# The Mirror That Cannot Contain Every Reflection

## Consciousness, self-models, and the mathematics of strange loops

A thermostat reacts to temperature. A chess program evaluates a board. A person can do something more peculiar: notice that they are noticing. The observer becomes part of the observed world, and the resulting picture can itself become an object of reflection. This recursive pattern has long inspired metaphors of mirrors facing mirrors, tangled hierarchies, and strange loops. Mathematics can make one precise version of that pattern—and it delivers both a fixed-point theorem and a sharp warning about what “perfect self-knowledge” could mean.

The framework begins modestly. Let $A$ be a collection of possible internal states and let $B$ be a collection of possible observations. Each state $a\in A$ carries an internal observer: a rule that assigns an observation in $B$ to every state in $A$. Thus a self-model is a function

$$
I:A\longrightarrow (A\longrightarrow B).
$$

For each state $a$, the function $I(a)$ is the observer represented by that state. The value $I(a)(x)$ is what the observer encoded at $a$ says about state $x$.

The crucial act of self-reference is diagonal evaluation. Instead of asking what the observer at $a$ says about some other state $x$, ask what it says about its own state:

$$
d(a)=I(a)(a).
$$

This diagonal observation $d(a)$ is the mathematical moment when the lens turns back upon itself.

## The seductive ideal of completeness

Suppose the self-model is *complete*: every conceivable observer $p:A\to B$ is represented by at least one state. In symbols, for every $p$ there is an $a\in A$ such that $I(a)=p$. This is an extraordinarily strong demand. It does not merely say that the system models many useful perspectives. It says that no possible $B$-valued description of its state space is missing.

Now choose any transformation of observations,

$$
g:B\longrightarrow B.
$$

It might sharpen an estimate, reverse a verdict, relabel a signal, or update a belief. From $g$ and the diagonal map, form a new observer

$$
p(x)=g(d(x)).
$$

Completeness says that some state $a$ represents exactly this observer, so

$$
I(a)(x)=g(d(x))
$$

for every $x$. Evaluate this identity at the representing state itself. The left side becomes $I(a)(a)=d(a)$, while the right side becomes $g(d(a))$. Therefore

$$
g(d(a))=d(a).
$$

This is the **Strange-Loop Fixed-Point Theorem**: if every observer is represented, then every transformation $g:B\to B$ has a fixed point. More strongly, the state $a$ both represents the transformed diagonal observer and supplies the stable observation $d(a)$. Representation, self-application, and stability close into one loop.

The proof is only a few lines, but its architecture appears across logic and computer science. Build an object that refers to the diagonal behavior of all objects; invoke expressive completeness to represent it; then apply the representation to itself. Self-reference forces a fixed point.

## A loop in an actual graph

The phrase “strange loop” need not remain metaphorical. Draw the orbit graph of $g$: its vertices are observations in $B$, and draw an arrow from $x$ to $g(x)$. A fixed point $b$ is then literally a self-loop, because the arrow from $b$ returns to $b$.

The theorem produces such a vertex at $b=d(a)$. Moreover, if $g(b)=b$, then repeated application never leaves $b$. Writing $g^n$ for $n$ successive applications, one has

$$
g^n(b)=b
$$

for every natural number $n$. The same stable observation therefore gives a closed walk of every finite length: zero steps, one step, ten steps, or a million all begin and end at the same point. The topology here is elementary—a directed graph rather than a continuous surface—but it captures the essential closure of the self-referential circuit.

## The price of perfection

At first the fixed-point theorem sounds like a recipe for emergence: make a system expressive enough to model every observer, and stable self-reference appears. Yet the negative consequences are even more revealing.

Suppose $g:B\to B$ has no fixed point. Then no complete self-model with observations in $B$ can exist. Otherwise the theorem would manufacture a fixed point that $g$ forbids. This is the **Fixed-Point-Free Obstruction**.

Boolean observations provide the clearest example. Let $B=\{\mathrm{false},\mathrm{true}\}$ and let $g$ be negation. Negation swaps the two values, so neither is fixed:

$$
\neg\mathrm{false}=\mathrm{true},\qquad
\neg\mathrm{true}=\mathrm{false}.
$$

Consequently, no matter what state space $A$ is chosen, no function $I:A\to(A\to B)$ can represent every Boolean observer. The familiar liar-like reversal—“take the opposite of what the self-description says”—blocks total representation.

