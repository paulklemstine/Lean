## YOUR ASSIGNMENT: Functorial Mackey completion for maxitive measures on finite T0 spaces via idempotent Kantorovich codensity and support reconstruction

Work in the finite \(T_0\) regime where topology is equivalent to a specialization preorder and irreducible closed sets are controlled combinatorially. The goal is to turn the existing support-duality / idempotent Wasserstein infrastructure into a genuine completion theorem: the zero-distance quotient of maxitive measures should not merely identify equal supports, but assemble canonically into a codensity object on irreducible closed sets, with functorial pushforward.

The breakthrough is that this would replace analytic completion by a finite order-theoretic Mackey-style completion, giving a new bridge between tropical measure theory, finite domain theory, and categorical semantics of supports. In finite \(T_0\) spaces, completion should be computable, canonical, and functorial.

### Core definitions to introduce

Use concrete finite structures. If a fully topological finite \(T_0\) space is not already available, model it as a finite preorder/partial order whose closed sets are lower sets and irreducible closed sets are principal lower sets. This is the most promising route because on finite \(T_0\) spaces every irreducible closed set should be the closure of a unique point.

You should define a support class and codensity data in a way that can actually be manipulated in Lean.

A good minimal formal scaffold is:

```lean
class FiniteT0SupportClass (X : Type _) [Fintype X] [Preorder X] : Prop where
  antisymm_of_closure_eq :
    ∀ {x y : X}, (∀ z : X, z ≤ x ↔ z ≤ y) → x = y
```

If `PartialOrder X` is already available, this class can be trivialized or replaced by assumptions; the point is to package the finite \(T_0\) separation principle you will need for support reconstruction.

Define irreducible closed sets as principal lower sets:

```lean
def irreducibleClosed (X : Type _) [Preorder X] (x : X) : Set X := {y | y ≤ x}
```

Define codensity weights on irreducible closed sets by taking the maxitive mass of the corresponding support piece. If your ambient maxitive measure object is called `MaxitiveMeasure X α` or similar, adapt the type accordingly. A flexible target signature is:

```lean
def irreducibleClosedWeight
  {X : Type _} [Fintype X] [Preorder X]
  (μ : X → ℝ≥0∞) (x : X) : ℝ≥0∞ :=
  sSup {t | ∃ y ≤ x, μ y = t}
```

but if the existing measure object already has a value on sets, the cleaner definition is:

```lean
def irreducibleClosedWeight
  {X : Type _} [Fintype X] [Preorder X]
  (μ : Set X → ℝ≥0∞) (x : X) : ℝ≥0∞ :=
  μ {y | y ≤ x}
```

The second version is strongly preferable if available.

Define support gauge as the maximal discrepancy on irreducible closed sets:

```lean
def supportGauge
  {X : Type _} [Fintype X] [Preorder X]
  (μ ν : Set X → ℝ≥0∞) : ℝ≥0∞ :=
  ⨆ x : X, max
    (ENNReal.ofReal ((irreducibleClosedWeight μ x).toReal - (irreducibleClosedWeight ν x).toReal))
    (ENNReal.ofReal ((irreducibleClosedWeight ν x).toReal - (irreducibleClosedWeight μ x).toReal))
```

If subtraction in `ℝ≥0∞` becomes annoying, define instead a Boolean/equality-valued gauge for the zero-distance theorem:

```lean
def supportGaugeEq
  {X : Type _} [Fintype X] [Preorder X]
  (μ ν : Set X → ℝ≥0∞) : Prop :=
  ∀ x : X, irreducibleClosedWeight μ x = irreducibleClosedWeight ν x
```

This is likely the right first target. Then define an asymmetric idempotent Kantorovich quantity. Since full analytic duality is not needed in the finite case, use a finite supremum over monotone/LSC test functions:

```lean
def IsTestFunction
  {X : Type _} [Preorder X] (f : X → ℝ) : Prop :=
  Monotone f
```

and

```lean
def idempotentKantorovich
  {X : Type _} [Fintype X] [Preorder X]
  (μ ν : Set X → ℝ≥0∞) : ℝ≥0∞ :=
  ⨆ f : {f : X → ℝ // IsTestFunction f},
    ENNReal.ofReal (max 0 ((⨆ x : X, (f.1 x) - (irreducibleClosedWeight ν x).toReal) -
                           (⨆ x : X, (f.1 x) - (irreducibleClosedWeight μ x).toReal)))
```

