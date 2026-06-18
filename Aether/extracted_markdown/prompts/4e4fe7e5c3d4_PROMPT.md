Create a CLEAN, SELF-CONTAINED file `Catalog/Bridges/ProofEntropy.lean` containing ONLY the entropic proof complexity framework. Do NOT include any ECOC, multigraph, Eulerian trail, or other unrelated content.

## Definitions

1. `ProofRule n := Fin n` — the type of inference rules (n possible rules).
2. `FormalProof n := List (Fin n)` — a proof is a sequence of rule applications.
3. `ruleCounts (π : FormalProof n) : Fin n → ℕ` — count of each rule in the proof.
4. `numSteps (π : FormalProof n) : ℕ := π.length` — total proof length N.
5. `numRulesUsed (π : FormalProof n) : ℕ` — number of distinct rules appearing (cardinality of the support of ruleCounts).
6. `proofEntropy (π : FormalProof n) : ℝ` — Shannon entropy of the rule frequency distribution: H(π) = -Σᵢ (nᵢ/N) log₂(nᵢ/N), where nᵢ = ruleCounts π i and N = numSteps π. Handle the 0-probability case (0 · log 0 = 0) and the empty proof case (H = 0).

## Main Theorems

**Theorem 1 (Maximum entropy bound):** For any nonempty proof π using r distinct rules, `proofEntropy π ≤ log₂ r`. This follows because the uniform distribution on r outcomes maximizes entropy at log₂(r), and the empirical distribution is supported on at most r outcomes.

**Theorem 2 (Entropy-compression bound):** For any nonempty proof π of length N, `proofEntropy π ≤ log₂ N`, equivalently `N ≥ 2^(proofEntropy π)`. Proof: H = log₂(N) - (1/N)Σ nᵢ log₂(nᵢ). Since each nᵢ ≥ 1, we have nᵢ log₂(nᵢ) ≥ 0, so H ≤ log₂(N).

## Implementation Notes

- Use `Mathlib.InformationTheory.Entropy` or `Mathlib.Probability.ProbabilityMassFunction` if helpful, but a direct real-valued computation is also fine.
- For Theorem 1, use the fact that for a probability distribution on a finite set of size r, the entropy is maximized by the uniform distribution (prove via concavity of log or via the inequality log(x) ≤ x-1 applied to pᵢ/(1/r)).
- For Theorem 2, the key identity is: H = log₂(N) - (1/N) Σᵢ nᵢ log₂(nᵢ), and each term nᵢ log₂(nᵢ) ≥ 0 since nᵢ ≥ 1.
- Define a helper `entropyBound` lemma for the general inequality that entropy of a finitely-supported distribution is at most the log of the support size.
- Keep the file SHORT and FOCUSED — under 300 lines, no unrelated content.