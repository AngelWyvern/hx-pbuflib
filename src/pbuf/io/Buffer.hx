package pbuf.io;

import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.Encoding;
import haxe.io.FPHelper;
import pbuf.Typedefs;

/**
 * A cross-compatible byte buffer class with extensive features and limited chaining support.
 */
@:forward
abstract Buffer(BufferImpl) from BufferImpl
{
	/**
	 * Allocates a new buffer with the given byte length. 
	 * 
	 * Bytes are not initialized and may not be zero.
	 * Set the `zero` argument to `true` if you need these values to be zeroed out.
	 * 
	 * @param byteLength the amount of bytes to allocate
	 * @param zero if set to true, zeroes out all of the allocated bytes
	 * @return a new `Buffer` object
	 */
	public static inline function alloc(byteLength:UInt, zero:Bool = false):Buffer
	{
		final bytes:Bytes = Bytes.alloc(byteLength);
		if (zero)
			bytes.fill(0, byteLength, 0);
		@:privateAccess return new BufferImpl(bytes);
	}

	/**
	 * Instantiates a `Buffer` instance from existing `Bytes`.
	 * 
	 * @param bytes the `Bytes` object to read data from
	 * @param copy if `true`, allocates a new `Bytes` object with a copy of the data in this buffer, otherwise reuses the `Bytes` internal data
	 * @return a new `Buffer` object
	 */
	public static inline function fromBytes(bytes:Bytes, copy:Bool = true):Buffer
	{
		@:privateAccess return new BufferImpl(copy ? bytes.sub(0, bytes.length) : bytes);
	}

	/** Implicit cast from `haxe.io.Bytes` */
	@:from
	private static inline function fromBytesUnsafe(bytes:Bytes):Buffer
	{
		@:privateAccess return new BufferImpl(bytes);
	}

	/**
	 * Instantiates a `Buffer` instance from a byte array.
	 * 
	 * @param array the array to read data from
	 * @return a new `Buffer` object
	 */
	@:from
	public static inline function fromByteArray(array:Array<UInt8>):Buffer
	{
		final bytes:Bytes = Bytes.alloc(array.length);
		for (i in 0...array.length)
			bytes.set(i, array[i] & 0xFF);
		@:privateAccess return new BufferImpl(bytes);
	}

	/**
	 * Instantiates a `Buffer` representation of the given hexadecimals.
	 * 
	 * Must be a string of even length consisting only of hexadecimal digits.
	 * 
	 * @param hexStr the string containing hexadecimal characters
	 * @return a new `Buffer` object
	 */
	public static inline function fromHex(hexStr:String):Buffer
	{
		@:privateAccess return new BufferImpl(Bytes.ofHex(hexStr));
	}

	/**
	 * Instantiates a `Buffer` representation of the given string.
	 * 
	 * @param str the string to derive the data from
	 * @param encoding the encoding to parse the data with
	 * @return a new `Buffer` object
	 */
	public static inline function fromString(str:String, ?encoding:Encoding = UTF8):Buffer
	{
		@:privateAccess return new BufferImpl(Bytes.ofString(str, encoding));
	}

	/** Implicit cast from `String` */
	@:from
	private static inline function fromStringUTF8(str:String):Buffer
	{
		@:privateAccess return new BufferImpl(Bytes.ofString(str, UTF8));
	}

	/**
	 * Converts this buffer to a `Bytes` object.
	 * 
	 * @param safe if `true`, allocates a new `Bytes` object with a copy of the data in this buffer, otherwise reuses this buffer's internal `Bytes` data
	 * @return the converted `Bytes` object
	 */
	public inline function toBytes(safe:Bool = true):Bytes
	{
		@:privateAccess return safe ? this._buf.sub(0, this._buf.length) : this._buf;
	}

	/** Implicit cast to `haxe.io.Bytes` */
	@:to
	private inline function toBytesUnsafe():Bytes
	{
		@:privateAccess return this._buf;
	}

	/**
	 * Converts this buffer to a byte array.
	 * 
	 * @return a new array of bytes
	 */
	@:to
	public inline function toByteArray():Array<UInt8>
	{
		final array:Array<UInt8> = [];
		@:privateAccess for (i in 0...this._buf.length)
			@:privateAccess array.push(this._buf.get(i));
		return array;
	}

	/**
	 * Converts this buffer to a hexadecimal `String` object.
	 * 
	 * @return the hexadecimal representation of this buffer as a `String`
	 */
	public inline function toHex():String
	{
		@:privateAccess return this._buf.toHex();
	}

	/**
	 * Converts this buffer to a UTF-8 `String` object.
	 * 
	 * @return the UTF-8 representation of this buffer as a `String`
	 */
	@:to
	public inline function toString():String
	{
		@:privateAccess return this._buf.toString();
	}

	/** Alias for array access (getter) */
	@:arrayAccess
	private inline function get(pos:Int):Int
	{
		@:privateAccess var value:Int = this._buf.get(pos);
		this.curPos = pos + 1;
		return value;
	}

	/** Alias for array access (setter) */
	@:arrayAccess
	private inline function set(pos:Int, value:Int):Int
	{
		@:privateAccess this._buf.set(pos, value);
		this.curPos = pos + 1;
		return value;
	}
}

