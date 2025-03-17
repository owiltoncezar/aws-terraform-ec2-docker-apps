const express = require('express');
const redis = require('redis');
const client = require('prom-client');
const app = express();
const port = 3000;

// Configuração inicial das métricas Prometheus
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();
const requestCounter = new client.Counter({
  name: 'node_app_requests_total',
  help: 'Contador de requisições feitas à aplicação Node.js',
});
const responseDuration = new client.Histogram({
  name: 'node_app_response_duration_seconds',
  help: 'Duração das respostas da aplicação Node.js',
  buckets: [0.1, 0.3, 0.5, 1, 2, 5],
});

// Conexão com o Redis para cache
const redisClient = redis.createClient({ host: 'redis', port: 6379 });

let counter = 0;

// Endpoint que mostra uma página HTML simples com contador de visitas
app.get('/fixed', (req, res) => {
  requestCounter.inc();
  counter++;
  const end = responseDuration.startTimer();
  res.send(`
        <h1>Bem-vindo à aplicação Node.js!</h1>
        <p><strong>Mãe to na Globo!!!</strong></p>
        <p>Acessos: <strong>${counter}</strong></p>
    `);
  end();
});

// Endpoint que demonstra o uso de cache com Redis
app.get('/time', (req, res) => {
  requestCounter.inc();
  const end = responseDuration.startTimer();
  redisClient.get('current_time', (err, cachedTime) => {
    if (cachedTime) {
      end();
      return res.send(`O horário atual (do cache) é: ${cachedTime}`);
    }
    const currentTime = new Date().toISOString();
    redisClient.setex('current_time', 60, currentTime);  // Cache por 1 minuto
    end();
    res.send(`O horário atual (gerado) é: ${currentTime}`);
  });
});

// Endpoint para expor métricas ao Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// Inicialização do servidor web
app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});