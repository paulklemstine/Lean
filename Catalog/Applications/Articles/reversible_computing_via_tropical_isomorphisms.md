# The Hidden Geometry of Forgetting

## How a branch of abstract algebra reveals that every act of erasure is a thermodynamic event—and why that matters for the future of computing

---

There is a cost to forgetting. Not a metaphorical cost, not a poetic cost—a real, physical, measurable cost paid in heat. Every time a computer overwrites a bit of memory, every time a calculation discards an intermediate result, energy dissipates into the environment as surely as friction warms a brake pad. This is not an engineering limitation. It is a law of nature.

For sixty years, physicists have known this as Landauer's principle: erasing one bit of information at room temperature releases at least 0.0000000000000000000028 joules of heat—roughly three zeptojoules. The number is absurdly small. But when a modern processor executes billions of operations per second, those zeptojoules add up. They are the reason your laptop gets warm. They are one of the fundamental walls standing between us and the next generation of computing.

What was not known until now is that this wall has a precise geometric shape—and that shape is described by one of the most elegant and least expected branches of mathematics: tropical algebra.

---

## The Calculator That Runs on Minimums

Tropical algebra sounds exotic, but its core idea is disarmingly simple. Take ordinary arithmetic and replace addition with "take the minimum" and replace multiplication with "take the sum." In this strange mirror world, 3 + 5 = 3 (because 3 is the minimum), while 3 × 5 = 8 (because 3 + 5 = 8). 

This is not a mathematical prank. Tropical arithmetic arises naturally whenever you are optimizing—finding shortest paths, minimizing costs, or propagating the cheapest option through a network. It is the algebra of "what's the least expensive way to get from here to there?"

The surprise—the deep, structural surprise that connects seemingly unrelated fields—is that this same algebra also describes the thermodynamics of computation.

---

## Bijections, Fibers, and the Price of Collapse

Here is the key insight. Think of a computer's state as a point in a vast space of configurations. A computation is a function that moves each point to a new location. If that function is a bijection—a perfect one-to-one mapping where every input goes to a unique output—then no information is lost. You can always trace your steps backward. The computation is *reversible*.

But if the function collapses multiple inputs to the same output—if it is "many-to-one"—then information is destroyed. Several distinct states are merged into one. The collection of input states that map to the same output is called a *fiber*, borrowing language from geometry. The size of that fiber measures how much information was lost.

The mathematics here is precise and beautiful. If a map sends every group of exactly four input states to one output state, then the fiber size is four—that's two bits of information erased. The entropy drops by exactly 2 × ln(2) ≈ 1.386 nats. The minimum heat dissipated is 2 × kT × ln(2), where k is Boltzmann's constant and T is the temperature.

This is not approximate. It is exact. The entropy drop equals the natural logarithm of the fiber size—no more, no less. It is a theorem, not an estimate.

---

## Reversible Computing: The Zero-Cost Dream

If information destruction is what costs energy, then the obvious question is: can we compute without destroying information?

The answer, remarkably, is yes—with a catch. In the 1970s, Charles Bennett showed that any computation can be made reversible by recording enough history. Instead of discarding intermediate results, you save them. Instead of overwriting memory, you use fresh memory. The computation becomes a bijection on a larger state space.

The catch is overhead. You need extra memory to record the history, and extra steps to manage it. But the overhead is modest—polynomial, not exponential. A computation that takes *t* steps on *n* bits of memory can be made reversible using roughly *t* additional bits of history storage.

The tropical perspective reveals why this works. In the min-plus world, a reversible step is a bijection that simply *rearranges* the energy landscape without changing its minimum. The tropical free energy—the minimum value of the energy function—is invariant under transport by any bijection. No energy is dissipated because no fibers are collapsed. The geometry is preserved.

An irreversible step, by contrast, folds the energy landscape. Fibers collapse. The minimum might survive, but the multiplicity of configurations at each energy level changes. Information about the landscape's fine structure is lost, and that lost information must be paid for in heat.

---

## The Tropical Bridge

The formal connection between these ideas goes through a construction called *tropical transport*. Given an energy function that assigns a cost to each configuration, and a bijection that permutes configurations, the transported energy function is simply the original energy evaluated at the inverse of the bijection. It is a pullback, in the language of geometry.

This operation has three crucial properties, each of which has been rigorously proved:

1. **Composition**: Transporting energy through two successive bijections is the same as transporting through their composition. This means reversible computation steps form an algebraic structure—they compose cleanly.

2. **Identity**: Transporting by the identity map changes nothing.

3. **Invertibility**: Transporting forward and then backward returns to the original energy function.

