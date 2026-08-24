# The Dial That Could Not Be a Switch

## What a rank correlation of $0.72$ can tell you about the thing you cannot see

There is a particular kind of scientific frustration that comes from measuring a number you believe but cannot explain. You run an experiment three times, with three different random seeds, and it returns $0.7192$, $0.7202$, $0.7198$. The agreement is almost embarrassing — three digits of stability. Whatever you are measuring is real. But *what* is it measuring?

This article is about one such number, and about a small piece of mathematics that turns out to answer the question completely: not by explaining what the hidden mechanism *is*, but by proving, with certainty, an entire catalogue of things it *cannot be*.

---

## The setup: counting the zeros at the end

Take a whole number and write it in binary. Look at the right-hand end and count how many zeros you find before you hit the first $1$. For $40 = 101000_2$ the answer is $3$. For $7 = 111_2$ the answer is $0$. Number theorists call this the **$2$-adic valuation**; we will simply call it $T$, the *trailing-zero count*.

$T$ is the crudest possible measure of "how divisible by two" a number is, and it has a beautifully lopsided distribution. Among integers drawn uniformly at random, half are odd, so $T = 0$ half the time. A quarter have $T = 1$. An eighth have $T = 2$. The statistic is a geometric cascade: each additional trailing zero is half as likely as the last.

Now suppose you draw integers uniformly at random with a fixed size — say, exactly $48$ bits long — and you feed each one into some downstream process. The process either produces a certain kind of structural relation or it does not; over many draws it produces one $12.5\%$ of the time. You measure the rank correlation between $T$ and that relation rate, and you get $0.7192$.

That is a *strong* correlation. Rank correlation runs from $-1$ to $1$, and $0.72$ means: knowing how many trailing zeros a number has tells you a great deal about whether the downstream process will fire.

The natural first guess is that the correlation is trivial. Perhaps the process just fires whenever $T$ is large. The relation rate is $12.5\% = 1/8$, and one-eighth of the integers have $T \geq 3$. Maybe the whole "correlation" is nothing but the statement "the process fires exactly when $T \geq 3$" — a switch, not a dial.

The mathematics below proves that this cannot be so. And it does so by an argument that never looks at the process at all.

---

## Ties are the whole story

Here is the key structural fact. Rank correlation works by replacing each observation by its position in a sorted list. But $T$ takes very few distinct values, so enormous numbers of observations tie. If we look at the low $47$ bits of our $48$-bit draws, we have $n = 2^{47}$ observations sorted into blocks:

$$2^{46} \text{ observations with } T = 0,\quad 2^{45} \text{ with } T = 1,\quad \ldots,\quad 1 \text{ with } T = 46,\quad 1 \text{ with } T = \infty .$$

We call this list of block sizes the **tie profile**. Within a block, the ranking convention assigns every observation the same *midrank*: the average of the rank positions the block occupies. So the ranked version of $T$ is a step function — it is constant across each block and jumps between them, and all of its variability lives in those jumps.

Quantify that variability by the **between-block sum of squares**, which we write $\mathrm{SSB}$: for each block, take its midrank, subtract the overall mean rank $(n+1)/2$, square, and weight by the block's size. For the trailing-zero profile this admits an astonishingly clean closed form:

$$\boxed{\ \mathrm{SSB} \;=\; \frac{n^3 - 1}{14}\ }$$

Compare it with the corresponding quantity for a *tie-free* ranking of $n$ items, which is $(n^3 - n)/12$. The ratio is $\tfrac{6}{7}$ to within a whisker. So ties in $T$ destroy exactly one-seventh of the available rank variance — and no matter how brilliantly a downstream response resolves the world, its rank correlation with $T$ can never exceed $\sqrt{6/7} \approx 0.926$. That is the classical ceiling, and $0.7192$ sits comfortably below it. No contradiction there.

The new mathematics begins with the observation that this classical ceiling answers the *wrong question*.

---

## A switch is not a refinement

The $6/7$ law describes a response that is *finer* than $T$: something that sees everything $T$ sees and more. But a relation rate of $12.5\%$ is not fine. It is coarse to the point of brutality — a single yes/no verdict on every draw.

Coarse responses obey a completely different law, and the difference matters enormously. Suppose the response marks $K$ of the $n$ observations and leaves $n - K$ unmarked. Then its squared rank correlation with $T$ satisfies

$$\rho^2 \;\le\; \frac{n \, K \, (n-K)}{4 \cdot \mathrm{SSB}},$$

