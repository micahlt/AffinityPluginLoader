using System;
using System.Linq;
using System.Reflection;
using HarmonyLib;
using AffinityPluginLoader.UI;

namespace AffinityPluginLoader.Patches
{
    /// <summary>
    /// Patches for adding the Plugins tab to Affinity's Preferences dialog
    /// </summary>
    public static class PreferencesPatches
    {
        public static void ApplyPatches(Harmony harmony)
        {
            try
            {
                FileLog.Log($"Applying PreferencesDialog patches\n");
                
                // Find the Serif.Affinity assembly
                var serifAssembly = AppDomain.CurrentDomain.GetAssemblies()
                    .FirstOrDefault(a => a.GetName().Name == "Serif.Affinity");
                
                if (serifAssembly == null)
                {
                    FileLog.Log($"ERROR: Serif.Affinity assembly not found for preferences patch\n");
                    return;
                }
                
                // Get the PreferencesDialog type
                var preferencesDialogType = serifAssembly.GetType("Serif.Affinity.UI.Dialogs.Preferences.PreferencesDialog");
                if (preferencesDialogType == null)
                {
                    FileLog.Log($"ERROR: PreferencesDialog type not found\n");
                    return;
                }
                
                // Find the constructor - it takes a Type parameter with default value
                var constructor = preferencesDialogType.GetConstructor(
                    BindingFlags.Public | BindingFlags.Instance,
                    null,
                    new Type[] { typeof(Type) },
                    null);
                
                if (constructor != null)
                {
                    FileLog.Log($"Found PreferencesDialog constructor\n");
                    var postfix = typeof(PreferencesPatches).GetMethod(nameof(PreferencesDialog_Constructor_Postfix), BindingFlags.Static | BindingFlags.Public);
                    harmony.Patch(constructor, postfix: new HarmonyMethod(postfix));
                    FileLog.Log($"Patched PreferencesDialog constructor\n");
                }
                else
                {
                    FileLog.Log($"ERROR: PreferencesDialog constructor not found\n");
                }
            }
            catch (Exception ex)
            {
                FileLog.Log($"Failed to apply preferences patches: {ex.Message}\n{ex.StackTrace}\n");
            }
        }

        // Postfix for PreferencesDialog constructor
        public static void PreferencesDialog_Constructor_Postfix(object __instance)
        {
            try
            {
                FileLog.Log($"PreferencesDialog constructor postfix called\n");
                
                // Get the type of the dialog
                var dialogType = __instance.GetType();
                
                // Find the property that holds the pages (it's called "Pages")
                var pagesProperty = dialogType.GetProperty("Pages", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
                
                if (pagesProperty != null)
                {
                    var pages = pagesProperty.GetValue(__instance);
                    if (pages is System.Collections.IList pageList)
                    {
                        FileLog.Log($"Found Pages property with {pageList.Count} existing pages\n");
                        
                        // Create plugins page using factory to avoid loading Serif.Affinity.dll early
                        var pluginsPage = PluginsPreferencesPageFactory.CreatePage();
                        
                        if (pluginsPage != null)
                        {
                            // Set Index property via reflection
                            var indexProperty = pluginsPage.GetType().GetProperty("Index");
                            if (indexProperty != null)
                            {
                                indexProperty.SetValue(pluginsPage, pageList.Count);
                            }
                            
                            pageList.Add(pluginsPage);
                            FileLog.Log($"Added Plugins tab to preferences dialog\n");
                        }
                    }
                    else
                    {
                        FileLog.Log($"Pages property is not IList: {pages?.GetType()?.FullName}\n");
                    }
                }
                else
                {
                    FileLog.Log($"Could not find Pages property in PreferencesDialog\n");
                }
            }
            catch (Exception ex)
            {
                FileLog.Log($"Error in PreferencesDialog postfix: {ex.Message}\n{ex.StackTrace}\n");
            }
        }
    }
}
