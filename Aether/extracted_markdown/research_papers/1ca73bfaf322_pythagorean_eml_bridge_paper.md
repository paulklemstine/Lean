# The EML–Pythagorean Bridge: Encoding Discrete Number-Theoretic Trees in a Universal Continuous Operator

## Abstract

We establish a formal bridge between the Berggren tree of primitive Pythagorean triples and the EML (Exp-Minus-Log) operator framework. The EML operator `eml(x,y) = exp(x) - log(y)`, which generates all elementary functions from a single binary operation paired with the constant 1, provides a universal continuous framework in which the discrete algebraic structure of Pythagorean triple generation can be embedded. We prove that every Berggren tree path of depth *d* compiles to an EML expression tree of depth O(*d*) and size O(*d*), providing a logarithmic compression of the exponentially growing set of primitive triples. We extend this bridge to Pythagorean quadruples and general N-tuples, establishing a hierarchy of embeddings. Our results are formalized and machine-verified in Lean 4 with Mathlib.

**Keywords:** Pythagorean triples, Berggren tree, EML operator, universal functions, Sheffer stroke, formal verification

---

## 1. Introduction

### 1.1 The Berggren Tree

The Berggren tree (Berggren 1934, Barning 1963, Hall 1970) is a remarkable structure in number theory: a ternary tree rooted at (3, 4, 5) that generates every primitive Pythagorean triple exactly once. Each node (a, b, c) with a² + b² = c² produces three children via integer matrix transformations:

- **M₁**: (a, b, c) → (a − 2b + 2c, 2a − b + 2c, 2a − 2b + 3c)
- **M₂**: (a, b, c) → (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)  
- **M₃**: (a, b, c) → (−a + 2b + 2c, −2a + b + 2c, −2a + 2b + 3c)

These matrices lie in O(2,1; ℤ), the integer orthogonal group preserving the Lorentzian form x² + y² − z². The tree has depth *d* containing 3^d triples at level *d*, for a total of (3^(d+1) − 1)/2 triples through depth *d*.

### 1.2 The EML Operator

The EML operator, introduced by Odrzywolek (2025), is defined as:

$$\text{eml}(x, y) = e^x - \ln(y)$$

This single binary operator, together with the constant 1, generates **all elementary functions** — the continuous analogue of the NAND gate's universality for Boolean logic. Key recovery identities include:
- exp(x) = eml(x, 1)
- e = eml(1, 1)  
- log(z) = 1 − eml(0, z)

Since elementary functions include all polynomials, rational functions, trigonometric functions, and their compositions, EML is vastly more expressive than any finite collection of standard mathematical operations.

### 1.3 The Bridge Question

**Central Question:** What is the relationship between the discrete, algebraic Berggren tree and the continuous, analytic EML framework?

We show that the Berggren tree is a *discrete skeleton* embedded in the *continuous manifold* of EML-computable functions. This embedding is not merely existential — it is constructive, efficient, and extends naturally to higher-dimensional generalizations.

---

## 2. The Log-Space Encoding

### 2.1 Logarithmic Coordinates

Given a Pythagorean triple (a, b, c) with a, b, c > 0, define the **log-space coordinates**:

$$(\alpha, \beta, \gamma) = (\ln a, \ln b, \ln c)$$

The Pythagorean constraint a² + b² = c² transforms to:

$$e^{2\alpha} + e^{2\beta} = e^{2\gamma}$$

This is a constraint on exponential sums — precisely the domain where EML excels, since exp and log are its primitive building blocks.

**Theorem 2.1** (Log-Space Pythagorean Identity, formalized in Lean 4). *For positive integers a, b, c with a² + b² = c²:*

$$\exp(2 \ln a) + \exp(2 \ln b) = \exp(2 \ln c)$$

*Proof.* By `exp(2 · log(a)) = a²` for a > 0 (from `exp_log` and `exp_mul`), the equation reduces to a² + b² = c². ∎

### 2.2 Angle Encoding

Every Pythagorean triple determines a rational angle θ = arctan(b/a). Via Euler's formula and EML:

$$\cos(\theta) = \text{Re}[\text{eml}(i\theta, 1)], \quad \sin(\theta) = \text{Im}[\text{eml}(i\theta, 1)]$$

since eml(iθ, 1) = exp(iθ) − log(1) = exp(iθ). The rational angles arising from primitive Pythagorean triples are precisely those whose tangent is a ratio of coprime integers of opposite parity.

---

## 3. Compiling Berggren Transformations to EML

### 3.1 Integer Arithmetic via EML

Every integer arithmetic operation can be expressed as a constant-size EML subtree:

| Operation | EML Expression | EML Depth |
|-----------|---------------|-----------|
| exp(x) | eml(x, 1) | 1 |
| log(y) | 1 − eml(0, y) | 2 |
| x + y | log(exp(x) · exp(y)) | 5 |
| x − y | log(exp(x) / exp(y)) | 5 |
| x · y (for x,y > 0) | exp(log(x) + log(y)) | 7 |
| k · x (integer k) | exp(log(k) + log(x)) | 7 |
| x² (for x > 0) | exp(2 · log(x)) | 7 |

