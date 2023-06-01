--LOJAS UVV

--Apaga o banco de dados "uvv" e o usuario "talles" caso eles existam

DROP DATABASE IF EXISTS uvv WITH (force);

DROP USER IF EXISTS talles;

--Cria o usuario

CREATE USER talles WITH createrole createdb encrypted password 'senha';
ALTER USER talles
SET SEARCH_PATH TO lojas, "$user", public;

--Muda o caminho de esquema padrão

--Cria o banco de dados "uvv"

CREATE DATABASE uvv 
	   OWNER = talles
	   TEMPLATE = template0
	   ENCODING = 'UTF8'
	   LC_COLLATE = 'pt_BR.UTF-8'
   	   LC_CTYPE = 'pt_BR.UTF-8'
	   ALLOW_CONNECTIONS = TRUE;
	  
--Escreve automaticamente a senha no prompt
	  
\setenv PGPASSWORD senha

--Muda para o banco de dados uvv usando o usuario "talles"

\c uvv talles;

--Cria o esquema lojas

CREATE SCHEMA lojas AUTHORIZATION talles;

--Cria a tabela produtos com restrição em "preco_unitario"

CREATE TABLE lojas.produtos (
                produto_id                NUMERIC(38)  NOT NULL,
                nome                      VARCHAR(255) NOT NULL,
                preco_unitario            NUMERIC(10,2) CHECK (preco_unitario > 0),
                detalhes                  BYTEA,
                imagem                    BYTEA,
                imagem_mime_type          VARCHAR(512),
                imagem_arquivo            VARCHAR(512),
                imagem_charset            VARCHAR(512),
                imagem_ultima_atualizacao DATE,
                --Modifica a coluna produto_id para PK
                CONSTRAINT produtos_pk 
                PRIMARY KEY (produto_id)
);

--Comenta na tabela e nas colunas

COMMENT ON TABLE  lojas.produtos             IS 'Tabela com dados dos produtos';
COMMENT ON COLUMN lojas.produtos.produto_id  IS 'Identificação do produto';
COMMENT ON COLUMN lojas.produtos.nome        IS 'Nome do produto';

--Cria a tabela lojas

CREATE TABLE lojas.lojas (
                loja_id                 NUMERIC(38) NOT NULL,
                nome                    VARCHAR(255) NOT NULL,
                endereco_web            VARCHAR(100),
                endereco_fisico         VARCHAR(512),
                latitude                NUMERIC,
                longitude               NUMERIC,
                logo                    BYTEA,
                logo_mime_type          VARCHAR(512),
                logo_arquivo            VARCHAR(512),
                logo_charset            VARCHAR(512),
                logo_ultima_atualizacao DATE,
                --Cria uma restrição para a tabela "endereco_web" ou "endereco_fisico"
                CONSTRAINT lojas_endereco
                CHECK(endereco_web IS NOT NULL OR endereco_fisico IS NOT NULL),
                --Modifica a coluna loja_id para PK
                CONSTRAINT lojas_pk
                PRIMARY KEY (loja_id)
);
--Comenta na tabela e nas colunas
COMMENT ON TABLE  lojas.lojas          IS 'Tabela com dados das lojas';
COMMENT ON COLUMN lojas.lojas.loja_id  IS 'Identificação da loja';
COMMENT ON COLUMN lojas.lojas.nome     IS 'Nome da loja';

--Cria a tabela estoques com restrição em "quantidade"
CREATE TABLE lojas.estoques (
                estoque_id NUMERIC(38) NOT NULL,
                loja_id    NUMERIC(38) NOT NULL,
                produto_id NUMERIC(38) NOT NULL,
                quantidade NUMERIC(38) NOT NULL CHECK (quantidade > 0),
                CONSTRAINT estoques_pk
                PRIMARY KEY (estoque_id)
);
--Comenta na tabela e nas colunas
COMMENT ON TABLE  lojas.estoques            IS 'Tabela com dados dos estoques';
COMMENT ON COLUMN lojas.estoques.estoque_id IS 'Identificação do estoque';
COMMENT ON COLUMN lojas.estoques.loja_id    IS 'Identificação da loja';
COMMENT ON COLUMN lojas.estoques.produto_id IS 'Identificação do produto';
COMMENT ON COLUMN lojas.estoques.quantidade IS 'Quantidade de produtos no estoque';

--Cria a tabela clientes
CREATE TABLE lojas.clientes (
                cliente_id NUMERIC(38)  NOT NULL,
                email      VARCHAR(255) NOT NULL,
                nome       VARCHAR(255) NOT NULL,
                telefone1  VARCHAR(20),
                telefone2  VARCHAR(20),
                telefone3  VARCHAR(20),
                CONSTRAINT clientes_pk 
                PRIMARY KEY (cliente_id)
);
--Comenta na tabela e nas colunas
COMMENT ON TABLE  lojas.clientes            IS 'Tabela com dado dos clientes';
COMMENT ON COLUMN lojas.clientes.cliente_id IS 'Identificação do cliente';
COMMENT ON COLUMN lojas.clientes.email      IS 'Email do cliente';
COMMENT ON COLUMN lojas.clientes.nome       IS 'Nome do cliente';
COMMENT ON COLUMN lojas.clientes.telefone1  IS 'número de telefone do cliente';
COMMENT ON COLUMN lojas.clientes.telefone2  IS 'número de telefone';
COMMENT ON COLUMN lojas.clientes.telefone3  IS 'número de telefone do cliente';

