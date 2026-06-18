## YOUR ASSIGNMENT: Functorial bisimulation pseudometric for reversible temporal circuits via Lawvere-enriched traced semiring semantics

### Core formalization target

Build a quantitative semantics layer on top of the existing traced idempotent semiring / guarded fixed-point infrastructure by defining a Lawvere-style pseudometric on circuit states and proving that it is the **least prefixed point** of a trace-lifting operator induced by the circuit semantics. The theorem should simultaneously deliver:

1. **existence** of the bisimulation pseudometric as a least fixed/prefixed point,
2. **functorial nonexpansiveness** of the semantic combinators,
3. **trace compatibility** for guarded feedback,
4. **finite-state computability** via monotone iteration.

The breakthrough is not merely “another metric on systems”: it is a **quantitative coinduction principle for reversible temporal circuits** internal to traced semiring semantics. This opens a path from exact equivalence to robust approximate equivalence, and connects reversible computation, enriched category theory, and algorithmic fixed-point computation.

---

## Precise definitions to introduce

Work with an extended nonnegative-cost codomain such as `ENNReal := ℝ≥0∞` unless the existing catalog already prefers `WithTop ℝ≥0`; if so, keep the latter consistently. Use `0` as exact behavioral equality and `⊤` as maximal separation.

Define a lightweight structure if no suitable one already exists:

```lean
structure LawverePseudoMetric (α : Type _) where
  dist : α → α → ℝ≥0∞
  refl : ∀ x, dist x x = 0
  triangle : ∀ x y z, dist x z ≤ dist x y + dist y z
```

If symmetry is available or desired for the target semantics, add it separately rather than baking it into the base structure:

```lean
def IsSymmetricLawvere (d : α → α → ℝ≥0∞) : Prop :=
  ∀ x y, d x y = d y x
```

Define the pointwise order on candidate distances:

```lean
def MetricPred (α : Type _) := α → α → ℝ≥0∞

instance : LE (MetricPred α) := ⟨fun d e => ∀ x y, d x y ≤ e x y⟩
```

Define the semantic lifting operator induced by one-step observations and transitions. A flexible finite-state version is:

```lean
def stepLift
    {σ ω : Type _}
    [Fintype σ] [DecidableEq σ]
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ) : MetricPred σ :=
  fun s t => obsDist (out s) (out t) ⊔ d (next s) (next t)
```

A richer branching/kernel version, if supported by the existing idempotent semantics, should replace `next : σ → σ` by a semiring-valued transition object and the recursive clause by a Kantorovich/Wasserstein-style lifting already present in the catalog.

For guarded feedback, define an operator abstractly if trace semantics already exists:

```lean
def traceLift
    {σ : Type _}
    (T : MetricPred σ → MetricPred σ)
    : MetricPred σ → MetricPred σ := T
```

The point is not the syntax of `traceLift`, but to prove that the traced feedback operator inherited from the semantic trace is monotone / Scott-continuous and preserves nonexpansiveness.

---

## Main theorem: least bisimulation pseudometric

Prove a theorem of the following shape first in a finite-state setting, then generalize if the infrastructure permits.

### Finite-state least prefixed point theorem

```lean
theorem exists_least_bisimulation_metric_finite
    {σ ω : Type _}
    [Fintype σ] [DecidableEq σ]
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_refl : ∀ w, obsDist w w = 0)
    (hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c)
    (out : σ → ω)
    (next : σ → σ) :
    ∃ d : MetricPred σ,
      (∀ s, d s s = 0) ∧
      (∀ s t u, d s u ≤ d s t + d t u) ∧
      (∀ s t, stepLift obsDist out next d s t ≤ d s t) ∧
      (∀ d' : MetricPred σ,
        (∀ s, d' s s = 0) →
        (∀ s t u, d' s u ≤ d' s t + d' t u) →
        (∀ s t, stepLift obsDist out next d' s t ≤ d' s t) →
        ∀ s t, d s t ≤ d' s t)
```

This states that `d` is the **least prefixed point among Lawvere pseudometrics** for the one-step behavioral transformer.

If fixed-point infrastructure is stronger, sharpen prefixed point to fixed point:

