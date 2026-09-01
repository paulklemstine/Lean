# How Many Positions Does a Language Need?

## A guided tour of retention knees, tokenizer taxes, and the limits of a five-number table

---

Every system that reads with a limited memory faces the same arithmetic. It has a long context in front of it, it can only afford to attend closely to part of it, and it has to decide *how much* is enough. This page is about turning that vague question into a number, discovering that the number depends on the language being read, and then finding out — precisely — how much of that dependence a measurement can actually pin down.

We will build the theory from scratch, and at each step you get a control to turn.

---

## 1. The knee: one number for "how much memory"

Sort the attention weights over a context in decreasing order. You get a profile

$$w_0 \ge w_1 \ge w_2 \ge \cdots \ge 0, \qquad \sum_i w_i = 1 .$$

The **retained mass** of the top $k$ positions is the partial sum $R(k) = \sum_{i<k} w_i$, and for a **gate** $\tau$ — the fraction of mass you insist on keeping — the **knee** is

$$k^*(\tau) = \min\{\,k : R(k) \ge \tau\,\}.$$

That is the whole definition. It behaves the way you would hope: $R$ is nondecreasing, so once you are past the knee you stay past it; a profile with a heavier head has an earlier knee; and if every weight is at most $p$ then $k^* \ge \tau/p$, because you cannot accumulate mass faster than $p$ per position.

<details>
<summary><b>Click for the formal statements about the knee</b></summary>

**Monotonicity.** If $w_i \ge 0$ for all $i$ then $R$ is nondecreasing, since $R(b) - R(a)$ is a sum of nonnegative terms for $a \le b$.

**Specification.** If some cut-off clears the gate, then $\tau \le R(k^*(\tau))$ and $\tau > R(j)$ for every $j < k^*(\tau)$. This is just the statement that the least element of a nonempty set of naturals belongs to the set and is minimal in it.

**Characterisation.** Conversely, if $\tau \le R(n)$ and $\tau > R(j)$ for all $j<n$, then $k^*(\tau) = n$. This is the tool we use to *compute* knees in proofs.

**Domination.** If $R_w(k) \le R_v(k)$ for all $k$, then $k^*(v,\tau) \le k^*(w,\tau)$: a heavier head means an earlier knee.

**Self-calibration.** If all weights are strictly positive then $R$ is strictly increasing and $k^*(R(k)) = k$ exactly. Every cut-off is the knee of its own retained mass — a fact we will exploit later to prove a rigidity theorem.
</details>

Here is the measurement that started all this. At a fixed context of $1024$ positions and a gate of $0.98$:

| domain | code | English prose | mathematics | German prose | French prose |
|---|---|---|---|---|---|
| $k^*$ | $12$ | $20$ | $20$ | $24$ | $40$ |

Look carefully. German is English **plus four**. French is English **times two**. Those are different kinds of statement, and the rest of this page is about why they cannot both come from one mechanism.

{{visualization:0}}

---

## 2. Two taxes, and only two

There are two clean ways a change of domain can push the knee outward.

**A delay.** Suppose a domain prepends $d$ positions carrying no information — boilerplate, markup, a segmentation quirk. Formally $(\mathrm{delay}_d w)_i = 0$ for $i<d$ and $w_{i-d}$ otherwise. Then for **every** positive gate,

$$k^*(\mathrm{delay}_d\,w,\ \tau) = d + k^*(w,\tau).$$

Exactly $d$, at every gate. That is the precise content of a "$+4$" law.

**A slower tail.** Now take the geometric profile $w_i = (1-r)r^i$, whose retained mass is $R(k) = 1-r^k$. Reparametrise the gate by the **tail budget** $t = 1-\tau$; then the knee is the least $k$ with $r^k \le t$, which we write $k_{\mathrm{geom}}(r,t)$. Comparing a profile of ratio $r$ with one of ratio $r^m$:

$$k_{\mathrm{geom}}(r^m,\ t) \;=\; \left\lceil \frac{k_{\mathrm{geom}}(r,t)}{m} \right\rceil .$$

That is the "$\times 2$" law, and note the ceiling — it will matter enormously.

<details>
<summary><b>Click to reveal the proof of the root law (it is three lines)</b></summary>

The key is that both knees are characterised by their *down-sets*. For any $n$,
$$k_{\mathrm{geom}}(r^m,t)\le n \iff (r^m)^n \le t \iff r^{mn}\le t \iff k_{\mathrm{geom}}(r,t)\le mn \iff \left\lceil \frac{k_{\mathrm{geom}}(r,t)}{m}\right\rceil \le n,$$
the last step being the defining adjunction of ceiling division ($\lceil a/m\rceil \le n \iff a \le mn$). Two natural numbers with the same down-set are equal. $\blacksquare$

