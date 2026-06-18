# Future Directions: Diagonal Phase Transition Incompleteness

## 1. Converse Theorem: Subcritical Analyticity Implies Bounded Approximate Reflection

**Target statement:**
```lean
theorem subcritical_implies_bounded_reflection
    {M : Type*} [ClosureSelfModel M] [Encodable M] :
    (∀ β₀ : ℝ, DifferentiableAt ℝ (diagFreeEnergy M) β₀) →
    ∃ C : ℕ, ∀ φ : ℕ → M, Set.Infinite (Set.range φ) →
      ∃ ψ : ℕ → M, (∀ n, ClosureSelfModel.complexity (ψ n) ≤ C) ∧
        ApproximatesWithinClosure M φ ψ
```

If the diagonal free energy is everywhere differentiable (no phase transition),
then every infinite family admits a bounded-complexity approximation within the
closure. This would establish the converse: analyticity ↔ universal approximate
compressibility. Proving this requires formalizing `ApproximatesWithinClosure`
and connecting differentiability of the supremum to pointwise approximation.

## 2. Quantitative Lower Bounds from Critical Exponents

**Target statement:**
```lean
theorem complexity_lower_bound_from_critical_exponent
    {M : Type*} [ClosureSelfModel M] [Encodable M]
    {α : ℝ} (hα : 0 < α) :
    HasCriticalExponent (diagFreeEnergy M) α →
    ∃ φ : ℕ → M, Set.Infinite (Set.range φ) ∧
      ∀ n, (n : ℝ) ^ α ≤ ClosureSelfModel.complexity (φ n)
```

Near a critical point, the free energy typically behaves as |β - β_c|^α for
some critical exponent α. This should give a quantitative lower bound on
complexity growth: the witness family's complexity must grow at least
polynomially with exponent α. This connects to universality classes in
statistical mechanics and would provide concrete compression bounds.

## 3. Tropical / Legendre-Dual Reformulation

**Target:**
Reformulate the diagonal entropy barrier in terms of tropical geometry and
Legendre duality over proof semirings.

The diagonal free energy F_diag(β) = sup_m F(β, m) is already a tropical
(max-plus) operation. Its Legendre transform L(s) = sup_β [βs - F_diag(β)]
gives the rate function in a large deviations framework. The entropy barrier
becomes a statement about the tropical variety of the proof semiring:
incompressible families correspond to points where the tropical hypersurface
is non-smooth.

**Formalization target:**
```lean
def tropicalDiagFreeEnergy (M : Type*) [ClosureSelfModel M] : TropicalSemiring ℝ
def legendreDual (f : ℝ → ℝ) : ℝ → ℝ
theorem entropy_barrier_tropical_characterization ...
```

## 4. Constructive Witness Extraction from Critical-Point Data

**Target statement:**
```lean
theorem constructive_witness_from_critical_data
    {M : Type*} [ClosureSelfModel M] [Encodable M] [DecidableEq M]
    (βc : ℝ) (hcrit : ¬DifferentiableAt ℝ (diagFreeEnergy M) βc) :
    ∃ φ : ℕ → M, Computable φ ∧
      Set.Infinite (Set.range φ) ∧
      ¬ UniformlyCompressibleWithinClosure M φ
```

The current theorem uses classical logic (choice) to extract the witness
family. A constructive version would algorithmically produce the incompressible
family from the critical-point data. This requires:
- A computable enumeration of M (via `Encodable`)
- An effective test for complexity bounds
- A diagonal construction that avoids all finite-complexity families

This connects to algorithmic information theory and effective descriptive
set theory.

## 5. Finite-Model Approximation: Metastability and Bounded Incompleteness

**Target statement:**
```lean
theorem finite_model_metastability
    {M : Type*} [ClosureSelfModel M] [Fintype M] :
    ∀ β : ℝ, DifferentiableAt ℝ (diagFreeEnergy M) β

theorem finite_model_bounded_incompleteness
    {M : Type*} [ClosureSelfModel M] [Fintype M]
    {N : Type*} [ClosureSelfModel N] [Encodable N]
    (h : IsApproximation M N) :
    HasCriticalPoint (diagFreeEnergy N) →
    ∃ β_meta : ℝ, MetastableRegion (diagFreeEnergy M) β_meta ∧
      NearCriticalBehavior M N β_meta
```

Finite models cannot have true phase transitions (the free energy of a
finite system is always analytic). But they can exhibit *metastability*:
near-critical behavior that approximates a phase transition for practical
purposes. This connects to:
- The thermodynamic limit in statistical mechanics
- Finite-model theory and 0-1 laws
- Practical incompleteness phenomena in bounded formal systems (like
  bounded arithmetic or feasible theories)

## Additional Research Threads

### 5a. Connection to Proof Complexity
The compression bound C in `UniformlyCompressibleWithinClosure` can be
interpreted as a proof complexity measure. The theorem then says: phase
transitions force unbounded proof complexity for some family of statements.
This connects to the hierarchy of proof systems and circuit complexity
lower bounds.

### 5b. Multi-temperature Criticality
Extend the framework to models with multiple thermodynamic parameters
(temperature, chemical potential, external field). Phase transitions in
higher-dimensional parameter spaces give richer incompleteness phenomena:
lines of critical points, multicritical points, etc.

### 5c. Dynamic Phase Transitions
Consider time-dependent closure self-models where the free energy evolves.
Dynamic phase transitions (where the system crosses a critical point during
evolution) would correspond to the emergence of new incompressible families
over time — a formalization of how self-referential systems discover their
own limitations.
