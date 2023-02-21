#Persistent
#SingleInstance force
#Include ./INet.ahk
SetWorkingDir %A_scriptDir%
DetectHiddenWindows,on
SetTitleMatchMode,slow
SetTitleMatchMode,2

PatVersion = 4.8

server = <<������>>
port = <<������>> 
User = <<������>>
Pwd = <<������>>

;������Ʈ ���� : �α��ν� ��� �ð� 1�ʷ� ����. �� �� ��ȸ�� Ű �Է� ����ڿ� ���� �ҽ� �Ϻ� ����

;������ ���� ���---------------------------------------------------------------------------------------

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

;Ʈ���� ������-----------------------------------------------------------------------------------
Menu, tray, NoStandard

Menu, tray, add, Made by_ �̼���, return
Menu, tray, add, ���α׷� �����(F8), F8
Menu, tray, add, ���α׷� ����(Ctrl+Q), ^Q

;��Ų ������------------------------------------------------------------------------------------
SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
		}
}

FileInstall, Skin.zip, %A_Temp%\Skin.zip, 1  ;ZIP ����

Zip := ComObjCreate("Shell.Application")  ;�� ������Ʈ ����
Folder := Zip.NameSpace(A_Temp "\Skin.zip")   ; .ZIP �������� ����, ���⼭�� �ӽ�����(A_Temp)\���ҽ�.zip
NewFolder := Zip.NameSpace(A_Temp)                ; ������ Ǯ ��� ����, ���⼭�� �ӽ�����(A_Temp)
NewFolder.CopyHere(Folder.items, 4|16)          ; ��������, �ӽ�����(A_Temp)�� ���ҽ�.zip ������ ǰ, �׻� �����

SkinForm(Apply, A_Temp . "\AfterSchoolManager\USkin.dll", A_Temp . "\AfterSchoolManager\Luminous.msstyles")
SetWorkingDir %Temp%
;���α׷� �⺻ ���� �ٿ�ε�--------------------------------------------------------------------------
Runwait %comspec% /c netsh advfirewall firewall delete rule name=`"%A_ScriptName%`",,hide
Runwait %comspec% /c netsh advfirewall firewall add rule name=`"%A_ScriptName%`" dir=in program=`"%A_ScriptFullPath%`" action=allow,,hide


;���� ���� ����
filedelete, Log.txt
filedelete, Patcher.ini
filedelete, Patcher

urldownloadtofile, ftp://<<������>>:<<������>>@<<������>>/Files/AfterSchool/Patcher.ini, Patcher
if errorlevel
{
	msgbox,,���� �߻�,(�����ڵ�:2-1) `n����ġ ���� ���� �߻�. `n`n������ ���� ������ ���� �� �ֽ��ϴ�.`n`n1. ������ �����ְų�, ����Ǿ����ϴ�. �� ��� �����ڿ��� �����Ͽ��� �մϴ�. ���� ������ ���α׷��� �ֽŹ������� �ٿ�޾ƾ� �� ���� �ֽ��ϴ�. `n2.���� ������ �ջ�Ǿ����ϴ�. �� ��� �����ڰ� ������ ���� �����Ͽ����մϴ�. `n`n�켱`n���� �ּҿ��� �ֽŹ����� �ֱ������� Ȯ���Ͽ� ���� �������� üũ�Ͻʽÿ�.`n������ڵ�.oa.to �Ǵ� �ڵ������.oa.to `n`n BY LEESH
	goto ^Q
}

;���� ���� üũ
IniRead, Version, Patcher, Version, Ver
if Version > %PatVersion%
	{
	msgbox,,���� ����,���� �ֽ� ������ �ƴմϴ�. `n�ֽ� ������ �ٿ�ε��Ͽ� �ֽʽÿ�.
	run, <<�ֽ� ���� ��ũ>>
	filedelete, Patcher
	goto ^Q
	}

IniRead, PatLog, Patcher, Notice, PatLog

