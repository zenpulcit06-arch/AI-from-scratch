# 🤖 AI From Scratch: Vectorized Polynomial & Logistic Regression (Fortran)

**Author:** Pulkit Jain — BITS Pilani |  Physics

> A low-level Machine Learning engine built in Modern Fortran — no PyTorch, no Scikit-Learn, just raw matrix calculus, gradient descent, and feature engineering.

---

## 📌 Overview

This repository implements a **Non-Linear Binary Classifier** — a single-neuron engine capable of learning non-linear decision boundaries using:

- **Logistic Regression** — probabilistic decision-making via Sigmoid activation
- **Polynomial Feature Mapping** — transforms 1D input into an $N$-dimensional feature space
- **L2 Regularization (Ridge)** — prevents overfitting on high-degree polynomial models
- **Vectorized Matrix Operations** — the entire dataset is treated as a matrix $X$, with weights as a vector $w$

The engine moves beyond linear classification by combining these techniques into a clean, modular Fortran architecture.

---

## 📂 Repository Structure

```
AI-form-scratch/
├── linear_regression/
│   └── logistic_regression.f90   # Core math module: Fit, Standardize, Sigmoid, Accuracy
├── polynomial_regression/
│   └── polynomialreg.f90         # Main orchestrator & polynomial feature generator
├── makefile                      # Build system
└── README.md
```

---

## ✨ Key Features

| Feature | Description |
|---|---|
| **Polynomial Expansion** | Transforms scalar input $x$ into $(x, x^2, \dots, x^D)$ — a $D$-dimensional feature space |
| **Vectorized Predictions** | Computes $\hat{y} = \sigma(Xw + b)$ as a single matrix operation |
| **Z-Score Standardization** | Scales all features to mean $= 0$, S.D. $= 1$ to prevent gradient explosion |
| **L2 Regularization** | Adds a weight-decay penalty to the loss to combat overfitting |
| **Gradient Descent** | Optimized with Fortran's `do concurrent` for parallel-ready performance |
| **Modular Architecture** | Math engine (`logistic_regression`) and feature generator (`polynomialreg`) fully separated |

---

## 🛠️ Design Choices & Architecture

### 1. Why Fortran?

Python is standard for AI, but Fortran was chosen for its native high-performance array handling. Built-in functions like `matmul()`, `transpose()`, and `do concurrent` allow this engine to perform matrix operations at near-hardware speeds — a natural precursor to future GPU implementation.

### 2. Multivariate Matrix Logic (Vectorization)

Instead of looping through individual samples, the engine treats the entire dataset as a single matrix operation:

$$\hat{y} = \sigma(Xw + b)$$

This eliminates per-sample loops and enables significant computational speedups on large datasets.

### 3. Polynomial Feature Mapping

To solve non-linear problems (like the parabola test), the `Polynomial_reg` module transforms a scalar input $x$ into a $D$-dimensional vector:

$$x \rightarrow (x,\ x^2,\ x^3,\ \dots,\ x^D)$$

This allows a linear classifier to find **non-linear decision boundaries** in the original input space.

### 4. L2 Regularization (Ridge)

High-degree polynomials are prone to overfitting — they become too "jagged" trying to pass through every data point. L2 regularization adds a penalty term to both the loss and the gradient:

$$dw = \frac{1}{m} X^T(\hat{y} - y) + \frac{\lambda}{m}w$$

This **weight decay** forces the model to prefer smaller weights, producing smoother, more generalizable curves.

### 5. Z-Score Standardization

Polynomial terms like $x^{10}$ can be exponentially larger than $x^1$. Without scaling, the gradient explodes and training fails with `NaN`. The saved `mean` and `std` from training are also applied at prediction time so the input speaks the same language as the learned weights.

### 6. Sigmoid Activation

$$\sigma(z) = \frac{1}{1 + e^{-z}}$$

Maps any real-valued output to a probability in $(0, 1)$, turning the regression into a binary classifier.

---

## 🏗️ How to Compile

Ensure `gfortran` is installed (via MinGW/MSYS2 on Windows, or natively on Linux/macOS).

**Using Make:**
```bash
make
```

**Manual compilation:**
```bash
gfortran -O3 linear_regression/logistic_regression.f90 polynomial_regression/polynomialreg.f90 -o polyreg.exe
```

---

## 📊 Test Case: The Parabola

The engine was verified on a dataset where $y = 1$ at the extremes and $y = 0$ in the center — a non-linear boundary no linear model can learn.

| $x$ | Label |
|-----|-------|
| 1   | 0     |
| 5   | 1     |
| 9   | 0     |

**Result:** The model correctly suppressed the linear weight (Weight $\approx 0$) and assigned a strong positive weight to the $x^2$ term, confirming it learned the parabolic structure.

| Metric | Value |
|--------|-------|
| Initial Loss | $\approx 0.69$ (random baseline) |
| Final Loss | $\approx 0.08$ |

---

## ⚠️ Mistakes & Lessons Learned

<details>
<summary><strong>1. "Actual vs Formal" Argument Mismatch</strong></summary>

**Error:** The `main` program passed `lamda` to `subroutine fit`, but the subroutine interface wasn't updated to receive it — causing a silent mismatch.

**Fix:** Synchronized the module interface and used a clean-recompile strategy to ensure `.mod` files were fully regenerated.

</details>

<details>
<summary><strong>2. Scalar Penalty in the Gradient</strong></summary>

**Error:** Used `sum(weight)` in the L2 gradient calculation — this collapsed all weights into one scalar, destroying per-feature precision.

**Fix:** Corrected to use the full vector `weight` for an element-wise penalty.

</details>

<details>
<summary><strong>3. The <code>main</code> Conflict</strong></summary>

**Error:** `program main` was defined in both the module file and the application file, causing a *"multiple definition of main"* linker error.

**Fix:** Separated all math logic into pure modules; kept execution logic in a single `program` file.

</details>

<details>
<summary><strong>4. Memory Allocation Crashes</strong></summary>

**Error:** Attempted to access `x_poly` and `weight` arrays before the user had provided `degree` and `sample_size`.

**Fix:** All `allocate()` calls now happen after runtime input is collected.

</details>

<details>
<summary><strong>5. Standardization Not Applied at Prediction Time</strong></summary>

**Error:** The model predicted on raw input values, while the weights were trained on standardized features — a systematic mismatch.

**Fix:** The `mean` and `std` computed during training are saved and reapplied to every input at prediction time.

</details>

<details>
<summary><strong>6. Compilation Flag Errors</strong></summary>

**Error:** Used the `-I` flag pointing to `.f90` and `.exe` files directly.

**Fix:** `-I` is for directories containing compiled `.mod` files. Compiling the module and program together in a single command is cleaner.

</details>

---

## 🗺️ Roadmap

- [x] Phase 1 — Polynomial Logistic Regression with L2 Regularization
- [ ] Phase 2 — Multi-layer Neural Network (Hidden Layers)
- [ ] Phase 3 — Vectorized Backpropagation algorithm
- [ ] Phase 4 — Multi-class Classification (Softmax)
- [ ] Phase 5 — CUDA/GPU acceleration for large matrices
- [ ] Phase 6 — Link with BLAS/LAPACK for optimized matrix operations

---

## 🔗 Part of the *AI From Scratch* Series

This project is one step in a larger journey to build AI primitives from first principles using low-level languages. Each module builds on the last — with full transparency into design decisions, mathematical derivations, and hard-won lessons from real bugs.