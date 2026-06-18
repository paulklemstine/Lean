# Future Directions: Spectral Proof Complexity

## Synthesis

This research cycle established a rigorous, machine-verified framework connecting directed graph expansion to proof complexity through derivation systems. We formalized derivation systems (axioms + one-step derivation on a finite type), proof balls (reachable sets at bounded depth), and frontiers (newly derivable statements). The central results are: (1) an additive growth bound showing |Ball(k)| ≥ |axioms| + k·c when each frontier has at least c elements; (2) a depth lower bound (n - |axioms|)/f ≤ depth when each frontier is bounded by f; (3) a fixed-point characterization of stabilization as closure under derivation; (4) a reachability dichotomy (derivable or permanently unreachable); and (5) a proof domination framework comparing derivation systems.

The most promising cross-domain connection is the **spectral pipeline**: spectral gap → conductance → frontier growth → proof length lower bounds. Our additive growth framework provides the foundation (steps 2→3→4), but the missing piece is the multiplicative/exponential version that would connect to spectral theory. The additive bound gives linear growth; a multiplicative bound (|Ball(k)| ≥ (1+φ)^k · |axioms|) would give exponential growth and exponentially stronger lower bounds. This connects to the broader Catalog through `growth_from_spectral_gap` (in `Bridges/HyperbolicNumberTheory.lean`) which establishes spectral gap-to-growth connections, and `cheeger_from_spectral_gap` (in `Bridges/Sp4SpectralGap.lean`) which provides the Cheeger inequality half of the pipeline.

The direction with highest breakthrough potential is **Direction 1 (Multiplicative Expansion Bounds)** because it would complete the exponential growth chain and enable proof length lower bounds that grow logarithmically with the target set size—matching known lower bounds for specific proof systems but derived from uniform graph-theoretic principles.

---

### Direction 1: Multiplicative Expansion and Exponential Proof Ball Growth

**Conjecture**: For a derivation system D with directed graph conductance φ > 0, if |Ball_D(k)| ≤ |α|/2, then |Ball_D(k+1)| ≥ (1 + φ) · |Ball_D(k)|. Consequently, |Ball_D(k)| ≥ min((1+φ)^k · |axioms|, |α|/2).

A derivation system on a finite type α = {s₁, ..., sₙ} has axiom set Ax ⊆ α, derivation function δ : α → P(α), proof ball Ball(k) defined inductively (Ball(0) = Ax, Ball(k+1) = Ball(k) ∪ ⋃_{a ∈ Ball(k)} δ(a)), and frontier F(k) = (⋃_{a ∈ Ball(k)} δ(a)) \ Ball(k). The conductance φ(D) = min_{S : |S| ≤ |α|/2} |∂S|/|S| where ∂S = {b ∉ S : ∃ a ∈ S, b ∈ δ(a)}.

**Test**: Construct explicit derivation systems (e.g., the derivation graph of propositional resolution on random 3-SAT instances) and compute both the conductance and the actual ball growth rate. If growth rate < (1+φ) for small balls, the conjecture fails.

**Impact**: If true, this gives logarithmic depth lower bounds: to reach n statements from m axioms requires depth ≥ log(n/m) / log(1+φ). This would match the Ben-Sasson-Wigderson width-based resolution lower bounds but through purely graph-theoretic means, potentially extending to proof systems where width-based arguments fail.

**Catalog References**: `Bridges/HyperbolicNumberTheory.lean` (`growth_from_spectral_gap`), `Bridges/Sp4SpectralGap.lean` (`cheeger_from_spectral_gap`), `Bridges/SpectralProofComplexity.lean` (`ball_growth_additive_lower`, `depth_lower_bound_from_card`)

