#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <File.au3>

If(Not FileExists(@AppDataDir & "\SimpleVideoEditor")) Then
    DirCreate(@AppDataDir & "\SimpleVideoEditor")
EndIf
$iniFile = @AppDataDir & "\SimpleVideoEditor\SimpleVideoEditor.ini"
$ffmpegBinary = iniRead($iniFile,"general","ffmpeg","C:\Program Files (x86)\ffmpeg\ffmpeg.exe")

Local $hGUI = GUICreate("Simple Video Editor", 600, 500)
$hTab = GUICtrlCreateTab(10, 10, 580, 480)
GUICtrlCreateTabItem("Cut Video")
GUICtrlCreateLabel("Source File",20,40)
Local $iFileName = GUICtrlCreateInput("",20,60,300)
Local $iChooseVideo = GUICtrlCreateButton("Choose File",330,60,100)
Local $iPreview = GUICtrlCreateButton("Preview",440,60,100)
GUICtrlCreateLabel("Start Time",20,90)
Local $iStartTime = GUICtrlCreateInput("00:00",120,90,200)
GUICtrlCreateLabel("Duration",20,120)
Local $iDuration = GUICtrlCreateInput("00:00",120,120,200)
Local $iSaveName = GUICtrlCreateInput("",20,150,300)
Local $iSaveVideo = GUICtrlCreateButton("Pick Output Name",330,150,100)
Local $iPreviewOutput = GUICtrlCreateButton("Preview Output",440,150,100)
Local $iFixRotate = GUICtrlCreateCheckbox("Fix Rotation",20,180)
Local $iCut = GUICtrlCreateButton("Cut Video Segment", 20, 210, 150)

GUICtrlCreateTabItem("Concatenate Video")
GUICtrlCreateLabel("Choose a folder containing video files",20,60)
Local $iDirectory = GUICtrlCreateInput("",20,100,300)
Local $iChooseDirectory = GUICtrlCreateButton("Choose Folder",330,100,100)
Local $iCombinedVideo = GUICtrlCreateInput("",20,130,300)
Local $iChooseCombinedVideo = GUICtrlCreateButton("Choose Output Video File",330,130,200)
Local $iCombinedAudio = GUICtrlCreateInput("",20,160,300)
Local $iChooseCombinedAudio = GUICtrlCreateButton("Choose Output Audio File",330,160,200)

Local $iCombineVideo = GUICtrlCreateButton("Concat Video with Sound",20,190,180)
Local $iCombineVideoNoSound = GUICtrlCreateButton("Concat Video without Sound",210,190,180)
Local $iCombineAudio = GUICtrlCreateButton("Concat Audio",400,190,180)
GUICtrlCreateLabel("NOTE: All video files must be exactly the same dimensions and codec.",20,230)
GUICtrlCreateLabel("(i.e.) produced by the same digital camera or software with identical settings",40,250)

GUICtrlCreateTabItem("Multiplex Audio/Video")
GUICtrlCreateLabel("Video File",20,40)
Local $iMFileName = GUICtrlCreateInput("",20,60,300)
Local $iMChooseVideo = GUICtrlCreateButton("Choose Video File",330,60,100)
GUICtrlCreateLabel("Audio File",20,85)
Local $iMAFileName = GUICtrlCreateInput("",20,100,300)
Local $iMChooseAudio = GUICtrlCreateButton("Choose Audio File",330,100,100)
Local $iMTranscode = GUICtrlCreateCheckbox("Transcode Audio?",20,130)
Local $iMReplace = GUICtrlCreateCheckbox("Replace Existing Audio?",20,160)
Local $iMSaveName = GUICtrlCreateInput("",20,200,300)
Local $iMSaveVideo = GUICtrlCreateButton("Pick Output Name",330,200,100)
Local $iMultiplexAV = GUICtrlCreateButton("Multiplex Audio & Video",20,240,300)

GUICtrlCreateTabItem("Settings")
GUICtrlCreateLabel("This program requires FFMPEG to do the 'real' work.",20,40)
GUICtrlCreateLabel("Please install FFMPEG and specify the location of ffmpeg.exe",20,60)
Local $iFFMPEGInput = GUICtrlCreateInput($ffmpegBinary,80,90,400)
Local $iFFMPEGDownload = GUICtrlCreateButton("Download",120,120,100)
Local $iFFMPEGChoose = GUICtrlCreateButton("Find Location",240,120,100)
Local $iFFMPEGSave = GUICtrlCreateButton("Save Setting",360,120,100)

GUICtrlCreateTabItem("")

GUICtrlSetState($iPreviewOutput, $GUI_DISABLE)
GUISetState(@SW_SHOW, $hGUI)

