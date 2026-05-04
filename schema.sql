CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,          -- Identificador único del cliente
  full_name TEXT NOT NULL,                  -- Nombre completo del cliente
  email TEXT NOT NULL UNIQUE,               -- Correo electrónico único por cliente
  phone TEXT,                               -- Teléfono (opcional)
  city TEXT NOT NULL,                       -- Ciudad de residencia
  segment TEXT NOT NULL CHECK(segment IN ('retail', 'wholesale', 'online_only', 'vip')), -- Tipo de cliente
  created_at DATETIME NOT NULL,             -- Fecha de registro
  is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1)), -- 1=activo, 0=inactivo
  deleted_at DATETIME                       -- Fecha de borrado lógico (NULL = no borrado)
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,           -- Identificador único del producto
  sku TEXT NOT NULL UNIQUE,                 -- Código de barras único del producto
  product_name TEXT NOT NULL,              -- Nombre del producto
  category TEXT NOT NULL,                  -- Categoría (ej: fashion, office)
  brand TEXT NOT NULL,                     -- Marca del producto
  unit_price REAL NOT NULL CHECK(unit_price >= 0),  -- Precio de venta al cliente
  unit_cost REAL NOT NULL CHECK(unit_cost >= 0),    -- Costo de fabricación o compra
  created_at DATETIME NOT NULL,            -- Fecha de creación del producto
  is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1)), -- 1=activo, 0=inactivo
  deleted_at DATETIME                      -- Fecha de borrado lógico (NULL = no borrado)
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,            -- Identificador único del pedido
  customer_id INTEGER NOT NULL,            -- Cliente que realizó el pedido (FK)
  order_datetime DATETIME NOT NULL,        -- Fecha y hora del pedido
  channel TEXT NOT NULL CHECK(channel IN ('web', 'mobile', 'store', 'phone')), -- Canal de venta
  currency TEXT NOT NULL,                  -- Moneda utilizada en el pedido
  current_status TEXT NOT NULL CHECK(current_status IN ('shipped', 'created', 'delivered', 'paid', 'cancelled', 'packed', 'refunded')), -- Estado actual
  is_active INTEGER NOT NULL DEFAULT 1 CHECK(is_active IN (0, 1)), -- 1=activo, 0=inactivo
  deleted_at DATETIME,                     -- Fecha de borrado lógico (NULL = no borrado)
  order_total REAL NOT NULL CHECK(order_total >= 0), -- Monto total del pedido
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  order_item_id INTEGER PRIMARY KEY,       -- Identificador único del item
  order_id INTEGER NOT NULL,               -- Pedido al que pertenece este item (FK)
  product_id INTEGER NOT NULL,             -- Producto incluido en el item (FK)
  quantity INTEGER NOT NULL CHECK(quantity > 0),           -- Cantidad comprada (mínimo 1)
  unit_price REAL NOT NULL CHECK(unit_price >= 0),         -- Precio unitario al momento de compra
  discount_rate REAL NOT NULL DEFAULT 0 CHECK(discount_rate >= 0 AND discount_rate <= 1), -- Descuento aplicado (0 a 1)
  line_total REAL NOT NULL CHECK(line_total >= 0),         -- Total de la línea con descuento
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
  payment_id INTEGER PRIMARY KEY,          -- Identificador único del pago
  order_id INTEGER NOT NULL,               -- Pedido al que corresponde el pago (FK)
  payment_datetime DATETIME NOT NULL,      -- Fecha y hora del pago
  method TEXT NOT NULL CHECK(method IN ('card', 'transfer', 'cash', 'wallet')), -- Método de pago
  payment_status TEXT NOT NULL CHECK(payment_status IN ('rejected', 'approved', 'pending', 'refunded')), -- Estado del pago
  amount REAL NOT NULL CHECK(amount >= 0), -- Monto pagado
  currency TEXT NOT NULL,                  -- Moneda del pago
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_status_history (
  status_history_id INTEGER PRIMARY KEY,   -- Identificador único del registro
  order_id INTEGER NOT NULL,               -- Pedido al que pertenece el cambio (FK)
  status TEXT NOT NULL CHECK(status IN ('shipped', 'packed', 'delivered', 'created', 'paid', 'refunded', 'cancelled')), -- Estado registrado
  changed_at DATETIME NOT NULL,            -- Fecha y hora del cambio
  changed_by TEXT NOT NULL CHECK(changed_by IN ('system', 'user', 'ops', 'warehouse', 'payment_gateway')), -- Quién realizó el cambio
  reason TEXT,                             -- Motivo del cambio (opcional)
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_audit (
  audit_id INTEGER PRIMARY KEY,            -- Identificador único del registro de auditoría
  order_id INTEGER NOT NULL,               -- Pedido auditado (FK)
  field_name TEXT NOT NULL,               -- Campo que fue modificado
  old_value TEXT,                          -- Valor anterior al cambio
  new_value TEXT,                          -- Valor nuevo después del cambio
  changed_at DATETIME NOT NULL,            -- Fecha y hora del cambio
  changed_by TEXT NOT NULL CHECK(changed_by IN ('system', 'support', 'ops')), -- Quién realizó el cambio
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Índice para buscar pedidos de un cliente rápidamente
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Índice para buscar items de un pedido rápidamente
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- Índice para buscar pagos de un pedido rápidamente
CREATE INDEX idx_payments_order_id ON payments(order_id);

-- Índice para buscar historial de un pedido rápidamente
CREATE INDEX idx_status_history_order_id ON order_status_history(order_id);