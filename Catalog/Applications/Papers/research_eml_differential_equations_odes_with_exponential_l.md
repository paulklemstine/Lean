# Formalized Differential Galois Theory for EML Differential Equations

## Abstract

We present a formalization in Lean 4 of the differential Galois-theoretic obstruction to EML (exponential-multiplicative-logarithmic) solvability of second-order linear ODEs. Our main contributions are:

1. **Abel's Identity** for the Wronskian of second-order linear ODEs, in both differential and integral forms, with consequences for linear independence of solutions.
2. **Perfect groups are not solvable**: a clean proof that non-trivial perfect groups (G = [G,G]) have non-terminating derived series.
3. **Differential ring axiomatics**: a formalization of differential rings with proofs of the Leibniz rule consequences (D(0)=0, D(1)=0, D(-a)=-D(a), the power rule).
4. **Kovacic algorithm framework**: a decision-theoretic formalization of the four cases, with proof that Case 4 (SL(2) Galois group) excludes EML solutions.
5. **Airy equation obstructions**: proofs that no constant, monomial, or exponential function satisfies Airy's equation nontrivially, formalizing special cases of the general non-solvability result.

The formalization comprises approximately 600 lines of Lean 4 code across four files, with 25+ proved theorems and only one remaining sorry (the full structural induction for the main Airy theorem).

**Building upon**: `EML/EMLv17Core.lean` (eml function definitions), `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order), `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety).

## 1. Introduction

### 1.1 Background

The problem of determining when a differential equation has solutions expressible in terms of elementary functions has a rich history going back to Liouville (1833). The modern formulation uses differential Galois theory, developed by Kolchin (1948) and refined by Singer and others.

A function is **EML** (elementary) if it can be built from constants, the identity function, and the operations of addition, multiplication, negation, reciprocal, exponentiation, and logarithm through finite composition. The central question: given an ODE y'' + p(x)y' + q(x)y = 0 with EML coefficients p, q, when are the solutions also EML?

The answer is governed by the **differential Galois group** — an algebraic group acting on the solution space. The Kolchin-Singer theorem states: a Picard-Vessiot extension is Liouvillian (EML) if and only if the identity component of its differential Galois group is solvable.

### 1.2 Main Results

We formalize the following chain of reasoning:

$$\text{SL}(2,\mathbb{C}) \text{ perfect} \implies \text{not solvable} \implies \text{no EML solutions for Airy}$$

More precisely:

**Theorem (perfect_not_solvable).** If G is a non-trivial perfect group (⁅⊤,⊤⁆ = ⊤), then G is not solvable (the derived series never terminates at ⊥).

**Theorem (abel_identity).** If y₁, y₂ are solutions of y'' + p(x)y' + q(x)y = 0, then the Wronskian W = y₁y₂' - y₁'y₂ satisfies W'(x) = -p(x)W(x).

**Theorem (abel_identity_integral).** The Wronskian satisfies W(x) = W(x₀) · exp(-∫_{x₀}^x p(t) dt).

**Theorem (wronskian_nonzero_everywhere).** If the Wronskian is nonzero at any point, it is nonzero everywhere.

**Theorem (airy_no_const_solution, airy_no_monomial_solution, airy_no_exp_linear_solution).** No nontrivial constant, monomial x^n (n ≥ 1), or exponential exp(ax) satisfies Airy's equation y'' = xy.

## 2. EML Expression Formalization

### 2.1 Syntax

We define EML expressions as an inductive type:

```
inductive EMLExpr : Type
  | const : ℝ → EMLExpr
  | var : EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | neg : EMLExpr → EMLExpr
  | inv : EMLExpr → EMLExpr
  | exp : EMLExpr → EMLExpr
  | log : EMLExpr → EMLExpr
```

### 2.2 Syntactic Differentiation

Formal differentiation is defined recursively, implementing the chain rule, product rule, and the derivatives of exp and log. The key structural theorem is:

**Theorem (diff_elHeight_le).** The EL-height (maximal nesting depth of exp/log) does not increase under differentiation: elHeight(diff(e)) ≤ elHeight(e).

This is proved by structural induction and captures the fundamental algebraic insight that differentiation preserves the transcendental complexity of EML expressions. The exp and log operations cancel in a precise sense: differentiating exp(f) yields f'·exp(f), which has the same EL-height as exp(f); differentiating log(f) yields f'/f, which has strictly lower EL-height.

### 2.3 Evaluation and Closure

We define evaluation of EML expressions and prove that the class of EML functions is closed under addition, multiplication, exponentiation, and logarithm — establishing that EML functions form an algebra.

## 3. Abel's Identity and the Wronskian

### 3.1 The Second-Order Linear ODE

We formalize a second-order linear ODE y'' + p(x)y' + q(x)y = 0 as a structure containing coefficients p, q, with solutions specified by providing explicit derivative witnesses satisfying HasDerivAt.

