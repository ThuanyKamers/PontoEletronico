-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 27/06/2025 às 23:06
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

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
-- Estrutura para tabela `ajustes_banco_horas`
--

CREATE TABLE `ajustes_banco_horas` (
  `id_ajuste` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `data_ajustada` date NOT NULL,
  `horas_abonadas` int(11) DEFAULT 0,
  `descricao` varchar(255) DEFAULT NULL,
  `criado_em` datetime DEFAULT current_timestamp(),
  `atualizado_em` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `ajustes_banco_horas`
--

INSERT INTO `ajustes_banco_horas` (`id_ajuste`, `id_usuario`, `data_ajustada`, `horas_abonadas`, `descricao`, `criado_em`, `atualizado_em`) VALUES
(1, 6, '2025-06-01', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(2, 6, '2025-06-02', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:31'),
(3, 6, '2025-06-03', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(4, 6, '2025-06-04', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(5, 6, '2025-06-05', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(6, 6, '2025-06-06', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(7, 6, '2025-06-07', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(8, 6, '2025-06-08', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(9, 6, '2025-06-09', 120, 'gfgfrgttfhdfhdghfghfghfghfghfghfghfgjfgjfgmmmmmmmmmm3', '2025-06-27 17:36:19', '2025-06-27 17:47:10'),
(10, 6, '2025-06-10', 120, 'pq eu quis', '2025-06-27 17:36:19', '2025-06-27 17:41:48'),
(11, 6, '2025-06-11', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(12, 6, '2025-06-12', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(13, 6, '2025-06-13', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(14, 6, '2025-06-14', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(15, 6, '2025-06-15', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(16, 6, '2025-06-16', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(17, 6, '2025-06-17', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(18, 6, '2025-06-18', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(19, 6, '2025-06-19', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(20, 6, '2025-06-20', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(21, 6, '2025-06-21', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(22, 6, '2025-06-22', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(23, 6, '2025-06-23', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(24, 6, '2025-06-24', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(25, 6, '2025-06-25', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(26, 6, '2025-06-26', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(27, 6, '2025-06-27', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(28, 6, '2025-06-28', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(29, 6, '2025-06-29', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19'),
(30, 6, '2025-06-30', 0, '', '2025-06-27 17:36:19', '2025-06-27 17:36:19');

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
(80, '2025-03-04', 'Carnaval', 'Ponto Facultativo', NULL, NULL),
(81, '2025-04-18', 'Sexta-feira Santa (Paixão de Cristo)', 'Nacional', NULL, NULL),
(82, '2025-06-19', 'Corpus Christi', 'Ponto Facultativo', NULL, NULL),
(83, '2025-01-01', 'Confraternização Universal (Ano Novo)', 'Nacional', NULL, NULL),
(84, '2025-04-21', 'Tiradentes', 'Nacional', NULL, NULL),
(85, '2025-05-01', 'Dia do Trabalho', 'Nacional', NULL, NULL),
(86, '2025-09-07', 'Independência do Brasil', 'Nacional', NULL, NULL),
(87, '2025-10-12', 'Nossa Senhora Aparecida', 'Nacional', NULL, NULL),
(88, '2025-11-02', 'Finados', 'Nacional', NULL, NULL),
(89, '2025-11-15', 'Proclamação da República', 'Nacional', NULL, NULL),
(90, '2025-12-25', 'Natal', 'Nacional', NULL, NULL);

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
(6, 'jornada de 8h', '40h semanais', 10, 60),
(7, 'Estágio de manhã', '30h semanais', 10, 15),
(8, 'das 8 as 18', '40h semanais', 10, 60);

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
(42, 6, 'domingo', NULL, NULL, NULL, NULL, 1),
(43, 7, 'segunda', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(44, 7, 'terca', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(45, 7, 'quarta', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(46, 7, 'quinta', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(47, 7, 'sexta', '08:00:00', '12:00:00', '12:15:00', '14:00:00', 0),
(48, 7, 'sabado', NULL, NULL, NULL, NULL, 1),
(49, 7, 'domingo', NULL, NULL, NULL, NULL, 1),
(50, 8, 'segunda', '07:00:00', '12:00:00', '13:00:00', '16:00:00', 0),
(51, 8, 'terca', '07:00:00', '12:00:00', '13:00:00', '16:00:00', 0),
(52, 8, 'quarta', '07:00:00', '12:00:00', '13:00:00', '16:00:00', 0),
(53, 8, 'quinta', '07:00:00', '12:00:00', '13:00:00', '16:00:00', 0),
(54, 8, 'sexta', '07:00:00', '12:00:00', '13:00:00', '16:00:00', 0),
(55, 8, 'sabado', NULL, NULL, NULL, NULL, 1),
(56, 8, 'domingo', NULL, NULL, NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Estrutura para tabela `ocorrencias`
--

CREATE TABLE `ocorrencias` (
  `id_ocorrencia` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_solicitacao` int(11) DEFAULT NULL,
  `tipo` enum('ATESTADO','ATESTADO_MEDICO','FERIAS','LICENCA_OBITO','DOACAO_SANGUE','ACOMPANHAMENTO_CONJUGE','ALISTAMENTO_ELEITORAL','LICENCA_MATERNIDADE','LICENCA_PATERNIDADE','LICENCA_CASAMENTO','COMPARECIMENTO_JUIZO','SUSPENSAO','AUXILIO_DOENCA','ABONO','OUTRO') NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `descricao` text DEFAULT NULL COMMENT 'Observações adicionais, se necessário',
  `anexo_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `ocorrencias`
--

INSERT INTO `ocorrencias` (`id_ocorrencia`, `id_usuario`, `id_solicitacao`, `tipo`, `data_inicio`, `data_fim`, `descricao`, `anexo_path`) VALUES
(93, 1, NULL, 'ATESTADO', '2025-07-01', '2025-07-02', 'Atestado.', 'uploads/68532e09914f7-'),
(103, 1, NULL, 'ATESTADO', '2025-06-26', '2025-07-07', 'solicito atestado', 'uploads/comprovantes/anexo_685d9b59c7c4c8.02726732.jpg'),
(104, 1, NULL, 'FERIAS', '2025-08-01', '2025-08-05', 'solicito férias', NULL),
(105, 1, NULL, 'FERIAS', '2025-09-01', '2025-09-05', 'solicito férias', NULL),
(106, 1, NULL, 'ALISTAMENTO_ELEITORAL', '2025-10-10', '2025-10-10', 'alistamento eleitoral', 'uploads/comprovantes/anexo_685ecda3767d36.06901080.pdf'),
(107, 1, NULL, 'LICENCA_MATERNIDADE', '2025-11-05', '2025-11-07', 'aaaaaaaaaaaaa', 'uploads/comprovantes/anexo_685ecf29b8b8d0.67348386.jpg'),
(108, 1, NULL, 'LICENCA_PATERNIDADE', '2025-11-01', '2025-11-03', 'aaaaaaaaaaaa', 'uploads/comprovantes/anexo_685ecf1ce96033.92830572.pdf'),
(109, 1, NULL, 'LICENCA_CASAMENTO', '2025-11-10', '2025-11-10', 'aaaaaaaaaaaaa', NULL),
(110, 1, NULL, 'LICENCA_OBITO', '2025-12-01', '2025-12-02', 'aaaaaaaaaaaa', NULL),
(111, 1, NULL, '', '2025-12-04', '2025-12-05', 'aaaaaaaaaaaaa', NULL),
(112, 1, NULL, '', '2025-12-06', '2025-12-06', 'aaaaaaaaaaa', NULL),
(113, 1, NULL, 'DOACAO_SANGUE', '2025-12-07', '2025-12-07', 'aaaaaaaaa', NULL),
(114, 1, NULL, '', '2025-12-08', '2025-12-08', 'aaaaaaaa', NULL),
(115, 1, NULL, '', '2025-12-08', '2025-12-08', 'aaaaaaaaa', NULL),
(116, 1, NULL, '', '2025-12-09', '2025-12-09', 'aaaaaaaaa', NULL),
(117, 1, NULL, 'ACOMPANHAMENTO_CONJUGE', '2025-12-10', '2025-12-10', 'aaaaaaa', NULL),
(118, 1, NULL, '', '2025-12-10', '2025-12-10', 'aaaaa', NULL),
(119, 1, NULL, 'LICENCA_CASAMENTO', '2026-02-01', '2026-02-01', 'aaaaaaaaaaa', NULL),
(144, 6, NULL, 'ATESTADO_MEDICO', '2025-06-04', '2025-06-05', 'Atestado por motivo de saúde', NULL),
(145, 6, NULL, 'ABONO', '2025-06-06', '2025-06-06', 'Abono por motivo pessoal', NULL),
(146, 6, NULL, '', '2025-06-09', '2025-06-09', 'Folga compensatória', NULL);

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
(550, 1, 'FIM_JORNADA', '2025-06-04 17:15:00'),
(551, 1, 'INICIO_JORNADA', '2025-06-26 16:55:25'),
(552, 1, 'FIM_JORNADA', '2025-06-26 16:55:36'),
(585, 6, 'INICIO_JORNADA', '2025-06-02 08:00:00'),
(586, 6, 'INICIO_INTERVALO', '2025-06-02 12:00:00'),
(587, 6, 'RETORNO_INTERVALO', '2025-06-02 13:00:00'),
(588, 6, 'FIM_JORNADA', '2025-06-02 17:00:00'),
(589, 6, 'INICIO_JORNADA', '2025-06-03 08:00:00'),
(590, 6, 'INICIO_INTERVALO', '2025-06-03 12:00:00'),
(591, 6, 'RETORNO_INTERVALO', '2025-06-03 13:00:00'),
(592, 6, 'FIM_JORNADA', '2025-06-03 17:00:00'),
(593, 6, 'INICIO_JORNADA', '2025-06-04 08:00:00'),
(594, 6, 'INICIO_INTERVALO', '2025-06-04 12:00:00'),
(595, 6, 'RETORNO_INTERVALO', '2025-06-04 13:00:00'),
(596, 6, 'FIM_JORNADA', '2025-06-04 17:00:00'),
(597, 6, 'INICIO_JORNADA', '2025-06-05 08:00:00'),
(598, 6, 'INICIO_INTERVALO', '2025-06-05 12:00:00'),
(599, 6, 'RETORNO_INTERVALO', '2025-06-05 13:00:00'),
(600, 6, 'FIM_JORNADA', '2025-06-05 17:00:00'),
(601, 6, 'INICIO_JORNADA', '2025-06-06 08:00:00'),
(602, 6, 'INICIO_INTERVALO', '2025-06-06 12:00:00'),
(603, 6, 'RETORNO_INTERVALO', '2025-06-06 13:00:00'),
(604, 6, 'FIM_JORNADA', '2025-06-06 17:00:00'),
(605, 6, 'INICIO_JORNADA', '2025-06-09 08:00:00'),
(606, 6, 'INICIO_INTERVALO', '2025-06-09 12:00:00'),
(607, 6, 'RETORNO_INTERVALO', '2025-06-09 13:00:00'),
(608, 6, 'FIM_JORNADA', '2025-06-09 17:00:00'),
(613, 6, 'INICIO_JORNADA', '2025-06-11 08:00:00'),
(614, 6, 'INICIO_INTERVALO', '2025-06-11 12:00:00'),
(615, 6, 'RETORNO_INTERVALO', '2025-06-11 13:00:00'),
(616, 6, 'FIM_JORNADA', '2025-06-11 17:00:00'),
(617, 6, 'INICIO_JORNADA', '2025-06-12 08:00:00'),
(618, 6, 'INICIO_INTERVALO', '2025-06-12 12:00:00'),
(619, 6, 'RETORNO_INTERVALO', '2025-06-12 13:00:00'),
(620, 6, 'FIM_JORNADA', '2025-06-12 17:00:00'),
(621, 6, 'INICIO_JORNADA', '2025-06-13 08:00:00'),
(622, 6, 'INICIO_INTERVALO', '2025-06-13 12:00:00'),
(623, 6, 'RETORNO_INTERVALO', '2025-06-13 13:00:00'),
(624, 6, 'FIM_JORNADA', '2025-06-13 17:00:00'),
(625, 6, 'INICIO_JORNADA', '2025-06-16 08:00:00'),
(626, 6, 'INICIO_INTERVALO', '2025-06-16 12:00:00'),
(627, 6, 'RETORNO_INTERVALO', '2025-06-16 13:00:00'),
(628, 6, 'FIM_JORNADA', '2025-06-16 17:00:00'),
(629, 6, 'INICIO_JORNADA', '2025-06-17 08:00:00'),
(630, 6, 'INICIO_INTERVALO', '2025-06-17 12:00:00'),
(631, 6, 'RETORNO_INTERVALO', '2025-06-17 13:00:00'),
(632, 6, 'FIM_JORNADA', '2025-06-17 17:00:00'),
(633, 6, 'INICIO_JORNADA', '2025-06-18 08:00:00'),
(634, 6, 'INICIO_INTERVALO', '2025-06-18 12:00:00'),
(635, 6, 'RETORNO_INTERVALO', '2025-06-18 13:00:00'),
(636, 6, 'FIM_JORNADA', '2025-06-18 17:00:00'),
(637, 6, 'INICIO_JORNADA', '2025-06-19 08:00:00'),
(638, 6, 'INICIO_INTERVALO', '2025-06-19 12:00:00'),
(639, 6, 'RETORNO_INTERVALO', '2025-06-19 13:00:00'),
(640, 6, 'FIM_JORNADA', '2025-06-19 17:00:00'),
(641, 6, 'INICIO_JORNADA', '2025-06-20 08:00:00'),
(642, 6, 'INICIO_INTERVALO', '2025-06-20 12:00:00'),
(643, 6, 'RETORNO_INTERVALO', '2025-06-20 13:00:00'),
(644, 6, 'FIM_JORNADA', '2025-06-20 17:00:00'),
(645, 6, 'INICIO_JORNADA', '2025-06-23 08:00:00'),
(646, 6, 'INICIO_INTERVALO', '2025-06-23 12:00:00'),
(647, 6, 'RETORNO_INTERVALO', '2025-06-23 13:00:00'),
(648, 6, 'FIM_JORNADA', '2025-06-23 17:00:00'),
(649, 6, 'INICIO_JORNADA', '2025-06-24 08:00:00'),
(650, 6, 'INICIO_INTERVALO', '2025-06-24 12:00:00'),
(651, 6, 'RETORNO_INTERVALO', '2025-06-24 13:00:00'),
(652, 6, 'FIM_JORNADA', '2025-06-24 17:00:00'),
(653, 6, 'INICIO_JORNADA', '2025-06-25 08:00:00'),
(654, 6, 'INICIO_INTERVALO', '2025-06-25 12:00:00'),
(655, 6, 'RETORNO_INTERVALO', '2025-06-25 13:00:00'),
(656, 6, 'FIM_JORNADA', '2025-06-25 17:00:00'),
(657, 6, 'INICIO_JORNADA', '2025-06-26 08:00:00'),
(658, 6, 'INICIO_INTERVALO', '2025-06-26 12:00:00'),
(659, 6, 'RETORNO_INTERVALO', '2025-06-26 13:00:00'),
(660, 6, 'FIM_JORNADA', '2025-06-26 17:00:00'),
(661, 6, 'INICIO_JORNADA', '2025-06-27 08:00:00'),
(662, 6, 'INICIO_INTERVALO', '2025-06-27 12:00:00'),
(663, 6, 'RETORNO_INTERVALO', '2025-06-27 13:00:00'),
(664, 6, 'FIM_JORNADA', '2025-06-27 17:00:00'),
(665, 6, 'INICIO_JORNADA', '2025-06-30 08:00:00'),
(666, 6, 'INICIO_INTERVALO', '2025-06-30 12:00:00'),
(667, 6, 'RETORNO_INTERVALO', '2025-06-30 13:00:00'),
(668, 6, 'FIM_JORNADA', '2025-06-30 17:00:00'),
(669, 6, 'INICIO_JORNADA', '2025-06-10 08:00:00'),
(670, 6, 'FIM_JORNADA', '2025-06-10 12:00:00');

-- --------------------------------------------------------

--
-- Estrutura para tabela `solicitacoes_alteracao`
--

CREATE TABLE `solicitacoes_alteracao` (
  `id_solicitacao` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `data_ocorrencia` date NOT NULL,
  `data_atestado_inicio` date DEFAULT NULL,
  `data_atestado_fim` date DEFAULT NULL,
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

INSERT INTO `solicitacoes_alteracao` (`id_solicitacao`, `id_usuario`, `data_ocorrencia`, `data_atestado_inicio`, `data_atestado_fim`, `tipo_solicitacao`, `descricao`, `caminho_anexo`, `data_solicitacao`, `status_solicitacao`, `justificativa_admin`, `caminho_anexo_admin`, `novo_horario_sugerido`, `novo_tipo_ponto_sugerido`, `id_registro_original`) VALUES
(1, 1, '2025-06-03', NULL, NULL, 'ATESTADO_MEDICO', 'Compareci ao médico', 'uploads/comprovantes/anexo_6840b05a39c709.44069982.jpg', '2025-06-04 20:45:14', 'REJEITADA', 'Não tem nada no documento.', 'uploads/admin_anexos/admin_recusa_6840bb6a4c8b64.92210718.jpg', NULL, NULL, NULL),
(2, 1, '2025-06-04', NULL, NULL, 'ESQUECIMENTO_PONTO', 'Esqueci de bater uns pontos hoje', NULL, '2025-06-04 21:30:41', 'APROVADA', NULL, NULL, NULL, NULL, NULL),
(3, 1, '2025-06-05', NULL, NULL, 'ESQUECIMENTO_PONTO', 'Esqueci de bater o ponto de início de jornada.', NULL, '2025-06-05 15:52:17', 'REJEITADA', 'Duplicidade', NULL, '12:35:00', 'INICIO_JORNADA', NULL),
(4, 1, '2025-06-05', NULL, NULL, 'ESQUECIMENTO_PONTO', 'Esqueci de bater o ponto hihihi', NULL, '2025-06-05 16:16:59', 'APROVADA', 'certo', NULL, '12:35:00', 'INICIO_JORNADA', NULL),
(5, 1, '2025-06-05', NULL, NULL, 'ESQUECIMENTO_PONTO', 'esquecii', NULL, '2025-06-05 16:58:44', 'APROVADA', 'teste', NULL, '13:00:00', 'INICIO_INTERVALO', NULL),
(6, 1, '2025-06-05', NULL, NULL, 'PONTO_INCORRETO', 'era pra registrar inicio de jornada 12h35, intervalo 13h, volta 13h05 e fim da jornada 14h.', NULL, '2025-06-05 17:07:00', 'REJEITADA', 'Não há registros.', NULL, NULL, NULL, NULL),
(7, 1, '2025-06-05', NULL, NULL, 'ESQUECIMENTO_PONTO', 'esqueci', NULL, '2025-06-05 17:07:16', 'APROVADA', 'ok', NULL, '12:35:00', 'INICIO_JORNADA', NULL),
(8, 1, '2025-06-02', NULL, NULL, 'ATESTADO_MEDICO', 'Atesto o dia 2', NULL, '2025-06-05 18:06:46', 'REJEITADA', 'Duplicidade.', NULL, NULL, NULL, NULL),
(9, 1, '2025-06-03', NULL, NULL, 'ESQUECIMENTO_PONTO', 'Esqueci de bater o ponto.', NULL, '2025-06-05 18:07:20', 'APROVADA', 'Ajustado.', NULL, '17:05:00', 'FIM_JORNADA', NULL),
(10, 1, '2025-06-04', NULL, NULL, 'PONTO_INCORRETO', 'Bati o ponto depois, mas voltei antes. Era pra ser 12:20h a volta do intervalo.', NULL, '2025-06-05 18:08:28', 'APROVADA', 'Ajustado.', NULL, NULL, NULL, NULL),
(11, 1, '2025-06-02', NULL, NULL, 'ATESTADO_MEDICO', 'não compareci', NULL, '2025-06-05 18:21:17', 'REJEITADA', 'duplicidade', NULL, NULL, NULL, NULL),
(12, 1, '2025-06-02', NULL, NULL, 'ATESTADO_MEDICO', 'num fui esse dia aí', 'uploads/comprovantes/anexo_6841e32161c936.13605769.jpg', '2025-06-05 18:34:09', 'APROVADA', 'Aceito.', 'uploads/admin_anexos/admin_aprov_6841ebef0a9711.53448572.pdf', NULL, NULL, NULL),
(15, 1, '2025-06-06', NULL, NULL, 'PONTO_INCORRETO', 'ajusta o ponto', NULL, '2025-06-06 15:55:01', 'REJEITADA', '', NULL, '00:00:00', '', NULL),
(16, 7, '2025-06-06', NULL, NULL, 'PONTO_INCORRETO', 'Ajusta aí se faz favore', NULL, '2025-06-06 16:35:17', 'REJEITADA', 'nao', NULL, '00:00:00', '', NULL),
(17, 7, '2025-06-06', NULL, NULL, 'PONTO_INCORRETO', 'Ajusta aí se faz favore', NULL, '2025-06-06 16:35:31', 'REJEITADA', 'NÃO QUERO', NULL, '00:00:00', '', NULL),
(18, 1, '2025-06-06', NULL, NULL, 'PONTO_INCORRETO', 'arruma pra mim', NULL, '2025-06-06 17:21:23', 'REJEITADA', 'EU RECUSOOOOOOOOOO', NULL, '00:00:00', '', NULL),
(20, 1, '2025-06-06', NULL, NULL, 'PONTO_INCORRETO', 'vamos verrrrrrrrrrr', NULL, '2025-06-06 21:33:34', 'APROVADA', 'Ajustado.', NULL, '18:35:00', 'FIM_JORNADA', NULL),
(21, 1, '2025-06-09', NULL, NULL, 'PONTO_INCORRETO', 'Registrei errado', NULL, '2025-06-09 15:44:08', 'APROVADA', 'Ajustado.', NULL, '12:45:00', 'FIM_JORNADA', NULL),
(22, 1, '2025-06-09', NULL, NULL, 'PONTO_INCORRETO', 'coloquei errado', NULL, '2025-06-09 20:39:18', 'APROVADA', 'ajustado.', NULL, '18:00:00', 'FIM_JORNADA', NULL),
(23, 1, '2025-06-10', NULL, NULL, 'PONTO_INCORRETO', 'ajuste aí', NULL, '2025-06-10 14:41:38', 'REJEITADA', 'Negado.', NULL, '11:50:00', 'FIM_JORNADA', NULL),
(24, 1, '2025-06-08', NULL, NULL, 'ATESTADO_MEDICO', 'atestado', 'uploads/comprovantes/anexo_6848443312dfb7.35198948.jpg', '2025-06-10 14:41:55', 'APROVADA', 'ajustado', NULL, NULL, NULL, NULL),
(25, 1, '2025-06-13', NULL, NULL, 'PONTO_INCORRETO', 'ajusta', 'uploads/comprovantes/anexo_684c91ea9dd910.67915046.jpg', '2025-06-13 21:02:34', 'APROVADA', 'ajustado', 'uploads/admin_anexos/admin_aprovar_684c926f4f1870.63281893.jpg', '18:05:00', 'FIM_JORNADA', NULL),
(26, 1, '2025-06-26', '2025-06-26', '2025-07-07', 'ATESTADO_MEDICO', 'solicito atestado', 'uploads/comprovantes/anexo_685d9a2f85e9b7.10710814.jpg', '2025-06-26 19:06:23', 'REJEITADA', 'no.', NULL, NULL, NULL, NULL),
(27, 1, '2025-06-26', '2025-06-26', '2025-07-07', 'ATESTADO_MEDICO', 'solicito atestado', 'uploads/comprovantes/anexo_685d9a9f1c5845.81707598.jpg', '2025-06-26 19:08:15', 'REJEITADA', 'duplicidade.', NULL, NULL, NULL, NULL),
(28, 1, '2025-06-26', '2025-06-26', '2025-07-07', 'ATESTADO_MEDICO', 'solicito atestado', 'uploads/comprovantes/anexo_685d9b59c7c4c8.02726732.jpg', '2025-06-26 19:11:21', 'APROVADA', 'confirmo', NULL, NULL, NULL, NULL),
(29, 1, '2025-08-01', '2025-08-01', '2025-08-05', 'FERIAS', 'solicito férias', NULL, '2025-06-27 15:37:00', 'APROVADA', 'Aprovado.', 'uploads/admin_anexos/admin_aprovar_685ebac885ed10.69571847.jpg', NULL, NULL, NULL),
(30, 1, '2025-09-01', '2025-09-01', '2025-09-05', 'FERIAS', 'solicito férias', NULL, '2025-06-27 15:49:25', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(31, 1, '2025-10-10', NULL, NULL, 'ACIDENTE_TRABALHO', 'acidente', NULL, '2025-06-27 16:05:44', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(32, 1, '2025-10-11', NULL, NULL, 'ACOMPANHAMENTO_CONJUGE', 'acompanhamento', NULL, '2025-06-27 16:06:02', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(33, 1, '2025-10-12', NULL, NULL, 'ACOMPANHAMENTO_MEDICO', 'consulta', NULL, '2025-06-27 16:06:17', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(34, 1, '2025-10-13', NULL, NULL, 'SERVICO_MILITAR', 'militar', NULL, '2025-06-27 16:06:27', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(35, 1, '2025-10-15', NULL, NULL, 'ALISTAMENTO_ELEITORAL', 'alistamento', NULL, '2025-06-27 16:06:40', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(36, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:07:02', 'APROVADA', 'aprovado.', NULL, NULL, NULL, NULL),
(37, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:08:34', 'APROVADA', 'aprovado.', NULL, NULL, NULL, NULL),
(38, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:16:28', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(39, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:17:33', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(40, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:18:14', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(41, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:19:26', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(42, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:20:25', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(43, 1, '2025-10-16', NULL, NULL, 'DOACAO_SANGUE', 'doação de sangue', NULL, '2025-06-27 16:23:31', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(44, 1, '2025-10-25', NULL, NULL, 'AUXILIO_DOENCA', 'auxílio doença', 'uploads/comprovantes/anexo_685ec59c3b2274.18632617.jpg', '2025-06-27 16:23:56', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(45, 1, '2025-10-26', '2025-10-26', '2025-10-28', 'COMPARECIMENTO_JUIZO', 'juizo', 'uploads/comprovantes/anexo_685ec71c3bde69.53333965.pdf', '2025-06-27 16:30:20', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(46, 1, '2025-09-01', '2025-09-01', '2025-09-02', 'LICENCA_OBITO', 'obito', 'uploads/comprovantes/anexo_685ec72fa21317.23463690.jpg', '2025-06-27 16:30:39', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(47, 1, '2025-11-05', NULL, NULL, 'LICENCA_CASAMENTO', 'casamento', NULL, '2025-06-27 16:30:59', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(48, 1, '2025-10-10', NULL, NULL, 'ALISTAMENTO_ELEITORAL', 'alistamento eleitoral', 'uploads/comprovantes/anexo_685ecda3767d36.06901080.pdf', '2025-06-27 16:58:11', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(49, 1, '2025-12-10', NULL, NULL, 'ACIDENTE_TRABALHO', 'aaaaa', NULL, '2025-06-27 17:01:16', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(50, 1, '2025-12-10', NULL, NULL, 'ACOMPANHAMENTO_CONJUGE', 'aaaaaaa', NULL, '2025-06-27 17:01:25', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(51, 1, '2025-12-09', NULL, NULL, 'ACOMPANHAMENTO_MEDICO', 'aaaaaaaaa', NULL, '2025-06-27 17:01:35', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(52, 1, '2025-12-08', NULL, NULL, 'SERVICO_MILITAR', 'aaaaaaaaa', NULL, '2025-06-27 17:01:44', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(53, 1, '2025-12-08', NULL, NULL, 'SERVICO_MILITAR', 'aaaaaaaa', NULL, '2025-06-27 17:01:52', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(54, 1, '2025-12-07', NULL, NULL, 'DOACAO_SANGUE', 'aaaaaaaaa', NULL, '2025-06-27 17:02:04', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(55, 1, '2025-12-06', NULL, NULL, 'AUXILIO_DOENCA', 'aaaaaaaaaaa', NULL, '2025-06-27 17:02:14', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(56, 1, '2025-12-04', '2025-12-04', '2025-12-05', 'COMPARECIMENTO_JUIZO', 'aaaaaaaaaaaaa', NULL, '2025-06-27 17:02:28', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(57, 1, '2025-12-01', '2025-12-01', '2025-12-02', 'LICENCA_OBITO', 'aaaaaaaaaaaa', NULL, '2025-06-27 17:02:45', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(58, 1, '2025-11-10', NULL, NULL, 'LICENCA_CASAMENTO', 'aaaaaaaaaaaaa', NULL, '2025-06-27 17:03:00', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(59, 1, '2025-11-01', '2025-11-01', '2025-11-03', 'LICENCA_PATERNIDADE', 'aaaaaaaaaaaa', 'uploads/comprovantes/anexo_685ecf1ce96033.92830572.pdf', '2025-06-27 17:04:28', 'APROVADA', 'aprovado', NULL, NULL, NULL, NULL),
(60, 1, '2025-11-05', '2025-11-05', '2025-11-07', 'LICENCA_MATERNIDADE', 'aaaaaaaaaaaaa', 'uploads/comprovantes/anexo_685ecf29b8b8d0.67348386.jpg', '2025-06-27 17:04:41', 'APROVADA', 'approvado', NULL, NULL, NULL, NULL),
(61, 1, '2026-02-01', NULL, NULL, 'LICENCA_CASAMENTO', 'aaaaaaaaaaa', NULL, '2025-06-27 17:10:17', 'APROVADA', 'ok', NULL, NULL, NULL, NULL),
(76, 6, '2025-12-01', '2025-12-01', '2025-12-05', 'ATESTADO_MEDICO', 'hyhy', 'uploads/comprovantes/anexo_685ef6aaa7b750.27015851.jpg', '2025-06-27 19:53:14', 'APROVADA', 'blz', 'uploads/admin_anexos/admin_aprovar_685ef6d179a1d1.05146982.pdf', NULL, NULL, NULL),
(77, 6, '2025-12-15', '2025-12-15', '2025-12-19', 'FERIAS', 'çpçp', NULL, '2025-06-27 19:53:35', 'APROVADA', 'gtgtgtgtg', NULL, NULL, NULL, NULL);

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
  `endereco_cep` varchar(9) DEFAULT NULL COMMENT 'Formato XXXXX-XXX',
  `salario_valor` decimal(10,2) NOT NULL DEFAULT 0.00,
  `salario_tipo` enum('hora','semanal','mensal','anual') NOT NULL DEFAULT 'mensal'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nome_completo`, `email`, `telefone`, `data_admissao`, `cargo`, `data_nascimento`, `senha_hash`, `perfil`, `status`, `id_modelo_jornada`, `data_criacao`, `cpf`, `endereco_rua`, `endereco_numero`, `endereco_complemento`, `endereco_bairro`, `endereco_cidade`, `endereco_estado`, `endereco_cep`, `salario_valor`, `salario_tipo`) VALUES
(1, 'Thuany Paula Kamers', 'thuany@sistemapet.com', '48998405097', '2025-05-28', 'Estagiária de Desenvolvimento', '0000-00-00', '$2y$10$p4qn.5Mb5C0OSUmW43z4muQqycSC0n.K1PNhV9j262eywZNXZ7ksq', 'empregado', 'ativo', 5, '2025-06-04 18:38:22', '100.136.699-90', 'rua das palmeiras', '101', 'Casa', 'ponte do imaruim', 'palhoça', 'SC', '88130500', 0.00, 'mensal'),
(2, 'Administrador', 'admin@sistemapet.com', NULL, NULL, NULL, '0000-00-00', '$2y$10$5kd9J1D5RFlPltBqF8eGneuwOxHZ8kQ5EvyvsJomVKmuZUa8W0Yty', 'admin', 'ativo', NULL, '0000-00-00 00:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 'mensal'),
(6, 'Lucas Freitas Sagás', 'lucas@gmail.com', '489555555555', '2025-06-01', 'Engenheiro eletricista', '2000-01-28', '$2y$10$uGk3EYML5ObbRnhu24mX8OJWAhsbMfORF/rfChxt69v1WzydIwmse', 'empregado', 'ativo', 5, '2025-06-05 19:41:14', '12345678909', 'rua dos apóstolos', '64', 'casa', 'caminho novo', 'palhoça', 'SC', '88130000', 4500.00, 'mensal'),
(7, 'João da Silva', 'joao@gmail.com', '479898988888', '2023-01-01', 'RH', '2001-01-01', '$2y$10$yaGKNA5VLZ2f/Kmh7eCdsuRDEwzccnQcVNg6hEQTPufIRSE/F3E7e', 'empregado', 'ativo', 6, '2025-06-06 16:06:31', '12332112332', 'Rua 22', '100', 'Casa', 'Pacheco', 'Palhoça', 'SC', '88000111', 0.00, 'mensal'),
(8, 'Novo Administrador', 'adm@sistemapet.com', '48999999999', '2025-06-13', NULL, '2001-01-01', '$2y$10$6Dp58Qn.dz7YlPtMhxHHs.Adhfg6gMK1ToLz4Qm2Ppjol1JD3PcsC', 'empregado', 'ativo', 1, '2025-06-13 17:50:21', '01111122223', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 'mensal'),
(9, 'Davi Amorim de Lima', 'davi.amorim@sistemapet.com', '489555552202', '2025-06-24', NULL, '2001-02-01', '$2y$10$xaj9rEP/6JNJkqlZP675Pe5WGSij8b9OhkAqc4Ne/LSH/9SUY2kDm', 'empregado', 'ativo', 1, '2025-06-24 13:33:29', '20056889990', 'Rua Ademir Rocha', '244', 'Casa', 'Estreito', 'Florianópolis', 'SC', '88135422', 1800.00, 'mensal'),
(10, 'Davi Ferreira dos Santos', '', NULL, NULL, NULL, '2000-03-19', '', '', 'ativo', NULL, '2025-06-26 17:32:52', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 'mensal');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `ajustes_banco_horas`
--
ALTER TABLE `ajustes_banco_horas`
  ADD PRIMARY KEY (`id_ajuste`),
  ADD UNIQUE KEY `id_usuario` (`id_usuario`,`data_ajustada`);

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
-- AUTO_INCREMENT de tabela `ajustes_banco_horas`
--
ALTER TABLE `ajustes_banco_horas`
  MODIFY `id_ajuste` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=451;

--
-- AUTO_INCREMENT de tabela `feriados`
--
ALTER TABLE `feriados`
  MODIFY `id_feriado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

--
-- AUTO_INCREMENT de tabela `jornada_modelos`
--
ALTER TABLE `jornada_modelos`
  MODIFY `id_modelo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de tabela `jornada_modelo_dias`
--
ALTER TABLE `jornada_modelo_dias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT de tabela `ocorrencias`
--
ALTER TABLE `ocorrencias`
  MODIFY `id_ocorrencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=147;

--
-- AUTO_INCREMENT de tabela `registros_ponto`
--
ALTER TABLE `registros_ponto`
  MODIFY `id_registro` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=671;

--
-- AUTO_INCREMENT de tabela `solicitacoes_alteracao`
--
ALTER TABLE `solicitacoes_alteracao`
  MODIFY `id_solicitacao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT de tabela `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
