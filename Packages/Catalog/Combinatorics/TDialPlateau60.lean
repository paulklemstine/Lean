/-
# T-DIAL-60: the rank-correlation degradation plateaus at a strictly positive floor

Round-49 #2 (exp 512) reports that at bit length 60 the `T`-dial still scores
`Spearman(T, rate) = 0.437` with bootstrap interval `[0.393, 0.480]`, that the degradation
of the dial with growing bit length *plateaus* instead of continuing to zero, and that `T`
still beats plain `count` by `+0.070`.  This file supplies the exact combinatorial mechanism
that can produce such a plateau, and proves it.

## The model

A dial is a *ranking*: it produces, for `n` items, a rank map `f` which is a permutation of
`{0,…,n-1}` (`PermRange`).  The measured statistic is Spearman's coefficient
`ρ(f) = 1 - 6 ∑ (i - f i)² / (n³ - n)` (`rho`, built on `sqDisp`).

Degradation is modelled by *block localisation* (`BlockPerm n a m f`): growing bit length
destroys the dial's ordering information only inside a window of `m` consecutive ranks (the
"starved" zone where the QR-lottery gives no discrimination), leaving the coarse order
outside intact.

## Main results

* `three_mul_sqDisp_add_rev` — an exact **reversal duality**
  `3∑(i-f i)² + 3∑(i-(n-1-f i))² = n³-n`, i.e. `ρ(f) + ρ(rev ∘ f) = 0`.
* `three_mul_sqDisp_le`, `three_mul_sqDisp_revMap`, `eq_revMap_of_sqDisp_max` — the sharp
  extremal bound `3∑d² ≤ n³-n`, its unique maximiser (the reversal), hence `-1 ≤ ρ ≤ 1`.
* `sqDisp_block_eq`, `three_mul_sqDisp_block_le` — block transfer: a window-localised dial
  has `3∑d² ≤ m³-m`, a bound depending on the window width only.
* `plateau_floor` (**main theorem**) — if the scrambled window occupies at most a fraction
  `α ≤ 1` of the ranks then `ρ ≥ 1 - 2α³` *uniformly in `n`*; `plateau_pos` turns this into
  a strictly positive floor whenever `2α³ < 1` (`α < 2^{-1/3} ≈ 0.7937`).  This is the
  refutation of H1 (monotone continuation to zero) inside the model.
* `rho_blockRev`, `rho_blockRev_strict_anti`, `rho_blockRev_pos_iff` — the exact degradation
  curve of the worst window dial, its strict monotonicity in the window width, and the
  phase transition at `2(m³-m) = n³-n`.
* `rho_blockRev_alpha_law`, `rho_blockRev_tendsto` — the curve is `1 - 2α³` in the shape
  parameter `α = m/n` up to an error `2/(n²-1)`, and converges to it exactly: the floor is
  attained, not merely bounded.
* `plateau_value_in_reported_CI`, `plateau_floor_60` — calibration: window width `α = 0.66`
  predicts the plateau value `1 - 2·0.66³ = 0.425008`, which lies inside the reported
  interval `[0.393, 0.480]`, and every instance with `α ≤ 0.66` scores at least `0.425`.
* `T_beats_count` — a `T`-dial with `α_T ≤ 0.66` beats a `count`-dial with `α_C ≥ 0.69` by
  at least `0.070` in Spearman correlation, for every instance with `n ≥ 20`.
* `sqDisp_seg_eq`, `three_mul_sqDisp_seg_le`, `fragmentation_floor`, `fragmentation_half`
  (second cycle) — the *starved-everywhere* regime: if the ranks are cut into `k` segments
  and the dial is scrambled inside every segment, then `ρ ≥ 1 - 2/k²` whatever the segment
  length; with `k ≥ 2` the dial keeps `ρ ≥ 1/2`.  Total local starvation therefore still
  cannot send the correlation to zero — only coarse-order loss can.

## Lab notes (numerics feeding the statements; all re-proved below)

Brute force over all permutations of `{0,…,m-1}` (`m ≤ 7`) gives
`max ∑ d² = 0, 0, 2, 8, 20, 40, 70, 112` for `m = 0,…,7`, matching `(m³-m)/3` exactly —
see `sqDisp_ten_seven` for the `m = 7` instance and `three_mul_sqDisp_le` for the theorem.

| `n` | `m` | `ρ = 1-2(m³-m)/(n³-n)` | shape law `1-2(m/n)³` |
| --- | --- | --- | --- |
| 10 | 3 | 0.951515 | 0.946000 |
| 10 | 7 | 0.321212 | 0.314000 |
| 60 | 40 | 0.407613 | 0.407407 |
| 100 | 66 | 0.425083 | 0.425008 |
| 1000 | 660 | 0.425009 | 0.425008 |

The last two rows are the plateau: the reading is stationary in `n` at fixed shape `α`,
which is exactly `plateau_floor` + `rho_blockRev_tendsto`.  The observed `0.437` sits at
`α ≈ 0.655`; `0.66` is the rational calibration used here.
-/
import Mathlib

open Finset

namespace Catalog.TDialPlateau

/-- `PermRange n f` says that `f` restricts to a permutation of the ranks `{0,…,n-1}`. -/
structure PermRange (n : ℕ) (f : ℕ → ℕ) : Prop where
  maps : ∀ i < n, f i < n
  inj : ∀ i < n, ∀ j < n, f i = f j → i = j

lemma PermRange.image_eq {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f) :
    (range n).image f = range n := by
  refine Finset.eq_of_subset_of_card_le ?_ ?_
  · intro x hx
    simp only [Finset.mem_image, Finset.mem_range] at hx ⊢
    obtain ⟨i, hi, rfl⟩ := hx
    exact hp.maps i hi
  · rw [Finset.card_image_of_injOn
      (fun i hi j hj h => hp.inj i (mem_range.1 hi) j (mem_range.1 hj) h)]

