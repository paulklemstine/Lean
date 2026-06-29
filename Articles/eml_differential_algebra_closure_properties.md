# The Algebra That Knows Its Own Derivative

## A small world of functions that is closed under calculus

Imagine a workshop with only six tools. With them you can build an
astonishing range of machines — but never anything outside what those
six tools allow. The marvel is not the range; it is the *guarantee*.
Whatever you assemble, you know in advance exactly how it will behave,
because the tools constrain it.

This article is about such a workshop, but for functions instead of
machines. The six tools are:

1. dialing in a **constant** number,
2. the **identity** function $x \mapsto x$,
3. **adding** two functions,
4. **multiplying** two functions,
5. **negating** a function, and
6. wrapping a function inside the **exponential** $e^{(\cdot)}$.

Starting from constants and the variable $x$, and applying these
operations any finite number of times, you generate a family of
functions. We call them the **log-free EML functions** — "EML" standing
for *exponential–multiplication–linear*. They are exactly the
**exponential polynomials**: polynomials in $x$ and in exponentials of
polynomials.

A few examples to fix the picture:

$$
3x^2 - 5, \qquad e^x, \qquad x\,e^{x} + 7, \qquad e^{x^2}, \qquad
e^{\,e^{x} + x} - x\,e^{-x}.
$$

Each of these is built by a finite recipe from the six tools. None of
them involves division, logarithms, sines, or square roots. The class
looks modest. The surprise is how much structure it secretly carries.

## The central claim: this world is closed under calculus

Here is the headline. **The log-free EML functions form a differential
algebra.** Unpacking that phrase:

- **Algebra:** the family is closed under addition, multiplication, and
  scaling by real numbers. Add two EML functions and you get an EML
  function; multiply them and you stay inside; multiply by $\sqrt{2}$ and
  you never leave.
- **Differential:** the family is closed under *differentiation*. Take
  the derivative of any EML function, and the result is again an EML
  function — no exceptions, no escape.

The second point is the beautiful one. Calculus, which so often drags you
out of a tidy family of functions, here keeps you safely inside. Where
$1/x$ comes from differentiating $\ln x$ and drags you into rational
functions, every EML function differentiates to another EML function.
The workshop is closed under the operation of "finding the slope."

And there is a third, subtler kind of closure: **composition**. If you
take one EML function and feed it into another — substitute $g(x)$
wherever the variable appears in $f$ — the composite $f(g(x))$ is again
EML. The family is closed under chaining functions together.

## Why this is not obvious

It would be easy to assume all of this is automatic. It is not. Consider
what happens with neighboring families.

- The **polynomials** are closed under $+$, $\times$, and $d/dx$, but the
  moment you allow $e^x$ they are not enough.
- The **rational functions** $p(x)/q(x)$ are closed under differentiation,
  but they fail the moment you exponentiate: $e^{x}$ is not a ratio of
  polynomials.
- The **elementary functions** of a first calculus course (allowing
  division, logarithms, and roots) *are* closed under differentiation —
  but they are a far larger, far wilder class, and proving anything
  rigorous about all of them is genuinely hard.

The log-free EML functions sit in a sweet spot: rich enough to contain
$e^{x^2}$ and $x\,e^x + 1$, small enough that every closure property can
be proved cleanly and completely. They are the smallest natural family
containing $x$, the constants, and the exponential, and closed under the
arithmetic of functions.

## The trick: separate the *recipe* from the *function*

The cleanest way to understand why EML functions behave so well is to
stop thinking about the functions themselves and think instead about
their **recipes**.

A recipe is a finite formula tree. Its leaves are constants or the symbol
$X$; its internal nodes are the operations $+$, $\times$, negation, and
$\exp$. For example, the recipe for $x\,e^{x}+7$ is

$$
\text{add}\big(\,\text{mul}(X,\ \exp(X)),\ \text{const}(7)\,\big).
$$

This is pure syntax — a tree of symbols, with no calculus in it yet. We
then give each recipe a *meaning*: a rule that turns the tree into an
actual function $\mathbb{R} \to \mathbb{R}$. The constant node $c$ means
"the function always equal to $c$"; the $X$ node means "the function
$x \mapsto x$"; the $\text{add}$ node means "add the meanings of the two
sub-recipes"; and so on, with the $\exp$ node meaning "exponentiate the
meaning of the sub-recipe." A function is **EML** precisely when *some*
recipe evaluates to it.

Now comes the magic. Differentiation, which is an analytic operation on
functions, can be mirrored by a purely *mechanical rewriting of recipes*.
Define a syntactic operator $D$ that walks a recipe tree and rewrites it
according to the rules every calculus student knows:

$$
D(\text{const } c) = 0, \quad D(X) = 1, \quad
D(a+b) = D a + D b,
$$
$$
D(a\cdot b) = D a \cdot b + a \cdot D b
\ \text{(product rule)}, \quad
D(\exp a) = D a \cdot \exp a \ \text{(chain rule)}.
$$

$D$ takes a recipe and produces another recipe. It never leaves the
syntax. And the key theorem says: **the meaning of $D(t)$ is exactly the
derivative of the meaning of $t$.** Symbolically, for every recipe $t$
and every point $x$,

$$
\frac{d}{dx}\,\big(\text{meaning of } t\big)(x)
= \big(\text{meaning of } D t\big)(x).
$$

