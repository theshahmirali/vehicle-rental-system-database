--Name: Shah Mir Ali bin Kamran

/*
Creating Table
*/

---------- VEHICLE_UNIT ----------
CREATE TABLE vehicle_unit (
    garage_code                NUMBER(2) NOT NULL,
    vunit_id                   NUMERIC(6) NOT NULL,
    vunit_purchase_price       NUMERIC(7,2) NOT NULL,
    vunit_exhibition_flag      CHAR(1) NOT NULL,
    vehicle_insurance_id       VARCHAR2(20) NOT NULL,
    vunit_rego                 VARCHAR2 (8) NOT NULL
);

ALTER TABLE vehicle_unit
    ADD CONSTRAINT v_exhibition_chk CHECK ( vunit_exhibition_flag IN (
        'E',
        'R'
    ) );

COMMENT ON COLUMN vehicle_unit.garage_code IS
    'garage code identifier - identifies the garage code';
    
COMMENT ON COLUMN vehicle_unit.vunit_id IS
    'the vehicle identifier local id number';
    
COMMENT ON COLUMN vehicle_unit.vunit_purchase_price IS
    'the purchase price of the vehicle';
    
COMMENT ON COLUMN vehicle_unit.vunit_exhibition_flag IS
    'the vehicle flag to know if it is for exhibiton ("E") or is it for rent ("R")';
    
COMMENT ON COLUMN vehicle_unit.vehicle_insurance_id IS
    'the insurance identifier';
    
COMMENT ON COLUMN vehicle_unit.vunit_rego IS
    'the vehicle registration identifier';
    
ALTER TABLE vehicle_unit ADD CONSTRAINT vehicle_unit_pk PRIMARY KEY ( garage_code, vunit_id );

ALTER TABLE vehicle_unit ADD CONSTRAINT vehicle_unit_uq UNIQUE ( vunit_rego );

ALTER TABLE vehicle_unit
    ADD CONSTRAINT vehicle_garage FOREIGN KEY ( garage_code )
        REFERENCES garage ( garage_code );
        
ALTER TABLE vehicle_unit
    ADD CONSTRAINT vehicle_insurance FOREIGN KEY ( vehicle_insurance_id )
        REFERENCES vehicle_detail ( vehicle_insurance_id ); 
        
---------- LOAN ----------
CREATE TABLE loan (
    garage_code                NUMBER(2) NOT NULL,
    vunit_id                   NUMERIC(6) NOT NULL,
    loan_date_time             DATE NOT NULL,
    loan_due_date              DATE NOT NULL,
    loan_actual_return_date    DATE,
    renter_no                  NUMERIC (6) NOT NULL
);

COMMENT ON COLUMN loan.garage_code IS
    'garage code identifier - identifies the garage code';
    
COMMENT ON COLUMN loan.vunit_id IS
    'the vehicle identifier local id number';    
    
COMMENT ON COLUMN loan.loan_date_time IS
    'the time and date of when the vehicle was loaned';  

COMMENT ON COLUMN loan.loan_due_date IS
    'the due date of the vehicle'; 
    
COMMENT ON COLUMN loan.loan_actual_return_date IS
    'the return of date of the vehicle'; 

COMMENT ON COLUMN loan.renter_no IS
    'the identification id of the renter'; 

ALTER TABLE loan ADD CONSTRAINT loan_pk PRIMARY KEY ( garage_code, vunit_id, loan_date_time );

ALTER TABLE loan
    ADD CONSTRAINT vloan_garage_unit FOREIGN KEY ( garage_code, vunit_id )
        REFERENCES vehicle_unit ( garage_code, vunit_id );

ALTER TABLE loan
    ADD CONSTRAINT vloan_renter FOREIGN KEY ( renter_no )
        REFERENCES renter ( renter_no );

---------- RESERVE ----------
CREATE TABLE reserve (
    garage_code                NUMBER(2) NOT NULL,
    vunit_id                   NUMERIC(6) NOT NULL,
    reserve_date_time_placed   DATE NOT NULL,
    renter_no                  NUMERIC (6) NOT NULL
);

