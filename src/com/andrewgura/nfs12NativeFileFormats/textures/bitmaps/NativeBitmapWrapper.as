package com.andrewgura.nfs12NativeFileFormats.textures.bitmaps {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;

import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

public class NativeBitmapWrapper extends BitmapData implements INativeBitmap {

    private var _name:String;

    public function NativeBitmapWrapper(width:int, height:int, transparent:Boolean = true, fillColor:uint = 4.294967295E9) {
        super(width, height, transparent, fillColor);
    }

    public function addNestedResource(value:INativeTextureResource):Boolean {
        return false;
    }

    public function get name():String {
        return _name;
    }

    public function set name(value:String):void {
        _name = value;
    }

    override public function draw(source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void {
        super.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
    }

    public function get textureWidth():Number {
        return super.width;
    }

    public function get textureHeight():Number {
        return super.height;
    }
}
}