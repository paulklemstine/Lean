
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle opened a constructive bridge between three faces of ordinal analysis,
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Proof-Theoretic Bridge: Ordinal Analysis A

## Synthesis

This cycle opened a constructive bridge between three faces of ordinal analysis,
all stated over Mathlib's *computable* notation system `ONote` / `NONote` (Cantor
normal forms below `ε₀`):

* the **well-ordering** of the notation system (a proof-theoretic invariant),
* the **termination** of any algorithm carrying an `ε₀`-valued monovariant (an
  algorithmic invariant), and
* the **fast-growing hierarchy** `fastGrowing : ONote → ℕ → ℕ`, an effective,
  `native_decide`-evaluable family of number-theoretic functions.

The connective tissue is the single theorem `terminates_of_measure`: a state space
`α` equipped with a step map and an `ε₀`-valued quantity that strictly decreases
until it bottoms out provably reaches the bottom in finitely many steps. The
well-ordering theorem `nonote_no_infinite_descent` is its engine, and the
self-measured corollary `terminates_of_self_descent` is its most directly
executable face.

## Results Summary (`Geometry/OrdinalAnalysisBridge.lean`, 0 `sorry`)

1. `fastGrowing_zero_eq_succ` — the base function of the hierarchy is `(· + 1)`.
2. `fastGrowing_one_three`, `fastGrowing_two_two` — concrete kernel-checked values
   (`F₁(3) = 6`, `F₂(2) = 8`) witnessing that the hierarchy is genuinely effective.
3. `nonote_no_infinite_descent` — no strictly `<`-decreasing sequence of notations
   below `ε₀` exists (well-ordering of the notation system).
4. `terminates_of_measure` — ordinal-measure termination: an `ε₀`-monovariant
   certifies that a deterministic process halts.
5. `terminates_of_self_descent` — the `μ = id` specialisation: a self-decreasing
   step on `NONote` reaches `0`.

All results depend only on the permitted axioms (`propext`, `Classical.choice`,
`Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler` for the `native_decide`
computations).

---

## Direction 1 — Goodstein sequences as an `ε₀`-monovariant instance

State and prove termination of Goodstein sequences by exhibiting the standard
hereditary-base ordinal assignment `g : ℕ → NONote` and feeding it to
`terminates_of_measure`. The falsifiable claim: the Goodstein step strictly
decreases the assigned `NONote` while the value is nonzero, so every Goodstein
sequence reaches `0`. **The key insight is** that Goodstein termination is not a
new theorem but a *single application* of `terminates_of_measure` once the
hereditary-base map is shown to be a strict monovariant. **Why now?** We already
have the abstract termination engine and a computable target type; the only
missing piece is the explicit, `#eval`-checkable hereditary-base encoding, which is
finite combinatorics rather than ordinal theory.

## Direction 2 — Hydra games and the same engine

Encode Kirby–Paris hydras as finite rooted trees, define the head-chopping step,
and assign each hydra an element of `NONote` so that chopping strictly decreases
it. The falsifiable conjecture: this assignment is a strict monovariant, hence
`terminates_of_self_descent`/`terminates_of_measure` yields that Hercules always
wins. **The key insight is** that the hydra's ordinal rank is literally a `NONote`
descent measure, making the win a corollary rather than a bespoke induction. **Why
now?** The tree-to-`ONote` rank is computable and testable on small hydras with
`#eval`, so the strict-decrease hypothesis can be empirically stress-tested before
the full proof.

## Direction 3 — Closed forms for the low fast-growing levels

Prove `∀ n, ONote.fastGrowing 1 n = 2 * n` and a closed form for level two (the
data suggests `F₂(n) = n · 2ⁿ`). The falsifiable claim is exactly these two
identities, checkable against `native_decide` for many `n` before proving. **The
key insight is** that `fundamentalSequence` of `1` and `ω` has a regular shape that
lets the recursion collapse to elementary arithmetic by induction on `n`. **Why
now?** We have computed enough sample values (`F₁(3)=6`, `F₂(2)=8`) to pin the
conjectured closed forms; the remaining work is a clean induction using
`fastGrowing_succ`.

