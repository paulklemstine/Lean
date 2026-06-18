# The Hidden Geometry of Fairness: How Two Obscure Branches of Mathematics Turned Out to Be the Same Thing

## When Moving Dirt Meets Tropical Rain

Imagine you're an urban planner trying to redistribute sand across a city's beaches after a storm. Beach A has too much; Beach C has too little. Trucks have to haul sand along roads with different distances and tolls. Your job: find the cheapest way to move exactly the right amount of sand to every beach.

This isn't a thought experiment. It's the *optimal transport problem*, and it governs everything from how machine learning models compare images to how economists measure inequality between income distributions. The mathematics behind it won a Fields Medal in 2018.

Now imagine a completely different problem. You're managing a network of fiber-optic cables connecting data centers. Each cable has a latency — a delay measured in milliseconds. You want to find the fastest round-trip route that visits a particular server. As the network grows, you want to know: what's the theoretical minimum average latency per hop?

This is a problem in *tropical algebra*, a bizarre corner of mathematics where addition is replaced by "take the minimum" and multiplication is replaced by "add." It sounds like mathematical anarchy, but it produces a rigorous theory of shortest paths, scheduling, and network optimization.

Here's what nobody expected: these two theories are secretly the same.

## The Gaspard Monge Problem, Reinvented

The story begins in 1781, when the French mathematician Gaspard Monge posed a deceptively simple question: given a pile of dirt and a set of holes, what's the cheapest way to fill all the holes? "Cost" is proportional to distance times mass.

For two centuries, this remained a curiosity — elegant but isolated. Then in 1942, the Soviet mathematician Leonid Kantorovich reformulated the problem as a linear program and discovered something astonishing: the minimum cost of moving mass has a *dual* description in terms of price functions. You can compute the optimal shipping cost by finding the right set of prices instead of the right shipping plan. This duality principle would later earn Kantorovich a Nobel Prize in Economics.

In the early 2000s, researchers realized that the cost of the optimal transport plan — now called the *Wasserstein distance* — defines a genuine metric on the space of probability distributions. It measures how "different" two distributions are, not by comparing them point by point, but by asking: how much work would it take to reshape one into the other?

This insight revolutionized machine learning. Wasserstein distances power the GANs (generative adversarial networks) that create photorealistic images, the algorithms that detect distribution shift in deployed models, and the metrics that compare single-cell gene expression profiles in computational biology.

But there was a gap. Everyone knew the Wasserstein distance should be *intrinsic* — it should depend on the cost of moving mass, not on how you label the locations. If you rename "Beach A" to "Beach B" and vice versa, the optimal transport cost shouldn't change, as long as the physical distances between beaches are preserved.

This sounds obvious. But it had never been rigorously proved at the formal, machine-verifiable level. And as we'll see, the proof opens a door to something much deeper.

## The Relabeling Theorem

Consider a finite set of locations — say, three cities. You have a cost matrix telling you how expensive it is to move goods between each pair. You have two probability distributions over these cities (think: "where the goods are" and "where they need to be"). The Wasserstein distance is the minimum total cost over all possible shipping plans.

Now apply a relabeling: a bijection that renames the cities. If this relabeling preserves costs (the cost between any two cities is the same after renaming), then the Wasserstein distance between the relabeled distributions equals the original Wasserstein distance.

The proof works by showing that relabeling establishes a perfect one-to-one correspondence between the shipping plans before and after renaming, and that corresponding plans have identical costs. Since the Wasserstein distance is the minimum cost over all plans, and the two sets of plans have exactly the same costs, the minima must be equal.

This is not a trivial bookkeeping exercise. The set of shipping plans is a continuous, infinite set (a polytope in high-dimensional space), and showing that a bijection preserves both the structure of this set and the objective function requires careful reasoning about sums over finite types, reindexing of double sums, and the interaction between equivalences and infima.

## Enter the Tropics

Meanwhile, in a parallel mathematical universe, something strange was happening with arithmetic.

In the 1960s, the Brazilian mathematician Imre Simon began studying a peculiar algebraic system where "addition" means "take the minimum" and "multiplication" means "add." Under these rules:

- 3 "+" 5 = min(3, 5) = 3
- 3 "×" 5 = 3 + 5 = 8

