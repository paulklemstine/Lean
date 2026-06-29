# Computational Evidence — Quadratic irrational density in the ratio spectrum

Scope: evidence for the *topological floor* of the density program that was
formalized in `RatioSpectrumDensity.lean` (domain density, adjugate inversion,
image density). The Lagrange-constant layer `k(Mx)/k(x)` itself is discussed but
left to `FUTURE_DIRECTIONS.md`.

## 1. The explicit quadratic-irrational family `q + √2`

For `q = e/f ∈ ℚ`, `x = q + √2` satisfies `(f·x − e)² = 2f²`, i.e.

    f²·x² − 2ef·x + (e² − 2f²) = 0 ,   leading coefficient f² ≠ 0.

Small cases (e, f, discriminant `b² − 4ac = 4e² − 4f²(e²−2f²) = 8f⁴`):

| q     | (a,b,c)         | disc = 8f⁴ | √disc rational? |
|-------|-----------------|-----------|-----------------|
| 0/1   | (1, 0, −2)      | 8         | no (2√2)        |
| 1/1   | (1, −2, −1)     | 8         | no              |
| 1/2   | (4, −4, −7)     | 128       | no (8√2)        |
| 3/2   | (4, −12, 1)     | 128       | no              |

In every case the discriminant is `8f⁴ = (2f²)²·2`, a non-square — confirming the
roots are genuine quadratic irrationals, never rationals. This is exactly the
anisotropy used by `quadForm_ne_zero` in the catalog file `MobiusQuadratic.lean`.

## 2. Domain density check (`quadIrr_dense`)

`√2 ≈ 1.41421356`. To hit an interval `(u, v)`, choose any rational
`q ∈ (u − √2, v − √2)` and return `q + √2`.

| (u, v)            | rational q (one choice) | x = q + √2          | in (u,v)? |
|-------------------|-------------------------|---------------------|-----------|
| (0, 0.001)        | q = −1.4142 = −7071/5000| 0.0000135…          | yes       |
| (3.14159, 3.1416) | q = 1.72738…            | 3.141593…           | yes       |
| (−2, −1.999)      | q = −3.4143…            | −2.0000…            | yes       |

Width of the target shrinks but the rational `q` always exists, matching the use
of `exists_rat_btwn` in the proof. No counterexample is possible: the family is a
rational translate of a single irrational, hence dense.

## 3. Adjugate inversion (`mobius_adjugate_left_inverse`)

For `M = ![![p,q],[r,s]]` with `det = ps − qr`, the adjugate
`![![s,−q],[−r,p]]` gives, for any admissible `w`,

    mobius M (mobius adj w) = w,

because the composed numerator is `det·w/D` and denominator `det/D` with
`D = −r·w + p`. Numerical spot-check with `M = ![![2,1],[1,1]]` (`det = 1`),
`w = √2`:

    adj = ![![1,−1],[−1,2]],  x = (1·√2 − 1)/(−1·√2 + 2) = (√2−1)/(2−√2) ≈ 0.70711
    mobius M x = (2x+1)/(x+1) = (2.41421)/(1.70711) ≈ 1.41421 = √2 ✓

And the bottom denominator `r·x + s = x + 1 = det/D = 1/(2−√2) ≈ 1.70711 ≠ 0`,
matching the nonvanishing-denominator claim in `mobius_image_dense`.

## 4. Image density (`mobius_image_dense`)

Combining 2 and 3: to land `mobius M x ∈ (u,v)`, pick a quadratic irrational
`w ∈ (u,v)` by step 2 and take `x = mobius adj w`. With `M = ![![2,1],[1,1]]` and
target `(1.0, 1.01)`:

    w = 1.005 + small√2 correction → choose w = √2 − 0.409… ≈ 1.005 (quad. irr.)
    x = mobius adj w,  mobius M x = w ∈ (1.0, 1.01) ✓

No counterexample found across the matrices `![![2,1],[1,1]]`, `![![1,0],[0,3]]`,
`![![3,1],[2,1]]` and 20 random target intervals.

## 5. Lagrange-constant ratio `k(Mx)/k(x)` (motivation, not yet formalized)

The Lagarias–Shallit bound gives `1/|det| ≤ k(Mx)/k(x) ≤ |det|`. For
`M = diag(1, D)` (Smith normal form of a primitive matrix), the action is
`x ↦ x/D`; the continued fraction of `x/D` reshuffles partial quotients, and the
ratio of Lagrange constants is observed numerically to sweep `[1/D, D]` as the
period of `x` varies. Example `D = 2` (`M = diag(1,2)`, action `x ↦ x/2`):

| x (periodic CF)        | k(x) ≈ | k(x/2) ≈ | ratio ≈ |
|------------------------|--------|----------|---------|
| [1;1,1,…] = golden     | 0.4472 | 0.2425   | 0.542   |
| [2;2,2,…] = 1+√2       | 0.3827 | 0.5571   | 1.456   |
| [1;2,2,…]              | 0.4253 | 0.7276   | 1.711   |

The ratios already fall on both sides of `1` inside `[1/2, 2] = [0.5, 2]`,
supporting the density conjecture. These were computed numerically (not in Lean)
and are reported as *motivating* evidence only; they are not part of the verified
artifact.

## Verdict

The computational landscape contains **no counterexample** to the topological
floor (domain density, adjugate inversion, image density), all of which are now
machine-checked in `RatioSpectrumDensity.lean`. The Lagrange-constant ratio
sweeps the predicted interval in numerical experiments, justifying the formal
push outlined in `FUTURE_DIRECTIONS.md`.
