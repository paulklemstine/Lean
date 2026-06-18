

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

## YOUR ASSIGNMENT: Algebraic–EML Phase-Space Reconstruction via Closure Bialgebras and Koopman Spectra

Work in Lean 4 by building a finite, fully constructive phase-space reconstruction theory for algebraic closures acting on finite observables. The core goal is to formalize a bridge between:

- algebraic closure semantics / idempotent semiring dynamics,
- finite Koopman-style operator spectra,
- prime / character reconstruction ideas,
- and certified bounds relevant to quantum, cryptographic, and ML semantics.

The breakthrough target is not merely “define a Koopman map,” but to prove that a finite closure-driven observable algebra determines a canonical recurrent phase portrait, together with explicit stabilization and Lipschitz-style bounds.

### CENTRAL FORMALIZATION AXIS

Develop a file centered on a finite closure bialgebra of observables over a finite state space, with reconstruction of recurrent classes from characters/eigen-observables.

You should introduce at least the following novel definitions/structures, with typeclass abstraction where possible:

```lean
/-- A closure-compatible idempotent-semiring observable algebra on a finite phase space. -/
class ClosureBialgebra (α σ : Type*) [Semiring α] [Fintype σ] where
  obs : Type*
  instFintypeObs : Fintype obs
  instDecidableEqObs : DecidableEq obs
  eval : obs → σ → α
  closure : obs → obs
  mul_closed : ∀ x y, closure (x * y) = closure (closure x * closure y)
  one_closed : closure 1 = 1
  idempotent_closure : ∀ x, closure (closure x) = closure x
  extensive_closure : ∀ x s, eval x s ≤ eval (closure x) s
  monotone_closure :
    ∀ {x y}, (∀ s, eval x s ≤ eval y s) → ∀ s, eval (closure x) s ≤ eval (closure y) s
```

If the above exact class is too ambitious because of algebra-on-`obs` bookkeeping, introduce a bundled structure instead:

```lean
structure ClosureObservable (α σ : Type*) [Semiring α] [Preorder α] [Fintype σ] where
  carrier : Type*
  instFintypeCarrier : Fintype carrier
  instDecidableEqCarrier : DecidableEq carrier
  instSemiringCarrier : Semiring carrier
  eval : carrier → σ → α
  closure : carrier → carrier
  closure_idem : ∀ x, closure (closure x) = closure x
  closure_mul : ∀ x y, closure (x * y) = closure (closure x * closure y)
  closure_one : closure 1 = 1
  closure_extensive : ∀ x s, eval x s ≤ eval (closure x) s
  closure_monotone :
    ∀ {x y}, (∀ s, eval x s ≤ eval y s) → ∀ s, eval (closure x) s ≤ eval (closure y) s
```

Define at least 10 new concepts, including some version of:

```lean
def koopmanMap
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (f : σ → σ) (φ : σ → α) : σ → α := fun s => φ (f s)

def isClosureInvariant
  (C : β → β) (x : β) : Prop := C x = x

def closureOrbit
  (C : β → β) : ℕ → β → β
| 0, x => x
| n+1, x => C (closureOrbit n x)

def closureStabilizationTime
  [Fintype β] [DecidableEq β]
  (C : β → β) (x : β) : ℕ :=
Nat.findGreatest (fun n => closureOrbit C (n+1) x ≠ closureOrbit C n x) (Fintype.card β)

def recurrentClass
  [Fintype σ] (f : σ → σ) (s : σ) : Finset σ := ...

def Character
  (A : Type*) [Semiring A] :=
A →+* α

def koopmanEigenCharacter
  (f : σ → σ) (χ : Character A) : Prop := ...
```

Also define finite-spectrum and entropy-adjacent notions with explicit application keywords in names and docstrings, e.g.

```lean
def quantum_koopman_energy ...
def post_quantum_closure_hash ...
def lipschitz_certified_robustness_radius ...
def thermodynamic_recurrence_entropy ...
def lattice_phase_separator ...
```

