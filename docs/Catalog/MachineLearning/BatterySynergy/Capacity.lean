/-
# BATTERY-SYNERGY, part II: joint capacity, synergy, and the two ceilings

The round-27 experiment (paper 92, verdict *SYNERGY-COMPOUNDS*) measures, for a
four-dial battery of CRT moduli `31 · 23 · 9 · 8 = 51336` read against one
shared semiprime population:

| quantity | measured |
|---|---|
| joint capacity `I` | `8.2246` bits |
| additive prediction `Σ` marginals | `3.9099` bits |
| synergy `I − Σ` | `+4.3147` bits |
| joint label-entropy ceiling | `9.5276` bits |
| total pairwise synergy | `+0.244` bits |

This file formalises the *capacity arithmetic* the verdict says must be done
jointly.  On top of `MachineLearning.BatterySynergy.MutualInformation` it
defines, for a battery of dials `d : ι → TraceBattery.Dial Ω` and a label
`L : Ω → Λ`,

* `BatterySynergy.info d L S` — the joint capacity in bits of the sub-battery
  `S`, i.e. `I(L ; (read i)_{i ∈ S})`;
* `BatterySynergy.synergy d L S` — its excess over the additive prediction;
* `BatterySynergy.pairSynergyTotal d L S` — the total of the pairwise synergies,
  the entire content of the paper-91 table.

and proves:

* `info_empty` — an empty battery carries nothing, so all capacity is built up
  by adding dials;
* `info_mono` — **capacity is monotone in the battery** (data processing);
* `info_le_label_entropy` — the **joint-label-entropy ceiling** (`9.5276`);
* `info_le_capacity`, `info_le_logb_prod` — the **CRT code ceiling**
  (`log₂ 51336`) and the sparse-code ceiling `log₂ #Ω`;
* `synergy_le_label_entropy`, `synergy_ge_of_mem` — two-sided bounds on synergy:
  super-additivity is capped by the label entropy, and sub-additivity is capped
  by the marginal bookkeeping it defeats;
* `synergy_eq_info_of_marginals_zero` — the extreme regime the witness file
  realises: when the marginals vanish the synergy *is* the capacity;
* `round27_table_consistent` — the reported numbers obey every proven ceiling.
-/
import Mathlib
import Combinatorics.TraceBatteryCapacity
import MachineLearning.BatterySynergy.MutualInformation

namespace BatterySynergy

open TraceBattery Finset

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {ι : Type*}

/-! ## 1. Capacity of a sub-battery -/

/-- The **joint capacity** in bits of the sub-battery `S` read against the label
`L`: the trace information `I(L ; (read i)_{i ∈ S})`. -/
noncomputable def info (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) : ℝ :=
  MIb L (joint d S)

/-- The **synergy** of the sub-battery `S`: its capacity minus the additive
prediction obtained by summing the single-dial capacities. -/
noncomputable def synergy (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) : ℝ :=
  info d L S - ∑ i ∈ S, info d L {i}

/-- The total pairwise synergy inside `S` — the quantity tabulated in paper 91. -/
noncomputable def pairSynergyTotal (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) : ℝ :=
  ∑ T ∈ S.powersetCard 2, synergy d L T

theorem info_nonneg (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) : 0 ≤ info d L S :=
  MIb_nonneg _ _

/-! ## 2. The empty battery -/

/-- A constant statistic carries no information about any label. -/
theorem MI_eq_zero_of_const [Nonempty Ω] {α : Type*} (L : Ω → Λ) (f : Ω → α)
    (hf : ∀ x y, f x = f y) : MI L f = 0 := by
  classical
  have himg : img f = {f (Classical.arbitrary Ω)} := by
    apply Finset.eq_singleton_iff_unique_mem.2
    refine ⟨self_mem_img _ _, fun a ha => ?_⟩
    obtain ⟨x, hx⟩ := mem_img.1 ha
    rw [← hx]
    exact hf x _
  have hcnt : ∀ a ∈ img f, cnt f a = Fintype.card Ω := by
    intro a ha
    obtain ⟨x, hx⟩ := mem_img.1 ha
    have : fib f a = Finset.univ := by
      ext y
      simp only [Finset.mem_univ, iff_true, mem_fib]
      rw [← hx]
      exact hf y x
    rw [cnt, this, Finset.card_univ]
  have hHf : H f = 0 := by
    rw [H_eq_log_card_img_of_uniform f (Fintype.card Ω) Fintype.card_pos hcnt, himg]
    simp
  have hpr : H (pr L f) = H L := by
    refine H_eq_of_same_fibers (pr L f) L fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    exact ⟨fun h => h.1, fun h => ⟨h, hf x y⟩⟩
  rw [MI_eq, hHf, hpr]
  ring

