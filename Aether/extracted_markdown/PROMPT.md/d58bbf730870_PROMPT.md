
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

**Title**: Closure-stable probe reconstruction as an algorithmic Galois correspondence for finite closure systems
**Domain**: Bridges
**Mathematical framing**: Let `α` be a finite type. Define a reconstruction map from a probe family `P` to a set closure operator `cl_P` by intersecting all probe-certified closed supersets containing a set `s`. Main conjectural theorem cluster: (1) if `P` is separating and closure-stable, then `cl_P` is a `SetClosureOperator`; (2) the `cl_P`-closed sets are exactly the sets invariant under all probes in `P`; (3) if two separating closure-stable probe families induce the same family of closed sets, then they define the same closure operator; (4) conversely, any finite closure operator with enough characteristic probes admits a closure-stable probe representation recovering it exactly. Proof strategy should follow the future-direction style of producing an algorithmic pipeline: first establish lattice-theoretic lemmas about intersections of closed supersets, then define reconstruction, then prove soundness/completeness of probe detection, then derive uniqueness/equivalence. If possible, formulate the converse via finite closed-set lattices or characteristic functions into a semimodule-valued probe space, leveraging the semimodule language already present in the Bridges file.
**Concept description**: The key insight is that the existing closure/reconstruction infrastructure in Bridges can likely be sharpened into a concrete equivalence between finite closure systems and families of closure-stable probes, yielding not just abstract representation theorems but an explicit reconstruction pipeline: recover the closure of any set as the intersection of probe-supported closed supersets, and characterize when two probe families induce the same closure operator. Why now: the catalog already contains the right primitives in `Bridges/AlgebraEMLClosureComputation.lean` (`ClosureSemimoduleSystem`, `ProbeFamily`, `ClosureStableProbe`) and `Bridges/AlgebraEMLReconstruction.lean` (`SetClosureOperator`, `ClosedSet`), while `Algebra/EMLClosureUnification/Core.lean` supplies a parallel closure/kernel viewpoint that makes a bridge theorem tractable. This is a high-novelty Bridges-to-Algebra direction in an under-explored domain with strong existing foundations and almost no remaining technical debt. Concretely, prove a finite reconstruction theorem: for a finite ground type, a separating probe family satisfying closure stability determines a unique closure operator, every closed set is the intersection of probe-detected maximal supersets, and the induced operator is monotone, extensive, idempotent, and algorithmically computable from the probe family. Then prove a converse representation theorem: every finite closure operator admitting enough characteristic probes yields a closure-stable probe family whose reconstruction recovers the original operator. A further target is a comparison theorem showing that probe-equivalence classes correspond to identical closed-set lattices, giving a falsifiable bridge between computational probing data and algebraic closure structure. This matters because it turns orphan closure abstractions into a reusable algorithmic interface for reconstruction, learning, and thermodynamic-style invariants already present elsewhere in Bridges.
**Novelty estimate**: 0.89
**Breakthrough potential**: 0.84
Research domain: Bridges
Research mode: prove


### Lean 4 Sketch
Likely feasible by introducing a finite-type section using `Fintype α` and `DecidableEq α`, defining `reconstructClosure (P : ProbeFamily α ...) : Set α → Set α`, then proving `extensive`, `monotone`, `idempotent`, followed by representation/equivalence lemmas. Expect heavy use of `Set.iInter`/finite intersections or explicit finite `sInf` over closed supersets.



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
