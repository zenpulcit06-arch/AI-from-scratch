# 🤖 AI From Scratch: Polynomial Logistic Regression (Fortran)

> Part of a series on building Artificial Intelligence from the ground up using low-level languages — no Scikit-Learn, no TensorFlow, just math and code.

---

## 📌 Overview

This repository implements a **Non-Linear Binary Classifier** that combines:

- **Logistic Regression** — for probabilistic decision-making
- **Polynomial Feature Expansion** — to handle non-linear data patterns

By using **Fortran 2008/2018**, this project focuses on understanding the mathematical and computational foundations of machine learning at the lowest practical level.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| **Polynomial Expansion** | Transforms 1D input data into an $N$-degree feature matrix |
| **Z-Score Standardization** | Scales features to mean = 0, S.D. = 1 to prevent numerical overflow |
| **Gradient Descent** | Optimized using Fortran's `do concurrent` for parallel-ready performance |
| **Modular Architecture** | Math engine (`Logistic`) and feature generator (`Polynomial`) are fully separated |

---

## 🛠️ Design Choices

### 1. Why Fortran?

While C is the common choice for low-level work, Fortran was selected for its:

- **Native multidimensional array handling** — no pointer arithmetic required
- **Clean mathematical syntax** — expressions like $W \cdot X + b$ map directly to code
- **High-performance numerical operations** — built for scientific computing

### 2. Feature Scaling (Standardization)

Polynomial features ($x,\ x^2,\ x^3,\ \dots$) grow at vastly different magnitudes. Without standardization, high-degree terms dominate the gradient and cause the model to **diverge during training**.

The `standardize` subroutine scales all features before they reach the optimizer.

### 3. Activation Function

A **Sigmoid** activation function transforms the raw linear output into a probability in the range $(0, 1)$. This converts the curve-fitter into a classifier capable of making binary "Yes/No" decisions.

$$\sigma(z) = \frac{1}{1 + e^{-z}}$$

---

## ⚠️ Mistakes & Lessons Learned

<details>
<summary><strong>The <code>main</code> Conflict</strong></summary>

**Mistake:** `program main` was defined in both the module file and the application file, causing a *"multiple definition of main"* linker error.

**Fix:** Separated all math logic into pure modules; kept execution logic in a single `program` file.

</details>

<details>
<summary><strong>Compilation Flag Errors</strong></summary>

**Mistake:** Used the `-I` flag pointing directly to `.f90` and `.exe` files.

**Fix:** `-I` is for directories containing compiled `.mod` files. Compiling the module and program together in one command is simpler and avoids this entirely.

</details>

<details>
<summary><strong>Memory Management</strong></summary>

**Mistake:** Attempted to access `x_input` and `weight` arrays before allocating them, causing runtime crashes.

**Fix:** Dynamic allocation with `allocate()` is now performed *after* the user provides the polynomial degree and sample size.

</details>

<details>
<summary><strong>Hyperparameter Tuning</strong></summary>

**Mistake:** A learning rate of `0.001` was too slow for the small dataset — the model barely converged.

**Fix:** A rate of `0.1` provided significantly faster convergence for the "U-shape" test case.

</details>

---

## 🏗️ How to Compile

Ensure `gfortran` is installed (via MinGW/MSYS2 on Windows, or natively on Linux/macOS).

```powershell
gfortran -O3 ..\linear_regression\logistic_regression.f90 .\polynomialreg.f90 -o polyreg.exe
```

---

## 📈 Example Result — The U-Shape Test

The model successfully learns non-linear patterns that standard linear regression cannot capture.

**Input Data:**

| $x$ | Label |
|-----|-------|
| 1   | 0     |
| 5   | 1     |
| 9   | 0     |

**Logic:** The positive class is concentrated in the center — a classic non-linear boundary.

**Result:** Achieved a final loss of $\approx 0.07$ with high classification confidence on all three points.

---

## 🗺️ Roadmap

- [ ] Implement Vectorized Backpropagation
- [ ] Add Multi-class Classification support (Softmax)
- [ ] Link with BLAS/LAPACK for optimized matrix operations

---

## 🔗 Part of the *AI From Scratch* Series

This project is one step in a larger journey to build AI primitives from first principles using low-level languages. Each module builds on the last, with full transparency into mistakes, corrections, and design rationale.