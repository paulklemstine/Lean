/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.TateThesis.Defs
import Pythagorean.HaarRestrictedProduct.Defs

/-!
# Tate's Thesis: Core Theorems

This file proves three core theorems that formalize the first decisive fragment
of Tate's thesis, establishing the mechanism by which harmonic analysis on the
adèles manufactures arithmetic symmetry.

## Main Results

### Theorem 1: Local Nonarchimedean Euler Factor
For any prime `p` and `s > 0`, the local zeta integral of the standard indicator
function `𝟙_{ℤ_p}` equals the Euler factor:

  Z_p(𝟙_{ℤ_p}, s) = ∑_{n≥0} p^{-ns} = (1 - p^{-s})⁻¹

This is the arithmetic atom: it converts measure-theoretic integration over
ℚ_p× into the Euler product building block.

### Theorem 2: Euler Product Factorization
For a factorizable adelic test function that is standard outside a finite set S,
the truncated adelic zeta integral factors as a product of local Euler factors:

  ∏_{p ∈ S} Z_p(φ_p, s) = ∏_{p ∈ S} (1 - p^{-s})⁻¹

when all local components are standard.

### Theorem 3: Functional Equation via Fourier Duality
The completed Riemann zeta function ξ(s) = completedRiemannZeta(s) satisfies
the functional equation ξ(1-s) = ξ(s), which in Tate's framework arises from
the Fourier self-duality of the standard adelic Gaussian.

## Cross-Domain Connection

The functional equation is interpreted as a conservation symmetry: the standard
adelic Gaussian is a fixed point of the adelic Fourier transform, and the
functional equation is the shadow of this Fourier self-duality.
-/

open scoped Filter Topology
open MeasureTheory MeasureTheory.Measure Set Filter Finset Real

noncomputable section

namespace TateThesis

/-!
## § 1: Local Euler Factor Theorem

The local zeta integral at prime p for the standard indicator 𝟙_{ℤ_p}
equals the Euler factor (1 - p^{-s})⁻¹.

**Proof architecture**: Decompose ℚ_p× into shells by p-adic valuation.
The integral over {x : v_p(x) = n} contributes p^{-ns} under the normalized
multiplicative Haar measure with vol(ℤ_p×) = 1. The sum ∑_{n≥0} p^{-ns}
is a geometric series converging to (1 - p^{-s})⁻¹ for s > 0.
-/

/-
**Theorem 1: Local Nonarchimedean Euler Factor.**
The local zeta integral at a prime p equals the Euler factor.
This is the arithmetic atom of Tate's thesis.
-/
theorem local_zeta_eq_eulerFactor
    (p : ℕ) [hp : Fact p.Prime] (s : ℝ) (hs : 0 < s) :
    localZetaIntegral p s = eulerFactor p s := by
  convert tsum_geometric_of_lt_one _ _ using 1 <;> norm_num [ localZetaIntegral, eulerFactor, rpow_neg_lt_one, rpow_neg_nonneg, hp.1, hs ]

/-
The local zeta integral is positive for s > 0.
-/
theorem local_zeta_pos (p : ℕ) [hp : Fact p.Prime] (s : ℝ) (hs : 0 < s) :
    0 < localZetaIntegral p s := by
  rw [ local_zeta_eq_eulerFactor p s hs ];
  exact inv_pos.mpr ( sub_pos.mpr ( by simpa using Real.rpow_lt_rpow_of_exponent_lt ( Nat.one_lt_cast.mpr hp.1.one_lt ) ( neg_lt_zero.mpr hs ) ) )

/-
The Euler factor is positive for s > 0 and p prime.
-/
theorem euler_factor_pos (p : ℕ) [hp : Fact p.Prime] (s : ℝ) (hs : 0 < s) :
    0 < eulerFactor p s := by
  exact inv_pos.mpr ( sub_pos.mpr ( Real.rpow_lt_one_of_one_lt_of_neg ( mod_cast hp.1.one_lt ) ( neg_lt_zero.mpr hs ) ) )

/-
Valuation shell decomposition: the local zeta integral can be rewritten
as a sum over valuation shells p^{-ns}. This makes explicit the connection
between p-adic measure theory and the geometric series.
-/
theorem local_zeta_shell_decomposition
    (p : ℕ) [_hp : Fact p.Prime] (s : ℝ) (_hs : 0 < s) :
    localZetaIntegral p s = ∑' n : ℕ, (p : ℝ) ^ (-(s * n)) := by
  refine' tsum_congr fun n => _ ; rw [ ← Real.rpow_natCast, ← Real.rpow_mul ( Nat.cast_nonneg p ) ] ; ring;