This formula is only schematic; if the catalog already provides a dual pairing or idempotent KR expression, use that instead. The critical feature is: on finite \(T_0\) spaces, test functions separate principal closed sets, and the zero-distance condition should collapse exactly to equality of irreducible-closed weights.

### First target theorem: zero distance detects support codensity

Prove the exact zero-distance characterization first, in the strongest Lean-feasible form.

Preferred statement:

```lean
theorem idempotentKantorovich_eq_zero_iff_supportGaugeEq
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  (μ ν : Set X → ℝ≥0∞) :
  idempotentKantorovich μ ν = 0 ↔ supportGaugeEq μ ν
```

If you succeed in defining a numeric gauge:

```lean
theorem idempotentKantorovich_eq_zero_iff_supportGauge_eq_zero
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  (μ ν : Set X → ℝ≥0∞) :
  idempotentKantorovich μ ν = 0 ↔ supportGauge μ ν = 0
```

A very strong and probably easier intermediate theorem is:

```lean
theorem supportGaugeEq_iff_irreducibleClosedWeight_eq
  {X : Type _} [Fintype X] [Preorder X]
  (μ ν : Set X → ℝ≥0∞) :
  supportGaugeEq μ ν ↔ ∀ x : X, irreducibleClosedWeight μ x = irreducibleClosedWeight ν x
```

which is tautological if you define `supportGaugeEq` that way, but then use it as the semantic bridge to support equality / codensity equality.

### Quotient and completion object

Define the zero-distance equivalence relation:

```lean
def KantorovichZeroSetoid
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  (M : Type _) [PseudoMetricSpace M] : Setoid M where
  r μ ν := dist μ ν = 0
  iseqv := ...
```

If your measure space itself carries the pseudometric via `idempotentKantorovich`, use:

```lean
def mkCompletionSetoid
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  (M : Type _) :=
  Setoid.mk (fun μ ν => idempotentKantorovich μ ν = 0) ...
```

Then define codensity assignments on irreducible closed sets:

```lean
structure CodensityAssignment (X : Type _) [Preorder X] where
  toFun : X → ℝ≥0∞
  monotone' : Monotone toFun
```

Interpretation: `toFun x` is the codensity on the irreducible closed set `↓x`. In finite \(T_0\) spaces, this should be the completed object.

Define the canonical map from measures to codensity assignments:

```lean
def measureToCodensity
  {X : Type _} [Fintype X] [Preorder X]
  (μ : Set X → ℝ≥0∞) : CodensityAssignment X where
  toFun := irreducibleClosedWeight μ
  monotone' := by
    intro x y hxy
    -- use monotonicity of measure on closed sets / principal ideals
```

Then prove the factorization through the zero-distance quotient:

```lean
theorem measureToCodensity_respects_zero
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  {μ ν : Set X → ℝ≥0∞} :
  idempotentKantorovich μ ν = 0 →
  measureToCodensity μ = measureToCodensity ν
```

and conversely, if possible:

```lean
theorem measureToCodensity_injective_on_quotient
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  {μ ν : Set X → ℝ≥0∞} :
  measureToCodensity μ = measureToCodensity ν →
  idempotentKantorovich μ ν = 0
```

These together give the quotient identification.

### Final theorem: Functorial Mackey completion

State the final theorem as an equivalence between the quotient/completion of maxitive measures and codensity assignments. If full `Metric.Completion` is too heavy, first prove the finite stabilization theorem: every Cauchy family is eventually constant on irreducible support weights, hence admits a canonical codensity limit.

A strong Lean-feasible formulation is:

```lean
theorem finite_cauchy_stabilization_codensity
  {X : Type _} [Fintype X] [Preorder X]
  [FiniteT0SupportClass X]
  (u : ℕ → Set X → ℝ≥0∞)
  (hCauchy : Cauchy (Filter.map measureToCodensity Filter.atTop)) :
  ∃ c : CodensityAssignment X, ∀ x : X, Tendsto (fun n => irreducibleClosedWeight (u n) x) Filter.atTop (nhds (c.toFun x))
```

But because the state space is finite, you can aim for a sharper combinatorial stabilization:

```lean
theorem finite_support_pattern_eventually_stable
  {X : Type _} [Fintype X] [Preorder X]
  (u : ℕ → Set X → ℝ≥0∞) :
  (∀ x : X, ∃ N, ∀ m n ≥ N,
    irreducibleClosedWeight (u m) x = irreducibleClosedWeight (u n) x) →
  ∃ c : CodensityAssignment X, ∃ N, ∀ n ≥ N,
    measureToCodensity (u n) = c
```

