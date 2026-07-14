# Computational Evidence: sharp dimension-one sumset lower bound

Target claim (formalized as `SumsetSharpDim1.sumset_sharp_dim_one`):
for finite nonempty `A₀,…,A_{n-1} ⊆ {0,1,…,m} ⊆ ℤ`,

    (|A₀|·…·|A_{n-1}|)^{1/p} ≤ |A₀ + … + A_{n-1}|,   p = n·log(m+1)/log(nm+1).

## 1. Exhaustive small-case verification (n = 2)

A brute-force check (Lean `#eval`, `Float` arithmetic) over **all** ordered pairs
of nonempty subsets `A, B ⊆ {0,…,m}` confirmed the inequality
`(|A|·|B|)^{1/p} ≤ |A+B|` for:

| m | ambient size | #nonempty subsets | all pairs satisfy bound |
|---|--------------|-------------------|-------------------------|
| 1 | 2            | 3                 | ✓ true                  |
| 2 | 3            | 7                 | ✓ true                  |
| 3 | 4            | 15                | ✓ true                  |

(`allOK m` returned `true` for m = 1,2,3; i.e. 9, 49, 225 ordered pairs each.)

## 2. Extremal (equality) case

For `A = B = {0,1,2,3}` (m = 3, n = 2): `|A|·|B| = 16`, `A+B = {0,…,6}` so
`|A+B| = 7`. With `p = 2·log 4 / log 7`,

    16^{1/p} = 7.000000   (computed),   |A+B| = 7.

So equality is attained exactly, matching
`SumsetSharpDim1.extremal_interval_sharp_dim_one`. This is why `p` is sharp: it
cannot be lowered.

## 3. Why the exponent is transcendental / sharp

The extremiser `Aⱼ = {0,…,m}` has `|Aⱼ| = m+1` and `∑Aⱼ = {0,…,nm}` of size
`nm+1`. Equality `(m+1)^{n/p} = nm+1` forces
`p = n·log(m+1)/log(nm+1)`, an irrational (transcendental) exponent strictly
inside `(1, n)` for `n ≥ 2`.

## 4. Counterexample hunt (symmetric ball caveat)

The exponent `p` is tied to the **one-sided segment** `{0,…,m}` (size `m+1`), the
face of the box/L₁ extremiser, *not* the symmetric ball `{-m,…,m}` (size `2m+1`).
Testing the *symmetric* ball with the same `p` produces violations, e.g.
`A = B = {-1,0,1}` (m=1): `|A||B| = 9`, `|A+B| = 5`, and
`5^{p} = 5^{1.262…} ≈ 7.6 < 9`. This correctly identifies the segment `{0,…,m}`
(equivalently any translate/interval) as the right domain for this exponent, and
is exactly the hypothesis used in the Lean statement (`A i ⊆ Finset.Icc 0 m`).

No counterexample was found within the stated hypotheses.
