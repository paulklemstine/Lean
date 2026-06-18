# Future Directions — Mobius Arithmetic

## Synthesis

This cycle set out to build the "Mobius integers" `Ztilde = ℤ × {+1,-1}` modulo the
twist `(n,+1) ~ (-n,-1)` and to test the bold conjectures attached to it: a class
number 1, a *double cover* of the primes into oriented pairs `p₊`/`p₋`, distinct
factorizations of `6`, and a zeta function with zeros off the critical line because
the ring is "non-Ore". The decisive structural finding is a **collapse phenomenon**:
the orientation-respecting signed-value map `mval(n,s) = s·n` is a complete invariant
of each Mobius class, so the quotient is in bijection with `ℤ`, and the transported
ring structure upgrades this to a genuine **ring isomorphism `ztildeRingEquivInt :
Ztilde ≃+* ℤ`**. Everything else follows from this one fact.

Under the collapse, each conjecture resolves cleanly — and mostly negatively. The
double cover *collapses*: the two oriented lifts satisfy `p₋ = -p₊`
(`ominus_eq_neg_oplus`), and since `-1` is a unit they are **associates**
(`oriented_primes_associated`); the spectrum is the ordinary prime spectrum, a degree-1
cover, not a degree-2 one. The "two distinct factorizations of 6" are the single
factorization `2·3` taken up to the unit `±1`, i.e. exactly `ℤ`'s unique factorization,
so unique factorization *up to orientation* is just unique factorization up to units.
The orientation flip is literally negation (`flip_eq_neg`), confirming that all of the
Mobius nonorientability is carried by the unit `-1`. The proposed twisted addition is
not even an operation: it fails to descend to the quotient (`twisted_add_not_welldefined`),
because its agree-branch hard-codes orientation `+1` and so depends on representatives,
not just signed values.

The reusable structural insight is methodological: a topologically-motivated
identification yields a *new* number system only when the gluing map admits no
single complete numeric invariant. Here `mval` is such an invariant, which is why the
construction degenerates. This is a sharp, transferable diagnostic for the sibling
Geometry experiments (`PadicMobius`, `InverseStereoMobiusNext`, `HyperbolicNumberTheory`):
to obtain genuine novelty one must break the existence of a complete `ℤ`-valued (or
field-valued) invariant — for instance by making the orientation *interact
multiplicatively in a non-central way*, forcing noncommutativity that no commutative
value map can capture.

## Results Summary

- `ztildeRingEquivInt`: proved — the Mobius integers are ring-isomorphic to `ℤ`; the entire construction collapses to ordinary arithmetic.
- `ztilde_isDomain`: proved — `Ztilde` is an integral domain (a corollary of the collapse), so "class number 1 / UFD" is just `ℤ`'s.
- `mobius_identification`: proved — the defining Mobius twist `(n,+1) ~ (-n,-1)` holds in the quotient.
- `twisted_add_not_welldefined`: disproved (counterexample) — the sketch's case-split addition does not descend to the quotient.
- `oriented_primes_associated`: disproved-as-conjectured — `p₊` and `p₋` are associates, so the prime double cover collapses to degree 1.
- `ominus_eq_neg_oplus`: proved — the two oriented lifts of `p` are negatives of each other.
- `flip_eq_neg`: proved — orientation reversal equals ring negation.

## Research Directions

### Direction 1: Noncommutative Mobius integers via a twisted product
**Hypothesis**: Equipping `ℤ × {±1}` with the *twisted* multiplication
`(a,s)·(b,t) = (a·b, s·t)` together with a value map that records orientation as a
genuine grading (a `ℤ/2`-graded ring, or a crossed product `ℤ ⋊ ℤ/2`) produces a ring
that is **not** isomorphic to `ℤ` and whose unit group is strictly larger than `{±1}`.
**Test**: Build the `ℤ/2`-crossed-product `ℤ[ℤ/2]` (group ring) in Lean and prove it is
*not* an integral domain (exhibit zero divisors `(1+g)(1-g)=0`), contrasting with
`ztilde_isDomain`.
**Why now**: This cycle proved the *commutative* collapse via the complete invariant
`mval`; the obstruction is precisely the existence of that invariant, so deliberately
destroying it (grading instead of quotient) is the minimal next step.
**If true**: A genuinely new orientation-aware ring whose number theory differs from `ℤ`,
salvaging the original concept's intent.
**If false**: It further confirms that "orientation = unit ±1" is unavoidable for any
`ℤ`-valued construction, sharpening the no-go.

