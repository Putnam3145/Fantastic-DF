function isBlunt(item)
	if not item:isWeapon() then return false end
	for k,v in ipairs(item.subtype.attacks) do
		if v.edged then return true end
	end
	return false
end

eventful=require('plugins.eventful')

eventful.enableEvent('ITEM_CREATED',5)

eventful.onItemCreated.artifactFantasticP=function(item_id)
	local item=df.item.find(item_id)
	--check if item is eligible for this particular function
	if (not item.flags.artifact or not (item:isWeapon() or item:getEffectiveArmorLevel()<2)) then return false end
	local matInfo
	--check if blunt or not; if blunt, set matInfo (defined above) to the blunt artifact mat, else sharp/armor artifact mat
	if isBlunt(item) then
		matinfo=dfhack.matinfo.find('ARTIFACT_BLUNT_P')
	else
		matinfo=dfhack.matinfo.find('ARTIFACT_SHARP_ARMOR_P')
	end
	item:setMaterial(matInfo.type)
	item:setMaterialIndex(matinfo.index)
end