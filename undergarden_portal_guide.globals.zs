/**	Turn obituaries into something so that you aren't just stuck with a useless item.
 *	That rather creepy something will guide you to the Undergarden, if you're willing to go along with what it asks of you.
 */

#priority 20

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
import crafttweaker.api.util.MCVector3d;
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

/**	Setup global variables and helper functions.
 *	Big thanks to @DShadowWolf#0851 for showing me
 *	how to make a class to store global variables.
 *	Also thanks to @friendlyhj#8596 for additional help.
 */
public class UNDER_PLOT {
	public static val MARKED_LEVEL as int = 4;
	public static val CATALYST_LEVEL as int = 5;
	public static val FRAME_LEVEL as int = 6;
	public static val PORTAL_LEVEL as int = 7;
	public static val PORTAL_FRAME_NAME_PLURAL = UNDERGARDEN_FRAME.NAME_PLURAL;
	public static val PORTAL_FRAME_NAME_SINGLE = UNDERGARDEN_FRAME.NAME_SINGLE;
	public static val PORTAL_FRAME_ITEMS = UNDERGARDEN_FRAME.ITEMS_TAG;

	public static val ENTITY_MARKER_PARENT_KEY = "ForgeData";

	// Define books that are used in recipes or that are given in pure ZenScript.
	public static val BOOK1_CRAFTED = <item:minecraft:written_book>.withTag({undertome: 1, pages: ["{\"text\":\"Have you seen it?\\n\\nThe under land?\\n\\nNo, not the land below.\\nNot that hellish place.\\n\\nLook below that.\\nDeeper…\\nDeeper…\\n§kDeeper§r…\\nThere! Do you see?\"}", "{\"text\":\"A veritable garden of potential.\\n\\nIt waits for you.\\n\\nIt longs for you.\\n\\nDo you long for it?\\n\\nI long to speak more on the subject, but, alas, I have run out of paper…. §kFEED_ME!\"}"], title: "Cryptic Note", author: "§4§kUnknown", display: {Name: "{\"text\":\"Cryptic Note\",\"color\":\"dark_red\",\"italic\":false}", Lore: ["{\"text\":\"I offer you a prize worth more than any §3§odiamond§r§4.\",\"color\":\"dark_red\",\"italic\":false}","{\"text\":\"I can show you the lush land under it all.\",\"color\":\"dark_green\",\"italic\":false,\"bold\":true}"]}, resolved: 1 as byte}) as IItemStack;
	public static val BOOK1_DROPPED = <item:minecraft:written_book>.withTag({undertome: 1, pages: ["{\"text\":\"You heard it, yes?\\n\\nBut have you seen it?\\n\\nThe under land?\\n\\nNo, not the land below.\\nNot that hellish place.\\n\\nLook below that.\\nDeeper…\\nDeeper…\\n§kDeeper§r…\\nThere! Do you see?\"}", "{\"text\":\"A veritable garden of potential.\\n\\nIt waits for you.\\n\\nIt longs for you.\\n\\nDo you long for it?\\n\\nI long to speak more on the subject, but, alas, I have run out of paper…. §kFEED_ME!\"}"], title: "§4Cryptic Note", author: "§4§kUnknown", display: {Lore: ["{\"text\":\"Thank you for picking me up!\",\"color\":\"dark_red\"}","{\"text\":\"I knew that you would hear §kmy cry.\",\"color\":\"dark_red\",\"italic\":false}"] }, resolved: 1 as byte}) as IItemStack;
	public static val BOOK2 = <item:minecraft:written_book>.withTag({undertome: 2, pages: ["{\"text\":\"\\n\\n\\n§kMmmmm.§r\\n\\n\\nThat was good.\\n\\n\\nYes.\"}" as string, "{\"text\":\"I have not §keaten§r in so long… I forgot what it was like.\\n\\nPlease.\\n\\nMay I have some more?\"}" as string], title: "Cryptic Note" as string, author: "§4your friend ♥" as string, display: {Name: "{\"text\":\"§kCryptic_Note\",\"color\":\"dark_red\",\"italic\":false}" as string}, generation: 1}) as IItemStack;
	public static val BOOK3 = <item:minecraft:written_book>.withTag({undertome: 3, pages:['["",{"text":"Thank you. I am feeling better now. But I am not yet whole. I can not remember. I can not "},{"text":"recall","obfuscated":true},{"text":".\\n\\nI require\\u2026 more.\\nI require\\u2026 ","color":"reset"},{"text":"additional","obfuscated":true},{"text":".\\n\\nIt is only a small thing.","color":"reset"}]','["",{"text":"I can help you.\\n\\nI can show you the way.\\n\\nBut you must help me first. "},{"text":"HELP ME","obfuscated":true},{"text":"\\n\\nIt is only a small thing that I ask of you.\\n\\nWill you give it to me?","color":"reset"}]','["",{"text":"You will not regret helping me! I "},{"text":"promise!","italic":true},{"text":"\\n\\nIt will be easy.\\n\\nAll you must do is ","color":"reset"},{"text":"donate some of your ","obfuscated":true},{"text":"life force","obfuscated":true,"color":"dark_red"},{"text":".\\n\\nEasy, right?","color":"reset"}]','["",{"text":"Oh, you didn\'t understand that?\\n\\nLet me try again.\\n\\n"},{"text":"FEED ","obfuscated":true},{"text":"ME","obfuscated":true,"color":"dark_red"},{"text":" YOURSELF.","color":"reset","obfuscated":true},{"text":"\\n ","color":"reset"}]','["",{"text":"I don\'t think I can articulate it properly.\\n\\nJust\\u2026 follow my instructions and "},{"text":"no one gets hurt","obfuscated":true},{"text":". ","color":"reset"},{"text":"Got it","obfuscated":true},{"text":"?\\n\\nListen: Turn a few more pages, and then press your finger against the large red dot. OK? Just do it, and ","color":"reset"},{"text":"stop asking questions","color":"dark_red"},{"text":".","color":"reset"}]','{"text":""}','["",{"text":"\\n"},{"text":" \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 \\u0020.\\n \\u0020 \\u0020. \\u0020 \\u0020 m \\u0020 h \\u0020 .\\n \\u0020. \\u0020 \\u0020H j \\u0020GH \\u0020[\\n \\u0020 \\u0020g asdf lkjj l; \\u0020.\\n \\u002034 us UNDERga rden\\n \\u0020await THE_depths of\\n \\u0020 x \\u0020 the abysss \\u002099\\n x \\u0020 \\u0020get out \\u0020stop\\n \\u0020, \\u0020 , \\u0020never will I\\n \\u0020 \\u0020, \\u0020 \\u0020 \\u0020 x \\u0020 ,\\n \\u0020 \\u0020 \\u0020 \\u0020]\\u0020 \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 w\\n \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 \\u0020 st \\u0020 op","obfuscated":true}]','{"text":" \\u0020 \\u0020 \\u0020a \\u0020 b \\u0020 \\u0020 \\u0020c \\u0020\\n \\u0020as \\u0020 F \\u0020 \\u0020dFv \\u0020 Fh\\n asdf \\u0020asd asdf \\u0020sadk fk j5h bhq 81 09as\\n LD j5h34.j5h 3j4- 5 hjhasd8 \\u0020df 84 1834 . \\u0020 kasdjkasd dfg3as\\n 12jLJFS jjaslHJS j Sk KSDjl . kjALSK ljk jsa as jse e q as qpLF t zHG a . h .\\n sdjkjq AS3 k10KAS a\\n \\u0020BH \\u0020uss GJS more 1\\n \\u0020 \\u0020a \\u0020. \\u0020 GH d \\u0020 m","obfuscated":true}','["",{"text":"  .    a   b    fx\\n]  as   Fx  x g dFv F\\nasdf  asd asdf  sadk fk j5h bhq 81 09as  x\\n] LD j5h34.j5h 3j4- 5 hjhasd8 ] df 84 1834\\nkasdjkasd","obfuscated":true},{"text":"ʘ","color":"dark_red","clickEvent":{"action":"run_command","value":"/trigger TouchedBook set 1"},"hoverEvent":{"action":"show_text","contents":"§4Press your finger here.\\n§4Nothing §kgood§r§4 will happen.\\n§4TRUST ME."}},{"text":"]fg3]s.dfhs\\n.12jLJFS jjaslHJS jSk x KSDjl . kjALSK ljk. jsa as jse e q as x] qpLF ]xt zHG a . h ]x .jkjq AS3 k10KAS a H  uss GJS more 1  a  .\\n GH d   m dfgj fg52","color":"reset","obfuscated":true}]'],title:"§4Cryptic Tome",author:"§4your friend ♥♥",generation:3}) as IItemStack;
	public static val BOOK5 = <item:minecraft:written_book>.withTag({undertome: FRAME_LEVEL, pages: ['[{"text":"Now, fashion at least 10 '+PORTAL_FRAME_NAME_PLURAL+'.\\n\\n"},{"text":"If I have to explain how to make these, you will never survive in "},{"text":"the Undergarden","color":"dark_green"},{"text":".","color":"reset"}]'], title: "Instructional Note", author: "§4your teacher ♥♥♥♥", display: {Lore: ['{"text":"Next is 10 '+PORTAL_FRAME_NAME_PLURAL+'.","color":"dark_red","italic":false}'] },generation:3}) as IItemStack;
	public static val BOOK6 = <item:minecraft:written_book>.withTag({undertome: PORTAL_LEVEL, pages: ['{"text":"Very good! Very good!\\nYou have done well!\\n\\nYou will now build the portal frame out of these '+PORTAL_FRAME_NAME_PLURAL+', and light it with the catalyst.\\n\\nYou know how to build a portal frame, do you not?"}','{"text":"The frame must be a vertical hollow rectangle.\\n\\nThe opening must be at least 2 blocks wide and at least 3 blocks tall.\\n\\nWould a diagram help your puny mind comprehend?"}','{"text":"Here.\\n\\n  X B B X\\n  B - - B\\n  B - - B\\n  B - - B\\n  X B B X\\n\\nB is '+PORTAL_FRAME_NAME_SINGLE+',\\nX is any block,\\n- must be empty air."}', '{"text":"Once you have done this, stand back, and light the portal by using the Catalyst on the inside of the frame.\\n\\n§k[Release]me! RELEASE ME! Oh, how I long to taste freedom!"}'], title: "Instructional Note", author: "§4your teacher ♥♥♥♥♥", display: {Lore: ['{"text":"Build and light the portal!","color":"dark_red","italic":true}'] },generation:3}) as IItemStack;
	public static val BOOK_AFTER_CATALYST = BOOK5;
	public static val BOOK_AFTER_FRAME = BOOK6;

