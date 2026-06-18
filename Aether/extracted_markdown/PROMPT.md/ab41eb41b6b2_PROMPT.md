

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

## Algebra–Speculative Fixed-Point Logic via Proof-Semiring Diagonalization and Chronometric Incompleteness Bounds

### Core formalization target

Work in a finite, computable proof-semiring setting where “sentences” are coded by a finite type, unary operators are coded endomorphisms, and semantic equivalence is represented by a semiring congruence. Formalize a diagonalization framework that is weak enough to be fully constructive on finite supports, but strong enough to prove a genuine fixed-point/trichotomy theorem with explicit stabilization bounds.

The central bridge is:

- **algebra / semiring congruence theory**
- **temporal logic / self-reference**
- **computational complexity**
- **cryptographic and certified-robustness metaphors**

Use theorem names and doc comments with explicit application keywords:
`quantum`, `thermodynamic`, `post_quantum_security`, `lipschitz_certified_robustness`, `lattice`, `certified`, `chronometric`, `diagonal`, `fixedPoint`.

---

## File-level deliverable

Create one substantial Lean file formalizing a complete narrative around finite proof semirings, coded unary operators, diagonal classes, eventual stabilization, obstruction certificates, and fixed-point trichotomy. The file should contain:

- **10+ new definitions / structures / classes**
- **20+ theorem statements**
- **10+ proved theorems**
- **zero sorries**
- explicit finite bounds such as `≤ Fintype.card α`, `≤ m + Fintype.card α`, `O(n^2)` encoded as concrete polynomial inequalities over naturals

If the strongest theorem is too ambitious, prove the strongest finite special case with exact bounds and state the full generalization precisely as a conjecture.

---

## New definitions and structures to introduce

You should define at least the following, with computable data and minimal hypotheses.

### 1. Finite proof-semiring presentation

```lean
structure FiniteProofSemiring (α : Type _) [Fintype α] [DecidableEq α] [Semiring α] where
  codeWeight : α → ℕ
  codeWeight_zero : codeWeight 0 = 0
  codeWeight_add : ∀ a b, codeWeight (a + b) ≤ codeWeight a + codeWeight b
  codeWeight_mul : ∀ a b, codeWeight (a * b) ≤ codeWeight a + codeWeight b
```

### 2. Coded unary operator

```lean
structure CodedUnaryOp (α : Type _) where
  toFun : α → α
  cost : ℕ
```

Add coercion to function and extensionality lemmas.

### 3. Semiring congruence dynamics package

Use the existing semiring congruence APIs. Bundle an operator preserving a congruence:

```lean
structure CongruenceRespectingOp (α : Type _) [Semiring α] (ρ : Setoid α) where
  op : α → α
  resp : ∀ ⦃a b⦄, a ≈ b → op a ≈ op b
```

If there is an existing semiring-congruence object in the catalog, specialize to that object rather than plain `Setoid`, but give an interface theorem from your structure to the catalog object.

### 4. Diagonal class

```lean
def IsDiagonalClass
  {α : Type _} (ρ : Setoid α) (D : Set α) : Prop :=
  ∀ f : α → α, ∃ x, x ∈ D ∧ ρ.r (f x) x
```

Also define a bounded finite-support version:

```lean
def IsBoundedDiagonalClass
  {α : Type _} [Fintype α] (ρ : Setoid α) (D : Set α) (N : ℕ) : Prop :=
  ∀ f : α → α, ∃ x, x ∈ D ∧ ρ.r (f x) x ∧ Fintype.card α ≤ N
```

### 5. Eventual stabilization

```lean
def StabilizesBy
  {α : Type _} (ρ : Setoid α) (f : α → α) (N : ℕ) : Prop :=
  ∀ x, ∃ n ≤ N, ρ.r ((f^[n+1]) x) ((f^[n]) x)
```

And orbit-wise stabilization index:

```lean
def stabilizationIndex
  {α : Type _} [Fintype α] [DecidableEq α] (ρ : Setoid α) (f : α → α) (x : α) : ℕ := ...
```

You may implement this via `Nat.find` on a pigeonhole lemma.

### 6. Obstruction certificate

```lean
structure ObstructionCertificate
  {α : Type _} (ρ : Setoid α) (f : α → α) where
  witness : α
  separates : ∀ n, ¬ ρ.r ((f^[n+1]) witness) ((f^[n]) witness)
```

And a bounded finite obstruction:

```lean
structure BoundedObstructionCertificate
  {α : Type _} [Fintype α] (ρ : Setoid α) (f : α → α) where
  witness : α
  horizon : ℕ
  separates_upto : ∀ n ≤ horizon, ¬ ρ.r ((f^[n+1]) witness) ((f^[n]) witness)
```

### 7. Chronometric incompleteness bound

```lean
def ChronometricIncompletenessBound
  {α : Type _} [Fintype α] (ρ : Setoid α) (f : α → α) : ℕ :=
  Fintype.card α
```

Later prove this is a valid stabilization horizon modulo congruence in the finite quotient setting.

### 8. Quotient-separated dynamics

