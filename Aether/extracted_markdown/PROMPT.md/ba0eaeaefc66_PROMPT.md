## Research Task: Multiclass tropical certified robustness for residual ReLU networks via pairwise logit-gap margins

Research Mode: PROVE

Work in a new file
`MachineLearning/Neural/TropicalMulticlassResidualRobustness.lean`.

The goal is to upgrade the existing binary/output-margin robustness result for residual ReLU networks with identity skip connections to a genuinely multiclass theorem. The right formal object is the family of pairwise logit-gap functions
`g c j x = f c x - f j x`.
A multiclass certificate should follow by proving that every such gap remains positive under sufficiently small `‖·‖∞` perturbations.

The mathematically natural theorem is:

- if each output coordinate `f i : (Fin d → ℝ) → ℝ` has a global `L∞`-Lipschitz constant `K * d`,
- if `c` strictly wins at `x`,
- and if every competitor `j ≠ c` has gap
  `f c x - f j x > 2 * K * d * r`,
- then for every perturbation `δ` with `‖δ‖∞ ≤ r`, class `c` still strictly wins at `x + δ`.

This should be formalized first in a coordinatewise/Lipschitz style, without overcommitting to a specific network datatype, and then specialized to the residual-network hypotheses already available in the robustness development.

---

### Precise Lean theorem targets

Use `Fin d → ℝ` as the input space and `Fin k → ℝ` as the logit vector. Define the `L∞` seminorm by a finite sup over coordinates.

A convenient starting definition is:

```lean
def linfNorm {d : ℕ} (x : Fin d → ℝ) : ℝ :=
  Finset.sup Finset.univ (fun i => |x i|)

def pairwiseGap {d k : ℕ} (f : Fin k → (Fin d → ℝ) → ℝ) (c j : Fin k) (x : Fin d → ℝ) : ℝ :=
  f c x - f j x
```

If `Finset.sup` on `ℝ` is awkward, it is also acceptable to define
`linfNorm x = ‖x‖∞` using an existing `Matrix`/`Pi` norm already present in Mathlib, but the theorem statements should remain explicitly about `L∞`.

The core abstract theorem should have a type essentially of the following form:

```lean
theorem multiclass_argmax_stable_of_pairwise_margin
    {d k : ℕ}
    (f : Fin k → (Fin d → ℝ) → ℝ)
    (L r : ℝ)
    (x : Fin d → ℝ)
    (c : Fin k)
    (hL : ∀ i x y, |f i x - f i y| ≤ L * linfNorm (fun t => x t - y t))
    (hr : 0 ≤ r)
    (hmargin : ∀ j, j ≠ c → 2 * L * r < f c x - f j x) :
    ∀ δ : Fin d → ℝ,
      linfNorm δ ≤ r →
      ∀ j, j ≠ c → f j (fun t => x t + δ t) < f c (fun t => x t + δ t)
```

A sharper and often easier-to-use equivalent formulation is to state the conclusion directly for the perturbed point `y`:

```lean
theorem multiclass_argmax_stable_of_pairwise_margin'
    {d k : ℕ}
    (f : Fin k → (Fin d → ℝ) → ℝ)
    (L : ℝ)
    (x y : Fin d → ℝ)
    (c : Fin k)
    (hL : ∀ i x y, |f i x - f i y| ≤ L * linfNorm (fun t => x t - y t))
    (hmargin : ∀ j, j ≠ c → 2 * L * linfNorm (fun t => y t - x t) < f c x - f j x) :
    ∀ j, j ≠ c → f j y < f c y
```

Then prove the pairwise-gap Lipschitz lemma:

```lean
theorem pairwiseGap_lipschitz
    {d k : ℕ}
    (f : Fin k → (Fin d → ℝ) → ℝ)
    (L : ℝ)
    (hL : ∀ i x y, |f i x - f i y| ≤ L * linfNorm (fun t => x t - y t))
    (c j : Fin k) :
    ∀ x y,
      |pairwiseGap f c j y - pairwiseGap f c j x|
        ≤ (2 * L) * linfNorm (fun t => y t - x t)
```

This is the key binary reduction. After that, derive the multiclass theorem by applying positivity of all pairwise gaps.

