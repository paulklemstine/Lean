# Computational Evidence — NET-51 structural theorems

Small numerical checks used to *design* the theorems in `Catalog/Novelty/`.
These tables are exploratory (computed in floating point); the statements that
matter are the Lean theorems, which are proved exactly and listed at the end.

## 1. Cosine similarity does not bound decision agreement

The *flip pair* `u = (1+t, 1)`, `v = (1, 1+t)` has `argmax u = 0`, `argmax v = 1`
for every `t > 0`, and cosine similarity `(2+2t)/(t²+2t+2)`:

| t | cos(u,v) | decisions agree? |
|---|----------|------------------|
| 0.5 | 0.9230769231 | no |
| 0.1 | 0.9954751131 | no |
| 0.01 | 0.9999504975 | no |
| 0.001 | 0.9999995005 | no |
| 0.0001 | 0.9999999950 | no |

The cosine tends to 1 quadratically in `t` while the decision is wrong for every
`t`. The measured tail point (cos `0.983`, agreement `0.568`) therefore violates
no inequality — it sits comfortably inside the admissible region.
Formalised as `cosine_near_one_decision_flip` (with the exact identity
`cosSim_flipPair` and the clean bound `cosSim_flipPair_lower : 1 - t/2 ≤ cos`).

## 2. Maslov gap versus top-1 margin

Margin `m` ⟹ gap ≤ `log(1 + (n-1)e^{-m})` (n = 128 context positions):

| margin m | gap bound |
|----------|-----------|
| 0.5 | 4.3571 |
| 1 | 3.8654 |
| 2 | 2.9007 |
| 4 | 1.2018 |
| 8 | 0.0417 |

Converse direction, gap `g` ⟹ margin cap:

| n | g | exact cap `log(n-1) − log(e^g−1)` | simple cap `log(n-1)+log 2−g` | flipping perturbation ≈ cap/2 |
|---|---|------|------|------|
| 128 | 2.5 | 2.4298 | 3.0373 | 1.21 |
| 128 | 2.7 | 2.2138 | 2.8373 | 1.11 |
| 1024 | 2.5 | 4.5161 | 5.1236 | 2.26 |
| 16 | 2.5 | 0.2937 | 0.9012 | 0.15 |

So the NET-50 tail measurement (`g ≈ 2.5–2.7`) numerically caps the tail's top-1
margin at ≈ 2.2–2.4 nats, i.e. a perturbation of ≈ 1.1–1.2 nats in the logits
suffices to change the choice. Formalised as `maslovGap_le_of_margin`,
`margin_le_of_maslovGap`, `margin_le_of_maslovGap_simple`,
`far_from_tropical_is_fragile`.

## 3. Amortized serving ratio (L = 24 layers, s = 22 shared)

`serveCost(n) / (n·L) = (22 + 2n)/(24n)`:

| n models | ratio |
|---|---|
| 1 | 1.0000 |
| 2 | 0.5417 |
| 4 | 0.3125 |
| 8 | 0.1979 |
| 16 | 0.1406 |
| 64 | 0.0977 |
| 1024 | 0.0842 |

converging to the tail fraction `2/24 = 1/12 ≈ 0.0833`. Formalised as
`serveCost_ratio_tendsto` and `serveCost_ratio_tail_24_22`.

Note on a claim we had to correct: `22/24 = 0.9167`, **not** `≥ 0.92`. The Lean
statement `agreement_24_22` therefore certifies the honest bound `11/12`.

## 4. Counterexample hunt

* Hunted for a cosine threshold `c < 1` that would force decision agreement:
  none exists — §1 is a one-parameter family of counterexamples for every `c`.
* Hunted for a hump produced by nonexpansive layers with per-layer delta `ε`:
  impossible, since `divergence_linear_bound` gives `d k ≤ k·ε` (monotone
  envelope) and any strict drop beyond `ε` is a contraction certificate
  (`contraction_of_divergence_drop`). The measured drop `0.217 → 0.16` over seven
  layers hence forces either contraction (factor ≤ 4/5, `net51_tail_contraction_factor`)
  or a delta budget `≥ 0.057` (`net51_hump_delta_budget`), i.e. some single layer
  injecting `≥ 0.008` (`net51_hump_single_layer_delta`).

## 5. Depth budget (cycle 2)

With nonexpansive layers, `budget k = k * eps`; for `eps = 0.01` and a uniform
margin `0.5` the certificate `2 * budget k < margin` holds exactly for `k ≤ 24`
and fails at `k = 25` (`0.5 < 0.5` is false). Formalised as `net51_depth_budget`
and `net51_depth_budget_tight`.

## 6. OEIS

No integer sequence arises here; the objects are inequalities between real
quantities, so no OEIS lookup applies.

## Exactly verified in Lean (0 sorries)

`Catalog/Novelty/KVDecisionDissociation.lean`,
`Catalog/Novelty/LayerDivergenceHump.lean`,
`Catalog/Novelty/SharedCoreServingBudget.lean`,
`Catalog/Novelty/TropicalMaslovMarginBridge.lean`,
`Catalog/Novelty/TailSwapAttribution.lean`,
`Catalog/Novelty/MarginDepthSharingBudget.lean`.
All main theorems depend only on `propext`, `Classical.choice`, `Quot.sound`.
