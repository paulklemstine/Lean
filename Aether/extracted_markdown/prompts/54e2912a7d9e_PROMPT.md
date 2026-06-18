## YOUR ASSIGNMENT: Guarded Lawvere fixed-point index and entropy monotonicity for reversible temporal oracle towers

Work in a new file along the lines of
`Bridges/LogicComputation/GuardedFixedPointIndex.lean`
or
`Logic/TemporalComputation/GuardedFixedPointIndex.lean`.

The objective is to build a genuine index theory for guarded self-reference in reversible temporal computation, not merely another fixed-point existence lemma. The key new idea is to isolate a numerical/order-valued obstruction carried by a guarded endomorphism, prove that it is stable under the natural equivalences of traced semantics, and then show that nonzero index forces nontrivial temporal/entropy cost. This turns Lawvere-style self-reference from a yes/no phenomenon into a quantitative certificate.

### 1. Core definitions to introduce

You should define a structure for guarded endomorphisms over a concrete enriched order. Keep the first implementation as concrete as possible: use `ℕ∞ = WithTop ℕ` or `ℝ≥0∞` as the weight/complexity object, and only abstract later if the catalog infrastructure already exposes a suitable ordered idempotent semiring.

A robust first-pass Lean shape is:

```lean
import Mathlib
-- plus the local catalog imports for traced/idempotent-semiring semantics

open scoped BigOperators

/-- A concrete guarded endomorphism carrying a morphism, an oracle level,
and a quantitative guard bound. The interpretation is that one application
of `f` must cross at least `guardCost` units of guarded delay / closure weight. -/
structure GuardedEnd (α : Type _) where
  f : α → α
  oracleLevel : ℕ
  guardCost : WithTop ℕ
```

If the existing files already package reversible temporal morphisms as a structure, refine this to:

```lean
structure GuardedEnd (C : Type _) [Category C] (X : C) where
  hom : X ⟶ X
  oracleLevel : ℕ
  guardCost : WithTop ℕ
  guarded : Prop
```

but only do this if the ambient categorical infrastructure is genuinely usable. Otherwise, first prove the index theory in the concrete endofunction/weight setting and then provide a bridge theorem into the traced semantics already formalized elsewhere.

Define the fixed-point index as the least admissible closure/feedback weight. A good concrete definition is the simplest one that supports monotonicity and additivity:

```lean
def fixedPointIndex {α : Type _} (g : GuardedEnd α) : WithTop ℕ :=
  g.guardCost
```

This is too syntactic by itself, so you should immediately strengthen the semantics by adding a realizability predicate expressing that a given budget admits a guarded feedback witness. For example:

```lean
def RealizesAt {α : Type _} (g : GuardedEnd α) (k : WithTop ℕ) : Prop :=
  g.guardCost ≤ k

def fixedPointIndex' {α : Type _} (g : GuardedEnd α) : WithTop ℕ :=
  sInf {k : WithTop ℕ | RealizesAt g k}
```

Then prove that this collapses to `guardCost` under the concrete realizability predicate. This gives you a true infimum-based definition while keeping proofs tractable.

Introduce the preorder capturing semantic domination:

```lean
def GuardedEnd.Le {α : Type _} (g h : GuardedEnd α) : Prop :=
  g.oracleLevel ≤ h.oracleLevel ∧ g.guardCost ≤ h.guardCost
```

and trace-conjugacy / reversible equivalence in a concrete reversible form:

```lean
def TraceConj {α : Type _} (g h : GuardedEnd α) : Prop :=
  ∃ e : Equiv.Perm α, h.f = e ∘ g.f ∘ e.symm ∧
    g.oracleLevel = h.oracleLevel ∧
    g.guardCost = h.guardCost
```

For additive composition under oracle extension, define a stratified composition operation:

```lean
def GuardedEnd.comp {α : Type _} (g h : GuardedEnd α) : GuardedEnd α :=
{ f := g.f ∘ h.f
  oracleLevel := max g.oracleLevel h.oracleLevel
  guardCost := g.guardCost + h.guardCost }
```

If the catalog’s stratification theorem suggests `oracleLevel := g.oracleLevel + h.oracleLevel`, prove both variants if possible and identify which one matches the existing semantics.

Finally define an entropy/complexity observable. Keep it order-preserving:

```lean
def entropyBound : WithTop ℕ → WithTop ℕ := id
```

Then later replace `id` by the actual dequantization / density-theoretic map if available. The critical theorem only needs monotonicity:

