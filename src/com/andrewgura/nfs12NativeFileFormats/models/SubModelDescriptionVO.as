package com.andrewgura.nfs12NativeFileFormats.models {
public class SubModelDescriptionVO {

    public var name:String;
    public var vertexData:Vector.<Number>;
    public var indexData:Vector.<uint>;
    public var uvData:Vector.<Number>;
    public var textureID:String;

    public function SubModelDescriptionVO(name:String) {
        this.name = name;
        vertexData = new Vector.<Number>();
        indexData = new Vector.<uint>();
        uvData = new Vector.<Number>();
    }
}

}
