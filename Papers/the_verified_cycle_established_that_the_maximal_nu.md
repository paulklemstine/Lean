# Computational Evidence — Good manifolds in an `n`-nice polytope

## 1. Small-case calculations

The maximal good-manifold count `a n = 2^n + d(n)` with defect
`d = (0,4,4,4,8,8,16,0,0,…)` (from `n = 0`) gives:

| n      | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|--------|---|---|---|---|---|---|----|-----|-----|-----|
| a(n)   | 1 | 6 | 8 |12 |24 |40 | 80 | 128 | 256 | 512 |
| d(n)   | 0 | 4 | 4 | 4 | 8 | 8 | 16 | 0 | 0 | 0 |
| v₂(a)  | 0 | 1 | 3 | 2 | 3 | 3 | 4 | 7 | 8 | 9 |

Observations, all confirmed by machine-checked proof:
- Defect values lie in `{0,4,8,16}` and form blocks of lengths `3,2,1`.
- For `n ≥ 7`, `a(n) = 2^n` and `v₂(a(n)) = n` exactly.
- The head valuations `0,1,3,2,3,3,4` do **not** equal the index — the
  identity `v₂ = n` is sharp and holds only past the threshold.

## 2. Growth rate

`a(n)^{1/n}` equals `2` exactly for every `n ≥ 7` (since `a(n) = 2^n`), so the
sequence of `n`-th roots is eventually constant `2`; hence the limit is `2`.

## 3. Counterexample hunt (Conjecture 4)

Running totals `S(n) = Σ_{k ≤ n} a(k)`:

| n        | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|----------|---|---|---|---|---|---|----|-----|-----|------|
| S(n)     | 1 | 7 |15 |27 |51 |91 |171 | 299 | 555 |1067 |
| S(n)%128 | 1 | 7 |15 |27 |51 |91 | 43 |  43 |  43 |  43 |

For `n ≥ 6` one has `S(n) = 2^{n+1} + 43`, so `S(n) ≡ 43 (mod 128)` forever.
**No `n` satisfies `128 | S(n)`.** This refutes Conjecture 4: the onset of the
geometric tail at `n = 7` is invisible to the cumulative-divisibility test.

## 4. OEIS note

The count sequence `1, 6, 8, 12, 24, 40, 80, 128, 256, …` matches the
"maximal number of good manifolds in an `n`-nice polytope" data from the
research thread; from `n = 7` it is the pure powers of two.
