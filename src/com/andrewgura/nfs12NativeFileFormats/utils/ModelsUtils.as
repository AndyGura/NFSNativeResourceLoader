package com.andrewgura.nfs12NativeFileFormats.utils {
import com.andrewgura.nfs12NativeFileFormats.NativeOripFile;
import com.andrewgura.nfs12NativeFileFormats.NativeShpiArchiveFile;
import com.andrewgura.nfs12NativeFileFormats.models.SubModelDescriptionVO;
import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.INativeBitmap;

public class ModelsUtils {

    public static function attachSHPItoOrip(shpi:NativeShpiArchiveFile, orip:NativeOripFile):void {
        for each (var texture:INativeBitmap in shpi) {
            for each (var subModel:SubModelDescriptionVO in orip.modelDescription.subModels) {
                if (subModel.name != texture.name) {
                    continue;
                }
                var newUVData:Vector.<Number> = new Vector.<Number>();
                for (var i:Number = 0; i < subModel.uvData.length; i++) {
                    newUVData.push(subModel.uvData[i] / (i & 1 ? texture.textureHeight : texture.textureWidth));
                }
                subModel.uvData = newUVData;
            }
        }
    }

}
}
