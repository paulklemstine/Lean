import Mathlib
import Catalog.Novelty.RatioSpectrum.MobiusQuadratic

/-!
# Determinant structure of the ratio spectrum (Phase A, v19c)

The Lagarias–Shallit bounds say that for an integer matrix `M` of nonzero
determinant the Lagrange-constant ratio satisfies
`1/|det M| ≤ k(M x)/k(x) ≤ |det M|`, and the density conjecture asserts these
ratios fill the whole interval `[1/|det M|, |det M|]` as `x` ranges over real
quadratic irrationals.

This file establishes the **structural backbone** of that target interval and of
the Möbius action that produces it:

* the target interval is always nonempty and contains `1` (because an integer
  matrix of nonzero determinant has `|det| ≥ 1`);
* its endpoints are reciprocal (`(1/|det|) * |det| = 1`), reflecting the
  `M ↔ M⁻¹` symmetry of the ratio spectrum;
* **primitivity is the right normalization**: the Möbius action is invariant
  under scaling all entries by a nonzero integer, so only the *primitive* part of
  `M` matters — exactly why the density statement is phrased for primitive `M`
  (cf. reduction via Smith normal form);
* the Möbius action is a (partial) action of the integer matrix monoid:
  composition of Möbius maps is the Möbius map of the matrix product, whose
  determinant multiplies — so the reachable interval of `M N` sits inside the
  product of the intervals of `M` and `N`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the endpoints `1/|det|` and `|det|` are not arbitrary —
they are forced by two independent facts: integrality (`|det| ≥ 1`) and the
reciprocal `M ↔ M⁻¹` symmetry.  Bold form: the *only* invariant of `M` visible to
the ratio spectrum's support is `|det|` together with the primitive class.

Experiment (Experimenter): `|det| ≥ 1` is `Int.one_le_abs` on a nonzero integer.
Scaling invariance `mobius (k•M) = mobius M` is a field computation cancelling the
common factor `k`.  Composition `mobius M ∘ mobius N = mobius (M*N)` is a longer
`field_simp` identity; determinant multiplicativity `det (M*N) = det M · det N` is
a bare `ring` identity on the explicit `2×2` entries.

Analysis (Analyst): the interval facts (`one_mem`, `endpoints_mul`,
`lower_le_upper`) are corollaries of `|det| ≥ 1` once `D := |det| ≥ 1` is in
hand.  The substantive structural inputs are the two action identities; they show
the spectrum problem is a problem about the monoid of integer matrices acting by
Möbius maps, with `|det| : ℤˣ-blind` only through its absolute value.

Critique (Critic): the composition identity needs *both* the inner and the
composed denominators to be nonzero; dropping either makes `mobius` ill-defined.
Scaling invariance needs only `k ≠ 0` — it holds for every real `x`, since the
common factor `k` cancels in numerator and denominator.  None of the statements
is vacuous: each is exercised by `mobius` on genuine inputs.

Synthesis (PI): together with the closure theorem of `MobiusQuadratic`, these
identities reduce the density program to (a) controlling `k` along periodic
continued fractions and (b) the Smith-normal-form reduction to `diag(1, |det|)`,
both isolated as future directions.
-/

namespace RatioSpectrum

open scoped Classical

/-
An integer matrix of nonzero determinant has absolute determinant `≥ 1`.
-/
theorem one_le_absDet (p q r s : ℤ) (hdet : p * s - q * r ≠ 0) :
    (1 : ℤ) ≤ |p * s - q * r| := by
  exact abs_pos.mpr hdet

/-
The real absolute determinant is `≥ 1`.
-/
theorem one_le_absDet_real (p q r s : ℤ) (hdet : p * s - q * r ≠ 0) :
    (1 : ℝ) ≤ ((|p * s - q * r| : ℤ) : ℝ) := by
  exact_mod_cast one_le_absDet p q r s hdet

/-
`1` lies in the target interval: `1/|det| ≤ 1 ≤ |det|`.
-/
theorem one_mem_spectrum_interval (p q r s : ℤ) (hdet : p * s - q * r ≠ 0) :
    1 / ((|p * s - q * r| : ℤ) : ℝ) ≤ 1 ∧ (1 : ℝ) ≤ ((|p * s - q * r| : ℤ) : ℝ) := by
  exact ⟨ div_le_self zero_le_one <| mod_cast abs_pos.mpr hdet, mod_cast abs_pos.mpr hdet ⟩

/-
The target interval is nonempty: lower endpoint `≤` upper endpoint.
-/
theorem spectrum_lower_le_upper (p q r s : ℤ) (hdet : p * s - q * r ≠ 0) :
    1 / ((|p * s - q * r| : ℤ) : ℝ) ≤ ((|p * s - q * r| : ℤ) : ℝ) := by
  rw [ div_le_iff₀ ] <;> norm_cast;
  · nlinarith [ abs_pos.mpr hdet ];
  · positivity

/-
**Reciprocal endpoints.**  The product of the two endpoints of the target
interval is `1`, reflecting the `M ↔ M⁻¹` symmetry of the ratio spectrum.
-/
theorem spectrum_endpoints_mul (p q r s : ℤ) (hdet : p * s - q * r ≠ 0) :
    (1 / ((|p * s - q * r| : ℤ) : ℝ)) * ((|p * s - q * r| : ℤ) : ℝ) = 1 := by
  rw [ div_mul_cancel₀ _ ( by norm_cast; aesop ) ]

/-
**Primitivity is the right normalization.**  Scaling every entry of the matrix
by a nonzero integer `k` does not change the Möbius action; hence the ratio
spectrum depends only on the primitive class of `M`.
-/
theorem mobius_smul_invariant (k p q r s : ℤ) (hk : k ≠ 0) (x : ℝ) :
    mobius (k * p) (k * q) (k * r) (k * s) x = mobius p q r s x := by
  unfold mobius;
  convert mul_div_mul_left _ _ ( show ( k : ℝ ) ≠ 0 by simpa ) using 1 ; push_cast ; ring

/-
**Determinant multiplicativity** on the explicit `2×2` integer entries: the
determinant of the matrix product is the product of determinants.
-/
theorem det_mul (p q r s p' q' r' s' : ℤ) :
    (p * p' + q * r') * (r * q' + s * s') - (p * q' + q * s') * (r * p' + s * r')
      = (p * s - q * r) * (p' * s' - q' * r') := by
  grind +splitImp

/-
**Composition of Möbius maps is the Möbius map of the matrix product.**  The
integer matrix monoid acts on `ℝ` by (partial) Möbius transformations.
-/
theorem mobius_comp (p q r s p' q' r' s' : ℤ) (x : ℝ)
    (hden1 : (r' : ℝ) * x + (s' : ℝ) ≠ 0)
    (hden2 : ((r * p' + s * r' : ℤ) : ℝ) * x + ((r * q' + s * s' : ℤ) : ℝ) ≠ 0) :
    mobius p q r s (mobius p' q' r' s' x)
      = mobius (p * p' + q * r') (p * q' + q * s') (r * p' + s * r') (r * q' + s * s') x := by
  unfold mobius;
  grind +revert

end RatioSpectrum