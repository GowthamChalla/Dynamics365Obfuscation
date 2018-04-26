namespace Microsoft.Dynamics.Obfuscation.Support
{
	using System;

	public class RecentPastDateTimeObfuscator : IObfuscationAgent
	{
		public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
		{
			try
			{
				result = DateTime.Now
					.AddDays(-engine.CurrentRandom.NextInt(0, 5 * 365))
					.AddHours(engine.CurrentRandom.NextInt(0, 24))
					.AddMinutes(engine.CurrentRandom.NextInt(0, 60))
					.AddMilliseconds(engine.CurrentRandom.NextInt(0, 60000));
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