## Direction 4 — A verified ordinal-bounded `while`-loop combinator

Package `terminates_of_measure` into a dependently typed, executable loop
combinator `whileDescending : (μ : α → NONote) → (step : α → α) → … → α` that runs
`step` until `μ` hits `0`, returning the final state together with a proof of
termination. The falsifiable deliverable: a combinator that both `#eval`s on
concrete inputs and carries a total-correctness certificate. **The key insight is**
that ordinal monovariants give *general recursion for free* — the `NONote`
well-order can serve as the decreasing measure in Lean's `termination_by`. **Why
now?** The termination theorem is in hand; turning it into a reusable, runnable
combinator is engineering that immediately yields verified algorithms across the
catalog (e.g. normalization/rewriting loops).

## Direction 5 — Quantitative descent: step counts vs. fast-growing rate

For a self-descending step on `NONote` with start `a`, conjecture that the number
of steps to reach `0` is bounded below by a fast-growing function of the
"unfolding parameter" when the descent follows fundamental sequences (Hardy-style
descent). The falsifiable claim ties `terminates_of_self_descent`'s existential `n`
to `fastGrowing`/`fastGrowingε₀` lower bounds. **The key insight is** that
fundamental-sequence descent realizes the Hardy hierarchy, so step counts are not
arbitrary but governed by the very hierarchy we already evaluate. **Why now?** With
both the descent engine and the computable hierarchy in the same file, the
correspondence can be probed numerically (compare measured step counts against
`fastGrowing` values) before committing to the analytic bound.

**Concept description**: # Future Directions — Proof-Theoretic Bridge: Ordinal Analysis A

## Synthesis

This cycle opened a constructive bridge between three faces of ordinal analysis,
all stated over Mathlib's *computable* notation system `ONote` / `NONote` (Cantor
normal forms below `ε₀`):

* the **well-ordering** of the notation system (a proof-theoretic invariant),
* the **termination** of any algorithm carrying an `ε₀`-valued monovariant (an
  algorithmic invariant), and
* the **fast-growing hierarchy** `fastGrowing : ONote → ℕ → ℕ`, an effective,
  `native_decide`-evaluable family of number-theoretic functions.

The connective tissue is the single theorem `terminates_of_measure`: a state space
`α` equipped with a step map and an `ε₀`-valued quantity that strictly decreases
until it bottoms out provably reaches the bottom in finitely many steps. The
well-ordering theorem `nonote_no_infinite_descent` is its engine, and the
self-measured corollary `terminates_of_self_descent` is its most directly
executable face.

## Results Summary (`Geometry/OrdinalAnalysisBridge.lean`, 0 `sorry`)

1. `fastGrowing_zero_eq_succ` — the base function of the hierarchy is `(· + 1)`.
2. `fastGrowing_one_three`, `fastGrowing_two_two` — concrete kernel-checked values
   (`F₁(3) = 6`, `F₂(2) = 8`) witnessing that the hierarchy is genuinely effective.
3. `nonote_no_infinite_descent` — no strictly `<`-decreasing sequence of notations
   below `ε₀` exists (well-ordering of the notation system).
4. `terminates_of_measure` — ordinal-measure termination: an `ε₀`-monovariant
   certifies that a deterministic process halts.
5. `terminates_of_self_descent` — the `μ = id` specialisation: a self-decreasing
   step on `NONote` reaches `0`.

All results depend only on the permitted axioms (`propext`, `Classical.choice`,
`Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler` for the `native_decide`
computations).

---

## Direction 1 — Goodstein sequences as an `ε₀`-monovariant instance

