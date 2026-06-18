# Future Directions — The Equivalence Calculus and Contractibility as a Universal Property

## Synthesis

This cycle took the fibrewise characterisation of equivalences proved last cycle
(`HoTT.bijective_iff_contr_fibers`: *a map is a bijection iff all of its homotopy
fibres are contractible*) and turned it into a working **equivalence calculus**, then
used the classical-topology bridge to nail down the **universal property** of
contractibility.

Two new, `sorry`-free files were added under `Speculative/AutoResearch/`:

* `EquivalenceCalculus.lean` introduces the first-class predicate
  `HoTT.IsEquiv f := ∀ b, IsContr (HFiber f b)` and proves the *representation
  dictionary* `HoTT.isEquiv_iff_bijective` identifying it with `Function.Bijective`.
  On top of this dictionary it derives reflexivity (`isEquiv_id`), closure under
  composition (`isEquiv_comp`), homotopy-stability (`isEquiv_of_homotopy`), the full
  **2-out-of-3 law** (`isEquiv_comp_of_isEquiv`, `isEquiv_cancel_left`,
  `isEquiv_cancel_right`), transport of h-levels along equivalences
  (`isContr_of_equiv`, `isMereProp_of_equiv`), and the **univalence-lite** transport
  of algebraic structure along *abstract* equivalences
  (`magma_comm_transport_equiv`, `magma_assoc_transport_equiv`), generalising the
  catalog's named-isomorphism transport lemmas
  (`HoTT.magma_comm_transport` / `magma_assoc_transport`).

* `ContractibleMappingSpace.lean` proves that for a contractible space `Y` the set of
  homotopy classes `[X, Y]` is itself contractible for *every* `X`
  (`HoTT.isContr_homotopyClasses`), assembled from the topological corollary
  `HoTT.maps_to_contractible_homotopic` and the synthetic packaging
  `HoTT.isContr_iff`. This is the precise statement that a contractible space is a
  **terminal object of the homotopy category**.

The unifying theme is **duality/representation**: an equivalence is *represented* by
the homotopy-spectral datum "every fibre is contractible", which is exactly dual to
the algebraic datum `Function.Bijective`; and contractibility of a *space* is dual to
contractibility of the *type* of homotopy classes mapping into it. A concrete cycle
discovery: the **2-out-of-3 law holds verbatim** for `IsContr`-fibre equivalences
with *no* extra coherence condition — the falsifiable question posed last cycle is
thereby answered in the affirmative, because in `Type` an equivalence *is* a
bijection.

## Results summary

Fully proved this cycle (`sorry = 0`; axioms ⊆ {`propext`, `Classical.choice`,
`Quot.sound`}):

* `HoTT.isEquiv_iff_bijective`, `HoTT.IsEquiv.bijective`, `HoTT.IsEquiv.of_bijective`
  — the representation dictionary `IsEquiv ↔ Function.Bijective`.
* `HoTT.isEquiv_id`, `HoTT.isEquiv_comp`, `HoTT.isEquiv_of_homotopy` — the basic
  groupoid laws.
* `HoTT.isEquiv_comp_of_isEquiv`, `HoTT.isEquiv_cancel_left`,
  `HoTT.isEquiv_cancel_right` — the 2-out-of-3 law, all three legs.
* `HoTT.isContr_of_equiv`, `HoTT.isMereProp_of_equiv` — h-levels transport along
  equivalences.
* `HoTT.magma_comm_transport_equiv`, `HoTT.magma_assoc_transport_equiv` —
  univalence-lite structure transport along fibrewise equivalences.
* `HoTT.isContr_homotopyClasses` (with `isMereProp_homotopyClasses`,
  `nonempty_homotopyClasses`) — the homotopy mapping space `[X, Y]` into a
  contractible `Y` is contractible: contractible targets are terminal.

## Direction 1 — The 2-out-of-6 law and the spans/cospans of equivalences

The 2-out-of-3 law is now `sorry`-free; the natural strengthening is the
**2-out-of-6 law**: given `f : A → B`, `g : B → C`, `h : C → D` with `g ∘ f` and
`h ∘ g` equivalences, *all six* of `f, g, h, g∘f, h∘g, h∘g∘f` are equivalences.
**The key insight is** that `isEquiv_iff_bijective` already reduces every such
question to `Function.Bijective`, where 2-out-of-6 is a short surjectivity/injectivity
diagram chase — the same machine that closed 2-out-of-3 closes 2-out-of-6 with one
extra cancellation. **Why now?** With all three legs of 2-out-of-3 proved and the
bijection dictionary in hand, 2-out-of-6 is a finite assembly with no new analytic
content; it is the last purely-formal law of an abstract class of weak equivalences,
and a clean falsifiable target (does it hold verbatim, or does the middle map `g`
require a separately-supplied section?).

