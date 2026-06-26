# The Stubborn Constant: Why Euler's Number $\gamma$ Refuses to Be Pinned Down

## A number hiding in plain sight

Add up the reciprocals of the whole numbers, one at a time:

$$H_n = 1 + \frac{1}{2} + \frac{1}{3} + \frac{1}{4} + \cdots + \frac{1}{n}.$$

This is the *harmonic sum*, one of the oldest objects in mathematics. It grows — but agonizingly slowly. To push it past $10$ you need about $12{,}000$ terms; to reach $20$ you need more grains than there are in a beach. The sum drifts upward forever, never settling, never stopping.

In the 1730s, a young Leonhard Euler asked a deceptively simple question: *how fast* does it grow? He discovered that the harmonic sum tracks the natural logarithm almost perfectly. The function $\ln n$ rises at the same lazy pace, and if you subtract one from the other, the wild parts cancel and something astonishing remains — a single, fixed number:

$$\gamma = \lim_{n \to \infty} \bigl(H_n - \ln n\bigr) = 0.5772156649\ldots$$

This is the **Euler–Mascheroni constant**, usually written with the Greek letter gamma. It is the third great constant of mathematics, standing beside $\pi$ and $e$. It surfaces in the distribution of prime numbers, in the Riemann zeta function, in physics, in the analysis of algorithms. And yet, almost three centuries after Euler found it, we still do not know the answer to the most basic question one can ask about a number:

**Is $\gamma$ rational or irrational?**

Nobody knows. We know $\pi$ is irrational. We know $e$ is irrational. We have known both for over two hundred years. But $\gamma$ has resisted every attempt. If it turned out to be a fraction $p/q$, its denominator $q$ would have to be astronomically large — more than $10^{242{,}080}$ — yet no one has been able to rule out that possibility entirely.

This article is about *why* $\gamma$ is so hard to corner. The answer turns out to be beautifully concrete, and it comes from looking closely at the very sequence Euler used to define it.

## A constant trapped between two fences

The cleanest way to think about $\gamma$ is as a number caught in a vise. Define two sequences that approach it from opposite sides. The first is Euler's own:

$$a_n = H_n - \ln(n+1).$$

The second is a small variant:

$$b_n = H_n - \ln n.$$

The first sequence creeps *upward* toward $\gamma$ but always stays just below it. The second sequence drifts *downward* toward $\gamma$ but always stays just above it. Together they form a shrinking cage:

$$a_n < \gamma < b_n \qquad \text{for every } n.$$

This is genuinely useful. If you compute both fences at some value of $n$, you have *proven* that $\gamma$ lies between them — not estimated, proven. The trouble is the width of the cage. How quickly do the two fences close in on each other? That width is the whole story, because it controls exactly how well you can ever know $\gamma$ from this sequence.

## The width is a single logarithm — exactly

Here is the first clean result. The gap between the upper fence and the lower fence is not some messy expression. It collapses, perfectly, to one logarithm:

$$b_n - a_n = \ln\!\left(\frac{n+1}{n}\right).$$

The proof is a one-liner once you write it out: $b_n - a_n = \bigl(H_n - \ln n\bigr) - \bigl(H_n - \ln(n+1)\bigr) = \ln(n+1) - \ln n = \ln\frac{n+1}{n}$. The harmonic sums simply cancel. Everything about how fast we can trap $\gamma$ is encoded in this single, friendly quantity $\ln\bigl(1 + \tfrac{1}{n}\bigr)$.

So the real question becomes: how big is $\ln\bigl(1 + \tfrac{1}{n}\bigr)$?

## Squeezing the logarithm from both sides

There is a famous inequality, true for every positive $x$, that says the logarithm never rises faster than its tangent line at $1$:

$$\ln x \le x - 1.$$

It is the analytic fingerprint of *convexity* — the fact that the logarithm curve always bends downward. Apply it cleverly, twice, and the width of our cage gets pinned from above and below.

**Upper bound.** Plug $x = \frac{n+1}{n}$ into $\ln x \le x-1$. Since $\frac{n+1}{n} - 1 = \frac{1}{n}$, we get immediately

$$\ln\!\left(\frac{n+1}{n}\right) \le \frac{1}{n}.$$

This is the "easy" direction. It says the cage closes at least as fast as $1/n$.

**Lower bound.** Now plug in the *reciprocal*, $x = \frac{n}{n+1}$. This time $x - 1 = -\frac{1}{n+1}$, and because $\ln\frac{n}{n+1} = -\ln\frac{n+1}{n}$, the inequality flips into a lower bound:

$$\frac{1}{n+1} \le \ln\!\left(\frac{n+1}{n}\right).$$

This is the "informative" direction — the one that carries the punchline. It says the cage cannot close *faster* than $1/n$.

Put the two together and you have an exact verdict on the convergence rate:

$$\boxed{\;\frac{1}{n+1} \;\le\; b_n - a_n \;\le\; \frac{1}{n}\;}$$

In the language of asymptotics, the width is $\Theta(1/n)$ — it shrinks *exactly* like one over $n$, no faster and no slower. This two-sided control is the heart of the matter. A one-sided bound would only tell you the approximation is "at least this good." The lower bound tells you it is "at most this good," and that is a fundamental limitation, not a temporary failure of cleverness.

## What linear convergence costs you

