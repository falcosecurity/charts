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
	"fmt"
	"path/filepath"
	"reflect"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
)

type deploymentTemplateTest struct {
	suite.Suite
	chartPath   string
	releaseName string
	namespace   string
	templates   []string
}

func TestDeploymentTemplate(t *testing.T) {
	t.Parallel()

	chartFullPath, err := filepath.Abs(chartPath)
	require.NoError(t, err)

	suite.Run(t, &deploymentTemplateTest{
		Suite:       suite.Suite{},
		chartPath:   chartFullPath,
		releaseName: "k8s-metacollector-test",
		namespace:   "metacollector-test",
		templates:   []string{"templates/deployment.yaml"},
	})
}

func (s *deploymentTemplateTest) TestImage() {
	// Get chart info.
	cInfo, err := chartInfo(s.T(), s.chartPath)
	s.NoError(err)
	// Extract the appVersion.
	appVersion, found := cInfo["appVersion"]
	s.True(found, "should find app version from chart info")

	testCases := []struct {
		name     string
		values   map[string]string
		expected string
	}{
		{
			"defaultValues",
			nil,
			fmt.Sprintf("docker.io/falcosecurity/k8s-metacollector:%s", appVersion),
		},
		{
			"changingImageTag",
			map[string]string{
				"image.tag": "testingTag",
			},
			"docker.io/falcosecurity/k8s-metacollector:testingTag",
		},
		{
			"changingImageRepo",
			map[string]string{
				"image.repository": "falcosecurity/testingRepository",
			},
			fmt.Sprintf("docker.io/falcosecurity/testingRepository:%s", appVersion),
		},
		{
			"changingImageRegistry",
			map[string]string{
				"image.registry": "ghcr.io",
			},
			fmt.Sprintf("ghcr.io/falcosecurity/k8s-metacollector:%s", appVersion),
		},
		{
			"changingAllImageFields",
			map[string]string{
				"image.registry":   "ghcr.io",
				"image.repository": "falcosecurity/testingRepository",
				"image.tag":        "testingTag",
			},
			"ghcr.io/falcosecurity/testingRepository:testingTag",
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			s.Equal(testCase.expected, deployment.Spec.Template.Spec.Containers[0].Image, "should be equal")
		})
	}
}

func (s *deploymentTemplateTest) TestImagePullPolicy() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected string
	}{
		{
			"defaultValues",
			nil,
			"IfNotPresent",
		},
		{
			"changingPullPolicy",
			map[string]string{
				"image.pullPolicy": "Always",
			},
			"Always",
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			s.Equal(testCase.expected, string(deployment.Spec.Template.Spec.Containers[0].ImagePullPolicy), "should be equal")
		})
	}
}

func (s *deploymentTemplateTest) TestImagePullSecrets() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected string
	}{
		{
			"defaultValues",
			nil,
			"",
		},
		{
			"changingPullPolicy",
			map[string]string{
				"image.pullSecrets[0].name": "my-pull-secret",
			},
			"my-pull-secret",
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)
			if testCase.expected == "" {
				s.Nil(deployment.Spec.Template.Spec.ImagePullSecrets, "should be nil")
			} else {
				s.Equal(testCase.expected, deployment.Spec.Template.Spec.ImagePullSecrets[0].Name, "should be equal")
			}
		})
	}
}

func (s *deploymentTemplateTest) TestServiceAccount() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected string
	}{
		{
			"defaultValues",
			nil,
			s.releaseName,
		},
		{
			"changingServiceAccountName",
			map[string]string{
				"serviceAccount.name": "service-account",
			},
			"service-account",
		},
		{
			"disablingServiceAccount",
			map[string]string{
				"serviceAccount.create": "false",
			},
			"default",
		},
		{
			"disablingServiceAccountAndSettingName",
			map[string]string{
				"serviceAccount.create": "false",
				"serviceAccount.name":   "service-account",
			},
			"service-account",
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			s.Equal(testCase.expected, deployment.Spec.Template.Spec.ServiceAccountName, "should be equal")
		})
	}
}

func (s *deploymentTemplateTest) TestPodAnnotations() {
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
			"settingPodAnnotations",
			map[string]string{
				"podAnnotations.my-annotation": "annotationValue",
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
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			if testCase.expected == nil {
				s.Nil(deployment.Spec.Template.Annotations, "should be nil")
			} else {
				for key, val := range testCase.expected {
					val1 := deployment.Spec.Template.Annotations[key]
					s.Equal(val, val1, "should contain all the added annotations")
				}
			}
		})
	}
}

