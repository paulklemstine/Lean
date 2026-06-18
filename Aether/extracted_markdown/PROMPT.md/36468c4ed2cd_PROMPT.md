

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

## FORMALIZATION TARGET: Condensation Semantics for Algebraic–EML Fixed Points via Idempotent Galois Reconstruction

Create a Lean 4 development that turns the slogan

> “finitary closure data on compact generators reconstructs an idempotent nucleus, whose fixed points are equivalent to closed ideals, and whose iterative dynamics admit a certified termination rank bound”

into a precise, reusable theorem package.

The central bridge is between:
1. **order/algebraic lattice semantics** (compact generation, ideals, nuclei, fixed points),
2. **EML / emergent computation semantics** (iterative closure as computation, convergence rank),
3. **cryptographic / ML / physics language** (certified termination, lattice semantics, entropy-style monotonicity).

Use these application keywords explicitly in theorem names or doc comments:
`quantum`, `thermodynamic`, `post_quantum`, `lattice`, `certified`, `robustness`, `entropy`, `neural`.

You must build a coherent file with definitions, instances, lemmas, and main theorems. If some generality is too hard, first formalize the complete theorem in a strong but manageable setting such as `P` an `OrderBot` + `SupSet` + `CompleteLattice` + `IsAlgebraic P`, then abstract.

---

## SECTION 1: Core new definitions and precise Lean signatures

Define at least the following new structures/defs, with doc comments explaining the bridge to EML computation and lattice/crypto semantics.

### 1. Finitary closure data on compact elements

The intended meaning: a closure recipe determined on compact generators and compatible with finite joins.

Use a structure close to:

```lean
/-- Bridge: connects algebraic lattice semantics to certified EML update rules.
A `FinitaryClosure P` specifies a monotone closure recipe on compact generators,
preserving finite sup structure, from which a global closure/nucleus will be reconstructed. -/
structure FinitaryClosure (P : Type*) [CompleteLattice P] [OrderBot P] where
  onCompact : P → P
  compact_stable :
    ∀ ⦃x : P⦄, CompactElement x → CompactElement (onCompact x)
  extensive_compact :
    ∀ ⦃x : P⦄, CompactElement x → x ≤ onCompact x
  mono_compact :
    ∀ ⦃x y : P⦄, CompactElement x → CompactElement y → x ≤ y → onCompact x ≤ onCompact y
  map_sup_compacts :
    ∀ ⦃x y : P⦄, CompactElement x → CompactElement y →
      onCompact (x ⊔ y) = onCompact x ⊔ onCompact y
  map_bot :
    onCompact ⊥ = ⊥
```

If `CompactElement` is awkward, introduce a local predicate:

```lean
def IsCompactGen [CompleteLattice P] (x : P) : Prop := CompactElement x
```

and use that consistently.

### 2. Ideal condensation object

Define a structure or subtype of lower sets closed under finite sup and under the finitary closure action:

```lean
/-- Bridge: connects ideal completion to condensation semantics for emergent computation. -/
structure IdealCondensation (P : Type*) [SemilatticeSup P] [OrderBot P] where
  carrier : Set P
  bot_mem' : ⊥ ∈ carrier
  lower' : ∀ ⦃x y : P⦄, y ∈ carrier → x ≤ y → x ∈ carrier
  sup_mem' : ∀ ⦃x y : P⦄, x ∈ carrier → y ∈ carrier → x ⊔ y ∈ carrier
```

Then enrich relative to `F : FinitaryClosure P`:

```lean
def IdealCondensation.ClosedBy
  {P : Type*} [CompleteLattice P] [OrderBot P]
  (F : FinitaryClosure P) (I : IdealCondensation P) : Prop :=
  ∀ ⦃x : P⦄, CompactElement x → x ∈ I.carrier → F.onCompact x ∈ I.carrier
```

If convenient, define:

