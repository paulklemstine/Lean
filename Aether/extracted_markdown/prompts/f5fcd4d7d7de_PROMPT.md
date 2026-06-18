## Research Task: GL3 tropical Satake certified robustness for one-vs-rest Hecke score classifiers

Research Mode: PROVE

Work in a new file
`Bridges/GL3/TropicalSatakeOneVsRestRobustness.lean`.

The goal is to formalize a genuinely multiclass certified robustness theorem for GL3 tropical Satake / Hecke-score classifiers under the one-vs-rest decision rule. The intended theorem is not just a generic argmax stability lemma: it should explicitly connect the GL3 Hecke-score realization to the tropical certified-robustness radius already proved for binary score differences, and show that the same quantitative constant `2 * K * d` governs the multiclass certificate.

### Core objects and target theorem

Assume:
- a finite class index type `C` with `[Fintype C] [DecidableEq C]`,
- an input dimension `n : ℕ`,
- class scores `S : C → (Fin n → ℝ) → ℝ`,
- constants `K d : ℝ`,
- a distinguished true/predicted label `y : C`.

Define the one-vs-rest margins at `x` by
```lean
def ovrMargin {C : Type*} [Fintype C] [DecidableEq C]
    (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ) : ℝ :=
  (Finset.univ.erase y).inf' (by
    simpa using Finset.card_erase_pos.2 (Fintype.card_pos_iff.2 ⟨y⟩))
    (fun c => S y x - S c x)
```
or an equivalent nonempty-finset formulation.

Also define the prediction relation
```lean
def predicts {C : Type*} (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ) : Prop :=
  ∀ c, S c x ≤ S y x
```
so that ties are allowed but `y` is a maximizer. This is the cleanest notion for a certified theorem; if you want a strict argmax corollary, derive it afterward under strict positivity of all margins.

The main theorem should have essentially the following shape:
```lean
theorem gl3_ovr_certified_radius
    {C : Type*} [Fintype C] [DecidableEq C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ)
    (K d : ℝ)
    (hKd : 0 < 2 * K * d)
    (hLip : ∀ a b : C, a ≠ b →
      ∀ x z : Fin n → ℝ,
        |((S a x - S b x) - (S a z - S b z))| ≤ (2 * K * d) * ‖x - z‖∞)
    {y : C} {x : Fin n → ℝ}
    (hpred : predicts S y x)
    (hmargin : 0 < ovrMargin S y x) :
    ∀ δ : Fin n → ℝ,
      ‖δ‖∞ < ovrMargin S y x / (2 * K * d) →
      predicts S y (x + δ)
```
where `‖·‖∞` can be instantiated using whatever sup-norm convention already appears in the robustness library. If the existing library phrases perturbations as `z` with `dist∞ x z < ...`, adapt the statement to that API rather than forcing pointwise addition.

A more directly usable variant, likely closer to the existing binary robustness theorem, is:
```lean
theorem gl3_ovr_certified_radius'
    {C : Type*} [Fintype C] [DecidableEq C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ)
    (K d : ℝ)
    (y : C) (x z : Fin n → ℝ)
    (hLip : ∀ c, c ≠ y →
      |((S y z - S c z) - (S y x - S c x))| ≤ (2 * K * d) * ‖z - x‖∞)
    (hmargin : 0 < ovrMargin S y x)
    (hz : ‖z - x‖∞ < ovrMargin S y x / (2 * K * d)) :
    predicts S y z
```
This formulation is often easier to prove because it avoids algebra around `x + δ`.

### GL3-specific bridge theorem

To ensure this is genuinely in the GL3 tropical Satake line, prove a bridge theorem showing that the Hecke/Satake score coordinates satisfy the pairwise Lipschitz hypothesis needed above. The exact names should match the existing GL3 file, but the target shape should be something like:
```lean
theorem gl3_satake_pairwise_diff_lipschitz
    {C : Type*} [Fintype C] [DecidableEq C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ)
    (hSatake : IsGL3TropicalSatakeFamily S K d) :
    ∀ a b : C, a ≠ b →
      ∀ x z : Fin n → ℝ,
        |((S a x - S b x) - (S a z - S b z))| ≤ (2 * K * d) * ‖x - z‖∞
```
If the library already has a per-class Lipschitz theorem
```lean
|S c x - S c z| ≤ (K * d) * ‖x - z‖∞
```
then the pairwise result should be obtained by the triangle inequality:
```lean
|((S a x - S b x) - (S a z - S b z))|
= |(S a x - S a z) - (S b x - S b z)|
≤ |S a x - S a z| + |S b x - S b z|
≤ (K*d)‖x-z‖∞ + (K*d)‖x-z‖∞
= (2*K*d)‖x-z‖∞.
```
This is the key quantitative bridge: multiclass robustness depends on score differences, not individual scores, and you need the exact `2*K*d` constant to match the binary certified-radius formula.

### Intermediate lemmas worth formalizing

Prove these lemmas explicitly; they should make the final theorem modular and reusable.

1. **Margin unpacking from finite infimum**
```lean
lemma lt_ovrMargin_iff
    {C : Type*} [Fintype C] [DecidableEq C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ) (t : ℝ) :
    t < ovrMargin S y x ↔ ∀ c, c ≠ y → t < S y x - S c x
```
and the weaker corollary
```lean
lemma ovrMargin_le_pair
    ...
    (c : C) (hc : c ≠ y) :
    ovrMargin S y x ≤ S y x - S c x
```
These are the finite-minimum facts needed to pass from the global margin to each binary subproblem.

