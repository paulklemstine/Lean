# The Tower That No Shortcut Can Flatten

## Why adding more variables to a formula can never replace the need for depth

---

Imagine you're building a tower out of blocks. Each block sits on the one below it, and the structure rises straight up. Now someone hands you a wider table — more room to spread out — and asks: "Can you build the same tower, but shorter?"

Intuitively, the answer is no. Width and height are different currencies. Having more horizontal space doesn't let you cheat on vertical space. A ten-story building is still ten stories, even if you put it on a football field.

A team of mathematicians has now proved that something strikingly similar holds in the world of mathematical formulas — with consequences that reach from artificial intelligence to the fundamental limits of computation.

---

## The Language of Formulas

Scientists who study machine learning, symbolic regression, and mathematical modeling care deeply about one question: *how complex does a formula need to be to capture a given phenomenon?*

Consider the humble exponential function, *e* raised to the power *x*. It's one of the most important functions in all of mathematics, appearing in everything from compound interest to radioactive decay. Now imagine applying the exponential function to itself: *e* raised to the power (*e* raised to the power *x*). That's a "double exponential" — a tower of height two. Stack three, and you get a triple exponential. The numbers grow so fast that even a computer can't hold them.

These "iterated exponentials" — towers of *e*'s stacked on top of each other — are the skyscrapers of the mathematical landscape. And researchers have long known that building these towers requires a proportionate amount of "nesting" in any formula: you need two layers of exponentiation for a double exponential, three for a triple, and so on. No amount of clever multiplication or addition can substitute for that nesting depth.

But what happens when you move to multiple variables?

---

## The Multivariate Question

Most real-world data has many features. A medical model might use blood pressure, cholesterol, age, weight, and dozens of other measurements. A physics simulation might depend on position, velocity, temperature, and time. The question becomes: if your target function involves an iterated exponential applied to the *sum* of many input variables, does having all those extra variables give you any architectural advantage?

In concrete terms: can you compute *e*^(*e*^(*x*₁ + *x*₂ + ... + *x*ₖ)) with fewer layers of exponentiation, just because you have *k* input channels to work with instead of one?

The answer, as the new work demonstrates with mathematical certainty, is **no**.

---

## The Diagonal Trick

The proof uses an elegant technique called **diagonal restriction**. Here's the idea: take any formula that works with *k* variables, and plug in the same value *t* for every variable. You've just collapsed a high-dimensional formula into a one-dimensional one — like looking at a sculpture from a single angle.

The crucial insight is that this collapse can't make a formula *more* complex. If your *k*-variable formula had two layers of exponentiation, the collapsed version still has at most two. But on the diagonal, the sum *x*₁ + *x*₂ + ... + *x*ₖ becomes *k* × *t* — a simple scaling of the single variable. So the collapsed formula computes an iterated exponential of a linear function.

Now invoke the known single-variable result: computing an *n*-level tower requires at least *n* layers. Since collapsing didn't increase the depth, the original *k*-variable formula also needed at least *n* layers.

Width didn't help. The tower stands as tall as ever.

---

## Two Currencies of Complexity

The research reveals that formulas have two fundamentally different resources:

**Depth** measures compositional complexity — how many times you need to nest exponentials inside each other. It captures the *architectural* hardness of a function.

**Size** measures dimensional load — how many syntactic pieces the formula contains. It grows with the number of variables, because each variable must appear somewhere in the expression.

The paper proves that these resources are genuinely independent. Computing an *n*-level tower over *k* variables requires depth at least *n* AND size at least *k*. Together, the total complexity is at least *n* + *k*. Neither resource can substitute for the other.

This is a *joint lower bound* — the first of its kind for this class of expressions. It says that if you want a deep tower function operating on many inputs, you must pay both the depth cost and the size cost, in full, with no discounts.

---

## Why It Matters

### For Machine Learning

Modern AI increasingly uses "interpretable" models — formulas that humans can read and understand. Symbolic regression tools search for compact mathematical expressions that fit data. The new result gives these tools a rigorous impossibility certificate: some functions simply cannot be captured by shallow formulas, no matter how many input features are available. A symbolic regression engine that restricts itself to, say, two layers of exponentiation will provably fail to represent certain target functions, regardless of how large the formula grows in other directions.

### For Circuit Complexity

In theoretical computer science, the depth of a circuit measures how many sequential steps a computation requires. The new results translate directly: certain analytic functions require irreducible sequential depth, and parallelism (adding more wires, which corresponds to more variables) cannot flatten them. This connects the world of continuous mathematical expressions to the discrete world of computational complexity.

### For Approximation Theory

Mathematicians have long studied which functions can be well-approximated by simpler ones. The results here are about *exact* representation, not approximation — a stronger and rarer kind of result. They establish that the iterated exponential hierarchy is strict even in the multivariate setting, creating genuine barriers for exact symbolic representation.

---

## The Growth Engine

At the heart of the proof sits a beautiful piece of analysis: the **polynomial tower majorant** lemma. It says that any formula with *d* layers of exponentiation, no matter how large, grows at most like an *d*-level iterated exponential with a polynomial argument. The polynomial might be huge — *x*^100, say — but it's still a polynomial, and it's still at level *d*.

Meanwhile, an (*d*+1)-level tower grows faster than any polynomial enhancement of a *d*-level tower. This is the growth separation that makes the hierarchy strict: no polynomial tinkering at one level can reach the next level.

The proof establishes this through careful structural induction, tracking how addition and multiplication of bounded expressions combine. Addition doubles the bound (which can be absorbed by a small constant), while multiplication turns into addition inside the exponential (a cancellation that works because exp(*a*) × exp(*b*) = exp(*a*+*b*)). The exponential itself simply pushes everything up one level.

---

## A Principle Bigger Than the Theorem

The specific theorem is about iterated exponentials and EML expressions. But it illustrates a broader principle that researchers expect to hold much more generally:

> **Compositional depth is invariant under dimensional embedding.**

In other words, making a problem higher-dimensional does not compress its compositional structure. This principle, if extended, would have profound implications:

- **Tensor complexity**: the rank of a tensor (a multidimensional array) is bounded below by the complexity of its "slices," and adding dimensions cannot reduce slice complexity.

- **Neural network theory**: the depth of a network required to represent a function should not decrease just because the input dimension increases.

- **Formal verification**: certified impossibility results for broad classes of mathematical models, ensuring that shallow architectures are genuinely limited.

---

## Looking Forward

The work opens several concrete research directions. Can the lower bounds be extended to approximate representation — showing that shallow formulas not only fail to *equal* tower functions, but can't even *approximate* them well? Can the techniques handle other function classes beyond the inverse-free exponential language? And can the diagonal restriction method be generalized to arbitrary linear projections, establishing a full "tensor restriction" theory for expression complexity?

These questions connect pure mathematics to the practical challenge of understanding what modern AI models can and cannot represent. The answer to "how complex must a formula be?" is not just a mathematical curiosity — it's a guide to the limits of automated discovery.

The tower stands. No shortcut can flatten it. And in that stubbornness lies a deep truth about the architecture of mathematical functions.
