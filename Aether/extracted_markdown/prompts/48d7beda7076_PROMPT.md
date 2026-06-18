

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

## YOUR ASSIGNMENT: Proof-Semiring Prime Spectrum, Spectral Topology, and Stone-Type Duality for Self-Referential Computation

Create `AutoResearch/Bridges/ProofSpectrumDuality.lean` and make it a mathematically coherent bridge between algebraic logic, spectral topology, and algorithmic semantics of self-referential proof objects. The file should not merely define a topological space; it should formalize a **computational Stone/Hochster-style dictionary** for proof semirings, where prime proof-congruences play the role of generalized “observable worlds” of a self-referential computational system.

Your core target is to define the prime spectrum of a proof semiring, endow it with a Zariski-style topology via zero loci of proof predicates, prove principality/quasi-compactness facts for basic opens, prove continuity of pullback along proof-semiring morphisms/congruence maps, and culminate in a finite-generation duality theorem showing that finitely generated proof theories determine compact-open data and vice versa.

The result should explicitly connect:
- **algebraic logic**: proof objects, theories, congruences, self-reference;
- **topology/order theory**: spectral spaces, compact opens, Stone/Hochster heuristics;
- **cryptography / ML / physics**: theorem names and doc comments must explicitly mention `post_quantum`, `lattice`, `quantum`, `entropy`, `lipschitz_certified_robustness`, or `tropical_hash_collision` where mathematically appropriate.

At minimum, the file should include 10+ definitions/structures and 20+ theorems/lemmas, with zero `sorry`.

---

## PRECISE DEFINITIONS TO IMPLEMENT

Work over a typeclass abstraction such as:

```lean
variable {R S : Type*} [CommSemiring R] [CommSemiring S]
```

If the existing proof-semiring infrastructure uses a more specific class, generalize only when safe. Prefer minimal hypotheses.

### 1. Prime proof spectrum
Define the point-set of prime proof-congruences:

```lean
def SpecProof (R : Type*) [CommSemiring R] : Type _
```

A good model is a subtype:
```lean
def SpecProof (R : Type*) [CommSemiring R] :=
  {C : ProofCongruence R // ProofCongruence.IsPrime C}
```

Also define coercions/accessors:
```lean
namespace SpecProof

def asCongruence : SpecProof R → ProofCongruence R
def carrierTheory : SpecProof R → Set R
```

If `theoryOf` already exists, package:
```lean
def theoryAt (x : SpecProof R) : Set R := theoryOf x.1
```

### 2. Vanishing and zero-locus sets
Define vanishing of an element/proof-object at a prime:
```lean
def vanishesAtPoint (r : R) (x : SpecProof R) : Prop := vanishesAt x.1 r
```

Define zero-locus for arbitrary sets:
```lean
def zeroLocusSet (s : Set R) : Set (SpecProof R) :=
  {x | ∀ r ∈ s, vanishesAtPoint r x}
```

Define principal closed sets:
```lean
def zeroLocusSingleton (r : R) : Set (SpecProof R) := zeroLocusSet ({r} : Set R)
```

Define principal opens:
```lean
def principalOpen (r : R) : Set (SpecProof R) :=
  {x | ¬ vanishesAtPoint r x}
```

Also define a finite-support version to prepare compact-open algebra:
```lean
def finitaryOpen (t : Finset R) : Set (SpecProof R) :=
  {x | ∃ r ∈ t, ¬ vanishesAtPoint r x}
```

### 3. Closed-set predicate and topological structure
Define:
```lean
def isClosed_zeroLocus (Z : Set (SpecProof R)) : Prop :=
  ∃ s : Set R, Z = zeroLocusSet s
```

Then build a topology, either directly by declaring closed sets or by constructing `TopologicalSpace (SpecProof R)` from generated opens:
```lean
instance instTopologicalSpaceSpecProof : TopologicalSpace (SpecProof R)
```

You should prove explicitly that arbitrary intersections of zero loci and finite unions of zero loci stay zero loci, so that the topology is mathematically transparent.

### 4. Pullback/comap on spectra
If there is an existing notion of semiring morphism compatible with proof congruences, define:
```lean
def comapProofCongruence (f : R →+* S) :
    SpecProof S → SpecProof R
```

The key point is that primality survives comap. If the existing library has a theorem for `ProofCongruence.IsPrime`, use it; otherwise prove the comap-prime lemma first.

