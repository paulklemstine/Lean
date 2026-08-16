# The Unreasonable Effectiveness of Wrong Theories

### A guided tour of perturbation theory on theory-space

---

## 1. A puzzle worth taking seriously

Newton's law of gravitation is false. Spacetime is curved, gravity is not a force, and every physicist since 1915 has agreed on the point.

And every engineer since 1915 has used it anyway. Voyager flew past Neptune on a Newtonian trajectory. Tide tables are Newtonian. For most of the questions we actually ask, the false theory is not merely convenient — it is *more accurate in practice* than any competitor we can compute with.

This is not an embarrassment about Newton. It happens everywhere:

| Theory | Verdict | Still used for |
|---|---|---|
| Newtonian gravitation | False since 1915 | Spacecraft navigation, tides, orbital mechanics |
| The Bohr atom | False since 1926 | Hydrogen spectral lines to four digits |
| The ideal gas law | Never exactly true | Refrigeration, meteorology, engine design |
| Any truncated loop expansion | Wrong *by construction* | Essentially all quantitative predictions of the Standard Model |

By the end of this page you will have a theorem that explains the pattern, a second theorem that explains why "compute one more order" is a rational thing to do, and — just as importantly — two explicit counterexamples showing exactly where both explanations stop working.

> **The question in one line.** Can we prove that an *approximately correct* theory must outpredict its rivals — and if so, on which phenomena, against which rivals, and under what conditions?

---

## 2. Stripping a theory down to its skeleton

Forget ontology. Empirically, a physical theory does one thing: it assigns numbers to measurable situations.

- A set $\Phi$ of **phenomena** — the perihelion shift of Mercury, the boiling point of water at altitude, the electron's magnetic moment.
- A **theory** is a function $T : \Phi \to \mathbb{R}$.
- Somewhere out there is the **truth**, another function $t : \Phi \to \mathbb{R}$, which we never see.
- The **error** at a phenomenon is $E(T,p) = |T(p) - t(p)|$.
- We say $T$ **beats** $C$ at $p$ when $E(T,p) < E(C,p)$.

Notice how little this says. Not that $T$ is true. Not that $T$ is beautiful. Just: at *this* phenomenon, it lands closer. Superiority is comparative, local, and nothing more. Everything below flows from taking that austerity seriously.

<details>
<summary><b>Why be this minimal? (click to expand)</b></summary>

