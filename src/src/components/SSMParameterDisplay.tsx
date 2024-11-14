// app/components/SSMParameterDisplay.tsx
import { GetParameterCommand, SSMClient } from '@aws-sdk/client-ssm';

const awsRegion = process.env.AWS_REGION;

async function fetchSSMParameter(ssmParamKey: string) {
  const client = new SSMClient({ region: awsRegion });
  const command = new GetParameterCommand({
    Name: ssmParamKey,
    WithDecryption: true,
  });

  console.log('Fetching SSM parameter with key:', ssmParamKey);

  try {
    const data = await client.send(command);
    return data.Parameter?.Value;
  } catch (err) {

    console.error(`Failed to fetch parameter: ${ssmParamKey}`, err);
    return null;
  }
}

export default async function SSMParameterDisplay() {
    const ssmParamKey = process.env.API_KEY_SSM_PARAM_NAME;
    const debugInfo = []; // Array to store debug messages for client display
  
    debugInfo.push('SSMParameterDisplay Component Initialized');
    debugInfo.push(`Environment Variable - API_KEY_SSM_PARAM_NAME: ${ssmParamKey || 'Not defined'}`);
  
    if (!ssmParamKey) {
      debugInfo.push('SSM parameter key is not defined in environment variables.');
      return (
        <div>
          <p>Error: SSM parameter key is not defined.</p>
          <pre>{JSON.stringify(debugInfo, null, 2)}</pre>
        </div>
      );
    }
  
    let apiKey;
    try {
      debugInfo.push(`Attempting to fetch SSM parameter with key: ${ssmParamKey}`);
      apiKey = await fetchSSMParameter(ssmParamKey);
      debugInfo.push(`SSM parameter fetch result: ${apiKey ? 'Success' : 'Failure'}`);
    } catch (error) {
      debugInfo.push(`An error occurred while fetching the SSM parameter: ${error}`);
      return (
        <div>
          <p>Error: Failed to retrieve API key from SSM.</p>
          <pre>{JSON.stringify(debugInfo, null, 2)}</pre>
        </div>
      );
    }
  
    if (!apiKey) {
      debugInfo.push('API key was not retrieved; possibly due to decryption issues or missing parameter.');
      return (
        <div>
          <p>Error: Failed to retrieve API key from SSM.</p>
          <pre>{JSON.stringify(debugInfo, null, 2)}</pre>
        </div>
      );
    }
  
    return (
      <div>
        <p>Retrieved API Key: {apiKey}</p>
        <pre>{JSON.stringify(debugInfo, null, 2)}</pre> {/* Display debug info */}
      </div>
    );
}  