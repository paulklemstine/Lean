# Future Directions: Dihedral-Cyclotomic Theory

## Overview

The foundational results in `Algebra/DihedralCyclotomic/Basic.lean` establish the quadratic tower structure $F \subseteq F(\zeta+\zeta^{-1}) \subseteq F(\zeta)$ and the fixed-field inclusion for the inversion automorphism. This document outlines five concrete research directions opened by these results, with precise theorem statements and proof strategies.

---

## Direction 1: Minimal Polynomial of $2\cos(2\pi/p)$ for Odd Primes

### Goal
For an odd prime $p$, compute and prove the irreducibility of the minimal polynomial of $\alpha_p = 2\cos(2\pi/p)$ over $\mathbb{Q}$.

### Theorem Statement
```lean
theorem minpoly_two_cos_prime (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    (minpoly ℚ (2 * Real.cos (2 * Real.pi / p))).natDegree = (p - 1) / 2
```

### Proof Strategy
1. The minimal polynomial of $\alpha_p$ divides the "real cyclotomic polynomial" $\Phi_p(X) / (X-1)$ evaluated at appropriate substitution.
2. For prime $p$, $\Phi_p(X) = X^{p-1} + X^{p-2} + \cdots + 1$. Substituting $X \to$ root of $t^2 - \alpha t + 1 = 0$ and clearing denominators gives a degree-$(p-1)/2$ polynomial in $\alpha$.
3. Irreducibility follows from the Eisenstein criterion applied to $\Phi_p$ at the prime $p$, transferred to the real polynomial via the quadratic substitution.

### Cross-Domain Connections
- **Constructive geometry**: The degree determines whether the regular $p$-gon is constructible (iff $(p-1)/2$ is a power of 2, i.e., $p$ is a Fermat prime).
- **Coding theory**: These polynomials appear in the weight enumerator theory of cyclic codes.

---

## Direction 2: Chebyshev Polynomial Recurrence for $\zeta^k + \zeta^{-k}$

### Goal
Formalize the Chebyshev recurrence expressing $\zeta^k + \zeta^{-k}$ as a polynomial in $\alpha = \zeta + \zeta^{-1}$.

### Theorem Statements
```lean
/-- The power-sum Chebyshev recurrence. -/
def chebyshev_power_sum : ℕ → Polynomial ℤ
  | 0 => 2
  | 1 => X
  | (n+2) => X * chebyshev_power_sum (n+1) - chebyshev_power_sum n

/-- T_k(ζ + ζ⁻¹) = ζ^k + ζ^{-k} for all k. -/
theorem chebyshev_eval_eq_power_sum {K : Type*} [Field K] (ζ : K) (hζ : ζ ≠ 0) (k : ℕ) :
    Polynomial.aeval (ζ + ζ⁻¹) (chebyshev_power_sum k) = ζ^k + (ζ⁻¹)^k

/-- Periodicity: T_n(α) = 2 when ζ^n = 1. -/
theorem chebyshev_period {K : Type*} [Field K] (ζ : K) (n : ℕ) (hζ : ζ^n = 1) (hζ0 : ζ ≠ 0) :
    Polynomial.aeval (ζ + ζ⁻¹) (chebyshev_power_sum n) = 2
```

### Proof Strategy
- Induction on $k$ using the quadratic relation as the base case ($k=2$).
- The key identity is $(\zeta^{k+1} + \zeta^{-(k+1)}) = (\zeta + \zeta^{-1})(\zeta^k + \zeta^{-k}) - (\zeta^{k-1} + \zeta^{-(k-1)})$, which follows from distributing and canceling.

### Cross-Domain Connections
- **Polynomial dynamics**: The map $x \mapsto x^2 - 2$ on $\mathbb{R}$ is conjugate to $z \mapsto z^2$ on the unit circle via $x = z + z^{-1}$. Iterates of the Chebyshev map correspond to squaring in the cyclotomic world.
- **Algebraic circuits**: Different circuit representations of the Chebyshev recurrence can be certified equivalent.

---

## Direction 3: Fixed Field Equality (Reverse Inclusion)

### Goal
Prove the reverse inclusion $\text{Fix}(\langle \sigma \rangle) \subseteq F(\zeta + \zeta^{-1})$, completing the identification of the real subfield with the fixed field of inversion.

### Theorem Statement
```lean
theorem fixedField_inv_eq_adjoin_zeta_add_inv
    {K : Type*} [Field K] [Algebra ℚ K]
    (n : ℕ) (hn : 2 < n)
    (ζ : K) (hζ : IsPrimitiveRoot ζ n)
    (σ : K ≃ₐ[ℚ] K) (hσ : σ ζ = ζ⁻¹) :
    IntermediateField.fixedField (Subgroup.closure {σ}) =
      IntermediateField.adjoin ℚ ({ζ + ζ⁻¹} : Set K)
```

