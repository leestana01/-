;������ ���� ���
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
    Msgbox, 48, �����ڱ��� ����, �����ڱ����� ȹ���ϴµ� �����Ͽ����ϴ�. `n������ ������ �ο��Ͻð�, �ٽ� �����Ͽ� �ֽʽÿ�.
    ExitApp
}


msgbox,4,���,�� ���α׷��� '����� �ڵ�ȭ ���α׷�'�� Ű ������Ʈ���� �����մϴ�.`n�̸� �����ϼ̴ٸ� 'Ȯ��'��ư�� �����ֽʽÿ�.
Ifmsgbox yes
{
regdelete, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable
regdelete, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent
regdelete, HKLM, SOFTWARE\AutoAfterSchool, Key
RegRead, LoginPass, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable
msgbox % "��ȸ�� Ű �� = "LoginPass
RegRead, LoginPass, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent
msgbox % "���� Ű �� = "LoginPass
}

msgbox,4,�ȳ�,Ű ������Ʈ���� �߰��ұ��?
Ifmsgbox yes
{
msgbox,4,�ȳ�,'��'��ư�� �����ø� '��ȸ�� Ű'������Ʈ���� �߰��մϴ�.
	Ifmsgbox yes
	regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable, ok
msgbox,4,�ȳ�,'��'��ư�� �����ø� '���� Ű'������Ʈ���� �߰��մϴ�.
	Ifmsgbox yes
	{
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent, ok
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool, Key, ������
	}
}
msgbox,0,�ȳ�, ��� �۾��� �Ϸ�Ǿ����ϴ�.


guiclose:
exitapp