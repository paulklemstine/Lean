## Research Task: GL3 tropical Satake certified robustness for Kemeny–Young Hecke-score aggregation

Research Mode: PROVE

Work in a new file
`Bridges/GL3KemenyRobustness.lean`.

The goal is to formalize a genuinely new certified-robustness theorem for a 3-class decision rule obtained by:
1. a real-valued score map `h : α → Fin 3 → ℝ`,
2. pairwise margins `mij x := h x i - h x j`,
3. Kemeny–Young aggregation over the `6` permutations of `Fin 3`,
4. the induced top-ranked class of the unique Kemeny-optimal permutation.

The crucial point is that for `3` candidates the Kemeny score of a ranking is an explicit affine linear form in the three pairwise margins
`m01, m02, m12`, so the winner region is cut out by finitely many linear inequalities. This lets you transfer the existing Lipschitz control on the Hecke score vector into a certified robustness radius for the Kemeny winner.

### Precise objects to define

Use `Fin 3` as the label type. It is worth defining the three basic margins explicitly:
```lean
def margin01 (h : α → Fin 3 → ℝ) (x : α) : ℝ := h x 0 - h x 1
def margin02 (h : α → Fin 3 → ℝ) (x : α) : ℝ := h x 0 - h x 2
def margin12 (h : α → Fin 3 → ℝ) (x : α) : ℝ := h x 1 - h x 2
```
or, more invariantly,
```lean
def margin (h : α → Fin 3 → ℝ) (x : α) (i j : Fin 3) : ℝ := h x i - h x j
```
with lemmas specializing to the three unordered pairs.

Represent rankings as lists or tuples of the six permutations of `Fin 3`. Since `Fin 3` is tiny, the cleanest formalization is usually to define the six rankings explicitly and define their Kemeny scores by closed formulas. For example, if a ranking is `0 ≻ 1 ≻ 2`, its Kemeny score is
`m01 + m02 + m12`;
if `0 ≻ 2 ≻ 1`, its score is
`m02 + m01 - m12`;
etc.

Define the six scores:
```lean
def score012 (h : α → Fin 3 → ℝ) (x : α) : ℝ :=
  margin h x 0 1 + margin h x 0 2 + margin h x 1 2

def score021 (h : α → Fin 3 → ℝ) (x : α) : ℝ :=
  margin h x 0 2 + margin h x 0 1 + margin h x 2 1

def score102 (h : α → Fin 3 → ℝ) (x : α) : ℝ :=
  margin h x 1 0 + margin h x 1 2 + margin h x 0 2

def score120 (h : α → Fin 3 → ℝ) (x : α) : ℝ :=
  margin h x 1 2 + margin h x 1 0 + margin h x 2 0

def score201 (h : α → Fin 3 → ℝ) (x : α) : ℝ :=
  margin h x 2 0 + margin h x 2 1 + margin h x 0 1

def score210 (h : α → Fin 3 → ℝ) (x : α) : ℝ :=
  margin h x 2 1 + margin h x 2 0 + margin h x 1 0
```
Then define the Kemeny score attached to a ranking datatype, or simply work with these six named scores directly.

A very useful simplification is to rewrite all six scores in terms of the three basic margins `m01 := margin h x 0 1`, `m02 := margin h x 0 2`, `m12 := margin h x 1 2`:
```lean
score012 =  m01 + m02 + m12
score021 =  m01 + m02 - m12
score102 = -m01 + m02 + m12
score120 = -m01 - m02 + m12
score201 =  m01 - m02 - m12
score210 = -m01 - m02 - m12
```
These identities should be proved once and then used everywhere.

Define the top candidate of each ranking, and define what it means for a class `c : Fin 3` to be the Kemeny winner at `x`: there exists a unique ranking among the six with maximal score, and its top element is `c`.

### Main theorem: explicit Kemeny score stability

A first theorem should isolate the metric estimate at the level of Kemeny scores.

Use a hypothesis of the form:
```lean
∀ i : Fin 3, |h (x + δ) i - h x i| ≤ Kd * ‖δ‖∞
```
or whatever concrete norm/control statement is already available in your GL3 tropical robustness framework. If the existing theorem is stated for `dist` rather than `|·|`, adapt accordingly. The key derived bound is
```lean
|margin h (x + δ) i j - margin h x i j| ≤ 2 * Kd * ‖δ‖∞
```
for all `i j`.