with **equality precisely when the marked set is a top segment** of the $T$-ordering — that is, when the response marks the observations with the largest $T$-values and nothing else. This is the *coarse response ceiling*, and it is sharp: the greedy, perfectly aligned switch attains it exactly, and no other switch of the same rate does better.

Why does the bound have this shape? The proof turns on two clean facts. First, because midranks are constant on blocks, the centred cross moment between $T$ and any binary response depends on the response only through the total *centred rank mass* it carries — literally $\mathrm{Cov} = (n/2) \sum_j s_j (r_j - \mu)$, where $s_j$ counts how many members of block $j$ the response marks and $r_j$ is that block's midrank. Second, the response's own variance is fixed by the count alone: $\mathrm{Var} = n K (n-K)/4$. Maximising the correlation therefore means maximising a *linear* functional of the selection under a fixed budget — a greedy problem, whose answer is to spend the budget where the centred midrank is largest, at the top. The optimality argument needs nothing more sophisticated than two monotonicity inequalities and a counting identity.

Now substitute the trailing-zero profile. If the response fires at rate $p$, the ceiling becomes what we will call the **rate parabola**:

$$\boxed{\ \rho^2_{\max}(p) \;=\; \frac{7}{2}\, p\,(1-p)\, \frac{n^3}{n^3 - 1}\ }$$

The correction factor $n^3/(n^3-1)$ is astronomically close to $1$ — at $n = 2^{47}$ it differs from $1$ by about $10^{-43}$ — so for all practical purposes the ceiling is the parabola $\tfrac{7}{2}p(1-p)$: a clean inverted arch, zero at $p = 0$ and $p = 1$, peaking at $7/8$ when the response is balanced.

And here is the punchline. Put in the recorded rate $p = 1/8$:

$$\rho^2_{\max}(1/8) \;=\; \frac{49}{128}\Bigl(1 + \frac{1}{2^{141}-1}\Bigr) \;=\; 0.3828\ldots, \qquad \rho_{\max} \;=\; \frac{7}{8\sqrt{2}} \;=\; 0.61872\ldots$$

The measured value is $0.7192$. **A switch firing on one-eighth of the draws — any switch, however perfectly aligned with $T$ — tops out at $0.619$.** The measurement is not merely above the best available switch; it is above it by a margin of $0.10$, which in this business is a canyon.

The trivial explanation is dead. The relation rate is not a single-trial indicator. It must be a genuinely graded quantity, carrying more information than a yes/no verdict.

One can quantify how much more. Since $\tfrac{7}{2}p(1-p)$ is increasing on $[0, 1/2]$, a two-valued explanation of the measurement would need a rate of at least $1/4$: at $p = 1/4$ the parabola gives $0.656 > 0.517 = 0.7192^2$. **A binary story requires twice the observed relation rate.** There is no way to squeeze it in.

---

## An inversion: sometimes coarser is better

Before going on, note something counterintuitive that falls straight out of the parabola. At $p = 1/2$ the coarse ceiling is $7/8 = 0.875$, while the ceiling for an arbitrarily fine response is $6/7 = 0.857$. A single, perfectly-balanced coin flip aligned with $T$ correlates with $T$ *better* than the most refined possible response.

That looks like a paradox — how can throwing away information help? — but it is exactly right. Coarsening damages the covariance, but it damages the response's own standard deviation faster. A rank correlation is a ratio, and the denominator shrinks more than the numerator. The famous $6/7$ tie-attenuation law is therefore **not universal**: it governs refinements, not coarsenings, and a coarse response can vault over it.

The same inversion has a practical consequence for the experiment. The recorded measurement compares $T$ against a baseline: the *popcount*, the number of $1$ bits. For a refining response the popcount baseline has strictly more headroom than $T$ does — its ties are gentler, so its ceiling is higher. But the coarse ceiling is *antitone* in the between-block variance: it has $\mathrm{SSB}$ in the denominator, so a statistic with *more* rank variance has a *lower* coarse ceiling. For a rate-style response the ordering therefore flips: at every aligned split, the popcount baseline's ceiling is strictly below $T$'s. The recorded advantage of $T$ over the count baseline — between $+0.098$ and $+0.145$ across seeds — points in exactly the direction the coarse theory predicts, and in the opposite direction from what the refining theory would suggest.

---

## But maybe the response is coarse only where nothing happens

There is a real objection to all this, and it deserves a serious answer. A relation rate need not be a switch. It could be perfectly flat across the $87.5\%$ of draws where nothing happens, while resolving the interesting $12.5\%$ in exquisite detail. Such a response is not two-valued; it might have millions of levels. Does the parabola still bite?

To answer, we need a law that covers *every* partially-coarse response, not just the two-valued ones. Here it is, and it is remarkably clean.

