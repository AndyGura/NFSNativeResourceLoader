package com.andrewgura.nfs12NativeFileFormats.textures.bitmaps {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.utils.ByteArray;

public class NativeBitmap16bit1555 extends BitmapData implements INativeBitmap {

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

    public function NativeBitmap16bit1555(data:ByteArray) {
        super(data.readUnsignedShort(), data.readUnsignedShort());
        data.position += 8;
        for (var j:int = 0; j < height; j++) {
            for (var i:int = 0; i < width; i++) {
                var color:Number = data.readUnsignedShort();
                setPixel/*32*/(i, j,
                        /*(32768 & color ? 4278190080 : 0) +	*/			//ALPHA
                        ((31744 & color) << 9 | (28672 & color) << 4) + //RED
                        ((992 & color) << 6 | (896 & color) << 1) +     //GREEN
                        ((31 & color) << 3 | (28 & color) >> 2)		 	//BLUE
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

