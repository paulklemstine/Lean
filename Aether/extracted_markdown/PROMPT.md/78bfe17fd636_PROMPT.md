

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

## TASK: Proof-Congruence Automata, Prime Spectra, and Certified Minimality over Idempotent Proof Dynamics

Work in Lean 4 by creating a substantial development around semiring congruence dynamics as automata. The core objective is to formalize a new bridge between:

- algebraic automata theory via Myhill–Nerode style congruences,
- proof-theoretic algebraic geometry via prime congruence spectra and zero loci,
- certified computation for cryptographic / ML / quantum-inspired state compression.

Your file should define a proof-driven automaton model whose states are congruence classes or congruences themselves, whose transitions are induced by semiring multiplication contexts, and whose acceptance / observability is controlled by prime congruence spectral predicates. The final output should include both abstract theorems and computable finite-state minimization in a finite-generator setting.

Use theorem names and doc comments with explicit impact vocabulary:
`quantum`, `thermodynamic`, `post_quantum`, `lattice`, `certified`, `robustness`, `neural`, `tropical`, `entropy`.

Target at least 10 definitions / structures and 20 theorems, with zero sorries.

---

## 1. Core definitions: contextual proof dynamics as automata

Assume the relevant imported APIs provide:
- `SemiringCong S`
- left/right context actions from `AutoResearch.Basic`
- elimination congruence from `AutoResearch.CongruenceElimination`
- `ProofCongruence`, `theoryOf`, `zeroLocus`, `ProofCongruence.IsPrime`
  from `AutoResearch.PrimeCongruenceProofSemiring`

If some exact names differ, adapt to the catalog names while preserving the mathematical content.

### 1.1 Define a context-action record

Introduce a structure encoding one-step contextual transitions on a semiring:

```lean
structure ProofContextAction (S : Type u) [Semiring S] where
  leftCtx  : S
  rightCtx : S
```

Define its action on `S`:

```lean
def ProofContextAction.act {S : Type u} [Semiring S]
    (c : ProofContextAction S) (x : S) : S :=
  c.leftCtx * x * c.rightCtx
```

Prove identity / composition-style lemmas if useful.

### 1.2 Define contextual indistinguishability

Define the central congruence:

```lean
def contextualEquiv (S : Type u) [Semiring S] : SemiringCong S := ...
```

with intended relation
`x ~ y` iff for all left/right contexts `a b : S`, the transformed terms
`a * x * b` and `a * y * b` are observationally equivalent in the chosen proof semantics.

At minimum, formalize a concrete semiring congruence such as:
```lean
def contextualRel {S : Type u} [Semiring S] (x y : S) : Prop :=
  ∀ a b : S, a * x * b = a * y * b
```
and package it as a `SemiringCong S`.

If the imported `ProofCongruence` is more appropriate, define a stronger / weaker variant and prove comparison lemmas.

Required exact signature:

```lean
def contextualRel (S : Type u) [Semiring S] : S → S → Prop
def contextualEquiv (S : Type u) [Semiring S] : SemiringCong S
```

### 1.3 Define the automaton

Define an automaton whose states are quotient classes modulo `contextualEquiv S`, or alternatively raw congruences with transitions induced by context action.

Preferred quotient-state version:

```lean
def ProofState (S : Type u) [Semiring S] :=
  Quotient (contextualEquiv S).toSetoid

structure ProofAutomaton (S : Type u) [Semiring S] where
  State      : Type u
  step       : State → ProofContextAction S → State
  output     : State → Prop
  sound_repr : S → State
```

Then instantiate a canonical automaton:

```lean
def canonicalProofAutomaton (S : Type u) [Semiring S] : ProofAutomaton S := ...
```

with
```lean
State := ProofState S
```
and step induced by multiplication under quotient.

You must prove quotient well-definedness explicitly.

### 1.4 Define language / theory recognition

Define a notion that a state satisfies a proof-theoretic observable:

```lean
def recognizesTheory {S : Type u} [Semiring S]
    (A : ProofAutomaton S) (T : Set S) : Prop := ...
```

Also define spectral observability via prime congruences:

```lean
def PrimeObservable {S : Type u} [Semiring S]
    [/* whatever proof-semiring structure is needed */]
    (P : ProofCongruence S) : Prop := ProofCongruence.IsPrime P

def spectralRecognizes {S : Type u} [Semiring S]
    (A : ProofAutomaton S) (X : Set (ProofCongruence S)) : Prop := ...
```

