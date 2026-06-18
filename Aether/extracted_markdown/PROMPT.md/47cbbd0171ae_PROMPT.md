

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

## Algebra–Speculative Causal Sheaf Semantics for Oracle Reversible Computation via Time-Reversal Congruence Groupoids

### Core formalization target

Build a Lean 4 development that turns the slogan

> “oracle reversible computation is a sheaf of locally invertible causal histories glued along time-reversal congruence groupoids”

into precise algebraic statements over finite causal sites. The main payoff is a **descent theorem**: local reversible oracle behaviors that satisfy a Čech-style compatibility condition glue to a unique global reversible behavior, and the only obstruction on the finite site is a computable congruence defect.

This should bridge:
- **algebra / semiring congruences**
- **sheaf semantics / finite descent**
- **reversible computation / oracle computation**
- **physics-inspired time reversal**
- **cryptographic and certified-robustness language** in theorem names/docstrings

Use the physics/crypto/ML vocabulary explicitly in theorem names and doc comments:
`quantum`, `thermodynamic`, `post_quantum`, `lattice`, `certified`, `oracle`, `reversible`, `causal`.

---

## File-level objective

Produce a substantial Lean file formalizing a finite causal site and a presheaf/sheaf of oracle-local reversible states. The development should contain:

- **10+ new definitions/structures**
- **20+ theorems/lemmas**
- **at least one main descent theorem**
- **at least one obstruction-vanishing theorem**
- **at least one explicit computational bound theorem**
- **zero sorries**

You should prefer finite/combinatorial encodings over abstract category theory if that makes the proofs stronger and more complete in Lean.

---

## Precise formal objects to define

Use finite types throughout unless there is a compelling reason not to.

### 1. Causal histories and covers

Define a finite causal history as a preorder-like reachability structure.

Suggested signatures:

```lean
structure CausalHistory (α : Type _) where
  le : α → α → Prop
  refl : ∀ a, le a a
  trans : ∀ {a b c}, le a b → le b c → le a c
```

Also define a coercion or notation so `h.le a b` can be used naturally.

Define a notion of causal cover by finite families:

```lean
structure CausalCover {α : Type _} (H : CausalHistory α) where
  ι : Type _
  [fintype_ι : Fintype ι]
  piece : ι → Set α
  covers : ∀ x : α, ∃ i, x ∈ piece i
  downward_closed :
    ∀ {i x y}, y ∈ piece i → H.le x y → x ∈ piece i
```

You may also want a “refinement” relation:

```lean
def CausalCover.Refines {α} {H : CausalHistory α}
    (U V : CausalCover H) : Prop := ...
```

and prove reflexivity/transitivity.

### 2. Time-reversal congruence

Define a symmetric relation compatible with an algebraic action.

If the semiring layer is too heavy globally, first define a purely set-theoretic congruence groupoid and then enrich it by labels in a semiring.

Suggested signatures:

```lean
structure TimeReversalCong {α : Type _} (H : CausalHistory α) where
  rel : α → α → Prop
  symm : ∀ {a b}, rel a b → rel b a
  refl : ∀ a, rel a a
  causal_respect :
    ∀ {a b c d}, rel a b → rel c d → H.le a c → H.le b d
```

Define equivalence classes only if convenient; otherwise work directly with the relation.

Also define a finite groupoid-like witness of reversible transport:

```lean
structure TimeReversalArrow {α : Type _} (T : TimeReversalCong (H := H)) where
  src : α
  dst : α
  witness : T.rel src dst
```

and composition when possible in a restricted sense. If full groupoid composition is awkward, define a partial composition relation and prove associativity where defined.

### 3. Oracle local systems

Model oracle data attached to each causal region, together with restriction and reversible transport.

A practical Lean signature is:

```lean
structure OracleLocalSystem (α S : Type _) [Semiring S] (H : CausalHistory α) where
  state : Set α → Type _
  restrict :
    ∀ {U V : Set α}, V ⊆ U → state U → state V
  restrict_id :
    ∀ {U} (x : state U), restrict (by intro u hu; exact hu) x = x
  restrict_comp :
    ∀ {U V W} (hVW : W ⊆ V) (hUV : V ⊆ U) (x : state U),
      restrict hVW (restrict hUV x) = restrict (Set.Subset.trans hVW hUV) x
  oracle_weight : ∀ U, state U → S
```

