# Healthchecks

> [!NOTE] This repository serves as the source code behind my healthchecks dashboard.

## Table of Contents

- [About](#about)
- [Getting Started](#getting-started)
  - [Setup Environment Variables](#setup-environment-variables)
  - [Run the Service](#run-the-service)
  - [Configure the Service](#configure-the-service)
  - [TLS Termination](#tls-termination)
- [Docker Images](#docker-images)


## About

This repository serves as the source code behind my healthchecks dashboard.

The site runs using the [healthchecks.io](https://healthchecks.io) service, which is a free service that allows you to
monitor your cron jobs, scheduled tasks, and background jobs.

The project is setup and configured to run the Healthchecks service via [Docker]() and [Docker Compose]().

> [!NOTE] For simplicity, the configuration starts a single database node and a single web-server node, both on the same
> "host" network. It doe not handle `TLS` termination.

The service is run via [Docker](https://www.docker.com/), and is deployed to [Azure](https://azure.microsoft.com/en-us/).

## Getting Started

### Setup Environment Variables

- Replace [`.env.example`](.env.example) with a `.env` file containing your configuration variables:

```bash
cp .env.example .env
```

- At a minimum, populate the following variables in `.env`:
  - `DEFAULT_FROM_EMAIL`: the "From:" email address to use for outbound emails.
  - `EMAIL_HOST`: the SMTP server to use for outbound emails.
  - `EMAIL_HOST_PASSWORD`: the password for the SMTP server.
  - `EMAIL_HOST_USER`: the username for the SMTP server.
  - `SECRET_KEY`: the secret key to use for the HTTP session (can be a random string).
    - *Note: Secret Key is associated with Flask / Django applications. See [here](https://flask.palletsprojects.com/en/1.1.x/quickstart/#sessions) for more information.*

Example `.env` file:

```text
DEFAULT_FROM_EMAIL=""
EMAIL_HOST=""
EMAIL_HOST_PASSWORD=""
EMAIL_HOST_USER=""
SECRET_KEY=""
```

<details><summary>View Full Example Variables</summary><p>

```text
# HEALTHCHECKS ENVIRONMENT VARIABLES

# DEBUG
DEBUG=False

# SITE
ALLOWED_HOSTS=localhost # ,127.0.0.1,jimbrig.com,jimbrig.dev
SITE_ROOT=http://localhost:8000 # https://healthchecks.jimbrig.dev
SITE_NAME=HealthChecks
SITE_LOGO_URL=
REGISTRATION_OPEN=True

# API
SECRET_KEY=mysecretkey
REMOTE_USER_HEADER=

# WEBHOOKS
WEBHOOKS_ENABLED=True

# PING
PING_BODY_LIMIT=10000
PING_EMAIL_DOMAIN=localhost
PING_ENDPOINT=http://localhost:8000/ping/

# EMAIL
DEFAULT_FROM_EMAIL=healthchecks@jimbrig.com
EMAIL_HOST=smtp.gmail.com
EMAIL_HOST_PASSWORD=---
EMAIL_HOST_USER=healthchecks@jimbrig.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_USE_VERIFICATION=True

# DATABASE
DB=postgres
DB_CONN_MAX_AGE=0
DB_HOST=db
DB_NAME=healthchecks
DB_PASSWORD=P@ssword1
DB_PORT=5432
DB_SSLMODE=prefer
DB_TARGET_SESSION_ATTRS=read-write
DB_USER=postgres

# MISC
MASTER_BADGE_LABEL=HealthChecks

# INTEGRATIONS
INTEGRATIONS_ALLOW_PRIVATE_IPS=False

# APPRISE
APPRISE_ENABLED=False

# DISCORD
DISCORD_CLIENT_ID=
DISCORD_CLIENT_SECRET=

# LINENOTIFY
LINENOTIFY_CLIENT_ID=
LINENOTIFY_CLIENT_SECRET=

# MATRIX
MATRIX_ACCESS_TOKEN=
MATRIX_HOMESERVER=
MATRIX_USER_ID=

# MATTERMOST
MATTERMOST_ENABLED=True

# MICROSOFT TEAMS
MSTEAMS_ENABLED=True

# OPSGENIE
OPSGENIE_ENABLED=True

# PAGERTREE
PAGERTREE_ENABLED=True

# PD
PD_APP_ID=
PD_ENABLED=True

# PROMETHEUS
PROMETHEUS_ENABLED=True

# PUSHBULLET
PUSHBULLET_CLIENT_ID=
PUSHBULLET_CLIENT_SECRET=

# PUSHOVER
PUSHOVER_API_TOKEN=
PUSHOVER_EMERGENCY_EXPIRATION=86400
PUSHOVER_EMERGENCY_RETRY_DELAY=300
PUSHOVER_SUBSCRIPTION_URL=

# ROCKETCHAT
ROCKETCHAT_ENABLED=True

# RP
RP_ID=

# AWS S3
S3_ACCESS_KEY=
S3_BUCKET=
S3_ENDPOINT=
S3_REGION=
S3_SECRET_KEY=
S3_TIMEOUT=60

# SHELL
SHELL_ENABLED=False

# SIGNAL
SIGNAL_CLI_SOCKET=

# SLACK
SLACK_CLIENT_ID=
SLACK_CLIENT_SECRET=
SLACK_ENABLED=True

# SMTPD
# SMTPD_PORT=

# SPIKE
SPIKE_ENABLED=True

# TELEGRAM
TELEGRAM_BOT_NAME=
TELEGRAM_TOKEN=

# TRELLO
TRELLO_APP_KEY=

# TWILIO
TWILIO_ACCOUNT=
TWILIO_AUTH=
TWILIO_FROM=
TWILIO_USE_WHATSAPP=False

# PAYMENTS
USE_PAYMENTS=False

# VICTOROPS
VICTOROPS_ENABLED=True

# ZULIP
ZULIP_ENABLED=True

```

</p></details>

### Run the Service

- Create and start the containers via `docker-compose`:

```bash
docker-compose up -d
```

- Verify the containers are running:

```bash
docker-compose ps
```

- Create a *SuperUser*:

```bash
docker-compose run web /opt/healthchecks/manage.py createsuperuser
```

This runs the `createsuperuser` management command inside the web container to create an administrative user for the
[Django Admin Interface](https://docs.djangoproject.com/en/3.1/ref/contrib/admin/).

- Navigate to the Healthchecks dashboard at [http://localhost:8000](http://localhost:8000) in your local web-browser and
log in with the credentials from the previous step.

### Configure the Service

> [!NOTE] The server runs via `uWSGI`, which is a full-featured Python web application server. See the `uwsgi.ini` file
> for configuration details.

The [Dockerfile](./Dockerfile) uses [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/) as its `WSGI` server.

You can configure `uWSGI` by setting `UWSGI_` environment variables in the `.env` file.

For example, to disable HTTP request logging, set `UWSGI_DISABLE_LOGGING=1` in the `.env` file:

```text
UWSGI_DISABLE_LOGGING=1
```

Read more about configuring uWSGI in the [uWSGI documentation](https://uwsgi-docs.readthedocs.io/en/latest/).

### TLS Termination

If you plan to expose your Healthchecks instance to the public internet, make sure you put a TLS-terminating reverse proxy or load balancer in front of it.

Important: This Dockerfile uses UWSGI, which relies on the [X-Forwarded-Proto](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-Proto) header to determine if a request is secure or not. Make sure your TLS-terminating reverse proxy:

- Discards the X-Forwarded-Proto header sent by the end user.
- Sets the X-Forwarded-Proto header value to match the protocol of the original request ("http" or "https").

For example, in [NGINX](https://www.nginx.com/) you can use the `$scheme` variable like so:

```text
proxy_set_header X-Forwarded-Proto $scheme;
```

## Docker Images

Pre-built Docker Images, built from the [Dockerfile](./Dockerfile) in this repository are available both on
- [Docker Hub](https://hub.docker.com/r/healthchecks/healthchecks) (`healthchecks/healthchecks`)
- [GitHub Container Registry](https://github.com/users/healthchecks/packages/container/package/healthchecks) (`ghcr.io`)

The docker images are automatically built every release and support the following features:

- Support `amd64`, `arm/v7` and `arm64` architectures.
- Use `uWSGI` as the web server. `uWSGI` is configured to perform database migrations on startup, and to run *sendalerts*, *sendreports*, and *smtpd* in the background. You do not need to run them separately.
- Ship with both `PostgreSQL` and `MySQL` database drivers.
- Serve static files using the `whitenoise` library.
- Have the `apprise` library preinstalled.
- Do not handle `TLS` termination. In a production setup, you will want to put the Healthchecks container behind a *reverse proxy or load balancer that handles TLS termination*.
