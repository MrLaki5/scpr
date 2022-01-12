# scpr
**Copy whole directories recursive** from host device to targeted device **over SSH**. Copy is done with changes check, so **only changed files** are copied. This speeds up whole process of copy if only few files have changed in between two copy actions. This can be quite usefull in constant transfering of project files to edge devices that don't support rsync and have only SSH.

## Run
In order to run use script scpr.sh
```bash
scpr.sh <path to directory on host to copy> <receiver user>@<receiver ip>:<receiver path where dir is placed>
```

### Example
If we wanted to copy *./test* directory from host to RaspberryPi device on ip 192.168.1.10 with default user pi. If destination where we want to copy is under /home/pi/Desktop.
```bash
scpr.sh ./test pi@192.168.1.10:/home/pi/Desktop
```
