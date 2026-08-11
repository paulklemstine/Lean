# The Heat of Forgetting a Proof

## What a proof costs to tidy up

Every mathematician has done it. You find an argument, and it is a mess: three lemmas
invoked in an arbitrary order, a case split that could have been done earlier or later, a
substitution performed in the wrong place. Then you clean it up. You *normalize* it. The
tidy proof is shorter, canonical, and — crucially — it is the same proof. Nothing was lost.

Except that something was lost, and it can be measured in joules.

The reason is a piece of physics from 1961 known as **Landauer's principle**: erasing one
bit of information in any physical device dissipates at least $k_B T \ln 2$ of heat, where
$T$ is the temperature and $k_B$ is Boltzmann's constant. Computation itself is free; only
*forgetting* costs. And tidying a proof is forgetting. When two hundred messy derivations
all normalize to the same canonical one, the normalizer has discarded the information about
which of the two hundred it started with. Run that normalizer on a physical machine and the
machine must warm the room by a definite, calculable amount.

This article is about how much. The answer turns out to be a genuinely two-sided law — not a
bound, not a heuristic, but an identity with an exactly characterized equality case — plus a
small family of surprises about how these costs behave when proofs are composed, shared, and
run in pipelines.

## Counting versus knowing

Here is the naive answer, and it is the one everybody reaches for first. Suppose a proof
term $x$ normalizes to $f(x)$. The set of all terms that normalize to the same thing,
$$f^{-1}(f(x)) = \{y : f(y) = f(x)\},$$
is called the **normalization fiber** of $x$. If the fiber has $N$ elements, then knowing
only the normal form leaves $\log_2 N$ bits of uncertainty about where you started. So the
cost of normalization "obviously" ought to be the average of $\log_2 N$ over all proofs:
$$\mathbb{E}\big[\log_2 |f^{-1}(f(x))|\big].$$
Call this the **fiber-counting estimate**. It is a pure piece of combinatorics: count the
preimages, take a logarithm, average.

The honest answer is different. What thermodynamics actually charges you for is *Shannon
entropy destroyed*, which for a probability law $p$ on proof terms is the conditional entropy
$$H(x \mid f(x)) = -\sum_x p(x) \log_2 \frac{p(x)}{P(f(x))}, \qquad
P(b) = \sum_{f(x) = b} p(x).$$
This is the average amount of information about $x$ still missing once you have been told
$f(x)$. It is a statistical quantity: it knows not just how many proofs are in a fiber, but
how likely each of them is.

The two quantities are not the same, and the discrepancy has a clean explanation. If one
messy derivation is overwhelmingly more common than its ninety-nine siblings, then learning
only the normal form has barely cost you anything — you can guess the original almost every
time. The fiber still has a hundred elements, so the counting estimate still charges you
$\log_2 100 \approx 6.64$ bits. But the entropy actually destroyed is close to zero.

## The Fiber-Entropy Law

The first main result makes this exact.

> **Fiber-Entropy Law.** Let $f$ be a normalization map on a finite set of proof terms and
> let $p$ be any non-negative weight on those terms. Then
> $$H(x \mid f(x)) \;\le\; \mathbb{E}\big[\log_2 |f^{-1}(f(x))|\big],$$
> and equality holds **if and only if** $p$ is constant on every fiber of $f$ — that is,
> if and only if the conditional law inside each fiber is uniform. Any deviation from
> fiberwise uniformity makes the inequality strict.

So the naive count is not merely an approximation. It is *exactly right* in one precisely
delimited circumstance — when all the proofs of a given theorem are equally likely — and
*strictly pessimistic* in every other circumstance, with no exceptions. Translated into
physics: the fiber-counting heuristic always over-charges the normalization, and the
over-charge is zero exactly on fiberwise-uniform laws. The same statement holds verbatim in
energetic units, since the Landauer work is just the bit count multiplied by the positive
constant $k_B T \ln 2$.

The proof is a sharpened version of a classical fact — that entropy is maximized by the
uniform distribution — but sharpened in a way that matters. The usual maximum-entropy
statement assumes the weights sum to one. Here they need not: the law applies to
unnormalized multiplicity counts and to sub-probability laws just as well, and fibers of
total weight zero are handled rather than excluded. The engine is the elementary estimate
$t(\log c - \log t) \le c - t$ for $t \ge 0 < c$, whose equality case is precisely $t = c$.
A vanishing weight, notably, is *strictly* suboptimal: a proof term that never occurs inside
a fiber that does occur is already a departure from uniformity, and the law correctly
detects it.