```lean
def QuotientInjectiveStep
  {α : Type _} (ρ : Setoid α) (f : α → α) : Prop :=
  ∀ ⦃a b⦄, ρ.r (f a) (f b) → ρ.r a b
```

### 9. Fixed-point modulo congruence

```lean
def HasCongruenceFixedPoint
  {α : Type _} (ρ : Setoid α) (f : α → α) : Prop :=
  ∃ x, ρ.r (f x) x
```

### 10. Symmetric temporal pair / time-reversal witness

```lean
structure TimeReversalWitness
  {α : Type _} (ρ : Setoid α) (f g : α → α) where
  left_inv_mod : ∀ x, ρ.r (g (f x)) x
  right_inv_mod : ∀ x, ρ.r (f (g x)) x
```

Use this to connect “chronometric” semantics to algebraic reversibility and physics-flavored doc comments.

---

## Main theorem cluster to prove

You should aim for a theorem family, not a single theorem.

### A. Finite orbit stabilization modulo congruence

Precise target:

```lean
theorem chronometric_stabilizes_by_card
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f : α → α) :
  StabilizesBy ρ f (Fintype.card α) := ...
```

A stronger and more useful quotient-cardinality form is even better if you can formalize finite quotient cardinality:

```lean
theorem chronometric_stabilizes_by_quotient_card
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f : α → α) :
  ∀ x, ∃ n ≤ Fintype.card (Quotient ρ), ρ.r ((f^[n+1]) x) ((f^[n]) x) := ...
```

This is the computational backbone. It gives an explicit chronometric bound.

### B. Diagonal fixed-point existence modulo congruence

Target:

```lean
theorem diagonal_fixedPoint_mod_congruence
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (D : Set α)
  (hD : IsDiagonalClass ρ D)
  (f : α → α) :
  ∃ x, x ∈ D ∧ ρ.r (f x) x := ...
```

This should be a direct use of the diagonal-class axiom with `f` as witness, but enrich it by proving compatibility lemmas for congruence-respecting operators and for operators induced on quotient types.

### C. Trichotomy theorem

Formalize a genuine trichotomy. For a congruence-respecting operator on a finite proof semiring, one of three alternatives holds:

1. congruence fixed point exists;
2. bounded obstruction certificate exists up to the chronometric horizon;
3. there is a nontrivial cycle modulo congruence.

A possible statement:

```lean
def HasNontrivialCongruenceCycle
  {α : Type _} (ρ : Setoid α) (f : α → α) : Prop :=
  ∃ x n, 0 < n ∧ ρ.r ((f^[n]) x) x

theorem proofSemiring_diagonal_chronometric_trichotomy
  {α : Type _} [Fintype α] [DecidableEq α] [Semiring α]
  (ρ : Setoid α) (f : α → α) :
  HasCongruenceFixedPoint ρ f
  ∨ BoundedObstructionCertificate ρ f
  ∨ HasNontrivialCongruenceCycle ρ f := ...
```

Refine this to ensure the obstruction horizon is bounded by `Fintype.card α`, e.g.

```lean
theorem proofSemiring_diagonal_chronometric_trichotomy_bounded
  {α : Type _} [Fintype α] [DecidableEq α] [Semiring α]
  (ρ : Setoid α) (f : α → α) :
  HasCongruenceFixedPoint ρ f
  ∨ (∃ c : BoundedObstructionCertificate ρ f, c.horizon ≤ Fintype.card α)
  ∨ HasNontrivialCongruenceCycle ρ f := ...
```

### D. Time-reversal symmetry and stabilization equivalence

```lean
theorem timeReversal_certified_stabilization_equivalence
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f g : α → α)
  (htr : TimeReversalWitness ρ f g) :
  StabilizesBy ρ f (Fintype.card α) ↔ StabilizesBy ρ g (Fintype.card α) := ...
```

This bridges algebraic reversibility with physics-flavored “chronometric” symmetry.

### E. Quantitative bounds for coded operators

Assume a weight function from `FiniteProofSemiring`. Prove orbit complexity bounds:

```lean
theorem codedUnaryOp_iterate_weight_bound
  {α : Type _} [Fintype α] [DecidableEq α] [Semiring α]
  (S : FiniteProofSemiring α) (f : CodedUnaryOp α) :
  ∀ x n, S.codeWeight ((f.toFun^[n]) x) ≤ S.codeWeight x + n * f.cost := ...
```

If linear growth is too strong without hypotheses, define a class of weight-controlled operators:

```lean
structure WeightControlledOp
  {α : Type _} [Semiring α] (S : FiniteProofSemiring α) where
  op : α → α
  cost : ℕ
  bound : ∀ x, S.codeWeight (op x) ≤ S.codeWeight x + cost
```

Then prove the iterate bound.

This is important for utility and “algorithmic shadow”.

---

## Strong theorem names to include

Use inventive names, not generic names. Suggested theorem names:

- `chronometric_pigeonhole_fixedPoint`
- `diagonal_echo_quantum_certificate`
- `proofSemiring_thermodynamic_trichotomy`
- `post_quantum_security_obstruction_or_cycle`
- `lipschitz_certified_robustness_of_congruence_iterates`
- `tropical_hash_collision_via_finite_orbit`
- `quantum_timeReversal_mod_congruence`
- `lattice_diagonal_resonance_bound`
- `certified_temporal_selfReference`
- `entropy_style_orbit_compression`

Not all need to be mathematically deep, but each should correspond to a precise statement and bridge in doc comments.

---

## Concrete theorem statements to include

Prove as many of the following as possible. At least 10 should be fully proved.

```lean
theorem stabilizationIndex_le_card
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f : α → α) (x : α) :
  stabilizationIndex ρ f x ≤ Fintype.card α := ...
```

```lean
theorem hasCongruenceFixedPoint_of_stabilizes_at_zero
  {α : Type _} (ρ : Setoid α) (f : α → α) :
  (∃ x, ρ.r (f x) x) → HasCongruenceFixedPoint ρ f := ...
```

```lean
theorem quotientInjectiveStep_no_short_collapse
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f : α → α)
  (hinj : QuotientInjectiveStep ρ f) :
  ∀ x n, ρ.r ((f^[n+1]) x) ((f^[n]) x) → HasNontrivialCongruenceCycle ρ f := ...
```

```lean
theorem boundedObstruction_or_stabilization
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f : α → α) :
  (∃ c : BoundedObstructionCertificate ρ f, c.horizon ≤ Fintype.card α)
  ∨ StabilizesBy ρ f (Fintype.card α) := ...
```

```lean
theorem diagonalClass_nonempty
  {α : Type _} (ρ : Setoid α) (D : Set α)
  (hD : IsDiagonalClass ρ D) :
  D.Nonempty := ...
```

```lean
theorem diagonalClass_fixedPoint_for_respectingOp
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (D : Set α)
  (hD : IsDiagonalClass ρ D)
  (f : CongruenceRespectingOp α ρ) :
  ∃ x, x ∈ D ∧ ρ.r (f.op x) x := ...
```

```lean
theorem finite_orbit_eventually_periodic_mod_congruence
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f : α → α) (x : α) :
  ∃ m n, m < n ∧ ρ.r ((f^[m]) x) ((f^[n]) x) := ...
```

```lean
theorem eventual_periodicity_yields_cycle
  {α : Type _}
  (ρ : Setoid α) (f : α → α) (x : α)
  {m n : ℕ} (h : m < n) :
  ρ.r ((f^[m]) x) ((f^[n]) x) →
  HasNontrivialCongruenceCycle ρ f := ...
```

```lean
theorem weightControlled_iterate_affine_bound
  {α : Type _} [Semiring α] [Fintype α] [DecidableEq α]
  (S : FiniteProofSemiring α) (f : WeightControlledOp S) :
  ∀ x n, S.codeWeight ((f.op^[n]) x) ≤ S.codeWeight x + n * f.cost := ...
```

```lean
theorem entropy_style_orbit_compression
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f : α → α) :
  ∀ x, ∃ n ≤ Fintype.card α, ρ.r ((f^[n+1]) x) ((f^[n]) x) := ...
```

```lean
theorem post_quantum_security_obstruction_or_cycle
  {α : Type _} [Fintype α] [DecidableEq α] [Semiring α]
  (ρ : Setoid α) (f : α → α) :
  (∃ c : BoundedObstructionCertificate ρ f, c.horizon ≤ Fintype.card α)
  ∨ HasNontrivialCongruenceCycle ρ f
  ∨ HasCongruenceFixedPoint ρ f := ...
```

```lean
theorem quantum_timeReversal_mod_congruence
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (f g : α → α)
  (htr : TimeReversalWitness ρ f g) :
  HasCongruenceFixedPoint ρ f ↔ HasCongruenceFixedPoint ρ g := ...
```

```lean
theorem lipschitz_certified_robustness_of_congruence_iterates
  {α : Type _} [Fintype α] [DecidableEq α] [Semiring α]
  (S : FiniteProofSemiring α) (f : WeightControlledOp S) :
  ∀ x n, S.codeWeight ((f.op^[n]) x) - S.codeWeight x ≤ n * f.cost := ...
```

If subtraction on naturals becomes awkward, restate with `≤` only.

---

## Proof architecture and tactics

Use multiple proof styles. Do not rely only on `simp`.

### Strategy 1: Finite orbit / pigeonhole / quotient route
Most promising for the main stabilization and trichotomy theorems.

1. Prove a finite orbit repetition lemma:
   - map `i ↦ Quotient.mk _ ((f^[i]) x)` on indices `0..card`
   - use finite pigeonhole on `Fintype.card α + 1` iterates
   - obtain `m < n` with equal quotient classes
2. Convert equality in the quotient to `ρ.r ((f^[m]) x) ((f^[n]) x)`.
3. Specialize either to adjacent repetition or derive eventual periodicity.
4. Extract a cycle or a fixed-point modulo congruence.
5. Bound all indices by `Fintype.card α`.

