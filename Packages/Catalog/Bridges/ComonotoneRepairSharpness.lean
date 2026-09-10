/-
# Scaling laws and sharpness of the repair-distance / discordance comparison

Continuation of `Bridges.ComonotoneRepairDistance`, which established

* `g · δ ≤ Δ` (dimension-free, `g` = separation of the footprint values), and
* `Δ ≤ 2 · |ι| · R · δ` (`R` = range of the footprint),

for the comonotone repair distance `δ = repairDist x y` and the discordance mass
`Δ = discordanceMass x y`.

This file explains *why* those are the right shapes, by two independent structural
mechanisms.

## 1.  Degree: both functionals are positively homogeneous of degree one in the rates

`discordanceMass_smul` and `repairDist_smul` show `Δ(x, c·y) = c·Δ(x, y)` and
`δ(x, c·y) = c·δ(x, y)` for `c ≥ 0`.  Consequently *no* comparison of the form
`δ^α ≤ C · Δ` with `α > 1` can hold: rescaling the rates multiplies the left side by `c^α`
and the right side by `c`.  `no_superlinear_comparison` makes this quantitative for
`α = 2`, refuting the conjectured `δ² ≤ Δ` for a whole one-parameter family rather than a
single accident.

## 2.  Dimension: an explicit family attaining half of the upper bound

`famX m`, `famY m` is the `n = m+2`-key population with equally spaced footprints
`0, 1, …, n-1` and rates `(1, 0, …, 0)`: one high outlier sitting at the smallest
footprint.  A single coordinate move of ℓ¹ size `1` repairs it (`famRepairDist`), while its
discordance mass is `n(n-1)` (`famDiscordanceMass`).  Since the range is `R = n-1`, the
population realises

  `Δ = n(n-1) = ½ · (2 n R δ)`,

exactly half of the general upper bound (`upper_bound_sharp_up_to_two`).  Hence the
population-size factor is unavoidable, and no bound `Δ ≤ C · R · δ` with a constant `C`
can hold (`no_bound_linear_in_range`).

Together with the refutations of the previous file, the shape
`g · δ ≤ Δ ≤ 2 |ι| R · δ` is pinned down: the exponent on the left is forced by
homogeneity, and the `|ι|` on the right is forced by this family.
-/
import Bridges.ComonotoneRepairDistance

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-! ### Positive homogeneity in the rates -/