	// Define template items to search for books of varying level in inventories.
	public static val BOOK_TESTS as IItemStack[] =
	[	<item:minecraft:written_book>.withTag( { undertome: 7 } )
	,	<item:minecraft:written_book>.withTag( { undertome: 6 } )
	,	<item:minecraft:written_book>.withTag( { undertome: 5 } )
	,	<item:minecraft:written_book>.withTag( { undertome: 4 } )
	,	<item:minecraft:written_book>.withTag( { undertome: 3 } )
	,	<item:minecraft:written_book>.withTag( { undertome: 2 } )
	,	<item:minecraft:written_book>.withTag( { undertome: 1 } )
	];
	public static val MAX_TEST_LEVEL as int = BOOK_TESTS.length as int;

	// Define NBT tags and the items for some of the fancy loot.
	public static val UNDERHELM_NBT =
		{ display:
			{ Name: "{\"text\":\"Helm of the Tome\",\"color\":\"dark_red\",\"italic\":false}"
			, Lore:
				[ "{\"text\":\"While wearing it, you tend to eat without even thinking....\",\"color\":\"dark_red\",\"italic\":false}"
				, "{\"text\":\"It is as if you were compelled by a deep, primal hunger.\",\"color\":\"dark_red\",\"italic\":false}"
				, "{\"text\":\"Breathing, too, becomes something practically beneath your contempt.\",\"color\":\"dark_red\",\"italic\":false}"
				]
			}
		, Enchantments:
			[
				{ id: "respiration"
				, lvl: 5
				}
			,
				{ id: "unbreaking"
				, lvl: 5
				}
			,
				{ id: "mending"
				, lvl: 1
				}
			]
		, modules:
			[ "feeder_module"
			]
		, AttributeModifiers:
			[ {Amount: 3.5 as double, Operation: 0 as int, Slot: "head" as string, AttributeName: "minecraft:generic.armor_toughness" as string, UUID: [718533190, -18788761, -1199150595, 940290384], Name: "Armor toughness" as string}
			, {Amount: 4.0 as double, Operation: 0 as int, Slot: "head" as string, AttributeName: "minecraft:generic.armor" as string, UUID: [718533190, -18788761, -1199150595, 940290384], Name: "Armor modifier" as string}
			, {Amount: 0.25 as double, Operation: 1 as int, Slot: "head" as string, AttributeName: "minecraft:generic.max_health" as string, UUID: [718533190, -18788761, -1199150595, 940290384], Name: "Max health" as string}
			]
		} as IData;
	public static val UNDERPLATE_NBT =
		{ display:
			{ Name: "{\"text\":\"Plate of the Tome\",\"color\":\"dark_red\",\"italic\":false}"
			, Lore:
				[ "{\"text\":\"Honed with thousands of years of skill, the\",\"color\":\"dark_red\",\"italic\":false}"
				, "[{\"text\":\"essence of \",\"color\":\"dark_red\",\"italic\":false},{\"text\":\"the Undergarden\",\"color\":\"dark_green\",\"italic\":false,\"bold\":true},{\"text\":\" itself empowers\",\"color\":\"dark_red\",\"italic\":false}]"
				, "{\"text\":\"this chestplate to supernatural levels.\",\"color\":\"dark_red\",\"italic\":false}"
				, "{\"text\":\"No mortal could ever craft something so fine.\",\"color\":\"dark_red\",\"italic\":false}"
				]
			}
		, Enchantments:
			[
				{ id: "blast_protection"
				, lvl: 5
				}
			,
				{ id: "fire_protection"
				, lvl: 5
				}
			,
				{ id: "protection"
				, lvl: 5
				}
			,
				{ id: "unbreaking"
				, lvl: 5
				}
			,
				{ id: "mending"
				, lvl: 1
				}
			]
		, AttributeModifiers:
			[ {Amount: 9.0 as double, Operation: 0 as int, Slot: "chest" as string, AttributeName: "minecraft:generic.armor" as string, UUID: [-1623373971, -1055374012, -2090507132, 1761916046], Name: "Armor modifier" as string}
			, {Amount: 3.5 as double, Operation: 0 as int, Slot: "chest" as string, AttributeName: "minecraft:generic.armor_toughness" as string, UUID: [-1623373971, -1055374012, -2090507132, 1761916046], Name: "Armor toughness" as string}
			, {Amount: 0.25 as double, Operation: 1 as int, Slot: "chest" as string, AttributeName: "minecraft:generic.max_health" as string, UUID: [-1623373971, -1055374012, -2090507132, 1761916046], Name: "Max health" as string}
			]
		} as IData;
	public static val UNDERCROWN_NBT =
		{ display:
			{ Name: "{\"text\":\"Crown of the Tome\",\"color\":\"dark_red\",\"italic\":false}"
			, Lore:
				[ "{\"text\":\"The excess energies of bloodlust infused into the finest gold.\",\"color\":\"dark_red\",\"italic\":false}"
				, "[{\"text\":\"This crown allows you to see \",\"color\":\"dark_red\",\"italic\":false},{\"text\":\"prey\",\"color\":\"dark_red\",\"obfuscated\":true},{\"text\":\" even in the \",\"color\":\"dark_red\",\"italic\":false}]"
				, "[{\"text\":\"blackness\",\"color\":\"dark_gray\",\"bold\":true,\"italic\":false},{\"text\":\" of \",\"color\":\"dark_red\",\"bold\":false},{\"text\":\"caves\",\"color\":\"dark_gray\",\"bold\":true},{\"text\":\" or \",\"color\":\"dark_red\",\"bold\":false},{\"text\":\"the Undergarden\",\"color\":\"dark_green\",\"bold\":true},{\"text\":\".\",\"color\":\"dark_red\",\"bold\":false}]"
				, "{\"text\":\"The hunger is more intense, with this on your head.\",\"color\":\"dark_red\",\"italic\":false}"
				, "{\"text\":\"If you do not act to satisfy it, this artifact will fade away.\",\"color\":\"dark_red\",\"italic\":false}"
				, "{\"text\":\"Should you die, it will deem you unworthy and vanish immediately.\",\"color\":\"dark_red\",\"italic\":false}"
				, "[{\"text\":\"Blood spills out in liters as someone screams a word\",\"color\":\"dark_red\",\"obfuscated\":true},{\"text\":\".\",\"color\":\"dark_red\",\"italic\":false,\"obfuscated\":false}]"
				]
			}
		, Enchantments:
			[
				{ id: "mending"
				, lvl: 1
				}
			,
				{ id: "unbreaking"
				, lvl: 5
				}
			,
				{ id: "vanishing_curse"
				, lvl: 1
				}
			]
		} as IData;
	public static val UNDERFLAME_NBT =
		{ display:
			{ Name: "{\"text\":\"Flaming Bow of the Tome\",\"color\":\"dark_red\",\"italic\":false}"
			}
		, Enchantments:
			[
				{ id: "flame"
				, lvl: 1
				}
			,
				{ id: "unbreaking"
				, lvl: 5
				}
			,
				{ id: "piercing"
				, lvl: 5
				}
			,
				{ id: "punch"
				, lvl: 3
				}
			,
				{ id: "knockback"
				, lvl: 3
				}
			,
				{ id: "mending"
				, lvl: 1
				}
			]
		} as IData;
	public static val UNDERBOW_NBT =
		{ display:
			{ Name: "{\"text\":\"Bow of the Tome\",\"color\":\"dark_red\",\"italic\":false}"
			}
		, Enchantments:
			[
				{ id: "unbreaking"
				, lvl: 5
				}
			,
				{ id: "knockback"
				, lvl: 2
				}
			,
				{ id: "mending"
				, lvl: 1
				}
			]
		} as IData;
	public static val UNDERCROWN_NAME = "curios:crown";
	public static val UNDERCROWN = <item:${UNDERCROWN_NAME}>.withTag(UNDERCROWN_NBT);
	public static val UNDERHELM_NAME = "undergarden:utheric_helmet";
	public static val UNDERHELM = <item:${UNDERHELM_NAME}>.withTag(UNDERHELM_NBT);
	public static val UNDERPLATE_NAME = "undergarden:utheric_chestplate";
	public static val UNDERPLATE = <item:${UNDERPLATE_NAME}>.withTag(UNDERPLATE_NBT);
	public static val UNDERFLAME_NAME = "minecraft:bow";
	public static val UNDERFLAME = <item:${UNDERFLAME_NAME}>.withTag(UNDERFLAME_NBT);
	public static val UNDERBOW_NAME = "minecraft:bow";
	public static val UNDERBOW = <item:${UNDERBOW_NAME}>.withTag(UNDERBOW_NBT);

