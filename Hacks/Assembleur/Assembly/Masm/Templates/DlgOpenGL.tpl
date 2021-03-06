Win32 App
DlgOpenGL
OpenGL in a box
-
Pegasus, 2oo4
e-mail: pegasus@anticrack.de
web: http://www.anticrack.de
[*BEGINPRO*]
[*BEGINTXT*]
DlgOpenGL.asm

include DlgOpenGL.inc                                    ; needed header

.code
start:                                                   ; entry point
  invoke  GetModuleHandle,NULL                           ; get a module handle
  mov     hInstance,eax                                  ; and store it
  invoke  InitCommonControls                             ; init treeview usage
  invoke  DialogBoxParam,hInstance,IDD_DIALOG,NULL,offset DlgProc,NULL
  invoke  ExitProcess,NULL                               ; cleanup and kill process
DlgProc      proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
  .if     uMsg==WM_INITDIALOG                            ; WM_INITDIALOG
    invoke  ShowWindow,hWin,SW_MINIMIZE                  ; pop up effect
    invoke  LoadIcon,hInstance,IDI_ICON                  ; set application icon
    mov     hIcon,eax                                    ; and store it's handle
    invoke  SendMessage,hWin,WM_SETICON,1,hIcon          ; show the icon
    invoke  SendMessage,hWin,WM_SETTEXT,0,offset szAppName ; show application name
    invoke  ShowWindow,hWin,SW_SHOWNORMAL                ; show the final dialog 
    invoke  myOGL_InitGL,hWin
    invoke  SetTimer,hWin,1,10,NULL                      ; setup a timer

  .elseif uMsg==WM_TIMER                                 ; WM_TIMER
    invoke  myOGL_DrawScene                              ; redraw openGL scene

  .elseif uMsg==WM_CLOSE                                 ; WM_CLOSE
    invoke  ShowWindow,hWin,SW_MINIMIZE                  ; minimize the window to taskbar
    invoke  KillTimer,hWin,1                             ; delete timer
    invoke  myOGL_KillGL                                 ; delete openGL crap
    invoke  ReleaseDC,hWin,hDC                           ; release device context
    invoke  EndDialog,hWin,0                             ; end the dialog

  .elseif uMsg==WM_COMMAND                               ; WM_COMMAND
    nop                                                  ; do nothing

  .else
    mov     eax,FALSE                                    ; delete unhandeled message
    ret                                                  ; and continue
  .endif
  mov    eax,TRUE                                        ; message handled with success
  ret                                                    ; and continue
DlgProc      endp			

myOGL_InitGL proc theWindowHandle:DWORD
  LOCAL    pfd:PIXELFORMATDESCRIPTOR                     ; ...
  LOCAL    PixelFormat:DWORD                             ; correct pixelformat for static window
  pushad                                                 ; store all registers
  mov     pfd.nSize,sizeof PIXELFORMATDESCRIPTOR         ; setup pixelformatdescriptor struct
  mov     pfd.nVersion,1
  mov     pfd.dwFlags, PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER
  mov     pfd.iPixelType, PFD_TYPE_RGBA
  mov     pfd.cColorBits, 16
  mov     pfd.cDepthBits, 16
  mov     pfd.dwLayerMask, PFD_MAIN_PLANE
  invoke  GetDlgItem,theWindowHandle,IDI_OPENGL          ; the static item which shows openGL
  mov     hOGLWindow,eax                                 ; store it's handle
  invoke  GetDC,hOGLWindow                               ; get the device context
  mov     hDC,eax                                        ; and store it
  invoke  GetClientRect,hOGLWindow,addr staticRect       ; we need the dimensions of the static
  invoke  ChoosePixelFormat, hDC, ADDR pfd               ; and the correct pixelformat
  mov     PixelFormat,eax                                ; thats the correct one
  invoke  SetPixelFormat, hDC, PixelFormat, ADDR pfd     ; so set it!
  invoke  wglCreateContext, hDC                          ; create rendering context
  mov     hRC, eax                                       ; store the handle
  invoke  wglMakeCurrent, hDC, hRC                       ; it's our OpenGL context
  invoke  glViewport, 0, 0, staticRect.right, staticRect.bottom  ;reset viewport
  invoke  glMatrixMode, GL_PROJECTION                    ; select projection matrix
  invoke  glLoadIdentity                                 ; reset it
  push    40590000h                                      ; 100.0f
  push    0                                              ; double
  push    3FB99999h                                      ; 0.1f
  push    9999999Ah                                      ; double
  fild    staticRect.right
  fidiv   staticRect.bottom                              ; dividing width by height and
  sub     esp,8                                          ; pushing it on the
  fstp    qword ptr [esp]                                ; stack as a double
  push    40468000h                                      ; 45.0f
  push    0                                              ; double
  call    gluPerspective
  invoke  glMatrixMode, GL_MODELVIEW                     ; select modelview matrix
  invoke  glLoadIdentity                                 ; reset it
  invoke  glShadeModel,GL_SMOOTH                         ; Enable Smooth Shading
  invoke  glClearColor,0,0,0,0                           ; Black Background
  invoke  glClearDepth,0,3FF00000h                       ; Depth Buffer Setup
  invoke  glEnable,GL_DEPTH_TEST                         ; Enables Depth Testing
  invoke  glDepthFunc,GL_LEQUAL                          ; The Type Of Depth Testing To Do
  invoke  glHint,GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST; Really Nice Perspective Calculations
  popad                                                  ; retore all registers
  ret                                                    ; return to caller
