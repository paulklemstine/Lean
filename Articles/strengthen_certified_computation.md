# The Arithmetic of Almost-Certainty

## What a computer can prove by checking, what it can never prove by checking, and exactly what closes the gap

---

### Twenty numbers

Start with a game that a child can play. Pick a whole number. If it is even, halve it. If it is odd, triple it and add one. Repeat forever.

Take $7$. It goes
$$7 \to 22 \to 11 \to 34 \to 17 \to 52 \to 26 \to 13 \to 40 \to 20 \to 10 \to 5 \to 16 \to 8 \to 4 \to 2 \to 1.$$
Sixteen steps, a wild excursion up to $52$, and then collapse. Take $27$ and the orbit climbs to $9232$ before crashing down to $1$ after $111$ steps. Every number anyone has ever tried has ended at $1$. The claim that *every* positive integer does is the **Collatz conjecture**, and it is eighty years old and completely open.

Suppose someone hands you a certificate: a verified computation showing that all of $1, 2, \ldots, 20$ reach $1$. What, precisely, have you learned?

The honest answer is: something about twenty numbers, and *nothing whatsoever* about the twenty-first. This article is about making that answer precise — about measuring exactly how much a finite computation is worth, exactly how far a fixed budget of computation can be stretched by clever mathematics, and exactly what extra ingredient converts checking into proving. All three questions have crisp, provable answers, and together they draw a sharp line through the middle of what "computational evidence" means.

---

### Part I: The checker, and what it is worth

Fix a yes/no test $p$ that you can run on any positive integer — "does $n$ reach $1$?", "does $n^5$ end in the same digit as $n$?", "is $n$ a sum of $3$'s and $5$'s?". A *bounded check* is the finite conjunction
$$C_p(\text{lo}, \text{hi}) \;=\; p(\text{lo}) \wedge p(\text{lo}+1) \wedge \cdots \wedge p(\text{hi}).$$

The first thing worth knowing is that this object is not merely *sound* but *exact*.

> **Reflection Principle.** The bounded check $C_p(\text{lo}, \text{hi})$ evaluates to true if and only if $p(k)$ holds for every $k$ with $\text{lo} \le k \le \text{hi}$.

So a successful check loses no information and invents none: it is the bounded statement, computed. Two structural laws come with it. The first is the **gluing law**:
$$C_p(\text{lo}, \text{hi}) \;=\; C_p(\text{lo}, \text{mid}) \wedge C_p(\text{mid}+1, \text{hi}),$$
which is what makes chunked, resumable, and parallel certification legitimate — a certificate for a long interval is *exactly* a pair of certificates for its halves, nothing more and nothing less. The second is **counterexample extraction**: if a check fails, one can read off from the failure an explicit $k$ in the window with $p(k)$ false. Evidence and refutation are the two faces of the same computation.

And now the wall.

> **Finite Evidence Is Never Sound.** For every bound $N$, no matter how astronomical, there exists a predicate $q$ that passes the check on $[1, N]$ and is false somewhere. Explicitly, take the predicate that is true on $[1,N]$ and false forever after.

The witness is embarrassingly simple — it is the *truncation* $q(k) = p(k) \wedge (k \le N)$ — and that is the point. Truncation is invisible to the certificate: the truncated predicate produces the **same certificate, bit for bit**, on $[1,N]$, and is false at $N+1$. So there is no bound $N$ that works for all predicates simultaneously; the diagonal argument is one line long once you have the truncation operator.

You can sharpen the knife. Call the **version space** after a certificate the set of all predicates consistent with the evidence gathered — everything that could still be true, given what you have seen.

> **Continuum Theorem.** After checking any predicate on $[1, N]$, the version space still has the cardinality of the continuum.

The proof is a construction: any function $f$ on the natural numbers can be grafted onto the certified prefix, producing a distinct consistent hypothesis, and the grafting map is injective. So finite evidence does not eliminate *a positive fraction* of the hypothesis space; measured by cardinality, it eliminates nothing at all. Learning theorists will recognise the shape: the class of all binary predicates on the integers shatters every finite set — its VC dimension is infinite — so no finite sample complexity exists, and no finite sample ever determines a hypothesis. Given any finite sample and any hypothesis, one can flip the value at an unsampled point and get a different hypothesis fitting the same data exactly.

This is the pessimistic half, and it is airtight. But it is only half.

---

### Part II: What actually closes the gap

If more computation is not the answer, what is? The answer is **structure**, and it can be named exactly.

> **Definition (Descent Certificate).** A descent certificate for a predicate $p$ consists of a bound $N$, a verified check of $p$ on the window $[1, N]$, and a *reduction function* $r$ such that for every $n > N$:
> 1. $r(n) \ge 1$ (the reduction stays in range),
> 2. $r(n) < n$ (the reduction strictly decreases), and
> 3. $p(r(n))$ true implies $p(n)$ true (truth flows back upward).

> **Soundness.** A descent certificate proves the universal statement: $p(n)$ holds for every $n \ge 1$.