The argument extends far beyond two values. If $B$ contains distinct elements $x$ and $y$, define a transformation that sends $x$ to $y$ and sends every other element to $x$. Nothing is fixed: $x$ moves to $y$, while any point other than $x$ moves to $x$. Therefore a complete self-model can exist only when all observations are equal. In mathematical language, $B$ must be a subsingleton: for every $u,v\in B$, one has $u=v$.

Completeness also forces both spaces to be inhabited. At least one state must exist, because completeness must represent even one chosen observer; evaluating that state's observer on itself then produces an observation. Combining these facts gives an exact classification.

**Classification Theorem.** A complete self-model $I:A\to(A\to B)$ exists if and only if $A$ is nonempty, $B$ is nonempty, and $B$ has at most one element.

The reverse direction is simple. Choose a state $a_0\in A$ and the unique observation $b_0\in B$. Define every internal observer to return $b_0$. Since every function into a one-point observation space is the same constant function, every possible observer is represented.

This classification changes the philosophical reading. Unrestricted extensional completeness does guarantee fixed points, but only by collapsing the observable world to a single value. A rich observation space—one able to distinguish yes from no, pain from pleasure, or one confidence level from another—cannot support this absolute form of self-representation. Any serious model of cognition must therefore weaken something: represent only a selected family of observers, tolerate approximation, impose levels, add time delays, or restrict the transformations under consideration.

## What behavior reveals

A separate but complementary idea concerns how an internal observer can be known from its effects. Given a map $f:A\to B$, any downstream test $h:B\to X$ can be attached after it, producing

$$
h\circ f:A\longrightarrow X.
$$

Call this the action of $f$ on tests. If we know $h\circ f$ for every target space $X$ and every test $h$, have we lost information about $f$? No. Choose $X=B$ and choose the identity test $h=\operatorname{id}_B$. Then

$$
\operatorname{id}_B\circ f=f.
$$

This is the elementary heart of Yoneda faithfulness: a map is completely determined by how every possible probe composes with it. If two maps $f,g:A\to B$ have $h\circ f=h\circ g$ for every $X$ and every $h:B\to X$, then taking the identity probe yields $f=g$.

Applied to a self-model, the observer $I(a):A\to B$ represented at state $a$ is recoverable from all of its downstream behaviors. If two states induce identical composed behavior under every possible test, then their represented observers are identical. Notice the careful distinction: the states themselves need not be equal. They may be different internal realizations of the same observer. What is determined is their extensional observational content.

This offers a second bridge to discussions of consciousness. The diagonal theorem studies a system turning its own represented observer upon itself. The Yoneda perspective studies an observer through the entire field of consequences it produces under probing. One emphasizes recursive closure; the other, behavioral identity.

## From theorem to research program

The mathematics does not establish that biological consciousness is literally a fixed point, nor does it identify neural states with arbitrary functions. Its value is sharper: it isolates the assumptions behind a tempting metaphor and follows them to their exact consequences.

The positive result says that sufficiently expressive self-reference forces stable points. The graph interpretation says those points are genuine closed loops under iteration. The negative result says that total expressiveness is impossible whenever observations admit a fixed-point-free transformation. The classification says that completely unrestricted self-modeling is possible only in the observationally trivial case. And the Yoneda principle says that an observer's full pattern of effects determines that observer exactly.

Together these results suggest a disciplined view of emergent selfhood. Strange loops need not arise from a magical extra ingredient; they can be forced by the architecture of representation and diagonal self-application. But meaningful systems cannot represent everything without limit. Their very capacity to distinguish alternatives creates diagonal descriptions they must omit.

This trade-off has practical echoes. A predictive agent must compress a world too large to reproduce internally; a scientific theory chooses observables rather than recording every detail; a social institution builds indicators that inevitably leave some behavior outside their frame. In each case, useful representation depends on selection. The theorem makes an extreme endpoint visible: once a model promises to include every possible perspective, diagonal construction tests that promise with a perspective tailored against the model itself. The resulting fixed point is not mystical. It is the bill that expressive closure presents when representation is asked to include its own transformed self-assessment.

That tension may be the most realistic part of the model. Minds appear neither omniscient nor featureless. They are selective, layered, temporally extended, and capable of revising their own partial portraits. The mathematics of self-reference does not replace neuroscience or phenomenology. It supplies a clean boundary marker: stable self-observation can emerge from expressive recursion, while perfect self-description and nontrivial distinction cannot coexist under the strongest notion of completeness.

The mirror can reflect itself. What it cannot do is contain every possible reflection while still preserving more than one color.