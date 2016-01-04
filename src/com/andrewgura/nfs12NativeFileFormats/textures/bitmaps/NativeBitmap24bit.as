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

    public function getResized():BitmapData {
        var scaleX:Number = calculateNewDimension(width) / width;
        var scaleY:Number = calculateNewDimension(height) / height;
        var matrix:Matrix = new Matrix();
        matrix.scale(scaleX, scaleY);
        var newBitmap:NativeBitmapWrapper = new NativeBitmapWrapper(calculateNewDimension(width), calculateNewDimension(height), true, 0);
        newBitmap.draw(this, matrix);
        newBitmap.name = name;
        return newBitmap;
    }

    private function calculateNewDimension(value:Number):Number {
        for (var i:Number = 1; i <= 2048; i <<= 1) {
            if (i >= value) break;
        }
        return i;
    }

    public function get textureWidth():Number {
        return super.width;
    }

    public function get textureHeight():Number {
        return super.height;
    }
}
}