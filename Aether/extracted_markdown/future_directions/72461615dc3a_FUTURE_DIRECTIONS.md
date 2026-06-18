# Future Directions: Provability Logic as a Fixed-Point Theory (Cycle 2)

## Synthesis

This cycle took the order-theoretic core of Gödel–Löb logic established previously
(`GLOperator` in `LobFixedPoint.lean`, the concrete `ℕ`-model in `LobNatModel.lean`) and
pushed it in **two orthogonal structural directions**, both of which closed cleanly and
axiom-free.

The first move (`LobWellFoundedFrame.lean`) was to ask *what part of the `ℕ`-model's Löb
proof actually used `ℕ`*. The answer: nothing beyond the fact that `<` is **transitive
and well-founded**. Abstracting `natBox` to the frame box `wfBox r S = {x | ∀ y, r y x →
y ∈ S}` of an arbitrary relation, `wfBox_loeb` proves Löb's axiom for *every* transitive
converse-well-founded frame by well-founded induction on the witness, with the single
appeal to transitivity falling exactly where the `ℕ` proof used `lt_trans`. The original
`natBox` is recovered as the literal `r = (· < ·)` instance (`natBox_eq_wfBox`, by
`rfl`). Instantiating at `(Ordinal, <)` then lifts the entire `GLOperator` API
transfinitely (`OrdGL`), and the provability-rank computation `□^k⊥ = Iio k` becomes the
ordinal **ladder** `ordBox_Iio : □(Iio a) = Iio (a+1)` — boxing the depth-`a` falsity
advances the rank by exactly one successor, for every ordinal. The consistency strengths
`a ↦ Iio a` therefore form a *proper-class* strictly increasing chain
(`ordinal_consistency_strictMono`), and graded Gödel II
(`ordinal_godel_hierarchy`) holds at every ordinal: nothing special happens at limits,
the box simply keeps taking successors.

