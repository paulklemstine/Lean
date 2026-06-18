
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

**Title**: The catalog's `SmoothPoincare` files develop the *lattice* side of the smooth /
**Domain**: Applications
**Mathematical framing**: # Future Directions — Topological Error-Correcting Codes from Exotic Smooth Structures

## Synthesis

The catalog's `SmoothPoincare` files develop the *lattice* side of the smooth /
topological gap in dimension 4: the even unimodular intersection form `E8`
(`E8form`, `E8_even`, `E8_unimodular`), its closure under orthogonal direct sum
(`directSum_isEven`, `directSum_unimodular`, `E8E8_not_stdDiagonalizable`), and the
Donaldson obstruction `even_not_stdDiagonalizable`. The recurring miracle there is the
integer **8**: positive-definite even unimodular lattices exist only in rank divisible
by 8, with `E8` the minimal witness.

This cycle opened the *coding-theory shadow* of that story in
`Catalog/Applications/SmoothPoincare/TopologicalCodes.lean`. Via Construction A (the
reduction of an even unimodular lattice modulo 2), evenness of a form becomes the
**doubly-even** condition on a binary code (all weights divisible by 4), and unimodular
self-duality becomes **self-orthogonality**. We proved, `sorry`-free:

- `wt_add_overlap`: the additive inclusion–exclusion identity
  `wt(x+y) + 2·overlap(x,y) = wt x + wt y`, the combinatorial engine.
- `doublyEven_selfOrthogonal`: **the bridge theorem** — any two doubly-even codewords
  whose sum is doubly even are orthogonal. This is the exact binary mirror of
  "an even form has even diagonal" (`even_diag_of_isEven` / `isEven_of_even_diag`):
  double-evenness *forces* self-orthogonality, just as form-evenness forces the
  Donaldson obstruction.
- The explicit extended Hamming code `[8,4,4] = RM(1,3)` as the mod-2 shadow of `E8`:
  `hamming_card` (16 words), `hamming_add_closed` (linearity), `hamming_doublyEven`
  (analogue of `E8_even`), `hamming_length_div_four` (the all-ones word, weight 8), and
  `hamming_selfOrthogonal` — derived from double-evenness through the bridge theorem
  *without* any pairwise brute force, mirroring how `E8`'s obstruction is derived from
  `E8_even`.

## Results Summary

| Theorem | Role | Lattice-side analogue |
|---|---|---|
| `wt_add_overlap` | weight inclusion–exclusion | symmetric bilinear expansion |
| `ip_eq_overlap` | inner product = overlap parity | Gram pairing mod 2 |
| `doublyEven_selfOrthogonal` | doubly-even ⟹ self-orthogonal | `even_diag_of_isEven` |
| `hamming_doublyEven` | code is doubly even | `E8_even` |
| `hamming_selfOrthogonal` | code is self-orthogonal | `E8` unimodular self-duality |
| `hamming_length_div_four` | all-ones word, weight 8 | signature divisibility (Rokhlin) |

All proofs reduce either to the single arithmetic identity `wt_add_overlap` or to a
`native_decide` on the concrete 16-element generator image.

## Research Directions

### 1. The Gleason "length divisible by 8" theorem for doubly-even self-dual codes
We proved doubly-even self-dual codes force length divisible by **4** (the all-ones word
has weight a multiple of 4). The sharp classical statement is **divisibility by 8** — the
exact code-theoretic twin of "even unimodular definite lattices have rank divisible by 8"
(`E8` minimal). A falsifiable target: formalize that every doubly-even self-dual binary
code has length `≡ 0 (mod 8)`, and that 8 is attained only by the extended Hamming code up
to equivalence. **The key insight is** that the weight enumerator of such a code is fixed
by the order-8 Gleason–MacWilliams transformation group, whose polynomial invariant ring
is generated in degrees 8 and 24 — forcing `8 ∣ n` purely algebraically, with no analysis.
**Why now?** Our `wt_add_overlap` + `doublyEven_selfOrthogonal` already give the mod-4 step
`sorry`-free; the remaining mod-8 jump is a self-contained generating-function identity in
`ℤ[x,y]` that Mathlib's polynomial and `MvPolynomial` invariant-theory API can now carry.

