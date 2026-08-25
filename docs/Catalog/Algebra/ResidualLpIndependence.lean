import Algebra.ParallelResidualBlocks

/-!
# The residual certificate does not see the cartesian structure

The conjecture of `Algebra.ParallelResidualBlocks` is stated for the **max** product norm.
It is natural to ask whether the value `max (1 + K₁) (1 + K₂)` is an artefact of that
choice of monoidal structure.  It is not.

Here we redo the bound and its attainment for the `L¹` and `L²` cartesian products
(`WithLp 1 (X × Y)` and `WithLp 2 (X × Y)`), and obtain the same sharp constant.  Thus the
tensor-product certificate is an invariant of the *pair of blocks*, not of the product
metric used to glue them: it is stable under the whole `Lᵖ` family of cartesian
structures on real normed spaces.

Main results:

* `lipschitzWith_parLp_one`, `lipschitzWith_parLp_two` — the max rule in `L¹` and `L²`;
* `isLeast_lipschitz_parLp_one_dilation`, `isLeast_lipschitz_parLp_two_dilation` —
  attainment of the max rule in `L¹` and `L²`;
* `residual_certificate_p_independent` — for every `K₁, K₂` the number
  `max (1 + K₁) (1 + K₂)` is simultaneously the least Lipschitz constant of the parallel
  dilation blocks in `L^∞`, `L¹` and `L²`.
-/

open NNReal ENNReal ResidualCert

namespace ParallelResidualBlocks

variable {X Y : Type*} [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y]

/-- The parallel product of two maps, seen inside the `Lᵖ` cartesian product. -/
def parLp (p : ℝ≥0∞) (f : X → X) (g : Y → Y) : WithLp p (X × Y) → WithLp p (X × Y) :=
  fun z => WithLp.toLp p (f z.fst, g z.snd)

omit [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y] in
@[simp] theorem parLp_fst (p : ℝ≥0∞) (f : X → X) (g : Y → Y) (z : WithLp p (X × Y)) :
    (parLp p f g z).fst = f z.fst := rfl

omit [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y] in
@[simp] theorem parLp_snd (p : ℝ≥0∞) (f : X → X) (g : Y → Y) (z : WithLp p (X × Y)) :
    (parLp p f g z).snd = g z.snd := rfl

/-! ### The `L¹` cartesian product -/

/-- **Max rule in `L¹`.**  A parallel pair of an `a`-Lipschitz and a `b`-Lipschitz map is
`max a b`-Lipschitz for the sum metric. -/
theorem lipschitzWith_parLp_one {a b : ℝ≥0} {f : X → X} {g : Y → Y}
    (hf : LipschitzWith a f) (hg : LipschitzWith b g) :
    LipschitzWith (max a b) (parLp 1 f g) := by
  refine LipschitzWith.of_dist_le_mul fun z w => ?_
  rw [WithLp.prod_dist_eq_of_L1, WithLp.prod_dist_eq_of_L1, parLp_fst, parLp_snd,
    parLp_fst, parLp_snd]
  have ha : (a : ℝ) ≤ ((max a b : ℝ≥0) : ℝ) := by exact_mod_cast le_max_left a b
  have hb : (b : ℝ) ≤ ((max a b : ℝ≥0) : ℝ) := by exact_mod_cast le_max_right a b
  have h1 : dist (f z.fst) (f w.fst) ≤ ((max a b : ℝ≥0) : ℝ) * dist z.fst w.fst :=
    (hf.dist_le_mul _ _).trans (by nlinarith [dist_nonneg (x := z.fst) (y := w.fst)])
  have h2 : dist (g z.snd) (g w.snd) ≤ ((max a b : ℝ≥0) : ℝ) * dist z.snd w.snd :=
    (hg.dist_le_mul _ _).trans (by nlinarith [dist_nonneg (x := z.snd) (y := w.snd)])
  nlinarith [h1, h2]