Then package the completion theorem:

```lean
theorem FunctorialIdempotentMackeyCompletion
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X] :
  ∃ Φ : Quot (mkCompletionSetoid (X := X) (M := Set X → ℝ≥0∞)) ≃ CodensityAssignment X,
    True
```

A better final theorem, if you can formalize pushforwards, is:

```lean
theorem FunctorialIdempotentMackeyCompletion
  {X Y : Type _} [Fintype X] [Fintype Y] [Preorder X] [Preorder Y]
  [FiniteT0SupportClass X] [FiniteT0SupportClass Y]
  (f : X → Y) (hf : Monotone f) :
  ∃ ΦX : Quot (mkCompletionSetoid (X := X) (M := Set X → ℝ≥0∞)) ≃ CodensityAssignment X,
  ∃ ΦY : Quot (mkCompletionSetoid (X := Y) (M := Set Y → ℝ≥0∞)) ≃ CodensityAssignment Y,
    Nonempty
      {F : CodensityAssignment X → CodensityAssignment Y //
        ∀ μ,
          F.1 (ΦX (Quot.mk _ μ)) = ΦY (Quot.mk _ (pushforward f μ))}
```

If this is too elaborate, split it into:
1. quotient equivalence;
2. nonexpansiveness of pushforward;
3. commutation of quotient-to-codensity map with pushforward.

For nonexpansiveness, target:

```lean
theorem idempotentKantorovich_pushforward_le
  {X Y : Type _} [Fintype X] [Fintype Y] [Preorder X] [Preorder Y]
  (f : X → Y) (hf : Monotone f)
  (μ ν : Set X → ℝ≥0∞) :
  idempotentKantorovich (pushforward f μ) (pushforward f ν) ≤
    idempotentKantorovich μ ν
```

### Concrete proof strategy

1. **Reduce finite \(T_0\) topology to order theory.**  
   Identify closed sets with lower sets and irreducible closed sets with principal lower sets `irreducibleClosed X x = {y | y ≤ x}`. Prove the key separation lemma:
   ```lean
   theorem irreducibleClosed_injective
     {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X] :
     Function.Injective (irreducibleClosed X)
   ```
   This is the exact finite \(T_0\) mechanism replacing analytic regularity.

2. **Show test functions separate irreducible closed sets.**  
   For `x ≰ y`, construct a monotone indicator-type function detecting `↓x` versus `↓y`. On finite posets this should be a step function:
   ```lean
   def sepTest (x : X) : X → ℝ := fun z => if z ≤ x then 1 else 0
   ```
   or its order-dual depending on monotonicity conventions. Prove it is monotone after choosing the correct orientation. This yields the hard direction of
   `idempotentKantorovich_eq_zero_iff_supportGaugeEq`.

3. **Prove zero-distance iff equality on irreducible codensities.**  
   - `→`: use the separating test functions from step 2.
   - `←`: invoke the catalog’s functorial KR duality if available; otherwise show directly that every admissible finite test functional factors through irreducible closed weights. Because the space is finite, every monotone test function is a finite max-plus combination of principal indicators. This decomposition is the key new lemma:
     ```lean
     theorem monotone_function_sup_decomposition
       {X : Type _} [Fintype X] [Preorder X]
       (f : X → ℝ) (hf : Monotone f) :
       ∃ w : X → ℝ, ∀ z,
         f z = ⨆ x : X, if z ≤ x then w x else 0
     ```
     Even a weaker finite decomposition is enough.

4. **Construct the quotient-to-codensity equivalence.**  
   Define `measureToCodensity`; prove it is constant on zero-distance classes and surjective onto monotone codensity assignments by constructing a representing measure/capacity from a codensity assignment. In the finite setting, the obvious candidate is:
   ```lean
   def codensityToMeasure (c : CodensityAssignment X) : Set X → ℝ≥0∞ :=
     fun A => ⨆ x : {x // x ∈ A}, c.toFun x
   ```
   or, for lower sets,
   ```lean
   fun A => ⨆ x ∈ A, c.toFun x
   ```
   Then verify maxitivity and that principal closed weights recover `c`.

