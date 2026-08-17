"""Transversal-probe width certificate for rectified perception layers.

Given a rectified layer  x -> relu(W x + b)  with W an m-by-n real matrix, this
algorithm decides the structural criterion behind the exact width law: it builds
a probe direction transverse to every nonzero weight row, evaluates the active
unit sets far out along that direction and its opposite, and reports the two
active-set ranks.  If either rank is smaller than n, the layer is certified
LOSSY and an explicit collision pair of percepts is returned.  If both ranks
equal n the probe certificate is consistent with losslessness and, in
particular, m >= 2n is confirmed numerically.

Complexity: O(m n) to build the probe, O(m n^2) for the two Gaussian
eliminations, O(m n) per collision step; overall O(m n^2).
"""

from __future__ import annotations

from typing import List, Optional, Sequence, Tuple

Vec = List[float]
Mat = List[List[float]]


def transversal_probe(W: Mat, n: int, max_tries: int = 64) -> Vec:
    """Return u with <w_i, u> != 0 for every nonzero row w_i.

    Uses moment-curve (Vandermonde) points u(t) = (1, t, ..., t^{n-1}).  The
    inner product <w_i, u(t)> is the value at t of the polynomial with
    coefficients w_i, which is nonzero off a finite root set, so some t in a
    finite scan of distinct values always works.
    """
    t = 1.0
    for _ in range(max_tries):
        u = [t ** k for k in range(n)]
        ok = True
        for row in W:
            if any(abs(v) > 0.0 for v in row):
                if abs(sum(row[j] * u[j] for j in range(n))) <= 1e-12:
                    ok = False
                    break
        if ok:
            return u
        t += 0.37211
    raise RuntimeError("no transversal probe found in the scan range")


def far_field_scale(W: Mat, b: Sequence[float], u: Vec, n: int) -> float:
    """Smallest safe s with |b_i| < s |<w_i,u>| for every unit with <w_i,u> != 0."""
    best = 1.0
    for i, row in enumerate(W):
        d = sum(row[j] * u[j] for j in range(n))
        if abs(d) > 1e-12:
            best = max(best, 1.0 + abs(b[i]) / abs(d))
    return best


def active_set(W: Mat, b: Sequence[float], x: Vec) -> List[int]:
    """Indices of strictly active, input-dependent units at the percept x."""
    out: List[int] = []
    for i, row in enumerate(W):
        p = sum(row[j] * x[j] for j in range(len(x))) + b[i]
        if p > 0 and any(v != 0.0 for v in row):
            out.append(i)
    return out


def rank_and_kernel_vector(rows: Mat, n: int) -> Tuple[int, Optional[Vec]]:
    """Gaussian elimination: return (rank, kernel vector) with kernel None iff rank == n."""
    A = [row[:] for row in rows]
    pivot_cols: List[int] = []
    r = 0
    for c in range(n):
        piv = None
        for i in range(r, len(A)):
            if abs(A[i][c]) > 1e-10:
                piv = i
                break
        if piv is None:
            continue
        A[r], A[piv] = A[piv], A[r]
        scale = A[r][c]
        A[r] = [v / scale for v in A[r]]
        for i in range(len(A)):
            if i != r and abs(A[i][c]) > 1e-14:
                f = A[i][c]
                A[i] = [A[i][k] - f * A[r][k] for k in range(n)]
        pivot_cols.append(c)
        r += 1
        if r == len(A):
            break
    rank = r
    if rank == n:
        return rank, None
    free = next(c for c in range(n) if c not in pivot_cols)
    v = [0.0] * n
    v[free] = 1.0
    for i, c in enumerate(pivot_cols):
        v[c] = -A[i][free]
    return rank, v


def collision_from_kernel(W: Mat, b: Sequence[float], x: Vec, v: Vec) -> Tuple[Vec, Vec]:
    """Turn a kernel vector of the active rows at x into two colliding percepts."""
    n = len(x)
    worst = None
    for i, row in enumerate(W):
        p = sum(row[j] * x[j] for j in range(n)) + b[i]
        c = sum(row[j] * v[j] for j in range(n))
        if abs(c) > 1e-12 and p < 0:
            cand = -p / (1.0 + abs(c))
            worst = cand if worst is None else min(worst, cand)
    t = 1.0 if worst is None else max(min(worst, 1.0), 1e-9)
    return x, [x[j] + t * v[j] for j in range(n)]


def width_certificate(W: Mat, b: Sequence[float], n: int) -> dict:
    """Full certificate: probe, both active sets, both ranks, and any collision found."""
    u = transversal_probe(W, n)
    s = far_field_scale(W, b, u, n)
    xp = [s * t for t in u]
    xm = [-s * t for t in u]
    Ap, Am = active_set(W, b, xp), active_set(W, b, xm)
    rank_p, ker_p = rank_and_kernel_vector([W[i] for i in Ap], n)
    rank_m, ker_m = rank_and_kernel_vector([W[i] for i in Am], n)

    report = {
        "units": len(W),
        "input_dimension": n,
        "required_width": 2 * n,
        "probe_scale": s,
        "active_positive": Ap,
        "active_negative": Am,
        "rank_positive": rank_p,
        "rank_negative": rank_m,
        "disjoint": set(Ap).isdisjoint(set(Am)),
        "lossy_certificate": None,
        "verdict": "",
    }

    if rank_p < n:
        report["lossy_certificate"] = collision_from_kernel(W, b, xp, ker_p or [])
    elif rank_m < n:
        report["lossy_certificate"] = collision_from_kernel(W, b, xm, ker_m or [])

    if report["lossy_certificate"] is not None:
        report["verdict"] = "LOSSY: explicit colliding percept pair produced"
    elif len(W) < 2 * n:
        report["verdict"] = "LOSSY: width below the threshold 2n"
    else:
        report["verdict"] = "probe certificate passed: both half-probes have full rank"
    return report


if __name__ == "__main__":
    n = 11
    split: Mat = []
    for j in range(n):
        split.append([1.0 if k == j else 0.0 for k in range(n)])
    for j in range(n):
        split.append([-1.0 if k == j else 0.0 for k in range(n)])
    print("optimal 22-unit split layer:")
    rep = width_certificate(split, [0.0] * 22, n)
    for k, v in rep.items():
        print(f"  {k}: {v}")

    narrow = split[:21]
    print("\n21-unit layer (one negative detector removed):")
    rep = width_certificate(narrow, [0.0] * 21, n)
    for k, v in rep.items():
        print(f"  {k}: {v}")


"""Assemble PACKAGE.json from the deliverable files in this directory."""

from __future__ import annotations

import json
import pathlib

ROOT = pathlib.Path(__file__).parent
LEAN_DIR = ROOT / "Catalog" / "MachineLearning" / "HyperAwareness11D"
LEAN_ORDER = [
    "Injectivity.lean",
    "FrameBounds.lean",
    "Equivariance.lean",
    "SpectralPercept.lean",
    "BalancedFrame.lean",
    "DeepNetworks.lean",
    "LabNotes.lean",
]


def read(name: str) -> str:
    return (ROOT / name).read_text()


lean_files = [f"Catalog/MachineLearning/HyperAwareness11D/{f}" for f in LEAN_ORDER]
lean_proofs = "\n\n".join(
    f"-- FILE: Catalog/MachineLearning/HyperAwareness11D/{f}\n\n"
    + (LEAN_DIR / f).read_text()
    for f in LEAN_ORDER
)

