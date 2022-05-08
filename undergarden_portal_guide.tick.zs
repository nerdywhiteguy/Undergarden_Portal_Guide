/**	Turn obituaries into something so that you aren't just stuck with a useless item.
 *	That rather creepy something will guide you to the Undergarden, if you're willing to go along with what it asks of you.
 */

import crafttweaker.api.data.MapData;
import crafttweaker.api.data.IData;
import crafttweaker.api.data.INumberData;
import crafttweaker.api.item.IIngredient;
import crafttweaker.api.item.IItemStack;
import crafttweaker.api.item.MCItemDefinition;
import crafttweaker.api.inventory.IInventory;
import crafttweaker.api.tag.MCTag;
import crafttweaker.api.server.MCServer;
import crafttweaker.api.events.CTEventManager;
import crafttweaker.api.entity.AttributeOperation;
import crafttweaker.api.entity.MCEntity;
import crafttweaker.api.entity.MCEntityType;
import crafttweaker.api.entity.MCItemEntity;
import crafttweaker.api.entity.MCLivingEntity;
import crafttweaker.api.player.MCPlayerEntity;
import crafttweaker.api.world.MCServerWorld;
import crafttweaker.api.world.MCWorld;
import crafttweaker.api.util.BlockPos;
import crafttweaker.api.util.MCHand;
import crafttweaker.api.util.Random;
import crafttweaker.api.util.text.MCStyle;
import crafttweaker.api.util.text.MCTextComponent;
import crafttweaker.api.loot.conditions.LootConditionBuilder;
import crafttweaker.api.loot.conditions.crafttweaker.Not;
import crafttweaker.api.loot.conditions.vanilla.EntityProperties;
import crafttweaker.api.loot.conditions.vanilla.KilledByPlayer;
import crafttweaker.api.loot.modifiers.CommonLootModifiers;
import crafttweaker.api.predicate.TargetedEntity;
import stdlib.List;

