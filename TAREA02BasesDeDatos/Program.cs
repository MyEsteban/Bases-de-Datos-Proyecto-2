using TAREA02BasesDeDatos.Data;

var builder = WebApplication.CreateBuilder(args);

// 1. Agregar servicios al contenedor (Inyección de Dependencias)
builder.Services.AddControllersWithViews();

// Registramos tu clase de conexión para que los controladores puedan usarla
builder.Services.AddScoped<ConexionBD>();

// Configuración de Sesión (Vital para el R7 y guardar el IdUsuario)
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

// Configuración para acceder al contexto HTTP (para capturar la IP en el Controller)
builder.Services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

var app = builder.Build();

// 2. Configurar el pipeline de solicitudes HTTP (Middlewares)
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

// ¡IMPORTANTE! UseSession debe ir después de UseRouting y antes de UseAuthorization
app.UseSession();

app.UseAuthorization();

// 3. Configuración de la Ruta por Defecto
// Aquí cambiamos "Home" por "Login" para que sea lo primero que cargue
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Login}/{action=Index}/{id?}");

app.Run();