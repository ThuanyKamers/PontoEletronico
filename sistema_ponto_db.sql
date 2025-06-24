-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 24/06/2025 às 03:32
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `sistema_ponto_db`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_gerar_dados_complexos` (IN `p_id_usuario` INT, IN `p_mes` INT, IN `p_ano` INT)   BEGIN
    DECLARE v_dia INT DEFAULT 1;
    DECLARE v_total_dias INT;
    DECLARE v_data_atual DATE;
    DECLARE v_dia_da_semana INT;

    SET v_total_dias = DAY(LAST_DAY(CONCAT(p_ano, '-', p_mes, '-01')));

    WHILE v_dia <= v_total_dias DO
        SET v_data_atual = CONCAT(p_ano, '-', LPAD(p_mes, 2, '0'), '-', LPAD(v_dia, 2, '0'));
        SET v_dia_da_semana = DAYOFWEEK(v_data_atual);

        IF v_dia_da_semana NOT IN (1, 7) THEN
            
            IF v_dia NOT IN (4, 5) THEN

                IF v_dia >= 9 AND v_dia <= 11 THEN
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'FIM_JORNADA');

                ELSEIF v_dia >= 16 AND v_dia <= 18 THEN
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'INICIO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:30:00'), 'RETORNO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '15:30:00'), 'FIM_JORNADA');

                ELSEIF v_dia = 23 THEN
                     INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '16:00:00'), 'INICIO_JORNADA');
                     INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '23:00:00'), 'FIM_JORNADA');
                ELSE
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'INICIO_INTERVALO');
                    -- CORREÇÃO ESTAVA AQUI: 'panto' virou 'ponto'
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:15:00'), 'RETORNO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '14:15:00'), 'FIM_JORNADA');
                END IF;

            END IF;
        END IF;

        SET v_dia = v_dia + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_gerar_dados_variados` (IN `p_id_usuario` INT, IN `p_mes` INT, IN `p_ano` INT)   BEGIN
    DECLARE v_dia INT DEFAULT 1;
    DECLARE v_total_dias INT;
    DECLARE v_data_atual DATE;
    DECLARE v_dia_da_semana INT;
    SET v_total_dias = DAY(LAST_DAY(CONCAT(p_ano, '-', p_mes, '-01')));

    WHILE v_dia <= v_total_dias DO
        SET v_data_atual = CONCAT(p_ano, '-', LPAD(p_mes, 2, '0'), '-', LPAD(v_dia, 2, '0'));
        SET v_dia_da_semana = DAYOFWEEK(v_data_atual);

        -- Insere pontos apenas em dias de semana
        IF v_dia_da_semana NOT IN (1, 7) THEN
            
            -- Cenário de FALTA nos dias 4 e 5: não faz nada, pulando a inserção.
            IF v_dia NOT IN (4, 5) THEN

                -- Cenário de SAÍDA ANTECIPADA (Saldo Negativo) no dia 9
                IF v_dia = 9 THEN
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'INICIO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:15:00'), 'RETORNO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '13:00:00'), 'FIM_JORNADA'); -- Saiu bem mais cedo

                -- Cenário de HORAS EXTRAS (Saldo Positivo) no dia 10
                ELSEIF v_dia = 10 THEN
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'INICIO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:15:00'), 'RETORNO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '16:00:00'), 'FIM_JORNADA'); -- Saiu bem mais tarde
                
                -- Cenário com MÚLTIPLAS PAUSAS (mais de 4 pontos) no dia 11
                ELSEIF v_dia = 11 THEN
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '10:00:00'), 'INICIO_PAUSA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '10:10:00'), 'RETORNO_PAUSA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'INICIO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:15:00'), 'RETORNO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '14:15:00'), 'FIM_JORNADA');

                -- Cenário de DIA NORMAL (Jornada de 6h com 15 min de intervalo)
                ELSE
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'INICIO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:15:00'), 'RETORNO_INTERVALO');
                    INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '14:15:00'), 'FIM_JORNADA');
                END IF;
            END IF;
        END IF;
        SET v_dia = v_dia + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `p_popular_registros_ponto` (IN `p_id_usuario` INT, IN `p_mes` INT, IN `p_ano` INT)   BEGIN
    DECLARE v_dia INT DEFAULT 1;
    DECLARE v_total_dias INT;
    DECLARE v_data_atual DATE;
    DECLARE v_dia_da_semana INT;

    SET v_total_dias = DAY(LAST_DAY(CONCAT(p_ano, '-', p_mes, '-01')));

    WHILE v_dia <= v_total_dias DO
        SET v_data_atual = CONCAT(p_ano, '-', LPAD(p_mes, 2, '0'), '-', LPAD(v_dia, 2, '0'));
        SET v_dia_da_semana = DAYOFWEEK(v_data_atual);

        IF v_dia_da_semana NOT IN (1, 7) THEN
            INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '08:00:00'), 'INICIO_JORNADA');
            INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '12:00:00'), 'INICIO_INTERVALO');
            INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto) VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '13:00:00'), 'RETORNO_INTERVALO');

            -- ==============================================================
            --  LÓGICA CORRIGIDA: Usa o dia do mês (v_dia) para a condição
            -- ==============================================================
            IF v_dia <= 15 THEN
                -- Para os dias 1 a 15, sai mais cedo para gerar SALDO NEGATIVO
                INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto)
                VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '16:30:00'), 'FIM_JORNADA');
            ELSE
                -- Para os dias depois do dia 15, sai mais tarde para gerar SALDO POSITIVO
                INSERT INTO registros_ponto (id_usuario, data_hora_ponto, tipo_ponto)
                VALUES (p_id_usuario, TIMESTAMP(v_data_atual, '18:30:00'), 'FIM_JORNADA');
            END IF;
            
        END IF;

        SET v_dia = v_dia + 1;
    END WHILE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `feriados`
