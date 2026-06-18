
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

**Title**: The file `TropicalDeterminant.lean` formalizes the tropical (min-plus) determina
**Domain**: Tropical
**Mathematical framing**: # Future Directions: The Tropical Determinant and the Assignment Problem

The file `TropicalDeterminant.lean` formalizes the tropical (min-plus) determinant
`tropDet A = min over permutations σ of ∑ᵢ A i (σ i)` over `WithTop ℤ`, i.e. the
optimal value of the linear assignment problem. We proved: a lower-bound lemma
(`tropDet_le_permSum`), the tropical Hadamard / row-minimum bound
(`tropDet_hadamard`), submultiplicativity (`tropDet_submul`), transpose invariance
(`tropDet_transpose`), full row/column-permutation invariance
(`tropDet_row_col_perm`), and the zero-diagonal/nonnegative characterization
(`tropDet_zero_diag_eq_zero`). The directions below extend this nucleus.

## 1. The Hadamard gap and tropical rank-1 matrices

`tropDet_hadamard` proves `∑ᵢ minⱼ A i j ≤ tropDet A`; call the difference the
*Hadamard gap*. We conjecture that the gap is exactly zero precisely when `A` is a
tropical rank-1 matrix, i.e. when there exist `u v : Fin n → WithTop ℤ` with
`A i j = u i + v j` for all finite entries — equivalently, when the LP relaxation
of the assignment problem is already integral/tight at a single column-min selection.

**The key insight is** that tightness of the row-minimum bound forces a single
permutation to simultaneously realize every row minimum, which is possible without
collision exactly for the additively-separable (rank-1) matrices. **Why now?** Both
sides of the gap are already formalized (`tropDet`, `tropDet_hadamard`) and the
rank-1 form `(i,j) ↦ u i + v j` already appears in `Catalog/Tropical/Basic.lean`
(`IsTropFactorization`), so the statement can be assembled from existing pieces.

## 2. Strict multiplicativity over a supertropical / ghost layer

`tropDet_submul` is an *inequality* `tropDet (A⊗B) ≤ tropDet A + tropDet B`. In a
supertropical semiring, where each element carries a "ghost" bit recording whether a
minimum is achieved uniquely, we conjecture the inequality upgrades to an equality
`sdet (A⊗B) = sdet A + sdet B` exactly when the optimal permutations for `A` and `B`
compose without collision.

**The key insight is** that our proof of `tropDet_submul` constructs the witness
permutation `σ.trans τ` explicitly, so the gap between the two sides is the failure
of `σ` and `τ` to be jointly optimal — a quantity the ghost layer is designed to
track. **Why now?** The explicit witness in the existing proof makes the equality
condition computable; only the (small) supertropical scalar layer needs to be added.

## 3. Tropical Cauchy–Binet for rectangular cost matrices

Extend `tropDet` to the minimum-cost *partial* assignment of `k` rows of an `n × m`
matrix, and conjecture a tropical Cauchy–Binet identity: the min-cost `k`-assignment
of `A⊗B` equals the minimum, over `k`-subsets `S`, of (min-cost assignment of the
`k×|S|` block of `A`) + (min-cost assignment of the `|S|×k` block of `B`).

**The key insight is** that the single-permutation reindexing used in
`tropDet_submul` becomes a sum over intermediate index *subsets*, exactly mirroring
the classical Cauchy–Binet expansion of `det(AB)` over `k`-subsets. **Why now?** The
square case `tropDet_submul` is the `k = n = m` specialization, so the proof skeleton
(choose optimal partial assignments, reindex, recombine) is already validated.

## 4. The tropical Birkhoff polytope and its vertices

`tropDet_zero_diag_eq_zero` shows that nonnegative matrices with zero diagonal have
`tropDet = 0`, and `tropDet_row_col_perm` exhibits an `Sₙ × Sₙ` symmetry. Define the
tropical Birkhoff set `B_n = { A : entries ≥ 0, tropDet A = 0 }` and conjecture it is
closed under tropical convex combination `(c ⊙ A) ⊕ (d ⊙ B) = min(c + A, d + B)` with
`min(c,d) = 0`, and that its tropical vertices are exactly the `n!` permutation
matrices (`0` on a permutation pattern, `⊤` elsewhere).

