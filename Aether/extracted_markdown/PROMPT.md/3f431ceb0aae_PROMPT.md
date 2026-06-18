Complete the Entropic Proof Complexity formalization. The file Catalog/Bridges/ProofEntropy.lean has correct definitions (ProofRule, FormalProof, ruleCounts, numSteps, numRulesUsed, proofEntropy) but the theorem proofs are stubs. Your task:

1. Keep all existing definitions unchanged.

2. Prove the core lemma `entropyBound`: For any probability distribution (implemented as a PMF from Mathlib.Probability.ProbabilityMassFunction) on a Finset of cardinality r, the Shannon entropy is at most log₂(r). Strategy: Use Mathlib's `PMF.entropy` and the fact that the uniform distribution maximizes entropy. This follows from Jensen's inequality since -x·log₂(x) is concave. Look in Mathlib for `PMF.entropy_le_log_card` or similar, or construct the proof from `convexOn_log` / `concaveOn_neg_mul_log` results.

3. Prove `maxEntropy_bound`: If π : FormalProof n is nonempty and uses r distinct rules, then proofEntropy π ≤ log₂(r). Strategy: Construct a PMF from ruleCounts π / numSteps π, show its support has cardinality ≤ r, and apply entropyBound.

4. Prove `entropyCompression_bound`: If π has length N > 0, then proofEntropy π ≤ log₂(N). Strategy: Since r ≤ N (distinct rules ≤ total steps), compose maxEntropy_bound with the monotonicity of log₂.

5. REMOVE all unrelated content (prime number theorems, clique complexes, Belnap logic, etc.).

6. Every `sorry` must be eliminated. Every proof must be complete and compile.

Key Mathlib references to search:
- `Mathlib.Probability.ProbabilityMassFunction.Basic` for PMF construction
- `Mathlib.Probability.ProbabilityMassFunction.Entropy` or similar for entropy bounds
- `Mathlib.InformationTheory.Entropy` for Shannon entropy definitions
- `Mathlib.Analysis.Convex.Jensen` for Jensen's inequality
- `Mathlib.Data.Fintype.Card` for finite set cardinality