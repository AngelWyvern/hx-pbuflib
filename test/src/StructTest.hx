package;

import haxe.Int64;
import pbuf.Typedefs;
import pbuf.io.Buffer;

class StructTest
{
	static function main()
	{
		trace('  >> Struct Test 1 <<  ');
		var x:MyStruct = new MyStruct();
		x.myInt = 32168;
		x.myString = "Good stuff";
		trace('reading myInt: ' + x.myInt);
		trace('reading myString: ' + x.myString);
		trace('preview: ' + arrayFromBuf(x) + '\n');

		trace('  >> Struct Test 2 <<  ');
		var y:OtherStruct = new OtherStruct();
		y.smallData = Math.round(Math.random() * 0xFFFF - 0x8000);
		y.bigData = Int64.make(Math.round(Math.random() * 0xFFFFFF - 0x800000), Math.round(Math.random() * 0xFFFFFF - 0x800000));
		y.smallFloat = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);
		y.bigFloat = Math.random() * 0xFFFFFF - 0x800000;
		trace('reading smallData: ' + y.smallData);
		trace('reading bigData: ' + y.bigData);
		trace('reading smallFloat: ' + y.smallFloat);
		trace('reading bigFloat: ' + y.bigFloat);
		trace('preview: ' + arrayFromBuf(y) + '\n');

		trace('  >> Struct Test 3 <<  ');
		var z:MegaStruct = new MegaStruct();
		z.a = Math.round(Math.random() * 0xFF);
		z.b = Math.round(Math.random() * 0xFFFF);
		z.c = Math.round(Math.random() * 0xFFFFFF);
		z.d = Int64.make(Math.round(Math.random() * 0xFFFFFF), Math.round(Math.random() * 0xFFFFFF));
		z.e = Math.round(Math.random() * 0xFF - 0x80);
		z.f = Math.round(Math.random() * 0xFFFF - 0x8000);
		z.g = Math.round(Math.random() * 0xFFFFFF - 0x800000);
		z.h = Int64.make(Math.round(Math.random() * 0xFFFFFF - 0x800000), Math.round(Math.random() * 0xFFFFFF - 0x800000));
		z.i = limitPrecision(Math.random() * 0xFFFFFF - 0x800000, 4);
		z.j = Math.random() * 0xFFFFFF - 0x800000;
		z.k = "Very cool";
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

	static inline function arrayFromBuf(buffer:Buffer):Array<UInt>
	{
		var arr = [];
		for (i in 0...buffer.byteLength)
			arr.push(buffer.readUInt8(i));
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