# Future Directions: Constructive Foundations from Homotopy Type Theory

## Synthesis

This cycle built `Applications/HoTT/ConstructiveFoundations.lean`, a *self-contained*
fragment of Homotopy Type Theory inside Lean 4.  The central design decision — and the
reason the development is non-trivial rather than collapsing to bookkeeping — is that
Lean's native `Eq` lives in `Prop` and therefore satisfies definitional proof
irrelevance (UIP / axiom K).  Working with `Eq` would make every type a set and every
"homotopical" statement vacuous.  We instead introduced a synthetic Martin-Löf identity
type `Path`, an *indexed inductive valued in `Type`*, whose only eliminator is path
induction (`Path.rec`).  For such a type UIP is **not** derivable, so `Path` genuinely
models the homotopical identity type, and all groupoid/coherence laws have to be proved
by honest path induction.

Four headline results were proved with **zero `sorry`** and verified axiom-clean
(`#print axioms` reports *no* axioms for the equivalence and identity theorems, and only
`Quot.sound` for the truncation HIT, which is unavoidable and permitted):
the coincidence of the two notions of equivalence (`equiv_iff_contr_fibers`), the full
biconditional Fundamental Theorem of Identity Types (`fundamental_theorem_id`),
equivalence induction from a univalence hypothesis (`equivalence_induction`), and
propositional truncation as a genuine higher inductive type with its recursion principle
and uniqueness (`PTrunc.rec`, `PTrunc.rec_unique`).

The structural insight that emerged is a *contractibility-juggling* style: almost every
"hard" theorem reduces to transporting `IsContr` along a quasi-inverse (`isContr_of_qinv`)
or a retract (`isContr_of_retract`), seeded by exactly one workhorse — singleton
contractibility (`singleton_contr`).  The genuinely delicate content concentrated in two
places: (1) adjointification (`qinv_to_ishae`/`adjoint_triangle`), the HoTT 4.2.3
path-algebra that an arbitrary quasi-inverse lacks, which forced us to build a small
2-cell calculus (`trans_assoc`, `symm_trans`, `cancel_right`, `homotopy_natural`); and
(2) the total-implies-fibrewise transfer (`fibrewise_of_total`, HoTT 4.7.7), where we
discovered that a *retract* — needing only a single homotopy that collapses to `refl`
under path induction — suffices, sidestepping the full fibre equivalence.  The principal
failure mode was attempting the `QInv → IsEquiv` direction *directly*: it cannot be closed
without the adjoint coherence `tau`, which is precisely why the half-adjoint structure
`IsHAE` is the necessary intermediary rather than a stylistic choice.

## Results Summary

- `equiv_iff_contr_fibers`: proved — a map has a quasi-inverse iff all its fibres are contractible; identifies the "naive" and "good" notions of equivalence.
- `qinv_of_isEquiv`: proved — easy direction (contractible fibres give a quasi-inverse).
- `qinv_to_ishae`: proved — adjointification: a quasi-inverse upgrades to a half-adjoint equivalence (the hard HoTT 4.2.3 coherence, via `adjoint_triangle`).
- `ishae_to_isEquiv`: proved — a half-adjoint equivalence has contractible fibres (HoTT 4.2.4).
- `fundamental_theorem_id`: proved — full biconditional: a fibrewise family `f : ∀ x, Path a x → C x` is a fibrewise equivalence iff `Σ x, C x` is contractible.
- `ftid_forward`: proved — fibrewise equivalence forces the total space to be contractible.
- `ftid_backward`: proved — contractibility of the total space manufactures the fibrewise equivalences (the encode–decode engine).
- `fibrewise_of_total`: proved — total equivalence implies fibrewise equivalence (HoTT 4.7.7, one direction), via the fibre-retract argument.
- `equivalence_induction`: proved — under a `Univalence` hypothesis, a property of all equivalences out of `A` follows from the identity-equivalence case.
- `equivSpace_contr`: proved — univalence makes the space of equivalences out of `A` contractible.
- `singleton_contr` / `singleton_contr_types`: proved — based path spaces are contractible (the workhorse).
- `PTrunc.is_prop`: proved — `‖A‖₋₁` is a mere proposition (path constructor of the HIT).
- `PTrunc.rec` / `PTrunc.rec_beta` / `PTrunc.rec_unique`: proved — recursion principle into subsingletons, with computation and uniqueness.
- `isContr_of_qinv` / `isContr_of_retract` / `qinv_between_contr` / `totalMap_qinv`: proved — the contractibility-transport toolkit.
- `homotopy_natural` / `Path.trans_assoc` / `Path.symm_trans` / `Path.cancel_right` / `ap_comp` / `ap_id` / `eta_natural`: proved — the 2-cell path-algebra calculus.

## Research Directions