;������Ʈ�� �ε�
RegRead, LoginDis, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable
RegRead, LoginPer, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent

;�α��� â ����
Gui, 2:Add, GroupBox, x2 y0 w180 h70 , Member Login
	Gui, 2:Add, Text, x12 y19 w40 h20 , ID :
	Gui, 2:Add, Text, x12 y39 w40 h20 , PW :
	Gui, 2:Add, Edit, x52 y19 w120 h20 v���̵�, 
	Gui, 2:Add, Edit, x52 y39 w120 h20 password v���, 
Gui, 2:Add, GroupBox, x2 y79 w180 h70 , ����Ű �Է�
	Gui, 2:Add, Text, x12 y99 w70 h20 , ���� ���� :
	Gui, 2:Add, Text, x82 y99 w90 h20 vSecState, ���� �����
	Gui, 2:Add, Edit, x12 y119 w160 h20 vSecKey, 
Gui, 2:Add, Text, x187 y0 w180 h90 , [�ȳ�����]`n*ID`,PW�� ����� ���� ����`n`n*��� ����Ű�� ��ȸ���Դϴ�.`n`n*�̸� �Է½� ���� �߻��ÿ�`n   ����� ��ó�� �����մϴ�.

Gui, 2:Add, Text, x190 y100 w100 h20 , [���� �̸�-����]
Gui, 2:Add, edit, x290 y95 w70 h20 vUserName, 

Gui, 2:Add, Button, x192 y119 w170 h30 default gPatChk, �α���
Gui, 2:Show, h159 w375, ����� �ڵ� ��û ���α׷�

If (InStr(LoginPer, "ok"))	;Patcher ���� ������ �ʿ��� ���� �̸� ����
	{
	RegRead, SecKey, HKLM, SOFTWARE\AutoAfterSchool, Key
	if SecKey = 
	{
		msgbox,,���ε��� ����, ���ε��� ���� �����̾� �����Դϴ�. �����̾� Ű�� �ٽ� �Է����ֽʽÿ�.`n`n���α׷��� ������մϴ�.
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent,
		goto F8
	}
	IniRead, ClassNotice, Patcher, Notice, Pre
	guicontrol,2:, SecState, ������-�����̾�
	guicontrol,2:, Seckey, �����Ϸ�-�����̾�
	}
else
If (InStr(LoginDis, "ok"))	;Patcher ���� ������ �ʿ��� ���� �̸� ����
	{
	guicontrol,2:, SecState, ������-��ȸ��
	guicontrol,2:, Seckey, �����Ϸ�
	}
else
	IniRead, ClassNotice, Patcher, Notice, Norm

Return

;��ġ Ȯ��------------------------------------------------------------------------------------------

PatChk:

Gui, 2:hide

Gui 4: -Resize +LastFound -caption
Gui, 4:Add, Text, x12 y9 w270 h20 , �۾��� �غ����Դϴ�. ��ø� ��ٷ� �ֽʽÿ�.
Gui, 4:Add, ListBox, x12 y29 w270 h70 vPreListBox, ��ȿŰ �˻���...
Gui, 4:Add, Progress, x12 y99 w270 h20 vPreProgress, 0
Gui, 4:Show, h133 w299, �۾� �غ���

;������ �ٽ� �ٿ�ε� ��
filedelete, Patcher
urldownloadtofile, ftp://<<������>>:<<������>>@<<������>>/Files/AfterSchool/Patcher.ini, Patcher
if errorlevel
{
	msgbox,,���� �߻�,(�����ڵ�:2-1) `n����ġ ���� ���� �߻�.
	goto ^Q
}


;���� �̸��� �ۼ���
IniRead, �����̸�, Patcher, �����̸�, �̸�
Loop, parse, �����̸�, |
	���¸�%A_index% = %A_loopfield%

