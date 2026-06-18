Produce one small, complete Lean 4 file formalizing a finite classical surrogate of integrated information for bit chains, closely aligned with the original concept but deliberately narrowed so the development is fully finished and typechecks.

Target problem:
For a fixed n : ℕ, model a classical n-bit state as a probability mass function p : (Fin n → Bool) → ℝ together with hypotheses expressing nonnegativity and total mass 1 over the finite configuration space. For a cut k with k ≤ n, define the left and right blocks and the induced marginals. Then define a simple bipartition score detecting whether p factorizes across the cut. Finally define Phi_min as the minimum of this score over all nontrivial cuts, and prove that factorized/product distributions have Phi_min = 0 whenever a nontrivial witnessing cut exists.

Required scope and structure:
1. Stay entirely within finite classical probability on bit strings. Do not introduce tensor networks, quantum states, Jacobians, unrelated algebra, or speculative physics abstractions.
2. Use only a small number of definitions that can be fully supported by finished proofs.
3. Prefer computable finite-sum definitions over abstract measure theory.
4. The final file must be complete: no `sorry`, no placeholders, no interrupted proofs, no unused theorem stubs.

Suggested mathematical plan:
A. Basic combinatorial infrastructure
- Represent full configurations as `Fin n → Bool`.
- For a cut `k : ℕ` with proof `hk : k ≤ n`, define a way to split a configuration into:
  - left assignment on `Fin k`
  - right assignment on `Fin (n-k)`
- Define the recombination map from left/right assignments back to a full assignment.
- Prove the split/recombine inverse lemmas needed for later finite-sum manipulations.

B. Probability distribution and marginals
- Define a predicate such as `IsProbDist p` meaning:
  - `∀ x, 0 ≤ p x`
  - `∑ x, p x = 1`
  where the sum is over the finite type `(Fin n → Bool)`.
- For a cut `k ≤ n`, define:
  - `leftMarginal p hk : (Fin k → Bool) → ℝ`
  - `rightMarginal p hk : (Fin (n-k) → Bool) → ℝ`
  by summing over the opposite block.
- Keep these definitions elementary and explicit.

C. Cut factorization / independence
- Define `CutIndependent p hk` to mean:
  for every left assignment `a` and right assignment `b`,
  `p (recombine hk a b) = leftMarginal p hk a * rightMarginal p hk b`.
- Alternatively, if this exact form is cumbersome, define a stronger but easier-to-use predicate `FactorsAcross p hk` by existentially providing left/right functions `pl`, `pr` with
  `p (recombine hk a b) = pl a * pr b`,
  and then separately show that when `pl`, `pr` are the actual marginals under probability hypotheses, cut independence follows. But prefer the direct marginal formulation if manageable.

D. Simple cut score and integrated-information surrogate
- Define `cutScore p hk : ℕ` or `ℝ` by
  - `0` if `CutIndependent p hk`
  - `1` otherwise.
- Define the set of nontrivial cuts as `k` with `1 ≤ k` and `k < n`.
- Define `PhiMin p : ℕ` or `ℝ` as the minimum of `cutScore p hk` over nontrivial cuts.
  If defining the minimum over a dependent finite set is awkward, use an equivalent formulation such as:
  - `PhiMin p = 0` iff there exists a nontrivial cut with score 0,
  - `PhiMin p = 1` otherwise,
  implemented directly by decidable existence over `Finset.range (n+1)` with boundary checks.
  The goal is a robust formalization, not maximal elegance.

Required theorems:
1. A theorem that explicitly factorized distributions have score 0 at the witnessing cut.
   Example shape:
   `theorem cutScore_eq_zero_of_factorization ...`
2. A theorem that if there exists a nontrivial cut across which `p` is independent/factorized, then `PhiMin p = 0`.
   Example shape:
   `theorem phiMin_eq_zero_of_exists_factorization ...`
3. If you define a constructor for product distributions from left/right factors, prove the resulting distribution is cut-independent at that cut.
4. Include at least one concrete example distribution on a small chain (for example n = 2 or n = 3) where the theorem applies.

Optional extension only if easy and fully complete:
- Define Shannon entropy / mutual information for finite strictly positive distributions and prove:
  factorization across a cut implies mutual information 0.
- This is optional and should only be attempted if the core development is already complete.

Implementation guidance:
- Prefer `Fintype` sums over function spaces like `(Fin n → Bool)`.
- Keep notation light and local.
- Use helper lemmas for `Fin.append`-style decomposition or equivalent explicit piecewise definitions.
- If dependent indexing over `k ≤ n` becomes awkward, package the cut as a structure containing `k` and the proof `k ≤ n`.
- It is acceptable to define `PhiMin` in the simplest way that makes the main theorem easy to prove.

What to avoid:
- No unrelated imports or domains.
- No grand theorem statements beyond what is proved.
- No partial entropy infrastructure unless it is actually used and completed.

Deliverable:
A single self-contained Lean file in an information-theory or combinatorics-appropriate catalog location, with concise module documentation explaining the surrogate notion of integrated information and the exact theorems proved.