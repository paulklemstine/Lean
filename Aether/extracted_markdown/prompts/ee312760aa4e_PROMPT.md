
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

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

**Title**: The Lean development in `Catalog/Speculative/ProteinFolding.lean` establishes th
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Biological Topology: Protein Folding as Persistent-Homology Optimization

The Lean development in `Catalog/Speculative/ProteinFolding.lean` establishes the rigorous
backbone of a topological theory of folding: barcodes, total persistence as a topological
*energy*, functoriality of the Vietoris–Rips contact filtration (`Rips_mono`), the elder-rule
identity on a chain (`H0_totalPersistence_eq_extent`), bottleneck stability
(`H0_totalPersistence_stable`), and existence/uniqueness of the native fold as the argmin of
the energy (`exists_native_fold`, `native_fold_unique`). The conjectures below are the natural
next theorems, each formalizable in Lean and each empirically testable.

## Direction 1 — The general minimum-spanning-tree law for `H₀` total persistence

The chain result `H0_totalPersistence_eq_extent` is the path-graph special case of a sweeping
identity: for *any* finite metric configuration of Cα atoms, the degree-`0` total persistence of
the Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the
complete weighted graph on the atoms. **The key insight is** that single-linkage clustering and
`H₀` persistence are the same process viewed two ways — components merge exactly along MST edges,
so each bar's death is one MST edge weight and the births are all `0`. **Why now?** Mathlib now
has a mature `SimpleGraph` and weighted-graph API, and the elder-rule telescoping argument we
already proved is the `n = path` shadow of Kruskal's algorithm; lifting it to general trees is a
finite, falsifiable combinatorial statement (test: for 100 PDB structures, the GUDHI `H₀`
persistence sum must equal the SciPy MST weight to floating-point tolerance).

## Direction 2 — Compaction monotonicity beyond one dimension (the hydrophobic-collapse theorem)

`compaction_lowers_persistence` shows, on a line, that shrinking the extent lowers the energy.
The multidimensional conjecture: if a configuration `Y` is a `1`-Lipschitz contraction of `X`
(every pairwise distance weakly decreases), then `totalPersistence (H₀(Y)) ≤ totalPersistence (H₀(X))`.
**The key insight is** that a global contraction can only make components merge *earlier*, never
later, so every bar's death time can only decrease — monotonicity of the whole barcode under
distance contraction. **Why now?** This is the precise mathematical content of "the hydrophobic
core pulls the chain inward," and it is directly testable: artificially contracting decoy
coordinates toward their centroid must never raise the measured `H₀` persistence.

## Direction 3 — A Levinthal speed bound from the stability constant

`H0_totalPersistence_stable` gives a Lipschitz constant `2` between coordinate perturbations and
energy change on a chain. Conjecture: the energy landscape `E = totalPersistence ∘ H₀` is globally
Lipschitz in the configuration (in Gromov–Hausdorff distance) with an explicit constant depending
only on `N`, and this constant bounds the number of gradient-descent steps to the native basin by a
**polynomial** in `N`. **The key insight is** that a Lipschitz, single-well topological energy
cannot hide its minimum behind exponentially many barriers, which is exactly what Levinthal's
paradox needs explained. **Why now?** With stability proved in the chain case, the general
Lipschitz estimate is the missing quantitative ingredient; it is falsifiable by measuring the
empirical step-count-to-convergence scaling of persistence-gradient descent across protein lengths.

## Direction 4 — Higher barcodes detect the hydrophobic void (a degree-1/2 signature)

Total persistence in degree `0` measures connectivity; degrees `1` and `2` measure loops and
cavities. Conjecture: native folds are characterized not by minimal *total* persistence but by a
fixed **signature vector** `(TP₀, TP₁, TP₂)` in which `TP₀` is minimized while `TP₁, TP₂` carry a
sharp, reproducible nonzero peak corresponding to the hydrophobic core cavity and the main-chain
loop. **The key insight is** that a protein is not topologically trivial — collapse without a
persistent `H₂` void would be a molten globule, not a fold, so the native state *minimizes* `TP₀`
*subject to* a target `H₂` persistence rather than minimizing all degrees. **Why now?** Fast
Vietoris–Rips engines (Ripser) make multi-degree barcodes computable for full proteins, so the
signature-vector hypothesis can be checked against native/decoy ensembles immediately.

## Direction 5 — Energy-gap uniqueness as a foldability criterion

`native_fold_unique` gives uniqueness when the energy is injective on the decoy set. Conjecture:
a sequence is *foldable* (has a well-defined native state) iff its topological energy landscape has
a strictly positive **spectral gap** — the second-smallest energy over a dense decoy ensemble
exceeds the minimum by a margin bounded below independently of ensemble size. **The key insight is**
that foldability is not about the depth of the global minimum but about its *isolation*: a positive
energy gap is exactly the robust version of `Set.InjOn` at the minimizer. **Why now?** Intrinsically
disordered proteins (no unique fold) provide a natural negative control, so the gap criterion is
directly falsifiable — ordered proteins should show a measurable persistence-energy gap and
disordered ones should not.

