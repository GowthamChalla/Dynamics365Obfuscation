namespace Microsoft.Dynamics.Obfuscation.Support
{
    using System;
    using System.Globalization;
    using Microsoft.Dynamics.Ics.Storage;
    public class LastNameObfuscator : IObfuscationAgent
    {
        private const string repositoryName = "obfuscation";
        private const string lastNameFile = "all-last.txt";
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {            
            result = string.Empty;
            try
            {
                if (engine.ContainsReference("STORAGECLIENT"))
                {
                    var storageClient = engine.GetOrAddReference("STORAGECLIENT", (obfuscationEngine) => null) as IcsStorageClient;
                    
                    var blob = storageClient.LoadBlob(repositoryName, lastNameFile);

                    string[] names = blob.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);
                    result = names.GetValue(engine.CurrentRandom.NextInt(names.Length - 1)).ToString();
                    engine.AddOrReplaceReference("LASTNAME", result);
                    //result = engine.GetOrAddReference(lastName, (obfuscationEngine) => (previous ?? string.Empty).ToString());
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
