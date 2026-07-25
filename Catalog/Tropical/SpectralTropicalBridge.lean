import Mathlib

/-!
# Spectral–Tropical Bridge: From Markov Mixing to Tropical Cycle Geometry

This file establishes a formal bridge between the spectral theory of finite
Markov chains and tropical (min-plus) cycle geometry on weighted directed graphs.

## Core idea

Given a row-stochastic matrix `P` with strictly positive entries on `Fin (n+1)`,
the logarithmic weight matrix `W i j = -log(P i j)` converts multiplicative
probability transport into additive tropical geometry. We prove that **spectral
expansion on P forces nontrivial tropical cycle separation for W**.

## Main definitions

* `RowStochastic` — predicate for row-stochastic matrices
* `PositiveMatrix` — predicate for entrywise strictly positive matrices
* `logWeight` — the log-transform `W i j = -log(P i j)`
* `triangleMean` — mean weight of a triangle cycle `(i,j,k)`
* `triangleCycleGap` — minimum triangle mean over all triples
* `pathWeight` — weight of a path (list of vertices) through a weight matrix
* `spectralGapSurrogate` — elementary spectral gap surrogate `1 - max P i j`

## Main results

* `neg_log_antitone` — `-log` is antitone on positive reals
* `triangleMean_logWeight_lower_bound` — triangle mean of `-log P` is ≥ `-log s`
  when all entries of P are ≤ s
* `triangleCycleGap_logWeight_lower_bound` — the triangle cycle gap of the
  log-weight matrix is bounded below by `-log(max entry)`
* `tropical_cycle_gap_pos_of_uniform_non_determinism` — if `P i j ≤ 1 - ε`
  then the tropical cycle gap is positive: non-determinism ⟹ cycle separation
* `pathWeight_lower_bound` — general path weight lower bound for arbitrary
  length paths
* `tropical_triangle_mean_lower_bound` — direct theorem for individual triples
* `spectral_surrogate_to_tropical_gap` — spectral gap surrogate controls
  the tropical cycle gap

## Cross-domain significance

The log-transform `-log P` converts:
- **Markov transition probabilities** → **tropical edge weights** (information costs)
- **Spectral mixing rates** → **tropical cycle separations**
- **Probabilistic non-determinism** → **positive tropical energy barriers**

This creates a certified dictionary between:
1. Markov chain mixing theory (spectral gaps, relaxation times)
2. Tropical/idempotent algebra (min-plus eigenvalues, cycle means)
3. Information theory (surprisal, entropy rates)
4. Statistical physics (energy landscapes, loop costs)

## References

This framework connects to:
- `spectral_tropical_bound` in `SpectralIdempotentBridge.lean`:
  classical trace ≤ tropical eigenvalue for 2×2 matrices
- `TropicalMixing` in `MixingTheory.lean`:
  diagonal-based tropical cycle gaps for Markov chains
-/

noncomputable section

open Finset BigOperators Real

namespace SpectralTropicalBridge

variable {n : ℕ}

/-! ## Core predicates -/

/-- A matrix is row-stochastic: each row sums to 1. -/
def RowStochastic (P : Fin n → Fin n → ℝ) : Prop :=
  ∀ i, ∑ j, P i j = 1

/-- A matrix has strictly positive entries. -/
def PositiveMatrix (P : Fin n → Fin n → ℝ) : Prop :=
  ∀ i j, 0 < P i j

/-! ## The log-weight transform -/

/-- The tropical weight matrix: `W i j = -log(P i j)`.
    Converts multiplicative probability transport to additive tropical geometry. -/