The second move (`LobDiamond.lean`) was to dualise. Over a Boolean `GLOperator`, the de
Morgan dual `dia a = (□ aᶜ)ᶜ` turns out to be a **well-founded co-closure**: every box
law has a complementary diamond law — `dia_bot` dualises necessitation, `dia_sup`
dualises normality, `dia_dia_le` dualises the derived transitivity `□a ≤ □□a`, and the
headline `dia_loeb : dia a ≤ dia (a ⊓ (dia a)ᶜ)` is literally `loeb aᶜ` rewritten through
`p ⇨ q = pᶜ ⊔ q`. The structural insight is that GL's box is simultaneously *inflationary
on theorems* (axiom 4) and *rigid off them* (Löb's rule); dually `dia` is *deflationary*
and *strictly contracting off fixed points* — exactly the signature of a well-founded
nucleus, with no analogue among ordinary topological closure operators. The only fixed
point is `⊥` (`dia_fixedPoint_eq_bot`), dual to "the only self-provable element is `⊤`".

What failed / was constrained: the diamond development needs **Boolean**, not merely
Heyting, structure — involutive complement (`compl_compl`) is what makes the duality
`(dia a)ᶜ = □aᶜ` round-trip. And `wfBox_loeb` genuinely needs *both* transitivity and
well-foundedness; dropping transitivity gives a well-founded frame that need not validate
axiom 4, hence is not GL. These two hypotheses are the precise frame conditions for GL.

## Results Summary

- `wfBox_loeb`: proved — Löb's axiom holds for the box of *any* transitive
  converse-well-founded frame; the frame-theoretic engine of GL soundness, generalising
  `natBox_loeb`.
- `wfBox_top`, `wfBox_inf`: proved — necessitation and normality for the general frame box.
- `natBox_eq_wfBox`: proved — the existing `ℕ`-model is exactly the `r = (· < ·)` instance.
- `OrdGL`: proved (instance) — `Set Ordinal` is a Gödel–Löb algebra for the frame
  `(Ordinal, <)`, lifting the whole `GLOperator` API past `ω`.
- `ordBox_Iio`: proved — the transfinite rank ladder `□(Iio a) = Iio (a+1)`.
- `ordGL_consistent`: proved — the ordinal model is consistent (`□⊥ ≠ ⊤`).
- `ordinal_consistency_strictMono`: proved — a proper-class strictly increasing chain of
  consistency strengths.
- `ordinal_godel_hierarchy`: proved — graded Gödel II at every ordinal; an unprovability
  spectrum indexed by the ordinals.
- `GLOperator.dia_compl`, `dia_bot`, `dia_sup`, `dia_mono`: proved — `dia` is a
  monotone, join-preserving, `⊥`-strict operator (the dual of the box laws).
- `GLOperator.dia_dia_le`: proved — sub-idempotence `◇◇a ≤ ◇a`, dual to axiom 4.
- `GLOperator.dia_loeb`: proved — the dual Löb law `◇a ≤ ◇(a ⊓ (◇a)ᶜ)`, the
  well-founded co-closure signature.
- `GLOperator.dia_fixedPoint_eq_bot`: proved — the only fixed point of `◇` is `⊥`.

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Research Directions

### Direction 1: Transfinite iterated-falsity equals `Iio` for all ordinals
**Hypothesis**: There is a well-defined transfinite iteration `boxIter a := ⋃_{b<a} □(boxIter b)`
of the ordinal box such that `boxIter a = Set.Iio a` for every ordinal `a`, refining the
finite `natBox_iterate_eq_Iio` into a genuine ordinal-indexed identity.
**Test**: Define `boxIter` by `Ordinal`-valued well-founded recursion (`Ordinal.lt_wf`)
and prove `boxIter a = Set.Iio a` by transfinite induction, using `ordBox_Iio` at
successors and an `iSup`/`Set.iUnion` computation at limits.
**Why now**: `ordBox_Iio` already supplies the successor step `□(Iio a) = Iio (a+1)`, and
`OrdGL` gives the box; only the limit `⋃_{b<a} Iio b = Iio a` step is missing, and that
is a one-line `Set.iUnion` lemma on a linear order.
**If true**: provability rank is literally the identity on the ordinals, a clean
transfinite refinement of Gödel II with explicit rank witnesses at every level.
**If false**: the failure pinpoints exactly which limit ordinals break the
rank-equals-index identity, isolating where iterated consistency "jumps".

### Direction 2: Soundness/completeness of `wfBox` against finite frames
**Hypothesis**: An inequality between `□`-terms holds in every `GLOperator` iff it holds
in `wfBox (· < ·)` on `Set (Fin n)` for all `n` (the finite transitive irreflexive
frames are complete for the `GLOperator` equational theory).
**Test**: Soundness is immediate from a `wfBox`-on-`Fin n` instance (a direct corollary
of `wfBox_loeb` once `(· < ·)` on `Fin n` is shown transitive + well-founded);
completeness requires a filtration/quotient argument embedding an arbitrary algebra into
a finite frame.
**Why now**: `wfBox_loeb` now provides the soundness half *uniformly* for every finite
frame in one lemma; the abstract algebra and a working family of finite models are both
in hand, so only the filtration step remains.
**If true**: a fully verified finite-model property for the order-theoretic core of GL.
**If false**: a concrete `GLOperator` inequality true in all finite `wfBox` frames but
refuted in some infinite algebra would be a striking incompleteness witness.

### Direction 3: `dia` as the nucleus of a sublocale of fixed points
**Hypothesis**: In a Boolean `GLOperator` the fixed points of `□` form a frame on which
`dia` acts as a nucleus, and in `OrdGL` this is the locale of `Iio`-determined subsets of
`(Ordinal, <)`.
**Test**: Show the `□`-fixed points are closed under `⊓` and arbitrary `⊔` (using
`box_inf` and, for completeness, an `iSup` version), then verify the three nucleus laws
for `dia` restricted to them, leveraging `dia_dia_le`, `dia_sup`, `dia_loeb`.
**Why now**: `dia_dia_le` (sub-idempotence), `dia_sup` (join preservation), and
`dia_loeb` (the well-founded twist) are exactly the nucleus axioms minus the ambient
frame structure, which Mathlib's `Order.Frame`/`Nucleus` API supplies directly.
**If true**: a precise sense in which provability logic is the internal logic of a
*well-founded sublocale* — a genuinely new closure-operator phenomenon.
**If false**: the specific nucleus law that fails reveals where GL's well-foundedness is
incompatible with ordinary point-free topology.

### Direction 4: Two-variable / parametric de Jongh–Sambin fixed points in `wfBox`
**Hypothesis**: The general uniqueness theorem `modalised_fixedPoint_unique` specialises
in every `wfBox` model to an *explicit computation* of the unique fixed point of any
box-guarded operator `x ↦ d ⊓ (□x ⇨ c)`, given by a closed `wfBox`-term in `c, d`.
**Test**: Instantiate `modalised_fixedPoint_unique` at `OrdGL`/`NatGL`, then compute the
fixed point set explicitly via `ordBox_Iio`/`natBox_iterate_eq_Iio` and verify the closed
form by `ext`.
**Why now**: uniqueness is already proved abstractly (`modalised_fixedPoint_unique`,
`glFix_unique`), and the frame models now come with *computable* boxes, so the fixed
point can be exhibited as an actual set rather than an abstract term.
**If true**: turns the de Jongh–Sambin theorem from an existence/uniqueness statement
into an explicit algorithm on well-founded frames.
**If false**: a box-guarded operator whose abstract fixed point has no closed `wfBox`
form would bound the expressive power of explicit Gödel/Henkin constructions.

### Direction 5: Diamond consistency hierarchy and its strictness
**Hypothesis**: The diamond iterates `◇^k ⊤` in `OrdGL`/`NatGL` form a strictly
*decreasing* chain dual to `consistency_strength_strictMono`, with `◇^k ⊤ = (Iio k)ᶜ`,
giving a "decreasing tower of consistency" mirroring the increasing falsity tower.
**Test**: Prove `dia (Iio a)ᶜ`-style identities from `dia_compl` and `ordBox_Iio`, then
establish strict antitonicity by complementing `ordinal_consistency_strictMono`.
**Why now**: `dia_compl` reduces every diamond iterate to a box iterate, and the box
iterates are already computed (`ordBox_Iio`, `natBox_iterate_eq_Iio`); the dual chain is
a direct complement of an already-proved strict chain.
**If true**: a self-dual picture of the provability hierarchy — increasing unprovable
consistencies and decreasing provable possibilities are literally complements.
**If false**: a mismatch between the box and diamond towers would expose an asymmetry
hidden by the Boolean duality, worth understanding.
