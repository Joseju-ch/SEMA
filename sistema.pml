
//Jose Juan Cabrera Higueras
//Teresa Vidal Hortal

//SISTEMA COMPLETO

/////////LTL

//LUZ

ltl spec1 { [] (presencia_luz -> <> (Luz==ON)) }
ltl spec2 { [] (((Luz==ON) && (deadline)) -> <> (Luz==OFF)) }
ltl spec3 { [] (((Luz==OFF) && boton_luz)-> <> (Luz==ON)) }
ltl spec4 { [] (((Luz==ON) && boton_luz)-> <> (Luz==OFF)) }

// ALARMA

ltl spec5 {[](( ((Alarma==ON)W(Sirena==1)) && (presencia==1) && (Code_OK==0) ) -> <> (Sirena ==1) )}
ltl spec6 {[](( (Alarma==ON) && (Code_OK==1) )-> <> ((Alarma ==OFF) && (Sirena== 0)) )}
ltl spec7 {[](( (Alarma==OFF)&& (Code_OK==1)) -> <> (Alarma ==ON))}
ltl spec8 {[](((Alarma== ON) && (Sirena ==1) && (Code_OK==1))-> <> ((Alarma == OFF)&&(Sirena ==0)))}

// CODIGO

ltl spec9 {[](((deadline_code)&& (Actual==2)&&(input[0]==Secret[0])&&(input[1]==Secret[1])&&(input[2]==Secret[2]))-> <>(Code_OK==1))}
ltl spec10 {[](((deadline_code)&& (Actual==2)&&((input[0]!=Secret[0])||(input[1]!=Secret[1])||(input[2]!=Secret[2])))-> <>(Code_OK==0))}

// Estados
mtype={ON,OFF};

mtype Alarma, Luz, Code;

////////// VARIABLES:

int input[3];
int Secret[3];
int Actual=0;
int time=0;
byte deadline =0;
bit deadline_code=0;
bit presencia;
bit boton_luz;
bit boton_codigo;
bit Code_OK;
bit Sirena;
bit flag_puls;
bit presencia_luz;

////////// Maquinas

// LUZ

active proctype luz(){
  Luz=OFF;
  do
  :: Luz==OFF-> atomic{
    if
    :: presencia_luz -> Luz=ON; printf("LUZ ON"); presencia_luz=0; time=0;
    :: boton_luz -> Luz=ON; printf("LUZ ON"); boton_luz=0; time=0;
    fi }
  :: Luz==ON -> atomic{
    if
    :: presencia_luz -> printf("LUZ ON"); presencia_luz=0; Luz=ON;
    :: boton_luz -> printf("LUZ OFF"); boton_luz=0; Luz=OFF;
    :: deadline -> printf ("LUZ OFF"); Luz=OFF;
    fi}
  od
}


// ALARMA

active proctype alarma(){
  Alarma = OFF;
  do
  :: Alarma == ON -> atomic {
    if
    :: ((presencia==1) && (Sirena==0)) -> presencia=0; Sirena=1; printf("Sirena ON");
    :: (Code_OK == 1) -> Alarma=OFF; Sirena=0;  Code_OK =0; printf("Alarma y Sirena OFF"); presencia=0;
    fi }
  :: Alarma == OFF -> atomic {
    if
    :: (Code_OK== 1) -> Alarma = ON; Code_OK =0; Sirena=0; printf ("Alarma ON"); presencia=0;
    fi }
  od
}

// CODIGO

active proctype codigo(){
  Code = ON;
  Secret[0]=7;
  Secret[1]=5;
  Secret[2]=9;
  input[0]=0;
  input[1]=0;
  input[2]=0;
  Actual=0;
  flag_puls=0;
  do
  :: (Code==ON) -> atomic {
    if
    ::((boton_codigo) && (!deadline_code) && (input[Actual]<9)) ->  input[Actual]=input[Actual]+1; boton_codigo=0; deadline_code=0;Code_OK=0; flag_puls=1;
    ::((boton_codigo) && (!deadline_code) && (input[Actual]==9))-> input[Actual]=0; boton_codigo=0; deadline_code=0; Code_OK=0; flag_puls=1;
    ::((deadline_code) && (Actual<2) && (flag_puls==1)) ->  printf("Siguiente digito"); Actual=Actual+1; Code_OK=0; deadline_code=0; boton_codigo=0; flag_puls=0;
    ::((deadline_code) && (Actual==2) && (flag_puls==1) && ((Secret[0]==input[0])&&(Secret[1]==input[1])&&(Secret[2]==input[2]))) ->  printf("CODIGO OK");input[0]=0; input[1]=0; input[2]=0; Actual=0; Code_OK=1; deadline_code=0; boton_codigo=0; flag_puls=0;
    ::((deadline_code) && (Actual==2) && (flag_puls==1) && ((Secret[0]!=input[0])||(Secret[1]!=input[1])||(Secret[2]!=input[2]))) ->  printf("CODIGO NOK"); input[0]=0; input[1]=0; input[2]=0; Actual=0; Code_OK=0; boton_codigo=0; deadline_code=0; flag_puls=0;
    fi }
  od
 }


////////ENTORNO

active proctype entorno(){
  do
  ::if
    :: boton_codigo=1;
    :: boton_luz=1;
    :: presencia=1;
    :: presencia_luz=1;
    :: deadline=5;
    :: deadline_code=1;
    :: skip;
    fi; time=time+1;  printf ("boton_codigo= %d,boton_luz= %d deadline_code =%d,Code_OK = %d, Actual= %d, input[0]= %d , input[1]= %d , input[2]= %d \n", boton_codigo, boton_luz ,deadline_code, Code_OK, Actual, input[0], input[1], input[2]);
  od
}
