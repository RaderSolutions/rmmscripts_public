package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
)

func main() {
	PoshInstallDir := (os.Getenv("PROGRAMFILES") + "\\pwsh")
	poshExe := PoshInstallDir + "\\pwsh.exe"
	fmt.Println("Checking posh @ " + poshExe)
	if isPowerShellInstalled(poshExe) == false {
		installPowerShellPortable(PoshInstallDir)
		fmt.Println("Installed Powershell Portable")
		if isPowerShellInstalled(poshExe) == false {
			fmt.Println("ERROR: Powershell still not working")
		}
	}

	beatScript := ".\\winshares.ps1"
	beatOutput := exec.Command(poshExe, "/C", beatScript)
	if err := beatOutput.Run(); err != nil {
		fmt.Println("Error: Failed to execute beats config script", err)
	}

}

func installPowerShellPortable(installDir string) {

	fileUrl := "https://aka.ms/install-powershell.ps1"
	err := DownloadFile("install-powershell.ps1", fileUrl)
	if err != nil {
		panic(err)
	}
	fmt.Println("Downloaded: " + fileUrl)
	instPath := ("\"" + installDir + "\"")
	poshCmd := `.\install-powershell.ps1 -Destination ` + instPath
	fmt.Println("Installing pwsh to", installDir)
	fmt.Println(poshCmd)
	poshOutput := exec.Command("powershell.exe", "/C", poshCmd)
	if err := poshOutput.Run(); err != nil {
		fmt.Println("Error: Failed to execute system-level powershell", err)
	}

}

func isPowerShellInstalled(poshExe string) bool {
	cmd := exec.Command(poshExe, "-v")
	if err := cmd.Run(); err != nil {
		return false
	}
	return true
}

func DownloadFile(filepath string, url string) error {

	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Create the file
	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	// Write the body to file
	_, err = io.Copy(out, resp.Body)
	return err
}
