// pages/index.tsx
import SSMParameterDisplay from '../app/components/SSMParameterDisplay';
import WoodlandCreatureDisplay from '../app/components/WoodlandCreatureDisplay';
import React from 'react';

const HomePage: React.FC = () => {
  return (
    <div>
      <h1>Welcome to the Application</h1>

      {/* Render the SSMParameterDisplay component, passing in apiKey or error */}
      <SSMParameterDisplay />
      <WoodlandCreatureDisplay />
    </div>
  );
}

export default HomePage;