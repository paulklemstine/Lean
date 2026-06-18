## YOUR ASSIGNMENT: Tropical kernel mean embedding for maxitive measures via idempotent RKHS reconstruction and witness separation

Work first in the fully discrete finite setting, where the mathematics is already nontrivial and the Lean realization can be made robust and reusable. The core object is the max-plus analogue of a kernel mean embedding: it sends a weight/capacity profile `w : α → WithBot ℝ` to the tropical potential
\[
m_w(y) = \sup_x \bigl(w(x) + k(x,y)\bigr).
\]
This is the idempotent shadow of classical kernel mean embedding, but here reconstruction must proceed through residuation rather than linear duality. If you make this precise and prove injective reconstruction under a tropical separating kernel hypothesis, you will have created a formal bridge between maxitive measure theory, tropical functional analysis, and algorithmic statistical comparison.

### Core definitions to implement

Use a finite type first:
```lean
import Mathlib

open scoped BigOperators

def tropKME {α : Type*} [Fintype α] (k : α → α → WithBot ℝ) (w : α → WithBot ℝ) :
    α → WithBot ℝ :=
  fun y => ⨆ x, w x + k x y
```

For algorithmic finite support / witness extraction, also define a `Finset` version:
```lean
def tropKMEFinset {α : Type*} [DecidableEq α]
    (s : Finset α) (k : α → α → WithBot ℝ) (w : α → WithBot ℝ) :
    α → WithBot ℝ :=
  fun y => s.sup fun x => w x + k x y
```

You will need a tropical residuation operator. In `WithBot ℝ`, subtraction is partial at `⊥`, so define the clean order-theoretic version first:
```lean
def tropResiduatedBy {α : Type*} [Fintype α]
    (k : α → α → WithBot ℝ) (m : α → WithBot ℝ) : α → WithBot ℝ :=
  fun x => ⨅ y, m y - k x y
```
If subtraction on `WithBot ℝ` is awkward in the current library, define a custom residual predicate instead of forcing arithmetic too early:
```lean
def IsTropResidualUpper {α : Type*} [Fintype α]
    (k : α → α → WithBot ℝ) (w m : α → WithBot ℝ) : Prop :=
  ∀ x, w x ≤ ⨅ y, m y - k x y
```
and only later package the actual residual function once the arithmetic interface is stable.

The correct structural notion is not merely “positive definite” but a tropical separation/reconstruction axiom. A useful first class is:
```lean
structure TropSeparatingKernel (α : Type*) [Fintype α] where
  k : α → α → WithBot ℝ
  reconstruct :
    ∀ w : α → WithBot ℝ, ∀ x,
      w x = ⨅ y, (tropKME k w y) - k x y
```
This is the exact idempotent analogue of perfect reconstruction by kernel profiles. If this is too strong as a primitive structure, weaken it to `≤` plus a converse witness property and derive equality.

A more constructive alternative, often easier to verify in examples, is:
```lean
structure TropWitnessSeparatingKernel (α : Type*) [Fintype α] where
  k : α → α → WithBot ℝ
  upper_residuation :
    ∀ w x, w x ≤ ⨅ y, (tropKME k w y) - k x y
  witness :
    ∀ w x, ∃ y, (tropKME k w y) - k x y ≤ w x
```
Then reconstruction follows by `le_antisymm`.

### Precise theorem targets

Prove the following finite-type theorems with exact Lean signatures as close as possible to:

```lean
theorem tropKME_mono {α : Type*} [Fintype α]
    {k : α → α → WithBot ℝ} {w₁ w₂ : α → WithBot ℝ}
    (h : ∀ x, w₁ x ≤ w₂ x) :
    ∀ y, tropKME k w₁ y ≤ tropKME k w₂ y := by
```

```lean
theorem tropKME_le_iff {α : Type*} [Fintype α]
    {k : α → α → WithBot ℝ} {w : α → WithBot ℝ} {m : α → WithBot ℝ}
    (h : ∀ y, tropKME k w y ≤ m y) :
    ∀ x, w x ≤ ⨅ y, m y - k x y := by
```
This is the basic residuation upper bound. It is the key order-theoretic lemma: every upper bound on the embedding induces a pointwise upper bound on the original weights through residual inversion.

