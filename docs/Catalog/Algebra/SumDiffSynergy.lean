/-
# THE-SUM-DIFFERENCE-SPLIT, part III: sharpness, synergy, and the exact boundary

Cycle 2 of the round-29 loop.  Part II proved `0 ≤ I(s,d) - I(N) ≤ min(H(T), …)` and refuted
the reconstruction hypothesis with an exact one-bit witness.  Three questions were left open
by that cycle, and all three are settled here.

**Q1 — is the boundary condition of part II also necessary?**  `hintValue = 0` was proved for
product-measurable labels.  *No*: `SumDiffSynergy.hint_zero_not_product_measurable` exhibits a
battery with hint value `0` whose labels are not a function of the product residue.  The
correct characterisation is the conditional-entropy identity
`SumDiffSynergy.hintValue_eq_zero_iff`: the hint value vanishes **iff** the labels are
conditionally independent of the factor-residue pair given the product residue — the exact
COND-RANK statement, with no measurability hypothesis.

**Q2 — is the label-entropy ceiling attained?**  *Yes, exactly.*
`SumDiffSynergy.hintValue_eq_label_entropy_of_const_product` says that whenever the factor
residues pin the label while the product residue is constant, the hint value equals the full
label entropy; `SumDiffSynergy.CeilingWitness` realises this modulo `5` on the product fibre
`pq = 1` with a two-bit hint value.  So the round-29 reading of `+0.5189` bits sits strictly
inside a range whose top end is attainable, and the `152%` share of the product row is not
even close to the structural maximum (which is `+∞%`, the product row being `0`).

**Q3 — where does the `3.9% / 3.9% / 152%` pattern come from?**  From genuine synergy, and
that too is attainable exactly: `SumDiffSynergy.synergy_witness` is a battery modulo `5` on
which the sum view reads **exactly `0`** bits, the gap view reads **exactly `0`** bits, and the
joint residue view reads **exactly `1`** bit.  Two dials that individually see nothing jointly
see everything.  The general bound `SumDiffSynergy.neg_min_le_residueSynergy` shows the
opposite (redundant) direction is limited: the synergy of the split is never below
`-min(I(s), I(d))`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1, cycle 2): (i) the vanishing of the hint value is *not* equivalent to
  product-measurability; (ii) the label-entropy ceiling of part II is attained; (iii) the
  near-zero sum and gap rows of the round-29 table are compatible with a maximal joint row,
  so the observed pattern needs no dependence assumption at all.
Experiment (Stage 2, cycle 2): independent recomputation (see `ComputationalEvidence.md`).
  Ceiling witness `P = (1,2,3,4)`, `Q = (1,3,2,4)` mod `5`, labels `0,1,2,3`: reads
  `sum 1.5000 / gap 1.5000 / prod 0.0000 / joint 2.0000`, hint `+2.0000 = H(T)`.
  Synergy witness `P = (0,2,3,0)`, `Q = (0,3,3,1)` mod `5`, labels `0,1,1,0`: reads
  `sum 0.0000 / gap 0.0000 / prod 1.0000 / joint 1.0000`.
  Degenerate witness `P = Q = (0,0)`, labels `0,1`: every row reads `0.0000` while
  `H(T) = 1`, and the labels are not product-measurable.
Analysis (Stage 3, cycle 2): the three witnesses separate three distinct mechanisms that the
  round-29 table conflates — *release* (hint value `> 0`), *synergy* (joint `>` sum `+` gap)
  and *blindness* (all rows `0`).  The ceiling witness has release `=` label entropy and also
  large single rows; the synergy witness has maximal synergy and zero release.  Release and
  synergy are therefore independent coordinates of a routing table, which is why a single
  number like `+0.5189` cannot be read as "the amount of structure" in a battery.
Critique (Stage 4, cycle 2): every reading below is an exact rational number of bits, obtained
  from fibre counts through `TraceBattery.H_eq_log_sub_log_of_uniform`; nothing is estimated
  and no `native_decide` is used.  The witnesses are small (2 and 4 samples) — deliberately,
  since their role is to *separate* hypotheses, not to model a battery.  A residual weakness:
  `hintValue_eq_zero_iff` characterises the boundary in terms of conditional entropies rather
  than an intrinsic condition on `(P, Q, L)`; finding such an intrinsic condition is
  conjecture C1 of `FUTURE_DIRECTIONS.md`.
-/
import Mathlib
import Algebra.SumDiffHintValue
import MachineLearning.BatterySynergy.Capacity

namespace SumDiffSynergy

open TraceBattery BatterySynergy SumDiffSplit

/-! ## 1. A reusable exact-entropy computation for small populations -/