;���� �� ���� Ȯ��
Gui, 2:submit,nohide
IniRead, OnOff, Patcher, Server, ServerChk
if OnOff = On
	goto KeyChk
if OnOff = Off
	{
	msgbox,,���� ���� ����,(�����ڵ�:1)�α��� ������ �������� �ʽ��ϴ�. `n�����ڿ��� �����Ͽ� �ֽʽÿ�. `n`n���α׷��� �����մϴ�.
	filedelete, Patcher
	goto ^Q
	}
else
	msgbox,,���� �߻�,(�����ڵ�:2) `n����ġ ���� ���� �߻�.`n`n���α׷��� �����մϴ�.
	filedelete, Patcher
	goto ^Q
return

KeyChk:
;DisŰ�� ���� ������ ��� �α� �ۼ��� �̹� �Ϸ� �Ǿ��⿡ �� ������ �پ� ����.
If (InStr(LoginDis, "ok"))
goto Web
;�����̾� ������ ��� �ٷ� �α� �ۼ����� ����
If (InStr(LoginPer, "ok"))
goto LogInput

;����� üũ
IniRead, UsedKey, Patcher, UsedKey, Key

IniRead, BlackLists, Patcher, BlackLists, Key
Loop, parse, BlackLists, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,���� �߻�,(�����ڵ�:6) `n%Banned%`n�ڼ��� ���� �����ڿ��� �����Ͻñ� �ٶ��ϴ�.
		filedelete, Patcher
		goto F8
		}
}


Loop, parse, UsedKey, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,���� �߻�,(�����ڵ�:3) `n�̹� ���� �����ڵ��Դϴ�.
		filedelete, Patcher
		goto F8
		}
}

IniRead, PerKey, Patcher, PerKey, Key ;�����̾� Ű Ȯ��
Loop, parse, PerKey, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,�����Ϸ�,�����Ǿ����ϴ�.`n`n���� ���� : �����̾� ����
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent, ok
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool, Key, %Seckey%
		goto Keyinput
		}
}

IniRead, DisKey, Patcher, DisKey, Key ;��ȸ�� Ű Ȯ��
Loop, parse, DisKey, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,�����Ϸ�,�����Ǿ����ϴ�.`n`n���� ���� : ��ȸ�� ����`n(���α׷� ����� �����ڵ� �űԹ߱��� �ʿ��մϴ�)
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable, ok
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool, Key, %Seckey%
		goto Keyinput
		}
}

msgbox,,������ȣ�� Ȯ�ε��� ����,�������� �ʴ� ������ȣ�Դϴ�. �ٽ� Ȯ���Ͽ� �ֽʽÿ�.
goto F8
return

;���� Ű�� ���� ������.
Keyinput:
IniRead, Usedkey, Patcher, Usedkey, Key
iniwrite, %UsedKey%|%SecKey%, Patcher, UsedKey, Key

;�α׸� �ۼ���
LogInput:

urldownloadtofile, ftp://<<������>>:<<������>>@<<������>>/Files/AfterSchool/Log.txt, Log.txt
FileAppend, [%A_YYYY%/%A_MM%/%A_DD%/%A_Hour%:%A_Min%:%A_sec%]`n �����ڵ� : %SecKey% | �̸� : %UserName% `n, Log.txt
sleep 300
filecopy, Patcher, Patcher.ini, 1
filedelete, Patcher

InetOpen() 
hFTP:=INetConnect(Server, Port, User, Pwd, "ftp")

if(hFTP) 
	{ 
	FtpSetCurrentDirectory(hFTP, "/Files/AfterSchool/") 
	FtpPutFile(hFTP, "Log.txt")
		if errorlevel
		{
			msgbox,,���� �߻�,(�����ڵ�:4 - Log) `n�������� ���ῡ ������ �߻��Ͽ����ϴ�. - Log
			filedelete, Log.txt
			filedelete, Patcher.ini
			goto ^Q
		}
	FtpPutFile(hFTP, "Patcher.ini")
		if errorlevel
		{
			msgbox,,���� �߻�,(�����ڵ�:4 - Pat) `n�������� ���ῡ ������ �߻��Ͽ����ϴ�. - Pat
			filedelete, Log.txt
			filedelete, Patcher.ini
			goto ^Q
		}
	INetCloseHandle(hFTP) 
	}
