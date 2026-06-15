# Future Directions — Tropical Gravitational Lensing for Integer Factorization

Research cycle output: `Catalog/Pythagorean/TropicalLensingFactorization.lean`
(11 theorems, fully verified, 0 sorries; standard axioms only).

This cycle made precise the metaphor *prime = lensing mass*, *p-adic valuation =
deflection*, *factorization = tropical (additive) partition of deflection*, and
connected it to the Berggren–Lorentz / Pythagorean difference-of-squares geometry.
The following conjectures are bold but **testable in Lean** and build directly on the
established dictionary.

## C1. Berggren orbit realizes every depth split (tropical surjectivity)

For a fixed prime `p` and any target even depth `2k`, the Berggren tree (generators
`A, B, C` of `Algebra/BerggrenLorentz/Core.lean`) acting on the seed `(3,4,5)`
produces a triple `(x,y,z)` whose lensed leg-square `(z-y)(z+y) = x²` realizes the
partition `v_p(z-y) + v_p(z+y) = 2k` with **both summands attained nontrivially**
for infinitely many `(i, 2k-i)` with `0 < i < 2k`.
> *Test:* state `∀ k, ∃ word, 0 < padicValNat p (z-y) ∧ ...` along a Berggren word and
> prove the `p = 2` case computationally on the first few tree levels, then generalize.

## C2. Caustic sharpness ⇔ balanced factor (the "even-depth obstruction")

The caustic inequality `min(v_p a, v_p b) ≤ v_p(a+b)` is an **equality** exactly when
`v_p a ≠ v_p b`. Conjecture: for an odd composite `n = a²-b²` produced by Fermat, the
two images `a-b, a+b` give a *balanced* (near-equal) factorization **iff** the caustic
is strict (`min < v_p(a+b)`) at every odd prime `p ∣ n`. This would turn caustic
strictness into a certificate of factorization quality.
> *Test:* prove the `iff` between `v_p a = v_p b` and caustic non-strictness, then bound
> `|（a+b) − (a−b)|` by a function of the strict primes.

## C3. Tropical lens metric separates primitive Pythagorean classes

Define the lens (ultrametric) distance `d_p(m,n) = padicNorm p (m-n)`. Conjecture:
two primitive Pythagorean triples lie in the same Berggren subtree **iff** their
hypotenuses are `p`-adically close (`d_p(z₁, z₂)` small) for the single prime `p = 2`,
i.e. the 2-adic lens metric is a complete invariant of the tree address up to depth.
> *Test:* compute `padicValNat 2 (z - 1)` (hypotenuses are odd, `≡ 1 mod 4`) along the
> three branches and prove a monotone depth bound.

## C4. Additive (tropical) factorization functor lifts to the Lorentz monoid

The map `n ↦ (v_p n)_p` is a monoid morphism `(ℕ_{>0}, ×) → (⊕_p ℕ, +)` — the
"global tropicalization." Conjecture: it intertwines the multiplicative action of the
Berggren–Lorentz monoid `O(2,1;ℤ)` on leg-squares with a piecewise-**linear** (hence
genuinely tropical) action on the depth vectors, giving a functor
`BerggrenAction → TropicalLinearAction`. This is the categorical bridge promised by
`Bridges/CategoricalTropicalUltrametric.lean`.
> *Test:* prove `v_p` is a monoid hom (`padicValNat.mul` packaged), then show each
> generator induces an affine map on `(v_p(z-y), v_p(z+y))`.

## C5. Lensing speedup bound for difference-of-squares search

Quantify the metaphor's payoff: if `n` has a prime factor `p` with `v_p n = k`, then
restricting Fermat's `a²-b²` search to residues compatible with the caustic law cuts
the search interval by a factor `≥ p^{⌊k/2⌋}`. Conjecture: a `padicValNat`-indexed
sieve over the Fermat interval `[√n, (n+9)/6]` has certified density `O(n^{1/2}/p^{k/2})`.
> *Test:* formalize the residue restriction as a `Finset` filter and prove a cardinality
> upper bound via `padicValNat_dvd_iff_le`.
