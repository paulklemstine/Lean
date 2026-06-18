## Research Task: GL3 tropical Satake certified robustness for top-2 gap Hecke-score classifiers

Research Mode: PROVE

Establish a direct multiclass certification theorem for tropical GL3 Hecke-score classifiers using the gap between the largest and second-largest scores. The key point is to avoid aggregation-specific machinery and instead prove a general “winner stability under perturbation” lemma for any finite family of score functions satisfying a uniform Lipschitz bound. Then instantiate it for the verified GL3 tropical Satake score functions.

This should be developed in a way that is reusable for later one-vs-rest / top-k / abstention theorems: first prove abstract finite-family lemmas over `Fin m`, then specialize to tropical Hecke scores.

### Core definitions to formalize

Work with `m d : ℕ`, inputs `x δ : Fin d → ℝ`, and scores `s : Fin m → (Fin d → ℝ) → ℝ`.

A useful abstract predicate for the score regularity is:

```lean
def ScoreLipschitzInf (C : ℝ) (s : Fin m → (Fin d → ℝ) → ℝ) : Prop :=
  ∀ i x y, |s i x - s i y| ≤ C * ‖x - y‖∞
```

If the catalog’s existing bound is instead of the form
`|s i x - s i y| ≤ K * d * ‖x - y‖∞`,
then define either:
```lean
def ScoreLipschitzInfKd (K : ℝ) (s : Fin m → (Fin d → ℝ) → ℝ) : Prop :=
  ∀ i x y, |s i x - s i y| ≤ K * d * ‖x - y‖∞
```
with `d : ℝ` coerced appropriately, or immediately package the available constant as a single `C : ℝ`.

For the top class and margin, it is better to avoid an explicit “second-largest index” at first. Define the margin of class `i` at `x` against all competitors:
```lean
def classMargin (s : Fin m → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) (i : Fin m) : ℝ :=
  s i x - Finset.sup' (Finset.univ.erase i) (by
    simpa using Finset.nonempty_erase (Finset.mem_univ i)) (fun j => s j x)
```

When `m = 0` or `m = 1`, the statement is degenerate, so assume at least `Fact (1 < m)` or work with `m+2` classes. A very clean setup is:
```lean
variable {m d : ℕ} [Fact (1 < m)]
```

Also define a winner predicate:
```lean
def IsTopClass (s : Fin m → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) (i : Fin m) : Prop :=
  ∀ j, s j x ≤ s i x
```

and a unique winner predicate:
```lean
def IsUniqueTopClass (s : Fin m → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) (i : Fin m) : Prop :=
  (∀ j, s j x ≤ s i x) ∧ ∀ j ≠ i, s j x < s i x
```

For the direct pairwise route, define:
```lean
def topGap (s : Fin m → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) (i : Fin m) : ℝ :=
  infᵢ (fun j : {j // j ≠ i} => s i x - s j.1 x)
```
but this `iInf` formulation is likely heavier than needed in Lean. For formal robustness, the more practical theorem is the pairwise strict domination statement:
```lean
∀ j ≠ i, 2 * C * ‖δ‖∞ < s i x - s j x → s j (x + δ) < s i (x + δ)
```
and then conclude `IsUniqueTopClass` at `x + δ`.

### Precise theorem targets

The most robust abstract theorem should look like this:

```lean
theorem unique_top_stable_of_inf_margin
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {C : ℝ}
    (hC : 0 ≤ C)
    (hLip : ScoreLipschitzInf C s)
    {x δ : Fin d → ℝ}
    {i : Fin m}
    (hwin : IsUniqueTopClass s x i)
    (hmargin : ∀ j, j ≠ i → 2 * C * ‖δ‖∞ < s i x - s j x) :
    IsUniqueTopClass s (x + δ) i := by
  ...
```

A very useful intermediate lemma is the two-score comparison estimate:

```lean
theorem score_diff_le_two_mul_lipschitz
    {m d : ℕ}
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {C : ℝ}
    (hLip : ScoreLipschitzInf C s)
    {i j : Fin m} {x y : Fin d → ℝ} :
    |(s i x - s j x) - (s i y - s j y)| ≤ 2 * C * ‖x - y‖∞ := by
  ...
```

This is the key quantitative lemma. It should be proved purely from the single-score bound using:
- rewrite
  `((s i x - s j x) - (s i y - s j y)) = (s i x - s i y) - (s j x - s j y)`
- apply `abs_sub_le`
- use the two Lipschitz bounds
- finish by linear arithmetic / `ring_nf` / `nlinarith`.

