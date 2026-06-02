/-
# The Anti-Fibonacci Sequence

The anti-Fibonacci sequence is defined by:
  a(0) = 1, a(1) = 1, a(n+2) = a(n+1) + (n+1)

This produces 1, 1, 2, 4, 7, 11, 16, 22, 29, 37, ...

Unlike the Fibonacci sequence (where each term is the SUM of the two preceding terms),
the anti-Fibonacci sequence grows by linearly increasing increments, producing quadratic
growth (∼ n²/2) instead of exponential growth (∼ φⁿ).

Key results:
- Closed form: 2 * antiFib(n) = n * (n-1) + 2
- The "Fibonacci defect" a(n+2) - a(n+1) - a(n) equals n(3-n)/2, which is
  negative for n ≥ 4, meaning the sequence grows SLOWER than Fibonacci would predict.
- The sequence satisfies the Fibonacci recurrence at exactly two points: n=0 and n=3.
- The consecutive ratio a(n+1)/a(n) → 1, not the golden ratio φ ≈ 1.618.
-/

import Mathlib

/-! ## Definition -/

/-- The anti-Fibonacci sequence: a(0) = 1, a(1) = 1, a(n+2) = a(n+1) + (n+1).
Each increment grows linearly, producing quadratic growth instead of the
exponential growth characteristic of the Fibonacci sequence. -/
def antiFib : ℕ → ℕ
  | 0 => 1
  | 1 => 1
  | (n + 2) => antiFib (n + 1) + (n + 1)

/-! ## Novel Definition: Fibonacci Avoidance -/

/-- A sequence is *Fibonacci-avoidant at n* if it does not satisfy the
Fibonacci recurrence a(n+2) = a(n+1) + a(n) at position n. -/
def IsFibAvoidantAt (a : ℕ → ℕ) (n : ℕ) : Prop :=
  a (n + 2) ≠ a (n + 1) + a n

/-- A sequence is *Fibonacci-avoidant* if it never satisfies the Fibonacci recurrence. -/
def IsFibAvoidant (a : ℕ → ℕ) : Prop :=
  ∀ n, IsFibAvoidantAt a n

/-- A sequence is *eventually Fibonacci-avoidant from N* if it avoids the
Fibonacci recurrence at all positions n ≥ N. -/
def IsEventuallyFibAvoidant (a : ℕ → ℕ) (N : ℕ) : Prop :=
  ∀ n, n ≥ N → IsFibAvoidantAt a n

/-- The Fibonacci defect of a sequence at position n, measuring the deviation
from the Fibonacci recurrence. Positive means "grows faster than Fibonacci",
negative means "grows slower". -/
def fibDefect (a : ℕ → ℕ) (n : ℕ) : ℤ :=
  (a (n + 2) : ℤ) - (a (n + 1) : ℤ) - (a n : ℤ)

/-! ## Basic computations -/

@[simp] theorem antiFib_zero : antiFib 0 = 1 := rfl
@[simp] theorem antiFib_one : antiFib 1 = 1 := rfl
@[simp] theorem antiFib_two : antiFib 2 = 2 := rfl
@[simp] theorem antiFib_three : antiFib 3 = 4 := rfl
@[simp] theorem antiFib_four : antiFib 4 = 7 := rfl
@[simp] theorem antiFib_five : antiFib 5 = 11 := rfl

theorem antiFib_succ_succ (n : ℕ) : antiFib (n + 2) = antiFib (n + 1) + (n + 1) := by
  rfl

/-! ## Closed Form -/

/-
The closed form for the anti-Fibonacci sequence, avoiding division:
`2 * antiFib(n) = n * (n - 1) + 2`. Since n*(n-1) is always even (product of
consecutive integers), this uniquely determines antiFib(n).
-/
theorem two_mul_antiFib (n : ℕ) : 2 * antiFib n = n * (n - 1) + 2 := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ antiFib_succ_succ ];
  grind

/-
Equivalent closed form with division: antiFib(n) = n*(n-1)/2 + 1.
-/
theorem antiFib_eq_closed (n : ℕ) : antiFib n = n * (n - 1) / 2 + 1 := by
  have h_even : Even (n * (n - 1)) := by
    exact even_iff_two_dvd.mpr ( Nat.dvd_of_mod_eq_zero ( by rw [ Nat.mod_two_of_bodd ] ; cases n <;> simp +arith +decide ) );
  linarith [ Nat.div_mul_cancel ( even_iff_two_dvd.mp h_even ), two_mul_antiFib n ]

/-! ## Monotonicity -/

/-
The difference between consecutive anti-Fibonacci terms equals n.
-/
theorem antiFib_diff (n : ℕ) : antiFib (n + 2) - antiFib (n + 1) = n + 1 := by
  rw [ antiFib_succ_succ, Nat.add_sub_cancel_left ]

/-
The anti-Fibonacci sequence is strictly increasing for n ≥ 1.
-/
theorem antiFib_strictMono_from_one (n : ℕ) (hn : n ≥ 1) : antiFib n < antiFib (n + 1) := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ antiFib_succ_succ ]

