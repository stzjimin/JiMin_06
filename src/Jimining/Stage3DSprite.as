package Jimining
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class Stage3DSprite
	{
		/** Cached static lookup of Context3DVertexBufferFormat.FLOAT_2 */
		private static const FLOAT2_FORMAT:String = Context3DVertexBufferFormat.FLOAT_2;
		
		/** Cached static lookup of Context3DVertexBufferFormat.FLOAT_3 */
		private static const FLOAT3_FORMAT:String = Context3DVertexBufferFormat.FLOAT_3;
		
		/** Cached static lookup of Context3DProgramType.VERTEX */
		private static const VERTEX_PROGRAM:String = Context3DProgramType.VERTEX;
		
		/** Cached static lookup of Vector3D.Z_AXIS */
		private static const Z_AXIS:Vector3D = Vector3D.Z_AXIS;
		
		/** Temporary AGAL assembler to avoid allocation */
		private static const tempAssembler:AGALMiniAssembler = new AGALMiniAssembler();
		
		/** Temporary rectangle to avoid allocation */
		private static const tempRect:Rectangle = new Rectangle();
		
		/** Temporary point to avoid allocation */
		private static const tempPoint:Point = new Point();
		
		/** Temporary matrix to avoid allocation */
		private static const tempMatrix:Matrix = new Matrix();
		
		/** Temporary 3D matrix to avoid allocation */
		private static const tempMatrix3D:Matrix3D = new Matrix3D();
		
		/** Cache of positions Program3D per Context3D */
		private static const programsCache:Dictionary = new Dictionary(true);
		
		/** Cache of positions and texture coordinates VertexBuffer3D per Context3D */
		private static const posUVCache:Dictionary = new Dictionary(true);
		
		/** Cache of triangles IndexBuffer3D per Context3D */
		private static const trisCache:Dictionary = new Dictionary(true);
		
		/** Vertex shader program AGAL bytecode */
		private static var vertexProgram:ByteArray;
		
		/** Fragment shader program AGAL bytecode */
		private static var fragmentProgram:ByteArray;
		
		/** 3D context to use for drawing */
		public var ctx:Context3D;
		
		/** 3D texture to use for drawing */
		public var texture:Texture;
		
		/** Width of the created texture */
		public var textureWidth:uint;
		
		/** Height of the created texture */
		public var textureHeight:uint;
		
		/** X position of the sprite */
		public var x:Number = 0;
		
		/** Y position of the sprite */
		public var y:Number = 0;
		
		/** Rotation of the sprite in degrees */
		public var rotation:Number = 0;
		
		/** Scale in the X direction */
		public var scaleX:Number = 1;
		
		/** Scale in the Y direction */
		public var scaleY:Number = 1;
		
		/** Fragment shader constants: U scale, V scale, {unused}, {unused} */
		private var fragConsts:Vector.<Number> = new <Number>[1, 1, 1, 1];
		
		// Static initializer to create vertex and fragment programs
		{
			tempAssembler.assemble(
				Context3DProgramType.VERTEX,
				// Apply draw matrix (object -> clip space)
				"m44 op, va0, vc0\n" +
				
				// Scale texture coordinate and copy to varying
				"mov vt0, va1\n" +
				"div vt0.xy, vt0.xy, vc4.xy\n" +
				"mov v0, vt0\n"
			);
			vertexProgram = tempAssembler.agalcode;
			
			tempAssembler.assemble(
				Context3DProgramType.FRAGMENT,
				"tex oc, v0, fs0 <2d,linear,mipnone,clamp>"
			);
			fragmentProgram = tempAssembler.agalcode;
		}
		
		/**
		 *   Make the sprite
		 *   @param ctx 3D context to use for drawing
		 */
		public function Stage3DSprite(ctx:Context3D): void
		{
			this.ctx = ctx;
			if (!(ctx in trisCache))
			{
				// Create the shader program
				var program:Program3D = ctx.createProgram();
				program.upload(vertexProgram, fragmentProgram);
				programsCache[ctx] = program;
				
				// Create the positions and texture coordinates vertex buffer
				var posUV:VertexBuffer3D = ctx.createVertexBuffer(4, 5);
				posUV.uploadFromVector(
					new <Number>[
						// X,  Y,  Z, U, V
						-1,   -1, 0, 0, 1,
						-1,    1, 0, 0, 0,
						1,    1, 0, 1, 0,
						1,   -1, 0, 1, 1
					], 0, 4
				);
				posUVCache[ctx] = posUV;
				
				// Create the triangles index buffer
				var tris:IndexBuffer3D = ctx.createIndexBuffer(6);
				tris.uploadFromVector(
					new <uint>[
						0, 1, 2,
						2, 3, 0
					], 0, 6
				);
				trisCache[ctx] = tris;
			}
		}
		
		/**
		 *   Set a BitmapData to use as a texture
		 *   @param bmd BitmapData to use as a texture
		 */
		public function set bitmapData(bmd:BitmapData): void
		{
			var width:uint = bmd.width;
			var height:uint = bmd.height;
			
			// Create a new texture if we need to
			if (createTexture(width, height))
			{
				// If the new texture doesn't match the BitmapData's dimensions
				if (width != textureWidth || height != textureHeight)
				{
					// Create a BitmapData with the required dimensions
					var powOfTwoBMD:BitmapData = new BitmapData(
						textureWidth,
						textureHeight,
						bmd.transparent
					);
					
					// Copy the given BitmapData to the newly-created BitmapData
					tempRect.width = width;
					tempRect.height = height;
					powOfTwoBMD.copyPixels(bmd, tempRect, tempPoint);
					
					// Upload the newly-created BitmapData instead
					bmd = powOfTwoBMD;
					
					// Scale the UV to the sub-texture
					fragConsts[0] = textureWidth / width;
					fragConsts[1] = textureHeight / height;
				}
				else
				{
					// Reset UV scaling
					fragConsts[0] = 1;
					fragConsts[1] = 1;
				}
			}
			
			// Upload new BitmapData to the texture
			texture.uploadFromBitmapData(bmd);
		}
		
		/**
		 *   Create the texture to fit the given dimensions
		 *   @param width Width to fit
		 *   @param height Height to fit
		 *   @return If a new texture had to be created
		 */
		protected function createTexture(width:uint, height:uint): Boolean
		{
			width = nextPowerOfTwo(width);
			height = nextPowerOfTwo(height);
			
			if (!texture || textureWidth != width || textureHeight != height)
			{
				texture = ctx.createTexture(
					width,
					height,
					Context3DTextureFormat.BGRA,
					false
				);
				textureWidth = width;
				textureHeight = height;
				return true;
			}
			return false;
		}
		
		/**
		 *   Render the sprite to the 3D context
		 */
		public function render(): void
		{
			tempMatrix3D.identity();
			tempMatrix3D.appendRotation(-rotation, Z_AXIS);
			tempMatrix3D.appendScale(scaleX, scaleY, 1);
			tempMatrix3D.appendTranslation(x, y, 0);
			
			ctx.setProgram(programsCache[ctx]);
			ctx.setTextureAt(0, texture);
			ctx.setProgramConstantsFromMatrix(VERTEX_PROGRAM, 0, tempMatrix3D, true);
			ctx.setProgramConstantsFromVector(VERTEX_PROGRAM, 4, fragConsts);
			ctx.setVertexBufferAt(0, posUVCache[ctx], 0, FLOAT3_FORMAT);
			ctx.setVertexBufferAt(1, posUVCache[ctx], 3, FLOAT2_FORMAT);
			ctx.drawTriangles(trisCache[ctx]);
		}
		
		/**
		 *   Get the next-highest power of two
		 *   @param v Value to get the next-highest power of two from
		 *   @return The next-highest power of two from the given value
		 */
		public static function nextPowerOfTwo(v:uint): uint
		{
			v--;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			v++;
			return v;
		}
	}
}