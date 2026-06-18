## Research Task: GL3 tropical Satake certified robustness for top-cycle (Smith-set) Hecke-score classifiers via pairwise margin domination

Research Mode: PROVE

Work in a new file
`Bridges/GL3TopCycleRobustness.lean`.

The goal is to formalize a genuinely nontrivial multiclass robustness theorem for a tournament-valued classifier built from GL3 tropical Hecke scores. The key point is to avoid any dependence on additive score aggregation rules: the prediction is defined from the pairwise comparison tournament, and robustness is deduced from preservation of all edges adjacent to a uniformly dominant class. This is the natural “Condorcet/top-cycle” analogue of the already verified binary certified radius `margin / (2*K*d)`.

### Core definitions to introduce

Use a finite label type; for the first pass it is acceptable to specialize to `Fin 3`, but a more reusable development should parametrize by `[Fintype α] [DecidableEq α]`.

A clean setup is:

```lean
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Fintype.Basic
import Mathlib.Algebra.BigOperators.Basic

open scoped BigOperators

def PairwisePref {α : Type*} [DecidableEq α]
    (score : α → ℝ) (i j : α) : Prop :=
  score j < score i

def CondorcetWinner {α : Type*} [Fintype α] [DecidableEq α]
    (score : α → ℝ) (c : α) : Prop :=
  ∀ j, j ≠ c → score j < score c

def IsSmithSingleton {α : Type*} [Fintype α] [DecidableEq α]
    (score : α → ℝ) (c : α) : Prop :=
  CondorcetWinner score c
```

The last definition is deliberately minimal: for tournaments, a Condorcet winner is exactly a singleton Smith set, so this is the right theorem-level interface even if you later add a more intrinsic `SmithSet` definition.

For the score geometry, assume a per-class score family `s : α → (Fin d → ℝ) → ℝ` and a coordinatewise `K`-Lipschitz bound strong enough to imply the standard `K*d*‖δ‖∞` estimate:

```lean
def CoordwiseLipschitz {α : Type*} (d : ℕ)
    (s : α → (Fin d → ℝ) → ℝ) (K : ℝ) : Prop :=
  ∀ i x y, |s i x - s i y| ≤ K * ∑ k : Fin d, |x k - y k|
```

and an `L∞` perturbation hypothesis

```lean
def LinftyBall {d : ℕ} (r : ℝ) (δ : Fin d → ℝ) : Prop :=
  ∀ k, |δ k| ≤ r
```

You will likely want the standard finite-dimensional estimate

```lean
lemma sum_abs_le_d_mul_r {d : ℕ} (δ : Fin d → ℝ) (r : ℝ)
    (hδ : LinftyBall r δ) :
    ∑ k : Fin d, |δ k| ≤ d * r
```

with the right coercions to `ℝ`, probably as `((d : ℕ) : ℝ) * r`.

Then define the pairwise margin:

```lean
def pairMargin {α : Type*} (s : α → β → ℝ) (x : β) (i j : α) : ℝ :=
  s i x - s j x
```

### Main theorem statements to target

The first theorem should be the clean certified robustness statement for a Condorcet/Smith-singleton winner under uniform pairwise domination.

```lean
theorem condorcet_robust_of_uniform_margin
    {α : Type*} [Fintype α] [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (c : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ j, j ≠ c → 2 * K * (d : ℝ) * r < s c x - s j x) :
    CondorcetWinner (fun i => s i (fun k => x k + δ k)) c
```

A more explicit pairwise version is useful as an intermediate lemma:

```lean
theorem pairwise_orientation_preserved_of_margin
    {α : Type*} [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (i j : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : 2 * K * (d : ℝ) * r < s i x - s j x) :
    s j (fun k => x k + δ k) < s i (fun k => x k + δ k)
```

Then package the singleton Smith-set conclusion:

```lean
theorem smith_singleton_robust_of_uniform_margin
    {α : Type*} [Fintype α] [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (c : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ j, j ≠ c → 2 * K * (d : ℝ) * r < s c x - s j x) :
    IsSmithSingleton (fun i => s i (fun k => x k + δ k)) c
```

For a GL3-facing specialization, add:

```lean
theorem gl3_top_cycle_robustness
    {d : ℕ}
    (s : Fin 3 → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (c : Fin 3) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ j, j ≠ c → 2 * K * (d : ℝ) * r < s c x - s j x) :
    IsSmithSingleton (fun i => s i (fun k => x k + δ k)) c
```

This theorem is mathematically the same as the general one, but having the `Fin 3` specialization makes the bridge to GL3 tropical Satake classifiers explicit.

### Stronger “dominance cut invariance” theorem

Beyond preserving a single winner, prove a theorem that preserves an entire dominance cut. Let `S : Finset α` and assume every `i ∈ S` beats every `j ∉ S` by margin `> 2*K*d*r`. Then after perturbation, every such cross-edge is preserved. This is the correct tournament-theoretic invariant behind top-cycle stability.

A precise theorem is:

```lean
theorem dominance_cut_preserved
    {α : Type*} [Fintype α] [DecidableEq α]
    {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (S : Finset α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ)
    (hmargin : ∀ i, i ∈ S → ∀ j, j ∉ S → 2 * K * (d : ℝ) * r < s i x - s j x) :
    ∀ i, i ∈ S → ∀ j, j ∉ S → s j (fun k => x k + δ k) < s i (fun k => x k + δ k)
```

