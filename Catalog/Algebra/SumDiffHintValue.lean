/-
# THE-SUM-DIFFERENCE-SPLIT, part II: the factor-residue hint value

Round-29 experiment #1 (paper 99) reads a battery of labels through four views of a factor
pair `(p, q)` modulo `m = 31` and reports

| view                        | bits   | share |
|-----------------------------|--------|-------|
| product view (hint-free)    | 1.0012 | 100%  |
| sum view alone `s = p+q`    | 0.0391 | 3.9%  |
| gap view alone `d = q-p`    | 0.0387 | 3.9%  |
| joint residue view `(s,d)`  | 1.5201 | 152%  |
| **hint value** `I(s,d)-I(N)`| +0.5189|       |

refuting the pre-stated reconstruction hypothesis `I(s,d) = I(N)` *upward*.

This file proves that every structural feature of that table is a theorem, using the
catalog's finitary information calculus (`TraceBattery.H`, `BatterySynergy.MIb`) and the
algebra of `Algebra.SumDiffSplit`:

* `SumDiffSplit.product_le_residue` — **the hint value is never negative**: the product view
  factors through the joint residue view (`prodOf_sd`), so data processing forbids the joint
  row from falling below the product row.  The pre-stated hypothesis can only fail upward —
  which is exactly the direction observed.
* `SumDiffSplit.sum_le_residue`, `gap_le_residue` — the two single-coordinate rows are also
  dominated by the joint row: `3.9% ≤ 152%` is forced.
* `SumDiffSplit.residue_eq_pair` — the joint residue view carries *exactly* the information of
  the factor pair `(p mod m, q mod m)`: the `10`-bit hint of the experiment.
* `SumDiffSplit.hintValue_symm` — `p ↔ q` symmetry of the hint value, the invariance the
  experiment verified numerically.
* `SumDiffSplit.hintValue_eq_condH_release` — the hint value *is* the conditional-entropy
  released by the hint: `I(s,d) - I(N) = (H(T|N) - H(T|s,d))/log 2`.  This is the bridge to
  the COND-RANK conditioning-capacity reading.
* `SumDiffSplit.hintValue_eq_zero_of_product_measurable` — **the exact boundary**: if the
  labels are a function of the product residue, the pre-stated hypothesis is *true*
  (hint value `0`).  So round 29 did not refute a theorem; it refuted an extrapolation from
  product-measurable labels to arbitrary ones.
* `SumDiffSplit.hintValue_le_label_entropy`, `hintValue_le_sum_plus_gap_entropy`,
  `hintValue_le_logb_card_pairs` — three ceilings: the label entropy `H(T)`, the
  sum-row-plus-gap-entropy budget, and the `log₂ 961 < 10`-bit hint budget.
* `SumDiffSplit.witness_hintValue_eq_one` and
  `SumDiffSplit.reconstruction_hypothesis_false` — **THE-HINT-VALUE-IS-REAL**, formally: an
  explicit four-sample battery mod `5` on which the product view reads exactly `0` bits while
  the joint residue view reads exactly `1` bit.  The hypothesis `I(s,d) = I(N)` is therefore
  false as a universal statement, with an exactly computed `1`-bit gap — no floating point.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the `+0.5189` bits are not noise and not an artefact of `m = 31`; the
  correct general statement is `0 ≤ I(s,d) - I(N) ≤ min(H(T), I(s) + H(d), log₂ m²)`, with
  equality on the left exactly for product-measurable labels.
Experiment (Stage 2): recomputed the routing table independently (see
  `ComputationalEvidence.md`).  Three batteries mod `31`: labels built from `(s,d)` give
  `prod 0.0749 / sum 1.3260 / gap 0.3304 / joint 1.9984`, hint `+1.9235`; labels built from
  `N` give `prod 1.0000 / joint 1.0000`, hint exactly `0`; random labels on `120` samples give
  hint `+0.7768`.  `2000` randomised trials over `m ∈ {5,7,11,31}` produced **no** violation of
  `joint ≥ max(prod, sum, gap)` and **no** discrepancy between the joint residue view and the
  factor-pair view.  The four-sample witness mod `5` reads `prod 0.0`, `sum 0.5`, `gap 0.5`,
  `joint 1.0` — the `1`-bit gap formalised below.
Analysis (Stage 3): the observed `152%` share is not a pathology of estimation: it is the
  generic position.  The product row equals the joint row only on the measure-zero set of
  product-measurable label assignments; everywhere else the quadratic collapse
  `(s,d) ↦ (s²-d²)/4` destroys label information that the hint restores.
