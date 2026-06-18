# Summary of changes for run 44e22d7a-c412-4081-8b12-3ca5caf1896a
# Top-k Certified Robustness for Multiclass Neural Networks

## Formally Verified Mathematics (Lean 4)

All 16 theorems are **fully proved** with no `sorry`, no custom axioms—only `propext`, `Classical.choice`, and `Quot.sound`.

### Definitions (`MachineLearning/TopKRobustness/Defs.lean`)

Three core objects, all using Finset operations from Mathlib:

- **`kthLargest s k`**: The (k+1)-th largest value, defined via the sup-of-infima characterization: `max_{|S|=k+1} min_{i∈S} s(i)`. This definition was chosen because the perturbation bound follows directly from `Finset.sup'_le` and `Finset.le_inf'`, avoiding the need to formalize sorting.

- **`topkGap s k`**: The gap `kthLargest(s, k-1) - kthLargest(s, k)` measuring separation between the k-th and (k+1)-th largest scores.

- **`topKSet s k`**: The set `{i | kthLargest(s, k) < s(i)}`, which has exactly k elements when the gap is positive.

### Theorems (`MachineLearning/TopKRobustness/Main.lean`)

**Core perturbation bounds:**
- `kthLargest_perturb_le/ge`: |kthLargest(t,k) - kthLargest(s,k)| ≤ ε under ε-perturbation
- `topkGap_perturb_ge`: Gap degrades by at most 2ε

**Top-k set characterization:**
- `topKSet_card_of_gap_pos`: Positive gap ⟹ |topKSet| = k
- `topKSet_separation`: In-set minus out-set scores ≥ gap
- `topKSet_eq_of_dominates`: If k elements dominate all others, they form the top-k set

**Main theorems (matching the requested signatures):**
- `topk_stable_of_gap_pos`: Top-k set invariant when gap > 2·K·d·‖δ‖
- `topk_stable_on_closedBall`: Ball-form certificate
- `topk_certified_radius`: Explicit radius r = gap/(2Kd)

**Compositional results:**
- `coord_lipschitz_comp_preserves_bound`: 1-Lipschitz aggregation preserves the perturbation bound
- `topk_stable_comp_agg`: Full compositional top-k stability through A ∘ h
- `proj_one_lipschitz`, `relu_one_lipschitz`, `min_zero_one_lipschitz`: Concrete aggregator bounds

## Python Demos (`demos/topk_robustness_demo.py`)

Six interactive demonstrations:
1. **Basic order statistics**: Computes kthLargest, topkGap, topKSet for concrete vectors
2. **Gap degradation**: Shows the 2ε bound is conservative but correct
3. **Certified radius visualization**: 2D network with top-1/2/3 decision regions and certified balls
4. **Compositional theorem**: ReLU network with 1-Lipschitz aggregation, empirically verified (10,000 samples, 0 violations)
5. **Gap analysis plots**: Gap vs perturbation magnitude, certified radius vs Lipschitz constant
6. **Sup-of-infima verification**: Confirms the definition matches sorting

Generated visualizations: `demos/topk_certified_regions.png`, `demos/topk_gap_analysis.png`

## Research Paper (`paper/topk_certified_robustness.md`)

Complete mathematical paper covering:
- Motivation for top-k vs top-1 certification
- Full mathematical framework with proof sketches
- Formal verification methodology
- Applications (retrieval, medical diagnosis, beam search, score fusion)
- "Scoreboard analogy" discussion section for broad accessibility
- Future directions (robust ranking, certified beam search, tropical degree integration)