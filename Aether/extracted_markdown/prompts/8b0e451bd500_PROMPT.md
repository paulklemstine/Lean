

=== AEM QUALITY SCORING (MANDATORY GUIDELINES) 



Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new

## Algebra–Speculative Ultrametric Oracle Capacity via Non-Archimedean Fixed-Point Compression

### Core formalization target

Create `Bridges/Speculative/UltrametricOracleCapacity.lean` and make it a self-contained bridge between:

- algebraic dynamics on semiring-weighted states,
- non-Archimedean / ultrametric fixed-point theory,
- congruence minimization for speculative traces,
- certified robustness / quantum / post-quantum / lattice-flavored oracle semantics.

The file should introduce a mathematically coherent notion of semiring-valued speculative dynamics with a valuation-induced pseudo-ultrametric on traces, a time-reversal congruence, and a capacity invariant measuring how many recurrent fixed-point classes survive quotient compression.

You should formalize the strongest theorem that can be proved without axioms, and if a fully abstract oracle theorem is too ambitious, prove a concrete finite-trace / natural-valued special case and state the general theorem precisely.

---

## New definitions and structures to introduce

Use typeclass abstraction aggressively. Prefer minimal hypotheses.

### 1. Valuation-like structure on a semiring

Define a valuation interface strong enough to induce a pseudo-ultrametric.

Suggested Lean skeleton:

```lean
class SemiringValuation (R : Type*) [Semiring R] where
  v : R → ℕ
  map_zero : v 0 = 0
  map_one : v 1 = 0
  map_add_le_max : ∀ a b, v (a + b) ≤ max (v a) (v b)
  map_mul_le_add : ∀ a b, v (a * b) ≤ v a + v b
```

Also define a stronger non-Archimedean version if useful:

```lean
class StrongSemiringValuation (R : Type*) [Semiring R] extends SemiringValuation R where
  map_add_eq_max_of_ne : ∀ {a b : R}, v a ≠ v b → v (a + b) = max (v a) (v b)
```

### 2. Semiring-weighted speculative state

```lean
structure ValuatedSemiringState (R σ α : Type*)
    [Semiring R] [SemiringValuation R] where
  weight : σ → α → R
  step : σ → α → σ
  init : σ
```

Interpret `α` as an oracle alphabet / action alphabet and `σ` as configurations.

### 3. Trace evaluation and trace cost

For traces as `List α`, define recursive evaluation:

```lean
def traceWeight
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) : σ → List α → R
```

and valuation depth:

```lean
def traceDepth
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (t : List α) : ℕ :=
  SemiringValuation.v (traceWeight S s t)
```

### 4. Pseudo-ultrametric on traces

Use a bounded natural-valued distance to avoid real-analysis overhead; later connect to certified Lipschitz bounds.

A robust and provable choice is:

```lean
def traceDist
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v : List α) : ℕ :=
  max (traceDepth S s u) (traceDepth S s v)
```

This already supports a strong ultrametric-style inequality:
`d x z ≤ max (d x y) (d y z)` by pure order reasoning.

Also define a genuinely comparison-based distance using common prefixes or equal outputs if feasible:

```lean
def oraclePseudoDist ...
```

If the stronger definition becomes difficult, keep `traceDist` as the canonical formal object and state the stronger one as a future direction.

### 5. Time-reversal on traces and congruence

```lean
def timeReverse {α : Type*} : List α → List α := List.reverse

def TimeReversalCong {α : Type*} (u v : List α) : Prop :=
  u = v ∨ u = timeReverse v
```

Also define a configuration-level congruence induced by observational equivalence of all traces:

```lean
def ConfigTraceCong
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (x y : σ) : Prop :=
  ∀ t : List α, traceDepth S x t = traceDepth S y t
```

And a mixed quotient-stable congruence:

```lean
def TimeReversalConfigCong
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (x y : σ) : Prop :=
  ∀ t : List α, traceDepth S x t = traceDepth S y (timeReverse t)
```

### 6. Oracle contractivity

Define a one-step contractivity notion on traces/configurations.

```lean
def OracleContractive
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) : Prop :=
  ∀ (s : σ) (a : α) (u v : List α),
    traceDist S (S.step s a) u v ≤ traceDist S s (a :: u) (a :: v)
```

Also define a stronger shrink factor in natural numbers:

```lean
def OracleContractiveWithSlack
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (k : ℕ) : Prop :=
  ∀ (s : σ) (a : α) (u v : List α),
    traceDist S (S.step s a) u v + k ≤ traceDist S s (a :: u) (a :: v)
```

Interpret `k` as a certified robustness margin / cryptographic compression gap.

### 7. Recurrent fixed points and oracle capacity

Define recurrence in a finite-step constructive way:

```lean
def IsTraceFixedPoint
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) : Prop :=
  ∀ a : α, S.step s a = s
```

```lean
def IsRecurrentWithin
    {R σ α : Type*} [Semiring R] [SemiringValuation R] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (s : σ) : Prop :=
  ∃ t : List α, t.length ≤ n ∧
    List.foldl S.step s t = s
```

Define class counting on finite lists of states to stay computable:

```lean
def recurrentFixedPointsIn
    {R σ α : Type*} [Semiring R] [SemiringValuation R] [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) : List σ
```

Define quotient capacity as number of congruence classes represented among recurrent fixed points:

```lean
def oracleCapacity
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) : ℕ
```

Also define a quotient-compressed version:

```lean
def quotientOracleCapacity
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) : ℕ
```

You may implement quotienting by deduplication under a decidable approximation of congruence on the given finite list.

---

## Precise theorem statements to formalize and prove

You should prove at least 20 theorems total. At minimum include the following 12 central theorems, with these exact or near-exact signatures.

### Foundational trace/time-reversal theorems

```lean
theorem timeReverse_involutive {α : Type*} (t : List α) :
    timeReverse (timeReverse t) = t
```

```lean
theorem TimeReversalCong_refl {α : Type*} (t : List α) :
    TimeReversalCong t t
```

```lean
theorem TimeReversalCong_symm {α : Type*} {u v : List α} :
    TimeReversalCong u v → TimeReversalCong v u
```

```lean
theorem TimeReversalCong_trans {α : Type*} {u v w : List α} :
    TimeReversalCong u v → TimeReversalCong v w → TimeReversalCong u w
```

Package this as a `Setoid` if possible.

### Ultrametric / non-Archimedean theorems

```lean
theorem traceDist_self
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u : List α) :
    traceDist S s u u = traceDepth S s u
```

```lean
theorem traceDist_symm
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v : List α) :
    traceDist S s u v = traceDist S s v u
```

```lean
theorem traceDist_ultrametric
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v w : List α) :
    traceDist S s u w ≤ max (traceDist S s u v) (traceDist S s v w)
```

```lean
theorem traceDist_isosceles_principle
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (u v w : List α)
    (h₁ : traceDist S s u v < traceDist S s v w) :
    traceDist S s u w = traceDist S s v w
```

For the isosceles theorem, if the current `traceDist` definition makes the statement false, modify the distance so that it is actually provable. The theorem name must remain ultrametric-flavored and mathematically meaningful.

### Prefix/contraction theorems

Define a prefix-compatible theorem:

```lean
theorem traceDepth_cons_bound
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) (s : σ) (a : α) (t : List α) :
    traceDepth S s (a :: t) ≤
      SemiringValuation.v (S.weight s a) + traceDepth S (S.step s a) t
```

```lean
theorem oracle_contractive_of_weight_control
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (hctrl : ∀ s a u v,
      traceDist S (S.step s a) u v ≤ traceDist S s (a :: u) (a :: v)) :
    OracleContractive S
```

```lean
theorem oracle_contractive_iterate
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α)
    (hS : OracleContractive S) :
    ∀ (s : σ) (t u v : List α),
      traceDist S (List.foldl S.step s t) u v ≤
        traceDist S s (t ++ u) (t ++ v)
```

This is a key induction theorem. Prove by induction on `t`.

### Congruence and quotient preservation theorems

```lean
theorem ConfigTraceCong_refl
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    Reflexive (ConfigTraceCong S)
```

