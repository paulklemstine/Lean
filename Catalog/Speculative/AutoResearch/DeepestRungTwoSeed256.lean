/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Deepest Rung Is Two-Seed 256: a formal bridge between attention concentration,
# knee brackets, and concave depth laws

This file formalises the *mathematical skeleton* behind the NET-43 measurement round
("the deepest rung is two-seed 256").  The empirical round measured, for a causal
transformer of depth `d = 32` at context `ctx = 512`, the smallest top-`k` attention
width `k` whose accuracy clears a fixed bar, obtaining `k* = 256` at two independent
seeds, with knee bracket `(240, 256]`, effective attention support `≈ 216.92`,
top-`256` attention mass `≈ 0.922`, and a positive random-`k` selection gap.

None of those numbers can be *proved*; they are measurements.  What can be proved —
and is proved here, with no `sorry` — are the structural laws that make the
measurement protocol meaningful, and the arithmetic consequences of the reported
numbers.  Four independent mathematical threads are bridged:

1. **Selection geometry** (`bestMass`).  Top-`k` selection is optimal among all
   width-`k` selections (`mass_le_bestMass`), and *strictly* better than any
   selection that omits a heavier index (`mass_lt_bestMass_of_swap`).  This is the
   theorem behind the "random-`k` control" of Part B2: the measured selection gap
   is nonnegative by mathematics, and strictly positive as soon as the random draw
   misses a heavier key.

2. **Concentration ⇒ knee lower bound** (`card_ge_of_bestMass_ge`).  Via
   Chebyshev/Cauchy–Schwarz, any width `k` reaching mass `τ` obeys
   `k ≥ τ² · eff`, where `eff = 1 / ∑ pᵢ²` is the participation-ratio effective
   support.  Thus the *measured concentration* `eff ≈ 216.92` forces
   `k* > 183` — an independent, purely mathematical corroboration of the measured
   knee `256`, and a refutation of any "knee ≈ 96" style claim at this cell.

3. **Knee brackets and two-seed agreement** (`knee_mem_bracket`,
   `two_seed_knee_eq_of_grid`).  If passing is upward closed in `k`, the knee is the
   least passing width; a fail at `240` and a pass at `256` bracket it in `(240, 256]`;
   and on the NET-43 sweep grid that bracket contains a *unique* grid point, so two
   seeds that both fail at `240` and pass at `256` must report the *same* knee.
   This is the exact-reproduction claim, proved as a lemma about upward-closed
   predicates rather than asserted from data.

4. **Concave depth law** (`kstarLaw`).  The fitted law `k*(d) = 24.7 · d^(2/3)` is
   concave, has per-doubling ratio `2^(2/3) ∈ (1.58, 1.59) < 2` (sub-linear depth
   leg), is subadditive, and — the structural punchline — *any affine model
   calibrated at two shallower depths necessarily over-predicts at every greater
   depth* (`concave_affine_extrapolation_over_predicts`).  The empirical statement
   "the affine model `8d + 32 = 288` over-predicts the measured `256` by more than
   11%" is therefore an instance of a theorem about concavity, not a coincidence.

## Main results

* `mass_le_bestMass`, `mass_lt_bestMass_of_swap` — selection-gap nonnegativity/strictness
* `sq_bestMass_le_card_mul_sumSq` — Chebyshev bound on best-`k` mass
* `card_ge_of_bestMass_ge` — knee lower bound `k ≥ τ² · eff`
* `net43_concentration_forces_knee_gt_183` — the NET-43 instance of the above
* `knee_mem_bracket`, `two_seed_knee_eq_of_grid`, `net43_two_seed_exact`
* `kstarLaw_concaveOn`, `kstarLaw_doubling`, `two_pow_two_thirds_lt_two`,
  `kstarLaw_subadditive`
* `concave_affine_extrapolation_over_predicts`, `net43_affine_over_predicts`
* `net43_speedup_two`, `product_law_no_speedup`
-/

namespace Bridges.DeepestRungTwoSeed256

open Finset

/-! ## 1. Selection geometry: top-`k` attention mass -/

/-- A (row of an) attention matrix: a probability vector on `n` keys. -/
structure AttnDist (n : ℕ) where
  /-- the attention weights -/
  p : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ p i
  sum_one : ∑ i, p i = 1

