--Projeto implementado usando o SGDB PostgreSQL

--Criacao do schema para o projeto
CREATE SCHEMA projeto;

--Criacao das tabelas
CREATE TABLE projeto.Cliente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(11),
    endereco VARCHAR(255),
    data_nascimento DATE
);

CREATE TABLE projeto.Produto (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco NUMERIC(10, 2) NOT NULL,
    disponivel BOOLEAN NOT NULL DEFAULT TRUE, 
);

CREATE TABLE projeto.Pedido (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES projeto.Cliente(id) ON DELETE CASCADE,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total NUMERIC(10, 2) NOT NULL DEFAULT 0
);

CREATE TABLE projeto.Item_Pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES projeto.Pedido(id) ON DELETE CASCADE,
    produto_id INT REFERENCES projeto.Produto(id) ON DELETE CASCADE,
    quantidade INT NOT NULL,
    valor NUMERIC(10, 2) NOT NULL
);

--Automatizando o calculo do total para evitar que tenha que ser feito de forma manual
CREATE OR REPLACE FUNCTION update_total_pedido()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE projeto.Pedido
    SET total = (SELECT COALESCE(SUM(quantidade * valor), 0) FROM projeto.Item_Pedido WHERE id = NEW.pedido_id)
    WHERE id = NEW.pedido_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_total_pedido
AFTER INSERT OR DELETE ON projeto.Item_Pedido
FOR EACH ROW EXECUTE FUNCTION update_total_pedido();

--Insert de dados e exemplo

--INSERT INTO projeto.Cliente (nome, email, telefone, endereco, data_nascimento) VALUES
--('Usuário Teste1', 'teste1@hotmail.com', '21999999999', 'Av. Brasil, 1', '2000-01-01'),
--('Usuário Teste2', 'teste2@hotmail.com', '21999999999', 'Av. Brasil, 1', '2000-01-01'),
--('Usuário Teste3', 'teste3@hotmail.com', '21999999999', 'Av. Brasil, 1', '2000-01-01');
--
--INSERT INTO projeto.Produto (nome, descricao, preco, disponivel) VALUES
--('Quadro 20x20', 'Dimensões: 20x20 cm', 55.00, TRUE),
--('Quadro 20x30', 'Dimensões: 20x30 cm', 65.00, TRUE),
--('Quadro 30x40', 'Dimensões: 30x40 cm', 80.00, TRUE),
--('Quadro 40x60', 'Dimensões: 40x60 cm', 120.00, TRUE),
--('Macramê', 'Dimensões: 1x1 m', 210.00, TRUE),
--('Macramê Wall Hanger', 'Dimensões: 20x75 cm', 40.00, TRUE),
--('Vasinho Pequeno', 'Dimensões: 12 cm / Sem planta', 20.00, TRUE),
--('Arte em Parede m²', 'Dimensões: 1x1 m / O valor do m² em parede pode variar após conclusão', 100.00, TRUE);
--
--WITH pedido AS (
--    INSERT INTO projeto.Pedido (cliente_id, data_pedido, total)
--    VALUES (1, CURRENT_TIMESTAMP, 0) RETURNING id
--)
--INSERT INTO projeto.Item_Pedido (pedido_id, produto_id, quantidade, valor)
--VALUES
--    ((SELECT id FROM pedido), (SELECT id FROM projeto.Produto WHERE id = 3), 2, (SELECT preco FROM projeto.Produto WHERE id = 3)),
--    ((SELECT id FROM pedido), (SELECT id FROM projeto.Produto WHERE id = 6), 1, (SELECT preco FROM projeto.Produto WHERE id = 6));
--
--
--select c.nome, p.data_pedido, p.total from projeto.Pedido p
--JOIN projeto.Cliente c ON p.cliente_id = c.id