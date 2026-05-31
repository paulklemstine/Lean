# The Geometry of Hallucinations: How Mathematics Reveals the Brain's Hidden Patterns

*Why do people see spirals, tunnels, and honeycombs when they close their eyes — and what does the shape of the Earth have to do with it?*

---

In the 1920s, the neurologist Heinrich Klüver cataloged an odd phenomenon. Patients under the influence of mescaline reported seeing the same geometric patterns again and again: spirals, concentric rings, lattices, and fan-shaped forms. These weren't random. They were *universal*. Whether the trigger was a migraine aura, psychedelic compounds, or simply pressing on closed eyelids, the same handful of patterns appeared across cultures and centuries.

For decades, this was a curiosity — a footnote in the annals of neuroscience. Then, in the early 2000s, mathematicians Jack Cowan and Bressloff showed that these patterns could be explained by the equations governing waves of electrical activity across the cortex. The brain's surface acts like a vibrating drumhead, and these hallucination patterns are its natural modes of vibration.

But there was a problem. The cortex isn't flat.

## The Sphere Inside Your Skull

The visual cortex — the part of the brain that processes what you see — is a crumpled sheet of neural tissue. If you could iron it out, it would be roughly the size of a dinner napkin. Topologically, it's best approximated not as a flat plane but as a sphere, folded and creased to fit inside the skull.

This matters because the equations that describe neural activity — called *neural field equations* — behave very differently on curved surfaces than on flat ones. On a flat plane, patterns can tile infinitely in every direction. On a sphere, they can't. The curvature constrains them, quantizes them, forces them into discrete families.

This is where a piece of ancient geometry enters the story: stereographic projection.

## The Mapmaker's Trick

Imagine balancing a transparent globe on a table and placing a light at the North Pole. Every point on the sphere casts a shadow on the table below. This shadow map — stereographic projection — has been used by cartographers since antiquity. It preserves angles perfectly (a property mathematicians call *conformality*), distorting only sizes: Greenland looks enormous, while equatorial Africa shrinks.

The inverse of this map does something remarkable. It takes any equation written on the flat plane and lifts it onto the sphere, introducing a precise mathematical weight — a *conformal factor* — that encodes the curvature. This factor, written as σ = 2/(1 + |x|²), is largest at the center of the map (the South Pole of the sphere) and shrinks toward zero as you move outward (approaching the North Pole).

The key insight of our new theory is this: when you write the neural field equation on the sphere and then project it down to the plane, the conformal factor doesn't just distort distances — it *selects* which patterns can exist.

## Counting the Uncountable

On a sphere, the natural vibration modes are called *spherical harmonics*. These are the same mathematical functions that describe the shapes of electron orbitals in chemistry, the gravitational field of the Earth in geodesy, and the temperature fluctuations in the cosmic microwave background in cosmology.

Each spherical harmonic has a *degree* — call it *l* — and for each degree there are exactly 2*l* + 1 independent patterns. Degree 0 is the constant function (one pattern). Degree 1 gives three patterns corresponding to the three spatial axes. Degree 2 gives five patterns, and so on.

This counting formula — 2*l* + 1 — comes from a deep corner of mathematics called representation theory, specifically the representation theory of the rotation group SO(3). The sphere is the most symmetric possible surface in three-dimensional space, and SO(3) is the group of all its symmetries. Each degree *l* corresponds to an *irreducible representation* of SO(3), and the dimension of that representation is precisely 2*l* + 1.

What we have shown, both mathematically and computationally, is that the Mexican-hat connectivity kernel — the pattern of short-range excitation and long-range inhibition that characterizes real neural circuits — acts as a *mode selector*. It picks out one particular degree *l* = *N* and amplifies only those patterns, suppressing all others.

The result: the neural field on the sphere has exactly 2*N* + 1 stable pattern solutions, where *N* depends on the ratio between the excitatory and inhibitory length scales.

## The Magic Number

