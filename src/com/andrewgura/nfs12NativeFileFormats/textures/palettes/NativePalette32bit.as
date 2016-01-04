package com.andrewgura.nfs12NativeFileFormats.textures.palettes {
	
	import flash.utils.ByteArray;

	public dynamic class NativePalette32bit extends Array implements INativePalette {
				
		public function NativePalette32bit(data:ByteArray) {
			super();
			data.position += 12;			
			for (var i:Number = 0;i<256;i++) {
				this.push(data.readUnsignedInt());
				if (data.bytesAvailable < 4) {
					data.position = data.length;
					break;
				}
			}
		}
		
	}
	
}