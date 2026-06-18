Create a single NEW file only — do NOT modify any existing catalog files. The new file should be self-contained and import Mathlib.Data.Nat.Digits and Mathlib.Tactic.NormNum.

Define narcissistic numbers formally:

```
def IsNarcissistic (n : ℕ) : Prop :=
  n = (n.digits 10).foldr (fun d acc => acc + d ^ (n.digits 10).length) 0
```

Prove the following theorems with COMPLETE proofs (no sorry, no incomplete tactics):

1. digit_pow_sum_le: For any natural number n with d digits (d = (n.digits 10).length), the sum of d-th powers of digits is ≤ d * 9^d. Prove this by bounding each digit by 9.

2. key_ineq: ∀ d ≥ 61, d * 9^d < 10^(d-1). Prove by induction: show base case d=61 by norm_num (compute 61 * 9^61 and 10^60 numerically), then inductive step showing the ratio (d+1)*9^(d+1) / 10^d < d*9^d / 10^(d-1) for d ≥ 61, which reduces to 9*(d+1) < 10*d, i.e., 9d + 9 < 10d, i.e., d > 9, which holds for d ≥ 61.

3. narcissistic_bound: ∀ n, IsNarcissistic n → n < 10^60. Prove by considering number of digits d: if d ≥ 61, the digit power sum < 10^(d-1) ≤ n (contradiction unless n=0, but 0 has 0 digits handled separately). If d ≤ 60, then n < 10^60 trivially since n < 10^d ≤ 10^60.

4. Instance: DecidablePred IsNarcissistic — derive from decidable equality on ℕ.

5. Specimen theorems (each proved by decide or norm_num):
   - narcissistic_1 : IsNarcissistic 1
   - narcissistic_153 : IsNarcissistic 153  
   - narcissistic_370 : IsNarcissistic 370
   - narcissistic_371 : IsNarcissistic 371
   - narcissistic_407 : IsNarcissistic 407

CRITICAL: Do NOT include any diffs to existing files. Do NOT modify Tropical/ or any other existing files. Only produce the new Narcissistic.lean file with complete proofs. Every theorem must have a full proof — no sorry, no incomplete calc blocks, no cut-off tactics.