COMMENT ON COLUMN reserve.garage_code IS
    'garage code identifier - identifies the garage code';
    
COMMENT ON COLUMN reserve.vunit_id IS
    'the vehicle identifier local id number';    

COMMENT ON COLUMN reserve.reserve_date_time_placed IS
    'the reserved vehicle date and time';    

COMMENT ON COLUMN reserve.renter_no IS
    'the identification id of the renter'; 

ALTER TABLE reserve ADD CONSTRAINT reserve_pk PRIMARY KEY ( garage_code, vunit_id, reserve_date_time_placed );

ALTER TABLE reserve
    ADD CONSTRAINT vreserve_garage_unit FOREIGN KEY ( garage_code, vunit_id )
        REFERENCES vehicle_unit ( garage_code, vunit_id );

ALTER TABLE reserve
    ADD CONSTRAINT vreserve_renter FOREIGN KEY ( renter_no )
        REFERENCES renter ( renter_no );

/*
Alter Tables
*/

ALTER TABLE loan
  DROP CONSTRAINT vloan_garage_unit;
  
ALTER TABLE reserve
  DROP CONSTRAINT vreserve_garage_unit;

drop table vehicle_unit purge;

drop table loan purge;

drop table reserve purge;

/* This drop statement is for table*/
drop table manager_garage;

/*
Inserting additional data

*/
INSERT INTO vehicle_detail VALUES (
    'sports-ute-449-12b',
    'Toyota Hilux SR Manual 4x2 MY14',
    'M',
    200.00,
    TO_DATE('2018','YYYY'),
    2.4,
    1
);

INSERT INTO vehicle_feature VALUES (
    1,
    'sports-ute-449-12b'
);

INSERT INTO vehicle_feature VALUES (
    10,
    'sports-ute-449-12b'
);

INSERT INTO vehicle_unit VALUES (
    10,
    1,
    50000,
    'R',
    'sports-ute-449-12b',
    'RD3161'
);

UPDATE garage
SET garage_count_vehicles = garage_count_vehicles + 1
WHERE garage_code = 10;

INSERT INTO vehicle_unit VALUES (
    11,
    2,
    50000,
    'R',
    'sports-ute-449-12b',
    'RD3141'
);

UPDATE garage
SET garage_count_vehicles = garage_count_vehicles + 1
WHERE garage_code = 11;

INSERT INTO vehicle_unit VALUES (
    12,
    3,
    50000,
    'R',
    'sports-ute-449-12b',
    'RD3000'
);

UPDATE garage
SET garage_count_vehicles = garage_count_vehicles + 1
WHERE garage_code = 12;

COMMIT;

/*
Creating Sequence

*/

CREATE SEQUENCE renter_seq START WITH 10 INCREMENT BY 1;

/*
Drop Sequence

*/

DROP SEQUENCE renter_seq;

/*
Insert renter Values

*/

INSERT INTO renter VALUES (renter_seq.nextval,
    'Van','DIESEL','22 Neerim Rd','Caulfield','3162','van@facebook.example','0423456789',
    (SELECT garage_code FROM garage WHERE garage.garage_name = 'Caulfield VIC'));
    
COMMIT;

/*
Insewrting reserve values

*/

INSERT INTO reserve VALUES (
    (SELECT garage_code FROM garage WHERE garage.garage_name = 'Melbourne Central VIC'),
    (SELECT vunit_id FROM vehicle_unit WHERE vehicle_insurance_id = 'sports-ute-449-12b' AND  garage_code = (SELECT garage_code FROM garage WHERE garage.garage_name = 'Melbourne Central VIC')),
    (to_date('May 4 2019, 04:00 P.M.','Month dd YYYY, HH:MI P.M.')),
    (renter_seq.currval)
);

COMMIT;

/*
Inseerting values for loans

*/

