// Jose Juan Cabrera Higueras
// Teresa Vidal Hortal 

#include <stdio.h>
#include "reactor.h"
#include "fsm.h"

#include <assert.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/select.h>
#include <signal.h>

#include <sys/time.h>
#include <time.h>

#define T 200 //ms
#define T_luz 5000 //ms 	5s --- Cambiar a 60000 = 60 s del enunciado original 
#define T_pulsacion 1000 //ms 	1s
 
/*
#define GPIO_boton_alarma	2
#define GPIO_boton_luz	6
#define GPIO_presencia	3
#define GPIO_luz	4
#define GPIO_sirena	 5
*/

static int presencia_fsm1=0;
static int presencia_fsm2=0;
static int boton=0; 
static int boton_luz=0; 
static int code_ok=0;

static int secret[]={7,5,9};
static int entrada[]={0,0,0};

static int actual=0;

static struct timeval next_luz;
static struct timeval next_puls;

int flag_puls=0;

/*static void boton_alarma_isr (void) { boton = 1; }
static void boton_luz_isr (void) { boton_luz = 1; }

static void presencia_isr (void) { 
	presencia_fsm1 = 1; 
	presencia_fsm2 = 1;
}*/

enum luz_state {
	luz_on,
	luz_off
};

enum alarma_state {
	alarma_on,
	alarma_off
};
enum codigo_state {
	codigo
};

// CONDICION DE GUARDA
int f_presencia_fsm1(fsm_t* this){
		return presencia_fsm1;
}
int f_boton_luz(fsm_t* this){
		return boton_luz;
}
int f_timeout_luz(fsm_t* this){
		struct timeval now;
		gettimeofday(&now, NULL);
		return timeval_less (&next_luz, &now);
}

int f_code_ok(fsm_t* this){
		return code_ok;
}
int f_presencia_fsm2(fsm_t* this){
		return presencia_fsm2;
}


int f_corta(fsm_t* this){
	return ((boton==1) && (entrada[actual]<9));
}
int f_corta10(fsm_t* this){	
	return ((boton==1) && (entrada[actual]==9));
}
int f_larga_ok(fsm_t* this){
	struct timeval now;
	gettimeofday(&now, NULL);
	return (((timeval_less (&next_puls, &now)))  && (actual<2) && (flag_puls==1));
}
int f_larga_nok(fsm_t* this){
	struct timeval now;
	gettimeofday(&now, NULL);
	return (((timeval_less (&next_puls, &now))) && ((entrada[0]!=secret[0]) || (entrada[1]!=secret[1]) || (entrada[2]!=secret[2])) && (actual==2) && (flag_puls==1));
}
int f_larga_final(fsm_t* this){
	struct timeval now;
	gettimeofday(&now, NULL);
	return ((timeval_less (&next_puls, &now)) && (entrada[0]==secret[0]) && (entrada[1]==secret[1]) && (entrada[2]==secret[2]) && (actual==2) && (flag_puls==1));
}


// SALIDA
void encender_luz(fsm_t* this){
	struct timeval timeout = { T_luz / 1000, (T_luz % 1000) * 1000 };
	printf("Encender luz \n ");
	//digitalWrite (GPIO_luz, 1);
	presencia_fsm1=0;
	boton_luz=0;
	gettimeofday (&next_luz,NULL);
	timeval_add (&next_luz, &next_luz, &timeout);
}
void apagar_luz(fsm_t* this){
	printf("Apagar luz \n");
	//digitalWrite (GPIO_luz, 0);
	boton_luz=0;
}


void f_alarma_on(fsm_t* this){
	printf("Alarma ON \n");
	presencia_fsm2=0;
	code_ok=0;
}
void f_alarma_off(fsm_t* this){
	printf("Alarma OFF \n");
	printf("Sirena OFF \n");
	//digitalWrite (GPIO_sirena, 0);
	presencia_fsm2=0;
	code_ok=0;
}
void f_sirena(fsm_t* this){
	printf("Sirena ON \n");
	//digitalWrite (GPIO_sirena, 1);
	presencia_fsm2=0;
}


void f_actualizar(fsm_t* this){
	struct timeval timeout2 = { T_pulsacion / 1000, (T_pulsacion % 1000) * 1000 };
	entrada[actual]+=1;
	boton=0; 
	printf("Pulsaciones: %d   ",entrada[actual]);
	printf("Actual: %d\n ", actual);
	gettimeofday (&next_puls,NULL);
	timeval_add (&next_puls, &next_puls, &timeout2);
	code_ok=0;
	flag_puls=1;
}
void f_actualizar0(fsm_t* this){
	struct timeval timeout2 = { T_pulsacion / 1000, (T_pulsacion % 1000) * 1000 };
	entrada[actual]=0;
	boton=0; 
	printf("Pulsaciones: %d   ",entrada[actual] );
	printf("Actual: %d\n ", actual); 
	gettimeofday (&next_puls,NULL);
	timeval_add (&next_puls, &next_puls, &timeout2);
	code_ok=0;
	flag_puls=1;
}
void f_actualizar_input(fsm_t* this){
	actual+=1;
	code_ok=0;
	printf("Actual actualizada: %d \n",actual );
	flag_puls=0;
}
void f_actualizar_input0(fsm_t* this){
	actual=0;
	entrada[0]=0;
	entrada[1]=0;
	entrada[2]=0;
	code_ok=0;
	printf("Codigo erroneo \n" );
	printf("entrada[0]= %d  ", entrada[0]);
	printf("entrada[1]= %d  ", entrada[1]);
	printf("entrada[2]= %d ", entrada[2]);
	printf("flag_puls= %d \n", flag_puls);
	flag_puls=0;
}
void f_actualizar_ok(fsm_t* this){
	actual=0;
	entrada[0]=0;
	entrada[1]=0;
	entrada[2]=0;
	printf("Codigo OK \n ");
	code_ok=1;
	flag_puls=0;
}



