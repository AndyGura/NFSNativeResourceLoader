package com.andrewgura.nfs12NativeFileFormats {

import away3d.core.base.Geometry;
import away3d.core.base.SubGeometry;
import away3d.core.base.data.Vertex;
import away3d.entities.Mesh;
import away3d.materials.TextureMaterial;
import away3d.utils.Cast;

import com.andrewgura.nfs12NativeFileFormats.textures.bitmaps.INativeBitmap;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.utils.ByteArray;
import flash.utils.Endian;

import mx.collections.ArrayCollection;

public class NativeCFMFile extends Mesh {

    private var recordPower:Array = new Array(12, 8, 20, 20, 28, 12, 12, 12, 4);
    private var recordCount:Array = new Array(9);
    private var offsets:Array = new Array(9);
    private var vertexesFileIndicesArray:Array = new Array();
    private var textures:ArrayCollection;

    public function NativeCFMFile(file:ByteArray) {
        var carGeo:Geometry;
        file.endian = Endian.LITTLE_ENDIAN;
        file.position = 8;
        var offsets:Array = new Array(file.readUnsignedInt(), file.readUnsignedInt());
        var data:ByteArray = new ByteArray();
        file.position = offsets[1];
        file.readBytes(data, 0, offsets[2] - offsets[1]);

        var fR:FileStream = new FileStream();
        var f:File = File.desktopDirectory.resolvePath("out.fsh");
        fR.open(f, FileMode.WRITE);
        fR.writeBytes(data, 0, data.length);
        fR.close();

        textures = NFSNativeResourceLoader.loadNativeFileFromData(data);
        data = new ByteArray();
        file.position = offsets[0];
        file.readBytes(data, 0, offsets[1] - offsets[0]);
        for each (var item:INativeBitmap in NativeFshFile(textures)) {
            var itemN:Bitmap = getResized(new Bitmap(item as BitmapData));
            if (!carGeo) {
                carGeo = processModel(data, item.name, item.textureWidth, item.textureHeight);
                if (carGeo.subGeometries[0].vertexData.length == 0) {
                    carGeo = null;
                    continue;
                }
                super(carGeo, new TextureMaterial(Cast.bitmapTexture(itemN)));
                continue;
            }
            carGeo = processModel(data, item.name, item.textureWidth, item.textureHeight);
            if (carGeo.subGeometries[0].vertexData.length == 0) continue;
            var mesh:Mesh = new Mesh(carGeo, new TextureMaterial(Cast.bitmapTexture(itemN)));
            super.addChild(mesh);
        }
        vertexesFileIndicesArray = null;
    }

    private function processModel(data:ByteArray, materialID:String, textureWidth:Number, textureHeight:Number):Geometry {
        var subGeom:SubGeometry = new SubGeometry();
        subGeom.updateVertexData(new Vector.<Number>());
        subGeom.updateIndexData(new Vector.<uint>());
        subGeom.updateUVData(new Vector.<Number>());
        data.endian = Endian.LITTLE_ENDIAN;
        readChunksData(data);
        for (var i:int = 0; i < recordCount[0]; i++) {
            data.position = i * recordPower[0] + 112;
            var polType:int = data.readByte() & 255;
            var normal:Number = data.readByte();
            var textureID:String = getTextureName(data, data.readByte());
            if (textureID != materialID) {
                continue;
            }
            data.position += 1;
            var offset3D = data.readUnsignedInt();
            var offset2D = data.readUnsignedInt();
            if (polType == 0x83) {
                switch (normal) {
                    case 17://2-sided polygons
                    case 19:
                        setupPolygon(subGeom, data, offset3D, offset2D, textureWidth, textureHeight,
                                0, 1, 2, 0, 2, 1);
                        break;
                    case 18://default polygon
                        setupPolygon(subGeom, data, offset3D, offset2D, textureWidth, textureHeight,
                                0, 1, 2);
                        break;
                    case 16://inverted polygon
                        setupPolygon(subGeom, data, offset3D, offset2D, textureWidth, textureHeight,
                                0, 2, 1);
                        break;
                    default:
                        trace("Unknown normal:", normal);
                }
            } else if (polType == 0x84 || polType == 0x8C) {
                switch (normal) {
                    case 17://2-sided polygons
                    case 19:
                        setupPolygon(subGeom, data, offset3D, offset2D, textureWidth, textureHeight,
                                0, 1, 3, 1, 2, 3, 0, 3, 1, 1, 3, 2);
                        break;
                    case 18://default polygon
                        setupPolygon(subGeom, data, offset3D, offset2D, textureWidth, textureHeight,
                                0, 1, 3, 1, 2, 3);
                        break;
                    case 16://inverted polygon
                        setupPolygon(subGeom, data, offset3D, offset2D, textureWidth, textureHeight,
                                0, 3, 1, 1, 3, 2);
                        break;
                    default:
                        trace("Unknown normal:", normal);
                }
            } else {
                //throw new Error("unknown polygon!");
                trace("Unknown polygon! name: " + materialID);
            }
        }
        subGeom.updateVertexData(subGeom.vertexData);
        subGeom.updateIndexData(subGeom.indexData);
        subGeom.updateUVData(subGeom.UVData);
        var geom:Geometry = new Geometry;
        geom.addSubGeometry(subGeom);
        return geom;
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

    private function setupPolygon(subGeom:SubGeometry, data:ByteArray,
                                  offset3D:Number, offset2D:Number,
                                  textureWidth:Number, textureHeight:Number,
                                  ...offsets:Array):void {
        for (var i:Number = 0; i < offsets.length; i++) {
            subGeom.indexData.push(setupVertex(subGeom, data, offset3D + offsets[i], offset2D + offsets[i], textureWidth, textureHeight));
        }
    }

    private function setupVertex(geom:SubGeometry, data:ByteArray, index3D:uint, index2D:uint, textureWidth:Number, textureHeight:Number):Number {
        if (vertexesFileIndicesArray[index3D] != null)
            return vertexesFileIndicesArray[index3D];
        //создание новой вершины
        data.position = offsets[8] + index3D * recordPower[8];
        data.position = offsets[7] + data.readUnsignedInt() * recordPower[7];
        geom.vertexData.push(data.readInt(), data.readInt(), data.readInt());
        vertexesFileIndicesArray[index3D] = (geom.vertexData.length - 3) / 3;
        //настройка координаты текстуры
        data.position = offsets[8] + index2D * recordPower[8];
        data.position = offsets[1] + data.readUnsignedInt() * recordPower[1];
        geom.UVData.push(data.readInt() / textureWidth, data.readInt() / textureHeight);
        return vertexesFileIndicesArray[index3D];
    }

    private function getTextureName(data:ByteArray, index:Number):String {
        var pointer:Number = data.position;
        data.position = offsets[2] + index * recordPower[2] + 8;
        var output:String = data.readUTFBytes(4);
        data.position = pointer;
        return output;
    }

    private function getResized(bitmap:Bitmap):Bitmap {
        var scaleX:Number = calculateNewDimension(bitmap.width) / bitmap.width;
        var scaleY:Number = calculateNewDimension(bitmap.height) / bitmap.height;
        var matrix:Matrix = new Matrix();
        matrix.scale(scaleX, scaleY);
        var newBitmap:BitmapData = new BitmapData(calculateNewDimension(bitmap.width), calculateNewDimension(bitmap.height), true, 0);
        newBitmap.draw(bitmap, matrix);
        return new Bitmap(newBitmap);
    }

    private function calculateNewDimension(value:Number):Number {
        for (var i:Number = 1; i < 2048; i <<= 1) {
            if (i >= value) break;
        }
        return i;
    }

}
}