Then define the induced map on theories/zero loci and prove continuity:
```lean
theorem continuous_comap (f : R →+* S) :
    Continuous (comapProofCongruence f)
```

A useful stronger lemma:
```lean
theorem preimage_zeroLocusSet
    (f : R →+* S) (s : Set R) :
    (comapProofCongruence f) ⁻¹' (zeroLocusSet s) = zeroLocusSet (f '' s) -- or suitable preimage formulation
```

Depending on your chosen `vanishesAt` convention, the correct formula may involve `Set.image` or `Set.preimage`. State the exact formula that the library supports and use it to prove continuity.

### 5. Compactness/spectrality package
Prove principal opens are quasi-compact/compact in the spectrum topology:

```lean
theorem quasiCompact_principalOpen (r : R) :
    IsCompact (principalOpen r)
```

If `IsCompact` is too strong under your topology construction, formulate a finite-subcover theorem directly:

```lean
theorem principalOpen_finite_subcover
    (r : R) {ι : Type*} (U : ι → Set (SpecProof R))
    (hUopen : ∀ i, IsOpen (U i))
    (hcover : principalOpen r ⊆ ⋃ i, U i) :
    ∃ t : Finset ι, principalOpen r ⊆ ⋃ i ∈ t, U i
```

Then package spectrality:

```lean
class IsSpectralProofSpace (X : Type*) [TopologicalSpace X] : Prop :=
  (t0 : T0Space X)
  (basis_compact_open : ∃ B : Set (Set X), ...)
  (compact_open_closed_under_inter : ...)
  (every_irreducible_closed_has_generic : ...)
```

or, if simpler, prove a theorem with the intended content:

```lean
theorem isSpectral_SpecProof (R : Type*) [CommSemiring R] :
    IsSpectralProofSpace (SpecProof R)
```

If a full generic-point theorem is too heavy for the current infrastructure, prove a weaker but still meaningful spectral package:
- `T0Space (SpecProof R)`
- principal opens form a basis
- finite intersections of principal opens are principal/finitary
- each principal open is compact

This still counts as a genuine Hochster-style bridge.

### 6. Finite-generation duality theorem
State and prove a finite-generation theorem connecting algebraic generation of theories/congruences to compact-open behavior.

Possible target:
```lean
def finitelyGeneratedTheory (T : Set R) : Prop :=
  ∃ t : Finset R, ∀ x, x ∈ T ↔ x ∈ theoryOf (eliminationCong (↑t : Set R))
```

or a more topological version:
```lean
theorem finite_generation_duality
    (T : Set R) :
    finitelyGeneratedTheory T ↔
    ∃ t : Finset R, zeroLocusSet T = zeroLocusSet (↑t : Set R)
```

An even stronger compact-open form is encouraged:
```lean
theorem finite_generation_compact_open_duality
    (U : Set (SpecProof R)) :
    IsOpen U ∧ IsCompact U ↔ ∃ t : Finset R, U = finitaryOpen t
```

If the full equivalence is too ambitious, prove one implication fully and isolate the converse as a precise conjecture. But prefer a complete theorem in the finitely generated fragment.

---

## REQUIRED THEOREMS AND SUGGESTED LEAN SIGNATURES

You should aim to prove at least the following theorem family, adapting names only if required by the existing API. Use inventive names and include application keywords in doc comments.

