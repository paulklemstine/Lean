## Research Task: Tropical certified robustness for multiclass piecewise-linear networks with hierarchical max-aggregation trees via subtree logit-gap margins

### Research Mode
PROVE

### Precise Lean 4 target

Work with a finite rooted aggregation tree whose leaves carry class-score functions `α → ℝ` indexed by `κ`, and whose internal nodes aggregate child score families by pointwise `sup`/`max`. Use a concrete tree type such as:

```lean
inductive AggTree (κ : Type*) where
  | leaf : (κ → α → ℝ) → AggTree κ
  | node : List (AggTree κ) → AggTree κ
```

or, if easier for finite-arity proofs, a rose tree over `Finset`/`List` with a nonempty-child hypothesis for internal nodes.

Define recursively the aggregated score family:
```lean
def AggTree.eval [Fintype κ] : AggTree κ → α → κ → ℝ
| .leaf f, x, i => f i x
| .node ts, x, i => ts.foldr (fun t acc => max (AggTree.eval t x i) acc) (-∞)   -- or use `sSup` over a finite set
```

A cleaner finite version avoiding `-∞` is preferable:
```lean
def AggTree.evalNE [Fintype κ] : {ts : List (AggTree κ) // ts ≠ []} → α → κ → ℝ
```
or a tree with children indexed by `Fin n.succ`.

Also define the recursive Lipschitz bound:
```lean
def AggTree.lip : AggTree κ → ℝ
| .leaf f => ...   -- supplied externally
| .node ts => ts.foldr (fun t acc => max (AggTree.lip t) acc) 0
```

The first theorem should be a max-preserves-Lipschitz lemma in `L∞` form.

Suggested exact statement:
```lean
theorem lipschitz_eval_of_leaf_lipschitz
  [Fintype κ]
  (T : AggTree κ)
  (Lleaf : AggTree κ → ℝ)
  (hleaf :
    ∀ f, (∀ i, LipschitzWith (ENNReal.ofReal (Lleaf (.leaf f))) (f i)) )
  :
  ∀ i, LipschitzWith (ENNReal.ofReal (AggTree.lip T)) (fun x => AggTree.eval T x i)
```

If `LipschitzWith` on `α` is awkward, specialize to `α = Fin n → ℝ` with `dist = ‖·‖∞`, or use an explicit estimate:
```lean
theorem eval_sub_le_lip_mul_dist
  [Fintype κ]
  (T : AggTree κ)
  (hleaf :
    ∀ f i x x', |f i x - f i x'| ≤ Lleaf (.leaf f) * dist x x')
  :
  ∀ i x x', |AggTree.eval T x i - AggTree.eval T x' i|
    ≤ AggTree.lip T * dist x x'
```

Then define pairwise logit gaps:
```lean
def gap (T : AggTree κ) (x : α) (i j : κ) : ℝ :=
  AggTree.eval T x i - AggTree.eval T x j
```

Define a recursive certified margin lower bound `certGap : AggTree κ → α → κ → κ → ℝ` satisfying:
- leaf: any given lower certificate for the leaf gap,
- node: minimum over child certificates.

A natural target:
```lean
def AggTree.certGap : AggTree κ → α → κ → κ → ℝ
| .leaf f => leafCert f
| .node ts => ts.foldr (fun t acc => min (AggTree.certGap t x i j) acc) (+∞)
```
again best implemented with a nonempty finite child family to avoid `±∞`.

The key structural theorem should be:

```lean
theorem certGap_le_gap
  [Fintype κ]
  (T : AggTree κ) (x : α) (i j : κ) :
  AggTree.certGap T x i j ≤ gap T x i j
```

But the genuinely useful version is the robust one:

```lean
theorem gap_perturb_lower_bound
  [Fintype κ]
  (T : AggTree κ) (x x' : α) (i j : κ)
  (hLip :
    ∀ x x' i, |AggTree.eval T x i - AggTree.eval T x' i|
      ≤ AggTree.lip T * dist x x') :
  gap T x' i j ≥ gap T x i j - 2 * AggTree.lip T * dist x x'
```

and then the certification theorem:

```lean
theorem argmax_stable_of_gap_gt
  [Fintype κ] [DecidableEq κ]
  (T : AggTree κ) (x x' : α) (y : κ)
  (hy :
    ∀ j ≠ y, 2 * AggTree.lip T * dist x x' < AggTree.certGap T x y j) :
  ∀ j ≠ y, AggTree.eval T x' y > AggTree.eval T x' j
```

Finally derive the radius certificate in `L∞` form, e.g. with `α = Fin n → ℝ`:
```lean
theorem robust_radius_lower_bound
  [Fintype κ] [DecidableEq κ]
  (T : AggTree κ) (x : Fin n → ℝ) (y : κ)
  (hy : ∀ j ≠ y, 0 < AggTree.certGap T x y j) :
  let r :=
    sInf {r : ℝ | ∃ j, j ≠ y ∧ r = AggTree.certGap T x y j / (2 * AggTree.lip T)}
  in
  ∀ x', ‖x' - x‖∞ < r → ∀ j ≠ y, AggTree.eval T x' y > AggTree.eval T x' j
```

If `sInf` is annoying, use the finite minimum over `univ.erase y`:
```lean
def classRadius [Fintype κ] [DecidableEq κ] (T : AggTree κ) (x : α) (y : κ) : ℝ :=
  ((Finset.univ.erase y).inf' _ (fun j => AggTree.certGap T x y j / (2 * AggTree.lip T)))
```

Then prove:
```lean
theorem classRadius_spec
  [Fintype κ] [DecidableEq κ]
  (T : AggTree κ) (x x' : α) (y : κ)
  (hball : dist x x' < classRadius T x y) :
  ∀ j ≠ y, AggTree.eval T x' y > AggTree.eval T x' j
```

### Core mathematical content to establish

1. **Pointwise max preserves Lipschitz constants by taking the maximum constant.**  
   For functions `f,g : α → ℝ`,
   ```lean
   |max (f x) (g x) - max (f y) (g y)| ≤ max Lf Lg * dist x y
   ```
   whenever `|f x - f y| ≤ Lf * dist x y` and similarly for `g`.  
   Generalize by induction to finite child families. This is the fundamental bottom-up estimate for internal nodes.

2. **Gap degradation under perturbation is at most twice the score Lipschitz constant.**  
   For any class pair `(i,j)`,
   ```lean
   gap T x' i j ≥ gap T x i j - 2 * AggTree.lip T * dist x x'
   ```
   by applying the Lipschitz estimate separately to logits `i` and `j` and combining with
   ```lean
   (a' - b') ≥ (a - b) - |a-a'| - |b-b'|.
   ```

3. **Subtree certificate lower-bounds the true root gap.**  
   The nontrivial tropical step is to show that if a parent score is a max over children, then for fixed `(i,j)`:
   ```lean
   min_c gap(child_c, x, i, j) ≤ gap(parent, x, i, j).
   ```
   Indeed, choose a child attaining the `j`-max; then
   ```lean
   max_c s_c(i) - max_c s_c(j) ≥ s_c(i) - s_c(j).
   ```
   Hence any lower bound valid for every child is valid for the parent. Iterating this yields a path/subtree witness certificate.

4. **Classification stability from positive pairwise margins.**  
   If `y` beats every `j ≠ y` at `x` by more than `2 L r`, then `y` remains the unique winner throughout the `r`-ball. This is the multiclass analogue of the flat max-pooling robustness theorem, now lifted through arbitrary hierarchical max aggregation.

### Concrete proof strategy

1. **Build the recursive tree semantics and Lipschitz bound.**  
   Prove by induction on `T` that each output coordinate `fun x => AggTree.eval T x i` is `AggTree.lip T`-Lipschitz.  
   Key local lemma:
   ```lean
   abs_max_sub_max_le_max :
     |max a b - max c d| ≤ max |a-c| |b-d|
   ```
   followed by
   ```lean
   max (Lf * δ) (Lg * δ) ≤ max Lf Lg * δ
   ```
   for `δ ≥ 0`.

2. **Prove the finite-family max lemma.**  
   For a nonempty list/finset of real-valued functions with common pointwise bounds,
   ```lean
   |(sup_i f_i x) - (sup_i f_i y)| ≤ (sup_i L_i) * dist x y.
   ```
   This is best done by induction over the list of children using the binary max lemma. This avoids delicate `sSup` arguments and keeps the development computational.

