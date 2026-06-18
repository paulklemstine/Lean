# Future Directions: Tropical Low-Rank Approximation Theory

This document outlines concrete next steps for extending the formalized tropical
approximation theory, building on the certified results in `Computation/TropicalApprox/`.

---

## 1. Tropical Singular-Value / Width Theory Based on `tropicalRankEps`

**Goal:** Develop a formal theory of tropical Kolmogorov widths analogous to
classical n-widths, using `tropicalRankEps` as the foundation.

**Specific theorem targets:**

```lean
/-- The tropical ε-entropy: log₂ of the minimum covering number
    of the unit ball under tropical rank constraints. -/
noncomputable def tropicalEntropy (f : X → Y → ℝ) : ℝ → ℝ :=
  fun ε => Real.log (tropicalRankEps f ε) / Real.log 2

/-- For Lipschitz functions on [0,1]², the tropical ε-rank
    grows at most as O(1/ε²). -/
theorem tropicalRankEps_lipschitz_bound
    (f : C(Set.Icc (0:ℝ) 1 × Set.Icc (0:ℝ) 1, ℝ))
    (L : ℝ) (hL : LipschitzWith (Real.toNNReal L) f)
    {ε : ℝ} (hε : 0 < ε) :
    tropicalRankEps_continuous f ε ≤ ⌈L / ε⌉₊ ^ 2
```

This would establish the tropical analogue of the classical result that
Lipschitz functions have polynomial approximation complexity.

---

## 2. Dictionary-Restricted Approximation with Explicit Search Complexity

**Goal:** Given finite dictionaries A ⊆ C(X,ℝ) and B ⊆ C(Y,ℝ), prove that
the optimal dictionary-restricted tropical approximant can be found by
finite enumeration, and bound the search complexity.

**Specific theorem targets:**

```lean
/-- Dictionary-restricted tropical rank. -/
noncomputable def dictTropicalRank
    {X Y : Type*} [Fintype X] [Fintype Y]
    (A : Finset (X → ℝ)) (B : Finset (Y → ℝ))
    (f : X → Y → ℝ) (ε : ℝ) : ℕ :=
  sInf {n | ∃ ts : Fin n → DictTerm X Y,
    (∀ i, (ts i).a ∈ A ∧ (ts i).b ∈ B) ∧
    ∀ x y, |f x y - sup_of_terms ts x y| ≤ ε}

/-- The search space for dictionary-restricted rank-n approximation
    has size at most (|A| * |B|)^n * discretization of coefficients. -/
theorem dictTropicalRank_search_bound
    {X Y : Type*} [Fintype X] [Fintype Y]
    (A : Finset (X → ℝ)) (B : Finset (Y → ℝ))
    (f : X → Y → ℝ) (ε : ℝ) (n : ℕ) :
    -- The number of candidate n-term approximants from A,B is (|A|*|B|)^n
    ∃ candidates : Finset (Fin n → DictTerm X Y),
      candidates.card ≤ (A.card * B.card) ^ n ∧
      -- and the optimal is among them
      ...
```

This connects tropical approximation to combinatorial optimization
and provides explicit algorithmic guarantees.

---

## 3. Continuous-Kernel Compression for Lipschitz f : X × Y → ℝ

**Goal:** Formalize the transfer from finite-grid exact representation to
compact metric space approximation via ε-nets, with explicit error bounds
in terms of the modulus of continuity.

**Specific theorem targets:**

```lean
/-- Given finite δ-nets S ⊆ X and T ⊆ Y, one can construct at most
    |S| * |T| max-plus terms that approximate f within ω(δ),
    where ω is the modulus of continuity of f. -/
theorem finite_net_approximation
    {X Y : Type*} [MetricSpace X] [MetricSpace Y]
    [CompactSpace X] [CompactSpace Y]
    (f : C(X × Y, ℝ))
    (S : Finset X) (T : Finset Y)
    (δ : ℝ) (hδ : 0 < δ)
    (hS : ∀ x : X, ∃ s ∈ S, dist x s ≤ δ)
    (hT : ∀ y : Y, ∃ t ∈ T, dist y t ≤ δ)
    (ω : ℝ → ℝ) (hω : ∀ p q, ‖f p - f q‖ ≤ ω (dist p q))
    (hωmono : Monotone ω) :
    ∃ ts : Fin (S.card * T.card) → MaxPlusTerm X Y,
      ∀ x y,
        |f (x, y) - Finset.univ.sup' ... (fun i => (ts i).eval x y)| ≤ ω (2 * δ)
```

This is the key bridge between finite combinatorics and continuous analysis,
and would complete the "certified tropical compiler" pipeline.

---

## 4. Comparison Between Tropical ε-Rank and Classical Matrix Ranks

**Goal:** On finite spaces, relate `tropicalRankEps` to classical notions:
nonneg rank, Boolean rank, and exact max-plus rank (Barvinok rank).

**Specific theorem targets:**

```lean
/-- The tropical 0-rank (exact rank) is at most the conventional
    nonneg matrix rank after exponentiation. -/
theorem tropicalRank_le_nonnegRank
    {m n : ℕ} (f : Fin m → Fin n → ℝ) :
    tropicalRankEps f 0 ≤ nonnegRank (fun i j => Real.exp (f i j))

/-- The tropical 0-rank is at most min(m,n) (trivial bound). -/
theorem tropicalRankEps_le_min_dim
    (f : Fin m → Fin n → ℝ) :
    tropicalRankEps f 0 ≤ min m n

/-- On Boolean matrices (0/1 valued), tropical 0-rank equals
    the minimum number of all-ones submatrices covering all 1-entries. -/
theorem tropicalRank_boolean_eq_cover
    (f : Fin m → Fin n → Fin 2) :
    tropicalRankEps (fun i j => (f i j : ℝ)) 0 = booleanCoverNumber f
```

These comparison theorems would situate tropical rank within the broader
landscape of matrix complexity measures.

---

## 5. Tropical Attention: Max-Plus Score Decomposition for Transformers

**Goal:** Formalize the connection between tropical low-rank approximation
and attention mechanism decomposition in transformer architectures.

In a transformer's attention layer, the score matrix is
`S[i,j] = q_i · k_j / √d`, and the softmax-weighted value is
`max_j (S[i,j] + log V[j,:])` in the tropical (low-temperature) limit.

**Specific theorem targets:**

```lean
/-- The tropical limit of softmax attention is a max-plus
    score decomposition. Every attention matrix of head-dimension d
    has tropical rank at most d. -/
theorem attention_tropical_rank_bound
    (d : ℕ) (Q K : Fin n → Fin d → ℝ) :
    tropicalRankEps (fun i j => ∑ k, Q i k * K j k) 0 ≤ d
```

This connects the formal tropical theory to practical deep learning
architectures and could guide the design of efficient attention mechanisms
with provably low tropical rank.

---

## Priority Ordering

1. **Continuous-kernel compression** (Direction 3) — highest priority, completes
   the main theoretical pipeline from finite to compact.
2. **Classical rank comparison** (Direction 4) — situates the theory in context.
3. **Dictionary-restricted approximation** (Direction 2) — most algorithmically
   actionable.
4. **Tropical widths** (Direction 1) — deepest theoretical extension.
5. **Tropical attention** (Direction 5) — highest application impact.
