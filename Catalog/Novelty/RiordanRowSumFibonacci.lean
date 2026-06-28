import Mathlib

/-!
# Row sums of the Riordan array `R = (1/(1-x), x/(1-x)^2)` are odd-indexed Fibonacci numbers

The Riordan array `R = (1/(1-x), x/(1-x)^2)` has `(n,k)` entry
`t n k = C(n+k, 2k)`.  Its row sums

`s n = ∑_{k=0}^{n} C(n+k, 2k)`

satisfy `s 0 = 1`, `s 1 = 2` and `s (n+2) = 3 * s (n+1) - s n`.  Consequently the
generating function `G(x) = ∑ s n x^n` equals `(1 - x)/(1 - 3x + x^2)`, and
`s n = F_{2n+1}` where `F` is the Fibonacci sequence.

This file proves:

* `s_zero`, `s_one`, `s_rec` — the initial values and the linear recurrence (Part 1);
* `genfun_closed` / `genfun_unit_form` — the generating function identity (Part 2);
* a direct Riordan-array computation (`riordan_col_coeff`, `s_eq_riordan_rowsum`,
  `riordan_gf_closed`) showing how the closed form arises from the array product
  `(1/(1-x)) · ∑_k (x/(1-x)^2)^k` by extracting coefficients;
* `s_eq_fib` — the identification `s n = Nat.fib (2n+1)` (Part 3).
-/

namespace RiordanRowSumFibonacci

open Finset

/-- The `(n,k)` entry of the Riordan array `R = (1/(1-x), x/(1-x)^2)`. -/
def t (n k : ℕ) : ℕ := Nat.choose (n + k) (2 * k)

/-- The row-sum sequence `s n = ∑_{k=0}^{n} t n k`. -/
def s (n : ℕ) : ℕ := ∑ k ∈ Finset.range (n + 1), t n k

/-- A companion sum `v n = ∑_{j=0}^{n} C(n+1+j, 2j+1)`, equal to `F_{2n+2}`,
used to obtain the recurrence for `s`. -/
def v (n : ℕ) : ℕ := ∑ j ∈ Finset.range (n + 1), Nat.choose (n + 1 + j) (2 * j + 1)

/-! ## Part 1: initial values and the recurrence -/

lemma s_zero : s 0 = 1 := by
  rfl

lemma s_one : s 1 = 2 := by
  native_decide +revert

/-
`s (n+1) = s n + v n`: obtained from Pascal's rule on `C((n+1)+k, 2k)`.
-/
lemma s_succ (n : ℕ) : s (n + 1) = s n + v n := by
  unfold s v;
  have h_split : ∑ k ∈ Finset.range (n + 2), Nat.choose (n + 1 + k) (2 * k) = ∑ k ∈ Finset.range (n + 2), Nat.choose (n + k) (2 * k) + ∑ k ∈ Finset.range (n + 1), Nat.choose (n + 1 + k) (2 * k + 1) := by
    simp +arith +decide [ Finset.sum_range_succ', Nat.choose_succ_succ ];
    simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun _ _ => by ring;
  convert h_split using 1;
  simp +arith +decide [ Finset.sum_range_succ, t ]

/-
`v (n+1) = s (n+1) + v n`: obtained from Pascal's rule on `C((n+2)+j, 2j+1)`.
-/
lemma v_succ (n : ℕ) : v (n + 1) = s (n + 1) + v n := by
  unfold v s;
  simp +arith +decide [ Finset.sum_range_succ, t ];
  rw [ ← Finset.sum_add_distrib ] ; congr ; ext x ; simp +arith +decide [ Nat.choose_succ_succ ] ;

/-- The Riordan row sums satisfy the recurrence `s (n+2) + s n = 3 * s (n+1)`,
i.e. `s (n+2) = 3 * s (n+1) - s n`. -/
lemma s_rec (n : ℕ) : s (n + 2) + s n = 3 * s (n + 1) := by
  have h1 := s_succ n
  have h2 := s_succ (n + 1)
  have h3 := v_succ n
  simp only [show n + 1 + 1 = n + 2 from rfl] at h2
  -- s (n+2) = s (n+1) + v (n+1) = s (n+1) + (s (n+1) + v n)
  -- and s (n+1) = s n + v n, so s (n+2) + s n = 3 * s (n+1).
  omega

/-! ## Part 3: identification with Fibonacci numbers -/

/-
The Fibonacci sequence satisfies the same length-two recurrence at odd indices:
`F_{2n+5} + F_{2n+1} = 3 * F_{2n+3}`.
-/
lemma fib_odd_rec (n : ℕ) :
    Nat.fib (2 * n + 5) + Nat.fib (2 * n + 1) = 3 * Nat.fib (2 * n + 3) := by
      simp +arith +decide [ Nat.fib_add_two ]

/-
The row sums are the odd-indexed Fibonacci numbers: `s n = F_{2n+1}`.
-/
lemma s_eq_fib (n : ℕ) : s n = Nat.fib (2 * n + 1) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
  linarith! [ s_rec n, ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), fib_odd_rec n ]

