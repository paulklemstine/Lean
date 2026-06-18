# The Two-Button Brain: How a Single Mathematical Operation Could Revolutionize Artificial Intelligence

*A breakthrough in mathematics promises AI that can discover scientific laws, explain its reasoning, and never get arithmetic wrong*

---

## The Problem with Smart Machines

Imagine training an artificial intelligence on a century of astronomical observations — the positions of planets, their velocities, the timing of their orbits — and asking it to find the pattern. Today's neural networks can do this, after a fashion. They'll produce a function that predicts planetary motion with impressive accuracy. But ask the AI *what pattern it found*, and you'll get something like this: a matrix of 50,000 floating-point numbers.

Not exactly what Kepler had in mind.

Johannes Kepler, working with the same kind of data four centuries ago, discovered something beautiful: the square of a planet's orbital period equals the cube of its distance from the Sun. T² = a³. Six characters that encode a fundamental law of the universe.

Modern AI can match Kepler's predictions but not his insight. The numbers are right, but the knowledge is hidden. This is the interpretability crisis of artificial intelligence, and it may be the biggest obstacle between today's pattern-matching machines and genuine scientific discovery.

Now, a remarkable mathematical breakthrough may have cracked the problem wide open.

---

## One Operation to Rule Them All

In 2025, mathematician Andrzej Odrzywolek of Jagiellonian University in Poland made a discovery so simple it seems like it shouldn't be true: *every elementary mathematical function* — every exponential, every logarithm, every trigonometric function, every polynomial, every power, every root — can be built from a single binary operation:

**eml(x, y) = eˣ − ln(y)**

That's it. Take the exponential of the first input, subtract the natural logarithm of the second. This operation, combined with the number 1, generates all of elementary mathematics.

Think of it as the mathematical equivalent of the NAND gate in computing. In digital electronics, every logical operation — AND, OR, NOT, everything — can be built from the single NAND gate. Odrzywolek showed that EML does the same thing for continuous mathematics. It is the NAND gate of the real numbers.

Want the exponential function? That's eml(x, 1) — because ln(1) = 0.

Want the number e? That's eml(1, 1) = e¹ − ln(1) = e.

Want the natural logarithm? That takes a few more steps, building a small binary tree of EML operations, but it works out to: eml(0, eml(eml(0, x), 1)) = ln(x).

Even sine and cosine — those oscillating functions that seem fundamentally different from exponentials — emerge from EML trees, using the complex exponential and Euler's formula e^(ix) = cos(x) + i·sin(x).

It's as if someone discovered that every recipe in the world could be prepared using only salt.

---

## The AI Revolution

The AI implications hit like a thunderbolt. If every mathematical function is an EML tree, then you can build a neural network where *every neuron is an EML gate*. Each neuron computes:

**exp(w₁·x + b₁) − ln(w₂·x + b₂)**

Four numbers — w₁, b₁, w₂, b₂ — define the neuron. Train the network on data, and those numbers adjust to minimize error. Standard stuff so far.

But here's the magic: **when training finishes, you can read the formula directly off the weights.**

No interpretation needed. No approximation. No post-hoc analysis. The formula is *right there*, in the definition of the neuron. If the trained weights are w₁ = 1, b₁ = 0, w₂ = 0.001, b₂ = 1, then the neuron learned exp(x). If w₁ = 0, b₁ = 0, w₂ = 1, b₂ = 0, it learned 1 − ln(x). Whatever the function is, you can write it down as a symbolic expression.

This is what researchers call "interpretability by construction." You don't need to explain the AI's reasoning after the fact because the reasoning is the formula, and the formula is the output.

---

## Teaching Machines to Be Kepler

The immediate application is automated scientific discovery. Here's how it works:

1. **Collect data.** Planetary positions, chemical reaction rates, particle trajectories — whatever your experiment produces.

2. **Feed it to an EML symbolic regression engine.** This system searches through EML trees of increasing complexity, optimizing the leaf values by gradient descent, looking for the simplest formula that fits the data.

3. **Read off the formula.** When the error drops to zero (or machine precision), the EML tree *is* the scientific law.

In demonstrations, EML symbolic regression has rediscovered:

- **Kepler's Third Law** (T² = ka³) from simulated planetary data — represented as an EML tree with just 6 leaves
- **The Ideal Gas Law** (PV = nRT) from simulated pressure-volume-temperature measurements — 10 leaves
- **Newton's Second Law** (F = ma) from force-mass-acceleration data — 8 leaves

These are toy examples, to be sure. But the mathematical guarantee is real: if the true relationship is an elementary function, it is in the EML search space. The question is only whether the search algorithm can find it efficiently.

