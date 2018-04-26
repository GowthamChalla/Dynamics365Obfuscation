namespace Microsoft.Dynamics.Obfuscation.Support
{
	public class USCityObfuscator : IObfuscationAgent
	{
		public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
		{
			try
			{
				if (engine.ContainsReference("ZIP"))
				{
					string zip = engine.GetOrAddReference("ZIP", (obfuscationEngine) => string.Empty).ToString();
					result = engine.GetOrAddReference(string.Format("ZIP={0}/CITY", zip), (obfuscationEngine) => (previous ?? string.Empty).ToString());
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
