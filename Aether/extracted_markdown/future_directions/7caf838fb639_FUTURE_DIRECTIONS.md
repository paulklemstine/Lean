# Future Directions: Spectral Gap Detection of Compositeness

## Synthesis

The results established in this cycle — the arithmetic fragmentation theorem, basin disjointness, idempotent isolation, and conductance proxy framework — constitute the first formally verified bridge from prime factorization to spectral graph theory via arithmetic dynamics. This opens five concrete research directions, ranging from direct extensions of the current Lean formalization (Directions 2–4) to paradigm-shifting conjectures about dynamical Ramanujan graphs and sublinear spectral primality (Directions 1 and 5). Each direction is grounded in the verified theorems and testable by explicit computation.

The unifying theme is that **the squaring endomorphism converts arithmetic structure into geometric structure**, and the spectral theory of graphs provides the optimal language for measuring this geometry. The progression from idempotent counting → basin decomposition → conductance bounds → spectral gap estimates → primality classification represents an entire new pipeline, each stage of which can be independently formalized and tested.

---

## Direction 1: Dynamical Ramanujan Conjecture for Prime Squaring Graphs

**Conjecture**: For prime $p$, the squaring graph $G_p$ (undirected functional graph of $x \mapsto x^2$ on $\mathbb{Z}/p\mathbb{Z}$) is a dynamical Ramanujan graph: the second-largest eigenvalue of its adjacency matrix satisfies $\lambda_2(G_p) \leq 2\sqrt{\Delta(G_p) - 1}$, where $\Delta$ is the maximum degree.

**Test**: For all primes $p \leq 10^4$, compute the full spectrum of the undirected squaring graph adjacency matrix (sparse eigensolver). Verify the Ramanujan bound. Compare $\lambda_2$ distributions for primes vs. composites of comparable size.

**Impact**: If true, this would establish primes as spectrally optimal among squaring graphs, giving the strongest possible separation from composites (whose spectral gaps are suppressed by basin fragmentation). This would be the first example of a number-theoretic Ramanujan family arising from a single endomorphism.

**Catalog References**: `Pythagorean/SpectralGap.lean` — `prime_sq_idempotents_eq_zero_or_one`, `prime_idempotentSubtype_card`

**Proof Strategy**: For the forward direction, leverage the connection between squaring graphs of $\mathbb{F}_p$ and Cayley graphs of the multiplicative group. The quadratic residue structure induces a natural correspondence with Paley graphs, for which Ramanujan-type bounds are known via Weil's theorem on character sums.

**Domain Bridges**: Number theory ↔ spectral graph theory ↔ algebraic geometry (Weil conjectures)

**Lineage**: Extends the prime rigidity theorem (`prime_sq_idempotents_eq_zero_or_one`) from fixed-point counting to full spectral characterization.

**Ambition**: Grand challenge — would unify arithmetic dynamics with Ramanujan graph theory.

---

## Direction 2: CRT Product Bottleneck Theorem

**Conjecture**: For coprime $a, b \geq 2$, the minimum basin conductance satisfies $h_{\text{basin}}(ab) \leq \min(h_{\text{basin}}(a), h_{\text{basin}}(b))$, up to an explicit normalization factor depending on $a$ and $b$. More precisely, the basin structure of $ab$ is controlled by the product of the basin structures of $a$ and $b$ via CRT.

**Test**: For all coprime pairs $(a, b)$ with $2 \leq a \leq b \leq 100$, compute $h_{\text{basin}}(ab)$, $h_{\text{basin}}(a)$, and $h_{\text{basin}}(b)$. Verify the monotonicity inequality. Identify the optimal normalization.

**Impact**: Would give a formal product formula for spectral deterioration under factorization, proving that "more factors = worse expansion" in a quantitatively precise sense.

**Catalog References**: `Pythagorean/SpectralGap.lean` — `arithmetic_fragmentation_theorem`, `sqBasin_disjoint_of_ne_idempotent`; `Catalog/FINAL/Pythagorean/DynamicalSquaring.lean` — `crt_squaring_equivariant`

**Proof Strategy**: Use the CRT equivariance of squaring (`crt_squaring_equivariant`) to decompose the adjacency matrix of $G_{ab}$ as a tensor-like product. Basin conductance of the product should be bounded by the minimum of the factor conductances via standard product graph inequalities.

**Domain Bridges**: Number theory (CRT) ↔ spectral graph theory (product graphs) ↔ combinatorics

**Lineage**: Direct extension of the CRT squaring equivariance theorem and basin disjointness.

**Ambition**: Solid extension — concrete and provable with existing Lean infrastructure.

---

## Direction 3: Full Cheeger Inequality Formalization

