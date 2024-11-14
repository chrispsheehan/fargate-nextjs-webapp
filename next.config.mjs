/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  env: {
    NEXT_PUBLIC_WOODLAND_CREATURE: process.env.NEXT_PUBLIC_WOODLAND_CREATURE,
  },
};


export default nextConfig;
