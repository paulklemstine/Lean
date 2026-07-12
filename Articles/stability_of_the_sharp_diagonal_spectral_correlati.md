# When "Almost Perfect" Forces "Perfect": The Hidden Rigidity of Correlated Yes/No Rules

Imagine a committee of $n$ experts, each casting a simple yes-or-no vote. From
their votes we build a decision rule: a function that reads the whole vote
pattern and outputs a single verdict, *approve* or *reject*. If we insist the
rule be **monotone** — switching any single "no" to a "yes" can never turn an
approval into a rejection — then we are in the world of *increasing Boolean
functions*, one of the most studied objects in modern combinatorics,
probability, and theoretical computer science.

A natural question about two such rules $f$ and $g$ is: **how correlated can
they be?** If both rules tend to approve on the same vote patterns, they are
positively correlated. It turns out that monotone rules are *always* positively
correlated — a beautiful and deep fact — and there is a sharp ceiling on how
strongly a rule can correlate with itself or with a partner. This article is
about what happens right at that ceiling, and the surprising *rigidity* that
lives there: when two rules correlate *almost* as strongly as mathematically
possible, they are forced to be one of only a few very specific shapes.

## The playing field

We work on the *Boolean cube*: the set of all $2^n$ possible vote patterns,
each an $n$-tuple of $0$s and $1$s, chosen uniformly at random. A Boolean
function $f$ assigns each pattern a value $0$ or $1$. Two summary numbers drive
everything:

- The **mean** $\mathbb{E}[f]$, the fraction of patterns on which $f$ outputs
  $1$ — its "approval rate."
- The **covariance** of two functions,
  $$\operatorname{Cov}(f,g) = \mathbb{E}[f\cdot g] - \mathbb{E}[f]\,\mathbb{E}[g],$$
  which measures how much more often $f$ and $g$ say "yes" *together* than
  chance alone would predict.

A function is **increasing** (monotone) if flipping any input coordinate from
$0$ to $1$ never decreases the output. Two classic examples on many coordinates:
a **dictatorship** $f(x) = x_i$, which simply echoes voter $i$; and the
two-coordinate **AND** $x_i x_j$ (approve only if both $i$ and $j$ say yes) and
**OR** $x_i \vee x_j$ (approve if either does).

## Positivity: monotone rules pull the same way

The first pillar is the celebrated **Harris–FKG correlation inequality**. In
plain terms: two increasing rules are never negatively correlated. If both rules
are more likely to approve when more voters approve, they cannot systematically
disagree.

> **Harris–FKG inequality.** If $f$ and $g$ are nonnegative and increasing,
> then $\operatorname{Cov}(f,g) \ge 0$.

This is not obvious — one can easily design *non-monotone* rules that are
anti-correlated — but monotonicity forbids it. Increasing events on the cube
live in a kind of cooperative universe.

## The self-correlation ceiling

Next we ask how strongly a single rule can correlate with *itself*. This is just
the variance, and for a yes/no function there is an exact and elegant formula.
Because a $0/1$ value is unchanged when squared ($0^2 = 0$, $1^2 = 1$), we get

> **Variance identity.** For any Boolean function $f$,
> $$\operatorname{Cov}(f,f) = \mathbb{E}[f]\bigl(1 - \mathbb{E}[f]\bigr).$$

The right-hand side is a downward parabola in the approval rate
$m = \mathbb{E}[f]$. It is largest exactly when $m = \tfrac12$, where it hits
$\tfrac14$, and it shrinks to $0$ as the rule approaches "always yes" or "always
no." So:

> **The self-correlation ceiling.** $\operatorname{Cov}(f,f) \le \tfrac14$,
> with equality precisely when $f$ is **balanced** ($\mathbb{E}[f] = \tfrac12$).

A dictatorship $x_i$ approves exactly half the time, so it sits right at the
ceiling with self-correlation $\tfrac14$.

## The heart of the story: stability

Here is where the mathematics becomes genuinely surprising. Sitting *exactly* at
the ceiling forces the rule to be exactly balanced. But real data is never
exact. What if a rule sits *almost* at the ceiling — within a tiny slack
$\varepsilon$? Does "almost extremal" force "almost balanced"? And how *almost*?

