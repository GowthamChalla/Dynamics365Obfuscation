namespace Microsoft.Dynamics.Obfuscation.Support
{
	public class IntObfuscator : IObfuscationAgent
	{
		public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
		{
			try
			{
				result = engine.CurrentRandom.Next();
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
