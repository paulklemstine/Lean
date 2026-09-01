# The Cost of Being Balanced

## Why a fifty-fifty mixture of code and prose is the most expensive context a language model can read

There is a quiet economy inside every large language model. When a model reads a long
document, it does not attend to all of it equally. For any given question the model is
asking of its context — "what variable was this assigned to?", "who is the subject of
this sentence?" — a handful of positions carry almost all of the answer, and the rest
carry almost nothing. Engineers exploit this ruthlessly. Instead of keeping every key
vector in memory, they keep the top $k$ and throw the rest away. The question that
decides how much memory a deployment needs is simply: **how big does $k$ have to be?**

Call the answer the *knee*. Fix a tolerance — say you are willing to keep $98\%$ of the
attention mass — and the knee is the smallest budget $k$ that clears it. Pure code has a
knee. Pure prose has a knee. And the obvious guess is that a document which is half code
and half prose has a knee somewhere in between.

That guess is wrong, and this article is about how wrong, and why.

---

## The shape nobody predicted

Before running the experiment, three shapes were written down as candidates for how the
knee should respond as you slide the mixing ratio from pure code to pure prose.

- **A line.** The knee interpolates: mix the corpora, mix the budgets.
- **A dip.** Mixtures are *cheaper* — two domains share a common head of syntactic
  scaffolding, so the union needs less than either alone.
- **A ramp.** The knee climbs (or falls) monotonically as the prose fraction rises,
  because prose is intrinsically the harder of the two.

The measurement produced none of them. Both pure endpoints cost the same. Both lopsided
mixtures — three parts code to one part prose, and the reverse — cost the same as the
endpoints. And the balanced fifty-fifty mixture cost a full grid step *more* than
everything else, at both context lengths tested: 16 keys where everything else wanted 12,
20 where everything else wanted 16. A premium of $25$–$33\%$, paid for nothing except
symmetry. The mixture that also, incidentally, scored the worst full-context accuracy of
any arm in the sweep.

The response is a **bump**: flat at the sides, peaked exactly in the middle.

A bump is a strange thing to find in an engineering curve. Lines you expect. Ramps you
expect. A local maximum sitting precisely at the balance point demands an explanation
that is structural, not accidental — and that is what the rest of this article gives.
The bump is not a quirk of one corpus or one model. It is a theorem about a certain kind
of optimisation problem, and once you see the problem the right way, the bump becomes
inevitable.

---

## The right way to see the problem

Here is the whole model, and it fits in a paragraph.

A **sorted attention profile** is a sequence of positive weights
$a_0 \ge a_1 \ge a_2 \ge \cdots$ — the attention mass carried by the most important key,
the second most important, and so on. Write

$$A(n) = a_0 + a_1 + \cdots + a_{n-1}$$

for the total mass of the top $n$ keys; call it the **head mass**. In a context of $n$
keys, a budget of $k$ retains the fraction $A(\min(k,n))/A(n)$, and the knee
$k^*_a(n,\tau)$ is the least $k$ for which that fraction reaches the gate $\tau$.

Now put two domains in the same window: $m$ keys drawn from a profile $a$, and $l$ keys
drawn from a profile $b$. What does a top-$k$ selection look like now? It sorts *all*
$m+l$ weights together and takes the largest $k$. But those weights come pre-sorted
inside each domain, so a top-$k$ selection of the union is nothing more than a **choice
of how to split the budget**: take the top $j$ from domain $a$ and the top $k-j$ from
domain $b$, for the best possible $j$. Hence the head mass of the mixture is

$$H(m,l,k) \;=\; \max_{0 \le j \le k}\;\Big[\,A\big(\min(j,m)\big) + B\big(\min(k-j,\,l)\big)\Big].$$

This operation — maximise a sum over all ways of splitting a resource — is called a
**sup-convolution**, and it is the same object that governs optimal transport, the
Legendre transform, and the economics of allocating a fixed factory budget across two
product lines. That is the entire content of the mixed-domain model. Every phenomenon
below is a consequence of this one formula.

Two immediate sanity checks: set $l = 0$ and the formula collapses to the single-domain
theory, and likewise for $m = 0$. The mixing-ratio sweep really is a curve that passes
through the pure theory at both ends.

---

