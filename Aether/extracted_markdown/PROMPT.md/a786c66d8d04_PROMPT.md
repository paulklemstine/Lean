## Research Task: Tropical certified robustness for multiclass piecewise-linear networks under lexicographic top-2 decision via ordered logit-gap margins

Research Mode: PROVE

Work with a finite class set `Fin C` over `ℝ`, with `C ≥ 2`. Let `f : Fin C → (Fin d → ℝ) → ℝ` be the score family, so for each class `i`, `f i` is the class-score map. The target is to formalize a certified `L∞` robustness theorem for the *ordered top-2 outcome* `(a,b)` consisting of the winner and runner-up, under a deterministic tie-free strict-margin hypothesis.

The main point is that ordered top-2 stability is not the same as ordinary argmax stability: one must simultaneously preserve (i) that `a` remains above all other classes and (ii) that among the non-`a` classes, `b` remains above all remaining competitors. This gives a finite system of strict inequalities, and the correct certificate is the minimum slack over that system. The proof should reduce robustness to preservation of these inequalities under perturbation, using Lipschitz bounds for score differences.

### Core definitions to introduce

Use the ambient norm
```lean
def linfNorm {d : ℕ} (x : Fin d → ℝ) : ℝ := ‖x‖∞
```
or directly `‖x‖∞` if convenient in Mathlib.

Define score differences:
```lean
def scoreDiff {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ) (i j : Fin C) :
    (Fin d → ℝ) → ℝ :=
  fun x => f i x - f j x
```

Define the strict ordered-top-2 predicate:
```lean
def IsOrderedTop2 {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a b : Fin C) (x : Fin d → ℝ) : Prop :=
  a ≠ b ∧
  (∀ j, j ≠ a → f a x > f j x) ∧
  (∀ j, j ≠ a → j ≠ b → f b x > f j x)
```

This formulation already forces uniqueness of the ordered pair `(a,b)`: `a` is the unique maximizer, and `b` is the unique maximizer among classes distinct from `a`.

Define the ordered gap margin:
```lean
def orderedTop2Margin {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a b : Fin C) (x : Fin d → ℝ) : ℝ :=
  min
    (Finset.inf' (Finset.univ.filter fun j => j ≠ a)
      (by
        have : (Finset.univ.filter fun j : Fin C => j ≠ a).Nonempty := by
          -- requires C ≥ 2 and a witness b ≠ a
          sorry
        exact this)
      (fun j => f a x - f j x))
    (Finset.inf' (Finset.univ.filter fun j => j ≠ a ∧ j ≠ b)
      (by
        -- requires existence of some third class if used literally;
        -- better to avoid this issue by defining a one-sided theorem first for C ≥ 3,
        -- or by special-casing C = 2 where second conjunct is vacuous.
        sorry)
      (fun j => f b x - f j x))
```

However, because `Finset.inf'` on the second set is awkward when `C = 2`, it is better to use one of these two routes:

1. **Main theorem for `C ≥ 3`**, where both filtered sets are nonempty; or  
2. Define the margin by a `sInf`/`iInf` over a finite set with a default convention, then separately prove simplifications under `C ≥ 3`.

The cleanest formal target is probably `C ≥ 3`. If you want a fully uniform theorem, define:
```lean
def winnerMargin {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a : Fin C) (x : Fin d → ℝ) : ℝ :=
  Finset.inf' (Finset.univ.filter fun j => j ≠ a)
    (by sorry)
    (fun j => f a x - f j x)

def runnerUpMargin {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a b : Fin C) (x : Fin d → ℝ) : ℝ :=
  Finset.inf' (Finset.univ.filter fun j => j ≠ a ∧ j ≠ b)
    (by sorry)
    (fun j => f b x - f j x)

def orderedTop2Margin {C d : ℕ} (f : Fin C → (Fin d → ℝ) → ℝ)
    (a b : Fin C) (x : Fin d → ℝ) : ℝ :=
  min (winnerMargin f a x) (runnerUpMargin f a b x)
```

### Precise theorem statements

A good sequence is:

```lean
theorem isOrderedTop2_iff_pairwise
    {C d : ℕ} {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ} :
    IsOrderedTop2 f a b x ↔
      a ≠ b ∧
      (∀ j, j ≠ a → 0 < scoreDiff f a j x) ∧
      (∀ j, j ≠ a → j ≠ b → 0 < scoreDiff f b j x) := by
  ...
```

This is the bridge lemma: preserving the ordered top-2 decision is equivalent to preserving a finite family of positive score differences.

Then prove a perturbation lemma for one inequality family:

