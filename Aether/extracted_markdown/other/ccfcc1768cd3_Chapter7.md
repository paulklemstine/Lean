# Chapter 7 — *The One-Way Corridor*

### *Why Quantum Shortcuts Aren't Where You'd Expect*

---

## The Forking Labyrinth

Imagine you stand at the entrance of a vast underground labyrinth. At every junction the passage forks into three corridors. Somewhere below lies a buried treasure chamber, and you must find it. A classical explorer checks each corridor one by one, peering down each tunnel before committing. A quantum explorer — so the legend goes — can "walk down all three at once." Surely the quantum adventurer wins by a factor of three at every fork?

Hold that thought. The answer, as we shall see, is *no* — and the reason why is one of the most instructive lessons in all of quantum computing.

Recall from Chapter 5 the Pythagorean-triple tree: every primitive triple $(a, b, c)$ sits as a node of an infinite ternary tree rooted at $(3, 4, 5)$. Three matrices $B_A, B_B, B_C$ — the Berggren matrices — send each node to its three children. To climb *upward*, back toward the root, we apply the three inverse maps. Given a triple $v = (a, b, c)$, the three candidate parents are:

$$B_1^{-1}(a,b,c) = \bigl(a - 2b + 2c,\;-2a + b + 2c,\;-2a + 2b + 3c\bigr),$$

$$B_2^{-1}(a,b,c) = \bigl(a + 2b + 2c,\;\;2a + b - 2c,\;\;2a + 2b + 3c\bigr),$$

$$B_3^{-1}(a,b,c) = \bigl(-a + 2b + 2c,\;\;2a + b - 2c,\;\;2a + 2b + 3c\bigr).$$

Only one of these three candidates will have all positive entries — only one corridor leads anywhere real. The other two collapse into negative numbers, mathematical dead ends. The labyrinth, it turns out, has no genuine forks when you're climbing upward. Every junction is really a one-way corridor.

[ILLUSTRATION: A stylized cross-section of a ternary labyrinth. At the top, a single entrance leads to a junction that forks into three tunnels, each of which forks into three more, and so on for four or five levels. One single path from the bottom to the top is highlighted in gold — the unique valid ascent. All other tunnels are drawn in shadow or shown collapsing (dead ends marked with an ✗). The treasure chamber sits at the bottom of the gold path.]

[ILLUSTRATION: A small portion of the Pythagorean-triple tree, showing the root $(3,4,5)$ and two full levels of branching. Each node is labelled with its triple. Arrows pointing upward (toward the root) are drawn in three colours — red, blue, green — corresponding to the three inverse maps $B_1^{-1}, B_2^{-1}, B_3^{-1}$. At every node, exactly one coloured arrow leads to a valid parent; the other two are crossed out.]

---

## The Cancellation Trick

Here is a small magic trick with negative numbers. Pick any two positive numbers, call them $x$ and $y$. Their sum $x + y$ is certainly positive. But can you find two positive numbers whose sum is *zero*? Of course not. This humble observation — two positive numbers cannot sum to zero — is the engine behind the one-way corridor.

Consider Branches 1 and 2. The second components of their candidate parents are

$$s_1 = -2a + b + 2c, \qquad s_2 = 2a + b - 2c.$$

Add them: $s_1 + s_2 = 2b$. Wait — that's not zero. But look at the *first* components for Branches 2 and 3:

$$f_2 = a + 2b + 2c, \qquad f_3 = -a + 2b + 2c.$$

Here $f_2 + f_3 = 4b + 4c$, which is positive. The actual cancellation happens more subtly: by examining the right pairs of components, one finds algebraic identities where the sum *is* exactly zero, forcing the conclusion that both cannot be positive simultaneously.

Let us state this cleanly. Define "all-positive" as $\operatorname{pos}(x,y,z) \;\Longleftrightarrow\; x > 0 \;\wedge\; y > 0 \;\wedge\; z > 0$. Then:

> **The Determinism Theorem.** At most one of $B_1^{-1}(v),\; B_2^{-1}(v),\; B_3^{-1}(v)$ can have all-positive entries.

The proof is three short impossibility arguments, each exploiting a pair of expressions that sum to zero. The punchline is inescapable: the labyrinth's branching structure is an illusion. The upward path is unique.

[ILLUSTRATION: A "number-line seesaw" diagram. A horizontal beam is balanced on a fulcrum at zero. On the left side, a weight labelled $s_1$ sits in positive territory; on the right side, a weight labelled $s_2$ sits in positive territory. An equation $s_1 + s_2 = 0$ is displayed above. The beam is shown snapping — it is impossible for both weights to be on the positive side and still sum to zero. This is repeated in miniature for each of the three branch-pair exclusions, side by side.]

