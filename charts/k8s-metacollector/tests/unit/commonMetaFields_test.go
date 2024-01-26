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
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
)

type commonMetaFieldsTest struct {
	suite.Suite
	chartPath   string
	releaseName string
	namespace   string
	templates   []string
}

func TestCommonMetaFields(t *testing.T) {
	t.Parallel()
	// Template files that will be rendered.
	templateFiles := []string{
		"templates/clusterrole.yaml",
		"templates/clusterrolebinding.yaml",
		"templates/deployment.yaml",
		"templates/service.yaml",
		"templates/serviceaccount.yaml",
		"templates/servicemonitor.yaml",
	}

	chartFullPath, err := filepath.Abs(chartPath)
	require.NoError(t, err)

	suite.Run(t, &commonMetaFieldsTest{
		Suite:       suite.Suite{},
		chartPath:   chartFullPath,
		releaseName: "releasename-test",
		namespace:   "metacollector-test",
		templates:   templateFiles,
	})
}

func (s *commonMetaFieldsTest) TestNameOverride() {
	cInfo, err := chartInfo(s.T(), s.chartPath)
	s.NoError(err)
	chartName, found := cInfo["name"]
	s.True(found)

	testCases := []struct {
		name     string
		values   map[string]string
		expected string
	}{
		{
			"defaultValues, release name does not contain chart name",
			map[string]string{
				"serviceMonitor.create": "true",
			},
			fmt.Sprintf("%s-%s", s.releaseName, chartName),
		},
		{
			"overrideFullName",
			map[string]string{
				"fullnameOverride":      "metadata",
				"serviceMonitor.create": "true",
			},
			"metadata",
		},
		{
			"overrideFullName, longer than 63 chars",
			map[string]string{
				"fullnameOverride":      "aVeryLongNameForTheReleaseThatIsLongerThanSixtyThreeCharsaVeryLongNameForTheReleaseThatIsLongerThanSixtyThreeChars",
				"serviceMonitor.create": "true",
			},
			"aVeryLongNameForTheReleaseThatIsLongerThanSixtyThreeCharsaVeryL",
		},
		{
			"overrideName, not containing release name",
			map[string]string{
				"nameOverride":          "metadata",
				"serviceMonitor.create": "true",
			},
			fmt.Sprintf("%s-metadata", s.releaseName),
		},

		{
			"overrideName, release name contains the name",
			map[string]string{
				"nameOverride":          "releasename",
				"serviceMonitor.create": "true",
			},
			s.releaseName,
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			for _, template := range s.templates {
				// Render the current template.
				output := helm.RenderTemplate(s.T(), options, s.chartPath, s.releaseName, []string{template})
				// Unmarshal output to a map.
				var resource unstructured.Unstructured
				helm.UnmarshalK8SYaml(s.T(), output, &resource)

				s.Equal(testCase.expected, resource.GetName(), "should be equal")
			}
		})
	}
}

func (s *commonMetaFieldsTest) TestNamespaceOverride() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected string
	}{
		{
			"defaultValues",
			map[string]string{
				"serviceMonitor.create": "true",
			},
			"default",
		},
		{
			"overrideNamespace",
			map[string]string{
				"namespaceOverride":     "metacollector",
				"serviceMonitor.create": "true",
			},
			"metacollector",
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			for _, template := range s.templates {
				// Render the current template.
				output := helm.RenderTemplate(s.T(), options, s.chartPath, s.releaseName, []string{template})
				// Unmarshal output to a map.
				var resource unstructured.Unstructured
				helm.UnmarshalK8SYaml(s.T(), output, &resource)
				if resource.GetKind() == "ClusterRole" || resource.GetKind() == "ClusterRoleBinding" {
					continue
				}
				s.Equal(testCase.expected, resource.GetNamespace(), "should be equal")
			}
		})
	}
}

// TestLabels tests that all rendered resources have the same base set of labels.
func (s *commonMetaFieldsTest) TestLabels() {
	// Get chart info.
	cInfo, err := chartInfo(s.T(), s.chartPath)
	s.NoError(err)
	// Get app version.
	appVersion, found := cInfo["appVersion"]
	s.True(found, "should find app version in chart info")
	appVersion = appVersion.(string)
	// Get chart version.
	chartVersion, found := cInfo["version"]
	s.True(found, "should find chart version in chart info")
	// Get chart name.
	chartName, found := cInfo["name"]
	s.True(found, "should find chart name in chart info")
	chartName = chartName.(string)
	expectedLabels := map[string]string{
		"helm.sh/chart":                fmt.Sprintf("%s-%s", chartName, chartVersion),
		"app.kubernetes.io/name":       chartName.(string),
		"app.kubernetes.io/instance":   s.releaseName,
		"app.kubernetes.io/version":    appVersion.(string),
		"app.kubernetes.io/managed-by": "Helm",
		"app.kubernetes.io/component":  "metadata-collector",
	}

	// Adjust the values to render all components.
	options := helm.Options{SetValues: map[string]string{"serviceMonitor.create": "true"}}

	for _, template := range s.templates {
		// Render the current template.
		output := helm.RenderTemplate(s.T(), &options, s.chartPath, s.releaseName, []string{template})
		// Unmarshal output to a map.
		var resource unstructured.Unstructured
		helm.UnmarshalK8SYaml(s.T(), output, &resource)
		labels := resource.GetLabels()
		s.Len(labels, len(expectedLabels), "should have the same number of labels")
		for key, value := range labels {
			expectedVal := expectedLabels[key]
			s.Equal(expectedVal, value)
		}
	}
}