WarnFFMPEG()

Local $iMsg = 0
While 1
    $iMsg = GUIGetMsg()
    Switch $iMsg
		Case $iChooseVideo
			Local $fName = FileOpenDialog("Choose Source Video",@ScriptDir,"Video Files (*.mp4;*.mov)")
			GuiCtrlSetData($iFileName,$fName)
		Case $iSaveVideo
			Local $fName = FileSaveDialog("Pick Output Filename",@ScriptDir,"Video Files (*.mp4)")
			if(FileExists($fName)) Then
			    GUICtrlSetState($iPreviewOutput, $GUI_ENABLE)
			Else
			    GUICtrlSetState($iPreviewOutput, $GUI_DISABLE)
			EndIf
			GuiCtrlSetData($iSaveName,$fName)
		Case $iPreview
			Local $fName = GUICtrlRead($iFileName)
			ShellExecute($fName)
		Case $iPreviewOutput
			Local $fName = GUICtrlRead($iSaveName)
			ShellExecute($fName)
        Case $iCut
			CutVideo()
		Case $iChooseDirectory
			$dirName = FileSelectFolder("Choose Folder Containing Video Files",@ScriptDir)
			GuiCtrlSetData($iDirectory,$dirName)
		Case $iChooseCombinedVideo
			Local $fName = FileSaveDialog("Choose Output Combined Video",@ScriptDir,"Video Files (*.mp4)")
			GuiCtrlSetData($iCombinedVideo,$fName)
		Case $iChooseCombinedAudio
			Local $fName = FileSaveDialog("Choose Output Combined Audio",@ScriptDir,"MP4 Audio Files (*.m4a)")
			GuiCtrlSetData($iCombinedAudio,$fName)
		Case $iCombineVideo
			CombineVideo(true)
		Case $iCombineVideoNoSound
			CombineVideo(false)
		Case $iCombineAudio
			CombineAudio()
		Case $iMChooseVideo
			Local $fName = FileOpenDialog("Choose Source Video",@ScriptDir,"Video Files (*.mp4;*.mov)")
			GuiCtrlSetData($iMFileName,$fName)
		Case $iMChooseAudio
			Local $fName = FileOpenDialog("Choose Audio",@ScriptDir,"Audio Files (*.m4a;*.wav;*.flac;$.mp3)")
			GuiCtrlSetData($iMAFileName,$fName)
		Case $iMSaveVideo
			Local $fName = FileSaveDialog("Pick Output Filename",@ScriptDir,"Video Files (*.mp4)")
			GuiCtrlSetData($iMSaveName,$fName)
		Case $iMultiplexAV
			MultiplexAV()
		Case $iFFMPEGDownload
			ShellExecute("https://github.com/BtbN/FFmpeg-Builds/releases")
		Case $iFFMPEGChoose
			Local $fName = FileOpenDialog("Locate FFMPEG",@ScriptDir,"FFMPEG (ffmpeg.exe)")
			GuiCtrlSetData($iFFMPEGInput,$fName)
			$ffmpegBinary = $fName
			iniWrite($iniFile,"general","ffmpeg",$ffmpegBinary)
		Case $iFFMPEGSave
			$ffmpegBinary = GUICtrlRead($iFFMPEGInput)
			iniWrite($iniFile,"general","ffmpeg",$ffmpegBinary)
        Case $GUI_EVENT_CLOSE
            ExitLoop

    EndSwitch
WEnd

GUIDelete($hGUI)

Func WarnFFMPEG()
	If(Not FileExists($ffmpegBinary)) Then
		MsgBox(0,"Please Download FFMPEG","In order to use this program, you must install FFMPEG. Go to the settings tab to download and point this program to the correct location for ffmpeg.exe")
	EndIf
EndFunc

Func CutVideo()
	WarnFFMPEG()
	Local $tStart = GUICtrlRead($iStartTime)
	Local $duration = GUICtrlRead($iDuration)
	Local $inputFile = GUICtrlRead($iFileName)
	Local $outputFile = GUICtrlRead($iSaveName)
	Local $flags = ''
	if(FileExists($outputFile)) Then
		Local $ans = MsgBox($MB_YESNO,"Confirm Overwrite","The File '" & $outputFile & "' already exists. Overwrite?")
		If($ans = $IDYES) Then
			FileDelete($outputFile)
		Else
			Return(1)
		EndIf
	EndIf
	$fixRotate = GUICtrlRead($iFixRotate)
	if($fixRotate = 1) Then
		$flags = $flags & ' -metadata:s:v "rotate=0" '
	EndIf
	Local $cmd = '"' & $ffmpegBinary & '" -ss ' & $tStart & ' -i "' & $inputFile & '" -t ' & $duration & ' ' & $flags & ' -c:a copy -c:v copy "' & $outputFile & '"'
	;MsgBox(0,"Command to Run",$cmd)
	RunWait($cmd,@ScriptDir)
	if(FileExists($outputFile)) Then
		GUICtrlSetState($iPreviewOutput, $GUI_ENABLE)
	Else
		GUICtrlSetState($iPreviewOutput, $GUI_DISABLE)
	EndIf
