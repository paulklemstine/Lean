
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

**Title**: The file `TropicalValuationLimitBridge.lean` formalizes the *easy half* of the F
**Domain**: Bridges
**Mathematical framing**: # Future Directions: The Valuation–Tropicalization Bridge

The file `TropicalValuationLimitBridge.lean` formalizes the *easy half* of the Fundamental
Theorem of Tropical Geometry: tropicalizing a point of a classical hypersurface always lands on
the corner locus (`kapranov_easy_direction`), powered by the ultrametric winner-takes-all lemma
(`addValuation_sum_eq_of_unique_min`), and it isolates the min-plus multiplicativity
(`TropPoly.eval_mul`) that makes tropical degrees add. Below are the next conjectures this work
opens up. Each is stated so that it can be falsified by a single counterexample or settled by a
single Lean proof.

## Direction 1 — Kapranov's hard direction (surjectivity onto the corner locus)

Conjecture: if `K` is algebraically closed with a non-trivial valuation `v` whose value group is
divisible (so `v` is surjective onto `Γ`), then for every weight vector `w` lying on the corner
locus of a tropical polynomial `trop(f)` there exists a point `p` with `f(p) = 0` and
`v(p) = w`. This is the converse of `kapranov_easy_direction`, currently recorded as the open
target `kapranov_hard_direction_sketch`.

The key insight is that the easy direction is *purely a consequence of the ultrametric
inequality being an equality away from ties*, whereas the hard direction needs a genuine
*lifting* step: a Newton-polygon / Hensel argument that promotes a "leading-term cancellation"
(two monomials tied for the minimum) into an actual root. Formalizing the univariate case first
(`Fin 1` many variables, where the Newton polygon is literally the lower convex hull of
`{(i, v(cᵢ))}`) reduces the whole theorem to Hensel's lemma plus convexity.

Why now? Mathlib already has `Polynomial.Monic`, Hensel's lemma for complete local rings, and
the `AddValuation` API used here; the missing glue is a Newton-polygon predicate, which is a
finite-combinatorial object identical in spirit to the `inf'_product_add` lemma already proven.

## Direction 2 — The valuation-going-to-infinity limit is genuinely a limit

Conjecture: for the rescaled family `v_t := t • v` (`t : ℝ≥0`, `t → ∞`), the corner locus of
`trop_{v_t}(f)` converges, in the Hausdorff metric on compact windows, to the corner locus of
`trop_v(f)` *scaled by t*; equivalently the normalized amoeba `(1/t)·Log_t(V(f))` converges to
the tropical variety. This makes precise the slogan "tropicalization is the `t → ∞` limit".

The key insight is that `t • v` is *again* an `AddValuation` (scaling preserves the two
valuation axioms), so the entire corner-locus characterization is invariant under `t`-rescaling
up to a homothety — meaning the "limit" is not an analytic limit of moving sets but the fixed
shape that all members of the family already share after normalization.

Why now? The corner-locus predicate `AttainedAtLeastTwice` is scale-equivariant on the nose
(`AttainedAtLeastTwice (t • w) ↔ AttainedAtLeastTwice w` for `t > 0`), a one-line lemma to add,
turning a hard analytic statement into an algebraic invariance that Lean can check directly.

## Direction 3 — Stable intersection and tropical Bézout from `eval_mul`

Conjecture: define the tropical hypersurface `V(P) := {x | AttainedAtLeastTwice (P.termVal x)}`.
Then `V(P.mul Q) = V(P) ∪ V(Q)` exactly, and for plane curves (`n = 2`) the number of stable
intersection points of `V(P)` and `V(Q)`, counted with lattice multiplicity, equals
`deg P · deg Q`.

The key insight is that `TropPoly.eval_mul` already proves `eval (P ⊙ Q) = eval P + eval Q`
*as functions*; a corner of a sum of two convex-piecewise-linear functions occurs exactly where
at least one summand has a corner, so the union law for hypersurfaces is the pointwise shadow of
the additivity of evaluations — no new geometry is needed, only a corner-of-a-sum lemma.

Why now? The catalog already contains `Tropical/Bezout.lean` proving `mixedLatticeIndex` of two
degree simplices equals `d₁·d₂`; combining that lattice count with the union law here would give
the *first end-to-end* tropical Bézout theorem in the catalog that connects the analytic
(min-plus evaluation) and combinatorial (Newton polytope) descriptions.

