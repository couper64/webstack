--
-- PostgreSQL database dump
--

\restrict U7PwLxNizzBirkUjTrUmZjP5GgdQcN3PICKWdEVnLcHr7iQOGNwTdM3PXetGvw9

-- Dumped from database version 17.6 (Debian 17.6-1.pgdg13+1)
-- Dumped by pg_dump version 17.6 (Debian 17.6-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: forward; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forward (
    id bigint NOT NULL,
    path text NOT NULL,
    ip text NOT NULL,
    port integer NOT NULL,
    postfix text
);


--
-- Name: forward_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forward_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forward_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forward_id_seq OWNED BY public.forward.id;


--
-- Name: forward id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forward ALTER COLUMN id SET DEFAULT nextval('public.forward_id_seq'::regclass);


--
-- Data for Name: forward; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.forward (id, path, ip, port, postfix) FROM stdin;
1	/api/v1/	fastapi	8000	\N
3	/minio/api/	minio	9000	\N
2	/streamlit/	streamlit	8501	\N
4	/minio/dashboard/	minio	9001	\N
5	/flower/	flower	5555	/flower
6	/guacamole/	guacamole	8080	/guacamole
\.


--
-- Name: forward_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.forward_id_seq', 5, true);


--
-- Name: forward forward_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forward
    ADD CONSTRAINT forward_pkey PRIMARY KEY (id);


--
-- Name: forward port_check_range; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.forward
    ADD CONSTRAINT port_check_range CHECK (((port >= 0) AND (port <= 65535))) NOT VALID;


--
-- PostgreSQL database dump complete
--

\unrestrict U7PwLxNizzBirkUjTrUmZjP5GgdQcN3PICKWdEVnLcHr7iQOGNwTdM3PXetGvw9

