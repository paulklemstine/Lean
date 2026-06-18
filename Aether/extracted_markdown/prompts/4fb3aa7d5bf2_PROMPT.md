## Research Task: GL3 tropical Satake robustness for plurality-of-top-k Hecke score committees

Research Mode: PROVE

Work in a new file
`Bridges/TropicalSatakeCommitteePlurality.lean`.

The target is a genuinely new bridge theorem: pass from the already-developed **single-model GL3 tropical Satake top-k robustness certificate** to a **committee-level plurality robustness theorem**. The central mathematical point is that there are two distinct stability layers:

1. **analytic / tropical layer**: a member’s top-k output is unchanged under sufficiently small score perturbation;
2. **discrete committee layer**: if only finitely many members can change their vote, then a large enough plurality margin forces the committee winner to remain fixed.

The goal is to formalize both layers cleanly and compose them.

---

### Concrete setup to formalize

Use a finite committee indexed by `Fin n`. Let labels be `Fin m`. Let each member output a score vector
`σ i : Fin m → ℝ`.

You should choose a simple deterministic vote extractor from top-k data that is easy to formalize and still captures the intended theorem. The cleanest choice is:

- each member has a deterministic selected label
  `vote i : Fin m`,
- this selected label is assumed to be a member of the member’s top-k set,
- under perturbation, if the top-k set is unchanged then the selected label is unchanged.

If the existing catalog already has a deterministic top-k selector, reuse it. Otherwise define an abstract selector with a stability hypothesis instead of re-developing top-k tie-breaking machinery from scratch.

A robust formal path is to separate the problem into three ingredients:

#### 1. Committee vote counts
Define
```lean
def voteCount {n m : ℕ} (v : Fin n → Fin m) (y : Fin m) : ℕ :=
  Fintype.card { i : Fin n // v i = y }
```
or equivalently via `Finset.univ.filter`.

Define plurality winner and margin assumptions through pointwise inequalities on `voteCount`, avoiding unnecessary argmax infrastructure.

#### 2. Perturbed votes
Let `v v' : Fin n → Fin m` be the original and perturbed committee votes.  
Define the changed-member set
```lean
def changedMembers {n m : ℕ} (v v' : Fin n → Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun i => v i ≠ v' i)
```
and use the bound
`(changedMembers v v').card ≤ M`.

#### 3. Member stability certificates
For each member `i`, assume a certified radius condition ensuring its selected vote is unchanged under perturbation. Package this as either:

- a theorem imported from the GL3 tropical Satake top-k robustness development, or
- a hypothesis of the form
  ```lean
  hi : ε i < certRadius i x → v' i = v i
  ```
  if the exact catalog API is cumbersome.

Then define the unstable set
```lean
def unstableMembers (ε cert : Fin n → ℝ) : Finset (Fin n) :=
  Finset.univ.filter (fun i => ¬ ε i < cert i)
```
and prove that only unstable members can change vote.

---

### Precise theorem statements to target

You should aim to prove the following sequence of theorems with concrete Lean signatures.

#### A. Single-vote counting perturbation bound
Changing one member’s vote changes any fixed label’s vote count by at most `1`.

A usable statement is:
```lean
theorem voteCount_sub_le_changed
    {n m : ℕ} [Fact (0 < m)]
    (v v' : Fin n → Fin m) (y : Fin m) :
    |(voteCount v y : ℤ) - (voteCount v' y : ℤ)| ≤ (changedMembers v v').card := by
  ...
```

A stronger and often easier combinatorial formulation is:
```lean
theorem voteCount_lower_bound
    {n m : ℕ} [Fact (0 < m)]
    (v v' : Fin n → Fin m) (y : Fin m) :
    voteCount v' y ≥ voteCount v y - (changedMembers v v').card := by
  ...
```
and the symmetric upper bound. If the `ℤ` absolute-value version is awkward, prove the pair of `Nat` inequalities instead.

#### B. Discrete plurality stability lemma
If `w` beats every competitor by margin strictly greater than the number of changed members, then `w` remains the unique winner after perturbation.

A precise statement:
```lean
theorem plurality_winner_stable_of_margin_gt_changed
    {n m : ℕ} [Fact (0 < m)]
    (v v' : Fin n → Fin m) (w : Fin m)
    (hmargin : ∀ y : Fin m, y ≠ w →
      voteCount v y + (changedMembers v v').card < voteCount v w)
    :
    ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w := by
  ...
```

This theorem is the correct committee-level discrete core. It avoids having to define a global `argmax`; the conclusion already says `w` remains the unique plurality winner.