Then prove that each Kemeny permutation score changes by at most `6 * Kd * ‖δ‖∞`, because each score is a sum of three signed margins:
```lean
theorem kemeny_score_perturbation_bound
    {α : Type*}
    [Norm α]
    (h : α → Fin 3 → ℝ)
    (Kd : ℝ)
    (x δ : α)
    (hLip :
      ∀ i : Fin 3, |h (x + δ) i - h x i| ≤ Kd * ‖δ‖) :
    ∀ s : KemenyRanking,
      |kemenyScore h (x + δ) s - kemenyScore h x s| ≤ 6 * Kd * ‖δ‖ := by
```
If your ambient type does not naturally carry `x + δ`, replace by a pair of points `x y : α` and assume `|h y i - h x i| ≤ Kd * dist y x`.

This is the right constant if you only use coordinatewise score control. Do not claim the stronger `2 * Kd * ‖δ‖` score-gap bound unless you have proved an additional combinatorial cancellation lemma. The safe route is:
- each margin perturbs by at most `2Kd‖δ‖`,
- each permutation score is a sum of three such terms,
- so each permutation score perturbs by at most `6Kd‖δ‖`,
- hence the gap between two permutation scores perturbs by at most `12Kd‖δ‖`.

### Main theorem: certified robustness from unique Kemeny gap

Define the Kemeny margin at `x` as the difference between the best and second-best permutation scores. Since there are only six scores, define it concretely:
```lean
def kemenyMargin (h : α → Fin 3 → ℝ) (x : α) : ℝ :=
  sSup {r : ℝ | ∃ s, r = kemenyScore h x s} -
  sSup {r : ℝ | ∃ s, r = kemenyScore h x s ∧
    ∃ t, t ≠ s ∧ kemenyScore h x t ≤ kemenyScore h x s}
```
But for formal tractability, it may be better to define:
```lean
def isUniqueKemenyWinner (h : α → Fin 3 → ℝ) (x : α) (s⋆ : KemenyRanking) : Prop :=
  ∀ t, t ≠ s⋆ → kemenyScore h x t < kemenyScore h x s⋆

def kemenyGap (h : α → Fin 3 → ℝ) (x : α) (s⋆ : KemenyRanking) : ℝ :=
  kemenyScore h x s⋆ - max
    (score over the other five rankings)
```
Because the ranking type is finite of size `6`, defining this gap by explicit `max` of five terms is perfectly acceptable and probably easier in Lean than using `sSup`.

Then prove the robustness theorem:

```lean
theorem unique_kemeny_winner_stable
    {α : Type*}
    [Norm α]
    (h : α → Fin 3 → ℝ)
    (Kd : ℝ)
    (x δ : α)
    (s⋆ : KemenyRanking)
    (hLip :
      ∀ i : Fin 3, |h (x + δ) i - h x i| ≤ Kd * ‖δ‖)
    (huniq : ∀ t, t ≠ s⋆ → kemenyScore h x t < kemenyScore h x s⋆)
    (hgap :
      12 * Kd * ‖δ‖ <
        kemenyScore h x s⋆ - maxOtherKemenyScore h x s⋆) :
    ∀ t, t ≠ s⋆ → kemenyScore h (x + δ) t < kemenyScore h (x + δ) s⋆ := by
```

From this derive the cleaner radius corollary:

```lean
theorem unique_kemeny_winner_certified_radius
    {α : Type*}
    [Norm α]
    (h : α → Fin 3 → ℝ)
    (Kd Δ : ℝ)
    (x δ : α)
    (s⋆ : KemenyRanking)
    (hKd : 0 ≤ Kd)
    (hΔ : 0 < Δ)
    (hLip :
      ∀ i : Fin 3, |h (x + δ) i - h x i| ≤ Kd * ‖δ‖)
    (huniq_gap :
      ∀ t, t ≠ s⋆ → kemenyScore h x s⋆ - kemenyScore h x t ≥ Δ)
    (hrad : ‖δ‖ < Δ / (12 * Kd)) :
    ∀ t, t ≠ s⋆ → kemenyScore h (x + δ) t < kemenyScore h (x + δ) s⋆ := by
```

If you insist on an `L∞` formulation on `ℝ^d`, use:
```lean
theorem unique_kemeny_winner_certified_radius_sup
    (h : (Fin d → ℝ) → Fin 3 → ℝ)
    (K dconst Δ : ℝ)
    (x δ : Fin d → ℝ)
    ...
    (hLip :
      ∀ i : Fin 3, |h (x + δ) i - h x i| ≤ K * dconst * ‖δ‖∞)
    ...
    (hrad : ‖δ‖∞ < Δ / (12 * K * dconst)) :
    ...
```
Only use `‖δ‖∞` if the corresponding norm and previous GL3 theorem are already available in the codebase. Otherwise stay with the ambient norm from existing robustness lemmas.

### Winner-level corollary

The final theorem should speak about the class label, not just the optimal ranking. Define:
```lean
def topClass : KemenyRanking → Fin 3
```
and
```lean
def kemenyWinner (h : α → Fin 3 → ℝ) (x : α) (c : Fin 3) : Prop :=
  ∃ s⋆, topClass s⋆ = c ∧ ∀ t, t ≠ s⋆ → kemenyScore h x t < kemenyScore h x s⋆
```