```lean
theorem least_fixed_bisimulation_metric_finite
    {σ ω : Type _}
    [Fintype σ] [DecidableEq σ]
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_refl : ∀ w, obsDist w w = 0)
    (hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c)
    (out : σ → ω)
    (next : σ → σ) :
    ∃ d : MetricPred σ,
      (∀ s t, stepLift obsDist out next d s t = d s t) ∧
      (∀ d' : MetricPred σ,
        (∀ s t, stepLift obsDist out next d' s t = d' s t) →
        ∀ s t, d s t ≤ d' s t)
```

### Compositional nonexpansiveness theorem

For semantic combinators already present in the traced circuit semantics, prove pointwise nonexpansiveness. Abstractly:

```lean
theorem seq_nonexpansive
    {α β γ : Type _}
    (dα : MetricPred α) (dβ : MetricPred β) (dγ : MetricPred γ)
    (f : α → β) (g : β → γ)
    (hf : ∀ x y, dβ (f x) (f y) ≤ dα x y)
    (hg : ∀ u v, dγ (g u) (g v) ≤ dβ u v) :
    ∀ x y, dγ (g (f x)) (g (f y)) ≤ dα x y
```

```lean
theorem prod_nonexpansive_sup
    {α β γ δ : Type _}
    (dα : MetricPred α) (dβ : MetricPred β)
    (dγ : MetricPred γ) (dδ : MetricPred δ)
    (f : α → γ) (g : β → δ)
    (hf : ∀ x y, dγ (f x) (f y) ≤ dα x y)
    (hg : ∀ x y, dδ (g x) (g y) ≤ dβ x y) :
    ∀ p q : α × β,
      (dγ (f p.1) (f q.1) ⊔ dδ (g p.2) (g q.2))
        ≤ (dα p.1 q.1 ⊔ dβ p.2 q.2)
```

For the traced combinator itself, prove a theorem in the strongest form your existing trace API permits:

```lean
theorem trace_nonexpansive
    {α β γ : Type _}
    (T : MetricPred (α × γ) → MetricPred (β × γ))
    (hmono : Monotone T)
    (hguarded : Guarded T) :
    ∃ tr : MetricPred α → MetricPred β,
      Monotone tr ∧
      ∀ d x y, tr d x y ≤ ?bound
```

If a concrete bound is available from the catalog’s diagonal/guarded fixed-point theorem, instantiate `?bound` explicitly. The real content is that **feedback preserves quantitative semantics** under guardedness.

### Iterative computation theorem

For finite `σ`, prove that the least pseudometric is computable by ascending iteration from the bottom metric:

```lean
def botMetric (σ : Type _) : MetricPred σ := fun _ _ => 0

def iterStep
    {σ ω : Type _}
    [Fintype σ] [DecidableEq σ]
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ) : ℕ → MetricPred σ
  | 0 => botMetric σ
  | n+1 => stepLift obsDist out next (iterStep obsDist out next n)
```

Then prove stabilization or convergence:

```lean
theorem iterStep_monotone
    {σ ω : Type _}
    [Fintype σ] [DecidableEq σ]
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (next : σ → σ) :
    ∀ n s t, iterStep obsDist out next n s t ≤ iterStep obsDist out next (n+1) s t
```

```lean
theorem least_metric_eq_iSup_iter
    {σ ω : Type _}
    [Fintype σ] [DecidableEq σ]
    (obsDist : ω → ω → ℝ≥0∞)
    (hout_refl : ∀ w, obsDist w w = 0)
    (hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c)
    (out : σ → ω)
    (next : σ → σ)
    (d : MetricPred σ)
    (hdleast : -- d is least prefixed/fixed point as above
      True) :
    ∀ s t, d s t = ⨆ n, iterStep obsDist out next n s t
```

If `iSup` over `ℕ` is awkward, prove the weaker but algorithmically useful approximation theorem:

```lean
theorem iterStep_least_metric
    {σ ω : Type _}
    [Fintype σ] [DecidableEq σ]
    ...
    : ∀ n s t, iterStep obsDist out next n s t ≤ d s t
```

and, when finite-height/order-continuity is available, prove eventual stabilization.

---

