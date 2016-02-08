package com.andrewgura.nfs12NativeFileFormats {

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public class NFSNativeResourceLoader {

    public static function loadNativeFile(file:File):* {
        var data:ByteArray = new ByteArray();
        var f:FileStream = new FileStream();
        f.open(file, FileMode.READ);
        f.readBytes(data, 0, f.bytesAvailable);
        f.close();
        var parsedData:* = loadNativeFileFromData(file.name.substr(0, file.name.lastIndexOf('.')), data);
        return parsedData;
    }

    public static function loadNativeFileFromData(name:String, data:ByteArray):* {
        var id:String = data.readUTFBytes(4);
        if (((data[0] & 0xfe) == 0x10) && (data[1] == 0xfb)) {
            return new NativeQfsFile(data);
        } else if (id == 'SHPI') {
            return new NativeShpiArchiveFile(data);
        } else if (id == 'FNTF') {
            var ffn:* = new NativeFfnFile(data);
            ffn.name = name;
            return ffn;
        } else if (id == 'ORIP') {
            return new NativeOripFile(name, data);
        } else if (id == 'wwww') {
            return new NativeWwwwArchiveFile(name, data);
        } else {
            throw new Error("Unknown file format!");
        }
    }

}

}