FROM node:20

ARG _aws_region
ENV AWS_REGION=$_aws_region

ARG _api_key_ssm_param_name
ENV API_KEY_SSM_PARAM_NAME=$_api_key_ssm_param_name

ARG _next_public_woodland_creature
ENV NEXT_PUBLIC_WOODLAND_CREATURE==$_next_public_woodland_creature

ARG _secret_woodland_creature
ENV SECRET_WOODLAND_CREATURE=$_secret_woodland_creature


WORKDIR /app  

COPY ./src /app

RUN npm i

RUN npm run build --prefix /app

EXPOSE 3000  

CMD ["npm", "run", "start"]