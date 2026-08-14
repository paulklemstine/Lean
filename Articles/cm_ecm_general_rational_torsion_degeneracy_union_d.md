# The Curve That Knows Nothing

## What happens when a beautiful symmetry turns out to say exactly zero

There is a particular kind of disappointment familiar to anyone who has hunted for hidden structure in numbers. You find a pattern. It is clean, it is exact, it holds every single time you test it. And then you realise that precisely *because* it holds every single time, it can never tell you anything you did not already know.

This is a story about one such pattern, and about the surprisingly sharp mathematics you get when you take that disappointment seriously and turn it into a theorem.

---

## Factoring, and the shape of luck

Start with the practical problem. You are handed a large number $N$ — say, a $200$-digit integer — and you want its prime factors. The best general-purpose methods all rest on the same gamble: you build an algebraic group attached to a secret prime divisor $p$ of $N$, and you hope that group has an order which is *smooth*, meaning it factors entirely into small primes. If it does, a certain product of small numbers will detect $p$, and you win.

Pollard's $p-1$ method (1974) gambles on the group $(\mathbb{Z}/p)^\times$, whose order is $p-1$. Williams' $p+1$ method (1982) gambles instead on a torus of order $p+1$. Both are hostage to a single number: if neither $p-1$ nor $p+1$ happens to be smooth, you are stuck with that prime forever.

Hendrik Lenstra's elliptic curve method (ECM, 1987) removed the hostage. Instead of one fixed group, you get an entire family: for each elliptic curve $E$ over the rationals, reduction modulo $p$ gives a finite abelian group $E(\mathbb{F}_p)$, whose order is

$$\#E(\mathbb{F}_p) = p + 1 - a_p, \qquad |a_p| \le 2\sqrt{p},$$

where $a_p$, the *trace of Frobenius*, is a small integer wobble around $p+1$. Change the curve and $a_p$ changes; you get to re-roll the dice. ECM's power is precisely that $\#E(\mathbb{F}_p)$ moves as the curve moves, sweeping out an interval of about $4\sqrt{p}$ values, until one of them lands on a smooth number.

Now here is the natural question that motivates everything below.

> **Does the choice of curve leak information about $p$ — enough that we could aim the dice rather than roll them?**

If some easily-computable feature of $N$ (say, its residue modulo a small number) correlated with divisibility properties of $\#E(\mathbb{F}_p)$, that would be a genuine advantage. You would preferentially choose curves whose orders are *predisposed* to be smooth for that $p$. Over enough trials, a few percent of edge compounds into a real speedup — and, seen from the other direction, a real weakness in any cryptosystem whose security rests on factoring being hard.

The most promising place to look is the curves with **complex multiplication** (CM), because those are exactly the curves whose arithmetic is governed by an explicit abelian symmetry — the kind of symmetry that classical reciprocity laws make *visible* in residue classes.

---

## The two most symmetric curves in the world

There are exactly two elliptic curves of maximal symmetry over the rationals, and both have been famous since Gauss and Eisenstein.

The first is
$$E_0 : y^2 = x^3 + 1,$$
whose extra symmetry is the map $(x,y) \mapsto (\zeta x, y)$ for a cube root of unity $\zeta$. Its endomorphism ring is the Eisenstein integers $\mathbb{Z}[\omega]$, $\omega = e^{2\pi i/3}$, and its CM field is $\mathbb{Q}(\sqrt{-3})$.

The second is
$$E_{1728} : y^2 = x^3 + x,$$
with the symmetry $(x,y) \mapsto (-x, iy)$, endomorphism ring the Gaussian integers $\mathbb{Z}[i]$, and CM field $\mathbb{Q}(i)$.

For such curves the trace $a_p$ is not mysterious. Classical reciprocity says: a prime $p$ either **splits** in the CM field or is **inert**, and the two behaviours are utterly different. For $E_0$: $p$ splits when $p \equiv 1 \pmod 3$ and is inert when $p \equiv 2 \pmod 3$. And on the inert half, something dramatic happens.

**Theorem (Inert collapse).** *If $p \equiv 2 \pmod 3$ then $\#E_0(\mathbb{F}_p) = p+1$ exactly, so $a_p = 0$. If $p \equiv 3 \pmod 4$ then $\#E_{1728}(\mathbb{F}_p) = p+1$ exactly, so again $a_p = 0$.*