## Direction 4 — Balancing condition as a conservation law

Conjecture: at every corner point `x` of `V(P)`, the primitive edge directions of the tropical
curve, weighted by lattice length, sum to zero (the *balancing condition*). Moreover this is
equivalent to `∑ᵢ Tᵢ = 0` lifting consistently, i.e. balancing is the tropical shadow of
"a regular function has no poles".

The key insight is that balancing is exactly the statement that the set of monomials achieving
the minimum at `x` (the "tie set" produced by `kapranov_easy_direction`) forms the vertex set of
a polytope whose outward normal fan is complete — so the same tie set that proves membership in
the corner locus *also* carries the balancing data, for free.

Why now? `kapranov_easy_direction` already extracts the tie set (two indices realizing the min);
generalizing its conclusion from "≥ 2 minimizers" to "the minimizer set spans a balanced fan"
is the natural strengthening, and Mathlib's `Finset` convex-geometry API is now rich enough to
state primitive lattice vectors.

## Direction 5 — Tropical semiring morphism packaging of the valuation

Conjecture: the map `x ↦ v x` is a semiring homomorphism `K → Tropical (WithTop Γ)ᵒᵈ` *up to the
single defect on addition*, and the defect locus (where `v(x+y) ≠ min(v x, v y)`) is precisely
the diagonal-tie set `{v x = v y}`. Packaging this as a bundled `TropicalHom` would let every
classical algebraic identity be transported to a tropical inequality automatically.

The key insight is that the only obstruction to `v` being an honest tropical-semiring morphism is
the failure of additivity *exactly when two valuations coincide* — which is the same tie
phenomenon driving the corner locus. So "morphism defect = corner locus" unifies the additive
and multiplicative stories into one statement.

Why now? Mathlib's `Tropical R` type and `Semiring (Tropical R)` instance (from
`Mathlib.Algebra.Tropical.Basic`) are already imported transitively here; the bundling is a
definitional wrapper, after which `AddValuation.map_add` becomes a tropical-additivity inequality
and `map_mul` becomes tropical-multiplicativity on the nose.

**Concept description**: # Future Directions: The Valuation–Tropicalization Bridge

The file `TropicalValuationLimitBridge.lean` formalizes the *easy half* of the Fundamental
Theorem of Tropical Geometry: tropicalizing a point of a classical hypersurface always lands on
the corner locus (`kapranov_easy_direction`), powered by the ultrametric winner-takes-all lemma
(`addValuation_sum_eq_of_unique_min`), and it isolates the min-plus multiplicativity
(`TropPoly.eval_mul`) that makes tropical degrees add. Below are the next conjectures this work
opens up. Each is stated so that it can be falsified by a single counterexample or settled by a
single Lean proof.

## Direction 1 — Kapranov's hard direction (surjectivity onto the corner locus)

Conjecture: if `K` is algebraically closed with a non-trivial valuation `v` whose value group is
divisible (so `v` is surjective onto `Γ`), then for every weight vector `w` lying on the corner
locus of a tropical polynomial `trop(f)` there exists a point `p` with `f(p) = 0` and
`v(p) = w`. This is the converse of `kapranov_easy_direction`, currently recorded as the open
target `kapranov_hard_direction_sketch`.

The key insight is that the easy direction is *purely a consequence of the ultrametric
inequality being an equality away from ties*, whereas the hard direction needs a genuine
*lifting* step: a Newton-polygon / Hensel argument that promotes a "leading-term cancellation"
(two monomials tied for the minimum) into an actual root. Formalizing the univariate case first
(`Fin 1` many variables, where the Newton polygon is literally the lower convex hull of
`{(i, v(cᵢ))}`) reduces the whole theorem to Hensel's lemma plus convexity.

Why now? Mathlib already has `Polynomial.Monic`, Hensel's lemma for complete local rings, and
the `AddValuation` API used here; the missing glue is a Newton-polygon predicate, which is a
finite-combinatorial object identical in spirit to the `inf'_product_add` lemma already proven.

## Direction 2 — The valuation-going-to-infinity limit is genuinely a limit

