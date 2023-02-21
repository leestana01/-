#Persistent
#SingleInstance force
#Include ./INet.ahk
SetWorkingDir %A_scriptDir%
DetectHiddenWindows,on
SetTitleMatchMode,slow
SetTitleMatchMode,2

PatVersion = 4.8

server = <<수정됨>>
port = <<수정됨>> 
User = <<수정됨>>
Pwd = <<수정됨>>

;업데이트 내역 : 로그인시 대기 시간 1초로 지정. 그 외 일회용 키 입력 사용자에 대한 소스 일부 변경

;관리자 권한 취득---------------------------------------------------------------------------------------

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

;트레이 아이콘-----------------------------------------------------------------------------------
Menu, tray, NoStandard

Menu, tray, add, Made by_ 이수혁, return
Menu, tray, add, 프로그램 재시작(F8), F8
Menu, tray, add, 프로그램 종료(Ctrl+Q), ^Q

;스킨 입히기------------------------------------------------------------------------------------
SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
		}
}

FileInstall, Skin.zip, %A_Temp%\Skin.zip, 1  ;ZIP 파일

Zip := ComObjCreate("Shell.Application")  ;쉘 오브젝트 생성
Folder := Zip.NameSpace(A_Temp "\Skin.zip")   ; .ZIP 압축파일 지정, 여기서는 임시폴더(A_Temp)\리소스.zip
NewFolder := Zip.NameSpace(A_Temp)                ; 압축을 풀 경로 설정, 여기서는 임시폴더(A_Temp)
NewFolder.CopyHere(Folder.items, 4|16)          ; 압축해제, 임시폴더(A_Temp)에 리소스.zip 압축을 품, 항상 덮어씌움

SkinForm(Apply, A_Temp . "\AfterSchoolManager\USkin.dll", A_Temp . "\AfterSchoolManager\Luminous.msstyles")
SetWorkingDir %Temp%
;프로그램 기본 사항 다운로드--------------------------------------------------------------------------
Runwait %comspec% /c netsh advfirewall firewall delete rule name=`"%A_ScriptName%`",,hide
Runwait %comspec% /c netsh advfirewall firewall add rule name=`"%A_ScriptName%`" dir=in program=`"%A_ScriptFullPath%`" action=allow,,hide


;기존 파일 제거
filedelete, Log.txt
filedelete, Patcher.ini
filedelete, Patcher

urldownloadtofile, ftp://<<수정됨>>:<<수정됨>>@<<수정됨>>/Files/AfterSchool/Patcher.ini, Patcher
if errorlevel
{
	msgbox,,에러 발생,(에러코드:2-1) `n예기치 못한 오류 발생. `n`n다음과 같은 이유가 있을 수 있습니다.`n`n1. 서버가 닫혀있거나, 만료되었습니다. 이 경우 관리자에게 문의하여야 합니다. 서버 복구후 프로그램을 최신버전으로 다운받아야 할 수도 있습니다. `n2.서버 파일이 손상되었습니다. 이 경우 관리자가 파일을 직접 수정하여야합니다. `n`n우선`n다음 주소에서 최신버전을 주기적으로 확인하여 오류 수정본을 체크하십시오.`n방과후자동.oa.to 또는 자동방과후.oa.to `n`n BY LEESH
	goto ^Q
}

;서버 버전 체크
IniRead, Version, Patcher, Version, Ver
if Version > %PatVersion%
	{
	msgbox,,버전 오류,현재 최신 버전이 아닙니다. `n최신 버전을 다운로드하여 주십시오.
	run, <<최신 버전 링크>>
	filedelete, Patcher
	goto ^Q
	}

IniRead, PatLog, Patcher, Notice, PatLog

;레지스트리 로드
RegRead, LoginDis, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable
RegRead, LoginPer, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent

;로그인 창 구현
Gui, 2:Add, GroupBox, x2 y0 w180 h70 , Member Login
	Gui, 2:Add, Text, x12 y19 w40 h20 , ID :
	Gui, 2:Add, Text, x12 y39 w40 h20 , PW :
	Gui, 2:Add, Edit, x52 y19 w120 h20 v아이디, 
	Gui, 2:Add, Edit, x52 y39 w120 h20 password v비번, 
Gui, 2:Add, GroupBox, x2 y79 w180 h70 , 인증키 입력
	Gui, 2:Add, Text, x12 y99 w70 h20 , 현재 상태 :
	Gui, 2:Add, Text, x82 y99 w90 h20 vSecState, 인증 대기중
	Gui, 2:Add, Edit, x12 y119 w160 h20 vSecKey, 
Gui, 2:Add, Text, x187 y0 w180 h90 , [안내사항]`n*ID`,PW는 방과후 계정 대입`n`n*모든 인증키는 일회용입니다.`n`n*이름 입력시 문제 발생시에`n   재빠른 대처가 가능합니다.

Gui, 2:Add, Text, x190 y100 w100 h20 , [본인 이름-선택]
Gui, 2:Add, edit, x290 y95 w70 h20 vUserName, 

Gui, 2:Add, Button, x192 y119 w170 h30 default gPatChk, 로그인
Gui, 2:Show, h159 w375, 방과후 자동 신청 프로그램

If (InStr(LoginPer, "ok"))	;Patcher 파일 제거전 필요한 변수 미리 저장
	{
	RegRead, SecKey, HKLM, SOFTWARE\AutoAfterSchool, Key
	if SecKey = 
	{
		msgbox,,승인되지 않음, 승인되지 않은 프리미엄 유저입니다. 프리미엄 키를 다시 입력해주십시오.`n`n프로그램을 재시작합니다.
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent,
		goto F8
	}
	IniRead, ClassNotice, Patcher, Notice, Pre
	guicontrol,2:, SecState, 인증됨-프리미엄
	guicontrol,2:, Seckey, 인증완료-프리미엄
	}
else
If (InStr(LoginDis, "ok"))	;Patcher 파일 제거전 필요한 변수 미리 저장
	{
	guicontrol,2:, SecState, 인증됨-일회성
	guicontrol,2:, Seckey, 인증완료
	}
else
	IniRead, ClassNotice, Patcher, Notice, Norm

Return

;패치 확인------------------------------------------------------------------------------------------

PatChk:

Gui, 2:hide

Gui 4: -Resize +LastFound -caption
Gui, 4:Add, Text, x12 y9 w270 h20 , 작업을 준비중입니다. 잠시만 기다려 주십시오.
Gui, 4:Add, ListBox, x12 y29 w270 h70 vPreListBox, 유효키 검사중...
Gui, 4:Add, Progress, x12 y99 w270 h20 vPreProgress, 0
Gui, 4:Show, h133 w299, 작업 준비중

;파일을 다시 다운로드 함
filedelete, Patcher
urldownloadtofile, ftp://<<수정됨>>:<<수정됨>>@<<수정됨>>/Files/AfterSchool/Patcher.ini, Patcher
if errorlevel
{
	msgbox,,에러 발생,(에러코드:2-1) `n예기치 못한 오류 발생.
	goto ^Q
}


;강좌 이름을 작성함
IniRead, 강좌이름, Patcher, 강좌이름, 이름
Loop, parse, 강좌이름, |
	강좌명%A_index% = %A_loopfield%

;서버 온 오프 확인
Gui, 2:submit,nohide
IniRead, OnOff, Patcher, Server, ServerChk
if OnOff = On
	goto KeyChk
