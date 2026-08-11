# The Price of Order: What It Really Costs to Sort

## A puzzle with a temperature

Sorting is the most domesticated of all algorithms. Every programmer meets it in
their first week; every database, spreadsheet and search engine runs it billions of
times a day. And every textbook tells the same story: to sort $n$ items with yes/no
comparisons you need about $n\log_2 n$ of them, because a binary decision tree with
$d$ levels has at most $2^d$ leaves and you must be able to reach all $n!$ possible
input orderings, so $2^d \ge n!$.

That is a statement about *time*. But sorting also costs something else, something
that has a temperature attached to it. When a physical machine sorts a list, it
destroys information: at the start, the machine's memory could have been in any of
$n!$ distinguishable arrangements; at the end, it is in one — the sorted one. Erasing
distinguishability is not free. Landauer's principle, the deepest bridge between
computation and thermodynamics, says that discarding one bit of information into an
environment at temperature $T$ requires at least $kT\log 2$ of work, where $k$ is
Boltzmann's constant. Sorting $n$ items therefore has an *ideal thermodynamic price*:

$$W_{\min} = kT\log(n!).$$

At room temperature this is a laughably small number — sorting a million items costs
less energy than a mosquito's heartbeat. But the number is exact, and the exactness
is what makes it interesting. It is a hard floor, like the speed of light, and hard
floors have structure. This article is about that structure: five sharp facts about
what sorting costs, and the surprisingly clean picture they assemble into.

The punchline, stated once and then earned: **the time cost of sorting and the
thermodynamic cost of sorting are not the same quantity, and they respond to
different things.** Time responds to how many questions you ask and how informative
each one is. Heat responds only to how much you cannot un-ask.

---

## Act I: Asking bigger questions

Start with time, but relax the rules. Real comparators do not have to be binary. A
three-way comparison — "is $a < b$, $a = b$, or $a > b$?" — is a single physical
operation on most hardware. A sorting network might branch $q$ ways at once. So fix
a **radix** $q \ge 2$: every query has at most $q$ possible answers.

Here is the clean way to think about any such algorithm. Run it on a particular input
ordering $\sigma$ and write down, in order, the answers it receives: a string of $d$
symbols from an alphabet of size $q$. Call that string the **transcript** of $\sigma$.
Now the crucial observation: the *output* of a sorting algorithm carries no
information about its input at all. Every input produces the same sorted list. So if
the algorithm is correct — if it really did determine the right permutation to apply —
then all the information distinguishing $\sigma$ from any other ordering must be
sitting in the transcript. Formally:

> **The transcript map of a correct sorter is injective.** Distinct input orderings
> produce distinct transcripts.

Everything in Act I follows from this one sentence plus counting. There are exactly
$q^d$ transcripts of length $d$ over an alphabet of size $q$, and there are $n!$
orderings, so:

> **Multiway depth lower bound.** Any correct sorting algorithm whose queries have at
> most $q$ outcomes must, in the worst case, perform at least
> $$d \;\ge\; \lceil \log_q (n!) \rceil$$
> queries.

Setting $q = 2$ recovers the classical $\lceil\log_2 (n!)\rceil \approx n\log_2 n$
bound. And this bound is not merely an artifact of a crude argument — in the
transcript model it is *achieved*: whenever $n! \le q^{\lceil\log_q(n!)\rceil}$
(which is exactly what the ceiling guarantees), there is an injection from orderings
into transcripts, hence a sorter of precisely that depth. Depth also behaves
monotonically as you'd hope: raising the radix never increases the required depth.

Here is the table for $n = 5$, where $5! = 120$:

| radix $q$ | 2 | 3 | 4 | 5 | 10 |
|---|---|---|---|---|---|
| optimal depth $\lceil\log_q 120\rceil$ | 7 | 5 | 4 | 3 | 3 |

Bigger questions, fewer of them. No surprise.

## Act II: The bill that refuses to change

Now attach a price tag. A register that can hold $q$ distinct answers stores $\log q$
nats of information; a naive physical accountant charges $kT\log q$ to clear each
query register, so a depth-$d$, radix-$q$ run costs

$$W_{\text{naive}} = d \cdot kT\log q.$$

