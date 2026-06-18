# The Geometry of Hallucinations: How a 400-Year-Old Map Explains Patterns in the Brain

## A Projection That Changes Everything

Close your eyes and press gently on your eyelids. You'll likely see shimmering geometric patterns — spirals, lattices, concentric rings. These are not random glitches. They are the brain's visual cortex revealing its own mathematical architecture.

For decades, neuroscientists have known that the visual cortex of mammals is organized as a curved sheet of neural tissue, roughly spherical in its large-scale geometry. When this sheet is perturbed — by pressure, flickering light, or certain pharmacological agents — it spontaneously generates geometric patterns. The mystery has always been: why *these* patterns? Why spirals with a specific number of arms? Why rings with particular spacing? Why do the same motifs appear across species, from cats to humans?

A new mathematical framework offers a surprisingly elegant answer, rooted in a map invented by ancient astronomers and refined by Renaissance cartographers: the stereographic projection.

## From Globe to Flat Map

Imagine trying to draw a perfect map of the Earth on a flat sheet of paper. You can't do it without some distortion — this is a mathematical certainty, proved rigorously in the 19th century. But there is one projection that preserves *angles*: the stereographic projection. Used by Hipparchus around 150 BC and formalized by Ptolemy, it works by placing a light source at the North Pole of a globe and projecting every other point downward onto a flat plane.

The resulting map has a remarkable property: while distances are distorted (Greenland looks enormous), the shape of any small region is preserved perfectly. Mathematicians call this *conformality*. A tiny circle on the globe maps to a tiny circle on the flat map, never an ellipse. This angle-preserving quality made stereographic projection indispensable in navigation, crystallography, and complex analysis.

What no one fully appreciated until recently is that this same geometric trick holds the key to understanding pattern formation in the brain.

## The Cortex as a Sphere

The mammalian visual cortex, when unfolded, resembles a curved sheet — not perfectly spherical, but close enough that a spherical model captures its essential geometry. Neural field theory, developed in the 1970s by Wilson, Cowan, and Amari, describes the cortex as a continuous field of neural activity. Each point on the cortical surface has an activation level, and nearby points influence each other through excitatory and inhibitory connections.

The critical insight is that these interaction patterns have a characteristic spatial scale. Nearby neurons excite each other, while more distant neurons inhibit each other — the so-called "Mexican hat" interaction profile, named for its cross-sectional shape. When the strength of neural interactions crosses a critical threshold, the uniform resting state becomes unstable, and patterns spontaneously emerge.

On a flat sheet, this process is well understood: it produces stripes, hexagons, or other periodic patterns, depending on the interaction radius. But the cortex is not flat. It is curved. And on a sphere, the mathematics changes dramatically.

## Harmonics on the Sphere

On a sphere, the natural building blocks of pattern are not sine waves but *spherical harmonics* — the same mathematical functions that describe the shapes of electron orbitals in atoms, the vibration modes of a bell, and the gravitational field of the Earth.

Spherical harmonics come in families labeled by a degree number ℓ. Degree 0 is a constant (no pattern). Degree 1 has three independent modes — three fundamentally different ways to paint a simple pattern on the sphere. Degree 2 has five modes. Degree 3 has seven. In general, degree ℓ has exactly **2ℓ + 1** independent modes.

This number — 2ℓ + 1 — is not arbitrary. It emerges from the rotational symmetry of the sphere. The sphere looks the same from any angle, and this symmetry, captured mathematically by the rotation group SO(3), forces the space of degree-ℓ patterns to have precisely this dimension. It is a consequence of representation theory, the branch of mathematics that studies how symmetry constrains structure.

## The Bridge: Conformal Transport

Here is where stereographic projection enters the picture. Take a pattern on the sphere — say, a degree-3 spherical harmonic with its characteristic nodal lines dividing the sphere into regions of positive and negative activation. Now project it down to the flat plane through the stereographic map.

The projected pattern is no longer periodic. It decays as you move away from the origin, fading to zero at infinity (which corresponds to the North Pole on the sphere). But it retains a crucial property: it satisfies a weighted version of the wave equation on the plane.

