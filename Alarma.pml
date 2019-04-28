
//Jose Juan Cabrera Higueras
//Teresa Vidal Hortal

// EJERCICIO Alarma

// LTL

ltl spec1 {[](( ((Alarma==ON)W(Sirena==1)) && (presencia==1) && (Code_OK==0) ) -> <> (Sirena ==1) )}
ltl spec2 {[](( (Alarma==ON) && (Code_OK==1) )-> <> ((Alarma ==OFF) && (Sirena== 0)) )}
ltl spec3 {[](( (Alarma==OFF)&& (Code_OK==1)) -> <> (Alarma ==ON))}
ltl spec4 {[](((Alarma== ON) && (Sirena ==1) && (Code_OK==1))-> <> ((Alarma == OFF)&&(Sirena ==0)))}


// SPIN


mtype={ON,OFF};

mtype Alarma;
bit Code_OK;
bit presencia;
bit Luz;
bit Sirena;

active proctype fsm(){
  Alarma = OFF;
  do
  :: Alarma == ON -> atomic {
    if
    :: ((presencia==1) && (Sirena==0)) -> presencia=0; Sirena=1; printf("Sirena ON");
    :: (Code_OK == 1) -> Alarma=OFF; Sirena=0;  Code_OK =0; printf("Alarma y Sirena OFF");
    fi }
  :: Alarma == OFF -> atomic {
    if
    :: (Code_OK== 1) -> Alarma = ON; Code_OK =0; Sirena=0; printf ("Alarma ON");
    fi }
  od
}

active proctype entorno() {
  do
  ::if
      :: presencia = 1;
      :: Code_OK=1;
      :: skip;
    fi; printf ("presencia = %d, Alarma= %d, Sirena=%d, Code_OK =%d ;\n", presencia, Alarma, Sirena, Code_OK )
  od
}

/*
active proctype luz() {
  do
  ::if
      :: Luz=1;
      :: skip;
    fi; printf ("Luz = %d\n", Luz)
  od
}
active proctype codigo() {
  do
  ::if
      :: Code_OK=1;
      :: skip;
    fi; printf ("Code_OK = %d\n", Code_OK)
  od

}
*/
