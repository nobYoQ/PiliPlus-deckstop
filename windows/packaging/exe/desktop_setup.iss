; Build the modified desktop release with the upstream installer identity.
; Keep AppId, install privileges and architecture aligned with make_config.yaml
; and inno_setup.iss so upstream and local builds upgrade the same installation.
; Build with ISCC.exe /DProjectRoot=<repository path> desktop_setup.iss
#ifndef ProjectRoot
  #error ProjectRoot must point to the repository root.
#endif
#define AppName "PiliPlus"
#define AppVersion GetStringFileInfo(ProjectRoot + "\build\windows\x64\runner\Release\piliplus.exe", "ProductVersion")

[Setup]
AppId=5ef970f9-2b9e-4155-b7d6-a9d4dbd6b226
AppVersion={#AppVersion}
AppName={#AppName}
AppPublisher=dom
AppPublisherURL=https://github.com/bggRGjQaUbCoE/PiliPlus
AppSupportURL=https://github.com/bggRGjQaUbCoE/PiliPlus
AppUpdatesURL=https://github.com/bggRGjQaUbCoE/PiliPlus
DefaultDirName={autopf}\PiliPlus
UsePreviousAppDir=yes
DisableProgramGroupPage=yes
OutputDir={#ProjectRoot}\dist
OutputBaseFilename=PiliPlus_windows_{#AppVersion}_x64_setup
Compression=lzma
SolidCompression=yes
SetupIconFile={#ProjectRoot}\windows\runner\resources\app_icon.ico
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Code]
procedure KillOldProcess;
var ResultCode: Integer;
begin
  Exec('taskkill', '/F /IM piliplus.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

function InitializeSetup(): Boolean;
begin
  KillOldProcess;
  Result := True;
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "{#ProjectRoot}\windows\packaging\exe\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,{#AppName}}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#ProjectRoot}\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\piliplus.exe"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\piliplus.exe"; Tasks: desktopicon
Name: "{userstartup}\{#AppName}"; Filename: "{app}\piliplus.exe"; WorkingDir: "{app}"; Tasks: launchAtStartup

[Registry]
Root: HKCU; Subkey: "Software\Classes\bilibili"; ValueType: string; ValueData: "URL:Bilibili Protocol"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\bilibili"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\bilibili\DefaultIcon"; ValueType: string; ValueData: "{app}\piliplus.exe,0"
Root: HKCU; Subkey: "Software\Classes\bilibili\shell\open\command"; ValueType: string; ValueData: """{app}\piliplus.exe"" ""%1"""

[Run]
Filename: "{app}\piliplus.exe"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: runascurrentuser nowait postinstall skipifsilent