Critique (Stage 4): the plug-in reading is a biased estimator, so a *small* positive hint
  value is not by itself evidence of structure — nonnegativity is a theorem, not a
  measurement.  What the theorems below license is the *ordering* of the rows and the
  *boundary* (zero iff product-measurable in the determinstic direction); the numerical size
  `+0.5189` remains an empirical quantity.  Accordingly the flagged joint-battery anomaly
  (`0.1353` vs paper 91's `2.1314`) is untouched here: no theorem in this file depends on it,
  and `residue_eq_pair` shows that any two faithful encodings of the same residue pair must
  agree, so the discrepancy is a label-encoding issue and not an information-theoretic one.
-/
import Mathlib
import Algebra.SumDiffSplit
import MachineLearning.BatterySynergy.MutualInformation

namespace SumDiffSplit

open TraceBattery BatterySynergy

/-! ## 1. The four views of a factor-residue battery -/

section Views

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R]

/-- The **sum view** of a factor-residue battery: `s = p + q`. -/
def sumView (P Q : Ω → R) : Ω → R := fun x => P x + Q x

/-- The **gap view**: `d = q - p`. -/
def gapView (P Q : Ω → R) : Ω → R := fun x => Q x - P x

/-- The **joint residue view** `(s, d)`. -/
def residueView (P Q : Ω → R) : Ω → R × R := fun x => sd (P x) (Q x)

/-- The **product view**, i.e. the hint-free channel `N = p q mod m`. -/
def productView (P Q : Ω → R) : Ω → R := fun x => P x * Q x

/-- The **factor-pair view** `(p, q)`: the 10-bit hint itself. -/
def pairView (P Q : Ω → R) : Ω → R × R := fun x => (P x, Q x)

omit [Fintype Ω] in
theorem residueView_eq_pair_of_views (P Q : Ω → R) :
    residueView P Q = fun x => (sumView P Q x, gapView P Q x) := rfl

