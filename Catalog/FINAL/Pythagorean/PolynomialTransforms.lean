import Mathlib
import Speculative.RiemannHypothesis.Defs

/-!
# Polynomial Root-Location Transforms

This file establishes formal bridge theorems between different root-location
predicates for complex polynomials, connecting:

1. **Critical line** (`Re(z) = 1/2`) — the RH condition
2. **Imaginary axis** (`Re(z) = 0`) — after horizontal shift
3. **Real line** (`Im(z) = 0`) — after rotation

These transforms are the formal backbone connecting RH-style geometry to
classical stability theory, Schur stability, and self-inversive polynomial theory.

## Main Results

- `re_eq_half_iff_shifted_re_zero`: pointwise critical line ↔ imaginary axis
- `re_zero_iff_rotated_im_zero`: pointwise imaginary axis ↔ real line
- `re_eq_half_iff_rotated_shifted_real`: full pipeline pointwise
- `critical_line_iff_shifted_imaginary_axis`: polynomial-level transform
-/

namespace RH

/-! ## Root-Location Equivalences for Individual Points -/

/-
A complex number has `Re(z) = 1/2` iff `z - 1/2` has `Re = 0`.
-/
theorem re_eq_half_iff_shifted_re_zero (z : ℂ) :
    z.re = (1 : ℝ) / 2 ↔ (z - (1/2 : ℂ)).re = 0 := by
  norm_num [ sub_eq_iff_eq_add ]

/-
A complex number has `Re(z) = 0` iff `(i·z)` has `Im = 0` (i.e., is real).
-/
theorem re_zero_iff_rotated_im_zero (z : ℂ) :
    z.re = 0 ↔ (Complex.I * z).im = 0 := by
  aesop

/-
Combining: `Re(z) = 1/2` iff `i·(z - 1/2)` is real.
-/
theorem re_eq_half_iff_rotated_shifted_real (z : ℂ) :
    z.re = (1 : ℝ) / 2 ↔ (Complex.I * (z - (1/2 : ℂ))).im = 0 := by
  constructor <;> intro <;> norm_num at * <;> linarith

/-! ## Polynomial-Level Root-Location Transforms -/

/-
Critical-line roots ↔ imaginary-axis roots after shifting by `1/2`.

    This is the key reduction: studying roots on `Re(z) = 1/2` is equivalent
    to studying roots on the imaginary axis for a shifted polynomial.
-/
theorem critical_line_iff_shifted_imaginary_axis (P : Polynomial ℂ) :
    CriticalLineRoots P ↔
    ImagAxisRoots (P.comp (Polynomial.X + Polynomial.C (1/2 : ℂ))) := by
  -- By definition of polynomial composition, $z$ is a root of $P$ if and only if $z - 1/2$ is a root of $P.comp (X + C (1/2))$.
  have h_root_comp : ∀ z : ℂ, P.IsRoot z ↔ (P.comp (Polynomial.X + Polynomial.C (1 / 2))).IsRoot (z - 1 / 2) := by
    norm_num [ Polynomial.IsRoot ];
  constructor <;> intro h z hz;
  · specialize h ( z + 1 / 2 ) ; aesop;
  · have := h _ ( h_root_comp _ |>.1 hz ) ; norm_num at * ; linarith

/-! ## Self-Inversive Polynomial Infrastructure

A polynomial is *self-inversive* if it equals its own "reciprocal" (up to
a unit). Self-inversive polynomials have the property that their roots come
in pairs `{z, 1/z̄}`, which (after appropriate centering) corresponds to
critical-line symmetry.
-/

/-- A polynomial `P` of degree `n` is self-inversive if `z^n · P(1/z̄) = ε · P(z)`
    for some `|ε| = 1`. We define a simplified version for monic polynomials. -/
def IsSelfInversive (P : Polynomial ℂ) : Prop :=
  ∃ ε : ℂ, ‖ε‖ = 1 ∧
    ∀ z : ℂ, z ≠ 0 → P.eval z = ε * z ^ P.natDegree * P.eval (1 / starRingEnd ℂ z)

/-
Roots of a self-inversive polynomial come in conjugate-reciprocal pairs:
    if `z` is a root, then `1/z̄` is also a root (provided `z ≠ 0`).
-/
theorem self_inversive_root_pairing (P : Polynomial ℂ) (hP : IsSelfInversive P)
    (z : ℂ) (hz : z ≠ 0) (hroot : P.IsRoot z) :
    P.IsRoot (1 / starRingEnd ℂ z) := by
  have := hP.choose_spec.2 z hz ; simp_all +decide;
  have := hP.choose_spec.1; aesop;

end RH