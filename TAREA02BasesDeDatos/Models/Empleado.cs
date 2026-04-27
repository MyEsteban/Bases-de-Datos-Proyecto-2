using System.ComponentModel.DataAnnotations;
namespace TAREA02BasesDeDatos.Models
{
    public class Empleado
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "El nombre es obligatorio")]
        [RegularExpression(@"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$", ErrorMessage = "El nombre solo debe contener letras y espacios")]
        public string Nombre { get; set; }

        [Required(ErrorMessage = "La cédula es obligatoria")]
        [RegularExpression(@"^[0-9]+$", ErrorMessage = "La cédula debe ser únicamente numérica")]
        public string ValorDocumentoIdentidad { get; set; }

        [Required]
        public int IdPuesto { get; set; }

        public string Puesto { get; set; } // Para mostrar el nombre en la tabla

        [Required]
        public DateTime FechaContratacion { get; set; } = DateTime.Now;

        public decimal SaldoVacaciones { get; set; }
        public bool EsActivo { get; set; }
    }
}