/** Implementation class for `Buffer` */
private class BufferImpl
{
	/** Int64 value of the mathematical equation `2^32 - 1`. */
	@:noCompletion private static var M1:Int64 = Int64.fromFloat(4294967295);

	private var _buf:Bytes = null;

	/** The length (in terms of byte count) of this buffer. */
	public var byteLength(get, never):Int;

	/**
	 * The current read/write head position of the data stream.
	 * 
	 * When the position argument is not specified in data manipulation functions, this
	 * value will be used and will automatically advance the number of bytes read/written.
	 */
	public var curPos:UInt = 0;

	private inline function new(internalBuffer:Bytes)
	{
		_buf = internalBuffer;
	}

	@:noCompletion private inline function get_byteLength():Int
	{
		return _buf.length;
	}

	/**
	 * Copies data from a remote buffer.
	 * 
	 * @param src the buffer to pull data from
	 * @param srcPos where in the source buffer to start reading data from
	 * @param length how many bytes to copy from the source buffer
	 * @param pos where in this buffer to start writing data to
	 */
	public inline function copyFrom(src:Buffer, srcPos:Int, length:Int, ?pos:Int = null):Buffer
	{
		if (pos != null) curPos = pos;
		_buf.blit(curPos, src._buf, srcPos, length);
		curPos += length;
		return this;
	}

	/**
	 * Copies data to a remote buffer.
	 * 
	 * @param target the buffer to write data to
	 * @param pos where in this buffer to start reading data from
	 * @param length how many bytes to copy to the target buffer
	 * @param targetPos where in the target buffer to start writing data to
	 */
	public inline function copyTo(target:Buffer, pos:Int, length:Int, ?targetPos:Int):Buffer
	{
		if (targetPos != null) target.curPos = targetPos;
		target._buf.blit(target.curPos, _buf, pos, length);
		target.curPos += length;
		return this;
	}

	/**
	 * Clones the data of this buffer into a new `Buffer` object.
	 * 
	 * @return the cloned buffer
	 */
	public inline function clone():Buffer
	{
		final b:Buffer = _buf.sub(0, _buf.length);
		b.curPos = curPos;
		return b;
	}

	/**
	 * Compares the data of this buffer to another buffer.
	 * 
	 * @param target the other buffer to compare data to
	 * @return `0` if the data within both buffers are identical, a negative value if the length of this buffer is less than the other buffer, a positive value if the length of this buffer is more than the other buffer, or if the lengths match, a negative value if the first different value in the other buffer is greater than the corresponding value in this buffer, otherwise a positive value
	 */
	public inline function compare(target:Buffer):Int
	{
		return _buf.compare(target._buf);
	}

	/**
	 * Fills the buffer with a given value.
	 * 
	 * @param pos where in the buffer to start writing data
	 * @param length how many bytes to fill in this buffer
	 * @param value what value to fill in this buffer
	 */
	public inline function fill(value:Int, length:Int, ?pos:Int = null):Buffer
	{
		if (pos != null) curPos = pos;
		_buf.fill(curPos, length, value);
		curPos += length;
		return this;
	}

