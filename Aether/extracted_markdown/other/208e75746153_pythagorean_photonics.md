# Pythagorean Photonics: Integer Geometry, Light Propagation, and the Case for Discrete Spacetime

**A Speculative Research Paper**

---

**Authors**: Pythagorean Photonics Research Collective  
**Date**: 2025  
**Status**: Theoretical/Speculative — Not Peer-Reviewed  
**Keywords**: Pythagorean triplets, discrete spacetime, lattice field theory, Lorentz invariance, quantum gravity, Planck scale

---

## Abstract

We investigate the logical and physical implications of a simple but provocative premise: that the propagation of light is fundamentally governed by Pythagorean triplet geometry. We show that this premise leads, by strict logical deduction, to the conclusion that spacetime must be discrete (quantized) and must possess an absolute coordinate structure. We develop a computational framework for simulating light propagation on Pythagorean lattices in 2D and 3D, analyze the resulting anisotropy of the speed of light, derive modified dispersion relations, and compare all predictions against current experimental bounds from Michelson-Morley experiments, gamma-ray burst observations, and precision atomic spectroscopy. We find that while a simple cubic lattice at the Planck scale is ruled out by existing data, stochastic lattice models and sub-Planckian lattice spacings remain viable. We discuss connections to causal set theory, loop quantum gravity, and digital physics, and propose specific experimental tests that could constrain or validate the hypothesis.

---

## 1. Introduction

The relationship between the Pythagorean theorem and the propagation of light is more than a mathematical coincidence — it is a structural feature of relativistic geometry. In special relativity, the null-cone condition for light propagation in flat spacetime reads:

$$c^2 dt^2 = dx^2 + dy^2 + dz^2$$

This is, quite literally, the Pythagorean theorem applied to spacetime intervals. The spatial displacement of a light ray and its temporal displacement are related as the legs and hypotenuse of a right triangle.

In standard physics, the differentials dx, dy, dz, dt are continuous — they can take any real value. But what if they couldn't? What if, at some fundamental scale, these displacements were constrained to be *integers* (in appropriate units)? Then the null condition would demand:

$$a^2 + b^2 + c^2 = d^2, \quad a, b, c, d \in \mathbb{Z}$$

This is a Pythagorean quadruple — an integer solution to the 3D Pythagorean equation. The existence of such integer constraints would have radical implications for the structure of spacetime itself.

In this paper, we trace the logical consequences of this "Pythagorean light hypothesis" to their conclusions, build computational models to explore them, and confront them with experimental reality.

### 1.1 Outline

- **Section 2**: The logical chain from Pythagorean light to quantized spacetime
- **Section 3**: Mathematical properties of Pythagorean lattices
- **Section 4**: Computational simulations (light propagation, anisotropy, dispersion)
- **Section 5**: Confrontation with experimental bounds
- **Section 6**: Connections to existing quantum gravity programs
- **Section 7**: Discussion and future directions

---

## 2. The Logical Argument

### 2.1 Premises and Deductions

**Premise (P1):** The geometry of light propagation is governed by Pythagorean triplet (or quadruple) relationships — that is, the spatial and temporal displacements of light are integers in some fundamental unit system.

**Deduction 1 (D1):** If displacements are integers, there exists a fundamental length scale λ₀ such that all physical lengths are integer multiples of λ₀. This is the definition of a *quantized* or *discrete* space.

**Deduction 2 (D2):** A set of positions of the form {nλ₀ : n ∈ ℤ} in each spatial dimension forms a *lattice*. A lattice is a regular discrete structure with:
  - (a) A fixed set of lattice vectors defining the geometry
  - (b) Preferred directions (the lattice axes)
  - (c) A natural labeling of positions by integer coordinates

**Deduction 3 (D3):** The integer labeling constitutes an *absolute coordinate system* — each lattice point has a unique address independent of any observer. The preferred lattice directions define an *absolute frame*.

**Conclusion:** If light propagation obeys Pythagorean geometry (P1), then space is quantized (D1) and possesses absolute coordinates (D3). QED.

### 2.2 Strength and Limitations

The argument is *deductively valid*: given P1, the conclusions follow necessarily. The physical question is whether P1 is *true*. We cannot currently confirm or deny P1 directly, but we can:

1. Identify observable consequences of the conclusions
2. Test those consequences against experiment
3. Constrain the parameter space of viable models

### 2.3 Comparison with Known Physics

The conclusions stand in tension with two pillars of modern physics:

- **Special Relativity**: There is no preferred frame; all inertial observers are equivalent (Lorentz invariance).
- **General Relativity**: Space is a smooth manifold; coordinates are gauge-dependent, not absolute.

However, these are *classical* theories. Quantum gravity may require their modification at the Planck scale (~10⁻³⁵ m). Several active research programs (loop quantum gravity, causal set theory) already contemplate discrete spacetime.

---

## 3. Mathematical Properties of Pythagorean Lattices

### 3.1 Pythagorean Triplets in 2D

A Pythagorean triplet (a, b, c) satisfies a² + b² = c² with a, b, c ∈ ℤ⁺. The complete set of primitive triplets is generated by Euclid's formula:

$$a = m^2 - n^2, \quad b = 2mn, \quad c = m^2 + n^2$$

where m > n > 0, gcd(m,n) = 1, and m - n is odd.

**Density**: The number of primitive triplets with hypotenuse c ≤ N scales as N/(2π). Our computational experiments confirm this (see Demo 1):

| N | Primitive triplets | N/(2π) | Ratio |
|---|-------------------|---------|-------|
| 100 | 16 | 15.9 | 1.01 |
| 1000 | 158 | 159.2 | 0.99 |
| 5000 | 792 | 795.8 | 1.00 |

**Angular coverage**: For a fixed maximum hypotenuse c_max, the set of achievable angles θ = arctan(a/b) covers only a finite subset of [0°, 90°]. For c_max = 100, only 30 out of 90 one-degree bins are occupied. However, as c_max → ∞, the Pythagorean angles become *dense* in [0°, 90°].

### 3.2 Pythagorean Quadruples in 3D

In three dimensions, we require a² + b² + c² = d². These "Pythagorean quadruples" are far more numerous:

- Every positive integer participates in some quadruple
- The number of quadruples with d ≤ N grows as ~N²
- Angular coverage on the unit sphere approaches 100% rapidly

Our simulations (Demo 4) show that for d ≤ 30, the 5°×5° angular bins on the sphere are >70% occupied, rising to near-complete coverage for d ≤ 100.

**Key result**: The 3D Pythagorean lattice recovers approximate isotropy far more efficiently than the 2D case. This is favorable for the hypothesis, as it reduces the predicted anisotropy.

### 3.3 The Pythagorean Graph

We define the *Pythagorean graph* G_P on the integer lattice ℤ³:
- Vertices: all lattice points (x, y, z) ∈ ℤ³
- Edges: (x₁, y₁, z₁) ~ (x₂, y₂, z₂) iff ||(x₁-x₂, y₁-y₂, z₁-z₂)|| ∈ ℤ

This graph represents all possible "Pythagorean hops" for a photon on the lattice. Light propagation becomes a path-finding problem on G_P.

Properties of G_P:
- Infinite vertex degree (each point has infinitely many Pythagorean neighbors)
- Connected (any two lattice points can be reached via Pythagorean hops)
- Translation-invariant (but NOT rotation-invariant)

---

## 4. Computational Experiments

### 4.1 Light Propagation Simulation (Demo 2)

We simulate a photon on a 2D Pythagorean lattice, constrained to hop only to lattice points at integer distances. At each step, the photon chooses the available neighbor closest to its intended direction of travel.

**Results**:
- Along lattice axes (0°, 90°): photons propagate efficiently (c_eff ≈ 1)
- Along the 3-4-5 angle (36.87°): efficient propagation via (3,4) hops
- Along non-Pythagorean angles (e.g., 30°): zig-zag paths, reduced efficiency
- Maximum anisotropy on a coarse lattice: ~5-15%

### 4.2 Modified Dispersion Relations (Demo 3)

On a lattice with spacing a, the dispersion relation for a massless particle becomes:

$$E^2 = \frac{4}{a^2} \sin^2\left(\frac{pa}{2}\right)$$

instead of the continuum E = p. Key features:
- At low momentum (p ≪ 1/a): E ≈ p (indistinguishable from continuum)
- At p = π/a (Brillouin zone boundary): E saturates at 2/a
- Group velocity v_g = dE/dp → 0 at the zone boundary

For a Planck-scale lattice (a = ℓ_P ≈ 1.6 × 10⁻³⁵ m):
- Deviation at TeV energies: < 10⁻³⁰ (undetectable)
- Deviation at GZK cosmic ray energies: ~ 10⁻¹⁴ (extremely small)
- Only significant at E ~ E_Planck ≈ 10¹⁹ GeV

