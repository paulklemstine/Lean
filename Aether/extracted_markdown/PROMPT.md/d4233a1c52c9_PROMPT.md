## Research Task: Tropical certified robustness for multiclass piecewise-linear networks under monotone min-margin score aggregation

Research Mode: PROVE

Prove a compositional robustness theorem for multiclass piecewise-linear/tropical networks in which certification is mediated by aggregated pairwise class margins rather than by direct aggregation of logits. The central object is the family of pairwise gaps
\[
g_{i,j}(x) := f_i(x) - f_j(x),
\]
and for a predicted class \(y\), an aggregate certificate
\[
A_y(x) := \Phi(v_y(x)), \qquad v_y(x)_j = f_y(x) - f_j(x)\ \ (j \neq y),
\]
where \(\Phi\) is coordinatewise monotone and \(1\)-Lipschitz with respect to \(\ell_\infty\). The main theorem should show that a positive margin for \(A_y\) at \(x_0\), large enough to absorb perturbation of all pairwise gaps, certifies preservation of the top-1 class on the whole \(\ell_\infty\)-ball.

This is a genuine extension of the current tropical robustness program: the certificate is not a direct function of the logits, but a monotone score on the geometry of pairwise comparisons. The resulting theorem should be reusable for `min`, min/max trees, and any custom aggregator satisfying a positivity-to-coordinatewise-positivity implication.

### Concrete formal setup

Use a finite class set `Fin C` with `C : ℕ` and `hC : 0 < C`. It is easiest to assume `C ≥ 2` for the nontrivial pairwise statements.

Represent logits as a function
```lean
f : α → Fin C → ℝ
```
for some input type `α`, ideally `α = Fin d → ℝ` if you want to connect directly to existing `ℓ∞` perturbation lemmas. Define the pairwise gap family by
```lean
def pairGap (f : α → Fin C → ℝ) (i j : Fin C) (x : α) : ℝ := f x i - f x j
```

For the aggregated certificate, avoid fighting dependent tuples indexed by `j ≠ y` unless necessary. A practical Lean formulation is to aggregate over all classes with the diagonal entry forced to `0`, or to define vectors on `Fin C` and require the positivity implication only for `j ≠ y`. For example:
```lean
def marginVec (f : α → Fin C → ℝ) (y : Fin C) (x : α) : Fin C → ℝ :=
  fun j => f x y - f x j
```
Then `marginVec f y x y = 0`, and the meaningful coordinates are the off-diagonal ones.

A general aggregator can be modeled as
```lean
Φ : (Fin C → ℝ) → ℝ
```
together with hypotheses:

```lean
def CoordwiseMonotone (Φ : (Fin C → ℝ) → ℝ) : Prop :=
  ∀ ⦃u v : Fin C → ℝ⦄, (∀ i, u i ≤ v i) → Φ u ≤ Φ v

def LipschitzOneInf (Φ : (Fin C → ℝ) → ℝ) : Prop :=
  ∀ u v, |Φ u - Φ v| ≤ ‖u - v‖∞

def PositivityImpliesOffDiagPositive
    (Φ : (Fin C → ℝ) → ℝ) : Prop :=
  ∀ ⦃y : Fin C⦄ ⦃v : Fin C → ℝ⦄,
    Φ v > 0 → ∀ j, j ≠ y → v j > 0
```

If `‖u - v‖∞` is inconvenient on function spaces, replace it by an explicit coordinatewise bound:
```lean
def LipschitzOneCoordwise (Φ : (Fin C → ℝ) → ℝ) : Prop :=
  ∀ u v, (∀ i, |u i - v i| ≤ δ) → |Φ u - Φ v| ≤ δ
```
or, more canonically:
```lean
def LipschitzOneSup (Φ : (Fin C → ℝ) → ℝ) : Prop :=
  ∀ u v, |Φ u - Φ v| ≤ Finset.univ.sup' (by simp) (fun i : Fin C => |u i - v i|)
```
This latter form often avoids introducing a full metric structure on `Fin C → ℝ`.

### Main theorem: abstract bridge from aggregated pairwise margin to argmax stability

A strong and Lean-friendly target theorem is:

```lean
theorem robust_of_pairwise_aggregated_margin
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hmono : CoordwiseMonotone Φ)
    (hLip : ∀ u v,
      |Φ u - Φ v| ≤ Finset.univ.sup' (by simpa using hC) (fun i : Fin C => |u i - v i|))
    (hpos : PositivityImpliesOffDiagPositive Φ)
    (hgap :
      ∀ x x' i j,
        |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * d * ‖x - x'‖∞)
    (x₀ x : Fin d → ℝ)
    (y : Fin C)
    (hball : ‖x - x₀‖∞ ≤ ε)
    (hcert : Φ (marginVec f y x₀) > 2 * K * d * ε) :
    ∀ j, j ≠ y → f x y > f x j
```

and hence a corollary:

```lean
theorem top1_stable_of_pairwise_aggregated_margin
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hmono : CoordwiseMonotone Φ)
    (hLip : ∀ u v,
      |Φ u - Φ v| ≤ Finset.univ.sup' (by simpa using hC) (fun i : Fin C => |u i - v i|))
    (hpos : PositivityImpliesOffDiagPositive Φ)
    (hgap :
      ∀ x x' i j,
        |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * d * ‖x - x'‖∞)
    (x₀ x : Fin d → ℝ)
    (y : Fin C)
    (hball : ‖x - x₀‖∞ ≤ ε)
    (hcert : Φ (marginVec f y x₀) > 2 * K * d * ε) :
    ∀ j, f x j ≤ f x y
```

The strict pairwise version is the mathematically essential statement; the weak `argmax` version follows immediately by cases on `j = y` or `j ≠ y`.

### More conceptual variant using domination of coordinatewise minimum

A particularly natural special case is when positivity is deduced from a lower bound by the minimum coordinate. Introduce:

```lean
def DominatesMin (Φ : (Fin C → ℝ) → ℝ) : Prop :=
  ∀ v, (Finset.univ.inf' (by simp) v) ≤ Φ v
```

Then prove:

```lean
theorem positivity_from_min_domination
    {C : ℕ} (hC : 0 < C)
    {Φ : (Fin C → ℝ) → ℝ}
    (hdom : DominatesMin Φ) :
    PositivityImpliesOffDiagPositive Φ := by
  ...
```

The key mathematical fact is:
if `min_i v i ≤ Φ v` and `Φ v > 0`, then `min_i v i > 0`, hence every coordinate is positive. This gives a large class of admissible aggregators automatically, including `min`, and many nested min/max trees once you separately prove they dominate the minimum.

A sharpened theorem then becomes:

```lean
theorem robust_of_pairwise_aggregated_margin_of_min_domination
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hLip : ∀ u v,
      |Φ u - Φ v| ≤ Finset.univ.sup' (by simpa using hC) (fun i : Fin C => |u i - v i|))
    (hdom : DominatesMin Φ)
    (hgap :
      ∀ x x' i j,
        |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * d * ‖x - x'‖∞)
    (x₀ x : Fin d → ℝ)
    (y : Fin C)
    (hball : ‖x - x₀‖∞ ≤ ε)
    (hcert : Φ (marginVec f y x₀) > 2 * K * d * ε) :
    ∀ j, j ≠ y → f x y > f x j
```

This is likely the cleanest theorem for downstream reuse.

### Specialization to the minimum aggregator

You should definitely prove the `Φ = min` instance explicitly, since it is the canonical min-margin certificate:

```lean
def minMarginAgg {C : ℕ} (hC : 0 < C) : (Fin C → ℝ) → ℝ :=
  fun v => Finset.univ.inf' (by simpa using hC) v
```

Target theorem:

```lean
theorem robust_of_min_pairwise_margin
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hgap :
      ∀ x x' i j,
        |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * d * ‖x - x'‖∞)
    (x₀ x : Fin d → ℝ)
    (y : Fin C)
    (hball : ‖x - x₀‖∞ ≤ ε)
    (hcert : minMarginAgg hC (marginVec f y x₀) > 2 * K * d * ε) :
    ∀ j, j ≠ y → f x y > f x j
```

This theorem should be straightforward once the abstract bridge is in place. It is the multiclass analogue of the binary margin certificate, but expressed entirely through pairwise gap geometry.

### Optional stronger theorem: robustness of the aggregated certificate itself

Besides stability of the class label, prove the certificate perturbation inequality itself:

```lean
theorem aggregated_margin_lower_bound_under_perturbation
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (Φ : (Fin C → ℝ) → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K) (hε : 0 ≤ ε)
    (hLip : ∀ u v,
      |Φ u - Φ v| ≤ Finset.univ.sup' (by simpa using hC) (fun i : Fin C => |u i - v i|))
    (hgap :
      ∀ x x' i j,
        |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * d * ‖x - x'‖∞)
    (x₀ x : Fin d → ℝ)
    (y : Fin C)
    (hball : ‖x - x₀‖∞ ≤ ε) :
    Φ (marginVec f y x) ≥ Φ (marginVec f y x₀) - 2 * K * d * ε
```

This is a useful intermediate result and makes the final robustness proof modular:
1. bound each coordinate perturbation of `marginVec`,
2. pass through `Φ` by Lipschitzness,
3. deduce positivity at `x`,
4. conclude all pairwise gaps remain positive.

### Concrete proof strategy

1. **Prove the coordinatewise perturbation bound for pairwise margins.**  
   Show for every `j : Fin C`,
   ```lean
   |marginVec f y x j - marginVec f y x₀ j| ≤ 2 * K * d * ε
   ```
   from `hgap`, applied to `(i, j) = (y, j)`, plus `hball`.  
   This is the basic transfer from network Lipschitz control to pairwise certificate control.