State and prove termination of Goodstein sequences by exhibiting the standard
hereditary-base ordinal assignment `g : ℕ → NONote` and feeding it to
`terminates_of_measure`. The falsifiable claim: the Goodstein step strictly
decreases the assigned `NONote` while the value is nonzero, so every Goodstein
sequence reaches `0`. **The key insight is** that Goodstein termination is not a
new theorem but a *single application* of `terminates_of_measure` once the
hereditary-base map is shown to be a strict monovariant. **Why now?** We already
have the abstract termination engine and a computable target type; the only
missing piece is the explicit, `#eval`-checkable hereditary-base encoding, which is
finite combinatorics rather than ordinal theory.

## Direction 2 — Hydra games and the same engine

Encode Kirby–Paris hydras as finite rooted trees, define the head-chopping step,
and assign each hydra an element of `NONote` so that chopping strictly decreases
it. The falsifiable conjecture: this assignment is a strict monovariant, hence
`terminates_of_self_descent`/`terminates_of_measure` yields that Hercules always
wins. **The key insight is** that the hydra's ordinal rank is literally a `NONote`
descent measure, making the win a corollary rather than a bespoke induction. **Why
now?** The tree-to-`ONote` rank is computable and testable on small hydras with
`#eval`, so the strict-decrease hypothesis can be empirically stress-tested before
the full proof.

## Direction 3 — Closed forms for the low fast-growing levels

Prove `∀ n, ONote.fastGrowing 1 n = 2 * n` and a closed form for level two (the
data suggests `F₂(n) = n · 2ⁿ`). The falsifiable claim is exactly these two
identities, checkable against `native_decide` for many `n` before proving. **The
key insight is** that `fundamentalSequence` of `1` and `ω` has a regular shape that
lets the recursion collapse to elementary arithmetic by induction on `n`. **Why
now?** We have computed enough sample values (`F₁(3)=6`, `F₂(2)=8`) to pin the
conjectured closed forms; the remaining work is a clean induction using
`fastGrowing_succ`.

## Direction 4 — A verified ordinal-bounded `while`-loop combinator

Package `terminates_of_measure` into a dependently typed, executable loop
combinator `whileDescending : (μ : α → NONote) → (step : α → α) → … → α` that runs
`step` until `μ` hits `0`, returning the final state together with a proof of
termination. The falsifiable deliverable: a combinator that both `#eval`s on
concrete inputs and carries a total-correctness certificate. **The key insight is**
that ordinal monovariants give *general recursion for free* — the `NONote`
well-order can serve as the decreasing measure in Lean's `termination_by`. **Why
now?** The termination theorem is in hand; turning it into a reusable, runnable
combinator is engineering that immediately yields verified algorithms across the
catalog (e.g. normalization/rewriting loops).

## Direction 5 — Quantitative descent: step counts vs. fast-growing rate

For a self-descending step on `NONote` with start `a`, conjecture that the number
of steps to reach `0` is bounded below by a fast-growing function of the
"unfolding parameter" when the descent follows fundamental sequences (Hardy-style
descent). The falsifiable claim ties `terminates_of_self_descent`'s existential `n`
to `fastGrowing`/`fastGrowingε₀` lower bounds. **The key insight is** that
fundamental-sequence descent realizes the Hardy hierarchy, so step counts are not
arbitrary but governed by the very hierarchy we already evaluate. **Why now?** With
both the descent engine and the computable hierarchy in the same file, the
correspondence can be probed numerically (compare measured step counts against
`fastGrowing` values) before committing to the analytic bound.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Synthetic Catalog Integration Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Synthetic Catalog Integration**. Focus on building a coherent body of work on top of our existing catalog.

### RESEARCH CORE METHODOLOGY:
1. **Lineage Synthesis**: Analyze the existing catalog context deeply. Do not reinvent definitions; import and build directly on top of the validated catalog results.
2. **Connect the Dots**: Search for "orphan" results or gaps in the catalog and construct bridges to connect them. Show how new theorems advance the overall mathematical architecture of the repository.
3. **Foundational Extension**: Take successful packages from the catalog and extend their results to broader algebraic settings, sharper bounds, or new domain applications.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