myOGL_InitGL endp

myOGL_DrawScene proc
  pushad                                                 ; store all registers
  invoke  glClear,GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT ; Clear Screen And Depth Buffer
  invoke  glLoadIdentity                                 ; Reset The Current Modelview Matrix

  invoke  SwapBuffers, hDC                               ; show the result
  popad                                                  ; restore all registers
  ret                                                    ; return to caller
myOGL_DrawScene endp

myOGL_KillGL proc
  pushad
  invoke  wglMakeCurrent,NULL,NULL
  invoke  wglDeleteContext,hRC
  popad
  ret
myOGL_KillGL endp
end start                                                ; end of application
[*ENDTXT*]
[*BEGINTXT*]
DlgOpenGL.inc

.386                                                     ; minimum processor
.model flat,stdcall                                      ; win32 application
option casemap:none                                      ; case sensitive

include windows.inc                                      ; win32 structures etc.

incboth macro incl                                       ; macro for lazy coders
  include    incl.inc
  includelib incl.lib
endm

incboth kernel32                                         ; functions from kernel32
incboth user32                                           ; functions from user32
incboth comctl32                                         ; functions from comctl32
incboth gdi32                                            ; functions from gdi32
incboth opengl32                                         ; functions from opengl32
incboth glu32                                            ; functions from glu32


; ** function prototypes
DlgProc           PROTO :HWND,:UINT,:WPARAM,:LPARAM      ; main dialog procedure
myOGL_InitGL      PROTO :DWORD                           ; setup openGL
myOGL_DrawScene   PROTO                                  ; update the openGL scene
myOGL_KillGL      PROTO                                  ; cleanup openGL


; ** uninitialized data
.data?
hInstance            HINSTANCE  ?                        ; application instance
hIcon                HICON      ?                        ; application icon 
hDC                  dd         ?                        ; device context
hRC                  dd         ?                        ; openGL rendering context
hOGLWindow           HWND       ?                        ; openGL window handle
staticRect           RECT       <?>                      ; dimensions of static openGL "window"


; ** initialized data
.data
szAppName            db "OpenGL in a Box - by Pegasus",0 ; dialog caption


; ** constants
.const
IDI_ICON             equ 100                             ; application icon
IDD_DIALOG           equ 1000                            ; dialog resource
IDI_OPENGL           equ 1001                            ; openGL static area
[*ENDTXT*]
[*BEGINTXT*]
DlgOpenGL.rc
#include "Res/mainDlg.rc"
#include "Res/mainIcon.rc"
[*ENDTXT*]
[*BEGINBIN*]
res\main.dlg
6500000001000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
00000000000000004D532053616E732053657269660000000000000000000000
000000000000000008000000F5FFFFFF00000000E90300000000000000000000
0000000000000000BC090A80000000006A040300010000004397410068040900
000000000008CA10000000000A0000000A00000075010000000100004944445F
444C470000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000E8030000494444
5F4449414C4F4700000000000000000000000000000000000000000000000000
00000000006C040300000000009F62E1776A0403000000000000000050000000
0012000000120000004E010000C10000004F70656E474C000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000020000000200000000000000E90300004944495F4F50454E474C00000000
0000000000000000000000000000000000000000000000000000
[*ENDBIN*]
[*ENDPRO*]
[*BEGINTXT*]
res\maindlg.rc
#define IDD_DIALOG 1000
#define IDI_OPENGL 1001
IDD_DIALOG DIALOGEX 6,6,244,142
CAPTION "IDD_DLG"
FONT 8,"MS Sans Serif"
STYLE 0x10CA0800
EXSTYLE 0x00000000
BEGIN
  CONTROL "OpenGL",IDI_OPENGL,"Static",0x50000000,12,11,222,118,0x00000000
