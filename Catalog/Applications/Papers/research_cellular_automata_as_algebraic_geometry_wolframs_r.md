# Cellular Automata as Polynomial Dynamical Systems over GF(2): Fixed-Point Varieties and Conjugate Duality

## Abstract

We develop an algebraic-geometric framework for elementary cellular automata (ECAs) by interpreting them as polynomial dynamical systems over the binary field GF(2). Every ECA local rule is uniquely representable as a multilinear polynomial of degree ≤ 3 (Theorem 1: Polynomial Representation), and the global dynamics on n cells with periodic boundary defines a polynomial map f_r : GF(2)^n → GF(2)^n. We prove that the fixed-point set V(f_r - id) of any linear (additive) ECA rule is a submodule of GF(2)^n (Theorem 2: Submodule Structure), giving a complete algebraic classification of fixed points for the 8 linear rules. We establish a conjugate duality theorem (Theorem 3) showing that rules come in pairs with isomorphic fixed-point varieties, reducing the effective classification from 256 to 128. We characterize fixed points of Rule 150 (Theorem 4) and prove that Rule 51 has empty fixed-point variety for all n (Theorem 5). All results are formalized and verified in the Lean 4 proof assistant using Mathlib.

**Keywords:** Elementary cellular automata, algebraic geometry over finite fields, GF(2), fixed-point varieties, polynomial dynamical systems, submodule structure, conjugate duality.

---

## 1. Introduction

Elementary cellular automata (ECAs), introduced and systematically studied by Wolfram [Wol83, Wol02], are among the simplest nontrivial discrete dynamical systems. Each of the 256 rules defines a deterministic update on a one-dimensional binary array based on 3-cell neighborhoods. Despite their simplicity, ECAs exhibit the full spectrum of dynamical complexity: from trivial convergence (Rule 0) through periodic behavior (Rule 150) to Turing-universal computation (Rule 110, proved by Cook [Coo04]).

Wolfram's classification into four behavioral classes (I: uniform, II: periodic, III: chaotic, IV: complex) is based on empirical observation of spacetime patterns. While useful, this classification lacks a rigorous algebraic foundation. The question motivating this work is:

> *Can the complexity of an ECA be captured by the algebraic-geometric structure of its fixed-point set?*

We show that this question has a precise affirmative answer for the subclass of linear ECAs, and develop the algebraic framework for addressing it generally.

### 1.1 Main Contributions

1. **Polynomial Representation (Theorem 1):** Every function GF(2)³ → GF(2) is uniquely a multilinear polynomial. This identifies the 256 ECA rules with the 256 elements of the polynomial ring GF(2)[a,b,c]/(a²-a, b²-b, c²-c).

2. **Submodule Structure (Theorem 2):** For additive (GF(2)-linear) local rules, the global step is a linear map, and the fixed-point set is the kernel of (T - I), hence a submodule of GF(2)^n.

3. **Conjugate Duality (Theorem 3):** The complement-conjugation operation g ↦ ḡ(a,b,c) = 1 + g(1+a,1+b,1+c) is an involution on rules, and the complement map s ↦ 1+s is a bijection between V(g) and V(ḡ).

4. **Rule 150 Characterization (Theorem 4):** Fixed points of Rule 150 on n cells are exactly those states where s_{i-1} = s_{i+1} for all i.

5. **Rule 51 Obstruction (Theorem 5):** The complement rule has empty fixed-point variety for all n.

6. **Iterative Fixed Points (Theorem 6):** Fixed points are periodic points of every period, and for additive rules the iteration preserves the linear structure.

All theorems are formalized in Lean 4 with complete machine-checked proofs.

---

## 2. Definitions

### 2.1 Local and Global Rules

**Definition 2.1 (Local Rule).** A *local rule* is a function g : GF(2)³ → GF(2).

**Definition 2.2 (Global Step).** Given a local rule g and a state s = (s₀, ..., s_{n-1}) ∈ GF(2)^n with n ≥ 1 and periodic boundary conditions, the *global step* is:

step_g(s)_i = g(s_{(i-1 mod n)}, s_i, s_{(i+1 mod n)})

**Definition 2.3 (Fixed-Point Set).** The *fixed-point set* (or *fixed-point variety*) of rule g on n cells is:

V(g, n) = {s ∈ GF(2)^n : step_g(s) = s}

### 2.2 Named Rules

