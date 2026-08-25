import Algebra.ResidualCertificateAlgebra

/-!
# Parallel residual blocks and their tensor-product certificate

Work in the cartesian monoidal category of real (semi)normed spaces and Lipschitz maps,
where the monoidal product is the cartesian product carrying the **max product norm**
(`Prod.dist_eq : dist x y = max (dist x.1 y.1) (dist x.2 y.2)`, which is what mathlib's
`Prod` instance provides).

A **residual block** with certificate `K : ℝ≥0` on a space `X` is a map `x ↦ x + r x`
whose residual `r` is `K`-Lipschitz.  This file proves:

* `ResidualBlock.lipschitz` — a block with certificate `K` is `(1 + K)`-Lipschitz;
* `ResidualBlock.par` — the parallel (monoidal) product of two blocks with certificates
  `K₁, K₂` is a residual block on `X × Y` with certificate `max K₁ K₂`, hence the
  **upper bound** `max (1 + K₁) (1 + K₂)` of the conjecture
  (`parallel_lipschitz_bound`, and `parallel_dist_le` in real-number form);
* `parallel_isLeast_lipschitz` — the bound is **attained**: for every `K₁, K₂ ≥ 0` there
  are blocks (dilations of `ℝ`) whose parallel product has *least* Lipschitz constant
  exactly `max (1 + K₁) (1 + K₂)`.  So the conjecture is confirmed, in the sharp form
  `IsLeast {L | LipschitzWith L F} (max (1 + K₁) (1 + K₂))`;
* `ResidualBlock.comp` — serial composition multiplies gains, i.e. certificates compose
  by `ResidualCert.serial`;
* `par_comp_interchange` — the monoidal interchange law holds *on maps*, while
  `certificate_laxity_gap` shows that the induced certificate calculus is only lax:
  the same map is certified by `2` through one bracketing and only by `4` through the
  other.

Everything is stated for `ℝ≥0`-valued Lipschitz constants; real-number corollaries with
hypotheses `0 ≤ K` are given where the conjecture is phrased that way.
-/

open NNReal ResidualCert

namespace ParallelResidualBlocks

variable {X Y Z : Type*}

/-! ### Residual blocks -/

/-- A **residual block** on `X` with residual certificate `K`: the map `x ↦ x + r x`
where the residual `r` is `K`-Lipschitz. -/
structure ResidualBlock (X : Type*) [SeminormedAddCommGroup X] (K : ℝ≥0) where
  /-- The residual (the "learned" part of the block). -/
  residual : X → X
  /-- The residual is `K`-Lipschitz; `K` is the block's certificate. -/
  residual_lipschitz : LipschitzWith K residual

namespace ResidualBlock

variable [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y] [SeminormedAddCommGroup Z]
variable {K K₁ K₂ : ℝ≥0}

/-- The map computed by a residual block: the identity plus the residual. -/
def toFun (B : ResidualBlock X K) : X → X := fun x => x + B.residual x

@[simp] theorem toFun_apply (B : ResidualBlock X K) (x : X) : B.toFun x = x + B.residual x := rfl

/-- **Gain bound.** A residual block with certificate `K` is `(1 + K)`-Lipschitz. -/
theorem lipschitz (B : ResidualBlock X K) : LipschitzWith (1 + K) B.toFun :=
  LipschitzWith.id.add B.residual_lipschitz

/-- The identity block: certificate `0`. -/
def idBlock (X : Type*) [SeminormedAddCommGroup X] : ResidualBlock X 0 where
  residual := fun _ => 0
  residual_lipschitz := LipschitzWith.const 0

@[simp] theorem idBlock_toFun (x : X) : (idBlock X).toFun x = x := by simp [toFun, idBlock]

end ResidualBlock

/-! ### Parallel composition -/