2. **Prediction from positive pairwise margins**
```lean
lemma predicts_of_pairwise_nonneg
    {C : Type*} [Fintype C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ) (y : C) (x : Fin n → ℝ)
    (h : ∀ c, S c x ≤ S y x) :
    predicts S y x := h
```
and more usefully
```lean
lemma predicts_of_margin_nonneg
    ...
    (h : ∀ c, c ≠ y → 0 ≤ S y x - S c x) :
    predicts S y x
```
This converts the binary conclusions back into a multiclass argmax statement.

3. **Binary certificate applied to each class**
```lean
lemma pairwise_robust_against_class
    {n : ℕ}
    (f : (Fin n → ℝ) → ℝ)
    (K d : ℝ)
    (hLip : ∀ x z, |f z - f x| ≤ (2 * K * d) * ‖z - x‖∞)
    {x z : Fin n → ℝ}
    (hfx : 0 < f x)
    (hz : ‖z - x‖∞ < f x / (2 * K * d)) :
    0 < f z ∨ 0 ≤ f z
```
Ideally instantiate this directly from the existing binary robustness theorem rather than reproving it from scratch. Then specialize `f` to `fun x => S y x - S c x`.

4. **Intersection of pairwise safe regions**
```lean
lemma predicts_of_all_pairwise_certified
    {C : Type*} [Fintype C] [DecidableEq C]
    {n : ℕ}
    (S : C → (Fin n → ℝ) → ℝ) (y : C) (x z : Fin n → ℝ)
    (h : ∀ c, c ≠ y → 0 ≤ S y z - S c z) :
    predicts S y z
```
This is the final “one-vs-rest reduction” lemma.

### Suggested proof strategy

1. **Establish pairwise difference Lipschitz bounds from the GL3 Satake score family.**  
   Use the existing GL3 tropical Satake realization to obtain per-class Lipschitz estimates, then prove the pairwise bound by rewriting
   ```lean
   (S a x - S b x) - (S a z - S b z)
   = (S a x - S a z) - (S b x - S b z)
   ```
   and applying `abs_sub_le` / triangle inequality. This is the nontrivial bridge from the representation-theoretic construction to the robustness API.

2. **Relate the global one-vs-rest margin to each pairwise margin.**  
   Unfold `ovrMargin` as an infimum over `Finset.univ.erase y`. From `0 < ovrMargin S y x`, derive
   ```lean
   0 < S y x - S c x
   ```
   for every `c ≠ y`. You will likely need `Finset.inf'_le` and a small lemma identifying membership in `erase`.

3. **Apply the existing binary certified robustness theorem to each score difference.**  
   For fixed `c ≠ y`, set
   ```lean
   Δ_c t := S y t - S c t.
   ```
   The previous step gives `0 < Δ_c x`, and the pairwise Lipschitz bridge gives the required quantitative bound with constant `2 * K * d`. The radius hypothesis
   ```lean
   ‖z - x‖∞ < ovrMargin S y x / (2 * K * d)
   ```
   is stronger than
   ```lean
   ‖z - x‖∞ < (S y x - S c x) / (2 * K * d),
   ```
   because `ovrMargin S y x ≤ S y x - S c x`. Feed this into the binary theorem to conclude
   ```lean
   0 ≤ S y z - S c z.
   ```

4. **Intersect the binary conclusions over all `c ≠ y`.**  
   Since for each competitor `c` we have `S c z ≤ S y z`, conclude `predicts S y z`. Handle the case `c = y` trivially.

5. **Derive a clean corollary in radius form.**  
   Package the previous theorem as the standard certified radius statement:
   ```lean
   r = ovrMargin S y x / (2 * K * d)
   ```
   certifies that every perturbation inside the open `∞`-ball of radius `r` preserves the predicted label `y`. This is the exact multiclass analogue of the existing binary radius formula.

### Useful Lean design choices

- If `Finset.inf'` causes friction, define the margin equivalently as
  ```lean
  sInf ((Set.range fun c : {c // c ≠ y} => S y x - S c.1 x))
  ```
  only if the order-theoretic lemmas are easier. But `Finset.inf'` is preferable for finite-class computability.
- It may be cleaner to work with
  ```lean
  predicts S y x := y ∈ Finset.argmax (fun c => S c x) Finset.univ
  ```
  only if an argmax API is already in place. Otherwise the “maximizer” predicate `∀ c, S c x ≤ S y x` will be much easier.
- Keep all constants in `ℝ`; avoid coercion noise from `ℕ` unless the GL3 side naturally indexes dimensions by naturals.
- If the existing robustness theorem is stated using `dist`, add a lemma comparing that metric to the library’s sup norm notation and then restate the theorem in your preferred coordinate form.

### Significance

This theorem upgrades the tropical certified-robustness program from binary and committee-style constructions to a canonical multiclass reduction that is actually compatible with the GL3 tropical Satake/Hecke formalization. The point is not merely that “argmax is stable under margins” — that is folklore — but that the specific Hecke-score coordinates arising from the tropical Langlands side preserve the exact quantitative Lipschitz envelope needed for a sharp radius
```lean
ovrMargin S y x / (2 * K * d).
```
That gives a mathematically internal certified robustness theorem for GL3 score systems, and it provides the base case for future extensions to richer multiclass aggregation rules and eventually tropical Hecke-algebraic classifiers beyond GL3.

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
