/** @type {import('next').NextConfig} */
const nextConfig = {
    env: {
        NEXT_PUBLIC_WOODLAND_CREATURE: process.env.NEXT_PUBLIC_WOODLAND_CREATURE,
        SECRET_WOODLAND_CREATURE: process.env.SECRET_WOODLAND_CREATURE
    }
};

export default nextConfig;
