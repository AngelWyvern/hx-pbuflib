# <p align="center">hx-pbuflib<p><p align="center"><a href="https://lib.haxe.org/p/pbuflib"><img src="https://img.shields.io/badge/available_on-haxelib-EA8220?style=for-the-badge&logo=haxe"/></a> <img src="https://img.shields.io/badge/Version-1.0.0-0080FF?style=for-the-badge"></p>

This is the repository for hx-pbuflib (short for Prototype Buffer Library), a cross-platform Haxe library that expands the capabilities of byte buffers.

Through the use of macros, you can easily create structures without having to directly interface with the buffer code. This can be utilized for quick code writing and easily exchanging data.

## <p align="center">Quick Start</p>

A buffer can be created from a UTF-8 `String`, a `String` of hexadecimals, an existing `haxe.io.Bytes` object, or as we're doing in this example, allocating a specified amount of bytes.

Data can then be manipulated using the `read`/`write` functions within the buffer.

```hx
import pbuf.io.Buffer;

class Main
{
	static function main()
	{
		var buffer:Buffer = Buffer.alloc(16); // allocates 16 bytes of space for this buffer
		buffer.writeInt16LE(24576); // writes a 16-bit integer in little-endian
		buffer.writeString("Hello pbuflib"); // writes a string in the next available space
		trace(buffer.readInt16LE(0)); // read a 16-bit integer in little-endian at position 0
		trace(buffer.readString(13)); // read a string with the length of 13 bytes
	}
}
```

Output:

```
Main.hx:10: 24576
Main.hx:11: Hello pbuflib
```

When manipulating data within the buffer, a position argument may be provided to tell the buffer where in the byte array to read from or write to.

If a position is not given, then an internal tracker (`buffer.curPos`) will be used instead. This tracker is automatically updated after each read/write operation to point directly to the position following the last element that was read from or written to.

### <p align="center">Chaining</p>

The `Buffer` class has limited chaining support. Each `write` function within a buffer can be chained, allowing for swifter coding.

```hx
function example(buffer:Buffer)
{
	buffer
		.writeUInt8(128)
		.writeUInt16LE(16384)
		.writeFloatLE(1234.5678)
		.writeString("Test");
}
```

### <p align="center">Data Structures</p>

If you're working with a lot of varying types of data, structuring can massively speed up your workflow while reducing the rate of encountering bugs along the way.

A struct *(Structure)* is simply an abstract buffer with properties that will automatically read and write the corresponding data when accessed. These properties are automatically populated by a macro that reads a set of variables defined by the user. The macro only supports reading variables that are of types listed in the __Data Types__ section below.

An example of a struct definition:

```hx
import pbuf.Typedefs;
import pbuf.io.Buffer;

@:build(pbuf.macro.StructBuilder.gen())
abstract MyStruct(Buffer)
{
	var myInt:UInt16;
	@size(16) var myString:ZString;
}
```

*(Note: Since strings can be of any size, it is highly recommended that you use the `@size(v)` metadata to prevent allocating an excessive amount of bytes.)*

Now we can use the struct like so:

```hx
var struct:MyStruct = new MyStruct();
struct.myInt = 32168;
struct.myString = "Hello struct";
```

Or we could make it a bit more compact by putting our values directly into the constructor:

```hx
var struct:MyStruct = new MyStruct(32168, "Hello struct");
```

Both code blocks would be equivalent to writing the following:

```hx
var buffer:Buffer = Buffer.alloc(18); // 2 bytes (UInt16) + 16 (specified by @size meta) = 18
buffer.writeUInt16LE(32168, 0); // first var is always at pos 0
buffer.writeZString("Hello struct", null, 2); // last var held 2 bytes, write at pos 2
```

## <p align="center">Reference</p>

### <p align="center">Data Types</p>

|    Type     |                            Description                             |  Endianness   |
|-------------|--------------------------------------------------------------------|---------------|
| Bool        | Binary `true`/`false` value                                        | N/A           |
| UInt8       | Unsigned 8-bit integer (0 - 255)                                   | N/A           |
| UInt16LE    | Unsigned 16-bit integer (0 - 65535)                                | Little-Endian |
| UInt16BE    | *(See above)*                                                      | Big-Endian    |
| UInt32LE    | Unsigned 32-bit integer (0 - 4294967295)                           | Little-Endian |
| UInt32BE    | *(See above)*                                                      | Big-Endian    |
| UInt64LE    | Unsigned 64-bit integer (0 - 18446744073709551615)                 | Little-Endian |
| UInt64BE    | *(See above)*                                                      | Big-Endian    |
| Int8        | Signed 8-bit integer (-128 - 127)                                  | N/A           |
| Int16LE     | Signed 16-bit integer (-32768 - 32767)                             | Little-Endian |
| Int16BE     | *(See above)*                                                      | Big-Endian    |
| Int32LE     | Signed 32-bit integer (-2147483648 - 2147483647)                   | Little-Endian |
| Int32BE     | *(See above)*                                                      | Big-Endian    |
| Int64LE     | Signed 64-bit integer (-9223372036854775808 - 9223372036854775807) | Little-Endian |
| Int64BE     | *(See above)*                                                      | Big-Endian    |
| FloatLE     | Single-precision floating point number                             | Little-Endian |
| FloatBE     | *(See above)*                                                      | Big-Endian    |
| DoubleLE    | Double-precision floating point number                             | Little-Endian |
| DoubleBE    | *(See above)*                                                      | Big-Endian    |
| String      | A sequence of encoded characters                                   | N/A           |
| L8String    | A string value with an unsigned 8-bit integer length prepended     | N/A           |
| L16LEString | A string value with an unsigned 16-bit integer length prepended    | Little-Endian |
| L16BEString | *(See above)*                                                      | Big-Endian    |
| L32LEString | A string value with an unsigned 32-bit integer length prepended    | Little-Endian |
| L32BEString | *(See above)*                                                      | Big-Endian    |
| ZString     | A string value with a null terminator appended                     | N/A           |

*(Note: When writing structs, the endianness (`LE`/`BE`) can optionally be omitted. When omitted, Little-Endian is assumed unless `inferBE` is set to true in the `@:build` function arguments.)*

## <p align="center">Compatibility</p>

### <p align="center">Tested Platforms</p>

**JavaScript**, **HashLink**, **C++**, **C#**, **Python**, and **Lua** were tested and functional. Any untested platforms may have varying results.

### <p align="center">Other Libraries</p>

This library was written to be compatible with any other library that utilizes Haxe's built-in `Bytes` class.

Buffers can be passed to functions as `Bytes` via the `buffer.toBytes()` function. Buffers can also be created from existing `Bytes` objects via the `Buffer.fromBytes(bytes)` function.