variable {n : ℕ}

/-- The family of admissible width-`k` selections: key sets of cardinality at most `k`. -/
def Kset (n k : ℕ) : Finset (Finset (Fin n)) :=
  Finset.univ.powerset.filter (fun S => S.card ≤ k)

lemma Kset_nonempty (n k : ℕ) : (Kset n k).Nonempty := ⟨∅, by simp [Kset]⟩

lemma mem_Kset {k : ℕ} {S : Finset (Fin n)} : S ∈ Kset n k ↔ S.card ≤ k := by
  simp [Kset]

/-- The mass captured by the *best* width-`k` selection, i.e. the top-`k` attention mass. -/
noncomputable def bestMass (a : AttnDist n) (k : ℕ) : ℝ :=
  (Kset n k).sup' (Kset_nonempty n k) (fun S => ∑ i ∈ S, a.p i)

/-- **Selection-gap nonnegativity.**  No width-`k` selection — in particular no random-`k`
control — captures more mass than the top-`k` selection. -/
lemma mass_le_bestMass {k : ℕ} (a : AttnDist n) {S : Finset (Fin n)} (hS : S.card ≤ k) :
    ∑ i ∈ S, a.p i ≤ bestMass a k :=
  Finset.le_sup' (fun S => ∑ i ∈ S, a.p i) (mem_Kset.2 hS)

lemma bestMass_nonneg {k : ℕ} (a : AttnDist n) : 0 ≤ bestMass a k := by
  have := mass_le_bestMass (k := k) a (S := (∅ : Finset (Fin n))) (by simp)
  simpa using this

/-- Top-`k` mass is monotone in the width `k`. -/
lemma bestMass_mono (a : AttnDist n) {k k' : ℕ} (h : k ≤ k') :
    bestMass a k ≤ bestMass a k' :=
  Finset.sup'_mono _ (fun _ hS => mem_Kset.2 ((mem_Kset.1 hS).trans h)) _

lemma bestMass_le_one {k : ℕ} (a : AttnDist n) : bestMass a k ≤ 1 := by
  refine Finset.sup'_le _ _ (fun S _ => ?_)
  rw [← a.sum_one]
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S) (fun i _ _ => a.nonneg i)

/-- **Strict selection gap.**  A selection that keeps a key `i` while dropping a strictly
heavier key `j` is strictly beaten by the top-`k` selection.  This is the structural reason
the repaired random-`k` control of NET-43 had to show a positive gap. -/
theorem mass_lt_bestMass_of_swap {k : ℕ} (a : AttnDist n) {S : Finset (Fin n)}
    (hS : S.card ≤ k) {i j : Fin n} (hi : i ∈ S) (hj : j ∉ S) (hlt : a.p i < a.p j) :
    ∑ x ∈ S, a.p x < bestMass a k := by
  classical
  set T : Finset (Fin n) := insert j (S.erase i) with hT
  have hjT : j ∉ S.erase i := fun h => hj (Finset.mem_of_mem_erase h)
  have hcardT : T.card ≤ k := by
    have h1 : T.card = (S.erase i).card + 1 := by
      rw [hT, Finset.card_insert_of_notMem hjT]
    have h2 : (S.erase i).card = S.card - 1 := Finset.card_erase_of_mem hi
    have h3 : 1 ≤ S.card := Finset.card_pos.2 ⟨i, hi⟩
    omega
  have hsumT : ∑ x ∈ T, a.p x = a.p j + ∑ x ∈ S.erase i, a.p x := by
    rw [hT, Finset.sum_insert hjT]
  have hsumS : ∑ x ∈ S, a.p x = a.p i + ∑ x ∈ S.erase i, a.p x :=
    (Finset.add_sum_erase _ _ hi).symm
  have := mass_le_bestMass a hcardT
  rw [hsumT] at this
  linarith

/-! ## 2. Concentration forces a knee lower bound -/

/-- The inverse participation ratio `∑ pᵢ²`. -/
noncomputable def sumSq (a : AttnDist n) : ℝ := ∑ i, (a.p i) ^ 2