### Direction 2: A general collapse criterion for "twisted" quotient number systems
**Hypothesis**: For any `f : A → B` with `B` a commutative ring and `f` surjective, the
quotient `A / Setoid.ker f` carries a *unique* ring structure making `f` descend, and it
is `≃+* B`; hence no quotient-by-a-complete-invariant construction is new.
**Test**: State and prove the general lemma `Quotient (Setoid.ker f) ≃+* B` from
`Function.Surjective f` plus compatibility of `f` with given operations, then instantiate
it to re-derive `ztildeRingEquivInt` as a one-liner.
**Why now**: `ztildeRingEquivInt` is a special case; abstracting it gives the next team a
*reusable theorem* that instantly screens out degenerate "exotic ring" proposals.
**If true**: A catalog-level diagnostic lemma that saves future cycles from rebuilding
collapses by hand.
**If false**: There is a subtle obstruction to uniqueness of the descended structure
worth isolating (e.g. when `f` is not injective on units).

### Direction 3: The Mobius zeta function is the ordinary zeta function
**Hypothesis**: The proposed `zeta_tilde(s) = Σ (1/n^s_+ + 1/n^s_-)` equals
`(1 + 2^{-s}·…)`-style rearrangement of `2·ζ(s)` (each value counted with both
orientations), so it inherits the standard functional equation and its zeros lie on the
critical line — contradicting the concept's "zeros off the critical line" claim.
**Test**: Formalize the oriented Dirichlet sum over `Ztilde` using `ztildeRingEquivInt`
to reindex by `ℤ`, and prove `zeta_tilde(s) = 2·ζ(s)` (or the appropriate constant
multiple) on `Re(s) > 1`; conclude the RH-status is identical to `ℤ`'s.
**Why now**: With `Ztilde ≃+* ℤ` established, the "Mobius zeta" is a relabelled
classical zeta, making the equality provable rather than speculative.
**If true**: The "non-Ore / zeros off the line" claim is refuted; orientation cannot move
zeros.
**If false**: The orientation weighting is genuinely asymmetric (e.g. `p₊` and `p₋`
weighted differently), which would itself be a surprising and publishable asymmetry.

### Direction 4: Klein-bottle integers (double twist) and whether they too collapse
**Hypothesis**: The two-sided identification `(m,n,+1) ~ (-m,-n,-1)` on `ℤ² × {±1}`
(a "Klein-bottle" analogue) again collapses, this time to `ℤ²`, via the complete
invariant `(m,n,s) ↦ (s·m, s·n)`.
**Test**: Reuse the `Setoid.ker` pattern with `mval₂(m,n,s) = (s·m, s·n)` and prove
`KleinZtilde ≃+* ℤ²` (as additive groups / commutative rings with coordinatewise product).
**Why now**: The exact mechanism from this cycle (`Setoid.ker` + surjectivity) transfers
verbatim to higher rank, letting us test whether *dimension* changes the collapse.
**If true**: Collapse is dimension-independent for sign-twist identifications, a clean
general statement.
**If false**: Some higher-rank twist resists a complete invariant — exactly the regime
where new number systems could live.

### Direction 5: Where exactly does the twisted addition fail — measure the obstruction
**Hypothesis**: The set of "bad" representative-pairs for `tadd` (where the agree-branch
flips sign) is precisely the pairs of *opposite* orientation, and `tadd` *does* descend
when restricted to the sub-setoid of fixed orientation; i.e. the obstruction is a single
`ℤ/2`-cocycle.
**Test**: Prove that `tadd` is well defined on `{(n,+1)}` (the orientation-`+1` section)
and exhibit the cocycle measuring the failure on the full quotient; classify it in
`H²(ℤ/2; ℤ)`.
**Why now**: `twisted_add_not_welldefined` gives one explicit failure; localizing it to a
cohomology class turns a counterexample into structure.
**If true**: The "twist" is a genuine but cohomologically trivial obstruction, explaining
*why* the only coherent arithmetic is `ℤ`'s.
**If false**: The failure is non-cohomological (depends on values, not just orientations),
indicating the proposed operation is simply incoherent rather than twisted.