## Most promising proof architecture

### Strategy A: Order-theoretic fixed point on the complete lattice of distances
This is the primary route.

1. **Define the complete lattice of candidate distances**  
   Use the pointwise complete lattice structure on `σ → σ → ℝ≥0∞`. This should come almost for free from existing instances.
   Key lemma:
   ```lean
   theorem stepLift_monotone ... : Monotone (stepLift obsDist out next)
   ```

2. **Show closure of Lawvere axioms under the transformer**  
   Prove that if `d` is reflexive and satisfies triangle inequality, then so does `stepLift ... d`, or at least that the least prefixed point obtained by fixed-point machinery inherits these properties.
   Critical lemmas:
   ```lean
   theorem stepLift_refl ...
   theorem stepLift_triangle ...
   ```
   For `⊔`, triangle follows from distributivity of `≤` over `sup` plus `add_le_add`.

3. **Apply existing guarded/diagonal fixed-point theorem**  
   Use the catalog theorem giving least prefixed/fixed points for guarded traced operators. Instantiate it on the complete lattice of `MetricPred σ`.
   The clever intermediate result is:
   > the semantic transformer is not just monotone, but **Scott-continuous / guarded**, so the least bisimulation pseudometric is produced by the same traced fixed-point mechanism already used for qualitative reversible temporal semantics.

4. **Prove minimality among pseudometrics**  
   Once the fixed-point theorem yields a least prefixed point in the ambient lattice, prove it lies inside the pseudometric subspace and is least there by closure lemmas.

5. **Derive compositionality**  
   Show semantic combinators are monotone/nonexpansive by pointwise inequalities and then lift these to the least fixed point using minimality.

Why this is strongest: it directly fuses the catalog’s traced fixed-point semantics with quantitative behavioral reasoning and should generalize beyond the deterministic finite-state case.

---

### Strategy B: Coinductive metric as intersection of all post-fixed pseudometrics
Use a “largest bisimulation relation” analogy, but quantitative.

1. Define:
   ```lean
   def bisimBound : MetricPred σ := fun s t => ⨅ d' : MetricPred σ, ...
   ```
   where the infimum ranges over all pseudometrics satisfying the simulation inequality.

2. Prove the infimum of pseudometrics is again a pseudometric:
   - reflexivity is immediate by pointwise infimum,
   - triangle uses `iInf_le` / `le_iInf` and order properties of addition.

3. Show `bisimBound` is a prefixed point by infimum reasoning.

4. Prove leastness tautologically.

This route is elegant and categorical, but Lean may make the bounded quantification over the subtype of pseudometrics more cumbersome than Strategy A.

---

### Strategy C: Matrix/Kleene iteration in the finite-state case
For a breakthrough computational theorem, especially if abstract trace continuity becomes difficult.

1. Encode `d` as a matrix:
   ```lean
   Matrix σ σ ℝ≥0∞
   ```
2. Define the transformer matrix-wise and prove monotonicity.
3. Show the `n`-step iterate computes behavioral discrepancy up to horizon `n`.
4. Prove the least fixed point is the supremum of these finite-horizon approximants.
5. If possible, derive a finite stabilization bound from cardinality or finite height assumptions.

This is the best route for an executable algorithmic shadow and can later be connected back to the abstract fixed-point theorem.

---

## Concrete proof steps and key lemmas

1. **Monotonicity of the semantic lifting**
   ```lean
   theorem stepLift_monotone
       {σ ω : Type _}
       [Fintype σ] [DecidableEq σ]
       (obsDist : ω → ω → ℝ≥0∞)
       (out : σ → ω)
       (next : σ → σ) :
       Monotone (stepLift obsDist out next)
   ```
   Proof: unfold `Monotone`; if `d ≤ e` pointwise, then `obsDist _ _ ⊔ d _ _ ≤ obsDist _ _ ⊔ e _ _` by `sup_le_sup_left`.

2. **Preservation of reflexivity**
   ```lean
   theorem stepLift_self_zero
       (hout_refl : ∀ w, obsDist w w = 0) :
       ∀ s, stepLift obsDist out next d s s = 0
   ```
   This may require assuming `d s s = 0`. Then:
   `obsDist (out s) (out s) = 0`, `d (next s) (next s) = 0`, hence `0 ⊔ 0 = 0`.

