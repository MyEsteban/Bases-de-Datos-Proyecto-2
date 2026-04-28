namespace TAREA02BasesDeDatos.Models
{
    public class Empleado
    {
        public int Id { get; set; }
        public int IdPuesto { get; set; }
        public string ValorDocumentoIdentidad { get; set; } // Nombre exacto de tu DB
        public string NombrePuesto { get; set; } // <--- AGREGA ESTA LÍNEA
        public string Nombre { get; set; }
        public DateTime FechaContratacion { get; set; }
        public decimal SaldoVacaciones { get; set; }
        public bool EsActivo { get; set; }
        public DateTime PostTime { get; set; }
        public string IpPostIn { get; set; }
    }
}