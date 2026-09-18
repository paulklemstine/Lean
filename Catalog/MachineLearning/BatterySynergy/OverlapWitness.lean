/-
# BATTERY-SYNERGY, part VI: one battery realising all three rows of paper 91

Round-27 #1 (verdict *SYNERGY-AND-OVERLAP*) measured three two-dial batteries
against one population and found three different signs:

| battery | `I(joint)` | `I₁ + I₂` | `Δ` |
|---|---|---|---|
| `S₃a@31 × S₃b@23` | `2.1314` | `2.0024` | `+0.129` |
| `A₄@9 × D₄@8` | `1.9125` | `1.9076` | `+0.005` |
| `S₃a@23 × S₃b@23` | `1.0104` | `2.0024` | `−0.992` |

so the battery space is *neither additive nor comonotone*.  Part V proved the
exact law behind this, `Δ = I(f;g|L) − I(f;g)`.  This file shows that all three
signs are realised — with the extreme values `+1`, `0`, `−1` bit — by **one**
three-dial battery on a four-element population:

* the population is `Bool × Bool`;
* dial `0` reads the first bit, dial `1` reads the second bit, and dial `2` is a
  *duplicate* of dial `0` (the "shared conductor" dial: same subfield, same
  dial);
* two labels are read: the parity `labX` and the first bit `labF`.

Then

* `OverlapWitness.synergy_row_pos` — `Δ(labX; dials 0,1) = +1` bit, pure synergy:
  both marginals are `0` and the joint pins the label;
* `OverlapWitness.synergy_row_zero` — `Δ(labF; dials 0,1) = 0`, exact
  additivity;
* `OverlapWitness.synergy_row_neg` — `Δ(labF; dials 0,2) = −1` bit, total
  overlap: the second dial is redundant and the deficit is a full marginal;
* `OverlapWitness.coinformation_explains_rows` — and in each case the co-informa­
  tion identity of part V accounts for the sign: the `+1` comes from conditional
  dependence with zero unconditional dependence, the `−1` from unconditional
  dependence with zero conditional dependence;
* `OverlapWitness.battery_space_neither_additive_nor_comonotone` — the verdict:
  no additivity law and no comonotonicity law can hold for the pair operation,
  even on one fixed population with one fixed dial set.

Both bounds of part V are attained here: the overlap row meets
`overlap ≤ min (I₁, I₂)` and `overlap ≤ I(f ; g)` with equality.

`decide` is used only for finite combinatorial facts about four individuals
(fibre cardinalities and images), never for an entropy inequality.
-/
import Mathlib
import MachineLearning.BatterySynergy.CoInformation

namespace BatterySynergy

namespace OverlapWitness

open TraceBattery Finset

/-! ## 1. The population, the dials and the two labels -/

/-- The population: two bits, four individuals. -/
abbrev Pop2 : Type := Bool × Bool

/-- A bit as a residue modulo `2`. -/
def bit (b : Bool) : ℕ := if b then 1 else 0

theorem bit_lt_two (b : Bool) : bit b < 2 := by cases b <;> simp [bit]

/-- The reading of the first bit. -/
def rA (x : Pop2) : ℕ := bit x.1

/-- The reading of the second bit. -/
def rB (x : Pop2) : ℕ := bit x.2

/-- Dial `2` duplicates dial `0`: two dials that see the same subfield. -/
def r : Fin 3 → Pop2 → ℕ
  | ⟨0, _⟩ => rA
  | ⟨1, _⟩ => rB
  | _ => rA

/-- The parity label. -/
def labX (x : Pop2) : ℕ := bit (xor x.1 x.2)

/-- The first-bit label. -/
def labF (x : Pop2) : ℕ := bit x.1

/-- The three-dial battery: `(first bit, second bit, first bit again)`. -/
def qdial : Fin 3 → Dial Pop2 := fun i =>
  { modulus := 2
    modulus_pos := by norm_num
    read := r i
    read_lt := by
      intro x
      match i with
      | ⟨0, _⟩ => exact bit_lt_two _
      | ⟨1, _⟩ => exact bit_lt_two _
      | ⟨2, _⟩ => exact bit_lt_two _ }

