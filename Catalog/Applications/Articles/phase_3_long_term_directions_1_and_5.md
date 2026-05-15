# The Strange Arithmetic That Runs the World

## How replacing multiplication with addition — and addition with "pick the bigger one" — unlocks the hidden mathematics of GPS, scheduling, and artificial intelligence

---

Imagine you're planning a road trip from New York to Los Angeles. Your GPS doesn't care about the sum of all possible routes. It doesn't average them. It finds the *best* one — the shortest, the fastest, the one that minimizes your time on I-70 through Kansas. That act of optimization, of picking the maximum or minimum from a vast ocean of possibilities, seems like it should require sophisticated algorithms, extensive computation, maybe a touch of machine learning magic.

But what if optimization were just *arithmetic*? What if finding the best path through a network were as mechanical as multiplying two numbers on paper?

This is the revelation at the heart of tropical mathematics — a strange, beautiful alternative universe of algebra where the rules of arithmetic are reshuffled in a way that turns every calculation into an optimization problem, and every matrix multiplication into a search for the best route through a network.

## A Different Kind of Addition

Here is the key move. Take ordinary arithmetic — the kind you learned in elementary school — and make two substitutions:

- Wherever you would **add** two numbers, instead take the **maximum**.
- Wherever you would **multiply** two numbers, instead **add** them.

That's it. Two substitutions. The result is called the **max-plus algebra**, or more evocatively, **tropical arithmetic** — named, with a touch of mathematical whimsy, after the Brazilian mathematician Imre Simon, who pioneered its study.

Under these new rules, "adding" 3 and 7 gives you 7 (the max). "Multiplying" 3 and 7 gives you 10 (the sum). It sounds like a parlor trick, a mathematician's joke. But the consequences are staggering.

## Matrices That Think About Routes

The real magic emerges when you apply tropical arithmetic to matrices — those rectangular grids of numbers that form the backbone of modern computation, from computer graphics to machine learning.

In ordinary linear algebra, when you multiply two matrices, each entry of the result is computed by taking a row from the first matrix and a column from the second, multiplying corresponding entries, and summing the products. It's the dot product — the workhorse of computational mathematics.

In tropical matrix multiplication, you do something different. You take a row and a column, *add* corresponding entries (that's the tropical "multiplication"), and then take the *maximum* of all those sums (that's the tropical "addition"). The result looks like a standard matrix operation, but it computes something profoundly different.

Here's where the conceptual earthquake happens. Suppose your matrix represents a weighted directed graph — a network where each edge has a weight. Think of cities connected by highways, where the weight might represent the quality of the road, the bandwidth of a fiber optic connection, or the reliability of a link. The matrix entry W[i][j] tells you the weight of the direct edge from city i to city j.

When you tropically multiply this matrix by itself, each entry of the result tells you the **maximum total weight** you can accumulate on a **two-step journey** through the network. Entry (i, j) of the tropical product answers the question: "What is the best two-hop route from city i to city j, and how much total weight does it collect?"

Multiply again, and you get the best three-step route. Again: the best four-step route. Each tropical matrix power reaches deeper into the network, extending its tentacles along longer and longer paths, always tracking the optimal one.

## The Path Composition Theorem

This connection between tropical algebra and graphs isn't just an analogy or a heuristic. It is a precise, provable mathematical theorem — and it has now been formally verified with machine-checked mathematical certainty.

The theorem states: for any weighted graph on n vertices, the (i, j) entry of the m-th tropical power of the weight matrix equals the maximum total weight over all directed walks of length m from vertex i to vertex j. Every single walk. Exhaustively optimized. Computed by simple matrix arithmetic.

This is remarkable for several reasons. First, the number of possible walks grows exponentially — there are n^m walks of length m in a graph on n vertices. Yet the tropical matrix power compresses all of this information into a single n×n matrix, computed in just m matrix multiplications. The exponential explosion of combinatorial possibilities is tamed by the algebraic structure of tropical arithmetic.

Second, the computation is purely mechanical. No clever algorithms, no heuristics, no approximations. Just multiply matrices — with a different definition of "multiply." The optimization emerges from the arithmetic itself.

## The Bellman Connection

There's a deeper story here, one that connects tropical algebra to one of the most powerful ideas in computer science and operations research: **dynamic programming**.

The **Bellman equation**, formulated by Richard Bellman in the 1950s, is the mathematical principle behind everything from GPS navigation to inventory management to robot motion planning. It says that the optimal solution to a multi-step problem can be built incrementally: the best m-step solution from i to j equals the best (m-1)-step solution from i to some intermediate point k, plus the best single step from k to j, maximized over all possible intermediate points k.

