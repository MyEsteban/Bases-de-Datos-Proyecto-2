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

        [HttpGet]
        public IActionResult Crear()
        {
            if (HttpContext.Session.GetInt32("IdUsuario") == null) return RedirectToAction("Index", "Login");

            // Aquí podrías cargar una lista de puestos desde la BD si fuera necesario
            ViewBag.Puestos = _conexion.ConsultarPuestos();
            return View();
        }




        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Crear(Empleado emp)
        {
            int? idUsuario = HttpContext.Session.GetInt32("IdUsuario");
            string ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

            int resultCode = _conexion.InsertarEmpleado(emp, idUsuario.Value, ip);

            if (resultCode == 0)
            {
                return RedirectToAction("Index");
            }

            ViewBag.Error = "Error al insertar: " + resultCode;
            ViewBag.Puestos = _conexion.ConsultarPuestos();
            return View(emp);
        }

        [HttpGet]
        public IActionResult Editar(int id)
        {
            if (HttpContext.Session.GetInt32("IdUsuario") == null) return RedirectToAction("Index", "Login");

            var empleado = _conexion.ObtenerEmpleadoPorId(id);
            if (empleado == null) return RedirectToAction("Index");

            ViewBag.Puestos = _conexion.ConsultarPuestos();
            return View(empleado);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Editar(Empleado emp)
        {
            int idUsuario = HttpContext.Session.GetInt32("IdUsuario") ?? 0;
            string ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

            int resultCode = _conexion.ActualizarEmpleado(emp, idUsuario, ip);

            if (resultCode == 0) return RedirectToAction("Index");

            // Manejo de errores específicos según tus códigos de retorno del SP
            ViewBag.Error = resultCode switch
            {
                50009 => "El nombre solo debe contener letras.",
                50010 => "La cédula solo debe contener números.",
                50006 => "Ya existe otro empleado con ese documento de identidad.",
                _ => "Error inesperado: " + resultCode
            };

            ViewBag.Puestos = _conexion.ConsultarPuestos();
            return View(emp);
        }

        [HttpPost]
        public IActionResult Eliminar(int id)
        {
            int idUsuario = HttpContext.Session.GetInt32("IdUsuario") ?? 0;
            string ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

            _conexion.BorrarEmpleado(id, idUsuario, ip);
            return RedirectToAction("Index");
        }


        public IActionResult Movimientos(int id)
        {
            // 1. Verificación de seguridad
            int? idUsuario = HttpContext.Session.GetInt32("IdUsuario");
            if (idUsuario == null) return RedirectToAction("Index", "Login");

            string ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
            int resCode;

            // 2. Obtener datos del empleado para el encabezado (R5)
            var empleado = _conexion.ObtenerEmpleadoPorId(id);
            if (empleado == null) return RedirectToAction("Index");

            ViewBag.Empleado = empleado;

            // 3. Obtener la lista de movimientos mediante el SP
            var listaMovs = _conexion.ConsultarMovimientos(id, idUsuario.Value, ip, out resCode);

            if (resCode != 0)
            {
                ViewBag.Error = "Error al consultar movimientos: " + resCode;
            }

            return View(listaMovs);
        }

        [HttpGet]
        public IActionResult InsertarMovimiento(int id)
        {
            if (HttpContext.Session.GetInt32("IdUsuario") == null)
                return RedirectToAction("Index", "Login");

            var empleado = _conexion.ObtenerEmpleadoPorId(id);
            ViewBag.Empleado = empleado; // Para mostrar Nombre y ValorDocumentoIdentidad arriba
            ViewBag.Tipos = _conexion.ConsultarTiposMovimiento();

            return View();
        }

        [HttpPost]
        public IActionResult InsertarMovimiento(int idEmpleado, int idTipoMovimiento, decimal monto)
        {
            int idUsuario = HttpContext.Session.GetInt32("IdUsuario") ?? 1;
            string ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "::1";

            int resultCode = _conexion.InsertarMovimiento(idEmpleado, idTipoMovimiento, monto, idUsuario, ip);

            if (resultCode == 0)
            {
                // IMPORTANTE: Esto obliga a la web a recargar el empleado con su nuevo saldo
                return RedirectToAction("Movimientos", new { id = idEmpleado });
            }

            // Si hubo error, volvemos a consultar al empleado para que el saldo en pantalla sea real
            ViewBag.Error = "Error: " + resultCode;
            ViewBag.Empleado = _conexion.ObtenerEmpleadoPorId(idEmpleado);
            ViewBag.Tipos = _conexion.ConsultarTiposMovimiento();
            return View();
        }


    }
}