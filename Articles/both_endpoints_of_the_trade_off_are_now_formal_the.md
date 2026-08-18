# The Price of Certainty: How Far Back Must a Decoder Look?

## A question every decoder must answer

Imagine you are listening to a noisy phone call. Someone says a word, and for a
fraction of a second you are not sure whether you heard "fifteen" or "fifty".
You have two options. You can commit immediately, guess, and move on. Or you can
wait — hold the ambiguity open for another second or two, let the rest of the
sentence arrive, and then decide. "Fifty dollars" and "fifteen dollars" sound
alike; "fifty-fifty chance" and "fifteen-fifty chance" do not.

Waiting works. But waiting costs. Every extra fraction of a second you hold open
is memory you must spend, arithmetic you must do, and latency your listener must
tolerate. The whole engineering discipline of decoding — for cellular modems,
hard drives, speech recognizers, gene-sequence aligners, GPS receivers — lives
inside that one trade-off. How far back must you look, and what do you pay for it?

This article is about a complete, quantitative answer to that question in a
setting where the answer can be made exact: **min-plus decoding on a chain**. We
will see that the cost of looking back grows *linearly* with the lookback window,
that the failure probability shrinks *exponentially* with it, that the two match
each other to within a whisker, and — most surprisingly — that the exponential
gain is *not* an algebraic phenomenon at all. The algebra, by itself, refuses to
give it to you. We will prove that refusal is real, by exhibiting a system in
which the algebraic memory never fades, not even a little, no matter how long you
wait.

## The arithmetic of shortest paths

Start with the mathematics of "best explanation". Suppose a hidden system moves
through a sequence of states $s_0, s_1, s_2, \dots$, and each transition from
state $b$ to state $a$ at time $i$ carries a *cost* $A^{(i)}_{ab}$ — how
implausible that transition is, given what you observed. The best explanation of
the whole sequence is the path of least total cost. Finding it is a shortest-path
problem, and the classical way to solve it is dynamic programming: work backwards,
maintaining for each state a *cost-to-go* number $v_a$, the cheapest way to finish
from state $a$ onwards, and update it one step at a time by

$$(A \otimes v)_a \;=\; \min_b \bigl( A_{ab} + v_b \bigr).$$

Stare at this formula for a moment. It is matrix–vector multiplication, with
$\min$ where the sum used to be and $+$ where the product used to be. That
substitution is not a coincidence or a pun: $(\mathbb{R}, \min, +)$ is a perfectly
good algebraic system — a *semiring* — in which $\min$ plays the role of addition
and $+$ plays the role of multiplication. It is called the **tropical semiring**,
and in it, dynamic programming *is* linear algebra. Shortest paths are matrix
powers. The Viterbi algorithm is a product of matrices. Every intuition you have
about how linear operators mix information has a tropical shadow, and the whole
point of what follows is to chase that shadow and find out exactly where it falls
short.

## What a decoder actually sees

Here is the first key observation, and it is elementary but decisive.

A decoder does not care about the cost-to-go vector $v$. It cares about
$\arg\min_a \bigl(u_a + v_a\bigr)$, where $u$ is the local cost of the decision
it is about to make. If you add the same constant to every entry of $v$, nothing
changes: the same state wins. The decoder sees $v$ only *projectively*, up to a
global shift.

So the right measure of "how much information is left in $v$" is not its size but
its **span**:

$$\mathrm{sp}(v) \;=\; \max_a v_a \;-\; \min_a v_a .$$

If $\mathrm{sp}(v) = 0$, the vector is constant, it carries no information, and
the decoder's decision is determined entirely by the local cost $u$ — the future
has been forgotten. If $\mathrm{sp}(v)$ is large, the future still matters a great
deal. The span is the memory of the decoder, measured in the only units the
decoder can perceive.

We can now say precisely what "waiting doesn't help" would mean: it would mean
the span shrinks to zero. And we can say precisely how much waiting we can afford
to skip.

## Two theorems about forgetting

