# The Village That Remembers Whether It Started Even

*How a children's party game hides a two-faced limit law, and why the number $\pi$ decides which face you see.*

---

## A village with no information

Imagine a village of $n$ people. Some small number $k$ of them are wolves; the rest are ordinary villagers. Every day the village assembles and votes to eliminate one person. Every night, if any wolf is still alive, the wolves eat one villager. The village wins if it eliminates every wolf; the wolves win if they eat every villager.

That is the ancient party game — Werewolf, Mafia, Assassin, whatever your local name for it. What makes it fun is the arguing: reading faces, catching contradictions, noticing who defended whom.

Now take all of that away.

Suppose nobody has any information at all. No tells, no slips, no logic. The daily vote is a pure coin flip — or rather, a uniform draw from everybody still breathing. This is the **information-free game**, and it is the natural null model against which every real strategy should be measured. Whatever your clever deduction buys you, it buys it *over and above* this baseline. So it is worth knowing exactly what the baseline is.

The answer turns out to be strange, and beautiful, and it involves $\pi$.

---

## The conserved quantity nobody notices

Here is the observation on which everything else rests.

In each full round — one day, one night — the population drops by **exactly two**, no matter what happens.

Check the two cases. If the day vote *hits* a wolf, that wolf dies by day; a wolf still remains alive at night only if $k \ge 2$, and if not, the game is already over. In the ordinary run of play, one wolf dies by day, one villager dies by night: total loss two. If the vote *misses* — an innocent villager is lynched — then a villager dies by day and another villager is eaten at night: total loss two again.

Hit or miss, the population goes
$$n, \quad n-2, \quad n-4, \quad n-6, \ \dots$$

The consequence is immediate and, at first, seems too trivial to matter: **the parity of the population never changes**. A village that starts with $17$ people passes through $15, 13, 11, \dots$; a village that starts with $18$ passes through $16, 14, 12, \dots$. These are two entirely different ladders. The game never crosses from one to the other.

That parity is a conserved quantity — a constant of the motion, in the physicist's phrase — and the whole surprise of this story is that it *never washes out*. Not even as $n \to \infty$. The village remembers whether it started even, all the way to the bitter end.

---

## One wolf, and a product from 1656

Start with the simplest interesting case: exactly one wolf.

With a single wolf, the wolves win precisely when that one wolf is never lynched. So we need the probability that a designated player survives every vote. On the first day the population is $n$ and the wolf survives with probability $1 - 1/n$. Two days later the population is $n-2$ and the wolf survives with probability $1 - 1/(n-2)$. And so on down the ladder. Multiplying:

$$s(n) \;=\; \left(1 - \frac{1}{n}\right)\left(1 - \frac{1}{n-2}\right)\left(1 - \frac{1}{n-4}\right)\cdots$$

Because the ladder steps by two, this product looks completely different depending on where it starts. For an **even** population $n = 2m$ it is
$$s(2m) \;=\; \frac{1}{2}\cdot\frac{3}{4}\cdot\frac{5}{6}\cdots\frac{2m-1}{2m},$$
while for an **odd** population $n = 2m+1$ it is
$$s(2m+1) \;=\; \frac{2}{3}\cdot\frac{4}{5}\cdot\frac{6}{7}\cdots\frac{2m}{2m+1}.$$

These are the two halves of one of the most famous products in mathematics. Divide the second by the first and you get
$$\frac{s(2m+1)}{s(2m)} \;=\; \frac{2\cdot 2}{1\cdot 3}\cdot\frac{4\cdot 4}{3\cdot 5}\cdot\frac{6\cdot 6}{5\cdot 7}\cdots\frac{2m\cdot 2m}{(2m-1)(2m+1)},$$
which is exactly the partial product in **Wallis's product**, discovered by John Wallis in 1656, and which converges to $\pi/2$.

There is a second identity, even simpler, that pins the two ladders together. Multiply consecutive values instead of dividing them: the interleaved telescoping gives, for every $n \ge 0$,
$$s(n)\,s(n+1) \;=\; \frac{1}{\,n+1\,}.$$

So we have two facts about the pair $\bigl(s(2m),\,s(2m+1)\bigr)$: their *ratio* is a Wallis partial product $W_m \to \pi/2$, and their *product* is $1/(2m+1)$. Two equations, two unknowns. Solving:

$$(2m+1)\,s(2m+1)^2 \;=\; W_m, \qquad (2m+1)\,s(2m)^2\,W_m \;=\; 1.$$

