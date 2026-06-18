## Research Task: Tropical certified robustness for multiclass piecewise-linear residual networks under DAG-aggregated decision rules via pathwise pairwise logit-gap margins

Research Mode: PROVE

Work in a concrete finite-dimensional setting over `ℝ`. A good base model is:
- input space `ι → ℝ` with `[Fintype ι]`
- class set `Fin C` with `C : ℕ`, `0 < C`
- score map `f : (ι → ℝ) → Fin C → ℝ`
- perturbation measured in `‖·‖∞` on functions `ι → ℝ`

The target is a genuinely new robustness theorem for decision procedures represented by a finite rooted DAG whose internal nodes are built from monotone `1`-Lipschitz tropical primitives (`max`, `min`, and score-difference comparisons / selection rules). The theorem should strictly subsume both:
1. the one-vs-all argmax certificate from a global top-vs-runner-up margin, and
2. the sequential-elimination / tournament certificate from stagewise pairwise margins.

### Precise formal objects to introduce

Define a finite rooted DAG by giving:
- a finite type `V` of nodes with `[Fintype V] [DecidableEq V]`
- a distinguished root `root : V`
- a predecessor relation `edge : V → V → Prop`
- acyclicity encoded by a rank `rank : V → ℕ` with
  ```lean
  ∀ {u v : V}, edge u v → rank v < rank u
  ```
  so edges point from parent to child and every recursive proof can proceed by decreasing `rank`.

At each node, define a real-valued “robustness signal” evaluated at an input `x`. The intended semantics is:
- leaves compute primitive margins such as `f x i - f x j`
- internal nodes aggregate child certificates by `min` / `max` / affine monotone forms
- the root being strictly positive implies invariance of the final DAG decision

A practical Lean encoding is to define a recursive certificate function from leaf values:
```lean
def NodeVal (leafVal : V → ℝ) : V → ℝ
```
with hypotheses ensuring that for each internal node `u`, `NodeVal leafVal u` is obtained from its children by a monotone `1`-Lipschitz operator.

For the first main theorem, it is enough to specialize to the min-over-paths semantics, since this already captures the pathwise bottleneck margin:
```lean
def PathMargin (P : List V) (m : V → ℝ) : ℝ := P.foldr (fun v acc => min (m v) acc) (0 : ℝ)
```
or better, use a finite set / list formulation with a nonempty path and define the bottleneck as the infimum / minimum over nodes in the path.

Define path sensitivity weights:
```lean
def PathWeight (w : V → ℝ) (P : List V) : ℝ := P.foldr (fun v acc => w v * acc) 1
```
or, if the internal aggregators are all `1`-Lipschitz and the only nontrivial sensitivity comes from the score map, simply take a global weight `K : ℝ` and later derive the path-weighted version as a strengthening.

### Main theorem: pathwise bottleneck certificate for DAG robustness

A clean first theorem should be stated for a recursive node certificate `cert : (ι → ℝ) → V → ℝ` satisfying:
- each leaf certificate is a score-gap, hence `2*K`-Lipschitz in the input if each logit is `K`-Lipschitz in `‖·‖∞`
- each internal node is built from monotone `1`-Lipschitz tropical operations, so perturbation cannot increase by more than the maximum perturbation of children
- positivity of the root certificate implies invariance of the DAG decision

A useful precise theorem signature is:

```lean
theorem dag_root_certificate_of_leaf_gap
    {ι V : Type*} [Fintype ι] [Fintype V] [DecidableEq V]
    (f : (ι → ℝ) → V → ℝ)
    (root : V)
    (children : V → Finset V)
    (rank : V → ℕ)
    (cert : (V → ℝ) → V → ℝ)
    (x δ : ι → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K)
    (hε : 0 ≤ ε)
    (hδ : ‖δ‖ ≤ ε)
    (hacyclic : ∀ {u v}, v ∈ children u → rank v < rank u)
    (hmono_lip :
      ∀ g h : V → ℝ, ∀ u,
        |cert g u - cert h u| ≤
          (Finset.sup (children u) fun v => |g v - h v|))
    (hleaf :
      ∀ u, children u = ∅ →
        |cert (fun v => f x v) u - cert (fun v => f (x + δ) v) u| ≤ 2 * K * ε)
    (hroot_pos :
      2 * K * ε < cert (fun v => f x v) root) :
    0 < cert (fun v => f (x + δ) v) root
```

