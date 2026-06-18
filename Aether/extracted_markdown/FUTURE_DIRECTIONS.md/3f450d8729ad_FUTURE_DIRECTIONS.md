# FUTURE DIRECTIONS — Cellular Automata at the Ordinals: Transfinite Computation

Cycle artifact: `Catalog/Bridges/OrdinalCellularAutomata.lean`
Builds on / cross-references: `Catalog/Computation/TransfiniteCA.lean`,
`Catalog/Computation/TransfiniteCADepth.lean`, and Mathlib's
`SetTheory/Ordinal/FixedPointApproximants` (`OrdinalApprox.lfpApprox`).

## Synthesis

The catalog already contained an ℕ-indexed transfinite CA framework (`transfiniteLevel`,
`omegaLimitConfig`, `transfiniteDepth`), where each "level" is one ω-step and depth is
measured in `WithTop ℕ`. That framework can *describe* limit behaviour but cannot quantify
over genuine ordinal time, so questions such as "does this CA halt at ω, ω+1, or some
larger countable ordinal?" cannot even be stated there. This cycle closes that gap by
making **ordinal time intrinsic**: a transfinite CA is modelled as a *monotone* global
transition operator `F : Set α →o Set α`, and its run `ordRun F o := lfpApprox F ⊥ o` is
iterated along the ordinals, taking unions at limit stages. Monotonicity is exactly the
hypothesis that makes the limit-stage union the correct ("Infinite Time") semantics, the CA
analogue of an ITTM reading the limit of its tape.

Three things emerged. (1) Every monotone transfinite CA **halts at a bounded clockable
ordinal** `ord(succ #(Set α))`, becomes a genuine fixed point there, stays constant
forever after (`ordRun_const_after`), and the halting configuration is precisely the least
CA-closed configuration (`ordRun_isLeast`). This is the CA face of the boundedness of ITTM
clockable ordinals, obtained by transporting Mathlib's `lfpApprox` pigeonhole. (2) A
concrete CA (`succCA`) has clockable ordinal **exactly ω**, and exhibits a clean
super-Turing gap (`succCA_transfinite_gap`): every finite stage is *finite* yet the ω-stage
is all of ℕ — the limit step computes what no finite iteration can. (3) The conjecture we
initially left open — that some monotone CA needs *more* than ω steps — was resolved
affirmatively in-cycle (`clockable_above_omega`) by `flagCA`, whose "completion flag" cell
fires only after infinitely many cells are already active; its ω-stage is *not* a fixed
point, so its clockable ordinal is ω+1.

What failed/was abandoned: trying to reuse the catalog's `omegaLimitConfig` (which collapses
oscillation to `false` via `eventualValue`) for ordinal iteration is a dead end — it is
non-monotone, so the limit-stage semantics is not a union and the elegant `lfpApprox`
machinery does not apply. The structural lesson is that **monotonicity is the dividing line**
between CA whose transfinite dynamics are governed by lattice fixed-point theory (clean,
bounded clockable ordinals) and the oscillatory non-monotone CA of the existing files, whose
ordinal-time behaviour is genuinely harder and currently unformalized at the ordinal level.

## Results Summary

- `ordRun_zero`: proved — the ordinal run starts at the empty configuration (base of the dynamics).
- `ordRun_mono`: proved — ordinal time is monotone; once-on cells accumulate (justifies limit-as-union).
- `ordRun_succ`: proved — a successor stage applies the CA rule once (local-to-ordinal step law).
- `ordRun_halts`: proved — every monotone CA reaches a genuine fixed point at the clockable bound.
- `ordRun_eq_lfp`: proved — the halting configuration is the least fixed point of the CA.
- `ordRun_const_after`: proved — past the clockable bound the run is constant forever (true halting).
- `ordRun_isLeast`: proved — the transfinite output is the least CA-closed configuration (semantic characterization).
- `succCA_stage_nat`: proved — finite stage `n` of the successor CA is the interval `{0,…,n-1}`.
- `succCA_stage_finite`: proved — every finite stage of `succCA` is finite.
- `succCA_omega_eq_univ`: proved — `succCA` has clockable ordinal exactly ω (first limit stage = whole space).
- `succCA_lfp_eq_univ`: proved — the least fixed point of `succCA` is all of ℕ.
- `succCA_transfinite_gap`: proved — **Super-Turing gap**: all finite stages finite, ω-stage infinite.
- `flagCA_stage_nat`: proved — finite stage `n` of the flag CA is `{1,…,n}` (flag cell stays off).
- `flagCA_omega`: proved — at ω the positive cells are all on but the completion flag is still off.
- `clockable_above_omega`: proved — there is a monotone CA whose ω-stage is *not* a fixed point (clockable ordinal > ω).

## Research Directions

### Direction 1: Pin the clockable ordinal of `flagCA` to exactly ω + 1
**Hypothesis**: `ordRun flagCA (ω + 1) = Set.univ` and `flagCA Set.univ = Set.univ`; i.e. the
flag CA halts at exactly ω+1, not later. The key insight is that one successor step past the
ω-stage fires the completion flag and saturates the space, after which the operator is
idempotent, so no ordinal beyond ω+1 changes anything.
**Test**: Prove `ordRun flagCA (Ordinal.omega0 + 1) = Set.univ` via `ordRun_succ` + `flagCA_omega`,
then `ordRun_const_after`-style permanence; disprove "clockable ordinal = ω" is already done.
**Why now**: `flagCA_omega` and `ordRun_succ` are in hand this cycle, so the successor step is a
two-line rewrite away; only the saturation `flagCA (Ici 1) = univ` remains.
**If true**: gives the first *exact* transfinite clockable ordinal (ω+1) for a CA in Lean.
**If false**: would reveal a hidden additional limit phase, i.e. the flag construction is subtler than ω+1.

