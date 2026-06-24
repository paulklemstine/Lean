# Computational Evidence

Concise numerical checks performed (via `#eval`/`decide` in Lean) before
formalising the three tactic-soundness files.

## File I — `tropical_simp` (min-plus distributivity)

Distributivity `c + min a b = min (c+a) (c+b)` and its fold form
`c + foldr min h l = foldr min (c+h) (map (c+·) l)` tested on samples:

| c | l            | c + foldr min 99 l | foldr min (c+99) (map (c+·) l) |
|---|--------------|--------------------|--------------------------------|
| 5 | [3, 1, 4]    | 6                  | 6                              |
| 2 | [7, 7, 2]    | 4                  | 4                              |
| 0 | []           | 99                 | 99                             |

All rows agree, matching the proved `tropical_fold_distrib`.

## File II — `number_theory_decide`

* `6 ∣ n*(n+1)*(n+2)` checked for `n = 0..20`: holds in every case (products
  `0,6,24,60,120,210,…` all divisible by 6).
* `n^2 % 4`: for `n = 0..12` the value is `0` (n even) or `1` (n odd) — never
  `2` or `3`, matching `sq_mod_four`.
* Fibonacci strong divisibility `m ∣ n → fib m ∣ fib n`: spot-checked
  `fib 3 = 2 ∣ fib 6 = 8`, `fib 4 = 3 ∣ fib 8 = 21`, `fib 5 = 5 ∣ fib 10 = 55`.
  (OEIS A000045; the `gcd` identity `fib (gcd m n) = gcd (fib m) (fib n)` is the
  source `Nat.fib_gcd`.)

## File III — `spectral_bound`

Sanity check of the row-sum eigenvalue bound on `A = ![![2, 1], ![1, 2]]`
(eigenvalues `1, 3`): every eigenvalue modulus `≤ max row sum = 3`, with
equality at `μ = 3`, confirming the bound `eigenvalue_norm_le_max_row_sum` is
tight and correct. For `![![0, 2], ![2, 0]]` (eigenvalues `±2`): max row sum
`= 2`, again tight.

## Counterexample hunt

No counterexamples found for any of the universal claims on the sampled ranges.
The bounds in File III are tight (attained), so they cannot be strengthened
without extra hypotheses (e.g. Hermitian structure — see FUTURE_DIRECTIONS #3).