```lean
def MonotoneMap (φ : WithTop ℕ → WithTop ℕ) : Prop :=
  Monotone φ
```

### 2. Precise theorem targets

Prove the following theorems with exact Lean signatures or very close variants.

#### A. Infimum characterization of the index

```lean
theorem fixedPointIndex'_eq_guardCost {α : Type _} (g : GuardedEnd α) :
    fixedPointIndex' g = g.guardCost := by
  ...
```

and the basic realization theorem:

```lean
theorem fixedPointIndex'_least {α : Type _} (g : GuardedEnd α) :
    RealizesAt g (fixedPointIndex' g) ∧
    ∀ k, RealizesAt g k → fixedPointIndex' g ≤ k := by
  ...
```

This is the formal seed of the whole obstruction theory: the index is a least feedback budget.

#### B. Monotonicity under enrichment order

```lean
theorem fixedPointIndex_mono {α : Type _} {g h : GuardedEnd α}
    (hle : GuardedEnd.Le g h) :
    fixedPointIndex' g ≤ fixedPointIndex' h := by
  ...
```

If you define a pointwise/order-theoretic relation on the underlying morphisms, strengthen this to include morphism comparison, not only metadata.

#### C. Invariance under trace-conjugacy

```lean
theorem fixedPointIndex_traceConj_invariant {α : Type _} {g h : GuardedEnd α}
    (hconj : TraceConj g h) :
    fixedPointIndex' g = fixedPointIndex' h := by
  ...
```

This theorem is conceptually essential: the index must depend only on the guarded feedback semantics, not on presentation.

#### D. Additivity / subadditivity under stratified oracle extension

At minimum prove subadditivity:

```lean
theorem fixedPointIndex_comp_le {α : Type _} (g h : GuardedEnd α) :
    fixedPointIndex' (g.comp h) ≤ fixedPointIndex' g + fixedPointIndex' h := by
  ...
```

If your definitions make equality true, prove the stronger theorem:

```lean
theorem fixedPointIndex_comp_eq {α : Type _} (g h : GuardedEnd α) :
    fixedPointIndex' (g.comp h) = fixedPointIndex' g + fixedPointIndex' h := by
  ...
```

Then prove oracle stratification monotonicity:

```lean
theorem oracleLevel_comp {α : Type _} (g h : GuardedEnd α) :
    (g.comp h).oracleLevel = max g.oracleLevel h.oracleLevel := by
  ...
```

and, if useful for later obstruction arguments,

```lean
theorem fixedPointIndex_oracle_monotone {α : Type _} {g h : GuardedEnd α}
    (hlev : g.oracleLevel ≤ h.oracleLevel)
    (hcost : g.guardCost ≤ h.guardCost) :
    fixedPointIndex' g ≤ fixedPointIndex' h := by
  ...
```

#### E. Elimination / obstruction theorem

Formulate “index zero implies eliminability of guarded self-reference” and its contrapositive “nonzero index obstructs elimination.” In the concrete first version, eliminability can mean “there exists a zero-cost representative in the same trace-conjugacy class.”

```lean
def Eliminable {α : Type _} (g : GuardedEnd α) : Prop :=
  ∃ h : GuardedEnd α, TraceConj g h ∧ fixedPointIndex' h = 0
```

Then prove:

```lean
theorem fixedPointIndex_zero_of_eliminable {α : Type _} {g : GuardedEnd α}
    (helim : Eliminable g) :
    fixedPointIndex' g = 0 := by
  ...
```

and the obstruction form:

```lean
theorem not_eliminable_of_pos_index {α : Type _} {g : GuardedEnd α}
    (hpos : 0 < fixedPointIndex' g) :
    ¬ Eliminable g := by
  ...
```

This is the theorem that upgrades fixed-point semantics into a certificate of irreducible feedback.

#### F. Entropy monotonicity law

Start with the abstract monotone-map theorem:

```lean
theorem entropy_monotone_of_monotone_map {α : Type _}
    (φ : WithTop ℕ → WithTop ℕ) (hφ : Monotone φ) {g h : GuardedEnd α}
    (hle : GuardedEnd.Le g h) :
    φ (fixedPointIndex' g) ≤ φ (fixedPointIndex' h) := by
  ...
```

Then derive the nontrivial lower bound theorem for any nonzero-index guarded endomorphism:

```lean
theorem entropy_lower_bound_of_pos_index {α : Type _}
    (φ : WithTop ℕ → WithTop ℕ) (hφ : Monotone φ) (hφpos : ∀ n > 0, 0 < φ n)
    {g : GuardedEnd α} (hpos : 0 < fixedPointIndex' g) :
    0 < φ (fixedPointIndex' g) := by
  ...
```