theorem read_zero : (qdial 0).read = rA := rfl
theorem read_one : (qdial 1).read = rB := rfl
theorem read_two : (qdial 2).read = rA := rfl

/-! ## 2. Entropies on four individuals -/

theorem card_pop2 : Fintype.card Pop2 = 4 := by decide

theorem img_eq_of (f : Pop2 → ℕ) (T : Finset ℕ) (h1 : ∀ x, f x ∈ T)
    (h2 : ∀ a ∈ T, ∃ x, f x = a) : img f = T := by
  ext a
  simp only [mem_img]
  exact ⟨by rintro ⟨x, rfl⟩; exact h1 x, fun ha => h2 a ha⟩

theorem cnt_eq_of (f : Pop2 → ℕ) (a k : ℕ)
    (h : (Finset.univ.filter fun x => f x = a).card = k) : cnt f a = k := by
  rw [cnt, fib_eq_filter]
  exact h

theorem log4_eq : Real.log 4 = 2 * Real.log 2 := by
  rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow]
  push_cast
  ring

/-- A statistic with two cells of two individuals each has entropy `log 2`. -/
theorem H_log2_of (f : Pop2 → ℕ) (h1 : ∀ x, f x ∈ ({0, 1} : Finset ℕ))
    (h2 : ∀ a ∈ ({0, 1} : Finset ℕ), ∃ x, f x = a)
    (h3 : ∀ a ∈ ({0, 1} : Finset ℕ), (Finset.univ.filter fun x => f x = a).card = 2) :
    H f = Real.log 2 := by
  have himg : img f = ({0, 1} : Finset ℕ) := img_eq_of f _ h1 h2
  have h := H_eq_log_card_img_of_uniform f 2 (by norm_num)
    (fun a ha => cnt_eq_of f a 2 (h3 a (himg ▸ ha)))
  rw [h, himg]
  norm_num

/-- A statistic separating all four individuals has entropy `log 4`. -/
theorem H_log4_of (f : Pop2 → ℕ) (h1 : ∀ x, f x ∈ ({0, 1, 2, 3} : Finset ℕ))
    (h2 : ∀ a ∈ ({0, 1, 2, 3} : Finset ℕ), ∃ x, f x = a)
    (h3 : ∀ a ∈ ({0, 1, 2, 3} : Finset ℕ), (Finset.univ.filter fun x => f x = a).card = 1) :
    H f = Real.log 4 := by
  have himg : img f = ({0, 1, 2, 3} : Finset ℕ) := img_eq_of f _ h1 h2
  have h := H_eq_log_card_img_of_uniform f 1 (by norm_num)
    (fun a ha => cnt_eq_of f a 1 (h3 a (himg ▸ ha)))
  rw [h, himg]
  norm_num

theorem H_rA : H rA = Real.log 2 := H_log2_of rA (by decide) (by decide) (by decide)

theorem H_rB : H rB = Real.log 2 := H_log2_of rB (by decide) (by decide) (by decide)

theorem H_labX : H labX = Real.log 2 := H_log2_of labX (by decide) (by decide) (by decide)

theorem H_labF : H labF = Real.log 2 := H_log2_of labF (by decide) (by decide) (by decide)

theorem Hb_labX : Hb labX = 1 := by
  rw [Hb, H_labX]
  field_simp

/-! ## 3. The marginal capacities -/

/-- The parity label and one bit are jointly balanced on four cells. -/
theorem H_pr_labX_rA : H (pr labX rA) = Real.log 4 := by
  have hcode : H (pr labX rA) = H (fun x => 2 * labX x + rA x) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    revert x y
    decide
  rw [hcode]
  exact H_log4_of _ (by decide) (by decide) (by decide)

theorem H_pr_labX_rB : H (pr labX rB) = Real.log 4 := by
  have hcode : H (pr labX rB) = H (fun x => 2 * labX x + rB x) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    revert x y
    decide
  rw [hcode]
  exact H_log4_of _ (by decide) (by decide) (by decide)

theorem H_pr_labF_rB : H (pr labF rB) = Real.log 4 := by
  have hcode : H (pr labF rB) = H (fun x => 2 * labF x + rB x) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    revert x y
    decide
  rw [hcode]
  exact H_log4_of _ (by decide) (by decide) (by decide)

