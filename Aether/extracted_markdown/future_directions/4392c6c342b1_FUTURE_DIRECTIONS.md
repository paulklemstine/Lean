# Future Directions — The Regular Representation of Eckmann–Hilton Algebra

## Synthesis

This cycle pursued the **Duality & Representation** program on the catalog's
Eckmann–Hilton bridge. The previous cycle (`EckmannHiltonMonoid.lean`) proved an
*abstract* identification: a doubly-unital interchanging pair of operations is exactly
a commutative monoid (`toCommMonoid`, `ofCommMonoid`, `eh_iff_commMonoid`,
`structure_rigidity`). That answered *what* the structure is, but kept the operations
opaque.

The new file `Catalog/Speculative/AutoResearch/EckmannHiltonRepresentation.lean`
supplies the missing **concrete dual model**. It realizes the abstract vertical
operation `m₁` as honest self-maps of the underlying set under composition, and proves
this realization is faithful with commutative image:

- `regRep` / `regRep_injective` / `regRep_image_comm` — Cayley's theorem for
  commutative monoids: left translation `a ↦ (a * ·)` is an injective monoid
  homomorphism into `Function.End M` with commutative image. Faithfulness is automatic
  by evaluating at `1`.
- `ehRep_one`, `ehRep_mul`, `ehRep_injective`, `ehRep_comm`, `ehRep_apply` — the same
  picture ported directly to raw `EckmannHiltonData`, using only the catalog lemmas
  `EckmannHilton.assoc`, `EckmannHilton.comm` and the unit laws.
- `eckmannHilton_faithful_representation` — the capstone: *every* Eckmann–Hilton
  structure is, faithfully and concretely, a commuting algebra of operators on its own
  underlying set, with the original operation recovered by evaluation `(rep a) b = m₁ a b`.
- `bridge_roundtrip` — the `EckmannHiltonMonoid` bridge is a genuine involution:
  `E ↦ toCommMonoid E ↦ ofCommMonoid` recovers `E` field by field (the `m₂` field
  matches via `EckmannHilton.same_op`).

The duality pairing in play is **evaluation**: the geometric object (self-maps) and
the algebraic original (the operation) are interchangeable because `(rep a) b = m₁ a b`.
This is the elementary, fully-formal shadow of Gelfand/Stone-style "points are
evaluations" dualities.

## Results Summary

All results are `sorry`-free and depend only on the permitted axioms
(`propext`, `Classical.choice`, `Quot.sound`). The file builds against the existing
catalog Eckmann–Hilton infrastructure via `import`, reproving nothing.

## Research Directions

### 1. The representation is a *full* isomorphism onto its image, naturally in `M`.

