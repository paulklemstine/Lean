/-
Copyright (c) 2026. Phase A Research Mission: Bridge NumberTheory ↔ Machine Learning.

# Arithmetic Geometry of Transformer Weight Lattices, V:
# the exact convexity defect of nearest-point grid quantization

This file closes the first open conjecture of `FUTURE_DIRECTIONS.md`
("the sharp constant is `L·r`, not `2·L·r`, for *nearest-point* quantizers").

The conjecture is **false**, and it is refuted here by an explicit convex
`1`-Lipschitz loss:

* `targetLoss_defect_ge` — the "distance to the target weight" loss
  `f w = |w − δ|` composed with `δ`-grid rounding has convexity defect
  `≥ (1 − 1/n)·δ` for every `n ≥ 3`, hence
* `gridRound_defect_ge` — defect `≥ δ = 2·L·r`.  Combined with Theorem A
  (`quantized_approxConvex`) the sharp constant for the nearest-point grid
  quantizer is **exactly** `2·L·r` (`grid_defect_constant_exact`), and the
  conjectured `L·r` bound fails (`grid_defect_Lr_refuted`).

The earlier computational scans missed this because they only tested losses
(`|x|`, `x²`, a two-kink loss) that are *symmetric around a grid point*; the
extremal configuration needs a strongly unbalanced convex combination `a → 1`
together with a loss that decreases across the offending grid cell.

The failure is however confined to unbalanced combinations.  The second half of
the file proves the complementary **positive** result:

* `two_round_midpoint_sub_le` — the arithmetic heart, an integer parity
  statement: `|round X + round Y − 2·round((X+Y)/2)| ≤ 1`;
* `gridRound_midpoint_dist` — hence rounding the midpoint of two weights differs
  from the midpoint of the two rounded weights by at most `δ/2`;
* `quantizeTensor_midpoint_defect` — hence for *weight averaging* (`a = b = ½`,
  the "model soup" regime) the entrywise-quantized landscape of a convex
  `L`-Lipschitz loss has defect at most `L·δ/2 = L·r`, **half** the general
  bound, and that constant is sharp (`midpoint_constant_sharp`).

So the true picture is: defect `= 2·L·r` in general, `= L·r` on balanced
combinations.
-/
import Bridges.QuantizedWeightLatticesLandscape

namespace QuantizedWeightLattices.SharpConstant

open QuantizedWeightLattices QuantizedWeightLattices.Sharp Set

/-! ## Section 1: an integer parity lemma for nearest-point rounding -/

/-- **Parity of nearest-point rounding.**  For any two reals, the sum of their
roundings and twice the rounding of their mean differ by at most one.  This is a
genuine arithmetic constraint: it forbids the two endpoints and the midpoint of a
segment from being rounded "in opposite directions" simultaneously. -/
lemma two_round_midpoint_sub_le (X Y : ℝ) :
    |round X + round Y - 2 * round ((X + Y) / 2)| ≤ 1 := by
  have hX1 : X - 1 / 2 < ((round X : ℤ) : ℝ) := sub_half_lt_round X
  have hX2 : ((round X : ℤ) : ℝ) ≤ X + 1 / 2 := round_le_add_half X
  have hY1 : Y - 1 / 2 < ((round Y : ℤ) : ℝ) := sub_half_lt_round Y
  have hY2 : ((round Y : ℤ) : ℝ) ≤ Y + 1 / 2 := round_le_add_half Y
  have hM1 : (X + Y) / 2 - 1 / 2 < ((round ((X + Y) / 2) : ℤ) : ℝ) := sub_half_lt_round _
  have hM2 : ((round ((X + Y) / 2) : ℤ) : ℝ) ≤ (X + Y) / 2 + 1 / 2 := round_le_add_half _
  -- upper bound: `2w < p + q + 2`
  have hup : ((2 * round ((X + Y) / 2) : ℤ) : ℝ) < ((round X + round Y + 2 : ℤ) : ℝ) := by
    push_cast; linarith
  have hup' : 2 * round ((X + Y) / 2) < round X + round Y + 2 := by exact_mod_cast hup
  -- lower bound: `p + q - 2 < 2w`
  have hlo : ((round X + round Y - 2 : ℤ) : ℝ) < ((2 * round ((X + Y) / 2) : ℤ) : ℝ) := by
    push_cast; linarith
  have hlo' : round X + round Y - 2 < 2 * round ((X + Y) / 2) := by exact_mod_cast hlo
  exact abs_le.2 ⟨by omega, by omega⟩