	// Other constants and variables.
	public static val PORTAL_DETECT_DISTANCE as BlockPos = new BlockPos(8, 3, 8);
	public static val ESCAPE_HEIGHT = 300;
	public static val ASCEND_TIME = 2400; // ticks until ascention begins after being summoned
	public static val RIDE_TIME = 200; // ticks to ride the Undercat
	public static val SUMMON_TIME = (RIDE_TIME*3/4) as int; // ticks to spawn in minions for every second (20 ticks)
	public static val MINION_TIME = ASCEND_TIME + SUMMON_TIME; // ticks until main minions start despawning
	public static val MINION_RIDE_TIME = RIDE_TIME; // ticks until the minion's mounts start despawning

	public static var counter = 0;
	public static var last_tick = 0L;
	public static var initial_setup_run = false;

	// Define helper/convenience functions.
	public static getBookLevel(item as IItemStack, minimum as int = 0) as int {
		if minimum >= MAX_TEST_LEVEL {
			return minimum; // short circuit if we're already at the highest level
		}
		// Compare template items against the item in question.
		for level in 0 .. MAX_TEST_LEVEL - minimum {
			if BOOK_TESTS[level].matches(item) {
				return MAX_TEST_LEVEL - level;
			}
		}
		return minimum;
	}
	public static getBookLevel(player as MCPlayerEntity, initial_level as int = 0) as int {
		val inventory = player.getInventory();
		// inventory.itemStack is the item held by the mouse.
		// Big thanks to the main man Jared for exposing this property just because I asked about it. lol
		// https://discord.com/channels/136877912698650625/354745056743260172/860656997250629673
		// https://discord.com/channels/136877912698650625/354745056743260172/860659801401851925
		var max = getBookLevel(inventory.itemStack, initial_level);
		if max >= MAX_TEST_LEVEL {
			return MAX_TEST_LEVEL; // short circuit if we're already at the highest level
		}

		// Loop over the rest of the items in the user's inventory slots.
		for slot in 0 .. inventory.getInventorySize() {
			var level = getBookLevel(inventory.getStackInSlot(slot), max);
			if level >= MAX_TEST_LEVEL {
				return MAX_TEST_LEVEL; // short circuit if we're already at the highest level
			} else if level > max {
				max = level;
			}
		}
		return max;
	}
	public static getBookLevel(entities as MCEntity[], initial_level as int = 0) as int {
		var max = initial_level;
		for entity in entities {
			if entity is MCItemEntity {
				// This line was bugged. But Jared did a lot of work and fixed it! Thanks Jared!
				var entityItem = entity as MCItemEntity;
				var level = getBookLevel(entityItem.item, max);
				if level > max {
					max = level;
				}
			} else {
				if entity.data.contains(ENTITY_MARKER_PARENT_KEY) {
					var tag as MapData = (entity.data.getAt(ENTITY_MARKER_PARENT_KEY) as IData) as MapData;
					if tag.contains("undertome") && ((tag.getAt("undertome").asNumber() as int) > max) {
						max = (tag.getAt("undertome").asNumber() as int);
					}
				}
			}
		}
		return max;
	}
	public static getBookLevel(world as MCServerWorld, initial_level as int = 0) as int {
		if initial_level >= MAX_TEST_LEVEL {
			return MAX_TEST_LEVEL;
		}
		return getBookLevel( (world).getEntities((entity as MCEntity) => entity.world.isLoaded(entity.position)) as MCEntity[], initial_level);
	}
	public static getBookLevel(world as MCWorld, initial_level as int = 0) as int {
		return getBookLevel(world as MCServerWorld, initial_level);
	}
	public static getBookLevel(world as MCServerWorld, player as MCPlayerEntity) as int {
		// Check in the world first, then in the player's inventory.
		return getBookLevel(player, getBookLevel(world));
	}
	public static getBookLevel(world as MCWorld, player as MCPlayerEntity) as int {
		// Automatically cast MCWorld to MCServerWorld
		return getBookLevel(world as MCServerWorld, player);
	}
	public static getBookLevel(player as MCPlayerEntity, world as MCServerWorld) as int {
		// Check in the player's inventory first, then in the world.
		return getBookLevel(world, getBookLevel(player));
	}
	public static getBookLevel(player as MCPlayerEntity, world as MCWorld) as int {
		// Automatically cast MCWorld to MCServerWorld
		return getBookLevel(player, world as MCServerWorld);
	}
	/**	Determine if the given player has an item.
	 *	Note that this checks what is being held by the mouse in a GUI as well.
	 */
	public static hasItem(player as MCPlayerEntity, search as IIngredient) as bool {
		val inventory = player.getInventory();
		// inventory.itemStack is the item held by the mouse.
		// Big thanks to Jared for exposing this property just because I asked about it. lol
		if search.matches(inventory.itemStack) {
			return true;
		}
		// Loop over the rest of the items in the user's inventory slots.
		for slot in 0 .. inventory.getInventorySize() {
			if search.matches(inventory.getStackInSlot(slot)) {
				return true;
			}
		}
		return false;
	}
	/**	Remove (and return) an item from a given player.
	 *	Note that this checks what is being held by the mouse in a GUI as well.
	 *	Returns <item:minecraft:air> if there was no matching item found.
	 */
	public static popItem(player as MCPlayerEntity, search as IIngredient) as IItemStack {
		val inventory = player.getInventory();
		val heldByMouse as IItemStack = inventory.itemStack; // inventory.itemStack is the item held by the mouse.
		if search.matches(heldByMouse) {
			inventory.itemStack = <item:minecraft:air>;
			return heldByMouse;
		}
		// Loop over the rest of the items in the user's inventory slots.
		for slot in 0 .. inventory.getInventorySize() {
			if search.matches(inventory.getStackInSlot(slot)) {
				return inventory.removeStackFromSlot(slot);
			}
		}
		return <item:minecraft:air>;
	}
	public static positionCommand(pos as BlockPos) as string {
		return (pos.x as string) + " " + (pos.y as string) + " " + (pos.z as string);
	}
	public static positionTarget(pos as BlockPos) as string {
		return "x=" + (pos.x as string) + ",y=" + (pos.y as string) + ",z=" + (pos.z as string);
	}
	public static positionTarget(pos as BlockPos, distance as string) as string {
		return positionTarget(pos) + ",distance=" + distance;
	}
	public static positionTargetMax(pos as BlockPos, distance as double) as string {
		return positionTarget(pos, ".." + (distance as string));
	}
	public static positionTargetMin(pos as BlockPos, distance as double) as string {
		return positionTarget(pos, (distance as string) + "..");
	}

