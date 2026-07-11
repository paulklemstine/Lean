# Computational Evidence — The Mega-Sphere (Deepening)

This cycle deepens the "Mega-Sphere: all dimensions at once" theme along its
three pillars: inverse limits of towers, the mod-2 cohomology ring of `ℝP^∞`
(Stiefel–Whitney classes), and the Bernoulli numbers.  Below is the concise
numerical evidence that guided the formal statements.

## 1. Inverse-limit collapse (multiplication towers)

Tower `ℤ ←×d— ℤ ←×d— ⋯`.  A coherent sequence `x` satisfies `d·x(n+1) = x(n)`,
so `x(0) = dᵏ·x(k)` is divisible by every power of `d`.

| d | d² | d³ | d⁴ | forces x(0) divisible by | limit |
|---|----|----|----|--------------------------|-------|
| 2 | 4  | 8  | 16 | all 2ᵏ                   | {0}   |
| 3 | 9  | 27 | 81 | all 3ᵏ                   | {0}   |
| -2| 4  | -8 | 16 | all 2ᵏ (via \|d\|)        | {0}   |

For `|d| ≥ 2` the only integer divisible by all `dᵏ` is `0`, so the inverse limit
is trivial.  (For `|d| ≤ 1` this fails: `d = 1` gives the diagonal `ℤ`, `d = 0`
gives `ℤ` at stage 0.)  Formalized as `mulTower_invLimit_eq_bot`.

## 2. Contrarian test: do nontrivial stages force a nontrivial limit?

Conjecture "every stage nontrivial ⇒ limit nontrivial" — hunt for a
counterexample.  Take every stage `= ℤ/2` (nontrivial) with **all connecting
maps zero**.  Coherence `0 = x(n)` forces `x ≡ 0`: limit `= {0}`.

    stages:   ℤ/2   ℤ/2   ℤ/2   ℤ/2 ...   (each has 2 elements)
    maps:      0     0     0     0
    limit:    {0}                          (1 element)

Counterexample found → conjecture is **false**.  Formalized as
`exists_nontrivial_stages_trivial_invLimit`.  By contrast, *surjective*
connecting maps never collapse (`proj_zero_surjective_of_surjective`), and the
`p`-adic reduction tower has a genuinely nontrivial limit (prior cycle).

## 3. Bernoulli numbers and Faulhaber

First Bernoulli numbers `Bₙ`:

| n  | 0 | 1    | 2   | 3 | 4     | 5 | 6    |
|----|---|------|-----|---|-------|---|------|
| Bₙ | 1 | -1/2 | 1/6 | 0 | -1/30 | 0 | 1/42 |

Contrarian test of "all odd Bₙ vanish": **false at n = 1** (B₁ = -1/2 ≠ 0);
true only for odd `n ≥ 3`.  Formalized as `not_all_odd_bernoulli_vanish`.

Faulhaber `p = 4`, checking `∑_{k<n} k⁴ = (n-1)n(2n-1)(3n²-3n-1)/30`:

| n | ∑_{k<n} k⁴ | RHS |
|---|-----------|-----|
| 1 | 0         | 0   |
| 2 | 1         | 1   |
| 3 | 17        | 17  |
| 4 | 98        | 98  |
| 5 | 354       | 354 |

All agree.  Formalized as `faulhaber_four`; the general "one polynomial per
exponent" fact is `faulhaber_isPolynomial`.  The single object encoding **all**
Bernoulli numbers at once is the generating function
`(∑ Bₙ xⁿ/n!)·(eˣ−1) = x` (`mega_generating_function`).

OEIS: Bernoulli numerators/denominators A027641/A027642; `∑ k⁴` is A000538.

## 4. Cohomology of `ℝP^∞` vs `ℝP^n`

Model `H*(ℝP^∞;𝔽₂) ≅ 𝔽₂[w]`, `deg w = 1`.  Poincaré count: exactly one class in
each degree, so `dim_{𝔽₂} H^{<n} = n` (`sw_poincare`).  In the infinite ring `w`
is **not** nilpotent (`sw_not_nilpotent`); in the truncation `𝔽₂[w]/(w^{n+1})`
modelling `ℝP^n`, `w` **is** nilpotent (`sw_nilpotent_in_truncation`).  In char 2
the total class satisfies `(1+w)^{2^k} = 1 + w^{2^k}` (`sw_frobenius_series`), and
in `𝔽₂⟦w⟧` its inverse (the dual Stiefel–Whitney series) has all coefficients 1
(`dual_sw_all_one`).
