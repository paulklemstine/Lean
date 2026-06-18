# Future Directions: Multivariate k-Fold Log-Concavity and M-Convexity

## Synthesis

The theory developed here — multivariate directional log-concavity with its structural consequences for support geometry, tropical duality, and product stability — opens a new interface between three mature mathematical domains: Lorentzian polynomial theory, discrete convex analysis, and higher-order log-concavity hierarchies. The central insight is that a single elementary inequality (the mixed directional condition) simultaneously controls combinatorial exchange structure, tropical convexity, and analytic smoothness depth. The five directions below exploit this insight in progressively more ambitious ways, from concrete extensions building on catalog theorems to paradigm-shifting conjectures that could reshape the foundations of combinatorial optimization and algebraic combinatorics.

---

## Direction 1: Lorentzian Equivalence via Hessian Descent

**Conjecture**: For homogeneous polynomials with positive coefficients, recursive Lorentzianity (in the sense of `IsRecursivelyLorentzian` from `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`) is equivalent to k-fold directional log-concavity of the coefficient function for all k ≤ degree, together with the support exchange property.

**The key insight is** that the Hessian signature condition (at most one positive eigenvalue) for degree-2 derivative leaves is exactly the mixed directional log-concavity inequality applied to the coefficients of those leaves, and the recursive descent through partial derivatives mirrors the k-fold ratio transform hierarchy.

**Test**: Implement the forward direction for degree ≤ 6: given a recursively Lorentzian polynomial, verify computationally that all coefficient-level mixed and axis inequalities hold. Search for a counterexample to the converse among polynomials with positive coefficients and exchange-closed support that fail the Hessian condition. A single explicit counterexample (n ≤ 5, d ≤ 6) would refute the conjecture.

**Impact**: If true, this provides an elementary characterization of Lorentzian polynomials, replacing the spectral machinery of Hessian eigenvalue analysis with simple product inequalities on coefficients. This would make Lorentzianity checkable in O(n² · |support|) time rather than requiring eigenvalue computation.

**Catalog References**: `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (specifically `IsRecursivelyLorentzian`, `recursivelyLorentzian_iff_brandenHuh`, `recursive_certificate_sound`); `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (`KFoldLogConcave`, `kFoldLogConcave_mono`).

**Proof Strategy**: Prove the forward direction by induction on degree. For degree 2, the mixed inequality IS the Hessian condition. For degree d, use `pderiv_coeff_nonneg` to show that partial derivatives preserve coefficient nonnegativity, and show that mixed DLC of the original polynomial implies mixed DLC of its partial derivatives (via a coefficient extraction argument). The converse would require showing that coefficient-level inequalities plus exchange imply the global Hessian condition, likely via the reversed Cauchy-Schwarz (`lorentzian_reversed_cauchy_schwarz`).

**Domain Bridges**: Algebraic geometry (Lorentzian polynomials) ↔ Discrete combinatorics (exchange properties) ↔ Linear algebra (Hessian spectra).

**Lineage**: Extends `recursivelyLorentzian_iff_brandenHuh` and connects to `support_rectangle_closure`.

**Ambition**: Grand challenge — would fundamentally simplify the theory of Lorentzian polynomials.

---

## Direction 2: Valuated Matroid Theory via k-Fold Log-Concavity

**Conjecture**: The k-fold directional log-concavity hierarchy provides a graded refinement of Murota's M-convexity. Specifically, for a function f on a fixed degree slice with exchange-closed support, the depth k at which f ceases to be k-fold directionally log-concave measures the "Lorentzian depth" of the underlying valuated matroid.

**The key insight is** that the ratio transform Rᵢf(m) = f(m+eᵢ)/f(m) is the discrete analog of the logarithmic derivative, and applying it repeatedly extracts finer and finer curvature information from the valuation. The k-fold hierarchy thus provides an intrinsic notion of "smoothness depth" for valuated matroids, analogous to the differentiability class C^k for continuous functions.

**Why now?** The product stability theorem (`mixedLogConcave_mul`, `directionalLogConcave_mul`) shows that the k-fold classes form multiplicative monoids. Combined with the tropical bridge (`negLog_supermodular_of_mixed`), this means k-fold directional log-concavity defines a hierarchy of tropical convexity classes that is preserved under the tropical product. No such hierarchy existed in Murota's theory.

