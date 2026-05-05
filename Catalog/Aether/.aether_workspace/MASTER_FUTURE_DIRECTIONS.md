# MASTER FUTURE DIRECTIONS — Accumulated Research Wisdom

*Last updated: 2026-05-05 11:06*

## 5. Thermodynamic Dual Semantics: Free-Energy Interpretation

**Statement**: In the thermodynamic interpretation, derivability corresponds to
non-positive free-energy gap: `derivable x y ↔ F(x) - F(y) ≤ 0` where `F` is
a free-energy functional derived from the partition function over admissible
evaluations.

**Formalization target**:
```lean
theorem thermodynamic_duality
    [CoherentClosureProofSemiring S] [MeasurableSpace S] (x y : S) :
    derivable x y ↔ freeEnergyGap x y ≤ 0
```

where `freeEnergyGap x y = sup { log(P(e x)) - log(P(e y)) | e admissible }`.

**Why it matters**: This connects proof theory to statistical mechanics, where
the "temperature" parameter controls the sharpness of the evaluation. At zero
temperature (the "ground state"), the evaluations concentrate on the separating
prime ideals, recovering the algebraic adequacy theorem. At positive temperature,
the free-energy gap provides a smooth relaxation of derivability that could be
optimized by gradient methods.

**Approach**: Define the partition function as a sum/integral over admissible
evaluations, define the free energy via the Legendre transform, and show that
the zero-temperature limit recovers the algebraic adequacy theorem.

---

## 5. Statistical-Mechanical Extension: Partition Functions and Zero-Temperature Limits

**Problem:** Introduce the partition function `Z(β) = Σ_p exp(−β · eval(p, y) + β · eval(p, x))` and prove that the zero-temperature (β → ∞) limit selects the canonical extremal prime.

**Approach:** Define the "thermodynamic free energy"
```
F(β) = −(1/β) · log Z(β)
```
and prove:
1. `lim_{β → ∞} F(β) = max_p (eval(p, y) − eval(p, x))`
2. The Gibbs measure concentrates on the canonical countermodel as β → ∞
3. For finite β, the partition function provides a "soft" version of the compression theorem

**Significance:** This connects proof theory to statistical mechanics: the canonical countermodel is the ground state of a "proof Hamiltonian," and the partition function provides a smooth interpolation between the thermodynamic and algebraic views.

**Expected formalization:**
```
theorem zero_temperature_limit_selects_canonical
    [Fintype (PrimeSpectrum S)] [Nonempty (PrimeSpectrum S)]
    (eval : PrimeSpectrum S → S → ℝ) (x y : S) :
    Filter.Tendsto (fun β => freeEnergy eval x y β)
      Filter.atTop
      (nhds (eval (canonicalCountermodel eval x y) y -
             eval (canonicalCountermodel eval x y) x))
```

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

## 4. Algorithmic Extraction of Minimal-Energy Countermodels from Finite Spectra

**Goal**: For coherent proof semirings with finite prime spectrum, give an explicit algorithm that finds the countermodel minimizing the free-energy gap, and prove its correctness.

**Precise statement**: Define a function

  `minEnergyCountermodel : (S → S → Prop) → S → S → Option (P × ℝ)`

that, given a non-derivable pair `(x, y)`, returns the thermodynamic state `(p*, β*)` achieving the maximal free-energy gap. Prove:

  1. If `¬ derivable x y`, the function returns `some (p*, β*)` with `0 < FreeEnergyGap p* β* x y`.
  2. The returned state maximizes the gap: `∀ p β, FreeEnergyGap p β x y ≤ FreeEnergyGap p* β* x y`.

**Technical approach**: Over a finite prime spectrum, the optimization reduces to a finite search over prime points combined with a one-dimensional optimization over β ≥ 0 for each prime. The optimal β* has a closed form when the evaluation is affine in β (as in the additive thermodynamic formula).

**File**: `Bridges/MinimalEnergyCountermodel.lean`

---