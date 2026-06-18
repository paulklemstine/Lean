# Future Directions: Directional Depth Filtration for Valuated Matroids

## Synthesis

The directional depth filtration establishes a new graded invariant for functions on integer lattice points, measuring the persistence of log-concavity under iterated ratio transforms. The five directions below form a coherent program: Direction 1 extends the algebraic foundations (mixed log-concavity depth), Direction 2 builds the tropical-geometric bridge to valuated matroid theory proper, Direction 3 connects to Hodge theory and Lorentzian polynomials for the deepest structural results, Direction 4 develops the computational theory for algorithmic applications, and Direction 5 bridges to statistical physics and machine learning. Together, these directions aim to transform the depth filtration from a new invariant into a new *theory* — one that provides computational access to geometric structure previously accessible only through heavy algebraic machinery.

---

## Direction 1: Mixed Log-Concavity Depth Filtration

**Conjecture:** Define a *mixed directional depth* by replacing `MultiDirLogConcave` with `MixedLogConcave` in the recursive definition. Then: (a) the mixed depth classes are also multiplicatively stable, (b) mixed depth ≥ 1 implies supermodularity of $-\log f$ (already proved), and (c) mixed depth provides a strictly finer filtration than directional depth.

**The key insight is** that mixed log-concavity — the condition $f(m+e_i) \cdot f(m+e_j) \geq f(m) \cdot f(m+e_i+e_j)$ — is the *natural* multivariate generalization that captures cross-directional interactions, and iterating it through ratio transforms should produce a richer hierarchy than single-direction conditions alone.

**Why now?** The multiplicative stability theorem (Theorem 1) and the tropical bridge theorem (Theorem 2) are both established. The mixed analog of multiplicative stability (`mixedLogConcave_mul`) is already proved in our formalization, providing the base case for the recursive extension.

**Test:** Prove `mixedDirectionalDepthAtLeast_mul` by induction on $k$, using `mixedLogConcave_mul` and the ratio transform factorization. Then compute mixed depth for the same families tested in our experiments and compare with directional depth.

**Impact:** This would complete the algebraic foundation, showing that the *strongest* reasonable notion of multivariate log-concavity also admits a multiplicative depth hierarchy with tropical-geometric content.

**Catalog References:** `ValuatedMatroidDepth/Theorems.lean` — `mixedLogConcave_mul`, `ratioTransform_mul`, `negLog_supermodular_of_mixedLC`.

**Proof Strategy:** Direct induction on $k$ generalizing $f, g$, using the ratio transform product decomposition and the fact that ratio transforms of mixed-LC functions are mixed-LC (to be proved as a lemma).

**Domain Bridges:** Tropical geometry (supermodularity tower), algebraic combinatorics (Schur positivity).

**Lineage:** Builds directly on Theorems 1 and 2 of the current work.

**Ambition:** Solid extension — incremental but necessary for the full theory.

---

## Direction 2: Depth and M-Convexity for Valuated Matroids

**Conjecture:** For functions with exchange-closed support on a fixed degree slice, directional depth ≥ 1 combined with mixed log-concavity implies a weak form of M-convexity for the tropical valuation $v = -\log f$. Specifically: for any $m, n$ with $\sum m_i = \sum n_i = d$, $f(m) > 0$, $f(n) > 0$, and $m_i < n_i$, there exists $j$ with $n_j < m_j$ such that $v(m) + v(n) \geq v(\text{exchangeMove}(m,i,j)) + v(\text{exchangeMove}(n,j,i))$.

**The key insight is** that the exchange axiom for valuated matroids (Dress–Wenzel) has a natural logarithmic reformulation, and the combination of exchange-closed support with supermodularity of $-\log f$ should force exchange inequalities for the tropical valuation.

**Why now?** The tropical bridge theorem converts mixed log-concavity to supermodularity, and the exchange-closed support definition is already formalized. The missing piece is showing that supermodularity on a degree slice, combined with exchange-closure, implies the Dress–Wenzel exchange condition.

**Test:** Formalize and prove the weak exchange theorem for functions on degree slices. Test computationally on uniform matroids $U(r, n)$ for small $r, n$.

**Impact:** This would be the first rigorous result showing that the depth filtration *refines* classical valuated matroid theory — that depth-1 functions with exchange-closed support are valuated matroids in a precise sense.

**Catalog References:** `ValuatedMatroidDepth/Defs.lean` — `ExchangeClosedSupport`, `exchangeMove`, `degreeSlice`.

**Proof Strategy:** Local-to-global: use supermodularity to compare energy at neighboring lattice points, then apply exchange-closure to identify the exchange coordinate, and sum inequalities via a `calc` chain.

**Domain Bridges:** Discrete convex analysis (Murota), tropical Grassmannians, optimization.

**Lineage:** Builds on Theorem 2 and the exchange-closed support definition.

**Ambition:** Grand challenge — this would establish the depth filtration as a genuine refinement of M-convexity.

---

## Direction 3: Lorentzian Polynomial Connection

**Conjecture:** For a homogeneous polynomial $p$ of degree $d$ in $n$ variables with positive coefficients, define $f(m) = [\text{coefficient of } x^m \text{ in } p]$. Then $p$ is Lorentzian (in the sense of Brändén–Huh) if and only if $f$ has infinite mixed directional depth.