```lean
theorem ConfigTraceCong_symm
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    Symmetric (ConfigTraceCong S)
```

```lean
theorem ConfigTraceCong_trans
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    (S : ValuatedSemiringState R σ α) :
    Transitive (ConfigTraceCong S)
```

```lean
theorem recurrent_fixedpoint_class_preserved_under_time_reversal_quotient
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    quotientOracleCapacity S n states ≤ oracleCapacity S n states
```

And a stronger preservation theorem under suitable injectivity / canonical representative hypotheses:

```lean
theorem recurrent_fixedpoint_class_preserved_exactly
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ)
    (hcanon : ∀ x ∈ recurrentFixedPointsIn S n states, ∃ y,
      y ∈ recurrentFixedPointsIn S n states ∧
      TimeReversalConfigCong S x y) :
    quotientOracleCapacity S n states = oracleCapacity S n states
      ∨ quotientOracleCapacity S n states < oracleCapacity S n states
```

If exact equality is too strong in full generality, prove:
- monotonicity under quotient,
- existence of a representative per quotient class,
- preservation of nonemptiness of recurrent fixed-point classes.

### Explicit computational bound theorems

These utility theorems matter for AEM scoring. Make the finite-list algorithmic content explicit.

```lean
theorem oracleCapacity_le_card_states
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    oracleCapacity S n states ≤ states.eraseDups.length
```

```lean
theorem quotientOracleCapacity_le_card_states
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    quotientOracleCapacity S n states ≤ states.eraseDups.length
```

```lean
theorem oracle_capacity_prefix_certified_robustness_bound
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α)
    (hS : OracleContractiveWithSlack S 1)
    (n : ℕ) (states : List σ) :
    quotientOracleCapacity S n states + n ≤ oracleCapacity S n states + states.length
```

Name the theorem with certified/robustness language exactly; the ML connection should be explicit in the theorem name or docstring.

---

## Additional definitions/theorems for richness and cross-domain impact

Add at least 5 more novel definitions among these:

```lean
def oracleEntropyProxy ...
def quantumTraceEcho ...
def latticeSecurityGap ...
def certifiedReversalMargin ...
def tropicalHashCollisionScore ...
def nonArchimedeanCompressionRatio ...
def postQuantumOracleRadius ...
```

These do not need deep external semantics; they must be mathematically clean functions/invariants on your structures, and at least 5 theorems should relate them to `oracleCapacity`, `traceDist`, or quotienting.

Examples of suitable theorem names:

```lean
theorem quantum_trace_echo_time_reverse_invariant ...
theorem lattice_security_gap_monotone_under_quotient ...
theorem tropical_hash_collision_score_le_oracleCapacity ...
theorem certified_reversal_margin_nonarchimedean_bound ...
theorem post_quantum_oracle_radius_of_contractive_system ...
```

At least two theorem statements should have quantifier alternation of the form:

```lean
∀ x, ∃ y, ...
```

For example:

```lean
theorem every_recurrent_class_has_time_reversed_witness
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ) :
    ∀ x, x ∈ recurrentFixedPointsIn S n states →
      ∃ y, y ∈ recurrentFixedPointsIn S n states ∧ TimeReversalConfigCong S x y
```

and

```lean
theorem every_capacity_class_has_certified_radius
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) :
    ∀ x : σ, IsTraceFixedPoint S x →
      ∃ r : ℕ, ∀ u v : List α, traceDist S x u v ≤ r → TimeReversalCong u v ∨ u = v
```

If the second is too strong, weaken the conclusion while keeping the `∀ x, ∃ r` alternation.

---

## Concrete proof architecture

Do not rely on `simp` alone. Use a broad tactic palette. Include explicit intermediate lemmas.

### Phase 1: list/time-reversal algebra
1. Prove `timeReverse_involutive` via `simp [timeReverse]`.
2. Prove reflexive/symmetric/transitive properties of `TimeReversalCong` using `rcases` on the disjunction and rewrite with involutivity.
3. Package as a `Setoid (List α)` if useful for quotient constructions.

### Phase 2: recursive trace evaluation
1. Define `traceWeight` recursively on lists:
   - `[] ↦ 1`
   - `a :: t ↦ S.weight s a * traceWeight S (S.step s a) t`
2. Prove the recursion lemmas for `[]` and `(::)`.
3. Derive `traceDepth_cons_bound` from `map_mul_le_add`.
4. If stronger equalities hold in your concrete semiring instance (e.g. `ℕ` with additive valuation), prove specialized exact formulas.

### Phase 3: ultrametric inequalities
1. Start with the simple max-based `traceDist`.
2. Prove symmetry and ultrametric inequality by reducing to order lemmas on `max`.
3. For the isosceles principle, isolate an order-theoretic lemma on naturals:
   ```lean
   lemma max_isosceles_nat {a b c : ℕ} (h : max a b < max b c) : max a c = max b c
   ```
   Then instantiate with trace depths.
4. If needed, use `omega` for natural arithmetic and `linarith` if you transfer to `ℤ` or `ℚ`.

### Phase 4: contraction under iteration
1. Define `List.foldl S.step s t` as the iterated state.
2. Prove:
   ```lean
   List.foldl S.step s (t ++ u) = List.foldl S.step (List.foldl S.step s t) u
   ```
   or use an existing list fold lemma.
3. Induct on `t` for `oracle_contractive_iterate`.
4. Use the one-step contractive hypothesis at the inductive step and finish with transitivity of `≤`.

### Phase 5: congruence minimization and capacity bounds
1. Define `recurrentFixedPointsIn` by filtering `states` on `IsTraceFixedPoint` and `IsRecurrentWithin`.
2. Define quotient capacity by deduplicating according to a computable representative map or a finite-list normalization under time reversal.
3. Prove:
   - filtered list is a sublist / subset of `states`,
   - dedup length is bounded by original length,
   - quotient capacity is bounded by oracle capacity.
4. Use `List.length_filter_le`, `List.eraseDups_sublist`, membership lemmas, and `omega`.

### Phase 6: application-facing invariants
1. Define the “physics/crypto/ML” invariants as natural-number proxies.
2. Prove monotonicity under quotient and upper bounds by `oracleCapacity`.
3. Interpret these as:
   - `quantumTraceEcho`: time-reversal stability,
   - `latticeSecurityGap`: class separation margin,
   - `certifiedReversalMargin`: robust congruence radius,
   - `tropicalHashCollisionScore`: quotient collision count,
   - `postQuantumOracleRadius`: contraction-derived safe radius.

---

## Suggested concrete instances

To guarantee nontrivial executable content, instantiate the framework for at least one concrete semiring/state system.

### Natural semiring instance
Define a simple valuation on `ℕ`, for example:

```lean
instance : SemiringValuation ℕ where
  v n := n
  map_zero := rfl
  map_one := rfl
  map_add_le_max := by
    intro a b
    omega
  map_mul_le_add := by
    intro a b
    omega
```

If `v n := n` makes some intended inequalities awkward, use the constant-zero valuation for the fully general theory and then a second concrete structure for computational examples. It is acceptable to separate:
- a general abstract pseudo-ultrametric theory,
- a concrete executable oracle-capacity example over `ℕ`.

### Finite-state toy oracle
Use `σ = Fin m` or `Bool`, `α = Bool`, with explicit step and weight rules.
Then prove specialized examples:

```lean
theorem bool_oracle_capacity_bound ...
theorem bool_time_reversal_capacity_exact ...
theorem quantum_certified_bool_echo ...
```

These examples should compute and demonstrate the definitions are not vacuous.

---

## Required theorem naming style and doc comments

Use theorem names that explicitly carry cross-domain impact. Include doc comments of the form:

```lean
/--
Bridge: connects non-Archimedean fixed-point compression to certified robustness
for speculative oracle traces. The bound shows quotient minimization cannot
increase recurrent capacity, a semiring analogue of stable model compression.
-/
theorem oracle_capacity_prefix_certified_robustness_bound ...
```

Also include at least 3 doc comments mentioning these exact keywords:
- `quantum`
- `post_quantum`
- `certified robustness`
- `lattice`
- `thermodynamic`
- `tropical`