If you can connect to an existing temporal complexity or density quantity, define:

```lean
def temporalFeedbackComplexity {α : Type _} (g : GuardedEnd α) : WithTop ℕ :=
  entropyBound (fixedPointIndex' g)
```

and prove

```lean
theorem temporalFeedbackComplexity_lower_bound {α : Type _}
    {g : GuardedEnd α} (hpos : 0 < fixedPointIndex' g) :
    0 < temporalFeedbackComplexity g := by
  ...
```

with `entropyBound` instantiated by the actual order-preserving semantics from the existing dequantization/density files if available.

### 3. Recommended proof architecture

Do not attack the final entropy theorem first. Build the index theory in layers.

#### Strategy A: Concrete order-theoretic realization model
This is the most promising route for a complete formal proof.

1. Define `RealizesAt g k := g.guardCost ≤ k`.
2. Define `fixedPointIndex' g` as the `sInf` of realizable budgets.
3. Use order lemmas for `WithTop ℕ` to show the infimum is exactly `guardCost`.
4. Derive monotonicity and composition from monotonicity/additivity of `≤` and `+`.
5. Prove trace-conjugacy invariance by transporting equal metadata through the equivalence witness.

Why this is promising: it yields a fully formalized quantitative theory with almost no hidden categorical obligations, while still faithfully representing the “least closure weight” idea.

Key lemmas likely useful:
```lean
show sInf {k : WithTop ℕ | g.guardCost ≤ k} = g.guardCost
```
using `csInf`/`sInf` lemmas for conditionally complete lattices, or by proving both inequalities via `le_csInf` and `csInf_le`. If the complete lattice API is annoying, define the index directly as `guardCost` and separately prove the infimum characterization as a theorem.

#### Strategy B: Pullback from existing traced semiring semantics
If the catalog already defines a quantitative trace weight `traceWeight : End X → W`, make the new index a wrapper around that object.

1. Define `GuardedEnd` as an endomorphism together with a witness that it factors through one guarded temporal step / oracle stratum.
2. Set `fixedPointIndex` to the trace/closure weight supplied by the existing files.
3. Use previously verified diagonal/Lawvere-Kleene theorems to prove invariance under semantic equivalence.
4. Use traced monoidal functoriality to prove composition/additivity.
5. Push the index through dequantization to obtain entropy monotonicity.

Why this is more revolutionary: it directly connects self-reference, trace semantics, and entropy. But it depends on existing APIs being clean enough.

#### Strategy C: Tropical/dequantized shadow
If the entropy semantics are already tropicalized, prove a bridge theorem.

1. Construct an order-preserving map from the guarded index semiring to tropical complexity.
2. Show composition becomes tropical addition.
3. Show positive index maps to positive tropical complexity.
4. Deduce algorithmic lower bounds on temporal feedback complexity.

This is the strongest cross-domain statement and best matches the broader research program: categorical self-reference acquires a tropical complexity shadow.

### 4. Concrete proof steps you should implement

1. **Foundational order lemmas**
   - Prove `RealizesAt g g.guardCost`.
   - Prove minimality: `RealizesAt g k → g.guardCost ≤ k`.
   - Deduce `fixedPointIndex'_eq_guardCost`.

2. **Monotonicity and invariance**
   - Package the preorder `GuardedEnd.Le` as a theorem-friendly relation.
   - Show `g.guardCost ≤ h.guardCost` implies index monotonicity.
   - In the conjugacy theorem, extract equal guard/oracle data from the witness and rewrite.

3. **Composition**
   - Prove `(g.comp h).guardCost = g.guardCost + h.guardCost`.
   - Rewrite both sides of `fixedPointIndex_comp_eq` using `fixedPointIndex'_eq_guardCost`.
   - If exact equality is too strong in the semantic model, prove `≤` first and isolate the converse as a conjecture.

4. **Elimination obstruction**
   - Show trace-conjugacy invariance transports zero index.
   - If `Eliminable g`, choose a zero-index conjugate and rewrite back.
   - Contrapose to obtain `not_eliminable_of_pos_index`.

5. **Entropy lower bound**
   - First prove the generic monotone-map theorem.
   - Then instantiate with the actual entropy/dequantization map if available.
   - If only an abstract monotone map is available, keep the theorem abstract and add a specialization later.

### 5. Lean-specific implementation advice

