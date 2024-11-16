local b = peripheral.find("meBridge")
local ccs = require("cc.strings")
local ccs_ew = ccs.ensure_width

function retrieve()
    craftForBook()
    local list = getItemListFromLectern()
    local lut = getDisplayNameLut()
    
    print("Retrieving items...")
    sleep(0.2)
    for dn,count in pairs(list) do
        if lut[dn] then
            count = tonumber(count)
            local id = lut[dn]
            local moved, err = b.exportItem(
                {name=id,count=count},
                "up"
            )
            if err ~= nil then
                print("Failed to retrieve item: "..err)
            end
        end
    end
    print("Done")
end

function craftForBook()
    local list = getItemListFromLectern()
    local lut = getDisplayNameLut()
    
    local toCraft = {n=0}
    local cantCraft = {n=0}
    
    for dn,count in pairs(list) do
        count = tonumber(count)
        if lut[dn] == nil then
            cantCraft[dn] = count
            cantCraft.n = cantCraft.n + 1
        else
            local id = lut[dn]
            local existing = getItemCount(id)
            if count > existing then
                toCraft[id] = count - existing
                toCraft.n = toCraft.n + 1
            end
        end
    end
    
    term.clear()
    term.setCursorPos(1,1)
    if cantCraft.n > 0 then
        print("Cannot craft some items:\n")
        sleep(0.5)
        require("cc.pretty").pretty_print(cantCraft)
        print("\nPress enter to proceed (You will need to make these yourself)")
        read()
    end
    
    if toCraft.n > 0 then
        term.clear()
        term.setCursorPos(1,1)
        print("Going to craft:\n")
        require("cc.pretty").pretty_print(toCraft)
        print("\nPress enter to proceed")
        read()
    
        for name,count in pairs(toCraft) do
            if name == "n" then goto skip end
            write("Crafting "..count.." of "..name.."...")
            craftItem(name, count)
            print("  Done")
            ::skip::
        end
    end
end

function craftItem(id, count)
    local bool, err = b.craftItem(
        {name = id, count = count}
    )
    if not bool then
        return false, err
    end
    sleep(0.5)
    while b.isItemCrafting(
        {name = id}
    ) do
        sleep(0.05)
    end
    return true
end

function getItemCount(id)
    local r, err = b.getItem(
        {name = id}
    )
    if r == nil then
        error(err)
    else
        return r.amount
    end
end

function getItemListFromLectern()
    local lectern = peripheral.find("minecraft:lectern")
    if lectern == nil then error("No lectern connected") end
    sleep(0.1)
    if not lectern.hasBook() then error("Lectern does not contain a book\n(Sometimes it does this even when the lectern does contain a book, just try again in that case)") end
    
    local listOut = {}
    
    sleep(0.1)
    local text = lectern.getText()
    for _, pageText in pairs(text) do
        for name, count in pageText:gmatch(
            "(.-)\n x([0-9]+).-\n"
        ) do
            if name:sub(-1,-1) == "?" then
                -- this is a ticked entry, ignore
            else
                listOut[name] = count
            end
        end
    end
    
    return listOut
end

function getDisplayNameLut()
    -- run through stored items
    local l, err = b.listItems()
    if l == nil then error(err) end
    local lut = {}
    for k,v in pairs(l) do
        local id = v.name
        local dn = v.displayName
        if lut[dn] ~= false then
            if lut[dn] ~= nil and lut[dn] ~= v.name then
                -- there are multiple items with the
                -- same display name
                lut[dn] = false
            else
                lut[dn] = id
            end
        end
    end
    -- run through craftable items
    local cl, err = b.listCraftableItems()
    if cl == nil then error(err) end
    for k,v in pairs(cl) do
        local id = v.name
        local dn = v.displayName
        if lut[dn] ~= false then
            if lut[dn] ~= nil and lut[dn] ~= v.name then
                lut[dn] = false
            else
                lut[dn] = id
            end
        end
    end
    
    for k,v in pairs(lut) do
        if v == false then
            lut[k] = nil
        end
    end
    return lut
end

function list(args)
    local l, err = b.listItems()
    if l == nil then
        error(err)
    end
    pattern = ".*"
    if type(args[2]) == "string" then
        pattern = args[2]
    end
    for k,v in pairs(l) do
        local n = v.name:lower()
        local dn = v.displayName:lower()
        local ic = ""
        if v.isCraftable then ic = "*" end
        if n:match(pattern) or dn:match(pattern) then
            print(
                ccs_ew(tostring(v.amount), 6)..
                " - "..
                v.displayName..
                " "..
                ic
            )
        end
    end
end

retrieve()
