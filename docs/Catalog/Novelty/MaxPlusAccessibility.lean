/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Accessibility and the matching lower bound for idempotent large deviations

`Novelty.MaxPlusRateGeometry` proves the large-deviation *upper* bound
`limsup Wₙ(C) ≤ - inf_C rate` for arbitrary velocity sets `C`, and
`Novelty.MaxPlusCramer` identifies `- rate x` with the best mixture score at `x`.

What is still missing for a genuine idempotent large-deviation principle is a matching
*lower* bound.  In the max-plus world the obstruction is purely arithmetic: a length-`n`
path can only realize velocities whose mixture weights are multiples of `1/n`.  This file
isolates that obstruction and removes it under an explicit accessibility hypothesis.

## Main results

* `twoBlockPath` and `sum_twoBlockPath` — the elementary explicit paths that realize a
  rational two-point mixture exactly.
* `MaxPlusLaw.le_eventWeightE_of_velocity_mem` — any realizing path bounds the event
  weight from below.
* `MaxPlusLaw.le_limsup_eventWeightE_of_accessible` — the lower bound along the
  arithmetic progression of accessible lengths.
* `maxPlus_LDP_of_accessible_minimizer` — **a complete idempotent LDP**: for a velocity
  set whose rate infimum is attained at an accessible velocity carrying an optimality
  certificate, `limsup Wₙ(G) = - inf_G rate` exactly.
-/

import Novelty.MaxPlusCramer

open scoped BigOperators
open Finset

namespace IdempotentProbability

/-! ## Two-block paths -/

/-- The length-`N` path that uses the increment `i` for its first `K` steps and the
increment `j` afterwards.  These are the paths realizing a rational two-point mixture. -/
def twoBlockPath {ι : Type*} (i j : ι) (N K : ℕ) : Fin N → ι :=
  fun t => if (t : ℕ) < K then i else j

/-- The additive statistics of a two-block path are exactly the corresponding
two-point mixture, scaled by the length. -/
theorem sum_twoBlockPath {ι : Type*} (g : ι → ℝ) (i j : ι) {N K : ℕ} (h : K ≤ N) :
    ∑ t : Fin N, g (twoBlockPath i j N K t) = (K : ℝ) * g i + ((N : ℝ) - K) * g j := by
  simp only [twoBlockPath]
  rw [Fin.sum_univ_eq_sum_range (fun t => g (if t < K then i else j)) N]
  simp only [apply_ite g]
  rw [Finset.sum_ite]
  have h1 : (Finset.range N).filter (fun t => t < K) = Finset.range K := by
    ext a; simp; omega
  have h2 : (Finset.range N).filter (fun t => ¬ t < K) = Finset.Ico K N := by
    ext a; simp [Finset.mem_Ico]; omega
  rw [h1, h2, Finset.sum_const, Finset.sum_const, Nat.card_Ico, Finset.card_range,
    nsmul_eq_mul, nsmul_eq_mul, Nat.cast_sub h]

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Every path realizing a velocity in `C` is a lower bound for the extended-real
max-plus weight of the event `C`. -/
theorem MaxPlusLaw.le_eventWeightE_of_velocity_mem (μ : MaxPlusLaw ι) {n : ℕ} (C : Set ℝ)
    (p : Fin n → ι) (hp : μ.empiricalVelocity p ∈ C) :
    ((μ.pathScore p : ℝ) : EReal) ≤ μ.eventWeightE n C :=
  le_sSup ⟨p, hp, rfl⟩

/-! ## Accessible velocities -/

