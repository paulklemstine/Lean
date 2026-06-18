## Research Task: Tropical certified robustness for multiclass piecewise-linear networks under plurality-of-experts decision via expertwise logit-gap margins

Research Mode: PROVE

Work with a finite family of experts indexed by `Fin n`, each expert producing a score vector on `Fin C` over an input space `Fin d → ℝ`. Formalize plurality voting and prove a compositional robustness theorem converting individual logit-gap certificates into an ensemble certificate.

A good concrete setup is the following.

### Core definitions to introduce

Use `n C d : ℕ` with `[NeZero C]`, and represent inputs as `x : Fin d → ℝ`, score maps as
```lean
f : Fin n → (Fin d → ℝ) → Fin C → ℝ
```
Define:

```lean
def scoreGap (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : ℝ :=
  f x c - Finset.sup' (Finset.univ.erase c) (by
    simpa using Finset.nonempty_erase (Finset.mem_univ c)) (fun j => f x j)

def predicts (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : Prop :=
  ∀ j : Fin C, f x j ≤ f x c

def voteCount (F : Fin n → (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : ℕ :=
  ((Finset.univ : Finset (Fin n)).filter (fun i => decides (F i x) c)).card
```

where
```lean
def decides (s : Fin C → ℝ) (c : Fin C) : Prop := ∀ j : Fin C, s j ≤ s c
```

You may also want the winner-support set
```lean
def winnerVoters (F : Fin n → (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : Finset (Fin n) :=
  (Finset.univ.filter (fun i => decides (F i x) c))
```

For robustness in `‖·‖∞`, define the closed ball predicate
```lean
def InLInfBall (x z : Fin d → ℝ) (r : ℝ) : Prop :=
  ∀ k, |z k - x k| ≤ r
```

For each expert, assume a coordinatewise Lipschitz bound strong enough to imply logit-gap stability:
```lean
def CoordLipschitz (f : (Fin d → ℝ) → Fin C → ℝ) (K : ℝ) : Prop :=
  ∀ x z c, |f z c - f x c| ≤ K * (∑ k : Fin d, |z k - x k|)
```

A useful stronger assumption than needed, but easy to exploit, is:
```lean
def ExpertStableOnBall
  (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) (r K : ℝ) : Prop :=
  0 ≤ r ∧ 0 ≤ K ∧
  scoreGap f x c > 2 * K * (d : ℝ) * r ∧
  CoordLipschitz f K
```

### Main theorem: frozen winner-voters imply plurality robustness

The central theorem should be stated in a purely combinatorial-analytic form. A strong target signature is:

```lean
theorem plurality_robust_of_frozen_winner_voters
  {n C d : ℕ} [NeZero C]
  (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
  (K : Fin n → ℝ)
  (x : Fin d → ℝ)
  (c⋆ : Fin C)
  (r : ℝ)
  (S : Finset (Fin n))
  (hSsubset :
    S ⊆ winnerVoters F x c⋆)
  (hstable :
    ∀ ⦃i : Fin n⦄, i ∈ S →
      ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r → decides (F i z) c⋆)
  (hplurality :
    ∀ c : Fin C, c ≠ c⋆ →
      voteCount F x c < S.card) :
  ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r →
    ∀ c : Fin C, c ≠ c⋆ → voteCount F z c < voteCount F z c⋆
```

This theorem says: if a set `S` of experts that vote for `c⋆` at the basepoint are individually frozen to `c⋆` throughout the ball, and `|S|` already exceeds every rival basepoint vote count, then `c⋆` remains the unique plurality winner on the whole ball. The key subtlety is that rival classes can gain votes only from experts outside `S`, while `c⋆` keeps all votes from `S`.

A useful corollary packages `S` as all basepoint `c⋆`-voters whose certified radius exceeds `r`:

```lean
def certRadius
  (f : (Fin d → ℝ) → Fin C → ℝ) (K : ℝ) (x : Fin d → ℝ) (c : Fin C) : ℝ :=
  scoreGap f x c / (2 * K * (d : ℝ))

def stableWinnerVoters
  (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
  (K : Fin n → ℝ) (x : Fin d → ℝ) (c : Fin C) (r : ℝ) : Finset (Fin n) :=
  (Finset.univ.filter (fun i =>
    decides (F i x) c ∧ r < certRadius (F i) (K i) x c))
```

