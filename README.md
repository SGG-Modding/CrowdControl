# Crowd Control for SGG Games

Should work on Hades and Pyre and hopefully Hades 2 after some minor alterations
This will NOT work on Windows Store / Game Pass games.

You need the latest [`Mod Importer`](https://github.com/SGG-Modding/ModImporter), [`Mod Utility`](https://github.com/SGG-Modding/ModUtil), and [`StyxScribe`](https://github.com/SGG-Modding/StyxScribe).     
(get `Mod Importer` from GitHub releases, and the rest by cloning the respective repositories)

For clarification, `Mod Importer`'s content should be extracted to the `Content` folder, `Mod Utility`'s content should be in a folder called `ModUtil` with a `modfile.txt` directly inside, then put that folder in `Content/Mods`, `StyxScribe`'s content should be put directly into your game's top level directory, so for Hades that's just the folder `Hades.game.app` on macOS and `Hades` on the rest.

You need at least [`python 3.8`](https://www.python.org/downloads/) and you need to run `Mod Importer`'s `modimporter<.ext>` (where `<.ext>` depends on which version you got) first, and then run the appropriate `Subsume<game>.py` such as `SubsumeHades.py` for Hades.
    
For modders, use the [Crowd Control SDK](https://forum.warp.world/t/how-to-setup-and-use-the-crowd-control-sdk/5121) to test effects by loading the a `.cs` file in `Content/CrowdControlContent`.          
You can fork this repo and make pull requests but try to only make changes to the `Packs` folder.   
The [Base Pack](Packs/CrowdControl.Packs.Base.lua) contains a lot of comments that hopefully make the format clear.

For streamers, use the [Crowd Control Twitch extension and the Crowd Control app](https://crowdcontrol.live/setup) to load a `.ccpack` file in `Content/CrowdControlContent`.
You may also need the [Crowd Control SDK](https://forum.warp.world/t/how-to-setup-and-use-the-crowd-control-sdk/5121) to turn a `.cs` file into a `.ccpack`, as that assigns points to the effects.