/-! ## Part 2: the generating function

We work in the ring `ℚ⟦X⟧` of formal power series.  The generating function of the
row sums is `G = ∑ s n X^n`. -/

open PowerSeries

/-- The generating function `G(x) = ∑ s n x^n` of the row sums. -/
noncomputable def G : PowerSeries ℚ := PowerSeries.mk (fun n => (s n : ℚ))

/-- The denominator `1 - 3X + X^2`. -/
noncomputable def denom : PowerSeries ℚ :=
  1 - (PowerSeries.C (3 : ℚ)) * PowerSeries.X + PowerSeries.X ^ 2

lemma constantCoeff_denom : (PowerSeries.constantCoeff (R := ℚ)) denom = 1 := by
  unfold denom; norm_num;

/-
**Part 2.** The generating function identity `(1 - 3X + X^2) · G = 1 - X`,
which expresses `G = (1 - X)/(1 - 3X + X^2)`.  This is derived from the recurrence
(`s_rec`) and initial conditions (`s_zero`, `s_one`), not from the Fibonacci form.
-/
lemma genfun_closed : denom * G = 1 - PowerSeries.X := by
  ext ( _ | _ | n );
  · simp +decide [ denom, G, s_zero ];
  · simp +decide [ denom, G, mul_assoc, sub_mul, add_mul, pow_succ ];
    native_decide +revert;
  · simp +decide [ denom, G, mul_assoc, sub_mul, add_mul, pow_succ ];
    rw [ show ( s ( n + 1 + 1 ) : ℚ ) = 3 * s ( n + 1 ) - s n by exact eq_sub_of_add_eq <| mod_cast s_rec n ] ; norm_num [ PowerSeries.coeff_X ]

/-
The closed/division form `G = (1 - X) · (1 - 3X + X^2)⁻¹`.
-/
lemma genfun_unit_form :
    G = (1 - PowerSeries.X) * PowerSeries.invOfUnit denom (1 : ℚˣ) := by
      -- By definition of $G$, we know that $denom * G = 1 - X$.
      have hG : denom * G = 1 - PowerSeries.X := by
        convert genfun_closed;
      simp +decide [ ← hG, mul_assoc, mul_comm ];
      simp +decide [ constantCoeff_denom ]

/-! ## Part 2 (Riordan product form): deriving the closed form from the array

The `A`-series of the Riordan array is `A = 1/(1-x)` and its multiplier is
`h = x/(1-x)^2`.  Column `k` of the array has generating function `A · h^k`, whose
`n`-th coefficient is exactly `t n k = C(n+k, 2k)`.  The row-sum generating function
is therefore `A · ∑_k h^k = A/(1-h)`, and this rational function simplifies to the
closed form `(1-x)/(1-3x+x^2)`. -/

/-- The `A`-series `A = 1/(1-x)`. -/
noncomputable def Aser : PowerSeries ℚ := (PowerSeries.invOneSubPow ℚ 1).val

/-- The multiplier series `h = x/(1-x)^2`. -/
noncomputable def hser : PowerSeries ℚ :=
  PowerSeries.X * (PowerSeries.invOneSubPow ℚ 2).val

/-- Column `k` of the Riordan array as a power series, `A · h^k`. -/
noncomputable def col (k : ℕ) : PowerSeries ℚ := Aser * hser ^ k

