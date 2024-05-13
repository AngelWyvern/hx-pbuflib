package pbuf.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.ExprTools;

@:dce // Safely remove this class from the final output
class StructBuilder
{
	/**
	 * Generates an abstract structure that can be used in place of `Buffer`s.
	 * 
	 * The fields within a structure are user-defined, and can only be of types compatible with the
	 * `pbuf.io.Buffer` class (i.e. `UInt32BE`, `L16LEString`, etc).
	 * 
	 * All structures use the `pbuf.io.Buffer` class under the hood, allocated to fit the computed
	 * maximum size its fields can hold. Said fields are converted to properties that call the
	 * appropriate `read`/`write` functions with precomputed positions in the same order as the
	 * fields were initially defined.
	 * 
	 * @param inferBE if true, assumes big-endian when endianness is unspecified, otherwise little-endian is assumed
	 * @return a generated structure with embedded functionality to handle all the underlying buffer code
	 */
	public static macro function gen(inferBE:Bool = false):Array<Field>
	{
		final absImpl:ClassType = Context.getLocalClass().get();
		var absInfo:AbstractType;
		switch (absImpl.kind)
		{
			case KAbstractImpl(ref):
				absInfo = ref.get();
			case _:
				Context.fatalError('Structs can only be generated on abstract types with an underlying Buffer type.', Context.currentPos());
		}
		switch (absInfo.type)
		{
			case TInst(t, _):
				var classType = t.get();
				if (classType.name != 'Buffer' || classType.pack.length != 2 || classType.pack[0] != 'pbuf' || classType.pack[1] != 'io')
					Context.fatalError('Structs can only be generated on abstract types with an underlying Buffer type.', Context.currentPos());
			case _:
				Context.fatalError('Structs can only be generated on abstract types with an underlying Buffer type.', Context.currentPos());
		}
		absImpl.meta.add(':dce', [], Context.currentPos()); // Remove abstract definitions if inlining is enabled
		final absPath:ComplexType = TPath({ name:absInfo.name, pack:absInfo.pack });

		var userFields:Array<Field> = Context.getBuildFields();
		var genFields:Array<Field> = [];

		var allocSize:UInt = 0;

		var initArgs:Array<FunctionArg> = [];
		var initExprs:Array<Expr> = [];

		for (uf in userFields)
		{
			switch (uf.kind)
			{
				case FVar(t, e):
					switch (t)
					{
						case TPath(p):
							var inference:String = inferType(p.name, inferBE);
							if (inference == null)
							{
								Context.reportError('Incompatible variable declaration.', uf.pos);
								continue;
							}
							var size:UInt = inferSize(inference);

							var pathname:String = inference, pack:Array<String> = [], sub:Null<String> = null;
							if (inference != 'Bool' && inference != 'String') // Don't fix built-in types
							{
								pathname = 'Typedefs';
								pack = ['pbuf'];
								sub = inference;
							}

							var inferred:ComplexType = TPath({ name:pathname, pack:pack, sub:sub });
							var readFunc:String = 'read$inference';
							var writeFunc:String = 'write$inference';
							var getter:Function =
							{
								args:[],
								expr:macro return this.$readFunc($v{allocSize}),
								ret:inferred
							};
							var setter:Function =
							{
								args:[{ name:'newValue', type:inferred }],
								expr:macro { this.$writeFunc($i{'newValue'}, $v{allocSize}); return $i{'newValue'}; },
								ret:inferred
							};

							if (isStringType(inference))
							{
								for (m in uf.meta)
									if (m.name == 'size')
										size = m.params[0].getValue(); // use user-specified length instead of inferred
								if (inference == 'String')
									getter.expr = macro return this.$readFunc($v{size}, null, $v{allocSize});
								else
									getter.expr = macro return this.$readFunc(null, $v{allocSize});
								setter.expr = macro { this.$writeFunc($i{'newValue'}, null, $v{allocSize}); return $i{'newValue'}; };
							}

							final fieldName:String = uf.name;
							genFields.push(
							{ // Property field
								name:fieldName,
								doc:uf.doc,
								access:[ APublic ],
								meta:uf.meta,
								kind: FProp('get', 'set', inferred),
								pos:uf.pos
							});
							genFields.push(
							{ // Getter field
								name:'get_$fieldName',
								access:[ APrivate, AInline ],
								meta:[{ name:':noCompletion', pos:Context.currentPos() }],
								kind: FFun(getter),
								pos:Context.currentPos()
							});
							genFields.push(
							{ // Setter field
								name:'set_$fieldName',
								access:[ APrivate, AInline ],
								meta:[{ name:':noCompletion', pos:Context.currentPos() }],
								kind: FFun(setter),
								pos:Context.currentPos()
							});

							allocSize += size;

							initArgs.push({ name:fieldName, type:inferred, value:macro null, opt:true });
							initExprs.push(macro if ($i{fieldName} != null) $i{'set_$fieldName'}($i{fieldName}));
						case _:
							Context.reportError('Incompatible variable declaration.', uf.pos);
							continue;
					}
				case _:
					genFields.push(uf);
			}
		}

		initExprs.unshift(macro this = pbuf.io.Buffer.alloc($v{allocSize}));

		genFields.push(
		{ // Constructor field
			name:'new',
			access:[ APublic, AInline ],
			kind:FFun({ args:initArgs, expr:macro $b{initExprs} }),
			pos:Context.currentPos()
		});
		genFields.push(
		{ // From Bytes field
			name:'fromBytes',
			access:[ APublic, AStatic, AInline ],
			meta:[{ name:':from', pos:Context.currentPos() }],
			kind:FFun({ args:[{ name:'bytes', type:macro:haxe.io.Bytes }], expr:macro return cast pbuf.io.Buffer.fromBytes($i{'bytes'}, false), ret:absPath }),
			pos:Context.currentPos()
		});
		genFields.push(
		{ // From Buffer field
			name:'fromBuffer',
			access:[ APublic, AStatic, AInline ],
			meta:[{ name:':from', pos:Context.currentPos() }],
			kind:FFun({ args:[{ name:'buffer', type:macro:pbuf.io.Buffer }], expr:macro return cast $i{'buffer'}, ret:absPath }),
			pos:Context.currentPos()
		});
		genFields.push(
		{ // To Buffer field
			name:'toBuffer',
			access:[ APublic, AInline ],
			meta:[{ name:':to', pos:Context.currentPos() }],
			kind:FFun({ args:[], expr:macro return this, ret:macro:pbuf.io.Buffer }),
			pos:Context.currentPos()
		});
		genFields.push(
		{ // To Bytes field
			name:'toBytes',
			access:[ APublic, AInline ],
			meta:[{ name:':to', pos:Context.currentPos() }],
			kind:FFun({ args:[], expr:macro return this.toBytes(false), ret:macro:haxe.io.Bytes }),
			pos:Context.currentPos()
		});
		return genFields;
	}

