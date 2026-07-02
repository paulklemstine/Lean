# When a Single Neuron Learns *Exactly*: The Hidden Geometry of Learned Concepts

## A machine that never makes a mistake — on the data it has seen

Every student of machine learning meets the same reassuring slogan early on:
neural networks are *universal approximators*. Give a network enough neurons and
it can mimic any reasonable function as closely as you like. It is a comforting
promise, but it hides a subtle disappointment. *Approximation* means "close, but
not quite." On any finite collection of examples, an approximator might still get
a few of them wrong, or hover uncertainly near the decision boundary.

This article is about a sharper and, in some ways, more surprising promise. On a
finite set of distinct examples, a strikingly small architecture — a *single*
nonlinear feature stage followed by a polynomial read-out — does not merely
approximate a labeling. It reproduces it **exactly**, with room to spare. Every
example is classified correctly, the network's numerical output equals the
intended label on the nose, and there is a fixed, guaranteed *margin* of
confidence separating the two classes. No error, no ambiguity, no "close enough."

The result reframes a question that quietly haunts modern machine learning: *what
does it actually cost to represent a concept perfectly?* The answer turns out not
to depend on the deep, mysterious internals of a network at all. It depends on
something far more transparent — the **geometry of how features pull distinct
inputs apart**.

## The setup: features first, decision second

Picture the pipeline in two stages. First a **feature map** $\Phi$ takes a raw
input $x$ — an image, a molecule, a sentence — and turns it into a numerical
signature $\Phi(x)$. Then a **read-out** function looks only at that signature
and produces a score; the sign of the score is the predicted class, say $+1$ or
$-1$.

The single property we demand of the feature map is that it be **injective**:
distinct inputs receive distinct signatures. This is not a strong assumption. It
merely says the feature stage does not *confuse* two genuinely different inputs by
collapsing them to the same point. Any reasonable, information-preserving
encoder — one that does not throw away the very distinctions we hope to classify —
qualifies.

For the read-out we use a **polynomial**. Polynomials are the most elementary
nonlinear building blocks in mathematics: sums of powers, $p(t) = c_0 + c_1 t +
c_2 t^2 + \cdots$. They are easy to write down, easy to evaluate, and — as we are
about to see — astonishingly expressive.

Put together, the network computes
$$
N(x) = p\big(\Phi(x)\big),
$$
a polynomial read-out sitting on top of an injective feature stage. That is the
whole machine.

## The exact realizability theorem

Here is the central result, stated plainly.

> **Exact Realizability Theorem.** Let $\Phi$ be any injective feature map, and
> let $x_1, x_2, \dots, x_n$ be finitely many *distinct* inputs, each tagged with
> an arbitrary label $y_i \in \{-1, +1\}$. Then there is a polynomial read-out
> $p$ such that the network $N = p \circ \Phi$ satisfies
> $$
> N(x_i) = y_i \qquad \text{for every } i.
> $$
> Consequently the sign of the output equals the label at every example,
> $\operatorname{sign} N(x_i) = y_i$, and the output has a *fixed margin*:
> $\lvert N(x_i)\rvert = 1$ for all $i$.

Read that again. The labeling $y_1, \dots, y_n$ was **arbitrary** — any pattern
of pluses and minuses whatsoever, including the most adversarial, checkerboarded,
seemingly-random assignment you could devise. And yet a single polynomial
read-out reproduces it exactly, hitting each target label precisely and leaving a
clean unit gap between the classes.

## Why it works: distinctness becomes interpolation

The proof is a small miracle of leverage, and its engine is a classical idea:
**polynomial interpolation**.

Because the feature map $\Phi$ is injective and the inputs $x_1, \dots, x_n$ are
distinct, their signatures $t_i = \Phi(x_i)$ are also distinct numbers. We now
have $n$ distinct points $t_1, \dots, t_n$ on the real line, and at each one we
wish the polynomial to take a prescribed value $y_i$.

That is *exactly* the problem Lagrange solved in the eighteenth century. Through
any $n$ points with distinct $t$-coordinates there passes **one and only one**
polynomial of degree at most $n - 1$. Its formula can be written down explicitly:
$$
p(t) \;=\; \sum_{i=1}^{n} y_i \prod_{j \ne i} \frac{t - t_j}{t_i - t_j}.
$$
Each product term is a polynomial that equals $1$ at $t_i$ and vanishes at every
other $t_j$. Summing these "indicator polynomials," weighted by the labels,
produces a curve that threads perfectly through every target: $p(t_i) = y_i$.