3. **Preservation of triangle inequality**
   ```lean
   theorem stepLift_triangle
       (hout_tri : ∀ a b c, obsDist a c ≤ obsDist a b + obsDist a c)
       (hd_tri : ∀ s t u, d s u ≤ d s t + d t u) :
       ∀ s t u,
         stepLift obsDist out next d s u
           ≤ stepLift obsDist out next d s t + stepLift obsDist out next d t u
   ```
   Adjust the `hout_tri` statement to the correct variables:
   ```lean
   ∀ a b c, obsDist a c ≤ obsDist a b + obsDist b c
   ```
   Then combine the two triangle inequalities under `sup` using `sup_le_iff.mpr`.

4. **Least fixed point from existing fixed-point infrastructure**
   Instantiate the catalog’s theorem on:
   ```lean
   α := MetricPred σ
   ```
   and operator:
   ```lean
   Φ := stepLift obsDist out next
   ```
   If the theorem requires Scott continuity, prove:
   ```lean
   theorem stepLift_scottContinuous ... : ScottContinuous (stepLift obsDist out next)
   ```
   likely by pointwise preservation of `iSup`:
   ```lean
   stepLift ... (fun s t => ⨆ i, d i s t) = ...
   ```

5. **Nonexpansiveness of combinators**
   For semantic maps `⟦C⟧`, prove:
   ```lean
   theorem sem_nonexpansive :
     ∀ x y, d_out (sem C x) (sem C y) ≤ d_in x y
   ```
   by induction on circuit syntax:
   - identity/wire permutation: equality,
   - sequential composition: transitivity of `≤`,
   - parallel composition: `sup`-product metric,
   - trace/feedback: guarded fixed-point theorem plus monotonicity.

This induction is the semantic heart of the whole development.

---

## Stronger theorem to aim for if the APIs cooperate

If the catalog already contains a Kantorovich-style lifting for semiring-valued kernels, do not stop at deterministic `next : σ → σ`. Prove the branching version:

```lean
theorem least_bisimulation_metric_kernel
    {σ ω κ : Type _}
    [Fintype σ] [DecidableEq σ]
    (obsDist : ω → ω → ℝ≥0∞)
    (out : σ → ω)
    (K : σ → κ)
    (liftK : MetricPred σ → κ → κ → ℝ≥0∞)
    (hlift_mono : ∀ {d e}, d ≤ e → ∀ a b, liftK d a b ≤ liftK e a b)
    (hlift_refl : ...)
    (hlift_tri : ...)
    :
    ∃ d : MetricPred σ,
      (∀ s t, obsDist (out s) (out t) ⊔ liftK d (K s) (K t) ≤ d s t) ∧
      ...
```

This is much more revolutionary: it becomes a true **Kantorovich–Rubinstein theorem for reversible temporal semantics**, not just a deterministic metric recurrence.

---

## If full symmetry is obtainable

If reversibility plus trace axioms imply symmetry, prove it:

```lean
theorem least_bisimulation_metric_symmetric
    ...
    : ∀ s t, d s t = d t s
```

A likely route is to show the transformer commutes with swapping arguments:
```lean
stepLift ... d s t = stepLift ... (fun x y => d y x) t s
```
and use leastness to compare `d` with its transpose. This would be conceptually powerful: reversibility induces a genuinely pseudometric, not just a Lawvere quasi-metric.

---

## Why this matters

This theorem creates the quantitative layer that reversible temporal circuit semantics currently lacks. Exact equivalence is too brittle for modern semantics: optimization, approximate synthesis, fault tolerance, and robust verification all demand **distances**, not just propositions. By proving that the bisimulation pseudometric is the least traced/guarded fixed point, you establish:

- a **coinductive metric semantics** for reversible computation,
- a **compositional robustness theorem** for circuit operators,
- an **algorithmic approximation scheme** via finite iteration,
- a bridge from traced monoidal semantics to **optimal transport / Kantorovich lifting** ideas.

