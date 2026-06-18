Repair `Catalog/Probability/SpeciesBoltzmannBridge.lean` only. Do not create new files, do not switch domains, and do not include unrelated material. The previous attempt was malformed and mixed with extraneous code, so this retry must be a minimal sorry-elimination pass that produces one compiling Lean file focused solely on the linear-order species / geometric Boltzmann bridge.

Concrete objective: remove every remaining `sorry` needed to derive the linear-order Boltzmann expectation theorem, but simplify the path aggressively if necessary. You may refactor definitions inside this same file to reduce dependence on broken species scaffolding, provided the mathematical content remains: the Boltzmann size law for linear orders is geometric.

Required mathematical scope:
1. Define the partition function for parameter `x : ℝ` as `Z x = ∑' n : ℕ, x^n` (or reuse the existing definition if sound).
2. Prove the closed form `Z x = (1 - x)⁻¹` under hypotheses `0 ≤ x` and `x < 1`.
3. Define the normalized pmf `p_x n = x^n / Z x`, and then prove the explicit formula `p_x n = (1 - x) * x^n`.
4. Prove `0 ≤ p_x n` and `∑' n, p_x n = 1`.
5. Prove the expectation formula `∑' n, (n : ℝ) * p_x n = x / (1 - x)`.
6. Only after the above is complete, add a lightweight bridge lemma identifying this with the linear-order species coefficient, e.g. `((n.factorial : ℝ) / (n.factorial : ℝ)) = 1` or an equivalent already-compatible statement. Do not force a complicated species API if it obstructs completion.

Proof strategy to follow:
- First inspect the actual file and preserve any good existing definitions/theorem names where possible.
- Use standard Mathlib summability results for geometric series over `ℝ`, especially `tsum_geometric`-style lemmas.
- For the expectation, rely on an existing theorem for `∑' n, (n : ℝ) * x^n = x / (1 - x)^2` if available; otherwise prove it via a known geometric power-series lemma already in Mathlib, not by inventing a long bespoke analysis development.
- Keep the dependency chain short: partition function -> pmf closed form -> expectation.
- Remove or delete any extraneous declarations from the malformed prior attempt if they block compilation.

Important constraints:
- Stay in `Catalog/Probability/SpeciesBoltzmannBridge.lean` only.
- No new speculative abstractions.
- No unrelated imports beyond what is needed.
- No placeholders, no `sorry`, no truncated theorem bodies.
- Prefer a small complete result over a broad incomplete one.

Deliver a clean, standalone file whose main theorem is the Boltzmann mean formula for the linear-order/geometric distribution.