Then define a reversible enhancement:

```lean
structure ReversibleOracleLocalSystem (α S : Type _) [Semiring S]
    (H : CausalHistory α) extends OracleLocalSystem α S H where
  transport :
    ∀ {U V : Set α}, (∀ x, x ∈ U ↔ ∃ y ∈ V, True) → state U → state V
  reverse_transport :
    ∀ {U V : Set α}, (∀ x, x ∈ U ↔ ∃ y ∈ V, True) → state V → state U
```

If the above transport premise is too artificial, replace it with a custom notion of `TimeReversalEquivalentSet`.

### 4. Čech 1-cocycles and reversible descent data

Define overlaps and cocycles for finite covers. Since abstract sheaf cohomology is overkill here, use a concrete finite family definition.

Suggested signatures:

```lean
def overlap {α} (U V : Set α) : Set α := U ∩ V

structure Cech1Cocycle {α S : Type _} [Semiring S]
    {H : CausalHistory α} (F : OracleLocalSystem α S H) (U : CausalCover H) where
  section : ∀ i, F.state (U.piece i)
  compatible :
    ∀ i j,
      F.restrict (by intro x hx; exact hx.1) (section i) =
      F.restrict (by intro x hx; exact hx.2) (section j)
```

Define reversible descent data:

```lean
structure ReversibleDescentData {α S : Type _} [Semiring S]
    {H : CausalHistory α} (F : ReversibleOracleLocalSystem α S H) (U : CausalCover H) where
  local_section : ∀ i, F.toOracleLocalSystem.state (U.piece i)
  pairwise_match :
    ∀ i j,
      F.toOracleLocalSystem.restrict (by intro x hx; exact hx.1) (local_section i) =
      F.toOracleLocalSystem.restrict (by intro x hx; exact hx.2) (local_section j)
  time_reversal_invariant :
    ∀ i, True
```

The last field may be strengthened into an actual transport invariance once the transport notion is stabilized.

### 5. Obstruction and gluing defect

Define an obstruction measure that is computable on finite covers.

For example, in a decidable equality setting, define the defect as the number of pairwise incompatibilities:

```lean
def pairConflictCount ... : Nat := ...

def obstructionVanishes ... : Prop := pairConflictCount ... = 0
```

Also define a “thermodynamic” or “certified” complexity measure:

```lean
def coverComplexity {α} [Fintype α] {H : CausalHistory α} (U : CausalCover H) : Nat := Fintype.card U.ι

def gluingWorkBound {α} [Fintype α] {H : CausalHistory α} (U : CausalCover H) : Nat :=
  (Fintype.card α) * (coverComplexity U)^2
```

This gives explicit `O(|α| * |ι|^2)` bounds for brute-force compatibility checking.

---

## Main theorem targets with Lean-style signatures

You do not need to use exactly these names, but the statements should be this precise or stronger.

### A. Finite reversible descent from vanishing obstruction

```lean
theorem reversible_oracle_descent_of_obstruction_zero
    {α S : Type _} [Fintype α] [DecidableEq α] [Semiring S]
    {H : CausalHistory α}
    (F : ReversibleOracleLocalSystem α S H)
    (U : CausalCover H)
    (D : ReversibleDescentData F U)
    (hvanish : obstructionVanishes F U D) :
    ∃ g : F.toOracleLocalSystem.state Set.univ,
      ∀ i,
        F.toOracleLocalSystem.restrict
          (by intro x hx; trivial)
          g = D.local_section i
```

If `Set.univ` is not the right global region, define a canonical “total causal region”.

### B. Uniqueness of global glued section

```lean
theorem reversible_oracle_descent_unique_quantum
    {α S : Type _} [Fintype α] [DecidableEq α] [Semiring S]
    {H : CausalHistory α}
    (F : OracleLocalSystem α S H)
    (U : CausalCover H)
    (hg : ∀ x : α, ∃ i, x ∈ U.piece i) :
    ∀ g₁ g₂ : F.state Set.univ,
      (∀ i,
        F.restrict (by intro x hx; trivial) g₁ =
        F.restrict (by intro x hx; trivial) g₂) →
      g₁ = g₂
```

