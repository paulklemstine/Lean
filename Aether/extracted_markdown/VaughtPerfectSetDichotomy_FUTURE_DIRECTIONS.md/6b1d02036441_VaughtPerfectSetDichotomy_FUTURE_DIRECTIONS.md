# Future Directions: from the Cantor–Bendixson Dichotomy toward Vaught's Conjecture

The file `VaughtPerfectSetDichotomy.lean` proves the exact cardinal dichotomy for
closed subsets of Polish spaces: such a set is either countable or has cardinality
exactly the continuum, and never lands in the forbidden interval `(ℵ₀, 𝔠)`. This is
the topological skeleton on which every known instance of Vaught's Conjecture is
built — the conjecture is precisely the assertion that the *space of countable
models* of a countable complete theory obeys the same dichotomy. The results below
chart concrete, falsifiable next steps that move from the abstract dichotomy toward
the model-theoretic statement, reusing the catalog's descriptive-set-theory and
model-theory layers (`Mathlib.Topology.Perfect`, `Mathlib.ModelTheory.Satisfiability`,
and the `AxKochenMorleyBridge` development already present in
`Catalog/Speculative/AutoResearch`).

## Direction 1 — Extend the dichotomy from closed sets to `Gδ` and analytic sets

Our `cantor_bendixson_dichotomy` is stated for closed sets. The perfect set property
in fact holds for the much larger class of analytic (`Σ¹₁`) sets, and this is the
exact generality Vaught's Conjecture requires, since orbit equivalence relations and
spaces of models are analytic, not closed. The concrete target is
`analytic_dichotomy : IsAnalytic C → C.Countable ∨ #C = 𝔠`.
**The key insight is** that an uncountable analytic set still contains a nonempty
perfect subset (Mathlib's `IsClosed.exists_nat_bool_injection_of_not_countable`
generalizes through the Suslin operation / a Cantor scheme on a closed witness in
Baire space), so the lower bound transfers verbatim while the upper bound is the
ambient Polish cardinality bound we already proved.
**Why now?** Mathlib's Polish-space and `MeasurableSpace.CountablyGenerated`
machinery is mature enough to express analytic sets as continuous images of Baire
space, so the only missing piece is a Cantor-scheme lemma that our lower-bound proof
already exercises in the closed case.

## Direction 2 — Cardinality of the type space `S_n(T)` as an instance of the dichotomy

For a countable theory `T`, the Stone space of complete `n`-types `S_n(T)` is a
compact, totally disconnected, second countable space — a closed subspace of `2^ω`.
Our `mk_le_continuum_of_secondCountable` already bounds `#S_n(T) ≤ 𝔠`, and the
dichotomy then yields `S_n(T).Countable ∨ #S_n(T) = 𝔠`.
**The key insight is** that the number of isolated points of `S_n(T)` counts the
*principal* (algebraic) types, so the dichotomy translates directly into the
Ryll-Nardzewski/omitting-types boundary: a theory is `ℵ₀`-categorical iff every
`S_n(T)` is finite, and the dichotomy forbids exactly the "intermediate" type-space
sizes that a counterexample to Vaught would need.
**Why now?** Mathlib has `FirstOrder.Language.Theory` and Boolean-algebra/Stone-space
duality; encoding `S_n(T)` as a closed subset of `ℕ → Bool` is a finite amount of
glue, after which the present file's theorems apply unchanged.

## Direction 3 — The Vaught "never exactly two countable models" theorem

Vaught's celebrated theorem states that no countable complete theory has *exactly*
two countable models up to isomorphism. This is the smallest nontrivial case of the
conjecture and is fully provable today.
**The key insight is** that if a theory has a prime model and a countable saturated
model that are non-isomorphic, then realizing a single non-principal type produces a
*third* model strictly between them, so the count can never be `2`; formally this is a
parity/pigeonhole statement about the lattice of elementary substructures.
**Why now?** The omitting-types theorem and the existence of prime models for
small theories are within reach of Mathlib's `ModelTheory.Satisfiability` layer, and
proving "≠ 2" is a self-contained combinatorial corollary that does not need the full
descriptive-set-theoretic dichotomy — making it the ideal first *genuinely
model-theoretic* milestone after the topological backbone established here.

## Direction 4 — Effective/lightface refinement: a `Π¹₁` rank bound

Beyond cardinality, the Cantor–Bendixson *rank* of a closed set measures how many
times one must strip isolated points before reaching the perfect kernel. The
refinement target is `cantor_bendixson_rank_countable_lt_omega1 : C.Countable →
cbRank C < ω₁`, i.e. countable closed sets have countable rank.
**The key insight is** that the derivative operation `C ↦ C'` (removing isolated
points) is `≤`-monotone and eventually stabilizes at the perfect kernel, and the
stabilization ordinal is countable precisely when the kernel is empty — turning the
qualitative dichotomy into a quantitative ordinal invariant.
**Why now?** Mathlib already has `Preperfect`, the derivative-style `Perfect.splitting`
lemma, and a solid `Ordinal`/`ω₁` API; assembling the transfinite derivative as an
`Ordinal`-indexed recursion is the natural next abstraction over the kernel we use.

## Direction 5 — Topological Vaught conjecture for compact group actions

The topological Vaught conjecture asserts the same `≤ℵ₀`-or-`𝔠` dichotomy for the
orbit space of a continuous action of a Polish group on a Polish space. A tractable
fragment is the case of a *compact* (hence in particular profinite) acting group,
where orbits are closed.
**The key insight is** that for compact-group actions every orbit is a closed
(indeed compact) subset, so the *orbit count* dichotomy reduces, via a Borel
selector, to our closed-set dichotomy applied to a transversal — converting a
dynamical statement into the static cardinal statement already proved.
**Why now?** Mathlib's `Topology.Algebra.Group` and `MeasureTheory` selection
theorems supply continuous/Borel transversals for compact-group actions, so this is
the first place where the abstract dichotomy meets a real group-action application
without needing the full (open) Polish-group case.