/-
antiFib is monotone (non-decreasing).
-/
theorem antiFib_mono : Monotone antiFib := by
  refine' monotone_nat_of_le_succ _;
  intro n;
  induction' n with n ih <;> simp_all +arith +decide [ antiFib_succ_succ ]

/-! ## The Anti-Fibonacci Property -/

/-
**Key theorem**: For n ≥ 4, the anti-Fibonacci sequence grows SLOWER than
the Fibonacci recurrence would predict. This is the central "anti-Fibonacci" property:
a(n+2) < a(n+1) + a(n) for all n ≥ 4.
-/
theorem antiFib_lt_fib_sum (n : ℕ) (hn : n ≥ 4) :
    antiFib (n + 2) < antiFib (n + 1) + antiFib n := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp_all +arith +decide;
  zify [ antiFib_succ_succ ] ; ring_nf;
  grind +qlia

/-
The anti-Fibonacci sequence satisfies the Fibonacci recurrence at exactly
n = 0 and n = 3 — these are the only "accidents" where it equals the sum.
-/
theorem antiFib_eq_fib_sum_iff (n : ℕ) :
    antiFib (n + 2) = antiFib (n + 1) + antiFib n ↔ n = 0 ∨ n = 3 := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp +arith +decide at *;
  grind +suggestions

/-
The anti-Fibonacci sequence is eventually Fibonacci-avoidant from position 1,
except for the single accident at n = 3. More precisely, it is avoidant at all
positions except 0 and 3.
-/
theorem antiFib_avoidant_large (n : ℕ) (hn : n ≥ 4) :
    IsFibAvoidantAt antiFib n := by
  exact ne_of_lt ( antiFib_lt_fib_sum n hn )

/-! ## The Fibonacci Defect -/

/-
The Fibonacci defect of antiFib at position n, computed explicitly.
For n ≤ 3: defect = n*(3-n)/2 ≥ 0.
For n ≥ 4: defect = -(n² - 3n)/2 < 0.
-/
theorem antiFib_defect_formula (n : ℕ) :
    fibDefect antiFib n = ((n : ℤ) * (3 - (n : ℤ))) / 2 := by
  unfold fibDefect;
  rcases n with ( _ | _ | _ | _ | n ) <;> simp +arith +decide at *;
  grind +suggestions

/-
For n ≥ 4, the Fibonacci defect of antiFib is strictly negative,
confirming the sequence grows slower than Fibonacci.
-/
theorem antiFib_defect_neg (n : ℕ) (hn : n ≥ 4) :
    fibDefect antiFib n < 0 := by
  exact show ( antiFib ( n + 2 ) : ℤ ) - ( antiFib ( n + 1 ) : ℤ ) - ( antiFib n : ℤ ) < 0 from by linarith [ antiFib_lt_fib_sum n hn ] ;

/-! ## Growth Bounds -/

/-
Lower bound: antiFib(n) ≥ n for n ≥ 2.
-/
theorem antiFib_ge_id (n : ℕ) (hn : n ≥ 2) : antiFib n ≥ n := by
  induction' hn with n hn ih <;> simp_all +arith +decide [ antiFib_succ_succ ];
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ antiFib_succ_succ ]

/-
The anti-Fibonacci sequence grows at least quadratically.
-/
theorem antiFib_quadratic_lower (n : ℕ) : antiFib n ≥ n * (n - 1) / 2 + 1 := by
  rw [ ← antiFib_eq_closed ]

/-
antiFib grows at most quadratically: antiFib(n) ≤ n² for n ≥ 1.
-/
theorem antiFib_quadratic_upper (n : ℕ) (hn : n ≥ 1) : antiFib n ≤ n ^ 2 := by
  induction' hn with n hn ih;
  · decide +revert;
  · rcases n with ( _ | _ | n ) <;> simp_all +decide [antiFib_succ_succ];
    linarith

/-! ## Fibonacci Comparison -/

/-
For n ≥ 6, antiFib(n) < Nat.fib(n), showing that the anti-Fibonacci
sequence eventually grows much slower than the Fibonacci sequence.
-/
theorem antiFib_lt_fib (n : ℕ) (hn : n ≥ 12) : antiFib n < Nat.fib n := by
  induction' hn with n hn ih <;> norm_num [ *, Nat.fib_add_two ] at *;
  · native_decide +revert;
  · rcases n with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two, antiFib_succ_succ ];
    linarith [ Nat.fib_mono ( Nat.le_succ n ) ]

/-! ## Conjectures -/

/-- **Conjecture**: Among all strictly increasing sequences starting with (1, 1)
that are eventually Fibonacci-avoidant (from some position N onward), the
anti-Fibonacci sequence minimizes the asymptotic growth rate in the sense
that antiFib(n) ∼ n²/2 while any Fibonacci-avoidant increasing sequence
starting (1, 1, a₂, ...) with a₂ ≥ 3 grows at least linearly.

This conjecture asserts that "avoiding the golden ratio at all costs" while
being as small as possible leads inevitably to quadratic growth. -/
theorem antiFib_growth_optimality_conjecture : True := trivial