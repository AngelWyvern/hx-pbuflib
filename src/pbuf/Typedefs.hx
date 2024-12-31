package pbuf;

import haxe.Int64;

///////////////////////////// !!! IMPORTANT !!! /////////////////////////////
//                                                                         //
// Due to limitations within Haxe's typing system, these typedefs will NOT //
// represent the exact type based on name alone. They will fallback to the //
// safest compatible type whenever possible (usually `Int`). This means    //
// there is no type safety advantages gained from using these typedefs     //
// outside of checking them in macros and using them in pbuf structs (or   //
// similarly defined macro builders).                                      //
/////////////////////////////////////////////////////////////////////////////

/** Unsigned 8-bit integer (0 – 255) */
typedef UInt8 = Int;
/** Unsigned 16-bit integer (0 – 65535, endianness inferred) */
typedef UInt16 = Int;
/** Unsigned 16-bit integer (0 – 65535, little endian) */
typedef UInt16LE = UInt16;
/** Unsigned 16-bit integer (0 – 65535, big endian) */
typedef UInt16BE = UInt16;
/** Unsigned 32-bit integer (0 – 4294967295, endianness inferred) */
typedef UInt32 = UInt;
/** Unsigned 32-bit integer (0 – 4294967295, little endian) */
typedef UInt32LE = UInt32;
/** Unsigned 32-bit integer (0 – 4294967295, big endian) */
typedef UInt32BE = UInt32;
/** Unsigned 64-bit integer (0 – 18446744073709551615, endianness inferred) */
typedef UInt64 = Int64;
/** Unsigned 64-bit integer (0 – 18446744073709551615, little endian) */
typedef UInt64LE = UInt64;
/** Unsigned 64-bit integer (0 – 18446744073709551615, big endian) */
typedef UInt64BE = UInt64;
/** Signed 8-bit integer (-128 – 127) */
typedef Int8 = Int;
/** Signed 16-bit integer (-32768 – 32767, endianness inferred) */
typedef Int16 = Int;
/** Signed 16-bit integer (-32768 – 32767, little endian) */
typedef Int16LE = Int16;
/** Signed 16-bit integer (-32768 – 32767, big endian) */
typedef Int16BE = Int16;
/** Signed 32-bit integer (-2147483648 – 2147483647, endianness inferred) */
typedef Int32 = Int;
/** Signed 32-bit integer (-2147483648 – 2147483647, little endian) */
typedef Int32LE = Int32;
/** Signed 32-bit integer (-2147483648 – 2147483647, big endian) */
typedef Int32BE = Int32;
/** Signed 64-bit integer (-9223372036854775808 – 9223372036854775807, little endian) */
typedef Int64LE = Int64;
/** Signed 64-bit integer (-9223372036854775808 – 9223372036854775807, big endian) */
typedef Int64BE = Int64;
/** Single-precision (32-bit) floating point number (1.17549e-38 – 3.40282e+38, little endian) */
typedef FloatLE = Float;
/** Single-precision (32-bit) floating point number (1.17549e-38 – 3.40282e+38, big endian) */
typedef FloatBE = Float;
/** Double-precision (64-bit) floating point number (2.22507e-308 – 1.79769e+308, endianness inferred) */
typedef Double = Float;
/** Double-precision (64-bit) floating point number (2.22507e-308 – 1.79769e+308, little endian) */
typedef DoubleLE = Double;
/** Double-precision (64-bit) floating point number (2.22507e-308 – 1.79769e+308, big endian) */
typedef DoubleBE = Double;
/** Unsigned 8-bit length prepended string */
typedef L8String = String;
/** Unsigned 16-bit length prepended string (endianness inferred) */
typedef L16String = String;
/** Unsigned 16-bit length prepended string (little endian) */
typedef L16LEString = L16String;
/** Unsigned 16-bit length prepended string (big endian) */
typedef L16BEString = L16String;
/** Unsigned 32-bit length prepended string (endianness inferred) */
typedef L32String = String;
/** Unsigned 32-bit length prepended string (little endian) */
typedef L32LEString = L32String;
/** Unsigned 32-bit length prepended string (big endian) */
typedef L32BEString = L32String;
/** Null-terminated string */
typedef ZString = String;