This exact signature may need adjustment because `‖δ‖` on function spaces can be awkward unless you instantiate a normed structure on `ι → ℝ`. If easier in Lean, replace `hδ : ‖δ‖ ≤ ε` by the coordinatewise bound
```lean
(hδ : ∀ i, |δ i| ≤ ε)
```
and define `x + δ` pointwise. Then separately prove the standard estimate that a `K`-Lipschitz score map in `L∞` changes by at most `K * ε`.

A more directly useful theorem for the stated research goal is the pathwise version:

```lean
theorem dag_decision_invariant_of_pathwise_margins
    {ι V : Type*} [Fintype ι] [Fintype V] [DecidableEq V]
    (f : (ι → ℝ) → ℝ)
    (root : V)
    (IsLeaf : V → Prop)
    (children : V → Finset V)
    (rank : V → ℕ)
    (margin weight : V → ℝ)
    (x : ι → ℝ)
    (K ε : ℝ)
    (Paths : Finset (List V))
    (hK : 0 ≤ K)
    (hε : 0 ≤ ε)
    (hacyclic : ∀ {u v}, v ∈ children u → rank v < rank u)
    (hpath_root :
      ∀ P ∈ Paths, P ≠ [] ∧ P.head? = some root)
    (hpath_complete :
      ∀ v, v = root ∨ ∃ P ∈ Paths, v ∈ P)
    (hweight_nonneg : ∀ v, 0 ≤ weight v)
    (hmargin_bound :
      ∀ P ∈ Paths,
        2 * K * ε * PathWeight weight P <
          P.foldr (fun v acc => min (margin v) acc) (margin root))
    :
    True
```

The conclusion `True` is of course only a placeholder for the actual invariance statement; replace it with a concrete decision predicate:
```lean
DecisionStable ε x
```
or
```lean
∀ x', (∀ i, |x' i - x i| ≤ ε) → decideDAG x' = decideDAG x
```
You should define a concrete `decideDAG : (ι → ℝ) → Fin C` or a Boolean winner predicate propagated through the DAG.

The mathematically strongest and most usable final form is:

```lean
theorem decision_invariant_on_ball_of_pathwise_gap
    {ι C V : Type*} [Fintype ι] [Fintype V] [DecidableEq V] [Fintype C] [DecidableEq C]
    (score : (ι → ℝ) → C → ℝ)
    (decide : ((C → ℝ)) → C)
    (dagCert : (C → ℝ) → V → ℝ)
    (root : V)
    (paths : Finset (List V))
    (leafGap : V → (C → ℝ) → ℝ)
    (W : List V → ℝ)
    (x : ι → ℝ)
    (K ε : ℝ)
    (hK : 0 ≤ K)
    (hε : 0 ≤ ε)
    (hscore_lip :
      ∀ z z' : ι → ℝ,
        (∀ i, |z i - z' i| ≤ ε) →
        ∀ c, |score z c - score z' c| ≤ K * ε)
    (hleaf_gap :
      ∀ v s s', IsLeaf v →
        (∀ c, |s c - s' c| ≤ K * ε) →
        |leafGap v s - leafGap v s'| ≤ 2 * K * ε)
    (hdag_stable :
      ∀ s s',
        (∀ v, |dagCert s v - dagCert s' v| ≤ 2 * K * ε) →
        |dagCert s root - dagCert s' root| ≤ 2 * K * ε)
    (hpositive_implies_decision :
      ∀ s s', 0 < dagCert s root → 0 < dagCert s' root → decide s = decide s')
    (hpathwise :
      ∀ P ∈ paths, 2 * K * ε * W P < pathBottleneck (dagCert (score x)) P) :
    ∀ z : ι → ℝ, (∀ i, |z i - x i| ≤ ε) → decide (score z) = decide (score x)
```

This theorem should be sharpened so that the root certificate positivity is deduced from the pathwise bottleneck hypothesis:
```lean
inf_{P ∈ paths} (pathBottleneck P / W P) > 2 * K * ε
```
In Lean, avoid division if possible; use the multiplication form
```lean
∀ P ∈ paths, 2 * K * ε * W P < pathBottleneck ...
```
with `0 ≤ W P`.

