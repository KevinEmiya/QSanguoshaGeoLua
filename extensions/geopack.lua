module("extensions.geopack", package.seeall)
extension = sgs.Package("geopack")

jisheng = sgs.General(extension, "jisheng", "geo", 4, true)

--Skills of jisheng
--品位
Pinwei = sgs.CreateViewAsSkill{
	name = "Pinwei",
	n = 1,
	view_filter = function(self, selected, to_select)
		if #selected > 0 then return false end
		local card = to_select
		local judge_peach = card:isKindOf("EquipCard") and card:isRed()
		local judge_analeptic = card:isKindOf("Weapon") and card:isBlack()
		
		local usereason = sgs.Sanguosha:getCurrentCardUseReason()
		if usereason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			return judge_peach or judge_analeptic
		elseif (usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE) or (usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if string.find(pattern, "analeptic") then
				return judge_analeptic or judge_peach
			elseif string.find(pattern, "peach") then
				return judge_peach
			else
				return false
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local originalCard = cards[1]
		if originalCard:isRed() then
			local peach = sgs.Sanguosha:cloneCard("peach", originalCard:getSuit(), originalCard:getNumber())
			peach:addSubcard(originalCard)
			peach:setSkillName(self:objectName())
			return peach
		elseif originalCard:isBlack() then
			local analeptic = sgs.Sanguosha:cloneCard("analeptic", originalCard:getSuit(), originalCard:getNumber())
			analeptic:addSubcard(originalCard)
			analeptic:setSkillName(self:objectName())
			return analeptic
		else
			return nil
		end
	end,
	enabled_at_play = function(self, target)
		return true
	end, 
	enabled_at_response = function(self, target, pattern)
		return string.find(pattern, "peach") or string.find(pattern, "analeptic")
	end
}

--绝杀
JueshaCard = sgs.CreateSkillCard{
	name = "JueshaCard",
	target_fixed = true,
	will_throw = true, 
	on_effect = function(self, effect)
	end
}

JueshaVS = sgs.CreateViewAsSkill{
	name = "Juesha",
	n = 1,
	view_filter = function(self, selected, to_select)
		local card = to_select
		return ((card:isKindOf("Weapon") and card:isBlack()) or card:isKindOf("Analeptic")) and (not sgs.Self:isJilei(to_select))
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local juesha_card = JueshaCard:clone()
			juesha_card:addSubcard(cards[1])
			return juesha_card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, target, pattern)
		return pattern == "@@Juesha"
	end
}

Juesha = sgs.CreateTriggerSkill{
	name = "Juesha",
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.Dying},
	view_as_skill = JueshaVS, 
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		local _player = dying.who
		local damage = dying.damage
		if _player:getHp() < 1 then
			if player:canDiscard(player, "he") then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					 if room:askForUseCard(player, "@@Juesha", "@juesha-card", -1, sgs.Card_MethodNone) then
						room:killPlayer(_player, damage)
					 end
				end
			end
		end
		return false
	end,
}
---End of Skills of jisheng

jisheng:addSkill(Pinwei)
jisheng:addSkill(Juesha)

sgs.LoadTranslationTable{
	["geo"] = "基",
	["geopack"] = "基包",
	["jisheng"] = "张继盛",
	["#jisheng"] = "品位帝",
	["Pinwei"] = "品位",
	[":Pinwei"] = "你可以将红色的装备牌当作桃，黑色的武器牌当作酒使用",
	["Juesha"] = "绝杀",
	["juesha"] = "绝杀",
	[":Juesha"] = "任意角色进入濒死状态时，你可以弃置一张酒令其立即死亡。",
	["@juesha-card"] = "请弃置一张【酒】",
	["~Juesha"] = "选择一张【酒】-确定",
	["designer:jisheng"] = "洩矢の呼啦圈"
}
		