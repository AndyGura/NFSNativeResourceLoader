package com.andrewgura.nfs12NativeFileFormats.textures.bitmaps {

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;

import flash.display.BitmapData;
import flash.display.IBitmapDrawable;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import com.andrewgura.nfs12NativeFileFormats.textures.INativeTextureResource;

public interface INativeBitmap extends INativeTextureResource, IBitmapDrawable {

    function addNestedResource(value:INativeTextureResource):Boolean;

    function getResized():BitmapData;

    function get name():String;

    function set name(value:String):void;

    function draw(source:IBitmapDrawable, matrix:Matrix = null,
                  colorTransform:ColorTransform = null,
                  blendMode:String = null,
                  clipRect:Rectangle = null,
                  smoothing:Boolean = false):void;

    function get textureWidth():Number;

    function get textureHeight():Number;

}

}