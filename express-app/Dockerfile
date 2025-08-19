# ADD CODE HERE
# Use a lightweight Node.js base image
FROM node:18-alpine
# Set the working directory
WORKDIR /usr/src/app
# Copy the package.json and install dependencies
COPY package*.json ./
RUN npm install
# Copy the application code
COPY express.js .
# Document the port
EXPOSE 4567
# Define the command to run the app
CMD [ "node", "express.js" ]