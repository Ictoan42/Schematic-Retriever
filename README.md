# Schematic Retriever

**Read the limitations list at the bottom before trying to use this**

## Usage
### Setup
- Download the file: `wget https://github.com/Ictoan42/Schematic-Retriever/raw/refs/heads/main/schem_retrieve.lua schem_retrieve.lua`
- Place an ME Bridge from [Advanced Peripherals](https://modrinth.com/mod/advancedperipherals) next to the computer and connect it to the ME system
- Place a chest **on top** of the ME Bridge (Other sides will not work!)
- Place a lectern next to the computer
### To Retrieve for a schematic
- Configure schematic and place inside Schematicannon as usual
- Use a **book** in the Schematicannon UI to create a material list (Clipboards will not work!)
- Insert the now-written book into the lectern
- Run `schem_retrieve`
- The required items will appear in the chest on top of the ME Bridge

## Limitations (IMPORTANT)
- **The program cannot detect when an item cannot be autocrafted due to lack of ingredients.** This is a limitation of the ME Bridge API, through which a failed craft due to insufficient ingredients looks identical to a successful craft. If there's a way around this that I've missed, please tell me. This is driving me insane. `schem_retrieve` will consider such items to be successfully crafted even when they weren't, so always double check that you have the materials you need after `schem_retrieve` has finished.
- If the ME system contains (or can craft) multiple items with the same display name then `schem_retrieve` will refuse to retrieve or craft anything at all, due to being unable to distinguish two items that have the same display name (An example of this is "Steel Scaffolding" from Immersive Engineering) so you will need to retrieve these manually.
