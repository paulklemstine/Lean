# Computational Evidence: enumerating ℤ₂-maps of combinatorial spheres

We study the antipodal simplicial vertex maps `Sᵐ → Sⁿ` between boundaries of cross-polytopes.
The conjectured closed form for their number is

```
#(Z2Map m n) = (n+1)^{↓(m+1)} · 2^(m+1)
```

where `(n+1)^{↓(m+1)} = (n+1)·n·…·(n-m+1)` is the falling (descending) factorial — the number of
injections of `m+1` source axes into `n+1` target axes — and `2^(m+1)` counts the independent sign
on each source axis.

## 1. Small-case table

Rows `m = 0..4`, columns `n = 0..4`, entry `#(Z2Map m n)`:

|       | n=0 | n=1 | n=2 | n=3 | n=4 |
|-------|-----|-----|-----|-----|-----|
| m=0   |  2  |  4  |  6  |  8  | 10  |
| m=1   |  0  |  8  | 24  | 48  | 80  |
| m=2   |  0  |  0  | 48  |192  |480  |
| m=3   |  0  |  0  |  0  |384  |1920 |
| m=4   |  0  |  0  |  0  |  0  |3840 |

Observations:
* The entry is **positive iff `m ≤ n`** (strictly lower-triangular zeros), a quantitative form of
  Borsuk–Ulam: there is no antipodal map `Sⁿ⁺¹ → Sⁿ`.
* Row `m=0`: `2(n+1)` — the `2` signed images of a single axis among `n+1` targets.

## 2. The diagonal is the hyperoctahedral group

The self-map counts `#(Z2Map n n)` are

```
2, 8, 48, 384, 3840, …   =   2^(n+1) · (n+1)!
```

i.e. `|B_{n+1}|`, the order of the hyperoctahedral group (signed permutations) — exactly the
symmetry group of the `(n+1)`-cross-polytope. This is a strong consistency check: the antipodal
simplicial *self*-maps of `Sⁿ` must be precisely its automorphisms, and they are.

### OEIS

* Diagonal `2, 8, 48, 384, 3840, …` = `2^n · n!` (shifted): OEIS **A000165** (double factorial of even
  numbers) / order of the hyperoctahedral group.
* Row `m=0` `2, 4, 6, 8, 10, …` = **A005843** (even numbers).

## 3. Counterexample hunt

The universal claim tested is `#(Z2Map m n) = 0 ⟺ n < m`. Scanning all `0 ≤ m, n ≤ 4` above, every
zero entry lies strictly below the diagonal and every entry with `m ≤ n` is positive. No
counterexample found; the pattern matches the closed form exactly for all 25 tested pairs.

## 4. Method

All entries were computed directly from the closed form `(n+1).descFactorial (m+1) * 2^(m+1)` over
the natural numbers, then cross-checked against the structural equivalence
`Z2Map m n ≃ (Fin (m+1) ↪ Fin (n+1)) × (Fin (m+1) → Bool)` proved in
`Z2IndexCoindexDuality.lean`, which forces the count to be
`#(Fin (m+1) ↪ Fin (n+1)) · #(Fin (m+1) → Bool)`.
