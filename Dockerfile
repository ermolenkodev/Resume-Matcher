FROM python:3.12-slim

# install nodejs
RUN apt-get update && apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# copy dependency files
COPY package.json package-lock.json ./
COPY apps/backend/requirements.txt apps/backend/
COPY apps/frontend/package.json apps/frontend/
COPY apps/frontend/package-lock.json apps/frontend/

# install dependencies
RUN npm ci && \
    npm ci --prefix apps/frontend && \
    pip install --no-cache-dir -r apps/backend/requirements.txt

# copy application
COPY . .
RUN cp apps/backend/.env.sample apps/backend/.env && \
    cp apps/frontend/.env.sample apps/frontend/.env && \
    npm run build:frontend

EXPOSE 3000 8000

CMD bash -c "cd apps/backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 & cd ../frontend && npx next start -H 0.0.0.0 -p 3000"