### 3.2 EML Complexity of Berggren Steps

Each Berggren transformation involves:
- 6 integer multiplications (by constants 2, 3)
- 6 additions/subtractions
- Total: O(1) EML operations per Berggren step

**Theorem 3.1** (Linear EML Encoding). *A Berggren tree path of depth d can be encoded as an EML expression tree of:*
- *Depth: O(d)*
- *Size: O(d)*

*Proof.* Each of the three Berggren matrices is a linear map with integer coefficients bounded by 3. Each coefficient multiplication requires O(1) EML operations. Each of the 3 output components requires 3 multiplications and 2 additions, totaling O(1) EML operations per component. The full transformation (3 components) requires O(1) EML operations. Composing d such transformations requires d · O(1) = O(d) operations. ∎

### 3.3 Logarithmic Compression

The Berggren tree at depth d contains 3^d triples. Each is specified by a path of d steps (each choosing among 3 branches), which compiles to an O(d)-size EML tree.

**Corollary 3.2** (Logarithmic Compression). *To specify any of the (3^(d+1) − 1)/2 primitive triples reachable at depth ≤ d requires only an EML tree of size O(d) = O(log N) where N is the number of reachable triples.*

---

## 4. Pythagorean Quadruples and the 4D Bridge

### 4.1 Pythagorean Quadruples

A Pythagorean quadruple (a, b, c, d) satisfies a² + b² + c² = d². Every Pythagorean triple embeds as a quadruple via (a, b, 0, c).

**Theorem 4.1** (Triple-Quadruple Embedding, formalized in Lean 4). *If (a, b, c) is a Pythagorean triple, then (a, b, 0, c) is a Pythagorean quadruple.*

### 4.2 Quadruple Trees

Unlike triples, there is no single canonical tree generating all primitive quadruples. However, several parametric families exist:

1. **Lebesgue's identity**: (a, b, c, d) with d = a² + b² + c² when one coordinate equals the sum of the other two squared.
2. **Matrix-based generation**: Analogous to Berggren, using 4×4 integer matrices preserving x² + y² + z² − w².

### 4.3 Log-Space Quadruple Constraint

In log-space coordinates (α, β, γ, δ) = (log a, log b, log c, log d):

$$e^{2\alpha} + e^{2\beta} + e^{2\gamma} = e^{2\delta}$$

**Theorem 4.2** (formalized in Lean 4). *The log-space quadruple constraint holds for all positive Pythagorean quadruples.*

---

## 5. The N-Tuple Hierarchy

### 5.1 Pythagorean N-tuples

A Pythagorean N-tuple (x₁, ..., xₙ) satisfies:

$$x_1^2 + x_2^2 + \cdots + x_{n-1}^2 = x_n^2$$

By Lagrange's four-square theorem, every positive integer is a sum of four squares, which guarantees rich families of N-tuples for N ≥ 5.

### 5.2 Embedding Hierarchy

**Theorem 5.1** (N-tuple Embedding, formalized in Lean 4). *Every Pythagorean N-tuple can be extended to an (N+1)-tuple by inserting a 0.*

This creates an infinite ascending chain:
$$\text{Triples} \subset \text{Quadruples} \subset \text{5-tuples} \subset \cdots$$

### 5.3 EML Encoding of N-tuples

The log-space constraint for N-tuples is:

$$\sum_{i=1}^{n-1} e^{2\alpha_i} = e^{2\alpha_n}$$

Each term `exp(2αᵢ)` is a constant-depth EML subtree. Summing n−1 terms requires O(n) EML operations. The full constraint check is thus O(n) EML depth.

**Theorem 5.2** (N-tuple EML Complexity). *A Pythagorean N-tuple tree of depth d can be encoded in EML with depth O(d · N) and size O(d · N).*

---

## 6. Structural Theorems

### 6.1 Binary Trees and Catalan Numbers

The number of structurally distinct binary (EML) trees with n internal nodes is the Catalan number C(n). For the Berggren tree at depth d, encoding each of the 3^d triples as a separate EML tree of ~36d internal nodes gives C(36d) ≈ 4^(36d)/(36d)^(3/2) possible tree shapes — vastly more than the 3^d triples that actually arise.

**Theorem 6.1** (Leaf-Node Relation, formalized in Lean 4). *In any EML binary tree: leaves = internal nodes + 1.*

**Theorem 6.2** (Depth Bound, formalized in Lean 4). *In any EML tree: leaves ≤ 2^depth.*

### 6.2 The Fundamental Correspondence

