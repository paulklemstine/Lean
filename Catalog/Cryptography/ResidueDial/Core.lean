import Mathlib

/-!
# The residue-dial speedup law and the universal cap `4/3`

A *residue dial* is the simplest conceivable oracle that a factoring scan can be
handed: a modulus `M`, a set `K` of residue classes modulo `M`, and the promise
that the sought factor's class lies in `K` or does not.  Empirically (paper 88)
the best speedup such a filter can buy a scanning algorithm follows a fixed
curve in the *density* `θ = |K| / φ(M)` alone.  This file turns that empirical
curve into a theorem for the whole congruence stratum.

## The model

The scan has `n = φ(M)` admissible residue classes; the target class `t` is
uniform among them.  The dial-aware algorithm scans the `k = |K|` kept classes
first and, if the target is not there, is forced back onto the full scan.  Its
cost on target `t` is therefore

  `cost t = if t ∈ K then k else n`,

whose average over `t` is `expectedScanCost`.  Normalising by the baseline `n`
gives the *exact law*

  `expectedScanCost / n = 1 - θ + θ²`,  `Speedup = 1 / (1 - θ + θ²)`.

## Scope (read this before quoting the constant)

The model is a *single-pass scan*: the dial reorders the candidate classes, but a
class once scheduled is paid for.  If the dial's answer instead lets the
algorithm **skip** the rejected classes outright, the cost is `Σ θᵢ²` and no
universal cap holds — a balanced `r`-symbol full reveal then buys exactly `r`
(`ResidueDial.revealSpeedup_uniform` in `MultiSymbol.lean`).  So `4/3` is a
theorem about scan-order algorithms, not about arbitrary use of congruence
information; `Accounting.lean` and `MultiSymbol.lean` chart the boundary.

## Main results

* `expectedScanCost_eq` — Claim A: the exact law, derived from the finite model
  by summation, for an arbitrary filter `K` in an arbitrary finite class space.
* `dialCost_ge_three_quarters`, `speedup_le_four_thirds` — the **universal cap**
  `Speedup ≤ 4/3`, with equality exactly at `θ = 1/2`
  (`speedup_eq_four_thirds_iff`).
* `speedup_lt_two` — the barrier-4 converse in the asked form: a residue dial
  can never buy a factor-`2` speedup.
* `speedup_of_trivial` — trivial filters (`θ = 0`, `θ = 1`) buy exactly `1`.
* `speedup_strictMonoOn`, `speedup_strictAntiOn`, `isGreatest_speedup` — the
  shape of the curve and that `4/3` really is the maximum over `θ ∈ [0,1]`.
* `dialSpeedup_le_four_thirds` and `exists_dial_speedup_eq_four_thirds` — the
  cap and its attainment for genuine residue dials `K ⊆ (ZMod M)ˣ`; the
  attaining sets are *arbitrary* half-density sets, no character structure is
  required (Lemma B2, see `Converse.lean`).

Everything below depends on `K` only through its cardinality; that is the
content of the structure-blindness corollaries collected in `Converse.lean`.
-/

namespace ResidueDial

open Finset

/-! ## The law -/

/-- Normalised expected cost of a dial-aware scan at filter density `θ`:
`1 - θ + θ²`.  (Cost `1` is the unfiltered baseline scan.) -/
def dialCost (θ : ℝ) : ℝ := 1 - θ + θ ^ 2

/-- The speedup bought by a residue dial of density `θ`. -/
noncomputable def speedup (θ : ℝ) : ℝ := 1 / dialCost θ

@[simp] theorem dialCost_zero : dialCost 0 = 1 := by simp [dialCost]

@[simp] theorem dialCost_one : dialCost 1 = 1 := by norm_num [dialCost]

theorem dialCost_half : dialCost (1 / 2) = 3 / 4 := by norm_num [dialCost]

/-- The cost never drops below `3/4`: completing the square,
`1 - θ + θ² = (θ - 1/2)² + 3/4`. -/
theorem dialCost_ge_three_quarters (θ : ℝ) : 3 / 4 ≤ dialCost θ := by
  have h : (θ - 1 / 2) ^ 2 ≥ 0 := sq_nonneg _
  unfold dialCost
  nlinarith [h]

theorem dialCost_pos (θ : ℝ) : 0 < dialCost θ :=
  lt_of_lt_of_le (by norm_num) (dialCost_ge_three_quarters θ)

theorem dialCost_ne_zero (θ : ℝ) : dialCost θ ≠ 0 := ne_of_gt (dialCost_pos θ)

/-- Equality in the cost bound happens exactly at half density. -/
theorem dialCost_eq_three_quarters_iff {θ : ℝ} : dialCost θ = 3 / 4 ↔ θ = 1 / 2 := by
  constructor
  · intro h
    have h2 : (θ - 1 / 2) ^ 2 = 0 := by unfold dialCost at h; nlinarith [h]
    have h3 := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h2
    linarith
  · rintro rfl; exact dialCost_half

