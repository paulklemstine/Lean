

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

## YOUR ASSIGNMENT: Algebra–EML Turing–Myhill Reconstruction via Closure Semimodule Dynamics and Intrinsic Computation Capacity

Work in a new file
`Bridges/AlgebraEMLClosureComputation.lean`
and organize the development around a closure-driven weighted transition semantics that reconstructs a Myhill–Nerode style minimal quotient from semiring-valued observables. The central bridge is:

- **automata theory / intrinsic computation**
- **semiring-linear dynamics / Koopman-style closure evolution**
- **thermodynamic / quantum / cryptographic interpretations of indistinguishability and capacity**

Your formalization should treat “closure observations” as semiring-valued probes on states, define trace indistinguishability via equality of all closed probe responses under all words, quotient by that relation, prove the quotient is minimal among all realizations preserving closure traces, and define a computable intrinsic capacity invariant with explicit finite bounds.

---

## CORE DEFINITIONS TO INTRODUCE

Use typeclass abstraction aggressively. Prefer minimal hypotheses, but split into stronger finite/computable sections when needed.

### Base weighted closure dynamics
Introduce a structure along the lines of:

```lean
universe u v w

structure ClosureSemimoduleSystem
    (σ : Type u) (α : Type v) (K : Type w)
    [Semiring K] where
  step : σ → α → σ
  output : σ → K
  closure : Set σ → Set σ
  closure_extensive : ∀ S : Set σ, S ⊆ closure S
  closure_mono : ∀ ⦃S T : Set σ⦄, S ⊆ T → closure S ⊆ closure T
  closure_idem : ∀ S : Set σ, closure (closure S) ⊆ closure S
```

Also define at least the following new objects:

```lean
def evalWord
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) : σ → List α → σ

structure ProbeFamily (σ : Type u) (K : Type w) [Semiring K] where
  probes : Set (σ → K)

def ClosureTrace
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) (s : σ) : List α → Set K

def ClosureIndistinguishable
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) : σ → σ → Prop
```

A good concrete trace definition is:
- run a word `w` from `s`,
- collect all states in `closure {evalWord M s w}`,
- evaluate every probe in `P` on every state in that closure,
- define the trace as the resulting set of semiring values.

This “set of probe values after closure” is implementable and avoids premature topological complexity.

You should also define:

```lean
def closureReachable
    (M : ClosureSemimoduleSystem σ α K) (s : σ) : Set σ

def inducesSameClosedLanguage
    ...

def ClosureSetoid
    ...

def quotientStep
    ...

def quotientOutput
    ...

def IntrinsicCapacity
    ...

def FiniteProbeRank
    ...

def GeneratedByWordsUpTo
    ...
```

Add at least 10 definitions/structures total. Useful additional notions:

- `ClosureStableProbe`
- `SeparatingProbeFamily`
- `ClosureGenerated`
- `ObservableRealization`
- `MinimalClosureRealization`
- `QuantumCertifiedProbe` (doc-comment bridge to quantum/certified robustness)
- `PostQuantumIndistinguishability` (doc-comment bridge to cryptographic semantics)
- `ThermoKoopmanObservable`

Give doc comments of the form:
```lean
/-- Bridge: connects closure automata to quantum indistinguishability and
certified robustness via probe-invariant observational semantics. -/
```

---

## PRECISE TARGET THEOREMS

You should prove a chain of theorems culminating in a minimal realization result. Use inventive names, not generic names.

### 1. Word evaluation and closure basics
Prove exact recursion and closure monotonicity lemmas.

```lean
@[simp] theorem evalWord_nil
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) :
    evalWord M s [] = s

@[simp] theorem evalWord_cons
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) (a : α) (w : List α) :
    evalWord M s (a :: w) = evalWord M (M.step s a) w

theorem closure_singleton_reachable
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (s : σ) (w : List α) :
    evalWord M s w ∈ M.closure {x | x = evalWord M s w}

theorem closure_idempotent_eq
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K) (S : Set σ)
    (hanti : M.closure (M.closure S) ⊆ M.closure S)
    (hext : M.closure S ⊆ M.closure (M.closure S)) :
    M.closure (M.closure S) = M.closure S
```

