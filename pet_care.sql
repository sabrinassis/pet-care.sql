-- =====================================================================
-- PET CARE - Sistema de gerenciamento para petshop
-- Disciplina: Modelagem de Banco de Dados | Grupo 03
-- SGBD: MySQL 8.0.16+ ou MariaDB 10.2.1+ (restrições CHECK aplicadas)
-- ATENÇÃO: o script inicia com DROP DATABASE IF EXISTS pet_care,
--          que apaga e recria o banco de mesmo nome.
-- =====================================================================

-- ---------------------------------------------------------------------
-- PARTE 1 - Criação do banco de dados
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS pet_care;
CREATE DATABASE pet_care CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pet_care;

-- ---------------------------------------------------------------------
-- PARTE 2 - Tabela clientes (tutores dos pets)
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente   INT AUTO_INCREMENT PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    cpf          VARCHAR(14)  UNIQUE,
    telefone     VARCHAR(20),
    email        VARCHAR(100)
);

-- ---------------------------------------------------------------------
-- PARTE 3 - Tabela funcionarios
-- ---------------------------------------------------------------------
CREATE TABLE funcionarios (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    cargo          VARCHAR(50)  NOT NULL,
    telefone       VARCHAR(20),
    salario        DECIMAL(10,2) CHECK (salario >= 0)
);

-- ---------------------------------------------------------------------
-- PARTE 4 - Tabela atendimentos (serviço prestado a um pet)
-- ---------------------------------------------------------------------
CREATE TABLE atendimentos (
    id_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    nome_pet       VARCHAR(100) NOT NULL,
    especie        VARCHAR(30)  NOT NULL,
    tipo_servico   VARCHAR(50)  NOT NULL,
    data_entrada   DATE,
    data_retirada  DATE,
    valor          DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
    status         VARCHAR(30)  NOT NULL DEFAULT 'Agendado',
    id_cliente     INT NOT NULL,
    id_funcionario INT NOT NULL,
    FOREIGN KEY (id_cliente)     REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

-- ---------------------------------------------------------------------
-- PARTE 5 - Tabela produtos (estoque de insumos e produtos)
-- ---------------------------------------------------------------------
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL DEFAULT 1 CHECK (quantidade >= 0),
    situacao   VARCHAR(30)  NOT NULL DEFAULT 'Em estoque'
);

