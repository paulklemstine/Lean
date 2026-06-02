# The Shape That Broke Symmetry: How One Tile Changed Mathematics Forever

## A 50-Year Quest Ends with a Single Shape

For half a century, mathematicians chased a ghost. They knew shapes existed that could tile a flat surface infinitely in every direction—covering it completely, with no gaps and no overlaps—but only in patterns that never repeat. The first examples, discovered by Robert Berger in 1966, required over 20,000 different tile shapes working in concert. Roger Penrose whittled that number down to just two in the 1970s, creating the famous Penrose tilings with their haunting, almost-but-never-quite-repeating patterns. But the deepest question remained stubbornly open: Could a *single* shape do it alone?

In 2023, a retired printing technician named David Smith, working with mathematicians Craig Kaplan, Joseph Myers, and Chaim Goodman-Strauss, answered that question with a resounding yes. Their shape—a deceptively simple 13-sided polygon they called "the hat"—can tile the entire infinite plane, but only in patterns that never repeat. It is an *aperiodic monotile*: one shape, infinitely many tiles, zero periodicity.

The discovery electrified the mathematical world. But as with all great discoveries, it opened more questions than it answered. And the most tantalizing question of all turned out to have a beautiful answer: the hat is not alone.

## Not One Shape, But a Family

The hat tile has 13 edges, but not all edges are equal. It has two distinct edge lengths—call them *a* and *b*. When Smith and his collaborators studied what happens as you change the ratio between these two lengths, they found something remarkable: the hat is not an isolated curiosity. It sits on a *spectrum*.

Imagine a dial that you can turn smoothly from 0 to 1. At position 0, you get the hat. At position 1, you get a different shape called "the turtle." In between, you get a continuously varying family of shapes, each one slightly different from the last. And here's the key discovery: *every single shape in this family tiles the plane aperiodically*—except at exactly one critical point, right in the middle, where the two edge lengths become equal.

At that midpoint, the tile undergoes a phase transition. The two edge lengths coincide, and suddenly the tile *can* tile periodically. It's as if the tile loses its "memory" of which edge is which, and the forced aperiodicity vanishes. Move even slightly away from that critical point in either direction, and aperiodicity returns.

This is the *hat spectrum*: a one-parameter family of aperiodic monotiles, connected by a continuous bridge, separated by a single point of periodicity.

## Why Irrational Numbers Forbid Repetition

What prevents these tiles from forming periodic patterns? The answer lies in a beautiful interplay between geometry and number theory.

Every substitution tiling system has an *expansion factor*—a number that describes how the tiling scales up when you group tiles into larger "supertiles." For the hat family, this expansion factor is 2 + √3, approximately 3.732. This number has a remarkable property: it is *irrational*.

Why does irrationality matter? Imagine you have a periodic tiling—one that repeats in a regular grid pattern. The tiling has a fundamental "period vector" that describes the smallest shift that maps the pattern exactly onto itself. Now apply the substitution: group tiles into supertiles. The period vector gets stretched by the expansion factor. Apply the substitution again, and it stretches again. After *n* applications, the original period has been stretched by (2 + √3)ⁿ.

But here's the catch: in a periodic tiling, all period vectors must lie on a discrete lattice—they must be integer combinations of a fixed set of basis vectors. As you keep stretching by an irrational factor, the stretched periods can't stay on any lattice. They grow without bound, shooting off to infinity, eventually becoming too large to be periods of any finite-area fundamental domain. This contradiction proves that no periodic tiling is possible.

The expansion factor 2 + √3 satisfies a beautiful algebraic equation: λ² − 4λ + 1 = 0. Its conjugate, 2 − √3, is its multiplicative inverse—their product is exactly 1. Together, they sum to exactly 4. These clean algebraic relationships aren't coincidences; they reflect deep structural properties of the substitution rule that generates the tiling.

## The Architecture of Aperiodicity

