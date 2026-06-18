# Future Directions — Saturation of the Equivalence Calculus and Universal Transport

## Synthesis

This cycle pushed the *representation/duality* program of the synthetic-HoTT foundation
`Logic.HomotopyTypeTheory` one structural layer further. That foundation already
represents every homotopical equivalence faithfully by `Function.Bijective`
(`HoTT.fiber_equiv_characterization`, `HoTT.bijective_of_contr_fibers`,
`HoTT.isHEquiv_to_bijective`) and transports each *fixed binary* algebraic axiom along a
magma isomorphism (`HoTT.magma_comm_transport`, `HoTT.magma_assoc_transport`). Two new
`sorry`-free files close the two open structural questions left dangling by that
representation:

* `Catalog/Speculative/AutoResearch/EquivalenceLadder.lean` — the **2-out-of-6 law** for
  the class of equivalences. The crux `HoTT.isEquiv_middle_of_six` pins down the *middle*
  map of a composable triple `A→B→C→D` with no extra section data: surjectivity is read
  off the outer factor of `g ∘ f` (`Function.Surjective.of_comp`) and injectivity off the
  inner factor of `h ∘ g` (`Function.Injective.of_comp`). From it
  `HoTT.isEquiv_two_out_of_six` derives that *all four* of `f, g, h, h∘g∘f` are
  equivalences, and the classical 2-out-of-3 laws
  (`HoTT.isEquiv_two_out_of_three_left` / `_right`) appear as the `n = 2` rungs.

* `Catalog/Speculative/AutoResearch/UniversalTransport.lean` — **universal transport** over
  an *arbitrary finitary signature*. A signature `HoTT.Sig` carries operation symbols of
  arbitrary arity; `HoTT.Term` is the free term algebra; `HoTT.Structure` interprets it;
  `HoTT.StructureHom` / `HoTT.StructureIso` are homomorphisms / isomorphisms. The
  naturality square `HoTT.evalTerm_hom` (homomorphisms commute with term evaluation,
  proved by structural induction whose `app`-case hypothesis is the arity-agnostic
  `∀ i, …`) drives the headline theorem `HoTT.equation_transport`: any equation holding for
  all assignments in `A` holds in any isomorphic `B`, by pulling each assignment back
  through the surjective inverse (`Function.surjInv`). The binary magma transports reappear
  as the one-operation corollaries `HoTT.comm_transport_of_universal` /
  `HoTT.assoc_transport_of_universal`.

The unifying theme: **the 2-out-of-6 law and universal transport are the two closure laws
a localisation-of-fractions calculus requires** — the first says the class of equivalences
is saturated under squeezing, the second says all *equational* structure is invariant under
it. Together they isolate exactly the formal content needed before one can invert the
equivalences.

## Results Summary

Fully proved this cycle (`sorry = 0`; axioms ⊆ {`propext`, `Classical.choice`,
`Quot.sound`}; `HoTT.isEquiv_middle_of_six` and `HoTT.isEquiv_two_out_of_six` use *no*
axioms at all):

* **Equivalence ladder:** `HoTT.isEquiv_two_out_of_three_left`,
  `HoTT.isEquiv_two_out_of_three_right`, `HoTT.isEquiv_middle_of_six`,
  `HoTT.isEquiv_two_out_of_six`, plus the reflexivity / transitivity rungs
  `HoTT.isEquiv_id`, `HoTT.isEquiv_comp`.
* **Universal transport:** `HoTT.Sig`, `HoTT.Term`, `HoTT.Structure`, `HoTT.StructureHom`,
  `HoTT.StructureIso`, `HoTT.evalTerm`, `HoTT.evalTerm_hom`, `HoTT.equation_transport`,
  `HoTT.evalTerm_binary`, `HoTT.comm_transport_of_universal`,
  `HoTT.assoc_transport_of_universal`.

---

## Direction 1 — The 2-out-of-n ladder over indexed chains

The two proven rungs (2-out-of-3 and 2-out-of-6) are the base of a conjectured uniform
**2-out-of-n ladder**: for any composable chain `f₁, …, fₙ` (modelled as a `List` of maps,
or an `ℕ`-indexed family with the composability constraint as a hypothesis), if every
*adjacent pair composite* `fᵢ₊₁ ∘ fᵢ` is an equivalence then every individual map and every
sub-composite is an equivalence. **The key insight is** that `HoTT.isEquiv_middle_of_six`
already generalises verbatim — each interior map is squeezed between its two neighbouring
composites — so the entire ladder is an induction on chain length where the bijection
dictionary (`isEquiv_two_out_of_three_left/right`) does the per-step work, with no new
geometric content. **Why now?** Both base cases are formally closed and the decisive
middle-map lemma is axiom-free, so the remaining task is purely the inductive packaging over
`List`-indexed chains; the sharp falsifiable question is whether *adjacency* of the composite
hypotheses truly suffices, or whether some non-adjacent composite must also be assumed for
chains of length ≥ 4.

