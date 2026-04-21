
CREATE TABLE customers (

    -- El identificador único de cada cliente
    -- INTEGER = número entero
    -- PRIMARY KEY = es la clave principal, no puede repetirse ni ser NULL
    customer_id   INTEGER     PRIMARY KEY,

    -- El nombre completo del cliente
    -- TEXT = texto
    -- NOT NULL = obligatorio, no puede estar vacío
    full_name     TEXT        NOT NULL,

    -- El email, también obligatorio y único (no puede haber dos clientes con el mismo email)
    email         TEXT        NOT NULL    UNIQUE,

    -- El teléfono, puede estar vacío (no todos lo tienen)
    phone         TEXT,

    -- La ciudad, obligatoria
    city          TEXT        NOT NULL,

    -- El segmento: solo puede ser 'retail', 'wholesale', 'online_only' o 'vip'
    -- CHECK valida que el valor sea uno de los dos permitidos
    segment       TEXT        NOT NULL    CHECK(segment IN ('retail', 'wholesale', 'online_only', 'vip')),

    -- Fecha de creación, obligatoria
    created_at    DATETIME    NOT NULL,

    -- Si está activo: solo puede ser 0 o 1
    -- DEFAULT 1 = si no se aclara, asume que está activo
    is_active     INTEGER     NOT NULL    DEFAULT 1   CHECK(is_active IN (0, 1)),

    -- Fecha de borrado lógico: puede estar vacío (NULL = no fue borrado)
    deleted_at    DATETIME

);

CREATE TABLE products (

    -- Identificador único del producto
    product_id    INTEGER     PRIMARY KEY,

    -- Código de barras único del producto (ej: SKU-658EDSCIEQ)
    -- UNIQUE porque no pueden existir dos productos con el mismo SKU
    sku           TEXT        NOT NULL    UNIQUE,

    -- Nombre del producto
    product_name  TEXT        NOT NULL,

    -- Categoría (ej: fashion, office, etc.)
    category      TEXT        NOT NULL,

    -- Marca del producto
    brand         TEXT        NOT NULL,

    -- Precio de venta al cliente (no puede ser negativo)
    unit_price    REAL        NOT NULL    CHECK(unit_price >= 0),

    -- Costo de fabricación/compra (no puede ser negativo)
    unit_cost     REAL        NOT NULL    CHECK(unit_cost >= 0),

    -- Fecha de creación del producto
    created_at    DATETIME    NOT NULL,

    -- Si está activo: 0 o 1
    is_active     INTEGER     NOT NULL    DEFAULT 1   CHECK(is_active IN (0, 1)),

    -- Fecha de borrado lógico (NULL = no fue borrado)
    deleted_at    DATETIME

);

CREATE TABLE orders (

    -- Identificador único del pedido
    order_id          INTEGER     PRIMARY KEY,

    -- El cliente que hizo el pedido
    -- FK: este número debe existir en la tabla customers
    customer_id       INTEGER     NOT NULL,

    -- Fecha y hora del pedido
    order_datetime    DATETIME    NOT NULL,

    -- Canal de venta: solo 'web', 'mobile', 'store' o 'phone'
    channel           TEXT        NOT NULL    CHECK(channel IN ('web', 'mobile', 'store', 'phone')),

    -- Moneda usada
    currency          TEXT        NOT NULL,

    -- Estado actual del pedido
    current_status    TEXT        NOT NULL    CHECK(current_status IN ('shipped', 'created', 'delivered', 'paid', 'cancelled', 'packed', 'refunded')),

    -- Si está activo
    is_active         INTEGER     NOT NULL    DEFAULT 1   CHECK(is_active IN (0, 1)),

    -- Borrado lógico
    deleted_at        DATETIME,

    -- Total del pedido (no puede ser negativo)
    order_total       REAL        NOT NULL    CHECK(order_total >= 0),

    -- Acá se declara la relación con customers
    -- "customer_id en esta tabla debe existir en customers"
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)

);

