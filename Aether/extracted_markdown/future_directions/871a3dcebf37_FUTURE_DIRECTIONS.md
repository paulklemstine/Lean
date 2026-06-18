# Future Directions — Logic–Physics Bridge: Consistency of Physical Theories

The module `Catalog/Logic/LogicPhysicsBridge.lean` recasts the consistency of a physical
theory as a purely proof-theoretic object. It establishes two layers that are, at present,
only loosely coupled: a **Tarskian consequence calculus** describing how a physical theory
extends its mathematical core (`physical_consistency_implies_mathematical`,
`mathematical_consistency_not_implies_physical`), and an **abstract Gödel–Löb provability
calculus** in which Löb's theorem (`ProvabilityCalculus.loeb`), the second incompleteness
theorem (`second_incompleteness`), and the full independence of the consistency statement
(`consistency_independent`) are proved with no axioms. The boundary result
`loeb_needs_diagonal` pins down exactly which hypothesis (the diagonal/fixed-point lemma)
carries the incompleteness phenomenon. The directions below aim to *fuse* the two layers
and to connect them to the existing `GLKripke` semantic development in the catalog.

## Direction 1 — A provability functor from consequence systems to provability calculi

The two layers should not merely coexist; there should be a canonical construction sending
a Tarskian `ConsequenceSystem` (with an internal arithmetization) to a
`ProvabilityCalculus` whose `□` is the formalized provability predicate of that system.
**Conjecture.** For every consequence system `C` whose sentence algebra contains a faithful
arithmetization, there is a `ProvabilityCalculus` `G(C)` such that `Consistent C ⊤` (in the
sense of Layer 1) holds iff `¬ G(C).Thm G(C).bot` (Layer 2), and the extension order
`M ⊆ P` is reflected by the relation `G(M).Thm A → G(P).Thm A`. This is falsifiable: a
counterexample would be a consequence system whose downward consistency inheritance is *not*
matched by any provability calculus respecting `□`. **The key insight is** that downward
consistency inheritance (`physical_consistency_implies_mathematical`) is the Layer-1 shadow
of the monotonicity of the box modality under theory extension, so the functor must send
`Cn`-monotonicity to `□`-monotonicity. **Why now?** Both endpoints are already formalized
with clean axioms in this file, so the functor only has to be *built and checked*, not
discovered — the hard semantic content (Löb) is already done.

## Direction 2 — Relative consistency strength as a strict order on physical theories

`consistency_independent` shows `Con(T)` is undecided by `T`; the natural next object is the
*ordering of physical theories by relative consistency*. **Conjecture.** Define `P ⊳ M`
("P proves M consistent") by `P.Thm (M.Con)`. Then `⊳` is a strict, well-founded partial
order on consistent provability calculi: it is irreflexive (`second_incompleteness`),
transitive (via `nec` + `ax_box_K`), and admits no infinite descending chain. The
well-foundedness is the testable, falsifiable part. **The key insight is** that
irreflexivity of `⊳` is *literally* the second incompleteness theorem already proved here,
so the relative-consistency hierarchy of physical theories inherits the anti-reflexivity
that `GLKripke.gl_antireflexive` establishes semantically — the syntactic and semantic
anti-reflexivities should coincide. **Why now?** The catalog already contains the semantic
anti-reflexivity (`GLKripke`) and this file now supplies the syntactic one; matching them is
the missing rung, and a strict well-founded order is exactly what a physics "tower of
effective theories" (EFT cutoffs) needs to be made precise.

## Direction 3 — Quantitative independence: a complexity lower bound on `Con(T)`

The independence in `consistency_independent` is qualitative. Physics cares about *how hard*
consistency is to access. **Conjecture.** In any provability calculus with a Gödel diagonal,
the shortest `Thm`-derivation of any consequence of `Con(T)` that is itself independent grows
without bound relative to the calculus's own proof-length measure; equivalently, no
`k`-bounded proof search certifies consistency. This is falsifiable by exhibiting a calculus
with a uniformly short consistency certificate. **The key insight is** that Löb's argument is
*length-non-increasing in the wrong direction*: it converts a proof of `□A → A` into a proof
of `A`, so a short consistency proof would collapse to a short proof of `⊥`, contradicting
consistency. **Why now?** The catalog's `CircuitComplexityBarriers` and `PvsNP*` modules give
a ready vocabulary of proof-complexity barriers; bolting the now-formalized Löb mechanism
onto them turns "incompleteness" into a concrete lower-bound statement.

## Direction 4 — Soundness witnesses as physical models, and the failure of self-certification

`negCon_unprovable_of_sound` uses a classical valuation `val` in which `⊥` and `□⊥` are both
false — i.e. an external *model* witnessing genuine consistency. **Conjecture.** Such a
valuation can always be taken to factor through a `ConsequenceSystem` (a "physical model")
that is itself consistent in the Layer-1 sense; and conversely no calculus can internalize
its own soundness valuation (`Thm A → val A` with `val = Thm`) without becoming inconsistent.
The converse is the falsifiable half. **The key insight is** that soundness is exactly the
ingredient that rules out `¬Con` (Layer 2) while consistency rules out `Con`, so the
*independence* of consistency is the joint shadow of "has a model" and "doesn't prove its own
model exists." **Why now?** This file already separates the two halves into
`second_incompleteness` (no `Con`) and `negCon_unprovable_of_sound` (no `¬Con`); promoting
the abstract `val` to a structured physical model is a clean refactor with immediate payoff
for interpreting "physical consistency" as model-existence.

## Direction 5 — A Löb-style fixed-point theorem for renormalization-group flows

The diagonal field `diag` is the only thing that distinguishes a Löb calculus from a mere
modal logic (this is exactly `loeb_needs_diagonal`). Physical theories also have a canonical
fixed-point structure: RG fixed points. **Conjecture.** There is a faithful translation
sending an RG flow with a fixed point to a provability calculus whose `diag` operator is the
self-referential sentence "this theory flows to a consistent fixed point," under which a
theory proves its own UV-completion exactly when it is inconsistent (the Löb collapse).
Falsifiable: a consistent theory that provably reaches its own fixed point would refute it.
**The key insight is** that an RG fixed point is a solution of `T = F(T)` — formally the same
shape as the Gödel diagonal `diag A ↔ (□ diag A → A)` — so the obstruction to a theory
"certifying its own UV completion" is a Löb obstruction, not a dynamical one. **Why now?**
With `diag` isolated as the load-bearing hypothesis of Löb in this file, and the `Physics`
catalog already carrying mass-gap and metastability fixed-point machinery
(`CertifiedMassGapBounds`, `LongTimeMetastability`), the fixed-point analogy can finally be
stated as a precise, checkable translation rather than a metaphor.
