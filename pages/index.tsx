// pages/index.tsx
import React from 'react';
import SSMParameterDisplay from '../app/components/SSMParameterDisplay';
import WoodlandCreatureDisplay from '../app/components/WoodlandCreatureDisplay';
import StaticSecretDisplay from '../app/components/StaticSecretDisplay';

interface HomePageProps {
  staticSecretMasked: string;
}

const HomePage: React.FC<HomePageProps> = ({ staticSecretMasked }) => {
  return (
    <div>
      <h1>Welcome to the Application</h1>

      {/* Render components */}
      <SSMParameterDisplay />
      <WoodlandCreatureDisplay />
      <StaticSecretDisplay secret={staticSecretMasked} />
    </div>
  );
}

export async function getServerSideProps() {
  // Retrieve the secret and mask it to show only the first and last characters
  const secret = process.env.STATIC_SECRET || '';
  const maskedSecret = secret.length > 1 ? `${secret[0]}${'*'.repeat(secret.length - 2)}${secret[secret.length - 1]}` : secret;

  return {
    props: {
      staticSecretMasked: maskedSecret,
    },
  };
}

export default HomePage;
