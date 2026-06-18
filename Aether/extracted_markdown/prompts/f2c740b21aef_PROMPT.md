
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

**Title**: The 2×2 eigenvalue formula `tropEigval2(A) = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` general
**Domain**: Shared
**Mathematical framing**: # Future Directions: Tropical Spectral Theory

## 1. Tropical Eigenvalue Formula for General n×n Matrices

The 2×2 eigenvalue formula `tropEigval2(A) = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` generalizes to n×n matrices as the minimum cycle mean: `λ(A) = min_{k=1..n} tr(A^k)/k`, where `tr(A^k)` is the minimum weight length-k closed walk. Our `tropical_trace_eigval_2x2` proves this for n=2; the general case requires showing that walk enumeration through matrix powers captures all directed cycles.

The key insight is that `minPlusMul` composes shortest-path computations, so `(A^k)_{ii}` equals the minimum weight walk from i to i of length exactly k, and the infimum over diagonal entries gives the minimum over all starting vertices. Why now? The associativity proof `minPlus_mul_assoc` provides the algebraic backbone — it shows min-plus matrix powers are well-defined and composable. The next step is proving `minPlusPow_entry_eq_min_walk` by induction on k, which reduces the spectral radius formula to a combinatorial identity over the cycle space of the complete directed graph.

## 2. Tropical Cayley–Hamilton and Matrix Power Stabilization

For an n×n min-plus matrix A with no negative-weight cycles (i.e., `tropEigval(A) ≥ 0`), the Bellman–Ford theorem states that the matrix power sequence A, A², A³, ... stabilizes: A^n = A^(n-1) (after suitable normalization). This is the tropical analog of the Cayley–Hamilton theorem. The conjecture is formalizable: define the normalized power `Ã^k := A^k - k·λ(A)·I` (subtracting the eigenvalue from the diagonal) and prove `Ã^n = Ã^(n-1)` for irreducible matrices.

The key insight is that after subtracting the eigenvalue, all cycle means become non-negative, and the critical graph (cycles achieving mean zero) determines the periodicity of the power sequence. Why now? Our `minPlusMul` and `minPlusPow` definitions provide the infrastructure, and `minPlus_mul_assoc` ensures the power sequence is well-defined. The proof should proceed by showing that paths longer than n must revisit a vertex, and non-negative cycle means ensure the shortest path length stabilizes.

## 3. Tropical Eigenvector Uniqueness and the Critical Graph

For a 2×2 matrix, we exhibited three cases for the eigenvector (cycle case, diag0 case, diag1 case). In general, the eigenvector is unique up to tropical scalar multiplication (adding a constant to all entries) if and only if the critical graph — the subgraph consisting of edges participating in minimum-mean cycles — is strongly connected. The conjecture: formalize the critical graph for n×n matrices and prove that strong connectivity of the critical graph implies the tropical eigenspace has "dimension 1" (i.e., all eigenvectors differ by a tropical scalar).

The key insight is that tropical eigenspaces are classical convex cones, and their dimension equals the number of strongly connected components of the critical graph. Why now? The explicit eigenvector constructions in our three case theorems reveal the pattern: when the 2-cycle (0→1→0) is critical, the eigenvector has a specific off-diagonal structure; when a 1-cycle (self-loop) is critical, the eigenvector has a simpler structure. Generalizing this to track which cycles are critical would yield the full classification.

## 4. Tropical Perron–Frobenius Theorem

The classical Perron–Frobenius theorem states that an irreducible non-negative matrix has a unique maximal eigenvalue with a positive eigenvector. The tropical analog: for an irreducible min-plus matrix (the associated digraph is strongly connected), the tropical eigenvalue `λ = min_{k=1..n} tr(A^k)/k` is achieved by a unique eigenvector up to tropical scaling, and this eigenvector has all finite entries. Our `tropical_eigval_2x2_witness` proves existence for n=2; irreducibility (strong connectivity of the 2-vertex digraph with finite entries) should imply the eigenvector entries are all finite.

