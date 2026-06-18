# Future Directions: Constructive Foundations from Homotopy Type Theory

The file `ConstructiveFoundations.lean` establishes a self-contained HoTT
fragment with four load-bearing results: the coincidence of the two notions of
equivalence (`equiv_iff_contr_fibers`), the *full biconditional* Fundamental
Theorem of Identity Types (`fundamental_theorem_id`), the equivalence-induction
principle that the univalence hypothesis unlocks (`equivalence_induction`), and
a genuine higher inductive type — propositional truncation — with its recursion
principle (`PTrunc`, `PTrunc.rec`, `PTrunc.rec_unique`). The following
directions extend this frontier; each is testable in Lean and falsifiable.

## 1. A computation rule for equivalence induction

`equivalence_induction` currently gives only the *eliminator*: a proof of
`P A (refl A)` yields `P B e` for all `B, e`. The natural next theorem is the
**β/computation rule**: when the eliminator is applied to the reflexivity
equivalence, it returns the base case *propositionally*, and — under a
strengthened coherent `Univalence` carrying `idToEquiv (toId (refl A)) = refl A`
as a `leftInv`-style law — even *definitionally*. One should also prove the
**2-out-of-3** and **2-out-of-6** closure laws for `≃ₕ` directly from
`equiv_iff_contr_fibers`.

The key insight is that contractibility of fibers (`qequiv_contr_fiber`) makes
"being an equivalence" a *proposition*, so the 2-out-of-3 law reduces to a
contractibility-juggling argument that never needs to inspect the chosen
inverses. Why now? With both faces of equivalence already proved equal in this
file, the property-level reasoning that 2-out-of-3 requires is finally available
without re-deriving inverses by hand.

## 2. The n-truncation hierarchy

`PTrunc` is the `(-1)`-truncation. Define the `0`-truncation (set truncation) as
the quotient by the "mere-equality" relation, and conjecture its universal
property: maps into any h-set factor uniquely through it. More ambitiously,
build the general `n`-truncation by a hub-and-spoke quotient and prove the
recursion principle into `n`-types.

The key insight is that each truncation level is characterized by a *lifting
property against the next sphere inclusion*, and `PTrunc.rec_unique` is exactly
the `n = -1` instance of that uniform statement — so the hierarchy is obtained by
replaying one proof schema with the relation parameter varied. Why now? The
quotient-as-HIT pattern is already validated here for `n = -1`; promoting the
relation from `fun _ _ => True` to `mere-equality` is a small, local change that
immediately tests whether the schema generalizes.

## 3. The Structure Identity Principle (cross-domain bridge to `Algebra`)

Using the `Univalence` hypothesis, conjecture and prove a **Structure Identity
Principle**: for a one-sorted algebraic signature (e.g. monoids), isomorphic
structures are *equal*, hence every property is transported across isomorphism by
`equivalence_induction`. This connects the present `Applications/HoTT` work
directly to the catalog's `Algebra` developments.

The key insight is that an isomorphism of structures is precisely an equivalence
of carriers that commutes with the operations, and `equivalence_induction` lets
us reduce "prove `P` of an isomorphic structure" to "prove `P` of the identity
isomorphism" — collapsing transport-of-structure to a single base case. Why now?
`equivalence_induction` is the exact tool the SIP needs, and it is proved and
axiom-clean in this file, so the only remaining work is the (purely
bookkeeping) commutation-with-operations layer.

## 4. Voevodsky's theorem: univalence implies function extensionality

In Lean, `funext` is ambient, which obscures the deep HoTT fact that it is a
*consequence* of univalence. Conjecture: working with a synthetic universe `𝒰`
equipped only with a `Univalence`-style structure (and *no* ambient `funext`),
one can derive function extensionality for maps into `𝒰`. Formalize the
weak-equivalence / naive-non-dependent-funext chain abstractly.

The key insight is that the map `(A → Σ_{b} (b = ·))  →  (A → B)` is a
fiberwise equivalence over the contractible based-path space, so `funext` falls
out of `fundamental_theorem_id` applied to a path space of function types. Why
now? The biconditional Fundamental Theorem proved here is the precise engine
Voevodsky's argument uses; the one-directional catalog version was insufficient,
so this derivation only becomes reachable with `fundamental_theorem_id`.

## 5. Encode–decode for concrete identity types (bridge to `Combinatorics`)

Apply `fundamental_theorem_id` as a *computation device*: pick a concrete family
`C` (the coproduct `Bool`, the natural numbers, a finite type) and exhibit a
contractible pointed total space to *read off* the identity type of that type.
Conjecture closed-form codes for `a = b` in coproducts and in `Fin n`, with the
counting consequences cross-listed to the catalog's combinatorial results.

The key insight is that the encode–decode method is not merely descriptive: the
forward direction of `fundamental_theorem_id` *manufactures* the equivalence
`(a = x) ≃ C x` from a single contractibility witness, so designing the family
`C` is the entire creative step and the equivalence is then free. Why now? The
forward implication — the half that does the manufacturing — was missing from the
catalog and is supplied here, so encode–decode becomes a turnkey method rather
than a bespoke construction per type.
