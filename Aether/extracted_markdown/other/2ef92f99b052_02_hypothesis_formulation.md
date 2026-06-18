# Hypothesis Formulation

## The Logical Chain

### Premise (P1)
**Light propagation in spacetime is fundamentally described by Pythagorean relations**: the spatial and temporal components of a photon's worldline satisfy $\Delta x^2 + \Delta y^2 + \Delta z^2 = (c \Delta t)^2$ with all quantities being integer multiples of a fundamental unit.

### Deduction 1 (D1): Quantized Distances
If $\Delta x, \Delta y, \Delta z, c\Delta t$ are all integers (in fundamental units), then:
- Space is a lattice $\mathbb{Z}^3$ with spacing $a$ (the Planck length or similar)
- Time is discrete with tick $\tau = a/c$
- Light paths are integer vectors $(n_x, n_y, n_z)$ satisfying $n_x^2 + n_y^2 + n_z^2 = n_t^2$

### Deduction 2 (D2): Quantized Spacetime
- There exists a minimal length $a > 0$ below which spatial distinctions are meaningless
- There exists a minimal time $\tau > 0$ below which temporal distinctions are meaningless
- The spacetime manifold is replaced by the lattice $\mathbb{Z}^{3,1}$

### Deduction 3 (D3): Absolute Coordinates
- The lattice $\mathbb{Z}^3$ defines a preferred reference frame: the rest frame of the lattice
- Lorentz transformations are approximate symmetries, valid at scales $\gg a$
- At the lattice scale, there is a detectable anisotropy and preferred frame

## Three Hypothesis Versions

### Strong Hypothesis
> Spacetime IS the integer lattice $\mathbb{Z}^{3,1}$, and light paths are exactly Pythagorean quadruples. Lorentz invariance is an emergent, approximate symmetry.

**Prediction**: Observable Lorentz violation at energy $E \sim E_P = \sqrt{\hbar c^5/G} \approx 1.2 \times 10^{19}$ GeV.

### Moderate Hypothesis
> Spacetime has a discrete substructure whose symmetry group is $SO(3,1;\mathbb{Z})$ rather than $SO(3,1;\mathbb{R})$. The Pythagorean structure encodes allowed light directions at the fundamental scale, but coarse-graining recovers continuous Lorentz invariance.

**Prediction**: Statistical Lorentz invariance with $O(a/\lambda)$ corrections to photon propagation.

### Weak Hypothesis
> The Pythagorean structure of integer null vectors provides a useful *mathematical model* for studying discrete spacetime, without claiming physical reality. It illuminates the tension between discreteness and Lorentz invariance.

**Prediction**: No direct physical predictions, but mathematical insights applicable to quantum gravity programs.

## Testable Predictions

| Prediction | Strong | Moderate | Weak |
|-----------|--------|----------|------|
| Speed of light anisotropy | $\Delta c/c \sim (a/\lambda)^2$ | $\Delta c/c \sim e^{-\lambda/a}$ | N/A |
| Dispersion relation modification | $E^2 = p^2c^2 + \alpha p^4 a^2 c^2$ | Statistical $O(a^2)$ corrections | N/A |
| Preferred frame effects | Yes, detectable | Exponentially suppressed | N/A |
| Photon direction quantization | Yes, at scale $a$ | No, smeared by coarse-graining | N/A |
| GZK-like cutoff for photons | At $E \sim \hbar c/a$ | Smoothed Brillouin zone | N/A |

## Counterarguments and Responses

### C1: "Lattice breaks Lorentz invariance"
**Response**: Yes — that is the *point*. The question is whether the breaking is observable. At $a = \ell_P$, the fractional anisotropy is $\sim (a/\lambda)^2 \sim 10^{-57}$ for optical light.

### C2: "Causal set theory shows discreteness is compatible with Lorentz invariance"
**Response**: True, via random sprinkling. Our hypothesis uses a *regular* lattice, which is a stronger (and more falsifiable) claim. The causal set approach shows the logical possibility of a middle ground.

### C3: "There are only finitely many Pythagorean directions — light couldn't propagate in most directions"
**Response**: At scale $d$, the fraction of directions accessible via Pythagorean quadruples with hypotenuse $\leq d$ grows. For $d \sim 10^{35}$ (Planck units per meter), angular coverage is essentially complete. We verify this computationally.

## Iteration Log

### v1 (Initial)
- Strong hypothesis stated as conjecture
- No experimental bounds considered

### v2 (Post-computation)
- Added angular coverage analysis showing >70% coverage at $d \leq 30$
- Added dispersion relation calculation

### v3 (Post-experimental confrontation)
- Michelson-Morley compatible at Planck scale ($10^{-57}$ vs $10^{-18}$ bound)
- Fermi-LAT marginal — simple cubic lattice *barely* survives
- Hughes-Drever poses the strongest constraint

### v4 (Final)
- Downgraded "strong" hypothesis to "interesting but likely ruled out"
- "Moderate" hypothesis elevated as most promising
- Connected to existing quantum gravity programs (causal sets, LQG)
