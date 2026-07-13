# The Hidden Arithmetic of Suspicion: How Werewolf Reveals a 300-Year-Old Identity

## A game of hidden roles

Imagine a village of $n$ people gathered around a fire at night. Among them hide $k$ **werewolves** — indistinguishable from everyone else by daylight, but deadly by night. The remaining $n-k$ are ordinary **villagers**. Each night the werewolves secretly devour one villager; each day the survivors argue, accuse, and vote to eliminate a suspect. The villagers win if they eliminate every werewolf; the werewolves win if they ever equal or outnumber the villagers.

This is *Werewolf* (also called *Mafia*), one of the most popular social-deduction games in the world. On the surface it is a game of bluffing, psychology, and reading faces. But underneath the theatrics lies a purely mathematical skeleton — a question of **inference under uncertainty**. When a villager stares across the fire and wonders *"is that person a werewolf?"*, they are, whether they know it or not, computing a probability.

The surprising discovery in this article is that the arithmetic of that suspicion is not new mathematics at all. It is a re-dressing of two of the most classical facts in all of combinatorics: **Vandermonde's convolution**, published by Alexandre-Théophile Vandermonde in the eighteenth century (and known even earlier to Zhu Shijie in fourteenth-century China), and the humble **binomial absorption identity**. The whole Bayesian backbone of optimal Werewolf play turns out to be a shadow of counting.

## The committee question

Let us make the intuition precise. Set aside a single night and ask a cleaner question. Suppose that during a round of play we single out a *committee* of $t$ players — perhaps the set of people accused, the players targeted by a night action, or simply a random sample the villagers decide to scrutinize. If the committee is chosen uniformly at random from all $\binom{n}{t}$ possible committees of size $t$, **how many werewolves does it contain?**

The number of werewolves in the committee, call it $J$, is random. Its probability law is the celebrated **hypergeometric distribution**. The probability that the committee contains exactly $j$ werewolves is

$$
\Pr[J = j] \;=\; \frac{\dbinom{k}{j}\,\dbinom{n-k}{t-j}}{\dbinom{n}{t}}.
$$

The reasoning is elementary and beautiful. To build a committee with exactly $j$ werewolves, you must choose which $j$ of the $k$ werewolves are included — that is $\binom{k}{j}$ ways — and independently choose which $t-j$ of the $n-k$ villagers fill the remaining seats — that is $\binom{n-k}{t-j}$ ways. Divide by the total number $\binom{n}{t}$ of committees, and you have the probability. This is *sampling without replacement*: once a player is on the committee, they cannot be chosen again, which is exactly what distinguishes the hypergeometric law from its more famous cousin, the binomial distribution.

## Two questions every probability distribution must answer

A probability distribution is only legitimate if it satisfies two sanity checks, and these two checks are precisely where the classical identities emerge.

**First: do the probabilities add up to one?** If $J$ must take *some* value between $0$ and $t$, then summing $\Pr[J=j]$ over all possible $j$ had better give exactly $1$. Writing this out,

$$
\sum_{j=0}^{t} \frac{\binom{k}{j}\binom{n-k}{t-j}}{\binom{n}{t}} = 1
\qquad\Longleftrightarrow\qquad
\sum_{j=0}^{t} \binom{k}{j}\binom{n-k}{t-j} = \binom{n}{t}.
$$

The right-hand equation is **Vandermonde's convolution**, one of the oldest identities in combinatorics. And notice: we did not *invent* it to make the probabilities behave — it is forced upon us by the same counting logic that built the distribution in the first place. To pick $t$ players out of $n$, split the $n$ into $k$ werewolves and $n-k$ villagers, choose $j$ from the first group and $t-j$ from the second, and sum over all splits. The demand that a probability distribution normalize to one *is* Vandermonde's identity, wearing a costume.

**Second: what is the average?** On average, how many werewolves does the committee contain? Intuition suggests a clean answer: if a fraction $k/n$ of the whole village is werewolf, then a committee of $t$ people should contain, on average, that same fraction of its seats filled by werewolves — namely $t \cdot k/n$. This intuition is exactly correct:

$$
\mathbb{E}[J] \;=\; \sum_{j=0}^{t} j\cdot \frac{\binom{k}{j}\binom{n-k}{t-j}}{\binom{n}{t}} \;=\; \frac{t\,k}{n}.
$$

Proving it requires one more classical tool, the **binomial absorption identity**:

$$
j\,\binom{k}{j} \;=\; k\,\binom{k-1}{j-1}.
$$

This says something concrete: the number of ways to choose a $j$-person team from $k$ people *and* designate one of them as captain equals $k$ (pick the captain first) times $\binom{k-1}{j-1}$ (fill out the rest of the team). Absorbing the pesky factor $j$ into the binomial coefficient turns the mean's sum back into another Vandermonde convolution — one rung lower, on $n-1$ players — and the whole thing collapses to $t\,k/n$.

## The moment of suspicion

Now shrink the committee to its smallest interesting size: $t = 1$. A single suspect, drawn at random. How likely is that lone individual to be a werewolf? Plug $t=1$ into the mean formula, and the expected number of werewolves in a one-person committee is

$$
\mathbb{E}[J] = \frac{1\cdot k}{n} = \frac{k}{n}.
$$

Since a one-person committee contains either zero or one werewolf, this expected value *is* the probability that the suspect is a werewolf. We have recovered the villager's gut instinct — "with no other information, anyone is a werewolf with probability $k/n$" — as a mathematical theorem. This is the **prior**: the belief you hold before any evidence arrives. Every accusation, every alibi, every suspicious silence in the game is an update to this baseline via Bayes' rule, but the baseline itself is nothing more than $k/n$, the raw density of wolves in the village.

This is the "prior/posterior collapse" at the heart of optimal play: when you truly know nothing, the sophisticated hypergeometric machinery flattens into a single fraction. Detection is hardest at the start, when suspicion is spread evenly across everyone, and the whole art of the game is accumulating enough evidence to sharpen that flat $k/n$ into confident certainty.

## A dictionary between two worlds

Step back and look at what we have found. On the left sits a table of probabilistic facts about a game of deception; on the right sit named theorems of pure combinatorics:

| Probability (social deduction) | Combinatorics / number theory |
| --- | --- |
| The probabilities sum to $1$ | **Vandermonde's convolution** $\sum_j \binom{k}{j}\binom{n-k}{t-j} = \binom{n}{t}$ |
| The mean equals $t\,k/n$ | **Binomial absorption** $j\binom{k}{j} = k\binom{k-1}{j-1}$, then Vandermonde again |
| A single random suspect is a werewolf | The prior probability $k/n$ |

The dictionary is exact. There is no approximation, no limiting argument, no "for large $n$" caveat. Every probabilistic statement reduces, letter for letter, to an integer identity about binomial coefficients. The bridge is **dimension-free**: it holds for a village of five or five million, for one werewolf or a hundred.

## Why this matters

Cross-domain bridges like this one are the connective tissue of mathematics. They let insight flow both ways. On one side, the rich toolkit of combinatorics — generating functions, absorption identities, convolution formulas — becomes available to analyze games, sampling schemes, and inference problems. On the other, the concrete, tactile intuition of "how many wolves in the committee" gives fresh meaning to abstract identities that might otherwise feel like dry symbol-pushing.

The same engine keeps running. The distribution's *variance* — a measure of how spread-out suspicion is, and hence how reliable a single sample is — comes from a second-order absorption identity $j^2\binom{k}{j} = k\,j\,\binom{k-1}{j-1}$ followed by yet another Vandermonde. Higher *falling-factorial moments* $\mathbb{E}[(J)_r] = (t)_r(k)_r/(n)_r$ all flow from a single $r$-fold absorption. And sampling *until* the first werewolf appears leads to the negative-hypergeometric law and its own family of identities. Each is a new entry in the same dictionary.

There is a quiet lesson here about the unity of mathematics. A parlor game invented for firelit evenings, a convolution identity from the age of Vandermonde, and the Bayesian logic that powers modern spam filters and medical diagnostics all turn out to be the same structure seen from three angles. When you next accuse a friend across the table, know that you are, in the most literal sense, computing a binomial coefficient — and that the arithmetic of suspicion was written down three centuries before the game was ever played.
