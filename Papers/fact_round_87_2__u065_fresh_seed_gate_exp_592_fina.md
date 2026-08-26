# The Dial That Only Turns One Way

### A guided tour of divisibility cells: what they can measure, and what they provably cannot

---

## 0. The question, in one picture

Take the integers. Ask a handful of very simple questions about each one — *is it even? is it
divisible by 3? by 5? by 7?* — and file each integer in the box determined by its answers. With
four primes there are sixteen boxes. This page is about a single question:

> **How much can those boxes tell you?**

The answer splits cleanly in two. The boxes tell you an enormous amount about *how many* — the
sizes are exactly computable, span a factor of $\varphi(210)=48$, and are stable under every change
of scale. They tell you exactly **nothing** about *where* — and "nothing" here is a theorem with no
error term, not a measurement that came out small.

That dichotomy has a slogan: **divisibility is a rate dial, not a position dial.** By the end of
this page you will have watched both halves of it happen on screen.

<details>
<summary><strong>Where this question came from</strong> (a short scientific detective story)</summary>

An empirical study stratified a large population of integers by small-prime divisibility and
reported two effects. The first: the strata accumulated members at systematically different rates,
with a reproducible extremal pair and a spread of about $2.2\times$. The second, and the exciting
one: membership appeared to correlate with *position* in the scanned range, suggesting a genuine
positional mechanism.

The positional effect was found by sweeping about thirty strata and reporting the largest
deviation, and it rested on a single generated population. Rerun on a freshly generated,
independently checked population, it evaporated: the fresh amplitude $0.0742 \pm 0.0377$ came in
*below the measurement procedure's own measured baseline on null input*, $0.1398 \pm 0.0478$. On
the calibrated scale the two runs bracketed zero, $+1.53$ and $-1.08$ — the fingerprint of a
maximum selected over many noisy candidates. The rate effect, by contrast, replicated to within
about $2\%$.

Rather than gather a third population, the underlying object was settled outright. Everything
below is the result.
</details>

---

## 1. Cells, periods, and the rate law

**Definition.** Fix a finite set $P$ of distinct primes and put
$$L \;=\; \prod_{p\in P} p .$$
An integer $v$'s *signature* records, for each $p \in P$, whether $p \mid v$. Integers sharing a
signature form a **cell**. Because divisibility by $p$ depends only on $v \bmod p$, the whole
partition is periodic with period $L$.

**The Rate Law.** *If the signature requires the primes of $T \subseteq P$ to divide $v$ and forbids
the rest, its cell contains exactly*
$$\kappa_T \;=\; \prod_{p \in P \setminus T} (p-1)$$
*of the $L$ residues in a period.*

<details>
<summary>Click to reveal the proof</summary>

Induct on $P$. Split off one prime $q$, so $L = q L'$ with $\gcd(q, L') = 1$ because the primes are
distinct. Modulo $q$ there is exactly one residue divisible by $q$ (namely $0$) and exactly $q - 1$
that are not. The condition at $q$ is $q$-periodic and the condition at the remaining primes is
$L'$-periodic, and by the [Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)
the map $v \mapsto (v \bmod q,\, v \bmod L')$ is a bijection $[0,L) \to [0,q)\times[0,L')$. So the
joint count is the product of the two counts, which is exactly the inductive step. $\blacksquare$
</details>

Three immediate consequences, all visible in the laboratory below:

* the **all-cleared** cell is the set of integers coprime to $L$, so its rate is Euler's totient
  $\varphi(L) = \prod_p (p-1)$ — the top of the dial;
* the **all-required** cell is the multiples of $L$, rate $1$ — the bottom;
* summing $\kappa_T$ over all $2^{|P|}$ cells gives $\prod_p\big(1 + (p-1)\big) = L$: the cells
  tile a period exactly, with nothing left over.

And one that looks trivial and is not: since $2 - 1 = 1$, **the prime $2$ is a dead coordinate**.
Demanding evenness never changes any cell's rate. Hold on to that; it comes back in Section 4 with
real consequences.

---

## 2. The laboratory

Everything above and below is live here. Toggle primes to change $P$; click a row of the rate table
to select a cell; change the coprime modulus $M$ to interrogate the cell at a different scale.
Every number shown is computed by direct enumeration, not by the formula — the point is to watch
formula and count agree exactly, every time.

{{interactive_demo:0}}

**Things worth trying.**

1. Start with $P=\{2,3,5,7\}$. Note that the rows $T = \emptyset$ and $T = \{2\}$ have the *same*
   rate $48$. That is the dead coordinate.
