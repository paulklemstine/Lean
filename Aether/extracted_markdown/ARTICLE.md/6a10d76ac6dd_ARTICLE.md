# The Algebra of the Impossible

*When symmetry meets constraint, mathematics reveals what can never be done — and why.*

---

In 1882, the German mathematician Ferdinand von Lindemann proved that squaring the circle is impossible. Not difficult, not impractical — *impossible*, in the most absolute sense that mathematics allows. No amount of ingenuity, no clever construction, no undiscovered technique could ever accomplish it. The result didn't just close a 2,000-year-old problem; it revealed something deep about the relationship between geometry and algebra.

But Lindemann's result was just one impossibility theorem. Mathematics is full of them: you cannot trisect an arbitrary angle with compass and straightedge, you cannot solve the general quintic equation by radicals, you cannot find an algorithm that determines whether an arbitrary program halts. Each of these results seems to stand alone, a monument to some particular limitation of some particular mathematical system.

What if they didn't have to stand alone?

## The Hidden Thread

A new mathematical framework, the **impossibility spectrum**, reveals that many impossibility results share a common algebraic skeleton. The key insight is deceptively simple: most impossibility theorems are really statements about *symmetry*.

Consider a concrete example. Suppose you have three people — Alice, Bob, and Carol — and you want to assign them to two teams. You might require that the assignment be "fair" in some precise sense: if you relabel the people (swapping Alice and Bob, say), the team assignment should transform in a predictable way. This is what mathematicians call *equivariance* — the function respects the symmetry of the input.

Here's the catch: sometimes no equivariant assignment exists. The symmetry group of three people (the symmetric group S₃, with six elements) can act on the three-person set and on the two-team set, but the actions may be incompatible. When they are, no function — no matter how cleverly constructed — can simultaneously respect all the symmetries.

The impossibility spectrum captures *exactly which symmetries* create these obstructions. For any pair of mathematical objects with group symmetry, it identifies the collection of subgroups for which equivariant maps are impossible.

## Climbing the Lattice

The most striking property of the impossibility spectrum is what mathematicians call **upward closure**. Subgroups of a group form a lattice — a hierarchical structure where some subgroups contain others. The impossibility spectrum always forms an *upper set* in this lattice: if a certain symmetry creates an obstruction, then any larger symmetry group that contains it creates an obstruction too.

This is intuitively satisfying but mathematically powerful. It means impossibility *propagates upward*. If you can show that a small, manageable subgroup sits in the spectrum, you automatically know that every larger subgroup does too — potentially ruling out huge families of equivariant maps in one stroke.

The proof is elegant: any map that respects a larger symmetry group automatically respects every smaller subgroup (since there are fewer constraints to satisfy). Contrapositively, if no map respects the smaller group, none can respect the larger one either.

## Fixed Points: The Smoking Gun

How do you actually prove that a subgroup belongs to the impossibility spectrum? The most powerful tool is the **fixed-point obstruction**.

When a group acts on a set, some elements may be *fixed* — unmoved by every group element. Equivariant maps must send fixed points to fixed points. (If a point doesn't move under any symmetry, its image can't move either, because the map commutes with the symmetry.) This creates an immediate obstruction: if the source has fixed points but the target doesn't, no equivariant map can exist.

This is the algebraic mechanism behind many classical impossibility results. In the angle trisection problem, for instance, certain symmetries of the constructible numbers have fixed-point structures that are incompatible with the trisection operation. The impossibility spectrum framework makes this mechanism explicit and general.

## Orbits and Counting

Fixed points are the simplest case of a richer structure: *orbits*. Under a group action, elements cluster into orbits — sets of elements that can be reached from each other by applying group elements. Equivariant maps don't just preserve fixed points; they map orbits into orbits.

This leads to a powerful counting argument. If a bijective equivariant map exists between two sets, then corresponding orbits must have the same size. An orbit of size 3 in the source must map to an orbit of size 3 in the target. If the orbit sizes don't match up, no equivariant bijection exists.