**The key insight is** that the Lorentzian property — preservation of the definite-sign Hessian condition under all sequences of partial derivatives — is the continuous polynomial analog of infinite depth for the coefficient function. The ratio transform $R_i f$ corresponds to the coefficient function of $\partial_i p / p$ in a suitable sense.

**Why now?** Lorentzian polynomial theory is one of the most active areas in combinatorics, but the coefficient-level characterization remains incomplete. Our depth filtration provides the right language to state and potentially prove such a characterization.

**Test:** Verify computationally for Lorentzian polynomials of small degree (e.g., elementary symmetric polynomials $e_k(x_1, \ldots, x_n)$, complete homogeneous symmetric polynomials $h_k$) that their coefficient functions have high depth.

**Impact:** This would provide a new, purely combinatorial characterization of Lorentzian polynomials, potentially more accessible than the current definition via Hessian conditions.

**Catalog References:** `Catalog/Pythagorean/HigherOrderLogConcavity.lean` — `KFoldLogConcave`, `KFoldLogConcave.mul`.

**Proof Strategy:** One direction (Lorentzian → infinite depth) via the Brändén–Huh theory of coefficient-level consequences. The converse likely requires new ideas connecting support theory to the Hessian criterion.

**Domain Bridges:** Algebraic geometry (Hodge theory), representation theory (Schur positivity), matroid theory.

**Lineage:** Connects the 1D theory in `HigherOrderLogConcavity.lean` to the multivariate theory in `ValuatedMatroidDepth/`.

**Ambition:** Grand challenge — paradigm-shifting if successful.

---

## Direction 4: Efficient Depth Computation

**Conjecture:** On degree-$d$ slices with $n$ variables, directional depth can be computed in time $O(n^2 \cdot \binom{n+d}{d}^2 \cdot k)$ for depth up to $k$, by exploiting the recursive structure and memoization of ratio transforms on the slice.

**The key insight is** that the ratio transform preserves the degree slice structure (shifting from degree $d$ to degree $d+1$), so computations can be restricted to slices rather than the full $\mathbb{Z}_{\geq 0}^n$ lattice. Combined with sparse representations for functions supported on degree slices, this should make depth computation practical for moderate $n$ and $d$.

**Why now?** The naive algorithm has complexity exponential in $k$ (due to the branching ratio transform tree). But most ratio transforms at deep levels evaluate to zero or near-zero for finitely supported functions, suggesting aggressive pruning is possible.

**Test:** Implement the slice-restricted algorithm and benchmark against the naive implementation on uniform matroids $U(r, n)$ for $n$ up to 10.

**Impact:** Would make the depth filtration a practical computational tool for matroid optimization, not just a theoretical invariant.

**Catalog References:** `algorithms.py` — `DepthComputer`, `ExactDepthSearcher`.

**Proof Strategy:** Correctness proof by showing slice restriction is exact for finitely supported functions. Complexity analysis via counting slice sizes.

**Domain Bridges:** Algorithms, computational algebra, optimization.

**Lineage:** Extends the computational experiments in `demo.py` and `algorithms.py`.

**Ambition:** Solid extension — necessary for practical applications.

---

## Direction 5: Depth in Statistical Mechanics and Machine Learning

**Conjecture:** In exponential family models $f_\theta(m) = \exp(\theta \cdot T(m) - A(\theta))$, the directional depth of $f_\theta$ as a function of $m$ is always infinite for the natural sufficient statistics, and equals 1 for generic curved exponential families.

**The key insight is** that exponential families have $-\log f$ linear in sufficient statistics, making them "flat" in the information-geometric sense. Flatness implies all ratio transforms are again exponential, giving infinite depth. Curved subfamilies break this structure, producing finite depth that measures the "curvature complexity" of the statistical model.

**Why now?** The connection between log-concavity and sampling algorithms (Anari–Liu–Oveis Gharan–Vinzant, 2019) has already revolutionized combinatorial optimization. Depth adds a *graded* version: higher depth should give faster mixing of Markov chains, since the energy landscape has more persistent convexity.

**Test:** Compute depth for Ising models on small graphs with varying coupling strengths, and correlate with MCMC mixing times.

**Impact:** Would provide a new sufficient condition for fast mixing of Glauber dynamics — one that is strictly stronger than ordinary log-concavity and may capture the full mixing-time behavior for many natural models.

**Catalog References:** `Catalog/Pythagorean/DirectionalLogConcavity.lean` — `IsPairwiseDLC`, `dobrushin_contraction_bound`; `applications.py` — `energy_landscape_analysis`.

**Proof Strategy:** For exponential families, direct computation shows ratio transforms are exponential. For mixing times, adapt the Dobrushin framework to use depth-based contraction bounds.

**Domain Bridges:** Statistical mechanics (Ising models, Gibbs measures), machine learning (Boltzmann machines, energy-based models), information geometry (Fisher information, natural gradient).

**Lineage:** Connects the statistical mechanics bridge in Theorem 4 (`ratio_energy_supermodular`) to the Dobrushin contraction framework in `DirectionalLogConcavity.lean`.

**Ambition:** Grand challenge — bridges two major fields through the depth filtration.