lemma discordanceMass_smul (x y : ι → ℝ) {c : ℝ} (hc : 0 ≤ c) :
    discordanceMass x (fun i => c * y i) = c * discordanceMass x y := by
  simp only [discordanceMass, Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  have h : -((x i - x j) * (c * y i - c * y j)) = c * -((x i - x j) * (y i - y j)) := by ring
  rw [h]
  rcases le_or_gt 0 (-((x i - x j) * (y i - y j))) with hp | hn
  · rw [max_eq_left hp, max_eq_left (mul_nonneg hc hp)]
  · have hcn : c * -((x i - x j) * (y i - y j)) ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hc hn.le
    rw [max_eq_right hn.le, max_eq_right hcn, mul_zero]

lemma l1norm_smul (d : ι → ℝ) {c : ℝ} (hc : 0 ≤ c) :
    l1norm (fun i => c * d i) = c * l1norm d := by
  simp only [l1norm, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by rw [abs_mul, abs_of_nonneg hc]

omit [Fintype ι] in
lemma smul_mem_RepairSet {x y d : ι → ℝ} (hd : d ∈ RepairSet x y) {c : ℝ} (hc : 0 ≤ c) :
    (fun i => c * d i) ∈ RepairSet x (fun i => c * y i) := by
  intro i j
  have hcom := hd i j
  have h : (x i - x j) * ((c * y i + c * d i) - (c * y j + c * d j))
      = c * ((x i - x j) * ((y i + d i) - (y j + d j))) := by ring
  rw [h]
  exact mul_nonneg hc hcom

/-- **The repair distance is positively homogeneous of degree one in the rates.** -/
theorem repairDist_smul (x y : ι → ℝ) {c : ℝ} (hc : 0 ≤ c) :
    repairDist x (fun i => c * y i) = c * repairDist x y := by
  rcases eq_or_lt_of_le hc with hzero | hpos
  · -- `c = 0`: the rates are constant, hence already comonotone
    have hcom : Comonotone x (fun i => c * y i) := by
      intro i j
      simp [← hzero]
    have := (repairDist_eq_zero_iff_comonotone x (fun i => c * y i)).mpr hcom
    rw [this, ← hzero, zero_mul]
  · refine le_antisymm ?_ ?_
    · -- scale any repair of `(x, y)`
      have hub : ∀ d ∈ RepairSet x y,
          repairDist x (fun i => c * y i) ≤ c * l1norm d := by
        intro d hd
        have := repairDist_le_of_mem (smul_mem_RepairSet hd hc)
        rwa [l1norm_smul d hc] at this
      have : repairDist x (fun i => c * y i) / c ≤ repairDist x y := by
        refine le_repairDist ?_
        intro d hd
        rw [div_le_iff₀ hpos]
        have := hub d hd
        linarith
      rw [div_le_iff₀ hpos] at this
      linarith
    · -- scale back by `c⁻¹`
      have hub : ∀ d ∈ RepairSet x (fun i => c * y i),
          c * repairDist x y ≤ l1norm d := by
        intro d hd
        have hmem : (fun i => c⁻¹ * d i) ∈ RepairSet x y := by
          have hy : (fun i => c⁻¹ * (c * y i)) = y := by
            funext i
            field_simp
          have := smul_mem_RepairSet hd (le_of_lt (inv_pos.mpr hpos))
          rwa [hy] at this
        have hle := repairDist_le_of_mem hmem
        rw [l1norm_smul d (le_of_lt (inv_pos.mpr hpos))] at hle
        have hc' : c ≠ 0 := ne_of_gt hpos
        calc c * repairDist x y ≤ c * (c⁻¹ * l1norm d) :=
              mul_le_mul_of_nonneg_left hle hc
          _ = l1norm d := by field_simp
      exact le_repairDist hub

/-! ### The degree obstruction: no superlinear comparison -/

/-- **No superlinear comparison.**  For every constant `C` there is a population with
`C · Δ < δ²`.  The witnesses are the rescalings `y = (t, 0)` of a fixed two-key
population: homogeneity forces the left side to grow linearly in `t` and the right side
quadratically, so the conjectured `δ² ≤ Δ` fails by an unbounded margin. -/
theorem no_superlinear_comparison (C : ℝ) :
    ∃ t : ℝ, 0 < t ∧
      C * discordanceMass vx (fun i => t * vy i) < (repairDist vx (fun i => t * vy i)) ^ 2 := by
  obtain ⟨k, hk⟩ := exists_nat_gt (max (2 * C) 1)
  refine ⟨(k : ℝ), ?_, ?_⟩
  · have : (1 : ℝ) ≤ max (2 * C) 1 := le_max_right _ _
    linarith
  · have ht0 : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg _
    rw [discordanceMass_smul vx vy ht0, repairDist_smul vx vy ht0,
      discordanceMass_vx_vy, repairDist_vx_vy]
    have hC : 2 * C < (k : ℝ) := lt_of_le_of_lt (le_max_left _ _) hk
    have h1 : (1 : ℝ) < (k : ℝ) := lt_of_le_of_lt (le_max_right _ _) hk
    nlinarith

/-! ### An infinite family forcing the population-size factor -/

/-- Equally spaced footprints `0, 1, …, n-1` on `n = m+2` keys. -/
def famX (m : ℕ) : Fin (m + 2) → ℝ := fun i => (i : ℝ)

/-- Rates with a single high outlier sitting at the smallest footprint. -/
def famY (m : ℕ) : Fin (m + 2) → ℝ := fun i => if i = 0 then 1 else 0

private lemma sum_range_cast (k : ℕ) :
    ∑ i ∈ Finset.range k, (i : ℝ) = (k : ℝ) * ((k : ℝ) - 1) / 2 := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

private lemma sum_index_cast (m : ℕ) :
    ∑ i : Fin (m + 2), (i : ℝ) = ((m : ℝ) + 2) * ((m : ℝ) + 1) / 2 := by
  have h : ∑ i : Fin (m + 2), ((i : ℕ) : ℝ) = ∑ i ∈ Finset.range (m + 2), (i : ℝ) :=
    Fin.sum_univ_eq_sum_range (fun i => (i : ℝ)) (m + 2)
  rw [h, sum_range_cast]
  push_cast
  ring

lemma famX_range (m : ℕ) (i j : Fin (m + 2)) : |famX m i - famX m j| ≤ (m : ℝ) + 1 := by
  have hi : ((i : ℕ) : ℝ) ≤ (m : ℝ) + 1 := by
    have := i.isLt
    have : ((i : ℕ) : ℝ) ≤ ((m + 1 : ℕ) : ℝ) := by
      exact_mod_cast Nat.lt_succ_iff.mp i.isLt
    push_cast at this
    linarith
  have hj : ((j : ℕ) : ℝ) ≤ (m : ℝ) + 1 := by
    have : ((j : ℕ) : ℝ) ≤ ((m + 1 : ℕ) : ℝ) := by
      exact_mod_cast Nat.lt_succ_iff.mp j.isLt
    push_cast at this
    linarith
  have hi0 : (0 : ℝ) ≤ ((i : ℕ) : ℝ) := Nat.cast_nonneg _
  have hj0 : (0 : ℝ) ≤ ((j : ℕ) : ℝ) := Nat.cast_nonneg _
  simp only [famX]
  rw [abs_le]
  constructor <;> linarith

/-- **Discordance mass of the outlier family**: `Δ = n (n-1)` on `n = m+2` keys. -/
theorem famDiscordanceMass (m : ℕ) :
    discordanceMass (famX m) (famY m) = ((m : ℝ) + 2) * ((m : ℝ) + 1) := by
  classical
  set S : ℝ := ∑ i : Fin (m + 2), (i : ℝ) with hS
  have hterm : ∀ i j : Fin (m + 2),
      max (-((famX m i - famX m j) * (famY m i - famY m j))) 0
        = if i = 0 then (if j = 0 then (0 : ℝ) else (j : ℝ))
          else (if j = 0 then (i : ℝ) else 0) := by
    intro i j
    have hjn : (0 : ℝ) ≤ ((j : ℕ) : ℝ) := Nat.cast_nonneg _
    have hin : (0 : ℝ) ≤ ((i : ℕ) : ℝ) := Nat.cast_nonneg _
    by_cases hi : i = 0
    · subst hi
      by_cases hj : j = 0
      · subst hj; simp [famX, famY]
      · simp only [famX, famY, if_neg hj, if_true, Fin.val_zero, Nat.cast_zero]
        rw [show -((0 - ((j : ℕ) : ℝ)) * (1 - 0)) = ((j : ℕ) : ℝ) by ring, max_eq_left hjn]
    · by_cases hj : j = 0
      · subst hj
        simp only [famX, famY, if_neg hi, if_true, Fin.val_zero, Nat.cast_zero]
        rw [show -((((i : ℕ) : ℝ) - 0) * (0 - 1)) = ((i : ℕ) : ℝ) by ring, max_eq_left hin]
      · simp [famX, famY, hi, hj]
  have hrow0 : ∑ j : Fin (m + 2), (if j = 0 then (0 : ℝ) else (j : ℝ)) = S := by
    rw [hS]
    refine Finset.sum_congr rfl fun j _ => ?_
    by_cases hj : j = 0
    · simp [hj]
    · simp [hj]
  have hrowi : ∀ i : Fin (m + 2),
      ∑ j : Fin (m + 2), (if j = 0 then (i : ℝ) else 0) = (i : ℝ) := by
    intro i
    rw [Finset.sum_ite_eq' univ (0 : Fin (m + 2)) (fun _ => (i : ℝ))]
    simp
  have hmass : discordanceMass (famX m) (famY m)
      = ∑ i : Fin (m + 2), (if i = 0 then S else (i : ℝ)) := by
    rw [discordanceMass]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_congr rfl fun j _ => hterm i j]
    by_cases hi : i = 0
    · simp only [hi, if_true]
      exact hrow0
    · simp only [hi, if_false]
      exact hrowi i
  have hsplit : ∑ i : Fin (m + 2), (if i = 0 then S else (i : ℝ))
      = ∑ i : Fin (m + 2), ((if i = 0 then S else 0) + (if i = 0 then (0 : ℝ) else (i : ℝ))) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases hi : i = 0 <;> simp [hi]
  rw [hmass, hsplit, Finset.sum_add_distrib,
    Finset.sum_ite_eq' univ (0 : Fin (m + 2)) (fun _ => S), hrow0]
  simp only [mem_univ, if_true]
  rw [hS, sum_index_cast]
  ring

/-- **Repair distance of the outlier family**: a single coordinate move of size `1`
suffices, and one discordant pair certifies that nothing cheaper works. -/
theorem famRepairDist (m : ℕ) : repairDist (famX m) (famY m) = 1 := by
  classical
  refine le_antisymm ?_ ?_
  · have hmem : (fun i : Fin (m + 2) => if i = 0 then (-1 : ℝ) else 0)
        ∈ RepairSet (famX m) (famY m) := by
      intro i j
      have hzi : famY m i + (if i = 0 then (-1 : ℝ) else 0) = 0 := by
        by_cases hi : i = 0 <;> simp [famY, hi]
      have hzj : famY m j + (if j = 0 then (-1 : ℝ) else 0) = 0 := by
        by_cases hj : j = 0 <;> simp [famY, hj]
      show (0 : ℝ) ≤ (famX m i - famX m j) *
        ((famY m i + (if i = 0 then (-1 : ℝ) else 0))
          - (famY m j + (if j = 0 then (-1 : ℝ) else 0)))
      rw [hzi, hzj]
      simp
    have hnorm : l1norm (fun i : Fin (m + 2) => if i = 0 then (-1 : ℝ) else 0) = 1 := by
      have : ∀ i : Fin (m + 2), |if i = 0 then (-1 : ℝ) else 0| = if i = 0 then (1 : ℝ) else 0 := by
        intro i
        by_cases hi : i = 0 <;> simp [hi]
      rw [l1norm, Finset.sum_congr rfl fun i _ => this i,
        Finset.sum_ite_eq' univ (0 : Fin (m + 2)) (fun _ => (1 : ℝ))]
      simp
    have := repairDist_le_of_mem hmem
    rwa [hnorm] at this
  · have hne : (1 : Fin (m + 2)) ≠ 0 := by
      intro h
      have := congrArg Fin.val h
      simp at this
    have hx : famX m 0 < famX m 1 := by
      simp only [famX]
      rw [show ((0 : Fin (m + 2)) : ℝ) = 0 by norm_num,
        show ((1 : Fin (m + 2)) : ℝ) = 1 by norm_num]
      norm_num
    have h := violation_le_repairDist (x := famX m) (y := famY m) hx
    have hy : famY m 0 - famY m 1 = 1 := by
      simp [famY, hne]
    rwa [hy] at h

/-- **The upper bound is attained up to a factor two.**  For the outlier family the general
bound `Δ ≤ 2 |ι| R δ` (with `|ι| = m+2`, `R = m+1`, `δ = 1`) reads `Δ ≤ 2(m+2)(m+1)`, and
the true value is exactly half of it. -/
theorem upper_bound_sharp_up_to_two (m : ℕ) :
    discordanceMass (famX m) (famY m)
      = (1 / 2) * (2 * (Fintype.card (Fin (m + 2)) : ℝ) * ((m : ℝ) + 1)
          * repairDist (famX m) (famY m)) := by
  rw [famDiscordanceMass, famRepairDist, Fintype.card_fin]
  push_cast
  ring

/-- **The population-size factor cannot be removed.**  For every constant `C` there is a
population whose discordance mass exceeds `C · range(x) · δ`.  Hence no bound of the form
`Δ ≤ C · R · δ` holds, and the `|ι|` in `discordanceMass_le_repairDist` is necessary. -/
theorem no_bound_linear_in_range (C : ℝ) :
    ∃ m : ℕ, C * (((m : ℝ) + 1) * repairDist (famX m) (famY m))
      < discordanceMass (famX m) (famY m) := by
  obtain ⟨k, hk⟩ := exists_nat_gt C
  refine ⟨k, ?_⟩
  rw [famDiscordanceMass, famRepairDist]
  have hk0 : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg _
  nlinarith

end Catalog.UniformDial