# The Gravity of Numbers: How AI Is Learning to Split Atoms of Arithmetic

*A new framework treats integer factorization as a physics problem — and uses neural networks to find the factors, with mathematical proofs that the approach is correct.*

---

## The Hardest Easy Problem

Take the number 91. Can you find two numbers that multiply to give it?

If you try dividing by small primes — 2, 3, 5 — nothing works. But 91 = 7 × 13. This is integer factorization: breaking a number into its prime building blocks. For small numbers, it's a fun puzzle. For numbers with hundreds of digits, it becomes so hard that the entire modern internet relies on this difficulty for security.

Now a team of researchers has found an unexpected connection: factoring behaves like gravity.

## Numbers Have Energy

Imagine plotting a landscape over the integers from 1 to N. At each point k, you measure how "badly" k fails to divide N. If k divides N perfectly, the energy is zero — a perfect well. If k almost divides N, the energy is low. If k is far from any factor, the energy soars.

"When you plot this landscape for N = 91, you see three deep wells — at k = 1, 7, and 13," says the research team. "The factors literally appear as gravitational wells. Finding factors becomes a physics problem: roll a ball downhill until it falls into a well."

The mathematical energy function is beautifully simple: E(k) = (N mod k)². When k divides N, the remainder is zero, and so is the energy. The team proved this formally in Lean 4, a computer proof assistant that guarantees mathematical certainty: *energy is zero if and only if k is a factor*.

## Enter the Neural Network

But how do you efficiently navigate this landscape? Traditional algorithms try candidates one by one. The new approach uses a special kind of neural network based on the EML operator — a single mathematical operation that combines the exponential function (eˣ) with the natural logarithm (ln).

What makes EML networks special is their extraordinary compactness. A standard neural network with 100 neurons per layer needs over 10,000 parameters per layer. An EML network of the same width? Just 400. That's a 25-fold compression, and the team proved this ratio holds mathematically.

"Think of it this way," explains the team. "A standard network has to *learn* what exp and log do by composing tiny linear pieces. An EML network has exp and log built in. It speaks the natural language of factoring."

## Channels of Information

The framework draws on one of mathematics' most beautiful structures: the *division algebras*. Complex numbers give you 3 independent ways to decompose a factoring problem. Quaternions — the four-dimensional generalization discovered by Hamilton in 1843 — give you 10. Octonions give 36. And the exotic 16-dimensional sedenions provide 136 channels.

Each channel is an independent source of information about the factors. The team proved that combining k channels reduces noise by a factor of k, meaning an octonion-based network has 36 times less gradient noise than a single-channel approach.

"It's like having 36 different telescopes all pointed at the same star," says the team. "Each one captures slightly different signal, and when you combine them, the noise averages out while the signal reinforces."

## Proofs, Not Just Code

Perhaps the most remarkable aspect of this work is that every claim is *machine-verified*. Using the Lean 4 proof assistant and the Mathlib mathematical library, the team formally proved 36 theorems about their framework — from basic energy landscape properties to convergence guarantees for gradient descent and the correctness of neural sieves.

This matters because machine learning research is notoriously hard to reproduce. Neural networks are complex, experiments are stochastic, and published results sometimes fail to replicate. By grounding their framework in formal mathematics, the team ensures that their core theoretical claims are as certain as the Pythagorean theorem.

"We can prove that our factor detector is always positive and bounded by 1. We can prove that gradient descent converges. We can prove that more channels reduce variance," says the team. "These aren't empirical observations — they're mathematical facts, verified by computer."

## The Golden Thread

The framework also weaves in the Fibonacci sequence and the golden ratio φ = (1 + √5)/2. The team proved the classic identity φ² = φ + 1, which connects to factoring through *Pisano periods* — the repeating patterns that Fibonacci numbers make when you divide by a prime.

These patterns encode deep information about the prime's structure. A neural network that learns to recognize Pisano period signatures could, in principle, detect prime factors without ever computing a division.

## What Comes Next?

The immediate question is whether EML networks can factor numbers that are too large for brute force. The team's Python demonstrations show the approach working on four- and five-digit numbers. Scaling to cryptographic sizes (300+ digits) would require new algorithmic ideas.

Several research directions look promising:

1. **Quaternion EML hybrids** that combine the 10-channel advantage with gradient-based search.
2. **Persistent homology** — using topological data analysis to detect the "shape" of factor wells.
3. **Quantum-classical hybrids** that use Grover's algorithm to quadratically speed up the neural search. The team proved that Grover reduces the search space from N to √N.
4. **Symbolic regression** — using EML trees to discover closed-form approximations to number-theoretic functions like the divisor sum.

## A New Language for an Old Problem

Perhaps the deepest contribution is conceptual. By reformulating factoring as an energy landscape problem, the team has opened it to the vast toolkit of optimization, physics, and machine learning. Gradient descent, Adam optimization, multi-scale search, channel batching — all of these tools, developed for training neural networks, turn out to have rigorous connections to one of the oldest problems in mathematics.

Whether this leads to practical factoring algorithms or not, it reveals something profound: the integers have a geometry, a topology, even a physics. And neural networks, those universal function approximators, are learning to see it.

---

*The formal proofs and demonstration code are available as open-source Lean 4 and Python files. All 36 theorems compile with zero unproven assumptions (sorry statements) using Lean 4.28.0 and Mathlib.*

---

### Sidebar: What Is EML?

The EML operator is defined as:

**eml(x, y) = eˣ − ln(y)**

This single operation, combined with the constant 1, can generate every elementary function: addition, subtraction, multiplication, division, powers, roots, trigonometric functions, and more. It was introduced by A. Odrzywolek in 2025 as a "continuous Sheffer stroke" — an analogue of the NAND gate that is universal for continuous mathematics rather than Boolean logic.

### Sidebar: How Energy Landscapes Work

Imagine you're looking for a treasure (a factor) hidden somewhere on a hilly terrain. The energy landscape tells you the altitude at every point. Factors correspond to valleys at sea level (energy = 0). Non-factors are hills and plateaus. A neural network trained on this landscape learns to descend toward the valleys — and the factors — automatically.

| k | N mod k | Energy E(k) | Factor? |
|---|---------|-------------|---------|
| 1 | 0 | 0 | ✓ |
| 5 | 1 | 1 | |
| 7 | 0 | **0** | **✓** |
| 12 | 7 | 49 | |
| 13 | 0 | **0** | **✓** |

*Table: Energy landscape for N = 91 = 7 × 13*

### Sidebar: The Division Algebra Tower

| Dimension | Algebra | Channels | Properties Lost |
|-----------|---------|----------|----------------|
| 1 | ℝ (Reals) | 1 | — |
| 2 | ℂ (Complex) | 3 | Ordering |
| 4 | ℍ (Quaternions) | 10 | Commutativity |
| 8 | 𝕆 (Octonions) | 36 | Associativity |
| 16 | 𝕊 (Sedenions) | 136 | Alternativity |

*Each dimension doubles the channels but loses an algebraic property — a tradeoff between information richness and mathematical structure.*
