function isBlunt(item)
    if not item:isWeapon() then return false end
    for k,v in ipairs(item.subtype.attacks) do
        if v.edged then return false end
    end
    return true
end

eventful=require('plugins.eventful')

eventful.enableEvent(eventful.eventType['ITEM_CREATED'],4)

eventful.onItemCreated.fantasticP=function(item_id)
    local item=df.item.find(item_id)
    --check if item is eligible for this particular function
    if item.flags.artifact and (item:isWeapon() or item:getEffectiveArmorLevel()<2)
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
end
