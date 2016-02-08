package com.andrewgura.nfs12NativeFileFormats {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;
import com.andrewgura.nfs12NativeFileFormats.textures.NativeText;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.INativeBitmap;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap16bit0565;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap16bit1555;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap24bit;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap32bit;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap8bit;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.INativePalette;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.NativePalette16bit;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.NativePalette24bit;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.NativePalette32bit;

import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;

import mx.collections.ArrayCollection;

public class NativeShpiArchiveFile extends ArrayCollection {

    public static var lastGlobalPalette:INativePalette;

    public var texturesMap:Dictionary = new Dictionary;
    private var _globalPalette:INativePalette = lastGlobalPalette;
    public function get globalPalette():INativePalette {
        return _globalPalette;
    }

    public function set globalPalette(value:INativePalette):void {
        _globalPalette = value;
        for each (var item:INativeBitmap in this) {
            item.addNestedResource(_globalPalette);
        }
        lastGlobalPalette = _globalPalette;
    }

    public var directoryIdentifier:String;


    public function NativeShpiArchiveFile(file:ByteArray) {
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
            resource = parseTextureResource(tmpArray, globalPalette);
            if (tmpArray.bytesAvailable > 0) {
                try {
                    var tmpArray2:ByteArray = new ByteArray();
                    tmpArray.readBytes(tmpArray2, 0, tmpArray.bytesAvailable);
                    var subresource:INativeTextureResource = parseTextureResource(tmpArray2);
                    if (subresource is INativePalette) {
                        INativeBitmap(resource).addNestedResource(subresource);
                    }
                } catch (e:Error) {
                    //silent
                }
            }
            if (resource == null) {
                break;
            }
            if (resource is INativeBitmap) {
                (resource as INativeBitmap).name = name;
                addItem(resource);
                texturesMap[name] = resource;
            } else if (resource is INativePalette && name.toLowerCase() != '!xxx') {
                this.globalPalette = resource as INativePalette;
            }
            resource = null;
        }
    }


    public function parseTextureResource(bd:ByteArray, palette:INativePalette = null):INativeTextureResource {
        var id:uint = bd.readUnsignedByte();
        bd.position += 3;

        switch (id) {
            case 0:
                trace("#################### skipping 0");
                return null;
            case 34:
                return new NativePalette24bit(bd, true);
            case 36:
//            case 124: // it seems to be an 24 bit palette, but it breaks up textures for some reason
                return new NativePalette24bit(bd);
            case 41:
                trace("#################### skipping 41"); //16-bit DOS palette
                return null;
            case 42:
                return new NativePalette32bit(bd);
            case 45:
                return new NativePalette16bit(bd);
            case 111:
                return new NativeText(bd);
            case 120:
                return new NativeBitmap16bit0565(bd);
            case 122:
                trace("#################### skipping 122");
                return null;
            case 123:
                return new NativeBitmap8bit(bd, palette);
            case 125:
                return new NativeBitmap32bit(bd);
            case 126:
                return new NativeBitmap16bit1555(bd);
            case 127:
                return new NativeBitmap24bit(bd);
            default:
                throw new Error("Unknown resource id! (id: " + id + ")");
        }
    }

}
}