Translate "$\Theta(1/n)$" into practical terms. Because $\gamma$ is trapped between the fences and the fences are $1/n$ apart, each of them approximates $\gamma$ with one-sided error smaller than $1/n$:

$$\gamma - a_n < \frac{1}{n}, \qquad b_n - \gamma < \frac{1}{n}.$$

Want $\gamma$ to ten decimal places? You need $n$ around ten *billion*. Want a hundred decimals? You need $n$ around $10^{100}$ — more steps than there are atoms in the observable universe. The elementary sequence is honest, simple, and hopelessly slow. The lower bound $\frac{1}{n+1} \le b_n - a_n$ is the rigorous proof that this slowness is unavoidable: you cannot squeeze better accuracy out of this particular sequence by waiting longer in any reasonable sense. It is the mathematical certificate behind every textbook remark that "the defining sequence for $\gamma$ converges very slowly."

This is *why* mathematicians invented "series accelerations" — clever reorganizations that converge in a handful of terms instead of a galaxy of them. The slow rate we just proved is precisely the obstruction those accelerations are designed to overcome.

## $\gamma$ as an infinite sum of tiny corrections

There is a second, complementary way to see the constant — not as a limit of a sequence, but as the total of an infinite series. Define the $k$-th term:

$$t_k = \frac{1}{k+1} - \ln\!\left(\frac{k+2}{k+1}\right), \qquad k = 0, 1, 2, \ldots$$

Each term measures the small mismatch between a single harmonic step $\frac{1}{k+1}$ and the logarithmic step $\ln\frac{k+2}{k+1}$ that is "trying" to match it. By the same convexity inequality $\ln x \le x - 1$, every one of these terms is **nonnegative**. And when you add them up, the logarithms telescope — each one's tail cancels the next one's head — leaving exactly Euler's sequence behind. The conclusion is a clean classical identity:

$$\gamma = \sum_{k=0}^{\infty}\left(\frac{1}{k+1} - \ln\frac{k+2}{k+1}\right) = \sum_{m=1}^{\infty}\left(\frac{1}{m} - \ln\Bigl(1 + \frac{1}{m}\Bigr)\right).$$

So $\gamma$ is genuinely the sum of an explicit, term-by-term, nonnegative convergent series. Every partial sum of this series is exactly the fence $a_n = H_n - \ln(n+1)$.

## The tail tells the same story

Now comes the unifying observation. If you add up only the *first* $n$ terms of the series, what is left over — the "tail" — is exactly the error of the approximation:

$$\sum_{k=n}^{\infty} t_k = \gamma - a_n.$$

The leftover of the series is literally the distance from the fence to the constant. And since we already proved $\gamma - a_n < \frac{1}{n}$, we get for free that the tail of the series is smaller than $\frac{1}{n}$ too. The two threads — "$\gamma$ as a series" and "$\gamma$ as a well-trapped limit" — turn out to be the *same* thread. The single quantity $\ln\frac{n+1}{n}$ governs both the width of the cage and the size of the tail.

This is more than a tidy coincidence. It is a diagnostic. Because the tail behaves exactly like $1/n$ — neither vanishing faster nor lingering longer — no truncation of this particular series can ever produce rational approximations to $\gamma$ sharp enough to *force* it to be irrational. The classic test for irrationality (à la the proofs for $e$ and for Apéry's constant $\zeta(3)$) needs approximations that beat $1/n$ by a wide, accelerating margin. Our series, by its very nature, cannot supply them. The slow rate we measured is exactly why the elementary approach is, as one might put it, *irrationality-blind*.

## Why this matters

It is tempting to dismiss a "slow convergence" result as a piece of bad news. It is the opposite. Knowing *precisely* how slow the elementary method is — pinned to the exact order $\Theta(1/n)$, with both an upper and a lower bound — is what makes the search for better methods scientific rather than hopeful. It tells you exactly how much improvement is needed and rules out a whole class of dead ends.

It also points the way forward. The lower bound $\frac{1}{n+1} \le \ln\frac{n+1}{n}$ isolates a specific culprit: a leading correction of size $\frac{1}{2n}$ that the logarithm's expansion always carries. Re-center the logarithm at the *midpoint*, replacing $\ln(n+1)$ with $\ln\bigl(n + \tfrac{1}{2}\bigr)$, and that leading term cancels. The conjecture — natural, and now sharply motivated — is that this single tweak upgrades the convergence from $\Theta(1/n)$ to $O(1/n^2)$, a quadratic leap. The same telescoping machinery that produced the series identity generalizes directly to this re-centered version, and beyond it to the *Stieltjes constants* $\gamma_m$, the higher-order cousins of $\gamma$ that appear in the fine structure of the zeta function.

## The constant that keeps its secret

Three centuries on, $\gamma$ remains one of the great open mysteries of mathematics — a number we can compute to half a trillion digits yet cannot classify as rational or irrational. The results gathered here do not crack that mystery. What they do is something quieter and, in its way, just as valuable: they explain, with complete precision, *why the most natural tool for studying $\gamma$ is too blunt to settle the question*. The harmonic sum and the logarithm chase each other forever, their gap shrinking like clockwork at exactly the rate $1/n$ — fast enough to define a beautiful constant, far too slow to expose its deepest secret.

Euler found the number. Mascheroni computed it. And the constant, with characteristic stubbornness, is still waiting for someone to find the sharper tool.
