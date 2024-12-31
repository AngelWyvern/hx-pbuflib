package;

import pbuf.io.Buffer;

class OpTest
{
	static function main():Void
	{
		testCopy();
		testClone();
		testCompare();
		testFill();
	}

	static function testCopy():Void
	{
		trace('  >> Copy Test <<  ');

		var buffer1:Buffer = getRandBuf();
		var buffer2:Buffer = getRandBuf();

		trace('buffer1 raw: ${arrayFromBuf(buffer1)}');
		trace('buffer2 raw: ${arrayFromBuf(buffer2)}');

		buffer1.copyTo(buffer2, 0, 4, 0);
		trace('buffer1 copied its first 4 bytes to the start of buffer2');
		buffer2.copyFrom(buffer1, buffer1.byteLength - 4, 4, buffer2.byteLength - 4);
		trace('buffer2 copied from buffer1\'s last 4 bytes to its end');

		trace('buffer1 raw: ${arrayFromBuf(buffer1)}');
		trace('buffer2 raw: ${arrayFromBuf(buffer2)}\n');
	}

	static function testClone():Void
	{
		trace('  >> Clone Test <<  ');

		var buffer:Buffer = getRandBuf();
		trace('buffer raw: ${arrayFromBuf(buffer)}');

		var clone:Buffer = buffer.clone();
		trace('clone raw: ${arrayFromBuf(clone)}');

		for (i in 0...Std.int(clone.byteLength / 4))
			clone[i] = Math.round(Math.random() * 0xFF);
		trace('modified first quarter bytes of clone data with random values');

		trace('buffer raw: ${arrayFromBuf(buffer)}');
		trace('clone raw: ${arrayFromBuf(clone)}\n');
	}

	static function testCompare():Void
	{
		trace('  >> Compare Test <<  ');

		var buffer1:Buffer = getRandBuf();
		var buffer2:Buffer = getRandBuf();

		trace('buffer1 raw: ${arrayFromBuf(buffer1)}');
		trace('buffer2 raw: ${arrayFromBuf(buffer2)}');
		trace('compare: ${buffer1.compare(buffer2)}\n');
	}

	static function testFill():Void
	{
		trace('  >> Fill Test <<  ');

		var buffer:Buffer = getRandBuf();
		trace('buffer raw: ${arrayFromBuf(buffer)}');

		var num:Int = Math.round(Math.random() * 0xFF);
		buffer.fill(num, Std.int(buffer.byteLength / 2), 0);
		trace('filled half of the buffer with value: $num');

		trace('buffer raw: ${arrayFromBuf(buffer)}\n');
	}

	static inline function getRandBuf():Buffer
	{
		var buf:Buffer = Buffer.alloc(16);
		for (i in 0...buf.byteLength)
			buf[i] = Math.round(Math.random() * 0xFF);
		return buf;
	}

	static inline function arrayFromBuf(buffer:Buffer):Array<Int>
	{
		var arr = [];
		for (i in 0...buffer.byteLength)
			arr.push(buffer[i]);
		return arr;
	}
}