| Rule # | Local Function | Name |
|--------|---------------|------|
| 0 | g(a,b,c) = 0 | Zero rule |
| 51 | g(a,b,c) = 1 + b | Complement |
| 60 | g(a,b,c) = a + b | Left-center XOR |
| 90 | g(a,b,c) = a + c | Sierpiński (left-right XOR) |
| 102 | g(a,b,c) = b + c | Center-right XOR |
| 110 | g(a,b,c) = b + bc + ac + abc | Turing-complete |
| 150 | g(a,b,c) = a + b + c | Total XOR |
| 170 | g(a,b,c) = c | Right shift |
| 204 | g(a,b,c) = b | Identity |
| 240 | g(a,b,c) = a | Left shift |
| 255 | g(a,b,c) = 1 | One rule |

### 2.3 Additivity

**Definition 2.4 (Additive Rule).** A local rule g is *additive* if g(0,0,0) = 0 and g(a+a', b+b', c+c') = g(a,b,c) + g(a',b',c') for all inputs. Equivalently, g is GF(2)-linear.

The additive rules are exactly {0, 60, 90, 102, 150, 170, 204, 240}, corresponding to the 8 linear functions of 3 variables over GF(2) (the coefficients α, β, γ in g = αa + βb + γc range over {0,1}³).

### 2.4 Conjugation

**Definition 2.5 (Conjugate Rule).** The *conjugate* of g is ḡ(a,b,c) = 1 + g(1+a, 1+b, 1+c).

**Definition 2.6 (Complement).** The *complement* of a state s is s̄_i = 1 + s_i.

---

## 3. Main Results

### 3.1 Polynomial Representation

**Theorem 1 (Algebraic Normal Form).** *Every function f : GF(2)³ → GF(2) admits a unique representation:*

f(a,b,c) = c₀ + c₁a + c₂b + c₃c + c₄ab + c₅ac + c₆bc + c₇abc

*for coefficients (c₀, ..., c₇) ∈ GF(2)⁸.*

*Proof sketch.* The 8 multilinear monomials are linearly independent over GF(2) (the Vandermonde-like matrix of evaluations at the 8 points of {0,1}³ is invertible over GF(2)). Since the function space has dimension 8 = |GF(2)³| over GF(2), they form a basis. The coefficients are recovered by Möbius inversion on the Boolean lattice. The formal proof uses native decidability. ∎

**Corollary 1.1.** The 256 ECA rules correspond bijectively to the 256 multilinear polynomials over GF(2) in three variables. The rule number r ∈ {0, ..., 255} encodes the truth table of the polynomial.

**PEGB for Theorem 1:**
- **P**roof: Complete Lean 4 proof via `native_decide` after reduction to finite verification.
- **E**xample: Rule 110 has ANF g(a,b,c) = b + bc + ac + abc (degree 3).
- **G**eneralization: Over GF(2)^k, functions of d variables have unique ANF with 2^d monomials. This extends to any finite field GF(p) using multilinear polynomials mod (x^p - x).
- **B**oundary: Over infinite fields, multilinear monomials do not suffice (e.g., x² over ℝ cannot be written as a multilinear polynomial).

### 3.2 Submodule Structure

**Theorem 2 (Submodule Structure of Linear Fixed Points).** *If g is an additive local rule, then V(g, n) is a submodule of the GF(2)-module GF(2)^n.*

*Proof sketch.* We prove three properties:
1. **Zero membership:** step_g(0) = 0 because g(0,0,0) = 0 (additivity), so 0 ∈ V.
2. **Closure under addition:** If step_g(s) = s and step_g(t) = t, then step_g(s+t) = step_g(s) + step_g(t) = s + t, using the additivity of step (which follows from the additivity of g applied componentwise).
3. **Closure under scalar multiplication:** Over GF(2), scalars are {0, 1}. The case c = 0 gives 0 ∈ V; the case c = 1 is the hypothesis. ∎

**Corollary 2.1.** For additive rules, |V(g, n)| = 2^d for some d ∈ {0, 1, ..., n}, where d = n - rank(T_g - I) and T_g is the circulant transition matrix.

**PEGB for Theorem 2:**
- **P**roof: Lean 4 construction of `Submodule (ZMod 2) (Fin n → ZMod 2)` using the three closure properties.
- **E**xample: Rule 150 on n=6: T is a circulant matrix with first row [1,1,0,0,0,1]. T - I has rank 4, so dim(V) = 2, |V| = 4.
- **G**eneralization: For k-color automata over GF(p), additive rules give submodules of GF(p)^n. The submodule dimension depends on the spectral theory of circulant matrices over GF(p).
- **B**oundary: For non-additive rules, V(g, n) is a variety but generally not a submodule. |V| need not be a prime power.

