# Why Shortcuts Can't Shrink Every Mountain

## The surprising mathematics of computational depth

Imagine you're organizing a relay race. Four runners carry a baton in sequence: Alice hands to Bob, Bob to Carol, Carol to Dave. The total time depends on the slowest handoff chain — no matter how many backup runners you add on the sidelines, you can't make Alice hand off to Dave any faster. The baton *must* pass through every pair of hands in order.

Now imagine the same principle, but applied to mathematical computation. When a computer evaluates a complex expression like exp(exp(exp(x))), each exponential must wait for the one inside it to finish. The innermost exp(x) runs first. Then exp of that result. Then exp of *that* result. Three sequential steps, no shortcuts possible.

Or so mathematicians believed. But is that really true? What if there were a clever trick — some way of sharing intermediate results, reusing partial computations, or restructuring the calculation — that could collapse those three steps into two?

A new mathematical result answers this question definitively: **no such trick exists.** And the proof reveals something profound about the nature of computation itself.

---

## The Art of Sharing

To understand what's at stake, consider a simpler example. Suppose you need to compute

> exp(exp(x)) + exp(exp(x))

The naive approach computes exp(exp(x)) twice — a waste. A smart compiler recognizes the duplication and computes exp(exp(x)) once, stores the result, and adds it to itself. This optimization, called *common subexpression elimination* (CSE), is one of the oldest and most powerful tricks in computer science. It reduces the total work by eliminating redundant computations.

Engineers use CSE constantly. Every modern compiler does it. Every symbolic algebra system exploits it. The savings can be dramatic: expressions that would take exponential time to evaluate naively can sometimes be collapsed to polynomial time through intelligent sharing.

But here's the subtle question that mathematicians rarely asked until recently: **does sharing reduce the *depth* of a computation, or only its *size*?**

The size of a computation is the total number of operations. The depth is the length of the longest chain of operations where each depends on the previous one — the *critical path*. In our relay race analogy, size is the total number of runner-steps, while depth is the number of baton handoffs that must happen in sequence.

---

## Towers of Exponentials

The expression family at the heart of this story is deceptively simple:

- Level 0: x
- Level 1: exp(x)
- Level 2: exp(exp(x))
- Level 3: exp(exp(exp(x)))
- Level n: exp applied n times to x

These *iterated exponentials* grow unimaginably fast. By level 4, even modest inputs produce numbers so large they overflow any computer. But the growth rate isn't what matters here — it's the *structural complexity*.

Each level requires one more sequential exponential operation than the last. Level 3 needs three exponentials in a chain. You might compute other things in parallel alongside this chain — multiplications, additions, other exponentials — but that central chain of three nested exponentials seems unavoidable.

The question is whether "seems unavoidable" is actually "is unavoidable."

---

## Trees and DAGs

Mathematicians think about computations in two ways. A *tree* is the straightforward representation: each operation has its own copy of every subexpression it needs. No sharing. A *DAG* (directed acyclic graph) allows sharing: the same subexpression can feed into multiple operations without being recomputed.

The difference between trees and DAGs captures exactly the power of common subexpression elimination. A DAG is what a compiler produces when it optimizes a tree by identifying and merging duplicate subexpressions.

It was already known that in the *tree* model, computing the level-n iterated exponential requires tree depth at least n. This is the *tree depth hierarchy theorem*: you can't build a shallower tree that computes the same function, at least in a natural computational language that combines multiplication and exponentiation without division.

But trees are rigid. The real question is: what happens when you allow sharing?

---

## The Breakthrough

The new result proves that **sharing does not help.** Specifically:

> *For every computation graph (DAG) that computes the level-n iterated exponential using only multiplication, addition, negation, and the operation a·exp(b) — no division allowed — the graph's critical-path depth must be at least n.*

In other words, no matter how cleverly you share subexpressions, you cannot reduce the sequential depth below n. The canonical chain of n exponentials is already optimal — not just among trees, but among all possible DAGs.

