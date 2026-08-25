# How Deep Should a Machine Guess? The Hidden Law Behind Fast Language Models

## A gamble that made large models usable

There is a trick, now running quietly inside almost every deployed language model, that looks like cheating and isn't.

Big models are slow because they are sequential. To produce the hundredth word of an answer, the model must first have produced the ninety-ninth. Each word costs one full pass through billions of parameters, and on a CPU that pass is agonizing. But here is the asymmetry that makes the trick possible: checking a word is nearly free compared to generating it. A large model can read and score a whole block of candidate words in a single pass, for roughly the price of generating one.

So: let a small, fast model — a *draft* model — guess the next $d$ words. Then hand all $d$ guesses to the big model at once and ask it to verify them in one pass. Wherever the big model agrees with the guess, you keep the word for free. At the first disagreement you throw away the rest of the guess and correct that one word yourself. The output is mathematically identical to what the big model would have produced alone. You have paid one verification pass and bought, on average, several words.

This is *speculative decoding*, and it is one of the rare optimizations that costs nothing in quality. But it comes with a dial, and nobody agrees where to set it.

The dial is $d$: how many tokens the draft model guesses before you stop and check. Guess too few and you waste the verification pass. Guess too many and you burn draft-model time producing words that will be discarded at the first disagreement. Somewhere in between lies an optimum, and practitioners generally find it by brute force: sweep $d$ from $1$ to $8$, time each, pick the winner.

This article is about what happens when you stop guessing where the optimum is and start *deriving* it — and about a measurement that failed in an instructive way.

## Two ways to know the same number

Suppose you have a fixed draft model, a fixed big model, and a fixed style of prompt. Two very different experiments are available to you.

The **macroscopic** experiment is the sweep: set the depth to $1$, generate a lot of text, time it. Set the depth to $2$, repeat. You end up with a throughput curve over depths and you read off its peak. This is honest but opaque: it tells you *that* depth $4$ is best without telling you *why*.

The **microscopic** experiment is different. Forget throughput. Just ask: when the draft model proposes a block of tokens, how far does the agreement typically run? Let
$$s_i = \Pr[\text{the accepted run survives past position } i],$$
so that $s_0 \ge s_1 \ge s_2 \ge \cdots$ in the physically expected regime — reaching a later position requires surviving all the earlier ones. The sequence $(s_0, s_1, s_2, \dots)$ is the **survival curve**. It is a property of the draft/target pair and the prompt register, not of your speed dial, and it contains no timing information whatsoever.

The question that motivates everything below: **can the microscopic curve predict the macroscopic peak?** If it can, the two experiments are the same experiment in disguise, and the mysterious optimum becomes a computation.

## The cost law

Here is the derivation, and it is short enough to do in your head.

If you set the depth to $d$, the expected number of tokens you get out of one verification pass is the sum of the survival probabilities up to $d$:
$$A(d) = s_0 + s_1 + \cdots + s_{d-1}.$$
(The run reaches position $i$ with probability $s_i$; summing over positions counts the expected run length. This is just the tail-sum formula for an expectation.)

What did it cost? One verification pass, which we normalize to $1$, plus the draft model's work: it had to generate $d$ tokens, and each costs some fraction $c$ of a verification pass. So the total is $1 + cd$. For the hardware in question here — a 0.5-billion-parameter draft model speculating for a 7-billion-parameter target on CPU — that fraction was measured at $c \approx 0.118$: drafting a token costs about an eighth of what verifying a block costs.

Divide the benefit by the cost and you get the **cost law**:
$$G(d) \;=\; \frac{A(d)}{1 + cd} \;=\; \frac{\sum_{i<d} s_i}{1+cd}.$$
That is the whole model. Everything that follows is an analysis of this one ratio.

## When is deeper better?

Ask the natural question: should I move from depth $d$ to depth $d+1$? A little algebra on the inequality $G(d) \le G(d+1)$ clears the denominators and leaves a single quantity, the **marginal**:
$$M(d) \;=\; s_d\,(1 + cd) \;-\; c\,A(d).$$