### Proof Strategy
1. We already have $\subseteq$ in one direction (Theorem C from Basic.lean).
2. For the reverse: $\text{Fix}(\langle \sigma \rangle)$ has index $|\langle \sigma \rangle| = 2$ in $F(\zeta)$ by the fundamental theorem of Galois theory.
3. $F(\zeta + \zeta^{-1})$ also has index $\leq 2$ in $F(\zeta)$ by the degree bound (Theorem F).
4. Since $F(\zeta + \zeta^{-1}) \subseteq \text{Fix}(\langle \sigma \rangle) \subseteq F(\zeta)$ and both have index $\leq 2$, equality follows by dimension counting.

### Prerequisites
- Construction of the inversion automorphism $\sigma$ for cyclotomic extensions.
- Application of the fundamental theorem of Galois theory from Mathlib.

---

## Direction 4: Semidirect Product / Dihedral Galois Structure

### Goal
For the compositum $L = \mathbb{Q}(\zeta_n, \sqrt{d})$ of a cyclotomic field with a quadratic extension, prove that $\text{Gal}(L/\mathbb{Q})$ has a semidirect product structure isomorphic to a subgroup of a dihedral group.

### Theorem Statement (aspirational)
```lean
theorem galois_group_dihedral_structure
    (n : ℕ) (hn : 2 < n) (hn_prime : Nat.Prime n) :
    ∃ (C : Subgroup (Gal(CyclotomicField n ℚ / ℚ)))
      (R : Subgroup (Gal(CyclotomicField n ℚ / ℚ))),
      C.IsNormal ∧ R.card = 2 ∧
      ∀ g, ∃ c ∈ C, ∃ r ∈ R, g = c * r
```

### Proof Strategy
1. Identify $C$ with the subgroup fixing $\mathbb{Q}(\zeta + \zeta^{-1})$ (the "rotation" subgroup).
2. Identify $R = \langle \sigma \rangle$ where $\sigma$ is the inversion automorphism.
3. Show $C$ is normal (as the kernel of the sign homomorphism $(\mathbb{Z}/n\mathbb{Z})^\times \to \{\pm 1\}$).
4. Show $C \cap R = \{1\}$ and $|C| \cdot |R| = |G|$.

### Cross-Domain Connections
- **Inverse Galois theory**: This provides explicit dihedral extensions over $\mathbb{Q}$.
- **Representation theory**: The decomposition corresponds to the character table of $D_n$.

---

## Direction 5: Representation-Theoretic Interpretation via Character Values

### Goal
Connect the real cyclotomic generator $\zeta + \zeta^{-1}$ to the character values of irreducible representations of the dihedral group $D_n$.

### Theorem Statement
```lean
/-- The character of the 2-dimensional representation of the cyclic
    subgroup C_n ⊂ D_n at generator g is ζ + ζ⁻¹. -/
theorem dihedral_char_eq_real_generator
    (n : ℕ) (hn : 2 < n) :
    -- The trace of the rotation matrix [cos θ, -sin θ; sin θ, cos θ]
    -- equals 2cos(2π/n) = ζ + ζ⁻¹
    2 * Real.cos (2 * Real.pi / n) =
      Complex.re (Complex.exp (2 * Real.pi * Complex.I / n) +
        (Complex.exp (2 * Real.pi * Complex.I / n))⁻¹)
```

### Proof Strategy
- The 2-dimensional irreducible representations of $D_n$ are indexed by $1 \leq k \leq \lfloor(n-1)/2\rfloor$.
- The character value at the rotation generator is $\zeta^k + \zeta^{-k} = 2\cos(2\pi k/n)$.
- The character value at a reflection is 0.
- This connects our algebraic `zeta_add_inv` to representation-theoretic traces.

### Cross-Domain Connections
- **Harmonic analysis on finite groups**: The Fourier transform on $D_n$ decomposes into characters valued in the real cyclotomic field.
- **Molecular symmetry**: Character tables of $D_n$ determine selection rules in spectroscopy. The entries are exactly the values $2\cos(2\pi k/n)$.

---

## Research Team Structure

Each direction should be pursued by a team with these roles:

- **Field theorist**: Handles intermediate field API, integrality, finite-dimensional towers.
- **Galois architect**: Manages automorphism construction, fixed fields, Galois correspondence.
- **Polynomial engineer**: Builds Chebyshev polynomials, minimal polynomials, and irreducibility proofs.
- **Computation lead**: Tests conjectures computationally before formalization, validates edge cases.
- **Knowledge curator**: Maintains this document, records failed approaches, extracts reusable lemmas.

## Priority Order

1. **Direction 2** (Chebyshev) — most self-contained, builds directly on existing quadratic relation.
2. **Direction 3** (Fixed field equality) — highest mathematical value, requires Galois theory API.
3. **Direction 1** (Minimal polynomials) — requires Direction 2 as infrastructure.
4. **Direction 5** (Characters) — connects to representation theory, relatively independent.
5. **Direction 4** (Dihedral structure) — most ambitious, requires all previous results.

## Dependencies

```
Direction 2 (Chebyshev)  ←  Direction 1 (Minimal Poly)
                              ↑
Direction 3 (Fixed Field) ←  Direction 4 (Dihedral)
                              ↑
Direction 5 (Characters)  ←──┘
```