/-- The entropy of a statistic on `Fin (n+1)` all of whose fibres have size `k`. -/
theorem H_eq_of_uniform_counts {n : ℕ} {α : Type*} (f : Fin (n + 1) → α) (k : ℕ) (hk : 0 < k)
    (hc : ∀ x, cnt f (f x) = k) :
    H f = Real.log ((n : ℝ) + 1) - Real.log (k : ℝ) := by
  have h : ∀ a ∈ img f, cnt f a = k := by
    intro a ha
    obtain ⟨x, rfl⟩ := mem_img.1 ha
    exact hc x
  have hcard := H_eq_log_sub_log_of_uniform f k hk h
  rw [Fintype.card_fin] at hcard
  rw [hcard]
  push_cast
  ring_nf

/-- Fibre counts on `Fin n`, in computable form. -/
theorem cnt_eq_filter_card {n : ℕ} {α : Type*} [DecidableEq α] (f : Fin n → α) (a : α) :
    cnt f a = (Finset.univ.filter fun x => f x = a).card := by
  rw [cnt, fib_eq_filter]

theorem log_four : Real.log 4 = 2 * Real.log 2 := by
  rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow]
  push_cast; ring

/-! ## 2. The exact boundary: a conditional-entropy identity, not measurability -/

section Boundary

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R] [Invertible (2 : R)]

omit [Invertible (2 : R)] in
/-- **The exact boundary of the refuted hypothesis.**  The hint value vanishes precisely when
the factor-residue pair releases no conditional entropy of the labels beyond the product
residue.  No measurability assumption appears: this is an identity, and it is the statement
that COND-RANK's conditioning-capacity reading measures. -/
theorem hintValue_eq_zero_iff (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L P Q = 0 ↔ condH L (productView P Q) = condH L (residueView P Q) := by
  rw [hintValue_eq_condH_release, div_eq_zero_iff]
  have hlog : Real.log 2 ≠ 0 := ne_of_gt log_two_pos
  constructor
  · rintro (h | h)
    · linarith [sub_eq_zero.mp h]
    · exact absurd h hlog
  · intro h
    exact Or.inl (by rw [h, sub_self])

end Boundary

/-! ## 3. Q1: vanishing hint value does **not** force product-measurable labels -/

namespace Degenerate

/-- A two-sample battery whose factor residues are constant while its labels are not. -/
def P : Fin 2 → ZMod 5 := ![0, 0]

def Q : Fin 2 → ZMod 5 := ![0, 0]

def L : Fin 2 → Fin 2 := ![0, 1]

theorem residue_const (x y : Fin 2) : residueView P Q x = residueView P Q y := by
  fin_cases x <;> fin_cases y <;> decide

theorem product_const (x y : Fin 2) : productView P Q x = productView P Q y := by
  fin_cases x <;> fin_cases y <;> decide

theorem hint_zero : hintValue L P Q = 0 := by
  rw [hintValue, MIb, MIb, MI_eq_zero_of_const L _ residue_const,
    MI_eq_zero_of_const L _ product_const]
  norm_num

/-- The labels are *not* a function of the product residue. -/
theorem not_product_measurable :
    ¬ ∀ x y, productView P Q x = productView P Q y → L x = L y := by
  intro h
  have := h 0 1 (product_const 0 1)
  simp [L] at this

end Degenerate

/-- **Q1 answered: the boundary condition of part II is sufficient but not necessary.**  There
is a battery with zero hint value whose labels are not product-measurable — the vanishing is a
conditional-independence statement (`hintValue_eq_zero_iff`), not a measurability statement. -/
theorem hint_zero_not_product_measurable :
    ∃ (L : Fin 2 → Fin 2) (P Q : Fin 2 → ZMod 5),
      hintValue L P Q = 0 ∧ ¬ ∀ x y, productView P Q x = productView P Q y → L x = L y :=
  ⟨Degenerate.L, Degenerate.P, Degenerate.Q, Degenerate.hint_zero,
    Degenerate.not_product_measurable⟩

/-! ## 4. Q2: the label-entropy ceiling is attained -/

section Ceiling

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*} {R : Type*} [CommRing R]
  [Invertible (2 : R)]

omit [Invertible (2 : R)] in
/-- **Sharpness of the label-entropy ceiling.**  If the factor residues pin the label while
the product residue is constant, the entire label entropy is hint value: the hint releases
everything the hint-free channel cannot see. -/
theorem hintValue_eq_label_entropy_of_const_product (L : Ω → Λ) (P Q : Ω → R)
    (hdet : ∀ x y, residueView P Q x = residueView P Q y → L x = L y)
    (hconst : ∀ x y, productView P Q x = productView P Q y) :
    hintValue L P Q = Hb L := by
  rw [hintValue, MIb_eq_label_entropy_of_determines L _ hdet, MIb,
    MI_eq_zero_of_const L _ hconst]
  norm_num

