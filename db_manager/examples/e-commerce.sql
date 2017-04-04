 /***************************************************************************
 *   Copyright (C) 2016-2017 by Danilo Sorano <soranod@gmail.com>     *
 *   Copyright (C) 2016 by Claudio Guidi <guidiclaudio@gmail.com>     *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 *                                                                         *
 *   For details about the authors of this software, see the AUTHORS file. *
 ***************************************************************************/


 /*
  * Database E-commerce usewd to explain how the tool works
  */
DROP DATABASE  IF EXISTS e_commerce;

CREATE DATABASE e_commerce
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

\connect e_commerce

CREATE TABLE public.user
(
  fiscalcode character varying(30) NOT NULL,
  name character varying(30) NOT NULL,
  surname character varying(30) NOT NULL,
  email character varying(30) NOT NULL,
  PRIMARY KEY (fiscalcode)
)
WITH (
          OIDS = FALSE
      )
      TABLESPACE pg_default;

      ALTER TABLE public.user
          OWNER to postgres;


  CREATE TABLE public.product
  (
      id_product serial NOT NULL,
      product_name character varying(60) NOT NULL,
      description character varying(100),
      quantity bigint NOT NULL,
      PRIMARY KEY (id_product)
  )
  WITH (
            OIDS = FALSE
        )
        TABLESPACE pg_default;

        ALTER TABLE public.product
            OWNER to postgres;


      CREATE TABLE public.order
      (
          id_order serial NOT NULL,
          id_product bigint NOT NULL,
          id_user character varying(30) NOT NULL,
          quantity bigint NOT NULL,
          date timestamp without time zone DEFAULT NOW(),
          PRIMARY KEY (id_order)
      )
      WITH (
          OIDS = FALSE
      )
      TABLESPACE pg_default;

      ALTER TABLE public.order
          OWNER to postgres;