if OnOff = Off
	{
	msgbox,,서버 연결 오류,(에러코드:1)로그인 서버가 응답하지 않습니다. `n관리자에게 문의하여 주십시오. `n`n프로그램을 종료합니다.
	filedelete, Patcher
	goto ^Q
	}
else
	msgbox,,에러 발생,(에러코드:2) `n예기치 못한 오류 발생.`n`n프로그램을 종료합니다.
	filedelete, Patcher
	goto ^Q
return

KeyChk:
;Dis키를 가진 유저의 경우 로그 작성이 이미 완료 되었기에 이 과정을 뛰어 넘음.
If (InStr(LoginDis, "ok"))
goto Web
;프리미엄 유저의 경우 바로 로그 작성으로 진입
If (InStr(LoginPer, "ok"))
goto LogInput

;사용자 체크
IniRead, UsedKey, Patcher, UsedKey, Key

IniRead, BlackLists, Patcher, BlackLists, Key
Loop, parse, BlackLists, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,에러 발생,(에러코드:6) `n%Banned%`n자세한 것은 관리자에게 문의하시기 바랍니다.
		filedelete, Patcher
		goto F8
		}
}


Loop, parse, UsedKey, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,에러 발생,(에러코드:3) `n이미 사용된 인증코드입니다.
		filedelete, Patcher
		goto F8
		}
}

IniRead, PerKey, Patcher, PerKey, Key ;프리미엄 키 확인
Loop, parse, PerKey, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,인증완료,인증되었습니다.`n`n인증 형식 : 프리미엄 유저
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, permanent, ok
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool, Key, %Seckey%
		goto Keyinput
		}
}

IniRead, DisKey, Patcher, DisKey, Key ;일회용 키 확인
Loop, parse, DisKey, |
{
	If A_loopfield = %Seckey%
		{
		msgbox,,인증완료,인증되었습니다.`n`n인증 형식 : 일회성 계정`n(프로그램 종료시 인증코드 신규발급이 필요합니다)
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable, ok
		regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool, Key, %Seckey%
		goto Keyinput
		}
}

msgbox,,인증번호가 확인되지 않음,존재하지 않는 인증번호입니다. 다시 확인하여 주십시오.
goto F8
return

;사용된 키는 따로 보관함.
Keyinput:
IniRead, Usedkey, Patcher, Usedkey, Key
iniwrite, %UsedKey%|%SecKey%, Patcher, UsedKey, Key

;로그를 작성함
LogInput:

urldownloadtofile, ftp://<<수정됨>>:<<수정됨>>@<<수정됨>>/Files/AfterSchool/Log.txt, Log.txt
FileAppend, [%A_YYYY%/%A_MM%/%A_DD%/%A_Hour%:%A_Min%:%A_sec%]`n 인증코드 : %SecKey% | 이름 : %UserName% `n, Log.txt
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
			msgbox,,에러 발생,(에러코드:4 - Log) `n서버와의 연결에 문제가 발생하였습니다. - Log
			filedelete, Log.txt
			filedelete, Patcher.ini
			goto ^Q
		}
	FtpPutFile(hFTP, "Patcher.ini")
		if errorlevel
		{
			msgbox,,에러 발생,(에러코드:4 - Pat) `n서버와의 연결에 문제가 발생하였습니다. - Pat
			filedelete, Log.txt
			filedelete, Patcher.ini
			goto ^Q
		}
	INetCloseHandle(hFTP) 
	}