/-- Auxiliary: a pair of Lipschitz maps is Lipschitz for the max product norm, with the
maximum of the two constants.  (Mathlib provides `LipschitzWith.prodMk`; this is the
`Prod.map` form.) -/
theorem lipschitzWith_prodMap {α β γ δ : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
    [PseudoMetricSpace γ] [PseudoMetricSpace δ] {Kf Kg : ℝ≥0} {f : α → γ} {g : β → δ}
    (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (max Kf Kg) (Prod.map f g) := by
  have h := (hf.comp LipschitzWith.prod_fst).prodMk (hg.comp LipschitzWith.prod_snd)
  simpa [Prod.map, mul_one] using h

namespace ResidualBlock

variable [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y] [SeminormedAddCommGroup Z]
variable {K K₁ K₂ K₃ : ℝ≥0}

/-- **Parallel composition** of residual blocks: a residual block on the monoidal product
`X × Y`, whose certificate is `par K₁ K₂ = max K₁ K₂`. -/
def par (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂) :
    ResidualBlock (X × Y) (ResidualCert.par K₁ K₂) where
  residual := Prod.map B₁.residual B₂.residual
  residual_lipschitz := lipschitzWith_prodMap B₁.residual_lipschitz B₂.residual_lipschitz

/-- Parallel composition of blocks computes the parallel composition of the maps. -/
@[simp] theorem par_toFun (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂) :
    (B₁.par B₂).toFun = Prod.map B₁.toFun B₂.toFun := rfl

/-- **Serial composition** of residual blocks: certificates combine by
`serial K₁ K₂ = K₁ + K₂ + K₁ * K₂`, i.e. gains multiply. -/
def comp (B₂ : ResidualBlock X K₂) (B₁ : ResidualBlock X K₁) :
    ResidualBlock X (ResidualCert.serial K₁ K₂) where
  residual := fun x => B₁.residual x + B₂.residual (B₁.toFun x)
  residual_lipschitz := by
    have h : LipschitzWith (K₁ + K₂ * (1 + K₁))
        (fun x => B₁.residual x + B₂.residual (B₁.toFun x)) :=
      B₁.residual_lipschitz.add (B₂.residual_lipschitz.comp B₁.lipschitz)
    have hK : K₁ + K₂ * (1 + K₁) = ResidualCert.serial K₁ K₂ := by
      simp only [ResidualCert.serial]; ring
    rwa [hK] at h

@[simp] theorem comp_toFun (B₂ : ResidualBlock X K₂) (B₁ : ResidualBlock X K₁) :
    (B₂.comp B₁).toFun = B₂.toFun ∘ B₁.toFun := by
  funext x
  simp [toFun, comp, add_assoc]

end ResidualBlock

/-! ### The upper bound of the conjecture -/

open ResidualBlock

variable [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y]
variable {K₁ K₂ : ℝ≥0}

/-- **Upper bound (conjecture, part 1).**  The parallel composition of residual blocks
with certificates `K₁` and `K₂` is Lipschitz with constant `max (1 + K₁) (1 + K₂)` for
the max product norm. -/
theorem parallel_lipschitz_bound (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂) :
    LipschitzWith (max (1 + K₁) (1 + K₂)) (Prod.map B₁.toFun B₂.toFun) := by
  have h := (B₁.par B₂).lipschitz
  rwa [par_toFun, show (1 : ℝ≥0) + ResidualCert.par K₁ K₂ = max (1 + K₁) (1 + K₂) from
    ResidualCert.gain_par K₁ K₂] at h

/-- Real-number form of the upper bound, for residual constants given as nonnegative
reals. -/
theorem parallel_dist_le (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂)
    (p q : X × Y) :
    dist (Prod.map B₁.toFun B₂.toFun p) (Prod.map B₁.toFun B₂.toFun q)
      ≤ max (1 + (K₁ : ℝ)) (1 + (K₂ : ℝ)) * dist p q := by
  have h := (parallel_lipschitz_bound B₁ B₂).dist_le_mul p q
  simpa [NNReal.coe_max] using h

/-! ### Attainment: dilation blocks on `ℝ` -/

/-- The dilation residual block on `ℝ` with residual `x ↦ K * x`; its certificate is
exactly `K` and it computes `x ↦ (1 + K) * x`. -/
def dilationBlock (K : ℝ≥0) : ResidualBlock ℝ K where
  residual := fun x => (K : ℝ) * x
  residual_lipschitz := by
    refine LipschitzWith.of_dist_le_mul fun x y => ?_
    rw [Real.dist_eq, Real.dist_eq, ← mul_sub, abs_mul, abs_of_nonneg K.coe_nonneg]

@[simp] theorem dilationBlock_toFun (K : ℝ≥0) :
    (dilationBlock K).toFun = fun x : ℝ => (1 + (K : ℝ)) * x := by
  funext x
  simp [ResidualBlock.toFun, dilationBlock]
  ring

/-- **Sharpness of the max rule for dilations.**  For `a b : ℝ≥0` the parallel pair of
dilations `(x, y) ↦ (a x, b y)` has least Lipschitz constant exactly `max a b` in the max
product norm. -/
theorem isLeast_lipschitz_prod_dilation (a b : ℝ≥0) :
    IsLeast {L : ℝ≥0 | LipschitzWith L (Prod.map (fun x : ℝ => (a : ℝ) * x)
      (fun y : ℝ => (b : ℝ) * y))} (max a b) := by
  have hdil : ∀ c : ℝ≥0, LipschitzWith c (fun x : ℝ => (c : ℝ) * x) := by
    intro c
    refine LipschitzWith.of_dist_le_mul fun x y => ?_
    rw [Real.dist_eq, Real.dist_eq, ← mul_sub, abs_mul, abs_of_nonneg c.coe_nonneg]
  constructor
  · exact lipschitzWith_prodMap (hdil a) (hdil b)
  · rintro L hL
    have hL' := hL.dist_le_mul
    -- test the first coordinate
    have h1 : (a : ℝ) ≤ (L : ℝ) := by
      have := hL' ((1 : ℝ), (0 : ℝ)) ((0 : ℝ), (0 : ℝ))
      simp only [Prod.map_apply, Prod.dist_eq, Real.dist_eq] at this
      simpa [abs_of_nonneg a.coe_nonneg, abs_of_nonneg b.coe_nonneg] using this
    -- test the second coordinate
    have h2 : (b : ℝ) ≤ (L : ℝ) := by
      have := hL' ((0 : ℝ), (1 : ℝ)) ((0 : ℝ), (0 : ℝ))
      simp only [Prod.map_apply, Prod.dist_eq, Real.dist_eq] at this
      simpa [abs_of_nonneg a.coe_nonneg, abs_of_nonneg b.coe_nonneg] using this
    exact max_le (by exact_mod_cast h1) (by exact_mod_cast h2)

/-- **Attainment (conjecture, part 2).**  For every pair of certificates `K₁, K₂ ≥ 0`
there are residual blocks — the dilations of `ℝ` — whose parallel composition has
*least* Lipschitz constant exactly `max (1 + K₁) (1 + K₂)`.  Combined with
`parallel_lipschitz_bound`, the tensor-product certificate is sharp. -/
theorem parallel_isLeast_lipschitz (K₁ K₂ : ℝ≥0) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (Prod.map (dilationBlock K₁).toFun (dilationBlock K₂).toFun)}
      (max (1 + K₁) (1 + K₂)) := by
  have h := isLeast_lipschitz_prod_dilation (1 + K₁) (1 + K₂)
  simpa [dilationBlock_toFun] using h

/-- The conjecture in one statement: the upper bound holds for *all* parallel residual
blocks and is attained for *every* pair of residual constants. -/
theorem parallel_certificate_sharp (K₁ K₂ : ℝ≥0) :
    (∀ {X Y : Type} [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y]
        (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂),
        LipschitzWith (max (1 + K₁) (1 + K₂)) (Prod.map B₁.toFun B₂.toFun)) ∧
      IsLeast {L : ℝ≥0 | LipschitzWith L
          (Prod.map (dilationBlock K₁).toFun (dilationBlock K₂).toFun)}
        (max (1 + K₁) (1 + K₂)) :=
  ⟨fun B₁ B₂ => parallel_lipschitz_bound B₁ B₂, parallel_isLeast_lipschitz K₁ K₂⟩

/-- Real-number formulation, matching the informal statement "for all `K₁, K₂ ≥ 0`". -/
theorem parallel_bound_real (k₁ k₂ : ℝ) (hk₁ : 0 ≤ k₁) (hk₂ : 0 ≤ k₂)
    {X Y : Type*} [SeminormedAddCommGroup X] [SeminormedAddCommGroup Y]
    (B₁ : ResidualBlock X ⟨k₁, hk₁⟩) (B₂ : ResidualBlock Y ⟨k₂, hk₂⟩) (p q : X × Y) :
    dist (Prod.map B₁.toFun B₂.toFun p) (Prod.map B₁.toFun B₂.toFun q)
      ≤ max (1 + k₁) (1 + k₂) * dist p q :=
  parallel_dist_le B₁ B₂ p q

/-- **Minimality of the max rule.**  Suppose `c` is *any* rule assigning to a pair of
residual certificates a certificate for the parallel product, i.e. such that every
parallel pair of blocks on `ℝ` is `(1 + c K₁ K₂)`-Lipschitz.  Then `c` dominates the max
rule.  So `par = max` is not merely *a* valid tensor-product certificate: it is the
smallest one. -/
theorem certificate_rule_minimal (c : ℝ≥0 → ℝ≥0 → ℝ≥0)
    (h : ∀ (K₁ K₂ : ℝ≥0) (B₁ : ResidualBlock ℝ K₁) (B₂ : ResidualBlock ℝ K₂),
      LipschitzWith (1 + c K₁ K₂) (Prod.map B₁.toFun B₂.toFun))
    (K₁ K₂ : ℝ≥0) : ResidualCert.par K₁ K₂ ≤ c K₁ K₂ := by
  have hle := (parallel_isLeast_lipschitz K₁ K₂).2
    (h K₁ K₂ (dilationBlock K₁) (dilationBlock K₂))
  rw [show max (1 + K₁) (1 + K₂) = 1 + ResidualCert.par K₁ K₂ from
    (ResidualCert.gain_par K₁ K₂).symm] at hle
  exact le_of_add_le_add_left hle

/-! ### Interchange: strict on maps, lax on certificates -/

variable {K₃ K₄ : ℝ≥0}

/-- **Interchange law on maps.**  Composing parallel blocks serially is the same map as
composing serially in each branch: the cartesian product is a bifunctor. -/
theorem par_comp_interchange {X Y : Type*} [SeminormedAddCommGroup X]
    [SeminormedAddCommGroup Y] (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂)
    (C₁ : ResidualBlock X K₃) (C₂ : ResidualBlock Y K₄) :
    ((B₁.par B₂).comp (C₁.par C₂)).toFun = ((B₁.comp C₁).par (B₂.comp C₂)).toFun := by
  funext p
  cases p with
  | mk x y => simp [ResidualBlock.comp, ResidualBlock.par, ResidualBlock.toFun, Prod.map]

/-- **Certificate laxity, realised by genuine maps.**  Take the identity block and the
`1`-dilation in each branch, crossed over.  The composite map is `(x, y) ↦ (2x, 2y)`,
whose least Lipschitz constant is `2`; but the parallel-first certificate calculus only
certifies `serial (par 0 1) (par 1 0) = 3`, i.e. the gain `4`.  Hence the tensor-product
certificate, though sharp for a single parallel layer, is *strictly lax* once serial
composition is interleaved. -/
theorem certificate_laxity_gap :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (Prod.map ((dilationBlock 1).toFun ∘ (dilationBlock 0).toFun)
          ((dilationBlock 0).toFun ∘ (dilationBlock 1).toFun))} 2 ∧
      ResidualCert.gain (ResidualCert.serial (ResidualCert.par 0 1) (ResidualCert.par 1 0))
        = 4 ∧ (2 : ℝ≥0) < 4 := by
  refine ⟨?_, by norm_num [ResidualCert.gain, ResidualCert.par, ResidualCert.serial], by norm_num⟩
  have h := isLeast_lipschitz_prod_dilation 2 2
  have hfun : ((dilationBlock 1).toFun ∘ (dilationBlock 0).toFun) = fun x : ℝ => (2 : ℝ) * x := by
    funext x
    simp only [Function.comp_apply, dilationBlock_toFun]
    norm_num
  have hfun' : ((dilationBlock 0).toFun ∘ (dilationBlock 1).toFun) = fun x : ℝ => (2 : ℝ) * x := by
    funext x
    simp only [Function.comp_apply, dilationBlock_toFun]
    norm_num
  rw [hfun, hfun']
  simpa using h

end ParallelResidualBlocks