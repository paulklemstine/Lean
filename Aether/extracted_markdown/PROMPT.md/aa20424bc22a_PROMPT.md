## Research Task: Tropical certified robustness for residual ReLU networks with identity skip connections

Research Mode: PROVE

Develop a formally sharp robustness theory for residual networks in the same style as the existing feedforward tropical robustness certificate. The goal is to isolate the exact extra multiplicative factor introduced by identity skip connections and prove a reusable library of Lipschitz and certification lemmas for residual blocks and their compositions.

### Target file
`MachineLearning/Neural/TropicalResNetRobustness.lean`

### Core mathematical objects
Work over finite-dimensional real input spaces modeled concretely as `Fin d → ℝ` with the sup norm
`‖x‖∞ := ‖x‖ = dist x 0` using the existing normed additive commutative group / normed space structure on function types. Use explicit dimension parameter `d : ℕ` and assume `[Fact (0 < d)]` whenever a nondegenerate input dimension is needed.

A residual block should be modeled as
```lean
def ResBlock {d : ℕ} (F : (Fin d → ℝ) → (Fin d → ℝ)) : (Fin d → ℝ) → (Fin d → ℝ) :=
  fun x => x + F x
```
and a scalar classifier/logit-gap map as a function
```lean
g : (Fin d → ℝ) → ℝ
```
with a certified margin assumption `0 < m ∧ m ≤ g x` in the binary / one-vs-rest normalization where preserving positivity of `g` preserves the predicted label.

### Precise theorem statements to aim for

1. **One residual block is `(1 + K)`-Lipschitz in `L∞`**
```lean
theorem resblock_lipschitz_one_add
    {d : ℕ}
    (F : (Fin d → ℝ) → (Fin d → ℝ))
    (K : ℝ)
    (hF : ∀ x y, ‖F x - F y‖ ≤ K * ‖x - y‖) :
    ∀ x y, ‖ResBlock F x - ResBlock F y‖ ≤ (1 + K) * ‖x - y‖
```
A variant with hypothesis `0 ≤ K` is likely useful for rearranging inequalities:
```lean
theorem resblock_lipschitz_one_add_nonneg
    {d : ℕ}
    (F : (Fin d → ℝ) → (Fin d → ℝ))
    (K : ℝ)
    (hK : 0 ≤ K)
    (hF : ∀ x y, ‖F x - F y‖ ≤ K * ‖x - y‖) :
    ∀ x y, ‖ResBlock F x - ResBlock F y‖ ≤ (1 + K) * ‖x - y‖
```

2. **Composition of residual blocks multiplies the constants**
For a finite family of branch maps `Fs : Fin n → ((Fin d → ℝ) → (Fin d → ℝ))` with constants `Ks : Fin n → ℝ`, define the iterated composition of blocks in a fixed order, e.g.
```lean
def composeResBlocks {d n : ℕ}
    (Fs : Fin n → ((Fin d → ℝ) → (Fin d → ℝ))) :
    (Fin d → ℝ) → (Fin d → ℝ)
```
corresponding to `R_{n-1} ∘ ... ∘ R_0`.

Then prove
```lean
theorem compose_resblocks_lipschitz_prod
    {d n : ℕ}
    (Fs : Fin n → ((Fin d → ℝ) → (Fin d → ℝ)))
    (Ks : Fin n → ℝ)
    (hKs : ∀ i, 0 ≤ Ks i)
    (hF : ∀ i x y, ‖Fs i x - Fs i y‖ ≤ Ks i * ‖x - y‖) :
    ∀ x y, ‖composeResBlocks Fs x - composeResBlocks Fs y‖
      ≤ ((∏ i, (1 + Ks i))) * ‖x - y‖
```
If function-indexed products over `Fin n` become awkward, a `List` or `Finset (Fin n)` version is acceptable, but the final theorem should expose the exact product constant.

3. **Scalar gap robustness from a Lipschitz bound**
Abstract the robustness argument away from network internals:
```lean
theorem gap_positive_of_supnorm_perturbation
    {d : ℕ}
    [Fact (0 < d)]
    (g : (Fin d → ℝ) → ℝ)
    (L m : ℝ)
    (x δ : Fin d → ℝ)
    (hL : ∀ u v, |g u - g v| ≤ L * (d : ℝ) * ‖u - v‖)
    (hm : 0 < m)
    (hg : m ≤ g x)
    (hδ : ‖δ‖ < m / (2 * (d : ℝ) * L)) :
    0 < g (x + δ)
```
A weak variant with `≤ m / (2*d*L)` and conclusion `0 ≤ g (x+δ)` is also useful. The strict version is the one that most directly certifies label preservation.

