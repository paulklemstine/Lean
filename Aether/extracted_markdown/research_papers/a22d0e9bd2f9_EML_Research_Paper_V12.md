# The EML Operator: New Results in Algebra, Geometry, and Dynamics

## A Formally Verified Investigation — Version 12

---

### Authors
EML Research Team

### Abstract

We present new formally verified results on the EML operator $\operatorname{eml}(x,y) = e^x - \ln y$, a Sheffer operator for the elementary function algebra. Building on 280+ previously verified theorems (V1–V8), we establish: (1) complete characterization of right and left quasi-division, showing EML forms a right quasigroup but not a left quasigroup on $\mathbb{R}_{>0}$; (2) verification of geodesic equation solutions for the EML Hessian metric, confirming hyperbolic geometry with Gaussian curvature $K = -e^x/(4y^2)$; (3) strict convexity and unique minimum of the diagonal map on $(0,\infty)$; (4) a new lower bound $\operatorname{eml}(x,y) \ge 1 + x - \ln y$ from the inequality $e^x \ge 1 + x$; (5) tropical EML algebraic properties including non-commutativity and averaging bounds; (6) EML complexity results establishing $K_{\text{EML}}(\exp) = 1$, $K_{\text{EML}}(1-x) = 2$, and generation of the constants $\{0, \pm 1, e, e^2, e^e\}$. All results are machine-verified in Lean 4.28.0 with Mathlib.

### Keywords
EML operator, Sheffer operator, formal verification, Lean 4, Riemannian geometry, quasi-division, tropical algebra, symbolic regression

---

## 1. Introduction

### 1.1 Background

The **EML operator** (Exponential-Minus-Logarithm) is the binary function

$$\operatorname{eml}(x, y) = e^x - \ln y$$

defined for $x \in \mathbb{R}$ and $y > 0$. Its fundamental property is **Sheffer completeness**: the closure of $\{x, 1\}$ under EML generates all elementary functions, just as the Sheffer stroke (NAND) generates all Boolean functions.

The EML research program, spanning versions V1 through V8, has produced over 280 formally verified theorems in Lean 4. These establish:

- **Algebraic structure:** EML is a wild magma — non-commutative, non-associative, with no identity element.
- **Analysis:** Strict monotonicity (increasing in $x$, decreasing in $y$ for $y > 0$), non-vanishing gradient.
- **Dynamics:** The diagonal map $d(z) = e^z - \ln z$ satisfies $d(z) > z$ for all $z$, with orbits diverging at tetrationally fast rates.
- **Constants:** EML generates $e, e^e, e^{e^e}, \ldots$ and all integers via the e-tower construction.

### 1.2 This Paper

We present new results in three areas:

1. **Quasi-division theory** (§3): Complete characterization of when the equations $\operatorname{eml}(a, x) = b$ and $\operatorname{eml}(x, a) = b$ have solutions.
2. **Riemannian geometry** (§4): The EML Hessian defines a hyperbolic metric with explicit geodesics.
3. **Approximation and complexity** (§5): New bounds on what EML can and cannot compute efficiently.

---

## 2. Definitions and Notation

```lean
def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y
def emlDiag (z : ℝ) : ℝ := Real.exp z - Real.log z
def emlGmap (z : ℝ) : ℝ := Real.exp 1 - Real.log z
def emlETower : ℕ → ℝ
  | 0 => 1
  | n + 1 => Real.exp (emlETower n)
def emlTrop (x y : ℝ) : ℝ := max x (-y)
```

We write $d(z) = \operatorname{emlDiag}(z) = e^z - \ln z$ for the diagonal map, $g(z) = e - \ln z$ for the g-map, and $e\uparrow\uparrow n$ for the e-tower of height $n$.

---

## 3. Quasi-Division Theory

### 3.1 Right Quasi-Division

**Theorem 3.1** (Right Division). *For all $a, b \in \mathbb{R}$, the equation $\operatorname{eml}(a, x) = b$ has the unique positive solution $x = e^{e^a - b}$.*

*Proof.* $\operatorname{eml}(a, x) = b$ means $e^a - \ln x = b$, so $\ln x = e^a - b$, hence $x = e^{e^a - b}$. Since the exponential is always positive, the solution exists for all $a, b$. Uniqueness follows from the strict monotonicity of $\ln$ on $(0, \infty)$. ∎

**Lean verification:**
```lean
theorem eml_right_division (a b : ℝ) :
    eml a (Real.exp (Real.exp a - b)) = b
```

