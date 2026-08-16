# The Unreasonable Effectiveness of Wrong Theories

## Why the best prediction in the room is usually made by a theory nobody believes

In 1687 Isaac Newton wrote down a law of gravitation that is, we now know, false. Space is not flat, time is not absolute, gravity is not a force but the curvature of spacetime. Every serious physicist since 1915 has agreed that Newton's theory is *wrong*.

And every serious engineer since 1915 has used it anyway. When NASA flew Voyager past Neptune, the trajectory was computed with Newton. When you look up the tides, you are reading a Newtonian calculation. The false theory is not merely convenient — for most of the questions we actually ask, it is *more accurate in practice* than any competitor we can compute with.

This is not a scandal about Newton. It is a structural fact about knowledge, and it repeats itself everywhere. The Bohr model of the atom is wrong, and it predicts hydrogen's spectral lines to four digits. The ideal gas law is wrong, and refrigeration engineers use it daily. The two-loop truncation of a quantum field theory calculation is *knowingly, deliberately* wrong — the physicist doing it can tell you exactly which infinitely many terms are being thrown in the bin — and it beats every non-perturbative competitor that anyone can actually evaluate.

What follows is an attempt to turn this folklore into mathematics: to state and prove a theorem about *theories themselves*, which explains why approximately correct falsehoods so reliably outperform their rivals, and — just as importantly — to find exactly where that explanation stops working.

---

## Theories as functions, wrongness as a series

Strip a physical theory down to its empirical skeleton. There is a set $\Phi$ of **phenomena** — things you can measure: the perihelion shift of Mercury, the boiling point of water at 3 km altitude, the magnetic moment of the electron. A **theory** is nothing more than an assignment of a number to each phenomenon:
$$T : \Phi \to \mathbb{R}.$$

Somewhere out there — unknowable, but existing — is the **truth**, another such function $t : \Phi \to \mathbb{R}$. The **error** of a theory at a phenomenon is the obvious thing:
$$E(T, p) = |T(p) - t(p)|.$$

We say $T$ **beats** a rival $C$ at $p$ when $E(T,p) < E(C,p)$: it lands strictly closer to the truth there. Notice what this definition does *not* say. It does not say $T$ is true, or beautiful, or ontologically respectable. Predictive superiority is a purely comparative, purely local notion, and everything below flows from taking that seriously.

Now, what makes a theory "approximately correct"? Here we borrow the shape of an idea from physics itself. Almost every successful approximate theory is the leading part of an expansion in some small quantity: $v/c$ in special relativity, $\hbar$ in the semiclassical limit, the fine-structure constant in quantum electrodynamics, $\varepsilon = 4 - d$ in critical phenomena. So we define a **perturbative family of theories** to be a truth function together with a sequence of correction coefficients $a_n(p)$, giving for each value of a coupling $\varepsilon$ the prediction
$$T_\varepsilon(p) = t(p) + \sum_{n=0}^{\infty} a_n(p)\, \varepsilon^{\,n+1}.$$

We require one thing of the coefficients — a uniform Cauchy-type bound
$$|a_n(p)| \le B\, r^{\,n} \qquad \text{for all } n \text{ and all } p,$$
with constants $B, r \ge 0$. This says the corrections grow no faster than geometrically, uniformly across *all* phenomena at once. It is exactly the condition that makes the series a genuine analytic germ in $\varepsilon$ rather than a formal fantasy.

The quantity
$$W(\varepsilon, p) = T_\varepsilon(p) - t(p) = \sum_{n=0}^{\infty} a_n(p)\,\varepsilon^{\,n+1}$$
is the **wrongness** of the theory: the total amount by which it misses. The framing of the whole subject is this: *wrongness is not a binary verdict, it is a convergent series.*

**The Convergent Wrongness Theorem.** *If $r|\varepsilon| < 1$, the wrongness series converges absolutely and*
$$|W(\varepsilon, p)| \;\le\; \frac{B\,|\varepsilon|}{1 - r|\varepsilon|}$$
*for every phenomenon $p$ simultaneously.*