A useful corollary with an explicit `M`:
```lean
theorem plurality_winner_stable_of_margin_gt_M
    {n m : ℕ} [Fact (0 < m)]
    (v v' : Fin n → Fin m) (w : Fin m) (M : ℕ)
    (hchanged : (changedMembers v v').card ≤ M)
    (hmargin : ∀ y : Fin m, y ≠ w → voteCount v y + M < voteCount v w)
    :
    ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w := by
  ...
```

#### C. Only unstable members can change vote
Assume a memberwise stability certificate:
```lean
theorem changedMembers_subset_unstable
    {n m : ℕ}
    (v v' : Fin n → Fin m)
    (ε cert : Fin n → ℝ)
    (hstable : ∀ i, ε i < cert i → v' i = v i) :
    changedMembers v v' ⊆ unstableMembers ε cert := by
  ...
```
and then cardinal control:
```lean
theorem changedMembers_card_le_unstable
    {n m : ℕ}
    (v v' : Fin n → Fin m)
    (ε cert : Fin n → ℝ)
    (hstable : ∀ i, ε i < cert i → v' i = v i) :
    (changedMembers v v').card ≤ (unstableMembers ε cert).card := by
  ...
```

This is the bridge from analytic certificates to the combinatorial margin lemma.

#### D. Final committee robustness theorem
State the final theorem in a way that only depends on memberwise vote stability, so that the GL3 tropical Satake theorem can be plugged in as the proof of `hstable`.

A good theorem is:
```lean
theorem committee_plurality_robust_of_member_certificates
    {n m : ℕ} [Fact (0 < m)]
    (v v' : Fin n → Fin m)
    (ε cert : Fin n → ℝ)
    (w : Fin m)
    (hstable : ∀ i, ε i < cert i → v' i = v i)
    (hmargin : ∀ y : Fin m, y ≠ w →
      voteCount v y + (unstableMembers ε cert).card < voteCount v w) :
    ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w := by
  ...
```

This theorem is the main ensemble robustness statement in a reusable abstract form.

#### E. GL3 tropical Satake specialization
Then add a specialization theorem whose hypotheses match the existing GL3/top-k catalog API as closely as possible. The exact signature depends on the existing names, but it should look structurally like:

```lean
theorem gl3_tropical_satake_committee_plurality_robust
    {n m : ℕ} [Fact (0 < m)]
    (x : X)
    (models : Fin n → ModelType)
    (ε : Fin n → ℝ)
    (w : Fin m)
    (v v' : Fin n → Fin m)
    (hvote :
      ∀ i, v i = selectedLabelFromTopK (scoreVec (models i) x))
    (hvote' :
      ∀ i, v' i = selectedLabelFromTopK (perturbedScoreVec (models i) x))
    (hmember_cert :
      ∀ i, ε i < certifiedRadius (models i) x →
        v' i = v i)
    (hmargin :
      ∀ y : Fin m, y ≠ w →
        voteCount v y + (unstableMembers ε (fun i => certifiedRadius (models i) x)).card
          < voteCount v w) :
    ∀ y : Fin m, y ≠ w → voteCount v' y < voteCount v' w := by
  ...
```

If the exact score perturbation theorem in the catalog is phrased in terms of top-k set equality rather than direct vote equality, insert an intermediate lemma:

```lean
theorem selectedLabel_eq_of_topK_eq
    ...
    (hsel : selectorDependsOnlyOnTopK ...)
    (htopk : topKSet score' = topKSet score) :
    selectedLabelFromTopK score' = selectedLabelFromTopK score := by
  ...
```

This is likely the right abstraction boundary.

---

### Proof strategy hints

#### For `voteCount_*` lemmas
1. Rewrite `voteCount` using `Finset.card_filter` on `Finset.univ`.
2. Compare the counts before and after perturbation by splitting the committee into changed and unchanged members:
   - unchanged members contribute identically;
   - changed members contribute at most `1` each to the discrepancy for a fixed label.
3. A very usable helper lemma is:
   ```lean
   (Finset.filter P s).card ≤ s.card
   ```
   together with the inclusion
   ```lean
   {i | v i = y ∧ v' i ≠ y} ⊆ changedMembers v v'
   ```
4. If the `ℤ` absolute-value route gets messy, first prove:
   ```lean
   voteCount v' y ≤ voteCount v y + (changedMembers v v').card
   ```
   and the symmetric inequality by swapping `v` and `v'`.

#### For the plurality stability lemma
1. For any competitor `y ≠ w`, combine:
   - an upper bound on `voteCount v' y`,
   - a lower bound on `voteCount v' w`.
