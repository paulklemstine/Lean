# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-05 08:05*

## Key Open Problem

The central open question is whether the `linResultantPair` formula
(or any fixed polynomial-time computable formula) can produce
generators of the elimination congruence from generators of the
original congruence, for arbitrary idempotent semirings.

Our analysis suggests this may be impossible in full generality:
unlike classical ideal elimination (which uses subtraction/determinants),
semiring congruences cannot "cancel" the eliminated variable from
relations. The correct framework may require either:

1. **Evaluation-based witnesses**: Using ring endomorphisms (evaluation
   maps) to project congruences, rather than algebraic elimination.

2. **Lattice-theoretic methods**: Exploiting the lattice structure of
   congruences over idempotent semirings (which form a distributive
   lattice) to perform elimination via lattice-theoretic operations.

3. **Restricted classes**: Proving elimination for specific classes of
   idempotent semirings (totally ordered, Boolean, etc.) where
   additional structural properties enable cancellation-like operations.

## 5. Comparison with Stone/Localic Duality for Proof Semirings

**Target**: Establish a formal comparison between nucleus-sheaf reconstruction and Stone duality for distributive lattices, mediated by the proof semiring interpretation.

```
theorem nucleus_sheaf_vs_stone_duality
    (S : Type*) [CoherentIdemCommSemiring S] :
    Nonempty (NucleusSpectrum S ≃ₜ StoneSpectrum (IdealLattice S))
```

In a proof semiring (where elements represent derivations), the nucleus spectrum should be homeomorphic to the Stone spectrum of the lattice of theories. The sheaf reconstruction then corresponds to the Stone representation of the lattice as clopen sets of a spectral space. This comparison would unify the algebraic-geometric viewpoint (sheaves on spectra) with the order-theoretic viewpoint (Stone duality) and the proof-theoretic viewpoint (completeness of derivation systems). Establishing this triangle of equivalences would be a major structural result connecting algebra, topology, and logic in the idempotent setting.

## 5. Algorithm Extraction: Certified Decision Procedure

**Target artifact.** Extract from the Lean proofs a certified
executable algorithm for congruence membership testing via
evaluation elimination.

```lean
def eliminationOracle
    [Fintype τ] [DecidableEq S] [Fintype S]
    (C : RingCon (MvPolynomial (σ ⊕ τ) S))
    (generators : Finset (MvPolynomial (σ ⊕ τ) S × MvPolynomial (σ ⊕ τ) S))
    (hgen : C = ringConGen (fun f g => (f, g) ∈ generators))
    (f g : MvPolynomial σ S) :
    Decidable (eliminationCong C f g) := ...
```

The algorithm proceeds by:
1. Enumerating evaluation witnesses up to the computed degree bound
2. Testing each contraction membership (reduces to ideal membership
   in the finitely generated case)
3. Returning a certificate of membership or a separating evaluation

This would be the first formally verified elimination algorithm for
the congruence setting, directly applicable to tropical constraint
satisfaction and optimization verification.

---

## 4. Categorical Reformulation: Elimination as Right Kan Extension

**Target construction.** Define the evaluation site as the category of
evaluation maps `evalXY φ` and show that the elimination congruence is
the right Kan extension of the congruence `C` along the restriction
functor from the (x,y)-spectrum to the x-spectrum.

```lean
def EvaluationSite (C : RingCon (MvPolynomial (σ ⊕ τ) S)) :
    Category where
  Obj := {φ : τ → MvPolynomial σ S // AdmissibleEval C φ}
  Hom φ ψ := ... -- morphisms witnessing contraction refinement

theorem elimination_as_Kan_extension :
    eliminationCong C = rightKanExtension (EvaluationSite C) (congruencePresheaf C) := ...
```

This reformulation would unify the spectral evaluation theorem with
descent theory for congruences. It opens the door to cohomological
obstruction theory for elimination: when does elimination fail to
commute with base change? The Kan extension viewpoint makes this
a question about derived functors.

---