theorem H_pair_rA_rB : H (pair rA rB) = Real.log 4 := by
  have hcode : H (pair rA rB) = H (fun x => 2 * rA x + rB x) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pair, Prod.mk.injEq]
    revert x y
    decide
  rw [hcode]
  exact H_log4_of _ (by decide) (by decide) (by decide)

/-- **Each single dial is blind to the parity label.** -/
theorem MI_labX_rA : MI labX rA = 0 := by
  rw [MI_eq, H_labX, H_rA, H_pr_labX_rA, log4_eq]
  ring

theorem MI_labX_rB : MI labX rB = 0 := by
  rw [MI_eq, H_labX, H_rB, H_pr_labX_rB, log4_eq]
  ring

/-- Dial `1` is blind to the first-bit label. -/
theorem MI_labF_rB : MI labF rB = 0 := by
  rw [MI_eq, H_labF, H_rB, H_pr_labF_rB, log4_eq]
  ring

/-- Dial `0` pins the first-bit label, so it carries the whole label entropy. -/
theorem MI_labF_rA : MI labF rA = Real.log 2 := by
  rw [MI_eq_label_entropy_of_determines labF rA (fun x y h => h), H_labF]

/-- The pair of the two distinct dials pins the parity label. -/
theorem MI_labX_pair : MI labX (pair rA rB) = Real.log 2 := by
  have hdet : ∀ x y : Pop2, pair rA rB x = pair rA rB y → labX x = labX y := by
    intro x y
    simp only [pair, Prod.mk.injEq]
    revert x y
    decide
  rw [MI_eq_label_entropy_of_determines labX _ hdet, H_labX]

/-- The pair of the two distinct dials also pins the first-bit label. -/
theorem MI_labF_pair : MI labF (pair rA rB) = Real.log 2 := by
  have hdet : ∀ x y : Pop2, pair rA rB x = pair rA rB y → labF x = labF y := by
    intro x y
    simp only [pair, Prod.mk.injEq]
    revert x y
    decide
  rw [MI_eq_label_entropy_of_determines labF _ hdet, H_labF]

/-! ## 4. The three rows -/

/-- **Row 1 — synergy.**  Read against the parity label, the two distinct dials
are individually blind and jointly complete: the pair synergy is `+1` bit, the
maximum allowed by the label-entropy ceiling. -/
theorem synergy_row_pos : synergy qdial labX {0, 1} = 1 := by
  rw [synergy_pair_eq_pairSynergyb qdial labX (by decide : (0 : Fin 3) ≠ 1),
    read_zero, read_one, pairSynergyb, pairSynergy, MI_labX_pair, MI_labX_rA, MI_labX_rB,
    sub_zero, sub_zero, div_self (ne_of_gt log_two_pos)]

/-- **Row 2 — exact additivity.**  Read against the first-bit label the same two
dials are exactly additive: dial `0` carries the whole bit, dial `1` carries
nothing, and the joint carries the bit. -/
theorem synergy_row_zero : synergy qdial labF {0, 1} = 0 := by
  rw [synergy_pair_eq_pairSynergyb qdial labF (by decide : (0 : Fin 3) ≠ 1),
    read_zero, read_one, pairSynergyb, pairSynergy, MI_labF_pair, MI_labF_rA, MI_labF_rB]
  simp

