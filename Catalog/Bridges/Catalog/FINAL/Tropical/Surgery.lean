import Mathlib

/-!
# Tropical Surgery: Rank-2 Min-Plus Matrix Updates and Spectral Monotonicity

This file develops a theory of "tropical surgery" on min-plus matrices,
proving that rank-2 min-plus updates (taking entrywise minima with outer products)
yield spectrally monotone perturbations.

## Main Definitions

* `tropicalRankOneUpdate` - rank-1 outer product in min-plus algebra
* `tropicalRankTwoSurgery` - rank-2 surgery: min with two outer products
* `twoEntrySurgery` - localized surgery at exactly two entries
* `closedWalkWeight` - total weight of a closed walk in a weighted digraph
* `cycleMean` - average edge weight of a closed walk
* `tropicalSpectralRadius` - minimum cycle mean (tropical eigenvalue)

## Main Results

* `tropicalRankTwoSurgery_le` - surgery yields entrywise ≤
* `closedWalkWeight_mono` - walk weight is monotone under entrywise ≤
* `cycleMean_mono` - cycle mean is monotone under entrywise ≤
* `tropicalSpectralRadius_mono` - spectral radius is monotone under entrywise ≤
* `tropicalRankTwoSurgery_spectral_bound` - main theorem: surgery decreases spectral radius
* `rankOne_spectralRadius_le_diag_min` - spectral radius of rank-1 matrix ≤ min diagonal
* `tropicalRankTwoSurgery_explicit_bound` - explicit bound from update vectors

## References

This formalizes the tropical analogue of rank-2 matrix perturbation theory.
In min-plus algebra, the spectral radius equals the minimum cycle mean of the
associated weighted digraph. Surgery (taking entrywise minima) is the tropical
analogue of additive low-rank updates.
-/

noncomputable section

open Finset

/-! ## Part 1: Surgery Definitions -/

