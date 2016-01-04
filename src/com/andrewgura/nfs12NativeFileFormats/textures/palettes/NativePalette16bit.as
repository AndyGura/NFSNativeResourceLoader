package com.andrewgura.nfs12NativeFileFormats.textures.palettes {
	
	import flash.utils.ByteArray;
	
	public dynamic class NativePalette16bit extends Array implements INativePalette {
		
		public function NativePalette16bit(data:ByteArray) {
			super();
			data.position += 12;			
			for (var i:Number = 0;i<256;i++) {
				var color:Number = data.readUnsignedShort();
				var RED:Number = Math.floor(color/2048);
				var GREEN:Number = Math.floor((color-RED*2048)/32);
				var BLUE:Number = color - RED*2048 - GREEN*32;					
				this.push(RED*256*256*8+GREEN*256*4+BLUE*8);
			}
		}
		
	}
	
}