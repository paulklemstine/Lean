
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


## Concept

**Title**: The tropical analogue of eigenvalues — values λ such that A ⊗ x = λ ⊗ x in the t
**Domain**: Computation
**Mathematical framing**: # Future Directions: Tropical Phase Transition Thresholds

## 1. Tropical Spectral Theory and Eigenvalue Phase Transitions

The tropical analogue of eigenvalues — values λ such that A ⊗ x = λ ⊗ x in the tropical semiring — exhibits a remarkable phase transition structure. For tropical matrices with entries drawn from random distributions, the critical cycle mean (the tropical eigenvalue) undergoes a sharp transition as the matrix density crosses a threshold, analogous to the giant component transition in random graphs.

The key insight is that tropical eigenvalues are determined by the maximum cycle mean in the associated directed graph, which connects graph connectivity thresholds to algebraic spectral transitions. Why now? Our formalization of `tropical_sum_eq_trop_inf'` and `tropical_threshold_dichotomy` provides the algebraic foundation for characterizing when cycle means achieve their critical values. The next step is formalizing tropical matrix powers A^k and proving that the sequence trop_trace(A^k)/k converges to the tropical spectral radius, with a sharp transition in the number of cycles achieving the maximum.

## 2. Tropical Convexity and Hyperplane Arrangement Complexity

The sub-level closure theorem (`tropical_sublevel_closed`) opens the door to a full theory of tropical convexity. A tropical polytope — the tropical convex hull of finitely many points — has a combinatorial type determined by which "phase" each face is in (i.e., which term achieves the minimum). The conjecture is that the number of distinct combinatorial types of tropical polytopes with n vertices in dimension d exhibits a phase transition at d ≈ log n, below which all polytopes are "simple" (each vertex has a unique minimizer) and above which exponentially many combinatorial types appear.

The key insight is that tropical convexity is equivalent to min-plus convexity, and the combinatorial explosion of face types is governed by the same threshold phenomena we formalized in `tropical_threshold_dichotomy`. Why now? The algebraic infrastructure for tropical sums as infima and the witness theorem provides the correct language for counting face types. Formalizing the tropical Carathéodory theorem (every point in the tropical convex hull of S lies in the tropical convex hull of at most d+1 points from S) would be the next concrete target.

## 3. Tropical Bellman-Ford Convergence and Shortest-Path Phase Transitions

The idempotent iteration theorem (`tropical_idempotent_nsmul`) generalizes to tropical matrix powers: for an n×n tropical matrix A, the sequence A, A^2, A^3, ... stabilizes at A^(n-1) (if no negative cycles exist). This is exactly the Bellman-Ford algorithm. The conjecture is that for random tropical matrices with entry distribution parameterized by density ρ, the stabilization time undergoes a sharp threshold: for ρ < ρ_c the matrix power stabilizes in O(1) steps, while for ρ > ρ_c it requires Θ(n) steps, with the transition governed by the emergence of long shortest paths.

The key insight is that stabilization time equals the longest shortest path (the diameter of the implicit weighted graph), which has a known phase transition in random graph theory. Why now? Our formalization of tropical idempotent iteration provides the algebraic framework for reasoning about stabilization, and the parameterized phase transition theorems give the tools for formalizing the sharp threshold. The next step is defining tropical matrix multiplication and proving A^n = A^(n-1) for matrices without negative cycles.

## 4. Tropical Proof Complexity and Resource Thresholds

The original motivation for this work: can tropical algebra formalize phase transitions in proof search? The conjecture is that for a natural ensemble of tropical optimization problems of size n (e.g., random tropical linear programs), the probability of finding a feasible solution undergoes a sharp threshold at a critical constraint density ρ_c = 1, and moreover, the "proof" of feasibility (a witness point) has size that diverges as ρ → ρ_c from below, analogous to resolution proof complexity near the SAT threshold.

The key insight is that `tropical_sum_witness` gives a constructive witness for every tropical sum, but the number of potential witnesses grows combinatorially, and near the threshold, the witnesses become highly constrained. Why now? Our framework provides the first formalized connection between tropical algebraic operations and combinatorial witness structures. The next step is defining tropical linear feasibility (does x exist such that A ⊗ x ≤ b in the tropical sense?) and characterizing the feasibility boundary.

## 5. Tropical Entropy and Information-Theoretic Phase Transitions

Define the "tropical entropy" of a finite tropical sum ∑ᵢ trop(aᵢ) as the logarithm of the number of indices i that are "near-optimal" (within ε of the minimum). As ε → 0, this quantity drops to log(k) where k is the number of exact minimizers. The conjecture is that for random i.i.d. entries aᵢ, the expected tropical entropy exhibits a phase transition at ε_c = Θ(1/n) from logarithmic growth (many near-minimizers) to constant (unique minimizer).