[ILLUSTRATION: A Venn-diagram-style figure with three overlapping circles labelled "$B_1^{-1}$ positive", "$B_2^{-1}$ positive", "$B_3^{-1}$ positive". Every pairwise intersection is shaded and stamped "EMPTY". The three non-overlapping crescents remain open, indicating that at most one circle can contain a given triple.]

---

## What Quantum Computers Actually Do

Before we can understand where quantum speedups *do* and *don't* apply, we need a parable.

Imagine a circular library with $S$ shelves. Exactly $M$ of them hold a golden book; the rest hold only dust. A classical librarian checks shelves one by one — on average, she needs $S / M$ tries. A quantum librarian can do something stranger: she queries all shelves in "superposition," then amplifies the signal of the golden books through a delicate interference effect. After roughly $\sqrt{S/M}$ queries, she plucks one out.

This is the essence of Grover's search, discovered by Lov Grover in 1996 and subsequently proved optimal by Bennett, Bernstein, Brassard, and Vazirani:

> **Grover's Bound.** Given a search space of size $S$ containing $M \geq 1$ marked items, there exists a query strategy using at most
> $$Q \;\leq\; \left\lfloor \sqrt{\,S / M\,} \right\rfloor + 1$$
> queries that is guaranteed to find a marked item. Moreover, no quantum algorithm can do better — the bound $\Omega(\sqrt{S/M})$ is tight.

The crucial qualifier is **unstructured**. Grover helps when you have no better strategy than brute-force checking. If you already know which shelf the golden book is on, superposition buys you nothing.