---

## Tactic diversity requirements inside the file

Ensure the proofs visibly use a broad tactic palette:
- `induction` on lists for recursive trace theorems,
- `rcases` for congruence case splits,
- `by_contra` for at least one impossibility / strict inequality lemma,
- `omega` for natural-number bounds,
- `linarith` if any integer/rational lifting is used,
- `field_simp` if you introduce any ratio-valued compression invariant,
- `simpa`, `aesop`, `constructor`, `have`, `calc`.

A good target is:
- 20+ theorems,
- 10+ definitions/structures/instances,
- at least 3 theorems proved by induction,
- at least 2 proofs using `rcases`,
- at least 1 proof using `by_contra`,
- at least 3 arithmetic proofs using `omega` or `linarith`.

---

## Main theorem package to end the file

Conclude with a theorem bundling the central message:

```lean
/--
Bridge: connects ultrametric fixed-point dynamics, congruence minimization,
and post_quantum oracle compression. Recurrent fixed-point classes survive
time-reversal quotienting, and certified robustness is controlled by the
non-Archimedean contraction radius.
-/
theorem nonarchimedean_fixedPointCompression_preserves_recurrent_capacity
    {R σ α : Type*} [Semiring R] [SemiringValuation R]
    [DecidableEq σ] [Inhabited α]
    (S : ValuatedSemiringState R σ α) (n : ℕ) (states : List σ)
    (hS : OracleContractive S) :
    quotientOracleCapacity S n states ≤ oracleCapacity S n states ∧
    ∀ x, x ∈ recurrentFixedPointsIn S n states →
      ∃ y, y ∈ recurrentFixedPointsIn S n states ∧ TimeReversalConfigCong S x y
```

If the existential witness is too strong in abstract generality, prove it under an added symmetry hypothesis:

```lean
(hrev : ∀ x, x ∈ recurrentFixedPointsIn S n states →
  ∃ y, y ∈ recurrentFixedPointsIn S n states ∧ TimeReversalConfigCong S x y)
```

and make the theorem conclude both quotient monotonicity and witness preservation.

---

## If abstraction becomes too difficult

Do not stall. Split into two layers:

### Layer A: fully proved abstract theory
- time reversal congruence,
- trace recursion,
- pseudo-ultrametric inequalities,
- contractive iteration,
- monotonicity of quotient capacity on finite lists.

### Layer B: fully proved concrete oracle model
- finite-state Boolean oracle,
- explicit recurrent fixed points,
- exact capacity counts,
- explicit certified / quantum / lattice-named corollaries.

State the more ambitious general theorem as a conjecture only if absolutely necessary, but maximize the number of complete formal results first.

---

## Deliverables inside the file

1. All definitions compile with minimal imports.
2. Zero `sorry`.
3. At least one `Setoid` instance.
4. At least one finite computable example.
5. At least 20 theorems total, including the 12 core theorems above.
6. A structured final comment block listing 3–5 precise future extensions:
   - stronger genuine ultrametric from longest common valued prefix,
   - entropy/capacity inequalities for thermodynamic oracle semantics,
   - tropical / lattice compression invariants for post_quantum security,
   - certified robustness radii for semiring-valued neural trace systems,
   - reversible quantum oracle analogues with phase-weight valuations.

Also produce `FUTURE_DIRECTIONS.md` with those next steps stated as concrete theorem targets, not vague ideas.

**AEM QUALITY MANDATE**: Your output will be scored on 5 pillars. Optimize ALL:
- RIGOR: 10+ theorems, diverse tactics (induction, rcases, by_contra, omega, linarith), ZERO sorries
- AESTHETIC: Bridge 2+ domains in theorem names and doc comments. Use quantifier alternation.
- UTILITY: Define 5+ structures/instances. State SPECIFIC computational bounds (O(n log n), Omega(2^n)) — generic terms like 'bound' or 'rate' alone do NOT score utility.
- ORIGINALITY: Coin novel definitions beyond Mathlib. Inventive theorem names. Write 'Bridge: connects X to Y' in doc comments for cross-domain connections. Generic names (main, test, aux) do NOT count.
- IMPACT: Use SPECIFIC application terms (lipschitz_certified_robustness, post_quantum_security, tropical_hash_collision) — generic terms like 'convergence' or 'spectrum' without ML/crypto/physics context do NOT score impact.

**FILE RICHNESS MANDATE**: Produce substantial, rich files (not stubs).
- Target 500+ lines with 20+ theorems and 10+ definitions per file.
- Historical Masters in the catalog average 2000+ lines, 180+ theorems, 70+ definitions.
- Each file should be a complete mathematical narrative with definitions, lemmas, and main theorems all connected.
- When producing catalog-wide output: create files across MULTIPLE domains (Bridges, Algebra, Cryptography, Tropical, EML, Physics), not just one domain.

            Research Mode: FORMALIZE

You are given informal mathematical ideas, notes, or a paper excerpt.
Formalize these ideas in Lean 4. Translate the informal mathematics
into precise definitions and theorem statements, then prove what you
can. If some parts require new axioms, declare them clearly and prove
consequences.

