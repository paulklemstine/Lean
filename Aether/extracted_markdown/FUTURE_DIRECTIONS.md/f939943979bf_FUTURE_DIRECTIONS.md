# Future Directions: Isogeny-Based Cryptography Formalization

## Synthesis

This research cycle established the formal algebraic foundations of isogeny-based cryptography in Lean 4, proving 15+ theorems about group actions, torsors, CSIDH correctness, and CSI-FiSh soundness — all without sorry. The key insight is that the entire security framework of CSIDH reduces to three properties of the class group action: freeness, transitivity, and commutativity. These abstract properties, once formalized, yield machine-verified proofs of protocol correctness and security reductions.

The most promising cross-domain connection from this cycle is the bridge between **algebraic number theory** (class groups, quadratic forms) and **graph theory** (Cayley graphs, expander properties). The Cayley graph of the class group action on supersingular curves is a Ramanujan graph — an optimal expander. This connects our formalization to the Catalog's existing work on spectral graph theory (e.g., `Algebra/ClassicalGroupExpanders.lean`) and lattice cryptography (`Cryptography/BerggrenLatticeCryptography.lean`). The cardinality theorem |G| = |X| for torsors opens connections to counting arguments in combinatorics, and the connector algebra (composition, inversion) parallels the cocycle conditions in group cohomology.

The highest breakthrough potential lies in Direction 1 (Quantum Complexity of GAIP), since resolving the exact quantum complexity would either validate or undermine the entire CSIDH ecosystem. Direction 3 (Concrete Instantiation) has the most immediate practical value for the Catalog.

---

### Direction 1: Quantum Complexity Lower Bounds for GAIP

**Conjecture**: The Group Action Inverse Problem for a free transitive action of an abelian group $G$ on a set $X$ requires $\Omega(|G|^{1/4})$ quantum queries to the group action oracle. Specifically, for any quantum algorithm making $T$ queries, the success probability is at most $O(T^4 / |G|)$.

**Test**: Implement a quantum simulation of Kuperberg's hidden shift algorithm for small cyclic groups ($\mathbb{Z}/n\mathbb{Z}$ for $n \leq 128$). Measure the actual query count and compare against the $O(n^{1/4} \cdot \text{polylog})$ theoretical prediction. If the constant factors are large enough, this supports practical security of CSIDH-512.

**Impact**: If true, this provides the first formal lower bound on quantum attacks against CSIDH, validating parameter choices. If false (i.e., if a $o(|G|^{1/4})$ algorithm exists), it would necessitate parameter increases across all CSIDH-based systems. The formal proof would connect quantum information theory to group action security.

