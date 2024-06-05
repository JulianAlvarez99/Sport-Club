import customtkinter as ctk
import mysql.connector
from mysql.connector import Error

# Configuración de la conexión a MySQL
def create_connection():
    return mysql.connector.connect(
        host='your_host',
        user='your_username',
        password='your_password',
        database='your_database'
    )

# Crear la tabla si no existe
def create_table():
    connection = create_connection()
    cursor = connection.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            age INT NOT NULL,
            email VARCHAR(255) NOT NULL
        )
    ''')
    connection.commit()
    cursor.close()
    connection.close()

# Funciones para la GUI
def insert_data(name, age, email):
    connection = create_connection()
    cursor = connection.cursor()
    cursor.execute("INSERT INTO users (name, age, email) VALUES (%s, %s, %s)", (name, age, email))
    connection.commit()
    cursor.close()
    connection.close()
    display_data()

def delete_data(user_id):
    connection = create_connection()
    cursor = connection.cursor()
    cursor.execute("DELETE FROM users WHERE id=%s", (user_id,))
    connection.commit()
    cursor.close()
    connection.close()
    display_data()

def display_data():
    connection = create_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM users")
    records = cursor.fetchall()
    for row in tree.get_children():
        tree.delete(row)
    for record in records:
        tree.insert("", "end", values=record)
    cursor.close()
    connection.close()
    update_stats()

def generate_report():
    connection = create_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM users")
    records = cursor.fetchall()
    with open('report.txt', 'w') as f:
        for record in records:
            f.write(f"{record}\n")
    cursor.close()
    connection.close()

def update_stats():
    connection = create_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT COUNT(*), AVG(age) FROM users")
    count, avg_age = cursor.fetchone()
    stats_text.delete(1.0, ctk.END)
    stats_text.insert(ctk.END, f"Total Users: {count}\n")
    stats_text.insert(ctk.END, f"Average Age: {avg_age:.2f}\n")
    cursor.close()
    connection.close()

def open_insert_window():
    insert_window = ctk.CTkToplevel(app)
    insert_window.title("Insert Data")
    insert_window.geometry("300x200")

    label_name = ctk.CTkLabel(insert_window, text="Name:")
    label_name.grid(row=0, column=0, padx=10, pady=10)
    entry_name = ctk.CTkEntry(insert_window)
    entry_name.grid(row=0, column=1, padx=10, pady=10)

    label_age = ctk.CTkLabel(insert_window, text="Age:")
    label_age.grid(row=1, column=0, padx=10, pady=10)
    entry_age = ctk.CTkEntry(insert_window)
    entry_age.grid(row=1, column=1, padx=10, pady=10)

    label_email = ctk.CTkLabel(insert_window, text="Email:")
    label_email.grid(row=2, column=0, padx=10, pady=10)
    entry_email = ctk.CTkEntry(insert_window)
    entry_email.grid(row=2, column=1, padx=10, pady=10)

    def submit():
        name = entry_name.get()
        age = entry_age.get()
        email = entry_email.get()
        insert_data(name, age, email)
        insert_window.destroy()

    button_submit = ctk.CTkButton(insert_window, text="Submit", command=submit)
    button_submit.grid(row=3, column=0, columnspan=2, pady=10)

def open_delete_window():
    delete_window = ctk.CTkToplevel(app)
    delete_window.title("Delete Data")
    delete_window.geometry("300x100")

    label_id = ctk.CTkLabel(delete_window, text="User ID:")
    label_id.grid(row=0, column=0, padx=10, pady=10)
    entry_id = ctk.CTkEntry(delete_window)
    entry_id.grid(row=0, column=1, padx=10, pady=10)

    def submit():
        user_id = entry_id.get()
        delete_data(user_id)
        delete_window.destroy()

    button_submit = ctk.CTkButton(delete_window, text="Submit", command=submit)
    button_submit.grid(row=1, column=0, columnspan=2, pady=10)

def open_search_window():
    search_window = ctk.CTkToplevel(app)
    search_window.title("Search Data")
    search_window.geometry("400x300")

    def search_data():
        search_query = entry_search.get()
        connection = create_connection()
        cursor = connection.cursor()
        query = "SELECT * FROM users WHERE name LIKE %s OR email LIKE %s"
        cursor.execute(query, ('%' + search_query + '%', '%' + search_query + '%'))
        records = cursor.fetchall()
        for row in tree_search.get_children():
            tree_search.delete(row)
        for record in records:
            tree_search.insert("", "end", values=record)
        cursor.close()
        connection.close()

    label_search = ctk.CTkLabel(search_window, text="Search:")
    label_search.grid(row=0, column=0, padx=10, pady=10)
    entry_search = ctk.CTkEntry(search_window)
    entry_search.grid(row=0, column=1, padx=10, pady=10)

    button_search = ctk.CTkButton(search_window, text="Search", command=search_data)
    button_search.grid(row=0, column=2, padx=10, pady=10)

    tree_search = ctk.CTkTreeview(search_window, columns=("ID", "Name", "Age", "Email"), show="headings")
    tree_search.heading("ID", text="ID")
    tree_search.heading("Name", text="Name")
    tree_search.heading("Age", text="Age")
    tree_search.heading("Email", text="Email")
    tree_search.grid(row=1, column=0, columnspan=3, padx=10, pady=10)

# Configuración de la GUI
app = ctk.CTk()
app.title("Database Management")
app.geometry("800x600")

# Treeview to display data
# tree = ctk.CTkTreeview(app, columns=("ID", "Name", "Age", "Email"), show="headings")
# tree.heading("ID", text="ID")
# tree.heading("Name", text="Name")
# tree.heading("Age", text="Age")
# tree.heading("Email", text="Email")
# tree.grid(row=0, column=0, columnspan=3, padx=10, pady=10)

# Text box for statistics
stats_text = ctk.CTkTextbox(app, height=4)
stats_text.grid(row=1, column=0, columnspan=3, padx=10, pady=10, sticky="ew")

# Frame for buttons at the bottom
button_frame = ctk.CTkFrame(app)
button_frame.grid(row=2, column=0, columnspan=3, pady=20, sticky="ew")

button_insert_main = ctk.CTkButton(button_frame, text="Insert Data", command=open_insert_window)
button_insert_main.grid(row=0, column=0, padx=10, pady=10)

button_delete_main = ctk.CTkButton(button_frame, text="Delete Data", command=open_delete_window)
button_delete_main.grid(row=0, column=1, padx=10, pady=10)

button_search_main = ctk.CTkButton(button_frame, text="Search Data", command=open_search_window)
button_search_main.grid(row=0, column=2, padx=10, pady=10)

# Función para cerrar la aplicación
def on_closing():
    app.destroy()

# Vincula el evento de cierre de la ventana principal
app.protocol("WM_DELETE_WINDOW", on_closing)

# # Crear tabla si no existe
# create_table()

# # Mostrar datos iniciales
# display_data()

# Iniciar la aplicación
app.mainloop()