lemma PermRange.sum_comp {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f) (F : ℕ → ℤ) :
    ∑ i ∈ range n, F (f i) = ∑ i ∈ range n, F i := by
  conv_rhs => rw [← hp.image_eq]
  rw [Finset.sum_image (fun i hi j hj h => hp.inj i (mem_range.1 hi) j (mem_range.1 hj) h)]

/-! ## Elementary power sums -/

lemma two_mul_sum_range (n : ℕ) :
    2 * ∑ i ∈ range n, (i : ℤ) = (n : ℤ) ^ 2 - n := by
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ]; push_cast; push_cast at ih; linarith

lemma six_mul_sum_range_sq (n : ℕ) :
    6 * ∑ i ∈ range n, (i : ℤ) ^ 2 = 2 * (n : ℤ) ^ 3 - 3 * (n : ℤ) ^ 2 + n := by
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ]; push_cast; push_cast at ih; nlinarith [ih]

/-! ## Squared rank displacement -/

/-- The Spearman squared-displacement statistic `∑ (i - f i)²` of a rank map `f` on `n` ranks. -/
def sqDisp (n : ℕ) (f : ℕ → ℕ) : ℤ := ∑ i ∈ range n, ((i : ℤ) - (f i : ℤ)) ^ 2

lemma sqDisp_nonneg (n : ℕ) (f : ℕ → ℕ) : 0 ≤ sqDisp n f :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

lemma sqDisp_eq_zero_of_id (n : ℕ) : sqDisp n id = 0 := by
  simp [sqDisp]

/-- `sqDisp` expanded through the inner product `∑ i · f i`. -/
lemma sqDisp_eq {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f) :
    sqDisp n f = 2 * (∑ i ∈ range n, (i : ℤ) ^ 2) - 2 * ∑ i ∈ range n, (i : ℤ) * (f i : ℤ) := by
  have hsq : ∑ i ∈ range n, ((f i : ℤ)) ^ 2 = ∑ i ∈ range n, (i : ℤ) ^ 2 :=
    hp.sum_comp (fun j => (j : ℤ) ^ 2)
  have hexp : sqDisp n f
      = ∑ i ∈ range n, ((i : ℤ) ^ 2 + ((f i : ℤ)) ^ 2 - 2 * ((i : ℤ) * (f i : ℤ))) := by
    unfold sqDisp
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hexp, Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hsq]
  ring

/-- Cauchy–Schwarz for rank permutations: `∑ i · f i ≤ ∑ i²`. -/
lemma sum_mul_le {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f) :
    ∑ i ∈ range n, (i : ℤ) * (f i : ℤ) ≤ ∑ i ∈ range n, (i : ℤ) ^ 2 := by
  have h0 : 0 ≤ sqDisp n f := sqDisp_nonneg n f
  rw [sqDisp_eq hp] at h0
  linarith

/-- The reversal of a rank permutation is again a rank permutation. -/
lemma PermRange.rev {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f) :
    PermRange n (fun i => n - 1 - f i) where
  maps := by
    intro i hi
    have := hp.maps i hi
    omega
  inj := by
    intro i hi j hj h
    have h1 := hp.maps i hi
    have h2 := hp.maps j hj
    exact hp.inj i hi j hj (by omega)