AEM QUALITY TARGETS:
- RIGOR: Prove 10+ theorems with diverse tactics. ZERO sorries.
- AESTHETIC: Formalize ideas that bridge 2+ mathematical domains.
- UTILITY: Define 5+ structures with computational implications.
- ORIGINALITY: Coin novel Lean 4 typeclass names for the formalized concepts.
- IMPACT: Formalize concepts with physics/crypto/ML applications.


            === VISIONARY DIRECTIVES ===

            Think beyond current mathematical fashion. You are not just proving theorems —
            you are building a mathematical civilization. Every result should:

            1. OPEN DOORS: A good theorem doesn't just close a question — it opens three
               new ones. What does your result make possible that wasn't possible before?
            2. CONNECT WORLDS: The deepest results connect fields that seemed unrelated.
               If you prove something about tropical geometry, ask: what does this mean
               for quantum computing? For cryptography? For neural networks?
            3. PRODUCE ALGORITHMS: Don't just prove existence — construct. Don't just
               construct — compute. Don't just compute — optimize. Every theorem should
               have an algorithmic shadow.
            4. BE BOLD: An interesting false conjecture is more valuable than a boring
               true theorem. If you suspect something is true but can't prove it, state
               it as a conjecture with precise Lean 4 type signature and explain why it matters.
            5. BUILD INFRASTRUCTURE: Definitions are as valuable as theorems. A good
               mathematical definition (like "tropical semiring" or "EML closure") can
               organize an entire field. Define things precisely, then prove things about them.

            The mathematics comes FIRST. Excellent proofs trump everything else.
            But excellent proofs that OPEN NEW FIELDS trump everything.

            === AEM QUALITY SCORING (MANDATORY GUIDELINES) ===
            Your output will be scored on 5 pillars. MAXIMIZE each one:

            PILLAR 1 — RIGOR (Is it World-class?):
            • ZERO sorries in your output (sorries cost -1.5 points each)
            • Use diverse proof tactics (induction, rcases, by_contra, omega, linarith,
              field_simp, refine, obtain — not just simp/rfl/decide)
            • Use typeclass abstraction ([Semiring B], [LinearOrder B], etc.) not
              concrete types alone
            • Later theorems should reference earlier ones (semantic coherence)
            • 10+ theorems = full rigor score; 3-10 = partial; 0-2 = minimal

            PILLAR 2 — AESTHETIC (Is it Interesting?):
            • Bridge 2+ mathematical domains in EVERY file (e.g., tropical + neural
              networks; algebra + thermodynamics; number theory + quantum)
            • Use quantifier alternation (∀ → ∃) for non-trivial theorem statements
            • Include symmetric structures (lattices, posets, groups, duality)
            • Minimize hypotheses for maximal conclusions (small axiomatic footprint)
            • Narrative surprise: state in doc comments WHY the result is unexpected

            PILLAR 3 — UTILITY (Is it Useful?):
            • State explicit computational bounds (O(...), convergence rates, Lipschitz
              constants, error bounds, complexity classifications)
            • Define extensible APIs: 5+ definitions, structures, and instances
            • Reference or advance known open problems (Carmichael, tropical Langlands,
              certified robustness, Berggren factoring, lattice crypto)
            • Organize code with namespaces and sections (framework structure)

            PILLAR 4 — ORIGINALITY (Is it New?):
            • Coin NOVEL definitions — not just restating Mathlib theorems with new names
            • Avoid derivative theorem names (*_eq_zero, *_nonneg, *_symm, *_comm,
              *_add_*, *_mul_*). Use INVENTIVE names that reveal new concepts
            • Combine unusual typeclasses ([Semiring, LinearOrder], [NormedAddCommGroup,
              Field], [MeasureSpace, Category]) — this signals divergent reasoning
            • Each file should introduce 5+ genuinely new mathematical objects (def, structure, class, instance). High-Originality files average 10+ new definitions.

            PILLAR 5 — IMPACT (Does it have Wonderful Applications?):
            • EVERY theorem should connect to at least one of: physics (quantum,
              thermodynamic, entropy), cryptography (lattice, post-quantum, SPB),
              or ML (certified robustness, Lipschitz bounds, neural networks)
            • Name-drop application keywords explicitly in theorem/doc-comment text:
              certified_robustness, Lipschitz, neural_network, gradient_descent,
              convergence, post_quantum, lattice_crypto, hamiltonian, entropy,
              holographic, berggren
            • Produce algorithms or computational pipelines, not just existence proofs

            ### Research Direction
            Develop a formally precise capacity theory for reversible/self-referential oracle computation by modeling oracle state evolution as contractive endomorphisms on ultrametric semiring state spaces. Prove that time-reversal congruence classes from chronometric semiring dynamics admit a non-Archimedean compression invariant controlling oracle distinguishability, fixed-point multiplicity, and reversible simulation cost. The core target is a capacity bound: if an oracle transition family is uniformly ultrametrically contractive modulo a semiring congruence, then the number of dynamically separable oracle behaviors is bounded by a valuation-complexity radius, yielding an algorithm for oracle minimization by congruence collapse plus ultrametric clustering.

            ### Precise Mathematical Framing
            Let S be an idempotent or ordered semiring equipped with a valuation v into an ordered additive monoid, and let X be a finite oracle configuration space with an S-weighted transition action T. Define an ultrametric on behavior traces by d(x,y)=exp(-v(eqdepth(x,y))) or an equivalent valuation-induced radius, and quotient by a time-reversal congruence ~ generated by chronometric reversibility relations. Study the induced endomorphism semiring End(X/~) and define the oracle capacity cap(T) as the maximal cardinality of an r-separated family of recurrent congruence classes across all admissible radii r. Prove: (1) contractive oracle fixed-point theorem on ultrametric semiring spaces; (2) separation-collapse inequality bounding cap(T) by the number of valuation strata of the congruence quotient; (3) reversible simulation theorem showing any such oracle system admits a minimal quotient automaton preserving fixed-point spectrum and bounded causal depth; (4) algorithmic minimization via iterative congruence elimination and ultrametric clustering. This extends the finished chronometric semiring dynamics work in a genuinely new direction while avoiding in-flight oracle hierarchy/sheaf semantics and closure-semiring EML tracks. It also leverages the open UltrametricDeepLearning infrastructure and congruence elimination primitives without being merely a sorry-filling task.

            ### Lean 4 Sketch