Let $n \to \infty$. Since $W_m \to \pi/2$:

$$\boxed{\;\sqrt{n}\;s(n) \;\longrightarrow\; \sqrt{\tfrac{2}{\pi}} \approx 0.79788 \quad\text{along even } n,\qquad \sqrt{n}\;s(n) \;\longrightarrow\; \sqrt{\tfrac{\pi}{2}} \approx 1.25331 \quad\text{along odd } n.\;}$$

Two limits. Not one. The scaled survival probability does not converge — it *oscillates forever* between two values, and the ratio of those values is
$$\frac{\sqrt{\pi/2}}{\sqrt{2/\pi}} \;=\; \frac{\pi}{2} \;\approx\; 1.5708 .$$

A lone wolf in an odd village is, asymptotically, $\pi/2$ times more likely to survive than a lone wolf in an even village of the same size. That factor of $\pi/2$ is not an approximation and not a coincidence: it *is* Wallis's product, wearing a costume.

---

## The oscillation you can see at $n = 7$

It would be one thing if this were a purely asymptotic effect, visible only for absurd village sizes. It is not. There is a clean, completely elementary statement that separates the parities at *every* population.

Consider the quantity $n\,s(n)^2$ — the population times the squared survival probability. The two limits above say it tends to $2/\pi \approx 0.6366$ on evens and to $\pi/2 \approx 1.5708$ on odds. Note that
$$\frac{2}{\pi}\cdot\frac{\pi}{2} \;=\; 1,$$
so $1$ is the geometric mean of the two limits. And in fact $1$ is an exact separator:

> **For every even population, $n\,s(n)^2 < 1$. For every odd population, $n\,s(n)^2 \ge 1$.**

Here is the whole proof. The even product is termwise smaller than the odd one — compare $\frac{2j-1}{2j}$ with $\frac{2j}{2j+1}$ and cross-multiply: $(2j-1)(2j+1) = 4j^2 - 1 < 4j^2$. So $s(2m) \le s(2m+1)$. Now feed that into the coupling identity $s(2m)s(2m+1) = 1/(2m+1)$:
$$s(2m)^2 \;\le\; s(2m)s(2m+1) \;=\; \frac{1}{2m+1} \;\le\; s(2m+1)^2 .$$
Multiply through by $2m+1$ and you have both halves at once. No analysis, no limits, no $\pi$ — just a comparison of fractions.

The table is immediate and unambiguous:

| $n$ | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|---|---|---|---|---|---|---|---|---|
| $n\,s(n)^2$ | 1.4629 | 0.5981 | 1.4861 | 0.6056 | 1.5011 | 0.6107 | 1.5116 | 0.6143 |
| side of 1 | above | below | above | below | above | below | above | below |

Two interleaved sequences, each climbing serenely toward its own limit, never meeting. This is the fingerprint that no single asymptotic formula in $n$ could ever reproduce, and it is visible from the very first village big enough to play in.

---

## More wolves, same $\pi$

So far, one wolf. What happens with a pack?

With $k$ wolves the obvious first guess is the **union bound**: the wolves win only if *some* wolf survives to the end, and each individual wolf survives with probability $s(n)$, so
$$p_k(n) \;\le\; k\,s(n),$$
where $p_k(n)$ denotes the wolves' win probability in a population of $n$ containing $k$ wolves. This is a genuine theorem here, not a heuristic — a careful induction along the population ladder confirms it, the key algebraic cancellation being the identity $k(k-1) + vk = k(n-1)$ relating the "hit" and "miss" branches.

The union bound overcounts, of course: it double-counts the scenarios in which two wolves both survive. The remarkable thing is *how little* it overcounts. Define the **defect**
$$D_k(n) \;=\; k\,s(n) - p_k(n) \;\ge\; 0 .$$
Then, for every wolf count $k$ and every population $n$,
$$n\,D_k(n) \;\le\; \binom{k}{2} \;=\; \frac{k(k-1)}{2}.$$

The constant is exactly the number of *unordered pairs* of wolves — precisely the objects the union bound double-counts. And it is not merely a convenient bound: for $k = 2$ and $k = 3$ it is attained exactly, at every odd population.