else
	{
		msgbox,, ���� �߻�,(�����ڵ�:5) `n�������� ���ῡ ������ �߻��Ͽ����ϴ�.
		filedelete, Log.txt
		filedelete, Patcher.ini
		goto ^Q
	}

filedelete, Log.txt
filedelete, Patcher.ini
INetClose() 
;�ڵ� �α��� ����---------------------------------------------------------------------------------
Web:
Guicontrol, 4:, PreListBox, ����Ʈ�� �α������Դϴ�...
Guicontrol, 4:, PreProgress, 25

Gui, 2:submit, nohide
Gui, 2:destroy

RegRead, SecKey, HKLM, SOFTWARE\AutoAfterSchool, Key ;�Ŀ� �α� �ۼ��� ���� �̸� ���� Ű���� �޾Ƶ�.

Gui 1: -Resize +LastFound -caption
Gui, 1:Show, hide x0 y0 w916 h902, ���� ��Ȳ ǥ��â(�������Ƶ� �˴ϴ�.)
COM_AtlAxWinInit()
COM_CoInitialize()
COM_Error(0)
web:="<<������û ����Ʈ>>/regi/login.php"
pwb := COM_AtlAxGetControl(COM_AtlAxCreateContainer(WinExist(), 0, 0, 1280, 970, "Shell.Explorer"))
COM_Invoke( pwb, "Visible", True )
COM_Invoke( pwb, "Navigate", web )
;while, COM_Invoke( pwb, "readyState" ) <> "4"
;	Continue
gosub pagewait
ControlFocus, ,% "ahk_id " . COM_AtlAxGetContainer(pwb)

COM_Invoke( pwb, "document.all.id.value", ���̵� )
COM_Invoke( pwb, "document.all.pw.value", ���)


�α��μҽ� := COM_Invoke( pwb, "document.documentElement.InnerHTML") ; ���ͳ� �ҽ� ����
;clipboard := �α��μҽ�
pos = 1
While pos := RegExMatch(�α��μҽ�, "#ff0000.{11}(.)", SecCode, pos+StrLen(SecCode)) ; �ҽ��� ���Խ��� ������ SecCode��� ������ �ֿ�
�����ڵ� .= SecCode1 ; SecCode�� ã�� ���� ��� ǥ�� / SecCode�� �ϸ� ()�� ������ �׷� �߿� 1�� ���븸 ǥ��
COM_Invoke( pwb, "document.all.spamcode.value", �����ڵ�)
COM_Invoke( pwb, "document.all.form.submit()")
�α��μҽ� = "" ; �α��μҽ� ���� ����
;���� ���ͳ� �ּҸ� Ȯ���Ͽ� �α����� ���������� �Ǿ������� Ȯ����.--------------------------------------------
While, Com_invoke(pwb, "document.url") = "<<������û ����Ʈ>>/regi/login.php"
	Continue
sleep 1000
If (Com_invoke(pwb, "document.url") <> "<<������û ����Ʈ>>/student/agree.php")
{
regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable, ok
msgbox,,�α��� ����,���̵� Ȥ�� ��й�ȣ�� �߸��Ǿ��ų�`, ���ͳ� �ӵ��� �ʹ� �����ϴ�.
goto F8
}
Guicontrol, 4:, PreListBox, ������ �̵� �غ���...
Guicontrol, 4:, PreProgress, 50

;����� ���Ǽ� ����-----------------------------------------------------------------------------
COM_Invoke(pwb, "document.all.item[27].click")
COM_Invoke(pwb, "document.all.item[41].click")
COM_Invoke(pwb, "document.all.item[48].click")