func (s *deploymentTemplateTest) TestPodSecurityContext() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected func(psc *corev1.PodSecurityContext)
	}{
		{
			"defaultValues",
			nil,
			func(psc *corev1.PodSecurityContext) {
				s.Equal(true, *psc.RunAsNonRoot, "runAsNonRoot should be set to true")
				s.Equal(int64(1000), *psc.RunAsUser, "runAsUser should be set to 1000")
				s.Equal(int64(1000), *psc.FSGroup, "fsGroup should be set to 1000")
				s.Equal(int64(1000), *psc.RunAsGroup, "runAsGroup should be set to 1000")
				s.Nil(psc.SELinuxOptions)
				s.Nil(psc.WindowsOptions)
				s.Nil(psc.SupplementalGroups)
				s.Nil(psc.Sysctls)
				s.Nil(psc.FSGroupChangePolicy)
				s.Nil(psc.SeccompProfile)
			},
		},
		{
			"changingServiceAccountName",
			map[string]string{
				"podSecurityContext": "null",
			},
			func(psc *corev1.PodSecurityContext) {
				s.Nil(psc, "podSecurityContext should be set to nil")
			},
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.SecurityContext)
		})
	}
}

func (s *deploymentTemplateTest) TestContainerSecurityContext() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected func(sc *corev1.SecurityContext)
	}{
		{
			"defaultValues",
			nil,
			func(sc *corev1.SecurityContext) {
				s.Len(sc.Capabilities.Drop, 1, "capabilities in drop should be set to one")
				s.Equal("ALL", string(sc.Capabilities.Drop[0]), "should drop all capabilities")
				s.Nil(sc.Capabilities.Add)
				s.Nil(sc.Privileged)
				s.Nil(sc.SELinuxOptions)
				s.Nil(sc.WindowsOptions)
				s.Nil(sc.RunAsUser)
				s.Nil(sc.RunAsGroup)
				s.Nil(sc.RunAsNonRoot)
				s.Nil(sc.ReadOnlyRootFilesystem)
				s.Nil(sc.AllowPrivilegeEscalation)
				s.Nil(sc.ProcMount)
				s.Nil(sc.SeccompProfile)
			},
		},
		{
			"changingServiceAccountName",
			map[string]string{
				"containerSecurityContext": "null",
			},
			func(sc *corev1.SecurityContext) {
				s.Nil(sc, "containerSecurityContext should be set to nil")
			},
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.Containers[0].SecurityContext)
		})
	}
}

func (s *deploymentTemplateTest) TestResources() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected func(res corev1.ResourceRequirements)
	}{
		{
			"defaultValues",
			nil,
			func(res corev1.ResourceRequirements) {
				s.Nil(res.Claims)
				s.Nil(res.Requests)
				s.Nil(res.Limits)
			},
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.Containers[0].Resources)
		})
	}
}

func (s *deploymentTemplateTest) TestNodeSelector() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected func(ns map[string]string)
	}{
		{
			"defaultValues",
			nil,
			func(ns map[string]string) {
				s.Nil(ns, "should be nil")
			},
		},
		{
			"Setting nodeSelector",
			map[string]string{
				"nodeSelector.mySelector": "myNode",
			},
			func(ns map[string]string) {
				value, ok := ns["mySelector"]
				s.True(ok, "should find the key")
				s.Equal("myNode", value, "should be equal")
			},
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.NodeSelector)
		})
	}
}

func (s *deploymentTemplateTest) TestTolerations() {
	tolerationString := `[
    {
        "key": "key1",
        "operator": "Equal",
        "value": "value1",
        "effect": "NoSchedule"
    }
]`
	var tolerations []corev1.Toleration

	err := json.Unmarshal([]byte(tolerationString), &tolerations)
	s.NoError(err)

	testCases := []struct {
		name     string
		values   map[string]string
		expected func(tol []corev1.Toleration)
	}{
		{
			"defaultValues",
			nil,
			func(tol []corev1.Toleration) {
				s.Nil(tol, "should be nil")
			},
		},
		{
			"Setting tolerations",
			map[string]string{
				"tolerations": tolerationString,
			},
			func(tol []corev1.Toleration) {
				s.Len(tol, 1, "should have only one toleration")
				s.True(reflect.DeepEqual(tol[0], tolerations[0]), "should be equal")
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

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.Tolerations)
		})
	}
}