else
	{
		msgbox,, 에러 발생,(에러코드:5) `n서버와의 연결에 문제가 발생하였습니다.
		filedelete, Log.txt
		filedelete, Patcher.ini
		goto ^Q
	}

filedelete, Log.txt
filedelete, Patcher.ini
INetClose() 
;자동 로그인 실행---------------------------------------------------------------------------------
Web:
Guicontrol, 4:, PreListBox, 사이트에 로그인중입니다...
Guicontrol, 4:, PreProgress, 25

Gui, 2:submit, nohide
Gui, 2:destroy

RegRead, SecKey, HKLM, SOFTWARE\AutoAfterSchool, Key ;후에 로그 작성을 위해 미리 지금 키값을 받아둠.

Gui 1: -Resize +LastFound -caption
Gui, 1:Show, hide x0 y0 w916 h902, 현재 상황 표시창(내려놓아도 됩니다.)
COM_AtlAxWinInit()
COM_CoInitialize()
COM_Error(0)
web:="<<수강신청 사이트>>/regi/login.php"
pwb := COM_AtlAxGetControl(COM_AtlAxCreateContainer(WinExist(), 0, 0, 1280, 970, "Shell.Explorer"))
COM_Invoke( pwb, "Visible", True )
COM_Invoke( pwb, "Navigate", web )
;while, COM_Invoke( pwb, "readyState" ) <> "4"
;	Continue
gosub pagewait
ControlFocus, ,% "ahk_id " . COM_AtlAxGetContainer(pwb)

COM_Invoke( pwb, "document.all.id.value", 아이디 )
COM_Invoke( pwb, "document.all.pw.value", 비번)


로그인소스 := COM_Invoke( pwb, "document.documentElement.InnerHTML") ; 인터넷 소스 복사
;clipboard := 로그인소스
pos = 1
While pos := RegExMatch(로그인소스, "#ff0000.{11}(.)", SecCode, pos+StrLen(SecCode)) ; 소스에 정규식을 적용후 SecCode라는 변수에 넣움
보안코드 .= SecCode1 ; SecCode는 찾은 줄을 모두 표시 / SecCode라 하면 ()로 묶어준 그룹 중에 1번 내용만 표시
COM_Invoke( pwb, "document.all.spamcode.value", 보안코드)
COM_Invoke( pwb, "document.all.form.submit()")
로그인소스 = "" ; 로그인소스 변수 제거
;현재 인터넷 주소를 확인하여 로그인이 정상적으로 되었는지를 확인함.--------------------------------------------
While, Com_invoke(pwb, "document.url") = "<<수강신청 사이트>>/regi/login.php"
	Continue
sleep 1000
If (Com_invoke(pwb, "document.url") <> "<<수강신청 사이트>>/student/agree.php")
{
regwrite, REG_SZ, HKLM, SOFTWARE\AutoAfterSchool\Passkey, disposable, ok
msgbox,,로그인 실패,아이디 혹은 비밀번호가 잘못되었거나`, 인터넷 속도가 너무 느립니다.
goto F8
}
Guicontrol, 4:, PreListBox, 페이지 이동 준비중...
Guicontrol, 4:, PreProgress, 50

;방과후 동의서 제출-----------------------------------------------------------------------------
COM_Invoke(pwb, "document.all.item[27].click")
COM_Invoke(pwb, "document.all.item[41].click")
COM_Invoke(pwb, "document.all.item[48].click")

Guicontrol, 4:, PreListBox, 강좌 목록을 불러오는중...
Guicontrol, 4:, PreProgress, 75

gosub pagewait

;수강 신청 페이지 접속----------------------------------------------------------------------------
COM_Invoke( pwb, "Navigate", "<<수강신청 사이트>>/student/consent.php" )

gosub pagewait
;수강 신청 목록 읽어들임-------------------------------------------------------------------------
목록소스 := COM_Invoke( pwb, "document.documentElement.InnerHTML")

