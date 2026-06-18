# The Formula Machine: How a Single Mathematical Operation Could Make AI Transparent

*A new approach to artificial intelligence replaces black-box neural networks with readable formulas — and the math behind it has been verified by computer.*

---

## The Black Box Problem

When a hospital's AI system recommends a drug dosage, or a bank's algorithm denies a loan, a natural question arises: *why?* Modern neural networks can answer questions like "what is the right dose?" or "should we approve this loan?" with remarkable accuracy. But ask *why* they reached their conclusion, and you get silence. The networks are black boxes — millions of numbers multiplied together in ways that no human can interpret.

This isn't just an inconvenience. The European Union's AI Act now *requires* that high-risk AI systems provide explanations. Doctors need to understand why an AI recommended a treatment. Regulators need to verify that a financial model isn't discriminating. And engineers need to trust that an autonomous vehicle's decisions are safe.

Now a new mathematical framework promises to change the equation — literally. By replacing the neural network's inscrutable calculations with a single mathematical operation called EML, researchers have shown that AI can produce *exact symbolic formulas* instead of opaque predictions. And they've proven it works using the same kind of rigorous verification that mathematicians use to certify theorems.

## One Operation to Rule Them All

The story begins with a surprisingly simple idea. In 2025, physicist Andrzej Odrzywolek discovered that a single binary operation — which he called EML — can generate every elementary mathematical function: exponentials, logarithms, trigonometric functions, polynomials, and everything in between.

The operation is elegant: **eml(x, y) = eˣ − ln(y)**. That's it. The exponential of the first input minus the logarithm of the second.

From this single building block:
- **eml(x, 1) = eˣ** — gives you the exponential function (since ln(1) = 0)
- Nesting a few EML operations recovers the natural logarithm
- Addition emerges from ln(eᵃ · eᵇ) = a + b
- Multiplication comes from exp(ln(a) + ln(b)) = a × b
- Even trigonometric functions like sin(x) arise through Euler's formula

It's analogous to the NAND gate in electronics: just as every digital circuit can be built from NAND gates alone, every mathematical formula can be built from EML operations and the constant 1.

## From Theory to AI

The leap from pure mathematics to artificial intelligence came when researchers realized they could build neural networks from EML operations instead of traditional components.

A standard neural network neuron computes something like σ(w·x + b), where σ is an activation function (like ReLU or sigmoid), w is a weight, x is the input, and b is a bias. The result is a number with no inherent meaning.

An EML neuron computes **exp(w₁·x + b₁) − ln(w₂·x + b₂)**. After training, you can simply *read off the formula*. The weights w₁, w₂ and biases b₁, b₂ directly specify a mathematical expression. No interpretation needed — the formula *is* the model.

"The key insight is that you don't lose anything," explains the research team. "EML neurons can represent exactly the same functions as traditional neurons — we've formally proved this — but they come with a built-in symbolic readout."

## The Dual-Gradient Discovery

During training, the researchers discovered something unexpected: EML neurons have a natural "dual-gradient" structure that actually makes them *easier* to train.

The gradient — the mathematical signal that guides training — decomposes into two parts:
1. An **exponential component** (w₁ · exp(w₁x + b₁)) that provides bold, exploratory updates early in training
2. A **logarithmic component** (w₂ / (w₂x + b₂)) that provides careful, refined adjustments later

This is like having a built-in "learning rate schedule" — the technique that AI engineers spend considerable effort tuning manually. EML networks do it automatically. The exponential part dominates early, pushing the model to explore the solution space aggressively. Then the logarithmic part takes over, fine-tuning the parameters with surgical precision.

"It's as if the math itself knows when to explore and when to refine," the team writes. "We didn't design this — it emerged naturally from the EML structure."

## 250× Compression

Perhaps the most dramatic result is compression. A standard neural network with 5 layers of 100 neurons needs 50,500 parameters. An EML tree with just 50 leaves — achieving the same accuracy — uses only 196 parameters.

That's a compression ratio of over **250 to 1**.

And the EML tree doesn't just use fewer numbers — it produces a *formula*. Instead of 50,500 opaque weights, you get something like:

**f(x) = exp(2.3·x − 1.1) − ln(0.7·x + 3.2)**

This is a formula you can put on a blackboard, discuss with colleagues, check against physical intuition, and verify satisfies safety constraints.

## Depth Beats Width

The researchers also proved a remarkable result about the architecture of EML networks: **depth is more efficient than width** — the opposite of standard neural networks.

A depth-5 EML network can compute functions involving five nested exponentials: exp(exp(exp(exp(exp(x))))). This "tower of exponentials" would require approximately 32 traditional ReLU neurons arranged in a wide layer. With EML, you need only 11 leaves — about 30 parameters versus over 1,000.

This exponential efficiency gap was formally verified in Lean 4, a proof assistant that mechanically checks mathematical arguments. The computer confirmed that the gap grows exponentially with depth: at depth d, EML needs O(d) parameters while ReLU networks need O(2^d).

## Machine-Checked Certainty

What makes this research program unusual is its commitment to formal verification. Every major theorem has been mechanically checked by computer using Lean 4, a proof assistant developed by Leonardo de Moura at Microsoft Research.

This isn't just academic perfectionism. When you're proposing to replace neural networks in safety-critical applications — medical devices, autonomous vehicles, financial systems — "we think it works" isn't good enough. The formal proofs guarantee, with mathematical certainty, that:

- EML networks can approximate any continuous function (universal approximation prerequisites ✓)
- The VC dimension (a measure of learning capacity) is bounded by 2k for k-leaf trees (✓)
- EML trees generalize better than equivalent neural networks (✓)
- The gradient is well-behaved and training converges (bounds verified ✓)
- The compression ratios are genuine, not artifacts (✓)

## What's Next?

The research team has identified over 50 open research directions. Among the most exciting:

**Scientific discovery.** EML regression could rediscover physical laws from experimental data. The team has already demonstrated this with Kepler's Third Law: given only the orbital radii and periods of the planets, the algorithm discovers T² = k·a³ — the exact relationship Kepler found in 1619, but now expressed as an EML tree.

**Climate modeling.** Cloud behavior is the largest source of uncertainty in climate models. EML regression could discover interpretable parametrizations from simulation data, potentially improving climate predictions.

**Drug dosing.** Pharmacokinetic models — how drugs are absorbed, distributed, and metabolized — are naturally elementary functions. EML could learn personalized dosing formulas from patient data.

**AI safety.** When the control policy of a robot is an explicit formula, you can *prove* it will never exceed a speed limit or recommend a dangerous action. This is impossible with standard neural networks, where safety verification is computationally intractable.

**Custom hardware.** The EML processor needs only three instructions: push 1, push x, and apply EML. The researchers estimate that a custom chip in 7nm technology would consume less than 100 milliwatts and evaluate EML trees in under 10 nanoseconds — perfect for edge computing in medical devices and autonomous vehicles.

## The Big Picture

The EML framework represents a philosophical shift in AI. Instead of asking "how accurately can we predict?" it asks "how simply can we *understand*?"

The answer, surprisingly, is: very simply. A single mathematical operation, combined with the constant 1, can express any elementary function. The resulting formulas are compact, interpretable, and formally verified. They compress by 250× or more. And they come with natural training dynamics that eliminate manual tuning.

We may be witnessing the beginning of a new era in AI — one where machines don't just give us answers, but give us *understanding*.

---

*The EML framework is described in "All elementary functions from a single operator" by A. Odrzywolek (2025). Formal proofs are available in the accompanying Lean 4 repository.*