### 4.3 Anisotropy Quantification (Demo 2 & 5)

The fractional anisotropy of light speed on a cubic lattice scales as:

$$\frac{\Delta c}{c} \sim \left(\frac{a}{\lambda}\right)^2$$

where λ is the observation wavelength. For visible light (λ = 500 nm):

| Lattice spacing | Δc/c |
|----------------|------|
| 1 m | ~4 × 10⁻¹⁴ |
| 1 mm | ~4 × 10⁻⁸ |
| Planck length | ~10⁻⁵⁷ |
| 10⁻⁹ × Planck | ~10⁻⁷⁵ |

---

## 5. Confrontation with Experiment

### 5.1 Michelson-Morley Bounds

Modern versions of the Michelson-Morley experiment constrain the anisotropy of light speed to:

$$\frac{\Delta c}{c} < 10^{-18}$$

For our model (Δc/c ~ (a/λ)²), this requires:

$$a < \lambda \times 10^{-9} \approx 5 \times 10^{-16} \text{ m}$$

This is 10¹⁹ times *smaller* than the Planck length. **A simple cubic lattice at the Planck scale is ruled out.**

### 5.2 Gamma-Ray Burst Constraints

The Fermi Large Area Telescope (LAT) observed GRB 090510, setting a bound on energy-dependent photon speed:

$$E_{QG} > 1.2 \times E_{Planck}$$

for linear modifications. This means any lattice-induced dispersion must be suppressed beyond the Planck energy — again ruling out a simple Planck-scale lattice.

### 5.3 Hughes-Drever Experiments

Precision atomic spectroscopy constrains violations of local Lorentz invariance to:

$$\delta < 10^{-33} \text{ GeV}$$

These are the most stringent tests of spatial isotropy and strongly constrain any lattice model with preferred directions.

### 5.4 Summary of Experimental Status

| Prediction | Experimental Bound | Simple lattice at ℓ_P | Status |
|-----------|-------------------|----------------------|--------|
| Speed anisotropy | Δc/c < 10⁻¹⁸ | Δc/c ~ 10⁻⁵⁷ | Compatible (far below bound) |
| Dispersion modification | E_QG > 1.2 E_P | E_QG = E_P | Marginally excluded |
| Frame isotropy | δ < 10⁻³³ GeV | Lattice breaks isotropy | Potentially excluded |

**Verdict**: A Planck-scale cubic lattice is compatible with Michelson-Morley but is in tension with gamma-ray and spectroscopic data unless the lattice symmetry is higher than cubic.

---

## 6. Connections to Existing Programs

### 6.1 Causal Set Theory

Causal set theory (Bombelli, Lee, Meyer, Sorkin, 1987) posits that spacetime is fundamentally a discrete partial order — a set of events with causal relations. Our Pythagorean lattice is a *regular* causal set. The key insight from causal set theory is that **random** discrete structures can maintain statistical Lorentz invariance, avoiding the anisotropy problem. A "randomized Pythagorean lattice" — where points are randomly sprinkled but connections obey integer distance constraints — could be a viable hybrid model.

### 6.2 Loop Quantum Gravity

Loop quantum gravity (LQG) predicts discrete spectra for area and volume operators, with minimum values of order ℓ_P². Our Pythagorean lattice is consistent with this prediction — on a lattice with spacing ℓ_P, the minimum area is ℓ_P² and the minimum volume is ℓ_P³. However, LQG does NOT require a fixed background lattice; its discreteness is dynamical and background-independent.

### 6.3 Digital Physics

The Pythagorean lattice hypothesis is most naturally aligned with "digital physics" (Zuse, 1969; Fredkin, 1990; Wolfram, 2002) — the idea that the universe is a computational process on a discrete substrate. In this view, the integer constraints on light propagation reflect the *finite precision arithmetic* of the underlying computation. Our contribution is to make this precise: the arithmetic must satisfy Pythagorean constraints.

### 6.4 Information-Theoretic Approaches

The integer constraint on distances can be interpreted as a *finite information content* per spacetime region. If each Planck cell carries log₂(N) bits for N distinguishable states, then distances computed from cell data are necessarily rational (and, for geometric purposes, must satisfy integer relations). This connects to Bekenstein's bound and the holographic principle.

---

## 7. Discussion

### 7.1 What We Have Shown

