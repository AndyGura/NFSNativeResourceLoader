package com.andrewgura.nfs12NativeFileFormats {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;
import com.andrewgura.nfs12NativeFileFormats.textures.NativeText;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap16bit0565;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap16bit1555;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap24bit;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap32bit;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.NativeBitmap8bit;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.INativePalette;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.NativePalette16bit;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.NativePalette24bit;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.NativePalette32bit;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;

public class NFSNativeResourceLoader {

    public static function loadNativeFile(file:File):* {
        var data:ByteArray = new ByteArray();
        var f:FileStream = new FileStream();
        f.open(file, FileMode.READ);
        f.readBytes(data, 0, f.bytesAvailable);
        f.close();
        var parsedData:* = loadNativeFileFromData(file.name.substr(0, file.name.lastIndexOf('.')), file.extension, data);
        return parsedData;
    }

    public static function loadNativeFileFromData(name:String, extension:String, data:ByteArray):* {
        var id:String = data.readUTFBytes(4);
        if (((data[0] & 0xfe) == 0x10) && (data[1] == 0xfb)) {
            return new NativeQfsFile(data);
        } else if (id == 'SHPI') {
            return new NativeShpiArchiveFile(data);
        } else if (id == 'FNTF') {
            return new NativeFfnFile(data);
        } else if (id == 'ORIP') {
            return new NativeOripFile(name, data);
        } else if (id == 'wwww') {
            return new NativeWwwwArchiveFile(name, data);
        } else {
            throw new Error("Unknown file format!");
        }
    }

    public static function loadResource(bd:ByteArray, palette:INativePalette = null):INativeTextureResource {
        var id:uint = bd.readUnsignedByte();
        bd.position += 3;

        switch (id) {
            case 0:
                trace("#################### skipping 0");
                return null;
            case 34:
                return new NativePalette24bit(bd, true);
            case 36:
                return new NativePalette24bit(bd);
            case 41:
                trace("#################### skipping 41");
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
            case 124:
                trace("#################### skipping 124");
                return null;
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