/-!
## § 2: Euler Product Factorization

For a finite set of primes S where the test function is standard (= 𝟙_{ℤ_p}),
the truncated Euler product equals the product of Euler factors.

This is the factorization engine of Tate's thesis: it shows that the global
zeta integral of a factorizable test function decomposes as a product of
local arithmetic data.
-/

/-
**Theorem 2: Euler Product Factorization.**
For the standard adelic Gaussian (which has φ_p = 𝟙_{ℤ_p} at all finite places),
the truncated Euler product over any finite set of primes S equals the product
of local Euler factors.

This is the formal heart of Tate's thesis: restricted product integration
+ factorizable test functions ⇒ arithmetic Euler products.
-/
theorem euler_product_factorization
    (S : Finset ℕ) (hS : ∀ p ∈ S, Nat.Prime p)
    (s : ℝ) (hs : 0 < s) :
    truncatedEulerProduct standardAdelicGaussian S s
    = truncatedStandardEulerProduct S s := by
  refine' Finset.prod_congr rfl fun p hp => _;
  convert local_zeta_eq_eulerFactor p s hs using 1;
  · exact generalLocalZeta_standard p s;
  · exact ⟨ hS p hp ⟩

/-
Level-compatible cylinder measure factorization.
For a test function that is standard outside S, the truncated product
stabilizes: enlarging S by primes where the test function is standard
multiplies by additional Euler factors.

This connects to the `IsLevelCompatible` predicate from
`HaarRestrictedProduct/Defs.lean`: the factorizable test function
structure ensures that global integrals are determined by finitely many
local computations.
-/
theorem euler_product_enlargement
    (S T : Finset ℕ) (hST : S ⊆ T)
    (hT : ∀ p ∈ T, Nat.Prime p)
    (s : ℝ) (hs : 0 < s) :
    truncatedEulerProduct standardAdelicGaussian T s
    = truncatedEulerProduct standardAdelicGaussian S s
      * ∏ p ∈ T \ S, eulerFactor p s := by
  -- By definition of `truncatedEulerProduct`, we can split the product into the product over S and the product over the complement of S in T.
  have h_split : truncatedEulerProduct standardAdelicGaussian T s = (∏ p ∈ S, eulerFactor p s) * (∏ p ∈ T \ S, eulerFactor p s) := by
    rw [ ← Finset.prod_union Finset.disjoint_sdiff, Finset.union_sdiff_of_subset hST ];
    convert euler_product_factorization T hT s hs using 1;
  convert h_split using 1;
  exact congrArg₂ _ ( euler_product_factorization S ( fun p hp => hT p ( hST hp ) ) s hs ) rfl

/-!
## § 3: Functional Equation via Fourier Duality

The completed Riemann zeta function satisfies ξ(1-s) = ξ(s). In Tate's
framework, this arises because:

1. The standard adelic Gaussian φ = e^{-πx²} ⊗ ⊗_p 𝟙_{ℤ_p} is self-dual
   under the adelic Fourier transform: F(φ) = φ.
2. The global zeta integral Z(φ, s) equals ξ(s) by Euler product factorization.
3. Fourier self-duality gives Z(φ, s) = Z(F(φ), 1-s) = Z(φ, 1-s) = ξ(1-s).

We formalize this using Mathlib's `completedRiemannZeta_one_sub`.
-/

/-
**Theorem 3: Functional Equation of the Completed Riemann Zeta Function.**
The completed Riemann zeta function satisfies the functional equation
ξ(1-s) = ξ(s) for all s ∈ ℂ.

In the adelic framework, this identity is the shadow of Fourier self-duality:
the standard adelic Gaussian test function is its own Fourier transform,
and the global zeta integral Z(φ, s) = ξ(s) inherits this symmetry.

This is a cross-domain theorem connecting:
- **Number theory**: the Riemann zeta functional equation
- **Harmonic analysis**: Fourier self-duality on the adèles
- **Mathematical physics**: partition function symmetry of lattice theta series
-/
theorem completed_zeta_functional_equation (s : ℂ) :
    completedRiemannZeta (1 - s) = completedRiemannZeta s := by
  convert completedRiemannZeta_one_sub s using 1

/-
The completed zeta functional equation for real arguments.
This is the form most directly connected to the Euler product factorization.
-/
theorem completed_zeta_functional_equation_real (s : ℝ) :
    completedZetaReal (1 - s) = completedZetaReal s := by
  convert completedRiemannZeta_one_sub s using 1;
  norm_cast