The proof is two lines of geometric domination: $|a_n(p)\varepsilon^{n+1}| \le (B|\varepsilon|)(r|\varepsilon|)^n$, and summing the geometric majorant gives the bound. What matters is not the difficulty but the *uniformity*. The estimate has no $p$ in it. Shrink the coupling and the theory becomes accurate everywhere at once — not phenomenon by phenomenon, but as a single sweep across the entire domain of application. Concretely: for every tolerance $\eta > 0$ there is a window $|\varepsilon| < \delta$ inside which $|W(\varepsilon,p)| < \eta$ for *all* $p$.

---

## The meta-theorem

Now the payoff. Fix an approximately correct theory — a perturbative family in the above sense — and fix any accuracy threshold $\eta > 0$.

**The Unreasonable Effectiveness Theorem.** *There exists $\delta > 0$ such that for every coupling with $|\varepsilon| < \delta$, for every rival theory $C$ whatsoever, and for every phenomenon $p$ at which $C$'s error is at least $\eta$, the theory $T_\varepsilon$ beats $C$ at $p$.*

Read the quantifiers slowly, because they carry the entire content. The window $\delta$ is chosen **first**. It does not depend on the rival, and it does not depend on the phenomenon. Once you have fixed how accurate your approximate theory is, *every* competing theory in the universe — Aristotelian physics, a neural network, a rival unification programme, or the true theory implemented with a bug — is automatically beaten on the whole region where that competitor's error exceeds the threshold.

The proof is a single application of the convergence estimate: $E(T_\varepsilon, p) = |W(\varepsilon,p)| < \eta \le E(C, p)$. Trivial as mathematics; substantial as epistemology. It tells you that the "class of phenomena for which a wrong theory beats its rivals" is not some exotic set that needs to be constructed by hand. It is simply the set where the rival is bad, and it comes for free.

Two corollaries sharpen this into something one can point at.

*The superiority region is never empty.* If a rival $C$ is inexact at even a single phenomenon $p_0$ — that is, $C(p_0) \ne t(p_0)$ — then there is a coupling window on which the set $\{p : T_\varepsilon \text{ beats } C \text{ at } p\}$ is nonempty. Take $\eta = E(C, p_0) > 0$ and apply the theorem. An approximately correct theory outpredicts every imperfect rival *somewhere*.

*And imperfection is generic.* Over a countable space of phenomena, given any theory $T$ and any $\delta > 0$, there is a constant $0 < c < \delta$ such that the shifted theory $T + c$ is wrong at **every single phenomenon**. The argument is a cardinality trick of striking economy: the "bad" shifts — the ones that accidentally hit the truth somewhere — form a countable set, while the interval $(0,\delta)$ is uncountable, so almost every tiny shift misses the truth everywhere. Nowhere-exact theories are dense in theory space. The hypothesis "your rival is imperfect somewhere" is not a caveat; it is the generic case.

---

## The tower of deliberate lies

There is a second, more delicate phenomenon hiding inside the wrongness series, and it concerns the theories physicists actually write down. Nobody sums an infinite perturbation series. What one computes is a **truncation**: keep the first $N$ corrections, discard the infinitely many others,
$$T^{(N)}_\varepsilon(p) = t(p) + \sum_{n<N} a_n(p)\,\varepsilon^{\,n+1}.$$
This is a knowingly wrong theory in the purest sense — its author can name the terms being thrown away. The discarded remainder is the **tail** $R_N = W - \sum_{n<N} a_n \varepsilon^{n+1}$, and it satisfies the exact recursion $R_N = a_N \varepsilon^{N+1} + R_{N+1}$: the error of a truncation is its first neglected term plus the error of the next truncation down the line.

From that recursion come matched two-sided estimates. In the half-disc $r|\varepsilon| \le \tfrac12$,
$$|a_N(p)|\,|\varepsilon|^{N+1} - 2B\,r^{N+1}|\varepsilon|^{N+2} \;\le\; |R_N| \;\le\; 2B\,r^{N}|\varepsilon|^{N+1}.$$
The upper bound says the $N$-th truncation is accurate to order $\varepsilon^{N+1}$. The lower bound is the interesting one: it says the error is *at least* the first neglected term, minus a correction that is smaller by a whole power of $\varepsilon$. Squeeze these together and you get:

**The Wrongness Hierarchy Theorem.** *Let $p$ be a phenomenon at which the $M$-th correction does not vanish, $a_M(p) \ne 0$, and let $N > M$. Then there is a punctured window $0 < |\varepsilon| < \delta$ on which the $N$-th order truncation strictly beats the $M$-th order truncation as a predictor of the exact theory.*

And the window can be taken uniform: for any finite stretch of the tower, there is a single $\delta$ on which the truncations of orders $0, 1, 2, \dots, K$ are **totally ordered** by predictive accuracy, each higher one strictly better than every lower one.

This is the precise sense in which the wrongness of a theory "forms a convergent series toward truth". It is not just that the total error goes to zero. It is that the *sequence of deliberate falsehoods is strictly, monotonically improving* — the tower of lies is a ladder, and each rung is closer to the sky than the last. When a physicist says "we went to three loops and the agreement improved", this theorem is what they are relying on.

Why $\delta$ has the size it does is worth a glance. It is essentially
$$\delta \approx \frac{|a_M(p)|}{2B\,(r^N + r^{M+1})},$$
the ratio of the *signal* — the first term the coarse theory neglects — to the *noise*, the geometric mass of everything both theories neglect. Improvement happens exactly when the term you newly capture outweighs everything still missing. Push the coupling past that ratio and the guarantee dissolves.

---

## Where it all breaks

A meta-theorem that admitted no counterexamples would be suspicious, and this one has two sharp ones. They are not gaps in the proof; they are proofs that the hypotheses are indispensable.

**The coupling window is necessary.** Take the perturbative theory $T_\varepsilon = \varepsilon$ around a truth of $0$, and the crude constant rival $C \equiv 1/4$, which is certainly wrong. At $\varepsilon = 1/2$ — not a small coupling, but hardly an outrageous one — the approximately correct theory errs by $1/2$ while the crude rival errs by $1/4$. The wrong-but-lucky rival wins. So the meta-theorem's guarantee genuinely evaporates outside its window: an approximate theory pushed beyond its regime of validity can be beaten by a competitor with no claim to correctness at all. This is the mathematical shadow of the practical rule that a perturbative calculation at strong coupling is worth less than a good guess.

**Monotonicity along the tower is a small-coupling phenomenon.** Consider the two-term family $W(\varepsilon) = \varepsilon - 3\varepsilon^2$. At $\varepsilon = 1$ the zeroth truncation errs by $|{-2}| = 2$, while the first-order truncation — which *includes more information* — errs by $|{-3}| = 3$. Adding a correction made things worse. So "higher order is always better" is not merely unproved; it is false, and false at a completely explicit point. Anyone who has watched a perturbative series in a strongly coupled theory get worse as the loop order climbs will recognise the picture.

Both failures share a shape: *true inside a window, false outside it, with the window explicit and quantitative.* That is arguably the most honest thing a meta-theorem about approximate knowledge could say.

---

## Being right is a fact about the world, not about the theory

Two further results reframe what "closeness to truth" can even mean.

Suppose two theories make different predictions $a \ne b$ at some phenomenon, and ask: in which possible worlds — that is, for which values $t$ of the unknown truth — does the first beat the second? A one-line computation shows
$$|t - a| < |t - b| \iff (b-a)\,(2t - a - b) < 0,$$
which is a *half-line* in $t$. So:

**The Epistemic Half-Space Theorem.** *For any two distinct predictions, the set of worlds in which the first outpredicts the second is a nonempty, open, unbounded half-line. It always contains the world $t = a$ in which the first theory is exactly right, and it stretches to infinity.*

No prediction is unconditionally inferior. Every theory that says *anything* is the best available theory in an unbounded family of worlds. Indeed, given any family of rival theories that pairwise disagree at some phenomenon, one can exhibit a world in which any chosen member strictly beats all the others — simply the world in which it happens to be exactly right. Empirical inferiority is never intrinsic to a theory; it is a joint fact about the theory and the world it finds itself in.

And there is a related bound with a bracing moral. For any two theories and any truth whatsoever,
$$|T(p) - C(p)| \;\le\; E(T,p) + E(C,p).$$
**Disagreement forces error**: if two theories differ by an amount $D$ at a phenomenon, then whatever the truth is, at least one of them is wrong by at least $D/2$. Controversy is a lower bound on collective ignorance.

