# Computational Evidence

Target statements (formalised in `Catalog/Bridges/FundamentalGroupK1Classification.lean`):

* **Realization.** Every homomorphism `φ : π₁(C,c) → π₁(D,d₀)` between vertex groups of
  connected groupoids (models of `K(G,1)`) is induced by a functor `C ⥤ D`.
* **Conjugacy classification.** Two such functors are naturally isomorphic (= homotopic
  maps of 1-types) iff the induced homomorphisms are conjugate, i.e.
  `[K(G,1), K(H,1)] ≃ Hom(G,H)/conj`.
* **Whitehead for 1-types.** A functor between connected groupoids inducing a bijection
  on vertex groups is an equivalence.
* **Sharpness.** Without connectedness the vertex group is not a complete invariant.

These are statements about all (possibly infinite) groupoids, so the computations below
are finite sanity checks on the *finite* models, not proofs; the Lean file contains the
proofs.

## 1. Counting homomorphisms and conjugacy classes

`|Hom(G,H)|` versus `|Hom(G,H)/conj|`, the predicted cardinality of the set of homotopy
classes of maps `K(G,1) → K(H,1)`:

|  G  |  H  | \|Hom\| | \|Hom/conj\| |
|-----|-----|-------|------------|
| Z2 | Z2 | 2 | 2 |
| Z2 | Z3 | 1 | 1 |
| Z2 | Z6 | 2 | 2 |
| Z2 | S3 | 4 | 2 |
| Z3 | Z2 | 1 | 1 |
| Z3 | Z3 | 3 | 3 |
| Z3 | Z6 | 3 | 3 |
| Z3 | S3 | 3 | 2 |
| Z4 | Z2 | 2 | 2 |
| Z4 | Z6 | 2 | 2 |
| Z4 | S3 | 4 | 2 |
| Z6 | Z6 | 6 | 6 |
| Z6 | S3 | 6 | 3 |
| S3 | Z2 | 2 | 2 |
| S3 | S3 | 10 | 3 |

Note that the two counts differ exactly when the target is non-abelian: conjugation is a
genuinely necessary quotient, which is why the formal statement
`realize_natIso_iff_conj` is an "up to conjugacy" statement and not an equality.

## 2. Brute-force check of the conjugacy classification

Model of a connected groupoid with vertex group `G` and `n` objects: objects `0,…,n-1`,
`Hom(i,j) = G`, composition `(j,k,h) ∘ (i,j,g) = (i,k,hg)`. Functors into the one-object
groupoid `SingleObj(H)` were enumerated (via the parametrisation
`F(i,j,g) = t_j φ(g) t_i⁻¹` with `φ ∈ Hom(G,H)`, `t_0 = 1`, `t_i ∈ H`) and then quotiented
by natural isomorphism (components `a_i ∈ H`, `F' (m) = a_j F(m) a_i⁻¹`).

| n objects | G | H | #functors | #natural-iso classes | \|Hom(G,H)/conj\| | match |
|---|---|---|---|---|---|---|
| 1 | Z3 | S3 | 3 | 2 | 2 | ✓ |
| 1 | Z2 | S3 | 4 | 2 | 2 | ✓ |
| 1 | S3 | S3 | 10 | 3 | 3 | ✓ |
| 2 | Z3 | S3 | 18 | 2 | 2 | ✓ |
| 2 | Z2 | S3 | 24 | 2 | 2 | ✓ |
| 2 | S3 | S3 | 60 | 3 | 3 | ✓ |
| 3 | Z3 | S3 | 108 | 2 | 2 | ✓ |
| 3 | Z2 | S3 | 144 | 2 | 2 | ✓ |

The number of natural-isomorphism classes is independent of the number of objects `n`
(i.e. of the size of the connected groupoid) and equals `|Hom(G,H)/conj|` in every case
tested. This is the finite shadow of `natIso_iff_conjugating_iso` and
`realize_natIso_iff_conj`.

## 3. Counterexample hunt

* Searched for connected finite groupoids with isomorphic vertex groups that are not
  equivalent: none exist (consistent with the previous cycle's classification theorem,
  and with `isEquivalence_of_bijective_mapAut`).
* Dropping connectedness immediately produces counterexamples: the discrete groupoids on
  a one-element and a two-element set have trivial (hence isomorphic) vertex groups at
  every basepoint but different numbers of isomorphism classes of objects, so they are
  inequivalent. Formalised as `connectedness_necessary`, and topologically as
  `allHomotopyGroups_equiv_not_homotopyEquiv` (`Unit` versus discrete `Bool`, where in
  fact *all* homotopy groups agree).

## 3b. A hypothesis discovered by counterexample search

The first version of the statement "all homotopy groups of a totally disconnected space are
trivial" was refuted while formalising: for the empty index type `N = Empty` the cube is a
point and its boundary is empty, so `HomotopyGroup Empty Z z` is (in bijection with) `Z`
itself — this is `π₀`, which is exactly the invariant distinguishing `Unit` from `Bool`.
The formal statement therefore carries the hypothesis `[Nonempty N]`
(`homotopyGroup_subsingleton_of_totallyDisconnected`), and the counterexample
`allHomotopyGroups_equiv_not_homotopyEquiv` asserts agreement of all homotopy groups in
positive degrees only.

## 4. OEIS

No new integer sequence arises; the counts above are the standard "number of conjugacy
classes of homomorphisms" data and are not tabulated here as a single sequence.

## 5. Appendix (this cycle): orbit sizes and centraliser indices

The tables above count `|Hom(G,H)|` against `|Hom(G,H)/conj|`. The refinement suggested by
them — that the conjugacy class (orbit) of a homomorphism `φ` has size the index of the
centraliser of its image — is no longer conjectural: it is proved in general in
`Catalog/Bridges/FundamentalGroupK1Deepening.lean` as `card_orbit_eq_index_centralizer`
(and, in the homotopy-theoretic form counting the homomorphisms realising a fixed homotopy
class of maps of 1-types, as `card_homs_natIso_realize`). For `G = H = S₃` the three orbits
have sizes 1, 3, 6, with centralisers of the images of index 1, 3, 6 respectively.

## 6. Appendix (this cycle): π₀ + vertex groups

The `Unit` vs. discrete `Bool` counterexample of cycles 1–2 is a `π₀` phenomenon: the two
spaces have the same homotopy groups in all positive degrees but 1 versus 2 components.
Small-case bookkeeping for groupoids with `n` components and vertex groups `G₁, …, Gₙ`:
the number of equivalence classes with a fixed multiset of vertex groups is the number of
multisets of isomorphism classes, e.g. with `n = 2` and vertex groups drawn from
`{1, ℤ/2, ℤ/3}` there are 6 equivalence classes (3 with equal groups, 3 with distinct
ones), matching a bijection-of-components-plus-group-isomorphisms count.  This pattern is
no longer conjectural: it is the content of
`FundamentalGroupPi0.groupoid_equivalence_iff_pi0_aut` in
`Catalog/Bridges/FundamentalGroupPi0Decomposition.lean`, which says that the pair
(π₀, family of fundamental groups of the components) is a complete invariant of a
homotopy 1-type.
