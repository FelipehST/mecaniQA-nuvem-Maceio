CREATE DATABASE IF NOT EXISTS mecaniqa;

USE mecaniqa;

CREATE TABLE IF NOT EXISTS health_check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensagem VARCHAR(100) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO health_check (mensagem)
SELECT 'MecaniQA MySQL ativo'
WHERE NOT EXISTS (
    SELECT 1
    FROM health_check
    WHERE mensagem = 'MecaniQA MySQL ativo'
);