theorem speedup_pos (θ : ℝ) : 0 < speedup θ := by
  unfold speedup
  have := dialCost_pos θ
  positivity

/-- **Universal cap.**  No residue dial, of any density, buys more than `4/3`. -/
theorem speedup_le_four_thirds (θ : ℝ) : speedup θ ≤ 4 / 3 := by
  have h := dialCost_ge_three_quarters θ
  have hp := dialCost_pos θ
  rw [speedup, div_le_div_iff₀ hp (by norm_num)]
  linarith

/-- The cap is attained exactly at half density. -/
theorem speedup_eq_four_thirds_iff {θ : ℝ} : speedup θ = 4 / 3 ↔ θ = 1 / 2 := by
  rw [← dialCost_eq_three_quarters_iff, speedup,
    div_eq_div_iff (dialCost_ne_zero θ) (by norm_num : (3:ℝ) ≠ 0)]
  constructor <;> intro h <;> linarith

@[simp] theorem speedup_half : speedup (1 / 2) = 4 / 3 :=
  speedup_eq_four_thirds_iff.mpr rfl

/-- **Barrier-4 converse.**  A residue dial can never reach a factor-`2` speedup:
`4/3 < 2`. -/
theorem speedup_lt_two (θ : ℝ) : speedup θ < 2 :=
  lt_of_le_of_lt (speedup_le_four_thirds θ) (by norm_num)

/-- Trivial filters (keep nothing, keep everything) buy exactly nothing. -/
theorem speedup_of_trivial {θ : ℝ} (h : θ = 0 ∨ θ = 1) : speedup θ = 1 := by
  rcases h with rfl | rfl <;> simp [speedup]

/-- A dial with a genuine density (strictly between `0` and `1`) does buy
something: the speedup is `> 1`. -/
theorem one_lt_speedup {θ : ℝ} (h0 : 0 < θ) (h1 : θ < 1) : 1 < speedup θ := by
  have hp := dialCost_pos θ
  rw [speedup, lt_div_iff₀ hp]
  have hmul : θ * (1 - θ) > 0 := mul_pos h0 (by linarith)
  unfold dialCost
  nlinarith

/-- The speedup is strictly increasing up to half density. -/
theorem speedup_strictMonoOn : StrictMonoOn speedup (Set.Icc 0 (1 / 2)) := by
  intro a ha b hb hab
  have hpa := dialCost_pos a
  have hpb := dialCost_pos b
  rw [speedup, speedup, div_lt_div_iff₀ hpa hpb]
  have ha2 : a ≤ 1 / 2 := ha.2
  have hb2 : b ≤ 1 / 2 := hb.2
  have ha0 : 0 ≤ a := ha.1
  unfold dialCost
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b - 1)]

/-- The speedup is strictly decreasing beyond half density. -/
theorem speedup_strictAntiOn : StrictAntiOn speedup (Set.Icc (1 / 2) 1) := by
  intro a ha b hb hab
  have hpa := dialCost_pos a
  have hpb := dialCost_pos b
  rw [speedup, speedup, div_lt_div_iff₀ hpb hpa]
  have ha2 : 1 / 2 ≤ a := ha.1
  have hb2 : b ≤ 1 := hb.2
  unfold dialCost
  nlinarith [sq_nonneg (a - b), sq_nonneg (a + b - 1)]

/-- `4/3` is the greatest value of the speedup curve on `[0,1]`, attained at
`θ = 1/2`. -/
theorem isGreatest_speedup : IsGreatest (speedup '' Set.Icc (0:ℝ) 1) (4 / 3) := by
  constructor
  · exact ⟨1 / 2, by norm_num, speedup_half⟩
  · rintro y ⟨θ, -, rfl⟩; exact speedup_le_four_thirds θ

/-! ## Claim A: deriving the law from the finite scan model -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Cost of the dial-aware scan when the target class is `t`: the `|K|` kept
classes if `t` survives the filter, otherwise the whole class space. -/
def scanCost (K : Finset α) (t : α) : ℝ :=
  if t ∈ K then (K.card : ℝ) else (Fintype.card α : ℝ)

/-- Expected cost of the dial-aware scan, the target class being uniform. -/
noncomputable def expectedScanCost (K : Finset α) : ℝ :=
  (∑ t : α, scanCost K t) / (Fintype.card α : ℝ)

theorem sum_scanCost (K : Finset α) :
    ∑ t : α, scanCost K t
      = (K.card : ℝ) * (K.card : ℝ)
        + ((Fintype.card α : ℝ) - (K.card : ℝ)) * (Fintype.card α : ℝ) := by
  classical
  have h1 : ∑ t : α, (if t ∈ K then (1:ℝ) else 0) = (K.card : ℝ) := by simp
  have hswap : ∀ t : α, (if t ∈ K then (0:ℝ) else 1) = 1 - (if t ∈ K then 1 else 0) := by
    intro t; by_cases h : t ∈ K <;> simp [h]
  have h2 : ∑ t : α, (if t ∈ K then (0:ℝ) else 1)
      = (Fintype.card α : ℝ) - (K.card : ℝ) := by
    simp only [hswap, Finset.sum_sub_distrib, h1, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul, mul_one]
  have key : ∀ t : α, scanCost K t
      = (K.card : ℝ) * (if t ∈ K then 1 else 0)
        + (Fintype.card α : ℝ) * (if t ∈ K then 0 else 1) := by
    intro t; by_cases h : t ∈ K <;> simp [scanCost, h]
  rw [Finset.sum_congr rfl (fun t _ => key t), Finset.sum_add_distrib, ← Finset.mul_sum,
    ← Finset.mul_sum, h1, h2]
  ring

