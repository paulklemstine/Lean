# Future Directions: Arithmetic Foundations of Secure Multi-Party Computation

The file `Catalog/Cryptography/AdditiveSecretSharingMPC.lean` formalizes the arithmetic
core of additive secret sharing over an arbitrary abelian group `G`: the local linear
gates (`reconstruct_add`, `reconstruct_zsmul`, `reconstruct_map`), perfect privacy as an
explicit equivocation bijection (`privacyEquiv`, supported by `share_privacy_existence`
and `share_privacy_uniqueness`), re-randomization as a simply transitive group action
(`rerandomizeEquiv`), the boundary fact that multiplication is *not* share-local
(`mul_not_local`), and the constructive resolution of that boundary via the Beaver
multiplication gate (`beaver_gate_correct`, `reconstruct_beaverOutput`). The following
directions extend this concrete arithmetic backbone toward a fully certified GMW/BGW
pipeline and connect it to the matroid access-structure layer already in the catalog
(`Catalog/Bridges/ClosureMatroidSecretSharing.lean`).

## 1. Threshold (Shamir) sharing and the honest-majority bound

Generalize the `n`-out-of-`n` additive scheme proved here to a genuine `t`-out-of-`n`
threshold scheme by interpolating shares as evaluations of a degree-`t` polynomial over a
finite field `F`. Prove the two matching halves: any `t+1` shares reconstruct (Lagrange
interpolation is exact) and any `t` shares are independent of the secret, generalizing the
present `privacyEquiv` to a bijection over the missing evaluation points.

*The key insight is* that the additive `privacyEquiv` already isolates the single
algebraic fact privacy needs — that the "complete the missing coordinate" map is a
bijection (here `Equiv.subRight`, built on `add_right_cancel` in `share_privacy_uniqueness`)
— and for Shamir that same role is played by the invertibility of the Vandermonde matrix
on any `t+1` distinct points, so the existence/uniqueness proof transfers almost verbatim
with `Matrix.det_vandermonde` replacing `add_right_cancel`.

*Why now?* Mathlib has matured `Polynomial.eval`, `Lagrange.interpolate`, and Vandermonde
determinants, so the polynomial machinery to state and prove threshold correctness and
privacy is finally available off the shelf, making this the natural next step rather than
a from-scratch development.

## 2. Quantitative privacy: from equivocation bijection to zero statistical distance

Upgrade the qualitative `privacyEquiv : G ≃ G` to a quantitative statement when `G` is
finite: under the uniform dealer distribution, the adversary's view on any `n−1` shares is
*uniform* on `G^{n-1}` regardless of the secret, so the statistical distance from a
secret-free simulator is exactly `0` (perfect security, not merely computational).

*The key insight is* that a bijection between secrets and consistent missing shares pushes
the uniform measure forward to the uniform measure, so perfect security is literally the
image of `privacyEquiv` under `PMF.map`; the counting bijection already proved becomes a
zero-advantage security bound with no new combinatorics.

*Why now?* Mathlib's `PMF` and `PMF.uniformOfFintype` are stable and interoperate cleanly
with `Equiv` (`PMF.map` of a bijection of a uniform PMF is uniform), so the jump from
"bijection" to "identical distributions" is a short `PMF.map`-style argument rather than
new probability infrastructure.

## 3. Functorial composition: gate-by-gate security of a whole arithmetic circuit

Lift the per-gate results to whole circuits by modeling a circuit as a finite DAG of
add/scalar/mul gates and proving, by induction on topological order, that the joint
sharing of all wire values reconstructs the circuit output (each step is `reconstruct_add`,
`reconstruct_zsmul`, or `beaver_gate_correct`) and that every adversarial view remains
equivocable. This is a concrete, finitary stand-in for the universal composition theorem.

*The key insight is* that `privacyEquiv` and `rerandomizeEquiv` are *bijections* (`Equiv`),
and bijections compose, so security of a circuit is the composite of per-gate bijections —
recasting "universal composition" as the statement that a finite composite of `Equiv`s is
again an `Equiv`, which Lean handles definitionally via `Equiv.trans`.

*Why now?* The gate-level invariants are already `Equiv`-valued rather than mere
propositions, which is exactly the shape needed to compose them without re-proving privacy
at each step; an inductively-defined `Circuit` type plus `Equiv.trans` is the whole proof
skeleton, and `beaver_gate_correct` supplies the only nonlinear gate.

## 4. Malicious security: authenticated (SPDZ-style) shares via information-theoretic MACs

Extend the semi-honest backbone to active security by attaching to each secret `x` a MAC
`m = α·x` under a global random key `α`, sharing both `x` and `m` additively, and proving
that the linear gates preserve the MAC relation while any additive tampering by a corrupt
party is caught except with probability `1/|F|`.

*The key insight is* that the MAC relation `m = α·x` is itself a linear gate in the present
sense — applying `reconstruct_zsmul`/`reconstruct_map` to the key-scaling map — so MAC
consistency is *preserved for free* under add and scalar gates, and only the Beaver gate
needs an extra triple-on-the-MAC; the soundness bound reduces to the fact that a nonzero
linear polynomial in `α` has at most one root.

*Why now?* The free-gate algebra (`reconstruct_map` with the `α`-scaling homomorphism) and
the multiplication gate (`beaver_gate_correct`) are both in place, so authentication is a
thin linear overlay rather than a new framework, and the soundness probability is a single
`Finset.card`-style counting argument over a field.

## 5. Bridging to the matroid access structures already in the catalog

Connect this arithmetic file to `Catalog/Bridges/ClosureMatroidSecretSharing.lean` by
proving that the additive scheme *realizes* the access structure whose only qualified set
is the full party set (the `n`-out-of-`n` threshold), and conjecture the converse for
matroid ports: every representable matroid access structure is realized by a linear
secret-sharing scheme over a large enough field.

*The key insight is* that linear secret-sharing schemes and representable matroids are two
views of the same linear-algebraic object — qualified sets are spanning sets of a matrix's
columns — so the catalog's closure/rank `Qualified` predicate should coincide with
"the restricted reconstruction map `reconstruct ∘ (restrict to the party subset)` is
surjective," which for the additive scheme is exactly `share_privacy_existence` for
qualified sets and `privacyEquiv` for unqualified ones.

*Why now?* The catalog already contains a fully certified matroid/closure access-structure
layer and this file now supplies the concrete linear shares; the missing link is a single
definitional bridge identifying `Qualified` with surjectivity of a restricted
`reconstruct`, making the cross-domain unification (combinatorics ↔ linear algebra ↔
cryptography) immediately actionable.