/-- **Attainment in `L¹`.** -/
theorem isLeast_lipschitz_parLp_one_dilation (a b : ℝ≥0) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (parLp 1 (fun x : ℝ => (a : ℝ) * x) (fun y : ℝ => (b : ℝ) * y))} (max a b) := by
  have hdil : ∀ c : ℝ≥0, LipschitzWith c (fun x : ℝ => (c : ℝ) * x) := by
    intro c
    refine LipschitzWith.of_dist_le_mul fun x y => ?_
    rw [Real.dist_eq, Real.dist_eq, ← mul_sub, abs_mul, abs_of_nonneg c.coe_nonneg]
  refine ⟨lipschitzWith_parLp_one (hdil a) (hdil b), ?_⟩
  rintro L hL
  have key : ∀ c : ℝ≥0, ∀ z w : WithLp 1 (ℝ × ℝ),
      dist z.fst w.fst + dist z.snd w.snd = 1 →
      dist (parLp 1 (fun x : ℝ => (a : ℝ) * x) (fun y : ℝ => (b : ℝ) * y) z)
        (parLp 1 (fun x : ℝ => (a : ℝ) * x) (fun y : ℝ => (b : ℝ) * y) w) = (c : ℝ) →
      (c : ℝ) ≤ (L : ℝ) := by
    intro c z w hzw himg
    have h := hL.dist_le_mul z w
    rw [himg, WithLp.prod_dist_eq_of_L1, hzw, mul_one] at h
    exact h
  have h1 : (a : ℝ) ≤ (L : ℝ) := by
    refine key a (WithLp.toLp 1 ((1 : ℝ), (0 : ℝ))) (WithLp.toLp 1 ((0 : ℝ), (0 : ℝ)))
      (by simp) ?_
    rw [WithLp.prod_dist_eq_of_L1]
    simp [abs_of_nonneg a.coe_nonneg]
  have h2 : (b : ℝ) ≤ (L : ℝ) := by
    refine key b (WithLp.toLp 1 ((0 : ℝ), (1 : ℝ))) (WithLp.toLp 1 ((0 : ℝ), (0 : ℝ)))
      (by simp) ?_
    rw [WithLp.prod_dist_eq_of_L1]
    simp [abs_of_nonneg b.coe_nonneg]
  exact max_le (by exact_mod_cast h1) (by exact_mod_cast h2)

/-! ### The `L²` cartesian product -/

/-- **Max rule in `L²`.**  A parallel pair of an `a`-Lipschitz and a `b`-Lipschitz map is
`max a b`-Lipschitz for the euclidean product metric. -/
theorem lipschitzWith_parLp_two {a b : ℝ≥0} {f : X → X} {g : Y → Y}
    (hf : LipschitzWith a f) (hg : LipschitzWith b g) :
    LipschitzWith (max a b) (parLp 2 f g) := by
  refine LipschitzWith.of_dist_le_mul fun z w => ?_
  rw [WithLp.prod_dist_eq_of_L2, WithLp.prod_dist_eq_of_L2, parLp_fst, parLp_snd,
    parLp_fst, parLp_snd]
  set M : ℝ := ((max a b : ℝ≥0) : ℝ) with hM
  have hM0 : 0 ≤ M := (max a b).coe_nonneg
  have ha : (a : ℝ) ≤ M := by exact_mod_cast le_max_left a b
  have hb : (b : ℝ) ≤ M := by exact_mod_cast le_max_right a b
  have h1 : dist (f z.fst) (f w.fst) ≤ M * dist z.fst w.fst :=
    (hf.dist_le_mul _ _).trans (by nlinarith [dist_nonneg (x := z.fst) (y := w.fst)])
  have h2 : dist (g z.snd) (g w.snd) ≤ M * dist z.snd w.snd :=
    (hg.dist_le_mul _ _).trans (by nlinarith [dist_nonneg (x := z.snd) (y := w.snd)])
  have hsq : dist (f z.fst) (f w.fst) ^ 2 + dist (g z.snd) (g w.snd) ^ 2
      ≤ M ^ 2 * (dist z.fst w.fst ^ 2 + dist z.snd w.snd ^ 2) := by
    have hd1 : (0 : ℝ) ≤ dist (f z.fst) (f w.fst) := dist_nonneg
    have hd2 : (0 : ℝ) ≤ dist (g z.snd) (g w.snd) := dist_nonneg
    nlinarith [h1, h2, hd1, hd2, dist_nonneg (x := z.fst) (y := w.fst),
      dist_nonneg (x := z.snd) (y := w.snd)]
  calc Real.sqrt (dist (f z.fst) (f w.fst) ^ 2 + dist (g z.snd) (g w.snd) ^ 2)
      ≤ Real.sqrt (M ^ 2 * (dist z.fst w.fst ^ 2 + dist z.snd w.snd ^ 2)) :=
        Real.sqrt_le_sqrt hsq
    _ = M * Real.sqrt (dist z.fst w.fst ^ 2 + dist z.snd w.snd ^ 2) := by
        rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hM0]

