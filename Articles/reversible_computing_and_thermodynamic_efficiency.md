# The Price of Forgetting: Why Erasing a Bit Costs Heat, and Why Reversible Computers Pay Nothing

## A puzzle hiding inside every computer

Run your hand over the back of a laptop after a long video call and you will feel it: warmth.
We are used to treating that heat as an engineering nuisance — a sign that the fan should
spin faster, that the chip is "wasting" electricity. But buried inside that warmth is one
of the most beautiful ideas in physics, a bridge between three worlds that look like they
should have nothing to do with one another: **logic**, **information**, and **thermodynamics**.

The idea is this. Some computational steps are, in a deep and unavoidable sense, *destructive*.
When your processor overwrites a memory cell, it forgets what used to be there. That act of
forgetting is not free. It has a minimum thermodynamic price, paid in heat dumped into the
surrounding world, and that price is fixed by the laws of nature — not by the cleverness of
the engineer. The bound was first written down by Rolf Landauer in 1961, and it is now known
as **Landauer's principle**.

The flip side is just as striking. If a computation never forgets anything — if every step
can in principle be run backwards — then there is *no* minimum price at all. Such
**reversible** computations can, in the ideal limit, be performed for free. Charles Bennett
showed in 1973 that, remarkably, *any* computation can be rewritten in this reversible form.

This article tells the story of why forgetting costs heat, why remembering is free, and how a
single clean mathematical inequality — one short statement about probability distributions —
captures the whole picture at once.

## Information as a physical thing

Start with the simplest possible object: a bit. A bit can be `0` or `1`. If you have no idea
which, the bit carries one full unit of uncertainty. Once you learn its value, the uncertainty
collapses to nothing.

Physicists and information theorists measure this uncertainty with a single number, the
**Shannon entropy**. If a system can be in several states, and state $x$ occurs with
probability $p(x)$, then the entropy of the distribution $p$ is

$$ H(p) = -\sum_x p(x)\,\log p(x). $$

Don't let the formula intimidate you. It is just a careful way of measuring "how spread out"
the probabilities are. A coin that always lands heads has zero entropy: there is nothing to
be uncertain about. A fair coin has the maximum possible entropy for two outcomes. The more
genuinely unpredictable a system is, the higher its entropy.

Here is the crucial bridge, the one Landauer identified. Entropy in this *informational* sense
is not a metaphor for entropy in the *thermodynamic* sense. Up to a universal conversion factor
— Boltzmann's constant $k$ times the temperature $T$ — they are the *same quantity*. When the
informational entropy of a computer's memory drops by an amount $\Delta H$, the second law of
thermodynamics demands that at least $k\,T\,\Delta H$ worth of entropy be exported to the
environment, and that export takes the form of heat:

$$ Q \ge k\,T\,\Delta H. $$

So the question "how much heat must a computation release?" becomes the question "how much
informational entropy does it destroy?" And *that* is a question we can answer with pure
mathematics.

## The heart of the matter: a deterministic map can never create uncertainty

Imagine a deterministic computational step. It takes an input $x$ and produces an output $f(x)$.
"Deterministic" means: the same input always yields the same output. There is no randomness in
the rule $f$ itself.

Now feed this step a random input drawn from some distribution $p$. The outputs are then random
too, distributed according to what mathematicians call the **pushforward** of $p$ along $f$. Its
recipe is intuitive: to find the probability that the output equals some value $y$, add up the
probabilities of all inputs that get mapped to $y$:

$$ (f_* p)(y) \;=\; \sum_{x \,:\, f(x) = y} p(x). $$

The set of inputs $\{x : f(x) = y\}$ that all collapse onto the same output $y$ is called the
**fiber** over $y$. A deterministic step is destructive precisely when it has fat fibers — when
many distinct inputs are crushed together into a single output, so that knowing the output no
longer tells you the input.

The central result, the engine that drives everything else, is a statement about what happens to
entropy under such a map:

> **Data-Processing Inequality (deterministic form).** For *any* function $f$ and *any*
> distribution $p$, the entropy of the output never exceeds the entropy of the input:
> $$ H(f_* p) \;\le\; H(p). $$

In words: **no deterministic computation can manufacture uncertainty out of nothing.** Processing
data can only preserve information or throw it away; it can never conjure new information. This is
the mathematical skeleton of the slogan "garbage in, garbage out" — and, as we will see, of
Landauer's principle itself.