/-- **Midpoint stability of grid quantization.**  Rounding the midpoint of two
weights and averaging the two rounded weights differ by at most the covering
radius `δ/2` — *not* `δ`, which is the general bound for the distance between
`Q(a x + b y)` and `a Q x + b Q y`. -/
lemma gridRound_midpoint_dist {δ : ℝ} (hδ : 0 < δ) (x y : ℝ) :
    |gridRound δ ((x + y) / 2) - (gridRound δ x + gridRound δ y) / 2| ≤ δ / 2 := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have harg : (x + y) / 2 / δ = (x / δ + y / δ) / 2 := by field_simp
  have key : |round (x / δ) + round (y / δ) - 2 * round ((x / δ + y / δ) / 2)| ≤ 1 :=
    two_round_midpoint_sub_le (x / δ) (y / δ)
  have keyR : |((round (x / δ) + round (y / δ)
      - 2 * round ((x / δ + y / δ) / 2) : ℤ) : ℝ)| ≤ 1 := by
    rw [← Int.cast_abs]
    exact_mod_cast key
  have hrepr : gridRound δ ((x + y) / 2) - (gridRound δ x + gridRound δ y) / 2
      = -(δ / 2) * ((round (x / δ) + round (y / δ)
          - 2 * round ((x / δ + y / δ) / 2) : ℤ) : ℝ) := by
    simp only [gridRound, harg]
    push_cast
    ring
  rw [hrepr, abs_mul, abs_neg, abs_of_pos (by positivity : (0:ℝ) < δ / 2)]
  calc δ / 2 * |((round (x / δ) + round (y / δ)
        - 2 * round ((x / δ + y / δ) / 2) : ℤ) : ℝ)|
      ≤ δ / 2 * 1 := mul_le_mul_of_nonneg_left keyR (by positivity)
    _ = δ / 2 := by ring

/-! ## Section 2: the midpoint (weight-averaging) defect is only `L·r` -/

section Tensor

variable {ι : Type*} [Fintype ι]

/-- Entrywise version of `gridRound_midpoint_dist`: quantizing the average of two
weight tensors is within `δ/2` (sup norm) of the average of the two quantized
tensors. -/
lemma quantizeTensor_midpoint_dist {δ : ℝ} (hδ : 0 < δ) (W V : ι → ℝ) :
    ‖quantizeTensor δ ((1 / 2 : ℝ) • W + (1 / 2 : ℝ) • V)
      - ((1 / 2 : ℝ) • quantizeTensor δ W + (1 / 2 : ℝ) • quantizeTensor δ V)‖ ≤ δ / 2 := by
  refine (pi_norm_le_iff_of_nonneg (by positivity)).2 fun i => ?_
  have h := gridRound_midpoint_dist hδ (W i) (V i)
  have hi : ((1 / 2 : ℝ) • W + (1 / 2 : ℝ) • V) i = (W i + V i) / 2 := by
    simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]; ring
  have e : (quantizeTensor δ ((1 / 2 : ℝ) • W + (1 / 2 : ℝ) • V)
      - ((1 / 2 : ℝ) • quantizeTensor δ W + (1 / 2 : ℝ) • quantizeTensor δ V)) i
      = gridRound δ ((W i + V i) / 2) - (gridRound δ (W i) + gridRound δ (V i)) / 2 := by
    simp only [Pi.sub_apply, Pi.add_apply, Pi.smul_apply, smul_eq_mul, quantizeTensor, hi]
    ring
  rw [Real.norm_eq_abs, e]
  exact h

variable {L : NNReal} {f : (ι → ℝ) → ℝ}

/-- **Theorem S7 (weight averaging is only `L·r`-nonconvex).**  For a convex
`L`-Lipschitz loss on weight tensors, the entrywise `δ`-grid quantized landscape
satisfies the convexity inequality at the *midpoint* with defect at most
`L·δ/2 = L·r`, i.e. half of the general bound `2·L·r` of Theorem A.

Interpretation: averaging two quantized checkpoints ("model soup") can lose only
half as much landscape convexity as an arbitrary interpolation. -/
theorem quantizeTensor_midpoint_defect (hf : ConvexOn ℝ univ f) (hL : LipschitzWith L f)
    {δ : ℝ} (hδ : 0 < δ) (W V : ι → ℝ) :
    f (quantizeTensor δ ((1 / 2 : ℝ) • W + (1 / 2 : ℝ) • V))
      ≤ (1 / 2 : ℝ) * f (quantizeTensor δ W) + (1 / 2 : ℝ) * f (quantizeTensor δ V)
        + (L : ℝ) * (δ / 2) := by
  set A : ι → ℝ := quantizeTensor δ ((1 / 2 : ℝ) • W + (1 / 2 : ℝ) • V) with hA
  set B : ι → ℝ := (1 / 2 : ℝ) • quantizeTensor δ W + (1 / 2 : ℝ) • quantizeTensor δ V with hB
  have hdist : ‖A - B‖ ≤ δ / 2 := quantizeTensor_midpoint_dist hδ W V
  have hlip : |f A - f B| ≤ (L : ℝ) * ‖A - B‖ := abs_sub_le_lipschitz hL A B
  have hmul : (L : ℝ) * ‖A - B‖ ≤ (L : ℝ) * (δ / 2) :=
    mul_le_mul_of_nonneg_left hdist L.coe_nonneg
  have hAB : f A ≤ f B + (L : ℝ) * (δ / 2) := by
    have := (abs_le.1 (hlip.trans hmul)).2
    linarith
  have hconv : f B ≤ (1 / 2 : ℝ) * f (quantizeTensor δ W)
      + (1 / 2 : ℝ) * f (quantizeTensor δ V) :=
    hf.2 (mem_univ _) (mem_univ _) (by norm_num) (by norm_num) (by norm_num)
  linarith

end Tensor

