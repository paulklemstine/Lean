# Computational Evidence: Arithmetic on the Möbius Band

We study the value map `φ(x, y) = y·(2x − 1)` on the Möbius band
`M = (ℝ × ℝ) / ~`, where `(0, y) ~ (1, -y)`.

## 1. The value map descends to the quotient

The gluing identifies `(0, y)` with `(1, −y)`. Evaluate `φ` on both:

| point   | φ = y·(2x−1)        |
|---------|---------------------|
| (0, y)  | y·(2·0 − 1) = −y    |
| (1, −y) | (−y)·(2·1 − 1) = −y |

The two agree for every `y`, so `φ` is constant on each glued pair and therefore
descends to a well-defined function `M → ℝ`. (Formalized: `value_respects_moebRel`,
`MoebiusValue`.)

## 2. The ℤ-embedding collapses to the sign

The prompt's embedding is `n ↦ (1/2 + 1/(2n), |n|)`. Its value is

```
φ = |n| · (2·(1/2 + 1/(2n)) − 1) = |n| · (1/n) = |n|/n = sign(n).
```

Small cases (value of `embed n`):

| n     | -3 | -2 | -1 |  1 |  2 |  3 |
|-------|----|----|----|----|----|----|
| value | -1 | -1 | -1 | +1 | +1 | +1 |

So the "Möbius integers" do **not** form a faithful copy of `ℤ`: all positive
integers share the value `+1` and all negative integers share `−1`. The image of the
value map on the embedded integers is just `{−1, +1}`. This refutes the conjecture
that `Z_M` is a one-point compactification of `ℤ` (which would need the embedding to be
injective away from a single point). (Formalized: `value_embed_pos`, `value_embed_neg`,
`value_embed_sign`, `embed_not_injective`.)

## 3. Counterexample hunt for injectivity of `φ` on `M`

`φ` is surjective (the point `(1, r)` has value `r`), but far from injective: e.g.
`(1, 1)` and `(3/4, 2)` are distinct, non-glued points with `φ = 1` in both cases:

```
φ(1, 1)   = 1·(2·1 − 1)     = 1
φ(3/4, 2) = 2·(2·(3/4) − 1) = 2·(1/2) = 1
```

They are not identified by `~` (neither has first coordinate `0`, and the boundary
rule `x=1 ↦ x'=0` fails since `3/4 ≠ 0`), so they are genuinely different points of
`M` with equal value. (Formalized: `MoebiusValue_surjective`,
`MoebiusValue_not_injective`.)

## Summary

The only robust structural fact is the well-definedness of `φ` on the twist quotient.
The proposed ring / integral-domain / prime-factorization story does not survive
contact with the actual value map, which collapses the integers onto their signs.
No OEIS sequence arises (the image is the finite set `{−1, +1}`).
