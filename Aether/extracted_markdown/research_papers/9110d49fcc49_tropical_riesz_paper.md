# A Formally Verified Tropical Riesz Representation Theorem

## Abstract

We establish a formally verified tropical (max-plus, idempotent) analogue of the Riesz representation theorem. Working in the max-plus semiring ℝ ∪ {-∞} with tropical addition (= max) and tropical multiplication (= ordinary addition), we prove that every normalized max-plus linear functional on a finite discrete space is uniquely represented as a tropical integral against a weight function. Specifically, for any functional Λ satisfying preservation of sup (tropical additivity), additive shifts (tropical scalar multiplication), constant normalization, and monotonicity, there exists a unique weight function w : X → ℝ ∪ {-∞} such that

    Λ(f) = max_{x ∈ X} (w(x) + f(x))

for all continuous functions f. The weight function is recovered algorithmically via w(x) = Λ(δ_x), where δ_x is the tropical Dirac basis function (0 at x, -∞ elsewhere). The proof is fully formalized in Lean 4 with Mathlib, comprising approximately 400 lines of verified code with no axioms beyond the standard foundations (propext, Classical.choice, Quot.sound).

## 1. Introduction

### 1.1 The Classical Riesz Theorem

The Riesz–Markov–Kakutani representation theorem is one of the cornerstones of functional analysis. It states that every positive linear functional on the space C(X) of continuous functions on a compact Hausdorff space X is given by integration against a unique regular Borel measure:

    Λ(f) = ∫_X f dμ

This theorem bridges algebra (linear functionals) and geometry (measures on spaces), and underlies much of modern probability theory, spectral theory, and mathematical physics.

### 1.2 The Tropical Setting

Tropical (max-plus) mathematics replaces ordinary addition with maximum and ordinary multiplication with addition:

    a ⊕ b := max(a, b)     (tropical addition)
    a ⊙ b := a + b          (tropical multiplication)

The "zero" element is -∞ (identity for max), and the "one" element is 0 (identity for addition). This semiring structure appears throughout optimization, algebraic geometry, neural networks, and control theory.

### 1.3 Our Contribution

We prove the first formally verified tropical Riesz representation theorem: every max-plus linear functional on a finite space is integration against a unique maxitive measure (weight function). Our formalization includes:

1. The tropical function space TropCont(X) = C(X, WithBot ℝ)
2. The tropical functional structure with four axioms
3. Tropical basis decomposition: f(y) = max_x (f(x) + δ_x(y))
4. The representation formula: Λ(f) = max_x (w(x) + f(x))
5. Uniqueness and algorithmic recovery of weights
6. The evaluation functional construction
7. Maxitive measures with μ(K ∪ L) = max(μ(K), μ(L))

## 2. Mathematical Framework

### 2.1 The Max-Plus Semiring

We work with WithBot ℝ = ℝ ∪ {-∞}, equipped with the natural extension of ≤, the lattice supremum (max), and addition extended by -∞ + a = -∞. We equip this with the order topology.

### 2.2 Tropical Functionals

A **tropical functional** on a finite discrete space X satisfies:

1. **Sup preservation:** Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)
2. **Constant normalization:** Λ(const c) = c
3. **Additive shift:** Λ(c + f) = c + Λ(f)
4. **Monotonicity:** f ≤ g ⟹ Λ(f) ≤ Λ(g)

### 2.3 The Tropical Basis

The tropical Dirac profile at x₀:

    δ_{x₀}(y) = 0 if y = x₀, -∞ otherwise

## 3. Main Results

### 3.1 Tropical Basis Decomposition (finite_tropical_decompose)

    f(y) = max_{x ∈ X} (f(x) + δ_x(y))

The x = y term gives f(y) + 0 = f(y); all others give -∞.

### 3.2 The Representation Formula (finite_representation_formula)

    Λ(f) = max_{x ∈ X} (w(x) + f(x))

where w(x) = Λ(δ_x). Proved via two inequalities using monotonicity and the additive shift axiom.

### 3.3 Uniqueness (tropical_riesz_finite)

The weight w is unique: evaluate at f = δ_y to recover w(y) = Λ(δ_y).

### 3.4 Weight Normalization (deltaWeight_sup_eq_zero)

    max_x w(x) = 0

Follows from evaluating the formula at constant 0.

### 3.5 Round-Trip (evalFunctional_deltaWeight_eq)

Constructing a functional from weights and recovering weights gives back the original functional: evalFunctional(deltaWeight(Λ)) = Λ.

## 4. Formalization

The proof is in `Bridges/TropicalFunctional/Basic.lean`, approximately 400 lines of Lean 4 with Mathlib. All theorems compile with zero `sorry` statements and use only standard axioms.

Key technical choices:
- WithBot ℝ with order topology for the codomain
- Existential formulation of the additive shift axiom
- `continuous_of_discreteTopology` for the finite case

## 5. Applications

### 5.1 Dynamic Programming
The Bellman operator V(s) = max_a {r(s,a) + γV(s')} is a tropical integral. The Riesz theorem characterizes value functions by their weights.

### 5.2 Neural Networks
ReLU networks compute max_j(w_j·x + b_j) — tropical polynomials. The Riesz theorem gives unique weight recovery.

### 5.3 Possibility Theory
Maxitive measures are possibility distributions. The theorem provides a representation for idempotent expectations.

## 6. Discussion: What This Means

Imagine a machine that evaluates "landscapes" (functions) by picking the best location with handicaps. The classical Riesz theorem says: if a machine averages fairly, it has hidden probabilities. Our theorem says: **if a machine maximizes with handicaps, those handicaps are unique and recoverable.**

This is the passage from "linear algebra" to "tropical linear algebra" — from probability to possibility, from integrals to suprema, from measures to weights. It's the same conceptual structure, but in the idempotent world where addition is max.

## 7. References

1. Shilkret, N. "Maxitive measure and integration." *Indagationes Mathematicae* 33 (1971).
2. Maslov, V.P. *Méthodes opératorielles.* Mir, 1987.
3. Akian, Gaubert, Kolokoltsov. "Set coverings and invertibility of functional Galois connections." *Contemp. Math.* 377 (2005).
4. Cohen, Gaubert, Quadrat. "Duality and separation theorems in idempotent semimodules." *Lin. Alg. Appl.* 379 (2004).