/-- The scalar case of `quantizeTensor_midpoint_defect`, stated directly for
`gridRound` on `ℝ`. -/
theorem gridRound_midpoint_defect {L : NNReal} {f : ℝ → ℝ} (hf : ConvexOn ℝ univ f)
    (hL : LipschitzWith L f) {δ : ℝ} (hδ : 0 < δ) (x y : ℝ) :
    f (gridRound δ ((x + y) / 2))
      ≤ (1 / 2 : ℝ) * f (gridRound δ x) + (1 / 2 : ℝ) * f (gridRound δ y)
        + (L : ℝ) * (δ / 2) := by
  have hdist : |gridRound δ ((x + y) / 2)
      - ((1 / 2 : ℝ) * gridRound δ x + (1 / 2 : ℝ) * gridRound δ y)| ≤ δ / 2 := by
    have h := gridRound_midpoint_dist hδ x y
    have e : (gridRound δ x + gridRound δ y) / 2
        = (1 / 2 : ℝ) * gridRound δ x + (1 / 2 : ℝ) * gridRound δ y := by ring
    rwa [e] at h
  set A : ℝ := gridRound δ ((x + y) / 2) with hA
  set B : ℝ := (1 / 2 : ℝ) * gridRound δ x + (1 / 2 : ℝ) * gridRound δ y with hB
  have hlip : |f A - f B| ≤ (L : ℝ) * ‖A - B‖ := abs_sub_le_lipschitz hL A B
  have hmul : (L : ℝ) * ‖A - B‖ ≤ (L : ℝ) * (δ / 2) := by
    rw [Real.norm_eq_abs]
    exact mul_le_mul_of_nonneg_left hdist L.coe_nonneg
  have hAB : f A ≤ f B + (L : ℝ) * (δ / 2) := by
    have := (abs_le.1 (hlip.trans hmul)).2
    linarith
  have hconv : f B ≤ (1 / 2 : ℝ) * f (gridRound δ x) + (1 / 2 : ℝ) * f (gridRound δ y) := by
    have := hf.2 (mem_univ (gridRound δ x)) (mem_univ (gridRound δ y))
      (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num)
    simpa [hB, smul_eq_mul] using this
  linarith

/-- **Sharpness of the midpoint constant.**  The constant `L·δ/2` of
`gridRound_midpoint_defect` cannot be lowered: the convex `1`-Lipschitz loss `|·|`
attains it at the weights `2δ/5` and `3δ/5`. -/
theorem midpoint_constant_sharp {δ : ℝ} (hδ : 0 < δ) :
    |gridRound δ ((2 * δ / 5 + 3 * δ / 5) / 2)|
      = (1 / 2 : ℝ) * |gridRound δ (2 * δ / 5)| + (1 / 2 : ℝ) * |gridRound δ (3 * δ / 5)|
        + ((1 : NNReal) : ℝ) * (δ / 2) := by
  have harg : (2 * δ / 5 + 3 * δ / 5) / 2 = δ / 2 := by ring
  rw [harg, gridRound_half hδ, gridRound_two_fifths hδ, gridRound_three_fifths hδ,
    abs_of_pos hδ, abs_zero]
  push_cast
  ring

/-! ## Section 3: refutation of the `L·r` conjecture for unbalanced combinations

The loss is `f w = |w − δ|`, the distance to the target weight `δ` (itself a grid
point); it is convex and `1`-Lipschitz.  The two sample weights are `δ/2` and
`−δ/2`, which round *away from each other* to `δ` and `0`; their convex
combination with weights `a = 1 − 1/n` and `b = 1/n` sits just below the rounding
threshold `δ/2` and therefore rounds *down* to `0`, where the loss is maximal. -/

/-- The "distance to the target weight `c`" loss. -/
noncomputable def targetLoss (c : ℝ) : ℝ → ℝ := fun w => |w - c|

lemma convexOn_targetLoss (c : ℝ) : ConvexOn ℝ univ (targetLoss c) := by
  refine ⟨convex_univ, fun x _ y _ a b ha hb hab => ?_⟩
  have hc : a * c + b * c = c := by rw [← add_mul, hab, one_mul]
  have hx : a • x + b • y - c = a • (x - c) + b • (y - c) := by
    simp only [smul_eq_mul]; linarith
  simp only [targetLoss, hx]
  calc |a • (x - c) + b • (y - c)| ≤ |a • (x - c)| + |b • (y - c)| := abs_add_le _ _
    _ = a * |x - c| + b * |y - c| := by
        simp [abs_mul, abs_of_nonneg ha, abs_of_nonneg hb]

lemma lipschitzWith_targetLoss (c : ℝ) : LipschitzWith 1 (targetLoss c) := by
  refine LipschitzWith.of_dist_le_mul fun x y => ?_
  have h := abs_abs_sub_abs_le_abs_sub (x - c) (y - c)
  have e : (x - c) - (y - c) = x - y := by ring
  rw [e] at h
  simpa [Real.dist_eq, targetLoss] using h

lemma gridRound_neg_half {δ : ℝ} (hδ : 0 < δ) : gridRound δ (-(δ / 2)) = 0 := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hx : -(δ / 2) / δ = -(1 / 2) := by field_simp
  simp [gridRound, hx]

