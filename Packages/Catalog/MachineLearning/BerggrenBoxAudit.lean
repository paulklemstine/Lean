import MachineLearning.BerggrenBoxDensity
import MachineLearning.BerggrenTreeFreeness
import MachineLearning.BerggrenBoxExact
import MachineLearning.BerggrenBoxRatio

/-!
# Audit: axiom checks and real numerical data for the box-counting theorems

Every `#print axioms` below must print only `propext`, `Classical.choice`, `Quot.sound`.
The `#eval`s produce the experimental data quoted in `ComputationalEvidence.md`.
-/

namespace BerggrenStars

#print axioms BerggrenStars.isNode_iff
#print axioms BerggrenStars.isNodeSwap_iff
#print axioms BerggrenStars.param_isNode
#print axioms BerggrenStars.isPPT_iff_node_or_swap
#print axioms BerggrenStars.not_isNode_and_isNodeSwap
#print axioms BerggrenSieve.card_coprimePairs_lower
#print axioms BerggrenStars.boxNode_card_le
#print axioms BerggrenStars.boxNode_card_ge
#print axioms BerggrenStars.boxNode_card_theta
#print axioms BerggrenStars.boxNode_density_zero
#print axioms BerggrenStars.boxBerggren_eq_boxPPT
#print axioms BerggrenStars.card_boxPPT_eq_two_mul
#print axioms BerggrenStars.applyGens_root_injective
#print axioms BerggrenStars.depth_forces_hypotenuse
#print axioms BerggrenStars.exists_deep_node_large
#print axioms BerggrenStars.card_euclidBox_eq_card_boxNode
#print axioms BerggrenStars.card_euclidBox_theta
#print axioms BerggrenStars.boxPPT_card_theta
#print axioms BerggrenStars.boxPPT_density_zero
#print axioms BerggrenStars.single_seed_ratio
#print axioms BerggrenStars.two_seed_ratio

/-! ### Fast standalone counters (used only for the numerical experiments) -/

/-- Number of primitive Pythagorean triples `(a,b,c)` with `a` odd and all entries `≤ H`,
counted directly from the Euclid parametrisation `m > n ≥ 1`, `gcd = 1`, `m - n` odd. -/
def nodeCount (H : ℕ) : ℕ :=
  ((List.range (H + 1)).flatMap fun m =>
    (List.range m).filterMap fun n =>
      if 1 ≤ n ∧ Nat.gcd m n = 1 ∧ (m + n) % 2 = 1 ∧ m * m + n * n ≤ H then some (m, n)
      else none).length

/-- Number of coprime opposite-parity pairs `0 < n < m ≤ N` (the sieve's `coprimePairs`). -/
def pairCount (N : ℕ) : ℕ :=
  ((List.range (N + 1)).flatMap fun m =>
    (List.range m).filterMap fun n =>
      if 1 ≤ n ∧ Nat.gcd m n = 1 ∧ (m + n) % 2 = 1 then some (m, n) else none).length

-- Cycle 1.  `nodeCount H` against the two proved bounds `H/128 ≤ · ≤ H`.
-- Columns: H, H/128 (proved lower bound), nodeCount H, H (proved upper bound).
#eval [64, 128, 256, 512, 1024, 2048, 4096].map fun H => (H, H / 128, nodeCount H, H)

-- Cycle 2.  The ratio `nodeCount H / H` should converge to `1/(2π) ≈ 0.15915`.
#eval [256, 1024, 4096, 16384].map fun H => (H, (10000 * nodeCount H) / H)

-- Cycle 3.  Density of coprime parity pairs: `pairCount N / N²` should converge to
-- `2/π² ≈ 0.202642`.  The proved lower bound is `1/16 = 0.0625`.
#eval [16, 64, 256, 512].map fun N => (N, (1000000 * pairCount N) / (N * N))

-- Cycle 4.  The three Berggren branches in Euclid coordinates: A(m,n) = (2m-n, m),
-- B(m,n) = (2m+n, m), C(m,n) = (m+2n, n), started at the root (2,1).
#eval (List.range 4).foldl (fun acc _ => acc.flatMap fun (m, n) =>
  [(2 * m - n, m), (2 * m + n, m), (m + 2 * n, n)]) [((2 : ℕ), (1 : ℕ))] |>.length

end BerggrenStars