--Cria a tabela pedido com restrições em "status"
CREATE TABLE lojas.pedidos (
                pedido_id  NUMERIC(38) NOT NULL,
                data_hora  TIMESTAMP   NOT NULL,
                cliente_id NUMERIC(38) NOT NULL,
                status     VARCHAR(15) NOT NULL CHECK (status IN('CANCELADO', 'COMPLETO', 'ABERTO', 'PAGO', 'REEMBOLSADO', 'ENVIADO')),
                loja_id    NUMERIC(38) NOT NULL,
                CONSTRAINT pedidos_pk
                PRIMARY KEY (pedido_id)
);
--Comenta na tabela e nas colunas
COMMENT ON TABLE  lojas.pedidos            IS 'Tabela com dados dos pedidos';
COMMENT ON COLUMN lojas.pedidos.pedido_id  IS 'identificação dos pedidos';
COMMENT ON COLUMN lojas.pedidos.data_hora  IS 'data do pedido';
COMMENT ON COLUMN lojas.pedidos.cliente_id IS 'Identificação do cliente';
COMMENT ON COLUMN lojas.pedidos.status     IS 'Status do pedido';
COMMENT ON COLUMN lojas.pedidos.loja_id    IS 'Identificação da loja';

--Cria a tabela envios com restrições em "status"
CREATE TABLE lojas.envios (
                envio_id         NUMERIC(38)  NOT NULL,
                loja_id          NUMERIC(38)  NOT NULL,
                cliente_id       NUMERIC(38)  NOT NULL,
                endereco_entrega VARCHAR(512) NOT NULL,
                status           VARCHAR(15)  NOT NULL CHECK (status IN('CRIADO', 'ENVIADO', 'TRANSITO', 'ENTREGUE')),
                CONSTRAINT envios_pk
                PRIMARY KEY (envio_id)
);
--Comenta na tabela e nas colunas
COMMENT ON TABLE  lojas.envios                  IS 'Tabela com dados dos envios';
COMMENT ON COLUMN lojas.envios.envio_id         IS 'Identificação do envio';
COMMENT ON COLUMN lojas.envios.loja_id          IS 'identificação da loja';
COMMENT ON COLUMN lojas.envios.cliente_id       IS 'identificação do cliente';
COMMENT ON COLUMN lojas.envios.endereco_entrega IS 'endereço';
COMMENT ON COLUMN lojas.envios.status           IS 'status do envio';

--Cria a tabela pedidos_itens com restrições em "preço_unitario" e "quantidade" 
CREATE TABLE lojas.pedidos_itens (
                pedido_id       NUMERIC(38)   NOT NULL,
                produto_id      NUMERIC(38)   NOT NULL,
                numero_da_linha NUMERIC(38)   NOT NULL,
                preco_unitario  NUMERIC(10,2) NOT NULL CHECK (preco_unitario > 0),
                quantidade      NUMERIC(38)   NOT NULL CHECK (quantidade > 0),
                envio_id        NUMERIC(38),
                CONSTRAINT pedidos_itens_pk
                PRIMARY KEY (pedido_id, produto_id)
);
--Comenta na tabela e nas colunas
COMMENT ON TABLE  lojas.pedidos_itens            IS 'Tabela com dados dos itens pedidos';
COMMENT ON COLUMN lojas.pedidos_itens.pedido_id  IS 'Identificação do pedido';
COMMENT ON COLUMN lojas.pedidos_itens.produto_id IS 'identificação do produto';

--Cria as relações entre as tabelas

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT produtos_pedidos_itens_fk
FOREIGN KEY (produto_id)
REFERENCES  lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.estoques ADD CONSTRAINT produtos_estoques_fk
FOREIGN KEY (produto_id)
REFERENCES  lojas.produtos (produto_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.envios ADD CONSTRAINT lojas_envios_fk
FOREIGN KEY (loja_id)
REFERENCES  lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos ADD CONSTRAINT lojas_pedidos_fk
FOREIGN KEY (loja_id)
REFERENCES  lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.estoques ADD CONSTRAINT lojas_estoques_fk
FOREIGN KEY (loja_id)
REFERENCES  lojas.lojas (loja_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.envios ADD CONSTRAINT clientes_envios_fk
FOREIGN KEY (cliente_id)
REFERENCES  lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos ADD CONSTRAINT clientes_pedidos_fk
FOREIGN KEY (cliente_id)
REFERENCES  lojas.clientes (cliente_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT pedidos_pedidos_itens_fk
FOREIGN KEY (pedido_id)
REFERENCES  lojas.pedidos (pedido_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE lojas.pedidos_itens ADD CONSTRAINT envios_pedidos_itens_fk
FOREIGN KEY (envio_id)
REFERENCES  lojas.envios (envio_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;