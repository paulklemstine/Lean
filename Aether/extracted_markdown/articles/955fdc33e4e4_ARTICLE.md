# The Calculator That Can't Tell Odd from Even

## Why the math behind GPS navigation is fundamentally blind to a simple question

Imagine you run a delivery company. Every morning, your routing software crunches thousands of numbers to find the shortest path between warehouses and customers. It compares distances, adds up travel times, and picks the cheapest option. This kind of optimization — find the minimum, add the costs — is the beating heart of modern logistics, internet routing, and even the autocomplete on your phone.

Now imagine asking that same software a different kind of question: *Is the number of packages in this truck odd or even?*

Your routing software would stare at you blankly. Not because it's badly programmed, but because the mathematical language it speaks — the language of "take the minimum" and "add things up" — is structurally incapable of answering that question. It's like asking someone who only knows how to whisper to shout. The limitation isn't about volume; it's about the physics of their vocal cords.

A new mathematical result has made this intuition rigorous, proving that an entire universe of computation — one that powers billions of dollars of real-world optimization — has a fundamental blind spot. And that blind spot turns out to illuminate one of the deepest questions in all of computer science.

## The Tropical World

In the 1960s, mathematicians began studying a curious variation of ordinary arithmetic. Instead of the usual addition and multiplication, they worked with two operations:

- **"Addition"** became *taking the minimum* of two numbers
- **"Multiplication"** became *ordinary addition*

So in this strange arithmetic, "3 + 5" equals 3 (the smaller one), and "3 × 5" equals 8 (their ordinary sum).

This system was eventually named **tropical mathematics**, reportedly after the Brazilian mathematician Imre Simon, though the name stuck more for its exotic flavor than its geography. Despite its apparent whimsy, tropical math turned out to be extraordinarily useful. It naturally describes optimization problems: when you compute shortest paths in a network, you're repeatedly taking minimums of sums — which is exactly tropical arithmetic.

Today, tropical mathematics underpins algorithms in logistics, telecommunications, scheduling, computational biology, and machine learning. Whenever a computer needs to find the best option among many by comparing accumulated costs, it's secretly doing tropical arithmetic.

## The Question of Limits

But here's the deeper question: *What can tropical arithmetic actually compute?*

Think of it this way. Ordinary arithmetic with addition and multiplication can express enormously complex things. Given enough additions and multiplications, you can compute anything a digital computer can compute — you can encrypt messages, simulate galaxies, render photorealistic images. The operations are universal.

Tropical arithmetic, with its minimums and additions, feels similar. It's powerful enough to solve shortest-path problems, to optimize supply chains, to train certain kinds of neural networks. But is it universal? Can it compute *anything*, given enough steps?

The answer, it turns out, is a resounding no. And the reason is beautiful.

## The Monotonicity Trap

Here's the key insight. Consider what happens when you increase one of the inputs to a tropical computation.

If you make a variable larger — say, increase a travel time in your network — then every minimum involving that variable either stays the same or increases. Every sum involving that variable increases. And this property cascades: no matter how you combine minimums and additions, making an input bigger can never make the output smaller.

Mathematicians call this property **monotonicity**. It's like water flowing downhill: in the tropical world, bigger inputs always push toward bigger outputs. There's no way to create a computation where increasing an input causes the output to decrease.

This might seem like a minor technical observation. But it has devastating consequences.

## Parity: The Simplest Impossible Question

Consider the parity function — the question "is this number odd or even?" Applied to a list of yes/no answers (say, which switches are flipped on), parity asks: *Is the total number of "yes" answers odd?*

Parity is emphatically not monotone. If you have three switches on (odd — yes!), and you flip one more to on, now you have four switches on (even — no!). Adding more "yes" answers can flip the answer from "odd" to "even" and back again, forever oscillating.

The new theorem proves that this oscillation is the death knell for tropical computation. Because tropical expressions are inherently monotone, and parity is inherently non-monotone, no tropical expression — no matter how large or cleverly constructed — can exactly compute parity.

This isn't a limitation of current algorithms or available computing power. It's a mathematical impossibility, as absolute as the fact that no real number squares to give −1.

## Beyond Parity

The barrier extends far beyond parity. The theorem actually proves something more general: *any* Boolean function that violates monotonicity under the tropical encoding is forever beyond the reach of tropical computation.

This captures a zoo of important computational predicates:

- **XOR** (exclusive or): fundamental to cryptography and error correction
- **Exact-one**: does exactly one condition hold? (Used in constraint satisfaction)
- **Modular counting**: is a quantity divisible by 3? By 7? By any fixed number?
- **Satisfiability detection**: the canonical hard problem in computer science