The key insight is that irreducibility in the tropical setting means every pair of vertices is connected by a finite-weight path, which forces the eigenvector equation `min_j(A_{ij} + x_j) = λ + x_i` to have a unique solution (up to additive constants) by a contraction mapping argument on the tropical projective space. Why now? The infrastructure of `IsTropicalEigenpair` and the case analysis framework scales naturally to larger matrices. The next concrete step is defining irreducibility (`∀ i j, ∃ k, minPlusPow A k i j < ⊤`) and proving the eigenvector has no infinite entries.

## 5. Tropical Determinant and Optimal Assignment

The tropical determinant of an n×n matrix is `tdet(A) = min_{σ ∈ Sₙ} Σᵢ A_{i,σ(i)}`, which is exactly the optimal assignment (Hungarian algorithm) cost. The conjecture: `tdet(A·B) = tdet(A) + tdet(B)` (the tropical determinant is multiplicative, where tropical multiplication of scalars is ordinary addition). This is a non-trivial combinatorial identity relating optimal assignments in a product to the sum of individual optimal assignments.

The key insight is that the minimum over permutations of a sum can be decomposed using the associativity of min-plus multiplication (`minPlus_mul_assoc`): the (σ,τ)-term of the product determinant telescopes through intermediate vertices. Why now? Our formalization of `minPlusMul` and its associativity provides the exact framework. The proof should use `Finset.inf'` over `Equiv.Perm (Fin n)` and the fact that composing two permutations through intermediate sums gives back the full permutation sum — essentially a tropical Cauchy–Binet identity.

**Concept description**: # Future Directions: Tropical Spectral Theory

## 1. Tropical Eigenvalue Formula for General n×n Matrices

The 2×2 eigenvalue formula `tropEigval2(A) = min(A₀₀, A₁₁, (A₀₁+A₁₀)/2)` generalizes to n×n matrices as the minimum cycle mean: `λ(A) = min_{k=1..n} tr(A^k)/k`, where `tr(A^k)` is the minimum weight length-k closed walk. Our `tropical_trace_eigval_2x2` proves this for n=2; the general case requires showing that walk enumeration through matrix powers captures all directed cycles.

The key insight is that `minPlusMul` composes shortest-path computations, so `(A^k)_{ii}` equals the minimum weight walk from i to i of length exactly k, and the infimum over diagonal entries gives the minimum over all starting vertices. Why now? The associativity proof `minPlus_mul_assoc` provides the algebraic backbone — it shows min-plus matrix powers are well-defined and composable. The next step is proving `minPlusPow_entry_eq_min_walk` by induction on k, which reduces the spectral radius formula to a combinatorial identity over the cycle space of the complete directed graph.

## 2. Tropical Cayley–Hamilton and Matrix Power Stabilization

For an n×n min-plus matrix A with no negative-weight cycles (i.e., `tropEigval(A) ≥ 0`), the Bellman–Ford theorem states that the matrix power sequence A, A², A³, ... stabilizes: A^n = A^(n-1) (after suitable normalization). This is the tropical analog of the Cayley–Hamilton theorem. The conjecture is formalizable: define the normalized power `Ã^k := A^k - k·λ(A)·I` (subtracting the eigenvalue from the diagonal) and prove `Ã^n = Ã^(n-1)` for irreducible matrices.

The key insight is that after subtracting the eigenvalue, all cycle means become non-negative, and the critical graph (cycles achieving mean zero) determines the periodicity of the power sequence. Why now? Our `minPlusMul` and `minPlusPow` definitions provide the infrastructure, and `minPlus_mul_assoc` ensures the power sequence is well-defined. The proof should proceed by showing that paths longer than n must revisit a vertex, and non-negative cycle means ensure the shortest path length stabilizes.

## 3. Tropical Eigenvector Uniqueness and the Critical Graph

