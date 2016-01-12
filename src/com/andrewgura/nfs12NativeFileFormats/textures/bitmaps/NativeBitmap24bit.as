package com.andrewgura.nfs12NativeFileFormats.textures.bitmaps {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.utils.ByteArray;

public class NativeBitmap24bit extends BitmapData implements INativeBitmap {

    private var _name:String;
    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        _name = value;
    }

    private var _nestedResources:Array = new Array;

    public function addNestedResource(value:INativeTextureResource):Boolean {
        if (value == null)
            return false;
        else
            _nestedResources.push(value);
        return true;
    }


    public function NativeBitmap24bit(data:ByteArray) {
        super(data.readUnsignedShort(), data.readUnsignedShort());
        data.position += 8;
        for (var j:int = 0; j < height; j++) {
            for (var i:int = 0; i < width; i++) {
                setPixel32(i, j,
                        4278190080 + 					//ALPHA
                        data.readUnsignedByte() << 16 + //RED
                        data.readUnsignedByte() << 8 +	//GREEN
                        data.readUnsignedByte()			//BLUE
                );
            }
        }
        if (width * height % 2 != 0)
            data.position += 2;
    }

    public function get textureWidth():Number {
        return super.width;
    }

    public function get textureHeight():Number {
        return super.height;
    }
}
}