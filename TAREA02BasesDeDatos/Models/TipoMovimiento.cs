namespace TAREA02BasesDeDatos.Models
{
    public class TipoMovimiento
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public string TipoAccion { get; set; } // "Credito" o "Debito" según tu tabla
    }
}