```lean
theorem zeroLocusSet_univ :
    zeroLocusSet (Set.univ : Set R) = {x : SpecProof R | ∀ r : R, vanishesAtPoint r x}

theorem zeroLocusSet_empty :
    zeroLocusSet (∅ : Set R) = Set.univ

theorem zeroLocusSet_mono {s t : Set R} (h : s ⊆ t) :
    zeroLocusSet t ⊆ zeroLocusSet s

theorem zeroLocusSet_union :
    zeroLocusSet (s ∪ t) = zeroLocusSet s ∩ zeroLocusSet t

theorem zeroLocusSet_iUnion {ι : Sort*} (s : ι → Set R) :
    zeroLocusSet (⋃ i, s i) = ⋂ i, zeroLocusSet (s i)

theorem principalOpen_eq_compl_zeroLocusSingleton (r : R) :
    principalOpen r = (zeroLocusSingleton r)ᶜ

theorem principalOpen_inter_principalOpen
    (r s : R) :
    principalOpen r ∩ principalOpen s ⊆ principalOpen (r * s)

theorem prime_forces_product_visibility
    (x : SpecProof R) (r s : R) :
    ¬ vanishesAtPoint (r * s) x → ¬ vanishesAtPoint r x ∧ ¬ vanishesAtPoint s x

theorem product_in_zeroLocus_quantum_entropy
    (x : SpecProof R) (r s : R) :
    vanishesAtPoint (r * s) x → vanishesAtPoint r x ∨ vanishesAtPoint s x

theorem t0_of_theory_separation :
    T0Space (SpecProof R)

theorem principalOpen_basis_lattice_certified :
    IsTopologicalBasis {U : Set (SpecProof R) | ∃ r : R, U = principalOpen r}

theorem comapProofCongruence_wellDefined
    (f : R →+* S) (x : SpecProof S) :
    ProofCongruence.IsPrime (SpecProof.asCongruence (comapProofCongruence f x))

theorem vanishing_comap_iff
    (f : R →+* S) (x : SpecProof S) (r : R) :
    vanishesAtPoint r (comapProofCongruence f x) ↔ vanishesAtPoint (f r) x

theorem preimage_principalOpen_post_quantum
    (f : R →+* S) (r : R) :
    (comapProofCongruence f) ⁻¹' principalOpen r = principalOpen (f r)

theorem continuous_comap (f : R →+* S) :
    Continuous (comapProofCongruence f)

theorem finitaryOpen_eq_iUnion_principal
    (t : Finset R) :
    finitaryOpen t = ⋃ r ∈ t, principalOpen r

theorem compact_finitaryOpen_lattice_hash
    (t : Finset R) :
    IsCompact (finitaryOpen t)

theorem quasiCompact_principalOpen (r : R) :
    IsCompact (principalOpen r)

theorem finite_generation_zeroLocus_reflection
    (T : Set R) :
    finitelyGeneratedTheory T →
    ∃ t : Finset R, zeroLocusSet T = zeroLocusSet (↑t : Set R)

theorem finite_generation_compact_open_duality
    (U : Set (SpecProof R)) :
    IsOpen U → IsCompact U →
    ∃ t : Finset R, U = finitaryOpen t

theorem isSpectral_SpecProof :
    IsSpectralProofSpace (SpecProof R)
```

You should add further supporting lemmas so the file reads as a complete theory, not a sparse theorem list.

---

## PROOF STRATEGY: KEY MATHEMATICAL STEPS

### Strategy A: Zero-locus calculus first, topology second, spectrality third
This is the most promising route.

1. **Build the set-theoretic calculus of zero loci**
   - Prove `zeroLocusSet_empty`, `zeroLocusSet_union`, `zeroLocusSet_iUnion`.
   - These are mostly extensionality proofs:
     ```lean
     ext x; constructor <;> intro hx
     ```
     followed by `constructor`, `intro`, `rcases`, and set membership unfolding.
   - Use `simp [zeroLocusSet, vanishesAtPoint]` aggressively, but not exclusively.

2. **Exploit primality exactly once to get the topology/algebra bridge**
   - The crucial lemma is the prime vanishing law:
     ```lean
     vanishesAtPoint (r * s) x ↔ vanishesAtPoint r x ∨ vanishesAtPoint s x
     ```
     or at least the forward implication.
   - This is the engine behind:
     - closed-set union formulas,
     - intersection formulas for principal opens,
     - basis closure under finite intersections.
   - If `ProofCongruence.IsPrime` is currently incomplete, close that gap first in the source file where it belongs or prove a local lemma that exposes the elimination principle you need.

3. **Construct the topology from principal opens**
   - Define opens by complement of zero loci or directly use principal opens as a prebasis.
   - Prove:
     - `principalOpen r = (zeroLocusSingleton r)ᶜ`
     - finite intersections of principal opens are finitary/principal-open controlled.
   - Then derive `IsTopologicalBasis`.

4. **Prove continuity by preimage-on-basis**
   - For `continuous_comap`, it is enough to show preimages of basis opens are basis opens:
     ```lean
     refine isOpenMap_iff_nhds_le ?_ -- only if convenient
     ```
     but the simpler route is:
     ```lean
     rw [continuous_iff_isClosed]
     ```
     if your topology was built from closed zero loci, or use `continuous_generateFrom`.
   - The key lemma is `vanishing_comap_iff`.