5. **Prove functoriality and nonexpansiveness of pushforward.**  
   Show
   `irreducibleClosedWeight (pushforward f μ) y`
   is controlled by the supremum of `irreducibleClosedWeight μ x` over `f x ≤ y`. This gives monotonicity/nonexpansiveness at the codensity level. Then transport this to the quotient/completion. The finite proof should be combinatorial, avoiding any compactness or lower-semicontinuity subtleties.

### Key intermediate lemmas worth isolating

These are likely the actual engines of the whole development:

```lean
theorem principalClosed_monotone
  {X : Type _} [Preorder X] :
  Monotone (irreducibleClosed X)
```

```lean
theorem irreducibleClosedWeight_monotone
  {X : Type _} [Fintype X] [Preorder X]
  (μ : Set X → ℝ≥0∞) :
  Monotone (irreducibleClosedWeight μ)
```

```lean
theorem zero_distance_implies_principal_weights_equal
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  {μ ν : Set X → ℝ≥0∞} :
  idempotentKantorovich μ ν = 0 →
  ∀ x : X, irreducibleClosedWeight μ x = irreducibleClosedWeight ν x
```

```lean
theorem principal_weights_equal_implies_zero_distance
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X]
  {μ ν : Set X → ℝ≥0∞} :
  (∀ x : X, irreducibleClosedWeight μ x = irreducibleClosedWeight ν x) →
  idempotentKantorovich μ ν = 0
```

```lean
theorem codensity_representation
  {X : Type _} [Fintype X] [Preorder X]
  (c : CodensityAssignment X) :
  ∀ x : X, irreducibleClosedWeight (codensityToMeasure c) x = c.toFun x
```

```lean
theorem pushforward_codensity_nonexpansive
  {X Y : Type _} [Fintype X] [Fintype Y] [Preorder X] [Preorder Y]
  (f : X → Y) (hf : Monotone f) :
  ∀ μ ν,
    idempotentKantorovich (pushforward f μ) (pushforward f ν) ≤
    idempotentKantorovich μ ν
```

### Most promising route

The most promising route is **not** to formalize a full abstract completion first. Instead:

1. define codensity assignments on principal closed sets;
2. prove `d = 0` iff codensity equality;
3. identify the quotient with codensity assignments;
4. only then formulate “completion” as this quotient object, noting that in the finite setting the codensity side is already complete/stable.

This is superior to a direct metric completion attack because the finite \(T_0\) case is fundamentally algebraic, and Lean will reward explicit finite decompositions over abstract uniform-space arguments.

### Why this matters

If proved, this creates the first genuinely functorial finite-space completion theory for maxitive measures in which:
- support identifiability becomes an equivalence of completed objects, not merely a detection theorem;
- idempotent Kantorovich geometry collapses to computable order-theoretic codensity data;
- pushforward becomes a nonexpansive morphism on completions, opening a categorical semantics of tropical transport;
- finite \(T_0\) spaces become a laboratory for tropical Mackey theory, domain-theoretic semantics, and algorithmic support reconstruction.

This is not an incremental variant of support duality. It upgrades support from an invariant to a universal completion object. That opens at least three new directions: tropical belief propagation on finite posets, categorical semantics of idempotent Bayesian update, and algorithmic reconstruction of maxitive laws from codensity profiles.

### If the full theorem is too hard

Prove the strongest possible special case with exact signatures:

1. Chain case:
```lean
theorem FunctorialIdempotentMackeyCompletion_chain
  {X : Type _} [Fintype X] [LinearOrder X] :
  ...
```

2. Equality of zero-distance quotient with monotone weights only:
```lean
theorem quotient_equiv_codensityAssignment
  {X : Type _} [Fintype X] [Preorder X] [FiniteT0SupportClass X] :
  Quot (mkCompletionSetoid (X := X) (M := Set X → ℝ≥0∞)) ≃ CodensityAssignment X
```

3. Pushforward nonexpansiveness independently:
```lean
theorem pushforward_nonexpansive
  ...
```

State any remaining obstruction as a precise conjecture with type signature.

### Deliverable requirement

Also produce a `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems, for example:
- extension from finite \(T_0\) spaces to spectral spaces via compact irreducibles;
- enriched categorical equivalence between finite posets and completed maxitive codensity spaces;
- tropical optimal transport algorithms derived from codensity normal forms;
- idempotent Stone duality between finite distributive lattices and completed support geometries;
- a computational extraction theorem turning codensity assignments into certified reconstruction algorithms.

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