The proofs are wonderfully elementary. For $E_0$, when $p \equiv 2 \pmod 3$ the map $u \mapsto u^3$ is a *bijection* of $\mathbb{F}_p$ — there is an explicit inverse, namely raising to the power $(2p-1)/3$. So for each value $y$, the equation $y^2 - 1 = x^3$ has exactly one solution $x$. The affine points are therefore in bijection with the $y$-axis: exactly $p$ of them, plus the point at infinity. For $E_{1728}$, when $p \equiv 3 \pmod 4$ the cubic $x^3 + x$ is odd, and $-1$ is a non-residue, so of the two values $c$ and $-c$ exactly one is a square: the fibres over $x$ and $-x$ contribute exactly two points between them, again totalling $p$.

Half of all primes, and the curve's order is nailed to $p+1$ with no wobble at all.

This has an immediate and slightly deflating consequence. On the inert half, asking whether $\#E_0(\mathbb{F}_p)$ is smooth is asking whether $p+1$ is smooth. **On that half, running ECM on the most symmetric curve in the world is literally running Williams' $p+1$ method from 1982.** The whole apparatus of complex multiplication buys nothing new; it reproduces a forty-year-old algorithm exactly.

---

## The pattern that says nothing

So much for the inert half. What about small-prime divisibility of the order in general — the thing ECM actually cares about?

Look at $E_0 : y^2 = x^3+1$ again, and notice the point $T = (0,1)$. It lies on the curve. It has order $3$ in the group law. And crucially it is *rational*: it is there over $\mathbb{Q}$, hence it survives reduction modulo every good prime.

**Theorem (Rational-torsion degeneracy).** *For every prime $p > 3$, $\ \#E_0(\mathbb{F}_p)$ is divisible by $6$. Consequently $a_p \equiv p+1 \pmod 6$ for every such $p$.*

You can see the divisibility by $3$ without any group law at all. Translation by $T$ acts on the affine points with $x \neq 0$ by the explicit rational map
$$(x, y) \ \longmapsto \ \left( \frac{2(1-y)}{x^2}, \ \frac{y-3}{y+1} \right),$$
which one checks by direct algebra is (i) well defined — the curve equation forces $y \neq \pm 1$ whenever $x \neq 0$; (ii) again a point of the curve; (iii) of order exactly $3$, since iterating three times returns $(x,y)$; and (iv) *fixed-point free*, since a fixed point would force simultaneously $y = -3$ and $y^2 = -3$, i.e. $12 = 0$, impossible for $p > 3$. Extended by the three-cycle $\infty \mapsto (0,1) \mapsto (0,-1) \mapsto \infty$, this is a fixed-point-free self-map of order $3$ of the entire point set, so the point set breaks into orbits of size exactly $3$, and $3$ divides its cardinality. Divisibility by $2$ is easier still: $(-1, 0)$ is a rational point of order $2$.

Check it: $\#E_0(\mathbb{F}_5) = 6$, $\#E_0(\mathbb{F}_7) = 12$, $\#E_0(\mathbb{F}_{13}) = 12$, $\#E_0(\mathbb{F}_{23}) = 24$, $\#E_0(\mathbb{F}_{31}) = 36$. Always a multiple of six.

Here is the punchline, and it is where the disappointment becomes the theorem. Suppose you are looking for a correlation: you want to know whether the residue of $N$ modulo $3$ predicts the event "$3$ divides $\#E_0(\mathbb{F}_p)$". Measure the correlation with mutual information — the standard measure, in bits, of how much learning one variable tells you about the other. The answer is not "small". The answer is:

**Theorem (Zero-bit law).** *A Boolean observable that is constant on a sample has empirical mutual information exactly $0$ with every classifying statistic whatsoever. Hence for every finite sample of primes $p > 3$, every class function on that sample, and every $\ell$ dividing $6$, the channel "$\ell$ divides $\#E_0(\mathbb{F}_p)$" carries exactly zero information — not approximately zero, not below a noise floor: zero.*

This is a curious situation to sit with. The divisibility $3 \mid \#E_0(\mathbb{F}_p)$ is real, it is abelian in origin, it is visible in residue classes, it holds a hundred percent of the time — and for exactly that reason it is worth nothing. **A perfectly reliable signal is not a signal.** Information lives in variation, and there is none.