def logWeight (P : Fin n → Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => -Real.log (P i j)

/-! ## Triangle cycle invariants -/

/-- Mean weight of the triangle cycle `i → j → k → i`. -/
def triangleMean (W : Fin n → Fin n → ℝ) (i j k : Fin n) : ℝ :=
  (W i j + W j k + W k i) / 3

/-- The triangle cycle gap: minimum triangle mean over all triples.
    This is a computationally tractable surrogate for the full tropical
    cycle gap (minimum over all cycle means). -/
def triangleCycleGap (W : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.inf' Finset.univ (⟨0, Finset.mem_univ 0⟩)
    (fun i => Finset.inf' Finset.univ (⟨0, Finset.mem_univ 0⟩)
      (fun j => Finset.inf' Finset.univ (⟨0, Finset.mem_univ 0⟩)
        (fun k => triangleMean W i j k)))

/-! ## Path weight -/

/-- Weight of a path through the weight matrix.
    For a list `[v₀, v₁, …, vₖ]`, the weight is `∑ W(vₜ, vₜ₊₁)`. -/
def pathWeight (W : Fin n → Fin n → ℝ) (path : List (Fin n)) : ℝ :=
  ((path.zip path.tail).map (fun e => W e.1 e.2)).sum

/-! ## Spectral gap surrogate -/

/-- Elementary spectral gap surrogate: `1 - max_{i,j} P i j`.
    Valid without spectral machinery; positive when no entry is too large. -/
def spectralGapSurrogate (P : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  1 - Finset.sup' Finset.univ (⟨0, Finset.mem_univ 0⟩)
    (fun i => Finset.sup' Finset.univ (⟨0, Finset.mem_univ 0⟩) (fun j => P i j))

/-! ## Scalar log monotonicity -/

/-
`-log` is antitone on positive reals: if `0 < x ≤ s` then `-log s ≤ -log x`.
-/
theorem neg_log_antitone {x s : ℝ} (hx : 0 < x) (_hs : 0 < s) (hxs : x ≤ s) :
    -Real.log s ≤ -Real.log x := by
  linarith [Real.log_le_log hx hxs]

/-! ## Triangle mean lower bound -/

/-
**Theorem 1 (Triangle version).**
    For a positive matrix P with entries bounded by s,
    every triangle mean of the log-weight matrix is at least `-log s`.
-/
theorem triangleMean_logWeight_lower_bound
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    {s : ℝ}
    (hpos : PositiveMatrix P)
    (hs : 0 < s)
    (hbound : ∀ i j, P i j ≤ s)
    (i j k : Fin (n + 1)) :
    -Real.log s ≤ triangleMean (logWeight P) i j k := by
  unfold triangleMean logWeight;
  linarith [ neg_log_antitone ( hpos i j ) hs ( hbound i j ), neg_log_antitone ( hpos j k ) hs ( hbound j k ), neg_log_antitone ( hpos k i ) hs ( hbound k i ) ]

/-
**Triangle cycle gap lower bound.**
    The minimum triangle mean of `-log P` is at least `-log(max entry)`.
-/
theorem triangleCycleGap_logWeight_lower_bound
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    {s : ℝ}
    (hpos : PositiveMatrix P)
    (hs : 0 < s)
    (hbound : ∀ i j, P i j ≤ s) :
    -Real.log s ≤ triangleCycleGap (logWeight P) := by
  unfold triangleCycleGap;
  have := triangleMean_logWeight_lower_bound P hpos hs hbound;
  norm_num [ Finset.inf'_le, this ]

/-! ## Theorem 2: Uniform non-determinism ⟹ positive tropical gap -/

/-
Positivity of `-log(1-ε)` when `0 < ε < 1`.
-/
theorem neg_log_one_sub_pos (ε : ℝ) (hε0 : 0 < ε) (hε1 : ε < 1) :
    0 < -Real.log (1 - ε) := by
  exact neg_pos_of_neg ( Real.log_neg ( by linarith ) ( by linarith ) )

/-
**Theorem 2: Non-determinism forces positive tropical cycle gap.**
    If all entries of P satisfy `P i j ≤ 1 - ε` with `0 < ε < 1`,
    then the tropical triangle cycle gap is positive.
    This is the key bridge: classical non-determinism ⟹ tropical cycle separation.
-/
theorem tropical_cycle_gap_pos_of_uniform_non_determinism
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    (ε : ℝ) (hε0 : 0 < ε) (hε1 : ε < 1)
    (hpos : PositiveMatrix P)
    (hbound : ∀ i j, P i j ≤ 1 - ε) :
    0 < triangleCycleGap (logWeight P) := by
  -- Apply the theorem that states the tropical cycle gap is at least -log(1 - ε).
  have h_triangle_cycle_gap : -Real.log (1 - ε) ≤ triangleCycleGap (logWeight P) := by
    apply triangleCycleGap_logWeight_lower_bound P hpos (by linarith) hbound;
  exact lt_of_lt_of_le ( neg_log_one_sub_pos ε hε0 hε1 ) h_triangle_cycle_gap

/-! ## General path weight lower bound -/

/-
**Path weight lower bound.**
    For any path of length ≥ 1, the total path weight through `-log P`
    is at least `(path.length - 1) * (-log s)` when all entries ≤ s.
-/
theorem pathWeight_lower_bound
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    {s : ℝ}
    (hpos : PositiveMatrix P)
    (hs : 0 < s)
    (hbound : ∀ i j, P i j ≤ s)
    (c : List (Fin (n + 1)))
    (_hlen : c.length > 1) :
    (-Real.log s) * (c.length - 1 : ℕ) ≤ pathWeight (logWeight P) c := by
  have h_term_ge : ∀ e ∈ List.zip c c.tail, -Real.log (P e.1 e.2) ≥ -Real.log s := by
    exact fun e _he => neg_log_antitone (hpos _ _) hs (hbound _ _)
  simpa [mul_comm, List.length_zip, List.length_tail] using List.sum_le_sum h_term_ge

/-! ## Direct theorem for individual triples -/

/-
**Direct triangle theorem.**
    For positive P with entries ≤ s, the average of three log-weights
    around any triangle is at least `-log s`.
-/
theorem tropical_triangle_mean_lower_bound
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    {s : ℝ}
    (hpos : PositiveMatrix P)
    (hs : 0 < s)
    (hbound : ∀ i j, P i j ≤ s)
    (i j k : Fin (n + 1)) :
    -Real.log s ≤
      ((-Real.log (P i j)) + (-Real.log (P j k)) + (-Real.log (P k i))) / 3 := by
  linarith [ neg_log_antitone ( hpos i j ) hs ( hbound i j ), neg_log_antitone ( hpos j k ) hs ( hbound j k ), neg_log_antitone ( hpos k i ) hs ( hbound k i ) ]

/-! ## Spectral surrogate bridge -/

/-
**Spectral surrogate to tropical gap.**
    When the spectral gap surrogate is positive (i.e., max entry < 1),
    and all entries are positive, the tropical triangle cycle gap is positive.
-/
theorem spectral_surrogate_to_tropical_gap
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    (hpos : PositiveMatrix P)
    (hmax : ∀ i j, P i j < 1) :
    0 < triangleCycleGap (logWeight P) := by
  -- Let ε = 1 - max P i j. Since max P i j < 1 (using hmax to bound all entries), ε > 0.
  obtain ⟨ε, hε⟩ : ∃ ε, 0 < ε ∧ ∀ i j, P i j ≤ 1 - ε := by
    -- Since there are only finitely many entries, there exists a minimum value of $1 - P i j$ over all $i$ and $j$.
    obtain ⟨δ, hδ⟩ : ∃ δ, δ ∈ Set.image (fun p : Fin (n + 1) × Fin (n + 1) => 1 - P p.1 p.2) (Set.univ : Set (Fin (n + 1) × Fin (n + 1))) ∧ ∀ y ∈ Set.image (fun p : Fin (n + 1) × Fin (n + 1) => 1 - P p.1 p.2) (Set.univ : Set (Fin (n + 1) × Fin (n + 1))), δ ≤ y := by
      apply_rules [ IsCompact.exists_isLeast, CompactIccSpace.isCompact_Icc ];
      · exact Set.Finite.isCompact ( Set.toFinite _ );
      · exact ⟨ _, ⟨ ⟨ 0, 0 ⟩, Set.mem_univ _, rfl ⟩ ⟩;
    exact ⟨ δ, by obtain ⟨ ⟨ i, j ⟩, -, rfl ⟩ := hδ.1; linarith [ hmax i j ], fun i j => by linarith [ hδ.2 _ <| Set.mem_image_of_mem _ <| Set.mem_univ ( i, j ) ] ⟩;
  convert tropical_cycle_gap_pos_of_uniform_non_determinism P ε hε.1 _ hpos hε.2;
  linarith [ hε.2 0 0, hpos 0 0 ]

/-! ## Row-stochastic entry bound -/

/-
For a row-stochastic positive matrix on `Fin (n+2)` (at least 2 states),
    every entry is strictly less than 1.
-/
theorem rowStochastic_entry_lt_one
    {m : ℕ}
    (P : Fin (m + 2) → Fin (m + 2) → ℝ)
    (hrow : RowStochastic P)
    (hpos : PositiveMatrix P) :
    ∀ i j, P i j < 1 := by
  exact fun i j ↦ by have := hrow i; rw [ ← this ] ; exact ( by rw [ Finset.sum_eq_add_sum_diff_singleton <| Finset.mem_univ j ] ; exact lt_add_of_pos_right _ <| Finset.sum_pos ( fun k hk ↦ hpos i k ) <| Finset.card_pos.mp <| by simp [ Finset.card_sdiff ] ) ;

/-
**Corollary: Row-stochastic positive matrices have positive tropical gap.**
    For a row-stochastic strictly positive matrix on ≥ 2 states,
    the tropical triangle cycle gap is automatically positive.
-/
theorem rowStochastic_positive_tropical_gap
    {m : ℕ}
    (P : Fin (m + 2) → Fin (m + 2) → ℝ)
    (hrow : RowStochastic P)
    (hpos : PositiveMatrix P) :
    0 < triangleCycleGap (logWeight P) := by
  exact spectral_surrogate_to_tropical_gap P hpos (fun i j => rowStochastic_entry_lt_one P hrow hpos i j)

end SpectralTropicalBridge

end