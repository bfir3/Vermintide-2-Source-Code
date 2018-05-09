ExplosiveBarrelHealthExtension = class(ExplosiveBarrelHealthExtension, GenericHealthExtension)

ExplosiveBarrelHealthExtension.init = function (self, extension_init_context, unit, extension_init_data)
	ExplosiveBarrelHealthExtension.super.init(self, extension_init_context, unit, extension_init_data)

	self.in_hand = extension_init_data.in_hand
	self.item_name = extension_init_data.item_name
	local data = extension_init_data.health_data

	if data then
		self.ignited = true
		self.explode_time = data.explode_time
		self.fuse_time = data.fuse_time
		self.instaexplode = not self.in_hand

		Unit.flow_event(unit, "exploding_barrel_fuse_init")
	end

	local owner_unit = extension_init_data.owner_unit

	if owner_unit then
		self.owner_unit = owner_unit
		self.owner_unit_health_extension = ScriptUnit.extension(owner_unit, "health_system")
		self.ignored_damage_types = extension_init_data.ignored_damage_types
	end
end

ExplosiveBarrelHealthExtension.update = function (self, dt, context, t)
	local owner_unit_health_extension = self.owner_unit_health_extension

	if owner_unit_health_extension then
		local recent_damages, num_damages = owner_unit_health_extension.recent_damages(owner_unit_health_extension)

		for i = 1, num_damages / DamageDataIndex.STRIDE, 1 do
			local j = (i - 1) * DamageDataIndex.STRIDE
			local attacker_unit = recent_damages[j + DamageDataIndex.ATTACKER]
			local damage_amount = recent_damages[j + DamageDataIndex.DAMAGE_AMOUNT]
			local damage_type = recent_damages[j + DamageDataIndex.DAMAGE_TYPE]
			local ignore_damage_type = self.ignored_damage_types[damage_type]

			if not ignore_damage_type then
				if damage_type == "heal" then
					self.add_heal(self, attacker_unit, -damage_amount, nil, "n/a")
				else
					local hit_zone_name = recent_damages[j + DamageDataIndex.HIT_ZONE]
					local damage_direction = Vector3Aux.unbox(recent_damages[j + DamageDataIndex.DIRECTION])
					local damage_source_name = recent_damages[j + DamageDataIndex.DAMAGE_SOURCE_NAME]

					self.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name)
				end
			end
		end
	end

	if self.ignited and not self._dead and not self.exploded then
		local network_time = Managers.state.network:network_time()
		local fuse_time_left = self.explode_time - network_time
		local fuse_time_percent = fuse_time_left / self.fuse_time

		Unit.set_data(self.unit, "fuse_time_percent", fuse_time_percent)

		if self.explode_time <= network_time then
			self.instaexplode = true

			self.add_damage(self, self.unit, self.health, "full", "undefined", Vector3(0, 0, -1))
		elseif not self.in_hand and not self.instaexplode and self.instaexplode_time <= network_time then
			self.instaexplode = true
		elseif not self.played_fuse_out and self.explode_time - 1.2 <= network_time then
			Unit.flow_event(self.unit, "exploding_barrel_fuse_out")

			self.played_fuse_out = true
		end
	end
end

ExplosiveBarrelHealthExtension.add_damage = function (self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike)
	if 0 < damage_amount and self.damage < self.health and not self.ignited then
		local unit = self.unit
		local network_time = Managers.state.network:network_time()
		local fuse_time = (Unit.has_data(unit, "fuse_time") and Unit.get_data(unit, "fuse_time")) or 4
		local instaexplode_time = network_time + 0.2
		local enemies_ignore_fuse = Unit.get_data(unit, "enemies_ignore_fuse")
		local explode_time = network_time + fuse_time

		Unit.flow_event(unit, "exploding_barrel_fuse_init")

		self.fuse_time = fuse_time
		self.explode_time = explode_time
		self.ignited = true
		self.instaexplode_time = instaexplode_time
	elseif self.health <= self.damage then
		self.exploded = true

		if self.ignited and not self.played_fuse_out then
			Unit.flow_event(self.unit, "exploding_barrel_remove_fuse")
		end
	end

	damage_amount = (self.instaexplode and damage_amount) or 0

	ExplosiveBarrelHealthExtension.super.add_damage(self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit, hit_react_type, is_critical_strike)
end

ExplosiveBarrelHealthExtension.health_data = function (self)
	local data = {
		fuse_time = self.fuse_time,
		explode_time = self.explode_time
	}

	return data
end

return