**Conjecture**: The combinatorial Cheeger inequality $h(G)^2/2 \leq \lambda_1(G) \leq 2h(G)$ can be formalized in Lean 4 for finite graphs, and specialized to the squaring graph to yield: for squarefree $n$ with $\omega(n) \geq 2$,
$$\lambda_1(G_n) \leq 2 \cdot h_{\text{basin}}(n)$$
where the basin conductance is constructed from the formally verified basin decomposition.

**Test**: (1) Formalize the combinatorial Laplacian for finite undirected graphs in Lean. (2) Prove the easy direction of Cheeger ($\lambda_1 \leq 2h$) via the Rayleigh quotient. (3) Instantiate for squaring graphs.

**Impact**: Would complete the formal bridge from arithmetic to spectral gap, making "compositeness suppresses spectral gap" a fully machine-verified theorem.

**Catalog References**: `Pythagorean/SpectralGap.lean` — `sqEdgeBoundary`, `sqConductance`, `sqConductance_le_one`

**Proof Strategy**: Define the Laplacian as $L = D - A$ for the adjacency matrix $A$ and degree matrix $D$. The inequality $\lambda_1 \leq 2h$ follows from taking the indicator function $\mathbf{1}_S$ as a test vector in the Rayleigh quotient and bounding the numerator by $2|E(S, \bar{S})|$ and the denominator by $|S| \cdot |\bar{S}| / n$.

**Domain Bridges**: Linear algebra ↔ spectral graph theory ↔ arithmetic dynamics

**Lineage**: Builds directly on the conductance proxy definitions and edge boundary formalization.

**Ambition**: Solid extension — well-understood mathematics, requires Lean linear algebra infrastructure.

---

## Direction 4: Idempotent-Basin Law for General Rings

**Conjecture**: For any squarefree $n$, the number of "large terminal basins" (basins containing $\geq n / (2^{\omega(n)+1})$ elements) equals exactly $2^{\omega(n)}$, the number of idempotents. Each basin has size approximately $n / 2^{\omega(n)}$.

**Test**: For all squarefree $n \leq 10000$ with $\omega(n) \leq 5$, compute basin sizes and verify: (1) every idempotent basin is nonempty, (2) the number of "large" basins equals the number of idempotents, (3) basin sizes are approximately equal.

**Impact**: Would quantify the basin partition theorem: not only are basins disjoint, but they are roughly balanced, meaning each idempotent governs a comparable fraction of phase space. This balance is crucial for conductance bounds.

**Catalog References**: `Pythagorean/SpectralGap.lean` — `sqBasin_disjoint_of_ne_idempotent`, `idempotent_separated`; `Catalog/FINAL/Pythagorean/DynamicalSquaring.lean` — `nontrivial_idempotent_iff_multiple_prime_factors`

**Proof Strategy**: Via CRT, the basin of the idempotent $e = (e_1, \ldots, e_k)$ consists of elements whose coordinate orbits converge to $e_i$. In $\mathbb{Z}/p\mathbb{Z}$, the basin of 0 has size roughly $p/2$ (non-quadratic residues) and the basin of 1 has size roughly $p/2$ (quadratic residues plus 1). The product structure then gives approximately balanced basins.

**Domain Bridges**: Ring theory ↔ dynamical systems ↔ analytic number theory (quadratic residue distribution)

**Lineage**: Extension of basin disjointness to basin size estimation.

**Ambition**: Solid extension — requires quantitative estimates but no deep new theory.

---

## Direction 5: Sublinear Spectral Primality Testing

**Conjecture**: There exists a randomized algorithm that, given $n$, runs in time $O((\log n)^c)$ for some constant $c$, and with probability $\geq 2/3$ correctly classifies $n$ as prime or composite, by sampling a proxy for the spectral gap of the squaring graph $G_n$ without constructing the full graph.

**Test**: Implement a random-walk-based spectral gap estimator on $G_n$: run $T$ random walks of length $L$ starting from random elements, compute the empirical mixing time, and use it as a spectral proxy. Measure classification accuracy against ground truth for $n \leq 10^6$.

**Impact**: Would turn the spectral paradigm into a practical primality test competitive with Miller-Rabin, representing a fundamentally new approach to one of the oldest problems in computational mathematics.

**Catalog References**: `Pythagorean/SpectralGap.lean` — full theorem suite; `Catalog/Speculative/AutoResearch/PrimalityTesting/WitnessTheorems.lean` — Miller-Rabin framework for comparison

**Proof Strategy**: The key insight is that random walks on expanders mix rapidly ($O(\log n / \lambda_1)$ steps), so a random walk test can distinguish high-gap (prime) from low-gap (composite) graphs in polylogarithmic time. The challenge is proving that the spectral gap separation between primes and composites is large enough for reliable detection.

**Domain Bridges**: Computational complexity ↔ spectral graph theory ↔ number theory ↔ probability theory

**Lineage**: The logical endpoint of the entire spectral primality program: from verified spectral bounds to efficient algorithms.

**Ambition**: Grand challenge — requires both new mathematics and new algorithms, but would be transformative if achieved.