Tactics likely useful:
- `classical`
- `by_contra`
- `rcases`
- `obtain ⟨...⟩ := ...`
- `simpa [Function.iterate_succ]`
- `omega` for arithmetic on naturals
- `linarith` if integers/reals appear in auxiliary weight bounds

### Strategy 2: Induction on iterate count for weight/cost bounds
Best for utility theorems.

1. Define weight-controlled operators.
2. Prove base case `n = 0` by simp.
3. Inductive step:
   - rewrite `Function.iterate_succ`
   - apply operator bound
   - combine with induction hypothesis
   - close arithmetic using `omega` or `nlinarith`
4. Derive affine complexity bounds and “certified robustness” corollaries.

### Strategy 3: Diagonal-class route
Best for fixed-point existence.

1. Unfold `IsDiagonalClass`.
2. Apply it to the chosen operator.
3. Obtain witness `x ∈ D` with `ρ.r (f x) x`.
4. Repackage into `HasCongruenceFixedPoint ρ f`.
5. Extend from raw functions to congruence-respecting operators.

### Strategy 4: Contrapositive / obstruction route
Useful for the trichotomy.

1. Assume no congruence fixed point.
2. For each `x`, all adjacent iterates are separated.
3. In finite horizon, package this as a `BoundedObstructionCertificate`.
4. If separation cannot persist beyond cardinality bound, use finite orbit repetition to derive a nontrivial cycle.
5. Thus obtain the trichotomy.

### Strategy 5: Symmetry / time reversal route
For the physics bridge.

1. Use `TimeReversalWitness` to transfer fixed-point and stabilization properties.
2. Compose relations `ρ.r (g (f x)) x` and `ρ.r (f (g x)) x`.
3. Show any modulo-ρ fixed point for `f` transports to one for `g`.
4. State doc comments as “Bridge: connects chronometric reversibility to quantum/thermodynamic symmetry.”

---

## Suggested auxiliary lemmas

You will likely need the following helpers.

```lean
lemma iterate_respects_setoid
  {α : Type _} (ρ : Setoid α) (f : CongruenceRespectingOp α ρ) :
  ∀ n ⦃a b⦄, ρ.r a b → ρ.r ((f.op^[n]) a) ((f.op^[n]) b) := ...
```

```lean
lemma quotient_eq_of_rel
  {α : Type _} (ρ : Setoid α) {a b : α} :
  ρ.r a b → Quotient.mk'' a = Quotient.mk'' b := ...
```

```lean
lemma rel_of_quotient_eq
  {α : Type _} (ρ : Setoid α) {a b : α} :
  Quotient.sound : ρ.r a b → Quotient.mk'' a = Quotient.mk'' b
```

Adapt to the exact quotient API in Lean 4.

```lean
lemma iterate_succ_rel
  {α : Type _} (ρ : Setoid α) (f : α → α) (x : α) (n : ℕ) :
  ρ.r ((f^[n+1]) x) (f ((f^[n]) x)) := by rfl
```

This may be definitional equality rather than relation; use it only if convenient.

```lean
lemma finite_repeat_exists
  {β : Type _} [Fintype β] [DecidableEq β] (g : ℕ → β) :
  ∃ m n, m < n ∧ n ≤ Fintype.card β ∧ g m = g n := ...
```

This is a key combinatorial lemma. If a general infinite-domain codomain version is awkward, prove the bounded version on `Fin (Fintype.card β + 1)`.

---

## Computational/complexity requirements

Do not leave “bounded” informal. State exact arithmetic bounds.

Examples:

- stabilization horizon `≤ Fintype.card α`
- affine weight growth `≤ w₀ + n * c`
- cycle detection search bounded by `Fintype.card α + 1`
- if you define an explicit algorithm returning the first repeated quotient class, prove:
  ```lean
  theorem cycle_search_terminates_in_O_card
    ...
    : ∃ n ≤ Fintype.card α + 1, ...
  ```

Since Lean does not encode big-O simply in elementary developments, prefer explicit cardinal polynomial bounds over asymptotic notation unless you import asymptotics carefully. If you do use `IsBigO`, connect it to a concrete bound theorem.

---

## Cross-domain bridges to make explicit in doc comments

For each major definition/theorem, include a one-line doc comment like:

- `Bridge: connects algebraic congruence dynamics to temporal self-reference and certified robustness.`
- `Bridge: connects finite proof semantics to post_quantum_security via collision-style orbit repetition.`
- `Bridge: connects time-reversal congruence symmetry to quantum and thermodynamic fixed-point phenomena.`
- `Bridge: connects diagonal classes to lattice-style obstruction certificates.`

These doc comments matter: they should signal the intended scientific meaning.

---

## Minimal-hypothesis aesthetic

Prefer statements with the weakest useful assumptions:

- pure `Setoid α` for congruence-dynamic theorems
- `[Fintype α] [DecidableEq α]` only when using finiteness
- `[Semiring α]` only when actually using semiring structure
- separate weighted/operator-growth lemmas into `FiniteProofSemiring α`