That is strong induction, in one line. The interesting theorem is the converse.

> **Completeness.** Conversely, *every* true universal statement of this form admits a descent certificate.

So the proof system "finite window $+$ descent" is **complete**, whereas the proof system "finite window" alone is not even **sound**. This is a genuine dichotomy, and it locates the missing ingredient exactly: what stands between a computation and a theorem is not more computation but a reduction function. (The certificate produced in the completeness proof is trivial — $N = 1$ with $r \equiv 1$ — but its existence is precisely what makes the system complete, and the content of the statement is that no *third* ingredient is ever needed.)

Two structural hypotheses that occur constantly in practice are instances of descent.

> **Periodic Certificate.** If $p$ has period $T > 0$ — that is, $p(n + T) = p(n)$ for all $n$ — then checking the single window $[1, T]$ proves $p$ universally. (Reduce $n$ to $n - T$.)

> **Shift Certificate.** If $p$ is closed under adding a fixed step $a > 0$ above $N$, then checking the window $[N, N + a - 1]$ of length $a$ proves $p(n)$ for all $n \ge N$.

These are not toys. Ten checked inputs plus periodicity give a genuinely infinite theorem: since $n \mapsto n^5 \bmod 10$ and $n \mapsto n \bmod 10$ both have period $10$, checking $n = 1, \ldots, 10$ proves
$$n^5 \equiv n \pmod{10} \quad \text{for every } n,$$
the familiar fact that fifth powers preserve last digits. Three checked inputs plus a shift give the classic **Chicken McNugget** theorem: since representability as $3x + 5y$ is closed under adding $3$, checking only $n = 8, 9, 10$ proves that every $n \ge 8$ is a non-negative combination of $3$ and $5$. The boundary is sharp — $7$ is not representable, and in fact the complete set of gaps is exactly $\{1, 2, 4, 7\}$, with $7$ the Frobenius number of the semigroup $\langle 3, 5 \rangle$.

Three inputs. An infinite theorem. That is what structure buys.

---

### Part III: Squeezing the budget

Now return to Collatz, where nobody has a descent function and everyone has computers. Given that no certificate will ever be a proof, the remaining question is a genuinely mathematical one: **how far can a fixed amount of verified computation reach?** The answer turns out to be: much further than brute force, and the improvements are theorems, not tricks.

It helps to run the game at double speed. Define the *accelerated map*
$$T(n) = \begin{cases} n/2 & n \text{ even},\\ (3n+1)/2 & n \text{ odd},\end{cases}$$
which merges the guaranteed halving after an odd step into the odd step itself. One accelerated step is one or two ordinary steps, so an orbit reaching $1$ under $T$ reaches $1$ under the classical rule; the certified conclusion is about $3n+1$ itself, not about a convenient surrogate.

**Improvement 1: check a quarter of the inputs.** Look at what the accelerated map does to the four residue classes modulo $4$, in two steps:
$$4m \mapsto m, \qquad 4m+1 \mapsto 3m+1, \qquad 4m+2 \mapsto 3m+2, \qquad 4m+3 \mapsto 9m+8.$$
Three of the four *descend*: $m$, $3m+1$, and $3m+2$ are all smaller than their starting values (for inputs $\ge 3$). Only $4m+3 \mapsto 9m+8$ grows. So by strong induction on the input:

> **Mod-4 Sieve.** To certify that every $n \le B$ reaches $1$, it suffices to certify only the inputs $n \equiv 3 \pmod 4$.

The workload is exactly $\lfloor (B+1)/4 \rfloor$ inputs instead of $B$: a fourfold saving, and one that lands, because the same budget that certified $[1,1000]$ unsieved certified $[1,4000]$ sieved.

And this sieve is not a lucky guess — it is **provably optimal at its scale**. Since the two-step map sends $4m+3$ to $9m+8$, which is never smaller than $4m+3$, *every* input congruent to $3 \bmod 4$ genuinely fails to descend in two steps and genuinely has to be examined. The precise workload of the two-step sieve on $[1, B]$ is the set $\{1, 2\}$ together with the class $3 \bmod 4$, of size exactly $\lfloor (B+1)/4 \rfloor + 2$. No residue-based sieve at this scale can examine fewer.

**Improvement 2: go to higher scales, and watch the cost vanish.** The mod-$4$ sieve is the $k = 2$ member of a family. At scale $k$, look at residues modulo $2^k$ and ask which classes fail to descend within $k$ accelerated steps. A class $r$ modulo $2^k$ turns out to be *non-contracting* precisely when
$$2^k \le 3^{\,s_k(r)},$$
where $s_k(r)$ counts the odd steps taken in the first $k$ iterations starting from $r$ — the analytic contraction condition collapses to a clean integer inequality about parity words. (At $k = 2$: the classes $0, 1, 2$ have $s_2 = 0, 1, 1$ and fail $4 \le 3^{s}$; the class $3$ has $s_2 = 2$ and satisfies $4 \le 9$. Hence the unique non-contracting class at scale $2$ is $3$, confirming the hand-built sieve.) Because most parity words have close to $k/2$ odd steps and $2^k > 3^{k/2}$, the non-contracting classes become rare, and:

> **Vanishing Amortized Cost.** For every $\varepsilon > 0$ there is a scale $k$ such that, for all sufficiently large $B$, the scale-$k$ sieve is sound for $[1,B]$ and examines fewer than $\varepsilon \cdot B$ inputs.

Certified checking of Collatz evidence is therefore **sublinear** in a precise and fully proved sense. Cost per certified input tends to zero. And it is still, by the Continuum Theorem, worth exactly nothing as a proof. That juxtaposition is the moral of the whole story.

**Improvement 3: stop early, and evaluate in a balanced way.** Two further ideas are worth naming because they are the ones that actually moved the number.

The first is *stopping early*. Running each orbit all the way to $1$ costs on the order of a hundred accelerated steps. But strong induction never needed the orbit to reach $1$ — it only needed the orbit to fall *below its own starting point*, at which point the inductive hypothesis takes over. That test succeeds after about $3.5$ accelerated steps on average across all inputs, and about $10$ on the harder sieved class, against roughly $60$–$70$ steps to reach $1$ — a saving of roughly sevenfold on the inputs actually examined, and closer to eighteenfold averaged over all inputs. Crucially, this cheap test is *relatively complete*: whenever a descent exists within the step budget, the cheap checker finds it, so nothing certifiable by the expensive checker is lost.

The second is *the shape of the evaluation*. A naive check recurses linearly along the interval, and the evaluation depth grows with the window — it collapses under its own weight at around $2 \times 10^4$ inputs, at any time budget. Replace it with a *balanced* check: verify $2^d$ inputs by splitting into two halves of $2^{d-1}$, recursively. The value computed is provably identical to the linear one, so nothing at all is assumed; only the shape changes. Depth $d$ instead of depth $2^d$. The obstruction disappears.

Put together — the mod-$4$ sieve, the drop-below test, and balanced evaluation — the certified bound moves from
$$20 \;\longrightarrow\; 1000 \;\longrightarrow\; 4000 \;\longrightarrow\; 131072,$$
a factor of $6553$ over the evidence we started with, and each step a theorem about *why* less work suffices rather than a bigger machine.

---

### Part IV: When evidence *is* conclusive

The Continuum Theorem sounds like a death sentence for empirical mathematics, but read the fine print: it is a statement about the *unrestricted* class of all binary predicates. Restrict the class and everything inverts.

> **Learning Dichotomy.** Fix $T \ge 1$ and consider the evidence consisting of the values of a predicate at $1, 2, \ldots, T$. Within the unrestricted class, the version space consistent with this evidence has the cardinality of the continuum. Within the class of $T$-periodic predicates, the version space is a *singleton*: the evidence determines the hypothesis completely on all positive integers.

Same evidence, same amount of computation. Worthless in one class, conclusive in the other. And the sample size is sharp: for every $T \ge 2$ there are two distinct $T$-periodic predicates agreeing on $[1, T-1]$, so $T-1$ samples are genuinely not enough. The sample complexity of the periodic class is exactly $T$.

This is the learning-theoretic shadow of the descent theorem, and the two say the same thing in different languages. In learning terms: evidence is informative to the extent that the hypothesis class is constrained. In proof terms: a universal statement follows from a finite window precisely when the predicate carries a descent structure — periodicity being one, closure under a shift another. Neither ever depends on the *amount* of computation.

---

### What it all means

There is a widespread and slightly uncomfortable intuition that a conjecture verified to $10^{20}$ is "probably true". The results above say something more disciplined than "that intuition is wrong". They say:

1. **The intuition has no purchase in the unrestricted class.** After any finite check, a continuum of hypotheses survive, and one of them says the conjecture fails at the very next input. For Collatz specifically: for every bound $B$, there is a predicate reproducing the entire body of certified evidence on $[1, B]$ and failing at $B+1$.

2. **The intuition is exactly right in a constrained class.** If you know your hypothesis is periodic with period $T$, then $T$ samples do not merely suggest — they *determine*. The whole question is whether you have earned the right to constrain.

3. **Between the two lies a complete and nameable proof system.** Finite check plus descent is sound and complete for universal statements. Nothing else is ever needed, and nothing less ever suffices. Collatz is equivalent to the existence of a descent certificate for its checker; the missing ingredient is a *reduction function*, not another decade of CPU time.

4. **Meanwhile, the engineering is genuinely mathematical.** Reformulating what needs to be checked — by residue class, by early stopping, by evaluation shape — bought a factor of $6553$ with no new hardware, and the asymptotic version of the argument shows the examined fraction can be made arbitrarily small. Structure beats computation, even when structure is not enough to finish the job.

The child's game is still unsolved. But we now know, with precision, what kind of thing would solve it — and, just as usefully, exactly what kind of thing never will.
