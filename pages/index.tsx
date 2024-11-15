// pages/index.tsx
import SSMParameterDisplay from '../app/components/SSMParameterDisplay';
import WoodlandCreatureDisplay from '../app/components/WoodlandCreatureDisplay';
import StaticSecretDisplay from '../app/components/StaticSecretDisplay';
import React from 'react';

interface HomePageProps {
  staticSecret: string;
}

const HomePage: React.FC<HomePageProps> = ({ staticSecret }) => {
  return (
    <div>
      <h1>Welcome to the Application</h1>

      {/* Render the SSMParameterDisplay component */}
      <SSMParameterDisplay />
      <WoodlandCreatureDisplay />
      
      {/* Render the StaticSecretDisplay component with the fetched staticSecret */}
      <StaticSecretDisplay secret={staticSecret} />
    </div>
  );
}

export async function getServerSideProps() {
  // Fetch the STATIC_SECRET from environment variables
  const staticSecret = process.env.STATIC_SECRET || '';

  return {
    props: {
      staticSecret,
    },
  };
}

export default HomePage;