1. The logical chain from "Pythagorean light" to "quantized spacetime with absolute coordinates" is *deductively valid*.
2. A 3D Pythagorean lattice recovers approximate isotropy more efficiently than a 2D one.
3. Modified dispersion relations on a lattice are exponentially suppressed at energies below the Planck scale.
4. A simple cubic lattice at the Planck scale is in tension with some experimental bounds but compatible with others.
5. Stochastic lattice models and sub-Planckian spacings remain viable.

### 7.2 What We Have NOT Shown

1. That P1 (Pythagorean light) is *true* — this remains a speculative premise.
2. That our model is consistent with general relativity in the classical limit.
3. That the lattice model can reproduce quantum field theory on curved spacetime.
4. That the absolute coordinates implied by the lattice are physically meaningful (vs. gauge artifacts).

### 7.3 Open Questions

1. Can a Pythagorean lattice support fermion propagation without the doubling problem?
2. What is the continuum limit of the Pythagorean graph Laplacian?
3. Does the Pythagorean lattice have any special algebraic properties (e.g., related to Gaussian integers)?
4. Can the model be embedded in a background-independent framework?

### 7.4 Proposed Experimental Tests

1. **High-energy gamma-ray timing**: Search for energy-dependent arrival times from distant blazars at sub-Planck sensitivity.
2. **CMB polarization analysis**: Look for subtle preferred-direction signatures in B-mode polarization patterns.
3. **Gravitational wave spectroscopy**: Search for discrete corrections to black hole quasi-normal mode frequencies.
4. **Precision quantum optics**: Test the generalized uncertainty principle with squeezed light states.

---

## 8. Conclusion

The Pythagorean light hypothesis, while speculative, serves as a powerful *gedanken* framework for exploring the implications of discrete spacetime. The connection between Pythagorean geometry and light propagation is not merely analogical — it is structural, rooted in the null-cone condition of special relativity. If we take this connection seriously and demand integer constraints, we are led inescapably to a quantized spacetime with absolute structure.

Whether nature actually implements this structure is an empirical question. Current experiments neither confirm nor definitively rule out all versions of the hypothesis. The most restrictive version (cubic lattice at Planck scale) is in tension with data, but more sophisticated variants (stochastic lattices, sub-Planckian spacing, higher symmetry) remain viable and interesting.

We hope this work stimulates further investigation at the intersection of number theory, discrete geometry, and fundamental physics. The integers have always been fundamental to mathematics; perhaps they are fundamental to physics as well.

---

## References

1. Bombelli, L., Lee, J., Meyer, D., & Sorkin, R. (1987). Space-time as a causal set. *Physical Review Letters*, 59(5), 521.
2. Rovelli, C. (2004). *Quantum Gravity*. Cambridge University Press.
3. Wilson, K. (1974). Confinement of quarks. *Physical Review D*, 10(8), 2445.
4. Wolfram, S. (2002). *A New Kind of Science*. Wolfram Media.
5. Mattingly, D. (2005). Modern tests of Lorentz invariance. *Living Reviews in Relativity*, 8(1), 5.
6. Hagar, A. (2014). *Discrete or Continuous? The Quest for Fundamental Length in Modern Physics*. Cambridge University Press.
7. Amelino-Camelia, G. (2013). Quantum-spacetime phenomenology. *Living Reviews in Relativity*, 16(1), 5.
8. Abdo, A. A., et al. (2009). A limit on the variation of the speed of light arising from quantum gravity effects. *Nature*, 462, 331-334.

---

## Appendix A: Computational Code

All computational experiments are available in the `demos/` directory:
- `demo1_pythagorean_triplets.py` — Triplet generation and lattice visualization
- `demo2_lattice_light_propagation.py` — Light propagation simulation
- `demo3_dispersion_relation.py` — Modified dispersion relations
- `demo4_quantized_spacetime.py` — 3D lattice analysis
- `demo5_experimental_bounds.py` — Experimental comparison

## Appendix B: Visual Materials

SVG visualizations are in the `visuals/` directory:
- `concept_diagram.svg` — Logical chain overview
- `lattice_3d_concept.svg` — 3D lattice with Pythagorean light path
- `pythagorean_lattice.svg` — 2D Pythagorean lattice points (generated)
- `lattice_propagation.svg` — Light propagation paths (generated)
- `dispersion_relation.svg` — Dispersion relation comparison (generated)
- `experimental_bounds.svg` — Predictions vs experimental bounds (generated)
