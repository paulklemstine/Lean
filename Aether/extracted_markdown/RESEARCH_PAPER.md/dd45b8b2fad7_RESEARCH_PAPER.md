# Tropical Information Bottleneck Duality: Sharp Phase Transitions via Closure Capacities and Finite Observer Spectra

## Abstract

We establish a rigorous min-plus (tropical) information bottleneck duality theorem that unifies closure-theoretic semantics of representation, operadic compositional complexity of neural architectures, and rate-distortion theory in tropical algebra. The main result proves that under an observer sufficiency condition, the infimum of a capacity-distortion scalarization over an arbitrary (possibly infinite) admissible set equals the minimum over a finite observer spectrum. As corollaries, we obtain piecewise affine structure of the bottleneck function, finite breakpoint sets characterizing phase transitions, upward closure of the certified rate region, and existence of extreme observer minimizers at every trade-off parameter. These results provide a combinatorial foundation for phase transition phenomena in information-constrained systems, with applications to proof complexity thresholds, neural architecture selection, and tropical rate-distortion theory.

**Keywords**: tropical algebra, information bottleneck, rate-distortion duality, phase transitions, piecewise affine functions, closure operators, operadic composition, Pareto optimality

---

## 1. Introduction

The information bottleneck method, introduced by Tishby, Pereira, and Bialek (1999), formalizes the problem of extracting a compressed representation *T* of a source *X* that preserves maximal information about a target *Y*. In its Lagrangian form, the objective minimizes *I(X; T) − β I(T; Y)*, trading compression (low mutual information with the source) against prediction (high mutual information with the target).

Classical treatments rely on entropy and mutual information — smooth, concave functionals defined over probability distributions. In this work, we develop a **tropical** (min-plus) analogue that replaces entropy with capacity, mutual information with distortion, and smooth optimization with piecewise-affine combinatorics. The resulting theory exhibits features familiar from statistical mechanics: the bottleneck function has a finite number of phase transitions (breakpoints) where the optimal strategy switches discontinuously.

Our approach draws on three intellectual traditions:

1. **Lawvere's categorical metric theory** (1973): We model observers as morphisms in an enriched category, with closure capacity as a categorical invariant measuring representational fidelity.

2. **Tropical (idempotent) mathematics** (Litvinov, 2007): The min-plus semiring (ℝ ∪ {+∞}, min, +) replaces the conventional (ℝ, +, ×), turning optimization problems into algebraic computations.

3. **Shannon's rate-distortion theory** (1959): The capacity-distortion trade-off generalizes the classical rate-distortion function to the tropical setting.

The main results are formalized in machine-checked proofs (see @Catalog/Bridges/EMLMachineLearning/TropicalInformationBottleneckDuality.lean).

---

## 2. Definitions and Setup

### 2.1 Observer Spectrum

**Definition 2.1** (Objective). Let *Obs* be a finite set of observers, and let *cap, dist : Obs → R* assign a capacity and distortion to each observer. The **tropical bottleneck objective** at trade-off parameter *β ∈ R* for observer *i* is:

$$\text{obj}(i, \beta) = \text{cap}(i) + \beta \cdot \text{dist}(i)$$

This is the tropical analogue of the Lagrangian *R + βD* in classical rate-distortion theory, where addition plays the role of tropical multiplication and the minimum (taken over observers) plays the role of tropical addition.

**Definition 2.2** (Bottleneck Value). The **bottleneck value function** is:

$$B(\beta) = \min_{i \in Obs} \text{obj}(i, \beta) = \min_{i \in Obs} [\text{cap}(i) + \beta \cdot \text{dist}(i)]$$

As a pointwise minimum of finitely many affine functions of *β*, this is a concave piecewise-affine function — the lower envelope of the observer spectrum.

**Definition 2.3** (Certified Rate Region). The **certified rate region** is the upward closure of the observer spectrum in capacity-distortion space:

$$\mathcal{R} = \{ (c, d) \in R^2 \mid \exists\, i \in Obs,\; \text{cap}(i) \leq c \;\wedge\; \text{dist}(i) \leq d \}$$

### 2.2 Admissible Space and Observer Sufficiency

**Definition 2.4** (Admissible Space). An **admissible space** is a pair *(Adm, Cap, Dist)* where *Adm* is a (possibly infinite) set and *Cap, Dist : Adm → R* assign capacity and distortion to each admissible representation.

