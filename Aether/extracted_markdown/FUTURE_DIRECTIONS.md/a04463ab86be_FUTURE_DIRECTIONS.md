# Future Directions: Dynamical Squaring and Idempotent Attractors

## Synthesis

The results in this cycle establish a precise correspondence between the *algebraic* structure of $\mathbb{Z}/n\mathbb{Z}$ (its idempotents, via CRT) and the *dynamical* structure of the squaring map (its fixed points and basins of attraction). The key theorem — nontrivial idempotents exist iff $\omega(n) \geq 2$ — bridges ring theory and discrete dynamics.

The five directions below extend this bridge in complementary ways: Direction 1 pushes toward spectral graph theory (connecting basin structure to Laplacian eigenvalues), Direction 2 generalizes the dynamical system (from squaring to arbitrary power maps), Direction 3 introduces information-theoretic invariants (orbit entropy bounds), Direction 4 connects to quantum computation (polynomial-time orbit sampling), and Direction 5 aims for the grand challenge of converting the topological framework into a practical factoring algorithm. Together, they outline a program of *arithmetic dynamics of endomorphisms* — a systematic study of how algebraic structure is encoded in dynamical behavior.

All directions build on the formally verified theorems in `Pythagorean/DynamicalSquaring.lean`, which provide the rigorous foundation. Each direction includes explicit conjectures that can be tested computationally and, if true, formalized in Lean.

---

## Direction 1: Spectral Gap Detection of Compositeness

**Conjecture**: For the functional graph $G(f_n)$ of the squaring map on $\mathbb{Z}/n\mathbb{Z}$, the spectral gap $\Delta(n)$ (smallest nonzero eigenvalue of the graph Laplacian) satisfies:
$$\Pr_{n \text{ composite, } \omega(n) \geq 2}\left[\Delta(n) < \Delta(p_{\text{nearest}})\right] > 0.95$$
for $n \leq 10^6$, where $p_{\text{nearest}}$ is the prime nearest to $n$.

**Test**: Compute $\Delta(n)$ for all $n \in [3, 10^4]$ using sparse eigenvalue solvers. Measure the classification accuracy of $\Delta(n) < \text{median}(\Delta)$ as a compositeness detector. Extend to $n \leq 10^5$ if the pattern holds.

**Impact**: If confirmed, this would establish a *spectral primality test* — a fundamentally new approach to primality testing based on the topology of the functional graph rather than algebraic witnesses. This would connect number theory to Ramanujan graph theory and expander graph theory.

**Catalog References**: `Pythagorean/DynamicalSquaring.lean` (Theorems `prime_idempotent_card`, `composite_has_nontrivial_idempotent`), `Catalog/Speculative/AutoResearch/PrimalityTesting/WitnessTheorems.lean`

**Proof Strategy**: The key insight is that each nontrivial idempotent creates an additional connected component in the fixed-point subgraph, which should lower the spectral gap. Formalize the relationship between $|\text{Idem}(n)|$ and the multiplicity of the zero eigenvalue of the Laplacian. Then bound the gap using Cheeger's inequality and the basin structure.

**Domain Bridges**: Spectral graph theory ↔ Number theory ↔ Algebraic geometry (étale cohomology of functional graphs)

**Lineage**: Extends `nontrivial_idempotent_iff_multiple_prime_factors` from a counting result to a spectral result.

**Ambition**: ★★★☆☆ (computational verification is straightforward; formalization requires spectral theory of directed graphs)

---

## Direction 2: Generalized Power Map Dynamics ($x \mapsto x^k$)

**Conjecture**: For the $k$-th power map $g_{n,k}(x) = x^k \bmod n$, the fixed points satisfy $x^k = x$ iff $x^{k-1} = 1$ or $x = 0$ (in the prime case), and the number of fixed points in $\mathbb{Z}/n\mathbb{Z}$ is $\prod_{p^a \| n} \gcd(k-1, \varphi(p^a)) + 1$ when $k$ is coprime to $\varphi(n)$. For composites with $\omega(n) \geq 2$, the power map $g_{n,k}$ has nontrivial fixed points for suitable $k$ that provide factorization information.

**Test**: For $k \in \{2, 3, 5, 7\}$ and $n \leq 1000$, compute the fixed-point set of $g_{n,k}$ and verify the product formula. Identify which values of $k$ yield the most useful factorization information.

**Impact**: Generalizing from squaring to arbitrary power maps could yield new families of compositeness tests. Different exponents $k$ probe different aspects of the multiplicative structure, potentially revealing factors that the squaring map alone cannot detect.

**Catalog References**: `Pythagorean/DynamicalSquaring.lean` (all theorems), `Catalog/Speculative/AutoResearch/PrimalityTesting/WitnessTheorems.lean`

**Proof Strategy**: Extend `crt_squaring_equivariant` to $g_{n,k}$: the CRT isomorphism is equivariant for any polynomial map. Then classify fixed points of $x^k$ in $\mathbb{Z}/p^a\mathbb{Z}$ using Hensel's lemma and the structure of $(\mathbb{Z}/p^a\mathbb{Z})^*$.

**Domain Bridges**: Algebraic number theory ↔ Dynamical systems ↔ Cryptography (discrete log variants)

**Lineage**: Direct generalization of `squaringMap` and `crt_squaring_equivariant`.

**Ambition**: ★★☆☆☆ (well-understood algebraically; the formalization is the main challenge)

---

## Direction 3: Orbit Entropy Bounds and Superadditivity (Grand Challenge)

