local _, ns = ...

local playerClass = select(2, UnitClass('player'))
local cfg = ns.Config
local page

if cfg.ActionbarPaging[playerClass] then
	page = cfg.ActionbarPaging[playerClass]
else
	return;
end

local F = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate') 
F:Hide()

for i = 1,12 do 
	F:SetFrameRef('ActionButton'..i,_G['ActionButton'..i]) 
end

F:Execute(	[[btn = table.new() 
				for i=1,12 do 
					btn[i]=self:GetFrameRef('ActionButton'..i)
				end]])
F:SetAttribute('_onstate-mod', [[for _,b in pairs(btn) do 
									b:SetAttribute('actionpage',newstate)
								end]])
RegisterStateDriver(F, 'mod', page)