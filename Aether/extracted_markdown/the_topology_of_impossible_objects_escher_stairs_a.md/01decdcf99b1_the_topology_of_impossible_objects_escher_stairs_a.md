# The Staircase That Goes Up Forever: How Mathematics Explains Impossible Art

*Why Escher's staircases and Penrose's triangles break our brains — and what they reveal about the hidden geometry of the universe*

---

You've seen them a thousand times: the staircase in M.C. Escher's *Ascending and Descending* where monks trudge endlessly upward only to arrive back where they started. The Penrose triangle — three bars of steel joined at right angles into an object that cannot exist. These "impossible figures" have decorated dorm rooms and puzzle books for decades. But beneath their visual trickery lies a profound mathematical truth that connects art, physics, and the topology of space itself.

The question that drove a team of mathematicians to investigate isn't just *why* these figures are impossible — that much is obvious to anyone who stares at them long enough. The deeper question is: **what mathematical structure unites all impossible figures, and can we classify them the way chemists classify elements?**

The answer turns out to involve a concept called *monodromy* — a Greek word meaning "running around once" — and it reveals that impossible figures are not failures of geometry, but windows into a different kind of geometry altogether.

## The Height Game

Imagine you're standing at one corner of the Penrose triangle. An architect tells you to measure the height of each joint as you walk around the figure. At the first corner, your measuring stick reads zero. You walk along the first bar and the height goes up by some amount — let's say one meter. You turn the corner, walk the second bar: up another meter. Turn again, walk the third bar: up one more meter.

Now you're back where you started. Your measuring stick reads three meters. But you're standing at the exact same spot where it read zero.

This is the monodromy of the Penrose triangle: three meters. And here's the key insight: **any figure where the monodromy is not zero is impossible**.

This sounds almost tautological — of course you can't go up three meters and be back where you started. But the mathematical formulation is far more powerful than the intuition. The monodromy isn't just a diagnostic tool; it's a complete invariant. A figure is impossible if and only if its monodromy is nonzero. Zero monodromy means a consistent height assignment exists. Nonzero monodromy means it doesn't. Period.

## The Staircase Theorem

Escher's ascending staircase is a special case where every single step goes up. Mathematically, this means every weight in the cycle is positive. And here's where basic arithmetic becomes unexpectedly profound: the sum of positive numbers is positive.

That's it. That's the proof that Escher's staircase is impossible.

But wait — the depth is in what this simple fact implies. The sum being positive means the monodromy is positive. Positive monodromy means no consistent height function. No consistent height function means the figure cannot exist in three-dimensional space. A chain of logic that starts with grade-school arithmetic and ends with a topological impossibility theorem.

What makes this nontrivial is that the same framework extends far beyond simple staircases. Consider a figure where most steps go up but a few go down. Is it still impossible? The monodromy theorem tells you instantly: add up all the steps. If the sum is nonzero, the figure is impossible, regardless of how the ups and downs are arranged.

## Rotation Doesn't Matter

Here's a result that surprised even the researchers: the monodromy doesn't care where you start measuring.

Walk around the Penrose triangle starting from corner A: the monodromy is three. Start from corner B: three. Start from corner C: three. This seems obvious for the symmetric Penrose triangle, but it holds for *any* impossible figure, no matter how asymmetric.

The proof is elegant: cyclically rotating the weights of the cycle is the same as applying a permutation to the index set. A permutation doesn't change a sum. Therefore the monodromy is rotation-invariant.

This invariance is the discrete analogue of a deep fact in differential geometry: the integral of a closed 1-form around a loop doesn't depend on the starting point. The impossible figures are telling us something about cohomology — the branch of mathematics that studies when local data fails to assemble into global data.

## Building Bigger Impossibilities

What happens when you combine two impossible figures? Imagine taking a Penrose triangle and gluing it to a Penrose square at a shared vertex — like two conjoined twins of impossibility.

The result is a figure with two independent cycles, and its obstruction lives not in a single number but in a pair of numbers: the monodromy vector (m₁, m₂) in ℝ². The combined figure is realizable if and only if *both* monodromies vanish.

This is the beginning of a classification theory. For a figure built from k independent cycles (a graph with first Betti number k), the obstruction space is ℝᵏ. Each dimension corresponds to one independent way the figure can fail to close up. The entire theory of impossible figures is really a theory of first cohomology.

