# The Circuits That Never Lie: How Min and Max Built the Most Stable Computer in Mathematics

## A Machine Made of Comparisons

Imagine a computer that can only do two things: compare two numbers and pick the smaller one, or compare two numbers and pick the larger one. No addition. No multiplication. No subtraction. Just *min* and *max*, over and over, wired together in any pattern you like.

It sounds absurdly limited. What could such a primitive machine possibly compute?

The answer turns out to be: quite a lot — and with a guarantee that no other computing model can match. These "monotone min-max circuits" possess a mathematical superpower that researchers have now rigorously proved: *they cannot amplify errors*. Feed slightly wrong inputs into an arbitrarily deep, arbitrarily complex network of min and max operations, and the output is never more wrong than the worst input. Not by a little. Not asymptotically. *Exactly* never more wrong.

This is not how computers normally work. In ordinary arithmetic, a tiny rounding error in the tenth decimal place can snowball through a chain of multiplications until it dominates the answer. Engineers spend careers fighting this numerical chaos. But min-max circuits are immune to it — by their very nature, by the mathematics woven into their structure.

The story of how mathematicians proved this, and what it means for everything from artificial intelligence to game strategy, begins with a deceptively simple question about order.

## The Monotonicity Principle

Here's a fact so obvious it seems unworthy of a theorem: if you increase every input to a min-max circuit, the output cannot decrease.

Think about it with a concrete example. Suppose you have three temperature sensors feeding into a system that computes `max(min(sensor₁, sensor₂), sensor₃)`. If every sensor reading goes up by one degree, can the output possibly go *down*? Of course not. The minimum of two larger numbers is at least as large as the minimum of the original numbers. The maximum of larger quantities is at least as large. No matter how you wire min and max together — in any configuration, to any depth — increasing inputs means a non-decreasing output.

This is the **monotonicity theorem** for min-max circuits. It sounds trivial, but its implications are profound. It says that these circuits are *intrinsically well-behaved*. They preserve the natural ordering of their inputs. They are, mathematically speaking, *monotone functions* — and this monotonicity is not something you have to check or enforce. It is guaranteed by the structure of the circuit itself.

Compare this with ordinary Boolean logic circuits, which include NOT gates. A NOT gate flips the direction of change: increase an input and the output decreases. This inversion is what makes Boolean circuits so powerful — and so unpredictable. Monotone circuits trade away negation for a guarantee of orderly behavior.

## The Stability Breakthrough

The monotonicity theorem is the warm-up act. The main event is what happens when we ask about *approximate* inputs.

In the real world, measurements are never exact. Your GPS knows your position to within a few meters. Your thermometer is accurate to half a degree. Every sensor, every data source, every observation comes with uncertainty. So the critical question for any computational system is: *how does input uncertainty affect output reliability?*

For most computations, the answer is discouraging. Consider the simple operation of multiplying two numbers. If each input has an error of at most ε, the output error can be as large as roughly 2ε times the input magnitude — it grows with the values involved. Chain together *d* multiplications and the error can blow up exponentially, by a factor of roughly 2^d. This is the nightmare of numerical analysis, the reason supercomputers need 128-bit floating point, the reason your banking software has so many decimal places.

Min-max circuits obliterate this problem entirely.

The **1-Lipschitz stability theorem** states: if every input to a min-max circuit differs from its true value by at most ε, then the output differs from its true value by at most ε. Not 2ε. Not 10ε. Not ε times anything. Just ε. And this holds regardless of the circuit's size, depth, or complexity.

The proof is elegant in its simplicity. Consider what happens at a single min gate with inputs *a* and *b*. If you perturb *a* to *a'* and *b* to *b'*, each within ε, then:

- If *a < b*, then min(*a, b*) = *a*, and min(*a', b'*) is either *a'* or *b'*. In either case, the result stays within ε of *a*: if *a'* wins, it's within ε directly; if *b'* wins, it's because *b'* dropped below *a'*, but *b'* is within ε of *b* which was above *a*, so *b'* can't be more than ε below *a*.

The key insight is that *selecting* a value (which is what min and max do — they select one of their inputs) can never amplify a perturbation. Selection is inherently stable. When you pick the smaller of two slightly-wrong numbers, your answer is at most as wrong as the most wrong input, because your answer *is* one of those inputs.

This property — being 1-Lipschitz, or *nonexpansive* — is the holy grail of robust computation. It means you can compose min-max operations to arbitrary depth with zero degradation of accuracy. A circuit with a million gates and a circuit with three gates have exactly the same worst-case error amplification: none.

## The Algebra of Fairness

There's another theorem in this package that reveals something unexpected about the algebra of comparison: min and max obey distributive laws, just like addition and multiplication.

You learned in school that *a × (b + c) = a × b + a × c*. It turns out that a precisely analogous law holds for min and max:

> min(*a*, max(*b*, *c*)) = max(min(*a*, *b*), min(*a*, *c*))

And the dual:

> max(*a*, min(*b*, *c*)) = min(max(*a*, *b*), max(*a*, *c*))

