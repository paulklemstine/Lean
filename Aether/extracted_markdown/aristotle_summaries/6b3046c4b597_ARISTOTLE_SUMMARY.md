# Summary of changes for run b6713431-6609-4555-a1f1-d41a2da364d3
I created `MachineLearning/Neural/TransformerApproximation.lean` containing **18 fully machine-verified theorems** (zero `sorry`, zero non-standard axioms) covering the mathematically formalizable core of your request. Here is what was proved:

**Section 1 — Sub-Quadratic Attention Complexity (3 theorems)**
- `block_sparse_subquadratic`: Block-sparse attention with B ≥ 2 blocks has cost N·(N/B) < N², i.e., strictly sub-quadratic.
- `block_sparse_at_most_half`: The cost is at most N²/2.
- `linear_attention_cost`: With B = N (linear attention), the cost is exactly N.

**Section 2 — Quantization Error Bounds (3 theorems)**
- `uniform_quantization_elementwise_bound`: Rounding to nearest grid point gives per-element error ≤ Δ/2.
- `quantization_frobenius_bound`: Frobenius-norm² of n quantization errors ≤ n·δ².
- `kv_cache_quantization_bound`: KV-cache quantization with per-element error δ gives total Frobenius error² ≤ 2·n·d·δ².

**Section 3 — Lipschitz Continuity (2 theorems)**
- `lipschitz_comp_real`: Composition of Lf-Lipschitz and Lg-Lipschitz functions is (Lg·Lf)-Lipschitz.
- `lipschitz_tower_induction`: L composed K-Lipschitz layers give a K^L-Lipschitz function (proved by induction on L with foldl).

**Section 4 — ε-Bounded Output Divergence (2 theorems)**
- `layer_perturbation_geom_bound`: The geometric partial sum ∑ K^i ≤ K^L · L (bounding total perturbation).
- `geometric_perturbation_bound`: The exact geometric series formula ∑ K^i = (K^L − 1)/(K − 1) for K > 1.

**Section 5 — Grouped-Query Attention (2 theorems)**
- `gqa_rank_bound`: GQA effective rank G·d_k ≤ H·d_k where H = G·R.
- `gqa_memory_reduction`: GQA KV-cache uses G·n·d_k ≤ H·n·d_k memory.

**Section 6 — SwiGLU Activation (3 theorems)**
- `sigmoid_bounded`: σ(x) = 1/(1 + e^{-x}) ∈ (0, 1].
- `silu_abs_bound`: |x · σ(x)| ≤ |x|.
- `swiglu_growth_bound`: |x / (1 + e^{-x})| ≤ |x|.

**Section 7 — RoPE (2 theorems)**
- `rope_norm_preservation`: 2D rotation preserves ‖v‖² (the Pythagorean identity for rotary embeddings).
- `scaled_rope_norm_preservation`: Scaling the RoPE frequency base preserves the norm-preservation property.

**Section 8 — Distributed Training (1 theorem)**
- `allreduce_sum_comm`: Summation is permutation-invariant, formalizing that All-Reduce with addition is order-independent.

**What was NOT done (and why):**
- **Triton/CUDA kernel extraction from Lean**: This is not possible — Lean's code extraction targets C/IR, not GPU kernels. This would require a separate compiler project.
- **Full Llama-3.1 architecture formalization**: Formalizing the complete forward pass of a 32-layer, 4096-dim transformer with all its implementation details is a multi-year research effort.
- **Meta-tactic for automated architecture search**: Building a Lean meta-program that discovers and verifies sparse topologies is a research project in its own right.
- **The original `layer_perturbation_bound` (ε·L·K^(L-1) ≤ ε·K^L)**: This was *disproved* — it's false when L > K (e.g., L=2, K=1.5). It was replaced with the correct geometric series bound.

The file compiles cleanly with only standard axioms (propext, Classical.choice, Quot.sound).