# The Function That Swallowed Mathematics

## How a Single Operation Captures All of Calculus — and Where It Breaks

Imagine you're an alien mathematician, arriving on Earth with no knowledge of our mathematical traditions. You find two strange operations — the exponential function, which turns addition into multiplication, and the logarithm, which reverses it. These two functions have been the workhorses of science since Napier invented logarithms in 1614, four centuries of separate treatment.

Now imagine someone tells you: *there's a single operation that does both jobs.*

That operation is called **EML**, defined by a deceptively simple formula:

> eml(x, y) = eˣ − ln(y)

It looks almost trivial. Just subtraction between an exponential and a logarithm. But this formula contains a mathematical universe.

## One Operation to Rule Them All

Set the second argument to 1, and since ln(1) = 0, you get eml(x, 1) = eˣ — pure exponential growth. Set the first argument to 0, and since e⁰ = 1, you get eml(0, y) = 1 − ln(y), which means ln(y) = 1 − eml(0, y) — the logarithm springs out from the same formula.

This is like discovering that addition and subtraction are really the same operation viewed from different angles. The EML function unifies the two most important transcendental functions in mathematics into a single primitive.

But the real surprise isn't the unification. It's what happens when you start doing calculus with it.

## The Self-Referential Miracle

Here's the question that launched a research program: if you take the derivative of an EML expression, do you get another EML expression?

Think about what this question means. When you differentiate eˣ, you get eˣ back — beautiful self-reference. When you differentiate ln(x), you get 1/x — not a logarithm at all, but a simple algebraic function. These are different behaviors from two different functions.

But with EML, something remarkable happens. Consider a function built by plugging two varying expressions f(t) and g(t) into the EML slots:

> F(t) = eml(f(t), g(t)) = exp(f(t)) − ln(g(t))

What's its derivative? The chain rule gives:

> F'(t) = f'(t) · exp(f(t)) − g'(t) / g(t)

Look at that formula. The exp(f(t)) term is just eml(f(t), 1). The g'(t)/g(t) term is a ratio of functions. Everything in the derivative is built from multiplication, division, and EML itself. **The derivative of an EML expression is always another EML expression.**

This property has a name: *differential closure*. The class of EML functions forms what mathematicians call a **differential algebra** — a self-contained world where differentiation never escapes.

## Building the Tower

The implications cascade. If first derivatives stay in the EML world, what about second derivatives? The second derivative of the "diagonal" function eml(z, z) = eᶻ − ln(z) is:

> First derivative: eᶻ − 1/z
> Second derivative: eᶻ + 1/z²

Both are EML-expressible. And this pattern continues to all orders. You can differentiate as many times as you want, and you never leave the EML universe.

This creates what we call the **depth hierarchy**. Assign each function a "transcendence depth" — how many layers of exponentials and logarithms are nested inside each other. The function x² has depth 0 (it's algebraic). The function eˣ has depth 1. The function exp(exp(x)) has depth 2.

The depth preservation theorem says: **differentiation never increases the transcendence depth.** When you differentiate exp(f(x)), you get f'(x) · exp(f(x)), which has the same depth as exp(f(x)). When you differentiate ln(f(x)), you get f'(x)/f(x), which actually *decreases* the depth by one.

This is surprising. You might expect that applying calculus operations to complex functions makes them more complex. Instead, differentiation respects the complexity hierarchy perfectly.

## The Leibniz Rule and the Algebra of Derivations

There's a deeper algebraic structure at work. The German mathematician Gottfried Leibniz discovered in the 1680s that the derivative of a product follows a beautiful rule:

> (f · g)' = f' · g + f · g'

This "Leibniz rule" means that differentiation is what algebraists call a *derivation* — a linear operation satisfying this product rule. The EML differential closure theorem shows that the Leibniz rule, when applied to EML functions, keeps everything inside the EML class.

Why? Because the right-hand side f'g + fg' involves only multiplication and addition of EML functions, and the class is closed under both. This isn't a coincidence. It's the structural reason why differential closure works: the derivative is built from exactly the operations that the class already contains.

## The Inverse Function Connection

If f is an EML function with nonzero derivative, what about its inverse function f⁻¹? The inverse function theorem tells us that (f⁻¹)'(y) = 1/f'(f⁻¹(y)).

This formula involves only division and composition — both operations that preserve the EML class. So if f⁻¹ is itself an EML function (and many important ones are: log is the inverse of exp, for instance), then its derivative is automatically EML-expressible.

This connects to a profound question in mathematics: which functions have "elementary" inverses? The EML framework gives us a precise language to ask and answer this question.

## Where the Magic Breaks: Integration

Differentiation is well-behaved. Integration is wild.

Consider the function exp(exp(x)). It's clearly EML-expressible — it's just exp composed with exp, depth 2 in our hierarchy. Its derivative, exp(x)·exp(exp(x)), is also EML-expressible.

But what about its *antiderivative* — the function F such that F'(x) = exp(exp(x))? This is one of the great negative results of 19th-century mathematics: **no such elementary function exists.** The integral of exp(exp(x)) requires new, non-elementary functions.

This asymmetry — differentiation always closes, integration sometimes escapes — is one of the deepest phenomena in analysis. The French mathematician Joseph Liouville proved in the 1830s that certain elementary functions have no elementary antiderivatives. Our work confirms that this obstruction persists in the EML framework: the EML differential algebra is closed going "down" (differentiation) but not "up" (integration).

## The Iterated Exponential Tower

One of the most elegant consequences of EML closure is about iterated exponentials. Define the tower:

> exp¹(x) = eˣ
> exp²(x) = exp(eˣ) = e^(eˣ)
> exp³(x) = exp(exp(eˣ)) = e^(e^(eˣ))

We prove that expⁿ(x) is EML-expressible for every n. Moreover, each derivative is EML-expressible at the same depth level. The EML framework handles these rapidly-growing functions — each of which grows faster than any polynomial, any exponential, any tower of exponentials below it — with the same uniform machinery.

## Why It Matters

The EML differential algebra isn't just an intellectual curiosity. It provides a *canonical normal form* for elementary calculus. Any computation involving exponentials and logarithms can be re-expressed in terms of a single primitive. This has practical implications:

**Computer algebra**: Instead of implementing separate rules for exp and log differentiation, a system needs only the EML chain rule. One rule replaces many.

**Neural networks**: Modern architectures use exponentials (softmax, sigmoid) and logarithms (log-likelihood) extensively. The EML framework suggests these can be unified into a single computational primitive, potentially simplifying both hardware and software.

**Mathematical physics**: Many physical quantities involve combinations of exponentials and logarithms — entropy, free energy, partition functions. The EML viewpoint reveals hidden structure in these formulas.

## The Road Ahead

Several tantalizing questions remain open. Can the EML depth hierarchy be extended to capture hyperexponential functions beyond any finite tower? Is there a "tropical" version of the EML differential algebra, where addition becomes minimum and multiplication becomes addition?

Perhaps most ambitiously: the EML operator eml(x, y) = eˣ − ln(y) lives at the boundary between the additive world (eˣ turns addition into multiplication) and the multiplicative world (ln turns multiplication into addition). Could there be a deeper algebraic structure — a "bridge" — that explains why this particular combination has such remarkable closure properties?

The answers may reshape how we think about the relationship between algebra and analysis, between the discrete and the continuous, between the operations we compute with and the mathematics those operations describe.

---

*The EML differential algebra was developed through a combination of mathematical reasoning and machine-verified proofs. All theorems described in this article have been formally verified.*
