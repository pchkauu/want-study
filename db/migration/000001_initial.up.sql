CREATE TABLE studies (
    id uuid PRIMARY KEY,
    title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 200),
    goal text NOT NULL DEFAULT '' CHECK (octet_length(goal) <= 1048576),
    local_repository_path text NOT NULL DEFAULT '',
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    content_revision bigint NOT NULL DEFAULT 1 CHECK (content_revision > 0),
    archived_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE learning_sources (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    source_type text NOT NULL CHECK (source_type IN ('course', 'book', 'article', 'video', 'other')),
    title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 200),
    author text NOT NULL DEFAULT '',
    url text NOT NULL DEFAULT '',
    export_slug text NOT NULL CHECK (export_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
    position integer NOT NULL CHECK (position >= 0),
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    archived_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, study_id),
    UNIQUE (study_id, export_slug)
);

CREATE TABLE sections (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    source_id uuid NOT NULL,
    title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 200),
    position integer NOT NULL CHECK (position >= 0),
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    archived_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, source_id),
    FOREIGN KEY (source_id, study_id) REFERENCES learning_sources(id, study_id)
);

CREATE TABLE lessons (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    source_id uuid NOT NULL,
    section_id uuid,
    title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 200),
    url text NOT NULL DEFAULT '',
    source_position text NOT NULL DEFAULT '',
    export_slug text NOT NULL CHECK (export_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
    position integer NOT NULL CHECK (position >= 0),
    status text NOT NULL CHECK (status IN ('planned', 'studying', 'homework', 'mastered')),
    started_at timestamptz,
    mastered_at timestamptz,
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    archived_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, study_id),
    UNIQUE (source_id, export_slug),
    FOREIGN KEY (source_id, study_id) REFERENCES learning_sources(id, study_id),
    FOREIGN KEY (section_id, source_id) REFERENCES sections(id, source_id),
    CHECK (status = 'planned' OR started_at IS NOT NULL),
    CHECK ((status = 'mastered') = (mastered_at IS NOT NULL))
);

CREATE TABLE note_blocks (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    lesson_id uuid NOT NULL,
    block_type text NOT NULL CHECK (block_type IN ('text', 'definition', 'claim', 'quote', 'example', 'question', 'summary')),
    markdown text NOT NULL CHECK (octet_length(markdown) <= 1048576),
    source_url text NOT NULL DEFAULT '',
    source_position text NOT NULL DEFAULT '',
    position integer NOT NULL CHECK (position >= 0),
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, study_id),
    FOREIGN KEY (lesson_id, study_id) REFERENCES lessons(id, study_id) ON DELETE CASCADE
);

CREATE TABLE homework_tasks (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    lesson_id uuid NOT NULL,
    prompt_markdown text NOT NULL CHECK (octet_length(prompt_markdown) <= 1048576),
    solution_markdown text NOT NULL DEFAULT '' CHECK (octet_length(solution_markdown) <= 1048576),
    status text NOT NULL CHECK (status IN ('todo', 'done')),
    due_at timestamptz,
    position integer NOT NULL CHECK (position >= 0),
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, lesson_id),
    UNIQUE (id, study_id),
    FOREIGN KEY (lesson_id, study_id) REFERENCES lessons(id, study_id) ON DELETE CASCADE
);

CREATE TABLE code_files (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    lesson_id uuid NOT NULL,
    homework_task_id uuid,
    relative_path text NOT NULL,
    language text NOT NULL DEFAULT '',
    content text NOT NULL CHECK (octet_length(content) <= 1048576),
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (lesson_id, relative_path),
    FOREIGN KEY (lesson_id, study_id) REFERENCES lessons(id, study_id) ON DELETE CASCADE,
    FOREIGN KEY (homework_task_id, lesson_id) REFERENCES homework_tasks(id, lesson_id) ON DELETE CASCADE,
    CHECK (relative_path <> ''),
    CHECK (relative_path !~ '(^/|\\\\|(^|/)\.\.(/|$)|(^|/)\.(/|$))')
);

