# How to Prove That a Clue Is Worthless

## A story about negative results, and the mathematics that makes them stick

Every experimental science has a shadow archive: the things that were tried and did not
work. In physics it is the null runs; in medicine, the trials that found no effect; in the
quantitative study of algorithms, the features that turned out to predict nothing. The
shadow archive is enormous and almost entirely unwritten, because a negative result is
awkward to state. "We looked and found nothing" invites the obvious retort: *maybe you did
not look hard enough.*

This article is about turning that retort off. It tells the story of one very concrete
negative result — a set of arithmetic clues that failed to predict what an integer
factorisation sieve would do — and then about the small body of mathematics we built so
that the failure could be stated as a *theorem* rather than as a shrug.

---

## The setting: a sieve, and a dial that predicts it

Suppose you want to factor a large integer $N$. The classical family of algorithms — the
quadratic sieve and its descendants — proceed by hunting for integers $x$ near $\sqrt{N}$
such that $x^2 - N$ factors completely over a fixed list of small primes, the *factor
base*. Each such $x$ gives a relation; enough relations, and linear algebra over
$\mathbb{F}_2$ hands you a factorisation.

The engineering question is: for a given $N$, how *productive* will the sieve be? Some
moduli are lucky and yield relations quickly; others are stubborn. If you could predict
productivity in advance, you could budget, choose parameters, or switch algorithms.

There is a classical heuristic that does remarkably well, and we will call it the
**quadratic-residue footprint dial**. A prime $p$ in the factor base is useful for $N$ only
if $N$ is a quadratic residue modulo $p$ — otherwise $x^2 \equiv N \pmod p$ has no solution
and $p$ never divides any sieve value. Each *useful* prime $p$ contributes roughly a
density $2/p$ of sieve positions that it can hit (two roots modulo $p$). So define, for a
factor-base bound $B$,

$$
W(N) \;=\; \sum_{\substack{p \le B,\ p \text{ odd prime} \\ N \ \text{is a QR mod } p}} \frac{2}{p}.
$$

This single number — the total sieve "footprint" available to $N$ — is a genuinely good
predictor. In the experiment behind this article, across a balanced population of
$96$-bit moduli, the footprint dial alone explained $R^2 = 0.411$ of the variance in sieve
yield, a correlation of $r = 0.641$. That is a strong single-feature result for a
number-theoretic prediction problem.

But it leaves roughly $40\%$ of the variation unexplained, near a characteristic operating
point of the sieve. Where does the missing $40\%$ live?

---

## The tempting clue: what the neighbours of $N$ look like

Here is a very natural guess. The sieve's behaviour near $N$ ought to be sensitive to how
*smooth* the neighbourhood of $N$ is — how easily nearby integers break into small prime
factors. So take four covariates read off the immediate neighbourhood of the modulus:

$$
\omega(N-1),\qquad \omega(N+1),\qquad \log \mathrm{lpf}(N-1),\qquad \log \mathrm{lpf}(N+1),
$$

where $\omega(m)$ counts the distinct prime factors of $m$ and $\mathrm{lpf}(m)$ is its
least prime factor. This is the "neighbour smoothness" block: cheap to compute, arithmetically
meaningful, and exactly the sort of thing that ought to carry information.

The experiment appended these four covariates to the footprint dial and refitted. The
result:

- dial alone: $R^2 = 0.4112$;
- the four neighbour covariates alone: $R^2 = 0.0319$;
- dial plus neighbours, jointly: $R^2 = 0.4307$.

The increment is $\Delta R^2 = 0.0195$. The best single correlation between any neighbour
covariate and the dial's residual was $|r| = 0.16$. A permutation test — shuffle the rows
of the covariate block $500$ times and refit — gave $p = 0.389$, with a $95$th percentile
of the null distribution at $0.046$, comfortably *above* the observed $0.0195$. Running the
comparison the other way round, the dial's incremental value *given* the neighbourhood
block was $+0.3987$.

