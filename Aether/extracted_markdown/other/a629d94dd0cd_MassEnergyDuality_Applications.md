# Applications of Mass-Energy Stereographic Duality

## 1. Particle Physics: Natural Units and the Mass Shell

The inversion duality t ↦ 1/t corresponds directly to the relationship between
a particle's **Compton wavelength** λ = ℏ/(mc) and its **de Broglie wavelength**
λ = h/p. In natural units (c = ℏ = 1), mass m and energy E satisfy E = 1/m for
a particle at rest, which is precisely our transition map.

**Application**: The stereographic framework provides a geometric understanding of
the mass shell condition p² = m² in momentum space. The on-shell constraint is the
condition that the state lies on S¹, and the two projections give the mass and
energy parametrizations of the shell.

## 2. Conformal Field Theory

Stereographic projection is a **conformal map** — it preserves angles. The transition
map t ↦ 1/t is a Möbius transformation, the fundamental symmetry of conformal field
theory (CFT). The mass-energy duality is therefore a **conformal symmetry**.

**Application**: In 2D CFT, the operator-state correspondence maps operators (energy)
to states (mass) via exactly this conformal map. Our formalization provides the
rigorous mathematical foundation for this correspondence.

## 3. String Theory: T-Duality

In string theory, **T-duality** relates a string compactified on a circle of radius R
to a string on a circle of radius 1/R. This is precisely the inversion map t ↦ 1/t
applied to the compactification radius.

**Application**: Our formal proof that inversion is an involutive homeomorphism
provides the mathematical backbone for T-duality. The photon graph structure
captures the worldsheet topology of interacting strings.

## 4. Quantum Computing: Gate Synthesis

The stereographic parametrization of S¹ (and more generally Sⁿ) is used in
**quantum gate synthesis**: mapping continuous gate parameters to points on the
Bloch sphere. The inversion duality corresponds to the relationship between a gate
and its inverse.

**Application**: The photon graph morphisms we define are exactly the structure-preserving
maps needed for quantum circuit optimization — transformations that preserve the
causal ordering (DAG property) while simplifying the circuit.

## 5. Signal Processing: The Cayley Transform

The map t ↦ (t-i)/(t+i) from ℝ to S¹ (the Cayley transform) is closely related to
stereographic projection. It maps the real frequency axis to the unit circle in the
z-plane, connecting continuous-time and discrete-time signal processing.

**Application**: The mass-energy duality (inversion on ℝ) corresponds to **frequency
inversion** in signal processing — swapping low and high frequencies. This is the
mathematical basis for bandpass-to-lowpass filter transformations.

## 6. Network Science: Causal DAGs

The photon event graph is a concrete instance of a **causal DAG** — the same
mathematical structure used in:
- **Bayesian networks** for probabilistic inference
- **Blockchain** transaction graphs
- **Distributed systems** event ordering (Lamport clocks)

**Application**: Our proof that the photon graph is acyclic (no causal loops) and
that it defines a unique propagator is directly applicable to any causal inference
system. The equilibrium-idempotence theorem characterizes steady-state behavior.

## 7. Machine Learning: Stereographic Neural Networks

The inverse stereographic projection is used in neural network architectures to
map unconstrained parameters to unit-norm vectors (as formalized in this project's
`StereographicProjection.lean`). The mass-energy duality gives a **dual parametrization**:

- **Mass parametrization** (north-pole chart): natural for the "weight" interpretation
- **Energy parametrization** (south-pole chart): natural for the "activation" interpretation
- **Transition**: switching between parametrizations via inversion

**Application**: Dual parametrization can improve optimization by switching between
charts when one becomes singular (near the poles).

## 8. Cosmology: The Photon Graph of the Universe

If the universe's photon graph is connected (all photons traceable to common events),
this has implications for:
- **The cosmic microwave background**: all CMB photons share a common source (the surface
  of last scattering), making that subgraph connected
- **The horizon problem**: disconnected components of the photon graph correspond to
  causally disconnected regions
- **Information paradoxes**: the DAG structure constrains information flow

**Application**: The graph morphism framework provides a way to compare different
cosmological models by their photon graph structure.

## 9. Thermodynamics: Equilibrium as Idempotence

Our theorem that the propagator is idempotent at equilibrium connects to:
- **Detailed balance**: at thermal equilibrium, every process is balanced by its reverse
- **Maximum entropy states**: the oracle/fixed-point characterization of equilibrium
- **The second law**: non-equilibrium states are NOT idempotent — they evolve

**Application**: The oracle framework provides an information-theoretic characterization
of thermodynamic equilibrium that complements the standard entropy-based formulation.

## 10. Cryptography: Inversion in Finite Fields

The inversion map t ↦ 1/t is the core nonlinear operation in the **AES S-box**
(Advanced Encryption Standard). Our proof that inversion is an involutive bijection
on the nonzero elements is the same algebraic property used in AES, transplanted
from finite fields to ℝ.

**Application**: The stereographic framework suggests new S-box constructions based
on projections from higher-dimensional spheres, potentially offering better
cryptographic properties.

---

## Summary Table

| Domain | Mass-Energy Duality Corresponds To | Photon Graph Corresponds To |
|--------|------------------------------------|-----------------------------|
| Particle Physics | Mass shell condition | Feynman diagrams |
| String Theory | T-duality (R ↔ 1/R) | Worldsheet topology |
| CFT | Conformal symmetry | Operator algebra |
| Quantum Computing | Gate/inverse pairing | Circuit DAGs |
| Signal Processing | Frequency inversion | Signal flow graphs |
| Network Science | — | Causal inference DAGs |
| Machine Learning | Dual parametrization | Computation graphs |
| Cosmology | — | Causal structure |
| Thermodynamics | — | Equilibrium fixed points |
| Cryptography | AES S-box inversion | — |