--

CREATE TABLE `feriados` (
  `id_feriado` int(11) NOT NULL,
  `data_feriado` date NOT NULL,
  `descricao` varchar(255) NOT NULL,
  `tipo` enum('Nacional','Estadual','Municipal','Ponto Facultativo') NOT NULL,
  `uf` char(2) DEFAULT NULL,
  `cidade` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `feriados`
--

INSERT INTO `feriados` (`id_feriado`, `data_feriado`, `descricao`, `tipo`, `uf`, `cidade`) VALUES
(55, '2025-03-04', 'Carnaval', 'Ponto Facultativo', NULL, NULL),
(56, '2025-04-18', 'Sexta-feira Santa (Paixão de Cristo)', 'Nacional', NULL, NULL),
(58, '2025-01-01', 'Confraternização Universal (Ano Novo)', 'Nacional', NULL, NULL),
(59, '2025-04-21', 'Tiradentes', 'Nacional', NULL, NULL),
(60, '2025-05-01', 'Dia do Trabalho', 'Nacional', NULL, NULL),
(61, '2025-09-07', 'Independência do Brasil', 'Nacional', NULL, NULL),
(62, '2025-10-12', 'Nossa Senhora Aparecida', 'Nacional', NULL, NULL),
(63, '2025-11-02', 'Finados', 'Nacional', NULL, NULL),
(64, '2025-11-15', 'Proclamação da República', 'Nacional', NULL, NULL),
(65, '2025-12-25', 'Natal', 'Nacional', NULL, NULL),
(67, '2025-06-19', 'Corpus Christi', 'Nacional', NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `jornada_modelos`
--

CREATE TABLE `jornada_modelos` (
  `id_modelo` int(11) NOT NULL,
  `nome_modelo` varchar(255) NOT NULL,
  `tipo_jornada` varchar(100) DEFAULT NULL,
  `limite_tolerancia_minutos` int(11) NOT NULL DEFAULT 10,
  `duracao_intervalo_minutos` int(11) NOT NULL DEFAULT 60
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `jornada_modelos`
--

INSERT INTO `jornada_modelos` (`id_modelo`, `nome_modelo`, `tipo_jornada`, `limite_tolerancia_minutos`, `duracao_intervalo_minutos`) VALUES
(1, 'Estágio tarde', '30h semanais', 10, 60),
(5, 'estágio das 13h às 19h', '30h semanais', 10, 15),
(6, 'jornada de 8h', '40h semanais', 10, 60);

-- --------------------------------------------------------

--
-- Estrutura para tabela `jornada_modelo_dias`
--

CREATE TABLE `jornada_modelo_dias` (
  `id` int(11) NOT NULL,
  `id_modelo` int(11) NOT NULL,
  `dia_semana` enum('segunda','terca','quarta','quinta','sexta','sabado','domingo') NOT NULL,
  `inicio_jornada` time DEFAULT NULL,
  `inicio_intervalo` time DEFAULT NULL,
  `fim_intervalo` time DEFAULT NULL,
  `fim_jornada` time DEFAULT NULL,
  `folga` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `jornada_modelo_dias`
--

INSERT INTO `jornada_modelo_dias` (`id`, `id_modelo`, `dia_semana`, `inicio_jornada`, `inicio_intervalo`, `fim_intervalo`, `fim_jornada`, `folga`) VALUES
(1, 1, 'segunda', NULL, NULL, NULL, NULL, 1),
(2, 1, 'terca', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(3, 1, 'quarta', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(4, 1, 'quinta', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(5, 1, 'sexta', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(6, 1, 'sabado', NULL, NULL, NULL, NULL, 1),
(7, 1, 'domingo', NULL, NULL, NULL, NULL, 1),
(29, 5, 'segunda', '13:00:00', '16:00:00', '16:15:00', '19:00:00', 0),
(30, 5, 'terca', '13:00:00', '16:00:00', '16:15:00', '19:00:00', 0),
(31, 5, 'quarta', '13:00:00', '16:00:00', '16:15:00', '19:00:00', 0),
(32, 5, 'quinta', '13:00:00', '16:00:00', '16:15:00', '19:00:00', 0),
(33, 5, 'sexta', '13:00:00', '16:00:00', '16:15:00', '19:00:00', 0),
(34, 5, 'sabado', NULL, NULL, NULL, NULL, 1),
(35, 5, 'domingo', NULL, NULL, NULL, NULL, 1),
(36, 6, 'segunda', '09:00:00', '13:00:00', '14:00:00', '18:00:00', 0),
(37, 6, 'terca', '09:00:00', '13:00:00', '14:00:00', '18:00:00', 0),
(38, 6, 'quarta', '09:00:00', '13:00:00', '14:00:00', '18:00:00', 0),
(39, 6, 'quinta', '09:00:00', '13:00:00', '14:00:00', '18:00:00', 0),
(40, 6, 'sexta', '09:00:00', '13:00:00', '14:00:00', '18:00:00', 0),
(41, 6, 'sabado', NULL, NULL, NULL, NULL, 1),
(42, 6, 'domingo', NULL, NULL, NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Estrutura para tabela `ocorrencias`
--

CREATE TABLE `ocorrencias` (
  `id_ocorrencia` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `tipo` enum('ATESTADO','FERIAS','LICENCA_MATERNIDADE','LICENCA_PATERNIDADE','LICENCA_CASAMENTO','LICENCA_OBITO','DOACAO_SANGUE','ALISTAMENTO_ELEITORAL','SERVICO_MILITAR','ACOMPANHAMENTO_MEDICO','ACOMPANHAMENTO_CONJUGE','ACIDENTE_TRABALHO','FALTA_INJUSTIFICADA','SUSPENSAO_ADVERTENCIA','ABONO','OUTRO') NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `descricao` text DEFAULT NULL COMMENT 'Observações adicionais, se necessário',
  `anexo_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `ocorrencias`
--

INSERT INTO `ocorrencias` (`id_ocorrencia`, `id_usuario`, `tipo`, `data_inicio`, `data_fim`, `descricao`, `anexo_path`) VALUES
(85, 6, 'FERIAS', '2025-07-01', '2025-07-15', 'Férias.', NULL),
(86, 6, 'LICENCA_OBITO', '2025-07-05', '2025-07-07', 'Atestado.', 'uploads/685193cb8c351-'),
(89, 6, 'ATESTADO', '2025-06-12', '2025-06-13', 'Atestado médico de 2 dias', NULL),
(90, 6, 'ATESTADO', '2025-07-08', '2025-07-15', 'Atestado', 'uploads/6853201a9623c-'),
(93, 1, 'ATESTADO', '2025-07-01', '2025-07-02', 'Atestado.', 'uploads/68532e09914f7-'),
(94, 6, 'ATESTADO', '2025-07-15', '2025-07-30', 'atestado.', 'uploads/6855bb9a07800-'),
(95, 6, 'ATESTADO', '2025-06-11', '2025-06-13', 'atestadoo', NULL),
(96, 6, 'FERIAS', '2025-08-01', '2025-08-15', 'férias', NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `registros_ponto`
--

CREATE TABLE `registros_ponto` (
  `id_registro` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `tipo_ponto` enum('INICIO_JORNADA','INICIO_INTERVALO','RETORNO_INTERVALO','INICIO_PAUSA','RETORNO_PAUSA','FIM_JORNADA') NOT NULL,
  `data_hora_ponto` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `registros_ponto`
--

INSERT INTO `registros_ponto` (`id_registro`, `id_usuario`, `tipo_ponto`, `data_hora_ponto`) VALUES
(445, 6, 'INICIO_JORNADA', '2025-06-02 08:00:00'),
(446, 6, 'INICIO_INTERVALO', '2025-06-02 12:00:00'),
(447, 6, 'RETORNO_INTERVALO', '2025-06-02 12:15:00'),
(448, 6, 'FIM_JORNADA', '2025-06-02 14:15:00'),
(449, 6, 'INICIO_JORNADA', '2025-06-03 08:00:00'),
(450, 6, 'INICIO_INTERVALO', '2025-06-03 12:00:00'),
(451, 6, 'RETORNO_INTERVALO', '2025-06-03 12:15:00'),
(452, 6, 'FIM_JORNADA', '2025-06-03 14:15:00'),
(453, 6, 'INICIO_JORNADA', '2025-06-06 08:00:00'),
(454, 6, 'INICIO_INTERVALO', '2025-06-06 12:00:00'),
(455, 6, 'RETORNO_INTERVALO', '2025-06-06 12:15:00'),
(456, 6, 'FIM_JORNADA', '2025-06-06 14:15:00'),
(457, 6, 'INICIO_JORNADA', '2025-06-09 08:00:00'),
(458, 6, 'INICIO_INTERVALO', '2025-06-09 12:00:00'),
(459, 6, 'RETORNO_INTERVALO', '2025-06-09 12:15:00'),
(460, 6, 'FIM_JORNADA', '2025-06-09 13:00:00'),
(461, 6, 'INICIO_JORNADA', '2025-06-10 08:00:00'),
(462, 6, 'INICIO_INTERVALO', '2025-06-10 12:00:00'),
(463, 6, 'RETORNO_INTERVALO', '2025-06-10 12:15:00'),
(464, 6, 'FIM_JORNADA', '2025-06-10 16:00:00'),
(465, 6, 'INICIO_JORNADA', '2025-06-11 08:00:00'),
(466, 6, 'INICIO_PAUSA', '2025-06-11 10:00:00'),
(467, 6, 'RETORNO_PAUSA', '2025-06-11 10:10:00'),
(468, 6, 'INICIO_INTERVALO', '2025-06-11 12:00:00'),
(469, 6, 'RETORNO_INTERVALO', '2025-06-11 12:15:00'),
(470, 6, 'FIM_JORNADA', '2025-06-11 14:15:00'),
(479, 6, 'INICIO_JORNADA', '2025-06-16 08:00:00'),
(480, 6, 'INICIO_INTERVALO', '2025-06-16 12:00:00'),
(481, 6, 'RETORNO_INTERVALO', '2025-06-16 12:15:00'),
(482, 6, 'FIM_JORNADA', '2025-06-16 14:15:00'),
(483, 6, 'INICIO_JORNADA', '2025-06-17 08:00:00'),
(484, 6, 'INICIO_INTERVALO', '2025-06-17 12:00:00'),
(485, 6, 'RETORNO_INTERVALO', '2025-06-17 12:15:00'),
(486, 6, 'FIM_JORNADA', '2025-06-17 14:15:00'),
(487, 6, 'INICIO_JORNADA', '2025-06-18 08:00:00'),
(488, 6, 'INICIO_INTERVALO', '2025-06-18 12:00:00'),
(489, 6, 'RETORNO_INTERVALO', '2025-06-18 12:15:00'),
(490, 6, 'FIM_JORNADA', '2025-06-18 14:15:00'),
(491, 6, 'INICIO_JORNADA', '2025-06-19 08:00:00'),
(492, 6, 'INICIO_INTERVALO', '2025-06-19 12:00:00'),
(493, 6, 'RETORNO_INTERVALO', '2025-06-19 12:15:00'),
(494, 6, 'FIM_JORNADA', '2025-06-19 14:15:00'),
(495, 6, 'INICIO_JORNADA', '2025-06-20 08:00:00'),
(496, 6, 'INICIO_INTERVALO', '2025-06-20 12:00:00'),
(497, 6, 'RETORNO_INTERVALO', '2025-06-20 12:15:00'),
(498, 6, 'FIM_JORNADA', '2025-06-20 14:15:00'),
(499, 6, 'INICIO_JORNADA', '2025-06-23 08:00:00'),
(500, 6, 'INICIO_INTERVALO', '2025-06-23 12:00:00'),
(501, 6, 'RETORNO_INTERVALO', '2025-06-23 12:15:00'),
(502, 6, 'FIM_JORNADA', '2025-06-23 14:15:00'),
(503, 6, 'INICIO_JORNADA', '2025-06-24 08:00:00'),
(504, 6, 'INICIO_INTERVALO', '2025-06-24 12:00:00'),
(505, 6, 'RETORNO_INTERVALO', '2025-06-24 12:15:00'),
(506, 6, 'FIM_JORNADA', '2025-06-24 14:15:00'),
(507, 6, 'INICIO_JORNADA', '2025-06-25 08:00:00'),
(508, 6, 'INICIO_INTERVALO', '2025-06-25 12:00:00'),
(509, 6, 'RETORNO_INTERVALO', '2025-06-25 12:15:00'),
(510, 6, 'FIM_JORNADA', '2025-06-25 14:15:00'),
(511, 6, 'INICIO_JORNADA', '2025-06-26 08:00:00'),
(512, 6, 'INICIO_INTERVALO', '2025-06-26 12:00:00'),
(513, 6, 'RETORNO_INTERVALO', '2025-06-26 12:15:00'),
(514, 6, 'FIM_JORNADA', '2025-06-26 14:15:00'),
(515, 6, 'INICIO_JORNADA', '2025-06-27 08:00:00'),
(516, 6, 'INICIO_INTERVALO', '2025-06-27 12:00:00'),
(517, 6, 'RETORNO_INTERVALO', '2025-06-27 12:15:00'),
(518, 6, 'FIM_JORNADA', '2025-06-27 14:15:00'),
(519, 6, 'INICIO_JORNADA', '2025-06-30 08:00:00'),
(520, 6, 'INICIO_INTERVALO', '2025-06-30 12:00:00'),
(521, 6, 'RETORNO_INTERVALO', '2025-06-30 12:15:00'),
(522, 6, 'FIM_JORNADA', '2025-06-30 14:15:00'),
(533, 1, 'INICIO_JORNADA', '2025-06-02 08:00:00'),
(534, 1, 'INICIO_INTERVALO', '2025-06-02 12:00:00'),
(535, 1, 'RETORNO_INTERVALO', '2025-06-02 13:00:00'),
(536, 1, 'FIM_JORNADA', '2025-06-02 17:00:00'),
(537, 1, 'INICIO_JORNADA', '2025-06-03 08:00:00'),
(538, 1, 'INICIO_PAUSA', '2025-06-03 10:00:00'),
(539, 1, 'RETORNO_PAUSA', '2025-06-03 10:15:00'),
(540, 1, 'INICIO_INTERVALO', '2025-06-03 12:00:00'),
(541, 1, 'RETORNO_INTERVALO', '2025-06-03 13:00:00'),
(542, 1, 'FIM_JORNADA', '2025-06-03 17:15:00'),
(543, 1, 'INICIO_JORNADA', '2025-06-04 08:00:00'),
(544, 1, 'INICIO_PAUSA', '2025-06-04 10:00:00'),
(545, 1, 'RETORNO_PAUSA', '2025-06-04 10:10:00'),
(546, 1, 'INICIO_INTERVALO', '2025-06-04 12:00:00'),
(547, 1, 'RETORNO_INTERVALO', '2025-06-04 13:00:00'),
(548, 1, 'INICIO_PAUSA', '2025-06-04 15:00:00'),
(549, 1, 'RETORNO_PAUSA', '2025-06-04 15:05:00'),
(550, 1, 'FIM_JORNADA', '2025-06-04 17:15:00');

-- --------------------------------------------------------

--
-- Estrutura para tabela `solicitacoes_alteracao`
--

CREATE TABLE `solicitacoes_alteracao` (
  `id_solicitacao` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `data_ocorrencia` date NOT NULL,
  `tipo_solicitacao` varchar(50) NOT NULL COMMENT 'Ex: ATESTADO_MEDICO, ESQUECIMENTO_PONTO, PONTO_INCORRETO, OUTRO',
  `descricao` text NOT NULL,
  `caminho_anexo` varchar(255) DEFAULT NULL,
  `data_solicitacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `status_solicitacao` varchar(20) NOT NULL DEFAULT 'PENDENTE' COMMENT 'Ex: PENDENTE, APROVADA, REJEITADA',
  `justificativa_admin` text DEFAULT NULL COMMENT 'Justificativa do administrador em caso de rejeição ou observação na aprovação',
  `caminho_anexo_admin` varchar(255) DEFAULT NULL COMMENT 'Anexo do admin ao processar solicitação',
  `novo_horario_sugerido` time DEFAULT NULL COMMENT 'Horário que deveria ter sido batido (para esquecimento ou correção)',
  `novo_tipo_ponto_sugerido` varchar(25) DEFAULT NULL COMMENT 'Tipo do ponto que deveria ter sido batido (INICIO_JORNADA, etc.)',
  `id_registro_original` int(11) DEFAULT NULL COMMENT 'ID do registro_ponto original que está sendo corrigido (para tipo PONTO_INCORRETO)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `solicitacoes_alteracao`
--

INSERT INTO `solicitacoes_alteracao` (`id_solicitacao`, `id_usuario`, `data_ocorrencia`, `tipo_solicitacao`, `descricao`, `caminho_anexo`, `data_solicitacao`, `status_solicitacao`, `justificativa_admin`, `caminho_anexo_admin`, `novo_horario_sugerido`, `novo_tipo_ponto_sugerido`, `id_registro_original`) VALUES
(1, 1, '2025-06-03', 'ATESTADO_MEDICO', 'Compareci ao médico', 'uploads/comprovantes/anexo_6840b05a39c709.44069982.jpg', '2025-06-04 20:45:14', 'REJEITADA', 'Não tem nada no documento.', 'uploads/admin_anexos/admin_recusa_6840bb6a4c8b64.92210718.jpg', NULL, NULL, NULL),
(2, 1, '2025-06-04', 'ESQUECIMENTO_PONTO', 'Esqueci de bater uns pontos hoje', NULL, '2025-06-04 21:30:41', 'APROVADA', NULL, NULL, NULL, NULL, NULL),
(3, 1, '2025-06-05', 'ESQUECIMENTO_PONTO', 'Esqueci de bater o ponto de início de jornada.', NULL, '2025-06-05 15:52:17', 'REJEITADA', 'Duplicidade', NULL, '12:35:00', 'INICIO_JORNADA', NULL),
(4, 1, '2025-06-05', 'ESQUECIMENTO_PONTO', 'Esqueci de bater o ponto hihihi', NULL, '2025-06-05 16:16:59', 'APROVADA', 'certo', NULL, '12:35:00', 'INICIO_JORNADA', NULL),
(5, 1, '2025-06-05', 'ESQUECIMENTO_PONTO', 'esquecii', NULL, '2025-06-05 16:58:44', 'APROVADA', 'teste', NULL, '13:00:00', 'INICIO_INTERVALO', NULL),
(6, 1, '2025-06-05', 'PONTO_INCORRETO', 'era pra registrar inicio de jornada 12h35, intervalo 13h, volta 13h05 e fim da jornada 14h.', NULL, '2025-06-05 17:07:00', 'REJEITADA', 'Não há registros.', NULL, NULL, NULL, NULL),
(7, 1, '2025-06-05', 'ESQUECIMENTO_PONTO', 'esqueci', NULL, '2025-06-05 17:07:16', 'APROVADA', 'ok', NULL, '12:35:00', 'INICIO_JORNADA', NULL),
(8, 1, '2025-06-02', 'ATESTADO_MEDICO', 'Atesto o dia 2', NULL, '2025-06-05 18:06:46', 'REJEITADA', 'Duplicidade.', NULL, NULL, NULL, NULL),
(9, 1, '2025-06-03', 'ESQUECIMENTO_PONTO', 'Esqueci de bater o ponto.', NULL, '2025-06-05 18:07:20', 'APROVADA', 'Ajustado.', NULL, '17:05:00', 'FIM_JORNADA', NULL),
(10, 1, '2025-06-04', 'PONTO_INCORRETO', 'Bati o ponto depois, mas voltei antes. Era pra ser 12:20h a volta do intervalo.', NULL, '2025-06-05 18:08:28', 'APROVADA', 'Ajustado.', NULL, NULL, NULL, NULL),
(11, 1, '2025-06-02', 'ATESTADO_MEDICO', 'não compareci', NULL, '2025-06-05 18:21:17', 'REJEITADA', 'duplicidade', NULL, NULL, NULL, NULL),
(12, 1, '2025-06-02', 'ATESTADO_MEDICO', 'num fui esse dia aí', 'uploads/comprovantes/anexo_6841e32161c936.13605769.jpg', '2025-06-05 18:34:09', 'APROVADA', 'Aceito.', 'uploads/admin_anexos/admin_aprov_6841ebef0a9711.53448572.pdf', NULL, NULL, NULL),
(13, 6, '2025-06-05', 'PONTO_INCORRETO', 'troca aí fzd o favor', NULL, '2025-06-05 20:04:05', 'APROVADA', 'pronto', NULL, '00:00:00', '', NULL),
(14, 6, '2025-06-05', 'PONTO_INCORRETO', 'troca aí pra mim', NULL, '2025-06-05 20:20:07', 'REJEITADA', '', NULL, '00:00:00', '', NULL),
(15, 1, '2025-06-06', 'PONTO_INCORRETO', 'ajusta o ponto', NULL, '2025-06-06 15:55:01', 'REJEITADA', '', NULL, '00:00:00', '', NULL),
(16, 7, '2025-06-06', 'PONTO_INCORRETO', 'Ajusta aí se faz favore', NULL, '2025-06-06 16:35:17', 'REJEITADA', 'nao', NULL, '00:00:00', '', NULL),
(17, 7, '2025-06-06', 'PONTO_INCORRETO', 'Ajusta aí se faz favore', NULL, '2025-06-06 16:35:31', 'REJEITADA', 'NÃO QUERO', NULL, '00:00:00', '', NULL),
(18, 1, '2025-06-06', 'PONTO_INCORRETO', 'arruma pra mim', NULL, '2025-06-06 17:21:23', 'REJEITADA', 'EU RECUSOOOOOOOOOO', NULL, '00:00:00', '', NULL),
(19, 6, '2025-06-06', 'PONTO_INCORRETO', 'arruma pfv', NULL, '2025-06-06 17:35:27', 'APROVADA', 'funciona em nome de JESUS', NULL, '14:36:00', 'FIM_JORNADA', NULL),
(20, 1, '2025-06-06', 'PONTO_INCORRETO', 'vamos verrrrrrrrrrr', NULL, '2025-06-06 21:33:34', 'APROVADA', 'Ajustado.', NULL, '18:35:00', 'FIM_JORNADA', NULL),
(21, 1, '2025-06-09', 'PONTO_INCORRETO', 'Registrei errado', NULL, '2025-06-09 15:44:08', 'APROVADA', 'Ajustado.', NULL, '12:45:00', 'FIM_JORNADA', NULL),
(22, 1, '2025-06-09', 'PONTO_INCORRETO', 'coloquei errado', NULL, '2025-06-09 20:39:18', 'APROVADA', 'ajustado.', NULL, '18:00:00', 'FIM_JORNADA', NULL),
(23, 1, '2025-06-10', 'PONTO_INCORRETO', 'ajuste aí', NULL, '2025-06-10 14:41:38', 'PENDENTE', NULL, NULL, '11:50:00', 'FIM_JORNADA', NULL),
(24, 1, '2025-06-08', 'ATESTADO_MEDICO', 'atestado', 'uploads/comprovantes/anexo_6848443312dfb7.35198948.jpg', '2025-06-10 14:41:55', 'APROVADA', 'ajustado', NULL, NULL, NULL, NULL),
(25, 1, '2025-06-13', 'PONTO_INCORRETO', 'ajusta', 'uploads/comprovantes/anexo_684c91ea9dd910.67915046.jpg', '2025-06-13 21:02:34', 'APROVADA', 'ajustado', 'uploads/admin_anexos/admin_aprovar_684c926f4f1870.63281893.jpg', '18:05:00', 'FIM_JORNADA', NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nome_completo` varchar(150) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `data_admissao` date DEFAULT NULL,
  `cargo` varchar(100) DEFAULT NULL,
  `data_nascimento` date NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `perfil` varchar(20) NOT NULL COMMENT 'Ex: admin, empregado',
  `status` enum('ativo','inativo','demitido') NOT NULL DEFAULT 'ativo',
  `id_modelo_jornada` int(11) DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `cpf` varchar(14) DEFAULT NULL COMMENT 'Formato XXX.XXX.XXX-XX',
  `endereco_rua` varchar(255) DEFAULT NULL,
  `endereco_numero` varchar(20) DEFAULT NULL,
  `endereco_complemento` varchar(100) DEFAULT NULL,
  `endereco_bairro` varchar(100) DEFAULT NULL,
  `endereco_cidade` varchar(100) DEFAULT NULL,
  `endereco_estado` varchar(2) DEFAULT NULL COMMENT 'Sigla do estado, ex: SC',
  `endereco_cep` varchar(9) DEFAULT NULL COMMENT 'Formato XXXXX-XXX'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nome_completo`, `email`, `telefone`, `data_admissao`, `cargo`, `data_nascimento`, `senha_hash`, `perfil`, `status`, `id_modelo_jornada`, `data_criacao`, `cpf`, `endereco_rua`, `endereco_numero`, `endereco_complemento`, `endereco_bairro`, `endereco_cidade`, `endereco_estado`, `endereco_cep`) VALUES
(1, 'Thuany Paula Kamers', 'thuany@sistemapet.com', '48998405097', '2025-05-28', 'Estagiária de Desenvolvimento', '0000-00-00', '$2y$10$p4qn.5Mb5C0OSUmW43z4muQqycSC0n.K1PNhV9j262eywZNXZ7ksq', 'empregado', 'ativo', 5, '2025-06-04 18:38:22', '100.136.699-90', 'Rua 22', '25', 'Casa', 'ponte do imaruim', 'palhoça', 'SC', '88130500'),
(2, 'Administrador', 'admin@sistemapet.com', NULL, NULL, NULL, '0000-00-00', '$2y$10$5kd9J1D5RFlPltBqF8eGneuwOxHZ8kQ5EvyvsJomVKmuZUa8W0Yty', 'admin', 'ativo', NULL, '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, 'Lucas Freitas Sagás', 'lucas@gmail.com', '489555555555', '2025-06-01', 'Engenheiro eletricista', '2000-01-28', '$2y$10$3RN/siHm0V9tdPdsU6JYT.zm1mCLFeZ1qotemw5jnJBkFE5Wg5H5e', 'empregado', 'ativo', 5, '2025-06-05 19:41:14', '12345678909', 'Rua 1', '25', 'casa', 'caminho novo', 'palhoça', 'SC', '88130000'),
(7, 'João da Silva', 'joao@gmail.com', '479898988888', '2023-01-01', 'RH', '2001-01-01', '$2y$10$yaGKNA5VLZ2f/Kmh7eCdsuRDEwzccnQcVNg6hEQTPufIRSE/F3E7e', 'empregado', 'ativo', 6, '2025-06-06 16:06:31', '12332112332', 'Rua 22', '100', 'Casa', 'Pacheco', 'Palhoça', 'SC', '88000111'),
(8, 'Novo Administrador', 'adm@sistemapet.com', '48999999999', '2025-06-13', NULL, '2001-01-01', '$2y$10$6Dp58Qn.dz7YlPtMhxHHs.Adhfg6gMK1ToLz4Qm2Ppjol1JD3PcsC', 'empregado', 'ativo', 1, '2025-06-13 17:50:21', '01111122223', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `feriados`
--
ALTER TABLE `feriados`
  ADD PRIMARY KEY (`id_feriado`),
  ADD UNIQUE KEY `data_feriado` (`data_feriado`,`uf`,`cidade`);

--
-- Índices de tabela `jornada_modelos`
--
ALTER TABLE `jornada_modelos`
  ADD PRIMARY KEY (`id_modelo`);

--
-- Índices de tabela `jornada_modelo_dias`
--
ALTER TABLE `jornada_modelo_dias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_modelo` (`id_modelo`);

--
-- Índices de tabela `ocorrencias`
--
ALTER TABLE `ocorrencias`
  ADD PRIMARY KEY (`id_ocorrencia`),
  ADD KEY `fk_ocorrencias_usuario_idx` (`id_usuario`);

--
-- Índices de tabela `registros_ponto`
--
ALTER TABLE `registros_ponto`
  ADD PRIMARY KEY (`id_registro`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Índices de tabela `solicitacoes_alteracao`
--
ALTER TABLE `solicitacoes_alteracao`
  ADD PRIMARY KEY (`id_solicitacao`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Índices de tabela `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `email_2` (`email`),
  ADD UNIQUE KEY `cpf` (`cpf`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `feriados`
--
ALTER TABLE `feriados`
  MODIFY `id_feriado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=68;

--
-- AUTO_INCREMENT de tabela `jornada_modelos`
--
ALTER TABLE `jornada_modelos`
  MODIFY `id_modelo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `jornada_modelo_dias`
--
ALTER TABLE `jornada_modelo_dias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT de tabela `ocorrencias`
--
ALTER TABLE `ocorrencias`
  MODIFY `id_ocorrencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT de tabela `registros_ponto`
--
ALTER TABLE `registros_ponto`
  MODIFY `id_registro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=551;

--
-- AUTO_INCREMENT de tabela `solicitacoes_alteracao`
--
ALTER TABLE `solicitacoes_alteracao`
  MODIFY `id_solicitacao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de tabela `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `jornada_modelo_dias`
--
ALTER TABLE `jornada_modelo_dias`
  ADD CONSTRAINT `jornada_modelo_dias_ibfk_1` FOREIGN KEY (`id_modelo`) REFERENCES `jornada_modelos` (`id_modelo`) ON DELETE CASCADE;

--
-- Restrições para tabelas `ocorrencias`
--
ALTER TABLE `ocorrencias`
  ADD CONSTRAINT `fk_ocorrencias_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE NO ACTION;

--
-- Restrições para tabelas `registros_ponto`
--
ALTER TABLE `registros_ponto`
  ADD CONSTRAINT `registros_ponto_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Restrições para tabelas `solicitacoes_alteracao`
--
ALTER TABLE `solicitacoes_alteracao`
  ADD CONSTRAINT `solicitacoes_alteracao_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
