
namespace Microsoft.Dynamics.Obfuscation.Support
{
    public class USAddress2Obfuscator : IObfuscationAgent
    {
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {
            string[] address2Part1 = { "Apt.", "House", "Suite", "Unit" };
            string address2Part2 = engine.CurrentRandom.NextInt(9999).ToString();
            try
            {
                result = address2Part1.GetValue(engine.CurrentRandom.NextInt(address2Part1.Length - 1))
                    + " " + address2Part2;
                return true;
            }
            catch
            {
                result = previous;
                return false;
            }
        }
    }
}