CREATE TABLE concepts (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    title text NOT NULL CHECK (char_length(btrim(title)) BETWEEN 1 AND 200),
    description_markdown text NOT NULL DEFAULT '' CHECK (octet_length(description_markdown) <= 1048576),
    export_slug text NOT NULL CHECK (export_slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    archived_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (id, study_id),
    UNIQUE (study_id, export_slug)
);

CREATE UNIQUE INDEX concepts_active_title_unique
    ON concepts (study_id, lower(title))
    WHERE archived_at IS NULL;

CREATE TABLE concept_aliases (
    study_id uuid NOT NULL REFERENCES studies(id),
    concept_id uuid NOT NULL,
    alias text NOT NULL CHECK (char_length(btrim(alias)) BETWEEN 1 AND 200),
    PRIMARY KEY (concept_id, alias),
    FOREIGN KEY (concept_id, study_id) REFERENCES concepts(id, study_id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX concept_aliases_study_alias_unique
    ON concept_aliases (study_id, lower(alias));

CREATE TABLE block_concepts (
    study_id uuid NOT NULL REFERENCES studies(id),
    block_id uuid NOT NULL,
    concept_id uuid NOT NULL,
    PRIMARY KEY (block_id, concept_id),
    FOREIGN KEY (block_id, study_id) REFERENCES note_blocks(id, study_id) ON DELETE CASCADE,
    FOREIGN KEY (concept_id, study_id) REFERENCES concepts(id, study_id) ON DELETE CASCADE
);

CREATE TABLE concept_relations (
    id uuid PRIMARY KEY,
    study_id uuid NOT NULL REFERENCES studies(id),
    source_concept_id uuid NOT NULL,
    target_concept_id uuid NOT NULL,
    relation_type text NOT NULL CHECK (relation_type IN ('relatedTo', 'partOf', 'prerequisiteFor', 'contrastsWith', 'appliesTo')),
    version bigint NOT NULL DEFAULT 1 CHECK (version > 0),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    FOREIGN KEY (source_concept_id, study_id) REFERENCES concepts(id, study_id) ON DELETE CASCADE,
    FOREIGN KEY (target_concept_id, study_id) REFERENCES concepts(id, study_id) ON DELETE CASCADE,
    CHECK (source_concept_id <> target_concept_id),
    CHECK (relation_type NOT IN ('relatedTo', 'contrastsWith') OR source_concept_id < target_concept_id),
    UNIQUE (study_id, source_concept_id, target_concept_id, relation_type)
);

CREATE TABLE import_runs (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    study_id uuid NOT NULL REFERENCES studies(id),
    repository_path text NOT NULL,
    source_revision text NOT NULL,
    warning_count integer NOT NULL DEFAULT 0 CHECK (warning_count >= 0),
    imported_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (repository_path, source_revision)
);

CREATE INDEX learning_sources_study_position_idx ON learning_sources (study_id, position, id);
CREATE INDEX sections_source_position_idx ON sections (source_id, position, id);
CREATE INDEX lessons_source_position_idx ON lessons (source_id, position, id);
CREATE INDEX note_blocks_lesson_position_idx ON note_blocks (lesson_id, position, id);
CREATE INDEX homework_tasks_lesson_position_idx ON homework_tasks (lesson_id, position, id);
CREATE INDEX block_concepts_concept_idx ON block_concepts (concept_id, block_id);
CREATE INDEX concept_relations_source_idx ON concept_relations (source_concept_id);
CREATE INDEX concept_relations_target_idx ON concept_relations (target_concept_id);

CREATE FUNCTION bump_study_revision_from_child() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    changed_study_id uuid;
BEGIN
    changed_study_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.study_id ELSE NEW.study_id END;
    UPDATE studies
    SET content_revision = content_revision + 1,
        updated_at = now()
    WHERE id = changed_study_id;
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$;

CREATE FUNCTION bump_study_own_revision() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.title IS DISTINCT FROM OLD.title
        OR NEW.goal IS DISTINCT FROM OLD.goal
        OR NEW.archived_at IS DISTINCT FROM OLD.archived_at THEN
        NEW.content_revision := OLD.content_revision + 1;
    END IF;
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

CREATE TRIGGER studies_revision_before_update
BEFORE UPDATE ON studies
FOR EACH ROW EXECUTE FUNCTION bump_study_own_revision();

CREATE TRIGGER learning_sources_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON learning_sources
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER sections_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON sections
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER lessons_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON lessons
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER note_blocks_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON note_blocks
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER homework_tasks_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON homework_tasks
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER code_files_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON code_files
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER concepts_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON concepts
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER concept_aliases_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON concept_aliases
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER block_concepts_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON block_concepts
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
CREATE TRIGGER concept_relations_revision_after_change
AFTER INSERT OR UPDATE OR DELETE ON concept_relations
FOR EACH ROW EXECUTE FUNCTION bump_study_revision_from_child();
