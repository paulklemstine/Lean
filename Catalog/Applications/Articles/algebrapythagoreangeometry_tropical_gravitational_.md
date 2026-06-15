# The Gravity of Numbers: How Light-Bending Mathematics Could Crack the Code of Primes

## A hidden geometry connects ancient triangles to modern cryptography

Imagine you need to break a large number into its building blocks—say, figuring out that 91 is really 7 × 13. For small numbers, that's trivial. But for a number with hundreds of digits? That's the problem that guards your bank account, your medical records, and every secure message you've ever sent. The entire architecture of modern cryptography rests on the assumption that factoring large numbers is fantastically hard.

Now imagine someone told you that the answer wasn't hiding in the numbers at all—but in the way light bends around them.

That's the provocative idea behind a new mathematical framework that connects three seemingly unrelated fields: the ancient geometry of right triangles, the exotic algebra of tropical mathematics, and the physics of gravitational lensing. The result is a theory where breaking a number into factors becomes equivalent to reading the focal pattern of a mathematical lens—a structure that bends "rays" of arithmetic information the way a massive galaxy bends starlight.

## The oldest triangles in mathematics

The story begins 4,000 years ago, with the Babylonians and their clay tablets full of Pythagorean triples: sets of three whole numbers like (3, 4, 5) or (5, 12, 13) that form the sides of a right triangle. These triples have fascinated mathematicians ever since—not because of right triangles per se, but because they encode deep structure about how whole numbers relate to each other.

In 1934, the German mathematician Berggren discovered something remarkable: every primitive Pythagorean triple (one where the numbers share no common factor) can be generated from the simplest triple (3, 4, 5) by applying just three matrix transformations, over and over. The result is an infinite ternary tree—a branching structure where every primitive triple appears exactly once, connected to its "parent" and "children" by simple algebraic operations.

This Berggren tree is not just a catalogue. It's a dynamical system—a machine that generates all of number theory's right-triangle arithmetic through simple, deterministic branching. For decades, mathematicians viewed it as an elegant curiosity. The new framework asks: what if it's actually a lens?

## When algebra meets the tropics

To understand how a tree of triangles becomes a lens, you need to visit one of the strangest corners of modern mathematics: tropical geometry.

Tropical mathematics replaces the familiar operations of arithmetic with something alien. Instead of adding numbers, you take their minimum. Instead of multiplying them, you add them. This sounds like a parlor trick, but it turns out to be extraordinarily powerful. Problems that are impossibly nonlinear in ordinary algebra become piecewise-linear—angular, crystalline, tractable—in the tropical world.

The "tropical" name, incidentally, has nothing to do with palm trees. It honors the Brazilian mathematician Imre Simon, who pioneered this min-plus algebra. But the imagery is apt: tropical geometry reveals hidden skeletal structures inside complicated mathematical objects, the way an X-ray reveals bones.

In the new framework, each primitive Pythagorean triple is assigned a "Gram defect"—a measure of how well or poorly it fits with the divisor structure of some target number N. These defects become tropical weights. The Berggren tree, with its algebraic branching, becomes a weighted network. And on this network, you can ask a question straight from physics: where does the energy focus?

## Gravitational lensing, but for numbers

When light from a distant quasar passes near a massive galaxy, the galaxy's gravity bends the light rays. Multiple images of the quasar appear, and the pattern of those images encodes information about the mass distribution of the galaxy—even mass you can't see directly, like dark matter.

The mathematics of this focusing—finding where bent rays converge—has a precise tropical analogue. On the Berggren lens complex, "rays" are paths through the tree weighted by Gram defects, and "focusing" means minimizing a tropical potential: a sum of min-plus costs across all source triples. The vertices where this potential is smallest are the focal minimizers—the mathematical equivalent of the bright spots where lensed quasar images appear.