From this, derive the one-sided preservation lemma:

```lean
theorem score_gap_positive_under_perturbation
    {m d : ℕ}
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {C : ℝ}
    (hLip : ScoreLipschitzInf C s)
    {i j : Fin m} {x δ : Fin d → ℝ}
    (hgap : 2 * C * ‖δ‖∞ < s i x - s j x) :
    s j (x + δ) < s i (x + δ) := by
  ...
```

A convenient proof route is to show
```lean
s i (x + δ) - s j (x + δ) ≥ (s i x - s j x) - 2 * C * ‖δ‖∞
```
using the previous lemma with `y = x + δ` and `x = x`, then conclude positivity.

Then prove the direct classifier robustness theorem:

```lean
theorem argmax_stable_of_top2_gap
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {C : ℝ}
    (hC : 0 ≤ C)
    (hLip : ScoreLipschitzInf C s)
    {x δ : Fin d → ℝ}
    {i : Fin m}
    (hwin : IsUniqueTopClass s x i)
    (hgap : ∀ j, j ≠ i → 2 * C * ‖δ‖∞ < s i x - s j x) :
    ∀ j, s j (x + δ) ≤ s i (x + δ) := by
  ...
```

and preferably the strict form for uniqueness:
```lean
theorem unique_argmax_stable_of_top2_gap
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {C : ℝ}
    (hC : 0 ≤ C)
    (hLip : ScoreLipschitzInf C s)
    {x δ : Fin d → ℝ}
    {i : Fin m}
    (hwin : IsUniqueTopClass s x i)
    (hgap : ∀ j, j ≠ i → 2 * C * ‖δ‖∞ < s i x - s j x) :
    IsUniqueTopClass s (x + δ) i := by
  ...
```

### Radius-form certification theorem

After the abstract theorem, prove the radius corollary in the exact style used by earlier robustness files. If the catalog already phrases perturbation as `‖δ‖∞ < r`, use:

```lean
theorem unique_top_certified_radius
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {C : ℝ}
    (hC : 0 < C)
    (hLip : ScoreLipschitzInf C s)
    {x δ : Fin d → ℝ}
    {i : Fin m}
    (hwin : IsUniqueTopClass s x i)
    (hmargin : ∀ j, j ≠ i → 0 < s i x - s j x)
    (hr : ‖δ‖∞ < (infᵢ (fun j : {j // j ≠ i} => (s i x - s j.1 x) / (2 * C)))) :
    IsUniqueTopClass s (x + δ) i := by
  ...
```

But in Lean this `iInf` over a finite subtype may be awkward. A simpler and more concrete theorem is to quantify a radius `r` and assume the pointwise margin lower bound:

```lean
theorem unique_top_certified_radius'
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {C r : ℝ}
    (hC : 0 ≤ C)
    (hLip : ScoreLipschitzInf C s)
    {x δ : Fin d → ℝ}
    {i : Fin m}
    (hwin : IsUniqueTopClass s x i)
    (hrδ : ‖δ‖∞ < r)
    (hsep : ∀ j, j ≠ i → 2 * C * r < s i x - s j x) :
    IsUniqueTopClass s (x + δ) i := by
  ...
```

This theorem is likely the best formal API. Then instantiate `r = gap / (2*C)` in corollaries.

If the catalog’s available constant is `K * (d : ℝ)`, provide the specialization:

```lean
theorem unique_top_certified_radius_Kd
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {K r : ℝ}
    (hK : 0 ≤ K)
    (hLip : ∀ i x y, |s i x - s i y| ≤ K * (d : ℝ) * ‖x - y‖∞)
    {x δ : Fin d → ℝ}
    {i : Fin m}
    (hwin : IsUniqueTopClass s x i)
    (hrδ : ‖δ‖∞ < r)
    (hsep : ∀ j, j ≠ i → 2 * K * (d : ℝ) * r < s i x - s j x) :
    IsUniqueTopClass s (x + δ) i := by
  ...
```

This is the exact theorem that matches the stated research goal.

### Top-2 gap formulation

Once the pairwise-separation theorem is in place, package the “largest minus second-largest” gap. Avoid fragile order-statistics definitions unless the library support is already good. A practical finite-set definition is:

```lean
def top2Gap (s : Fin m → (Fin d → ℝ) → ℝ) (x : Fin d → ℝ) (i : Fin m) : ℝ :=
  s i x - Finset.sup' (Finset.univ.erase i)
    (by simpa using Finset.nonempty_erase (Finset.mem_univ i))
    (fun j => s j x)
```

