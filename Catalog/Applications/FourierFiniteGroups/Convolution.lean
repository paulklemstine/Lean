import Catalog.Applications.FourierFiniteGroups.Basic

/-!
# Convolution theorem and Parseval/Plancherel identity on `ZMod N`

We define cyclic convolution on `ZMod N` and prove:

* the **convolution theorem** `dft_dconv`: the discrete Fourier transform turns
  convolution into pointwise multiplication, `𝓕 (f ⋆ g) = 𝓕 f · 𝓕 g`;
* **character orthogonality** `sum_stdAddChar_mul` for the standard additive
  character;
* **Parseval/Plancherel** `dft_parseval`: `∑ₖ ‖𝓕 f k‖² = N · ∑ⱼ ‖f j‖²`.

Mathlib has the discrete transform `ZMod.dft` but none of these identities for it.

-- !-- Lab Notes -- !--
Hypothesis (H3): `𝓕` diagonalises convolution.  Experiment: a change of variables
`x ↦ x - y` (a group automorphism of `ZMod N`) together with character
multiplicativity `χ(a+b)=χ(a)χ(b)` factors the double sum, with *no* orthogonality
needed — this is the algebraic heart of the DFT-as-representation-theory picture.
Hypothesis (H4): Plancherel holds with constant `N`.  Experiment: expand
`∑ₖ |𝓕 f k|²` as a triple sum and collapse the inner `k`-sum using character
orthogonality `∑ₖ χ((l-j)k) = N·[l=j]` (`AddChar.sum_mulShift` + primitivity of
`ZMod.stdAddChar`).
Analysis: orthogonality is the *only* extra ingredient distinguishing Parseval
from the convolution theorem; both reduce to the two structural facts
"characters multiply" and "characters sum to zero unless trivial".
Critique: the constant `N` is forced (test `f = δ₀`, giving `∑|𝓕 f|² = N` and
`∑|f|² = 1`); a different normalisation of `dft` would change it.
-/

open scoped BigOperators
open Classical

namespace Catalog.FourierFiniteGroups

variable {N : ℕ} [NeZero N]

/-- Cyclic convolution on `ZMod N`: `(f ⋆ g)(x) = ∑_y f(y) · g(x - y)`. -/
noncomputable def dconv (f g : ZMod N → ℂ) : ZMod N → ℂ :=
  fun x => ∑ y, f y * g (x - y)

/-
**Convolution theorem.**  The discrete Fourier transform maps convolution to
pointwise multiplication.
-/
theorem dft_dconv (f g : ZMod N → ℂ) :
    ZMod.dft (dconv f g) = fun k => ZMod.dft f k * ZMod.dft g k := by
  ext k;
  -- By changing the variables from `x` to `z` in the inner sum, we can factor the sum into a product of two sums.
  have h2 : ∑ x : ZMod N, (ZMod.stdAddChar (-(x * k))) * (∑ y : ZMod N, f y * g (x - y)) = ∑ y : ZMod N, f y * ∑ x : ZMod N, (ZMod.stdAddChar (-(x * k))) * g (x - y) := by
    simpa only [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] using Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
  -- By changing the variables from `x` to `z` in the inner sum, we can rewrite it using the properties of the character.
  have h3 : ∀ y : ZMod N, ∑ x : ZMod N, (ZMod.stdAddChar (-(x * k))) * g (x - y) = (ZMod.stdAddChar (-(y * k))) * ∑ z : ZMod N, (ZMod.stdAddChar (-(z * k))) * g z := by
    intro y; rw [ Finset.mul_sum _ _ _ ] ; rw [ ← Equiv.sum_comp ( Equiv.addRight y ) ] ; simp +decide ;
    simp +decide [ ← mul_assoc, ← AddChar.map_add_eq_mul, add_mul ];
  convert h2 using 1;
  simp +decide only [h3];
  simp +decide [ ZMod.dft_apply, Finset.sum_mul _ _ _, mul_comm, mul_left_comm, Finset.mul_sum ]

/-
**Character orthogonality** for the standard additive character of `ZMod N`:
summing `χ(m·k)` over `k` gives `N` if `m = 0` and `0` otherwise.
-/
lemma sum_stdAddChar_mul (m : ZMod N) :
    ∑ k, ZMod.stdAddChar (m * k) = if m = 0 then (N : ℂ) else 0 := by
  have h_sum_mulShift : ∑ k : ZMod N, ZMod.stdAddChar (k * m) = if m = 0 then (N : ℂ) else 0 := by
    have := @AddChar.sum_mulShift ( ZMod N );
    convert this m ( ZMod.isPrimitive_stdAddChar N ) using 1;
    split_ifs <;> simp +decide [ * ];
  simpa only [ mul_comm ] using h_sum_mulShift

/-
**Parseval / Plancherel identity** for the discrete Fourier transform on
`ZMod N`: the squared `L²` norm of the transform equals `N` times the squared
`L²` norm of the original function.
-/
theorem dft_parseval (f : ZMod N → ℂ) :
    ∑ k, ‖ZMod.dft f k‖ ^ 2 = N * ∑ j, ‖f j‖ ^ 2 := by
  -- Expand the square of the norm using the definition of DFT.
  have h_expand : ∀ k : ZMod N, ‖ZMod.dft f k‖ ^ 2 = (∑ j : ZMod N, f j * ZMod.stdAddChar (-(j * k))) * (∑ l : ZMod N, starRingEnd ℂ (f l) * ZMod.stdAddChar (l * k)) := by
    intro k;
    convert congr_arg ( fun x : ℂ => x * starRingEnd ℂ x ) ( ZMod.dft_apply f k ) using 1;
    · rw [ Complex.mul_conj, Complex.normSq_eq_norm_sq, Complex.ofReal_pow ];
    · simp +decide [ mul_comm, AddChar.map_neg_eq_conj ];
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ k : ZMod N, (∑ j : ZMod N, f j * ZMod.stdAddChar (-(j * k))) * (∑ l : ZMod N, starRingEnd ℂ (f l) * ZMod.stdAddChar (l * k)) = ∑ l : ZMod N, ∑ j : ZMod N, starRingEnd ℂ (f l) * f j * ∑ k : ZMod N, ZMod.stdAddChar ((l - j) * k) := by
    simp +decide only [mul_comm, Finset.mul_sum _ _ _, mul_left_comm];
    rw [ Finset.sum_comm ] ; congr ; ext ; rw [ Finset.sum_comm ] ; congr ; ext ; ring_nf;
    simp +decide [ mul_assoc, mul_comm, mul_left_comm, sub_eq_add_neg, AddChar.map_add_eq_mul ];
  -- Apply the orthogonality lemma to simplify the inner sum.
  have h_orthogonality : ∀ l j : ZMod N, ∑ k : ZMod N, ZMod.stdAddChar ((l - j) * k) = if l = j then (N : ℂ) else 0 := by
    intro l j; split_ifs with h; simp_all +decide ;
    convert sum_stdAddChar_mul ( l - j ) using 1 ; simp +decide [ sub_eq_iff_eq_add, h ];
  convert congr_arg Complex.re h_fubini using 1;
  · rw [ ← Finset.sum_congr rfl fun _ _ => h_expand _ ] ; norm_cast;
  · simp +decide [ h_orthogonality, Finset.mul_sum _ _ _ ];
    norm_num [ Complex.normSq, Complex.sq_norm, mul_comm ]

end Catalog.FourierFiniteGroups