2. Select a cell and look at panel 3. The block counts are a perfectly flat line. Not
   approximately flat — the reported drift reads exactly $0$, for every cell, every time.
3. In panel 4, pick any coprime $M$. Every residue class gets exactly $\kappa$ members. Change $M$;
   it stays exact.
4. Now switch to $P = \{3,7,13\}$ and read panel 5. Two cells collapse onto the rate $12$, because
   $(3-1)(7-1) = 12 = 13-1$. The sweep has fewer knobs than it appears to.

---

## 3. Why position is hopeless — the no-go theorem

Flatness across whole period blocks is easy: cell membership is $L$-periodic, so a window of
length $L$ starting at any multiple of $L$ sees the same thing. Formally:

**Exact Positional Flatness.** *For every $m$, the block $[mL,\,mL+L)$ contains exactly the same
number of cell members as $[0,L)$; hence $[0,mL)$ contains exactly $m\,\kappa_T$, and the ratio of
two cells' counts is independent of how many periods you observe.*

But a sceptic can ask: maybe the signal hides at a finer scale, inside a period. It cannot, and
this is the sharp statement of the whole page.

**Coprime-Statistic No-Go Theorem.** *Let $M$ be any modulus coprime to $L$ and let $Q$ be **any**
property of integers depending only on $v \bmod M$. Then over $[0, LM)$,*
$$\#\{\,v < LM : v \in C_T \text{ and } Q(v)\,\} \;=\; \kappa_T \cdot \#\{\,r < M : Q(r)\,\}.$$
*The cell and the event $Q$ are exactly independent — no error term, for every $M$, every $Q$.*

**Corollary (equidistribution).** *Each residue class mod $M$ receives exactly $\kappa_T$ members of
the cell inside $[0,LM)$.* Concretely: of the $2310$ integers below $2310$, the ones coprime to
$210$ split as $48$ in each of the eleven classes mod $11$ — $528$ in total, with zero deviation
anywhere.

<details>
<summary>Click to reveal the proof, and the one thing the theorem does <em>not</em> say</summary>

*Proof.* Cell membership is $L$-periodic, $Q$ is $M$-periodic, and $\gcd(L,M)=1$. The map
$v \mapsto (v \bmod L,\, v \bmod M)$ is a bijection $[0,LM) \to [0,L)\times[0,M)$, under which the
joint condition becomes a product condition; counts over a product are products of counts. Evaluate
the first factor by the Rate Law. $\blacksquare$

*Scope.* Coprimality is the entire content. If $\gcd(M,L) = d > 1$, a cell *does* interact with
residues mod $M$ — but only through $d$, that is, through the same divisibility conditions restated
at a coarser modulus. So the honest reading is: **the only positional information a divisibility
cell can express is the divisibility itself.** Any claim of a *distinct* positional mechanism must
live at a scale sharing a factor with $L$, and is then not a new mechanism at all.
</details>

This is what turns a failed replication into a closed question. A positional statistic measured at
a coprime scale has *identically zero* signal. Whatever amplitude such a measurement reports is
noise plus the bias of the estimator — which is exactly the diagnosis the fresh population handed
back, its raw amplitude sitting below the estimator's own null baseline.

---

## 4. Sharpening the resolution buys you nothing new

"Divisible by $3$" is the coarsest possible $3$-adic question. What if we ask the sharp one: *what
is the exact power of $3$ dividing $v$?* Fix an exponent $e_p$ for each $p \in P$ and collect the
integers with $v_p(v) = e_p$ for all $p$. The period refines to $L_e = \prod_p p^{\,e_p+1}$.

**The Valuation Ladder.** *Over the refined period $L_e$, the exact-valuation cell has exactly*
$$\prod_{p\in P}(p-1)$$
*members — **independently of the exponents**. Hence its density is the pure geometric expression*
$$\prod_{p\in P} p^{-e_p}\Bigl(1-\frac1p\Bigr).$$

Every unit of extra resolution costs exactly one factor of $p$ in density and changes nothing else.
The numerator is frozen. For $p=3$: two residues of valuation $e$ in every period $3^{e+1}$, so the
densities march $2/3,\ 2/9,\ 2/27,\dots$ forever, with $2$ on top the whole way.

<details>
<summary>Click to reveal the proof</summary>

The residues below $p^{e+1}$ divisible by $p^{e}$ are $p^{e}k$ for $0 \le k < p$; among these,
$p^{e+1}$ divides $p^{e}k$ exactly when $p \mid k$, i.e. only for $k = 0$. So exactly $p-1$ residues
have valuation precisely $e$, whatever $e$ is. Multiply across the primes with the Chinese Remainder
Theorem, as before. $\blacksquare$
</details>

