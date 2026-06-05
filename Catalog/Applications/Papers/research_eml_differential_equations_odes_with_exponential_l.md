# Polynomial Obstructions and Wronskian Invariants for EML Differential Equations: A Formal Treatment

## Abstract

We develop a formal framework for studying second-order linear ordinary differential equations with polynomial and EML (Exponential-Multiplicative-Logarithmic) coefficients. Our main contributions are: (1) a general polynomial ODE obstruction theorem showing that no nonzero polynomial satisfies y'' = q(x)y when deg(q) ≥ 1, with the Airy equation y'' = xy as a key corollary; (2) the constancy of the Wronskian for Airy-type ODEs (Abel's identity), establishing the symplectic structure of the solution space; (3) formal verification that the EML expression class is closed under differentiation with controlled depth growth; and (4) the triviality of the polynomial solution submodule for equations with nonconstant polynomial coefficients. All results are fully formalized in Lean 4 with Mathlib, providing machine-verified proofs of classical differential algebra results in a modern proof assistant framework.

## 1. Introduction

The theory of linear ordinary differential equations with polynomial coefficients is one of the oldest and most fruitful areas of mathematics, connecting classical analysis to modern algebraic and computational frameworks. The Airy equation y'' = xy, introduced by G.B. Airy in 1838 for the study of optical caustics, serves as the prototypical example of an ODE whose solutions transcend the class of elementary functions.

The modern understanding of this transcendence relies on differential Galois theory, developed by Picard, Vessiot, Kolchin, and others. The differential Galois group of the Airy equation is SL₂(ℂ), and since this group is not solvable, the equation has no Liouvillian (and hence no EML) solutions. The Kovacic algorithm (1986) provides a decision procedure for this question.

In this paper, we formalize the foundational layer of this theory: the polynomial obstruction, the Wronskian structure, and the EML closure property. These results are the building blocks upon which the full differential Galois theory and the Kovacic algorithm rest.

### 1.1 Catalog Context

Our work builds on the EML framework established in the Aether Catalog, particularly:
- `EML/EMLv17Core.lean`: Core EML definitions (`eml`, `emlDiag`, `sigmaEml`)
- `EML/EMLv18Advanced.lean`: Second difference operations (`eml_second_difference`)
- `Bridges/GaloisNeuralCorrespondence.lean`: Galois group order bounds (`prime_degree_divides_galois_order`)
- `Algebra/ProofSpectra/Core.lean`: Galois connections (`galois_connection_theory_variety`)

Our polynomial ODE obstruction theorem extends the EML theory into the differential domain, showing that the algebraic closure properties of EML functions create absolute barriers to polynomial solvability of ODEs.

## 2. Definitions

### 2.1 EML Expressions

We define EML expressions as an inductive type:

```
inductive EMLExpr
  | const : ℝ → EMLExpr
  | var : EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | exp : EMLExpr → EMLExpr
  | log : EMLExpr → EMLExpr
```

This grammar captures the full class of functions constructible from constants, the identity function, arithmetic, and the exponential and logarithm.

### 2.2 Formal Differentiation

The formal derivative `EMLExpr.deriv : EMLExpr → EMLExpr` is defined structurally:
- `d/dx[c] = 0`
- `d/dx[x] = 1`
- `d/dx[f + g] = f' + g'`
- `d/dx[f · g] = f' · g + f · g'`
- `d/dx[exp(f)] = f' · exp(f)`
- `d/dx[log(f)] = f' · exp(-log(f))`

The key observation is that this definition is **well-typed**: every output is again an `EMLExpr`. This immediately proves the closure theorem.

### 2.3 The Wronskian

For differentiable functions f, g : ℝ → ℝ, the Wronskian is:

$$W(f, g)(x) = f(x) g'(x) - g(x) f'(x)$$

This is the determinant of the fundamental matrix of the solution space.

### 2.4 Polynomial Solution Space

For q ∈ ℝ[X], we define:

```
polyODESolutions(q) = {p ∈ ℝ[X] | p'' = q · p}
```

This is shown to be a submodule of ℝ[X] over ℝ.

## 3. Main Results

### 3.1 Degree Gap Theorem

**Theorem 3.1** (Second Derivative Degree Gap). *For any polynomial p over an integral domain R with torsion-free additive group, if natDegree(p) ≥ 2, then:*

$$\text{natDegree}(p'') = \text{natDegree}(p) - 2$$

*Proof sketch.* Apply the Mathlib lemma `degree_derivative_eq` twice. The first application gives natDegree(p') = natDegree(p) - 1 (valid since natDegree(p) ≥ 2 > 0). The second gives natDegree(p'') = natDegree(p') - 1 = natDegree(p) - 2 (valid since natDegree(p') = natDegree(p) - 1 ≥ 1 > 0). □

**Theorem 3.2** (Polynomial ODE Degree Obstruction). *Let R be an integral domain with torsion-free additive group. If q, p ∈ R[X] with q ≠ 0, p ≠ 0, and natDegree(q) ≥ 1, then p'' ≠ q · p.*

*Proof.* By contradiction. If p'' = q · p, consider two cases:

*Case 1: natDegree(p) ≤ 1.* Then p'' = 0 by the second derivative of low-degree polynomials. So q · p = 0. Since R[X] is an integral domain and q ≠ 0, p ≠ 0, we have q · p ≠ 0. Contradiction.

*Case 2: natDegree(p) ≥ 2.* By Theorem 3.1, natDegree(p'') = natDegree(p) - 2. By `natDegree_mul` (since q ≠ 0, p ≠ 0), natDegree(q · p) = natDegree(q) + natDegree(p). Since natDegree(q) ≥ 1, we have natDegree(q) + natDegree(p) ≥ natDegree(p) + 1 > natDegree(p) - 2 = natDegree(p''). But p'' = q · p implies they have the same natDegree. Contradiction. □

### 3.2 Airy Equation: No Polynomial Solutions

**Theorem 3.3** (Airy Polynomial Obstruction). *No nonzero polynomial p ∈ ℝ[X] satisfies p'' = X · p.*

*Proof.* Immediate from Theorem 3.2 with q = X, since natDegree(X) = 1 ≥ 1 and X ≠ 0 in ℝ[X]. □

**Theorem 3.4** (General Non-Solvability). *For any nonzero polynomial q ∈ ℝ[X] with natDegree(q) ≥ 1, no nonzero polynomial satisfies y'' = q(x)y.*

*Proof.* Direct application of Theorem 3.2. □

### 3.3 Constant Coefficient Case

**Theorem 3.5** (Constant Coefficient Obstruction). *For any nonzero c ∈ ℝ, no nonzero polynomial satisfies p'' = c · p.*

*Proof.* The case natDegree(p) ≤ 1 gives p'' = 0 = c · p, forcing p = 0 (since c ≠ 0). The case natDegree(p) ≥ 2 gives natDegree(p'') = natDegree(p) - 2 while natDegree(C(c) · p) = natDegree(p), a contradiction. □

This covers the harmonic oscillator (c < 0), whose solutions are trigonometric, and the exponential growth equation (c > 0), whose solutions are exponential.

### 3.4 Wronskian Constancy (Abel's Identity)

**Theorem 3.6** (Abel's Identity for Airy-type ODEs). *If f and g are twice-differentiable functions satisfying y'' = q(x)y for the same q, then the Wronskian W(f,g) has derivative zero everywhere.*

*Proof.* Computing:
$$W'(f,g) = (fg' - gf')' = f'g' + fg'' - g'f' - gf'' = fg'' - gf'' = f(qg) - g(qf) = 0$$

The cross-terms f'g' cancel, and the ODE substitution makes the remaining terms cancel. □

**Corollary 3.7** (Wronskian Constancy). *Under the hypotheses of Theorem 3.6, there exists C ∈ ℝ such that W(f,g)(x) = C for all x.*

### 3.5 Solution Space Structure

**Theorem 3.8** (Polynomial Solution Submodule). *polyODESolutions(q) is a submodule of ℝ[X] over ℝ.*

*Proof.* Closure under addition follows from linearity of differentiation and distributivity of multiplication. Closure under scalar multiplication follows from C(c) · p'' = (C(c) · p)'' (since C(c) is constant) and commutativity. □

**Theorem 3.9** (Triviality of Polynomial Solutions). *If q ≠ 0 and natDegree(q) ≥ 1, then polyODESolutions(q) = ⊥.*

This is the submodule-theoretic formulation of Theorem 3.4.

### 3.6 EML Derivative Closure

**Theorem 3.10** (EML Closure under Differentiation). *The formal derivative of any EML expression is again an EML expression.*

This is immediate from the well-typedness of `EMLExpr.deriv`.

**Theorem 3.11** (Derivative Depth Bound). *For any EML expression e, depth(e') ≤ 2 · depth(e) + 1.*

*Proof.* By structural induction. The critical cases are `exp` and `log`, where the chain rule introduces new exp/log applications, but these are bounded by the original depth. □

### 3.7 Linear Independence from Wronskian

**Theorem 3.12** (Wronskian Linear Independence). *If W(f,g)(x₀) ≠ 0 at some point x₀, then f and g are linearly independent as elements of ℝ → ℝ.*

*Proof.* If f = cg for some constant c, then W(f,g) = cg·g' - g·cg' = 0 everywhere. If g = 0, then W = 0. So W ≠ 0 implies both f ≠ cg and g ≠ 0. □

## 4. The Galois-Theoretic Picture

The results above form the polynomial layer of a larger picture. The differential Galois group G of y'' = q(x)y is a linear algebraic group acting on the solution space V ≅ ℂ², so G ⊆ GL₂(ℂ).

**The Wronskian constrains G.** Theorem 3.6 shows that the Wronskian is preserved by the flow. Since the Galois group commutes with the flow (being the symmetries of the solution space), G preserves the Wronskian bilinear form. This means G ⊆ SL₂(ℂ) (matrices preserving the symplectic form have determinant 1).

**The polynomial obstruction constrains G further.** If G were reducible (i.e., had an invariant 1-dimensional subspace), the equation would have a solution of the form exp(∫r(x)dx) for some rational function r. The polynomial obstruction shows this cannot be a polynomial, which is consistent with G being irreducible.

For the Airy equation specifically, the Galois group is exactly SL₂(ℂ) — the full symplectic group. This is "maximally non-solvable" and implies that no Liouvillian (and hence no EML) solutions exist.

## 5. Algorithms

### 5.1 Polynomial Solution Test

**Algorithm** (PolynomialSolutionTest):
- Input: Polynomial q ∈ ℝ[X]
- Output: Whether y'' = q(x)y has a nonzero polynomial solution
- Method: If natDegree(q) ≥ 1, return NO (by Theorem 3.2). If q = 0, return YES (solutions are linear functions). If q is a nonzero constant, return NO (by Theorem 3.5).

### 5.2 Kovacic Algorithm (Sketch)

The full Kovacic algorithm extends the polynomial test to handle all four cases of the differential Galois group. It searches for solutions in progressively larger EML subclasses:

1. **Case 1** (G reducible, triangularizable): Search for exp(∫r dx) with r rational.
2. **Case 2** (G imprimitive): Search for exp(∫r dx) with r algebraic of degree 2.
3. **Case 3** (G finite primitive): Search for algebraic solutions of bounded degree.
4. **Case 4** (G = SL₂): No EML solutions exist.

Each case involves checking specific algebraic conditions on the poles and residues of q.

## 6. Discussion

### 6.1 PEGB Analysis

**Polynomial ODE Obstruction (Theorem 3.2)**:
- **Proof**: Complete, non-trivial, using degree analysis in polynomial rings over integral domains.
- **Example**: For the Airy equation y'' = xy, the degree gap gives n-2 = n+1, impossible.
- **Generalization**: Works over any integral domain with torsion-free additive group, not just ℝ. The next level up would be obstructions for rational function solutions.
- **Boundary**: Fails when natDegree(q) = 0 and q = 0 (the equation y'' = 0 has polynomial solutions y = ax + b).

**Wronskian Constancy (Theorem 3.6)**:
- **Proof**: Complete, using the product rule and ODE substitution.
- **Example**: For Ai(x) and Bi(x), W(Ai, Bi) = 1/π for all x.
- **Generalization**: Extends to Abel's full identity W' = -pW for y'' + py' + qy = 0.
- **Boundary**: Requires both functions to satisfy the same ODE. Two solutions of different ODEs can have non-constant Wronskian.

**EML Closure (Theorem 3.10)**:
- **Proof**: By construction (well-typedness of the derivative function).
- **Example**: d/dx[exp(x²)] = 2x·exp(x²), which is EML of depth 1.
- **Generalization**: Higher-order derivatives remain EML, but depth can grow linearly.
- **Boundary**: Integration is NOT closed: ∫exp(-x²)dx is not EML (this is Liouville's theorem).

### 6.2 Cross-Domain Connections

The bridge between polynomial algebra and differential equations runs through the degree gap. This connects:
- **Polynomial ring theory** (natDegree, integral domains) ↔ **ODE theory** (solution spaces, existence/uniqueness)
- **Wronskian theory** (antisymmetric bilinear forms) ↔ **Symplectic geometry** (preservation of area)
- **Differential Galois theory** (algebraic groups) ↔ **Representation theory** (group actions on solution spaces)

## 7. Future Work

1. Formalize the full Kovacic algorithm in Lean 4, including the rational function case.
2. Extend the polynomial obstruction to higher-order ODEs: y^(n) = q(x)y.
3. Formalize the differential Galois group as an algebraic group acting on the solution space.
4. Prove that the Galois group of the Airy equation is exactly SL₂(ℂ).
5. Connect to the EML complexity theory: classify ODEs by the "EML depth" of their solutions.

## References

1. Airy, G.B. (1838). "On the intensity of light in the neighbourhood of a caustic." *Trans. Cambridge Phil. Soc.* 6, 379–402.
2. Kovacic, J. (1986). "An algorithm for solving second order linear homogeneous differential equations." *J. Symbolic Comput.* 2, 3–43.
3. van der Put, M. and Singer, M.F. (2003). *Galois Theory of Linear Differential Equations.* Springer.
4. Kolchin, E. (1973). *Differential Algebra and Algebraic Groups.* Academic Press.
5. Catalog: `EML/EMLv17Core.lean`, `EML/EMLv18Advanced.lean`, `Bridges/GaloisNeuralCorrespondence.lean`