Why $\binom{k}{2}$? Because the defect obeys its own clean recursion,
$$n\,D_{k+1}(n) \;=\; (k+1)\,D_k(n-2) \;+\; (n-k-1)\,D_{k+1}(n-2),$$
in which the survival term has cancelled *identically* — the survival ladder and the population ladder step in lockstep, so the $s$ pieces annihilate. Rescale by setting $g_k(n) = n\,D_k(n)$ and the recursion becomes
$$g_{k+1}(n) \;=\; \frac{(k+1)\,g_k(n-2) + (n-k-1)\,g_{k+1}(n-2)}{n-2},$$
and $\binom{k}{2}$ is exactly the fixed point: substitute $g_k \equiv \binom{k}{2}$ and $g_{k+1} \equiv \binom{k+1}{2}$ on the right, use $\binom{k+1}{2} = \binom{k}{2} + k$, and the numerator collapses to $(n-2)\binom{k+1}{2}$. Pascal's rule, hiding inside a game.

Since $s(n)$ decays like $n^{-1/2}$ but the defect decays like $n^{-1}$, the defect is of *lower order*. So the whole parity story transfers, intact, to every wolf count:

$$\sqrt{n}\;p_k(n) \;\longrightarrow\; k\sqrt{\tfrac{2}{\pi}} \ \ (n \text{ even}), \qquad \sqrt{n}\;p_k(n) \;\longrightarrow\; k\sqrt{\tfrac{\pi}{2}} \ \ (n \text{ odd}).$$

Both constants are proportional to $k$ — so their ratio is $\pi/2$ **regardless of how many wolves there are**. The parity correction is a universal multiplicative constant of the game, not a feature of one particular pack size.

Turned around, in terms of the village's chances: for any fixed number of wolves the village wins with probability tending to $1$, but the *rate* is parity-split:
$$\mathbb{P}(\text{village wins}) \;=\; 1 - \frac{k\sqrt{2/\pi}}{\sqrt{n}} + o(n^{-1/2}) \quad (n \text{ even}), \qquad 1 - \frac{k\sqrt{\pi/2}}{\sqrt{n}} + o(n^{-1/2}) \quad (n \text{ odd}).$$

Same leading term. Different first correction. Ratio exactly $\pi/2$. And because the two subsequential limits differ, the scaled sequence $\sqrt{n}\,p_k(n)$ **has no limit at all** — a single parity-blind asymptotic formula for this game simply does not exist.

---

## The game solved exactly, for two wolves

Sometimes the algebra is generous. For two wolves it hands over the complete answer:

$$p_2(n) \;=\; \begin{cases} 2\,s(n) & n \text{ even},\\[4pt] 2\,s(n) - \dfrac{1}{n} & n \text{ odd}. \end{cases}$$

Read that again. On even populations the union bound is *exactly* attained — the double-counting is precisely zero, a perfect and slightly eerie cancellation. On odd populations it is missed by exactly $1/n$, no more and no less, for every single odd $n$. You can check both halves by hand at $n = 19$ and $n = 20$: with $18$ villagers and $2$ wolves the wolf-win probability is $\tfrac{46189}{131072}$, which is exactly $2\,s(20)$; with $17$ villagers and $2$ wolves it is $\tfrac{118917}{230945}$, strictly below $2\,s(19)$, and short by exactly $1/19$.

Three wolves behave the same way, with a $3$ in place of the $1$:
$$p_3(n) \;=\; 3\,s(n) - \frac{3}{n} \quad (n \text{ odd}), \qquad p_3(n) \;=\; \frac{3n-4}{n-1}\,s(n) \quad (n \text{ even}),$$
the even prefactor being a rational function increasing to $3$. Four wolves at even populations give $\frac{4n-8}{n-1}\,s(n)$.

Rewriting those even-population formulas in terms of the defect exposes something striking. For three wolves at even $n$,
$$n\,D_3(n) \;=\; s(n-2),$$
and for four wolves at even $n$,
$$n\,D_4(n) \;=\; 4\,s(n-2).$$
So on the *even* ladder the second-order term is not a rational number at all — it is another survival product, decaying like $n^{-1/2}$, carrying its own trace of Wallis. But on the *odd* ladder the second-order term is a plain rational constant: $1$ for two wolves, $3$ for three. The parity split reaches all the way down to the second order, and it changes *character* as it goes: rational on one side, transcendental on the other.

---

## Why any of this matters

**Because null models should be exact.** Every claim of the form "good players win more" needs a baseline, and here the baseline is now known to the second order, with the surprising rider that it depends on a fact about the village nobody ever thinks to record: whether the starting count was even or odd.

