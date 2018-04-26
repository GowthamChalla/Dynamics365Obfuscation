namespace Microsoft.Dynamics.Obfuscation.Support
{
    using System;
    using System.Globalization;
    using Microsoft.Dynamics.Ics.Storage;
    public class TitlePrefixObfuscator : IObfuscationAgent
    {        
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {
            result = string.Empty;
            string gender = string.Empty;
            string[] genderArray = { "Male", "Female" };            
            string[] malePrefixes = { "Mr", "Master" };
            string[] femalePrefixes = {"Mrs", "Ms", "Miss", "Madame", "Maid" };
            try
            {
                if (engine.ContainsReference("STORAGECLIENT"))
                {
                    var storageClient = engine.GetOrAddReference("STORAGECLIENT", (obfuscationEngine) => null) as IcsStorageClient;

                    if (engine.ContainsReference("GENDER"))
                    {
                        gender = engine.GetOrAddReference("GENDER", (obfuscationEngine) => string.Empty).ToString();                        
                    }
                    else
                    {
                        gender = genderArray[engine.CurrentRandom.NextInt(0, 1)].ToString();
                    }
                    if (gender.StartsWith("M", StringComparison.InvariantCultureIgnoreCase))
                    {
                        result = malePrefixes.GetValue(engine.CurrentRandom.NextInt(malePrefixes.Length - 1)).ToString();
                    }
                    else
                    {
                        result = femalePrefixes.GetValue(engine.CurrentRandom.NextInt(femalePrefixes.Length - 1)).ToString();
                    }                   
                    return true;
                }
            }
            catch
            {
                result = (previous ?? string.Empty).ToString();
                return false;
            }
            result = (previous ?? string.Empty).ToString();
            return false;
        }
    }
}