func (s *deploymentTemplateTest) TestAffinity() {
	affinityString := `{
    "nodeAffinity": {
        "requiredDuringSchedulingIgnoredDuringExecution": {
            "nodeSelectorTerms": [
                {
                    "matchExpressions": [
                        {
                            "key": "disktype",
                            "operator": "In",
                            "values": [
                                "ssd"
                            ]
                        }
                    ]
                }
            ]
        }
    }
}`
	var affinity corev1.Affinity

	err := json.Unmarshal([]byte(affinityString), &affinity)
	s.NoError(err)

	testCases := []struct {
		name     string
		values   map[string]string
		expected func(aff *corev1.Affinity)
	}{
		{
			"defaultValues",
			nil,
			func(aff *corev1.Affinity) {
				s.Nil(aff, "should be nil")
			},
		},
		{
			"Setting affinity",
			map[string]string{
				"affinity": affinityString,
			},
			func(aff *corev1.Affinity) {
				s.True(reflect.DeepEqual(affinity, *aff), "should be equal")
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

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.Affinity)
		})
	}
}

func (s *deploymentTemplateTest) TestLiveness() {
	livenessProbeString := `{
    "httpGet": {
        "path": "/healthz",
        "port": 8081
    },
    "initialDelaySeconds": 45,
    "timeoutSeconds": 5,
    "periodSeconds": 15
}`
	var liveness corev1.Probe

	err := json.Unmarshal([]byte(livenessProbeString), &liveness)
	s.NoError(err)

	testCases := []struct {
		name     string
		values   map[string]string
		expected func(probe *corev1.Probe)
	}{
		{
			"defaultValues",
			nil,
			func(probe *corev1.Probe) {
				s.True(reflect.DeepEqual(*probe, liveness), "should be equal")
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

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.Containers[0].LivenessProbe)
		})
	}
}

func (s *deploymentTemplateTest) TestReadiness() {
	readinessProbeString := `{
    "httpGet": {
        "path": "/readyz",
        "port": 8081
    },
    "initialDelaySeconds": 30,
    "timeoutSeconds": 5,
    "periodSeconds": 15
}`
	var readiness corev1.Probe

	err := json.Unmarshal([]byte(readinessProbeString), &readiness)
	s.NoError(err)

	testCases := []struct {
		name     string
		values   map[string]string
		expected func(probe *corev1.Probe)
	}{
		{
			"defaultValues",
			nil,
			func(probe *corev1.Probe) {
				s.True(reflect.DeepEqual(*probe, readiness), "should be equal")
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

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.Containers[0].ReadinessProbe)
		})
	}
}

func (s *deploymentTemplateTest) TestContainerPorts() {

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
		expected func(p []corev1.ContainerPort)
	}{
		{
			"defaultValues",
			nil,
			func(p []corev1.ContainerPort) {
				portsJSON := `[
    {
        "name": "broker-grpc",
        "containerPort": 45000,
        "protocol": "TCP"
    },
    {
        "name": "health-probe",
        "containerPort": 8081,
        "protocol": "TCP"
    },
    {
        "name": "metrics",
        "containerPort": 8080,
        "protocol": "TCP"
    }
]`
				var ports []corev1.ContainerPort

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
			func(p []corev1.ContainerPort) {
				portsJSON := `[
    {
        "name": "broker-grpc",
        "containerPort": 45000,
        "protocol": "TCP"
    },
    {
        "name": "health-probe",
        "containerPort": 8081,
        "protocol": "TCP"
    },
    {
        "name": "metrics",
        "containerPort": 8080,
        "protocol": "TCP"
    },
    {
        "name": "myNewPort",
        "containerPort": 1111,
        "protocol": "UDP"
    }
]`
				var ports []corev1.ContainerPort

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

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			testCase.expected(deployment.Spec.Template.Spec.Containers[0].Ports)
		})
	}
}

func (s *deploymentTemplateTest) TestReplicaCount() {
	testCases := []struct {
		name     string
		values   map[string]string
		expected int32
	}{
		{
			"defaultValues",
			nil,
			1,
		},
	}

	for _, testCase := range testCases {
		testCase := testCase

		s.Run(testCase.name, func() {
			subT := s.T()
			subT.Parallel()

			options := &helm.Options{SetValues: testCase.values}
			output, err := helm.RenderTemplateE(subT, options, s.chartPath, s.releaseName, s.templates)
			s.NoError(err, "should succeed")

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(subT, output, &deployment)

			s.Equal(testCase.expected, (*deployment.Spec.Replicas), "should be equal")
		})
	}
}