Look at the table again through this lens, at $kT = 1$ nat: the four columns give
$7\log 2 = 4.85$, $5\log 3 = 5.49$, $4\log 4 = 5.55$, $3\log 5 = 4.83$ and
$3\log 10 = 6.91$. The depth fell by more than a factor of two from $q=2$ to $q=10$,
but the bill barely moved — and it never dropped below $\log 120 = 4.79$. That is not
a coincidence.

> **Radix independence of the work floor.** For every radix $q \ge 2$ and every
> correct sorter of depth $d$, the naive charge satisfies
> $$kT\log(n!) \;\le\; d \cdot kT \log q.$$
>
> **Optimal-radix sandwich.** For the depth-optimal sorter, and for every $q \ge 2$
> and $n \ge 2$,
> $$kT\log(n!) \;\le\; \lceil\log_q(n!)\rceil \cdot kT\log q \;<\; kT\log(n!) + kT\log q.$$

The proofs are two lines of logarithms each: from $n!\le q^d$ take logs to get
$\log(n!) \le d\log q$; for the upper end, the defining property of the ceiling is
that $q^{\,d-1} < n!$, so $(d-1)\log q < \log(n!)$.

The content, though, is a genuine physical statement. **Radix trades depth against
information per query, and the trade is exactly fair.** You can ask ten-way questions
and finish in a third of the time, but each answer register is $\log 10$ nats wide
instead of $\log 2$, and the product $d\log q$ is pinned to the interval
$[\log(n!),\ \log(n!) + \log q)$ — always above the Landauer baseline, and never more
than one query's worth above it. There is no free lunch in the query radix: the
reversible information balance of sorting does not depend on how you slice your
questions.

## Act III: What you actually have to pay for

The naive accountant, though, is overcharging — and the way in which he overcharges
is the most surprising part of the story.

Suppose your algorithm is sloppy. It performs its $d$ genuinely informative queries,
and then, out of paranoia, writes a second copy of the whole transcript into a
backup register. The transcript length has doubled. Has the heat bill doubled?

No. Not even slightly.

To see why, we need the right definition of erasure cost. A register whose contents,
across all inputs, take $N$ distinct values holds $\log N$ nats of genuinely
distinguishable state, and resetting it to a fixed blank costs

$$W_{\text{reset}} = kT \log N, \qquad N = \#\{\text{distinct values the register takes}\}.$$

This is Landauer's principle in its honest form: you pay for *distinguishability*,
not for *storage volume*. A gigabyte register that only ever holds one of two values
costs one bit to clear.

Now apply it. Duplicating the transcript maps each value $t$ to the pair $(t,t)$, and
$t \mapsto (t,t)$ is injective, so the number of distinct values is unchanged:

> **Correlated registers are thermodynamically free.** Writing the transcript twice
> costs exactly what writing it once costs. More generally, any logically redundant
> copy of information you already hold adds zero to the reset bill.

And now the sharp statement. For a *correct* sorter, the transcript map is injective
on the $n!$ orderings, so its image has exactly $n!$ elements, no matter how long or
how wide the transcript is. Therefore:

> **The reset cost of sorting is the conditional entropy of the transcript, not its
> length.** For every correct radix-$q$, depth-$d$ sorter,
> $$W_{\text{reset}} = kT\log(n!),$$
> independent of $d$ and of $q$ — and it never exceeds the naive per-register charge.

This settles a question that the naive accounting made look confusing. Pad your
algorithm with a thousand redundant comparisons, re-derive the same facts a hundred
times, keep a running log in triplicate: the transcript length balloons, the naive
bill balloons with it, and the *actual* minimum dissipated work does not move by one
nat. The only thing you can be charged for is the part of your history that you
cannot reconstruct from what you keep — and for a sorter, that part is precisely the
identity of the input permutation, worth $\log(n!)$ nats and not a drop more.

## Act IV: Two lists, one theorem

What if you have two independent jobs — sort a block of $m$ items and, separately, a
block of $n$ items? Intuitively the costs should add. They do, but something else
*multiplies*, and the interplay is the sharpest structural result in this circle of
ideas.

The erased information is additive, because logarithms turn the product of the two
ordering spaces into a sum:

$$W_{\min}(m \oplus n) = kT\log(m!) + kT\log(n!) = kT\log(m!\,n!).$$

