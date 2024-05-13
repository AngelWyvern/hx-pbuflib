package;

import haxe.Int64;
import haxe.io.Bytes;
import pbuf.Typedefs;
import pbuf.io.Buffer;

class StructTest
{
	static function main()
	{
		test1();
		test2();
		#if !lua // annoying
		test3();
		#end
		test4();
	}

	static function test1()
	{
		trace('  >> Struct Test 1 <<  ');
		var x:MyStruct = new MyStruct(32168, "Good stuff");
		trace('struct initialized with UInt16BE:32168 and ZString:Good stuff');

		trace('reading myInt: ' + x.myInt);
		trace('reading myString: ' + x.myString);
		trace('preview: ' + arrayFromBuf(x) + '\n');
	}

	static function test2()
	{
		trace('  >> Struct Test 2 <<  ');
		var y:OtherStruct = new OtherStruct();

		var a:Int = Math.round(Math.random() * 0xFFFF - 0x8000);
		var b:Int64 = Int64.make(Math.round(Math.random() * 0xFFFFFF - 0x800000), Math.round(Math.random() * 0xFFFFFF - 0x800000));
		var c:Float = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);
		var d:Float = Math.random() * 0xFFFFFF - 0x800000;

		trace ('writing smallData: ' + a);
		y.smallData = a;
		trace ('writing bigData: ' + b);
		y.bigData = b;
		trace ('writing smallFloat: ' + c);
		y.smallFloat = c;
		trace ('writing bigFloat: ' + d);
		y.bigFloat = d;

		trace('reading smallData: ' + y.smallData);
		trace('reading bigData: ' + y.bigData);
		trace('reading smallFloat: ' + y.smallFloat);
		trace('reading bigFloat: ' + y.bigFloat);
		trace('preview: ' + arrayFromBuf(y) + '\n');
	}

	#if !lua // annoying
	static function test3()
	{
		trace('  >> Struct Test 3 <<  ');
		var z:MegaStruct = new MegaStruct();

		var a:Int = Math.round(Math.random() * 0xFF);
		var b:Int = Math.round(Math.random() * 0xFFFF);
		var c:Int = Math.round(Math.random() * 0xFFFFFF);
		var d:Int64 = Int64.make(Math.round(Math.random() * 0xFFFFFF), Math.round(Math.random() * 0xFFFFFF));
		var e:Int = Math.round(Math.random() * 0xFF - 0x80);
		var f:Int = Math.round(Math.random() * 0xFFFF - 0x8000);
		var g:Int = Math.round(Math.random() * 0xFFFFFF - 0x800000);
		var h:Int64 = Int64.make(Math.round(Math.random() * 0xFFFFFF - 0x800000), Math.round(Math.random() * 0xFFFFFF - 0x800000));
		var i:Float = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);
		var j:Float = Math.random() * 0xFFFFFF - 0x800000;
		var k:String = "Very cool";

		trace('writing a: ' + a);
		z.a = a;
		trace('writing b: ' + b);
		z.b = b;
		trace('writing c: ' + c);
		z.c = c;
		trace('writing d: ' + d);
		z.d = d;
		trace('writing e: ' + e);
		z.e = e;
		trace('writing f: ' + f);
		z.f = f;
		trace('writing g: ' + g);
		z.g = g;
		trace('writing h: ' + h);
		z.h = h;
		trace('writing i: ' + i);
		z.i = i;
		trace('writing j: ' + j);
		z.j = j;
		trace('writing k: ' + k);
		z.k = k;

		trace('reading a: ' + z.a);
		trace('reading b: ' + z.b);
		trace('reading c: ' + z.c);
		trace('reading d: ' + z.d);
		trace('reading e: ' + z.e);
		trace('reading f: ' + z.f);
		trace('reading g: ' + z.g);
		trace('reading h: ' + z.h);
		trace('reading i: ' + z.i);
		trace('reading j: ' + z.j);
		trace('reading k: ' + z.k);
		trace('preview: ' + arrayFromBuf(z) + '\n');
	}
	#end

	static function test4()
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

	static inline function arrayFromBuf(buffer:Buffer):Array<UInt>
	{
		var arr = [];
		for (i in 0...buffer.byteLength)
			arr.push(buffer.readUInt8(i));
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

@:build(pbuf.macro.StructBuilder.gen(true))
abstract MyStruct(Buffer)
{
	var myInt:UInt16;
	@size(16) var myString:ZString;
}

@:build(pbuf.macro.StructBuilder.gen())
abstract OtherStruct(Buffer)
{
	var smallData:Int16LE;
	var bigData:Int64LE;
	var smallFloat:FloatLE;
	var bigFloat:DoubleLE;
}

@:build(pbuf.macro.StructBuilder.gen())
abstract MegaStruct(Buffer)
{
	var a:UInt8;
	var b:UInt16;	
	var c:UInt32;	
	var d:UInt64;
	var e:Int8;
	var f:Int16;	
	var g:Int32;	
	var h:Int64;
	var i:Float;
	var j:Double;
	@size(10) var k:ZString;	
}