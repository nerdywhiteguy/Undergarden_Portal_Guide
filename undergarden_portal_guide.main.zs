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

// Create a loot modifier so that entities with the NBT "NoLootUnlessKilledByPlayer" set to 1
// won't drop anything unless killed by the player (and not being killed by code).
loot.modifiers.register(
	"no_loot_unless_killed_by_player",
	LootConditionBuilder.create()
		.add<Not>(condition => {
			condition.withCondition<KilledByPlayer>(cond => {});
		})
		.add<EntityProperties>(condition => {
			condition.withTargetedEntity(TargetedEntity.ACTOR);
			condition.withPredicate(predicate => {
				predicate.withDataPredicate(nbtPredicate => {
					nbtPredicate.withData({"ForgeData": {"NoLootUnlessKilledByPlayer": 1 as byte}});
				});
			});
		}),
	CommonLootModifiers.clearLoot()
);

/**	Setup item tooltips and recipes.
 */
//<item:minecraft:dirt>.addTooltip(MCTextComponent.createStringTextComponent("Yes, this is dirt."));
<item:gravestone:obituary>.addTooltip(MCTextComponent.createStringTextComponent("This is a useless item.").setStyle(<formatting:yellow>));
<item:gravestone:obituary>.addTooltip(MCTextComponent.createStringTextComponent("Just throw it away.").setStyle(<formatting:yellow>));
<item:gravestone:obituary>.addTooltip((MCTextComponent.createStringTextComponent("§kPlease")+MCTextComponent.createStringTextComponent(" throw it away.")).setStyle(<formatting:yellow>));

val SHIMMER_TIP = MCTextComponent.createStringTextComponent("It shimmers with excess energy.").setStyle(<formatting:dark_red>);
UNDER_PLOT.UNDERHELM.addTooltip(SHIMMER_TIP);
UNDER_PLOT.UNDERPLATE.addTooltip(SHIMMER_TIP);
UNDER_PLOT.UNDERFLAME.addTooltip(SHIMMER_TIP);
UNDER_PLOT.UNDERBOW.addTooltip(SHIMMER_TIP);

UNDER_PLOT.UNDERCROWN.anyDamage().replaceTooltip(
	".*Slot.*Head.*", // FIXME: The tooltip is unchanged. The order of these function calls doesn't matter.
	MCTextComponent.createStringTextComponent("Slot: Head").setStyle(<formatting:gray>)
).replaceTooltip(
	"Curse of Vanishing", // This one works just fine, however.
	MCTextComponent.createStringTextComponent("Curse of Vanishing").setStyle(<formatting:gray>)
);
UNDER_PLOT.UNDERHELM.anyDamage().removeTooltip(".*Auto feeding mode.*"); // FIXME: The tooltip remains.

craftingTable.addShapeless("not_useless_obituary_from_gravestone", <item:gravestone:obituary>, [ <item:gravestone:gravestone>.reuse(), <item:minecraft:paper> ]);
craftingTable.addShapeless("not_useless_book1_from_obituary", <item:minecraft:diamond>.withTag({display:{Lore:["{\"text\":\"Do not believe it's lies.\",\"color\":\"yellow\",\"italic\":false}","{\"text\":\"QUIET YOU!   §k. [ ]SHx]\",\"color\":\"dark_red\",\"italic\":false}","{\"text\":\"I'm telling you, DO NOT LET IT OUT!\",\"color\":\"yellow\",\"italic\":false,\"obfuscated\":true}","{\"text\":\"That's better. Sorry you had to see that.\",\"color\":\"dark_red\",\"italic\":false}"]}}), [ <item:gravestone:obituary> ], (usualOut as IItemStack, inputs as IItemStack[]) => {
	return UNDER_PLOT.BOOK1_CRAFTED;
});
craftingTable.addShapeless("not_useless_book2_from_book1_dropped", UNDER_PLOT.BOOK2, [ UNDER_PLOT.BOOK1_DROPPED, <item:minecraft:paper> ]);
craftingTable.addShapeless("not_useless_book2_from_book1_crafted", UNDER_PLOT.BOOK2, [ UNDER_PLOT.BOOK1_CRAFTED, <item:minecraft:paper> ]);
craftingTable.addShapeless("not_useless_book3_from_book2", UNDER_PLOT.BOOK3, [ UNDER_PLOT.BOOK2, <item:minecraft:paper>, <item:minecraft:paper>, <item:minecraft:paper>, <item:minecraft:paper>, <item:minecraft:paper>, <item:minecraft:paper>, <item:minecraft:paper>, <item:minecraft:paper> ]);