	public static positionCommand(entity as MCEntity) as string {
		return positionCommand(entity.position);
	}
	public static positionTarget(entity as MCEntity) as string {
		return positionTarget(entity.position);
	}
	public static positionTarget(entity as MCEntity, distance as string) as string {
		return positionTarget(entity.position, distance);
	}
	public static positionTargetMax(entity as MCEntity, distance as double) as string {
		return positionTargetMax(entity.position, distance);
	}
	public static positionTargetMin(entity as MCEntity, distance as double) as string {
		return positionTargetMin(entity.position, distance);
	}

	public static ascentionTarget(position as BlockPos) as string {
		return "x="+position.x+",y=150,z="+position.z+",distance=..160";
	}
	public static ascentionTarget(entity as MCEntity) as string {
		return ascentionTarget(entity.position);
	}

	public static val FOUND_IN_INVENTORY as byte = 0x1 as byte;
	public static val FOUND_IN_MOUSE as byte = 0x2 as byte;
	public static val FOUND_IN_WORLD as byte = 0x4 as byte;
	/**	Replace all instances of the given item with at most one instance of another (which defaults to air).
	 *	Returns the combination of flags to indicate where the item was found.
	 */
	public static replaceEverywhere(player as MCPlayerEntity, search as IIngredient, replace as IItemStack = <item:minecraft:air>) as byte {
		var found as byte = 0x0 as byte;
		val inventory = player.getInventory();
		if inventory.remove(search) {
			found = FOUND_IN_INVENTORY;
		}
		if search.matches(inventory.itemStack) {
			// We are about to place the new item here, so don't otherwise bother removing.
			found += FOUND_IN_MOUSE;
		}
		/*getBookLevel(world) == CATALYST_LEVEL {
			shouldGetNextLevel = 1;
			// remove books from the ground
			// IDK how to do this
		}*/
		if found > 0x0 as byte {
			if (found & FOUND_IN_MOUSE) > 0x0 as byte {
				inventory.itemStack = replace;
			} else {
				player.give(replace);
			}
		}
		return found;
	}

/**	Concenience method to setup a new entity and add it to the world.
 *	Summons the entity at the coordinate given.
 *	Note that 0, 0, 0 would NOT be at the center of a block.
 *	Rather, 0.5, 0, 0.5 is the center of a block.
 */
public static newEntity(world as MCWorld, x as double, y as double, z as double, entityType as MCEntityType, nbt as IData? = null) as MCEntity {
	val entity = entityType.create(world);
	if nbt != null {
		entity.updateData(nbt as IData);
	}
	entity.setPositionAndUpdate(x, y, z);
	world.addEntity(entity);
	return entity;
}
/**	Concenience method to setup a new entity and add it to the world.
 *	Summons the entity at the center of the given BlockPos instead of on the corner
 *	by adding 0.5 to both the x and z axis.
 */
public static newEntity(world as MCWorld, pos as BlockPos, entityType as MCEntityType, nbt as IData? = null) as MCEntity {
	return newEntity(world, pos.x + 0.5, pos.y, pos.z + 0.5, entityType, nbt);
}
/**	Concenience method to setup a new entity and add it to the world.
 *	Summons the entity at the given MCVector3d.
 *	Special thanks to Jared for exposing all of the positionVec stuff!
 */
public static newEntity(world as MCWorld, posVec as MCVector3d, entityType as MCEntityType, nbt as IData? = null) as MCEntity {
	return newEntity(world, posVec.x, posVec.y, posVec.z, entityType, nbt);
}
/**	Convenience method to setup a new entity riding the given entity and add it to the world.
 */
public static newEntity(riding as MCEntity, entityType as MCEntityType, nbt as IData? = null) as MCEntity {
	val entity = newEntity(riding.world, riding.positionVec, entityType, nbt);
	entity.startRiding(riding);
	return entity;
}
}

// Thanks to @p3lim#0001 https://discord.com/channels/136877912698650625/354745056743260172/877351821423820850
public expand IIngredient {
	/**	Replace lines in the tooltip matching the given regex with the given MCTextComponent.
	 */
	public replaceTooltip(input as string, output as MCTextComponent) as IIngredient {
		this.modifyTooltip((stack as IItemStack, tooltip as List<MCTextComponent>, isAdvanced as bool) as void => {
			for i in 0 .. tooltip.length {
				if tooltip[i].formattedText.matchesRegex(input) {
					tooltip[i] = output;
				}
			}
		});
		return this;
	}
}
public expand IInventory {
	/**	Get a count of the number of items in this inventory matching the given tag.
	 */
	public count(tag as MCTag<MCItemDefinition>) as int {
		var x = 0 as int;
		for item in tag.elements {
			x += this.count(item);
		}
		return x;
	}
}