/-- **Reversal duality.** For every rank permutation `f` of `{0,…,n-1}` the squared
displacements of `f` and of its reversal `i ↦ n-1-f i` add up to exactly `(n³-n)/3`.
This is the exact form of the antisymmetry `ρ(f) + ρ(rev ∘ f) = 0` of Spearman's statistic. -/
theorem three_mul_sqDisp_add_rev {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f) :
    3 * sqDisp n f + 3 * sqDisp n (fun i => n - 1 - f i) = (n : ℤ) ^ 3 - n := by
  set S1 : ℤ := ∑ i ∈ range n, (i : ℤ) with hS1
  set S2 : ℤ := ∑ i ∈ range n, (i : ℤ) ^ 2 with hS2
  have e1 : 2 * S1 = (n : ℤ) ^ 2 - n := two_mul_sum_range n
  have e2 : 6 * S2 = 2 * (n : ℤ) ^ 3 - 3 * (n : ℤ) ^ 2 + n := six_mul_sum_range_sq n
  -- the reversed permutation
  have hrev := hp.rev
  have hQeq : ∑ i ∈ range n, (i : ℤ) * ((n - 1 - f i : ℕ) : ℤ)
      = ((n : ℤ) - 1) * S1 - ∑ i ∈ range n, (i : ℤ) * (f i : ℤ) := by
    rw [hS1, Finset.mul_sum, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun i hi => ?_
    have hi' : i < n := mem_range.1 hi
    have hfi : f i < n := hp.maps i hi'
    have hcast : ((n - 1 - f i : ℕ) : ℤ) = (n : ℤ) - 1 - (f i : ℤ) := by omega
    rw [hcast]; ring
  have hDf := sqDisp_eq hp
  have hDg := sqDisp_eq hrev
  rw [← hS2] at hDf hDg
  rw [hDf, hDg, hQeq]
  linear_combination 2 * e2 - 3 * ((n : ℤ) - 1) * e1

/-- **Sharp extremal bound.** For every rank permutation of `{0,…,n-1}`,
`3 · ∑ (i - f i)² ≤ n³ - n`; equivalently Spearman's `ρ ≥ -1`. -/
theorem three_mul_sqDisp_le {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f) :
    3 * sqDisp n f ≤ (n : ℤ) ^ 3 - n := by
  have h := three_mul_sqDisp_add_rev hp
  have h0 := sqDisp_nonneg n (fun i => n - 1 - f i)
  linarith

lemma sqDisp_eq_zero_iff {n : ℕ} {f : ℕ → ℕ} :
    sqDisp n f = 0 ↔ ∀ i < n, f i = i := by
  constructor
  · intro h i hi
    have hterm : ∀ j ∈ range n, ((j : ℤ) - (f j : ℤ)) ^ 2 = 0 := by
      refine (Finset.sum_eq_zero_iff_of_nonneg fun j _ => sq_nonneg _).1 h
    have := hterm i (mem_range.2 hi)
    have : (i : ℤ) - (f i : ℤ) = 0 := by nlinarith [this]
    omega
  · intro h
    refine Finset.sum_eq_zero fun i hi => ?_
    rw [h i (mem_range.1 hi)]
    ring

/-- The rank-reversing map on `{0,…,n-1}`. -/
def revMap (n : ℕ) : ℕ → ℕ := fun i => n - 1 - i

lemma permRange_id (n : ℕ) : PermRange n id := ⟨fun _ h => h, fun _ _ _ _ h => h⟩

lemma permRange_revMap (n : ℕ) : PermRange n (revMap n) := by
  refine ⟨fun i hi => by simp only [revMap]; omega, fun i hi j hj h => ?_⟩
  simp only [revMap] at h
  omega

/-- The reversal is the *unique maximiser*: `3 · ∑ (i - revMap i)² = n³ - n` exactly. -/
theorem three_mul_sqDisp_revMap (n : ℕ) : 3 * sqDisp n (revMap n) = (n : ℤ) ^ 3 - n := by
  have h := three_mul_sqDisp_add_rev (permRange_id n)
  have h0 : sqDisp n (id : ℕ → ℕ) = 0 := sqDisp_eq_zero_of_id n
  simp only [id_eq] at h h0
  rw [h0] at h
  simpa [revMap] using h

/-- **Equality case of the extremal bound**: only the reversal attains `ρ = -1`. -/
theorem eq_revMap_of_sqDisp_max {n : ℕ} {f : ℕ → ℕ} (hp : PermRange n f)
    (hmax : 3 * sqDisp n f = (n : ℤ) ^ 3 - n) : ∀ i < n, f i = revMap n i := by
  have h := three_mul_sqDisp_add_rev hp
  have hz : sqDisp n (fun i => n - 1 - f i) = 0 := by linarith
  intro i hi
  have := (sqDisp_eq_zero_iff).1 hz i hi
  have hfi := hp.maps i hi
  simp only [revMap]
  omega

/-! ## Block-localised rank maps: the degradation model -/

/-- `BlockPerm n a m f` : the rank map `f` acts as the identity outside the window
`[a, a+m)` and permutes that window.  This is the formal model of a dial whose ordering
information has been destroyed only inside a window of relative width `m/n`. -/
structure BlockPerm (n a m : ℕ) (f : ℕ → ℕ) : Prop where
  fits : a + m ≤ n
  fix : ∀ i, i < a ∨ a + m ≤ i → f i = i
  into : ∀ j < m, a ≤ f (a + j) ∧ f (a + j) < a + m
  shift_perm : PermRange m (fun j => f (a + j) - a)

/-- A block-localised map is a genuine rank permutation of `{0,…,n-1}`. -/
lemma BlockPerm.permRange {n a m : ℕ} {f : ℕ → ℕ} (hb : BlockPerm n a m f) :
    PermRange n f := by
  constructor
  · intro i hi
    by_cases h : a ≤ i ∧ i < a + m
    · obtain ⟨h1, h2⟩ := h
      have := hb.into (i - a) (by omega)
      have hia : a + (i - a) = i := by omega
      rw [hia] at this
      have := hb.fits
      omega
    · rw [hb.fix i (by omega)]; exact hi
  · intro i hi j hj h
    by_cases hai : a ≤ i ∧ i < a + m <;> by_cases haj : a ≤ j ∧ j < a + m
    · obtain ⟨hi1, hi2⟩ := hai
      obtain ⟨hj1, hj2⟩ := haj
      have e1 : a + (i - a) = i := by omega
      have e2 : a + (j - a) = j := by omega
      have := hb.shift_perm.inj (i - a) (by omega) (j - a) (by omega)
        (by simp only [e1, e2, h])
      omega
    · rw [hb.fix j (by omega)] at h
      obtain ⟨hi1, hi2⟩ := hai
      have hin := hb.into (i - a) (by omega)
      have e1 : a + (i - a) = i := by omega
      rw [e1] at hin
      omega
    · rw [hb.fix i (by omega)] at h
      obtain ⟨hj1, hj2⟩ := haj
      have hin := hb.into (j - a) (by omega)
      have e2 : a + (j - a) = j := by omega
      rw [e2] at hin
      omega
    · rw [hb.fix i (by omega), hb.fix j (by omega)] at h
      exact h

/-- **Block transfer.** The Spearman displacement of a block-localised map equals the
displacement of the induced permutation of the window, translated to `{0,…,m-1}`. -/
theorem sqDisp_block_eq {n a m : ℕ} {f : ℕ → ℕ} (hb : BlockPerm n a m f) :
    sqDisp n f = sqDisp m (fun j => f (a + j) - a) := by
  have hsub : Finset.Ico a (a + m) ⊆ range n := by
    intro x hx
    simp only [Finset.mem_Ico] at hx
    have := hb.fits
    exact mem_range.2 (by omega)
  have hzero : ∀ x ∈ range n, x ∉ Finset.Ico a (a + m) → ((x : ℤ) - (f x : ℤ)) ^ 2 = 0 := by
    intro x _ hx
    simp only [Finset.mem_Ico, not_and, not_lt] at hx
    rw [hb.fix x (by rcases lt_or_ge x a with h | h; exacts [Or.inl h, Or.inr (hx h)])]
    ring
  have hsplit : ∑ i ∈ Finset.Ico a (a + m), ((i : ℤ) - (f i : ℤ)) ^ 2 = sqDisp n f :=
    Finset.sum_subset hsub hzero
  rw [← hsplit, Finset.sum_Ico_eq_sum_range]
  rw [Nat.add_sub_cancel_left]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hj' : j < m := mem_range.1 hj
  have hin := hb.into j hj'
  have hcast : ((f (a + j) - a : ℕ) : ℤ) = (f (a + j) : ℤ) - a := by omega
  rw [hcast]
  push_cast
  ring

/-- **Degradation bound.** A dial whose ordering is scrambled only inside a window of
width `m` has squared displacement at most `(m³-m)/3`, *independently of `n`*. -/
theorem three_mul_sqDisp_block_le {n a m : ℕ} {f : ℕ → ℕ} (hb : BlockPerm n a m f) :
    3 * sqDisp n f ≤ (m : ℤ) ^ 3 - m := by
  rw [sqDisp_block_eq hb]
  exact three_mul_sqDisp_le hb.shift_perm

/-- The worst dial supported on the window `[a, a+m)`: the window is order-reversed. -/
def blockRev (a m : ℕ) : ℕ → ℕ := fun i => if a ≤ i ∧ i < a + m then a + (m - 1 - (i - a)) else i

lemma blockRev_add {a m j : ℕ} (hj : j < m) : blockRev a m (a + j) = a + (m - 1 - j) := by
  simp only [blockRev]
  rw [if_pos (by omega)]
  congr 1
  omega

lemma blockPerm_blockRev {n a m : ℕ} (hfits : a + m ≤ n) :
    BlockPerm n a m (blockRev a m) := by
  refine ⟨hfits, ?_, ?_, ?_⟩
  · intro i hi
    simp only [blockRev]
    rw [if_neg (by omega)]
  · intro j hj
    rw [blockRev_add hj]
    omega
  · constructor
    · intro j hj
      rw [blockRev_add hj]
      omega
    · intro i hi j hj h
      rw [blockRev_add hi, blockRev_add hj] at h
      omega

/-- The block reversal attains the degradation bound exactly. -/
theorem three_mul_sqDisp_blockRev {n a m : ℕ} (hfits : a + m ≤ n) :
    3 * sqDisp n (blockRev a m) = (m : ℤ) ^ 3 - m := by
  rw [sqDisp_block_eq (blockPerm_blockRev hfits)]
  have hfun : sqDisp m (fun j => blockRev a m (a + j) - a) = sqDisp m (revMap m) := by
    refine Finset.sum_congr rfl fun j hj => ?_
    simp only
    rw [blockRev_add (mem_range.1 hj)]
    simp only [revMap]
    congr 2
    omega
  rw [hfun]
  exact three_mul_sqDisp_revMap m

/-! ## Spearman's rank correlation and the plateau -/

/-- Spearman's rank correlation coefficient of a rank map `f` against the identity ranking. -/
noncomputable def rho (n : ℕ) (f : ℕ → ℕ) : ℝ :=
  1 - 6 * (sqDisp n f : ℝ) / ((n : ℝ) ^ 3 - (n : ℝ))

lemma denom_pos {n : ℕ} (hn : 2 ≤ n) : 0 < (n : ℝ) ^ 3 - (n : ℝ) := by
  have h : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have h1 : (0 : ℝ) < (n : ℝ) := by linarith
  nlinarith [mul_pos h1 h1]

lemma rho_le_one {n : ℕ} (hn : 2 ≤ n) (f : ℕ → ℕ) : rho n f ≤ 1 := by
  have hd := denom_pos hn
  have h0 : (0 : ℝ) ≤ (sqDisp n f : ℝ) := by exact_mod_cast sqDisp_nonneg n f
  have : 0 ≤ 6 * (sqDisp n f : ℝ) / ((n : ℝ) ^ 3 - n) := by positivity
  simp only [rho]
  linarith

lemma neg_one_le_rho {n : ℕ} {f : ℕ → ℕ} (hn : 2 ≤ n) (hp : PermRange n f) : -1 ≤ rho n f := by
  have hd := denom_pos hn
  have h : (3 : ℝ) * (sqDisp n f : ℝ) ≤ (n : ℝ) ^ 3 - n := by
    exact_mod_cast three_mul_sqDisp_le hp
  have hdiv : 6 * (sqDisp n f : ℝ) / ((n : ℝ) ^ 3 - n) ≤ 2 := by
    rw [div_le_iff₀ hd]; linarith
  simp only [rho]
  linarith

lemma rho_id {n : ℕ} : rho n id = 1 := by
  simp [rho, sqDisp_eq_zero_of_id n]

/-- The reversal dial sits exactly at `ρ = -1`. -/
lemma rho_revMap {n : ℕ} (hn : 2 ≤ n) : rho n (revMap n) = -1 := by
  have hd := denom_pos hn
  have h : (3 : ℝ) * (sqDisp n (revMap n) : ℝ) = (n : ℝ) ^ 3 - n := by
    exact_mod_cast three_mul_sqDisp_revMap n
  have h6 : 6 * (sqDisp n (revMap n) : ℝ) = 2 * ((n : ℝ) ^ 3 - n) := by linarith
  have hcancel : 2 * ((n : ℝ) ^ 3 - n) / ((n : ℝ) ^ 3 - n) = 2 :=
    mul_div_cancel_right₀ 2 (ne_of_gt hd)
  simp only [rho, h6, hcancel]
  norm_num

/-- **Degradation floor for a block-localised dial.** -/
theorem rho_block_ge {n a m : ℕ} {f : ℕ → ℕ} (hb : BlockPerm n a m f) (hn : 2 ≤ n) :
    1 - 2 * ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n) ≤ rho n f := by
  have hd := denom_pos hn
  have h : (3 : ℝ) * (sqDisp n f : ℝ) ≤ (m : ℝ) ^ 3 - m := by
    exact_mod_cast three_mul_sqDisp_block_le hb
  simp only [rho]
  have hsub : 0 ≤ 2 * ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n)
      - 6 * (sqDisp n f : ℝ) / ((n : ℝ) ^ 3 - n) := by
    rw [div_sub_div_same]
    exact div_nonneg (by linarith) hd.le
  linarith