For a 2×2 matrix, we exhibited three cases for the eigenvector (cycle case, diag0 case, diag1 case). In general, the eigenvector is unique up to tropical scalar multiplication (adding a constant to all entries) if and only if the critical graph — the subgraph consisting of edges participating in minimum-mean cycles — is strongly connected. The conjecture: formalize the critical graph for n×n matrices and prove that strong connectivity of the critical graph implies the tropical eigenspace has "dimension 1" (i.e., all eigenvectors differ by a tropical scalar).

The key insight is that tropical eigenspaces are classical convex cones, and their dimension equals the number of strongly connected components of the critical graph. Why now? The explicit eigenvector constructions in our three case theorems reveal the pattern: when the 2-cycle (0→1→0) is critical, the eigenvector has a specific off-diagonal structure; when a 1-cycle (self-loop) is critical, the eigenvector has a simpler structure. Generalizing this to track which cycles are critical would yield the full classification.

## 4. Tropical Perron–Frobenius Theorem

The classical Perron–Frobenius theorem states that an irreducible non-negative matrix has a unique maximal eigenvalue with a positive eigenvector. The tropical analog: for an irreducible min-plus matrix (the associated digraph is strongly connected), the tropical eigenvalue `λ = min_{k=1..n} tr(A^k)/k` is achieved by a unique eigenvector up to tropical scaling, and this eigenvector has all finite entries. Our `tropical_eigval_2x2_witness` proves existence for n=2; irreducibility (strong connectivity of the 2-vertex digraph with finite entries) should imply the eigenvector entries are all finite.

The key insight is that irreducibility in the tropical setting means every pair of vertices is connected by a finite-weight path, which forces the eigenvector equation `min_j(A_{ij} + x_j) = λ + x_i` to have a unique solution (up to additive constants) by a contraction mapping argument on the tropical projective space. Why now? The infrastructure of `IsTropicalEigenpair` and the case analysis framework scales naturally to larger matrices. The next concrete step is defining irreducibility (`∀ i j, ∃ k, minPlusPow A k i j < ⊤`) and proving the eigenvector has no infinite entries.

## 5. Tropical Determinant and Optimal Assignment

The tropical determinant of an n×n matrix is `tdet(A) = min_{σ ∈ Sₙ} Σᵢ A_{i,σ(i)}`, which is exactly the optimal assignment (Hungarian algorithm) cost. The conjecture: `tdet(A·B) = tdet(A) + tdet(B)` (the tropical determinant is multiplicative, where tropical multiplication of scalars is ordinary addition). This is a non-trivial combinatorial identity relating optimal assignments in a product to the sum of individual optimal assignments.

The key insight is that the minimum over permutations of a sum can be decomposed using the associativity of min-plus multiplication (`minPlus_mul_assoc`): the (σ,τ)-term of the product determinant telescopes through intermediate vertices. Why now? Our formalization of `minPlusMul` and its associativity provides the exact framework. The proof should use `Finset.inf'` over `Equiv.Perm (Fin n)` and the fact that composing two permutations through intermediate sums gives back the full permutation sum — essentially a tropical Cauchy–Binet identity.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Shared
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v12 Depth Requirements -- Speculative Specifier Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Speculative Specifying (Bold Conjectures)**. Target high-risk, high-reward, grand-challenge level research.

### RESEARCH CORE METHODOLOGY:
1. **Grand Challenges**: Formulate bold, surprising, and non-trivial conjectures that challenge existing intuition. Even if a complete proof cannot be achieved in this cycle, outline precise strategies, obstacles, and partial results.
2. **Deep Speculation**: Explore radical connections that seem distant or impossible at first glance. Frame your theorems as seeds for entirely new fields of study.
3. **Long-Term Roadmap**: Dedicate significant intellectual effort to detailing the proof strategies and testable predictions in your future directions, laying out a clear path for future researchers.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