Guicontrol, 4:, PreListBox, ���� ����� �ҷ�������...
Guicontrol, 4:, PreProgress, 75

gosub pagewait

;���� ��û ������ ����----------------------------------------------------------------------------
COM_Invoke( pwb, "Navigate", "<<������û ����Ʈ>>/student/consent.php" )

gosub pagewait
;���� ��û ��� �о����-------------------------------------------------------------------------
��ϼҽ� := COM_Invoke( pwb, "document.documentElement.InnerHTML")

Sch=returl=consent.php`"`>
fileappend, % ��ϼҽ�, test.txt
��ϼҽ� = "" ; ��ϼҽ� ���� ����
loop, read, test.txt ;����� �о�鿩�� �� ���� �ٷ� �տ� �ش� ���¸� ���������� ���� ����. ���⼭�� '(����)'
{
	if ALists <> 1
		if Instr( A_loopreadline, ���¸�1)
		{
			fileappend, returl=consent.php">(����)aaaaaaaaa`n, Out.txt
			ALists = 1
		}
	if BLists <> 1
		if Instr( A_loopreadline, ���¸�2)
		{
			fileappend, returl=consent.php">&|(����)aaaaaaaaa`n, Out.txt
			BLists = 1
		}
	if CLists <> 1
		if Instr( A_loopreadline, ���¸�3)
		{
			fileappend, returl=consent.php">&|(����)aaaaaaaaa`n, Out.txt
			
			CLists = 1
		}
	if DLists <> 1
		if Instr( A_loopreadline, ���¸�4)
		{
			fileappend, returl=consent.php">&|(����)aaaaaaaaa`n, Out.txt
			
			DLists = 1
		}
	if ELists <> 1
		if Instr( A_loopreadline, ���¸�5)
		{
			fileappend, returl=consent.php">&|(����)aaaaaaaaa`n, Out.txt
			ELists = 1
		}
	if FLists <> 1
		if Instr( A_loopreadline, ���¸�6)
		{
			fileappend, returl=consent.php">&|(����)aaaaaaaaa`n, Out.txt
			FLists = 1

		}
	if GLists <> 1
		if Instr( A_loopreadline, ���¸�7)
		{
			fileappend, returl=consent.php">&|(����)aaaaaaaaa`n, Out.txt
			GLists = 1
		}
	if HLists <> 1
		if Instr( A_loopreadline, ���¸�8)
		{
			fileappend, returl=consent.php">&|(����)aaaaaaaaa`n, Out.txt
			HLists = 1
		}
	if Instr( A_loopreadline, Sch )
		fileappend, %A_loopreadline%`n, Out.txt
}
filedelete, test.txt

loop, read, Out.txt ; ������ ���� ����� ������ �� ���� ���ϴ� ���� �߶�.
{
	Ifinstring, A_loopreadline, `<IMG 
		continue
	i := Instr( A_loopreadline, Sch )

	StringMid, LTrimed, A_loopreadline, i+20
	StringTrimRight, LTrimed, LTrimed, 9
	StringReplace, LTrimed, LTrimed, &gt;, `>
	StringReplace, LTrimed, LTrimed, &lt;, `<
	OutLists .= LTrimed . "`|"
}

filedelete, Out.txt
StringTrimRight, OutLists, OutLists, 1

StringReplace, OutLists, OutLists, |&|, &, All
StringSplit, OutList, OutLists , &

Loop, 8 ; ���°� �������� ������ Ȥ�� �� ��츦 ����� '(����)'ó��.
If OutList%A_index% = 
{
	OutList%A_index% = (����)
}
Guicontrol, 4:, PreListBox, �Ϸ�
Guicontrol, 4:, PreProgress, 100
sleep 500
Gui, 4:destroy