The precise relationship is captured by a conformal transport theorem: if the spherical pattern satisfies the spherical Laplace eigenvalue equation

Δ_{S²} u = −ℓ(ℓ+1) u,

then its planar projection v satisfies the weighted equation

Δ_{ℝ²} v = −4ℓ(ℓ+1) / (1+|x|²)² · v.

The weight factor 4/(1+|x|²)² is exactly the square of the conformal factor of stereographic projection — the same quantity that measures how much distances are distorted by the map.

This equation is a *weighted Schrödinger equation* — the same type of equation that governs quantum particles in a potential well. The conformal potential V(x) = 4ℓ(ℓ+1)/(1+|x|²)² acts like a trapping force, binding the pattern near the origin. Each degree-ℓ mode on the sphere corresponds to a bound state of this potential.

## Counting Patterns

The payoff of this geometric dictionary is a precise prediction: when a neural field on a nearly spherical cortex becomes unstable at interaction radius r, the number of independent patterns that can emerge is **2N + 1**, where N is determined by the interaction radius.

This is not a rough estimate or a numerical observation. It is a mathematical theorem, following from three ingredients:

1. The conformal transport identity, which converts spherical dynamics to weighted planar dynamics.
2. The eigenvalue structure of the spherical Laplacian, which organizes modes by degree.
3. The representation-theoretic dimension formula, which fixes the multiplicity at 2ℓ + 1.

For a Mexican-hat interaction with radius r ≈ 1/k, the dominant mode has degree k, giving 2k+1 independent patterns. When k = 1, there are 3 patterns (simple dipolar activations). When k = 2, there are 5 (quadrupolar patterns). When k = 3, there are 7 (more complex angular patterns with three-fold structure).

## Why Patterns Decay

A key feature of the transported patterns is that they decay at infinity in the planar coordinates. This follows from a topological fact: as you move infinitely far from the origin in the plane, the inverse stereographic projection approaches the North Pole of the sphere. If the spherical pattern vanishes at the North Pole (which is generically true for positive-degree harmonics), then the planar pattern must fade away at large distances.

This decay property is what makes the planar pullbacks physically meaningful as cortical activation patterns. They are not infinite periodic structures but localized, decaying motifs — exactly what is observed in visual hallucination patterns.

## From Ancient Maps to Modern Neuroscience

The story of stereographic projection spans two millennia, from Greek astronomy through Islamic cartography, Renaissance navigation, and modern complex analysis. Its application to neural field theory represents a new chapter in this long history.

What makes this connection powerful is its *exactness*. The conformal transport is not an approximation. It is a precise geometric identity that converts problems on curved surfaces into weighted problems on flat surfaces, preserving all the essential structure. The 2ℓ+1 multiplicity is not a perturbative result but an exact consequence of symmetry.

This framework also connects to other areas of science and mathematics. The weighted Schrödinger equation appears in quantum mechanics. The representation theory of SO(3) underlies atomic physics. The conformal geometry is central to string theory and the AdS/CFT correspondence. The same mathematical structure appears in geometric deep learning, where neural networks on spheres and other manifolds must respect rotational symmetry.

## Looking Forward

Several concrete predictions emerge from this theory, all computationally testable. The mode selection law — that interaction radius r = 1/k selects degree k — can be verified by computing Funk–Hecke eigenvalues for specific kernels. The nodal domain correspondence predicts how the topology of cortical activation regions transforms under stereographic transport. The conformal robustness hypothesis suggests that small deviations from perfect spherical geometry should not change the dominant pattern multiplicity.

Perhaps most intriguingly, the theory predicts that the geometric patterns seen during visual hallucinations should cluster into specific symmetry classes, each corresponding to a particular degree ℓ of spherical harmonics. The spirals, fans, and lattices reported by observers are not random — they are the visible signatures of the brain's spherical geometry, projected into our flat visual field by a mathematical map that Hipparchus might have recognized.

The brain, it seems, is a geometer. And its visual cortex speaks the language of conformal symmetry.
