# Future Directions: Impossibility Theory via Equivariant Obstructions

## Synthesis

This research cycle established a formal theory connecting classical impossibility theorems through the lens of equivariant tasks on free group actions. The key results — the Transfer Principle, Product Composition, Spectral Upward Closure, and Equivariant Bijectivity — form a self-consistent algebraic framework for reasoning about impossibility. The most promising cross-domain connection is between the impossibility spectrum (a novel invariant measuring which subgroups witness impossibility) and existing Catalog results on Galois obstructions (`Algebra/GaloisObstruction.lean`) and equivariant impossibility (`Catalog/Bridges/Speculative/EquivariantImpossibility/Core.lean`).

The highest breakthrough potential lies in Direction 1 (Spectral Gap Conjecture), because it would transform the impossibility spectrum from a qualitative concept into a computable, classifying invariant — giving each impossibility theorem a "fingerprint" based on its minimal witnessing subgroups. The connection to the existing `exists_impossible_equivariant_task_of_free_action` theorem is direct: our spectral analysis refines the binary existence result into a graded hierarchy. Direction 3 (Categorical Impossibility Functor) could unify the Transfer Principle with existing Galois obstruction results, potentially yielding a functorial framework where impossibility theorems compose naturally.

The cycle's results relate to the broader Catalog through the bridge between algebra and computation: the stabilizer characterization (free ↔ all stabilizers trivial) connects to `Computation/InfoEfficientAlgorithms.lean` (algorithmic lower bounds as symmetry obstructions), while the product composition theorem extends the cross-domain bridge principle in `Bridges/AlgebraEMLClosureComputation.lean` (closure systems preserve structural invariants under products).

---

### Direction 1: Spectral Gap Conjecture for Impossibility Spectra

**Conjecture**: For any finite group G acting on a finite set X, the impossibility spectrum Spec_imp(G, X) = {H ≤ G | H ≠ 1 and X^H = ∅} can have "gaps" — that is, there exist actions where a nontrivial subgroup H has fixed points (H ∉ Spec_imp) but a proper subgroup K < H has no fixed points (K ∈ Spec_imp). More precisely: there exists a group G, a G-set X, and subgroups K < H ≤ G with K ∈ Spec_imp(G,X) and H ∉ Spec_imp(G,X).

**Test**: Construct an explicit action of Z₆ on a 6-element set where the subgroup Z₂ has no fixed points but the subgroup Z₃ does. This would be a concrete spectral gap. Computationally verify using GAP or SageMath by enumerating all actions of small groups on small sets and computing their spectra.

**Impact**: If spectral gaps exist, the impossibility spectrum is NOT a sublattice of the subgroup lattice — it's merely an upper set. This means impossibility can be "deeper" than expected: small symmetries can create obstructions that larger symmetries don't, fundamentally undermining the intuition that "more symmetry = more impossibility." If spectral gaps don't exist for certain classes of groups (e.g., abelian groups), this would be a surprising rigidity result.

**Catalog References**: `Catalog/Bridges/Speculative/EquivariantImpossibility/Core.lean` (ImpossibilitySpectrum definition), `Computation/Impossibility/Core.lean` (spectrum_upward_closed, spectrum_contains_top_of_free_nontrivial)

**Proof Strategy**: For the existence direction, consider G = Z₆ = ⟨g | g⁶ = 1⟩ acting on X = {0,1,2,3,4,5} by g · k = (k + 1) mod 6. The subgroup Z₂ = {1, g³} has fixed points iff g³ fixes some element, i.e., (k+3) mod 6 = k, which has no solutions — so Z₂ ∈ Spec. The subgroup Z₃ = {1, g², g⁴} fixes k iff (k+2) mod 6 = k, also no solutions — so Z₃ ∈ Spec too. Try instead a non-regular action. Define X = {a, b, c} with g acting as (a b c)(a b c) = rotation by 2. Then g² acts as identity on some elements. Need careful construction.