These need not all be deep; some can be computational wrappers that support later theorems.

---

## PRECISE TARGET THEOREMS

Prove a hierarchy of results. If the full generality is difficult, first prove them for finite state spaces `σ` and observables `σ → α`, then lift to bundled closure observables.

### 1. Finite closure stabilization

A realistic first main theorem:

```lean
theorem closure_orbit_eventually_idempotent
  {β : Type*} [Fintype β] [DecidableEq β]
  (C : β → β)
  (hidem : ∀ x, C (C x) = C x) :
  ∀ x ∃ n ≤ Fintype.card β, closureOrbit C (n+1) x = closureOrbit C n x
```

Strengthen to the explicit one-step stabilization expected from idempotence:

```lean
theorem closure_orbit_stabilizes_after_one
  {β : Type*}
  (C : β → β)
  (hidem : ∀ x, C (C x) = C x) :
  ∀ x, closureOrbit C 2 x = closureOrbit C 1 x
```

Then derive a finite-cardinality certified bound:

```lean
theorem closure_stabilizationTime_le_card
  {β : Type*} [Fintype β] [DecidableEq β]
  (C : β → β)
  (hmono : True) :
  ∀ x, closureStabilizationTime C x ≤ Fintype.card β
```

Even if the actual orbit stabilizes at time `1`, keep the `≤ card β` theorem because it gives the desired computational bound.

### 2. Koopman reconstruction of recurrent classes

For finite dynamics `f : σ → σ`, define eventual image / recurrent support and prove existence of periodic representatives:

```lean
theorem finite_dynamics_eventually_periodic
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (f : σ → σ) :
  ∀ s : σ, ∃ m n : ℕ, m < n ∧ (f^[m]) s = (f^[n]) s
```

```lean
theorem recurrentClass_nonempty
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (f : σ → σ) (s : σ) :
  (recurrentClass f s).Nonempty
```

```lean
theorem recurrentClass_forward_invariant
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (f : σ → σ) (s t : σ) :
  t ∈ recurrentClass f s → f t ∈ recurrentClass f s
```

```lean
theorem recurrentClass_contains_periodic_point
  {σ : Type*} [Fintype σ] [DecidableEq σ]
  (f : σ → σ) (s : σ) :
  ∃ t ∈ recurrentClass f s, ∃ n > 0, (f^[n]) t = t
```

This is the combinatorial phase-space backbone.

### 3. Observable separation and finite spectral reconstruction

For observables `φ : σ → α`, prove that composition by `f` defines a semiring endomorphism when pointwise structure exists:

```lean
def koopmanEnd
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α]
  (f : σ → σ) : (σ → α) →+* (σ → α)
```

Then prove:

```lean
theorem koopmanEnd_apply
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α]
  (f : σ → σ) (φ : σ → α) (s : σ) :
  koopmanEnd f φ s = φ (f s)
```

Define a finite “character” by evaluation at a state:

```lean
def evalCharacter
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α]
  (s : σ) : (σ → α) →+* α
```

and prove the reconstruction identity:

```lean
theorem evalCharacter_koopman_intertwines
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α]
  (f : σ → σ) (s : σ) :
  (evalCharacter (f s)).comp (koopmanEnd f) = evalCharacter s
```

This theorem is the exact algebraic shadow of phase-space evolution.

Then prove a finite-state separation theorem, ideally over `α = Bool` or `α = ℕ` first:

```lean
theorem observables_separate_states
  {σ : Type*} [Fintype σ] [DecidableEq σ] :
  ∀ s t : σ, s ≠ t → ∃ φ : σ → Bool, φ s = true ∧ φ t = false
```

Use this to show that equality of all evaluation characters implies equality of states:

```lean
theorem character_extensional_phase_reconstruction
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α] [Nontrivial α]
  (s t : σ) :
  (∀ φ : σ → α, φ s = φ t) → s = t
```

This is a rigorous finite Tannaka/Koopman reconstruction principle.

### 4. Closure-compatible spectral semantics