**Proof Strategy**: 
1. Define directed conductance formally as min |F(k) ∩ S^c| / |Ball(k) ∩ S| over appropriate subsets S.
2. Prove that φ(D) > 0 and |Ball(k)| ≤ |α|/2 implies |F(k)| ≥ φ · |Ball(k)| (this is essentially the definition of conductance applied to S = Ball(k)).
3. Use the additive bound |Ball(k+1)| = |Ball(k)| + |F(k)| ≥ (1+φ)|Ball(k)|.
4. Induct to get exponential growth.
5. The main challenge is formalizing the conductance definition for directed graphs and handling the ℝ-valued arithmetic in Lean.

**Domain Bridges**: Spectral graph theory ↔ Proof complexity ↔ Combinatorial optimization

**Lineage**: Builds on this cycle's `ball_growth_additive_lower` and `card_proofBall_succ`.

**Ambition**: grand_challenge

---

### Direction 2: Hypergraph Derivation Systems

**Conjecture**: For a *k-uniform hypergraph derivation system* (where each derivation step requires exactly k premises), the depth lower bound scales as (n - |Ax|)^{1/k} / f^{1/k} rather than (n - |Ax|) / f. That is, multi-premise inference reduces the depth requirement polynomially.

A k-uniform hypergraph derivation system has δ : α^k → P(α), proof ball Ball(0) = Ax, Ball(d+1) = Ball(d) ∪ ⋃_{(a₁,...,aₖ) ∈ Ball(d)^k} δ(a₁,...,aₖ), and frontier F(d) = Ball(d+1) \ Ball(d).

**Test**: For k=2 (binary resolution), construct derivation systems on Fin n and verify computationally that depth scales as √n rather than n. Compare k=1 (our current framework) and k=3 derivation systems on the same statement set.

**Impact**: Multi-premise inference is fundamental to practical proof systems (resolution uses two premises, sequent calculus uses multiple). Understanding how premise count affects depth requirements would give tighter lower bounds for these systems.

**Catalog References**: `Bridges/SpectralProofComplexity.lean` (entire framework), `Computation/InfoEfficientAlgorithms.lean` (`InfoEfficientAlgorithm`)

**Proof Strategy**:
1. Define HypergraphDerivationSystem with derives : (Fin k → α) → Finset α.
2. Define proof balls and frontiers analogously.
3. Show the frontier can grow as |Ball(k)|^k, giving much faster ball growth.
4. Derive the corresponding depth lower bound by inverting the growth function.
5. The key lemma is bounding |Ball(d)^k \ Ball(d-1)^k| in terms of |F(d-1)| · |Ball(d-1)|^{k-1}.

**Domain Bridges**: Hypergraph theory ↔ Proof complexity ↔ Multi-agent reasoning

**Lineage**: Direct extension of this cycle's DerivationSystem framework.

**Ambition**: extension

---

### Direction 3: Derivation Graph Universality under Coarse-Graining

**Conjecture**: For a sequence of derivation systems D_n on Fin(n) with uniformly bounded degree (|δ(a)| ≤ d for all a) and conductance bounded away from 0 (φ(D_n) ≥ φ₀ > 0), the normalized ball growth profile g_n(t) = |Ball_{D_n}(⌊tn⌋)| / n converges to a universal function g*(t) depending only on φ₀ and d, independent of the specific derivation rules.

**Test**: Generate random derivation systems on Fin(100) with fixed degree d=3 and varying conductance. Plot the normalized growth profiles. If they cluster around a common curve for each φ₀, universality holds.

**Impact**: If true, this would mean that the macroscopic behavior of proof systems is determined by just two parameters (expansion and degree), analogous to universality in statistical physics. This would dramatically simplify proof complexity analysis.

**Catalog References**: `Bridges/RenormalizationUniversality.lean` (`every_stabilizing_observable_has_fixed_universality_class`), `Bridges/SpectralProofComplexity.lean` (`proofBall_stabilizes`, `exists_stabilization_depth`)

**Proof Strategy**:
1. Define a coarse-graining operator that maps D_n to a derivation system on Fin(n/2) by merging pairs of statements.
2. Show that conductance is approximately preserved under coarse-graining (within a factor of 2).
3. Prove that the normalized ball growth profile is approximately preserved.
4. Apply the coarse-graining iteratively to approach a fixed point.
5. The key difficulty is making "approximately preserved" precise—likely requires a Wasserstein-type metric on growth profiles.

