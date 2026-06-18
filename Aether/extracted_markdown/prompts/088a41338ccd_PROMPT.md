## Research Task: GL3 tropical Satake certified robustness for Borda-count Hecke score aggregation

Research Mode: PROVE

Develop a formal robustness theory for multiclass GL3 Hecke-score classifiers whose final prediction is obtained by Borda aggregation of pairwise score comparisons. The most promising route is to work first with a **weighted Borda / Copeland-margin surrogate**
\[
\Omega_i(x) := \sum_{j \neq i} (S_i(x)-S_j(x)),
\]
because this converts the discrete rank-aggregation problem into a tropical-Lipschitz statement about linear combinations of already-controlled class scores. After that, derive a discrete winner-invariance theorem for the thresholded Borda score
\[
B_i(x) := \sum_{j \neq i} \mathbf{1}[S_i(x) > S_j(x)]
\]
under a strict pairwise margin hypothesis.

The key mathematical point is that pairwise margins inherit perturbation control from the class-score perturbation theorem, and both the weighted aggregate \(\Omega_i\) and the thresholded aggregate \(B_i\) can be certified by reducing robustness of the final decision to stability of finitely many pairwise inequalities.

### Suggested concrete definitions

Work over a finite label type `α` with `[Fintype α] [DecidableEq α]`. It is acceptable to prove the theorems for arbitrary finite `α` and then specialize to `Fintype.card α = 3`; this is likely cleaner than hard-coding `Fin 3`.

A useful set of Lean definitions is:

```lean
open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

def pairMargin (S : α → ℝ) (i j : α) : ℝ :=
  S i - S j

def weightedBorda (S : α → ℝ) (i : α) : ℝ :=
  ∑ j in (univ.erase i), pairMargin S i j

def bordaScore (S : α → ℝ) (i : α) : ℕ :=
  ∑ j in (univ.erase i), if 0 < pairMargin S i j then 1 else 0

def isWinnerWeighted (S : α → ℝ) (w : α) : Prop :=
  ∀ j, weightedBorda S j ≤ weightedBorda S w

def strictWinnerWeighted (S : α → ℝ) (w : α) : Prop :=
  ∀ j, j ≠ w → weightedBorda S j < weightedBorda S w

def isWinnerBorda (S : α → ℝ) (w : α) : Prop :=
  ∀ j, bordaScore S j ≤ bordaScore S w

def strictWinnerBorda (S : α → ℝ) (w : α) : Prop :=
  ∀ j, j ≠ w → bordaScore S j < bordaScore S w
```

For perturbations, it is enough to parameterize by two score vectors `S T : α → ℝ`, where `S` is the score at `x` and `T` the score at `x+δ`. This avoids committing too early to a particular input-space norm formalization. Then the downstream theorem for `x, δ` can be obtained by instantiating the hypothesis
`∀ c, |T c - S c| ≤ K * ε`
from the GL3 tropical Satake score perturbation bound already available.

### Primary theorem 1: weighted Borda perturbation bound

Prove first the exact Lipschitz control on weighted Borda totals.

A strong and clean target statement is:

```lean
theorem weightedBorda_diff_le
    (S T : α → ℝ) (i : α)
    (hST : ∀ c, |T c - S c| ≤ η) :
    |weightedBorda T i - weightedBorda S i|
      ≤ 2 * (Fintype.card α - 1 : ℕ) * η := by
  ...
```

A sharper form with `ℝ` casts may be easier:

```lean
theorem weightedBorda_diff_le'
    (S T : α → ℝ) (i : α)
    (hST : ∀ c, |T c - S c| ≤ η) :
    |weightedBorda T i - weightedBorda S i|
      ≤ (2 : ℝ) * ((Fintype.card α - 1 : ℕ) : ℝ) * η := by
  ...
```

An even better theorem, if convenient, is the pairwise intermediate lemma:

```lean
theorem pairMargin_diff_le
    (S T : α → ℝ) (i j : α)
    (hST : ∀ c, |T c - S c| ≤ η) :
    |pairMargin T i j - pairMargin S i j| ≤ 2 * η := by
  ...
```

and then sum this over `j ∈ univ.erase i`.

#### Proof strategy
1. Expand
   \[
   (T_i-T_j) - (S_i-S_j) = (T_i-S_i) - (T_j-S_j).
   \]
   In Lean, `ring_nf` or `linarith` after rewriting `pairMargin`.
2. Apply the triangle inequality:
   \[
   |(T_i-S_i) - (T_j-S_j)| \le |T_i-S_i| + |T_j-S_j| \le 2\eta.
   \]
   This should be a straightforward `nlinarith`/`linarith` step using `abs_sub_le`.
3. For `weightedBorda`, rewrite the difference of sums as the sum of differences using `Finset.sum_sub_distrib`.
4. Bound the absolute value of the sum by the sum of absolute values using `abs_sum_le_sum_abs`.
5. Convert the resulting sum of constant bounds into a cardinality factor via
   `Finset.sum_const_nat`, `Finset.card_erase_of_mem`, and `Finset.mem_univ`.

This theorem is the analytic heart of the project: it packages the GL3 tropical score perturbation theorem into a robust certificate for an aggregation rule that is genuinely multiclass and not reducible to plain top-1 or plurality.

### Primary theorem 2: weighted Borda winner certification

Once the previous theorem is established, prove a winner-invariance theorem with an explicit margin threshold.

A natural precise statement is:

```lean
theorem weightedBorda_certified_winner
    (S T : α → ℝ) (w : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : ∀ j, j ≠ w →
      (2 : ℝ) * ((Fintype.card α - 1 : ℕ) : ℝ) * η
      < weightedBorda S w - weightedBorda S j) :
    strictWinnerWeighted T w := by
  ...
```

However, this constant is not yet sufficient, because both `weightedBorda S w` and `weightedBorda S j` can move. The correct robust separation condition is

\[
\Omega_w(S)-\Omega_j(S) > 4 (n-1)\eta.
\]

So the correct theorem should be:

```lean
theorem weightedBorda_certified_winner
    (S T : α → ℝ) (w : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : ∀ j, j ≠ w →
      (4 : ℝ) * ((Fintype.card α - 1 : ℕ) : ℝ) * η
      < weightedBorda S w - weightedBorda S j) :
    strictWinnerWeighted T w := by
  ...
```

If your GL3 score theorem has the form `|S_c(x+δ)-S_c(x)| ≤ K * ε`, instantiate `η := K * ε` to obtain the explicit radius certificate
\[
\Omega_w(x)-\Omega_j(x) > 4(n-1)K\varepsilon.
\]

#### Proof strategy
1. Use `weightedBorda_diff_le'` for both `w` and `j`.
2. Derive lower and upper one-sided inequalities:
   \[
   \Omega_w(T) \ge \Omega_w(S) - 2(n-1)\eta,\qquad
   \Omega_j(T) \le \Omega_j(S) + 2(n-1)\eta.
   \]
   This is just `abs_le.mp` or `have := abs_le.mp ...`.
3. Subtract to obtain
   \[
   \Omega_w(T)-\Omega_j(T)
   \ge (\Omega_w(S)-\Omega_j(S)) - 4(n-1)\eta.
   \]
4. Use the strict margin hypothesis to conclude positivity.
5. Package the result as `strictWinnerWeighted T w`.

This gives a clean certified robustness theorem whose proof is purely combinatorial once the score perturbation bound is known. It is the most likely theorem to be both nontrivial and smoothly formalizable.

### Primary theorem 3: pairwise sign stability under perturbation

For the discrete Borda score, first prove that sufficiently large pairwise margins cannot flip sign.

A precise theorem:

```lean
theorem pairMargin_sign_stable
    (S T : α → ℝ) (i j : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : 2 * η < pairMargin S i j) :
    0 < pairMargin T i j := by
  ...
```

and dually

```lean
theorem pairMargin_sign_stable_neg
    (S T : α → ℝ) (i j : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : pairMargin S i j < - 2 * η) :
    pairMargin T i j < 0 := by
  ...
```

A symmetric absolute-value formulation is also useful:

```lean
theorem pairMargin_no_flip
    (S T : α → ℝ) (i j : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : 2 * η < |pairMargin S i j|) :
    (0 < pairMargin S i j ↔ 0 < pairMargin T i j) := by
  ...
```

#### Proof strategy
1. Start from `pairMargin_diff_le`.
2. Convert the absolute bound into a lower bound:
   \[
   pairMargin(T,i,j) \ge pairMargin(S,i,j) - 2\eta.
   \]
3. Combine with the strict hypothesis `2η < pairMargin S i j`.
4. Use `linarith`.
5. For the biconditional version, prove both directions separately by symmetry in `S` and `T`, or just prove the positive/negative cases and split on the sign of `pairMargin S i j`.

This lemma is the bridge from real-valued score control to combinatorial rank invariance.

### Primary theorem 4: thresholded Borda score invariance under uniform pairwise separation

Now prove the discrete Borda robustness statement.

A good theorem is:

```lean
theorem bordaScore_eq_of_pairwise_margin
    (S T : α → ℝ) (i : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hsep : ∀ j, j ≠ i → 2 * η < |pairMargin S i j|) :
    bordaScore T i = bordaScore S i := by
  ...
```

This states that if every pairwise contest involving `i` has margin exceeding the perturbation threshold, then none of the indicator terms in `bordaScore` changes.

A global version for all labels is even more useful:

```lean
theorem bordaScore_eq_of_all_pairwise_margin
    (S T : α → ℝ) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hsep : ∀ i j, i ≠ j → 2 * η < |pairMargin S i j|) :
    ∀ i, bordaScore T i = bordaScore S i := by
  ...
```

#### Proof strategy
1. Unfold `bordaScore`.
2. Apply `Finset.sum_congr`.
3. For each `j ∈ univ.erase i`, use `j ≠ i` obtained from `Finset.mem_erase.mp`.
4. Use `pairMargin_no_flip` to prove the `if` conditions are equivalent:
   `0 < pairMargin T i j ↔ 0 < pairMargin S i j`.
5. Conclude the summands are identical and hence the total sums are equal.

This theorem is the exact discrete analogue of the weighted theorem: every pairwise vote remains unchanged, so the Borda totals remain unchanged.

### Primary theorem 5: Borda winner certification

Finally package the global invariance into a winner theorem.

A robust and simple statement is:

```lean
theorem borda_certified_winner
    (S T : α → ℝ) (w : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hwin : strictWinnerBorda S w)
    (hsep : ∀ i j, i ≠ j → 2 * η < |pairMargin S i j|) :
    strictWinnerBorda T w := by
  ...
```

Because `bordaScore T i = bordaScore S i` for all `i`, this theorem should be immediate once the previous one is proved.

A more local but stronger theorem would only assume separation for the pairwise contests that are relevant to preserving the winner’s lead. For a first formalization, the global separation condition is preferable; after that, try to optimize hypotheses.

#### Proof strategy
1. Obtain `hb : ∀ i, bordaScore T i = bordaScore S i` from `bordaScore_eq_of_all_pairwise_margin`.
2. Fix `j ≠ w`.
3. Rewrite both sides of the target inequality using `hb`.
4. Apply `hwin j hj`.
5. Done.

### Specialization to GL3 / certified radius form

After proving the abstract perturbation theorems above, specialize them to the actual GL3 tropical Satake score family. The expected shape is something like:

```lean
theorem gl3_weightedBorda_certified_radius
    (x δ : ...) (w : α) (ε K : ℝ)
    (hδ : ‖δ‖∞ ≤ ε)
    (hscore : ∀ c, |S c (x + δ) - S c x| ≤ K * ε)
    (hmargin : ∀ j, j ≠ w →
      (4 : ℝ) * ((Fintype.card α - 1 : ℕ) : ℝ) * K * ε
        < weightedBorda (fun c => S c x) w - weightedBorda (fun c => S c x) j) :
    strictWinnerWeighted (fun c => S c (x + δ)) w := by
  ...
```

and similarly for thresholded Borda with `2 * K * ε < |S_i(x)-S_j(x)|`.

If the normed-space setup for `x, δ` is not yet standardized, it is entirely acceptable to leave the GL3 specialization at the level of a hypothesis `hscore : ∀ c, |T c - S c| ≤ K * ε` and defer the exact ambient type to a later file.

### Additional structural lemmas worth proving

These are not mere conveniences; they clarify the geometry of the weighted Borda surrogate.

1. Closed form for `weightedBorda`:
   \[
   \Omega_i = n S_i - \sum_k S_k.
   \]
   Precise Lean statement:
   ```lean
   theorem weightedBorda_eq_card_mul_sub_sum
       (S : α → ℝ) (i : α) :
       weightedBorda S i
         = ((Fintype.card α : ℕ) : ℝ) * S i - ∑ j, S j := by
     ...
   ```
   This is very valuable: it shows weighted Borda is just an affine transform of the original class score, hence the weighted theorem is not only robust but algebraically transparent.

2. Difference formula:
   \[
   \Omega_i - \Omega_j = n(S_i-S_j).
   \]
   Precise Lean statement:
   ```lean
   theorem weightedBorda_sub_weightedBorda
       (S : α → ℝ) (i j : α) :
       weightedBorda S i - weightedBorda S j
         = ((Fintype.card α : ℕ) : ℝ) * (S i - S j) := by
     ...
   ```
   This is especially important in the `|α|=3` case:
   \[
   \Omega_i - \Omega_j = 3(S_i-S_j).
   \]
   It implies the weighted-Borda winner agrees exactly with the ordinary argmax of `S`, so the weighted result is mathematically clean but also exposes that the genuinely new content lies in the thresholded Borda theorem.

3. Specialization to `Fintype.card α = 3`:
   ```lean
   theorem weightedBorda_diff_le_card3
       (hcard : Fintype.card α = 3)
       (S T : α → ℝ) (i : α)
       (hST : ∀ c, |T c - S c| ≤ η) :
       |weightedBorda T i - weightedBorda S i| ≤ 4 * η := by
     ...
   ```
   Since `2*(3-1)=4`, the constants become especially simple.

### Why this matters

This direction extends certified robustness from simple multiclass decision rules to a bona fide **rank-aggregation mechanism**. That matters for the program because:

1. Borda aggregation uses all pairwise comparisons, not just the top score, so it is a more structurally global decision rule.
2. The weighted theorem isolates a tropical-Lipschitz principle for aggregated Hecke/Satake statistics.
3. The thresholded theorem shows that discrete social-choice-style aggregation can still admit explicit robustness certificates.
4. In the `GL3` setting, this is the first natural robustness result for a multiclass rule built from the full pairwise comparison graph rather than from a single winner-take-all statistic.

The best proof architecture is therefore:

- first, abstract perturbation lemmas on `α → ℝ`;
- second, weighted Borda Lipschitz and winner certification;
- third, pairwise sign-stability and thresholded Borda invariance;
- finally, specialization to the GL3 tropical Satake score family and the certified radius corollaries.

If time permits, try to push one step further: weaken the global pairwise separation hypothesis in `borda_certified_winner` to a hypothesis only on those pairwise contests whose flip could reduce the winner’s Borda lead below zero. That would produce a sharper and genuinely new certificate beyond the uniform-margin bound.

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
