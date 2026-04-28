using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using TAREA02BasesDeDatos.Models; // Asegúrate de que este sea tu namespace


namespace TAREA02BasesDeDatos.Data
{
    public class ConexionBD
    {
        private readonly string _connectionString;

        public ConexionBD(IConfiguration configuration)
        {
            // Usamos "AzureConnection" para que coincida con tu appsettings
            _connectionString = configuration.GetConnectionString("AzureConnection");
        }

        // ============================================================
        // R1: LOGIN (Valida intentos, bloqueos y registra bitácora)
        // ============================================================
        public int ValidarLogin(string username, string password, string ip, out int userId)
        {
            userId = -1;
            int resultCode = 0;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_Login", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                // Entradas
                cmd.Parameters.AddWithValue("@inUsername", username);
                cmd.Parameters.AddWithValue("@inPassword", password);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                // Salida 1: El código de resultado (0, 50001, etc.)
                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outResult);

                // Salida 2: El ID del Usuario que acabamos de agregar al SP
                SqlParameter outId = new SqlParameter("@outIdUsuario", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outId);

                connection.Open();

                // IMPORTANTE: Usamos ExecuteNonQuery porque los datos vienen por parámetros de salida
                cmd.ExecuteNonQuery();

                // Leemos los valores de los parámetros después de la ejecución
                resultCode = (outResult.Value != DBNull.Value) ? (int)outResult.Value : 50008;

