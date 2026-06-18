# Future Directions: Tropical Automorphic Norms from Berggren–Lorentz Orbits

These conjectures extend the results in `Bridges/TropicalAutomorphicNorms.lean`, which
establishes the tropical (ℓ∞ / max-plus) norm as an *automorphic size* on the
Berggren–Lorentz orbit of Pythagorean triples: the Lorentz form `Q = a²+b²−c²` is frozen
at `0` along the orbit while the tropical norm is squeezed geometrically,
`5·5ⁿ ≤ ‖orbitⁿ‖ ≤ 5·7ⁿ`, with each generator tropically `7`-Lipschitz.

Each direction below is stated as a precise, falsifiable Lean-provable conjecture.

## D1. Uniform tropical operator norm of arbitrary Berggren words
**Conjecture.** For every Berggren word `w` of length `ℓ`, the tropical (ℓ∞) operator
norm of the associated matrix product satisfies `‖M_w‖_∞ ≤ 7^ℓ`, and equality of the
exponential *rate* `limsup (1/ℓ) log ‖M_w‖_∞ = log 7` is attained exactly along the
all-`B` word. Concretely: `tnorm (wordChild w v) ≤ 7^(w.length) * tnorm v` for all `v`,
generalising `tnorm_child{A,B,C}_le` from single steps to words.
*Why testable:* pure induction on word length over the three proven single-step bounds.

## D2. Sharp two-sided band per generator
**Conjecture.** On the positive light cone, each generator has a *sharp* tropical
expansion band: `A` and `C` satisfy `1·c ≤ ‖child‖ < 7c` (they may fix the hypotenuse
direction, no uniform lower expansion), while `B` satisfies the strict band
`5c < ‖child‖ ≤ 7c`, and the constant `5` is optimal (approached as `a/c → 0` or
`b/c → 0`). Formally, `∀ ε>0, ∃` positive Pythagorean `(a,b,c)` with
`‖childB‖ < (5+ε)·c`.
*Why testable:* the lower constant `5` comes from the triangle inequality `c < a+b`;
near-degenerate triples (e.g. `(3,4,5)`-like with one small leg) approach it.

## D3. Tropical valuation = tree depth (max-plus linearity)
**Conjecture.** Define the tropical valuation `v(t) = ⌊log₅ ‖t‖⌋`. Then for the all-`B`
orbit, `v(orbitⁿ) = n + 1` exactly for all `n` (the valuation equals the tree depth plus
the seed offset), i.e. the discrete log base 5 is an exact linear coordinate on the
B-branch. More strongly, `5^(n+1) ≤ ‖orbitⁿ‖ < 5·7ⁿ < 5^(2n+2)`, pinning the valuation
between `n+1` and `2n+2`.
*Why testable:* the squeeze `orbitB_tnorm_squeeze` already brackets `‖orbitⁿ‖`; the claim
is an integer floor/log computation on top of it.

## D4. Automorphic isotropy is unique to the cone
**Conjecture.** The tropical norm is *unbounded on the orbit* (proved) and this is
special to isotropic (`Q = 0`) seeds: for any seed with `Q ≠ 0`, no Berggren orbit can
keep `Q` invariant at a nonzero value while having tropical norm bounded — and the
analogue of the geometric squeeze holds with the same rates `[5,7]` whenever the seed has
positive entries with `a + b > c`. Formally, the squeeze `5·5ⁿ·k ≤ ‖orbitⁿ(seed)‖`
holds for any positive seed satisfying the strict triangle inequality, with
`k = tnorm seed / 5`.
*Why testable:* re-run the induction of `orbitB_tnorm_lower`/`_upper` with a general
positive triangle-inequality seed instead of `(3,4,5)`.

## D5. Tropical sub-multiplicativity as an ultrametric bridge
**Conjecture.** The map `t ↦ log₇ ‖t‖` is an *ultrametric-compatible valuation* in the
sense of `Bridges/CategoricalTropicalUltrametric.lean`: it sends the Berggren monoid
action to additive shifts bounded by `1` per generator, so the induced distance
`d(s,t) = ‖s − t‖` is quasi-non-Archimedean along orbits, `d(orbitⁿ, orbitᵐ) ≤
7^max(n,m) · d(seed-scale)`. This would functorially transfer the certified Lipschitz
bound (`7^depth`) into an ultrametric robustness certificate.
*Why testable:* combine `tnorm_child*_le` (sub-multiplicativity) with the tropical
valuation object interface already present in the catalog.