/-- The **factor-residue hint value**: what the joint residue view adds over the product
view, in bits. -/
noncomputable def hintValue (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  MIb L (residueView P Q) - MIb L (productView P Q)

/-! ## 2. The routing table is a partial order, not a coincidence -/

omit [Fintype Ω] in
/-- The sum view is a coarsening of the joint residue view. -/
theorem sumView_comp (P Q : Ω → R) : sumView P Q = Prod.fst ∘ residueView P Q := rfl

omit [Fintype Ω] in
/-- The gap view is a coarsening of the joint residue view. -/
theorem gapView_comp (P Q : Ω → R) : gapView P Q = Prod.snd ∘ residueView P Q := rfl

/-- **The sum row is dominated by the joint row.** -/
theorem sum_le_residue (L : Ω → Λ) (P Q : Ω → R) :
    MIb L (sumView P Q) ≤ MIb L (residueView P Q) := by
  rw [sumView_comp]
  exact MIb_comp_le L (residueView P Q) Prod.fst

/-- **The gap row is dominated by the joint row.** -/
theorem gap_le_residue (L : Ω → Λ) (P Q : Ω → R) :
    MIb L (gapView P Q) ≤ MIb L (residueView P Q) := by
  rw [gapView_comp]
  exact MIb_comp_le L (residueView P Q) Prod.snd

variable [Invertible (2 : R)]

omit [Fintype Ω] in
/-- **The product view factors through the joint residue view**, by `4pq = s² - d²`. -/
theorem productView_comp (P Q : Ω → R) :
    productView P Q = prodOf ∘ residueView P Q := by
  funext x
  simpa [productView, residueView] using (prodOf_sd (P x) (Q x)).symm

/-- **The product row is dominated by the joint row.**  Data processing plus the recovery
identity: reading `N` is a post-processing of reading `(s, d)`, so the pre-stated
reconstruction hypothesis can fail only in the direction round 29 observed. -/
theorem product_le_residue (L : Ω → Λ) (P Q : Ω → R) :
    MIb L (productView P Q) ≤ MIb L (residueView P Q) := by
  rw [productView_comp]
  exact MIb_comp_le L (residueView P Q) prodOf

/-- **The hint value is never negative.** -/
theorem hintValue_nonneg (L : Ω → Λ) (P Q : Ω → R) : 0 ≤ hintValue L P Q := by
  have := product_le_residue L P Q
  simp only [hintValue]
  linarith

/-! ## 3. The joint residue view *is* the factor-pair hint -/

omit [Fintype Ω] in
/-- The joint residue view and the factor-pair view induce the same partition of the
population: over a ring with `1/2`, `(p,q) ↦ (p+q, q-p)` is a bijection. -/
theorem residueView_same_fibres (P Q : Ω → R) (x y : Ω) :
    residueView P Q x = residueView P Q y ↔ pairView P Q x = pairView P Q y := by
  constructor
  · intro h
    have h' : (fun v : R × R => sd v.1 v.2) (P x, Q x)
        = (fun v : R × R => sd v.1 v.2) (P y, Q y) := h
    simpa [pairView] using sd_injective h'
  · intro h
    have h1 : P x = P y := congrArg Prod.fst h
    have h2 : Q x = Q y := congrArg Prod.snd h
    simp [residueView, sd, h1, h2]

/-- **The `(s,d)` reading is exactly the `(p,q)` reading.**  Nothing is gained or lost by
presenting the hint in sum/difference coordinates, so the `152%` row is literally the
capacity of the 10-bit factor-residue hint. -/
theorem residue_eq_pair [Nonempty Ω] (L : Ω → Λ) (P Q : Ω → R) :
    MIb L (residueView P Q) = MIb L (pairView P Q) :=
  MIb_eq_of_same_fibers L _ _ (residueView_same_fibres P Q)

/-! ## 4. `p ↔ q` symmetry -/

omit [Fintype Ω] [Invertible (2:R)] in
theorem productView_symm (P Q : Ω → R) : productView Q P = productView P Q := by
  funext x; exact mul_comm _ _

omit [Fintype Ω] [Invertible (2:R)] in
theorem residueView_swap_same_fibres (P Q : Ω → R) (x y : Ω) :
    residueView Q P x = residueView Q P y ↔ residueView P Q x = residueView P Q y := by
  simp only [residueView, sd, Prod.mk.injEq]
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨by linear_combination h1, by linear_combination -h2⟩
  · rintro ⟨h1, h2⟩
    exact ⟨by linear_combination h1, by linear_combination -h2⟩

omit [Invertible (2:R)] in
/-- **The hint value is `p ↔ q` symmetric**, as verified numerically in round 29. -/
theorem hintValue_symm [Nonempty Ω] (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L Q P = hintValue L P Q := by
  simp only [hintValue, productView_symm]
  rw [MIb_eq_of_same_fibers L (residueView Q P) (residueView P Q)
    (residueView_swap_same_fibres P Q)]

/-! ## 5. The hint value as released conditional entropy -/

omit [Invertible (2:R)] in
/-- **The bridge to COND-RANK.**  The hint value equals the conditional entropy of the labels
released by the hint: `I(T ; s,d) - I(T ; N) = (H(T | N) - H(T | s,d)) / log 2`. -/
theorem hintValue_eq_condH_release (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L P Q =
      (condH L (productView P Q) - condH L (residueView P Q)) / Real.log 2 := by
  simp only [hintValue, MIb, MI]
  field_simp
  ring

/-! ## 6. The boundary: when the pre-stated hypothesis is true -/

/-- **Exact boundary of the refuted hypothesis.**  If the labels are a function of the
product residue, the joint residue view adds nothing and `I(s,d) = I(N)` holds on the nose.
Round 29 therefore refuted an extrapolation, not a theorem: the hypothesis is precisely the
assumption that the battery labels are product-measurable. -/
theorem hintValue_eq_zero_of_product_measurable [Nonempty Ω] (L : Ω → Λ) (P Q : Ω → R)
    (h : ∀ x y, productView P Q x = productView P Q y → L x = L y) :
    hintValue L P Q = 0 := by
  have hres : ∀ x y, residueView P Q x = residueView P Q y → L x = L y := by
    intro x y hxy
    exact h x y (prod_eq_of_sd_eq hxy)
  rw [hintValue, MIb_eq_label_entropy_of_determines L _ hres,
    MIb_eq_label_entropy_of_determines L _ h, sub_self]

/-! ## 7. Three ceilings for the hint value -/

omit [Invertible (2:R)] in
/-- **Label-entropy ceiling.**  The hint value cannot exceed the entropy of the labels: the
ceiling `H(T)` of papers 80–94 caps the bridge as well as the channel. -/
theorem hintValue_le_label_entropy (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L P Q ≤ Hb L := by
  have h1 : MIb L (residueView P Q) ≤ Hb L := MIb_le_label_entropy L _
  have h2 : 0 ≤ MIb L (productView P Q) := MIb_nonneg L _
  simp only [hintValue]
  linarith

omit [Invertible (2:R)] in
/-- **Split ceiling.**  The joint row is at most the sum row plus the entropy of the gap
coordinate: the gap dial can only contribute its own entropy on top of the sum dial. -/
theorem residue_le_sum_add_gap_entropy (L : Ω → Λ) (P Q : Ω → R) :
    MIb L (residueView P Q) ≤ MIb L (sumView P Q) + Hb (gapView P Q) := by
  have h := MI_pair_le_add_H L (sumView P Q) (gapView P Q)
  rw [← residueView_eq_pair_of_views] at h
  rw [MIb, MIb, Hb, ← add_div]
  exact (div_le_div_iff_of_pos_right log_two_pos).mpr h

omit [Invertible (2:R)] in
/-- The hint value is bounded by the sum row plus the gap entropy. -/
theorem hintValue_le_sum_plus_gap_entropy (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L P Q ≤ MIb L (sumView P Q) + Hb (gapView P Q) := by
  have h1 := residue_le_sum_add_gap_entropy L P Q
  have h2 : 0 ≤ MIb L (productView P Q) := MIb_nonneg L _
  simp only [hintValue]
  linarith

end Views

/-! ## 8. The hint budget at the modulus of the experiment -/

section Budget

variable {Ω : Type*} [Fintype Ω] {Λ : Type*}

private theorem logb_two_le_of_le {c : ℕ} (hc : c ≤ 961) :
    Real.logb 2 (c : ℝ) ≤ Real.logb 2 (961 : ℝ) := by
  rcases Nat.eq_zero_or_pos c with rfl | hpos
  · simp only [Nat.cast_zero, Real.logb_zero]
    exact Real.logb_nonneg (by norm_num) (by norm_num)
  · have h0 : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hpos
    have hle : (c : ℝ) ≤ (961 : ℝ) := by exact_mod_cast hc
    exact Real.logb_le_logb_of_le (by norm_num) h0 hle

/-- **Hint-budget ceiling at `m = 31`.**  The hint value of any battery read through factor
residues mod `31` is at most `log₂ 961 < 10` bits: the `+0.5189` bits measured in round 29 are
about `5%` of the budget that revealing `p` and `q` mod `31` could conceivably release. -/
theorem hintValue_le_logb_card_pairs (L : Ω → Λ) (P Q : Ω → ZMod 31) :
    hintValue L P Q ≤ Real.logb 2 (961 : ℝ) := by
  have h1 : MIb L (residueView P Q) ≤ Hb (residueView P Q) := MIb_le_stat_entropy L _
  have h2 : Hb (residueView P Q) ≤ Real.logb 2 ((img (residueView P Q)).card : ℝ) :=
    Hb_le_logb_card_img _
  have h3 : (img (residueView P Q)).card ≤ 961 := by
    have := Finset.card_le_univ (img (residueView P Q))
    simpa [Finset.card_univ, ZMod] using this
  have h4 := logb_two_le_of_le h3
  have h5 : 0 ≤ MIb L (productView P Q) := MIb_nonneg L _
  simp only [hintValue]
  linarith

theorem hintValue_lt_ten (L : Ω → Λ) (P Q : Ω → ZMod 31) :
    hintValue L P Q < 10 := by
  have h := hintValue_le_logb_card_pairs L P Q
  have h2 : Real.logb 2 ((Fintype.card (ZMod 31 × ZMod 31) : ℕ) : ℝ) < 10 :=
    logb_card_sd_lt_ten
  rw [card_residue_pairs] at h2
  norm_num at h2
  linarith

end Budget

/-! ## 9. THE-HINT-VALUE-IS-REAL: an exact one-bit witness -/

namespace Witness

/-- A four-sample battery: first factor residues mod `5`. -/
def P : Fin 4 → ZMod 5 := ![1, 1, 2, 2]

/-- A four-sample battery: second factor residues mod `5`. -/
def Q : Fin 4 → ZMod 5 := ![1, 2, 3, 1]

/-- The battery labels: the factor pairs `(1,1), (1,2)` get label `0`, the pairs
`(2,3), (2,1)` get label `1`.  Both label classes see the *same* multiset of product
residues `{1, 2}`, so the product view is exactly independent of the label, while the four
residue pairs `(s,d) = (2,0), (3,1), (0,1), (3,4)` are distinct and pin the label. -/
def L : Fin 4 → Fin 2 := ![0, 0, 1, 1]

theorem card_pop : Fintype.card (Fin 4) = 4 := by simp

/-- Fibre counts of a statistic on `Fin 4`, in computable form. -/
theorem cnt_eq_filter_card {α : Type*} [DecidableEq α] (f : Fin 4 → α) (a : α) :
    cnt f a = (Finset.univ.filter fun x => f x = a).card := by
  rw [cnt, fib_eq_filter]

theorem cnt_L (x : Fin 4) : cnt L (L x) = 2 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_prod (x : Fin 4) : cnt (productView P Q) (productView P Q x) = 2 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

theorem cnt_pr (x : Fin 4) : cnt (pr L (productView P Q)) (pr L (productView P Q) x) = 1 := by
  rw [cnt_eq_filter_card]
  fin_cases x <;> decide

/-- The joint residue view pins the label on this battery. -/
theorem residue_determines (x y : Fin 4) :
    residueView P Q x = residueView P Q y → L x = L y := by
  fin_cases x <;> fin_cases y <;> decide

private theorem H_of_uniform {α : Type*} (f : Fin 4 → α) (k : ℕ) (hk : 0 < k)
    (hc : ∀ x : Fin 4, cnt f (f x) = k) :
    H f = Real.log 4 - Real.log (k : ℝ) := by
  have h : ∀ a ∈ img f, cnt f a = k := by
    intro a ha
    obtain ⟨x, rfl⟩ := mem_img.1 ha
    exact hc x
  have := H_eq_log_sub_log_of_uniform f k hk h
  rwa [card_pop] at this
  
theorem H_L : H L = Real.log 4 - Real.log 2 := by
  have := H_of_uniform L 2 (by norm_num) cnt_L
  simpa using this

/-- **The product view reads exactly zero bits on this battery.** -/
theorem MIb_product : MIb L (productView P Q) = 0 := by
  have hf : H (productView P Q) = Real.log 4 - Real.log 2 := by
    have := H_of_uniform (productView P Q) 2 (by norm_num) cnt_prod
    simpa using this
  have hpr : H (pr L (productView P Q)) = Real.log 4 := by
    have := H_of_uniform (pr L (productView P Q)) 1 (by norm_num) cnt_pr
    simpa using this
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow]
    push_cast; ring
  have : MI L (productView P Q) = 0 := by
    rw [MI_eq, H_L, hf, hpr, h4]; ring
  rw [MIb, this, zero_div]

/-- **The joint residue view reads exactly one bit on this battery.** -/
theorem MIb_residue : MIb L (residueView P Q) = 1 := by
  rw [MIb_eq_label_entropy_of_determines L _ residue_determines, Hb, H_L]
  have h4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow]
    push_cast; ring
  rw [h4]
  field_simp
  norm_num

end Witness

/-- **THE-HINT-VALUE-IS-REAL.**  On the explicit four-sample battery of `Witness`, the
factor-residue hint value is exactly one bit: the product view reads `0`, the joint residue
view reads `1`.  Nothing here is numerical: both readings are computed exactly. -/
theorem witness_hintValue_eq_one : hintValue Witness.L Witness.P Witness.Q = 1 := by
  rw [hintValue, Witness.MIb_residue, Witness.MIb_product, sub_zero]

/-- **The pre-stated reconstruction hypothesis is false.**  There is no universal identity
`I(labels ; (s,d)) = I(labels ; N)`: the witness battery separates the two readings by a full
bit.  Combined with `product_le_residue`, the exact statement that survives is the
*inequality* `I(N) ≤ I(s,d)`, with the boundary case characterised by
`hintValue_eq_zero_of_product_measurable`. -/
theorem reconstruction_hypothesis_false :
    ¬ ∀ (L : Fin 4 → Fin 2) (P Q : Fin 4 → ZMod 5),
        MIb L (residueView P Q) = MIb L (productView P Q) := by
  intro h
  have := h Witness.L Witness.P Witness.Q
  rw [Witness.MIb_residue, Witness.MIb_product] at this
  norm_num at this

/-- **The strict form of the routing table.**  There is a battery on which the joint residue
row is strictly above the product row, and the gap between them is positive — so the `152%`
share of round 29 is a structurally available reading, not an estimation artefact. -/
theorem exists_positive_hint_value :
    ∃ (L : Fin 4 → Fin 2) (P Q : Fin 4 → ZMod 5), 0 < hintValue L P Q :=
  ⟨Witness.L, Witness.P, Witness.Q, by rw [witness_hintValue_eq_one]; norm_num⟩

end SumDiffSplit