/-- Elementary comparison: if `1 ≤ M ≤ αN`, `0 ≤ α ≤ 1` and `2 ≤ N`, then
`M³ - M ≤ α³(N³ - N)`.  This is what converts a *window-width* hypothesis into a
*correlation floor*. -/
lemma cube_ratio_le {M N alpha : ℝ} (hM1 : 1 ≤ M) (hMN : M ≤ alpha * N)
    (ha0 : 0 ≤ alpha) (ha1 : alpha ≤ 1) (hN : 2 ≤ N) :
    M ^ 3 - M ≤ alpha ^ 3 * (N ^ 3 - N) := by
  have hNpos : (0 : ℝ) < N := by linarith
  have hu1 : 1 ≤ alpha * N := le_trans hM1 hMN
  have hcube : alpha ^ 3 ≤ alpha := by
    nlinarith [mul_nonneg (mul_nonneg ha0 (sub_nonneg.2 ha1)) (by linarith : (0 : ℝ) ≤ 1 + alpha)]
  have hkey : alpha ^ 3 * N ≤ alpha * N := by nlinarith
  have hsq : (1 : ℝ) ≤ M ^ 2 := by nlinarith
  have hmono : M ^ 3 - M ≤ (alpha * N) ^ 3 - alpha * N := by
    nlinarith [mul_nonneg (sub_nonneg.2 hMN)
      (by nlinarith : (0 : ℝ) ≤ (alpha * N) ^ 2 + (alpha * N) * M + M ^ 2 - 1)]
  calc M ^ 3 - M ≤ (alpha * N) ^ 3 - alpha * N := hmono
    _ ≤ alpha ^ 3 * (N ^ 3 - N) := by nlinarith [hkey]

