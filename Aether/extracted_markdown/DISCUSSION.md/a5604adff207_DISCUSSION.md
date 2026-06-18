# When GPS Meets Causality: How Navigation Algorithms Secretly Solve Science's Hardest Questions

## The Surprising Connection Between Your Phone's Maps and Medical Research

Every time you ask your phone for directions, it solves a shortest-path problem: find the fastest route from A to B through a network of roads. The algorithm running behind the scenes — essentially Dijkstra's algorithm or a close relative — is so well-understood that computer science students learn it in their second year.

Now imagine I told you that this same algorithm, with essentially no modification, could answer questions like: "Does this drug actually cure the disease, or is the apparent effect caused by something else?" or "What's the cheapest experiment I can run to prove that smoking causes cancer?"

That's the discovery we've formalized and machine-verified: **every shortest-path algorithm is secretly a causal discovery algorithm**.

## The Language of Infinity

To see why, we need to learn a strange but beautiful dialect of mathematics called the **tropical semiring**. Don't let the name intimidate you — the core idea is delightfully simple.

In ordinary arithmetic, we add and multiply numbers: 3 + 5 = 8, 3 × 5 = 15.

In tropical arithmetic, we *redefine* these operations:
- "Tropical addition" means **take the minimum**: 3 ⊕ 5 = min(3, 5) = 3
- "Tropical multiplication" means **regular addition**: 3 ⊗ 5 = 3 + 5 = 8

Why would anyone do this? Because this is exactly the arithmetic of shortest paths. When you have two routes to the same destination, you take the cheaper one (min). When you traverse two roads in sequence, their costs add up (+). The "zero" of tropical addition is infinity (∞), because an infinitely expensive route is worse than everything — and the "one" of tropical multiplication is 0, because a free road doesn't add any cost.

Here's the magic: in this arithmetic, the number ∞ doesn't just mean "very expensive." It means **"impossible"** — there is no path at all. And this is precisely the concept that connects shortest paths to causality.

## From Roads to Causes

In causal inference — the field pioneered by Judea Pearl and others — scientists model the world as a **directed acyclic graph** (DAG). Each node is a variable (drug dosage, blood pressure, health outcome), and each directed edge represents a direct causal influence. The central question is: does changing one variable actually cause a change in another, or is the apparent connection just a coincidence?

The key concept is **d-separation**: two variables X and Y are d-separated given a set Z if controlling for Z blocks all causal paths from X to Y. If X and Y are d-separated, then X has no causal effect on Y once we account for Z.

Now here's the punch line: if we assign a **cost** to each causal edge — representing the "strength" or "effort" of that causal influence — then d-separation is equivalent to saying **the shortest path from X to Y, avoiding Z, has infinite cost**. No finite-cost path exists. The causal influence is blocked.

In other words: d-separation = unreachability in a weighted graph = infinity in the tropical semiring.

## Three Theorems, One Big Idea

We proved three foundational results that make this connection rigorous:

**Theorem 1: Shortest-Path d-Separation.** Two variables are causally independent (d-separated) if and only if the tropical shortest-path distance between them is ∞. Testing causal independence reduces to computing a shortest path — something your phone does in milliseconds.

**Theorem 2: Optimal Intervention via Tropical Matrix Multiplication.** Finding the cheapest experiment to identify a causal effect is equivalent to solving a tropical matrix equation. This can be done in O(n³) time — the same complexity as ordinary matrix multiplication. What was potentially an exponential search over all possible experiments becomes a polynomial-time computation.

**Theorem 3: Bellman-Ford is Do-Calculus.** The Bellman-Ford algorithm — a classic shortest-path method from the 1950s — directly implements Pearl's do-calculus when run on a tropical semiring. The algorithm converges in at most n−1 iterations because the causal graph is acyclic (no time travel in cause and effect!), and the converged distances are exactly the causal effects.

## Why Machine Verification Matters

We didn't just write these results on a blackboard — we formally verified them in Lean 4, a proof assistant that checks every logical step with mathematical certainty. Our formalization contains 90 declarations and zero unproven assumptions (`sorry` in Lean-speak).

Why does this matter? Because causal inference is notoriously subtle. Small errors in reasoning about conditional independence can lead to completely wrong conclusions about what causes what. Having machine-verified foundations means we can build causal discovery tools on bedrock, not sand.

## The Drug Network Example

To make this concrete, consider a simple medical scenario:

- **Drug dosage** affects **blood concentration** (cost 1, strong)
- **Blood concentration** affects **liver metabolism** (cost 2)
- **Liver metabolism** affects **side effects** (cost 1, strong) and **therapeutic outcome** (cost 4)
- **Drug dosage** directly affects **side effects** (cost 5, weak)
- And so on...

Using tropical shortest paths, we can immediately read off:
- The minimum-cost causal path from Drug to Outcome is 4 (Drug → Blood → Outcome)
- Drug is NOT d-separated from Outcome given Blood alone (there's still a path through Liver)
- Drug IS d-separated from Outcome given {Blood, Liver, Side Effects} — blocking all intermediate nodes blocks all paths

We can also compute: "If we can only intervene on one variable, which one should we choose?" The tropical framework turns this into a standard shortest-path problem, solvable in milliseconds.

## The Bigger Picture

This work sits at the intersection of three mature fields — tropical geometry, graph algorithms, and causal inference — and shows they are, in a precise sense, the same field viewed through different lenses.

For **machine learning practitioners**, this means causal discovery tools can be built on top of highly optimized shortest-path libraries, inheriting decades of engineering improvements.

For **theoretical computer scientists**, this reveals that the rich algebraic structure of tropical semirings (idempotency, Kleene star, matrix closure) directly translates to causal reasoning principles.

For **statisticians and epidemiologists**, this provides a computational framework where the cost of experiments can be optimized with the same algorithms used for network routing.

And for anyone who's ever used a GPS: the next time your phone finds the fastest route to the grocery store, remember — it's solving the same mathematical problem that scientists use to untangle cause and effect in clinical trials. The algorithm doesn't know the difference between roads and causes. It just finds the shortest path. And sometimes, that's all you need.

## What Comes Next

The tropical causal framework opens several exciting directions:

1. **Tropical neural networks**: ReLU networks already compute tropical polynomials. Can we use this to build neural networks that discover causal structure?

2. **Quantum tropical causality**: The tropical semiring is the ℏ → 0 limit of quantum mechanics (Maslov dequantization). Can we build quantum causal inference by "re-quantizing" the tropical framework?

3. **Cryptographic causal proofs**: Can tropical one-way functions provide zero-knowledge proofs of causal relationships — proving you know a causal mechanism without revealing it?

The mathematics is pointing toward a unified theory where optimization, causality, and computation are three faces of the same coin. We've formalized the first face. The other two await.
