package unit

import (
	"github.com/gruntwork-io/terratest/modules/helm"
	"gopkg.in/yaml.v3"
	"testing"
)

func chartInfo(t *testing.T, chartPath string) (map[string]interface{}, error) {
	// Get chart info.
	output, err := helm.RunHelmCommandAndGetOutputE(t, &helm.Options{}, "show", "chart", chartPath)
	if err != nil {
		return nil, err
	}
	chartInfo := map[string]interface{}{}
	err = yaml.Unmarshal([]byte(output), &chartInfo)
	return chartInfo, err
}