5. **Package compactness via finite generation**
   - Define `finitaryOpen t` as finite union of principal opens.
   - Prove compactness of `finitaryOpen t` by induction on `Finset`.
   - Then `quasiCompact_principalOpen` is the singleton case.
   - The finite-generation duality theorem should use elimination congruences and the fact that vanishing against a finitely generated theory depends on finitely many generators.

### Strategy B: Order-theoretic Stone route through compact opens
Use if the direct topological package becomes awkward.

1. Define the distributive lattice of finitary opens.
2. Show:
   - top/bot correspond to `∅` and `univ`,
   - meet corresponds to intersection,
   - join corresponds to finite union.
3. Construct a Stone-style map from finitely generated theories to compact opens:
   ```lean
   FGTheory R → OrderIso (CompactOpenSubsets (SpecProof R))
   ```
   or a theorem-level surrogate.
4. This route is elegant if the existing order infrastructure is strong, but may be heavier in Lean.

### Strategy C: Computational semantics route via theory extraction
Use if the topology API becomes too cumbersome.

1. Formalize the algebra of theories generated by finite proof-sets.
2. Show zero-loci only depend on elimination-normal forms of generating sets.
3. Prove the duality theorem in set-theoretic form first:
   ```lean
   finitelyGeneratedTheory T ↔ ∃ t : Finset R, zeroLocusSet T = zeroLocusSet ↑t
   ```
4. Then recover compactness as a corollary by defining opens to be unions of complements of these closed sets.

This route is especially good for the “algorithmic shadow” requirement.

---

## TACTIC DIVERSITY REQUIREMENT

Use a wide range of proof styles across the file:
- `ext`
- `constructor`
- `intro`, `rintro`
- `rcases`
- `by_cases`
- `by_contra`
- `simpa`
- `aesop` only sparingly, never as the sole engine
- `induction` on `Finset` for compactness/finitary opens
- `omega` for finite-cardinality bookkeeping if needed
- `linarith` or `nlinarith` only if numeric bounds arise in an algorithmic section
- `field_simp` only if a normalization/rational-weight side lemma is introduced
- `exact`, `refine`, `have`, `specialize`

To satisfy rigor, include at least one nontrivial induction, one `by_contra` separation proof for `T0`, and one proof using `rcases` on prime witnesses.

---

## ADDITIONAL DEFINITIONS FOR UTILITY AND IMPACT

To strengthen the research program, define at least 5 of the following:

```lean
def proofSupport (T : Set R) : Set R := {r | r ∈ T}

def finitelyGeneratedTheory (T : Set R) : Prop := ∃ t : Finset R, ...

def compactOpenGenerated (U : Set (SpecProof R)) : Prop :=
  ∃ t : Finset R, U = finitaryOpen t

def proofSpectralRank (U : Set (SpecProof R)) : Nat :=
  sInf {n | ∃ t : Finset R, t.card = n ∧ U = finitaryOpen t}

def quantumEntropyWitness (x : SpecProof R) (r s : R) : Prop :=
  vanishesAtPoint (r * s) x → vanishesAtPoint r x ∨ vanishesAtPoint s x

def postQuantumSeparationProfile (x y : SpecProof R) : Prop :=
  ∃ r : R, vanishesAtPoint r x ∧ ¬ vanishesAtPoint r y

def certifiedRobustTheoryRadius (t : Finset R) : Nat := t.card

def latticeHashCollisionWindow (t : Finset R) : Set (SpecProof R) := finitaryOpen t
```

Even if some are mathematically lightweight, they give handles for theorem statements with algorithmic meaning.

Then prove explicit bounds such as:
```lean
theorem proofSpectralRank_le_card
    (t : Finset R) :
    proofSpectralRank (finitaryOpen t) ≤ t.card
```

```lean
theorem certifiedRobustTheoryRadius_singleton
    (r : R) :
    certifiedRobustTheoryRadius ({r}.toFinset) = 1
```

Or, if singleton finset notation is awkward:
```lean
theorem certifiedRobustTheoryRadius_singleton
    (r : R) :
    certifiedRobustTheoryRadius ({r}) = 1
```

If exact complexity is formalizable, include algorithmic statements like:
```lean
theorem finitaryOpen_membership_decision_bound
    [DecidableEq R]
    (t : Finset R) (x : SpecProof R) :
    ∃ n : Nat, n ≤ t.card + 1
```
as a placeholder for a concrete finite decision bound. Prefer genuinely meaningful bounds over vacuous existence.

---

## CROSS-DOMAIN DOC COMMENTS AND THEOREM NAMING

