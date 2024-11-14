// pages/index.tsx
import { GetParameterCommand, SSMClient } from '@aws-sdk/client-ssm';
import SSMParameterDisplay from '../app/components/SSMParameterDisplay';

// Function to fetch the SSM parameter from AWS
async function fetchSSMParameter(ssmParamKey: string) {
  const client = new SSMClient({ region: process.env.AWS_REGION });  // Use the AWS region from the environment variable
  const command = new GetParameterCommand({
    Name: ssmParamKey,  // Name of the SSM parameter to fetch
    WithDecryption: true,  // Decrypt the parameter if it's encrypted
  });

  try {
    const data = await client.send(command);  // Send the command to fetch the parameter
    return data.Parameter?.Value;  // Return the value of the parameter if successful
  } catch (err) {
    console.error(`Failed to fetch parameter: ${ssmParamKey}`, err);
    return null;  // Return null in case of failure
  }
}

// getServerSideProps fetches the data before rendering the page
export async function getServerSideProps() {
  const ssmParamKey = process.env.API_KEY_SSM_PARAM_NAME;  // Get the SSM parameter key from environment variables

  // If the SSM parameter key is not defined, return an error
  if (!ssmParamKey) {
    return {
      props: {
        error: 'SSM parameter key is not defined in environment variables.',
      },
    };
  }

  // Fetch the SSM parameter
  const apiKey = await fetchSSMParameter(ssmParamKey);

  // If the API key is not found or there was an error, return an error
  if (!apiKey) {
    return {
      props: {
        error: 'Failed to retrieve API key from SSM.',
      },
    };
  }

  // Return the fetched API key as a prop to the page component
  return {
    props: {
      apiKey,
    },
  };
}

// The page component which receives props from getServerSideProps
export default function HomePage({ apiKey, error }: { apiKey?: string; error?: string }) {
  return (
    <div>
      <h1>Welcome to the Application</h1>

      {/* Render the SSMParameterDisplay component, passing in apiKey or error */}
      <SSMParameterDisplay apiKey={apiKey} error={error} />
    </div>
  );
}