Define closure-fixed observables:

```lean
def closureFixedSubsemiring
  (O : ClosureObservable α σ) : Set O.carrier := {x | O.closure x = x}
```

If full subsemiring machinery is cumbersome, work with a predicate and prove closure/fixedness lemmas.

Then prove:

```lean
theorem koopman_preserves_closure_fixed
  (O : ClosureObservable α σ)
  (f : σ → σ)
  (hcomm : ∀ x, O.closure ( ... koopman action on x ... ) = ... koopman action on (O.closure x) ... ) :
  ∀ x, isClosureInvariant O.closure x → isClosureInvariant O.closure (...koopman action on x...)
```

In a simpler function-space model where `closure : (σ → α) → (σ → α)`, prove:

```lean
theorem koopman_closure_commutation_reconstruction
  {σ α : Type*}
  [Fintype σ] [DecidableEq σ] [Preorder α] [Semiring α]
  (f : σ → σ)
  (C : (σ → α) → (σ → α))
  (hidem : ∀ φ, C (C φ) = C φ)
  (hcomm : ∀ φ, C (koopmanMap f φ) = koopmanMap f (C φ)) :
  ∀ φ, isClosureInvariant C φ → isClosureInvariant C (koopmanMap f φ)
```

This theorem should be presented as the algebraic engine for EML phase-space semantics.

### 5. Certified quantitative bounds

Introduce explicit computable quantities, even in a finite combinatorial form:

```lean
def observableHammingDist
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [DecidableEq α]
  (φ ψ : σ → α) : ℕ := Fintype.card {s // φ s ≠ ψ s}

def lipschitz_certified_robustness_radius
  {σ α : Type*} [Fintype σ] [PseudoMetricSpace α]
  (K : ℝ) (margin : ℝ) : ℝ := margin / (2 * K + 1)

def thermodynamic_recurrence_entropy
  {σ : Type*} [Fintype σ] (f : σ → σ) : ℝ :=
  Real.log (Nat.card {C // True} + 1)
```

Then prove concrete inequalities, for example:

```lean
theorem observableHammingDist_triangle
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [DecidableEq α]
  (φ ψ ξ : σ → α) :
  observableHammingDist φ ξ ≤ observableHammingDist φ ψ + observableHammingDist ψ ξ
```

```lean
theorem lipschitz_certified_robustness_radius_nonneg
  (K margin : ℝ) (hK : 0 ≤ K) (hm : 0 ≤ margin) :
  0 ≤ lipschitz_certified_robustness_radius K margin
```

```lean
theorem closure_iterate_runtime_bound
  {β : Type*} [Fintype β] [DecidableEq β]
  (C : β → β) :
  ∀ x, ∃ n ≤ Fintype.card β + 1, closureOrbit C (n+1) x = closureOrbit C n x
```

State this in doc comments as an `O(|β|)` certified stabilization theorem for ML / cryptographic state summarization.

### 6. Reconstruction from characters of finite observable algebras

If feasible, define a finite subalgebra generated by a finite family of observables and prove a restricted reconstruction theorem.

A suggested signature:

```lean
def generatedObservableSet
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α]
  (S : Finset (σ → α)) : Finset (σ → α) := ...

def finiteCharacterFamily
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α]
  (S : Finset (σ → α)) := σ → (∀ φ ∈ generatedObservableSet S, α)
```

Then prove a finite reconstruction statement of the form:

```lean
theorem finite_spectral_reconstruction_bridge
  {σ α : Type*} [Fintype σ] [DecidableEq σ] [Semiring α] [Nontrivial α]
  (S : Finset (σ → α))
  (hsep : ∀ s t, s ≠ t → ∃ φ ∈ generatedObservableSet S, φ s ≠ φ t) :
  ∀ s t, (∀ φ ∈ generatedObservableSet S, φ s = φ t) → s = t
```

This is the exact finite-spectrum version of “phase-space reconstruction from observables.”

---

## PROOF STRATEGY

