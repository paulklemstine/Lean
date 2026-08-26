# Computational Evidence — canonical α-connections of finite exponential families

This note records the small-case data that guided the formalization in
`Catalog/Combinatorics/AlphaConnectionCanonical.lean`,
`Catalog/Combinatorics/AlphaConnectionRigidity.lean` and
`Catalog/Combinatorics/AlphaConnectionCombinatorics.lean`.

Everything below was *also* checked symbolically, and the entries marked
**(Lean)** are machine-checked theorems in the files above (no `sorry`,
no `native_decide`).

## 1. The Bernoulli exponential family

Model: `S = {0,1}`, feature `T(x) = x`, natural parameter `θ`,
`p = e^θ / (1 + e^θ)`.

| p    | mean `m = p` | Fisher `g = p(1−p)` | cubic `C = p(1−p)(1−2p)` |
|------|--------------|---------------------|--------------------------|
| 1/4  | 1/4          | 3/16 = 0.1875       | 3/32 = 0.09375           |
| 1/3  | 1/3          | 2/9  ≈ 0.2222       | 2/27 ≈ 0.0741            |
| 1/2  | 1/2          | 1/4  = 0.25         | 0                        |
| 2/3  | 2/3          | 2/9                 | −2/27                    |
| 3/4  | 3/4          | 3/16                | −3/32                    |

The `p = 1/4` row reproduces exactly the catalog's independently proved values
`featureFisher = 3/16` and `scoreCubic = 3/32`
(`InformationGeometryContrarian.bernoulli_quarter_fisher_exact`,
`bernoulli_quarter_cubic_exact`).  This cross-check is what made us confident
that the general skewness law is `C = p(1−p)(1−2p)` and not some other cubic
polynomial; it is now proved in general for *every* `{0,1}`-valued feature of
*every* finite exponential family as **(Lean)** `cum3_binary_feature`.

## 2. Consistency check of the central analytic claim `∂g/∂θ = C`

For the Bernoulli family, `dp/dθ = p(1−p)`, hence

```
dg/dθ = d/dθ [p − p²] = (1 − 2p) · dp/dθ = p(1−p)(1−2p) = C.
```

Numerically, at `p = 1/4` (`θ = log(1/3) ≈ −1.0986`), a central finite
difference with `h = 10⁻⁴` gives

```
[g(θ+h) − g(θ−h)] / (2h) = 0.0937500002…   vs   C = 0.09375
```

agreeing to 9 digits.  This is the small-case shadow of the general theorem
**(Lean)** `hasDerivAt_fisher`: `∂_k g_ij = C_ijk` for arbitrary finite
exponential families.

## 3. Symmetric (Rademacher) two-point family

Model: `S = {0,1}`, `T(0) = −1`, `T(1) = +1`, uniform base weights, `θ = 0`.

| quantity | value |
|----------|-------|
| partition function | 2 |
| mean | 0 |
| Fisher `g` | 1 **(Lean)** `rademacher_fisher_at_zero` |
| cubic `C` | 0 **(Lean)** `rademacher_cubic_at_zero` |

Here the entire α-pencil collapses: every α-connection is flat at `θ = 0`
**(Lean)** `rademacher_all_alpha_flat`.  This contrasts sharply with the
catalog's asymmetric Bernoulli(1/4) example, where flatness occurs *only* at
`α = 1`.  The mechanism is the sign-reversing involution `x ↦ 1 − x`; the
general statement is **(Lean)** `amariCubic_eq_zero_of_involution`.

## 4. Counterexample hunt

* **"Every α = 1 connection is flat"** — false for arbitrary Christoffel
  symbols; the catalog already refutes it
  (`arbitrary_connection_e_flat_conjecture_false`).  Our files therefore prove
  e-flatness only for the *canonical* tensor built from an actual family.
* **"The cubic tensor vanishes only in the symmetric case"** — false: it also
  vanishes at the degenerate points `p = 0, 1` of a binary feature; this is why
  `cum3_binary_eq_zero_iff` carries the nondegeneracy hypotheses `p ≠ 0`,
  `p ≠ 1`.
* **"Duality + e-flatness alone determine the coefficient function"** — false.
  `F(α) = (1−α)/2` and `F(α) = (1−α)/2 + h(α)` with `h` any odd function
  vanishing at `±1` both satisfy `F(1)=0` and `F(α)+F(−α)=1`
  (e.g. `h(α) = α(α²−1)`).  This counterexample forced the third axiom
  (affinity in α) in the rigidity theorem **(Lean)** `alpha_coeff_rigidity`,
  and continuity there is not removable: a Hamel-basis additive map gives a
  non-measurable solution.
* **Mixed cumulants of independent factors** — sampled products of two
  Bernoulli families (`p = 1/4`, `q = 1/3`) give mixed third cumulants equal to
  `0` to machine precision; proved in general as **(Lean)**
  `cum3_mixed_product_eq_zero`.

## 5. OEIS

The integer data appearing here (numerators of `p(1−p)(1−2p)` on `p = 1/n`)
is a rational, not an integer, sequence and no OEIS match is claimed.