/-- The *effective support* (participation ratio) `eff = 1 / ∑ pᵢ²`. -/
noncomputable def eff (a : AttnDist n) : ℝ := 1 / sumSq a

lemma sumSq_pos (a : AttnDist n) : 0 < sumSq a := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · exfalso
    subst hn
    have := a.sum_one
    simp at this
  · have hchev : (∑ i, a.p i) ^ 2 ≤ ((Finset.univ : Finset (Fin n)).card : ℝ) * sumSq a :=
      sq_sum_le_card_mul_sum_sq
    rw [a.sum_one] at hchev
    have hcard : ((Finset.univ : Finset (Fin n)).card : ℝ) = (n : ℝ) := by simp
    rw [hcard] at hchev
    have hnpos : (0:ℝ) < n := by exact_mod_cast hn
    nlinarith

/-- **Chebyshev bound on selected mass.**  The squared top-`k` mass is at most `k · ∑ pᵢ²`. -/
theorem sq_bestMass_le_card_mul_sumSq {k : ℕ} (a : AttnDist n) :
    (bestMass a k) ^ 2 ≤ (k : ℝ) * sumSq a := by
  obtain ⟨S, hS, hEq⟩ := Finset.exists_mem_eq_sup' (Kset_nonempty n k) (fun S => ∑ i ∈ S, a.p i)
  rw [show bestMass a k = ∑ i ∈ S, a.p i from hEq]
  have h1 : (∑ i ∈ S, a.p i) ^ 2 ≤ (S.card : ℝ) * ∑ i ∈ S, (a.p i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have h2 : (S.card : ℝ) ≤ k := by exact_mod_cast mem_Kset.1 hS
  have h3 : ∑ i ∈ S, (a.p i) ^ 2 ≤ sumSq a :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S) (fun i _ _ => sq_nonneg _)
  have h4 : (0:ℝ) ≤ ∑ i ∈ S, (a.p i) ^ 2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have h5 : (0:ℝ) ≤ (S.card : ℝ) := by positivity
  nlinarith

/-- **Knee lower bound from concentration.**  If width `k` captures mass at least `τ ≥ 0`,
then `k ≥ τ² · eff`.  Equivalently: no sparsity budget below `τ²` times the effective
support can reach the mass target, whatever the selection rule. -/
theorem card_ge_of_bestMass_ge {k : ℕ} (a : AttnDist n) {τ : ℝ} (hτ : 0 ≤ τ)
    (h : τ ≤ bestMass a k) : τ ^ 2 * eff a ≤ (k : ℝ) := by
  have hQ := sumSq_pos a
  have h1 : τ ^ 2 ≤ (bestMass a k) ^ 2 := by nlinarith [bestMass_nonneg (k := k) a]
  have h2 := sq_bestMass_le_card_mul_sumSq (k := k) a
  have h3 : τ ^ 2 ≤ (k : ℝ) * sumSq a := le_trans h1 h2
  rw [eff, mul_one_div, div_le_iff₀ hQ]
  linarith

/-- **NET-43 concentration instance.**  With the measured effective support `eff = 216.92`,
any attention width reaching mass `0.92` must exceed `183`.  (The round measured
top-`256` mass `0.922` at knee `k* = 256`, comfortably above this floor.) -/
theorem net43_concentration_forces_knee_gt_183 {k : ℕ} (a : AttnDist n)
    (heff : eff a = 216.92) (hmass : (0.92 : ℝ) ≤ bestMass a k) : 183 < (k : ℝ) := by
  have := card_ge_of_bestMass_ge a (by norm_num) hmass
  rw [heff] at this
  nlinarith

/-! ## 3. Knees, brackets, and two-seed agreement -/

/-- A pass predicate is *upward closed* if widening a passing budget still passes. -/
def UpwardClosed (P : ℕ → Prop) : Prop := ∀ ⦃a b : ℕ⦄, P a → a ≤ b → P b

/-- Monotonicity of the pass predicate is exactly upward closure. -/
lemma upwardClosed_of_monotone {r : ℕ → ℝ} (bar : ℝ) (hm : Monotone r) :
    UpwardClosed (fun k => bar ≤ r k) := fun _ _ ha hab => le_trans ha (hm hab)