/-- A rank-one tropical (min-plus) outer product: the matrix with entries `u(i) + v(j)`. -/
def tropicalRankOneUpdate {n : ℕ} (u v : Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => u i + v j

/-- Rank-two tropical surgery: replace `A` by the entrywise minimum of `A` with
    two rank-one outer products. This is the tropical analogue of a rank-2 update. -/
def tropicalRankTwoSurgery {n : ℕ} (A : Fin n → Fin n → ℝ)
    (u v u' v' : Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => min (A i j) (min (u i + v j) (u' i + v' j))

/-- Localized two-entry surgery: decrease at most two specific matrix entries. -/
def twoEntrySurgery {n : ℕ} (A : Fin n → Fin n → ℝ)
    (i₁ j₁ i₂ j₂ : Fin n) (c₁ c₂ : ℝ) : Fin n → Fin n → ℝ :=
  fun i j =>
    if i = i₁ ∧ j = j₁ then min (A i j) c₁
    else if i = i₂ ∧ j = j₂ then min (A i j) c₂
    else A i j

/-! ## Part 2: Cycle Weight and Cycle Mean -/

/-- Weight of a closed walk of length `k` specified by vertex sequence `σ`.
    The walk visits `σ(0) → σ(1) → ⋯ → σ(k-1) → σ(0)`. -/
def closedWalkWeight {n : ℕ} (A : Fin n → Fin n → ℝ) {k : ℕ} (hk : 0 < k)
    (σ : Fin k → Fin n) : ℝ :=
  ∑ t : Fin k, A (σ t) (σ ⟨(t.val + 1) % k, Nat.mod_lt _ hk⟩)

/-- Mean edge weight of a closed walk (cycle mean). -/
def cycleMean {n : ℕ} (A : Fin n → Fin n → ℝ) {k : ℕ} (hk : 0 < k)
    (σ : Fin k → Fin n) : ℝ :=
  closedWalkWeight A hk σ / (k : ℝ)

/-- Auxiliary type: a walk parameter is a pair of a length index and a vertex sequence. -/
abbrev WalkParam (n : ℕ) := Σ (k : Fin (n + 1)), (Fin (k.val + 1) → Fin (n + 1))

/-- Cycle mean of the walk specified by a `WalkParam`. -/
def walkParamCycleMean {n : ℕ} (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (p : WalkParam n) : ℝ :=
  cycleMean A (Nat.succ_pos p.1.val) p.2

/-! ## Part 3: Tropical Spectral Radius -/

/-- The tropical spectral radius of an `(n+1) × (n+1)` matrix, defined as the minimum
    cycle mean over all closed walks of length 1 through `n+1`.

    This equals the classical minimum cycle mean of the associated weighted digraph,
    which is the tropical eigenvalue of the matrix in min-plus algebra. -/
def tropicalSpectralRadius {n : ℕ} (A : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (walkParamCycleMean A)

/-! ## Part 4: Entrywise Bounds for Surgery -/

/-- Rank-two surgery yields an entrywise smaller-or-equal matrix. -/
theorem tropicalRankTwoSurgery_le {n : ℕ} (A : Fin n → Fin n → ℝ)
    (u v u' v' : Fin n → ℝ) (i j : Fin n) :
    tropicalRankTwoSurgery A u v u' v' i j ≤ A i j := by
  simp [tropicalRankTwoSurgery]

/-- Two-entry surgery yields an entrywise smaller-or-equal matrix. -/
theorem twoEntrySurgery_le {n : ℕ} (A : Fin n → Fin n → ℝ)
    (i₁ j₁ i₂ j₂ : Fin n) (c₁ c₂ : ℝ) (i j : Fin n) :
    twoEntrySurgery A i₁ j₁ i₂ j₂ c₁ c₂ i j ≤ A i j := by
  simp only [twoEntrySurgery]
  split_ifs <;> simp

/-- Rank-one surgery (min with a single outer product) yields entrywise ≤. -/
theorem tropicalRankOneSurgery_le {n : ℕ} (A : Fin n → Fin n → ℝ)
    (u v : Fin n → ℝ) (i j : Fin n) :
    min (A i j) (u i + v j) ≤ A i j :=
  min_le_left _ _

/-! ## Part 5: Cycle Weight and Cycle Mean Monotonicity -/

/-
If `B` is entrywise ≤ `A`, then every closed walk has smaller-or-equal weight in `B`.
-/
theorem closedWalkWeight_mono {n : ℕ} {A B : Fin n → Fin n → ℝ} {k : ℕ}
    (hk : 0 < k) (σ : Fin k → Fin n) (h : ∀ i j, B i j ≤ A i j) :
    closedWalkWeight B hk σ ≤ closedWalkWeight A hk σ := by
  exact Finset.sum_le_sum fun i _ => h _ _

/-
If `B` is entrywise ≤ `A`, then every cycle mean is smaller-or-equal in `B`.
-/
theorem cycleMean_mono {n : ℕ} {A B : Fin n → Fin n → ℝ} {k : ℕ}
    (hk : 0 < k) (σ : Fin k → Fin n) (h : ∀ i j, B i j ≤ A i j) :
    cycleMean B hk σ ≤ cycleMean A hk σ := by
  exact div_le_div_of_nonneg_right ( closedWalkWeight_mono hk σ h ) ( Nat.cast_nonneg _ )

/-
Walk-parameter level monotonicity.
-/
theorem walkParamCycleMean_mono {n : ℕ} {A B : Fin (n + 1) → Fin (n + 1) → ℝ}
    (h : ∀ i j, B i j ≤ A i j) (p : WalkParam n) :
    walkParamCycleMean B p ≤ walkParamCycleMean A p := by
  convert cycleMean_mono _ _ h

/-! ## Part 6: Spectral Radius Monotonicity -/

/-
**Tropical spectral monotonicity**: if `B` is entrywise ≤ `A`,
    then the tropical spectral radius of `B` is ≤ that of `A`.

    This is the key structural theorem: entrywise decrease of matrix entries
    cannot increase the minimum cycle mean.
-/
theorem tropicalSpectralRadius_mono {n : ℕ} {A B : Fin (n + 1) → Fin (n + 1) → ℝ}
    (h : ∀ i j, B i j ≤ A i j) :
    tropicalSpectralRadius B ≤ tropicalSpectralRadius A := by
  -- Let $C$ be a walk-parameter cycle mean that achieves the infimum for $B$.
  by_contra h_contra;
  unfold tropicalSpectralRadius at h_contra;
  simp_all +decide [ Finset.inf'_le_iff ];
  obtain ⟨ a, b, h ⟩ := h_contra;
  exact not_le_of_gt ( h a b ) ( walkParamCycleMean_mono ‹_› ⟨ a, b ⟩ )

/-! ## Part 7: Main Surgery Spectral Theorems -/

/-
**Main Theorem (Rank-2 Tropical Spectral Monotonicity).**
    Rank-two surgery cannot increase the tropical spectral radius.
-/
theorem tropicalRankTwoSurgery_spectral_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (u v u' v' : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (tropicalRankTwoSurgery A u v u' v') ≤
      tropicalSpectralRadius A := by
  -- Apply the lemma that states if `B` is entrywise ≤ `A`, then the tropical spectral radius of `B` is ≤ that of `A`.
  apply tropicalSpectralRadius_mono
  exact fun i j => tropicalRankTwoSurgery_le A u v u' v' i j

/-
Two-entry surgery cannot increase the tropical spectral radius.
-/
theorem twoEntrySurgery_spectral_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (i₁ j₁ i₂ j₂ : Fin (n + 1)) (c₁ c₂ : ℝ) :
    tropicalSpectralRadius (twoEntrySurgery A i₁ j₁ i₂ j₂ c₁ c₂) ≤
      tropicalSpectralRadius A := by
  grind +suggestions

/-
Rank-one surgery cannot increase the tropical spectral radius.
-/
theorem tropicalRankOneSurgery_spectral_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (u v : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (fun i j => min (A i j) (u i + v j)) ≤
      tropicalSpectralRadius A := by
  convert tropicalSpectralRadius_mono _;
  exact fun i j => min_le_left _ _

/-! ## Part 8: Spectral Radius of Rank-One Matrices -/

/-
The spectral radius of a rank-one matrix `u ⊕ v` (with entry `u(i) + v(j)`)
    is at most `min_i (u(i) + v(i))`.

    For rank-one matrices, every cycle mean equals the average of `u(σ(t)) + v(σ(t))`
    over the cycle vertices, so the minimum is achieved by the constant cycle at the
    vertex minimizing `u(i) + v(i)`.
-/
theorem rankOne_spectralRadius_le_diag_min {n : ℕ}
    (u v : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (tropicalRankOneUpdate u v) ≤
      Finset.univ.inf' Finset.univ_nonempty (fun i => u i + v i) := by
  -- The cycle mean of the vertex `i` is exactly `u(i) + v(i)`.
  have h_vertex_cycle_mean (i : Fin (n + 1)) :
      cycleMean (tropicalRankOneUpdate u v) (Nat.succ_pos i.val) (fun _ => i) = u i + v i := by
        unfold cycleMean closedWalkWeight; norm_num;
        unfold tropicalRankOneUpdate; rw [ mul_div_cancel_left₀ _ <| by positivity ] ;
  simp +decide [ ← h_vertex_cycle_mean, tropicalSpectralRadius ];
  exact fun i => ⟨ ⟨ i, by linarith [ Fin.is_lt i ] ⟩, fun _ => i, by rfl ⟩

/-! ## Part 9: Explicit Spectral Bound for Rank-Two Surgery -/

/-
**Explicit bound**: the spectral radius after rank-two surgery is at most
    the minimum of the original spectral radius and the diagonal minima of
    the two rank-one components.
-/
theorem tropicalRankTwoSurgery_explicit_bound {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (u v u' v' : Fin (n + 1) → ℝ) :
    tropicalSpectralRadius (tropicalRankTwoSurgery A u v u' v') ≤
      min (tropicalSpectralRadius A)
        (min (Finset.univ.inf' Finset.univ_nonempty (fun i => u i + v i))
             (Finset.univ.inf' Finset.univ_nonempty (fun i => u' i + v' i))) := by
  refine' le_min _ _;
  · exact tropicalRankTwoSurgery_spectral_bound A u v u' v'
  · refine' le_min _ _;
    · refine' le_trans _ ( rankOne_spectralRadius_le_diag_min u v );
      refine' tropicalSpectralRadius_mono _;
      exact fun i j => min_le_of_right_le ( min_le_left _ _ );
    · exact le_trans ( tropicalSpectralRadius_mono fun i j => by unfold tropicalRankTwoSurgery; aesop ) ( rankOne_spectralRadius_le_diag_min u' v' )

/-! ## Part 10: Algebraic Properties of Min-Plus -/

/-
Addition distributes over min from the left: `a + min(b,c) = min(a+b, a+c)`.
-/
theorem tropical_add_min_left (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := by
  grind

/-
Addition distributes over min from the right: `min(a,b) + c = min(a+c, b+c)`.
-/
theorem tropical_add_min_right (a b c : ℝ) :
    min a b + c = min (a + c) (b + c) := by
  rw [ min_add_add_right ]

/-! ## Part 11: Surgery Composition -/

/-
Two rank-one surgeries compose to give (at most) a rank-two surgery.
-/
theorem rankOne_compose_le_rankTwo {n : ℕ}
    (A : Fin n → Fin n → ℝ) (u v u' v' : Fin n → ℝ) (i j : Fin n) :
    min (min (A i j) (u i + v j)) (u' i + v' j) ≤
      tropicalRankTwoSurgery A u v u' v' i j := by
  unfold tropicalRankTwoSurgery; aesop;

/-
Rank-two surgery is idempotent: applying it twice gives the same result.
-/
theorem tropicalRankTwoSurgery_idem {n : ℕ}
    (A : Fin n → Fin n → ℝ) (u v u' v' : Fin n → ℝ) (i j : Fin n) :
    tropicalRankTwoSurgery (tropicalRankTwoSurgery A u v u' v') u v u' v' i j =
      tropicalRankTwoSurgery A u v u' v' i j := by
  unfold tropicalRankTwoSurgery;
  grind

/-
Surgery with large outer products (u(i)+v(j) ≥ A(i,j) for all i,j) is identity.
-/
theorem tropicalRankTwoSurgery_of_ge {n : ℕ}
    (A : Fin n → Fin n → ℝ) (u v u' v' : Fin n → ℝ)
    (hu : ∀ i j, A i j ≤ u i + v j) (hv : ∀ i j, A i j ≤ u' i + v' j)
    (i j : Fin n) :
    tropicalRankTwoSurgery A u v u' v' i j = A i j := by
  exact min_eq_left ( by cases min_cases ( u i + v j ) ( u' i + v' j ) <;> linarith [ hu i j, hv i j ] )

/-! ## Part 12: Connection to Graph Theory -/

/-
The diagonal entry `A(i,i)` is the cycle mean of the self-loop at vertex `i`.
-/
theorem selfLoop_cycleMean {n : ℕ} (A : Fin (n + 1) → Fin (n + 1) → ℝ)
    (i : Fin (n + 1)) :
    cycleMean A (Nat.succ_pos 0) (fun _ => i) = A i i := by
  unfold cycleMean;
  unfold closedWalkWeight; norm_num;

/-
The spectral radius is at most any diagonal entry.
-/
theorem tropicalSpectralRadius_le_diag {n : ℕ}
    (A : Fin (n + 1) → Fin (n + 1) → ℝ) (i : Fin (n + 1)) :
    tropicalSpectralRadius A ≤ A i i := by
  norm_num [ tropicalSpectralRadius ];
  exact ⟨ ⟨ 0, Nat.le_add_left _ _ ⟩, fun _ => i, by unfold walkParamCycleMean; exact selfLoop_cycleMean A i ▸ le_rfl ⟩

end