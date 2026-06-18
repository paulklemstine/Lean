# The Illusion of Sharing: Why Shortcuts in Computation Might Be Impossible

## A Hidden Wall at the Heart of Computer Science

Imagine you're assembling a massive jigsaw puzzle. You notice that many pieces look identical—same color, same shape. "Why not reuse them?" you think. Instead of placing each piece individually, you could save time by building one copy and somehow referencing it in multiple locations.

This is exactly the gamble that lies at the heart of modern computing, and it leads to one of the deepest unsolved questions in all of mathematics: **When does sharing intermediate results actually speed things up, and when is it an illusion?**

The answer matters far beyond abstract mathematics. Every computer chip, every algorithm, every neural network relies on reusing computed values. The assumption that sharing helps is so fundamental that we barely question it. But a new line of mathematical research has produced a startling result: for an important class of computations, sharing provides *zero* depth advantage. The shortcut is a mirage.

## Trees, Graphs, and the Architecture of Thought

To understand the breakthrough, we need two pictures from computer science.

The first is a **tree**. Think of a family genealogy chart: each person has exactly two parents, each parent has two parents, and so on. In computing, a tree represents a calculation where every intermediate result is used exactly once. If you compute "3 + 5" and need the answer in two different places, you compute it twice—once for each place. Trees are simple, elegant, and inefficient.

The second is a **graph** (specifically, a directed acyclic graph, or DAG). This is the clever version. When "3 + 5" appears in two places, you compute it once and *share* the result. Modern computer chips are DAGs: billions of logic gates wired together, with outputs fanning out to multiple consumers. Sharing is what makes chips compact and fast.

The critical question is: **How much does sharing actually help?**

For *size*—the total number of operations—sharing can help enormously. A tree might need millions of nodes where a DAG needs only thousands. But what about *depth*—the longest chain of operations that must happen one after another? Depth measures the minimum time a parallel computer needs. Can sharing reduce depth?

If the answer is yes, then DAGs are fundamentally more powerful than trees in terms of speed. If the answer is no—if sharing cannot reduce depth for certain computations—then we get a powerful tool: any speed limit we prove for trees automatically applies to DAGs too.

## Monotone Computing: The Restricted Universe

The new results focus on a beautiful restricted world called **monotone computation**. In a monotone circuit, the only operations allowed are AND (both inputs must be true) and OR (at least one input must be true). No negation. No "NOT."

This isn't as restrictive as it sounds. Monotone circuits compute a huge and important class of functions. They determine network connectivity (is there a path from A to B?), matching (can every worker be assigned a task?), and threshold decisions (do at least *k* sensors agree?). Monotone computation also appears naturally in voting systems, reliability engineering, and database queries.

The restriction to monotone operations has a beautiful mathematical consequence: the output can only go from false to true, never the reverse, when any input flips from false to true. In the language of mathematics, the function is *order-preserving*. This connects circuit complexity to the rich world of lattice theory and partial orders—a bridge between engineering and pure mathematics.

## The Unfolding Trick

The key tool in the new research is an operation called **unfolding**. Take any DAG circuit and convert it back into a tree by duplicating every shared node. Wherever a gate's output fans out to multiple consumers, make separate copies—one for each consumer.

This is conceptually simple but has a remarkable property, now rigorously proven:

> **The unfolded tree has exactly the same depth as the original DAG.**

Not "at most" the same depth. Not "approximately." *Exactly* the same. Sharing can balloon the size of a computation, but it cannot—cannot—compress its depth.

This might seem obvious, but it is not. In general, transformations that change the structure of a computation can alter its depth in subtle ways. The proof requires careful induction on the topological structure of the DAG, tracking how each layer of gates maps to the corresponding layer in the tree. It's the kind of result that feels inevitable in hindsight but requires genuine mathematical work to establish rigorously.

## The Transfer Principle: Turning Tree Limits into Graph Limits

The depth-preservation theorem has a powerful corollary that complexity theorists have long dreamed about. Suppose you can prove a lower bound—a minimum depth requirement—for *tree-shaped* computations of some function. Since every DAG unfolds into a tree of the same depth, that lower bound *automatically transfers* to DAG computations.

In other words: **If no tree can compute your function quickly, then no graph can either.**

This is the *lower bound transfer principle*. It converts tree lower bounds (which are often accessible) into graph lower bounds (which are notoriously hard). The principle has been established with complete mathematical rigor, following a clean logical chain:

1. Any monotone DAG computing function *f* can be unfolded into a tree.
2. The unfolded tree computes the same function (semantic correctness).
3. The unfolded tree has the same depth (depth preservation).
4. Therefore, any depth lower bound for trees applies to DAGs.

Each step has been verified with absolute certainty—not "checked by hand" or "believed by experts," but certified through a chain of logic in which every inference is explicitly justified.

## Recursive Majority: A Spotlight on the Conjecture

The most tantalizing family of monotone functions is **recursive majority**. Take three bits and output the majority vote. Now apply this recursively: take nine bits, split them into three groups of three, compute majority of each group, then take the majority of the three results. Repeat.

