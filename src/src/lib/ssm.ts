// lib/ssm.js
import { GetParameterCommand, SSMClient } from '@aws-sdk/client-ssm';

const awsRegion = process.env.AWS_REGION;

export async function getParameter(ssm_param_key: string | undefined) {
    if (!ssm_param_key) {
        throw new Error('SSM parameter key is undefined.');
    }

    const client = new SSMClient({ region: awsRegion });
    const command = new GetParameterCommand({
        Name: ssm_param_key,
        WithDecryption: true,
    });

    try {
        const data = await client.send(command);
        return data.Parameter?.Value;
    } catch (err) {
        console.error("Failed to fetch parameter:", err);
    }
}