Normalize first. Any transfer matrix can be adjusted by subtracting from each row
its own minimum, which changes no decision and no shortest path — only the
bookkeeping. Call a matrix **tropically stochastic** when every row already has
minimum $0$; it is the min-plus analogue of a row-stochastic matrix, and every
matrix is equivalent to one.

**Theorem (Nonexpansiveness).** *If $A$ is tropically stochastic, then for every
cost-to-go vector $v$,*
$$\mathrm{sp}(A \otimes v) \;\le\; \mathrm{sp}(v).$$

Memory never *increases*. The proof is two lines: stochasticity forces every
entry $A_{ab} \ge 0$, so each new entry $\min_b(A_{ab} + v_b)$ is at least
$\min_b v_b$; and because each row contains a zero, each new entry is at most
$\max_b v_b$. The new vector lives inside the old vector's range.

That's the easy half. The interesting half concerns *how fast* memory decays, and
here the relevant quantity is the **diameter** of the transfer matrix:

$$\Delta(A) \;=\; \max_{a,a',b} \bigl( A_{ab} - A_{a'b} \bigr),$$

the largest disagreement between two rows about the cost of the same destination.
If $\Delta(A) = 0$, all rows are identical: the matrix tells you nothing about
where you came from, and it wipes the slate clean. If $\Delta(A)$ is large, the
matrix is highly discriminating and preserves distinctions.

**Theorem (Tropical Dobrushin contraction).** *For every matrix $A$ — stochastic
or not — and every vector $v$,*
$$\mathrm{sp}(A \otimes v) \;\le\; \Delta(A).$$

The remarkable feature is the absence of $v$ on the right-hand side. One step of
min-plus propagation *forgets everything* down to the level $\Delta(A)$,
regardless of how wild the input was. The proof takes half a page: pick the state
$a$ where the output is minimal, pick the $b$ that achieves that minimum, and
compare every competitor $a'$ against that same $b$; the gap is exactly a row
difference, bounded by $\Delta(A)$.

This is the tropical mirror of a beautiful classical fact. In ordinary Markov
chains, Dobrushin's ergodic coefficient measures how much a transition matrix
mixes, and iterating a mixing matrix drives any two distributions together
geometrically. The tropical version has the same shape and the same name. What it
does *not* have — and this is the heart of the story — is the geometric decay.

## The absorption theorem: one good step is enough

Chain the diameter bound with nonexpansiveness and something clean falls out.
Propagate a cost-to-go vector backwards through a window of $k$ consecutive
transfer matrices $A^{(i)}, A^{(i+1)}, \dots, A^{(i+k-1)}$, and write
$W_{i,k}(v)$ for the result.

**Theorem (Absorption).** *For every $j < k$,*
$$\mathrm{sp}\bigl(W_{i,k}(v)\bigr) \;\le\; \Delta\bigl(A^{(i+j)}\bigr),$$
*and hence*
$$\mathrm{sp}\bigl(W_{i,k}(v)\bigr) \;\le\; \min_{j<k} \Delta\bigl(A^{(i+j)}\bigr).$$

Read that carefully, because it is stronger and stranger than it looks. It is not
"the span decays as you accumulate more steps". It is: **a single good step
anywhere inside the window already caps the span, and the rest of the window is
irrelevant.** Split the window at position $j$; the steps after $j$ produce
*something*, the step at $j$ crushes that something down to $\Delta(A^{(i+j)})$,
and the steps before $j$ — being nonexpansive — cannot undo the damage. Memory
loss is not erosion. It is a trapdoor.

There is a matrix-level companion: tropically stochastic matrices are closed
under the min-plus product, and the diameter is monotone under composition,
$\Delta(A \otimes B) \le \min\bigl(\Delta(A), \Delta(B)\bigr)$. Composing can only
help you forget.

## The noise floor: why algebra cannot finish the job

So far so encouraging. A natural next hope is a contraction estimate of the
familiar form
$$\mathrm{sp}\bigl(W_{i,k}(v)\bigr) \;\le\; \rho^{\,k}\,\mathrm{sp}(v)
\qquad \text{for some } \rho < 1,$$
the kind of geometric decay that makes classical Markov chains so tractable. If
such a bound held, the exponential reliability of long-window decoding would be a
theorem of pure algebra.

