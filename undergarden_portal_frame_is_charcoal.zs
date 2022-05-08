/**	Change the Undergarden's portal frame.
 *	Then, get a nice textual string for use in descriptions.
 */

#priority 100

import crafttweaker.api.item.IIngredient;
import crafttweaker.api.item.IItemStack;

/*println("Originally, the portal frame block tag contained:");
for block in <tag:blocks:undergarden:portal_frame_blocks>.getElements() {
	println(block.commandString as string);
}

println("Modifying portal frame block tag.");*/
<tag:blocks:undergarden:portal_frame_blocks>.remove(<tag:blocks:undergarden:portal_frame_blocks>);
<tag:blocks:undergarden:portal_frame_blocks>.add(<tag:blocks:forge:storage_blocks/charcoal>);

//println("Registering portal frame item tag.");
for block in <tag:blocks:undergarden:portal_frame_blocks>.getElements() {
	UNDERGARDEN_FRAME.ITEMS_TAG.add(block.asItem());
	//println("Registered: "+(block.asItem().getDefaultInstance().displayName as string));
}
// This doesn't work on servers:
//val PORTAL_FRAME_NAME_RAW = (UNDERGARDEN_FRAME.ITEMS_TAG.elements[0].getDefaultInstance().displayName as string).toLowerCase();
// Hardcode for now:
val PORTAL_FRAME_NAME_RAW = "charcoal block";
val PORTAL_FRAME_NAME_PLURAL = PORTAL_FRAME_NAME_RAW.endsWith("s") ? PORTAL_FRAME_NAME_RAW : PORTAL_FRAME_NAME_RAW + "s";
val PORTAL_FRAME_NAME_SINGLE = ( PORTAL_FRAME_NAME_RAW.endsWith("s")
	? "" : (
		PORTAL_FRAME_NAME_RAW.startsWith("a") || PORTAL_FRAME_NAME_RAW.startsWith("e") ||
		PORTAL_FRAME_NAME_RAW.startsWith("i") || PORTAL_FRAME_NAME_RAW.startsWith("o") ||
		PORTAL_FRAME_NAME_RAW.startsWith("u") ? "an " : "a "
	) ) + PORTAL_FRAME_NAME_RAW;
//println("Portal frame single: "+PORTAL_FRAME_NAME_SINGLE);
//println("Portal frame plural: "+PORTAL_FRAME_NAME_PLURAL);

public class UNDERGARDEN_FRAME {
	public static val ITEMS_TAG = <tag:items:undergarden:portal_frame_items>;
	public static var NAME_RAW = "";
	public static var NAME_SINGLE = "";
	public static var NAME_PLURAL = "";
}

UNDERGARDEN_FRAME.NAME_RAW = PORTAL_FRAME_NAME_RAW;
UNDERGARDEN_FRAME.NAME_SINGLE = PORTAL_FRAME_NAME_SINGLE;
UNDERGARDEN_FRAME.NAME_PLURAL = PORTAL_FRAME_NAME_PLURAL;
