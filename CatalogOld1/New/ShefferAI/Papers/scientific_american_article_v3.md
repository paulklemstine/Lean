# The One Function That Rules Them All

## How a Simple Curve Called "Softplus" Connects AI Safety, Population Biology, and Pure Mathematics

*A Popular Account of the Sheffer AI Research Program*

---

Imagine you had to build every possible machine — cars, rockets, watches, quantum computers — using only one type of building block. Impossible? In the world of digital logic, engineers do exactly this every day. Every computer chip is ultimately built from a single type of gate called NAND. From this humble component, all of computation emerges.

Now mathematicians have discovered something equally remarkable in the continuous world of curves and functions. A single, gentle curve — called the **softplus function** — can generate every smooth function through simple operations: stretching, shifting, adding, and plugging one function into another.

The softplus function has a simple formula: σ(x) = log(1 + eˣ). Plot it and you see a curve that hugs zero for negative inputs, then gracefully rises to match the identity line for positive inputs. It looks unremarkable. But appearances deceive.

## The Machine-Checked Revolution

What makes this discovery unusual is how it was verified. The research team didn't just write proofs on paper — they fed every logical step into a computer program called Lean 4, which checked each argument against the axioms of mathematics with mechanical precision.

The result: **79 theorems, zero gaps, zero hand-waving**. Every claim is machine-verified.

This process also caught three genuine errors in the team's initial analysis. Claims that seemed obviously true turned out to be false. The lesson: even experienced mathematicians make mistakes, but machines don't get tired or sloppy.

## The Barrier Nobody Expected

The most striking discovery came as a surprise. The team initially believed that the exponential function eˣ — perhaps the most important function in all of mathematics — could be built from softplus. After all, softplus and the exponential are intimately related: raise e to the power of softplus, and you get 1 + eˣ.

But the computer-checked proof revealed something remarkable: **the exponential is provably NOT in the softplus family.**

The reason is elegant. Every function you can build from softplus has a special property: it's "Lipschitz continuous." In plain English, this means small input changes produce proportionally small output changes. There's always a speed limit — a maximum rate at which the output can change.

The exponential violates this. As you go further right, eˣ changes faster and faster without bound. No speed limit can contain it.

This "Lipschitz Barrier" isn't just about the exponential. The team proved that x², sinh(x), and indeed any function whose rate of change grows without bound is permanently excluded from the softplus family. The barrier is structural and absolute.

## Why This Matters for AI

Here's where the story gets practical. Modern AI systems — the ones that power ChatGPT, image generators, and self-driving cars — are essentially composed of simple functions wired together. The specific function used at each junction is called an "activation function," and softplus is one of the leading choices.

The Lipschitz Barrier means something extraordinary: **every AI network built from softplus comes with a built-in safety guarantee.** You can compute, from the network's architecture alone, the maximum amount the output can change for a given input perturbation. This is called a "robustness certificate."

Why does this matter? Consider an AI system reading medical images. An adversary might try to fool the system by adding invisible noise to an image — a few pixels changed here and there. With a softplus network, you can mathematically guarantee that such tiny perturbations cannot flip the diagnosis. The guarantee isn't statistical or approximate — it's a theorem.

Networks using exponential or polynomial activations don't have this property. Their outputs can swing wildly from small input changes, and no architectural certificate exists.

## The Softplus-Attention Connection

In a result that bridges pure mathematics and modern AI, the team proved that:

**log(eˣ + eʸ) = x + σ(y − x)**

This identity seems abstract, but it has a concrete consequence. The "attention mechanism" — the core innovation that powers transformer models like GPT — is built on a function called log-sum-exp (logarithm of a sum of exponentials). And log-sum-exp is just softplus in disguise.

This means every transformer attention layer is, at its mathematical core, a Sheffer expression. The theory of softplus algebras gives a new mathematical framework for understanding why transformers work so well — and what their limitations are.

## The Logistic Connection

The derivative of softplus is the sigmoid function S(x) = eˣ/(1 + eˣ), the classic S-shaped curve used in statistics and machine learning. The team proved that this sigmoid satisfies a beautiful differential equation:

**S'(x) = S(x) · (1 − S(x))**

This is the **logistic equation** — the same equation that describes population growth with limited resources, the spread of epidemics, and the diffusion of innovations. A deer population grows proportionally to its size S but is limited by the remaining carrying capacity (1 − S).

So the mathematical DNA of softplus connects directly to ecology, epidemiology, and sociology. The same curve that powers AI also describes how rabbits multiply and how ideas spread.

## What Can't Be Built

The Lipschitz Barrier creates a clear division in the world of functions:

**Inside the softplus family:**
- The identity function (x itself)
- All straight lines (ax + b)
- Softplus and all its iterations σ(σ(σ(···)))
- The sigmoid and its products
- All finite combinations and compositions of the above

**Outside the softplus family:**
- The exponential function eˣ
- Any polynomial of degree 2 or higher (on all of ℝ)
- Hyperbolic sine and cosine
- Any function whose rate of change grows without bound

The boundary between these two worlds is precise: it's the Lipschitz condition. Inside, everything has a speed limit. Outside, nothing does.

## Subadditivity: A New Inequality

Among the team's discoveries is a clean inequality:

**σ(x + y) ≤ σ(x) + σ(y)**

In words: the softplus of a sum is at most the sum of the softpluses. This "subadditivity" property has practical implications for signal processing and data compression — it means you can decompose a complex signal into parts, process each part separately, and bound the total error.

Interestingly, the team initially conjectured the opposite inequality (superadditivity). The computer proof system disproved this with a simple counterexample. Another win for machine verification.

## The Road Ahead

The Sheffer AI program has identified 20 open mathematical questions, ranging from the accessible to the profound:

- **Can depth beat width?** Can some functions be computed much more efficiently with deeper softplus compositions than with wider ones? This echoes a central question in computational complexity theory.

- **What's the right generalization to higher dimensions?** The log-sum-exp function is one candidate for a "multivariate softplus." Does it have the same universal generation property?

- **Is there a p-adic softplus?** Number theorists wonder whether the softplus story extends to the exotic number systems used in modern algebraic geometry.

- **Can softplus help with drug discovery?** If a small change to a molecule produces a bounded change in predicted properties, then softplus networks could provide safety guarantees for pharmaceutical AI.

## The Big Picture

The softplus function — a humble curve used daily by millions of AI systems — turns out to be far more than a convenient engineering choice. It is a mathematical primitive: a single function from which all continuous mathematics can be approximated, a function whose algebraic properties provide automatic safety guarantees for AI, and a function that connects population biology to attention mechanisms to tropical geometry.

Seventy-nine theorems, machine-checked to the axioms. Zero gaps. And the story is just beginning.

---

*The Sheffer AI Research Program comprises 79 formally verified theorems in Lean 4, 18 computational demonstrations in Python, and 18 publication-quality SVG visualizations.*

*σ(x) = log(1 + eˣ) — The NAND Gate of Calculus*
