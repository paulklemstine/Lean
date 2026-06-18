# Future Directions: Certified Tropical Invariants for Applied Data Analysis

This document outlines concrete next steps building on the formally verified theory of tropical equivalence invariance established in `Tropical/Applications/TropicalEquivalenceInvariance.lean`.

---

## 1. Approximate Tropical Equivalence Stability Theorem

**Status**: Foundation laid (`approximate_tropical_shift_preserves_order`).

**Next target**: Generalize from strict order to full ranking stability with explicit combinatorial bounds.

```
theorem approximate_tropical_ranking_stability
    {n : ℕ} (s t : Fin n → ℝ) (c ε : ℝ)
    (happrox : ∀ i, |t i - s i - c| ≤ ε)
    (hgap : ∀ i j, s i ≠ s j → |s i - s j| > 2 * ε) :
    ∀ i j, s i ≤ s j ↔ t i ≤ t j
```

**Proof strategy**: Extend the gap-stability argument to handle the non-strict case by case-splitting on `s i = s j` vs `s i < s j` vs `s i > s j`.

**Connection to existing catalog**: Combine with `tropical_network_lipschitz_bound` to derive end-to-end robustness: if a tropical network's Lipschitz constant is `L` and input perturbation is `δ`, then rankings are preserved when score gaps exceed `2Lδ`.

**Impact**: Enables certified reproducibility statements for data pipelines: "rankings are stable under measurement noise up to this quantified threshold."

---

## 2. Phylogenetic Quartet Invariance Under Tropical Normalization

**Hypothesis**: Quartet selection (the four-point condition used in neighbor-joining and related phylogenetic methods) is invariant under tropical equivalence of dissimilarity vectors.

**Formal target**:
```
def quartet_topology {n : ℕ} (d : Fin n → Fin n → ℝ) (a b c e : Fin n) : Prop :=
  d a b + d c e ≤ d a c + d b e ∧ d a b + d c e ≤ d a e + d b c

theorem tropequiv_preserves_quartet_topology
    {n : ℕ} (d₁ d₂ : Fin n → Fin n → ℝ) (c : ℝ)
    (hshift : ∀ i j, d₂ i j = d₁ i j + c) :
    ∀ a b c' e, quartet_topology d₁ a b c' e ↔ quartet_topology d₂ a b c' e
```

**Proof strategy**: The quartet condition involves sums of pairs of distances. Under uniform additive shift, each sum `d₁ a b + d₁ c e` becomes `(d₁ a b + c) + (d₁ c e + c) = d₁ a b + d₁ c e + 2c`. Since the same `2c` is added to all three sums, the ordering is preserved.

**Cross-domain implications**: This would formalize the guarantee that tree reconstruction algorithms are invariant under baseline calibration choices — a fundamental assumption in computational phylogenetics that has never been machine-verified.

---

## 3. Tropical Quotient Statistics: Well-Definedness on TP^{n-1}

**Hypothesis**: Ranking statistics, argmin sets, and gap structures descend to well-defined functions on the tropical projective space `TP^{n-1} = ℝ^n / (1,1,...,1)`.

**Formal target**:
```
def TropProj (n : ℕ) := Quotient (Setoid.mk (@TropEquiv n) tropequiv_equivalence)

noncomputable def argmin_on_TropProj {n : ℕ} [NeZero n] :
    TropProj n → Set (Fin n) :=
  Quotient.lift (fun x => {i | ∀ j, x i ≤ x j}) (by
    intro x y hxy
    exact tropequiv_preserves_argmin_set hxy)
```

**Proof strategy**: The key lemma `tropequiv_preserves_argmin_set` already shows the lift is well-defined. The remaining work is defining `TropProj` as a quotient type and showing various statistics lift.

**Statistics to lift**:
- Argmin set (done in principle)
- Ranking permutation (the permutation sorting the vector)
- Gap vector (vector of consecutive differences after sorting)
- Top-k set for any fixed k

**Impact**: Establishes tropical projective space as a formal domain for order statistics, connecting tropical geometry to nonparametric statistics.

---

## 4. Min-Plus Spectral Observables and Tropical Eigenvectors

**Connection to catalog**: `tropical_eigenpair_one_by_one` provides the 1×1 case. The next step is to show that tropical eigenvector structure is preserved under equivalence.

**Formal target**:
```
-- A tropical eigenvector of A with eigenvalue λ satisfies:
-- min_j (A i j + v j) = λ + v i  for all i
def IsTropEigenvector (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (λ : ℝ) : Prop :=
  ∀ i, (Finset.univ.inf' ⟨0, Finset.mem_univ 0⟩ (fun j => A i j + v j)) = λ + v i

theorem trop_eigenvector_shift_invariant
    {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) (v w : Fin n → ℝ) (λ : ℝ)
    (hv : IsTropEigenvector A v λ) (hw : TropEquiv v w) :
    IsTropEigenvector A w λ
```