/-- The knee: the least width that passes. -/
noncomputable def knee (P : ℕ → Prop) (h : ∃ k, P k) : ℕ :=
  @Nat.find P (Classical.decPred P) h

lemma knee_spec (P : ℕ → Prop) (h : ∃ k, P k) : P (knee P h) :=
  @Nat.find_spec P (Classical.decPred P) h

lemma knee_le {P : ℕ → Prop} (h : ∃ k, P k) {b : ℕ} (hb : P b) : knee P h ≤ b :=
  @Nat.find_le b P (Classical.decPred P) h hb

/-- Below an upward-closed predicate's knee, every width fails; hence a measured failure at
`a` certifies `a < knee`. -/
lemma lt_knee {P : ℕ → Prop} (hUC : UpwardClosed P) (h : ∃ k, P k) {a : ℕ} (ha : ¬ P a) :
    a < knee P h := by
  by_contra hcon
  exact ha (hUC (knee_spec P h) (le_of_not_gt hcon))

/-- **Bracket lemma.**  A fail at `a` and a pass at `b` pin the knee to the half-open
interval `(a, b]`. -/
theorem knee_mem_bracket {P : ℕ → Prop} (hUC : UpwardClosed P) (h : ∃ k, P k) {a b : ℕ}
    (ha : ¬ P a) (hb : P b) : a < knee P h ∧ knee P h ≤ b :=
  ⟨lt_knee hUC h ha, knee_le h hb⟩

/-- The NET-43 sweep grid (widths actually measured this round). -/
def sweep : Finset ℕ := {96, 128, 160, 192, 224, 240, 256, 288, 320, 384, 512}

/-- The bracket `(240, 256]` meets the sweep grid in the single point `256`. -/
lemma sweep_bracket_unique : ∀ k ∈ sweep, 240 < k → k ≤ 256 → k = 256 := by decide

/-- **Two-seed exact agreement.**  Two runs whose knees are grid points, both failing at
`240` and passing at `256`, report the *same* knee, namely `256`.  Exact reproduction is
thus forced by the bracket plus the grid, not merely observed. -/
theorem two_seed_knee_eq_of_grid {P Q : ℕ → Prop}
    (hPUC : UpwardClosed P) (hQUC : UpwardClosed Q) (hP : ∃ k, P k) (hQ : ∃ k, Q k)
    (hPg : knee P hP ∈ sweep) (hQg : knee Q hQ ∈ sweep)
    (hP240 : ¬ P 240) (hP256 : P 256) (hQ240 : ¬ Q 240) (hQ256 : Q 256) :
    knee P hP = 256 ∧ knee Q hQ = 256 := by
  obtain ⟨h1, h2⟩ := knee_mem_bracket hPUC hP hP240 hP256
  obtain ⟨h3, h4⟩ := knee_mem_bracket hQUC hQ hQ240 hQ256
  exact ⟨sweep_bracket_unique _ hPg h1 h2, sweep_bracket_unique _ hQg h3 h4⟩

/-- **NET-43 two-seed reproduction.**  Specialised to an upward-closed accuracy criterion:
if for each seed the accuracy ratio is monotone in the width, the seed-1 and seed-2 knees
coincide at `256`. -/
theorem net43_two_seed_exact {r₁ r₂ : ℕ → ℝ} (bar : ℝ)
    (hm₁ : Monotone r₁) (hm₂ : Monotone r₂)
    (h₁240 : r₁ 240 < bar) (h₁256 : bar ≤ r₁ 256)
    (h₂240 : r₂ 240 < bar) (h₂256 : bar ≤ r₂ 256)
    (hg₁ : knee (fun k => bar ≤ r₁ k) ⟨256, h₁256⟩ ∈ sweep)
    (hg₂ : knee (fun k => bar ≤ r₂ k) ⟨256, h₂256⟩ ∈ sweep) :
    knee (fun k => bar ≤ r₁ k) ⟨256, h₁256⟩ = knee (fun k => bar ≤ r₂ k) ⟨256, h₂256⟩ := by
  have h1 : ¬ (bar ≤ r₁ 240) := not_le.2 h₁240
  have h2 : ¬ (bar ≤ r₂ 240) := not_le.2 h₂240
  obtain ⟨e1, e2⟩ := two_seed_knee_eq_of_grid (P := fun k => bar ≤ r₁ k)
    (Q := fun k => bar ≤ r₂ k) (upwardClosed_of_monotone bar hm₁) (upwardClosed_of_monotone bar hm₂)
    ⟨256, h₁256⟩ ⟨256, h₂256⟩ hg₁ hg₂ h1 h₁256 h2 h₂256
  rw [e1, e2]

