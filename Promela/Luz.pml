
//Jose Juan Cabrera Higueras
//Teresa Vidal Hortal


//EJERCICIO LUZ:

// LTL

ltl spec1 {
  [] (presencia -> <> (Luz==ON))
}
ltl spec2 {
  [] (((Luz==ON) && (time>deadline)) -> <> (Luz==OFF))
}
ltl spec3 {
  [] (((Luz==OFF) && boton_luz)-> <> (Luz==ON))
}
ltl spec4 {
  [] (((Luz==ON) && boton_luz)-> <> (Luz==OFF))
}

// SPIN

mtype={ON,OFF};

int time=0;
byte deadline =2;
bit Alarma;
bit presencia;
bit boton_luz;
bit Code_OK;
mtype Luz;

active proctype fsm(){
  Luz=OFF;
  do
  :: Luz==OFF-> atomic{
    if
    :: presencia -> Luz=ON; printf("enciende"); presencia=0; time=0;
    :: boton_luz -> Luz=ON; printf("enciende"); boton_luz=0; time=0;
    fi }
  :: Luz==ON -> atomic{
    if
    :: presencia -> printf("enciende"); presencia=0; Luz=ON;
    :: boton_luz -> printf("apagar"); boton_luz=0; Luz=OFF;
    :: time>deadline -> printf ("apagar"); Luz=OFF;
    fi}
  od
}

active proctype entorno() {
  do
  ::if
    :: presencia = 1;
    :: boton_luz = 1;
    :: time = 2;
    :: skip;
    fi ;
    printf ("Luz = %e, presencia = %d, boton_luz = %d\n", Luz, presencia, boton_luz)
  od
}

/*
active proctype codigo() {
  do
  :: if
     :: Code_OK=0;
     :: Code_OK=1;
     :: skip;
     fi ; printf ("Code_OK = %d\n", Code_OK)
  od
}

active proctype alarma() {
  do
  :: if
     :: Alarma =1;
     :: Alarma =0;
     :: skip;
     fi ; printf ("Alarma = %d\n", Alarma)
  od
}
*/