One must be careful here, because "our statistic returned zero" is also what a broken statistic returns. So the story needs its other half, and it has one. The same information functional does attain positive values: on a two-point sample where the event is perfectly correlated with the label, it returns exactly $\log 2$ — one full bit. And the $\ell = 5$ channel on the very same curve is not constant: $\#E_0(\mathbb{F}_{29}) = 30$ is divisible by $5$, and $\#E_0(\mathbb{F}_5) = 6$ is not. Feeding the two-prime sample $\{29, 5\}$ into the functional returns $\log 2$ on the nose.

So the null at $\ell = 3$ is a property of *the event*, not of *the measurement*. It is a degeneracy caused by rational torsion, and nothing else.

How much else? Exactly nothing else, as it turns out.

**Theorem (Silent-set classification).** *For a positive integer $\ell$, the divisibility $\ell \mid \#E_0(\mathbb{F}_p)$ holds for every prime $p > 3$ if and only if $\ell$ divides $6$. So the "silent set" of the curve — the levels carrying zero information on every conceivable sample — is exactly $\{1, 2, 3, 6\}$.*

One direction is the torsion theorem. The other needs a single prime: $\#E_0(\mathbb{F}_5) = 6$, so any $\ell$ that is unconditionally a divisor must divide $6$. From this follows an all-or-nothing dichotomy: for every $\ell$, either $\ell \mid 6$ and the channel is dead on arrival everywhere; or $\ell \nmid 6$ and any single good prime whose order is divisible by $\ell$, paired with $p=5$, already yields a sample on which the channel carries a full bit. There is no middle ground, no "weakly informative" level. Silence is *equivalent* to rational torsion.

And this last statement is not special to $E_0$: the underlying counting principle is that a self-map of a finite set with $f^{[n]} = \mathrm{id}$ and no point of smaller period forces $n$ to divide the size of the set — the counting shadow of a free $\mathbb{Z}/n$-action, valid for every $n$, prime or not. Wherever a rational $n$-torsion point survives reduction, the corresponding channel is silent. This is a fact about torsion, not about complex multiplication.

---

## Where the signal actually hides

So where, if anywhere, does a residue class of $p$ genuinely determine divisibility of the elliptic order? The inert collapse answers this completely — and the answer is a little dial.

**Theorem (Inert dial).** *For $p \equiv 2 \pmod 3$ and any $\ell \ge 1$: $\ \ell \mid \#E_0(\mathbb{F}_p)$ if and only if $p \equiv -1 \pmod \ell$.*

Since the order *is* $p+1$ on that half, this is immediate — but it is a striking statement all the same. On half of all primes, the entire smoothness profile of the elliptic order is a pure congruence condition on $p$. In particular $9 \mid \#E_0(\mathbb{F}_p)$ exactly on the class $p \equiv 8 \pmod 9$, and $27 \mid \#E_0(\mathbb{F}_p)$ exactly on $p \equiv 26 \pmod{27}$. These are powers of $3$ — the *ramified* prime of the CM field $\mathbb{Q}(\sqrt{-3})$ — and that is not a coincidence: ramification shrinks the relevant conductor, pinning the arithmetic to a small modulus.

And on the other half? Nothing of the kind exists, and one can see it in two numbers. The primes $13$ and $31$ are both split ($\equiv 1 \bmod 3$) and both lie in the *same* class $4$ modulo $9$. Yet $\#E_0(\mathbb{F}_{13}) = 12$, not divisible by $9$, while $\#E_0(\mathbb{F}_{31}) = 36$, divisible by $9$. Their traces, $a_{13} = 2$ and $a_{31} = -4$, are incongruent modulo $9$. So on the split half the divisibility is *not* a function of $p \bmod 9$: the visibility is a ramified-inert phenomenon, not a global congruence. The genuinely two-dimensional part of the arithmetic — the part where the trace can wobble — remains hidden.

Which is, in a sense, the deepest structural statement here. The trace of Frobenius of a CM curve is an *exact* dichotomy:

**Theorem (Atomic trace law).** *For $p > 3$, $\ a_p(E_0) = 0$ if and only if $p \equiv 2 \pmod 3$; and for odd $p$, $\ a_p(E_{1728}) = 0$ if and only if $p \equiv 3 \pmod 4$. Consequently, on any finite sample of primes, the number with vanishing trace equals exactly the number of inert primes — no slack, no error term.*

