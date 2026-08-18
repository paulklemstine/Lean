/-
Copyright (c) 2026. Phase A Research Mission: Bridge NumberTheory ↔ Machine Learning.

# Arithmetic Geometry of Transformer Weight Lattices, I: the analytic core

Quantizing a transformer's weight tensor means replacing each real entry by the
nearest point of a *modular lattice grid* `δ·ℤ ⊆ ℝ` (in practice: an integer
`INT-k` code times a scale).  This file proves that this operation preserves the
**global convexity invariants** of the loss landscape *quantitatively*:

* the quantized loss `f ∘ Q` is `2Lr`-approximately convex (`quantized_approxConvex`);
* the best lattice weight is within `L·r` of the *global* optimum
  (`quantized_min_gap`), where `r` is the covering radius of the grid;
* under quadratic growth the lattice minimiser is `√(2Lr/μ)`-close to the true
  minimiser (`quantized_minimizer_close`);
* sublevel sets of the quantized loss are sandwiched between two genuinely convex
  sets (`sublevel_sandwich`), so all sublevel-convexity invariants survive up to
  the covering radius;
* **capstone / reverse transfer**: if along a tower of refining lattices the
  quantized landscapes are `εₘ`-approximately convex with `εₘ → 0`, then the
  underlying continuous loss is *exactly* convex (`convexOn_of_approxConvex_tower`).
  Convexity is therefore an invariant certifiable from finite, quantized data.

The arithmetic (modular / CRT / lattice-tower) layer lives in
`Bridges.QuantizedWeightLatticesModular`.
-/

import Mathlib

namespace QuantizedWeightLattices

open Set Filter Topology

/-! ## Section 1: the scalar grid quantizer `δ·ℤ` -/

/-- Rounding a real number to the nearest point of the lattice `δ·ℤ`. -/
noncomputable def gridRound (δ x : ℝ) : ℝ := δ * (round (x / δ) : ℤ)

lemma gridRound_mem_zmultiples (δ x : ℝ) :
    gridRound δ x ∈ AddSubgroup.zmultiples δ := by
  refine ⟨round (x / δ), ?_⟩
  simp [gridRound, zsmul_eq_mul, mul_comm]

/-- **Covering radius of the grid**: rounding moves a weight by at most `δ/2`. -/
lemma gridRound_error {δ : ℝ} (hδ : 0 < δ) (x : ℝ) : |gridRound δ x - x| ≤ δ / 2 := by
  have hne : δ ≠ 0 := ne_of_gt hδ
  have hx : gridRound δ x - x = δ * ((round (x / δ) : ℝ) - x / δ) := by
    simp only [gridRound]; field_simp
  have h2 : |(round (x / δ) : ℝ) - x / δ| ≤ 1 / 2 := by
    rw [abs_sub_comm]; exact abs_sub_round (x / δ)
  rw [hx, abs_mul, abs_of_pos hδ]
  nlinarith [abs_nonneg ((round (x / δ) : ℝ) - x / δ)]

/-- Grid points are exactly the fixed points of the rounding map. -/
lemma gridRound_eq_self_iff {δ : ℝ} (hδ : δ ≠ 0) (y : ℝ) :
    gridRound δ y = y ↔ y ∈ AddSubgroup.zmultiples δ := by
  constructor
  · intro h; rw [← h]; exact gridRound_mem_zmultiples δ y
  · rintro ⟨k, hk⟩
    have hk' : y = δ * (k : ℝ) := by
      rw [← hk]; simp [zsmul_eq_mul, mul_comm]
    subst hk'
    simp [gridRound, mul_div_cancel_left₀ _ hδ]

/-- Quantization is idempotent: re-quantizing an already quantized weight is a no-op. -/
lemma gridRound_idem {δ : ℝ} (hδ : δ ≠ 0) (x : ℝ) :
    gridRound δ (gridRound δ x) = gridRound δ x :=
  (gridRound_eq_self_iff hδ _).2 (gridRound_mem_zmultiples δ x)

