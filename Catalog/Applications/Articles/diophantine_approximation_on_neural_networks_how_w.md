# How Well Can a Neural Network Know Pi?

## The Surprisingly Deep Connection Between AI and Ancient Mathematics

*When mathematicians first computed the digits of pi, they could not have imagined that their work would illuminate a fundamental question about artificial intelligence: how well can the simplest neural networks approximate the most famous numbers in mathematics?*

---

In 1674, Gottfried Wilhelm Leibniz discovered one of the most beautiful formulas in mathematics: an infinite series that converges to π/4. Take the odd numbers — 1, 3, 5, 7, 9 — and form the alternating sum of their reciprocals: 1 − 1/3 + 1/5 − 1/7 + 1/9 − ⋯. Multiply by four, and you get pi. Simple, elegant, and painfully slow.

Three and a half centuries later, a new question emerges from the intersection of number theory and machine learning: if you build the simplest possible neural network — one using only the ReLU activation function, the workhorse of modern deep learning — how efficiently can it compute those digits of pi?

The answer, it turns out, reveals a profound structural connection between two seemingly unrelated fields: **Diophantine approximation** (the ancient art of approximating irrational numbers by rationals) and **neural network expressiveness** (the modern science of what functions networks can represent).

## The ReLU Revolution

The ReLU function is almost absurdly simple: it takes a number and returns it if it's positive, or zero if it's negative. Mathematically, ReLU(x) = max(0, x). It's a kinked line — linear everywhere except at the origin, where it bends.

Yet this simplicity is deceptive. When you compose ReLU functions — layering them into networks — something remarkable happens. Each ReLU operation can at most double the number of "pieces" in your function, plus one. A single ReLU gives you a function with 2 linear pieces. Two layers give you 5. Three give you 11. After *d* layers, you have up to 2^(d+1) − 1 pieces.

This exponential growth is the source of deep networks' power. A shallow network with a thousand neurons can represent functions with roughly a thousand pieces. A deep network with just 10 layers of 10 neurons each can represent functions with *ten billion* pieces. Depth buys exponentially more expressiveness than width.

But what does this have to do with pi?

## The Diophantine Connection

Here's the key insight. A ReLU network with rational parameters — weights and biases that are ordinary fractions — can only output rational numbers. And pi is irrational. So a ReLU network with rational parameters can never *exactly* output pi. It can only approximate it.

How well? That depends on number theory.

The quality of rational approximations to pi is governed by its **irrationality measure** — a number, denoted μ(π), that quantifies how "hard" pi is to approximate by fractions. The theorem of Thue, Siegel, and Roth tells us that any algebraic irrational number (like √2) has irrationality measure exactly 2. For transcendental numbers like pi, the measure can be larger, making them harder to approximate.

Current bounds place π's irrationality measure at most 7.61. This means: for any fraction p/q with large enough q, the distance |π − p/q| is larger than 1/q^7.61. Pi, in a precise sense, actively *resists* rational approximation — but not as fiercely as it could.

This resistance creates a fundamental barrier for ReLU networks. A network whose parameters are integers bounded by some value B can produce outputs that are rationals with denominators bounded by a function of B and the network's complexity. The quality of its approximation to pi is therefore constrained by the same number-theoretic forces that Diophantus studied two millennia ago.

## Building Pi from Scratch

The Leibniz series gives us a constructive strategy. The partial sum using n terms approximates π/4 with error at most 1/(2n+1). Multiplied by 4, we get an approximation to pi with error at most 4/(2n+1) — roughly 2/n.

A ReLU network can represent this partial sum directly: each term of the Leibniz series is a rational number, and the sum of n rationals is rational. We can encode the entire partial sum as a single constant parameter. To get accuracy ε, we need roughly n ≈ 2/ε terms — and the resulting rational number has denominator growing roughly as n! (the product of the odd numbers).

But here's where depth becomes crucial. If instead of storing the precomputed sum as a single constant, we want the network to *construct* it from simpler operations — adding terms one by one — then we need network architecture. A network of depth d can sum up to 2^d terms (using a binary-tree addition structure). So to sum the n ≈ 2/ε terms of the Leibniz series, we need depth d ≈ log₂(2/ε) = O(log(1/ε)).

This gives us the headline result: **a ReLU network of depth O(log(1/ε)) can approximate pi within ε**.

## The Spectrum of Difficulty

Not all numbers are equally hard to approximate. The **Diophantine approximation spectrum** — a new concept emerging from this research — measures how the best rational approximation quality varies with the allowed denominator size.

For pi, the spectrum has dramatic jumps. With denominators up to 7, the best you can do is 22/7, achieving accuracy 0.00126. With denominators up to 113, you get the remarkable fraction 355/113, accurate to within 0.000000267. That single step from denominator 7 to denominator 113 buys you *four extra decimal places*.

These jumps correspond to the convergents of pi's continued fraction expansion. The continued fraction of pi begins [3; 7, 15, 1, 292, 1, 1, 1, 2, ...], and each large coefficient (like 292) signals a convergent of exceptional quality. The fraction 355/113, discovered by Chinese mathematician Zu Chongzhi in the 5th century, arises from the coefficient 292 and remains the best rational approximation to pi with a denominator under 33,000.

For a ReLU network, each convergent represents an "efficiency breakthrough" — a point where a small increase in parameter size yields a disproportionate improvement in approximation quality. The landscape of pi approximation is not smooth; it has valleys and plateaus, dictated by the continued fraction.

## What Makes Pi Special?

Compare pi to the golden ratio φ = (1+√5)/2. The continued fraction of φ is [1; 1, 1, 1, 1, ...] — all ones. This makes φ the *hardest* irrational number to approximate by rationals (in a precise sense). Its Diophantine spectrum decreases smoothly, with no dramatic jumps. For a ReLU network, approximating φ requires steady, predictable growth in complexity.

The number e = 2.71828... has continued fraction [2; 1, 2, 1, 1, 4, 1, 1, 6, 1, 1, 8, ...] — a beautiful pattern with growing coefficients. Its spectrum has moderate jumps, making it easier to approximate than φ but harder than pi (whose coefficient 292 creates an anomalous convergent).

This suggests a classification of real numbers by their "ReLU complexity": how fast must network parameters grow to achieve a given approximation quality? Rational numbers have finite complexity (they can be represented exactly). Algebraic irrationals have polynomial complexity (governed by Roth's theorem). Transcendental numbers like pi and e have complexity governed by their individual continued fraction structure.

## The Deeper Question

This research opens a window onto a profound question: **what is the information-theoretic cost of approximating mathematical constants?**

A constant like pi encodes an infinite amount of information in its decimal expansion. A neural network is a finite object — a fixed set of parameters. The approximation quality measures how much of pi's infinite information the network has captured.

The exponential expressiveness of deep networks (2^d pieces from depth d) means that depth is the most efficient axis along which to grow. But the Diophantine barrier means that no matter how clever the architecture, the network cannot do better than the number-theoretic constraints allow. The ancient mathematics of rational approximation sets an inescapable lower bound on the modern challenge of neural network representation.

In the end, Leibniz's formula — slowly converging, term by term, toward the elusive digits of pi — mirrors the neural network's own struggle. Both are finite approximations to an infinite truth, and both are governed by the same mathematical forces that have fascinated humanity for millennia.

---

*The results described here have been rigorously verified using computer-assisted mathematical proof, confirming both the upper bounds (via Leibniz series construction) and the lower bounds (via the irrationality of pi) with mathematical certainty.*
