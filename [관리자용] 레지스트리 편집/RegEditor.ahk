;관리자 권한 취득
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    If errorlevel
    Msgbox, 48, 관리자권한 오류, 관리자권한을 획득하는데 실패하였습니다. `n관리자 권한을 부여하시고, 다시 실행하여 주십시오.
    ExitApp
}


msgbox,4,경고,이 프로그램은 '방과후 자동화 프로그램'의 키 레지스트리를 삭제합니다.`n이를 숙지하셨다면 '확인'버튼을 눌러주십시오.
Ifmsgbox yes
{
regdelete, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable
regdelete, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent
regdelete, HKLM, SOFTWARE\AutoAfterSchool, Key
RegRead, LoginPass, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable
msgbox % "일회용 키 값 = "LoginPass
RegRead, LoginPass, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent
msgbox % "영구 키 값 = "LoginPass
}

msgbox,4,안내,키 레지스트리를 추가할까요?
Ifmsgbox yes
{
msgbox,4,안내,'네'버튼을 누르시면 '일회용 키'레지스트리를 추가합니다.
	Ifmsgbox yes
	regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable, ok
msgbox,4,안내,'네'버튼을 누스시면 '영구 키'레지스트리를 추가합니다.
	Ifmsgbox yes
	{
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent, ok
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool, Key, 관리자
	}
}
msgbox,0,안내, 모든 작업이 완료되었습니다.


guiclose:
exitapp