Recursive majority is the cornerstone of fault-tolerant computing. If each sensor in a network has a small probability of error, recursive majority voting amplifies reliability exponentially: three levels of voting with 27 sensors can turn 80% individual accuracy into over 99% system accuracy.

The depth of a recursive majority circuit equals the number of levels of recursion. The transfer principle says: if no *formula* (tree) can compute recursive majority faster, then no *circuit* (DAG) can either. And indeed, computational experiments on small cases confirm that sharing provides no depth advantage whatsoever for recursive majority.

This leads to a bold conjecture: **recursive majority is depth-rigid**—its minimum circuit depth equals its minimum formula depth, with at most a small additive constant.

If true, this conjecture would mean that the natural recursive construction is essentially optimal. No clever sharing trick, no ingenious rewiring, can beat the straightforward approach. The function is "hard in the right way."

## Why This Matters: The P vs NP Connection

Circuit lower bounds are the final frontier of theoretical computer science. The question "P versus NP"—arguably the most important unsolved problem in mathematics—reduces to proving that certain functions require large circuits. Despite decades of effort, we can prove almost nothing about general circuits.

But monotone circuits are different. In the 1980s, Alexander Razborov proved groundbreaking lower bounds for monotone circuits computing the clique function. These results showed that monotone circuits for detecting cliques must be exponentially large—a genuine triumph. Yet extending these results to depth, or to broader classes of circuits, has remained stubbornly difficult.

The transfer principle offers a new angle of attack. Instead of wrestling directly with the combinatorial complexity of DAGs, we can focus on trees—which are structurally simpler and more amenable to analysis. Every tree lower bound becomes a DAG lower bound for free.

This doesn't solve P versus NP. But it opens a *formally verified route* toward lower bounds, one where each step is machine-checkable and each intermediate result can be trusted absolutely.

## Communication Games: The Deeper Bridge

Behind formula lower bounds lies an elegant connection to **communication complexity**, discovered by Mihail Karchmer and Avi Wigderson in 1990. They showed that the minimum depth of a Boolean formula computing a function *f* equals the communication complexity of a certain two-player game associated with *f*.

In this game, Alice receives an input where *f* is true, Bob receives an input where *f* is false, and they must find a coordinate where their inputs differ. The minimum number of bits they need to exchange is exactly the formula depth.

Combined with the transfer principle, this creates a three-step pipeline:

1. Prove a communication lower bound (using information-theoretic or combinatorial methods).
2. Transfer it to a formula depth lower bound (via Karchmer-Wigderson).
3. Transfer it to a circuit depth lower bound (via unfolding).

Each step preserves the lower bound. The pipeline converts an information-theoretic argument into a circuit complexity result—a bridge between two seemingly unrelated domains.

## The Role of Rigorous Proof

What makes this work distinctive is its emphasis on absolute rigor. Every theorem has been formalized with complete logical precision, using methods where each deduction is mechanically verified. There are no gaps, no hand-waving, no "it is easy to see that."

This matters because complexity theory is littered with failed proofs and retracted claims. The P versus NP problem has attracted hundreds of purported solutions, virtually all flawed. In such a landscape, machine-verified results provide a bedrock of certainty.

The formalization also serves a practical purpose: it creates reusable infrastructure. Future researchers can build on these verified foundations without re-proving basic lemmas. The transfer principle, once formalized, becomes a black box that any subsequent lower-bound proof can invoke with confidence.

## What Comes Next

Several concrete directions beckon:

**Testing depth rigidity.** Computational search can seek monotone circuits that compute recursive majority with less depth than the natural construction. If such circuits exist, the depth-rigidity conjecture fails, and we learn that sharing can sometimes help. If they don't exist up to large sizes, confidence in the conjecture grows.

**Tropical depth semantics.** Depth behaves like evaluation in a "tropical" arithmetic where addition becomes maximum and multiplication becomes addition. This algebraic perspective could yield new proof techniques—and connects circuit complexity to optimization theory and algebraic geometry.

**Broader function families.** Beyond majority, threshold functions, connectivity problems, and matching problems all await formal analysis. Each family tests the transfer principle in a new regime.

**The negation barrier.** Monotone circuits forbid negation. Understanding exactly where and why negation breaks the transfer principle would illuminate the boundary between what we can and cannot prove about computation.

## The Deepest Question

At its core, this research asks: **When is sharing real, and when is it an illusion?**

We share intermediate results constantly—in computation, in communication, in thought itself. Every time you use a previously established fact in an argument, you're sharing a subcomputation. Every time a chip reuses a signal, it's sharing.

For monotone computation, we now know: sharing cannot compress depth. The tree is as good as the graph, at least for the measure that matters most for parallel speed.

Whether this principle extends beyond monotone computation—whether there exist functions for which sharing provably helps or provably doesn't—remains one of the most profound open questions in the mathematical sciences. The tools are now in place to pursue it with unprecedented rigor.

The jigsaw puzzle, it turns out, cannot be solved faster by reusing pieces. Every piece must be placed in order, one layer at a time. The depth of the puzzle is the depth of the puzzle, no matter how clever you are about sharing.