```lean
structure ClosedIdealCondensation (P : Type*) [CompleteLattice P] [OrderBot P]
    (F : FinitaryClosure P) extends IdealCondensation P where
  closed_compact' :
    ∀ ⦃x : P⦄, CompactElement x → x ∈ carrier → F.onCompact x ∈ carrier
```

### 3. Reconstructed global closure / nucleus

Define the closure by taking the supremum of images of compact generators below `x`:

```lean
/-- Reconstructed closure from compact generators. This is the algebraic-EML
condensation operator whose fixed points model certified stable states. -/
def ClosureNucleus
  (P : Type*) [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) : P → P :=
  fun x => sSup {y : P | ∃ k : P, CompactElement k ∧ k ≤ x ∧ y = F.onCompact k}
```

Then also define the closed-point predicate and fixpoint subtype:

```lean
def IsClosedPoint
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) (x : P) : Prop :=
  ClosureNucleus P F x = x

def ClosureFixpoints
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :=
  {x : P // IsClosedPoint F x}
```

### 4. Iteration rank and certified termination witness

For computational/EML significance, define iterates and a rank bound notion:

```lean
def closureIterate
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) : ℕ → P → P
| 0, x => x
| n+1, x => ClosureNucleus P F (closureIterate n x)

def stabilizationAt
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) (x : P) (n : ℕ) : Prop :=
  closureIterate F (n+1) x = closureIterate F n x

def terminationRank
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) (x : P) : ℕ :=
  Nat.findGreatest (fun n => ¬ stabilizationAt F x n) x.height? -- replace with a workable finite-height variant
```

If `terminationRank` is too hard in full generality, define a witness-style version first:

```lean
def TerminatesBy
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) (x : P) (n : ℕ) : Prop :=
  closureIterate F n x = closureIterate F (n+1) x
```

and then define `terminationRank` only in finite-height settings.

### 5. Height / ACC interface

Introduce a finite-height or ACC hypothesis that is easy to use in Lean:

```lean
def AscendingChain
  (P : Type*) [Preorder P] :=
  ℕ →o P

def IsAscendingChain
  {P : Type*} [Preorder P] (c : ℕ → P) : Prop :=
  ∀ n, c n ≤ c (n+1)

class HasFiniteHeight (P : Type*) [Preorder P] where
  height : ℕ
  strict_chain_bound :
    ∀ c : ℕ → P, (∀ n, c n < c (n+1)) → False
```

If a direct `height` API is cumbersome, define instead a usable theorem-level hypothesis:

```lean
def BoundedChainLength {P : Type*} [Preorder P] (h : ℕ) : Prop :=
  ∀ c : Fin (h+2) → P, ¬ StrictMono c
```

Then prove the computational bound in this bounded setting.

---

## SECTION 2: Main theorem package to prove

You must prove a chain of at least 10 substantial theorems, including the following flagship results.

### A. Basic reconstruction lemmas

1. `ClosureNucleus_mono`
```lean
theorem ClosureNucleus_mono
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  Monotone (ClosureNucleus P F)
```

2. `ClosureNucleus_extensive`
```lean
theorem ClosureNucleus_extensive
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ x : P, x ≤ ClosureNucleus P F x
```

3. `ClosureNucleus_idempotent`
```lean
theorem ClosureNucleus_idempotent
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ x : P, ClosureNucleus P F (ClosureNucleus P F x) = ClosureNucleus P F x
```

4. `ClosureNucleus_sup_fixed`
A nucleus-style theorem; if full meet-preservation is hard, prove preservation of binary sup on compact-generated closed points:
```lean
theorem ClosureNucleus_sup_fixed
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ ⦃x y : P⦄, IsClosedPoint F x → IsClosedPoint F y →
    IsClosedPoint F (x ⊔ y)
```

### B. Closed ideals ↔ fixed points

5. Define the ideal generated by a point:
```lean
def compactIdealBelow
  {P : Type*} [CompleteLattice P] [OrderBot P]
  (x : P) : IdealCondensation P := ...
```

6. Define the supremum of an ideal:
```lean
def idealSup
  {P : Type*} [CompleteLattice P] [OrderBot P]
  (I : IdealCondensation P) : P := sSup I.carrier
```

