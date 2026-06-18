# Summary of changes for run 6b2c1259-7039-47a6-8f3e-c56c9bdf0fa6
## Summary

I extended the Neural Tangent Kernel (NTK) convergence theory along Research Direction #2 ("spectral convergence rate with eigenvalue decay"), building directly on the existing catalog files `MachineLearning/NTKCore.lean` and `MachineLearning/NTKSpectral.lean`.

### Build-config fix
The project's sources live under `Catalog/` but `lakefile.toml` had no `srcDir`, so the existing `import MachineLearning.…` statements could not resolve and nothing under `Catalog/` built. I added `srcDir = "Catalog"` to the package, which is the clearly intended configuration and now lets the catalog modules (and the new file) compile.

### New file: `Catalog/MachineLearning/NTKSpectralDecay.lean`
A self-contained, fully proved development (no `sorry`; only the standard axioms `propext`, `Classical.choice`, `Quot.sound`). It upgrades the previous *single-mode* spectral analysis to the *full multi-mode residual* and derives explicit iteration-complexity budgets. Ten theorems, all proved:

1. **Linearity of the residual map** — `gdResidual_add`, `gdResidual_smul`, `gdResidual_sum`: the gradient-descent residual is linear in the initial residual (it is iterated multiplication by `I − ηK`).
2. **Multi-mode residual formula** — `gdResidual_sum_eigenvectors`: for `u₀ = Σ_k c_k v_k` of eigenvectors, the modes decouple, `u_t = Σ_k c_k (1−ηλ_k)^t v_k`.
3. **Multi-mode geometric decay (capstone)** — `gdResidual_multimode_decay`: if every active mode contracts by `≤ ρ`, then `‖u_t‖ ≤ ρ^t · Σ_k |c_k| ‖v_k‖`, a genuine multi-mode analogue of the existing single-rate decay, proved with no orthogonality assumption.
4. **Geometric iteration complexity** — `geometric_iteration_complexity`: `ρ^t ≤ ε` once `t ≥ log ε / log ρ`.
5. **Condition-number complexity** — `optimalRate_log_contraction` (`log((κ−1)/(κ+1)) ≤ −2/(κ+1)`) and `optimalRate_iteration_complexity`: at the optimal learning rate, `O((κ+1)·log(1/ε))` steps suffice.
6. **Power-law spectrum** — `powerlaw_condition_number` (`1^{−α}/K^{−α} = K^α`) and `powerlaw_iteration_complexity`: for `λ_k = k^{−α}` over the top `K` modes the cost is `O(K^α·log(1/ε))` steps.

Each theorem carries a brief proof sketch as a `-- !-- … -- !--` comment. During cleanup I removed two genuinely unused hypotheses (`0 ≤ ρ` in the decay theorem and `1 ≤ K` in the condition-number identity) to keep the statements clean and general, and replaced leftover `exact?` calls with explicit proof terms. The module compiles warning-free.

### `Catalog/MachineLearning/FUTURE_DIRECTIONS.md`
Five falsifiable research conjectures extending the work (exact orthogonal energy identity; matching convergence lower bound; effective-dimension complexity; continuous-time exponential decay limit; kernel-perturbation Grönwall robustness), each with a "The key insight is…" sentence and a "Why now?" justification referencing the specific lemmas that make it tractable.