future_directions = """# Future Directions — Hyper-Awareness: 11-dimensional perception architectures

Derived from the analysis and adversarial review of this cycle. Every conjecture below is
falsifiable, and each is stated so that a single theorem (or a single explicit counterexample)
settles it.

Recap of what is now proved:

* **Exact width law.** 22 is the least width of a lossless (injective) ReLU layer on R^11; in
  general the least width is 2n.
* **Metric law.** The optimal layer is a frame with sharp constants 1/2 and 1.
* **Rigidity at the optimum.** A 22-unit lossless layer splits into two balanced blocks of 11
  active units and has no inessential unit.
* **Symmetry obstruction.** Hyperoctahedral equivariance collapses an 11-dimensional layer to a
  single scalar parameter; permutation equivariance to two.
* **Parity dividend.** Every 11-dimensional linear layer has an invariant percept direction, and
  the dimension-2 rotation shows oddness is essential.

---

## Conjecture A — the bias-free optimum is *unique up to symmetry*

**Statement.** Let W be a 22 x 11 real matrix with zero bias such that x -> relu(Wx) is injective.
Then there is a permutation pi of the 22 units, positive scalars c_i > 0 and an invertible
A in GL_11(R) such that the rows satisfy w_{pi(i)} = c_i * (A e_i) for i < 11 and
w_{pi(i)} = -c_i * (A e_{i-11}) for i >= 11 — i.e. every optimal architecture is a reparametrised
positive/negative split.

**The key insight is** that the balanced-activation theorem already forces the 22 rows to split
into two blocks of 11 that are *mutually antipodal in sign pattern* across every transverse
direction, and a set of vectors whose sign patterns are exactly complementary on all of R^11 must
be an antipodal pair of bases.

**Why now?** The balanced-activation theorem proved in this cycle supplies precisely the
combinatorial input (two disjoint spanning blocks of size exactly 11) that was missing; the
remaining step is a sign-pattern classification, which is finite-dimensional linear algebra.

**Falsifier.** A single injective bias-free 22 x 11 layer whose rows are not of this form.

---

## Conjecture B — the width law is stable: 2n(1+eps) units buy conditioning 1/(1+eps)

**Statement.** For every m >= 22 there is an injective ReLU layer R^11 -> R^m whose frame
constants satisfy alpha >= 1/2 + c*(m - 22)/m for an absolute c > 0, and no injective layer of
width m has frame constant alpha > 1/2 + C*(m - 22)/m. In particular the optimal condition number
sqrt(2) at m = 22 improves *continuously* with excess width, not discontinuously.

**Falsifier.** Either an injective layer of width m whose lower frame constant exceeds the stated
upper envelope, or a proof that no width-m layer beats 1/2 by more than o((m-22)/m).

---

## Further programme

* **Approximate losslessness.** How many units are needed for a layer that is injective only on a
  delta-net of the percept sphere, or bi-Lipschitz with a prescribed constant? The exact-width
  argument is a rank argument at two probes and should degrade quantitatively.
* **Structured tensor percepts.** The order-k width law 2 * 11^k ignores the tensor factorisation.
  Does requiring the layer to respect the factorisation (a separable or low-rank weight structure)
  strictly increase the lossless width?
* **Equivariant optima.** What is the least width of a lossless layer that is additionally
  S_11-equivariant, or B_11-equivariant, as a *nonlinear* map? The rigidity theorem shows the
  linear part collapses, so the question is genuinely about the nonlinearity.
* **Leaky rectifiers.** With slope lambda in (0,1) the activation is injective at width n, so the
  threshold jumps from n to 2n exactly at lambda = 0. Quantifying the conditioning as lambda
  decreases to 0 interpolates between the two regimes and should identify the crossover width.
* **Invariant modes in practice.** Can the invariant percept direction guaranteed by oddness be
  located stably, and does it carry interpretable meaning in trained systems?
"""

