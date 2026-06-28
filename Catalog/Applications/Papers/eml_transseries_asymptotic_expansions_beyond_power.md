# Computational Evidence — Ordered Transseries Field & Real-Closedness Ingredients

This note records the small-case checks that motivated the theorems in
`OrderedField.lean` and `RealClosureIngredients.lean`. All objects live in the
transseries field `TSeries = HahnSeries (Lex (ℤ →₀ ℝ)) ℝ` of `Field.lean`, with its
lexicographic (Lex) ordered-field structure.

## 1. Divisibility of the value group `Lex (ℤ →₀ ℝ)`

For `g = single 0 a` (a single real exponent at tower height `0`) and `n > 0`, the
witness `g' = single 0 (a/n)` satisfies `n • g' = g`:

| g (exponent of x) | n | g' = g/n | check `n • g'` |
|-------------------|---|----------|----------------|
| 1                 | 2 | 1/2      | 2·(1/2) = 1 ✓  |
| 1                 | 3 | 1/3      | 3·(1/3) = 1 ✓  |
| 5                 | 2 | 5/2      | 2·(5/2) = 5 ✓  |
| -1                | 2 | -1/2     | 2·(-1/2) = -1 ✓|

By contrast, over the **Laurent** value group `ℤ` the equation `2 • k = 1` has no
solution (`k` would be `1/2 ∉ ℤ`). This is exactly `laurent_value_group_not_divisible`
and the reason Laurent series are not real closed while transseries (real exponents) head
toward it.

## 2. Monomial roots (square / n-th root)

`(term h (a/n))^n = term h (n·(a/n)) = term h a` via the law of exponents `term_pow`:

| term      | n | root term  | root^n      |
|-----------|---|------------|-------------|
| x   (h=0,a=1)  | 2 | x^(1/2)    | x ✓     |
| x   (h=0,a=1)  | 3 | x^(1/3)    | x ✓     |
| exp x (h=1,a=1)| 2 | (exp x)^(1/2) | exp x ✓ |
| log x (h=-1,a=1)| 2 | (log x)^(1/2) | log x ✓ |

Every transmonomial is therefore a square (`isSquare_term`) and has all `n`-th roots
(`exists_nthRoot_term`) — the monomial layer of the real-closedness square property.

## 3. Non-Archimedean order (orientation check)

The Lex order decides comparisons at the **smallest** group index; `Field.lean` stores
tower height `h` at index `-h` with "higher tower = greater group element". Composing the
two conventions gives `mono h a > 0 ⟺ a > 0`, i.e. the **germ order at x → 0⁺**:

- `x = term 0 1` is a positive **infinitesimal**: `(n+1)·x < 1` for every `n`
  (`x_infinitesimal`). Sampled: `2x < 1`, `3x < 1`, … all hold (leading coefficient of
  `1 - (n+1)x` is `+1` at the constant index `0`).
- `1/x = term 0 (-1)` is **infinite**: `n < 1/x` for every `n` (`inv_x_infinite`), and
  `x·(1/x) = 1` (`x_mul_inv_x`).

Counterexample hunt: if the orientation were reversed, `x` would be infinite and
`x_infinitesimal` would be **false**. We verified the deciding coefficient sign is `+1`
at index `0`, confirming `x < 1`; the claim is robust. No counterexample exists.

## 4. OEIS

No integer sequence arises (the data here is structural/algebraic, parameterized by real
exponents), so no OEIS lookup applies.