/-- A rational two-point mixture is realized *exactly* by a path of any length that is a
multiple of the denominator: the empirical velocity is the prescribed one, and the
normalized score is the prescribed mixture score. -/
theorem MaxPlusLaw.eventWeightE_ge_of_accessible (μ : MaxPlusLaw ι) (i j : ι)
    {q k : ℕ} (hq : 0 < q) (hk : k ≤ q) (C : Set ℝ)
    (hC : ((k : ℝ) * μ.value i + ((q : ℝ) - k) * μ.value j) / q ∈ C)
    {m : ℕ} (hm : 0 < m) :
    ((((k : ℝ) * μ.weight i + ((q : ℝ) - k) * μ.weight j) / q : ℝ) : EReal) ≤
      μ.eventWeightE (m * q) C := by
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  have hmR : (0:ℝ) < m := by exact_mod_cast hm
  have hKN : k * m ≤ m * q := by
    calc k * m ≤ q * m := Nat.mul_le_mul_right m hk
      _ = m * q := Nat.mul_comm _ _
  have hstat : ∀ g : ι → ℝ,
      (∑ t : Fin (m * q), g (twoBlockPath i j (m * q) (k * m) t)) / ((m * q : ℕ) : ℝ)
        = ((k : ℝ) * g i + ((q : ℝ) - k) * g j) / q := by
    intro g
    rw [sum_twoBlockPath g i j hKN]
    push_cast
    field_simp
  have hvel : μ.empiricalVelocity (twoBlockPath i j (m * q) (k * m))
      = ((k : ℝ) * μ.value i + ((q : ℝ) - k) * μ.value j) / q := hstat μ.value
  have hsc : μ.pathScore (twoBlockPath i j (m * q) (k * m))
      = ((k : ℝ) * μ.weight i + ((q : ℝ) - k) * μ.weight j) / q := hstat μ.weight
  have := μ.le_eventWeightE_of_velocity_mem C (twoBlockPath i j (m * q) (k * m))
    (by rw [hvel]; exact hC)
  rwa [hsc] at this

/-- **Lower bound along accessible lengths.**  If a velocity in `C` is realized by a
rational two-point mixture with denominator `q`, then the mixture score is a lower bound
for the limit superior of the event weights: it is achieved exactly, infinitely often. -/
theorem MaxPlusLaw.le_limsup_eventWeightE_of_accessible (μ : MaxPlusLaw ι) (i j : ι)
    {q k : ℕ} (hq : 0 < q) (hk : k ≤ q) (C : Set ℝ)
    (hC : ((k : ℝ) * μ.value i + ((q : ℝ) - k) * μ.value j) / q ∈ C) :
    ((((k : ℝ) * μ.weight i + ((q : ℝ) - k) * μ.weight j) / q : ℝ) : EReal) ≤
      Filter.limsup (fun n => μ.eventWeightE n C) Filter.atTop := by
  refine Filter.le_limsup_of_frequently_le ?_ (Filter.isBoundedUnder_of ⟨⊤, fun n => le_top⟩)
  rw [Filter.frequently_atTop]
  intro a
  refine ⟨(a + 1) * q, ?_, μ.eventWeightE_ge_of_accessible i j hq hk C hC (Nat.succ_pos a)⟩
  calc a ≤ a + 1 := Nat.le_succ a
    _ = (a + 1) * 1 := by ring
    _ ≤ (a + 1) * q := Nat.mul_le_mul_left _ hq

/-! ## A complete idempotent large-deviation principle -/

/-- **Full LDP at an accessible minimizer.**  Let `G` be any set of velocities and suppose

* `x` is realized by the rational two-point mixture `(k/q, 1 - k/q)` on the increments
  `i, j` and lies in `G`;
* that mixture carries an *optimality certificate*: a tilt `θ` under which the mixture
  score dominates every tilted increment score;
* `x` minimizes the rate function over `G`.

