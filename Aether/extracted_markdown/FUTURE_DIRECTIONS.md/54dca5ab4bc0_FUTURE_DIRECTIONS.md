# Future Directions: Arithmetic Monster Theory

## Synthesis

The four theorems established in this work — the modular sieve, the binary ghost impossibility, length additivity, and the digit-disjoint infinitude theorem — form the foundation of a base-independent theory of digit-interaction under multiplication. Together they demonstrate that digit bags are the correct abstraction for studying how multiplication rearranges symbolic information. The directions below extend this foundation in five ways: (1) toward asymptotic density via analytic methods, (2) toward graph-theoretic structure via the digit-disjointness graph, (3) toward automatic sequences and Cobham's theorem, (4) toward higher-order factorizations, and (5) toward information-theoretic bounds. Each direction builds directly on the catalog of proved theorems and is designed to be testable within a single research cycle.

---

## Direction 1: Asymptotic Density of Vampire Numbers via Fourier Analysis on Digit Bags

**Conjecture**: The number of vampire numbers V(N) in base b with v ≤ N satisfies V(N) = Θ(N^{1-c(b)}) for a base-dependent constant c(b) > 0.

**Test**: Compute V(N) for N = 10^k (k = 2, ..., 8) in bases 10 and 16. Fit log V(N) against log N to estimate c(b). The conjecture predicts a stable negative slope. If c(b) varies significantly with the range, the power-law model is falsified.

**Impact**: This would be the first rigorous density result for any digit-rearrangement class, settling a 30-year-old open question from recreational number theory.

**Catalog References**: `Speculative/ArithmeticMonsters/Theorems.lean` — `IsVampire.modEq_sum` (provides the sieve used to prune the counting), `IsVampire.digitLen_add` (constrains which digit-length pairs contribute).

**Proof Strategy**: Use the Fourier transform on ZMod(b-1)^k to express the digit-bag equality as an exponential sum. Apply the modular obstruction (Theorem 1) as a first-order sieve. Estimate the remaining sum using standard circle-method bounds. The key difficulty is controlling the correlation between digit-bag matching and multiplicative structure.

**Domain Bridges**: Analytic number theory (circle method), additive combinatorics (Freiman-type theorems on digit multisets).

**Lineage**: Extends the congruence sieve of Theorem 1 from a pointwise obstruction to an asymptotic tool.

**Ambition**: Grand challenge — requires new analytic machinery beyond what currently exists in Lean/Mathlib.

The key insight is that the digit bag equality, viewed as a convolution condition, connects vampire enumeration to exponential sum estimates of the kind used in the Hardy-Littlewood circle method.

Why now? The formal framework makes the digit bag a first-class mathematical object rather than an ad hoc computational check. The modular sieve (Theorem 1) provides the crucial first-order cancellation that makes the exponential sums tractable.

---

## Direction 2: Spectral Theory of the Digit-Disjointness Graph

**Conjecture**: The digit-disjointness graph on {1, ..., N} in base b ≥ 3 has spectral gap Ω(1) as N → ∞, indicating expansion properties analogous to Ramanujan graphs.

**Test**: Compute the adjacency matrix eigenvalues for N = 50, 100, 200 in bases 3, 5, 10. Track the ratio λ₂/λ₁ as N grows. The conjecture predicts this ratio stays bounded away from 1.

**Impact**: Would establish the digit-disjointness graph as a new family of sparse graphs with expansion properties, connecting number theory to spectral graph theory and expander constructions.

**Catalog References**: `Speculative/ArithmeticMonsters/Theorems.lean` — `pos_not_digitDisjoint_base2` (establishes the graph is empty for b=2), `exists_digitDisjoint_pair_ge` (establishes infinitely many edges for b≥3).

**Proof Strategy**: Decompose the adjacency operator by digit support patterns. Numbers sharing the same digit support set form cliques; the inter-clique structure should exhibit pseudorandomness due to equidistribution of digits in long numbers. Use Weil-type character sum bounds.

**Domain Bridges**: Spectral graph theory, expander graphs, algebraic graph theory, coding theory (LDPC codes from digit-disjointness).

**Lineage**: Directly extends Theorems 2 and 4, which establish the 0-vs-∞ dichotomy in edge count.

**Ambition**: Grand challenge — requires connecting digit combinatorics to spectral theory in a novel way.

The key insight is that the digit-disjointness graph decomposes naturally by digit support (the subset of {0,...,b-1} used), and each support class has algebraic structure amenable to spectral analysis.

Why now? The phase transition theorem (Theorem 2 + Theorem 4) establishes the base-dependent structure that makes spectral analysis meaningful. Without the formal framework, the graph itself was never precisely defined.

---

## Direction 3: Digit-Constrained Factorization and Cobham's Theorem

**Conjecture**: For bases b₁, b₂ with log(b₁)/log(b₂) ∉ ℚ, the set of numbers that are vampire numbers in *both* base b₁ and base b₂ is finite.

**Test**: Enumerate vampire numbers up to 10^7 in bases 6 and 10. Compute the intersection. The conjecture predicts the intersection grows sublogarithmically.