---

## 2. New structures with computational and cross-domain meaning

Define at least 5 of the following, or closely related variants with these names.

```lean
structure CertifiedObservationKernel (S : Type u) [Semiring S] where
  carrier : Set S
  closed_under_context : ∀ {x}, x ∈ carrier → ∀ a b : S, a * x * b ∈ carrier
```

```lean
structure SpectralWitness (S : Type u) [Semiring S] where
  primeCong : ProofCongruence S
  isPrime   : ProofCongruence.IsPrime primeCong
  separates : ∃ x y : S, ¬ primeCong.Rel x y
```

```lean
structure FiniteProofGenerator (S : Type u) [Semiring S] where
  gens : Finset S
  spans_contexts : ∀ x : S, ∃ a b : S, True
```

If an actual finite-generation API exists, replace the placeholder with a real one.

```lean
structure QuotientMinimizationCertificate (S : Type u) [Semiring S] where
  carrierStates : Finset (ProofState S)
  complete      : True
  minimality    : True
```

```lean
structure QuantumCertifiedSeparator (S : Type u) [Semiring S] where
  separator : S → S → Prop
  sound     : ∀ {x y}, separator x y → x ≠ y
```

```lean
structure TropicalEntropyBound (S : Type u) [Semiring S] where
  stateCount : ℕ
  bitBound   : ℕ
  witness    : bitBound ≤ stateCount * stateCount + 1
```

Also define one Lipschitz-style notion for state perturbation under contexts, even if purely discrete:

```lean
def proofLipschitzConstant (S : Type u) [Semiring S] : ℕ := ...
```

and a robust transition property:

```lean
def certifiedRobustStep {S : Type u} [Semiring S]
    (A : ProofAutomaton S) : Prop := ...
```

Doc comments should explicitly say:
“Bridge: connects automata minimization to prime congruence spectra and certified robustness / post_quantum state compression.”

---

## 3. Main theorem cluster: exact Lean targets

You should prove as many of the following as possible with these or essentially equivalent signatures.

### 3.1 `contextualEquiv` is a semiring congruence

```lean
theorem contextualRel_refl (S : Type u) [Semiring S] :
    Reflexive (contextualRel S)

theorem contextualRel_symm (S : Type u) [Semiring S] :
    Symmetric (contextualRel S)

theorem contextualRel_trans (S : Type u) [Semiring S] :
    Transitive (contextualRel S)

theorem contextualEquiv_mul_compat (S : Type u) [Semiring S] :
    ∀ {x y z w : S},
      (contextualEquiv S).Rel x y →
      (contextualEquiv S).Rel z w →
      (contextualEquiv S).Rel (x * z) (y * w)

theorem contextualEquiv_add_compat (S : Type u) [Semiring S] :
    ∀ {x y z w : S},
      (contextualEquiv S).Rel x y →
      (contextualEquiv S).Rel z w →
      (contextualEquiv S).Rel (x + z) (y + w)
```

If addition compatibility is unavailable from your chosen relation, either strengthen hypotheses or define a multiplicative contextual congruence and then a full semiring congruence using closure. But prove a packaged theorem:

```lean
theorem contextualEquiv_isSemiringCong (S : Type u) [Semiring S] :
    True
```

Prefer a real theorem exposing the structure rather than `True`.

### 3.2 Quotient transition well-definedness

```lean
theorem canonical_step_wellDefined
    (S : Type u) [Semiring S] :
    ∀ x y : S, (contextualEquiv S).Rel x y →
    ∀ c : ProofContextAction S,
      (contextualEquiv S).Rel (c.act x) (c.act y)
```

```lean
theorem canonicalProofAutomaton_sound
    (S : Type u) [Semiring S] :
    ∀ x c,
      (canonicalProofAutomaton S).step
        ((canonicalProofAutomaton S).sound_repr x) c
      =
      (canonicalProofAutomaton S).sound_repr (c.act x)
```

### 3.3 Comparison with elimination congruence

Formulate and prove inclusion / coincidence theorems with the imported elimination congruence. Use the exact imported name if available; otherwise use a local alias.

Target one of the following forms:

```lean
theorem eliminationCong_le_contextualEquiv
    (S : Type u) [Semiring S] :
    ∀ {x y : S},
      eliminationCong.Rel x y →
      (contextualEquiv S).Rel x y
```