This is surprising because sharing *does* reduce other measures of complexity. The total size of a DAG can be much smaller than the corresponding tree. For expressions involving many copies of the same subexpression, the savings are exponential. Yet this enormous compression in size buys you exactly *nothing* in terms of depth.

---

## How the Proof Works

The proof strategy is elegant in its simplicity. It consists of one key insight: **any DAG can be "unfolded" back into a tree without increasing depth.**

Here's the idea. Take any DAG — no matter how much sharing it exploits — and systematically replace every shared reference with a fresh copy of the subexpression it points to. The result is a tree. This tree may be enormously larger (exponentially so), but its depth is no greater than the original DAG's depth. And it computes exactly the same function.

Why doesn't unfolding increase depth? Because depth tracks the longest *dependency chain*, not the total number of operations. When you duplicate a shared subexpression, you create more copies of the same operations, but you don't lengthen any chain. Each copy has the same depth as the original.

Once you have a tree with the same depth, you can apply the existing tree depth hierarchy theorem. That theorem says: no tree of depth less than n can compute the level-n iterated exponential. Since the unfolded tree has depth at most the DAG's depth, the DAG must have depth at least n. Done.

---

## Why It Matters

This result sits at the intersection of several important fields.

**Compiler optimization.** Every compiler performs common subexpression elimination. The theorem says there are functions for which this optimization — while valuable for reducing total work — cannot reduce the minimum execution time on a parallel machine. No compiler can break the sequential bottleneck for this family of functions.

**Parallel computing.** The critical-path depth of a computation graph determines the minimum time needed to evaluate it, even with unlimited processors. The theorem says iterated exponentials have an inherent sequential barrier: n exponentials require n time steps, no matter how much parallelism is available.

**Circuit complexity.** In theoretical computer science, the distinction between "formulas" (trees) and "circuits" (DAGs) is fundamental. Circuits can be exponentially smaller than formulas computing the same function. The big question is: can circuits also be shallower? For many computational models, this remains open. The new result answers it for one natural model: circuits cannot be shallower than formulas for this explicit function family.

**Symbolic computation.** Computer algebra systems routinely manipulate expressions involving exponentials and logarithms. The theorem provides a rigorous lower bound on how efficiently these systems can represent certain expressions — a bound that no amount of clever data structure design can circumvent.

---

## The Bigger Picture

The result is an instance of a broader principle that appears throughout mathematics and computation:

> **Sharing compresses duplication, not dependency.**

You can reuse results to avoid redundant work. But you cannot reuse results to break genuine sequential dependencies. If computation B truly depends on the output of computation A, no amount of restructuring eliminates the need to do A before B.

This principle is intuitive, but formalizing it rigorously is hard. The mathematical challenge is showing that there truly is no clever restructuring that eliminates the dependency — that the sequential chain of exponentials is *inherent* to the function being computed, not merely an artifact of how we happened to write it down.

The proof accomplishes this by connecting two mathematical worlds: the world of *graphs* (DAGs with shared subexpressions) and the world of *analysis* (growth rates of iterated exponentials). The bridge between them is the unfolding operation, which translates structural questions about graphs into analytical questions about function growth — questions that were already answered by the tree hierarchy theorem.

---

## What Comes Next

The result opens several tantalizing directions. Can the same principle be extended to other function families? Are there computation models where sharing *does* reduce depth, and if so, what makes them different? Can the bounds be tightened to account for approximate computation?

Perhaps most intriguingly, the result connects to deep open problems in computational complexity. The question of whether sharing reduces depth for general computations — not just exponential towers — is closely related to longstanding questions about the relationship between formula size and circuit depth, questions that have resisted decades of attack.

For now, the theorem stands as a clean, beautiful answer to a clean, beautiful question: can clever tricks compress the depth of iterated exponentiation?

The mountain cannot be shrunk.
