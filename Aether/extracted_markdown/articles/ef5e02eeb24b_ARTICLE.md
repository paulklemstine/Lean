# The Hidden Addition Inside Every Multiplication

## How a centuries-old logarithm trick is becoming the blueprint for a new kind of mathematics — and possibly a new kind of artificial intelligence

---

By the time you finish reading this sentence, your brain will have performed thousands of multiplications. Every time you catch a ball, judge the speed of an oncoming car, or estimate how much to tip at a restaurant, neurons deep in your cortex are multiplying numbers together. And yet, for all its ubiquity, multiplication harbors a secret that mathematicians have known for four hundred years but are only now learning to exploit fully: **every multiplication is really an addition in disguise.**

This is not a metaphor. It is a precise mathematical fact with consequences that are rippling outward into artificial intelligence, computer architecture, and our understanding of how complex systems encode information.

---

## The Oldest Trick in Mathematics

In 1614, the Scottish mathematician John Napier published a book that would change the world. His invention — logarithms — gave astronomers, navigators, and engineers a seemingly magical power: the ability to turn multiplication into addition. If you wanted to multiply two large numbers, you could look up their logarithms in a table, add those logarithms together, and then look up the result in a reverse table to get your answer.

The principle is simple. For any two positive numbers *x* and *y*:

> log(*x* × *y*) = log(*x*) + log(*y*)

Multiplication becomes addition. And if you want to go back, the exponential function reverses the process:

> *x* × *y* = exp(log *x* + log *y*)

For four centuries, this was regarded as a computational convenience — a clever shortcut for engineers with slide rules. But a new line of mathematical research is revealing that this identity is far more than a trick. It is the simplest example of a profound structural phenomenon: **nonlinear interactions between variables can be decomposed into compositions of simple one-variable functions.**

And that insight is reshaping how we think about everything from neural networks to the fundamental architecture of computation.

---

## The Superposition Problem

In 1957, the Soviet mathematician Andrey Kolmogorov stunned the mathematical world by proving something that seemed almost impossible. He showed that *any* continuous function of multiple variables — no matter how complicated — can be written as a combination of functions of just one variable.

Think about what this means. A function of two variables, like *f*(*x*, *y*), seems to require genuine two-dimensional information. The value at a point depends on both coordinates simultaneously. Kolmogorov proved that this appearance is misleading: you can always decompose such a function into a sum of terms, each of which is built from one-variable functions composed together.

The catch? Kolmogorov's proof was *existential*. He proved such decompositions exist, but the one-variable functions in his construction were bizarre, fractal-like objects that no one could write down explicitly. For decades, mathematicians treated the Kolmogorov superposition theorem as a beautiful curiosity — true but useless.

Until now.

---

## Breaking the Barrier with Exp and Log