/-- **Row 3 — total overlap.**  Dial `2` duplicates dial `0` ("same subfield =
same dial"): the additive prediction double-counts one full bit, so the pair
synergy is `−1`. -/
theorem synergy_row_neg : synergy qdial labF {0, 2} = -1 := by
  have hdup := pairSynergy_eq_neg_of_refines labF rA rA id rfl
  rw [synergy_pair_eq_pairSynergyb qdial labF (by decide : (0 : Fin 3) ≠ 2),
    read_zero, read_two, pairSynergyb, hdup, MI_labF_rA]
  field_simp

/-! ## 5. The co-information identity accounts for both signs -/

theorem readMI_rA_rB : readMI rA rB = 0 := by
  rw [readMI, MI_eq, pr_eq_pair, H_rA, H_rB, H_pair_rA_rB, log4_eq]
  ring

theorem readMI_rA_rA : readMI rA rA = Real.log 2 := by
  rw [readMI, MI_eq_label_entropy_of_determines rA rA (fun x y h => h), H_rA]

/-- The synergy row is driven by *conditional* dependence: the two readings are
unconditionally independent, yet inside a parity class each determines the
other. -/
theorem condMI_labX_rA_rB : condMI labX rA rB = Real.log 2 := by
  have hid := pairSynergy_eq_condMI_sub_readMI labX rA rB
  have hps : pairSynergy labX rA rB = Real.log 2 := by
    rw [pairSynergy, MI_labX_pair, MI_labX_rA, MI_labX_rB]
    ring
  rw [hps, readMI_rA_rB] at hid
  linarith

/-- The overlap row is driven by *unconditional* dependence: inside a label
class the duplicated dial is constant, so the conditional dependence vanishes
and the whole deficit is the shared channel. -/
theorem condMI_labF_rA_rA : condMI labF rA rA = 0 := by
  have hid := pairSynergy_eq_condMI_sub_readMI labF rA rA
  have hps : pairSynergy labF rA rA = -Real.log 2 := by
    rw [pairSynergy_eq_neg_of_refines labF rA rA id rfl, MI_labF_rA]
  rw [hps, readMI_rA_rA] at hid
  linarith

/-- **The mechanism, in one statement.**  The `+1` row has zero unconditional
dependence and one bit of conditional dependence; the `−1` row has one bit of
unconditional dependence and zero conditional dependence.  Both are instances of
`Δ = I(f;g|L) − I(f;g)`. -/
theorem coinformation_explains_rows :
    readMI rA rB = 0 ∧ condMI labX rA rB = Real.log 2 ∧
    pairSynergy labX rA rB = condMI labX rA rB - readMI rA rB ∧
    readMI rA rA = Real.log 2 ∧ condMI labF rA rA = 0 ∧
    pairSynergy labF rA rA = condMI labF rA rA - readMI rA rA :=
  ⟨readMI_rA_rB, condMI_labX_rA_rB, pairSynergy_eq_condMI_sub_readMI labX rA rB,
    readMI_rA_rA, condMI_labF_rA_rA, pairSynergy_eq_condMI_sub_readMI labF rA rA⟩

/-! ## 6. Both bounds of part V are attained -/

/-- The overlap row saturates **both** ceilings of part V simultaneously: the
deficit equals the smaller marginal and equals the shared channel. -/
theorem overlap_row_saturates_bounds :
    overlap labF rA rA = min (MI labF rA) (MI labF rA) ∧
    overlap labF rA rA = readMI rA rA := by
  have h : overlap labF rA rA = MI labF rA := overlap_self labF rA
  exact ⟨by rw [h, min_self], by rw [h, MI_labF_rA, readMI_rA_rA]⟩

/-! ## 7. The verdict -/

/-- **SYNERGY-AND-OVERLAP.**  A single three-dial battery on four individuals
realises all three rows of the paper-91 table at their extreme values:

* against the parity label the pair `{0,1}` is strictly super-additive (`+1`);
* against the first-bit label the same pair is exactly additive (`0`);
* against the first-bit label the pair `{0,2}` — the duplicated dial — is
  strictly sub-additive (`−1`).

So no inequality `Δ ≥ 0` (additivity as a lower bound, i.e. comonotonicity of
capacity) and no inequality `Δ ≤ 0` (sub-additive bookkeeping) can hold for
two-dial batteries, and additivity itself is not a law but a coincidence: it
occurs here on one pair of labels and fails on both neighbours of that pair. -/
theorem battery_space_neither_additive_nor_comonotone :
    0 < synergy qdial labX {0, 1} ∧
    synergy qdial labF {0, 1} = 0 ∧
    synergy qdial labF {0, 2} < 0 ∧
    synergy qdial labX {0, 1} = Hb labX ∧
    synergy qdial labF {0, 2} = -Hb labX := by
  refine ⟨?_, synergy_row_zero, ?_, ?_, ?_⟩
  · rw [synergy_row_pos]; norm_num
  · rw [synergy_row_neg]; norm_num
  · rw [synergy_row_pos, Hb_labX]
  · rw [synergy_row_neg, Hb_labX]

end OverlapWitness

end BatterySynergy