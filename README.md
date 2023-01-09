# Crowd Control for SGG Games

You need the latest [`Mod Importer`](https://github.com/SGG-Modding/ModImporter), [`Mod Utility`](https://github.com/SGG-Modding/ModUtil), and `StyxScribe` (all from GitHub source files as releases and Nexus posts are a bit behind always)
   
Either way, you need at least `python 3.8` and you need to run `Mod Importer` first, and then run the appropriate `Subsume<game>.py` such as `SubsumeHades.py` for Hades.
    
For modders, use the Crowd Control SDK to test effects by loading the a `.cs` file in `Content/CrowdControlContent`.          
You can fork this repo and make pull requests but try to only make changes to the `Packs` folder.   

For streamers, use the Crowd Control Twitch extension and the Crowd Control app to load a `.ccpack` file in `Content/CrowdControlContent`.    
You may also need the Crowd Control SDK to turn a `.cs` file into a `.ccpack`, as that assigns points to the effects.