**Because parity is a physical idea.** What we have here is a discrete conserved quantity — a superselection rule, if you like — that partitions the state space into two sectors that never communicate. Coarse-graining the dynamics does not merge them. Systems whose microscopic update preserves a $\mathbb{Z}/2$ invariant routinely display exactly this pathology: a "thermodynamic limit" that fails to exist because two sublattices, two sublimits, two phases, refuse to reconcile. Statistical physics has met these sublattice oscillations many times, in antiferromagnets, in dimer coverings, in absorbing-state models. The village game is a small, exactly solvable instance in which one can watch the mechanism from beginning to end.

**Because it is a warning about fitting.** Suppose you had only the numerical values and tried to fit $p_k(n) \approx c\,n^{-1/2}$. You would obtain a systematically bad fit, with residuals that flip sign every step, and you might reach for a quadratic correction or an extra parameter to soak up the wobble. You would be fitting the wrong shape. The data are not noisy around one curve; they are exactly on *two* curves, whose ratio is $\pi/2$ forever.

**Because $\pi$ has no business being here.** There is no circle in this game. There is no continuum, no geometry, no measure of an angle. There is a village, a die, and a rule. And yet the ratio of the two long-run behaviours is exactly half the ratio of a circle's circumference to its radius. The reason is Wallis's product, which is itself an accident of how the central binomial coefficient $\binom{2m}{m}$ behaves: the even survival product is $\binom{2m}{m}4^{-m}$, and the appearance of $\pi$ is Stirling's formula in disguise. Every time you count subsets, $\pi$ is already waiting. Here it waits inside a party game.

---

## The shape of the answer

Let us assemble the whole picture in one place. Write $n$ for the starting population, $k$ for the number of wolves, $p_k(n)$ for the probability the wolves win, and
$$s(n) = \prod_{j \ge 0,\; n - 2j \ge 2} \left(1 - \frac{1}{n-2j}\right)$$
for the single-wolf survival product.

1. **Parity is conserved.** The population falls by exactly $2$ each round, so the game never leaves its parity class.
2. **One wolf is exact.** $p_1(n) = s(n)$ — no approximation at all.
3. **The two ladders are coupled.** $s(n)s(n+1) = 1/(n+1)$, and $s(2m+1)/s(2m)$ is the $m$-th Wallis partial product.
4. **Finite-$n$ separation.** $n\,s(n)^2 < 1$ for all even $n$, and $\ge 1$ for all odd $n$; the separator $1$ is the geometric mean of the two limits.
5. **Two limits, ratio $\pi/2$.** $\sqrt{n}\,s(n) \to \sqrt{2/\pi}$ on evens, $\to \sqrt{\pi/2}$ on odds.
6. **The union bound is asymptotically exact and quantitatively sharp.** $0 \le k\,s(n) - p_k(n) \le \binom{k}{2}/n$, with the constant attained on odd populations for $k = 2, 3$.
7. **Hence two expansions for every $k$.** $\sqrt{n}\,p_k(n) \to k\sqrt{2/\pi}$ on evens, $k\sqrt{\pi/2}$ on odds; the scaled sequence has no limit; the village wins with probability $\to 1$ along either parity, at parity-dependent speed.
8. **Two wolves are solved outright.** $p_2(n) = 2s(n)$ for even $n$ and $2s(n) - 1/n$ for odd $n$.

---

## What we still don't know

The exact odd-population formulas for two and three wolves — $n D_k(n) = 1$ and $3$ — and machine computations of the next few cases suggest something tidy. For $k = 4, 5, 6$ the scaled odd defect appears to be
$$\frac{6n-13}{n-2}, \qquad \frac{10n-25}{n-2}, \qquad \frac{15n^2 - 105n + 183}{(n-2)(n-4)},$$
each a rational function of $n$ tending to $\binom{k}{2}$: $6$, $10$, $15$. That pattern, if it holds for all $k$, would solve the odd-population game in closed form for every pack size and would upgrade the inequality $nD_k(n) \le \binom{k}{2}$ into an exact asymptotic equality. The defect recursion is the natural engine for a proof, because on the odd ladder the survival product genuinely disappears from it.

The even ladder is conjectured to behave in the opposite way: no rational description, because the second-order term there is $s(n-2)$ times a rational function — an irreducibly Wallis-flavoured object. If both conjectures are right, then the parity split is not one phenomenon but two, and the two sides of the village are different not just in their constants but in the very kind of number they produce.

Which is a satisfying place for a story about a party game to end: with the village still remembering, all the way to infinity, whether it started even or odd.