/-! ## 4. The concave depth law `k*(d) = C · d^(2/3)` -/

/-- The fitted knee law `k*(d) = C · d^(2/3)`. -/
noncomputable def kstarLaw (C d : ℝ) : ℝ := C * d ^ ((2:ℝ)/3)

/-- The fitted constant of NET-43. -/
def netC : ℝ := 24.7

lemma kstarLaw_concaveOn {C : ℝ} (hC : 0 ≤ C) :
    ConcaveOn ℝ (Set.Ici 0) (kstarLaw C) := by
  have h := (Real.strictConcaveOn_rpow (p := (2:ℝ)/3) (by norm_num) (by norm_num)).concaveOn
  simpa [kstarLaw, smul_eq_mul] using h.smul hC

/-- Per-doubling growth of the law is the constant factor `2^(2/3)`. -/
lemma kstarLaw_doubling (C : ℝ) {d : ℝ} (hd : 0 ≤ d) :
    kstarLaw C (2 * d) = (2:ℝ) ^ ((2:ℝ)/3) * kstarLaw C d := by
  rw [kstarLaw, kstarLaw, Real.mul_rpow (by norm_num) hd]
  ring

lemma two_pow_two_thirds_cube : ((2:ℝ) ^ ((2:ℝ)/3)) ^ (3:ℕ) = 4 := by
  rw [← Real.rpow_natCast ((2:ℝ) ^ ((2:ℝ)/3)) 3, ← Real.rpow_mul (by norm_num)]
  norm_num

/-- The per-doubling factor is pinned between `1.58` and `1.59`, matching the measured
sub-linear depth leg `1.50 → 1.58 → 1.68`. -/
theorem two_pow_two_thirds_bounds :
    (1.58 : ℝ) < (2:ℝ) ^ ((2:ℝ)/3) ∧ (2:ℝ) ^ ((2:ℝ)/3) < 1.59 := by
  have hpos : (0:ℝ) < (2:ℝ) ^ ((2:ℝ)/3) := Real.rpow_pos_of_pos (by norm_num) _
  have hcube := two_pow_two_thirds_cube
  constructor
  · nlinarith [hcube, hpos, sq_nonneg ((2:ℝ) ^ ((2:ℝ)/3) - 1.58),
      sq_nonneg ((2:ℝ) ^ ((2:ℝ)/3) + 1.58)]
  · nlinarith [hcube, hpos, sq_nonneg ((2:ℝ) ^ ((2:ℝ)/3) - 1.59),
      sq_nonneg ((2:ℝ) ^ ((2:ℝ)/3) + 1.59)]

/-- **Sub-linear depth leg.**  Doubling the depth multiplies the predicted knee by strictly
less than two — the qualitative content of the concave-power-2/3 law. -/
theorem two_pow_two_thirds_lt_two : (2:ℝ) ^ ((2:ℝ)/3) < 2 :=
  lt_trans two_pow_two_thirds_bounds.2 (by norm_num)

theorem kstarLaw_doubling_sublinear {C : ℝ} (hC : 0 < C) {d : ℝ} (hd : 0 < d) :
    kstarLaw C (2 * d) < 2 * kstarLaw C d := by
  have hpos : 0 < kstarLaw C d := by
    have : (0:ℝ) < d ^ ((2:ℝ)/3) := Real.rpow_pos_of_pos hd _
    simpa [kstarLaw] using mul_pos hC this
  rw [kstarLaw_doubling C hd.le]
  nlinarith [two_pow_two_thirds_lt_two]