This system, eventually called *tropical algebra* (named after Simon's home country), isn't just a curiosity. It's the natural language for optimization problems.

Why? Because in ordinary linear algebra, the inner product ∑ aᵢbᵢ captures weighted sums. In tropical algebra, the "inner product" min(a₁ + b₁, a₂ + b₂, ...) captures weighted minimization. Replace addition with minimum and multiplication with addition, and matrix algebra becomes a theory of shortest paths.

The tropical product of two matrices A and B gives you, at entry (i, j), the minimum cost of a two-step path from i to j. The tropical cube gives you three-step paths. The tropical n-th power gives you n-step paths. Diagonal entries of tropical powers tell you the minimum cost of round-trip journeys.

## The Subadditivity Discovery

Here's where the two theories start to converge.

Consider the diagonal entries of tropical matrix powers: let aₘ be the minimum cost of an m-step round trip from city i back to itself. The following inequality holds:

**a_{m+k} ≤ aₘ + aₖ**

In words: the cheapest (m+k)-step round trip costs no more than doing a cheapest m-step round trip followed by a cheapest k-step round trip.

This is the *subadditivity* property, and it's profound. A classical result known as Fekete's lemma says that any subadditive sequence has a well-defined limit: the ratio aₘ/m converges as m grows. This limit is the *tropical eigenvalue* — the best achievable average cost per step in an infinitely long cycling journey.

The proof of subadditivity proceeds in two stages. First, establish that tropical multiplication is associative — a fact that requires showing two nested minimizations over a finite set can be reordered. Second, show that tropical powers split: the (m+k)-fold product equals the m-fold product tropically multiplied by the k-fold product. Subadditivity then falls out immediately because the diagonal of a tropical product is bounded by the sum of the diagonals (just choose the "go through yourself" option in the minimization).

## The Bridge: Permutation Couplings

Now comes the unifying insight. When both distributions are uniform — equal probability on every location — the shipping plans include a special class: *permutation couplings*. Instead of splitting mass between multiple destinations, each location sends all its mass to exactly one other location, determined by a permutation.

The cost of a permutation coupling is the *assignment cost*: the sum of the costs along the permutation's matching. Finding the cheapest permutation coupling is the *assignment problem*, one of the foundational problems in combinatorial optimization.

And the assignment problem is exactly a tropical optimization problem. Minimizing over all permutations of a sum of matrix entries is what tropical algebra was built to do. The minimum assignment cost is, in tropical language, the tropical permanent of the cost matrix.

The bridge theorem makes this precise: the transport cost of a permutation coupling equals a scaled assignment cost, and this cost is invariant under conjugation by cost-preserving bijections. In other words, simultaneously relabeling the sources and destinations doesn't change the assignment cost, as long as the relabeling preserves the cost structure.

This is the same invariance principle seen in Wasserstein distance, but now expressed in purely combinatorial terms.

## One Principle, Two Theories

Step back and see the pattern. In optimal transport, you minimize a linear objective over a convex set of couplings, and the result is invariant under cost-preserving symmetries. In tropical algebra, you minimize over paths encoded as matrix products, and the algebraic structure (associativity, subadditivity) ensures the result is well-behaved.

Both theories are governed by the same meta-principle: **cost-preserving relabelings act isometrically.** Whether you're optimizing over couplings or over matrix products, the symmetry group of the cost function is the symmetry group of the optimization.

This isn't a metaphor. It's a theorem — or rather, a family of theorems with a common skeleton:

1. Define an optimization problem (minimize cost over plans, or minimize path weight).
2. Show that a bijection on the index set transforms feasible solutions to feasible solutions.
3. Show that the bijection preserves objective values.
4. Conclude that the optimum is invariant.

## Why This Matters

The convergence of transport and tropical theories has immediate practical implications.

**In machine learning**, Wasserstein distances are used to compare data distributions — but computing them is expensive. The symmetry theorem says you can reduce the computation by modding out the symmetry group of the cost function. If your cost is rotation-invariant, you only need to compare distributions up to rotation.

**In network optimization**, tropical matrix powers compute shortest paths, and the subadditivity theorem guarantees that average-cost-per-hop estimates converge. This gives rigorous bounds for network routing protocols without having to compute paths of every possible length.

**In operations research**, the bridge between transport and assignment problems means that algorithms designed for one can be repurposed for the other. The Hungarian algorithm for assignment problems becomes a Wasserstein distance computer; LP-based transport solvers become assignment optimizers.

**In pure mathematics**, the convergence hints at deeper structural connections. Both theories involve optimization over polytopes (the Birkhoff polytope of doubly stochastic matrices for transport; the permutohedron for tropical geometry). Both have duality theories (Kantorovich duality for transport; tropical spectral theory for min-plus algebra). The formal unification suggests these dualities might themselves be dual to each other.

## The Road Ahead

The theorems proved in this project are seeds, not endpoints. They open pathways to:

- **Kantorovich duality**: proving that the minimum shipping cost equals the maximum dual potential, a result that underpins virtually all computational optimal transport.
- **Tropical eigenvalue theory**: proving that the asymptotic cycle mean equals the minimum cycle mean over all cycles, connecting the subadditivity theorem to network scheduling.
- **Equivariant transport**: building Wasserstein distances on quotient spaces, enabling efficient computation for distributions with symmetries.
- **Algorithm verification**: proving correctness of the Hungarian algorithm, which simultaneously solves assignment problems and computes Wasserstein distances for uniform distributions.

Each of these directions sits at the intersection of multiple mathematical disciplines, and each has concrete applications in science and engineering.

## A New Language for Optimization

Mathematics progresses not only by proving new theorems but by recognizing when different theorems are saying the same thing. The most powerful moments in mathematical history — the unification of algebra and geometry by Descartes, the unification of electricity and magnetism by Maxwell, the unification of geometry and topology in modern algebraic geometry — occur when a common structure is recognized beneath apparently different surfaces.

The convergence of optimal transport and tropical algebra is a small example of the same phenomenon. It reveals that the act of finding the cheapest way to move resources and the act of finding the shortest path through a network are governed by identical algebraic and geometric principles. The "addition" in one theory becomes the "minimum" in the other; the "coupling" in one becomes the "permutation" in the other; but the invariance — the deep indifference to relabeling — is the same.

That indifference is not a limitation. It is the mathematical expression of a physical truth: the cost of moving goods depends on the landscape, not on the names you give to places. And recognizing that truth formally, rigorously, and computably is what transforms an intuition into a tool.