7. Show every fixed point yields a closed ideal:
```lean
def fixpointToClosedIdeal
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ClosureFixpoints F → ClosedIdealCondensation P F
```

8. Show every closed ideal yields a fixed point:
```lean
def closedIdealToFixpoint
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ClosedIdealCondensation P F → ClosureFixpoints F
```

9. Main equivalence:
```lean
def fixpointLatticeIsoClosedIdeals
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ClosureFixpoints F ≃o ClosedIdealCondensation P F
```

If `≃o` is too ambitious, first produce:
```lean
def fixpointEquivClosedIdeals ... : ClosureFixpoints F ≃ ClosedIdealCondensation P F
```
then separately prove order preservation.

### C. Termination / rank bounds

10. Monotone iteration chain:
```lean
theorem closureIterate_monotone_nat
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) (x : P) :
  ∀ n, closureIterate F n x ≤ closureIterate F (n+1) x
```

11. Stabilization from bounded chain length:
```lean
theorem exists_stabilization_of_height_bound
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) {h : ℕ}
  (hh : BoundedChainLength (P := P) h) :
  ∀ x : P, ∃ n ≤ h, stabilizationAt F x n
```

12. Certified rank bound:
```lean
theorem terminationRank_le_height
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) {h : ℕ}
  (hh : BoundedChainLength (P := P) h) :
  ∀ x : P, ∃ n ≤ h, closureIterate F n x = ClosureNucleus P F x
```

If defining an actual numeric `terminationRank` is manageable in finite-height lattices, strengthen to:
```lean
theorem terminationRank_le_height
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P] [HasFiniteHeight P]
  (F : FinitaryClosure P) :
  ∀ x : P, terminationRank F x ≤ HasFiniteHeight.height (P := P)
```

---

## SECTION 3: Additional originality/impact theorems

Prove at least 8 more theorems with strong names and cross-domain doc comments. Suggested targets:

### 13. Entropy-style monotonicity
```lean
/-- Bridge: connects thermodynamic entropy production to closure growth in algebraic EML. -/
theorem thermodynamic_entropy_closure_growth
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ x : P, x ≤ ClosureNucleus P F x
```
This may duplicate extensivity mathematically, but package it with application-facing naming and doc comments.

### 14. Certified robustness of fixed points under inclusion
```lean
theorem certified_robustness_of_closed_ideals
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ ⦃I J : ClosedIdealCondensation P F⦄,
    I.carrier ⊆ J.carrier →
    idealSup I.toIdealCondensation ≤ idealSup J.toIdealCondensation
```

### 15. Post-quantum lattice semantics theorem
```lean
theorem post_quantum_lattice_fixpoint_certificate
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ x : P, IsClosedPoint F (ClosureNucleus P F x)
```

### 16. Compact witness extraction with quantifier alternation
```lean
theorem compact_witness_for_nonclosed_state
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ x : P, x ≠ ClosureNucleus P F x →
    ∃ k : P, CompactElement k ∧ k ≤ ClosureNucleus P F x ∧ ¬ k ≤ x
```

### 17. Symmetry of reconstruction over binary sup
```lean
theorem quantum_symmetry_of_condensation
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ x y : P,
    ClosureNucleus P F (x ⊔ y) = ClosureNucleus P F (y ⊔ x)
```

### 18. Finite iteration exactness
```lean
theorem neural_certified_iterate_exactness
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) :
  ∀ x : P, closureIterate F 2 x = closureIterate F 1 x
```
If this is too strong, prove it assuming you have already established idempotence of `ClosureNucleus`.

### 19. Lower-set reconstruction theorem
```lean
theorem lattice_hash_collision_closedIdeal_extensionality
  {P : Type*} [CompleteLattice P] [OrderBot P]
  {I J : IdealCondensation P} :
  I.carrier = J.carrier → I = J
```