Conjecture: for the rescaled family `v_t := t • v` (`t : ℝ≥0`, `t → ∞`), the corner locus of
`trop_{v_t}(f)` converges, in the Hausdorff metric on compact windows, to the corner locus of
`trop_v(f)` *scaled by t*; equivalently the normalized amoeba `(1/t)·Log_t(V(f))` converges to
the tropical variety. This makes precise the slogan "tropicalization is the `t → ∞` limit".

The key insight is that `t • v` is *again* an `AddValuation` (scaling preserves the two
valuation axioms), so the entire corner-locus characterization is invariant under `t`-rescaling
up to a homothety — meaning the "limit" is not an analytic limit of moving sets but the fixed
shape that all members of the family already share after normalization.

Why now? The corner-locus predicate `AttainedAtLeastTwice` is scale-equivariant on the nose
(`AttainedAtLeastTwice (t • w) ↔ AttainedAtLeastTwice w` for `t > 0`), a one-line lemma to add,
turning a hard analytic statement into an algebraic invariance that Lean can check directly.

## Direction 3 — Stable intersection and tropical Bézout from `eval_mul`

Conjecture: define the tropical hypersurface `V(P) := {x | AttainedAtLeastTwice (P.termVal x)}`.
Then `V(P.mul Q) = V(P) ∪ V(Q)` exactly, and for plane curves (`n = 2`) the number of stable
intersection points of `V(P)` and `V(Q)`, counted with lattice multiplicity, equals
`deg P · deg Q`.

The key insight is that `TropPoly.eval_mul` already proves `eval (P ⊙ Q) = eval P + eval Q`
*as functions*; a corner of a sum of two convex-piecewise-linear functions occurs exactly where
at least one summand has a corner, so the union law for hypersurfaces is the pointwise shadow of
the additivity of evaluations — no new geometry is needed, only a corner-of-a-sum lemma.

Why now? The catalog already contains `Tropical/Bezout.lean` proving `mixedLatticeIndex` of two
degree simplices equals `d₁·d₂`; combining that lattice count with the union law here would give
the *first end-to-end* tropical Bézout theorem in the catalog that connects the analytic
(min-plus evaluation) and combinatorial (Newton polytope) descriptions.

## Direction 4 — Balancing condition as a conservation law

Conjecture: at every corner point `x` of `V(P)`, the primitive edge directions of the tropical
curve, weighted by lattice length, sum to zero (the *balancing condition*). Moreover this is
equivalent to `∑ᵢ Tᵢ = 0` lifting consistently, i.e. balancing is the tropical shadow of
"a regular function has no poles".

The key insight is that balancing is exactly the statement that the set of monomials achieving
the minimum at `x` (the "tie set" produced by `kapranov_easy_direction`) forms the vertex set of
a polytope whose outward normal fan is complete — so the same tie set that proves membership in
the corner locus *also* carries the balancing data, for free.

Why now? `kapranov_easy_direction` already extracts the tie set (two indices realizing the min);
generalizing its conclusion from "≥ 2 minimizers" to "the minimizer set spans a balanced fan"
is the natural strengthening, and Mathlib's `Finset` convex-geometry API is now rich enough to
state primitive lattice vectors.

## Direction 5 — Tropical semiring morphism packaging of the valuation

Conjecture: the map `x ↦ v x` is a semiring homomorphism `K → Tropical (WithTop Γ)ᵒᵈ` *up to the
single defect on addition*, and the defect locus (where `v(x+y) ≠ min(v x, v y)`) is precisely
the diagonal-tie set `{v x = v y}`. Packaging this as a bundled `TropicalHom` would let every
classical algebraic identity be transported to a tropical inequality automatically.

The key insight is that the only obstruction to `v` being an honest tropical-semiring morphism is
the failure of additivity *exactly when two valuations coincide* — which is the same tie
phenomenon driving the corner locus. So "morphism defect = corner locus" unifies the additive
and multiplicative stories into one statement.

Why now? Mathlib's `Tropical R` type and `Semiring (Tropical R)` instance (from
`Mathlib.Algebra.Tropical.Basic`) are already imported transitively here; the bundling is a
definitional wrapper, after which `AddValuation.map_add` becomes a tropical-additivity inequality
and `map_mul` becomes tropical-multiplicativity on the nose.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Bridges
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
