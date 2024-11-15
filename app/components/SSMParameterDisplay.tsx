// components/SSMParameterDisplay.tsx
import React, { useEffect, useState } from 'react';

const SSMParameterDisplay: React.FC = () => {
  const [apiKeyMasked, setApiKeyMasked] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchApiKey = async () => {
      try {
        const response = await fetch('/api/getApiKey');
        if (!response.ok) {
          throw new Error("Failed to fetch API key");
        }

        const data = await response.json();
        console.log("API Response:", data); // Log API response for confirmation

        if (data.apiKeyMasked) {
          setApiKeyMasked(data.apiKeyMasked); // Use the masked key directly from the response
        } else {
          throw new Error("API key not found in response");
        }
      } catch (err) {
        console.error("Error fetching masked API key:", err);
        setError("Error fetching API key");
      }
    };

    fetchApiKey();
  }, []);

  return (
    <div style={{ padding: '1em', border: '1px solid #ccc', borderRadius: '8px', width: 'fit-content', marginTop: '1em' }}>
      <h2>API Key Accessed server side SSM PoC</h2>
      <h3>First / last characters below</h3>
      {error ? (
        <p style={{ color: 'red' }}>Error: {error}</p>
      ) : (
        <p style={{ fontWeight: 'bold', color: '#333', fontSize: '1.2em' }}>{apiKeyMasked || 'Loading...'}</p>
      )}
    </div>
  );
};

export default SSMParameterDisplay;