/-- **T-DIAL-60 PLATEAU (main theorem).** If the ordering information of a dial is
destroyed only inside a window occupying at most a fraction `α ≤ 1` of the ranks, then its
Spearman correlation with the true ranking is at least `1 - 2α³`, *uniformly in the number
of ranks `n`*.  Hence the degradation cannot continue past this floor: for `2α³ < 1` the
signal is bounded away from `0` no matter how large the instance gets. -/
theorem plateau_floor {n a m : ℕ} {f : ℕ → ℕ} {alpha : ℝ} (hb : BlockPerm n a m f)
    (hn : 2 ≤ n) (hm : 1 ≤ m) (hfrac : (m : ℝ) ≤ alpha * n)
    (ha0 : 0 ≤ alpha) (ha1 : alpha ≤ 1) :
    1 - 2 * alpha ^ 3 ≤ rho n f := by
  have hd := denom_pos hn
  have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hN : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hcmp := cube_ratio_le hM1 hfrac ha0 ha1 hN
  have hstep : 2 * ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n) ≤ 2 * alpha ^ 3 := by
    rw [div_le_iff₀ hd]; nlinarith
  have := rho_block_ge hb hn
  linarith

/-- The plateau is a strictly positive floor once the scrambled window is thinner than
`2^{-1/3}` of the whole range: the QR-lottery signal stabilises, it does not vanish. -/
theorem plateau_pos {n a m : ℕ} {f : ℕ → ℕ} {alpha : ℝ} (hb : BlockPerm n a m f)
    (hn : 2 ≤ n) (hm : 1 ≤ m) (hfrac : (m : ℝ) ≤ alpha * n)
    (ha0 : 0 ≤ alpha) (ha1 : alpha ≤ 1) (hthin : 2 * alpha ^ 3 < 1) :
    0 < rho n f :=
  lt_of_lt_of_le (by linarith) (plateau_floor hb hn hm hfrac ha0 ha1)

/-! ## The exact degradation curve of the worst block dial -/

/-- The block-reversal dial has an *exactly* computable Spearman coefficient. -/
theorem rho_blockRev {n a m : ℕ} (hfits : a + m ≤ n) :
    rho n (blockRev a m) = 1 - 2 * ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n) := by
  have h : (3 : ℝ) * (sqDisp n (blockRev a m) : ℝ) = (m : ℝ) ^ 3 - m := by
    exact_mod_cast three_mul_sqDisp_blockRev hfits
  have h6 : 6 * (sqDisp n (blockRev a m) : ℝ) = 2 * ((m : ℝ) ^ 3 - m) := by linarith
  simp only [rho, h6]

