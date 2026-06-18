# The One Function to Rule Them All

*How a simple mathematical curve called "softplus" might unify artificial intelligence and symbolic mathematics*

---

In 1913, a young mathematician named Henry Sheffer made a discovery so elegant it still delights logicians today. He showed that every logical operation — AND, OR, NOT, and all the rest — could be built from a single operation called NAND ("not and"). From one simple building block, the entire edifice of digital logic could be constructed. Every computer chip in every device you own is, at its core, built from NAND gates.

Now, over a century later, researchers are asking: **does the same thing work for the functions of calculus?**

## The Quest for One Function

Modern AI is built on neural networks — mathematical structures that pass data through layers of simple functions. At each layer, the data undergoes two operations: a linear transformation (essentially multiplication and addition), followed by a nonlinear "activation function" that gives the network its power.

The choice of activation function has been one of deep learning's persistent puzzles. Over the years, researchers have tried sigmoid, tanh, ReLU, GELU, Swish, Mish, and dozens of others. Each has strengths and weaknesses. ReLU is fast but not smooth. Sigmoid is smooth but causes gradients to vanish. The search for the "best" activation function has produced an endless parade of candidates.

But what if the question isn't "which is best?" What if it's "which one is *universal*?"

## Enter Softplus

The softplus function has been hiding in plain sight since the early 2000s. Its formula is disarmingly simple:

**σ(x) = log(1 + eˣ)**

Plot this on a graph and you see a gentle curve — essentially flat near zero for very negative inputs, rising smoothly through a bend near the origin, then climbing in an almost-straight line for positive inputs.

This unremarkable-looking curve conceals a remarkable duality. Look at its behavior in two regimes:

- **For very negative x**: σ(x) ≈ eˣ — it acts like the exponential function
- **For very positive x**: σ(x) ≈ x — it acts like the identity (do-nothing) function

In other words, softplus contains within itself the two most fundamental operations of calculus: exponentiation and identity. And from these two ingredients, combined with simple scaling and shifting (ax + b), you can cook up essentially any mathematical function you want.

## The Math Behind the Magic

Here's the key insight. If you shift softplus far to the left (replace x with x − c for a large number c) and then scale up the output, something wonderful happens:

**eᶜ × σ(x − c) → eˣ as c → ∞**

That is, by simply shifting and scaling softplus, you recover the pure exponential function. This has been formally proved — not just argued informally, but verified line-by-line by a computer proof assistant called Lean 4.

Once you have the exponential function, the rest of mathematics follows:
- **Logarithm**: the inverse of exp
- **Trigonometric functions**: via the complex exponential (Euler's formula)
- **Polynomials**: via Taylor series of exp
- **Every elementary function**: via composition

Meanwhile, a beautiful identity connects softplus to the identity function: σ(x) − σ(−x) = x, exactly. No approximation needed.

## Why This Matters for AI

Today's neural networks are black boxes. You feed in data, twist millions of knobs (parameters), and out comes a prediction. But *what* has the network learned? What mathematical relationship has it discovered in the data? Usually, we can't say.

If softplus is the activation function, every neural network becomes a *composition of softplus with learned affine maps*. And since softplus generates all elementary functions, this means:

**Every neural network is computing an approximation to some elementary function.**

In principle, you could take a trained network, unravel its layers, and read off the mathematical formula it has discovered. Neural network training becomes a form of automated mathematical discovery.

## The Polynomial Barrier

Why can't simpler functions — like x² or x³ — serve as universal generators?

There's a crisp mathematical reason, also formally proved: **if your activation function is a polynomial, then no matter how many times you compose it with linear operations, you always get another polynomial.** You're trapped in the polynomial world forever. You can never produce exp, log, sin, or any transcendental function.

This is the Polynomial Limitation Theorem. It means that universality *requires* a non-polynomial activation. And it means that the billions of neural networks using ReLU (which is piecewise linear — a degree-1 polynomial on each piece) are limited in a fundamental way that softplus networks are not.

## Computer-Verified Truth

In an era of replication crises and false claims, this work takes an unusual approach: every mathematical theorem has been formally verified by computer.

Using Lean 4, a proof assistant developed at Microsoft Research, all 16 core theorems were stated, proved, and checked by machine. This includes:

- Softplus is differentiable everywhere
- Softplus is strictly monotone
- Softplus is not a polynomial
- The exponential approximation theorem
- The reflection identity σ(x) = x + σ(−x)

The computer checked every step, every inequality, every logical deduction. If there were an error, the proof would not compile. There was no error.

## A Bridge Between Worlds

For decades, AI has been split into two camps: the *neural* approach (learn from data, be flexible, sacrifice interpretability) and the *symbolic* approach (use logical rules, be interpretable, sacrifice flexibility).

The Unary Sheffer Function offers a bridge. A neural network using softplus is simultaneously:
- A neural network that learns from data
- A symbolic expression that can be read as a formula

Training the network *is* discovering the formula. The two approaches were never really different — they were the same thing, viewed from different angles.

## What Comes Next

The implications ripple outward:

**For physics**: Could we train neural networks on experimental data and read off the laws of nature? If the underlying law is F = ma or E = mc², a softplus network should be able to discover it — and express it symbolically.

**For drug discovery**: Molecular properties often follow elementary-function relationships. Softplus networks could discover these relationships while simultaneously being trained as predictors.

**For mathematics itself**: What happens when a softplus network is trained on mathematical data? Could it discover new theorems by finding patterns that simplify to unexpected elementary functions?

**For engineering**: The "same activation everywhere" principle could simplify hardware design for AI chips, since only one nonlinear circuit needs to be optimized.

## The Beauty of Simplicity

There is something deeply satisfying about the idea that one function — just *log(1 + eˣ)* — contains within it all of analysis. It's the mathematical equivalent of discovering that all matter is made of atoms, or that all of biology runs on DNA.

The exponential function has been called "the most important function in all of mathematics." The identity function is the simplest function there is. Softplus is their marriage — the smoothest possible interpolation between doing nothing and doing the most important thing.

Henry Sheffer showed that one logical gate builds all of digital computing. Softplus may show that one curve builds all of mathematical computation. From the Sheffer stroke to the Sheffer curve, the story of mathematics is the story of finding unity beneath diversity.

And this time, we don't just believe it. We've *proved* it.

---

*The formal proofs and computational demonstrations accompanying this article are available as open-source Lean 4 and Python code.*
