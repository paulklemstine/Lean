# When Information Becomes Geometry: A New Mathematical Bridge Between Logic and Gravity

## The Shape of What You Know

Imagine you're trapped in a dark room, and all you have is a flashlight that measures how much *stuff* is behind each wall. You can't see the room's shape directly. But if you're clever enough — and if the walls follow certain rules — you can reconstruct the entire floor plan from those measurements alone.

Now imagine the "room" isn't a physical space. It's the structure of a logical system: the way conclusions follow from premises, the way information accumulates when you combine facts. And the "walls" are information bottlenecks — places where adding a new piece of data causes a measurable jump in the system's total complexity.

A new mathematical result shows that, under surprisingly mild conditions, these information measurements — these entropy jumps across logical cuts — are enough to reconstruct the *entire geometry* of the system. And the reconstruction is unique: there is exactly one minimal "shape" that explains the data.

This isn't a metaphor. It's a theorem.

## Two Worlds That Shouldn't Talk to Each Other

For over a century, mathematics has maintained a sharp divide between two kinds of structure.

On one side sits **algebra and logic**: closure operators, lattices, the architecture of inference. These are the tools of computer science, linguistics, and formal reasoning. When a database computes the consequences of a set of constraints, it's using a closure operator. When a compiler determines which variables are reachable, that's closure too. These structures are discrete, combinatorial, and utterly ungeometric.

On the other side sits **physics and geometry**: curved spaces, gravitational fields, the fabric of spacetime. Since Einstein, physicists have understood that gravity isn't a force — it's the shape of space itself. Mass tells space how to curve; curvature tells mass how to move. In the 1970s, Bekenstein and Hawking discovered something even stranger: black holes have entropy proportional to their surface area, not their volume. The information content of a gravitational system is encoded on its boundary.

This "holographic principle" — the idea that boundary data encodes bulk geometry — has been one of the most fertile ideas in theoretical physics for three decades. But it has always been stated in the language of continuous geometry, quantum fields, and string theory. It seemed to have nothing to do with the discrete, finite world of logic and computation.

Until now.

## The Breakthrough: Entropy Determines Shape

The new result establishes that holography — the reconstruction of interior geometry from boundary measurements — works in the finite, discrete world of closure systems.

Here's the setup. Take any finite collection of objects — call them data points, variables, axioms, whatever you like. Define a *closure operator*: a rule that takes any subset and computes its "logical completion." This is the discrete analogue of computing the causal future of an event, or the deductive closure of a set of axioms. The operator must satisfy three natural conditions: it only adds things (extensivity), it respects containment (monotonicity), and doing it twice is the same as doing it once (idempotence).

Now add an *entropy functional*: a number assigned to each closed set that measures its "information content." Require that bigger closed sets have more entropy (monotonicity) and that combining two closed sets can't create more entropy than the sum of the parts minus what they share (submodularity). These are the same mathematical conditions that Shannon entropy satisfies. They're the laws of information.

Finally, introduce *cuts*: partitions that slice the system into two sides. For each closed set, you can measure how much entropy increases when you extend it across each cut. This marginal entropy increment — call it the *curvature profile* — is the key object.

The theorem says: **if the cuts separate all distinct closed sets, then the curvature profile uniquely determines the closed set, and vice versa.** Moreover, you can reconstruct a minimal "horizon graph" — a discrete geometric object encoding the system's causal structure — from the profile data alone. This reconstruction is unique up to the natural notion of isomorphism.

In other words: the entropy data determines the geometry. And the geometry determines the entropy data. They are dual descriptions of the same structure.

## What Makes This Different

Mathematical dualities are not new. Fourier analysis relates a function to its frequency spectrum. Pontryagin duality links groups to their characters. The Riesz representation theorem connects functionals to measures. In each case, two seemingly different mathematical objects turn out to be the same thing viewed from different angles.

But this duality is different in three crucial ways.

**First, it's finite and constructive.** There are no limits, no approximations, no infinite-dimensional function spaces. Everything lives on finite sets. The reconstruction algorithm terminates. The uniqueness is exact. This means the result is not just true in principle — it's computable.

**Second, it bridges logic and geometry.** The closure operator is a logical structure: it captures inference, dependence, reachability. The horizon graph is a geometric structure: it captures causal connectivity, boundary screens, entropic area. The theorem says these are the same information in different packaging.

**Third, it uses tropical mathematics.** The curvature profiles live naturally in a *tropical semimodule* — a mathematical structure where "addition" is taking the minimum and "multiplication" is ordinary addition. This isn't a quirk; it's the right algebra for optimization problems. Just as gravitational systems extremize action, the tropical structure encodes which cuts are "dominant" — which information bottlenecks are the real geometric constraints. The minimal generators of this tropical structure correspond exactly to the primitive entropic screens of the horizon.

## The Anatomy of a Proof

