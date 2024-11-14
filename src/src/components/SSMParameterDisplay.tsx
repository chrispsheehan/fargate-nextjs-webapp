// app/components/SSMParameterDisplay.tsx
import { GetParameterCommand, SSMClient } from '@aws-sdk/client-ssm';

const awsRegion = process.env.AWS_REGION;

async function fetchSSMParameter(ssmParamKey: string) {
  const client = new SSMClient({ region: awsRegion });
  const command = new GetParameterCommand({
    Name: ssmParamKey,
    WithDecryption: true,
  });

  try {
    const data = await client.send(command);
    return data.Parameter?.Value;
  } catch (err) {
    console.error('Failed to fetch parameter:', err);
    return null;
  }
}

export default async function SSMParameterDisplay() {
  const ssmParamKey = process.env.API_KEY_SSM_PARAM_NAME;
  if (!ssmParamKey) {
    console.error('SSM parameter key is not defined.');
    return <p>Error: SSM parameter key is not defined.</p>;
  }

  const apiKey = await fetchSSMParameter(ssmParamKey);
  if (!apiKey) {
    return <p>Error: Failed to retrieve API key from SSM.</p>;
  }

  return (
    <div>
      <p>Retrieved API Key: {apiKey}</p>
    </div>
  );
}
