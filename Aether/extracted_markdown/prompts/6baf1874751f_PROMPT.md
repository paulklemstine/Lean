

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

## Algebraic–EML Rate–Distortion Duality via Closure Cost Monoids and Minimal Description Fixed Points

### Core formalization target

Work in a fully finite setting first, so every infimum/supremum is realized by a finite minimum/maximum. The main bridge is between:

1. **closure-theoretic description complexity** on a finite hypothesis/state space,
2. **semiring-weighted distortion aggregation** on finite codebooks,
3. **thermodynamic pressure / free-energy style dual bounds**,
4. **minimal fixed-point descriptions** arising from closure operators,
5. **applications to certified robustness, post-quantum coding heuristics, and quantum/thermodynamic semantics**.

You should build a self-contained Lean 4 file around a finite type `α` of source states and a finite type `β` of code symbols / reconstructions.

### Required new definitions and structures

Introduce at least the following 10 definitions/structures with doc comments explicitly mentioning cross-domain bridges:

```lean
/-- Bridge: connects closure semantics to rate–distortion and thermodynamic pressure. -/
structure ClosureCostMonoid (α : Type*) where
  carrier : Set α
  close : Set α → Set α
  cost : α → ℕ
  monotone_close : Monotone close
  extensive_close : ∀ s, s ⊆ close s
  idempotent_close : ∀ s, close (close s) = close s

/-- Bridge: connects proof-semiring coding to cryptographic and quantum description cost. -/
structure FiniteCodebook (α β : Type*) [Fintype α] [Fintype β] where
  encode : α → β
  decode : β → Set α

/-- Distortion between source and reconstruction symbols. -/
def DistortionFn (α β : Type*) := α → β → ℚ

/-- Description length of a code symbol, used as an algebraic rate surrogate. -/
def CodeLengthFn (β : Type*) := β → ℕ

/-- Closure-induced description cost of a source element via a code symbol. -/
def closureDescriptionCost
    {α β : Type*} (C : Set α → Set α) (ℓ : CodeLengthFn β) (dec : β → Set α) : α → β → ℕ :=
  fun x y => if x ∈ C (dec y) then ℓ y else ℓ y + 1

/-- Distortion threshold admissibility. -/
def IsAdmissibleAt
    {α β : Type*} (d : DistortionFn α β) (ε : ℚ) (x : α) (y : β) : Prop :=
  d x y ≤ ε

/-- A code symbol is closure-feasible for x at threshold ε if it is admissible and closure-covers x. -/
def ClosureFeasible
    {α β : Type*} (C : Set α → Set α) (d : DistortionFn α β) (dec : β → Set α)
    (ε : ℚ) (x : α) (y : β) : Prop :=
  x ∈ C (dec y) ∧ d x y ≤ ε

/-- Minimal closure-description rate at distortion ε. -/
def closureRateDistortion
    {α β : Type*} [Fintype β]
    (C : Set α → Set α) (d : DistortionFn α β) (ℓ : CodeLengthFn β)
    (dec : β → Set α) (ε : ℚ) (x : α) : ℕ :=
  Finset.inf' (Finset.univ.filter (fun y => ClosureFeasible C d dec ε x y))
    (by
      -- prove nonempty in theorems under hypotheses, not here
      sorry?)
    (fun y => closureDescriptionCost C ℓ dec x y)

/-- Global worst-case rate at distortion ε. -/
def globalClosureRate
    {α β : Type*} [Fintype α] [Fintype β]
    (C : Set α → Set α) (d : DistortionFn α β) (ℓ : CodeLengthFn β)
    (dec : β → Set α) (ε : ℚ) : ℕ :=
  Finset.sup Finset.univ (fun x => closureRateDistortion C d ℓ dec ε x)

/-- Partition-function style pressure with finite sums. -/
def closurePartition
    {α β : Type*} [Fintype α] [Fintype β]
    (C : Set α → Set α) (d : DistortionFn α β) (ℓ : CodeLengthFn β)
    (dec : β → Set α) (λ : ℚ) (ε : ℚ) : ℚ :=
  ∑ x, ∑ y, if ClosureFeasible C d dec ε x y then (λ * (ℓ y : ℚ) + d x y) else 0

/-- Minimal-description fixed points of a closure. -/
def IsMinimalDescriptionFixedPoint
    {α β : Type*}
    (C : Set α → Set α) (ℓ : CodeLengthFn β) (dec : β → Set α) (x : α) : Prop :=
  x ∈ C ({x}) ∧
  ∀ y, x ∈ C (dec y) → closureDescriptionCost C ℓ dec x y ≥ closureDescriptionCost C ℓ dec x y

/-- A pressure dual certificate at inverse temperature λ. -/
def IsPressureDualCertificate
    {α β : Type*} [Fintype α] [Fintype β]
    (C : Set α → Set α) (d : DistortionFn α β) (ℓ : CodeLengthFn β)
    (dec : β → Set α) (λ ε : ℚ) (R : ℕ) : Prop :=
  ∀ x, ∃ y, ClosureFeasible C d dec ε x y ∧ (ℓ y : ℚ) ≤ R ∧
    closurePartition C d ℓ dec λ ε ≤ λ * R + d x y
```