Read the numbers plainly: the neighbourhood layer carries essentially nothing that the dial
does not already carry, while the dial carries almost everything even after the neighbours
have had their chance. But "read the numbers plainly" is exactly the move a sceptic is
entitled to refuse.

---

## From a measurement to a bound

The core problem with a small $\Delta R^2$ is that it is a *measurement of one fit*. It does
not, by itself, say anything about what a different fit could have done. So we proved the
statement that does.

Fix a response vector $y$ over a sample of $n$ points, a baseline prediction $g$, and write
$r = y - g$ for the baseline residual. Let $v_1,\dots,v_k$ be the covariate block. Suppose
the block is not pathologically collinear — formally, that there is a constant $\lambda>0$
with

$$
\lambda\,\|c\|^2 \;\le\; \Big\|\sum_{j=1}^k c_j v_j\Big\|^2 \qquad \text{for every coefficient vector } c,
$$

which is exactly saying that $\lambda$ is a lower bound for the smallest eigenvalue of the
block's Gram matrix. Then:

> **The Block Ceiling.** No linear combination of $v_1,\dots,v_k$ can remove more than
> $\displaystyle \frac{1}{\lambda}\sum_{j=1}^k \langle r, v_j\rangle^2$
> of the residual energy $\|r\|^2$.

The proof is two lines of honest inequality. Fitting coefficients $c$ changes the residual
energy to $\|r\|^2 - 2\langle r, \sum_j c_jv_j\rangle + \|\sum_j c_jv_j\|^2$. Cauchy–Schwarz
bounds the cross term by $2\sqrt{\|c\|^2 S}$ where $S = \sum_j \langle r,v_j\rangle^2$, and
the frame bound says the quadratic term is at least $\lambda\|c\|^2$. Then the elementary
inequality $2D \le \lambda a + S/\lambda$, valid whenever $D^2 \le aS$ (it is AM–GM in
disguise, or: complete the square in $\sqrt{a}$), finishes it. The *best possible* $c$ is
already accounted for, because the bound holds for all $c$ at once.

Normalise the covariates to unit length, suppose every residual correlation is at most
$\rho$ in absolute value, and the ceiling becomes a slogan you can quote:

$$
\boxed{\;\Delta R^2 \;\le\; \frac{k\,\rho^{2}\,(1-R^2_0)}{\lambda}\;}
$$

where $R^2_0$ is the baseline's own $R^2$. Four covariates, correlations at most $0.16$, a
baseline of $0.4112$, and an orthonormal block ($\lambda = 1$):

$$
\Delta R^2 \;\le\; 4 \cdot 0.16^2 \cdot 0.5888 \;=\; 0.0603.
$$

The observed $0.0195$ sits comfortably inside. And here is the part we want to flag rather
than hide: the ceiling *does not by itself* refute the pre-registered alternative
$\Delta R^2 \ge 0.05$. If the correlations had all been at most $0.1457$, it would have
—because $4 \cdot 0.1457^2 \cdot 0.5888 = 0.04999\ldots < 0.05$. At $\rho = 0.16$ the
certificate is not sharp enough on its own, and the verdict genuinely leans on the joint
fit and the permutation test. Certificates should announce their own boundaries.

---

## Nothing is not the same as not-much

The ceiling has an exact companion, and it is the cleanest statement in the whole
development:

> **The Block Dichotomy.** A block strictly improves $R^2$ over the baseline **if and only
> if** at least one of its covariates has nonzero inner product with the baseline residual.

So "the block adds nothing" is not a vague statistical impression. It is the precise
geometric statement that the block lies in the orthogonal complement of the residual. There
is no third possibility, no "adds a tiny bit for subtle reasons": either some covariate
correlates with what the baseline missed, or the block's optimal contribution is exactly
zero.

Dual to it is a robustness statement that makes the *asymmetry* rigorous:

> **Conditional Dominance.** If a feature $w$ is orthogonal to every covariate in the block,
> then fitting the block first costs $w$ nothing: after the block has been fitted, $w$ still
> gains its full individual lift $\langle r,w\rangle^2/(\|w\|^2\,\mathrm{TSS})$.

Combining ceiling and dominance gives the capstone. Suppose the block's residual
correlations are bounded by $\rho$, the dial's individual lift is at least $d$, and the
ceiling $k\rho^2(1-R^2_0)/\lambda$ falls below $d$. Then

$$
\underbrace{R^2(\text{dial} + \text{block}) - R^2(\text{block})}_{\text{what the dial adds given the neighbours}}
\;>\;
\underbrace{R^2(\text{block}) - R^2(\text{dial baseline})}_{\text{what the neighbours add given the dial}} .
$$

With the experiment's numbers — $\rho = 0.16$, $d = 0.3987$, $R^2_0 = 0.4112$, ceiling
$0.0603$ — the hypothesis holds and the conclusion follows. "Nothing beyond the dial" is
now a theorem about the design, not a summary of one regression run.

---

## Calibrating the reference distribution by pure algebra

Permutation tests are usually treated as Monte-Carlo devices: you shuffle, refit, and read
off an empirical quantile, and the null distribution is whatever the computer says it is.
For a single centred covariate it turns out you can compute the first moment exactly.

Let $r$ be a centred residual and $v$ a centred covariate on $n$ sample points. Sum the
squared inner product over *all* $n!$ relabellings:

$$
\sum_{\sigma \in S_n} \langle r,\, v\circ\sigma\rangle^2 \;=\; \frac{n!\,\|r\|^2\|v\|^2}{n-1}.
$$

The proof is a symmetry argument of great economy. Expand the square: everything reduces to
the quantities $W(i,j) = \sum_\sigma v(\sigma i)\,v(\sigma j)$. Because the symmetric group
is *sharply $2$-transitive enough* — for any two pairs of distinct indices there is a
permutation carrying one to the other — $W(i,j)$ takes only two values, one on the diagonal
and one off it. Two linear relations pin both down: the diagonal sum is $n!\,\|v\|^2$, and
the total sum over all $(i,j)$ vanishes because $v$ is centred. Solve, and the identity
falls out.

The consequence is the calibration statement:

> **Permutation-Null Calibration.** The mean, over all row shuffles, of the $R^2$ increment
> contributed by one centred covariate is exactly $(1-R^2_0)/(n-1)$.

No distributional assumption, no asymptotics, no normality: the reference distribution's
centre is fixed by the baseline fit and the sample size alone. From it, Markov's inequality
gives a tail bound: at most a fraction $(1-R^2_0)/((n-1)t)$ of shuffles reach an increment
of $t$. At $R^2_0 = 0.4112$ and $n \ge 237$, at most $5\%$ of shuffles reach $0.05$ — which
is exactly the neighbourhood in which the experiment's empirical $q_{95} = 0.046$ was
found. The Monte-Carlo estimate and the algebraic bound agree, and one of them needed no
random numbers.

---

## But what about nonlinear structure?

A sceptic's strongest card is still on the table. All of the above bounds what a covariate
can do *linearly*. A feature can be linearly uncorrelated with a residual and still
determine it completely — think of $y = v^2$ with $v$ symmetric about zero.

So we removed linearity from the discussion. For an arbitrary feature $f$ — taking values in
any set at all — consider the class of *every* predictor that is a function of $f$: no
linearity, no monotonicity, no smoothness. Group the sample into the level sets ("cells") of
$f$. Then:

> **The Nonlinear Ceiling.** The best achievable residual sum of squares over the class of
> all functions of $f$ is exactly the within-cell sum of squares
> $\sum_{a} \sum_{i:\,f(i)=a} (y_i - \bar y_a)^2$, where $\bar y_a$ is the mean of $y$ on the
> cell. Equivalently, the best achievable $R^2$ is exactly the correlation ratio
> $\eta^2 = 1 - \mathrm{WSS}/\mathrm{TSS}$.

