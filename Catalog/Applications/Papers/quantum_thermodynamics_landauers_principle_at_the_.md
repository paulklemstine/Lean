# THEOREM TRACE — Landauer's Principle as a Second-Law Inequality

Internal anti-hallucination ledger. Every theorem/definition below is taken
verbatim from the Phase A Lean output. Prose in `ARTICLE.md` and
`RESEARCH_PAPER.md` may only state these results.

## Source file: `Catalog/Physics/LandauerSecondLaw.lean` (namespace `LandauerSecondLaw`)

| Lean name | Mathematical statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `expect_add_one_le_expect_exp` | For PMF `p`, observable `g`: `1 + E_p[g] ≤ E_p[exp g]` | yes (plain language) | yes (Lemma 1) |
| `expect_centered_zero` | `E_p[ -α(W - E_p[W]) ] = 0` | yes | yes (Lemma 2) |
| `work_fluctuation_ge_one` | `1 ≤ E_p[ exp(-α(W - E_p[W])) ]` | yes | yes (Lemma 3) |
| `work_correction_nonneg` | `0 ≤ log E_p[ exp(-α(W - E_p[W])) ]` | yes | yes (Cor. 4) |
| `jarzynski_second_law` | For `α>0`, Jarzynski cond.: `ΔF ≤ E_p[W]` | yes (main thm) | yes (Thm 5) |
| `landauer_kT_bound` | `k,T>0`, Jarzynski at `α=(kT)⁻¹`, `ΔF=kT log 2`: `kT log 2 ≤ E_p[W]` | yes (main thm) | yes (Thm 6) |
| `landauer_cost_eq_entropy_loss` | `kT log 2 = kT (H(uniform) − H(erased))` | yes | yes (Thm 7) |
| `logical_to_thermodynamic_irreversibility` | erasure non-injective ⇒ `0 < E_p[W]` (positive dissipation) | yes | yes (Thm 8) |

## Source file: `Catalog/Logic/JarzynskiLandauer.lean` (namespace `JarzynskiLandauer`)

| Lean name | Mathematical statement |
|---|---|
| `expect` (def) | `expect p f = ∑_ω p ω · f ω` |
| `IsPMF` (def) | `(∀ω, 0 ≤ p ω) ∧ ∑_ω p ω = 1` |
| `JarzynskiCondition` (def) | `E_p[exp(-αW)] = exp(-α ΔF)` |
| `shannonEntropy` (def) | `∑_ω negMulLog(p ω)` (conv. `0 log 0 = 0`) |
| `uniformBool` (def) | `fun _ => 1/2` |
| `erasedBool` (def) | `fun b => if b then 0 else 1` |
| `erasure` (def) | `fun _ => false` |
| `entropy_uniformBool` | `H(uniformBool) = log 2` |
| `entropy_erasedBool` | `H(erasedBool) = 0` |
| `erasure_not_injective` | `¬ Injective erasure` |
| `entropy_loss` | `H(uniformBool) − H(erasedBool) = log 2` |
| `jarzynski_correction` | `E[W] = ΔF + α⁻¹ log E[exp(-α(W-E[W]))]` |
| `landauer_identity` | specialization with `ΔF = (H_u - H_e)/α` |

## Source file: `Catalog/Computation/LandauerLowerBound.lean` (namespace `LandauerLowerBound`)

| Lean name | Mathematical statement |
|---|---|
| `pushforwardFun` (def) | `f∗p (y) = ∑_{x: f x = y} p x` |
| `pushforwardFun_apply_ge` | `p x ≤ f∗p (f x)` |
| `pushforwardFun_isDistribution` | `f∗p` is a distribution |
| `shannonEntropy_pushforward_le` | `H(f∗p) ≤ H(p)` (data-processing) |
| `shannonEntropy_pushforward_of_injective` | injective `f` ⇒ `H(f∗p) = H(p)` |
| `landauer_lower_bound` | `0 ≤ kT(H(p) − H(f∗p))` for `k,T ≥ 0` |
| `landauer_lower_bound_zero_of_injective` | injective ⇒ cost `= 0` |