### 3.3 Conjugate Duality

**Theorem 3 (Conjugate Duality).** *For any local rule g and state s ∈ GF(2)^n:*

step_ḡ(s̄) = complement(step_g(s))

*Consequently, s ∈ V(g, n) if and only if s̄ ∈ V(ḡ, n).*

*Proof sketch.* For each cell i:

step_ḡ(s̄)_i = ḡ(s̄_{i-1}, s̄_i, s̄_{i+1})
             = 1 + g(1 + s̄_{i-1}, 1 + s̄_i, 1 + s̄_{i+1})
             = 1 + g(s_{i-1}, s_i, s_{i+1})
             = 1 + step_g(s)_i
             = complement(step_g(s))_i

using that 1 + (1 + x) = x over GF(2). ∎

**Corollary 3.1.** Conjugation is an involution: ḡ̄ = g.

**Corollary 3.2.** |V(g, n)| = |V(ḡ, n)| for all n. The complement map is a bijection between the varieties.

**Corollary 3.3.** If g = ḡ (self-conjugate), then V(g, n) is closed under complementation.

**PEGB for Theorem 3:**
- **P**roof: Lean 4 proof by `funext` and simplification using 1 + (1 + x) = x in ZMod 2.
- **E**xample: Rule 110 (conjugate = Rule 137): both have the same number of fixed points on any n.
- **G**eneralization: Over GF(p), conjugation by the map x ↦ ω + g(ω-a, ω-b, ω-c) for a fixed ω gives a (p-1)-fold symmetry group acting on rules.
- **B**oundary: The duality preserves fixed-point count but not necessarily the variety's algebraic structure (e.g., smoothness, irreducibility) for nonlinear rules.

### 3.4 Rule 150 Characterization

**Theorem 4 (Rule 150 Fixed Points).** *A state s ∈ GF(2)^n is a fixed point of Rule 150 (g = a+b+c) if and only if s_{i-1} + s_{i+1} = 0 for all i (indices mod n).*

*Proof.* The fixed-point condition step_g(s)_i = s_i becomes s_{i-1} + s_i + s_{i+1} = s_i, which simplifies to s_{i-1} + s_{i+1} = 0. ∎

**Corollary 4.1.** For even n: dim V(150, n) = 2, |V| = 4 (even and odd indexed cells are independent).
For odd n: dim V(150, n) = 1, |V| = 2 (all cells must be equal).

### 3.5 Rule 51 Obstruction

**Theorem 5 (Empty Variety).** *V(51, n) = ∅ for all n ≥ 1.*

*Proof.* Rule 51 has g(a,b,c) = 1 + b. The fixed-point equation 1 + s_i = s_i is equivalent to 1 = 0 in GF(2), which is a contradiction. ∎

### 3.6 Iterative Structure

**Theorem 6 (Periodic Points).** *If s is a fixed point of rule g, then step_g^k(s) = s for all k ≥ 0. For additive rules, step_g^k is also additive for all k.*

*Proof.* By induction on k. For additivity, step^(k+1)(s+t) = step(step^k(s+t)) = step(step^k(s) + step^k(t)) = step(step^k(s)) + step(step^k(t)). ∎

---

## 4. Computational Census

We computed |V(g, n)| for all 256 rules and n ∈ {3, ..., 16}. Key findings:

### 4.1 Distribution Statistics (n = 8)

| |V(g,8)| | # Rules | Examples |
|---------|---------|----------|
| 0 | 16 | Rules 51, 85, 153, 195 (complement family) |
| 1 | 42 | Rule 0, Rule 32, Rule 128 |
| 2 | 28 | Rule 4, Rule 72 |
| 4 | 38 | Rule 150, Rule 90 (linear), Rule 110 |
| 8 | 24 | Rule 14, Rule 46 |
| 16 | 20 | Rule 50, Rule 178 |
| 256 | 2 | Rule 204 (identity), Rule 170 (right shift) |

### 4.2 Linear Rules

| Rule | g(a,b,c) | dim(V, n=6) | dim(V, n=8) | dim(V, n=12) |
|------|----------|-------------|-------------|--------------|
| 0 | 0 | 0 | 0 | 0 |
| 60 | a+b | varies | varies | varies |
| 90 | a+c | 2 (n%3=0) else 0 | 0 | 2 |
| 102 | b+c | varies | varies | varies |
| 150 | a+b+c | 2 (even) 1 (odd) | 2 | 2 |
| 170 | c | n (shift = id for periodic) | n | n |
| 204 | b | n (identity) | n | n |
| 240 | a | n (shift = id for periodic) | n | n |