**Definition 2.5** (Observer Sufficiency). The observer set *Obs* is **sufficient** for the admissible space if:

1. *Realizability*: Every observer is realized by some admissible point:
   $$\forall\, i \in Obs,\; \exists\, z \in Adm,\; Cap(z) = \text{cap}(i) \wedge Dist(z) = \text{dist}(i)$$

2. *Domination*: Every admissible point is dominated by some observer:
   $$\forall\, z \in Adm,\; \exists\, i \in Obs,\; \text{cap}(i) \leq Cap(z) \wedge \text{dist}(i) \leq Dist(z)$$

Observer sufficiency is the key structural hypothesis. It asserts that the finite observer spectrum captures all the essential trade-offs present in the infinite admissible space.

---

## 3. Main Results

### 3.1 Bottleneck Realization (Theorem 1)

**Theorem 3.1** (Bottleneck Realization). *For every β, the bottleneck value B(β) is attained by some observer i ∈ Obs:*

$$\exists\, i \in Obs,\; B(\beta) = \text{cap}(i) + \beta \cdot \text{dist}(i)$$

*Proof sketch.* This is an immediate consequence of the finite-set minimum principle: a minimum over a nonempty finite set is attained. In the formalization, this follows from `exists_mem_eq_inf'` applied to the finset `Obs`. ∎

**Corollary 3.2** (Slope Containment). At every *β*, the slope of the bottleneck function (viewed as the active distortion) belongs to the finite set *{dist(i) : i ∈ Obs}*. See `slopes_subset_distortion_spectrum` in the formalization.

The significance of this result is foundational: it ensures that the bottleneck optimization is always solvable, never requiring limit arguments or approximation sequences. The optimal observer exists, not just as an infimum, but as an achieved minimum. This distinguishes the tropical setting from the classical one, where the rate-distortion function's infimum may not be attained in general measure-theoretic settings.

### 3.2 Piecewise Affine Structure (Theorem 2)

**Theorem 3.3** (Piecewise Affine Structure). *For every β, there exist m ∈ {dist(i)} and b ∈ {cap(i)} such that B(β) = b + β · m.*

*Proof sketch.* By Theorem 3.1, the minimum is realized at some observer *i*. Setting *m = dist(i)* and *b = cap(i)* yields the result. The formalization constructs the witness explicitly using `mem_image`. ∎

This theorem establishes that the bottleneck function is a piecewise affine function of *β* with finitely many pieces. Each piece corresponds to a "phase" in which a single observer dominates the trade-off.

### 3.3 Scalarization Monotonicity (Theorem 3)

**Theorem 3.4** (Scalarization Monotonicity). *If observer i dominates observer j (i.e., cap(i) ≤ cap(j) and dist(i) ≤ dist(j)) and β ≥ 0, then obj(i, β) ≤ obj(j, β).*

*Proof sketch.* Since *β ≥ 0* and *dist(i) ≤ dist(j)*, we have *β · dist(i) ≤ β · dist(j)*. Adding *cap(i) ≤ cap(j)* yields the result. ∎

This monotonicity is the mechanism by which the Pareto structure of the observer spectrum governs the bottleneck. Non-Pareto-optimal observers are dominated and can never achieve the minimum for any *β ≥ 0*.

**Remark.** The constraint *β ≥ 0* is essential. For negative *β* (which would correspond to rewarding distortion rather than penalizing it), the monotonicity reverses, and dominated observers can become optimal. The non-negativity of *β* is thus a physical constraint reflecting the fact that distortion is a cost, not a benefit.

### 3.4 Main Duality Theorem (Theorem 4)

**Theorem 3.5** (Tropical Bottleneck Duality). *Under observer sufficiency, for all β ≥ 0:*

$$\min_{i \in Obs} [\text{cap}(i) + \beta \cdot \text{dist}(i)] = \inf_{z \in Adm} [Cap(z) + \beta \cdot Dist(z)]$$

*Proof sketch.* The proof proceeds by `le_antisymm`:

**Direction 1** (≤): For any admissible *z*, domination gives an observer *i* with *cap(i) ≤ Cap(z)* and *dist(i) ≤ Dist(z)*. By scalarization monotonicity, *obj(i, β) ≤ Cap(z) + β · Dist(z)*. Since the finite minimum is ≤ *obj(i, β)*, the finite minimum is a lower bound for the infimum.

