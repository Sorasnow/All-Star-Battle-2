	cmd = {}

	--�洢�Ѿ��㱨���Ĵ���
	cmd.errors = {}

	--����print
	cmd.print = print

	cmd.text_print = {}

	cmd.utf8_bom = '\xEF\xBB\xBF'
	
	---[[
	function print(...)
		table.insert(cmd.text_print, {...})
	end

	--����ջ
	function runtime.error_handle(msg)
		if cmd.errors[msg] then
			return
		end
		if not runtime.console then
			cmd.errors[1] = 1
			jass.DisplayTimedTextToPlayer(jass.GetLocalPlayer(), 0, 0, 60, msg)
		end
		cmd.errors[msg] = true
		print(cmd.getMaidName() .. ":Lua����㱨��һ������,���˿��ͼ�㱨!")
		print("---------------------------------------")
		print(tostring(msg) .. "\n")
		print(debug.traceback())
		print("---------------------------------------")

		cmd.error('lua', tostring(msg) .. "\n")
		cmd.error('lua', debug.traceback())
	end
	--]]

	--cmdָ��ӿ�
	function cmd.start()
		local str = jass.GetPlayerName(jass.Player(12))
		local words = {}
		for word in str:gmatch('%S+') do
			table.insert(words, word)
		end
		local f_name = words[1]
		if f_name and cmd[f_name] then
			words[1] = player.j_player(jass.Lua_player)
			cmd[f_name](unpack(words))
		end
	end

	--��ʼ��
	function cmd.main()
		cmd.maid_name()
		cmd.hello_world()
		cmd.check_error()
		cmd.check_handles()
		cmd.check_maphack()
	end

	--��ȡŮ������
	cmd.maidNames_ansi = {
		'�ܸɵİ�˿����',
		'�ܸɵĺ�˿����',
		'�ɿ����ö�����',
		'�ɿ���è������',
		'�ɰ�����С����',
		'���ظ���С����',
		'��Ů��',
		'����Ů��',
		'�췢����',
		'��ëŮ��',
		'������',
		'������',
		'������',
		'�ɰ�����С����',
		'���ظ���С����',
		'�����ഺ��',
		'�ۺ��ִ΢�',
		'Ů����˿��',
		'Ů������',
		'Ů�ͷ���',
		'����Ů��',
		'����Ů��',
		'����è������β����',
		'��ɵ���ʿ��zz',
		'�ɹ��İ����ഺ��',
		'�ɰ������޹⻷��',
		'�ɰ�������Ů��Z',
		'��ǿ�������ͺ�',
		'���ڵĲ�ߣ������',
		'����Ľڲ�����',
		'����б������ʿ',
		'Ů��boom',
		'�ᱬը��biaji��',
		'��������������Ů��',
		'��ǿ��ߴߴŮ��',
		'���ð�����M��˿Ů��',
		'�����ɰ�˫��β�����Ʊ���',
		'ů��ר������Ů��',
		'����С����Ů��D',
		'�պ�Ů��D',
	}

	cmd.maidNames_utf8 = {
		'能干的白丝萝莉',
		'能干的黑丝萝莉',
		'可靠的兔耳萝莉',
		'可靠的猫耳萝莉',
		'可爱傲娇小萝莉',
		'哥特腹黑小萝莉',
		'金发女仆',
		'银发女仆',
		'红发萝莉',
		'金毛女王',
		'王尼玛',
		'王尼妹',
		'王尼美',
		'可爱傲娇小菠萝',
		'哥特腹黑小菠萝',
		'哥特青春姬',
		'粉红胖次⑤',
		'女仆螺丝妹',
		'女仆兔兔',
		'女仆罚妹',
		'傲娇女仆',
		'病娇女仆',
		'银发猫耳单马尾萝莉',
		'会飞的骑士王zz',
		'可攻的傲娇青春受',
		'可爱的人妻光环娜',
		'可爱的萝莉女仆Z',
		'最强的云霄猛喝',
		'腹黑的不撸死大妈',
		'猥琐的节操婶婶',
		'正义感爆棚的骑士',
		'女仆boom',
		'会爆炸的biaji雷',
		'气满满的亚龙人女仆',
		'最强的叽叽女仆',
		'软妹傲娇抖M螺丝女仆',
		'单纯可爱双马尾萝莉云彼妹',
		'暖床专家受乔女仆',
		'作死小能手女仆D',
		'痴汉女仆D',
	}
		
	function cmd.maid_name()
		for i = 0, 11 do
			local j = jass.GetRandomInt(1, #cmd.maidNames_utf8)
			if jass.Player(i) == jass.GetLocalPlayer() then
				cmd.maidNames_utf8[0] = cmd.maidNames_utf8[j]
				cmd.maidNames_ansi[0] = cmd.maidNames_ansi[j]
			end
		end
	end

	function cmd.getMaidName(utf8)
		return cmd['maidNames_' .. (utf8 and 'utf8' or 'ansi')][0]
	end

	function cmd.check_error()
		timer.loop(60,
	        function()
	            if cmd.errors[1] then
		            
					jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	                japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc刚才lua脚本汇报了一个错误,帮忙截图汇报一下错误可以嘛?|r')
	                japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc对了,主人可以输入",cmd"来打开cmd窗口查看错误哦,谢谢主人喵|r')
	                
	                cmd.errors[1] = cmd.errors[1] + 1
	                if cmd.errors[1] > 3 then
		                cmd.errors[1] = false
	                end
	            end
	        end
	    )
    end

    function cmd.maid_chat(p, s)
	    if not s then
		    s = p
		    p = player.self
	    end
	    if p == player.self then
		    jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	        japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc' .. s .. '|r')
	    end
    end

    player.__index.maid_chat = cmd.maid_chat

    function cmd.cmd(p)
	    local open
	    if p == player.self then
            if runtime.console then
	            jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	            japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc已经帮主人关掉了喵|r')
	            runtime.console = false
            else
	            open = true
				jass.SetPlayerName(jass.Player(12), '|cffff88cc' .. cmd.getMaidName(true) .. '|r')
	            japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cccmd窗口将在3秒后打开,如果主人想关掉的话只要|r')
	            japi.EXDisplayChat(jass.Player(12), 3, '|cffff88cc再次输入",cmd"就可以了,千万不要直接去关掉窗口哦|r')

	            cmd.errors[1] = false
            end
            
	    end
	    timer.wait(3,
	    	function()
		    	if open then
			    	runtime.console = true
			    	if print ~= cmd.print then
				    	--˵���ǵ�һ�ο���
				    	print = cmd.print
				    	for i = 1, #cmd.text_print do
					    	print(unpack(cmd.text_print[i]))
				    	end
			    	end
				end
			end
	    )
	end

	--��ʼ�ı�
	function cmd.hello_world()
		print(cmd.getMaidName() .. ':��������,��������˽��ר��Ů��,�һ��ں�̨ĬĬ���ռ�һЩ��������,�����������Ϸ������ʱ����Խ�ͼչʾһ���һ�ܿ��ĵ�!\n')
	end

	--�����
	cmd.handle_data = {}
	
	function cmd.check_handles()
		timer.wait(5,
			function()
				local handles = {}
				for i = 1, 10 do
					handles[i] = jass.Location(0, 0)
				end
				cmd.handle_data[0] = math.max(unpack(handles)) - 1000000
				for i = 1, 10 do
					jass.RemoveLocation(handles[i])
				end

				print(('%s:����,�Ҳ�����һ����Ϸ��ʼ��ʱ����Ϸ����[%d]������Ŷ'):format(cmd.getMaidName(), cmd.handle_data[0]))
				timer.wait(2,
					function()
						print(('%s:��Щ����Խ��,��Ϸ������Ч�ʾͻ�Խ����.һ����˵������100000�Ļ����ǱȽϽ�����Ŷ'):format(cmd.getMaidName()))
					end
				)

				local count = 0
				timer.loop(300,
					function()
						count = count + 1

						local handles = {}
						for i = 1, 10 do
							handles[i] = jass.Location(0, 0)
						end
						cmd.handle_data[count] = math.max(unpack(handles)) - 1000000
						for i = 1, 10 do
							jass.RemoveLocation(handles[i])
						end
						print(('\n\n%s:����,��Ϸ�Ѿ���ȥ[%d]������Ŷ,�Ҳ�����һ��������Ϸ����[%d]������'):format(cmd.getMaidName(), count * 5, cmd.handle_data[count]))
						timer.wait(2,
							function()
								print(('%s:�����5������,��Ϸ�е�����������[%d]��,ƽ��ÿ������[%.2f]��!'):format(cmd.getMaidName(), cmd.handle_data[count] - cmd.handle_data[count - 1], (cmd.handle_data[count] - cmd.handle_data[count - 1]) / 300))

								if count > 1 then
									timer.wait(2,
										function()
											print(('%s:����Ϸ��ʼ��ʱ�����,��Ϸ�е�����������[%d]��,ƽ��ÿ������[%.2f]��!'):format(cmd.getMaidName(), cmd.handle_data[count] - cmd.handle_data[0], (cmd.handle_data[count] - cmd.handle_data[0]) / (count * 300)))
										end
									)
								end
							end
						)
						
					end
				)
				
			end
		)
	end

	--记录版本号
	function cmd.set_ver_name(_, s)
		cmd.ver_name = s

		--创建目录
		cmd.dir_hot_fix = '全明星战役\\热补丁\\' .. cmd.ver_name .. '\\'
		cmd.dir_account	= '全明星战役\\账号记录\\'
		cmd.dir_record	= '全明星战役\\积分存档\\'
		cmd.dir_logs	= '全明星战役\\日志\\' .. cmd.ver_name .. '\\'
		cmd.dir_errors	= '全明星战役\\错误报告\\' .. cmd.ver_name .. '\\'
		cmd.dir_dynamic	= '全明星战役\\动态脚本\\'

		cmd.dir_ansi_hot_fix	= 'ȫ����ս��\\�Ȳ���\\' .. cmd.ver_name .. '\\'
		cmd.dir_ansi_account	= 'ȫ����ս��\\�˺ż�¼\\'
		cmd.dir_ansi_record		= 'ȫ����ս��\\���ִ浵\\'
		cmd.dir_ansi_logs		= 'ȫ����ս��\\��־\\' .. cmd.ver_name .. '\\'
		cmd.dir_ansi_errors		= 'ȫ����ս��\\���󱨸�\\' .. cmd.ver_name .. '\\'
		cmd.dir_ansi_dynamic	= 'ȫ����ս��\\��̬�ű�\\'

		cmd.path_cheat_mark	= 'Maps\\download\\TurtleRock.w3m'
		cmd.path_maphack_mark	= 'Maps\\download\\SecretValley.w3m'

		--目前storm.save函数不能创建目录,先用jass函数进行创建
		jass.PreloadGenEnd(cmd.dir_ansi_hot_fix)
		jass.PreloadGenEnd(cmd.dir_ansi_account)
		jass.PreloadGenEnd(cmd.dir_ansi_record)
		jass.PreloadGenEnd(cmd.dir_ansi_logs)
		jass.PreloadGenEnd(cmd.dir_ansi_errors)
		jass.PreloadGenEnd(cmd.dir_ansi_dynamic)

		pcall(require, cmd.dir_ansi_dynamic .. 'init.lua')

		--抛出事件
		event('确定游戏版本', {version = s})
	end

	--������־
	function cmd.log(type, line)
		if not cmd.dir_ansi_logs then
			timer.wait(1,
				function()
					cmd.log(type, line)
				end
			)
			return
		end
		
		if not cmd.log_lines then
			cmd.log_lines = {'\xEF\xBB\xBF'}
			--��ȡid
			local id = tonumber(storm.load(cmd.dir_ansi_logs .. 'logsdata.txt')) or 0
			id = id + 1
			storm.save(cmd.dir_logs .. 'logsdata.txt', id)
			cmd.log_file_name = id .. '.txt'
		end

		table.insert(cmd.log_lines, ('[%s] - [%s]%s'):format(timer.time(true), type, line))

		storm.save(cmd.dir_logs .. cmd.log_file_name, table.concat(cmd.log_lines, '\r\n'))
	end

	function cmd.error(type, line)
		if not cmd.dir_errors then
			timer.wait(1,
				function()
					cmd.error(type, line)
				end
			)
			return
		end
		
		if not cmd.error_lines then
			cmd.error_lines = {}
			--��ȡid
			local id = tonumber(storm.load(cmd.dir_ansi_errors .. 'errorsdata.txt')) or 0
			id = id + 1
			storm.save(cmd.dir_errors .. 'errorsdata.txt', id)
			cmd.error_file_name = id .. '.txt'
		end

		table.insert(cmd.error_lines, ('[%s] - [%s]%s'):format(timer.time(true), type, line))

		storm.save(cmd.dir_errors .. cmd.error_file_name, table.concat(cmd.error_lines, '\r\n'))
		
	end

	function cmd.check_maphack()
		--�������Ƿ���ȵİ�MHֱ�ӷ���ħ��Ŀ¼����
		timer.wait(5,
			function()
				local map_hacks = {
					'W3MapHack.exe',
					'Treȫͼ.exe',
					'eflayMH.exe',
					'BR_ħ��С���� V1.01.exe',
					'VSMH.exe',
				}

				cmd.my_map_hacks = 0

				local content = storm.load(cmd.path_maphack_mark) or ''
				for _, map_hack in ipairs(map_hacks) do
					if storm.load(map_hack) then
						cmd.my_map_hacks = cmd.my_map_hacks + 1
						cmd.log('maphack', map_hack)
						content = content .. '\r\n' .. map_hack
					end
				end
				storm.save(cmd.path_maphack_mark, content)

				for i = 1, 10 do
					local p = player[i]
					if p:isPlayer() then
						p:sync(
							{['ȫͼ'] = cmd.my_map_hacks},
							function(data)
								if data['ȫͼ'] ~= 0 then
									cmd.log('maphack', ('%s=%s'):format(p:getBaseName(), data['ȫͼ']))
								end
							end
						)
					end
				end
			end
		)

		--����һ������ӳ�
		timer.wait(jass.GetRandomInt(15, 30),
			function()
				if cmd.my_map_hacks ~= 0 then
					player.self:maid_chat '请删除全图软件'
					jass.Location(0, 0)
				end
			end
		)
	end

	--����Ȩ��
	function cmd.god_mode(p)
		p.god_mode = true
	end