Prefer explicit concrete codomains over overly abstract typeclasses in the first draft. `WithTop ℕ` is ideal because:
- it has an order,
- it has addition,
- positivity/nonzeroness is easy to reason about,
- it naturally models finite/infinite feedback cost.

Useful signatures:

```lean
def RealizesAt {α : Type _} (g : GuardedEnd α) (k : WithTop ℕ) : Prop := ...

def fixedPointIndex' {α : Type _} (g : GuardedEnd α) : WithTop ℕ := ...

def GuardedEnd.comp {α : Type _} (g h : GuardedEnd α) : GuardedEnd α := ...

def TraceConj {α : Type _} (g h : GuardedEnd α) : Prop := ...

def Eliminable {α : Type _} (g : GuardedEnd α) : Prop := ...

def temporalFeedbackComplexity {α : Type _} (g : GuardedEnd α) : WithTop ℕ := ...
```

Likely useful theorem forms:

```lean
theorem fixedPointIndex_eq_guardCost {α : Type _} (g : GuardedEnd α) :
    fixedPointIndex' g = g.guardCost := by ...

theorem fixedPointIndex_pos_iff {α : Type _} (g : GuardedEnd α) :
    0 < fixedPointIndex' g ↔ 0 < g.guardCost := by ...

theorem fixedPointIndex_comp_eq {α : Type _} (g h : GuardedEnd α) :
    fixedPointIndex' (g.comp h) = fixedPointIndex' g + fixedPointIndex' h := by ...

theorem fixedPointIndex_traceConj_invariant {α : Type _} {g h : GuardedEnd α}
    (hconj : TraceConj g h) :
    fixedPointIndex' g = fixedPointIndex' h := by ...
```

If positivity on `WithTop ℕ` is awkward, prove a nonzeroness version first:

```lean
theorem fixedPointIndex_ne_zero_of_guardCost_ne_zero {α : Type _} {g : GuardedEnd α}
    (h : g.guardCost ≠ 0) :
    fixedPointIndex' g ≠ 0 := by ...
```

and then derive positivity where needed.

### 6. Why this matters

This theorem package creates a new layer in the program: a **quantitative obstruction theory for self-reference**. Existing Lawvere/diagonal theorems tell you when feedback/fixed points exist. The new index tells you how much guarded temporal/oracle structure is irreducibly required. That is a different kind of result.

The conceptual breakthrough is the triangle:

- **Lawvere self-reference** gives fixed-point phenomena,
- **traced idempotent enrichment** turns them into ordered weights,
- **entropy/dequantization** converts those weights into lower bounds on computation.

Once formalized, this becomes a reusable engine:
- for proving irreducibility of feedback in reversible temporal circuits,
- for extracting algorithmic obstruction certificates from categorical semantics,
- for connecting fixed-point logic with tropical/entropy complexity,
- for building a future index calculus for oracle hierarchies, recursion depth, and self-referential protocols.

If you can prove even the concrete `WithTop ℕ` version cleanly, you have established the first formal fixed-point index theory in this direction. If you can also bridge it to the existing dequantization/entropy files, you open a path from categorical logic directly to complexity lower bounds.

### 7. If full generality is difficult

Prove the strongest special case completely:

- concrete `α → α`,
- `fixedPointIndex' = guardCost`,
- conjugacy invariance under `Equiv.Perm α`,
- exact additivity under `comp`,
- obstruction theorem using `Eliminable`,
- entropy theorem for `φ = id`.

Then state the categorical upgrade precisely as a conjecture, e.g.:

```lean
conjecture categorical_fixedPointIndex_trace_invariant
    {C : Type _} [Category C] [MonoidalCategory C]
    {X : C} (g h : GuardedEnd C X) :
    TraceConj g h → fixedPointIndex g = fixedPointIndex h
```

and similarly for the dequantized entropy bridge.

### 8. Deliverables

Produce:
1. the new Lean file with the definitions and theorems above,
2. at least one theorem connecting the index to a complexity/entropy observable,
3. a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:
   - categorical generalization from `WithTop ℕ` to arbitrary ordered idempotent semirings,
   - a tropicalization theorem sending guarded index to tropical feedback complexity,
   - an algorithm extracting obstruction certificates for oracle-gated reversible circuits,
   - a stratified tower theorem relating index growth to oracle hierarchy depth,
   - a comparison theorem with existing Lawvere–Kleene stratification invariants.

Be bold about the final statements, but make the first layer watertight. The central target is a formal theorem that **nonzero guarded fixed-point index forces nontrivial temporal feedback complexity**.

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

Research domain: Logic
Research mode: prove