**Direction 2** (≥): For each observer *i*, realizability gives an admissible *z* with matching capacity and distortion. Hence *Cap(z) + β · Dist(z) = cap(i) + β · dist(i)*, placing the observer's value in the image set. The infimum of a set is ≤ any of its elements, so *inf ≤ obj(i, β)* for all *i*, giving *inf ≤ min*. ∎

This is the central result. It reduces an infinite-dimensional optimization (over *Adm*) to a finite computation (over *Obs*). The duality is exact — not merely a bound — and holds for all non-negative trade-off parameters simultaneously.

**Remark on the proof structure.** The proof is constructive in both directions. The forward direction (≤) uses domination to bound each admissible point from below by some observer's objective. The reverse direction (≥) uses realizability to exhibit, for each observer, an admissible point achieving the same objective value. The `le_antisymm` combining these directions yields equality. Notably, the proof requires the admissible set to be nonempty and the image to be bounded below — both of which are established from the hypotheses.

**Remark on generality.** The theorem is stated over an arbitrary `ConditionallyCompleteLinearOrder` with a `Semiring` and `IsOrderedRing` structure. This means it applies not only to ℝ but to ℚ, ℤ, and any other ordered semiring satisfying these conditions. The generality is deliberate: it allows the framework to be instantiated in both continuous and discrete settings.

### 3.5 Extreme Observer Minimizer (Theorem 5)

**Theorem 3.6** (Extreme Observer Minimizer). *At every β, there exists an observer i ∈ Obs that achieves the minimum objective among all observers:*

$$\exists\, i \in Obs,\; \forall\, j \in Obs,\; \text{obj}(i, \beta) \leq \text{obj}(j, \beta)$$

*Proof sketch.* This follows from `exists_min_image` — a finite nonempty set always has a minimum element under any linear-order-valued function. ∎

The extreme observer minimizer identifies the Pareto-optimal architecture (in the neural operad interpretation) or the optimal proof strategy (in the proof complexity interpretation) at each trade-off parameter.

**Remark.** While the existence of a minimizer follows from elementary finite-set theory, the theorem's significance lies in its role within the larger framework: it guarantees that at every trade-off parameter, there is a *single* observer that simultaneously minimizes the objective relative to all other observers. Combined with the piecewise affine structure, this implies that the phase diagram partitions the β-axis into intervals, each governed by a single extreme observer.

### 3.6 Rate Region Properties (Theorems 6–7)

**Theorem 3.7** (Admissible Pair in Rate Region). *Under observer sufficiency, for every admissible z ∈ Adm, the pair (Cap(z), Dist(z)) lies in the certified rate region.*

**Theorem 3.8** (Upward Closure). *The certified rate region is upward closed: if (c, d) ∈ R and c ≤ c', d ≤ d', then (c', d') ∈ R.*

*Proof sketch.* Both follow directly from the definitions: Theorem 3.7 uses domination to find a witnessing observer, and Theorem 3.8 chains the ordering transitively. ∎

### 3.7 Finite Breakpoints (Theorem 8)

**Theorem 3.9** (Finite Breakpoints). *The set of breakpoints — values of β where two distinct observers with different distortions achieve equal objectives — is finite.*

*Proof sketch.* At a breakpoint, *cap(i) + β · dist(i) = cap(j) + β · dist(j)* with *dist(i) ≠ dist(j)*. Solving for *β* gives *β = (cap(j) − cap(i)) / (dist(i) − dist(j))*, a unique value for each pair *(i, j)*. The set of breakpoints is thus contained in the image of the finite set *Obs × Obs* under a fixed function, hence finite. ∎

---

## 4. Phase Transition Interpretation

### 4.1 The Bottleneck Phase Diagram

The piecewise affine structure of *B(β)* defines a natural phase diagram. Each affine piece — an interval between consecutive breakpoints — corresponds to a **phase** in which a single observer is optimal. At a breakpoint *β**, two observers tie and a **first-order phase transition** occurs: the slope of *B(β)* (the effective distortion) changes discontinuously.

The finite breakpoint theorem guarantees that the phase diagram has finitely many phases. The extreme observer minimizer theorem identifies the phase at each *β*. The scalarization monotonicity theorem ensures that dominated observers never define a phase.

### 4.2 Connection to Random Theory Thresholds

The framework suggests a statistical-mechanics theory of provability. In a formal logical system, consider:
- **Observers** = proof strategies (specific rule applications)
- **Capacity** = information preserved by a proof step
- **Distortion** = logical gap bridged by the step
- **β** = clause density in a random theory