Notice what the proof does *not* use: no logarithms, no asymptotics, no approximation. The law is exact.
</details>

Now turn the knobs. Watch what happens to the gap between the two knees as you tighten the gate — and compare it with the delayed curve, which keeps a constant distance forever.

{{interactive_demo:0}}

The thing you just discovered has a name and a proof.

> **No fixed additive tax.** For any genuine root tax with $m \ge 2$ and any bound $N$, there is a gate at which the fine knee exceeds the coarse one by more than $N$. Consequently, for any fixed $d$ there is a gate at which the additive prediction $d + k_{\mathrm{coarse}}$ is simply wrong.

The witness is beautifully simple: take the tail budget $t = r^{mN+m}$. Then the fine knee is exactly $mN+m$ and the coarse one is exactly $N+1$, and $N + (N+1) \le mN+m$ whenever $m \ge 2$.

{{visualization:1}}

---

## 3. Closed form, and a prediction you can falsify

Behind the integer knee lies a real number that behaves perfectly. For a geometric profile, define the **ideal knee**

$$\kappa(r,t) = \frac{\log t}{\log r},$$

the exact real cut-off at which the tail budget is spent. Then the integer knee is its ceiling, and in particular

$$\kappa(r,t) \le k_{\mathrm{geom}}(r,t) < \kappa(r,t) + 1 .$$

The integer knee never lies to you by as much as one position. And the ideal knee makes the multiplicative law exact: $\kappa(r^m,t) = \kappa(r,t)/m$, no ceiling anywhere.

That gives the single most testable statement in this whole subject. Take two domains with tail ratios $r_1$ and $r_2$. The gate-dependent factor $\log t$ cancels from the ratio of their ideal knees:

$$\frac{\kappa(r_1,t)}{\kappa(r_2,t)} = \frac{\log r_2}{\log r_1}, \qquad \textbf{independent of the gate.}$$