Each of these functions has the property that increasing inputs can decrease outputs — they oscillate, they alternate, they refuse to flow in one direction. And this refusal places them permanently outside the tropical universe.

## Why Computer Scientists Care

This result belongs to a grand tradition in theoretical computer science called **lower bound theory** — the study of what computers *cannot* do, or cannot do efficiently.

The most famous open question in this tradition is the P versus NP problem, which asks whether every problem whose solution can be quickly verified can also be quickly solved. It's one of the seven Millennium Prize Problems, carrying a million-dollar bounty, and has resisted all attacks for over fifty years.

One reason P versus NP is so hard is that proving computational impossibility is fiendishly difficult. It's not enough to say "nobody has found a fast algorithm." You must prove that no fast algorithm *can* exist — out of the infinite space of all possible algorithms.

The tropical barrier theorem is a clean victory in this war. It doesn't solve P versus NP, but it proves an impossibility result in a model that matters for real computation. And it does so through a structural argument — monotonicity — that illuminates *why* certain computations are impossible rather than merely asserting that they are.

## The Monotone Circuit Connection

This work has a distinguished ancestor. In 1985, the mathematician Alexander Razborov proved a landmark result: monotone Boolean circuits — circuits built only from AND and OR gates, without NOT gates — require exponentially many gates to compute certain functions. This was one of the first unconditional lower bounds in circuit complexity and remains one of the most celebrated results in the field.

The tropical barrier theorem is a spiritual descendant of Razborov's work, translated into the language of optimization algebra. Where Razborov showed that AND/OR circuits without negation are limited, the new result shows that min/plus circuits without subtraction are limited — and for the same fundamental reason: monotonicity cannot capture alternation.

But the tropical setting offers new connections. Tropical mathematics sits at the crossroads of algebra, geometry, and optimization in ways that Boolean circuits do not. This creates fresh opportunities to extend the barrier.

## Tropical Geometry: Where Algebra Meets Shape

One of the most exciting developments in modern mathematics is **tropical geometry**, which studies geometric objects defined by tropical polynomials. Where classical algebraic geometry studies curves and surfaces defined by polynomial equations, tropical geometry studies their "shadows" — piecewise-linear structures that emerge when you replace addition and multiplication with minimum and plus.

These tropical shadows turn out to encode deep information about their classical counterparts. Tropical curves look like networks of line segments. Tropical surfaces look like origami. And the combinatorics of these shapes — how many folds they have, how they intersect — directly constrain what tropical polynomials can compute.

The barrier theorem suggests that complexity questions about tropical circuits can be rephrased as geometric questions about tropical varieties. How many linear regions can a tropical circuit of a given size create? How do those regions relate to the oscillations of non-monotone functions? These questions connect computational complexity to the rapidly developing toolkit of tropical geometry.

## What Comes Next

The current theorem proves a qualitative barrier: tropical circuits *cannot* represent non-monotone functions at all. The next frontier is quantitative: for functions that are "close" to monotone, or that can be approximated by monotone functions, how large must the tropical circuit be?

Several concrete research directions emerge:

**Piecewise-linear complexity.** Every tropical circuit computes a piecewise-linear function, and the number of linear pieces is bounded by the circuit size. Functions with rapid oscillations — like parity — require many pieces, suggesting size lower bounds.

**Approximation barriers.** Even if exact representation is impossible, can tropical circuits *approximate* non-monotone functions? If so, how well? These questions connect to optimization theory and the design of approximation algorithms.

**Idempotent complexity classes.** The tropical semiring is an example of an idempotent semiring (since min(x,x) = x). One can define complexity classes based on computation in such semirings, creating a parallel universe of complexity theory with its own hierarchies and separations.

**Connections to deep learning.** Modern neural networks with ReLU activation functions compute piecewise-linear functions — exactly the functions that tropical geometry studies. The barrier theorem hints at fundamental limits on what can be learned by optimization-only architectures.

## The Bigger Picture

Mathematics advances not only by proving what is true, but by proving what is impossible. The discovery that the square root of 2 is irrational, that angles cannot be trisected with compass and straightedge, that polynomial equations of degree 5 have no general formula — these impossibility results reshaped mathematics by revealing the boundaries of mathematical methods.

The tropical barrier theorem belongs to this tradition. It reveals a boundary of the optimization paradigm — a line that separates what minimums and additions can compute from what they cannot. On one side lies the vast territory of shortest paths, dynamic programming, and tropical geometry. On the other side lies the wild landscape of parity, satisfiability, and alternation.

Between them runs a wall built from a single, elegant property: monotonicity. And now that wall has been certified with mathematical proof — not just conjectured or believed, but *known*, with the absolute certainty that only mathematics can provide.

The delivery truck will always find the shortest route. But it will never — *can* never — tell you if the number of packages is odd.