; �ڵ�ȭ ���� ���� â ���� (Gui3)------------------------------------------------------------------
Gui, 3:Add, GroupBox, x12 y9 w380 h190 , ���� ����
Gui, 3:Add, Text, x22 y29 w80  , A / 1`,2 ����
Gui, 3:Add, DropDownList, x102 y29 w280 vDrop1, %OutList1%
Gui, 3:Add, Text, x22 y49 w80  , A / 3`,4 ����
Gui, 3:Add, DropDownList, x102 y49 w280 vDrop2, %OutList2%
Gui, 3:Add, Text, x22 y69 w80  , B / 1`,2 ����
Gui, 3:Add, DropDownList, x102 y69 w280 vDrop3, %OutList3%
Gui, 3:Add, Text, x22 y89 w80  , B / 3`,4 ����
Gui, 3:Add, DropDownList, x102 y89 w280 vDrop4, %OutList4%
Gui, 3:Add, Text, x22 y109 w80 , C / 1`,2 ����
Gui, 3:Add, DropDownList, x102 y109 w280 vDrop5, %OutList5%
Gui, 3:Add, Text, x22 y129 w80 , C / 3`,4 ����
Gui, 3:Add, DropDownList, x102 y129 w280 vDrop6, %OutList6%
Gui, 3:Add, Text, x22 y149 w80 , �����Ϲ�
Gui, 3:Add, DropDownList, x102 y149 w280 vDrop7, %OutList7%
Gui, 3:Add, Text, x22 y169 w80 , Ź����
Gui, 3:Add, DropDownList, x102 y169 w280 vDrop8, %OutList8%
Gui, 3:Add, GroupBox, x402 y9 w370 h190 , ���� ��� ����
Gui, 3:Add, Text, x422 y29 w340 h160 , *���������� ������� ���¸� �Է��մϴ�.`n�����ʰų� ���� ���´� '(����)'�Ǵ� �������� �����Ͻʽÿ�.`n`n-�߰�����: �� ���α׷��� ���� ��û ������ Ư�� �����Ǿ�`, ������ ����ġ ���� ������ ����ų �� ����.`n���� ���α� ���·� ä���δ� ���� ���� ����.`n`n�� ���ÿ� �ش��ϴ� ���¸� ������ �� '�ڵ�ȭ �۾� ����' ��ư�� ���� ���.`n`n��`, �ش� ��ư�� �ʹ� ���� ������ ������ ������ Ʈ������ ���� ���ܵ� �� ������`, 8�� 58~59�а濡 ������.
Gui, 3:Add, GroupBox, x12 y209 w380 h150 , �ȳ�����
Gui, 3:Add, Text, x22 y229 w360 h20 , v%PatVersion% _ For H______ AfterSchool
Gui, 3:Add, Text, x22 y259 w360 h20 , %ClassNotice%
Gui, 3:Add, Text, x22 y289 w360 h20 , ��ġ���� / �������� :
Gui, 3:Add, Text, x22 y309 w360 h40 , %PatLog%
Gui, 3:Add, Radio, x412 y260 w360 h30 vWCh gWCh, �� ������ ���̱� - ���� �۵� ��Ȳ�� üũ�մϴ�.`n(������ ������ ���ٸ� ������ �ﰡ�� �ֽʽÿ�.)
Gui, 3:Add, Button, x412 y290 w360 h70 gStarter vSt, �ڵ�ȭ �۾� ����`n`n(����� ��û �ð��� �Ǹ� �ڵ����� ��û�� �����մϴ�.)
Gui,3: Show, h374 w794, �۾� ����â - F8 ������ ���α׷� �����
VCh = 0 ;�������� ���̱� ����Ⱑ �ȵǼ� �ٸ� ����� �����. -> Vch�� ���.

reuse = 1
return

