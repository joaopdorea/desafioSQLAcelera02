-- PARAMETROS QUE VÃO SER INSERIDOS NA CHAMADA DA PROCEDURE: nome do curso e nome do aluno.
CREATE OR REPLACE PROCEDURE sp_matricula_aluno_teste(
	p_nome_aluno VARCHAR,
	p_nome_curso VARCHAR
)

-- DEFININDO A LINGUAGEM
LANGUAGE plpgsql
AS $$
-- DECLARANDO VARIÁVEIS QUE SERÃO UTILIZADAS
DECLARE 
	var_matricula_aluno INTEGER;
	var_curso CHAR(3);
	var_materias RECORD;
	var_qtd_linhas_materias INTEGER;
	

BEGIN



SELECT matricula INTO var_matricula_aluno
FROM alunos
WHERE nome = p_nome_aluno;

--VERIFICANDO SE O ALUNO JÁ ESTÁ CADASTRADO
IF var_matricula_aluno IS NULL THEN
    INSERT INTO alunos(nome) VALUES (p_nome_aluno);
    SELECT matricula INTO var_matricula_aluno
    FROM alunos
    WHERE nome = p_nome_aluno;

END IF;


SELECT curso INTO var_curso
FROM cursos
WHERE nome = p_nome_curso;
RAISE NOTICE 'Matricula do aluno: %', var_matricula_aluno;
RAISE NOTICE 'Sigla do curso: %', var_curso;

SELECT COUNT(matricula) INTO var_qtd_linhas_materias FROM
matricula
WHERE matricula = var_matricula_aluno;

IF var_qtd_linhas_materias > 0 THEN
	RAISE EXCEPTION 'Aluno já matriculado!';
ELSE

	FOR var_materias IN
	        SELECT sigla FROM materias
			WHERE curso = var_curso
	LOOP
	        INSERT INTO matricula (matricula, curso, materia, perletivo) VALUES (var_matricula_aluno, var_curso, var_materias.sigla, CONCAT(EXTRACT(YEAR FROM NOW()), '.', CASE WHEN EXTRACT(MONTH FROM NOW()) <= 6 THEN '1' ELSE '2' END));
	END LOOP;


END IF;

END;
$$