**Domain Bridges**: Algebra (subgroup lattice theory) ↔ Computation (impossibility hierarchy)

**Lineage**: Builds on spectrum_upward_closed and ImpossibilitySpectrum from this cycle's Computation/Impossibility/Core.lean

**Ambition**: grand_challenge

---

### Direction 2: Impossibility Transfer via Non-Surjective Homomorphisms

**Conjecture**: The Transfer Principle (impossibility transfers along surjective homomorphisms) can be partially extended to non-surjective homomorphisms. Specifically, if φ : H →* G is a group homomorphism with image containing a nontrivial element that acts freely, then the impossibility of equivariant constant maps transfers from G to H. The precise condition is: im(φ) ∩ (G \ {1}) ≠ ∅ and the restricted action of im(φ) on X is free.

**Test**: Formalize the theorem: if φ : H →* G is a homomorphism (not necessarily surjective) and the subgroup im(φ) acts freely and nontrivially on X, then no H-equivariant (via φ) constant map X → X exists. Verify that the proof reduces to applying the core impossibility theorem to im(φ) acting on X.

**Impact**: This would show that impossibility transfer is more general than surjectivity — any homomorphism that "hits" enough of the free-acting part of G transfers the impossibility. This connects to representation theory: the condition on im(φ) relates to faithfulness of the induced representation.

**Catalog References**: `Computation/Impossibility/Core.lean` (impossibility_transfer), `Algebra/GaloisObstruction.lean` (not_solvableByRad_root_of_Gal_not_solvable)

**Proof Strategy**: Apply no_equivariant_constant to the subgroup im(φ) with the restricted MulAction instance. Need to verify that the MulAction of a subgroup inherits freeness from the ambient group's freeness restricted to that subgroup. The key lemma is: if G acts freely and H ≤ G with H ≠ 1, then H acts freely (this follows directly from the definition since H-elements are G-elements).

**Domain Bridges**: Algebra (homomorphism theory) ↔ Computation (impossibility transfer)

**Lineage**: Extends impossibility_transfer from this cycle

**Ambition**: extension

---

### Direction 3: Categorical Impossibility Functor

**Conjecture**: There exists a contravariant functor F from the category FreeAct (objects: free nontrivial group actions, morphisms: equivariant surjections) to the category of propositions (ordered by implication) that maps each action to its impossibility proposition. The functor sends morphisms (equivariant surjections) to implications (if the codomain action has an impossible task, so does the domain).

**Test**: Define the category FreeAct in Lean 4 (objects = (G, X, free nontrivial G-action on X), morphisms = pairs (φ : G₁ →* G₂, ψ : X₁ → X₂) with φ surjective and ψ equivariant). Define the functor mapping (G, X) to the proposition "∃ T : EquivariantTask G X X, ¬ TaskSolvable G X X T" and verify functoriality (composition of morphisms gives composition of implications).

**Impact**: If successful, this would provide a categorical foundation for the entire impossibility theory, enabling abstract nonsense-style reasoning about impossibility. It would also connect to existing categorical infrastructure in Mathlib (Mathlib.CategoryTheory).

**Catalog References**: `Computation/Impossibility/Core.lean` (full framework), `Catalog/Bridges/Speculative/EquivariantImpossibility/Core.lean` (exists_impossible_equivariant_task_of_free_action)

**Proof Strategy**: (1) Define the category FreeAct as a structure with group, type, MulAction, freeness proof, and nontriviality proof. (2) Define morphisms as equivariant surjective homomorphism pairs. (3) Show the impossibility proposition is functorial by composing the transfer principle with equivariant map composition. Key challenge: universe management in Lean 4 when defining categories with Type* objects.

**Domain Bridges**: Algebra (category theory) ↔ Computation (impossibility theory) ↔ Logic (propositions as objects)

**Lineage**: Synthesizes impossibility_transfer and exists_impossible_equivariant_task_of_free_action

**Ambition**: grand_challenge

---

### Direction 4: Quantitative Impossibility Measure via Index Theory