The proof has an elegant architecture built on four pillars.

**Pillar 1: Separation implies injectivity.** If every pair of distinct closed sets can be told apart by some cut — if there exists a cut where their marginal entropy increments differ — then the profile map is injective. No two closed sets have the same entropy fingerprint. This is a finite version of the physical principle that boundary data determines bulk geometry.

**Pillar 2: Submodularity implies antitonicity.** When one closed set contains another, the larger set has smaller curvature profiles everywhere. Extending a larger region across a cut produces a smaller marginal increment. This is the discrete analogue of the gravitational principle that larger horizons have lower curvature — they're "flatter" in an entropic sense. The proof uses the submodularity inequality in a subtle way, applying it to pairs of closed sets that arise from the interplay of closure and intersection.

**Pillar 3: Active cuts form minimal generators.** The cuts where the curvature profile is nonzero — the "active" cuts — form the unique minimal generating family for the profile. No proper subset can capture the full entropic signature. This is the discrete analogue of the principle that a horizon is determined by its minimal set of independent screens.

**Pillar 4: Minimal realizations are unique.** If two horizon graphs both minimally realize the same closed set, they must have the same size. There is no ambiguity in the geometric reconstruction.

## Why It Matters

The implications radiate outward in several directions.

**For computer science:** Closure operators are everywhere in computation — in databases (functional dependencies), in program analysis (abstract interpretation), in knowledge representation (concept lattices). This theorem says that any such system with a well-behaved entropy functional has a hidden geometric structure that can be algorithmically extracted. That geometric structure could be used for optimization, compression, or visualization of complex logical dependencies.

**For physics:** The holographic principle has been formulated in the continuous setting of quantum gravity, where it remains largely conjectural except in special cases (like the AdS/CFT correspondence). This result provides a rigorous, finite model where holographic reconstruction actually works — with explicit witnesses, constructive algorithms, and uniqueness guarantees. It shows that the holographic principle is not an artifact of continuous geometry; it's a consequence of entropy laws that hold in any setting.

**For mathematics:** The connection between closure lattices and tropical geometry opens a new field. The curvature profiles form a tropically convex structure. The extremal generators correspond to join-irreducible elements of the closure lattice. The interplay between idempotent algebra and submodular functions has been studied separately in optimization theory and matroid theory, but this result connects them through a geometric lens that hasn't been explored before.

**For information theory:** The submodularity condition on entropy is exactly what defines the "holographic entropy cone" in quantum information theory — the set of entropy vectors that can arise from holographic systems. This result shows that the finite entropic constraints alone, without any quantum mechanics, already determine a geometric realization. The entropy cone has a built-in geometry.

## The Bigger Picture

There's a deep philosophical question lurking behind this mathematics: **Is geometry fundamental, or does it emerge from information?**

Einstein showed that gravity is geometry. Bekenstein and Hawking showed that black hole geometry is entropy. The holographic principle suggests that all of spacetime might be an encoding of information on a distant boundary. But these ideas have remained in the realm of physics, expressed in the language of quantum fields and spacetime manifolds.

This result takes a step toward making the idea precise in a setting stripped of all physical contingency. There are no quantum fields here, no continuous spacetime, no strings. There is only a finite set, a closure operator, and an entropy functional. And from these minimal ingredients, a geometry emerges — not postulated, not assumed, but *derived* from the entropy laws alone.

The geometry is discrete and combinatorial: a horizon graph rather than a Riemannian manifold. But it satisfies the same holographic principle: boundary data (entropy profiles across cuts) determines bulk structure (the closure operator and its associated causal geometry). And the reconstruction is certified: it comes with an algorithmic procedure and a uniqueness guarantee.

Perhaps the most striking aspect is how little structure is needed. The closure operator could model anything: logical inference, causal precedence, semantic containment, physical accessibility. The entropy could measure anything that satisfies monotonicity and submodularity: Shannon entropy, Rényi entropy, counting functions, capacity measures. The cuts could be any family of partitions that separates the closed sets.

In every such system, geometry is waiting to be discovered. The theorem tells you exactly how to find it.

## What Comes Next

The result opens several concrete research directions. Can the tropical curvature structure be enriched to capture more than just the cardinal properties of the horizon? Can the reconstruction be extended to infinite closure systems with appropriate compactness conditions? Can the entropy inequalities be strengthened to characterize exactly which profiles are realizable — yielding a finite analogue of the holographic entropy cone?

Most tantalizingly: can the discrete horizon graphs be organized into a category, and can the duality be promoted to an equivalence of categories? If so, the result would not just be a theorem about individual systems but a structural principle about the relationship between logical and geometric thinking — a new kind of mathematics where inference and curvature are two faces of the same coin.

The room is dark, but the flashlight measurements are enough. The shape is there, encoded in the entropy. You just have to know how to read it.