It does not hold. Here is the counterexample, and it fits in a sentence.

Take two states, and the symmetric transfer matrix
$$T_d = \begin{pmatrix} 0 & d \\ d & 0\end{pmatrix}, \qquad d \ge 0,$$
which is tropically stochastic with $\Delta(T_d) = d$. Take the cost-to-go vector
$v = (0, d)$. Then
$$T_d \otimes v = \bigl(\min(0+0,\; d+d),\ \min(d+0,\; 0+d)\bigr) = (0, d) = v .$$
It is a fixed point. Apply $T_d$ a thousand times and nothing moves.

**Theorem (Tropical noise floor).** *For the two-state chain with transfer matrix
$T_d$, for every $k \ge 0$ and every starting position,*
$$\mathrm{sp}\bigl(W_{i,k}(v)\bigr) \;=\; d \;=\; \Delta(T_d).$$

The absorption bound is attained with equality *at every window length*. There is
no $\rho < 1$. There is no decay. The system's ambiguity between its two states is
permanent: the chain is perfectly symmetric, and no amount of symmetric evidence
ever breaks a symmetry.

This is a genuine obstruction, and it reshapes the problem. It says: whatever
makes long windows exponentially reliable in practice, it is not the tropical
algebra. Algebra gives you one-step absorption to $\Delta$, and then it stops.
The exponential must come from somewhere else.

## Where the exponential actually lives

It comes from *chance*.

In a real channel, the transfer matrices are not all the same. Some steps are
**informative** — the observation strongly discriminates between states, the
diameter $\Delta(A^{(i)})$ is small, the trapdoor is open. Others are
**uninformative** — noise swamped the signal, the diameter is large, nothing is
learned. Model this the simplest way possible: each step is informative
independently with probability $p$.

Now recall what the absorption theorem gives us: **one informative step anywhere
in the window suffices.** The window-$b$ decoder fails at a position only if the
entire window of $b$ consecutive steps happens to be uninformative — a run of $b$
independent coin flips all coming up bad. The probability of that is exactly
$(1-p)^b$, and the probability that *some* window along a chain of length $n$
fails is, by a union bound over the $n+1-b$ available windows,

$$\Pr[\text{failure}] \;\le\; (n+1-b)\,(1-p)^b .$$

There is the exponential. It is a statement about independent coin flips, not
about min-plus matrices. The algebra's role was to reduce "the decoder is correct"
to "the window contains one good step" — a purely combinatorial event — and the
probability theory does the rest.

To make "the decoder is correct" precise, one more algebraic ingredient is needed.
Say a decision $a_0$ wins by **margin** $m$ if $u_{a_0} + V_{a_0} + m \le u_a + V_a$
for every competitor $a$. Then:

**Theorem (Robustness).** *If $a_0$ wins by margin $2\theta$ against one
cost-to-go vector of span at most $\theta$, then $a_0$ is optimal for* every
*cost-to-go vector of span at most $\theta$.*

Combine that with absorption and you get the punchline: if the window contains one
step of diameter at most $\theta$, and the windowed decision wins by $2\theta$,
then that decision agrees *exactly* with what a decoder using the full remaining
horizon would have chosen — for every longer horizon, all the way to infinity.
Truncation is not an approximation. On a good window, it is free.

## The trade-off, from both sides

Now count. A window-$b$ decoder at each of $n$ positions performs $b$ min-plus
matrix–vector products on $q$ states, at $q^2$ operations each:

$$C(b) \;=\; n\,b\,q^2 .$$

Cost is exactly linear in the window. The two classical extremes are the endpoints
of one line: the greedy symbol-by-symbol decoder ($b = 1$) costs $n q^2$ and fails
with probability up to $n(1-p)$; the full-block decoder ($b = n$) costs $n^2 q^2$
and fails with probability at most $(1-p)^n$. Everything in between is a genuine
interpolation — cost climbing linearly, failure probability falling
exponentially.