### 2. Closure trace extensionality and invariance
Define `ClosureTrace` so that the following are provable:

```lean
theorem closureTrace_nil_formula
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) (s : σ) :
    ClosureTrace M P s [] =
      {k | ∃ x ∈ M.closure {y | y = s}, ∃ p ∈ P.probes, p x = k}

theorem closureTrace_cons_formula
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) (s : σ) (a : α) (w : List α) :
    ClosureTrace M P s (a :: w) = ClosureTrace M P (M.step s a) w

theorem closureTrace_mono_under_probe_enlargement
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    {P Q : ProbeFamily σ K}
    (hPQ : P.probes ⊆ Q.probes) :
    ∀ s w, ClosureTrace M P s w ⊆ ClosureTrace M Q s w
```

### 3. Indistinguishability is an equivalence relation
This is the first major milestone.

```lean
theorem closureIndistinguishable_refl
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    Reflexive (ClosureIndistinguishable M P)

theorem closureIndistinguishable_symm
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    Symmetric (ClosureIndistinguishable M P)

theorem closureIndistinguishable_trans
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    Transitive (ClosureIndistinguishable M P)

def ClosureSetoid
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) : Setoid σ
```

### 4. Congruence under transitions
This is the Myhill-style heart: indistinguishability must be stable under input extension.

```lean
theorem closureIndistinguishable_step_invariant
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    ∀ {s t : σ},
      ClosureIndistinguishable M P s t →
      ∀ a : α, ClosureIndistinguishable M P (M.step s a) (M.step t a)

theorem closureIndistinguishable_word_invariant
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    ∀ {s t : σ},
      ClosureIndistinguishable M P s t →
      ∀ w : List α, ClosureIndistinguishable M P (evalWord M s w) (evalWord M t w)
```

If useful, prove the word version by induction on `w`, with the step version as the base transport lemma.

### 5. Quotient transition system
Define the quotient by the setoid and prove well-definedness of dynamics and outputs.

```lean
def quotientStep
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    Quotient (ClosureSetoid M P) → α → Quotient (ClosureSetoid M P)

def quotientOutput
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    Quotient (ClosureSetoid M P) → Set K
```

Then prove:

```lean
theorem quotientStep_sound
    ...

theorem quotientOutput_sound
    ...

theorem quotientTrace_exact
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) (s : σ) (w : List α) :
    ClosureTrace M P s w =
      quotientOutput M P (evalWord ({
        step := quotientStep M P
        output := quotientOutput M P
        closure := fun S => S
        closure_extensive := by intro S x hx; exact hx
        closure_mono := by intro S T hST x hx; exact hST hx
        closure_idem := by intro S x hx; exact hx
      } : ClosureSemimoduleSystem (Quotient (ClosureSetoid M P)) α (Set K))
      (Quotient.mk _ s) w)
```

If the full statement above is awkward, prove a cleaner extensional version using quotient-lifted evaluation:
```lean
theorem quotient_trace_represents_original ...
```

### 6. Separation and minimality
Introduce a separation hypothesis saying probes distinguish inequivalent classes.

```lean
def SeparatingProbeFamily
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) : Prop :=
  ∀ s t, ¬ ClosureIndistinguishable M P s t →
    ∃ w : List α, ∃ k,
      (k ∈ ClosureTrace M P s w ∧ k ∉ ClosureTrace M P t w) ∨
      (k ∈ ClosureTrace M P t w ∧ k ∉ ClosureTrace M P s w)
```

Prove the quotient is observationally minimal:

```lean
structure ObservableRealization
    (α : Type u) (K : Type v) where
  σ : Type w
  instSemiring : Semiring K := by infer_instance
  sys : ClosureSemimoduleSystem σ α K
  probes : ProbeFamily σ K

def RealizationPreservesTrace
    ...

theorem closure_myhill_quantum_minimality
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    ∀ R : ObservableRealization α K,
      RealizationPreservesTrace M P R →
      ∃ f : Quotient (ClosureSetoid M P) → R.σ, Function.Injective f
```