-- ---------------------------------------------------------------------
-- PARTE 6 - Tabela etapas_atendimento
-- ---------------------------------------------------------------------
CREATE TABLE etapas_atendimento (
    id_etapa       INT AUTO_INCREMENT PRIMARY KEY,
    nome_etapa     VARCHAR(100) NOT NULL,
    descricao      TEXT,
    status         VARCHAR(30)  NOT NULL DEFAULT 'Pendente',
    id_atendimento INT NOT NULL,
    FOREIGN KEY (id_atendimento) REFERENCES atendimentos(id_atendimento)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- PARTE 7 - Tabela pagamentos (sem exclusão em cascata)
-- ---------------------------------------------------------------------
CREATE TABLE pagamentos (
    id_pagamento    INT AUTO_INCREMENT PRIMARY KEY,
    valor_pago      DECIMAL(10,2) NOT NULL CHECK (valor_pago > 0),
    data_pagamento  DATE NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    id_atendimento  INT NOT NULL,
    FOREIGN KEY (id_atendimento) REFERENCES atendimentos(id_atendimento)
);

-- ---------------------------------------------------------------------
-- PARTE 7.1 - Tabela uso_produtos (associativa N:N)
-- ---------------------------------------------------------------------
CREATE TABLE uso_produtos (
    id_atendimento       INT NOT NULL,
    id_produto           INT NOT NULL,
    quantidade_utilizada INT NOT NULL DEFAULT 1 CHECK (quantidade_utilizada > 0),
    PRIMARY KEY (id_atendimento, id_produto),
    FOREIGN KEY (id_atendimento) REFERENCES atendimentos(id_atendimento)
        ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------------------
-- PARTE 8 - Inserção de dados de teste (dados fictícios)
-- Ordem: tabelas "pai" primeiro, depois as "filhas".
-- ---------------------------------------------------------------------
INSERT INTO clientes (nome, cpf, telefone, email) VALUES
('Mariana Lopes',       '111.111.111-11', '(11) 91111-1111', 'mariana.lopes@email.com'),
('Carlos Eduardo Ramos','222.222.222-22', '(11) 92222-2222', 'carlos.ramos@email.com'),
('Fernanda Alves',      '333.333.333-33', '(11) 93333-3333', 'fernanda.alves@email.com'),
('Paulo Henrique Souza','444.444.444-44', '(11) 94444-4444', 'paulo.souza@email.com'),
('Juliana Martins',     '555.555.555-55', '(11) 95555-5555', NULL);

INSERT INTO funcionarios (nome, cargo, telefone, salario) VALUES
('Camila Torres', 'Médica veterinária', '(11) 96666-6666', 6500.00),
('Rafael Mendes', 'Tosador',            '(11) 97777-7777', 2800.00),
('Aline Prado',   'Banhista',           '(11) 98888-8888', 2200.00),
('Bruno Costa',   'Atendente',          '(11) 99999-9999', 1900.00);

INSERT INTO produtos (nome, quantidade, situacao) VALUES
('Shampoo neutro (galão 5 L)',  20, 'Em estoque'),
('Condicionador hidratante',    15, 'Em estoque'),
('Vacina V10',                  30, 'Em estoque'),
('Ração premium (saco 15 kg)',   8, 'Em estoque'),
('Perfume pet',                  0, 'Esgotado');

INSERT INTO atendimentos
(nome_pet, especie, tipo_servico, data_entrada, data_retirada, valor, status, id_cliente, id_funcionario) VALUES
('Thor',   'Cachorro', 'Banho e tosa',          '2026-10-20', '2026-10-20', 120.00, 'Concluído',    1, 2),
('Mel',    'Gato',     'Consulta e vacinação',  '2026-10-25', '2026-10-25', 280.00, 'Em andamento', 2, 1),
('Bolinha','Cachorro', 'Hospedagem',            '2026-11-01', '2026-11-08', 600.00, 'Em andamento', 3, 4),
('Luna',   'Cachorro', 'Banho',                 '2026-11-10', '2026-11-10',  70.00, DEFAULT,        4, 3),
('Pipoca', 'Coelho',   'Banho',                 '2026-11-12', '2026-11-12',  60.00, 'Cancelado',    5, 3);

INSERT INTO etapas_atendimento (nome_etapa, descricao, status, id_atendimento) VALUES
('Banho',               'Banho com shampoo e condicionador',      'Concluída', 1),
('Tosa',                'Tosa higiênica e de acabamento',          'Concluída', 1),
('Consulta clínica',    'Avaliação geral do animal',               'Concluída', 2),
('Vacinação',           'Aplicação da vacina V10',                 'Pendente',  2),
('Check-in',            'Entrada e orientações do tutor',          'Concluída', 3),
('Estadia',             'Hospedagem com alimentação supervisionada','Pendente', 3),
('Banho',               'Banho com shampoo neutro',                'Pendente',  4),
('Banho',               'Banho agendado e cancelado pelo tutor',   'Cancelada', 5);

INSERT INTO pagamentos (valor_pago, data_pagamento, forma_pagamento, id_atendimento) VALUES
(120.00, '2026-10-20', 'Pix',            1),
(150.00, '2026-10-25', 'Cartão',         2),
(300.00, '2026-11-01', 'Cartão',         3);

INSERT INTO uso_produtos (id_atendimento, id_produto, quantidade_utilizada) VALUES
(1, 1, 1),
(1, 2, 1),
(2, 3, 1),
(3, 4, 1);

-- ---------------------------------------------------------------------
-- PARTE 9 - Consultas simples
-- ---------------------------------------------------------------------
-- 9.1 Todos os clientes em ordem alfabética
SELECT * FROM clientes ORDER BY nome;

-- 9.2 Atendimentos com valor acima de R$ 100,00
SELECT nome_pet, tipo_servico, valor FROM atendimentos WHERE valor > 100;

-- 9.3 Produtos com estoque baixo (menos de 10 unidades)
SELECT nome, quantidade FROM produtos WHERE quantidade < 10;

-- ---------------------------------------------------------------------
-- PARTE 10 - Consultas com JOIN
-- ---------------------------------------------------------------------
-- 10.1 Atendimentos com o nome do cliente e do funcionário responsável
SELECT a.nome_pet, a.tipo_servico, c.nome AS cliente, f.nome AS funcionario
FROM atendimentos a
INNER JOIN clientes c     ON a.id_cliente = c.id_cliente
INNER JOIN funcionarios f ON a.id_funcionario = f.id_funcionario;

-- 10.2 Etapas de cada atendimento
SELECT a.nome_pet, e.nome_etapa, e.status
FROM atendimentos a
INNER JOIN etapas_atendimento e ON e.id_atendimento = a.id_atendimento
ORDER BY a.id_atendimento;

-- ---------------------------------------------------------------------
-- PARTE 11 - Atualização
-- ---------------------------------------------------------------------
UPDATE atendimentos SET status = 'Concluído' WHERE id_atendimento = 2;
UPDATE etapas_atendimento SET status = 'Concluída'
WHERE id_atendimento = 2 AND nome_etapa = 'Vacinação';

-- ---------------------------------------------------------------------
-- PARTE 12 - Exclusão
-- O atendimento 5 não possui pagamentos; suas etapas são excluídas em cascata.
-- ---------------------------------------------------------------------
DELETE FROM atendimentos WHERE id_atendimento = 5;

-- ---------------------------------------------------------------------
-- PARTE 13 - Relatórios (funções de agregação)
-- ---------------------------------------------------------------------
-- 13.1 Total recebido por atendimento
SELECT a.nome_pet, SUM(p.valor_pago) AS total_recebido
FROM atendimentos a
INNER JOIN pagamentos p ON p.id_atendimento = a.id_atendimento
GROUP BY a.id_atendimento, a.nome_pet;

-- 13.2 Valor contratado, recebido e saldo a receber
SELECT a.nome_pet AS atendimento,
       a.valor AS valor_contratado,
       COALESCE(SUM(p.valor_pago), 0) AS recebido,
       a.valor - COALESCE(SUM(p.valor_pago), 0) AS saldo_a_receber
FROM atendimentos a
LEFT JOIN pagamentos p ON p.id_atendimento = a.id_atendimento
GROUP BY a.id_atendimento, a.nome_pet, a.valor;

-- 13.3 Quantidade de atendimentos por funcionário
SELECT f.nome, COUNT(a.id_atendimento) AS total_atendimentos
FROM funcionarios f
LEFT JOIN atendimentos a ON a.id_funcionario = f.id_funcionario
GROUP BY f.id_funcionario, f.nome;

-- 13.4 Produtos utilizados em cada atendimento
SELECT a.nome_pet, pr.nome AS produto, u.quantidade_utilizada
FROM uso_produtos u
INNER JOIN atendimentos a ON a.id_atendimento = u.id_atendimento
INNER JOIN produtos pr    ON pr.id_produto = u.id_produto;
