
//Jose Juan Cabrera Higueras
//Teresa Vidal Hortal

//// EJERCICIO CODIGO

ltl spec1 {[](((deadline_code)&& (Actual==2)&&(input[0]==Secret[0])&&(input[1]==Secret[1])&&(input[2]==Secret[2]))-> <>(Code_OK==1))}
ltl spec2 {[](((deadline_code)&& (Actual==2)&&((input[0]!=Secret[0])||(input[1]!=Secret[1])||(input[2]!=Secret[2])))-> <>(Code_OK==0))}


mtype = {ON};
mtype Code;
int input[3];
int Secret[3];
int Actual=0;
byte deadline_code;
bit boton_codigo;
bit Code_OK;
bit Alarma;
bit Luz;
bit flag_puls;



active proctype fsm(){
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

active proctype entorno(){
  do
  ::if
    :: boton_codigo=1;
    :: deadline_code=1;
    :: skip;
    fi; printf ("boton_codigo= %d, deadline_code =%d,Code_OK = %d, Actual= %d, input[0]= %d , input[1]= %d , input[2]= %d \n", boton_codigo ,deadline_code, Code_OK, Actual, input[0], input[1], input[2]);
  od
}

/* active proctype alarma() {
   do
   ::if
     :: Alarma=0;
     :: Alarma=1;
     :: skip;
     fi; printf ("alarma = %d\n", Alarma);
   od
 }
 active proctype luz() {
   do
   ::if
     :: Luz=1;
     :: Luz=0;
     :: skip;
     fi; printf ("Luz = %d\n", Luz)
   od
 }
*/
