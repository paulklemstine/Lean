## Research Task: GL3 tropical Satake certified robustness for hierarchical one-vs-one Hecke-score classifiers via tournament margin decomposition

Research Mode: PROVE

Develop a formally precise robustness theory for hierarchical multiclass classifiers built from pairwise tropical Hecke-score comparisons arranged in a fixed binary elimination tree. The key point is that robustness should be certified along the **realized winner path** rather than by a global all-pairs condition. This gives a sharper and structurally new certificate compared to one-vs-rest or voting-style aggregation.

### Precise objects to define

Work over a finite class index type `α` with `[Fintype α] [DecidableEq α]`. Use a binary tree whose leaves are labeled by classes in `α`, and whose internal nodes recursively combine two disjoint subtrees.

A convenient Lean representation is:

```lean
inductive HTree (α : Type)
| leaf : α → HTree α
| node : HTree α → HTree α → HTree α
deriving DecidableEq
```

Define:
- `HTree.classes : HTree α → Finset α`, the set of leaves in the subtree.
- `HTree.eval : HTree α → (α → ℝ) → α`, the winner obtained by recursively comparing the winners of the two children using the score function.
- `HTree.margin : HTree α → (α → ℝ) → ℝ`, the minimum absolute pairwise margin encountered along the realized winner path.

The intended recursive definitions are:

```lean
def HTree.eval [LinearOrder α] : HTree α → (α → ℝ) → α
| .leaf a, s => a
| .node L R, s =>
    let u := eval L s
    let v := eval R s
    if s u ≥ s v then u else v
```

and

```lean
def HTree.margin [LinearOrder α] : HTree α → (α → ℝ) → ℝ
| .leaf a, s => Real.top -- or use a separate Option/leaf convention
| .node L R, s =>
    let u := eval L s
    let v := eval R s
    let local := |s u - s v|
    min local (min (margin L s) (margin R s))
```

However, this “global subtree minimum” is stronger than needed. The sharper object is the minimum margin **only along the realized winner path**. So define instead:

```lean
def HTree.pathMargin [LinearOrder α] : HTree α → (α → ℝ) → ℝ
| .leaf _, s => 0
| .node L R, s =>
    let u := eval L s
    let v := eval R s
    let local := |s u - s v|
    if s u ≥ s v then min local (pathMargin L s)
    else min local (pathMargin R s)
```

This leaf value `0` is awkward if you want a direct radius formula. A better theorem statement avoids division by zero by formulating a nodewise predicate “every comparison on the realized path has margin > c”. Alternatively define an auxiliary proposition collecting the margins on the realized path as a finite list/finset and then take its infimum. If you want a cleaner executable definition, define:

```lean
def HTree.certRadius (K d : ℝ) [LinearOrder α] (T : HTree α) (s : α → ℝ) : ℝ :=
  pathMargin T s / (2 * K * d)
```

under hypotheses `0 < K`, `0 < d`, and with the convention that only non-leaf trees are certified.

You also need a perturbation model. Let `X` be the input space, e.g. `X := Fin n → ℝ`, with `‖x - y‖∞` represented concretely by
```lean
Finset.sup (Finset.univ) (fun i => |x i - y i|)
```
or use an existing `dist`/`‖·‖` if the ambient type is already normed. To keep the theorem accessible, parameterize by:
- `score : α → X → ℝ`
- a pairwise Lipschitz hypothesis
```lean
∀ u v x y, |((score u x - score v x) - (score u y - score v y))| ≤ 2 * K * d * D x y
```
where `D : X → X → ℝ` is your chosen `L∞` distance surrogate.

### Main theorem: pathwise hierarchical robustness

A strong and Lean-friendly statement is:

```lean
theorem HTree.eval_const_on_ball_of_pairwise_gap
    {α X : Type}
    [Fintype α] [DecidableEq α] [LinearOrder α]
    (T : HTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (K d r : ℝ)
    (hK : 0 ≤ K)
    (hd : 0 ≤ d)
    (hLip :
      ∀ u v x y,
        |((score u x - score v x) - (score u y - score v y))|
          ≤ 2 * K * d * D x y)
    {x y : X}
    (hy : D x y ≤ r)
    (hmargin :
      2 * K * d * r < T.pathMargin (fun a => score a x)) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

Because `pathMargin` is recursive and leaf-based, you may need a theorem specialized to non-leaf trees or a strengthened induction statement that simultaneously proves winner stability and path-margin transport on the realized branch.

An even cleaner formulation avoids `pathMargin` in the theorem hypothesis and instead uses a recursive predicate:

```lean
def HTree.StableAt
    [LinearOrder α]
    (T : HTree α) (score : α → X → ℝ) (x : X) (ρ : ℝ) : Prop
