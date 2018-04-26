namespace Microsoft.Dynamics.Obfuscation.Support
{
    using System;
    using System.Linq;

    public class EmailObfuscator : IObfuscationAgent
    {
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {
            try
            {
                var domainNames = new string[] { "azure", "powerbi", "bing", "office365", "xbox", "msn", "dynamics365", "yammer", "sharepoint" };
                var domainExtension = new string[] { "com", "us", "org ", "net" };
                
                result = string.Format("{0}.{1}@{2}.{3}"
                    , engine.GetOrAddReference("FIRSTNAME", (obfuscationengine) => GetMailBoxName()).ToString()
                    , engine.GetOrAddReference("LASTNAME", (obfuscationengine) => GetMailBoxName()).ToString()
                    , domainNames.GetValue(engine.CurrentRandom.NextInt(domainNames.Length - 1)).ToString()
                    , domainExtension.GetValue(engine.CurrentRandom.NextInt(domainExtension.Length - 1)).ToString()
                    );

                return true;
            }
            catch
            {
                result = (previous ?? string.Empty).ToString();
                return false;
            }            
        }
        private string GetMailBoxName()
        {
            string alphaNumericChars = "abcdefghijklmnopqrstuvwxyz";
            int defaultMailboxLength = 10;
            Random random = new Random();            
            return new string(Enumerable.Repeat(alphaNumericChars, defaultMailboxLength).Select(chars => chars[random.NextInt(chars.Length)]).ToArray());            
        }
    }
}