Every major definition and theorem should have a doc comment of the form:

```lean
/--
Bridge: connects algebraic proof semantics to spectral topology and
post_quantum / quantum / certified robustness interpretations.

The principal open `D(r)` records prime proof-worlds where `r` remains
observable. This behaves like a logical analogue of a measurable event,
a lattice-separation primitive in cryptographic semantics, and a
certified robustness witness in self-referential ML semantics.
-/
```

Use application-bearing names where reasonable:
- `preimage_principalOpen_post_quantum`
- `principalOpen_basis_lattice_certified`
- `product_in_zeroLocus_quantum_entropy`
- `compact_finitaryOpen_lattice_hash`
- `finite_generation_zeroLocus_reflection`
- `proof_theory_stone_bridge`
- `hochster_selfReference_window`
- `t0_post_quantum_separation`

These names should still reflect actual mathematical content.

---

## MAIN BREAKTHROUGH STATEMENT TO PRIORITIZE

The central theorem should read, in one robust form or another:

```lean
/--
Bridge: connects self-referential proof theories to spectral spaces,
with compact opens representing finitely generated observable constraints.
This is the proof-semiring analogue of Stone/Hochster duality and gives a
formal topological semantics for quantum-observable, lattice-cryptographic,
and certified-robustness interpretations of proof systems.
-/
theorem finite_generation_compact_open_duality
    (U : Set (SpecProof R)) :
    IsOpen U → IsCompact U →
    ∃ t : Finset R, U = finitaryOpen t
```

And package the spectral conclusion:

```lean
/--
Bridge: the prime proof spectrum is a spectral space in the Hochster sense.
This equips self-referential computation with a topological phase space whose
compact opens are finitely generated proof observables, relevant to
post_quantum separation and lipschitz_certified_robustness semantics.
-/
theorem isSpectral_SpecProof :
    IsSpectralProofSpace (SpecProof R)
```

If necessary, define your own `IsSpectralProofSpace` tailored to the theorems you can prove completely.

---

## IF THE FULL DUALITY IS TOO STRONG

Do not stall. Prove the strongest complete fragment, in this order:

1. `SpecProof` definition and topology.
2. Zero-locus calculus.
3. `principalOpen` basis and `T0`.
4. `comapProofCongruence` and `continuous_comap`.
5. Compactness of `finitaryOpen`.
6. One-way finite-generation theorem:
   ```lean
   finitelyGeneratedTheory T → ∃ t, zeroLocusSet T = zeroLocusSet ↑t
   ```
7. A precise conjecture for the converse, with the exact Lean statement.

But the default goal remains a complete theorem suite with no gaps.

---

## FILE STRUCTURE TO AIM FOR

Organize the file into sections:

```lean
namespace AutoResearch
namespace Bridges
namespace ProofSpectrumDuality

section BasicDefs
section ZeroLocusCalculus
section PrincipalOpens
section Topology
section Comap
section CompactOpens
section FiniteGenerationDuality
section SpectralPackage

end ProofSpectrumDuality
end Bridges
end AutoResearch
```

Within each section, prove local helper lemmas before the headline theorem. Avoid giant monolithic proofs; instead, create reusable intermediate lemmas such as:
- `mem_zeroLocusSet_iff`
- `mem_principalOpen_iff`
- `zeroLocusSet_insert`
- `principalOpen_mul_subset_inter`
- `finitaryOpen_insert`
- `isOpen_principalOpen`
- `isCompact_finitaryOpen_induction`

---

## SIGNIFICANCE FOR THE RESEARCH PROGRAM

This file should establish a new semantic layer for the project: proof systems are no longer only algebraic or syntactic objects, but **topological phase spaces of prime observational worlds**. That matters because:

- In **logic/self-reference**, it gives a geometric semantics for consistency fragments and observational separation.
- In **cryptography**, principal opens behave like finite observability windows and can model `post_quantum_security`-style distinguishability primitives.
- In **ML/certified robustness**, compact opens represent finitely generated stable regions of proof-behavior, analogous to finite certificates of robustness.
- In **physics/quantum semantics**, prime points act like irreducible observational phases, and vanishing laws resemble event-factorization constraints.

This is not an incremental extension: it is the beginning of a genuine Stone/Hochster dictionary for self-referential computation.

---

## REQUIRED END PRODUCT

