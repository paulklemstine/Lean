# How to Approximate a Crowd by Calling a Few Names — Sharply, and Without Luck

Picture a vast assembly hall. Thousands of people are scattered across the floor,
and somewhere among them stands an invisible point: the *center of gravity* of the
crowd. If everyone were a tiny equal weight, this center would be the average of
all their positions. More generally, suppose each person $i$ carries a weight
$p_i \ge 0$, with all the weights adding up to one, $\sum_i p_i = 1$. Then the
balance point is the weighted average

$$x = \sum_i p_i V_i,$$

where $V_i$ is the position of person $i$. Physicists call $x$ the *centroid*;
geometers call it a *convex combination*; in the language of optimization it is a
point inside the convex hull of the crowd.

Now a strange request arrives. You are told: *forget the exact weights. Just pick a
short list of $k$ people — you may name the same person more than once — and report
the plain, unweighted average of the people on your list. Get as close to the true
balance point $x$ as you possibly can.*

How well can you do? And — more subtly — can you find your list **without
gambling**, by a rule that a computer could follow step by step and that you could
later check line by line?

This is the **approximate Carathéodory problem**, and it sits at the crossroads of
geometry, probability, and the algorithms that power modern machine learning. This
article tells the story of a sharp, *deterministic* answer to it, and of an
unexpected bridge from that answer to the way engineers carve up space into ever
finer triangular meshes.

## The classical promise: $R/\sqrt{k}$

The first surprise is that a short list can do astonishingly well, and the quality
of the approximation does **not** depend on how big the crowd is. It depends only on
how spread out the crowd is and on how long your list is.

Make the natural assumption that nobody stands further than a distance $R$ from the
origin: $\|V_i\| \le R$ for every person $i$. Then the classical theorem — known as
the *approximate Carathéodory theorem*, and originally proved by Maurey's
"empirical method" — guarantees that there is a list of $k$ names whose plain
average $y = \tfrac1k\sum_{j} V_{f(j)}$ satisfies

$$\left\| x - \tfrac1k \sum_{j} V_{f(j)} \right\|^2 \;\le\; \frac{R^2}{k}.$$

In words: the squared error shrinks like $1/k$, so the error itself shrinks like
$R/\sqrt{k}$. Want to halve your error? Quadruple your list. And — remarkably — a
crowd of a million and a crowd of a billion obey the *same* bound. This
"dimension-free" quality is exactly why the result is a workhorse in high-dimensional
data science, where the number of features can dwarf the number of samples.

The classical proof is a beautiful piece of probabilistic sleight of hand. Imagine
drawing each name on your list *at random*, person $i$ chosen with probability $p_i$,
independently $k$ times. The *expected* squared error of the resulting random
average works out to exactly $\tau/k$, where

$$\tau = \sum_i p_i \, \| V_i - x \|^2$$

is the **variance** of the crowd — the weighted average squared distance of people
from the balance point. Since $\tau \le R^2$, the average list has squared error at
most $R^2/k$. And if the *average* list is that good, then *some particular* list
must be at least that good. That last sentence — "some sample is no worse than its
expectation" — is the entire engine of the probabilistic method.

But notice what the argument does **not** do: it never tells you *which* list. It
proves a good list exists by averaging over all of them, the way one might prove
that some student scored above the class mean without naming the student. For a
mathematician that is a complete proof. For an engineer who has to *ship* a list,
it is an unfinished sentence.

## Finishing the sentence: a greedy rule you can run and check

The heart of this work is to replace the lucky existence proof with an explicit,
deterministic recipe — and, as a bonus, to prove a **sharper** bound along the way.

The recipe is the natural greedy one, a cousin of the Frank–Wolfe algorithm that
optimizers know well. Keep a running "error vector" $s$, the accumulated deviation
of your choices from the target. Start empty:

$$s_0 = 0.$$

At each step, look at every person $i$ and ask: *if I add this person to my list,
how big will my running error become?* Adding person $i$ changes the running vector
to $s + \mathrm{dev}(i)$, where $\mathrm{dev}(i) = V_i - x$ is that person's
deviation from the balance point. **Greedily pick the person who makes the new
running error smallest:**

$$\text{choose } i_t = \arg\min_i \, \| s_t + \mathrm{dev}(i) \|^2, \qquad
  s_{t+1} = s_t + \mathrm{dev}(i_t).$$

That arg-min is a finite search with a definite winner — no coin flips, no oracle.
After $k$ steps you have named $k$ people, and your list is locked in.

Why does this simple rule work, and work *provably*? The argument rests on one
elegant identity. Consider, at any moment, the *weighted average over the whole
crowd* of the squared running errors you could reach in one step. A short
calculation — the cross term vanishes precisely because the weighted deviations
cancel, $\sum_i p_i\,\mathrm{dev}(i) = 0$ — shows that this average is exactly

$$\sum_i p_i \, \| s + \mathrm{dev}(i) \|^2 \;=\; \|s\|^2 + \tau.$$

This is the **averaging identity**, and it is the deterministic shadow of the
probabilistic variance computation. Here is the punchline: the greedy player does
not settle for the average — they pick the *minimum*. Since the minimum is never
larger than the average, **one greedy step grows the squared error by at most the
variance $\tau$**:

$$\| s_{t+1} \|^2 \;\le\; \|s_t\|^2 + \tau.$$

Chain this inequality $k$ times — a one-line induction — and the running error
after $k$ steps is controlled:

$$\| s_k \|^2 \;\le\; k\,\tau.$$

Finally, unwind the bookkeeping. The running vector is just the sum of the chosen
deviations, $s_k = \big(\sum_{t<k} V_{i_t}\big) - k\,x$, so dividing by $k$ turns it
into exactly the gap between the target and your list's average. Therefore

$$\boxed{\;\left\| x - \tfrac1k \sum_{j} V_{i_j} \right\|^2 \;\le\; \frac{\tau}{k}
  \;\le\; \frac{R^2}{k}.\;}$$

Two victories in one line. First, the list is **explicit**: it is produced by a
finite, deterministic search you can run on a laptop and audit afterward. Second,
the bound is **sharper** than the classical $R^2/k$: it is $\tau/k$, and since

$$\tau = \Big(\sum_i p_i \|V_i\|^2\Big) - \|x\|^2 \;\le\; R^2,$$

the variance *subtracts the squared norm of the very point you are chasing*. A
target sitting far from the origin is, paradoxically, easier to pin down by this
measure. The closer the crowd hugs a sphere of radius $R$ and the further $x$
drifts from the center, the more the greedy bound beats the textbook one.

## A worked miniature

Let the "crowd" be the four corners of the unit square in the plane:
$V_1=(1,1)$, $V_2=(1,-1)$, $V_3=(-1,1)$, $V_4=(-1,-1)$, each with weight
$p_i = 1/4$. The balance point is the center $x=(0,0)$, and every corner sits at
distance $R=\sqrt2$ from the origin, so the classical promise for a list of length
$k=4$ is a squared error of at most $R^2/k = 2/4 = 0.5$.

The variance here is $\tau = \tfrac14\sum_i \|V_i\|^2 - 0 = 2$, so the sharp greedy
promise is $\tau/k = 2/4 = 0.5$ as well (the square is perfectly symmetric, so
$\|x\|^2=0$ and the two bounds coincide). But watch the greedy player at work: by
always cancelling the current running error, they pick one corner, then its
opposite, then a third, then *its* opposite — and after four steps the running
error is exactly zero. The realized squared error is $0$, far below the worst-case
$0.5$. The bound is a *guarantee*, not a prediction; on friendly, balanced data the
greedy rule does dramatically better than its own worst case, while still carrying
an iron-clad certificate.

## The bridge to carving up space

The same arithmetic that governs short lists also governs how engineers refine
meshes — and this is where the story takes its unexpected turn.

To simulate airflow over a wing or stress in a bridge, one tiles a region with a
mesh of simplices (triangles in 2D, tetrahedra in 3D). A *Delaunay refinement*
repeatedly inserts a new point — often the *minicenter*, the center of a simplex's
smallest enclosing ball — and re-triangulates, splitting big simplices into smaller
ones. The hope, long folklore in computational geometry, is that each round of
refinement shrinks the largest simplex *diameter* by a fixed factor $\lambda>1$.

If that per-step contraction holds, the consequences are completely rigid. Writing
$d_k$ for the maximum diameter after $k$ rounds, a one-line induction gives
exponential decay,

$$d_k \;\le\; \left(\tfrac1\lambda\right)^{k} d_0,$$

so the mesh fineness $d_k \to 0$, and for any target tolerance $\varepsilon$ there
is an explicit number of rounds after which every simplex is smaller than
$\varepsilon$. Even the *total work* is finite: summing the diameters over **all**
rounds gives a closed-form geometric budget,

$$\sum_{k=0}^{\infty} d_k \;\le\; \frac{d_0\,\lambda}{\lambda - 1}.$$

The one-dimensional case is not folklore but a theorem: the minicenter of an edge
$[a,b]$ is exactly its midpoint, splitting the edge into two halves each of length
$\mathrm{dist}(a,b)/2$. So edge bisection is an honest contraction process with the
sharp factor $\lambda = 2$ and diameters $d_k = D/2^k$ — a concrete witness that the
abstract decay law is not vacuous.

Where does approximate Carathéodory re-enter? In the *covering* guarantee. The
refinement is useful only if every point of the domain ends up close to a sample
vertex — the "covering radius" must vanish. The same averaging principle that
powers the greedy list shows that any domain point, being a convex combination of
nearby vertices, is within one current simplex of a short average of them. So the
covering radius is controlled by the simplex diameter, and inherits its exponential
decay and finite cumulative budget. The two halves of the story — the
$1/\sqrt{k}$ face of approximation and the $(1/\lambda)^k$ face of refinement — are
two views of a single principle: **structured refinement reduces error, predictably
and at a rate you can compute in advance.**

## Why it matters

Dimension-free approximation by short lists is everywhere modern computation is hard.
It is how recommendation engines summarize a million-feature user by a handful of
prototypes; how sparse approximation compresses signals; how Frank–Wolfe solvers
keep their iterates honest in optimization over convex sets. In every one of these
settings, the difference between "a good summary exists" and "here is the good
summary, and here is its certificate" is the difference between a theorem and a tool.

The greedy result turns the classic existence promise into exactly such a tool: a
deterministic, auditable rule with a bound that is never worse than the textbook
$R^2/k$ and often strictly better. And by tying it to the contraction of refined
meshes, it draws a clean line from a question about averaging a crowd to the
engineering of the grids on which we simulate the physical world. The crowd in the
hall, it turns out, can always be approximated by calling a few names — and you
never have to leave it to luck.
