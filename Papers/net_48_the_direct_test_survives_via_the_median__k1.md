# Why the Middle Number Wins

### A guided tour of quota ladders, breakdown numbers, and the theorem that makes "report the median" more than a convention

---

## 0. The question in one paragraph

You run the same experiment three times, changing only the random seed, and get three numbers:
$160$, $224$, $256$. You must publish one number. Almost everyone picks the middle. This page is
about what entitles us to that reflex — and about the moment where the reflex turns into a
theorem with an exact statement, an exact proof, and an unwelcome consequence for anyone planning
a fourth run.

By the end you will be able to state, and to test with your own numbers, the following:

> **The Calibration–Robustness Dichotomy.** In an ensemble of $n = 2r+1$ runs, a reading is
> unbiased on maximally uninformative data **if and only if** it is maximally hard to sabotage.
> Both properties hold for exactly one reading — the median — and for even $n$ both fail
> together.

---

## 1. Where the numbers came from

The measurement behind this theory is about attention sparsification. For a sequence model with
width parameter $d$ and context length $L$, keep only the $k$ largest attention weights at each
position and discard the rest. The **knee** is the least $k$ at which held-out quality is still
preserved — the compression factor you can safely deploy.

Train the same model with a different seed and the knee moves. At $(d,L) = (4,2048)$ three seeds
gave $\{160, 224, 256\}$; at $(d,L) = (4,1024)$ three others gave $\{96, 112, 128\}$. Writing
$P = dL/32$ for the natural scale of the cell ($256$ and $128$ respectively), those sets are
$$\{0.625P,\;0.875P,\;1.0P\} \qquad\text{and}\qquad \{0.75P,\;0.875P,\;1.0P\}.$$
Individual knees are wildly noisy — the long-context spread is $60\%$ — yet **both medians are
exactly $\tfrac78 P$**. Four sharp point predictions for the third long-context seed ($224$, $240$,
$256$, $192$) were all refuted by the measured $160$; the prediction about the *centre* survived
untouched.

That is the pattern this page explains.

---

## 2. From a list of runs to a ladder of readings

The first move is to stop thinking of the ensemble as a list and start thinking of it as a
**ladder**. Give each run $i$ its knee $K(i)$, and for each quota $m$ define

$$Q(m) \;=\; \text{the least budget } b \text{ at which at least } m \text{ of the } n \text{ runs clear the bar}.$$

$Q(1)$ is the best case, $Q(n)$ is the guarantee ("this budget works for everybody"), and for odd
$n = 2r+1$ the rung $Q(r+1)$ is the median. Every reporting convention you have ever seen is a
choice of rung.

{{algorithm:0}}

<details>
<summary>Why $Q(m)$ really is the $m$-th smallest reading</summary>

At least $m$ runs clear the bar at budget $b$ exactly when $b$ is at least the $m$-th smallest
knee. Taking the least such $b$ gives the $m$-th order statistic. The operational definition and
the order-statistic definition therefore agree — which is what lets us reason about *quotas* while
computing with *sorted lists*.
</details>

---

## 3. Play with it: the seed ensemble laboratory

Type in your own run readings. Choose a rung by clicking a row. Then drag the corruption slider
and watch which readings survive and which are pushed off to infinity.

{{interactive_demo:0}}

Three things are worth discovering here before we prove anything:

1. The **guarantee** rung — the maximum, the number a deployment SLA quotes — is destroyed by a
   single bad run. So is the best case.
2. With three runs, the **median is the only rung that survives one corrupted run at all**.
3. Switching from three runs to four does *not* improve that: the maximal tolerance stays at one,
   and now two rungs tie for it.

---

## 4. The first quality score: calibration

Fix a budget and model each run as clearing the bar independently with probability $p$. Then rung
$m$ sits at or below that budget exactly when at least $m$ runs clear it, so its distribution
function is the binomial upper tail

$$R_n(m,p) \;=\; \sum_{j\ge m}\binom{n}{j}p^{\,j}(1-p)^{\,n-j}.$$

Call the rung **calibrated** if $R_n(m,\tfrac12) = \tfrac12$: on maximally uninformative data —
fair coins — it says "pass" exactly half the time, so it does not lean.

> **The parity law of calibration.** $R_n(m,\tfrac12) = \tfrac12$ **iff** $2m = n+1$.
> An ensemble has a calibrated rung iff its size is odd, and then it is unique.

<details>
<summary>Click to reveal the proof (three lines, no analysis)</summary>

At $p = 1/2$ every outcome is equally likely, so $R_n(m,\tfrac12) = T(n,m)/2^n$ with
$T(n,m) = \sum_{j\ge m}\binom{n}{j}$. The substitution $j \mapsto n-j$ turns the tail
$\{j \ge m\}$ into the head $\{j \le n-m\}$ and fixes binomial coefficients, so

$$T(n,m) + T(n,\,n+1-m) = 2^{\,n}.$$