This is the seed of a new field: quantitative reversible semantics. It invites follow-up work on tropicalized circuit distances, entropy-like invariants for reversible dynamics, certified approximate compilation, and metric-enriched denotational models of physically realizable computation.

---

## Failure-controlled milestones

If the full theorem is too ambitious, prove the following in order, keeping all statements precise.

1. **Deterministic finite-state least prefixed pseudometric**
   ```lean
   theorem exists_least_bisimulation_metric_finite ...
   ```

2. **Iterative approximation from below**
   ```lean
   theorem iterStep_monotone ...
   theorem iterStep_least_metric ...
   ```

3. **Sequential and parallel nonexpansiveness**
   ```lean
   theorem seq_nonexpansive ...
   theorem prod_nonexpansive_sup ...
   ```

4. **Guarded trace preserves nonexpansiveness**
   even if only under a stronger contractiveness/guardedness hypothesis.

5. State the remaining conjecture precisely if kernel/Kantorovich lifting is blocked:
   ```lean
   conjecture trace_guarded_kantorovich_fixedpoint ...
   ```

---

## Deliverables inside the Lean development

Implement the main theorem in a dedicated file with supporting lemmas separated cleanly:
- definitions of candidate metrics and pseudometric laws,
- monotonicity / continuity lemmas for the lifting operator,
- least fixed-point construction,
- compositionality theorems,
- finite-state iterative computation theorem.

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next targets, for example:
1. kernel/Kantorovich lifting for branching reversible circuits,
2. symmetry from reversibility,
3. tropicalization of the bisimulation pseudometric,
4. algorithm extraction for exact finite-state computation,
5. quantitative full abstraction comparing operational and denotational distances.

### Catalog Reference Files
            @Computation/DensityTheory.lean