**The Marginal Test.** *For any nonnegative overhead $c$ and any survival curve, $G(d) \le G(d+1)$ if and only if $M(d) \ge 0$; and $G(d+1) < G(d)$ if and only if $M(d) < 0$.*

That is exact — no approximation, no asymptotics. But its real content only appears when you rearrange it. Divide through by $1+cd$:

**The Equilibrium Law.** *Deepening stops paying off exactly when*
$$s_d \;<\; c \cdot G(d),$$
*that is, when the survival probability of the next drafted token falls below the drafting cost rate times the throughput you have already achieved.*

Stare at that for a moment, because it is the sentence that closes the loop between the two experiments. On the left is a purely **microscopic** quantity: one number from the survival curve, the chance that the run reaches one more position. On the right is a purely **macroscopic** quantity: the throughput of the whole pipeline, scaled by the overhead. The optimal depth is precisely where these two cross. Micro meets macro at a single point, and that point is the answer to "how deep should I guess?"

There is an economic reading. Each extra drafted token buys an expected $s_d$ tokens of output and costs $c$ units of budget — but that budget was going to be spent producing tokens at your current rate $G(d)$, so the *opportunity cost* of the extra token is $c \cdot G(d)$ tokens. Deepen while the purchase beats the opportunity cost; stop when it doesn't. The optimal speculation depth is a market equilibrium.

## Why greedy is enough

The Marginal Test tells you about one step. It does not, by itself, tell you that the first step where things get worse is the *global* peak — for all you know the curve dips and then rises again, and the true optimum is at depth $30$.

It doesn't, and here is why. Compute how the marginal itself changes:
$$M(d+1) - M(d) \;=\; \bigl(1 + c(d+1)\bigr)\,\bigl(s_{d+1} - s_d\bigr).$$
The bracket on the left is positive. So the marginal moves in exactly the same direction as the survival curve. If acceptance decays with position — if $s_0 \ge s_1 \ge s_2 \ge \cdots$, which is what "the further you guess, the likelier you have already gone wrong" means — then the marginal is *decreasing* in $d$. It starts positive and once it goes negative it stays negative.

**Discrete Concavity.** *If the survival curve is nonincreasing, the marginal is nonincreasing in the depth.*

**Unimodality.** *Consequently the cost law is unimodal: once $G(d+1) < G(d)$, we have $G(e) \le G(d)$ for every $e \ge d$.*

**Myopic Stopping is Exact.** *The first depth at which the marginal turns negative is a global maximizer of the cost law over all depths.*

This last statement is the practical payoff. You do not need to search. You do not need to sweep. You walk up the survival curve one position at a time, applying the equilibrium test $s_d < c\,G(d)$, and the moment it fires you stop — and you are provably at the global optimum, not a local one. Greedy one-step lookahead, which is usually a heuristic, is here an exact algorithm.

And the hypothesis can be weakened almost to nothing. What the proof actually uses is not monotone decay but a **single crossing**: the marginal is nonnegative before some depth $d^\star$ and negative from $d^\star$ onward. Any curve with that property — however ragged before or after — has $d^\star$ as its global optimum. This turns out to matter enormously, for reasons we come to below.

Two more facts round out the structure theory. First, if the draft model's agreement ever runs out — if $s_i = 0$ beyond some horizon $D$ — then the marginal is strictly negative past $D$, so **a finite sweep certifies a global optimum**: you never have to wonder about depth $1000$. Second, there is a hard ceiling:

**The Speedup Ceiling.** *Since survival probabilities never exceed $1$, the cost law satisfies $G(d) < 1/c$ at every depth, for every draft model whatsoever.*

At $c = 0.118$ that is a ceiling of about $8.47$ verified tokens per verification pass. No draft model, however good, no depth, however clever, gets past it. Verification overhead alone caps speculative decoding, and the only way to raise the ceiling is to make drafting cheaper relative to verification.

## What the optimum actually depends on

The cost law is a formula, so we can interrogate it about families of survival curves.

