/-
Copyright (c) 2026. Phase A Research Mission: Bridge NumberTheory ↔ Machine Learning.

# Arithmetic Geometry of Transformer Weight Lattices, III: sharpness and density

Adversarial (Stage 4) companion to the two previous files.  Two questions are
answered here.

**Is the convexity-preservation theorem vacuous?**  No.  For the archetypal convex
`1`-Lipschitz loss `x ↦ |x|` the `δ`-grid quantized landscape is *provably not
convex*: its convexity defect is at least `δ/2` (`quantized_abs_defect_ge`), while
Theorem A bounds it by `δ`.  Hence the constant `2·L·r` of Theorem A is sharp up
to a factor of two (`defect_bound_sharp`), and the phrase "convexity is preserved"
must be read in the quantitative, approximate sense — exact convexity really is
destroyed (`quantized_abs_not_convex`).  Moreover, over the *whole* class of
radius-`r` quantizers the constant `2·L·r` is exactly optimal
(`abstract_defect_bound_optimal`): the residual factor-two question concerns only
nearest-point projections.

**How rich is the arithmetic of the codebook tower?**  The `m`-level codebooks are
the torsion subgroups of the weight torus `ℝ/δℤ`; they form a divisibility tower
with index `m'/m` (`torsion_card_ratio`) whose union — the full torsion subgroup,
an avatar of `ℚ/ℤ` — is **dense** in the weight torus
(`dense_quantization_tower`).  This is the arithmetic mechanism behind the reverse
transfer theorem (Theorem E): the tower of finite codebooks sees all of weight
space in the limit.
-/

import Bridges.QuantizedWeightLatticesModular

namespace QuantizedWeightLattices.Sharp

open QuantizedWeightLattices QuantizedWeightLattices.Modular Set

/-! ## Section 1: the scalar quantizer and the model loss `|·|` -/

/-- The scalar grid quantizer on `ℝ` as an abstract `Quantizer`. -/
noncomputable def scalarQuantizer {δ : ℝ} (hδ : 0 < δ) : Quantizer ℝ where
  toFun := gridRound δ
  radius := δ / 2
  radius_nonneg := by positivity
  error_le := fun x => by simpa [Real.norm_eq_abs] using gridRound_error hδ x

lemma convexOn_abs_real : ConvexOn ℝ univ (fun x : ℝ => |x|) := by
  refine ⟨convex_univ, fun x _ y _ a b ha hb _ => ?_⟩
  calc |a • x + b • y| ≤ |a • x| + |b • y| := abs_add_le _ _
    _ = a * |x| + b * |y| := by
        simp [abs_mul, abs_of_nonneg ha, abs_of_nonneg hb]

lemma lipschitzWith_abs_real : LipschitzWith 1 (fun x : ℝ => |x|) := by
  refine LipschitzWith.of_dist_le_mul fun x y => ?_
  simpa [Real.dist_eq] using abs_abs_sub_abs_le_abs_sub x y

/-! ## Section 2: three explicit rounding computations -/

lemma gridRound_two_fifths {δ : ℝ} (hδ : 0 < δ) : gridRound δ (2 * δ / 5) = 0 := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hx : 2 * δ / 5 / δ = 2 / 5 := by field_simp
  have hr : round ((2 : ℝ) / 5) = 0 := by
    rw [round_eq]
    norm_num
  simp [gridRound, hx, hr]

lemma gridRound_three_fifths {δ : ℝ} (hδ : 0 < δ) : gridRound δ (3 * δ / 5) = δ := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hx : 3 * δ / 5 / δ = 3 / 5 := by field_simp
  have hr : round ((3 : ℝ) / 5) = 1 := by
    rw [round_eq]
    norm_num
  simp [gridRound, hx, hr]

lemma gridRound_half {δ : ℝ} (hδ : 0 < δ) : gridRound δ (δ / 2) = δ := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hx : δ / 2 / δ = 1 / 2 := by field_simp
  simp [gridRound, hx]

/-! ## Section 3: the convexity defect of a quantized convex loss is genuinely positive -/

/-- **Theorem S1 (defect lower bound).**  For the convex `1`-Lipschitz loss `|·|`,
any approximate-convexity certificate for the `δ`-grid quantized landscape must
have defect at least `δ/2`.  The witnesses are the weights `2δ/5` and `3δ/5`,
which quantize to `0` and `δ` while their midpoint `δ/2` quantizes *upwards* to
`δ`: rounding creates a genuine bump of height `δ/2`. -/
theorem quantized_abs_defect_ge {δ ε : ℝ} (hδ : 0 < δ)
    (h : ApproxConvexOn ε univ (fun x : ℝ => |gridRound δ x|)) : δ / 2 ≤ ε := by
  have hmid : ((1 : ℝ) / 2) • (2 * δ / 5) + ((1 : ℝ) / 2) • (3 * δ / 5) = δ / 2 := by
    simp only [smul_eq_mul]; ring
  have key := h (mem_univ (2 * δ / 5)) (mem_univ (3 * δ / 5))
    (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num)
  rw [hmid] at key
  simp only [gridRound_half hδ, gridRound_two_fifths hδ, gridRound_three_fifths hδ,
    abs_of_pos hδ, abs_zero] at key
  linarith

