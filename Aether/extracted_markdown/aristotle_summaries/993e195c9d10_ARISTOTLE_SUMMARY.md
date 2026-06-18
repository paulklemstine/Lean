# Summary of changes for run 18bb48d1-75ee-4ad5-9d7d-81e39b0f6e76
Created a single self-contained Lean 4 file `Catalog/Cryptography/Rule90Complexity.lean` formalizing and proving the exact row-complexity theorem for Rule 90.

What it contains (all proved, no `sorry`, only standard axioms `propext`/`Classical.choice`/`Quot.sound`):

- Module docstring stating that Rule 90 rows are Pascal rows mod 2, the exact formula, and the two infinite subsequences.
- `complexity (t)` — the requested definition counting indices `k ≤ t` with `Nat.choose t k` odd.
- `bitcount : ℕ → ℕ` — a population-count function defined by parity splitting, with recurrences `bitcount_two_mul : bitcount (2*n) = bitcount n` and `bitcount_two_mul_add_one : bitcount (2*n+1) = bitcount n + 1`.
- Parity classification lemmas, derived conservatively from the base-2 case of Mathlib's Lucas theorem (`Choose.choose_modEq_choose_mod_mul_choose_div_nat`), rather than a hand-rolled broad Lucas theorem:
  - `odd_choose_two_mul_iff : Odd (choose (2*n) m) ↔ (Even m ∧ Odd (choose n (m/2)))`
  - `odd_choose_two_mul_add_one_iff : Odd (choose (2*n+1) m) ↔ Odd (choose n (m/2))`
- Structural complexity recurrences via clean even/odd Finset partitions:
  - `complexity_two_mul : complexity (2*n) = complexity n`
  - `complexity_two_mul_add_one : complexity (2*n+1) = 2 * complexity n`
- Main theorem `complexity_eq_two_pow_bitcount : complexity t = 2 ^ bitcount t`, proved by strong (binary) induction.
- Corollaries for the two subsequences:
  - `complexity_two_pow : complexity (2^k) = 2` (uniform in `k`, including `k = 0`)
  - `complexity_two_pow_sub_one : complexity (2^k - 1) = 2^k`

The pre-existing project default build targets are misconfigured at the repository level (unrelated to this task), so the file was verified by compiling it directly with `lake env lean`, which succeeds with no errors, no `sorry`, and only the standard axioms.