Call a response a **coarsening** of $T$ if it is constant on groups of consecutive tie blocks — that is, it may merge adjacent $T$-levels, but it never splits one and never reorders them. Group the fine blocks into consecutive bundles; the response's own tie profile is the list of bundle totals. Then, exactly,

$$\boxed{\ \rho^2 \;=\; \frac{\mathrm{SSB}(\text{coarse profile})}{\mathrm{SSB}(\text{fine profile})}\ }$$

**The squared rank correlation is literally the fraction of the between-block variance that survives the merge.** No inequality, no approximation: an identity. The reason is a midrank collapse — the centred cross moment between the fine midranks and the coarse midranks equals the coarse sum of squares outright, because summing the fine centred masses inside a bundle rebuilds the bundle's own centred mass.

This one identity contains both earlier ceilings as special cases. Take the coarse side to be a two-bundle split and you recover the rate parabola. Take the fine side to be the tie-free ranking and you recover $6/7$. And it comes with a monotonicity: merging blocks always reduces the sum of squares (a block-by-block parallel-axis argument), so the whole ladder is ordered — finer responses can see more — and everything is capped at $1$.

Now run the objection through it. Suppose the response merges the entire bottom $1 - 2^{-t}$ of the $T$-scale into one indistinguishable lump, and is *arbitrarily fine* above the boundary. Because merging only ever loses variance, the best such response is the one that is maximally fine above the line, and its ceiling comes out exactly:

$$\rho^2 \;=\; \frac{\tfrac{7}{2}\,(2^t - 1)\,2^t\, 8^{\,b-t} \;+\; 8^{\,b-t} - 1}{8^{\,b} - 1}, \qquad n = 2^b .$$

At $t = 3$ — blindness on the recorded $87.5\%$ bulk — this equals $(197 \cdot 8^{\,b-3} - 1)/(8^{\,b} - 1)$, which converges to $197/512 = 0.38477\ldots$. The recorded seeds square to $\approx 0.5172$. So

**every response that cannot tell one no-relation draw from another — no matter how finely it resolves the relation events themselves — is capped at $\rho^2 \le 0.3848$, far below the measurement.**

The objection fails, and it fails decisively. What is more, the failure is sharply located. The same formula at $t = 2$ gives $43/64 = 0.6719$, comfortably *above* the measurement. So blindness on the bottom $75\%$ is permitted by the data, while blindness on the bottom $87.5\%$ is forbidden. There is a genuine threshold, and the measurement sits between the two rungs.

The moral is a strange and rather beautiful one. The $12.5\%$ of draws where the interesting thing happens are *not* where the information in this correlation lives. The dial is certified by the boring majority: the response must carry graded structure **inside the bulk**, on the draws where nothing happens at all.

---

## The mirror question, and a sharp asymmetry

If the bulk is indispensable, what about the tip — the rare, high-$T$ end where the relation events cluster? Symmetry would suggest it matters even more. Symmetry is wrong.

Merge the entire top $2^{-t}$ fraction of the $T$-scale into a single tie, keeping full resolution below. Something surprising happens: the cost of the merge is *exactly* the merged part's own sum of squares, with no interaction term whatsoever. The parallel-axis cross terms of the merged group coincide identically with those of the fine blocks it replaces, and cancel. The resulting ceiling is

$$\rho^2 \;=\; \frac{8^{\,b} - 8^{\,b-t}}{8^{\,b} - 1},$$

and this exceeds $7/8 = 0.875$ **for every depth $t$**, right up to merging the whole top half. At $t = 1$ it is $0.875$; at $t = 3$ it is $0.998$.

Put the two sides together and the asymmetry is stark:

- Blind on the bottom $87.5\%$: ceiling $0.385$ — the measurement is **impossible**.
- Blind on the top $50\%$: ceiling $0.875$ — the measurement is **comfortable**.

A response can throw away everything it knows about the rare, structurally interesting half of the scale and still reproduce the recorded correlation. It cannot throw away the fine structure of the common, uninteresting bulk. The information certified by a strong rank correlation against a geometrically-tied statistic lives where the mass is, not where the action is.

Once stated, this is intuitive. The between-block variance $(n^3-1)/14$ is dominated by the *big* blocks, which sit at low $T$. The top blocks are singletons and near-singletons: they are extreme in rank but they weigh almost nothing. Rank correlation is an averaged quantity, and averages listen to mass.

---

## Where does $7/2$ come from?

