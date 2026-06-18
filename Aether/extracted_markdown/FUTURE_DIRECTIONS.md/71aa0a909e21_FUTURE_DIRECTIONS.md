# Future Directions: Formalized Finite-Field Verification Theory

## Overview

The formalization of Freivalds' theorem as a hyperplane counting theorem creates a foundation for a broader program of formalized randomized algebra. Below are five concrete next steps, each specified with precise theorem statements and proof strategies.

---

## 1. Rank-Sensitive Exact Kernel Cardinality

**Goal**: Strengthen the bound `|ker(M)| ≤ q^(p-1)` to the exact formula `|ker(M)| = q^(p - rank(M))`.

**Theorem statement**:
```lean
theorem card_mulVec_kernel_exact
    {q m p : ℕ} [Fact q.Prime]
    (M : Matrix (Fin m) (Fin p) (ZMod q)) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      = q ^ (p - Module.finrank (ZMod q) (Matrix.mulVecLin M).range)
```

**Strategy**: Use `Matrix.mulVecLin` to interpret M as a linear map, apply rank-nullity to get `dim(ker) = p - dim(range)`, then use `Module.card_eq_pow_finrank` on the kernel submodule. The main technical challenge is establishing `Fintype` on the kernel of `mulVecLin` and connecting the subtype formulation to the Submodule.ker formulation.

**Impact**: Gives exact acceptance probabilities for Freivalds depending on the rank of the error matrix. For rank-$k$ errors, the probability is exactly $q^{-k}$, not just bounded by $q^{-1}$.

---

## 2. Repeated-Trial Soundness Amplification

**Goal**: Formalize the exponential soundness amplification when running $t$ independent Freivalds checks.

**Theorem statement**:
```lean
theorem freivalds_amplified_soundness
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) (t : ℕ) :
    (Fintype.card {rs : Fin t → (Fin p → ZMod q) //
        ∀ i, K.mulVec (rs i) = (A * B).mulVec (rs i)} : ℚ) /
      Fintype.card (Fin t → Fin p → ZMod q) ≤ (1 : ℚ) / q ^ t
```

**Strategy**: The product space `Fin t → Fin p → ZMod q` has cardinality `q^(t·p)`. The accepting set in the product is the $t$-fold Cartesian product of the single-trial accepting set, with cardinality `(card_accept)^t ≤ (q^(p-1))^t = q^(t(p-1))`. The ratio is `q^(t(p-1)) / q^(tp) = q^(-t)`.

**Impact**: Directly formalizes the standard amplification argument, the workhorse of all randomized verification.

---

## 3. Freivalds as a Corollary of Schwartz-Zippel

**Goal**: Formalize the Schwartz-Zippel lemma over finite fields and derive Freivalds as the degree-1 special case.

**Theorem statement** (Schwartz-Zippel):
```lean
theorem schwartz_zippel
    {q : ℕ} [Fact q.Prime] {n : ℕ}
    (f : MvPolynomial (Fin n) (ZMod q))
    (hf : f ≠ 0) :
    Fintype.card {x : Fin n → ZMod q // MvPolynomial.eval x f = 0}
      ≤ f.totalDegree * q ^ (n - 1)
```

**Strategy**: Induction on the number of variables. Base case: univariate root bound. Inductive step: condition on one variable, apply the inductive hypothesis to the residual polynomial. This is a well-known proof but requires careful formalization of partial evaluation and degree bounds for MvPolynomial in Mathlib.

**Connection to Freivalds**: Each entry of $M \cdot r$ is a degree-1 polynomial in $r$. The polynomial $P(r) = \sum_i (M \cdot r)_i^2$ (or any nonzero coordinate) has degree 1 in some variable, so Schwartz-Zippel gives $\leq 1 \cdot q^{p-1}$ zeros.

**Impact**: Unifies Freivalds, polynomial identity testing, and Reed-Solomon decoding under a single formal umbrella.

---

## 4. General Linear Map Kernel Density Theorem

**Goal**: Generalize from matrices over `Fin` to arbitrary finite-dimensional vector spaces.

**Theorem statement**:
```lean
theorem nonzero_linear_map_kernel_density
    {q : ℕ} [Fact q.Prime]
    {V W : Type*} [AddCommGroup V] [Module (ZMod q) V]
    [AddCommGroup W] [Module (ZMod q) W]
    [FiniteDimensional (ZMod q) V] [FiniteDimensional (ZMod q) W]
    [Fintype V] [Fintype W]
    (f : V →ₗ[ZMod q] W) (hf : f ≠ 0) :
    Fintype.card f.ker * q ≤ Fintype.card V
```

**Strategy**: Since $f \neq 0$, the range has positive dimension, so $\dim(\ker f) \leq \dim(V) - 1$. Then $|\ker f| = q^{\dim(\ker f)} \leq q^{\dim(V)-1} = |V|/q$.

**Impact**: This is the truly general theorem, applicable to any finite-dimensional representation. It covers:
- Matrix verification (current result)
- Polynomial evaluation (via polynomial spaces)
- Code distance bounds (via codeword spaces)
- Linear sketch verification (via streaming spaces)

---

## 5. Streaming/Interactive Verification Protocol

**Goal**: Formalize a streaming verification protocol where a verifier checks a matrix product using $O(m + p)$ space.

**Theorem statement**:
```lean
structure StreamingVerifier (q m p : ℕ) [Fact q.Prime] where
  state : Fin m → ZMod q  -- running sum A·(B·r) - K·r
  r : Fin p → ZMod q       -- random challenge (fixed)

theorem streaming_verifier_soundness
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B)
    (r : Fin p → ZMod q) :
    -- The streaming state after processing equals (K - A*B)·r
    (K - A * B).mulVec r = 0 ↔ K.mulVec r = (A * B).mulVec r
```

**Impact**: Connects the algebraic soundness theorem to the algorithmic setting of streaming computation. Combined with Direction 2 (amplification), this gives a complete formalized theory of streaming matrix verification with quantified error bounds.

---

## Cross-Cutting Themes

### Infrastructure Needs

All five directions benefit from:
- Better `Fintype` instance automation for submodules of finite types
- Formalized product measure / independent sampling for amplification arguments
- MvPolynomial evaluation and degree bounds for PIT connections

### Connections to Active Research

- **Verifiable computation**: Directions 2 and 5 formalize the core of SNARK/STARK soundness arguments
- **Algebraic complexity**: Direction 3 opens Schwartz-Zippel, the foundation of arithmetic circuit lower bounds
- **Coding theory**: Direction 4 generalizes to arbitrary linear codes, connecting to minimum distance bounds
- **Machine learning verification**: Streaming verification of matrix products is directly relevant to verifiable neural network inference

### Suggested Priority Order

1. Direction 2 (amplification) — highest impact, most straightforward
2. Direction 4 (general linear maps) — high reusability, moderate difficulty
3. Direction 1 (exact formula) — strengthens existing result, moderate difficulty
4. Direction 5 (streaming) — practical impact, requires protocol formalization
5. Direction 3 (Schwartz-Zippel) — most ambitious, highest long-term value