```lean
theorem contextualEquiv_refines_eliminationCong
    (S : Type u) [Semiring S] :
    ∀ {x y : S},
      (contextualEquiv S).Rel x y →
      eliminationCong.Rel x y
```

If both directions are provable, state the equivalence:

```lean
theorem contextualEquiv_eq_eliminationCong
    (S : Type u) [Semiring S] :
    contextualEquiv S = eliminationCong
```

This is a key breakthrough target: contextual state minimization = proof cut-elimination quotient.

### 3.4 Prime-separation and spectral recognition

Use `theoryOf`, `zeroLocus`, and primality predicates to prove prime-separation principles. The desired shape is:

```lean
theorem prime_separation_of_contextual_inequivalence
    (S : Type u) [Semiring S]
    [/* required proof-semiring hypotheses */] :
    ∀ {x y : S},
      ¬ (contextualEquiv S).Rel x y →
      ∃ P : ProofCongruence S,
        ProofCongruence.IsPrime P ∧ ¬ P.Rel x y
```

Also prove a zero-locus / theory theorem:

```lean
theorem contextual_zeroLocus_reflects_theory
    (S : Type u) [Semiring S]
    [/* needed hypotheses */] :
    ∀ T : Set S, ∀ x y : S,
      x ∈ theoryOf (zeroLocus T) →
      (contextualEquiv S).Rel x y →
      y ∈ theoryOf (zeroLocus T)
```

And a spectral recognition theorem for the canonical automaton:

```lean
theorem canonical_spectral_recognition
    (S : Type u) [Semiring S]
    [/* needed hypotheses */] :
    ∀ x y : S,
      (∀ P : ProofCongruence S, ProofCongruence.IsPrime P → P.Rel x y) →
      (contextualEquiv S).Rel x y
```

This is the automata-theoretic analogue of a prime-spectrum completeness statement.

### 3.5 Universal minimality / Myhill–Nerode theorem for proof automata

Define a notion of automaton morphism and prove universal minimality of the canonical quotient.

```lean
structure ProofAutomatonHom (S : Type u) [Semiring S]
    (A B : ProofAutomaton S) where
  toFun : A.State → B.State
  step_comm :
    ∀ q c, toFun (A.step q c) = B.step (toFun q) c
  output_comm :
    ∀ q, A.output q ↔ B.output (toFun q)
```

```lean
def IsContextuallyComplete (S : Type u) [Semiring S]
    (A : ProofAutomaton S) : Prop := ...
```

```lean
def IsMinimalProofAutomaton (S : Type u) [Semiring S]
    (A : ProofAutomaton S) : Prop := ...
```

Main theorem:

```lean
theorem quantum_certified_myhill_nerode_proof
    (S : Type u) [Semiring S] :
    IsMinimalProofAutomaton S (canonicalProofAutomaton S)
```

And universal factorization:

```lean
theorem canonical_factor_through_any_complete
    (S : Type u) [Semiring S]
    (A : ProofAutomaton S) :
    IsContextuallyComplete S A →
    ∃ f : ProofAutomatonHom S (canonicalProofAutomaton S) A, True
```

If finite-state hypotheses are needed, state them minimally and explicitly.

### 3.6 Computable minimization with explicit complexity bounds

If a finite generator / finite quotient API exists, implement a computable quotient minimization routine.

Suggested signatures:

```lean
def minimizeProofAutomaton
    (S : Type u) [Semiring S] [Fintype (ProofState S)] [DecidableEq (ProofState S)] :
    ProofAutomaton S := canonicalProofAutomaton S
```

```lean
def minimizationStateCount
    (S : Type u) [Semiring S] [Fintype (ProofState S)] : ℕ :=
  Fintype.card (ProofState S)
```

```lean
theorem minimizeProofAutomaton_universal
    (S : Type u) [Semiring S] [Fintype (ProofState S)] [DecidableEq (ProofState S)] :
    IsMinimalProofAutomaton S (minimizeProofAutomaton S)
```

Now state an explicit asymptotic-style finite bound theorem in discrete form. Since Lean does not natively encode big-O as simply, it is acceptable to prove a concrete cardinal bound:

```lean
theorem minimization_certificate_bit_bound
    (S : Type u) [Semiring S] [Fintype (ProofState S)] :
    ∃ k : ℕ, k = minimizationStateCount S * minimizationStateCount S + 1
```

and a stronger finite search bound:

```lean
theorem prime_spectral_search_bound
    (S : Type u) [Semiring S] [Fintype (ProofState S)] :
    ∃ N : ℕ, N ≤ (minimizationStateCount S)^2 + 2
```

In doc comments explicitly interpret these as:
- certified state compression bound,
- post_quantum finite-state proof compression budget,
- neural robustness witness search budget.

---

## 4. Proof strategy requirements: use diverse tactics and multiple proof routes

For each major theorem, aim to include one of the following proof patterns.

### 4.1 For `contextualEquiv`
- unfold the relation and use `constructor` / `intro` / `simpa`
- for transitivity, chain equalities under arbitrary contexts
- for multiplication compatibility, choose expanded contexts like `a` and `b`, rewrite by associativity, then apply hypotheses to `x ~ y` and `z ~ w`
- use `calc`, `simp [mul_assoc, add_mul, mul_add]`
- if needed, use `congrArg` and `funext`

### 4.2 For quotient well-definedness
- use `Quot.sound`
- `refine Quotient.sound ?_`
- unfold `ProofContextAction.act`
- prove preservation by contextual closure directly

### 4.3 For elimination congruence comparison
- `intro x y h`
- unpack the elimination hypothesis with `rcases`
- feed the resulting witness / relation into arbitrary contexts
- if proving equality of congruences, use extensionality:
  ```lean
  ext x y; constructor <;> intro h
  ```
- contrapositive route:
  if not contextually equivalent, construct a context that survives elimination

### 4.4 For prime separation
- use the imported prime-spectrum theorem as the critical engine
- prove first that contextual inequivalence implies a theory mismatch
- then pass to `zeroLocus` / `theoryOf`
- use `by_contra hsep`; derive that all prime congruences identify `x` and `y`; then use spectral completeness to conclude contextual equivalence
- this is a good place to use `classical`
- if finite cases appear, use `by_cases`, `omega`, or `linarith` on cardinal inequalities

### 4.5 For minimization
- define a morphism from the canonical quotient by sending a class `[x]` to the reachable state represented by `x`
- prove well-definedness exactly from contextual completeness
- minimality follows by injectivity on distinguishable states
- cardinal minimality:
  prove
  ```lean
  Fintype.card (ProofState S) ≤ Fintype.card A.State
  ```
  when `A` is complete and finite
- use `Fintype.card_le_of_injective` if you can build an injective map
- if cardinal arithmetic is awkward, prove existence of an embedding instead

---

## 5. Required theorem inventory with inventive names

Prove at least 10 of the following with these names or stronger equivalents.

```lean
theorem contextual_echo_invariant ...
theorem proof_dynamics_double_coset ...
theorem elimination_shadow_refinement ...
theorem prime_spectrum_whispers_inequivalence ...
theorem zero_loss_cut_elimination_channel ...
theorem quantum_certified_myhill_nerode_proof ...
theorem post_quantum_state_compression_bound ...
theorem tropical_entropy_of_quotient_states ...
theorem neural_robust_context_step_soundness ...
theorem lattice_separator_from_prime_spectrum ...
theorem thermodynamic_proof_entropy_monotone ...
theorem certified_observation_kernel_closed ...
theorem spectral_witness_yields_distinguishability ...
theorem canonical_factor_through_any_complete ...
theorem quotient_minimization_has_no_ghost_states ...
```

At least some of these should carry nontrivial content, not just wrappers.

---

## 6. Cross-domain bridges to formalize in doc comments and theorem names

Every major definition or theorem should mention one or more of:

- **Automata theory**: Myhill–Nerode, quotient minimization, reachability
- **Algebraic geometry**: prime spectrum, zero locus, theory / variety duality
- **Cryptography**: post_quantum state compression, lattice-style separators, collision resistance analogies
- **Machine learning**: certified robustness, Lipschitz state perturbation bounds, neural state abstraction
- **Physics**: thermodynamic entropy of quotient states, quantum observational equivalence

Examples of acceptable theorem doc comments:
- `Bridge: connects prime congruence spectra to certified robustness of proof-state automata.`
- `Bridge: interprets minimal quotient automata as post_quantum proof-compression channels.`
- `Bridge: recasts zero-locus invariance as a thermodynamic coarse-graining law.`

---

## 7. Minimal hypotheses, but use rich typeclass abstraction where justified

Prefer the weakest assumptions that make each theorem true:
- basic congruence lemmas under `[Semiring S]`
- spectral theorems under whatever stronger imported proof-semiring structure is necessary
- finite minimization under `[Fintype (ProofState S)] [DecidableEq (ProofState S)]`