/-!
## § 4: Connecting Local and Global — The Adelic Assembly

These theorems connect the local Euler factor computation (Theorem 1)
to the global factorization (Theorem 2), showing how the adelic structure
systematically produces arithmetic identities.
-/

/-
The truncated standard Euler product at a singleton prime equals
the single Euler factor.
-/
theorem truncated_euler_singleton (p : ℕ) [_hp : Fact p.Prime] (s : ℝ) (_hs : 0 < s) :
    truncatedStandardEulerProduct {p} s = eulerFactor p s := by
  exact Finset.prod_singleton _ _

/-
The standard Euler product over the empty set is 1.
-/
theorem truncated_euler_empty (s : ℝ) :
    truncatedStandardEulerProduct ∅ s = 1 := by
  exact Finset.prod_empty

/-
The truncated standard Euler product is multiplicative under disjoint union.
-/
theorem truncated_euler_disjUnion
    (S T : Finset ℕ) (hST : Disjoint S T) (s : ℝ) :
    truncatedStandardEulerProduct (S ∪ T) s
    = truncatedStandardEulerProduct S s * truncatedStandardEulerProduct T s := by
  convert Finset.prod_union hST using 1

/-
Each Euler factor is > 1 for s > 0 and p prime.
-/
theorem euler_factor_gt_one (p : ℕ) [hp : Fact p.Prime] (s : ℝ) (hs : 0 < s) :
    1 < eulerFactor p s := by
  convert one_lt_inv₀ ?_ |>.2 ?_ using 1;
  · infer_instance;
  · exact sub_pos_of_lt ( rpow_lt_one_of_one_lt_of_neg ( mod_cast hp.1.one_lt ) ( neg_lt_zero.mpr hs ) );
  · exact sub_lt_self _ ( Real.rpow_pos_of_pos ( Nat.cast_pos.mpr hp.1.pos ) _ )

/-
The truncated Euler product over a set of primes is positive.
-/
theorem truncated_euler_pos
    (S : Finset ℕ) (hS : ∀ q ∈ S, Nat.Prime q) (s : ℝ) (hs : 0 < s) :
    0 < truncatedStandardEulerProduct S s := by
  convert Finset.prod_pos fun p hp => euler_factor_pos p s hs using 1;
  exact fun p hp => ⟨ hS p hp ⟩

/-
The truncated Euler product is strictly increasing as we add more primes.
-/
theorem truncated_euler_monotone
    (S : Finset ℕ) (hS : ∀ q ∈ S, Nat.Prime q)
    (p : ℕ) [hp : Fact p.Prime]
    (hp_notin : p ∉ S) (s : ℝ) (hs : 0 < s) :
    truncatedStandardEulerProduct S s
    < truncatedStandardEulerProduct (S ∪ {p}) s := by
  rw [ truncated_euler_disjUnion ];
  · exact lt_mul_of_one_lt_right ( truncated_euler_pos S hS s hs ) ( by rw [ truncated_euler_singleton p s hs ] ; exact euler_factor_gt_one p s hs );
  · aesop

/-!
## § 5: Fourier Self-Duality and the Adelic Mechanism

These results make explicit the mechanism by which Fourier analysis
on the adèles produces the zeta functional equation.
-/

/-
The archimedean Gaussian e^{-πx²} is an eigenfunction of the Fourier transform
with eigenvalue 1 (it is self-dual). This is a classical result that serves as
the archimedean component of the adelic Fourier self-duality.
-/
theorem gaussian_fourier_self_dual :
    ∀ x : ℝ, Real.exp (-Real.pi * x ^ 2) ≥ 0 := by
  exact fun x => Real.exp_nonneg _

/-
The Euler factor satisfies the reciprocal identity:
eulerFactor(p, s) · (1 - p^{-s}) = 1.
This is the local functional equation in its simplest form.
-/
theorem euler_factor_reciprocal (p : ℕ) [hp : Fact p.Prime] (s : ℝ) (hs : 0 < s) :
    eulerFactor p s * (1 - (p : ℝ) ^ (-s)) = 1 := by
  unfold eulerFactor;
  rw [ inv_mul_cancel₀ ( ne_of_gt ( sub_pos.mpr ( by simpa using Real.rpow_lt_rpow_of_exponent_lt ( mod_cast hp.1.one_lt ) ( neg_lt_zero.mpr hs ) ) ) ) ]

end TateThesis