**Domain Bridges**: Statistical physics (renormalization group) ↔ Proof complexity ↔ Ergodic theory

**Lineage**: Builds on this cycle's stabilization results and the prior cycle's renormalization framework (`RenormalizationUniversality`).

**Ambition**: grand_challenge

---

### Direction 4: Expansion Certificates as Proof-of-Work

**Conjecture**: Computing an ExpansionWitness with minFrontier ≥ c for a derivation system D is at least as hard as computing Ball_D(steps). That is, there is no shortcut to certifying expansion without actually running the derivation.

An ExpansionWitness for D with parameters (steps, minFrontier) certifies that |F_D(i)| ≥ minFrontier for all i < steps. This gives |Ball_D(steps)| ≥ |Ax| + steps · minFrontier.

**Test**: Attempt to construct expansion witnesses for specific derivation systems (e.g., resolution on pigeonhole formulas) without computing the full proof balls. If no polynomial shortcut exists for exponential-depth systems, the conjecture holds.

**Impact**: If expansion certificates are inherently hard, they could serve as proofs-of-work in cryptographic protocols—verifiable certificates that a certain amount of logical computation was performed.

**Catalog References**: `Bridges/SpectralProofComplexity.lean` (`ExpansionWitness`, `ball_growth`, `total_derivable_lower`), `Cryptography/BerggrenFingerprintRigidity.lean`

**Proof Strategy**:
1. Formalize a computational model (oracle Turing machine with access to δ).
2. Show that any algorithm producing an ExpansionWitness must query δ at least steps · minFrontier times (information-theoretic lower bound).
3. The key insight: to certify |F(i)| ≥ c, you must identify c elements in F(i), each requiring at least one query to δ.
4. Lower bound: Ω(steps · minFrontier) queries, which matches the cost of computing all proof balls.

**Domain Bridges**: Proof complexity ↔ Cryptography ↔ Computational complexity

**Lineage**: Builds on this cycle's ExpansionWitness framework and expansion certificates.

**Ambition**: extension

---

### Direction 5: Optimal Derivation System Design

**Conjecture**: For any target set T ⊆ α with |T| = n and any axiom set Ax ⊆ α with |Ax| = m, the minimum-depth derivation system reaching T has depth Θ(log(n/m)) when the maximum outdegree is unrestricted, and depth Θ((n-m)/d) when the maximum outdegree is bounded by d.

**Test**: For T = Fin(n) and Ax = {0}, construct derivation systems achieving depth O(log n) (exponential-growth design: δ(a) = {2a, 2a+1}) and verify the lower bound via `depth_lower_bound_from_card`.

**Impact**: Understanding optimal derivation system design would guide the construction of efficient proof systems and could yield separation results between proof systems of different expansion characteristics.

**Catalog References**: `Bridges/SpectralProofComplexity.lean` (`depth_lower_bound_from_card`, `ProofDominates`, `proofDominates_of_superset`)

**Proof Strategy**:
1. Upper bound (unrestricted): construct δ(a) = {all not-yet-derived statements}, giving Ball(1) = α. Depth = 1 (trivial but shows the bound is tight for degree n).
2. Upper bound (degree d): use a balanced tree construction giving depth ⌈log_d(n/m)⌉.
3. Lower bound (degree d): at each step, at most d · |Ball(k)| new statements can be derived, giving |Ball(k)| ≤ m · (d+1)^k, so depth ≥ log_{d+1}(n/m).
4. Formalize the lower bound using `depth_lower_bound_from_card` with f = d · |Ball(k)| (noting this requires a non-uniform frontier bound).

**Domain Bridges**: Combinatorial optimization ↔ Proof complexity ↔ Information theory

**Lineage**: Direct application of this cycle's depth lower bound theorems.

**Ambition**: extension