### 20. Finite sup closure induction theorem
```lean
theorem compact_sup_induction_for_certified_semantics
  {P : Type*} [CompleteLattice P] [OrderBot P]
  {S : Set P} :
  ⊥ ∈ S →
  (∀ ⦃x y⦄, x ∈ S → y ∈ S → x ⊔ y ∈ S) →
  ∀ x, (∃ n, True) → True
```
Replace this placeholder with an actually useful induction principle over finitely generated compact ideals.

---

## SECTION 4: Preferred proof architecture

Use several distinct proof styles. Do not let the file degenerate into `simp`-only proofs.

### Proof path A: algebraic-lattice reconstruction (most promising)
1. Prove every `x : P` is a supremum of compact elements below it using `IsAlgebraic`.
2. Define `ClosureNucleus P F x` as the `sSup` of `F.onCompact k` over compact `k ≤ x`.
3. Use `mono_compact` to prove monotonicity of the reconstructed operator.
4. Use `extensive_compact` and algebraicity to show `x ≤ ClosureNucleus P F x`.
5. For idempotence, show compact witnesses below `ClosureNucleus x` are already absorbed by one more application; the key intermediate lemma should be a **compact lifting lemma**:
   ```lean
   theorem compact_below_reconstructed_has_finitary_cover
     {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
     (F : FinitaryClosure P) :
     ∀ ⦃k x : P⦄, CompactElement k → k ≤ ClosureNucleus P F x →
       ∃ c : P, CompactElement c ∧ c ≤ x ∧ k ≤ F.onCompact c
   ```
   This is likely the crucial step. Try to derive it from compactness of `k` and the fact that `k ≤ sSup (...)` implies `k` is below a finite sub-sup, then fold finite sups using `map_sup_compacts`.

### Proof path B: ideal-completion / lower-set semantics
1. For a point `x`, define the ideal of compact generators below `x`.
2. For a closed ideal `I`, let `idealSup I := sSup I.carrier`.
3. Show closedness under `F.onCompact` implies `idealSup I` is a fixed point.
4. Show a fixed point `x` is recovered from the ideal of compact elements below `x`.
5. Build the equivalence and then upgrade to an order isomorphism by extensionality.

### Proof path C: computational rank / ACC
1. Prove `closureIterate F n x` forms an ascending chain using monotonicity and extensivity.
2. Under finite-height / bounded-chain hypotheses, show a strictly ascending chain longer than `h` is impossible.
3. Use contradiction (`by_contra`) to show some iterate stabilizes by step `h`.
4. Convert stabilization into exact fixed-point equality using idempotence.
5. State the resulting theorem as a certified convergence theorem for EML dynamics.

---

## SECTION 5: Concrete Lean tactics and local lemmas to use

You must deliberately diversify tactics. Suggested placements:

- `rcases`:
  unpack compact witnesses in `ClosureNucleus` and ideal membership proofs.
- `refine` / `constructor`:
  for structures `IdealCondensation`, `ClosedIdealCondensation`, equivalences.
- `ext`:
  for extensional equality of ideals/structures/subtypes where appropriate.
- `by_contra`:
  in stabilization and chain-bound arguments.
- `induction n with`
  for iterate monotonicity and finite iteration formulas.
- `linarith` / `omega`:
  for index arithmetic in chain-length arguments.
- `simpa [closureIterate]`:
  only after the hard order reasoning is done.
- `have`, `calc`, `trans`:
  for order chains.
- `field_simp`:
  include at least one auxiliary theorem with explicit rational/real decay bound if you add a numeric potential function on finite heights.
- `finite`/`Finset` induction:
  very useful for finite sup compression of compact witnesses.

Prove supporting lemmas such as:

```lean
theorem compact_sup_of_compact
  {P : Type*} [SemilatticeSup P]
  {x y : P} :
  CompactElement x → CompactElement y → CompactElement (x ⊔ y)
```

```lean
theorem finset_sup_compact_closed
  {P : Type*} [CompleteLattice P] [OrderBot P]
  (F : FinitaryClosure P) :
  ∀ {s : Finset P}, (∀ x ∈ s, CompactElement x) →
    F.onCompact s.sup id = s.sup (fun x => F.onCompact x)
```