If this is too strong for your chosen `state`, define and prove uniqueness for a concrete state model such as functions `U → S`.

### C. Concrete sheaf model on functions

This is likely the easiest complete model and should be your backbone.

```lean
def FunctionOracleLocalSystem
    (α S : Type _) [Semiring S] (H : CausalHistory α) :
    OracleLocalSystem α S H := ...
```

with

```lean
state U := {f : α → S // ∀ x, x ∉ U → f x = 0}
```

or alternatively `U → S` if you use subtype domains.

Then prove the gluing theorem concretely:

```lean
theorem function_oracle_cech_gluing_certified
    {α S : Type _} [Fintype α] [DecidableEq α] [Semiring S]
    {H : CausalHistory α}
    (U : CausalCover H)
    (c : Cech1Cocycle (FunctionOracleLocalSystem α S H) U) :
    ∃ g : (FunctionOracleLocalSystem α S H).state Set.univ,
      ∀ i,
        (FunctionOracleLocalSystem α S H).restrict
          (by intro x hx; trivial) g = c.section i
```

### D. Explicit computational bound

State an explicit finite verification bound. Even if the theorem is simple, make it exact.

```lean
theorem certified_post_quantum_gluing_work_bound
    {α S : Type _} [Fintype α] [DecidableEq α] [Semiring S]
    {H : CausalHistory α}
    (U : CausalCover H) :
    gluingWorkBound U ≤ (Fintype.card α) * (Fintype.card U.ι)^2
```

Also prove a theorem that pairwise compatibility checking uses exactly or at most `|ι|^2` overlap checks.

### E. Time-reversal symmetry induces obstruction collapse

```lean
theorem thermodynamic_time_reversal_obstruction_collapse
    {α S : Type _} [Fintype α] [DecidableEq α] [Semiring S]
    {H : CausalHistory α}
    (F : ReversibleOracleLocalSystem α S H)
    (U : CausalCover H)
    (D : ReversibleDescentData F U)
    (hsym : ∀ i j, True) :
    pairConflictCount F U D = 0
```

If full generality is false or too hard, prove this for a concrete symmetric cover or for `FunctionOracleLocalSystem`.

---

## Strongly recommended concrete model

To ensure zero sorries, instantiate the theory with a tractable concrete sheaf:

### Suggested concrete state model
For a region `U : Set α`, let a local state be a finitely supported function that vanishes off `U`:

```lean
def SupportedFun (α S : Type _) (U : Set α) [Zero S] :=
  {f : α → S // ∀ x, x ∉ U → f x = 0}
```

Restrictions are easy:
```lean
def SupportedFun.restrict {U V : Set α} (h : V ⊆ U) :
    SupportedFun α S U → SupportedFun α S V := ...
```

Gluing is then pointwise:
- choose any `i` with `x ∈ U.piece i`
- define `g x := (D.local_section i).1 x`
- use compatibility to show independence of the chosen `i`
- use `Classical.choose` for existence of covering indices
- use `funext` and subtype extensionality for equality

This is the most promising route for the main theorem.

A second model, if time permits:
- local states are predicates on `U`
- reversible transport acts by precomposition with a symmetry
- cocycle compatibility is equality on overlaps

---

## Proof architecture: 3 viable strategies

### Strategy A: Concrete supported-function sheaf on finite sets
**Most promising.**
1. Define `SupportedFun α S U`.
2. Build `FunctionOracleLocalSystem`.
3. Define `Cech1Cocycle` and `ReversibleDescentData` concretely.
4. Glue by pointwise definition using a chosen covering witness.
5. Prove well-definedness from pairwise compatibility.
6. Derive obstruction vanishing as equivalence with pairwise compatibility.

This strategy will support the most complete theorem suite with zero sorries.

### Strategy B: Quotient by time-reversal congruence
1. Define `TimeReversalCong`.
2. Define “invariant local sections” constant on congruence classes.
3. Show pairwise-compatible invariant sections descend to quotient-compatible data.
4. Glue on the quotient, then lift back.
5. Prove obstruction collapse when every overlap lies in one congruence orbit.

This is aesthetically stronger and more physics-flavored, but only pursue after Strategy A is complete.

