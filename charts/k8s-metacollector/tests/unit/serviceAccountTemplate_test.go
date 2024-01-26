// SPDX-License-Identifier: Apache-2.0
// Copyright 2024 The Falco Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package unit

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	corev1 "k8s.io/api/core/v1"
	rbacv1 "k8s.io/api/rbac/v1"
)

// Type used to implement the testing suite for service account
// and the related resources: clusterrole, clusterrolebinding
type serviceAccountTemplateTest struct {
	suite.Suite
	chartPath   string
	releaseName string
	namespace   string
	templates   []string
}

func TestServiceAccountTemplate(t *testing.T) {
	t.Parallel()

	chartFullPath, err := filepath.Abs(chartPath)
	require.NoError(t, err)

	suite.Run(t, &serviceAccountTemplateTest{
		Suite:       suite.Suite{},
		chartPath:   chartFullPath,
		releaseName: "k8s-metacollector-test",
		namespace:   "metacollector-test",
		templates:   []string{"templates/serviceaccount.yaml"},
	})
}

func (s *serviceAccountTemplateTest) TestSVCAccountResourceCreation() {
	testCases := []struct {
		name   string
		values map[string]string
	}{
		{"defaultValues",
			nil,
		},
		{"changeName",
			map[string]string{
				"serviceAccount.name": "TestName",
			},
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}

			// Render the service account and unmarshal it.
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")
			var svcAccount corev1.ServiceAccount
			helm.UnmarshalK8SYaml(subT, output, &svcAccount)

			// Render the clusterRole and unmarshal it.
			output, err = helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, []string{"templates/clusterrole.yaml"})
			s.NoError(err, "should succeed")
			var clusterRole rbacv1.ClusterRole
			helm.UnmarshalK8SYaml(subT, output, &clusterRole)

			output, err = helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, []string{"templates/clusterrolebinding.yaml"})
			s.NoError(err, "should succeed")
			var clusterRoleBinding rbacv1.ClusterRoleBinding
			helm.UnmarshalK8SYaml(subT, output, &clusterRoleBinding)

			// Check that clusterRoleBinding references the right svc account.
			s.Equal(svcAccount.Name, clusterRoleBinding.Subjects[0].Name, "should be the same")
			s.Equal(svcAccount.Namespace, clusterRoleBinding.Subjects[0].Namespace, "should be the same")

			// Check that clusterRobeBinding references the right clusterRole.
			s.Equal(clusterRole.Name, clusterRoleBinding.RoleRef.Name)

			if testCase.values != nil {
				s.Equal("TestName", svcAccount.Name)
			}
		})
	}
}

func (s *serviceAccountTemplateTest) TestSVCAccountResourceNonCreation() {
	options := &helm.Options{SetValues: map[string]string{"serviceAccount.create": "false"}}
	// Render the service account and unmarshal it.
	_, err := helm.RenderTemplateE(s.T(), options, s.chartPath, s.releaseName, s.templates)
	s.Error(err, "should error")
	s.Equal("error while running command: exit status 1; Error: could not find template templates/serviceaccount.yaml in chart", err.Error())

	// Render the clusterRole and unmarshal it.
	_, err = helm.RenderTemplateE(s.T(), options, s.chartPath, s.releaseName, []string{"templates/clusterrole.yaml"})
	s.Error(err, "should error")
	s.Equal("error while running command: exit status 1; Error: could not find template templates/clusterrole.yaml in chart", err.Error())

	_, err = helm.RenderTemplateE(s.T(), options, s.chartPath, s.releaseName, []string{"templates/clusterrolebinding.yaml"})
	s.Error(err, "should error")
	s.Equal("error while running command: exit status 1; Error: could not find template templates/clusterrolebinding.yaml in chart", err.Error())
}

func (s *serviceAccountTemplateTest) TestSVCAccountAnnotations() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected map[string]string
	}{
		{
			"defaultValues",
			nil,
			nil,
		},
		{
			"settingSvcAccountAnnotations",
			map[string]string{
				"serviceAccount.annotations.my-annotation": "annotationValue",
			},
			map[string]string{
				"my-annotation": "annotationValue",
			},
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			// Render the service account and unmarshal it.
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")
			var svcAccount corev1.ServiceAccount
			helm.UnmarshalK8SYaml(subT, output, &svcAccount)

			if testCase.expected == nil {
				s.Nil(svcAccount.Annotations, "should be nil")
			} else {
				for key, val := range testCase.expected {
					val1 := svcAccount.Annotations[key]
					s.Equal(val, val1, "should contain all the added annotations")
				}
			}
		})
	}
}
