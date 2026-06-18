
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

**Title**: Order-theoretic core of the Cook–Reckhow program (built
**Domain**: Novelty
**Mathematical framing**: # Future Directions: The Poset of p-Degrees and Parametric Separation

## Synthesis

This cycle extended the order-theoretic core of the Cook–Reckhow program (built in
`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`) from a *preorder existence* result
into a *structural and concrete* theory of the simulation order. The new file
`Catalog/Logic/ProofComplexity/SimulationDegrees.lean` elaborates cleanly with `sorry = 0`
and only the standard axioms `propext, Classical.choice, Quot.sound`.

Three conceptual moves were made.

1. **Separation became parametric.** The previous cycle's separation theorem
   `no_simulation_of_fib_hard` was bound to `Nat.fib`. We isolated the *only* arithmetic
   fact it used — that a function pointwise below a polynomially bounded one is itself
   polynomially bounded (`polyBounded_of_le`) — and rebuilt the separation as
   `no_simulation_of_hard`, parametric in an arbitrary non-polynomial hardness function `s`.
   The Fibonacci statement is now recovered as the single instance `s = Nat.fib`
   (`no_simulation_of_fib_hard_via_template`), confirming the catalog's Fibonacci lower
   bound was never special — *any* super-polynomial growth rate separates.

2. **The separation became concrete.** We constructed two honest proof systems over
   `Thm = ℕ` — the linear-size `linSystem` and the Fibonacci-size `fibSystem` — and proved
   `exists_separated_pair : ∃ P Q, ¬ Simulates P Q`. This shows the simulation preorder is
   genuinely non-trivial: the abstract structure is not vacuously a single point.

3. **The preorder antisymmetrized to a genuine poset.** We identified `PEquiv` with
   Mathlib's `AntisymmRel (· ≤ ·)` (`pEquiv_iff_antisymmRel`, definitional), so the canonical
   poset of *p-degrees* is `Antisymmetrization (ProofSystem Thm) (· ≤ ·)` with its library
   `PartialOrder`. The concrete separation lifted to `exists_two_distinct_pdegrees`, proving
   the poset of p-degrees has at least two points.

## Results Summary

| Theorem | Statement |
|---|---|
| `polyBounded_of_le` | A function below a polynomially-bounded one is polynomially bounded |
| `no_simulation_of_hard` | Generic separation: any non-polynomial hardness lower bound separates `P` from `Q` |
| `no_simulation_of_fib_hard_via_template` | Fibonacci separation recovered as the `s = Nat.fib` instance |
| `exists_separated_pair` | The linear system is not p-simulated by the Fibonacci system |
| `pEquiv_iff_antisymmRel` | p-equivalence is exactly antisymmetry of the simulation preorder |
| `exists_two_distinct_pdegrees` | The poset of p-degrees has ≥ 2 elements |

---

## Direction 1 — A strict chain of p-degrees of unbounded length

We exhibited two distinct p-degrees; the next falsifiable claim is that the poset of
p-degrees contains an **infinite strict chain** `d_0 < d_1 < d_2 < ...`. The key insight is
that the concrete construction generalizes: for any strictly increasing sequence of
growth rates `g_0 ≺ g_1 ≺ ...` that are pairwise non-dominating in the polynomial sense, the
systems `sizeSystem g_i` (proofs are theorems, size of the proof of `n` is `g_i n`) should
satisfy `Simulates (sizeSystem g_j) (sizeSystem g_i)` iff `g_i` is polynomially bounded by
`g_j` — turning a growth hierarchy directly into a chain in the p-degree poset. Why now? The
`linSystem`/`fibSystem` pair is already the `g_0 = id`, `g_1 = fib` case, and `polyBounded_of_le`
plus `polyBounded_comp` give exactly the simulation/non-simulation dichotomy needed to order
the chain; only a clean "intermediate growth rate" family (e.g. iterated logarithms of `fib`)
remains to be supplied.

## Direction 2 — The p-degree poset is not a lattice

The conjecture is that `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)` is **not** a lattice: there
exist two incomparable p-degrees with two distinct minimal upper bounds. The key insight is
that incomparability is now manufacturable — two systems whose hardness functions dominate
each other on disjoint index sets (e.g. `fib` on evens, identity on odds, versus the swap)
are mutually non-simulating by two applications of `no_simulation_of_hard`, yet both are
p-simulated by the "max" system, and the join can be split. Why now? `no_simulation_of_hard`
is parametric in the hardness function and in the theorem family `t`, so building systems
that are hard on *complementary* index sets is a direct instantiation, and Mathlib's
`Lattice`/`SemilatticeSup` predicates make the refutation a finite case analysis on four
explicit degrees.

## Direction 3 — A `GrowthClass` abstraction making the order parametric in the blow-up class

We proved everything for the polynomial class `PolyBounded`, but `no_simulation_of_hard` and
the preorder laws used only two properties: closure under composition and a witness *outside*
the class. The conjecture is that abstracting to a `class GrowthClass (C : (ℕ → ℕ) → Prop)`
with fields `mem_id`, `comp_closed`, and `mem_mono` yields a `Preorder` `Simulates_C` for
*every* such class, with the separation `Nat.fib`-bridge surviving precisely when
`¬ C Nat.fib`. The key insight is that the entire development of both files is *generic over
the growth class* — `PolyBounded` is one model, and quasi-polynomial `2^{(log n)^c}` or
sub-exponential classes are others. Why now? The two load-bearing lemmas (`polyBounded_comp`,
`polyBounded_of_le`) are already isolated as standalone statements, so lifting them to fields
of a typeclass is mechanical, and it would let the next cycle probe *where in the growth
hierarchy* Fibonacci-style separations first appear without reproving any order structure.

## Direction 4 — p-optimality and the top of the poset

A proof system is *p-optimal* if it p-simulates every other system over the same theorems —
i.e. it is a greatest element of the simulation preorder. The falsifiable conjecture for the
abstract setting: over `Thm = ℕ` with the size functions ranging over **all** of `ℕ → ℕ`,
there is **no** p-optimal system, because for any candidate `P` with size function `g` one
can build `sizeSystem (fun n => g n + fib n)`, whose proofs `P` cannot p-simulate. The key
insight is that p-optimality is a `IsTop` statement in the `Preorder`, and its negation
reduces, via `no_simulation_of_hard`, to "the candidate's growth rate can always be exceeded
super-polynomially" — a diagonalization that `not_polyBounded_fib` already powers. Why now?
The concrete `sizeSystem` construction and the parametric separation template together make
the diagonal system definable and the non-simulation immediate; only the `IsTop` negation
plumbing remains.

## Direction 5 — Bridging back to number theory: entry-point growth as a separation source

The catalog's Fibonacci/entry-point theory (`Shared.CarmichaelProof`,
`Speculative.AutoResearch.CarmichaelHelper`) supplies sequences whose growth is controlled by
arithmetic invariants. The conjecture is that the *entry-point function* `α(n)` (rank of
apparition) and the primitive-part sequence `Ψ_n` are themselves non-polynomial, hence each
induces its own separation in the p-degree poset via `no_simulation_of_hard`. The key insight
is that primitive divisors force `Ψ_n > 1` for all large `n` (Carmichael), and the product
formula makes `Ψ_n` grow like `fib n` up to a bounded arithmetic correction — so the
arithmetic of Fibonacci primitive divisors yields a *second, independent* super-polynomial
hardness function distinct from `fib` itself. Why now? `no_simulation_of_hard` only needs
`¬ PolyBounded s`, and the growth lemma `two_pow_le_fib` from the previous cycle, combined with
the entry-point divisibility infrastructure already in the catalog, reduces the claim to a
clean lower bound `Ψ_n ≥ fib n / α(n)` — a self-contained arithmetic inequality.