Sch=returl=consent.php`"`>
fileappend, % 목록소스, test.txt
목록소스 = "" ; 목록소스 변수 제거
loop, read, test.txt ;목록을 읽어들여서 각 강좌 바로 앞에 해당 강좌를 구분지어줄 말을 넣음. 여기서는 '(없음)'
{
	if ALists <> 1
		if Instr( A_loopreadline, 강좌명1)
		{
			fileappend, returl=consent.php">(없음)aaaaaaaaa`n, Out.txt
			ALists = 1
		}
	if BLists <> 1
		if Instr( A_loopreadline, 강좌명2)
		{
			fileappend, returl=consent.php">&|(없음)aaaaaaaaa`n, Out.txt
			BLists = 1
		}
	if CLists <> 1
		if Instr( A_loopreadline, 강좌명3)
		{
			fileappend, returl=consent.php">&|(없음)aaaaaaaaa`n, Out.txt
			
			CLists = 1
		}
	if DLists <> 1
		if Instr( A_loopreadline, 강좌명4)
		{
			fileappend, returl=consent.php">&|(없음)aaaaaaaaa`n, Out.txt
			
			DLists = 1
		}
	if ELists <> 1
		if Instr( A_loopreadline, 강좌명5)
		{
			fileappend, returl=consent.php">&|(없음)aaaaaaaaa`n, Out.txt
			ELists = 1
		}
	if FLists <> 1
		if Instr( A_loopreadline, 강좌명6)
		{
			fileappend, returl=consent.php">&|(없음)aaaaaaaaa`n, Out.txt
			FLists = 1

		}
	if GLists <> 1
		if Instr( A_loopreadline, 강좌명7)
		{
			fileappend, returl=consent.php">&|(없음)aaaaaaaaa`n, Out.txt
			GLists = 1
		}
	if HLists <> 1
		if Instr( A_loopreadline, 강좌명8)
		{
			fileappend, returl=consent.php">&|(없음)aaaaaaaaa`n, Out.txt
			HLists = 1
		}
	if Instr( A_loopreadline, Sch )
		fileappend, %A_loopreadline%`n, Out.txt
}
filedelete, test.txt

loop, read, Out.txt ; 위에서 만든 목록을 가지고 각 행을 원하는 말만 잘라냄.
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

Loop, 8 ; 강좌가 존재하지 않을시 혹시 모를 경우를 대비해 '(없음)'처리.
If OutList%A_index% = 
{
	OutList%A_index% = (없음)
}
Guicontrol, 4:, PreListBox, 완료
Guicontrol, 4:, PreProgress, 100
sleep 500
Gui, 4:destroy

; 자동화 강좌 선택 창 구현 (Gui3)------------------------------------------------------------------
Gui, 3:Add, GroupBox, x12 y9 w380 h190 , 강좌 선택
Gui, 3:Add, Text, x22 y29 w80  , A / 1`,2 교시
Gui, 3:Add, DropDownList, x102 y29 w280 vDrop1, %OutList1%
Gui, 3:Add, Text, x22 y49 w80  , A / 3`,4 교시
Gui, 3:Add, DropDownList, x102 y49 w280 vDrop2, %OutList2%
Gui, 3:Add, Text, x22 y69 w80  , B / 1`,2 교시
Gui, 3:Add, DropDownList, x102 y69 w280 vDrop3, %OutList3%
Gui, 3:Add, Text, x22 y89 w80  , B / 3`,4 교시
Gui, 3:Add, DropDownList, x102 y89 w280 vDrop4, %OutList4%
Gui, 3:Add, Text, x22 y109 w80 , C / 1`,2 교시
Gui, 3:Add, DropDownList, x102 y109 w280 vDrop5, %OutList5%
Gui, 3:Add, Text, x22 y129 w80 , C / 3`,4 교시
Gui, 3:Add, DropDownList, x102 y129 w280 vDrop6, %OutList6%
Gui, 3:Add, Text, x22 y149 w80 , 배드민턴반
Gui, 3:Add, DropDownList, x102 y149 w280 vDrop7, %OutList7%
Gui, 3:Add, Text, x22 y169 w80 , 탁구반
Gui, 3:Add, DropDownList, x102 y169 w280 vDrop8, %OutList8%
Gui, 3:Add, GroupBox, x402 y9 w370 h190 , 실행 방법 설명
Gui, 3:Add, Text, x422 y29 w340 h160 , *위에서부터 순서대로 강좌를 입력합니다.`n듣지않거나 없는 강좌는 '(없음)'또는 공백으로 설정하십시오.`n`n-추가사항: 이 프로그램은 방학 신청 용으로 특수 개조되어`, 공강은 예상치 못한 에러를 일으킬 수 있음.`n따라서 비인기 강좌로 채워두는 것이 좋을 듯함.`n`n각 교시에 해당하는 강좌를 선택한 뒤 '자동화 작업 시작' 버튼을 눌러 대기.`n`n단`, 해당 버튼을 너무 일찍 누르면 서버에 과도한 트래픽을 보내 차단될 수 있으니`, 8시 58~59분경에 누를것.
Gui, 3:Add, GroupBox, x12 y209 w380 h150 , 안내사항
Gui, 3:Add, Text, x22 y229 w360 h20 , v%PatVersion% _ For H______ AfterSchool
Gui, 3:Add, Text, x22 y259 w360 h20 , %ClassNotice%
Gui, 3:Add, Text, x22 y289 w360 h20 , 패치내역 / 공지사항 :
Gui, 3:Add, Text, x22 y309 w360 h40 , %PatLog%
Gui, 3:Add, Radio, x412 y260 w360 h30 vWCh gWCh, 웹 페이지 보이기 - 현재 작동 상황을 체크합니다.`n(페이지 내에서 별다른 조작은 삼가해 주십시오.)
Gui, 3:Add, Button, x412 y290 w360 h70 gStarter vSt, 자동화 작업 시작`n`n(방과후 신청 시간이 되면 자동으로 신청을 시작합니다.)
Gui,3: Show, h374 w794, 작업 세팅창 - F8 누를시 프로그램 재시작
VCh = 0 ;웹페이지 보이기 숨기기가 안되서 다른 방법을 사용함. -> Vch를 사용.

reuse = 1
return

;자동화 작업 시작-----------------------------------------------------------------------------
Starter:
Gui, 3:submit, nohide
Guicontrol,hide, St
Gui, 3:Add, Text, x412 y290 w360 h70 vAutoDelay, `n`n자동화 작업 대기중입니다.이후 변경사항은 적용되지 않으며`n만약 변경을 원할시 F8을 눌러 프로그램을 재시작 하십시오.`n입력하신 인증 키는 그대로 유지됩니다.
/*
var1=1200 ; pm08:00 = 1,200분 
var2:=var1-(A_Hour*60+A_Min) 
msgbox, % var2//60 "시간" mod(var2,60) "분 남았습니다."
*/

로그내용 = (신청요망) %Drop1%||%Drop2%||%Drop3%||%Drop4%||%Drop5%||%Drop6%||%Drop7%||%Drop8%
로그이름 = %SecKey%
gosub LogWrite

loop
{
text := COM_Invoke(pwb, "document.documentElement.innerText") 
ifinstring, text, 접수중
	{
	Guicontrol,, AutoDelay, 자동화 작업을 시작합니다.
	break
	}
COM_Invoke( pwb, "Navigate", "<<수강신청 사이트>>/student/consent.php" )
;COM_Invoke(pwb, "document.all.item[79].click")
gosub pagewait
sleep 150
}


Cnt3 = 0  
Cnt4 = 0
Cnt5 = 0
CntFN = 0 ;CntF 누적(Nujuk) -> CntFN
CntCh = 10 ; 왜 10이냐면, A강좌 전의 모든 링크들이 총 10개임. Cnt3는 현재까지의 링크를 계산하기 때문에, 처음에 10개로 시작해야함. + 첫 강좌가 공강일 경우 10 처리를 안하면 B강좌선택시 A강좌가 신청될 수 있음.
;Cnt: 회돌이 수. A강좌면 1 B강좌면 2가 됨 / Cnt2: 해당 드롭박스 리스트의 수 / NCnt: 해당 드롭박스 리스트 중 현재 선택 순번 / Cnt3: 해당 링크의 순번 /

;SetTimer, Check, 200
sleep 50
;SetTimer, Check2, 200
sleep 50
;SetTimer, Check3, 200

Loop,8
{ 
	if % Drop%A_index% <> "(없음)"
		{
			if % Drop%A_index% <> ""
			{
				Cnt=%A_index% ; 현재 몇 번째 DropdownLists인지 확인함
				loop, parse, OutList%Cnt%, |
				{
				Cnt2 = %A_index%
				If % Drop%Cnt% = A_loopfield ;현재 DropdownLists중 몇번째 리스트를 클릭했는지를 확인함 - Cnt3에서 빼기 위해서.
					{
					NCnt = %A_index%
					}
				}
				--NCnt ; '(없음)'항목때문에 1을 뺌.
				--Cnt2 ; '(없음)'항목때문에 1을 뺌.
				loop, % com_invoke(pwb,"document.links.length") 
				{
					if ( A_index <= CntCh + CntFN)
						continue
					Finding:=com_invoke(pwb,"document.links.item[" a_index-1 "].innertext") 
					IfInString, Finding, % Drop%Cnt%
					{
					com_invoke(pwb,"document.links.item[" a_index-1 "].click")
					Cnt3 = %A_index% ; 링크를 찾았으면, 몇 번째 링크인지 찾아봄 - 기본꺼(A강좌 전) + 해당꺼(A강좌 이후)\
					break 
					}
				}

				CntCh := Cnt3 - NCnt*2 + Cnt2*2 +1
				gosub PageWait
				
				COM_Invoke( pwb, "document.all.form.submit()")
				CntFN = 0
				NowPage := Com_invoke(pwb, "document.url")
				While ( Instr( NowPage, "<<수강신청 사이트>>/student/_order.php" ) ) ;현재 창이 '신청 버튼 페이지'에서 나와 '신청 목록 페이지'에 머물러있는지 체크
				{
				NowPage := Com_invoke(pwb, "document.url")
				}
			}
			else
			{
				loop, parse, OutList%A_index%, |
				{
				CntF := A_index ; DropdownLists의 리스트 개수를 셈.
				}
				--CntF
				CntFN += CntF*2
			}
		}
	else
	{
		loop, parse, OutList%A_index%, |
		{
		CntF := A_index ; DropdownLists의 리스트 개수를 셈.
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
로그내용 = (신청결과) %OutFinding%
로그이름 = %SecKey%
gosub LogWrite
;--------------------------

Guicontrol,, AutoDelay, 자동화 작업이 종료되었습니다.

;로그내용 = Drop1|Drop2|Drop3|Drop4|Drop5|Drop6|Drop7|Drop8
;gosub LogWrite
;COM_Invoke(pwb, "Quit")

return





;부가 서브 라벨들---------------------------------------------------------------------
PageWait: ; 웹 로딩 대기
while, COM_Invoke( pwb, "readyState" ) < 4
		Continue
	while, COM_Invoke( pwb, "readyState" ) <> 4
		Continue
	while, COM_Invoke(pwb, "document.readyState") <> "complete"
		Continue
sleep 150
return

Check: ; 메시지박스 로드 대기후 '확인'클릭
Check2:
Check3:
IfWinExist, ahk_class #32770
SetControlDelay -1
ControlClick, Button1, ahk_class #32770
return

WCh: ; Gui창 켜거나 끄기
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
PutName = %로그이름%.txt
urldownloadtofile, ftp://<<수정됨>>:<<수정됨>>@<<수정됨>>/Files/AfterSchool/Logs/%로그이름%.txt, %로그이름%.txt
FileAppend, [%A_YYYY%/%A_MM%/%A_DD%/%A_Hour%:%A_Min%:%A_sec%]`n[사용자] : %SecKey% `n[이름] : %UserName% `n[로그내용]`n%로그내용% `n`n, %로그이름%.txt
InetOpen() 
hFTP:=INetConnect(Server, Port, User, Pwd, "ftp")
if(hFTP) 
	{ 
	FtpSetCurrentDirectory(hFTP, "/Files/AfterSchool/Logs") 
	FtpPutFile(hFTP, PutName)
	INetCloseHandle(hFTP) 
	}
filedelete, %로그이름%.txt
INetClose()

return

GuiClose:
2GuiClose:
3GuiClose:
msgbox,4,프로그램 종료, 정말로 프로그램을 종료하시겠습니까?
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