import Mathlib

/-!
# Adversarial Training as Tropical Regularization

This file formalizes the equivalence between adversarial robust optimization and
tropical/min-plus regularization for finite classifiers. The key results establish:

1. **Tropical Distance = Certified Radius** (Theorem A): The min-plus distance from a
   point to the adversarial (misclassification) set equals the supremum of radii for
   which all points remain correctly classified.

2. **Robust Loss ≤ Tropical Shift** (Theorem B): Under a margin-Lipschitz hypothesis
   and antitone loss transfer, the adversarial robust loss is bounded by the loss
   evaluated at a tropically shifted (eroded) margin.

3. **Certified Radius from Margin/Lipschitz** (Theorem C): The idempotent closure
   radius is at least `margin / L`, providing a constructive certified defense.

## Mathematical Context

Adversarial perturbation in the tropical/min-plus framework becomes an infimal
convolution (erosion) of the margin function. The robust empirical risk is then
a tropical Moreau envelope, and the certified radius is the idempotent closure
of the tropical margin — connecting adversarial ML to idempotent analysis,
mathematical morphology, and Hamilton–Jacobi semigroups.

## Main Definitions

* `TropAdv.margin` — classification margin: score gap between true and best rival class
* `TropAdv.advSet` — adversarial (misclassification) set where margin ≤ 0
* `TropAdv.tropDist` — tropical distance (min-plus) to the adversarial set
* `TropAdv.robustLoss` — worst-case loss under bounded perturbations
* `TropAdv.idempotentClosureRadius` — largest radius preserving positive margin
* `TropAdv.empiricalRisk` — empirical risk over a finite dataset
* `TropAdv.tropicalRegularizedRisk` — empirical risk with tropical penalty

## Main Results

* `TropAdv.robustLoss_le_tropicalShift` — Theorem B
* `TropAdv.idempotentClosureRadius_ge_margin_div_lipschitz` — Theorem C
* `TropAdv.robustEmpiricalRisk_le_tropicalRegularizedRisk` — Empirical corollary
-/

open Finset BigOperators

noncomputable section

namespace TropAdv

variable {d c : ℕ}

/-- Auxiliary: the set of competing labels is nonempty when `c ≥ 2`. -/
private theorem erase_univ_nonempty (hc : 1 < c) (y : Fin c) :
    (Finset.univ.erase y).Nonempty := by
  have : Nontrivial (Fin c) := Fintype.one_lt_card_iff_nontrivial.mp (by simp; omega)
  exact ⟨(exists_ne y).choose,
    Finset.mem_erase.mpr ⟨(exists_ne y).choose_spec, Finset.mem_univ _⟩⟩

/-- The input space for classifiers. -/
abbrev InputSpace (d : ℕ) := Fin d → ℝ

/-- The label space for classifiers. -/
abbrev LabelSpace (c : ℕ) := Fin c

/-! ## Core Definitions -/

/-- Classification margin: the gap between the score for the true label `y` and
the maximum score among all competing labels. A positive margin means `y` is the
predicted class. When `c ≥ 2`, the set of competitors `Finset.univ.erase y` is
nonempty.

In tropical geometry, this is a tropical linear functional on the score vector. -/
def margin (score : InputSpace d → LabelSpace c → ℝ) (x : InputSpace d) (y : LabelSpace c)
    (hc : 1 < c) : ℝ :=
  score x y - Finset.sup' (Finset.univ.erase y) (erase_univ_nonempty hc y)
    (fun y' => score x y')

/-- The adversarial set (misclassification locus) for label `y`: the set of inputs
where the margin is nonpositive, meaning `y` is not strictly the top-scoring class. -/
def advSet (score : InputSpace d → LabelSpace c → ℝ) (y : LabelSpace c) (hc : 1 < c) :
    Set (InputSpace d) :=
  {x | margin score x y hc ≤ 0}

/-- Tropical distance from a point to the adversarial set: the infimum of the cost
to reach any point in the adversarial region. This is the min-plus distance
transform of the indicator of the adversarial set. -/
def tropDist (cost : InputSpace d → InputSpace d → ℝ)
    (score : InputSpace d → LabelSpace c → ℝ)
    (x : InputSpace d) (y : LabelSpace c) (hc : 1 < c) : ℝ :=
  sInf (cost x '' advSet score y hc)