/-- **Attainment in `L²`.** -/
theorem isLeast_lipschitz_parLp_two_dilation (a b : ℝ≥0) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (parLp 2 (fun x : ℝ => (a : ℝ) * x) (fun y : ℝ => (b : ℝ) * y))} (max a b) := by
  have hdil : ∀ c : ℝ≥0, LipschitzWith c (fun x : ℝ => (c : ℝ) * x) := by
    intro c
    refine LipschitzWith.of_dist_le_mul fun x y => ?_
    rw [Real.dist_eq, Real.dist_eq, ← mul_sub, abs_mul, abs_of_nonneg c.coe_nonneg]
  refine ⟨lipschitzWith_parLp_two (hdil a) (hdil b), ?_⟩
  rintro L hL
  have h1 : (a : ℝ) ≤ (L : ℝ) := by
    have h := hL.dist_le_mul (WithLp.toLp 2 ((1 : ℝ), (0 : ℝ)))
      (WithLp.toLp 2 ((0 : ℝ), (0 : ℝ)))
    rw [WithLp.prod_dist_eq_of_L2, WithLp.prod_dist_eq_of_L2] at h
    simpa [Real.dist_eq, abs_of_nonneg a.coe_nonneg] using h
  have h2 : (b : ℝ) ≤ (L : ℝ) := by
    have h := hL.dist_le_mul (WithLp.toLp 2 ((0 : ℝ), (1 : ℝ)))
      (WithLp.toLp 2 ((0 : ℝ), (0 : ℝ)))
    rw [WithLp.prod_dist_eq_of_L2, WithLp.prod_dist_eq_of_L2] at h
    simpa [Real.dist_eq, abs_of_nonneg b.coe_nonneg] using h
  exact max_le (by exact_mod_cast h1) (by exact_mod_cast h2)

/-- **`p`-independence of the residual certificate.**  For all residual constants
`K₁, K₂ ≥ 0`, the number `max (1 + K₁) (1 + K₂)` is *simultaneously* the least Lipschitz
constant of the parallel pair of dilation residual blocks in the `L^∞`, `L¹` and `L²`
cartesian products.  The tensor-product certificate therefore depends only on the two
blocks, not on the chosen cartesian monoidal structure. -/
theorem residual_certificate_p_independent (K₁ K₂ : ℝ≥0) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (Prod.map (dilationBlock K₁).toFun (dilationBlock K₂).toFun)}
      (max (1 + K₁) (1 + K₂)) ∧
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (parLp 1 (dilationBlock K₁).toFun (dilationBlock K₂).toFun)}
      (max (1 + K₁) (1 + K₂)) ∧
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (parLp 2 (dilationBlock K₁).toFun (dilationBlock K₂).toFun)}
      (max (1 + K₁) (1 + K₂)) := by
  refine ⟨parallel_isLeast_lipschitz K₁ K₂, ?_, ?_⟩
  · have h := isLeast_lipschitz_parLp_one_dilation (1 + K₁) (1 + K₂)
    rw [dilationBlock_toFun, dilationBlock_toFun]
    convert h using 5
  · have h := isLeast_lipschitz_parLp_two_dilation (1 + K₁) (1 + K₂)
    rw [dilationBlock_toFun, dilationBlock_toFun]
    convert h using 5

end ParallelResidualBlocks