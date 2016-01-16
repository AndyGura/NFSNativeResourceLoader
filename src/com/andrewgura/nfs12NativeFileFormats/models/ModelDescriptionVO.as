package com.andrewgura.nfs12NativeFileFormats.models {
import mx.collections.ArrayCollection;

public class ModelDescriptionVO {

    public var name:String;
    public var subModels:ArrayCollection;

    public function ModelDescriptionVO(name:String) {
        this.name = name;
        this.subModels = new ArrayCollection();
    }
}
}
