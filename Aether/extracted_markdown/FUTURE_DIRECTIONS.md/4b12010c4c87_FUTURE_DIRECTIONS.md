# Future Directions: Magari Algebras and the Bridge to Provability

The file `Catalog/Logic/MagariAlgebra.lean` establishes the **algebraic
semantics** of the Gödel–Löb provability logic GL: Magari (diagonalizable)
algebras, with `loeb_rule` (Löb's theorem as a fixed-point principle),
`henkin` (the only fixed point of the provability operator is `⊤`),
`godel_second` (consistency is unprovable), and `tau_four` (positive
introspection `□A → □□A` is *derived* from the Löb axiom rather than assumed).
These sit alongside the existing catalog developments of the *Kripke* semantics
(`Logic.GLKripke`, `gl_frame_validates_loeb`, `gl_frame_well_founded`) and the
*syntactic* calculus (`Logic.ProvabilityLogic.GLPFrames`, `GLPLogic.loeb_valid`).
The natural next cycle is to weld these three pillars — algebra, frames, syntax —
into a single verified completeness/duality package. Five concrete, falsifiable
directions follow.

## 1. Stone duality between Magari algebras and finite GL frames

Build the functor sending a finite `GLFrame` `F` to the Magari algebra of its
upward-closed subsets (carrier `{S // F.IsUpwardClosed S}`, with `τ = boxSet`),
and prove it is a contravariant equivalence onto finite Magari algebras whose
operator has no nontrivial fixed points below `⊤`. The catalog already proves
`box_upward_closed`, `gl_box_inter`, and `gl_box_univ` — exactly the normality
laws — and `gl_frame_validates_loeb` supplies the Löb inequality, so the object
map is essentially assembled; what remains is the arrow map and the unit/counit
isomorphisms. **The key insight is** that `gl_frame_validates_loeb` is literally
the statement `τ(τS ⇨ S) ⊆ τS` in the powerset Boolean algebra, so each GL frame
*is* a Magari algebra and Stone duality is the missing categorical glue.
**Why now?** Both halves already compile in this repository (`GLFrame.boxSet` and
`MagariAlgebra.Magari`), so the equivalence is a finite, mechanical bridge rather
than new mathematics — it is the cheapest possible "cross-domain" theorem.

## 2. Fixed-point (de Jongh–Sambin) theorem in algebraic form

State and prove: for any *box-guarded* term operator `f : B → B` on a Magari
algebra (one that factors through `τ`, i.e. `f a = g (τ a)` for some monotone
`g`), there is a unique `a` with `a = f a`, and it is explicitly computable from
`f`. The current `henkin`/`tau_fixedPoints_eq` is the special case `f = τ`.
**The key insight is** that guardedness makes Löb's axiom act as a contraction
principle, so the de Jongh–Sambin fixed point is the algebraic analogue of a
Banach fixed point and uniqueness should reduce to two applications of
`loeb_rule`. **Why now?** `loeb_rule` and `Magari.monotone` are already proved,
giving both ingredients (contraction + monotonicity) needed to make the
fixed-point iteration converge in one Boolean step.

## 3. Algebraic Solovay completeness: faithfulness of the arithmetical functor

Formalize the assignment of a Magari-algebra element to each modal formula via a
"realization" `r : MFormula α → B` (a Boolean homomorphism commuting with `τ`),
and prove the *soundness half* of Solovay's theorem fully: a GL-derivable formula
realizes to `⊤` in **every** Magari algebra. Then conjecture and target the
converse (completeness) against the free Magari algebra on countably many
generators. **The key insight is** that `GLPLogic.loeb_valid` already gives
completeness against frames, and Direction 1's duality transports it to
completeness against finite Magari algebras — so algebraic Solovay completeness
becomes a corollary of frame completeness plus duality rather than a fresh proof.
**Why now?** The syntactic Hilbert calculus (`MFormula`, `loebF`) and the
algebraic semantics now live in the same library, so the realization map can be
defined by structural recursion with every target law (`tau_top`, `tau_inf`,
`tau_loeb`) already available as named lemmas.

## 4. Quantitative Gödel II: a strict consistency hierarchy in nontrivial models

Strengthen `godel_second` from "`τ⊥ ⇨ ⊥ ≠ ⊤`" to a *strict ascending chain*
`τ⊥ < τ(τ⊥) < τ(τ(τ⊥)) < ⋯` of iterated inconsistency statements in any Magari
algebra where these are distinct, and identify exactly which algebras collapse
the chain (conjecture: precisely those of finite height, matching the depth of
the dual GL frame). **The key insight is** that `tau_four` gives `τ⊥ ≤ τ(τ⊥)`
for free, so the entire question reduces to *strictness*, i.e. to detecting
fixed-point-free behaviour of `τ` — a property visible on the frame side as the
length of the longest `R`-chain. **Why now?** `tau_four` and `tau_four_iterate`
are freshly proved, turning the hierarchy's *existence* into a one-line corollary
and isolating strictness as the single open quantity to pin down.

## 5. Polymodal Magari algebras and Beklemishev's `GLP` ordinal analysis

Generalize `Magari` to a *graded* structure with a family `τₙ` of operators
satisfying `τₙ` Löb plus the GLP interaction `τₙ a ≤ τₘ (τₙ a)` for `m < n`,
matching the `GLPFrame` levels already in `Logic.ProvabilityLogic.GLPFrames`.
Prove the graded Löb rule and the monotone-hierarchy law, then connect the
height of the resulting algebra to an ordinal notation below ε₀.
**The key insight is** that GLP's worms (iterated diamonds) form a well-order
whose order type is the proof-theoretic ordinal of PA, and the algebraic side
makes this a statement about descending chains in a single Boolean algebra rather
than about an external syntax. **Why now?** The polymodal *frames* are already
formalized with their nesting condition `R₀ ⊇ R₁ ⊇ ⋯` (`glp_loeb_at_level`), so a
graded `Magari` structure can reuse that scaffolding directly and inherit its
validity lemmas instead of rebuilding the modal apparatus.