Composing with the feature map gives $N(x_i) = p(\Phi(x_i)) = p(t_i) = y_i$. The
denominators $t_i - t_j$ are nonzero precisely *because* injectivity guaranteed
the signatures are distinct — the single geometric hypothesis of the theorem is
also the single thing that makes the formula well defined. Distinctness of inputs
becomes distinctness of features becomes solvability of interpolation. That is the
entire argument.

## The two morals

Two lessons emerge, and each rearranges an intuition.

**First: exactness is free once features separate.** The heavy lifting is not done
by the read-out. It is done by the feature map's refusal to confuse distinct
inputs. The polynomial is merely the bookkeeping that turns separated points into
a curve. In slogan form: *the power to memorize perfectly is a property of the
representation, not of the classifier.*

**Second: confidence is built in.** Because the network outputs precisely $+1$ or
$-1$ on the data, the *output margin* — the numerical gap between the two
classes — is not something you have to fight for through regularization or lucky
initialization. It is exactly $1$, guaranteed, every time. Whatever robustness a
model might have left to gain must therefore live somewhere else entirely: not in
the output score, but back in the input space, in *how far apart* the feature map
manages to push genuinely different inputs.

That second moral is the doorway to everything that comes next.

## The geometry of learning is the geometry of separation

If the output margin is always pinned at $1$, then the real question of
*robustness* — how much can I perturb an input before the network changes its
mind? — cannot be answered by staring at the read-out. It is decided upstream, by
the feature map's **separation modulus**: the smallest distance between any two
distinct feature signatures.

This reframing is quietly radical. Certified-robustness engineering, the discipline
of proving that a classifier cannot be fooled by small perturbations, usually
measures margins out in *input space*, where the data lives. Universality theory,
by contrast, lives in *output space*, where the scores are computed. The exact
realizability theorem shows these two worlds meet at exactly one hinge: the
feature map. Fix the output margin at a constant, and every remaining question
about safety, stability, and confidence becomes a question about how strongly the
features separate the data.

Three natural conjectures crystallize this program, and each is a concrete,
checkable refinement rather than a vague hope.

**Input-space margin follows feature separation.** For a well-behaved (injective
and Lipschitz) feature map on a bounded domain, the largest robust margin one can
carve out in input space should be squeezed between two quantities determined by
the *features alone*: bounded below by a monotone function of the minimum pairwise
feature separation, and above by half the distance between the nearest pair of
oppositely-labeled points. Robustness would then be *certifiable from the feature
map*, without ever inspecting the read-out.

**The cost of a concept is its alternation count.** To realize an arbitrary
labeling of $n$ feature values, a polynomial of degree $n-1$ always suffices — and
for the nastiest labelings, nothing smaller works. But for a *specific* concept,
the true cost should be far more revealing: order the inputs along the feature
axis, walk from one to the next, and count how many times the label flips. The
minimal read-out degree needed should equal one plus that number of sign changes.
In this picture, the difficulty of learning a rule is a *combinatorial invariant
of the rule itself* — its "wiggle" in feature order — not an accident of
architecture. Model compression, which hunts for the smallest exact
representative of a learned behavior, would gain a precise target instead of a
heuristic stopping rule.

**Exactness is stable under drift.** Deployed feature extractors are never frozen:
they get fine-tuned, quantized, and nudged. The conjecture is that exactness is an
*open* condition — if the feature map is perturbed by less than half the minimum
feature separation, then every labeling that was exactly realizable before remains
exactly realizable after, with read-out coefficients that vary continuously with
the perturbation. Perfect interpolation would then be robust to the small drift
of real systems, not a knife-edge phenomenon.

## Why this matters beyond the theorem

It is tempting to file "a polynomial can interpolate any labels" under *classical
curiosity*. What lifts it is the interpretation. Modern machine learning is
obsessed with three things: **expressivity** (what can a model represent?),
**robustness** (can it be fooled?), and **compression** (how small can it be?).
The exact realizability theorem, together with the geometric program it opens,
speaks to all three at once, and it does so by relocating the action.

Expressivity is *not* the bottleneck: a single neuron with a polynomial read-out
already represents every finite concept exactly. Robustness is *not* about the
decision layer: with the output margin fixed, all robustness lives in feature
separation. Compression is *not* an architectural search: the honest size of a
learned rule is a combinatorial count of how often its label alternates in feature
order.

In each case the lesson is the same, and it is a hopeful one. The most inscrutable
part of a learning system — the tangle of weights inside the network — is not
where the fundamental limits hide. They hide in something we can *see, measure,
and reason about*: the geometry of the features, the distances between the points,
the pattern of the labels along a line. Learn to read that geometry, and the
behavior of the machine stops being a mystery and starts being a theorem.
