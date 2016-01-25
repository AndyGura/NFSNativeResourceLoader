package com.andrewgura.nfs12NativeFileFormats {

import com.andrewgura.nfs12NativeFileFormats.models.ModelDescriptionVO;
import com.andrewgura.nfs12NativeFileFormats.models.SubModelDescriptionVO;
import com.andrewgura.nfs12NativeFileFormats.models.Vertex;

import flash.utils.ByteArray;
import flash.utils.Endian;

import mx.collections.ArrayCollection;

public class NativeOripFile {

    public var modelDescription:ModelDescriptionVO;

    private var recordPower:Array = new Array(12, 8, 20, 20, 28, 12, 12, 12, 4);
    private var recordCount:Array = new Array(9);
    private var offsets:Array = new Array(9);
    private var vertexesFileIndicesArray:Array = new Array();

    public function NativeOripFile(name:String, file:ByteArray) {
        var modelDescription:ModelDescriptionVO = new ModelDescriptionVO(name);
        modelDescription.subModels.addAll(processSubModels(file));
        this.modelDescription = modelDescription;
    }

    private function processSubModels(data:ByteArray):ArrayCollection {
        var output:ArrayCollection = new ArrayCollection();
        data.position = 0;
        data.endian = Endian.LITTLE_ENDIAN;
        readChunksData(data);
        for (var i:int = 0; i < recordCount[0]; i++) {
            data.position = i * recordPower[0] + 112;
            var polType:int = data.readByte() & 255;
            var normal:Number = data.readByte();
            var textureID:String = getTextureName(data, data.readByte());
            var subModel:SubModelDescriptionVO = new SubModelDescriptionVO(textureID);
            subModel.textureID = textureID;
            data.position += 1;
            var offset3D:uint = data.readUnsignedInt();
            var offset2D:uint = data.readUnsignedInt();
            if (polType == 0x8B || polType == 0x83) {
                switch (normal) {
                    case 17://2-sided polygons
                    case 19:
                        setupPolygon(subModel, data, offset3D, offset2D, 0, 1, 2, 0, 2, 1);
                        break;
                    case 18://default polygon
                    case 2:
                    case 3:
                    case 48://?
                    case 50://?
                        setupPolygon(subModel, data, offset3D, offset2D, 0, 1, 2);
                        break;
                    case 16://inverted polygon
                    case 1:
                    case 0:
                        setupPolygon(subModel, data, offset3D, offset2D, 0, 2, 1);
                        break;
                    default:
                        throw new Error("Unknown normal: " + normal + ", polygon type: " + polType);
                }
            } else if (polType == 0x84 || polType == 0x8C || polType == 0x04) {
                switch (normal) {
                    case 17://2-sided polygons
                    case 19:
                        setupPolygon(subModel, data, offset3D, offset2D, 0, 1, 3, 1, 2, 3, 0, 3, 1, 1, 3, 2);
                        break;
                    case 18://default polygon
                    case 2:
                    case 3:
                    case 48://?
                    case 50://?
                        setupPolygon(subModel, data, offset3D, offset2D, 0, 1, 3, 1, 2, 3);
                        break;
                    case 16://inverted polygon
                    case 1:
                    case 0:
                        setupPolygon(subModel, data, offset3D, offset2D, 0, 3, 1, 1, 3, 2);
                        break;
                    default:
                        throw new Error("Unknown normal: 0x" + normal.toString(16) + "; polygon type: 0x" + polType.toString(16));
                }
            } else {
                throw new Error("unknown polygon: 0x" + polType.toString(16));
            }
            output.addItem(subModel);
        }
        return output;
    }

    private function readChunksData(data:ByteArray):void {
        data.position = 16;
        recordCount[7] = data.readUnsignedInt();
        data.position += 4;
        offsets[7] = data.readUnsignedInt();
        recordCount[1] = data.readUnsignedInt();
        offsets[1] = data.readUnsignedInt();
        recordCount[0] = data.readUnsignedInt();
        offsets[0] = data.readUnsignedInt();
        var identifier:String = data.readUTFBytes(12);
        recordCount[2] = data.readUnsignedInt();
        offsets[2] = data.readUnsignedInt();
        recordCount[3] = data.readUnsignedInt();
        offsets[3] = data.readUnsignedInt();
        recordCount[4] = data.readUnsignedInt();
        offsets[4] = data.readUnsignedInt();
        offsets[8] = data.readUnsignedInt();
        recordCount[8] = (data.length - offsets[8]) / recordPower[8];
        recordCount[5] = data.readUnsignedInt();
        offsets[5] = data.readUnsignedInt();
        recordCount[6] = data.readUnsignedInt();
        offsets[6] = data.readUnsignedInt();
    }

    private function getVertexByOffset(data:ByteArray, index:uint):Vertex {
        var vertex:Vertex = new Vertex();
        data.position = offsets[7] + index * recordPower[7];
        vertex.x = data.readInt();
        vertex.z = data.readInt();
        vertex.y = data.readInt();
        return vertex;
    }

    private function setupPolygon(model:SubModelDescriptionVO, data:ByteArray,
                                  offset3D:Number, offset2D:Number,
                                  ...offsets:Array):void {
        for (var i:Number = 0; i < offsets.length; i++) {
            model.indexData.push(setupVertex(model, data, offset3D + offsets[i], offset2D + offsets[i]));
        }
    }

    private function setupVertex(model:SubModelDescriptionVO, data:ByteArray, index3D:uint, index2D:uint):Number {
        if (vertexesFileIndicesArray[index3D] != null)
            return vertexesFileIndicesArray[index3D];
        // new vertex creation
        data.position = offsets[8] + index3D * recordPower[8];
        data.position = offsets[7] + data.readUnsignedInt() * recordPower[7];
        model.vertexData.push(data.readInt(), data.readInt(), data.readInt());
        vertexesFileIndicesArray[index3D] = (model.vertexData.length - 3) / 3;
        // setup texture coordinate
        data.position = offsets[8] + index2D * recordPower[8];
        data.position = offsets[1] + data.readUnsignedInt() * recordPower[1];
        model.uvData.push(data.readInt(), data.readInt());
        return vertexesFileIndicesArray[index3D];
    }

    private function getTextureName(data:ByteArray, index:Number):String {
        var pointer:Number = data.position;
        data.position = offsets[2] + index * recordPower[2] + 8;
        var output:String = data.readUTFBytes(4);
        data.position = pointer;
        return output;
    }

}
}