The duality theorem predicts that the provability threshold in random formal theories should be governed by a finite set of "extreme proof strategies," with phase transitions at critical clause densities where one strategy supersedes another. The piecewise affine structure implies sharp (not smooth) thresholds.

### 4.3 Neural Architecture Selection

In deep learning, the operad structure assigns:
- **Observers** = layer compositions (architectures)
- **Capacity** = representational capacity of the architecture
- **Distortion** = approximation error

The extreme observer minimizer identifies Pareto-optimal architectures at each capacity-distortion trade-off. The breakpoints correspond to critical model sizes where the optimal architecture type changes — e.g., from a shallow wide network to a deep narrow one.

---

## 5. Algorithms

### 5.1 Bottleneck Computation

The bottleneck computability theorem (`bottleneck_computable`) establishes that *B(β)* is definitionally equal to the finset infimum — no optimization oracle or iterative algorithm is needed. For *n = |Obs|* observers, *B(β)* is computed in *O(n)* time by evaluating *cap(i) + β · dist(i)* for each observer and taking the minimum.

### 5.2 Breakpoint Enumeration

Breakpoints are computed by solving *cap(i) + β · dist(i) = cap(j) + β · dist(j)* for all pairs *(i, j)* with *dist(i) ≠ dist(j)*, yielding *β = (cap(j) − cap(i)) / (dist(i) − dist(j))*. This requires *O(n²)* pair evaluations. The sorted breakpoint sequence defines the full phase diagram.

### 5.3 Rate Region Construction

The certified rate region is constructed as the upward closure of the finite point set *{(cap(i), dist(i)) : i ∈ Obs}*. Its Pareto frontier — the lower-left boundary — is computed in *O(n log n)* time by sorting observers by capacity and retaining those with strictly decreasing distortion.

---

## 6. Computational Complexity

The tropical bottleneck framework admits efficient algorithms for all its key operations.

**Bottleneck evaluation.** Given *n = |Obs|* observers and a parameter *β*, computing *B(β)* requires *O(n)* time — simply evaluate each objective and take the minimum. The `bottleneck_computable` theorem confirms that no optimization oracle is needed; the bottleneck is definitionally equal to the finset infimum.

**Phase diagram construction.** The complete phase diagram requires:
1. Breakpoint enumeration: *O(n²)* pair comparisons, each yielding a candidate breakpoint.
2. Sorting: *O(n² log n)* to order breakpoints.
3. Phase identification: *O(n²)* sweeps to determine which observer is optimal in each interval.

Total complexity: *O(n² log n)*, dominated by sorting.

**Pareto frontier extraction.** The non-dominated observers are found in *O(n log n)* time by sorting by capacity and scanning for strictly decreasing distortion. Only Pareto-optimal observers can appear in the phase diagram, so computing the frontier first reduces subsequent work.

**Rate region membership.** Testing whether a point *(c, d)* lies in the certified rate region requires *O(n)* comparisons — check if any observer dominates *(c, d)*.

**Duality gap verification.** The duality theorem guarantees zero gap, but in practice, verifying this numerically for a given admissible set of size *m* requires *O(n + m)* time per *β* value.

---

## 7. Discussion

### 6.1 Relationship to Classical Rate-Distortion Theory

The tropical bottleneck duality is the min-plus analogue of the classical rate-distortion theorem. In Shannon's theory, the rate-distortion function *R(D)* is the infimum of mutual information *I(X; T)* subject to *E[d(X, T)] ≤ D*. The Lagrangian form *R(D) = inf_T [I(X;T) + β E[d(X,T)]]* has a smooth, convex structure governed by Gibbs distributions.

In the tropical setting, the smooth convex structure is replaced by piecewise affine concave structure — the lower envelope of finitely many affine functions. Phase transitions in the tropical theory are the analogues of first-order phase transitions in statistical mechanics, where the optimal Gibbs distribution changes discontinuously.

### 6.2 Relationship to Lawvere's Metric Duality

Lawvere (1973) observed that metric spaces are categories enriched over ([0,∞], ≥, +), the opposite of the tropical semiring. Our closure capacity generalizes Lawvere's enriched-categorical distance: the capacity of an observer measures the "distance" it induces in the enriched category of representations. The observer sufficiency condition is a categorical analogue of the statement that the observer spectrum is cofinal in the admissible category.