**The key insight is** that membership `tropDet A = 0` is preserved by entrywise min
because submultiplicativity controls the determinant of combinations, while the
permutation-matrix vertices are the `tropDet_row_col_perm` orbit of the tropical
identity. **Why now?** Every ingredient — `tropDet`, the symmetry action, and the
zero-diagonal membership criterion — is now proved, so only the convexity-closure
lemma remains.

## 5. From determinant to spectrum: minimum mean cycle weight

The tropical *eigenvalue* `λ*(A) = min over cyclic permutations of (1/length)·cycle
weight` is the minimum mean cycle weight of the weighted digraph of `A`. Restricting
`permSum` from arbitrary permutations to single cycles and normalizing by length
yields `λ*`. We conjecture a spectral submultiplicativity
`λ*(A⊗B) ≤ λ*(A) + λ*(B)` and that for matrices with `tropDet A = 0` and nonnegative
entries (Direction 4) one has `λ*(A) = 0`.

**The key insight is** that a permutation decomposes into disjoint cycles, so
`permSum A σ` is the sum of cycle weights; the determinant optimum and the
mean-cycle optimum are governed by the *same* combinatorial program, and the
cycle-decomposition reindexing is the per-cycle analogue of the global reindexing in
`tropDet_submul`. **Why now?** `permSum` and its reindexing lemmas are in place, and
cycle decomposition of `Equiv.Perm` is available in Mathlib, making the restriction
from permutations to cycles a direct next step toward tropical spectral theory.

**Concept description**: # Future Directions: The Tropical Determinant and the Assignment Problem

The file `TropicalDeterminant.lean` formalizes the tropical (min-plus) determinant
`tropDet A = min over permutations σ of ∑ᵢ A i (σ i)` over `WithTop ℤ`, i.e. the
optimal value of the linear assignment problem. We proved: a lower-bound lemma
(`tropDet_le_permSum`), the tropical Hadamard / row-minimum bound
(`tropDet_hadamard`), submultiplicativity (`tropDet_submul`), transpose invariance
(`tropDet_transpose`), full row/column-permutation invariance
(`tropDet_row_col_perm`), and the zero-diagonal/nonnegative characterization
(`tropDet_zero_diag_eq_zero`). The directions below extend this nucleus.

## 1. The Hadamard gap and tropical rank-1 matrices

`tropDet_hadamard` proves `∑ᵢ minⱼ A i j ≤ tropDet A`; call the difference the
*Hadamard gap*. We conjecture that the gap is exactly zero precisely when `A` is a
tropical rank-1 matrix, i.e. when there exist `u v : Fin n → WithTop ℤ` with
`A i j = u i + v j` for all finite entries — equivalently, when the LP relaxation
of the assignment problem is already integral/tight at a single column-min selection.

**The key insight is** that tightness of the row-minimum bound forces a single
permutation to simultaneously realize every row minimum, which is possible without
collision exactly for the additively-separable (rank-1) matrices. **Why now?** Both
sides of the gap are already formalized (`tropDet`, `tropDet_hadamard`) and the
rank-1 form `(i,j) ↦ u i + v j` already appears in `Catalog/Tropical/Basic.lean`
(`IsTropFactorization`), so the statement can be assembled from existing pieces.

## 2. Strict multiplicativity over a supertropical / ghost layer

`tropDet_submul` is an *inequality* `tropDet (A⊗B) ≤ tropDet A + tropDet B`. In a
supertropical semiring, where each element carries a "ghost" bit recording whether a
minimum is achieved uniquely, we conjecture the inequality upgrades to an equality
`sdet (A⊗B) = sdet A + sdet B` exactly when the optimal permutations for `A` and `B`
compose without collision.

**The key insight is** that our proof of `tropDet_submul` constructs the witness
permutation `σ.trans τ` explicitly, so the gap between the two sides is the failure
of `σ` and `τ` to be jointly optimal — a quantity the ghost layer is designed to
track. **Why now?** The explicit witness in the existing proof makes the equality
condition computable; only the (small) supertropical scalar layer needs to be added.