**The tax ratio between two domains is a pure tail invariant.** Measure the French-to-English knee ratio at one gate and you have measured it at all of them. If a re-measurement at a different gate gives a different ratio, the geometric picture is dead. This costs nothing to check — the apparatus already exists. (For background on why $\log$-scaled quantities behave this way, see [logarithm](https://en.wikipedia.org/wiki/Logarithm) and [geometric series](https://en.wikipedia.org/wiki/Geometric_series).)

---

## 4. Forty, or thirty-nine?

Here is where the ceiling earns its keep. The measured claim is "French is exactly twice English". The law says "French is $m$ times English *up to a ceiling*". How much does the ceiling hide?

Exactly this much:

> **Sharp two-sided bound.** If the fine knee is $B$ and the coarse knee is $A$ under an $m$-fold root tax, then
> $$B \;\le\; mA \;<\; B+m .$$
> The multiplicative law holds with an error strictly smaller than the multiplier itself.

Set $m=2$ and $A=20$. Then $B \le 40 < B+2$, so $38 < B \le 40$, so

$$\boxed{\ B \in \{39,\ 40\}\ }$$

and nothing else. The reported $40$ is right *up to one position*. The only thing that removes $39$ is the extra assumption that the French knee is even — a parity bit that the measurement grid $\{36,40,48,56,64\}$ can never observe, because it never tests $39$.

<details>
<summary><b>Click for the ceiling-as-interval identity, which is the engine of everything below</b></summary>

For $m \ge 1$ and $v \ge 1$,
$$\left\lceil \frac{B}{m}\right\rceil = v \iff m(v-1) < B \le mv .$$

*Proof.* $\lceil B/m\rceil \le v \iff B \le mv$, and $\lceil B/m\rceil \le v-1 \iff B \le m(v-1)$; subtract the two down-sets. $\blacksquare$

So a ceiling equation is not a point condition at all — it is a half-open interval condition. That single reframing is what turns the master-knee question of Section 6 from a search into a computation.
</details>

And what did the measurement itself actually establish, with no modelling assumptions at all? The retained masses were $0.9795$ at $k=36$ (failing the gate $0.98$) and $0.9830$ at $k=40$ (passing it), so rigorously $36 < k^* \le 40$. A coarse grid never *under*estimates the knee — it reports the least tested point at or above the truth — so measurements of this kind are always safe, only imprecise. Two further probes close the gap:

{{algorithm:2}}

---

## 5. When the multiplier is exact, everything is determined

Suppose the multiplicative law is not approximate but exact, and holds at *every* gate:

$$k^*(A,\tau) = m\,k^*(B,\tau)\qquad \text{for all } \tau > 0 .$$

Then something remarkable follows, with no geometric hypothesis whatsoever.

> **Multiplicative rigidity.** For strictly positive profiles, the hypothesis above forces
> $$R_A(mk) = R_B(k) \qquad \text{for every } k \ge 1 .$$
> The taxed retention curve, sampled at multiples of $m$, *is* the untaxed curve: a block dilation.

<details>
<summary><b>Click to reveal the proof — it is a two-line application of self-calibration</b></summary>

Fix $k\ge 1$ and take the gate $\tau = R_B(k) > 0$. By self-calibration $k^*(B,\tau) = k$, so the hypothesis gives $k^*(A,\tau) = mk$, and hence $\tau \le R_A(mk)$; that is $R_B(k) \le R_A(mk)$.

Now take the gate $\sigma = R_A(mk) > 0$. By self-calibration $k^*(A,\sigma) = mk$, so $m\,k^*(B,\sigma) = mk$, so $k^*(B,\sigma) = k$, and hence $\sigma \le R_B(k)$; that is $R_A(mk) \le R_B(k)$.

Antisymmetry finishes it. $\blacksquare$

Note the shape of the argument: the hypothesis is about knees (an inverse-function statement), and self-calibration converts it into a statement about retention (the function itself). This is why strict positivity is needed — it makes retention strictly increasing, hence invertible.
</details>

So "the tax is a clean multiplier" is not a soft statistical claim. It pins down the entire retention curve. Physically: a multiplicative tax means the language spreads the *same* information over twice as many positions, whereas an additive tax means it front-loads dead weight. Those are different pictures of what a language does to attention. The demonstration below checks the dilation numerically, along with every other law on this page:

{{demo:0}}

---

## 6. The master knee — and the limits of five numbers

Now the payoff. Suppose all five domains are one hidden **master** profile with knee $B$, and domain $j$ merely sees the master's decay ratio raised to an integer **tax exponent** $m_j$. By the root law, domain $j$'s knee is $\lceil B/m_j\rceil$. Can one $B$ generate the whole table?

Yes — take $B=120$ with exponents $(10,6,6,5,3)$:

$$\lceil 120/10\rceil = 12,\quad \lceil120/6\rceil = 20,\quad \lceil120/5\rceil = 24,\quad \lceil120/3\rceil = 40 .$$

And $120$ looks canonical, because it is $\mathrm{lcm}(20,24)$: the smallest master that divides every entry *exactly*. Case closed?

No. **Exact divisibility was never part of the law.** The law has a ceiling in it. Drop the extra demand and a smaller master works, with the very same exponents:

$$\lceil 118/10\rceil = 12,\quad \lceil118/6\rceil = 20,\quad \lceil118/5\rceil = 24,\quad \lceil118/3\rceil = 40 .$$

Slide $B$ yourself and see which values survive:

{{interactive_demo:1}}

Two theorems make this precise.

> **Minimality.** No master knee below $118$ reproduces the table — not even allowing *arbitrary* tax exponents, one freely chosen per domain.

> **Exact gauge freedom.** For the exponent vector $(10,6,5,3)$, a master $B$ reproduces the table **if and only if** $B \in \{118,119,120\}$.

<details>
<summary><b>Click to see why an a-priori infinite search is actually finite</b></summary>

The minimality claim quantifies over all positive integers $m$, which is an unbounded search. It becomes finite by one observation:

**Exponent bound.** If $\lceil B/m\rceil = v$ with $v \ge 2$, then $m \le B$. Indeed if $m > B$ then $B \le m\cdot 1$, so $\lceil B/m\rceil \le 1 < v$.

Every entry in the table is at least $2$, so for each candidate $B$ it suffices to test $m = 1,\dots,B$. The whole covering predicate is then a finite computation of $O(B)$ work per entry, and exhaustive evaluation over $B = 0,\dots,117$ shows it fails everywhere.
</details>

<details>
<summary><b>Click to see the gauge freedom derived by hand</b></summary>

Apply the ceiling-as-interval identity to each of the four equations:

| equation | interval |
|---|---|
| $\lceil B/10\rceil = 12$ | $110 < B \le 120$ |
| $\lceil B/6\rceil = 20$ | $114 < B \le 120$ |
| $\lceil B/5\rceil = 24$ | $115 < B \le 120$ |
| $\lceil B/3\rceil = 40$ | $117 < B \le 120$ |

Intersect: $117 < B \le 120$, i.e. $B \in \{118,119,120\}$. $\blacksquare$

Every interval shares the right endpoint $120$ — that is precisely why divisibility singles it out, and precisely why divisibility is a red herring: the *left* endpoints are what actually constrain, and the binding one is $117$.
</details>

{{visualization:2}}

The consequence deserves to be said flatly: **two systems, one with master knee $118$ and one with $120$, produce literally identical five-domain tables.** The measurement, however carefully repeated, cannot separate them. That is a gauge freedom, not noise — no amount of precision on those five numbers shrinks the set to a point. If you want the master knee to mean something, you need a *new* observable.

Here is the machinery, in code:

{{algorithm:0}}

{{algorithm:1}}

---

## 7. The other universe: heavy tails

Everything above lives inside one assumption — geometric decay, for which the knee grows like $\log(1/t)$. There is a second class. Consider

$$w_i = \frac{1}{(i+1)(i+2)}, \qquad R(k) = \frac{k}{k+1},$$

a [telescoping series](https://en.wikipedia.org/wiki/Telescoping_series) whose tail decays polynomially. Its knee at tail budget $t$ is about $1/t$: keep $99\%$ and you need $\sim 100$ positions; keep $99.9\%$ and you need $\sim 1000$.

> **Tail-class separation.** For every geometric ratio $r$ and every constant $C$, however large, there is a gate at which the heavy-tailed knee is at least $C$ times the geometric knee.

The two classes are separated by an *unbounded factor*, not a constant. So across tail classes there is no tax of either kind — additive or multiplicative. The "$+4$ versus $\times 2$" question only has a referent if all five domains live in the geometric class.

Which suggests the cleanest experiment available, and it needs no new apparatus: **double the context**. A geometric-class domain responds with an additive shift that saturates; a polynomial-class domain keeps scaling. Run it:

{{demo:1}}

<details>
<summary><b>Click for the analytic core of the separation theorem</b></summary>

Everything reduces to: for $0<r<1$ and any $C$, there is $n \ge 1$ with $Cn\,r^n < 1$. Write $s=1/r>1$ and $c = s-1>0$. [Bernoulli's inequality](https://en.wikipedia.org/wiki/Bernoulli%27s_inequality) gives $s^p \ge 1+pc$, hence
$$s^{2p} \ge (1+pc)^2 \ge 1 + 2pc + p^2c^2 .$$
Choose a natural $p > \max(2C/c^2,\,1)$; then $pc^2 > 2C$, so $p^2c^2 > 2Cp$ and $s^{2p} > C\cdot(2p)$. Take $n = 2p$ and invert.

Now set the gate to $\tau = 1-r^n$. The geometric knee is exactly $n$. For the heavy profile, the gate is cleared at $j$ precisely when $(j+1)r^n \ge 1$; but for every $j < Cn$ we have $(j+1)r^n \le Cn\,r^n < 1$, so all those cut-offs fail and the heavy knee is at least $Cn$. $\blacksquare$
</details>

---

## 8. What you now know

1. **Two clean mechanisms, provably distinct.** A delay of $d$ shifts the knee by exactly $+d$ at every gate; an $m$-th root of the decay ratio multiplies it by $m$ up to a ceiling. No fixed additive constant can imitate a root tax — the error is unbounded as the gate tightens.

2. **The sharp version of the headline.** With an English knee of $20$ and a square-root tax, the French knee is $39$ **or** $40$. The reported $40$ needs a parity assumption that no coarse grid can verify.

3. **Five numbers cannot pin down a master.** The admissible master knees are exactly $\{118, 119, 120\}$; $118$ is the true minimum over all exponent choices; $118$ and $120$ are observationally identical. The tidy value $120$ is an artefact of an unnecessary divisibility demand.

4. **Exact multiplicativity is rigid.** If the multiplier law holds at every gate, the taxed retention curve is the untaxed one dilated by $m$ — with no geometric assumption anywhere.

5. **Two falsifiable predictions, free.** The tax ratio between domains must be gate-independent; and doubling the context must separate logarithmic from polynomial tail classes by the *kind* of shift it induces.

The headline number turned out to be a slightly over-confident rendering of a genuinely sharp fact. That is not a failure of the measurement — it is the measurement finally becoming precise enough that the theory can say where its own blind spots are.