Is the exponential the best possible? Yes, and this is the converse. A single
window is already enough to fail, so $\Pr[\text{failure}] \ge (1-p)^b$, giving

$$\log \frac{1}{\Pr[\text{failure}]} \;\le\; b \log \frac{1}{1-p}.$$

**No windowed decoder can have a reliability exponent better than
$b \log\frac{1}{1-p}$.** Wanting failure probability below $\varepsilon$ therefore
*forces*
$$b \;\ge\; \frac{\log(1/\varepsilon)}{\log\frac{1}{1-p}},
\qquad\text{and hence}\qquad
C(b) \;\ge\; n q^2 \cdot \frac{\log(1/\varepsilon)}{\log\frac{1}{1-p}} .$$

Cost is $\Theta(\log(1/\varepsilon))$: every additional nine of reliability costs
the same fixed increment of computation. And it matches from above — any window of
length at least $\bigl(\log n + \log(1/\varepsilon)\bigr) / \log\frac{1}{1-p}$
already achieves failure probability $\varepsilon$. The optimal window length is
pinned between two thresholds separated by only an additive $\log n / \log\frac{1}{1-p}$.

That gap can be narrowed. The union bound loses a factor because the $n+1-b$
windows overlap; but $\lfloor n/b \rfloor$ of them — those starting at
$0, b, 2b, \dots$ — are *disjoint*, hence genuinely independent, and a
second-order Bonferroni inequality converts that independence into

$$\Pr[\text{failure}] \;\ge\; m(1-p)^b - \binom{m}{2}(1-p)^{2b}
\;\ge\; \frac{m}{2}(1-p)^b
\quad\text{whenever } m(1-p)^b \le 1 .$$

With $m = \lfloor n/b\rfloor$ the failure probability is genuinely *linear* in
$n/b$, and the residual gap between what is necessary and what is sufficient
collapses from $\log n$ to $\log(2b)$.

Everything above can be compressed into a single inequality — the exchange rate
between computation and certainty:

$$\log\frac{1}{\Pr[\text{failure}]} \cdot n q^2
\;\le\; C(b) \cdot \log\frac{1}{1-p}.$$

Reliability exponent per unit of per-position budget never exceeds total cost times
the per-step informativeness rate. Cost buys reliability, at a fixed and knowable
price.

## Why this is worth knowing

Three things, I think.

First, it is a clean instance of a **division of labour between algebra and
probability**. It is tempting, when a system behaves well, to look for a single
mechanism. Here there are two, and they are cleanly separated by a theorem. The
algebra contributes absorption — a hard, deterministic, one-step statement with no
decay in it. The probability contributes the exponential — via independence, which
the algebra cannot supply. The noise floor theorem is the proof that neither can
do the other's job. That kind of impossibility result is worth more than another
estimate: it tells you where not to look.

Second, it turns folklore into arithmetic. "Longer traceback is more reliable but
costs more" is something every communications engineer knows. Here it becomes
$C(b) = nbq^2$, $\Pr[\text{fail}] \asymp (n/b)(1-p)^b$, and an optimal window
length determined up to an additive $\log(2b)/\log\frac{1}{1-p}$. You can now
*design* a traceback depth rather than tune it.

Third, tropical mathematics keeps proving that it deserves the analogies it
borrows. Dobrushin coefficients, nonexpansive operators, contraction, ergodicity —
all of it transplants. But the transplant is not perfect, and the imperfection is
the interesting part. In the classical world, mixing compounds: apply a contraction
twice and you get $\rho^2$. In the tropical world, mixing *absorbs*: apply the best
contraction once and you are done, and applying it again buys you nothing. The
min-plus world is a world of records and thresholds, not of averages, and records
do not compound the way averages do. The noise floor is that difference, made
visible in a two-by-two matrix.

The next time you wait a beat before deciding whether you heard "fifteen" or
"fifty", you are running a windowed min-plus decoder, and the length of your pause
is a solved optimization problem. Wait long enough for one informative syllable to
land — and no longer.
