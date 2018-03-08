--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.4
-- Dumped by pg_dump version 9.6.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: assemblages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE assemblages (
    id integer NOT NULL,
    name text,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    kind character varying(255)
);


--
-- Name: assemblages_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE assemblages_files (
    assemblage_id integer,
    file_id integer
);


--
-- Name: assemblages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assemblages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assemblages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assemblages_id_seq OWNED BY assemblages.id;


--
-- Name: assemblies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE assemblies (
    assemblage_id integer,
    child_assemblage_id integer,
    kind character varying(255),
    id integer NOT NULL
);


--
-- Name: assemblies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assemblies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assemblies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assemblies_id_seq OWNED BY assemblies.id;


--
-- Name: borkles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE borkles (
    user_id integer,
    file_id integer,
    inserted_at timestamp without time zone NOT NULL,
    scrobbled boolean DEFAULT false NOT NULL
);


--
-- Name: files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE files (
    id integer NOT NULL,
    path text,
    mime character varying(255),
    size integer,
    sha256 bytea,
    seen_at timestamp without time zone,
    atime timestamp without time zone,
    mtime timestamp without time zone,
    ctime timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    id3v2 jsonb
);


--
-- Name: files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE files_id_seq OWNED BY files.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags (
    id integer NOT NULL,
    key character varying(255),
    value character varying(255),
    assemblage_id integer,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lastfm_username character varying(255),
    lastfm_key character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: assemblages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblages ALTER COLUMN id SET DEFAULT nextval('assemblages_id_seq'::regclass);


--
-- Name: assemblies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblies ALTER COLUMN id SET DEFAULT nextval('assemblies_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY files ALTER COLUMN id SET DEFAULT nextval('files_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: assemblages assemblages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblages
    ADD CONSTRAINT assemblages_pkey PRIMARY KEY (id);


--
-- Name: assemblies assemblies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblies
    ADD CONSTRAINT assemblies_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: assemblages_assemblages_assemblage_id_child_assemblage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assemblages_assemblages_assemblage_id_child_assemblage_id_index ON assemblies USING btree (assemblage_id, child_assemblage_id);


--
-- Name: assemblages_assemblages_assemblage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assemblages_assemblages_assemblage_id_index ON assemblies USING btree (assemblage_id);


--
-- Name: assemblages_assemblages_child_assemblage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assemblages_assemblages_child_assemblage_id_index ON assemblies USING btree (child_assemblage_id);


--
-- Name: assemblages_files_assemblage_id_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX assemblages_files_assemblage_id_file_id_index ON assemblages_files USING btree (assemblage_id, file_id);


--
-- Name: assemblages_files_assemblage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX assemblages_files_assemblage_id_index ON assemblages_files USING btree (assemblage_id);


--
-- Name: borkles_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX borkles_file_id_index ON borkles USING btree (file_id);


--
-- Name: borkles_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX borkles_user_id_index ON borkles USING btree (user_id);


--
-- Name: files_path_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX files_path_index ON files USING btree (path);


--
-- Name: files_sha256_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX files_sha256_index ON files USING btree (sha256);


--
-- Name: tags_assemblage_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tags_assemblage_id_index ON tags USING btree (assemblage_id);


--
-- Name: assemblies assemblages_assemblages_assemblage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblies
    ADD CONSTRAINT assemblages_assemblages_assemblage_id_fkey FOREIGN KEY (assemblage_id) REFERENCES assemblages(id);


--
-- Name: assemblies assemblages_assemblages_child_assemblage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblies
    ADD CONSTRAINT assemblages_assemblages_child_assemblage_id_fkey FOREIGN KEY (child_assemblage_id) REFERENCES assemblages(id);


--
-- Name: assemblages_files assemblages_files_assemblage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblages_files
    ADD CONSTRAINT assemblages_files_assemblage_id_fkey FOREIGN KEY (assemblage_id) REFERENCES assemblages(id);


--
-- Name: assemblages_files assemblages_files_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assemblages_files
    ADD CONSTRAINT assemblages_files_file_id_fkey FOREIGN KEY (file_id) REFERENCES files(id);


--
-- Name: borkles borkles_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY borkles
    ADD CONSTRAINT borkles_file_id_fkey FOREIGN KEY (file_id) REFERENCES files(id);


--
-- Name: borkles borkles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY borkles
    ADD CONSTRAINT borkles_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: tags tags_assemblage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_assemblage_id_fkey FOREIGN KEY (assemblage_id) REFERENCES assemblages(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20170113125235), (20170113145411), (20170113150407), (20170113150619), (20170113221822), (20170113234956), (20170113235046), (20170114111539), (20170114185651), (20170114230607), (20170115130531), (20170207172503), (20170816223846), (20170816224152), (20170816224633);