The natural model is **geometric decay**, $s_i = r^i$: the draft model agrees with probability $r$ at each step, independently. Then $A(d) = (1-r^d)/(1-r)$, and deepening still pays as long as $r^d \ge c/(1-r)$. Taking logarithms:

**The Logarithmic Depth Law.** *For geometric survival with rate $r$, every depth below $\log\!\big((1-r)/c\big)\big/\log(1/r)$ is still improving, and once $r^d(1+cd) < c$ no deeper depth can win. The optimal speculation depth is therefore $\Theta(\log(1/c))$ as the drafting overhead vanishes.*

Halving the cost of your draft model does not double the depth you should speculate to; it adds a constant. This is a genuinely useful piece of engineering guidance, and it explains why real optimal depths cluster in the single digits rather than the hundreds. As a calibration: with the measured overhead $c = 0.118$ and a geometric acceptance rate $r = 0.8$, the globally optimal depth is exactly $7$.

What if acceptance decays much more slowly? Take the heaviest plausible tail, the **harmonic** or Zipf profile $s_i = 1/(i+1)$. Its cumulative acceptance *diverges*: guess long enough and you accept arbitrarily many tokens. Surely then you should speculate forever?

**Finite Optimum Under Divergent Acceptance.** *Even for the harmonic survival profile, a finite globally optimal depth exists.*

You should not. The benefit grows like $\log d$ while the cost grows like $1 + cd$, and linear beats logarithmic. Unbounded speculation is strictly suboptimal even when unbounded acceptance is available.

Finally, and this is the fact that dooms every attempt to publish a single recommended depth:

**No Universal Optimal Depth.** *For every candidate depth $d_0$ there exists a perfectly legitimate survival curve — nonincreasing, with all values in $[0,1]$ — for which depth $d_0+1$ strictly beats $d_0$.*

The witness is embarrassingly simple: the curve that accepts the first $d_0+1$ tokens with certainty and nothing after. Optimal depth is a property of the *workload*, not of the decoder. Which brings us to the measurement.

## The experiment, and the number that came out right

The setup: a fine sweep over depths $1$ through $8$, two registers of prompt — ordinary English prose, and source code — with a $0.5$B draft model speculating for a CPU-hosted $7$B target, greedy decoding throughout.

An earlier round of the same experiment had measured throughput directly and found the peaks: **depth 4 for prose, depth 8 for code.** Two different registers, two different optima, differing by a factor of two — exactly the register-dependence the theory predicts is unavoidable.

The new round measured something else entirely: cumulative acceptance, from which a survival curve was extracted. Then the cost-law argmax was computed on those curves, with no timing data used at all.

It returned $4$ for prose and $8$ for code. Exactly.

Let us be precise about what "exactly" buys. On the recorded prose curve, $G(4) = 3.000/1.472 \approx 2.038$ verified tokens per verification pass, against $G(3) \approx 1.581$ and $G(5) \approx 1.962$; the argmax over the swept range is $4$, strictly. On the code curve, $G(8) = 6.950/1.944 \approx 3.575$ beats $G(7) \approx 3.428$ and everything below; the argmax is $8$. And these are not merely the best over the sweep. Because the recorded curves have a single marginal crossing, and because acceptance is taken to cease past the horizon, the single-crossing theorem upgrades both to **global** optima over all depths.

The equilibrium law can be read directly off the prose data. At depth $4$ the next survival value is $s_4 = 0.119$, while $c \cdot G(4) = 0.118 \times 2.038 \approx 0.241$. The micro-quantity has fallen below the macro-quantity; the crossing has happened; stop. At depth $3$ the inequality still ran the other way. The measured optimum is *literally* the crossing point, not a coincidence of the arithmetic.

That is the closed loop: a micro-mechanism, measured without any reference to speed, predicting a macro-throughput optimum measured without any reference to acceptance. Two independent experiments, one number.

## The measurement that failed — and the theorem that explains it

Now the interesting part, because the same experiment also produced something wrong, and the wrongness is more instructive than the success.

