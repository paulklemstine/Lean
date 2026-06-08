import Mathlib
import Cryptography.ModuleLWE.Defs

/-!
# TVD Contraction and Coarse-Graining for Non-Commutative Modules

## Main Results

This module proves the **data processing inequality for total variation distance**:
pushforward along any function between finite types cannot increase TVD.
This is the measure-theoretic core of all cryptographic indistinguishability
reductions. Crucially, no algebraic structure on the domain/codomain is needed.

We then specialize to left-linear maps over arbitrary (possibly non-commutative)
rings, showing that Module-LWE-style contraction arguments are ring-agnostic.

### Theorems

1. `coarse_graining_contracts_tvd`: For any `f : α → β` between finite types,
   `tvd (μ.map f) (ν.map f) ≤ tvd μ ν`. This is the **data processing inequality**.

2. `tvd_map_le_of_leftLinear`: Specialization to `R`-linear maps where `R` is
   a (possibly non-commutative) ring and the modules are left `R`-modules.

3. `tvd_triangle`: Triangle inequality for TVD.

## Mathematical Content

The proof of TVD contraction proceeds by:
- Expressing `(μ.map f)(b)` as a sum over the fiber `f⁻¹(b)`.
- Applying the triangle inequality to bound the fiber-sum differences.
- Regrouping the double sum `∑_b ∑_{a ∈ f⁻¹(b)}` back to `∑_a`.

This identifies the true invariant: TVD contraction depends only on the
**partition structure** induced by `f` on the domain, not on any algebraic
properties of `f`. Commutativity of the base ring is entirely irrelevant.
-/

open Finset BigOperators

noncomputable section

/-! ## PMF map applied to elements -/

/-
The value of a mapped PMF at a point, expressed as a finite sum over the fiber.
-/
lemma pmf_map_apply_eq_sum_fiber {α β : Type*} [DecidableEq β] [Fintype α]
    (f : α → β) (μ : PMF α) (b : β) :
    (μ.map f) b = ∑ a : α, if f a = b then μ a else 0 := by
  convert ( PMF.map_apply f μ b ) using 1;
  rw [ tsum_fintype ] ; congr ; ext ; simp +decide [ eq_comm ]

/-
The toReal of a mapped PMF at a point equals the real sum over the fiber.
-/
lemma pmf_map_toReal_eq_sum_fiber {α β : Type*} [DecidableEq β] [Fintype α]
    (f : α → β) (μ : PMF α) (b : β) :
    ((μ.map f) b).toReal = ∑ a : α, if f a = b then (μ a).toReal else 0 := by
  convert congr_arg ENNReal.toReal ( pmf_map_apply_eq_sum_fiber f μ b ) using 1;
  rw [ ENNReal.toReal_sum ] ; congr ; ext ; aesop;
  intro a _; split_ifs <;> simp +decide [ PMF.apply_ne_top ] ;

/-! ## Core Data Processing Inequality -/

/-
**Data Processing Inequality / Coarse-Graining Contracts TVD**.

For any function `f : α → β` between finite types, pushforward along `f`
cannot increase total variation distance. This is the most general form:
no algebraic structure on `α` or `β` is assumed.

**Proof sketch**: Express each `(μ.map f)(b)` as a sum over fibers,
apply triangle inequality on the fiber sums, then regroup.
-/
theorem coarse_graining_contracts_tvd
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → β) (μ ν : PMF α) :
    tvd (μ.map f) (ν.map f) ≤ tvd μ ν := by
  -- Use the fact that |∑ x, f x| ≤ ∑ x, |f x| to bound the sum.
  have h_abs_sum : ∀ b : β, |((μ.map f) b).toReal - ((ν.map f) b).toReal| ≤ ∑ a : α, |(μ a).toReal - (ν a).toReal| * (if f a = b then 1 else 0) := by
    intro b
    have h_sum : ((μ.map f) b).toReal - ((ν.map f) b).toReal = ∑ a : α, ((μ a).toReal - (ν a).toReal) * (if f a = b then 1 else 0) := by
      simp +decide only [pmf_map_toReal_eq_sum_fiber, mul_ite, mul_one, mul_zero];
      simpa only [ ← Finset.sum_sub_distrib ] using Finset.sum_congr rfl fun _ _ => by split_ifs <;> ring;
    exact h_sum.symm ▸ le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun a _ => by split_ifs <;> norm_num [ abs_mul ] );
  convert mul_le_mul_of_nonneg_left ( Finset.sum_le_sum fun b _ => h_abs_sum b ) ( by norm_num : ( 0 : ℝ ) ≤ 1 / 2 ) using 1;
  rw [ Finset.sum_comm ] ; simp +decide [ tvd ] ;

/-! ## Specialization to Left-Linear Maps -/

/-- **TVD contraction for left-linear maps over non-commutative rings**.

This is a direct corollary of `coarse_graining_contracts_tvd`. The ring `R`
is only assumed to be a `Ring` (not `CommRing`), and the modules are
left `R`-modules via the standard `Module R M` instance.

This theorem shows that the algebraic structure of Module-LWE reductions
is irrelevant to the contraction principle: what matters is only that
the map induces a partition on the domain via its fibers. -/
theorem tvd_map_le_of_leftLinear
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M] [Fintype M] [DecidableEq M]
    [AddCommGroup N] [Module R N] [Fintype N] [DecidableEq N]
    (φ : M →ₗ[R] N)
    (μ ν : PMF M) :
    tvd (μ.map φ) (ν.map φ) ≤ tvd μ ν :=
  coarse_graining_contracts_tvd φ μ ν

/-! ## TVD Triangle Inequality -/

/-
**Triangle inequality for TVD** on finite types.
-/
theorem tvd_triangle {α : Type*} [Fintype α] [DecidableEq α]
    (μ ν ρ : PMF α) :
    tvd μ ρ ≤ tvd μ ν + tvd ν ρ := by
  -- Expand both sides using the definition of total variation distance.
  unfold tvd
  ring_nf at *;
  rw [ ← add_mul, ← Finset.sum_add_distrib ] ; exact mul_le_mul_of_nonneg_right ( Finset.sum_le_sum fun i _ ↦ by cases abs_cases ( ( μ i |> ENNReal.toReal ) - ( ρ i |> ENNReal.toReal ) ) <;> cases abs_cases ( ( μ i |> ENNReal.toReal ) - ( ν i |> ENNReal.toReal ) ) <;> cases abs_cases ( ( ν i |> ENNReal.toReal ) - ( ρ i |> ENNReal.toReal ) ) <;> linarith ) ( by norm_num ) ;

/-! ## Kernel-Invariant Error over Non-Commutative Rings -/

/-- A distribution `χ` on a left `R`-module `M` is kernel-invariant with respect to
a linear map `f : M →ₗ[R] N` if `χ` assigns equal probability to any two
elements in the same kernel coset. Generalization to non-commutative `R`. -/
def KernelInvariantError_nc
    {R M N : Type*}
    [Ring R]
    [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N]
    (f : M →ₗ[R] N) (χ : PMF M) : Prop :=
  ∀ m k, k ∈ LinearMap.ker f → χ m = χ (m + k)

end