Here's the crucial insight: the focal pattern isn't arbitrary. It's rigid. If two different families of source triples produce the same tropical potential everywhere on the lens, then they must encode exactly the same divisor information about N. This is the focal rigidity theorem, and it's the conceptual heart of the framework.

Rigidity means the geometry isn't just correlated with the arithmetic—it determines it. You can't change the factorization without changing the focal pattern, and you can't change the focal pattern without changing the factorization. The lens and the number are locked together.

## From focus to factors

The factor extraction theorem makes the connection explicit. Suppose the focal set—the collection of all potential-minimizing triples—splits into two groups, each carrying a "factor witness" for a different divisor of N, and these divisors multiply to give N. Then the framework guarantees that you've found a genuine, nontrivial factorization. No probabilistic arguments, no heuristics—a certified decomposition, read directly from the geometry.

This is remarkable because it translates factorization from a search problem (try all possible divisors) into a decoding problem (read the focal pattern of a lens). In gravitational lensing, astronomers decode mass distributions from image patterns. Here, mathematicians decode divisor distributions from focal patterns. The analogy isn't just poetic—the mathematical structures are genuinely parallel.

## Why rigidity matters

The word "rigidity" carries enormous weight in mathematics. A rigid structure is one where local information determines global structure—where you can't wiggle one piece without moving everything else. Rigidity theorems are among the deepest results in geometry, from Mostow's theorem about hyperbolic manifolds to the Pogorelov-Alexandrov theory of convex surfaces.

The focal rigidity theorem in this framework says something similarly powerful: the tropical-optical fingerprint of a number's divisor structure is unique. Two different "mass distributions" (factor partitions) can't produce the same lensing pattern. This uniqueness is what makes the geometric approach viable—without it, the lens would be ambiguous, and the focal pattern would be noise rather than signal.

## The complexity question

Does this mean factoring large numbers is suddenly easy? Not yet—and perhaps not ever, in the way cryptographers fear. The framework includes a complexity bound showing that the search space (the number of vertices in the lens complex) grows at most exponentially with structural parameters like branching and diameter. This is consistent with factoring being hard in general, but it opens a new avenue for understanding *why* it's hard—and *when* it might be easier.

In the language of this framework, the difficulty of factoring a particular number is controlled by the geometry of its Berggren lens: its diameter (how far apart the farthest triples are), its branching entropy (how bushy the tree is at each level), and the sharpness of its focal split (how clearly the lens resolves the factors). Numbers that are products of two primes of similar size would produce lenses with weak, diffuse focal patterns—hard to read. Numbers with factors of very different sizes might produce sharp, distinctive patterns—easier to decode.

This geometric perspective on computational complexity is itself a contribution, independent of any practical algorithm. It suggests that the difficulty of factoring is not just a property of bit-length, but of arithmetic geometry—of how the number sits inside the landscape of Pythagorean triples.

## A new language for an old problem

Perhaps the most striking aspect of this work is that it creates a genuinely new language for thinking about factorization. For centuries, the tools for attacking this problem have been algebraic: sieves, congruences, lattice reduction, elliptic curves. Each of these approaches treats the number as a static algebraic object and tries to find structure by computation.

The tropical gravitational approach treats the number as a source of geometric structure—a mass distribution that shapes a mathematical spacetime, bending rays and creating focal patterns. Factorization becomes not a search but an observation: you build the right lens, and the factors appear as bright spots in the focal plane.

This shift in perspective—from computation to observation, from algebra to geometry, from searching to decoding—is the kind of conceptual transformation that sometimes precedes major breakthroughs. Whether or not it leads to faster algorithms, it reveals a deep and unexpected connection between the arithmetic of whole numbers and the geometry of focusing. 

The Babylonians who carved their Pythagorean triples into clay tablets could never have imagined that those simple right triangles would one day become the vertices of a tropical lens, bending mathematical light to reveal the hidden structure of numbers. But mathematics has always had this quality: the simplest objects, studied deeply enough, turn out to be connected to everything else. The lens is focused. The question now is what else it will reveal.
