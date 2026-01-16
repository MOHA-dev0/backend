FROM php:8.2-apache

# 1. تثبيت المكتبات (تم إضافة libzip-dev لحل مشكلة السابقة)
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

# 2. تفعيل mod_rewrite الضروري لـ Laravel
RUN a2enmod rewrite

# 3. ضبط مجلد الروت ليكون public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# ===> التعديل الجديد والمهم جداً: تفعيل ملف .htaccess <===
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# 4. تثبيت Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. نقل الملفات
WORKDIR /var/www/html
COPY . /var/www/html

# 6. تثبيت المكتبات
RUN composer install --no-dev --optimize-autoloader

# 7. تصحيح الصلاحيات (مهم جداً للوصول للملفات)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/public

# 8. فتح البورت
EXPOSE 80