**Conjecture**: For $n = pq$ with $p, q$ distinct odd primes and $\gcd(p-1, q-1) = 2$:
$$H(pq) \geq H(p) + H(q) - \log_2 2$$
where $H(n)$ is the orbit entropy of the squaring map on $\mathbb{Z}/n\mathbb{Z}$. More generally, for squarefree $n$ with $\omega(n) = k$:
$$H(n) \geq \sum_{p | n} H(p) - (k-1) \log_2 2$$

**Test**: Compute $H(n)$ for all products of two primes $pq \leq 10000$ and verify the inequality. Identify the tightest cases and characterize when equality (approximately) holds.

**Impact**: If proven, this would establish orbit entropy as a provably *superadditive* invariant — meaning that compositeness always increases dynamical complexity in a quantifiable way. This would be a foundational result connecting information theory to multiplicative number theory.

**Catalog References**: `Pythagorean/DynamicalSquaring.lean` (`crt_squaring_equivariant`, `nontrivial_idempotent_iff_multiple_prime_factors`)

**Proof Strategy**: Use the CRT orbit decomposition (Proposition 4.1 in the paper): orbit type $(ρ, λ)$ in $\mathbb{Z}/n\mathbb{Z}$ decomposes as $(\max ρ_p, ρ_q), \text{lcm}(λ_p, λ_q))$. The entropy of the joint distribution is bounded below by the conditional entropy argument: $H(X, Y) \geq H(X) + H(Y) - I(X; Y)$, and the mutual information $I(X;Y)$ is bounded by $\log_2 |\text{range}(\gcd)|$.

**Domain Bridges**: Information theory ↔ Analytic number theory ↔ Ergodic theory ↔ Cryptography (security of RSA against entropy-based attacks)

**Lineage**: Builds on CRT orbit decomposition and the entropy framework in the research paper.

**Ambition**: ★★★★★ (requires deep connections between information theory and number theory; could be a breakthrough result)

---

## Direction 4: Quantum Orbit Sampling

**Conjecture**: A quantum algorithm can sample the orbit type distribution of $f_n$ on $\mathbb{Z}/n\mathbb{Z}$ in time $O(\text{poly}(\log n))$, yielding a BQP primality test distinct from Shor's algorithm. Specifically, the quantum period-finding subroutine can be adapted to compute the period $\lambda$ of the squaring orbit from a random starting point in quantum polynomial time.

**Test**: Implement the quantum circuit for orbit type sampling using a quantum simulator (e.g., Qiskit). Verify for $n \leq 64$ that the quantum circuit correctly identifies orbit types. Compare circuit depth and qubit count with Shor's algorithm.

**Impact**: This would establish a new quantum approach to number-theoretic problems that doesn't require order-finding in the multiplicative group (as Shor's algorithm does), but instead exploits the dynamical structure of the squaring map. This could be more efficient for certain classes of numbers or provide alternative quantum factoring routes.

**Catalog References**: `Pythagorean/DynamicalSquaring.lean` (`squaringIterate`, `squaring_fixed_iff_idempotent`)

**Proof Strategy**: The quantum period-finding algorithm (QPE) applies directly to the squaring map iteration $x \mapsto x^{2^t} \bmod n$. The key observation is that $x^{2^t} = x^{2^{t \bmod \text{ord}(x)}}$ for $x$ coprime to $n$, so the quantum circuit can extract $\text{ord}(x)$ — but the novelty is applying QPE to the *composition* of squaring maps rather than modular exponentiation.

**Domain Bridges**: Quantum computing ↔ Dynamical systems ↔ Number theory ↔ Cryptanalysis

**Lineage**: Extends `squaringIterate` to the quantum setting.

**Ambition**: ★★★★☆ (requires quantum computing expertise; the connection to Shor is deep but the novelty must be carefully established)

---

## Direction 5: Topological Factoring Algorithm (Grand Challenge)

**Conjecture**: There exists a subexponential-time algorithm that factors $n$ by detecting the basin structure of the squaring map without computing individual idempotents. Specifically, by sampling $O(n^{1/4})$ random elements and computing their orbit types, one can distinguish which basin each element belongs to with high probability, and then extract factors from the basin boundaries.

**Test**: Implement the following algorithm for $n \leq 10^8$:
1. Sample $m = \lceil n^{1/4} \rceil$ random elements $a_1, \ldots, a_m$ from $\mathbb{Z}/n\mathbb{Z}$
2. Compute orbit types $(\rho_i, \lambda_i)$ for each $a_i$
3. Cluster elements by orbit type
4. For pairs $(a_i, a_j)$ in different clusters, compute $\gcd(a_i^{2^k} - a_j^{2^k}, n)$ for small $k$
5. Report any nontrivial gcd found

**Impact**: A provably subexponential factoring algorithm based on dynamical topology would be a major breakthrough, potentially rivaling the Number Field Sieve in certain regimes. Even a heuristic algorithm with good practical performance would be significant.

**Catalog References**: `Pythagorean/DynamicalSquaring.lean` (all theorems, especially `nontrivial_idempotent_iff_multiple_prime_factors` and `crt_squaring_equivariant`), `Catalog/Speculative/AutoResearch/PrimalityTesting/WitnessTheorems.lean`

**Proof Strategy**: The key insight is that elements in different basins of attraction must have different CRT projections, so their differences modulo a factor of $n$ should have special divisibility properties. The birthday paradox suggests that $O(\sqrt{|\text{basins}|})$ samples suffice to find a collision between basins, and each collision yields a factor via gcd.

**Domain Bridges**: Computational number theory ↔ Dynamical systems ↔ Algebraic topology ↔ Cryptography (post-quantum security)

**Lineage**: Synthesizes all results: CRT equivariance, idempotent characterization, basin structure, orbit type decomposition.

**Ambition**: ★★★★★ (paradigm-shifting if successful; requires novel connections between dynamical topology and algebraic number theory)
