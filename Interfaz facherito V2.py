# -*- coding: utf-8 -*-
"""
Created on Sun Jun 23 01:47:53 2024

@author: julia
"""

# -*- coding: utf-8 -*-
"""
Created on Sat Jun 22 19:42:41 2024

@author: julia
"""

from tkinter import ttk, messagebox
import customtkinter as ctk
import mysql.connector
from datetime import datetime

# Conectar a la base de datos
def connect_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="42282383",
        database="Clubdeportivo"
    )


# Modificar la creación de la interfaz gráfica para incluir el campo domicilio opcional
def show_add_socio_window():
    add_window = ctk.CTkToplevel()
    add_window.title("Agregar Socio")

    # Agrandar la ventana
    add_window.geometry("400x500")

    # CTkLabels y entradas para los datos del socio
    ctk.CTkLabel(add_window, text="Número de Grupo").grid(row=0, column=0, padx=10, pady=10)
    entry_nro_grupo = ctk.CTkEntry(add_window)
    entry_nro_grupo.grid(row=0, column=1, padx=10, pady=10)

    ctk.CTkLabel(add_window, text="Número de Socio").grid(row=1, column=0, padx=10, pady=10)
    entry_nro_socio = ctk.CTkEntry(add_window)
    entry_nro_socio.grid(row=1, column=1, padx=10, pady=10)

    ctk.CTkLabel(add_window, text="Nombre").grid(row=2, column=0, padx=10, pady=10)
    entry_nombre = ctk.CTkEntry(add_window)
    entry_nombre.grid(row=2, column=1, padx=10, pady=10)

    ctk.CTkLabel(add_window, text="Apellido").grid(row=3, column=0, padx=10, pady=10)
    entry_apellido = ctk.CTkEntry(add_window)
    entry_apellido.grid(row=3, column=1, padx=10, pady=10)

    ctk.CTkLabel(add_window, text="Fecha de Nacimiento (YYYY-MM-DD)").grid(row=4, column=0, padx=10, pady=10)
    entry_fecha_nac = ctk.CTkEntry(add_window)
    entry_fecha_nac.grid(row=4, column=1, padx=10, pady=10)

    ctk.CTkLabel(add_window, text="Email").grid(row=5, column=0, padx=10, pady=10)
    entry_email = ctk.CTkEntry(add_window)
    entry_email.grid(row=5, column=1, padx=10, pady=10)

    # Botón para agregar socio
    ctk.CTkButton(add_window, text="Agregar Socio", command=lambda: add_socio(add_window,
                                                                         entry_nro_grupo.get(),
                                                                         entry_nro_socio.get(),
                                                                         entry_nombre.get(),
                                                                         entry_apellido.get(),
                                                                         entry_fecha_nac.get(),
                                                                         entry_email.get())).grid(row=8, column=0, columnspan=2, padx=10, pady=10)
    add_window.wait_window()
    