If exact existing lemmas differ in Mathlib, adapt the signatures, but keep the mathematical role.

---

## SECTION 6: Computational and algorithmic shadow

Even though the core result is order-theoretic, extract explicit computational consequences.

Define a finite-height evaluator if needed:

```lean
def certifiedClosureCompute
  {P : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  (F : FinitaryClosure P) (h : ℕ) (x : P) : P :=
  closureIterate F h x
```

Then prove:
1. **soundness**: it returns a post-fixed / fixed point under the height bound;
2. **completeness**: it equals `ClosureNucleus P F x` once `h` exceeds the chain height;
3. **complexity statement** in theorem/doc-comment form: “requires at most `h+1` closure calls”, i.e.
```lean
theorem certifiedClosureCompute_call_bound
  ... :
  ∀ x : P, ∃ n ≤ h + 1, True
```
If a true asymptotic statement is awkward, encode exact call counts with iterates.

Also add at least one theorem with a numerical flavor, e.g. on a potential function `φ : P → ℕ` that strictly decreases on non-stable complements or increases along chains and is bounded by `h`. This gives a concrete certified convergence measure for `neural` / `post_quantum` semantics.

---

## SECTION 7: Minimal-hypothesis variants and special cases

Do not stop at the strongest theorem. Also prove 2–4 specializations:

1. A theorem for finite distributive lattices.
2. A theorem for ideals in a semiring-congruence flavored order if you can reuse existing congruence infrastructure.
3. A theorem for closure operators that are already globally defined, showing your reconstruction recovers them from compact restriction.
4. A theorem on `OrderIso` compatibility with transport:
```lean
theorem ClosureNucleus_transport_quantum
  {P Q : Type*} [CompleteLattice P] [OrderBot P] [IsAlgebraic P]
  [CompleteLattice Q] [OrderBot Q] [IsAlgebraic Q]
  (e : P ≃o Q) (F : FinitaryClosure P) :
  ∃ G : FinitaryClosure Q, True
```
Strengthen this if feasible by proving conjugacy of nuclei.

---

## SECTION 8: Significance to the research program

Your formalization should make precise that:
- **algebraic fixed points** can be reconstructed from **finitary compact data**;
- **EML semantics** can be interpreted as **iterated nucleus condensation**;
- **certified termination** follows from finite-height / ACC hypotheses;
- this provides a reusable backbone for future developments in:
  - `post_quantum` lattice protocols,
  - `quantum` order semantics,
  - `thermodynamic` monotone coarse-graining,
  - `neural` certified robustness via closure-stable abstractions.

This is not a routine closure-operator exercise: the key breakthrough is a machine-checkable bridge from **compact algebraic generators** to **computationally certified fixed-point semantics**.

---

## SECTION 9: If full generality fails

Then complete one of the following fully, with zero sorries:

### Option A: finite lattice version
Assume `[Fintype P] [DecidableEq P] [CompleteLattice P] [OrderBot P]`.
Define compactness trivially or via finite-height arguments, prove all main results in this setting, and explicitly state the conjectural generalization.

### Option B: closure-operator version
Replace `FinitaryClosure` by a globally defined closure operator `c : P → P` satisfying monotone/extensive/idempotent and prove the fixed-point / closed-ideal equivalence and termination theorem.

### Option C: ideal-semiring bridge
Use semiring congruence objects from the existing infrastructure to instantiate an order of congruence classes/ideals and prove a semiring-specific condensation theorem.

In all cases, state the remaining conjecture with an exact Lean signature.

---

## SECTION 10: Required final artifacts inside the development

At the end of the file, include:

1. A section `Examples` with at least one explicit small finite lattice instance.
2. A section `Applications` with theorem names carrying impact keywords:
   - `quantum_condensation_certificate`
   - `post_quantum_fixedpoint_rank`
   - `neural_lipschitz_certified_robustness_closure`
   - `thermodynamic_entropy_stabilization`