Every formula above carries the same constant. The sum of squares is $(n^3-1)/14$; the parabola is $\tfrac{7}{2}p(1-p)$; the bulk-blind ceiling is $197/512$ where $197 = 196 + 1 = 4 \cdot 49 + 1$. The number $7$ is everywhere.

Is it about the prime $2$? Is it an arithmetic fact about $2$-adic valuations — the fingerprint of binary?

No. And proving that it is not is, in some ways, the most satisfying part of the story.

Nothing in the derivation ever used the primality of $2$, or divisibility, or anything arithmetic. All it used was the *shape* of the tie profile: block sizes forming a geometric sequence with ratio $1/2$. So repeat the whole computation in base $q$: count trailing zero digits of a base-$q$ integer, giving blocks of sizes $(q-1)q^{b-1}, (q-1)q^{b-2}, \ldots, (q-1), 1$ on a sample of $n = q^b$. The induction goes through unchanged — at each level, the cross term of the newly added block cancels against the recentring of everything below it — and yields

$$\mathrm{SSB} \;=\; \frac{q\,(n^3 - 1)}{4\,(q^2 + q + 1)}, \qquad \rho^2_{\max}(p) \;=\; \frac{q^2+q+1}{q}\, p\,(1-p)\, \frac{n^3}{n^3-1}.$$

Set $q = 2$: the sum of squares becomes $2(n^3-1)/(4 \cdot 7) = (n^3-1)/14$, and the constant becomes $7/2$. The recorded cell is exactly the $q = 2$ member of a one-parameter family.

So $7/2$ is a **shape constant, not an arithmetic constant**. It measures the geometric ratio of the tie spectrum, and nothing else. Written suggestively,

$$C(q) \;=\; \frac{q^2+q+1}{q} \;=\; q + 1 + \frac 1q ,$$

which is strictly increasing for $q \ge 1$. That single monotonicity fact has a pleasing consequence. Coarser digit bases — slower geometric decay — give *higher* ceilings, meaning it is easier for a coarse response to reproduce a given correlation. The binary case has the smallest constant of the entire family.

**The dyadic regime is the hardest one.** Every exclusion proved above — no binary response at rate $1/8$; no bulk-blind response; a binary story needs double the rate — is therefore the *strongest* such statement available anywhere in the geometric family. The recorded experiment, by living in base $2$, happens to sit at the most demanding point of a continuum, and its negative results are correspondingly the sharpest.

---

## Why the number never moves

One last observation ties the picture together. When the experiment is repeated at different bit-lengths, the measured value barely budges. That empirical flatness now has an algebraic explanation. Every ceiling in the story equals the limit parabola $\tfrac{7}{2}p(1-p)$ up to an error of at most $2/8^{\,b}$:

$$\Bigl|\; \tfrac{7}{2}p(1-p)\tfrac{n^3}{n^3-1} \;-\; \tfrac{7}{2}p(1-p) \;\Bigr| \;\le\; \frac{2}{8^{\,b}}, \qquad n = 2^b .$$

At $b = 47$ that is $7 \times 10^{-43}$. The geometry of the tie spectrum is *self-similar*: doubling the bit-length adds one more block on the top, and the top blocks carry negligible mass. So the constraint landscape at bit-length $48$ is the constraint landscape at bit-length $30$, or $64$, to a precision no experiment will ever probe. The flatness of the bit-length scan is not a coincidence of the sampler; it is a theorem.

---

## What was actually learned

We began with three numbers agreeing to three decimals and no idea what produced them. We end without knowing what produced them — but with a precise map of the space they could have come from:

1. The measured correlation cannot come from a two-valued indicator at the observed relation rate; such an indicator caps at $0.619$, and would need double the rate to reach $0.72$.
2. It cannot come from any response that is flat across the no-relation bulk, however finely it resolves the relation events; such responses cap at $\rho^2 = 0.385$. The threshold is sharp: blindness on $75\%$ is allowed, blindness on $87.5\%$ is not.
3. It *can* come from a response totally blind on the entire top half of the scale. The information lives in the bulk, not in the tip.
4. All of this is governed by a single identity — squared correlation equals surviving variance fraction — and a single shape constant $q + 1 + 1/q$, whose value at $q = 2$ makes the observed regime the most restrictive member of its family.

There is a general lesson here, and it goes well beyond trailing zeros. Rank correlations against a heavily-tied statistic are usually treated as a nuisance to be corrected for. In fact the tie structure is a lens. Because the achievable correlation is exactly the fraction of block variance a response preserves, a *single measured number* becomes a constraint on the entire resolution structure of an unknown mechanism. You do not get to see the mechanism. But you get to rule out, rigorously and permanently, the shapes it cannot have — and that, in the end, is what evidence is for.
