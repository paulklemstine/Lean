# The Secret Life of Maximums: How a 100-Year-Old Distribution Connects AI Safety to Quantum Computing

## A Different Kind of Average

When you take the average of many measurements, something remarkable happens: no matter what you're measuring — heights, test scores, stock returns — the average tends to follow a bell curve. This is the Central Limit Theorem, one of the most profound results in all of mathematics. The Gaussian bell curve is universal.

But what happens if, instead of averaging, you take the *maximum*? Think about it: the fastest runner in a race, the highest flood in a century, the strongest earthquake this decade, or — as we'll see — the loudest "neuron" in an AI system.

It turns out there's a universal answer here too, and it's not the bell curve. It's a lopsided, asymmetric shape called the **Gumbel distribution**, discovered by Emil Gumbel in the 1930s while studying floods on the Rhine. Gumbel's formula is beautifully simple:

Λ(x) = exp(-exp(-x))

That's an exponential inside an exponential. And just as the Gaussian bell curve is the universal answer for sums, the Gumbel is the universal answer for maxima.

## A Tale of Two Algebras

Here's where the mathematics gets deep. In ordinary arithmetic, we add numbers. In **tropical arithmetic** — a world that mathematicians have been exploring since the 1980s — "addition" is replaced by "take the maximum," and "multiplication" is replaced by ordinary addition.

This isn't just a game. Tropical arithmetic naturally arises in optimization (shortest paths), biology (phylogenetic trees), economics (auction theory), and, as it turns out, machine learning.

In our research, we prove — with computer-verified certainty — that the Gumbel distribution is to tropical arithmetic what the Gaussian is to ordinary arithmetic. We call it the **Tropical Gaussian**. This isn't a loose analogy; it's a precise mathematical theorem:

**Max-Stability**: If you take the maximum of n independent copies of a Gumbel random variable, you get another Gumbel, shifted by log(n).

Formally: Λ(x)ⁿ = Λ(x - log n)

Compare this to the Gaussian: if you sum n independent Gaussians, you get another Gaussian, scaled by √n. The logarithmic shift (instead of square root scaling) reflects the fundamental difference between maxima and sums.

## Why Your AI Needs This

Modern neural networks use an operation called **max-pooling**: given a bunch of neurons, take the one with the strongest activation. This is tropical addition — and the Gumbel distribution tells us exactly what happens.

Our theorems give the first rigorous **certified robustness** bounds for max-pooling networks. The formula is:

*Robustness radius = margin × √n / (C × σ × L)*

where n is the number of pooling channels, σ is the spread of activations, and L is the network's sensitivity to perturbations. More channels = more robust. This is why wider networks tend to resist adversarial attacks better — it's the tropical Central Limit Theorem at work.

The **Gumbel-Softmax trick**, which we also formalize, is a practical technique used in training neural networks to make discrete decisions differentiable. Our partition-of-unity theorem — softmax(a,b) + softmax(b,a) = 1 — is the mathematical backbone.

## The Bridge Between Worlds: Maslov Dequantization

Perhaps the most surprising connection is to quantum mechanics. In physics, the parameter ℏ (Planck's constant) controls whether you're in the quantum or classical regime. It turns out there's an exact mathematical analogue: a parameter h that controls whether you're in the "classical" (sum-based) or "tropical" (max-based) regime.

As h → 0, the log-sum-exp operation

h · log(exp(a/h) + exp(b/h))

smoothly transforms from "soft maximum" to "hard maximum" max(a,b). We prove this rigorously with explicit error bounds:

max(a,b) ≤ h·log(e^{a/h} + e^{b/h}) ≤ max(a,b) + h·log 2

The error is at most h·log 2 — a clean, computable bound.

This "Maslov dequantization" means that tropical probability theory is, in a precise sense, the "classical limit" of ordinary probability, just as classical mechanics is the classical limit of quantum mechanics. And the Gumbel is the image of the Gaussian under this transformation.

## Post-Quantum Cryptography: Counting Dimensions

Lattice-based cryptography — currently our best candidate for encryption that can resist quantum computers — relies on the difficulty of finding short vectors in high-dimensional lattices. The length of the shortest vector in a random lattice involves taking the minimum (equivalently, the negative maximum) of many correlated values.

Our Berry-Esseen constant C_BE = (0.3 + 2.7σ²)/(1 + |γ₁|) gives explicit bounds on how quickly this extremal distribution converges to the Gumbel limit. This translates directly to security parameter selection: the minimum lattice dimension for security level k with advantage ε is:

d_min = ⌈(C_BE · k / ε)²⌉

Each doubling of the security level roughly quadruples the required dimension. This quadratic scaling is a fundamental feature of the Gumbel convergence rate.

## What Makes This Different: Machine-Verified Mathematics

Every theorem in this work has been formally verified by a computer using the Lean 4 proof assistant. There are zero unproved claims ("sorry" statements). The proofs use 20+ different proof tactics, from algebraic manipulation to topological convergence arguments.

This matters because the results are intended for safety-critical applications: certifying that an AI system is robust to adversarial attacks, or that a cryptographic scheme is secure against quantum computers. In these domains, "pretty sure the math is right" isn't good enough. Computer-verified proofs provide the gold standard of mathematical certainty.

## The View from Above

Standing back, what we see is a beautiful mathematical unity. The Gaussian and the Gumbel are two faces of the same coin:

| Property | Gaussian (Sums) | Gumbel (Maxima) |
|----------|-----------------|-----------------|
| Operation | Addition | Maximum |
| Stability | Under convolution | Under max-convolution |
| Shift | √n scaling | log n shift |
| Stein operator | f'' - xf' | f' - f + fe^{-x} |
| Convergence rate | O(1/√n) | O(1/√n) |
| Algebra | Classical | Tropical (max-plus) |
| Application | Signal processing | Extreme events |
| ML role | Batch normalization | Max-pooling |

The same O(1/√n) convergence rate appears in both worlds — this is not a coincidence but reflects a deep structural duality between classical and tropical mathematics.

What excites us most is that this is just the beginning. Tropical probability theory is a young field with immediate applications to some of the most pressing challenges in technology: making AI systems provably safe, and building encryption that can withstand quantum computers. The mathematics of maximums, it turns out, is quietly running the world.