Do **not** leave `sorry` in definitions; if `Finset.inf'` nonemptiness is awkward, define the rate first using `sInf` over a finite set of values, or define a defaulted version:

```lean
def closureRateDistortionWithTop ... : WithTop ℕ := ...
```

and then prove realization lemmas under nonemptiness assumptions. This is likely the cleanest path.

Also define at least 2 additional structures:

```lean
/-- Bridge: connects closure dynamics to ML certified robustness and cryptographic decoding. -/
class ClosureRobustCodec (α β : Type*) [Fintype α] [Fintype β] where
  close : Set α → Set α
  encode : α → β
  decode : β → Set α
  len : β → ℕ
  dist : α → β → ℚ

/-- Bridge: connects tropical/free-energy inequalities to finite algebraic coding. -/
structure PressureWindow where
  lambda : ℚ
  epsilon : ℚ
  lambda_nonneg : 0 ≤ lambda
  epsilon_nonneg : 0 ≤ epsilon
```

### Main theorem family to formalize

You should prove a cluster of theorems, not just one statement. The central theorem should be a finite duality theorem with explicit witnesses and computational bounds.

#### Main target theorem: finite closure rate–distortion duality

A precise Lean target, in one implementable version, is:

```lean
theorem closure_rate_distortion_duality_quantum_certified
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α)
    (hmono : Monotone C)
    (hext : ∀ s, s ⊆ C s)
    (hidem : ∀ s, C (C s) = C s)
    (d : α → β → ℚ)
    (ℓ : β → ℕ)
    (dec : β → Set α)
    (ε : ℚ)
    (hε : 0 ≤ ε)
    (hcover : ∀ x : α, ∃ y : β, x ∈ C (dec y) ∧ d x y ≤ ε) :
    ∃ R : ℕ,
      (∀ x : α, ∃ y : β, x ∈ C (dec y) ∧ d x y ≤ ε ∧ ℓ y ≤ R) ∧
      R ≤ Finset.sup Finset.univ ℓ := by
  ...
```

This is the primal finite realizability theorem: there is a uniform finite rate bound achieving distortion threshold `ε`.

Then prove a dual pressure upper bound:

```lean
theorem closure_pressure_dual_upper_bound_post_quantum
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α)
    (d : α → β → ℚ)
    (ℓ : β → ℕ)
    (dec : β → Set α)
    (λ ε : ℚ)
    (hλ : 0 ≤ λ)
    (hε : 0 ≤ ε)
    (R : ℕ)
    (hR : ∀ x : α, ∃ y : β, x ∈ C (dec y) ∧ d x y ≤ ε ∧ ℓ y ≤ R) :
    closurePartition C d ℓ dec λ ε
      ≤ Fintype.card α * (λ * R + ε) * Fintype.card β := by
  ...
```

This theorem gives an explicit **O(|α||β|)** pressure bound, which must be stated in doc comments as a computational complexity bound.

Then prove a converse extraction theorem:

```lean
theorem pressure_certificate_extracts_uniform_rate_lattice
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α)
    (d : α → β → ℚ)
    (ℓ : β → ℕ)
    (dec : β → Set α)
    (λ ε : ℚ)
    (R : ℕ)
    (hλ : 0 < λ)
    (hcert : ∀ x : α, ∃ y : β, x ∈ C (dec y) ∧ closurePartition C d ℓ dec λ ε ≤ λ * R + d x y)
    (hε : ∀ x y, x ∈ C (dec y) → d x y ≤ ε) :
    ∀ x : α, ∃ y : β, x ∈ C (dec y) ∧ ℓ y ≤ R := by
  ...
```

This is the dual-to-primal extraction principle. Rearranging
`closurePartition ≤ λR + d x y` and using `d x y ≤ ε` with `λ > 0` should allow a bound on `ℓ y` once you prove a lower estimate linking the partition to any feasible pair. If the exact statement above is too strong, formalize a corrected version with an additional lower-bound hypothesis:
`λ * (ℓ y : ℚ) ≤ closurePartition ...` for feasible `y`, or a simpler theorem using a local pressure quantity.

#### Minimal fixed-point theorem

Formalize the fixed-point side as a separate but connected theorem:

```lean
theorem exists_minimal_description_fixed_point_thermodynamic
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α)
    (hmono : Monotone C)
    (hext : ∀ s, s ⊆ C s)
    (hidem : ∀ s, C (C s) = C s)
    (ℓ : β → ℕ)
    (dec : β → Set α)
    (hself : ∀ x : α, x ∈ C ({x} : Set α)) :
    ∃ x : α, IsMinimalDescriptionFixedPoint C ℓ dec x := by
  ...
```

A stronger finite minimization version is better:

```lean
theorem finite_argmin_closure_description_neural
    {α β : Type*} [Fintype α] [Nonempty α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α) (ℓ : β → ℕ) (dec : β → Set α) :
    ∃ x : α, ∀ z : α,
      minClosureSelfDescription C ℓ dec x ≤ minClosureSelfDescription C ℓ dec z := by
  ...
```

where you define

```lean
def minClosureSelfDescription
    {α β : Type*} [Fintype β]
    (C : Set α → Set α) (ℓ : β → ℕ) (dec : β → Set α) (x : α) : ℕ := ...
```

### Required theorem inventory

Prove at least 20 theorems. At minimum include the following 12 named results, with these names or stronger variants:

```lean
theorem closure_feasible_of_zero_distortion ...
theorem closure_rate_monotone_in_epsilon ...
theorem closure_rate_le_global_sup ...
theorem global_rate_attained_finite ...
theorem closure_partition_nonneg_quantum ...
theorem closure_partition_monotone_in_lambda ...
theorem closure_partition_monotone_in_epsilon ...
theorem closure_rate_distortion_duality_quantum_certified ...
theorem closure_pressure_dual_upper_bound_post_quantum ...
theorem pressure_certificate_extracts_uniform_rate_lattice ...
theorem exists_minimal_description_fixed_point_thermodynamic ...
theorem finite_argmin_closure_description_neural ...
```

Add at least 8 more, for example:

- `closure_description_cost_mem_eq_length`
- `closure_description_cost_not_mem_eq_succ_length`
- `feasible_exists_of_uniform_decoder`
- `rate_zero_for_constant_short_code`
- `global_rate_bound_by_max_length`
- `pressure_bound_via_cardinality_entropy`
- `certified_robustness_from_closure_cover_ml`
- `post_quantum_security_surrogate_from_large_rate`
- `tropical_free_energy_upper_envelope`
- `quantum_gibbs_style_code_selection`

### Concrete proof strategy hints

Use **three layers**: combinatorial finite minimization, algebraic closure lemmas, and pressure inequalities.

#### Layer 1: finite closure combinatorics
1. Prove basic closure-cost simplifications:
   ```lean
   theorem closure_description_cost_mem_eq_length ...
   theorem closure_description_cost_not_mem_eq_succ_length ...
   ```
   by unfolding and `simp`.

2. For finite minimization, define candidate value sets as finite images:
   ```lean
   Finset.univ.image (fun y => closureDescriptionCost C ℓ dec x y)
   ```
   and use `Finset.exists_min_image` / `Finset.mem_image` style lemmas, or reduce to `Finset.inf'` with explicit nonempty witness extracted from `hcover x`.