/-- **The empty battery carries nothing.**  Capacity is entirely built up by
adding dials. -/
theorem info_empty [Nonempty Ω] (d : ι → Dial Ω) (L : Ω → Λ) : info d L ∅ = 0 := by
  have hconst : ∀ x y : Ω, joint d (∅ : Finset ι) x = joint d ∅ y := by
    intro x y
    funext i
    exact absurd i.2 (Finset.notMem_empty _)
  rw [info, MIb, MI_eq_zero_of_const L (joint d ∅) hconst, zero_div]

theorem synergy_empty [Nonempty Ω] (d : ι → Dial Ω) (L : Ω → Λ) : synergy d L ∅ = 0 := by
  rw [synergy, info_empty]
  simp

/-! ## 3. Monotonicity: capacity grows with the battery -/

/-- **Monotone capacity.**  Adding dials to a battery can never lower the
capacity it carries about the label.  Unlike `TraceBattery.capacity_mono`, which
is monotonicity of the *code* entropy, this is a data processing inequality for
mutual information. -/
theorem info_mono (d : ι → Dial Ω) (L : Ω → Λ) {S T : Finset ι} (h : S ⊆ T) :
    info d L S ≤ info d L T := by
  have hj : joint d S = (restr h) ∘ (joint d T) := joint_restrict d h
  rw [info, info, hj]
  exact MIb_comp_le L (joint d T) (restr h)

/-- Every dial's marginal capacity is available to the battery containing it. -/
theorem info_single_le (d : ι → Dial Ω) (L : Ω → Λ) {S : Finset ι} {i : ι} (hi : i ∈ S) :
    info d L {i} ≤ info d L S :=
  info_mono d L (Finset.singleton_subset_iff.2 hi)

/-! ## 4. The two ceilings -/

/-- **Joint-label-entropy ceiling.**  No battery can carry more than the entropy
of the label population — the `9.5276`-bit ceiling of the experiment. -/
theorem info_le_label_entropy (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) :
    info d L S ≤ Hb L :=
  MIb_le_label_entropy _ _

/-- **Code ceiling.**  The capacity of a sub-battery is at most the entropy of
its own joint code. -/
theorem info_le_capacity (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) :
    info d L S ≤ capacity d S :=
  MIb_le_stat_entropy _ _

/-- **CRT ceiling.**  Composing with `TraceBattery.capacity_le_logb_prod`: the
capacity of a sub-battery is at most `log₂` of the product of its moduli — for
the round-27 battery, `log₂ (31 · 23 · 9 · 8) = log₂ 51336`. -/
theorem info_le_logb_prod [Nonempty Ω] [DecidableEq ι] (d : ι → Dial Ω) (L : Ω → Λ)
    (S : Finset ι) :
    info d L S ≤ Real.logb 2 (∏ i ∈ S, (d i).modulus : ℕ) :=
  (info_le_capacity d L S).trans (capacity_le_logb_prod d S)

/-- **Sparse-table ceiling.**  With `N` individuals no statistic, however many
residue columns it has, can carry more than `log₂ N` bits — the regime in which
the paper's `0.0469`-bit which-factor reading is plug-in bias. -/
theorem info_le_logb_pop (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) :
    info d L S ≤ Real.logb 2 (Fintype.card Ω : ℝ) :=
  (info_le_capacity d L S).trans (capacity_le_logb_pop d S)

/-! ## 5. Synergy: two-sided bounds -/

/-- Super-additivity is capped by the label entropy. -/
theorem synergy_le_label_entropy (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) :
    synergy d L S ≤ Hb L := by
  have h1 : info d L S ≤ Hb L := info_le_label_entropy d L S
  have h2 : 0 ≤ ∑ i ∈ S, info d L {i} :=
    Finset.sum_nonneg fun i _ => info_nonneg d L {i}
  rw [synergy]
  linarith

