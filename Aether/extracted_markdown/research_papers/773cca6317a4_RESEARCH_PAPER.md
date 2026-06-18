# Cellular Automata as Algebraic Geometry over GF(2): Fixed-Point Varieties and the Degree-Complexity Bridge

## Abstract

We formalize elementary cellular automata (ECAs) as polynomial dynamical systems over the field GF(2) and study the algebraic geometry of their fixed-point varieties. Each of the 256 ECA rules defines a local polynomial map g : GF(2)³ → GF(2) via the Algebraic Normal Form (ANF), which extends to a global polynomial map f : GF(2)^n → GF(2)^n on cyclic states of length n. We prove three main results: (1) every ECA rule has a unique ANF representation, computed by Möbius inversion; (2) for additive (degree ≤ 1) rules, the fixed-point variety V(f - id) forms a GF(2)-submodule of the state space; (3) Rule 110, the Turing-complete rule, has maximal ANF degree 3 while its nonlinearity prevents subspace structure. We computationally falsify the conjecture that fixed-point variety dimension correlates with Wolfram's complexity classification. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: Elementary cellular automata, algebraic normal form, GF(2), fixed-point varieties, polynomial dynamical systems, formal verification

## 1. Introduction

Elementary cellular automata (ECAs) are the 256 rules governing binary one-dimensional cellular automata with nearest-neighbor interactions. Despite their simplicity, they exhibit the full spectrum of dynamical behavior, from trivial convergence (Rule 0) to Turing completeness (Rule 110, proved by Cook [1]).

Wolfram [2] classified ECAs into four complexity classes:
- **Class 1**: Evolution to a homogeneous state
- **Class 2**: Evolution to periodic structures
- **Class 3**: Chaotic, apparently random behavior
- **Class 4**: Complex localized structures; edge of chaos

The algebraic perspective reinterprets each ECA rule as a polynomial map over the two-element field GF(2) = Z/2Z. Since every Boolean function has a unique multilinear polynomial representation (the Algebraic Normal Form), this reinterpretation is canonical. The polynomial structure opens the door to tools from algebraic geometry: varieties, dimensions, sheaves, and schemes.

### 1.1 Main Results

We establish the following, all formally verified in Lean 4:

**Theorem A** (ANF Uniqueness). *Every function g : GF(2)³ → GF(2) has a unique representation as a multilinear polynomial of degree ≤ 3. The coefficients are recovered by Möbius inversion on the Boolean lattice.*

**Theorem B** (Submodule Structure). *If an ECA rule has ANF degree ≤ 1 (additive rule), then for any cycle length n, the fixed-point set {s ∈ GF(2)^n : f(s) = s} is a GF(2)-submodule of GF(2)^n.*

**Theorem C** (Degree-Linearity Bridge). *Every additive ECA rule has ANF degree ≤ 1. Rule 110 has ANF degree exactly 3 and is not additive.*

**Negative Result**. *The dimension of the fixed-point variety does not correlate with Wolfram's complexity classification. Rule 110 (Class 4, Turing-complete) has a single fixed point (dimension 0), while Rule 204 (Class 2, identity) has 2^n fixed points (dimension n).*

## 2. Definitions

### 2.1 The Field GF(2)

We work over GF(2) = {0, 1} with addition mod 2 and multiplication mod 2. Key properties:
- **Idempotence**: a² = a for all a ∈ GF(2) (Theorem `zmod2_idempotent`)
- **Characteristic 2**: a + a = 0 for all a ∈ GF(2) (Theorem `zmod2_self_add`)

These properties ensure that every polynomial over GF(2) is equivalent to a multilinear polynomial (no squared or higher terms needed).

### 2.2 ECA Local Rules

An ECA local rule is a function g : GF(2)³ → GF(2). There are 2⁸ = 256 such functions, indexed by Wolfram's rule numbering convention:

```
Rule r ↦ g_r(a, b, c) where g_r at input (a,b,c) is bit (4a + 2b + c) of r
```

### 2.3 Algebraic Normal Form

**Definition** (ANF Coefficients). An ANF representation consists of 8 coefficients (c₀, c₁, ..., c₇) ∈ GF(2)⁸ encoding:

g(a,b,c) = c₀ + c₁a + c₂b + c₃c + c₄ab + c₅ac + c₆bc + c₇abc

**Definition** (ANF Degree). The degree of an ANF is:
- 3 if c₇ ≠ 0
- 2 if c₇ = 0 and some c₄, c₅, c₆ ≠ 0
- 1 if only linear terms are nonzero
- 0 if only the constant term is nonzero (or all zero)

**Definition** (Möbius Inversion). The ANF coefficients are extracted from the truth table by:

c₀ = g(0,0,0)
c₁ = g(1,0,0) + g(0,0,0)
c₂ = g(0,1,0) + g(0,0,0)
⋮
c₇ = g(1,1,1) + g(1,1,0) + g(1,0,1) + g(0,1,1) + g(1,0,0) + g(0,1,0) + g(0,0,1) + g(0,0,0)

This is Möbius inversion on the Boolean lattice {0,1}³ ordered by componentwise ≤.

### 2.4 ECA State Space

For cycle length n ≥ 1, the state space is GF(2)^n = Fin(n) → GF(2), the space of functions from {0, 1, ..., n-1} to GF(2). This has the structure of an n-dimensional vector space over GF(2).

### 2.5 Global Update

Given local rule g and state s, the global update f(s) is defined by:

f(s)ᵢ = g(s_{(i-1) mod n}, sᵢ, s_{(i+1) mod n})

### 2.6 Fixed Points and Varieties

A state s is a **fixed point** if f(s) = s. The set V(f - id) = {s : f(s) = s} is the **fixed-point variety** of the ECA.

### 2.7 Additive Rules

A rule g is **additive** if there exist α, β, γ ∈ GF(2) such that g(a,b,c) = αa + βb + γc for all a, b, c.

## 3. Main Theorems

### 3.1 ANF Correctness and Uniqueness (Theorem A)

**Theorem** (`anf_eval_correct`). *For every local rule g, the ANF computed by Möbius inversion satisfies (anfFromRule g).eval a b c = g a b c for all inputs.*

**Proof sketch.** By exhaustive evaluation at all 8 inputs. The Möbius inversion formula is designed so that when the polynomial is evaluated, the inclusion-exclusion yields the original truth table value. □

**Theorem** (`anf_unique`). *If two ANF coefficient sets evaluate to the same function on all inputs, they are identical.*

**Proof sketch.** Evaluate both at all 8 inputs. The system c₁.eval(x) = c₂.eval(x) for x ∈ {0,1}³ yields 8 linear equations that uniquely determine each coefficient. □

Together, these establish a canonical bijection between ECA rules and ANF coefficients.

### 3.2 Submodule Structure (Theorem B)

**Theorem** (`ECAFixedSubmodule`). *For any additive rule g with IsAdditiveRule g, the set {s : IsFixedPoint hn g s} is a Submodule (ZMod 2) (ECAState n).*

This is proved by establishing three closure properties:

**Lemma** (`additive_rule_zero_fixed`). *0 is a fixed point of every additive rule.*

*Proof.* g(0, 0, 0) = α·0 + β·0 + γ·0 = 0. □

**Lemma** (`additive_rule_fixed_closed_add`). *If s, t are fixed points of an additive rule, then s + t is a fixed point.*

*Proof.* For additive g:
f(s + t)ᵢ = g((s+t)_{i-1}, (s+t)ᵢ, (s+t)_{i+1})
= α(s_{i-1} + t_{i-1}) + β(sᵢ + tᵢ) + γ(s_{i+1} + t_{i+1})
= (αs_{i-1} + βsᵢ + γs_{i+1}) + (αt_{i-1} + βtᵢ + γt_{i+1})
= f(s)ᵢ + f(t)ᵢ = sᵢ + tᵢ = (s + t)ᵢ. □