Then prove:
```lean
theorem kemeny_winner_label_stable
    {α : Type*}
    [Norm α]
    (h : α → Fin 3 → ℝ)
    (Kd Δ : ℝ)
    (x δ : α)
    (c : Fin 3)
    (s⋆ : KemenyRanking)
    (htop : topClass s⋆ = c)
    (hKd : 0 ≤ Kd)
    (hΔ : 0 < Δ)
    (hLip :
      ∀ i : Fin 3, |h (x + δ) i - h x i| ≤ Kd * ‖δ‖)
    (hgap :
      ∀ t, t ≠ s⋆ → kemenyScore h x s⋆ - kemenyScore h x t ≥ Δ)
    (hrad : ‖δ‖ < Δ / (12 * Kd)) :
    kemenyWinner h (x + δ) c := by
```

If you can prove a sharper constant by exploiting the explicit six-score formulas, that is valuable. But do not overstate the radius: with only the generic pairwise-margin perturbation estimate, the robust radius is naturally controlled by `Δ / (12 Kd)` for permutation-score uniqueness. Any stronger denominator such as `2Kd` must come from a separately proved cancellation argument at the level of the particular winner inequalities, not from the raw margin bound alone.

### Concrete proof strategy

1. **Prove margin perturbation bounds from score perturbation bounds.**  
   For each `i j : Fin 3`,
   ```lean
   |(h (x + δ) i - h (x + δ) j) - (h x i - h x j)| ≤ 2 * Kd * ‖δ‖
   ```
   by rewriting and using `abs_sub_le_iff` / triangle inequality:
   ```lean
   ((h (x+δ) i - h x i) - (h (x+δ) j - h x j))
   ```
   Then apply `abs_sub_le`.

2. **Write each Kemeny score as an affine form in `m01, m02, m12`.**  
   Prove explicit simplification lemmas for all six rankings. This is the combinatorial heart that makes the theorem finite and exact. Once these are in place, every later inequality becomes linear arithmetic over `ℝ`.

3. **Bound perturbation of each permutation score and of score gaps.**  
   Since each score is a sum of three signed margins, combine the previous step with three applications of the triangle inequality to get
   ```lean
   |score_s (x+δ) - score_s x| ≤ 6 * Kd * ‖δ‖.
   ```
   Then for any two rankings `s,t`,
   ```lean
   |(score_s - score_t) at (x+δ) - (score_s - score_t) at x| ≤ 12 * Kd * ‖δ‖.
   ```

4. **Transfer strict gap at `x` to strict gap at `x + δ`.**  
   For each competitor `t ≠ s⋆`, start from
   ```lean
   score_s⋆ x - score_t x ≥ Δ
   ```
   and subtract the worst-case gap deterioration:
   ```lean
   score_s⋆ (x+δ) - score_t (x+δ)
     ≥ Δ - 12 * Kd * ‖δ‖.
   ```
   Under `‖δ‖ < Δ / (12 * Kd)`, the RHS is positive, giving strict dominance.

5. **Conclude uniqueness of the same ranking and hence label preservation.**  
   Since `s⋆` still beats all five competitors, it remains the unique Kemeny-optimal ranking at `x+δ`, so its top class is unchanged.

### Optional sharper structural theorem

If the GL3 development already contains top-1 or pairwise certified robustness lemmas, try to prove an explicit winner-region characterization for each top class. For example, characterize when `0` is the top class of the unique Kemeny ranking in terms of linear inequalities among
`m01, m02, m12`. One expects the region for ranking `0 ≻ 1 ≻ 2` to be cut out by inequalities like:
```lean
score012 > score021
score012 > score102
score012 > score120
score012 > score201
score012 > score210
```
which simplify to explicit linear half-spaces. This would make the tropical/polyhedral geometry of the classifier visible and may permit a sharper certified radius than the crude union bound.

### Why this matters

This theorem is not a cosmetic variant of Borda or Condorcet robustness. Kemeny aggregation is a global ranking optimization problem: the winning label is extracted from the top element of the permutation maximizing a nontrivial objective over `S₃`. Showing that this optimization remains stable under tropical-Lipschitz perturbations builds a real bridge between:
- tropical/Hecke score geometry,
- finite social-choice optimization,
- certified adversarial robustness.

For the broader program, this gives the first robustness theorem for a multiclass decision rule whose prediction is obtained through an explicit combinatorial optimization layer rather than a direct max or simple score sum. In other words, it demonstrates that the GL3 tropical Satake framework is strong enough to certify robustness not only for linear or pairwise-derived classifiers, but also for structured ranking-based aggregators.

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