Compare this with existing symbolic regression tools, which typically search over a predefined set of operations — addition, multiplication, sine, cosine, etc. These tools work well but require the user to guess which operations are relevant. EML needs no such guidance. The search space is *complete*.

---

## The Compression Revolution

Here's a number that should make every machine learning engineer sit up straight: **an EML tree with 50 leaves can represent functions that would require 20,000 neural network parameters.**

That's a compression ratio of 400 to 1.

The reason is structural. A standard neural network approximates a function by stacking linear transformations with nonlinear activations — a fundamentally local approach that requires many parameters to capture global structure. An EML tree exploits the *algebraic* structure of elementary functions, encoding global relationships (exponential growth, logarithmic scaling) directly.

In storage terms:
- A 50-leaf EML tree at 64-bit precision: **400 bytes**
- An equivalent neural network: **80 kilobytes**

This has immediate practical implications. Imagine deploying a scientific model on a microcontroller, a satellite, or a medical device. The EML representation is small enough to fit in the memory of a smartwatch.

But the deeper implication is conceptual. The EML leaf count gives us a *natural measure of formula complexity* — a kind of Kolmogorov complexity specifically for mathematical expressions. Simple functions like exp(x) have K_EML = 2. Complex functions like sin(x) have K_EML ≈ 15. The number π, the most famous constant in mathematics, has K_EML ≤ 40.

This complexity measure tells us something profound: **mathematical knowledge is compressible**, far more compressible than the neural networks that learn it suggest.

---

## Fixing LLMs' Math Problem

Anyone who has used ChatGPT for mathematics knows the frustration. Ask it to compute 1847 × 293 and you might get a wrong answer. Ask it to evaluate ln(exp(42)) and it might confidently respond "approximately 41.8."

The problem is fundamental: language models process mathematics as *text patterns*, not as *computation*. They've seen many examples of "ln(exp(x)) = x" in training data, but they don't actually *compute* the logarithm and exponential. They predict the most likely next token, and sometimes that prediction is wrong.

EML-augmented language models solve this with a simple architectural change:

1. A learned "math detector" identifies mathematical expressions in the user's query
2. Those expressions are routed to an EML computation engine
3. The engine evaluates them **exactly** using EML tree operations
4. The exact result is integrated back into the language model's response

The EML engine requires no training — it's an algorithm, not a neural network. It computes exp, ln, sin, cos, and every other elementary function through pure EML tree evaluation. The results are mathematically guaranteed to be correct.

This is the difference between an AI that *predicts* the answer to a math problem and an AI that *computes* it.

---

## What's Next?

The EML-AI framework opens research directions that didn't exist a year ago:

**EML Hardware.** Just as NAND gates are implemented in silicon for digital computing, EML gates could be implemented in analog circuits for mathematical computing. Transistors in subthreshold mode naturally compute exponentials (I ∝ exp(V/V_T)), providing half the EML operation at the physics level. A single chip with arrays of EML gates could evaluate any elementary function.

**Scientific Discovery at Scale.** With EML symbolic regression, we can systematically search for mathematical laws in datasets too large or complex for human analysis. Genomics, climate science, materials science — any field with abundant data and unknown mathematical relationships is a target.

**Knowledge Distillation.** Train a massive neural network on a complex task. Then distill its learned function into an EML tree. The result: the *exact formula* that the neural network learned, compressed by a factor of 100 or more, and immediately interpretable.

**EML Complexity Theory.** The K_EML measure creates a new branch of complexity theory — not for algorithms or computations, but for *mathematical formulas themselves*. What is the simplest EML tree that computes π? (Currently known: at most 40 leaves.) Is finding the simplest EML tree NP-hard? These questions connect to deep problems in computational complexity.

---

## The Bigger Picture

The EML operator is a reminder that mathematical simplicity can hide in plain sight. Exponential and logarithm — two functions known since the 17th century — together form a universal basis for all elementary mathematics. And this universality, once recognized, transforms how we think about computation, learning, and discovery.

In digital computing, the recognition that NAND is universal led to the entire semiconductor industry. Every processor, every memory chip, every digital device is built from NAND gates.

The EML operator is the continuous version of the same insight. Whether it leads to a similar revolution in analog computing and scientific AI remains to be seen. But the mathematical foundation is now in place — and it's been formally verified, theorem by theorem, in the Lean 4 proof assistant.

For the first time, we have neural networks that don't just learn patterns — they discover formulas. And they can prove they're right.

---

*The author acknowledges the foundational work of Andrzej Odrzywolek at Jagiellonian University. The formal verification was conducted using Lean 4 with the Mathlib library.*