## Why symmetry is expensive: the sandwich

Two bounds fence the mixed knee in from above and below, and they say opposite-sounding
things that turn out to be the two halves of the bump.

**From above — you never pay more than twice.** If you buy enough keys to serve domain
$a$ to the gate on its own, and enough to serve domain $b$ to the gate on its own, then
together they certainly serve the mixture. So

$$k^*(m,l,\tau) \;\le\; k^*_a(m,\tau) + k^*_b(l,\tau).$$

The bump can never be worse than a doubling. Mixing is subadditive.

**From below — you really do have to pay for both heads.** This is the mechanism. Write
$S_a = A(m)$ and $S_b = B(l)$ for the two domains' total masses. Then

$$k^*_a\!\Big(m,\;\tau - (1-\tau)\tfrac{S_b}{S_a}\Big) \;+\; k^*_b\!\Big(l,\;\tau - (1-\tau)\tfrac{S_a}{S_b}\Big) \;\le\; k^*(m,l,\tau).$$

Read the relaxed gates carefully, because they are where the whole story lives. A mixed
context cannot be served by concentrating on one domain: whatever mass you fail to
capture in domain $b$ counts against your budget in domain $a$, so you must buy a head in
*each* domain, each to a gate only slightly relaxed from $\tau$. How slightly depends on
the **mass ratio** $S_b/S_a$.

And now the punchline is visible. If one domain is far heavier than the other, say
$S_b \ll S_a$, then the relaxed gate for $b$ becomes hugely negative, the second term
collapses to zero, and the lower bound says nothing — the light domain is free. But when
$S_a = S_b$, both relaxed gates become $2\tau - 1$, both terms fire at once, and the
lower bound reads

$$2\,k^*_a(m,\,2\tau-1) \;\le\; k^*(m,m,\tau) \;\le\; 2\,k^*_a(m,\tau).$$

At the balanced point, symmetric mixing costs a **factor of two**, not a convex
interpolation. There is no linear law that can pass through both endpoints and satisfy
this sandwich. The refutation of the straight line is not empirical; it is arithmetic.

---

## The bump, with exact numbers

Abstract bounds are one thing; an explicit curve is another. Take the cleanest possible
profile — geometric decay, $a_i = 2^{-i}$, a model context with a clean spectral gap —
and the experiment's gate $\tau = 0.98$. Then $A(n) = 2\big(1 - 2^{-n}\big)$, and
everything can be computed exactly.

For any context of at least $16$ keys, the pure knee is **exactly $6$**: six keys capture
$1 - 2^{-6} = 98.44\%$ of the mass, and five capture only $96.88\%$, which misses the
gate. Both endpoints of the sweep sit at $6$, at every context length. So far, so
symmetric.

Now mix. If *both* sides carry at least $16$ keys, the mixed knee is **exactly $12$** —
regardless of the ratio. The reason is visible in one line of arithmetic: with a budget
split as $j$ and $k-j$, the mass left behind is $2(2^{-j} + 2^{-(k-j)})$ out of a total
of $4$, so the gate demands $2^{-j} + 2^{-(k-j)} \le \tfrac{1}{25}$. At $k = 12$ the split
$(6,6)$ gives $\tfrac{1}{32} \le \tfrac{1}{25}$ and passes. At $k=11$ the *best* split
$(6,5)$ gives $\tfrac{3}{64} > \tfrac{1}{25}$ and fails. Twelve keys, not eleven, not
seven.

So the sweep on this profile is
$$6 \;\longrightarrow\; 12 \;\longrightarrow\; 12 \;\longrightarrow\; 12 \;\longrightarrow\; 6,$$
and every one of the three pre-registered shapes dies:

- **Not a line**, because a linear response would put the balanced arm at the average of
  the endpoints, $6$, and it is at $12$.
- **Not a dip**, because $12 > \max(6,6)$ — the mixture is strictly *above* both pure
  domains, not below.
- **Not a ramp**, because the sweep rises from $6$ to $12$ and falls back to $6$: it is
  neither increasing nor decreasing in the prose fraction.

The measured table has exactly this sign structure — interior never below the endpoints,
balanced arm strictly above — while being finer-grained in the interior than the
geometric model, whose knee grid is too coarse to separate $50/50$ from $75/25$.