2. **Upgrade coordinatewise bounds to a sup bound on the margin vector.**  
   Prove
   ```lean
   Finset.univ.sup' _ (fun j => |marginVec f y x j - marginVec f y x₀ j|) ≤ 2 * K * d * ε
   ```
   by `Finset.sup'_le`. This is the exact quantity needed by the `1`-Lipschitz hypothesis on `Φ`.

3. **Derive certificate stability.**  
   Using the previous step and `hLip`, obtain
   ```lean
   |Φ (marginVec f y x) - Φ (marginVec f y x₀)| ≤ 2 * K * d * ε
   ```
   and therefore
   ```lean
   Φ (marginVec f y x) > 0
   ```
   from `hcert : Φ (marginVec f y x₀) > 2 * K * d * ε`.  
   The arithmetic step is:
   \[
   \Phi(v_x) \ge \Phi(v_{x_0}) - |\Phi(v_x)-\Phi(v_{x_0})| > 0.
   \]

4. **Convert positivity of the aggregate certificate into positivity of every pairwise gap.**  
   Apply `hpos` (or derive it from `DominatesMin`) to conclude:
   ```lean
   ∀ j ≠ y, marginVec f y x j > 0
   ```
   i.e.
   ```lean
   ∀ j ≠ y, f x y - f x j > 0.
   ```

5. **Rewrite to top-1 stability.**  
   Finish by `linarith` or `nlinarith`:
   ```lean
   f x y > f x j
   ```
   for all `j ≠ y`, and hence `f x j ≤ f x y` for all `j`.

### Key auxiliary lemmas worth formalizing separately

These should make the main theorem short and reusable.

```lean
theorem marginVec_sub_eq_pairGap
    {C : ℕ} (f : α → Fin C → ℝ) (y j : Fin C) (x : α) :
    marginVec f y x j = pairGap f y j x := by
  rfl
```

```lean
theorem sup_pairwise_margin_change_le
    {C d : ℕ} (hC : 0 < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K ε : ℝ)
    (hgap :
      ∀ x x' i j,
        |pairGap f i j x - pairGap f i j x'| ≤ 2 * K * d * ‖x - x'‖∞)
    (x₀ x : Fin d → ℝ)
    (y : Fin C)
    (hball : ‖x - x₀‖∞ ≤ ε) :
    Finset.univ.sup' (by simpa using hC)
      (fun j : Fin C => |marginVec f y x j - marginVec f y x₀ j|) ≤ 2 * K * d * ε := by
  ...
```

```lean
theorem positive_all_coords_of_inf'_pos
    {C : ℕ} (hC : 0 < C) {v : Fin C → ℝ}
    (h : Finset.univ.inf' (by simpa using hC) v > 0) :
    ∀ i, v i > 0 := by
  ...
```

```lean
theorem min_aggregator_lipschitz_one
    {C : ℕ} (hC : 0 < C) :
    ∀ u v : Fin C → ℝ,
      |minMarginAgg hC u - minMarginAgg hC v|
        ≤ Finset.univ.sup' (by simpa using hC) (fun i : Fin C => |u i - v i|) := by
  ...
```

The last lemma is especially valuable: it isolates the finite-dimensional metric fact that the minimum map is `1`-Lipschitz in `ℓ∞`. It should be proved by the standard sandwich:
\[
\min u \le \min v + \sup_i |u_i-v_i|,\qquad
\min v \le \min u + \sup_i |u_i-v_i|.
\]

### Recommended implementation choices in Lean

- Prefer `Fin C → ℝ` over vectors/subtypes for the aggregator domain; it keeps theorems compositional.
- Use `Finset.univ.sup'` and `Finset.univ.inf'` for finite sup/inf over `Fin C`.
- Keep a separate theorem for the logical implication `Φ(v) > 0 → ∀ j ≠ y, v j > 0`; this makes the main robustness theorem independent of the internal structure of `Φ`.
- For arithmetic, `linarith` should handle the transition from absolute-value bounds to positivity once you have the inequality
  ```lean
  |Φ u - Φ v| ≤ δ
  ```
  and the assumption `Φ v > δ`.
- If the existing tropical library already gives a logit perturbation theorem rather than a pair-gap theorem, derive
  ```lean
  |(f x i - f x j) - (f x₀ i - f x₀ j)| ≤ 2 * K * d * ε
  ```
  by the triangle inequality from two one-logit bounds. That derivation is itself worth recording as a lemma.

### Why this matters

This theorem creates a new bridge principle for certified robustness: any multiclass certificate built from pairwise margins through a monotone `1`-Lipschitz aggregator inherits tropical robustness directly from the network’s global Lipschitz control. It strictly generalizes the standard worst-case pairwise margin certificate (`min_j (f_y-f_j)`) and opens the door to richer tropical decision architectures, such as nested min/max score trees, hybrid hierarchical-vs-pairwise certificates, and future tropical Hecke-style or idempotent aggregation schemes. Formally, it gives a clean separation between:
1. analytic control of pairwise gap perturbations, and
2. order-theoretic properties of the aggregator.

That separation is exactly the reusable abstraction needed for the broader tropical certified robustness program.

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
