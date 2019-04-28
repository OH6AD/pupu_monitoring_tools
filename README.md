# pupu_monitoring_tools
Pupu Network monitoring tools, used with Icinga

## Icecast stream monitoring

Requirements:

```sh
sudo apt install opus-tools sox libsox-fmt-mp3
```

Usage:

```sh
./stream_monitor mp3 http://example.com:8000/fm.mp3
./stream_monitor opus http://example.com:8000/fm.opus
```

Example output:

```
OK: RMS amplitude: 0.17094|Samples read=483840 Length (seconds)=5.485714 Scaled by=2147483647 Maximum amplitude=0.84853 Minimum amplitude=-0.753561 Midline amplitude=0.047485 Mean norm=0.135753 Mean amplitude=-9.5e-05 RMS amplitude=0.17094;0.1;0.05;0 Maximum delta=0.959165 Minimum delta=0 Mean delta=0.168535 RMS delta=0.211994 Rough frequency=8704 Volume adjustment=1.179
```
