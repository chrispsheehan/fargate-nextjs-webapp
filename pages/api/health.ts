// pages/api/health.ts

import { NextApiRequest, NextApiResponse } from 'next';

export default function handler(req: NextApiRequest, res: NextApiResponse) {
    console.log("Health check endpoint was hit"); 
    res.status(200).json({ status: 'ok' });
}