But consider a *reversible* implementation: a machine that, instead of erasing,
repackages its input bijectively into (sorted output, retained history). Because the
output is constant, the history must determine the input, so the history map is
injective, and the history space $\mathrm{Aux}$ must satisfy

$$|\mathrm{Aux}| \;\ge\; m!\cdot n!.$$

Entropy adds; reversible state counts multiply. These are the same statement viewed
through the logarithm, which is exactly why the dichotomy is worth stating: the
additive quantity is a *cost*, the multiplicative one is a *resource*. And the
equality case has a crisp meaning:

> **Direct-sum theorem with equality case.** A reversible implementation of the
> two-block sorting task uses the minimum possible history space,
> $|\mathrm{Aux}| = m!\,n!$, if and only if its history map is a bijection — that is,
> if and only if the retained history is exactly the pair of block orderings, with no
> cross-block garbage. If the history map fails to be surjective, then strictly
> $|\mathrm{Aux}| > m!\,n!$.

The proof is the finite pigeonhole principle wearing a lab coat: an injective map
between finite sets of equal size is a bijection. But read physically, it says that
*garbage is exactly measured by unused history states*. A protocol that entangles the
two blocks — recording, say, comparisons between an element of the first block and an
element of the second — carries a history that is not simply the pair of orderings,
and it pays for it in a strictly larger state space. There is even a query-model
shadow of the same theorem: a joint radix-$q$ sorter of depth $d$ has naive charge at
least the *sum* of the two blocks' Landauer baselines.

## Act V: The surcharge for hurrying

Everything so far is a *quasistatic* accounting: the minimum work, achieved only in
the idealized limit of infinitely slow operation. Real machines run fast, and fast
machines fluctuate. What does haste cost?

Model a finite-time run as a random trajectory: a finite set of possible histories
$i$, each with probability $p_i > 0$ and a work value $W_i$. The physics comes in
through the Jarzynski equality, one of the celebrated results of modern
non-equilibrium statistical mechanics, which states that for a protocol driven
between two states with free-energy difference $F$,

$$\big\langle e^{-W/kT}\big\rangle = e^{-F/kT}.$$

Notice what this says: the *exponential average* of the work is exactly $F$, always,
no matter how violently you drive the system. It is an equality, not an inequality —
and yet the second law falls out of it immediately, because $e^{-x}$ is convex.

From this single input, three facts follow. Define the reverse weights
$p_i^R = p_i e^{-(W_i - F)/kT}$. The Jarzynski equality says precisely that these
weights sum to $1$: they are a genuine probability distribution, the time-reversed
one. Then:

> **Second law.** $\langle W\rangle \ge F$.
>
> **Strict fluctuation penalty.** If the work is not the same on every trajectory in
> the support — if the distribution has any spread at all — then $\langle W\rangle > F$
> strictly.
>
> **Exact divergence identity.** The excess is *exactly* $kT$ times a
> Kullback–Leibler divergence:
> $$\langle W\rangle - F \;=\; kT\, D\big(p \,\|\, p^R\big) \;=\; kT\sum_i p_i \log\frac{p_i}{p_i^R}.$$

The proof is a two-step dance with the inequality $\log x \le x - 1$, applied
pointwise at $x_i = e^{-(W_i - F)/kT}$; the $p$-average of the right-hand side is zero
*by Jarzynski*, and the inequality is strict unless every $x_i = 1$, i.e. unless every
$W_i$ equals $F$.

Specialized to sorting, with $F = kT\log(n!)$:

> **Fluctuation penalty for sorting.** Any finite-time stochastic sorting protocol
> whose work distribution is nonconstant on its support satisfies
> $$\langle W\rangle > kT\log(n!),$$
> and the excess is exactly $kT\,D(p\|p^R)$ — a quantitative measure of how
> distinguishable the forward run is from its time reversal.

A worked example makes it concrete. Take $n = 3$, so $F = \log 6 = 1.7918$ nats at
$kT = 1$, and a two-trajectory protocol with equal probabilities. Choose
$W_1 = \log 6 - 0.5 = 1.292$; the Jarzynski constraint then forces
$W_2 = 2.838$. The mean work is $2.065$ nats, an excess of $0.273$ over the baseline.
The reverse distribution is $p^R = (0.824, 0.176)$, and
$D(p\|p^R) = \tfrac12\log\frac{0.5}{0.824} + \tfrac12\log\frac{0.5}{0.176} = 0.273$.
Exactly. Dissipation *is* relative entropy; the identity is not an estimate.

