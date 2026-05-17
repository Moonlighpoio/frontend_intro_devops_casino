# ---------- Etapa 1: Compilación de Angular ----------
    FROM node:20-alpine AS builder
    WORKDIR /app
    COPY package*.json ./
    # Usamos install por si falta el lockfile
    RUN npm install
    COPY . .
    RUN npm run build -- --configuration production
    
    # ---------- Etapa 2: Runtime Nginx No-Root ----------
    FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime
    
    # Copiar la plantilla del proxy inverso (Nginx Unprivileged la lee automáticamente aquí)
    COPY default.conf.template /etc/nginx/templates/default.conf.template
    
    # Copiar directamente el build estático generado por Angular (sobreescribe de forma segura)
    COPY --from=builder /app/dist/casino-frontend/browser/. /usr/share/nginx/html/
    
    # Exponer el puerto interno seguro no privilegiado
    EXPOSE 8080
    CMD ["nginx", "-g", "daemon off;"]