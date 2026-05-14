# Variables
FC = gfortran
FFLAGS = -O3
MODDIR = modfiles
TARGET = ai_engine

SOURCES = ./linear_regression/logistic_regression.f90 ./polynomial_regression/polynomialreg.f90

# Default target
all: $(TARGET)

$(TARGET): $(SOURCES)
	if not exist $(MODDIR) mkdir $(MODDIR)
	$(FC) $(FFLAGS) $(SOURCES) -o $(TARGET) -J$(MODDIR) -Wall -fcheck=all

# Clean up build artifacts (Windows syntax)
clean:
	if exist $(TARGET).exe del $(TARGET).exe
	if exist $(MODDIR) rmdir /s /q $(MODDIR)