The survival curve was not instrumented directly. It was *differenced* out of aggregate data. What the harness could report was $m(d)$, the mean acceptance per drafted token at depth $d$; since $d \cdot m(d) = A(d)$, one recovers the per-position values by
$$s_i \;=\; (i+1)\,m(i+1) \;-\; i\,m(i).$$
On exact data this is exact — it inverts the cumulative sum perfectly. On measured data it is a disaster.

The extracted prose curve contained a *negative* survival probability, and three of the sixteen extracted values across the two registers exceeded $1$. These are impossible numbers. A probability cannot be $1.05$, and it certainly cannot be $-0.03$. The extracted curve is also not nonincreasing — it rises and falls — so the hypothesis of the entire unimodality theory fails pointwise on the actual data.

Why? Because differencing amplifies noise, and here is exactly how much.

**Noise Amplification of Differencing.** *If the aggregate means carry a sup-norm error of at most $\delta$, then the differenced survival value at position $i$ can be off by as much as $(2i+1)\,\delta$ — and this bound is attained, by an alternating-sign error pattern. The cumulative statistic $d\,m(d)$, by contrast, is off by at most $d\,\delta$.*

So the estimator that people reach for instinctively — "I have cumulative numbers, I'll just difference them" — has worst-case error growing like $2i$ while the cumulative statistic it came from has error growing like $i$. The ratio of the two worst cases sits strictly between $3/2$ and $2$ at every position and tends to $2$. Differencing asymptotically doubles the noise, and it does so *before* you divide by anything, at exactly the positions ($i$ large) where the signal $s_i$ is smallest.

With only four prompts per experimental cell, the aggregate error $\delta$ was large enough that $(2i+1)\delta$ swamped the per-position signal entirely. The impossible values are not a bug in the code; they are the estimator behaving exactly as the theorem says it must.

The lesson, stated plainly: **per-position acceptance must be instrumented directly** — logged from the verifier, one position at a time — and never numerically differentiated out of small-sample aggregates. This is a general lesson about aggregate-to-pointwise inversion, not a fact about language models.

## Why the answer survived anyway

Here is the resolution, and it is the reason the successful prediction above is not luck.

The impossible per-position values are wrong. The *argmax computed from them* is right, and provably robust:

**Argmax Stability.** *Perturbing a survival curve by at most $\varepsilon$ in sup-norm perturbs the cost law at depth $d$ by at most $\varepsilon d/(1+cd)$. Consequently, if depth $d_0$ beats depth $d$ by more than the combined perturbation budget, it still beats it after the perturbation.*

Applied to the recorded data, this gives a certified robustness radius: **every survival curve within sup-distance $1/100$ of the recorded prose curve has its cost-law argmax at depth $4$, and every curve within $1/100$ of the recorded code curve has its argmax at depth $8$.** The winning margins are $0.0764$ for prose and $0.1468$ for code — comfortably wider than the jitter.

The reason is structural. The argmax depends on the survival curve only through its *partial sums*, and the differencing errors, being alternating in the worst case, largely telescope away when you sum them back up. You destroyed the individual measurements and preserved the functional of them that you cared about. The cost law is, in this precise sense, a robust statistic of a fragile estimate.

## What to take away

Three things, in increasing order of generality.

For anyone tuning a speculative decoder: stop sweeping. Instrument the survival curve, then walk up it applying the test "is $s_d$ still above $c$ times my current throughput?" The first time the answer is no, you are at the global optimum. Expect that optimum to sit near $\log(1/c)$, to differ between prose and code, and never to exceed a throughput of $1/c$.

For anyone measuring anything: the estimator you get by differencing aggregates has worst-case error $(2i+1)\delta$ where the aggregate had $d\delta$, and the bound is tight. If you need pointwise numbers, pay for pointwise instrumentation.

And for anyone who mistrusts a model that predicted the right answer from bad data: the mistrust is healthy, and the answer is a stability theorem. A prediction from noisy inputs is worth exactly as much as the robustness radius you can certify around it. Here the radius is $1/100$ and the margin is $0.0764$, so the prediction stands. That is what it means for a loop to close: not that two numbers happened to agree, but that you can say how far they would have to be pushed apart before they didn't.