2. The strongest clean pair is:
   ```lean
   voteCount v' y ≤ voteCount v y + C
   voteCount v' w ≥ voteCount v w - C
   ```
   but this only yields a `2C` loss. That is too weak for the intended margin `> C`.
3. The sharper argument is label-sensitive:
   - every changed vote can increase competitor `y` by at most `1`,
   - but any changed vote that increases `y` either leaves `w` alone or decreases `w`;
   - globally, one can still prove
     ```lean
     voteCount v' y - voteCount v' w ≤
       (voteCount v y - voteCount v w) + (changedMembers v v').card
     ```
     which is exactly the inequality needed.
4. So it is worth proving the more refined helper:
   ```lean
   theorem voteGap_perturbation_le_changed
       {n m : ℕ} [Fact (0 < m)]
       (v v' : Fin n → Fin m) (y w : Fin m) :
       (voteCount v' y : ℤ) - voteCount v' w
         ≤ ((voteCount v y : ℤ) - voteCount v w) + (changedMembers v v').card := by
     ...
   ```
   Then the plurality theorem becomes immediate from `hmargin`.
5. This “gap” formulation is mathematically the right one: the committee winner is governed by pairwise vote gaps, not by independent count perturbation bounds.

#### For `changedMembers_subset_unstable`
1. Take `i ∈ changedMembers v v'`; then `v i ≠ v' i`.
2. Suppose for contradiction `ε i < cert i`.
3. Apply `hstable i` to deduce `v' i = v i`, contradiction.
4. Convert the pointwise implication into `Finset.Subset`; then use `Finset.card_le_of_subset`.

#### For the GL3 tropical Satake specialization
1. Use the existing certified robustness theorem to obtain top-k set invariance for each member whenever `ε i < certifiedRadius ...`.
2. Use the selector-stability lemma to convert top-k invariance into vote invariance.
3. Apply `committee_plurality_robust_of_member_certificates`.
4. If the existing catalog theorem is phrased using a Lipschitz transfer from input perturbation to score perturbation, compose the inequalities first:
   ```lean
   ‖Δscore_i‖ ≤ L_i * ‖Δx‖
   ```
   and then ensure
   ```lean
   L_i * ‖Δx‖ < certifiedRadius_i
   ```
   to trigger the member certificate.

---

### Recommended helper definitions and lemmas

These will likely make the file cleaner.

```lean
def voteCountFinset {n m : ℕ} (v : Fin n → Fin m) (y : Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun i => v i = y)

theorem voteCount_eq_card_voteCountFinset
    {n m : ℕ} (v : Fin n → Fin m) (y : Fin m) :
    voteCount v y = (voteCountFinset v y).card := by
  ...
```

```lean
theorem mem_changedMembers
    {n m : ℕ} {v v' : Fin n → Fin m} {i : Fin n} :
    i ∈ changedMembers v v' ↔ v i ≠ v' i := by
  ...
```

```lean
theorem not_mem_changedMembers_of_eq
    {n m : ℕ} {v v' : Fin n → Fin m} {i : Fin n}
    (h : v i = v' i) :
    i ∉ changedMembers v v' := by
  ...
```

```lean
theorem voteCount_eq_on_unchanged
    {n m : ℕ} (v v' : Fin n → Fin m) (y : Fin m) :
    ((Finset.univ.erase? ???) -- if useful
```

But do not over-engineer this; the key deliverable is the gap-based plurality theorem.

---

### Significance for the research program

This result is the correct next step in the tropical Satake robustness line because it upgrades **certified robustness from a single GL3 Hecke-score classifier to an ensemble mechanism**. The new content is not just a repackaging of existing single-model top-k stability:

- the theorem isolates a **discrete plurality margin principle** that is independent of the analytic details of tropical Satake;
- it shows how **memberwise certified radii compose nontrivially at committee level** through the cardinality of the unstable-member set;
- it yields a reusable abstraction for future ensemble constructions, including weighted committees, ECOC-style tropical decoders, and hierarchical decision rules.

Mathematically, the important novelty is the passage from **continuous margin certificates** to a **combinatorial winner-invariance theorem** via pairwise vote-gap control. This is the right structural theorem for later extensions to weighted plurality, top-`ℓ` committee outputs, and more general tropical Hecke voting schemes.

The strongest version to prioritize is the abstract theorem
`committee_plurality_robust_of_member_certificates`
together with at least one clean GL3 tropical Satake specialization showing that the abstract hypotheses are actually discharged by the existing catalog theorems.

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
