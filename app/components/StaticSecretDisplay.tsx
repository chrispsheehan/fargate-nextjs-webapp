// components/StaticSecretDisplay.tsx
import React from 'react';

interface StaticSecretDisplayProps {
  secret: string;
}

const StaticSecretDisplay: React.FC<StaticSecretDisplayProps> = ({ secret }) => {
  return (
    <div>
      <h2>Our Static Secret</h2>
      <h3>Set via server-side environment variable (ECS secret loaded at startup)</h3>
      <p>{secret ? `The static secret is: ${secret}` : "Secret not specified"}</p>
    </div>
  );
};

export default StaticSecretDisplay;
