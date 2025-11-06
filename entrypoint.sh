#!/bin/sh
set -e

# If DB host is not provided, skip migrations (useful for standalone runs without DB)
if [ -z "$DB_HOST" ]; then
	echo "DB_HOST not set — skipping migrate. If you expect a DB, run with docker-compose or set DB_ env vars."
else
	echo "DB_HOST is set to '$DB_HOST' — attempting to run migrations (will retry until DB is ready)."
	# wait for DB to become available (simple retry loop)
	MAX_RETRIES=30
	SLEEP_SECONDS=2
	n=0
	until python manage.py migrate --noinput; do
		n=$((n+1))
		if [ "$n" -ge "$MAX_RETRIES" ]; then
			echo "Migrations failed after $n attempts — exiting." >&2
			exit 1
		fi
		echo "Migration attempt $n/$MAX_RETRIES failed, retrying in $SLEEP_SECONDS seconds..."
		sleep $SLEEP_SECONDS
	done
fi

# Collect static files if needed (uncomment if serving static files in production)
# python manage.py collectstatic --noinput

# Exec the passed command (gunicorn by default)
exec "$@"