## 3. Tropical Cauchy–Binet for rectangular cost matrices

Extend `tropDet` to the minimum-cost *partial* assignment of `k` rows of an `n × m`
matrix, and conjecture a tropical Cauchy–Binet identity: the min-cost `k`-assignment
of `A⊗B` equals the minimum, over `k`-subsets `S`, of (min-cost assignment of the
`k×|S|` block of `A`) + (min-cost assignment of the `|S|×k` block of `B`).

**The key insight is** that the single-permutation reindexing used in
`tropDet_submul` becomes a sum over intermediate index *subsets*, exactly mirroring
the classical Cauchy–Binet expansion of `det(AB)` over `k`-subsets. **Why now?** The
square case `tropDet_submul` is the `k = n = m` specialization, so the proof skeleton
(choose optimal partial assignments, reindex, recombine) is already validated.

## 4. The tropical Birkhoff polytope and its vertices

`tropDet_zero_diag_eq_zero` shows that nonnegative matrices with zero diagonal have
`tropDet = 0`, and `tropDet_row_col_perm` exhibits an `Sₙ × Sₙ` symmetry. Define the
tropical Birkhoff set `B_n = { A : entries ≥ 0, tropDet A = 0 }` and conjecture it is
closed under tropical convex combination `(c ⊙ A) ⊕ (d ⊙ B) = min(c + A, d + B)` with
`min(c,d) = 0`, and that its tropical vertices are exactly the `n!` permutation
matrices (`0` on a permutation pattern, `⊤` elsewhere).

**The key insight is** that membership `tropDet A = 0` is preserved by entrywise min
because submultiplicativity controls the determinant of combinations, while the
permutation-matrix vertices are the `tropDet_row_col_perm` orbit of the tropical
identity. **Why now?** Every ingredient — `tropDet`, the symmetry action, and the
zero-diagonal membership criterion — is now proved, so only the convexity-closure
lemma remains.

## 5. From determinant to spectrum: minimum mean cycle weight

The tropical *eigenvalue* `λ*(A) = min over cyclic permutations of (1/length)·cycle
weight` is the minimum mean cycle weight of the weighted digraph of `A`. Restricting
`permSum` from arbitrary permutations to single cycles and normalizing by length
yields `λ*`. We conjecture a spectral submultiplicativity
`λ*(A⊗B) ≤ λ*(A) + λ*(B)` and that for matrices with `tropDet A = 0` and nonnegative
entries (Direction 4) one has `λ*(A) = 0`.

**The key insight is** that a permutation decomposes into disjoint cycles, so
`permSum A σ` is the sum of cycle weights; the determinant optimum and the
mean-cycle optimum are governed by the *same* combinatorial program, and the
cycle-decomposition reindexing is the per-cycle analogue of the global reindexing in
`tropDet_submul`. **Why now?** `permSum` and its reindexing lemmas are in place, and
cycle decomposition of `Equiv.Perm` is available in Mathlib, making the restriction
from permutations to cycles a direct next step toward tropical spectral theory.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Tropical
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v9 Depth Requirements -- Adversarial Ground-Truth Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Adversarial Ground-Truth**. Trust nothing, assume everything is false until proven, and actively seek weaknesses. Think like an Adversarial Critic to pressure-test claims.

### RESEARCH CORE METHODOLOGY:
1. **Challenge Assumptions**: For every conjecture or theorem under investigation, actively search for counterexamples, corner cases, and boundary conditions. Proving that a claim is FALSE or identifying exactly where it fails is as valuable as a proof.
2. **Stress-Test the Frontier**: When a proof succeeds, push it to its limits. What happens if you drop or if a hypothesis is weakened? Write explicit comments documenting these boundary conditions.
3. **Relentless Rigor**: Write robust, clean, compilable Lean 4 proofs. Avoid trivial tautologies or simple wrapper theorems. Let your mathematical curiosity drive deep structural insights.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