A three-term example makes the gap concrete. Take three proof terms, of which the first two
normalize to one thing and the third to another, and let the law be $(1/2, 1/4, 1/4)$. The
fiber-counting estimate is exactly $3/4$ of a bit. The entropy actually destroyed is
$\tfrac{3}{4}\log_2 3 - \tfrac12 \approx 0.68872$ bits. The counting heuristic over-charges
by $\tfrac54 - \tfrac34\log_2 3 \approx 0.0613$ bits — small, but strictly positive, and
predicted to the last digit by the law.

## Two hundred proofs of a three-line theorem

The Fiber-Entropy Law has content only if fibers can be large. Can they? Can a short
theorem, with a short canonical proof, have astronomically many messy derivations?

They can, and the second main result exhibits a rewrite system where this happens in the
most transparent possible way. Fix $n$ and consider a calculus whose derivations are pairs
$(u, c)$, where $c \in \{0,1\}^n$ is an $n$-bit **conclusion** — the theorem being proved —
and $u \in \{0,1\}^n$ is a **bookkeeping vector** recording, for each of $n$ independent
inference blocks, whether the derivation performed that block in the fussy "bureaucratic"
order or in the canonical one. The calculus has exactly $n$ rewrite rules. Rule $i$ says:
if block $i$ is in bureaucratic order, put it in canonical order, and change nothing else.

This is not an artificial gadget; it is the shape of a *permutative conversion*, the most
ordinary kind of proof-theoretic tidying there is. Two independent inference steps were done
in one order rather than the other; the rewrite swaps them; the mathematical content is
untouched.

Everything one wants of such a calculus is true of it, and provably so.

- **Strong normalization.** The number of blocks still in bureaucratic order strictly
  decreases with every rewrite, so the rewrite relation is well-founded: there is no infinite
  reduction sequence, from any derivation, under any strategy.
- **Normal forms are characterized, not decreed.** A derivation admits no rewrite at all
  exactly when every block is in canonical order. Irreducibility and canonicity coincide;
  this is a theorem about the rewrite relation, not a definition.
- **Unique normal forms.** Whatever order the rules are applied in, the only normal
  derivation reachable from $(u,c)$ is $(\mathbf{0}, c)$. The calculus is confluent in the
  strongest sense: one derivation, one destination.
- **Linear-time normalization.** Every derivation reaches its normal form in at most $n$
  steps — indeed in exactly as many steps as it has bureaucratic blocks.
- **Exponential fibers.** Every normal derivation has exactly $2^n$ preimages under
  normalization, and every one of those $2^n$ preimages reaches it within $n$ steps.

Look at the arithmetic. The theorem is $n$ bits long. Its canonical proof is $n$ bits long.
Normalization takes at most $n$ steps. And the number of derivations collapsing onto that one
canonical proof is $2^n$. For $n = 30$ — a statement you could write on a napkin, with a
proof you could check over coffee — there are more than a billion bureaucratically distinct
derivations, every one of them normalizing in at most thirty steps.

Proof-term multiplicity, in other words, is controlled by *none* of the syntactic size
parameters. Not the length of the theorem, not the length of the normal proof, not the
running time of the normalizer. That is exactly the regime in which the Fiber-Entropy Law
has teeth.

And here the law applies in its equality case, because the uniform law on derivations is
trivially uniform on each fiber. So the accounting is not a bound but an identity:
normalizing this calculus destroys **exactly $n$ bits**, and dissipates **exactly**
$n \, k_B T \ln 2$ of heat. For $n = 3$: eight conclusions, sixty-four derivations, eight
normal derivations, fibers of size eight, three bits erased, three steps at most. Every
number checks.

## Sharing lemmas is not free — but it is never expensive

Real mathematics does not verify one obligation at a time. It verifies many, and they share
lemmas. What does sharing do to the energy budget?

The naive guess — and it was the guess this work set out to confirm — is that verifying two
obligations jointly rather than separately saves exactly the **mutual information** between
them, the standard measure of how much knowing one tells you about the other. That guess is
**false**, and the correct statement is more interesting.

> **Compositional Landauer Accounting.** Let two proof obligations be verified by maps $f$
> and $g$, under an arbitrary non-negative joint law $p$ on pairs of proofs. Then
> $$\underbrace{H(x_1 \mid f x_1) + H(x_2 \mid g x_2)}_{\text{separate}}
> \;-\; \underbrace{H\big((x_1,x_2) \mid (f x_1, g x_2)\big)}_{\text{joint}}
> \;=\; I(\text{inputs}) - I(\text{outputs}).$$

The saving is not the mutual information of the inputs; it is the mutual information the
verification *destroys* — the drop from input correlation to output correlation. The naive
form is the special case in which verification annihilates all correlation, so that
$I(\text{outputs}) = 0$; that happens often enough (any verifier that collapses its input to
a single "verified" token does it) to make the false guess plausible.