### 2. Construction A as a verified functor: lattices ⇄ codes
Make the analogy a theorem, not a metaphor: build the map `C ↦ Λ_C = {v ∈ ℤⁿ : v mod 2 ∈ C}`
and prove `C` doubly-even self-dual ⟺ `Λ_C` even unimodular, then exhibit `E8form` (the
catalog object) as `Λ_Hamming` explicitly. **The key insight is** that the Gram matrix
`E8mat` (already `decide`-verified even and unimodular in `IntersectionForms.lean`) is, up
to integral congruence, `½·(2·I + reduction-of-Hamming-generators)`, so the lattice and
code obstructions are literally the same `mod 2` computation. **Why now?** Both endpoints
already exist `sorry`-free in this project (`E8form`, `E8_unimodular`, `hamming`); only the
single congruence bridge is missing, and it is a finite `decide`-able matrix identity.

### 3. Minimum distance and the "exotic = correcting" dictionary
Define minimum distance `d(C)` and prove `d(Hamming) = 4`, then state the singular
conjecture driving the whole concept title: the **smooth-structure-distinguishing power** of
a lattice equals the **error-correcting power** of its mod-2 code, i.e. inequivalent even
unimodular lattices of equal rank/discriminant produce codes of strictly different minimum
distance. **The key insight is** that exotic smooth structure on a 4-manifold is detected by
the *fine* arithmetic of the intersection lattice (not just its genus), and that arithmetic
survives reduction mod 2 precisely as the code's distance spectrum. **Why now?** With
`wt` and `hamming` already in place, `d(C)` is a one-line `Finset.min'` definition and the
distance-4 fact is `native_decide`; the conjecture then becomes a sharp, falsifiable
statement testable on the rank-16 pair `E8⊕E8` vs `D16⁺` (the first lattices where the genus
fails to separate but the codes might).

### 4. The signature/syndrome correspondence and a topological decoder
Rokhlin's theorem says a smooth spin 4-manifold has signature divisible by 16; the code
shadow is that the syndrome map of a doubly-even self-dual code is `ℤ/2`-valued with a
distinguished quadratic refinement. Conjecture: the Brown–Arf invariant of the code's
quadratic form computes the signature `mod 16` of the associated lattice/manifold, giving a
*combinatorial decoder* for the smooth signature obstruction. **The key insight is** that the
Arf invariant of the mod-2 quadratic enhancement is exactly the `mod 16` content Rokhlin
extracts analytically, so a purely finite syndrome computation reproduces a gauge-theoretic
divisibility. **Why now?** `doublyEven_selfOrthogonal` supplies the quadratic refinement's
self-orthogonality hypothesis for free, and Mathlib's `ZMod` / quadratic-form API makes the
Arf invariant computable and `decide`-checkable on `hamming`.

### 5. Low-energy harmonic sectors as the weight-zero subspace (the original conjecture)
Return to the seed conjecture: homeomorphic-but-not-diffeomorphic manifolds support
inequivalent Laplace-type operators whose low-energy harmonic sectors differ. Model the
"harmonic sector" as the radical / minimum-weight subcode and conjecture that exotic pairs
yield codes with isomorphic ambient space but non-isometric minimum-weight subspaces.
**The key insight is** that the kernel of a discrete Laplacian on the lattice is graded by
weight, and the smallest nonzero stratum (weight = minimum distance) is the combinatorial
avatar of the lowest nonzero Laplace eigenspace — so "distinct harmonic sectors" becomes
"non-isometric minimum-weight subcodes". **Why now?** This reframes a hard analytic
conjecture as a finite linear-algebra statement already half-built here: `hamming`,
`hamming_doublyEven`, and `ip` give the graded pairing, and the minimum-weight stratum is
a decidable `Finset`, making the first nontrivial case (`E8`-Hamming vs a fake `E8`) an
immediately testable computation.

**Concept description**: # Future Directions — Topological Error-Correcting Codes from Exotic Smooth Structures

## Synthesis