Use several proof modes deliberately; do not let the file collapse into only `simp`.

### Strategy A: Finite pigeonhole dynamics + iterate algebra
Best for recurrent classes and periodicity.

1. Use `Finite`/`Fintype.card` and the orbit segment
   `s, f s, (f^[2]) s, ..., (f^[card σ]) s`.
2. Prove repetition via `Fintype.exists_ne_map_eq_of_card_lt`-style finite counting, or a direct `Finset`/list argument if library search is easier.
3. Extract `m < n` with `(f^[m]) s = (f^[n]) s`.
4. Set `t := (f^[m]) s`, let `k := n - m`, and prove `(f^[k]) t = t`.
5. Use `rcases`, `obtain`, `omega` for arithmetic, and `simpa [Function.iterate_add_apply]`.

### Strategy B: Pointwise semiring-hom algebra
Best for Koopman and character intertwinings.

1. Define `koopmanEnd f` as precomposition.
2. Prove preservation of `0`, `1`, `+`, `*` by extensionality:
   `ext s <;> rfl`.
3. Define `evalCharacter s`.
4. Prove equality of semiring homs using `ext φ <;> rfl`.
5. For phase reconstruction, use indicator observables:
   `φ := fun x => if x = s then 1 else 0`.
   Then `by_cases h : t = s`; use `simp [h]` and `Nontrivial` to separate.

### Strategy C: Closure dynamics as idempotent condensation
Best for closure-fixed semantics.

1. Prove by induction:
   ```lean
   theorem closureOrbit_succ ...
   theorem closureOrbit_of_fixed ...
   theorem closureOrbit_ge_one_eq_closure ...
   ```
2. Use `induction n with`
   and rewrite with `hidem`.
3. For commutation with Koopman, rewrite
   `C (koopmanMap f φ)` into `koopmanMap f (C φ)` using `hcomm`.
4. If `φ` is fixed, substitute `C φ = φ` and conclude.
5. Package the result as a “spectral semantics preservation” theorem.

### Strategy D: Quantitative bounds by subset cardinality
Best for Hamming distance and explicit rates.

1. Express disagreement sets as finite subtypes.
2. Use subset inclusions to prove triangle inequalities.
3. Convert cardinality inequalities with `Finset.card_union_le`.
4. Use `linarith`, `nlinarith`, or `omega` for numeric bounds.
5. State the algorithmic meaning in comments: `O(|σ|)` orbit scan, `O(|σ| log |σ|)` if sorting/reindexing finite supports is introduced.

---

## REQUIRED THEOREM CLUSTERS

Produce at least 20 theorems, with at least 10 substantial proofs. Include theorem names that visibly encode cross-domain significance. Suggested list:

```lean
theorem quantum_koopman_energy_monotone ...
theorem thermodynamic_recurrence_entropy_nonneg ...
theorem post_quantum_closure_hash_stable_under_idempotent_round ...
theorem lipschitz_certified_robustness_radius_nonneg ...
theorem closure_orbit_zero ...
theorem closure_orbit_one ...
theorem closure_orbit_succ ...
theorem closure_orbit_ge_one_eq_closure ...
theorem closure_fixed_iff_stabilizes_immediately ...
theorem closure_orbit_eventually_idempotent ...
theorem closure_iterate_runtime_bound ...
theorem finite_dynamics_eventually_periodic ...
theorem recurrentClass_nonempty ...
theorem recurrentClass_forward_invariant ...
theorem recurrentClass_contains_periodic_point ...
theorem koopmanEnd_apply ...
theorem koopmanEnd_iterate_formula ...
theorem evalCharacter_koopman_intertwines ...
theorem observables_separate_states ...
theorem character_extensional_phase_reconstruction ...
theorem finite_spectral_reconstruction_bridge ...
theorem koopman_closure_commutation_reconstruction ...
theorem closure_fixed_observable_quantum_certified ...
theorem lattice_phase_separator_exists ...
theorem tropical_hash_collision_obstruction ...
```

