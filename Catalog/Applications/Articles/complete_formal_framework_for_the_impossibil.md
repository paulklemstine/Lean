# The Landscape of Impossible Maps

## When Symmetry Says "No"

Imagine you're an architect designing a building. The client wants a floor plan with rotational symmetry — it should look the same when rotated 90 degrees. You have a beautiful circular lobby (the "source") and need to assign each point in it to a room in a square grid (the "target"). Can you do this while preserving the rotational symmetry?

Sometimes the answer is yes. Sometimes it's a resounding, provable *no*. And the collection of symmetries that force this impossibility — what mathematicians now call the **impossibility spectrum** — turns out to have a remarkably elegant structure all its own.

## The Fixed-Point Trap

The key insight is deceptively simple. When a symmetry group acts on a space, some points don't move — they're *fixed points*. The center of a circle, for example, is fixed by every rotation. If your source space has a fixed point under some symmetry but your target space doesn't, then no symmetry-respecting map can possibly exist. Where would the fixed point go? It would need to land on a fixed point in the target — but there aren't any.

This "fixed-point obstruction" is the simplest weapon in the impossibility arsenal, but it's far from the only one. The real power emerges when you consider *all possible subgroups* of your symmetry group simultaneously.

## A Spectrum of Obstructions

Consider a molecule with the symmetry group of a cube — 48 different rotations and reflections that leave it looking the same. This group contains dozens of subgroups: rotations around each axis, reflections through each plane, and various combinations. For any pair of molecular configurations (source and target), some of these subgroups will obstruct the existence of a symmetry-respecting map, and some won't.

The impossibility spectrum is the complete census: which subgroups say "no map exists"?

What's remarkable is that this spectrum isn't just an arbitrary collection. It has rigid structural properties that constrain what patterns of impossibility can occur in nature.

## The Three Laws of Impossibility

**The First Law: Impossibility Climbs.** If a small symmetry group already forbids an equivariant map, then any larger group containing it will forbid one too. This makes intuitive sense: more symmetry constraints mean fewer maps can satisfy them all. In mathematical language, the impossibility spectrum is "upward closed" in the lattice of subgroups.

**The Second Law: Triviality Escapes.** The trivial symmetry group — the one containing only the identity transformation — never obstructs anything. If you impose no symmetry requirements at all, you can always find a map (as long as the target space is nonempty). This means the bottom of the subgroup lattice is never in the spectrum.

**The Third Law: Conjugation Symmetry.** If the symmetry group of rotations around the *x*-axis forbids a map, then so does the symmetry group of rotations around the *y*-axis (assuming these are conjugate subgroups — related by a symmetry of the ambient group). The spectrum respects the internal symmetries of the group itself.

## The Obstruction Filter

These three laws aren't just observations — they're axioms for a new algebraic structure called an **obstruction filter**. Think of it as a "shape" that any pattern of impossibility must conform to. Just as a filter in topology captures a notion of "largeness" for sets, an obstruction filter captures a notion of "impossibility" for symmetry subgroups.

The upward closure property is reminiscent of filters in order theory, but the conjugation invariance adds a distinctly group-theoretic flavor. This hybrid structure sits at the intersection of lattice theory, group theory, and equivariant topology.

## The Quantitative Dimension

Beyond the qualitative question of whether an equivariant map exists, there's a quantitative refinement. Count the fixed points: if your source has more fixed points under a subgroup *H* than your target does, then no *injective* equivariant map can exist. The fixed points in the source would need to map one-to-one into the fixed points of the target, but there aren't enough target fixed points to go around.

This pigeonhole argument connects the abstract algebra of group actions to concrete combinatorial counting. It's the bridge between "this map can't exist" and "here's exactly why, measured in fixed points."

## Transfer and Functoriality

The impossibility spectrum also respects natural transformations between spaces. If two source spaces are connected by an equivariant bijection — a symmetry-preserving relabeling — they have the same impossibility spectrum against any target. Similarly, if the target can be enlarged through an equivariant surjection, the spectrum can only shrink (more room in the target means more potential maps).

These transfer principles mean the impossibility spectrum is not just a property of specific spaces, but a *functorial* invariant — it transforms predictably under the natural operations of equivariant mathematics.

## Connections to the Wider World

The impossibility spectrum framework connects to several deep areas of mathematics:

**The Burnside Ring.** The integers assigned to each conjugacy class of subgroups — counting fixed points — form an algebraic structure called the Burnside ring. The impossibility spectrum can be read off from the "marks" in this ring, connecting abstract impossibility to concrete linear algebra over integers.

**Equivariant Topology.** The Borsuk-Ulam theorem — perhaps the most famous equivariant impossibility result — states that no continuous map from the sphere to the plane can be equivariant under the antipodal action. This is a topological instance of a fixed-point obstruction, and the impossibility spectrum framework provides the algebraic scaffolding to generalize it.

**Computational Complexity.** In theoretical computer science, symmetry obstructions appear in lower bounds: proving that no algorithm with certain symmetry properties can solve a problem. The obstruction filter structure suggests that these lower bounds form a lattice-theoretically constrained family, not an arbitrary zoo.

## The Completeness Question

The most tantalizing open question is whether every obstruction filter is *realizable* — whether every abstract pattern of impossibility satisfying the three laws actually arises as the impossibility spectrum of some pair of group actions. If the answer is yes, it would mean the three laws are not just necessary but *sufficient* to characterize all possible patterns of equivariant impossibility.

This completeness conjecture has the flavor of a representation theorem: just as every abstract Boolean algebra is isomorphic to a field of sets (Stone's theorem), every obstruction filter might be the spectrum of a concrete pair of group actions. Resolving this would transform the study of equivariant impossibility from case analysis into a complete classification.

## Looking Forward

The impossibility spectrum is a new lens for viewing an old phenomenon. Mathematicians have long known individual impossibility theorems — you can't trisect an angle with compass and straightedge, you can't solve the quintic by radicals, you can't comb a hairy ball. What the spectrum framework offers is a *systematic* way to organize these impossibilities, revealing the hidden algebraic structure that constrains which combinations of symmetry obstructions can coexist.

As mathematics continues to grapple with increasingly complex symmetry groups — from crystallographic groups in materials science to gauge groups in physics — having a principled framework for the landscape of impossibility may prove as valuable as having tools for the landscape of possibility.

After all, knowing what *can't* be done is half the battle.