**Proof strategy**: If `w i = v i + c`, then `A i j + w j = A i j + v j + c`, so the min shifts by `c`, and `λ + w i = λ + v i + c`. The `c` cancels.

**Impact**: Connects the representation-invariance theory to tropical spectral theory, enabling certified analysis of min-plus matrix powers (relevant to shortest-path algorithms and network flow).

---

## 5. Information-Theoretic Tropical Sufficiency

**Connection to catalog**: `network_tropical_degree` bounds the complexity of tropical objects. Combined with ranking invariance, this suggests a compression theory.

**Hypothesis**: The ranking statistic is a sufficient statistic for the tropical equivalence class — it retains exactly the information lost by projectivization.

**Formal target**:
```
-- The ranking function extracts the total preorder from a vector
def ranking {n : ℕ} (x : Fin n → ℝ) : Fin n → Fin n → Prop :=
  fun i j => x i ≤ x j

-- Ranking determines the tropical equivalence class up to a scalar
theorem ranking_determines_tropequiv_class
    {n : ℕ} (hn : 2 ≤ n) (x y : Fin n → ℝ)
    (hrank : ∀ i j, x i ≤ x j ↔ y i ≤ y j)
    (hfixed : x 0 = y 0) :  -- fix one coordinate to remove the scalar ambiguity
    x = y
```

**Proof strategy**: If all pairwise comparisons agree and one coordinate is pinned, then by transitivity all coordinates must agree (since for any i, x 0 ≤ x i and x i ≤ x 0 implies x 0 = x i, etc., and more generally the differences are determined).

*Note*: This requires the stronger assumption of continuous data. For discrete/tied data, the ranking determines only a coarser equivalence class.

**Impact**: Formalizes the intuition that tropical projectivization discards exactly the "overall scale" and retains all "shape" information — a tropical analogue of the classical sufficiency principle in statistics.

---

## 6. Certified Centrality Pipeline for Network Analysis

**Application target**: Formalize a complete pipeline:
1. Compute node scores from an adjacency matrix (e.g., row sums or min-plus row potentials).
2. Show that different normalization conventions produce tropically equivalent score vectors.
3. Apply `tropical_equiv_scores_preserve_ranking` to certify ranking invariance.

```
-- Row-sum centrality
noncomputable def rowSumScore (A : Matrix (Fin n) (Fin n) ℝ) : Fin n → ℝ :=
  fun i => ∑ j, A i j

-- Normalized row-sum centrality (subtract global mean)
noncomputable def normalizedRowSumScore (A : Matrix (Fin n) (Fin n) ℝ) : Fin n → ℝ :=
  fun i => rowSumScore A i - (∑ i, rowSumScore A i) / n

theorem normalized_row_sum_tropequiv (A : Matrix (Fin n) (Fin n) ℝ) :
    TropEquiv (normalizedRowSumScore A) (rowSumScore A)
```

**Impact**: Directly applicable to reproducibility in network science. Different software packages normalize centrality scores differently; this theorem certifies that the choice doesn't affect rankings.

---

## 7. Tropical Hecke Symmetry Interpretation

**Connection to catalog**: `tropical_hecke_shift_one` shows that additive shift appears as a Hecke operator in the tropical Langlands program.

**Hypothesis**: The ranking-invariance theorem can be reinterpreted as invariance under a tropical Hecke operator, connecting applied data analysis to representation theory.

**Formal target**: Show that the Hecke shift operator on tropical functions preserves the ranking filtration.

**Impact**: Provides unexpected algebraic depth to what appears to be an elementary observation. The Hecke interpretation suggests that tropical invariance is part of a larger symmetry group acting on data representations, potentially leading to new invariants beyond ranking.

---

## Summary: Prioritized Roadmap

| Priority | Direction | Difficulty | Impact |
|----------|-----------|------------|--------|
| 1 | Approximate stability (§1) | Medium | High — enables real-data certification |
| 2 | Quartet invariance (§2) | Low-Medium | High — direct phylogenetics application |
| 3 | Quotient statistics (§3) | Medium | High — structural foundation |
| 4 | Centrality pipeline (§6) | Low | Medium — concrete case study |
| 5 | Spectral observables (§4) | High | High — connects to spectral theory |
| 6 | Sufficiency theory (§5) | High | Very High — new theoretical framework |
| 7 | Hecke interpretation (§7) | Very High | Transformative — connects to Langlands |

Each direction builds on the verified theorems in `TropicalEquivalenceInvariance.lean` and can be pursued independently. The recommended team structure is to pursue directions 1–4 in parallel (each is self-contained), then converge on directions 5–7 which require deeper theoretical development.