```lean
import Mathlib

/-! # CatalogBuild.Computation.DensityTheory

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15
-/


noncomputable section

/-- The EML operation. -/
def EMLd (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- EML closure at depth n: start from seed set S and apply EMLd n times. -/
def EMLClosure : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S => EMLClosure n S ∪ {z | ∃ a ∈ EMLClosure n S, ∃ b ∈ EMLClosure n S, z = EMLd a b}

/-- The full EML closure (union over all depths). -/
def fullEMLClosure (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure n S




/-- 1 is in the seed set. -/
theorem one_in_closure : (1 : ℝ) ∈ EMLClosure 0 {1} := by
  simp [EMLClosure]




/-- EML closure is monotone in depth. -/
theorem EMLClosure_mono (S : Set ℝ) (n : ℕ) :
    EMLClosure n S ⊆ EMLClosure (n + 1) S := by
  intro x hx
  simp [EMLClosure]
  exact Or.inl hx




/-- Log-split: EML(x, y·z) = EML(x, y) - ln(z) for y, z > 0. -/
theorem EMLd_log_split (x y z : ℝ) (hy : 0 < y) (hz : 0 < z) :
    EMLd x (y * z) = EMLd x y - Real.log z := by
  simp [EMLd, Real.log_mul hy.ne' hz.ne']; ring




/-- EML(x, 1) = exp(x). -/
theorem EMLd_exp (x : ℝ) : EMLd x 1 = Real.exp x := by
  simp [EMLd, Real.log_one]




/-- EML(0, x) = 1 - ln(x). -/
theorem EMLd_one_minus_log (x : ℝ) : EMLd 0 x = 1 - Real.log x := by
  simp [EMLd]




/-- EML(0, x) maps values in (1, e) to (0, 1). -/
theorem EMLd_maps_to_unit_interval (x : ℝ) (hx1 : 1 < x) (hxe : x < Real.exp 1) :
    0 < EMLd 0 x ∧ EMLd 0 x < 1 := by
  constructor
  · simp [EMLd]
    have : Real.log x < 1 := by
      rwa [← Real.log_exp 1, Real.log_lt_log_iff (by linarith) (Real.exp_pos 1)]
    linarith
  · simp [EMLd]
    linarith [Real.log_pos hx1]




/-- exp maps any positive value to a value > 1. -/
theorem EMLd_amplifies (x : ℝ) (hx : 0 < x) :
    EMLd x 1 > 1 := by
  simp [EMLd, Real.log_one]
  linarith [Real.add_one_le_exp x]




/-- The composition EML(EML(0, x), 1) = exp(1 - ln(x)) = e/x for x > 0. -/
theorem EMLd_inv_scaled (x : ℝ) (hx : 0 < x) :
    EMLd (EMLd 0 x) 1 = Real.exp 1 / x := by
  simp [EMLd, Real.log_one, Real.exp_sub, Real.exp_log hx]




/-- ln recovery: EML(0, exp(EML(0, x))) = ln(x). -/
theorem EMLd_recovers_ln (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 x)) = Real.log x := by
  simp [EMLd, Real.log_exp]




/-- Double negation: EML(0, exp(EML(0, exp(x)))) = x. -/
theorem EMLd_double_neg (x : ℝ) :
    EMLd 0 (Real.exp (EMLd 0 (Real.exp x))) = x := by
  simp [EMLd, Real.log_exp]




/-- Shift identity: EML(x + c, 1) = exp(c) · exp(x). -/
theorem EMLd_shift (x c : ℝ) :
    EMLd (x + c) 1 = Real.exp c * Real.exp x := by
  simp [EMLd, Real.log_one, Real.exp_add, mul_comm]




/-- [Section: # CatalogBuild.Computation.DensityTheory
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 15] -/
theorem e_irrational : Irrational (Real.exp 1) := by
  by_contra h;
  -- Assume that $e$ is rational, so there exist positive integers $p$ and $q$ such that $e = p/q$.
  obtain ⟨p, q, hpq⟩ : ∃ p q : ℕ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
    -- Since $e$ is not irrational, it must be rational. Therefore, there exist positive integers $p$ and $q$ such that $e = p/q$.
    obtain ⟨p, q, hpq⟩ : ∃ p q : ℤ, p > 0 ∧ q > 0 ∧ Real.exp 1 = p / q := by
      obtain ⟨ q, hq ⟩ := Classical.not_not.mp h;
      exact ⟨ q.num, q.den, mod_cast Rat.num_pos.mpr ( show 0 < q by exact_mod_cast hq.symm ▸ Real.exp_pos 1 ), mod_cast q.pos, by simpa only [ Rat.cast_def ] using hq.symm ⟩;
    cases p <;> cases q <;> aesop;
  -- Multiply both sides of the equation $e = p/q$ by $q!$ to obtain $q! \cdot e = p \cdot (q-1)! + p \cdot (q-2)! + \cdots + p + \frac{p}{q+1} + \cdots$.
  have h_mul_factorial : q.factorial * Real.exp 1 = ∑ k ∈ Finset.range (q + 1), (q.factorial : ℝ) / (k.factorial : ℝ) + ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) := by
    have h_mul_factorial : q.factorial * Real.exp 1 = ∑' k : ℕ, (q.factorial : ℝ) / ((k).factorial : ℝ) := by
      norm_num [ div_eq_mul_inv, Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum ];
      rw [ NormedSpace.exp_eq_tsum_div, ← tsum_mul_left ] ; exact tsum_congr fun _ => by ring;
    rw [ h_mul_factorial, ← Summable.sum_add_tsum_nat_add ];
    congr! 2;
    · ac_rfl;
    · exact Summable.mul_left _ <| by simpa using Real.summable_pow_div_factorial 1;
  -- The series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ is strictly less than 1.
  have h_series_lt_one : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) < 1 := by
    -- We can bound the series $\sum_{k=q+1}^{\infty} \frac{q!}{k!}$ above by a geometric series.
    have h_geo_series : ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1 + k).factorial : ℝ) ≤ ∑' k : ℕ, (q.factorial : ℝ) / ((q + 1).factorial : ℝ) * (1 / (q + 2)) ^ k := by
      refine' Summable.tsum_le_tsum _ _ _;
      · field_simp;
        intro i; rw [ div_pow ] ; rw [ mul_div, le_div_iff₀ ] <;> norm_cast <;> induction' i with i ih <;> norm_num [ Nat.factorial, pow_succ' ] at *;
        nlinarith [ Nat.factorial_succ ( q + 1 + i ) ];
-- ... (truncated, full file has 181 lines)
```


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