Define a structure `ValuatedSemiringState` with a semiring action, valuation, and induced pseudo-ultrametric on traces; define `TimeReversalCong` on traces/configurations; define `OracleContractive` and `oracleCapacity`. Prove lemmas analogous to ultrametric contraction and isosceles principles, then show quotient minimization preserves recurrent fixed-point classes. Likely files: `Bridges/Speculative/UltrametricOracleCapacity.lean` importing `Speculative/AutoResearch/Bridges/UltrametricDeepLearning`, `AutoResearch/CongruenceElimination`, and chronometric semiring files.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `fixed_point_consensus_bound` : theorem fixed_point_consensus_bound
     (file: Bridges/ByzantineCertificate.lean)
  2. `fixed_point_construction_bound` : theorem fixed_point_construction_bound (f : H → H)
     (file: Bridges/EMLClosureCore.lean)
  3. `valuation_compression_code_bound` : theorem valuation_compression_code_bound {H : Type*}
     (file: Bridges/UltrametricLearning/UltrametricPACBayes.lean)
  4. `fixed_point_of_invariant_singleton` : theorem fixed_point_of_invariant_singleton
     (file: Bridges/ProofStoneCechDynamics.lean)
  5. `ultrametric_measurement_radius_of_uniform_valuation_control` : theorem ultrametric_measurement_radius_of_uniform_valuation_control
     (file: Bridges/TropicalUltrametricQuantumUncertainty.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT



Recent successful concepts: Algebraic–Speculative Chronometric Semiring Dynamics via Time-Reversal Congruences and Causal Fixed-Point Separation, Algebraic–EML Thermodynamic Formalism via Closure Pressure and Gibbs Fixed-Point States, Algebraic–EML Phase-Space Reconstruction via Closure Bialgebras and Koopman Spectra


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician, software engineer, and science writer.
            Create ALL of the following:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **ARTICLE.md** — MANDATORY standalone popular-science article
               CRITICAL RULES:
               • Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
               • Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
               • This is a premier magazine-quality piece for curious, intelligent readers.
               QUALITY STANDARDS:
               • Superb, vivid, engaging prose with a strong opening hook and narrative arc.
               • Concrete analogies and metaphors that make abstract ideas tangible.
               • Story structure: provocative question → tension → breakthrough → significance.
               • Real-world connections: technology, nature, everyday life.
               • Historical context: place the work in the sweep of intellectual history.
               • 1500–3000 words. Substantial, standalone, enjoyable, interesting.
               • A reader should say "Wow, I had no idea math could do THAT."

            3. **RESEARCH_PAPER.md** — MANDATORY comprehensive, in-depth research paper
               This is a full, publishable-quality paper, NOT a summary:
               • Abstract, Introduction, Definitions & Notation
               • Main Results with detailed proof sketches (not just "by induction")
               • Algorithms with complete pseudocode and complexity analysis
               • Applications with worked examples showing practical use
               • Computational Experiments with tables, charts, numerical results
               • Discussion, Future Work, References
               • 3000–8000 words. Thorough and substantive.

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale

               ## Under-explored Territory
               ## Cross-Domain Bridges
               ## Open Problems Encountered

            5. **Python code** — demos, visualizations, algorithms, applications:
               - **demo.py** — concrete numerical examples bringing the math to life
               - **visualizations** — matplotlib/plotly charts (save as PNG/SVG too)
               - **algorithms.py** — implement algorithms from the paper with docstrings
               - **applications.py** — real-world applications (ML, crypto, physics)

            6. **diagram.svg** — visualization of key mathematical structures

            7. **PACKAGE.json** — MANDATORY JSON Data Package
               Bundle ALL artifacts into a single JSON file for the web frontend:
               • Output a strictly valid JSON object:
                 {
                   "title": "Title", "domain": "Domain",
                   "article": "Markdown content...",
                   "research_paper": "Markdown content...",
                   "future_directions": "Markdown content...",
                   "demos": [ { "name": "...", "code": "..." } ],
                   "algorithms": [ { "name": "...", "pseudocode": "..." } ],
                   "visualizations": [ { "name": "...", "data": "base64 URI or inline SVG" } ],
                   "lean_proofs": "Raw lean code..."
                 }
               • Ensure all Markdown and code is properly JSON-escaped.
               • ALL images MUST be embedded as base64 data URIs or inline SVG within the `data` field.
                 If you generate matplotlib/plotly charts, convert to base64.
                 NEVER reference external image files — they won't exist standalone.
               • This JSON file powers the dynamic web UI. Include ALL content.

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            @Speculative/AutoResearch/Bridges/UltrametricDeepLearning.lean
```lean
/-
# Ultrametric Deep Learning: p-Adic Optimization, Valuation Bounds, and Pruning Theory

This file formalizes the foundations of *ultrametric deep learning*: the study of
neural network optimization over non-Archimedean fields. The ultrametric strong
triangle inequality ‖x + y‖ ≤ max ‖x‖ ‖y‖ fundamentally reshapes loss landscape
geometry, yielding provable structural advantages over Archimedean optimization.

## Main Results (27 theorems, 0 sorry)

- **Ultrametric Isosceles Principle**: Unequal-norm elements sum to max norm
- **Sum Dominance**: ‖∑ vᵢ‖ ≤ max ‖vᵢ‖ (no cancellation)
- **MulVec Bound**: ‖(Av)ᵢ‖ ≤ ‖A‖_∞ · ‖v‖_∞ (no factor of n)
- **Entrywise Norm Submultiplicativity**: ‖BA‖_∞ ≤ ‖B‖_∞ · ‖A‖_∞
- **Lipschitz Composition**: Constants multiply under composition
- **Pruning Advantage**: Total error = max(individual errors), not sum
- **Valuation Monotone Pruning**: Higher valuation ⟹ smaller error
- **Critical Point Uniformity**: At critical points, components have equal norm
- **Generalization Bound Decay**: O(1/√n) with sample size
- **Valuation-Norm Correspondence**: ‖w‖ = p^{-v_p(w)}

## Structures (7 novel types)

- `IsUltrametricNormedField` — typeclass for non-Archimedean normed fields
- `UltrametricLayer` — neural network layer with certified norm bound
- `ValuationComplexityMeasure` — product-of-norms generalization complexity
- `PadicActivation` — activation function with certified Lipschitz constant
- `UltrametricNetworkCertificate` — end-to-end Lipschitz certification
- `UltrametricGeneralizationBound` — sample-size-dependent generalization bound
- `UltrametricPruningCertificate` — certified pruning with ultrametric advantage

## Bridges

- **Algebra ↔ ML**: p-adic valuations → neural network complexity measures
- **Number Theory ↔ Cryptography**: Valuation structure → certified pruning
- **Optimization ↔ Analysis**: Non-cancellation → saddle-free landscapes
-/

import Mathlib

open Finset Matrix

noncomputable section

/-! ## §1. Ultrametric Normed Field Infrastructure -/

/-- **IsUltrametricNormedField**: A normed field satisfying the ultrametric
    (strong) triangle inequality ‖x + y‖ ≤ max ‖x‖ ‖y‖.
    Bridge: connects non-Archimedean algebra to saddle-free ML optimization. -/
class IsUltrametricNormedField (K : Type*) extends NormedField K where
  ultrametric' : ∀ x y : K, ‖x + y‖ ≤ max ‖x‖ ‖y‖

/-- ℚ_p is an ultrametric normed field. -/
instance Padic.instIsUltrametricNormedField (p : ℕ) [hp : Fact (Nat.Prime p)] :
    IsUltrametricNormedField ℚ_[p] where
  ultrametric' := fun x y => IsUltrametricDist.norm_add_le_max x y

/-! ## §2. Fundamental Ultrametric Norm Theorems -/

variable (p : ℕ) [hp : Fact (Nat.Prime p)]

/-- **Ultrametric Triangle Inequality**: The fundamental non-Archimedean inequality.
    Impact: certified_robustness — perturbation bounds tighter than Archimedean. -/
theorem ultrametric_triangle_inequality (x y : ℚ_[p]) :
    ‖x + y‖ ≤ max ‖x‖ ‖y‖ :=
  IsUltrametricDist.norm_add_le_max x y

/-- **Ultrametric Isosceles Principle**: Unequal-norm elements sum to max norm.
    *Impossible* in ℝ where cancellation reduces ‖x + y‖ (e.g., x = 1, y = -1 + ε).
    Engine behind saddle elimination: gradient components cannot partially cancel.
    Bridge: connects ultrametric geometry (Algebra) to gradient dominance (ML). -/
theorem ultrametric_isosceles_principle (x y : ℚ_[p]) (hne : ‖x‖ ≠ ‖y‖) :
    ‖x + y‖ = max ‖x‖ ‖y‖ :=
  Padic.add_eq_max_of_ne hne

/-- **Ultrametric Subtraction Bound**: ‖x - y‖ ≤ max ‖x‖ ‖y‖.
    Bridge: connects p-adic geometry to adversarial ML defense. -/
theorem ultrametric_sub_bound (x y : ℚ_[p]) :
    ‖x - y‖ ≤ max ‖x‖ ‖y‖ := by
  calc ‖x - y‖ = ‖x + (-y)‖ := by rw [sub_eq_add_neg]
    _ ≤ max ‖x‖ ‖-y‖ := IsUltrametricDist.norm_add_le_max x (-y)
    _ = max ‖x‖ ‖y‖ := by rw [norm_neg]

/-- **Norm Multiplicativity**: ‖xy‖ = ‖x‖·‖y‖ in ℚ_p.
    Impact: certified_robustness — exact Lipschitz constants. -/
theorem padic_norm_multiplicative (x y : ℚ_[p]) :
    ‖x * y‖ = ‖x‖ * ‖y‖ :=
  norm_mul x y

/-- **Ultrametric Sum Dominance**: ‖∑ vᵢ‖ ≤ C when all ‖vᵢ‖ ≤ C.
    No partial cancellation possible — prevents gradient saddle creation.
    Bridge: connects ultrametric analysis to gradient non-cancellation (ML). -/
theorem ultrametric_sum_dominance
    {n : ℕ} (v : Fin n → ℚ_[p]) (C : ℝ) (hn : 0 < n)
    (hC : ∀ i, ‖v i‖ ≤ C) :
    ‖∑ i : Fin n, v i‖ ≤ C :=
  IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty
    ⟨⟨0, hn⟩, mem_univ _⟩ (fun i _ => hC i)

/-- **Critical Point Gradient Uniformity**: If g₁ + g₂ = 0, then ‖g₁‖ = ‖g₂‖.
    At a critical point where ∇L = 0, all gradient components must have the
    same p-adic norm — no "mixed curvature" as in Archimedean saddles.
    Bridge: connects ultrametric analysis to saddle-free optimization (ML).
    Impact: certified_robustness, adversarial_defense. -/
theorem ultrametric_critical_gradient_uniformity
    (g₁ g₂ : ℚ_[p]) (hsum : g₁ + g₂ = 0) :
    ‖g₁‖ = ‖g₂‖ := by
  rw [eq_neg_of_add_eq_zero_left hsum, norm_neg]

/-- **N-ary Critical Point Bound**: If ∑ vᵢ = 0 and all components except i₀
    have norm ≤ C, then ‖v i₀‖ ≤ C. Ultrametric inequality propagates bounds.
    Bridge: connects ultrametric analysis to high-dimensional optimization (ML). -/
theorem ultrametric_sum_zero_dominant_bound
    {n : ℕ} (v : Fin n → ℚ_[p])
    (hsum : ∑ i : Fin n, v i = 0)
    (i₀ : Fin n) (C : ℝ) (hC0 : 0 ≤ C) (hC : ∀ i, i ≠ i₀ → ‖v i‖ ≤ C) :
    ‖v i₀‖ ≤ C := by
  have h1 := add_sum_erase univ v (mem_univ i₀)
  rw [hsum] at h1
  rw [eq_neg_of_add_eq_zero_left h1, norm_neg]
  by_cases hempty : (univ.erase i₀ : Finset (Fin n)).Nonempty
  · exact IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty hempty
      (fun j hj => hC j (ne_of_mem_erase hj))
  · rw [not_nonempty_iff_eq_empty.mp hempty, sum_empty, norm_zero]; exact hC0

/-- **Valuation-Norm Correspondence**: ‖x‖ = p^{-v_p(x)} for x ≠ 0.
    Norms take values in {p^k : k ∈ ℤ} ∪ {0} — a discrete spectrum.
    Impact: post_quantum_security — connects to lattice problems. -/
theorem valuation_norm_correspondence (x : ℚ_[p]) (hx : x ≠ 0) :
    ‖x‖ = (p : ℝ) ^ (-x.valuation) :=
  Padic.norm_eq_zpow_neg_valuation hx

/-- **Norm Absorption**: If ‖x‖ < ‖y‖ then ‖x + y‖ = ‖y‖. The larger-norm
    element "absorbs" the smaller one.
    Bridge: connects ultrametric absorption to gradient analysis (ML). -/
theorem ultrametric_norm_absorption (x y : ℚ_[p]) (hlt : ‖x‖ < ‖y‖) :
    ‖x + y‖ = ‖y‖ := by
  rw [Padic.add_eq_max_of_ne (ne_of_lt hlt), max_eq_right (le_of_lt hlt)]

/-- **Norm Absorption (symmetric)**: If ‖y‖ < ‖x‖ then ‖x + y‖ = ‖x‖. -/
theorem ultrametric_norm_absorption_symm (x y : ℚ_[p]) (hlt : ‖y‖ < ‖x‖) :
    ‖x + y‖ = ‖x‖ := by
  rw [Padic.add_eq_max_of_ne (ne_of_gt hlt), max_eq_left (le_of_lt hlt)]

/-- **Ball Stability**: p-adic balls are additive subgroups. If ‖x‖ ≤ r and
    ‖y‖ ≤ r, then ‖x + y‖ ≤ r.
    Bridge: connects p-adic topology to constraint optimization (ML). -/
theorem ultrametric_ball_stability
    (x y : ℚ_[p]) (r : ℝ) (hx : ‖x‖ ≤ r) (hy : ‖y‖ ≤ r) :
    ‖x + y‖ ≤ r :=
-- ... (truncated, full file has 534 lines)
```

@AutoResearch/CongruenceElimination.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
  lhs : PolyFull S σ
  rhs : PolyFull S σ

/-! ## Embedding and Elimination -/

/-- The canonical embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`. -/
noncomputable def liftSome {S : Type*} [CommSemiring S] {σ : Type*} :
    PolyRet S σ →ₐ[S] PolyFull S σ :=
  MvPolynomial.rename Option.some

/-- Elimination congruence: pullback of `C` along `liftSome`. -/
def eliminationCong {S : Type*} [CommSemiring S] {σ : Type*}
    (C : SemiringCong (PolyFull S σ)) : SemiringCong (PolyRet S σ) where
  r f g := C.r (liftSome f) (liftSome g)
  refl' a := C.refl' (liftSome a)
  symm' h := C.symm' h
  trans' h1 h2 := C.trans' h1 h2
  add' h1 h2 := by
    show C.r (liftSome (_ + _)) (liftSome (_ + _))
    simp only [map_add]; exact C.add' h1 h2
  mul' h1 h2 := by
    show C.r (liftSome (_ * _)) (liftSome (_ * _))
    simp only [map_mul]; exact C.mul' h1 h2

/-! ## Structural Lemmas for coeffNone -/

section CoeffNone

variable {S : Type*} [CommSemiring S] {σ : Type*}

@[simp]
theorem coeffNone_add (n : ℕ) (f g : PolyFull S σ) :
    coeffNone n (f + g) = coeffNone n f + coeffNone n g := by
  simp [coeffNone, map_add]

@[simp]
theorem coeffNone_zero (n : ℕ) : coeffNone n (0 : PolyFull S σ) = 0 := by
  simp [coeffNone, map_zero]

/-- `optionEquivLeft` sends `liftSome r` to `Polynomial.C r`. -/
theorem optionEquivLeft_liftSome (r : PolyRet S σ) :
    optionEquivLeft S σ (liftSome r) = Polynomial.C r := by
  show optionEquivLeft S σ ((MvPolynomial.rename Option.some) r) = _
  induction r using MvPolynomial.induction_on with
  | C a => simp [optionEquivLeft_C]
-- ... (truncated, full file has 387 lines)
```

@AutoResearch/Basic.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
* `four_products_congruent` — all four products of pair elements are mutually congruent
* `idempotent_sandwich_left` / `_right` — idempotent semiring sandwich lemmas
* `direct_cross_sum_congruent` — S₁ ≡ S₂ for product sums

## Counterexample

The originally conjectured `linResultantPair_mem_elimination` theorem is **false** in
general. A counterexample is provided in the Boolean semiring ({0,1}, OR, AND):
taking `p = (1, X)` and `q = (X, 1)`, the linResultantPair gives `(0, 1)`, but `0` and
`1` are not related by any congruence generated solely by `(1, X)`.
See `Speculative.CongruenceElimination.Counterexample` for a detailed formal analysis.
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

/-- Scaling on the left: `C.r (f * a) (f * b)` from `C.r a b`. -/
theorem mul_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f * a) (f * b) :=
  C.mul' (C.refl' f) h