Avoid over-assuming commutativity or order unless needed.

Also include at least one theorem with genuine quantifier alternation, e.g.

```lean
theorem certified_temporal_selfReference
  {α : Type _} [Fintype α] [DecidableEq α]
  (ρ : Setoid α) (D : Set α) :
  IsDiagonalClass ρ D →
  ∀ f : α → α, ∃ x, x ∈ D ∧ ρ.r (f x) x := ...
```

and one symmetric theorem involving a pair `(f, g)`.

---

## If ambitious quotient cardinality is hard

A perfectly acceptable fallback is to prove everything with bound `Fintype.card α` rather than `Fintype.card (Quotient ρ)`. But if you can establish finite quotient cardinality and a sharper bound, that is preferred and more original.

---

## Strong endgame theorem

The ideal final theorem is:

```lean
/--
Bridge: connects proof-semiring diagonalization to quantum time-symmetry,
post_quantum_security obstruction search, and lipschitz_certified_robustness
through explicit chronometric incompleteness bounds.
-/
theorem proofSemiring_quantum_cryptographic_fixedPoint_trichotomy
  {α : Type _} [Fintype α] [DecidableEq α] [Semiring α]
  (S : FiniteProofSemiring α)
  (ρ : Setoid α)
  (f : WeightControlledOp S)
  (D : Set α) :
  IsDiagonalClass ρ D →
  HasCongruenceFixedPoint ρ f.op
  ∨ (∃ c : BoundedObstructionCertificate ρ f.op,
      c.horizon ≤ ChronometricIncompletenessBound ρ f.op)
  ∨ HasNontrivialCongruenceCycle ρ f.op := ...
```

If the diagonal hypothesis makes the first disjunct immediate, then sharpen the theorem by separating:
- unconditional stabilization/cycle theorem for any `f`
- diagonal hypothesis implies actual fixed point in `D`

This separation will make the architecture cleaner and the results stronger.

---

## Final required section in the file

End with a clearly marked section of precise future conjectures, as Lean comments, including 3–5 concrete next-step targets such as:

1. extend finite-cardinality stabilization to finitely generated semimodules;
2. replace `Setoid` by semiring congruence objects from the catalog and prove functoriality;
3. define a genuine algorithm extracting shortest obstruction certificates;
4. connect quotient-cycle bounds to tropical or lattice collision estimates;
5. formalize a “Gödel–Brouwer semiring diagonal schema” with explicit coding maps.

Also produce a structured `FUTURE_DIRECTIONS.md` describing these next steps in mathematical and computational terms.

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
            Develop a formally precise fixed-point/diagonalization calculus for self-referential semiring dynamics by combining proof semirings, semiring congruences, and chronometric reversible update systems. The target result is a family of incompleteness-style separation statements: for a finitary proof semiring equipped with a time-indexed endomorphism dynamics, any sufficiently expressive self-evaluator induces a fixed-point sentence whose truth, provability, and dynamical stabilization cannot all coincide. This would create a new field-level bridge between algebraic proof semantics and speculative temporal computation, distinct from existing EML-centered and chronometric-capacity projects. The program should also yield an algorithmic pipeline for detecting diagonal obstructions from finite semiring presentations via congruence elimination and fixed-point search.

            ### Precise Mathematical Framing
            Core objects: (1) a proof semiring P with additive idempotence or bounded join structure; (2) a semiring congruence ~ representing observational equivalence of proofs/program traces; (3) a chronometric endomorphism tau : P -> P encoding one-step temporal evolution or self-inspection; (4) a valuation/evaluator e : P -> B into a finite Boolean or modal semiring. Define a diagonalizable pair (tau,e) when every affine-in-proof operator F(x)=a⊗tau(x)⊕b admits a coded self-substitution class [p_F]. Prove a Fixed-Point Diagonal Lemma for finitely presented proof semirings: under effective coding and congruence elimination, every evaluator-definable unary operator has a fixed-point class modulo ~. Then prove an Incompatibility Trichotomy: for any expressive chronometric proof semiring, at least one of the following fails for some fixed-point class p: (i) semantic correctness e(p)=truth, (ii) internal provability p<=Prov(p), (iii) temporal stabilization tau^n(p)=tau^(n+1)(p) for some bounded n. Strengthen this to quantitative chronometric incompleteness bounds giving lower bounds on stabilization time in terms of congruence complexity or generator depth. Algorithmically, derive a decision/search procedure on finite presentations that either finds a stable evaluator-compatible fixed point or outputs a diagonal obstruction certificate. This leverages existing semiring-congruence infrastructure and chronometric semantics, but is genuinely different from current in-flight work on reversible automata, oracle capacity, or EML reconstructions.

            ### Lean 4 Sketch