We proved `regRep` is an injective monoid homomorphism. The next falsifiable claim is
that `regRep` corestricts to a **monoid isomorphism** `M ≃* (Set.range (regRep M))`,
and moreover that this assignment is *natural*: every monoid homomorphism `f : M →* N`
intertwines `regRep M` and `regRep N` along post-composition, making `regRep` a natural
transformation from the identity functor to the "self-maps" functor on `CommMon`.
**The key insight is** that faithfulness already gives the object-level isomorphism for
free, so the only remaining content is a single `funext` naturality square — a
finite, mechanical obligation rather than a new idea. **Why now?** The injectivity and
homomorphism lemmas (`regRep_injective`, `regRep`'s `map_mul'`) are exactly the two
inputs a `MulEquiv.ofInjective`-style construction consumes; the scaffolding is already
in this file. This is falsifiable: if the corestriction fails to be surjective onto
`Set.range`, the claim dies immediately.

### 2. Eckmann–Hilton commutativity is equivalent to commutativity of the represented operators.

We showed (one direction) that EH data yields a *commutative* image
(`ehRep_comm`). The bold converse: for **any** unital magma `(X, m, e)`, the left-
translation maps `m a · : X → X` pairwise commute under composition **iff** `m` is a
commutative monoid operation. **The key insight is** that "operators commute" unpacks
to `m a (m b x) = m b (m a x)`, which at `x = e` is commutativity and in general is
medial associativity — so the operator-level commutativity is logically equivalent to
the entire commutative-monoid package, not merely a consequence of it. **Why now?** The
forward direction is already formalized here via `ehRep_comm`; only the reverse
implication (commuting translations ⇒ associative + commutative) remains, and it is a
self-contained equational exercise. This is falsifiable by exhibiting a non-associative
unital magma whose translations nonetheless commute.

### 3. The representation detects and quantifies failure of higher structure: `rep` is an isomorphism of *categories* of EH-structures and commuting-operator algebras.

Define a "commuting operator algebra on `X`" as a submonoid `S ≤ Function.End X` that
is commutative and acts faithfully and transitively-at-the-unit. Conjecture: the maps
`E ↦ ehRep E '' univ` and "operator algebra ↦ its evaluation operation" are mutually
inverse equivalences, upgrading `bridge_roundtrip` from an involution on data to an
**equivalence of categories**. **The key insight is** that `eckmannHilton_faithful_representation`
already lists *exactly* the closure properties (unital, multiplicative, commutative,
faithful, evaluation-recovering) that characterize the image, so the image is not an
arbitrary subset but a definable subcategory. **Why now?** With the involution
(`bridge_roundtrip`) and the faithful representation both formal, the remaining work is
to package both directions as functors and check the round-trips — no new mathematics,
only categorical bookkeeping. Falsifiable: if some commuting faithful operator algebra
is *not* of the form `ehRep E`, the equivalence fails.

### 4. Spectral/dual translation: characters of the EH monoid vs. simultaneous eigenstructure of the operator family.

Pursue the genuine duality analogue. For a finite commutative Eckmann–Hilton monoid
`M`, conjecture a perfect pairing between monoid characters `M →* (ℂˣ, ·)` and the
simultaneous eigenvalues of the commuting family `{regRep M a}` acting on `ℂ[M]`: each
character is a joint eigenvalue assignment, and the assignment is a bijection when `M`
is a finite abelian *group*. **The key insight is** that commuting diagonalizable
operators share an eigenbasis, and the regular representation's commutativity
(`regRep_image_comm`) is precisely the hypothesis that unlocks simultaneous
diagonalization — turning the algebraic dual (characters) into the spectral dual
(joint eigenvalues). **Why now?** `regRep` and `regRep_image_comm` give the commuting
family on a silver platter; Mathlib already has finite-dimensional simultaneous-
eigenvector machinery, so the pairing is reachable for the group case. Falsifiable:
count characters vs. joint eigenvalues on a small non-group monoid (e.g. `(ℕ, max)`
truncated) — equality should fail there, sharpening the group hypothesis.

### 5. Transport the representation to close the Fibonacci–Carmichael primitivity gap.

The catalog's `CarmichaelComposite` / `CarmichaelProof` chain leaves the *infinite
tail* (composite `n > 10000`) of "every Fibonacci number `F(n)`, `n ≥ 13`, has a
primitive prime divisor" open, and currently depends on a missing helper module.
Conjecture a representation-theoretic reformulation: a prime `p` is a primitive divisor
of `F(n)` iff the Fibonacci entry point `fibEntryPt p` equals `n`, i.e. iff the
left-shift operator on `ZMod p`-valued Fibonacci states has order exactly `n`. **The
key insight is** that entry-point divisibility (`fibEntryPt_dvd_of_fib_dvd` in
`CarmichaelComposite.lean`) is exactly a statement about the *order of a single
operator* — the companion matrix `[[1,1],[1,0]] mod p` — so primitivity becomes a
spectral/order condition amenable to the same "represent the algebra by one operator"
move used here for Eckmann–Hilton. **Why now?** The entry-point lemmas are already
formal; recasting the growth argument for `n > 10000` as a lower bound on operator
order (via the cyclotomic factorization of `F(n)`) replaces the analytic tail with a
finite-order/representation argument, and first restoring the missing
`Shared.CarmichaelHelper` module is a concrete, well-scoped prerequisite. Falsifiable:
the entry-point characterization can be checked computationally against the existing
`primPart_check` table on `[13, 10000]`; any mismatch refutes the reformulation.
