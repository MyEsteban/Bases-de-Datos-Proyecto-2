using System;

namespace TAREA02BasesDeDatos.Models
{
    public class Movimiento
    {
        public int Id { get; set; }
        public int IdEmpleado { get; set; }
        public int IdTipoMovimiento { get; set; }
        public DateTime Fecha { get; set; }
        public decimal Monto { get; set; }
        public decimal NuevoSaldo { get; set; }
        public int IdUsuario { get; set; }
        public string IpPostIn { get; set; }
        public DateTime PostTime { get; set; } // Nombre exacto de tu DB

        // Propiedades calculadas/traídas por JOIN para la vista
        public string TipoMovimiento { get; set; }
        public string TipoAccion { get; set; }
        public string NombreUsuario { get; set; } // Para mostrar el string del usuario
    }
}