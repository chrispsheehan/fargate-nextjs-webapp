// components/SSMParameterDisplay.tsx
import React from 'react';

// Allow apiKey and error to be string or undefined
interface SSMParameterDisplayProps {
  apiKey?: string;  // Optional prop
  error?: string;   // Optional prop
}

const SSMParameterDisplay: React.FC<SSMParameterDisplayProps> = ({ apiKey, error }) => {
  // If there's an error, display the error message
  if (error) {
    return <div>Error: {error}</div>;
  }

  // Display the first and last character of the apiKey if it exists
  if (apiKey) {
    const firstChar = apiKey[0];
    const lastChar = apiKey.slice(-1);
    return (
      <div>
        <h2>API Key Retrieved from SSM:</h2>
        <p>
          <strong>First Character:</strong> {firstChar} <br />
          <strong>Last Character:</strong> {lastChar}
        </p>
      </div>
    );
  }

  // If no apiKey and no error, display a loading message
  return <div>Loading...</div>;
};

export default SSMParameterDisplay;