### 3.2 Abel's Identity (Differential Form)

**Theorem.** If y₁, y₂ are solutions, then at each point x:
$$\text{HasDerivAt}(W, -p(x) \cdot W(x), x)$$

*Proof.* By the product rule:
$$W'(x) = y_1'y_2' + y_1 y_2'' - y_1'' y_2 - y_1' y_2'$$
$$= y_1 y_2'' - y_1'' y_2$$

Substituting the ODE (y'' = -py' - qy):
$$= y_1(-py_2' - qy_2) - (-py_1' - qy_1)y_2$$
$$= -p(y_1 y_2' - y_1' y_2) = -pW$$

The formal proof uses `HasDerivAt.sub`, `HasDerivAt.mul`, and `linear_combination` to close the algebraic identity. □

### 3.3 Abel's Identity (Integral Form)

**Theorem.** $W(x) = W(x_0) \cdot \exp\left(-\int_{x_0}^x p(t)\,dt\right)$

*Proof.* Define h(x) = W(x) · exp(∫_{x₀}^x p(t) dt). Show h'(x) = 0 using the differential form of Abel's identity and the fundamental theorem of calculus. Conclude h is constant: h(x) = h(x₀) = W(x₀). □

### 3.4 Consequences

- **Wronskian nonzero everywhere**: Since exp is never zero, W(x₀) ≠ 0 implies W(x) ≠ 0 for all x.
- **Wronskian zero from dependence**: If y₂ = cy₁, then W = 0 identically.

## 4. The Galois Obstruction

### 4.1 Perfect Groups and Solvability

A group G is **perfect** if ⁅G,G⁆ = G (the commutator subgroup is the whole group). We prove:

**Theorem (derivedSeries_perfect).** For a perfect group, derivedSeries G n = ⊤ for all n.

*Proof.* By induction. Base: derivedSeries G 0 = ⊤ by definition. Step: derivedSeries G (n+1) = ⁅derivedSeries G n, derivedSeries G n⁆ = ⁅⊤,⊤⁆ = ⊤ by perfectness and the inductive hypothesis. □

**Corollary (perfect_not_solvable).** A non-trivial perfect group is not solvable.

For the application: SL(2,ℂ) is perfect (every element is a product of commutators, since SL(2) over any algebraically closed field of characteristic ≠ 2 has this property). Therefore SL(2,ℂ) is not solvable, and by the Kolchin-Singer theorem, any ODE with differential Galois group SL(2,ℂ) has no EML solutions.

### 4.2 Differential Rings

We axiomatize differential rings and derive fundamental consequences of the Leibniz rule:

- D(0) = 0 (from D(0+0) = D(0) + D(0))
- D(1) = 0 (from D(1·1) = 2·D(1))
- D(-a) = -D(a) (from D(a + (-a)) = 0)
- D(a^(n+1)) = (n+1)·a^n·D(a) (by induction using D_mul)

### 4.3 The Kovacic Algorithm

We formalize the four cases of Kovacic's algorithm as an inductive type and prove the decision-theoretic structure: Case 4 implies no Liouvillian solutions (by definition of the algorithm's classification).

## 5. Airy's Equation

### 5.1 The Equation

Airy's equation y'' = xy is one of the simplest second-order linear ODEs with a variable coefficient. Its solutions, the Airy functions Ai(x) and Bi(x), arise in:
- Quantum mechanics (WKB approximation near turning points)
- Optics (diffraction near caustics)
- Fluid dynamics (Stokes phenomenon)

### 5.2 Non-Elementary Obstructions

We prove three special cases of the general non-solvability result:

1. **No nontrivial constant solution**: If y = c ≠ 0, then y'' = 0 ≠ xc for x ≠ 0.

2. **No monomial solution x^n (n ≥ 1)**: The ODE y'' = xy requires n(n-1)x^{n-2} = x^{n+1}. For n=1: 0 = x², impossible at x=1. For n≥2: degree n-2 ≠ n+1.

3. **No exponential solution exp(ax)**: The ODE requires a²exp(ax) = x·exp(ax), hence a² = x for all x, which is impossible.

### 5.3 The Growth Rate Perspective

We formalize the asymptotic growth of EML functions through an iterated exponential hierarchy. The Airy function has asymptotic growth involving exp(2x^{3/2}/3), where the 3/2 exponent is not a natural number (proved: three_halves_not_nat). This fractional power arises from the WKB analysis and reflects the transcendental nature of Airy solutions.

### 5.4 The Full Result (Statement)

The complete theorem — that no nontrivial EML expression satisfies Airy's equation — is stated but left as a formal conjecture (sorry), as it requires the full bridge between the syntactic EMLExpr formalization and the analytic differential Galois theory. This bridge requires:
1. Semantic correctness of syntactic differentiation
2. The Kolchin-Singer theorem in full generality
3. SL(2,ℂ) perfectness (computational group theory)

