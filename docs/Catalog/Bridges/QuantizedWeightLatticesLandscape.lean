/-
Copyright (c) 2026. Phase A Research Mission: Bridge NumberTheory ↔ Machine Learning.

# Arithmetic Geometry of Transformer Weight Lattices, IV: landscape invariants

Third cycle of the research loop.  Having established that grid quantization
perturbs convexity by at most `2·L·r` (file I), that the codebook is the torsion
of the weight torus (file II) and that the bound is sharp within a factor two
(file III), we now show that the *finer* invariants of the loss landscape also
survive quantization.

* `quadratic_growth_of_strongConvexOn` — strong convexity forces quadratic growth
  around a global minimiser (proved by an explicit limiting argument along
  `t = 1/(n+1)`).
* `strongConvex_quantized_minimizer_close` — consequently, for a strongly convex
  loss *every* lattice-optimal weight lies within `√(2Lr/μ)` of the true optimum.
* `quantized_approxStrongConvex` — the whole strong-convexity modulus `μ` is
  transported to the quantized landscape, with the same additive defect `2Lr`;
  in particular the curvature invariant `μ` itself is preserved exactly.
* `lattice_infimum_close` — the optimal value of the lattice-restricted problem
  and of the continuous problem differ by at most `L·r`.
-/

import Bridges.QuantizedWeightLatticesSharp

namespace QuantizedWeightLattices.Landscape

open QuantizedWeightLattices Set Filter Topology

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-! ## Section 1: strong convexity gives quadratic growth at the optimum -/

/-- **Theorem L1.**  If `f` is `μ`-strongly convex and attains its global minimum at
`x₀`, then it grows at least quadratically away from `x₀`.  The proof takes the
strong-convexity inequality along the segment `t • x + (1-t) • x₀` and lets
`t = 1/(n+1) → 0`. -/
theorem quadratic_growth_of_strongConvexOn {μ : ℝ} {f : E → ℝ} {x₀ : E}
    (hf : StrongConvexOn univ μ f) (hmin : ∀ x, f x₀ ≤ f x) (x : E) :
    μ / 2 * ‖x - x₀‖ ^ 2 ≤ f x - f x₀ := by
  set C : ℝ := μ / 2 * ‖x - x₀‖ ^ 2 with hC
  have key : ∀ n : ℕ, (1 - 1 / (n + 1 : ℝ)) * C ≤ f x - f x₀ := by
    intro n
    set t : ℝ := 1 / (n + 1 : ℝ) with ht
    have hn1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    have ht0 : 0 < t := by rw [ht]; positivity
    have ht1 : t ≤ 1 := by
      rw [ht, div_le_one hn1]
      linarith [Nat.cast_nonneg (α := ℝ) n]
    have h := hf.2 (mem_univ x) (mem_univ x₀) ht0.le (by linarith : (0 : ℝ) ≤ 1 - t)
      (by ring)
    have hlow := hmin (t • x + (1 - t) • x₀)
    simp only [smul_eq_mul] at h
    rw [← hC] at h
    have h2 : t * ((1 - t) * C) ≤ t * (f x - f x₀) := by nlinarith [hlow, h]
    exact le_of_mul_le_mul_left h2 ht0
  have hlim : Tendsto (fun n : ℕ => (1 - 1 / (n + 1 : ℝ)) * C) atTop (𝓝 ((1 - 0) * C)) := by
    exact ((tendsto_const_nhds.sub tendsto_one_div_add_atTop_nhds_zero_nat).mul
      tendsto_const_nhds)
  have := le_of_tendsto hlim (Eventually.of_forall key)
  simpa using this

/-- **Theorem L2 (basin localisation for strongly convex losses).**  For a
`μ`-strongly convex `L`-Lipschitz loss, every weight configuration that is optimal
*within the lattice* lies within `√(2Lr/μ)` of the true optimum: quantization
cannot move the basin of attraction. -/
theorem strongConvex_quantized_minimizer_close {μ : ℝ} (hμ : 0 < μ) {L : NNReal}
    {f : E → ℝ} {x₀ ŵ : E} (hf : StrongConvexOn univ μ f) (hL : LipschitzWith L f)
    (Q : Quantizer E) (hmin : ∀ x, f x₀ ≤ f x) (hlat : ∀ x, f ŵ ≤ f (Q.toFun x)) :
    ‖ŵ - x₀‖ ≤ Real.sqrt (2 * (L : ℝ) * Q.radius / μ) :=
  quantized_minimizer_close hμ hL Q (quadratic_growth_of_strongConvexOn hf hmin) hlat

/-! ## Section 2: the curvature modulus survives quantization -/