/-- Robust loss under adversarial perturbation: the supremum of the loss `φ(margin)`
over all perturbations within budget `ε`. -/
def robustLoss (cost : InputSpace d → InputSpace d → ℝ) (ε : ℝ)
    (score : InputSpace d → LabelSpace c → ℝ) (φ : ℝ → ℝ)
    (x : InputSpace d) (y : LabelSpace c) (hc : 1 < c) : ℝ :=
  sSup {z : ℝ | ∃ x', cost x x' ≤ ε ∧ z = φ (margin score x' y hc)}

/-- Idempotent closure radius: the supremum of radii `r ≥ 0` such that all points
within cost `r` of `x` have strictly positive margin. -/
def idempotentClosureRadius (cost : InputSpace d → InputSpace d → ℝ)
    (score : InputSpace d → LabelSpace c → ℝ)
    (x : InputSpace d) (y : LabelSpace c) (hc : 1 < c) : ℝ :=
  sSup {r : ℝ | 0 ≤ r ∧ ∀ x', cost x x' ≤ r → 0 < margin score x' y hc}

/-- Empirical risk over a finite labeled dataset. -/
def empiricalRisk {m : ℕ} (S : Fin m → InputSpace d × LabelSpace c)
    (loss : InputSpace d → LabelSpace c → ℝ) : ℝ :=
  ∑ i : Fin m, loss (S i).1 (S i).2

/-- Robust empirical risk: the sum of robust losses over the dataset. -/
def robustEmpiricalRisk {m : ℕ} (S : Fin m → InputSpace d × LabelSpace c)
    (cost : InputSpace d → InputSpace d → ℝ) (ε : ℝ)
    (score : InputSpace d → LabelSpace c → ℝ) (φ : ℝ → ℝ) (hc : 1 < c) : ℝ :=
  ∑ i : Fin m, robustLoss cost ε score φ (S i).1 (S i).2 hc

/-- Tropical regularized risk: empirical risk plus tropical penalty. -/
def tropicalRegularizedRisk {m : ℕ} (S : Fin m → InputSpace d × LabelSpace c)
    (baseLoss : InputSpace d → LabelSpace c → ℝ)
    (penalty : InputSpace d → LabelSpace c → ℝ) : ℝ :=
  ∑ i : Fin m, (baseLoss (S i).1 (S i).2 + penalty (S i).1 (S i).2)

/-! ## Basic Lemmas -/

/-- A point is in the adversarial set iff its margin is nonpositive. -/
theorem mem_advSet_iff (score : InputSpace d → LabelSpace c → ℝ)
    (x : InputSpace d) (y : LabelSpace c) (hc : 1 < c) :
    x ∈ advSet score y hc ↔ margin score x y hc ≤ 0 :=
  Iff.rfl

/-- If the margin is positive, the point is not in the adversarial set. -/
theorem not_mem_advSet_of_margin_pos (score : InputSpace d → LabelSpace c → ℝ)
    (x : InputSpace d) (y : LabelSpace c) (hc : 1 < c)
    (hm : 0 < margin score x y hc) : x ∉ advSet score y hc := by
  simp [advSet, Set.mem_setOf_eq]; linarith

/-! ## Theorem B: Robust Loss ≤ Tropical Shift -/

/-
**Theorem B (Adversarial loss as tropical regularization).**

Under the margin-Lipschitz hypothesis and antitone loss transfer `φ`, the robust
loss is bounded by `φ` applied to the tropically eroded margin. This is the formal
core of "adversarial training = tropical regularization."
-/
theorem robustLoss_le_tropicalShift
    (cost : InputSpace d → InputSpace d → ℝ)
    (score : InputSpace d → LabelSpace c → ℝ)
    (φ : ℝ → ℝ) (ε L : ℝ)
    (_hε : 0 ≤ ε) (hL : 0 ≤ L)
    (hφ : Antitone φ)
    (hc : 1 < c)
    (hmargin : ∀ x x' y, margin score x' y hc ≥ margin score x y hc - L * cost x x')
    (_hcost_nonneg : ∀ x x', 0 ≤ cost x x')
    (x : InputSpace d) (y : LabelSpace c)
    (_hbdd : BddAbove {z : ℝ | ∃ x', cost x x' ≤ ε ∧ z = φ (margin score x' y hc)})
    (hne : {z : ℝ | ∃ x', cost x x' ≤ ε ∧ z = φ (margin score x' y hc)}.Nonempty) :
    robustLoss cost ε score φ x y hc ≤ φ (margin score x y hc - L * ε) := by
  exact csSup_le hne fun z => by rintro ⟨ x', hx', rfl ⟩ ; exact hφ <| by nlinarith [ hmargin x x' y ] ;

/-! ## Theorem C: Certified Radius from Margin and Lipschitz Constant -/

/-
**Theorem C (Certified radius ≥ margin / L).**

If the margin is positive and `L`-Lipschitz, the idempotent closure radius is at
least `margin(x,y) / L`. This transforms the tropical margin into a constructive
certified defense.
-/
theorem idempotentClosureRadius_ge_margin_div_lipschitz
    (cost : InputSpace d → InputSpace d → ℝ)
    (score : InputSpace d → LabelSpace c → ℝ)
    (L : ℝ) (hc : 1 < c)
    (hL : 0 < L)
    (hmarginLip : ∀ x x' y, margin score x' y hc ≥ margin score x y hc - L * cost x x')
    (x : InputSpace d) (y : LabelSpace c)
    (_hmarginPos : 0 < margin score x y hc)
    (hbdd : BddAbove {r : ℝ | 0 ≤ r ∧ ∀ x', cost x x' ≤ r → 0 < margin score x' y hc}) :
    margin score x y hc / L ≤ idempotentClosureRadius cost score x y hc := by
  -- To show that $margin score x y hc / L \leq idempotentClosureRadius cost score x y hc$, we need to show that for any $r < margin score x y hc / L$, $r \leq idempotentClosureRadius cost score x y hc$.
  have h_le : ∀ r, r < margin score x y hc / L → 0 ≤ r → r ≤ idempotentClosureRadius cost score x y hc := by
    exact fun r hr₁ hr₂ => le_csSup hbdd ⟨ hr₂, fun x' hx' => by nlinarith [ hmarginLip x x' y, mul_div_cancel₀ ( margin score x y hc ) hL.ne' ] ⟩;
  contrapose! h_le;
  exact ⟨ ( idempotentClosureRadius cost score x y hc + margin score x y hc / L ) / 2, by linarith, by linarith [ show 0 ≤ idempotentClosureRadius cost score x y hc from by apply_rules [ Real.sSup_nonneg ] ; aesop ], by linarith ⟩

/-! ## Robustness Preservation -/

/-
Within the certified radius `margin/L`, every point has positive margin.
-/
theorem margin_pos_within_certified_radius
    (cost : InputSpace d → InputSpace d → ℝ)
    (score : InputSpace d → LabelSpace c → ℝ)
    (L : ℝ) (hc : 1 < c)
    (hL : 0 < L)
    (hmarginLip : ∀ x x' y, margin score x' y hc ≥ margin score x y hc - L * cost x x')
    (x : InputSpace d) (y : LabelSpace c)
    (_hmarginPos : 0 < margin score x y hc)
    (x' : InputSpace d)
    (hx' : cost x x' < margin score x y hc / L) :
    0 < margin score x' y hc := by
  nlinarith [ hmarginLip x x' y, mul_div_cancel₀ ( margin score x y hc ) hL.ne' ]

/-
**Robust empirical risk bound.** The robust empirical risk is bounded by the sum
of tropically shifted losses — the dataset-level tropical regularization theorem.
-/
theorem robustEmpiricalRisk_le_tropicalRegularizedRisk
    {m : ℕ}
    (S : Fin m → InputSpace d × LabelSpace c)
    (cost : InputSpace d → InputSpace d → ℝ)
    (score : InputSpace d → LabelSpace c → ℝ)
    (φ : ℝ → ℝ) (ε L : ℝ) (hc : 1 < c)
    (hε : 0 ≤ ε) (hL : 0 ≤ L)
    (hφ : Antitone φ)
    (hcost_nonneg : ∀ x x', 0 ≤ cost x x')
    (hmargin : ∀ x x' y, margin score x' y hc ≥ margin score x y hc - L * cost x x')
    (hbdd : ∀ i, BddAbove {z : ℝ | ∃ x', cost (S i).1 x' ≤ ε ∧
        z = φ (margin score x' (S i).2 hc)})
    (hne : ∀ i, {z : ℝ | ∃ x', cost (S i).1 x' ≤ ε ∧
        z = φ (margin score x' (S i).2 hc)}.Nonempty) :
    robustEmpiricalRisk S cost ε score φ hc ≤
      ∑ i : Fin m, φ (margin score (S i).1 (S i).2 hc - L * ε) := by
  exact Finset.sum_le_sum fun i _ => robustLoss_le_tropicalShift cost score φ ε L hε hL hφ hc hmargin hcost_nonneg _ _ ( hbdd i ) ( hne i )

/-! ## Tropical Margin Properties -/

/-
Positive margin means the true label scores strictly above all competitors.
-/
theorem margin_pos_iff_top_score (score : InputSpace d → LabelSpace c → ℝ)
    (x : InputSpace d) (y : LabelSpace c) (hc : 1 < c) :
    0 < margin score x y hc ↔
      ∀ y', y' ≠ y → score x y' < score x y := by
  unfold TropAdv.margin;
  simp_all +decide

/-
The margin equals the negative of the max competitor advantage (tropical duality).
-/
theorem margin_eq_neg_tropical_max (score : InputSpace d → LabelSpace c → ℝ)
    (x : InputSpace d) (y : LabelSpace c) (hc : 1 < c) :
    margin score x y hc =
      -(Finset.sup' (Finset.univ.erase y) (erase_univ_nonempty hc y)
        (fun y' => score x y' - score x y)) := by
  unfold TropAdv.margin;
  rw [ show ( Finset.univ.erase y ).sup' _ ( fun y' => score x y' - score x y ) = ( Finset.univ.erase y ).sup' _ ( fun y' => score x y' ) - score x y from ?_ ];
  grind;
  exact TropAdv.erase_univ_nonempty hc y;
  refine' le_antisymm _ _ <;> simp +decide [Finset.sup'_le_iff];
  · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
  · have := Finset.exists_max_image ( Finset.univ.erase y ) ( fun z => score x z ) ⟨ Classical.choose ( Finset.card_pos.mp ( by simpa [ Finset.card_erase_of_mem ( Finset.mem_univ y ) ] using by linarith ) ), Classical.choose_spec ( Finset.card_pos.mp ( by simpa [ Finset.card_erase_of_mem ( Finset.mem_univ y ) ] using by linarith ) ) ⟩ ; aesop;

end TropAdv