Then prove:
```lean
theorem top2Gap_pos_iff_unique_top
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {x : Fin d → ℝ} {i : Fin m}
    (hwin : IsTopClass s x i) :
    0 < top2Gap s x i ↔ IsUniqueTopClass s x i := by
  ...
```

and then the radius theorem in the exact desired form:

```lean
theorem unique_top_stable_of_top2Gap
    {m d : ℕ} [Fact (1 < m)]
    {s : Fin m → (Fin d → ℝ) → ℝ}
    {K : ℝ}
    (hK : 0 ≤ K)
    (hLip : ∀ i x y, |s i x - s i y| ≤ K * (d : ℝ) * ‖x - y‖∞)
    {x δ : Fin d → ℝ} {i : Fin m}
    (hwin : IsUniqueTopClass s x i)
    (hδ : ‖δ‖∞ < top2Gap s x i / (2 * K * (d : ℝ))) :
    IsUniqueTopClass s (x + δ) i := by
  ...
```

This is the cleanest formal expression of the intended certification statement. The only subtlety is handling the denominator when `K = 0` or `d = 0`; you can either:
- assume `0 < K` and `0 < d`, or
- formulate the theorem with an arbitrary `r` plus the separation hypothesis, then derive the division form only under positivity assumptions.

Since `d : ℕ`, the case `d = 0` is possible. For a clean theorem, either assume `[Fact (0 < d)]` or write the specialization with a general constant `C > 0`. The most reusable statement is with `C`.

### Concrete proof strategy

1. **Prove the two-score perturbation lemma.**  
   Show
   ```lean
   |((s i x - s j x) - (s i y - s j y))| ≤ 2 * C * ‖x - y‖∞
   ```
   by rewriting the left-hand side as
   ```lean
   |(s i x - s i y) - (s j x - s j y)|
   ```
   and using `abs_sub_le`, then both Lipschitz hypotheses. This is the essential quantitative estimate.

2. **Derive strict gap preservation.**  
   From the previous lemma, obtain
   ```lean
   s i (x + δ) - s j (x + δ) >
   (s i x - s j x) - 2 * C * ‖δ‖∞
   ```
   whenever the original margin exceeds `2 * C * ‖δ‖∞`. Conclude
   `s j (x + δ) < s i (x + δ)` by positivity. This is the core “winner beats any challenger” step.

3. **Upgrade pairwise inequalities to unique argmax stability.**  
   Use the hypothesis `∀ j ≠ i, ...` to show strict domination over every competitor at `x + δ`. The `j = i` case is trivial. Package the result as `IsUniqueTopClass s (x + δ) i`.

4. **Package the top-2 gap as a finite-set supremum.**  
   Prove that if `i` is a top class, then every competitor score is bounded above by the `sup'` over `univ.erase i`, and conversely strict positivity of `top2Gap` gives strict domination over all competitors. This lets you replace the family of pairwise conditions with a single scalar margin.

5. **Specialize to GL3 tropical Satake scores.**  
   Instantiate the abstract theorem with the verified tropical Hecke-score Lipschitz bound from the GL3 development. If the existing theorem gives
   ```lean
   |s i x - s i y| ≤ K * (d : ℝ) * ‖x - y‖∞
   ```
   then the certified radius is exactly
   ```lean
   top2Gap s x i / (2 * K * (d : ℝ)).
   ```
   If the catalog already has a norm-conversion theorem sharper than `(d : ℝ)`, use that constant instead so the theorem is genuinely optimal relative to the current library.

### Significance

This theorem is the mathematically natural multiclass robustness statement for tropical GL3 Hecke-score classifiers. It replaces aggregation-dependent certification arguments by a direct score-gap principle: the predicted class is stable whenever the perturbation cannot close the first-vs-second score gap. That is the right notion for direct multiclass decision rules, and it gives a reusable certification interface independent of ECOC, Borda, or other voting reductions.

It also cleanly separates two layers of the research program:

- **representation-theoretic / tropical layer:** establish score-function Lipschitz control for GL3 Hecke/Satake constructions;
- **robustness layer:** convert any such control into certified invariance of argmax under `L∞` perturbations.

Once formalized abstractly, the same lemmas should immediately support:
- top-`k` stability theorems using the gap between the `k`th and `(k+1)`st scores,
- abstaining classifiers with a certified non-abstention threshold,
- future tropical Hecke developments beyond GL3 without redoing the robustness proof.

So the real deliverable is not just one theorem, but a small robust API for finite score families under `L∞` perturbations, with GL3 tropical Satake as the first nontrivial instantiation.

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
