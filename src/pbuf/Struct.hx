package pbuf;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.ExprTools;
using StringTools;

@:dce // Safely remove this class from the final output
class Struct
{
	/**
	 * Makes an abstract structure that can be used in place of `Buffer`s.
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
	public static macro function make(inferBE:Bool = false):Array<Field>
	{
		final impl:ClassType = Context.getLocalClass().get();
		var info:AbstractType;
		switch (impl.kind)
		{
			case KAbstractImpl(ref):
				info = ref.get();
			case _:
				Context.fatalError('Structs can only be generated on abstract types with an underlying Buffer type.', Context.currentPos());
		}
		switch (info.type)
		{
			case TAbstract(t, _):
				var underType:AbstractType = t.get();
				if (underType.name != 'Buffer' || underType.pack.length != 2 || underType.pack[0] != 'pbuf' || underType.pack[1] != 'io')
					Context.fatalError('Structs can only be generated on abstract types with an underlying Buffer type.', Context.currentPos());
			case _:
				Context.fatalError('Structs can only be generated on abstract types with an underlying Buffer type.', Context.currentPos());
		}
		impl.meta.add(':dce', [], Context.currentPos()); // Remove abstract definitions if inlining is enabled
		final absPath:ComplexType = getAbstractTPath(info);

		final superFunc:String = '_super';

		var userFields:Array<Field> = Context.getBuildFields();
		var genFields:Array<Field> =
		[
			{
				name:superFunc,
				access:[ APrivate, AInline ],
				meta:[{ name:':noCompletion', pos:Context.currentPos() }],
				kind:FFun({ args:[], expr:macro return this }),
				pos:Context.currentPos()
			}
		];

		var allocSize:UInt = 0;

		var initArgs:Array<FunctionArg> = [];
		var initExprs:Array<Expr> = [];

		function parseField(field:Field, layers:Array<String>, ?outFields:Array<Field>)
		{
			if (outFields == null)
				outFields = genFields;

			switch (field.kind)
			{
				case FVar(t, e):
					switch (t)
					{
						case TPath(p):
							var format:String = formatTypePath(p);
							var inference:String = inferType(format, inferBE);
							if (inference == null)
							{
								Context.reportError('Incompatible variable type declaration: $format', field.pos);
								return;
							}

							var size:UInt = inferSize(inference);
							var builtin:Bool = inference == 'Bool' || inference == 'String';
							var inferred:ComplexType = TPath(builtin ? { pack:[], name:inference } : { pack:['pbuf'], name:'Typedefs', sub:inference }); // Don't fix built-in types

							var readFunc:String = 'read$inference';
							var writeFunc:String = 'write$inference';
							var getter:Function =
							{
								args:[],
								expr:macro return $i{superFunc}().$readFunc($v{allocSize}),
								ret:inferred
							};
							var setter:Function =
							{
								args:[{ name:'newValue', type:inferred }],
								expr:macro { $i{superFunc}().$writeFunc($i{'newValue'}, $v{allocSize}); return $i{'newValue'}; },
								ret:inferred
							};

							if (isStringType(inference))
							{
								for (m in field.meta)
									if (m.name == 'size')
										size = m.params[0].getValue(); // use user-specified length instead of inferred
								if (inference == 'String')
									getter.expr = macro return $i{superFunc}().$readFunc($v{size}, null, $v{allocSize});
								else
									getter.expr = macro return $i{superFunc}().$readFunc(null, $v{allocSize});
								setter.expr = macro { $i{superFunc}().$writeFunc($i{'newValue'}, null, $v{allocSize}); return $i{'newValue'}; };
							}

							outFields.push(
							{	// Property field
								name:field.name,
								doc:field.doc,
								access:[ APublic ],
								meta:field.meta,
								kind:FProp('get', 'set', inferred),
								pos:field.pos
							});
							outFields.push(
							{	// Getter field
								name:'get_${field.name}',
								access:[ APrivate, AInline ],
								meta:[{ name:':noCompletion', pos:Context.currentPos() }],
								kind:FFun(getter),
								pos:Context.currentPos()
							});
							outFields.push(
							{	// Setter field
								name:'set_${field.name}',
								access:[ APrivate, AInline ],
								meta:[{ name:':noCompletion', pos:Context.currentPos() }],
								kind:FFun(setter),
								pos:Context.currentPos()
							});

							allocSize += size;

							if (layers.length <= 0)
							{
								initArgs.push({ name:field.name, type:inferred, value:macro null, opt:true });
								initExprs.push(macro if ($i{field.name} != null) $i{'set_${field.name}'}($i{field.name}));
							}
							else
							{
								final cmbName:String = '${layers.join('__')}__${field.name}', fieldPath:Array<String> = layers.copy();
								fieldPath.push(field.name);
								initArgs.push({ name:cmbName, type:inferred, value:macro null, opt:true });
								initExprs.push(macro if ($i{cmbName} != null) $p{fieldPath} = $i{cmbName});
							}
						case TAnonymous(subFields):
							layers.push(field.name);

							var cf:Array<Field> =
							[
								{
									name:'new',
									access:[ APrivate, AInline ],
									kind:FFun(
									{
										args:[{ name:'_this', type:absPath }],
										expr:macro this = $i{'_this'}
									}),
									pos:Context.currentPos()
								},
								{
									name:superFunc,
									access:[ APrivate, AInline ],
									meta:[{ name:':noCompletion', pos:Context.currentPos() }],
									kind:FFun({ args:[], expr:macro @:privateAccess return this.$superFunc() }),
									pos:Context.currentPos()
								}
							];

							for (af in subFields)
								parseField(af, layers.copy(), cf);

							var cdef:TypeDefinition =
							{
								name:'${info.name}__subfield__${layers.join('__')}',
								meta:
								[
									{ name:':noCompletion', pos:Context.currentPos() },
									{ name:':dce', pos:Context.currentPos() } // Remove abstract definitions if inlining is enabled
								],
								kind:TDAbstract(absPath),
								fields:cf,
								pack:info.pack,
								pos:Context.currentPos()
							};
							var cpath:TypePath = { name:cdef.name, pack:cdef.pack };

							Context.defineType(cdef);

							outFields.push(
							{	// Property field
								name:field.name,
								doc:field.doc,
								access:[ APublic ],
								meta:field.meta,
								kind:FProp('get', 'never', TPath(cpath)),
								pos:field.pos
							});
							outFields.push(
							{	// Getter field
								name:'get_${field.name}',
								access:[ APrivate, AInline ],
								meta:[{ name:':noCompletion', pos:Context.currentPos() }],
								kind:FFun(
								{
									args:[],
									expr:macro @:privateAccess return new $cpath(this),
									ret:TPath(cpath)
								}),
								pos:Context.currentPos()
							});
						case _:
							Context.reportError('Incompatible variable declaration.', field.pos);
					}
				case _:
					Context.reportError('Incompatible field declaration.', field.pos);
			}
		}

		for (uf in userFields)
			parseField(uf, []);

		initExprs.unshift(macro this = pbuf.io.Buffer.alloc($v{allocSize}));

		genFields.push(
		{	// Constructor field
			name:'new',
			access:[ APublic, AInline ],
			kind:FFun({ args:initArgs, expr:macro $b{initExprs} }),
			pos:Context.currentPos()
		});
		genFields.push(
		{	// From Bytes field
			name:'fromBytes',
			access:[ APublic, AStatic, AInline ],
			meta:[{ name:':from', pos:Context.currentPos() }],
			kind:FFun({ args:[{ name:'bytes', type:macro:haxe.io.Bytes }], expr:macro return cast pbuf.io.Buffer.fromBytes($i{'bytes'}, false), ret:absPath }),
			pos:Context.currentPos()
		});
		genFields.push(
		{	// From Buffer field
			name:'fromBuffer',
			access:[ APublic, AStatic, AInline ],
			meta:[{ name:':from', pos:Context.currentPos() }],
			kind:FFun({ args:[{ name:'buffer', type:macro:pbuf.io.Buffer }], expr:macro return cast $i{'buffer'}, ret:absPath }),
			pos:Context.currentPos()
		});
		genFields.push(
		{	// To Buffer field
			name:'toBuffer',
			access:[ APublic, AInline ],
			meta:[{ name:':to', pos:Context.currentPos() }],
			kind:FFun({ args:[], expr:macro return this, ret:macro:pbuf.io.Buffer }),
			pos:Context.currentPos()
		});
		genFields.push(
		{	// To Bytes field
			name:'toBytes',
			access:[ APublic, AInline ],
			meta:[{ name:':to', pos:Context.currentPos() }],
			kind:FFun({ args:[], expr:macro return this.toBytes(false), ret:macro:haxe.io.Bytes }),
			pos:Context.currentPos()
		});
		return genFields;
	}

	private static inline function getAbstractTPath(info:AbstractType):ComplexType
	{
		final current:String = info.module.split('.').pop();
		if (current == info.name)
			return TPath({ name:info.name, pack:info.pack });
		return TPath({ name:current, pack:info.pack, sub:info.name });
	}

	private static inline function formatTypePath(path:TypePath):String
	{
		var sbuf:String = path.name;
		if (path.pack.length > 0)
			sbuf = path.pack.join('.') + '.$sbuf';
		if (path.sub != null)
			sbuf += '.${path.sub}';
		return sbuf;
	}

	private static inline function inferType(name:String, inferBE:Bool):Null<String>
	{
		if (name.startsWith('pbuf.Typedefs.')) name = name.substr(14);
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
			case 'String' | 'L8String' | 'L16LEString' | 'L16BEString' | 'L32LEString' |
					'L32BEString' | 'ZString': 256;
			case _: 0;
		}
	}

	private static inline function isStringType(type:String):Bool
	{
		return type == 'String'
		    || type == 'L8String'
		    || type == 'L16StringLE'
		    || type == 'L16StringBE'
		    || type == 'L32StringLE'
		    || type == 'L32StringBE'
		    || type == 'ZString';
	}
}