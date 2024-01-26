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
	"encoding/json"
	"path/filepath"
	"reflect"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	corev1 "k8s.io/api/core/v1"
)

type serviceTemplateTest struct {
	suite.Suite
	chartPath   string
	releaseName string
	namespace   string
	templates   []string
}

func TestServiceTemplate(t *testing.T) {
	t.Parallel()

	chartFullPath, err := filepath.Abs(chartPath)
	require.NoError(t, err)

	suite.Run(t, &serviceTemplateTest{
		Suite:       suite.Suite{},
		chartPath:   chartFullPath,
		releaseName: "test",
		namespace:   "metacollector-test",
		templates:   []string{"templates/service.yaml"},
	})
}

func (s *serviceTemplateTest) TestServiceCreateFalse() {
	options := &helm.Options{SetValues: map[string]string{"service.create": "false"}}
	// Render the service account and unmarshal it.
	_, err := helm.RenderTemplateE(s.T(), options, s.chartPath, s.releaseName, s.templates)
	s.Error(err, "should error")
	s.Equal("error while running command: exit status 1; Error: could not find template templates/service.yaml in chart", err.Error())
}

func (s *serviceTemplateTest) TestServiceType() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected string
	}{
		{"defaultValues",
			nil,
			"ClusterIP",
		},
		{"NodePort",
			map[string]string{
				"service.type": "NodePort",
			},
			"NodePort",
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}

			// Render the service and unmarshal it.
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")
			var svc corev1.Service
			helm.UnmarshalK8SYaml(subT, output, &svc)

			s.Equal(testCase.expected, string(svc.Spec.Type))
		})
	}
}

func (s *serviceTemplateTest) TestServicePorts() {
	newPorts := `{
    "enabled": true,
    "type": "ClusterIP",
    "ports": {
        "metrics": {
            "port": 8080,
            "targetPort": "metrics",
            "protocol": "TCP"
        },
        "health-probe": {
            "port": 8081,
            "targetPort": "health-probe",
            "protocol": "TCP"
        },
        "broker-grpc": {
            "port": 45000,
            "targetPort": "broker-grpc",
            "protocol": "TCP"
        },
        "myNewPort": {
            "port": 1111,
            "targetPort": "myNewPort",
            "protocol": "UDP"
        }
    }
}`
	testCases := []struct {
		name     string
		values   map[string]string
		expected func(p []corev1.ServicePort)
	}{
		{
			"defaultValues",
			nil,
			func(p []corev1.ServicePort) {
				portsJSON := `[
    {
        "name": "broker-grpc",
        "port": 45000,
        "protocol": "TCP",
        "targetPort": "broker-grpc"
    },
    {
        "name": "health-probe",
        "port": 8081,
        "protocol": "TCP",
        "targetPort": "health-probe"
    },
    {
        "name": "metrics",
        "port": 8080,
        "protocol": "TCP",
        "targetPort": "metrics"
    }
]`
				var ports []corev1.ServicePort

				err := json.Unmarshal([]byte(portsJSON), &ports)
				s.NoError(err)
				s.True(reflect.DeepEqual(ports, p), "should be equal")
			},
		},
		{
			"addNewPort",
			map[string]string{
				"service": newPorts,
			},
			func(p []corev1.ServicePort) {
				portsJSON := `[
    {
        "name": "broker-grpc",
        "port": 45000,
        "protocol": "TCP",
        "targetPort": "broker-grpc"
    },
    {
        "name": "health-probe",
        "port": 8081,
        "protocol": "TCP",
        "targetPort": "health-probe"
    },
    {
        "name": "metrics",
        "port": 8080,
        "protocol": "TCP",
        "targetPort": "metrics"
    },
    {
        "name": "myNewPort",
        "port": 1111,
        "protocol": "UDP",
        "targetPort": "myNewPort"
    }
]`
				var ports []corev1.ServicePort

				err := json.Unmarshal([]byte(portsJSON), &ports)
				s.NoError(err)
				s.True(reflect.DeepEqual(ports, p), "should be equal")
			},
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetJsonValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var svc corev1.Service
			helm.UnmarshalK8SYaml(subT, output, &svc)

			testCase.expected(svc.Spec.Ports)
		})
	}
}
