package com.andrewgura.nfs12NativeFileFormats.textures.bitmaps {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;
import com.andrewgura.nfs12NativeFileFormats.textures.palettes.INativePalette;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.utils.ByteArray;

public class NativeBitmap8bit extends BitmapData implements INativeBitmap {

    private var _name:String;
    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        _name = value;
    }

    private var _nestedResources:Array = new Array();

    public function addNestedResource(value:INativeTextureResource):Boolean {
        if (value == null)
            return false;
        _nestedResources.push(value);
        if (value is INativePalette) {
            setupPixels(value as INativePalette);
        }
        return true;

    }

    private var colorData:ByteArray = new ByteArray;


    public function NativeBitmap8bit(data:ByteArray, palette:INativePalette) {
        super(data.readUnsignedShort(), data.readUnsignedShort());
        data.position += 8;
        data.readBytes(colorData, 0, Math.ceil(width * height / 4) * 4);
        if (palette != null) {
            setupPixels(palette);
        }
    }

    private function setupPixels(palette:INativePalette):void {
        colorData.position = 0;
        for (var j:int = 0; j < height; j++) {
            for (var i:int = 0; i < width; i++) {
                setPixel32(i, j, palette[colorData.readUnsignedByte()]);
            }
        }
    }

    public function get textureWidth():Number {
        return super.width;
    }

    public function get textureHeight():Number {
        return super.height;
    }
}
}