## Direction 2 — Constants, arity-0 operations, and full monoid/group transport

`HoTT.equation_transport` transports every equation over a signature whose operations have
arbitrary arity, *including* arity 0 (constants/units), since the `Fin (S.ar o) → C`
interface degenerates to `Fin 0 → C` with no special-casing. The next target is to
*stress-test* this generality: build the signature of monoids (a binary `mul` and a nullary
`e`), state the unit and associativity axioms as `HoTT.Term`s, and transport an entire monoid
structure along a `HoTT.StructureIso`, recovering `MulEquiv`-style transport as a single
instance of `equation_transport`. **The key insight is** that a surjective homomorphism must
respect constants automatically — `φ.map` evaluated at the empty argument family
`(c, ![] : Fin 0 → A.C)` forces `φ.f (A.interp c ![]) = B.interp c ![]` — so the nullary case
that usually needs a separate "preserves unit" lemma is already subsumed by `evalTerm_hom`.
**Why now?** The transport theorem is proved without ever assuming positive arity, so the
monoid / group / ring instances are now a mechanical exercise in encoding axioms as terms;
the falsifiable claim is that *no* additional hypothesis beyond bijective-homomorphism is
needed even when constants are present.

## Direction 3 — Multi-sorted signatures and module/action transport

`HoTT.Sig` is single-sorted: one carrier `C`. The structural generalisation indexes the
carrier by a sort type `S.Sort`, gives each operation a list of input sorts and an output
sort, and re-runs the same evaluation/naturality/transport pipeline. This would make "module
structure transports along a ring-and-abelian-group isomorphism" and "group action
transports" instances of one theorem. **The key insight is** that `HoTT.evalTerm_hom` never
inspects the carrier as a single type — it only uses that a homomorphism commutes with each
interpretation — so replacing `A.C : Type` by a family `A.C : S.Sort → Type` and `φ.f` by a
sort-indexed family of maps leaves the structural induction and the surjective-pullback step
formally identical. **Why now?** The single-sorted prototype is `sorry`-free and the proof is
sort-blind in spirit, so the multi-sorted version is a re-indexing rather than a new idea; the
sharp question is whether the surjective inverse must be chosen *coherently across sorts* or
sort-by-sort suffices.

## Direction 4 — Localisation: inverting the equivalences via a calculus of fractions

With 2-out-of-3, 2-out-of-6, and universal transport all proved, the class `W` of
equivalences now satisfies every closure law a *calculus of fractions* demands. The capstone
is to construct the localisation `Type[W⁻¹]` that universally inverts `W`, and to prove its
universal property: any structure-respecting assignment sending `W` to isomorphisms factors
uniquely through it, and the localisation of `Type` at `Function.Bijective` collapses
contractible types to a terminal object (linking back to `HoTT.IsContr` and
`HoTT.isContr_imp_isMereProp`). **The key insight is** that the 2-out-of-3 / 2-out-of-6 laws
are *exactly* the composability conditions formal zig-zags require, so the localisation can be
built syntactically with composability guaranteed by the laws already proven — no further
hypotheses. **Why now?** The class `W` is now formally certified to satisfy each closure law a
localisation needs, so the construction converts a scattered collection of point-wise
equivalence lemmas into a single universal object; the falsifiable claim is that the abstract
`Function.Bijective` calculus is *complete* enough to support a calculus of fractions with no
extra axioms.

## Direction 5 — Free term algebra as a left adjoint and the universality of `evalTerm`

`HoTT.evalTerm` evaluates a term in any structure under any variable assignment; this is
precisely the action of the forgetful-functor right adjoint applied to the *free*
`S`-structure on the variable set `V`. The direction is to prove the **universal property of
`Term S V`** directly: assignments `V → A.C` are in natural bijection with homomorphisms
`StructureHom (freeStructure S V) A`, exhibiting `Term` as a genuine free construction. **The
key insight is** that `HoTT.evalTerm_hom` is the naturality half of this adjunction already —
it says evaluation is natural in the structure — so the missing content is only the
*uniqueness* of the extending homomorphism, which is again a one-line structural induction
matching `evalTerm` on generators. **Why now?** The evaluation map and its naturality are
`sorry`-free, so the adjunction is within one induction of completion; establishing it would
let *every* equational-theory result in this project be re-derived as a corollary of a single
adjoint functor — the natural Grothendieck-style unification of the whole transport layer.