/-- The critical weight `δ/2 − δ/n` sits just below the rounding threshold and
therefore rounds *down* to `0` (for `n ≥ 3`). -/
lemma gridRound_just_below_half {δ : ℝ} (hδ : 0 < δ) {n : ℕ} (hn : 3 ≤ n) :
    gridRound δ (δ / 2 - δ / n) = 0 := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : 1 ≤ n)
  have hn0 : (0 : ℝ) < (n : ℝ) := by linarith
  have hfac : δ / 2 - δ / (n : ℝ) = δ * (1 / 2 - 1 / (n : ℝ)) := by
    field_simp
  have hx : (δ / 2 - δ / n) / δ = 1 / 2 - 1 / (n : ℝ) := by
    rw [hfac, mul_comm, mul_div_assoc, div_self hne, mul_one]
  have hinv_pos : (0 : ℝ) < 1 / (n : ℝ) := by positivity
  have hinv_le : 1 / (n : ℝ) ≤ 1 := by rw [div_le_one hn0]; linarith
  have hlow : (0 : ℝ) ≤ 1 / 2 - 1 / (n : ℝ) + 1 / 2 := by linarith
  have hhigh : 1 / 2 - 1 / (n : ℝ) + 1 / 2 < 1 := by linarith
  have hr : round (1 / 2 - 1 / (n : ℝ)) = 0 := by
    rw [round_eq]
    exact Int.floor_eq_zero_iff.2 (Set.mem_Ico.2 ⟨hlow, hhigh⟩)
  rw [gridRound, hx, hr]
  simp

/-- **Defect lower bound for the target loss.**  For every `n ≥ 3` the convexity
defect of the `δ`-grid quantized target loss is at least `(1 − 1/n)·δ`. -/
theorem targetLoss_defect_ge {δ ε : ℝ} (hδ : 0 < δ) {n : ℕ} (hn : 3 ≤ n)
    (h : ApproxConvexOn ε univ (targetLoss δ ∘ gridRound δ)) :
    δ - δ / n ≤ ε := by
  have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : 1 ≤ n)
  have hn0 : (0 : ℝ) < (n : ℝ) := by linarith
  have hinv_pos : (0 : ℝ) < 1 / (n : ℝ) := by positivity
  have hinv_le : 1 / (n : ℝ) ≤ 1 := by rw [div_le_one hn0]; linarith
  have hcomb : (1 - 1 / (n : ℝ)) • (δ / 2) + (1 / (n : ℝ)) • (-(δ / 2)) = δ / 2 - δ / n := by
    simp only [smul_eq_mul]
    field_simp
    ring
  have key := h (mem_univ (δ / 2)) (mem_univ (-(δ / 2))) (by linarith : (0:ℝ) ≤ 1 - 1 / (n:ℝ))
    hinv_pos.le (by ring)
  rw [hcomb] at key
  simp only [Function.comp_apply, targetLoss, gridRound_just_below_half hδ hn,
    gridRound_half hδ, gridRound_neg_half hδ] at key
  rw [show (0 : ℝ) - δ = -δ by ring, abs_neg, abs_of_pos hδ,
    show δ - δ = (0:ℝ) by ring, abs_zero] at key
  have hdn : (1 / (n : ℝ)) * δ = δ / n := by field_simp
  nlinarith [key, hdn]

/-- **Theorem S8 (the constant `2·L·r` is exactly optimal, even for nearest-point
grid quantization).**  Any approximate-convexity certificate valid for all convex
`1`-Lipschitz losses and the `δ`-grid quantizer must have defect at least
`δ = 2·L·r`.  This *refutes* Conjecture 1 of `FUTURE_DIRECTIONS.md`. -/
theorem gridRound_defect_ge {δ ε : ℝ} (hδ : 0 < δ)
    (h : ApproxConvexOn ε univ (targetLoss δ ∘ gridRound δ)) : δ ≤ ε := by
  by_contra hcon
  push_neg at hcon
  have hpos : 0 < δ - ε := by linarith
  obtain ⟨m, hm⟩ := exists_nat_gt (δ / (δ - ε))
  set n : ℕ := max m 3 with hn
  have hn3 : 3 ≤ n := le_max_right m 3
  have hnm : (m : ℝ) ≤ (n : ℝ) := by exact_mod_cast le_max_left m 3
  have hn0 : (0 : ℝ) < (n : ℝ) := lt_of_le_of_lt (by positivity) (lt_of_lt_of_le hm hnm)
  have hlt : δ / (δ - ε) < (n : ℝ) := lt_of_lt_of_le hm hnm
  have hkey : δ - δ / n ≤ ε := targetLoss_defect_ge hδ hn3 h
  have h1 : δ < (n : ℝ) * (δ - ε) := by
    rw [div_lt_iff₀ hpos] at hlt
    linarith
  have h2 : δ / (n : ℝ) < δ - ε := by
    rw [div_lt_iff₀ hn0]
    linarith
  linarith

/-- The conjectured improvement of the general defect constant to `L·r` is false. -/
theorem grid_defect_Lr_refuted {δ : ℝ} (hδ : 0 < δ) :
    ¬ ApproxConvexOn (δ / 2) univ (targetLoss δ ∘ gridRound δ) := by
  intro h
  have := gridRound_defect_ge hδ h
  linarith

