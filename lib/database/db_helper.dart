import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'inventario.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Producto (
        id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre      TEXT NOT NULL,
        stock       INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE Cliente (
        id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre     TEXT NOT NULL,
        telefono   TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Compra (
        id_compra INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha     TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Detalle_Compra (
        id_compra       INTEGER NOT NULL,
        id_producto     INTEGER NOT NULL,
        cantidad        INTEGER NOT NULL,
        precio_unitario REAL    NOT NULL,
        PRIMARY KEY (id_compra, id_producto),
        FOREIGN KEY (id_compra)   REFERENCES Compra(id_compra),
        FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
      )
    ''');

    await db.execute('''
      CREATE TABLE Venta (
        id_venta   INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INTEGER NOT NULL,
        fecha      TEXT    NOT NULL,
        FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
      )
    ''');

    await db.execute('''
      CREATE TABLE Detalle_Venta (
        id_venta        INTEGER NOT NULL,
        id_producto     INTEGER NOT NULL,
        cantidad        INTEGER NOT NULL,
        precio_unitario REAL    NOT NULL,
        PRIMARY KEY (id_venta, id_producto),
        FOREIGN KEY (id_venta)    REFERENCES Venta(id_venta),
        FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
      )
    ''');
  }

  // ─── PRODUCTOS ───────────────────────────────────────────

  Future<int> insertProducto(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('Producto', data);
  }

  Future<List<Map<String, dynamic>>> getProductos() async {
    final db = await database;
    return await db.query('Producto', orderBy: 'nombre');
  }

  Future<Map<String, dynamic>?> getProducto(int id) async {
    final db = await database;
    final res = await db.query(
      'Producto',
      where: 'id_producto = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> updateProducto(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'Producto',
      data,
      where: 'id_producto = ?',
      whereArgs: [data['id_producto']],
    );
  }

  Future<int> deleteProducto(int id) async {
    final db = await database;
    return await db.delete(
      'Producto',
      where: 'id_producto = ?',
      whereArgs: [id],
    );
  }

  // ─── CLIENTES ────────────────────────────────────────────

  Future<int> insertCliente(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('Cliente', data);
  }

  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await database;
    return await db.query('Cliente', orderBy: 'nombre');
  }

  Future<int> updateCliente(Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'Cliente',
      data,
      where: 'id_cliente = ?',
      whereArgs: [data['id_cliente']],
    );
  }

  Future<int> deleteCliente(int id) async {
    final db = await database;
    return await db.delete('Cliente', where: 'id_cliente = ?', whereArgs: [id]);
  }

  // ─── COMPRAS ─────────────────────────────────────────────

  Future<int> insertCompra(
    Map<String, dynamic> compra,
    List<Map<String, dynamic>> detalle,
  ) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Insertar compra
      final idCompra = await txn.insert('Compra', compra);

      for (var item in detalle) {
        final Map<String, dynamic> sanitizedItem = {
          'id_compra': idCompra,
          'id_producto': item['id_producto'],
          'cantidad': item['cantidad'],
          'precio_unitario': item['precio_unitario'],
        };

        // Insertar detalle
        await txn.insert('Detalle_Compra', sanitizedItem);

        // Sumar stock
        await txn.rawUpdate(
          '''
          UPDATE Producto SET stock = stock + ?
          WHERE id_producto = ?
        ''',
          [item['cantidad'], item['id_producto']],
        );
      }

      return idCompra;
    });
  }

  Future<List<Map<String, dynamic>>> getCompras() async {
    final db = await database;
    return await db.query('Compra', orderBy: 'fecha DESC');
  }

  Future<List<Map<String, dynamic>>> getDetalleCompra(int idCompra) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT dc.*, IFNULL(p.nombre, 'Producto Eliminado') as nombre
      FROM Detalle_Compra dc
      LEFT JOIN Producto p ON dc.id_producto = p.id_producto
      WHERE dc.id_compra = ?
    ''',
      [idCompra],
    );
  }

  // ─── VENTAS ──────────────────────────────────────────────

  Future<int> insertVenta(
    Map<String, dynamic> venta,
    List<Map<String, dynamic>> detalle,
  ) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Insertar venta
      final idVenta = await txn.insert('Venta', venta);

      for (var item in detalle) {
        final Map<String, dynamic> sanitizedItem = {
          'id_venta': idVenta,
          'id_producto': item['id_producto'],
          'cantidad': item['cantidad'],
          'precio_unitario': item['precio_unitario'],
        };

        // Insertar detalle
        await txn.insert('Detalle_Venta', sanitizedItem);

        // Descontar stock
        await txn.rawUpdate(
          '''
          UPDATE Producto SET stock = stock - ?
          WHERE id_producto = ?
        ''',
          [item['cantidad'], item['id_producto']],
        );
      }

      return idVenta;
    });
  }

  Future<List<Map<String, dynamic>>> getVentas() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT v.*, IFNULL(c.nombre, 'Cliente Eliminado') as nombre_cliente
      FROM Venta v
      LEFT JOIN Cliente c ON v.id_cliente = c.id_cliente
      ORDER BY v.fecha DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getDetalleVenta(int idVenta) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT dv.*, IFNULL(p.nombre, 'Producto Eliminado') as nombre
      FROM Detalle_Venta dv
      LEFT JOIN Producto p ON dv.id_producto = p.id_producto
      WHERE dv.id_venta = ?
    ''',
      [idVenta],
    );
  }
}
