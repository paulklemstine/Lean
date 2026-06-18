# Future Directions: Testable Hypotheses for HoTT Foundations

## Hypothesis 1: QEquiv-to-Mathlib Equiv Refactoring

**Conjecture:** Every theorem in the current HoTT kernel using `QEquiv` can be refactored to use Mathlib's `Equiv` without increasing proof length by more than 25%, and the fiber characterization theorem (`qequiv_iff_all_fibers_contr`) has a direct Mathlib analogue via `Equiv.ofBijective` and related API.

**Test:** Implement paired versions of `fundamental_theorem_id'` and `qequiv_iff_all_fibers_contr` using Mathlib's `Equiv` in place of `QEquiv`. Measure total proof length (in lines and characters) for both versions. The hypothesis is confirmed if the Mathlib versions are within 125% of the QEquiv versions in proof length. Also check whether the axiom footprint changes.

**Impact:** If confirmed, this would establish that the HoTT kernel can be seamlessly integrated into Mathlib-based projects without maintaining a parallel equivalence type. If refuted, it would identify specific friction points between HoTT-style and Mathlib-style equivalence reasoning.

## Hypothesis 2: Identity-System Formulation Yields Shorter Proofs

**Conjecture:** An abstract identity-system formulation — defining `IdentitySystem a R r` as a structure expressing that `R : A → Sort v` with `r : R a` satisfies based path induction — yields proofs that are at least 30% shorter than direct encode-decode proofs for at least two nontrivial path-space classification theorems beyond the fundamental theorem itself.

**Test:** (1) Formalize the identity-system structure. (2) Derive the fundamental theorem from identity-system induction. (3) Apply both approaches (identity-system and direct encode-decode) to characterize equality in Σ-types and equality in function types. Compare lemma count, total proof size, and proof maintenance burden (measured by the number of auxiliary lemmas required).

**Impact:** If confirmed, the identity-system approach should be adopted as the primary proof method, with encode-decode reserved for computational applications. This would reduce the formalization burden for future path-space characterizations by providing a more modular and reusable framework.

## Hypothesis 3: Univalence Interface Suffices for Three Algebraic Transports

**Conjecture:** The abstract univalence interface (`Univalence` typeclass with `ua` and `ua_transport`) is sufficient to formally transport at least three distinct algebraic structures (semigroups, partial orders, and decidable equality) across type equivalences in Lean 4, without requiring any additional axioms beyond those already in the interface.

**Test:** For each of the three structures, define a "transport theorem" of the form: given `[Univalence]`, `e : QEquiv A B`, and an instance of the structure on `A`, construct an instance on `B` using only `cast` along `Univalence.ua e` and the computation rule `ua_transport`. Verify that each transported structure satisfies its axioms. The hypothesis is confirmed if all three succeed; it is refuted if any transport requires additional axioms (e.g., function extensionality) not derivable from the univalence interface alone.

**Impact:** Confirmation would demonstrate that the univalence interface is a practical tool for structure-invariant mathematics in Lean 4. Refutation would identify the minimal additional axioms needed, potentially leading to an enriched interface.

## Hypothesis 4: Contractible-Fiber Pattern Applies Outside HoTT

**Conjecture:** The characterization "equivalence ↔ all fibers contractible" can serve as a certification pattern in at least one domain outside HoTT proper. Specifically, for finite-type oracle functions in query complexity, the oracle equivalence relation (two oracles being indistinguishable to bounded-query algorithms) can be reformulated as "all observational fibers are contractible" in a suitable sense, and this reformulation simplifies at least one existing proof.

**Test:** (1) Define "observational fiber" for oracle functions: the set of oracles that produce the same output distribution on a fixed query set. (2) Formalize the claim that two oracles are equivalent iff all observational fibers (parameterized by query sets of bounded size) are contractible (i.e., singletons up to observational equivalence). (3) Identify an existing query-complexity result (e.g., a lower bound or separation) and attempt to re-prove it using the fiber characterization. The hypothesis is confirmed if the re-proof is successful and shorter; it is refuted if the fiber structure does not naturally capture observational equivalence.

**Impact:** Confirmation would demonstrate that HoTT concepts have genuine cross-domain utility beyond foundations, opening a bridge between type-theoretic methods and computational complexity. This would be a novel application of the "contractible fibers" viewpoint.

## Hypothesis 5: Universal-Property HIT Interfaces Support Nontrivial Proofs

**Conjecture:** The abstract suspension interface (`SuspensionData`) defined via universal properties (north, south, eliminator, computation rules) is sufficient to prove the following nontrivial theorem in Lean 4: for any suspension `Σ A`, the loop space `north = north` in `Σ A` admits a map from `A` that is injective when `A` is a set with decidable equality.

**Test:** (1) Instantiate `SuspensionData` for a concrete type (e.g., `Bool`, giving a circle-like object). (2) Define the meridian-based map `A → (north = north)` by `a ↦ merid(a) · merid(a₀)⁻¹` using the eliminator. (3) Attempt to prove injectivity using the computation rules. The hypothesis is confirmed if the proof compiles without `sorry`; it is refuted if the universal-property interface is too weak (e.g., missing a dependent eliminator or coherence law).

**Impact:** Confirmation would validate the approach of encoding HITs via universal properties rather than native syntax, establishing that Lean 4 can serve as an effective HoTT laboratory without kernel extensions. Refutation would precisely identify which additional elimination principles are needed, guiding future interface design.
