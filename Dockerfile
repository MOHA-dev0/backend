FROM php:8.2-apache

# 1. تثبيت البرامج والمكتبات الضرورية (أضفنا libzip-dev)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip

# 2. تفعيل إعدادات السيرفر (Apache Rewrite)
RUN a2enmod rewrite

# 3. ضبط مجلد الروت ليكون public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. نقل ملفات المشروع للسيرفر
WORKDIR /var/www/html
COPY . /var/www/html

# 6. تثبيت مكتبات لارافل
RUN composer install --no-dev --optimize-autoloader

# 7. إعطاء الصلاحيات لمجلدات التخزين
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 8. فتح البورت 80
EXPOSE 80