**Impact**: Would connect arithmetic monster theory to Cobham's theorem (1969), one of the deepest results linking automata theory to number theory. This is the strongest cross-domain bridge in the program.

**Catalog References**: `Speculative/ArithmeticMonsters/Defs.lean` — `IsVampire` (base-parametric definition), `digitBag` (the finite invariant). `Speculative/ArithmeticMonsters/Theorems.lean` — all four theorems provide base-dependent structural constraints.

**Proof Strategy**: The set of numbers with a specific digit-bag profile in base b is a union of arithmetic progressions intersected with a bounded-length condition — essentially a b-automatic set. The vampire number set is a projection of the intersection of such sets with the multiplicative relation. Cobham's theorem implies that sets recognizable in two multiplicatively independent bases are eventually periodic or sparse. Apply this to the digit-bag constraint.

**Domain Bridges**: Automata theory, formal languages, Cobham's theorem, symbolic dynamics.

**Lineage**: Extends the base-independence of the framework to a *comparison* across bases.

**Ambition**: High — requires interfacing with deep automata-theoretic results not yet formalized in Lean.

The key insight is that the digit bag constraint defines a b-recognizable set (in the sense of automata theory), and Cobham's theorem sharply constrains the intersection of recognizable sets across multiplicatively independent bases.

Why now? Prior work on vampire numbers was base-10-specific and computational. Our base-parametric formalization makes cross-base comparison a natural operation rather than an afterthought.

---

## Direction 4: Higher-Order Monster Factorizations

**Conjecture**: For k-ary factorizations v = x₁ · x₂ · ... · xₖ with digit-bag conservation, the necessary congruence condition generalizes to v ≡ x₁ + x₂ + ... + xₖ (mod b−1), and the number of k-ary vampire numbers with v ≤ N grows as Θ(N^{1-c_k(b)}) where c_k(b) is a decreasing function of k.

**Test**: Enumerate ternary (k=3) vampire numbers up to 10^6 in base 10. Verify the congruence condition. Compare the density with the k=2 case. The conjecture predicts a higher density for k=3.

**Impact**: Extends the theory from binary factorizations to arbitrary-arity decompositions, significantly broadening the framework's scope.

**Catalog References**: `Speculative/ArithmeticMonsters/Theorems.lean` — `IsVampire.modEq_sum` (the k=2 case), `vampire_digitSum_add` (the digit-sum additivity that drives the congruence).

**Proof Strategy**: The congruence proof for k=2 uses only two properties: (1) n ≡ digitSum(n) mod b-1, and (2) digit bag additivity implies digit sum additivity. Both generalize immediately to k factors. The formal proof should be a k-fold induction. Density analysis requires more sophisticated counting.

**Domain Bridges**: Additive combinatorics (sumsets of digit-bag vectors), partition theory.

**Lineage**: Direct generalization of Theorem 1.

**Ambition**: Moderate — the congruence generalization is straightforward; the density question is more challenging.

The key insight is that the modular obstruction theorem's proof depends only on the linearity of digit sums, which extends to any number of summands without additional machinery.

Why now? The formal framework makes k-ary factorizations a natural parametric extension. The Lean definitions can be generalized to list-valued factorizations with minimal refactoring.

---

## Direction 5: Digit Entropy and Information-Theoretic Bounds

**Conjecture**: For a vampire pair (x, y) with v = xy in base b, the Shannon entropy of the normalized digit bag of v is bounded below by the maximum of the entropies of x and y, i.e., H(v) ≥ max(H(x), H(y)).

**Test**: Compute H(v), H(x), H(y) for all vampire triples up to 10^6 in base 10. Check whether H(v) ≥ max(H(x), H(y)) holds universally. If a counterexample exists, characterize it.

**Impact**: Would provide the first information-theoretic characterization of digit-rearrangement phenomena, opening a bridge to coding theory and data compression.

**Catalog References**: `Speculative/ArithmeticMonsters/Defs.lean` — `digitBag` (the distribution whose entropy is computed). `Speculative/ArithmeticMonsters/Theorems.lean` — `IsVampire.digitLen_add` (the total mass constraint).

**Proof Strategy**: The digit bag of v is the sum of the digit bags of x and y. Entropy of a sum of distributions is bounded by the sum of entropies (subadditivity), but the relevant direction (lower bound by max) requires a different argument. Use the concavity of the entropy function on the simplex and the constraint that bags are summed componentwise.

**Domain Bridges**: Information theory, coding theory, convex optimization, entropy methods in combinatorics.

**Lineage**: Extends the digit bag framework from combinatorial counting to information-theoretic analysis.

**Ambition**: Moderate to high — the conjecture may be false for extreme digit distributions.

The key insight is that the digit bag, normalized by total digit count, defines a probability distribution on the digit alphabet, and vampire number constraints impose structured relationships between these distributions.

Why now? The digit bag abstraction provides a clean probability distribution that can be analyzed with standard information-theoretic tools. Prior work never formalized the digit bag as a mathematical object, making entropy analysis impossible.
