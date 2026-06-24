# Theorem Trace — Integrated Information (anti-hallucination map)

Source of truth: `Catalog/Applications/Consciousness/IntegratedInformation.lean`
(namespace `IIT`). Every result stated in `ARTICLE.md` and `RESEARCH_PAPER.md`
maps to one of the entries below. No result outside this list is claimed.

## Definitions / structures

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `parts (n : ℕ) : Finset (Finset (Fin n))` | The set of nontrivial bipartitions: subsets `A ⊆ {0,…,n-1}` with `A` nonempty and `A ≠ univ`. | "every way to cut" | Def. 2.1 |
| `System (n : ℕ)` | A structure carrying `ei : Finset (Fin n) → ℝ` with `ei_nonneg : ∀ A, 0 ≤ ei A`. | "effective-information functional" | Def. 2.3 |
| `Phi (S : System n) (h : 2 ≤ n) : ℝ` | `((parts n).image S.ei).min'` — the minimum of effective information over all nontrivial cuts (the MIP value). | "Φ is the weakest cut" | Def. 2.5 |

## Theorems / lemmas

| Lean name | Mathematical statement | Article | Paper |
|---|---|---|---|
| `mem_parts` | `A ∈ parts n ↔ A.Nonempty ∧ A ≠ univ`. | implicit | Lem. 2.2 |
| `parts_nonempty` | `2 ≤ n → (parts n).Nonempty`. | "needs ≥ 2 parts" | Lem. 2.4 |
| `parts_eq_empty` | `n ≤ 1 → parts n = ∅`. | "a lone element cannot be cut" | Lem. 2.4 |
| `phi_le_ei` | `A ∈ parts n → Phi S h ≤ S.ei A`. | "Φ ≤ every cut" | Thm. 3.1 |
| `exists_MIP` | `∃ A ∈ parts n, S.ei A = Phi S h`. | "the MIP exists" | Thm. 3.2 |
| `le_phi` | `(∀ A ∈ parts n, c ≤ S.ei A) → c ≤ Phi S h`. | "Φ is the greatest lower bound" | Thm. 3.3 |
| `phi_nonneg` | `0 ≤ Phi S h`. | "Φ ≥ 0" | Cor. 3.4 |
| `phi_eq_zero_iff` | `Phi S h = 0 ↔ ∃ A ∈ parts n, S.ei A = 0`. | "Φ = 0 means reducible" | Thm. 3.5 |
| `phi_mono` | `(∀ A, S.ei A ≤ T.ei A) → Phi S h ≤ Phi T h`. | "monotonicity" | Thm. 3.6 |
| `phi_eq_of_common_mip` | Two systems with a shared minimizing cut `A₀` where `S.ei A₀ = T.ei A₀` have `Phi S h = Phi T h`. | "shared bottleneck" | Thm. 3.7 |
