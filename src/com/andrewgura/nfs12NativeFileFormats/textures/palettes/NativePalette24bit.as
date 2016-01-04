package com.andrewgura.nfs12NativeFileFormats.textures.palettes {
	
	import flash.utils.ByteArray;

	public dynamic class NativePalette24bit extends Array implements INativePalette {
		
		public function NativePalette24bit(data:ByteArray, isDOS:Boolean = false) {
			super();
			data.position += 12;
			for (var i:Number = 0;i<256;i++) {
				this.push(4278190080 | 
							data.readUnsignedByte() << (isDOS ? 18 : 16) | 
							data.readUnsignedByte() << (isDOS ? 10 : 8) | 
							(isDOS ? (data.readUnsignedByte() << 2) : data.readUnsignedByte()));	
				if (data.bytesAvailable < 3) {
					data.position = data.length;	
					break;
				}
			}
		}
		
	}
	
}