---

## Blocks don't matter; mass does

If the bump were about *counting* blocks, then any mixture with half the keys from each
domain would be bumped. It isn't. Introduce a second domain with the same geometric
*shape* but a thousandth of the *mass*: $b_i = 10^{-3} \cdot 2^{-i}$. Give it half of all
the keys — a perfectly balanced key count. The knee stays at $6$, exactly the pure value.
Nothing happens at all.

Conversely, a genuinely massive minority domain lifts the knee to $12$. And in the other
extreme, a minority of at most $5$ keys keeps the knee at $11$ or below, strictly under
the plateau: a minority can inflate the budget by at most its own key count, since
$k^*(m,l,\tau) \le k^*_a(m,\tau) + l$.

So the ratio response has **shoulders**: flat at the sides where one domain's mass
dominates, and a plateau in the middle where the two masses are comparable. The switch
between the two regimes is governed by the mass ratio $S_b/S_a$ and nothing else. The
informal reading — "at the balanced point every code-block query attends into prose-keys
and vice versa, and cross-domain interactions are maximised" — has a precise mathematical
counterpart: the relaxed gates in the mechanism bound both become active exactly when the
masses are comparable.

---

## The peak really is at the centre

Knowing the balanced arm is bumped above the endpoints is not the same as knowing it is
the *maximum* of the whole sweep. That stronger statement is true, for every sorted
profile, and it comes from two facts that push in the same direction.

**Balanced splits have the most mass to cover.** For a decreasing profile,
$$A(m) + A(l) \;\le\; 2A(N) \qquad \text{whenever } m + l = 2N.$$
Moving keys from the majority side to the minority side trades a block of *small* weights
(deep in the majority's tail) for a block of *large* weights (near the minority's head).
Because the profile is decreasing, that trade always gains mass. Head mass is concave
along a split, and the balanced split is its maximum.

**Balanced splits offer the least head at each budget.** For any budget $k$ no larger
than twice the smaller side, $H(N,N,k) \le H(m,l,k)$. The proof is a mirroring argument:
take any allocation in the balanced context and transport it into the unbalanced one. If
the allocation fits inside the smaller side, keep it — the other side has only grown. If
it doesn't, reflect it, giving the minority side the (now small) complement. Either way
the unbalanced context does at least as well.

More to cover, less available to cover it with: the two effects compound, and the
conclusion is that the maximum of the ratio response sits exactly at $50/50$. There is a
side condition — the balanced knee must fit inside twice the smaller side, or the
mirroring has no room — and it is genuinely needed, not decorative.

There is a stronger version still. Order the splits by **imbalance**: say $(m,l)$ is more
unbalanced than $(m',l')$ when $m \le m' \le l' \le l$ and the totals agree. Then

$$k^*(m,l,\tau) \;\le\; k^*(m',l',\tau).$$

The entire sweep is monotone in the imbalance — a *Schur-concavity* phenomenon, the same
mathematical shape that governs why entropy is maximised by the uniform distribution and
why "spreading out" increases so many statistical quantities. The consequence for
engineering is sharp: the ratio response has **no interior local minima**. There is no
clever intermediate mixing ratio that is cheaper than a lopsided one. Every step you take
towards balance costs you, monotonically, until you hit the peak.

The mechanism is a single *Robin Hood* transposition: take keys from the rich side and
give them to the poor side. One such step increases the mass to be covered and decreases
the head available, and every majorisation comparison is a chain of such steps.

---

## Three domains, and the ladder that isn't

If two domains cost twice, do three cost three times? A code-plus-prose-plus-logs
workload is the obvious next question, and the model extends by nesting: the three-domain
head mass is the threefold sup-convolution, the maximum over all allocations
$j_1 + j_2 + j_3 \le k$ of $A(j_1) + B(j_2) + C(j_3)$.

For the geometric profile at gate $0.98$ with three massive domains, the answer is
**exactly $18$**. The upper bound is a construction — serve each domain to its own gate.
The lower bound is an impossibility: no allocation of $17$ keys clears the gate, because
$j_1 + j_2 + j_3 \le 17$ forces $2^{-j_1} + 2^{-j_2} + 2^{-j_3} \ge \tfrac{1}{16}$, with
the minimum attained at the balanced allocation $(6,6,5)$ — the Robin Hood phenomenon
again, now deciding an integer threshold.