Then prove:

```lean
theorem plurality_robust_of_expert_gap_certificates
  {n C d : ℕ} [NeZero C]
  (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
  (K : Fin n → ℝ)
  (x : Fin d → ℝ)
  (c⋆ : Fin C)
  (r : ℝ)
  (hK : ∀ i, 0 ≤ K i)
  (hLip : ∀ i, CoordLipschitz (F i) (K i))
  (hgap :
    ∀ i ∈ stableWinnerVoters F K x c⋆ r,
      scoreGap (F i) x c⋆ > 2 * K i * (d : ℝ) * r)
  (hplurality :
    ∀ c : Fin C, c ≠ c⋆ →
      voteCount F x c < (stableWinnerVoters F K x c⋆ r).card) :
  ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r →
    ∀ c : Fin C, c ≠ c⋆ → voteCount F z c < voteCount F z c⋆
```

### Quantitative radius theorem via order statistics of winner-expert certificates

After the structural theorem, derive a genuinely quantitative certificate. Let
```lean
def winnerRadii
  (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
  (K : Fin n → ℝ) (x : Fin d → ℝ) (c : Fin C) : Finset ℝ :=
  (winnerVoters F x c).image (fun i => certRadius (F i) (K i) x c)
```

The mathematically right statement is: if `M = max_{c ≠ c⋆} voteCount F x c`, and among experts voting for `c⋆` at `x` there are at least `M+1` experts with certificate radius greater than `r`, then `c⋆` is robust on the ball of radius `r`. This is the plurality analogue of a top-1 certified radius from a multiset of per-expert margins.

You can formulate this without explicit sorting by quantifying over a subset:
```lean
theorem plurality_robust_exists_frozen_subset
  {n C d : ℕ} [NeZero C]
  (F : Fin n → (Fin d → ℝ) → Fin C → ℝ)
  (K : Fin n → ℝ)
  (x : Fin d → ℝ)
  (c⋆ : Fin C)
  (r : ℝ)
  (M : ℕ)
  (hM :
    ∀ c : Fin C, c ≠ c⋆ → voteCount F x c ≤ M)
  (S : Finset (Fin n))
  (hSsubset : S ⊆ winnerVoters F x c⋆)
  (hScard : M < S.card)
  (hstable :
    ∀ ⦃i : Fin n⦄, i ∈ S →
      ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r → decides (F i z) c⋆) :
  ∀ ⦃z : Fin d → ℝ⦄, InLInfBall x z r →
    ∀ c : Fin C, c ≠ c⋆ → voteCount F z c < voteCount F z c⋆
```

This theorem is often easier to use than one involving a sorted list of radii, and it captures the exact combinatorial content.

### Key analytic lemma: gap stability under Lipschitz perturbation

The indispensable per-expert lemma is the multiclass margin preservation estimate. A precise target is:

```lean
theorem decides_of_gap_gt_two_mul_lipschitz
  {C d : ℕ} [NeZero C]
  (f : (Fin d → ℝ) → Fin C → ℝ)
  (K r : ℝ)
  (x z : Fin d → ℝ)
  (c : Fin C)
  (hK : 0 ≤ K)
  (hLip : CoordLipschitz f K)
  (hball : InLInfBall x z r)
  (hgap : scoreGap f x c > 2 * K * (d : ℝ) * r) :
  decides (f z) c
```

The intended proof is:
1. Fix any `j ≠ c`.
2. Use the definition of `scoreGap` to get `f x j ≤ f x c - scoreGap f x c`.
3. Apply the coordinatewise Lipschitz bound twice:
   `f z c ≥ f x c - K * ∑ |z_k - x_k|` and
   `f z j ≤ f x j + K * ∑ |z_k - x_k|`.
4. Bound `∑ |z_k - x_k| ≤ d * r` from the `L∞` ball hypothesis by summing the pointwise estimate.
5. Conclude `f z j < f z c`, hence `f z j ≤ f z c`.

