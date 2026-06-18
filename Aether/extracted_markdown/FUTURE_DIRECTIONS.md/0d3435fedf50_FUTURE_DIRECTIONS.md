# FUTURE_DIRECTIONS — Dream Logic: Paraconsistent Reasoning over Belnap's FOUR₂

## Synthesis

This cycle lifted the *algebraic* paraconsistency of the catalog file
`Logic.BelnapBilattice` (which proves `Belnap.explosion_fails` and
`Belnap.bneg_not_complement` as facts about a four-valued distributive bilattice)
to a *proof-theoretic* layer: a propositional language `Form`, a four-valued
semantics `eval`, and a multiple-premise consequence relation `DreamEntails`. The
new file `Catalog/Logic/DreamLogic.lean` proves eight theorems with zero `sorry`
and only the `propext` axiom. The headline results are that **ex contradictione
quodlibet fails** (`dream_non_explosion`) and that **disjunctive syllogism fails**
(`dream_disj_syllogism_fails`) — the two inferences whose collapse is the signature
of First-Degree Entailment — while the lattice rules ∧-elimination and
∨-introduction survive intact (`dream_conj_elim_valid`, `dream_disj_intro_valid`).

The structural insight that emerged is that **paraconsistency and non-monotonicity
are independent phenomena**. We proved `dream_entails_monotone`: the Tarskian
relation `DreamEntails` is fully monotone even though it is paraconsistent. This
sharpens the catalog's `consistent_consequence_nonmonotone`, which obtains
non-monotonicity only by *restricting to consistent (gap/glut-free) models*. So the
"belief retraction" half of the research brief does not live in the base
consequence relation at all; it must be sought in a *preferential* refinement.

The other decisive result is the *localisation* of paraconsistency. The classical
bridge `dream_classical_bridge` shows that on two-valued valuations dream-designation
coincides exactly with Boolean truth, and `dream_classical_explosion` shows explosion
*returns* there (vacuously: no two-valued world designates both `p` and `¬p`). Taken
with `dream_non_explosion`, this proves the glut value `B` is the *sole* algebraic
source of paraconsistency. What was deferred this cycle: the priority targets
`CarmichaelComposite` / `Fib_gcd_identity` remain blocked because their Lean
infrastructure references a missing module (`Shared.CarmichaelHelper`) and an
undefined `fib_primitive_divisor_prime`, and the one genuine `sorry`
(`fib_carmichael_composite`, composite `n > 10000`) is the full infinite-tail
Carmichael primitive-divisor theorem — a Zsygmondy-class result needing cyclotomic
machinery far beyond a single cycle. We deliberately invested compute in the
self-contained, fully-closeable dream-logic theory instead.

## Results Summary

- `dream_non_explosion`: **proved** — `p, ¬p ⊬ q`; ex falso quodlibet fails as an inference (inference-level form of catalog `Belnap.explosion_fails`).
- `dream_disj_syllogism_fails`: **proved** — `¬p, p∨q ⊬ q`; disjunctive syllogism fails, the defining invalidity of FDE.
- `dream_conj_elim_valid`: **proved** — ∧-elimination `φ∧ψ ⊢ φ` survives paraconsistency.
- `dream_disj_intro_valid`: **proved** — ∨-introduction `φ ⊢ φ∨ψ` survives paraconsistency.
- `dream_double_negation`: **proved** — `¬¬φ` and `φ` are semantically identical (via `bneg_involution`).
- `dream_entails_monotone`: **proved** — the consequence relation is monotone; paraconsistency ≠ non-monotonicity.
- `dream_classical_bridge`: **proved** — on two-valued valuations, designation = classical truth (induction on `Form`).
- `dream_classical_explosion`: **proved** — explosion holds on two-valued valuations, localising paraconsistency to the glut value `B`.

## Research Directions

### Direction 1: Preferential ("most-consistent-model") consequence is genuinely non-monotone
**Hypothesis**: Define `PrefEntails Γ φ` := `φ` is designated in every *gap/glut-minimal* model of `Γ` (a model minimising the set of atoms valued `B` or `N`). Then `PrefEntails` validates disjunctive syllogism on consistent premises yet there exist `Γ ⊆ Δ` and `φ` with `PrefEntails Γ φ` and `¬ PrefEntails Δ φ`.
**Test**: Formalise the minimal-model order and prove a two-atom witness (e.g. `Γ = [p]`, `Δ = [p, q ∧ ¬q]`) where adding the contradiction destroys the unique minimal model that supported `φ`. Disprove by exhibiting monotonicity if the minimisation is mis-specified.
**Why now**: `dream_entails_monotone` proved the *base* relation is monotone, so we now know exactly where to inject non-monotonicity — only the model-preference layer. The key insight is that belief retraction is a property of *model selection*, not of the truth tables, so the four-valued semantics can stay fixed while only the quantifier over models changes.
**If true**: Completes the "beliefs can be retracted" half of the brief and gives a Lean-checked example of paraconsistent default reasoning.
**If false**: Tells us minimal-model preference alone cannot be both paraconsistent and non-monotone, pointing toward genuinely ordered/ranked belief states.