/-- **Theorem S2 (quantization destroys exact convexity).**  The `δ`-grid quantized
version of the convex loss `|·|` is not convex for any positive mesh. -/
theorem quantized_abs_not_convex {δ : ℝ} (hδ : 0 < δ) :
    ¬ ConvexOn ℝ univ (fun x : ℝ => |gridRound δ x|) := by
  intro hconv
  have := quantized_abs_defect_ge hδ hconv.approxConvexOn
  linarith

/-- **Theorem S3 (sharpness of Theorem A up to a factor 2).**  For the loss `|·|`
and mesh `δ` the true convexity defect lies in `[δ/2, δ]`: the general bound
`2·L·r = δ` of `quantized_approxConvex` cannot be improved by more than a factor
of two. -/
theorem defect_bound_sharp {δ : ℝ} (hδ : 0 < δ) :
    ApproxConvexOn δ univ ((fun x : ℝ => |x|) ∘ (scalarQuantizer hδ).toFun) ∧
      ∀ ε : ℝ, ApproxConvexOn ε univ (fun x : ℝ => |gridRound δ x|) → δ / 2 ≤ ε := by
  refine ⟨?_, fun ε hε => quantized_abs_defect_ge hδ hε⟩
  have h := quantized_approxConvex convexOn_abs_real lipschitzWith_abs_real (scalarQuantizer hδ)
  have hrad : 2 * ((1 : NNReal) : ℝ) * (scalarQuantizer hδ).radius = δ := by
    show 2 * ((1 : NNReal) : ℝ) * (δ / 2) = δ
    push_cast
    ring
  rwa [hrad] at h

/-! ## Section 3b: for general quantizers the constant `2·L·r` is exactly optimal -/

/-- A quantizer of radius `r` that displaces every weight by exactly `r`, moving the
sample points `3r, 5r` *inwards* but their midpoint `4r` *outwards*.  It is a
legitimate `Quantizer` (its displacement never exceeds the radius) but it is not a
nearest-point lattice projection. -/
noncomputable def skewQuantizer {r : ℝ} (hr : 0 < r) : Quantizer ℝ where
  toFun := fun x => if x = 4 * r then 5 * r else x - r
  radius := r
  radius_nonneg := hr.le
  error_le := fun x => by
    rcases eq_or_ne x (4 * r) with h | h
    · have hval : ‖(if x = 4 * r then 5 * r else x - r) - x‖ = r := by
        rw [if_pos h, h, Real.norm_eq_abs, show 5 * r - 4 * r = r by ring, abs_of_pos hr]
      exact le_of_eq hval
    · have hval : ‖(if x = 4 * r then 5 * r else x - r) - x‖ = r := by
        rw [if_neg h, Real.norm_eq_abs, show x - r - x = -r by ring, abs_neg, abs_of_pos hr]
      exact le_of_eq hval

/-- **Theorem S6 (optimality of the constant in Theorem A).**  Over the class of all
quantizers of covering radius `r` the defect `2·L·r` of `quantized_approxConvex`
cannot be improved at all: the convex `1`-Lipschitz loss `|·|` composed with
`skewQuantizer` has defect exactly `2r`.  Together with Theorem S3 this delimits
the problem precisely — a possible improvement by a factor two would be a
statement about *nearest-point* quantizers, not about the abstract bound. -/
theorem abstract_defect_bound_optimal {r ε : ℝ} (hr : 0 < r)
    (h : ApproxConvexOn ε univ ((fun x : ℝ => |x|) ∘ (skewQuantizer hr).toFun)) :
    2 * r ≤ ε := by
  have h3 : (3 : ℝ) * r ≠ 4 * r := by intro hc; nlinarith
  have h5 : (5 : ℝ) * r ≠ 4 * r := by intro hc; nlinarith
  have e3 : (skewQuantizer hr).toFun (3 * r) = 2 * r := by
    show (if (3 * r : ℝ) = 4 * r then 5 * r else 3 * r - r) = 2 * r
    rw [if_neg h3]; ring
  have e5 : (skewQuantizer hr).toFun (5 * r) = 4 * r := by
    show (if (5 * r : ℝ) = 4 * r then 5 * r else 5 * r - r) = 4 * r
    rw [if_neg h5]; ring
  have e4 : (skewQuantizer hr).toFun (4 * r) = 5 * r := by
    show (if (4 * r : ℝ) = 4 * r then 5 * r else 4 * r - r) = 5 * r
    rw [if_pos rfl]
  have hmid : ((1 : ℝ) / 2) • (3 * r) + ((1 : ℝ) / 2) • (5 * r) = 4 * r := by
    simp only [smul_eq_mul]; ring
  have key := h (mem_univ (3 * r)) (mem_univ (5 * r))
    (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num)
  rw [hmid] at key
  simp only [Function.comp_apply, e3, e4, e5] at key
  rw [abs_of_pos (by linarith : (0:ℝ) < 5 * r), abs_of_pos (by linarith : (0:ℝ) < 2 * r),
      abs_of_pos (by linarith : (0:ℝ) < 4 * r)] at key
  linarith

