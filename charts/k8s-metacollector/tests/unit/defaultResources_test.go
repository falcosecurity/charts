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
	"regexp"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	"k8s.io/utils/strings/slices"
)

const chartPath = "../../"

// Using the default values we want to test that all the expected resources are rendered.
func TestRenderedResourcesWithDefaultValues(t *testing.T) {
	t.Parallel()

	helmChartPath, err := filepath.Abs(chartPath)
	require.NoError(t, err)

	releaseName := "rendered-resources"

	// Template files that we expect to be rendered.
	templateFiles := []string{
		"clusterrole.yaml",
		"clusterrolebinding.yaml",
		"deployment.yaml",
		"service.yaml",
		"serviceaccount.yaml",
	}

	require.NoError(t, err)

	options := &helm.Options{}

	// Template the chart using the default values.yaml file.
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, nil)
	require.NoError(t, err)

	// Extract all rendered files from the output.
	pattern := `# Source: k8s-metacollector/templates/([^\n]+)`
	re := regexp.MustCompile(pattern)
	matches := re.FindAllStringSubmatch(output, -1)

	var renderedTemplates []string
	for _, match := range matches {
		// Filter out test templates.
		if !strings.Contains(match[1], "test-") {
			renderedTemplates = append(renderedTemplates, match[1])
		}
	}

	// Assert that the rendered resources are equal tho the expected ones.
	require.Equal(t, len(renderedTemplates), len(templateFiles), "should be equal")

	for _, rendered := range renderedTemplates {
		require.True(t, slices.Contains(templateFiles, rendered), "template files should contain all the rendered files")
	}
}