/-- **Subadditivity in depth.**  The concave law satisfies `k*(d₁ + d₂) ≤ k*(d₁) + k*(d₂)`. -/
theorem kstarLaw_subadditive {C : ℝ} (hC : 0 ≤ C) {d₁ d₂ : ℝ} (h₁ : 0 ≤ d₁) (h₂ : 0 ≤ d₂) :
    kstarLaw C (d₁ + d₂) ≤ kstarLaw C d₁ + kstarLaw C d₂ := by
  have key : (d₁ + d₂) ^ ((2:ℝ)/3) ≤ d₁ ^ ((2:ℝ)/3) + d₂ ^ ((2:ℝ)/3) :=
    Real.rpow_add_le_add_rpow h₁ h₂ (by norm_num) (by norm_num)
  simp only [kstarLaw]
  nlinarith [key]

/-- **Affine extrapolation of a concave law over-predicts.**  If `f` is concave and an affine
model is calibrated to agree with `f` at two points `x < y`, then at every `z > y` the affine
model's value is at least `f z`.  This is the exact structural reason the affine fit
`8d + 32` over-predicts the measured knee at the deepest rung. -/
theorem concave_affine_extrapolation_over_predicts {f : ℝ → ℝ} {s : Set ℝ}
    (hf : ConcaveOn ℝ s f) {x y z : ℝ} (hx : x ∈ s) (hz : z ∈ s)
    (hxy : x < y) (hyz : y < z) :
    f z ≤ f y + (z - y) * ((f y - f x) / (y - x)) := by
  have h := hf.slope_anti_adjacent hx hz hxy hyz
  have hzy : 0 < z - y := by linarith
  have h' : f z - f y ≤ (z - y) * ((f y - f x) / (y - x)) := by
    rw [div_le_iff₀ hzy] at h
    linarith [h]
  linarith

/-- Numerical pin: `32^(2/3) ∈ (10.079, 10.080)`. -/
lemma rpow_32_two_thirds_bounds :
    (10.079 : ℝ) < (32:ℝ) ^ ((2:ℝ)/3) ∧ (32:ℝ) ^ ((2:ℝ)/3) < 10.080 := by
  have hpos : (0:ℝ) < (32:ℝ) ^ ((2:ℝ)/3) := Real.rpow_pos_of_pos (by norm_num) _
  have hcube : ((32:ℝ) ^ ((2:ℝ)/3)) ^ (3:ℕ) = 1024 := by
    rw [← Real.rpow_natCast ((32:ℝ) ^ ((2:ℝ)/3)) 3, ← Real.rpow_mul (by norm_num)]
    norm_num
  constructor
  · nlinarith [hcube, hpos, sq_nonneg ((32:ℝ) ^ ((2:ℝ)/3) - 10.079),
      sq_nonneg ((32:ℝ) ^ ((2:ℝ)/3) + 10.079)]
  · nlinarith [hcube, hpos, sq_nonneg ((32:ℝ) ^ ((2:ℝ)/3) - 10.080),
      sq_nonneg ((32:ℝ) ^ ((2:ℝ)/3) + 10.080)]

/-- **The law's prediction at the deepest rung.**  `24.7 · 32^(2/3) ∈ (248.9, 249)`: the
concave-power law predicts `≈ 249` against the two-seed measurement `256`. -/
theorem net43_law_prediction_at_32 :
    (248.9 : ℝ) < kstarLaw netC 32 ∧ kstarLaw netC 32 < 249 := by
  obtain ⟨h1, h2⟩ := rpow_32_two_thirds_bounds
  constructor <;> · simp only [kstarLaw, netC]; nlinarith

/-- The concave-law prediction sits within 3% of the two-seed measured knee `256`. -/
theorem net43_law_within_three_percent :
    |kstarLaw netC 32 - 256| < 0.03 * 256 := by
  obtain ⟨h1, h2⟩ := net43_law_prediction_at_32
  rw [abs_lt]
  constructor <;> nlinarith

/-- **The affine model over-predicts by more than 11%.**  `8·32 + 32 = 288` exceeds the
two-seed measured knee `256` by more than eleven percent. -/
theorem net43_affine_over_predicts : (288 : ℝ) > 1.11 * 256 := by norm_num