## 6. Cross-Domain Bridge

### 6.1 Algebraic vs. Differential Galois Theory

We formalize the structural parallel between:
- **Abel-Ruffini**: S₅ not solvable ⟹ quintic not solvable by radicals
- **Kovacic-Kolchin-Singer**: SL(2,ℂ) not solvable ⟹ Airy not solvable by EML

Both are instances of the Tannakian principle: the Galois group controls constructibility. We capture this as a `GaloisObstructionPrinciple` structure and prove the basic logical consequence (modus tollens on solvability).

### 6.2 Connection to Existing Catalog

Our `perfect_not_solvable` theorem generalizes the non-solvability results used in `Bridges/GaloisNeuralCorrespondence.lean` (prime_degree_divides_galois_order) by providing the abstract group-theoretic foundation. The differential ring formalization extends `Algebra/ProofSpectra/Core.lean` (galois_connection_theory_variety) to the differential setting.

## 7. Summary of Formal Results

| Theorem | File | Status |
|---------|------|--------|
| diff_elHeight_le | DiffEqCore.lean | ✓ Proved |
| eval_const_zero, eval_var, eval_add, eval_mul | DiffEqCore.lean | ✓ Proved |
| isEML_const, isEML_id, isEML_add, isEML_mul, isEML_exp, isEML_log | DiffEqCore.lean | ✓ Proved |
| abel_identity | AbelWronskian.lean | ✓ Proved |
| abel_identity_integral | AbelWronskian.lean | ✓ Proved |
| wronskian_antisymm | AbelWronskian.lean | ✓ Proved |
| wronskian_nonzero_everywhere | AbelWronskian.lean | ✓ Proved |
| wronskian_zero_of_dep | AbelWronskian.lean | ✓ Proved |
| perfect_not_solvable | GaloisObstruction.lean | ✓ Proved |
| derivedSeries_perfect | GaloisObstruction.lean | ✓ Proved |
| D_zero, D_one, D_neg, D_pow_succ | GaloisObstruction.lean | ✓ Proved |
| galois_obstruction_no_eml | GaloisObstruction.lean | ✓ Proved |
| kovacic_case4_full_galois | GaloisObstruction.lean | ✓ Proved |
| three_halves_not_nat | AiryNoEML.lean | ✓ Proved |
| polynomial_growth_is_iter_exp_zero | AiryNoEML.lean | ✓ Proved |
| airy_no_const_solution | AiryNoEML.lean | ✓ Proved |
| airy_no_monomial_solution | AiryNoEML.lean | ✓ Proved |
| airy_no_exp_linear_solution | AiryNoEML.lean | ✓ Proved |
| airy_no_nontrivial_eml_solution | AiryNoEML.lean | ✗ Sorry |

## 8. PEGB Analysis

### P (Proof): Abel's Identity
Complete formal proof using HasDerivAt, product rule, and linear_combination for the algebraic closure step.

### E (Example): Airy's Equation
Concrete verification that constants, monomials, and exponentials fail to satisfy y'' = xy. The polynomial case uses degree counting; the exponential case uses the impossibility of a²=x.

### G (Generalization): Perfect → Not Solvable
The abstract theorem applies to any perfect group, not just SL(2,ℂ). This encompasses all simple groups, and more generally any group generated by its commutators. The generalization to higher-order ODEs would involve SL(n,ℂ) for n > 2.

### B (Boundary): Where the Obstruction Breaks
The Kovacic algorithm's Case 1 (reducible Galois group) is where EML solutions *do* exist. The boundary between solvable and non-solvable is precisely at the structure of the coefficient function's poles. Adding a single pole of the right type can change the equation from Case 4 to Case 1.

## 9. Future Work

1. Complete the semantic correctness proof for syntactic differentiation of EML expressions
2. Formalize SL(2,ℂ) perfectness as a concrete group-theoretic computation
3. Full Kovacic algorithm implementation and correctness proof
4. Extension to systems of first-order ODEs
5. Painlevé transcendents and higher-order non-elementary functions

## References

1. Abel, N.H. (1824). Mémoire sur les équations algébriques.
2. Galois, É. (1832). Mémoire sur les conditions de résolubilité des équations par radicaux.
3. Liouville, J. (1833). Sur la détermination des intégrales.
4. Kolchin, E.R. (1948). Algebraic matric groups and the Picard-Vessiot theory.
5. Kovacic, J.J. (1986). An algorithm for solving second order linear homogeneous differential equations. *J. Symbolic Computation*, 2, 3-43.
6. Singer, M.F. (1981). Liouvillian solutions of linear differential equations with Liouvillian coefficients.
7. van der Put, M. & Singer, M.F. (2003). *Galois Theory of Linear Differential Equations*. Springer.
