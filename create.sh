### STILL WIP ###

## QUICKLY CREATE A DJANGO APP ##
#
# args:
# $1: app_name
# $2: app_path
#
# example:
# $ chmod +x create_boilerplate.sh
# $ ./create_boilerplate.sh my_app profile 
#

PORT=8001
APP_NAME=$1 # script accepts 1 argument: app name
FIRST_APP_NAME=$2 # script accepts 2 arguments: first app name

mkdir django_$APP_NAME

cd django_$APP_NAME

python3 -m venv venv

source venv/bin/activate

pip install django

django-admin startproject django_$APP_NAME .


## Create First App ##

python3 manage.py startapp $FIRST_APP_NAME

cd $FIRST_APP_NAME

# mkdir templates/home/ in templates folder
mkdir templates/
mkdir templates/$FIRST_APP_NAME/


# create model class in models.py
cat > models.py << EOF
from django.db import models
from django.urls import reverse

class ${FIRST_APP_NAME}(models.Model): 
    name = models.CharField(max_length=100)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name
    
    def get_absolute_url(self):
        return reverse('${FIRST_APP_NAME}_view', kwargs={'pk': self.pk})
EOF


# create new form in forms.py
cat > forms.py << EOF
from django import forms
from .models import ${FIRST_APP_NAME}

class ${FIRST_APP_NAME}_Form(forms.ModelForm):
    class Meta:
        model = ${FIRST_APP_NAME}
        fields = '__all__'

EOF


cat > templates/$FIRST_APP_NAME/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>
<body>
# form with CSRF token to model ${FIRST_APP_NAME}
    <form action="${FIRST_APP_NAME}_view" method="POST">
        {{ csrf_token }}
        <input type="text" name="name" id="name" placeholder="name">
        <input type="submit" value="Submit">
    </form>

    {% comment %} visualize model in table {% endcomment %}
    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Created</th>
                <th>Updated</th>
            </tr>
        </thead>
        <tbody>
            {% for ${FIRST_APP_NAME} in ${FIRST_APP_NAME}.objects.all %}
            <tr>
                <td>{{ ${FIRST_APP_NAME}.name }}</td>
                <td>{{ ${FIRST_APP_NAME}.created }}</td>
                <td>{{ ${FIRST_APP_NAME}.updated }}</td>
            </tr>
            {% endfor %}
        </tbody>
    </table>

</body>
</html>
EOF


# create view in views.py
cat > views.py << EOF
from django.shortcuts import render
from .models import ${FIRST_APP_NAME}

def ${FIRST_APP_NAME}_view(request):
    return render(
        request, 
        '${FIRST_APP_NAME}/index.html', 
        {
            '${FIRST_APP_NAME}': ${FIRST_APP_NAME}.objects.all()
        }
    )

EOF

# replace underscores with dashes in ${FIRST_APP_NAME} and store to DASH_APP_NAME
DASH_APP_NAME=${FIRST_APP_NAME//_/-}


# create 'urls.py' file 
cat > urls.py << EOF 
from django.urls import path
from .views import ${FIRST_APP_NAME}_view  # import view from views.py

app_name = '${DASH_APP_NAME}'

urlpatterns = [
    path('', ${FIRST_APP_NAME}_view, name='${DASH_APP_NAME}'),
]   

EOF

# register model to admin
cat > admin.py << EOF
from django.contrib import admin
from .models import ${FIRST_APP_NAME}

admin.site.register(${FIRST_APP_NAME})
EOF

cd ..

cd django_$APP_NAME

rm urls.py

# create urls.py file and create new jobs config route
cat > urls.py << EOF
"""django_$APP_NAME URL Configuration"""

from django.contrib import admin
from django.urls import path, include 


from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('${FIRST_APP_NAME}.urls', namespace='${DASH_APP_NAME}')),
]


urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

EOF

# edit settings.py to add new apps
cat > settings.py << EOF
"""django_$APP_NAME Settings"""

from pathlib import Path

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/4.0/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-p*dcp%mfkd%#d6p=czmu-k*1@uj3rc@@&h#u6@=mc5===b5_yz'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # new apps
    '${FIRST_APP_NAME}',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'django_etl_app.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'django_etl_app.wsgi.application'


# Database
# https://docs.djangoproject.com/en/4.0/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}


# Password validation
# https://docs.djangoproject.com/en/4.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',},
]


# Internationalization
# https://docs.djangoproject.com/en/4.0/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/4.0/howto/static-files/

STATIC_URL = 'static/'

# Default primary key field type
# https://docs.djangoproject.com/en/4.0/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

EOF

cd ..

# makemigrations
python3 manage.py makemigrations

# migrate
python3 manage.py migrate

# run server
python3 manage.py runserver $PORT