A finite-cardinality corollary is especially valuable:

```lean
theorem closure_myhill_cardinality_lower_bound
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    [Fintype (Quotient (ClosureSetoid M P))] [Fintype R.σ] :
    RealizationPreservesTrace M P R →
    Fintype.card (Quotient (ClosureSetoid M P)) ≤ Fintype.card R.σ
```

This is the formal automata-theoretic core.

### 7. Intrinsic capacity and explicit finite bounds
Define a computable capacity invariant. At minimum, use finite generation by traces up to bounded word length.

A practical definition:

```lean
def wordsUpTo (α : Type u) : ℕ → Finset (List α) := ...

def traceImageUpTo
    {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] [Fintype α] [DecidableEq α]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) [Fintype σ]
    [DecidableEq σ] [Fintype K] [DecidableEq K] :
    ℕ → Finset (Set K)

def IntrinsicCapacity
    {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] [Fintype α] [DecidableEq α]
    [Fintype σ] [DecidableEq σ] [Fintype K] [DecidableEq K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) : ℕ → ℕ
```

Then prove explicit bounds such as:

```lean
theorem wordsUpTo_card_exponential_bound
    (α : Type u) [Fintype α] [DecidableEq α] :
    ∀ n, (wordsUpTo α n).card ≤ ∑ i in Finset.range (n + 1), (Fintype.card α)^i

theorem intrinsicCapacity_upper_bound_by_state_count
    {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] [Fintype α] [DecidableEq α]
    [Fintype σ] [DecidableEq σ] [Fintype K] [DecidableEq K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    ∀ n, IntrinsicCapacity M P n ≤ Fintype.card σ

theorem intrinsicCapacity_upper_bound_by_trace_space
    {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] [Fintype α] [DecidableEq α]
    [Fintype σ] [DecidableEq σ] [Fintype K] [DecidableEq K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    ∀ n, IntrinsicCapacity M P n ≤ 2 ^ (Fintype.card K)

theorem intrinsicCapacity_monotone
    ...
```

If the exact `2^(card K)` bound is too crude due to trace-set coding, prove a clean finite bound in terms of the cardinality of the codomain of traces. State it explicitly, not vaguely.

### 8. Finite stabilization / reconstruction
A major theorem should say that once trace images stop growing, the quotient has been reconstructed.

```lean
def StabilizesAt
    (c : ℕ → ℕ) (N : ℕ) : Prop :=
  ∀ n ≥ N, c n = c N

theorem finite_capacity_stabilization
    {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] [Fintype α] [DecidableEq α]
    [Fintype σ] [DecidableEq σ] [Fintype K] [DecidableEq K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    ∃ N ≤ Fintype.card σ, StabilizesAt (IntrinsicCapacity M P) N

theorem turing_myhill_reconstruction_from_capacity_plateau
    {σ : Type u} {α : Type v} {K : Type w}
    [Semiring K] [Fintype α] [DecidableEq α]
    [Fintype σ] [DecidableEq σ] [Fintype K] [DecidableEq K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) :
    ∀ N,
      StabilizesAt (IntrinsicCapacity M P) N →
      ∀ s t,
        (∀ w ∈ wordsUpTo α N, ClosureTrace M P s w = ClosureTrace M P t w) →
        ClosureIndistinguishable M P s t
```

This is the “finite-window reconstruction” theorem. It is the precise algebra–EML analogue of Myhill–Nerode finite observation reconstruction.

### 9. Functoriality / simulation
Bridge to category-flavored semantics via simulations.