4. **One-block residual robustness certificate**
Let `g = gap ∘ ResBlock F`, or more generally assume directly that the residual classifier itself has Lipschitz constant `(1+K)`.
A clean theorem is:
```lean
theorem resblock_certified_radius
    {d : ℕ}
    [Fact (0 < d)]
    (g : (Fin d → ℝ) → ℝ)
    (K m : ℝ)
    (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hLip : ∀ u v, |g u - g v| ≤ ((1 + K) * (d : ℝ)) * ‖u - v‖)
    (hm : 0 < m)
    (hg : m ≤ g x)
    (hδ : ‖δ‖ < m / (2 * (d : ℝ) * (1 + K))) :
    0 < g (x + δ)
```
This realizes the target radius
`r* = m / (2 d (1 + K))`.

5. **Multi-block residual robustness certificate**
For the composed network:
```lean
theorem resnet_certified_radius
    {d n : ℕ}
    [Fact (0 < d)]
    (g : (Fin d → ℝ) → ℝ)
    (Fs : Fin n → ((Fin d → ℝ) → (Fin d → ℝ)))
    (Ks : Fin n → ℝ)
    (x δ : Fin d → ℝ)
    (m : ℝ)
    (hKs : ∀ i, 0 ≤ Ks i)
    (hLip : ∀ u v, |g u - g v| ≤ (((∏ i, (1 + Ks i)) : ℝ) * (d : ℝ)) * ‖u - v‖)
    (hm : 0 < m)
    (hg : m ≤ g x)
    (hδ : ‖δ‖ < m / (2 * (d : ℝ) * ∏ i, (1 + Ks i))) :
    0 < g (x + δ)
```
This gives the exact compositional certificate
`r* = m / (2 d ∏ i (1 + K_i))`.

6. **Bridge theorem from branchwise Lipschitz control to residual network Lipschitz control**
This is the theorem that makes the whole development reusable:
```lean
theorem resnet_gap_lipschitz_of_branch_bounds
    {d n : ℕ}
    (φ : (Fin d → ℝ) → (Fin d → ℝ))
    (Fs : Fin n → ((Fin d → ℝ) → (Fin d → ℝ)))
    (Ks : Fin n → ℝ)
    (Lφ : ℝ)
    (hKs : ∀ i, 0 ≤ Ks i)
    (hFs : ∀ i x y, ‖Fs i x - Fs i y‖ ≤ Ks i * ‖x - y‖)
    (hφ : ∀ x y, |φ x - φ y| ≤ Lφ * ‖x - y‖) :
    ∀ x y, |φ (composeResBlocks Fs x) - φ (composeResBlocks Fs y)| ≤
      (Lφ * ∏ i, (1 + Ks i)) * ‖x - y‖
```
This theorem is the precise formal bridge between blockwise tropical/Lipschitz constants and a final scalar margin certificate.

### Proof strategy

1. **Residual block Lipschitz bound by direct norm algebra**
   Expand
   ```lean
   ResBlock F x - ResBlock F y = (x - y) + (F x - F y)
   ```
   using `sub_eq_add_neg`, `add_comm`, `add_left_comm`, and `abel`-style simplification if helpful. Then apply the triangle inequality:
   ```lean
   ‖(x - y) + (F x - F y)‖ ≤ ‖x - y‖ + ‖F x - F y‖
   ```
   and insert the hypothesis `‖F x - F y‖ ≤ K * ‖x - y‖`. Finish with
   ```lean
   ‖x - y‖ + K * ‖x - y‖ = (1 + K) * ‖x - y‖
   ```
   using `ring` or `nlinarith` together with `hK : 0 ≤ K` if needed.

2. **Composition theorem by induction on the number of blocks**
   Define the block composition recursively:
   ```lean
   composeResBlocks Fs 0 = id
   composeResBlocks Fs (n+1) = ResBlock (Fs ⟨n, _⟩) ∘ composeResBlocks (truncate Fs) n
   ```
   or more simply use `Fin n` indexing plus `Nat.rec`. The inductive step should use:
   - induction hypothesis giving a product bound for the first `n` blocks,
   - one-block lemma for the last residual block,
   - multiplicativity of constants under composition:
     if `A` is `LA`-Lipschitz and `B` is `LB`-Lipschitz, then `A ∘ B` is `(LA*LB)`-Lipschitz.
   Algebraically, the step is
   ```lean
   ‖R_{n+1}(T x) - R_{n+1}(T y)‖
     ≤ (1 + K_{n+1}) * ‖T x - T y‖
     ≤ (1 + K_{n+1}) * (∏ i < n, (1 + K_i)) * ‖x - y‖.
   ```
   Then rewrite the product in the expected order with `Finset.prod_insert` or `Fin.prod_univ_succ`.