/-! ## Section 4: the arithmetic tower of codebooks is dense in the weight torus -/

section Tower

variable (δ : ℝ)

/-- The union of all finite codebooks is exactly the torsion subgroup of the
weight torus `ℝ/δℤ`. -/
theorem torsion_eq_iUnion_codebooks :
    ((AddCommGroup.torsion (AddCircle δ) : AddSubgroup (AddCircle δ)) : Set (AddCircle δ))
      = ⋃ m : {m : ℕ // 0 < m}, {x : AddCircle δ | (m : ℕ) • x = 0} := by
  ext x
  simp only [SetLike.mem_coe, AddCommGroup.mem_torsion, isOfFinAddOrder_iff_nsmul_eq_zero,
    mem_iUnion, mem_setOf_eq, Subtype.exists]
  constructor
  · rintro ⟨n, hn, hx⟩; exact ⟨n, hn, hx⟩
  · rintro ⟨n, hn, hx⟩; exact ⟨n, hn, hx⟩

/-- **Theorem S4 (arithmetic index of the refinement tower).**  Refining the
precision from `m` to a multiple `m'` multiplies the codebook size by exactly the
index `m'/m` of the corresponding torsion subgroups. -/
theorem torsion_card_ratio (hδ : 0 < δ) {m m' : ℕ} (hm : 0 < m) (hm' : 0 < m')
    (hdvd : m ∣ m') :
    Nat.card {x : AddCircle δ | (m' : ℕ) • x = 0}
      = (m' / m) * Nat.card {x : AddCircle δ | (m : ℕ) • x = 0} := by
  rw [nat_card_torsion δ m hδ hm, nat_card_torsion δ m' hδ hm']
  exact (Nat.div_mul_cancel hdvd).symm

/-- **Theorem S5 (density of the quantization tower).**  The union of all finite
codebooks is dense in the weight torus `ℝ/δℤ`.  Equivalently: every real weight is
approximated arbitrarily well by codes of sufficiently high precision — the
arithmetic reason why the approximate-convexity defects of the tower can be driven
to zero (Theorem E). -/
theorem dense_quantization_tower (hδ : 0 < δ) :
    Dense (⋃ m : {m : ℕ // 0 < m}, {x : AddCircle δ | (m : ℕ) • x = 0}) := by
  haveI : Fact (0 < δ) := ⟨hδ⟩
  rw [← torsion_eq_iUnion_codebooks δ, AddCircle.dense_addSubgroup_iff_ne_zmultiples]
  intro a ha hEq
  set n := addOrderOf a with hn
  have hnpos : 0 < n := Nat.pos_of_ne_zero ha
  -- the cyclic group generated by `a` is finite of size `n`
  have hcard : Nat.card (AddSubgroup.zmultiples a) = n := Nat.card_zmultiples a
  haveI hfin' : Finite ↥(AddSubgroup.zmultiples a) :=
    Nat.finite_of_card_ne_zero (by rw [hcard]; exact hnpos.ne')
  have hfin : ((AddSubgroup.zmultiples a : AddSubgroup (AddCircle δ)) :
      Set (AddCircle δ)).Finite := Set.toFinite _
  -- but the `(n+1)`-torsion already has `n+1` elements and sits inside it
  have hsub : {x : AddCircle δ | (n + 1 : ℕ) • x = 0} ⊆
      ((AddSubgroup.zmultiples a : AddSubgroup (AddCircle δ)) : Set (AddCircle δ)) := by
    intro x hx
    have hxtor : x ∈ AddCommGroup.torsion (AddCircle δ) := by
      rw [AddCommGroup.mem_torsion, isOfFinAddOrder_iff_nsmul_eq_zero]
      exact ⟨n + 1, Nat.succ_pos n, hx⟩
    rw [hEq] at hxtor
    exact hxtor
  have hcard' : Nat.card {x : AddCircle δ | (n + 1 : ℕ) • x = 0} = n + 1 :=
    nat_card_torsion δ (n + 1) hδ (Nat.succ_pos n)
  have h1 : ({x : AddCircle δ | (n + 1 : ℕ) • x = 0}).ncard ≤
      ((AddSubgroup.zmultiples a : AddSubgroup (AddCircle δ)) : Set (AddCircle δ)).ncard :=
    Set.ncard_le_ncard hsub hfin
  rw [← Nat.card_coe_set_eq, ← Nat.card_coe_set_eq, hcard'] at h1
  simp only [SetLike.coe_sort_coe, hcard] at h1
  omega
end Tower

end QuantizedWeightLattices.Sharp