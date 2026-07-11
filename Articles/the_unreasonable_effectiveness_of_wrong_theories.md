# The Unreasonable Effectiveness of Wrong Theories

Every physical theory ever written down has been, in some strict sense, wrong. Newton's mechanics was overthrown by relativity; relativity itself is expected to break at the smallest scales; the periodic table, thermodynamics, the standard model — all are provisional. And yet the enterprise of science works spectacularly well. We put probes on comets, predict eclipses to the second, and design microchips using equations we already know are approximations. How can a tower of wrong theories deliver such right answers?

This article tells a mathematical story that turns that paradox into a theorem. Instead of treating "wrongness" as a vague philosophical worry, we make it a *number*, and then we prove three things about that number: that wrongness shrinks in a controlled, quantifiable way as theories improve; that improvement can be *exponentially* fast; and — most surprisingly — that a theory known to be wrong can, on carefully chosen questions, out-predict a rival theory that is closer to the truth overall.

## Theories as points in a space

The first move is a change of scenery. Picture every possible physical theory as a single point in a vast space — call it *theory-space*. This is more than a metaphor. In practice a theory is specified by its predictions: the numbers it assigns to measurable quantities. Collect those numbers into a vector, and the theory becomes a point $T$ in a vector space $E$ equipped with a notion of length and angle (an inner product $\langle\, \cdot\, ,\cdot\,\rangle$, with norm $\|v\| = \sqrt{\langle v,v\rangle}$).

Somewhere in this space sits one distinguished point, $\mathrm{truth}$: the exact description of nature. We may never reach it, but it exists as a target. The **wrongness** of a theory $T$ is simply its distance from the truth,
$$w(T) = \|T - \mathrm{truth}\|.$$
A theory is exactly right precisely when its wrongness is zero — no more, no less. This is the cleanest possible statement of what it means to be correct: $w(T) = 0$ if and only if $T = \mathrm{truth}$.

With this picture, a *phenomenon* — a specific experiment or measurement — becomes a **direction** $u$ in theory-space. What a theory $T$ predicts for phenomenon $u$ is the projection $\langle T, u\rangle$, and the **error** it makes on that phenomenon is how far its projection sits from the truth's:
$$\mathrm{err}(T,u) = |\langle T - \mathrm{truth},\, u\rangle|.$$
Two facts fall out immediately. First, a theory is perfect on *every* phenomenon only if it is the truth itself — you cannot be flawless in all directions and still be wrong. Second, and more slyly, a wrong theory is *perfectly* right on every phenomenon that happens to point at right angles to its mistake. This second fact is the seed of everything surprising that follows.

## Science as a convergent series

Real theories are rarely torn down and rebuilt from scratch. More often they are *corrected*: a small term is added here, a relativistic tweak there, a quantum fluctuation summed over. This is the daily arithmetic of physics, and it has a name — perturbation theory.

We model it directly. Start with a rough theory $T_0$ and a sequence of corrections $c_1, c_2, c_3, \dots$. After $n$ steps the working theory is
$$T_n = T_0 + c_1 + c_2 + \cdots + c_n.$$
The central question is whether this ever-improving sequence actually *arrives* at the truth. The answer is a clean convergence theorem: **if the corrections add up to exactly the gap between the truth and the starting point** — that is, if $\sum_i c_i = \mathrm{truth} - T_0$ — then the wrongness $w(T_n)$ marches steadily to zero. The whole of science, in this model, is a convergent series toward the truth.

Two stabilizing facts make this trustworthy rather than fragile. The first is a *Lipschitz* bound: applying a correction $c$ changes a theory's wrongness by at most $\|c\|$, the size of the correction itself. Small tweaks cannot cause wild swings in accuracy; the map from theory to wrongness is gentle. The second is a *tail bound*: the leftover wrongness after $n$ corrections is controlled by the sum of the remaining correction sizes,
$$w(T_n) \le \sum_{i \ge 0} \|c_{i+n}\|,$$
and this tail necessarily shrinks to nothing. You always know how much further you have to go by looking at how much work remains.

## How fast? Exponentially, if you are lucky

Convergence is comforting; *speed* is what makes science practical. Here the model delivers a crisp, quantitative reward for well-behaved corrections. Suppose successive corrections shrink geometrically — each one at most a fixed fraction of the last, so $\|c_i\| \le M r^{i}$ for some ratio $0 \le r < 1$. Then the residual wrongness after $n$ terms obeys
$$w(T_n) \le \frac{M\, r^{n}}{1 - r}.$$
The error decays *exponentially*. This is the mathematical reason a handful of terms in a perturbation expansion can pin down a physical constant to a dozen decimal places: when the corrections behave, accuracy compounds. It is the difference between a theory that is asymptotically true in principle and one that is usefully true after an afternoon of calculation.