The orbit structure theorem shows that equivariant maps induce a well-defined map on the *set of orbits* — the quotient space obtained by collapsing each orbit to a point. This quotient map must respect the combinatorial structure of the orbit decomposition.

## Conjugation: Symmetries of Symmetries

There is a deeper symmetry at work. In any group, subgroups can be *conjugated* — transformed by the operation H ↦ gHg⁻¹. Conjugate subgroups are "the same up to relabeling" and share the same algebraic properties.

The impossibility spectrum respects this: **conjugate subgroups are either both in the spectrum or both out of it.** This means the spectrum is really a property of *conjugacy classes* of subgroups, not individual subgroups. It's a remarkably economical piece of structure.

The proof constructs an explicit transformation: if f is equivariant for the conjugate subgroup gHg⁻¹, then the map x ↦ g⁻¹·f(g·x) is equivariant for H itself. So an equivariant map for one subgroup can always be "twisted" into an equivariant map for any conjugate.

## Measuring How Far We Are

Not every system exhibits perfect symmetry. In physics and engineering, symmetries are often approximate — a crystal lattice has translational symmetry that's broken at the boundary, a molecule has rotational symmetry that's perturbed by external fields.

The **equivariance defect** extends the impossibility spectrum to this approximate setting. For each point, it measures the maximum distance between f(g·x) and g·f(x) over all group elements g. When this defect is zero, the map is perfectly equivariant. When it's small, the map is "almost" equivariant.

This quantitative perspective transforms impossibility from a binary yes/no question into a continuous measure: *how far is the nearest equivariant map?* In applications to physics and machine learning, this distance measures the cost of breaking symmetry.

## The Transfer Principle

Perhaps the most powerful structural result is the **transfer principle**: if two sets are isomorphic as G-sets (connected by a bijective equivariant map), they have identical impossibility spectra. This means the spectrum is an invariant of the G-set, not of its particular representation.

This is analogous to how topological invariants (like the fundamental group) are preserved under homeomorphism. The impossibility spectrum is an *algebraic invariant* of the equivariant structure, and it behaves accordingly: equivalent objects have equivalent obstructions.

## Applications: From Social Choice to Physics

The impossibility spectrum framework connects to several deep areas:

**Social choice theory.** Arrow's impossibility theorem, which shows that no voting system can simultaneously satisfy a small set of fairness axioms, can be understood through the lens of equivariant maps. The "fairness" axioms impose symmetry constraints, and Arrow's theorem says the impossibility spectrum is nonempty.

**Crystallography.** The 230 space groups that classify crystal structures correspond to different symmetry actions. The impossibility spectrum for a space group tells you which site symmetries are compatible with which physical properties — which orientations a molecule can adopt in a crystal while respecting the lattice symmetry.

**Gauge theory.** In physics, gauge symmetries impose equivariance constraints on physical fields. The impossibility spectrum identifies which gauge symmetries are incompatible with certain field configurations — a discrete analog of the topological obstructions that arise in fiber bundle theory.

**Machine learning.** Equivariant neural networks, which process data while respecting known symmetries (rotational symmetry in molecular modeling, permutation symmetry in set functions), must navigate the impossibility spectrum. Understanding which equivariant architectures can exist informs the design of neural network layers.

## Looking Forward

The impossibility spectrum is a new way to organize and unify impossibility results across mathematics. Its key properties — upward closure, conjugation invariance, the transfer principle — give it the character of a *classification theory*, not just a collection of individual results.

The deepest open question is **spectral completeness**: Is every upper set in the subgroup lattice realizable as the impossibility spectrum of some pair of G-sets? If so, the spectrum is a complete invariant — every possible pattern of obstruction actually occurs. This would establish the impossibility spectrum as the definitive algebraic framework for impossibility, connecting group theory, combinatorics, and the foundations of computation in a single, elegant structure.

Mathematics has always been as much about what's impossible as what's possible. The impossibility spectrum gives us a language for saying precisely what we cannot do — and understanding exactly why.
