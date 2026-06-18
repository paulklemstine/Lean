# Summary of changes for run 2d89815b-afa0-4594-a801-54f97a386544
## Entropy Power Inequality: Foundational Inequalities

### Deliverables

**Lean file**: `Catalog/Computation/EntropyPower/Core.lean` (176 lines, 0 sorries)
**Research directions**: `Catalog/Computation/EntropyPower/FUTURE_DIRECTIONS.md`

### Theorem Declarations

| # | Name | Status | Significance |
|---|------|--------|-------------|
| 1 | `shannonEntropy_nonneg` | **proved** | Shannon entropy H(p) ≥ 0 for any probability distribution on Fin n |
| 2 | `gibbs_inequality` | **proved** | KL divergence D(p‖q) ≥ 0 — the fundamental inequality of information theory, proved via Jensen's inequality for concave log |
| 3 | `shannonEntropy_le_log_card` | **proved** | Maximum entropy theorem: H(p) ≤ log n — derived as corollary of Gibbs by comparing to uniform distribution |
| 4 | `entropyPowerFn_convex` | **proved** | The entropy power function exp(2H/d) is convex — makes EPI remarkable since it asserts superadditivity of a convex function |

Plus supporting lemmas: `IsStrictProbDist.le_one`, `entropyPowerFn_pos`, `entropyPowerFn_mono` (all proved).

### Mathematical Content

The file formalizes the three foundational pillars of information theory:

1. **Non-negativity of Shannon entropy** — proved elementwise: each term p_i · log(p_i) ≤ 0 since 0 ≤ p_i ≤ 1.

2. **Gibbs' inequality** (D(p‖q) ≥ 0) — proved via Jensen's inequality (`ConcaveOn.le_map_sum`) applied to log on (0,∞). The key step is showing Σ p_i · (q_i/p_i) = Σ q_i = 1.

3. **Maximum entropy theorem** — proved by instantiating Gibbs' inequality with the uniform distribution q_i = 1/n, yielding H(p) = log n − D(p‖uniform) ≤ log n.

4. **Entropy power convexity** — proved via `convexOn_of_deriv2_nonneg`, establishing that exp(2h/d) is convex in h. This is structurally significant: the EPI asserts superadditivity of this convex function, which cannot hold for arbitrary convex functions and requires deep probabilistic content (Fisher information monotonicity or optimal transport).

### Key Insight

The entropy power inequality's truth cannot be derived from convexity/concavity arguments alone. The EPI is remarkable precisely because it asserts that exp(2H/n) — a *convex* function of entropy — is superadditive under convolution. An initial attempt to prove exp(a) + exp(b) ≤ exp(a+b) for positive reals was caught as **false** (counterexample: a = b = 0.1), demonstrating that the algebraic structure alone doesn't suffice.

### Axioms
All theorems depend only on `propext`, `Classical.choice`, and `Quot.sound` — standard and sound.