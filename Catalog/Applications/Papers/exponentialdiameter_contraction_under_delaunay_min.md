# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: `Catalog/Applications/DelaunayContraction/Inhomogeneous.lean`
(namespace `DelaunayContraction.Inhomogeneous`) and the homogeneous base
`Catalog/Applications/DelaunayContraction/Contraction.lean`
(namespace `DelaunayContraction`).

Every result below is stated exactly as it appears in the Lean output. No result
is invented or upgraded to a grander claim.

## Structures / definitions

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `InhomogeneousContractionProcess` | structure: `d : ℕ → ℝ`, `a b : ℝ`, with `0 ≤ a`, `a < 1`, `0 ≤ b`, `∀k, 0 ≤ d k`, and `∀k, d (k+1) ≤ a·d k + b` | yes (the "noisy refinement" model) | yes (Def. 1) |
| `fixedPoint` | `L := b / (1 - a)` | yes (attractor radius) | yes (Def. 2) |
| `affineIteration` | concrete process with `d(k+1) = a·d k + b` exactly | yes (tightness witness) | yes (§ tightness) |
| `ContractionProcess` (homog.) | `d : ℕ → ℝ`, `lam > 1`, `d ≥ 0`, `d(k+1) ≤ (1/lam)·d k` | yes (background) | yes (background) |
| `segmentBisection` (homog.) | edge bisection `d k = D/2^k`, `lam = 2` | yes (segment example) | yes (base case) |

## Theorems / lemmas

| Lean name | Statement | ARTICLE | PAPER |
|---|---|---|---|
| `one_sub_a_pos` | `0 < 1 - a` | implicit | yes |
| `fixedPoint_nonneg` | `0 ≤ L` | yes | yes |
| `fixedPoint_eq` | `a·L + b = L` | yes | yes (Lem.) |
| `d_le_closedForm` | `d k ≤ a^k·d 0 + b·(1-a^k)/(1-a)` | yes (main) | yes (Thm. 1) |
| `closedForm_eq` | `a^k·d 0 + b(1-a^k)/(1-a) = a^k·(d 0 - L) + L` | yes | yes |
| `excess_le_pow` | `d k - L ≤ a^k·(d 0 - L)` | yes (main) | yes (Thm. 2) |
| `closedFormBound_tendsto` | closed-form bound `→ L` as `k→∞` | yes | yes |
| `eventually_lt_fixedPoint_add` | `∀ε>0, eventually d k < L + ε` | yes | yes (Thm. 3) |
| `exists_steps_below` | `∀ε>0, ∃N, ∀k≥N, d k < L + ε` | yes | yes (Cor.) |
| `tendsto_of_exact` | under `d(k+1)=a·d k+b`: `d k → L` | yes | yes (Thm. 4) |
| `dist_le_pow_of_exact` | under exact recurrence: `|d k - L| ≤ a^k·|d 0 - L|` | yes | yes (Thm. 4) |
| `d_le_uniform` | `d k ≤ d 0 + L` (trapped in `[0, d0+L]`) | yes | yes |
| `perturbation_le` | each step perturbs by `≤ b` | yes | yes |
| `affine_isFixedPt` | `x ↦ a·x+b` fixes `L` | yes | yes |
| `fixedPoint_unique` | `L` is the unique fixed point | yes | yes |
| `affine_dist` | `dist (f x) (f y) = a·dist x y` (contraction) | yes | yes |
| `diam_le_pow` (homog.) | `d k ≤ (1/lam)^k·d 0` | yes | yes |
| `diam_tendsto_zero` (homog.) | `d k → 0` | yes | yes |
| `minicenter_segment_halves` (homog.) | edge midpoint splits into two half-edges | yes | yes |