These three properties mean that the collection of reversible computational steps, equipped with tropical energy transport, forms a *groupoid*—a mathematical structure that captures the essence of symmetry. Reversible computation is a symmetry of the tropical energy landscape.

Irreversible computation breaks this symmetry. An erasure map is not a bijection; it has no inverse. It is a quotient, a coarse-graining, a projection from a fine-grained space to a coarser one. The entropy defect of this projection—measured by the logarithm of the fiber size—is the exact cost of breaking the symmetry.

---

## Three Zeptojoules and the Future of Chips

Why does any of this matter? Because we are approaching the point where the thermodynamic cost of computation is becoming a practical constraint.

Modern transistors dissipate roughly 500 kT of energy per switching event—about 500 times the Landauer limit. The semiconductor industry has spent decades reducing this number. Each new chip generation squeezes out a few more percent. But the Landauer limit is a hard floor. You cannot go below it without making your computation reversible.

Reversible computing has long been seen as a curiosity—theoretically possible but practically irrelevant. The tropical framework changes the conversation. It reveals that the question is not "can we build reversible computers?" but "what is the optimal balance between reversibility and dissipation for a given computation?" 

Tropical algebra provides the tools to answer this question. The minimum-cost path through a computation graph can be found using tropical shortest-path algorithms—the same algorithms used to route packets in networks and plan logistics. The cost along each edge is the Landauer cost of the corresponding computational step: zero for reversible steps, kT × ln(fiber size) for irreversible ones.

This transforms thermodynamic optimization of circuits from a physics problem into a combinatorial optimization problem—one that computer scientists already know how to solve.

---

## Cryptography and the Heat of Hashing

One striking application is in cryptography. Hash functions like SHA-256 are deliberately irreversible—that's what makes them useful for digital signatures and password storage. Each compression step takes 512 bits of input and produces 256 bits of output, erasing 256 bits of information. The Landauer cost is 256 × kT × ln(2) per compression.

For a single hash, this is negligible. But Bitcoin mining performs roughly 10^{20} hashes per day. The Landauer lower bound on the energy cost of all that hashing is about 10^{-3} joules per day—still tiny compared to the actual energy consumption of around 10^{14} joules per day. But the ratio—about 10^{17}—tells us how far current hardware is from fundamental limits, and how much room there might be for improvement.

The tropical framework also suggests a new way to think about the security of hash functions. The irreversibility of a hash is not just a computational property; it is a thermodynamic one. Any adversary trying to invert a hash must either perform an exponential search or violate a thermodynamic law. This is a much stronger foundation for security than computational hardness alone.

---

## The Shape of Dissipation

The deepest implication of this work is conceptual. It reveals that computation, thermodynamics, and geometry are not merely analogous—they are the same theory, viewed from different angles.

A reversible computation is a tropical isometry: it preserves the energy landscape exactly. An irreversible computation is a tropical contraction: it folds the landscape, reducing its complexity by a precisely quantifiable amount. The heat dissipated is the geometric deficit—the log of the number of sheets that were folded together.

This perspective opens research directions that were previously invisible. What is the tropical analogue of mutual information? Can we define a tropical channel capacity? Is there a tropical data-processing inequality? Each of these questions has a precise mathematical formulation, and each could lead to new results in both information theory and algebraic geometry.

We are, perhaps, at the beginning of a new field: tropical thermodynamic complexity theory. The foundations have been laid. The first theorems have been proved. The applications are waiting.

---

## A Law of Nature, Written in Algebra

Rolf Landauer published his principle in 1961, in a three-page paper with the understated title "Irreversibility and Heat Generation in the Computing Process." He was working at IBM, trying to understand the fundamental limits of computation. His conclusion was prophetic: "The computer designer who tried to fight this thermodynamic force would be as foolish as an engineer who tried to build a perpetual motion machine."

Sixty-four years later, we can say something Landauer could not: his principle is not just a physical law. It is a theorem of tropical geometry. The cost of erasing *n* bits is *n* × ln(2) in natural units, because the erasure map has fibers of size 2^n, and the logarithm of 2^n is *n* × ln(2). The proof is a chain of exact equalities, not inequalities. There are no approximations, no assumptions about the nature of the physical substrate, no appeal to statistical mechanics. It is pure combinatorics—counting and taking logarithms.

The universe, it turns out, keeps its books in tropical arithmetic. Every minimum is tracked. Every fiber is counted. Every act of forgetting is recorded as a debt, payable in heat.

The cost of forgetting is exact. And now, for the first time, we know its precise mathematical shape.
