import Mathlib

/-!
# Generalized Multinomial Convolution Identity for Latin Rectangle Enumeration

This file proves the *generalized multinomial convolution identity*:
for all natural numbers `m`, `a`, `d`,
$$ \sum_{i_1 + \cdots + i_m = d} \; \prod_{j=1}^{m} \binom{a + i_j}{a}
     \;=\; \binom{m a + d + m - 1}{d}. $$

The sum ranges over all `m`-tuples `(i_1, …, i_m)` of non-negative integers summing
to `d`, which is exactly `Finset.Nat.antidiagonalTuple m d`.

For `m = 3` this is the identity used to simplify the Bogart–Longyear formula for
`3`-row Latin rectangles, where the source calls it "easily proved with dots and
dividers".  Here it is proved for general `m` by reducing to a two–factor
*negative-binomial convolution* and inducting on the number of factors.

## Main results

* `LatinRectangleConv.negBinom_conv` : the two-factor negative binomial convolution
  `∑_{i+j=d} C(p+i,p) * C(q+j,q) = C(p+q+1+d, d)`.
* `LatinRectangleConv.sum_antidiagonalTuple_succ` : the `Fin.cons` recursion for sums
  over `antidiagonalTuple`.
* `LatinRectangleConv.multinomial_conv` : the identity, stated with `m + 1` factors.
* `LatinRectangleConv.multinomial_conv_ge_one` : the identity in the exact stated form,
  for `1 ≤ m`.
* `LatinRectangleConv.multinomial_conv_three` : the special case `m = 3`.
-/

open Finset

namespace LatinRectangleConv

/-
**Two-factor negative binomial convolution.**
`∑_{i+j=d} C(p+i, p) · C(q+j, q) = C(p+q+1+d, d)`.