Then specialize:
```lean
theorem tropKME_residuation_upper {α : Type*} [Fintype α]
    {k : α → α → WithBot ℝ} {w : α → WithBot ℝ} :
    ∀ x, w x ≤ ⨅ y, tropKME k w y - k x y := by
```

Under the witness-separating or reconstructing kernel hypothesis, prove exact recovery:
```lean
theorem tropKME_reconstruct {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) (w : α → WithBot ℝ) :
    ∀ x, w x = ⨅ y, tropKME K.k w y - K.k x y := by
```

Then derive injectivity:
```lean
theorem tropKME_injective {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) :
    Function.Injective (tropKME K.k) := by
```

A pointwise extensional version is also valuable:
```lean
theorem tropKME_eq_iff {α : Type*} [Fintype α]
    (K : TropSeparatingKernel α) {w₁ w₂ : α → WithBot ℝ} :
    tropKME K.k w₁ = tropKME K.k w₂ ↔ w₁ = w₂ := by
```

For witness separation, prove a constructive finite version:
```lean
theorem tropKME_witness_separation {α : Type*} [Fintype α] [DecidableEq α]
    (K : TropWitnessSeparatingKernel α) {w₁ w₂ : α → WithBot ℝ}
    (hneq : w₁ ≠ w₂) :
    ∃ y, tropKME K.k w₁ y ≠ tropKME K.k w₂ y := by
```
and, stronger, if possible:
```lean
theorem tropKME_witness_strict {α : Type*} [Fintype α] [DecidableEq α]
    (K : TropWitnessSeparatingKernel α) {w₁ w₂ : α → WithBot ℝ}
    {x : α} (hx : w₁ x < w₂ x) :
    ∃ y, tropKME K.k w₁ y - K.k x y < tropKME K.k w₂ y - K.k x y := by
```

Finally, give an algorithmic finite-support comparison theorem using `Finset.sup`:
```lean
theorem tropKMEFinset_eq_tropKME_of_univ {α : Type*} [Fintype α] [DecidableEq α]
    (k : α → α → WithBot ℝ) (w : α → WithBot ℝ) :
    tropKMEFinset Finset.univ k w = tropKME k w := by
```

If there is already infrastructure for finitely supported maxitive measures or discrete capacities, define a bridge map:
```lean
def weightOfCapacity ... : α → WithBot ℝ := ...
```
and prove a transfer theorem of the form:
```lean
theorem tropKME_of_capacity_eq
    ... :
    tropKME k (weightOfCapacity μ) = ... := by
```
The exact target should match the existing EML/maxitive encoding in the library.

### Three proof routes: choose the strongest, but build fallback infrastructure

#### Strategy A: Pure order-residuation route — most promising
This is the cleanest and most reusable route. The main inequality
\[
w(x) \le \inf_y (m(y)-k(x,y))
\]
whenever
\[
\sup_x(w(x)+k(x,y)) \le m(y)
\]
is the tropical analogue of adjunction. In Lean, prove it pointwise:

1. Fix `x` and `y`.
2. Show `w x + k x y ≤ tropKME k w y` by `le_iSup`.
3. Compose with the assumed bound `tropKME k w y ≤ m y`.
4. Rearrange to obtain `w x ≤ m y - k x y`.
5. Infimize over `y`.

This route is ideal because it isolates all subtle arithmetic into one lemma about `WithBot ℝ`:
```lean
lemma le_sub_of_add_le {a b c : WithBot ℝ} (h : a + b ≤ c) : a ≤ c - b := ...
```
If this exact lemma is absent, prove or localize a variant. This single arithmetic bridge is the fulcrum of the whole development.

