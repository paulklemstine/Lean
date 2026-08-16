/-
# NET-30 / Catalog·NumberTheory — A saturating-gate population model: the k = 2
signature realised, and the k = 1 arms shown to be unconstrained

The two companion files are *negative*: the measured s = 13, k = 2 signature
(single-coordinate ablations inside the no-op band, whole-block ablation costing
0.24, sign flip costing as much) is impossible for an affine read-out
(`NumberTheory.ExclusiveChannelInterventions`) and, more sharply, for any convex
one (`NumberTheory.ExclusiveChannelConvexity`).  This file supplies the matching
*positive* half: an explicit, fully computed model in which the entire published
NET-30 s = 13 row is reproduced, and a theorem showing the Part B (`k = 1`) rows
carry no information at all about the model class.

Ingredients.

* `ItemPopulation`: a finite population of evaluation items with masses summing
  to `1`, item `i` being answered correctly exactly when the boundary gate value
  reaches its difficulty threshold `thr i`.  `ItemPopulation.acc γ` is the
  accuracy at gate value `γ`; it is monotone in `γ` (`acc_mono`).
* `satGate`: the saturating boundary gate `min (max (∑ i, c i) 0) 1` on the
  exclusive coefficients — rectified (hence sign-sensitive) and saturating
  (hence redundant).
* `s13_k2_saturating_realization`: one population, one coefficient vector
  `c = ![1, 1]`, and **all six** published s = 13 arm numbers reproduced to
  within `0.005` (the reported no-op scale): `ctl 0.9980`, `zeroAt 0 0.9961`,
  `zeroAt 1 0.9990`, `zeroAll 0.7544`, `flipAt 0 0.7505`, `scale 0.1 0.9067`.
  The model *predicts* the exact no-op of both single ablations and the
  simultaneous sign- and magnitude-sensitivity, which is what the arm shows.
* `acc_scaleAll_mono`: the scale curve is monotone, so `zeroAll ≤ scale l ≤ ctl`
  — matching the measured `0.7544 ≤ 0.9067 ≤ 0.9980` ordering.
* `missing_middle_sharp`: the headline. In this model class the
  "1-redundant but block-dependent" phenomenon **occurs at k = 2** and
  **cannot occur at k ≤ 1** — the formal statement of "the missing middle".
* `interventions_noop_of_boundary_free`, `noop_all_iff_acc_zero_eq`: a
  boundary-free arm (control accuracy already equal to the zero-gate accuracy)
  is unchanged by every gate-weakening intervention, and that is the *only* way
  for all of them to be no-ops.  This is the pooled Part B invariant — the
  failed arms are no-ops in every arm of both rounds — and it shows such a
  no-op is evidence that the channel was never used, not of internalisation.
* `k1_profile_unconstrained`: at `k = 1` *every* admissible pair of control and
  ablation accuracies `0 ≤ β ≤ α ≤ 1` is realised by some population.  The
  seed-heterogeneous Part B outcomes (two exact self-sufficient cures, two
  no-ops, two ~2 SE marginal losses) are therefore all inside the same class:
  no `k = 1` observation constrains it, which is precisely why the
  proportionality law it was used to support does not survive.
-/

import Mathlib
import NumberTheory.ExclusiveChannelInterventions

namespace NumberTheory.ExclusiveChannel

open Finset

/-! ## Populations of evaluation items -/

/-- A finite population of evaluation items: item `i` carries mass `mass i`
(the masses sum to one) and is answered correctly exactly when the boundary gate
value reaches the difficulty threshold `thr i`. -/
structure ItemPopulation where
  /-- number of item groups -/
  n : ℕ
  /-- mass (relative frequency) of each group -/
  mass : Fin n → ℝ
  /-- difficulty threshold of each group -/
  thr : Fin n → ℝ
  mass_nonneg : ∀ i, 0 ≤ mass i
  mass_sum : ∑ i, mass i = 1

/-- Accuracy of the population at boundary gate value `γ`. -/
noncomputable def ItemPopulation.acc (P : ItemPopulation) (γ : ℝ) : ℝ :=
  ∑ i, if P.thr i ≤ γ then P.mass i else 0

