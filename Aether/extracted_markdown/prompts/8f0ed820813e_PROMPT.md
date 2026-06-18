## Research Task: GL3 tropical Satake margin theorem for pairwise one-vs-one voting classifiers

Research Mode: PROVE

Work in a concrete finite class space `Fin n` with `Fintype`/`DecidableEq` instances, and formulate the voting architecture directly in Lean using real-valued score maps. The main goal is to prove a robustness theorem for pairwise one-vs-one aggregation that is genuinely different from plain argmax stability: the winner is determined by a tournament of pairwise tropical score differences, and robustness is certified by preserving all outgoing edges from the current winner.

### Core definitions to formalize

Use a general input type `α` equipped with a perturbation distance surrogate `dist : α → α → ℝ`, or more concretely `α = Fin d → ℝ` with the `‖·‖∞` norm. If you want to avoid normed-space overhead, parameterize the perturbation condition by a predicate `Perturb x x' r`.

A clean concrete route is:

```lean
open Finset

def PairMargin {n : ℕ} (S : Fin n → (Fin d → ℝ) → ℝ) (i j : Fin n) (x : Fin d → ℝ) : ℝ :=
  S i x - S j x

def PairWins {n : ℕ} (S : Fin n → (Fin d → ℝ) → ℝ) (i j : Fin n) (x : Fin d → ℝ) : Prop :=
  PairMargin S i j x > 0

def BordaScore {n : ℕ} (S : Fin n → (Fin d → ℝ) → ℝ) (i : Fin n) (x : Fin d → ℝ) : ℕ :=
  ((univ.filter fun j => j ≠ i ∧ PairMargin S i j x > 0).card)

def IsStrictBordaWinner {n : ℕ} (S : Fin n → (Fin d → ℝ) → ℝ) (w : Fin n) (x : Fin d → ℝ) : Prop :=
  ∀ i, i ≠ w → BordaScore S i x < BordaScore S w x
```

For a Copeland-style formulation, `BordaScore` above already counts pairwise wins, so it serves as the natural finite tournament score. If you also define a set-valued winner notion, keep a strict uniqueness predicate to avoid tie ambiguity.

For robustness assumptions, use heterogeneous pairwise Lipschitz constants:

```lean
def PairLipschitzAtRadius {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (K : Fin n → Fin n → ℝ)
    (x : Fin d → ℝ) (r : ℝ) : Prop :=
  ∀ i j x',
    ‖x' - x‖ ≤ r →
    |PairMargin S i j x' - PairMargin S i j x| ≤ K i j * r
```

If the GL3 tropical Satake development already gives pointwise finite-test-family control rather than a global norm-Lipschitz statement, introduce an intermediate hypothesis with exactly the form you can extract from those theorems, then derive the above inequality as a lemma.

### Main theorem: preservation of all outgoing pairwise wins implies stable Borda/Copeland winner

The key theorem should be stated in a way that isolates the genuinely new combinatorial content from the analytic tropical-margin estimate.

A strong and usable Lean signature is:

```lean
theorem borda_winner_stable_of_pairwise_win_preservation
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (w : Fin n) (x x' : Fin d → ℝ)
    (huniq : IsStrictBordaWinner S w x)
    (hpres : ∀ j, j ≠ w → PairMargin S w j x' > 0) :
    IsStrictBordaWinner S w x' := by
```

This is the combinatorial tournament lemma. It should be proved without any tropical machinery. The point is that if `w` beats every other class at `x'`, then `BordaScore S w x' = n - 1`, which is the maximal possible score, and every `i ≠ w` has score at most `n - 2` because `i` loses to `w`. Hence `w` is the unique strict Borda/Copeland winner at `x'`.

A more explicit score comparison lemma that may be easier to use in the final proof is:

```lean
theorem bordaScore_eq_top_of_beats_all
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (w : Fin n) (x : Fin d → ℝ)
    (h : ∀ j, j ≠ w → PairMargin S w j x > 0) :
    BordaScore S w x = n - 1 := by

theorem bordaScore_lt_top_of_loses_to_w
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (w i : Fin n) (x : Fin d → ℝ)
    (hwi : w ≠ i)
    (hlose : PairMargin S w i x > 0) :
    BordaScore S i x < n - 1 := by
```

Then combine them to obtain strict uniqueness.

### Main robustness theorem with heterogeneous margins

The central certified robustness result should be:

```lean
theorem stable_borda_winner_of_pairwise_margins
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (K : Fin n → Fin n → ℝ)
    (w : Fin n) (x x' : Fin d → ℝ) (r : ℝ)
    (hr : 0 ≤ r)
    (hpert : ‖x' - x‖ ≤ r)
    (hLip : ∀ i j, |PairMargin S i j x' - PairMargin S i j x| ≤ K i j * r)
    (hKnonneg : ∀ i j, 0 ≤ K i j)
    (hmargin : ∀ j, j ≠ w → 2 * K w j * r < PairMargin S w j x)
    (huniq : IsStrictBordaWinner S w x) :
    IsStrictBordaWinner S w x' := by
```

There is also a sharper radius corollary that packages the certified radius as an infimum/minimum over opponents:

```lean
def certifiedRadius {n : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (K : Fin n → Fin n → ℝ)
    (w : Fin n) (x : Fin d → ℝ) : ℝ :=
  (univ.erase w).inf' (by simp) (fun j => PairMargin S w j x / (2 * K w j))

theorem stable_borda_winner_of_lt_certifiedRadius
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (K : Fin n → Fin n → ℝ)
    (w : Fin n) (x x' : Fin d → ℝ)
    (hKpos : ∀ j, j ≠ w → 0 < K w j)
    (hpert : ‖x' - x‖ < certifiedRadius S K w x)
    (hLip : ∀ i j, |PairMargin S i j x' - PairMargin S i j x| ≤ K i j * ‖x' - x‖)
    (huniq : IsStrictBordaWinner S w x) :
    IsStrictBordaWinner S w x' := by
```