interactive_layout = r"""
# Eleven Dimensions, Twenty-Two Neurons

*A guided tour of the exact price of seeing without loss.*

---

## 1. The question

Imagine a machine whose momentary experience is an eleven-channel reading: a **percept**
$x \in \mathbb{R}^{11}$. The first thing almost every neural architecture does with it is push it
through a layer of rectified units,

$$\Phi(x)_i \;=\; \mathrm{relu}\big(\langle w_i, x\rangle + b_i\big), \qquad
\mathrm{relu}(t) = \max(t,0).$$

That $\max(t,0)$ is a diode. A unit reports on one side of its hyperplane and says exactly nothing
on the other. So: **how many units must the layer have if no two distinct percepts may ever
produce the same response?**

Two tempting answers are both wrong. "Eleven, one per input number" ignores rectification — the
layer $x \mapsto (\mathrm{relu}(x_1),\dots,\mathrm{relu}(x_{11}))$ sends every all-negative percept
to the origin. "A few hundred, to be safe" never tells you where the boundary is. The true answer
is a sharp integer.

> **Twenty-two.** A rectified layer on $\mathbb{R}^{11}$ is lossless if and only if it has at least
> $22$ units, and $22$ suffice. In dimension $n$ the threshold is exactly $2n$.

---

## 2. Discover the threshold yourself

The widget below lives in the plane, where the threshold is $2n = 4$. Start with three units and
drag the black probe percept around. Watch the rank readout: whenever the firing rows fail to span
the plane, a dashed red line appears — a **blind direction**, a whole segment of percepts that the
layer maps to one and the same response. Then press *positive/negative split* and see the verdict
flip.

{{interactive_demo:0}}

<details>
<summary><b>Click to reveal the full proof of the lower bound</b></summary>

Three steps.

**Step 1 — a transverse probe.** There is a direction $u$ with $\langle w_i, u \rangle \neq 0$ for
every nonzero row. Attach to each nonzero row the polynomial $P_i(X) = \sum_j w_{ij}X^{j-1}$; it is
not the zero polynomial. The product $\prod_i P_i$ is therefore nonzero and has a non-root $t$, and
$u = (1, t, t^2, \dots, t^{n-1})$ works, since $\langle w_i, u\rangle = P_i(t)$. This is the moment
curve trick: one point on it is transverse to finitely many hyperplanes at once.

**Step 2 — active rows must span.** Let $x$ be a percept at which no input-dependent unit sits
exactly on its kink. If some nonzero $v$ satisfied $\langle w_i, v\rangle = 0$ for every firing unit
$i$, then for small $t>0$ the percept $x + tv$ produces an identical response: firing units do not
see $v$, and silent units are silent by a strict inequality, so a small enough step keeps them
silent. Injectivity forbids that, so the firing rows span $\mathbb{R}^n$ and there are at least $n$
of them.

**Step 3 — probe both ends.** Choose $s$ so large that $|b_i| < s|\langle w_i,u\rangle|$ for every
unit with $\langle w_i, u\rangle \neq 0$. At $x = su$ and $y = -su$ no unit is at a kink, so each
fires at least $n$ units; and the two firing sets are disjoint, since a unit firing at both would
force $|b_i| > s|\langle w_i,u\rangle|$. Hence the layer has at least $2n$ units. $\blacksquare$

The factor $2$ is exactly the cost of one-sidedness: a rectifier only ever sees half the world.
</details>

---

## 3. Twenty-two is enough — and the decoder is a subtraction

The matching construction is the most natural one imaginable. Give every channel two units, one
watching the positive side and one the negative:

$$\Phi^{\mathrm{split}}(x) \;=\; \big(\mathrm{relu}(x_1),\dots,\mathrm{relu}(x_{11}),\;
\mathrm{relu}(-x_1),\dots,\mathrm{relu}(-x_{11})\big).$$

Reconstruction is the identity $\mathrm{relu}(t) - \mathrm{relu}(-t) = t$: each channel is recovered
as (positive unit) minus (negative unit). Not merely invertible — invertible *linearly*.

And one unit below the optimum, failure is concrete. Drop the negative detector of channel eleven
and the percepts $(0,\dots,0,-1)$ and $(0,\dots,0,-2)$ become indistinguishable: every unit reads
zero at both.

{{demo:0}}

---

## 4. Losslessness is not enough — how much distance survives?

Injectivity is set-theoretic: it says distinct percepts differ somewhere, not that the difference is
*legible*. The engineering property is a two-sided bound. The optimal split layer satisfies, for all
percepts,

$$\tfrac12\|x-y\|^2 \;\le\; \|\Phi^{\mathrm{split}}(x)-\Phi^{\mathrm{split}}(y)\|^2 \;\le\;
\|x-y\|^2,$$

with **both constants attained**. It never amplifies a difference, and never damps one by more than
a factor $2$ in energy: the decoding condition number is exactly $\sqrt2$.

Drag the two percepts in the second panel of the lab above (Experiment 2). Put both in one quadrant
and the ratio locks to $1$ — there the layer is a perfect isometry. Press *make them antipodal* and
it drops to exactly $0.5$. **A sign flip is the worst thing that can happen to a rectified percept,
and it costs exactly one half.**

<details>
<summary><b>Why exactly one half? (a two-line argument)</b></summary>

Write $u = \mathrm{relu}(a) - \mathrm{relu}(b)$ and $v = \mathrm{relu}(-a)-\mathrm{relu}(-b)$ for a
single coordinate. The split identity gives $u - v = a - b$, and $(u-v)^2 \le 2(u^2+v^2)$ yields
$\tfrac{(a-b)^2}{2} \le u^2+v^2$: the lower bound. For the upper bound, if $a$ and $b$ have the same
sign one of $u,v$ vanishes and the other equals $\pm(a-b)$ (equality, ratio $1$); if they straddle
zero, say $a \le 0 \le b$, then $u^2+v^2 = a^2+b^2 \le a^2 - 2ab + b^2 = (a-b)^2$, the loss being
precisely the cross term $-2ab$. Summing over coordinates gives the frame bounds.
</details>

The picture below shows the whole landscape: the ratio along great circles of percept space, its
distribution over tens of thousands of random pairs, the width law itself, and the balanced
activation pattern we meet next.

{{visualization:0}}

---

## 5. At the optimum there is no slack anywhere

Here is the result that surprised us most, and it comes from pure counting.

> **Balanced activation.** If a lossless layer on $\mathbb{R}^n$ has *exactly* $2n$ units, then two
> percepts exist whose firing sets are disjoint, of size exactly $n$ each, and together exhaust
> every unit.

Why: each of the two far probes fires at least $n$ units, the sets are disjoint, and there are only
$2n$ units to go around — so both counts are pinned to exactly $n$, and their union is everything.
Nothing was assumed about the weights, yet the layer is *forced* into the signature of the canonical
positive/negative split: two perfectly balanced halves of eleven.

An immediate corollary: **every unit of a width-optimal lossless layer has a nonzero weight row.**
No dead units, no constant detectors, nothing to prune — and pruning is impossible anyway, since
$21 < 22$.

---

## 6. A certificate you can run

Given any layer, you can *decide* the criterion behind the width law: build the transverse probe,
walk far out both ways, and compute the rank of the firing rows. If a rank falls short, the kernel
vector converts directly into two explicit percepts with identical responses.

{{algorithm:0}}

---

## 7. Depth cannot save you

A tempting escape: use a narrow first layer, then a very deep and wide network downstream. It does
not work, and the proof is one line.

> If the first hidden layer of a network on $\mathbb{R}^{11}$ has fewer than $22$ rectified units,
> then the whole network — however deep, whatever the later layers compute — identifies two distinct
> percepts.

Because if $g \circ \Phi$ is injective then so is $\Phi$; and a sub-$22$-unit $\Phi$ is not.
Information destroyed at the sensory interface is destroyed forever. Conversely, width costs nothing
in depth: towers of optimal split layers stay lossless at every depth.

The **input interface is the only place in an architecture where width is non-negotiable.**

---

## 8. Higher-order percepts

An order-$k$ eleven-dimensional percept — a matrix of channel correlations, a cube of triple
interactions — lives in a space of dimension $11^k$. The width law applies verbatim, since it was
proved for every dimension:

$$\text{lossless width for order-}k \text{ percepts} \;=\; 2\cdot 11^k:
\qquad 22,\quad 242,\quad 2662,\ \dots$$

The overhead of losslessness is always a factor $2$ — reassuring. The base cost is $11^k$ —
sobering. Any practical order-$3$ architecture is necessarily lossy, and now you know exactly what
it is paying.

---

## 9. Two warnings about symmetry, and one gift from oddness

**Permutation equivariance** — demanding that relabelling the eleven channels commutes with the
layer — pins a linear layer to the two-parameter *Deep Sets* form
$$x \;\longmapsto\; a\,x + b\Big(\textstyle\sum_j x_j\Big)\mathbf 1,$$
with the pair $(a,b)$ unique. Adding **sign equivariance** (commuting with flips of individual
channels) forces every off-diagonal weight to vanish, leaving $x \mapsto a x$: one parameter, a
global gain control that cannot even swap two channels. The hierarchy $121 \to 2 \to 1$ is not
gradual; the last step annihilates cross-channel computation altogether.

**And a gift.** Eleven is odd, so the characteristic polynomial of any $11\times 11$ layer has odd
degree and therefore a real root. Hence:

> Every linear perception layer on $\mathbb{R}^{11}$ — with *no* hypothesis on its weights — has an
> invariant percept direction $v \ne 0$ with $Mv = av$; if the layer is injective, $a \ne 0$.

There is always a stable perceptual mode. Parity really is the reason: the planar quarter-turn
$\begin{pmatrix}0&-1\\1&0\end{pmatrix}$ has no invariant direction at all, since $Mv = av$ forces
$(1+a^2)v = 0$.

---

## 10. What to take away

| | |
|---|---|
| **Interface width** | exactly $22$ on $\mathbb{R}^{11}$; $2n$ in general |
| **Stability** | condition number exactly $\sqrt2$; antipodes are the worst case |
| **Rigidity** | two balanced blocks of $11$; every unit essential |
| **Depth** | cannot repair a narrow interface; is otherwise free |
| **Tensors** | $2\cdot 11^k$ units: $22$, $242$, $2662$ |
| **Symmetry** | $121 \to 2 \to 1$ parameters; full symmetry kills channel mixing |
| **Parity** | odd dimension guarantees an invariant percept direction |

Further reading on the surrounding ideas:
[rectifier networks](https://en.wikipedia.org/wiki/Rectifier_(neural_networks)),
[frames and stable reconstruction](https://en.wikipedia.org/wiki/Frame_(linear_algebra)),
[equivariant maps](https://en.wikipedia.org/wiki/Equivariant_map),
[the hyperoctahedral group](https://en.wikipedia.org/wiki/Hyperoctahedral_group),
[eigenvalues of odd-dimensional real matrices](https://en.wikipedia.org/wiki/Eigenvalues_and_eigenvectors).

None of this depends on data, optimisation, or architecture search. It is a statement about what a
diode can transmit, sharpened until the answer is an integer: **$22$, because a rectifier sees only
half the world at a time.**
"""

