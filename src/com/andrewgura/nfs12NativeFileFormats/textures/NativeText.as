package com.andrewgura.nfs12NativeFileFormats.textures {
	import flash.utils.ByteArray;
	
	public class NativeText implements INativeTextureResource {
		
		private var length:uint;
		private var _string:String;
		public function get string():String {
			return _string;
		}
		
		public function NativeText(ba:ByteArray) {
			length = ba.readUnsignedInt();
			_string = ba.readUTFBytes(length);
		}
	}
}