Also $T(n,\cdot)$ strictly decreases, because each step removes a positive binomial coefficient.
Now $R_n(m,\tfrac12) = \tfrac12$ says $T(n,m) = T(n,n+1-m)$, and strict monotonicity forces
$m = n+1-m$, i.e. $2m = n+1$. Conversely, if $2m = n+1$ the reflection identity reads
$2T(n,m) = 2^n$. $\blacksquare$
</details>

Even ensembles miss, and by a measurable amount. The two central rungs of a $2r$-run ensemble read

$$\tfrac12 \pm \delta_r, \qquad \delta_r = \frac{1}{2^{2r+1}}\binom{2r}{r},$$

so they *average* to exactly $\tfrac12$. That is precisely the textbook rule "the median of an even
sample is the mean of the two middle values" — not a tie-break convention, but the exact repair of
a parity defect.

<details>
<summary>How fast does the defect vanish? (Spoiler: $\pi$ appears)</summary>

The defect is squeezed between two explicit square roots,
$$\frac{1}{2\sqrt{4r+1}} \;\le\; \delta_r \;\le\; \frac{1}{2\sqrt{3r+1}},$$
both proved by induction through the central binomial recursion
$(r+1)\binom{2r+2}{r+1} = 2(2r+1)\binom{2r}{r}$. So $\delta_r\sqrt r$ lives in
$[1/(2\sqrt5),\,1/(2\sqrt3)]$, and the exact limit is
$$\delta_r\sqrt r \longrightarrow \frac{1}{2\sqrt\pi} = 0.28209\ldots$$
Consistency of the bracket with the limit is exactly the statement $3 \le \pi \le 5$, read off a
ladder of ensembles instead of a circle. And since $\delta_r \gtrsim 1/(4(r+1))$, the defects are
not even summable: even ensembles are asymptotically, but never exactly, calibrated. For more on
the constant, see [Wallis' product](https://en.wikipedia.org/wiki/Wallis_product) and
[Stirling's approximation](https://en.wikipedia.org/wiki/Stirling%27s_approximation).
</details>

---

## 5. The second quality score: the breakdown number

Now forget probability. Someone hands you $n$ readings and warns that up to $c$ are corrupted —
a diverged run, a logging bug, a throttled machine — and you do not know which.

> **Bracket.** If two readings assignments agree outside a set of $c$ runs, then
> $Q(m-c) \le Q'(m) \le Q(m+c)$: $c$ corrupted runs move a rung by at most $c$ rungs, both ways.
>
> **Sharpness.** With $m$ corrupted runs the rung collapses to $0$; with $n-m+1$ corrupted runs it
> exceeds any bound.
>
> **Hence** the breakdown number of rung $m$ is exactly $\ \beta(n,m) = \min(m-1,\;n-m)$.

<details>
<summary>Click to reveal both proofs</summary>

*Bracket.* At a budget where $m + c$ runs pass under the clean assignment, at least $m$ of those
passers are outside the corrupted set, hence still pass under the corrupted assignment; so
$Q'(m) \le Q(m+c)$. Exchange the roles of the two assignments and use monotonicity of the ladder
for the lower bound.

*Upward breakdown.* Set every corrupted run's reading to $B$. If the corrupted rung read less than
$B$, its pass set would avoid the corrupted runs entirely and hence have fewer than $m$ elements —
contradicting the defining property of a rung.

*Downward breakdown.* Set $m$ corrupted readings to $0$; the quota is met at budget $0$.
$\blacksquare$
</details>

Two immediate consequences, both of them counterintuitive if you have ever quoted a worst case:
$\beta(n,n) = 0$ and $\beta(n,1) = 0$. **Guarantees are the most fragile reading, not the safest.**

Better still, below breakdown there is no gray zone: the readings an adversary can force are
*exactly* the clean interval $[Q(m-c),\,Q(m+c)]$, both endpoints attained. The maximal bias equals
the clean spread — which is why the widget above reports an asymmetric bias like $-64/+32$ rather
than a symmetric error bar.

---

## 6. The punchline: the two scores are the same score

Put the two profiles side by side. For $n = 2r+1$:

* calibration picks $m$ with $2m = n+1$, i.e. $m = r+1$;
* robustness picks $m$ maximising $\min(m-1, n-m)$, i.e. $m = r+1$.

{{visualization:0}}

> **The Calibration–Robustness Dichotomy.** For $n = 2r+1$ and $1 \le m \le n$:
> $$R_n\!\left(m,\tfrac12\right) = \tfrac12 \quad\Longleftrightarrow\quad \beta(n,m) = r.$$

The two sides were derived from disjoint premises — a symmetry of binomial coefficients on one
side, a counting bound on adversarial corruptions on the other — and they pin the same index.
That is the whole content: "report the median" is a theorem.

And the mirror image is just as sharp. For even $n = 2r$, no rung is calibrated **and** the
maximal breakdown number $r-1$ is attained by two rungs. Parity is a single obstruction to a
canonical centre, visible on both sides at once.

{{demo:1}}

---

## 7. So: should you run a fourth seed?

This is where the theory stops being decorative. Three runs gave $\{160, 224, 256\}$; the natural
next step is a fourth. Drag its outcome and watch what you buy.

{{interactive_demo:2}}

The verdict, stated plainly:

| you go from | breakdown number | calibrated? | what you bought |
|---|---|---|---|
| 3 runs → 4 runs | $1 \to 1$ | yes → **no** | nothing, unless the fourth lands exactly on $224$ |
| 3 runs → 5 runs | $1 \to 2$ | yes → yes | a strict robustness increment and calibration restored |

**Increase ensembles by two, not one.** (A fourth run is still worth doing if your question is
about the *low tail* — whether $0.625P$ is a stable feature of the long context or an artifact of
one seed — but that is a tail experiment, and should be reported as one.)

---

## 8. How many runs would actually certify the centre?

A different question: not *which* rung, but *how many* runs make it certain. If each run clears
the bar with probability $p > 1/2$, the median rung is a
[Condorcet jury](https://en.wikipedia.org/wiki/Condorcet%27s_jury_theorem), and adding two runs
changes it by exactly one monomial:

$$R_{2r+3}(r+2,p) - R_{2r+1}(r+1,p) \;=\; \binom{2r+1}{r}\bigl(p(1-p)\bigr)^{r+1}(2p-1).$$

Telescoping gives a geometric rate, $1 - R_{2r+1}(r+1,p) \le 2(1-p)(4p(1-p))^r$, and keeping the
binomial factor instead of bounding it gives a sharpened rate. Now explore the gap between what is
true and what each bound can prove:

{{interactive_demo:1}}

At the measured frequency $p = 2/3$ and a $1\%$ target, the three answers are **$47$ (truth), $49$
(sharpened bound), $73$ (crude bound)** — and no bound dominating the sharpened rate can reach
$47$, because the sharpened rate itself exceeds $1/100$ there. The gap is a property of the proof
route, honestly priced.

{{algorithm:1}}

Meanwhile the actual three-run ensemble has median-rung miss probability
$1 - R_3(2,\tfrac23) = 7/27 \approx 26\%$. The centre is the right functional to report; it is
still a point estimate.

{{visualization:1}}

---

## 9. A conjecture that turned out to be false

Since the achievable readings form the interval $[Q(m-c), Q(m+c)]$, its **width** is the
deployment-relevant uncertainty. Is the median always narrowest?

No. Take the five readings $\{0,0,0,10,20\}$ — three runs agreeing, two stragglers. The ladder is
$(0,0,0,10,20)$, so at radius $1$ the median window is $[0,10]$, of width $10$, while the rung
below it has window $[0,0]$, of width $0$. The minimiser of the width follows the sample's
**gaps**, not its centre. (Type that sample into the laboratory in §3 and see it.)

<details>
<summary>But it is true under the hypothesis a well-behaved experiment supplies</summary>

Call a ladder **centre-minimal** if gaps nearer the middle are smaller — which is what the order
statistics of a unimodal law do. Under centre-minimality, the median window is narrowest among all
rungs, at every radius. The proof is a two-sided induction driven by an exact criterion: moving a
window outward widens it exactly when the gap it takes in exceeds the gap it lets out.

The measured sample fails the hypothesis: its gaps are $64$ and $32$, equidistant from the centre
of a three-rung ladder yet unequal. So at three runs the median's robustness is *not* explained by
narrowness — it is explained by the breakdown number, the median being the only rung with a
contamination window at all. The mechanism first bites at five runs.
</details>

---

## 10. Run the numbers yourself

Everything above is computable in a few dozen lines, with exact rational arithmetic wherever
exactness matters. The demonstration below reproduces the median law, the parity law, the defect
sandwich and its $1/(2\sqrt\pi)$ constant, the breakdown table with a brute-force adversary, the
contamination curves, the fourth-seed bias, the Condorcet crossing at $47$, and the dichotomy.

{{demo:0}}

---

## 11. What to take away

* An ensemble does not report a number; it reports a **ladder** of numbers, one per quota.
* Each rung carries two scores: does it lean on uninformative data, and how many corrupted runs
  does it survive? The first is a **parity** condition, $2m = n+1$; the second is an exact
  **count**, $\min(m-1, n-m)$.
* For odd ensembles the two scores select the same rung, and only that rung. For even ensembles
  both fail, together.
* Consequently: report the median of an **odd** ensemble; treat published guarantees as maximally
  fragile; quote the contamination interval instead of a symmetric error bar; and grow ensembles
  by two.
* And when four sharp point predictions about a single run all fail while the prediction about the
  centre holds exactly — as happened at $\tfrac78 P = 224$ — that is not luck. It is the only
  outcome the theory permits you to expect.