CTEventManager.register<crafttweaker.api.event.tick.MCPlayerTickEvent>((event) => {
	val player = event.player as MCPlayerEntity;
	val world = player.world as MCWorld;
	if world.isRemote() || (UNDER_PLOT.initial_setup_run && (world.gameTime % 20 != 0) || event.start) {
		return; // If we're on the client instead of server OR (initial setup was run AND we're not at an even 20 ticks aka 1 second) OR we're at the start instead of the end of the event (so we don't get called twice each tick) THEN return without doing anything.
	}
	val server = world.asServerWorld().server as MCServer;
	if !UNDER_PLOT.initial_setup_run {
		server.executeCommand("gamerule sendCommandFeedback false");
		server.executeCommand("scoreboard objectives add TouchedBook trigger");
		UNDER_PLOT.initial_setup_run = true;
		return;
	}
	val inventory = player.getInventory();
	val BOOK_LEVEL_PLAYER = UNDER_PLOT.getBookLevel(player);
	val BOOK_LEVEL_WORLD = UNDER_PLOT.getBookLevel(world);
	val BOOK_LEVEL_BOTH = int.max(BOOK_LEVEL_PLAYER, BOOK_LEVEL_WORLD);
	if BOOK_LEVEL_BOTH == (UNDER_PLOT.MARKED_LEVEL - 1) { // FIXME: "-1" throws weird syntax errors. Only "- 1" works.
		if server.executeCommand("clear @a[scores={TouchedBook=1}] minecraft:written_book{undertome:3}") {
			server.executeCommand("give @a[scores={TouchedBook=1}] written_book{undertome:" + UNDER_PLOT.CATALYST_LEVEL + ", pages:['[\"\",{\"text\":\"I\\'m sorry.\",\"color\":\"aqua\"},{\"text\":\"\\\\n\\\\nI did not realize \",\"color\":\"reset\"},{\"text\":\"the effect\",\"color\":\"dark_red\"},{\"text\":\" would be \",\"color\":\"reset\"},{\"text\":\"so strong\",\"color\":\"dark_blue\"},{\"text\":\". However, \",\"color\":\"reset\"},{\"text\":\"you are strong\",\"color\":\"dark_green\"},{\"text\":\". Yes, that did not really harm you, did it?\\\\n\\\\nNo, of course not. Besides, you feel the boon as well, do you not?\",\"color\":\"reset\"}]','[\"\",{\"text\":\"It will be worth the sacrifice in the end. You shall see! I will teach you how to \"},{\"text\":\"find \",\"obfuscated\":true},{\"text\":\"me\",\"obfuscated\":true,\"color\":\"dark_red\"},{\"text\":\". \",\"color\":\"reset\"},{\"text\":\"I will teach you how to find the under world. \",\"color\":\"dark_blue\"},{\"text\":\"You will find the lost garden\",\"color\":\"dark_green\"},{\"text\":\". You will \",\"color\":\"reset\"},{\"text\":\"open the door\",\"obfuscated\":true},{\"text\":\", and the garden will see light (true light) for the first time in \",\"color\":\"reset\"},{\"text\":\"10,000 years\",\"obfuscated\":true},{\"text\":\".\",\"color\":\"reset\"}]','[\"\",{\"text\":\"Now, the most difficult part will be to create the \"},{\"text\":\"Catalyst\",\"color\":\"aqua\"},{\"text\":\".\\\\n\\\\nI only say that because some people consider \",\"color\":\"reset\"},{\"text\":\"diamonds\",\"color\":\"dark_aqua\"},{\"text\":\" to be hard to come by.\\\\n\\\\nYou will also need \",\"color\":\"reset\"},{\"text\":\"iron\",\"color\":\"gray\"},{\"text\":\" and \",\"color\":\"reset\"},{\"text\":\"gold\",\"color\":\"gold\"},{\"text\":\", but those are even more trivial.\",\"color\":\"reset\"}]','[\"\",{\"text\":\"Place the diamond in \"},{\"text\":\"the center\",\"color\":\"dark_aqua\"},{\"text\":\".\\\\n\\\\nPlace an iron ingot on each of it\\'s \",\"color\":\"reset\"},{\"text\":\"four cardinal directions\",\"color\":\"gray\"},{\"text\":\".\\\\n\\\\nPlace a gold ingot in each of \",\"color\":\"reset\"},{\"text\":\"the four corners\",\"color\":\"gold\"},{\"text\":\".\",\"color\":\"reset\"}]','[\"\",{\"text\":\"Like so:\\\\n\\\\n\"},{\"text\":\" / \",\"color\":\"gold\"},{\"text\":\"/\",\"color\":\"gray\"},{\"text\":\" /\",\"color\":\"gold\"},{\"text\":\"\\\\n\",\"color\":\"reset\"},{\"text\":\" / \",\"color\":\"gray\"},{\"text\":\"O\",\"color\":\"dark_aqua\"},{\"text\":\" /\",\"color\":\"gray\"},{\"text\":\"\\\\n\",\"color\":\"reset\"},{\"text\":\" / \",\"color\":\"gold\"},{\"text\":\"/\",\"color\":\"gray\"},{\"text\":\" /\",\"color\":\"gold\"},{\"text\":\"\\\\n\\\\nSimple enough, yes?\",\"color\":\"reset\"}]'],title:\"§bApologetic Tome\",author:\"§4your friend ♥♥♥\",display:{Lore:[\"{\\\"text\\\":\\\"What was that‽ Did you just §kempower that monster‽ WHY‽\\\",\\\"color\\\":\\\"yellow\\\",\\\"italic\\\":false}\",\"{\\\"text\\\":\\\"YES, THAT WAS ME. I THRIVE ON YOUR POWER.\\\",\\\"color\\\":\\\"dark_red\\\",\\\"italic\\\":false,\\\"obfuscated\\\":true}\",\"{\\\"text\\\":\\\"Look, I'm sorry. But that's in the past now, so lets just move on, yeah?\\\",\\\"color\\\":\\\"dark_red\\\",\\\"italic\\\":false}\"]}}");
			server.executeCommand("effect give @a[scores={TouchedBook=1}] minecraft:nausea 18 1 false");
			server.executeCommand("effect give @a[scores={TouchedBook=1}] minecraft:instant_damage 1 1 false");
			server.executeCommand("effect give @a[scores={TouchedBook=1}] minecraft:poison 5 1 false");
			server.executeCommand("effect give @a[scores={TouchedBook=1}] undergarden:gooey 12 2 true");
			server.executeCommand("effect give @a[scores={TouchedBook=1}] minecraft:haste 600 1 true");
			server.executeCommand("effect give @a[scores={TouchedBook=1}] minecraft:luck 300 1 true");
			server.executeCommand("effect give @a[scores={TouchedBook=1}] minecraft:glowing 30 1 true");
			server.executeCommand("tellraw @a[scores={TouchedBook=1}] {\"text\":\"Your life force rapidly drains away!\",\"color\":\"dark_red\"}");
			server.executeCommand("playsound undergarden:ambient.abyss_mood ambient @a " + UNDER_PLOT.positionCommand(player) + " 1 1");
			server.executeCommand("playsound undergarden:block.undergarden_portal_ambient block @a " + UNDER_PLOT.positionCommand(player) + " 1 1");
			server.executeCommand("playsound undergarden:entity.brute_angry hostile @a " + UNDER_PLOT.positionCommand(player) + " 1 1");
			server.executeCommand("playsound undergarden:entity.dweller_death neutral @a " + UNDER_PLOT.positionCommand(player) + " 1 1");
			server.executeCommand("scoreboard players reset @a TouchedBook");
		} else {
			server.executeCommand("execute in " + world.dimension + " run scoreboard players reset @a[" + UNDER_PLOT.positionTargetMax(player, 2) + "] TouchedBook");
			server.executeCommand("execute in " + world.dimension + " run scoreboard players enable @a[" + UNDER_PLOT.positionTargetMax(player, 2) + "] TouchedBook");
		}
	}
	if BOOK_LEVEL_PLAYER >= UNDER_PLOT.MARKED_LEVEL {
		if player.data.contains(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) {
			// Mark any player holding a high level book.
			var tag as MapData = (player.data.getAt(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
			tag.put("undertome", UNDER_PLOT.MARKED_LEVEL);
		}
		switch UNDER_PLOT.counter {
			case 19:
				player.sendStatusMessage(MCTextComponent.createStringTextComponent("Something…").setStyle(<formatting:yellow>), true);
				break;
			case 29:
				player.sendStatusMessage(MCTextComponent.createStringTextComponent("…is…").setStyle(<formatting:red>), true);
				break;
			case 39:
				player.sendStatusMessage(MCTextComponent.createStringTextComponent("…alive!").setStyle(<formatting:dark_red>), true);
				break;
		}
		if UNDER_PLOT.counter % 10 == 8 {
			server.executeCommand("playsound undergarden:entity.forgotten_guardian_living hostile @a " + UNDER_PLOT.positionCommand(player) + " " + (UNDER_PLOT.counter/40.0) + " 0.1");
		}
	} else {
		if BOOK_LEVEL_WORLD >= UNDER_PLOT.MARKED_LEVEL && BOOK_LEVEL_WORLD <= 7 {
			if UNDER_PLOT.getBookLevel(world.getEntitiesInArea(player.getPosition().add(-20,-20,-20), player.getPosition().add(20,20,20))) > 3 {
				switch UNDER_PLOT.counter {
					case 19:
						player.sendStatusMessage(MCTextComponent.createStringTextComponent("Something…").setStyle(<formatting:yellow>), true);
						break;
					case 29:
						player.sendStatusMessage(MCTextComponent.createStringTextComponent("…is…").setStyle(<formatting:red>), true);
						break;
					case 39:
						player.sendStatusMessage(MCTextComponent.createStringTextComponent("…alive!").setStyle(<formatting:dark_red>), true);
						break;
				}
			}
		} else {
			UNDER_PLOT.counter = 0;
		}
	}
	if BOOK_LEVEL_BOTH == UNDER_PLOT.CATALYST_LEVEL && UNDER_PLOT.hasItem(player, <item:undergarden:catalyst>) && UNDER_PLOT.replaceEverywhere(player, UNDER_PLOT.BOOK_TESTS[UNDER_PLOT.MAX_TEST_LEVEL - UNDER_PLOT.CATALYST_LEVEL], UNDER_PLOT.BOOK_AFTER_CATALYST) > 0 {
		server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(player) + " 0.5 0.5");
	} else if BOOK_LEVEL_BOTH == UNDER_PLOT.FRAME_LEVEL && inventory.count(UNDER_PLOT.PORTAL_FRAME_ITEMS) >= 10 {
		UNDER_PLOT.replaceEverywhere(player, UNDER_PLOT.BOOK_TESTS[UNDER_PLOT.MAX_TEST_LEVEL - UNDER_PLOT.FRAME_LEVEL], UNDER_PLOT.BOOK_AFTER_FRAME);
		server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(player) + " 0.5 0.5");
	} else if BOOK_LEVEL_BOTH >= UNDER_PLOT.MARKED_LEVEL {
		if BOOK_LEVEL_WORLD >= 8 {
			if player.data.contains(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) {
				// If the Underrider has spawned, unmark any player in range.
				var tag as MapData = (player.data.getAt(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
				tag.remove("undertome");
			}
			// Only process loaded entities and only within a considerable distance.
			val entities as MCEntity[] = (world.asServerWorld()).getEntities( (entity as MCEntity) => (entity.world.isLoaded(entity.position) && (entity.getDistance(player) as double < 450)) ) as MCEntity[];
			for entity in entities {
				if entity.data.contains(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) {
					var tag as MapData = (entity.data.getAt(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
					if tag.contains("undertome") {
						val level as int = tag.getAt("undertome").asNumber() as int;
						if level >= 8 {
							if entity.data.contains("PortalCooldown") && ((entity.data.getAt("PortalCooldown").asNumber() as int) > 0) {
								// PortalCooldown is used as a countdown to various triggers.
								// While still ticking downwards, certain things happen.
								if level == 11 && entity.data.contains("Age") && ((entity.data.getAt("Age").asNumber() as int) < 0) {
									// While the Undercat has a negative age (aka "is a kitten"),
									// spawn minions at it's location.
									UNDER_PLOT.newEntity(
										UNDER_PLOT.newEntity(world, entity.getPosition(), <entitytype:minecraft:creeper>,
											{ ExplosionRadius: 2
											, Fuse: 60
											, PortalCooldown: UNDER_PLOT.MINION_RIDE_TIME
											, ForgeData:
												{ undertome: 8
												, NoLootUnlessKilledByPlayer: 1
												}
											}
										)
									,
										<entitytype:minecraft:stray>
									,
										{ PersistenceRequired: 1
										, ForgeData:
											{ undertome: 9
											, NoLootUnlessKilledByPlayer: 1
											}
										, PortalCooldown: UNDER_PLOT.MINION_TIME
										, HandItems:
											[
												{ id: UNDER_PLOT.UNDERBOW_NAME
												, tag: UNDER_PLOT.UNDERBOW_NBT
												, Count: 1
												}
											]
										, HandDropChances:
											[ 0.075f
											, 0.0f
											]
										, ArmorItems:
											[
												{}
											,
												{}
											,
												{}
											,
												{ Count: 1
												, id: "player_head"
												}
											]
										, ArmorDropChances:
											[ 0.0f
											, 0.0f
											, 0.0f
											, 0.0f
											]
										} as IData
									);
								} else if level == 10 && entity is MCLivingEntity {
									// If the Underrider hasn't stolen your catalyst yet, he does so.
									// This cast was bugged. But Jared did a lot of work and fixed it! Thanks Jared!
									var entityLiving = entity as MCLivingEntity;
									var tool = UNDER_PLOT.popItem(player, <item:undergarden:catalyst>);
									if tool.commandString != "<item:minecraft:air>" {
										entityLiving.setHeldItem(MCHand.OFF_HAND, tool);
										// FIXME: Won't work if still riding the Undercat. Need a way to access the entity being ridden.
										entityLiving.teleportKeepLoaded(player.positionVec.x, player.positionVec.y, player.positionVec.z);
										entityLiving.setLastAttackedEntity(player);
										entityLiving.attackEntityAsMob(player);
										tag.put("undertome", 13);
										val ascentionEffectTarget = UNDER_PLOT.ascentionTarget(entity);
										server.executeCommand("tellraw @a[" + ascentionEffectTarget + "] {\"text\":\"I'll take that, thank you.\",\"color\":\"dark_red\"}");
										server.executeCommand("tellraw @a[" + ascentionEffectTarget + "] {\"text\":\"Don't let it have that! You need to kill it! Kill it before it kills you all!\",\"color\":\"yellow\",\"bold\":true}");
									}
								} else {
									var pos = entity.position.up(); // ensure it's not suffocating
									if !<block:minecraft:air>.matchesBlock(world.getBlockState(pos)) {
										// Look for two continuous blocks of air above the entity.
										// Note that pos is being modified IN THE CONDITION.
										while !( world.isAir(pos = pos.up()) ) && !( world.isAir(pos = pos.up()) ) {
											if pos.y > UNDER_PLOT.ESCAPE_HEIGHT {
												break;
											}
										}
										entity.teleportKeepLoaded(pos.x, pos.y, pos.z);
									}
								}
							} else {
								// Once PortalCooldown hits zero…
								if level == 13 || level == 10 {
									// The Underrider starts ascending.
									server.executeCommand("/effect give @e[nbt={ForgeData:{undertome:13}}] minecraft:levitation 100000 5");
									tag.put("undertome", 14);
								} else if level == 14 {
									// Ensure th Underrider has a clear path up into the sky.
									val ascentionEffectTarget = UNDER_PLOT.ascentionTarget(entity);
									var pos = entity.position.up(2);
									if !<block:minecraft:air>.matchesBlock(world.getBlockState(pos)) {
										server.executeCommand("tellraw @a[" + ascentionEffectTarget + "] {\"text\":\"I rise… I rise… I RISE! [I_RISE_I_RISE]\",\"color\":\"dark_red\",\"obfuscated\":true}");
										// Look for two continuous blocks of air above the entity.
										// Note that pos is being modified IN THE CONDITION.
										while !( <block:minecraft:air>.matchesBlock(world.getBlockState(pos = pos.up())) ) && !( <block:minecraft:air>.matchesBlock(world.getBlockState(pos = pos.up())) ) {
											if pos.y > UNDER_PLOT.ESCAPE_HEIGHT {
												break;
											}
										} // Teleport him into the next available free space if he's being blocked.
										entity.teleportKeepLoaded(pos.x, pos.y, pos.z);
									} else {
										// If he should have a clear path, make sure he isn't stuck on the lip of a block or something
										if UNDER_PLOT.last_tick % 1000 == 0 {
											// by randomly giving him some velicity every now and again.
											entity.addVelocity(world.random.nextDouble(-3,3), -world.random.nextDouble(-1,0), world.random.nextDouble(-3,3));
										}
										// Generate some arcane looking voodo to print to the screen.
										val cmd as string = ("tellraw @a[" + ascentionEffectTarget + "] {\"text\":\"[") as string;
										for i in 0 .. 8 {
											cmd += world.random.nextInt(15);
											if world.random.nextInt(5) == 0 {
												if world.random.nextBoolean() {
													cmd += ",";
												} else {
													cmd += " ";
												}
											}
										}
										cmd = (cmd + "]\",\"color\":\"dark_red\",\"obfuscated\":true}") as string;
										server.executeCommand(cmd);
									}
									if pos.y >= UNDER_PLOT.ESCAPE_HEIGHT {
										// The Underrider has ascended. Strike EVERYTHING with lightning.
										server.executeCommand("execute at @e[" + ascentionEffectTarget + "] run summon lightning_bolt ~ ~ ~");
										// Summon a column of fireworks.
										var y = 10;
										while (y += 1) < UNDER_PLOT.ESCAPE_HEIGHT {
											UNDER_PLOT.newEntity(world, entity.position.x, y, entity.position.z, <entitytype:minecraft:firework_rocket>,
												{ "LifeTime": 0
												, "FireworksItem":
													{ id: "firework_rocket"
													, Count: 1
													, tag:
														{ Fireworks:
															{ Flight: 0
															, Explosions:
																[ {Type:1,Flicker:1,Trail:1,Colors:[11743532],FadeColors:[3887386,2437522]}
																, {Type:2,Flicker:1,Trail:1,Colors:[3887386,2437522],FadeColors:[11743532]}
																]
															}
														}
													}
												}
											);
										}
										server.executeCommand("tellraw @a[" + ascentionEffectTarget + "] {\"text\":\"You fool! What have you done‽\",\"color\":\"yellow\"}");
										//entity.onKillCommand();
										entity.remove();
										// Make it thunder and lightning for two minutes to hopefully douse any fires the lightning started.
										server.executeCommand("weather thunder 120");
									}
								} else {
									//entity.onKillCommand();
									if level == 9 { // Give despawning minions some fanfare.
										UNDER_PLOT.newEntity(world, entity.positionVec, <entitytype:minecraft:firework_rocket>,
											{ "LifeTime": 0
											, "FireworksItem":
												{ id: "firework_rocket"
												, Count: 1
												, tag:
													{ Fireworks:
														{ Flight: 0
														, Explosions:
															[ {Type:2,Flicker:1,Trail:1,Colors:[3887386,2437522],FadeColors:[11743532]}
															//, {Type:1,Flicker:1,Trail:1,Colors:[11743532],FadeColors:[3887386,2437522]}
															]
														}
													}
												}
											}
										);
									}
									entity.remove();
								}
							}
						}
					}
				}
			}
		} else if world.dimension == "minecraft:overworld" {
			var foundPortal as bool = false;
			var portalPosition = player.getPosition();
			val x_flip = world.random.nextBoolean() ? 1 : -1; // The purpose of these variables is to randomize which side of the portal
			val z_flip = world.random.nextBoolean() ? 1 : -1; // (or which portal, if there are more than one) that the Underrider will spawn in.
			for x in (-UNDER_PLOT.PORTAL_DETECT_DISTANCE.x) .. (UNDER_PLOT.PORTAL_DETECT_DISTANCE.x) {
				for y in (-UNDER_PLOT.PORTAL_DETECT_DISTANCE.y) .. UNDER_PLOT.PORTAL_DETECT_DISTANCE.y {
					for z in (-UNDER_PLOT.PORTAL_DETECT_DISTANCE.z) .. (UNDER_PLOT.PORTAL_DETECT_DISTANCE.z) {
						if <block:undergarden:undergarden_portal>.matchesBlock(world.getBlockState(portalPosition.add(x_flip * x, y, z_flip * z))) {
							foundPortal = true;
							portalPosition = player.getPosition().add(x_flip * x, y, z_flip * z);
							break;
						}
					}
					if foundPortal {
						break;
					}
				}
				if foundPortal {
					break;
				}
			}
			if foundPortal {
				world.destroyBlock(portalPosition, false);
				var portalBase = portalPosition.down();
				while <block:undergarden:undergarden_portal>.matchesBlock(world.getBlockState(portalBase)) {
					world.destroyBlock(portalBase, false);
					portalBase = portalBase.down();
				}
				var portalTop = portalPosition.up();
				while <block:undergarden:undergarden_portal>.matchesBlock(world.getBlockState(portalTop)) {
					world.destroyBlock(portalTop, false);
					portalTop = portalTop.up();
				}
				UNDER_PLOT.newEntity(world, portalBase.x + 0.5, portalBase.y + 1, portalBase.z + 0.5, <entitytype:minecraft:firework_rocket>,
					{ "LifeTime": 0
					, "FireworksItem":
						{ id: "firework_rocket"
						, Count: 1
						, tag:
							{ Fireworks:
								{ Flight: 0
								, Explosions:
									[ {Type:1,Flicker:1,Trail:1,Colors:[11743532],FadeColors:[3887386,2437522]}
									, {Type:2,Flicker:1,Trail:1,Colors:[3887386,2437522],FadeColors:[11743532]}
									]
								}
							}
						}
					}
				);
				UNDER_PLOT.newEntity(
					UNDER_PLOT.newEntity(world, portalBase.up(), <entitytype:minecraft:cat>,
						{ CustomName: "{\"text\":\"Undercat\",\"obfuscated\":true,\"color\":\"dark_red\"}"
						, Age: -UNDER_PLOT.SUMMON_TIME
						, CatType: 10
						, CollarColor: 13
						, ForgeData:
							{ undertome: 11
							, NoLootUnlessKilledByPlayer: 1
							}
						, PersistenceRequired: 1
						, PortalCooldown: UNDER_PLOT.RIDE_TIME
						, ActiveEffects:
							[
								{ Id: 12
								, Amplifier: 0
								, ShowParticles: 0
								, Duration: 9999
								}
							,
								{ Id: 13
								, Amplifier: 0
								, ShowParticles: 0
								, Duration: 9999
								}
							,
								{ Id: 14
								, Amplifier: 2
								, Duration: 9999
								}
							,
								{ Id: 24
								, Amplifier: 0
								, Duration: 9999
								}
							,
								{ Id: 28
								, Amplifier: 0
								, Duration: 9999
								}
							]
						}
					)
				,
					<entitytype:minecraft:wither_skeleton>
				,
					{ CustomName: "{\"text\":\"The Underrider\",\"obfuscated\":true,\"color\":\"dark_red\"}"
					, ForgeData:
						{ undertome: 10
						, NoLootUnlessKilledByPlayer: 1
						}
					, PersistenceRequired: 1
					, PortalCooldown: UNDER_PLOT.ASCEND_TIME
					, HandItems:
						[
							{ Count: 1
							, id: UNDER_PLOT.UNDERFLAME_NAME
							, tag: UNDER_PLOT.UNDERFLAME_NBT
							}
						,
							{ Count: 1
							, id: "minecraft:air"
							}
						]
					, ArmorItems:
						[
							{}
						,
							{}
						,
							{ Count: 1
							, id: UNDER_PLOT.UNDERPLATE_NAME
							, tag: UNDER_PLOT.UNDERPLATE_NBT
							}
						,
							{ Count: 1
							, id: UNDER_PLOT.UNDERHELM_NAME
							, tag: UNDER_PLOT.UNDERHELM_NBT
							}
						]
					, HandDropChances:
						[ 0.2f
						, 1.0f
						]
					, ArmorDropChances:
						[ 0.0f
						, 0.0f
						, 0.2f
						, 0.2f
						]
					, ActiveEffects:
						[
							{ Id: 12
							, Amplifier: 0
							, ShowParticles: 0
							, Duration: 9999
							}
						,
							{ Id: 13
							, Amplifier: 0
							, ShowParticles: 0
							, Duration: 9999
							}
						,
							{ Id: 14
							, Amplifier: 2
							, ShowParticles: 0
							, Duration: 9999
							}
						,
							{ Id: 24
							, Amplifier: 0
							, ShowParticles: 0
							, Duration: 9999
							}
						,
							{ Id: 28
							, Amplifier: 0
							, ShowParticles: 0
							, Duration: 9999
							}
						]
					, Health: 80 // Health has it's own NBT property, instead of being an attribute.
					, Attributes: [
							{
								Base: 60.0 as double, // This should get +50% from his armor.
								Name: "minecraft:generic.max_health"
							},
							{
								Base: 10.0 as double, // Default is 16 but for zombies it's 40.
								Name: "minecraft:generic.follow_range"
							},
							{
								Base: 0.325 as double, // Default is 0.25. Endermen and ravagers are 0.3, pillagers are 0.35.
								Name: "minecraft:generic.movement_speed"
							},
							{
								Base: 0.75 as double, // Only 25% of knockback is applied.
								Name: "minecraft:generic.knockback_resistance"
							},
							{
								Base: 5.0 as double, // Default is 2.0 (one heart), but his initial attack should do some damage.
								Name: "minecraft:generic.attack_damage"
							},
							{
								Base: 0.0 as double,
								Name: "minecraft:generic.armor"
							},
							{
								Base: 5.0 as double,
								Name: "minecraft:generic.armor_toughness"
							},
							{
								Base: 0.06 as double, // default is 0.08
								Name: "forge:entity_gravity"
							}
						]
					} as IData
				);
				val ascentionEffectTarget = UNDER_PLOT.ascentionTarget(portalBase);
				server.executeCommand("tellraw @a[" + ascentionEffectTarget + "] [{\"text\":\"At last, I am free! I only need a few moments to begin my ascention… \",\"color\":\"dark_red\"},{\"text\":\"!You shall not stop me!\",\"color\":\"dark_red\",\"obfuscated\":true}]");
				server.executeCommand("tellraw @a[" + ascentionEffectTarget + "] [{\"text\":\"You fool! What have you done‽ \",\"color\":\"yellow\"},{\"text\":\"You must stop it from escaping! YOU MUST! \",\"color\":\"yellow\",\"bold\":true},{\"text\":\"[YOU_MUST]\",\"color\":\"yellow\",\"obfuscated\":true}]");
				if player.data.contains(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) {
					var tag as MapData = (player.data.getAt(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
					tag.remove("undertome");
				}
				for level in UNDER_PLOT.BOOK_TESTS {
					UNDER_PLOT.replaceEverywhere(player, level);
				}
			}
		}
	}
	if UNDER_PLOT.last_tick != world.gameTime {
		UNDER_PLOT.counter = (UNDER_PLOT.counter + 1) % 40;
		UNDER_PLOT.last_tick = world.gameTime;
	}
});
