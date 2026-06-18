# Future Directions: Arithmetic Foundations of Secure Multi-Party Computation

The file `Catalog/Cryptography/AdditiveSecretSharingMPC.lean` formalizes the
arithmetic core of additive secret sharing over an arbitrary abelian group `G`:
local linear gates (`reconstruct_map`, `reconstruct_add`, `reconstruct_smul`),
perfect privacy as an explicit equivocation bijection (`privacyEquiv`, built from
`share_privacy_existence` + `share_privacy_uniqueness`), re-randomization as a simply
transitive group action (`rerandomize_equiv`), and the boundary fact that
multiplication is *not* share-local (`mul_not_local`). It complements the abstract,
access-structure view in `Catalog/Bridges/ClosureMatroidSecretSharing.lean`: that file
says *which sets* can reconstruct; this one says *what the shares actually are* and how
they compose under computation. The directions below extend this concrete arithmetic
backbone toward a fully certified GMW/BGW pipeline.

## 1. Threshold (Shamir) sharing and the `t < n/2` honest-majority bound

Generalize the `n`-out-of-`n` additive scheme to a genuine `t`-out-of-`n` threshold
scheme by interpolating shares as evaluations of a degree-`t` polynomial over a finite
field `F`, then prove the two matching halves: any `t+1` shares reconstruct (Lagrange
interpolation is exact) and any `t` shares are independent of the secret
(`privacyEquiv` generalizes to a bijection over the missing evaluation points).

*The key insight is* that the additive `privacyEquiv` already isolates the single
algebraic fact privacy needs — that the "missing coordinate" map is a bijection — and
for Shamir that same role is played by the invertibility of the Vandermonde matrix on
any `t+1` distinct points, so the existence/uniqueness proof transfers almost verbatim
with `Matrix.det_vandermonde` replacing `add_right_cancel`.

*Why now?* Mathlib has matured `Polynomial.eval`, Lagrange interpolation
(`Lagrange.interpolate`), and Vandermonde determinants, so the polynomial machinery to
state and prove threshold correctness and privacy is finally available off-the-shelf,
making this the natural next step rather than a from-scratch development.

## 2. A certified Beaver multiplication gate closing the `mul_not_local` gap

`mul_not_local` proves there is no share-local product rule; the constructive resolution
is the Beaver triple: pre-share random `a, b, c` with `c = a·b`, then compute `x·y` from
the publicly opened `d = x−a`, `e = y−b` via `x·y = c + d·b + e·a + d·e`. Formalize one
multiplication gate over a commutative ring and prove its output sharing reconstructs
exactly the product, while the opened `d, e` are independent of `x, y`.

*The key insight is* that Beaver's identity turns a *multiplication of secrets* into a
*linear combination of shares with public coefficients* `d, e`, which is precisely the
free-gate regime already proved here (`reconstruct_add`, `reconstruct_smul`), so the
correctness proof reduces to a `ring` identity plus the existing linear-gate lemmas.

*Why now?* With `reconstruct_map`/`reconstruct_smul` and `rerandomize_equiv` in place,
the only missing ingredient is the algebraic triple identity — the hard privacy/locality
scaffolding already exists, so the multiplication gate is reachable in a single focused
cycle rather than requiring a new framework.

## 3. Functorial composition: gate-by-gate security of a whole arithmetic circuit

Lift the per-gate results to whole circuits by modeling a circuit as a finite DAG of
add/scalar/mul gates and proving, by induction on topological order, that the joint
sharing of all wire values reconstructs the circuit's output and that every adversarial
view remains equivocable. This is a concrete, finitary stand-in for the universal
composition theorem.

*The key insight is* that `privacyEquiv` and `rerandomize_equiv` are *bijections*, and
bijections compose, so security of a circuit is the composite of per-gate bijections —
recasting "universal composition" as the statement that a finite composite of `Equiv`s
is again an `Equiv`, which Lean handles definitionally via `Equiv.trans`.

*Why now?* The gate-level invariants are already `Equiv`-valued (not just propositions),
which is exactly the shape needed to compose them without re-proving privacy at each
step; an inductively-defined `Circuit` type plus `Equiv.trans` is the whole proof
skeleton.

## 4. Quantitative privacy: from equivocation bijection to exact statistical distance

Upgrade the qualitative `privacyEquiv` to a quantitative statement when `G` is finite:
under the uniform dealer distribution, the adversary's view has statistical distance
exactly `0` from a simulator's output, i.e. the induced distribution on any `n−1` shares
is *uniform* on `G^{n-1}` regardless of the secret.

*The key insight is* that a bijection between secrets and consistent sharings pushes the
uniform measure to the uniform measure, so perfect security is literally the
measure-theoretic image of `privacyEquiv` under `PMF.map` / `MeasureTheory.Measure.map`,
turning a counting bijection into a zero-advantage security bound.

*Why now?* Mathlib's `PMF` and finite uniform distributions (`PMF.uniformOfFintype`) are
stable and interoperate with `Equiv`, so the jump from "bijection" to "identical
distributions" is a short `PMF.map_comm`-style argument rather than new probability
infrastructure.

## 5. Bridging to the matroid access structures already in the catalog

Connect this arithmetic file to `Catalog/Bridges/ClosureMatroidSecretSharing.lean` by
proving that the additive scheme *realizes* the access structure whose qualified sets are
exactly the full party set (the `n`-out-of-`n` threshold), and conjecture the converse
direction for matroid ports: every matroid access structure is realized by a linear
secret-sharing scheme over a large enough field.

*The key insight is* that linear secret-sharing schemes and representable matroids are
two views of the same linear-algebraic object — qualified sets are spanning sets of a
matrix's columns — so the catalog's closure/rank `Qualified` predicate should coincide
with "the reconstruction linear map is surjective on that party subset."

*Why now?* The catalog already contains a fully certified matroid/closure access-structure
layer and this file now supplies the concrete linear shares; the missing link is a single
definitional bridge identifying `Qualified` with surjectivity of a restricted
`reconstruct`, making cross-domain unification (combinatorics ↔ linear algebra ↔ crypto)
immediately actionable.