### Concrete proof strategy

1. **Leaf perturbation bound from pairwise logit gaps.**  
   Prove a reusable lemma:
   ```lean
   theorem pairwise_gap_variation_le
       {ι C : Type*} [Fintype ι] [Fintype C]
       (score : (ι → ℝ) → C → ℝ)
       (K ε : ℝ)
       (x z : ι → ℝ)
       (i j : C)
       (hK : 0 ≤ K)
       (hε : 0 ≤ ε)
       (hLip :
         ∀ c, |score z c - score x c| ≤ K * ε) :
       |((score z i - score z j) - (score x i - score x j))| ≤ 2 * K * ε
   ```
   This is the basic reason the threshold is `2*K*ε`: each of the two logits may drift by at most `K*ε`. Use
   `abs_sub_le_iff` / triangle inequality / `ring_nf`.

2. **Monotone tropical aggregators preserve perturbation size.**  
   Prove nodewise Lipschitz lemmas for the tropical primitives:
   ```lean
   theorem max_stability :
     |max a b - max a' b'| ≤ max |a - a'| |b - b'|

   theorem min_stability :
     |min a b - min a' b'| ≤ max |a - a'| |b - b'|
   ```
   and analogous lemmas for selectors/comparators if needed. These are the crucial compositional steps. If there are already log-sum-exp / tropical max lemmas in the library, use them as inspiration, but here the needed result is a nonexpansiveness estimate in `L∞`. Then recursively prove:
   ```lean
   |cert s u - cert s' u| ≤ sup_child_error
   ```
   by induction on `rank u`.

3. **Pathwise bottleneck positivity implies root positivity after perturbation.**  
   Define the bottleneck along a path as the minimum leaf/node margin on that path. Show that if every primitive margin on a path decreases by at most `Δ(P)`, then the path bottleneck decreases by at most `Δ(P)`. Since the root is an aggregator of path certificates, monotonicity gives
   ```lean
   cert_z root ≥ cert_x root - 2*K*ε*W(P)
   ```
   on each path, hence positivity under the strict hypothesis
   ```lean
   2*K*ε*W(P) < pathBottleneck_x P.
   ```
   Then take the infimum / minimum over paths.

4. **Convert root positivity to decision invariance.**  
   Formalize a decision correctness lemma saying the DAG decoder output is determined by the sign pattern of the relevant comparison certificates, and in particular by positivity of the root robustness certificate:
   ```lean
   theorem root_positive_implies_same_decision ...
   ```
   This is where you encode the semantics of the DAG. For the first pass, you may choose a simpler decision object, e.g. a distinguished winner `c⋆ : C` together with a root certificate meaning “all comparisons needed to certify `c⋆` are positive.” Then show positivity persists throughout the perturbation ball.

5. **Recover the important corollaries.**
   - **One-vs-all argmax**: choose the DAG whose root is the minimum over all pairwise gaps `score x y - score x j` for a fixed predicted class `y`. Then the path set has one edge per competitor, weight `1`, and the theorem reduces to:
     ```lean
     (∀ j ≠ y, 2 * K * ε < score x y - score x j) →
     ∀ z, (∀ i, |z i - x i| ≤ ε) → argmax score z = y
     ```
     In finite form, use the global runner-up gap
     ```lean
     score x y - Finset.sup (univ.erase y) (score x)
     ```
     if convenient.
   - **Sequential elimination / tournament**: model each stage as one pairwise comparison node. The root certificate becomes the minimum stage margin. Then robustness follows from the minimum stagewise margin exceeding `2*K*ε` (or the weighted version if stages have different local sensitivities).

### Suggested intermediate theorem statements

These are likely to be the most reusable pieces in Lean:

```lean
theorem abs_sub_abs_pairwise_gap_le
    (a b a' b' : ℝ) :
    |((a - b) - (a' - b'))| ≤ |a - a'| + |b - b'|
```

```lean
theorem pairwise_gap_perturbation_le_two_mul
    {ι C : Type*} [Fintype ι] [Fintype C]
    (score : (ι → ℝ) → C → ℝ)
    (x z : ι → ℝ) (i j : C) (K ε : ℝ)
    (hLip : ∀ c, |score z c - score x c| ≤ K * ε) :
    |((score z i - score z j) - (score x i - score x j))| ≤ 2 * K * ε
```