	private static inline function inferType(name:String, inferBE:Bool):Null<String>
	{
		var endianness:String = inferBE ? 'BE' : 'LE';
		return switch (name)
		{
			case 'Bool' | 'UInt8' | 'UInt16LE' | 'UInt16BE' | 'UInt32LE' | 'UInt32BE' |
					'UInt64LE' | 'UInt64BE' | 'Int8' | 'Int16LE' | 'Int16BE' | 'Int32LE' |
					'Int32BE' | 'Int64LE' | 'Int64BE' | 'FloatLE' | 'FloatBE' | 'DoubleLE' |
					'DoubleBE' | 'String' | 'L8String' | 'L16LEString' | 'L16BEString' |
					'L32LEString' | 'L32BEString' | 'ZString': name;
			case 'UInt16' | 'UInt32' | 'UInt64' | 'Int16' | 'Int32' | 'Int64' |
					'Float' | 'Double' | 'L16String' | 'L32String': name + endianness;
			case 'UInt' | 'Int': name + '32' + endianness;
			case _: null;
		}
	}

	private static inline function inferSize(type:String):UInt
	{
		return switch (type)
		{
			case 'Bool' | 'UInt8' | 'Int8': 1;
			case 'UInt16LE' | 'UInt16BE' | 'Int16LE' | 'Int16BE': 2;
			case 'UInt32LE' | 'UInt32BE' | 'Int32LE' | 'Int32BE' | 'FloatLE' | 'FloatBE': 4;
			case 'UInt64LE' | 'UInt64BE' | 'Int64LE' | 'Int64BE' | 'DoubleLE' | 'DoubleBE': 8;
			case 'String' | 'L8String' | 'ZString': 256;
			case 'L16LEString' | 'L16BEString': 65536;
			case 'L32LEString' | 'L32BEString': 16777216;
			case _: 0;
		}
	}

	private static inline function isStringType(type:String):Bool
	{
		return type == 'String'
		    || type == 'LString8'
		    || type == 'LString16LE'
		    || type == 'LString16BE'
		    || type == 'LString32LE'
		    || type == 'LString32BE'
		    || type == 'ZString';
	}
}