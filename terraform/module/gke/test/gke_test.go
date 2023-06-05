package test

import (
	"fmt"
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"net/http"
)


func TestTerraformGKECreation(t *testing.T) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"cluster_name": "testing",
			"project_id": "devops-testing",
			"masters_cidr": "10.14.64.0/27",
			"subnets": map[string]interface{}{
				"nodes": "10.0.0.1/24",
				"pods": "10.0.1.0/24",
				"services": "10.0.1.0/25",
			},
			"k8s_namespaces": map[string]interface{}{
				"apps": map[string]interface{}{
				  "labels": map[string]interface{}{},
				  "annotations": map[string]interface{}{},
				},
				"cert-manager": map[string]interface{}{
				  "labels": map[string]interface{}{},
				  "annotations": map[string]interface{}{},
				},
			},
		},
	})

	// delete our resources after finishing testing
	defer terraform.Destroy(t, terraformOptions)

	// init and apply terraform
	terraform.InitAndApply(t, terraformOptions)

	// get control plane endpoint after apply finish
	controlPlaneEndpoint := terraform.Output(t, terraformOptions, "endpoint")

	// get kube api server access token from execution environment
	var token string
	flag.StringVar(&token, "token", "", "kube api access token")

	// make http request to check we get 200 status code form the API
	url := fmt.Sprintf("https://%s:6443/api", controlPlaneEndpoint)

	// prepare request
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		fmt.Printf("error when trying to form the request %s\n", err)
		os.Exit(1)
	}

	req.Header.Set( "Authorization", fmt.Sprintf("Bearer %s", token))

	client := http.Client{
		Timeout: 30 * time.Second,
	 }
	
	 res, err := client.Do(req)
	 if err != nil {
		fmt.Printf("client: error making http request: %s\n", err)
		os.Exit(1)
	}

	// check if we get a 200 status code
	want := 200
	got := res.StatusCode
	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}

}