**Test**: Compute the k-fold depth of specific valuated matroids: uniform matroid valuations, graphical matroid valuations (with edge weights), and the Grassmannian valuations from algebraic geometry. Identify the first example where k-fold depth is finite but greater than 1. If all naturally occurring valuated matroids have infinite depth, this would suggest a deep structural theorem.

**Impact**: Would create a new invariant for valuated matroids, potentially distinguishing matroids that are indistinguishable by existing invariants (basis exchange graph structure, Tutte polynomial, etc.).

**Catalog References**: `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (`KFoldLogConcave`, `KFoldLogConcave.ratio`, `kFoldLogConcave_mono`); `Pythagorean/MultivariateLogConcavity.lean` (`KFoldDirectionalLogConcave`, `kfold_mono`, `directionalLogConcave_mul`).

**Proof Strategy**: Define the Lorentzian depth as sup{k : KFoldDirectionalLogConcave k f}. Use the product stability theorem to show this is sub-additive under tropical convolution. Prove that exponential-type functions have infinite depth (already partially established by `exp_type_mixed_logconcave`). Show that graphic matroid valuations have depth at least d-2 using the connection to Kirchhoff's matrix tree theorem.

**Domain Bridges**: Combinatorial optimization (valuated matroids, M-convexity) ↔ Analysis (smoothness hierarchies) ↔ Algebraic geometry (Grassmannian, tropical flag varieties).

**Lineage**: Extends `kfold_mono` and `exp_type_mixed_logconcave`.

**Ambition**: Solid extension with grand-challenge potential.

---

## Direction 3: Negative Dependence and Rapid Mixing via Directional Log-Concavity

**Conjecture**: For a probability distribution μ on {0,1}ⁿ whose generating polynomial satisfies k-fold directional log-concavity (k ≥ 2), the Glauber dynamics Markov chain mixes in time O(n log n), with the mixing time constant depending on k.

**The key insight is** that mixed directional log-concavity is exactly the condition of pairwise negative dependence (the FKG inequality reversed), and the higher-order conditions in the k-fold hierarchy provide increasingly strong spectral gap bounds. The k = 2 condition should imply a spectral gap of Ω(1/n), which by standard Markov chain theory gives O(n log n) mixing.

**Why now?** Anari–Liu–Oveis Gharan–Vinzant (2019) proved rapid mixing for distributions associated with log-concave polynomials, but their proof goes through the complete homogeneous polynomial machinery. Our direct coefficient-level approach via mixed DLC could yield a simpler proof with explicit constants.

**Test**: Simulate Glauber dynamics for canonical partition functions of fermionic systems (tested in `applications.py`) and measure empirical mixing times. Compare mixing time against the k-fold depth of the generating polynomial. If there is a clear correlation (higher k → faster mixing), this provides strong evidence for the conjecture.

**Impact**: Would provide the first direct link between the k-fold hierarchy and algorithmic efficiency, with applications to approximate counting, sampling, and statistical inference.

**Catalog References**: `Catalog/Pythagorean/HigherOrderLogConcavity.lean` (`KFoldLogConcave.mul`, `partitionFunctionCoeff_kFoldLogConcave_of_factorization`); `Pythagorean/MultivariateLogConcavity.lean` (`mixedLogConcave_mul`, `support_rectangle_closure`).

**Proof Strategy**: Use the factored function theorem (`factored_mixed_logconcave`) to reduce to independent site distributions. Show that the product stability of mixed DLC (`mixedLogConcave_mul`) preserves the spectral gap bound under composition. Derive the mixing time bound from the spectral gap using the log-Sobolev inequality approach of Diaconis–Saloff-Coste.

**Domain Bridges**: Probability theory (mixing times, spectral gaps) ↔ Statistical physics (Glauber dynamics, phase transitions) ↔ Computer science (approximate counting, FPRAS).

**Lineage**: Extends `mixedLogConcave_mul` and `factored_mixed_logconcave`.

**Ambition**: Solid extension with immediate algorithmic impact.

---

## Direction 4: Tropical Hodge Theory via Supermodularity Hierarchies

**Conjecture**: The supermodularity hierarchy induced by the tropical bridge (−log of k-fold directional log-concavity) defines a tropical analog of the Hodge filtration on the cohomology of toric varieties. Specifically, the depth k at which −log f ceases to satisfy the iterated supermodularity conditions corresponds to the weight filtration level in tropical Hodge theory.

**The key insight is** that the tropical bridge theorem (`negLog_supermodular_of_mixed` and `exp_neg_supermodular_mixed`) establishes a perfect correspondence between multiplicative log-concavity and additive supermodularity. Iterating this correspondence through the k-fold hierarchy creates a tower of tropical convexity conditions that mirror the Lefschetz decomposition in Hodge theory.

**Why now?** The recent proof of the Hodge-Riemann relations for matroids by Adiprasito–Huh–Katz used the hard Lefschetz property, which in the tropical setting corresponds to a specific supermodularity condition on tropical intersection numbers. Our hierarchy provides a natural graded refinement of this single condition.

**Test**: Compute the tropical supermodularity depth for the tropical Grassmannians Gr(2,n) for n = 4,...,8. Compare with the known Hodge numbers of the corresponding toric varieties. If the depths match, this provides evidence for the correspondence.

**Impact**: Would create the first computational approach to tropical Hodge theory, potentially enabling machine verification of Hodge-theoretic results that are currently proved only by deep analytic methods.

**Catalog References**: `Pythagorean/MultivariateLogConcavity.lean` (`negLog_supermodular_of_mixed`, `exp_neg_supermodular_mixed`, `DiscreteSupermodular`); `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (`IsBrandenHuhLorentzian`, `QuadraticHasLorentzianSignature`).

