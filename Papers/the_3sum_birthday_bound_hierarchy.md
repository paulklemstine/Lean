# Computational Evidence — 3SUM / birthday-bound factoring hierarchy

All numbers below were produced by evaluation inside Lean (`#eval`) before the
corresponding theorems were formalized.  The items marked **[formalized]** are
now machine-checked theorems in `Catalog/Shared/`.

## 1. The `N = 143 = 11 · 13` census

Triples `1 ≤ a < b < c ≤ n`, counting those whose sum is divisible by `11`
("mod-p") and by `13` as well ("mod-both").

| `n`  | mod-11 only | mod-both |
|-----:|------------:|---------:|
| 10   | 10          | 0        |
| 11   | 15          | 0        |
| 12   | 20          | 0        |

Unordered-with-repetition variants (`1 ≤ a ≤ b ≤ c ≤ n`, sum divisible by 11)
give 20 (`n = 10`), 26 (`n = 11`), 33 (`n = 12`).

*Remark on the reported count 19.*  The source note reports "19 mod-p-only
triples" without specifying the range; no natural range reproduces 19 exactly.
The census actually verified in Lean is the `n = 12` row above (20 and 0).
**[formalized]** `ThreeSumReveal.census_143_modp_only`,
`ThreeSumReveal.census_143_mod_both`.

The empty mod-both column is not an accident of the range: every triple sum here
is `< 143`, and no positive integer below `p·q` is divisible by both `p` and `q`.
**[formalized]** `ThreeSumReveal.census_143_mod_both_reason`.

## 2. Counterexample hunt for the reveal claim

The claim tested was: `p ∣ s`, `0 < s < N = p·q` ⟹ `gcd(s, N) = p`, *without*
assuming `q ∤ s`.  Exhaustive search over `N = 143, 221, 10403` and all
`0 < s < N` divisible by the small factor found no counterexample; the reason is
that `q ∣ s` would force `N ∣ s`.  **[formalized]**
`ThreeSumReveal.Nat.gcd_eq_prime_of_dvd_of_lt` (the hypothesis `q ∤ s` is
redundant).

## 3. The amplitude barrier, measured

For `A = {1, …, M}` and 3-tuples, the smallest `M` for which some pair of triple
sums has a difference `d` with `gcd(d, N) = p`:

| `N`      | `p`  | smallest working `M` | prediction `⌈(p+3)/3⌉` |
|---------:|-----:|---------------------:|-----------------------:|
| `143`    | 11   | 5                    | 5                      |
| `10403`  | 101  | 35                   | 35                     |

The measured thresholds match the predicted amplitude bound exactly: the sums
live in `[3, 3M]`, so a nontrivial congruence mod `p` needs `3M - 3 ≥ p`.
**[formalized]** `CollisionFactoring.all_collisions_trivial_of_small`,
`CollisionFactoring.sumset_card_le_amplitude`,
`CollisionFactoring.rsum_needs_both_barriers` (`p ≤ r · M`).

## 4. The exponent gap, measured at `p = 997`

| scheme | smallest `k` with `k^r > 997` | tuples inspected |
|--------|------------------------------:|-----------------:|
| sumset (`r = 2`) | 32 | 1024 |
| 3SUM (`r = 3`)   | 10 | 1000 |

Storage drops from 32 to 10 (`p^{1/2} → p^{1/3}`), but the number of inspected
tuples stays just above `p` in both cases.  **[formalized]**
`BirthdayHierarchy.square_threshold_997`, `BirthdayHierarchy.cube_threshold_997`,
`BirthdayHierarchy.exponent_gap_997`.

## 5. OEIS

The census counts (10, 15, 20, …) are the standard "number of triples with sum
divisible by 11" counts and depend on the chosen range; no distinctive sequence
was identified, and no OEIS match is claimed.
