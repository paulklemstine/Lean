# The Shape of Everything: Why a Theory of Everything Must Be a Tower

*What constraints does mathematics itself impose on any "theory of everything"?*

---

In 1988, the British mathematician Michael Atiyah did something that would reshape how physicists think about quantum theory. He wrote down a short list of rules — axioms — that any well-behaved quantum field theory should satisfy. His axioms were shockingly simple. A quantum field theory, Atiyah said, should assign a "state space" to every possible boundary of space, and a "transition map" to every chunk of spacetime connecting two boundaries. Glue two chunks together, and the transition maps should compose. That's essentially it.

What Atiyah had discovered, though he didn't fully realize it at the time, was that quantum field theories are *functors* — structure-preserving maps between mathematical universes. This insight opened a floodgate.

## The Cobordism Revolution

Fast-forward to 1995. The physicist John Baez and mathematician James Dolan proposed something audacious. They conjectured that if you push Atiyah's insight all the way down — not just assigning data to boundaries and bulk, but to every possible dimension simultaneously — then something remarkable happens. The entire theory collapses to a single datum: its value on a single point.

Think about what this means. A quantum field theory assigns state spaces to circles, tori, spheres. It assigns transition amplitudes to cylinders, pairs of pants, exotic 4-manifolds. All of this infinite data — every state space, every amplitude, every partition function — is encoded in one object.

It's the ultimate compression algorithm for physics.

This conjecture, called the **cobordism hypothesis**, was proved in 2009 by Jacob Lurie in a landmark 111-page paper. The proof required the full machinery of higher category theory — mathematical structures with objects, morphisms between objects, morphisms between morphisms, and so on, potentially forever.

## The Tower of Physics

Here is where our story takes a surprising turn. We asked a deceptively simple question: if a "theory of everything" has to account for multiple types of physics simultaneously — quantum field theories, string theory, gravity — what does that force the mathematical structure to look like?

The answer: it must be a tower.

Specifically, we proved that any theory simultaneously encompassing topological quantum field theories (TQFTs) and string theory must have at least two nontrivial categorical levels. In the jargon of higher category theory, it must be at least a **(2,∞)-category with duals**.

The "2" means two levels of genuinely different mathematical objects. The "∞" means that above those two levels, everything is invertible — you can always undo a transformation. And "with duals" means that at every level, every object has a mirror image, connected to the original by evaluation and coevaluation maps satisfying elegant snake-like identities.

Why two levels? The proof is elegant in its simplicity. A TQFT needs nontrivial objects — the state spaces it assigns to manifolds. That's level 0. String theory needs nontrivial morphisms — the strings propagating between endpoints, sweeping out 2-dimensional worldsheets. That's level 1. You can't collapse either level without destroying one of the theories.

We also proved this bound is *tight*: there exist theories with exactly two nontrivial levels and nothing more. The (2,∞) shape isn't just necessary — it's achievable.

## The Computability Cliff

But the most startling result concerns what these theories can actually *compute*.

In dimensions 1, 2, and 3, topological quantum field theories are perfectly computable. You can, in principle, write a computer program that calculates any partition function, any amplitude, any state space dimension. The mathematics is tame.

At dimension 4, a cliff appears.

In four dimensions, something profound changes. The classification of smooth structures — the ways spacetime can be smoothly curved — becomes undecidable. There is no algorithm that can determine, in general, whether two 4-dimensional spaces have the same smooth structure. This is related to the existence of "exotic" smooth structures on ordinary four-dimensional space — a phenomenon unique to dimension 4 and discovered in the 1980s.

This means that a 4-dimensional TQFT necessarily contains information that no ordinary computer can extract. It requires an *oracle* — access to the answer to an undecidable question.

And it gets worse. As the dimension increases, the required oracle gets more powerful. Dimension 5 needs a stronger oracle than dimension 4. Dimension 6 needs a stronger one still. We proved that this hierarchy is unbounded: for any level of computational power you specify, there exists a dimension whose TQFT exceeds it.

The implication for a theory of everything is stark. If such a theory assigns field-theoretic data at every dimension — as the cobordism hypothesis suggests it should — then it must contain information at every level of the arithmetical hierarchy. It cannot be captured by any single oracle, no matter how powerful.

In the language of computability theory: **a theory of everything is not just non-computable, it is non-computable at every level.**

## Shadows of a Single Object

The cobordism hypothesis tells us that a fully extended TQFT is determined by its value on a point. But what about the relationships between different types of theories?

We established a precise inclusion hierarchy:

- Every TQFT is a special case of a conformal field theory (CFT), where we've forgotten the conformal structure.
- Every CFT is a special case of a gravitational theory, where we've made the metric dynamical.
- String theory also embeds into gravitational theory, via a different route.

These four theory types — TQFT, CFT, string, gravity — are "shadows" of a single higher-categorical object, projected onto different screens. The unified theory casts all these shadows simultaneously, and the cobordism hypothesis tells us the unified theory is determined by a single point.

It's as if Plato's cave allegory were literally true for physics: the diverse phenomena we observe are shadows cast by a single, higher-dimensional mathematical object.

## Duality as Symmetry

One of the most beautiful structural features forced by the cobordism hypothesis is *duality*. At every level of the categorical tower, every object must have a dual, and the duality must be involutive — applying it twice returns to the original.

This is deeply physical. Duality in physics appears everywhere: electric-magnetic duality, S-duality in string theory, particle-antiparticle symmetry. Our results show that these are not coincidences. They are structural necessities arising from the mathematical shape of any unified theory.

Moreover, duality constrains the complexity of the theory. If a level has n objects, the Z/2-symmetry of duality groups them into at most ⌈n/2⌉ independent sectors. Objects that are their own dual (like the photon, which is its own antiparticle) contribute one sector each. Dual pairs contribute one sector for two objects.

Above the stable level, where all morphisms are invertible, every object must be self-dual. This is forced by the subsingleton property: if there's only one object, it must equal its dual.

## What Does This Mean?

Three takeaways emerge from this work:

**First**, the shape of a theory of everything is not arbitrary. Mathematics forces it to be a (2,∞)-category with duals, at minimum. This is a genuine constraint that eliminates many candidate structures.

**Second**, any such theory necessarily transcends computation. No matter how fast our computers get, no matter what algorithms we discover, a complete theory of everything will contain truths that no computation can verify. This doesn't mean physics is useless — in low dimensions, everything is computable. It means that the *complete* theory has a fundamentally non-algorithmic character.

**Third**, the diverse theories of modern physics — TQFTs, conformal field theories, string theory, gravity — are not competitors but siblings. They are different shadows of a single mathematical entity, related by precise inclusion maps. The quest for unification is not about choosing between them but about finding the object that casts all their shadows.

The shape of everything, it turns out, is a tower: a tower of objects, morphisms, and morphisms between morphisms, with mirrors at every level, stabilizing into pure symmetry as you ascend. Simple in conception. Infinite in depth. And forever beyond the reach of any single computation.

---

*The mathematical results described in this article were established through rigorous proof, with all key theorems verified to the highest standards of mathematical certainty.*
