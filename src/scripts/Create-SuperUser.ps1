#!/usr/bin/env pwsh

<#
#>

docker-compose run web /opt/healthchecks/manage.py createsuperuser
