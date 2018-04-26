namespace Microsoft.Dynamics.Obfuscation.Support
{
    public class USPhoneNumberObfuscator : IObfuscationAgent
    {
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {
            try
            {
                result = string.Format("{0}-0{1}-0{2}"
                    , engine.CurrentRandom.NextInt(100, 999)
                    , engine.CurrentRandom.NextInt(1, 999)
                    , engine.CurrentRandom.NextInt(1, 9999));
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