/-! ## Section 2: quantizing a whole weight tensor

A transformer weight tensor is a function `ι → ℝ` for a finite index type `ι`
(e.g. `ι = Fin dout × Fin din` for one matrix, or a sigma type over all layers).
`ι → ℝ` carries the sup norm, the natural norm for entrywise quantization. -/

section Tensor

variable {ι : Type*} [Fintype ι]

/-- Entrywise quantization of a weight tensor onto the lattice `(δ·ℤ)^ι`. -/
noncomputable def quantizeTensor (δ : ℝ) (W : ι → ℝ) : ι → ℝ := fun i => gridRound δ (W i)

omit [Fintype ι] in
lemma quantizeTensor_mem_lattice (δ : ℝ) (W : ι → ℝ) (i : ι) :
    quantizeTensor δ W i ∈ AddSubgroup.zmultiples δ :=
  gridRound_mem_zmultiples δ (W i)

/-- **Uniform quantization error**: the tensor moves by at most `δ/2` in sup norm. -/
lemma quantizeTensor_error {δ : ℝ} (hδ : 0 < δ) (W : ι → ℝ) :
    ‖quantizeTensor δ W - W‖ ≤ δ / 2 := by
  refine (pi_norm_le_iff_of_nonneg (by positivity)).2 fun i => ?_
  simpa [quantizeTensor, Real.norm_eq_abs] using gridRound_error hδ (W i)

omit [Fintype ι] in
lemma quantizeTensor_idem {δ : ℝ} (hδ : δ ≠ 0) (W : ι → ℝ) :
    quantizeTensor δ (quantizeTensor δ W) = quantizeTensor δ W := by
  funext i; exact gridRound_idem hδ (W i)

end Tensor

/-! ## Section 3: abstract quantizers -/

/-- A `Quantizer` on a normed space is any map whose displacement is uniformly
bounded by its `radius` (the covering radius of the target lattice).  Nearest-point
projection to a full-rank lattice is the motivating example. -/
structure Quantizer (E : Type*) [SeminormedAddCommGroup E] where
  /-- the quantization map -/
  toFun : E → E
  /-- covering radius of the target lattice -/
  radius : ℝ
  radius_nonneg : 0 ≤ radius
  error_le : ∀ x, ‖toFun x - x‖ ≤ radius

/-- The entrywise grid quantizer as a `Quantizer` with covering radius `δ/2`. -/
noncomputable def gridQuantizer {ι : Type*} [Fintype ι] {δ : ℝ} (hδ : 0 < δ) :
    Quantizer (ι → ℝ) where
  toFun := quantizeTensor δ
  radius := δ / 2
  radius_nonneg := by positivity
  error_le := quantizeTensor_error hδ

/-! ## Section 4: approximate convexity -/

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- `ApproxConvexOn ε s g`: convexity up to an additive defect `ε`. -/
def ApproxConvexOn (ε : ℝ) (s : Set E) (g : E → ℝ) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → ∀ ⦃a b : ℝ⦄, 0 ≤ a → 0 ≤ b → a + b = 1 →
    g (a • x + b • y) ≤ a * g x + b * g y + ε