## Act VI: When you know what to expect

One last twist. Everything above assumed the worst case, or equivalently a uniform
prior: any of the $n!$ orderings equally likely. But real data is not uniformly
scrambled. Log files are nearly sorted; sensor streams are nearly sorted with
occasional spikes; merge inputs are two sorted runs interleaved. What does knowing
the distribution buy you?

Model a sorter as before, but let it stop when it likes: its transcript is a *binary
string of variable length*, and — crucially — the algorithm must be able to tell it
has finished from the answers alone, without an external clock. That condition is
exactly the statement that the set of transcripts is **prefix-free**: no transcript
is a prefix of another. Prefix-free codes obey Kraft's inequality, and Kraft's
inequality is the gateway to Shannon's source coding theorem. So:

> **Entropy floor.** For any prior $p$ on the $n!$ orderings with all probabilities
> positive, every correct self-delimiting comparison sorter has expected comparison
> count at least the Shannon entropy
> $$H(p) = -\sum_\sigma p_\sigma \log_2 p_\sigma.$$
>
> **Achievability within one comparison.** For every such prior there exists a correct
> self-delimiting sorter with expected comparison count strictly below $H(p) + 1$ —
> and its transcript *is* its retained reversible history, so the history is compressed
> to the same entropy scale.

The gap between floor and ceiling is a single comparison, uniformly in $n$. (The
conjecture that motivated this line of work guessed an additive slack of order $n$;
the truth is $1$.) And the relationship to the factorial baseline is exactly the one
you would hope for:

> **The factorial baseline is the maximum-entropy special case.** Always
> $H(p) \le \log_2(n!)$, with equality precisely at the uniform prior; every biased
> prior is strictly cheaper, and its ideal reset work $kT\log 2 \cdot H(p)$ lies
> strictly below $kT\log(n!)$.

Take $n = 3$ and the dyadic prior
$\left(\tfrac12, \tfrac14, \tfrac18, \tfrac1{16}, \tfrac1{32}, \tfrac1{32}\right)$ on
the six orderings. Its entropy is $1.9375$ bits against the uniform $\log_2 6 = 2.585$
bits — a saving of $0.647$ bits, and because all probabilities are dyadic the optimal
code hits $1.9375$ comparisons exactly, with zero overshoot. Prior knowledge is not
just an engineering speedup. It is a discount on the thermodynamic bill, and the size
of the discount is exactly the information you had in advance.

---

## The shape of the answer

Step back and the five acts snap into a single picture.

**Time is a tree; heat is an image.** The depth of a sorting algorithm is governed by
the *capacity* of its decision tree, $q^d$, and so it depends delicately on the radix,
the adaptivity, the shape of the branching. The heat is governed by the *cardinality
of the transcript's image*, and so it depends on nothing but how much input
information you failed to reconstruct. That is why doubling the transcript is free,
why a ten-way comparator saves time but no energy, and why a biased prior saves both.

**Entropy adds where states multiply.** Independent tasks contribute additively to the
bill and multiplicatively to the reversible state space, and the point of contact —
minimal history space exactly when the history map is bijective — is a precise,
checkable definition of "this protocol carries no garbage."

**Fluctuation is a surcharge, and the surcharge is a distance.** Going fast means
having a spread of work values, and any spread at all pushes the mean strictly above
the ideal floor by exactly $kT$ times the divergence between the forward run and its
time reverse. There is no such thing as a free hurry.

**The known baseline is the ignorant baseline.** The famous $\log(n!)$ is not a law of
sorting; it is the law of sorting *when you know nothing*. Replace ignorance with a
prior and the floor drops to $H(p)$, attainable to within one comparison.

None of these facts will change how you write a `sort` call. All of them change what
you should think is going on inside the machine when you do. The comparison count is
about the questions; the heat is about the answers you cannot give back.

*Total energy involved in sorting a billion records at room temperature, at the
Landauer floor: roughly $10^{-10}$ joules. The interesting part was never the size of
the number. It was that the number exists at all, and that it knows the difference
between a question you have asked and an answer you cannot un-know.*
