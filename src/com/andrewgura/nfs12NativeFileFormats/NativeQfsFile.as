package com.andrewgura.nfs12NativeFileFormats {
	
	import flash.utils.ByteArray;

	public class NativeQfsFile extends NativeFshFile {
		
		public function NativeQfsFile(file: ByteArray) {
			file = uncompress(file);
			super(file);
		}
		
		private function uncompress(input:ByteArray):ByteArray {
			var output:ByteArray = new ByteArray();	
			var packCode:uint, packA: uint, packB: uint;
			var len:uint, offset:uint;
			input.position = (input.readByte() & 0x01) ? 8 : 5;
			packCode = input.readUnsignedByte();
			while (packCode < 0xFC) {
				packA = input.readUnsignedByte();
				packB = input.readUnsignedByte();				
				if (!(packCode & 0x80)) {
					len=packCode & 3;
					input.position --;
					if (len > 0) {
						input.readBytes(output,output.position,len);
						output.position += len;
					}
					offset=((packCode>>5)<<8)+packA+1;
					len=((packCode & 0x1c) >> 2) + 3;	
					if (len > offset) {
						var oldLength:uint = output.length;
						while (output.length < oldLength+len-offset) {
							output.writeByte(output[output.length-offset]);
						}
						output.position -= len-offset;
					}					
					if (len > 0) {
						output.position -= offset;
						output.readBytes(output,output.position+offset,len);
						output.position += offset;					
					}					
				}
				else if (!(packCode&0x40)) {
					len = (packA >> 6) & 3;
					if (len > 0) {
						input.readBytes(output,output.position,len);
						output.position += len;
					}
					offset = (packA & 0x3f)*256+packB+1;
					len = (packCode & 0x3f) + 4;
					if (len > offset) {
						oldLength = output.length;
						while (output.length < oldLength+len-offset) {
							output.writeByte(output[output.length-offset]);
						}
						output.position -= len-offset;
					}	
					if (len > 0) {
						output.position -= offset;
						output.readBytes(output,output.position+offset,len);
						output.position += offset;		
					}
				}  
				else if (!(packCode&0x20)) {
					var packC:uint = input.readUnsignedByte();
					len=packCode & 3; 
					if (len > 0) {
						input.readBytes(output,output.position,len);
						output.position += len;
					}
					offset=((packCode & 0x10) << 12) + 256 * packA + packB + 1;
					len = ((packCode >> 2) & 3) * 256 + packC + 5;	
					if (len > offset) {
						oldLength = output.length;
						while (output.length < oldLength+len-offset) {
							output.writeByte(output[output.length-offset]);
						}
						output.position -= len-offset;
					}	
					if (len > 0) {
						output.position -= offset;
						output.readBytes(output,output.position+offset,len);
						output.position += offset;
					}
				}  
				else {
					len = (packCode&0x1f)*4+4;
					input.position -= 2;					
					input.readBytes(output,output.position,len);
					output.position += len;
				}		
				if (input.bytesAvailable == 0)
					break;
				packCode = input.readUnsignedByte();
			}
			if (input.bytesAvailable > 0) {
				input.readBytes(output,output.position,input.bytesAvailable);
			}
			return output;
		}
	
	}
}