```lean
structure ClosureSimulation
    {σ₁ : Type u} {σ₂ : Type v} {α : Type w} {K : Type _}
    [Semiring K]
    (M₁ : ClosureSemimoduleSystem σ₁ α K)
    (M₂ : ClosureSemimoduleSystem σ₂ α K) where
  map : σ₁ → σ₂
  step_comm : ∀ s a, map (M₁.step s a) = M₂.step (map s) a
  output_reflects :
    ∀ s, M₁.output s = M₂.output (map s)
  closure_respects :
    ∀ S, Set.image map (M₁.closure S) ⊆ M₂.closure (Set.image map S)
```

Prove:

```lean
theorem simulation_preserves_closureTrace
    ...

theorem simulation_descends_to_quotient
    ...

theorem quantum_koopman_cryptographic_capacity_monotone_under_simulation
    ...
```

The last theorem should assert a monotonicity inequality on `IntrinsicCapacity` under injective or trace-reflecting simulations, with explicit hypotheses.

---

## PROOF STRATEGY

### Strategy A: direct Myhill–Nerode quotient via set-valued traces
This is the most promising path because it avoids difficult semiring-linear algebra while still capturing semiring observability.

1. **Define `evalWord` recursively** and prove `[simp]` lemmas for `[]` and `(::)`.
   - Use induction on lists.
   - The theorem `closureTrace_cons_formula` should become definitional after unfolding.
2. **Define `ClosureIndistinguishable` as equality of traces for all words**:
   ```lean
   def ClosureIndistinguishable ... (s t : σ) : Prop :=
     ∀ w : List α, ClosureTrace M P s w = ClosureTrace M P t w
   ```
   Then `refl/symm/trans` are straightforward by intro/ext/transitivity.
3. **Prove step invariance by precomposition with words**:
   - For `a : α`, to show states after one step are equivalent, fix `w`;
   - compare traces on `a :: w`;
   - rewrite using `closureTrace_cons_formula`.
4. **Build quotient maps using `Quotient.lift`**:
   - well-definedness of `quotientStep` uses `closureIndistinguishable_step_invariant`;
   - well-definedness of `quotientOutput` uses the definition at `[]`.
5. **Minimality**:
   - define the canonical map from quotient classes into any realization preserving traces;
   - prove injective by contradiction:
     if two quotient classes map to the same realizing state, then all traces coincide, contradicting separation.

This route should already yield 12–15 theorems cleanly.

### Strategy B: semiring congruence packaging
Use this if you want deeper algebraic reuse from `AutoResearch/Basic.lean`.

1. Package indistinguishability as a `Setoid`.
2. If existing infrastructure has a `SemiringCong`-style pattern, mimic its quotient transport methods.
3. Prove trace observables are class functions.
4. Lift transition and output maps to the quotient by congruence.

This may produce elegant abstractions and reusable API, but only after the setoid layer is stable.

### Strategy C: finite reconstruction via pigeonhole/cardinality
Best for the capacity/stabilization segment.

1. Show `IntrinsicCapacity M P n` is monotone in `n`.
2. Show it is bounded by the number of equivalence classes or states.
3. Apply finite monotone stabilization:
   a monotone sequence of naturals bounded by `|σ|` stabilizes by time `|σ|`.
4. Use plateau to show every new longer word contributes no new distinctions.
5. Induct on word length to derive full indistinguishability from agreement up to `N`.

This is where `omega`, `linarith`, and cardinal arithmetic should appear.

---

## TACTICAL REQUIREMENTS

Use diverse tactics across the file. In particular, ensure there are proofs employing:

- `induction` on `List α` and on `Nat`
- `rcases` to unpack existential witnesses from trace membership
- `ext` for set equality and function extensionality
- `by_contra` in the separation/minimality proof
- `omega` for finite bound arithmetic
- `linarith` where natural-number inequalities are coerced or simplified
- `simpa` only as a finishing step, not the dominant proof style
- `constructor` / `refine` for structures and equivalence relations
- `Quotient.inductionOn` or `refine Quotient.lift ...`
- `Finite`/`Fintype.card` arguments with explicit inequalities

Do not rely on `simp`-only proofs for the central results.

---

## LEAN-SHAPED AUXILIARY LEMMAS TO INCLUDE

These will make the development robust and file-rich.