### Direction 1: A definitional computation rule for equivalence induction
**Hypothesis**: Strengthening `Univalence` to a *coherent* structure that additionally
carries `Path (idToEquiv (toId (idEquiv A))) (idEquiv A)` as a compatibility law makes
`equivalence_induction uv P base B e` reduce to `base` (up to a stated `Path`) when
`e = idEquiv A`, i.e. the eliminator satisfies a propositional β-rule, and the simple
`Univalence` used here already yields the β-rule *propositionally*.
**Test**: State `equivalence_induction_beta : Path (equivalence_induction uv P base A (idEquiv A)) base` and attempt to prove it by unfolding `equivSpace_contr` and using that `(equivSpace_contr uv A).contr` of the center is path-equal to `refl` (a contractibility-of-contractibility argument).
**Why now**: `equivSpace_contr`'s center is already *definitionally* `⟨A, idEquiv A⟩` (that is exactly why the base case type-checks), so the only missing ingredient is that the chosen contraction restricts to `refl` at the center — a local 2-cell computation.
**If true**: equivalence induction becomes a usable computational eliminator, not just a transport, enabling clean transport-of-structure proofs.
**If false**: it pinpoints which extra coherence (a `leftInv`-style law on `idToEquiv`) univalence must carry for the β-rule, sharpening the interface.

### Direction 2: The 2-out-of-3 and 2-out-of-6 closure laws for equivalences
**Hypothesis**: `IsEquiv` (contractible fibres) is closed under 2-out-of-3: for
`f : A → B`, `g : B → C`, if any two of `f`, `g`, `g ∘ f` are equivalences, so is the third;
and the stronger 2-out-of-6 law holds.
**Test**: Prove `isEquiv_comp`, `isEquiv_cancel_left`, `isEquiv_cancel_right` by passing
through `QInv` with `equiv_iff_contr_fibers`, composing/​cancelling quasi-inverses, then
returning to `IsEquiv` via `isEquiv_of_qinv`.
**Why now**: with both faces of equivalence proved equal (`equiv_iff_contr_fibers`), one
can do the bookkeeping at the level of *quasi-inverses* (where composition is trivial) and
transport the conclusion back to the propositional `IsEquiv` for free.
**If true**: yields the categorical backbone (a "homotopy category") and the standard
equivalence-stability lemmas needed for everything downstream.
**If false** (unlikely): a counterexample would reveal that our `IsEquiv` is subtly weaker
than the intended notion, exposing a definitional bug in `Fib`/`IsContr`.

### Direction 3: The Structure Identity Principle as a bridge to `Algebra`
**Hypothesis**: For a one-sorted signature (start with pointed magmas: a carrier with a
binary operation and a unit), an *isomorphism* of structures — an equivalence of carriers
commuting with the operations — induces a `Path` of structures, so every property transports
across isomorphism via `equivalence_induction`.
**Test**: Define `StructEquiv (M N : Magma)`, build a map `StructEquiv M N → Path M N`
under `Univalence`, and prove `transport_property : (P : Magma → Type) → StructEquiv M N → P M → P N`.
**Why now**: `equivalence_induction` is exactly the reduction "prove `P` of an isomorphic
structure ⇒ prove `P` of the identity isomorphism", and it is proved and axiom-clean here;
only the (purely mechanical) commutation-with-operations layer remains.
**If true**: connects this `Applications/HoTT` development to the catalog's `Algebra`
results, letting algebraic theorems be transported along isomorphism with no manual rewriting.
**If false**: it isolates exactly which naturality square fails for multi-sorted or
infinitary signatures, charting the boundary of the SIP.

### Direction 4: Voevodsky's theorem — univalence implies function extensionality
**Hypothesis**: Working with a synthetic universe carrying only a `Univalence`-style
structure (and *no* appeal to Lean's ambient `funext`), naive non-dependent function
extensionality for maps into that universe is derivable.
**Test**: Show the weak-equivalence map `(A → Σ b, Path b ·) → (A → B)` is a fibrewise
equivalence over the contractible based-path space, then apply `fundamental_theorem_id`
to a path space of function types to extract `funext`.
**Why now**: the *full biconditional* `fundamental_theorem_id` proved this cycle is the
precise engine Voevodsky's argument uses; the previously available one-directional form
(`ftid_forward` alone) was insufficient — the manufacturing half `ftid_backward` is what
makes the derivation reachable.
**If true**: demonstrates inside Lean the deep HoTT fact that funext is a *consequence*,
not an assumption, of univalence — a result Lean's proof-irrelevant `Eq` normally hides.
**If false**: it would reveal that our `Univalence` interface is too weak (e.g. missing a
coherence), telling us exactly what to add.

### Direction 5: Encode–decode for concrete identity types (bridge to `Combinatorics`)
**Hypothesis**: `fundamental_theorem_id` is a *computation device*: for a concrete type
(`Bool`, then `Fin n`), choosing a code family `C` with a contractible pointed total space
*reads off* its identity type, e.g. `Path (a : Bool) b ≃ (if a = b then Unit else Empty)`,
with the `Fin n` version giving a counting consequence cross-listed to the catalog's
combinatorial results.
**Test**: For `Bool`, define `C : Bool → Type`, exhibit `IsContr (Total C)`, and obtain the
fibrewise equivalence from `ftid_backward`; then count.
**Why now**: the forward-manufacturing half (`ftid_backward`) — absent from the catalog and
supplied this cycle — turns encode–decode into a turnkey method: designing `C` is the entire
creative step, and the equivalence is then free.
**If true**: provides reusable, fully verified identity-type computations and a concrete
HoTT → combinatorics dictionary.
**If false**: a mis-specified `C` will fail to be contractible, which itself diagnoses the
correct code family — the method is self-correcting.