3. A precise conjecture block for the strongest unproved abstraction, if any.
4. A structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps, for example:
   - extend from finite-height to transfinite ordinal rank;
   - connect closed ideals to prime congruence spectra;
   - derive abstract interpretation algorithms for certified robustness;
   - build tropical / idempotent semiring instances;
   - connect condensation rank to entropy production or proof complexity.

Make the theorem statements as strong as possible under minimal hypotheses, but prefer a complete, elegant, zero-sorry theory over an overambitious incomplete one.

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
            Develop a precise correspondence between algebraic closure operators and emergent meta-language (EML) closure semantics by proving that a finitary idempotent extensive monotone operator on a semiring-enriched poset admits a canonical condensation object whose fixed-point lattice is reconstructible as an algebraic spectrum. The target result is a reconstruction principle: under compact-generation and semiring-linearity hypotheses, EML closures are equivalent to nuclei on an associated ideal/completion object, and computational fixed points can be transferred to algebraic invariants such as prime congruence strata and Noetherian termination ranks. This opens a nontrivial Algebra <-> EML bridge that the catalog explicitly lacks, differs from the in-flight Lawvere-metric EML job, and converts existing closure infrastructure into a new algorithmic pipeline for certified convergence and self-reference control.

            ### Precise Mathematical Framing
            Let P be a semiring-enriched ordered structure with a finitary closure c : P -> P satisfying monotone, extensive, idempotent. Define the condensation object Cond(P,c) as the quotient/completion generated by compact c-closed elements together with a nucleus j on an ideal semimodule Idl(P). Prove: (1) Fixed-Point Representation: Fix(c) is canonically isomorphic to the j-closed compactly generated ideals. (2) Algebraic Reconstruction: if P is Noetherian/ACC on compact generators, then every EML closure is determined by its values on generators and yields a finite termination rank. (3) Prime-Stratified Semantics: the failure of two closures to agree is witnessed on a prime congruence stratum of Cond(P,c), giving a Stone-style separation principle for closure semantics without repeating the in-flight proof-semiring Stone duality project. (4) Algorithmic Corollary: iteration of c reaches the least fixed point above x in at most the generator height, yielding a certified fixed-point computation procedure. Suggested proof route: combine ideal completion, nucleus technology, compact-element induction, and congruence separation lemmas already present around SemiringCong/elimination infrastructure. This is paradigm-opening because it reframes EML semantics as algebraic reconstruction rather than ad hoc closure dynamics, and it can spawn a field of algebraic semantics for emergent computation.

            ### Lean 4 Sketch
Define a structure `FinitaryClosure (P)` with `map_sup_compacts`; build `IdealCondensation P`; define `ClosureNucleus`; prove `fixpointLatticeIsoClosedIdeals`; then derive `terminationRank_le_height` under ACC hypotheses. Likely files near Algebra/closure, EML closure APIs, and AutoResearch congruence files.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `closure_fixed_points_are_iterative_invariants` : theorem closure_fixed_points_are_iterative_invariants {α : Type*}
     (file: Bridges/EntropyClosureSeparation.lean)
  2. `diagonal_fixed_point_idempotent` : theorem diagonal_fixed_point_idempotent (f : H → H) :
     (file: Bridges/EMLClosureCore.lean)
  3. `certified_robustness_from_margin_and_lipschitz` : theorem certified_robustness_from_margin_and_lipschitz
     (file: Bridges/HomologicalDeepLearning.lean)
  4. `closure_self_idempotent` : theorem closure_self_idempotent (c : ClosureOperator α) (x : α) :
     (file: Bridges/QuantumStabilizerClosure.lean)
  5. `closure_has_least_fixed_point` : theorem closure_has_least_fixed_point {α : Type*} [CompleteLattice α]
     (file: Bridges/QuantumTropicalCore.lean)

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



Recent successful concepts: speculative_breakthrough_discovery, geometry_breakthrough_discovery, shared_breakthrough_discovery


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