**Concept description**: # Future Directions: The Poset of p-Degrees and Parametric Separation

## Synthesis

This cycle extended the order-theoretic core of the Cook–Reckhow program (built in
`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`) from a *preorder existence* result
into a *structural and concrete* theory of the simulation order. The new file
`Catalog/Logic/ProofComplexity/SimulationDegrees.lean` elaborates cleanly with `sorry = 0`
and only the standard axioms `propext, Classical.choice, Quot.sound`.

Three conceptual moves were made.

1. **Separation became parametric.** The previous cycle's separation theorem
   `no_simulation_of_fib_hard` was bound to `Nat.fib`. We isolated the *only* arithmetic
   fact it used — that a function pointwise below a polynomially bounded one is itself
   polynomially bounded (`polyBounded_of_le`) — and rebuilt the separation as
   `no_simulation_of_hard`, parametric in an arbitrary non-polynomial hardness function `s`.
   The Fibonacci statement is now recovered as the single instance `s = Nat.fib`
   (`no_simulation_of_fib_hard_via_template`), confirming the catalog's Fibonacci lower
   bound was never special — *any* super-polynomial growth rate separates.

2. **The separation became concrete.** We constructed two honest proof systems over
   `Thm = ℕ` — the linear-size `linSystem` and the Fibonacci-size `fibSystem` — and proved
   `exists_separated_pair : ∃ P Q, ¬ Simulates P Q`. This shows the simulation preorder is
   genuinely non-trivial: the abstract structure is not vacuously a single point.