### Direction 2: Realize ω·2 (and ω·k) as clockable ordinals — a true ω²-staircase
**Hypothesis**: For each `k`, there is a monotone CA on ℕ (or ℕ×ℕ) whose clockable ordinal is
exactly `ω·k`, by stacking `k` independent "fill-then-flag" gadgets in disjoint tracks that
trigger one another. The key insight is that the flag mechanism of `flagCA` is *composable*:
a flag that fires at ω can seed a second track that itself needs ω more steps, pushing the
clockable ordinal to ω·2, and so on by induction.
**Test**: Define `stackCA k` on `Fin k × ℕ`, prove `ordRun (stackCA k) (ω * k) = univ` and that
no smaller ordinal works; computationally sanity-check small `k` with `#eval` on truncations.
**Why now**: We now have a reusable monotone "delay-by-ω" gadget (`flagCA`) and the lattice
toolkit (`ordRun_succ`, `ordRun_mono`, `flagCA_omega`) needed to compose gadgets cleanly.
**If true**: realizes the title's "ω²" regime and a genuine ordinal hierarchy of CA depths.
**If false**: composition leaks (one track perturbs another), exposing a monotonicity obstruction to stacking.

### Direction 3: Sharpen the clockable bound from `ord(succ #(Set α))` to a countable ordinal for ℕ-CA
**Hypothesis**: Every monotone CA on a *countable* cell space halts at a *countable* ordinal,
and in fact the supremum of clockable ordinals of ℕ-CA is exactly the Church–Kleene-style
ordinal `ω₁^{CK}`-analogue restricted to monotone operators. The key insight is that for
countable `α` the increasing chain `ordRun F` is an increasing chain of countable sets, which
must stabilize below `ω₁`, dramatically tightening the generic `ord(succ #(Set α))` bound.
**Test**: Prove `∃ o < (Ordinal.omega1 : Ordinal), ordRun F o = ordRun F (haltOrd ℕ)` for all
`F : TransfiniteCA ℕ`, using cofinality/strict-monotone-chain-into-`ω₁` arguments.
**Why now**: `ordRun_const_after` already gives a fixed point at *some* bound; the remaining
work is purely a cardinality refinement, and Mathlib's `Ordinal.omega1` / cofinality API exists.
**If true**: matches the CA boundedness theorem to the known ITTM countable clockable bound.
**If false**: would mean a countable monotone CA can be forced past ω₁ — a striking and unlikely anomaly worth isolating.

### Direction 4: Connect monotone ordinal CA to ITTM-decidable / Π¹₁ sets
**Hypothesis**: The fixed point `F.lfp` of a "locally presented" monotone CA on ℕ ranges
exactly over the **inductively definable (Π¹₁) sets** as `F` varies, mirroring the
characterization of ITTM-semidecidable sets. The key insight is that `ordRun_eq_lfp`
identifies the transfinite output with a least fixed point, and least fixed points of
positive arithmetic operators are precisely the inductive (hence Π¹₁) sets.
**Test**: Encode a positive Σ⁰ₙ operator as a `TransfiniteCA ℕ`, prove its `ordRun`-output
equals the operator's inductive closure; conversely show a non-Π¹₁ set cannot be an `F.lfp`.
**Why now**: `ordRun_isLeast`/`ordRun_eq_lfp` give the exact least-fixed-point bridge this
cycle, turning a descriptive-set-theory statement into a fixed-point statement Lean can chew.
**If true**: a rigorous CA ↔ ITTM ↔ Π¹₁ correspondence, the strongest possible "super-Turing" claim.
**If false**: pinpoints which inductive sets are *not* CA-realizable, refining the power of monotone CA.

### Direction 5: Lift the gap theorem to non-monotone CA via lim-inf semantics
**Hypothesis**: The catalog's oscillatory rules (`notRule`, etc.) admit a *well-defined*
ordinal-time semantics if limit stages use lim-inf (catalog `eventualValue`) instead of union,
and under this semantics there is still a bounded "settling ordinal," though it can exceed the
monotone bound. The key insight is that lim-inf restores a (non-monotone) form of eventual
stabilization, so a pigeonhole on configuration values still forces a repeat — but the repeat
need not be a fixed point, only an eventually-periodic orbit.
**Test**: Define `ordRunInf` using `omegaLimitConfig` at limits, attempt `ordRunInf notRule`
stabilization; the Critic should hunt for a rule whose lim-inf orbit never settles (a disproof).
**Why now**: This cycle isolated *monotonicity* as the enabling hypothesis, so the natural next
probe is exactly its boundary — the non-monotone case the existing catalog files already study at ω.
**If true**: unifies the monotone (this cycle) and oscillatory (existing catalog) frameworks under one ordinal-time theory.
**If false**: a concrete non-settling lim-inf CA is itself a valuable counterexample delimiting transfinite CA computation.
