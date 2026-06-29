# Unconditional Cycle Obstructions for the Collatz Shortcut Map

This note summarizes the formal Lean 4 (Mathlib) development in

- `Catalog/Applications/Collatz/Basic.lean`
- `Catalog/Applications/Collatz/CycleObstruction.lean`

All statements below are fully machine-checked and depend only on the standard
axioms `propext`, `Classical.choice`, and `Quot.sound`.

## The map

On the natural numbers we use the Collatz step map

```
T(n) = n / 2      if n is even,
T(n) = 3 n + 1    if n is odd,
```

formalized as `Collatz.T n = if n % 2 = 0 then n / 2 else 3 * n + 1`.
Iteration is written `T^[k]` (Mathlib's `Function.iterate`). Two convenience
evaluation lemmas are provided: `T_even : Even n → T n = n / 2` and
`T_odd : Odd n → T n = 3 * n + 1`.

## Results

1. **`T_lt_of_even`** — `0 < n → Even n → T n < n`.
   An even step strictly decreases a positive input, since `n / 2 < n` for
   `n > 0` (`Nat.div_lt_self`).

2. **`T_gt_of_odd`** — `Odd n → T n > n`.
   An odd step strictly increases its input, since `3 n + 1 > n`.

3. **`T_no_fixed_point`** — `0 < n → T n ≠ n`.
   Immediate from (1) and (2): on an even input `T` strictly decreases, on an
   odd input it strictly increases, so it can never fix a positive value. The
   only fixed point of `T` on `ℕ` is `0`.

4. **`all_even_descent`** — if `T^[i] n` is even for every `i < k`, then
   `T^[k] n = n / 2 ^ k`.
   Proved by induction on `k`. The step uses `Function.iterate_succ'`, the
   inductive value `T^[k] n = n / 2 ^ k`, the even-step rule `T_even`, and the
   division identity `(n / 2^k) / 2 = n / 2^(k+1)`
   (`Nat.div_div_eq_div_mul` together with `pow_succ`).

5. **`periodic_has_odd`** — if `0 < n`, `0 < p`, and `T^[p] n = n`, then there is
   some `i < p` with `T^[i] n` odd.
   By contradiction: if every iterate `T^[i] n` (`i < p`) were even, then
   `all_even_descent` would give `n = T^[p] n = n / 2 ^ p`. But `n / 2 ^ p < n`
   for `n > 0` and `p > 0` (since `2 ^ p > 1`), a contradiction.

## Significance

Result (5) is the key obstruction: **every positive periodic orbit of `T`
must contain an odd integer.** Equivalently, `T` has no cycle made up of even
steps only. Combined with the monotonicity facts (1)–(3), this rules out the
simplest shapes of nontrivial cycles for the Collatz dynamics, and gives a
verified foundation for further computer-assisted study of the conjecture.

## Open directions

- Strengthen (5) toward `¬ ∃ n > 1, ∃ k > 0, T^[k] n = n` (no nontrivial cycle
  at all), which requires controlling the interleaving of odd and even steps.
- Use the verified descent lemma to study stopping-time statistics and the
  density of convergent integers.