package = {
    "title": "Lossless Rectified Perception in Eleven Dimensions: Exact Width, Sharp Frame "
             "Bounds, and Rigidity at the Optimum",
    "domain": "MachineLearning",
    "description": "A rectified-linear perception layer processes an 11-dimensional percept "
                   "without any information loss if and only if it has at least 22 units, and the "
                   "optimum is rigid: it is a frame with sharp constants 1/2 and 1, it splits into "
                   "two perfectly balanced blocks of 11 active units, every unit is essential, and "
                   "no amount of downstream depth can repair a narrower interface.",
    "authors": ["Aristotle"],
    "date": "2026-08-17",
    "key_results": [
        "Exact width law: a lossless (injective) rectified layer on an n-dimensional percept space "
        "needs at least 2n units and 2n units suffice; in dimension 11 the least lossless width is "
        "exactly 22.",
        "The optimal positive/negative split layer admits a linear decoder and is a frame with "
        "sharp constants 1/2 and 1, so the percept is recovered with condition number exactly "
        "sqrt(2), antipodal percepts being the unique worst case.",
        "Rigidity at the optimum: a lossless layer of width exactly 2n has two percepts whose "
        "active-unit sets partition the units into two blocks of exactly n, and consequently every "
        "unit has a nonzero weight row — no dead units and no prunable redundancy.",
        "Depth cannot repair a narrow sensory interface: any network whose first rectified layer "
        "has fewer than 22 units on an 11-dimensional percept identifies two distinct percepts, "
        "whatever the later layers compute, while towers of optimal split layers remain lossless.",
        "Order-k eleven-dimensional tensor percepts require exactly 2 * 11^k units — 22, 242 and "
        "2662 for orders 1, 2 and 3 — and hyperoctahedral equivariance collapses an 11-dimensional "
        "linear layer to a single scalar parameter, while oddness of 11 guarantees every linear "
        "layer an invariant percept direction.",
    ],
    "keywords": [
        "ReLU", "injective neural layer", "frame bounds", "width lower bound",
        "piecewise linear", "equivariance", "Deep Sets", "tensor percepts",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "End-to-End Numerical Verification of the Eleven-Dimensional Width Law",
            "description": "A self-contained suite of eight numerical experiments covering every "
                           "result. It verifies exact linear reconstruction through the 22-unit "
                           "split encoder on thousands of random percepts; exhibits, in exact "
                           "rational arithmetic, two distinct percepts that a 21-unit layer maps "
                           "to the same response; measures the expansion ratio "
                           "||Phi(x)-Phi(y)||^2/||x-y||^2 both exactly on structured pairs (giving "
                           "1/2, 1 and 61/102) and statistically over 20000 random pairs, "
                           "confirming the certified band [1/2, 1]; displays the balanced "
                           "partition of the 22 units into two disjoint blocks of 11 at a percept "
                           "and its antipode, together with the degeneracy that occurs at "
                           "non-transverse probes; shows that a 441-dimensional quadratic head "
                           "cannot separate percepts merged by a narrow interface while stacked "
                           "split layers reconstruct exactly; tabulates the tensor widths "
                           "2 * 11^k; checks the Deep Sets and scalar forms of equivariant layers; "
                           "and locates a real eigenvalue of a random 11 x 11 layer by bisection "
                           "on its characteristic polynomial while confirming that the planar "
                           "quarter-turn has none.",
            "code": read("demo.py"),
        }
    ],
    "algorithms": [
        {
            "name": "Transversal-Probe Width Certificate with Explicit Collision Extraction",
            "description": "Decides the structural criterion behind the exact width law for an "
                           "arbitrary rectified layer x -> relu(Wx + b) with W of shape m x n, and "
                           "returns a machine-checkable certificate. The algorithm first builds a "
                           "probe direction transverse to every nonzero weight row by scanning "
                           "moment-curve points u(t) = (1, t, ..., t^{n-1}): the inner product "
                           "<w_i, u(t)> is the value at t of the polynomial whose coefficients are "
                           "the row, hence nonzero off a finite root set. It then chooses a "
                           "far-field scale s exceeding max_i |b_i| / |<w_i,u>| so that the linear "
                           "term dominates every bias, and evaluates the active (strictly firing, "
                           "input-dependent) unit sets at the antipodal probes +su and -su. Each "
                           "active set is reduced by Gaussian elimination. Full rank n at both "
                           "probes is exactly the condition the width theorem shows must hold for "
                           "a lossless layer, and forces m >= 2n because the two active sets are "
                           "disjoint. If a rank falls short, the elimination returns a kernel "
                           "vector v of the firing rows, and a step size t is computed so that "
                           "every silent unit stays silent along x -> x + tv; the pair (x, x + tv) "
                           "is then an explicit certificate of information loss. Complexity: O(mn) "
                           "to build the probe and scale, O(m n^2) for the two eliminations, O(mn) "
                           "for the collision step, giving O(m n^2) overall with O(mn) memory.",
            "pseudocode": """INPUT : weight matrix W (m x n), bias vector b (length m), dimension n
OUTPUT: verdict, active sets, ranks, and (if lossy) a colliding percept pair

 1  # Stage 1: transversal probe via the moment curve
 2  t <- 1.0
 3  repeat
 4      u <- (1, t, t^2, ..., t^{n-1})
 5      if  |<w_i, u>| > eps  for every row w_i with w_i != 0  then break
 6      t <- t + delta                      # delta an irrational-looking increment
 7  until scan exhausted
 8
 9  # Stage 2: far-field scale so the linear term dominates every bias
10  s <- 1
11  for i = 1..m with <w_i,u> != 0:
12      s <- max(s, 1 + |b_i| / |<w_i,u>|)
13
14  # Stage 3: active sets at the antipodal probes
15  x_plus  <-  s * u ;   x_minus <- -s * u
16  A_plus  <- { i : <w_i, x_plus>  + b_i > 0  and  w_i != 0 }
17  A_minus <- { i : <w_i, x_minus> + b_i > 0  and  w_i != 0 }
18  assert A_plus and A_minus are disjoint          # guaranteed by the choice of s
19
20  # Stage 4: rank test by Gaussian elimination
21  (r_plus , k_plus ) <- RankAndKernel({ w_i : i in A_plus  }, n)
22  (r_minus, k_minus) <- RankAndKernel({ w_i : i in A_minus }, n)
23
24  # Stage 5: verdict and certificate
25  if r_plus < n then
26      (x, y) <- CollisionStep(W, b, x_plus,  k_plus )
27      return LOSSY with witness (x, y)
28  if r_minus < n then
29      (x, y) <- CollisionStep(W, b, x_minus, k_minus)
30      return LOSSY with witness (x, y)
31  if m < 2n then return LOSSY (width below the threshold 2n)
32  return CERTIFICATE PASSED: |A_plus| >= n, |A_minus| >= n, disjoint, so m >= 2n
33
34  procedure CollisionStep(W, b, x, v):
35      t <- min over silent units i with <w_i,v> != 0 of  (-p_i(x)) / (1 + |<w_i,v>|)
36      return (x, x + t*v)      # every firing unit ignores v; every silent unit stays silent""",
            "code": read("algo_width_certificate.py"),
        }
    ],
    "visualizations": [
        {
            "name": "The Frame Landscape of the Optimal Split Encoder",
            "description": "A four-panel figure. Panel (a) traces the expansion ratio "
                           "||Phi(x)-Phi(y)||^2 / ||x-y||^2 of the optimal 22-unit encoder along "
                           "great circles of the eleven-dimensional percept sphere, showing every "
                           "curve confined between the sharp bounds 1 and 1/2 and touching 1/2 "
                           "exactly at the antipodal angle pi. Panel (b) histograms the same ratio "
                           "over 40000 random percept pairs, empirically confirming the certified "
                           "band. Panel (c) plots the exact width law: minimal lossless width 2n "
                           "against input dimension, with the naive guess n shown as a dotted "
                           "line, the infeasible region between them shaded, and the "
                           "eleven-dimensional point (11, 22) highlighted. Panel (d) tracks the "
                           "number of strictly active units at a percept and at its antipode along "
                           "a rotating family of percepts, showing both counts pinned at 11 and "
                           "their union at 22 while the internal composition of each block varies "
                           "— the balanced-activation theorem in motion.",
            "code": read("viz_frame_landscape.py"),
        }
    ],
    "interactive_demos": [
        {
            "title": "The Rectified Perception Lab: Blind Directions and the Frame Gauge",
            "description": "Two linked hands-on experiments in the plane, where the width "
                           "threshold is 2n = 4 and everything is visible. In the first, the "
                           "reader chooses how many rectified units the layer has and where their "
                           "weight rows point, then drags a probe percept through the disc. "
                           "Firing units light up green with their half-planes shaded, and the "
                           "panel runs the two-probe rank test live: whenever the firing rows fail "
                           "to span the plane, a dashed red blind direction is drawn — an entire "
                           "segment of percepts collapsed to a single response — and the verdict "
                           "flips to LOSSY. Pressing the positive/negative split preset restores "
                           "losslessness with exactly four units, making the theorem tangible. In "
                           "the second experiment the reader drags two percepts through the split "
                           "encoder and watches a gauge display the expansion ratio: it locks to 1 "
                           "when both percepts share an orthant (the layer is an isometry there) "
                           "and falls to exactly 0.5 when they are antipodal, never leaving the "
                           "certified band. Live readouts show both encodings and the exact linear "
                           "decoding by subtraction. Progressive-disclosure panels reveal the full "
                           "three-step lower-bound proof, the two-line reason the frame constant "
                           "is exactly one half, and the rigidity theorem for width-optimal "
                           "layers.",
            "html": read("widget.html"),
        }
    ],
    "interactive_layout": interactive_layout,
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {
        "demo": read("demo.py"),
        "algo_width_certificate": read("algo_width_certificate.py"),
        "viz_frame_landscape": read("viz_frame_landscape.py"),
    },
    "lean_files": lean_files,
}

