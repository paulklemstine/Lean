# Future Directions — Tropical–Ultrametric Stability of p-adic Valuation Depth

This cycle established that the p-adic valuation `valDepth p = padicValNat p` is
simultaneously a **tropical homomorphism** (`v(ab) = v a + v b`) and an **ultrametric
depth** (`min (v a) (v b) ≤ v(a+b)`), with an exact *isosceles / sharp-stability* law
(`v a < v b ⇒ v(a+b) = v a`) and consequent **local constancy** (stability radius).
See `Catalog/Bridges/TropicalUltrametricValDepthStability.lean`.

The following conjectures are precise, falsifiable targets for the next cycles.

## C1. Many-term sharp isosceles (unique-minimum law)
If a finite list `l : List ℕ` of nonzero naturals has a **unique** index attaining the
minimum valuation depth `m = min_{x∈l} v x`, then `v (l.sum) = m`. More precisely, if
exactly one term `x₀` satisfies `v x₀ = m` and every other term has `v > m`, then the sum's
depth is exactly `m`. This generalizes `valDepth_add_eq_of_lt` from pairs to finite sums and
is the discrete Newton-polygon "lowest vertex" principle. Falsifiable: a counterexample
would be a list with a unique minimum-depth term whose sum has strictly larger depth.

## C2. Valuation depth as a continuous functor into `UltraNormObj`
Define the p-adic metric `d p a b = (p : ℝ)^(-(valDepth p (a - b)))` on `ℤ`. Conjecture:
`valDepth p` is **locally constant** in this metric (any `b` with `d p a b < p^(-(v a))`
has `v b = v a`), and the assignment `a ↦ v a` factors through the catalog's
`CategoricalTropicalUltrametric.valuationReconstruct` as a genuine morphism of
`UltraNormObj`. This would upgrade the present arithmetic stability into the categorical
"quantitative functor" claimed by the bridge file. Falsifiable via an explicit modulus.

## C3. Kummer carry-count bridge (carry-free ⇔ depth)
`Computation/PadicValuationDepth` argues that the ultrametric inequality "eliminates carry
propagation". Conjecture the exact arithmetic shadow: `valDepth p (Nat.choose (m+n) m)`
equals the number of carries when adding `m` and `n` in base `p` (Kummer's theorem), and
hence the binomial depth is bounded by `Nat.log p (m+n)`. This ties the informal
"carry-free" complexity story to a provable depth formula. Falsifiable: any `(p,m,n)` where
the carry count and `padicValNat p (choose (m+n) m)` disagree.

## C4. Tropical Newton-polygon lower bound for polynomial values
For `f : Polynomial ℤ` and `x = p^e`, conjecture `valDepth p (f.eval x).natAbs ≥ T_f(e)`,
where `T_f(e) = min_i (v(a_i) + i·e)` is the **tropical evaluation** of the coefficient
valuations (the Newton-polygon lower hull), with equality when the minimizing `i` is unique.
This makes `valDepth ∘ eval` a tropical-polynomial morphism and connects directly to
`Catalog/Tropical/PolynomialBridge`. Falsifiable: a polynomial/exponent pair violating the
lower bound.

## C5. Ultrametric stability of iteration depth (dynamical)
For a polynomial map `g : ℤ → ℤ` with `g(0) ≡ 0 (mod p)`, conjecture the orbit depths
`n ↦ valDepth p (g^[n] x)` are **eventually monotone** and in fact eventually grow at least
linearly when `g` is locally contractive at a p-adic fixed point (Hensel basin), realizing
the `UltrametricCompositionLaw.vdepth_iterate_succ` bound as an exact growth law rather than
just an upper bound. Falsifiable: a contractive `g` whose orbit depth fails to grow.
