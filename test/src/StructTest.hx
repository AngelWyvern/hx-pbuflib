package;

import haxe.Int64;
import haxe.io.Bytes;
import pbuf.Typedefs;
import pbuf.io.Buffer;

class StructTest
{
	static function main():Void
	{
		test1();
		test2();
		test3();
		test4();
	}

	static function test1():Void
	{
		trace('  >> Struct Test 1 <<  ');
		var x:MyStruct = new MyStruct(32168, "Good stuff");
		trace('struct initialized with UInt16BE:32168 and ZString:Good stuff');

		trace('reading myInt: ' + x.myInt);
		trace('reading myString: ' + x.myString);
		trace('preview: ' + arrayFromBuf(x) + '\n');
	}

	static function test2():Void
	{
		trace('  >> Struct Test 2 <<  ');
		var y:OtherStruct = new OtherStruct();

		var a:Int = Math.round(Math.random() * 0xFFFF - 0x8000);
		var b:Int64 = Int64.make(Math.round(Math.random() * 0xFFFFFF - 0x800000), Math.round(Math.random() * 0xFFFFFF - 0x800000));
		var c:Float = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);
		var d:Float = Math.random() * 0xFFFFFF - 0x800000;

		trace('writing smallData: ' + a);
		y.smallData = a;
		trace('writing bigData: ' + b);
		y.bigData = b;
		trace('writing smallFloat: ' + c);
		y.smallFloat = c;
		trace('writing bigFloat: ' + d);
		y.bigFloat = d;

		trace('reading smallData: ' + y.smallData);
		trace('reading bigData: ' + y.bigData);
		trace('reading smallFloat: ' + y.smallFloat);
		trace('reading bigFloat: ' + y.bigFloat);
		trace('preview: ' + arrayFromBuf(y) + '\n');
	}

	static function test3():Void
	{
		trace('  >> Struct Test 3 <<  ');
		var z:LayeredStruct = new LayeredStruct();

		var a:Int = Math.floor(Math.random() * 0x100);
		var b:Int = Math.floor(Math.random() * 0x10000 - 0x8000);
		var c:Int = Math.floor(Math.random() * 0x10000 - 0x8000);
		var d:Int = Math.floor(Math.random() * 0x10000 - 0x8000);
		var e:Int = Math.floor(Math.random() * 0x10000 - 0x8000);

		trace('writing id: ' + a);
		z.id = a;

		trace('writing rect.x: ' + b);
		z.rect.x = b;
		trace('writing rect.y: ' + c);
		z.rect.y = c;
		trace('writing rect.size.w: ' + d);
		z.rect.size.w = d;
		trace('writing rect.size.h: ' + e);
		z.rect.size.h = e;

		trace('reading id: ' + z.id);
		trace('reading rect.x: ' + z.rect.x);
		trace('reading rect.y: ' + z.rect.y);
		trace('reading rect.size.w: ' + z.rect.size.w);
		trace('reading rect.size.h: ' + z.rect.size.h);
		trace('preview: ' + arrayFromBuf(z) + '\n');
	}

	static function test4():Void
	{
		trace('  >> Struct from/to Bytes <<  ');
		var a:Array<Int> = [0x60, 0x00, 0x49, 0x74, 0x20, 0x77, 0x6F, 0x72, 0x6B, 0x73, 0x21, 0x00];
		var b:Bytes = Bytes.alloc(a.length);
		for (p in 0...b.length)
			b.set(p, a[p]);
		trace('setup Bytes: ' + a);
		var x:MyStruct = b;
		trace('reading myInt: ' + x.myInt);
		trace('reading myString: ' + x.myString);
		x.myInt = 27132;
		trace('changed myInt: ' + x.myInt);
		b = x.toBytes();
		a = arrayFromBytes(b);
		trace('convert to Bytes: ' + a);
	}

	static inline function arrayFromBuf(buffer:Buffer):Array<Int>
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

	static inline function limitPrecision(v:Float, d:Int):Float
	{
		final i = Std.int(v), m = Math.pow(10, d);
		return i + (Std.int((v - i) * m)) / m;
	}
}

@:build(pbuf.Struct.make(true))
abstract MyStruct(Buffer)
{
	var myInt:UInt16;
	@size(16) var myString:ZString;
}

@:build(pbuf.Struct.make())
abstract OtherStruct(Buffer)
{
	var smallData:Int16LE;
	var bigData:Int64LE;
	var smallFloat:FloatLE;
	var bigFloat:DoubleLE;
}

@:build(pbuf.Struct.make())
abstract LayeredStruct(Buffer)
{
	var id:UInt8;
	var rect:
	{
		var x:Int16;
		var y:Int16;
		var size:
		{
			var w:Int16;
			var h:Int16;
		}
	}
}