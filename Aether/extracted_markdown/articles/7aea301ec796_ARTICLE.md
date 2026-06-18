# Beyond Binary: How a 75-Year-Old Math Trick Could Revolutionize DNA Storage

## The Alphabet Problem

In 1948, Claude Shannon did something remarkable. Working at Bell Labs, he proved that there is a fundamental limit to how much you can compress a message — a limit set not by engineering cleverness, but by mathematics itself. His theorems launched the information age, giving us MP3s, JPEGs, Wi-Fi, and every digital communication system on Earth.

But Shannon had a blind spot. Or rather, his followers did. Almost every textbook, every course, every implementation of his ideas assumes the same thing: that the world speaks in binary. Ones and zeros. On and off. True and false.

The world, it turns out, has a much richer vocabulary.

## Nature's Four-Letter Code

Consider DNA. Every cell in your body stores information using four chemical letters — adenine, cytosine, guanine, and thymine. Not two. Four. When researchers began exploring DNA as a medium for archiving digital data (and they are: Microsoft, Twist Bioscience, and others have stored entire movies in DNA), they faced a curious mismatch. Their compression algorithms thought in binary. Their storage medium thought in quaternary. Something was being lost in translation.

Or consider the flash memory in your phone. Modern flash chips don't store simple on-off states. They store four, eight, or even sixteen distinct voltage levels per cell. Your phone's storage speaks in base 4, or base 8, or base 16. Yet the coding theory behind it was built for base 2.

This is not a minor inconvenience. It's like trying to write Chinese poetry using only the English alphabet — technically possible through transliteration, but you lose the structure, the elegance, and quite a bit of efficiency.

## The Universal Theorem

What if Shannon's theorems didn't need to assume binary at all? What if there were a single, clean mathematical statement that worked for *any* alphabet size — binary, ternary, quaternary, or beyond?

This is precisely what a new suite of mathematical results achieves. The theorems generalize Shannon's source coding theorem from base 2 to base *q*, for any integer *q* ≥ 2. The generalization is not merely cosmetic. It reveals a deeper structure: that information compression is governed by a universal variational principle, independent of the alphabet used to encode it.

The central result has three parts, forming what might be called the **q-ary source coding trinity**:

**The lower bound.** No matter how cleverly you design your code, the average code length can never be shorter than the *q-ary entropy* of the source. This is the fundamental irreducible cost of description. In base 2, entropy is measured in bits. In base 4, in "quats." In base *q*, in whatever unit is natural for that alphabet. The formula is beautiful in its universality:

$$H_q(p) = -\sum_a p(a) \log_q p(a)$$

**The upper bound.** A simple, explicit construction — take the ceiling of the ideal code length for each symbol — achieves an average length within one unit of this entropy. The gap between theory and practice is at most one symbol, regardless of the source distribution or the alphabet size.

**The optimizer.** If you allow code lengths to be real numbers (a mathematical idealization), there is exactly one assignment that achieves the minimum: give each symbol a length equal to its "information content" in base *q*. This isn't just the best code — it's the *unique* best code.

## Why This Matters

The practical implications cascade across multiple technologies.

**DNA data storage** operates natively in base 4. The q-ary coding theorem with *q* = 4 tells researchers exactly how much information can be packed into each nucleotide, and provides the ceiling-length construction for building codes that come within one nucleotide of the theoretical limit. No binary-to-quaternary conversion needed. The math speaks DNA's native language.

**Flash memory** is perhaps the most immediate beneficiary. A triple-level cell (TLC) flash chip stores 3 bits per cell by distinguishing 8 voltage levels. The q-ary theorem with *q* = 8 provides direct bounds on encoding efficiency, bypassing the standard trick of treating each cell as three independent binary channels (which loses the correlation structure between levels).

**Ternary and neuromorphic computing** is experiencing a renaissance. Researchers have shown that balanced ternary arithmetic can be more efficient than binary for certain operations. The q-ary coding theorem with *q* = 3 provides the information-theoretic foundation these systems need.

## The Kraft Inequality: A Geometric Insight

One of the most elegant results in the suite is the *q-ary Kraft inequality*. It says that for any prefix-free code (one where no codeword is the beginning of another), the sum of *q*^(−ℓ) over all code lengths ℓ must be at most 1.

