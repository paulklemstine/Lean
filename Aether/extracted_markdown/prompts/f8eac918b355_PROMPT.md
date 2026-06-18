Aristotle,

We need to close the multi-class gap in the tropical robustness program. Every existing certificate in our catalog is binary, but real networks have thousands of outputs. Prove that the tropical-degree robustness radius lifts from pairwise separation to the full multi-class argmax.

**Theorem statement.**

```lean
theorem multi_class_tropical_certified_robustness
    {n k : ℕ} (hk : 2 ≤ k)
    (f : (Fin n → ℝ) → Fin k → ℝ)
    (hf : ∀ i, IsTropicalReLUNetwork (λ x => f x i))
    (d : ℕ) (hd : 1 ≤ d)
    (hdeg : ∀ i, network_tropical_degree (λ x => f x i) d)
    (K : ℝ≥0) (hK : 0 < K)
    (hlip : ∀ i, LipschitzWith K (λ x => f x i))
    (x : Fin n → ℝ) (i : Fin k)
    (hcorrect : ∀ j ≠ i, f x i > f x j) :
    let rStar := ⨅ (j : Fin k) (hj : j ≠ i), tropDist (f x i) (f x j) / (2 * K * d)
    ∀ (y : Fin n → ℝ), ‖y - x‖₊ ≤ rStar → ∀ j ≠ i, f y i ≥ f y j
```

**Proof strategy.**

1. **Pairwise tropical gap decomposition.** Reduce the multi-class robustness goal to a finite conjunction of pairwise margin inequalities. For each competing class `j ≠ i`, define the tropical gap `g_j x := tropDist (f x i) (f x j)`. In the standard min-plus embedding `tropDist a b = abs (a - b)`, so `g_j x = f x i - f x j > 0` by hypothesis `hcorrect`. Use `sub_nonneg` to restate the goal as `g_j y ≥ 0`. The theorem then hinges on showing that the infimum radius `rStar` controls every gap simultaneously.

2. **Lipschitz-tropical composition bound.** Apply `LipschitzWith.dist_le_mul` to both coordinate logits `f · i` and `f · j`, yielding `abs (f y i - f x i) ≤ K * ‖y - x‖₊` and analogously for `j`. Combine these via `abs_sub` and `add_le_add` to obtain the raw Lipschitz estimate `abs (g_j y - g_j x) ≤ 2 * K * ‖y - x‖₊`. Now invoke `network_tropical_degree` (`Tropical/Core/TropicalInformationRichness.lean`) on both logits to certify that each is a tropical polynomial of degree at most `d`. Feed the resulting degree bounds into `tropical_and_bound` (`Tropical/Langlands/OracleApplicationsFrontier.lean`) to show that the tropical rational function `g_j` has effective degree at most `2 * d`; this sharpens the naive estimate to `g_j x - g_j y ≤ 2 * K * d * ‖y - x‖₊`. This is the heart of the argument: the tropical degree `d` acts as an architectural complexity measure that directly scales the certificate radius.

3. **Infimum certificate extraction.** Let `rStar` be the infimum of the pairwise robustness radii. For any perturbation `y` with `‖y - x‖₊ ≤ rStar`, use `ciInf_le` on the finite competing-class index set to obtain `‖y - x‖₊ ≤ tropDist (f x i) (f x j) / (2 * K * d)` for every `j ≠ i`. Apply `le_div_iff₀` (with the denominator positivity discharged by `exact_mod_cast hd` and `hK`) to derive `2 * K * d * ‖y - x‖₊ ≤ g_j x`. Chain this with the bound from Step 2 via `linarith` to conclude `0 ≤ g_j y`, which is `f y i ≥ f y j` by `sub_nonneg.mpr`. Since `j ≠ i` was arbitrary, the universal certificate follows.

**Why this matters.** The Tropical ReLU corpus establishes ReLU networks as tropical piecewise-linear maps and proves binary Lipschitz and depth-separation bounds, but it stops at two outputs. By lifting the certificate to `k ≥ 2`, this theorem validates the tropical geometry pipeline for real-world multi-class networks. The radius `r*` is computable from a single forward pass and the architectural constants `K` and `d`, making it a practical formal verification target. This resolves the open priority on tropical certified robustness for neural networks and completes the bridge between tropical polynomial degree and adversarial robustness.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Tropical
Research mode: prove