```lean
theorem min_list_stability
    (L L' : List ℝ)
    (hneq : L ≠ [])
    (hlen : L.length = L'.length)
    (herr : ∀ n hn hn', |L.get ⟨n, hn⟩ - L'.get ⟨n, hn'⟩| ≤ Δ) :
    |L.foldr min (L.head hneq) - L'.foldr min (L'.head (by ...))| ≤ Δ
```
If this list theorem is awkward, switch to `Fin n → ℝ` and use `iInf`/`Finset.inf'`, which is often cleaner in Lean.

```lean
theorem finset_inf'_stability
    {α : Type*} [DecidableEq α]
    (s : Finset α) (hs : s.Nonempty)
    (g h : α → ℝ) (Δ : ℝ)
    (herr : ∀ a ∈ s, |g a - h a| ≤ Δ) :
    |s.inf' hs g - s.inf' hs h| ≤ Δ
```
This is an excellent lemma because the root certificate for both one-vs-all and stagewise elimination is naturally a `Finset.inf'` of margins.

```lean
theorem positive_inf'_of_pointwise_lower_bound
    {α : Type*} [DecidableEq α]
    (s : Finset α) (hs : s.Nonempty)
    (g : α → ℝ)
    (γ : ℝ)
    (hγ : 0 < γ)
    (hg : ∀ a ∈ s, γ ≤ g a) :
    0 < s.inf' hs g
```

```lean
theorem one_vs_all_robust_of_margin
    {ι C : Type*} [Fintype ι] [Fintype C] [DecidableEq C]
    (score : (ι → ℝ) → C → ℝ)
    (x : ι → ℝ) (y : C) (K ε : ℝ)
    (hC : Fintype.card C ≥ 2)
    (hLip : ∀ z, (∀ i, |z i - x i| ≤ ε) → ∀ c, |score z c - score x c| ≤ K * ε)
    (hmargin : ∀ j, j ≠ y → 2 * K * ε < score x y - score x j) :
    ∀ z, (∀ i, |z i - x i| ≤ ε) → ∀ j, j ≠ y → score z y > score z j
```

```lean
theorem sequential_elimination_robust_of_stagewise_margins
    {ι C S : Type*} [Fintype ι] [Fintype S]
    (stageGap : S → (ι → ℝ) → ℝ)
    (x : ι → ℝ) (K ε : ℝ)
    (hLip : ∀ s z, (∀ i, |z i - x i| ≤ ε) →
      |stageGap s z - stageGap s x| ≤ 2 * K * ε)
    (hmargin : ∀ s, 2 * K * ε < stageGap s x) :
    ∀ z, (∀ i, |z i - x i| ≤ ε) → ∀ s, 0 < stageGap s z
```

### Significance to the research program

This theorem is the right abstraction layer for the tropical robustness line of work. The completed one-vs-all and sequential/tournament results are special cases of “decision certificates built from monotone `1`-Lipschitz tropical comparison circuits.” Formalizing the DAG theorem will:
- unify existing multiclass robustness certificates under one compositional principle,
- provide a reusable library of nonexpansiveness lemmas for tropical decision circuits,
- create the exact infrastructure needed for forthcoming plurality-of-experts and ECOC decoders, where the decoder is neither pure argmax nor a linear chain,
- make residual-network robustness statements modular: the network contributes a score-gap Lipschitz constant, while the decoder contributes only monotonicity and tropical nonexpansiveness.

The key new mathematical content is not merely that margins imply robustness, but that **pathwise bottleneck margins in an arbitrary acyclic tropical decision graph compose correctly with pairwise logit-gap perturbation bounds**. This is the precise finite combinatorial principle needed to scale certified robustness beyond flat argmax and simple tournaments.

### File target

`MachineLearning/Neural/TropicalDAGRobustness.lean`

A good implementation plan is:
1. first prove the real-analysis lemmas for pairwise gap perturbation and `min`/`max` stability;
2. then prove a generic `Finset.inf'` stability theorem;
3. then define a simple DAG/root certificate model via rank recursion;
4. finally derive the two corollaries: one-vs-all and sequential elimination.

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