INSERT INTO loan VALUES (

    (SELECT garage_code FROM garage WHERE garage.garage_name = 'Melbourne Central VIC'),
    (SELECT vunit_id FROM vehicle_unit WHERE vehicle_insurance_id = 'sports-ute-449-12b' AND  garage_code = (SELECT garage_code FROM garage WHERE garage.garage_name = 'Melbourne Central VIC')),
    (to_date('May 11 2019, 02:00 P.M.','Month dd YYYY, HH:MI P.M.')),
    (to_date('May 18 2019, 02:00 P.M.','Month dd YYYY, HH:MI P.M.')),
    NULL,
    (renter_seq.currval)

);

COMMIT;

/*
Updating

*/

UPDATE loan
SET loan_actual_return_date = (to_date('May 18 2019, 02:00 P.M.','Month dd YYYY, HH:MI P.M.'))
WHERE vunit_id = (SELECT vunit_id FROM vehicle_unit WHERE vehicle_insurance_id = 'sports-ute-449-12b' AND  garage_code = (SELECT garage_code FROM garage WHERE garage.garage_name = 'Melbourne Central VIC'));


INSERT INTO loan VALUES (

    (SELECT garage_code FROM garage WHERE garage.garage_name = 'Melbourne Central VIC'),
    (SELECT vunit_id FROM vehicle_unit WHERE vehicle_insurance_id = 'sports-ute-449-12b' AND  garage_code = (SELECT garage_code FROM garage WHERE garage.garage_name = 'Melbourne Central VIC')),
    (to_date('May 18 2019, 02:00 P.M.','Month dd YYYY, HH:MI P.M.')),
    (to_date('May 24 2019, 02:00 P.M.','Month dd YYYY, HH:MI P.M.')),
    NULL,
    (renter_seq.currval)

);

COMMIT;


ALTER TABLE vehicle_unit 
    ADD vehicle_condition CHAR(1) DEFAULT 'G' NOT NULL ;
    
ALTER TABLE vehicle_unit
    ADD CONSTRAINT v_condition_chk CHECK ( vehicle_condition IN (
        'M',
        'W',
        'G'
    ) );


COMMIT;


ALTER TABLE loan 
    ADD garage_returned NUMERIC(2);
    
UPDATE loan
SET garage_returned = garage_code;


COMMIT;

/*
Creating garage maanger table
*/

CREATE TABLE manager_garage(
    man_id                     NUMBER(2),
    garage_code                NUMBER(2),
    man_spec                   VARCHAR2(50)
);

COMMENT ON COLUMN manager_garage.man_id IS
    'manager id identifier - identifies the manager';

COMMENT ON COLUMN manager_garage.garage_code IS
    'garage code identifier - identifies the garage code';

COMMENT ON COLUMN manager_garage.man_spec IS
    'manager specialisation - shows which specialisation manager is managing';


ALTER TABLE manager_garage ADD CONSTRAINT m_garage_pk PRIMARY KEY ( man_id, garage_code);

ALTER TABLE manager_garage
    ADD CONSTRAINT m_garage_fk FOREIGN KEY ( garage_code )
        REFERENCES garage ( garage_code );
        
ALTER TABLE manager_garage
    ADD CONSTRAINT m_id_fk FOREIGN KEY ( man_id )
        REFERENCES manager ( man_id ); 


INSERT INTO manager_garage VALUES (
    1,
    (SELECT garage_code FROM garage WHERE garage_email = 'caulfield@rdbms.example.com'),
    'Bikes, Motorcars and Sportscars'

);


INSERT INTO manager_garage VALUES (
    1,
    (SELECT garage_code FROM garage WHERE garage_email = 'melbournec@rdbms.example.com'),
    'Sportscars'

);

INSERT INTO manager_garage VALUES (
    2,
    (SELECT garage_code FROM garage WHERE garage_email = 'southy@rdbms.example.com'),
    'Bikes, Motorcars and Sportscars'

);


INSERT INTO manager_garage VALUES (
    2,
    (SELECT garage_code FROM garage WHERE garage_email = 'melbournec@rdbms.example.com'),
    'Bikes and Motorcars'

);

COMMIT;