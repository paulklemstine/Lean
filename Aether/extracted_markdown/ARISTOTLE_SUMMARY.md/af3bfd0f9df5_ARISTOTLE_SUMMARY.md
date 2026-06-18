# Summary of changes for run 1e7b3b97-5e85-424a-8cb3-339421c30e0e
# Tropical Social Choice Theory: The Anti-Arrow Theorem

## Research Summary

This cycle introduced **Tropical Social Welfare Functions (TropSWF)** — a novel mathematical structure that reformulates social choice theory in the tropical (max-plus) semiring — and proved the **Tropical Anti-Arrow Theorem**, which inverts Arrow's classical impossibility: while Arrow shows dictatorship is *forced* in classical settings, the tropical algebraic structure makes dictatorship *impossible*.

## Lean 4 Formalization (`Speculative/TropicalSocialChoice.lean`)

**14 theorems, all fully proved (zero sorries), clean axioms.** The file defines the `TropSWF` structure and proves:

### Core Structure (Novel Definition)
- `TropSWF` — max-plus linear map f(x) = max_i(w_i + x_i) parameterized by voter weights
- `TropSWF.eval`, `maxWeight`, `support`, `weightGap`, `pureMax` — associated operations

### Main Theorems
1. **`trop_pareto`** — Every TropSWF automatically satisfies monotonicity (Pareto condition)
2. **`unanimity_iff`** — Unanimity ↔ maximum weight = 0 (clean algebraic characterization)
3. **`pureMax_unanimous`** — The all-zeros max function satisfies unanimity
4. **`trop_anti_arrow`** ⭐ — For n ≥ 2, NO TropSWF is dictatorial (the main result)
5. **`tropical_possibility`** — Non-dictatorial, unanimous, Pareto TropSWFs exist (inverts Arrow)
6. **`eval_tropical_additive`** — f(max(x,y)) = max(f(x), f(y)) — genuine tropical linearity
7. **`eval_tropical_homogeneous`** — f(c+x) = c + f(x) — tropical scalar multiplication
8. **`support_nonempty`** — The ruling coalition always exists
9. **`weightGap_scale`** — Gap scales linearly under weight scaling (mirrors `rescale_tropical_gap_linear`)
10. **`weightGap_zero_iff`** — Gap = 0 iff all weights equal (egalitarian characterization)
11. **`zero_gap_full_support`** — Zero gap means full-democracy (every voter in support)

Plus concrete computed examples for 3-voter TropSWFs.

### PEGB Coverage (for top theorems)
Each major theorem has Proof (Lean), Example (3-voter computations), Generalization (extends to any unbounded ordered group), and Boundary (n=1 case, bounded domains, WithBot ℤ).

### Cross-Connection
The weight gap theory directly mirrors the tropical spectral gap from `TropicalLorentzianShadows.rescale_tropical_gap_linear` in the Catalog — both measure max-plus separation and scale linearly.

## Deliverables

| File | Description |
|------|-------------|
| `Speculative/TropicalSocialChoice.lean` | 359 lines, 14 theorems, fully proved |
| `ARTICLE.md` | Scientific American-style article (~1800 words) |
| `RESEARCH_PAPER.md` | Full research paper with proofs, PEGB, algorithms |
| `FUTURE_DIRECTIONS.md` | 5 directions with conjectures and tests |
| `demo.py` | 7 interactive demonstrations |
| `algorithms.py` | Type-hinted TropSWF implementation |
| `viz_weight_gap.py` | Weight gap visualization |
| `viz_tropical_linearity.py` | Tropical linearity verification |
| `PACKAGE.json` | Complete package with 2 interactive HTML widgets |

## Key Conjecture (Testable)

**Bounded Domain Transition**: For TropSWFs over {0,...,K}^n with weight gap δ, the fraction of profiles where a non-support voter is decisive scales as Θ(K/δ). As δ/K → ∞, Arrow's impossibility "emerges" from tropical possibility. Computationally verified for n=3, K=8 in the demo.