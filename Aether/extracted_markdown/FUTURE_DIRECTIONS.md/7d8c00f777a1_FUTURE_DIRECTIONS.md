# Future Directions — Ramanujan-Style Intuition as Formalizable Meta-Reasoning

Derived from this cycle's findings (`Core.lean`, `Halting.lean`,
`FiniteBoundary.lean`, `JumpBridge.lean`). Each conjecture is bold, falsifiable,
and stated so that a single Lean theorem (or counterexample) would settle it.

The central correction this cycle produced: **the mission's literal "length ≤ 100"
framing is false** (`bounded_oracle_computable`) — every bounded family is decided
by a computable lookup table, *even for a non-computable truth function*. The real
obstruction is **sound + complete behaviour on an unbounded domain**
(`no_computable_sound_complete_oracle`), and its structural home is the **oracle
jump hierarchy** (`JumpBridge.lean`). The conjectures below build on this.

---

## C1. Soundness forces *infinitely many* abstentions, not just one.
**Statement.** Every computable, sound verdict oracle for the halting predicate
answers `unknown` on an infinite set of codes (not merely one).
**The key insight is** that a single abstention can always be patched by a finite
table (`FiniteBoundary.bounded_oracle_computable`), so any *finitely-abstaining*
sound computable oracle could be upgraded to a perfect one — contradicting
`no_computable_sound_complete_oracle`; hence the abstention set must be infinite.
**Why now?** We already have the perfect-oracle impossibility and the finite-table
upgrade lemma in this cycle; combining them via a finiteness/pigeonhole argument is
the immediate next Lean step.

## C2. High accuracy does **not** imply non-computability (accuracy is a red herring).
**Statement.** There exists a non-computable truth function `τ` and a *computable*
verdict oracle whose committed answers are correct with asymptotic density `1`.
**The key insight is** that the density of "hard" instances, not raw accuracy, is
what computability controls; a non-computable set can have a computable density-1
approximation, so the mission's "≥ 95% accuracy ⇒ non-computable" is unprovable as
stated and should be *refuted* by an explicit construction.
**Why now?** `Core.lean` shows diagonalization only forces *one* error per oracle,
never a positive error density — exactly the gap a density-1 computable approximant
would exploit. The tools (computable tables + a sparse non-computable set) are in hand.

## C3. The "intuitive leap" is strictly stronger than any finite tower of leaps.
**Statement.** For every `OracleJumpR` `J` and sound incomplete Ramanujan oracle,
the limit `⋃ₙ (J.iter T₀ n).provable` strictly contains every finite level
`(J.iter T₀ n).provable`, yet is still incomplete relative to truth.
**The key insight is** that `truth_invariant` pins the model while
`strict_hierarchy` (both used in `JumpBridge.lean`) make the provable sets a strict
ω-chain — so the union escapes every level but a fresh diagonal escapes the union.
**Why now?** `JumpBridge.lean` already imports the strict-hierarchy and
truth-invariance machinery; the catalog's `limit_escape` is the missing lemma to
wire in, making this a short composition.

## C4. Identifying the leap with the *Turing* jump requires the arithmetical hierarchy.
**Statement.** There is no order-embedding from the abstract `OracleJumpR` tower to
the Turing-degree jump tower `0, 0', 0'', …` definable without naming a `Σ⁰₁`
truth predicate; conversely, *with* such a predicate the embedding exists and is
unique up to the first level.
**The key insight is** that `OracleJumpR` is purely extensional (strict + truth
preserving), whereas the Turing jump is intensional (it is the halting set of the
previous level); bridging them is exactly the content `Halting.lean` isolates via
`ComputablePred.halting_problem`.
**Why now?** This cycle produced both endpoints — an abstract jump tower
(`JumpBridge.lean`) and a concrete halting non-computability witness
(`Halting.lean`); the conjecture asks precisely for the morphism between them.

## C5. "Discovery without proof" is formalizable as a sound oracle with unbounded verification delay.
**Statement.** There is a computable, sound, *eventually complete* oracle for any
`Σ⁰₁` family — one that commits correctly to every true statement after a finite
(but unbounded) delay — and no such oracle exists for a properly `Π⁰₁` family.
**The key insight is** that Ramanujan's "guess now, verify later" matches semi-
decidability: enumerability gives eventual `true`-commitment, while the absence of
co-enumerability is exactly what blocks completeness — the same asymmetry behind
`no_computable_sound_complete_oracle`.
**Why now?** The verdict/soundness/completeness vocabulary built in `Core.lean`
plus Mathlib's `RePred`/`Partrec` API make the `Σ⁰₁` (yes) vs `Π⁰₁` (no) split a
direct next formalization, turning the metaphor into a theorem.