If some of the physics/crypto/ML-named theorems are wrappers around the core finite combinatorics, that is acceptable; but they must have precise statements and proofs, not decorative names.

---

## LEAN-SPECIFIC IMPLEMENTATION GUIDANCE

Prefer realizable finite models first:

- `σ` finite state space.
- observables as functions `σ → α`.
- `α = Bool`, `ℕ`, or a general `[Semiring α]`.
- closure as an endomap on observables.

This minimizes category-theoretic overhead while preserving the conceptual breakthrough.

Useful type signatures to target:

```lean
def koopmanMap {σ α} (f : σ → σ) (φ : σ → α) : σ → α
def koopmanEnd {σ α} [Semiring α] (f : σ → σ) : (σ → α) →+* (σ → α)
def evalCharacter {σ α} [Semiring α] (s : σ) : (σ → α) →+* α
def closureOrbit {β} (C : β → β) : ℕ → β → β
def recurrentClass {σ} [Fintype σ] [DecidableEq σ] (f : σ → σ) (s : σ) : Finset σ
def observableHammingDist ...
def generatedObservableSet ...
```

Use these proof tools somewhere in the file:

- `induction`
- `rcases`
- `obtain`
- `by_contra`
- `omega`
- `linarith`
- `field_simp` for radius inequalities over `ℝ`
- `ext`
- `simp`
- `aesop` only as support, not as the whole proof

Where full generality is difficult, prove specialized versions such as:

```lean
theorem observables_separate_states_bool
  {σ : Type*} [Fintype σ] [DecidableEq σ] :
  ∀ s t : σ, s ≠ t → ∃ φ : σ → Bool, φ s = true ∧ φ t = false
```

and then lift to a general semiring via `0`/`1` if `[Nontrivial α]`.

---

## SIGNIFICANCE TO THE RESEARCH PROGRAM

This development should formalize a new bridge: closure semantics in algebraic EML can be read as a finite dynamical system whose Koopman algebra of observables reconstructs recurrent phase structure. That creates a common formal language for:

- **quantum / thermodynamic semantics**: observables, recurrence, entropy-like invariants;
- **cryptographic semantics**: finite closure rounds, state compression, post-quantum hash-style stabilization;
- **certified ML semantics**: Lipschitz-style robustness certificates for finite abstract state transitions.

The key conceptual deliverable is a rigorous finite theorem schema:

> closure-fixed observable algebra + Koopman intertwining + observable separation  
> ⇒ reconstructible recurrent phase portrait with explicit stabilization bounds.

This is exactly the kind of algebraic reconstruction principle that can later be lifted to prime spectra, idempotent geometry, tropical semantics, and Tannakian duality.

---

## MINIMUM FILE NARRATIVE

Organize the file as a coherent mathematical story:

1. finite closure iteration primitives,
2. finite recurrence classes for endomaps,
3. Koopman semiring endomorphisms on observables,
4. characters and extensional reconstruction,
5. closure-commuting spectral semantics,
6. quantitative certified bounds and application wrappers.

Aim for a rich development, not isolated lemmas.

---

## IF THE FULL TARGET IS TOO STRONG

Then prove the strongest complete special case with zero sorries:

- finite `σ`,
- observables `σ → Bool` or `σ → ℕ`,
- closure an idempotent endomap on observables,
- reconstruction from evaluation characters,
- recurrent classes as periodic tails of finite orbits.

State the remaining stronger conjecture explicitly, for example:

```lean
theorem conjectural_prime_spectral_phase_reconstruction
  (O : ClosureObservable α σ) :
  ...
```

but only after proving a substantial finite foundation.

---

## FUTURE_DIRECTIONS.md

Also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps, such as:

1. lift finite evaluation characters to prime-spectrum characters of idempotent semiring observables;
2. define a genuine closure-fixed subsemiring and prove a finite Tannaka duality statement;
3. connect thermodynamic recurrence entropy to Stone/prime entropy constructions;
4. derive certified robustness bounds for abstract neural transition systems via closure-Koopman contraction;
5. formalize a post-quantum_security theorem where closure stabilization bounds control finite-state hash collision depth.

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
            Develop a mathematically precise reconstruction principle turning finitary EML closure dynamics into an algebraic phase-space object equipped with a linearized Koopman-style action on observables, and prove that spectral data of the closure bialgebra determines recurrent fixed-point structure and entropy-like growth invariants. Concretely: define a closure bialgebra attached to an EML system by combining closure composition with an idempotent comultiplication on observable predicates; construct its prime/character space; prove a reconstruction theorem showing that under algebraicity and finite generation hypotheses, the original closure dynamics can be recovered from the spectrum-preserving endomorphisms of this bialgebra; and derive an algorithmic pipeline for computing eventual periodicity and fixed-point capacity from finite spectral summaries. This extends the successful Algebraic–EML spectral and coding lines, but is distinct from in-flight Stone-Cech completion, sheaf representation, and thermodynamic formalism because it introduces a dynamical linearization layer rather than a topological completion or Gibbs-pressure semantics.

            ### Precise Mathematical Framing
            Let C be a finitary extensive monotone idempotent operator on a finite or Noetherian semiring-enriched predicate algebra A. Define Obs(C) as the semiring of closure-stable observables and equip it with an endomorphism U_C(f)=f∘C on suitable predicate-valued functions. Introduce a closure bialgebra structure (B_C,m,Delta) where multiplication encodes conjunction/composition and comultiplication encodes observable splitting along closure-generated joins. Prove: (1) functoriality of C↦B_C under closure morphisms; (2) existence of a prime character spectrum Spec(B_C) carrying a canonical transition relation induced by U_C; (3) a reconstruction statement analogous to Tannaka/Koopman duality: if C is algebraic and separation by observables holds, then C is uniquely determined by the spectral action of U_C on characters of B_C; (4) spectral radius or cycle decomposition invariants bound fixed-point capacity and eventual periodic orbit length; (5) finite truncations of B_C yield an algorithm to certify stabilization and detect recurrent classes. This is a cross-domain synthesis of algebraic reconstruction, dynamical systems, and EML semantics, exploiting the large Algebra and EML infrastructure while avoiding repetition of existing prime-closure, Stone duality, and fixed-point projects.

            ### Lean 4 Sketch
Likely implementable by extending existing closure/operator structures from EML and prime-spectrum constructions from Bridges. Core definitions: ClosureBialgebra, ClosureObservable, koopmanMap, Character, recurrentClass. Key lemmas should use semiring homs, finite generated subalgebras, and existing spectral semantics APIs. A realistic file could build finite-spectrum reconstruction first, then derive stabilization bounds for closure iterates on finite predicate algebras.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `prime_spectral_gibbs_variational_principle` : theorem prime_spectral_gibbs_variational_principle
     (file: Bridges/GibbsPosterior.lean)
  2. `diagonal_fixed_point_idempotent` : theorem diagonal_fixed_point_idempotent (f : H → H) :
     (file: Bridges/EMLClosureCore.lean)
  3. `finite_witness_of_eventual_growth_gap` : theorem finite_witness_of_eventual_growth_gap {α : Type*}
     (file: Bridges/EntropyClosureSeparation.lean)
  4. `closure_has_least_fixed_point` : theorem closure_has_least_fixed_point {α : Type*} [CompleteLattice α]
     (file: Bridges/QuantumTropicalCore.lean)
  5. `thermodynamic_stone_prime_completeness` : theorem thermodynamic_stone_prime_completeness
     (file: Bridges/ThermodynamicStonePrimeCompleteness.lean)

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



Recent successful concepts: Vector-Valued Ultrametric Neural Network Certification via Width-Free Operator Lipschitz Calculus, Arithmetic–Berkovich Cell Decomposition and Height-Sensitive Region Counting for Rational Operadic Networks, Berggren–Residual Automata Correspondence for Primitive Triple Languages and Orbit-Minimal Quantum Control


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
