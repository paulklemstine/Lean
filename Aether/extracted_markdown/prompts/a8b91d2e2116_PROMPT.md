
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

**Title**: Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geometry
**Domain**: Geometry
**Mathematical framing**: Sphere packing on S^n (how many non-overlapping caps of radius r fit?) is a fundamental geometric problem with applications to error-correcting codes and signal processing. Use stereographic projection to transform spherical packing to a weighted packing problem on R^n. Define the stereographic packing number N(n,r) as the maximum number of non-overlapping spherical caps of geodesic radius r that fit on S^n. Conjecture: N(n,r) satisfies N(n,r) = (1+O(r^2)) * V_n/V_n(r) where V_n is the volume of S^n and V_n(r) is the volume of a cap, and the O(r^2) correction is explicitly computable from the conformal factor (1+|x|^2)^2/4 of the stereographic projection. More precisely, N(n,r) <= (2/cos(r))^n * V_n/V_n(r). The factor (2/cos(r))^n comes from the maximum conformal distortion of the stereographic projection: a cap of geodesic radius r is mapped to a Euclidean disk whose area differs from the cap area by at most this factor. Test: prove this bound for n=2 and verify it against the known optimal packings (icosahedral: N(2,pi/6) = 12, cuboctahedral: N(2,pi/4) = 6, tetrahedral: N(2,pi/3) = 4). Impact: explicit, computable sphere packing bounds on spheres via classical packing theory on R^n, with applications to spherical codes and molecular geometry.
**Concept description**: Sphere packing on S^n (how many non-overlapping caps of radius r fit?) is a fundamental geometric problem with applications to error-correcting codes and signal processing. Use stereographic projection to transform spherical packing to a weighted packing problem on R^n. Define the stereographic packing number N(n,r) as the maximum number of non-overlapping spherical caps of geodesic radius r that fit on S^n. Conjecture: N(n,r) satisfies N(n,r) = (1+O(r^2)) * V_n/V_n(r) where V_n is the volume of S^n and V_n(r) is the volume of a cap, and the O(r^2) correction is explicitly computable from the conformal factor (1+|x|^2)^2/4 of the stereographic projection. More precisely, N(n,r) <= (2/cos(r))^n * V_n/V_n(r). The factor (2/cos(r))^n comes from the maximum conformal distortion of the stereographic projection: a cap of geodesic radius r is mapped to a Euclidean disk whose area differs from the cap area by at most this factor. Test: prove this bound for n=2 and verify it against the known optimal packings (icosahedral: N(2,pi/6) = 12, cuboctahedral: N(2,pi/4) = 6, tetrahedral: N(2,pi/3) = 4). Impact: explicit, computable sphere packing bounds on spheres via classical packing theory on R^n, with applications to spherical codes and molecular geometry.
**Novelty estimate**: 0.84
**Breakthrough potential**: 0.84
Research domain: Geometry
Research mode: team


### Lean 4 Sketch
Define N(n,r) = max number of non-overlapping caps of geodesic radius r on S^n. Map caps to Euclidean disks via stereographic projection with conformal distortion factor (2/cos(r))^n. Apply Thue-Siegel sphere packing bounds on R^n to get N(n,r) <= (2/cos(r))^n * V_n/V_n(r). For n=2: prove N(2,r) <= (2/cos(r))^2 * 4*pi / (2*pi*(1-cos(r))). Test: verify N(2,pi/6) <= 12 (icosahedron achieves this), N(2,pi/4) <= 6 (cuboctahedron), N(2,pi/3) <= 4 (tetrahedron). Show the bound is tight for these class



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