If you define a top cycle as the minimal dominant set, this lemma should imply that whenever `S` is the unique dominant set at `x` with a strict cross-margin gap, the same cut remains dominant after perturbation. Even if the full minimality formalization is deferred, this theorem is already a substantial and reusable structural result.

### Proof strategy

1. **Prove the basic `L∞ → ℓ¹` estimate on `Fin d`.**  
   Show
   ```lean
   ∑ k : Fin d, |δ k| ≤ (d : ℝ) * r
   ```
   from `∀ k, |δ k| ≤ r` and `0 ≤ r`. This is a finite-sum bound by comparing each term with `r` and summing. In Lean, `Finset.sum_le_sum` over `Finset.univ` is the natural route.

2. **Derive a perturbation bound for each class score.**  
   From `CoordwiseLipschitz`, obtain
   ```lean
   |s i (x+δ) - s i x| ≤ K * (d : ℝ) * r
   ```
   where `x+δ := fun k => x k + δ k`. This is just the Lipschitz hypothesis plus the previous sum bound, followed by ring rearrangement. Keep this as a standalone lemma:
   ```lean
   theorem score_shift_le
   ```
   since it will be used twice in the pairwise margin estimate.

3. **Control pairwise margins by the triangle inequality.**  
   Show
   ```lean
   (s i (x+δ) - s j (x+δ)) ≥ (s i x - s j x) - 2 * K * (d : ℝ) * r
   ```
   by writing
   ```lean
   s i (x+δ) - s j (x+δ)
   = (s i x - s j x) + (s i (x+δ) - s i x) - (s j (x+δ) - s j x)
   ```
   and bounding the two error terms individually by `K*d*r`. This is the key quantitative lemma; once established, the strict positivity conclusion is immediate from `hmargin`.

4. **Upgrade preserved pairwise edges to Condorcet/Smith-singleton stability.**  
   If `c` beats every `j ≠ c` after perturbation, then `c` is a Condorcet winner by definition. In any finite tournament, a Condorcet winner is the unique element of the Smith set/top cycle. If you do not yet formalize the full Smith set, state this equivalence as your interface theorem via `IsSmithSingleton := CondorcetWinner`. If you do formalize Smith sets, the proof should be short: any dominant set must contain the Condorcet winner, and `{c}` itself is dominant.

5. **Generalize from a singleton winner to a preserved dominance cut.**  
   Repeat the pairwise argument uniformly for all `i ∈ S`, `j ∉ S`. This yields invariance of the cross-edge relation `S ≻ α \ S`, which is exactly the tournament-cut structure needed for top-cycle arguments. This theorem is the mathematically stronger contribution and should be emphasized.

### Useful intermediate lemmas to state explicitly

These will make the development modular and reduce proof friction:

```lean
lemma linfty_to_l1_bound
    {d : ℕ} (δ : Fin d → ℝ) (r : ℝ)
    (hr : 0 ≤ r) (hδ : LinftyBall r δ) :
    ∑ k : Fin d, |δ k| ≤ (d : ℝ) * r
```

```lean
lemma score_perturbation_bound
    {α : Type*} {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (i : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K) (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ) :
    |s i (fun k => x k + δ k) - s i x| ≤ K * (d : ℝ) * r
```

```lean
lemma pair_margin_lower_bound_under_perturbation
    {α : Type*} {d : ℕ}
    (s : α → (Fin d → ℝ) → ℝ)
    (K r : ℝ) (i j : α) (x δ : Fin d → ℝ)
    (hK : 0 ≤ K) (hr : 0 ≤ r)
    (hLip : CoordwiseLipschitz d s K)
    (hδ : LinftyBall r δ) :
    s i (fun k => x k + δ k) - s j (fun k => x k + δ k)
      ≥ (s i x - s j x) - 2 * K * (d : ℝ) * r
```

Then `pairwise_orientation_preserved_of_margin` should be a one-line corollary via `lt_of_lt_of_le`/`sub_pos.mp`.

### Mathematical significance

This result is important because it moves certified robustness for tropical Hecke classifiers from score-maximization rules to a genuinely tournament-based decision rule. The top cycle/Smith set is strictly more structural than Borda-style or one-vs-rest aggregation: it depends only on pairwise comparisons and is invariant under monotone score transformations. Proving that a uniform tropical pairwise margin certifies top-cycle stability shows that the same `margin / (2*K*d)` geometry controlling binary decisions also governs a nontrivial social-choice solution concept on multiclass GL3 score tournaments.

The stronger dominance-cut theorem is the real bridge theorem. It identifies the exact robust combinatorial object preserved by tropical score margins: not merely the winner label, but the dominant cut structure of the tournament. This is the right stepping stone toward future work on full tropical Satake tournament classifiers, Kemeny-style rules, and higher-rank Hecke score aggregation, where robustness should be expressed in terms of preserved comparison complexes rather than only preserved argmax labels.

Aim to leave behind a clean reusable API: perturbation bounds for score differences, edge-preservation lemmas for tournaments, and a final GL3 specialization showing that strict pairwise domination implies certified top-cycle robustness with radius determined by the minimum pairwise margin divided by `2*K*d`.

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