CREATE TABLE order_items (

    -- Identificador único del item
    order_item_id    INTEGER    PRIMARY KEY,

    -- A qué pedido pertenece este item
    -- FK: debe existir en orders
    order_id         INTEGER    NOT NULL,

    -- Qué producto es
    -- FK: debe existir en products
    product_id       INTEGER    NOT NULL,

    -- Cantidad comprada (mínimo 1, no puede ser 0 ni negativo)
    quantity         INTEGER    NOT NULL    CHECK(quantity > 0),

    -- Precio unitario al momento de la compra
    unit_price       REAL       NOT NULL    CHECK(unit_price >= 0),

    -- Descuento aplicado (entre 0 y 1, ej: 0.15 = 15%)
    discount_rate    REAL       NOT NULL    DEFAULT 0   CHECK(discount_rate >= 0 AND discount_rate <= 1),

    -- Total de esta línea (quantity * unit_price con descuento)
    line_total       REAL       NOT NULL    CHECK(line_total >= 0),

    -- Relaciones
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)

);

CREATE TABLE payments (

    -- Identificador único del pago
    payment_id          INTEGER    PRIMARY KEY,

    -- A qué pedido corresponde este pago
    -- FK: debe existir en orders
    order_id            INTEGER    NOT NULL,

    -- Fecha y hora del pago
    payment_datetime    DATETIME   NOT NULL,

    -- Método de pago
    method              TEXT       NOT NULL    CHECK(method IN ('card', 'transfer', 'cash', 'wallet')),

    -- Estado del pago
    payment_status      TEXT       NOT NULL    CHECK(payment_status IN ('rejected', 'approved', 'pending', 'refunded')),

    -- Monto pagado (no puede ser negativo ni cero)
    amount              REAL       NOT NULL    CHECK(amount >= 0),

    -- Moneda
    currency            TEXT       NOT NULL,

    -- Relación
    FOREIGN KEY (order_id) REFERENCES orders(order_id)

);

CREATE TABLE order_status_history (

    -- Identificador único del registro
    status_history_id    INTEGER    PRIMARY KEY,

    -- A qué pedido pertenece
    order_id             INTEGER    NOT NULL,

    -- El estado que tomó el pedido en ese momento
    status               TEXT       NOT NULL    CHECK(status IN ('shipped', 'packed', 'delivered', 'created', 'paid', 'refunded', 'cancelled')),

    -- Cuándo cambió
    changed_at           DATETIME   NOT NULL,

    -- Quién lo cambió
    changed_by           TEXT       NOT NULL    CHECK(changed_by IN ('system', 'user', 'ops', 'warehouse', 'payment_gateway')),

    -- Motivo del cambio (puede estar vacío)
    reason               TEXT,

    -- Relación
    FOREIGN KEY (order_id) REFERENCES orders(order_id)

);

CREATE TABLE order_audit (

    -- Identificador único del registro de auditoría
    audit_id      INTEGER    PRIMARY KEY,

    -- A qué pedido pertenece
    order_id      INTEGER    NOT NULL,

    -- Qué campo fue modificado (ej: "order_total", "shipping_address")
    field_name    TEXT       NOT NULL,

    -- Valor anterior
    old_value     TEXT,

    -- Valor nuevo
    new_value     TEXT,

    -- Cuándo ocurrió el cambio
    changed_at    DATETIME   NOT NULL,

    -- Quién lo hizo
    changed_by    TEXT       NOT NULL    CHECK(changed_by IN ('system', 'support', 'ops')),

    -- Relación
    FOREIGN KEY (order_id) REFERENCES orders(order_id)

);

-- Buscar pedidos de un cliente rápidamente
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Buscar items de un pedido rápidamente
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

-- Buscar pagos de un pedido rápidamente
CREATE INDEX idx_payments_order_id ON payments(order_id);

-- Buscar historial de un pedido rápidamente
CREATE INDEX idx_status_history_order_id ON order_status_history(order_id);