3. **Define recursive margin certificates and prove monotonicity.**  
   For internal node with children `c`,
   ```lean
   certGap(parent,x,i,j) = min_c certGap(c,x,i,j)
   ```
   and show
   ```lean
   certGap(parent,x,i,j) ≤ gap(parent,x,i,j)
   ```
   from the childwise inequalities and the elementary max-gap estimate:
   ```lean
   Finset.inf' ... ≤ gap child x i j ≤ gap parent x i j
   ```
   for a carefully chosen witness child, e.g. one maximizing class `j`.  
   If explicit argmax witnesses are cumbersome, first prove the weaker but sufficient inequality
   ```lean
   min_c gap(child,x,i,j) ≤ gap(parent,x,i,j)
   ```
   by selecting a maximizing child via `Finset.exists_max_image`.

4. **Derive perturbation stability of pairwise gaps.**  
   Combine the score Lipschitz theorem with:
   ```lean
   gap T x' i j
     = gap T x i j
       + (eval T x' i - eval T x i)
       - (eval T x' j - eval T x j)
   ```
   and bound the last two terms in absolute value. This yields the clean `2 * L * dist` degradation estimate.

5. **Conclude the multiclass robustness radius theorem.**  
   Let
   ```lean
   Γ(T,x,y,j) := AggTree.certGap T x y j
   ```
   and
   ```lean
   R(T,x,y) := min_{j ≠ y} Γ(T,x,y,j) / (2 * AggTree.lip T).
   ```
   Show that if `dist x x' < R(T,x,y)`, then every pairwise gap `gap T x' y j` remains positive, hence `y` is still the strict argmax.  
   This is the desired subtree logit-gap certificate.

### Suggested intermediate lemmas

These are worth stating explicitly because they are likely reusable:

```lean
theorem max_sub_max_le
  (a b c d : ℝ) :
  max a b - max c d ≤ max (a - c) (b - d)
```

```lean
theorem abs_max_sub_max_le
  (a b c d : ℝ) :
  |max a b - max c d| ≤ max |a - c| |b - d|
```

```lean
theorem gap_max_children_ge_child_gap
  (si sj : ι → ℝ) (c : ι) :
  si c - sj c ≤ (Finset.univ.sup si) - (Finset.univ.sup sj)
```
for finite `ι`, with the right `Finset` formulation.

```lean
theorem min_child_gap_le_parent_gap
  (children : Fin n.succ → AggTree κ) :
  (Finset.univ.inf' _ (fun c => gap (children c) x i j))
    ≤ gap (.node children) x i j
```

```lean
theorem gap_lower_under_perturbation
  (hyi : |eval T x i - eval T x' i| ≤ L * dist x x')
  (hyj : |eval T x j - eval T x' j| ≤ L * dist x x') :
  gap T x' i j ≥ gap T x i j - 2 * L * dist x x'
```

### Structural choices that will make the formalization smoother

- Prefer **nonempty finite branching** (`Fin n.succ → AggTree κ`) over arbitrary lists if possible. It makes `sup`, `inf'`, and witness extraction much easier.
- Prefer an explicit ambient input space like `α = Fin m → ℝ` or any `PseudoMetricSpace α`; if you want the exact `L∞` norm certificate, `Fin m → ℝ` with `‖x - x'‖∞` is concrete and compatible with existing norm lemmas.
- For classification, define strict winner as:
  ```lean
  def IsStrictWinner (T : AggTree κ) (x : α) (y : κ) : Prop :=
    ∀ j, j ≠ y → AggTree.eval T x y > AggTree.eval T x j
  ```
  Then the final theorem becomes a clean preservation statement for `IsStrictWinner`.

### Significance

This extends flat tropical/max-pooling robustness certificates to genuinely deep hierarchical max architectures. The new point is not merely that `max` is Lipschitz, but that **pairwise multiclass margins admit a recursive subtree certificate**: a local tropical comparison margin at every internal node propagates monotonically to the root, and the only global penalty is the accumulated max-Lipschitz constant. This gives a compositional, formally verified robustness guarantee for tree-structured piecewise-linear networks, exactly the kind of theorem needed for certified robustness beyond shallow aggregators. It also sets up a reusable tropical proof pattern for future work on attention trees, dynamic-programming networks, and tropical semiring verification, where deep `max` compositions are the essential obstacle.

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
