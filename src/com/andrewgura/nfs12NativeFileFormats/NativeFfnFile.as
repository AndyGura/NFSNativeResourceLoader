package com.andrewgura.nfs12NativeFileFormats {

import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.utils.Endian;

public class NativeFfnFile extends BitmapData {

    public var name:String;

    public function NativeFfnFile(file:ByteArray) {
        file.endian = Endian.LITTLE_ENDIAN;       //Это означет, что, например, число 00 00 00 C3 записано в файле как "С3 00 00 00"
        file.position = 2500;
        var fontBitmapWidth:Number = file.readShort() / 2;
        var fontBitmapHeight:Number = file.readShort();
        super(fontBitmapWidth, fontBitmapHeight);
        file.position = 2512;
        for (var j:Number = 0; j < fontBitmapHeight; j++) {
            for (var i:Number = 0; i < fontBitmapWidth; i++) {
                var byte:Number = file.readUnsignedByte();
                setPixel32(i, j, byte << 24);
            }
        }
    }
}

}