#### Strategy B: Galois connection packaging
Define operators
```lean
def Φ (w : α → WithBot ℝ) : α → WithBot ℝ := tropKME k w
def Ψ (m : α → WithBot ℝ) : α → WithBot ℝ := fun x => ⨅ y, m y - k x y
```
Then prove the adjunction:
```lean
theorem trop_galois :
  Φ w ≤ m ↔ w ≤ Ψ m
```
(pointwise order on functions). After this, `tropKME_residuation_upper` is just the `→` direction applied to `m = Φ w`, and reconstruction is `w = Ψ (Φ w)` under your kernel hypothesis. This is conceptually superior: it turns tropical KME into a closure/interior theory and opens the door to a full idempotent RKHS calculus. If feasible, this is the statement with the highest long-term payoff.

#### Strategy C: Matrix/max-plus linear algebra on finite types
For finite `α`, regard `k` as a max-plus matrix and `tropKME k w` as matrix-vector multiplication in the dioid sense. Reconstruction becomes exact left-residuation. This route is particularly useful if the library already has matrix support easier than generic lattice manipulations. It also gives an algorithmic path immediately: witness separation can be realized by scanning the finite codomain and checking where the profile differs. Use this route if `WithBot ℝ` arithmetic interacts better with finite `Finset.sup` than with `iSup/iInf`.

### Concrete proof steps and key lemmas

1. **Monotonicity of embedding**
   Prove for each fixed `y`:
   ```lean
   have hx : ∀ x, w₁ x + k x y ≤ w₂ x + k x y := ...
   exact iSup_le fun x => le_trans (hx x) (le_iSup (fun x => w₂ x + k x y) x)
   ```
   or the corresponding `Finset.sup` version.
   This gives `tropKME_mono`.

2. **Pointwise lower contribution lemma**
   Prove:
   ```lean
   theorem le_tropKME_of_mem {α : Type*} [Fintype α]
       (k : α → α → WithBot ℝ) (w : α → WithBot ℝ) (x y : α) :
       w x + k x y ≤ tropKME k w y := by
   ```
   This lemma will be reused everywhere.

3. **Residual upper bound**
   From `le_tropKME_of_mem` and a hypothesis `tropKME k w y ≤ m y`, derive
   `w x + k x y ≤ m y`, then rearrange. The only real technical point is subtraction in `WithBot ℝ`. If direct subtraction is brittle, first prove a predicate version:
   ```lean
   theorem tropKME_residual_pointwise
       (h : ∀ y, tropKME k w y ≤ m y) :
       ∀ x y, w x ≤ m y - k x y := by
   ```
   and then take `iInf`.

4. **Reconstruction from witness-separation**
   If your kernel structure gives `upper_residuation` and a witness `y` with reverse inequality, prove
   ```lean
   have h₁ : w x ≤ ⨅ y, tropKME k w y - k x y := ...
   have h₂ : (⨅ y, tropKME k w y - k x y) ≤ w x := by
     rcases K.witness w x with ⟨y, hy⟩
     exact le_trans (iInf_le _ y) hy
   exact le_antisymm h₂ h₁
   ```
   This is the cleanest path to exact equality.

5. **Injectivity**
   If `h : tropKME K.k w₁ = tropKME K.k w₂`, reconstruct both sides:
   ```lean
   funext x
   calc
     w₁ x = ⨅ y, tropKME K.k w₁ y - K.k x y := K.reconstruct w₁ x
     _ = ⨅ y, tropKME K.k w₂ y - K.k x y := by simp [h]
     _ = w₂ x := (K.reconstruct w₂ x).symm
   ```
   This should be almost immediate once reconstruction is available.

6. **Witness separation from injectivity**
   On finite types, the negation of pointwise witness existence implies equality:
   ```lean
   by_contra hnowit
   have hEqProf : tropKME K.k w₁ = tropKME K.k w₂ := by
     funext y
     by_cases hy : tropKME K.k w₁ y = tropKME K.k w₂ y
     · exact hy
     · exact False.elim (hnowit ⟨y, hy⟩)
   exact hneq (K.injective hEqProf)
   ```
   If desired, refine to a strict witness using an `x` with strict inequality in the source.

### Kernel classes worth formalizing as examples

Do not leave the theory abstract only. Exhibit at least one nontrivial kernel class.

