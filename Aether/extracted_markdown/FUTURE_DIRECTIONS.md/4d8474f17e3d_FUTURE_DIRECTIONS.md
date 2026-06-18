# Future Directions

## [Tropical Carathéodory Compression]

**Conjecture:** For every `n : ℕ`, every point in the tropical convex hull of a finite subset of `Fin n → ℝ` (defined as the closure under tropical combinations `fun i => min (a + x i) (b + y i)`) lies in the tropical convex hull of some subfamily of cardinality at most `n + 1`.

**Why it matters:** The classical Carathéodory theorem is the foundation of the entire Carathéodory → Radon → Helly implication chain. A formal tropical Carathéodory theorem would enable a clean, conceptual proof of the tropical Helly theorem (replacing ad hoc arguments with structural theory) and would open the door to tropical analogs of linear programming duality, where optimal solutions are determined by a bounded number of active constraints.

**Test:** Formalize the tropical convex hull for `n = 2, 3` over rational coefficients. Enumerate all tropical combinations of 4-5 points in dimension 2 and verify that each lies in the tropical hull of at most 3 of them. Attempt a general inductive proof by projecting along one coordinate and applying the lower-dimensional result.

---

## [Minimal Infeasible Tropical Systems]

**Conjecture:** Every minimal infeasible finite family of tropical halfspaces in `Fin n → ℝ` has cardinality at most `2n + 1`. Moreover, for the special case of difference constraints (`x_i - x_j ≤ w`), the bound improves to `n`, and the minimal infeasible subsystem forms a negative-weight cycle in the constraint graph.

**Why it matters:** This conjecture gives the tight Helly number for tropical halfspaces and provides a structural characterization of infeasibility certificates. For difference constraints, it connects the Helly theorem directly to the Bellman-Ford algorithm, establishing that negative-cycle detection is not just an algorithm but a manifestation of a deep compression principle.

**Test:** Implement a brute-force search over systems of 5-10 tropical halfspaces in dimensions 2-4 with rational coefficients. For each infeasible system, find the minimal infeasible subsystem and track its size. Compare against the conjectured bounds. For difference constraints, verify that every minimal infeasible subsystem is indeed a simple negative cycle.

---

## [Tropical LP Witness Attainment]

**Conjecture:** Every feasible bounded tropical linear program in dimension `n` — defined as minimizing `max_k (c_k + x_{i_k})` subject to tropical halfspace constraints — admits an optimal solution determined by at most `n + 1` active tropical constraints. The active constraints form a tropical basic feasible solution analogous to the vertices of classical linear programming polytopes.

**Why it matters:** This would establish the foundation for a certified tropical simplex method, where optimization proceeds by moving between tropical basic feasible solutions. Combined with the Helly theorem (which provides feasibility certificates), this would give a complete framework for certified tropical linear programming — a critical tool for verified scheduling, shortest-path optimization, and min-plus constraint solving.

**Test:** Define a finite tropical LP model in dimensions 2 and 3. Enumerate feasible solutions for small instances with rational data. For each optimal solution, identify the set of active constraints and verify that at most `n + 1` are needed. Implement a tropical simplex pivot rule and test convergence on random instances.

---

## [Tropical Radon Implies Helly]

**Conjecture:** A formal tropical Radon theorem — stating that any set of `2n + 2` points in tropical `ℝ^n` can be partitioned into two groups whose tropical convex hulls intersect — implies the tropical Helly theorem via the classical implication chain adapted to tropical convexity. Specifically, the proof requires only: (1) tropical Radon, (2) tropical convexity is preserved under intersection, and (3) standard finite set combinatorics.

**Why it matters:** The Carathéodory-Radon-Helly chain is one of the most elegant structural patterns in combinatorial geometry. Establishing this chain in the tropical setting would unify the tropical convexity theory into a single coherent framework, rather than requiring separate ad hoc proofs for each result. It would also identify the precise Helly number (which depends on the Radon partition number) and could reveal whether tropical geometry has a richer or more restrictive combinatorial structure than classical geometry.

**Test:** State the tropical Radon theorem as an axiom/hypothesis in a formal proof. Derive the tropical Helly theorem from it using the standard inductive argument (induction on family size, using Radon to close the inductive step). Identify exactly which intermediate lemmas are needed and verify that no additional tropical-specific hypotheses are required beyond Radon and intersection closure.

---

## [Shortest-Path Certificate Compression]

**Conjecture:** Infeasibility of a finite system of min-plus difference constraints (inequalities of the form `x_i ⊕ a ≤ x_j ⊕ b`, equivalently `min(x_i, a) ≤ min(x_j, b)`) admits a witness subsystem of size bounded by `O(n)` in ambient dimension `n`. Furthermore, this witness subsystem can be extracted in polynomial time from a Bellman-Ford-style negative cycle detection, and the extraction procedure produces a certificate that is independently verifiable in `O(n)` time.

**Why it matters:** This conjecture connects the abstract tropical Helly theorem to concrete algorithmic practice. In verified compilation, static analysis, and certified optimization, one needs not just a yes/no feasibility answer but a *certificate* that can be independently checked. The conjecture asserts that such certificates are always small and efficiently extractable, which would enable certified solvers for min-plus constraint systems — a class of problems that includes shortest-path feasibility, timing verification, and mean-payoff game solving.

**Test:** Formalize a restricted difference-constraint fragment (`x_i - x_j ≤ w`) in a proof assistant. Implement Bellman-Ford with negative cycle extraction. For random infeasible systems of size 10-100 in dimensions 3-10, measure the size of the extracted negative cycle and compare against the `n` bound. Implement a certificate verifier that checks the cycle independently and measure verification time. Connect the extraction to the formally proved `negCycle_infeasible` theorem to create an end-to-end certified pipeline.