3. **The preorder antisymmetrized to a genuine poset.** We identified `PEquiv` with
   Mathlib's `AntisymmRel (· ≤ ·)` (`pEquiv_iff_antisymmRel`, definitional), so the canonical
   poset of *p-degrees* is `Antisymmetrization (ProofSystem Thm) (· ≤ ·)` with its library
   `PartialOrder`. The concrete separation lifted to `exists_two_distinct_pdegrees`, proving
   the poset of p-degrees has at least two points.

## Results Summary

| Theorem | Statement |
|---|---|
| `polyBounded_of_le` | A function below a polynomially-bounded one is polynomially bounded |
| `no_simulation_of_hard` | Generic separation: any non-polynomial hardness lower bound separates `P` from `Q` |
| `no_simulation_of_fib_hard_via_template` | Fibonacci separation recovered as the `s = Nat.fib` instance |
| `exists_separated_pair` | The linear system is not p-simulated by the Fibonacci system |
| `pEquiv_iff_antisymmRel` | p-equivalence is exactly antisymmetry of the simulation preorder |
| `exists_two_distinct_pdegrees` | The poset of p-degrees has ≥ 2 elements |

---

## Direction 1 — A strict chain of p-degrees of unbounded length

We exhibited two distinct p-degrees; the next falsifiable claim is that the poset of
p-degrees contains an **infinite strict chain** `d_0 < d_1 < d_2 < ...`. The key insight is
that the concrete construction generalizes: for any strictly increasing sequence of
growth rates `g_0 ≺ g_1 ≺ ...` that are pairwise non-dominating in the polynomial sense, the
systems `sizeSystem g_i` (proofs are theorems, size of the proof of `n` is `g_i n`) should
satisfy `Simulates (sizeSystem g_j) (sizeSystem g_i)` iff `g_i` is polynomially bounded by
`g_j` — turning a growth hierarchy directly into a chain in the p-degree poset. Why now? The
`linSystem`/`fibSystem` pair is already the `g_0 = id`, `g_1 = fib` case, and `polyBounded_of_le`
plus `polyBounded_comp` give exactly the simulation/non-simulation dichotomy needed to order
the chain; only a clean "intermediate growth rate" family (e.g. iterated logarithms of `fib`)
remains to be supplied.

## Direction 2 — The p-degree poset is not a lattice

