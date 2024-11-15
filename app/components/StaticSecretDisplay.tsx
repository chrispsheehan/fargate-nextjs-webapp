// components/StaticSecretDisplay.tsx
import React from 'react';

interface StaticSecretDisplayProps {
  secret: string;
}

const StaticSecretDisplay: React.FC<StaticSecretDisplayProps> = ({ secret }) => {
  return (
    <div style={{ padding: '1em', border: '1px solid #ccc', borderRadius: '8px', width: 'fit-content', marginTop: '1em' }}>
      <h2>Static Secret Display using getServerSideProps()</h2>
      <h3>Only first and last characters are shown</h3>
      <p style={{ fontWeight: 'bold', color: '#333', fontSize: '1.2em' }}>{secret || 'Secret not specified'}</p>
    </div>
  );
};

export default StaticSecretDisplay;
