# Future Directions — Path Spaces, h-Levels, and Contractibility as a Universal Property

## Synthesis

This cycle pushed the catalog's synthetic homotopy module `Logic.HomotopyTypeTheory`
(`HoTT.IsContr`, `HoTT.IsMereProp`, `HoTT.HFiber`, the Eckmann–Hilton argument,
transport, …) toward the structural core of the "homotopy & path spaces" program
and, crucially, *welded that synthetic picture to Mathlib's classical topology*.

The new file `Catalog/Logic/PathSpaceHLevels.lean` establishes three things at once.
First, the **path space is contractible**: the based path space `{ b // a = b }` has
contractible total space (`isContr_based_paths`), the synthetic form of path
induction. Second, the **h-level hierarchy is closed** under the basic type formers
— Σ (`isContr_sigma`, `isMereProp_sigma`), Π (`isContr_fun`), and retracts
(`isContr_retract`) — and contractibility splits cleanly as
"inhabited + mere-proposition" (`isContr_iff`). Third, and most importantly, we
proved the **fibrewise characterisation of equivalences**
(`bijective_iff_contr_fibers`): *a map is a bijection iff all of its homotopy fibres
are contractible*. This upgrades the catalog's one-directional
`HoTT.bijective_of_contr_fibers` to a true ↔ and is the cornerstone on which the
homotopy theory of equivalences rests.

The conceptual payoff is a **unification**: contractibility is exactly terminality
in the homotopy category. Synthetically, any two contractible types are equivalent
(`isContr_unique_equiv`). Classically, every continuous map into a contractible
space is null-homotopic (`map_to_contractible_nullhomotopic`) and any two such maps
are homotopic (`maps_to_contractible_homotopic`), so the mapping space `C(X, *)` is
itself contractible-up-to-homotopy. A guiding discovery this cycle: in Lean's
proof-irrelevant `Prop`, **`IsHSet` is automatically true**, so the only
homotopically non-trivial h-levels are `(-2)` and `(-1)`; the substance of "path
spaces" therefore lives precisely in `IsContr` of based path spaces and in the
fibrewise picture, which is where we concentrated all the proof effort.

## Results summary

Fully proved this cycle (`sorry = 0`, axioms ⊆ {`propext`, `Classical.choice`,
`Quot.sound`}):

* `HoTT.isContr_based_paths` — based path space `{ b // a = b }` is contractible.
* `HoTT.isContr_retract` — contractibility passes to retracts.
* `HoTT.isContr_sigma`, `HoTT.isMereProp_sigma` — Σ-closure of the h-levels.
* `HoTT.isContr_fun` — Π of contractible types is contractible.
* `HoTT.isContr_iff` — `IsContr A ↔ Nonempty A ∧ IsMereProp A`.
* `HoTT.bijective_iff_contr_fibers` — equivalence ⇔ contractible homotopy fibres.
* `HoTT.isContr_unique_equiv` — uniqueness of the terminal homotopy type.
* `HoTT.map_to_contractible_nullhomotopic`, `HoTT.maps_to_contractible_homotopic`
  — classical realisation: contractible spaces are terminal up to homotopy.

## Direction 1 — A genuine `IsEquiv`/`IsContr`-fibre layer and the 2-out-of-3 law

We characterised bijections by contractible fibres, but the synthetic theory wants a
first-class `IsEquiv f := ∀ b, IsContr (HFiber f b)` predicate with the structural
calculus built on top: closure under composition, the **2-out-of-3 law** (if two of
`f`, `g`, `g ∘ f` are equivalences so is the third), and stability under homotopy.
**The key insight is** that `bijective_iff_contr_fibers` already turns every such
question into a statement about `Function.Bijective`, which Mathlib closes
mechanically, so the entire equivalence calculus reduces to bijection bookkeeping
plus the `HFiber` dictionary we just built. **Why now?** With the ↔ in hand the
hard analytic step is finished; 2-out-of-3 is a finite assembly over
`Function.Bijective.comp` and its inverses, a clean falsifiable target (does
2-out-of-3 hold verbatim with `IsContr`-fibres, or does it need a coherence
condition?).

## Direction 2 — Univalence-lite: transport of structure along fibrewise equivalences

`isContr_unique_equiv` says contractible types are equivalent; the next step is a
**structure identity principle** stating that any property closed under `Equiv`
transports along a map with contractible fibres. **The key insight is** that the
catalog already transports algebraic structure along *isomorphisms* (`HoTT.magma_comm_transport`,
`HoTT.magma_assoc_transport`); composing those with `bijective_iff_contr_fibers`
lets one transport structure along *any equivalence presented fibrewise*, decoupling
"is an equivalence" from "carries an explicit inverse". **Why now?** Both halves
exist and are `sorry`-free in this very project — the magma-transport lemmas and the
fibre characterisation — so the merge is a refactor that immediately generalises the
catalog's transport theorems from named isomorphisms to abstract equivalences.

## Direction 3 — Loop spaces, π₁, and Eckmann–Hilton from contractible path spaces

The catalog proves Eckmann–Hilton abstractly (`HoTT.eckmann_hilton_eq/_comm`) and
models `π₁(S¹) ≅ ℤ` by fiat (`HoTT.pi1_circle`). Direction: define the loop space
`Ω(A, a) := (a = a)` and the based path space `P(A, a) := { b // a = b }`, then
derive that `π_n` is abelian for `n ≥ 2` by *instantiating* Eckmann–Hilton at the
double loop space. **The key insight is** that `isContr_based_paths` makes `P(A, a)`
contractible, so the path fibration `P(A,a) → A` has fibre `Ω(A,a)`, and the
horizontal/vertical composition of 2-cells supplies exactly an `EckmannHiltonData`
on `Ω²`. **Why now?** The contractibility of the total path space — the one missing
geometric input — is now a proved lemma, turning "π₂ is abelian" into a direct
application of an existing catalog theorem rather than new homotopy theory.

## Direction 4 — Localization: inverting a class of maps and the contractible-target universal property

`maps_to_contractible_homotopic` exhibits a contractible space as terminal in the
homotopy category. The bold next move is to define the **homotopy localization**
that inverts a chosen class `W` of continuous maps and to prove its universal
property against contractible targets. **The key insight is** that, because every
map into a contractible `Y` is null-homotopic, *every* map in `W` is automatically
inverted by `C(-, Y)`; contractible spaces are therefore `W`-local for **every** `W`,
giving a zero-cost first family of local objects to seed the theory. **Why now?**
The terminality statement is already proved here, so the localization's defining
universal arrow exists on contractible targets before any model-category machinery
is built — a sharp, falsifiable claim (is `C(-, Y)` `W`-invariant for *all* `W`
exactly when `Y` is contractible-up-to-homotopy?).
