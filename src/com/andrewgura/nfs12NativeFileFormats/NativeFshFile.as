package com.andrewgura.nfs12NativeFileFormats {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.INativeBitmap;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.INativePalette;

import flash.utils.ByteArray;
import flash.utils.Endian;

import mx.collections.ArrayCollection;

public class NativeFshFile extends ArrayCollection {

    private var _globalPalette:INativePalette;
    public function get globalPalette():INativePalette {
        return _globalPalette;
    }

    public function set globalPalette(value:INativePalette):void {
        _globalPalette = value;
        for each (var item:INativeBitmap in this) {
            item.addNestedResource(_globalPalette);
        }
    }

    public var directoryIdentifier:String;


    public function NativeFshFile(file:ByteArray) {
        file.endian = Endian.LITTLE_ENDIAN;       //Это означет, что, например, число 00 00 00 C3 записано в файле как "С3 00 00 00"
        file.position = 8;
        var instanceCount:uint = file.readInt();
        directoryIdentifier = file.readUTFBytes(4);
        var offset:uint;
        var length:uint;
        var name:String;
        var tmpArray:ByteArray = new ByteArray();
        var resource:INativeTextureResource;
        tmpArray.endian = Endian.LITTLE_ENDIAN;
        for (var i:uint = 0; i < instanceCount; i++) {
            tmpArray.clear();
            file.position = 16 + i * 8;
            name = file.readUTFBytes(4);
            offset = file.readInt();
            if (i == instanceCount - 1) {
                length = file.length - offset;
            } else {
                file.position += 4;
                length = file.readInt() - offset;
                if (length + offset > file.length) {
                    length = file.length - offset;
                }
            }
            file.position = offset;
            file.readBytes(tmpArray, 0, length);
            resource = NFSNativeResourceLoader.loadResource(tmpArray, globalPalette);
            if (resource == null) {
                break;
            }
            if (resource is INativeBitmap) {
                (resource as INativeBitmap).name = name;
                addItem(resource);
            } else if (resource is INativePalette) {
                this.globalPalette = resource as INativePalette;
            }
            resource = null;
        }
    }

}
}