3. Prove `closure_rate_monotone_in_epsilon` using:
   - if `ε₁ ≤ ε₂`, then every `ClosureFeasible ... ε₁ x y` is feasible for `ε₂`;
   - convert inclusion of filtered finite sets into an inequality on infima/minima.
   If direct infimum comparison is painful, define the rate via `Nat.find` on the existence predicate
   ```lean
   ∃ n, ∃ y, ClosureFeasible ... ε x y ∧ ℓ y ≤ n
   ```
   and then monotonicity becomes much easier.

#### Layer 2: closure fixed-point architecture
4. For fixed points, define a self-description score:
   ```lean
   def minClosureSelfDescription ... (x : α) : ℕ := ...
   ```
   Then use finiteness of `α` to extract a global minimizer by `Finset.argminOn`-style reasoning or a finite image minimum theorem.

5. Use `hext` and `hself` to show every singleton-generated closure contains its seed. This gives a trivial feasible witness for self-description and ensures nonemptiness.

6. If `IsMinimalDescriptionFixedPoint` is too tautological as initially stated, strengthen it to:
   ```lean
   def IsMinimalDescriptionFixedPoint ... (x : α) : Prop :=
     x ∈ C ({x}) ∧
     ∀ z, minClosureSelfDescription C ℓ dec x ≤ minClosureSelfDescription C ℓ dec z
   ```
   Then the existence theorem is a direct finite argmin theorem and is mathematically meaningful.

#### Layer 3: pressure / dual bounds
7. For `closure_partition_nonneg_quantum`, assume
   ```lean
   ∀ x y, 0 ≤ d x y
   ```
   and `0 ≤ λ`. Then every summand is nonnegative; use `Finset.sum_nonneg`.

8. For the upper bound theorem, from `hR x` choose a witness `y`; then for any feasible pair, use
   ```lean
   λ * (ℓ y : ℚ) + d x y ≤ λ * R + ε
   ```
   by `nlinarith` or `linarith` after coercions. Since the partition sums over at most `|α||β|` terms, each bounded by `λ * R + ε`, derive:
   ```lean
   closurePartition ... ≤ (#α * #β) * (λ * R + ε)
   ```
   You may need helper lemmas converting cardinality counts to rational bounds on finite sums.

9. A more elegant variant is to define an **average pressure**
   ```lean
   def avgClosurePressure ... : ℚ := closurePartition ... / (Fintype.card α * Fintype.card β)
   ```
   and show
   ```lean
   avgClosurePressure ... ≤ λ * R + ε
   ```
   This is aesthetically closer to free-energy density.

10. For extraction from a pressure certificate, prove a local lower bound:
   ```lean
   theorem feasible_pair_contributes_to_partition ...
   ```
   stating that if `ClosureFeasible ... ε x y`, then
   ```lean
   λ * (ℓ y : ℚ) + d x y ≤ closurePartition ...
   ```
   because that term appears among the finite sum. This is the key duality lemma. Then combine with the certificate:
   ```lean
   λ * (ℓ y : ℚ) + d x y ≤ closurePartition ... ≤ λ * R + d x y
   ```
   cancel `d x y`, divide by positive `λ`, and conclude `ℓ y ≤ R`.
   This is the most promising proof path.

### Important helper lemmas you should explicitly prove

You will likely need the following exact or near-exact helper lemmas:

```lean
theorem feasible_pair_contributes_to_partition
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α) (d : α → β → ℚ) (ℓ : β → ℕ) (dec : β → Set α)
    (λ ε : ℚ) (hλ : 0 ≤ λ)
    {x : α} {y : β}
    (hxy : ClosureFeasible C d dec ε x y) :
    λ * (ℓ y : ℚ) + d x y ≤ closurePartition C d ℓ dec λ ε := by
  ...
```

This should follow by isolating the `(x,y)` summand in the double finite sum. Use `Finset.single_le_sum` twice.

```lean
theorem bounded_length_yields_partition_bound
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    ...
    (hℓ : ∀ y, (ℓ y : ℚ) ≤ R)
    (hd : ∀ x y, d x y ≤ ε)
    :
    closurePartition C d ℓ dec λ ε ≤
      (Fintype.card α * Fintype.card β : ℚ) * (λ * R + ε) := by
  ...
```