A very promising finite kernel is the tropical Kronecker kernel:
```lean
def tropDeltaKernel [DecidableEq α] (c d : WithBot ℝ) : α → α → WithBot ℝ
| x, y => if x = y then c else d
```
Under the strict diagonal dominance hypothesis `d < c`, the embedding becomes
\[
m_w(y)=\max(w(y)+c,\ \sup_{x\neq y}(w(x)+d)),
\]
which should allow exact reconstruction in many regimes. Formalize the sharp condition under which reconstruction holds. This gives the first explicit family of separating tropical kernels and is algorithmically transparent.

A theorem of the following flavor would be excellent:
```lean
theorem tropDeltaKernel_separating
    {α : Type*} [Fintype α] [DecidableEq α]
    {c d : WithBot ℝ} (hcd : d < c) :
    TropWitnessSeparatingKernel α := ...
```
If full generality is too hard, prove it under finite anti-collision assumptions on `w`, or for `α = Fin n`. Even this special case is already meaningful: it gives a certified explicit tropical kernel family with injective KME.

### Bridge to maxitive/EML functionals

Once the discrete finite theory is stable, connect it to existing maxitive/EML constructions. The conceptual theorem to aim for is:

- every discrete maxitive capacity / idempotent EML functional represented by a weight profile `w`
- has a tropical kernel profile `tropKME k w`
- and equality of these profiles implies equality of the underlying capacity/functional.

Formally, if the library has a representation theorem turning a discrete functional into pointwise weights, prove a transfer statement:
```lean
theorem tropKME_injective_on_discrete_functionals
    (K : TropSeparatingKernel α) :
    Function.Injective (fun μ => tropKME K.k (weightOfFunctional μ)) := by
```
This is where the result stops being a finite combinatorial exercise and becomes a new machine-learning / EML primitive: an idempotent statistical signature of maxitive measures.

### Why this matters

This theorem package creates the first formalized kernel technology for idempotent probability-like objects. In ordinary statistical learning, kernel mean embeddings turn measures into functions and make comparison, testing, and representation learning possible. Your tropical version does the same for maxitive capacities and idempotent linear functionals, but the geometry is entirely different: reconstruction is governed by residuation, not Hilbert orthogonality. That is the breakthrough.

If successful, this opens at least four research fronts immediately:

1. **Tropical MMD / witness metrics**: define a max-plus discrepancy between capacities via their kernel profiles.
2. **Idempotent statistical learning**: compare uncertain systems governed by sup-type aggregation rather than expectation.
3. **EML representation theory**: identify which idempotent functionals are kernel-representable and classify separating kernels.
4. **Algorithmic tropical inference**: finite witness extraction gives actual decision procedures for nonequality of maxitive laws.

This is not a variant of classical KME. It is a new formal language for “learning with supremum-based uncertainty,” and it fits naturally with tropical optimization, robust control, morphological signal processing, and energy landscape models.

### If full reconstruction is too hard

Prove the strongest ladder you can:

1. `tropKME_mono`
2. `tropKME_residuation_upper`
3. the Galois implication `tropKME k w ≤ m → w ≤ Ψ m`
4. injectivity for an explicit kernel family such as `tropDeltaKernel`
5. finite witness extraction for that explicit family

State any remaining conjecture precisely, for example:
```lean
conjecture trop_separating_iff_reconstructive
    {α : Type*} [Fintype α] (k : α → α → WithBot ℝ) :
    (∀ w₁ w₂, tropKME k w₁ = tropKME k w₂ → w₁ = w₂) ↔
    (∀ w x, w x = ⨅ y, tropKME k w y - k x y)
```
This equivalence would be a foundational theorem for tropical kernel theory.

### Deliverables

Implement the core definitions, prove the monotonicity/residuation/reconstruction/injectivity chain, provide at least one explicit separating kernel family, and include a finite witness algorithm based on `Finset.sup` or exhaustive search over `Finset.univ`.

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:
- tropical MMD and witness pseudometric on finite maxitive measures,
- universal/characteristic tropical kernels,
- compact-space extension from finite `α` via upper semicontinuous weights,
- links to morphological convolutions and tropical neural feature maps,
- a categorical adjunction between maxitive measures and tropical kernel profiles.

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
