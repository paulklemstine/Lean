# The Hidden Grammar of Optimization: How Two Mathematical Languages Turned Out to Be One

## A Shipping Problem, a Jungle Algebra, and an Unexpected Merger

Imagine you manage a network of warehouses scattered across a country. Each warehouse holds a different amount of inventory, and each retail store needs a different amount of product. Your job is to ship goods from warehouses to stores at the lowest possible cost, where cost depends on the distance between each warehouse-store pair. This is the *optimal transport problem*, and it's been a workhorse of applied mathematics since the French engineer Gaspard Monge first posed it in 1781 — to figure out the cheapest way to move piles of sand.

Now imagine a completely different world: a bizarre arithmetic where addition means "take the smaller number" and multiplication means "add." In this upside-down algebra, 3 + 5 = 3 (because 3 is smaller) and 3 × 5 = 8 (because 3 + 5 = 8 in normal arithmetic). This is *tropical mathematics*, named half-jokingly after the Brazilian mathematician Imre Simon, and it has become one of the most surprisingly powerful frameworks in modern mathematics.

For decades, these two theories — optimal transport and tropical algebra — developed in separate departments, solved different problems, and attracted different communities. Transport theory lived in probability and analysis; tropical algebra lived in combinatorics and algebraic geometry. But a new body of mathematical work reveals something startling: they are dialects of the same language.

## The Shape of Fairness

To understand why this connection matters, consider what happens when you relabel your warehouses. Suppose you swap the names of Warehouse A and Warehouse B — painting new signs, updating the database. Nothing physical changes. The distances are the same. The costs are the same. The optimal shipping plan should be the same, just with the labels swapped.

This seems obvious, but it's mathematically profound. It says that the *geometry of optimal transport* doesn't depend on names — it depends only on the underlying cost structure. Mathematicians call this *invariance under symmetry*, and getting it right is surprisingly subtle.

The key insight is this: if you have a bijection — a perfect relabeling — that preserves all pairwise costs, then the optimal transport cost between any two distributions doesn't change. The set of feasible shipping plans gets reshuffled by the relabeling, but every plan maps to a plan of identical cost. Since you're looking for the cheapest plan, and the costs of all plans are unchanged, the minimum must be unchanged too.

This has now been proved with complete mathematical rigor, not just for simple cases, but for arbitrary cost-preserving bijections on arbitrary finite spaces. The proof works by constructing an explicit correspondence: for every shipping plan π between the original distributions, the "reindexed" plan π' — defined by π'(i,j) = π(e⁻¹(i), e⁻¹(j)), where e is the relabeling — ships between the relabeled distributions, has the same total cost, and the correspondence is reversible.

## When Minimum Means Multiply

Now enter the tropical world. In standard matrix multiplication, you compute each entry of the product by multiplying corresponding entries and summing. In tropical matrix multiplication, you compute each entry by *adding* corresponding entries and taking the *minimum*. Written out:

> (A ⊗ B)ᵢⱼ = min over all k of (Aᵢₖ + Bₖⱼ)

If this looks familiar, it should. When A represents a cost matrix — the cost of going from node i to node k — and B represents costs from k to j, then the tropical product gives you the cheapest way to go from i to j through any intermediate node. Tropical matrix multiplication *is* shortest-path computation in disguise.

What happens when you repeatedly multiply a matrix by itself in this tropical arithmetic? You get tropical powers, and they compute shortest paths of increasing length. The diagonal entry (A^⊗n)ᵢᵢ gives the minimum cost of a round-trip from node i back to itself using exactly n+1 steps.

Here's the key discovery: these diagonal entries satisfy a *subadditivity* inequality:

> cost of (m+k+1)-step round trip ≤ cost of m-step trip + cost of k-step trip

In other words, you can always concatenate two round trips and do at least as well as the best single long trip. This seems intuitive — concatenating two good routes gives at least a decent route — but the mathematical proof requires careful handling of the optimization structure.

Why does this matter? Because subadditive sequences have a remarkable property, known since the 1920s through a result by the Hungarian mathematician Michael Fekete: the average cost per step *always converges*. The limit

> λ = lim (A^⊗n)ᵢᵢ / n

exists and equals the *minimum cycle mean* — the cheapest average cost per step in any closed loop. This number λ is the **tropical eigenvalue** of the matrix, the tropical analog of the dominant eigenvalue in standard linear algebra. It governs the long-run behavior of the system: if you're routing packets through a network, scheduling tasks on machines, or timing signals through a digital circuit, the tropical eigenvalue tells you the asymptotic throughput.

## The Bridge

Here's where the two stories merge into one.

Consider the optimal transport problem between two *uniform* distributions on n points — say, n identical warehouses and n identical stores, each needing exactly 1/n of the total goods. The cheapest shipping plan in this special case must be a *permutation*: each warehouse serves exactly one store. The transport cost reduces to