### Strategy C: Finite combinatorial sheaf via lists/finsets
1. Replace `Set α` with `Finset α`.
2. Define restriction by filtering support.
3. Define overlap compatibility via decidable extensional equality.
4. Count conflicts using `Finset.product`.
5. Prove exact algorithmic complexity bounds.

This is best for explicit computational bounds and cryptographic/certified language.

---

## Required theorem inventory

Prove at least 10 of the following, preferably 15+.

### Foundational lemmas
1. `causal_cover_refines_refl`
2. `causal_cover_refines_trans`
3. `overlap_comm`
4. `overlap_assoc_subset_left`
5. `supportedFun_ext`
6. `supportedFun_restrict_id`
7. `supportedFun_restrict_comp`
8. `timeReversalArrow_src_dst_symm`
9. `pairConflictCount_eq_zero_iff`
10. `obstructionVanishes_decidable`

### Sheaf/cocycle lemmas
11. `cech1cocycle_overlap_symmetry_quantum`
12. `reversible_descent_pairwise_to_triplewise`
13. `oracle_local_glue_well_defined`
14. `oracle_local_glue_support`
15. `oracle_local_glue_restrict`
16. `oracle_local_glue_unique_certified`
17. `function_oracle_is_sheaf_on_finite_causal_site`

### Time-reversal and symmetry lemmas
18. `time_reversal_transport_involutive_thermodynamic`
19. `time_reversal_congr_respects_overlap`
20. `quantum_oracle_invariant_section_descends`
21. `thermodynamic_time_reversal_obstruction_collapse`

### Computational/algorithmic bounds
22. `pairConflictCount_le_square`
23. `gluingWorkBound_exact_quadratic`
24. `certified_post_quantum_overlap_check_bound`
25. `lattice_oracle_verification_runs_in_O_n_m_sq`
   - In Lean, state this as an explicit inequality on natural-number cost functions.

### Main theorems
26. `function_oracle_cech_gluing_certified`
27. `reversible_oracle_descent_of_obstruction_zero`
28. `reversible_oracle_descent_unique_quantum`
29. `reversible_descent_exists_unique`
30. `post_quantum_oracle_globalization_on_symmetric_cover`

---

## Concrete proof steps for the main gluing theorem

For `function_oracle_cech_gluing_certified`, follow these steps.

### Step 1: Define the glued function pointwise
For each `x : α`, use `U.covers x` to choose some `i` with `x ∈ U.piece i`, and set
```lean
g x := (c.section i).1 x
```

### Step 2: Prove independence of choice
If `x ∈ U.piece i` and `x ∈ U.piece j`, then `x ∈ U.piece i ∩ U.piece j`. Use
```lean
c.compatible i j
```
and evaluate both sides at `x`. This should reduce to equality of values at `x`.

### Step 3: Prove support/globality
For global section on `Set.univ`, support is automatic. If you define a smaller total region, show the chosen value vanishes outside it.

### Step 4: Prove restriction recovers each local section
Fix `i`. Use subtype extensionality:
```lean
ext x
```
Then split by whether `x ∈ U.piece i`. The key case is immediate from the definition of `g`; the outside case follows from support-vanishing.

### Step 5: Prove uniqueness
Let `g₁ g₂` both glue the cocycle. For each `x`, choose `i` with `x ∈ U.piece i`, compare both restrictions to `c.section i`, and conclude
```lean
g₁.1 x = g₂.1 x
```
Then use `funext`.

Tactics likely useful:
- `classical`
- `rcases U.covers x with ⟨i, hi⟩`
- `ext x`
- `by_cases hx : x ∈ U.piece i`
- `simpa [overlap, Set.mem_inter_iff]`
- `funext`
- `subst`
- `omega` for cardinality/counting lemmas
- `linarith` if any arithmetic normalization appears
- `by_contra hneq` in uniqueness or zero-conflict proofs

---

## Concrete proof steps for conflict-count theorems

Define pair conflicts over finite index pairs:
```lean
Finset.univ.product Finset.univ
```
and count those pairs where restrictions disagree on overlaps.

### Key lemmas
- If all pairwise restrictions agree, then conflict count is zero.
- If conflict count is zero, every pair is compatible.
- The count is bounded by `|ι|^2`.

