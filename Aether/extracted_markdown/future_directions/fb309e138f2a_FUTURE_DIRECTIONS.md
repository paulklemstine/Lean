# Future Directions: Equi-Lipschitz Control and Uniform Maslov Dequantization

## Synthesis

This cycle attacked *Future Direction 4* of `Catalog/Tropical/AmoebaRonkin.lean` — the
gradient/Lipschitz control of the Maslov-deformed Ronkin function — and closed its
quantitative core in `Catalog/Tropical/AmoebaRonkinLipschitz.lean`. The amoeba spine
`trop f(x) = max_i (log|c_i| + ⟨m_i, x⟩)` and its smooth deformation
`R_t(x) = t·log Σ_i exp(A_i(x)/t)` are now both shown to have **slope confined to the
monomial support**, with a modulus that is *uniform in the deformation parameter `t`*. The
decisive observation is that the log-sum-exp inequality
`Σ_i e^{(A_i y + s_i)/t} ≤ e^{S/t} Σ_i e^{A_i y/t}` (with `S = max_i s_i`) is the analytic
shadow of `Finset.le_sup'`, and the single power of `t` in the factor `e^{S/t}` is exactly
the one the outer `t·log` cancels. This is the same `t`-cancellation that powers the
free-energy estimates of `SemiclassicalLimit.lean` and `LSEConvexity.lean`, so the result is
genuinely cross-domain.

## Results Summary (this cycle)

All in `Catalog/Tropical/AmoebaRonkinLipschitz.lean`, `sorry`-free:

- `abs_affLin_sub_le` / `affLin_sub_le_l1`: the linear part is `ℓ¹`-Lipschitz,
  `|⟨m,x⟩ − ⟨m,y⟩| ≤ Σ_j |m_j|·|x_j − y_j|`.
- `tropPoly_sub_le_sup_slope`: the spine increment is bounded by the largest monomial slope,
  `trop f(x) − trop f(y) ≤ max_i ⟨m_i, x − y⟩`.
- `ronkinDeform_sub_le_sup_slope` (**headline**): *the same* bound holds for `R_t`,
  uniformly in `t > 0`.
- `abs_tropPoly_sub_le`, `abs_ronkinDeform_sub_le`: two-sided forms exhibiting
  `{R_t}_{t>0} ∪ {trop f}` as an **equi-Lipschitz family** with common modulus
  `max_i Σ_j |m_{i,j}|·|x_j − y_j|`.

These supply precisely the gradient bound that `AmoebaRonkin.lean`'s pointwise
`maslov_tendsto` was missing.

## Direction 1 — Locally uniform Maslov dequantization via Arzelà–Ascoli

Conjecture: the convergence `R_t → trop f` (currently only pointwise, via `maslov_tendsto`
and `maslov_dequantization_rate`) is in fact **uniform on every compact set** of
log-modulus space. The key insight is that the two ingredients are now both in hand:
`abs_ronkinDeform_sub_le` gives a `t`-independent equicontinuity modulus, and
`maslov_dequantization_rate` gives the pointwise rate `t·log N`; equicontinuity plus
pointwise convergence is exactly the hypothesis of the Arzelà–Ascoli / Dini upgrade. Why
now? Both halves were proven in the last two files of this catalog, so the only remaining
step is to package the equi-Lipschitz bound as `Equicontinuous` and invoke Mathlib's
`Metric`/`UniformlyConvergent` API — a falsifiable, mechanical assembly with no new
analytic content required.

## Direction 2 — Sharpness: the equi-Lipschitz modulus is attained

Conjecture: the modulus `max_i Σ_j |m_{i,j}|·|x_j − y_j|` of `abs_tropPoly_sub_le` is
**sharp**, i.e. for every support `{m_i}` there exist `x ≠ y` realising equality, and the
optimal global Lipschitz constant of `trop f` in the `ℓ∞ → ℝ` sense is exactly
`max_i ‖m_i‖₁`. The key insight is that the bound degenerates to equality precisely when a
single monomial `k` dominates at both `x` and `y` and `x − y` is aligned with `sign(m_k)`,
which is the interior of a `dominantRegion` — connecting the Lipschitz constant directly to
the order map `tropPoly_slope_on_dominant`. Why now? `dominantRegion_convex` already gives a
nonempty open polyhedron to choose `x, y` from, so sharpness becomes an explicit witness
construction rather than an existence argument.

## Direction 3 — Equi-Lipschitz ⟹ derivative of the limit equals the a.e. limit of derivatives

Conjecture: on the open dominance region `dominantRegion c m k`, the gradients converge,
`∇R_t → m_k = ∇(trop f)` as `t → 0⁺`, uniformly on compact subsets. The key insight is that
an equi-Lipschitz family that converges pointwise to a function which is *affine* on an open
set must have its gradients converge there (the limit's derivative is forced, and
equicontinuity rules out oscillation), so the abstract order map of
`tropPoly_slope_on_dominant` is recovered as a genuine analytic gradient limit. Why now? The
slope bound `ronkinDeform_sub_le_sup_slope` already pins `∇R_t` inside `conv{m_i}`; combined
with strict dominance of monomial `k` it collapses the gradient onto the single vertex `m_k`.

## Direction 4 — Strict convexity transverse to the recession cone

Conjecture: `R_t` is **strictly** convex in every direction `v` not orthogonal to all
differences `m_i − m_j`, the non-strict directions forming exactly the lineality space
`⋂_{i,j}(m_i − m_j)^⊥`. The key insight is that `ronkinDeform_convexOn` (already proven in
`AmoebaRonkin.lean`) routes through the finite Hölder inequality, and Hölder is an equality
iff the two summed vectors are proportional — pinning the failure of strictness to precisely
the recession directions of the spine. Why now? The convexity proof has already isolated the
Hölder step, so only Mathlib's equality-case lemma for `inner_le_Lp_mul_Lq` is missing,
turning a qualitative statement into a sharp characterisation.

## Direction 5 — Cross-domain export: equi-Lipschitz free energy in the field

Conjecture: under the dictionary `t = 1/β`, `A_i(x) = −H_i(x)` (energy at external field
`x`), `R_t = −F(β)`, the theorem `abs_ronkinDeform_sub_le` *is* the statement that the
finite-volume free energy is Lipschitz in the external field with a `β`-independent constant
`max_i ‖m_i‖₁`, hence the magnetization (its subgradient) is uniformly bounded across all
temperatures. The key insight is that the `t`-cancellation here and the `β`-cancellation in
`SemiclassicalLimit.lean` are the *same* algebraic identity, so a single bridging file could
prove the dictionary by `rfl`/`simp` and export equi-Lipschitzness as a thermodynamic
stability theorem. Why now? Both the amoeba and statistical-mechanics halves are now
formalized with matching log-sum-exp cores, so the bridge is a finite chain of definitional
rewrites rather than new mathematics.
