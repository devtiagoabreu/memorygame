-- banco de dados da tembo.io
-- 

CREATE DATABASE memory_game;

DROP TABLE IF EXISTS ranking;

CREATE TABLE ranking (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(50) NOT NULL,
    time_in_seconds INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para melhorar a performance ao buscar os melhores tempos
CREATE INDEX idx_ranking_time ON ranking (time_in_seconds);

-- Função para inserir um novo recorde e manter apenas os 10 melhores
CREATE OR REPLACE FUNCTION maintain_top_10() RETURNS TRIGGER AS $$
BEGIN
    -- Deleta os tempos acima da 10ª posição, mantendo apenas os 10 melhores
    DELETE FROM ranking
    WHERE id IN (
        SELECT id FROM ranking
        ORDER BY time_in_seconds ASC, created_at ASC
        OFFSET 10
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para executar a função após cada inserção
CREATE TRIGGER trg_maintain_top_10
AFTER INSERT ON ranking
EXECUTE FUNCTION maintain_top_10();