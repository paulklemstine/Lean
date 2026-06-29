# Theorem Trace (internal anti-hallucination ledger)

Source of truth: Phase A Lean files
`Catalog/Tropical/DifferentialValuation/Basic.lean`,
`Catalog/Tropical/DifferentialValuation/Balancing.lean`, and (referenced in Phase A
future directions) `Catalog/Tropical/DifferentialValuation/FundamentalTheorem.lean`.

Every theorem named in ARTICLE.md / RESEARCH_PAPER.md / RESEARCH_PAPER.tex must appear
below. No grander paraphrases of names; statements mirror the Lean.

| Lean name | Math statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `le_order_sum` | If `m ≤ ord(φ j)` for all `j ∈ s`, then `m ≤ ord(∑_{j∈s} φ j)`. | yes (prose) | yes (Lemma 1) |
| `lt_order_sum` | For nonempty `s`, if `c < ord(φ j)` for all `j ∈ s`, then `c < ord(∑_{j∈s} φ j)`. | yes (prose) | yes (Lemma 2) |
| `order_sum_eq_of_unique_min` | If `i₀ ∈ s` and `ord(φ i₀) < ord(φ j)` for all `j ∈ s, j ≠ i₀`, then `ord(∑_{j∈s} φ j) = ord(φ i₀)`. | yes | yes (Theorem A) |
| `tropical_balancing` | If `∑_{j∈s} φ j = 0`, `i₀ ∈ s`, `ord(φ i₀) ≠ ⊤`, then `∃ j ∈ s, j ≠ i₀ ∧ ord(φ j) ≤ ord(φ i₀)`. | yes (main) | yes (Theorem B) |
| `order_derivativeFun_eq` | Over `CharZero K`: `ord f = k+1 ⟹ ord f' = k` (`f' = derivativeFun`). | yes | yes (Theorem C) |
| `order_iterate_derivativeFun` | `ord f = n ⟹ ord(dⁱf) = n − i` for `i ≤ n`. | yes | yes (Cor. C.1) |
| `order_diff_monomial` | `ord(∏ᵢ (dⁱf)^{eᵢ}) = ∑ᵢ eᵢ·(n − i)` where `n = ord f`. | yes | yes (Theorem D) |
| `tropical_FTDA` | Tropicalization of a differential ideal ⊆ tropical differential ideal of the tropicalization (the ⊆ direction). | yes (overarching) | yes (Theorem E) |
| `order_diffPoly_ge` | The tropical minimum lower-bounds the order of any classical value `P(f)`. | yes | yes (Theorem F) |
| `order_diffTerm` | Order bookkeeping for a single differential term (building block of `order_diffPoly_ge`). | mentioned | yes (Lemma 3) |

Mathlib facts cited (not our theorems, used as background): `order_mul`, `order_pow`,
`min_order_le_order_add`, `order_add_of_order_ne`, `coeff_derivativeFun`, `order_zero`.

Notes / honesty:
- `tropical_FTDA` is the **containment (⊆)** direction only; the converse (equality) is
  Conjecture 1 in future directions, stated as conjecture, never as proved.
- `CharZero` is load-bearing for `order_derivativeFun_eq` and everything downstream.
- `tropical_balancing` needs `ord(φ i₀) ≠ ⊤` (the nonzero-term hypothesis).