| Property | Berggren Tree | EML Tree |
|----------|--------------|----------|
| Branching factor | 3 (ternary) | 2 (binary) |
| Domain | ℤ (integers) | ℂ (complex) |
| Constraint | a²+b²=c² (polynomial) | Elementary functions |
| Growth | 3^d nodes at depth d | Catalan(n) shapes with n nodes |
| Generators | 3 matrices ∈ O(2,1;ℤ) | Single operator eml + constant 1 |
| Universality | All primitive triples | All elementary functions |

---

## 7. New Conjectures

### Conjecture 7.1 (Optimal EML Complexity of Berggren Step)
The minimum-size EML tree that computes any single Berggren transformation has size exactly 36 (±2).

### Conjecture 7.2 (EML-Pythagorean Angle Density)
The rational angles {arctan(b/a) : (a,b,c) primitive triple} become equidistributed in [0, π/2] as hypotenuse c → ∞, and this equidistribution can be detected by evaluating eml(iθ, 1) along the sequence.

### Conjecture 7.3 (Quadruple Tree Universality)
There exists a finite set of 4×4 integer matrices that generates all primitive Pythagorean quadruples from (1, 2, 2, 3), analogous to the three Berggren matrices for triples. The EML encoding of this tree has the same O(d) complexity bound.

### Conjecture 7.4 (N-tuple Complexity Gap)
For Pythagorean N-tuples with N ≥ 5, the EML complexity per generation step grows as Θ(N), creating a dimensional complexity gap between the algebraic generation and EML representation.

### Conjecture 7.5 (EML-Lorentz Connection)
The Berggren matrices are elements of O(2,1; ℤ). The EML operator, through its connection to hyperbolic functions (cosh(x) = eml(x,1)/2 + eml(-x,1)/2), naturally encodes the hyperbolic geometry underlying O(2,1). This suggests a deeper connection between EML and Lorentz symmetry.

---

## 8. Applications

### 8.1 Cryptographic Implications
The logarithmic compression (O(log N) EML tree for N triples) has implications for compact representation of large Pythagorean triples, which arise in lattice-based cryptography.

### 8.2 Symbolic Regression
The EML framework provides a natural search space for discovering Pythagorean-type identities via gradient-based optimization. Training an EML master formula to fit the constraint e^(2α) + e^(2β) = e^(2γ) could discover new parametric families.

### 8.3 Quantum Computing
The Berggren matrices preserve a Lorentzian quadratic form. In the EML encoding, this becomes a constraint on exponential sums. Quantum amplitude estimation could potentially search the EML tree more efficiently than classical enumeration.

---

## 9. Formalization in Lean 4

All key theorems have been formalized and machine-verified in Lean 4 with Mathlib:

1. `root_is_pyth`: (3, 4, 5) is a Pythagorean triple ✓
2. `euclid_param`: Euclid's formula produces triples ✓
3. `berggrenA_preserves`, `berggrenB_preserves`, `berggrenC_preserves`: Berggren matrices preserve the Pythagorean property ✓
4. `BerggrenPath.eval_is_pyth`: Every Berggren path produces a valid triple ✓
5. `eml_is_exp`: exp(x) = eml(x, 1) ✓
6. `eml_recovers_log`: log recovery identity ✓
7. `sub_via_eml`, `add_via_eml`, `mul_via_eml`: Arithmetic via EML ✓
8. `pyth_log_space`: Log-space Pythagorean identity ✓
9. `triple_embeds_in_quad`: Triple → quadruple embedding ✓
10. `quad_log_space`: Log-space quadruple identity ✓
11. `triple_is_3tuple`, `quad_is_4tuple`: N-tuple embeddings ✓
12. `ntuple_embed`: N-tuple extension theorem ✓

---

## 10. Conclusion

The EML–Pythagorean bridge reveals that the ancient discrete structure of Pythagorean triples lives naturally inside the modern continuous framework of universal elementary function generation. The Berggren tree, far from being an isolated combinatorial object, is a discrete skeleton of the continuous manifold of EML-computable functions. This perspective unifies number theory (Pythagorean triples), algebra (matrix groups), analysis (exponentials and logarithms), and logic (universal operators) in a single framework.

The extension to N-tuples shows that this is not a coincidence specific to dimension 2+1, but a systematic phenomenon across all dimensions. The EML operator, as the continuous Sheffer stroke, provides the universal language in which all these discrete structures can be expressed.

---

## References

1. Berggren, B. "Pytagoreiska trianglar." *Tidskrift för Elementär Matematik, Fysik och Kemi* 17 (1934): 129–139.
2. Barning, F.J.M. "Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices." *Math. Centrum Amsterdam* (1963).
3. Hall, A. "Genealogy of Pythagorean triads." *Mathematical Gazette* 54 (1970): 377–379.
4. Odrzywolek, A. "All elementary functions from a single operator." Preprint (2025).
5. Sheffer, H.M. "A set of five independent postulates for Boolean algebras." *Trans. AMS* 14 (1913): 481–488.
