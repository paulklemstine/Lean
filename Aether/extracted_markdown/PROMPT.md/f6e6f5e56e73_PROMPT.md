## Research Task: GL3 tropical Satake Lipschitz stability theorem for Hecke score classifiers under score perturbations

Research Mode: PROVE

Work in a new file
`Bridges/GL3TropicalSatakeScoreStability.lean`.

The goal is to isolate a reusable perturbation-transfer principle for 3-class score vectors, then instantiate it for the existing GL3 tropical Satake Hecke score constructions. The key point is that the current margin theorems certify decisions for a single score map, but what we now need is a bridge theorem: any approximation / quantization / pruning / reconstruction pipeline that controls the sup-norm error of the score vector automatically inherits certified invariance of top-1, top-2, and pairwise decisions.

This should be formulated at the level of arbitrary `X → Fin 3 → ℝ` score maps first, and only afterward specialized to the GL3 tropical Satake setting. The resulting theorem family should be architecture-agnostic and reusable by later files on robust tropical classifiers.

### Core setup

Use score maps of type
```lean
def Score3 (X : Type _) := X → Fin 3 → ℝ
```

For perturbation size, use the pointwise sup bound
```lean
def ScoreSupClose {X : Type _} (f g : Score3 X) (ε : ℝ) : Prop :=
  ∀ x i, |f x i - g x i| ≤ ε
```

For pairwise margins:
```lean
def pairMargin {X : Type _} (f : Score3 X) (x : X) (i j : Fin 3) : ℝ :=
  f x i - f x j
```

For top-1 winner, define a strict winner predicate rather than choosing an `argmax` globally. This avoids unnecessary finite-choice complications and makes the stability theorem cleaner:
```lean
def IsTop1Winner {X : Type _} (f : Score3 X) (x : X) (i : Fin 3) : Prop :=
  ∀ j, j ≠ i → f x j < f x i
```

For top-2 membership, use the “beats at least one competitor” characterization, which in `Fin 3` is equivalent to being in the top two:
```lean
def InTop2 {X : Type _} (f : Score3 X) (x : X) (i : Fin 3) : Prop :=
  ∃ j, j ≠ i ∧ f x j < f x i
```
This is the right formalization because in 3 classes, “not bottom” is equivalent to “top-2,” and strict margin assumptions naturally imply this strict comparison form.

For one-vs-one orientation, define:
```lean
def PairwisePrefers {X : Type _} (f : Score3 X) (x : X) (i j : Fin 3) : Prop :=
  f x i > f x j
```

You may also want a “uniform decisive pairwise margin” predicate:
```lean
def PairwiseMarginGT {X : Type _} (f : Score3 X) (x : X) (δ : ℝ) : Prop :=
  ∀ i j, i ≠ j → f x i > f x j → f x i - f x j > δ
```

### Precise theorem targets

First prove the generic perturbation lemmas for arbitrary 3-score maps.

1. **Pairwise score-difference perturbation bound**
```lean
theorem pairMargin_perturbation_bound
    {X : Type _} {f g : Score3 X} {ε : ℝ}
    (hclose : ScoreSupClose f g ε) :
    ∀ x i j, |pairMargin f x i j - pairMargin g x i j| ≤ 2 * ε
```

A slightly stronger and often easier-to-use directional version is also worth proving:
```lean
theorem pairMargin_perturbation_bound'
    {X : Type _} {f g : Score3 X} {ε : ℝ}
    (hε : 0 ≤ ε) (hclose : ScoreSupClose f g ε) :
    ∀ x i j, pairMargin g x i j ≥ pairMargin f x i j - 2 * ε
```
and symmetrically with `f` and `g` swapped.

2. **Top-1 winner stability from margin**
```lean
theorem top1_stable_of_margin_gt_two_eps
    {X : Type _} {f g : Score3 X} {ε : ℝ} {x : X} {i : Fin 3}
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hmargin : ∀ j, j ≠ i → f x i - f x j > 2 * ε) :
    IsTop1Winner g x i
```