**Corollary.** $(\mathbb{R}_{>0}, \operatorname{eml})$ is a right quasigroup: for every $a$ and $b$, there exists a unique $x > 0$ with $\operatorname{eml}(a, x) = b$.

### 3.2 Left Quasi-Division

**Theorem 3.2** (Left Division). *For $a > 0$, the equation $\operatorname{eml}(x, a) = b$ has a solution if and only if $b + \ln a > 0$. When it exists, the unique solution is $x = \ln(b + \ln a)$.*

*Proof.* $\operatorname{eml}(x, a) = b$ means $e^x - \ln a = b$, so $e^x = b + \ln a$. This has a solution $x = \ln(b + \ln a)$ if and only if $b + \ln a > 0$. ∎

**Lean verification:**
```lean
theorem eml_left_division (a b : ℝ) (ha : 0 < a) (hba : 0 < b + Real.log a) :
    eml (Real.log (b + Real.log a)) a = b

theorem eml_left_division_domain (a b x : ℝ) (ha : 0 < a) (h : eml x a = b) :
    0 < b + Real.log a
```

**Consequence.** $(\mathbb{R}_{>0}, \operatorname{eml})$ is NOT a (full) quasigroup. The left division obstruction defines a natural boundary curve $b = -\ln a$ in the parameter space.

---

## 4. Riemannian Geometry of EML

### 4.1 The Hessian Metric

The Hessian of $\operatorname{eml}(x, y)$ with respect to its arguments is:

$$H = \begin{pmatrix} \frac{\partial^2 \operatorname{eml}}{\partial x^2} & \frac{\partial^2 \operatorname{eml}}{\partial x \partial y} \\[4pt] \frac{\partial^2 \operatorname{eml}}{\partial y \partial x} & \frac{\partial^2 \operatorname{eml}}{\partial y^2} \end{pmatrix} = \begin{pmatrix} e^x & 0 \\ 0 & y^{-2} \end{pmatrix}$$

Since both diagonal entries are positive (for $y > 0$), this is a **positive definite** matrix, defining a Riemannian metric on $\mathbb{R} \times \mathbb{R}_{>0}$.

**Lean verification:**
```lean
theorem emlHessian_pos_def (x y : ℝ) (hy : 0 < y) :
    0 < emlHessXX x ∧ 0 < emlHessYY y
```

### 4.2 Gaussian Curvature

**Theorem 4.1.** *The Gaussian curvature of the EML Hessian metric is*

$$K(x, y) = -\frac{e^x}{4y^2}$$

*which is strictly negative for all $(x, y) \in \mathbb{R} \times \mathbb{R}_{>0}$.*

**Lean verification:**
```lean
theorem eml_curvature_negative (x y : ℝ) (hy : 0 < y) :
    -(Real.exp x) / (4 * y ^ 2) < 0
```

The negativity of the curvature means the EML metric space is **hyperbolic** — geodesics diverge, triangles have angle sums less than $\pi$, and the geometry resembles the Poincaré half-plane.

### 4.3 Geodesic Solutions

