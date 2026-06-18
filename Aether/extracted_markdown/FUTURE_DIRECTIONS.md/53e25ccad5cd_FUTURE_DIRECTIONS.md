# Future Directions

## Synthesis

The verified Kepler orbit formalization establishes a complete algebraic pipeline: effective potential analysis → Binet linearization → conic section classification. This opens five concrete research directions, ranging from direct extensions (formalizing the Laplace-Runge-Lenz vector and Kepler's three laws) to paradigm-shifting conjectures (tropical Kepler orbits and formal symplectic reduction). Each direction builds on the certified orbit equation and eccentricity-energy relation as foundations, extending the reach of formal verification into dynamical systems, representation theory, and tropical geometry.

---

## Direction 1: Laplace-Runge-Lenz Conservation

**Conjecture**: The Laplace-Runge-Lenz vector A = p × L − mkr̂ is conserved along Kepler trajectories, i.e., dA/dt = 0. Furthermore, |A| = mke, where e is the orbital eccentricity, and A points toward periapsis.

**Test**: Numerically integrate 1000 random Kepler orbits with varying (E, l). Compute |A(t) − A(0)|/|A(0)| at 100 points along each orbit. Verify conservation to machine precision (< 1e-10). Separately verify |A| = mke and that A/|A| aligns with the periapsis direction vector.

**Impact**: Formalizing LRL conservation would complete the algebraic structure of the Kepler problem and open the door to the SO(4) representation theory of bound orbits. This is the missing piece connecting classical orbital mechanics to quantum hydrogen spectroscopy.

**Catalog References**: `Pythagorean/KeplerDefs.lean` (eccentricity definition), `Pythagorean/OrbitClassification.lean` (eccentricity-energy relation).

**Proof Strategy**: Define A as a function of position and momentum vectors. Compute dA/dt using the product rule and Newton's second law F = −k r̂/r². The key cancellation involves the BAC-CAB identity for triple cross products. Decompose into 3-5 lemmas: (1) time derivative of p × L, (2) time derivative of r̂, (3) cancellation, (4) magnitude computation, (5) direction computation.

**Domain Bridges**: Classical Mechanics ↔ Representation Theory (SO(4) structure), Classical Mechanics ↔ Quantum Mechanics (hydrogen atom degeneracy).

**Lineage**: Direct extension of eccentricity_energy_relation and orbit_type_by_energy.

**Ambition**: High — this is a well-understood result but formalizing vector calculus identities in Lean 4 requires building infrastructure.

---

## Direction 2: Formal Kepler's Three Laws

**Conjecture**: From the verified orbit equation r(θ) = p/(1 + e cos θ), derive all three of Kepler's laws:
1. (Law of Orbits) Bound trajectories are ellipses with the force center at one focus.
2. (Law of Areas) The radius vector sweeps equal areas in equal times: dA/dt = l/(2m) = const.
3. (Law of Periods) T² = (4π²m/k) a³, where a is the semi-major axis.

**Test**: For 100 random (m, k, E, l) with E < 0, compute: (a) the area swept over equal time intervals (verify constant to 1e-10), (b) the period from numerical integration vs. the formula T = 2π√(a³m/k) (verify agreement to 1e-8), (c) verify ellipse geometry (sum of distances to foci = 2a).

**Impact**: Kepler's laws are foundational results taught in every physics course. A complete formal verification would be a landmark in formal mathematics, demonstrating that 17th-century physics can be made fully rigorous.

**Catalog References**: `Pythagorean/BinetOrbit.lean` (orbit equation), `Pythagorean/KeplerDefs.lean` (orbital period definition).

**Proof Strategy**: Law 2 follows directly from angular momentum conservation: dA/dt = ½r²dθ/dt = l/(2m). Law 1 is our verified orbit equation. Law 3 requires computing the area of the ellipse A = πab = πa²√(1−e²) and using dA/dt = l/(2m) to get T = A/(l/(2m)), then substituting a = p/(1−e²) and p = l²/(mk).

**Domain Bridges**: Geometry ↔ Dynamics (ellipse area as time integral), Number Theory ↔ Celestial Mechanics (commensurability of periods).

**Lineage**: Builds on kepler_orbit_radius_pos, semiLatusRectum_pos, eccentricity_energy_relation.

**Ambition**: Medium — mathematically straightforward but requires formalizing ellipse area and integration.

---

## Direction 3: Tropical Kepler Orbits (Grand Challenge)

**Conjecture**: The tropicalization of the Kepler orbit equation r(θ) = p/(1 + e cos θ) under the valuation v(x) = −log_t(|x|) as t → ∞ yields piecewise-linear orbits in the (log r, θ)-plane:
1. For E < 0 (elliptical): the tropical orbit is a tropical ellipse with exactly 6 vertices.
2. The tropical eccentricity is e_⊕ = max(0, v(1−e²)/2).
3. The tropical orbit equation is a piecewise-linear curve r_⊕(θ) = min(p_⊕, e_⊕ + |θ|_⊕).

**Test**: Compute tropical orbits for 100 random (E, l) pairs with E < 0. Verify vertex count (6 for ellipse, 4 for parabola, 2 for hyperbola). Compare tropical orbit with direct tropicalization of the Cartesian conic equation (1−e²)x² + 2epx + y² = e²p². Verify convergence rate of classical orbit to tropical limit.

**Impact**: This would establish the first connection between tropical geometry and celestial mechanics, potentially opening new computational methods for orbit determination using tropical algebra (which replaces floating-point arithmetic with exact piecewise-linear computation).

**Catalog References**: `Pythagorean/BinetOrbit.lean` (orbit equation), `Pythagorean/OrbitClassification.lean` (orbit type classification).

**Proof Strategy**: Define the tropical valuation on the orbit equation. Use the fundamental theorem of tropical algebraic geometry: tropical varieties are limits of amoebas. Compute the Newton polygon of the conic equation and derive the dual tropical curve. Verify vertex structure by examining the tropical polynomial's corner locus.

**Domain Bridges**: Tropical Geometry ↔ Celestial Mechanics (orbit tropicalization), Algebraic Geometry ↔ Dynamical Systems (Newton polygon as phase portrait).

**Lineage**: Extension of kepler_orbit_is_conic into tropical algebraic geometry.

**Ambition**: Very High — this is a novel conjecture combining two fields that have not been previously connected.

---

## Direction 4: Formal Marsden-Weinstein Reduction Theorem (Grand Challenge)

**Conjecture**: For any Hamiltonian system on a symplectic manifold (M, ω) with a Hamiltonian G-action and equivariant momentum map μ : M → g*, if μ_val is a regular value and G acts freely on μ⁻¹(μ_val), then the reduced space M_red = μ⁻¹(μ_val)/G carries a unique symplectic form ω_red such that π*ω_red = ι*ω, and the reduced Hamiltonian flow on M_red projects the original flow.

**Test**: Verify the reduction for three concrete examples: (1) the Kepler problem (our main result), (2) the rigid body (SO(3) action on T*SO(3)), (3) the spherical pendulum (S¹ action on T*S²). For each, compare reduced trajectories with projected original trajectories for 100 initial conditions.

**Impact**: A formal Marsden-Weinstein theorem would be a foundational result in formal symplectic geometry, enabling verified reduction of any Hamiltonian system with symmetry. This would be the formal mathematics equivalent of a compiler: transforming high-dimensional problems into lower-dimensional ones with guaranteed correctness.

**Catalog References**: `Pythagorean/KeplerDefs.lean` (MarsdenWeinsteinReduction structure), `Pythagorean/EffectivePotential.lean` (concrete reduction output).

**Proof Strategy**: Build the necessary symplectic geometry infrastructure: symplectic forms, Hamiltonian vector fields, momentum maps. Formalize the regular value theorem (implicit function theorem), free group actions, and quotient manifolds. The Marsden-Weinstein theorem then follows from the non-degeneracy of the reduced 2-form, proved via the rank-nullity theorem applied to ker(ω) ∩ T(μ⁻¹(μ_val)).

**Domain Bridges**: Symplectic Geometry ↔ Algebra (group actions, quotient spaces), Differential Geometry ↔ Physics (phase space reduction).

**Lineage**: Extends MarsdenWeinsteinReduction structure from a data type to a theorem.

**Ambition**: Very High — requires building substantial symplectic geometry infrastructure not currently in Mathlib.

---

## Direction 5: Perihelion Precession from Perturbation Theory

**Conjecture**: Adding a 1/r³ perturbation to the Kepler potential (modeling general relativistic corrections or oblateness), the orbit equation becomes r(θ) = p/(1 + e cos((1−δ)θ)) to first order in δ, where δ = 3GM/(c²p) for GR or δ = J₂R²/p² for oblateness. The perihelion advances by Δφ = 2πδ/(1−δ) ≈ 2πδ per orbit.

**Test**: Numerically integrate the perturbed Kepler problem for Mercury's parameters with the GR correction. Verify that the computed perihelion precession matches 42.98 arcseconds/century to within 0.1%. Compare with the first-order formula.

**Impact**: Einstein's prediction of Mercury's perihelion precession was one of the three classical tests of general relativity. A formal verification of this prediction — starting from the perturbed Kepler problem and arriving at the 43"/century figure — would connect formal mathematics to one of the most celebrated results in physics.

**Catalog References**: `Pythagorean/BinetOrbit.lean` (Binet equation), `Pythagorean/EffectivePotential.lean` (effective potential).

**Proof Strategy**: Add the perturbation term −α/r³ to the effective potential. The modified Binet equation is u'' + (1−ε)u = mk/l² where ε = 2mα/l². Solve by the method of variation of parameters to first order in ε. Compute the phase shift per orbit.

**Domain Bridges**: Classical Mechanics ↔ General Relativity (Schwarzschild geodesics), Perturbation Theory ↔ Formal Verification (certified error bounds).

**Lineage**: Direct perturbation of binet_solution_satisfies_equation.

**Ambition**: High — requires formalizing perturbation theory for ODEs, but the underlying mathematics is well-understood.