/-- Accuracy is monotone in the gate value: a stronger boundary signal never
loses items. -/
theorem ItemPopulation.acc_mono (P : ItemPopulation) {γ δ : ℝ} (h : γ ≤ δ) :
    P.acc γ ≤ P.acc δ := by
  refine Finset.sum_le_sum fun i _ => ?_
  by_cases hi : P.thr i ≤ γ
  · rw [if_pos hi, if_pos (hi.trans h)]
  · rw [if_neg hi]
    by_cases hi' : P.thr i ≤ δ
    · rw [if_pos hi']; exact P.mass_nonneg i
    · rw [if_neg hi']

/-! ## The saturating boundary gate -/

/-- The saturating boundary gate: the exclusive block's coefficients are summed,
rectified and clipped at `1`.  Rectification makes it sign-sensitive, clipping
makes it redundant. -/
noncomputable def satGate {k : ℕ} (c : Fin k → ℝ) : ℝ := min (max (∑ i, c i) 0) 1

@[simp] theorem satGate_zeroAll {k : ℕ} (c : Fin k → ℝ) : satGate (zeroAll c) = 0 := by
  simp [satGate, zeroAll]

/-- The clipped part of the gate is concave, which is what forces redundancy
(see `NumberTheory.ExclusiveChannelConvexity`). -/
theorem concaveOn_min_one : ConcaveOn ℝ Set.univ (fun x : ℝ => min x 1) :=
  (concaveOn_id convex_univ).inf (concaveOn_const 1 convex_univ)

/-- Monotonicity of the gate in the block scale, for a nonnegatively-summing
block. -/
theorem satGate_scaleAll_mono {k : ℕ} {c : Fin k → ℝ} (hc : 0 ≤ ∑ i, c i)
    {l l' : ℝ} (hll : l ≤ l') :
    satGate (scaleAll l c) ≤ satGate (scaleAll l' c) := by
  have hsum : ∀ m : ℝ, ∑ i, scaleAll m c i = m * ∑ i, c i := by
    intro m
    simp only [scaleAll, ← Finset.mul_sum]
  simp only [satGate, hsum]
  exact min_le_min (max_le_max (by nlinarith) le_rfl) le_rfl

/-- Consequently the measured scale curve is monotone: the whole-block ablation
is the worst case and the control the best, with every `scale l` in between. -/
theorem acc_scaleAll_mono (P : ItemPopulation) {k : ℕ} {c : Fin k → ℝ}
    (hc : 0 ≤ ∑ i, c i) {l l' : ℝ} (hll : l ≤ l') :
    P.acc (satGate (scaleAll l c)) ≤ P.acc (satGate (scaleAll l' c)) :=
  P.acc_mono (satGate_scaleAll_mono hc hll)

/-! ## Gate values of the six s = 13 interventions at `c = ![1, 1]` -/

/-- The control coefficient vector of the realisation: both exclusive
coordinates carry gain `1`, and the gate is already saturated at `1` — the
structural reason each single ablation is a no-op. -/
noncomputable def s13coef : Fin 2 → ℝ := ![1, 1]

theorem satGate_s13coef : satGate s13coef = 1 := by
  simp [satGate, s13coef, Fin.sum_univ_succ]

theorem satGate_s13_zeroAt (i : Fin 2) : satGate (zeroAt i s13coef) = 1 := by
  fin_cases i <;>
    simp [satGate, zeroAt, s13coef, Fin.sum_univ_succ, Function.update_of_ne]

theorem satGate_s13_flipAt : satGate (flipAt 0 s13coef) = 0 := by
  simp [satGate, flipAt, s13coef, Fin.sum_univ_succ, Function.update_of_ne]

theorem satGate_s13_scale : satGate (scaleAll (1 / 10) s13coef) = 1 / 5 := by
  norm_num [satGate, scaleAll, s13coef, Fin.sum_univ_succ]

/-! ## The s = 13 population -/

/-- Four difficulty groups tuned to the measured s = 13 length profile: 75.44 %
of the evaluation mass needs no boundary signal at all, 15.23 % needs a fifth of
it, 9.13 % needs half of it, and 0.20 % is never solved. -/
noncomputable def s13pop : ItemPopulation where
  n := 4
  mass := ![7544 / 10000, 1523 / 10000, 913 / 10000, 20 / 10000]
  thr := ![0, 1 / 5, 1 / 2, 2]
  mass_nonneg := by intro i; fin_cases i <;> norm_num
  mass_sum := by norm_num [Fin.sum_univ_succ]

@[simp] theorem s13pop_mass_eq :
    s13pop.mass = ![7544 / 10000, 1523 / 10000, 913 / 10000, 20 / 10000] := rfl

@[simp] theorem s13pop_thr_eq : s13pop.thr = ![0, 1 / 5, 1 / 2, 2] := rfl

@[simp] theorem s13pop_n_eq : s13pop.n = 4 := rfl

theorem s13pop_acc_zero : s13pop.acc 0 = 7544 / 10000 := by
  show (∑ i : Fin 4, if (![0, 1 / 5, 1 / 2, 2] : Fin 4 → ℝ) i ≤ 0 then (![7544 / 10000, 1523 / 10000, 913 / 10000, 20 / 10000] : Fin 4 → ℝ) i else 0) = 7544 / 10000
  norm_num [Fin.sum_univ_succ]

theorem s13pop_acc_fifth : s13pop.acc (1 / 5) = 9067 / 10000 := by
  show (∑ i : Fin 4, if (![0, 1 / 5, 1 / 2, 2] : Fin 4 → ℝ) i ≤ (1 / 5) then (![7544 / 10000, 1523 / 10000, 913 / 10000, 20 / 10000] : Fin 4 → ℝ) i else 0) = 9067 / 10000
  norm_num [Fin.sum_univ_succ]

theorem s13pop_acc_one : s13pop.acc 1 = 9980 / 10000 := by
  show (∑ i : Fin 4, if (![0, 1 / 5, 1 / 2, 2] : Fin 4 → ℝ) i ≤ 1 then (![7544 / 10000, 1523 / 10000, 913 / 10000, 20 / 10000] : Fin 4 → ℝ) i else 0) = 9980 / 10000
  norm_num [Fin.sum_univ_succ]

/-- **The measured s = 13, k = 2 arm, realised.**  A single saturating-gate
population reproduces all six published accuracies to within `0.005`, the
reported no-op scale:

`ctl 0.9980 | zeroAt 0 0.9961 | zeroAt 1 0.9990 | zeroAll 0.7544 |
 flipAt 0 0.7505 | scale 0.1 0.9067`.

The two single ablations are *exact* no-ops in the model (gate stays saturated),
whereas the block ablation, the sign flip and the ×0.1 rescaling all break the
gate — the sign- and magnitude-sensitivity of the arm. -/
theorem s13_k2_saturating_realization :
    ∃ (P : ItemPopulation) (c : Fin 2 → ℝ),
      |P.acc (satGate c) - 9980 / 10000| ≤ 5 / 1000 ∧
      |P.acc (satGate (zeroAt 0 c)) - 9961 / 10000| ≤ 5 / 1000 ∧
      |P.acc (satGate (zeroAt 1 c)) - 9990 / 10000| ≤ 5 / 1000 ∧
      |P.acc (satGate (zeroAll c)) - 7544 / 10000| ≤ 5 / 1000 ∧
      |P.acc (satGate (flipAt 0 c)) - 7505 / 10000| ≤ 5 / 1000 ∧
      |P.acc (satGate (scaleAll (1 / 10) c)) - 9067 / 10000| ≤ 5 / 1000 := by
  refine ⟨s13pop, s13coef, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [satGate_s13coef, s13pop_acc_one]; norm_num
  · rw [satGate_s13_zeroAt 0, s13pop_acc_one]
    rw [abs_of_nonneg (by norm_num)]; norm_num
  · rw [satGate_s13_zeroAt 1, s13pop_acc_one]
    rw [abs_of_nonpos (by norm_num)]; norm_num
  · rw [satGate_zeroAll, s13pop_acc_zero]; norm_num
  · rw [satGate_s13_flipAt, s13pop_acc_zero]
    rw [abs_of_nonneg (by norm_num)]; norm_num
  · rw [satGate_s13_scale, s13pop_acc_fifth]; norm_num

/-- The realisation is 1-redundant (both single ablations are exact no-ops) and
block-dependent (the whole-block ablation costs `0.2436`). -/
theorem s13_realization_redundant_and_block_dependent :
    (∀ i : Fin 2, s13pop.acc (satGate (zeroAt i s13coef)) = s13pop.acc (satGate s13coef)) ∧
      s13pop.acc (satGate s13coef) - s13pop.acc (satGate (zeroAll s13coef)) = 2436 / 10000 := by
  constructor
  · intro i
    rw [satGate_s13_zeroAt i, satGate_s13coef]
  · rw [satGate_s13coef, satGate_zeroAll, s13pop_acc_one, s13pop_acc_zero]
    norm_num

/-! ## The missing middle, sharp -/

/-- **The missing middle.**  In the saturating-gate population class the
signature "every single-coordinate ablation is a no-op, the whole-block ablation
is not" is *realised at `k = 2`* and *impossible at `k ≤ 1`* — at one exclusive
coordinate the two interventions are the same map, so no population, gate or
evaluation draw can separate them.  This is why NET-30's Part B could not have
found the effect, independently of what the networks learned. -/
theorem missing_middle_sharp :
    (∃ (P : ItemPopulation) (c : Fin 2 → ℝ),
        (∀ i, P.acc (satGate (zeroAt i c)) = P.acc (satGate c)) ∧
          P.acc (satGate (zeroAll c)) ≠ P.acc (satGate c)) ∧
      (∀ (k : ℕ), k ≤ 1 → ∀ (P : ItemPopulation) (c : Fin k → ℝ),
        (∀ i, P.acc (satGate (zeroAt i c)) = P.acc (satGate c)) →
          P.acc (satGate (zeroAll c)) = P.acc (satGate c)) := by
  constructor
  · refine ⟨s13pop, s13coef, s13_realization_redundant_and_block_dependent.1, ?_⟩
    have h := s13_realization_redundant_and_block_dependent.2
    intro hcontra
    rw [hcontra] at h
    norm_num at h
  · intro k hk P c hred
    exact block_self_sufficient_of_redundant_of_le_one hk
      (fun c => P.acc (satGate c)) c hred


/-! ## Why the failed arms are no-ops in every intervention

Pooled over all twelve `k = 1` arms of NET-29 and NET-30, removal of the sole
exclusive coordinate is a no-op *in every arm where the model had already
failed*.  In the population model this is forced: an arm whose accuracy is
already the boundary-free accuracy `acc 0` has no gate-dependent mass among the
items it solves, so weakening the gate — by ablation, by a partial ablation, or
by rescaling — cannot cost anything. -/

/-- The gate is monotone in the block sum. -/
theorem satGate_le_satGate_of_sum_le {k : ℕ} {c c' : Fin k → ℝ}
    (h : ∑ i, c i ≤ ∑ i, c' i) : satGate c ≤ satGate c' :=
  min_le_min (max_le_max h le_rfl) le_rfl

theorem satGate_nonneg {k : ℕ} (c : Fin k → ℝ) : 0 ≤ satGate c :=
  le_min (le_max_right _ _) zero_le_one

/-- Ablating a coordinate of a nonnegative block can only weaken the gate. -/
theorem satGate_zeroAt_le {k : ℕ} {c : Fin k → ℝ} (hc : ∀ i, 0 ≤ c i) (i : Fin k) :
    satGate (zeroAt i c) ≤ satGate c := by
  refine satGate_le_satGate_of_sum_le ?_
  have h : ∑ j, zeroAt i c j = (∑ j, c j) - c i := by
    simpa [margin] using margin_zeroAt 0 (fun _ => (1 : ℝ)) c i
  rw [h]
  linarith [hc i]

/-- **Boundary-free arms are intervention-proof.**  An arm whose control
accuracy already equals its zero-gate accuracy is unchanged by *every*
gate-weakening intervention — which is exactly the pooled Part B observation
that the failed arms are no-ops, in both rounds and at every seed. -/
theorem noop_of_acc_zero_eq (P : ItemPopulation) {k : ℕ} (c : Fin k → ℝ)
    (hfree : P.acc 0 = P.acc (satGate c)) {γ : ℝ} (hγ : 0 ≤ γ) (hγc : γ ≤ satGate c) :
    P.acc γ = P.acc (satGate c) :=
  le_antisymm (P.acc_mono hγc) (hfree ▸ P.acc_mono hγ)

/-- Conversely, a boundary-free arm is the *only* way for all weakenings of the
gate to be no-ops, so "no-op at the failed arms" is not evidence of
internalisation: it is evidence that the boundary channel was never used. -/
theorem noop_all_iff_acc_zero_eq (P : ItemPopulation) {k : ℕ} (c : Fin k → ℝ) :
    (∀ γ, 0 ≤ γ → γ ≤ satGate c → P.acc γ = P.acc (satGate c)) ↔
      P.acc 0 = P.acc (satGate c) := by
  constructor
  · intro h
    exact h 0 le_rfl (satGate_nonneg c)
  · intro h γ hγ hγc
    exact noop_of_acc_zero_eq P c h hγ hγc

/-- Applied to the interventions themselves: at a boundary-free arm with
nonnegative exclusive coefficients, the whole-block ablation and every
single-coordinate ablation are exact no-ops. -/
theorem interventions_noop_of_boundary_free (P : ItemPopulation) {k : ℕ} {c : Fin k → ℝ}
    (hc : ∀ i, 0 ≤ c i) (hfree : P.acc 0 = P.acc (satGate c)) :
    P.acc (satGate (zeroAll c)) = P.acc (satGate c) ∧
      ∀ i, P.acc (satGate (zeroAt i c)) = P.acc (satGate c) := by
  constructor
  · rw [satGate_zeroAll]
    exact hfree
  · intro i
    exact noop_of_acc_zero_eq P c hfree (satGate_nonneg _) (satGate_zeroAt_le hc i)

/-! ## Part B: the k = 1 rows constrain nothing -/

/-- **k = 1 profiles are unconstrained.**  For every admissible pair
`0 ≤ β ≤ α ≤ 1` there is a saturating-gate population whose control accuracy is
`α` and whose (unique) single-coordinate ablation — equivalently whole-block
ablation — accuracy is `β`.  Self-sufficient cures (`β = α`), no-ops at a failed
arm (`β = α` small), and partial losses (`β < α`) are all in the class, so the
seed-heterogeneous Part B table carries no information about it. -/
theorem k1_profile_unconstrained {α β : ℝ} (hβ : 0 ≤ β) (hβα : β ≤ α) (hα : α ≤ 1) :
    ∃ (P : ItemPopulation) (c : Fin 1 → ℝ),
      P.acc (satGate c) = α ∧ P.acc (satGate (zeroAll c)) = β ∧
        ∀ i, P.acc (satGate (zeroAt i c)) = β := by
  refine ⟨⟨3, ![β, α - β, 1 - α], ![0, 1, 2], ?_, ?_⟩, ![1], ?_, ?_, ?_⟩
  · intro i; fin_cases i <;> simp <;> linarith
  · norm_num [Fin.sum_univ_succ]
  · have hg : satGate (![1] : Fin 1 → ℝ) = 1 := by
      simp [satGate]
    rw [hg]
    show (∑ x : Fin 3, if (![0, 1, 2] : Fin 3 → ℝ) x ≤ 1 then (![β, α - β, 1 - α] : Fin 3 → ℝ) x else 0) = α
    norm_num [Fin.sum_univ_succ]
  · rw [satGate_zeroAll]
    show (∑ x : Fin 3, if (![0, 1, 2] : Fin 3 → ℝ) x ≤ 0 then (![β, α - β, 1 - α] : Fin 3 → ℝ) x else 0) = β
    norm_num [Fin.sum_univ_succ]
  · intro i
    rw [zeroAt_eq_zeroAll_of_one _ i, satGate_zeroAll]
    show (∑ x : Fin 3, if (![0, 1, 2] : Fin 3 → ℝ) x ≤ 0 then (![β, α - β, 1 - α] : Fin 3 → ℝ) x else 0) = β
    norm_num [Fin.sum_univ_succ]

end NumberTheory.ExclusiveChannel