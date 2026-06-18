# Future Directions: Spectral Arithmetic Transfer Theory

## Overview

The theorems proved in this work establish the first layer of a spectral arithmetic transfer principle. The following directions represent concrete next steps, each building on the verified infrastructure.

---

## Direction 1: Modular Multiplicity Bounds for Integer Spectra

### Problem Statement
Given an integer spectrum `ev : Fin n → ℤ` bounded by `|ev(i)| ≤ M`, what is the maximum number of eigenvalues that can share the same square class modulo `N`?

### Precise Theorem Statement
For prime `p`, at most `2⌊M/p⌋ + 2` eigenvalues can have the same squared residue modulo `p`, since they must lie in at most 2 residue classes (by sign collapse).

### Proposed Lean Signature
```lean
theorem prime_square_class_multiplicity_bound
    (p : ℕ) (hp : Nat.Prime p) (M : ℕ)
    (ev : List ℤ) (hnodup : ev.Nodup)
    (hbound : ∀ x ∈ ev, |x| ≤ M)
    (hcong : ∀ x ∈ ev, ∀ y ∈ ev,
      ((x : ZMod p) ^ 2 = (y : ZMod p) ^ 2)) :
    ev.length ≤ 2 * (2 * M / p + 1)
```

### Proof Strategy Ideas
1. **Via sign collapse**: Use `prime_three_mod_four_no_nonsign_square_collision` (generalized to all primes) to show elements lie in ≤ 2 residue classes mod `p`. Count integers in `[-M, M]` per residue class using `Finset.Icc` cardinality bounds.
2. **Via pigeonhole**: Map `ev` into `ZMod p × {0, 1}` (residue class, sign flag). Use `Finset.card_le_card` to bound the image, then `Nat.div` bounds for preimage sizes.

### Cross-Domain Significance
Combined with eigenvalue bounds from regular graph theory (`|λ| ≤ d`), this gives explicit multiplicity limits for spectral square classes — a new graph-theoretic invariant.

---

## Direction 2: Characteristic Polynomial Congruence Obstructions for Regular Graphs

### Problem Statement
Can the characteristic polynomial of a `d`-regular graph on `n` vertices be constrained modulo a prime `p`? Specifically, the trace is 0, the sum of squared eigenvalues is `nd`, and these create modular constraints on the polynomial coefficients.

### Precise Theorem Statement
For a `d`-regular simple graph on `n` vertices with integer spectrum `λ₁, ..., λₙ`:
- `∑ λᵢ = 0` (trace of adjacency = 0 for simple graphs)
- `∑ λᵢ² = nd` (trace of A² = number of edges × 2 = nd)
- For any prime `p | d`, the spectrum mod `p` is constrained.

### Proposed Lean Signature
```lean
theorem regular_graph_spectrum_mod_constraint
    (d n : ℕ) (hd : 0 < d) (hn : 0 < n)
    (ev : Fin n → ℤ)
    (htrace : ∑ i, ev i = 0)
    (henergy : ∑ i, (ev i)^2 = n * d)
    (p : ℕ) (hp : Nat.Prime p) (hpd : p ∣ d) :
    (∑ i, ((ev i : ZMod p)^2)) = 0
```

### Proof Strategy Ideas
1. **Direct modular reduction**: Cast `henergy` to `ZMod p`, use `hpd` to get `n * d ≡ 0 (mod p)`, then `∑ (ev i)² ≡ 0 (mod p)`.
2. **Newton's identity approach**: Use the relation between power sums and elementary symmetric polynomials to propagate the constraint to higher coefficients of the characteristic polynomial.

### Cross-Domain Significance
This would show that primes dividing the regularity degree create "shadows" in the modular spectrum — a new structural invariant for graph isomorphism testing and spectral classification.

---

## Direction 3: Prime 3 mod 4 Exclusion Theorems for Norm-Generated Eigenvalue Sets

### Problem Statement
If eigenvalues of a graph arise as norms of elements in ℤ[√d] for some `d`, and a prime `p ≡ 3 (mod 4)` divides the norm, what does this force?

### Precise Theorem Statement
For `p ≡ 3 (mod 4)` and elements `α = a + b√d ∈ ℤ[√d]`, if `p | Norm(α) = a² - db²`, then either `p | a` and `p | b`, or `-d` is a quadratic residue mod `p`.

### Proposed Lean Signature
```lean
theorem norm_generated_spectrum_prime_obstruction
    (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
    (d : ℤ) (a b : ℤ)
    (hnorm : (p : ℤ) ∣ a^2 - d * b^2) :
    ((p : ℤ) ∣ a ∧ (p : ℤ) ∣ b) ∨
    (∃ x : ZMod p, x^2 = ((-d : ℤ) : ZMod p))
```