end Ceiling

namespace CeilingWitness

/-- Four samples on the product fibre `pq = 1` modulo `5`: `(1,1), (2,3), (3,2), (4,4)`. -/
def P : Fin 4 → ZMod 5 := ![1, 2, 3, 4]

def Q : Fin 4 → ZMod 5 := ![1, 3, 2, 4]

/-- Four distinct labels, so the label entropy is exactly two bits. -/
def L : Fin 4 → Fin 4 := ![0, 1, 2, 3]

theorem product_const (x y : Fin 4) : productView P Q x = productView P Q y := by
  fin_cases x <;> fin_cases y <;> decide

theorem residue_determines (x y : Fin 4) :
    residueView P Q x = residueView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

theorem cnt_L (x : Fin 4) : cnt L (L x) = 1 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem Hb_L : Hb L = 2 := by
  have h := H_eq_of_uniform_counts L 1 (by norm_num) cnt_L
  rw [Hb]
  norm_num at h
  rw [h, log_four]
  field_simp

/-- **The ceiling is attained: a two-bit hint value.**  The hint-free product channel reads
`0` bits on this battery and the factor-residue hint reads the full label entropy. -/
theorem hintValue_eq_two : hintValue L P Q = 2 := by
  rw [hintValue_eq_label_entropy_of_const_product L P Q residue_determines product_const, Hb_L]

end CeilingWitness

/-- **Q2 answered: the label-entropy ceiling of part II is sharp**, and the hint value can
exceed one bit. -/
theorem exists_hintValue_eq_label_entropy :
    ∃ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5), hintValue L P Q = Hb L ∧ hintValue L P Q = 2 :=
  ⟨CeilingWitness.L, CeilingWitness.P, CeilingWitness.Q,
    by rw [CeilingWitness.hintValue_eq_two, CeilingWitness.Hb_L],
    CeilingWitness.hintValue_eq_two⟩

/-! ## 5. Q3: synergy of the sum/gap split -/

section Synergy

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R]

