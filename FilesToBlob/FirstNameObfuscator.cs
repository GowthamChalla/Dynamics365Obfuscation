namespace Microsoft.Dynamics.Obfuscation.Support
{
    using Microsoft.Dynamics.Ics.Storage;
    using System;

    public class FirstNameObfuscator : IObfuscationAgent
    {

        private const string repositoryName = "obfuscation";
        private const string maleFirstNameFile = "male-first.txt";
        private const string femaleFirstNameFile = "female-first.txt";

        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {            
            result = string.Empty;
            try
            {
                IcsStorageClient storageClient = null;
                string blob = string.Empty;
                string gender = string.Empty;
                if (engine.ContainsReference("STORAGECLIENT"))
                {
                    storageClient = engine.GetOrAddReference("STORAGECLIENT", (obfuscationEngine) => null) as IcsStorageClient;
                    if (engine.ContainsReference("GENDER"))
                    {
                        gender = engine.GetOrAddReference("GENDER", (obfuscationEngine) => string.Empty).ToString();
                        blob = storageClient.LoadBlob(repositoryName,
                                gender.StartsWith("M", StringComparison.InvariantCultureIgnoreCase) ? maleFirstNameFile : femaleFirstNameFile);
                    }
                    else
                    {
                        blob = storageClient.LoadBlob(repositoryName,
                                engine.CurrentRandom.Next(2) == 0 ? maleFirstNameFile : femaleFirstNameFile);

                    }

                    string[] names = blob.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);
                    result = names.GetValue(engine.CurrentRandom.NextInt(names.Length - 1)).ToString();
                    engine.AddOrReplaceReference("FIRSTNAME", result);                        
                    //result = engine.GetOrAddReference(string.Format("FIRSTNAME={0}", firstName), (obfuscationEngine) => (previous ?? string.Empty).ToString());
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
