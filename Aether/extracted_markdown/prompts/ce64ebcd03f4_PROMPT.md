## Research Task: Tropical Satake robustness bridge for GL3 score maps: certified multiclass invariance from dominant-coweight margin separation

Research Mode: PROVE

Work in a concrete finite-coordinate model of the GL3 tropical Satake test family. The key point is to turn the qualitative “finite separating family” statement into a quantitative robustness theorem for multiclass score maps built from max-plus linear forms on those coordinates.

### Precise theorem package to aim for

Use a finite index type `ι` for the separating coordinates, with each coordinate interpreted as a tropical Satake observable (simple-coroot edge valuation, rank-1 Levi marginal, rank-2 Levi marginal, etc.). Represent an input by a coordinate vector `z : ι → ℝ`.

A class score should be a finite tropical affine functional:
```lean
def TropScore {ι κ : Type*} [Fintype ι] [DecidableEq ι]
    (A : κ → Finset (ι → ℝ)) (b : κ → ℝ) (c : κ) (z : ι → ℝ) : ℝ :=
  (A c).sup (fun a => (∑ i, a i + z i)) + b c
```
If you prefer a more Lean-friendly finite encoding, replace `ι → ℝ` by `ι →₀ ℝ` or by vectors indexed by `Fin n`.

For pairwise differences, isolate the simpler max-plus linear model first:
```lean
def LinearScoreDiff {ι : Type*} [Fintype ι]
    (a : ι → ℝ) (z : ι → ℝ) : ℝ :=
  ∑ i, a i * z i
```
and weighted perturbation budget
```lean
def DriftBudget {ι : Type*} [Fintype ι]
    (w eps : ι → ℝ) : ℝ :=
  ∑ i, |w i| * eps i
```

Prove the following concrete lemmas/theorems.

### 1. Weighted drift bound for score differences
This is the quantitative core that converts coordinatewise control into a margin certificate.

```lean
theorem linearScoreDiff_drift_bound
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℝ) (z z' : ι → ℝ) (eps : ι → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hdrift : ∀ i, |z' i - z i| ≤ eps i) :
    |LinearScoreDiff a z' - LinearScoreDiff a z|
      ≤ DriftBudget a eps := by
  ...
```

A useful affine variant:
```lean
theorem linearMargin_lower_bound
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℝ) (β : ℝ) (z z' : ι → ℝ) (eps : ι → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hdrift : ∀ i, |z' i - z i| ≤ eps i) :
    (LinearScoreDiff a z + β) - DriftBudget a eps
      ≤ LinearScoreDiff a z' + β := by
  ...
```

This should be proved by expanding the finite sum, rewriting the difference as
`∑ i, a i * (z' i - z i)`, and applying the triangle inequality together with
`|a i * (z' i - z i)| = |a i| * |z' i - z i| ≤ |a i| * eps i`.

### 2. Binary robustness from a strict margin
This is the simplest certification theorem.

```lean
theorem binary_margin_robust
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℝ) (β : ℝ) (z z' : ι → ℝ) (eps : ι → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hdrift : ∀ i, |z' i - z i| ≤ eps i)
    (hmargin : 2 * DriftBudget a eps < LinearScoreDiff a z + β) :
    0 < LinearScoreDiff a z' + β := by
  ...
```

Equivalent and often cleaner formulation:
```lean
theorem binary_margin_robust'
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a : ι → ℝ) (β : ℝ) (z z' : ι → ℝ) (eps : ι → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hdrift : ∀ i, |z' i - z i| ≤ eps i)
    (hmargin : DriftBudget a eps < (LinearScoreDiff a z + β) / 2) :
    0 < LinearScoreDiff a z' + β := by
  ...
```

This is exactly the “half-margin” phenomenon: if the original pairwise margin exceeds twice the worst-case drift, its sign cannot flip.

### 3. Multiclass argmax invariance for finitely many classes
Now pass from pairwise score differences to class prediction stability.