/-- Scaling on the right: `C.r (a * f) (b * f)` from `C.r a b`. -/
theorem mul_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a * f) (b * f) :=
  C.mul' h (C.refl' f)

/-- Adding a common term on the left. -/
theorem add_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f + a) (f + b) :=
  C.add' (C.refl' f) h

/-- Adding a common term on the right. -/
theorem add_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a + f) (b + f) :=
  C.add' h (C.refl' f)

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-- Additive idempotency is inherited by `MvPolynomial σ S`. -/
instance MvPolynomial.addIdempotent {S : Type*} [CommSemiring S] [AddIdempotent S]
    {σ : Type*} : AddIdempotent (MvPolynomial σ S) where
  add_self p := by
    ext m
    simp [MvPolynomial.coeff_add, add_self_eq]

/-- Additive idempotency is inherited by `Polynomial R`. -/
instance Polynomial.addIdempotent {R : Type*} [Semiring R] [AddIdempotent R] :
    AddIdempotent (Polynomial R) where
  add_self p := by
    ext n
    simp [Polynomial.coeff_add, add_self_eq]

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator `lhs ≡ rhs`. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
-- ... (truncated, full file has 559 lines)
```


### Catalog Reference Files
            @Speculative/AutoResearch/Bridges/UltrametricDeepLearning.lean
```lean
/-
# Ultrametric Deep Learning: p-Adic Optimization, Valuation Bounds, and Pruning Theory

This file formalizes the foundations of *ultrametric deep learning*: the study of
neural network optimization over non-Archimedean fields. The ultrametric strong
triangle inequality ‖x + y‖ ≤ max ‖x‖ ‖y‖ fundamentally reshapes loss landscape
geometry, yielding provable structural advantages over Archimedean optimization.

## Main Results (27 theorems, 0 sorry)

- **Ultrametric Isosceles Principle**: Unequal-norm elements sum to max norm
- **Sum Dominance**: ‖∑ vᵢ‖ ≤ max ‖vᵢ‖ (no cancellation)
- **MulVec Bound**: ‖(Av)ᵢ‖ ≤ ‖A‖_∞ · ‖v‖_∞ (no factor of n)
- **Entrywise Norm Submultiplicativity**: ‖BA‖_∞ ≤ ‖B‖_∞ · ‖A‖_∞
- **Lipschitz Composition**: Constants multiply under composition
- **Pruning Advantage**: Total error = max(individual errors), not sum
- **Valuation Monotone Pruning**: Higher valuation ⟹ smaller error
- **Critical Point Uniformity**: At critical points, components have equal norm
- **Generalization Bound Decay**: O(1/√n) with sample size
- **Valuation-Norm Correspondence**: ‖w‖ = p^{-v_p(w)}

## Structures (7 novel types)

- `IsUltrametricNormedField` — typeclass for non-Archimedean normed fields
- `UltrametricLayer` — neural network layer with certified norm bound
- `ValuationComplexityMeasure` — product-of-norms generalization complexity
- `PadicActivation` — activation function with certified Lipschitz constant
- `UltrametricNetworkCertificate` — end-to-end Lipschitz certification
- `UltrametricGeneralizationBound` — sample-size-dependent generalization bound
- `UltrametricPruningCertificate` — certified pruning with ultrametric advantage

## Bridges

- **Algebra ↔ ML**: p-adic valuations → neural network complexity measures
- **Number Theory ↔ Cryptography**: Valuation structure → certified pruning
- **Optimization ↔ Analysis**: Non-cancellation → saddle-free landscapes
-/

