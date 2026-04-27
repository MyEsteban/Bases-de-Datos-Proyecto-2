using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using TAREA02BasesDeDatos.Data;
using TAREA02BasesDeDatos.Models;

namespace TAREA02BasesDeDatos.Controllers
{
    public class LoginController : Controller
    {
        private readonly ConexionBD _conexion;

        public LoginController(ConexionBD conexion)
        {
            _conexion = conexion;
        }

        [HttpGet]
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Index(LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                // R1: Captura de IP para el SP (trazabilidad y bloqueos)
                string ipCliente = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
                int userId;

                // Llamamos a tu método de ConexionBD
                int resultCode = _conexion.ValidarLogin(model.Username, model.Password, ipCliente, out userId);

                if (resultCode == 0) // Éxito
                {
                    // R7: Guardamos el ID en sesión para que los demás SPs sepan quién hace qué
                    HttpContext.Session.SetInt32("IdUsuario", userId);
                    HttpContext.Session.SetString("NombreUsuario", model.Username);

                    return RedirectToAction("Index", "Empleado");
                }
                else
                {
                    // R8: Manejo de errores basado en lo que devuelve SQL
                    if (resultCode == 50003)
                        ViewBag.Error = "Acceso bloqueado por demasiados intentos fallidos.";
                    else if (resultCode == 50001)
                        ViewBag.Error = "Usuario o contraseña incorrectos.";
                    else
                        ViewBag.Error = "Error en el sistema. Código: " + resultCode;
                }
            }
            return View(model);
        }

        public IActionResult Logout()
        {
            // Limpiamos toda la sesión (R7)
            HttpContext.Session.Clear();
            return RedirectToAction("Index", "Login");
        }
    }
}