Think of it this way. Imagine a tree with *q* branches at every node. Each codeword corresponds to a path from the root to some node. Making a code prefix-free means that once you've claimed a node, you can't use any of its descendants. The Kraft inequality counts the fraction of the tree consumed by each codeword: a codeword of length ℓ uses up a fraction *q*^(−ℓ) of the total tree. Since the tree has total capacity 1, the sum can't exceed 1.

This geometric insight is what makes the entire theory work. It's the bridge between the combinatorial structure of codes and the analytic structure of entropy.

## The Gibbs Connection

Deep beneath the coding theorems lies a remarkable inequality that connects information theory to statistical physics. The *Gibbs inequality* — named after the 19th-century physicist Josiah Willard Gibbs — states that among all probability distributions compatible with certain constraints, the one that maximizes entropy is the "true" distribution.

In the coding context, the Gibbs inequality takes a precise form: the average logarithm of a distribution *p* is always at least the average logarithm of any other distribution *w* with total weight at most 1. Mathematically:

$$\sum_a p(a) \log_q w(a) \leq \sum_a p(a) \log_q p(a)$$

This is the engine that powers the lower bound. It says, roughly, that no coding scheme can "cheat" — using symbols more efficiently than their information content allows.

The same inequality appears in thermodynamics (the second law), in machine learning (the principle of maximum entropy), and in statistical mechanics (the minimization of free energy). The q-ary coding theorem makes this connection explicit and mathematically precise, across all alphabet sizes.

## A Tropical Vista

There is a further connection that opens genuinely new mathematical territory. In the emerging field of *tropical mathematics*, one replaces ordinary addition with maximum (or minimum) and multiplication with addition. This algebraic shift transforms optimization problems into geometric ones, and has found applications in areas from algebraic geometry to phylogenetics.

The q-ary coding theorem has a natural tropical interpretation. Code lengths are additive weights. The Kraft sum is an exponential feasibility constraint that, in the tropical limit, becomes a linear one. The optimal code length function — *L*(a) = log_q(1/p(a))* — is a Legendre-type transform between the world of probabilities and the world of code lengths.

This is not merely an analogy. The relaxed optimizer result proves that there is an exact duality between the probability simplex and the set of feasible code lengths, mediated by the logarithm. In tropical terms, this duality becomes a linear correspondence, making the theory more transparent and computationally tractable.

## The Pigeonhole Principle, Upgraded

Among the results is a charming generalization of the classical pigeonhole argument. For any probability distribution and any code satisfying the q-ary Kraft inequality, there must exist at least one symbol whose Kraft weight *q*^(−ℓ) is at most its probability *p(a)*. 

The proof is delightfully simple: if every Kraft weight exceeded its corresponding probability, the Kraft sum would exceed the probability sum, which is 1. But the Kraft inequality says the Kraft sum is at most 1. Contradiction. 

This "tropical pigeonhole" principle has a direct interpretation in coding: no matter how you assign code lengths, at least one symbol must be encoded at least as efficiently as its information content demands. You can't make everything expensive.

## The Road Ahead

These results open several concrete research directions. Formalizing the q-ary Huffman algorithm — the optimal variable-length code construction — would extend the theory from Shannon's achievability bound to true optimality. Defining q-ary mutual information and proving the data-processing inequality in base *q* would create a complete q-ary information theory. And connecting this framework to tropical rate-distortion theory could yield new results in lossy compression for non-binary channels.

Perhaps most intriguingly, the variational structure of the relaxed optimizer suggests connections to tropical free energy and the thermodynamic formalism. The optimal code length function is, mathematically, a Gibbs measure in disguise. Formalizing this connection could bridge information theory, statistical mechanics, and tropical geometry in ways that are currently only dimly perceived.

## The Bigger Picture

Shannon's original insight was that information has a physics — that there are inviolable laws governing communication, just as there are inviolable laws governing energy and entropy. For 75 years, those laws were stated primarily in the language of binary arithmetic.

The q-ary source coding theorem suite rewrites those laws in their most natural form: universal, base-independent, and connected to the deepest structures in mathematics and physics. It's a small step in formalism — replace 2 by *q* — but a large step in understanding. The universe doesn't think in binary. Now, neither does the mathematics of information.