craftingTable.addShaped("undercown_from_underhelm", UNDER_PLOT.UNDERCROWN,
	[ [ <tag:items:forge:ingots/gold>, <tag:items:forge:ingots/gold>, <tag:items:forge:ingots/gold> ]
	, [ <tag:items:forge:storage_blocks/gold>, UNDER_PLOT.UNDERHELM.transformDamage((UNDER_PLOT.UNDERHELM.maxDamage * 0.8) as int), <tag:items:forge:storage_blocks/gold> ]
	, [ UNDER_PLOT.UNDERBOW.transformDamage((UNDER_PLOT.UNDERBOW.maxDamage * 0.8) as int), UNDER_PLOT.UNDERPLATE.transformDamage((UNDER_PLOT.UNDERPLATE.maxDamage * 0.8) as int), UNDER_PLOT.UNDERFLAME.transformDamage((UNDER_PLOT.UNDERFLAME.maxDamage * 0.8) as int) ]
	]
);

/** Register event handlers.
 */

CTEventManager.register<crafttweaker.api.event.item.MCItemTossEvent>((event) => {
	/*if event.player === null {
		return;
	}*/
	// Here we are just storing the values so they are easier to reference.
	val player = event.player as MCPlayerEntity;
	val world = player.world as MCWorld;
	// First we need to see what side we are running on, we only want this to run on the server side (if `remote` is true, it means it is the client)
	if world.remote {
		// Since it is the client, we are just going to do nothing and return.
		return;
	}
	val server = world.asServerWorld().server as MCServer;
	println(player.data.getString());
	if <item:gravestone:obituary>.matches(event.entityItem.item) /*|| <item:minecraft:paper>.matches(event.entityItem.item)*/ {
		server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(event.entityItem) + " 1 0.5");
		server.executeCommand("playsound undergarden:entity.stoneborn_chant neutral @a " + UNDER_PLOT.positionCommand(event.entityItem) + " 1 0.5");
		player.sendStatusMessage(( MCTextComponent.createStringTextComponent("§k!WAIT!") + MCTextComponent.createStringTextComponent(" DO NOT LEAVE ME LIKE THIS! ") + MCTextComponent.createStringTextComponent("§k!WAIT!") ).setStyle(<formatting:dark_red>), true);
		event.entityItem.item = UNDER_PLOT.BOOK1_DROPPED;
	} else {
		val itemLevel = UNDER_PLOT.getBookLevel(event.entityItem.item);
		if itemLevel > 0 {
			if itemLevel > UNDER_PLOT.MARKED_LEVEL {
				// For some reason, the /give command triggers this event.
				// We must use the /give command because ZenScript can't interact with scoreboards.
				// Therefore, we can't tell if the player actually dropped this book or if it was given via /give.
				var marked as bool = false;
				if player.data.contains(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) {
					// Check if the player is marked already.
					var tag as MapData = (player.data.getAt(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
					marked = tag.contains("undertome");
					tag.put("undertome", 4);
					//player.sendMessage("You are now marked.");
				}
				//player.sendMessage("Previous mark status: " + (marked as string));
				if marked {
					player.sendStatusMessage(( MCTextComponent.createStringTextComponent("§k[COMPLY]") + MCTextComponent.createStringTextComponent(" There is no escaping me now. ").setStyle(<formatting:bold>) + MCTextComponent.createStringTextComponent("§k[COMPLY]") ).setStyle(<formatting:dark_red>), true);
				} else {
					// If the player was newly marked, do not do anything as this was likely triggered via /give.
				}
			} else {
				server.executeCommand("playsound undergarden:entity.stoneborn_chant neutral @a " + UNDER_PLOT.positionCommand(event.entityItem) + " 1 0.5");
				player.sendStatusMessage(( MCTextComponent.createStringTextComponent("§k!WAIT!") + MCTextComponent.createStringTextComponent(" DO NOT LEAVE ME LIKE THIS! ") + MCTextComponent.createStringTextComponent("§k!WAIT!") ).setStyle(<formatting:dark_red>), true);
			}
		}
	}
});

CTEventManager.register<crafttweaker.api.event.player.MCItemCraftedEvent>((event) => {
	// Here we are just storing the values so they are easier to reference.
	val player = event.player as MCPlayerEntity;
	val world = player.world as MCWorld;
	// First we need to see what side we are running on, we only want this to run on the server side (if `remote` is true, it means it is the client)
	if world.remote {
		// Since it is the client, we are just going to do nothing and return.
		return;
	}
	val item = event.getCrafting();
	val server = world.asServerWorld().server as MCServer;
	if item == UNDER_PLOT.BOOK1_CRAFTED {
		server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(player) + " 1 0.5");
		server.executeCommand("playsound undergarden:entity.stoneborn_chant neutral @a " + UNDER_PLOT.positionCommand(player) + " 1 0.5");
	} else if item == UNDER_PLOT.BOOK2 {
		server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(player) + " 0.5 0.5");
	} else if item == UNDER_PLOT.BOOK3 {
		server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(player) + " 0.5 0.5");
		server.executeCommand("scoreboard players reset @a[" + UNDER_PLOT.positionTargetMax(player, 2) + "] TouchedBook");
		server.executeCommand("scoreboard players enable @a[" + UNDER_PLOT.positionTargetMax(player, 2) + "] TouchedBook");
	} else if <item:undergarden:catalyst>.matches(item) {
		if UNDER_PLOT.getBookLevel(player, world) == UNDER_PLOT.CATALYST_LEVEL && UNDER_PLOT.replaceEverywhere(player, UNDER_PLOT.BOOK_TESTS[UNDER_PLOT.MAX_TEST_LEVEL - UNDER_PLOT.CATALYST_LEVEL], UNDER_PLOT.BOOK_AFTER_CATALYST) > 0 {
			server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(player) + " 0.5 0.5");
		}
	} else if item in UNDER_PLOT.PORTAL_FRAME_ITEMS && player.getInventory().count(UNDER_PLOT.PORTAL_FRAME_ITEMS) >= 10 && UNDER_PLOT.getBookLevel(player) == UNDER_PLOT.FRAME_LEVEL {
		UNDER_PLOT.replaceEverywhere(player, UNDER_PLOT.BOOK_TESTS[UNDER_PLOT.MAX_TEST_LEVEL - UNDER_PLOT.FRAME_LEVEL], UNDER_PLOT.BOOK_AFTER_FRAME);
		server.executeCommand("playsound betterendforge:betterendforge.entity.dragonfly ambient @a " + UNDER_PLOT.positionCommand(player) + " 0.5 0.5");
	}
});

