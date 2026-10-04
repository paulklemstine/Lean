# The Filter That Knew Too Much — and Why It Was No Better Than a Coin

*How a careful experiment, and three lines of algebra, closed the books on a tempting idea for speeding up the oldest factoring algorithm there is.*

---

## A number that whispers

Pick two primes, say $p = 1009$ and $q = 2003$, and multiply them: $N = 2{,}021{,}027$. Hand $N$ to a stranger and ask for the factors. The oldest method — older than Euclid's writing on it — is **trial division**: try $2$, then $3$, then $5$, and so on, until something divides. You never need to go past $\sqrt N$, because the smaller factor always lives below it. Trial division is slow, but it is honest: its cost is exactly the number of candidates you try.

For as long as people have run trial division, they have wondered whether $N$ itself might *whisper* something about its factors, enough to let you skip the hopeless candidates. And $N$ certainly does whisper. Look at $N$ modulo $3$: since neither factor is divisible by $3$, each factor is $1$ or $2$ mod $3$, and $N \bmod 3$ tells you whether the two factors have the *same* residue ($N \equiv 1$) or *different* residues ($N \equiv 2$). That is a genuine bit of information about the pair of primes. Combine several such moduli — residues mod $5$, mod $7$, quadratic characters, Frobenius classes in number fields — and you can assemble a whole "battery" of such public readings, each one computable from $N$ alone. In the research programme this article describes, a battery of these readings was measured to carry about $3.49$ bits of information about the factor pair.

Three and a half bits! That sounds like it should be worth something. A bit, after all, is the information that cuts a search space in half. Three and a half bits should cut it by a factor of roughly eleven. Even if you only captured a sliver of that, you might expect trial division to speed up by a third — and that is exactly what was predicted before the decisive experiment: a speedup of about $4/3$.

The prediction was wrong. The true conversion rate from those bits into speed is **exactly zero**. This article is the story of why.

## The experiment: a real filter and a fake one

The test was designed to be as fair as possible to the bits. First, from millions of examples, one computes the exact *posterior*: given what the battery reads on $N$, how likely is each residue class to contain the smaller factor? Then one builds a **Bayesian candidate filter**: for each reading, keep only the most probable residue classes and trial-divide only by candidates in those classes. If the bits mean anything, this filter should catch the factor more often than chance.

The crucial ingredient is a control — a **sham filter**. The sham keeps exactly the same *number* of residue classes, but chooses *which* classes by flipping coins. It knows nothing. It ignores the posterior completely.

Each filter was run on $20{,}000$ random semiprimes per cell, in five independent batches, across a series of "dials" — batteries carrying $1$ bit, more bits, all the way to the $3.49$-bit battery. The result:

> The largest difference between the real filter's success rate and the sham's, across every dial and every keep size, was $0.0075$. The batch-to-batch standard deviation was $0.0073$.

In other words, the real filter and the coin-flipping filter were statistically indistinguishable. Plotting success against the fraction of classes kept, the real and sham curves lay on top of each other along one straight line: **the success rate equals the keep rate**. Keep a third of the classes, catch the factor a third of the time — whether you chose those classes with a perfect posterior or by tossing a coin.

## Where did the bits go?

Here is the puzzle. The bits are real: $N \bmod 3$ really does distinguish "same residues" from "different residues." So how can a filter that uses them be no better than chance?

The answer is a one-line change of variables, and it is worth seeing in full.

Model the factors by their residues: $a$ for the smaller factor (the *target* — the one trial division must find) and $b$ for the cofactor, both living in a finite group $G$ — for instance, the group of invertible residues modulo some $m$. Suppose $a$ and $b$ are independent and uniformly distributed. The public number reveals only their product, $c = a \cdot b$.

Now fix the target $a$ and let the cofactor $b$ run over the whole group. The product $c = ab$ also runs over the whole group, hitting every element exactly once — multiplying by $a$ just shuffles $G$. So the map

$$(a,\, b) \;\longmapsto\; (a,\, ab)$$

is a bijection from $G \times G$ to itself. That means the pair (target, public residue) is *also* uniformly distributed over $G \times G$, which means the target and the public residue are **independent**.