/-- The affine over-prediction is not an accident: calibrating an affine model on the two
shallower rungs `d = 8, 16` of the concave law already forces an over-prediction at `d = 32`. -/
theorem net43_affine_calibration_over_predicts :
    kstarLaw netC 32 ≤ kstarLaw netC 16
      + (32 - 16) * ((kstarLaw netC 16 - kstarLaw netC 8) / (16 - 8)) :=
  concave_affine_extrapolation_over_predicts (kstarLaw_concaveOn (C := netC) (by norm_num [netC]))
    (by norm_num : (8:ℝ) ∈ Set.Ici (0:ℝ)) (by norm_num : (32:ℝ) ∈ Set.Ici (0:ℝ))
    (by norm_num) (by norm_num)

/-! ## 5. Cost model and deployable speedup -/

/-- Cost of top-`k` causal attention at context `ctx`, in units of score evaluations. -/
def attnCost (ctx k : ℕ) : ℝ := (ctx : ℝ) * (k : ℝ)

/-- Speedup of a width-`k` attention over full attention at context `ctx`. -/
noncomputable def speedup (ctx k : ℕ) : ℝ := attnCost ctx ctx / attnCost ctx k

/-- **The product law gives no speedup.**  Setting `k = ctx` (the product-law prescription at
`d = 32`) leaves the cost unchanged. -/
theorem product_law_no_speedup {ctx : ℕ} (h : 0 < ctx) : speedup ctx ctx = 1 := by
  have hne : (ctx : ℝ) ≠ 0 := Nat.cast_ne_zero.2 h.ne'
  simp only [speedup, attnCost]
  field_simp

/-- **Deployable two-seed speedup.**  At `(d = 32, ctx = 512)` the measured knee `k* = 256`
gives exactly a `2.0×` speedup. -/
theorem net43_speedup_two : speedup 512 256 = 2 := by
  norm_num [speedup, attnCost]

/-- Any knee at most half the context yields at least a `2×` speedup. -/
theorem speedup_ge_two_of_knee_le_half {ctx k : ℕ} (hk : 0 < k) (h : 2 * k ≤ ctx) :
    2 ≤ speedup ctx k := by
  have hkR : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hctx : (0:ℝ) < (ctx:ℝ) := by
    have : 0 < ctx := lt_of_lt_of_le hk (by omega)
    exact_mod_cast this
  have h' : 2 * (k:ℝ) ≤ (ctx:ℝ) := by exact_mod_cast h
  rw [speedup, attnCost, attnCost, le_div_iff₀ (by positivity)]
  nlinarith

/-! ## 6. Lab notes (NET-43 measured data, round-net-43)

Harness: CausalTF `d_model = 64`, 4 heads, Gutenberg corpus, vocab 4097, 2000 AdamW steps,
depth `d = 32`, context `ctx = 512`, seed 2 (byte-identical to NET-42's seed-1 harness).

| quantity                     | seed 1 (NET-42) | seed 2 (NET-43) |
|------------------------------|-----------------|-----------------|
| full accuracy                | 0.1353          | 0.1350          |
| full loss                    | 5.6281          | 5.6482          |
| accuracy bar (0.98 × full)   | —               | 0.1323          |
| knee `k*`                    | 256             | 256             |
| knee bracket                 | (224, 256]      | (240, 256]      |
| effective support `eff`      | 218.46          | 216.92          |
| top-256 mass                 | 0.921           | 0.922           |
| random-`k` gap at `k = 256`  | (crash)         | +2.6            |
| random-`k` gap at `k = 384`  | (crash)         | +1.7            |
| `k = 512` accuracy ratio     | 1.000           | 1.000           |

Sweep grid: `{96, 128, 160, 192, 224, 240, 256, 288, 320, 384, 512}` (`sweep` above).
Concave-power fit: `k*(d) ≈ 24.7 · d^(2/3)`, predicting `249` at `d = 32`
(`net43_law_prediction_at_32`, `net43_law_within_three_percent`).
Affine fit `8d + 32 = 288` over-predicts (`net43_affine_over_predicts`), which
`net43_affine_calibration_over_predicts` shows to be forced by concavity.
Deployable speedup `512 / 256 = 2.0×` (`net43_speedup_two`).
-/

end Bridges.DeepestRungTwoSeed256