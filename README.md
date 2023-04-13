# zipsai_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

#alarmee_app : 알람 받는 핸드폰 앱 [flutter] 
#
#alarmee_caller : 알람을 발행하는 서버 겸용 윈도우 앱 [WPF]


## Protocol
[app] <> [server]

- (UDP)[서버 위치 알림]               
    > (Server) {"type":"server","ip":"127.0.0.1"}
- (TCP)[서버로 연결. token 알려줌]    
    > (App) {"type":"connect","ip":"127.0.0.1","token":"asdfasdfasddf"}
- (TCP)[이전까지 쌓여있던 이벤트 리스트 요청] 
    > (App) {"type":"request","code":"52653"}       
- (TCP)[이벤트 리스트 요청에 대한 응답]
    > (Server) {"type":"response","events":["e1","e2","e3","e4"]}
- (FCM)[이벤트 발생시 알람으로 전송]      
    > (Server) {"time":"123801","code":"123","location":A","type":"A","val":"123"}      
    >> hour*3600 + min*60 + sec*1 = time
- (TCP)[이벤트에 대한 응답]           
    > (App) {"type":"result","time":"123412","code":"123","res":"0"}              
    >> 0: default, 1: 대변, 2:소변, 3: 이상 없음