Suggested theorem:
```lean
theorem pairConflictCount_le_square
    {α S : Type _} [Fintype α] [DecidableEq α] [Semiring S]
    {H : CausalHistory α}
    (F : OracleLocalSystem α S H) (U : CausalCover H)
    (D : ReversibleDescentData (F := ?maybeReversible) U) :
    pairConflictCount F U D ≤ (Fintype.card U.ι)^2
```

If dependence on `ReversibleDescentData` is awkward, define the count for generic families of local sections.

Use:
- `Finset.card_product`
- `Finset.card_filter_le`
- `Nat.mul_comm`, `Nat.mul_assoc`
- `omega`

---

## Novel definitions to include

Add at least 5 of these, preferably more:

1. `CausalHistory`
2. `CausalCover`
3. `TimeReversalCong`
4. `TimeReversalArrow`
5. `OracleLocalSystem`
6. `ReversibleOracleLocalSystem`
7. `Cech1Cocycle`
8. `ReversibleDescentData`
9. `SupportedFun`
10. `pairConflictCount`
11. `obstructionVanishes`
12. `coverComplexity`
13. `gluingWorkBound`
14. `TimeReversalInvariantSection`
15. `SymmetricCausalCover`

For `SymmetricCausalCover`, a useful signature is:

```lean
structure SymmetricCausalCover {α} (H : CausalHistory α) extends CausalCover H where
  partner : ι → ι
  partner_involutive : Function.Involutive partner
  partner_piece :
    ∀ i x, x ∈ piece (partner i) ↔ x ∈ piece i
```

Then prove symmetry-induced obstruction vanishing in this setting.

---

## Typeclass and abstraction guidance

Use typeclass abstraction where natural:
- `[Semiring S]`
- `[DecidableEq α]`
- `[Fintype α]`
- optionally `[Zero S]`

If some proofs need stronger algebraic assumptions, isolate them:
- use `[CanonicallyOrderedCommSemiring S]` only for counting/monotonicity
- use `[Field S]` only if you genuinely need division
- avoid over-assuming

A nice cross-domain theorem would combine order and algebra:

```lean
theorem quantum_certified_weight_monotone_under_refinement
    {α S : Type _} [Fintype α] [DecidableEq α]
    [CanonicallyOrderedCommSemiring S]
    {H : CausalHistory α}
    (F : OracleLocalSystem α S H)
    {U V : CausalCover H}
    (hUV : U.Refines V) :
    coverComplexity V ≤ coverComplexity U
```

---

## Cross-domain theorem naming/docstring guidance

Use theorem names and doc comments that visibly bridge domains. Examples:

- `quantum_oracle_cech_descent_on_finite_causal_site`
- `thermodynamic_time_reversal_obstruction_collapse`
- `post_quantum_reversible_gluing_uniqueness`
- `lattice_certified_overlap_verification_bound`
- `oracle_entropy_zero_conflict_globalization`

Doc comment style:
```lean
/--
Bridge: connects reversible computation and sheaf semantics.
Interpretation: locally consistent oracle responses on a finite causal cover
admit a unique global section once the time-reversal congruence obstruction vanishes.
Application keywords: quantum, post_quantum_security, certified robustness.
-/
```

---

## If full abstraction becomes difficult

Prove the full story for the concrete `SupportedFun` model first, then package abstract interfaces around it.

A good fallback ladder is:

1. finite supported functions on sets
2. pairwise compatibility glues uniquely
3. conflict count zero iff compatibility
4. time-reversal symmetry implies conflict count zero for symmetric covers
5. then define abstract structures and instantiate them

Do not leave the main narrative unfinished. A complete concrete theorem is better than a vague abstract scaffold.

---

## Stretch goals

If the core file is complete, add one or two of these:

### 1. Binary-valued oracle semantics
Take `S = Bool` or `S = Fin 2` and interpret local sections as reversible decision traces. Prove a specialized gluing theorem.

### 2. Weighted semiring semantics
Show that oracle weights are preserved or bounded under gluing:
```lean
theorem oracle_weight_gluing_bound_certified
    ...
    oracle_weight Set.univ g ≤ ∑ i, oracle_weight (U.piece i) (D.local_section i)
```
If the exact inequality is hard, prove an equality or a simpler upper bound in `Nat`.