Likely feasible by extending semiring congruence APIs around AutoResearch/Basic.lean and AutoResearch/CongruenceElimination.lean, plus reusing proof-congruence ideas from AutoResearch/PrimeCongruenceProofSemiring.lean. Define finite presented proof semirings, coded unary operators, diagonal classes, eventual stabilization, and obstruction certificates; then prove fixed-point existence modulo congruence and the trichotomy via explicit construction on finite supports.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `diagonal_fixed_point` : theorem diagonal_fixed_point (f : H → H)
     (file: Bridges/EMLClosureCore.lean)
  2. `fixed_point_unique_under_theory_separation` : theorem fixed_point_unique_under_theory_separation
     (file: Bridges/ProofStoneCechDynamics.lean)
  3. `gaussian_fixed_point_all_irrelevant` : theorem gaussian_fixed_point_all_irrelevant (arch : RGArchitecture)
     (file: Bridges/RGArchitectureDynamics.lean)
  4. `fixed_point_consensus_bound` : theorem fixed_point_consensus_bound
     (file: Bridges/ByzantineCertificate.lean)
  5. `capacity_diagonal_bound` : theorem capacity_diagonal_bound (n : ℕ) :
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

@AutoResearch/PrimeCongruenceProofSemiring.lean
```lean
/-
# Prime Congruence Spectra of Closure-Generated Proof Semirings

This file establishes the algebraic core of **proof-spectrum semantics**: the reconstruction
of semiprime theories/kernels as intersections of prime theories in commutative semirings.

## Main results

* `semiprime_eq_iInter_prime_theories` — A semiprime kernel in a commutative semiring equals the
  intersection of all prime theories containing it. This is the algebraic heart of the
  proof-spectrum correspondence.

* `exists_prime_theory_avoiding` — Prime separation: if `a` is not in a semiprime kernel `K`,
  there exists a prime theory containing `K` but not `a` (via Zorn's lemma).

* `zeroLocus_anti_mono`, `theoryOf_zeroLocus_extensive`, `theoryOf_zeroLocus_galois` — The
  antitone Galois correspondence between sets of proof terms and sets of congruences.

* `zeroClass_of_prime_congruence_isPrimeTheory` — The zero-class of a prime proof congruence
  is a prime theory.

## Mathematical overview

The key insight is that a proof system can be given the structure of an idempotent commutative
semiring, where `a + b` represents "either derivation resource," `a * b` represents "composite
derivation," and the induced order captures logical entailment. The prime congruence spectrum
then provides a geometric semantics: theories correspond to vanishing loci, and derivability
is captured by vanishing on all points of the associated spectral set.

The decisive theorem is that **semiprime** theories (those closed under square roots:
`a * a ∈ T → a ∈ T`) are exactly the intersections of prime theories. This is the
semiring-theoretic analogue of the radical ideal theorem from algebraic geometry.

## References

The algebraic content is a semiring generalization of the classical commutative algebra result
that semiprime ideals are intersections of prime ideals (a consequence of Krull's theorem).
The proof uses Zorn's lemma applied to the family of ideals disjoint from a multiplicative set.
-/

import Mathlib

set_option maxHeartbeats 800000

universe u

open Set

/-! ## Section 1: Proof Congruences and Basic Definitions -/

/-- A semiring congruence interpreted as proof indistinguishability. -/
structure ProofCongruence (α : Type u) [CommSemiring α] where
  r : α → α → Prop
  iseqv : Equivalence r
  add_compat : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul_compat : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

/-- Vanishing of an element at a congruence: identified with zero. -/
def vanishesAt {α : Type u} [CommSemiring α] (P : ProofCongruence α) (a : α) : Prop :=
  P.r a 0

/-- Zariski closed set defined by a family of proof terms. -/
def zeroLocus {α : Type u} [CommSemiring α]
    (S : Set α) : Set (ProofCongruence α) :=
  {P | ∀ a ∈ S, vanishesAt P a}

/-- The theory reconstructed from a family of proof congruences. -/
def theoryOf {α : Type u} [CommSemiring α]
    (X : Set (ProofCongruence α)) : Set α :=
  {a | ∀ P ∈ X, vanishesAt P a}

/-- A proof congruence is prime if `ab ~ 0` forces `a ~ 0` or `b ~ 0`. -/
def ProofCongruence.IsPrime {α : Type u} [CommSemiring α]
    (P : ProofCongruence α) : Prop :=
  ∀ {a b : α}, P.r (a * b) 0 → P.r a 0 ∨ P.r b 0

/-- The prime spectrum: the set of all prime proof congruences. -/
def primeSpectrum {α : Type u} [CommSemiring α] : Set (ProofCongruence α) :=
  {P | ProofCongruence.IsPrime P}

/-! ## Section 2: Basic Galois Correspondence Lemmas -/

/-- Zero loci are antitone: larger generating sets yield smaller loci. -/
theorem zeroLocus_anti_mono
    {α : Type u} [CommSemiring α] {S T : Set α}
    (hST : S ⊆ T) :
    zeroLocus T ⊆ zeroLocus S := by
  intro P hP a ha
  exact hP a (hST ha)

/-- Every set is contained in the theory of its zero locus. -/
theorem theoryOf_zeroLocus_extensive
    {α : Type u} [CommSemiring α] (S : Set α) :
    S ⊆ theoryOf (zeroLocus S) := by
  intro a ha P hP
  exact hP a ha

/-- The Galois connection between sets of elements and sets of congruences. -/
theorem theoryOf_zeroLocus_galois
    {α : Type u} [CommSemiring α] {S : Set α} {X : Set (ProofCongruence α)} :
    S ⊆ theoryOf X ↔ X ⊆ zeroLocus S := by
  constructor
  · intro h P hP a ha
    exact h ha P hP
  · intro h a ha P hP
    exact h hP a ha

/-- TheoryOf is antitone: larger families of congruences yield smaller theories. -/
theorem theoryOf_anti_mono
    {α : Type u} [CommSemiring α] {X Y : Set (ProofCongruence α)}
    (hXY : X ⊆ Y) :
    theoryOf Y ⊆ theoryOf X := by
  intro a ha P hP
  exact ha P (hXY hP)

/-! ## Section 3: Prime Theories (Set-Based Approach) -/

/-- A set `T` is a *theory* if it contains 0, is closed under addition,
and absorbs multiplication. This captures the algebraic properties of
derivability kernels. -/
structure IsTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop where
  zero_mem : (0 : α) ∈ T
  add_closed : ∀ {a b}, a ∈ T → b ∈ T → a + b ∈ T
  mul_absorb : ∀ {a b}, a ∈ T → a * b ∈ T

/-- A theory is *prime* if `a * b ∈ T` implies `a ∈ T` or `b ∈ T`. -/
structure IsPrimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop
    extends IsTheory T where
  prime : ∀ {a b : α}, a * b ∈ T → a ∈ T ∨ b ∈ T

/-- A theory is *semiprime* if `a * a ∈ T` implies `a ∈ T`. -/
def IsSemiprimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop :=
  IsTheory T ∧ ∀ {a : α}, a * a ∈ T → a ∈ T

/-! ### Key lemma: powers in semiprime kernels -/

/-
In a semiprime kernel, if any power `a ^ n` (with `n ≥ 1`) belongs to `K`,
then `a ∈ K`. This strengthens the defining condition `a² ∈ K → a ∈ K`
using the absorption and closure properties.

The proof is by strong induction on `n`. For even `n = 2k`: `a^(2k) = (a^k)²`,
so `a^k ∈ K` by semiprimality, then `a ∈ K` by induction. For odd `n`:
`(a^n)² = a^(2n) ∈ K` by absorption, so `a^n ∈ K → a^(2n) ∈ K → a^n ∈ K`
(circular, but `2n` is even so we use the even case).
-/
theorem pow_mem_of_semiprime {α : Type u} [CommSemiring α]
    {K : Set α} (hK : IsTheory K) (hsemiprime : ∀ {a : α}, a * a ∈ K → a ∈ K)
    {a : α} {n : ℕ} (hn : 0 < n) (ha : a ^ n ∈ K) : a ∈ K := by
  revert ha;
-- ... (truncated, full file has 485 lines)
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

@AutoResearch/PrimeCongruenceProofSemiring.lean
```lean
/-
# Prime Congruence Spectra of Closure-Generated Proof Semirings

