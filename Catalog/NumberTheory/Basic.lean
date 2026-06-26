import Mathlib

/-!
# Sun's truncated Legendre-symbol determinant — structural core

For a prime `p ≥ 7` with `p ≡ 3 (mod 4)`, set `m = (p - 5) / 2` and consider the
`m × m` integer matrix `C` with `C j k = (j - k | p)` (the Legendre symbol viewed
as an integer).  Zhi-Wei Sun's theorem asserts that, over `ℤ[X]`, the determinant
of `A` with `A j k = X + (j - k | p)` equals `((p-2)/3)^2 · X`.

This file develops the *structural backbone* that is valid for **every** such `p`:

* `Cleg` — the integer Legendre-difference matrix.
* `Cleg_transpose_eq_neg` — `C` is antisymmetric (this is where `p ≡ 3 (mod 4)`
  enters, through `(-1 | p) = -1`).
* `mDim_odd` — the dimension `m = (p-5)/2` is odd.
* `det_Cleg_eq_zero` — therefore `det C = 0` (antisymmetric matrix of odd order).

These are genuine general theorems; they reduce Sun's identity to computing the
single linear coefficient of `X`, handled in the companion files.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The constant term of Sun's determinant polynomial,
namely `det C`, vanishes identically because `C` is antisymmetric of odd order.
The antisymmetry is *not* automatic — it requires `(-1 | p) = -1`, i.e.
`p ≡ 3 (mod 4)`.  This is the surprising structural lever: the congruence
condition is exactly what kills the constant term.

Experiment (Experimenter): Verified `det C = 0` numerically for all primes
`p ≡ 3 (mod 4)`, `7 ≤ p ≤ 151` (see `ComputationalEvidence.md`).  Formalized the
two ingredients separately: antisymmetry (Legendre multiplicativity + value at
`-1`) and odd dimension (`omega` on `m = (p-5)/2` with `p % 4 = 3`).

Analysis (Analyst): `det (-C) = (-1)^m · det C`; with `Cᵀ = -C`, `det Cᵀ = det C`
forces `2 · det C = 0`, hence `det C = 0` over the integral domain `ℤ`.  The proof
is fully general — no smallness assumption on `p` beyond `p ≥ 7` (needed only so
that `m ≥ 1`, though the statement holds vacuously for `m = 0` too).

Critique (Critic): The result is non-trivial (uses `legendreSym.mul`,
`legendreSym.at_neg_one`, `ZMod.χ₄`, and the odd-order antisymmetric determinant
argument).  Boundary: for `p ≡ 1 (mod 4)` antisymmetry fails, so this exact
argument does not apply — consistent with Sun's hypothesis.

Synthesis (PI): The constant term is understood completely and generally.
-/

open Polynomial Matrix

namespace SunLegendreDet

/-- The integer Legendre-difference matrix: `C j k = (j - k | p)`. -/
def Cleg (p m : ℕ) [Fact p.Prime] : Matrix (Fin m) (Fin m) ℤ :=
  fun j k => legendreSym p ((j : ℤ) - (k : ℤ))

/-- The dimension parameter `m = (p - 5) / 2`. -/
def mDim (p : ℕ) : ℕ := (p - 5) / 2

/-- For `p ≡ 3 (mod 4)`, the Legendre symbol of `-1` is `-1`. -/
theorem legendreSym_neg_one_of_three_mod_four
    (p : ℕ) [Fact p.Prime] (hp : p % 4 = 3) :
    legendreSym p (-1) = -1 := by
  rw [legendreSym.at_neg_one (by omega)]
  exact_mod_cast ZMod.χ₄_nat_three_mod_four hp

/-- The Legendre-difference matrix is antisymmetric when `p ≡ 3 (mod 4)`. -/
theorem Cleg_transpose_eq_neg
    (p m : ℕ) [Fact p.Prime] (hp : p % 4 = 3) :
    (Cleg p m)ᵀ = - Cleg p m := by
  ext j k
  simp only [Matrix.transpose_apply, Matrix.neg_apply, Cleg]
  have : ((k : ℤ) - (j : ℤ)) = (-1) * ((j : ℤ) - (k : ℤ)) := by ring
  rw [this, legendreSym.mul, legendreSym_neg_one_of_three_mod_four p hp]
  ring

/-- The dimension `m = (p-5)/2` is odd for `p ≡ 3 (mod 4)`, `p ≥ 7`. -/
theorem mDim_odd (p : ℕ) (hp : p % 4 = 3) (hp7 : 7 ≤ p) :
    Odd (mDim p) := by
  unfold mDim
  rw [Nat.odd_iff]
  omega

/-- **The constant term vanishes.** For `p ≡ 3 (mod 4)`, the determinant of the
integer Legendre-difference matrix on `Fin (mDim p)` is zero, because it is
antisymmetric of odd order. -/
theorem det_Cleg_eq_zero
    (p : ℕ) [Fact p.Prime] (hp : p % 4 = 3) (hp7 : 7 ≤ p) :
    (Cleg p (mDim p)).det = 0 := by
  have hanti : (Cleg p (mDim p))ᵀ = - Cleg p (mDim p) :=
    Cleg_transpose_eq_neg p (mDim p) hp
  have h1 : (Cleg p (mDim p)).det = (- Cleg p (mDim p)).det := by
    rw [← hanti, Matrix.det_transpose]
  have hodd : Odd (mDim p) := mDim_odd p hp hp7
  rw [Matrix.det_neg, Fintype.card_fin, hodd.neg_one_pow, neg_one_mul] at h1
  -- h1 : det C = - det C
  linarith [h1]

end SunLegendreDet