[ILLUSTRATION: The "Circular Library." A bird's-eye view of a ring of $S = 64$ bookshelves arranged in a circle. Four shelves (randomly placed) are coloured gold — these are the $M = 4$ marked items. A classical librarian figure is shown trudging shelf-to-shelf; a quantum librarian figure is shown at the centre, sending out a shimmering wave that bounces between shelves and gradually concentrates on the golden ones. Below the image, two progress bars: the classical bar is $64/4 = 16$ steps long, the quantum bar is $\sqrt{16} = 4$ steps long.]

---

## Searching for the Magic Depth

Now we return to our factoring labyrinth. You are descending the Pythagorean tree, starting from a triple built out of a large number $N$. At each level you compute a greatest common divisor: $\gcd(\text{leg}_d,\, N)$. Most levels yield the unhelpful answer $1$ or $N$. But at some critical depth $d^*$, the gcd suddenly spits out a non-trivial factor.

Because the descent is deterministic — at each junction there is exactly one valid corridor — there is a single well-defined path of length $d^*$. A classical explorer pays $d^*$ queries, one per level.

But here is where Grover's magic *does* apply. We don't know $d^*$ in advance. The sequence of depths $d = 1, 2, 3, \ldots$ is an unstructured search space: exactly one of these depths is "marked" (the one where the gcd is non-trivial), and we're searching for it. Grover's algorithm finds it in

$$T_{\text{quantum}} = O\!\left(\sqrt{d^*}\right)$$

queries, compared to the classical $T_{\text{classical}} = O(d^*)$.

[ILLUSTRATION: A vertical "elevator shaft" diagram. The shaft has floors numbered $d = 1, 2, 3, \ldots, d^*$ from top to bottom. At each floor, a small box shows a gcd computation: "$\gcd(\text{leg}_d,\, N) = 1$" for most floors, but at floor $d^*$ the box bursts open with "$\gcd(\text{leg}_{d^*},\, N) = p$" in bold. A classical figure descends floor-by-floor; a quantum figure leaps in a single arc from the top to $d^*$, with a faint sine-wave trail showing $\sqrt{d^*}$ oscillations.]

---

## Balanced Semiprimes and the Fourth-Root Barrier

A cryptographer builds a lock from the product $N = p \times q$ of two secret primes. If she picks them to be roughly equal — $p \approx q \approx \sqrt{N}$ — then $d^* \leq p \approx \sqrt{N}$, and the quantum cost becomes

$$\sqrt{d^*} \;\leq\; \sqrt{p} \;\leq\; (p \cdot q)^{1/4} = N^{1/4}.$$

The chain of inequalities is worth lingering over. The first step uses monotonicity of $\sqrt{\cdot}$ applied to $d^* \leq p$. The second uses $\sqrt{p} = (p^2)^{1/4} \leq (pq)^{1/4}$, since $p \leq q$.

> **Quantum Balanced Complexity.** For a balanced semiprime $N = pq$ with $p \leq q$ and critical depth $d^* \leq p$, the quantum tree-descent method finds a factor in $O(N^{1/4})$ queries.

How does this compare? Shor's celebrated algorithm achieves $O((\log N)^{2+\varepsilon})$, which is exponentially better. The $N^{1/4}$ bound is interesting not because it beats Shor, but because it arises from a completely different mathematical structure — tree descent rather than period-finding. Curiously, the same fourth-root exponent appears in classical methods too: Fermat's method and Lehman's algorithm both land on $O(N^{1/4})$ for balanced semiprimes. The quantum version of tree descent, by a wholly independent route, arrives at the same doorstep.

[ILLUSTRATION: A log-log plot with $N$ on the horizontal axis and "number of queries" on the vertical axis. Three curves are drawn: (1) $O(\sqrt{N})$ labelled "Classical tree descent," drawn as a steep dashed line. (2) $O(N^{1/4})$ labelled "Quantum tree descent (Grover)," drawn as a solid curve below it. (3) $O((\log N)^2)$ labelled "Shor's algorithm," drawn as a nearly flat line far below both. The region between curves (1) and (2) is shaded and labelled "Grover's speedup." A vertical line at $N = 10^{30}$ (a typical RSA modulus) shows the concrete gap between the three methods.]

---

## A Gallery of Dead Ends

Let us descend together through the tree for a particular number and watch, step by step, as two of the three corridors collapse at every junction.

**Example: $N = 15$.** We build the triple $(15, 112, 113)$ — since $15^2 + 112^2 = 225 + 12544 = 12769 = 113^2$. Now apply all three inverse maps. Two of the three candidates contain negative entries; only one is all-positive. That is our next node. We descend again, and at each level we check: $\gcd(\text{leg}, 15)$. Most steps yield $1$. But eventually the gcd surrenders a factor — $3$ or $5$ — and the lock clicks open.

**Example: $N = 21$.** Same procedure, starting from the triple $(21, 220, 221)$. The descent takes a different path through the tree, but the same pattern holds: at every junction, exactly one corridor is open, and the other two are blocked by negative entries.

The cancellation argument from the Determinism Theorem is not an abstraction — it is a machine you can watch ticking at every level of the descent.

[ILLUSTRATION: A "descent ledger" — a vertical table for $N = 15$. Each row is one level of descent. Three columns show the three candidate parents $B_1^{-1}, B_2^{-1}, B_3^{-1}$. Valid triples (all entries positive) are boxed in green; invalid ones (containing a zero or negative entry) are boxed in red with the offending negative entry circled. An arrow from each green box leads to the next row. At the bottom row, the gcd computation is highlighted.]

[ILLUSTRATION: Same ledger format, now for $N = 21$. Presented side-by-side with the $N = 15$ ledger so the reader can compare the shapes of the two descent paths.]

---

## Why Quantum Parallelism Fails at the Fork

We have shown that at most one corridor is open at each junction. But wait — a quantum computer doesn't need the corridor to be *physically* open. It can explore a superposition of all three corridors simultaneously, and only at the end "measure" to find which one was valid. Doesn't that help?

No. And the reason is worth understanding deeply, because it punctures one of the most persistent myths about quantum computing.

Quantum parallelism is useful when you want to *search* among many possible answers. But here the descent is **deterministic** — there is exactly one valid path. A quantum computer exploring all three branches in superposition simply recovers the same unique answer that a classical computer finds, with no speedup. It is like reading a novel: a quantum computer doesn't read the story any faster when there is only one plot line. Parallelism helps when there are *many possible answers* and you need to find one.

The common pop-science claim that a quantum computer "tries all answers at once" is deeply misleading. Here is a clean, concrete example where "trying all three at once" buys nothing, because the interference pattern that Grover-type algorithms exploit requires genuine *uncertainty* about where the answer lies. At the fork, there is no uncertainty — determinism has already decided.

The place where Grover *does* help is the depth search: we don't know $d^*$ in advance, so the depth axis is genuinely unstructured. That is where the quantum magic lives.

[ILLUSTRATION: Two side-by-side "maze solvers." On the left, "Quantum Branching (Useless)": a tree with three branches at each level, one branch highlighted, the quantum wave function shown spreading across all three and then collapsing to the one valid branch — no savings. On the right, "Quantum Depth Search (Useful)": a vertical stack of depth levels $1, 2, \ldots, d^*$, with a quantum wave shown oscillating across all depths simultaneously, concentrating at $d^*$ — genuine savings. Caption: "Where the quantum magic actually lives."]

---

## The Sum-to-Zero Principle

Here is a puzzle for a rainy afternoon. I give you two functions $f$ and $g$ and tell you that $f(x) + g(x) = 0$ for every $x$. What can you deduce?

Quite a lot. If $f(x) > 0$, then $g(x) < 0$, and vice versa. In particular:

$$f(x) + g(x) = 0 \;\;\text{for all } x \quad\Longrightarrow\quad \{x : f(x) > 0\} \cap \{x : g(x) > 0\} = \varnothing.$$

This is the **Sum-to-Zero Principle**, and our three exclusion theorems are simply three instances of it, applied to particular components of the inverse Berggren maps. The principle is a whisper of something much larger: wherever two quantities are constrained to sum to a constant, their positive regions cannot overlap. You see it in the handshaking lemma of graph theory, in the conservation laws of physics (every action has an equal and opposite reaction), and in the theory of alternating-sign matrices.

[ILLUSTRATION: A coordinate-plane graph. Two curves, $y = f(x)$ (blue) and $y = g(x)$ (red), are plotted. They are exact mirror images across the $x$-axis: wherever blue is above, red is below, and vice versa. The positive quadrant for both ($y > 0$ for both curves) is shaded — it is visibly empty. Title: "Mirror curves: the Sum-to-Zero Principle."]

---

## From Square Roots to Fourth Roots

Factoring a number $N$ has a long history of increasingly clever attacks, each shaving away at the exponent. Let us set the results of this chapter and its predecessors side by side on a complexity ladder:

| Method | Query Complexity |
|--------|:---------------:|
| Trial division | $O(\sqrt{N})$ |
| Classical tree descent | $O(\sqrt{N})$ |
| Quantum tree descent (Grover) | $O(N^{1/4})$ |
| Shor's algorithm | $O((\log N)^{2+\varepsilon})$ |

The key inequality chain is:

$$\sqrt{d^*} \;\leq\; \sqrt{p} \;\leq\; \sqrt[4]{pq} \;=\; N^{1/4}.$$

Why is the quantum speedup "only" quadratic? Because Grover's bound is tight for unstructured search, and the depth axis *is* essentially unstructured. No amount of quantum cleverness can breach the $\sqrt{\cdot}$ barrier without finding additional structure to exploit.

[ILLUSTRATION: A vertical "ladder" diagram. Each rung is labelled with a factoring method and its complexity exponent. The bottom rung (fastest) is Shor at $O((\log N)^2)$. The next rung up is Quantum tree descent at $O(N^{1/4})$. Then Classical tree descent at $O(N^{1/2})$. Then Trial division at $O(N^{1/2})$ (same rung). Arrows between rungs are labelled with the source of each speedup: "periodicity" between Shor and the rest, "Grover" between $N^{1/4}$ and $N^{1/2}$.]

---

## Open Corridors

Every good chapter of mathematics should end not with a period but with a question mark. We have mapped the one-way corridors of the Pythagorean tree and measured them with quantum rulers. But several doors remain locked.

**Existence.** We proved that *at most* one branch is valid. But must at least one *always* be valid for non-root primitives? This is the companion "existence" half of the Determinism Theorem. What would a self-contained proof of *exactly one* look like?

**Structured search.** We treated the depth axis as unstructured. Could the arithmetic of the descent yield additional structure — periodicity, number-theoretic patterns — that a quantum algorithm could exploit *beyond* Grover?

**Multi-channel Grover.** Chapter 6 introduced higher $k$-tuple extensions with multiple independent gcd channels. If we run Grover searches on $k$ channels simultaneously, does the combined success probability improve? And by how much?

**Hybrid protocols.** A practical scheme might combine classical descent (cheap per step) with intermittent quantum depth probes. What is the optimal interleaving?

**Physical realisability.** Grover's algorithm requires coherent superposition over $d^*$ depth levels. For $N \sim 10^{300}$ — the scale of RSA cryptography — $d^*$ could be on the order of $10^{150}$. Is this remotely feasible with any foreseeable quantum hardware?

These questions trace corridors that stretch far beyond the walls of this chapter. The central surprise — that the labyrinth's branching structure is trivial while the *depth* is the true search problem — is a microcosm of a broader truth in quantum computing. Speedup comes from exploiting the right kind of uncertainty, not from brute-force parallelism. The quantum computer is not a faster horse; it is a horse that knows which races to run.

[ILLUSTRATION: An open doorway at the end of a corridor, with sunlight streaming in. Through the doorway, a vista of many more branching corridors is visible, stretching into the distance, each labelled with one of the open questions listed above. The doorway frame is inscribed with a question mark. Title: "The corridors ahead."]