/-- `ApproxStrongConvexOn ε μ s g`: `μ`-strong convexity up to an additive defect `ε`. -/
def ApproxStrongConvexOn (ε μ : ℝ) (s : Set E) (g : E → ℝ) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → ∀ ⦃a b : ℝ⦄, 0 ≤ a → 0 ≤ b → a + b = 1 →
    g (a • x + b • y) ≤ a * g x + b * g y - a * b * (μ / 2 * ‖x - y‖ ^ 2) + ε

/-- **Theorem L3 (curvature transfer).**  Quantizing a `μ`-strongly convex
`L`-Lipschitz loss yields a landscape that is `μ`-strongly convex up to the same
additive defect `2·L·r` as in Theorem A.  The curvature modulus `μ` — a genuine
second-order invariant of the landscape — is transported unchanged; only a
zeroth-order defect of size `2Lr` appears. -/
theorem quantized_approxStrongConvex {μ : ℝ} {L : NNReal} {f : E → ℝ}
    (hf : StrongConvexOn univ μ f) (hL : LipschitzWith L f) (Q : Quantizer E) :
    ApproxStrongConvexOn (2 * (L : ℝ) * Q.radius) μ univ (f ∘ Q.toFun) := by
  intro x _ y _ a b ha hb hab
  have hmid : f (Q.toFun (a • x + b • y)) ≤ f (a • x + b • y) + (L : ℝ) * Q.radius :=
    loss_quantize_le hL Q _
  have hstrong := hf.2 (mem_univ x) (mem_univ y) ha hb hab
  simp only [smul_eq_mul] at hstrong
  have hx : f x ≤ f (Q.toFun x) + (L : ℝ) * Q.radius := loss_le_quantize hL Q x
  have hy : f y ≤ f (Q.toFun y) + (L : ℝ) * Q.radius := loss_le_quantize hL Q y
  have hax : a * f x ≤ a * (f (Q.toFun x) + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left hx ha
  have hby : b * f y ≤ b * (f (Q.toFun y) + (L : ℝ) * Q.radius) :=
    mul_le_mul_of_nonneg_left hy hb
  have hsum : a * ((L : ℝ) * Q.radius) + b * ((L : ℝ) * Q.radius) = (L : ℝ) * Q.radius := by
    have h : a * ((L : ℝ) * Q.radius) + b * ((L : ℝ) * Q.radius)
        = (a + b) * ((L : ℝ) * Q.radius) := by ring
    rw [h, hab, one_mul]
  simp only [Function.comp_apply]
  nlinarith [hmid, hstrong, hax, hby, hsum]

/-! ## Section 3: the optimal value is preserved -/

omit [NormedSpace ℝ E] in
/-- **Theorem L4 (optimal-value stability).**  The optimum of the lattice-restricted
training problem and the optimum of the continuous problem differ by at most
`L·r`.  Quantization therefore preserves the *value* of the global optimum, the
coarsest invariant of the loss landscape. -/
theorem lattice_infimum_close [Nonempty E] {L : NNReal} {f : E → ℝ}
    (hL : LipschitzWith L f) (Q : Quantizer E) (hbdd : BddBelow (Set.range f)) :
    sInf (Set.range f) ≤ sInf (f '' Set.range Q.toFun) ∧
      sInf (f '' Set.range Q.toFun) ≤ sInf (Set.range f) + (L : ℝ) * Q.radius := by
  have hsub : f '' Set.range Q.toFun ⊆ Set.range f := by
    rintro _ ⟨w, ⟨x, rfl⟩, rfl⟩
    exact ⟨Q.toFun x, rfl⟩
  have hne : (f '' Set.range Q.toFun).Nonempty :=
    ⟨f (Q.toFun (Classical.arbitrary E)), ⟨Q.toFun (Classical.arbitrary E),
      ⟨Classical.arbitrary E, rfl⟩, rfl⟩⟩
  have hbdd' : BddBelow (f '' Set.range Q.toFun) := hbdd.mono hsub
  refine ⟨csInf_le_csInf hbdd hne hsub, ?_⟩
  have hlb : ∀ z ∈ Set.range f, sInf (f '' Set.range Q.toFun) - (L : ℝ) * Q.radius ≤ z := by
    rintro _ ⟨x, rfl⟩
    have h1 : sInf (f '' Set.range Q.toFun) ≤ f (Q.toFun x) :=
      csInf_le hbdd' ⟨Q.toFun x, ⟨x, rfl⟩, rfl⟩
    have h2 : f (Q.toFun x) ≤ f x + (L : ℝ) * Q.radius := loss_quantize_le hL Q x
    linarith
  have := le_csInf (Set.range_nonempty f) hlb
  linarith

end QuantizedWeightLattices.Landscape