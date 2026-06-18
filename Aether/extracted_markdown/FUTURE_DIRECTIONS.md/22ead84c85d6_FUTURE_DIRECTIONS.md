# Future Directions

## Synthesis

The width-to-size conversion theorem for tree-like resolution establishes a certified bridge between clause width (a syntactic measure of proof complexity) and proof size (a computational cost measure). The formalized infrastructure — clauseSpaceBound, ClauseCode, allClauses, widthSpectrum — creates a foundation for extending machine-verified lower bounds across proof complexity and into broader areas of complexity theory.

The five directions below form a coherent program: Direction 1 strengthens the PHP bound to exponential, Direction 2 extends to DAG resolution, Direction 3 connects width to memory (space complexity), Direction 4 bridges to random combinatorics, and Direction 5 opens the door to algebraic proof systems. Together, they chart a path toward a comprehensive verified library of lower-bound technology.

---

## Direction 1: Exponential Tree-Resolution Lower Bound for PHP via the Prover-Delayer Game

**Conjecture:** There exists a formalized proof that any tree-resolution refutation of PHP(n+1, n) has size at least 2^(n/2).

**Test:** Formalize the Prover-Delayer game framework in Lean 4. Define the game tree, the Delayer's optimal strategy (assigning fractional weights to pigeons), and the scoring function. Verify that the Delayer can always accumulate Ω(n) points, giving a 2^Ω(n) lower bound on tree size. Test computationally for n ≤ 8 by exhaustive enumeration of all tree-resolution refutations.

**Impact:** This would be the first fully machine-verified exponential lower bound in proof complexity — a landmark result demonstrating that formal verification can reach the frontier of complexity theory.

**Catalog References:** `Computation/ProofComplexity/Resolution.lean` (ResTree, php_width_lower_bound), `Computation/ProofComplexity/WidthToSize.lean` (size_ge_maxWidth_sub_root_width, refutation_size_ge_maxWidth).

**Proof Strategy:** Define a `DelayerStrategy` type that maps partial assignments to pigeon-hole distributions. Prove that for any Prover move (choosing a resolution variable), the optimal Delayer response preserves an invariant relating accumulated score to remaining pigeons. The key lemma is that resolving on variable (i,j) forces the Delayer to either "commit" pigeon i to hole j (gaining 0 points but reducing the problem) or "reject" hole j for pigeon i (gaining 1 point but potentially losing options). The Delayer's scoring grows logarithmically with the number of remaining options, giving an exponential bound.

**Domain Bridges:** Game theory (two-player games), information theory (entropy accumulation), combinatorial optimization (fractional relaxations).

**Lineage:** Builds directly on `php_width_lower_bound` and `php_tree_size_lower_bound` from the current development. Extends the `ResTree` infrastructure with game-theoretic reasoning.

**Ambition:** Grand challenge — would be a paradigm-shifting result in formalized complexity theory.

---

## Direction 2: Width-to-Size Conversion for DAG Resolution

**Conjecture:** The Ben-Sasson-Wigderson bound S ≥ 2^{(w* - w₀)²/n} can be formalized for general (DAG) resolution, yielding exponential lower bounds for formulas with large width gaps.

**Test:** Define a DAG resolution proof system in Lean 4 (allowing clause reuse). Formalize the random restriction method: show that a random partial assignment of ρn variables, where ρ = 1 - w₀/n, simplifies the formula while preserving unsatisfiability with high probability. Verify the width-contraction lemma: restrictions reduce proof width. Test by computing exact minimum DAG-resolution proof sizes for small random 3-SAT instances (n ≤ 15) and comparing against the theoretical bound.

**Impact:** Would enable machine-verified exponential lower bounds for a much wider class of formulas than tree-resolution alone.

**Catalog References:** `Computation/ProofComplexity/Resolution.lean` (ResDerives, resolution_sound), `Computation/ProofComplexity/WidthToSize.lean` (clauseSpaceBound, clauseSpaceBound_mono).

**Proof Strategy:** 
1. Define `ResDag` as a DAG structure with shared nodes.
2. Formalize random restrictions as partial assignments ρ : ν →? Bool.
3. Prove the switching lemma: w(F↾ρ ⊢ ⊥) ≤ w(F ⊢ ⊥) - #assigned_vars.
4. Apply Markov's inequality to show the existence of a good restriction.
5. Iterate to reduce width to the initial clause width, counting the size reduction at each step.

**Domain Bridges:** Probability theory (random restrictions), circuit complexity (switching lemmas), communication complexity (partition arguments).

**Lineage:** Extends `ResDerives` to DAG form. Uses `clauseSpaceBound` for counting arguments.

**Ambition:** Solid extension — significant but within established proof patterns.

---

## Direction 3: Clause Space Lower Bounds via Width-Space Connections

