FFLAGS=-O3
MKLFLAGS=-L${MKL_BASE}/lib -lmkl_gf_lp64 -lmkl_core -lm -ldl -i8
MKLSEQ=-qmkl=sequential
MKLPAR=-liomp5 -qmkl=parallel -lpthread

TARGET=mat_mult_seq
TARGET_MP=mat_mult_par

OBJ=mkl_mat_mult.o

all: $(TARGET_MP)

$(TARGET): $(OBJ)
	$(FC) $(FFLAGS) -o $@ $^ $(MKLFLAGS) $(MKLSEQ)

$(TARGET_MP): $(OBJ)
	$(FC) $(FFLAGS) -o $@ $^ $(MKLFLAGS) $(MKLPAR)

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

clean:
	rm -f $(TARGET) $(TARGET_MP) $(OBJ)