> (1/n) × Σᵢ c(i, σ(i))

where σ is the permutation and c is the cost function. Finding the optimal transport plan becomes the *assignment problem*: find the permutation that minimizes the total cost.

And what optimizes over permutation costs? Tropical algebra. The minimum assignment cost is precisely a tropical permanent — a computation that lives natively in min-plus arithmetic.

The connection goes deeper. The invariance theorem for Wasserstein distance says that relabeling points by a cost-preserving bijection doesn't change the transport cost. Translated to the assignment world, this says that *conjugating* a permutation by a symmetry of the cost function doesn't change its assignment cost. In tropical language, this is a statement about the spectral invariance of tropical matrices under similarity transformations.

The bridge theorem proved in this work makes this concrete: the transport cost of a permutation plan under conjugation by e is exactly the transport cost of the original plan. The formula

> cost(e⁻¹ ∘ σ ∘ e) under c = cost(σ) under c

holds whenever c is invariant under e. This isn't just a philosophical connection — it's a precise mathematical identity linking transport symmetry to combinatorial optimization.

## Why You Should Care

These results may sound abstract, but they touch the infrastructure of modern life in ways you might not expect.

**Logistics and supply chains.** The assignment problem — which permutation of deliveries minimizes total distance? — is solved billions of times daily by routing algorithms. Understanding its symmetry structure helps reduce computational cost: if your problem has symmetries, you can solve a smaller problem and recover the full solution.

**Machine learning.** Wasserstein distances are increasingly used to compare probability distributions in generative AI models. The invariance theorem guarantees that these comparisons are robust to meaningless relabelings of features — a critical property for reliable AI.

**Circuit design.** The tropical eigenvalue — the minimum cycle mean — determines the maximum clock frequency of a digital chip. Proving subadditivity of tropical powers puts this engineering computation on rigorous mathematical footing.

**Network optimization.** Shortest-path algorithms are tropical matrix computations. The subadditivity theorem ensures that estimates improve predictably with more computation, a property essential for real-time routing protocols.

## The Deeper Pattern

What's really remarkable is the *reason* these connections exist. Both optimal transport and tropical algebra are theories of constrained minimization. Transport minimizes cost subject to marginal constraints (supply equals demand). Tropical algebra minimizes cost over path choices. The invariance principles in both cases say the same thing: *the minimum doesn't care about labels, only about structure.*

This is, in some sense, the mathematical version of a principle that pervades science: the laws of physics don't change when you rename your coordinate axes. Einstein built general relativity on this idea. Emmy Noether showed that every symmetry implies a conservation law. What's new here is the demonstration that these invariance principles operate not just in continuous physics, but in the discrete, combinatorial world of assignments, matchings, and networks — and that the connecting language is tropical.

The implications ripple outward. If transport and tropical algebra share invariance principles, then techniques from one field can be imported into the other. Duality theorems in transport (the celebrated Kantorovich duality) have tropical shadows. Spectral theory of tropical matrices has transport interpretations. The Birkhoff polytope — the convex hull of permutation matrices — is simultaneously a transport object and a tropical one.

## What Comes Next

The theorems proved in this cycle are the foundation, not the edifice. The natural next steps include:

- **Kantorovich duality**: proving the dual formulation of Wasserstein distance, connecting transport minimization to Lipschitz function maximization
- **Karp's theorem**: showing that the tropical eigenvalue equals the minimum cycle mean, completing the spectral picture
- **The Birkhoff-von Neumann theorem**: decomposing any doubly stochastic matrix into permutation matrices, revealing the extremal structure of the transport polytope
- **Verified algorithms**: proving correctness of the Hungarian algorithm, which computes optimal assignments and therefore Wasserstein distances

Each of these is now within reach because the foundational invariance and subadditivity results have been established. The bridge between transport and tropical is open; the traffic can begin to flow.

## Coda: The Unity of Optimization

Mathematics has a recurring pattern: theories that seem unrelated turn out to be facets of the same crystal. Number theory and geometry merged through algebraic geometry. Probability and analysis merged through measure theory. Now optimization theory is undergoing its own unification, as transport, tropical algebra, and combinatorial optimization reveal their shared DNA.

The theorems described here — that Wasserstein distance is invariant under cost-preserving symmetries, that tropical powers are subadditive, and that permutation couplings bridge the two — are early evidence of this unification. They suggest that the mathematics of "finding the best" has a universal grammar, independent of whether you're shipping goods, routing signals, or solving equations in a strange arithmetic where addition takes minimums.

The most surprising part? This grammar was hiding in plain sight, encoded in two theories that mathematicians had been developing independently for over two centuries. It just took looking at them from the right angle — and having the rigor to prove that the connection is real.