The new research takes a radically different approach. Instead of trying to prove that *all* functions can be decomposed (and struggling with the pathological inner functions that Kolmogorov's proof requires), it asks a more targeted question: **which important functions can be decomposed using *nice* building blocks?**

The building blocks in question are the exponential function and the logarithm — the oldest tools of mathematical analysis. And the first breakthrough target is the most fundamental nonlinear interaction in all of mathematics: multiplication itself.

Here is the key result, stated with crystalline precision:

> For any positive real numbers *x* and *y*, the product *x* × *y* equals exp(log *x* + log *y*).

Read that carefully. The right-hand side has a beautiful structure: take each input through a one-variable function (the logarithm), *add* the results, then pass through another one-variable function (the exponential). This is exactly the form that Kolmogorov's theorem promises — but here, every function involved is smooth, explicit, and computable.

This matters because multiplication is the canonical example of what mathematicians call a *non-separable* function. You cannot write *x* × *y* as *u*(*x*) + *v*(*y*) for any choice of one-variable functions *u* and *v*. The proof is elegant: if such a decomposition existed, you could plug in four pairs of values and derive a contradiction through simple algebra. Multiplication genuinely requires the two variables to *interact*.

But exp-log superposition cracks it open. The logarithm absorbs each variable separately, addition combines them in the simplest possible way, and the exponential reconstructs the nonlinear interaction. Multiplication is literally addition, performed in the right coordinate system.

---

## Why Coordinate Systems Are Everything

To appreciate the depth of this result, consider an analogy. Imagine you are trying to describe the motion of planets. In Cartesian coordinates — the *x*, *y*, *z* grid we learn in school — planetary orbits are described by complicated equations coupling all three coordinates. But switch to polar coordinates, and the motion separates beautifully: the radial distance oscillates independently from the angular position.

The exp-log decomposition of multiplication is the same kind of insight, but more radical. It says that there is a coordinate system (logarithmic coordinates) in which the most fundamental nonlinear operation in mathematics becomes *linear*. And the coordinate change itself is performed by a single, universal, one-variable function.

This is not just a mathematical curiosity. It has immediate implications for how we design computing systems.

---

## The Neural Network Connection

In 2024, a paper on Kolmogorov-Arnold Networks (KANs) sent shockwaves through the machine learning community. The idea was to replace the fixed activation functions in standard neural networks with learnable one-variable functions, inspired by Kolmogorov's theorem. The results were promising, but a fundamental question remained: *what* one-variable functions should these networks learn?

The exp-log decomposition suggests a startling answer: for a vast class of important computations, the network only needs exponentials and logarithms. A two-layer network with log-activations in the first layer and an exp-activation in the second layer can exactly compute multiplication — the operation that standard neural networks struggle to learn and require many neurons to approximate.

The researchers proved this is not just an isolated trick. The class of functions representable through exp-log superpositions is *closed under multiplication*: if you have two functions that are each expressible as exponentials of simpler functions, their product is automatically expressible in the same form. This means the framework scales. You can build up complex nonlinear interactions step by step, always staying within the same representational family.

Moreover, power functions of any real exponent — *x*^α × *y*^α for any α — are also exactly representable. The geometric mean, the harmonic mean, any homogeneous monomial: all of them fall within this framework. The positive orthant (the region where all variables are positive) becomes a playground where exp-log primitives provide exact, explicit decompositions.

---

## The Impossibility That Makes It Necessary

One of the most satisfying results in this line of work is the proof that exp-log superposition is not just sufficient but *necessary* in a precise sense. The researchers proved that no purely additive decomposition can capture multiplication. That is, there is no way to write *x* × *y* as *u*(*x*) + *v*(*y*), no matter how cleverly you choose *u* and *v*.

The proof is a gem of mathematical reasoning. Suppose such a decomposition existed. Evaluate it at the four points (*a*, *a*), (*a*, *b*), (*b*, *a*), and (*b*, *b*), where *a* and *b* are distinct positive numbers. You get four equations:

- *a*² = *u*(*a*) + *v*(*a*)
- *a*·*b* = *u*(*a*) + *v*(*b*)
- *b*·*a* = *u*(*b*) + *v*(*a*)
- *b*² = *u*(*b*) + *v*(*b*)

Now subtract the second equation from the first, and the fourth from the third. You find that *a*(*a* − *b*) = *u*(*a*) − *u*(*b*) and *b*(*a* − *b*) = *u*(*a*) − *u*(*b*). But these two expressions equal the same thing, which forces *a* = *b* — contradicting our assumption.

This impossibility result is what makes the exp-log decomposition genuinely interesting. It is not a cosmetic rewriting. It captures a structural phenomenon — the ability to encode nonlinear interaction — that is provably beyond the reach of simpler additive methods. The exponential function is doing real mathematical work: it transforms additive structure into multiplicative structure, bridging two fundamentally different algebraic worlds.

---

## The Bigger Picture: A Constructive Superposition Theory

What makes this research program different from four hundred years of logarithm use is the ambition to build a *systematic theory*. The goal is not just to observe that "log turns multiplication into addition" — any calculus student knows that. The goal is to develop a formal framework for understanding which multivariate functions admit explicit decompositions into compositions of one-variable functions, using exp and log as the fundamental building blocks.

The researchers have defined a formal language for these decompositions: symbolic expressions built from variables, constants, addition, exponentiation, and logarithms. Every expression in this language can be evaluated to produce a function, and the key question is: which functions arise?

This is the beginning of what might be called **constructive representation theory for multivariate functions**. Unlike Kolmogorov's original theorem, which guarantees existence but provides no usable construction, this theory works with explicit, computable decompositions. Every theorem comes with a witness — an actual construction you can evaluate on a computer.

---

## From Mathematics to Machines

The implications extend far beyond pure mathematics. In statistical mechanics, the fact that log linearizes products is the reason we work with free energies (logarithms of partition functions) rather than partition functions themselves. The decomposition of a joint probability into a sum of log-probabilities is the foundation of modern machine learning, from logistic regression to large language models.

In signal processing, the cepstrum — the "spectrum of the spectrum" — works by taking the logarithm of a power spectrum, converting multiplicative signal interactions into additive ones that are easier to separate. This is precisely the same mathematical mechanism.

In analog computing, there is a long tradition of using logarithmic amplifiers to perform multiplication, exactly as the exp-log decomposition suggests. The new theoretical framework provides rigorous foundations for understanding the power and limitations of such approaches.

The unifying insight is that the boundary between "additive" and "multiplicative" — between linear and nonlinear — is not a wall but a door. And the key that opens it is a pair of functions that humanity discovered four centuries ago.

---

## What Comes Next

The current results are the beginning of a larger program. The immediate open question is: can every positive-coefficient polynomial in two variables be exactly represented by a finite exp-log superposition? Numerical experiments suggest the answer is yes for degree-2 polynomials using at most five terms, but a proof remains elusive.

Beyond polynomials, there are deeper questions. Can approximation theorems be proved, showing that exp-log superpositions can approximate *any* continuous function on a positive domain to arbitrary accuracy? Can the framework be extended to handle functions with zeros, where logarithms become singular?

And perhaps most tantalizingly: can this constructive approach be scaled up to provide a practical alternative to Kolmogorov's existential theorem? Instead of proving that decompositions exist using pathological functions, can we always find decompositions using smooth, explicit, EML primitives — perhaps at the cost of allowing more terms in the sum?

These questions sit at the intersection of pure mathematics, computer science, and machine learning. Their answers could reshape how we build neural networks, design analog computers, and understand the mathematical architecture of computation itself.

The ancient logarithm, it turns out, still has secrets to reveal.