import Mathlib

open Finset Matrix

noncomputable section

/-! ## §1. Ultrametric Normed Field Infrastructure -/

/-- **IsUltrametricNormedField**: A normed field satisfying the ultrametric
    (strong) triangle inequality ‖x + y‖ ≤ max ‖x‖ ‖y‖.
    Bridge: connects non-Archimedean algebra to saddle-free ML optimization. -/
class IsUltrametricNormedField (K : Type*) extends NormedField K where
  ultrametric' : ∀ x y : K, ‖x + y‖ ≤ max ‖x‖ ‖y‖

/-- ℚ_p is an ultrametric normed field. -/
instance Padic.instIsUltrametricNormedField (p : ℕ) [hp : Fact (Nat.Prime p)] :
    IsUltrametricNormedField ℚ_[p] where
  ultrametric' := fun x y => IsUltrametricDist.norm_add_le_max x y

/-! ## §2. Fundamental Ultrametric Norm Theorems -/

variable (p : ℕ) [hp : Fact (Nat.Prime p)]

/-- **Ultrametric Triangle Inequality**: The fundamental non-Archimedean inequality.
    Impact: certified_robustness — perturbation bounds tighter than Archimedean. -/
theorem ultrametric_triangle_inequality (x y : ℚ_[p]) :
    ‖x + y‖ ≤ max ‖x‖ ‖y‖ :=
  IsUltrametricDist.norm_add_le_max x y

/-- **Ultrametric Isosceles Principle**: Unequal-norm elements sum to max norm.
    *Impossible* in ℝ where cancellation reduces ‖x + y‖ (e.g., x = 1, y = -1 + ε).
    Engine behind saddle elimination: gradient components cannot partially cancel.
    Bridge: connects ultrametric geometry (Algebra) to gradient dominance (ML). -/
theorem ultrametric_isosceles_principle (x y : ℚ_[p]) (hne : ‖x‖ ≠ ‖y‖) :
    ‖x + y‖ = max ‖x‖ ‖y‖ :=
  Padic.add_eq_max_of_ne hne

/-- **Ultrametric Subtraction Bound**: ‖x - y‖ ≤ max ‖x‖ ‖y‖.
    Bridge: connects p-adic geometry to adversarial ML defense. -/
theorem ultrametric_sub_bound (x y : ℚ_[p]) :
    ‖x - y‖ ≤ max ‖x‖ ‖y‖ := by
  calc ‖x - y‖ = ‖x + (-y)‖ := by rw [sub_eq_add_neg]
    _ ≤ max ‖x‖ ‖-y‖ := IsUltrametricDist.norm_add_le_max x (-y)
    _ = max ‖x‖ ‖y‖ := by rw [norm_neg]

/-- **Norm Multiplicativity**: ‖xy‖ = ‖x‖·‖y‖ in ℚ_p.
    Impact: certified_robustness — exact Lipschitz constants. -/
theorem padic_norm_multiplicative (x y : ℚ_[p]) :
    ‖x * y‖ = ‖x‖ * ‖y‖ :=
  norm_mul x y

/-- **Ultrametric Sum Dominance**: ‖∑ vᵢ‖ ≤ C when all ‖vᵢ‖ ≤ C.
    No partial cancellation possible — prevents gradient saddle creation.
    Bridge: connects ultrametric analysis to gradient non-cancellation (ML). -/
theorem ultrametric_sum_dominance
    {n : ℕ} (v : Fin n → ℚ_[p]) (C : ℝ) (hn : 0 < n)
    (hC : ∀ i, ‖v i‖ ≤ C) :
    ‖∑ i : Fin n, v i‖ ≤ C :=
  IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty
    ⟨⟨0, hn⟩, mem_univ _⟩ (fun i _ => hC i)

/-- **Critical Point Gradient Uniformity**: If g₁ + g₂ = 0, then ‖g₁‖ = ‖g₂‖.
    At a critical point where ∇L = 0, all gradient components must have the
    same p-adic norm — no "mixed curvature" as in Archimedean saddles.
    Bridge: connects ultrametric analysis to saddle-free optimization (ML).
    Impact: certified_robustness, adversarial_defense. -/
theorem ultrametric_critical_gradient_uniformity
    (g₁ g₂ : ℚ_[p]) (hsum : g₁ + g₂ = 0) :
    ‖g₁‖ = ‖g₂‖ := by
  rw [eq_neg_of_add_eq_zero_left hsum, norm_neg]

/-- **N-ary Critical Point Bound**: If ∑ vᵢ = 0 and all components except i₀
    have norm ≤ C, then ‖v i₀‖ ≤ C. Ultrametric inequality propagates bounds.
    Bridge: connects ultrametric analysis to high-dimensional optimization (ML). -/
theorem ultrametric_sum_zero_dominant_bound
    {n : ℕ} (v : Fin n → ℚ_[p])
    (hsum : ∑ i : Fin n, v i = 0)
    (i₀ : Fin n) (C : ℝ) (hC0 : 0 ≤ C) (hC : ∀ i, i ≠ i₀ → ‖v i‖ ≤ C) :
    ‖v i₀‖ ≤ C := by
  have h1 := add_sum_erase univ v (mem_univ i₀)
  rw [hsum] at h1
  rw [eq_neg_of_add_eq_zero_left h1, norm_neg]
  by_cases hempty : (univ.erase i₀ : Finset (Fin n)).Nonempty
  · exact IsUltrametricDist.norm_sum_le_of_forall_le_of_nonempty hempty
      (fun j hj => hC j (ne_of_mem_erase hj))
  · rw [not_nonempty_iff_eq_empty.mp hempty, sum_empty, norm_zero]; exact hC0

/-- **Valuation-Norm Correspondence**: ‖x‖ = p^{-v_p(x)} for x ≠ 0.
    Norms take values in {p^k : k ∈ ℤ} ∪ {0} — a discrete spectrum.
    Impact: post_quantum_security — connects to lattice problems. -/
theorem valuation_norm_correspondence (x : ℚ_[p]) (hx : x ≠ 0) :
    ‖x‖ = (p : ℝ) ^ (-x.valuation) :=
  Padic.norm_eq_zpow_neg_valuation hx

/-- **Norm Absorption**: If ‖x‖ < ‖y‖ then ‖x + y‖ = ‖y‖. The larger-norm
    element "absorbs" the smaller one.
    Bridge: connects ultrametric absorption to gradient analysis (ML). -/
theorem ultrametric_norm_absorption (x y : ℚ_[p]) (hlt : ‖x‖ < ‖y‖) :
    ‖x + y‖ = ‖y‖ := by
  rw [Padic.add_eq_max_of_ne (ne_of_lt hlt), max_eq_right (le_of_lt hlt)]

/-- **Norm Absorption (symmetric)**: If ‖y‖ < ‖x‖ then ‖x + y‖ = ‖x‖. -/
theorem ultrametric_norm_absorption_symm (x y : ℚ_[p]) (hlt : ‖y‖ < ‖x‖) :
    ‖x + y‖ = ‖x‖ := by
  rw [Padic.add_eq_max_of_ne (ne_of_gt hlt), max_eq_left (le_of_lt hlt)]

/-- **Ball Stability**: p-adic balls are additive subgroups. If ‖x‖ ≤ r and
    ‖y‖ ≤ r, then ‖x + y‖ ≤ r.
    Bridge: connects p-adic topology to constraint optimization (ML). -/
theorem ultrametric_ball_stability
    (x y : ℚ_[p]) (r : ℝ) (hx : ‖x‖ ≤ r) (hy : ‖y‖ ≤ r) :
    ‖x + y‖ ≤ r :=
-- ... (truncated, full file has 534 lines)
```

@AutoResearch/CongruenceElimination.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
  lhs : PolyFull S σ
  rhs : PolyFull S σ

/-! ## Embedding and Elimination -/

/-- The canonical embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`. -/
noncomputable def liftSome {S : Type*} [CommSemiring S] {σ : Type*} :
    PolyRet S σ →ₐ[S] PolyFull S σ :=
  MvPolynomial.rename Option.some