**Conjecture**: For a finite group G acting freely on a finite set X, define the *impossibility index* as idx(G, X) = min { [G : H] | H ∈ Spec_imp(G, X) }, i.e., the minimal index of a subgroup in the spectrum. Then idx(G, X) divides |G| and equals 1 if and only if the full group is the unique minimal element of the spectrum. Furthermore, idx captures a "degree of impossibility": higher index means the impossibility requires more of the group's symmetry.

**Test**: Compute idx for (1) S₅ acting on 5-element set (expected: 1, since even tiny subgroups have no fixed points on a set acted on freely); (2) Z_p acting on itself for primes p (expected: p, since the only nontrivial subgroup is the whole group); (3) D_n (dihedral group) acting on n-gon vertices. Compare the index to known algebraic invariants of the group.

**Impact**: If the impossibility index correlates with algebraic complexity measures (e.g., derived length, nilpotency class), this would quantify the informal notion that "some impossibilities are harder than others." The quintic's impossibility (A₅ is simple, so every nontrivial subgroup is "large") would have a different index profile than Arrow's impossibility (S_n has many small subgroups).

**Catalog References**: `Computation/Impossibility/Core.lean` (ImpossibilitySpectrum), `Computation/InfoEfficientAlgorithms.lean` (potential-based complexity measures)

**Proof Strategy**: Define idx in Lean 4 using Finset.inf over the spectrum restricted to Fintype groups. Prove basic properties: idx divides |G|, idx = 1 iff ⊤ is minimal in spectrum, idx > 1 iff the action has "spectral depth." For the cyclic prime case, show the spectrum is {Z_p} by proving every proper subgroup is trivial (since Z_p is simple).

**Domain Bridges**: Algebra (index theory, subgroup structure) ↔ Computation (complexity measures)

**Lineage**: Extends ImpossibilitySpectrum and spectrum_upward_closed from this cycle

**Ambition**: extension

---

### Direction 5: Diagonal Impossibility vs. Equivariant Impossibility

**Conjecture**: There exist impossibility theorems that are provably NOT instances of equivariant impossibility — i.e., impossibility phenomena that cannot be realized as "no equivariant map exists on a free action" for any group G and action. Specifically, the halting problem's undecidability is not an instance of equivariant impossibility: there is no group G acting freely on the set of Turing machines such that a halting oracle would be an equivariant map.

**Test**: Formalize the halting problem as a decision problem. Attempt to show: for any group G and free action of G on the set of Turing machine descriptions, a G-equivariant halting oracle exists (i.e., the equivariant framework does NOT obstruct it). This would demonstrate that the halting problem's impossibility comes from a fundamentally different source (diagonalization, not symmetry).

**Impact**: This would establish a formal boundary for the equivariant impossibility framework: it captures algebraic/geometric impossibilities (quintic, trisection, Arrow) but NOT computability-theoretic impossibilities (halting, Rice's theorem, Gödel). This boundary would be mathematically precise and would answer the meta-question: "Is all impossibility the same impossibility?" with a definitive "no."

**Catalog References**: `Computation/Impossibility/Core.lean` (equivariant impossibility framework), `Computation/AutomatedTheoryOracle.lean` (sound_complete_oracle_exists), `EML/DiagonalPhaseTransition.lean` (exists_incompressible_iff_not_all_compressible)

**Proof Strategy**: (1) Model Turing machines as elements of a countable type TM. (2) Observe that any group acting freely on TM must be at most countable. (3) Show that for any countable group G acting on TM, there exists a G-equivariant function f : TM → Bool (since the orbits are countable, one can define f orbit-by-orbit using choice). (4) Conclude that the halting problem's undecidability is not captured by the equivariant framework.

**Domain Bridges**: Computation (halting problem, computability) ↔ Algebra (group actions) ↔ Logic (diagonalization vs. symmetry)

**Lineage**: Builds on the full equivariant impossibility framework from this cycle, connects to diagonal phase transition results in EML

**Ambition**: grand_challenge