The conjecture is that `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)` is **not** a lattice: there
exist two incomparable p-degrees with two distinct minimal upper bounds. The key insight is
that incomparability is now manufacturable — two systems whose hardness functions dominate
each other on disjoint index sets (e.g. `fib` on evens, identity on odds, versus the swap)
are mutually non-simulating by two applications of `no_simulation_of_hard`, yet both are
p-simulated by the "max" system, and the join can be split. Why now? `no_simulation_of_hard`
is parametric in the hardness function and in the theorem family `t`, so building systems
that are hard on *complementary* index sets is a direct instantiation, and Mathlib's
`Lattice`/`SemilatticeSup` predicates make the refutation a finite case analysis on four
explicit degrees.

## Direction 3 — A `GrowthClass` abstraction making the order parametric in the blow-up class

We proved everything for the polynomial class `PolyBounded`, but `no_simulation_of_hard` and
the preorder laws used only two properties: closure under composition and a witness *outside*
the class. The conjecture is that abstracting to a `class GrowthClass (C : (ℕ → ℕ) → Prop)`
with fields `mem_id`, `comp_closed`, and `mem_mono` yields a `Preorder` `Simulates_C` for
*every* such class, with the separation `Nat.fib`-bridge surviving precisely when
`¬ C Nat.fib`. The key insight is that the entire development of both files is *generic over
the growth class* — `PolyBounded` is one model, and quasi-polynomial `2^{(log n)^c}` or
sub-exponential classes are others. Why now? The two load-bearing lemmas (`polyBounded_comp`,
`polyBounded_of_le`) are already isolated as standalone statements, so lifting them to fields
of a typeclass is mechanical, and it would let the next cycle probe *where in the growth
hierarchy* Fibonacci-style separations first appear without reproving any order structure.

## Direction 4 — p-optimality and the top of the poset

A proof system is *p-optimal* if it p-simulates every other system over the same theorems —
i.e. it is a greatest element of the simulation preorder. The falsifiable conjecture for the
abstract setting: over `Thm = ℕ` with the size functions ranging over **all** of `ℕ → ℕ`,
there is **no** p-optimal system, because for any candidate `P` with size function `g` one
can build `sizeSystem (fun n => g n + fib n)`, whose proofs `P` cannot p-simulate. The key
insight is that p-optimality is a `IsTop` statement in the `Preorder`, and its negation
reduces, via `no_simulation_of_hard`, to "the candidate's growth rate can always be exceeded
super-polynomially" — a diagonalization that `not_polyBounded_fib` already powers. Why now?
The concrete `sizeSystem` construction and the parametric separation template together make
the diagonal system definable and the non-simulation immediate; only the `IsTop` negation
plumbing remains.

## Direction 5 — Bridging back to number theory: entry-point growth as a separation source

The catalog's Fibonacci/entry-point theory (`Shared.CarmichaelProof`,
`Speculative.AutoResearch.CarmichaelHelper`) supplies sequences whose growth is controlled by
arithmetic invariants. The conjecture is that the *entry-point function* `α(n)` (rank of
apparition) and the primitive-part sequence `Ψ_n` are themselves non-polynomial, hence each
induces its own separation in the p-degree poset via `no_simulation_of_hard`. The key insight
is that primitive divisors force `Ψ_n > 1` for all large `n` (Carmichael), and the product
formula makes `Ψ_n` grow like `fib n` up to a bounded arithmetic correction — so the
arithmetic of Fibonacci primitive divisors yields a *second, independent* super-polynomial
hardness function distinct from `fib` itself. Why now? `no_simulation_of_hard` only needs
`¬ PolyBounded s`, and the growth lemma `two_pow_le_fib` from the previous cycle, combined with
the entry-point divisibility infrastructure already in the catalog, reduces the claim to a
clean lower bound `Ψ_n ≥ fib n / α(n)` — a self-contained arithmetic inequality.

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
