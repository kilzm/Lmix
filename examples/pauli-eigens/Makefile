CFLAGS=-Wall -Wextra `pkg-config --cflags eigen3`

all: pauli_eigens

pauli_eigens: pauli_eigens.o
	${CXX}  -o $@ $<

pauli_eigens.o: pauli_eigens.cpp
	${CXX} $(CFLAGS) -c $<

.PHONY: clean
clean:
	rm -f pauli_eigens pauli_eigens.o