## The twist: when wrong beats right

All of this would be a tidy formalization of scientific optimism — theories improve, and we can say how fast. But the title promises something stranger, and here it is.

Take two wrong theories. Call one $A$ — *our* theory — and the other $B$ — a rival, perhaps even one that is *closer* to the truth overall, a "better" theory by the honest global measure of wrongness. The claim is that there is always a phenomenon on which our worse theory $A$ gives the *exactly correct* answer while the better theory $B$ does not.

The only thing we need is that the two theories are wrong *in different directions*: the error vector of $A$ is not simply a rescaling of the error vector of $B$. When that mild condition holds, we can construct an explicit phenomenon $u$ — pointing along the part of $B$'s error that $A$'s error cannot explain — with the property that
$$\mathrm{err}(A, u) = 0 < \mathrm{err}(B, u).$$
On that experiment, the "wrong" theory is flawless and the "better" theory misses.

The construction is a classical one in disguise: it is the Gram–Schmidt step, the same orthogonalization trick that underlies least squares and quantum bases. We subtract from $B$'s error exactly its shadow along $A$'s error, leaving a direction orthogonal to $A$'s mistake. Because a theory is *perfect* on any phenomenon orthogonal to its error, $A$ scores exactly zero there — while $B$, whose error genuinely points that way, does not. The geometry guarantees a blind spot in the rival that our theory happens to see through.

## Why this is not a cheat

It is worth being honest about what this does and does not say. It does *not* say that wrong theories are secretly right, or that all theories are equally good. Globally, wrongness is wrongness: the theory with smaller $w(T)$ is closer to nature, full stop. What the meta-theorem says is that global accuracy and *local* accuracy come apart. No single wrong theory can win everywhere — that would make it the truth — but every wrong theory, provided it fails in its own idiosyncratic direction, owns a whole hyperplane of phenomena on which it is exactly right, and on some of those it beats any given rival.

This is why obsolete theories never fully die. Newtonian gravity is "wrong," yet for the phenomena orthogonal to its errors — everyday trajectories, orbital mechanics at human scales — it is not merely good but, within the model, exactly on target, and it will out-predict a clumsy relativistic approximation that happens to be miscalibrated for those regimes. Geocentric astronomy, ray optics, ideal gases, rigid bodies: each is a wrong theory that reigns supreme over its own class of phenomena. Engineers exploit this constantly, reaching for the "wrong" but locally perfect tool.

## The larger picture

There is a pleasing unity to the three results. The convergence and rate theorems explain the *diachronic* success of science — why the long march of corrected theories closes in on the truth, and why it can do so fast. The meta-theorem explains the *synchronic* success — why, at any given moment, a whole ecosystem of admittedly imperfect theories can each be indispensable, each ruling a territory of phenomena where it is not just adequate but exact.

It is worth dwelling on how tightly the pieces interlock. The single vector $T - \mathrm{truth}$, the *error* of a theory, carries all the information. Its length is the wrongness — the one number that decides which of two theories is globally better. Its direction carves theory-space into two parts: the line along which the theory is maximally wrong, and the vast perpendicular hyperplane on which it is exactly right. And the *relationship* between two error vectors — whether they are parallel or not — decides who wins a contest on a given phenomenon. Almost the entire story is written in the geometry of a single arrow.

This also clarifies a subtlety that trips up naive philosophy of science. "All models are wrong, but some are useful," the statistician George Box famously said. The geometry sharpens the aphorism into something quantitative: all models except the truth have a nonzero error vector, but each such model is not merely useful — it is *perfect* on an entire hyperplane of measurements, and it dominates any rival whose error strays into that hyperplane. Usefulness is not a vague virtue; it is a measurable region of theory-space that each wrong theory owns outright.

There is a practical moral, too. When you must choose between competing imperfect models, the right question is rarely "which is more accurate overall?" It is "which fails in a direction orthogonal to the phenomenon I care about?" A weather model that is globally cruder may nonetheless be exactly calibrated for the one quantity you need to forecast, precisely because its errors live elsewhere. The meta-theorem guarantees that such favorable mismatches always exist between any two differently-wrong theories — so the search for the locally best tool is never futile.

Eugene Wigner once marveled at "the unreasonable effectiveness of mathematics in the natural sciences." The story here is a companion puzzle with, perhaps, a more satisfying resolution. The effectiveness of wrong theories is not unreasonable at all once you draw the geometry: it is the necessary consequence of living in a space where error has direction, where corrections form convergent series, and where being wrong in your own way guarantees you a domain in which you are exactly, unbeatably right.
