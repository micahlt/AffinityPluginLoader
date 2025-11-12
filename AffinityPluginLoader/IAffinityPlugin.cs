using HarmonyLib;

namespace AffinityPluginLoader
{
    /// <summary>
    /// Interface that plugins must implement to be automatically initialized
    /// </summary>
    public interface IAffinityPlugin
    {
        /// <summary>
        /// Called when the plugin is loaded. Apply Harmony patches here.
        /// </summary>
        /// <param name="harmony">Harmony instance to use for patching</param>
        void Initialize(Harmony harmony);
    }
}
