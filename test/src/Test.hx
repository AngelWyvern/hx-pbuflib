package;

import haxe.Int64;
import haxe.io.Bytes;
import pbuf.io.Buffer;

class Test
{
	static var buffer:Buffer;

	static function main()
	{
		buffer = Buffer.alloc(16);

		testBool();
		testUInt8();
		testUInt16();
		testUInt32();
		testUInt64();
		testInt8();
		testInt16();
		testInt32();
		testInt64();
		testFloat();
		testDouble();
		testString();
		testCasts();
	}

	static function testBool()
	{
		trace('  >> Bool Test <<  ');

		trace('Writing Bools: $false, $true');
		buffer.writeBool(false)
		      .writeBool(true);

		trace('Reading Bools: ${buffer.readBool(0)}, ${buffer.readBool()}');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testUInt8()
	{
		trace('  >> UInt8 Test <<  ');

		var u1:UInt, u2:UInt, u3:UInt, u4:UInt;
		u1 = Math.round(Math.random() * 0xFF);
		u2 = Math.round(Math.random() * 0xFF);
		u3 = Math.round(Math.random() * 0xFF);
		u4 = Math.round(Math.random() * 0xFF);

		trace('Writing random UInt8s: $u1, $u2, $u3, $u4');
		buffer[0] = u1;
		buffer[1] = u2;
		buffer[2] = u3;
		buffer[3] = u4;

		trace('Reading random UInt8s: ${buffer[0]}, ${buffer[1]}, ${buffer[2]}, ${buffer[3]}');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testUInt16()
	{
		trace('  >> UInt16 Test <<  ');

		var u1:UInt, u2:UInt, u3:UInt, u4:UInt;
		u1 = Math.round(Math.random() * 0xFFFF);
		u2 = Math.round(Math.random() * 0xFFFF);
		u3 = Math.round(Math.random() * 0xFFFF);
		u4 = Math.round(Math.random() * 0xFFFF);

		trace('Writing random UInt16s: $u1 (LE), $u2 (LE), $u3 (BE), $u4 (BE)');
		buffer.writeUInt16LE(u1)
		      .writeUInt16LE(u2)
		      .writeUInt16BE(u3)
		      .writeUInt16BE(u4);

		trace('Reading random UInt16s: ${buffer.readUInt16LE(0)} (LE), ${buffer.readUInt16LE()} (LE), ${buffer.readUInt16BE()} (BE), ${buffer.readUInt16BE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testUInt32()
	{
		trace('  >> UInt32 Test <<  ');

		var u1:UInt, u2:UInt, u3:UInt, u4:UInt;
		u1 = Math.round(Math.random() * 0xFFFFFF);
		u2 = Math.round(Math.random() * 0xFFFFFF);
		u3 = Math.round(Math.random() * 0xFFFFFF);
		u4 = Math.round(Math.random() * 0xFFFFFF);

		trace('Writing random UInt32s: $u1 (LE), $u2 (LE), $u3 (BE), $u4 (BE)');
		buffer.writeUInt32LE(u1)
		      .writeUInt32LE(u2)
		      .writeUInt32BE(u3)
		      .writeUInt32BE(u4);

		trace('Reading random UInt32s: ${buffer.readUInt32LE(0)} (LE), ${buffer.readUInt32LE()} (LE), ${buffer.readUInt32BE()} (BE), ${buffer.readUInt32BE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testUInt64()
	{
		trace('  >> UInt64 Test <<  ');

		var u1:Int64, u2:Int64;
		u1 = Int64.make(Math.round(Math.random() * 0xFFFFFF), Math.round(Math.random() * 0xFFFFFF));
		u2 = Int64.make(Math.round(Math.random() * 0xFFFFFF), Math.round(Math.random() * 0xFFFFFF));

		trace('Writing random UInt64s: $u1 (LE), $u2 (BE)');
		buffer.writeUInt64LE(u1)
		      .writeUInt64BE(u2);

		trace('Reading random UInt64s: ${buffer.readUInt64LE(0)} (LE), ${buffer.readUInt64BE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testInt8()
	{
		trace('  >> Int8 Test <<  ');

		var i1:Int, i2:Int, i3:Int, i4:Int;
		i1 = Math.round(Math.random() * 0xFF - 0x80);
		i2 = Math.round(Math.random() * 0xFF - 0x80);
		i3 = Math.round(Math.random() * 0xFF - 0x80);
		i4 = Math.round(Math.random() * 0xFF - 0x80);

		trace('Writing random Int8s: $i1, $i2, $i3, $i4');
		buffer.writeInt8(i1)
		      .writeInt8(i2)
		      .writeInt8(i3)
		      .writeInt8(i4);

		trace('Reading random Int8s: ${buffer.readInt8(0)}, ${buffer.readInt8()}, ${buffer.readInt8()}, ${buffer.readInt8()}');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testInt16()
	{
		trace('  >> Int16 Test <<  ');

		var i1:Int, i2:Int, i3:Int, i4:Int;
		i1 = Math.round(Math.random() * 0xFFFF - 0x8000);
		i2 = Math.round(Math.random() * 0xFFFF - 0x8000);
		i3 = Math.round(Math.random() * 0xFFFF - 0x8000);
		i4 = Math.round(Math.random() * 0xFFFF - 0x8000);

		trace('Writing random Int16s: $i1 (LE), $i2 (LE), $i3 (BE), $i4 (BE)');
		buffer.writeInt16LE(i1)
		      .writeInt16LE(i2)
		      .writeInt16BE(i3)
		      .writeInt16BE(i4);

		trace('Reading random Int16s: ${buffer.readInt16LE(0)} (LE), ${buffer.readInt16LE()} (LE), ${buffer.readInt16BE()} (BE), ${buffer.readInt16BE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testInt32()
	{
		trace('  >> Int32 Test <<  ');

		var i1:Int, i2:Int, i3:Int, i4:Int;
		i1 = Math.round(Math.random() * 0xFFFFFF - 0x800000);
		i2 = Math.round(Math.random() * 0xFFFFFF - 0x800000);
		i3 = Math.round(Math.random() * 0xFFFFFF - 0x800000);
		i4 = Math.round(Math.random() * 0xFFFFFF - 0x800000);

		trace('Writing random Int32s: $i1 (LE), $i2 (LE), $i3 (BE), $i4 (BE)');
		buffer.writeInt32LE(i1)
		      .writeInt32LE(i2)
		      .writeInt32BE(i3)
		      .writeInt32BE(i4);

		trace('Reading random Int32s: ${buffer.readInt32LE(0)} (LE), ${buffer.readInt32LE()} (LE), ${buffer.readInt32BE()} (BE), ${buffer.readInt32BE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testInt64()
	{
		trace('  >> Int64 Test <<  ');

		var i1:Int64, i2:Int64;
		i1 = Int64.make(Math.round(Math.random() * 0xFFFFFF - 0x800000), Math.round(Math.random() * 0xFFFFFF - 0x800000));
		i2 = Int64.make(Math.round(Math.random() * 0xFFFFFF - 0x800000), Math.round(Math.random() * 0xFFFFFF - 0x800000));

		trace('Writing random Int64s: $i1 (LE), $i2 (BE)');
		buffer.writeInt64LE(i1)
		      .writeInt64BE(i2);

		trace('Reading random Int64s: ${buffer.readInt64LE(0)} (LE), ${buffer.readInt64BE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testFloat()
	{
		trace('  >> Float Test <<  ');

		var f1:Float, f2:Float, f3:Float, f4:Float;
		f1 = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4); // I'm too lazy to figure out the min and max float ranges
		f2 = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);
		f3 = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);
		f4 = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);

		trace('Writing random Floats: $f1 (LE), $f2 (LE), $f3 (BE), $f4 (BE)');
		buffer.writeFloatLE(f1)
		      .writeFloatLE(f2)
		      .writeFloatBE(f3)
		      .writeFloatBE(f4);

		trace('Reading random Floats: ${buffer.readFloatLE(0)} (LE), ${buffer.readFloatLE()} (LE), ${buffer.readFloatBE()} (BE), ${buffer.readFloatBE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testDouble()
	{
		trace('  >> Double Test <<  ');

		var f1:Float, f2:Float;
		f1 = Math.random() * 0xFFFFFF - 0x800000; // I'm too lazy to figure out the min and max float ranges
		f2 = Math.random() * 0xFFFFFF - 0x800000;

		trace('Writing random Doubles: $f1 (LE), $f2 (BE)');
		buffer.writeDoubleLE(f1)
		      .writeDoubleBE(f2);

		trace('Reading random Doubles: ${buffer.readDoubleLE(0)} (LE), ${buffer.readDoubleBE()} (BE)');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testString()
	{
		trace('  >> String Test <<  ');

		var str1:String = "String test", str2:String;

		trace('Writing String: $str1');
		buffer.writeString(str1, UTF8);

		trace('Reading String: ${buffer.readString(16, UTF8, 0)}');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();

		str1 = "LString";
		str2 = "Test";

		trace('Writing L16LEStrings: $str1, $str2');
		buffer.writeL16LEString(str1, UTF8)
		      .writeL16LEString(str2, UTF8);

		trace('Reading L16LEStrings: ${buffer.readL16LEString(UTF8, 0)}, ${buffer.readL16LEString(UTF8)}');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();

		str1 = "ZString";

		trace('Writing ZStrings: $str1, $str2');
		buffer.writeZString(str1, UTF8)
		      .writeZString(str2, UTF8);

		trace('Reading ZStrings: ${buffer.readZString(UTF8, 0)}, ${buffer.readZString(UTF8)}');

		trace('Raw buffer data: ${arrayFromBuf()}\n');
		cleanup();
	}

	static function testCasts()
	{
		trace('  >> Casts Test <<  ');

		trace('Filling buffer with random UInt8s');
		for (i in 0...buffer.byteLength)
			buffer[i] = Math.round(Math.random() * 0xFF);

		trace('Casting buffer to bytes');
		var bytes:Bytes = buffer;

		trace('Raw bytes data: ${arrayFromBytes(bytes)}');
		trace('Raw buffer data: ${arrayFromBuf()}');

		trace('Filling new bytes with random UInt8s');
		bytes = Bytes.alloc(buffer.byteLength);
		for (i in 0...bytes.length)
			bytes.set(i, Math.round(Math.random() * 0xFF));

		trace('Casting bytes to buffer');
		buffer = bytes;

		trace('Raw bytes data: ${arrayFromBytes(bytes)}');
		trace('Raw buffer data: ${arrayFromBuf()}\n');

		cleanup();
	}

	static inline function arrayFromBuf():Array<Int>
	{
		var arr = [];
		for (i in 0...buffer.byteLength)
			arr.push(buffer[i]);
		return arr;
	}

	static inline function arrayFromBytes(bytes:Bytes):Array<Int>
	{
		var arr = [];
		for (i in 0...bytes.length)
			arr.push(bytes.get(i));
		return arr;
	}

	static inline function cleanup():Void
	{
		buffer.fill(0, buffer.byteLength, 0);
		buffer.curPos = 0;
	}

	static inline function limitPrecision(v:Float, d:Int):Float
	{
		final i = Std.int(v), m = Math.pow(10, d);
		return i + (Std.int((v - i) * m)) / m;
	}
}