This file establishes the algebraic core of **proof-spectrum semantics**: the reconstruction
of semiprime theories/kernels as intersections of prime theories in commutative semirings.

## Main results

* `semiprime_eq_iInter_prime_theories` — A semiprime kernel in a commutative semiring equals the
  intersection of all prime theories containing it. This is the algebraic heart of the
  proof-spectrum correspondence.

* `exists_prime_theory_avoiding` — Prime separation: if `a` is not in a semiprime kernel `K`,
  there exists a prime theory containing `K` but not `a` (via Zorn's lemma).

* `zeroLocus_anti_mono`, `theoryOf_zeroLocus_extensive`, `theoryOf_zeroLocus_galois` — The
  antitone Galois correspondence between sets of proof terms and sets of congruences.

* `zeroClass_of_prime_congruence_isPrimeTheory` — The zero-class of a prime proof congruence
  is a prime theory.

## Mathematical overview

The key insight is that a proof system can be given the structure of an idempotent commutative
semiring, where `a + b` represents "either derivation resource," `a * b` represents "composite
derivation," and the induced order captures logical entailment. The prime congruence spectrum
then provides a geometric semantics: theories correspond to vanishing loci, and derivability
is captured by vanishing on all points of the associated spectral set.

The decisive theorem is that **semiprime** theories (those closed under square roots:
`a * a ∈ T → a ∈ T`) are exactly the intersections of prime theories. This is the
semiring-theoretic analogue of the radical ideal theorem from algebraic geometry.

## References

The algebraic content is a semiring generalization of the classical commutative algebra result
that semiprime ideals are intersections of prime ideals (a consequence of Krull's theorem).
The proof uses Zorn's lemma applied to the family of ideals disjoint from a multiplicative set.
-/

import Mathlib

set_option maxHeartbeats 800000

universe u

open Set

/-! ## Section 1: Proof Congruences and Basic Definitions -/

/-- A semiring congruence interpreted as proof indistinguishability. -/
structure ProofCongruence (α : Type u) [CommSemiring α] where
  r : α → α → Prop
  iseqv : Equivalence r
  add_compat : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  mul_compat : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)

/-- Vanishing of an element at a congruence: identified with zero. -/
def vanishesAt {α : Type u} [CommSemiring α] (P : ProofCongruence α) (a : α) : Prop :=
  P.r a 0

/-- Zariski closed set defined by a family of proof terms. -/
def zeroLocus {α : Type u} [CommSemiring α]
    (S : Set α) : Set (ProofCongruence α) :=
  {P | ∀ a ∈ S, vanishesAt P a}

/-- The theory reconstructed from a family of proof congruences. -/
def theoryOf {α : Type u} [CommSemiring α]
    (X : Set (ProofCongruence α)) : Set α :=
  {a | ∀ P ∈ X, vanishesAt P a}

/-- A proof congruence is prime if `ab ~ 0` forces `a ~ 0` or `b ~ 0`. -/
def ProofCongruence.IsPrime {α : Type u} [CommSemiring α]
    (P : ProofCongruence α) : Prop :=
  ∀ {a b : α}, P.r (a * b) 0 → P.r a 0 ∨ P.r b 0

/-- The prime spectrum: the set of all prime proof congruences. -/
def primeSpectrum {α : Type u} [CommSemiring α] : Set (ProofCongruence α) :=
  {P | ProofCongruence.IsPrime P}

/-! ## Section 2: Basic Galois Correspondence Lemmas -/

/-- Zero loci are antitone: larger generating sets yield smaller loci. -/
theorem zeroLocus_anti_mono
    {α : Type u} [CommSemiring α] {S T : Set α}
    (hST : S ⊆ T) :
    zeroLocus T ⊆ zeroLocus S := by
  intro P hP a ha
  exact hP a (hST ha)

/-- Every set is contained in the theory of its zero locus. -/
theorem theoryOf_zeroLocus_extensive
    {α : Type u} [CommSemiring α] (S : Set α) :
    S ⊆ theoryOf (zeroLocus S) := by
  intro a ha P hP
  exact hP a ha

/-- The Galois connection between sets of elements and sets of congruences. -/
theorem theoryOf_zeroLocus_galois
    {α : Type u} [CommSemiring α] {S : Set α} {X : Set (ProofCongruence α)} :
    S ⊆ theoryOf X ↔ X ⊆ zeroLocus S := by
  constructor
  · intro h P hP a ha
    exact h ha P hP
  · intro h a ha P hP
    exact h hP a ha

/-- TheoryOf is antitone: larger families of congruences yield smaller theories. -/
theorem theoryOf_anti_mono
    {α : Type u} [CommSemiring α] {X Y : Set (ProofCongruence α)}
    (hXY : X ⊆ Y) :
    theoryOf Y ⊆ theoryOf X := by
  intro a ha P hP
  exact ha P (hXY hP)

/-! ## Section 3: Prime Theories (Set-Based Approach) -/

/-- A set `T` is a *theory* if it contains 0, is closed under addition,
and absorbs multiplication. This captures the algebraic properties of
derivability kernels. -/
structure IsTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop where
  zero_mem : (0 : α) ∈ T
  add_closed : ∀ {a b}, a ∈ T → b ∈ T → a + b ∈ T
  mul_absorb : ∀ {a b}, a ∈ T → a * b ∈ T

/-- A theory is *prime* if `a * b ∈ T` implies `a ∈ T` or `b ∈ T`. -/
structure IsPrimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop
    extends IsTheory T where
  prime : ∀ {a b : α}, a * b ∈ T → a ∈ T ∨ b ∈ T

/-- A theory is *semiprime* if `a * a ∈ T` implies `a ∈ T`. -/
def IsSemiprimeTheory {α : Type u} [CommSemiring α] (T : Set α) : Prop :=
  IsTheory T ∧ ∀ {a : α}, a * a ∈ T → a ∈ T

/-! ### Key lemma: powers in semiprime kernels -/

/-
In a semiprime kernel, if any power `a ^ n` (with `n ≥ 1`) belongs to `K`,
then `a ∈ K`. This strengthens the defining condition `a² ∈ K → a ∈ K`
using the absorption and closure properties.

The proof is by strong induction on `n`. For even `n = 2k`: `a^(2k) = (a^k)²`,
so `a^k ∈ K` by semiprimality, then `a ∈ K` by induction. For odd `n`:
`(a^n)² = a^(2n) ∈ K` by absorption, so `a^n ∈ K → a^(2n) ∈ K → a^n ∈ K`
(circular, but `2n` is even so we use the even case).
-/
theorem pow_mem_of_semiprime {α : Type u} [CommSemiring α]
    {K : Set α} (hK : IsTheory K) (hsemiprime : ∀ {a : α}, a * a ∈ K → a ∈ K)
    {a : α} {n : ℕ} (hn : 0 < n) (ha : a ^ n ∈ K) : a ∈ K := by
  revert ha;
-- ... (truncated, full file has 485 lines)
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
