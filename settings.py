import os

sitename = 'docker'
ENABLE_SOCIAL = False

from settings_common import *

TEMPDIR = '/tmp'

#DATABASES['default']['NAME'] = 'an-docker'

DATABASES['default']['ENGINE'] = 'django.db.backends.sqlite3'
DATABASES['default']['NAME'] = os.path.join(
    os.path.dirname(astrometry.net.__file__),
    'django.sqlite3')

LOGGING['loggers']['django.request']['level'] = 'WARN'

SESSION_COOKIE_NAME = 'DockerAstrometrySession'

ssh_solver_config = 'an-docker'

try:
    SOCIAL_AUTH_GITHUB_KEY    = github_secrets[sitename].key
    SOCIAL_AUTH_GITHUB_SECRET = github_secrets[sitename].secret
except:
    SOCIAL_AUTH_GITHUB_KEY    = None
    SOCIAL_AUTH_GITHUB_SECRET = None
    
