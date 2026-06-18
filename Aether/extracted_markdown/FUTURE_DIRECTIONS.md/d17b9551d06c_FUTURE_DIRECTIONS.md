# Future Directions: Depth Rigidity of Recursive Majority

## Synthesis

This work establishes the first formally verified depth rigidity bounds for recursive ternary majority: the monotone formula/circuit depth lies between n and 3n, where n is the recursion depth. The lower bound n comes from a variable-counting argument (3^n variables force depth ≥ log₂(3^n) > n), while the upper bound 3n comes from encoding the ternary majority gate as binary AND/OR (depth 3 per layer). The remaining gap factor of 3 is the central open question. Closing it requires either a tighter lower bound via Karchmer–Wigderson game decomposition, or a clever circuit construction that shares subcircuits across majority layers. All five directions below attack different facets of this gap, from exact communication complexity to generalized arity, SAT-based search, cross-domain transfer, and renormalization-theoretic interpretations.

---

## Direction 1: Exact Karchmer–Wigderson Communication Cost

**Conjecture:** For all n ≥ 0, the monotone Karchmer–Wigderson communication cost of RecMaj_n equals 3n, i.e., MonotoneKWCost(RecMaj_n) = 3n.

**Test:** For n = 1 and n = 2, enumerate all possible deterministic communication protocols and verify that no protocol of cost < 3n solves the monotone KW game. For n = 1 (3 variables), this is a finite computation over 2³ × 2³ pairs. For n = 2 (9 variables), the game has at most 2⁹ × 2⁹ ≈ 260K pairs, still computationally feasible. A protocol achieving cost < 3n for any n would disprove the conjecture.

**Impact:** Would give exact monotone formula depth = 3n (by the KW theorem), which combined with our transfer theorem gives exact monotone circuit depth ≥ 3n. This would fully close the gap in our depth rigidity result.

**Catalog References:**
- `Pythagorean/MonotoneCircuitComplexity.lean`: Transfer Theorem (Theorem 4)
- `Pythagorean/RecursiveMajorityDepthRigidity.lean`: recMaj_formula_depth_lower, recMaj_circuit_depth_lower

**Proof Strategy:** Prove a one-level decomposition lemma: any KW protocol for RecMaj_{n+1} must identify which of the three top-level blocks contains a distinguishing pair, costing at least 3 communication bits (one for each gate in the binary encoding of maj3). Then compose inductively: KW(RecMaj_{n+1}) ≥ 3 + KW(RecMaj_n).

**Domain Bridges:** Communication complexity ↔ monotone circuit complexity ↔ formula complexity.

**Lineage:** Extends the variable-counting lower bound (Theorem 3) to an exact characterization.

**Ambition:** Grand challenge — resolving this would establish RecMaj as a canonical benchmark for KW games.

---

## Direction 2: Arity Generalization to Odd Majority

**Conjecture:** For every fixed odd arity k = 2m+1, the recursive k-ary majority function RecOddMaj(k, n) on k^n inputs has monotone circuit depth exactly cn, where c is the depth of the optimal binary formula for Maj_k.

**Test:** For k = 5 (majority of 5), compute the optimal binary formula depth for Maj_5 (which is 5, since Maj_5 requires depth 5 with binary AND/OR). Verify by exhaustive search for n = 1, 2 that no shallower circuit exists. For k = 3, c = 3 (our current result). For k = 5, test whether c = 5 or some lower value.

**Impact:** Would reveal whether the depth rigidity phenomenon is universal across all odd majority arities, or specific to ternary majority. A deviation would be scientifically significant.

**Catalog References:**
- `Pythagorean/RecursiveMajorityDepthRigidity.lean`: All main theorems generalize to odd arity.
- `Pythagorean/MonotoneCircuitComplexity.lean`: iterComposeFamily provides the general framework.

**Proof Strategy:** Generalize recMaj to recOddMaj(k, n) using iterComposeFamily with f = Maj_k. The variable-counting lower bound generalizes immediately: k^n variables give depth ≥ n · log₂(k). The upper bound construction generalizes by encoding Maj_k as binary AND/OR.

**Domain Bridges:** Threshold logic ↔ circuit complexity ↔ extremal combinatorics.

**Lineage:** Direct generalization of Theorems 1–4 from arity 3 to arbitrary odd arity.

**Ambition:** Solid extension — straightforward but valuable generalization.

---

## Direction 3: SAT-Based Exact Depth Determination

**Conjecture (RM-SAT-3):** No monotone circuit of depth 2 computes RecMaj_3 (on 27 inputs).

