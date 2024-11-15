// pages/api/getApiKey.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import { GetParameterCommand, SSMClient } from '@aws-sdk/client-ssm';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const ssmParamKey = process.env.API_KEY_SSM_PARAM_NAME;
  if (!ssmParamKey) {
    return res.status(500).json({ error: 'SSM parameter key is not defined' });
  }

  const client = new SSMClient({ region: process.env.AWS_REGION });
  const command = new GetParameterCommand({ Name: ssmParamKey, WithDecryption: true });

  try {
    const data = await client.send(command);
    const apiKey = data.Parameter?.Value;
    if (!apiKey) throw new Error('API key not found');

    // Return only a masked version of the API key, or data that does not expose it
    res.status(200).json({ apiKeyMasked: `${apiKey[0]}...${apiKey[apiKey.length - 1]}` });
  } catch (error) {
    console.error('Error fetching API key:', error);
    res.status(500).json({ error: 'Failed to retrieve API key' });
  }
}