END
[*ENDTXT*]
[*BEGINTXT*]
res\mainicon.rc
#define IDI_ICON     100
IDI_ICON             ICON     DISCARDABLE "Res/mainIcon.ico"
[*ENDTXT*]
[*BEGINBIN*]
res\mainicon.ico
0000010001003030000000000000A80E00001600000028000000300000006000
00000100080000000000800A000000000000000000000000000000000000FFFF
FF0010101000181818002929290039393900424242007373730094949400B5B5
B500CECECE00C6C6CE00CECED600A5A5AD00ADADB50094949C0084848C006B6B
7300B5B5C600BDBDCE0052525A00A5A5B5009494A500B5B5CE0073738400A5A5
BD0039394200636373009C9CB500C6C6E700525263007B7B94004A4A5A007373
8C009494B500B5B5DE006B6B8400212129004242520063637B00C6C6F7005A5A
73009494BD006B6B8C009C9CCE008C8CBD0018182100292939009494CE005252
73007B7BAD0063638C008484BD00393952006B6B9C0021213100101018003131
4A005252840052528C00424273006B6BBD0029294A006363C600313163001818
310042429C0031317B00101039002929BD000000080000001800000039000000
52000000630000007B000000840000009C000000AD000000BD001018BD000008
CE00424ACE003942CE0018219C007B84DE00525AAD005A63C60031398C002129
8C002131CE000010AD00737BBD00525A9C005A63B50000109C00ADB5EF009CA5
E700525A8C00424A84004252BD00212963003142AD003142BD0021319C001831
DE0000107B0000108400C6CEF700ADB5DE00BDC6F7008C94BD009CA5D600525A
8400394273004252A500182152002942D6002139B5002139C6000821B5000021
E7009CA5CE008C9CE7007384CE003952CE002142D6001831AD0008219C00ADB5
D600949CBD00848CAD00737B9C004A52730029315200314AAD00BDC6E7007B84
A5005A6384008C9CD600394A84002939730021398C00081852000839DE00C6CE
E700949CB5008C94AD007B8CBD00313952005A6B9C004A5A8C001039B5000821
6B007B849C00C6D6FF00ADBDE700A5B5DE008C9CC6004A5A84001042C6000839
C600BDCEF7009CB5EF00394A7300CEDEFF004A5A7B00184AB500A5ADBD00848C
9C004A6394001852C60000297B00182131004A638C00739CDE00314A7300395A
8C00102952000052CE00D6E7FF009CADC600C6DEFF0010213900103973000831
6B00B5CEEF0000398400D6DEE70029425A007B848C0029425200C6CECE004A52
52003139390018393900C6CEC600A5ADA5007B847B009CAD9C0094A594001821
1000B5B5AD00948494006339730063526B0029084200C6BDCE00635A6B002918
390063398C001008180031006300D6C6E7005A318C0063527B004A297B004208
940031007B004A3173007B63A500292139008463C6002918520031108400635A
7B003910A500524A6B00393152006352940063529C006B52BD00392973001808
520018006B00736B94006B638C003129520029214A0042318400312173001800
7B002100AD00635A8C005A4AAD0018009C00736BA5006B63A500524A84003121
A5004A428C0021186B00211884005A52C60021189C002118C600000000004545
454546454546024784B035452D3FC1464545454545454545450319454545458E
3A9495A71625110DB4BFB412BBBF2E454550774846438E45454545DC43454545
454545454545453F71885FA1B945454545ACA7809112011BA80EBF030BBB0245
4576454502784383FCF9A8012E05254545454501731A9116E313809A9A9A4545
45454511A71DA7840F1ABF03BBBB2401454663A045FB605F9B252E212434DC28
45457180794534A8A787A4A4A4A49A4547E92818B912CFA78412160C0CBB3602
4545023D6C27B9A26D813801DB362A0130A880028727A1A49AA4A4B3A4A4A445
45454580A7120E4512031605BBBB2D724545331C5F5F275F921F01454545C187
22B91987A49A9AA4A4A427B3A4A4A42E454547431612120F01171145BBBB4545
2DA5809B6D871C6D892E2D2D452D6C6D6D6D6DA19AA49AA4A4A4A4B327B3A494
45454545291616120E03CE1311BB45452D126C275F1C6D223601362D345F6DB9
B9A1A1B96BA12387A4A4A4A427B3A41D454545454516C3BF150C13CEBF1D4524
3623226D2780876D0219452B9BB96DB9B9B980B90287912DA41CA4A4B3A1A4B9
45454545453ABFBF160A02CE0B01C1692D2E9B82875F875FDC352B6D6DB9A187
A12EB9A426A4A4832D9CC11928A7EAA1454545464545CE16BF1AC6090F0E4547
8401990519B922906D8722166D8787A102B3256CA4A49AA49A3003196DB5B387
454545454545470A120216CE020B454547361D809B9C87226B1C228712226C23
80B3A4A4A4A4A49A9A2899799BA1A4A4454545454545450D130A0A1A10BB4545
4502A80119228787909087128787189C2AB39AA4A49AA46B6EC28129839AA4B5
33454545454545CA02CE090509BB45B18E453691A78722876D90878787168034
80A4A4A4A4A42E819CA12C25252888919A4545454545452D08CE0913BBBB4545
45454502241090B9B9876C8787922523876CB5A4A4A4A4A49A9AB5A49A9A6DB3
A44745454545454514C3CE0BBB0B45B16A4545454501878787B98722122B26B4
9A9A02C19192809CA490812081B9A191B31045454745454780120A09BFBB4545
4545454545451A876DB987872203199027A4A1A49283239CA49AA4B5B5A4A491
A46D45454545452E0CBFD40AD4BF3602B845458E4545256C8787B98787926C9A
A4A49AA4A4A48783231F3D1F1F451EB3A4A40245454545EDC9C31C120A0B4545
4546454545023B326C6C6D802383A49A9AA4A4A4A4A4A4A427809AA4B3A4A4B3
B3272A454545454608C3871C0BB92E45454645454545D03892221F79286CB3A4
B3A4A4A49AA4A4A4A4A4321FA4B3A418D4B3B3454545484531120B22D4CE0245
454545C22D2ECCE2EA9281E22002A49AA4A49AA49AA4A4A4A4A434B4B3B3B36B
B3B3B34545454545E9801209D409454645E9454545198291792A9928C15BA49A
9AA4A42AA4A49A9AA4023328847126B3A4B3B32A454545454545A7BFD4D402BC
45B2454045DCEB31A82B716E382CA4A4A49AA4837BA4A49AA1039425012E45B3
A4B3828345454546984545BF900B45454550454502242D4545DB92E3799CA4A4
A4A49A191F1FB3A483032445E3D4A445B3B39A6DE3454545694D454512BF0102
2D784545452E6245D7452D3883A49AA49A9AA4922B2EA31F1E831E2922A4A4A4
45A49A92EB454545694B458EBBBF0145418F458EFA01AC1F0245451E839CA4A4
9A9AA4A123DC265FA4A49AA1A49AA4A4231CA4A42F4545454A69E945A8BB4045
A08F46AC45DCAC3826E41F02A89A9A9AA4A4A49AA42D455FB39AA4A49A279AB5
5F1B186B214545454A4C6A0146114545467F4645454302024513C03130B5A49A
A4A4A4A4A4A426A220B379B99C279A29A76B9131921B45454C475E4F457C4501
465945455701453A0201E0A4A4A4A49AA4A4A4A4A4A4A4A4A49A2782829A2770
8329348833284545D95E67504551454545A64545451FA962D0197930A49A9AA4
9A9AA49AA49AA4A4A4A4A46BB3A4B5C16E83451E1E3102454645454545754502
45464502ECEC01E2F61DEB879A9AA49AA4A4A4A4A4A4A4A4A4A4A4A4A4A49A01
E233E0196F2D3D45467F468E45664545454667454501251702929AB3B3A49A26
8820B59A9A9A9AA4A4B4A4A4A4A4A42434A7318531224345AB49484B45654545
8E45454545242445231DA7A4B3879A2756B4E2344526829AA4A49AB3A4A4A445
3646642D0224BD454A4D4C46AF65459845B64545454501452D2E451880792E24
2E0331C1F75F1B2B93A49A6EA4A4B54545454545454545454A8E457CC10D4502
4A384545450245FAC045454501385545E34545360245361F8819279AB5A18245
45454545454545454A45651645B9454545408401454545454524454545454545
454545454602484525C11F22276CC14545454545454545F00207160813834545
4545304545454545464545454545454545454545454545480202E3A82C1F4545
454545454545451311121B06C405454545493B89A54545454548454546454545
4545454545454545454502341B1D45454545454545450C12121208451C044594
4945A528BC454545454545454545454545454745454545454545454545C04545
45454545181B0D0A0A121205030501458C021F94BCE501454545474545454545
4502454545454545454545454545454545451E181616160A0ACECF06C404022E
45458E347095E245454545454545454545454545454545454545454545134545
01140D8016121612CECE01C5CF0402454545341F38BC89A9BC01454545454545
45454545454545454545454545DC01BD911B0D1616161216160802C720C145A3
45E901C0AC452DC005A50145454545464545454545454545454545454545241B
1891141216161112160113C3C724AC624346019E454545023885BC302D454545
4545454545454545454536454588911818A7180D1212120C1245070E0C010270
4645BC0502451F45452D452D85028901454545454545454545454524202981A7
A7A70D110DCE12CE12CE92C60C012D8970492528A91F45454545450240342D83
C1450245454545454548ED3C319915B4A7C00D12121112CECE10BF1612450189
A545461FBC054545454545452D452A325C2D4545470245454546890131A81B0D
0F2428121812CECECE450ABF1145019E8545B085454545450245454545454526
834545453F02454540EA2D419115C1101E23451112CECECECE13BF0A11450000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
[*ENDBIN*]
