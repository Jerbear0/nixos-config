import Quickshell.Io
import QtQuick

Item {
    implicitHeight: 26
    implicitWidth: row.implicitWidth + 12
    property string _val: "—"

    Timer { interval: 4000; running: true; repeat: true; onTriggered: proc.running = true }
    Process {
        id: proc
        command: ["python3", "-c", [
            "import time",
            "f=open('/proc/stat')",
            "v1=list(map(int,f.readline().split()[1:]))",
            "f.close()",
            "time.sleep(1)",
            "f=open('/proc/stat')",
            "v2=list(map(int,f.readline().split()[1:]))",
            "f.close()",
            "i1,i2=v1[3]+v1[4],v2[3]+v2[4]",
            "t1,t2=sum(v1),sum(v2)",
            "dt=t2-t1",
            "print(str(round((1-(i2-i1)/dt)*100))+'%' if dt>0 else '0%')"
        ].join(";")]
        stdout: SplitParser { onRead: (line) => _val = line.trim() }
    }
    Component.onCompleted: proc.running = true

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4
        Text { text: ""; color: "#3fc4de"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
        Text { text: _val; color: "#fb958b"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
    }
}