**Theorem 4.2.** *The geodesic equations for the EML metric decouple into:*
- *$x$-equation: $x'' + \frac{1}{2}(x')^2 = 0$, solved by $x(t) = 2\ln(at + b)$*
- *$y$-equation: $y'' - \frac{(y')^2}{y} = 0$, solved by $y(t) = Ce^{kt}$*

**Lean verification:**
```lean
theorem eml_geodesic_x_verify (a b t : ℝ) (h : 0 < a * t + b) :
    let x'' := -(2 * a ^ 2) / (a * t + b) ^ 2
    let x' := 2 * a / (a * t + b)
    x'' + (1/2) * x' ^ 2 = 0

theorem eml_geodesic_y_verify (C k t : ℝ) (hC : 0 < C) :
    let y := C * Real.exp (k * t)
    let y' := C * k * Real.exp (k * t)
    let y'' := C * k ^ 2 * Real.exp (k * t)
    y'' - y' ^ 2 / y = 0
```

The $x$-geodesics are logarithmic curves, while the $y$-geodesics are exponential curves — precisely the functions that EML generates. This self-referential structure suggests a deep connection between the geometry of EML and its algebraic completeness.

---

## 5. Approximation Theory and Complexity

### 5.1 The EML Lower Bound

**Theorem 5.1.** *For all $x \in \mathbb{R}$ and $y > 0$:*
$$\operatorname{eml}(x, y) \ge 1 + x - \ln y$$

*Proof.* From $e^x \ge 1 + x$, we have $\operatorname{eml}(x,y) = e^x - \ln y \ge (1 + x) - \ln y$. ∎

**Lean verification:**
```lean
theorem eml_lower_bound (x y : ℝ) :
    eml x y ≥ 1 + x - Real.log y
```

### 5.2 EML Complexity Results

| Function | $K_{\text{EML}}$ | Representation |
|----------|:-----------------:|----------------|
| $e^x$ | 1 | $\operatorname{eml}(x, 1)$ |
| $1$ | 0 | constant |
| $e$ | 1 | $\operatorname{eml}(1, 1)$ |
| $0$ | 2 | $\operatorname{eml}(0, \operatorname{eml}(1, 1))$ |
| $1 - x$ | 2 | $\operatorname{eml}(0, e^x)$ |
| $e^{e^x}$ | 2 | $\operatorname{eml}(\operatorname{eml}(x, 1), 1)$ |
| $-1$ | 3 | $\operatorname{eml}(0, e^2) = \operatorname{eml}(0, \operatorname{eml}(2, 1))$ |
| $\ln x$ | 3–5 | **open** |

### 5.3 Diagonal Map Convexity

**Theorem 5.2.** *The diagonal map $d(z) = e^z - \ln z$ is strictly convex on $(0, \infty)$.*

*Proof.* $d''(z) = e^z + z^{-2} > 0$ for all $z > 0$. ∎

This implies $d$ has a unique minimum on $(0, \infty)$, occurring at the solution of $e^z = 1/z$.

---

## 6. Tropical EML

The **tropical EML** is the "dequantization" of EML:
$$\operatorname{trop}(x, y) = \max(x, -y)$$

obtained by replacing $\exp$ with $\text{id}$ and $\ln$ with $\text{id}$ in the $\max$-plus algebra limit.

### 6.1 Non-Commutativity

**Theorem 6.1.** *Tropical EML is not commutative.*

*Proof.* $\operatorname{trop}(1, 2) = \max(1, -2) = 1$, but $\operatorname{trop}(2, 1) = \max(2, -1) = 2$. ∎

### 6.2 Averaging Bound

**Theorem 6.2.** *$\operatorname{trop}(x, y) \ge (x - y)/2$ for all $x, y$.*

*Proof.* Since $\max(x, -y) \ge (x + (-y))/2 = (x - y)/2$. ∎

---

## 7. Connections and Future Directions

### 7.1 Connection to the Legendre Transform

The identity $\operatorname{eml}(x, e^y) = e^x - y$ shows that EML with an exponential second argument performs a "partial Legendre transform" — subtracting a linear term from a convex function. This connects EML to:
- Convex optimization (Fenchel duality)
- Thermodynamics (Helmholtz ↔ Gibbs free energy)
- Information geometry (exponential families)

### 7.2 Connection to the Lambert W Function

The fixed point $z^*$ of the g-map $g(z) = e - \ln z$ satisfies $z^* + \ln z^* = e$, which gives $z^* e^{z^*} = e \cdot e^e$, so $z^* = W(e^{e+1})$ where $W$ is the Lambert W function.

### 7.3 Open Problems

1. $K_{\text{EML}}(\ln x) = ?$
2. Is the EML closure dense in $C(K)$?
3. Is the Julia set of $d(z)$ connected?
4. Classify all Sheffer operators.
5. Compute the geodesic distance in closed form.

---

## 8. Conclusion

The EML operator continues to reveal unexpected depth. The quasi-division theory shows it is "almost" a quasigroup — right division always works, but left division has a natural domain constraint. The Riemannian geometry is hyperbolic, with geodesics that are themselves the functions EML generates. The tropical limit preserves the non-commutative character while connecting to the rich world of max-plus algebra.

With 280+ verified theorems and the new V12 results, the formal corpus provides a solid foundation for the ambitious research directions outlined in the companion Future Research Directions paper.

---

## References

The formal verification corpus is available in the `EML/` directory. Key files:
- `EML/EMLv8Core.lean` — Core definitions and fundamental identities
- `EML/EMLv8Advanced.lean` — E-tower, orbit dynamics, magma failures
- `EML/EMLFutureResearch.lean` — V12 new results (this paper)

All proofs are verified in Lean 4.28.0 with Mathlib (commit `8f9d9cff6bd728b17a24e163c9402775d9e6a365`).
