from flask import Flask
import redis
import time
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)
counter = 0

# Configuração do Redis
cache = redis.StrictRedis(host='redis', port=6379, db=0)

# Endpoint com página HTML simples e contador de visitas
@app.route('/fixed')
def fixed_message():
    global counter
    counter += 1
    return '''
        <h1>Bem-vindo à aplicação Flask!</h1>
        <p><strong>Mãe to na Globo!!!</strong></p>
        <p>Acessos: <strong>''' + str(counter) + '''</strong></p>
    '''

# Endpoint que demonstra uso de cache com Redis
@app.route('/time')
def time_message():
    # Verifica cache ou gera novo horário
    cached_time = cache.get('current_time')
    if cached_time:
        return f'O horário atual (do cache) é: {cached_time.decode("utf-8")}'
    
    current_time = time.strftime('%Y-%m-%d %H:%M:%S')
    cache.setex('current_time', 10, current_time)  # Cache por 10 segundos
    return f'O horário atual (gerado) é: {current_time}'

# Inicialização do servidor
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)