**Proof Strategy**: Define the tropical Lefschetz operator as the tropicalization of the algebraic Lefschetz operator. Show that the hard Lefschetz property for a Lorentzian polynomial tropicalizes to the supermodularity of −log(coefficient function). Use the k-fold hierarchy to define tropical Hodge numbers. Verify the tropical Hodge-Riemann bilinear relations at each level of the hierarchy.

**Domain Bridges**: Tropical geometry ↔ Algebraic geometry (Hodge theory) ↔ Combinatorics (matroid Chow rings).

**Lineage**: Extends `negLog_supermodular_of_mixed` and connects to `lorentzian_reversed_cauchy_schwarz`.

**Ambition**: Grand challenge — paradigm-shifting if realized.

---

## Direction 5: M-Convex Optimization via Directional Log-Concavity Certificates

**Conjecture**: For optimization problems on M-convex sets (base polyhedra of matroids, integral polymatroids), a directional log-concavity certificate for the objective function guarantees polynomial-time solvability via a simple exchange algorithm, with the convergence rate controlled by the k-fold depth.

**The key insight is** that the rectangle closure theorem (`support_rectangle_closure`) provides a "local-to-global" principle: if the objective function satisfies mixed DLC, then any local improvement via coordinate exchange leads to a global improvement. Combined with the exchange property of the feasible set, this means the exchange algorithm cannot cycle and must converge to the optimum.

**Why now?** Murota's discrete convex analysis provides polynomial-time algorithms for M-convex function minimization, but the algorithms require full M-convexity. Our graded hierarchy via k-fold depth suggests that partial log-concavity (depth k < d) may already suffice for efficient optimization, with the convergence rate degrading gracefully as k decreases.

**Test**: Implement the exchange algorithm for weighted matroid intersection with various objective functions. Measure the number of exchange steps as a function of (n, d, k) where k is the k-fold depth. If the step count scales as O(n^{d-k}), this confirms the graded convergence theory.

**Impact**: Would extend the reach of efficient discrete optimization algorithms to a broader class of objective functions, with certificates that are easier to verify than full M-convexity.

**Catalog References**: `Pythagorean/MultivariateLogConcavity.lean` (`support_rectangle_closure`, `kfold_mono`, `CoeffDirectionalLogConcave`); `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (`SupportSatisfiesExchange`).

**Proof Strategy**: Define a potential function Φ = −∑ log f(mₜ) along the exchange algorithm trajectory. Show that each exchange step decreases Φ by at least a quantity controlled by the k-fold depth. Use the product stability theorem to bound the total number of steps. Formalize the convergence proof and verify soundness of the exchange algorithm against the `SupportSatisfiesExchange` predicate.

**Domain Bridges**: Combinatorial optimization (matroid intersection, submodular maximization) ↔ Algorithm design (exchange algorithms, local search) ↔ Economics (mechanism design, auction theory).

**Lineage**: Extends `support_rectangle_closure` and connects to `SupportSatisfiesExchange`.

**Ambition**: Solid extension with direct practical applications.
