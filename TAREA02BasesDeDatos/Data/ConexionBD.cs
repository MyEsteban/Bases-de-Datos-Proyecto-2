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

                // Parámetros de entrada según estándar @in
                cmd.Parameters.AddWithValue("@inUsername", username);
                cmd.Parameters.AddWithValue("@inPassword", password);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                // Parámetro de salida según estándar @out (R8)
                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outResult);

                connection.Open();

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        userId = Convert.ToInt32(dr["Id"]);
                    }
                }
                resultCode = (int)cmd.Parameters["@outResultCode"].Value;
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
                            Puesto = dr["Puesto"].ToString(),
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
                resultCode = (int)cmd.Parameters["@outResultCode"].Value;
            }
            return resultCode;
        }

        // ============================================================
        // R4: ACTUALIZAR EMPLEADO
        // ============================================================
        public int ActualizarEmpleado(Empleado emp, int idUsuario, string ip)
        {
            int resultCode = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_ActualizarEmpleado", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inId", emp.Id);
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
                resultCode = (int)cmd.Parameters["@outResultCode"].Value;
            }
            return resultCode;
        }

        // ============================================================
        // R4: BORRAR EMPLEADO (Lógico)
        // ============================================================
        public int BorrarEmpleado(int id, int idUsuario, string ip)
        {
            int resultCode = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_BorrarEmpleado", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inId", id);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outResult);

                connection.Open();
                cmd.ExecuteNonQuery();
                resultCode = (int)cmd.Parameters["@outResultCode"].Value;
            }
            return resultCode;
        }

        // ============================================================
        // R5: CONSULTAR MOVIMIENTOS
        // ============================================================
        public List<Movimiento> ConsultarMovimientos(int idEmpleado, int idUsuario, string ip, out int resultCode)
        {
            List<Movimiento> lista = new List<Movimiento>();
            resultCode = 0;

            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_ConsultarMovimientos", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inIdEmpleado", idEmpleado);
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
                        lista.Add(new Movimiento
                        {
                            Id = Convert.ToInt32(dr["Id"]),
                            Fecha = Convert.ToDateTime(dr["Fecha"]),
                            TipoMovimiento = dr["TipoMovimiento"].ToString(),
                            TipoAccion = dr["TipoAccion"].ToString(),
                            Monto = Convert.ToDecimal(dr["Monto"]),
                            NuevoSaldo = Convert.ToDecimal(dr["NuevoSaldo"])
                        });
                    }
                }
                resultCode = (int)cmd.Parameters["@outResultCode"].Value;
            }
            return lista;
        }

        // ============================================================
        // R6: REGISTRAR MOVIMIENTO
        // ============================================================
        public int RegistrarMovimiento(int idEmpleado, int idTipo, decimal monto, int idUsuario, string ip)
        {
            int resultCode = 0;
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                SqlCommand cmd = new SqlCommand("dbo.sp_RegistrarMovimiento", connection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@inIdEmpleado", idEmpleado);
                cmd.Parameters.AddWithValue("@inIdTipoMovimiento", idTipo);
                cmd.Parameters.AddWithValue("@inMonto", monto);
                cmd.Parameters.AddWithValue("@inIdUsuario", idUsuario);
                cmd.Parameters.AddWithValue("@inIpPostIn", ip);

                SqlParameter outResult = new SqlParameter("@outResultCode", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outResult);

                connection.Open();
                cmd.ExecuteNonQuery();
                resultCode = (int)cmd.Parameters["@outResultCode"].Value;
            }
            return resultCode;
        }
    }
}