/-- **Claim A (exact law).**  For *any* filter `K` in *any* finite class space,
the expected scan cost is the baseline `n` times `1 - θ + θ²`, where
`θ = |K| / n`.  No structure of `K` enters. -/
theorem expectedScanCost_eq (K : Finset α) (hn : 0 < Fintype.card α) :
    expectedScanCost K =
      (Fintype.card α : ℝ) * dialCost ((K.card : ℝ) / (Fintype.card α : ℝ)) := by
  have hn' : (Fintype.card α : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  rw [expectedScanCost, sum_scanCost, dialCost]
  field_simp
  ring

/-- The normalised form: the *ratio* to the unfiltered baseline is exactly
`dialCost θ`. -/
theorem expectedScanCost_ratio (K : Finset α) (hn : 0 < Fintype.card α) :
    expectedScanCost K / (Fintype.card α : ℝ)
      = dialCost ((K.card : ℝ) / (Fintype.card α : ℝ)) := by
  have hn' : (Fintype.card α : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  rw [expectedScanCost_eq K hn, mul_comm, mul_div_assoc, div_self hn', mul_one]

/-- The realised speedup of the model equals the law evaluated at the density. -/
theorem model_speedup (K : Finset α) (hn : 0 < Fintype.card α) :
    (Fintype.card α : ℝ) / expectedScanCost K
      = speedup ((K.card : ℝ) / (Fintype.card α : ℝ)) := by
  have hn' : (Fintype.card α : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  have hc := dialCost_ne_zero ((K.card : ℝ) / (Fintype.card α : ℝ))
  rw [expectedScanCost_eq K hn, speedup]
  field_simp

/-! ## Genuine residue dials -/

/-- The density `θ = |K| / φ(M)` of a residue dial `K ⊆ (ZMod M)ˣ`. -/
noncomputable def density (M : ℕ) [NeZero M] (K : Finset (ZMod M)ˣ) : ℝ :=
  (K.card : ℝ) / (M.totient : ℝ)

theorem totient_pos_of_neZero (M : ℕ) [NeZero M] : 0 < M.totient :=
  Nat.totient_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne M))

theorem density_nonneg (M : ℕ) [NeZero M] (K : Finset (ZMod M)ˣ) : 0 ≤ density M K := by
  unfold density; positivity

theorem density_le_one (M : ℕ) [NeZero M] (K : Finset (ZMod M)ˣ) : density M K ≤ 1 := by
  have hcard : K.card ≤ M.totient := by
    rw [← ZMod.card_units_eq_totient M, ← Finset.card_univ]
    exact Finset.card_le_univ K
  have hpos : (0:ℝ) < (M.totient : ℝ) := by
    exact_mod_cast totient_pos_of_neZero M
  rw [density, div_le_one hpos]
  exact_mod_cast hcard

/-- **The cap for residue dials.**  Whatever the modulus, whatever the filter,
whatever the reading: at most `4/3`. -/
theorem dialSpeedup_le_four_thirds (M : ℕ) [NeZero M] (K : Finset (ZMod M)ˣ) :
    speedup (density M K) ≤ 4 / 3 :=
  speedup_le_four_thirds _

/-- Attainment: whenever `φ(M)` is even, *some* dial — indeed any half-density
one — hits the cap exactly. -/
theorem exists_dial_speedup_eq_four_thirds (M : ℕ) [NeZero M] (h : Even M.totient) :
    ∃ K : Finset (ZMod M)ˣ, speedup (density M K) = 4 / 3 := by
  obtain ⟨m, hm⟩ := h
  have hcard : Fintype.card (ZMod M)ˣ = M.totient := ZMod.card_units_eq_totient M
  have hle : m ≤ (univ : Finset (ZMod M)ˣ).card := by
    rw [Finset.card_univ, hcard, hm]; omega
  obtain ⟨K, -, hK⟩ := Finset.exists_subset_card_eq hle
  refine ⟨K, speedup_eq_four_thirds_iff.mpr ?_⟩
  have hMpos : 0 < M.totient := totient_pos_of_neZero M
  have hne : (M.totient : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hMpos.ne'
  have hm0 : 0 < m := by omega
  have hmpos : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm0
  have hmR : ((m : ℝ) + m) ≠ 0 := ne_of_gt (by linarith)
  rw [density, hK, hm]
  push_cast
  rw [div_eq_div_iff hmR (by norm_num : (2:ℝ) ≠ 0)]
  ring

end ResidueDial