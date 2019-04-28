CC=gcc
#CFLAGS=-g -Wall -O -I. -DNDEBUG
CFLAGS = -Wall -g -O
all: main_completo

main_completo: main_completo.o reactor.o fsm.o 
#interruptor.o

clean:
	$(RM) *.o *~ main_completo


#CFLAGS = -Wall -g -O

#all: q

#q: q.o fsm.o timeval_helper.o luz.o alarma.o