**Catalog References**: `Cryptography/BerggrenLatticeCryptography.lean`, `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: Formalize the recording query model for quantum group action oracles. Use the polynomial method or adversary method from quantum query complexity. Key lemma: any $T$-query quantum algorithm can produce at most $O(T^2)$ bits of information about the hidden group element, and specifying a random element of $G$ requires $\log |G|$ bits. This requires formalizing quantum states as vectors in $\ell^2(G \times X)$ and unitary operators corresponding to group action queries.

**Domain Bridges**: Cryptography <-> Computation, Algebra <-> Physics

**Lineage**: Builds on the FreeTrans and GAIP formalizations from this cycle. Extends the abstract group action framework to the quantum oracle setting.

**Ambition**: grand_challenge

---

### Direction 2: Expander Mixing Lemma for Isogeny Cayley Graphs

**Conjecture**: For the Cayley graph of a free transitive action of an abelian group $G$ on $X$ with generator set $S$ (with $|S| = k$, $S = S^{-1}$, $1 \notin S$), the spectral gap satisfies $\lambda_1 - \lambda_2 \geq \frac{k - 2\sqrt{k-1}}{k}$ (the Ramanujan bound), and consequently a random walk of length $t \geq \frac{2 \log |G|}{\log(k / (2\sqrt{k-1}))}$ is $\varepsilon$-close to uniform in total variation distance.

**Test**: For the cyclic group $\mathbb{Z}/p\mathbb{Z}$ with $p \in \{11, 23, 47, 97, 197\}$ and generator set $S = \{1, -1\}$:
1. Compute the adjacency matrix eigenvalues.
2. Verify the spectral gap matches $1 - \cos(2\pi/p)$.
3. Compute exact mixing time and compare with $\lceil p^2 / (4\pi^2) \rceil$.
If the spectral gap satisfies the Ramanujan bound for all tested primes, the conjecture is supported.

**Impact**: A formal proof would establish that isogeny graphs have optimal expansion, directly implying rapid mixing of the CSIDH key generation random walk. This is critical for the security proof: non-uniform key distribution would leak information about the secret.

**Catalog References**: `Algebra/ClassicalGroupExpanders.lean`, `Cryptography/CSIFiSh.lean` (IsogenyCayleyGraph)

**Proof Strategy**: 
1. Formalize the adjacency matrix of the Cayley graph as a $|X| \times |X|$ matrix over $\mathbb{R}$.
2. Connect eigenvalues to the Fourier transform of the generator set indicator function on $G$.
3. For abelian $G$, the eigenvalues are $\sum_{s \in S} \chi(s)$ for characters $\chi$ of $G$.
4. Apply the Ramanujan bound (or Alon-Boppana for general regular graphs).
Key lemma: $|\sum_{s \in S} \chi(s)| \leq 2\sqrt{|S|-1}$ for non-trivial characters.

**Domain Bridges**: Algebra <-> Computation, Cryptography <-> EML

**Lineage**: Extends IsogenyCayleyGraph and adjacent_symm from this cycle. Connects to the spectral methods in `Algebra/ClassicalGroupExpanders.lean`.

**Ambition**: extension

---

### Direction 3: Concrete Instantiation with Supersingular Curves

**Conjecture**: The set of $\mathbb{F}_p$-isomorphism classes of supersingular elliptic curves with endomorphism ring $\mathcal{O} = \mathbb{Z}[\sqrt{-p}]$ (for $p \equiv 3 \pmod{4}$) admits a FreeTrans action by $\text{Cl}(\mathcal{O})$, and the class number $h(\mathcal{O})$ satisfies $h(\mathcal{O}) \sim \frac{\sqrt{p}}{\pi} \cdot L(1, \chi_{-p})$ where $\chi_{-p}$ is the Kronecker symbol.

**Test**: For primes $p \in \{3, 7, 11, 19, 23, 31, 43, 67, 163\}$:
1. Enumerate all supersingular $j$-invariants in $\mathbb{F}_p$.
2. Compute $h(\mathcal{O})$ using the Hurwitz class number formula.
3. Verify that the count of $j$-invariants equals $h(\mathcal{O})$ (our cardinality theorem predicts equality).
For $p = 419$ (the CSIDH-512 prime), verify $h(\mathcal{O}) = ?$ matches the known class number.

**Impact**: This bridges our abstract formalization to the concrete cryptographic setting. It would yield the first end-to-end verified chain from the class group axioms to CSIDH parameter validation.

**Catalog References**: `Cryptography/CSIFiSh.lean` (FreeTrans, card_eq), `Algebra/Basic.lean`

**Proof Strategy**:
1. Formalize supersingular elliptic curves over $\mathbb{F}_p$ using Mathlib's `EllipticCurve` type.
2. Define the $j$-invariant and isomorphism classes.
3. Construct the class group $\text{Cl}(\mathcal{O})$ as $\text{Cl}(\mathbb{Z}[\sqrt{-p}])$.
4. Define the action via ideal multiplication on lattices.
5. Prove freeness and transitivity using Deuring's correspondence.
Key prerequisite: Mathlib's elliptic curve API needs extensions for supersingular curves.

**Domain Bridges**: Algebra <-> Cryptography, Geometry <-> Computation

**Lineage**: Direct continuation of the FreeTrans framework. The cardinality theorem card_eq would be instantiated to the class number formula.

**Ambition**: grand_challenge

---

### Direction 4: Verifiable Delay Functions from Isogeny Walks

**Conjecture**: A sequential walk of length $T$ in the isogeny Cayley graph (computing $g_1 \star (g_2 \star (\cdots (g_T \star x_0) \cdots))$ with $g_i$ drawn from the generator set) requires $\Omega(T)$ sequential isogeny computations, even with polynomial parallel processors. This is formalizable as: the walk function `groupActionWalk` cannot be computed by any circuit of depth $o(T)$ relative to a group action oracle.

**Test**: Implement the sequential walk for $\mathbb{Z}/n\mathbb{Z}$ with $n = 2^{128} - 1$ and generator $\{1\}$. Measure wall-clock time for walks of length $T \in \{10^3, 10^4, 10^5, 10^6\}$. Verify strict linear scaling. Attempt parallel speedup with multiple cores and verify no super-linear speedup.

**Impact**: If true, this establishes a formal foundation for isogeny-based Verifiable Delay Functions (VDFs), which are crucial for blockchain consensus, randomness beacons, and fair protocols. VDFs from isogenies would be post-quantum secure.

**Catalog References**: `Cryptography/CSIFiSh.lean` (groupActionWalk, groupActionWalk_eq_act), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: 
1. Formalize the sequential computation model (depth-restricted circuits with oracle gates).
2. Show that each step of the walk depends on the previous output (no shortcutting).
3. Use the freeness property: the intermediate states $x_0, g_1 \star x_0, (g_1 g_2) \star x_0, \ldots$ are all distinct (if generators are non-trivial), so the walk visits $T$ distinct points.
4. Apply a communication complexity argument: computing step $i+1$ requires knowing step $i$.

**Domain Bridges**: Cryptography <-> Computation, Algebra <-> Logic

**Lineage**: Builds on groupActionWalk_eq_act and the Cayley graph structure from this cycle.

**Ambition**: extension

---

### Direction 5: Threshold CSI-FiSh and Distributed Key Generation

**Conjecture**: The CSI-FiSh identification scheme admits a $(t, n)$-threshold variant where the secret $s \in G$ is Shamir-shared among $n$ parties (over the abelian group $G$), and any $t$ parties can jointly produce a valid identification transcript without reconstructing $s$. Formally: there exists a protocol where each party $i$ holds $s_i \in G$ with $\prod_{i \in S} s_i^{\lambda_i} = s$ for any $t$-subset $S$ (Lagrange coefficients $\lambda_i$), and the joint response to a challenge can be computed from individual partial responses.

**Test**: Implement $(2, 3)$-threshold CSI-FiSh for the group $\mathbb{Z}/101\mathbb{Z}$. Generate 100 random key sharings, produce threshold signatures, and verify all pass the verification equation. Check that any single share reveals no information about $s$ (statistical test: for each share value, count how many secrets are consistent).

**Impact**: Threshold signatures are essential for multi-party custody (e.g., cryptocurrency wallets). A post-quantum threshold signature from CSIDH would fill a critical gap in the post-quantum toolbox.

**Catalog References**: `Cryptography/CSIFiSh.lean` (CSIFiShTranscript, special_soundness), `Cryptography/BerggrenPostQuantumLattices.lean`

**Proof Strategy**:
1. Define Shamir secret sharing over abelian groups (polynomial interpolation in $G$).
2. Construct the partial response protocol: each party computes $z_i = r_i \cdot s_i^{-c}$ (for challenge $c$).
3. Show that $\prod z_i^{\lambda_i} = r \cdot s^{-c}$ (the correct full response).
4. Prove completeness by our existing csifish_completeness_1 theorem.
5. Prove soundness by extending special_soundness to the threshold setting.

**Domain Bridges**: Cryptography <-> Algebra, Computation <-> Logic

**Lineage**: Extends the CSI-FiSh formalization from this cycle. Uses shared_secret_agreement as a building block.

**Ambition**: extension