/-- **Monotone degradation.** Widening the scrambled window strictly lowers the dial. -/
theorem rho_blockRev_strict_anti {n a m m' : ℕ} (hm : 1 ≤ m) (hmm : m < m')
    (hfits : a + m' ≤ n) (hn : 2 ≤ n) :
    rho n (blockRev a m') < rho n (blockRev a m) := by
  have hd := denom_pos hn
  have hfits' : a + m ≤ n := by omega
  rw [rho_blockRev hfits', rho_blockRev hfits]
  have hM : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hMM : (m : ℝ) < (m' : ℝ) := by exact_mod_cast hmm
  have hnum : (m : ℝ) ^ 3 - m < (m' : ℝ) ^ 3 - m' := by
    have h1 : (0 : ℝ) < (m' : ℝ) - (m : ℝ) := by linarith
    have h2 : (0 : ℝ) < (m' : ℝ) ^ 2 + (m' : ℝ) * (m : ℝ) + (m : ℝ) ^ 2 - 1 := by nlinarith
    nlinarith [mul_pos h1 h2]
  have hlt : 2 * ((m : ℝ) ^ 3 - m) / ((n : ℝ) ^ 3 - n)
      < 2 * ((m' : ℝ) ^ 3 - m') / ((n : ℝ) ^ 3 - n) := by
    rw [div_lt_div_iff_of_pos_right hd]
    linarith
  linarith

/-- **Phase transition.** The worst block dial is still positively correlated with the true
ranking exactly when the scrambled window satisfies `2(m³-m) < n³-n`, i.e. asymptotically
when its relative width is below `2^{-1/3} ≈ 0.7937`. -/
theorem rho_blockRev_pos_iff {n a m : ℕ} (hfits : a + m ≤ n) (hn : 2 ≤ n) :
    0 < rho n (blockRev a m) ↔ 2 * ((m : ℝ) ^ 3 - m) < (n : ℝ) ^ 3 - n := by
  have hd := denom_pos hn
  rw [rho_blockRev hfits, sub_pos, div_lt_one hd]

/-- **The `α`-law with an explicit error term.** The degradation curve of the worst block
dial is `1 - 2α³` in the relative window width `α = m/n`, up to an error `2/(n²-1)`.
So the plateau value is a genuine function of the *shape* parameter alone. -/
theorem rho_blockRev_alpha_law {n a m : ℕ} (hfits : a + m ≤ n) (hn : 2 ≤ n) :
    |rho n (blockRev a m) - (1 - 2 * ((m : ℝ) / n) ^ 3)| ≤ 2 / ((n : ℝ) ^ 2 - 1) := by
  have hd := denom_pos hn
  have hN : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hNpos : (0 : ℝ) < (n : ℝ) := by linarith
  have hMn : (m : ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : m ≤ n)
  have hM0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  have hsq : (0 : ℝ) < (n : ℝ) ^ 2 - 1 := by nlinarith
  have hkey : rho n (blockRev a m) - (1 - 2 * ((m : ℝ) / n) ^ 3)
      = 2 * (m : ℝ) * ((n : ℝ) ^ 2 - (m : ℝ) ^ 2) / ((n : ℝ) ^ 2 * ((n : ℝ) ^ 3 - n)) := by
    rw [rho_blockRev hfits]
    field_simp
    ring
  rw [hkey, abs_le]
  constructor
  · have hpos : (0 : ℝ) < 2 / ((n : ℝ) ^ 2 - 1) := by positivity
    have : (0 : ℝ) ≤ 2 * (m : ℝ) * ((n : ℝ) ^ 2 - (m : ℝ) ^ 2)
        / ((n : ℝ) ^ 2 * ((n : ℝ) ^ 3 - n)) := by
      apply div_nonneg
      · nlinarith [mul_nonneg hM0 (mul_nonneg (sub_nonneg.2 hMn)
          (by linarith : (0 : ℝ) ≤ (n : ℝ) + (m : ℝ)))]
      · positivity
    linarith
  · rw [div_le_div_iff₀ (by positivity) hsq]
    nlinarith [mul_nonneg hM0 (sub_nonneg.2 hMn), sq_nonneg ((n : ℝ) - (m : ℝ)),
      mul_nonneg (mul_nonneg hM0 hM0) hM0]

/-- **Sharpness of the plateau.** Along the family with `n = q(k+1)` ranks and a scrambled
window of `m = p(k+1)` ranks, the Spearman coefficient of the worst block dial converges to
exactly `1 - 2(p/q)³`.  So the floor of `plateau_floor` is *attained* in the limit: the
plateau value is the true asymptotic level, not an artefact of the estimate. -/
theorem rho_blockRev_tendsto {p q : ℕ} (hpq : p ≤ q) (hq : 2 ≤ q) :
    Filter.Tendsto (fun k : ℕ => rho (q * (k + 1)) (blockRev 0 (p * (k + 1)))) Filter.atTop
      (nhds (1 - 2 * ((p : ℝ) / q) ^ 3)) := by
  rw [← tendsto_sub_nhds_zero_iff]
  refine squeeze_zero_norm (a := fun k : ℕ => 2 / ((k : ℝ) + 1)) (fun k => ?_) ?_
  · have hk : (0 : ℝ) < (k : ℝ) + 1 := by positivity
    have hn : 2 ≤ q * (k + 1) := le_trans hq (Nat.le_mul_of_pos_right q (Nat.succ_pos k))
    have hfits : 0 + p * (k + 1) ≤ q * (k + 1) := by
      simpa using Nat.mul_le_mul_right (k + 1) hpq
    have habs := rho_blockRev_alpha_law hfits hn
    have hq0 : (0 : ℝ) < (q : ℝ) := by
      have : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
      linarith
    have hratio : ((p * (k + 1) : ℕ) : ℝ) / ((q * (k + 1) : ℕ) : ℝ) = (p : ℝ) / q := by
      push_cast
      rw [mul_comm (p : ℝ), mul_comm (q : ℝ), mul_div_mul_left _ _ (ne_of_gt hk)]
    rw [hratio] at habs
    have hQ : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
    have hNbig : ((k : ℝ) + 1) ≤ (((q * (k + 1) : ℕ) : ℝ)) ^ 2 - 1 := by
      have hcast : ((q * (k + 1) : ℕ) : ℝ) = (q : ℝ) * ((k : ℝ) + 1) := by push_cast; ring
      rw [hcast]
      have ht1 : (1 : ℝ) ≤ (k : ℝ) + 1 := by linarith
      have hq2 : (4 : ℝ) ≤ (q : ℝ) ^ 2 := by nlinarith
      have htt : ((k : ℝ) + 1) ≤ ((k : ℝ) + 1) ^ 2 := by nlinarith
      nlinarith [mul_le_mul_of_nonneg_right hq2 (sq_nonneg ((k : ℝ) + 1))]
    calc ‖rho (q * (k + 1)) (blockRev 0 (p * (k + 1))) - (1 - 2 * ((p : ℝ) / q) ^ 3)‖
        = |rho (q * (k + 1)) (blockRev 0 (p * (k + 1))) - (1 - 2 * ((p : ℝ) / q) ^ 3)| :=
          Real.norm_eq_abs _
      _ ≤ 2 / (((q * (k + 1) : ℕ) : ℝ) ^ 2 - 1) := habs
      _ ≤ 2 / ((k : ℝ) + 1) := by
          gcongr
  · simpa using (tendsto_one_div_add_atTop_nhds_zero_nat (𝕜 := ℝ)).const_mul (2 : ℝ)

/-! ## Calibration against the round-49 measurement, and the T-versus-count gap -/

/-- The predicted plateau value for a scrambled window of relative width `33/50 = 0.66`
lies inside the reported bootstrap interval `[0.393, 0.480]` for `Spearman(T, rate)` at
bit length 60. -/
theorem plateau_value_in_reported_CI :
    (0.393 : ℝ) ≤ 1 - 2 * (33 / 50 : ℝ) ^ 3 ∧ 1 - 2 * (33 / 50 : ℝ) ^ 3 ≤ 0.480 := by
  norm_num

/-- **Calibrated plateau.** A dial scrambled on at most `66%` of the ranks keeps Spearman
correlation at least `0.425`, for every instance size `n ≥ 2`.  This is the formal content
of "the degradation reaches a floor at ≈ 0.44 instead of vanishing". -/
theorem plateau_floor_60 {n a m : ℕ} {f : ℕ → ℕ} (hb : BlockPerm n a m f)
    (hn : 2 ≤ n) (hm : 1 ≤ m) (hfrac : 50 * (m : ℝ) ≤ 33 * n) :
    (0.425 : ℝ) ≤ rho n f := by
  have hfrac' : (m : ℝ) ≤ (33 / 50 : ℝ) * n := by linarith
  have h := plateau_floor hb hn hm hfrac' (by norm_num) (by norm_num)
  nlinarith [h]

/-- **T still beats count.** A `T`-dial scrambled on at most `66%` of the ranks outscores a
`count`-dial whose top `69%` of ranks are order-reversed by more than `0.07` in Spearman
correlation, for every instance with at least `20` ranks. -/
theorem T_beats_count {n a b mT mC : ℕ} {fT : ℕ → ℕ} (hT : BlockPerm n a mT fT)
    (hmT : 1 ≤ mT) (hTfrac : 50 * (mT : ℝ) ≤ 33 * n)
    (hCfits : b + mC ≤ n) (hCfrac : (69 : ℝ) * n ≤ 100 * mC) (hn : 20 ≤ n) :
    (0.07 : ℝ) ≤ rho n fT - rho n (blockRev b mC) := by
  have hn2 : 2 ≤ n := by omega
  have hN : (20 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hNpos : (0 : ℝ) < (n : ℝ) := by linarith
  have hlow := plateau_floor_60 hT hn2 hmT hTfrac
  have habs := rho_blockRev_alpha_law hCfits hn2
  have hup : rho n (blockRev b mC) - (1 - 2 * ((mC : ℝ) / n) ^ 3) ≤ 2 / ((n : ℝ) ^ 2 - 1) :=
    (abs_le.1 habs).2
  have hfrac : (69 / 100 : ℝ) ≤ (mC : ℝ) / n := by
    rw [le_div_iff₀ hNpos]; linarith
  have hcube : (69 / 100 : ℝ) ^ 3 ≤ ((mC : ℝ) / n) ^ 3 := by gcongr
  have hbig : (399 : ℝ) ≤ (n : ℝ) ^ 2 - 1 := by nlinarith
  have herr : 2 / ((n : ℝ) ^ 2 - 1) ≤ 2 / 399 := by gcongr
  nlinarith [hlow, hup, hcube, herr]

/-! ## Fragmentation of the starved zone: why the degradation stops

The single-window model explains a plateau only while the scrambled window stays thinner
than `2^{-1/3}` of the range.  The regime actually observed at bit length 60 is *starved
everywhere*: local discrimination is lost across the whole range.  The following theorems
show that this still leaves a strictly positive floor, provided the loss is **local**: if
the range is cut into `k` segments and the dial is scrambled inside each segment, the
Spearman coefficient is at least `1 - 2/k²`, independently of the segment length.
-/

/-- `SegPerm k m f` : the ranks `{0,…,km-1}` are cut into `k` consecutive segments of length
`m`, and `f` permutes each segment separately — total local scrambling, intact coarse order. -/
structure SegPerm (k m : ℕ) (f : ℕ → ℕ) : Prop where
  into : ∀ j < k, ∀ i < m, j * m ≤ f (j * m + i) ∧ f (j * m + i) < j * m + m
  seg : ∀ j < k, PermRange m (fun i => f (j * m + i) - j * m)

/-- The displacement of a segment-wise scrambled dial is the sum of the segment
displacements. -/
theorem sqDisp_seg_eq {k m : ℕ} {f : ℕ → ℕ} (hs : SegPerm k m f) :
    sqDisp (k * m) f = ∑ j ∈ range k, sqDisp m (fun i => f (j * m + i) - j * m) := by
  induction k with
  | zero => simp [sqDisp]
  | succ k ih =>
    have hsk : SegPerm k m f :=
      ⟨fun j hj => hs.into j (by omega), fun j hj => hs.seg j (by omega)⟩
    have hsucc : (k + 1) * m = k * m + m := by ring
    have hsplit : sqDisp (k * m + m) f
        = sqDisp (k * m) f + ∑ i ∈ range m, (((k * m + i : ℕ) : ℤ) - (f (k * m + i) : ℤ)) ^ 2 := by
      simp only [sqDisp]
      exact Finset.sum_range_add _ _ _
    have hlast : ∑ i ∈ range m, (((k * m + i : ℕ) : ℤ) - (f (k * m + i) : ℤ)) ^ 2
        = sqDisp m (fun i => f (k * m + i) - k * m) := by
      refine Finset.sum_congr rfl fun i hi => ?_
      have hi' : i < m := mem_range.1 hi
      have hin := hs.into k (by omega) i hi'
      have hcast : ((f (k * m + i) - k * m : ℕ) : ℤ) = (f (k * m + i) : ℤ) - ((k * m : ℕ) : ℤ) := by
        omega
      simp only
      rw [hcast]
      push_cast
      ring
    rw [hsucc, hsplit, hlast, ih hsk, Finset.sum_range_succ]

/-- **Fragmentation bound.** Local scrambling inside `k` segments of length `m` costs at
most `k(m³-m)/3` in squared displacement. -/
theorem three_mul_sqDisp_seg_le {k m : ℕ} {f : ℕ → ℕ} (hs : SegPerm k m f) :
    3 * sqDisp (k * m) f ≤ (k : ℤ) * ((m : ℤ) ^ 3 - m) := by
  rw [sqDisp_seg_eq hs, Finset.mul_sum]
  calc ∑ j ∈ range k, 3 * sqDisp m (fun i => f (j * m + i) - j * m)
      ≤ ∑ _j ∈ range k, ((m : ℤ) ^ 3 - m) :=
        Finset.sum_le_sum fun j hj => three_mul_sqDisp_le (hs.seg j (mem_range.1 hj))
    _ = (k : ℤ) * ((m : ℤ) ^ 3 - m) := by
        rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]

/-- **Fragmentation plateau (main theorem of cycle 2).** Even when *every* rank sits inside
a scrambled zone, a dial that keeps the coarse order between `k` segments still scores
`ρ ≥ 1 - 2/k²`, independently of the segment length.  The starved regime therefore cannot
drive the correlation to zero; it can only push it to the fragmentation floor. -/
theorem fragmentation_floor {k m : ℕ} {f : ℕ → ℕ} (hs : SegPerm k m f) (hk : 1 ≤ k)
    (hn : 2 ≤ k * m) : 1 - 2 / (k : ℝ) ^ 2 ≤ rho (k * m) f := by
  have hd := denom_pos hn
  have hK : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hM0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  have hbound : (3 : ℝ) * (sqDisp (k * m) f : ℝ) ≤ (k : ℝ) * ((m : ℝ) ^ 3 - m) := by
    exact_mod_cast three_mul_sqDisp_seg_le hs
  have hcast : ((k * m : ℕ) : ℝ) = (k : ℝ) * (m : ℝ) := by push_cast; ring
  rw [hcast] at hd
  have hkey : 6 * (sqDisp (k * m) f : ℝ) / (((k : ℝ) * m) ^ 3 - (k : ℝ) * m) ≤ 2 / (k : ℝ) ^ 2 := by
    rw [div_le_div_iff₀ hd (by positivity)]
    nlinarith [hbound, mul_nonneg hM0 (sub_nonneg.2 hK), sq_nonneg ((k : ℝ) - 1),
      mul_nonneg (mul_nonneg hM0 hM0) hM0]
  simp only [rho, hcast]
  linarith

/-- With at least two segments the fragmented dial is still at least half-correlated with
the truth, however long the segments are. -/
theorem fragmentation_half {k m : ℕ} {f : ℕ → ℕ} (hs : SegPerm k m f) (hk : 2 ≤ k)
    (hn : 2 ≤ k * m) : (1 : ℝ) / 2 ≤ rho (k * m) f := by
  have hK : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have h := fragmentation_floor hs (by omega) hn
  have : 2 / (k : ℝ) ^ 2 ≤ 1 / 2 := by
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith
  linarith

/-! ## Lab-notes instances (numerically checked, then proved) -/

/-- `n = 10` ranks, window `[0,7)` order-reversed: `∑ d² = 112 = (7³-7)/3`. -/
theorem sqDisp_ten_seven : sqDisp 10 (blockRev 0 7) = 112 := by
  have h := three_mul_sqDisp_blockRev (n := 10) (a := 0) (m := 7) (by norm_num)
  norm_num at h
  omega

/-- The same instance in correlation units: `ρ = 1 - 672/990 ≈ 0.3212`. -/
theorem rho_ten_seven : rho 10 (blockRev 0 7) = 1 - 672 / 990 := by
  rw [rho_blockRev (by norm_num)]
  norm_num

/-- Two segments of length three, each order-reversed: a concrete fragmented dial. -/
def segRevTwo : ℕ → ℕ := fun i => if i < 3 then 2 - i else if i < 6 then 8 - i else i

theorem segPerm_segRevTwo : SegPerm 2 3 segRevTwo := by
  constructor
  · intro j hj i hi
    interval_cases j <;> interval_cases i <;> simp [segRevTwo]
  · intro j hj
    refine ⟨fun i hi => ?_, fun i hi i' hi' h => ?_⟩
    · interval_cases j <;> interval_cases i <;> simp [segRevTwo]
    · interval_cases j <;> interval_cases i <;> interval_cases i' <;>
        simp_all [segRevTwo]

/-- The fragmented dial of `segPerm_segRevTwo` reads `ρ = 1 - 96/210 ≈ 0.5429`, above the
fragmentation floor `1 - 2/2² = 0.5` guaranteed by `fragmentation_half`. -/
theorem rho_segRevTwo : rho 6 segRevTwo = 1 - 96 / 210 := by
  have hD : sqDisp 6 segRevTwo = 16 := by
    norm_num [sqDisp, segRevTwo, Finset.sum_range_succ]
  simp only [rho, hD]
  norm_num

/-- A `100`-rank instance at the calibrated window width `66%`: the dial still reads
`ρ > 0.42`, matching the measured plateau. -/
theorem rho_hundred_sixtysix_gt : (0.42 : ℝ) < rho 100 (blockRev 0 66) := by
  rw [rho_blockRev (by norm_num)]
  norm_num

end Catalog.TDialPlateau