The catalog's `SmoothPoincare` files develop the *lattice* side of the smooth /
topological gap in dimension 4: the even unimodular intersection form `E8`
(`E8form`, `E8_even`, `E8_unimodular`), its closure under orthogonal direct sum
(`directSum_isEven`, `directSum_unimodular`, `E8E8_not_stdDiagonalizable`), and the
Donaldson obstruction `even_not_stdDiagonalizable`. The recurring miracle there is the
integer **8**: positive-definite even unimodular lattices exist only in rank divisible
by 8, with `E8` the minimal witness.

This cycle opened the *coding-theory shadow* of that story in
`Catalog/Applications/SmoothPoincare/TopologicalCodes.lean`. Via Construction A (the
reduction of an even unimodular lattice modulo 2), evenness of a form becomes the
**doubly-even** condition on a binary code (all weights divisible by 4), and unimodular
self-duality becomes **self-orthogonality**. We proved, `sorry`-free:

- `wt_add_overlap`: the additive inclusion–exclusion identity
  `wt(x+y) + 2·overlap(x,y) = wt x + wt y`, the combinatorial engine.
- `doublyEven_selfOrthogonal`: **the bridge theorem** — any two doubly-even codewords
  whose sum is doubly even are orthogonal. This is the exact binary mirror of
  "an even form has even diagonal" (`even_diag_of_isEven` / `isEven_of_even_diag`):
  double-evenness *forces* self-orthogonality, just as form-evenness forces the
  Donaldson obstruction.
- The explicit extended Hamming code `[8,4,4] = RM(1,3)` as the mod-2 shadow of `E8`:
  `hamming_card` (16 words), `hamming_add_closed` (linearity), `hamming_doublyEven`
  (analogue of `E8_even`), `hamming_length_div_four` (the all-ones word, weight 8), and
  `hamming_selfOrthogonal` — derived from double-evenness through the bridge theorem
  *without* any pairwise brute force, mirroring how `E8`'s obstruction is derived from
  `E8_even`.

## Results Summary

| Theorem | Role | Lattice-side analogue |
|---|---|---|
| `wt_add_overlap` | weight inclusion–exclusion | symmetric bilinear expansion |
| `ip_eq_overlap` | inner product = overlap parity | Gram pairing mod 2 |
| `doublyEven_selfOrthogonal` | doubly-even ⟹ self-orthogonal | `even_diag_of_isEven` |
| `hamming_doublyEven` | code is doubly even | `E8_even` |
| `hamming_selfOrthogonal` | code is self-orthogonal | `E8` unimodular self-duality |
| `hamming_length_div_four` | all-ones word, weight 8 | signature divisibility (Rokhlin) |

All proofs reduce either to the single arithmetic identity `wt_add_overlap` or to a
`native_decide` on the concrete 16-element generator image.

## Research Directions

### 1. The Gleason "length divisible by 8" theorem for doubly-even self-dual codes
We proved doubly-even self-dual codes force length divisible by **4** (the all-ones word
has weight a multiple of 4). The sharp classical statement is **divisibility by 8** — the
exact code-theoretic twin of "even unimodular definite lattices have rank divisible by 8"
(`E8` minimal). A falsifiable target: formalize that every doubly-even self-dual binary
code has length `≡ 0 (mod 8)`, and that 8 is attained only by the extended Hamming code up
to equivalence. **The key insight is** that the weight enumerator of such a code is fixed
by the order-8 Gleason–MacWilliams transformation group, whose polynomial invariant ring
is generated in degrees 8 and 24 — forcing `8 ∣ n` purely algebraically, with no analysis.
**Why now?** Our `wt_add_overlap` + `doublyEven_selfOrthogonal` already give the mod-4 step
`sorry`-free; the remaining mod-8 jump is a self-contained generating-function identity in
`ℤ[x,y]` that Mathlib's polynomial and `MvPolynomial` invariant-theory API can now carry.

