FROM node:20

ARG _aws_region
ENV AWS_REGION=$_aws_region

ARG _api_key_ssm_param_name
ENV API_KEY_SSM_PARAM_NAME=$_api_key_ssm_param_name

WORKDIR /app  

COPY ./src /app

RUN npm i

RUN npm run build --prefix /app

EXPOSE 3000  

CMD ["npm", "run", "start"]