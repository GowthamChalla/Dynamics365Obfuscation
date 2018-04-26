

namespace Microsoft.Dynamics.Obfuscation.Support
{
    public class USAddress1Obfuscator: IObfuscationAgent
    {
        public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
        {
            string address1Part1 = engine.CurrentRandom.NextInt(99999).ToString();
            string[] address1Part2 = { "Cedar", "Elm", "Hill", "Lake", "Maple", "Oak", "Park", "Pine", "View", "Washington" };
            string[] streets = { "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "Main", "Cedar", "Elm", "Hill", "Lake", "Maple", "Oak", "Park", "Pine", "View", "Washington" };
            string[] address1Part3 = { "Avenue", "Blvd.", "Court", "Drive", "Lane", "Place", "Road", "Street", "Terrace", "Way" };
            string[] directions = { "N", "E", "W", "S", "NE", "SE", "NW", "SW"};
            try
            {
                //string randomPart4 = address1Part4.GetValue(engine.CurrentRandom.NextInt(address1Part4.Length - 1)).ToString();
                string randomPart3 = address1Part3.GetValue(engine.CurrentRandom.NextInt(address1Part3.Length - 1)).ToString();
                if (randomPart3 == "Avenue")
                {
                    result = address1Part1
                        + " " + address1Part2.GetValue(engine.CurrentRandom.NextInt(address1Part2.Length - 1))
                        + " Avenue " + directions.GetValue(engine.CurrentRandom.NextInt(directions.Length - 1)).ToString();
                }
                else if(randomPart3 == "Street")
                {
                    result = address1Part1
                        + " " + directions.GetValue(engine.CurrentRandom.NextInt(directions.Length - 1)).ToString()
                        + " " + streets.GetValue(engine.CurrentRandom.NextInt(streets.Length - 1))
                        + " Street";
                }
                else
                {
                    result = address1Part1
                        + " " + address1Part2.GetValue(engine.CurrentRandom.NextInt(address1Part2.Length - 1))
                        + " " + randomPart3;
                }
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