/-- **The exact defect constant of nearest-point grid quantization.**  For the
scalar `δ`-grid quantizer (covering radius `r = δ/2`) and convex `1`-Lipschitz
losses, the optimal approximate-convexity constant is exactly `δ = 2·L·r`:
Theorem A gives it, and no smaller value works. -/
theorem grid_defect_constant_exact {δ : ℝ} (hδ : 0 < δ) :
    ApproxConvexOn δ univ (targetLoss δ ∘ gridRound δ) ∧
      ∀ ε : ℝ, ApproxConvexOn ε univ (targetLoss δ ∘ gridRound δ) → δ ≤ ε := by
  refine ⟨?_, fun ε hε => gridRound_defect_ge hδ hε⟩
  have h := quantized_approxConvex (convexOn_targetLoss δ) (lipschitzWith_targetLoss δ)
    (scalarQuantizer hδ)
  have hrad : 2 * ((1 : NNReal) : ℝ) * (scalarQuantizer hδ).radius = δ := by
    show 2 * ((1 : NNReal) : ℝ) * (δ / 2) = δ
    push_cast
    ring
  rwa [hrad] at h

/-! ## Section 4: the finite-precision convexity audit

Theorem E of `QuantizedWeightLattices.lean` recovers *exact* convexity of the
continuous loss from an infinite tower of quantized landscapes with vanishing
defects.  The following two statements are its *finite* counterpart, and they
resolve the analytic half of Conjecture 5 of `FUTURE_DIRECTIONS.md`: a single
precision already certifies convexity of the continuous loss up to `2·L·r`, and
the correspondence is two-sided — quantization changes the convexity defect of an
`L`-Lipschitz landscape by at most `2·L·r`, in either direction. -/

section Audit

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] {L : NNReal} {f : E → ℝ}