	/**	Reads a boolean value stored in the buffer. */
	public inline function readBool(?pos:Int = null):Bool { return readUInt8(pos) != 0; }

	/** Reads an 8-bit unsigned integer value stored in the buffer. */
	public inline function readUInt8(?pos:Int = null):UInt8 { if (pos != null) curPos = pos; return _buf.get(curPos++); }

	/** Reads a 16-bit unsigned integer value in Little-Endian stored in the buffer. */
	public inline function readUInt16LE(?pos:Int = null):UInt16 { return readUInt8(pos) | (readUInt8() << 8); }
	/** Reads a 16-bit unsigned integer value in Big-Endian stored in the buffer. */
	public inline function readUInt16BE(?pos:Int = null):UInt16 { return (readUInt8(pos) << 8) | readUInt8(); }

	/** Reads a 32-bit unsigned integer value in Little-Endian stored in the buffer. */
	public inline function readUInt32LE(?pos:Int = null):UInt32 { return ((readUInt8(pos)) | (readUInt8() << 8) | (readUInt8() << 16)) + (readUInt8() * 0x1000000); }
	/** Reads a 32-bit unsigned integer value in Big-Endian stored in the buffer. */
	public inline function readUInt32BE(?pos:Int = null):UInt32 { return (readUInt8(pos) * 0x1000000) + ((readUInt8() << 16) | (readUInt8() << 8) | readUInt8()); }

	/** Reads a 64-bit unsigned integer value in Little-Endian stored in the buffer. */
	public inline function readUInt64LE(?pos:Int = null):UInt64 { return Int64.add(Int64.ofInt(readUInt8(pos) + readUInt8() * 0x100 + readUInt8() * 0x10000 + readUInt8() * 0x1000000), Int64.shl(Int64.ofInt(readUInt8() + readUInt8() * 0x100 + readUInt8() * 0x10000 + readUInt8() * 0x1000000), 32)); }
	/** Reads a 64-bit unsigned integer value in Big-Endian stored in the buffer. */
	public inline function readUInt64BE(?pos:Int = null):UInt64 { return Int64.add(Int64.shl(Int64.ofInt(readUInt8(pos) * 0x1000000 + readUInt8() * 0x10000 + readUInt8() * 0x100 + readUInt8()), 32), Int64.ofInt(readUInt8() * 0x1000000 + readUInt8() * 0x10000 + readUInt8() * 0x100 + readUInt8())); }

	/** Reads an 8-bit signed integer value stored in the buffer. */
	public inline function readInt8(?pos:Int = null):Int8 { final value:Int = readUInt8(pos); return (value & 0x80) != 0 ? (0x100 - value) * -1 : value; }

	/** Reads a 16-bit signed integer value in Little-Endian stored in the buffer. */
	public inline function readInt16LE(?pos:Int = null):Int16 { final value:Int = readUInt16LE(pos); return (value & 0x8000) != 0 ? (0x10000 - value) * -1 : value; }
	/** Reads a 16-bit signed integer value in Big-Endian stored in the buffer. */
	public inline function readInt16BE(?pos:Int = null):Int16 { final value:Int = readUInt16BE(pos); return (value & 0x8000) != 0 ? (0x10000 - value) * -1 : value; }