Produce:
1. `AutoResearch/Bridges/ProofSpectrumDuality.lean` with the full theorem suite above.
2. A structured `FUTURE_DIRECTIONS.md` containing 3–5 concrete next steps, such as:
   - sobrification / generic-point strengthening for proof spectra,
   - a distributive-lattice equivalence between compact opens and finitely generated proof theories,
   - tropicalization of proof spectra and `tropical_hash_collision` semantics,
   - sheaf semantics on `SpecProof` for local proof states,
   - a comparison theorem with classical prime ideal spectra or Kripke frames.

No `sorry`, no placeholders, and no purely cosmetic topology: every definition should feed at least one substantial theorem.

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
            Develop a mathematically precise duality between algebraic proof congruences and topological spaces of theories by proving that the prime spectrum of the proof semiring is a spectral space, and that semiring morphisms induce continuous maps enabling a contravariant equivalence on a finitely generated subcategory. The central concept is to treat proofs/programs as elements of an idempotent semiring, define prime proof congruences via `ProofCongruence.IsPrime`, construct `SpecProof` from zero loci/theory maps, and prove a Stone/Hochster-style representation theorem for self-referential proof systems. This creates a new bridge between Logic, Algebra, and Computation while leveraging underused catalog infrastructure around congruence elimination and proof semirings.

            ### Precise Mathematical Framing
            Let R be a proof semiring with predicates `vanishesAt : R → ProofCongruence R → Prop`, `zeroLocus : Set R → Set (ProofCongruence R)`, and `theoryOf : Set (ProofCongruence R) → Set R` as suggested by `PrimeCongruenceProofSemiring.lean`. Define `SpecProof(R) = { P : ProofCongruence R // P.IsPrime }` with closed sets V(S)=zeroLocus(S)∩SpecProof(R). Prove: (1) Galois connection `S ⊆ theoryOf(X) ↔ X ⊆ V(S)`; (2) finite unions/intersections identities `V(S∪T)=V(S)∩V(T)` and `V(s*t)=V(s)∪V(t)` in the semiring sense; (3) `SpecProof(R)` is T0, quasi-compact on principal opens, and spectral when R is finitely generated/idempotent; (4) every semiring morphism f:R→S induces a continuous pullback map `SpecProof(S)→SpecProof(R)`; (5) under finite generation and congruence elimination, the assignment `R ↦ SpecProof(R)` yields a contravariant duality with a category of spectral proof spaces. Algorithmically, this gives a pipeline for extracting semantic invariants of self-referential proof/program systems from algebraic presentations. The proof strategy should combine catalog congruence elimination (`eliminationCong`), prime congruence definitions, closure operators on theories, and standard spectral-space arguments adapted from prime ideals to semiring congruences.

            ### Lean 4 Sketch
Create `AutoResearch/Bridges/ProofSpectrumDuality.lean`. Define `SpecProof`, `isClosed_zeroLocus`, `principalOpen`, `comapProofCongruence`, `continuous_comap`, `quasiCompact_principalOpen`, `isSpectral_SpecProof`, and a finite-generation duality theorem. Likely imports: `AutoResearch/PrimeCongruenceProofSemiring`, `AutoResearch/CongruenceElimination`, `AutoResearch/Basic`, plus topology/order basics. A first milestone is closing the sorry in `ProofCongruence.IsPrime` and proving zero-locus lemmas; then package the topological structure.

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `rate_distortion_duality_of_coherent_proof_semiring` : theorem rate_distortion_duality_of_coherent_proof_semiring
     (file: Bridges/LawvereRateDistortionDuality.lean)
  2. `thermodynamic_stone_prime_completeness_beta_zero` : theorem thermodynamic_stone_prime_completeness_beta_zero
     (file: Bridges/ThermodynamicStonePrimeCompleteness.lean)
  3. `lawvere_proof_coding_theorem` : theorem lawvere_proof_coding_theorem
     (file: Bridges/LawvereCodingTheorem.lean)
  4. `spectral_search_space_bound` : theorem spectral_search_space_bound (k : ℕ) : k < 2 ^ k :=
     (file: Bridges/ProofAlgGeomBridge.lean)
  5. `purity_lower_bound_from_spectrum` : theorem purity_lower_bound_from_spectrum (k : ℕ) (hk : k > 0)
     (file: Bridges/QuantumIdempotent.lean)

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



Recent successful concepts: Foundations of Information-Theoretic Shared Structures, speculative_breakthrough_discovery, speculative_breakthrough_discovery


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
