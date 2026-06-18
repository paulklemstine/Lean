
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

**Title**: Catalog's topological theory of protein folding
**Domain**: Applications
**Mathematical framing**: # FUTURE_DIRECTIONS — Persistent-Homology Folding (Extended)

## Synthesis

This cycle extended the catalog's topological theory of protein folding
(`Speculative/AutoResearch/ProteinFolding.lean`, the `ProteinTopology` namespace) along four
axes, collected in `Speculative/AutoResearch/PersistentHomologyFoldingExt.lean` (namespace
`FoldingHomology`). The catalog had established the *elder rule on a chain*
(`H0_totalPersistence_eq_extent`: degree-0 total persistence = end-to-end extent) and the
existence/uniqueness of a "native fold" as the argmin of topological energy. The structural
question we pressed on was: **how rigid is the energy functional, and how much does it actually
determine the fold?**

The recurring discovery is that the degree-0 ("`H₀`") total persistence is an extraordinarily
*coarse* invariant. Because it telescopes to `xₙ − x₀`, it is (i) additive over disjoint
features and sub-chains (`totalPersistence_add`, `H0_totalPersistence_concat`), (ii) monotone
under feature inclusion (`totalPersistence_mono`), (iii) degree-1 homogeneous under rescaling
(`H0_totalPersistence_smul`), and — most importantly — (iv) a function of the *endpoints alone*
(`H0_energy_depends_only_on_endpoints`). Point (iv) is a genuine *negative* result: it lets us
construct two manifestly different monotone folds with identical `H₀` energy
(`native_fold_nonunique`), pinning the exact boundary of the catalog's `native_fold_unique`
theorem. The injectivity/energy-separation hypothesis there is not cosmetic — it is unavoidable,
because `H₀` cannot distinguish folds that share endpoints. The structural insight that ties the
cycle together: **to resolve Levinthal-type uniqueness you must look beyond `H₀`** to higher
persistent homology (loops `H₁`, voids `H₂`), which is exactly where the next cycle should go.

A secondary thread was a cross-domain bridge: evaluating the persistent-homology energy on the
Fibonacci sequence (atoms placed at `Fₖ`) returns exactly `Fₙ` (`H0_totalPersistence_fib`),
connecting the topology layer to the catalog's Fibonacci number theory
(`Shared/Fib_gcd_identity`, `Speculative/AutoResearch/FibPrimitive`). This is a template:
any monotone integer sequence becomes a "fold" whose topological energy is its terminal value.

## Results Summary

- `totalPersistence_mono`: proved — topological energy is monotone under multiset (feature) inclusion; the order-theoretic companion of additivity.
- `monotone_const_smul`: proved — nonnegative rescaling preserves monotonicity of a chain (supporting lemma for the scaling law).
- `H0_totalPersistence_smul`: proved — folding energy is degree-1 homogeneous: rescaling coordinates by `c ≥ 0` scales energy by `c`; the contact map has no intrinsic length scale.
- `H0_totalPersistence_concat`: proved — energy is additive across an interior split point (domain decomposition of the folding free energy).
- `H0_energy_depends_only_on_endpoints`: proved — degree-0 energy is a function of `(x 0, x n)` only; the structural root of Levinthal degeneracy.
- `chainA_monotone`, `chainB_monotone`: proved — two concrete monotone folds with shared endpoints (supporting the counterexample).
- `native_fold_nonunique`: proved (counterexample) — two distinct monotone folds with equal endpoints share `H₀` energy, so `native_fold_unique`'s injectivity hypothesis is not removable.
- `fibChain_monotone`: proved — the Fibonacci position sequence is monotone (supporting the bridge).
- `H0_totalPersistence_fib`: proved — the `H₀` energy of the Fibonacci fold equals `Fₙ`; a topology↔number-theory bridge.

## Research Directions

### Direction 1: Higher persistent homology breaks the endpoint degeneracy
**Hypothesis**: There is a `H₁`-flavored persistence functional `E₁` on planar (or 3D) Cα
configurations such that two folds with equal endpoints and equal `H₀` energy but different loop
structure satisfy `E₁(fold₁) ≠ E₁(fold₂)`; i.e. `(E₀, E₁)` jointly separate the `native_fold_nonunique`
counterexample.
**Test**: Formalize a minimal `H₁` barcode for a cyclic contact graph (e.g. the number/length of
independent cycles in the Vietoris–Rips complex at a fixed scale) and prove it distinguishes
`chainA` lifted to a loop vs. an unknotted variant.
**Why now**: `native_fold_nonunique` gives an explicit, fully-formal pair of indistinguishable
folds — a ready-made test fixture for any candidate higher invariant.
**If true**: Uniqueness of the native fold can be recovered from a *finite* tuple of persistence
energies, a quantitative refinement of `native_fold_unique`.
**If false**: It would suggest topological energy alone (any degree) cannot pin a fold, pushing
the theory toward geometric (metric, not just topological) functionals.