	/** Reads a 32-bit signed integer value in Little-Endian stored in the buffer. */
	public inline function readInt32LE(?pos:Int = null):Int32 { #if (python || lua) final value:Int = #else return #end readUInt8(pos) | (readUInt8() << 8) | (readUInt8() << 16) | (readUInt8() << 24); #if (python || lua) return #if lua lua.Boot.clampInt32 #end((value & 0x80000000 != 0) ? value | 0x80000000 : value); #end }
	/** Reads a 32-bit signed integer value in Big-Endian stored in the buffer. */
	public inline function readInt32BE(?pos:Int = null):Int32 { #if (python || lua) final value:Int = #else return #end (readUInt8(pos) << 24) | (readUInt8() << 16) | (readUInt8() << 8) | readUInt8(); #if (python || lua) return #if lua lua.Boot.clampInt32 #end((value & 0x80000000 != 0) ? value | 0x80000000 : value); #end }

	/** Reads a 64-bit signed integer value in Little-Endian stored in the buffer. */
	public inline function readInt64LE(?pos:Int = null):Int64 { final low:Int = readInt32LE(pos); return Int64.make(readInt32LE(), low); }
	/** Reads a 64-bit signed integer value in Big-Endian stored in the buffer. */
	public inline function readInt64BE(?pos:Int = null):Int64 { final low:Int = readInt32BE(pos); return Int64.make(low, readInt32BE()); }

	/** Reads a single-precision floating point value in Little-Endian stored in the buffer. */
	public inline function readFloatLE(?pos:Int = null):Float { return FPHelper.i32ToFloat(readInt32LE(pos)); }
	/** Reads a single-precision floating point value in Big-Endian stored in the buffer. */
	public inline function readFloatBE(?pos:Int = null):Float { return FPHelper.i32ToFloat(readInt32BE(pos)); }

	/** Reads a double-precision floating point value in Little-Endian stored in the buffer. */
	public inline function readDoubleLE(?pos:Int = null):Double { final low:Int = readInt32LE(pos); return FPHelper.i64ToDouble(low, readInt32LE()); }
	/** Reads a double-precision floating point value in Big-Endian stored in the buffer. */
	public inline function readDoubleBE(?pos:Int = null):Double { final low:Int = readInt32BE(pos); return FPHelper.i64ToDouble(readInt32BE(), low); }

	/** Reads a string value stored in the buffer. */
	public inline function readString(length:Int, ?encoding:Encoding = UTF8, ?pos:Int = null):String { return _buf.getString(RWPosHelper(pos, length), length, encoding); }
	/** Reads a string value with a prepended `UInt8` length stored in the buffer. */
	public inline function readL8String(?encoding:Encoding = UTF8, ?pos:Int = null):L8String { final length:Int = readUInt8(pos); return _buf.getString(RWPosHelper(null, length), length, encoding); }
	/** Reads a string value with a prepended `UInt16LE` length stored in the buffer. */
	public inline function readL16LEString(?encoding:Encoding = UTF8, ?pos:Int = null):L16String { final length:Int = readUInt16LE(pos); return _buf.getString(RWPosHelper(null, length), length, encoding); }
	/** Reads a string value with a prepended `UInt16BE` length stored in the buffer. */
	public inline function readL16BEString(?encoding:Encoding = UTF8, ?pos:Int = null):L16String { final length:Int = readUInt16BE(pos); return _buf.getString(RWPosHelper(null, length), length, encoding); }
	/** Reads a string value with a prepended `UInt32LE` length stored in the buffer. */
	public inline function readL32LEString(?encoding:Encoding = UTF8, ?pos:Int = null):L32String { final length:UInt = readUInt32LE(pos); return _buf.getString(RWPosHelper(null, length), length, encoding); }
	/** Reads a string value with a prepended `UInt32BE` length stored in the buffer. */
	public inline function readL32BEString(?encoding:Encoding = UTF8, ?pos:Int = null):L32String { final length:UInt = readUInt32BE(pos); return _buf.getString(RWPosHelper(null, length), length, encoding); }
	/** Reads a null-terminated string value stored in the buffer. */
	public inline function readZString(?encoding:Encoding = UTF8, ?pos:Int = null):ZString { if (pos == null) pos = curPos; var end:Int = pos; while (_buf.get(end) != 0) ++end; final str:String = _buf.getString(pos, end - pos, encoding); curPos = end + 1; return str; }

	/** Reads multiple 8-bit unsigned integer values stored in the buffer. */
	public inline function readBytes(?length:Int = null, ?pos:Int = null):Array<UInt8> { if (pos != null) curPos = pos; if (length == null || length < 0) length = length == null ? _buf.length - curPos : _buf.length - curPos + length; final array:Array<Int> = []; for (i in curPos...curPos + length) array.push(_buf.get(i)); curPos += length; return array; }

	/** Writes a boolean value to the buffer. */
	public inline function writeBool(value:Bool, ?pos:Int = null):Buffer { writeUInt8(value ? 1 : 0, pos); return this; }

	/** Writes an 8-bit unsigned integer value to the buffer. */
	public inline function writeUInt8(value:UInt8, ?pos:Int = null):Buffer { if (pos != null) curPos = pos; _buf.set(curPos++, value & 0xFF); return this; }

	/** Writes a 16-bit unsigned integer value in Little-Endian to the buffer. */
	public inline function writeUInt16LE(value:UInt16, ?pos:Int = null):Buffer { writeUInt8(value, pos); writeUInt8(value >>> 8); return this; }
	/** Writes a 16-bit unsigned integer value in Big-Endian to the buffer. */
	public inline function writeUInt16BE(value:UInt16, ?pos:Int = null):Buffer { writeUInt8(value >>> 8, pos); writeUInt8(value); return this; }

	/** Writes a 32-bit unsigned integer value in Little-Endian to the buffer. */
	public inline function writeUInt32LE(value:UInt32, ?pos:Int = null):Buffer { writeUInt8(value, pos); writeUInt8(value >>> 8); writeUInt8(value >>> 16); writeUInt8(value >>> 24); return this; }
	/** Writes a 32-bit unsigned integer value in Big-Endian to the buffer. */
	public inline function writeUInt32BE(value:UInt32, ?pos:Int = null):Buffer { writeUInt8(value >>> 24, pos); writeUInt8(value >>> 16); writeUInt8(value >>> 8); writeUInt8(value); return this; }

	/** Writes a 64-bit unsigned integer value in Little-Endian to the buffer. */
	public inline function writeUInt64LE(value:UInt64, ?pos:Int = null):Buffer { final low:Int = Int64.toInt(value & M1); final high:Int = Int64.toInt(value >> 32 & M1); writeUInt32LE(low, pos); writeUInt32LE(high); return this; }
	/** Writes a 64-bit unsigned integer value in Big-Endian to the buffer. */
	public inline function writeUInt64BE(value:UInt64, ?pos:Int = null):Buffer { final low:Int = Int64.toInt(value & M1); final high:Int = Int64.toInt(value >> 32 & M1); writeUInt32BE(high, pos); writeUInt32BE(low); return this; }

	/** Writes an 8-bit signed integer value to the buffer. */
	public inline function writeInt8(value:Int8, ?pos:Int = null):Buffer { if (value < 0) value += 0x100; writeUInt8(value, pos); return this; }

	/** Writes a 16-bit signed integer value in Little-Endian to the buffer. */
	public inline function writeInt16LE(value:Int16, ?pos:Int = null):Buffer { writeUInt8(value, pos); writeUInt8(value >>> 8); return this; }
	/** Writes a 16-bit signed integer value in Big-Endian to the buffer. */
	public inline function writeInt16BE(value:Int16, ?pos:Int = null):Buffer { writeUInt8(value >>> 8, pos); writeUInt8(value); return this; }

	/** Writes a 32-bit signed integer value in Little-Endian to the buffer. */
	public inline function writeInt32LE(value:Int32, ?pos:Int = null):Buffer { writeUInt8(value, pos); writeUInt8(value >>> 8); writeUInt8(value >>> 16); writeUInt8(value >>> 24); return this; }
	/** Writes a 32-bit signed integer value in Big-Endian to the buffer. */
	public inline function writeInt32BE(value:Int32, ?pos:Int = null):Buffer { writeUInt8(value >>> 24, pos); writeUInt8(value >>> 16); writeUInt8(value >>> 8); writeUInt8(value); return this; }

	/** Writes a 64-bit signed integer value in Little-Endian to the buffer. */
	public inline function writeInt64LE(value:Int64, ?pos:Int = null):Buffer { writeInt32LE(value.low, pos); writeInt32LE(value.high); return this; }
	/** Writes a 64-bit signed integer value in Big-Endian to the buffer. */
	public inline function writeInt64BE(value:Int64, ?pos:Int = null):Buffer { writeInt32BE(value.high, pos); writeInt32BE(value.low); return this; }

	/** Writes a single-precision floating point value in Little-Endian to the buffer. */
	public inline function writeFloatLE(value:Float, ?pos:Int = null):Buffer { writeInt32LE(FPHelper.floatToI32(value), pos); return this; }
	/** Writes a single-precision floating point value in Big-Endian to the buffer. */
	public inline function writeFloatBE(value:Float, ?pos:Int = null):Buffer { writeInt32BE(FPHelper.floatToI32(value), pos); return this; }

	/** Writes a double-precision floating point value in Little-Endian to the buffer. */
	public inline function writeDoubleLE(value:Double, ?pos:Int = null):Buffer { writeInt64LE(FPHelper.doubleToI64(value), pos); return this; }
	/** Writes a double-precision floating point value in Big-Endian to the buffer. */
	public inline function writeDoubleBE(value:Double, ?pos:Int = null):Buffer { writeInt64BE(FPHelper.doubleToI64(value), pos); return this; }

	/** Writes a string value to the buffer. */
	public inline function writeString(value:String, ?encoding:Encoding = UTF8, ?pos:Int = null):Buffer { final b:Bytes = Bytes.ofString(value, encoding); _buf.blit(RWPosHelper(pos, b.length), b, 0, b.length); return this; }
	/** Writes a string value to the buffer with its length prepended as a `UInt8`. */
	public inline function writeL8String(value:L8String, ?encoding:Encoding = UTF8, ?pos:Int = null):Buffer { final b:Bytes = Bytes.ofString(value, encoding); writeUInt8(b.length, pos); _buf.blit(RWPosHelper(null, b.length), b, 0, b.length); return this; }
	/** Writes a string value to the buffer with its length prepended as a `UInt16LE`. */
	public inline function writeL16LEString(value:L16String, ?encoding:Encoding = UTF8, ?pos:Int = null):Buffer { final b:Bytes = Bytes.ofString(value, encoding); writeUInt16LE(b.length, pos); _buf.blit(RWPosHelper(null, b.length), b, 0, b.length); return this; }
	/** Writes a string value to the buffer with its length prepended as a `UInt16BE`. */
	public inline function writeL16BEString(value:L16String, ?encoding:Encoding = UTF8, ?pos:Int = null):Buffer { final b:Bytes = Bytes.ofString(value, encoding); writeUInt16BE(b.length, pos); _buf.blit(RWPosHelper(null, b.length), b, 0, b.length); return this; }
	/** Writes a string value to the buffer with its length prepended as a `UInt32LE`. */
	public inline function writeL32LEString(value:L32String, ?encoding:Encoding = UTF8, ?pos:Int = null):Buffer { final b:Bytes = Bytes.ofString(value, encoding); writeUInt32LE(b.length, pos); _buf.blit(RWPosHelper(null, b.length), b, 0, b.length); return this; }
	/** Writes a string value to the buffer with its length prepended as a `UInt32BE`. */
	public inline function writeL32BEString(value:L32String, ?encoding:Encoding = UTF8, ?pos:Int = null):Buffer { final b:Bytes = Bytes.ofString(value, encoding); writeUInt32BE(b.length, pos); _buf.blit(RWPosHelper(null, b.length), b, 0, b.length); return this; }
	/** Writes a null-terminated string value to the buffer. */
	public inline function writeZString(value:ZString, ?encoding:Encoding = UTF8, ?pos:Int = null):Buffer { final b:Bytes = Bytes.ofString(value, encoding); _buf.blit(RWPosHelper(pos, b.length), b, 0, b.length); writeUInt8(0); return this; }

	/** Writes multiple 8-bit unsigned integer values to the buffer. */
	public inline function writeBytes(array:Array<UInt8>, ?pos:Int = null):Buffer { if (pos != null) curPos = pos; for (i in array) _buf.set(curPos++, i & 0xFF); return this; }

	/** Properly handles the position of the read/write head variable `curPos`. */
	@:noCompletion private inline function RWPosHelper(?pos:Int = null, length:Int):Int
	{
		if (pos != null)
		{
			curPos = pos + length;
			return pos;
		}

		final v:Int = curPos;
		curPos += length;
		return v;
	}
}