### Direction 2: A sound and complete Hilbert calculus for `DreamEntails`
**Hypothesis**: The relation `DreamEntails` is exactly axiomatised by the FDE rules (double negation, De Morgan, ∧/∨ lattice rules, and the meta-rule of cut) with NO ex-falso and NO disjunctive syllogism.
**Test**: Define an inductive provability predicate `FDEProves Γ φ` and prove soundness (`FDEProves Γ φ → DreamEntails Γ φ`) and completeness (the converse) by a four-valued canonical-model construction.
**Why now**: We already have the semantics (`eval`, `DreamEntails`) and the validity of every candidate rule (`dream_conj_elim_valid`, `dream_disj_intro_valid`, `dream_double_negation`) plus the invalidity of the two forbidden ones. The key insight is that completeness reduces to building, for each underivable sequent, a single FOUR₂ counter-valuation — and our witness valuations already show the template.
**If true**: Upgrades the file from a semantic study to a full deductive system, a genuinely citable formalisation of FDE.
**If false (one direction fails)**: Pinpoints exactly which structural rule the four-valued semantics secretly validates or forbids.

### Direction 3: De Morgan / negation-normal-form theorem inside dream logic
**Hypothesis**: Every `Form` is semantically equal (for all `v`) to a formula in negation-normal form, via a `pushNeg` rewriting that uses only `bneg_involution` and the De Morgan identities for `tInf`/`tSup`.
**Test**: Define `pushNeg : Form → Form` and prove `eval v (pushNeg φ) = eval v φ` by induction, then prove `pushNeg` outputs are NNF.
**Why now**: `dream_double_negation` is the base case and the catalog's `bneg_deMorgan_inf` / `bneg_deMorgan_sup` give the inductive steps for free. The key insight is that FOUR₂ is a De Morgan algebra, so normalisation is purely equational and avoids any appeal to bivalence.
**If true**: Provides a decision-procedure scaffold (NNF + finite valuation enumeration) for `DreamEntails`.
**If false**: Would reveal a connective whose negation is not De-Morgan-reducible, i.e. a hidden non-distributivity.

### Direction 4: Knowledge-ordering monotonicity of the consequence relation
**Hypothesis**: If valuation `v'` is everywhere ≥ₖ `v` in the *knowledge* ordering (more information), then every premise designated under `v` stays designated under `v'`, hence `DreamEntails` conclusions are preserved under information growth.
**Test**: Port the catalog's `kLE` and `tInf_kLE_monotone_left` / `tSup_kLE_monotone_left`, prove designation is ≤ₖ-upward-closed, and conclude a "monotone under information increase" theorem for `DreamEntails`.
**Why now**: The catalog already proved FOUR₂ is an *interlaced* bilattice (truth operations are knowledge-monotone). The key insight is that "dreaming more vividly" (adding information, possibly gluts) can only add beliefs, never retract them — the formal dual of Direction 1's retraction phenomenon.
**If true**: Connects the proof-theoretic layer back to the full bilattice structure, realising the cross-domain bridge the catalog invites.
**If false**: Identifies a designated set that is not a knowledge-filter, an interesting anomaly.

### Direction 5: Decidability and a verified validity checker
**Hypothesis**: `DreamEntails Γ φ` is decidable, and a checker that enumerates the `4^k` valuations on the `k` atoms occurring in `Γ ∪ {φ}` is sound and complete.
**Test**: Prove that `DreamEntails` depends only on the finitely many atoms appearing in the formulas (a "coincidence lemma": valuations agreeing on those atoms agree on `eval`), then build a `Decidable` instance and verify it against `dream_non_explosion` and `dream_disj_syllogism_fails`.
**Why now**: Every operation (`bneg`, `tInf`, `tSup`, `designated`) is already `Decidable` and finite, and our existing proofs are essentially hand-run instances of this enumeration. The key insight is that paraconsistent validity is *finitely refutable*, so the only missing piece is the coincidence lemma restricting to the support atoms.
**If true**: Turns the file into an executable paraconsistent reasoner with a machine-checked correctness proof.
**If false**: Would mean `eval` secretly depends on atoms outside the formula — impossible by construction, so failure here only signals a malformed `support` definition to repair.
