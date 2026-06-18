# FUTURE_DIRECTIONS — Temporal Logic of Proofs: Discovery Time

Seed file for the next research cycle. Source artifact: `Catalog/Logic/TemporalGLDiscovery.lean`,
extending `Catalog/Logic/TemporalGL.lean`.

## Synthesis

This cycle attacked the concept "*when* you prove something matters" by isolating, on top
of the catalog's temporal Gödel–Löb development (`Catalog/Logic/TemporalGL.lean`), the
**discovery time** of a proposition: the least stage at which the time-stamped provability
predicate `TemporalGL.TempProv` establishes it. We proved discovery time is well defined
and sharply characterised (`prov_discoveryTime`, `discoveryTime_le`,
`not_prov_before_discovery`), and we proved the central dynamical law of deduction:
**modus ponens never discovers its conclusion later than its premises become jointly
available**, `discoveryTime B ≤ max (discoveryTime (A→B)) (discoveryTime A)`
(`mp_discovery_bound`). Discoveries are also permanently self-certified
(`discovery_future_certified`), the quantitative reading of the catalog's
`future_self_certification`.

The most important outcome was a *failed* conjecture turned into a theorem. We set out to
prove the `max` bound tight — a model where the two premises have distinct discovery
times — and discovered it is **impossible**. In a classical, proof-irrelevant setting
(`propext` + `Classical.em`), `M.prov t : Prop → Prop` can only see a proposition's truth
value, and Löb's axiom together with Σ₁-completeness then erase even that: `prov t P`
collapses to `prov t True` for every `P` (`provability_collapse`). Hence all discovered
propositions share a single discovery time (`discoveryTime_collapse`), refuting the
tightness conjecture (`mp_discovery_bound_tight_refuted`).

The structural insight is sharp and actionable: the abstract `TempProv` axiomatisation is
*too coarse* to carry genuine "difficulty/timing" information about individual theorems —
it measures only the system's global clock. The Löb/Σ₁ pair pins the `Nat`-valued
thresholds of `True` and `False` equal (≤ from Σ₁, ≥ from Löb). Every direction below is a
concrete way to *escape the collapse* and recover a discovery time that distinguishes
theorems, which is the prerequisite for a quantitative temporal proof theory.

## Results Summary

- `prov_discoveryTime`: proved — a discovered proposition is actually proved at its discovery time (the minimum is attained).
- `discoveryTime_le`: proved — the discovery time is the least proving stage.
- `not_prov_before_discovery`: proved — nothing is proved strictly before its discovery time (a sharp threshold).
- `mp_discovery_bound`: proved — modus ponens discovers `B` by `max` of its premises' discovery times (deduction adds no delay).
- `discovery_future_certified`: proved — after discovery, the proof is forever provably established.
- `provability_strictly_gained`: proved — a semantic GL world where a sentence is unprovable now but provable later (genuine temporal asymmetry).
- `provability_collapse`: proved — `prov t P ↔ prov t True`; classical Löb+Σ₁ provability is blind to its propositional argument.
- `discoveryTime_collapse`: proved — all discovered propositions have one and the same discovery time.
- `mp_discovery_bound_tight_refuted`: disproved (the tightness conjecture) — no `TempProv` model has distinct premise discovery times.

## Research Directions

### Direction 1: Proof-relevant discovery time (escape the collapse)
**Hypothesis**: Replacing the Prop-valued `prov : ℕ → Prop → Prop` by a *Type*-valued
`Proof : ℕ → Sort* → Type` (a stage-indexed family of proof objects, with `K`/`sigma1`
as term-level operations and a Löb *fixed-point combinator* instead of the Prop axiom)
admits a model in which two theorems have provably *distinct* discovery times.
**Test**: Construct such a `ProofRelevantTempProv` in Lean with an explicit two-theorem
witness `discoveryTime A ≠ discoveryTime B`, then re-prove a tightness version of
`mp_discovery_bound`. Disproof = a Type-level replay of `provability_collapse`.
**Why now**: `provability_collapse` shows *exactly* which step kills information — the
`propext`/`Classical.em` reduction of every Prop to `True`/`False`. The key insight is
that the collapse is a proof-irrelevance artifact, not an inevitability of Löb; moving to
`Sort*` removes the very `eq_true`/`eq_false` rewrites the collapse proof relies on.
**If true**: discovery time becomes a genuine complexity measure on theorems, and
`mp_discovery_bound` becomes a non-vacuous subadditivity law.
**If false**: Löb-style fixed points force flatness even proof-relevantly, a strong and
surprising limitation worth its own paper.