```lean
theorem scoreDiff_positive_on_linf_ball
    {d : ℕ} {g : (Fin d → ℝ) → ℝ} {x δ : Fin d → ℝ} {K m : ℝ}
    (hLip : ∀ y z, |g y - g z| ≤ K * (d : ℝ) * ‖y - z‖∞)
    (hmargin : m ≤ g x)
    (hK : 0 ≤ K)
    (hδ : ‖δ‖∞ < m / ((2 : ℝ) * (d : ℝ) * K)) :
    0 < g (x + δ) := by
  ...
```

In practice, the statement you actually need is simpler and avoids introducing `m` separately:

```lean
theorem scoreDiff_stays_positive_of_linf_bound
    {d : ℕ} {g : (Fin d → ℝ) → ℝ} {x δ : Fin d → ℝ} {K : ℝ}
    (hLip : ∀ y z, |g y - g z| ≤ K * (d : ℝ) * ‖y - z‖∞)
    (hK : 0 ≤ K)
    (hx : 0 < g x)
    (hδ : ‖δ‖∞ < g x / ((2 : ℝ) * (d : ℝ) * K)) :
    0 < g (x + δ) := by
  ...
```

Then formulate a finite-margin version for all relevant score differences:

```lean
theorem orderedTop2_stable_of_margin
    {C d : ℕ} (hC : 3 ≤ C)
    {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x δ : Fin d → ℝ} {Keff : ℝ}
    (hord : IsOrderedTop2 f a b x)
    (hKeff : 0 ≤ Keff)
    (hLip :
      ∀ i j, i ≠ j →
        ∀ y z, |scoreDiff f i j y - scoreDiff f i j z|
          ≤ Keff * (d : ℝ) * ‖y - z‖∞)
    (hδ :
      ‖δ‖∞ < orderedTop2Margin f a b x / ((2 : ℝ) * (d : ℝ) * Keff)) :
    IsOrderedTop2 f a b (x + δ) := by
  ...
```

A slightly more flexible version is to allow different constants `Kij` and then take a finite maximum:

```lean
def diffLipConst {C : ℕ} (L : Fin C → Fin C → ℝ) : ℝ :=
  Finset.sup Finset.univ (fun i => Finset.sup Finset.univ (fun j => L i j))
```

but for a first theorem, a uniform `Keff` is cleaner.

You should also prove positivity of the margin from the ordered-top-2 hypothesis:

```lean
theorem orderedTop2Margin_pos
    {C d : ℕ} (hC : 3 ≤ C)
    {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ}
    (hord : IsOrderedTop2 f a b x) :
    0 < orderedTop2Margin f a b x := by
  ...
```

Finally, derive the robustness corollary in a “ball” form:

```lean
theorem orderedTop2_certified_radius
    {C d : ℕ} (hC : 3 ≤ C)
    {f : Fin C → (Fin d → ℝ) → ℝ}
    {a b : Fin C} {x : Fin d → ℝ} {Keff r : ℝ}
    (hord : IsOrderedTop2 f a b x)
    (hKeff : 0 ≤ Keff)
    (hLip :
      ∀ i j, i ≠ j →
        ∀ y z, |scoreDiff f i j y - scoreDiff f i j z|
          ≤ Keff * (d : ℝ) * ‖y - z‖∞)
    (hr : r < orderedTop2Margin f a b x / ((2 : ℝ) * (d : ℝ) * Keff)) :
    ∀ δ, ‖δ‖∞ ≤ r → IsOrderedTop2 f a b (x + δ) := by
  ...
```

If the factor `(d : ℝ)` is already built into your catalog’s `L∞` certificate, remove it and state the radius as `margin / (2 * Keff)` instead. But if the existing tropical Lipschitz result is of the form `|g(x)-g(y)| ≤ K * ‖x-y‖₁`, then use the standard inequality `‖v‖₁ ≤ d * ‖v‖∞` to get exactly the requested denominator `(2 d Keff)`.

### Proof strategy

1. **Characterize ordered top-2 by strict score differences.**  
   Prove `isOrderedTop2_iff_pairwise`. This is mostly algebra:
   - `f a x > f j x ↔ 0 < f a x - f j x`
   - `f b x > f j x ↔ 0 < f b x - f j x`
   This lemma is conceptually central: the classifier’s decision is encoded by finitely many inequalities, so robustness reduces to maintaining positivity of a finite family of scalar functions.

2. **Define the finite margin as the minimum slack over those inequalities.**  
   Show that under `IsOrderedTop2 f a b x`, every term appearing in `winnerMargin` and `runnerUpMargin` is positive, hence `orderedTop2Margin f a b x > 0`. Use `Finset.inf'_le` and the standard finite-inf positivity argument:
   - prove every candidate gap is `> 0`
   - conclude the finite infimum is `> 0`
   This is the exact ordered analogue of the usual argmax min-gap certificate.

