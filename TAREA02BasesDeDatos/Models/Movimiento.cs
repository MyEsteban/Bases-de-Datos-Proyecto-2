namespace TAREA02BasesDeDatos.Models
{
    // Movimiento.cs
    public class Movimiento
    {
        public int Id { get; set; }
        public DateTime Fecha { get; set; }
        public string TipoMovimiento { get; set; }
        public string TipoAccion { get; set; }
        public decimal Monto { get; set; }
        public decimal NuevoSaldo { get; set; }
    }
}
