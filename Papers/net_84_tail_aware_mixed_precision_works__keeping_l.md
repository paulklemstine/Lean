# Tail-Aware Mixed Precision: A Guided Tour

*How deep should you look before you decide which numbers in a neural network you are
allowed to round?*

---

## 1. The question, in one picture

Every deployed neural network has been squeezed. The weights come out of training as
32-bit floats and almost nobody ships them that way: before a model reaches a phone or a
cheap inference server, each weight is snapped to the nearest point of a much coarser
grid. Four bits per weight — sixteen possible values, down from four billion — is
routine.

The default is to squeeze every layer equally. This tour is about why that is never
optimal, which layers deserve the extra bits, and *exactly how many* extra bits they
deserve.

Here are three measurements on a 24-layer transformer. Retained accuracy is the fraction
of prompts on which the compressed model agrees with the original.

| what was compressed to 4 bits | retained accuracy |
|---|---|
| every layer | $0.9081$ |
| every layer **except the last two** | $0.9261$ |
| **only** the last two layers | $0.9766$ |

Two layers out of twenty-four, held at full precision, buy back $1.8$ points of
agreement. And compressing *only* those two layers already costs $2.34$ points.

Keep those three numbers in mind — by the end of this page you will be able to derive
almost everything about them.

---

## 2. Where fragility lives

A network is a stack of functions applied one after another. Each layer $f_j$ has a
**Lipschitz constant** $L_j$: the largest factor by which it can stretch a distance
between two inputs, $|f_j(x) - f_j(y)| \le L_j |x-y|$.

Now perturb layer $j$ by at most $\delta_j$ — which is exactly what quantization does.
That perturbation has to travel through everything downstream, getting stretched or
squashed on the way, so it arrives at the output multiplied by

$$s(j) \;=\; \prod_{k > j} L_k .$$

This is the **sensitivity profile**, and the total certified error is
$\sum_j \delta_j\, s(j)$.

<details>
<summary><b>Click to reveal the full propagation theorem and its proof sketch</b></summary>

**Theorem (Master propagation bound).** Let $f$ be a stack of layers with Lipschitz
constants $L_j \ge 0$, and let $g$ be a second stack with $|f_j(x) - g_j(x)| \le \delta_j$
for every $j$ and every $x$. Then the two stacks, run over layers $i, \dots, i+k-1$,
produce outputs differing by at most
$$\sum_{t=0}^{k-1} \delta_{i+t}\prod_{u=t+1}^{k-1} L_{i+u}.$$

*Proof sketch.* Induct on the block length $k$. Split the discrepancy at the first layer:
$$|F(f_i x) - G(g_i x)| \;\le\; \underbrace{|F(f_i x) - F(g_i x)|}_{\text{one perturbation, amplified}} \;+\; \underbrace{|F(g_i x) - G(g_i x)|}_{\text{inductive hypothesis}},$$
where $F$ and $G$ are the remaining blocks. The first term is at most
$\delta_i \prod_{k>i} L_k$ because a composition of Lipschitz maps is Lipschitz with the
product constant; the second is the bound for a block one layer shorter. ∎

</details>

And now the punchline, which is almost embarrassingly simple. Suppose the network is
**non-expansive**: $L_j \le 1$ for every layer, so nothing amplifies distances. This is
the normal regime for a trained transformer — normalization layers exist precisely to
keep activations from blowing up. Then $s(j)$ is a product of *fewer and fewer* numbers
that are each at most $1$ as $j$ grows, so:

> **Tail-Dominance Theorem.** In a non-expansive stack, $s(0) \le s(1) \le \cdots \le
> s(n-1) = 1$. The sensitivity profile increases with depth and attains its maximum,
> exactly $1$, at the last layer — which has nothing downstream to damp it.

Errors made early get filtered by the rest of the network. Errors made at the end go
straight out the door.

There is a mirror image that keeps this from becoming a slogan. If every layer
*expands*, $L_j \ge 1$, the ordering reverses exactly and the **head** becomes the
sensitive end.

> **Precision Dichotomy.** Which end of a network deserves precision is decided by
> whether the layers contract or expand — not by a universal rule about deep networks.

{{visualization:0}}

---

## 3. Play with it: the water-filling allocator

Before we prove the allocation law, get a feel for it. The widget below lets you set the
depth, the contraction factor $\lambda$, the total bit budget, and an extra sensitivity
bump on the final pair. It draws the sensitivity profile, the optimal bit ladder, the
deployable integer widths, and the price you pay for using uniform precision instead.

Things worth trying:

* Slide $\lambda$ from $0.99$ down to $0.70$ and watch the optimal ladder tilt from flat
  to steep. **Contraction strength is the only thing that sets the slope.**
* Push $\lambda$ above $1.0$. The ladder flips: the head now gets the bits.
* Raise the *tail bonus* and watch the last two layers jump by exactly $\log_2$ of the
  bonus — never more, never less.
* Increase the budget and watch every width rise by the same amount. Extra budget is
  shared **equally**; only the *differences* depend on sensitivity.

{{interactive_demo:0}}

---

## 4. The law behind the widget