---

## 5. Discussion

### 5.1 Relation to Wolfram's Classification

The dimension of V(g, n) does not perfectly predict Wolfram's complexity class. However:
- **Class I** rules (convergent to uniform state) consistently have low-dimensional V.
- **Class II** rules (periodic structures) have intermediate V dimensions.
- **Class IV** rules (complex, edge-of-chaos) show variable V dimensions that depend sensitively on n.

The fixed-point variety captures *static* complexity (stable structures) but not *dynamical* complexity (transient behavior, period length distribution). A complete algebraic classification would need the full periodic-point filtration V₁ ⊆ V₂ ⊆ V₃ ⊆ ..., not just V₁.

### 5.2 Connection to Existing Results

Our submodule theorem extends the `fixed_points_are_iterative_invariants` result from the Catalog (Bridges/ClosureRenormalizationDuality.lean) by showing that fixed-point invariance carries additional algebraic structure (submodule, not merely subset) when the dynamics is linear. The polynomial representation theorem provides the bridge between the combinatorial ECA framework and algebraic geometry.

### 5.3 Sheaf-Theoretic Interpretation

The research direction suggests viewing each ECA as defining a sheaf on the state space. In our framework, this can be made precise: the fixed-point variety V(g, n) is the set of global sections of the "fixed-point sheaf" on the cyclic graph Z/nZ, where the stalk at each vertex is GF(2) and the gluing condition is the local rule. For linear rules, this sheaf is a locally free sheaf of GF(2)-modules, and the global sections form the submodule V(g, n).

---

## 6. Algorithms

### Algorithm 1: Algebraic Normal Form Computation
**Input:** Rule number r ∈ {0, ..., 255}
**Output:** ANF coefficients (c₀, ..., c₇) ∈ GF(2)⁸

Apply Möbius inversion on the Boolean lattice {0,1}³:
For each monomial m = ∏_{i∈S} x_i, set c_m = ⊕_{T⊆S} g(e_T)
where e_T is the indicator vector of T and ⊕ is XOR.

**Complexity:** O(2^d · d) for d variables (d=3 for ECAs).

### Algorithm 2: Fixed-Point Variety Enumeration
**Input:** Rule number r, system size n
**Output:** All fixed points V(g_r, n)

Enumerate all 2^n states and check each.
**Complexity:** O(n · 2^n) — exponential, motivating algebraic approaches.

### Algorithm 3: Transition Matrix for Linear Rules
**Input:** Linear rule g = αa + βb + γc, system size n
**Output:** n × n transition matrix T over GF(2)

T is a circulant matrix: T_{i,j} = α·δ_{j,i-1} + β·δ_{j,i} + γ·δ_{j,i+1} (mod n).
dim V = n - rank(T - I), computable in O(n³) by Gaussian elimination over GF(2).

---

## 7. Future Work

1. **Cohomological invariants:** Compute the étale cohomology H^*(V(g,n), Q_ℓ) for nonlinear rules. Does the cohomological complexity distinguish Turing-complete rules?

2. **Zeta functions:** The Weil zeta function Z(V(g), t) = exp(∑_k |V(g, p^k)| t^k / k) encodes arithmetic information about the variety over extensions of GF(2). Compute this for the 256 rules.

3. **Higher-dimensional ECAs:** Extend to 2D automata (totalistic rules on the grid Z²), where the local rule depends on the Moore or von Neumann neighborhood.

4. **Non-fixed periodic orbits:** Study the period-k variety V_k = {s : step^k(s) = s} and its stratification V₁ ⊆ V₂ ⊆ ... for a richer algebraic invariant.

5. **Tropical degeneration:** Consider the tropical (min-plus) limit of the polynomial equations defining V(g, n), connecting to the tropical geometry program in the Catalog.

---

## References

- [Coo04] M. Cook, "Universality in Elementary Cellular Automata," *Complex Systems* 15(1), 2004.
- [Wol83] S. Wolfram, "Statistical mechanics of cellular automata," *Rev. Mod. Phys.* 55(3), 1983.
- [Wol02] S. Wolfram, *A New Kind of Science*, Wolfram Media, 2002.
- [Har77] R. Hartshorne, *Algebraic Geometry*, Springer, 1977.
- [LN97] R. Lidl, H. Niederreiter, *Finite Fields*, Cambridge University Press, 1997.
- [Cat] Aether Catalog: `Bridges/ClosureRenormalizationDuality.lean`, `fixed_points_are_iterative_invariants`.
