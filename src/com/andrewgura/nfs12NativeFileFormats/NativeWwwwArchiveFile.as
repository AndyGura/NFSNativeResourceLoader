package com.andrewgura.nfs12NativeFileFormats {

import com.andrewgura.nfs12NativeFileFormats.utils.ModelsUtils;

import flash.utils.ByteArray;
import flash.utils.Endian;

import mx.collections.ArrayCollection;

public class NativeWwwwArchiveFile extends ArrayCollection {

    protected var chunks:ArrayCollection = new ArrayCollection();

    public function NativeWwwwArchiveFile(name:String, file:ByteArray) {
        file.endian = Endian.LITTLE_ENDIAN;
        file.position = 4;
        var chunksCount:Number = file.readUnsignedInt();
        var offsets:Array = [];
        while (offsets.length < chunksCount) {
            offsets.push(file.readUnsignedInt());
        }
        for (var i:Number = 0; i < chunksCount; i++) {
            var data:ByteArray = new ByteArray();
            file.position = offsets[i];
            var chunkLength:Number = (i < chunksCount - 1 ? offsets[i + 1] - offsets[i] : file.bytesAvailable);
            file.readBytes(data, 0, chunkLength);
            chunks.addItem(NFSNativeResourceLoader.loadNativeFileFromData(name+'.'+i, data));
        }
        for (var i:Number=0;i<chunks.length-1;i++) {
            if (chunks[i] is NativeOripFile && chunks[i+1] is NativeShpiArchiveFile) {
                ModelsUtils.attachSHPItoOrip(NativeShpiArchiveFile(chunks[i+1]), NativeOripFile(chunks[i]));
            }
        }
        addAll(chunks);
    }

}
}