The moral is a strong negative: **no new arithmetic constant appears at any depth**. An effect that
"only shows up at finer resolution" cannot be produced by the valuation structure.

---

## 5. How many tests does a sweep actually run?

Now the part with statistical teeth. A discovery sweep that examines many cells and reports the most
extreme deviation must be corrected for selection — the maximum of $n$ noise draws drifts upward
like $\sqrt{2\log n}$. But *what is $n$?*

Not $2^{|P|}$. Since $\kappa_T = \prod_{p \notin T}(p-1)$ and $2-1=1$, the set of rates a sweep can
reach is exactly the set of subset products of $\{p-1 : p \in P,\ p \neq 2\}$.

**Effective Sweep Size.** *If $2 \in P$, a sweep over all $2^{|P|}$ cells explores at most
$2^{|P|-1}$ distinct rates; and every rate divides $\varphi(L)$, so the sweep never explores free
values but a sub-family of a single divisor lattice.*

**The Sidon Criterion.** *Equality holds precisely when the numbers $p-1$ over the odd primes of $P$
have pairwise distinct subset products — i.e. when $\{p-1\}$ is a
[multiplicative Sidon system](https://en.wikipedia.org/wiki/Sidon_sequence).*

The criterion is not vacuous. For $P=\{3,7,13\}$ the shifted primes are $2,6,12$ and
$2 \cdot 6 = 12$, so two different cells carry the identical rate and the sweep tests $7$ things,
not $8$. Run the analyser on your own prime sets:

{{algorithm:0}}

<details>
<summary>Why this matters for inference, in one paragraph</summary>

A max-statistic correction using $n = 2^{|P|}$ is misspecified in two directions at once. It
overcounts distinct statistics, because some cells are literally duplicate tests; and the ones that
remain are strongly *dependent by construction*, being subset products drawn from one divisor
lattice. Neither issue is fixed by a Bonferroni factor. The honest count is a theorem about the
multiplicative combinatorics of $\{p-1\}$ — an object with no dependence on the data whatsoever.
For a thirty-cell sweep, the naive selection drift is already about $2.6\sigma$ before any real
effect exists, which is the order of the gap between a raw score of $4.11$ and a calibrated
$+1.53$.
</details>

---

## 6. Everything at once

The four panels below put the whole theory in one figure for $P = \{2,3,5,7\}$: the dial and its
extremes, the perfectly horizontal block profile, the eleven identical residue-class bars, and the
geometric valuation ladder on a log scale.

{{visualization:0}}

And here is the exhaustive check — every claim on this page, re-derived by brute-force enumeration
rather than by formula, with assertions that fail loudly if any of them is off by one:

{{demo:0}}

<details>
<summary>What the enumeration covers</summary>

All sixteen cell rates for $P=\{2,3,5,7\}$ against direct counts; the tiling identity
$\sum_T \kappa_T = L$; divisibility of every rate into $\varphi(L)$; the extremes $1$ and
$\varphi(L)$ and the dead $2$-coordinate; zero drift across twenty period blocks for three
different cells; the no-go theorem at $M=11$ for three genuinely different coprime-measurable
statistics and for all eleven residue classes; valuation cells for all exponent vectors up to
$(2,2)$; the effective sweep dimension and Sidon verdict for five prime sets, including the
colliding $\{3,7,13\}$; and the selection-drift arithmetic. A second prime set, $\{3,5,11\}$, is run
end-to-end as an independent cross-check.
</details>

---

## 7. What to take away

* **Rate: exactly knowable.** A divisibility signature multiplies density by a completely factorised
  amount $\prod_p (1 \text{ or } 1-1/p)$. That multiplier is exact, transfers unchanged across
  scales, survives $p$-adic refinement up to a pure geometric factor, lies in the divisor lattice of
  $\varphi(L)$, and spans exactly $[1,\varphi(L)]$.
* **Position: exactly nothing.** At every scale coprime to $L$, for every observable whatsoever, a
  divisibility cell is exactly independent of it. The block profile is identically flat. There is no
  positional mechanism to find.
* **And a lesson about looking.** A sweep across cells has fewer degrees of freedom than it has
  cells, and the true number is computable in closed form before any data is collected. When the
  effective count is used and the estimator is calibrated against its own null, the reported
  positional effect scores $-1.08$ — which is to say, nothing at all, exactly as the theorem
  demands.

A negative result is worth a great deal when you can prove the negative.
