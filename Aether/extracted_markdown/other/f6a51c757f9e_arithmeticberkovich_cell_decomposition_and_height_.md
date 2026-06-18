# When Numbers Have Neighborhoods: How Ancient Arithmetic Is Revolutionizing Artificial Intelligence

## The Map That Rewrites Itself

Imagine you're standing in a vast landscape of decisions. Every point represents a possible input to an artificial intelligence system—an image, a medical scan, a financial signal. The AI carves this landscape into regions, each labeled with a different output: "cat" or "dog," "benign" or "malignant," "buy" or "sell." The boundaries between these regions are the decision boundaries, and they determine everything about how the AI behaves.

Now imagine that instead of looking at this landscape with ordinary geometry—the kind where nearby points have similar coordinates—you look at it through the lens of a completely different kind of distance. A distance where two numbers are "close" not because they differ by a small amount, but because their difference is divisible by a large power of a prime number. In this world, 0 and 1,000,000 might be neighbors, while 0 and 1/7 are far apart.

This isn't science fiction. It's a branch of mathematics called non-archimedean geometry, pioneered in the early twentieth century and brought to full flower by the Russian-born mathematician Vladimir Berkovich in the 1990s. And now, a new line of research is showing that these exotic number systems hold the key to understanding—and controlling—the complexity of modern AI.

## The Problem of Counting Regions

Here's the fundamental question: how many decision regions can a neural network create? If you're building an AI system for a self-driving car, you need to know not just that it works on your test data, but that it can't be tricked by a tiny perturbation—an adversarial attack. A sticker on a stop sign that makes the AI see a speed limit sign. A few pixels changed in a medical image that flip a diagnosis.

To certify that an AI is robust against such attacks, you need to understand the geometry of its decision regions. How many are there? How complex are their boundaries? How does this complexity grow as the network gets deeper?

For ordinary neural networks with ReLU activations—the workhorses of modern deep learning—this question connects to tropical geometry, a branch of mathematics that replaces addition with taking minimums and multiplication with addition. The tropical approach has yielded beautiful results, showing that the number of linear regions grows polynomially in width and exponentially in depth.

But for networks with rational coefficients—the kind that actually run on finite-precision computers—there's a richer story. The coefficients aren't just real numbers; they're fractions, and fractions have an arithmetic structure that tropical geometry can't see.

## Enter the Valuation

The key idea is breathtakingly simple: instead of looking at the *value* of a computation, look at its *valuation*—a measure of how divisible it is by a chosen prime number. If your network computes the rational number 12/35, its 5-adic valuation tells you that the denominator is divisible by 5 (once), while its 7-adic valuation tells you about divisibility by 7.

This might sound like an obscure number-theoretic curiosity. But here's the punch: the valuation of a sum satisfies an inequality that's *stronger* than the ordinary triangle inequality. Instead of `|a + b| ≤ |a| + |b|`, you get `v(a + b) ≤ max(v(a), v(b))`. This "ultrametric" inequality means that in the world of valuations, triangles are always isoceles. Every triangle has a flat side.

This ultrametric structure isn't just mathematically elegant—it's computationally powerful. Because `max` is much simpler than `+`, the valuation of a sum is determined by the valuations of its parts. And this means that the valuation behavior of a neural network is *piecewise constant* rather than piecewise linear: once you fix which term dominates in each sum, the valuation is completely determined.

## Cells, Skeletons, and the Arithmetic of Complexity

The new theory introduces "valuation cells"—regions of input space where the dominance pattern of all sums in the network is fixed. Within each cell, the network's valuation profile is completely predictable. The cells tile the input space like the cells of a honeycomb, and their boundaries are the places where dominance switches from one term to another.

The beautiful result is that the number of such cells can be bounded explicitly. For a network with depth `d`, where each layer uses at most `s` nonzero coefficients of logarithmic height at most `h`, the number of valuation cells is at most `((s+1)(h+1))^d`. This formula tells a story:

- Each layer can create at most `(s+1)(h+1)` new cell boundaries, one for each possible dominance switch among the `s` terms, refined by the `h` possible height levels.
- Composing `d` layers multiplies these factors, because each layer can split each existing cell.
- The total is exponential in depth but polynomial in the per-layer parameters.

This bound connects two seemingly unrelated ideas. The parameter `s` measures *sparsity*—how many terms are active in each computation. The parameter `h` measures *arithmetic height*—a concept from number theory that quantifies the complexity of rational numbers. Larger numerators and denominators mean higher height, and higher height means more possible valuation patterns.