A symmetric equivalence form is even better for downstream use:
```lean
theorem top1_stable_iff_of_margin_gt_two_eps
    {X : Type _} {f g : Score3 X} {ε : ℝ} {x : X} {i : Fin 3}
    (hε : 0 ≤ ε)
    (hfg : ScoreSupClose f g ε)
    (hgf : ScoreSupClose g f ε)
    (hfmargin : ∀ j, j ≠ i → f x i - f x j > 2 * ε) :
    IsTop1Winner f x i ∧ IsTop1Winner g x i
```
though the one-directional statement is the essential one.

3. **Top-2 membership stability**
```lean
theorem top2_stable_of_margin_gt_two_eps
    {X : Type _} {f g : Score3 X} {ε : ℝ} {x : X} {i : Fin 3}
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hmargin : ∃ j, j ≠ i ∧ f x i - f x j > 2 * ε) :
    InTop2 g x i
```

But the real theorem should preserve the actual top-2 set under a gap separating the second and third scores. Since `Fin 3` is tiny, formulate it combinatorially:

```lean
def SameTop2Set {X : Type _} (f g : Score3 X) (x : X) : Prop :=
  ∀ i, InTop2 f x i ↔ InTop2 g x i
```

Then prove:
```lean
theorem top2_set_stable_of_bottom_margin_gt_two_eps
    {X : Type _} {f g : Score3 X} {ε : ℝ} {x : X}
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hbottom :
      ∃ b : Fin 3, ∀ i, i ≠ b → f x i - f x b > 2 * ε) :
    SameTop2Set f g x
```

This is the cleanest strict-gap formulation in `Fin 3`: there is a unique bottom class `b`, and both other classes beat it by margin `> 2ε`. Then perturbation cannot change who is bottom, hence the top-2 set is preserved.

4. **Pairwise one-vs-one stability**
```lean
theorem pairwise_preference_stable_of_margin_gt_two_eps
    {X : Type _} {f g : Score3 X} {ε : ℝ} {x : X} {i j : Fin 3}
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hmargin : f x i - f x j > 2 * ε) :
    PairwisePrefers g x i j
```

Then package the all-pairs version:
```lean
theorem all_pairwise_preferences_stable_of_margin_gt_two_eps
    {X : Type _} {f g : Score3 X} {ε : ℝ} {x : X}
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f g ε)
    (hdec :
      ∀ i j, i ≠ j → f x i > f x j → f x i - f x j > 2 * ε) :
    ∀ i j, i ≠ j → PairwisePrefers f x i j → PairwisePrefers g x i j
```

This is the precise “every decisive pairwise margin exceeds `2ε`” statement.

### GL3 tropical Satake bridge theorem

After the abstract perturbation lemmas are in place, instantiate them with the existing GL3 tropical Satake score map. Use the actual score-map name already present in the development; if the existing API packages scores as a triple or vector rather than `Fin 3 → ℝ`, add a local coercion/adapter:
```lean
def toScore3 (s : /* existing GL3 score object */) : Fin 3 → ℝ := ...
```

Then prove a theorem of the shape:
```lean
theorem gl3_tropical_satake_top1_stability
    {X : Type _}
    (f f' : Score3 X)
    (hf_satake : IsGL3TropicalSatakeScore f)
    (hf'_close : ScoreSupClose f f' ε)
    (hε : 0 ≤ ε)
    {x : X} {i : Fin 3}
    (hmargin : ∀ j, j ≠ i → f x i - f x j > 2 * ε) :
    IsTop1Winner f' x i
```

and analogously for top-2 and pairwise OVO stability. If the existing library already contains a theorem giving certified robustness from score margins in a more general `n`-class setting, explicitly derive the 3-class Satake theorem through that result when possible, but still keep the direct `Fin 3` proofs because they expose the exact perturbation-transfer mechanism and are easier to reuse in later GL3-specific files.

A final bundled bridge theorem would be valuable:
```lean
theorem gl3_tropical_satake_stability_transfer
    {X : Type _} {f f' : Score3 X} {ε : ℝ}
    (hf_satake : IsGL3TropicalSatakeScore f)
    (hε : 0 ≤ ε)
    (hclose : ScoreSupClose f f' ε) :
    ((∀ x i, (∀ j, j ≠ i → f x i - f x j > 2 * ε) → IsTop1Winner f' x i)) ∧
    ((∀ x, (∃ b : Fin 3, ∀ i, i ≠ b → f x i - f x b > 2 * ε) → SameTop2Set f f' x)) ∧
    ((∀ x i j, i ≠ j → f x i - f x j > 2 * ε → PairwisePrefers f' x i j))
```