/-- **Quantization increases the defect by at most `2·L·r`** (Theorem A with the
exact-convexity hypothesis relaxed to `ε`-approximate convexity). -/
theorem quantized_approxConvexOn_of_approxConvexOn (hL : LipschitzWith L f) (Q : Quantizer E)
    {ε : ℝ} (h : ApproxConvexOn ε univ f) :
    ApproxConvexOn (ε + 2 * (L : ℝ) * Q.radius) univ (f ∘ Q.toFun) := by
  intro x _ y _ a b ha hb hab
  have hmid : f (Q.toFun (a • x + b • y)) ≤ f (a • x + b • y) + (L : ℝ) * Q.radius :=
    loss_quantize_le hL Q _
  have hconv : f (a • x + b • y) ≤ a * f x + b * f y + ε := h (mem_univ x) (mem_univ y) ha hb hab
  have hax : a * f x ≤ a * (f (Q.toFun x) + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left (loss_le_quantize hL Q x) ha
  have hby : b * f y ≤ b * (f (Q.toFun y) + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left (loss_le_quantize hL Q y) hb
  have hsum : a * ((L : ℝ) * Q.radius) + b * ((L : ℝ) * Q.radius) = (L : ℝ) * Q.radius := by
    rw [← add_mul, hab, one_mul]
  simp only [Function.comp_apply]
  nlinarith [hmid, hconv, hax, hby, hsum]

/-- **Theorem F (finite-precision convexity certification).**  Conversely, if the
quantized landscape of an `L`-Lipschitz loss is `ε`-approximately convex at a
*single* precision with covering radius `r`, then the continuous loss is
`(ε + 2·L·r)`-approximately convex.  In particular a *convex* quantized landscape
(`ε = 0`) certifies convexity of the true loss up to `2·L·r`; letting `r → 0`
along a refining tower recovers Theorem E. -/
theorem approxConvexOn_of_quantized (hL : LipschitzWith L f) (Q : Quantizer E) {ε : ℝ}
    (h : ApproxConvexOn ε univ (f ∘ Q.toFun)) :
    ApproxConvexOn (ε + 2 * (L : ℝ) * Q.radius) univ f := by
  intro x _ y _ a b ha hb hab
  have hmid : f (a • x + b • y) ≤ f (Q.toFun (a • x + b • y)) + (L : ℝ) * Q.radius :=
    loss_le_quantize hL Q _
  have hq : f (Q.toFun (a • x + b • y)) ≤ a * f (Q.toFun x) + b * f (Q.toFun y) + ε := by
    have := h (mem_univ x) (mem_univ y) ha hb hab
    simpa [Function.comp_apply] using this
  have hax : a * f (Q.toFun x) ≤ a * (f x + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left (loss_quantize_le hL Q x) ha
  have hby : b * f (Q.toFun y) ≤ b * (f y + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left (loss_quantize_le hL Q y) hb
  have hsum : a * ((L : ℝ) * Q.radius) + b * ((L : ℝ) * Q.radius) = (L : ℝ) * Q.radius := by
    rw [← add_mul, hab, one_mul]
  nlinarith [hmid, hq, hax, hby, hsum]

/-- **Theorem G (two-sided audit).**  For an `L`-Lipschitz loss the convexity
defect is a `2·L·r`-Lipschitz invariant of quantization: certificates transfer in
both directions with the same loss `2·L·r`, which by `grid_defect_constant_exact`
is optimal for nearest-point grid quantization. -/
theorem convexity_audit_two_sided (hL : LipschitzWith L f) (Q : Quantizer E) {ε : ℝ} :
    (ApproxConvexOn ε univ f → ApproxConvexOn (ε + 2 * (L : ℝ) * Q.radius) univ (f ∘ Q.toFun)) ∧
      (ApproxConvexOn ε univ (f ∘ Q.toFun) →
        ApproxConvexOn (ε + 2 * (L : ℝ) * Q.radius) univ f) :=
  ⟨quantized_approxConvexOn_of_approxConvexOn hL Q, approxConvexOn_of_quantized hL Q⟩

/-- A convex quantized landscape certifies `2·L·r`-approximate convexity of the
continuous loss. -/
theorem approxConvexOn_of_convex_quantized (hL : LipschitzWith L f) (Q : Quantizer E)
    (h : ConvexOn ℝ univ (f ∘ Q.toFun)) :
    ApproxConvexOn (2 * (L : ℝ) * Q.radius) univ f := by
  have := approxConvexOn_of_quantized hL Q h.approxConvexOn
  simpa using this

end Audit

/-! ## Section 5: the denominator law

The two extreme cases proved above — defect `L·r` for the balanced weight `a = 1/2`
and defect `→ 2·L·r` along `a = 1 − 1/n` — are the first instances of a single
**arithmetic law**: the sharp convexity defect at an interpolation weight
`a = k/q` (in lowest terms) is governed by the *denominator* `q`,

  `defect ≤ (1 − 1/q) · L · δ = (1 − 1/q) · 2·L·r`.

The reason is purely number-theoretic: the discrepancy
`A = a·Qx + (1−a)·Qy − Q(a x + (1−a) y)` is a multiple of `δ/q` (all three
roundings are lattice points and `a` has denominator `q`), while three
covering-radius estimates force `|A| < δ`; an integer strictly smaller than `q` is
at most `q − 1`.  The convex-analytic half converts `|A|` into a defect bound.

For `q = 2` this returns `L·δ/2 = L·r`, and the bound is attained for every `q`
at `a = (q−1)/q` (`targetLoss_defect_eq`), so the law is sharp along that family. -/

section DenominatorLaw

lemma round_monotone : Monotone (round : ℝ → ℤ) := by
  intro x y h
  simp only [round_eq]
  exact Int.floor_le_floor (by linarith)

lemma gridRound_monotone {δ : ℝ} (hδ : 0 < δ) : Monotone (gridRound δ) := by
  intro x y h
  have hdiv : x / δ ≤ y / δ := by gcongr
  have hround : (round (x / δ) : ℝ) ≤ (round (y / δ) : ℝ) := by
    exact_mod_cast round_monotone hdiv
  simpa [gridRound] using mul_le_mul_of_nonneg_left hround hδ.le

/-- **Convex-analytic half of the denominator law.**  If `w` lies between `u` and
`v`, the convexity defect of an `L`-Lipschitz convex `f` at the triple `(u, v, w)`
with weight `a` is bounded by `L` times the *discrepancy* `|a u + (1−a) v − w|`. -/
lemma convex_defect_le_discrepancy {L : NNReal} {f : ℝ → ℝ} (hf : ConvexOn ℝ univ f)
    (hL : LipschitzWith L f) {u v w a : ℝ} (hw : w ∈ Set.Icc (min u v) (max u v)) :
    f w - (a * f u + (1 - a) * f v) ≤ (L : ℝ) * |a * u + (1 - a) * v - w| := by
  rw [← segment_eq_Icc'] at hw
  obtain ⟨s, t, hs, ht, hst, hw'⟩ := hw
  have hwe : w = s * u + t * v := by rw [← hw']; simp [smul_eq_mul]
  have ht' : t = 1 - s := by linarith
  have hfw : f w ≤ s * f u + (1 - s) * f v := by
    have hconv := hf.2 (mem_univ u) (mem_univ v) hs ht hst
    rw [hwe, ht']
    simpa [smul_eq_mul, ht'] using hconv
  have hA : a * u + (1 - a) * v - w = (a - s) * (u - v) := by rw [hwe, ht']; ring
  have hlip : |f v - f u| ≤ (L : ℝ) * |v - u| := by
    simpa [Real.norm_eq_abs] using abs_sub_le_lipschitz hL v u
  calc f w - (a * f u + (1 - a) * f v) ≤ (a - s) * (f v - f u) := by nlinarith [hfw]
    _ ≤ |(a - s) * (f v - f u)| := le_abs_self _
    _ = |a - s| * |f v - f u| := abs_mul _ _
    _ ≤ |a - s| * ((L : ℝ) * |v - u|) := by
        exact mul_le_mul_of_nonneg_left hlip (abs_nonneg _)
    _ = (L : ℝ) * (|a - s| * |u - v|) := by rw [abs_sub_comm v u]; ring
    _ = (L : ℝ) * |a * u + (1 - a) * v - w| := by rw [hA, abs_mul]

/-- **Covering-radius half.**  The rounding discrepancy of a strictly convex
combination is *strictly* smaller than one full mesh. -/
lemma discrepancy_lt_mesh {δ : ℝ} (hδ : 0 < δ) {a : ℝ} (ha0 : 0 < a) (ha1 : a < 1) (x y : ℝ) :
    |a * gridRound δ x + (1 - a) * gridRound δ y
      - gridRound δ (a * x + (1 - a) * y)| < δ := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hM : (a * x + (1 - a) * y) / δ = a * (x / δ) + (1 - a) * (y / δ) := by
    field_simp
  set X : ℝ := x / δ with hX
  set Y : ℝ := y / δ with hY
  set M : ℝ := a * X + (1 - a) * Y with hMdef
  have hp1 : X - 1 / 2 < ((round X : ℤ) : ℝ) := sub_half_lt_round X
  have hp2 : ((round X : ℤ) : ℝ) ≤ X + 1 / 2 := round_le_add_half X
  have hr1 : Y - 1 / 2 < ((round Y : ℤ) : ℝ) := sub_half_lt_round Y
  have hr2 : ((round Y : ℤ) : ℝ) ≤ Y + 1 / 2 := round_le_add_half Y
  have hs1 : M - 1 / 2 < ((round M : ℤ) : ℝ) := sub_half_lt_round M
  have hs2 : ((round M : ℤ) : ℝ) ≤ M + 1 / 2 := round_le_add_half M
  have hup : a * ((round X : ℤ) : ℝ) + (1 - a) * ((round Y : ℤ) : ℝ) ≤ M + 1 / 2 := by
    have h1 : a * ((round X : ℤ) : ℝ) ≤ a * (X + 1 / 2) :=
      mul_le_mul_of_nonneg_left hp2 ha0.le
    have h2 : (1 - a) * ((round Y : ℤ) : ℝ) ≤ (1 - a) * (Y + 1 / 2) :=
      mul_le_mul_of_nonneg_left hr2 (by linarith)
    have : a * (X + 1 / 2) + (1 - a) * (Y + 1 / 2) = M + 1 / 2 := by rw [hMdef]; ring
    linarith
  have hlow : M - 1 / 2 < a * ((round X : ℤ) : ℝ) + (1 - a) * ((round Y : ℤ) : ℝ) := by
    have h1 : a * (X - 1 / 2) < a * ((round X : ℤ) : ℝ) := mul_lt_mul_of_pos_left hp1 ha0
    have h2 : (1 - a) * (Y - 1 / 2) < (1 - a) * ((round Y : ℤ) : ℝ) :=
      mul_lt_mul_of_pos_left hr1 (by linarith)
    have : a * (X - 1 / 2) + (1 - a) * (Y - 1 / 2) = M - 1 / 2 := by rw [hMdef]; ring
    linarith
  have hrepr : a * gridRound δ x + (1 - a) * gridRound δ y - gridRound δ (a * x + (1 - a) * y)
      = δ * (a * ((round X : ℤ) : ℝ) + (1 - a) * ((round Y : ℤ) : ℝ)
          - ((round M : ℤ) : ℝ)) := by
    simp only [gridRound, hM, ← hX, ← hY]
    ring
  rw [hrepr, abs_mul, abs_of_pos hδ]
  have hbound : |a * ((round X : ℤ) : ℝ) + (1 - a) * ((round Y : ℤ) : ℝ)
      - ((round M : ℤ) : ℝ)| < 1 := by
    rw [abs_lt]
    constructor <;> linarith
  nlinarith [hbound]

/-- **Arithmetic half of the denominator law.**  For an interpolation weight with
denominator `q` the discrepancy is a multiple of `δ/q` and strictly below `δ`,
hence at most `(1 − 1/q)·δ`. -/
lemma discrepancy_le_denominator {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hk0 : 0 < k) (hkq : k < q)
    (x y : ℝ) :
    |(k / q : ℝ) * gridRound δ x + (1 - (k / q : ℝ)) * gridRound δ y
      - gridRound δ ((k / q : ℝ) * x + (1 - (k / q : ℝ)) * y)| ≤ δ * (1 - 1 / q) := by
  have hq0 : 0 < q := lt_trans hk0 hkq
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq0
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk0
  have hkqR : (k : ℝ) < (q : ℝ) := by exact_mod_cast hkq
  have ha0 : (0 : ℝ) < (k / q : ℝ) := by positivity
  have ha1 : (k / q : ℝ) < 1 := by rw [div_lt_one hqR]; exact hkqR
  have hlt := discrepancy_lt_mesh hδ ha0 ha1 x y
  -- the discrepancy is `δ/q` times an integer
  set J : ℤ := (k : ℤ) * round (x / δ) + ((q : ℤ) - (k : ℤ)) * round (y / δ)
      - (q : ℤ) * round (((k / q : ℝ) * x + (1 - (k / q : ℝ)) * y) / δ) with hJ
  have hrepr : (k / q : ℝ) * gridRound δ x + (1 - (k / q : ℝ)) * gridRound δ y
      - gridRound δ ((k / q : ℝ) * x + (1 - (k / q : ℝ)) * y) = δ / q * (J : ℝ) := by
    simp only [gridRound, hJ]
    push_cast
    field_simp
  rw [hrepr] at hlt ⊢
  rw [abs_mul, abs_of_pos (by positivity : (0:ℝ) < δ / q)] at hlt ⊢
  have hJlt : |(J : ℝ)| < (q : ℝ) := by
    by_contra hcon
    push_neg at hcon
    have : δ / q * (q : ℝ) ≤ δ / q * |(J : ℝ)| :=
      mul_le_mul_of_nonneg_left hcon (by positivity)
    rw [div_mul_cancel₀ _ (ne_of_gt hqR)] at this
    linarith
  have hJle : |J| ≤ (q : ℤ) - 1 := by
    have : |J| < (q : ℤ) := by
      have : ((|J| : ℤ) : ℝ) < ((q : ℤ) : ℝ) := by
        push_cast [Int.cast_abs]
        exact_mod_cast hJlt
      exact_mod_cast this
    omega
  have hJleR : |(J : ℝ)| ≤ (q : ℝ) - 1 := by
    have : ((|J| : ℤ) : ℝ) ≤ (((q : ℤ) - 1 : ℤ) : ℝ) := by exact_mod_cast hJle
    push_cast [Int.cast_abs] at this
    exact this
  calc δ / q * |(J : ℝ)| ≤ δ / q * ((q : ℝ) - 1) :=
        mul_le_mul_of_nonneg_left hJleR (by positivity)
    _ = δ * (1 - 1 / q) := by field_simp

/-- **The denominator law.**  For a convex `L`-Lipschitz loss, the `δ`-grid
quantized landscape satisfies the convexity inequality at every interpolation
weight `a = k/q` with defect at most `(1 − 1/q)·L·δ = (1 − 1/q)·2·L·r`.

Balanced weights (`q = 2`) lose only `L·r`; the general bound `2·L·r` is
approached only along weights of large denominator. -/
theorem gridRound_defect_denominator {L : NNReal} {f : ℝ → ℝ} (hf : ConvexOn ℝ univ f)
    (hL : LipschitzWith L f) {δ : ℝ} (hδ : 0 < δ) {k q : ℕ} (hq : 0 < q) (hk : k ≤ q) (x y : ℝ) :
    f (gridRound δ ((k / q : ℝ) * x + (1 - (k / q : ℝ)) * y))
      ≤ (k / q : ℝ) * f (gridRound δ x) + (1 - (k / q : ℝ)) * f (gridRound δ y)
        + (L : ℝ) * (δ * (1 - 1 / q)) := by
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hq1 : 1 / (q : ℝ) ≤ 1 := by
    rw [div_le_one hqR]
    exact_mod_cast hq
  have hnonneg : 0 ≤ (L : ℝ) * (δ * (1 - 1 / q)) := by
    have : (0 : ℝ) ≤ 1 - 1 / q := by linarith
    have := L.coe_nonneg
    positivity
  rcases Nat.eq_zero_or_pos k with hk0 | hk0
  · subst hk0
    simp only [Nat.cast_zero, zero_div, zero_mul, sub_zero, one_mul, zero_add]
    linarith
  rcases eq_or_lt_of_le hk with hkq | hkq
  · subst hkq
    rw [div_self (ne_of_gt hqR)]
    simp only [one_mul, sub_self, zero_mul, add_zero]
    linarith
  -- the generic case `0 < k < q`
  set a : ℝ := (k / q : ℝ) with ha
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk0
  have ha0 : 0 < a := by rw [ha]; positivity
  have ha1 : a < 1 := by
    rw [ha, div_lt_one hqR]
    exact_mod_cast hkq
  set u : ℝ := gridRound δ x with hu
  set v : ℝ := gridRound δ y with hv
  set w : ℝ := gridRound δ (a * x + (1 - a) * y) with hw
  have hmem : a * x + (1 - a) * y ∈ Set.Icc (min x y) (max x y) := by
    constructor
    · have h1 : min x y ≤ x := min_le_left x y
      have h2 : min x y ≤ y := min_le_right x y
      nlinarith
    · have h1 : x ≤ max x y := le_max_left x y
      have h2 : y ≤ max x y := le_max_right x y
      nlinarith
  have hwmem : w ∈ Set.Icc (min u v) (max u v) := by
    have hmono := gridRound_monotone hδ
    constructor
    · rw [hu, hv, ← hmono.map_min]
      exact hmono hmem.1
    · rw [hu, hv, ← hmono.map_max]
      exact hmono hmem.2
  have hdef := convex_defect_le_discrepancy hf hL (a := a) hwmem
  have hdisc := discrepancy_le_denominator hδ hk0 hkq x y
  have hmul : (L : ℝ) * |a * u + (1 - a) * v - w| ≤ (L : ℝ) * (δ * (1 - 1 / q)) :=
    mul_le_mul_of_nonneg_left hdisc L.coe_nonneg
  linarith

/-- **Sharpness of the denominator law at `a = (q−1)/q`.**  The witness family of
Section 3 realises the bound exactly: for the target loss and the weight
`1 − 1/n`, the defect equals `(1 − 1/n)·δ`. -/
theorem targetLoss_defect_eq {δ : ℝ} (hδ : 0 < δ) {n : ℕ} (hn : 3 ≤ n) :
    targetLoss δ (gridRound δ ((1 - 1 / (n : ℝ)) * (δ / 2) + (1 / (n : ℝ)) * (-(δ / 2))))
        - ((1 - 1 / (n : ℝ)) * targetLoss δ (gridRound δ (δ / 2))
          + (1 / (n : ℝ)) * targetLoss δ (gridRound δ (-(δ / 2))))
      = δ * (1 - 1 / (n : ℝ)) := by
  have hn1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast (by omega : 1 ≤ n)
  have hn0 : (0 : ℝ) < (n : ℝ) := by linarith
  have hne : (n : ℝ) ≠ 0 := ne_of_gt hn0
  have hcomb : (1 - 1 / (n : ℝ)) * (δ / 2) + (1 / (n : ℝ)) * (-(δ / 2)) = δ / 2 - δ / n := by
    field_simp
    ring
  rw [hcomb, gridRound_just_below_half hδ hn, gridRound_half hδ, gridRound_neg_half hδ]
  simp only [targetLoss]
  rw [show (0 : ℝ) - δ = -δ by ring, abs_neg, abs_of_pos hδ, show δ - δ = (0:ℝ) by ring,
    abs_zero]
  field_simp
  ring

end DenominatorLaw

end QuantizedWeightLattices.SharpConstant