```

meaning: every local comparison on the realized winner path at `x` has margin strictly larger than `2*K*d*ρ`. Then prove:

```lean
theorem HTree.eval_eq_of_stableAt
    ...
    (hstable : T.StableAt score x r)
    (hy : D x y ≤ r) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

After that, derive the explicit certificate:

```lean
theorem HTree.eval_eq_of_lt_certRadius
    {α X : Type}
    [Fintype α] [DecidableEq α] [LinearOrder α]
    (T : HTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (K d : ℝ)
    (hK : 0 < K)
    (hd : 0 < d)
    (hLip :
      ∀ u v x y,
        |((score u x - score v x) - (score u y - score v y))|
          ≤ 2 * K * d * D x y)
    {x y : X}
    (hy : D x y ≤ T.certRadius K d (fun a => score a x)) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

You should also prove the simpler “uniform local gap” corollary matching the original informal statement:

```lean
theorem HTree.eval_eq_of_forall_path_gap
    ...
    (hgap : ∀ comparison (hcomp : comparison ∈ T.realizedComparisons (fun a => score a x)),
      2 * K * d * r < comparison.marginAt (fun a => score a x))
    (hy : D x y ≤ r) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

If encoding `realizedComparisons` is cumbersome, keep the recursive `pathMargin` formulation.

### Heterogeneous local constants

The more interesting extension is to allow each internal node to have its own Lipschitz constant. This is mathematically sharper and often more natural in hierarchical architectures.

Label each internal node with a constant `L : ℝ` so that for the local winner pair `(u,v)` selected at that node one has
```lean
|((score u x - score v x) - (score u y - score v y))| ≤ L * D x y.
```

A simple way is to define a labeled tree:

```lean
inductive LHTree (α : Type)
| leaf : α → LHTree α
| node : ℝ → LHTree α → LHTree α → LHTree α
```

Then define the realized-path certified radius recursively as the minimum over the realized winner path of `localMargin / localLip`. Prove:

```lean
theorem LHTree.eval_eq_of_lt_pathCert
    {α X : Type}
    [Fintype α] [DecidableEq α] [LinearOrder α]
    (T : LHTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (hLip : T.NodewiseLip score D)
    {x y : X}
    (hy : D x y < T.pathCert score x) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

In the GL3 tropical Satake application, instantiate `localLip = 2 * K_uv * d` or globally `2 * K * d`.

### Proof strategy

1. **Local pairwise sign preservation lemma.**  
   First prove a generic comparison-stability lemma:
   ```lean
   lemma pairwise_winner_stable_of_margin
       {a b A B r : ℝ}
       (hAB : |A - B| ≤ r)
       (hmargin : r < |a|)
       (hdef : B = A + (B - A)) :
       (0 ≤ a ↔ 0 ≤ a + (B - A))
   ```
   but in a cleaner form specialized to scores:
   ```lean
   lemma compare_stable_of_gap
       (hLip : |((su_x - sv_x) - (su_y - sv_y))| ≤ δ)
       (hgap : δ < |su_x - sv_x|) :
       ((su_x ≥ sv_x) ↔ (su_y ≥ sv_y))
   ```
   This is the atomic robustness step: if perturbation of the score difference is smaller than the current margin, the sign cannot flip. You may prove it by contradiction using
   `abs_sub_le_iff` or interval reasoning on `su_y - sv_y`.

2. **Recursive winner stability on the realized branch.**  
   Prove by induction on `T` a strengthened statement:
   - the winner of `T` at `y` equals the winner at `x`;
   - moreover, for the branch selected by the winner at `x`, the induction hypothesis applies to the corresponding child.
   
   At a node `node L R`, let `u := eval L sx`, `v := eval R sx`.  
   Use the induction hypotheses to show the child winners are unchanged at `y`, so the root comparison at `y` is still between the same pair `(u,v)`. Then apply the local pairwise sign-preservation lemma to conclude the root decision is unchanged.

3. **Why realized-path minima are sufficient.**  
   The crucial structural point is that you do **not** need margins from comparisons in subtrees that are never visited by the winner path at `x`. Once the winning child at a node is shown stable, the losing sibling subtree is irrelevant for the final label. Formalize this by making the induction hypothesis only descend into the chosen child. This yields the sharper certificate `pathMargin` instead of a wasteful minimum over all internal nodes.

4. **Ball-wise constancy theorem.**  
   Package the pointwise stability result into:
   ```lean
   theorem eval_const_on_closedBall ...
   ```
   stating that for fixed `x`, `T.eval (score · y)` is constant for all `y` with `D x y ≤ r` whenever `r < certRadius ... x`. This theorem is useful for later certified-robustness APIs.

5. **Heterogeneous constant refinement.**  
   After the uniform-`K` theorem works, abstract the proof so that each node uses its own perturbation budget. The induction should be identical, with `2*K*d*r` replaced by the node-specific quantity. This refinement is where the theorem becomes genuinely stronger than a direct restatement of existing pairwise robustness.

### Concrete supporting lemmas worth proving first

These will make the main induction manageable.

```lean
lemma abs_sub_score_diff_le
    (hLip :
      ∀ u v x y,
        |((score u x - score v x) - (score u y - score v y))|
          ≤ 2 * K * d * D x y)
    (hy : D x y ≤ r) :
    |((score u x - score v x) - (score u y - score v y))|
      ≤ 2 * K * d * r