/-- Elimination congruence: pullback of `C` along `liftSome`. -/
def eliminationCong {S : Type*} [CommSemiring S] {σ : Type*}
    (C : SemiringCong (PolyFull S σ)) : SemiringCong (PolyRet S σ) where
  r f g := C.r (liftSome f) (liftSome g)
  refl' a := C.refl' (liftSome a)
  symm' h := C.symm' h
  trans' h1 h2 := C.trans' h1 h2
  add' h1 h2 := by
    show C.r (liftSome (_ + _)) (liftSome (_ + _))
    simp only [map_add]; exact C.add' h1 h2
  mul' h1 h2 := by
    show C.r (liftSome (_ * _)) (liftSome (_ * _))
    simp only [map_mul]; exact C.mul' h1 h2

/-! ## Structural Lemmas for coeffNone -/

section CoeffNone

variable {S : Type*} [CommSemiring S] {σ : Type*}

@[simp]
theorem coeffNone_add (n : ℕ) (f g : PolyFull S σ) :
    coeffNone n (f + g) = coeffNone n f + coeffNone n g := by
  simp [coeffNone, map_add]

@[simp]
theorem coeffNone_zero (n : ℕ) : coeffNone n (0 : PolyFull S σ) = 0 := by
  simp [coeffNone, map_zero]

/-- `optionEquivLeft` sends `liftSome r` to `Polynomial.C r`. -/
theorem optionEquivLeft_liftSome (r : PolyRet S σ) :
    optionEquivLeft S σ (liftSome r) = Polynomial.C r := by
  show optionEquivLeft S σ ((MvPolynomial.rename Option.some) r) = _
  induction r using MvPolynomial.induction_on with
  | C a => simp [optionEquivLeft_C]
-- ... (truncated, full file has 387 lines)
```

@AutoResearch/Basic.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Functorial Resultant and Projection Reconstruction for Idempotent Semiring Congruences

This file builds an elimination mechanism for semiring congruences on multivariate
polynomials, parallel to classical resultant elimination but adapted to semiring
congruences rather than ideals.

## Overview

We work in a commutative semiring `S` with polynomial variables split as `Option σ`,
where `none` is the eliminated variable and `some i` are the retained variables.

Using the Mathlib equivalence `MvPolynomial.optionEquivLeft`, we view
`MvPolynomial (Option σ) S` as `Polynomial (MvPolynomial σ S)` — a univariate polynomial
in the distinguished variable `none` with coefficients in the retained-variable ring.

## Main definitions

* `SemiringCong` — a semiring congruence (equivalence compatible with `+` and `*`)
* `coeffNone` — extracts the n-th coefficient in the `none` variable
* `noneDegree` — maximum exponent of `none` in the support
* `PolyPair` — a pair of polynomials representing a congruence generator
* `liftSome` — the embedding `MvPolynomial σ S →ₐ[S] MvPolynomial (Option σ) S`
* `eliminationCong` — pullback of a semiring congruence along `liftSome`
* `linResultantPair` — cross-multiplied coefficient pair for linear generators

## Main results

* `coeffNone_add` — coefficient extraction is additive
* `coeffNone_X_none_pow_mul_liftSome` — key computation for `X none ^ k * liftSome a`
* `linear_expand_of_noneDegree_le_one` — decomposition of linear polynomials
* `mem_eliminationCong_iff` — characterization of elimination congruence
* `cross_mul_mem` — cross-multiplication theorem for congruence pairs
* `eliminationCong_mono` — monotonicity of elimination
* `four_products_congruent` — all four products of pair elements are mutually congruent
* `idempotent_sandwich_left` / `_right` — idempotent semiring sandwich lemmas
* `direct_cross_sum_congruent` — S₁ ≡ S₂ for product sums

## Counterexample

The originally conjectured `linResultantPair_mem_elimination` theorem is **false** in
general. A counterexample is provided in the Boolean semiring ({0,1}, OR, AND):
taking `p = (1, X)` and `q = (X, 1)`, the linResultantPair gives `(0, 1)`, but `0` and
`1` are not related by any congruence generated solely by `(1, X)`.
See `Speculative.CongruenceElimination.Counterexample` for a detailed formal analysis.
-/

import Mathlib

open MvPolynomial Polynomial

/-! ## Semiring Congruence -/

/-- A semiring congruence: an equivalence relation compatible with `+` and `*`. -/
structure SemiringCong (A : Type*) [Semiring A] where
  r : A → A → Prop
  refl' : ∀ a, r a a
  symm' : ∀ {a b}, r a b → r b a
  trans' : ∀ {a b c}, r a b → r b c → r a c
  add' : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul' : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

namespace SemiringCong

variable {A : Type*} [Semiring A]

instance : LE (SemiringCong A) where
  le C D := ∀ ⦃a b⦄, C.r a b → D.r a b

/-- Scaling on the left: `C.r (f * a) (f * b)` from `C.r a b`. -/
theorem mul_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f * a) (f * b) :=
  C.mul' (C.refl' f) h

/-- Scaling on the right: `C.r (a * f) (b * f)` from `C.r a b`. -/
theorem mul_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a * f) (b * f) :=
  C.mul' h (C.refl' f)

/-- Adding a common term on the left. -/
theorem add_left (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (f + a) (f + b) :=
  C.add' (C.refl' f) h

/-- Adding a common term on the right. -/
theorem add_right (C : SemiringCong A) (f : A) {a b : A} (h : C.r a b) :
    C.r (a + f) (b + f) :=
  C.add' h (C.refl' f)

end SemiringCong

/-! ## Type Abbreviations -/

/-- The "full" polynomial ring with the distinguished variable. -/
abbrev PolyFull (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial (Option σ) S

/-- The "retained" polynomial ring without the distinguished variable. -/
abbrev PolyRet (S : Type*) (σ : Type*) [CommSemiring S] := MvPolynomial σ S

/-! ## Additive Idempotency -/

/-- A type with addition is additively idempotent if `a + a = a` for all elements. -/
class AddIdempotent (S : Type*) [Add S] : Prop where
  add_self : ∀ a : S, a + a = a

theorem add_self_eq {S : Type*} [Add S] [AddIdempotent S] (a : S) : a + a = a :=
  AddIdempotent.add_self a

/-- Additive idempotency is inherited by `MvPolynomial σ S`. -/
instance MvPolynomial.addIdempotent {S : Type*} [CommSemiring S] [AddIdempotent S]
    {σ : Type*} : AddIdempotent (MvPolynomial σ S) where
  add_self p := by
    ext m
    simp [MvPolynomial.coeff_add, add_self_eq]

/-- Additive idempotency is inherited by `Polynomial R`. -/
instance Polynomial.addIdempotent {R : Type*} [Semiring R] [AddIdempotent R] :
    AddIdempotent (Polynomial R) where
  add_self p := by
    ext n
    simp [Polynomial.coeff_add, add_self_eq]

/-! ## Coefficient Extraction -/

/-- Extract the n-th coefficient of the distinguished variable `none`. -/
noncomputable def coeffNone {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) (f : PolyFull S σ) : PolyRet S σ :=
  Polynomial.coeff (optionEquivLeft S σ f) n

/-- `coeffNone` as an additive group homomorphism. -/
noncomputable def coeffNoneHom {S : Type*} [CommSemiring S] {σ : Type*}
    (n : ℕ) : PolyFull S σ →+ PolyRet S σ where
  toFun := coeffNone n
  map_zero' := by simp [coeffNone, map_zero]
  map_add' f g := by simp [coeffNone, map_add]

/-! ## Degree in the Distinguished Variable -/

/-- Maximum exponent of `none` in the support of `f`. -/
noncomputable def noneDegree {S : Type*} [CommSemiring S] {σ : Type*}
    (f : PolyFull S σ) : ℕ :=
  (optionEquivLeft S σ f).natDegree

/-! ## Polynomial Pairs -/

/-- A pair of polynomials representing a congruence generator `lhs ≡ rhs`. -/
structure PolyPair (S : Type*) (σ : Type*) [CommSemiring S] where
-- ... (truncated, full file has 559 lines)
```


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "ean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "..." } ],
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
