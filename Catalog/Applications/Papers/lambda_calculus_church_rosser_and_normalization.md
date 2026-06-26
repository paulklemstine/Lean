# Computational Evidence — de Bruijn substitution algebra & confluence

All claims below were checked by `#eval` in Lean before being formalized.

## 1. Substitution definitions behave as intended

With `Δ = λx. x x`, `Ω = Δ Δ`:

* `subst0 Δ (app (var 0) (var 0)) == Ω`  →  `true`
  (so `Ω` head-reduces to itself, matching `Bohm.omega_bohmApprox_bot`).

## 2. The commutation lemmas (exhaustive small-case search)

Enumerating **all** de Bruijn terms of depth ≤ 2 with variable indices `< 4`,
over all cutoffs/indices `< 4` (`< 3` where two indices interact), every identity
evaluated to `true`:

| Lemma | Statement | Result |
|-------|-----------|--------|
| `lift_lift`         | `i ≤ j → lift i (lift j t) = lift (j+1) (lift i t)` | ✅ all true |
| `subst_lift_cancel` | `subst i s (lift i t) = t`                           | ✅ all true |
| `lift_subst_le`     | `i ≤ j → lift i (subst j s t) = subst (j+1) (lift i s) (lift i t)` | ✅ all true |
| `lift_subst_ge`     | `j ≤ i → lift i (subst j s t) = subst j (lift i s) (lift (i+1) t)` | ✅ all true |
| `subst_subst`       | `n ≤ m → subst m w (subst n v e) = subst n (subst m w v) (subst (m+1) (lift n w) e)` | ✅ all true |

The randomized/exhaustive search found **no counterexample**; each identity was
subsequently proved by structural induction with `omega` discharging the index
arithmetic (see `Syntax.lean`).

## 3. Confluence sanity checks

`cd` (Takahashi complete development) on `Ω` returns `Ω` (the single redex is
contracted to itself), consistent with the triangle property `par_triangle`
that drives `church_rosser_beta`.

## Note on scope

The evidence stage is deliberately small: the theorems proved
(`church_rosser_beta`, `betaStar_normalForm_unique`, `HasType.preservation`) are
universally quantified over all terms/derivations, so the `#eval` checks serve
only to *de-risk the definitions* before committing to the inductive proofs.