If `Finset.inf'` over `ℝ` is awkward, replace this by a theorem quantified directly over any `r` satisfying
`∀ j ≠ w, r < PairMargin S w j x / (2 * K w j)`.

### Proof strategy

1. **Analytic margin preservation for each pair.**  
   Prove a basic inequality:
   ```lean
   theorem pairMargin_pos_of_lipschitz_bound
       {a b δ : ℝ}
       (hδ : |b - a| ≤ δ)
       (hmargin : δ < a) :
       0 < b := by
   ```
   Then instantiate with  
   `a = PairMargin S w j x`, `b = PairMargin S w j x'`, `δ = K w j * r`.  
   Since
   `PairMargin S w j x' ≥ PairMargin S w j x - |...|`
   and `|...| ≤ K w j * r`,
   the stronger hypothesis `2 * K w j * r < PairMargin S w j x` certainly implies `K w j * r < PairMargin ...`, hence positivity is preserved.  
   If desired, sharpen the theorem by assuming only `K w j * r < margin`; the `2` factor is mainly to match the established tropical robustness pattern.

2. **Convert preserved pairwise margins into preserved tournament edges.**  
   Derive:
   ```lean
   have hpres : ∀ j, j ≠ w → PairMargin S w j x' > 0 := ...
   ```
   This is the exact bridge from tropical quantitative control to the discrete one-vs-one voting graph.

3. **Pure combinatorial Copeland/Borda lemma.**  
   Show that if `w` beats every other class at `x'`, then `w` has the maximum possible pairwise-win count:
   `BordaScore S w x' = n - 1`.  
   For any `i ≠ w`, because `w` beats `i`, class `i` cannot beat all opponents, so
   `BordaScore S i x' ≤ n - 2`.  
   Therefore `BordaScore S i x' < BordaScore S w x'`.  
   This step is the genuinely new voting-aggregation lemma; it should not depend on the structure of tropical Satake scores.

4. **Optional strengthening: uniqueness at the base point is not actually needed for the target conclusion.**  
   Notice that once all inequalities `PairMargin S w j x' > 0` hold at the perturbed point, uniqueness at `x'` follows immediately from the tournament argument, regardless of whether `w` was unique at `x`.  
   Thus `huniq : IsStrictBordaWinner S w x` is logically stronger than necessary. It is still useful semantically, because it identifies `w` as the currently certified winner. Consider proving both versions:
   - a minimal theorem deriving uniqueness at `x'` purely from preserved pairwise wins,
   - a user-facing robustness theorem that assumes `w` is the winner at `x`.

5. **GL3 tropical Satake specialization.**  
   After the abstract theorem is proved for arbitrary score maps `S`, specialize it to the GL3 tropical Satake score family already available in the library. The specialization theorem should assume whatever finite-support dominant-weight hypotheses are needed to extract pairwise constants `K i j` from the finite test-family separation/reconstruction results. The theorem statement can remain abstract in the constants, e.g.
   ```lean
   theorem gl3_tropical_satake_borda_robust
       ... :
       IsStrictBordaWinner S w x' := by
   ```
   where the hypotheses package the known GL3 finite-test-family control into the `hLip` assumption above.

### Important intermediate lemmas

These should make the final proof short and reusable.

```lean
theorem pairMargin_lower_bound
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (i j : Fin n) (x x' : Fin d → ℝ) :
    PairMargin S i j x - |PairMargin S i j x' - PairMargin S i j x|
      ≤ PairMargin S i j x' := by
```

```lean
theorem pairMargin_pos_of_bound
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (K : Fin n → Fin n → ℝ)
    (i j : Fin n) (x x' : Fin d → ℝ) (r : ℝ)
    (hLip : |PairMargin S i j x' - PairMargin S i j x| ≤ K i j * r)
    (hmargin : K i j * r < PairMargin S i j x) :
    0 < PairMargin S i j x' := by
```

```lean
theorem beats_all_implies_strict_borda_winner
    {n d : ℕ}
    (S : Fin n → (Fin d → ℝ) → ℝ)
    (w : Fin n) (x : Fin d → ℝ)
    (h : ∀ j, j ≠ w → PairMargin S w j x > 0) :
    IsStrictBordaWinner S w x := by
```

If counting with `Finset.card (filter ...)` becomes annoying, another robust alternative is to define Borda/Copeland score in `ℝ` or `ℕ` via a sum of indicators:
```lean
∑ j in univ.erase i, if PairMargin S i j x > 0 then 1 else 0
```
This often makes comparison lemmas easier, because the contribution from the opponent `w` is visibly `0` for any `i ≠ w` once `w` beats `i`.

### Significance

This theorem is valuable because it pushes the tropical robustness program beyond the standard argmax architecture into a genuinely different discrete decision layer: a multiclass classifier assembled from pairwise GL3 tropical Satake comparisons and aggregated by tournament voting. The analytic control still comes from tropical Satake finite test families and margin inequalities, but the final classifier is no longer a direct maximizer of a single score vector. Proving robustness here shows that tropical certification is stable under nontrivial post-processing by one-vs-one voting, which is exactly the kind of closure property needed for a broader theory of certified tropical decision systems. It also creates a reusable combinatorial interface: any future GL3/Hecke score construction that yields pairwise Lipschitz margin bounds can inherit certified Copeland/Borda robustness immediately.

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