If `IsGL3TropicalSatakeScore` is not yet formalized, replace it by the actual hypothesis expressing “`f` is one of the existing GL3 tropical Satake Hecke score classifiers” and keep the theorem as an instantiation lemma over that concrete object.

### Proof strategy hints

1. **Start with the algebraic 2ε inequality.**
   Expand
   ```lean
   (f x i - f x j) - (g x i - g x j)
   = (f x i - g x i) - (f x j - g x j)
   ```
   then apply `abs_sub_le_iff`-style reasoning or simply
   `calc ... ≤ |f x i - g x i| + |f x j - g x j| := by ...`
   using `abs_sub_le` / triangle inequality. The bound `≤ 2 * ε` follows from the coordinatewise hypotheses. This is the fundamental lemma from which all stability statements should be deduced.

2. **Derive sign preservation from strict margin.**
   If `f x i - f x j > 2 * ε`, then from the lower-bound form
   ```lean
   g x i - g x j ≥ f x i - f x j - 2 * ε
   ```
   conclude `g x i - g x j > 0`, hence `g x i > g x j`. This is the exact bridge from numerical perturbation control to decision invariance.

3. **For top-1 stability, avoid global sorting.**
   Use the hypothesis
   ```lean
   ∀ j ≠ i, f x i - f x j > 2 * ε
   ```
   and apply pairwise sign preservation separately for each competitor `j`. Then discharge `IsTop1Winner g x i` directly by unfolding the definition.

4. **For top-2 stability in `Fin 3`, characterize the top-2 set by the unique bottom class.**
   The assumption
   ```lean
   ∃ b, ∀ i ≠ b, f x i - f x b > 2 * ε
   ```
   means `b` is strictly below both remaining classes. Perturbation preserves both inequalities, so `b` remains bottom for `g`. Then show
   ```lean
   InTop2 f x i ↔ i ≠ b ↔ InTop2 g x i
   ```
   The only genuinely nontrivial step is the equivalence between `InTop2` and “not bottom” in `Fin 3`; prove this once as a small combinatorial lemma by case analysis on `Fin 3`.

5. **For pairwise OVO stability, keep the theorem directional.**
   Do not overcomplicate it by defining a full majority vote aggregator unless one already exists in the library. The essential reusable fact is preservation of each strict pairwise preference under a `> 2ε` margin. Any future tournament / Condorcet / ECOC machinery can consume this directional theorem.

### Suggested supporting lemmas

These small lemmas will likely simplify the main proofs:

```lean
lemma sub_gt_zero_iff_lt {a b : ℝ} : a - b > 0 ↔ b < a := by linarith
lemma sub_pos_of_gt {a b : ℝ} (h : a > b) : a - b > 0 := by linarith
lemma gt_of_gt_of_ge_sub_two_eps
    {a b ε : ℝ} (h : a - b > 2 * ε) (hε : 0 ≤ ε) :
    a - b - 2 * ε > 0 := by linarith
```

For `Fin 3`, it is worth proving:
```lean
lemma inTop2_iff_not_bottom
    {X : Type _} (f : Score3 X) (x : X) (b : Fin 3)
    (hb : ∀ i, i ≠ b → f x i > f x b) :
    ∀ i, InTop2 f x i ↔ i ≠ b
```
This should be a finite case split on `i` and `b`, using the fact that `Fin 3` has exactly two indices distinct from `b`.

### Significance

This theorem family is the right next step for the GL3 tropical Satake program because it separates representation-theoretic score construction from robustness certification. The existing margin theorems show that a given score map has decisive gaps; the new result shows that any perturbation of that score map with uniform error `≤ ε` preserves all multiclass decisions whose margins exceed `2ε`. This creates a general interface between tropical Satake geometry and robust classification:

- future approximation theorems only need to prove `ScoreSupClose`,
- future margin theorems only need to prove score gaps,
- the present bridge then automatically yields certified invariance.

That modularity is the real novelty. It should make later work on quantized Hecke scores, finite-support truncations, tropical network surrogates, and reconstruction from sparse Satake data much cleaner, because all such developments can target the same perturbation-transfer API rather than reproving classifier-specific robustness lemmas each time.

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
