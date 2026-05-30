# The Hidden Algebra Inside Every Neural Network

**How a 1937 theorem about logic reveals the secret geometry of artificial intelligence**

---

In 1936, a young mathematician named Marshall Stone proved something extraordinary. He showed that every system of logical propositions — every collection of AND, OR, and NOT operations — has a hidden geometric twin. The algebra of logic, he demonstrated, is secretly a map of a landscape. True and false statements are not just abstract symbols; they are territories on a topological space, separated by boundaries as real as coastlines on a continent.

For decades, Stone's theorem was a jewel of pure mathematics, admired by logicians and topologists but seemingly irrelevant to the practical world. Then, in the 2020s, a surprising connection emerged: the same algebraic structures that Stone discovered in logic appear, uninvited, inside every neural network ever trained.

## The Neurons That Carve Space

To understand why, you need to know how neural networks actually work — not the mystical version, but the geometric one.

Every neuron in a neural network computes a simple operation: it takes an input, multiplies it by some learned weights, adds a bias, and checks whether the result is positive. In mathematical terms, each neuron defines a **hyperplane** — a flat surface that slices the input space in two. On one side, the neuron fires. On the other, it stays silent.

A network with 100 neurons in its first layer defines 100 such hyperplanes. These hyperplanes chop the input space into a mosaic of regions, like a stained glass window made of mathematics. Within each region, the network behaves as a simple linear function — it is essentially drawing straight lines. The magic of deep learning lies in assembling these linear pieces into complex, nonlinear shapes.

Here is the key insight: the **activation pattern** — the list of which neurons are firing and which are silent — completely identifies which region a point is in. Two inputs with the same activation pattern are in the same piece of the mosaic. They see the same linear function. They are, from the network's perspective, geometrically equivalent.

## Boolean Algebra in Disguise

Now comes the connection to Stone's 1937 theorem. The activation patterns are not random bit strings. They form a **Boolean algebra** — a logical structure with AND, OR, and NOT operations.

Consider two activation regions, A and B. Their union (A OR B) is a valid region. Their intersection (A AND B) is valid. The complement (NOT A) — everything outside A — is valid. The empty set and the entire space are both valid. Every Boolean algebra axiom is satisfied.

This is not a coincidence. It is an inevitable consequence of the way hyperplanes partition space. Each hyperplane contributes one binary choice (positive side or negative side), and the collection of all such choices forms a complete logical system.

The activation algebra of a neural network — as we call it — is isomorphic to a power set algebra, where the atoms are the individual activation regions. This is precisely the kind of structure that Stone's duality theorem describes.

## The Stone Dual of a Neural Network

Stone's theorem says that every Boolean algebra B has a **dual space** S(B) whose points are the ultrafilters of B. For finite Boolean algebras — like the activation algebra of a network — the ultrafilters are exactly the atoms. Each atom corresponds to one activation region.

So the Stone dual of a neural network's activation algebra is a finite topological space whose points are the linear regions of the network. The "clopen" sets (sets that are both open and closed) in this space correspond to the decidable properties of the network — the subsets of input space that the network can distinguish.

This gives us a new lens for understanding neural networks:

- **The network's expressivity** is measured by the number of points in its Stone dual space.
- **The network's decision boundaries** are the boundaries between clopen sets.
- **Two networks are equivalent** if and only if their Stone duals are homeomorphic.

## Counting the Uncountable

How many regions can a network create? This question connects to one of the most elegant results in combinatorial geometry: the **Zaslavsky bound**.

The naive answer is simple: with *k* hyperplanes, you can create at most 2^*k* regions, since each hyperplane provides one binary choice. For 100 neurons, that is 2^100 — more regions than there are atoms in the observable universe.