/-
The Riordan column `A · h^k` equals `x^k · (1-x)^{-(2k+1)}`.
-/
lemma col_eq (k : ℕ) :
    col k = PowerSeries.X ^ k * (PowerSeries.invOneSubPow ℚ (2 * k + 1)).val := by
      unfold col;
      unfold Aser hser;
      simp +decide [ mul_pow, mul_comm, mul_left_comm, pow_add, pow_mul, invOneSubPow_eq_inv_one_sub_pow ];
      group

/-
Extracting coefficients of the `k`-th column reproduces the array entry
`t n k = C(n+k, 2k)` (and `0` when `k > n`).
-/
lemma riordan_col_coeff (n k : ℕ) :
    (PowerSeries.coeff (R := ℚ) n) (col k) = if k ≤ n then (t n k : ℚ) else 0 := by
      rw [ col_eq ];
      rw [ PowerSeries.coeff_X_pow_mul' ];
      rw [ PowerSeries.invOneSubPow_val_succ_eq_mk_add_choose ];
      split_ifs <;> simp_all +decide [ t ];
      grind

/-
The `n`-th row sum equals the sum of the `n`-th coefficients of the columns:
`s n = ∑_{k=0}^n [x^n] (A · h^k)`.
-/
lemma s_eq_riordan_rowsum (n : ℕ) :
    (s n : ℚ) = ∑ k ∈ Finset.range (n + 1), (PowerSeries.coeff (R := ℚ) n) (col k) := by
      rw [ Finset.sum_congr rfl fun k hk => riordan_col_coeff n k ];
      rw [ Finset.sum_congr rfl fun x hx => if_pos <| Finset.mem_range_succ_iff.mp hx ] ; norm_cast

lemma constantCoeff_one_sub_hser :
    (PowerSeries.constantCoeff (R := ℚ)) (1 - hser) = 1 := by
      unfold hser; aesop;

/-
The key Riordan algebraic identity `A · (1 - 3X + X^2) = (1 - X) · (1 - h)`,
which makes the geometric-sum simplification work.
-/
lemma Aser_mul_denom : Aser * denom = (1 - PowerSeries.X) * (1 - hser) := by
  rw [ Aser, hser ];
  unfold denom invOneSubPow;
  simp +decide [ mul_comm, pow_succ ];
  ext ( _ | _ | n ) <;> norm_num [ mul_assoc, mul_left_comm, mul_add, add_mul, sub_mul, mul_sub ];
  norm_num [ PowerSeries.coeff_X ]

/-
The Riordan generating function `A/(1-h) = A · (1-h)⁻¹` satisfies the same
identity `(1 - 3X + X^2) · (A/(1-h)) = 1 - X`, hence equals the closed form `G`.
-/
lemma riordan_gf_closed :
    denom * (Aser * PowerSeries.invOfUnit (1 - hser) (1 : ℚˣ)) = 1 - PowerSeries.X := by
      -- By definition of $invOfUnit$, we know that $(1 - hser) * invOfUnit (1 - hser) 1 = 1$.
      have h_inv : (1 - hser) * (1 - hser).invOfUnit 1 = 1 := by
        convert PowerSeries.mul_invOfUnit ( 1 - hser ) ( 1 : ℚˣ ) _ using 1;
        convert constantCoeff_one_sub_hser using 1;
      grind +suggestions

/-
The combinatorial generating function `G` agrees with the Riordan product
`A · (1-h)⁻¹`.
-/
lemma G_eq_riordan :
    G = Aser * PowerSeries.invOfUnit (1 - hser) (1 : ℚˣ) := by
      -- Both $G$ and $R := Aser * invOfUnit (1 - hser) (1 : ℚˣ)$ satisfy `denom * · = 1 - X` (genfun_closed and riordan_gf_closed).
      have hG : denom * G = 1 - PowerSeries.X := by
        convert genfun_closed
      have hRG : denom * (Aser * PowerSeries.invOfUnit (1 - hser) (1 : ℚˣ)) = 1 - PowerSeries.X := by
        convert riordan_gf_closed;
      -- Since `denom` is a unit, we can cancel it from both sides of the equation.
      have h_unit : IsUnit denom := by
        convert PowerSeries.isUnit_iff_constantCoeff.mpr _;
        exact isUnit_iff_ne_zero.mpr ( by erw [ constantCoeff_denom ] ; norm_num );
      exact h_unit.mul_left_cancel ( hG.trans hRG.symm )

end RiordanRowSumFibonacci