# Computational Evidence — Conjecture C (renormalized products of normalized Laurent series)

Setting: `K` a field, `LaurentSeries K = HahnSeries ℤ K`, uniformizer `q = single 1 1`.
A series is **normalized** when `orderTop f = -1` (simple pole). The renormalized product of
`f 0, …, f (m-1)` is `q^m · ∏_{i<m} f i`.

All numbers below come from finite exhaustive enumeration over truncations
`K[[q]][q⁻¹] / q^D` (exploratory numerics, *not* Lean-verified; the Lean file
`Catalog/Probability/RenormalizedNormalizedFactorization.lean` contains the machine-checked
statements).

## 1. Small-case calculations: order bookkeeping

| m | orders of factors | order of ∏ | order of `q^m ∏` |
|---|-------------------|-----------|------------------|
| 1 | −1                | −1        | 0                |
| 2 | −1, −1            | −2        | 0                |
| 3 | −1, −1, −1        | −3        | 0                |
| m | −1 (m times)      | −m        | 0                |

This is the additivity of `orderTop` on a domain, formalized as `orderTop_prod_normalized`
and `orderTop_renormProd`. With a general exponent `k` the value is `k − m`
(`orderTop_renormProd_gen`), which is the source of the guarded statement
`renormalized_prod_iff_orderTop_sub`.

## 2. Counterexample hunt for uniqueness (the interesting datum)

Exhaustive count, over the truncation `mod q^D`, of pairs of normalized series `(f₀, f₁)`
with `q² f₀ f₁ ≡ 1`:

**K = 𝔽₂**

| D | # normalized truncations | # factorizations of `1` with m = 2 |
|---|--------------------------|------------------------------------|
| 1 | 1  | 1  |
| 2 | 2  | 2  |
| 3 | 4  | 4  |
| 4 | 8  | 8  |
| 5 | 16 | 16 |
| 6 | 32 | 32 |

**K = 𝔽₃**

| D | # normalized truncations | # factorizations of `1` with m = 2 | `(p−1)p^{D−1}` |
|---|---|---|---|
| 1 | 2  | 2  | 2  |
| 2 | 6  | 6  | 6  |
| 3 | 18 | 18 | 18 |

Observed law: the number of factorizations mod `q^D` equals `#(𝒪/q^D)ˣ = (p−1)p^{D−1}`, i.e.
the fibre is in bijection with the unit group — exactly the torsor statement proved as
`factorization_ratio_units` / `twist_family_mem_factorizationSet`. The counts grow without
bound in `D`, which is the finite-level shadow of the theorem
`setOfFactorizations_infinite`. No counterexample to the `m ≥ 2` non-uniqueness claim was found.

For **m = 1** the same enumeration returns count `1` at every truncation `D` and every field
tested: `q f₀ = g` forces `f₀ = q⁻¹ g`. This falsifies the naive reading "the factorization is
never unique" and produced the guarded pair of theorems
`factorization_unique_of_m_eq_one` (m = 1, rigid) and `factorization_not_unique` (m ≥ 2).

## 3. Realizability sweep

Exhaustive enumeration over `𝔽₂` of the image of `(f₀,…,f_{m−1}) ↦ q^m ∏ f i` modulo `q^D`,
for `m = 1,2,3` and `D = 1,…,4`:

| D | image size (m = 1,2,3) | # truncations with `orderTop = 0` | image = order-0 locus? |
|---|---|---|---|
| 1 | 1, 1, 1 | 1 | yes |
| 2 | 2, 2, 2 | 2 | yes |
| 3 | 4, 4, 4 | 4 | yes |
| 4 | 8, 8, 8 | 8 | yes |

The image is exactly the set of truncations with nonzero constant coefficient and no
negative-exponent terms, i.e. `orderTop g = 0`, and nothing else — and it does not depend on
`m`. This is `renormalized_prod_iff_orderTop_zero`.

## 4. OEIS

The 𝔽₂ counts `1, 2, 4, 8, 16, 32` are `A000079` (powers of two); the 𝔽₃ counts
`2, 6, 18` follow `2·3^{D−1}`. Both are just `#(𝒪/q^D)ˣ`; no exotic sequence appears,
which is itself evidence that the fibre carries no structure beyond the unit torsor.

## 5. Probability reading

For a law `p` of an ℕ-valued random variable supported in `{0,…,N−1}`, its generating function
`∑ p(n) q^n` has `orderTop = 0` iff `p(0) ≠ 0`. Laws with `p(0) = 0` (e.g. a geometric law shifted by 1) give `orderTop ≥ 1`, and by the sweep
in §3 no such `g` lies in the image — matching `generatingFunction_not_renormalizable`.

## 6. Finite-level fibre counts over `ZMod (p^D)` (cycle 5, conjecture N2)

Brute-force enumeration of `#{f : Fin m → (ZMod N)ˣ | ∏ f = g}` over the whole unit group
(`g = 1` unless stated), computed by `#eval`:

| `N` | `m = 1` | `m = 2` | `m = 3` | predicted `#U^{m−1}` |
|---|---|---|---|---|
| `3 = 3^1` | 1 | 2 | 4 | `2^{m−1}` |
| `9 = 3^2` | 1 | 6 | 36 | `6^{m−1}` |
| `27 = 3^3` | 1 | 18 | — | `18^{m−1}` |
| `81 = 3^4` | 1 | 54 | — | `54^{m−1}` |
| `4 = 2^2` | 1 | 2 | 4 | `2^{m−1}` |
| `8 = 2^3` | 1 | 4 | 16 | `4^{m−1}` |
| `25 = 5^2` | 1 | 20 | — | `20^{m−1}` |
| `2 = 2^1` | 1 | 1 | 1 | `1^{m−1}` (trivial unit group) |

Every entry matches `((p−1)·p^{D−1})^{m−1}`, which is `card_fibre_zmod_prime_pow`. The count
does not depend on the target: for `N = 9`, `m = 2` the fibre over `g = −1` also has `6`
elements, as the target-uniform statement `card_fibre` requires. The `3`-adic column at `m = 2`
reads `2, 6, 18, 54` — constant ratio `3 = p^{m−1}` — which is the recursion
`card_fibre_zmod_succ` and the denominator `1 − p^{m−1} T` of `euler_factor_identity`.

**Counterexample hunt.** The row `N = 2` is the only case in the table where the fibre is a
singleton for `m ≥ 2`. It falsifies the naive finite-level dichotomy "unique iff `m = 1`" and
forced the nontriviality hypothesis of `zmod_finite_rigidity_dichotomy`; the exception itself is
recorded as the theorem `zmod_two_level_one_rigid`.
