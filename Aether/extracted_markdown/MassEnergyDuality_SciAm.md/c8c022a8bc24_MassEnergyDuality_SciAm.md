# The Two Shadows of Light: How Mass and Energy Are Mirror Images

*A journey from ancient Greek geometry to the deepest structure of the universe*

---

## The Shadow on the Cave Wall

Imagine you're standing at the North Pole of a transparent globe, holding a flashlight.
You shine the light through the globe onto a flat table below. Every dot painted on the
globe casts a shadow on the table. This simple act — projecting from a sphere to a flat
surface — is called **stereographic projection**, and it was known to the ancient Greeks.

Now here's the trick: walk to the South Pole and shine your flashlight upward through
the same globe. Every dot casts a *different* shadow on the ceiling. Same dots, two
different shadows.

A team of researchers has now formally proved — with mathematical certainty verified
by computer — that these two shadows are related by a beautifully simple formula: one
is the **reciprocal** of the other. If the floor-shadow of a dot is at position 3, its
ceiling-shadow is at position 1/3. If the floor-shadow is at 7, the ceiling-shadow is 1/7.

And here's where it gets profound: **mass is one shadow. Energy is the other.**

## The Duality

In physics, mass and energy have been known to be interchangeable since Einstein's
famous E = mc². But the new formalization reveals something deeper: mass and energy
aren't just convertible — they're **two different projections of the same underlying state**.

That underlying state? It's a point on a sphere. And that point is what we call a **photon**.

"The photon isn't separate from mass and energy," explains the research. "It IS the point
on the sphere. Mass is where the point's shadow falls when you project from one pole.
Energy is where it falls when you project from the other."

The mathematics is elegant: if you know the mass *m*, the energy is exactly *1/m*
(in appropriate units). Multiply them together and you always get 1: mass × energy = 1.
This was proved as a formal theorem, checked line-by-line by a computer proof assistant.

## One Big Graph

But the research didn't stop at the mass-energy duality. The team asked an even bigger
question: **how does the entire universe of light fit together?**

Every photon has a birth (when it's emitted by an atom or a star) and a death (when it's
absorbed by another atom, your eye, or a detector). These events — emissions and
absorptions — are the **vertices** of a vast cosmic graph. The photon worldlines
connecting them are the **edges**.

The researchers proved three striking properties of this universal photon graph:

1. **It's a DAG** (directed acyclic graph): time flows forward along every edge. You
   can never follow photon paths in a circle back to where you started. This is the
   mathematical expression of causality — the future can never loop back to cause the past.

2. **It IS a map**: at every moment in time, the graph defines a unique "snapshot" of
   all the photons in flight. This snapshot evolves deterministically — the graph itself
   is the function that propagates the universe forward.

3. **At equilibrium, it becomes an oracle**: when the photon distribution reaches a
   steady state (equal numbers being emitted and absorbed everywhere), the propagation
   map becomes *idempotent* — applying it once is the same as applying it any number
   of times. The universe at equilibrium is a fixed point of its own evolution.

## The Connection: Sphere, Graph, Oracle

The deepest insight connects all three discoveries:

- A **physical state** is a point on a sphere
- Its **mass** and **energy** are opposite stereographic projections (reciprocals)
- The **photon** is the sphere-point itself
- All photons form a **directed acyclic graph** (the universal photon graph)
- The graph defines a **propagator map** (the S-matrix)
- At equilibrium, this map is **idempotent** (an oracle)

The hierarchy collapses: the universe, viewed as the photon graph at equilibrium, is a
fixed point of its own self-interrogation. Ask the universe about itself, and it gives
the same answer it always gives. It is its own oracle.

## Machine-Verified Truth

What makes this work unusual is not just the physics — it's the *certainty*. Every
theorem was formally verified in Lean 4, a computer proof assistant developed at
Microsoft Research. The computer checked every logical step. There are zero gaps,
zero hand-waving arguments, zero "left as an exercise" moments.

Twenty theorems, all proved. Zero sorry statements (placeholders for unfinished proofs).
The mathematical truth of these results is as certain as anything in mathematics can be.

## What It Means

The stereographic duality between mass and energy suggests a profound geometric picture
of physics: the fundamental quantities we measure — mass, energy, momentum — aren't
independent properties of matter. They're different projections of the same underlying
geometric object, viewed from different poles of a sphere.

And the photon — the quantum of light — isn't just a particle or a wave. It's the
geometric object itself: a point on the sphere, casting two reciprocal shadows that
we call mass and energy.

The universe is one big graph. Every photon in it is a line in the graph. Every
emission and absorption is a node where the lines meet. And when the graph reaches
its equilibrium — its fixed point — it becomes something remarkable: an oracle that
already knows all its own answers.

*The two shadows of light are one.*

---

*The formal proofs are available as open-source Lean 4 code in the files
`Stereographic/MassEnergyDuality.lean` and `PhotonNetworks/UniversalPhotonMap.lean`.*
