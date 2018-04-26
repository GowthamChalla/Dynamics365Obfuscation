
namespace Microsoft.Dynamics.Obfuscation.Support
{
    public class USAddress3Obfuscator : IObfuscationAgent
    {
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {
            string[] address3Part1 = { "Apt.", "House", "Suite", "Unit" };
            string address3Part2 = engine.CurrentRandom.NextInt(9999).ToString();
            try
            {
                result = address3Part1.GetValue(engine.CurrentRandom.NextInt(address3Part1.Length - 1))
                    + " " + address3Part2;
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