**Lemma** (`additive_rule_fixed_closed_smul`). *If s is a fixed point and c ∈ GF(2), then c·s is a fixed point.*

*Proof.* Since GF(2) = {0, 1}, either c = 0 (and 0·s = 0 is fixed) or c = 1 (and 1·s = s is fixed by hypothesis). □

### 3.3 Degree Classification (Theorem C)

**Theorem** (`additive_degree_le_one`). *Every additive rule has ANF degree ≤ 1.*

*Proof.* By case analysis on (α, β, γ) ∈ GF(2)³ (8 cases). For each, compute anfFromRule directly and verify that c₄ = c₅ = c₆ = c₇ = 0. The key algebraic fact: for g(a,b,c) = αa + βb + γc, the Möbius inversion formula cancels all degree ≥ 2 terms because in GF(2), x + x = 0. □

**Theorem** (`rule110_maximal_degree`). *Rule 110 has ANF degree 3.*

*Proof.* The ANF coefficients are c₂ = c₃ = c₆ = c₇ = 1, all others 0. Since c₇ ≠ 0, the degree is 3. □

**Theorem** (`rule110_not_additive`). *Rule 110 is not additive.*

*Proof.* Suppose g(a,b,c) = αa + βb + γc. From g(0,1,0) = 1: β = 1. From g(0,0,1) = 1: γ = 1. Then g(0,1,1) should be β + γ = 0. But Rule 110 gives g(0,1,1) = 1. Contradiction. □

### 3.4 Additional Results

**Theorem** (`rule204_all_fixed`). *Every state is a fixed point of Rule 204 (identity).*

**Theorem** (`rule0_fixed_iff_zero`). *The zero state is the unique fixed point of Rule 0.*

**Theorem** (`rule0_nilpotent`). *Rule 0 is nilpotent: one iteration sends every state to zero.*

**Theorem** (`fixed_point_iterate_invariant`). *Fixed points are invariant under all iterates of the update.*

**Theorem** (`rule204_fixed_submodule_eq_top`). *The fixed-point submodule of Rule 204 is the entire space ⊤.*

## 4. Computational Analysis

### 4.1 ANF Degree Distribution

Among all 256 ECA rules:
| Degree | Count | Percentage |
|--------|-------|------------|
| 0      | 2     | 0.8%       |
| 1      | 14    | 5.5%       |
| 2      | 112   | 43.8%      |
| 3      | 128   | 50.0%      |

The count at each degree follows from the binomial coefficients: there are C(k, d) monomials of degree d in k variables (k = 3 here), and each can independently be 0 or 1.

### 4.2 Fixed-Point Counts

For cycle length n = 8:

| Rule | Class | Fixed Points | log₂|V| | Degree |
|------|-------|-------------|---------|--------|
| 0    | 1     | 1           | 0       | 0      |
| 30   | 3     | 3           | ~1.58   | 2      |
| 51   | 2     | 0           | ∅       | 1      |
| 90   | 3     | 1           | 0       | 1      |
| 110  | 4     | 1           | 0       | 3      |
| 150  | 3     | 4           | 2       | 1      |
| 204  | 2     | 256         | 8       | 1      |
| 255  | 1     | 1           | 0       | 0      |

### 4.3 Falsification of Dimension-Complexity Conjecture

The conjecture that dim V(f - id) correlates with Wolfram class is falsified:
- Rule 110 (Class 4, Turing-complete): dim = 0 (1 fixed point)
- Rule 204 (Class 2, identity): dim = n (2^n fixed points)
- Rule 30 (Class 3, chaotic): |V| = 3 (not even a subspace)

The identity rule is the "most geometric" but least interesting dynamically. Computational power resides in transient dynamics, not fixed-point structure.

