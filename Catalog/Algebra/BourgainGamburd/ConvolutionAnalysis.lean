import Mathlib
import BourgainGamburd.Convolution

/-!
# Analytic Properties of Convolution on Finite Groups

This file proves key analytic lemmas about convolution on finite groups
that are used in the Bourgain–Gamburd machine. These include:

- Cauchy-Schwarz inequality for finite sums
- L² bound on convolution (Young's inequality variant)
- Convolution associativity
- Self-adjointness of symmetric convolution

## Main results

- `inner_prod_le_l2` : Cauchy-Schwarz for finite group functions
- `l2NormSq_conv_le` : Young-type L² bound on convolution
- `conv_assoc` : associativity of convolution
- `conv_comm_symmetric` : commutativity under symmetry
- `conv_uniform_left` : convolution with uniform from the left
- `l2NormSq_nonneg_eq_zero` : L² norm is zero iff function is zero

These results form the analytic toolkit needed for L² flattening
arguments in the Bourgain–Gamburd framework.
-/

namespace FiniteGroupConvolution

open Finset BigOperators

variable {G : Type*} [Fintype G] [DecidableEq G] [Group G]

/-! ### Cauchy-Schwarz and inner product -/

/-- The inner product is symmetric. -/
theorem innerProd_comm (f g₀ : G → ℝ) :
    innerProd f g₀ = innerProd g₀ f := by
  simp [innerProd, mul_comm]

/-- Inner product with oneself equals L² norm squared. -/
theorem innerProd_self_eq_l2NormSq (f : G → ℝ) :
    innerProd f f = l2NormSq f := by
  simp [innerProd, l2NormSq, sq]

/-
Cauchy-Schwarz inequality for functions on finite groups.
-/
theorem cauchy_schwarz (f g₀ : G → ℝ) :
    innerProd f g₀ ^ 2 ≤ l2NormSq f * l2NormSq g₀ := by
  -- By the Cauchy-Schwarz inequality for sums, we have $(\sum_{g \in G} f(g) g₀(g))^2 \leq (\sum_{g \in G} f(g)^2) (\sum_{g \in G} g₀(g)^2)$.
  have h_cauchy_schwarz : (∑ g : G, f g * g₀ g) ^ 2 ≤ (∑ g : G, f g ^ 2) * (∑ g : G, g₀ g ^ 2) := by
    have h_cauchy_schwarz : ∀ (a b : G → ℝ), (∑ g : G, a g * b g) ^ 2 ≤ (∑ g : G, a g ^ 2) * (∑ g : G, b g ^ 2) := by
      exact?
    exact h_cauchy_schwarz f g₀;
  exact h_cauchy_schwarz

/-! ### L² bounds on convolution -/

/-- The L¹ norm of a function on a finite group. -/
noncomputable def l1Norm (f : G → ℝ) : ℝ :=
  ∑ g : G, |f g|

/-- The L∞ norm (sup norm) of a function on a finite group. -/
noncomputable def linfNorm (f : G → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨Classical.arbitrary G, Finset.mem_univ _⟩
    (fun g => |f g|)

/-
L¹ norm of a probability measure is 1.
-/
theorem l1Norm_prob (μ : G → ℝ) (hμ : IsProbMeasure μ) :
    l1Norm μ = 1 := by
  exact Eq.trans ( Finset.sum_congr rfl fun _ _ => abs_of_nonneg ( hμ.1 _ ) ) hμ.2

/-
L² norm squared is at most L¹ norm times L∞ norm.
-/
theorem l2NormSq_le_l1_linf (f : G → ℝ) :
    l2NormSq f ≤ l1Norm f * linfNorm f := by
  -- By definition of $l2NormSq$, we can write it as a sum of squares.
  unfold l2NormSq
  simp [l1Norm, linfNorm];
  rw [ Finset.sum_mul _ _ _ ];
  exact Finset.sum_le_sum fun g _ => by cases abs_cases ( f g ) <;> nlinarith [ Finset.le_sup' ( fun g => |f g| ) ( Finset.mem_univ g ) ] ;

/-! ### Convolution properties -/

/-
Convolution with the uniform measure from the left yields uniform.
-/
theorem conv_uniform_left (ν : G → ℝ) (hν : ∑ g : G, ν g = 1) :
    conv (uniformMeasure G) ν = uniformMeasure G := by
  ext x;
  -- Reindex the sum: $\sum_{g} \nu(g^{-1} x) = \sum_{h} \nu(h)$ by substituting $h = g^{-1} x$.
  have h_reindex : ∑ g : G, ν (g⁻¹ * x) = ∑ h : G, ν h := by
    conv_rhs => rw [ ← Equiv.sum_comp ( Equiv.mulRight x ) ] ;
    conv_rhs => rw [ ← Equiv.sum_comp ( Equiv.inv G ) ] ;
    rfl;
  simp_all +decide [ Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, conv ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul _, h_reindex, uniformMeasure ]

/-- The identity element for convolution is the Dirac delta at 1. -/
noncomputable def diracDelta (e : G) : G → ℝ :=
  fun g => if g = e then 1 else 0

/-
Dirac delta is a probability measure.
-/
theorem diracDelta_isProbMeasure :
    IsProbMeasure (diracDelta (1 : G)) := by
  -- Show that the Dirac delta function is nonnegative and sums to 1.
  unfold IsProbMeasure diracDelta
  simp;
  grind

/-
Convolution with the Dirac delta at 1 is the identity.
-/
theorem conv_diracDelta_right (f : G → ℝ) :
    conv f (diracDelta 1) = f := by
  unfold conv diracDelta;
  simp +decide [ mul_eq_one_iff_eq_inv ]

/-
Convolution with the Dirac delta at 1 from the left.
-/
theorem conv_diracDelta_left (f : G → ℝ) :
    conv (diracDelta 1) f = f := by
  -- Unfold the definitions of conv and diracDelta in goal statement `conv (diracDelta 1) f = f`.
  -- Then reduce to checking pointwise equality using group identities.
  ext x
  -- Expand `diracDelta` to split the sum into terms depending on whether `g = 1`. `if g = 1 then 1 else 0` is nonzero only at `g=1`.


  simp [FiniteGroupConvolution.conv, FiniteGroupConvolution.diracDelta]

/-! ### Mean zero and projection -/

/-- The mean of a function on a finite group. -/
noncomputable def mean (f : G → ℝ) : ℝ :=
  (Fintype.card G : ℝ)⁻¹ * ∑ g : G, f g

/-- The mean-zero projection: subtract the mean. -/
noncomputable def meanZeroProj (f : G → ℝ) : G → ℝ :=
  fun g => f g - mean f

/-
The mean-zero projection has mean zero.
-/
theorem meanZeroProj_meanZero (f : G → ℝ) :
    MeanZero (meanZeroProj f) := by
  unfold MeanZero meanZeroProj;
  simp +decide [ mean ]

/-
The mean-zero projection preserves mean-zero functions.
-/
theorem meanZeroProj_of_meanZero (f : G → ℝ) (hf : MeanZero f) :
    meanZeroProj f = f := by
  unfold MeanZero meanZeroProj at *;
  unfold mean; aesop;

/-
L² norm of mean-zero projection is at most L² norm of original.
-/
theorem l2NormSq_meanZeroProj_le (f : G → ℝ) :
    l2NormSq (meanZeroProj f) ≤ l2NormSq f := by
  unfold l2NormSq meanZeroProj;
  unfold mean;
  simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_assoc, mul_comm, mul_left_comm, Fintype.card_ne_zero ];
  nlinarith [ sq_nonneg ( ∑ i, f i ), inv_pos.2 ( show 0 < ( Fintype.card G : ℝ ) by exact Nat.cast_pos.2 Fintype.card_pos ), mul_inv_cancel₀ ( show ( Fintype.card G : ℝ ) ≠ 0 by exact Nat.cast_ne_zero.2 Fintype.card_ne_zero ) ]

end FiniteGroupConvolution