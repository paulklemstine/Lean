# Theorem Trace (internal anti-hallucination ledger)

Source of truth: `Catalog/Computation/LandauerLowerBound.lean`
(namespace `LandauerLowerBound`). The "Phase A output" pasted into the Phase B
prompt referenced unrelated packages (mock theta functions, semiconjugacy orbit
arithmetic); those are NOT the math for this concept and are deliberately ignored.
The Landauer concept's proven content is the file above.

Background definitions imported from `Computation.ReversibleTropicalThermodynamics`
(used but not redefined in the target file), inferred from usage:

- `IsDistribution p` := `(∀ y, 0 ≤ p y) ∧ (∑ y, p y = 1)`  — accessed via `.1`, `.2`.
- `shannonEntropy p` := `-∑ x, p x * Real.log (p x)`  — confirmed by `unfold shannonEntropy`
  in `shannonEntropy_pushforward_eq` and `shannonEntropy_pushforward_le`.

| Lean name | Statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `pushforwardFun` (def) | `(f∗p)(y) = ∑_{x : f x = y} p x` | "fiber sum" / push-forward | Def 2 |
| `pushforwardFun_apply_ge` | `p x ≤ (f∗p)(f x)` for `p ≥ 0` | "a fiber contains at least its own grain" | Lemma 1 |
| `pushforwardFun_nonneg` | `0 ≤ (f∗p) y` for `p ≥ 0` | (implicit) | Lemma (mass) |
| `pushforwardFun_total` | `∑ y (f∗p) y = ∑ x p x` | "no probability is lost" | Lemma 2 |
| `pushforwardFun_isDistribution` | `IsDistribution p → IsDistribution (f∗p)` | "output is still a distribution" | Prop 3 |
| `shannonEntropy_pushforward_eq` | `H(f∗p) = -∑ x p x log((f∗p)(f x))` | reindexing step | Lemma 4 (reindexing) |
| `shannonEntropy_pushforward_le` | `H(f∗p) ≤ H(p)` for `p ≥ 0` | **main theorem** (data processing) | **Theorem 5** |
| `shannonEntropy_pushforward_of_injective` | `Injective f → H(f∗p) = H(p)` | reversible = free | **Theorem 6** |
| `landauer_lower_bound` | `0 ≤ kT(H(p) − H(f∗p))`, `k,T ≥ 0` | **Landauer bound** | **Theorem 7** |
| `landauer_lower_bound_zero_of_injective` | `Injective f → kT(H(p) − H(f∗p)) = 0` | reversible dissipates nothing | **Theorem 8** |

Derived application (NOT a separate Lean theorem, presented as a worked instance of
Theorem 5/7): uniform erasure of `n` bits collapses `2^n` equiprobable states to one
point, dropping entropy by `n log 2`, giving work `n·kT·log 2`; the one-bit case is
`kT log 2`. This is the extremal collapse-to-a-point case of the DPI, explicitly the
framing of the file's docstring.
