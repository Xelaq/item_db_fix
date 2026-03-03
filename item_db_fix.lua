local PLUGIN = PLUGIN

PLUGIN.name = "item database fix"
PLUGIN.author = "Xelaq"
PLUGIN.description = "what is this?"

if SERVER then
	hook.Add( "ShutDown", "fix_govno_items", function()
	    for k, ent in ents.Iterator() do 			-- Better, because some items use the OnRemove method for proper functionality
			if (ent:GetClass() == "ix_item" ) then
				ent:Remove()
			end
		end
	end )


	local baseClass = scripted_ents.GetStored("ix_item").t

	function baseClass:OnRemove()

		--if (!ix.shuttingDown and !self.ixIsSafe and self.ixItemID) then
		if (!self.ixIsSafe and self.ixItemID) then
			local itemTable = ix.item.instances[self.ixItemID]

			if (itemTable) then
				if (self.ixIsDestroying) then
					self:EmitSound("physics/cardboard/cardboard_box_break"..math.random(1, 3)..".wav")
					local position = self:LocalToWorld(self:OBBCenter())

					local effect = EffectData()
						effect:SetStart(position)
						effect:SetOrigin(position)
						effect:SetScale(3)
					util.Effect("GlassImpact", effect)

					if (itemTable.OnDestroyed) then
						itemTable:OnDestroyed(self)
					end

					ix.log.Add(self.ixDamageInfo[1], "itemDestroy", itemTable:GetName(), itemTable:GetID())
				end

				if (itemTable.OnRemoved) then
					itemTable:OnRemoved()
				end

				local query = mysql:Delete("ix_items")
					query:Where("item_id", self.ixItemID)
				query:Execute()
			end
		end
	end

	scripted_ents.Register( baseClass, "ix_item" )
end