(ROOT / "PACKAGE.json").write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n")
print("wrote PACKAGE.json",
      f"({(ROOT / 'PACKAGE.json').stat().st_size / 1024:.1f} KiB)")


"""
Lossless rectified perception in eleven dimensions: numerical demonstrations.

This self-contained script demonstrates, numerically and in exact rational
arithmetic where it matters, the main results about rectified-linear ("ReLU")
perception layers acting on an n-dimensional percept space:

  1. WIDTH LAW.  A layer  x -> relu(W x + b)  on R^n that is injective must have
     at least 2n units, and 2n units suffice (positive/negative split layer).
     For n = 11 the exact threshold is 22.
  2. EXPLICIT FAILURE BELOW THE THRESHOLD.  A 21-unit layer on R^11 collides on
     two explicit distinct percepts.
  3. SHARP FRAME BOUNDS.  The optimal split layer satisfies
        (1/2)|x-y|^2 <= |Phi(x)-Phi(y)|^2 <= |x-y|^2,
     with both constants attained (antipodal percepts give exactly 1/2).
  4. BALANCED ACTIVATION AT THE OPTIMUM.  At a generic percept and its antipode
     the active units of a width-optimal lossless layer split into two disjoint
     blocks of exactly n units each covering every unit.
  5. DEPTH DOES NOT HELP.  A narrow first layer destroys information that no
     downstream map can recover; towers of split layers stay lossless.
  6. EQUIVARIANCE COSTS.  Permutation-equivariant linear layers have exactly two
     parameters; adding sign equivariance leaves exactly one (a scalar).
  7. PARITY DIVIDEND.  Every real 11 x 11 matrix has a real eigenvector; the
     planar quarter-turn has none.

Only the Python standard library is required (fractions, itertools, math,
random). Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from itertools import product
from typing import Callable, List, Sequence, Tuple

Vec = List[float]
Mat = List[List[float]]
QVec = List[Fraction]
QMat = List[List[Fraction]]


# ----------------------------------------------------------------------------
# Basic layer machinery
# ----------------------------------------------------------------------------

def relu(t: float) -> float:
    """The rectifier max(t, 0)."""
    return t if t > 0 else 0.0


def relu_q(t: Fraction) -> Fraction:
    """Exact rational rectifier."""
    return t if t > 0 else Fraction(0)


def pre_activation(W: Mat, b: Vec, x: Vec) -> Vec:
    """Pre-activations p_i(x) = <w_i, x> + b_i."""
    return [sum(W[i][j] * x[j] for j in range(len(x))) + b[i] for i in range(len(W))]


def relu_layer(W: Mat, b: Vec, x: Vec) -> Vec:
    """A single rectified layer Phi(x)_i = relu(<w_i, x> + b_i)."""
    return [relu(p) for p in pre_activation(W, b, x)]


def split_weights(n: int) -> Tuple[Mat, Vec]:
    """The optimal 2n-unit positive/negative split layer on R^n (zero bias).

    Rows 0..n-1 are +e_j, rows n..2n-1 are -e_j.
    """
    W: Mat = []
    for j in range(n):
        W.append([1.0 if k == j else 0.0 for k in range(n)])
    for j in range(n):
        W.append([-1.0 if k == j else 0.0 for k in range(n)])
    return W, [0.0] * (2 * n)


def split_decode(y: Vec, n: int) -> Vec:
    """Linear left inverse of the split layer: x_j = y_j - y_{n+j}."""
    return [y[j] - y[n + j] for j in range(n)]


def active_rows(W: Mat, b: Vec, x: Vec) -> List[int]:
    """Indices of strictly active, input-dependent units at the percept x."""
    p = pre_activation(W, b, x)
    return [i for i in range(len(W)) if p[i] > 0 and any(v != 0.0 for v in W[i])]


def sqdist(u: Sequence[float], v: Sequence[float]) -> float:
    return sum((a - c) ** 2 for a, c in zip(u, v))


# ----------------------------------------------------------------------------
# 1. The width law and exact reconstruction
# ----------------------------------------------------------------------------

def demo_width_law(n: int = 11, trials: int = 2000, seed: int = 20260817) -> None:
    print("=" * 78)
    print(f"1. WIDTH LAW: lossless width on R^{n} is exactly 2n = {2 * n}")
    print("=" * 78)

    W, b = split_weights(n)
    rng = random.Random(seed)
    worst = 0.0
    for _ in range(trials):
        x = [rng.uniform(-5.0, 5.0) for _ in range(n)]
        y = relu_layer(W, b, x)
        xr = split_decode(y, n)
        worst = max(worst, max(abs(a - c) for a, c in zip(x, xr)))
    print(f"   split layer width                 : {len(W)}")
    print(f"   worst reconstruction error / {trials} random percepts : {worst:.3e}")
    print("   reconstruction is LINEAR: x_j = (positive unit) - (negative unit)")
    print(f"   conclusion: {2 * n} units are sufficient, with a linear decoder.\n")


# ----------------------------------------------------------------------------
# 2. Explicit collision one unit below the optimum
# ----------------------------------------------------------------------------

def narrow_layer_21() -> Tuple[QMat, QVec]:
    """11 positive detectors + only 10 negative detectors: 21 units on R^11."""
    n = 11
    W: QMat = []
    for j in range(n):
        W.append([Fraction(1) if k == j else Fraction(0) for k in range(n)])
    for j in range(n - 1):  # negative detector of channel 10 is MISSING
        W.append([Fraction(-1) if k == j else Fraction(0) for k in range(n)])
    return W, [Fraction(0)] * 21


def q_layer(W: QMat, b: QVec, x: QVec) -> QVec:
    return [relu_q(sum(W[i][j] * x[j] for j in range(len(x))) + b[i]) for i in range(len(W))]


def demo_collision_below_threshold() -> None:
    print("=" * 78)
    print("2. BELOW THE THRESHOLD: a 21-unit layer on R^11 is provably lossy")
    print("=" * 78)

    W, b = narrow_layer_21()
    xA: QVec = [Fraction(-1) if j == 10 else Fraction(0) for j in range(11)]
    xB: QVec = [Fraction(-2) if j == 10 else Fraction(0) for j in range(11)]
    yA, yB = q_layer(W, b, xA), q_layer(W, b, xB)

    print(f"   x_A = (0,...,0,-1),  x_B = (0,...,0,-2)   distinct: {xA != xB}")
    print(f"   layer(x_A) == layer(x_B)                : {yA == yB}")
    print(f"   both responses are the zero vector      : {all(v == 0 for v in yA)}")
    print("   one missing negative detector = one blind direction.\n")


# ----------------------------------------------------------------------------
# 3. Sharp frame bounds for the optimal layer
# ----------------------------------------------------------------------------

def expansion_ratio_q(x: QVec, y: QVec) -> Fraction:
    """Exact squared expansion ratio |Phi(x)-Phi(y)|^2 / |x-y|^2 for the split layer."""
    n = len(x)
    W: QMat = []
    for j in range(n):
        W.append([Fraction(1) if k == j else Fraction(0) for k in range(n)])
    for j in range(n):
        W.append([Fraction(-1) if k == j else Fraction(0) for k in range(n)])
    b = [Fraction(0)] * (2 * n)
    px, py = q_layer(W, b, x), q_layer(W, b, y)
    num = sum((a - c) ** 2 for a, c in zip(px, py))
    den = sum((a - c) ** 2 for a, c in zip(x, y))
    return Fraction(num, 1) / den


def demo_frame_bounds(n: int = 11, trials: int = 20000, seed: int = 4711) -> None:
    print("=" * 78)
    print("3. FRAME BOUNDS: 1/2 <= |Phi(x)-Phi(y)|^2 / |x-y|^2 <= 1, both sharp")
    print("=" * 78)

    e0: QVec = [Fraction(1) if j == 0 else Fraction(0) for j in range(11)]
    zero: QVec = [Fraction(0)] * 11
    v1: QVec = [Fraction(j - 5) for j in range(11)]
    v2: QVec = [Fraction((j - 3) * (-1) ** j) for j in range(11)]

    exact_pairs = [
        ("(e0, -e0)   antipodal", e0, [-t for t in e0]),
        ("(e0, 0)     vs origin", e0, zero),
        ("(v1, v2)    generic  ", v1, v2),
        ("(v1, -v1)   antipodal", v1, [-t for t in v1]),
        ("(v2, 0)     vs origin", v2, zero),
    ]
    print("   exact rational expansion ratios:")
    for name, a, c in exact_pairs:
        r = expansion_ratio_q(a, c)
        print(f"     {name} : {str(r):>8}  = {float(r):.6f}")

    W, b = split_weights(n)
    rng = random.Random(seed)
    lo, hi = math.inf, -math.inf
    for _ in range(trials):
        x = [rng.uniform(-3.0, 3.0) for _ in range(n)]
        y = [rng.uniform(-3.0, 3.0) for _ in range(n)]
        d = sqdist(x, y)
        if d == 0.0:
            continue
        r = sqdist(relu_layer(W, b, x), relu_layer(W, b, y)) / d
        lo, hi = min(lo, r), max(hi, r)
    print(f"   over {trials} random pairs: min ratio {lo:.6f}, max ratio {hi:.6f}")
    print(f"   theory: min 0.5 (antipodes), max 1.0; condition number sqrt(2) = "
          f"{math.sqrt(2):.6f}\n")


# ----------------------------------------------------------------------------
# 4. Balanced activation and essentiality at the optimum
# ----------------------------------------------------------------------------

def demo_balanced_activation(n: int = 11) -> None:
    print("=" * 78)
    print("4. RIGIDITY AT THE OPTIMUM: two balanced blocks of exactly n units")
    print("=" * 78)

    W, b = split_weights(n)
    x = [float(j + 1) for j in range(n)]           # strictly positive percept
    y = [-t for t in x]                            # its antipode
    A, B = active_rows(W, b, x), active_rows(W, b, y)

    print(f"   percept x = {x}")
    print(f"   |A(x)| = {len(A)}, |A(-x)| = {len(B)}")
    print(f"   disjoint      : {set(A).isdisjoint(set(B))}")
    print(f"   cover all {2 * n} units: {sorted(A + B) == list(range(2 * n))}")
    print(f"   A(x)  = positive block {A}")
    print(f"   A(-x) = negative block {B}")

    nonzero_rows = all(any(v != 0.0 for v in row) for row in W)
    print(f"   every unit has a nonzero weight row (no dead units): {nonzero_rows}")

    degenerate = [0.0] + [float(j) for j in range(1, n)]  # one vanishing coordinate
    Ad = active_rows(W, b, degenerate)
    Bd = active_rows(W, b, [-t for t in degenerate])
    print(f"   non-transverse probe (one zero coordinate): |A| = {len(Ad)}, "
          f"|A(-)| = {len(Bd)}  -> balance needs generic probes\n")


# ----------------------------------------------------------------------------
# 5. Depth cannot repair a narrow interface
# ----------------------------------------------------------------------------

def demo_depth(n: int = 11) -> None:
    print("=" * 78)
    print("5. DEPTH: a narrow first layer is fatal; wide first layers stack freely")
    print("=" * 78)

    Wn, bn = narrow_layer_21()
    xA: QVec = [Fraction(-1) if j == 10 else Fraction(0) for j in range(11)]
    xB: QVec = [Fraction(-2) if j == 10 else Fraction(0) for j in range(11)]

    def downstream(v: QVec) -> Tuple[Fraction, ...]:
        """An arbitrary (here: wildly expressive) map applied after the first layer."""
        out: List[Fraction] = []
        for i in range(len(v)):
            for j in range(len(v)):
                out.append(v[i] * v[j] + 3 * v[i] - v[j])
        return tuple(out)

    gA = downstream(q_layer(Wn, bn, xA))
    gB = downstream(q_layer(Wn, bn, xB))
    print(f"   21-unit interface, then a 441-dimensional quadratic head:")
    print(f"     outputs still identical on x_A != x_B : {gA == gB}")
    print("     no downstream map can separate what the interface merged.")

    # A tower of optimal split layers stays lossless.
    W1, b1 = split_weights(n)
    W2, b2 = split_weights(2 * n)
    rng = random.Random(99)
    worst = 0.0
    for _ in range(500):
        x = [rng.uniform(-4.0, 4.0) for _ in range(n)]
        h1 = relu_layer(W1, b1, x)
        h2 = relu_layer(W2, b2, h1)
        rec = split_decode(split_decode(h2, 2 * n), n)
        worst = max(worst, max(abs(a - c) for a, c in zip(x, rec)))
    print(f"   two stacked split layers R^{n} -> R^{2*n} -> R^{4*n}: "
          f"worst reconstruction error {worst:.3e}\n")


# ----------------------------------------------------------------------------
# 6. Tensor percepts
# ----------------------------------------------------------------------------

def demo_tensor_widths(max_order: int = 4) -> None:
    print("=" * 78)
    print("6. ORDER-k TENSOR PERCEPTS: exact lossless width is 2 * 11^k")
    print("=" * 78)
    for k in range(1, max_order + 1):
        dim = 11 ** k
        print(f"   order k = {k}: percept dimension {dim:>6}, lossless width {2 * dim:>7}")
    print()


# ----------------------------------------------------------------------------
# 7. Equivariance costs
# ----------------------------------------------------------------------------

def is_perm_equivariant(M: Mat, tol: float = 1e-12) -> bool:
    """Check M_{sigma(i)sigma(j)} = M_{ij} by testing the two-parameter form."""
    n = len(M)
    a, b = M[0][0], M[0][1]
    for i, j in product(range(n), repeat=2):
        target = a if i == j else b
        if abs(M[i][j] - target) > tol:
            return False
    return True


def is_sign_equivariant(M: Mat, tol: float = 1e-12) -> bool:
    """Sign equivariance <=> all off-diagonal entries vanish."""
    n = len(M)
    return all(abs(M[i][j]) <= tol for i in range(n) for j in range(n) if i != j)


def demo_equivariance(n: int = 11) -> None:
    print("=" * 78)
    print("7. THE COST OF SYMMETRY: 121 -> 2 -> 1 parameters")
    print("=" * 78)

    a, b = 1.7, -0.4
    M = [[a if i == j else b for j in range(n)] for i in range(n)]
    print(f"   Deep Sets layer with (a, b) = ({a}, {b})")
    print(f"     permutation equivariant : {is_perm_equivariant(M)}")
    print(f"     sign equivariant        : {is_sign_equivariant(M)}")

    x = [float(j) - 4.0 for j in range(n)]
    direct = [sum(M[i][j] * x[j] for j in range(n)) for i in range(n)]
    formula = [(a - b) * x[i] + b * sum(x) for i in range(n)]
    err = max(abs(u - v) for u, v in zip(direct, formula))
    print(f"     matches  x -> (a-b)x + b*sum(x):  max error {err:.3e}")

    S = [[2.5 if i == j else 0.0 for j in range(n)] for i in range(n)]
    print(f"   scalar layer 2.5*I: perm equivariant {is_perm_equivariant(S)}, "
          f"sign equivariant {is_sign_equivariant(S)}")

    # A channel swap is permutation-equivariant-incompatible under full symmetry.
    swap = [[1.0 if (i, j) in {(0, 1), (1, 0)} or (i == j and i > 1) else 0.0
             for j in range(n)] for i in range(n)]
    print(f"   channel-swap layer: perm equivariant {is_perm_equivariant(swap)}, "
          f"sign equivariant {is_sign_equivariant(swap)}")
    print("   => no hyperoctahedral-equivariant linear layer can swap two channels.")
    print("   parameter counts: unconstrained 121, permutation-equivariant 2, "
          "hyperoctahedral 1\n")


# ----------------------------------------------------------------------------
# 8. The parity dividend
# ----------------------------------------------------------------------------

def char_poly_coeffs(M: Mat) -> List[float]:
    """Coefficients of det(lambda I - M), ascending, via the Faddeev-LeVerrier method."""
    n = len(M)
    identity: Mat = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]

    def matmul(A: Mat, B: Mat) -> Mat:
        return [[sum(A[i][k] * B[k][j] for k in range(n)) for j in range(n)] for i in range(n)]

    def trace(A: Mat) -> float:
        return sum(A[i][i] for i in range(n))

    coeffs = [1.0]  # coefficient of lambda^n
    Mk: Mat = [row[:] for row in identity]
    for k in range(1, n + 1):
        Mk = matmul(M, Mk)
        c = -trace(Mk) / k
        coeffs.append(c)
        for i in range(n):
            Mk[i][i] += c
    return list(reversed(coeffs))  # ascending order


def poly_eval(coeffs: Sequence[float], t: float) -> float:
    return sum(c * t ** i for i, c in enumerate(coeffs))


def find_real_root(coeffs: Sequence[float]) -> float:
    """Bisection for a real root of an odd-degree monic polynomial (guaranteed to exist)."""
    lo, hi = -1.0, 1.0
    while poly_eval(coeffs, lo) > 0:
        lo *= 2.0
    while poly_eval(coeffs, hi) < 0:
        hi *= 2.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if poly_eval(coeffs, mid) < 0:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


def demo_parity(n: int = 11, seed: int = 2718) -> None:
    print("=" * 78)
    print("8. PARITY DIVIDEND: every linear layer on R^11 has an invariant direction")
    print("=" * 78)

    rng = random.Random(seed)
    M = [[rng.uniform(-1.0, 1.0) for _ in range(n)] for _ in range(n)]
    coeffs = char_poly_coeffs(M)
    root = find_real_root(coeffs)
    print(f"   random 11x11 layer: characteristic polynomial has odd degree {n}")
    print(f"   real eigenvalue found by bisection: a = {root:.10f}")
    print(f"   residual |chi(a)| = {abs(poly_eval(coeffs, root)):.3e}")

    rot = [[0.0, -1.0], [1.0, 0.0]]
    rot_coeffs = char_poly_coeffs(rot)  # 1 + lambda^2
    print(f"   planar quarter-turn: chi(lambda) = "
          f"{rot_coeffs[0]:.0f} + {rot_coeffs[2]:.0f}*lambda^2, no real root")
    print("   => in even dimension there need be no invariant percept direction.\n")


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("LOSSLESS RECTIFIED PERCEPTION IN ELEVEN DIMENSIONS")
    print("numerical demonstrations of the exact width law and its consequences")
    print()
    demo_width_law()
    demo_collision_below_threshold()
    demo_frame_bounds()
    demo_balanced_activation()
    demo_depth()
    demo_tensor_widths()
    demo_equivariance()
    demo_parity()
    print("=" * 78)
    print("All demonstrations agree with the theory:")
    print("  exact lossless width on R^11 is 22; frame bounds 1/2 and 1 are sharp;")
    print("  the optimum is balanced and irreducible; depth cannot repair a narrow")
    print("  interface; order-k tensor percepts cost exactly 2 * 11^k units.")
    print("=" * 78)


if __name__ == "__main__":
    main()


"""Visualisation: the frame landscape of the optimal split encoder.

