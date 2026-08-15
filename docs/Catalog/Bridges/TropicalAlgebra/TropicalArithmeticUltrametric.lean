/-
  # Ultrametric Lipschitz Bounds Induced by Tropical Valuations
  ## on Arithmetic Height Spaces

  Bridge: connects arithmetic height theory (`Bridges/ArithmeticVCDimension.lean`)
  ↔ tropical–ultrametric reconstruction (`Bridges/CategoricalTropicalUltrametric.lean`)
  ↔ nonarchimedean metric regularity / certified robustness.

  ## Research narrative

  The catalog already contains two complementary objects that had never been
  connected by a concrete metric-regularity theorem:

  * `ArithmeticVCDim.ratArithHeight : ℚ → ℕ`, an arithmetic height on the rationals,
    together with positivity (`ratArithHeight_pos`) and symmetry
    (`ratArithHeight_neg`) lemmas.
  * `CategoricalTropicalUltrametric.valuationReconstruct`, a *quantitative functor*
    turning tropical valuation data into ultrametric seminorms, together with the
    transfer theorem
    `CategoricalTropicalUltrametric.tropical_nonexpansive_implies_ultrametric_nonexpansive`.

  This file builds the missing bridge: it turns a *valuation monotonicity* inequality
  into a *concrete metric regularity* statement (nonexpansiveness) on rational
  arithmetic data, and isolates the sharp hypotheses under which the bridge is valid.

  ## Adversarial ground truth (the sharp hypothesis)

  The naive guess — that the arithmetic height itself is an ultrametric valuation —
  is **false**.  We prove this as `ratArithHeight_not_nonarchimedean`: the height
  fails the strong (max-form) triangle inequality already on `1 + 1`.  This is the
  precise obstruction the concept warned about ("the exact metric definition may fail
  to satisfy the desired inequalities without the right normalization").  The correct
  normalization is the *p-adic valuation*, which **does** yield a genuine rational
  ultrametric; that ultrametric is what supports the Lipschitz/nonexpansive bridge.

  ## Main results

  * `ratArithHeight_not_nonarchimedean` — the height is not an ultranorm (falsifier).
  * `RatUltraValuation` + `RatUltraValuation.dist_strong_triangle` — strong (max-form)
    triangle law for the induced rational ultradistance.
  * `valuation_mono_nonexpansive` — the **bridge theorem**: an additive map whose
    valuation does not increase induces a nonexpansive map of ultrametric spaces.
  * `nonexpansive_comp` / `lipschitz_comp` — compositional closure of nonexpansive
    (resp. Lipschitz) arithmetic maps.
  * `padicRatUltra` — the p-adic instance: a genuine rational ultravaluation.
  * `pow_padicValNat_le_ratArithHeight` — height comparison linking valuation depth
    to `ratArithHeight`.
-/

import Mathlib
import Bridges.PosetTheory.ArithmeticVCDimension
import Bridges.CategoricalTropicalUltrametric
open Function

noncomputable section

namespace TropicalArithmeticUltrametric

/-! ## §1. Adversarial ground truth: the arithmetic height is not an ultranorm

Bridge: pressure-tests the naive identification `height = ultrametric valuation`. -/

-- !-- Lab Notebook -- !--
-- Hypothesis: maybe `ratArithHeight` already satisfies the strong triangle law,
--   `h(q+r) ≤ max (h q) (h r)`, so it would directly be an ultranorm.
-- Result: FALSE. On `q = r = 1` we get `h(2) = 3 > 2 = max (h 1) (h 1)`.
-- Insight: the height is *sub*additive-ish but grows under addition; the genuine
--   ultrametric must come from a p-adic valuation, not the height itself.
-- Failure analysis: any bridge attempting to use `ratArithHeight` as the norm of
--   `valuationReconstruct` would violate `val_add`; the right carrier uses padicNorm.
-- !-- Lab Notebook -- !--

/-- **Falsifier.** The rational arithmetic height of
    `Bridges/ArithmeticVCDimension.lean` does *not* satisfy the ultrametric
    (strong, max-form) triangle inequality: it fails already at `1 + 1`.
    This isolates the sharp hypothesis — the height must be replaced by a genuine
    valuation before any nonexpansive bridge can hold. -/
-- !-- Sketch: instantiate at q = r = 1; `h 2 = 3` but `max (h 1) (h 1) = 2`. -- !--
theorem ratArithHeight_not_nonarchimedean :
    ¬ (∀ q r : ℚ, ArithmeticVCDim.ratArithHeight (q + r)
        ≤ max (ArithmeticVCDim.ratArithHeight q) (ArithmeticVCDim.ratArithHeight r)) := by
  intro h
  have := h 1 1
  norm_num [ArithmeticVCDim.ratArithHeight] at this

/-! ## §2. Rational ultravaluations and the induced ultradistance

Bridge: a rational arithmetic metric space whose distance is induced by a
(genuine) valuation, the corrected analogue of `valuationReconstruct` over ℚ. -/

/-- A **rational ultravaluation**: an absolute-value–like map `ℚ → ℚ` satisfying the
    nonarchimedean (max-form) triangle inequality.  This is the rational, real-valued
    counterpart of `CategoricalTropicalUltrametric.TropicalValuationCarrier`
    (which is ℕ-valued and multiplicative). -/
structure RatUltraValuation where
  val : ℚ → ℚ
  val_nonneg : ∀ x, 0 ≤ val x
  val_zero : val 0 = 0
  val_eq_zero : ∀ x, val x = 0 → x = 0
  val_neg : ∀ x, val (-x) = val x
  val_add_le : ∀ x y, val (x + y) ≤ max (val x) (val y)
  val_mul : ∀ x y, val (x * y) = val x * val y

namespace RatUltraValuation

variable (V : RatUltraValuation)

/-- The ultradistance induced by a rational ultravaluation: `d(x,y) = val (x - y)`.
    Bridge: rational arithmetic metric induced by valuation depth. -/
def dist (x y : ℚ) : ℚ := V.val (x - y)

@[simp] theorem dist_self (x : ℚ) : V.dist x x = 0 := by
  simp [dist, V.val_zero]

theorem dist_nonneg (x y : ℚ) : 0 ≤ V.dist x y := V.val_nonneg _

/-- Symmetry of the induced ultradistance. -/
theorem dist_comm (x y : ℚ) : V.dist x y = V.dist y x := by
  have : x - y = -(y - x) := by ring
  rw [dist, dist, this, V.val_neg]

/-- **Strong (max-form) triangle law** for the induced ultradistance.  This is the
    central metric-regularity target: the rational ultradistance is a genuine
    ultrametric.  Compare `CategoricalTropicalUltrametric.valuationReconstruct_obj_ultrametric`
    (the ℕ-valued analogue). -/
-- !-- Sketch: `x - z = (x - y) + (y - z)`, then apply `val_add_le`. -- !--
theorem dist_strong_triangle (x y z : ℚ) :
    V.dist x z ≤ max (V.dist x y) (V.dist y z) := by
  have hxz : x - z = (x - y) + (y - z) := by ring
  rw [dist, hxz]
  exact V.val_add_le _ _

/-- The ultradistance separates points: `d(x,y) = 0 ↔ x = y`. -/
theorem dist_eq_zero_iff (x y : ℚ) : V.dist x y = 0 ↔ x = y := by
  constructor
  · intro h
    have := V.val_eq_zero _ h
    have : x - y = 0 := this
    linarith
  · intro h; subst h; simp

end RatUltraValuation

/-! ## §3. The bridge theorem: valuation monotonicity ⇒ nonexpansiveness

Bridge: turns a valuation inequality (`val (f x) ≤ val x`) into a concrete metric
regularity statement (`dist (f x) (f y) ≤ dist x y`).  This is the rational, metric
counterpart of
`CategoricalTropicalUltrametric.tropical_nonexpansive_implies_ultrametric_nonexpansive`. -/

/-- `f` is **nonexpansive** for the ultradistance of `V`. -/
def Nonexpansive (V : RatUltraValuation) (f : ℚ → ℚ) : Prop :=
  ∀ x y, V.dist (f x) (f y) ≤ V.dist x y

/-- `f` is **`C`-Lipschitz** for the ultradistance of `V`. -/
def LipschitzWithRat (V : RatUltraValuation) (C : ℚ) (f : ℚ → ℚ) : Prop :=
  ∀ x y, V.dist (f x) (f y) ≤ C * V.dist x y

-- !-- Lab Notebook -- !--
-- Hypothesis: a valuation-monotone additive map should be nonexpansive.
-- Result: TRUE under exactly two hypotheses — additivity on differences
--   (`f (a - b) = f a - f b`) and valuation monotonicity (`val (f a) ≤ val a`).
-- Insight: additivity is the bridge that converts the *pointwise* valuation bound
--   into a *metric* bound on differences; dropping it breaks the argument.
-- Failure analysis: without additivity, `f x - f y ≠ f (x - y)`, so the valuation
--   bound on `f` cannot be transported to the distance.
-- !-- Lab Notebook -- !--

/-- **Bridge theorem.**  Any additive map whose valuation does not increase induces a
    nonexpansive map of the associated ultrametric spaces.  This is the sharp form:
    additivity on differences + valuation monotonicity are exactly what is needed. -/
-- !-- Sketch: `dist (f x)(f y) = val (f x - f y) = val (f (x - y)) ≤ val (x - y)`. -- !--
theorem valuation_mono_nonexpansive (V : RatUltraValuation) {f : ℚ → ℚ}
    (hadd : ∀ a b, f (a - b) = f a - f b)
    (hmono : ∀ a, V.val (f a) ≤ V.val a) :
    Nonexpansive V f := by
  intro x y
  unfold RatUltraValuation.dist
  rw [← hadd]
  exact hmono _

/-- **Lipschitz bridge.**  An additive map with valuation scaled by at most `C ≥ 0`
    is `C`-Lipschitz for the induced ultradistance. -/
theorem valuation_lip_lipschitz (V : RatUltraValuation) {f : ℚ → ℚ} {C : ℚ}
    (hadd : ∀ a b, f (a - b) = f a - f b)
    (hlip : ∀ a, V.val (f a) ≤ C * V.val a) :
    LipschitzWithRat V C f := by
  intro x y
  unfold RatUltraValuation.dist
  rw [← hadd]
  exact hlip _

/-! ## §4. Compositional closure

Bridge: nonexpansive (resp. Lipschitz) arithmetic maps remain so under composition —
the reusable "metric-control layer" for arithmetic pipelines. -/

/-- Compositional closure of nonexpansive maps. -/
-- !-- Sketch: chain `dist (g (f x)) (g (f y)) ≤ dist (f x)(f y) ≤ dist x y`. -- !--
theorem nonexpansive_comp (V : RatUltraValuation) {f g : ℚ → ℚ}
    (hf : Nonexpansive V f) (hg : Nonexpansive V g) :
    Nonexpansive V (g ∘ f) := by
  intro x y
  exact le_trans (hg (f x) (f y)) (hf x y)

/-- Compositional closure of Lipschitz maps: constants multiply. -/
-- !-- Sketch: `dist (g∘f x)(g∘f y) ≤ D * dist (f x)(f y) ≤ D * (C * dist x y)`. -- !--
theorem lipschitz_comp (V : RatUltraValuation) {f g : ℚ → ℚ} {C D : ℚ}
    (hD : 0 ≤ D)
    (hf : LipschitzWithRat V C f) (hg : LipschitzWithRat V D g) :
    LipschitzWithRat V (D * C) (g ∘ f) := by
  intro x y
  calc V.dist ((g ∘ f) x) ((g ∘ f) y)
      ≤ D * V.dist (f x) (f y) := hg (f x) (f y)
    _ ≤ D * (C * V.dist x y) := by
          apply mul_le_mul_of_nonneg_left (hf x y) hD
    _ = D * C * V.dist x y := by ring

/-- The identity map is nonexpansive. -/
theorem nonexpansive_id (V : RatUltraValuation) : Nonexpansive V (id) := by
  intro x y; simp [RatUltraValuation.dist]

/-! ## §5. The p-adic instance: a genuine rational ultravaluation

Bridge: the corrected normalization — the p-adic norm — actually realizes the
abstract `RatUltraValuation`, in contrast to the failed `ratArithHeight`. -/

-- !-- Lab Notebook -- !--
-- Hypothesis: padicNorm p gives a genuine RatUltraValuation, unlike ratArithHeight.
-- Result: TRUE. All seven axioms hold from Mathlib's nonarchimedean p-adic API.
-- Insight: this is the "right normalization" the concept demanded; the bridge
--   theorem then yields nonexpansiveness for integer-scaling arithmetic maps.
-- Failure analysis: none — the only subtlety is `val_eq_zero`, via
--   `zero_of_padicNorm_eq_zero`.
-- !-- Lab Notebook -- !--

/-- The p-adic norm assembles into a genuine rational ultravaluation. -/
def padicRatUltra (p : ℕ) [Fact (Nat.Prime p)] : RatUltraValuation where
  val := padicNorm p
  val_nonneg := padicNorm.nonneg
  val_zero := padicNorm.zero
  val_eq_zero := fun _ h => padicNorm.zero_of_padicNorm_eq_zero h
  val_neg := padicNorm.neg
  val_add_le := fun _ _ => padicNorm.nonarchimedean
  val_mul := padicNorm.mul

/-- Scaling by an integer constant is nonexpansive in the p-adic ultradistance,
    because integers have p-adic norm at most `1`.  Concrete instance of the bridge
    theorem `valuation_mono_nonexpansive`. -/
-- !-- Sketch: `val (c*a) = val c * val a ≤ 1 * val a` since `padicNorm p c ≤ 1`. -- !--
theorem padic_intScale_nonexpansive (p : ℕ) [Fact (Nat.Prime p)] (c : ℤ) :
    Nonexpansive (padicRatUltra p) (fun a => (c : ℚ) * a) := by
  apply valuation_mono_nonexpansive
  · intro a b; ring
  · intro a
    show padicNorm p ((c : ℚ) * a) ≤ padicNorm p a
    rw [padicNorm.mul]
    have hc : padicNorm p (c : ℚ) ≤ 1 := by
      exact_mod_cast padicNorm.of_int (p := p) c
    nlinarith [padicNorm.nonneg (p := p) a, padicNorm.nonneg (p := p) (c : ℚ)]

/-- Affine maps `a ↦ c·a + b` with integer slope `c` are nonexpansive in the p-adic
    ultradistance (translations are isometries). -/
-- !-- Sketch: `(c*x+b)-(c*y+b) = c*(x-y)`, reduce to integer-scaling. -- !--
theorem padic_intAffine_nonexpansive (p : ℕ) [Fact (Nat.Prime p)] (c : ℤ) (b : ℚ) :
    Nonexpansive (padicRatUltra p) (fun a => (c : ℚ) * a + b) := by
  intro x y
  show padicNorm p (((c : ℚ) * x + b) - ((c : ℚ) * y + b)) ≤ padicNorm p (x - y)
  have hrw : ((c : ℚ) * x + b) - ((c : ℚ) * y + b) = (c : ℚ) * (x - y) := by ring
  rw [hrw, padicNorm.mul]
  have hc : padicNorm p (c : ℚ) ≤ 1 := by
    exact_mod_cast padicNorm.of_int (p := p) c
  nlinarith [padicNorm.nonneg (p := p) (x - y), padicNorm.nonneg (p := p) (c : ℚ)]

/-! ## §6. Height comparison: valuation depth is bounded by arithmetic height

Bridge: links `Bridges/ArithmeticVCDimension.ratArithHeight` to p-adic valuation
depth, so the bounded ultradistance can be read off arithmetic data. -/

-- !-- Lab Notebook -- !--
-- Hypothesis: p-adic valuation depth of an integer is bounded by its height.
-- Result: TRUE. `p ^ v_p(n) ∣ n.natAbs ≤ n.natAbs + 1 = ratArithHeight (n:ℚ)`.
-- Insight: the largest p-power dividing n never exceeds the arithmetic height,
--   making valuation depth an arithmetically-computable quantity bounded by height.
-- Failure analysis: requires n ≠ 0 (else v_p is unbounded / height collapses).
-- !-- Lab Notebook -- !--

/-- **Height comparison.**  The p-adic valuation depth of a nonzero integer is bounded
    by its rational arithmetic height: `p ^ v_p(|n|) ≤ ratArithHeight n`. -/
-- !-- Sketch: `p^v ∣ |n|` and `|n| ≥ 1`, so `p^v ≤ |n| ≤ |n|+1 = height`. -- !--
theorem pow_padicValNat_le_ratArithHeight (p : ℕ) (n : ℤ) (hn : n ≠ 0) :
    p ^ padicValNat p n.natAbs ≤ ArithmeticVCDim.ratArithHeight (n : ℚ) := by
  have hdvd : p ^ padicValNat p n.natAbs ∣ n.natAbs := pow_padicValNat_dvd
  have hpos : 0 < n.natAbs := Int.natAbs_pos.mpr hn
  have hle : p ^ padicValNat p n.natAbs ≤ n.natAbs := Nat.le_of_dvd hpos hdvd
  have hheight : ArithmeticVCDim.ratArithHeight (n : ℚ) = n.natAbs + 1 := by
    simp [ArithmeticVCDim.ratArithHeight]
  omega

/-- For integer arithmetic data the p-adic ultradistance is bounded by `1`: the
    induced metric on the integers is the "bounded ultradistance" of the concept. -/
-- !-- Sketch: `x - y` is an integer; integers have p-adic norm ≤ 1. -- !--
theorem padic_int_dist_le_one (p : ℕ) [Fact (Nat.Prime p)] (m n : ℤ) :
    (padicRatUltra p).dist (m : ℚ) (n : ℚ) ≤ 1 := by
  show padicNorm p ((m : ℚ) - (n : ℚ)) ≤ 1
  have : ((m : ℚ) - (n : ℚ)) = ((m - n : ℤ) : ℚ) := by push_cast; ring
  rw [this]
  exact_mod_cast padicNorm.of_int (p := p) (m - n)

end TropicalArithmeticUltrametric

end