What makes this version special is the simplicity of its proof. The usual textbook argument
routes through deep facts about the concavity of the entropy function and clever regrouping of
terms. But there is a far more elementary path, and it rests on a single childlike observation.

Look again at the pushforward. The probability $(f_* p)(f(x))$ assigned to the output of a
particular input $x$ is a *sum* of nonnegative terms, and one of those terms is $p(x)$ itself —
because $x$ certainly lands in its own fiber. A sum of nonnegative numbers is at least as big as
any one of its members. Therefore, for every input $x$,

$$ (f_* p)(f(x)) \;\ge\; p(x). $$

That is the whole secret. Each output, viewed from the perspective of an input that produced it,
is *at least as probable* as that input was — because it may have absorbed the probability of
several siblings sharing its fiber. Since the logarithm is an increasing function, this pointwise
domination immediately gives

$$ \log\big((f_* p)(f(x))\big) \;\ge\; \log\big(p(x)\big). $$

Multiply by $p(x)\ge 0$, sum over all inputs, and the entropy gap reveals itself as a sum of
nonnegative pieces:

$$ H(p) - H(f_* p) \;=\; \sum_x p(x)\,\Big[\log\big((f_* p)(f(x))\big) - \log\big(p(x)\big)\Big]
\;\ge\; 0. $$

Every term is nonnegative, so the total is nonnegative, so $H(f_* p) \le H(p)$. No concavity, no
Jensen's inequality, no heavy machinery — just "a sum is bigger than one of its parts" and "the
logarithm goes up." The result is exact, completely general, and almost embarrassingly clean.

## When is the price exactly zero?

The inequality tells us forgetting *can* cost something. When does it cost *nothing*?

The gap $H(p) - H(f_* p)$ is a sum of nonnegative terms, so it vanishes exactly when every term
vanishes — that is, when $(f_* p)(f(x)) = p(x)$ for every input that actually occurs. And that
happens precisely when the fibers are *thin*: when no two distinct inputs are crushed into the
same output. A function with this property is called **injective** (one-to-one). It is exactly a
function that can be run backwards: from the output you can always recover the input.

This gives the converse half of the story:

> **Reversible computations preserve entropy.** If $f$ is injective, then
> $$ H(f_* p) \;=\; H(p) \quad\text{for every distribution } p. $$

An injective map merely relabels the possibilities; it never merges them. The uncertainty you put
in is exactly the uncertainty you get out. Nothing is forgotten, so — by Landauer's bridge —
nothing need be paid.

## Reading off Landauer's principle

Now translate back into the language of heat. The thermodynamic work that a computation $f$ must
dissipate, when run on inputs distributed as $p$, is

$$ W \;=\; k\,T\,\big(H(p) - H(f_* p)\big). $$

Our inequality says the bracket is always nonnegative. Hence:

> **Landauer's lower bound.** Every deterministic computation dissipates nonnegative heat,
> $$ k\,T\,\big(H(p) - H(f_* p)\big) \;\ge\; 0, $$
> and this dissipation is **exactly zero** whenever $f$ is reversible (injective).

There it is, the entire Landauer principle, falling out of one elementary inequality. Irreversible
steps — the ones with fat fibers, the ones that forget — carry a strictly positive heat tax.
Reversible steps are tax-free.

## The sharpest case: erasing a register

To see the bound bite hardest, take the most destructive computation imaginable: erasure. A memory
register holding $n$ bits has $2^n$ possible contents. Before erasure, with no knowledge of what is
stored, each of the $2^n$ patterns is equally likely — the **uniform distribution**, which carries
the maximum entropy

$$ H_{\text{uniform on } 2^n \text{ states}} \;=\; n\,\log 2. $$

Erasure collapses every one of those patterns to a single reset state, say all zeros. The output
distribution is now concentrated on one point, with entropy $0$. The entropy drop is therefore
*exactly*

$$ \Delta H \;=\; n\,\log 2 - 0 \;=\; n\,\log 2, $$

and the heat that must be released is *exactly*

$$ Q \;=\; k\,T\,n\,\log 2. $$

This is not a loose estimate. It is an equality, the extremal endpoint of the general inequality,
the case where the fibers are as fat as they can possibly be (all $2^n$ inputs sharing one fiber).