A useful “minimum margin” formulation over all competitors is:

```lean
def multiclassMargin {d k : ℕ}
    (f : Fin k → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) (c : Fin k) : ℝ :=
  Finset.inf' (Finset.univ.erase c) (by
    simp) (fun j => f c x - f j x)
```

and then prove:

```lean
theorem multiclass_argmax_stable_of_margin
    {d k : ℕ}
    (hk : 1 < k)
    (f : Fin k → (Fin d → ℝ) → ℝ)
    (L r : ℝ)
    (x : Fin d → ℝ)
    (c : Fin k)
    (hL : ∀ i x y, |f i x - f i y| ≤ L * linfNorm (fun t => x t - y t))
    (hr : 0 ≤ r)
    (hmargin : 2 * L * r < multiclassMargin f x c) :
    ∀ δ : Fin d → ℝ,
      linfNorm δ ≤ r →
      ∀ j, j ≠ c → f j (fun t => x t + δ t) < f c (fun t => x t + δ t)
```

Finally, specialize to the residual-network constant appearing in the existing robustness development. If the established theorem gives a coordinatewise bound of the form
`|f i (x + δ) - f i x| ≤ K * d * linfNorm δ`,
then instantiate `L := K * d` and obtain the certificate radius
`margin / (2 * K * d)`:

```lean
theorem residual_multiclass_certified_radius
    {d k : ℕ}
    (f : Fin k → (Fin d → ℝ) → ℝ)
    (K r : ℝ)
    (x : Fin d → ℝ)
    (c : Fin k)
    (hK : ∀ i x y, |f i x - f i y| ≤ (K * d) * linfNorm (fun t => x t - y t))
    (hr : 0 ≤ r)
    (hmargin : ∀ j, j ≠ c → 2 * (K * d) * r < f c x - f j x) :
    ∀ δ : Fin d → ℝ,
      linfNorm δ ≤ r →
      ∀ j, j ≠ c → f j (fun t => x t + δ t) < f c (fun t => x t + δ t)
```

If the existing residual theorem gives a sharpened pairwise-gap constant directly, also prove the improved version with `K * d` in place of `2 * K * d`.

---

### Proof strategy

1. **Prove the pairwise-gap perturbation inequality.**  
   Expand
   `pairwiseGap f c j y - pairwiseGap f c j x`
   as
   `(f c y - f c x) - (f j y - f j x)`.
   Then apply:
   - `abs_sub_le_iff` / triangle inequality in the form
     `|a - b| ≤ |a| + |b|`,
   - the coordinatewise Lipschitz hypotheses for classes `c` and `j`,
   - ring normalization to combine the two bounds into `2 * L * linfNorm (...)`.
   This lemma is the essential reduction from multiclass robustness to a family of binary certificates.

2. **Turn a positive margin at `x` into positivity of every pairwise gap at `x + δ`.**  
   For fixed `j ≠ c`, write:
   ```lean
   pairwiseGap f c j (x + δ)
   = pairwiseGap f c j x
     + (pairwiseGap f c j (x + δ) - pairwiseGap f c j x).
   ```
   Use the previous lemma to show the perturbation term has absolute value at most `2 * L * ‖δ‖∞`, hence is strictly smaller than the original gap by the margin hypothesis. Conclude
   `0 < pairwiseGap f c j (x + δ)`.

3. **Convert positivity of all pairwise gaps into argmax stability.**  
   The target conclusion is pointwise:
   `∀ j ≠ c, f j (x+δ) < f c (x+δ)`.
   This is exactly `0 < f c (...) - f j (...)`. No sophisticated `argmax` API is required. If you want an explicit “predicted class” formulation later, define:
   ```lean
   def StrictWinner (f : Fin k → α → ℝ) (x : α) (c : Fin k) : Prop :=
     ∀ j, j ≠ c → f j x < f c x
   ```
   and prove robustness of `StrictWinner`.

4. **Package the competitorwise assumptions into a minimum-margin theorem.**  
   For the `Finset.inf'` version, use:
   - membership facts for `Finset.univ.erase c`,
   - `Finset.inf'_le` to show
     `multiclassMargin f x c ≤ f c x - f j x`
     for each `j ≠ c`,
   - then compose with the previous theorem.
   This gives the clean statement “if `2Lr < min competitor gap`, then class `c` is certified stable.”

