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

  // If apiKey is provided, display it
  if (apiKey) {
    return (
      <div>
        <h2>Retrieved API Key:</h2>
        <p>{apiKey}</p>
      </div>
    );
  }

  // If no apiKey and no error, display a loading message
  return <div>Loading...</div>;
};

export default SSMParameterDisplay;