### Direction 2: General finite-metric elder rule = minimum spanning tree weight
**Hypothesis**: For any finite metric configuration, the degree-0 total persistence of its
Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the complete
weighted graph; the chain result `H0_totalPersistence_eq_extent` is the special case where the MST
is the path through consecutive atoms.
**Test**: Define an MST-weight functional in Lean and prove equality with `totalPersistence` of the
`H₀` barcode for `Fintype` point sets; verify on a 3- and 4-point example by `decide`/explicit computation.
**Why now**: The chain case is fully proved and the additivity/monotonicity algebra
(`totalPersistence_add`, `totalPersistence_mono`) is exactly the toolkit needed to induct on edges.
**If true**: Promotes the entire folding-energy theory from linear chains to arbitrary 3D
configurations — the realistic setting.
**If false**: The discrepancy would localize precisely which non-tree cycles contribute, informing
the `H₁` theory of Direction 1.

### Direction 3: Stability as a Lipschitz bound in the sup-metric
**Hypothesis**: `|E(x) − E(y)| ≤ 2 · sup_k |x k − y k|` for all monotone chains (a global,
all-coordinates strengthening of the catalog's two-endpoint `H0_totalPersistence_stable`).
**Test**: Prove it from `H0_energy_depends_only_on_endpoints` + the triangle inequality, then probe
whether the constant `2` is tight and whether it survives the MST generalization of Direction 2.
**Why now**: `H0_energy_depends_only_on_endpoints` reduces the whole functional to two coordinates,
making the sup-bound a short corollary while exposing the tightness question.
**If true**: Gives bottleneck stability of the folding energy landscape under thermal noise in a
clean operator-norm form.
**If false**: The failing configuration is a counterexample worth cataloguing — it would mean MST
rewiring under perturbation amplifies error beyond the endpoint bound.

### Direction 4: Integer-sequence folds as a topology↔number-theory dictionary
**Hypothesis**: For every monotone `a : ℕ → ℕ`, the fold at positions `aₖ` has `H₀` energy `aₙ − a₀`;
specializing to multiplicative/recursive sequences yields identities (e.g. for `aₖ = ∑_{j≤k} φ(j)`,
the energy is the totient summatory function), turning persistence identities into number-theoretic ones.
**Test**: Generalize `H0_totalPersistence_fib` to an arbitrary monotone `ℕ→ℕ` sequence, then derive
the totient-summatory and partial-sum-of-divisors instances as corollaries.
**Why now**: `H0_totalPersistence_fib` is the first worked instance; the proof is sequence-agnostic
(`H0_totalPersistence_eq_extent` + `a₀` value), so generalization is immediate.
**If true**: Provides a uniform bridge letting catalog number-theory results
(`Fib_gcd_identity`, `FibPrimitive`) be re-read as statements about persistent-homology energies.
**If false (i.e. some sequence breaks monotonicity casting)**: It pinpoints exactly which arithmetic
functions fail to embed as folds, a constraint on the dictionary.

### Direction 5: Two-sided functoriality and the persistence module structure
**Hypothesis**: The map `t ↦ Rips d t` together with the inclusion maps assembles into a genuine
persistence module over `ℝ`, and `totalPersistence` factors through its barcode decomposition
functorially (interleaving distance ≤ ε ⇒ energies differ by ≤ C·ε).
**Test**: Define the inclusion morphisms `Rips d s → Rips d t` (already supported by the catalog's
`Rips_mono`) and prove a categorical interleaving-stability statement for the chain model.
**Why now**: `Rips_mono` (catalog) plus this cycle's `totalPersistence_mono` give both halves of the
functoriality square; only the morphism bookkeeping remains.
**If true**: Connects the folding model to the standard persistence-module machinery, opening the
door to importing bottleneck/interleaving stability in full generality.
**If false**: The obstruction would reveal where the finite-chain model departs from the continuous
persistence-module theory — itself a publishable boundary.

**Concept description**: # FUTURE_DIRECTIONS — Persistent-Homology Folding (Extended)

## Synthesis

This cycle extended the catalog's topological theory of protein folding
(`Speculative/AutoResearch/ProteinFolding.lean`, the `ProteinTopology` namespace) along four
axes, collected in `Speculative/AutoResearch/PersistentHomologyFoldingExt.lean` (namespace
`FoldingHomology`). The catalog had established the *elder rule on a chain*
(`H0_totalPersistence_eq_extent`: degree-0 total persistence = end-to-end extent) and the
existence/uniqueness of a "native fold" as the argmin of topological energy. The structural
question we pressed on was: **how rigid is the energy functional, and how much does it actually
determine the fold?**

The recurring discovery is that the degree-0 ("`H₀`") total persistence is an extraordinarily
*coarse* invariant. Because it telescopes to `xₙ − x₀`, it is (i) additive over disjoint
features and sub-chains (`totalPersistence_add`, `H0_totalPersistence_concat`), (ii) monotone
under feature inclusion (`totalPersistence_mono`), (iii) degree-1 homogeneous under rescaling
(`H0_totalPersistence_smul`), and — most importantly — (iv) a function of the *endpoints alone*
(`H0_energy_depends_only_on_endpoints`). Point (iv) is a genuine *negative* result: it lets us
construct two manifestly different monotone folds with identical `H₀` energy
(`native_fold_nonunique`), pinning the exact boundary of the catalog's `native_fold_unique`
theorem. The injectivity/energy-separation hypothesis there is not cosmetic — it is unavoidable,
because `H₀` cannot distinguish folds that share endpoints. The structural insight that ties the
cycle together: **to resolve Levinthal-type uniqueness you must look beyond `H₀`** to higher
persistent homology (loops `H₁`, voids `H₂`), which is exactly where the next cycle should go.

A secondary thread was a cross-domain bridge: evaluating the persistent-homology energy on the
Fibonacci sequence (atoms placed at `Fₖ`) returns exactly `Fₙ` (`H0_totalPersistence_fib`),
connecting the topology layer to the catalog's Fibonacci number theory
(`Shared/Fib_gcd_identity`, `Speculative/AutoResearch/FibPrimitive`). This is a template:
any monotone integer sequence becomes a "fold" whose topological energy is its terminal value.

## Results Summary

- `totalPersistence_mono`: proved — topological energy is monotone under multiset (feature) inclusion; the order-theoretic companion of additivity.
- `monotone_const_smul`: proved — nonnegative rescaling preserves monotonicity of a chain (supporting lemma for the scaling law).
- `H0_totalPersistence_smul`: proved — folding energy is degree-1 homogeneous: rescaling coordinates by `c ≥ 0` scales energy by `c`; the contact map has no intrinsic length scale.
- `H0_totalPersistence_concat`: proved — energy is additive across an interior split point (domain decomposition of the folding free energy).
- `H0_energy_depends_only_on_endpoints`: proved — degree-0 energy is a function of `(x 0, x n)` only; the structural root of Levinthal degeneracy.
- `chainA_monotone`, `chainB_monotone`: proved — two concrete monotone folds with shared endpoints (supporting the counterexample).
- `native_fold_nonunique`: proved (counterexample) — two distinct monotone folds with equal endpoints share `H₀` energy, so `native_fold_unique`'s injectivity hypothesis is not removable.
- `fibChain_monotone`: proved — the Fibonacci position sequence is monotone (supporting the bridge).
- `H0_totalPersistence_fib`: proved — the `H₀` energy of the Fibonacci fold equals `Fₙ`; a topology↔number-theory bridge.

## Research Directions

### Direction 1: Higher persistent homology breaks the endpoint degeneracy
**Hypothesis**: There is a `H₁`-flavored persistence functional `E₁` on planar (or 3D) Cα
configurations such that two folds with equal endpoints and equal `H₀` energy but different loop
structure satisfy `E₁(fold₁) ≠ E₁(fold₂)`; i.e. `(E₀, E₁)` jointly separate the `native_fold_nonunique`
counterexample.
**Test**: Formalize a minimal `H₁` barcode for a cyclic contact graph (e.g. the number/length of
independent cycles in the Vietoris–Rips complex at a fixed scale) and prove it distinguishes
`chainA` lifted to a loop vs. an unknotted variant.
**Why now**: `native_fold_nonunique` gives an explicit, fully-formal pair of indistinguishable
folds — a ready-made test fixture for any candidate higher invariant.
**If true**: Uniqueness of the native fold can be recovered from a *finite* tuple of persistence
energies, a quantitative refinement of `native_fold_unique`.
**If false**: It would suggest topological energy alone (any degree) cannot pin a fold, pushing
the theory toward geometric (metric, not just topological) functionals.

### Direction 2: General finite-metric elder rule = minimum spanning tree weight
**Hypothesis**: For any finite metric configuration, the degree-0 total persistence of its
Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the complete
weighted graph; the chain result `H0_totalPersistence_eq_extent` is the special case where the MST
is the path through consecutive atoms.
**Test**: Define an MST-weight functional in Lean and prove equality with `totalPersistence` of the
`H₀` barcode for `Fintype` point sets; verify on a 3- and 4-point example by `decide`/explicit computation.
**Why now**: The chain case is fully proved and the additivity/monotonicity algebra
(`totalPersistence_add`, `totalPersistence_mono`) is exactly the toolkit needed to induct on edges.
**If true**: Promotes the entire folding-energy theory from linear chains to arbitrary 3D
configurations — the realistic setting.
**If false**: The discrepancy would localize precisely which non-tree cycles contribute, informing
the `H₁` theory of Direction 1.

### Direction 3: Stability as a Lipschitz bound in the sup-metric
**Hypothesis**: `|E(x) − E(y)| ≤ 2 · sup_k |x k − y k|` for all monotone chains (a global,
all-coordinates strengthening of the catalog's two-endpoint `H0_totalPersistence_stable`).
**Test**: Prove it from `H0_energy_depends_only_on_endpoints` + the triangle inequality, then probe
whether the constant `2` is tight and whether it survives the MST generalization of Direction 2.
**Why now**: `H0_energy_depends_only_on_endpoints` reduces the whole functional to two coordinates,
making the sup-bound a short corollary while exposing the tightness question.
**If true**: Gives bottleneck stability of the folding energy landscape under thermal noise in a
clean operator-norm form.
**If false**: The failing configuration is a counterexample worth cataloguing — it would mean MST
rewiring under perturbation amplifies error beyond the endpoint bound.

### Direction 4: Integer-sequence folds as a topology↔number-theory dictionary
**Hypothesis**: For every monotone `a : ℕ → ℕ`, the fold at positions `aₖ` has `H₀` energy `aₙ − a₀`;
specializing to multiplicative/recursive sequences yields identities (e.g. for `aₖ = ∑_{j≤k} φ(j)`,
the energy is the totient summatory function), turning persistence identities into number-theoretic ones.
**Test**: Generalize `H0_totalPersistence_fib` to an arbitrary monotone `ℕ→ℕ` sequence, then derive
the totient-summatory and partial-sum-of-divisors instances as corollaries.
**Why now**: `H0_totalPersistence_fib` is the first worked instance; the proof is sequence-agnostic
(`H0_totalPersistence_eq_extent` + `a₀` value), so generalization is immediate.
**If true**: Provides a uniform bridge letting catalog number-theory results
(`Fib_gcd_identity`, `FibPrimitive`) be re-read as statements about persistent-homology energies.
**If false (i.e. some sequence breaks monotonicity casting)**: It pinpoints exactly which arithmetic
functions fail to embed as folds, a constraint on the dictionary.

### Direction 5: Two-sided functoriality and the persistence module structure
**Hypothesis**: The map `t ↦ Rips d t` together with the inclusion maps assembles into a genuine
persistence module over `ℝ`, and `totalPersistence` factors through its barcode decomposition
functorially (interleaving distance ≤ ε ⇒ energies differ by ≤ C·ε).
**Test**: Define the inclusion morphisms `Rips d s → Rips d t` (already supported by the catalog's
`Rips_mono`) and prove a categorical interleaving-stability statement for the chain model.
**Why now**: `Rips_mono` (catalog) plus this cycle's `totalPersistence_mono` give both halves of the
functoriality square; only the morphism bookkeeping remains.
**If true**: Connects the folding model to the standard persistence-module machinery, opening the
door to importing bottleneck/interleaving stability in full generality.
**If false**: The obstruction would reveal where the finite-chain model departs from the continuous
persistence-module theory — itself a publishable boundary.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
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
