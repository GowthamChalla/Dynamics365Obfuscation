namespace Microsoft.Dynamics.Obfuscation.Support
{
	using System;

	public class BirthDateObfuscator : IObfuscationAgent
	{
		public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
		{
			try
			{
				result = (new DateTime(DateTime.Now.Year - engine.CurrentRandom.NextInt(1, 101), engine.CurrentRandom.NextInt(1, 13), 1))
					.AddDays(engine.CurrentRandom.NextInt(0, 32));
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