Produces a four-panel figure.

  (a) Expansion ratio |Phi(x)-Phi(y)|^2 / |x-y|^2 for the split encoder as a
      function of the angle between the two percepts on a sphere of fixed
      radius: the ratio decreases monotonically from 1 to the sharp minimum 1/2
      exactly at the antipodal angle pi.
  (b) Histogram of the same ratio over random percept pairs in R^11, confined
      to the certified band [1/2, 1].
  (c) The exact width law: minimal lossless width 2n against input dimension n,
      with the eleven-dimensional point (11, 22) highlighted, and the infeasible
      region n <= width < 2n shaded.
  (d) Balanced activation: number of active units of the 22-unit split layer at
      a percept and at its antipode, along a rotating family of percepts.

Requires numpy and matplotlib.  Saves 'frame_landscape.png'.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def split_encode(x: np.ndarray) -> np.ndarray:
    """Optimal 2n-unit positive/negative split encoder."""
    return np.concatenate([np.maximum(x, 0.0), np.maximum(-x, 0.0)])


def ratio(x: np.ndarray, y: np.ndarray) -> float:
    num = float(np.sum((split_encode(x) - split_encode(y)) ** 2))
    den = float(np.sum((x - y) ** 2))
    return num / den


def main() -> None:
    rng = np.random.default_rng(11_022)
    n = 11

    fig, axes = plt.subplots(2, 2, figsize=(13, 9))
    fig.suptitle("Lossless rectified perception in eleven dimensions",
                 fontsize=15, fontweight="bold")

    # (a) ratio versus angle -------------------------------------------------
    ax = axes[0, 0]
    base = rng.normal(size=n)
    base /= np.linalg.norm(base)
    perp = rng.normal(size=n)
    perp -= perp @ base * base
    perp /= np.linalg.norm(perp)
    angles = np.linspace(0.02, np.pi, 400)
    curves = []
    for _ in range(12):
        b = rng.normal(size=n)
        b /= np.linalg.norm(b)
        p = rng.normal(size=n)
        p -= p @ b * b
        p /= np.linalg.norm(p)
        curves.append([ratio(b, np.cos(t) * b + np.sin(t) * p) for t in angles])
    for c in curves:
        ax.plot(angles, c, color="#3b6ea5", alpha=0.35, lw=1.2)
    ax.plot(angles, [ratio(base, np.cos(t) * base + np.sin(t) * perp) for t in angles],
            color="#12355b", lw=2.4, label="one great circle")
    ax.axhline(0.5, color="#c1121f", ls="--", lw=1.6, label="sharp lower bound 1/2")
    ax.axhline(1.0, color="#2a9d8f", ls="--", lw=1.6, label="sharp upper bound 1")
    ax.set_xlabel("angle between percepts (radians)")
    ax.set_ylabel(r"$\|\Phi(x)-\Phi(y)\|^2 / \|x-y\|^2$")
    ax.set_title("(a) expansion ratio along great circles")
    ax.set_ylim(0.4, 1.08)
    ax.legend(fontsize=8, loc="lower left")
    ax.grid(alpha=0.25)

    # (b) histogram over random pairs ---------------------------------------
    ax = axes[0, 1]
    vals = []
    for _ in range(40_000):
        x = rng.normal(size=n)
        y = rng.normal(size=n)
        vals.append(ratio(x, y))
    ax.hist(vals, bins=80, color="#3b6ea5", alpha=0.85)
    ax.axvline(0.5, color="#c1121f", ls="--", lw=1.8)
    ax.axvline(1.0, color="#2a9d8f", ls="--", lw=1.8)
    ax.set_xlim(0.4, 1.05)
    ax.set_xlabel("expansion ratio")
    ax.set_ylabel("count")
    ax.set_title("(b) 40 000 random percept pairs stay inside [1/2, 1]")
    ax.grid(alpha=0.25)

    # (c) the width law ------------------------------------------------------
    ax = axes[1, 0]
    dims = np.arange(1, 17)
    ax.fill_between(dims, dims, 2 * dims, color="#c1121f", alpha=0.15,
                    label="infeasible: no lossless layer here")
    ax.plot(dims, 2 * dims, "o-", color="#12355b", lw=2, label="minimal lossless width $2n$")
    ax.plot(dims, dims, ":", color="#666666", lw=1.5, label="naive guess: width $n$")
    ax.scatter([11], [22], s=140, zorder=5, color="#e07a5f", edgecolor="black",
               label="eleven-dimensional percept: 22 units")
    ax.set_xlabel("input dimension $n$")
    ax.set_ylabel("units in the first rectified layer")
    ax.set_title("(c) the exact width law")
    ax.legend(fontsize=8, loc="upper left")
    ax.grid(alpha=0.25)

    # (d) balanced activation ------------------------------------------------
    ax = axes[1, 1]
    ts = np.linspace(0.0, 2 * np.pi, 240)
    a = rng.normal(size=n)
    c = rng.normal(size=n)
    act_x, act_mx, from_pos_block = [], [], []
    for t in ts:
        x = np.cos(t) * a + np.sin(t) * c
        # active at x: positive-block units with x_j > 0 and negative-block units with x_j < 0
        act_x.append(int(np.sum(x > 0)) + int(np.sum(-x > 0)))
        act_mx.append(int(np.sum(-x > 0)) + int(np.sum(x > 0)))
        from_pos_block.append(int(np.sum(x > 0)))
    total = [p + q for p, q in zip(act_x, act_mx)]
    ax.plot(ts, act_x, lw=2.6, color="#2a9d8f", label="$|A(x)| = 11$ always")
    ax.plot(ts, act_mx, lw=1.6, color="#c1121f", ls="--", label="$|A(-x)| = 11$ always")
    ax.plot(ts, total, lw=2.4, color="#12355b", ls="-.", label="union: all 22 units")
    ax.plot(ts, from_pos_block, lw=1.4, color="#8d99ae",
            label="of which from the positive block (varies)")
    ax.set_xlabel("percept phase along a great circle")
    ax.set_ylabel("number of strictly active units")
    ax.set_title("(d) the two blocks always sum to 22")
    ax.set_ylim(-1, 24)
    ax.legend(fontsize=8, loc="center right")
    ax.grid(alpha=0.25)

    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("frame_landscape.png", dpi=160)
    print("wrote frame_landscape.png")


if __name__ == "__main__":
    main()
