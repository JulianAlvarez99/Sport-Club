USE Clubdeportivo;
DELETE FROM A_CARGO_DE;


insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (786584, 141);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (807376, 142);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (867976, 143);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (846978, 144);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (727967, 145);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (806584, 146);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (777765, 147);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (897971, 148);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (908577, 149);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (708584, 150);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (717377, 151);
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (676578, 152);

#Probar el trigger, verifica que un profesional este capacitado para realizar una actividad
insert into A_CARGO_DE (COD_ACTIVIDAD,LEGAJO) values (777765, 152);