---

## Why you cannot simply rank theories

If superiority is local, the natural repair is to aggregate: declare $X$ better than $Y$ if $X$ beats $Y$ on *most* phenomena. This fails, and it fails in the way that democracies fail.

Take three phenomena with truth $0$, and three theories with error profiles
$$A = (1,2,3), \qquad B = (2,3,1), \qquad C = (3,1,2).$$
Then $A$ beats $B$ on phenomena 1 and 2; $B$ beats $C$ on phenomena 1 and 3; and $C$ beats $A$ on phenomena 2 and 3. Every one of these is a two-out-of-three majority. But $A$ beats $C$ on only the first phenomenon, so $A$ does *not* majority-beat $C$. Majority empirical adequacy runs in a **Condorcet cycle**, and is therefore not transitive: it is not even a preorder, let alone an ordering.

The consequence for the philosophy of science is sharp. Any attempt to compress predictive performance across phenomena into a single scalar "closeness to truth" must break something — either transitivity, or the independence of the individual phenomena, exactly as Arrow's theorem forces on voting rules. Comparative adequacy is a *directed graph* on theory space, with cycles, not a ladder.

---

## Convergence without correctness

One last result speaks directly to the pessimistic meta-induction — the argument that since every past scientific theory turned out to be false, our current ones will be too, and we should therefore not believe them.

Consider the sequence of theories $F_k = t + \frac{1}{k+1}$. Every single one is **wrong at every single phenomenon**; not one of them is ever exactly right anywhere. And their errors converge uniformly to zero. The history of a science can consist entirely of falsehoods and still be a history of convergence on the truth.

That is the reconciliation the whole framework is built to make. Wrongness is a magnitude, not a verdict. Falsity is compatible with progress; indeed, in a perturbative universe, falsity is the *only* form successful knowledge ever takes, because summing the whole series is not something finite beings do.

---

## A concrete case: the $\varepsilon$-expansion

None of this is a toy. Consider one of the genuine triumphs of twentieth-century theoretical physics: Wilson's expansion of critical exponents in $\varepsilon = 4 - d$, the deviation of spatial dimension from four. At the Wilson–Fisher fixed point, the two-loop calculation gives an anomalous dimension
$$\eta(\varepsilon) = \frac{\varepsilon^2}{54} + O(\varepsilon^3).$$

This formula is wrong. It is a truncation; the omitted terms are infinite in number, the series is not even convergent in the usual sense, and the physical case of interest is $\varepsilon = 1$ (three dimensions), which is not small. And yet it is a perturbative family in exactly the sense above — corrections $a_0 = 0$, $a_1 = 1/54$ — and the meta-theorem applies to it verbatim: for every accuracy threshold there is a window of dimensions near four in which this knowingly-truncated theory outpredicts *every* rival whose error exceeds the threshold.

That the same formula, extrapolated recklessly to $\varepsilon = 1$, still gives critical exponents accurate to a few percent for real magnets and real fluids, is the unreasonable effectiveness of wrong theories in its natural habitat — and the boundary counterexamples above are the honest reminder that at $\varepsilon = 1$ we are outside the window, and running on luck rather than on theorem.

---

## The moral

Newton's theory is false. So is Bohr's, so is the ideal gas law, so is every truncated loop expansion ever published. The framework here says that this is not a defect to be apologised for but the normal structure of successful science:

1. Wrongness is a convergent series, controlled uniformly across all phenomena at once.
2. An approximately correct theory beats *every* imperfect rival on the entire region where that rival is bad — with a window chosen in advance of knowing who the rival is.
3. The tower of deliberate truncations is strictly ordered: each knowingly-wrong approximation beats the one below it.
4. All of this holds only inside an explicit window, and demonstrably fails outside it.
5. No theory is inferior in every world; and predictive superiority cannot be aggregated into any consistent global ranking.

"All models are wrong, but some are useful," runs the aphorism. What the mathematics adds is the quantifier structure: *how* wrong, on *which* phenomena, compared to *whom*, and — crucially — within *what window*.