lemma ApproxConvexOn.mono {ε ε' : ℝ} {s : Set E} {g : E → ℝ}
    (h : ApproxConvexOn ε s g) (hle : ε ≤ ε') : ApproxConvexOn ε' s g := by
  intro x hx y hy a b ha hb hab
  exact (h hx hy ha hb hab).trans (by linarith)

/-- Exact convexity is the `ε = 0` case. -/
lemma ConvexOn.approxConvexOn {s : Set E} {g : E → ℝ} (h : ConvexOn ℝ s g) :
    ApproxConvexOn 0 s g := by
  intro x hx y hy a b ha hb hab
  simpa using h.2 hx hy ha hb hab

/-- Conversely, a `0`-approximately convex function on a convex set is convex. -/
lemma ApproxConvexOn.convexOn_of_zero {s : Set E} {g : E → ℝ} (hs : Convex ℝ s)
    (h : ApproxConvexOn 0 s g) : ConvexOn ℝ s g :=
  ⟨hs, fun _ hx _ hy _ _ ha hb hab => by simpa using h hx hy ha hb hab⟩

/-! ## Section 5: transfer of convexity through quantization -/

section Transfer

variable {L : NNReal} {f : E → ℝ}

omit [NormedSpace ℝ E] in
lemma abs_sub_le_lipschitz (hL : LipschitzWith L f) (x y : E) :
    |f x - f y| ≤ (L : ℝ) * ‖x - y‖ := by
  have h := hL.dist_le_mul x y
  rwa [Real.dist_eq, dist_eq_norm] at h

omit [NormedSpace ℝ E] in
/-- Quantizing a weight can increase the loss by at most `L·r`. -/
lemma loss_quantize_le (hL : LipschitzWith L f) (Q : Quantizer E) (x : E) :
    f (Q.toFun x) ≤ f x + (L : ℝ) * Q.radius := by
  have h1 : |f (Q.toFun x) - f x| ≤ (L : ℝ) * ‖Q.toFun x - x‖ := abs_sub_le_lipschitz hL _ _
  have h2 : (L : ℝ) * ‖Q.toFun x - x‖ ≤ (L : ℝ) * Q.radius :=
    mul_le_mul_of_nonneg_left (Q.error_le x) L.coe_nonneg
  have h3 := (abs_le.1 (h1.trans h2)).2
  linarith

omit [NormedSpace ℝ E] in
/-- ... and can decrease it by at most `L·r`. -/
lemma loss_le_quantize (hL : LipschitzWith L f) (Q : Quantizer E) (x : E) :
    f x ≤ f (Q.toFun x) + (L : ℝ) * Q.radius := by
  have h1 : |f (Q.toFun x) - f x| ≤ (L : ℝ) * ‖Q.toFun x - x‖ := abs_sub_le_lipschitz hL _ _
  have h2 : (L : ℝ) * ‖Q.toFun x - x‖ ≤ (L : ℝ) * Q.radius :=
    mul_le_mul_of_nonneg_left (Q.error_le x) L.coe_nonneg
  have h3 := (abs_le.1 (h1.trans h2)).1
  linarith

/-- **Theorem A (convexity is preserved up to the covering radius).**
If the continuous loss `f` is convex and `L`-Lipschitz, the quantized loss
`f ∘ Q` obtained by projecting weights onto the lattice is `2·L·r`-approximately
convex, where `r` is the covering radius.  For the `δ`-grid this defect is `L·δ`. -/
theorem quantized_approxConvex (hf : ConvexOn ℝ univ f) (hL : LipschitzWith L f)
    (Q : Quantizer E) : ApproxConvexOn (2 * (L : ℝ) * Q.radius) univ (f ∘ Q.toFun) := by
  intro x _ y _ a b ha hb hab
  have hmid : f (Q.toFun (a • x + b • y)) ≤ f (a • x + b • y) + (L : ℝ) * Q.radius :=
    loss_quantize_le hL Q _
  have hconv : f (a • x + b • y) ≤ a * f x + b * f y :=
    hf.2 (mem_univ x) (mem_univ y) ha hb hab
  have hx : f x ≤ f (Q.toFun x) + (L : ℝ) * Q.radius := loss_le_quantize hL Q x
  have hy : f y ≤ f (Q.toFun y) + (L : ℝ) * Q.radius := loss_le_quantize hL Q y
  have hax : a * f x ≤ a * (f (Q.toFun x) + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left hx ha
  have hby : b * f y ≤ b * (f (Q.toFun y) + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left hy hb
  have hab' : a * ((L : ℝ) * Q.radius) + b * ((L : ℝ) * Q.radius) = (L : ℝ) * Q.radius := by
    have : a * ((L : ℝ) * Q.radius) + b * ((L : ℝ) * Q.radius)
        = (a + b) * ((L : ℝ) * Q.radius) := by ring
    rw [this, hab, one_mul]
  simp only [Function.comp_apply]
  nlinarith [hmid, hconv, hax, hby, hab']

omit [NormedSpace ℝ E] in
/-- **Theorem B (no global optimum is lost).**  If `x₀` is a global minimiser of an
`L`-Lipschitz loss, then the *lattice point* `Q x₀` is an `L·r`-approximate global
minimiser: no real weight configuration beats it by more than `L·r`. -/
theorem quantized_optimum_gap (hL : LipschitzWith L f) (Q : Quantizer E) {x₀ : E}
    (hmin : ∀ x, f x₀ ≤ f x) (x : E) : f (Q.toFun x₀) ≤ f x + (L : ℝ) * Q.radius :=
  (loss_quantize_le hL Q x₀).trans (by linarith [hmin x])

omit [NormedSpace ℝ E] in
/-- **Theorem C (minimiser localisation).**  If the loss has quadratic growth of
modulus `μ > 0` around its minimiser `x₀` (the standard consequence of strong
convexity) then *any* loss-minimising lattice point `ŵ` lies within
`√(2Lr/μ)` of `x₀`: quantization cannot relocate the basin of attraction. -/
theorem quantized_minimizer_close {μ : ℝ} (hμ : 0 < μ) {x₀ ŵ : E}
    (hL : LipschitzWith L f) (Q : Quantizer E)
    (hgrowth : ∀ x, μ / 2 * ‖x - x₀‖ ^ 2 ≤ f x - f x₀)
    (hlat : ∀ x, f ŵ ≤ f (Q.toFun x)) :
    ‖ŵ - x₀‖ ≤ Real.sqrt (2 * (L : ℝ) * Q.radius / μ) := by
  have h1 : f ŵ ≤ f (Q.toFun x₀) := hlat x₀
  have h2 : f (Q.toFun x₀) ≤ f x₀ + (L : ℝ) * Q.radius := loss_quantize_le hL Q x₀
  have h3 : μ / 2 * ‖ŵ - x₀‖ ^ 2 ≤ f ŵ - f x₀ := hgrowth ŵ
  have h4 : μ / 2 * ‖ŵ - x₀‖ ^ 2 ≤ (L : ℝ) * Q.radius := by linarith
  have h5 : ‖ŵ - x₀‖ ^ 2 ≤ 2 * (L : ℝ) * Q.radius / μ := by
    rw [le_div_iff₀ hμ]; nlinarith
  calc ‖ŵ - x₀‖ = Real.sqrt (‖ŵ - x₀‖ ^ 2) := (Real.sqrt_sq (norm_nonneg _)).symm
    _ ≤ Real.sqrt (2 * (L : ℝ) * Q.radius / μ) := Real.sqrt_le_sqrt h5

/-- **Theorem D (sublevel sandwich).**  The sublevel sets of the quantized loss are
trapped between two *convex* sublevel sets of the continuous loss, at distance
`L·r` in level.  Hence every convexity invariant of the landscape's sublevel
filtration (connectedness, star-shapedness, contractibility of level sets, …) is
preserved up to a level shift of `L·r`. -/
theorem sublevel_sandwich (hf : ConvexOn ℝ univ f) (hL : LipschitzWith L f)
    (Q : Quantizer E) (c : ℝ) :
    Convex ℝ {x : E | f x ≤ c - (L : ℝ) * Q.radius} ∧
      {x : E | f x ≤ c - (L : ℝ) * Q.radius} ⊆ {x : E | f (Q.toFun x) ≤ c} ∧
      {x : E | f (Q.toFun x) ≤ c} ⊆ {x : E | f x ≤ c + (L : ℝ) * Q.radius} ∧
      Convex ℝ {x : E | f x ≤ c + (L : ℝ) * Q.radius} := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · simpa using hf.convex_le (c - (L : ℝ) * Q.radius)
  · intro x hx
    have := loss_quantize_le hL Q x
    simp only [mem_setOf_eq] at hx ⊢
    linarith
  · intro x hx
    have := loss_le_quantize hL Q x
    simp only [mem_setOf_eq] at hx ⊢
    linarith
  · simpa using hf.convex_le (c + (L : ℝ) * Q.radius)

end Transfer

/-! ## Section 6: the capstone — exact convexity from the lattice tower -/

/-- **Theorem E (reverse transfer / projective limit of the lattice tower).**
Let `f` be an `L`-Lipschitz loss and let `Qₘ` be a tower of quantizers whose
covering radii tend to `0` (e.g. the grids `δ/m·ℤ` along a divisibility tower).
If each quantized landscape `f ∘ Qₘ` is `εₘ`-approximately convex with `εₘ → 0`,
then the *continuous* loss is exactly convex.

This is the converse direction of Theorem A: global convexity of the real-valued
landscape is an invariant that can be certified purely from finitely-supported
quantized measurements. -/
theorem convexOn_of_approxConvex_tower {L : NNReal} {f : E → ℝ} (hL : LipschitzWith L f)
    (Q : ℕ → Quantizer E) (eps : ℕ → ℝ)
    (hr : Tendsto (fun m => (Q m).radius) atTop (𝓝 0))
    (heps : Tendsto eps atTop (𝓝 0))
    (hac : ∀ m, ApproxConvexOn (eps m) univ (f ∘ (Q m).toFun)) :
    ConvexOn ℝ univ f := by
  refine ⟨convex_univ, fun x _ y _ a b ha hb hab => ?_⟩
  -- the defect sequence
  set A : ℝ := a * f x + b * f y with hA
  have key : ∀ m, f (a • x + b • y) ≤ A + (eps m + 2 * (L : ℝ) * (Q m).radius) := by
    intro m
    have h0 := hac m (mem_univ x) (mem_univ y) ha hb hab
    simp only [Function.comp_apply] at h0
    have hmid : f (a • x + b • y) ≤ f ((Q m).toFun (a • x + b • y)) + (L : ℝ) * (Q m).radius :=
      loss_le_quantize hL (Q m) _
    have hx : f ((Q m).toFun x) ≤ f x + (L : ℝ) * (Q m).radius := loss_quantize_le hL (Q m) x
    have hy : f ((Q m).toFun y) ≤ f y + (L : ℝ) * (Q m).radius := loss_quantize_le hL (Q m) y
    have hax : a * f ((Q m).toFun x) ≤ a * (f x + (L : ℝ) * (Q m).radius) :=
      mul_le_mul_of_nonneg_left hx ha
    have hby : b * f ((Q m).toFun y) ≤ b * (f y + (L : ℝ) * (Q m).radius) :=
      mul_le_mul_of_nonneg_left hy hb
    have hsum : a * ((L : ℝ) * (Q m).radius) + b * ((L : ℝ) * (Q m).radius)
        = (L : ℝ) * (Q m).radius := by
      have : a * ((L : ℝ) * (Q m).radius) + b * ((L : ℝ) * (Q m).radius)
          = (a + b) * ((L : ℝ) * (Q m).radius) := by ring
      rw [this, hab, one_mul]
    rw [hA]
    nlinarith [hmid, h0, hax, hby, hsum]
  have hlim : Tendsto (fun m => A + (eps m + 2 * (L : ℝ) * (Q m).radius)) atTop (𝓝 A) := by
    have h1 : Tendsto (fun m => eps m + 2 * (L : ℝ) * (Q m).radius) atTop (𝓝 0) := by
      simpa using heps.add ((hr.const_mul (2 * (L : ℝ))).congr (fun m => by ring))
    simpa using (tendsto_const_nhds (x := A) (f := atTop (α := ℕ))).add h1
  exact ge_of_tendsto hlim (Eventually.of_forall key)

/-! ## Section 7: the concrete grid tower -/

section GridTower

variable {ι : Type*} [Fintype ι]

/-- Refining the grid: for `m ∣ m'` (both positive) the coarse lattice `(δ/m)·ℤ`
is contained in the fine lattice `(δ/m')·ℤ`.  This is the divisibility tower of
quantization grids. -/
theorem zmultiples_mono_of_dvd {δ : ℝ} {m m' : ℕ} (hm : 0 < m) (hm' : 0 < m') (hdvd : m ∣ m') :
    AddSubgroup.zmultiples (δ / m) ≤ AddSubgroup.zmultiples (δ / m') := by
  obtain ⟨c, rfl⟩ := hdvd
  have hc : (c : ℝ) ≠ 0 := by
    rcases Nat.eq_zero_or_pos c with h | h
    · simp [h] at hm'
    · exact Nat.cast_ne_zero.2 h.ne'
  have hm0 : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.2 hm.ne'
  rintro _ ⟨k, rfl⟩
  refine ⟨k * c, ?_⟩
  simp only [zsmul_eq_mul, Int.cast_mul, Int.cast_natCast, Nat.cast_mul]
  field_simp

/-- The covering radius of the `m`-th grid in the tower `δ/(m+1)` tends to `0`. -/
theorem gridTower_radius_tendsto_zero (δ : ℝ) :
    Tendsto (fun m : ℕ => δ / (m + 1) / 2) atTop (𝓝 0) := by
  have h : Tendsto (fun m : ℕ => δ / (m + 1)) atTop (𝓝 0) := by
    simpa using tendsto_const_nhds.div_atTop
      (tendsto_atTop_add_const_right atTop (1 : ℝ) tendsto_natCast_atTop_atTop)
  simpa using h.div_const 2

/-- The tower of grid quantizers on a weight tensor space, `Qₘ` with mesh `δ/(m+1)`. -/
noncomputable def gridTower (δ : ℝ) (hδ : 0 < δ) (m : ℕ) : Quantizer (ι → ℝ) :=
  gridQuantizer (ι := ι) (δ := δ / (m + 1)) (by positivity)

lemma gridTower_radius (δ : ℝ) (hδ : 0 < δ) (m : ℕ) :
    (gridTower (ι := ι) δ hδ m).radius = δ / (m + 1) / 2 := rfl

/-- **Corollary (tower version of Theorem A).**  Along the refining tower the
convexity defect of the quantized transformer landscape is `L·δ/(m+1)` and hence
tends to zero: the quantized loss landscapes converge to a convex landscape. -/
theorem gridTower_defect_tendsto_zero {L : NNReal} (δ : ℝ) (hδ : 0 < δ) :
    Tendsto (fun m : ℕ => 2 * (L : ℝ) * (gridTower (ι := ι) δ hδ m).radius) atTop (𝓝 0) := by
  simpa using ((gridTower_radius_tendsto_zero δ).const_mul (2 * (L : ℝ)))

/-- **Corollary (Theorem E on the concrete grid tower).**  If for every mesh
`δ/(m+1)` the entrywise-quantized transformer loss is `εₘ`-approximately convex
with `εₘ → 0`, then the continuous loss is convex. -/
theorem convexOn_of_grid_approxConvex {L : NNReal} {f : (ι → ℝ) → ℝ} (hL : LipschitzWith L f)
    {δ : ℝ} (hδ : 0 < δ) (eps : ℕ → ℝ) (heps : Tendsto eps atTop (𝓝 0))
    (hac : ∀ m : ℕ, ApproxConvexOn (eps m) univ (f ∘ quantizeTensor (δ / (m + 1)))) :
    ConvexOn ℝ univ f := by
  refine convexOn_of_approxConvex_tower hL (gridTower (ι := ι) δ hδ) eps ?_ heps ?_
  · simpa [gridTower_radius] using gridTower_radius_tendsto_zero δ
  · intro m; exact hac m

end GridTower

end QuantizedWeightLattices