These aren't just algebraic curiosities. They mean that min-max circuits can be *rearranged* — rewritten into different but equivalent forms — without changing their behavior. You can always push all the min operations down to the innermost level, creating a "max-of-mins" normal form, or vice versa. This is analogous to converting a Boolean formula to disjunctive normal form, and it opens the door to systematic simplification, optimization, and equivalence-checking of circuits.

The distributive laws make min-max circuits into a mathematical structure called a *distributive lattice*. And not just any distributive lattice — because we're working with numbers on a line (not just abstract elements), it's a *totally ordered* distributive lattice, which is the richest and best-behaved kind. Every comparison has a definite answer, and the algebra respects that perfectly.

## Where Did This Come From?

The mathematical roots of min-max circuits stretch back to several independent traditions.

In the 1950s and 60s, computer scientists studying **circuit complexity** asked which Boolean functions could be computed without negation — using only AND and OR gates. These "monotone Boolean circuits" turned out to be a natural and important restricted model, and proving lower bounds on their size became a major research program. In 1985, Alexander Razborov proved the first exponential lower bounds for monotone circuits computing specific functions, one of the landmark results in computational complexity theory.

Meanwhile, in an entirely different corner of mathematics, practitioners of **tropical geometry** were building an alternative algebra where addition is replaced by max (or min) and multiplication by addition. This "tropical semiring" turns polynomial equations into piecewise-linear geometry, transforming algebraic curves into networks of line segments. Tropical methods have since revolutionized parts of algebraic geometry, optimization, and combinatorics.

And in control theory and operations research, **dynamic programming** — pioneered by Richard Bellman in the 1950s — was built on exactly the same operations. The Bellman equation for optimal control is fundamentally a min or max operation applied recursively: find the minimum cost, or the maximum reward, at each decision point. Every dynamic programming recurrence is, at its core, a min-max circuit.

What the new mathematical results accomplish is unifying these threads. Monotone min-max circuits are simultaneously:
- the natural model for computation without negation,
- the term algebra of tropical mathematics,
- the structural skeleton of dynamic programming,
- a certified model of robust computation.

## What This Means for AI and Beyond

The 1-Lipschitz stability theorem has immediate implications for artificial intelligence and machine learning.

Modern neural networks suffer from a well-known fragility: tiny, carefully chosen perturbations to an input image can cause a network to catastrophically misclassify it. An image that clearly shows a panda gets classified as a gibbon after changing a few pixels by imperceptible amounts. This vulnerability — the subject of intense research under the banner of "adversarial robustness" — exists precisely because neural networks use operations (multiplication, addition, and activation functions like ReLU) that *can* amplify perturbations.

Min-max circuits offer a fundamentally different architecture. A decision system built entirely from min and max operations is *provably* immune to this kind of attack. No adversarial perturbation, no matter how cleverly crafted, can change the output by more than the perturbation itself. This isn't a statistical guarantee or an empirical observation — it's a mathematical theorem, proved with complete rigor.

Of course, a pure min-max network is less expressive than a general neural network. But the stability theorem suggests a design principle: the more a system relies on comparison and selection (min, max, median, quantile operations) rather than arithmetic (addition, multiplication), the more inherently robust it becomes. This is a precise, quantitative version of the intuition that "simpler models are more robust."

The applications extend beyond AI:

**Sensor fusion.** When combining readings from multiple sensors, a min-max aggregation scheme (take the median, or the min of the top three, or the max of the bottom three) provides guaranteed bounds on the output error.

**Game theory.** The minimax algorithm — the foundation of game-playing AI from chess engines to poker bots — is literally a min-max circuit. The stability theorem says that if your evaluation of board positions is slightly wrong, your strategic decisions are at most slightly wrong.

**Control systems.** Safety-critical systems in aviation, autonomous vehicles, and medical devices need guaranteed bounds on computational error. Min-max controllers provide these bounds by construction.

**Financial risk.** Portfolio risk measures like Value-at-Risk involve min and max over scenarios. The stability theorem guarantees that small errors in scenario modeling lead to small errors in risk assessment.

## The Deeper Pattern

Step back and consider what these results reveal about the nature of computation itself.

We tend to think of computers as arithmetic machines — they add, multiply, and branch. But there's a more primitive computational substrate: *comparison*. Before you can add two numbers, you need to know which is bigger (for borrowing, carrying, alignment). Before you can sort a list, you need to compare elements. Before you can make a decision, you need to compare options.

Min-max circuits isolate this comparison substrate and show that it has remarkable properties. Computation by pure comparison is automatically monotone (order-preserving), automatically stable (error-bounded), and algebraically well-structured (distributive). These properties don't need to be engineered — they emerge from the nature of comparison itself.

This is perhaps the deepest insight: **stability is not an engineering achievement but a mathematical consequence of using the right operations.** When we build systems from operations that respect the order structure of their inputs, we get guarantees that are impossible to achieve with operations that don't.

The ancient Greeks knew that comparison was fundamental — Euclid's algorithm, arguably the oldest algorithm in mathematics, is built on repeated comparison and subtraction. Two and a half millennia later, we're discovering that they were onto something profound. The simplest computational operations — "which is smaller?" and "which is larger?" — are also, in a precise mathematical sense, the most trustworthy.

In a world increasingly dependent on computation we can't fully understand or verify, that's a remarkable and reassuring fact. Some computations, by their very nature, cannot lie.