So the ladder begins $6 \to 12 \to 18$, and it is very tempting to read off the law
"$6d$ keys for $d$ domains". **That reading is false**, and the general theory says
exactly where it breaks.

The key is a *tangent line*. For every integer $j \ge 0$,
$$\frac{7-j}{64} \;\le\; 2^{-j},$$
with equality precisely at $j = 5$ and $j = 6$ — the chord through those two points of
the exponential curve, lying below it everywhere. Sum the inequality over $d$ domains
with allocations totalling $k$: whatever you do, the mass left behind is at least
$\frac{7d-k}{64}$ of the tail. The gate $\tau = 0.98$ demands the leftover be at most
$\frac{d}{50}$, and combining the two gives

$$k \;\ge\; \frac{143\,d}{25} \;=\; 5.72\,d.$$

The bound is *attained*, because the tangent is tight exactly at block sizes $5$ and $6$,
and any budget between $5d$ and $6d$ can be written as a mixture of those two block
sizes. So the exact $d$-domain budget is

$$k^*(d) \;=\; \left\lceil \frac{143\,d}{25} \right\rceil.$$

The true per-domain cost is $5.72$, not $6$. And now the small-$d$ ladder is exposed as a
rounding artefact: $\lceil 5.72 d\rceil$ equals $6d$ for $d = 1, 2, 3$ only because
$0.28d < 1$ there. From $d = 4$ the two separate, and **four domains cost $23$ keys, not
$24$**. The ladder is
$$6 \;\to\; 12 \;\to\; 18 \;\to\; 23 \;\to\; 29 \;\to\; 35 \;\to\; 41 \;\to\; \cdots$$
and at $d = 25$ it lands exactly on $143$.

This is a small but instructive humiliation for extrapolation. Three data points fit a
clean integer law perfectly, and the clean integer law is wrong. Only the exact general
formula reveals that the per-domain rate was never an integer at all.

---

## What this means if you are budgeting memory

The practical reading is short and slightly alarming.

Budget tables built from pure corpora **underestimate balanced mixed workloads**. If you
profile your key budget on a code-only benchmark and again on a prose-only benchmark, and
both agree, you have learned nothing about the agentic workload that interleaves them in
equal measure — that one costs a grid step more, at every context level tested. Because
the response is monotone in imbalance and peaks at balance, the *worst case* over mixing
ratios is not at either extreme where you are likely to measure; it is exactly at the
midpoint you are least likely to test.

For multi-domain workloads the correction goes the other way. The naive rule "$d$ domains
cost $d$ times a single domain" over-provisions, mildly but systematically, from four
domains on: the true cost is $\lceil 5.72\, d \rceil$, and the gap grows linearly. There
is a genuine, quantifiable economy of scale in heterogeneity — just not the one the first
three rungs of the ladder suggest.

And the honest limits should be stated as plainly as the results. The exact numbers above
are theorems about a geometric profile with a clean spectral gap; real attention spectra
are messier, and on them the knee grid is finer, so the interior of the sweep is expected
to be shaped rather than flat. The empirical side of the story rests on one model size,
one domain pair, one block size, and two context lengths, with mixed-arm knee values
showing more draw-to-draw variance than pure-arm ones. What the theory guarantees is the
*sign* and the *shape*: the interior is never below the endpoints, the peak is at the
centre, the response is monotone in imbalance, and the ceiling is a factor of two.

---

## The idea worth keeping

Strip away the attention machinery and a single sentence survives.

*When a resource must be split between two competing demands, the balanced split is the
hardest one to serve — because it simultaneously maximises the total demand and minimises
the efficiency of every allocation.*

That is a statement about sup-convolutions, and it applies wherever one appears: cache
partitioning across concurrent processes, bandwidth allocation across streams, inventory
held against two comparable demand distributions. In each case the pure regimes are easy,
because one demand dominates and you optimise for it. It is the symmetric case, the one
that looks like the natural compromise, that costs the most.

The knee of a mixed-domain attention budget just happens to be the place where that old
principle showed up wearing modern clothes — and where, this time, someone measured it,
found a bump where three straight lines had been predicted, and then proved the bump had
to be there.
