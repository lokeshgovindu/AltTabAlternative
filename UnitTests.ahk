/*
o-----------------------------------------------------------------------------o
|   Author : Lokesh Govindu                                                   |
|    Email : lokeshgovindu@gmail.com                                          |
| HomePage : http://lokeshgovindu.blogspot.in/                                |
o-----------------------------------------------------------------------------o
*/

#Include %A_ScriptDir%\CommonUtils.ahk

CheckForUpdatesDialogTest()

ExitApp


CheckVersion(ProductVersion, LatestVersion, ExpectedResult) {
	isLatestVersion := IsLatestRelease(ProductVersion, LatestVersion)
	FormatTime, CurrentTime, , yyyy-MM-dd HH:mm:ss
	result := (isLatestVersion == ExpectedResult ? "Pass" : "Fail")
	FileAppend, [%CurrentTime%] %result%: ProductVersion = [%ProductVersion%]`, LatestVersion = [%LatestVersion%]`n, *
}

CheckForUpdatesDialogTest() {
	ProductVersion := "1.0.0.1"
	LatestVersion := "1.0.0.2"
	
	CheckVersion(ProductVersion, LatestVersion, true)
	CheckVersion(LatestVersion, ProductVersion, false)
}

#Include %A_ScriptDir%\CheckForUpdatesDialog.ahk