This is *exactly* what tropical matrix multiplication computes. Each entry of the tropical product implements the Bellman recurrence in a single arithmetic operation. Tropical algebra doesn't just solve optimization problems — it *is* dynamic programming, wearing the elegant disguise of matrix algebra.

The formal verification confirms this Bellman recurrence as a precise theorem: the (m+1)-th tropical power at entry (i,j) equals the maximum, over all intermediate vertices k, of the m-th power at entry (i,k) plus the edge weight W[k][j].

## Associativity: Why Path Concatenation Works

For all of this to hang together, tropical matrix multiplication must be **associative** — meaning (A ⊗ B) ⊗ C = A ⊗ (B ⊗ C). If it weren't, the order in which you compute multi-step powers would matter, and the entire framework would collapse.

Associativity holds because of a beautiful algebraic fact: adding a constant to the maximum of a set of numbers is the same as taking the maximum of each number plus that constant. Formally, c + max(a, b) = max(c + a, c + b). This distributive law — addition distributing over maximum — is the secret engine that makes tropical algebra work. It's the structural reason why path concatenation is well-defined: joining two optimal sub-paths always produces an optimal total path.

## From Weights to Reachability

There's another layer to this story, one that connects tropical algebra to pure logic.

Consider a Boolean adjacency matrix — a grid of true/false values indicating which edges exist in a graph. If you encode "true" as 0 and "false" as negative infinity, then tropical matrix multiplication on this encoded matrix computes *reachability*: can you get from vertex i to vertex j in exactly m steps?

The formal theorem states: vertex j is reachable from vertex i in exactly m steps if and only if there exists a sequence of m+1 vertices forming a valid walk — starting at i, ending at j, with each consecutive pair connected by an edge. Tropical algebra provides a unified language where weighted optimization and logical reachability are two sides of the same coin.

## Why It Matters Now

Tropical mathematics has been known to specialists for decades, but it's experiencing a renaissance driven by three converging trends.

**Artificial intelligence.** Deep neural networks built from ReLU activation functions — the workhorses of modern AI — are tropical polynomials in disguise. Each layer of a ReLU network computes a piecewise-linear function, and these are precisely the functions that tropical algebra describes. Understanding neural networks through the tropical lens promises new insights into why deep learning works, how to make it more robust, and where its fundamental limits lie.

**Hardware acceleration.** Modern GPUs and TPUs are optimized for matrix multiplication. If your algorithm can be expressed as matrix multiplication — even with non-standard arithmetic — it can be massively parallelized. Tropical matrix powers inherit this acceleration for free, making large-scale path optimization problems amenable to the same hardware that trains language models.

**Verified computation.** As we deploy optimization algorithms in safety-critical systems — autonomous vehicles, medical robots, air traffic control — we need mathematical guarantees that the algorithms are correct. Formally verified tropical algebra provides exactly this: machine-checked proofs that the algebraic computation correctly captures the combinatorial optimization problem.

## The Bigger Picture

What makes tropical mathematics philosophically striking is that it reveals optimization as a natural algebraic operation. We tend to think of "finding the best" as a higher-order activity — something that requires intelligence, or at least sophisticated search. But tropical algebra shows that optimization is just arithmetic in a different universe. The act of choosing the maximum is as fundamental as the act of adding.

This has implications far beyond route planning. In economics, tropical algebra models optimal resource allocation. In linguistics, it describes parsing — finding the best parse tree for a sentence. In biology, it captures evolutionary fitness landscapes. In physics, it connects to the semiclassical limit of quantum mechanics, where wave functions collapse to classical trajectories via a process that is essentially tropical.

The tropical world is not a toy or an abstraction. It is the mathematics of decision-making itself — the algebra of choosing wisely, formalized and certified. And we are only beginning to explore what it can do.

## The Road Ahead

The formal verification of tropical path algebra opens doors that were previously locked. With machine-checked theorems establishing the equivalence between tropical matrix powers and optimal walks, researchers can now build certified algorithms for scheduling, routing, and planning — algorithms that come with mathematical proof of correctness, not just empirical testing.

Future work points toward tropical Perron–Frobenius theory (characterizing the long-run behavior of iteratively optimized systems), tropical message passing (the formal backbone of algorithms like Viterbi decoding and belief propagation), and tropical control theory (verified scheduling of manufacturing processes, transportation networks, and computing systems).

The strange arithmetic that replaces addition with "pick the bigger one" turns out not to be strange at all. It's the arithmetic the world has been using all along — in every GPS calculation, every factory schedule, every neural network layer. Mathematics has finally caught up.