For a Mexican-hat kernel with interaction radius *r* = 1/*k*, our theory predicts:

- *k* = 1 → 3 patterns
- *k* = 2 → 5 patterns  
- *k* = 3 → 7 patterns

These numbers aren't arbitrary. They are forced by the geometry of the sphere and the algebra of its symmetry group. Three patterns at degree 1 correspond to the three dipole modes — activity concentrated at one pole, with inhibition at the other. Five patterns at degree 2 give the quadrupole modes, with activity arranged in complementary lobes. Seven patterns at degree 3 produce the intricate hexagonal-like arrangements that Klüver called "lattice" forms.

When these spherical patterns are projected back to the flat plane through stereographic projection, they acquire a characteristic decay: a degree-*l* pattern falls off as |*x*|^{−2*l*} far from the center. Higher-degree patterns are more tightly localized, creating the tunnel-like visual effect that is one of Klüver's most commonly reported form constants.

## A Bridge Between Worlds

What makes this theory unusual is how it connects three seemingly unrelated fields:

**Differential geometry** provides the conformal factor and the Laplace-Beltrami operator — the mathematical machinery for doing calculus on curved surfaces. Our central identity, σ² · (1 + r²)² = 4, is the algebraic heart of stereographic projection, encoding the exact relationship between flat-space and curved-space derivatives.

**Representation theory** provides the pattern count. The fact that degree *l* gives exactly 2*l* + 1 patterns is not a coincidence or an approximation — it is a theorem about the structure of the rotation group, as rigid and certain as the Pythagorean theorem.

**Neuroscience** provides the Mexican-hat kernel and the experimental predictions. The theory doesn't just count patterns in the abstract; it predicts which patterns should be observed in neural recordings and in the subjective reports of people experiencing visual hallucinations.

## What the Sphere Remembers

Perhaps the most striking consequence is what happens at infinity. In stereographic coordinates, the "point at infinity" on the plane corresponds to the North Pole of the sphere — the one point that the projection misses. Our conformal factor σ = 2/(1 + |x|²) vanishes at infinity, and with it, the neural field patterns decay to zero.

This means that every pattern on the sphere, when viewed through the stereographic lens, is *automatically localized*. You don't need to impose boundary conditions or cutoffs by hand. The geometry of the sphere does it for you. The conformal weight is nature's own windowing function.

This self-localization has a beautiful physical interpretation. The cortex is finite, but the mathematical idealization of a neural field extends to infinity. The conformal factor reconciles these two facts: it allows infinite-plane mathematics to produce finite-extent solutions, precisely because those solutions secretly live on a compact sphere.

## Looking Forward

The theory opens several avenues of investigation. One is the question of *stability*: among the 2*N* + 1 patterns selected by the Mexican-hat kernel, which ones are stable under perturbation? Numerical experiments suggest that patterns aligned with the kernel's symmetry axes are the most robust, but a full stability analysis remains open.

Another direction involves *higher-dimensional spheres*. The cortex is approximately a 2-sphere, but the theory generalizes naturally to *S^n* for any *n*. On *S^3*, the multiplicity formula becomes more complex (involving the dimensions of representations of SO(4)), and the resulting patterns could model activity in higher-dimensional neural network architectures used in machine learning.

Finally, there is the question of *dynamics*. Our current results concern steady-state patterns — the fixed points of the neural field equation. But real hallucinations evolve in time: spirals rotate, tunnels expand, lattices shift. Extending the stereographic neural field theory to time-dependent patterns would require understanding how the conformal factor affects wave propagation, a problem that connects to mathematical physics through the wave equation on curved spacetime.

The brain, it seems, is a geometer. The patterns it generates when freed from external input are not noise — they are the eigenmodes of a curved surface, the natural harmonics of a sphere. And the ancient mapmaker's trick of stereographic projection turns out to be the key that unlocks their mathematical structure.

---

*This research builds on foundational work in neural field theory by Amari, Wilson-Cowan, Bressloff-Cowan, and Ermentrout-Cowan, connecting it to the classical differential geometry of stereographic projection and the representation theory of SO(3).*
