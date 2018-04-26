namespace Microsoft.Dynamics.Obfuscation.Support
{
    public class GenderObfuscator : IObfuscationAgent
    {
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {
            try
            {              
                if (!engine.ContainsReference("GENDER"))
                {                    
                    var genderArray = new string[] { "Male", "Female" };
                    result = genderArray[engine.CurrentRandom.NextInt(0, 1)].ToString();
                    engine.AddOrReplaceReference("GENDER", result);                    
                    return true;
                }
                else
                {
                    result = previous;
                    return false;
                }
            }
            catch
            {
                result = previous;
                return false;
            }
        }
    }
}