You may first prove the summation lemma:
```lean
theorem sum_abs_sub_le_dim_mul_linf
  {d : ℕ} (x z : Fin d → ℝ) (r : ℝ)
  (hball : InLInfBall x z r) :
  ∑ k : Fin d, |z k - x k| ≤ (d : ℝ) * r
```
under `0 ≤ r`, or derive it with `nlinarith` from `Finset.sum_le_card_nsmul`.

### Concrete proof strategy for the plurality theorem

A robust route is:

1. **Frozen-voter lower bound for the winner.**  
   Show that for every `z` in the ball,
   ```lean
   S.card ≤ voteCount F z c⋆
   ```
   because every `i ∈ S` still votes for `c⋆`. This is a `Finset.card_le_card` argument using `S ⊆ winnerVoters F z c⋆`.

2. **Basepoint upper bound for rivals persists as an absolute cap.**  
   For each rival `c ≠ c⋆`, one only needs
   ```lean
   voteCount F z c ≤ (Finset.univ \ S).card
   ```
   in general, but the sharper argument is simpler: since every `i ∈ S` votes for `c⋆`, no such `i` can vote for rival `c`, so
   ```lean
   voteCount F z c ≤ n - S.card.
   ```
   Combined with the hypothesis `voteCount F x c < S.card`, this already gives uniqueness if needed, but the direct comparison
   `voteCount F z c < voteCount F z c⋆` follows immediately from `voteCount F z c < S.card ≤ voteCount F z c⋆`
   once you prove `voteCount F z c < S.card`. To get that strict bound, observe rival voters at `z` are disjoint from `S`, and use the basepoint condition only to choose `S` large enough; in many formulations `hplurality` is exactly the needed combinatorial assumption.

3. **Disjointness argument.**  
   Prove that if `i ∈ S`, then `i ∉ {j | decides (F j z) c}` for `c ≠ c⋆`, because `hstable` gives `decides (F i z) c⋆`, and strict plurality formulations should use a uniqueness hypothesis ruling out ties. If your `decides` notion allows ties, then define ensemble robustness as preservation of `c⋆` as *a* winner; if you want strict uniqueness, strengthen to
   ```lean
   strict_decides (s : Fin C → ℝ) (c : Fin C) := ∀ j ≠ c, s j < s c
   ```
   and prove the strict version first.

4. **Use strict expert stability if needed.**  
   Since `scoreGap > 0` gives strict inequalities against every competitor, the analytic lemma naturally yields `strict_decides`. This avoids tie pathology and makes the plurality proof cleaner.

5. **Package the corollary via `stableWinnerVoters`.**  
   Build `S := stableWinnerVoters F K x c⋆ r`, verify each `i ∈ S` satisfies the gap lemma, then invoke the structural theorem.

### Recommended stronger formulation with strict expert decisions

If tie issues become awkward, use:
```lean
def StrictDecides (s : Fin C → ℝ) (c : Fin C) : Prop :=
  ∀ j : Fin C, j ≠ c → s j < s c
```
and then define
```lean
def strictVoteCount ...
```
with strict winners. Then prove:
```lean
theorem strict_plurality_robust_of_frozen_winner_voters ...
```
This is mathematically cleaner because positive gap hypotheses naturally imply strict winner preservation, and plurality with strict class counts is the intended notion anyway.

### Why this matters

This theorem is the missing compositional step from single-network tropical certificates to certified robustness of finite multiclass ensembles. The nontrivial content is that plurality is not a Lipschitz-stable aggregation in any obvious normed sense; robustness comes from a hybrid argument combining analytic margin preservation for individual experts with a combinatorial vote-margin invariant. Formalizing this gives a reusable certification pattern for:
- mixtures or ensembles of tropical / ReLU subnetworks,
- modular certified defenses where only a subset of experts need remain frozen,
- future top-`k`, majority, and abstaining aggregators proved by the same `frozen subset + counting` schema.

A successful development should leave behind:
1. a clean multiclass logit-gap stability lemma in `L∞`,
2. a finite-ensemble plurality robustness theorem,
3. a quantitative radius corollary based on the cardinality of certified winner-experts.

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
