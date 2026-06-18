# Future Directions: Tropical Valuation Observer Duality

## 1. Full Prime-Spectrum Classification for Finitely Generated Tropical Semimodules

**Conjectural Theorem Statement:**
For a finitely generated semimodule $M$ over an idempotent semiring $T$, two elements $m_1, m_2 \in M$ are equal if and only if they agree on every prime congruence of $M$:
$$m_1 = m_2 \iff \forall \mathfrak{p} \in \mathrm{Spec}(M),\ m_1 \equiv m_2 \pmod{\mathfrak{p}}$$

**Required Lean Objects:**
- `TropicalSemimodule T M` — semimodule over an idempotent commutative semiring
- `PrimeCongruence M` — congruence $\theta$ on $M$ such that $M/\theta$ is "subdirectly irreducible"
- `Spec M` — the set of prime congruences
- `separation_by_primes` — theorem that equality = intersection of all prime congruences

**Why It Opens a New Direction:**
This would establish a tropical analogue of the Nullstellensatz: points in tropical geometry are separated by their "prime coordinate data." Applied to leakage semantics, it would mean that every leakage distinguisher factors through a prime congruence, giving a complete algebraic classification of distinguishing attacks.

**Proof Strategy:**
Adapt the Birkhoff subdirect representation theorem to the idempotent semiring setting. The key lemma is that every finitely generated semimodule embeds into a subdirect product of subdirectly irreducible quotients, and the kernels of these projections are precisely the prime congruences.

---

## 2. Weighted Leakage Channels with Tropical Entropy Invariants

**Conjectural Theorem Statement:**
Define a tropical entropy functional $H_T : (C/{\sim_{O,v}}) \to T$ by
$$H_T([c]) = \bigoplus_{i \in \iota} v(O_i(c))$$
(where $\oplus$ is tropical addition = min). Then:
- $H_T$ is monotone under observer refinement
- $H_T$ characterizes the "tropical information content" of a leakage class
- For weighted observer families with costs $w_i$, the weighted tropical entropy $H_T^w([c]) = \bigoplus_i (w_i \otimes v(O_i(c)))$ satisfies a chain rule under observer composition

**Required Lean Objects:**
- `TropicalEntropy` — definition of $H_T$ on quotient classes
- `WeightedObserverFamily` — observer family with cost weights in $T$
- `tropical_entropy_monotone` — monotonicity under refinement
- `tropical_entropy_chain_rule` — chain rule for weighted composition

**Why It Opens a New Direction:**
This creates a tropical information theory, where Shannon entropy is replaced by a min-plus invariant. The chain rule would enable compositional security analysis: the leakage of a composed system is bounded by the tropical sum of component leakages. This could formalize the intuition behind masking countermeasures in side-channel cryptography.

---

## 3. Categorical Functoriality of Leakage Realization

**Conjectural Theorem Statement:**
Define a category $\mathbf{Leak}$ whose objects are triples $(C, O, v)$ (configuration space, observer family, valuation) and morphisms $f : (C_1, O_1, v_1) \to (C_2, O_2, v_2)$ are maps $f : C_1 \to C_2$ such that observational indistinguishability is preserved. Then the minimal realization construction
$$\mathcal{R} : \mathbf{Leak} \to \mathbf{SemiMod}_T$$
is a functor from the leakage category to the category of $T$-semimodules.

**Required Lean Objects:**
- `LeakageCategory` — category structure on $(C, O, v)$ triples
- `SemimoduleCategory` — category of $T$-semimodules (may exist partially in Mathlib)
- `RealizationFunctor` — the functor $\mathcal{R}$
- `functor_preserves_minimality` — the functor sends minimal realizations to minimal realizations

**Why It Opens a New Direction:**
This would enable systematic study of how leakage behaves under system transformations: encryption, composition, protocol steps. The functor would automatically track how leakage classes transform, enabling machine-verified security composition theorems. It also connects leakage theory to the broader categorical framework for automata theory (Goguen's work on machines in categories).

---

## 4. Adversarial Reconstruction Bounds: Tropical Rank vs. Attack Complexity

**Conjectural Theorem Statement:**
Define the tropical rank of a leakage system $(C, O, v)$ as the number of distinct valuation signatures:
$$\mathrm{rank}_T(C, O, v) = |\{sig_{O,v}(c) : c \in C\}|$$
Then for any adversary $\mathcal{A}$ that reconstructs secret configurations from leakage observations:
- The adversary's success probability is bounded by $1/\mathrm{rank}_T(C, O, v)$
- Reconstructing the exact leakage realization requires $\Omega(\mathrm{rank}_T)$ observations
- If the observer family is enriched (more observers added), the rank can only increase, and the adversary's task becomes strictly harder

**Required Lean Objects:**
- `tropical_rank` — cardinality of the signature image
- `AdversaryModel` — formalization of a leakage-based adversary
- `reconstruction_lower_bound` — rank-based lower bound on attack complexity
- `rank_monotone_under_enrichment` — rank is monotone under observer addition

**Why It Opens a New Direction:**
This creates quantitative security guarantees from algebraic invariants. Current side-channel security proofs typically use statistical or information-theoretic arguments. Tropical rank provides a combinatorial/algebraic alternative that could be more amenable to formal verification and could yield tighter bounds in specific settings (e.g., when the leakage is deterministic).

---

## 5. Tropical Hankel Matrix Realization and Automata-Theoretic Leakage Models

**Conjectural Theorem Statement:**
Construct a tropical Hankel matrix $H \in T^{P \times S}$ where rows are indexed by "prefixes" (past observations) and columns by "suffixes" (future observations), with entries being tropicalized observation values. Then:
- The tropical rank of $H$ equals the number of states in the minimal deterministic leakage automaton
- $H$ admits a factorization $H = L \otimes R$ (in tropical matrix multiplication) where $L$ encodes the reachability map and $R$ the observation map
- This factorization is unique up to tropical semimodule isomorphism of the middle factor
- The factorization can be computed from $H$ in polynomial time

**Required Lean Objects:**
- `TropicalHankelMatrix` — the Hankel matrix construction
- `tropical_matrix_rank` — rank of a matrix over a tropical semiring
- `HankelFactorization` — structure for $H = L \otimes R$ factorizations
- `hankel_factorization_unique` — uniqueness up to isomorphism
- `hankel_to_automaton` — construction of minimal leakage automaton from factorization

**Why It Opens a New Direction:**
This is the deepest connection point: it brings the full power of weighted automata theory (Schützenberger, Berstel–Reutenauer, Droste–Kuich) into cryptographic leakage analysis. The Hankel matrix approach has been spectacularly successful in learning theory (Angluin's L* algorithm, spectral learning of HMMs). Transplanting it to the tropical/cryptographic setting would enable:
- Algorithmic extraction of minimal leakage models from observed data
- Formal complexity bounds on leakage model identification
- Connection to tropical geometry via tropical rank and Kapranov's theorem

---

## Cross-Cutting Theme

All five directions share a common thread: **making leakage algebraically visible**. The current work establishes the foundational bridge (signatures, quotients, minimal realizations). These future directions extend it into:
- Algebraic geometry (prime spectra)
- Information theory (tropical entropy)
- Category theory (functorial composition)
- Complexity theory (rank bounds)
- Automata theory (Hankel realization)

Each direction can be pursued independently, but the most powerful results will come from combining them—for example, using the categorical framework (Direction 3) to compose the Hankel realization (Direction 5) with the prime-spectrum classification (Direction 1), yielding a complete structural theory of composable leakage automata classified by tropical algebraic invariants.