**Conjecture:** For the pigeonhole principle PHP(n+1, n), any resolution refutation requires clause space Ω(n). That is, at any point during the proof, at least Ω(n) clauses must be simultaneously "alive" (derived but not yet used).

**Test:** Define clause space as the maximum number of clauses stored simultaneously during a sequential execution of the proof. Formalize the Atserias-Dalmau width-space relationship: Space(F ⊢ ⊥) ≥ w(F ⊢ ⊥) - w(F) + 1. For PHP, this gives Space ≥ n - n + 1 = 1 (trivial for standard encoding). Instead, test via a "narrow PHP" encoding where initial clause width is O(1), giving Space ≥ Ω(n). Computationally verify for n ≤ 6 by exhaustive space-optimal proof search.

**Impact:** Would connect our clause counting infrastructure to memory complexity, relevant to practical SAT solver memory management.

**Catalog References:** `Computation/ProofComplexity/WidthToSize.lean` (allClauses, widthSpectrum, clauseSpaceBound).

**Proof Strategy:** Define a `ProofConfiguration` tracking which clauses are currently available. Show that configurations form a graph where each edge corresponds to a proof step. The space of a proof is the maximum configuration size. Connect to clauseSpaceBound by showing that the configuration must traverse a large portion of the clause space.

**Domain Bridges:** Space complexity, pebbling games, memory management algorithms, graph theory (configuration graphs).

**Lineage:** Uses `allClauses_width_le_maxWidth` and `clauseSpaceBound` as foundations.

**Ambition:** Solid extension — well-motivated by the existing infrastructure.

---

## Direction 4: Width Lower Bounds for Random k-SAT

**Conjecture:** For random 3-SAT at clause density α = 4.27 (near the satisfiability threshold), any resolution refutation has width Ω(n) with high probability, implying exponential size lower bounds.

**Test:** Formalize the Chvátal-Szemerédi width lower bound for random k-SAT: w(F ⊢ ⊥) ≥ cn for unsatisfiable random k-CNF formulas, where c depends on the clause density. Computationally estimate the constant c by computing exact minimum widths for random 3-SAT instances with n ≤ 20 at various densities. Compare against the theoretical prediction.

**Impact:** Would give machine-verified hardness results for random formulas, connecting proof complexity to average-case complexity.

**Catalog References:** `Computation/ProofComplexity/WidthToSize.lean` (clauseSpaceBound_mono, clauseEntropyBound_mono), `Computation/ProofComplexity/Resolution.lean` (resolution_sound, ResDerives).

**Proof Strategy:** The Chvátal-Szemerédi argument uses expansion properties of random bipartite graphs. Formalize the expansion lemma, then show that any narrow refutation would violate expansion. This requires basic probabilistic combinatorics (Lovász Local Lemma or first moment method) for random graphs.

**Domain Bridges:** Random graph theory, probabilistic combinatorics, average-case complexity, satisfiability threshold phenomena.

**Lineage:** Uses the clause counting infrastructure from `clauseSpaceBound`.

**Ambition:** Grand challenge — requires substantial probabilistic formalization.

---

## Direction 5: Degree Lower Bounds for Polynomial Calculus

**Conjecture:** The width-to-size methodology for resolution can be adapted to prove degree lower bounds in the Polynomial Calculus proof system, with a formal "degree-to-size" conversion.

**Test:** Define the Polynomial Calculus proof system in Lean 4 (proofs over polynomial rings with Boolean axioms x² = x). Define degree as the maximum monomial degree appearing in a proof. Formalize the analogue of clauseSpaceBound for bounded-degree polynomials: the number of monomials of degree ≤ d over n variables is ∑_{k≤d} C(n,k). Prove that PC refutations of PHP require degree ≥ n/2. Computationally verify for n ≤ 6 using Gröbner basis computation.

**Impact:** Would extend formalized lower bounds from propositional to algebraic proof systems, a fundamentally different proof paradigm.

**Catalog References:** `Computation/ProofComplexity/Resolution.lean` (phpCNF, php_unsat), `Computation/ProofComplexity/WidthToSize.lean` (clauseSpaceBound, ClauseCode).

**Proof Strategy:** Define `PCProof` as a sequence of polynomial derivation steps (linear combination, multiplication, Boolean axiom application). The degree-to-size argument mirrors the width-to-size argument: bound the number of distinct bounded-degree monomials, show all proof polynomials have bounded degree, and count.

**Domain Bridges:** Commutative algebra (polynomial ideals), algebraic geometry (varieties over F₂), algebraic complexity theory, Gröbner basis computation.

**Lineage:** Conceptually parallel to the resolution development. Uses phpCNF as a test case.

**Ambition:** Grand challenge — requires building algebraic proof system infrastructure from scratch.
