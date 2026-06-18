# Future Directions — Completed weight-enumerator primitives & functorial tropical profiles

This cycle promoted the classical multiplicativity `W_{C⊕D} = W_C · W_D` — previously only
*implicit* across the catalog's `SmoothPoincare` code files — to a first-class polynomial
identity in `ℕ[X]` (`CompletedWeightEnumerator.weightEnum_append`), and exhibited every prior
direct-sum invariant (`appendCode_card`, `wexact_append`, `wcount_append`, `twe_append`) as a
coefficient / evaluation / support projection of this single master primitive. The following
conjectures are concrete, falsifiable targets for the next cycle.

## Conjecture 1 — The completed enumerator is a genuine monoid homomorphism into `ℕ[X]`
**Statement.** There is a faithful description of the direct-sum operation `⊕c` (modulo the
`Fin (m+n)` reassociation) as a *strictly associative, commutative, unital* monoid on
"codes of all lengths", and `weightEnum` is a monoid homomorphism onto the multiplicative
monoid `(ℕ[X], ·, 1)`: in particular `weightEnum_append_comm` (`weightEnum (C ⊕c D) =
weightEnum (D ⊕c C)`) and a unit law `weightEnum (C ⊕c triv₀) = weightEnum C`, where
`triv₀ = {0} ⊆ Fin 0 → ZMod 2` has `weightEnum triv₀ = 1`.
**Test.** Prove `weightEnum_append_comm` and the unit law; the only obstruction is the
`Fin 0 + n ≅ Fin n` / `Fin m + n ≅ Fin n + m` cast, which should be absorbed by a
weight-preserving reindexing bijection. **Falsifiable** by exhibiting two codes whose
enumerators differ after swapping blocks (impossible if the conjecture holds).

## Conjecture 2 — MacWilliams duality as a polynomial-substitution functor
**Statement.** For a binary linear code `C` of length `n` with dual `C⊥`, the two-variable
completed enumerators satisfy the MacWilliams identity
`W_{C⊥}(x,y) = (1/|C|) · W_C(x+y, x−y)`. The single-variable shadow proved here,
`weightEnum C = ∑ X^{wt c}`, is the `x=1` slice; the conjecture is that the *full*
two-variable primitive in `ℕ[x,y]` (or `MvPolynomial (Fin 2) ℤ`) satisfies MacWilliams,
and that on the self-dual catalog code `hamming` it reduces to the Gleason-invariance
already proved in `GleasonLength`.
**Test.** Formalize `weightEnum2 C : MvPolynomial (Fin 2) ℤ`, prove `weightEnum2_append`
(same `wt_append` argument), then prove MacWilliams for `hamming` (self-dual ⇒ fixed by the
substitution up to the `|C| = 16` factor). **Falsifiable** numerically by evaluating the
substituted polynomial against the dual's spectrum.

## Conjecture 3 — Tropical Newton-polygon = lower convex hull of the support
**Statement.** The tropical enumerator `twe C` (proved here to be the `inf'` over the
polynomial support `support_weightEnum`) equals, as a function of `t ∈ ℝ`, the support
function of the **lower convex hull** of `{(d, 0) : d ∈ support (weightEnum C)}`; equivalently,
the slopes `d` realized as `twe C t = d·t` for some `t` are exactly the *vertices* of the
convex hull of the support, not all support elements. This makes precise the
"information-loss" observation `hamming_twe = min(0, 8t)` (the interior weight `4` is hidden).
**Test.** Prove `twe C t ∈ {d·t : d a hull-vertex of support}` for all `t`, and that interior
support points are never attained for any `t ≠ 0`. **Falsifiable** by a code whose every
support point is a hull vertex yet some is unattained.

## Conjecture 4 — Convolution power law for `k`-fold self direct sums
**Statement.** `weightEnum (C^{⊕k}) = (weightEnum C)^k`, hence
`wexact (C^{⊕k}) = (wexact C)^{∗k}` (the `k`-fold Cauchy convolution power), and the tropical
profile scales linearly `twe (C^{⊕k}) = k · twe C` (generalizing `hamming16_twe = 2·twe`).
Furthermore the *normalized* weight distribution `wexact (C^{⊕k}) / |C|^k` obeys a **local
central limit theorem**: as `k → ∞` it converges (after centering at `k·μ` and scaling by
`√k`) to a Gaussian with variance `k·σ²`, where `μ, σ²` are the mean/variance of the single
-block weight under the uniform distribution on `C`.
**Test.** Prove the algebraic power law `weightEnum_pow` by induction on `k` from
`weightEnum_append`; state the CLT as a limiting statement on coefficients. **Falsifiable**:
the power law is exact and checkable on `hamming^{⊕3}`; the CLT by computing the variance of
the `hamming` spectrum `{0↦1,4↦14,8↦1}` and comparing moments.

## Conjecture 5 — A tropical valuation functor into `CategoricalTropicalUltrametric`
**Statement.** Fixing a slope `t < 0`, the assignment `C ↦ −twe C hC t = max_c (wt c · |t|)`
is a *tropical valuation* in the sense of `Bridges.CategoricalTropicalUltrametric.
TropicalValuationObject`: it is additive under `⊕c` (`twe_append`) and sub-/super-additive in
the way required to reconstruct an ultrametric on the space of codes, with the
direct-sum metric `d(C, D) = |twe C t − twe D t|` ultrametric. The completed primitive
`weightEnum` should factor this construction functorially: `weightEnum → support → twe →
valuation → ultrametric`.
**Test.** Instantiate a `TropicalValuationObject` whose carrier is `{twe-profiles}` and verify
the structure axioms reuse `twe_append`/`twePlus_append`; prove the strong triangle
(ultrametric) inequality for the induced distance on direct-sum-generated codes.
**Falsifiable** by exhibiting three codes violating the strong triangle inequality.
