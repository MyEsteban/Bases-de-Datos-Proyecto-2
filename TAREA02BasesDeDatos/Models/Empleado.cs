namespace TAREA02BasesDeDatos.Models
{
    // Empleado.cs
    public class Empleado
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public string ValorDocumentoIdentidad { get; set; }
        public string Puesto { get; set; } // Para mostrar el nombre del puesto en el R2
        public int IdPuesto { get; set; }
        public decimal SaldoVacaciones { get; set; }
        public DateTime FechaContratacion { get; set; }
        public bool EsActivo { get; set; }
    }
}