```

```lean
lemma sign_preserved_of_abs_diff_lt_abs
    {a b : ℝ}
    (h : |a - b| < |a|) :
    (0 ≤ a ↔ 0 ≤ b)
```

```lean
lemma ge_preserved_of_score_gap
    {su_x sv_x su_y sv_y δ : ℝ}
    (hδ : |((su_x - sv_x) - (su_y - sv_y))| ≤ δ)
    (hgap : δ < |su_x - sv_x|) :
    (su_x ≥ sv_x ↔ su_y ≥ sv_y)
```

```lean
lemma eval_node_eq_left_of_child_and_root_stability
    ...
```

```lean
lemma pathMargin_pos_of_internal_and_strict_gaps
    ...
```

If `LinearOrder α` is only used for tie-breaking at leaves or deterministic evaluation, note that the real comparison is on scores, not labels. You may avoid any label order entirely by using `if score u ≥ score v then u else v`.

### Suggested theorem package

A good final file would contain the following progression.

1. `HTree.eval`
2. `HTree.pathMargin`
3. local sign-preservation lemmas
4. `HTree.eval_eq_of_margin`
5. `HTree.eval_eq_of_lt_certRadius`
6. uniform-gap corollary for radius `r`
7. heterogeneous-node refinement

Representative final theorem signatures:

```lean
theorem HTree.eval_eq_of_lt_pathMargin
    {α X : Type}
    [Fintype α] [DecidableEq α]
    (T : HTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (K d : ℝ)
    (hLip :
      ∀ u v x y,
        |((score u x - score v x) - (score u y - score v y))|
          ≤ 2 * K * d * D x y)
    {x y : X}
    (hy : D x y ≤ r)
    (hmargin : 2 * K * d * r < T.pathMargin (fun a => score a x)) :
    T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

```lean
theorem HTree.robust_radius_spec
    {α X : Type}
    [Fintype α] [DecidableEq α]
    (T : HTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (K d : ℝ)
    (hK : 0 < K)
    (hd : 0 < d)
    (hLip :
      ∀ u v x y,
        |((score u x - score v x) - (score u y - score v y))|
          ≤ 2 * K * d * D x y) :
    ∀ x y,
      D x y < T.pathMargin (fun a => score a x) / (2 * K * d) →
      T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

And the heterogeneous refinement:

```lean
theorem LHTree.robust_radius_spec
    {α X : Type}
    [Fintype α] [DecidableEq α]
    (T : LHTree α)
    (score : α → X → ℝ)
    (D : X → X → ℝ)
    (hLip : T.NodewiseLip score D) :
    ∀ x y,
      D x y < T.pathCert score x →
      T.eval (fun a => score a y) = T.eval (fun a => score a x)
```

### Why this matters

This theorem gives a genuinely new certified-robustness architecture for tropical Satake / Hecke-score classifiers: **hierarchical elimination**. The certificate is sharper than global multiclass margins because it depends only on the comparisons actually used to produce the winner. That is exactly the right notion for tournament-style decision systems, and it opens a path toward:
- adaptive multiclass certificates that scale with tree depth rather than number of classes,
- non-voting aggregation schemes for tropical score geometry,
- later integration with learned or Satake-motivated elimination trees,
- and a clean abstraction layer for future GLₙ tropical Hecke classifiers.

The conceptual novelty is the decomposition of multiclass robustness into a composition of pairwise tropical certificates along a realized path. This is the natural theorem needed to extend the tropical certified robustness program beyond flat argmax and voting-based aggregators.

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