If useful, also provide specialized idempotent versions:

```lean
theorem idempotent_contextual_collapse
    (S : Type u) [Semiring S] [OrderBot S] :
    ...
```

or ordered / tropical-flavored variants with unusual combinations such as:
```lean
variable {S : Type u} [Semiring S] [Preorder S]
```
provided they are mathematically real and not cosmetic.

---

## 8. Concrete special cases if the general theorem is difficult

If the fully abstract spectral separation theorem is too strong, prove one or more of these specializations:

1. Equality semiring congruence special case:
```lean
theorem contextualRel_eq_of_commutative_semiring
    (S : Type u) [CommSemiring S] :
    ∀ x y : S, contextualRel S x y ↔ x = y
```

2. Zero / one context simplifications:
```lean
theorem contextualRel_of_unit_contexts
    (S : Type u) [Semiring S] :
    ∀ {x y : S},
      contextualRel S x y →
      x = y
```
if it follows by plugging `a = 1`, `b = 1`.

3. Finite-state minimization for a trivial automaton:
```lean
theorem minimizeProofAutomaton_singleton_case ...
```

4. Prime-separation under explicit catalog assumptions only.

Even these special cases are valuable if they are cleanly connected to the larger program.

---

## 9. Significance to the research program

The file should make mathematically precise the thesis that proof normalization, automaton minimization, and algebraic-geometric spectrum formation are the same compression phenomenon seen from three domains. The breakthrough is not merely another congruence lemma; it is a certified architecture for:

- **post_quantum proof compression**: quotienting proofs by contextual indistinguishability while retaining spectral distinguishers,
- **neural / certified robustness**: interpreting contexts as adversarial perturbations and quotient states as robust abstractions,
- **quantum / thermodynamic semantics**: interpreting prime observables as coarse-grained measurement channels and quotient cardinality as entropy.

In particular, the theorem equating or comparing `contextualEquiv` with `eliminationCong` should be treated as the conceptual centerpiece: it says cut-elimination is automata minimization. The prime-separation theorem then says the prime spectrum supplies optimal distinguishers. The finite minimization theorem gives the algorithmic shadow.

---

## 10. FUTURE_DIRECTIONS artifact

At the end of the development, also produce a structured `FUTURE_DIRECTIONS.md` containing 3–5 specific next steps, each stated as a formalizable target, for example:

1. a Stone-type duality between finite proof automata and spectral spaces of prime congruences,
2. a tropical / idempotent Shannon entropy theory for quotient proof dynamics,
3. a lattice-based post_quantum separator extraction theorem,
4. a certified robustness theorem for neural proof-state abstractions,
5. a quantum measurement semantics for `zeroLocus` as observable collapse.

These future directions should be concrete enough to become the next Lean files.

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
            Develop a new bridge between Logic, Algebra, and Computation by proving that proof congruences on idempotent semirings canonically generate deterministic automata whose reachable-state structure is classified by prime congruence spectra, and whose minimization is exact via semiring-congruence elimination. The core objective is to turn the existing proof-congruence and congruence-elimination infrastructure into an algorithmic pipeline: from a finitely presented proof system or rewrite semiring, construct a certified state machine, prove language/state equivalence via semiring congruence, and derive a canonical minimized automaton from prime-spectrum separation. This is different from current inflight EML/quantum/tropical work, uses underexploited Unknown+Algebra+Logic infrastructure, and opens a field of proof-dynamic automata where normalization, equivalence, and compression are all expressed as algebraic spectrum phenomena.

            ### Precise Mathematical Framing
            Let S be an additively idempotent semiring equipped with a proof congruence ≈ capturing derivational indistinguishability. Define the proof-state transition system by left multiplication of generators on congruence classes. Prove: (1) a Myhill-Nerode-style criterion for proof languages, where two proof states are equivalent iff they agree on all future derivation contexts, and this equivalence is exactly a semiring congruence; (2) under finite generation, the quotient by contextual equivalence yields a canonical deterministic automaton; (3) prime proof congruences separate inequivalent states, giving a spectral realization of minimality; (4) congruence elimination computes the coarsest sound quotient, yielding an exact minimization algorithm; (5) zero-locus/theoryOf duality identifies accepted proof behaviors with spectral subsets, giving a geometric semantics of recognition. This would synthesize AutoResearch/PrimeCongruenceProofSemiring.lean, AutoResearch/CongruenceElimination.lean, and AutoResearch/Basic.lean into a single paradigm: proofs as semiring dynamics, automata minimization as congruence elimination, and recognition as spectral geometry. The likely formal payload is 10+ theorems: contextual-equivalence congruence, transition well-definedness, quotient determinism, universal property of minimized automaton, prime-separation lemma, soundness/completeness of elimination minimization, zero-locus recognition correspondence, functoriality under semiring morphisms, product construction, and decidability bounds for finite presentations.

            ### Lean 4 Sketch
