# Computational Evidence — 1D Discrete Wasserstein (`Wasserstein1D.lean`)

All claims below were sanity-checked with small explicit distributions on the
integer grid `{0,…,n-1}` before formalization. The CDF form
`W₁(p,q) = ∑_{k<n} |F_p(k) - F_q(k)|` is used throughout.

## 1. Small-case calculations

Let `n = 3`.

* `p = (1,0,0)` (Dirac at 0), `q = (0,0,1)` (Dirac at 2).
  CDFs: `F_p = (1,1,1)`, `F_q = (0,0,1)`. `W₁ = 1+1+0 = 2 = |0-2|`. ✓ (Dirac isometry)
* `p = (1/2,0,1/2)`, `q = (0,1,0)`.
  `F_p = (1/2,1/2,1)`, `F_q = (0,1,1)`. `W₁ = 1/2 + 1/2 + 0 = 1`.
  Mean check: `mean p = 1`, `mean q = 1`, `|Δmean| = 0 ≤ 1`. ✓
* `p = (0,1,0)`, `q = (1/3,1/3,1/3)`.
  `F_p = (0,1,1)`, `F_q = (1/3,2/3,1)`. `W₁ = 1/3 + 1/3 + 0 = 2/3`.
  Means `1` and `1`; `|Δmean| = 0 ≤ 2/3`. ✓

## 2. Dirac isometry (`W1_dirac`)

For `n = 5` and all `a,b < 5`, `W₁(δ_a, δ_b)` computed from CDFs equals `|a-b|`
in every one of the 25 cases (checked by hand on the step-function indicators).
This is exactly the closed form `∑_k |[a≤k]-[b≤k]| = |a-b|`.

## 3. Kantorovich–Rubinstein duality (`kantorovich_duality`)

Optimal potential `φ` with `Δφ = -sign(F_p - F_q)`:
for `p=(1/2,0,1/2)`, `q=(0,1,0)` (`n=3`): `F_p-F_q = (1/2,-1/2,0)`,
so `Δφ = (-1,+1,*)`, giving `φ = (0,-1,0)`.
Then `𝔼_p[φ]-𝔼_q[φ] = (0·½ + (-1)·0 + 0·½) - (0·0 + (-1)·1 + 0·0) = 0-(-1) = 1 = W₁`. ✓
`φ` is `1`-Lipschitz (`|Δφ| ≤ 1`). ✓

## 4. Primal coupling bound (`W1_le_transportCost`)

For `p=(1/2,0,1/2)`, `q=(0,1,0)`, the only coupling is `π[0][1]=1/2`, `π[2][1]=1/2`,
cost `= |0-1|·½ + |2-1|·½ = 1 = W₁`. Every other (sub)plan with these marginals
has cost `≥ 1`. ✓ (lower bound tight here)

## 5. Counterexample hunt

* "`W₁` is a *pseudo*metric only" — refuted: `eq_of_W1_zero` shows `W₁(p,q)=0 ⇒ p=q`
  on the support, so it is a genuine metric. No counterexample found.
* "Mean difference can exceed `W₁`" — refuted on all tested pairs; the identity map
  is `1`-Lipschitz so `kantorovich_le` forbids it.
* "Some coupling beats the CDF value" — refuted: `W1_le_transportCost` proven for
  *all* couplings; tested plans never went below the CDF value.

## Note

No OEIS sequence arises (the objects are real-valued distances, not integer
sequences). Evidence is closed-form/arithmetic, hence kept brief; all statements
are now machine-verified in `Wasserstein1D.lean` (axioms: `propext`,
`Classical.choice`, `Quot.sound` only).
