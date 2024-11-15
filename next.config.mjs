/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  env: {
    NEXT_PUBLIC_WOODLAND_CREATURE: process.env.NEXT_PUBLIC_WOODLAND_CREATURE,
  },
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://localhost:3000/api/:path*', // Proxy to backend during development
      },
    ];
  },
};


export default nextConfig;