### 6.3 Strengths and Limitations

**Strengths**: The framework is fully constructive (finite observers, explicit computations), general (parametric over any ordered semiring *R*), and machine-verified. The duality is exact, not approximate.

**Limitations**: The observer sufficiency condition must be verified externally — it is a structural hypothesis, not a consequence of the framework. In applications to neural architectures, identifying the observer spectrum requires domain-specific analysis. The tropical theory captures the combinatorial skeleton of rate-distortion trade-offs but does not recover the measure-theoretic content of Shannon's theory.

---

### 7.4 Extensions to Weighted Observers

The current framework treats all observers equally. A natural extension assigns weights (multiplicities) to observers, modeling the relative abundance or probability of each strategy. The weighted bottleneck becomes a weighted minimum, and the phase diagram may exhibit degenerate breakpoints where multiple observers tie simultaneously.

---

## 8. Future Work

1. **Probabilistic sharp thresholds**: Formalize Friedgut's sharp threshold theorem and apply it to prove that derivability in random implicational theories exhibits a sharp phase transition, leveraging the monotonicity infrastructure established here.

2. **Proof length transitions**: Investigate whether the existence of polynomial-length proofs in random theories exhibits a separate phase transition, connecting to resolution complexity lower bounds.

3. **Multi-premise generalization**: Extend from single-conclusion implications to *k*-ary hypergraph reachability, where the phase transition behavior should parallel the *k*-SAT threshold phenomenon.

4. **Continuous tropical geometry**: Replace the finite observer spectrum with a compact observer space and develop a continuous analogue of the duality using tropical convex analysis.

---

---

## 9. Conclusion

We have established a rigorous tropical information bottleneck duality that reduces infinite-dimensional capacity-distortion optimization to finite computation over an observer spectrum. The theory yields a complete combinatorial description of the bottleneck function: piecewise affine with finitely many phases, separated by computable breakpoints that mark first-order phase transitions. The certified rate region provides a geometric characterization of achievable performance.

The framework is parametric over any ordered semiring, making it applicable across domains: from neural architecture selection (where observers are layer compositions) to proof complexity (where observers are proof strategies) to classical rate-distortion theory (where observers are codebook entries). The machine-verified proofs ensure correctness of all results.

The central insight is that observer sufficiency — the condition that every point in the infinite admissible space is dominated by some finite observer — is the structural key that enables the duality. When this condition holds, the combinatorial structure of the finite observer spectrum completely determines the geometry of the optimization landscape.

---

## References

1. Shannon, C.E. (1959). Coding theorems for a discrete source with a fidelity criterion. *IRE National Convention Record*, Part 4, 142–163.

2. Litvinov, G.L. (2007). Maslov dequantization, idempotent and tropical mathematics: a brief introduction. *Journal of Mathematical Sciences*, 140(3), 349–386.

3. Lawvere, F.W. (1973). Metric spaces, generalized logic, and closed categories. *Rendiconti del Seminario Matematico e Fisico di Milano*, 43, 135–166.

4. Tishby, N., Pereira, F.C., & Bialek, W. (1999). The information bottleneck method. *Proceedings of the 37th Annual Allerton Conference on Communication, Control, and Computing*, 368–377.

5. Friedgut, E. (1999). Sharp thresholds of graph properties, and the *k*-SAT problem. *Journal of the American Mathematical Society*, 12(4), 1017–1054.

6. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, Vol. 161. American Mathematical Society.

---

## Appendix: Formalization Reference

All theorems in this paper correspond to machine-verified statements in the file:

`@Catalog/Bridges/EMLMachineLearning/TropicalInformationBottleneckDuality.lean`

| Paper Theorem | Formal Name | Section |
|---|---|---|
| Theorem 3.1 | `bottleneck_realized_by_observer` | B |
| Corollary 3.2 | `slopes_subset_distortion_spectrum` | B |
| Theorem 3.3 | `bottleneck_piecewise_affine` | B |
| Theorem 3.4 | `objective_mono_of_dominates` | C |
| Theorem 3.5 | `bottleneck_eq_min_over_observers` | D |
| Theorem 3.6 | `exists_extreme_observer_minimizer` | B |
| Theorem 3.7 | `admissible_pair_in_rate_region` | E |
| Theorem 3.8 | `certifiedRateRegion_upward_closed` | E |
| Theorem 3.9 | `finite_breakpoints` | G |