/-- Sub-additivity is capped by the marginals it defeats: the capacity of the
battery is at least that of any single dial in it. -/
theorem synergy_ge_of_mem (d : ι → Dial Ω) (L : Ω → Λ) {S : Finset ι} {i : ι} (hi : i ∈ S) :
    info d L {i} - ∑ j ∈ S, info d L {j} ≤ synergy d L S := by
  have := info_single_le d L hi
  rw [synergy]
  linarith

/-- **The extreme super-additive regime.**  If every dial is individually blind
to the label, then the whole capacity of the battery is synergy. -/
theorem synergy_eq_info_of_marginals_zero (d : ι → Dial Ω) (L : Ω → Λ) {S : Finset ι}
    (h : ∀ i ∈ S, info d L {i} = 0) : synergy d L S = info d L S := by
  rw [synergy, Finset.sum_congr rfl h]
  simp

/-- In that regime the battery is strictly super-additive as soon as it carries
anything at all. -/
theorem synergy_pos_of_marginals_zero (d : ι → Dial Ω) (L : Ω → Λ) {S : Finset ι}
    (h : ∀ i ∈ S, info d L {i} = 0) (hpos : 0 < info d L S) : 0 < synergy d L S := by
  rw [synergy_eq_info_of_marginals_zero d L h]
  exact hpos

/-! ## 6. Numeric certificates for the round-27 table -/

/-- `log₂ 51336 ≥ 15`, so the reported joint capacity `8.2246` bits sits far
below the CRT ceiling of the four-dial battery. -/
theorem reported_joint_below_crt_ceiling : (8.2246 : ℝ) ≤ Real.logb 2 51336 := by
  have h15 : (15 : ℝ) ≤ Real.logb 2 51336 := by
    rw [show (15 : ℝ) = Real.logb 2 ((2 : ℝ) ^ (15 : ℕ)) by
      simp [Real.logb_pow, Real.logb_self_eq_one]]
    gcongr <;> norm_num
  linarith

/-- **The reported round-27 numbers obey the proven structure.**  The measured
joint capacity lies below the joint label-entropy ceiling and below the CRT
ceiling; the synergy is exactly the reported excess over the additive
prediction, it more than doubles that prediction, and the pairwise total is
under `6%` of it. -/
theorem round27_table_consistent :
    (8.2246 : ℝ) ≤ 9.5276 ∧
    (8.2246 : ℝ) ≤ Real.logb 2 51336 ∧
    (8.2246 : ℝ) - 3.9099 = 4.3147 ∧
    2 * (3.9099 : ℝ) < 8.2246 ∧
    (0.244 : ℝ) < 0.06 * 4.3147 := by
  refine ⟨by norm_num, reported_joint_below_crt_ceiling, by norm_num, by norm_num, by norm_num⟩

/-- **The synergy budget.**  A battery's synergy is paid for out of the code
capacity its dials leave unused: it never exceeds the total of
`(per-dial code entropy) − (per-dial trace information)`.  For the round-27
battery the budget is `log₂ 51336 − 3.9099 ≈ 11.7` bits, comfortably above the
measured `+4.3147`. -/
theorem synergy_le_unused_code [Nonempty Ω] [DecidableEq ι] (d : ι → Dial Ω) (L : Ω → Λ) (S : Finset ι) :
    synergy d L S ≤ ∑ i ∈ S, (dialCapacity d i - info d L {i}) := by
  have h1 : info d L S ≤ ∑ i ∈ S, dialCapacity d i :=
    (info_le_capacity d L S).trans (capacity_le_sum_dials d S)
  rw [synergy, Finset.sum_sub_distrib]
  linarith

/-- The reported synergy `+4.3147` bits fits inside the budget left by the CRT
code of the four-dial battery against the reported marginal total. -/
theorem reported_synergy_within_budget :
    (4.3147 : ℝ) ≤ Real.logb 2 51336 - 3.9099 := by
  have h15 : (15 : ℝ) ≤ Real.logb 2 51336 := by
    rw [show (15 : ℝ) = Real.logb 2 ((2 : ℝ) ^ (15 : ℕ)) by
      simp [Real.logb_pow, Real.logb_self_eq_one]]
    gcongr <;> norm_num
  linarith

end BatterySynergy