def add_socio(add_window,nro_grupo, nro_socio, nombre, apellido, fecha_nac, email):
    try:
        conn = connect_db()
        cursor = conn.cursor()

        # Configurar el nivel de aislamiento serializable
        cursor.execute("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")

        # Convertir a tipo int si es necesario
        nro_grupo = int(nro_grupo)
        nro_socio = int(nro_socio)

        # Iniciar la transacción
        cursor.execute("START TRANSACTION")

        # Desactivar la verificación de claves foráneas
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")

        # Insertar el nuevo grupo familiar si no existe
        cursor.execute("SELECT COUNT(*) FROM GRUPO_FAMILIAR WHERE NRO_GRUPO = %s", (nro_grupo,))
        result = cursor.fetchone()
        exist_group = result[0] if result else 0

        # Si el grupo no existe, lo crea
        if exist_group == 0:
            nro_socio = 1

            # Insertar el socio principal
            cursor.execute("INSERT INTO GRUPO_FAMILIAR (NRO_GRUPO, NRO_SOCIO_TITULAR, DOMICILIO) VALUES (%s, %s, %s)", (nro_grupo, nro_socio, None))

        # Insertar el socio
        query = "INSERT INTO SOCIO (NRO_SOCIO, NRO_GRUPO, NOMBRE_SOCIO, APELLIDO_SOCIO, FECHA_NAC_SOCIO, MAIL) VALUES (%s, %s, %s, %s, %s, %s)"
        cursor.execute(query, (nro_socio, nro_grupo, nombre, apellido, fecha_nac, email))

        # Verificar si es necesario actualizar el socio titular en GRUPO_FAMILIAR
        if exist_group != 0:
            cursor.execute("SELECT NRO_SOCIO_TITULAR FROM GRUPO_FAMILIAR WHERE NRO_GRUPO = %s", (nro_grupo,))
            result = cursor.fetchone()
            if result and result[0] is None:
                cursor.execute("UPDATE GRUPO_FAMILIAR SET NRO_SOCIO_TITULAR = %s WHERE NRO_GRUPO = %s", (nro_socio, nro_grupo))

        
        # Cerrar la transacción principal antes de pedir detalles adicionales
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
        
        # Confirmar la transacción
        conn.commit()
        add_window.destroy()
        
        cursor.close()
        conn.close()

        # Pedir información adicional
        if exist_group == 0:
            add_additional_info(nro_grupo, nro_socio)

        messagebox.showinfo("Éxito", "Socio agregado exitosamente.")
    except mysql.connector.Error as e:
        if conn:
            conn.rollback()
        messagebox.showerror("Error", f"Ocurrió un error de MySQL: {e.msg}")
    except Exception as e:
        if conn:
            conn.rollback()
        messagebox.showerror("Error", f"Ocurrió un error: {e}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

def add_additional_info(nro_grupo, nro_socio):
    add_window = ctk.CTkToplevel()
    add_window.title("Creacion de grupo")

    # Agrandar la ventana de domicilio
    add_window.geometry("800x200")
    
    ctk.CTkLabel(add_window, text="Domicilio").grid(row=2, column=0, padx=10, pady=10)
    entry_domicilio = ctk.CTkEntry(add_window)
    entry_domicilio.grid(row=2, column=1, padx=10, pady=10)
    
    # Campos para contacto
    ctk.CTkLabel(add_window, text="Prefijo").grid(row=1, column=0, padx=10, pady=10)
    entry_prefijo = ctk.CTkEntry(add_window)
    entry_prefijo.grid(row=1, column=1, padx=10, pady=10)
         
    ctk.CTkLabel(add_window, text="Número").grid(row=1, column=2, padx=10, pady=10)
    entry_numero = ctk.CTkEntry(add_window)
    entry_numero.grid(row=1, column=3, padx=10, pady=10)
    
    ctk.CTkLabel(add_window, text="Fijo / Celular").grid(row=1, column=4, padx=10, pady=10)
    entry_tipoContacto = ctk.CTkEntry(add_window)
    entry_tipoContacto.grid(row=1, column=5, padx=10, pady=10)

    def save_additional_info():
        try:
            conn = connect_db()
            cursor = conn.cursor()
            
            # Configurar el nivel de aislamiento serializable
            cursor.execute("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")
            
            cursor.execute("START TRANSACTION")
            # Desactivar la verificación de claves foráneas
            cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
            
            update_contacto = "INSERT INTO CONTACTO (PREFIJO, NRO_TELEFONO, DESCRIPCION, NRO_GRUPO) VALUES (%s, %s, %s, %s)" 
            cursor.execute(update_contacto, (entry_prefijo.get(), entry_numero.get(), entry_tipoContacto.get(), nro_grupo))
            update_address = "UPDATE GRUPO_FAMILIAR SET DOMICILIO = %s WHERE NRO_GRUPO = %s"
            cursor.execute(update_address, (entry_domicilio.get(), nro_grupo))
            
            # Cerrar la transacción principal antes de pedir detalles adicionales
            cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
            
            conn.commit()
            add_window.destroy()
            messagebox.showinfo("Éxito", "Domicilio y contacto actualizados.")
        except mysql.connector.Error as e:
            if conn:
                conn.rollback()
            messagebox.showerror("Error", f"Ocurrió un error de MySQL: {e.msg}")
        except Exception as e:
            if conn:
                conn.rollback()
            messagebox.showerror("Error", f"Ocurrió un error: {e}")
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()

    # Botón para guardar cambios
    ctk.CTkButton(add_window, text="Guardar cambios", command=save_additional_info).grid(row=3, column=3, columnspan=2, padx=10, pady=10)

    # Esperar hasta que se cierre la ventana add_window
    add_window.wait_window()



# Función para consultar el número de grupo por dirección
def consultar_numero_grupo(nombre_titular, apellido_titular):
    try:
        conn = connect_db()
        cursor = conn.cursor()
        query = "SELECT DISTINCT S.NRO_GRUPO FROM GRUPO_FAMILIAR AS GF INNER JOIN SOCIO AS S ON S.NRO_SOCIO = GF.NRO_SOCIO_TITULAR WHERE NOMBRE_SOCIO = %s AND APELLIDO_SOCIO = %s"
        cursor.execute(query, (nombre_titular,apellido_titular))
        result = cursor.fetchone()
        if result:
            messagebox.showinfo("Resultado", f"El número de grupo es: {result[0]}")
        else:
            messagebox.showinfo("Resultado", "No se encontró ningún grupo con esa dirección.")
    except Exception as e:
        messagebox.showerror("Error", f"Ocurrió un error: {e}")
    finally:
        cursor.close()
        conn.close()
        
# Modificar la creación de la interfaz gráfica para llamar a la función con los valores de entrada
def show_delete_socio_window():
    delete_window = ctk.CTkToplevel()
    delete_window.title("Eliminar Socio")

    # Agrandar la ventana
    delete_window.geometry("400x300")

    # CTkLabels y entradas para los datos del socio
    ctk.CTkLabel(delete_window, text="Número de Grupo").grid(row=0, column=0, padx=10, pady=10)
    entry_nro_grupo = ctk.CTkEntry(delete_window)
    entry_nro_grupo.grid(row=0, column=1, padx=10, pady=10)

    ctk.CTkLabel(delete_window, text="Número de Socio").grid(row=1, column=0, padx=10, pady=10)
    entry_nro_socio = ctk.CTkEntry(delete_window)
    entry_nro_socio.grid(row=1, column=1, padx=10, pady=10)

    # Botón para eliminar socio
    ctk.CTkButton(delete_window, text="Eliminar Socio", command=lambda: delete_socio(entry_nro_grupo.get(),
                                                                               entry_nro_socio.get())).grid(row=2, column=0, columnspan=2, padx=10, pady=10)

# Función para mostrar la ventana de consulta de número de grupo
def show_consultar_grupo_window():
    add_window = ctk.CTkToplevel()
    add_window.title("Consultar Número de Grupo")

    # Agrandar la ventana
    add_window.geometry("400x200")
    
    ctk.CTkLabel(add_window, text="Nombre").grid(row=2, column=0, padx=10, pady=10)
    entry_nombre = ctk.CTkEntry(add_window)
    entry_nombre.grid(row=2, column=1, padx=10, pady=10)

    ctk.CTkLabel(add_window, text="Apellido").grid(row=3, column=0, padx=10, pady=10)
    entry_apellido = ctk.CTkEntry(add_window)
    entry_apellido.grid(row=3, column=1, padx=10, pady=10)

    # Botón para consultar el número de grupo
    ctk.CTkButton(add_window, text="Consultar", command=lambda: consultar_numero_grupo(entry_nombre.get(),
                                                                                   entry_apellido.get())).grid(row=5, column=1, columnspan=2, padx=10, pady=10)

def fetch_deudores_AnioCorriente():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Deudores_anio_corriente")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows

def consulta_deudores_anioCorriente():
    add_window = ctk.CTkToplevel()
    
    # Agrandar la ventana
    add_window.geometry("1000x400")
    now = datetime.now().strftime("%Y-%m-%d  -  %H:%M:%S")
    add_window.title("Deudores año " f"{now}")
    
    # Crear tabla para mostrar las actividades
    frame = ctk.CTkFrame(add_window)
    frame.pack(pady=10)

    tree = ttk.Treeview(frame, columns=("Nro socio", "Nombre", "Apellido","Cantidad de integrantes","Importe adeudado"), show="headings")
    tree.heading("Nro socio", text="Nro socio")
    tree.heading("Nombre", text="Nombre")
    tree.heading("Apellido", text="Apellido")
    tree.heading("Cantidad de integrantes", text="Cantidad de integrantes")
    tree.heading("Importe adeudado", text="Importe adeudado")
    tree.pack(expand=True, fill="both")

    # Cargar datos en la tabla
    deudores_AnioCorriente = fetch_deudores_AnioCorriente()

    for deudores in deudores_AnioCorriente:
        tree.insert("", "end", values=deudores)
        
def fetch_socios_in_AllfreeACT():
    conn = connect_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Socios_act_gratis")
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows

def consulta_socios_AllfreeACT():
    add_window = ctk.CTkToplevel()
    
    # Agrandar la ventana
    add_window.geometry("500x400")
    now = datetime.now().strftime("%Y-%m-%d  -  %H:%M:%S")
    add_window.title("Socios en todas las actividades del año pasado ")
    ctk.CTkLabel(add_window, text=f"{now}", font=("Helvetica", 16)).pack(pady=5)
    
    # Crear tabla para mostrar las actividades
    frame = ctk.CTkFrame(add_window)
    frame.pack(pady=10)

    tree = ttk.Treeview(frame, columns=("Tipo categoria", "Cantidad de socios"), show="headings")
    tree.heading("Tipo categoria", text="Tipo categoria")
    tree.heading("Cantidad de socios", text="Cantidad de socios")

    tree.pack(expand=True, fill="both")

    # Cargar datos en la tabla
    socios_in_AllfreeACT = fetch_socios_in_AllfreeACT()

    for socios in socios_in_AllfreeACT:
        tree.insert("", "end", values=socios)

def show_consultas_window():
    add_window = ctk.CTkToplevel()
    add_window.title("Consultas")

    # Agrandar la ventana
    add_window.geometry("250x200")
    
    ctk.CTkButton(add_window, text="Deudores año corriente", command=lambda: consulta_deudores_anioCorriente()).grid(row=0, column=1, columnspan=2, padx=10, pady=10)
    ctk.CTkButton(add_window, text="Socios en actividades gratuitas", command=lambda: consulta_socios_AllfreeACT()).grid(row=1, column=1, columnspan=2, padx=10, pady=10)

def show_stats():
    try:
        conn = connect_db()
        cursor = conn.cursor()

        # Obtener estadísticas
        cursor.execute("SELECT COUNT(*) FROM SOCIO")
        num_socios = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM ACTIVIDAD")
        num_actividades = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM GRUPO_FAMILIAR")
        num_grupos = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM AREA")
        num_areas = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM PROFESIONAL")
        num_profesionales = cursor.fetchone()[0]

        cursor.execute("SELECT COUNT(*) FROM TURNO")
        num_turnos = cursor.fetchone()[0]

        # Mostrar estadísticas
        stats_window = ctk.CTkToplevel()
        stats_window.title("Estadísticas")

        ctk.CTkLabel(stats_window, text=f"Cantidad de Socios: {num_socios}").pack(pady=10)
        ctk.CTkLabel(stats_window, text=f"Cantidad de Actividades: {num_actividades}").pack(pady=10)
        ctk.CTkLabel(stats_window, text=f"Cantidad de Grupos Familiares: {num_grupos}").pack(pady=10)
        ctk.CTkLabel(stats_window, text=f"Cantidad de Áreas: {num_areas}").pack(pady=10)
        ctk.CTkLabel(stats_window, text=f"Cantidad de Profesionales: {num_profesionales}").pack(pady=10)
        ctk.CTkLabel(stats_window, text=f"Cantidad de Turnos: {num_turnos}").pack(pady=10)

        conn.close()
    except mysql.connector.Error as e:
        messagebox.showerror("Error", f"Ocurrió un error de MySQL: {e.msg}")
    except Exception as e:
        messagebox.showerror("Error", f"Ocurrió un error: {e}")

def delete_socio(nro_grupo, nro_socio):
    try:
        conn = connect_db()
        cursor = conn.cursor()

        # Configurar el nivel de aislamiento serializable
        cursor.execute("SET TRANSACTION ISOLATION LEVEL SERIALIZABLE")

        # Convertir a tipo int si es necesario
        nro_grupo = int(nro_grupo)
        nro_socio = int(nro_socio)

        # Iniciar la transacción
        cursor.execute("START TRANSACTION")

        # Desactivar la verificación de claves foráneas
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")

        # 1. Eliminar las inscripciones del socio
        cursor.execute("DELETE FROM SE_INSCRIBE WHERE NRO_GRUPO = %s AND NRO_SOCIO = %s", (nro_grupo, nro_socio))

        # 2. Eliminar los pagos de arancel del socio
        cursor.execute("DELETE FROM PAGO_ARANCEL WHERE NRO_GRUPO = %s AND NRO_SOCIO = %s", (nro_grupo, nro_socio))

        # 3. Eliminar las categorías asociadas al socio
        cursor.execute("DELETE FROM POSEE WHERE NRO_GRUPO = %s AND NRO_SOCIO = %s", (nro_grupo, nro_socio))

        # 4. Eliminar las cuotas sociales asociadas al socio
        cursor.execute("DELETE FROM CUOTA_SOCIAL WHERE NRO_GRUPO = %s AND NRO_SOCIO = %s", (nro_grupo, nro_socio))

        # 5. Eliminar al socio de la tabla SOCIO
        cursor.execute("DELETE FROM SOCIO WHERE NRO_GRUPO = %s AND NRO_SOCIO = %s", (nro_grupo, nro_socio))

        # Comprobar si el grupo familiar se queda sin socios
        cursor.execute("SELECT COUNT(*) FROM SOCIO WHERE NRO_GRUPO = %s", (nro_grupo,))
        socio_count = cursor.fetchone()[0]

        # Si el grupo familiar no tiene más socios, eliminar las referencias al grupo
        if socio_count == 0:
            cursor.execute("DELETE FROM CUOTA_MENSUAL WHERE NRO_GRUPO = %s", (nro_grupo,))
            cursor.execute("DELETE FROM CONTACTO WHERE NRO_GRUPO = %s", (nro_grupo,))
            cursor.execute("DELETE FROM GRUPO_FAMILIAR WHERE NRO_GRUPO = %s", (nro_grupo,))

        # Reactivar la verificación de claves foráneas
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")

        # Confirmar la transacción
        conn.commit()
        messagebox.showinfo("Éxito", "Socio eliminado exitosamente.")
    except Exception as e:
        conn.rollback()
        messagebox.showerror("Error", f"Ocurrió un error: {e}")
    finally:
        cursor.close()
        conn.close()
        

def fetch_activities():
    conn = connect_db()
    cursor = conn.cursor()
    query = "SELECT * FROM Cronograma_Activo"
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows

root = ctk.CTk()
root.title("Gestión de Socios")

# Agrandar la ventana
root.geometry("800x500")

# Añadir título
ctk.CTkLabel(root, text="Club Deportivo", font=("Helvetica", 24)).pack(pady=20)

# Crear un frame para los botones
button_frame = ctk.CTkFrame(root)
button_frame.pack(pady=20)

# Botón para mostrar la ventana de agregar socio
ctk.CTkButton(button_frame, text="Agregar Socio", font=("Helvetica", 16), command=show_add_socio_window).grid(row=0, column=0, padx=10, pady=10)

# Botón para mostrar la ventana de eliminar socio
ctk.CTkButton(button_frame, text="Eliminar Socio", font=("Helvetica", 16), command=show_delete_socio_window).grid(row=0, column=1, padx=10, pady=10)

ctk.CTkButton(button_frame, text="Consultar Grupo", font=("Helvetica", 16), command=show_consultar_grupo_window).grid(row=0, column=2, padx=10, pady=10)

ctk.CTkButton(button_frame, text="Consultas", font=("Helvetica", 16), command=show_consultas_window).grid(row=0, column=3, padx=10, pady=10)

# Botón para mostrar estadísticas
ctk.CTkButton(button_frame, text="Ver Estadísticas", font=("Helvetica", 16), command=show_stats).grid(row=0, column=4, padx=10, pady=10)

# Mostrar la fecha y hora del día corriente
now = datetime.now().strftime("%Y-%m-%d  -  %H:%M:%S")
ctk.CTkLabel(root, text=f"{now}", font=("Helvetica", 16)).pack(pady=5)

# Crear tabla para mostrar las actividades
frame = ctk.CTkFrame(root)
frame.pack(pady=10)

tree = ttk.Treeview(frame, columns=("Actividad", "Fecha", "Horario"), show="headings")
tree.heading("Actividad", text="Actividad")
tree.heading("Fecha", text="Fecha")
tree.heading("Horario", text="Horario")
tree.pack(expand=True, fill="both")

# Cargar datos en la tabla
activities = fetch_activities()

for activity in activities:
    tree.insert("", "end", values=activity)
    
# Función para cerrar la aplicación
def on_closing():
    root.destroy()

# Vincula el evento de cierre de la ventana principal
root.protocol("WM_DELETE_WINDOW", on_closing)

# Ejecutar la interfaz gráfica
root.mainloop()