5. **Specialize to residual tropical/ReLU networks.**  
   Import the existing residual robustness file and instantiate the abstract theorem with the already-proved global coordinate Lipschitz estimate for each output logit. If that theorem is stated for perturbations of the form `x + δ`, adapt via `y := x + δ`. If the existing theorem carries an architectural constant named differently from `K`, preserve that name and only derive the final radius statement as a corollary.

---

### Useful intermediate lemmas to prove

These are likely to make the final theorem much easier to maintain:

```lean
theorem linfNorm_nonneg {d : ℕ} (x : Fin d → ℝ) : 0 ≤ linfNorm x
```

```lean
theorem linfNorm_add_le {d : ℕ} (x y : Fin d → ℝ) :
    linfNorm (fun i => x i + y i) ≤ linfNorm x + linfNorm y
```

```lean
theorem linfNorm_neg {d : ℕ} (x : Fin d → ℝ) :
    linfNorm (fun i => -x i) = linfNorm x
```

```lean
theorem pairwiseGap_pos_iff {d k : ℕ}
    (f : Fin k → (Fin d → ℝ) → ℝ) (c j : Fin k) (x : Fin d → ℝ) :
    0 < pairwiseGap f c j x ↔ f j x < f c x
```

```lean
theorem strictWinner_of_pairwiseGap_pos
    {d k : ℕ}
    (f : Fin k → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) (c : Fin k)
    (h : ∀ j, j ≠ c → 0 < pairwiseGap f c j x) :
    ∀ j, j ≠ c → f j x < f c x
```

And if useful for the minimum-margin packaging:

```lean
theorem multiclassMargin_le_gap
    {d k : ℕ}
    (hk : 1 < k)
    (f : Fin k → (Fin d → ℝ) → ℝ)
    (x : Fin d → ℝ)
    (c j : Fin k)
    (hj : j ≠ c) :
    multiclassMargin f x c ≤ f c x - f j x
```

---

### Architectural specialization target

After the abstract development is complete, add a corollary tailored to the residual-network setting already formalized elsewhere. The intended shape is:

```lean
theorem residual_relu_multiclass_robust
    {d k : ℕ}
    (net : ResidualReLUNet d k)  -- replace by the actual network structure in the codebase
    (K r : ℝ)
    (x : Fin d → ℝ)
    (c : Fin k)
    (hLip : ∀ i x y, |evalLogit net i x - evalLogit net i y|
        ≤ (K * d) * linfNorm (fun t => x t - y t))
    (hmargin : ∀ j, j ≠ c → 2 * (K * d) * r < evalLogit net c x - evalLogit net j x)
    (hr : 0 ≤ r) :
    ∀ δ : Fin d → ℝ,
      linfNorm δ ≤ r →
      ∀ j, j ≠ c →
        evalLogit net j (fun t => x t + δ t) <
        evalLogit net c (fun t => x t + δ t)
```

If the codebase has an existing predicate for certified robustness, also restate this as a theorem showing the ball
`{x + δ | ‖δ‖∞ ≤ r}`
is label-stable.

---

### Why this matters

This theorem is the natural next step after binary tropical robustness. Binary certification only controls one chosen margin; multiclass classification requires simultaneous control against every competing class. The pairwise-gap viewpoint is exactly the right bridge between tropical geometry and modern robustness theory:

- tropical/ReLU residual networks already provide coordinatewise piecewise-linear structure and global Lipschitz control;
- pairwise gaps inherit that structure with only a constant-factor loss;
- the multiclass certificate is then an intersection of finitely many binary certificates.

Formally verifying this result would turn the current residual robustness story into a publishable multiclass theory: a genuine certification theorem for tropical residual networks, not just a binary surrogate. It also sets up later work on certified training objectives, tropical decision regions, and sharper class-dependent constants via pairwise rather than coordinatewise analysis.

A good end state is:
1. a fully abstract multiclass Lipschitz-margin theorem for `Fin k → (Fin d → ℝ) → ℝ`,
2. a minimum-margin corollary using `Finset.inf'`,
3. a residual-network specialization importing the existing tropical/ReLU robustness bound.

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
