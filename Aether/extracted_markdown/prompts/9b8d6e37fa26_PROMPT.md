## Research Task: Tropical certified robustness for multiclass piecewise-linear networks under sequential elimination (tournament) decision via stagewise logit-gap margins

Research Mode: PROVE

Develop a formally robust theory of tournament-style multiclass decisions for piecewise-linear / tropical score maps. The goal is to replace the usual `argmax` semantics by a fixed binary elimination tree and prove a compositional certified robustness theorem: if every comparison on the winner path has margin strictly larger than the worst possible perturbation drift of the corresponding score difference, then the final tournament winner is unchanged on the whole perturbation ball.

This is mathematically interesting because tournament semantics is genuinely different from flat `argmax`: a class can lose globally while still win the tournament under a favorable bracket, and robustness therefore depends only on a sparse chain of comparisons rather than all pairwise class gaps. A clean formal theorem here gives a new certified-robustness primitive for hierarchical classifiers, bracketed decision systems, and tropical networks with staged comparison structure.

### Core objects to define

Use a concrete full binary tree of labels:
```lean
inductive Bracket (α : Type)
| leaf : α → Bracket α
| node : Bracket α → Bracket α → Bracket α
deriving DecidableEq
```

For scores `f : α → EuclideanSpace ℝ (Fin d) → ℝ` or simply
```lean
f : α → (Fin d → ℝ) → ℝ
```
define the recursive tournament winner:
```lean
def Bracket.winner [LinearOrder α] [DecidableEq α]
    (score : α → X → ℝ) : Bracket α → X → α
```
where at an internal node `node l r`, one compares the winners `a := winner score l x` and `b := winner score r x`; the node returns `a` if `score a x ≥ score b x`, else `b`.

Also define the winner-path margins at a point `x0` recursively: along the unique chain from the final champion leaf to the root, each internal node contributes the nonnegative quantity
```lean
max (score a x0 - score b x0) (score b x0 - score a x0)
```
but for the actual winner path you should orient it as
```lean
score w x0 - score o x0
```
where `w` is the child winner propagated upward at that node and `o` is the opposing child winner. The robust theorem should assume these oriented margins are strictly positive.

### First theorem: local invariance from winner-path inequalities

A good exact Lean target is:

```lean
theorem bracket_winner_const_of_pathwise_margin
    {α : Type} [DecidableEq α] [LinearOrder α]
    {d : ℕ}
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r : ℝ)
    (hr : 0 ≤ r)
    (L : α → α → ℝ)
    (hL_nonneg : ∀ a b, 0 ≤ L a b)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f b y)| ≤ L a b * ‖x - y‖)
    (hmargin :
      ∀ v ∈ T.winnerPath f x0,
        let w := v.winLabel f x0
        let o := v.oppLabel f x0
        2 * L w o * r < f w x0 - f o x0) :
    ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0
```

You will likely want a slightly different API than `winnerPath`, `winLabel`, `oppLabel`; that is fine, but the theorem should still express exactly this content: every internal comparison used by the champion at `x0` remains strictly in favor of the same branch throughout the radius-`r` ball, hence the root winner is fixed.

If encoding the winner path as a list/subtype of internal nodes is cumbersome, an equivalent stronger theorem by recursion on the tree may be easier:

```lean
theorem bracket_winner_const_of_recursive_margin
    {α : Type} [DecidableEq α] [LinearOrder α]
    {d : ℕ}
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r : ℝ)
    (hr : 0 ≤ r)
    (L : α → α → ℝ)
    (hL_nonneg : ∀ a b, 0 ≤ L a b)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f y)| ≤ L a b * ‖x - y‖) :
    recursiveMarginCert T f x0 r L →
    ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0
```

where `recursiveMarginCert` is an inductively defined predicate saying:
- leaves are automatically certified;
- for `node l r`, let `wl := l.winner f x0`, `wr := r.winner f x0`;
  require recursive certificates for the child subtree containing the eventual winner and for the opposing child if needed to stabilize its local winner, together with the strict comparison
  `2 * L wl wr * r < |f wl x0 - f wr x0|`,
  oriented so the winner at `x0` stays winner on the whole ball.

The recursive formulation is often the cleanest way to prove the pathwise one afterward.

### Second theorem: explicit certified radius lower bound

Once invariance on a fixed ball is proved, package it as a radius bound. A precise target is:

```lean
theorem le_certifiedRadius_of_pathMargins
    {α : Type} [DecidableEq α] [LinearOrder α]
    {d : ℕ}
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (L : α → α → ℝ)
    (hL_pos : ∀ a b, 0 < L a b)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f b y)| ≤ L a b * ‖x - y‖) :
    let c := T.winner f x0
    let path := T.winnerPath f x0
    let rad :=
      path.inf' (by exact T.winnerPath_nonempty _ _) (fun v =>
        (f (v.winLabel f x0) x0 - f (v.oppLabel f x0) x0) /
        (2 * L (v.winLabel f x0) (v.oppLabel f x0)))
    ∀ r, 0 ≤ r → r < rad →
      ∀ y, ‖y - x0‖ ≤ r → T.winner f y = c
```

This theorem is the clean quantitative certificate:
\[
r^\*(x_0)\ \ge\ \min_{v \in P(x_0)} \frac{m_v(x_0)}{2L_v}.
\]
If `Finset` is easier than `List`, use a finite set of path nodes and `sInf`/`Finset.inf'`.

A useful uniform-Lipschitz corollary should also be proved:

```lean
theorem bracket_winner_const_of_uniform_margin
    {α : Type} [DecidableEq α] [LinearOrder α]
    {d : ℕ}
    (T : Bracket α)
    (f : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r Kdiff : ℝ)
    (hr : 0 ≤ r)
    (hK : 0 ≤ Kdiff)
    (hLip : ∀ a b x y,
      |(f a x - f b x) - (f a y - f b y)| ≤ Kdiff * ‖x - y‖)
    (hmargin :
      ∀ v ∈ T.winnerPath f x0,
        2 * Kdiff * r < f (v.winLabel f x0) x0 - f (v.oppLabel f x0) x0) :
    ∀ y, ‖y - x0‖ ≤ r → T.winner f y = T.winner f x0
```

This is the practically usable version for tropical / ReLU networks when all score differences share a common Lipschitz bound.

### Third theorem: composition with 1-Lipschitz monotone aggregators

To connect with tropical and hierarchical architectures, prove a more structural theorem where leaves need not be raw class scores, but outputs of recursively composed aggregators. Use a node evaluator
```lean
g : ℝ → ℝ → ℝ
```
or more generally two subtree summaries followed by a comparison map, under assumptions:
- monotone in each argument,
- 1-Lipschitz with respect to `max`-norm or `ℓ∞`,
- comparison depends only on a score gap whose Lipschitz constant is controlled by child constants.

A reasonable theorem statement is:

```lean
theorem bracket_certified_of_mono_oneLip
    {α : Type} [DecidableEq α] [LinearOrder α]
    {d : ℕ}
    (T : Bracket α)
    (base : α → (Fin d → ℝ) → ℝ)
    (x0 : Fin d → ℝ)
    (r : ℝ)
    (hr : 0 ≤ r)
    (hbase : ∀ a b x y,
      |(base a x - base b x) - (base a y - base b y)| ≤ K * ‖x - y‖)
    (hmargin : ... winner-path stagewise margins > 2 * K * r ...) :
    ∀ y, ‖y - x0‖ ≤ r →
      T.winner base y = T.winner base x0
```

If the full aggregator generality becomes technically heavy, it is completely acceptable to formalize first the pure tournament-on-label-scores case, then derive a theorem saying any subtree summary built from monotone 1-Lipschitz operators inherits the needed Lipschitz bound. The important mathematical point is compositionality: robustness of the whole bracket should reduce to robustness of the finitely many winner-path comparisons.

### Proof strategy

1. **Stability of one comparison from a gap bound.**  
   First prove the elementary comparison lemma:
   ```lean
   lemma same_order_of_gap_gt_twice
       {u v : (Fin d → ℝ) → ℝ} {x0 y : Fin d → ℝ}
       {L r : ℝ}
       (hy : ‖y - x0‖ ≤ r)
       (hL : 0 ≤ L)
       (hLip : |((u y - v y) - (u x0 - v x0))| ≤ L * ‖y - x0‖)
       (hgap : 2 * L * r < u x0 - v x0) :
       u y > v y
   ```
   The proof is the standard perturbation estimate:
   \[
   (u(y)-v(y)) \ge (u(x_0)-v(x_0)) - L\|y-x_0\| \ge (u(x_0)-v(x_0)) - Lr > Lr \ge 0.
   \]
   In fact the factor `2` comes from allowing both winner and opponent scores to drift by `Lr` if your available theorem is on individual Lipschitz constants rather than directly on the difference. If you already assume `hLip` for the difference itself, you can sharpen the constant to `L*r < margin`; then deduce the `2Lr` version as a convenient corollary. It is worth proving both variants.