/**	Prevent mobs we summon from hurting (and therefore getting aggroed at) eachother.
 */
CTEventManager.register<crafttweaker.api.event.entity.living.MCLivingAttackEvent>((event) => {
	if event.source === null {
		return; // If the damage source is null, it was the environment, not another mob.
	}
	val source = event.source.getTrueSource() as MCEntity?;
	if source === null {
		return; // If the damage source is null, it was the environment, not another mob.
	}
	val target = event.getEntityLiving();
	val world = target.world as MCWorld;
	// First we need to see what side we are running on, we only want this to run on the server side (if `remote` is true, it means it is the client)
	if world.remote {//|| source.data === null || target.data === null {
		// Since it is the client, we are just going to do nothing and return.
		return;
	}
	val server = world.asServerWorld().server as MCServer;
	if source.data.contains(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) && target.data.contains(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) {
		var source_tag as MapData = (source.data.getAt(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
		var target_tag as MapData = (target.data.getAt(UNDER_PLOT.ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
		// Check for involvement in Undergarden plot:
		if source_tag.contains("undertome") && target_tag.contains("undertome") {
			event.cancel();
		}
	}
	/*if event.isCanceled() {
		server.executeCommand("say " + source.getName() + " could not injure " + target.getName());
	} else {
		server.executeCommand("say " + source.getName() + " injured " + target.getName());
	}*/
});