;�ڵ�ȭ �۾� ����-----------------------------------------------------------------------------
Starter:
Gui, 3:submit, nohide
Guicontrol,hide, St
Gui, 3:Add, Text, x412 y290 w360 h70 vAutoDelay, `n`n�ڵ�ȭ �۾� ������Դϴ�.���� ��������� ������� ������`n���� ������ ���ҽ� F8�� ���� ���α׷��� ����� �Ͻʽÿ�.`n�Է��Ͻ� ���� Ű�� �״�� �����˴ϴ�.
/*
var1=1200 ; pm08:00 = 1,200�� 
var2:=var1-(A_Hour*60+A_Min) 
msgbox, % var2//60 "�ð�" mod(var2,60) "�� ���ҽ��ϴ�."
*/

�α׳��� = (��û���) %Drop1%||%Drop2%||%Drop3%||%Drop4%||%Drop5%||%Drop6%||%Drop7%||%Drop8%
�α��̸� = %SecKey%
gosub LogWrite

loop
{
text := COM_Invoke(pwb, "document.documentElement.innerText") 
ifinstring, text, ������
	{
	Guicontrol,, AutoDelay, �ڵ�ȭ �۾��� �����մϴ�.
	break
	}
COM_Invoke( pwb, "Navigate", "<<������û ����Ʈ>>/student/consent.php" )
;COM_Invoke(pwb, "document.all.item[79].click")
gosub pagewait
sleep 150
}


Cnt3 = 0  
Cnt4 = 0
Cnt5 = 0
CntFN = 0 ;CntF ����(Nujuk) -> CntFN
CntCh = 10 ; �� 10�̳ĸ�, A���� ���� ��� ��ũ���� �� 10����. Cnt3�� ��������� ��ũ�� ����ϱ� ������, ó���� 10���� �����ؾ���. + ù ���°� ������ ��� 10 ó���� ���ϸ� B���¼��ý� A���°� ��û�� �� ����.
;Cnt: ȸ���� ��. A���¸� 1 B���¸� 2�� �� / Cnt2: �ش� ��ӹڽ� ����Ʈ�� �� / NCnt: �ش� ��ӹڽ� ����Ʈ �� ���� ���� ���� / Cnt3: �ش� ��ũ�� ���� /

;SetTimer, Check, 200
sleep 50
;SetTimer, Check2, 200
sleep 50
;SetTimer, Check3, 200

Loop,8
{ 
	if % Drop%A_index% <> "(����)"
		{
			if % Drop%A_index% <> ""
			{
				Cnt=%A_index% ; ���� �� ��° DropdownLists���� Ȯ����
				loop, parse, OutList%Cnt%, |
				{
				Cnt2 = %A_index%
				If % Drop%Cnt% = A_loopfield ;���� DropdownLists�� ���° ����Ʈ�� Ŭ���ߴ����� Ȯ���� - Cnt3���� ���� ���ؼ�.
					{
					NCnt = %A_index%
					}
				}
				--NCnt ; '(����)'�׸񶧹��� 1�� ��.
				--Cnt2 ; '(����)'�׸񶧹��� 1�� ��.
				loop, % com_invoke(pwb,"document.links.length") 
				{
					if ( A_index <= CntCh + CntFN)
						continue
					Finding:=com_invoke(pwb,"document.links.item[" a_index-1 "].innertext") 
					IfInString, Finding, % Drop%Cnt%
					{
					com_invoke(pwb,"document.links.item[" a_index-1 "].click")
					Cnt3 = %A_index% ; ��ũ�� ã������, �� ��° ��ũ���� ã�ƺ� - �⺻��(A���� ��) + �ش粨(A���� ����)\
					break 
					}
				}

				CntCh := Cnt3 - NCnt*2 + Cnt2*2 +1
				gosub PageWait
				
				COM_Invoke( pwb, "document.all.form.submit()")
				CntFN = 0
				NowPage := Com_invoke(pwb, "document.url")
				While ( Instr( NowPage, "<<������û ����Ʈ>>/student/_order.php" ) ) ;���� â�� '��û ��ư ������'���� ���� '��û ��� ������'�� �ӹ����ִ��� üũ
				{
				NowPage := Com_invoke(pwb, "document.url")
				}
			}
			else
			{
				loop, parse, OutList%A_index%, |
				{
				CntF := A_index ; DropdownLists�� ����Ʈ ������ ��.
				}
				--CntF
				CntFN += CntF*2
			}
		}
	else
	{
		loop, parse, OutList%A_index%, |
		{
		CntF := A_index ; DropdownLists�� ����Ʈ ������ ��.
		}
		--CntF
		CntFN += CntF*2
	}
	gosub PageWait
}

