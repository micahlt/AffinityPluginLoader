using System;
using HarmonyLib;

namespace WineFix
{
    /// <summary>
    /// WineFix Plugin - Bug fixes for running Affinity under Wine
    /// </summary>
    public class WineFixPlugin : AffinityPluginLoader.IAffinityPlugin
    {
        public void Initialize(Harmony harmony)
        {
            try
            {
                FileLog.Log($"WineFix plugin initializing...\n");
                
                // Apply Wine compatibility patches
                Patches.MainWindowLoadedPatch.ApplyPatches(harmony);
                
                FileLog.Log($"WineFix plugin initialized successfully\n");
            }
            catch (Exception ex)
            {
                FileLog.Log($"Error initializing WineFix: {ex.Message}\n{ex.StackTrace}\n");
            }
        }
    }
}