### 2. Construction A as a verified functor: lattices ⇄ codes
Make the analogy a theorem, not a metaphor: build the map `C ↦ Λ_C = {v ∈ ℤⁿ : v mod 2 ∈ C}`
and prove `C` doubly-even self-dual ⟺ `Λ_C` even unimodular, then exhibit `E8form` (the
catalog object) as `Λ_Hamming` explicitly. **The key insight is** that the Gram matrix
`E8mat` (already `decide`-verified even and unimodular in `IntersectionForms.lean`) is, up
to integral congruence, `½·(2·I + reduction-of-Hamming-generators)`, so the lattice and
code obstructions are literally the same `mod 2` computation. **Why now?** Both endpoints
already exist `sorry`-free in this project (`E8form`, `E8_unimodular`, `hamming`); only the
single congruence bridge is missing, and it is a finite `decide`-able matrix identity.

### 3. Minimum distance and the "exotic = correcting" dictionary
Define minimum distance `d(C)` and prove `d(Hamming) = 4`, then state the singular
conjecture driving the whole concept title: the **smooth-structure-distinguishing power** of
a lattice equals the **error-correcting power** of its mod-2 code, i.e. inequivalent even
unimodular lattices of equal rank/discriminant produce codes of strictly different minimum
distance. **The key insight is** that exotic smooth structure on a 4-manifold is detected by
the *fine* arithmetic of the intersection lattice (not just its genus), and that arithmetic
survives reduction mod 2 precisely as the code's distance spectrum. **Why now?** With
`wt` and `hamming` already in place, `d(C)` is a one-line `Finset.min'` definition and the
distance-4 fact is `native_decide`; the conjecture then becomes a sharp, falsifiable
statement testable on the rank-16 pair `E8⊕E8` vs `D16⁺` (the first lattices where the genus
fails to separate but the codes might).

### 4. The signature/syndrome correspondence and a topological decoder
Rokhlin's theorem says a smooth spin 4-manifold has signature divisible by 16; the code
shadow is that the syndrome map of a doubly-even self-dual code is `ℤ/2`-valued with a
distinguished quadratic refinement. Conjecture: the Brown–Arf invariant of the code's
quadratic form computes the signature `mod 16` of the associated lattice/manifold, giving a
*combinatorial decoder* for the smooth signature obstruction. **The key insight is** that the
Arf invariant of the mod-2 quadratic enhancement is exactly the `mod 16` content Rokhlin
extracts analytically, so a purely finite syndrome computation reproduces a gauge-theoretic
divisibility. **Why now?** `doublyEven_selfOrthogonal` supplies the quadratic refinement's
self-orthogonality hypothesis for free, and Mathlib's `ZMod` / quadratic-form API makes the
Arf invariant computable and `decide`-checkable on `hamming`.

### 5. Low-energy harmonic sectors as the weight-zero subspace (the original conjecture)
Return to the seed conjecture: homeomorphic-but-not-diffeomorphic manifolds support
inequivalent Laplace-type operators whose low-energy harmonic sectors differ. Model the
"harmonic sector" as the radical / minimum-weight subcode and conjecture that exotic pairs
yield codes with isomorphic ambient space but non-isometric minimum-weight subspaces.
**The key insight is** that the kernel of a discrete Laplacian on the lattice is graded by
weight, and the smallest nonzero stratum (weight = minimum distance) is the combinatorial
avatar of the lowest nonzero Laplace eigenspace — so "distinct harmonic sectors" becomes
"non-isometric minimum-weight subcodes". **Why now?** This reframes a hard analytic
conjecture as a finite linear-algebra statement already half-built here: `hamming`,
`hamming_doublyEven`, and `ip` give the graded pairing, and the minimum-weight stratum is
a decidable `Finset`, making the first nontrivial case (`E8`-Hamming vs a fake `E8`) an
immediately testable computation.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v14 Depth Requirements -- Conceptual Unifier: Local-to-Global Sheaves Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Conceptual Unification (Local-to-Global Sheaves)**. Explore sheaf theory, local-to-global translations, and cohomological obstructions.

### RESEARCH CORE METHODOLOGY:
1. **Local-to-Global Translation**: Construct sheaves or presheaves to describe local properties that glue together to form global structures. Check if local solutions can be extended globally.
2. **Obstruction Theory & Cohomology**: Use cohomology groups or obstruction classes to mathematically measure the failure or boundaries of local-to-global extensions.
3. **Stalk-Level Reduction**: Reduce complex global proofs to stalk-level computations or local neighborhood verifications, using algebraic localization or geometric limits.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