SetTimer, Check, off
SetTimer, Check2, off
SetTimer, Check3, off


;---------------------
COM_Invoke(pwb, "document.all.item[84].click")
gosub pagewait
loop, % com_invoke(pwb,"document.links.length") 
	{
		if ( A_index < 10)
			continue
		Finding:=com_invoke(pwb,"document.links.item[" a_index-1 "].innertext")
		OutFinding .= Finding . "`|"
	}
StringTrimRight, OutFinding, OutFinding, 17
�α׳��� = (��û���) %OutFinding%
�α��̸� = %SecKey%
gosub LogWrite
;--------------------------

Guicontrol,, AutoDelay, �ڵ�ȭ �۾��� ����Ǿ����ϴ�.

;�α׳��� = Drop1|Drop2|Drop3|Drop4|Drop5|Drop6|Drop7|Drop8
;gosub LogWrite
;COM_Invoke(pwb, "Quit")

return





;�ΰ� ���� �󺧵�---------------------------------------------------------------------
PageWait: ; �� �ε� ���
while, COM_Invoke( pwb, "readyState" ) < 4
		Continue
	while, COM_Invoke( pwb, "readyState" ) <> 4
		Continue
	while, COM_Invoke(pwb, "document.readyState") <> "complete"
		Continue
sleep 150
return

Check: ; �޽����ڽ� �ε� ����� 'Ȯ��'Ŭ��
Check2:
Check3:
IfWinExist, ahk_class #32770
SetControlDelay -1
ControlClick, Button1, ahk_class #32770
return

WCh: ; Guiâ �Ѱų� ����
gui,submit,nohide
If Vch = 0
{
	Vch=1
	gui,1:show
}
else
{
	Vch=0
	gui,1:hide
}
return

LogWrite:
PutName = %�α��̸�%.txt
urldownloadtofile, ftp://<<������>>:<<������>>@<<������>>/Files/AfterSchool/Logs/%�α��̸�%.txt, %�α��̸�%.txt
FileAppend, [%A_YYYY%/%A_MM%/%A_DD%/%A_Hour%:%A_Min%:%A_sec%]`n[�����] : %SecKey% `n[�̸�] : %UserName% `n[�α׳���]`n%�α׳���% `n`n, %�α��̸�%.txt
InetOpen() 
hFTP:=INetConnect(Server, Port, User, Pwd, "ftp")
if(hFTP) 
	{ 
	FtpSetCurrentDirectory(hFTP, "/Files/AfterSchool/Logs") 
	FtpPutFile(hFTP, PutName)
	INetCloseHandle(hFTP) 
	}
filedelete, %�α��̸�%.txt
INetClose()

return

GuiClose:
2GuiClose:
3GuiClose:
msgbox,4,���α׷� ����, ������ ���α׷��� �����Ͻðڽ��ϱ�?
	Ifmsgbox No
		return
	Ifmsgbox yes
		goto ^Q

return:
return

^Q::
Runwait %comspec% /c netsh advfirewall firewall delete rule name=`"%A_ScriptName%`",,hide
SkinForm(0)
regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable,
filedelete, test.txt
filedelete, Out.txt
ExitApp

F8::
if reuse = 1
regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable, ok
Runwait %comspec% /c netsh advfirewall firewall delete rule name=`"%A_ScriptName%`",,hide
reload

/*

F6::
goto Wch