fsm_t* fsm_new_luz(){
	static struct fsm_trans_t tt1[]={
		{luz_off, f_presencia_fsm1, luz_on, encender_luz },
		{luz_off, f_boton_luz, luz_on, encender_luz },
		{luz_on, f_boton_luz, luz_off, apagar_luz },
		{luz_on, f_presencia_fsm1, luz_on, encender_luz },
		{luz_on, f_timeout_luz, luz_off, apagar_luz },			
		{-1, NULL, -1, NULL },
	};
	fsm_t* this =fsm_new(tt1);
	return this;
}
fsm_t* fsm_new_alarma(){
	static struct fsm_trans_t tt2[]={
		{alarma_off, f_code_ok, alarma_on, f_alarma_on },
		{alarma_on, f_presencia_fsm2, alarma_on, f_sirena },
		{alarma_on, f_code_ok, alarma_off, f_alarma_off },
		{-1, NULL, -1, NULL },
	};
	fsm_t* this =fsm_new(tt2);
	return this;
}
fsm_t* fsm_new_codigo(){
	static struct fsm_trans_t tt3[]={
		{codigo, f_corta, codigo, f_actualizar},
		{codigo, f_corta10, codigo, f_actualizar0},
		{codigo, f_larga_ok, codigo, f_actualizar_input},
		{codigo, f_larga_nok, codigo, f_actualizar_input0},
		{codigo, f_larga_final, codigo, f_actualizar_ok},
		{-1, NULL, -1, NULL },
	};
	fsm_t* this =fsm_new(tt3);
	return this;
}


void delay_until (struct timeval* next_activation)
{
  struct timeval now, timeout;
  gettimeofday (&now, NULL);
  timeval_sub (&timeout, next_activation, &now);
  select (0, NULL, NULL, NULL, &timeout);
}


struct event_handler_fsm_t {
	struct event_handler_t eh;
	fsm_t* fsm;
	int period;
};

typedef struct event_handler_fsm_t event_handler_fsm_t;
struct timeval time1, time2;

static void eh_fsm_run (struct event_handler_t* this)
{
	event_handler_fsm_t* eh = (event_handler_fsm_t*) this;
	
	/*
	//////Parte para calcular los tiempos C/////
	struct timeval time1, time2;
	gettimeofday (&time1, NULL);*/
	fsm_fire(eh->fsm);
	/*gettimeofday (&time2, NULL);
	timeval_sub(&time2,&time2,&time1);
	printf("Tiempo: %ld\n", (time2.tv_usec));*/
	
	struct timeval timeout  = { eh->period / 1000, (eh->period % 1000) * 1000 };
	timeval_add (&this->next_activation, &this->next_activation, &timeout);
}

EventHandler* luz_eh_new (int prio)
{
	event_handler_fsm_t* eh = (event_handler_fsm_t*) malloc(sizeof (event_handler_fsm_t));
	event_handler_init (&eh->eh, prio, eh_fsm_run);
	eh->fsm = fsm_new_luz();
	eh->period = T;
	return (EventHandler*) eh;
}
EventHandler* alarma_eh_new (int prio)
{
	event_handler_fsm_t* eh = (event_handler_fsm_t*) malloc(sizeof (event_handler_fsm_t));
	event_handler_init (&eh->eh, prio, eh_fsm_run);
	eh->fsm = fsm_new_alarma();
	eh->period = T;
	return (EventHandler*) eh;
}
EventHandler* codigo_eh_new (int prio)
{
	event_handler_fsm_t* eh = (event_handler_fsm_t*) malloc(sizeof (event_handler_fsm_t));
	event_handler_init (&eh->eh, prio, eh_fsm_run);
	eh->fsm = fsm_new_codigo();
	eh->period = T;
	return (EventHandler*) eh;
}


void chk_stdin () {
	char buf[256];
	struct timeval timeout = {0,0};
	fd_set rdset;
	FD_ZERO (&rdset); 
	FD_SET (0, &rdset);
	if (select (1, &rdset, NULL, NULL, &timeout) > 0) {
		    fgets (buf, 256, stdin);
			if ((buf[0])!='\n'){
				switch (buf[0]) {
					case 'c': 
						boton=1; 
						printf("boton codigo \n"); 
						break;
					case 'l': 
						boton_luz=1; 
						printf("boton luz \n");  
						break;
					case 'p': 
						presencia_fsm1=1; 
						presencia_fsm2=1; 
						printf("presencia \n");  
						break;
				}
			}
	}
}


int main (){
	  
  EventHandler* luz_eh = luz_eh_new(3);
  EventHandler* alarma_eh =alarma_eh_new(1);
  EventHandler* codigo_eh =codigo_eh_new(2);
  
  reactor_init ();

  reactor_add_handler (luz_eh);
  reactor_add_handler (alarma_eh);
  reactor_add_handler (codigo_eh);
  
  while (1) {
    reactor_handle_events ();
	chk_stdin ();
  }
}