                if (resultCode == 0)
                {
                    userId = (outId.Value != DBNull.Value) ? (int)outId.Value : -1;
                }
            }
            return resultCode;
        }

        // ============================================================
        // R2: CONSULTAR EMPLEADOS (Con filtros opcionales)
        // ============================================================
        public List<Empleado> ConsultarEmpleados(string nombre, string cedula, int idUsuario, string ip, out int resultCode)
        {
            List<Empleado> lista = new List<Empleado>();
            resultCode = 0;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_ConsultarEmpleado", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                // Manejo de nulos para los filtros
                cmd.Parameters.AddWithValue("@inNombre", (object)nombre ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@inDocumentoIdentidad", (object)cedula ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outResult);

                connection.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new Empleado
                        {
                            Id = Convert.ToInt32(dr["Id"]),
                            Nombre = dr["Nombre"].ToString(),
                            ValorDocumentoIdentidad = dr["ValorDocumentoIdentidad"].ToString(),
                            NombrePuesto = dr["Puesto"].ToString(),
                            SaldoVacaciones = Convert.ToDecimal(dr["SaldoVacaciones"]),
                            FechaContratacion = Convert.ToDateTime(dr["FechaContratacion"]),
                            EsActivo = Convert.ToBoolean(dr["EsActivo"])
                        });
                    }
                }
                resultCode = (int)cmd.Parameters["@outResultCode"].Value;
            }
            return lista;
        }

        // ============================================================
        // R3: INSERTAR EMPLEADO
        // ============================================================
        public int InsertarEmpleado(Empleado emp, int idUsuario, string ip)
        {
            int resultCode = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_InsertarEmpleado", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inNombre", emp.Nombre);
                cmd.Parameters.AddWithValue("@inValorDocumentoIdentidad", emp.ValorDocumentoIdentidad);
                cmd.Parameters.AddWithValue("@inIdPuesto", emp.IdPuesto);
                cmd.Parameters.AddWithValue("@inFechaContratacion", emp.FechaContratacion);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outResult);

                connection.Open();
                cmd.ExecuteNonQuery();

                resultCode = (outResult.Value != DBNull.Value) ? (int)outResult.Value : 50008;
            }
            return resultCode;
        }


        // funcion aux que consulta los puestos para llenar el dropdownlist en el formulario de empleado
        // Para llenar el DropDownList del R3
        public List<Puesto> ConsultarPuestos()
        {
            List<Puesto> lista = new List<Puesto>();
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                // SQL corregido: Eliminamos cualquier referencia a EsActivo
                string query = "SELECT Id, Nombre, SalarioxHora FROM dbo.Puesto";
                SqlCommand cmd = new SqlCommand(query, connection);
                connection.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new Puesto
                        {
                            Id = (int)dr["Id"],
                            Nombre = dr["Nombre"].ToString()
                            // Asegúrate de NO leer dr["EsActivo"] aquí
                        });
                    }
                }
            }
            return lista;
        }

        // ============================================================
        // R4: ACTUALIZAR EMPLEADO
        // ============================================================

        // funcion aux
        // Método para cargar los datos del empleado en la pantalla de Editar
        public Empleado ObtenerEmpleadoPorId(int id)
        {
            Empleado emp = null;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                // FALTABA: SaldoVacaciones en el SELECT
                string query = "SELECT Id, Nombre, ValorDocumentoIdentidad, IdPuesto, FechaContratacion, SaldoVacaciones FROM dbo.Empleado WHERE Id = @id";
                SqlCommand cmd = new SqlCommand(query, connection);
                cmd.Parameters.AddWithValue("@id", id);
                connection.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        emp = new Empleado
                        {
                            Id = (int)dr["Id"],
                            Nombre = dr["Nombre"].ToString(),
                            ValorDocumentoIdentidad = dr["ValorDocumentoIdentidad"].ToString(),
                            IdPuesto = (int)dr["IdPuesto"],
                            FechaContratacion = (DateTime)dr["FechaContratacion"],
                            // AGREGAR ESTA LÍNEA:
                            SaldoVacaciones = Convert.ToDecimal(dr["SaldoVacaciones"])
                        };
                    }
                }
            }
            return emp;
        }


        public int ActualizarEmpleado(Empleado emp, int idUsuario, string ip)
        {
            int resultCode = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                // Usamos el nombre exacto de tu SP
                SqlCommand cmd = new SqlCommand("dbo.sp_ActualizarEmpleado", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inId", emp.Id);
                cmd.Parameters.AddWithValue("@inNombre", emp.Nombre);
                cmd.Parameters.AddWithValue("@inValorDocumentoIdentidad", emp.ValorDocumentoIdentidad);
                cmd.Parameters.AddWithValue("@inIdPuesto", emp.IdPuesto);
                cmd.Parameters.AddWithValue("@inFechaContratacion", emp.FechaContratacion);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outResult);

                connection.Open();
                cmd.ExecuteNonQuery();
                resultCode = (int)outResult.Value;
            }
            return resultCode;
        }

        // ============================================================
        // R4: BORRAR EMPLEADO (Lógico)
        // ============================================================
        public int BorrarEmpleado(int idEmpleado, int idUsuario, string ip)
        {
            int resultCode = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                // Usamos el nombre exacto de tu SP: sp_BorrarEmpleado
                SqlCommand cmd = new SqlCommand("dbo.sp_BorrarEmpleado", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inId", idEmpleado);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outResult);

                connection.Open();
                cmd.ExecuteNonQuery();
                resultCode = (int)outResult.Value;
            }
            return resultCode;
        }

        // ============================================================
        // R5: CONSULTAR MOVIMIENTOS
        // ============================================================
        public List<Movimiento> ConsultarMovimientos(int idEmpleado, int idUsuario, string ip, out int resultCode)
        {
            List<Movimiento> lista = new List<Movimiento>();
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_ConsultarMovimientos", connection);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@inIdEmpleado", idEmpleado);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outResult);

                connection.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new Movimiento
                        {
                            Id = Convert.ToInt32(dr["Id"]),
                            Fecha = Convert.ToDateTime(dr["Fecha"]),
                            TipoMovimiento = dr["TipoMovimiento"].ToString(),
                            TipoAccion = dr["TipoAccion"].ToString(),
                            Monto = Convert.ToDecimal(dr["Monto"]),
                            NuevoSaldo = Convert.ToDecimal(dr["NuevoSaldo"]),
                            NombreUsuario = dr["NombreUsuario"].ToString(), // Coincide con el Alias del SP
                            PostTime = Convert.ToDateTime(dr["PostTime"])   // Coincide con la columna de la DB
                        });
                    }
                }
                resultCode = (outResult.Value != DBNull.Value) ? (int)outResult.Value : 0;
            }
            return lista;
        }
        // consulta aux para llenar el dropdownlist de tipos de movimiento en la vista de movimientos
        public List<TipoMovimiento> ConsultarTiposMovimiento()
        {
            List<TipoMovimiento> lista = new List<TipoMovimiento>();
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                string query = "SELECT Id, Nombre, TipoAccion FROM dbo.TipoMovimiento";
                SqlCommand cmd = new SqlCommand(query, connection);
                connection.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        lista.Add(new TipoMovimiento
                        {
                            Id = (int)dr["Id"],
                            Nombre = dr["Nombre"].ToString(),
                            TipoAccion = dr["TipoAccion"].ToString()
                        });
                    }
                }
            }
            return lista;
        }

        // ============================================================
        // R6: REGISTRAR MOVIMIENTO
        // ============================================================
        public int InsertarMovimiento(int idEmpleado, int idTipoMovimiento, decimal monto, int idUsuario, string ip)
        {
            int resultCode = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_InsertarMovimiento", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inIdEmpleado", idEmpleado);
                cmd.Parameters.AddWithValue("@inIdTipoMovimiento", idTipoMovimiento);
                cmd.Parameters.AddWithValue("@inMonto", monto);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int) { Direction = ParameterDirection.Output };
                cmd.Parameters.Add(outResult);

                connection.Open();
                cmd.ExecuteNonQuery(); // Aquí es donde fallaba por la fecha

                resultCode = (outResult.Value != DBNull.Value) ? (int)outResult.Value : 0;
            }
            return resultCode;
        }
    }
}