## From Ancient Primes to Modern Security

The connection to height is where the theory becomes truly interdisciplinary. In post-quantum cryptography—the field of designing encryption that will resist quantum computers—security often depends on the difficulty of problems involving integer lattices. The "height" of lattice vectors is directly related to the hardness of these problems: larger coefficients mean harder lattice problems.

The valuation cell theory provides a bridge. If a neural network's coefficients have bounded height, then its decision regions are limited in number. If the height grows, the number of regions explodes—and enumerating them becomes computationally hard, in the same way that lattice problems are hard.

This isn't just an analogy. The mathematical structure is identical. A valuation cell is defined by a system of inequalities involving valuations of rational expressions, and these inequalities are equivalent to constraints on the divisibility of integers—exactly the kind of constraints that appear in lattice problems.

The implication is profound: the complexity of a neural network's decision landscape is governed by the same arithmetic that determines the security of post-quantum cryptographic systems. Understanding one helps you understand the other.

## The Algorithm Inside the Proof

What makes this theory practical, not just beautiful, is that it comes with an algorithm. Given a bounded architecture—depth `d`, width `w`, support bound `s`, height bound `h`—you can enumerate all possible valuation cells. The enumeration runs in time proportional to the region budget `((s+1)(h+1))^d`, and for each cell, you can check which decision the network makes.

This gives you a *certified* count of decision regions. Not an estimate, not an approximation, but a provable upper bound. And from the certified count, you can derive robustness guarantees: if the network has at most `R` regions and is Lipschitz continuous with constant `L` on each region, then no adversarial perturbation smaller than `margin / (L·R)` can change the network's decision.

The key insight of the proof is an induction on network depth. At depth 0, there is only one cell (the whole input space). At each additional depth, you analyze the new layer: its affine expressions create at most `(s+1)(h+1)` new valuation comparisons, each of which can split an existing cell. The total number of cells therefore multiplies by at most `(s+1)(h+1)` per layer.

## A New Geography of Intelligence

The theory of valuation cells reframes neural networks as objects of arithmetic geometry. Just as algebraic geometers study varieties by decomposing them into cells (CW complexes, stratifications, tropicalizations), this theory decomposes the behavior of neural networks into arithmetic cells determined by valuation patterns.

The name "Berkovich" in the title isn't decorative. Vladimir Berkovich showed that for non-archimedean fields (like the p-adic numbers), there's a natural way to "fill in" the gaps in their topology by adding extra points—seminorm points—that make the space connected and well-behaved. The resulting "Berkovich space" has a tree-like skeleton that captures the essential structure of the space.

The valuation cells of a neural network are the arithmetic analogue of these Berkovich skeleton regions. Just as Berkovich's work revealed hidden structure in p-adic geometry, valuation cell decomposition reveals hidden arithmetic structure in neural network computation.

## Why It Matters

We live in an era where AI systems make life-and-death decisions. A medical AI that misclassifies a tumor. An autonomous vehicle that misreads a sign. A financial algorithm that crashes the market. In each case, the failure mode is the same: the AI's decision boundaries are in the wrong place, or there are too many of them, or they're too sensitive to perturbation.

The valuation cell theory offers a new tool for understanding and controlling these failures. By connecting the arithmetic of network coefficients to the geometry of decision regions, it provides bounds that are not just asymptotic estimates but exact, provable guarantees.

Moreover, the connection to cryptographic hardness suggests a deep duality: the same mathematical structures that make encryption secure also make neural networks hard to analyze. This isn't a coincidence—it's a signal that arithmetic complexity is a fundamental concept that spans computation, security, and intelligence.

The ancient study of prime numbers and divisibility, born in the markets of Mesopotamia and the academies of Athens, has found a new home in the silicon architectures of the twenty-first century. The primes are speaking, and they're telling us something profound about the limits and possibilities of artificial intelligence.

## Looking Forward

The theory opens several exciting directions. Can the cell decomposition be extended to multi-input networks? Can the height bounds be sharpened using deeper results from Diophantine geometry? Can the connection to lattice cryptography be made precise enough to derive formal security reductions?

Perhaps most intriguingly, the theory suggests a new approach to neural network design. Instead of choosing architectures by trial and error, you could choose them by their arithmetic properties—seeking networks whose valuation cell structure is provably simple, robust, and computationally tractable.

The landscape of AI decision-making is vast and complex. But now, for the first time, we have an arithmetic map.