2. **Recursive stabilization of subtree winners.**  
   Prove by induction on `T` a theorem of the form:
   - leaves are trivial;
   - at `node l r`, use IH to show the relevant child winners remain fixed on the ball;
   - once those child winners are fixed to labels `a` and `b`, apply the comparison lemma to preserve the parent decision.
   
   The subtle point is that to compare at the parent for all `y`, you need the labels being compared at `y` to be the same labels `a,b` chosen at `x0`. So the induction hypothesis must first freeze child winners before the parent comparison is applied. This is exactly why the theorem should be proved recursively from the bottom up.

3. **Extracting the winner path only.**  
   Show that one does not need margins at every internal node, only along the chain traversed by the champion at `x0`. Nodes in the losing sibling subtrees need only enough stability to keep their own local winner fixed if they are referenced at a parent comparison. If your recursive certificate already ensures that, prove a separate lemma that pathwise margin assumptions imply the recursive certificate. This is the conceptual heart: tournament robustness is sparse.

4. **Radius from finite minima.**  
   After the invariance theorem on a fixed radius `r`, define the pathwise certified radius as the minimum of the local ratios `margin / (2L)`. Then prove any `r` strictly below that minimum is valid. The finite minimum step will likely need a nonempty path object and a lemma that `r < inf' s φ` implies `r < φ a` for every `a ∈ s`.

5. **Uniform-Lipschitz and network corollaries.**  
   Package the theorem with a global constant `Kdiff`, then connect it to known piecewise-linear / tropical network Lipschitz bounds. If previous files give classwise Lipschitz constants `Ki` rather than difference constants, derive
   \[
   |(f_a-f_b)(x)-(f_a-f_b)(y)| \le (K_a+K_b)\|x-y\|
   \]
   and use `L a b := K a + K b`. This gives an immediately deployable corollary for existing multiclass score maps.

### Key intermediate lemmas worth proving explicitly

```lean
lemma abs_sub_sub_le_of_le_diffLip
    {A B : ℝ} :
    |A - B| ≤ C → B ≥ A - C
```
or just use `linarith` after rewriting.

```lean
lemma score_gap_positive_on_ball
    (hLip : |((f a y - f b y) - (f a x0 - f b x0))| ≤ L * ‖y - x0‖)
    (hy : ‖y - x0‖ ≤ r)
    (hgap : L * r < f a x0 - f b x0) :
    0 < f a y - f b y
```

```lean
lemma winner_node_eq_left_of_gap_pos
    (hgap : f a y > f b y) :
    Bracket.winner f (.node (.leaf a) (.leaf b)) y = a
```
and its recursive analogue for arbitrary subtrees with frozen child winners.

```lean
lemma diff_lipschitz_of_individual_lipschitz
    (ha : |f a x - f a y| ≤ Ka * ‖x - y‖)
    (hb : |f b x - f b y| ≤ Kb * ‖x - y‖) :
    |(f a x - f b x) - (f a y - f b y)| ≤ (Ka + Kb) * ‖x - y‖
```

These lemmas should let the main theorem be mostly `calc` / `linarith` / induction rather than ad hoc case explosions.

### Suggested concrete Lean organization

A practical file structure is:
1. definitions of `Bracket`, `winner`;
2. recursive certificate predicate;
3. one-step comparison stability lemmas;
4. induction theorem `recursiveMarginCert → winner constant on ball`;
5. pathwise corollary;
6. certified-radius corollary;
7. uniform `Kdiff` corollary;
8. optional bridge from individual score Lipschitz constants.

Use `ℝ`-valued radii and norms, and `Fin d → ℝ` as input space unless an existing normed-space API in your development makes `EuclideanSpace ℝ (Fin d)` easier.

### Significance for the program

This theorem extends certified robustness beyond flat multiclass semantics to a genuinely hierarchical decision rule. The certification condition becomes structurally sharper: instead of needing all class-vs-class margins or top-k separation, it suffices to control the few comparisons actually traversed by the champion in the bracket. That opens a new branch of the tropical robustness program:
- robustness certificates for elimination-tree classifiers,
- hierarchical multiclass verification with logarithmically many active comparisons,
- compositional certification for piecewise-linear architectures whose decision semantics is not `argmax`.

A successful formalization here should make it natural to later study optimized bracket design, adaptive elimination schemes, and tropical hierarchical networks with certified robustness inherited by structural induction.

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