## Direction 2 — A structured `IsHEquiv` layer and contractibility of the space of inverses

`IsEquiv` is a *mere proposition* (a property), whereas the catalog's `IsHEquiv` is a
*structure* (carries an explicit inverse and coherence). The bridge to build is
`isEquiv_iff_nonempty_isHEquiv : IsEquiv f ↔ Nonempty (IsHEquiv f)`, together with the
theorem that **the type of half-adjoint inverse data is contractible** whenever `f`
is an equivalence. **The key insight is** that `bijective_iff_contr_fibers` produces a
genuine two-sided inverse from contractible fibres, and the adjunction coherence `adj`
can be repaired by the standard HoTT "one triangle determines the other" argument,
which is finite equational bookkeeping over the proof-irrelevant `Prop` equalities
Lean already collapses. **Why now?** Both endpoints exist `sorry`-free in this
project — `HoTT.IsHEquiv`/`HoTT.isHEquiv_to_bijective` in the catalog and `IsEquiv`
here — so the merge is a refactor that upgrades every property-level result
(2-out-of-3, transport) to a structure-level statement usable for actual computation
of inverses.

## Direction 3 — Loop spaces, the path fibration, and π₂ abelian via Eckmann–Hilton

Define the loop space `Ω(A, a) := (a = a)` and reuse `HoTT.isContr_based_paths` to
exhibit the **path fibration** `{ b // a = b } → A` with fibre `Ω(A, a)` over `a`.
The payoff is to manufacture an honest `HoTT.EckmannHiltonData` on the *double* loop
space `Ω²` from horizontal and vertical composition of 2-cells, and then *instantiate*
the catalog's `HoTT.eckmann_hilton_comm` to conclude `π₂` is abelian. **The key
insight is** that the contractibility of the total path space — the one geometric
input — is already a proved lemma (`isContr_based_paths`), so the remaining work is
purely the equational construction of the interchange law from path concatenation and
whiskering. **Why now?** The abstract Eckmann–Hilton engine and the contractible path
space are both `sorry`-free in this project, so "π₂ is abelian" reduces to supplying
one `EckmannHiltonData` instance rather than developing new homotopy theory.

## Direction 4 — From homotopy classes to a genuine contractible mapping space

`isContr_homotopyClasses` shows the *set of homotopy classes* `[X, Y]` is contractible
when `Y` is contractible. The bold upgrade is to promote this to the topological
statement that the **mapping space `C(X, Y)` is itself a `ContractibleSpace`** (in the
compact-open topology) whenever `Y` is, and to prove the converse implication for
suitable `X` (e.g. `X` a point recovers `Y`). **The key insight is** that a
contraction of `Y` (a homotopy `id_Y ≃ const`) induces, by post-composition, a
contraction of `C(X, Y)` continuously in the compact-open topology, so the synthetic
`IsContr` of homotopy classes is the shadow of a genuine space-level contraction.
**Why now?** The homotopy-class version is already proved here, isolating exactly the
missing continuity datum (post-composition is continuous), which Mathlib's
`ContinuousMap` API supplies — turning a falsifiable conjecture (is `C(X, Y)`
contractible *as a space*, not merely up to homotopy?) into a targeted lemma.

## Direction 5 — Univalence-lite for full algebraic theories

`magma_comm_transport_equiv` / `magma_assoc_transport_equiv` transport individual
axioms along fibrewise equivalences. The structural goal is a **single transport
theorem for an arbitrary equational theory**: any first-order equational property of a
magma operation transports along an equivalence-presented homomorphism, yielding
"group structure transports", "ring structure transports", etc. as one-line corollaries.
**The key insight is** that every equation is a finite composite of `op` applications,
and `IsEquiv.bijective` lets one pull each variable back along the equivalence and push
the equation forward exactly as in the commutativity/associativity proofs — the
argument is uniform in the term shape. **Why now?** The two-axiom prototypes are
`sorry`-free, so the generalisation is a matter of quantifying over a syntactic
description of equations (a `FreeMagma`/term datatype), a sharp falsifiable claim:
does the uniform transport hold for *all* equational axioms, or only for those whose
both sides mention every variable (the "balanced" identities)?
