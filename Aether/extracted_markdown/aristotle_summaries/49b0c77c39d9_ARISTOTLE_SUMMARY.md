# Summary of changes for run 10b5d4a9-1c70-492e-8abb-1b04f832be8f
## Quantum Thermodynamics: Landauer's Principle — Lean 4 Formalization

### Deliverables

**Two Lean 4 files** (sorry-free, fully verified) and a **FUTURE_DIRECTIONS.md**:

#### `QuantumThermo/ShannonEntropy.lean`
Defines `FinProbDist` (finite probability distributions) and `shannonEntropy`, and proves:

1. **`shannonEntropy_nonneg`** — Shannon entropy is non-negative for any finite probability distribution. Proved via `neg_entropy_term_nonneg`: each term p·log(p) ≤ 0 since 0 ≤ p ≤ 1.

2. **`uniform_entropy`** — The entropy of the uniform distribution on n elements equals log(n). Direct computation via sum of constant terms.

3. **`gibbs_inequality`** — Shannon entropy is maximized by the uniform distribution: H(p) ≤ log(n). Proved using the fundamental inequality log(x) ≤ x − 1 applied to x = 1/(n·p(i)), then summing over all states.

4. **`entropy_deterministic`** — For n = 1, entropy is 0 (boundary case).

#### `QuantumThermo/Landauer.lean`
Builds on ShannonEntropy to formalize the connection between information theory and thermodynamics:

5. **`jensen_exp_finite`** — Jensen's inequality for finite weighted sums: exp(∑ wᵢxᵢ) ≤ ∑ wᵢ exp(xᵢ). Uses Mathlib's `convexOn_exp` and `ConvexOn.map_sum_le`.

6. **`jarzynski_implies_second_law`** — The central theorem: from the Jarzynski equality ⟨exp(−βW)⟩ = exp(−βΔF), derives the second law ⟨W⟩ ≥ ΔF via Jensen's inequality and monotonicity of exp.

7. **`landauer_bound`** — Landauer's principle: erasing one bit from a uniform binary state requires dissipation Q ≥ (1/β)·ln(2) = kT·ln(2).

8. **`generalized_landauer`** — Partial erasure from n to m states costs at least kT·ln(n/m).

9. **`logical_thermo_irreversibility`** — Any state-space compression (n → m with m < n) has strictly positive entropy cost.

10. **`reversible_zero_cost`** — Bijective computation incurs zero entropy cost.

All 10 theorems are sorry-free and use only standard axioms (propext, Classical.choice, Quot.sound).

#### `FUTURE_DIRECTIONS.md`
Five research directions: finite-size fluctuation bounds via KL divergence, Crooks fluctuation theorem, quantum (von Neumann entropy) Landauer bound, entropy production and arrow of time, and the Szilard engine/Maxwell's demon cycle.