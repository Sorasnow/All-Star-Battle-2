	w3x2txt = {}

	local w3x2txt = w3x2txt

	local function main()
		--读取内部类型
		local meta_list	= {}

		meta_list.default	= {
			type	= 'string',
		}
		
		setmetatable(meta_list,
			{
				__index = function(_, id)
					return rawget(meta_list, 'default')
				end
			}
		)

		function w3x2txt.readMeta(file_name)
			local content	= io.load(file_name)
			if not content then
				print('文件无效:' .. file_name:string())
				return
			end

			for line in content:gmatch '[^\n\r]+' do
				local id	= line:match [[C;.*X1;.*K"(.-)"]]
				if id then
					meta_list.id	= id
					meta_list[id]	= {}
					goto continue
				end
				local x, value	= line:match [[C;X(%d+);K["]*(.-)["]*$]]
				if x then
					if meta_list.id == 'ID' then
						meta_list[x]	= value
					elseif meta_list[x] == 'type' then
						meta_list[meta_list.id].type	= value
					elseif meta_list[x] == 'data' then
						meta_list[meta_list.id].data	= value
					end
				end
				:: continue ::
			end
		end

		local index

		--string.pack/string.unpack的参数
		local data_type_format	= {}
		data_type_format[0]	= 'l'	--4字节有符号整数
		data_type_format[1] = 'f'	--4字节无符号浮点
		data_type_format[2] = 'f'	--4字节有符号浮点
		data_type_format[3] = 'z'	--以\0结尾的字符串

		setmetatable(data_type_format,
			{
				__index	= function(_, i)
					print(i, ('%x'):format(index - 2))
				end
			}
		)

		local value_type = {
			int			= 'int',
			bool		= 'int',
			unreal		= 'unreal',
			real		= 'real',
			deathType	= 'int',
			attackBits	= 'int',
			teamColor	= 'int',
			fullFlags	= 'int',
			channelType	= 'int',
			channelFlags= 'int',
			stackFlags	= 'int',
			silenceFlags= 'int',
			spellDetail	= 'int',
		}
		setmetatable(value_type,
			{
				__index	= function()
					return 'string'
				end,
			}
		)

		--将值根据内部类型转化为txt
		local function value2txt(value, id)
			local type	= meta_list[id].type
			if type == 'real' or type == 'unreal' then
				value = ('%.4f'):format(value)
			end
			return value
		end

		--将txt的值根据内部类型转化
		local function txt2value(value, id)
			local type	= value_type[meta_list[id].type]
			if type == 'int' then
				return value, 0
			elseif type == 'real' then
				return value, 1
			elseif type == 'unreal' then
				return value, 2
			end
			return value, 3
		end

		function w3x2txt.obj2txt(file_name_in, file_name_out, has_level)
			local content	= io.load(file_name_in)
			if not content then
				print('文件无效:' .. file_name_in:string())
				return
			end

			index = 1
			
			local len	= #content
			local lines	= {}

			local ver
			
			local chunks = {}
			local chunk, objs, obj, datas, data

			--解析方法
			local funcs	= {}

			--解析数据头
			function funcs.readHead()
				ver, index	= ('l'):unpack(content, index)

				funcs.next	= funcs.readChunk
			end

			--解析块
			function funcs.readChunk()
				chunk	= {}
				objs	= {}
				chunk.objs	= objs

				chunk.obj_count, index	= ('l'):unpack(content, index)

				table.insert(chunks, chunk)

				funcs.next	= funcs.readObj
			end

			--解析物体
			function funcs.readObj()
				obj	= {}
				datas	={}
				obj.datas	= datas
				obj.origin_id, obj.id, obj.data_count, index	= ('c4c4l'):unpack(content, index)
				if obj.id == '\0\0\0\0' then
					obj.id	= obj.origin_id
				end

				table.insert(objs, obj)

				if obj.data_count > 0 then
					funcs.next	= funcs.readData
				else
					--检查是否将这个chunk中的数据读完了
					if #objs == chunk.obj_count then
						funcs.next	= funcs.readChunk
						return
					end
					funcs.next	= funcs.readObj
				end
			end

			--解析数据
			function funcs.readData()
				data	= {}
				data.id, data.type, index	= ('c4l'):unpack(content, index)

				--是否包含等级信息
				if has_level then
					data.level, _, index	= ('ll'):unpack(content, index)
					if data.level == 0 then
						data.level	= nil
					end
				end
				
				data.value, index	= data_type_format[data.type]:unpack(content, index)
				data.value	= value2txt(data.value, data.id)
				index	= index + 4	--忽略掉后面4位的标识符

				table.insert(datas, data)

				--检查是否将这个obj中的数据读完了
				if #datas == obj.data_count then
					--检查是否将这个chunk中的数据读完了
					if #objs == chunk.obj_count then
						funcs.next	= funcs.readChunk
						return
					end
					funcs.next	= funcs.readObj
					return
				end
			end

			funcs.next	= funcs.readHead

			--开始解析
			repeat
				funcs.next()
			until index >= len or not funcs.next

			--转换文本
			--版本
			table.insert(lines, ('%s=%s'):format('VERSION', ver))
			for _, chunk in ipairs(chunks) do
				--chunk标记
				table.insert(lines, '[CHUNK]')
				for _, obj in ipairs(chunk.objs) do
					--obj的id
					if obj.id == obj.origin_id then
						table.insert(lines, ('[%s]'):format(obj.id))
					else
						table.insert(lines, ('[%s:%s]'):format(obj.id, obj.origin_id))
					end
					for _, data in ipairs(obj.datas) do
						--数据项
						local line = {}
						--数据id
						table.insert(line, data.id)
						--数据等级
						if data.level then
							table.insert(line, ('[%d]'):format(data.level))
						end
						table.insert(line, '=')
						--数据值
						table.insert(line, data.value)
						table.insert(lines, table.concat(line))
					end
				end
			end

			io.save(file_name_out, table.concat(lines, '\n'))

		end

		function w3x2txt.txt2obj(file_name_in, file_name_out, has_level)
			local content	= io.load(file_name_in)
			if not content then
				print('文件无效:' .. file_name_in:string())
				return
			end

			local pack = {}
			local chunks, chunk, objs, obj, datas, data
			local funcs
			funcs	= {
				--版本号
				function (line)
					pack.ver	= line:match 'VERSION%=(.+)'
					if pack.ver then
						chunks	= {}
						pack.chunks	= chunks
						table.remove(funcs, 1)
						return true
					end
				end,

				--块
				function (line)
					local obj_count	= line:match '^%s*%[%s*CHUNK%s*%]%s*$'
					if obj_count then
						chunk	= {}
						objs	= {}
						chunk.objs	= objs

						chunk.obj_count	= obj_count

						table.insert(chunks, chunk)
						return true
					end
				end,

				--当前obj的id
				function (line)
					local str	= line:match '^%s*%[%s*(.-)%s*%]%s*$'
					if not str then
						return
					end

					obj	= {}
					datas	= {}
					obj.datas	= datas

					obj.id, obj.origin_id	= str:match '^%s*(.-)%s*%:%s*(.-)%s*$'
					if not obj.id then
						obj.id, obj.origin_id	= str, str
					end

					table.insert(objs, obj)

					return true
				end,

				--当前obj的data
				function (line)
					local _, last, id	= line:find '^%s*(.-)%s*%='
					if not id then
						return
					end

					data = {}

					--检查是否包含等级信息
					if has_level then
						data.level	= id:match '%[(%d+)%]'
						id	= id:sub(1, 4)
					end

					data.id, data.value	= id, line:sub(last + 1):match '^%s*(.*)$'
					data.value, data.type	= txt2value(data.value, data.id)
					data.value	= data_type_format[data.type]:pack(data.value)

					table.insert(datas, data)

					return true
				end,
			}

			--解析文本
			for line in content:gmatch '[^\n\r]+' do
				for _, func in ipairs(funcs) do
					if func(line) then
						break
					end
				end
			end

			--生成2进制文件
			local hexs	= {}
			--版本
			table.insert(hexs, ('l'):pack(pack.ver))
			for _, chunk in ipairs(pack.chunks) do
				--obj数量
				table.insert(hexs, ('l'):pack(#chunk.objs))
				for _, obj in ipairs(chunk.objs) do
					--obj的id与数量
					if obj.origin_id == obj.id then
						obj.id	= '\0\0\0\0'
					end
					table.insert(hexs, ('c4c4l'):pack(obj.origin_id, obj.id, #obj.datas))
					for _, data in ipairs(obj.datas) do
						--data的id与类型
						table.insert(hexs, ('c4l'):pack(data.id, data.type))
						--data的等级与分类
						if has_level then
							table.insert(hexs, ('ll'):pack(data.level or 0, meta_list[data.id].data or 0))
						end
						--data的内容
						table.insert(hexs, data.value)
						--添加一个结束标记
						table.insert(hexs, '\0\0\0\0')
					end
				end
			end

			io.save(file_name_out, table.concat(hexs))
		end
	end

	main()
	
	return w3x2txt