### Proof Strategy Ideas
1. **Extension of sum-of-squares argument**: Generalize `prime_three_mod_four_sum_of_squares_dvd` from `d = -1` to general `d`. If `b ≢ 0 (mod p)`, then `(a/b)² ≡ d (mod p)`, giving a square root of `d`.
2. **Quadratic residue symbol approach**: Use the Legendre symbol `(d/p)` to classify: if `(d/p) = -1`, then the first case always holds; if `(d/p) = 1`, both cases are possible.

### Cross-Domain Significance
This connects norm forms from algebraic number theory to spectral obstructions. For graphs whose eigenvalues arise from algebraic integers (e.g., Cayley graphs of number field units), this gives unconditional exclusion results for primes `p ≡ 3 (mod 4)` where `(-d/p) = -1`.

---

## Direction 4: Formalized Finite-Search Classification Under Energy and Congruence Constraints

### Problem Statement
Given bounds on eigenvalue size, spectral energy, and a modulus `N`, enumerate all feasible integer spectra up to isomorphism.

### Precise Theorem Statement
The set of integer spectra `ev : Fin n → ℤ` satisfying `|ev(i)| ≤ M`, `∑ ev(i)² ≤ E`, and a fixed square class pattern modulo `N` is finite and explicitly computable.

### Proposed Lean Signature
```lean
theorem feasible_spectra_finite
    (n M : ℕ) (E : ℕ) (N : ℕ) (hN : 0 < N) (sq_class : ZMod N) :
    Set.Finite {ev : Fin n → ℤ |
      (∀ i, |ev i| ≤ M) ∧
      (∑ i, (ev i)^2 ≤ E) ∧
      (∀ i, ((ev i : ZMod N))^2 = sq_class)}
```

### Proof Strategy Ideas
1. **Bounded range finiteness**: Since `|ev(i)| ≤ M`, the spectrum lives in `Fin n → Finset.Icc (-M : ℤ) M`, which is finite. The constraints carve out a subset.
2. **Constructive enumeration**: Build the set explicitly using `Finset.filter` on the product `(Finset.Icc (-M) M)^n`, then prove its cardinality satisfies the stated bound.

### Cross-Domain Significance
This is the algorithmic payoff of the theory: a complete search procedure for integer spectra satisfying combined spectral and arithmetic constraints. It could be used for:
- Exhaustive classification of small graph spectra
- Verification of spectral uniqueness conjectures
- Automated counterexample search

---

## Direction 5: Spectral Polynomial Annihilator Library

### Problem Statement
Build a library of low-degree polynomials that annihilate specific eigenvalue configurations, starting from the B₂ cubic and extending to other matrix families.

### Precise Theorem Statement
For each Berggren matrix Bₖ, classify the integer roots of the characteristic polynomial and prove the factorization.

### Proposed Lean Signatures
```lean
def satisfies_B1_poly (x : ℤ) : Prop := x^3 - 3*x^2 + 3*x - 1 = 0

theorem B1_poly_factorization (x : ℤ) :
    x^3 - 3*x^2 + 3*x - 1 = (x - 1)^3

theorem B1_unique_root (x : ℤ) (h : satisfies_B1_poly x) : x = 1

def satisfies_B3_poly (x : ℤ) : Prop :=
    x^3 + 3*x^2 + 3*x + 1 = 0  -- characteristic poly of B₃

theorem B3_poly_factorization (x : ℤ) :
    x^3 + 3*x^2 + 3*x + 1 = (x + 1)^3
```

### Proof Strategy Ideas
1. **Direct factorization**: Use `ring` for algebraic identities, `interval_cases` for integer root classification.
2. **Discriminant analysis**: Compute discriminants of irreducible factors to determine whether roots are rational, and use the rational root theorem to classify integer roots.

### Cross-Domain Significance
A verified polynomial annihilator library becomes a reusable tool for:
- Checking whether proposed eigenvalues are compatible with known matrix families
- Automated spectral fingerprinting (identifying a matrix from its eigenvalues)
- Building connections to Hecke operators and modular forms through their characteristic polynomials

---

## Team Research Directive

Each direction above should be pursued as follows:

1. **Hypothesis formulation**: State the theorem precisely in Lean 4 with `sorry`.
2. **Computational validation**: Test with Python experiments for small cases.
3. **Decomposition**: Break into 3–5 helper lemmas, each independently provable.
4. **Verification**: Prove each helper, then assemble the main theorem.
5. **Cross-domain testing**: For each proved theorem, immediately check implications in at least one other domain (spectral, arithmetic, polynomial).
6. **Knowledge base update**: Record proved theorems, failed approaches, and newly discovered connections.
7. **Iteration**: Use failures to refine hypotheses and generate new directions.

The goal is a self-reinforcing cycle: each proved theorem creates new hypotheses to test, and each computational experiment suggests new formal targets.