A $b$-bit uniform quantizer on a weight block spanning a range $R$ produces a deviation
of about $R\,2^{-b}$: every extra bit halves the grid spacing. Feeding this into the
propagation bound gives the certified cost of an allocation,

$$\mathrm{cost}(b) \;=\; \sum_i c_i\, 2^{-b_i}, \qquad c_i = s(i)\,R_i > 0,$$

subject to a budget $\sum_i b_i = B$.

<details>
<summary><b>Click to reveal the optimality proof (it is two lines of AM–GM)</b></summary>

Set $z_i = c_i 2^{-b_i} > 0$. The [arithmetic–geometric mean inequality](https://en.wikipedia.org/wiki/AM%E2%80%93GM_inequality)
with uniform weights $1/n$ says
$$\prod_i z_i^{1/n} \;\le\; \frac1n \sum_i z_i \;=\; \frac{\mathrm{cost}(b)}{n}.$$
The left side is *fixed by the budget alone*, because $\prod_i 2^{-b_i} = 2^{-\sum_i b_i}
= 2^{-B}$. Hence
$$\mathrm{cost}(b) \;\ge\; n\Big(\prod_i c_i\Big)^{1/n} 2^{-B/n}.$$

Equality in AM–GM holds exactly when all the $z_i$ are equal — that is, when every block
contributes the *same* amount to the certified error. Solving $c_i 2^{-b_i} = \text{const}$
subject to the budget gives
$$b^\star_i = \frac{B}{n} + \log_2 c_i - \frac1n\sum_j \log_2 c_j,$$
and a direct computation confirms both that $\sum_i b^\star_i = B$ and that every term
equals $(\prod_j c_j)^{1/n} 2^{-B/n}$. ∎

</details>

> **Bit-Budget Lower Bound.** Every allocation of budget $B$ satisfies
> $\mathrm{cost}(b) \ge n(\prod_i c_i)^{1/n} 2^{-B/n}$, and the *water-filling*
> allocation $b^\star_i = B/n + \log_2 c_i - \frac1n\sum_j\log_2 c_j$ spends exactly the
> budget and attains the bound.

Two readings. The only aggregate of the sensitivities that obstructs compression is their
**geometric mean**. And the budget enters only through $2^{-B/n}$: one extra bit per
block halves the achievable error, no matter how the sensitivities are arranged.

The consequence that matters is what happens when you subtract two entries — the budget,
the depth, and every other block cancel:

$$\boxed{\;b^\star_i - b^\star_j = \log_2\frac{c_i}{c_j}\;}$$

**Precision is the logarithm of robustness.** A block $4\times$ more fragile deserves
exactly two more bits; $256\times$ deserves exactly eight. And since sensitivity increases
with depth in a non-expansive stack, so does $b^\star$: tail-aware mixed precision is
*derived*, not chosen.

For a uniformly contracting stack, $s(k) = \lambda^{n-1-k}$, the ladder is a straight
line: $b^\star_j - b^\star_i = (j-i)\log_2(1/\lambda)$. Twenty-four layers at
$\lambda = 0.9$ means the last layer deserves $23\log_2(1/0.9) \approx 3.5$ more bits than
the first — a 4-bit body with a 7-to-8-bit tail.

{{algorithm:0}}

Hardware only implements integer widths, of course. Rounding $b^\star$ down keeps you
inside the budget, and since dropping a bit at most doubles a term, the rounded
allocation costs at most twice the ideal — a factor of two, i.e. one bit, for
deployability.

{{visualization:1}}

---

## 5. Why the tail is *one* thing, not two things

There is a second, quite different reason those last two layers travel together, and it
has nothing to do with norms.

Retained accuracy is an *agreement rate*, so behind it is a **set**: for each collection
$S$ of compressed layers, let $D(S)$ be the set of evaluation prompts on which the model
disagrees with the original. Damage is $|D(S)|$. Two hypotheses are natural:

* **Monotonicity**: compressing more breaks more, $A \subseteq B \Rightarrow D(A) \subseteq D(B)$.
* **Coverage**: $D(A\cup B) \subseteq D(A)\cup D(B)$ — every joint failure was already a
  failure of one of the parts.

<details>
<summary><b>Click to reveal the protection sandwich and its proof</b></summary>

**Theorem (Protection sandwich).** Under monotonicity and coverage, for any compressed
set $U$ and protected subset $T$,
$$0 \;\le\; \mathrm{gain}(T) = |D(U)| - |D(U\setminus T)| \;\le\; |D(T)|.$$

*Proof.* The lower bound is monotonicity applied to $U\setminus T\subseteq U$. For the
upper bound, note every element of $U$ lies either in $T$ or in $U\setminus T$, so
$U \subseteq (U\setminus T)\cup T$; monotonicity then coverage give
$|D(U)| \le |D(U\setminus T)| + |D(T)|$. ∎

Iterating the same argument one layer at a time gives the **budget bound**
$\mathrm{gain}(T) \le \sum_{i\in T}|D(\{i\})|$: under coverage, single-layer probes
upper-bound every multi-layer intervention.

</details>

Check it against the measurement: the ceiling is $0.0234$ (the tail's standalone damage),
the measured gain is $0.0180$, and the ratio is exactly $\tfrac{10}{13} \approx 76.9\%$.
Tail protection is not merely positive, it nearly saturates its provable maximum.

### The converse has teeth

If a measurement is **super-additive** — joint damage exceeds the sum of the parts —
coverage must fail, and the failure is constructive: there exist prompts in $D(A\cup B)$
lying in neither $D(A)$ nor $D(B)$. Call them **emergent**.

> **Emergent Fraction.** If the joint damage is $r$ times the sum of the separate
> damages, then at least a fraction $\frac{r-1}{r}$ of all joint failures are emergent.

A companion experiment on the same layer pair found joint *pruning* to be $7\times$
super-additive. At $r=7$: **at least six sevenths of the failures caused by disturbing
both tail layers are caused by neither of them alone.** No procedure that scores layers
one at a time can see them.

{{interactive_demo:1}}

Try the presets in the widget above. The measured quantization arms sit comfortably
inside the sandwich; the epistatic preset breaks it, and the widget reports the certified
emergent share instead.

### The prescription, as a theorem

Define the **interaction** of two layers under protection,
$$I(a,b) = E(U\setminus\{a\}) + E(U\setminus\{b\}) - E(U) - E(U\setminus\{a,b\}),$$
where $E$ is the damage functional. Then, with no hypotheses at all,
$$\mathrm{gain}(\{a,b\}) = \mathrm{gain}(\{a\}) + \mathrm{gain}(\{b\}) + I(a,b).$$
All non-additivity of protection lives in that single scalar.

<details>
<summary><b>Click to reveal why the interaction cannot be negative for an agreement metric</b></summary>

A damage functional is [**submodular**](https://en.wikipedia.org/wiki/Submodular_set_function)
when $E(X\cup Y) + E(X\cap Y) \le E(X) + E(Y)$. Applying this with $X = U\setminus\{a\}$
and $Y = U\setminus\{b\}$, and noting $X\cup Y = U$ and $X\cap Y = U\setminus\{a,b\}$
whenever $a \ne b$, gives exactly $I(a,b) \ge 0$.

And submodularity is not an assumption of convenience — it is *forced*. For a monotone
covering family, coverage gives $|D(A\cup B)| \le |D(A)\cup D(B)|$, monotonicity gives
$D(A\cap B) \subseteq D(A)\cap D(B)$, and inclusion–exclusion
$|X\cup Y|+|X\cap Y| = |X|+|Y|$ closes the argument. Submodularity of the damage follows
from the mere fact that retained accuracy *counts prompts*. ∎

</details>

> **Tail-as-One-Unit Theorem.** For a submodular damage functional, protecting a pair of
> layers jointly recovers at least as much quality as the sum of protecting each
> separately — strictly more whenever the interaction is positive.

Even the coverage-consistent measurement has a strictly positive block interaction, of
exactly $0.0054$. Two layers, one unit.

{{algorithm:1}}

---

## 6. Run the numbers yourself

The demonstration below reproduces every claim on this page numerically: the monotonicity
of the sensitivity profile and its reversal in the expansive regime; the propagation
bound against an explicit pair of layer stacks; the bit-budget lower bound against twenty
thousand random allocations; the exactness of the $\log_2$ gap; the sandwich, budget
bound, submodularity and emergent-share bound on synthetic disagreement families; and the
three measured arms in exact rational arithmetic.

{{demo:0}}

And a deployment sweep, showing how the value of tail-awareness is governed by a single
number — how strongly the network contracts:

{{demo:1}}

---

## 7. What to take away

1. **Sensitivity is a product of downstream Lipschitz constants**, so in a contracting
   network it grows with depth and peaks at exactly $1$ on the final layer. That is why
   the tail is fragile — and why in an expanding network the head would be instead.
2. **The optimal bit gap between two blocks is $\log_2$ of their sensitivity ratio.**
   Nothing else enters: not the budget, not the depth, not the other blocks.
3. **Protecting layers never hurts and never buys more than they destroy alone.** The
   measured intervention realizes $10/13$ of that ceiling.
4. **An agreement metric is automatically submodular**, so a fragile pair should be
   protected as one unit, not as two independent decisions.
5. **Super-additivity is a certificate of emergence.** A $7\times$ interaction means at
   least $6/7$ of the joint failures are invisible to any per-layer analysis.

Compression, it turns out, should not be democratic. It should be logarithmic.

---

### Further reading

* [Lipschitz continuity](https://en.wikipedia.org/wiki/Lipschitz_continuity) — the notion
  of stretch that the whole sensitivity story is built on.
* [Rate–distortion theory and reverse water-filling](https://en.wikipedia.org/wiki/Rate%E2%80%93distortion_theory)
  — where the shape of the optimal allocation comes from in information theory.
* [Submodular set functions](https://en.wikipedia.org/wiki/Submodular_set_function) — the
  discrete convexity that makes joint protection dominate separate protection.
* [Epistasis](https://en.wikipedia.org/wiki/Epistasis) — the biological origin of the word
  for interactions that neither part exhibits alone.
