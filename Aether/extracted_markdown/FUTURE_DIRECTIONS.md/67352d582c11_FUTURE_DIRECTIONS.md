# Future Directions: Spectral Evaluation Elimination

Building directly on the Spectral Evaluation Elimination Theorem formalized
in `Catalog/Algebra/AutoResearch/SpectralEvaluationElimination.lean`, the
following concrete next steps extend the theory toward algorithmic,
categorical, and geometric applications.

---

## 1. Jacobson–Chevalley Theorem for Multi-Stage Elimination

**Target theorem.** For a tower of variable groups σ₁ ⊕ σ₂ ⊕ ... ⊕ σₖ,
multi-stage elimination (eliminating σₖ, then σₖ₋₁, etc.) equals
single-stage elimination of σ₂ ⊕ ... ⊕ σₖ simultaneously.

```lean
theorem multistage_elimination_eq
    (C : RingCon (MvPolynomial (σ₁ ⊕ σ₂ ⊕ σ₃) S)) :
    eliminationCong (eliminationCong C) =
      eliminationCong (C.comap (liftX.comp liftX)) := ...
```

The proof should factor through the spectral evaluation theorem at each
stage, showing that evaluation contractions compose coherently. This would
establish that spectral elimination is a **well-defined functor** on
congruence lattices, independent of elimination order — the analogue of
the Chevalley theorem for constructible sets.

---

## 2. Effective Finite Witness Bounds

**Target theorem.** Quantify the number and degree of evaluation witnesses
in terms of the compact generators of the congruence.

```lean
theorem finite_witness_bound
    (C : RingCon (MvPolynomial (σ ⊕ τ) S))
    (hfg : C = ringConGen r)
    (hcard : ∃ n, Fintype.card (support r) ≤ n) :
    ∃ N : ℕ, ∃ Φ : Fin N → (τ → MvPolynomial σ S),
      N ≤ f(n, degree_bound) ∧
      eliminationCong C = sInf (Set.range (fun i => evalContraction C (Φ i))) := ...
```

The bound should be polynomial in the number of generators and exponential
only in the number of eliminated variables, making it competitive with
Gröbner-based methods for fixed elimination depth. This directly enables
certified tropical quantifier elimination with complexity guarantees.

---

## 3. Tropical Quantifier Elimination via Admissible Evaluation Spectra

**Target theorem.** For tropical polynomial systems (congruences over the
tropical semiring T = (ℝ ∪ {∞}, min, +)), show that the evaluation
separation property holds with evaluations restricted to piecewise-linear
functions of bounded slope.

```lean
theorem tropical_eval_separation
    (C : RingCon (MvPolynomial (σ ⊕ τ) TropicalSemiring))
    {f g : MvPolynomial σ TropicalSemiring}
    (hfg : ¬eliminationCong C f g) :
    ∃ φ : τ → MvPolynomial σ TropicalSemiring,
      degree φ ≤ max_degree C ∧
      ¬evalContraction C φ f g := ...
```

This would give the first purely spectral proof of tropical quantifier
elimination, bypassing the usual polyhedral geometry route. It connects
directly to tropical Presburger arithmetic and decidability of tropical
polynomial optimization.

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

## Summary

These directions form a coherent program:
- **Direction 1** establishes structural foundations (functoriality)
- **Direction 2** provides quantitative guarantees (bounds)
- **Direction 3** specializes to the key application domain (tropical)
- **Direction 4** reveals the abstract mechanism (Kan extensions)
- **Direction 5** delivers computational payoff (certified algorithms)

Each builds on the spectral evaluation theorem as its foundation,
and each would constitute a significant advance in its own right.
