# Future Directions: Tropical Closure Capacities as Monotone Semimodule Valuations

The file `Catalog/Bridges/TropicalClosureCapacityReconstruction.lean` fuses the
finite closure-operator machinery (`FiniteClosureSystem`, mirroring
`SetClosureOperator` in `Bridges/AlgebraEMLReconstruction` and the speculative
`IsClosureOperator`/`ClosedSets`/`ClosureCapacity` of
`Speculative/.../PadicClosureInformationDuality`) with a tropical-valued valuation
viewpoint. It proves a constructive reconstruction theorem
(`recoveredClosure_eq_cl`), a fixed-point correspondence
(`closed_iff_recoveredStable`), the existence of faithful valuations
(`tautologicalValuation_faithful`), a faithful *tropical profile* into the linearly
ordered chain `ℕ` (`binProfile_faithful`), an algorithmic recovery of the closure
operator from a single integer fingerprint
(`recoveredClosure_binProfile_eq_cl`), and a boundary result showing faithfulness
is necessary (`recoveredClosure_constZero`). The following directions extend that
program; each is stated so it can be turned into a Lean theorem (or refuted).

## 1. Quantitative separation thresholds for the tropical profile

The current `binProfile` lands in `ℕ` and is faithful, but it uses up to `2^(card α)`
distinct values — exponentially many. **Conjecture:** for a closure system with `m`
closed sets, there is a faithful valuation into `Fin (m)` (equivalently into a chain
of length exactly the number of closed sets), and no faithful valuation into a
strictly shorter chain exists. The key insight is that *faithfulness is precisely an
order-embedding of the closed-set lattice into the value chain*, so the minimal
chain length is the height of any linear extension of that lattice, i.e. exactly the
count of closed sets. **Why now?** The reconstruction theorem already isolates
faithfulness as the only needed axiom, and `binProfile_faithful` shows a concrete
faithful valuation exists; the remaining step — replacing the binary code by a
linear-extension rank and proving optimality — is a finite, fully formalizable
combinatorial statement.

## 2. Functoriality: pullback of faithful valuations along closure morphisms

The speculative file proves `pullbackInfo`/`pullback_comp_eq` for `ClosureCapacity`.
**Conjecture:** if `f : α → β` is a closure morphism (`f '' (clα s) ⊆ clβ (f '' s)`)
that is *closure-reflecting* (`clβ (f '' s) = clβ (f '' t) → clα s = clα t`), then the
pullback of a faithful valuation along `f` is again faithful, and
`recoveredClosure (pullback V) s = clα s`. The key insight is that faithfulness is a
separation property that transports backwards exactly when the morphism does not
collapse distinct closure classes, so closure-reflecting is the precise hypothesis.
**Why now?** `recoveredClosure_eq_of_faithful` already shows reconstruction is
independent of which faithful valuation is chosen; lifting this to a functor on the
category of finite closure systems is the natural categorical completion and reuses
the existing `IsClosureMorphism` infrastructure.

## 3. Recovering the ultrametric/idempotent capacity from a valuation

`ClosureValuation` deliberately drops the ultrametric join axiom of the catalog's
`ClosureCapacity` to permit faithfulness. **Conjecture:** a valuation `V` admits an
order-preserving reparametrization `g : β → WithTop ℕ` making `g ∘ V.toFun` satisfy
the ultrametric join `V(cl(s ∪ t)) ≤ max(V s, V t)` if and only if the closed-set
lattice is *meet-distributive* (a join-semidistributive / antimatroid condition).
The key insight is that the ultrametric join is exactly the statement that the
valuation respects the join structure of the closure lattice, which is possible on a
chain only for antimatroid-like (convex-geometry) closures. **Why now?** Both the
ultrametric `ClosureCapacity` and the plain `ClosureValuation` are now formalized
side by side, so the precise gap between them can be stated and tested directly,
turning an informal "additional hypotheses" remark into a sharp equivalence.

## 4. Algorithmic closed-set enumeration from the capacity table

`recoveredClosure_binProfile_eq_cl` computes `cl s` from the integer profile. **Conjecture:**
iterating `recoveredClosure (binProfile C)` from singletons and closing under the
recovered operation enumerates *all* closed sets of `C` in time polynomial in
`card α` times the number of closed sets, and the resulting Moore family is uniquely
determined by the profile table `s ↦ binCode C s`. The key insight is that the
profile table is a complete invariant of the closure system (faithfulness ⇒ the table
determines `cl` pointwise via `recoveredClosure`), so closed-set enumeration reduces
to a fixpoint computation over a known finite invariant. **Why now?** The recovery map
is already `Decidable`/computable in the statement layer; promoting it to a verified
enumeration algorithm with a complexity certificate is a concrete next deliverable
that connects to the `FiniteClosureSystem` enumeration goals in the catalog.

## 5. Tropical-halfspace capacities and uniqueness of the induced closure

The original concept asks whether capacities arising from *tropical halfspace
intersection data* induce a Moore family whose closure is uniquely determined by the
tropical profile. **Conjecture:** given a finite family of tropical halfspaces
indexed by `α`, the map `s ↦` (the set of indices whose halfspace contains the
tropical span of `s`) is a closure operator, its closed sets form a Moore family, and
the binary profile of that operator coincides (up to order-isomorphism) with the
tropical-convex-hull valuation. The key insight is that tropical convex hull is itself
an EMI closure operator, so the bridge theorem `recoveredClosure_eq_cl` applies
verbatim once the halfspace-membership operator is shown to be extensive, monotone and
idempotent. **Why now?** With the abstract reconstruction proved and a concrete chain-
valued faithful valuation in hand, instantiating it on genuine tropical-convexity data
is the final step that makes the Bridges↔Tropical interface fully geometric rather
than purely lattice-theoretic.