### 3. Congruence quotient semantics
Define a quotient of `α` by time-reversal congruence and show that invariant sections descend to quotient sections.

---

## Deliverable shape inside the Lean development

The file should read like a mathematical narrative:

1. finite causal sites
2. covers and refinements
3. time-reversal congruence groupoid fragments
4. oracle local systems
5. concrete supported-function sheaf
6. Čech cocycles and reversible descent data
7. conflict counts and explicit algorithmic bounds
8. gluing existence/uniqueness
9. symmetry-driven obstruction collapse
10. application-facing corollaries with quantum/post-quantum/certified naming

---

## FUTURE_DIRECTIONS.md requirement

Also produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next steps. Include at least:
1. extending finite causal descent to genuine cohomology classes
2. quotient/groupoid semantics for reversible quantum oracle circuits
3. cryptographic interpretation of obstruction classes as oracle inconsistency certificates
4. certified robustness interpretation for local-to-global neural decision patches

Be specific about the next theorem statements, not just themes.

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
            Develop a sheaf/groupoid semantics for reversible oracle computation in which local time-reversal congruences on semiring-labeled computation fragments glue exactly when causal consistency obstructions vanish. The core target is a reconstruction-and-separation package: (i) define a causal site of partial computation histories, (ii) attach semiring congruence data and oracle transition cocycles, (iii) prove that globally reversible oracle behaviors correspond to descent data on this site, and (iv) derive algorithmic criteria for detecting when an oracle computation admits a causally consistent reversible realization. This extends the recently productive Algebraic–Speculative chronometric semiring dynamics direction, but shifts from dynamics alone to a genuinely geometric semantics using sheaf and groupoid machinery, avoiding overlap with the in-flight oracle fixed-point semantics project.

            ### Precise Mathematical Framing
            Let H be a category/site of finite causal histories with coverage generated by compatible local truncations. Define a presheaf assigning to each history h a semiring congruence class of weighted transition laws together with a time-reversal involution when available. Build a groupoid of local oracle realizations over h, with morphisms given by congruence-respecting reparametrizations. Main results to target: (1) a descent criterion: a family of locally reversible oracle realizations glues to a global reversible realization iff an explicitly defined 1-cocycle obstruction in a causal congruence cohomology set vanishes; (2) a separation criterion: non-isomorphic global oracle behaviors are distinguished by stalkwise time-reversal invariants under mild locality assumptions; (3) a reconstruction principle: the global reversible oracle semantics is equivalent to the category of sheaves of congruence-groupoids satisfying causal exactness; (4) an algorithmic acyclicity test reducing reversible-realizability to finite obstruction checking on a Čech nerve of a causal cover. This creates a new bridge among semiring algebra, sheaf semantics, reversible computation, and speculative oracle hierarchies, with a computational pipeline for certifying causal consistency.

            ### Lean 4 Sketch
Likely feasible by combining existing semiring congruence infrastructure, locale/sheaf patterns from recent Bridges work, and finite-category/groupoid encodings. Core definitions: CausalHistory, CausalCover, TimeReversalCong, OracleLocalSystem, Cech1Cocycle, ReversibleDescentData. Core lemmas should mirror existing closure/sheaf representation style but on a new site. Finite descent and obstruction-vanishing statements look formalizable without heavy external libraries.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `fixed_point_construction_bound` : theorem fixed_point_construction_bound (f : H → H)
     (file: Bridges/EMLClosureCore.lean)
  2. `geometric_partial_sum_bound` : theorem geometric_partial_sum_bound (r : ℝ) (hr : 0 ≤ r) (hr1 : r ≤ 1)
     (file: Bridges/NeuralBirkhoffDecomposition.lean)
  3. `constant_unique_fixed_point` : theorem constant_unique_fixed_point (c : ℝ) :
     (file: Bridges/Advanced.lean)
  4. `generic_point_causal_source` : theorem generic_point_causal_source {S : Set (PrimeSpectrum R)}
     (file: Bridges/CausalZariskiReconstruction.lean)
  5. `EMLSelfMap_unique_fixed_point` : theorem EMLSelfMap_unique_fixed_point (x : ℝ) (hx : 0 < x) (hfp : EMLSelfMap x = x) :
     (file: Bridges/EMLDensityBridge.lean)

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
