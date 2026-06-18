# Future Directions: Derivability Phase Transitions

The file `Catalog/Computation/ProofPhaseTransitions.lean` establishes the
*deterministic skeleton* of a derivability phase transition: for an inflationary
one-step inference operator `step` on a finite universe `α` of formulas, the
derivable set grows monotonically with the inference budget
(`stage_mono_budget`), freezes forever after a single stalled round
(`stage_stable_persists`), reaches its fixed point within `Fintype.card α` rounds
(`stage_card_fixed`, `exists_threshold`), and that fixed point is the least
`step`-closed superset of the axioms (`closure_fixpoint`, `mem_closure_iff`,
`closure_le_of_closed`).

This skeleton is "deterministic" because no probability is involved — the
transition is forced by monotonicity and finiteness alone. The natural next
cycles add *quantitative* and *probabilistic* flesh to these bones.

## 1. The exact threshold function and its tightness

We proved the saturation budget is at most `Fintype.card α`. Define the *sharp
threshold* `tau step S0 = sInf {N | stage step S0 (N+1) = stage step S0 N}` and
study how far below `card α` it can sit. The conjecture is a two-sided bound:
`tau step S0 ≤ (closure step S0).card - S0.card`, with equality exactly when each
inference round adds precisely one formula (a "maximally gradual" process).
The key insight is that the cardinality sequence `n ↦ (stage step S0 n).card` is
a strictly increasing, then constant, integer sequence, so the threshold is
*literally* the number of distinct cardinality values minus one — turning a
fixed-point question into a counting question. Why now? The proven lemma
`card_stage_add_le` already packages the strict-growth bookkeeping, so the
remaining work is to invert it into an exact identity rather than an inequality.

## 2. Per-formula derivation time and the depth spectrum

Define `derivTime step S0 x = sInf {n | x ∈ stage step S0 n}` and the *depth
spectrum* `fun d => (closure step S0).filter (fun x => derivTime step S0 x = d)`.
Conjecture: the spectrum is supported on `{0, 1, ..., tau step S0}` with no gaps,
and `derivTime` is sub-additive under composition of two inference operators
`step₁ ∘ step₂`. The key insight is that `mem_stage_mono` already shows each
formula's membership indicator is a single `0 → 1` step, so `derivTime` is a
genuine well-defined grading of the closure by "proof depth," and the whole
phase transition decomposes as a disjoint union of per-formula transitions. Why
now? `mem_stage_mono` and `mem_closure_iff` give exactly the monotonicity and
finiteness needed for `sInf` to be attained, so `derivTime` is immediately
well-founded.

## 3. Monotone operators without the inflationary hypothesis

Our results assume `step` is inflationary (`S ⊆ step S`). Drop it and keep only
`Monotone step`: then `stage` is no longer increasing, but the Knaster–Tarski
fixed point still exists. Conjecture: for monotone `step` on a finite lattice,
the *inflated* operator `step' S = S ∪ step S` has the same least fixed point
above `S0` as the Knaster–Tarski least fixed point of `step` that contains `S0`,
and our `closure` for `step'` computes it. The key insight is that
inflationarity is a convenience, not a necessity — replacing `step` by
`S ↦ S ∪ step S` recovers every theorem in this file while preserving the fixed
point, so the deterministic skeleton extends to *all* monotone inference systems.
Why now? `closure_le_of_closed` is already stated for merely `Monotone step`, so
the minimality half of the bridge is done; only the construction half remains.

## 4. Probabilistic onset: a genuine (random) phase transition

Replace the deterministic operator by a random one: each potential inference
rule fires independently with probability `p`. Conjecture: there is a critical
`p_c` (depending on the rule hypergraph) such that the expected closure size
`E[(closure step_p S0).card]` exhibits a threshold in `p` — vanishingly small
below `p_c` and a positive fraction of `card α` above it — mirroring bond
percolation. The key insight is that our deterministic monotone skeleton is the
`p = 1` boundary of this family, so the random model is a one-parameter
deformation of an object we have already fully characterized, and monotonicity in
`p` is inherited from `stage_mono_budget`. Why now? With the `p = 1` endpoint
proven exactly, the random model has a rigorous anchor against which to calibrate
the critical-probability conjecture.

## 5. Reverse mathematics of the threshold bound

The bound "saturation within `card α` rounds" is information-theoretic: it uses
only that the universe is finite. Conjecture: over a weak base theory, the
statement "every inflationary monotone operator on every finite type saturates
within `card` rounds" is equivalent to a pigeonhole/finite-`Σ⁰₁`-bounding
principle, and fails for operators on infinite well-ordered universes unless one
ascends to ordinal-indexed stages of length the Hartogs number. The key insight
is that `stage_card_fixed` is really a pigeonhole argument in disguise (a
strictly increasing chain of subsets of an `n`-element set has length `≤ n`), so
its logical strength is exactly that of finite pigeonhole. Why now? The Lean
proof isolates the combinatorial core (`card_stage_add_le` plus
`Finset.card_le_univ`), making the dependency on pigeonhole explicit and ready to
be transplanted to an ordinal-stage setting via transfinite recursion.