**Test:** Encode the existence of a depth-2 monotone circuit with bounded fan-in computing RecMaj_3 as a SAT instance. The encoding:
- Variables encode gate types (AND/OR) and connections.
- Clauses enforce monotonicity (no negation gates).
- Clauses enforce semantic correctness on a sufficient set of input/output pairs.
- Run a modern SAT solver (e.g., CaDiCaL). If UNSAT, the hypothesis is confirmed. If SAT, extract and verify the witness circuit.

**Impact:** Empirical confirmation or refutation of exact depth bounds for small n. A SAT-found circuit of unexpectedly low depth would immediately disprove the strongest depth rigidity conjecture.

**Catalog References:**
- `Pythagorean/RecursiveMajorityDepthRigidity.lean`: recMaj_circuit_depth_lower (our formal lower bound n ≤ depth).

**Proof Strategy:** N/A (computational experiment). Results feed back into conjecture refinement.

**Domain Bridges:** SAT solving ↔ circuit complexity ↔ formal verification.

**Lineage:** Complements the formal lower bound with computational upper/lower bound evidence.

**Ambition:** Solid extension — feasible with current SAT technology.

---

## Direction 4: Self-Similar Rigidity Schema

**Conjecture:** There exists a general "self-similar rigidity" metatheorem: for any monotone Boolean function f on k inputs and its recursive composition tree f^n on k^n inputs, the monotone circuit depth of f^n equals n · D(f) where D(f) is the monotone formula depth of f.

**Test:** Verify for f = AND_2 (D = 1, trivially rigid), f = OR_2 (D = 1), f = Maj_3 (D = 3, our result gives n ≤ depth ≤ 3n), and f = Threshold_{2,4} (majority of 4 inputs, which is not an odd majority). If the conjecture holds for Threshold_{2,4}, it applies beyond odd majority.

**Impact:** Would unify the EML depth hierarchy (from Catalog/Pythagorean/DagDepthHierarchy) with Boolean circuit depth rigidity into a single framework. Both results share the pattern: self-similar obstruction + transfer theorem → DAG depth rigidity.

**Catalog References:**
- `Pythagorean/DagDepthHierarchy/Theorems.lean`: dag_sharing_does_not_reduce_iterExp_depth — the EML analogue.
- `Pythagorean/MonotoneCircuitComplexity.lean`: circuit_depth_lb_of_formula_depth_lb — the transfer engine.

**Proof Strategy:** Abstract the common pattern: (1) define a recursive composition f^n, (2) prove a formula lower bound via KW game decomposition, (3) transfer to circuits via unfolding. Package steps (1)–(3) as a reusable metaschema parameterized by f and its KW analysis.

**Domain Bridges:** Monotone circuit complexity ↔ EML expression complexity ↔ renormalization group theory.

**Lineage:** Unifies the EML DAG hierarchy result with our Boolean circuit result.

**Ambition:** Grand challenge — a successful unification would open a new subfield.

---

## Direction 5: Renormalization and Information-Theoretic Lower Bounds

**Conjecture:** Each level of recursive majority carries Ω(1) bits of irreducible information-processing cost, measurable as mutual information between input blocks and output. No DAG sharing (common subexpression elimination) can amortize this cost across levels.

**Test:** For RecMaj_n with n ≤ 4, compute the mutual information I(block_i; output | other blocks) for each of the three top-level blocks. Verify that this quantity is bounded below by a positive constant independent of n. If the mutual information decays with n, the conjecture fails.

**Impact:** Would establish a clean information-theoretic interpretation of depth rigidity: each renormalization layer in the recursive majority tree requires irreducible communication/computation. This connects circuit complexity to statistical physics (where recursive majority is a canonical hierarchical model).

**Catalog References:**
- `Pythagorean/RecursiveMajorityDepthRigidity.lean`: recMaj_depends_on_var (each variable is pivotal).
- `Pythagorean/DagDepthHierarchy/Theorems.lean`: The analogous result for EML.

**Proof Strategy:** Define a formal notion of "per-layer information cost" using conditional entropy. Show that the self-similar structure of RecMaj forces each layer to process at least c > 0 bits that cannot be precomputed or shared. The variable-counting argument is a discrete version of this: 3^n distinct variables require log₂(3^n) = n·log₂(3) bits to index.

**Domain Bridges:** Information theory ↔ statistical physics ↔ circuit complexity ↔ renormalization group.

**Lineage:** Provides a physical/information-theoretic interpretation of the formal mathematical results.

**Ambition:** Grand challenge — connecting circuit depth rigidity to renormalization theory would be paradigm-shifting.