### 4.4 Subspace Verification

For all additive rules tested (Rules 90 and 150) at cycle lengths 3-12, the fixed-point count is always a power of 2 and the set is closed under componentwise XOR, confirming the submodule theorem computationally.

Rule 90 fixed-point dimensions for n = 3,...,12:
[2, 0, 0, 2, 0, 0, 2, 0, 0, 2]

This shows a periodic pattern of period 3, connected to the factorization of the polynomial x² + 1 over GF(2) (which is (x+1)², reflecting that the companion matrix has eigenvalue 1 with varying multiplicity depending on n mod 3).

## 5. Discussion

### 5.1 What Fixed-Point Geometry Captures

The fixed-point variety captures the **equilibrium structure** of the ECA, not its **computational capacity**. This distinction parallels the difference between a dynamical system's attractors and its transient complexity.

For additive rules, the submodule structure is complete and computable: the dimension equals n minus the rank of the matrix M - I over GF(2), where M is the circulant update matrix. This is a classical result in linear algebra over finite fields.

For nonlinear rules, the fixed-point set loses its subspace structure. The cardinality can be any integer from 0 to 2^n, and the set can be a genuinely nonlinear variety. The case of Rule 30 with 3 fixed points on an 8-cell cycle is a concrete example.

### 5.2 The Degree-Complexity Gap

While ANF degree does not directly predict Wolfram class, it plays a structural role: degree ≤ 1 rules are exactly the additive rules, which have well-understood dynamics (linear recurrence over GF(2)). The transition from degree 1 to degree 2 introduces qualitatively new behavior. The 112 quadratic rules and 128 cubic rules contain the full range of Wolfram classes 1-4.

### 5.3 Toward Orbit Varieties

The natural extension is to study the **periodic-point varieties**: Vₖ = {s : f^k(s) = s}, the variety of period-k orbits. The growth rate of |Vₖ| as a function of k — the **zeta function** of the dynamical system — is a richer invariant than V₁ alone. For additive rules, this zeta function has a rational expression in terms of the eigenvalues of M.

## 6. Formal Verification

All theorems in Sections 3.1-3.4 are formally verified in Lean 4 using the Mathlib library. The formalization comprises approximately 320 lines and includes:

- 7 definitions (ECALocalRule, ECAState, ecaUpdate, IsFixedPoint, ANFCoeffs, IsAdditiveRule, ECAFixedSubmodule)
- 16 theorems, all with complete machine-checked proofs
- No sorry, no additional axioms beyond the standard ones

The code is available at `Shared/CellularAlgebraicGeometry.lean`.

## 7. Future Work

1. **Orbit varieties and zeta functions**: Compute |Vₖ| for k > 1 and all 256 rules. Determine whether the growth rate of |Vₖ| correlates with Wolfram class.

2. **Scheme structure**: The variety V(f - id) over GF(2) has a scheme structure that remembers more than the set of solutions. Investigate whether the scheme-theoretic invariants distinguish complexity classes.

3. **GF(2)-cohomology**: Define a sheaf on the state space associated to each ECA rule and compute its cohomology groups. This is the Grothendieck-style approach suggested in the original problem statement.

4. **Higher-dimensional automata**: Extend the polynomial framework to 2D cellular automata, where the local rule depends on more neighbors and the polynomial degree can be higher.

## References

[1] Cook, M. "Universality in Elementary Cellular Automata." *Complex Systems* 15(1), 2004.

[2] Wolfram, S. "Statistical Mechanics of Cellular Automata." *Reviews of Modern Physics* 55(3), 1983.

[3] Lidl, R., Niederreiter, H. *Finite Fields.* Cambridge University Press, 1997.

[4] Cattaneo, G., Formenti, E., Margara, L., Mauri, G. "On the rank of the reduced transition matrix of linear cellular automata." *Theoretical Computer Science*, 1999.
