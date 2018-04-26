namespace Microsoft.Dynamics.Obfuscation.Support
{
	using System;

	public class GuidObfuscator : IObfuscationAgent
	{
		public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
		{
			try
			{
				result = Guid.NewGuid();
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