Define `ProofAutomaton (S : Type _) [Semiring S] [OrderBot?]` with states as `SemiringCong S` or quotient classes of proofs; transitions induced by `mul_left`/`mul_right` from `AutoResearch/Basic`. Prove a `contextualEquiv : SemiringCong S`; connect to `eliminationCong` from `AutoResearch/CongruenceElimination`; use `ProofCongruence`, `theoryOf`, `zeroLocus`, and `ProofCongruence.IsPrime` from `AutoResearch/PrimeCongruenceProofSemiring` to formulate prime-separation and spectral recognition lemmas. If finite generator APIs exist, add a computable minimization procedure returning a quotient automaton with proof of universal minimality.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `certified_robustness_from_margin_and_lipschitz` : theorem certified_robustness_from_margin_and_lipschitz
     (file: Bridges/HomologicalDeepLearning.lean)
  2. `certified_robust_from_margin_bound` : lemma certified_robust_from_margin_bound {n m : ℕ}
     (file: Bridges/MaslovDequantizationRobustness.lean)
  3. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)
  4. `new_bridge_count` : theorem new_bridge_count : newBridges.length = 12 := by decide
     (file: Bridges/ArchitectureOfReality/UnificationGraph.lean)
  5. `elimination_prime_code_sound` : theorem elimination_prime_code_sound (Γ : Finset α) (y : α) (φ : α)
     (file: Bridges/BooleanThermodynamicEliminationDuality.lean)

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



Recent successful concepts: EML Quantum Stabilizer Theory: Closure-Operator Stabilizer Correspondence, Knaster-Tarski Codespace Certification, and Idempotent Recovery Concatenation, Gravitational Factoring: Idempotent Spectral Lensing, Causal Prime Decomposition, and Ring-Theoretic Factorization Certification, Min-Plus Verification Theory: ReLU Network Isomorphism, Polytope Certified Radii, and Verification Completeness


            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - Detailed proofs and explanations

            3. **DISCUSSION.md** — MANDATORY Scientific American-style popular science article
               - Written for a mathematically literate but non-specialist audience
               - Use analogies, examples, and narrative to explain WHY this matters
               - Include at least one surprising connection to everyday life or another field
               - 1000-2000 words, accessible but not dumbed-down
               - This makes your research accessible to a broad audience

            4. **FUTURE_DIRECTIONS.md** — MANDATORY breakthrough research roadmap
               This is the MOST IMPORTANT deliverable because it drives the next
               research cycle. Structure it as:

               ## Breakthrough Opportunities (ranked by impact)
               For each opportunity:
               - **Theorem Statement**: Precise, formalizable statement with quantifiers
               - **Proof Strategy**: 2-3 concrete approaches with key lemmas identified
               - **Why This Is Revolutionary**: What field it opens, what applications it enables,
                 what unexpected connections it reveals
               - **Catalog Leverage**: Which existing catalog theorems to build on (by name)
               - **Research Mode**: prove | formalize | discover | counterexample
               - **Estimated Depth**: 1-5 scale (1 = one clever lemma, 5 = multi-theorem development)

               ## Under-explored Territory
               - Domains with many definitions but few deep theorems
               - Unexpected structural similarities across domains
               - "Orphan" results that could seed new research programs

               ## Cross-Domain Bridges
               - Specific, precise connections between domains
               - Conjectured functorial correspondences or isomorphisms
               - Algorithmic pipelines combining results from multiple domains

               ## Open Problems Encountered
               - Problems you couldn't solve but identified as important
               - Conjectures you can state precisely but not yet prove
               - Connections that seem to exist but need more catalog infrastructure

            5. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            6. **diagram.svg** — visualization of key mathematical structures

            Produce novel, non-trivial theorems with complete Lean 4 proofs. Think big — aim for results that would appear in JAMS, Annals, or FOCS.

            ### Catalog Reference Files
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
Research mode: formalize