The proof is the classical bias–variance split on each cell: $\sum_{i\in S}(y_i - c)^2 =
\sum_{i\in S}(y_i-\bar y_S)^2 + |S|(c - \bar y_S)^2$. Choosing the cell mean is optimal, and
nothing else can be. So a null result can be stated against *all* predictors, not merely
linear ones: if the within-cell energy is at least a fraction $\theta$ of the total, then no
function of $f$ whatsoever explains more than $1-\theta$ of the variance. And refining the
feature (appending the neighbourhood layer to the dial) can only lower within-cell energy,
so the floor transfers coherently to joint features.

Applied here: at least $40\%$ of the response variation lies out of reach of every function
— linear or wild — of the joint feature (dial, neighbourhood).

---

## The clue was never coupled to the answer

One last layer, and it is pure number theory. The statistical work shows the neighbourhood
covariates and the dial do not *behave* as though they were linked in this sample. But is
there some hidden arithmetic coupling that a bigger sample would expose?

No — and the reason is a construction. The dial is a function of $N$ modulo a finite set of
primes. The neighbour covariates are properties of $N\pm 1$. Choose any target residue class
$N_0$ modulo $P$, and any level $a$. Pick $a$ primes exceeding $P$ for $N-1$ and $a$ more,
all different, for $N+1$. The Chinese Remainder Theorem then produces integers $N$, of
arbitrarily large size, that lie in the prescribed class modulo $P$ while $N-1$ and $N+1$
each carry at least $a$ distinct prime factors.

> **Arithmetic Freedom.** For *every* value of the footprint dial and *every* target level
> $a$, there are arbitrarily large moduli realising that dial value while both neighbour
> covariates exceed $a$.

The two feature families are independent by construction. Conditioning on the neighbourhood
layer places no restriction whatsoever on the dial, and the neighbour covariate is provably
not a function of the dial: two moduli with the same dial value can have different
$\omega(N-1)$. Any correlation observed between them in a finite sample is a property of the
sample, not a law.

---

## What a completed negative looks like

Put the pieces side by side. The dial explains $41\%$ of sieve yield. A natural rival
explanation — the local factorisation structure around $N$ — was tested and produced an
increment of $0.0195$, below the pre-registered null boundary of $0.02$, with a permutation
$p$ of $0.389$. And behind that measurement now stand four theorems: a ceiling saying no
refit of the block could have done much better; a dichotomy saying "adds nothing" means
exact orthogonality; a calibration fixing the reference distribution by algebra rather than
simulation; and a nonlinear ceiling extending the verdict to every conceivable functional
form. Underneath them all, an arithmetic construction showing the two layers were never
coupled to begin with.

This matters beyond one sieve. The residual $40\%$ is not merely unexplained; it is
*genuinely open* — the leading candidates have been tested and have failed, and the failure
has been certified. That redirects the search: if no property of the modulus $N$ itself
explains the leftover variation, then the carrier must be a statistic of the sieve *run*,
not of the number being factored. Every $N$-property tested so far is a residue dial —
a function of $N$ modulo a fixed finite set of primes — and residue dials have now been
shown, as a theorem schema, to be incapable of lowering the within-cell energy once the
cells are fixed.

One caveat is worth stating in the open, because a certificate is only as good as its
inputs. The population of moduli used here was regenerated from a documented recipe rather
than recovered from the original archive; the fingerprint check matched at the level
available, but not exhaustively. The statistical conclusions are therefore conditional on
the sampled population being exchangeable with the original. The *arithmetic* freedom
theorem is not: it holds for all integers unconditionally, whatever population you draw.

Negative results deserve this treatment. A shrug is not reusable; a ceiling is. The next
person who wonders whether the neighbours of $N$ carry sieve information does not have to
rerun the experiment — they can read off the bound and see, in one line of arithmetic, how
much room was ever available.
