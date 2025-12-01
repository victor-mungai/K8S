FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y git stress wget && \
    git clone https://github.com/hkhcoder/vprofile-project.git .  && \
    git checkout monitoring && \
    pip install -r ./titan/requirments.txt && \
    wget -q -P /usr/local/bin/ https://raw.githubusercontent.com/hkhcoder/vprofile-project/refs/heads/monitoring/load.sh && \
    wget -q -P /usr/local/bin/ https://raw.githubusercontent.com/hkhcoder/vprofile-project/refs/heads/monitoring/generate_multi_logs.sh && \
    chmod +x titan/app.py /usr/local/bin/load.sh /usr/local/bin/generate_multi_logs.sh && \
    apt-get purge -y git && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]