Read that again, because it is the whole story. The public residue $c$ tells you a lot about the *pair* $(a, b)$ — given $c$, the pair is confined to a set of size $|G|$ instead of $|G|^2$, which is $\log_2 |G|$ bits of hard information. But it tells you *nothing at all* about $a$ by itself. Every value of $a$ remains consistent with every value of $c$; the cofactor simply adjusts to make up the difference. If $N \equiv 1 \pmod 3$, the factors are $(1,1)$ or $(2,2)$, and the target is $1$ or $2$ with equal probability. If $N \equiv 2$, they are $(1,2)$ or $(2,1)$ — and again the target is $1$ or $2$ with equal probability.

We call this **barrier 2**, the flat posterior:

> **Flat Posterior Theorem.** Let $\varphi$ be any public dial — any function of the public residue $c = ab$, however elaborate. For any dial reading $d$ and any residue class $r$, the number of factor pairs with reading $d$ whose target lies in class $r$ equals the number of public residues with reading $d$. It does not depend on $r$. So, conditioned on any reading at all, every class is equally likely to hold the target.

The information is there, but it lives entirely in the *joint* behaviour of the two factors — in the correlation "$a$ and $b$ have the same residue." Trial division does not need the pair; it needs the target. And on the target, the bits have nothing to say. The battery's capacity rides a channel that is **orthogonal** to every ordering decision.

## The keep-rate law

Once the posterior is flat, the experimental finding stops being a surprise and becomes a theorem.

Call a *filter* any rule $K$ that, after reading the public residue $c$, keeps some set $K(c)$ of candidate classes. It succeeds when the target's class is kept: $a \in K(ab)$. Count the successes over all $|G|^2$ equally likely factor pairs. Using the bijection above, counting pairs $(a,b)$ with $a \in K(ab)$ is the same as counting pairs $(a, c)$ with $a \in K(c)$ — and for each $c$ there are exactly $|K(c)|$ such $a$. So:

> **Keep-Rate Law.** The number of factor pairs on which a filter succeeds is $\sum_{c \in G} |K(c)|$, the total keep size. It depends only on how many classes are kept for each public residue, never on which ones.

Two immediate consequences match the experiment exactly:

- **Real equals sham.** Two filters that keep the same number of classes for each public residue succeed on exactly the same number of factor pairs. The posterior-ranked filter and a coin-flip keep-set of equal size are identical in performance — not approximately, but exactly, in the model.
- **Success rate equals keep rate.** If a filter always keeps $k$ of the $n = |G|$ classes, its success probability is exactly $k/n$.

And a third: if a filter discards just one class per public residue and has no fallback, it misses the target with probability **exactly $1/n$**. The experiment observed exactly this — no-fallback failure rates of $1/n$ at every dial. No class was "safer" to discard than any other.

What about cleverer uses of the bits — not filtering but *reordering*, examining likely classes first? The same bijection disposes of it:

> **Ordering Invariance.** However the order of examination is chosen from the public residue, the average position of the target in that order is exactly $(n-1)/2$, so the expected number of classes examined is $(n+1)/2$ — the same as for a plain scan.

## Paying the bill honestly

There is one more twist, and it is the reason every filter in the experiment, real or sham, actually ran at about **half** the speed of plain trial division.

A filter is not free. Before dividing $N$ by a candidate $x$, you must decide whether $x$'s class is in the keep-set — and that test (computing $x$ modulo something and looking it up) costs about as much as the division you were hoping to skip. Price each membership test at one division. Then a filter scanning up to the target pays one unit for every candidate it looks at, plus one more for every kept candidate it actually divides. That gives:

> **The 1× Cap.** Under honest accounting, the total cost of any filter is the cost of the plain scan *plus* the number of kept candidates divided. No filter — posterior-built or sham — ever beats plain trial division.

> **The 0.5× Law.** A filter that keeps every class (or, equivalently, one whose fallback eventually divides every candidate it tested) costs exactly twice the plain scan.

Since a working filter must eventually fall back to dividing the candidates it skipped, it lands at the $0.5\times$ end: a net factor-of-two *loss*. That is precisely what the measurements showed: every filter at about $0.50\times$. The pre-stated $4/3\times$ prediction was refuted; under complete accounting of the whole procedure, the sharp ceiling is $1\times$.

