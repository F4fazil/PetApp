import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({
    super.key,
  });

  @override
  _AudioCallPageState createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  late RtcEngine _engine;
  bool _joinedChannel = false;
  bool _muted = false;
  bool _speakerOn = true;
  final String appId = '460bb44c5af242d1a0f68903d5316413';
  final String token =
      "007eJxTYLjw8Nw+1hYzwWlr95Uu9Xy39ZGjKIP116DNnz6vSN055XuqAoOJmUFSkolJsmlimpGJUYphokGamYWlgXGKqbGhmYmhcd2+c+kNgYwMqg92MjBCIYjPxlCQWpJYUMDAAABWKSLi";
  final String channelName = 'pet';
  // final String _appCertficate = "3540825240994d57a213156e10845438";

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Request microphone permission
    await _handleMicrophonePermission();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await _engine.enableAudio();

    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _joinedChannel = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {});
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        setState(() {});
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        // Handle leaving the channel
        setState(() {
          _joinedChannel = false;
        });
      },
    ));

    await _joinChannel();
  }

  Future<void> _handleMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
    }
  }

  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
      uid: 0,
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onToggleSpeaker() {
    setState(() {
      _speakerOn = !_speakerOn;
    });
    _engine.setEnableSpeakerphone(_speakerOn);
  }

  void _onEndCall() {
    _engine.leaveChannel();
    Navigator.pop(context);
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: _muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              _muted ? Icons.mic_off : Icons.mic,
              color: _muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: _onEndCall,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
          ),
          RawMaterialButton(
            onPressed: _onToggleSpeaker,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: _speakerOn ? Colors.white : Colors.blueAccent,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              _speakerOn ? Icons.volume_up : Icons.volume_off,
              color: _speakerOn ? Colors.blueAccent : Colors.white,
              size: 20.0,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.indigo.shade200,
          ),
        ),
        title: const Text(' Audio Call'),
      ),
      body: Center(
        child: _joinedChannel
            ? const Text(
                'Connected',
                style: TextStyle(fontSize: 20),
              )
            : const Text(
                "Connecting...",
                style: TextStyle(fontSize: 20),
              ),
      ),
      bottomNavigationBar: _toolbar(),
    );
  }
}