EndFunc

Func CombineVideo($withSound)
	WarnFFMPEG()
	Local $directory = GUICtrlRead($iDirectory)
	Local $outputFile = GUICtrlRead($iCombinedVideo)
	Local $codec = ''
	if($withSound) Then
	    $codec = '-c:a copy -c:v copy'
        FFMPEG_Combine($directory,$outputFile,$codec)
    Else
		$codec = '-c:v copy -an'
		FFMPEG_Combine($directory,$outputFile,$codec)
		; Bad Code
	    ;$sTempDir = $directory & '\' & RandomLetters(10) & '.tmp'
		;DirCreate($sTempDir)
		;$aFiles = _FileListToArray($directory,"*.mp4",$FLTA_FILES)
		;Local $iCount = $aFiles[0]
		;For $i = 1 To $iCount
		;	Local $cmd = '"' & $ffmpegBinary & '" -i "' & $directory & '\' & $aFiles[$i] & '" -c:v copy -an "' & $sTempDir & '\' & $aFiles[$i] & '"'
		;	RunWait($cmd,$directory)
		;Next

        ;FFMPEG_Combine($sTempDir,$outputFile,$codec)
		;For $i = 1 To $iCount
		;	FileDelete($sTempDir & '\' & $aFiles[$i])
		;Next
		;DirRemove($sTempDir)
	EndIf

EndFunc

Func CombineAudio()
	Local $directory = GUICtrlRead($iDirectory)
	Local $outputFile = GUICtrlRead($iCombinedAudio)
	Local $codec = '-c:a copy -vn'
	FFMPEG_Combine($directory,$outputFile,$codec)
EndFunc

Func FFMPEG_Combine($directory,$outputFile,$codec)
	WarnFFMPEG()
	Local $aFiles = _FileListToArray($directory,"*.mp4",$FLTA_FILES)
	If(Not IsArray($aFiles)) Then
		MsgBox(0,"Error","Something went wrong, I can't find any .mp4 files")
		Return 1
	EndIf
	Local $iCount = $aFiles[0]
	_ArrayDelete($aFiles,0)
	_ArraySort($aFiles)
	;_ArrayDisplay($aFiles)
	$sList = ''
	For $i = 0 To ($iCount - 1)
		$sList = $sList & 'file ' & $aFiles[$i] & @CRLF
	Next
	$fname =  "list_" & RandomLetters(8) & ".tmp"
	StringToFile($sList,$directory & "\" & $fname)
	Local $cmd = '"' & $ffmpegBinary & '" -f concat -i "' & $fname & '" ' & $codec & ' "' & $outputFile & '"'

	;ConsoleWriteError($cmd)
	RunWait($cmd,$directory)
	FileDelete($directory & "\" & $fname)
EndFunc

Func MultiplexAV()
	WarnFFMPEG()
	Local $videoFile = GUICtrlRead($iMFileName)
	Local $audioFile = GUICtrlRead($iMAFileName)
	Local $outputFile = GUICtrlRead($iMSaveName)
	$transcode = GUICtrlRead($iMTranscode)
	;MsgBox(0,'DEBUG',$transcode)
	Local $acodec = "-c:a copy"
	if($transcode == 1) Then
		$acodec = "-c:a aac -strict -2 -b:a 240k"
	EndIf
	$replace = GUICTrlRead($iMReplace)
	$cmd = '"' & $ffmpegBinary & '" -i "' & $videoFile & '" -i "' & $audioFile & '" ' & $acodec & ' -c:v copy "' & $outputFile & '"'
	;ConsoleWrite($cmd)
	RunWait($cmd,@ScriptDir)
EndFunc

Func RandomLetters($num)
	Local $letters = ""
	For $i = 1 To $num
		$letters = $letters & Chr(Random(Asc("A"), Asc("Z"), 1))
	Next
	Return $letters
EndFunc

Func StringToFile($sData,$sFilePath)

	Local $hFileOpen = FileOpen($sFilePath, $FO_OVERWRITE)

	;Display a message box in case of any errors.
	If $hFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "An error occurred when opening the file.")
	EndIf
	FileWrite($hFileOpen, $sData)

	FileClose($hFileOpen)
EndFunc