/-- The **synergy of the sum/gap split**: how much the joint residue view reads beyond the
additive prediction from its two coordinates. -/
noncomputable def residueSynergy (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  MIb L (residueView P Q) - MIb L (sumView P Q) - MIb L (gapView P Q)

/-- **Redundancy is bounded.**  The split can be redundant, but never by more than the smaller
of its two coordinate readings: the joint row always dominates each single row. -/
theorem neg_min_le_residueSynergy (L : Ω → Λ) (P Q : Ω → R) :
    -min (MIb L (sumView P Q)) (MIb L (gapView P Q)) ≤ residueSynergy L P Q := by
  rcases le_total (MIb L (sumView P Q)) (MIb L (gapView P Q)) with h | h
  · rw [min_eq_left h]
    have := gap_le_residue L P Q
    simp only [residueSynergy]
    linarith
  · rw [min_eq_right h]
    have := sum_le_residue L P Q
    simp only [residueSynergy]
    linarith

/-- The synergy of the split is at most the label entropy. -/
theorem residueSynergy_le_label_entropy (L : Ω → Λ) (P Q : Ω → R) :
    residueSynergy L P Q ≤ Hb L := by
  have h1 : MIb L (residueView P Q) ≤ Hb L := MIb_le_label_entropy L _
  have h2 : 0 ≤ MIb L (sumView P Q) := MIb_nonneg L _
  have h3 : 0 ≤ MIb L (gapView P Q) := MIb_nonneg L _
  simp only [residueSynergy]
  linarith

end Synergy

namespace SynergyWitness

/-- Four samples modulo `5` whose sum/gap coordinates are `(0,0), (0,1), (1,0), (1,1)`. -/
def P : Fin 4 → ZMod 5 := ![0, 2, 3, 0]

def Q : Fin 4 → ZMod 5 := ![0, 3, 3, 1]

/-- The labels are the parity of `s + d`: a perfect `XOR` of the two coordinates. -/
def L : Fin 4 → Fin 2 := ![0, 1, 1, 0]

theorem cnt_L (x : Fin 4) : cnt L (L x) = 2 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_sum (x : Fin 4) : cnt (sumView P Q) (sumView P Q x) = 2 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_gap (x : Fin 4) : cnt (gapView P Q) (gapView P Q x) = 2 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_pr_sum (x : Fin 4) : cnt (pr L (sumView P Q)) (pr L (sumView P Q) x) = 1 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_pr_gap (x : Fin 4) : cnt (pr L (gapView P Q)) (pr L (gapView P Q) x) = 1 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem residue_determines (x y : Fin 4) :
    residueView P Q x = residueView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

theorem H_L : H L = Real.log 4 - Real.log 2 := by
  have h := H_eq_of_uniform_counts L 2 (by norm_num) cnt_L
  norm_num at h
  rw [h]

theorem Hb_L : Hb L = 1 := by
  rw [Hb, H_L, log_four]
  field_simp
  norm_num

/-- **The sum view alone reads exactly zero bits.** -/
theorem MIb_sum : MIb L (sumView P Q) = 0 := by
  have hf : H (sumView P Q) = Real.log 4 - Real.log 2 := by
    have h := H_eq_of_uniform_counts (sumView P Q) 2 (by norm_num) cnt_sum
    norm_num at h
    rw [h]
  have hpr : H (pr L (sumView P Q)) = Real.log 4 := by
    have h := H_eq_of_uniform_counts (pr L (sumView P Q)) 1 (by norm_num) cnt_pr_sum
    norm_num at h
    rw [h]
  have : MI L (sumView P Q) = 0 := by rw [MI_eq, H_L, hf, hpr, log_four]; ring
  rw [MIb, this, zero_div]

/-- **The gap view alone reads exactly zero bits.** -/
theorem MIb_gap : MIb L (gapView P Q) = 0 := by
  have hf : H (gapView P Q) = Real.log 4 - Real.log 2 := by
    have h := H_eq_of_uniform_counts (gapView P Q) 2 (by norm_num) cnt_gap
    norm_num at h
    rw [h]
  have hpr : H (pr L (gapView P Q)) = Real.log 4 := by
    have h := H_eq_of_uniform_counts (pr L (gapView P Q)) 1 (by norm_num) cnt_pr_gap
    norm_num at h
    rw [h]
  have : MI L (gapView P Q) = 0 := by rw [MI_eq, H_L, hf, hpr, log_four]; ring
  rw [MIb, this, zero_div]

/-- **The joint residue view reads exactly one bit.** -/
theorem MIb_residue : MIb L (residueView P Q) = 1 := by
  rw [MIb_eq_label_entropy_of_determines L _ residue_determines, Hb_L]

theorem synergy_eq_one : residueSynergy L P Q = 1 := by
  rw [residueSynergy, MIb_residue, MIb_sum, MIb_gap]
  ring

end SynergyWitness

/-- **Q3 answered: the `3.9% / 3.9% / 152%` pattern is exactly realisable.**  There is a
battery modulo `5` whose sum view and gap view each read exactly `0` bits while the joint
residue view reads exactly `1` bit — the two coordinates of the factor-residue hint are
individually blind and jointly complete.  The synergy of the split attains its label-entropy
ceiling. -/
theorem synergy_witness :
    ∃ (L : Fin 4 → Fin 2) (P Q : Fin 4 → ZMod 5),
      MIb L (sumView P Q) = 0 ∧ MIb L (gapView P Q) = 0 ∧
      MIb L (residueView P Q) = 1 ∧ residueSynergy L P Q = Hb L :=
  ⟨SynergyWitness.L, SynergyWitness.P, SynergyWitness.Q, SynergyWitness.MIb_sum,
    SynergyWitness.MIb_gap, SynergyWitness.MIb_residue,
    by rw [SynergyWitness.synergy_eq_one, SynergyWitness.Hb_L]⟩

/-- **Release and synergy are independent coordinates of a routing table.**  The synergy
witness has maximal synergy and *zero* hint value, while the ceiling witness has maximal hint
value; so no single scalar summarises a factor-residue routing table. -/
theorem synergy_and_release_independent :
    (∃ (L : Fin 4 → Fin 2) (P Q : Fin 4 → ZMod 5),
        residueSynergy L P Q = Hb L ∧ hintValue L P Q = 0) ∧
    (∃ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5), hintValue L P Q = Hb L) := by
  constructor
  · refine ⟨SynergyWitness.L, SynergyWitness.P, SynergyWitness.Q, ?_, ?_⟩
    · rw [SynergyWitness.synergy_eq_one, SynergyWitness.Hb_L]
    · have hdet := SynergyWitness.residue_determines
      have hprod : ∀ x y, productView SynergyWitness.P SynergyWitness.Q x
          = productView SynergyWitness.P SynergyWitness.Q y → SynergyWitness.L x
            = SynergyWitness.L y := by
        intro x y
        fin_cases x <;> fin_cases y <;> decide
      exact hintValue_eq_zero_of_product_measurable SynergyWitness.L _ _ hprod
  · exact ⟨CeilingWitness.L, CeilingWitness.P, CeilingWitness.Q,
      by rw [CeilingWitness.hintValue_eq_two, CeilingWitness.Hb_L]⟩

end SumDiffSynergy