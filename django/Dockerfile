FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Збираємо статичні файли в образ
RUN python manage.py collectstatic --noinput

# Запускаємо Gunicorn
# -w 3: кількість воркерів (зазвичай формула: (2 x $num_cores) + 1)
# -b 0.0.0.0:8000: біндимо на всі інтерфейси порт 8000
CMD ["gunicorn", "goit.wsgi:application", "-w", "3", "-b", "0.0.0.0:8000"]