Two corollaries pin down its behaviour. First, **additivity for independent obligations**:
if the two obligations are statistically independent, both mutual informations vanish and
the joint cost is exactly the sum of the separate costs. Sharing nothing saves nothing.
Second, **the saving is never negative**: by the data-processing inequality — verification,
being a deterministic function of its input, cannot manufacture correlation — the output
mutual information never exceeds the input one. Joint verification is never more expensive
than separate verification. Sharing lemmas can only help, and exactly how much it helps is
computable.

The extreme case is a clean one-bit ledger. Take two obligations, each a single bit, and a
joint law supported on the diagonal so that each determines the other — "the same lemma
twice". Each is verified by a total collapse. Separately, the two verifications destroy
$1 + 1 = 2$ bits. Jointly they destroy $1$ bit. The input mutual information is $1$, the
output mutual information is $0$, and the predicted saving of exactly one bit is realized
exactly.

## Entropy composes; multiplicity does not

The last surprise concerns pipelines. Normalization is rarely a single step: one normalizes,
then normalizes again in a coarser sense, then again. What is the cost of a pipeline
$X \to Y \to Z$?

For entropy, the answer is as good as it could possibly be.

> **Pipeline Chain Rule.** For any non-negative law, the entropy destroyed by a two-stage
> normalization is exactly the entropy destroyed by the first stage plus the entropy
> destroyed by the second stage acting on the pushed-forward law:
> $$H(x \mid g(f(x))) = H(x \mid f(x)) + H(f(x) \mid g(f(x))).$$
> There is no correction term, at any law, ever.

For fiber counting, the answer is much worse than one would expect. Under a uniform law the
fiber-counting estimate is at least subadditive, and there is a crisp criterion for when it
is exactly additive: precisely when all first-stage fibers lying over a common second-stage
fiber have the same size. But under a merely *skewed* law, subadditivity **fails outright**.

The counterexample is tiny and fully supported — no degenerate zero weights, no point masses.
Take three proof terms; the first stage sends the first term to one class and the other two
to a second class; the second stage collapses everything to a point; and let the law be
$(4/5,\, 1/10,\, 1/10)$. Stage one has fiber-counting cost $1/5$, stage two has cost $1$, for
a two-stage total of $6/5 = 1.2$. But the honest one-stage estimate for the composite is
$\log_2 3 \approx 1.585$. The pipeline accounting *under-reports* the cost by nearly four
tenths of a bit.

Why? Because the composite fiber size is the *sum* of the first-stage fiber sizes — an
$\ell^1$ quantity — while the two-stage estimate is a weighted geometric mean of them. Under
a uniform law those two effects cancel exactly. Under a skewed law that concentrates on a
small fiber sitting next to a large one, they do not. The failure is structural, not
statistical noise.

The moral is sharp, and it is the one line to take away from all four results: **entropy
composes, multiplicity does not.** Counting preimages is a seductive proxy for thermodynamic
cost — it is exact for a single step under a uniform law, and the bureaucratic calculus shows
it can be exact and enormous at once — but the moment steps are composed and the law is not
uniform, the proxy is not even a bound in the safe direction.

## Why this matters beyond the thermometer

Nobody is about to bill a mathematician for the electricity of tidying a proof. The point of Landauer
accounting here is not the joules; it is that thermodynamics supplies an *invariant*. It
insists that the right measure of what a proof transformation does is the conditional entropy
of the transformation, and it makes precise, testable claims about how that measure behaves
under composition, sharing, and normalization.

Those claims cut against intuition in useful ways. Multiplicity is not size: a thirty-bit
theorem can hide a billion derivations that normalize in thirty steps. Correlation is not
saving: sharing a lemma saves the correlation you *destroy*, not the correlation you have.
Composition is not free: the natural combinatorial estimate silently breaks along pipelines,
and only the entropic one survives.

The next questions almost ask themselves. The gap between the fiber count and the true
entropy is not merely positive off the uniform locus — it looks like a *distance* to that
locus, a weighted sum of relative entropies between each fiber's conditional law and the
uniform law on that fiber, which would upgrade "the heuristic is strictly pessimistic" to
"the heuristic is pessimistic by exactly this much, and here is a quantitative stability
bound". Beyond that lie time–space–energy tradeoffs for reversible verification, where
keeping a transcript avoids erasure at the price of recomputation, and questions about
incompressible proof families whose information has to enter a verifier *somewhere* — through
its input or through its heat.

For the moment, though, the ledger balances. Tidying a proof costs something; we now know
what, when the naive count is right, when it lies, and by how much.