Then the limit superior of the extended-real event weights equals `-inf_G rate` exactly.
Together with `maxPlus_limsup_le_neg_sInf_rate` (the unconditional upper bound) this is a
genuine max-plus large-deviation principle for `G`; the accessibility hypothesis is what
compensates for the arithmetic obstruction that a length-`n` path can only realize
mixtures with denominator dividing `n`. -/
theorem maxPlus_LDP_of_accessible_minimizer (μ : MaxPlusLaw ι) (G : Set ℝ) (i j : ι)
    {q k : ℕ} (hq : 0 < q) (hk : k ≤ q) (θ : ℝ)
    (hxG : ((k : ℝ) * μ.value i + ((q : ℝ) - k) * μ.value j) / q ∈ G)
    (hcert : ∀ l : ι, μ.weight l + θ * μ.value l ≤
      (((k : ℝ) * μ.weight i + ((q : ℝ) - k) * μ.weight j) / q) +
        θ * (((k : ℝ) * μ.value i + ((q : ℝ) - k) * μ.value j) / q))
    (hmin : ∀ y ∈ G, μ.rate (((k : ℝ) * μ.value i + ((q : ℝ) - k) * μ.value j) / q) ≤ μ.rate y) :
    Filter.limsup (fun n => μ.eventWeightE n G) Filter.atTop =
      ((-sInf (μ.rate '' G) : ℝ) : EReal) := by
  classical
  set x : ℝ := ((k : ℝ) * μ.value i + ((q : ℝ) - k) * μ.value j) / q with hx
  set s : ℝ := ((k : ℝ) * μ.weight i + ((q : ℝ) - k) * μ.weight j) / q with hs
  have hqR : (0:ℝ) < q := by exact_mod_cast hq
  have hkq : (k : ℝ) ≤ q := by exact_mod_cast hk
  -- the two-point mixture behind `x`
  set c : ℝ := (k : ℝ) / q with hc
  set lam : ι → ℝ := fun l => (if l = i then c else 0) + (if l = j then 1 - c else 0) with hlam
  have hmeanF : ∀ f : ι → ℝ, ∑ l, lam l * f l = c * f i + (1 - c) * f j := by
    intro f; rw [hlam]; simp [add_mul, Finset.sum_add_distrib, ite_mul]
  have hcv : ∀ f : ι → ℝ,
      c * f i + (1 - c) * f j = ((k : ℝ) * f i + ((q : ℝ) - k) * f j) / q := by
    intro f; rw [hc]; field_simp
  have hmix : μ.IsMixture x lam := by
    refine ⟨?_, ?_, ?_⟩
    · intro l
      have h1 : (0:ℝ) ≤ if l = i then c else 0 := by
        split_ifs
        · exact div_nonneg (Nat.cast_nonneg k) (le_of_lt hqR)
        · exact le_refl 0
      have h2 : (0:ℝ) ≤ if l = j then 1 - c else 0 := by
        split_ifs
        · rw [hc, sub_nonneg, div_le_one hqR]; exact hkq
        · exact le_refl 0
      linarith
    · rw [hlam]; simp [Finset.sum_add_distrib]
    · rw [hmeanF, hcv, hx]
  have hscore : ∑ l, lam l * μ.weight l = s := by rw [hmeanF, hcv, hs]
  -- the certificate turns the mixture into the exact rate
  have hrate : μ.rate x = -s := by
    have := μ.rate_eq_neg_of_supported_mixture hmix θ (by rw [hscore]; exact hcert)
    rwa [hscore] at this
  -- the infimum of the rate over `G` is attained at `x`
  have hleast : IsLeast (μ.rate '' G) (μ.rate x) := by
    refine ⟨⟨x, hxG, rfl⟩, ?_⟩
    rintro _ ⟨y, hy, rfl⟩
    exact hmin y hy
  have hInf : sInf (μ.rate '' G) = μ.rate x := hleast.csInf_eq
  rw [hInf, hrate]
  refine le_antisymm ?_ ?_
  · have := maxPlus_limsup_le_neg_sInf_rate μ G
    rwa [hInf, hrate] at this
  · have := μ.le_limsup_eventWeightE_of_accessible i j hq hk G hxG
    simpa using this

end IdempotentProbability