### Direction 2: Intuitionistic `TempProv` without `Classical.em`
**Hypothesis**: Dropping excluded middle (working in the constructive fragment) breaks
`provability_collapse`: there is an intuitionistic `TempProv` where `prov t P ↔ prov t True`
fails for some `P`.
**Test**: Audit which axioms `provability_collapse` truly needs (it currently reports
`Classical.choice`), then attempt the collapse using only `propext` + the structure
axioms; if it still goes through, the collapse is constructive and this direction is
refuted, which is itself informative.
**Why now**: The current proof visibly uses `by_cases`/`em` twice. The key insight is that
the `False`-branch reasoning ("either `prov t False` or not") is the only place classical
logic enters, so the collapse may be exactly co-extensive with `em`.
**If true**: constructive temporal provability retains discovery-time content for free.
**If false**: the collapse is constructive, sharpening Direction 1 as the only escape.

### Direction 3: Discovery time as a metric / ultrametric on theorems
**Hypothesis**: On a non-collapsing model (Direction 1 or 2), the map
`d(A,B) := |discoveryTime A − discoveryTime B|` — or the "join time" `max`-based
divergence from `mp_discovery_bound` — satisfies an *ultrametric* triangle inequality
`d(A,C) ≤ max (d(A,B)) (d(B,C))` along chains of modus ponens.
**Test**: Prove the ultrametric inequality from an iterated `mp_discovery_bound` over a
finite deduction chain `A 0 → A 1 → … → A n` (state the chain version first).
**Why now**: `mp_discovery_bound` already gives the `max`-form one-step law; the key
insight is that `max`-subadditivity is precisely the ultrametric axiom, so the geometry is
latent in this cycle's main theorem.
**If true**: proofs live in an ultrametric space; clustering = shared lemmas, a new
quantitative lens on proof dependency DAGs (cf. `Catalog/Applications/ProofDAG`).
**If false**: deduction chains accumulate delay super-`max`, revealing hidden cost in long
proofs.

### Direction 4: Arithmetical realisation over Peano Arithmetic
**Hypothesis**: There is a faithful `TempProv` where `prov t A` means "PA proves `A` with a
proof of Gödel-number ≤ `t`", and under this realisation `discoveryTime` equals the actual
least proof length — and crucially this model is proof-relevant enough to *avoid* the
collapse.
**Test**: Define the bounded-proof predicate over a Mathlib formalisation of PA / a
free deduction system, verify the `TempProv` axioms (persistence is monotonicity in the
length bound; `K` is cut; Σ₁ is provable Σ₁-completeness; Löb is the formalised Löb
theorem), and check whether `provability_collapse` is blocked because the predicate is
about *codes*, not Props.
**Why now**: The catalog already hosts provability-logic infrastructure
(`Catalog/Logic/ProvabilityLogic`, `GLKripke`). The key insight from this cycle is that
indexing by *proof size* (a property of syntax, invisible to `propext`) is exactly the
extra structure the abstract model threw away.
**If true**: discovery time is grounded in real proof complexity, connecting temporal GL
to bounded arithmetic.
**If false**: arithmetisation re-introduces the collapse, showing it is intrinsic to Löb
provability rather than to the shallow embedding.

### Direction 5: Temporal independence / speed-up phenomena
**Hypothesis**: In a non-collapsing model there exist propositions whose discovery time
strictly *exceeds* `max` of any finite set of available premises that classically entail
them — a "no shortcut" / speed-up theorem — yet adding one new axiom collapses their
discovery time to `0`.
**Test**: Build a model with a target `G` discoverable only at stage `n` from the base
axioms but at stage `0` once an oracle axiom `Ax` is present; quantify the speed-up
`discoveryTime_base G − discoveryTime_with_Ax G`.
**Why now**: `provability_strictly_gained` already realises "unprovable now, provable
later" semantically. The key insight is that the same mechanism (shrinking counterexample
sets over time) can be *parameterised by added axioms*, turning temporal gain into a
measure of axiomatic power.
**If true**: temporal GL captures Gödelian speed-up quantitatively, linking to
`Catalog/Speculative/AutoResearch/NaturalProofsBarrier`.
**If false**: discovery time is insensitive to axiom strength, bounding the expressiveness
of the framework.