3. **Control score differences under perturbation via Lipschitz bounds.**  
   For each ordered constraint, apply the difference Lipschitz estimate to `g = scoreDiff f i j`:
   ```lean
   |g (x + δ) - g x| ≤ Keff * (d : ℝ) * ‖δ‖∞
   ```
   using `y = x + δ`, `z = x`, and simplify `‖(x + δ) - x‖∞ = ‖δ‖∞`.  
   Then from the radius assumption,
   ```lean
   Keff * (d : ℝ) * ‖δ‖∞ < orderedTop2Margin f a b x / 2
   ```
   so each relevant gap decreases by strictly less than half the minimum margin. Since each original gap is at least the minimum margin, the perturbed gap remains positive.

4. **Lift positivity of all relevant perturbed differences back to ordered-top-2.**  
   Apply `isOrderedTop2_iff_pairwise` at `x + δ`.  
   For winner constraints, show:
   ```lean
   0 < scoreDiff f a j (x + δ)
   ```
   for all `j ≠ a`.  
   For runner-up constraints, show:
   ```lean
   0 < scoreDiff f b j (x + δ)
   ```
   for all `j ≠ a`, `j ≠ b`.  
   This directly yields `IsOrderedTop2 f a b (x + δ)`.

5. **Optional strengthening: replace uniform `Keff` by a finite max over relevant pairwise Lipschitz constants.**  
   If you want a sharper theorem, define
   ```lean
   orderedTop2LipMax ...
   ```
   as the maximum over the finite set of relevant pairs `(a,j)` and `(b,j)`. Then the same proof goes through with `Keff` replaced by that maximum. This is mathematically more natural: only the score differences used in the certificate should contribute to the radius.

### Key technical lemmas likely needed in Lean

You will probably want explicit helper lemmas such as:

```lean
lemma sub_pos_iff_lt_add' {a b : ℝ} : 0 < a - b ↔ b < a := by linarith
lemma pos_of_ge_of_ne {a b : ℝ} (h₁ : a ≥ b) (h₂ : a ≠ b) : a > b := by linarith
```

For perturbations:
```lean
have hchange :
    |scoreDiff f i j (x + δ) - scoreDiff f i j x|
      ≤ Keff * (d : ℝ) * ‖δ‖∞ := by
  simpa [scoreDiff, sub_eq_add_neg, add_comm, add_left_comm, add_assoc]
    using hLip i j hij (x + δ) x
```

Then use
```lean
have hlower :
    scoreDiff f i j (x + δ) ≥ scoreDiff f i j x -
      Keff * (d : ℝ) * ‖δ‖∞ := by
  linarith [abs_le.mp hchange].1
```
and conclude positivity by comparing `scoreDiff f i j x` with `orderedTop2Margin f a b x`.

You may also need:
```lean
have hnorm : ‖(x + δ) - x‖∞ = ‖δ‖∞ := by
  simp
```

For finite infimum arguments over filtered `Finset.univ`, it may be cleaner to first prove:
```lean
theorem orderedTop2Margin_le_winner_gap
    ...
    (hj : j ≠ a) :
    orderedTop2Margin f a b x ≤ f a x - f j x := by
  ...
```
and similarly for runner-up gaps. Then the positivity proof is immediate from `hord`.

### Significance

This theorem is the correct ordered analogue of tropical/PL argmax certification. Existing robustness certificates for multiclass networks usually stabilize either:
- the single winning class,
- an unordered top-`k` set,
- or a monotone max/min aggregate.

But ordered top-2 prediction is strictly richer: it certifies not only the winner but also the identity of the nearest competitor, which is the minimal nontrivial ranking structure needed for abstention, selective classification, fallback routing, and hierarchical decision pipelines. In tropical terms, the theorem identifies the decision region for an ordered pair `(a,b)` as an intersection of finitely many half-space-type score-difference constraints and shows that the certified radius is exactly governed by the minimum slack of those constraints divided by the effective Lipschitz modulus of the difference network.

This also sets up a reusable formal pattern for later work:
- ordered top-`k` robustness via finite chains of pairwise inequalities,
- lexicographic decision rules in tropical semimodules,
- and certified ranking stability for piecewise-linear networks beyond plain classification.

If time permits, prove the sharper variant with pair-dependent constants and a finite maximum over only the relevant constraints; that version is likely the most useful downstream for compositional tropical certificates.

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