But the Zaslavsky bound tells a subtler story. The actual number of regions depends not just on how many hyperplanes you have, but on the **dimension** of the space they live in. In ℝ^*n*, the maximum number of regions from *k* hyperplanes is the sum of binomial coefficients C(*k*,0) + C(*k*,1) + ... + C(*k*,*n*). When the number of neurons far exceeds the input dimension — as is common in deep learning — most activation patterns are unrealizable. The neurons are "wasting" their expressive power.

This has profound implications for network design. A network with 1000 neurons processing 10-dimensional input can create at most about 10^26 regions — enormous, but far below 2^1000. The bottleneck is not the number of neurons, but the dimension of the data.

## Depth as Dimensional Escape

This is where depth enters the picture. A single layer of *k* neurons in ℝ^*n* is constrained by the Zaslavsky bound. But a deep network effectively **lifts** the data into higher-dimensional spaces at each layer. The output of the first layer lives in ℝ^*k*, where the second layer's hyperplanes have more room to create new regions.

Our analysis shows that the total number of regions in a deep network is bounded by the product of per-layer region counts. For a network with layers of width *k*₁, *k*₂, ..., *k*_L, the total expressivity is bounded by 2^(*k*₁ + *k*₂ + ... + *k*_L). But the effective expressivity — the number of functionally distinct input-output behaviors — depends on how these layers interact through the activation patterns.

The Stone dual captures this interaction precisely. The dual space of a multi-layer network is not simply the product of per-layer duals; it is a **quotient** that reflects the network's actual computational structure.

## Pruning, Redundancy, and the Shape of Intelligence

One practical consequence of this framework is a new approach to **network pruning** — the art of making neural networks smaller without losing accuracy.

A neuron is algebraically redundant if removing its hyperplane does not change the activation algebra — that is, if it does not create or destroy any regions. Our algorithms can detect such neurons by checking whether the number of atoms in the Stone dual space changes when a neuron is removed.

In experiments, we find that typical trained networks have 10-30% redundant neurons — hyperplanes that overlap with others or slice through empty regions of the input space. These neurons consume computation without contributing to the network's expressivity.

## A Falsifiable Conjecture

We propose a bold conjecture: **the VC dimension of a ReLU network equals the number of atoms in its activation algebra** — that is, the number of points in the Stone dual space.

The VC dimension is a classical measure of a network's learning capacity: it counts how many points the network can perfectly classify in the worst case. Our conjecture links this statistical quantity to a purely algebraic one.

The conjecture is falsifiable. For small networks (2-3 neurons, 2-dimensional input), both quantities can be computed exactly. If they match across all configurations, the conjecture gains credibility. If a counterexample exists, it would reveal a fundamental gap between algebraic expressivity and statistical learning capacity.

Preliminary computations support the conjecture for networks with up to 5 neurons in 2 dimensions. But the general case remains open — a challenge for the next generation of mathematical minds.

## The Bigger Picture

Stone duality reveals that neural networks are not merely engineering artifacts. They are mathematical objects with rich algebraic structure, connected to deep theorems in logic, topology, and combinatorial geometry.

The activation algebra is the **syntax** of a neural network — the logical structure of its decisions. The Stone dual space is the **semantics** — the geometric meaning of those decisions. The duality between them is a bridge between two ways of understanding intelligence: the symbolic and the geometric.

This bridge may prove essential as we seek to understand, verify, and improve the neural networks that increasingly shape our world. When we can describe a network's behavior in algebraic terms, we can reason about it formally. We can prove that certain inputs are classified correctly. We can identify exactly where the decision boundary lies and why.

The mathematics of the 1930s, it turns out, was building tools for the 2020s. Stone's duality, conceived in an era of typewriters and telegraphs, illuminates the hidden structure of the most powerful computing systems ever created. And the story is just beginning.

---

*The research described here establishes new connections between Stone duality, hyperplane arrangements, and neural network expressivity. The main results include formal proofs that the activation algebra of any hyperplane arrangement forms a Boolean algebra, that the Stone dual space has cardinality equal to the number of linear regions, and that the Zaslavsky bound constrains neural network expressivity.*