3. **Robustness certificate from the scalar gap inequality**
   Start from
   ```lean
   |g (x + δ) - g x| ≤ L * d * ‖δ‖
   ```
   by applying the Lipschitz hypothesis to `u = x + δ`, `v = x`, and simplifying `‖(x + δ) - x‖ = ‖δ‖`.
   Then use the strict radius assumption
   ```lean
   ‖δ‖ < m / (2 * d * L)
   ```
   to derive
   ```lean
   L * d * ‖δ‖ < m / 2
   ```
   provided the denominator is positive. This is where you should isolate positivity side conditions:
   - `0 < d : ℝ` from `[Fact (0 < d)]`,
   - `0 ≤ L` or stronger `0 < L` when dividing,
   - if `L = 0`, the theorem is trivial because `g` is constant on perturbations.
   Conclude
   ```lean
   g (x + δ) ≥ g x - |g (x + δ) - g x| > m - m/2 = m/2 > 0.
   ```
   Lean-friendly route: first prove
   ```lean
   g (x + δ) ≥ g x - L * d * ‖δ‖
   ```
   using `abs_le.mp` or `sub_le_iff_le_add`, then finish by `nlinarith`.

4. **Connect branchwise bounds to the final classifier**
   For a scalar head `φ` after the residual stack, first prove the network map itself is Lipschitz with constant `∏ i (1+K_i)`. Then compose with the scalar head:
   ```lean
   |φ (N x) - φ (N y)| ≤ Lφ * ‖N x - N y‖
                      ≤ Lφ * (∏ i, (1 + K_i)) * ‖x - y‖.
   ```
   This modularity is important: the residual-network theorem should not hard-code the final classifier architecture.

5. **Tropical specialization**
   If the existing library already provides a theorem that an affine-ReLU branch has tropical/Lipschitz constant `K`, instantiate the abstract branchwise theorem with those `K_i`. The new theorem should not merely reprove Lipschitzness from scratch; it should package residual architecture as a compositional wrapper around the existing tropical constants. A useful final corollary has the form
   ```lean
   theorem tropical_resnet_certified_radius_of_branch_constants ...
   ```
   where the assumptions are exactly the catalog’s branchwise tropical constant theorems and the conclusion is the product-form robustness radius.

### Important auxiliary lemmas to prove first

These will likely make the main file much smoother.

```lean
theorem lipschitz_compose_mul
    {α β γ : Type*}
    [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]
    (f : β → γ) (g : α → β) (Lf Lg : ℝ)
    (hf : ∀ x y, dist (f x) (f y) ≤ Lf * dist x y)
    (hg : ∀ x y, dist (g x) (g y) ≤ Lg * dist x y) :
    ∀ x y, dist (f (g x)) (f (g y)) ≤ (Lf * Lg) * dist x y
```

```lean
theorem abs_sub_le_of_lipschitz
    {d : ℕ}
    (g : (Fin d → ℝ) → ℝ)
    (L : ℝ)
    (hL : ∀ x y, |g x - g y| ≤ L * ‖x - y‖) :
    ∀ x δ, |g (x + δ) - g x| ≤ L * ‖δ‖
```

```lean
theorem norm_add_residual_sub
    {d : ℕ}
    (F : (Fin d → ℝ) → (Fin d → ℝ))
    (x y : Fin d → ℝ) :
    ResBlock F x - ResBlock F y = (x - y) + (F x - F y)
```

If product indexing over `Fin n` becomes cumbersome, prove an equivalent list theorem:
```lean
theorem compose_resblocks_lipschitz_list
    {d : ℕ}
    (Fs : List ((Fin d → ℝ) → (Fin d → ℝ)))
    (Ks : List ℝ)
    ...
```
and derive the `Fin n` theorem afterward.

### Significance

This is not just a routine generalization of a feedforward Lipschitz bound. Identity skip connections change the geometry of the piecewise-linear map in a mathematically essential way: tropical/max-plus control of a residual branch does not simply replace the whole block, but interacts with the identity branch through an additive `1 + K` law at the block level and a multiplicative product law across depth. Formalizing this gives the first certified-robustness theorem in the library that genuinely reflects modern ResNet architecture rather than plain sequential chains.

The theorem is also structurally valuable for the broader research program:
- it upgrades the tropical robustness library from feedforward chains to residual compositions;
- it isolates a reusable compositional principle for any future tropical analysis of skip-connected architectures;
- it creates a clean interface between branchwise tropical constants and end-to-end certification;
- it sets up the next natural step: sharper certificates exploiting blockwise local constants, contraction blocks with `K < 1`, or mixed residual/standard architectures.

The strongest final deliverable is a theorem whose conclusion explicitly displays the certified radius
```lean
m / (2 * (d : ℝ) * ∏ i, (1 + Ks i))
```
and whose assumptions are stated in terms of branchwise Lipschitz/tropical constants that can be discharged by existing affine-ReLU results.

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

Research domain: MachineLearning
Research mode: prove
