/-
# Narcissistic (Armstrong) numbers

A natural number `n` is *narcissistic* (an Armstrong number) if it equals the sum
of its own decimal digits each raised to the power of the number of digits.

## Note on the definition and imports

The task statement proposed the definition

```
def IsNarcissistic (n : ℕ) : Prop :=
  n = (n.digits 10).foldr (fun d acc => acc + d ^ (n.digits 10).length) 0
```

However, in Lean 4 the dot-notation `n.digits 10` elaborates to `Nat.digits n 10`
(the base-`n` digits of the number `10`), *not* the base-`10` digits of `n`.
Under that reading `IsNarcissistic 153` is `153 = 10`, which is false, and indeed
all of the intended specimen theorems below would be false.  The mathematically
intended object is the list of base-`10` digits of `n`, i.e. `Nat.digits 10 n`,
so we use that corrected form here.

The task also asked to `import Mathlib.Data.Nat.Digits`.  In this Mathlib version
that module was split into a directory (`Defs`/`Div`/`Lemmas`); we import
`Mathlib.Data.Nat.Digits.Lemmas`, which provides the same digit API.
-/
import Mathlib.Data.Nat.Digits.Lemmas
import Mathlib.Tactic.NormNum

/-- A natural number is **narcissistic** if it equals the sum of its decimal
digits each raised to the power of the number of digits. -/
def IsNarcissistic (n : ℕ) : Prop :=
  n = (Nat.digits 10 n).foldr (fun d acc => acc + d ^ (Nat.digits 10 n).length) 0

/-
Auxiliary bound: for a list of natural numbers all bounded by `9`, the
`foldr`-sum of `E`-th powers is at most `length * 9 ^ E`.
-/
theorem foldr_pow_le (l : List ℕ) (E : ℕ) (h : ∀ x ∈ l, x ≤ 9) :
    l.foldr (fun d acc => acc + d ^ E) 0 ≤ l.length * 9 ^ E := by
  induction l <;> simp_all +decide [ Nat.succ_mul ];
  exact add_le_add ‹_› ( Nat.pow_le_pow_left h.1 _ )

/-
**Theorem 1.** For any `n` with `d = (Nat.digits 10 n).length` digits, the sum
of the `d`-th powers of the digits is at most `d * 9 ^ d`.
-/
theorem digit_pow_sum_le (n : ℕ) :
    (Nat.digits 10 n).foldr (fun d acc => acc + d ^ (Nat.digits 10 n).length) 0
      ≤ (Nat.digits 10 n).length * 9 ^ (Nat.digits 10 n).length := by
  convert foldr_pow_le _ _ _;
  exact fun x hx => Nat.le_of_lt_succ <| Nat.digits_lt_base' hx

/-
**Theorem 2.** For every `d ≥ 61`, `d * 9 ^ d < 10 ^ (d - 1)`.
-/
theorem key_ineq : ∀ d : ℕ, 61 ≤ d → d * 9 ^ d < 10 ^ (d - 1) := by
  intro d hd; induction hd <;> norm_num [ Nat.pow_succ' ] at *;
  cases ‹61 ≤ _› <;> norm_num [ Nat.pow_succ' ] at * ; nlinarith [ pow_pos ( by decide : 0 < 9 ) ‹_› ]

/-
**Theorem 3.** Every narcissistic number is less than `10 ^ 60`.
-/
theorem narcissistic_bound : ∀ n, IsNarcissistic n → n < 10 ^ 60 := by
  intro n hn;
  -- By contradiction, assume $d \geq 61$.
  by_contra h_contra
  have h_d_ge_61 : 61 ≤ (Nat.digits 10 n).length := by
    rw [ Nat.digits_len ] <;> try linarith;
    exact Nat.succ_le_succ ( Nat.le_log_of_pow_le ( by norm_num ) ( by linarith ) );
  -- Then `n < 10^(d-1)` and `10^(d-1) ≤ n` contradict via `omega`/`Nat.lt_irrefl`.
  have h_contradiction : n < 10 ^ ((Nat.digits 10 n).length - 1) ∧ 10 ^ ((Nat.digits 10 n).length - 1) ≤ n := by
    constructor;
    · convert key_ineq _ h_d_ge_61 |> lt_of_le_of_lt _;
      convert digit_pow_sum_le n using 1;
    · rw [ ← Nat.le_log_iff_pow_le, Nat.digits_len ] <;> aesop;
  grind

/-- **Theorem 4.** Being narcissistic is decidable. -/
instance : DecidablePred IsNarcissistic := fun n => by
  unfold IsNarcissistic; infer_instance

/-- **Specimen.** `1` is narcissistic. -/
theorem narcissistic_1 : IsNarcissistic 1 := by decide

/-- **Specimen.** `153` is narcissistic. -/
theorem narcissistic_153 : IsNarcissistic 153 := by decide

/-- **Specimen.** `370` is narcissistic. -/
theorem narcissistic_370 : IsNarcissistic 370 := by decide

/-- **Specimen.** `371` is narcissistic. -/
theorem narcissistic_371 : IsNarcissistic 371 := by decide

/-- **Specimen.** `407` is narcissistic. -/
theorem narcissistic_407 : IsNarcissistic 407 := by decide