## Orientation and the Möbius Strip

There's another kind of impossibility, more subtle than height inconsistency: *orientation reversal*. Imagine walking along a Möbius strip. You start with your head pointing outward. After one complete trip around the strip, your head is pointing inward. You've been flipped.

This is captured by the *orientation holonomy*: assign a sign (+1 or -1) to each edge of a cycle, representing whether that segment preserves or reverses orientation. The holonomy — the product of all these signs — tells you whether the whole cycle reverses orientation.

The mathematical result is crisp: the surface is non-orientable if and only if the number of orientation-reversing edges is odd. This is because (-1)ⁿ = -1 when n is odd. Simple arithmetic, deep geometry.

And here's the beautiful connection: every non-orientable surface has an *orientable double cover*. The Möbius band's double cover is the cylinder. The Klein bottle's double cover is the torus. In our discrete framework, the double cover simply replaces every edge sign with +1, doubling the number of edges. The holonomy of this double cover is always +1: orientability is restored.

## The Obstruction Degree

Not all impossible figures are equally impossible. An ascending Escher staircase has positive monodromy; a descending one has negative monodromy. The *obstruction degree* — the sign of the monodromy — is a topological invariant that classifies impossible figures into three families:

- **Degree +1**: Ascending impossibility (the Escher ascending staircase)
- **Degree -1**: Descending impossibility (the Escher descending staircase)
- **Degree 0**: Realizable (a consistent height function exists)

Scaling the figure — making the steps bigger or smaller — doesn't change the degree. Negating the figure — turning every up-step into a down-step — flips the degree. These are exactly the properties you'd want from a topological invariant.

## What Impossible Figures Tell Us About Physics

Why should physicists care about Penrose triangles? Because the same mathematical structure — a locally consistent quantity that fails globally — appears throughout modern physics.

In gauge theory, the analogue of monodromy is the *Wilson loop*: the phase accumulated by a quantum particle transported around a closed path. When this phase is nontrivial, the gauge field has nonzero curvature — the space is curved, and parallel transport around a loop rotates things. The Penrose triangle is, in a precise mathematical sense, a cartoon of curved spacetime.

In condensed matter physics, the Berry phase plays the same role: an electron's quantum state picks up a geometric phase as it traverses a closed path in parameter space. If this phase is nonzero — if the monodromy is nontrivial — the material exhibits exotic topological properties like the quantum Hall effect.

The impossible figure is not just a visual trick. It is a fundamental mathematical structure that nature uses over and over: local consistency, global failure, and the topological invariant that distinguishes the two.

## The Classification Theorem

The deepest result of this investigation is a classification theorem: every impossible figure on a cycle graph is monodromy-equivalent to a standard Penrose polygon.

That is, any impossible figure with nonzero monodromy m can be "deformed" (by positive rescaling) into a regular polygon where every edge has the same weight m/n. The irregular, asymmetric impossible figure and the perfectly symmetric Penrose polygon are, from the cohomological point of view, the same object.

This is analogous to the classification of closed surfaces: every closed orientable surface is a sphere with handles, regardless of how it's been stretched or deformed. The impossible figures, too, have a normal form — and that normal form is the Penrose polygon.

## The Deeper Question

This work opens a door. We've classified impossible figures on cycle graphs. But what about more complex graphs? Graphs with multiple independent cycles? Graphs embedded in higher-dimensional spaces?

The framework extends naturally: on a graph with first Betti number β₁, the obstruction space is ℝ^β₁. But proving that every possible obstruction is actually realized — that the classification is sharp — requires new mathematics. The tools of algebraic topology, sheaf cohomology, and homological algebra are waiting to be brought to bear.

And beyond the mathematics, there's the visual art. Every theorem in this paper corresponds to a rule about what impossible figures can and cannot look like. Artists have been exploring this design space intuitively for a century. Now we have the grammar of their language.

The Penrose triangle isn't just impossible. It's telling us that the world is more interesting than we thought — that consistency and inconsistency, like orientability and non-orientability, are two sides of the same mathematical coin. And that coin, as it turns out, has a beautiful name: monodromy.

---

*This article describes research formalizing the mathematics of impossible figures using monodromy and cohomological obstruction theory, connecting visual art to gauge theory and topology.*
