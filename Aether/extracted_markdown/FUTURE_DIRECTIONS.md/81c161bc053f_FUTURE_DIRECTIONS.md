# Future Directions: Closure-Stable Probe Reconstruction

## 1. Optimal Probe Families and Defect Halving

**Conjecture**: For any finitary closure operator on a type of cardinality n, there exists a probe refiner R such that `C.defect (R.refine s) ≤ C.defect s / 2` for every non-closed s. This would give O(log n) reconstruction steps instead of the O(n) worst case established in `iterate_reaches_closure`.

The key insight is that the single-element refiner achieves the worst case of exactly `defect(s)` steps, while the canonical refiner (full closure) achieves 1 step. A halving refiner would interpolate, and its existence would connect to information-theoretic lower bounds on probe complexity — each step should eliminate at least half the remaining "uncertainty" (defect).

**Why now?** The defect_decrease theorem provides the strict decrease infrastructure. Extending it to quantitative bounds requires only a strengthened strictness condition on the refiner, which the existing ProbeRefiner structure can accommodate with an additional field.

## 2. Galois Connection Between Probe Families and Closure Operators

**Conjecture**: There is a Galois insertion between the poset of "complete probe families" (ordered by refinement) and the poset of closure operators (ordered by pointwise inclusion), mediated by the map sending a probe family to the closure operator it generates, and the map sending a closure operator to its maximal complete probe family.

The key insight is that `fixedpoint_iff_closed` already establishes a bijection between fixed points and closed sets for a single refiner. Lifting this to the level of probe families should yield a lattice-theoretic correspondence where the closure operator determined by a probe family equals the closure operator whose closed sets are the common fixed points of all probes.

**Why now?** The `ProbeComplete` definition and `fixedpoint_iff_closed` theorem provide the two directions. The missing piece is showing that the map ProbeFamily → ClosureOperator is left adjoint to ClosureOperator → MaximalProbeFamily, which requires formalizing the order structures on both sides.

## 3. Compositional Probe Refinement for Product Closures

**Conjecture**: If C₁ and C₂ are closure operators on α and β respectively, and R₁, R₂ are probe refiners for them, then the product refiner R₁ × R₂ on α × β is a valid probe refiner for the product closure C₁ × C₂, and `defect_{C₁×C₂}(R₁×R₂(s)) ≤ defect_{C₁}(π₁(s)) + defect_{C₂}(π₂(s))`.

The key insight is that product closures decompose the defect additively, so the reconstruction algorithm on products can be decomposed into independent reconstruction on each component. This would yield a "divide and conquer" reconstruction principle: complex closure operators that factor as products can be reconstructed in parallel.

**Why now?** The FinClosureOp and ProbeRefiner structures are generic enough to instantiate on product types. The main technical challenge is relating the defect of a product set to the defects of its projections, which requires understanding how Finset products interact with sdiff.

## 4. Probe Reconstruction as Shortest Path in the Closed-Set Lattice

**Conjecture**: The reconstruction sequence s, R(s), R²(s), ..., cl(s) corresponds to a shortest path in a weighted graph whose vertices are the elements of the interval [s, cl(s)] in the subset lattice and whose edges connect sets differing by one element, weighted by the "probe cost" of detecting that element.

The key insight is that defect_decrease shows each step moves strictly closer to cl(s) in the lattice, and the potential function `defect` is a lattice-theoretic distance. Making this connection precise would bridge the reconstruction algorithm to Dijkstra's algorithm as formalized in the catalog's `InfoEfficientAlgorithms.lean`, creating a genuine three-way bridge: closure theory ↔ probe dynamics ↔ shortest-path computation.

**Why now?** Both the reconstruction algorithm (this file) and Dijkstra's algorithm (catalog) are formalized as `InfoEfficientAlgorithm` instances with potential-based termination. The bridge requires showing that the reconstruction state space embeds into a weighted graph where Dijkstra's optimality theorem applies.

## 5. Randomized Probe Selection and Expected Defect Decrease

**Conjecture**: If at each step we select a probe uniformly at random from a complete probe family of size k, the expected defect decrease per step is at least defect(s)/k, giving an expected O(k · ln(defect(s))) convergence time by a coupon-collector argument.

The key insight is that completeness guarantees every element of cl(s) \ s is "witnessed" by at least one probe, so a random probe has probability at least 1/k of adding any given missing element. This converts the deterministic worst-case bound of `defect(s)` steps into a randomized O(k log n) expected bound, which is better when k is small relative to n.

**Why now?** The deterministic framework is complete. Adding probabilistic analysis requires formalizing expected values over finite probability spaces (available in Mathlib via `MeasureTheory.ProbabilityMeasure`) and connecting them to the defect potential. The coupon-collector bound `E[T] ≤ n·H_n` is a standard result that could be formalized as a standalone lemma.