For a single bit ($n = 1$) at room temperature ($T \approx 300\,\mathrm{K}$), the number works out
to about $k\,T\,\log 2 \approx 2.9 \times 10^{-21}$ joules — roughly three *zeptojoules*, or about
$0.018$ electron-volts. It is a fantastically tiny amount of energy, millions of times smaller than
what today's transistors actually burn per operation. But it is not zero, and it is not negotiable.
As chips approach the atomic scale and energy budgets tighten, this once-academic floor is
becoming an engineering ceiling. Landauer's limit has been confirmed in delicate laboratory
experiments with single colloidal particles and single electron spins, each one a physical bit
being deliberately erased while the heat is measured. Nature pays the bill on time, every time.

## Building computers that never forget

If forgetting is the only thing that costs heat, the obvious dream is to build a computer that
never forgets. Can it be done? Bennett's astonishing answer is yes: any computation can be made
reversible by carrying along enough "history" so that no information is ever truly destroyed. The
building blocks are special **reversible logic gates** that are bijections — one-to-one and onto —
so that the input can always be reconstructed from the output.

Three gates form a universal reversible toolkit, and each is a perfect, lossless permutation of its
inputs:

- **The CNOT (controlled-NOT) gate** takes two bits $(a, b)$ and outputs $(a,\, a \oplus b)$, where
  $\oplus$ is exclusive-or. The first bit passes through untouched; the second is flipped exactly
  when the first is `1`. Apply CNOT twice and you are back where you started — it is its own inverse.
  With the right input it computes XOR, and it can also copy a bit. Yet it is perfectly reversible.

- **The Toffoli (controlled-controlled-NOT) gate** takes three bits $(a, b, c)$ and flips the last
  one only when the first two are both `1`, giving $(a,\, b,\, c \oplus (a \wedge b))$. By feeding it
  the right constants it can compute AND, OR, and NOT — making it, by itself, enough to build *any*
  logic circuit. And like CNOT it is its own inverse: a true reversible workhorse.

- **The Fredkin (controlled-SWAP) gate** takes three bits $(a, b, c)$ and swaps the last two
  whenever the first is `1`. It is universal, reversible, and has the elegant extra property of
  *conserving* the number of `1`s — a feature that maps neatly onto physical realizations where the
  ones are genuine conserved tokens, like billiard balls or photons.

Because each of these gates is a bijection, the equality half of our story applies to all of them:
they preserve entropy on *every* input distribution, and so — by Landauer's bound — they dissipate
*no* heat. The same gates, fed the right constants, reproduce all the ordinary irreversible logic
operations (AND, OR, NOT, XOR, COPY). The lesson is profound: the heat we associate with computation
is not intrinsic to *what* we compute, but to *how* we compute it. Forgetting is optional.

## A surprising bridge to tropical algebra

There is one more thread worth pulling, because it shows how deep these reversibility ideas run.
Replace ordinary arithmetic with **tropical** (or "min-plus") arithmetic, in which "addition" means
*taking the minimum* and "multiplication" means *ordinary addition*. This strange-looking algebra is
the natural language of optimization and shortest-path problems: the cost of the best route is the
*minimum* over routes, and the cost of a route is the *sum* of its legs.

Every reversible relabeling of states (every bijection) induces a perfectly faithful transformation
of these cost landscapes — one that respects both the "take a minimum" and the "add costs"
operations. In the precise algebraic sense, reversible computation acts as an *automorphism* of the
tropical cost structure. The very same maps that are thermodynamically free (because they preserve
entropy) are also algebraically structure-preserving (because they preserve the min-plus operations).
Reversibility, it turns out, is a single phenomenon wearing three costumes: a *logical* one
(invertible gates), an *information-theoretic* one (entropy preservation), and an *algebraic* one
(tropical isomorphism).

## The moral

We began with the warmth of a laptop and ended with a unifying principle that ties together logic,
information, and heat. The chain of reasoning is short enough to hold in your head:

1. Deterministic computation can only preserve or destroy information, never create it
   ($H(f_* p) \le H(p)$).
2. The amount of information destroyed equals the heat that must be dissipated, times $kT$.
3. Therefore irreversible steps cost heat, and the cost is exactly zero precisely for reversible
   steps.
4. Erasing $n$ bits is the extremal case, costing exactly $k\,T\,n\,\log 2$.
5. And any computation can be rebuilt out of reversible gates that never forget — so the heat is, in
   principle, avoidable.

The deepest surprise is how *little* mathematics it takes to see all of this. The whole edifice
balances on one homely fact: a sum of nonnegative numbers is at least as large as any one of its
parts. From that single pebble, the entire principle of the thermodynamic cost of forgetting comes
rolling down the hill. Heat, information, and logic — three faces of one idea, and the idea is
simply: *to forget is to pay, and to remember is to be free.*
