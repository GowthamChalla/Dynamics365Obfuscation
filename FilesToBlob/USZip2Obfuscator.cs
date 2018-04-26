namespace Microsoft.Dynamics.Obfuscation.Support
{
	using System;
	using System.Net.Http;
	using System.Threading;
    using System.Xml;

    public class USZipCode2Obfuscator : IObfuscationAgent
	{
		private const string UspsServiceUserId = "666HCL000658";

		public bool TryObfuscate(IObfuscationEngine engine, object previous, out object result)
		{
			try
			{
				int attempts = 0;
				string zip = string.Empty;
				do
				{
                    attempts++;
                    zip = Convert.ToString(engine.CurrentRandom.Next(501, 99951));
                    while (zip.Length < 5)
                    {
                        zip = string.Format("0{0}", zip);
                    }
                    if (!engine.ContainsReference(string.Format("ZIP2={0}/CITY", zip)))
                    {
                        try
                        {
                            var url = string.Format(
                                "http://production.shippingapis.com/ShippingAPI.dll?API=CityStateLookup&XML=<CityStateLookupRequest USERID=\"{0}\"><ZipCode ID=\"0\"><Zip5>{1}</Zip5></ZipCode></CityStateLookupRequest>",
                                USZipCodeObfuscator.UspsServiceUserId,
                                zip);
                            using (var httpClient = new HttpClient())
                            {
                                var response = httpClient.GetStringAsync(url).GetAwaiter().GetResult();
                                var document = new XmlDocument();
                                document.LoadXml(response);
                                if (document.DocumentElement.SelectSingleNode("ZipCode/City") != null &&
                                    document.DocumentElement.SelectSingleNode("ZipCode/State") != null)
                                {
                                    engine.AddOrReplaceReference(string.Format("ZIP2={0}/CITY", zip), document.DocumentElement.SelectSingleNode("ZipCode/City").InnerText);
                                    engine.AddOrReplaceReference(string.Format("ZIP2={0}/STATE", zip), document.DocumentElement.SelectSingleNode("ZipCode/State").InnerText);
                                }
                                else
                                {
                                    zip = null;
                                }
                                document = null;
                            }
                        }
                        catch
                        {
                            Thread.Sleep(1000);
                            zip = null;
                        }
                    }
                }
				while (string.IsNullOrEmpty(zip) && attempts < 6);
				if (string.IsNullOrEmpty(zip))
				{
					result = (previous ?? string.Empty).ToString();
					return false;
				}
				result = zip;
				engine.AddOrReplaceReference("ZIP2", zip);
				return true;
			}
			catch
			{
				result = (previous ?? string.Empty).ToString();
				return false;
			}
		}
	}
}