This is the coefficient identity coming from
`(1-x)^{-(p+1)} · (1-x)^{-(q+1)} = (1-x)^{-(p+q+2)}`.
-/
theorem negBinom_conv (p q d : ℕ) :
    ∑ ij ∈ Finset.antidiagonal d, (p + ij.1).choose p * (q + ij.2).choose q
      = (p + q + 1 + d).choose d := by
  induction' q with q ih generalizing p d;
  · induction' d with d hd;
    · norm_num;
    · rw [ Finset.Nat.sum_antidiagonal_succ' ] ; simp_all +decide [ add_comm, add_left_comm ] ;
      simp +arith +decide [ Nat.choose_succ_succ ];
      rw [ ← Nat.choose_succ_succ', add_assoc, add_comm ];
      rw [ Nat.choose_symm_of_eq_add ] ; ring;
  · induction' d with d ih <;> simp_all +arith +decide [ Nat.choose_succ_succ ];
    simp_all +decide [ Finset.sum_add_distrib, mul_add, add_assoc, add_left_comm, add_comm, Finset.Nat.sum_antidiagonal_succ' ];
    simp_all +decide [ ← add_assoc, Nat.choose_succ_succ, Finset.sum_add_distrib, mul_add ];
    lia

/-
The `Fin.cons` recursion for a sum over `antidiagonalTuple (k+1) n`:
splitting off the first coordinate turns the tuple sum into a sum over the
ordinary antidiagonal of the first coordinate against the tuple sum of the rest.
-/
theorem sum_antidiagonalTuple_succ {M : Type*} [AddCommMonoid M] (k n : ℕ)
    (f : (Fin (k + 1) → ℕ) → M) :
    ∑ x ∈ Finset.Nat.antidiagonalTuple (k + 1) n, f x
      = ∑ ij ∈ Finset.antidiagonal n,
          ∑ y ∈ Finset.Nat.antidiagonalTuple k ij.2, f (Fin.cons ij.1 y) := by
  rw [ Finset.sum_sigma' ];
  refine' Finset.sum_bij ( fun x _ => ⟨ ( x 0, n - x 0 ), fun i => x i.succ ⟩ ) _ _ _ _ <;> simp +decide;
  · simp_all +decide [ Nat.antidiagonalTuple ];
    intro a ha; rw [ Multiset.Nat.antidiagonalTuple ] at *; simp_all +decide [ List.Nat.antidiagonalTuple ] ;
    rcases ha with ⟨ a, b, rfl, c, hc, rfl ⟩ ; simp_all +decide ;
  · intro a₁ ha₁ a₂ ha₂ h₁ h₂ h₃; ext i; induction i using Fin.inductionOn <;> simp_all +decide [ funext_iff ] ;
  · rintro ⟨ ⟨ a, b ⟩, c ⟩ h₁ h₂;
    refine' ⟨ Fin.cons a c, _, _ ⟩ <;> simp_all +decide [ Nat.antidiagonalTuple ];
    · simp_all +decide [ Multiset.Nat.antidiagonalTuple ];
      simp_all +decide [ List.Nat.antidiagonalTuple ];
      use b;
    · rw [ ← h₁, Nat.add_sub_cancel_left ];
  · exact fun a ha => congr_arg f ( funext fun i => by cases i using Fin.inductionOn <;> rfl )

/-- **Generalized multinomial convolution identity** (stated with `m + 1` factors).
`∑_{i_0 + … + i_m = d} ∏_{j} C(a + i_j, a) = C((m+1)·a + d + m, d)`. -/
theorem multinomial_conv (m a d : ℕ) :
    ∑ x ∈ Finset.Nat.antidiagonalTuple (m + 1) d, ∏ j, (a + x j).choose a
      = ((m + 1) * a + d + m).choose d := by
  induction m generalizing d with
  | zero =>
      rw [show (0 : ℕ) + 1 = 1 from rfl, Finset.Nat.antidiagonalTuple_one,
        Finset.sum_singleton]
      simp only [Fin.prod_univ_one, Matrix.cons_val_zero, one_mul, Nat.add_zero]
      exact Nat.choose_symm_add
  | succ m ih =>
      rw [sum_antidiagonalTuple_succ]
      have step : ∀ ij ∈ Finset.antidiagonal d,
          (∑ y ∈ Finset.Nat.antidiagonalTuple (m + 1) ij.2,
              ∏ j, (a + (Fin.cons ij.1 y : Fin (m + 1 + 1) → ℕ) j).choose a)
            = (a + ij.1).choose a
                * (((m + 1) * a + m) + ij.2).choose ((m + 1) * a + m) := by
        intro ij _
        have hprod : ∀ y : Fin (m + 1) → ℕ,
            (∏ j, (a + (Fin.cons ij.1 y : Fin (m + 1 + 1) → ℕ) j).choose a)
              = (a + ij.1).choose a * ∏ j, (a + y j).choose a := by
          intro y
          rw [Fin.prod_univ_succ]
          simp only [Fin.cons_zero, Fin.cons_succ]
        rw [Finset.sum_congr rfl (fun y _ => hprod y), ← Finset.mul_sum, ih ij.2]
        have harg : (m + 1) * a + ij.2 + m = ((m + 1) * a + m) + ij.2 := by ring
        rw [harg, ← Nat.choose_symm_add]
      rw [Finset.sum_congr rfl step, negBinom_conv a ((m + 1) * a + m) d]
      congr 1
      ring

/-- **Generalized multinomial convolution identity**, in the exact stated form
`∑_{i_1 + … + i_m = d} ∏_{j} C(a + i_j, a) = C(m·a + d + m - 1, d)`, for `1 ≤ m`. -/
theorem multinomial_conv_ge_one (m a d : ℕ) (hm : 1 ≤ m) :
    ∑ x ∈ Finset.Nat.antidiagonalTuple m d, ∏ j, (a + x j).choose a
      = (m * a + d + m - 1).choose d := by
  cases m with
  | zero => omega
  | succ m =>
      rw [multinomial_conv m a d]
      congr 1

/-- The special case `m = 3` used in the Bogart–Longyear `3`-row Latin rectangle formula:
`∑_{i+j+k=d} C(a+i,a)·C(a+j,a)·C(a+k,a) = C(3a+d+2, d)`. -/
theorem multinomial_conv_three (a d : ℕ) :
    ∑ x ∈ Finset.Nat.antidiagonalTuple 3 d, ∏ j, (a + x j).choose a
      = (3 * a + d + 2).choose d := by
  have := multinomial_conv 2 a d
  simpa using this

/-!
## Consequences

A few corollaries obtained by specialising the identity.
-/

/-- The two-factor convolution written directly over the ordinary antidiagonal:
`∑_{i+j=d} C(a+i,a)·C(a+j,a) = C(2a+d+1, d)`. -/
theorem two_factor_conv (a d : ℕ) :
    ∑ ij ∈ Finset.antidiagonal d, (a + ij.1).choose a * (a + ij.2).choose a
      = (2 * a + d + 1).choose d := by
  rw [negBinom_conv a a d]
  congr 1
  ring

/-- The `m = 2` case: `∑_{i+j=d} C(a+i,a)·C(a+j,a) = C(2a+d+1, d)`. -/
theorem multinomial_conv_two (a d : ℕ) :
    ∑ x ∈ Finset.Nat.antidiagonalTuple 2 d, ∏ j, (a + x j).choose a
      = (2 * a + d + 1).choose d := by
  have := multinomial_conv 1 a d
  simpa using this

/-- **Stars and bars.** Setting `a = 0` in the identity counts the tuples themselves:
the number of `(m+1)`-tuples of non-negative integers summing to `d` is `C(d + m, d)`. -/
theorem card_antidiagonalTuple (m d : ℕ) :
    (Finset.Nat.antidiagonalTuple (m + 1) d).card = (d + m).choose d := by
  have := multinomial_conv m 0 d
  simpa using this

end LatinRectangleConv