The answer is as clean as one could hope. The gap between the ceiling and the
actual variance is *exactly* the squared distance of the mean from $\tfrac12$:
$$\tfrac14 - \operatorname{Cov}(f,f) = \Bigl(\mathbb{E}[f] - \tfrac12\Bigr)^2.$$
Reading this identity as an inequality gives the sharp **stability theorem**:

> **Quantitative diagonal stability.** If
> $\operatorname{Cov}(f,f) \ge \tfrac14 - \varepsilon$, then
> $$\Bigl(\mathbb{E}[f] - \tfrac12\Bigr)^2 \le \varepsilon.$$

In words: a rule whose self-correlation is within $\varepsilon$ of the maximum
must have approval rate within $\sqrt{\varepsilon}$ of one-half. The constant is
$1$ — there is no hidden fudge factor — and the bound is sharp, because the
identity behind it is an *equality*. This is the phenomenon mathematicians call
**stability**: not only is the extremal configuration unique, but everything
*near* the extreme is quantitatively *near* that unique shape.

Stability results are the modern refinement of classical extremal theorems.
Knowing the maximum is one thing; knowing that approaching the maximum *pins
down the structure* is far more powerful. It is the difference between "the
tallest mountain is Everest" and "any peak within a hundred meters of Everest's
height must be Everest itself."

## Two rules at once: the AND/OR jewel

Self-correlation is the "diagonal" case ($f$ with itself). The richer, still
partly open, question concerns two *different* increasing rules. On the smallest
interesting cube — just two voters — the extremal partner pair is the
**AND/OR** couple. Take $f = x \wedge y$ (approve only if both say yes) and
$g = x \vee y$ (approve if either does). Since AND implies OR, their product is
just AND again, and a one-line computation gives approval rates $\tfrac14$ and
$\tfrac34$ and covariance
$$\operatorname{Cov}(x\wedge y,\ x\vee y) = \tfrac14 - \tfrac14\cdot\tfrac34 = \tfrac{1}{16}.$$

This little number $\tfrac{1}{16}$ is the off-diagonal analogue of the diagonal
ceiling $\tfrac14$. The emerging picture — a **trichotomy** — says that any two
increasing rules whose covariance is near-extremal must fall into exactly one of
three families:

1. **Disjoint rules** that depend on completely separate voters (covariance
   near $0$);
2. **Common dictatorships**, both echoing the same single voter (the diagonal
   extreme $\tfrac14$);
3. **AND/OR-type pairs**, close after relabeling voters to the jewel
   $(x_i x_j,\ x_i \vee x_j)$ (the off-diagonal extreme $\tfrac{1}{16}$).

These three families correspond to three distinct covariance values —
$0$, $\tfrac14$, and $\tfrac1{16}$ — and the exact knowledge of all three turns
the once-vague classification into a concrete, finite bookkeeping problem.

## Why it matters beyond the puzzle

Monotone Boolean functions are the mathematical DNA of reliability engineering
(does a network of components function?), of social choice (do voting rules
behave sensibly?), of statistical physics (do spins in a magnet align?), and of
theoretical computer science (how hard is a decision problem?). Correlation
inequalities like Harris–FKG are the workhorses tying these fields together, and
*stability* versions tell us that near-optimal behavior is not a fuzzy
continuum but a sharply structured landscape.

The diagonal case, resolved here with best-possible constants, is a complete
miniature of the whole program: an exact extremal value, a unique extremal
shape, and a tight, constant-free stability estimate proving that "almost
perfect" really does force "almost the perfect thing." One more pleasing bonus:
because the variance identity uses *only* that the function is $0/1$-valued and
never mentions which probability weighting we chose, the same sharp bound holds
verbatim under any biased coin — flip the voters' coins to any bias $p$ you
like, and the stability estimate $(\mathbb{E}_p[f] - \tfrac12)^2 \le \varepsilon$
survives untouched, with the same constant $1$.

That robustness is the quiet signature of a *right* theorem: it does not depend
on the incidental details, only on the essential ones. And it points the way
forward — to nailing down the full off-diagonal trichotomy with the same
uncompromising sharpness.
