/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Sharp/flat supersingular degree sequences at a general prime `p`

For an elliptic curve with good supersingular reduction at a prime `p`, the sharp and
flat characteristic degrees of Pollack–Kobayashi type grow, along the cyclotomic
`ℤ_p`-tower, like partial sums of powers of `p` in base `p²`.  At `p = 2` this growth is
governed by the classical **Jacobsthal recurrence** `Jₙ₊₂ = Jₙ₊₁ + 2 Jₙ`, and the flat
degree is exactly the even-indexed Jacobsthal number (see the companion development of
Matsuno's μ-corrected formula).

This file carries out **Future Direction #4**: the generalisation of that arithmetic to an
arbitrary supersingular prime `p`.  The Jacobsthal sequence is replaced by the two-parameter
**generalised Jacobsthal sequence**
`qₙ₊₂ = (p − 1) qₙ₊₁ + p qₙ`,  `q₀ = 0`, `q₁ = 1`,
whose closed form is `(p + 1) qₙ = pⁿ − (−1)ⁿ` (characteristic roots `p` and `−1`), and the
base-`4` degree sums are replaced by base-`p²` sums.  We prove:

* the closed form `(p + 1) qₙ = pⁿ − (−1)ⁿ`;
* the consecutive-sum identity `qₙ + qₙ₊₁ = pⁿ`;
* the base-`p²` flat-degree closed form `(p² − 1)·flatDegP + 1 = p^{2n}`;
* the sharp/flat ratio `sharpDegP = p · flatDegP`;
* the **bridge** `q_{2n} = (p − 1)·flatDegP p n`, tying the generalised Jacobsthal
  sequence to the honest base-`p²` growth of the degrees;

and finally specialise everything back to `p = 2`, recovering the classical Jacobsthal
identities of the companion file.
-/

open scoped BigOperators
open Finset

namespace MatsunoSupersingularGeneralP

/-! ## Part I. The generalised Jacobsthal sequence -/

/-- The **generalised Jacobsthal sequence** `qₙ₊₂ = (p − 1) qₙ₊₁ + p qₙ`, `q₀ = 0`,
`q₁ = 1`, whose characteristic roots are `p` and `−1`.  At `p = 2` it is the classical
Jacobsthal sequence. -/
def qgen (p : ℤ) : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | (n + 2) => (p - 1) * qgen p (n + 1) + p * qgen p n

/-- The defining recurrence of the generalised Jacobsthal sequence. -/
theorem qgen_succ_succ (p : ℤ) (n : ℕ) :
    qgen p (n + 2) = (p - 1) * qgen p (n + 1) + p * qgen p n := rfl

/--
**Closed form**: `(p + 1) qₙ = pⁿ − (−1)ⁿ`.
-/
theorem qgen_closed (p : ℤ) (n : ℕ) : (p + 1) * qgen p n = p ^ n - (-1) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  · exact Or.inr rfl;
  · exact Eq.symm ( by erw [ show qgen p 1 = 1 from rfl ] ; ring );
  · grind +suggestions

/--
**Consecutive Jacobsthal numbers sum to a power of `p`**: `qₙ + qₙ₊₁ = pⁿ`.
-/
theorem qgen_add_succ (p : ℤ) (hp : p + 1 ≠ 0) (n : ℕ) :
    qgen p n + qgen p (n + 1) = p ^ n := by
  exact mul_left_cancel₀ hp ( by linear_combination qgen_closed p n + qgen_closed p ( n + 1 ) - pow_succ' p n )

/-! ## Part II. The base-`p²` sharp/flat degree sequences -/

/-- The **flat degree** `∑_{i<n} p^{2i}`: the base-`p²` growth of the flat characteristic
degree along the supersingular `ℤ_p`-tower. -/
def flatDegP (p n : ℕ) : ℕ := ∑ i ∈ range n, p ^ (2 * i)

/-- The **sharp degree** `∑_{i<n} p^{2i+1}`: the base-`p²` growth of the sharp degree. -/
def sharpDegP (p n : ℕ) : ℕ := ∑ i ∈ range n, p ^ (2 * i + 1)

/-- One-step growth of the flat degree. -/
theorem flatDegP_succ (p n : ℕ) : flatDegP p (n + 1) = flatDegP p n + p ^ (2 * n) := by
  unfold flatDegP; rw [Finset.sum_range_succ]

/--
**Subtraction-free closed form**: `p²·flatDegP + 1 = flatDegP + p^{2n}`.
-/
theorem p_sq_flatDegP (p n : ℕ) :
    p ^ 2 * flatDegP p n + 1 = flatDegP p n + p ^ (2 * n) := by
  induction n with
  | zero => simp [flatDegP]
  | succ k ih =>
      rw [flatDegP_succ, mul_add]
      have hb : p ^ (2 * (k + 1)) = p ^ 2 * p ^ (2 * k) := by
        rw [← pow_add]; congr 1; ring
      rw [hb]; omega

/--
**Closed form**: `(p² − 1)·flatDegP p n + 1 = p^{2n}`, i.e. `flatDegP p n =
(p^{2n} − 1)/(p² − 1)`.
-/
theorem flatDegP_closed {p : ℕ} (hp : 1 ≤ p) (n : ℕ) :
    (p ^ 2 - 1) * flatDegP p n + 1 = p ^ (2 * n) := by
  have := p_sq_flatDegP p n;
  nlinarith [ Nat.sub_add_cancel ( by nlinarith : 1 ≤ p ^ 2 ) ]

/--
The **sharp/flat ratio**: the sharp degree is exactly `p` times the flat degree.
-/
theorem sharpDegP_eq (p n : ℕ) : sharpDegP p n = p * flatDegP p n := by
  unfold sharpDegP flatDegP;
  simp +decide only [pow_succ', Finset.mul_sum _ _ _]

/--
The flat degree is strictly monotone for `p ≥ 2` (positive growth of the invariant).
-/
theorem flatDegP_strictMono {p : ℕ} (hp : 2 ≤ p) : StrictMono (flatDegP p) := by
  exact strictMono_nat_of_lt_succ fun n => by simp [ flatDegP_succ p n ] ; positivity;

/-! ## Part III. The bridge between the two sequences -/

/--
**Bridge identity**: `q_{2n}(p) = (p − 1)·flatDegP p n`.  This ties the generalised
Jacobsthal sequence to the honest base-`p²` growth of the sharp/flat degrees.  At `p = 2`
it collapses to `q_{2n} = flatDegP`, recovering the classical statement.
-/
theorem qgen_two_mul {p : ℕ} (hp : 2 ≤ p) (n : ℕ) :
    qgen (p : ℤ) (2 * n) = ((p : ℤ) - 1) * (flatDegP p n : ℤ) := by
  have := @qgen_closed p ( 2 * n );
  have := p_sq_flatDegP p n; norm_num [ pow_mul ] at *;
  nlinarith

/-! ## Part IV. Specialisation to `p = 2` (recovering the classical Jacobsthal identities) -/

/-- At `p = 2` the closed form reads `3 qₙ = 2ⁿ − (−1)ⁿ` — the classical Jacobsthal closed
form. -/
theorem three_qgen_two (n : ℕ) : 3 * qgen 2 n = 2 ^ n - (-1) ^ n := by
  have h := qgen_closed 2 n
  norm_num at h ⊢
  linarith [h]

/-- At `p = 2` the flat-degree closed form reads `3·flatDegP 2 n + 1 = 4ⁿ`, matching the
classical base-`4` growth. -/
theorem three_flatDegP_two (n : ℕ) : 3 * flatDegP 2 n + 1 = 4 ^ n := by
  have h := flatDegP_closed (p := 2) (by norm_num) n
  norm_num at h ⊢
  rw [show (4 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul]
  linarith [h]

/-- At `p = 2` the bridge collapses to `q_{2n} = flatDegP 2 n`. -/
theorem qgen_two_mul_two (n : ℕ) : qgen 2 (2 * n) = (flatDegP 2 n : ℤ) := by
  have h := qgen_two_mul (p := 2) (by norm_num) n
  simpa using h

/-! ## Part V. Examples and sanity checks (PEGB compliance) -/

section Examples

#check @qgen_closed
#check @qgen_two_mul
#check @flatDegP_closed

-- First few generalised Jacobsthal numbers at `p = 3`: `0, 1, 2, 7, 20, 61`.
example : qgen 3 0 = 0 := rfl
example : qgen 3 4 = 20 := by decide
-- Base-`9` flat degrees: `flatDegP 3 = 0, 1, 10, 91, …`.
example : flatDegP 3 3 = 91 := by decide
-- Bridge at `p = 3, n = 2`: `q₄(3) = 2·flatDegP 3 2 = 20`.
example : qgen 3 4 = ((3 : ℤ) - 1) * (flatDegP 3 2 : ℤ) := by decide

end Examples

end MatsunoSupersingularGeneralP