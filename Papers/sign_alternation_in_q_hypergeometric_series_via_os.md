# Computational Evidence: Sign Alternation via Oscillatory Asymptotics near ω = -1

## 1. The dominance mechanism (ω = -1)

Model coefficient: `a n = (-1)^n · A n + e n` with amplitude `A n > 0` beating the
error `|e n| < A n`. Then:

| n (parity) | (-1)^n · A n | a n sign |
|-----------|--------------|----------|
| even      | + A n        | +        |
| odd       | - A n        | -        |

So `sign(a n) = sign((-1)^n)`, hence `a n · a (n+1) < 0` (strict alternation).
Consequently, once dominance holds for all `n ≥ N₀`, alternation can only fail
inside the finite window `{0, …, N₀-1}` ⇒ the exceptional set is **finite** ⇒
density zero. This matches the *eventually strictly alternating* behaviour of the
Folsom–Males–Rolen–Storzer function `v₁(q)`.

## 2. Sharpness: infinite but density-zero exceptions

Let the amplitude degenerate on the perfect squares:
`sqAmp n = 0` if `n` is a square, else `1`; `sqCoeff n = (-1)^n · sqAmp n`.

Computed exceptional set `{n < 30 : ¬ (sqCoeff n · sqCoeff (n+1) < 0)}`:

```
[0, 1, 3, 4, 8, 9, 15, 16, 24, 25]
  = squares {0,1,4,9,16,25} ∪ predecessors {0,3,8,15,24}
  = {n | n or n+1 is a perfect square}.
```

This set is **infinite** (it contains every perfect square) yet has density zero.

## 3. Density-zero counting bound for squares

Number of perfect squares in `[0, N)` is bounded by `√N + 1`:

```
#{n < 100 : n a perfect square} = 10   ≤   Nat.sqrt 100 + 1 = 11.
```

Since `(√N + 1)/N → 0`, the perfect squares (and hence the exceptional set above,
whose count is ≤ `2(√N + 1)`) have natural density zero.

## 4. OEIS

- Perfect squares: A000290, `0, 1, 4, 9, 16, 25, …`.
- Indices where alternation fails above: A005563/neighbours; the union
  `{n | n or n+1 square}` is `0,1,3,4,8,9,15,16,24,25,…` (squares and their
  predecessors).

## 5. Counterexample hunt

No counterexample to the main claim was found: whenever `|e n| < A n` and
`A n > 0` on a tail, alternation held on that tail in every tested instance
(random amplitudes/errors, `n ≤ 10^3`). The exceptional set was always contained
in the pre-dominance window.
