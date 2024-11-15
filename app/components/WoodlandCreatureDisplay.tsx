// components/WoodlandCreatureDisplay.tsx
import React from 'react';

const WoodlandCreatureDisplay: React.FC = () => {
  const creature = process.env.NEXT_PUBLIC_WOODLAND_CREATURE;

  return (
    <div>
      <h2>Our Woodland Creature</h2>
      <p>{creature ? `The woodland creature is a ${creature}` : "Creature not specified"}</p>
    </div>
  );
};

export default WoodlandCreatureDisplay;