## How bugs pretend to be breakthroughs

Good experiments catch their own mistakes, and this one kept a ledger: nine catches in all. Two of them were serious. Two separate cost-accounting bugs produced spurious speedups above $1.5\times$ — the kind of number that launches a paper.

What exposed them was the sham. A spurious speedup that also appears for the coin-flip filter cannot be coming from the posterior. And there is a theorem behind this diagnostic:

> **Sham Co-Inflation.** If the membership test is (wrongly) left unpriced, the cost of each successful run is the number of kept classes examined up to the target. Summed over all successful runs, this equals $\tfrac12 \sum_c |K(c)|\,(|K(c)|+1)$ — again a function of keep sizes alone.

So that particular bug inflates the real filter and the same-size sham *by exactly the same amount*. When the real filter "wins" and the sham "wins" equally, the win is an artefact. The sham is not just a control; it is a bug detector.

A third catch was subtler. An early "dummy" dial, meant as a neutral baseline, turned out to carry one full bit about the target — impossible for a public dial, by the flat-posterior theorem. The culprit: it computed its reading from a random table indexed *through the factors*, not through $N$. The theory turns this into an audit rule:

> **Public-ness Audit.** Any dial that carries a nonzero amount of information about the target residue cannot be computable from the public number alone.

A leak is a certificate of cheating. The dial was rebuilt to read only $N$, and its leak vanished.

## What if the factors are not uniform?

A skeptic might object: real primes are not perfectly uniform over residue classes, and the smaller factor might prefer certain classes. Fine — let the target follow *any* prior distribution whatsoever, and keep only the assumption that the cofactor is uniform. Then:

> **$N$-Blind Optimality.** For every filter that reads the public residue, there is a filter that *ignores* it — keeping one fixed set of classes regardless of $N$, of the same size — that succeeds at least as often.

You can exploit the prior on the target. You cannot exploit $N$ on top of it.

There is exactly one place where structure *does* matter, and it marks the boundary of the theorem. If you score a filter on the wrong event — "*either* factor lies in a kept class" rather than "the *smaller* factor does" — the success count becomes $\sum_c |K(c) \cup c\,K(c)^{-1}|$, which depends on which classes are kept: a set can be chosen to cover its own "mirror" $x \mapsto c/x$. In the cyclic group of order three, the policies "always keep $\{1\}$" and "keep $\{c^2\}$" have identical true scores but unordered scores of $5$ versus $3$. Trial division must find the specific factor below $\sqrt N$, so the unordered score is the wrong one — and it is yet another way an accounting slip could manufacture a phantom speedup.

## Information without utility

There is a satisfying information-theoretic summary. For any public dial $\varphi$, the mutual information between the dial and the target residue is exactly zero bits, while the mutual information between the dial and the *pair* of residues equals the dial's full entropy. Stacking another dial onto a battery adds exactly zero further bits about the target. In the smallest example — residues mod $3$ — the public residue carries exactly one bit about the factor pair and exactly zero about the target, while the faulty factor-reading dial leaked one full bit.

That is the lesson in a sentence: **information about a system is not information about the question you are asking.** The battery's $3.49$ bits are perfectly real. They describe how the two factors relate to each other. They are silent about either factor alone. And a search for one factor can only use information about that factor.

## The question, closed

The question of whether this kind of public-residue information — the type channel and its batteries — could be converted into a trial-division speedup had been open in this research programme for some time. It is now closed, quantitatively: the conversion rate is exactly zero, the real filter equals the sham, and honest accounting caps every filter at $1\times$ and pins the full-keep filter at $0.5\times$.

A few loopholes remain worth exploring, and they are honest ones. Real semiprimes are only *approximately* equidistributed (a measured deviation of about $0.009$), so a stability version — "nearly flat implies nearly zero gain" — is the natural next theorem. The argument uses only left multiplication in a finite group, not commutativity, so it should carry over to non-abelian Frobenius classes. And the experiment used static filters; an adaptive filter that learns from each failed division is the last door to close — though a failed division removes only one class and leaves the posterior flat on the rest.

But the main door is shut. A coin, it turns out, knows exactly as much about the smaller factor of $N$ as the most carefully computed posterior. That is not a failure of cleverness. It is a theorem about multiplication.