The key insight is that `tropical_threshold_dichotomy` shows the transition between "a wins" and "b wins" is sharp — but with noise, multiple terms can be near the minimum simultaneously, creating an entropy landscape. Why now? Our formalization of the witness theorem and the parameterized threshold gives the exact framework for counting near-minimizers. The next step is defining the ε-witness set {i ∈ s : f(i) ≤ inf'(f) + ε} and proving it shrinks to a singleton as ε → 0, with a rate depending on the gap structure.

**Concept description**: # Future Directions: Tropical Phase Transition Thresholds

## 1. Tropical Spectral Theory and Eigenvalue Phase Transitions

The tropical analogue of eigenvalues — values λ such that A ⊗ x = λ ⊗ x in the tropical semiring — exhibits a remarkable phase transition structure. For tropical matrices with entries drawn from random distributions, the critical cycle mean (the tropical eigenvalue) undergoes a sharp transition as the matrix density crosses a threshold, analogous to the giant component transition in random graphs.

The key insight is that tropical eigenvalues are determined by the maximum cycle mean in the associated directed graph, which connects graph connectivity thresholds to algebraic spectral transitions. Why now? Our formalization of `tropical_sum_eq_trop_inf'` and `tropical_threshold_dichotomy` provides the algebraic foundation for characterizing when cycle means achieve their critical values. The next step is formalizing tropical matrix powers A^k and proving that the sequence trop_trace(A^k)/k converges to the tropical spectral radius, with a sharp transition in the number of cycles achieving the maximum.

## 2. Tropical Convexity and Hyperplane Arrangement Complexity

The sub-level closure theorem (`tropical_sublevel_closed`) opens the door to a full theory of tropical convexity. A tropical polytope — the tropical convex hull of finitely many points — has a combinatorial type determined by which "phase" each face is in (i.e., which term achieves the minimum). The conjecture is that the number of distinct combinatorial types of tropical polytopes with n vertices in dimension d exhibits a phase transition at d ≈ log n, below which all polytopes are "simple" (each vertex has a unique minimizer) and above which exponentially many combinatorial types appear.

The key insight is that tropical convexity is equivalent to min-plus convexity, and the combinatorial explosion of face types is governed by the same threshold phenomena we formalized in `tropical_threshold_dichotomy`. Why now? The algebraic infrastructure for tropical sums as infima and the witness theorem provides the correct language for counting face types. Formalizing the tropical Carathéodory theorem (every point in the tropical convex hull of S lies in the tropical convex hull of at most d+1 points from S) would be the next concrete target.

## 3. Tropical Bellman-Ford Convergence and Shortest-Path Phase Transitions

The idempotent iteration theorem (`tropical_idempotent_nsmul`) generalizes to tropical matrix powers: for an n×n tropical matrix A, the sequence A, A^2, A^3, ... stabilizes at A^(n-1) (if no negative cycles exist). This is exactly the Bellman-Ford algorithm. The conjecture is that for random tropical matrices with entry distribution parameterized by density ρ, the stabilization time undergoes a sharp threshold: for ρ < ρ_c the matrix power stabilizes in O(1) steps, while for ρ > ρ_c it requires Θ(n) steps, with the transition governed by the emergence of long shortest paths.

The key insight is that stabilization time equals the longest shortest path (the diameter of the implicit weighted graph), which has a known phase transition in random graph theory. Why now? Our formalization of tropical idempotent iteration provides the algebraic framework for reasoning about stabilization, and the parameterized phase transition theorems give the tools for formalizing the sharp threshold. The next step is defining tropical matrix multiplication and proving A^n = A^(n-1) for matrices without negative cycles.

## 4. Tropical Proof Complexity and Resource Thresholds

The original motivation for this work: can tropical algebra formalize phase transitions in proof search? The conjecture is that for a natural ensemble of tropical optimization problems of size n (e.g., random tropical linear programs), the probability of finding a feasible solution undergoes a sharp threshold at a critical constraint density ρ_c = 1, and moreover, the "proof" of feasibility (a witness point) has size that diverges as ρ → ρ_c from below, analogous to resolution proof complexity near the SAT threshold.

The key insight is that `tropical_sum_witness` gives a constructive witness for every tropical sum, but the number of potential witnesses grows combinatorially, and near the threshold, the witnesses become highly constrained. Why now? Our framework provides the first formalized connection between tropical algebraic operations and combinatorial witness structures. The next step is defining tropical linear feasibility (does x exist such that A ⊗ x ≤ b in the tropical sense?) and characterizing the feasibility boundary.

## 5. Tropical Entropy and Information-Theoretic Phase Transitions

Define the "tropical entropy" of a finite tropical sum ∑ᵢ trop(aᵢ) as the logarithm of the number of indices i that are "near-optimal" (within ε of the minimum). As ε → 0, this quantity drops to log(k) where k is the number of exact minimizers. The conjecture is that for random i.i.d. entries aᵢ, the expected tropical entropy exhibits a phase transition at ε_c = Θ(1/n) from logarithmic growth (many near-minimizers) to constant (unique minimizer).

The key insight is that `tropical_threshold_dichotomy` shows the transition between "a wins" and "b wins" is sharp — but with noise, multiple terms can be near the minimum simultaneously, creating an entropy landscape. Why now? Our formalization of the witness theorem and the parameterized threshold gives the exact framework for counting near-minimizers. The next step is defining the ε-witness set {i ∈ s : f(i) ≤ inf'(f) + ε} and proving it shrinks to a singleton as ε → 0, with a rate depending on the gap structure.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Computation
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