**Concept description**: # Future Directions — Biological Topology: Protein Folding as Persistent-Homology Optimization

The Lean development in `Catalog/Speculative/ProteinFolding.lean` establishes the rigorous
backbone of a topological theory of folding: barcodes, total persistence as a topological
*energy*, functoriality of the Vietoris–Rips contact filtration (`Rips_mono`), the elder-rule
identity on a chain (`H0_totalPersistence_eq_extent`), bottleneck stability
(`H0_totalPersistence_stable`), and existence/uniqueness of the native fold as the argmin of
the energy (`exists_native_fold`, `native_fold_unique`). The conjectures below are the natural
next theorems, each formalizable in Lean and each empirically testable.

## Direction 1 — The general minimum-spanning-tree law for `H₀` total persistence

The chain result `H0_totalPersistence_eq_extent` is the path-graph special case of a sweeping
identity: for *any* finite metric configuration of Cα atoms, the degree-`0` total persistence of
the Vietoris–Rips filtration equals the total edge weight of a minimum spanning tree of the
complete weighted graph on the atoms. **The key insight is** that single-linkage clustering and
`H₀` persistence are the same process viewed two ways — components merge exactly along MST edges,
so each bar's death is one MST edge weight and the births are all `0`. **Why now?** Mathlib now
has a mature `SimpleGraph` and weighted-graph API, and the elder-rule telescoping argument we
already proved is the `n = path` shadow of Kruskal's algorithm; lifting it to general trees is a
finite, falsifiable combinatorial statement (test: for 100 PDB structures, the GUDHI `H₀`
persistence sum must equal the SciPy MST weight to floating-point tolerance).

## Direction 2 — Compaction monotonicity beyond one dimension (the hydrophobic-collapse theorem)

`compaction_lowers_persistence` shows, on a line, that shrinking the extent lowers the energy.
The multidimensional conjecture: if a configuration `Y` is a `1`-Lipschitz contraction of `X`
(every pairwise distance weakly decreases), then `totalPersistence (H₀(Y)) ≤ totalPersistence (H₀(X))`.
**The key insight is** that a global contraction can only make components merge *earlier*, never
later, so every bar's death time can only decrease — monotonicity of the whole barcode under
distance contraction. **Why now?** This is the precise mathematical content of "the hydrophobic
core pulls the chain inward," and it is directly testable: artificially contracting decoy
coordinates toward their centroid must never raise the measured `H₀` persistence.

## Direction 3 — A Levinthal speed bound from the stability constant

`H0_totalPersistence_stable` gives a Lipschitz constant `2` between coordinate perturbations and
energy change on a chain. Conjecture: the energy landscape `E = totalPersistence ∘ H₀` is globally
Lipschitz in the configuration (in Gromov–Hausdorff distance) with an explicit constant depending
only on `N`, and this constant bounds the number of gradient-descent steps to the native basin by a
**polynomial** in `N`. **The key insight is** that a Lipschitz, single-well topological energy
cannot hide its minimum behind exponentially many barriers, which is exactly what Levinthal's
paradox needs explained. **Why now?** With stability proved in the chain case, the general
Lipschitz estimate is the missing quantitative ingredient; it is falsifiable by measuring the
empirical step-count-to-convergence scaling of persistence-gradient descent across protein lengths.

## Direction 4 — Higher barcodes detect the hydrophobic void (a degree-1/2 signature)

Total persistence in degree `0` measures connectivity; degrees `1` and `2` measure loops and
cavities. Conjecture: native folds are characterized not by minimal *total* persistence but by a
fixed **signature vector** `(TP₀, TP₁, TP₂)` in which `TP₀` is minimized while `TP₁, TP₂` carry a
sharp, reproducible nonzero peak corresponding to the hydrophobic core cavity and the main-chain
loop. **The key insight is** that a protein is not topologically trivial — collapse without a
persistent `H₂` void would be a molten globule, not a fold, so the native state *minimizes* `TP₀`
*subject to* a target `H₂` persistence rather than minimizing all degrees. **Why now?** Fast
Vietoris–Rips engines (Ripser) make multi-degree barcodes computable for full proteins, so the
signature-vector hypothesis can be checked against native/decoy ensembles immediately.

## Direction 5 — Energy-gap uniqueness as a foldability criterion

`native_fold_unique` gives uniqueness when the energy is injective on the decoy set. Conjecture:
a sequence is *foldable* (has a well-defined native state) iff its topological energy landscape has
a strictly positive **spectral gap** — the second-smallest energy over a dense decoy ensemble
exceeds the minimum by a margin bounded below independently of ensemble size. **The key insight is**
that foldability is not about the depth of the global minimum but about its *isolation*: a positive
energy gap is exactly the robust version of `Set.InjOn` at the minimizer. **Why now?** Intrinsically
disordered proteins (no unique fold) provide a natural negative control, so the gap criterion is
directly falsifiable — ordered proteins should show a measurable persistence-energy gap and
disordered ones should not.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
