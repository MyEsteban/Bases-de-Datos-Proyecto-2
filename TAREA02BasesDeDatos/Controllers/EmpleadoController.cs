using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using TAREA02BasesDeDatos.Data;
using TAREA02BasesDeDatos.Models;
using System.Collections.Generic;

namespace TAREA02BasesDeDatos.Controllers
{
    public class EmpleadoController : Controller
    {
        private readonly ConexionBD _conexion;

        public EmpleadoController(ConexionBD conexion)
        {
            _conexion = conexion;
        }

        // Acción principal: Lista empleados y permite filtrar (R2)
        public IActionResult Index(string nombre, string cedula)
        {
            // Verificamos sesión (R7)
            int? idUsuario = HttpContext.Session.GetInt32("IdUsuario");

            if (idUsuario == null)
            {
                return RedirectToAction("Index", "Login");
            }

            string ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
            int resultCode;

            // Llamamos a tu método en ConexionBD
            var lista = _conexion.ConsultarEmpleados(nombre, cedula, idUsuario.Value, ip, out resultCode);

            if (resultCode != 0)
            {
                ViewBag.Error = "Error al obtener datos: " + resultCode;
            }

            // Guardamos los filtros para que no se borren de los inputs en la vista
            ViewBag.FiltroNombre = nombre;
            ViewBag.FiltroCedula = cedula;

            return View(lista);
        }
    }
}