How does the hat tile actually tile the plane? Not by random placement, but through a hierarchical *substitution rule*. Start with a single hat tile. Following a precise recipe, group several hat tiles together to form a larger shape—a "supertile"—that is geometrically similar to the original hat, but scaled up by the factor 2 + √3. Then group supertiles into super-supertiles, and so on, building up larger and larger structures that tile ever-larger regions of the plane.

This hierarchy is the key to aperiodicity. Each level of the hierarchy constrains the next, creating a cascade of geometric relationships that extends infinitely in both directions—down to individual tiles, up to arbitrarily large patches. No periodic pattern can accommodate this infinite hierarchy, because periodicity would require the hierarchy to "close up" at some finite level, which the irrational expansion factor prevents.

The hat tile uses four types of "metatiles" in its substitution system—labeled H, T, P, and F—each of which is a specific cluster of hat tiles. The substitution matrix, which tracks how many of each type appear when you inflate, has its own spectral theory. The eigenvalues of this matrix encode the growth rates and frequency ratios of the different metatile types, connecting the combinatorics of tiling to linear algebra.

## The Critical Boundary

Perhaps the most intriguing feature of the hat spectrum is the critical parameter at t = 1/2, where the tile transitions from aperiodic to periodic. This isn't just a mathematical curiosity—it represents a genuine *phase transition* in the geometry of tiling.

On one side of the critical point, the hat has edge ratio less than 1 (shorter *a*, longer *b*). On the other side, the turtle has the reversed ratio. Both sides force aperiodicity. But at the critical point itself, where *a* = *b*, the tile's two edge types become indistinguishable, and the substitution rule loses its grip. The tile can slip into periodic arrangements because the geometric constraint that prevented periodicity—the distinction between the two edge types—has been erased.

This phase transition has deep connections to other areas of mathematics and physics. In condensed matter physics, quasicrystals—materials with aperiodic atomic arrangements—exhibit similar phase transitions between ordered and disordered states. The hat spectrum provides a clean, mathematical model of such transitions: a single continuously varying parameter that controls the boundary between order and disorder.

## One Shape, Many Questions

The discovery of the hat and its spectrum has opened a new chapter in the study of aperiodic tilings. Some questions that drive current research:

**How many aperiodic monotile families exist?** The hat spectrum is one continuous family, but are there others? Could there be aperiodic monotiles with fundamentally different substitution rules, expansion factors, or geometric properties?

**What happens in three dimensions?** The aperiodic monotile problem in three dimensions—finding a single shape that tiles space aperiodically—remains wide open. The hat is inherently two-dimensional, and its substitution machinery doesn't generalize directly to 3D.

**Can the substitution rule be read from the shape?** Given an arbitrary polygon, can you determine algorithmically whether it admits an aperiodic tiling? This decision problem is believed to be undecidable in general, but the hat spectrum suggests that for certain families of shapes, the answer might be computable.

**What is the entropy of a hat tiling?** Even though hat tilings are never periodic, they're not random either. The substitution rule constrains the local arrangements of tiles, and the resulting tilings have a specific configurational entropy that measures their "randomness." Computing this entropy exactly is an open problem.

The hat tile is more than a mathematical curiosity. It is a window into the deep structure of order and disorder—a shape so simple that a child could draw it, yet so subtle that it encodes an infinite hierarchy of geometric relationships that no periodic pattern can capture. In the hat spectrum, we see a microcosm of one of mathematics' grand themes: how continuous variation in a simple parameter can produce discontinuous changes in global structure. One shape, one dial, one phase transition—and an infinite plane that will never repeat itself.

---

*The hat tile was discovered by David Smith, Craig S. Kaplan, Joseph Samuel Myers, and Chaim Goodman-Strauss and published in 2023. Their paper "An aperiodic monotile" appeared in a preprint that quickly became one of the most celebrated mathematical discoveries of the decade.*