```lean
theorem mem_closureTrace_iff
    {σ : Type u} {α : Type v} {K : Type w} [Semiring K]
    (M : ClosureSemimoduleSystem σ α K)
    (P : ProbeFamily σ K) (s : σ) (w : List α) (k : K) :
    k ∈ ClosureTrace M P s w ↔
      ∃ x ∈ M.closure {y | y = evalWord M s w}, ∃ p ∈ P.probes, p x = k

theorem closureIndistinguishable_iff_all_words
    ...

theorem closureIndistinguishable_of_agrees_on_generators
    ...

theorem quotient_evalWord_sound
    ...

theorem wordsUpTo_zero
    ...

theorem wordsUpTo_succ_contains_prefix
    ...

theorem wordsUpTo_mono
    ...

theorem traceImageUpTo_mono
    ...

theorem stabilization_from_bounded_monotone_nat
    (c : ℕ → ℕ) (B : ℕ) :
    Monotone c → (∀ n, c n ≤ B) → ∃ N ≤ B, StabilizesAt c N
```

That last theorem is highly reusable and mathematically important.

---

## COMPUTATIONAL / CAPACITY INTERPRETATION

You must explicitly connect the formal objects to intrinsic computation and algorithmic observability.

Use theorem names and doc comments containing application keywords:

- `quantum`
- `thermodynamic`
- `post_quantum`
- `lattice`
- `certified`
- `koopman`
- `robustness`

Examples of good names:
- `closure_myhill_quantum_minimality`
- `post_quantum_probe_collision_lower_bound`
- `thermodynamic_koopman_capacity_plateau`
- `lipschitz_certified_robustness_via_closure_trace`
- `lattice_indistinguishability_from_probe_kernel`

Even if the theorem is abstract, the doc comment should explain the bridge:
- observational indistinguishability ↔ cryptographic indistinguishability
- closure-stable observables ↔ quantum coarse-graining
- finite reconstruction ↔ certified model extraction / robustness certificates

If a fully quantitative ML/crypto theorem is too ambitious, prove a clean abstract theorem with a precise quantitative corollary in the finite case.

---

## SPECIAL CASES WORTH PROVING IF MAIN PATH STALLS

If the most general semiring-valued setup becomes cumbersome, prove strongest available special cases without sorries:

1. **Boolean semiring / language semantics**
   ```lean
   K = Bool
   ```
   Then traces are finite sets of booleans and many extensionality lemmas simplify.

2. **Identity closure**
   ```lean
   closure := id
   ```
   Then your theory becomes a weighted Myhill–Nerode theorem directly.

3. **Finite state systems**
   Add `[Fintype σ] [DecidableEq σ]` early and prove all capacity/stabilization results.

4. **Singleton probe family**
   Use only `output`; then recover a closure-output language semantics.

State any remaining stronger conjecture precisely, for example:

```lean
conjecture closure_semiring_residual_rank_controls_intrinsicCapacity :
  ...
```

But only after proving the strongest theorem you can.

---

## SIGNIFICANCE TO THE RESEARCH PROGRAM

This development is not a routine automata exercise. It creates a formal bridge between:

- **Myhill–Nerode minimality** and **EML closure dynamics**
- **Koopman-style observable evolution** and **intrinsic computation capacity**
- **cryptographic indistinguishability** and **state-space quotient reconstruction**
- **quantum coarse-graining / thermodynamic macrostates** and **closure-stable semantics**

A successful formalization opens at least three new directions:

1. **Certified model extraction for dynamical systems**: finite-window trace equality implying full equivalence is a formal analogue of certified robustness and system identification.
2. **Post-quantum observational security**: probe families become adversaries; quotient classes become information-theoretic security classes.
3. **Thermodynamic / Koopman coarse-graining**: closure quotient gives a rigorous finite observable macro-dynamics extracted from micro-dynamics.

This file should read like the seed of a new subject: closure automata as a unifying language for intrinsic computation, certified robustness, and quantum/thermodynamic observation.

---

## FUTURE_DIRECTIONS.md REQUIREMENT

Produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, each specific enough to become the next Lean file. Include items such as:

1. semiring-linear Hankel rank versus `IntrinsicCapacity`
2. tropical probe families and `tropical_hash_collision` bounds
3. quantum channel coarse-graining as closure simulations
4. lattice-based probe indistinguishability and `post_quantum_security`
5. entropy/pressure bounds controlling capacity growth rates

Each item should state:
- exact target definition/theorem,
- why it is mathematically revolutionary,
- what existing theorem in this file it builds on.

---

## MINIMUM DELIVERABLE SHAPE

At minimum, the file should contain:

- 10+ new definitions/structures
- 20+ theorems/lemmas
- 1 quotient construction
- 1 minimality theorem
- 1 explicit finite capacity bound
- 1 stabilization theorem
- 1 simulation/functoriality theorem
- zero `sorry`

If you must simplify, keep the narrative intact:
**closure trace → indistinguishability → quotient dynamics → minimality → finite capacity → reconstruction**.

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
            Formalize a reconstruction principle turning finitary EML closure systems into deterministic computational transition structures by extracting a canonical state semimodule of closure-generated observables and a Myhill–Nerode-style congruence on closure traces. Prove that under algebraic compactness/idempotence hypotheses, the quotient trace semimodule is minimal among all semiring-linear realizations of the same closure dynamics, and define an intrinsic computation-capacity invariant from the rank/growth of distinguishable closure traces. This extends the recent Algebraic–EML program in a genuinely new direction: from completion, sheaf, thermodynamic, and Koopman viewpoints to computation semantics and automata reconstruction.

            ### Precise Mathematical Framing
            Let C be a finitary extensive monotone idempotent operator on a semiring-semimodule presentation of observables. Define closure traces generated by iterates of C and finite probe families, and an indistinguishability relation x ~ y when every finite probe sequence yields identical stabilized outputs. Show: (1) ~ is a semiring congruence; (2) the quotient of closure traces carries a canonical deterministic transition action induced by C; (3) this action satisfies a minimality/universality property analogous to Myhill–Nerode among semiring-linear recognizers of the same closure behavior; (4) closure morphisms induce simulation morphisms functorially; (5) the growth rate or finite rank of the quotient yields an intrinsic computation-capacity invariant, with bounds transferred from existing proof-semiring and closure-bialgebra infrastructure. The expected proof package mixes semiring congruences, closure algebra, fixed-point stabilization, and automata-style residualization, while avoiding repetition of prior Stone duality, sheaf, thermodynamic, and phase-space results.

            ### Lean 4 Sketch
Likely implementable in Bridges/AlgebraEMLClosureComputation. Core objects: ClosureTrace, ProbeFamily, ClosureIndistinguishable, induced SemiringCong / Setoid, quotient transition system, minimal realization theorem, functoriality lemmas, capacity invariant via finite generation or rank bounds. Reuse SemiringCong patterns from AutoResearch/Basic.lean and proof-semiring spectrum infrastructure where available.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `quantum_thermodynamic_energy_invariant_under_nerode` : theorem quantum_thermodynamic_energy_invariant_under_nerode
     (file: Bridges/613c6a31_aristotle/Bridges/TropicalAutomataComplexity/TropicalNerode.lean)
  2. `koopman_closure_commutation_reconstruction` : theorem koopman_closure_commutation_reconstruction
     (file: Bridges/ClosureKoopmanReconstruction.lean)
  3. `thermodynamic_entropy_closure_growth` : theorem thermodynamic_entropy_closure_growth
     (file: Bridges/CondensationSemantics.lean)
  4. `quantum_entropy_style_valuation_growth_bound` : theorem quantum_entropy_style_valuation_growth_bound (net : PadicOperadicNetwork K) :
     (file: Bridges/PadicOperadicNetworks.lean)
  5. `closure_drift_bound_iterate_linear` : theorem closure_drift_bound_iterate_linear
     (file: Bridges/ProofStoneCechDynamics.lean)

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