Because $D$ produces a recipe, and recipes always denote EML functions,
the derivative of an EML function is automatically EML. Closure under
differentiation is no longer a delicate analytic fact to be checked case
by case; it is a one-line consequence of the fact that the symbolic
operator $D$ stays inside the syntax.

The same trick handles composition. There is a syntactic substitution
operation: take the recipe for $f$, and wherever the symbol $X$ appears,
plug in the entire recipe for $g$. Call the result the composite recipe.
A short induction shows its meaning is exactly $x \mapsto f(g(x))$. Again,
because the output is a recipe, the composite is automatically EML.

This separation — syntax on one side, meaning on the other, linked by a
correctness theorem — is the engine that makes every closure property
fall out cleanly.

## Everything is smooth

There is a bonus prize. Every EML function is **infinitely
differentiable** — smooth, with no corners, kinks, or jumps anywhere on
the real line. You can differentiate it once, twice, a thousand times,
and it remains a well-behaved EML function each time.

The proof, once more, follows the recipe structure. Constants and the
identity are smooth. Sums, products, and negations of smooth functions
are smooth. And the exponential of a smooth function is smooth. Since
every EML function is assembled from these by a finite recipe, every EML
function is smooth by induction on the recipe. The result: the EML world
is not just closed under calculus, it is a world of perfectly tame,
perpetually differentiable functions.

## What the family is *not*: the boundaries of the workshop

A good way to appreciate a structure is to map its edges — the places
where, if you push, you fall out.

**It is a ring, but not a field.** You can add, subtract, and multiply
EML functions freely. But you cannot always *divide*. The function
$x \mapsto 1/x$ is not EML: there is no finite recipe over our six tools
that produces it. Division genuinely escapes the workshop. So the EML
functions form a *commutative differential ring*, not a differential
field — they have addition and multiplication with all the usual laws,
but reciprocals can lead outside.

**It is closed under differentiation, but only partly under
integration.** This is the most tantalizing boundary. Differentiation
never leaves the family. Integration sometimes does. The cleanest witness
is the function $e^{x^2}$. It is plainly EML — it is the exponential of
the EML function $x^2$. Yet its antiderivative is the famous error
function,

$$
\int_0^x e^{t^2}\,dt,
$$

which is *not* an EML function. There is no finite recipe over our six
tools whose derivative equals $e^{x^2}$. Closure under integration fails,
and it fails for a deep reason: integration is the *inverse* of the
syntactic derivative $D$, and $D$ is not "onto." Some EML functions are
nobody's derivative within the family. This is a baby version of a
celebrated nineteenth-century discovery by Liouville, that "elementary"
antiderivatives do not always exist — and here it lives entirely inside a
clean, finite world of recipes.

**It is closed under composition, but not under functional inverse.**
You can chain EML functions, but you cannot always *undo* one and stay
inside. The cube map $x \mapsto x^3$ is EML and is a perfect one-to-one
correspondence of the real line with itself. Its inverse is the cube root
$x \mapsto x^{1/3}$ — which is not EML (indeed it is not even
differentiable at the origin, while every EML function is smooth
everywhere). So inverting an EML bijection can throw you out of the
family. The obstruction is exactly that the derivative $3x^2$ vanishes at
$x=0$: a stationary point that the smooth EML world cannot reconcile with
a smooth inverse.

These three boundaries — no division, partial integration, no inverses —
are not failures. They are the precise shape of the family, the contour
lines that tell you exactly where its rich internal structure ends.

## Why anyone should care

This little algebra is a microcosm of a grand theme in mathematics:
**which operations keep you inside a family of objects, and which ones
break out.** That theme runs through Galois theory (which polynomial
roots can be reached by radicals?), through differential Galois theory
(which integrals can be expressed in closed form?), and through the
modern theory of computation (which functions can a given machine
compute?).

Exponential polynomials, the EML functions, are not an abstract toy. They
are the natural language of:

- **growth and decay**, where everything is built from $e^{kx}$ — radioactive
  decay, compound interest, population models, and the impulse responses
  of linear systems;
- **probability**, where the Gaussian bell curve $e^{-x^2/2}$ and its
  relatives are exponential polynomials, and where the failure of $e^{x^2}$
  to have an elementary integral is exactly why the normal distribution's
  cumulative function has no closed form;
- **signal processing and differential equations**, where solutions to
  constant-coefficient linear systems are precisely sums of terms
  $x^k e^{\lambda x}$ — all EML.

The fact that this family is *closed under differentiation* is what makes
symbolic differentiation engines fast and exact on it: the answer is
always representable, so the machine never has to approximate or give up.
The fact that it is *not closed under integration* is what makes symbolic
integration genuinely hard, and why software must sometimes answer "no
elementary form exists."

## The takeaway

We started with six humble tools and ended with a self-contained universe
of functions: closed under addition, multiplication, scaling,
composition, and — most elegantly — differentiation, with every member
guaranteed smooth. We then walked its perimeter and found three sharp
cliffs: no division, no general integration, no functional inverses.

The deep lesson is methodological. By turning functions into *recipes* —
finite trees of symbols — and proving that calculus on functions matches
a mechanical rewriting of recipes, we converted analytic theorems into
combinatorial certainties. Smoothness, the correctness of the derivative,
the correctness of composition, and the closure of the whole family all
followed from a single idea: keep the operation inside the syntax, and
the function will take care of itself.

It is a small algebra. But it knows its own derivative. And in
mathematics, an object that contains the rules for its own change is
about as close to alive as a definition ever gets.