```lean
theorem finite_exists_argmin_nat
    {α : Type*} [Fintype α] [Nonempty α]
    (f : α → ℕ) :
    ∃ x, ∀ z, f x ≤ f z := by
  ...
```

This helper theorem is a major reusable primitive and should be proved cleanly.

### Lean tactic diversity requirements

Across the file, deliberately use all of the following tactics in meaningful places:

- `simp`
- `rw`
- `rcases`
- `by_cases`
- `by_contra`
- `have`
- `calc`
- `linarith`
- `nlinarith`
- `omega`
- `field_simp` (use at least once in an average-pressure theorem with rational division)
- finite set reasoning with `Finset.sum_le_sum`, `Finset.sum_nonneg`, `Finset.single_le_sum`

A good place for `omega` is converting integer/natural inequalities such as `ℓ y + 1 ≤ R + 1`.
A good place for `field_simp` is proving equivalence between total and average pressure bounds.

### Suggested exact theorem signatures for helper computational bounds

```lean
theorem avg_closure_pressure_bound_certified_robustness
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α) (d : α → β → ℚ) (ℓ : β → ℕ) (dec : β → Set α)
    (λ ε : ℚ) (R : ℚ)
    (hcard : 0 < (Fintype.card α : ℚ) * (Fintype.card β : ℚ))
    (hbound : closurePartition C d ℓ dec λ ε
      ≤ (Fintype.card α : ℚ) * (Fintype.card β : ℚ) * (λ * R + ε)) :
    closurePartition C d ℓ dec λ ε /
      ((Fintype.card α : ℚ) * (Fintype.card β : ℚ))
      ≤ λ * R + ε := by
  ...
```

```lean
theorem global_rate_complexity_bound_O_card_beta
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (C : Set α → Set α) (d : α → β → ℚ) (ℓ : β → ℕ) (dec : β → Set α)
    (ε : ℚ)
    (hcover : ∀ x : α, ∃ y : β, ClosureFeasible C d dec ε x y) :
    globalClosureRate C d ℓ dec ε ≤ Finset.sup Finset.univ ℓ := by
  ...
```

The doc comment should explicitly state: “computable in `O(|α||β|)` by exhaustive finite search.”

### Cross-domain theorem names and doc comments

Use application-loaded theorem names and comments. Examples:

- `closure_rate_distortion_duality_quantum_certified`
- `closure_pressure_dual_upper_bound_post_quantum`
- `pressure_certificate_extracts_uniform_rate_lattice`
- `certified_robustness_from_closure_cover_ml`
- `post_quantum_security_surrogate_from_large_rate`
- `tropical_free_energy_upper_envelope`
- `quantum_gibbs_style_code_selection`

Each major definition/theorem should include a doc comment of the form:

```lean
/--
Bridge: connects finite closure semantics, thermodynamic free energy, and
certified robustness. The resulting bound is computable in O(|α||β|).
Applications: quantum coding heuristics, post_quantum_security, neural compression.
-/
```

### Strong special cases to prove if the full duality is delicate

If full duality with arbitrary `closurePartition` is too ambitious, prove these special cases completely and cleanly:

1. **Boolean distortion special case**
   ```lean
   d x y ∈ {0,1}
   ```
   and `ε = 0`, so feasible means exact closure-cover.

2. **Constant-length codebook**
   `ℓ y = L` for all `y`; then the optimal rate is exactly `L` whenever a feasible code exists for every `x`.

3. **Identity closure**
   `C s = s`; then the framework reduces to a finite exact covering/coding theorem.

4. **Top closure**
   `C s = Set.univ`; then every decoder is closure-feasible and the rate is the minimum code length.

State these with explicit theorem names, e.g.
`identity_closure_rate_exact_formula`,
`universal_closure_collapses_rate`,
`constant_length_codebook_equilibrium`,
`boolean_distortion_zero_recovers_exact_cover`.

### Significance to the research program

Make the file a genuine bridge theorem: it should show that **EML closure semantics admit a finite rate–distortion formalism whose primal object is minimal closure description length and whose dual object is finite pressure/free energy**. This matters because it turns abstract closure/fixed-point semantics into a **computable optimization theory** with three immediate interpretations:

- **ML / certified robustness:** `C` models perturbation closure; feasible reconstruction corresponds to robust encoding; `globalClosureRate` is a symbolic compression-robustness tradeoff.
- **Cryptography / lattice / post-quantum:** closure-feasibility models decoding neighborhoods or syndrome closures; large minimal rate becomes a surrogate hardness witness.
- **Physics / quantum / thermodynamic:** `closurePartition` is a finite free-energy surrogate; dual inequalities resemble Gibbs variational principles in a semiring-coded setting.

The main mathematical civilization-building point is that closure operators, coding length, and free energy should no longer be separate notions.

### Required final section in the file

End with a clearly marked section of formal conjectures and executable next lemmas, e.g.

```lean
section FutureDirections

/-- Conjectural stronger Fenchel-style converse with exact minimax equality. -/
conjecture closure_fenchel_exact_minimax ...
/-- Conjectural tropicalization of closure pressure. -/
conjecture tropical_closure_pressure_duality ...
/-- Conjectural lattice cryptographic hardness lower bound from closure rate. -/
conjecture post_quantum_closure_hardness ...
/-- Conjectural certified robustness radius from closure pressure slope. -/
conjecture lipschitz_certified_robustness_from_pressure_derivative ...

end FutureDirections
```

Also produce a `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, specifically including:
1. exact minimax / Fenchel duality,
2. tropicalization / max-plus pressure,
3. lattice/post-quantum decoding interpretation,
4. certified robustness radius extraction,
5. quantum Gibbs semantics for closure-selected codebooks.

### Minimal implementation guidance

Prefer finite, concrete, theorem-complete formalization over grand abstraction that stalls. A very viable implementation route is:

- use `ℕ` lengths and `ℚ` distortions;
- define rates via existence of bounded-length feasible codes, then take least such bound;
- define pressure as finite double sums;
- prove primal existence from finite witness extraction;
- prove dual upper bound by termwise estimates;
- prove extraction theorem from local contribution to partition;
- prove fixed-point minimizer by finite argmin.

If needed, split into sections:
1. `BasicClosureCost`
2. `FiniteRateDistortion`
3. `PressureBounds`
4. `MinimalDescriptionFixedPoints`
5. `Applications`

No sorries, no placeholders, and no vacuous restatements of existing Mathlib lemmas. The file should read like the birth of a new bridge between algebraic closure semantics, information theory, and thermodynamic computation.

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
            Develop a precise rate–distortion theory for finitary EML closure systems by assigning a description cost to generators in a proof/closure semiring, defining distortion as closure mismatch between target states and compressed representatives, and proving that optimal compressed fixed points are characterized by a Fenchel-type duality between closure pressure and constrained description capacity. The target is a formally checkable pipeline: define closure-costed semiring dynamics, prove existence and monotonicity of optimal compressed closures, establish a dual variational formula for the rate–distortion function, and derive computable lower/upper bounds for fixed-point compression and lossy reconstruction of closure trajectories.

            ### Precise Mathematical Framing
            Let C be a finitary closure operator on a finite or noetherian state space X, with generating families G(x) and an additive/idempotent cost monoid K measuring description length of generators or proof witnesses. Define a distortion functional d_C(x,y) by asymmetric closure defect, e.g. d_C(x,y)=0 iff C({x})=C({y}), with quantitative versions given by minimal cost of witnesses needed to derive C({x}) from y. Define the rate function R_C(epsilon) as the infimal cost needed to choose a representative codebook Y and encoder e:X→Y such that d_C(x,e(x))≤epsilon for all x or in expectation over a closure-invariant measure. The core conjectural theorem is that under finitary compactness/subadditivity hypotheses, R_C admits a dual formula as a supremum over closure-Lipschitz potentials, analogous to rate–distortion duality, and that the minimizers are exactly Gibbs-like fixed points for a cost-tilted closure transfer operator. This extends the recent thermodynamic formalism and phase-space reconstruction work without repeating them: thermodynamic pressure becomes the Legendre dual of description rate, while reconstructed dynamics supply the distortion process. A second theorem should identify zero-distortion rate with minimal generator complexity of closure-equivalence classes, yielding an algorithm for lossy compression of proof-semiring or EML trajectories. A third theorem should show functorial monotonicity: quotienting by prime closure congruences cannot increase the rate–distortion function beyond an explicit obstruction term. This would create a new information-theoretic semantics for EML systems, distinct from prior coding-theorem and thermodynamic directions because it studies lossy compression rather than entropy/capacity or equilibrium alone.

            ### Lean 4 Sketch
Likely implementable using finite types, closure operators, semiring-weighted costs, infimum over finite codebooks, and convex-dual style inequalities specialized to finite sums/max-plus style pressures. Definitions should reuse closure-pressure and fixed-point infrastructure from recent EML bridge files, plus proof-semiring and prime closure notions from existing catalog declarations.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `rate_distortion_duality_of_coherent_proof_semiring` : theorem rate_distortion_duality_of_coherent_proof_semiring
     (file: Bridges/LawvereRateDistortionDuality.lean)
  2. `closure_fixed_points_are_iterative_invariants` : theorem closure_fixed_points_are_iterative_invariants {α : Type*}
     (file: Bridges/EntropyClosureSeparation.lean)
  3. `knaster_tarski_closure_fixed_point` : theorem knaster_tarski_closure_fixed_point (f : H → H)
     (file: Bridges/EMLClosureCore.lean)
  4. `closure_has_least_fixed_point` : theorem closure_has_least_fixed_point {α : Type*} [CompleteLattice α]
     (file: Bridges/QuantumTropicalCore.lean)
  5. `capacity_lower_bound_degree` : theorem capacity_lower_bound_degree (n d : ℕ) (hn : 1 ≤ n) :
     (file: Bridges/HilbertVCCorrespondence.lean)

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

            7. **PACKAGE.html** — MANDATORY standalone HTML package
               Bundle ALL artifacts into a single, self-contained HTML file:
               • Everything inlined (CSS, JS, content). No external dependencies.
               • ALL images MUST be embedded as base64 data URIs:
                 `<img src="data:image/png;base64,..." />` for PNGs,
                 `<img src="data:image/svg+xml;base64,..." />` for SVGs.
                 For SVG diagrams, prefer inlining `<svg>...</svg>` markup directly.
                 If you generate matplotlib/plotly charts, convert to base64 and embed.
                 NEVER reference external image files — they won't exist standalone.
               • Tab/sidebar navigation: Article, Research Paper, Demos, Algorithms,
                 Visualizations, Code Listings
               • Modern design: clean typography, dark/light toggle, responsive layout
               • KaTeX for math rendering (CDN OK), syntax-highlighted code blocks
               • Collapsible sections, smooth scroll, table of contents
               • Must work when opened directly in any browser

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


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
DELIVERABLE 6 — Standalone HTML Package  →  PACKAGE.html
────────────────────────────────────────────────────────────────────────────
Create a **single, self-contained HTML file** that bundles ALL artifacts
into a beautiful, interactive presentation. Requirements:

• **Single file**: Everything (CSS, JS, content) inlined. No external deps.
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the HTML as base64 data URIs. Use the format:
  `<img src="data:image/png;base64,..." />` for PNGs,
  `<img src="data:image/svg+xml;base64,..." />` for SVGs.
  If you generate matplotlib/plotly figures in Python, convert them to base64
  and embed them. For SVG diagrams, inline the SVG markup directly with
  `<svg>...</svg>` tags — this is preferred over base64 for vector graphics.
  NEVER use `<img src="filename.png">` — the file won't exist when viewing.
• **Navigation**: Sidebar or tab navigation between sections:
  - Article (the popular-science piece)
  - Research Paper (the full paper)
  - Interactive Demos (embedded Python output / JS visualizations)
  - Algorithms (pseudocode + implementation)
  - Visualizations (embedded charts/diagrams as inline SVG or base64)
  - Code Listings (syntax-highlighted Python and proof code)
• **Beautiful design**: Modern, clean typography (system fonts).
  Dark/light mode toggle. Responsive layout. Smooth transitions.
• **Math rendering**: Use KaTeX (CDN link OK for math rendering only)
  for any mathematical notation.
• **Syntax highlighting**: Inline code highlighting for Python blocks.
• **Interactive elements**: Collapsible sections, smooth scroll, TOC.
• The HTML package should work when opened directly in any browser.
• Include ALL content from the article, research paper, and code.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