The forward direction for $E_0$ is a pleasant use of the torsion degeneracy: since $a_p \equiv p+1 \pmod 3$ always, $a_p = 0$ forces $3 \mid p+1$. For $E_{1728}$, if $p \equiv 1 \pmod 4$ then $-1$ is a square, so $x^3+x$ splits completely, giving full rational $2$-torsion and $4 \mid \#E$ — incompatible with $\#E = p+1 \equiv 2 \pmod 4$. So a measured statistic like "the trace vanished on $50.4\%$ of the sampled primes" is not an empirical near-coincidence to be explained: it is the inert frequency of the sample, exactly, by an identity.

---

## The dilution law: why a union can only ever be quieter

There is one more lesson, and it is the one with the widest reach beyond elliptic curves.

In practice you rarely test a single condition. ECM tests a *union*: the run succeeds if the order is divisible by $\ell$ **or** if some other, class-independent event fires. And unions behave counterintuitively when you measure them.

Suppose a channel has conditional probabilities $a_k = P(A \mid k)$ across classes $k$ with weights $w_k$, and you measure its strength by the normalised conditional variation (the squared correlation ratio)
$$\eta^2(a) \;=\; \frac{\sum_k w_k\,(a_k - \mu)^2}{\mu(1-\mu)}, \qquad \mu = \sum_k w_k a_k,$$
the natural "fraction of variance explained by the class". Now mix in a class-blind event of probability $b$, disjoint from $A$, so that $P(A \cup B \mid k) = a_k + b$.

**Theorem (Union-dilution law).** *The numerator is unchanged: adding a constant to every conditional probability does not alter the weighted conditional variance. But the normaliser $\mu(1-\mu)$ strictly increases as long as the base rate stays below $1/2$. Hence $\eta^2(a + b) \le \eta^2(a)$, with strict inequality whenever $b > 0$ and the channel is non-degenerate, and with the exact factor*
$$\frac{\eta^2(a+b)}{\eta^2(a)} \;=\; \frac{\mu_A(1-\mu_A)}{\mu_U(1-\mu_U)}, \qquad \mu_U = \mu_A + b.$$
*Moreover the dilution deepens monotonically in $b$, and every factor in the half-open interval $(0,1]$ is attained by an honest two-class channel — so the inequality is universal and no constant smaller than $1$ can replace it.*

The moral: **a union channel is never stronger than the conditional channel inside it.** Diluting a sharp conditional signal with a class-blind half doesn't just fail to help; it provably compresses the measured effect, by a computable amount. This is why, in a CM setting, a measured "shadow" of a union event sits systematically *below* its own inert-class reference channel — the split half raises the unconditional base rate and squeezes the variation out. The mechanism has nothing to do with which CM field one is in; it is a statement about variance normalisation, and it reproduces itself unchanged when one swaps $\mathbb{Q}(\sqrt{-3})$ for $\mathbb{Q}(i)$.

---

## The verdict, and why a null is worth having

Assemble the pieces and the picture is complete and, in its way, satisfying.

- On half the primes, the CM curve's order collapses to $p+1$ exactly, so ECM on it *is* the $p+1$ method. Nothing gained.
- The remaining structure that is genuinely visible in residues — divisibility by $2$, $3$, $6$ — is visible because it is *unconditional*, and unconditional means zero bits. Nothing gained.
- The one place where a residue class genuinely dictates divisibility is the inert half, where the "dial" $\ell \mid \#E \iff p \equiv -1 \pmod \ell$ is just the $p+1$ structure again, sharpest at powers of the ramified prime.
- On the split half, where the arithmetic is genuinely rich, the trace is invisible to residue classes already at modulus $9$.
- And any attempt to read a union of such events is provably quieter than the conditional channel it contains.

So: no shortcut. The security of factoring-based cryptography loses nothing to complex multiplication, and ECM practitioners have no residue-class dial to turn. That is a null result — and null results have a bad reputation they do not deserve. This one comes with three exact theorems that were not obvious before we went looking: a classification of which divisibility levels can *ever* carry information for a given curve (exactly the divisors of the rational torsion), an identity making trace-vanishing equivalent to inertness with no error term, and a sharp quantitative law for how unions dilute measured effects.

The last of these is the one likely to travel. Every experimental science measures union events and normalises by base rates, and the union-dilution law says something uncomfortable and precise about that practice: your measured effect size shrinks by exactly $\mu_A(1-\mu_A)/\mu_U(1-\mu_U)$ every time you fold in a channel-blind alternative. If you compare that diluted number against a threshold calibrated for the pure channel, you will call real signals noise.

Sometimes the most useful thing a beautiful symmetry can teach you is precisely how it manages to say nothing at all.