Let classes be indexed by a finite type `κ`, and define:
```lean
def PredClass {κ : Type*} [Fintype κ] [DecidableEq κ]
    (score : κ → ℝ) : κ :=
  Finset.univ.argmax (fun c => score c)
```
or, if `argmax` bookkeeping becomes annoying, formulate the conclusion relationally:

```lean
def IsWinner {κ : Type*} (score : κ → ℝ) (c : κ) : Prop :=
  ∀ c', score c' ≤ score c
```

Then prove:

```lean
theorem multiclass_robust_of_pairwise_margins
    {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    (score : κ → (ι → ℝ) → ℝ)
    (c : κ) (z z' : ι → ℝ) (eps : ι → ℝ)
    (L : κ → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hpair :
      ∀ c', c' ≠ c →
        score c z - score c' z > 2 * L c')
    (hstable :
      ∀ c', c' ≠ c →
        |(score c z' - score c' z') - (score c z - score c' z)| ≤ L c') :
    IsWinner (fun k => score k z') c := by
  ...
```

The proof is short once the pairwise drift control is available: for each `c' ≠ c`,
```lean
score c z' - score c' z'
  ≥ (score c z - score c' z) - L c'
  > 2 * L c' - L c'
  = L c' ≥ 0,
```
hence `score c' z' ≤ score c z'`.

A sharper and more directly usable version packages the Lipschitz constant as a weighted budget coming from a coefficient vector:
```lean
theorem multiclass_robust_of_weighted_margins
    {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    (c : κ)
    (d : κ → ι → ℝ)      -- pairwise difference coefficients: c vs c'
    (β : κ → ℝ)          -- pairwise affine offsets
    (z z' : ι → ℝ) (eps : ι → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hneq0 : β c = 0 := by simp) :
    (∀ c', c' ≠ c →
      2 * DriftBudget (d c') eps < LinearScoreDiff (d c') z + β c') →
    (∀ i, |z' i - z i| ≤ eps i) →
    (∀ c', c' ≠ c → 0 < LinearScoreDiff (d c') z' + β c') := by
  ...
```

This theorem is the direct formal analogue of the statement
`m_{c,c'}(x) > 2 ∑ i |a_i^{c,c'}| ε_i`.

### 4. Max-plus score maps: reduction to finitely many Satake coordinates
To connect with tropical Hecke score maps, prove that if each class score is a max of finitely many affine forms in the separating coordinates, then each pairwise score difference admits a finite drift bound obtained by controlling each branch separately.

A useful one-sided lemma is:
```lean
theorem tropScore_upper_drift
    {ι κ : Type*} [Fintype ι] [DecidableEq ι] [DecidableEq κ]
    (A : κ → Finset (ι → ℝ)) (b : κ → ℝ)
    (c : κ) (z z' : ι → ℝ) (eps : ι → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hA :
      ∀ a ∈ A c, ∀ i, 0 ≤ a i)
    (hdrift : ∀ i, |z' i - z i| ≤ eps i) :
    TropScore A b c z' ≤ TropScore A b c z + ∑ i, eps i := by
  ...
```

But the more natural theorem for robustness is to assume each pairwise margin already comes with an explicit finite affine presentation on the separating family. In other words, do not get stuck trying to prove a false global linearization theorem for arbitrary max-minus-max expressions. Instead formalize the theorem under the hypothesis that for each competitor `c' ≠ c`, the pairwise margin
```lean
fun z => score c z - score c' z
```
is represented by a specific finite affine form, or at least is certified to have a drift bound `L c'`. This is the correct abstraction barrier between the tropical Satake side and the robustness side.

### 5. GL3-specific wrapper theorem
Finally, package the previous abstract result in a theorem whose names and hypotheses reflect the intended GL3 interpretation. Keep the content concrete: a finite coordinate family, a score map depending only on those coordinates, and a certified perturbation radius on those coordinates.

A suggested final statement is:

```lean
theorem gl3_tropical_satake_certified_robustness
    {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    (phi : α → ι → ℝ)              -- finite GL3 separating coordinate family
    (score : κ → (ι → ℝ) → ℝ)      -- class scores in Satake coordinates
    (x x' : α) (c : κ)
    (eps : ι → ℝ) (L : κ → ℝ)
    (hε : ∀ i, 0 ≤ eps i)
    (hdrift : ∀ i, |phi x' i - phi x i| ≤ eps i)
    (hpair :
      ∀ c', c' ≠ c →
        score c (phi x) - score c' (phi x) > 2 * L c')
    (hLip :
      ∀ c', c' ≠ c →
        |(score c (phi x') - score c' (phi x'))
         - (score c (phi x) - score c' (phi x))| ≤ L c') :
    IsWinner (fun k => score k (phi x')) c := by
  ...
```

If you want an even more explicit theorem, replace `hLip` by the weighted coefficient presentation:
```lean
(hcoeff : ∀ c', c' ≠ c, ∃ a : ι → ℝ, ∃ β : ℝ,
  (∀ z, score c z - score c' z = LinearScoreDiff a z + β) ∧
  L c' = DriftBudget a eps)
```
and derive `hLip` from `linearScoreDiff_drift_bound`.

### Proof strategy hints

1. **Establish the finite-sum perturbation inequality first.**  
   This is the technical engine. Expand
   ```lean
   LinearScoreDiff a z' - LinearScoreDiff a z
   = ∑ i, a i * (z' i - z i)
   ```
   using `Finset.sum_sub_distrib`, `sub_eq_add_neg`, and distributivity. Then bound the absolute value of the sum by the sum of absolute values via `abs_sum_le_sum_abs`, and each term by
   `|a i| * eps i`.

2. **Turn absolute drift control into sign preservation.**  
   From
   ```lean
   |m(z') - m(z)| ≤ B
   ```
   deduce
   ```lean
   m(z') ≥ m(z) - B.
   ```
   If `m(z) > 2B`, then `m(z') > B ≥ 0`. This is the exact half-margin argument, and it is what should drive every multiclass theorem.

3. **Use pairwise winner characterization instead of a brittle `argmax` API at first.**  
   Define `IsWinner score c := ∀ c', score c' ≤ score c`. This avoids unnecessary finite-argmax machinery. Once the theorem is proved in this relational form, you can add a corollary about `Finset.argmax` if desired.

4. **Abstract the Satake geometry into a finite coordinate map.**  
   The real mathematical content is that the GL3 tropical Hecke functional is finitely determined by the separating family. In Lean, encode this as “all scores depend only on `phi x : ι → ℝ`”. Then the robustness theorem becomes a finite-dimensional tropical statement. This is exactly the bridge from representation-theoretic tropical data to certified robustness.

5. **Do not overcommit to a false linearization of arbitrary max-plus differences.**  
   For general tropical affine scores, `score c - score c'` need not be globally affine. The correct theorem should either:
   - assume explicit pairwise affine presentations on the region of interest, or
   - assume a supplied pairwise drift bound `L c'`, and prove robustness from that.
   This is mathematically cleaner and much easier to formalize rigorously.

### Significance

This theorem is valuable because it upgrades finite determinacy of GL3 tropical Satake data from a qualitative reconstruction principle to a quantitative certification principle. The separating coordinate family is no longer only enough to distinguish Hecke data; it becomes enough to certify stability of representation-theoretic tropical decisions under perturbation. That is the exact analogue of margin-based certified robustness for tropical/piecewise-linear neural classifiers, but now in a genuinely non-neural decision class arising from tropical Langlands/Satake structure.

A successful formalization would therefore create a reusable bridge theorem:

- **input side:** perturbations of GL3 data measured only through finitely many tropical Satake coordinates,
- **decision side:** multiclass prediction by tropical score maps,
- **output side:** a rigorous certified invariance theorem from pairwise margin separation.

This should serve as the foundational robustness result for any future “tropical Hecke classifier” built from finitely supported dominant-coweight data, and it gives a precise formal interface between tropical representation theory and the certified robustness program already developed for tropical max-plus models.

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

Research domain: Bridges
Research mode: prove
