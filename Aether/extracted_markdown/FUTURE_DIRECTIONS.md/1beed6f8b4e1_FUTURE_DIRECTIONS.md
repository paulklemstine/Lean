# Future Directions: Synthetic Homotopy of Spheres on a Classical Base

The new file `Catalog/Bridges/CircleFundamentalGroup.lean` closes a gap left open
by the catalog's `Catalog/Bridges/HoTTFoundations.lean`: it upgrades the winding
*homomorphism* π₁(S¹) → ℤ into a genuine **group isomorphism** π₁(S¹) ≃+ ℤ, by
building the fundamental group as an honest quotient `Pi1S1 = Quotient loopSetoid`
with an `AddCommGroup` structure, and proving infinite-cyclicity. The following
research directions extend this constructive bridge between Homotopy Type Theory
and classical algebra. Each is concrete, testable, and falsifiable.

## 1. The integral homology / fundamental group of the wedge `S¹ ∨ S¹` is the free group `F₂`

The `FormalLoop` model used here is, before quotienting, the *free monoid on one
generator-pair* `{true, false}`. Replacing the single-circle alphabet `Bool` with
a two-letter alphabet equipped with formal inverses yields a model of the
figure-eight `S¹ ∨ S¹`, whose fundamental group should be the free group on two
generators. **The key insight is** that the winding-number quotient generalizes
to a "reduced-word normal form" quotient, and the abelianization of that quotient
recovers `ℤ × ℤ` exactly as `windingClass` recovers `ℤ`. *Why now?* The present
file already isolates the only nontrivial ingredient — that the homomorphism
descends to the quotient and is injective on normal forms — so the free-group
case is a direct structural generalization rather than new theory.

Falsifiable form: prove `Pi1Wedge ≃* FreeGroup (Fin 2)`; the conjecture fails if
the natural concatenation quotient collapses any reduced word to the identity.

## 2. πₙ(S¹) = 0 for all `n ≥ 2` in the combinatorial model

Having computed π₁, the natural next invariant is the higher homotopy of the
circle, which classically vanishes because ℝ is the contractible universal cover.
**The key insight is** that contractibility of the cover is mirrored by the fact
that `windingClass` is a *bijection* onto a set (ℤ, an h-set), so every loop space
above degree 1 is a mere proposition; formally, the iterated based loop space of
`Pi1S1` is contractible. *Why now?* The file already proves `windingClass` is
injective and surjective (`windingClass_injective`, `windingClass_surjective`),
which is precisely the encode–decode data needed to show the higher loop spaces
are singletons; the remaining work is packaging this as an `IsContr` statement.

Falsifiable form: prove `Subsingleton (Pi1S1 ≃+ ℤ)`-style triviality of the second
loop space; it fails if a nontrivial self-homotopy of the identity loop exists.

## 3. A degree map realizing `πₙ(Sⁿ) ≃+ ℤ` uniformly in `n`

The catalog's `conjectured_pi_n_trunc` (in `HomotopyTypeTheory.lean`) predicts that
πₙ(Sⁿ) ≅ ℤ with truncation level scaling linearly in `n`. Our `n = 1` case is now
fully proved as `windingAddEquiv`. **The key insight is** that the winding number
is the `n = 1` instance of a combinatorial *degree* of a based map, computable as
a signed count of preimages of a regular value; this count is additive under the
join/suspension operation that takes Sⁿ to Sⁿ⁺¹. *Why now?* With the `n = 1`
isomorphism established as a clean `≃+`, the suspension step can be stated as a
homomorphism `degree_{n+1} ∘ Σ = degree_n` and attacked inductively, reusing the
quotient-descent pattern proved here.

Falsifiable form: construct `SphereDegree n : Pi_n_Sn n ≃+ ℤ`; fails if the
suspension map is not an isomorphism on degrees for some specific small `n`.

## 4. The winding isomorphism is natural: degree-1 self-maps of S¹ induce `±id` on ℤ

A group isomorphism is most useful when it is *natural* with respect to maps of
the underlying space. Self-maps of the circle of degree `d` should act on
π₁(S¹) ≅ ℤ as multiplication by `d`. **The key insight is** that on the
`FormalLoop` model a degree-`d` self-map is realized by the alphabet endomorphism
sending each generator to its `d`-fold power, and `windingClass` intertwines this
endomorphism with multiplication-by-`d` on ℤ. *Why now?* `windingAddEquiv` gives a
canonical identification with ℤ, so naturality becomes a finite computation of
`windingClass (f∗ x) = d • windingClass x` checkable on the explicit generators
`intLoop n`.

Falsifiable form: prove `windingClass (map_d l) = d * windingClass l`; fails if any
alphabet endomorphism induces a non-multiplicative map on winding numbers.

## 5. Constructive equiconsistency: π₁ computations as a witness of HoTT ⊢ ZFC-strength

The catalog's `FoundationalSystem` framework asserts `hott_equiconsistent_zfc`
purely at the level of strength labels. **The key insight is** that a *fully
constructive* computation of π₁(S¹) ≅ ℤ — using only `propext`, `Classical.choice`,
and `Quot.sound`, as verified for `windingAddEquiv` — is itself an interpretability
witness: any theorem of classical algebra about `ℤ` transports along the
isomorphism to a theorem about the synthetically-defined `Pi1S1`. *Why now?* The
present file makes the transport map (`windingAddEquiv`) a first-class object, so
one can begin formalizing a transfer functor `Thm(ℤ) → Thm(Pi1S1)` and measure
which classical principles are actually consumed.

Falsifiable form: exhibit an `AddCommGroup` theorem about ℤ whose transported
statement about `Pi1S1` requires an axiom beyond `{propext, Classical.choice,
Quot.sound}`; its existence would refute the "no extra strength" claim.