Richer accounts of theories — as sets of models, as axiom systems, as research programmes — are indispensable for questions about explanation and unification. But they smuggle in structure that predictive-accuracy questions do not need, and that structure tends to obscure the quantifiers. The whole force of the main theorem lies in the *order* in which "for all rivals", "for all phenomena", and "there exists a window" appear. A minimal setting makes that order visible. See the [Stanford Encyclopedia entry on scientific realism](https://plato.stanford.edu/entries/scientific-realism/) for the richer accounts this deliberately sets aside.

</details>

---

## 3. Wrongness is a series, not a verdict

Here is the modelling move that makes the whole subject go. Almost every successful approximate theory is the leading part of an expansion in something small: $v/c$ in relativity, $\hbar$ in the semiclassical limit, the fine-structure constant in electrodynamics, $\varepsilon = 4-d$ in critical phenomena.

So define a **perturbative family of theories**: a truth function together with correction coefficients $a_n(p)$, giving for each coupling $\varepsilon$ the prediction

$$T_\varepsilon(p) \;=\; t(p) \;+\; \underbrace{\sum_{n=0}^{\infty} a_n(p)\,\varepsilon^{\,n+1}}_{\text{the wrongness } W(\varepsilon,p)}$$

subject to one condition — a **uniform Cauchy bound**

$$|a_n(p)| \;\le\; B\,r^{\,n} \qquad \text{for every } n \text{ and every } p.$$

The corrections grow no faster than geometrically, and — this is the load-bearing word — *uniformly across all phenomena at once*.

> **Theorem (Convergent Wrongness).** If $r|\varepsilon| < 1$ then the wrongness series converges absolutely and
> $$|W(\varepsilon,p)| \;\le\; \frac{B|\varepsilon|}{1 - r|\varepsilon|}$$
> for every phenomenon $p$ simultaneously.

<details>
<summary><b>Proof (two lines)</b></summary>

Each term obeys $|a_n(p)\varepsilon^{n+1}| \le B r^n |\varepsilon|^{n+1} = (B|\varepsilon|)(r|\varepsilon|)^n$. Summing the geometric majorant gives $B|\varepsilon|/(1-r|\varepsilon|)$, and the triangle inequality for absolutely convergent series transfers the bound to $|W|$. $\blacksquare$

The point is not the difficulty; it is that the right-hand side contains **no $p$**. Shrink the coupling and the theory becomes accurate *everywhere at once*.

</details>

Equivalently: for every tolerance $\eta > 0$ there is a window $|\varepsilon| < \delta$ inside which $|W(\varepsilon,p)| < \eta$ for all $p$, and one may take

$$\delta \;=\; \min\left\{\frac{1}{2(r+1)},\ \frac{\eta}{2(B+1)}\right\}.$$

That formula is not decoration. It is computable, and the first algorithm below implements it.

{{algorithm:0}}

---

## 4. The meta-theorem

Now the payoff. Fix an approximately correct theory and an accuracy threshold $\eta > 0$.

> **Theorem (Unreasonable Effectiveness of Wrong Theories).** There is a $\delta > 0$ such that for every coupling with $|\varepsilon| < \delta$, for **every rival theory $C$ whatsoever**, and for every phenomenon $p$ at which $C$'s error is at least $\eta$, the theory $T_\varepsilon$ beats $C$ at $p$.

Read the quantifiers slowly, because they carry the entire content.

- $\delta$ is chosen **first**, from $B$, $r$ and $\eta$ alone.
- It does **not** depend on the rival. Not on Aristotelian physics, not on a neural network, not on a rival unification programme, not on the true theory implemented with a bug.
- It does **not** depend on the phenomenon.

The proof, once the convergence estimate is in hand, is a single line: $E(T_\varepsilon,p) = |W(\varepsilon,p)| < \eta \le E(C,p)$. Trivial as mathematics; substantial as epistemology.

Time to get your hands on it. In the laboratory below, the first tab puts the truth at $0$, places your approximate theory and a rival on the number line, and shades the threshold band. Start inside the window and try to defeat the theorem with any rival you like; then push $\varepsilon$ up and watch the guarantee dissolve.

{{interactive_demo:0}}

**Three things to try.**
1. Slide the rival anywhere. As long as its error reaches $\eta$, you cannot beat the approximate theory — that is the theorem.
2. Slide the rival *inside* the threshold band. The verdict panel turns amber: no claim is made there. The theorem only ever promises victory on the rival's **bad set**.
3. Push $\varepsilon$ past $\delta$. Now a crude constant can win. Hold that thought — §7 turns it into a theorem.

<details>
<summary><b>What the meta-theorem does <i>not</i> say</b></summary>

It does not say $T_\varepsilon$ is true — generically its wrongness is nonzero and it is false at every phenomenon. It does not say $T_\varepsilon$ beats $C$ everywhere — where $C$ happens to be very accurate, $C$ may well win. It says exactly this: *the region of the rival's badness is a region of the approximate theory's comparative goodness*, and that region is specified by a condition anyone can check without evaluating the approximate theory at all.

</details>

Two corollaries make it bite.

**The superiority region is never empty.** If a rival is inexact at even one phenomenon $p_0$, take $\eta = E(C,p_0) > 0$ and the theorem hands you a window on which $p_0$ belongs to the superiority region.

**And imperfection is generic.** Over a countable phenomenon space, given any theory and any $\delta > 0$, there is a shift $0 < c < \delta$ making the shifted theory wrong at *every single phenomenon*.

<details>
<summary><b>The cardinality trick behind genericity</b></summary>

The "bad" shifts — those that accidentally hit the truth somewhere — form the set $\{t(p) - T(p) : p \in \Phi\}$, the image of a countable set, hence countable. The interval $(0,\delta)$ has the cardinality of the continuum. So almost every tiny shift misses the truth everywhere. Nowhere-exact theories are *dense* in theory-space: "your rival is imperfect somewhere" is not a caveat, it is the typical case.

</details>

The next demo makes the certificate concrete over a catalogue of five phenomena and three very different rivals, and measures how conservative it is.

{{demo:1}}

---

## 5. The tower of deliberate lies

Nobody sums an infinite perturbation series. What one computes is a **truncation** — keep the first $N$ corrections, bin the rest:

$$T^{(N)}_\varepsilon(p) \;=\; t(p) + \sum_{n<N} a_n(p)\,\varepsilon^{\,n+1}.$$

This is a knowingly wrong theory in the purest sense: its author can name the terms being discarded. The discarded remainder is the **tail** $R_N$, and it obeys an exact recursion that is the engine of everything in this section:

$$R_N \;=\; \underbrace{a_N\varepsilon^{N+1}}_{\text{first neglected term}} \;+\; R_{N+1}.$$

The error of a truncation is its first neglected term plus the error of the next truncation down the line. Squeeze this between matched upper and lower bounds and you get:

> **Theorem (Wrongness Hierarchy).** Let $p$ be a phenomenon at which the $M$-th correction does not vanish, and let $N > M$. Then there is a punctured window $0 < |\varepsilon| < \delta$ on which the $N$-th order truncation **strictly beats** the $M$-th.
>
> Moreover a single window serves all of orders $0,1,\dots,K$ at once: on it, the truncations are **totally ordered** by accuracy.

<details>
<summary><b>The two-sided estimates, and where $\delta$ comes from</b></summary>

In the half-disc $r|\varepsilon| \le 1/2$,

$$|a_N(p)||\varepsilon|^{N+1} - 2Br^{N+1}|\varepsilon|^{N+2} \;\le\; |R_N| \;\le\; 2Br^{N}|\varepsilon|^{N+1}.$$

The upper bound is the geometric majorant. The lower bound comes from the recursion: $|a_N\varepsilon^{N+1}| = |R_N - R_{N+1}| \le |R_N| + |R_{N+1}|$, then apply the upper bound at order $N+1$. The gap between them is a full power of $\varepsilon$ — exactly the room needed to conclude. The resulting window is

$$\delta \;=\; \min\left\{1,\ \frac{1}{2(r+1)},\ \frac{|a_M(p)|}{2B(r^N + r^{M+1}) + 1}\right\},$$

which reads as a **signal-to-noise ratio**: the first term the coarse theory neglects, divided by the geometric mass of everything both theories neglect. Improvement happens exactly while the newly captured term outweighs everything still missing.

</details>

This is the precise sense in which the wrongness of a theory "forms a convergent series toward truth". Not just that the limit is right — that the *sequence of deliberate falsehoods is strictly, monotonically improving*. The tower of lies is a ladder, and each rung is closer to the sky than the last. When a physicist says "we went to three loops and the agreement improved", this is the theorem being relied on.

Switch the laboratory to its second tab — **The truncation tower** — and watch the bars fall in a clean staircase. Then push $\varepsilon$ and watch a bar turn red.

{{algorithm:1}}

The picture below is worth a thousand bars: on the left, six truncation-error curves nested like Russian dolls inside the certified window; on the right, the sharpness counterexample where two of them cross.

{{visualization:0}}

---

## 6. Being right is a fact about the *world*

Two results now reframe what "closer to the truth" can even mean.

Suppose two theories predict $a \ne b$ at some phenomenon. In which possible worlds — which values $t$ of the unknown truth — does the first beat the second? One line of algebra:

$$|t - a| < |t - b| \iff (b-a)(2t - a - b) < 0,$$

a **half-line** in $t$.

> **Theorem (Epistemic Half-Space).** For any two distinct predictions, the set of worlds in which the first outpredicts the second is a nonempty, open, unbounded half-line. It always contains the world $t = a$ where the first theory is exactly right, and it stretches to infinity.

No prediction is unconditionally inferior. Every theory that says *anything* is the best available theory in an unbounded family of worlds.

And a bracing companion bound, true whatever the truth is:

$$|T(p) - C(p)| \;\le\; E(T,p) + E(C,p).$$

**Disagreement forces error.** If two theories differ by $D$ at a phenomenon, at least one of them is wrong by at least $D/2$. Controversy is a truth-independent lower bound on collective ignorance.

Drag the truth around in the arena below and watch ownership of the world change hands.

{{interactive_demo:1}}

---

## 7. Why you cannot simply rank theories

If superiority is local, the natural repair is to aggregate: declare $X$ better than $Y$ if $X$ beats $Y$ on *most* phenomena. This fails — and it fails in the way democracies fail.

Three phenomena with truth $0$, and three theories with error profiles

$$A = (1,2,3), \qquad B = (2,3,1), \qquad C = (3,1,2).$$

Then $A$ beats $B$ on phenomena 1 and 2; $B$ beats $C$ on 1 and 3; $C$ beats $A$ on 2 and 3. Every one a two-out-of-three majority. But $A$ beats $C$ on phenomenon 1 only. Majority empirical adequacy runs in a **Condorcet cycle** and is not transitive.

The second experiment in the arena above lets you edit the profiles and watch the tournament graph rewire itself in real time. Try to break the cycle; then try to build a new one.

<details>
<summary><b>Why this is an Arrow-type obstruction, and what to do about it</b></summary>

Any aggregation of pointwise errors into a total order on theory-space must break either transitivity or the independence of the individual phenomena — the same trilemma [Arrow's impossibility theorem](https://plato.stanford.edu/entries/arrows-theorem/) forces on voting rules. The constructive response is to stop looking for an order. Comparative adequacy is a **tournament**: a directed graph on theory-space, cycles permitted.

Note how the meta-theorem escapes the obstruction: it never aggregates. It compares one theory to one rival at one phenomenon, and specifies the winning region by an explicit, checkable condition on the rival.

</details>

{{algorithm:2}}

{{visualization:1}}

---

## 8. Convergence without correctness

One last result, aimed squarely at the *pessimistic meta-induction* — the argument that since every past scientific theory turned out false, our current ones will be too, so we should not believe them.

Consider the sequence $F_k = t + \frac{1}{k+1}$. Every single one is **wrong at every single phenomenon**; not one is ever exactly right anywhere. And their errors converge uniformly to zero.

A history of science consisting entirely of falsehoods is perfectly consistent with convergence on the truth. Falsity is a binary predicate; approximate correctness is a magnitude; the meta-induction conflates them.

---

## 9. Where it all breaks

A meta-theorem with no counterexamples would be suspicious. This one has two sharp ones, and they are not gaps in the proofs — they are proofs that the hypotheses are indispensable.

> **Sharpness of the meta-theorem.** Take $T_\varepsilon = \varepsilon$ around a truth of $0$, and the crude constant rival $C \equiv 1/4$, which is certainly wrong. At $\varepsilon = 1/2$ the approximate theory errs by $1/2$, the crude rival by $1/4$. **The rival wins.**

> **Sharpness of the hierarchy.** Take $W(\varepsilon) = \varepsilon - 3\varepsilon^2$ at $\varepsilon = 1$. The zeroth truncation errs by $2$; the first-order truncation — which contains *more information* — errs by $3$. **Adding a correction made it worse.**

Both are the mathematical shadow of something every practitioner knows: a perturbative calculation at strong coupling can be worse than a good guess, and in a divergent series the loop order eventually stops helping.

Both failures share a shape — *true inside a window, false outside it* — and in both cases the window is explicit and computable. That makes the framework a **criterion**, not an apologia. Given the Cauchy data of an expansion and a threshold, you can compute the coupling range in which the guarantees hold, and outside which you are running on luck.

---

## 10. A real case: the $\varepsilon$-expansion

None of this is a toy. In Wilson's analysis of critical phenomena one works in $d = 4 - \varepsilon$ dimensions; at the interacting fixed point of the renormalisation-group flow the anomalous dimension of the field is, at two loops,

$$\eta(\varepsilon) = \frac{\varepsilon^2}{54} + O(\varepsilon^3).$$

This formula is wrong. It is a truncation, the omitted terms are infinite in number, the full series is believed divergent, and the physical case of interest is $\varepsilon = 1$ — three dimensions — which is not small.

It is also, exactly, a perturbative family with $a_0 = 0$ and $a_1 = 1/54$. The meta-theorem applies verbatim: for every accuracy threshold there is a window of dimensions near four in which this knowingly-truncated theory outpredicts every rival whose error exceeds the threshold.

That the same formula, extrapolated recklessly to $\varepsilon = 1$, still gives critical exponents good to a few percent for real magnets and real fluids is the unreasonable effectiveness of wrong theories in its natural habitat — and §9 is the honest reminder that at $\varepsilon = 1$ we are outside the window, and running on luck rather than on theorem. Read more on [critical exponents](https://en.wikipedia.org/wiki/Critical_exponent) and the [Wilson–Fisher fixed point](https://en.wikipedia.org/wiki/Wilson%E2%80%93Fisher_fixed_point).

---

## 11. Run everything

The complete numerical tour — convergence tables, the meta-theorem against four rivals, the strict tower, both counterexamples, the half-space theorem, the Condorcet cycle, the meta-induction sequence, and the $\varepsilon$-expansion — in one self-contained script.

{{demo:0}}

---

## 12. What to take away

1. **Wrongness is a convergent series**, controlled uniformly across all phenomena at once.
2. **An approximately correct theory beats every imperfect rival** on the entire region where that rival is bad — with a window chosen before knowing who the rival is.
3. **The tower of deliberate truncations is strictly ordered**: each knowingly-wrong approximation beats the one below it.
4. **All of this holds only inside an explicit window**, and demonstrably fails outside it.
5. **No theory is inferior in every world**, and predictive superiority cannot be aggregated into any consistent global ranking.

"All models are wrong, but some are useful." What the mathematics adds is the quantifier structure: *how* wrong, on *which* phenomena, compared to *whom*, and — crucially — within *what window*.

<details>
<summary><b>Open problems, if you want to push further</b></summary>

**Optimal truncation for divergent series.** Replace the geometric bound $|a_n| \le Br^n$ by the factorial one $|a_n| \le B\,n!\,r^n$ that actually occurs in quantum field theory. Conjecturally the strict chain *terminates* at an order $N^*(\varepsilon) \asymp 1/(r|\varepsilon|)$, with residual error $O(e^{-1/(r|\varepsilon|)})$. The mechanism is visible: the decisive inequality reverses once coefficient growth beats geometric decay.

**Measure of the winning regions.** Put Lebesgue measure on a box of worlds over $k$ phenomena. Conjecturally the set of worlds where one theory majority-beats another always has positive measure, and for odd $k$ the two majority regions partition the box. Each pointwise favouring set is a half-space, so each majority region is polyhedral — the measures should be computable.

**Tournament semantics.** Which tournaments arise from error profiles? What is the distribution of cycle lengths? Can a Copeland- or Kemeny-style score be given a principled justification as a canonical scalarisation, given that no order exists?

</details>
