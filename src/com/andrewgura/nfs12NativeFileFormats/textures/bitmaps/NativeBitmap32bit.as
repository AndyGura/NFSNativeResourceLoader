package com.andrewgura.nfs12NativeFileFormats.textures.bitmaps {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

public class NativeBitmap32bit extends BitmapData implements INativeBitmap {

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


    public function NativeBitmap32bit(data:ByteArray) {
        super(data.readUnsignedShort(), data.readUnsignedShort());
        data.position += 8;
        try {
            setPixels(new Rectangle(0, 0, width, height), data);
        } catch (e:Error) {
            data.position = data.length;
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