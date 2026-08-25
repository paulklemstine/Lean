import Algebra.ParallelResidualBlocks

/-!
# Wide and deep residual architectures: the `sup`/power certificate

This file extends the binary tensor-product certificate of
`Algebra.ParallelResidualBlocks` in the two structural directions of a residual
architecture.

**Width.**  For a finite family of residual blocks with certificates `K i`, the parallel
product on `∀ i, X i` (with the sup product norm, mathlib's `Pi` instance) is again a
residual block, with certificate `Finset.univ.sup K`; hence the Lipschitz bound
`⨆ i, (1 + K i)`.  The bound is attained by dilations of `ℝ`, so the "max rule" is sharp
in every width, not just width two.

**Depth.**  Iterating a block of certificate `K` `d` times gives Lipschitz constant
`(1 + K)^d`, and this stacking constant is itself sharp for dilations.  Combining the two
gives the certificate of a parallel pair of residual *stacks*, together with the
exponential comparison `(1 + K)^d ≤ exp (K * d)`.

Main results:

* `lipschitzWith_piMap`, `ResidualBlock.pi` — the wide parallel product and its certificate;
* `pi_lipschitz_bound` — the bound `⨆ i, (1 + K i)` (for a nonempty index type);
* `pi_isLeast_lipschitz` — attainment of the wide bound;
* `ResidualBlock.iterate_lipschitz`, `iterate_isLeast_lipschitz` — the depth-`d` gain
  `(1 + K)^d` and its sharpness;
* `parallel_stack_lipschitz_bound`, `parallel_stack_exp_bound` — the certificate of two
  parallel stacks and its exponential relaxation.
-/

open NNReal ResidualCert

namespace ParallelResidualBlocks

/-! ### Width: finite parallel families -/

/-- A finite family of Lipschitz maps is Lipschitz for the sup product metric, with the
supremum of the individual constants. -/
theorem lipschitzWith_piMap {ι : Type*} [Fintype ι] {X : ι → Type*}
    [∀ i, PseudoMetricSpace (X i)] {f : ∀ i, X i → X i} {K : ι → ℝ≥0}
    (h : ∀ i, LipschitzWith (K i) (f i)) :
    LipschitzWith (Finset.univ.sup K) (fun (x : ∀ i, X i) i => f i (x i)) := by
  refine LipschitzWith.of_dist_le_mul fun x y => ?_
  have hnn : (0 : ℝ) ≤ (Finset.univ.sup K : ℝ≥0) * dist x y :=
    mul_nonneg (Finset.univ.sup K).coe_nonneg dist_nonneg
  refine (dist_pi_le_iff hnn).2 fun i => ?_
  calc dist (f i (x i)) (f i (y i)) ≤ (K i : ℝ) * dist (x i) (y i) :=
        (h i).dist_le_mul _ _
    _ ≤ ((Finset.univ.sup K : ℝ≥0) : ℝ) * dist x y := by
        refine mul_le_mul ?_ (dist_le_pi_dist x y i) dist_nonneg
          (Finset.univ.sup K).coe_nonneg
        exact_mod_cast Finset.le_sup (Finset.mem_univ i)

/-- `1 + sup = sup (1 + ·)` on a nonempty finite index set. -/
theorem one_add_finset_sup {ι : Type*} {s : Finset ι} (hs : s.Nonempty) (K : ι → ℝ≥0) :
    1 + s.sup K = s.sup fun i => 1 + K i := by
  induction hs using Finset.Nonempty.cons_induction with
  | singleton i => simp
  | cons i s hi hs ih => simp [Finset.sup_cons, ← ih, max_add_add_left]

namespace ResidualBlock

/-- **Wide parallel product.**  A finite family of residual blocks assembles into a
residual block on the product space, with certificate the supremum of the certificates. -/
def pi {ι : Type*} [Fintype ι] {X : ι → Type*} [∀ i, SeminormedAddCommGroup (X i)]
    {K : ι → ℝ≥0} (B : ∀ i, ResidualBlock (X i) (K i)) :
    ResidualBlock (∀ i, X i) (Finset.univ.sup K) where
  residual := fun x i => (B i).residual (x i)
  residual_lipschitz := lipschitzWith_piMap fun i => (B i).residual_lipschitz

@[simp] theorem pi_toFun {ι : Type*} [Fintype ι] {X : ι → Type*}
    [∀ i, SeminormedAddCommGroup (X i)] {K : ι → ℝ≥0}
    (B : ∀ i, ResidualBlock (X i) (K i)) :
    (ResidualBlock.pi B).toFun = fun x i => (B i).toFun (x i) := rfl

end ResidualBlock

/-- **Wide upper bound.**  A parallel family of residual blocks with certificates `K i`
is Lipschitz with constant `⨆ i, (1 + K i)` for the sup product norm. -/
theorem pi_lipschitz_bound {ι : Type*} [Fintype ι] [Nonempty ι] {X : ι → Type*}
    [∀ i, SeminormedAddCommGroup (X i)] {K : ι → ℝ≥0}
    (B : ∀ i, ResidualBlock (X i) (K i)) :
    LipschitzWith (Finset.univ.sup fun i => 1 + K i)
      (fun (x : ∀ i, X i) i => (B i).toFun (x i)) := by
  have h := (ResidualBlock.pi B).lipschitz
  rwa [ResidualBlock.pi_toFun, one_add_finset_sup Finset.univ_nonempty K] at h

/-- **Sharpness in every width.**  For dilations of `ℝ` indexed by a nonempty finite set,
the least Lipschitz constant of the parallel family is exactly the supremum of the
dilation factors. -/
theorem pi_isLeast_lipschitz_dilation {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℝ≥0) :
    IsLeast {L : ℝ≥0 | LipschitzWith L (fun x : ι → ℝ => fun i => (a i : ℝ) * x i)}
      (Finset.univ.sup a) := by
  have hdil : ∀ i, LipschitzWith (a i) (fun t : ℝ => (a i : ℝ) * t) := by
    intro i
    refine LipschitzWith.of_dist_le_mul fun x y => ?_
    rw [Real.dist_eq, Real.dist_eq, ← mul_sub, abs_mul, abs_of_nonneg (a i).coe_nonneg]
  constructor
  · exact lipschitzWith_piMap hdil
  · rintro L hL
    refine Finset.sup_le fun j _ => ?_
    -- test against the `j`-th coordinate vector
    have hd := hL.dist_le_mul (fun i => if i = j then (1 : ℝ) else 0) (fun _ => (0 : ℝ))
    have hdist : dist (fun i => if i = j then (1 : ℝ) else 0) (fun _ : ι => (0 : ℝ)) = 1 := by
      refine le_antisymm ((dist_pi_le_iff zero_le_one).2 fun i => ?_) ?_
      · by_cases h : i = j <;> simp [h]
      · have := dist_le_pi_dist (fun i => if i = j then (1 : ℝ) else 0)
          (fun _ : ι => (0 : ℝ)) j
        simpa [Real.dist_eq] using this
    have hj : (a j : ℝ) ≤ dist (fun i => (a i : ℝ) * (if i = j then (1 : ℝ) else 0))
        (fun i => (a i : ℝ) * (0 : ℝ)) := by
      have := dist_le_pi_dist (fun i => (a i : ℝ) * (if i = j then (1 : ℝ) else 0))
        (fun i => (a i : ℝ) * (0 : ℝ)) j
      simpa [Real.dist_eq, abs_of_nonneg (a j).coe_nonneg] using this
    have : (a j : ℝ) ≤ (L : ℝ) := by
      refine hj.trans ?_
      simpa [hdist] using hd
    exact_mod_cast this

/-! ### Depth: iterated blocks -/

namespace ResidualBlock

variable {X : Type*} [SeminormedAddCommGroup X] {K : ℝ≥0}

/-- **Depth gain.**  Stacking `d` copies of a residual block with certificate `K` gives a
`(1 + K)^d`-Lipschitz map. -/
theorem iterate_lipschitz (B : ResidualBlock X K) (d : ℕ) :
    LipschitzWith ((1 + K) ^ d) (B.toFun^[d]) :=
  B.lipschitz.iterate d

end ResidualBlock

/-- The depth-`d` stack of the dilation block is the dilation by `(1 + K)^d`. -/
theorem dilation_iterate (K : ℝ≥0) (d : ℕ) :
    (dilationBlock K).toFun^[d] = fun x : ℝ => ((1 + (K : ℝ)) ^ d) * x := by
  induction d with
  | zero => funext x; simp
  | succ n ih =>
      funext x
      rw [Function.iterate_succ_apply', ih, dilationBlock_toFun]
      ring

/-- **Sharpness of the depth certificate.**  The stack of `d` dilation blocks with
certificate `K` has least Lipschitz constant exactly `(1 + K)^d`. -/
theorem iterate_isLeast_lipschitz (K : ℝ≥0) (d : ℕ) :
    IsLeast {L : ℝ≥0 | LipschitzWith L ((dilationBlock K).toFun^[d])} ((1 + K) ^ d) := by
  constructor
  · exact (dilationBlock K).iterate_lipschitz d
  · rintro L hL
    have hd := hL.dist_le_mul (1 : ℝ) (0 : ℝ)
    rw [dilation_iterate] at hd
    have h1 : ((1 + (K : ℝ)) ^ d) ≤ (L : ℝ) := by
      simpa [Real.dist_eq, abs_of_nonneg (by positivity : (0:ℝ) ≤ 1 + (K:ℝ)),
        abs_of_nonneg (by positivity : (0:ℝ) ≤ (1 + (K:ℝ)) ^ d)] using hd
    have : (((1 + K) ^ d : ℝ≥0) : ℝ) ≤ (L : ℝ) := by push_cast; exact h1
    exact_mod_cast this

/-- **Two parallel stacks.**  Depths `d₁, d₂` and certificates `K₁, K₂` give the
tensor-product certificate `max ((1 + K₁)^d₁) ((1 + K₂)^d₂)`. -/
theorem parallel_stack_lipschitz_bound {X Y : Type*} [SeminormedAddCommGroup X]
    [SeminormedAddCommGroup Y] {K₁ K₂ : ℝ≥0} (B₁ : ResidualBlock X K₁)
    (B₂ : ResidualBlock Y K₂) (d₁ d₂ : ℕ) :
    LipschitzWith (max ((1 + K₁) ^ d₁) ((1 + K₂) ^ d₂))
      (Prod.map B₁.toFun^[d₁] B₂.toFun^[d₂]) :=
  lipschitzWith_prodMap (B₁.iterate_lipschitz d₁) (B₂.iterate_lipschitz d₂)

/-- The parallel-stack certificate is attained: for dilation blocks the least Lipschitz
constant of the parallel pair of stacks is exactly `max ((1 + K₁)^d₁) ((1 + K₂)^d₂)`. -/
theorem parallel_stack_isLeast (K₁ K₂ : ℝ≥0) (d₁ d₂ : ℕ) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (Prod.map (dilationBlock K₁).toFun^[d₁] (dilationBlock K₂).toFun^[d₂])}
      (max ((1 + K₁) ^ d₁) ((1 + K₂) ^ d₂)) := by
  have h := isLeast_lipschitz_prod_dilation ((1 + K₁) ^ d₁) ((1 + K₂) ^ d₂)
  rw [dilation_iterate, dilation_iterate]
  convert h using 4

/-- **Exponential relaxation** (the bridge to the catalog's
`residual_lipschitz_bound` style estimates): the parallel-stack certificate is dominated
by `exp (max (K₁ * d₁) (K₂ * d₂))`. -/
theorem parallel_stack_exp_bound (K₁ K₂ : ℝ≥0) (d₁ d₂ : ℕ) :
    ((max ((1 + K₁) ^ d₁) ((1 + K₂) ^ d₂) : ℝ≥0) : ℝ)
      ≤ Real.exp (max ((K₁ : ℝ) * d₁) ((K₂ : ℝ) * d₂)) := by
  have key : ∀ (K : ℝ≥0) (d : ℕ), ((1 + (K : ℝ)) ^ d) ≤ Real.exp ((K : ℝ) * d) := by
    intro K d
    have h1 : (1 + (K : ℝ)) ≤ Real.exp (K : ℝ) := by
      simpa [add_comm] using Real.add_one_le_exp (K : ℝ)
    calc (1 + (K : ℝ)) ^ d ≤ (Real.exp (K : ℝ)) ^ d := by
          exact pow_le_pow_left₀ (by positivity) h1 d
      _ = Real.exp ((K : ℝ) * d) := by
          rw [← Real.exp_nat_mul, mul_comm]
  have h₁ : (((1 + K₁) ^ d₁ : ℝ≥0) : ℝ) ≤ Real.exp (max ((K₁ : ℝ) * d₁) ((K₂ : ℝ) * d₂)) := by
    refine le_trans ?_ (Real.exp_le_exp.2 (le_max_left _ _))
    push_cast
    exact key K₁ d₁
  have h₂ : (((1 + K₂) ^ d₂ : ℝ≥0) : ℝ) ≤ Real.exp (max ((K₁ : ℝ) * d₁) ((K₂ : ℝ) * d₂)) := by
    refine le_trans ?_ (Real.exp_le_exp.2 (le_max_right _ _))
    push_cast
    exact key K₂ d₂
  rw [NNReal.coe_max]
  exact max_le h₁ h₂

end ParallelResidualBlocks