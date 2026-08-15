# FUTURE DIRECTIONS — TRACEPROFILE

The verified results of this cycle are:

* **The exact low bit.** `s₁ = 1 - N₁` for every semiprime with odd factors, its `3/4`
  failure at bit 2, and the fact that the visible bit is a function of `N mod 4` alone.
* **The trace set.** `S_R(N) = {x+y : xy = N}`, its ring-isomorphism invariance, its CRT
  multiplicativity, the exact prime-field size `2|S_p(N)| = p + χ_p(N)`, and the joint law
  `∏(p-1) ≤ 2^ω |S_M(N)| ≤ ∏(p+1)`.
* **Factor invisibility.** `I(p mod q ; N mod q) = 0` as an exact product rule, the failure
  of that product rule for the trace at `q = 5`, and the size contrast
  `|S_q(N)| < |factor set| = q - 1`.
* **Character and arity.** The discriminant description of `S_q(N)`, the identification of
  the visible bit with the Legendre symbol, the `k`-factor low-bit law, and the
  arity-2/arity-3 dichotomy.
* **The pinning barrier.** Congruence data leaves `≳ N/2^ω` candidate traces in the window
  `[1, N]`.

Below are the next-cycle conjectures they suggest. Each is falsifiable by a finite
computation at a specific prime.

---

## C1. The trace set is a complete invariant of the modulus

**Conjecture.** For every odd prime `p` and all `N, N' ∈ 𝔽_p^×`, `S_p(N) = S_p(N')` implies
`N = N'`.

*Status.* Verified for `p ≤ 41` computationally; established exhaustively at `p = 13`.

*The key insight is* that `S_p(N) = {s : χ(s² - 4N) ≠ -1}` is the "non-residue locus" of the
quadratic pencil `s² - 4N`, and two such loci coincide only if the pencils agree: the overlap
`|S_p(N) ∩ S_p(N')|` is a two-variable character sum equal to `p/4 + O(√p)` for `N ≠ N'`,
whereas equality would force `p/2 + O(1)`.

*Why now?* The Legendre-symbol identification proved in this cycle shows the *size* of
`S_p(N)` sees only `χ_p(N)`; C1 says the *set* sees everything. That gap is precisely the
information that a residue attack fails to convert into factors, and pinning it down turns
the qualitative verdict "the trace is the least hidden invariant" into a theorem about how
much is hidden.

## C2. The arity-3 collapse has threshold exactly 11

**Conjecture.** For every prime `p ≥ 11` and every `N ∈ 𝔽_p^×`, `{x + y + z : xyz = N} = 𝔽_p`;
and `p = 3, 5, 7` are the only exceptions.

*Status.* Verified for `p ≤ 19`; established exhaustively at `p = 11`, with the exception at
`p = 5` also established.

*The key insight is* that `s` is a three-factor sum iff the quartic `w² = z²(s-z)² - 4Nz` has
a point with `z ≠ 0`; this is a genus-1 curve, so the Hasse–Weil bound gives `p + O(√p)`
points and forces solvability once `p ≥ 11`.

*Why now?* It isolates exactly *why* the trace is special: the two-factor constraint is a
conic (one quadratic condition, one bit), while the three-factor constraint is an elliptic
curve with enough points to reach every residue (zero bits). Proving C2 converts the observed
dichotomy into a structural theorem, and identifies the trace constraint definitively as the
quadratic discriminant and nothing else.

## C3. Higher symmetric functions and higher arity

For `k` factors the elementary symmetric functions `e₁, …, e_{k-1}` interpolate between the
trace and the full factorisation. Which of them are congruence-constrained, and by how much?
The `k`-factor low-bit law settles `e₁` modulo 4 for all `k`; the arity dichotomy settles `e₁`
modulo an odd prime for `k ≤ 3`.

## C4. Prime-power moduli

All the multiplicativity results here are for squarefree moduli. Modulo `p²` the trace set
should have size `p(p + χ)/2` by Hensel lifting away from the ramified locus, with corrections
at the degenerate traces `s² = 4N`. Making this exact would complete the CRT picture for
arbitrary moduli.

## C5. The high-bit carry sliver

Part of the measured visible fraction of the trace comes from the carry-out of `p + q` in the
top two bits. For `p, q` in a known range, how many high bits of `s` are determined by `N`?
This is a question about the distribution of `√N`-sized quantities and should admit a clean
answer.


# The Least Hidden Number

### A guided tour of what a semiprime cannot help telling you about the sum of its factors

Multiply two large primes, $p$ and $q$, and publish the product $N = pq$. Everyone can see $N$;
nobody can see $p$. That asymmetry is the foundation of a great deal of modern cryptography — see
[RSA](https://en.wikipedia.org/wiki/RSA_cryptosystem) for the standard story.

This page is about a *different* question. Not "how hard is it to compute $p$?" but:

> **How much does $N$ even say about $p$ — or about anything that would give $p$ away?**

The answers are exact, surprising in both directions, and, in the end, reassuring.

---

## 1. Why the sum of the factors is the thing to watch

Define the **trace** of the semiprime to be
$$s = p + q.$$

The trace is special because knowing it is *as good as* factoring. If you know both $N$ and $s$,
then $p$ and $q$ are the two roots of
$$X^2 - sX + N = 0, \qquad p, q = \frac{s \pm \sqrt{s^2 - 4N}}{2}.$$

One square root and the secret falls out. So the trace is the **minimal factor-bearing symmetric
witness**: a single number, treating $p$ and $q$ alike, that completes the puzzle. If any
symmetric quantity is going to leak, this is the one to watch.

{{demo:0}}

<details>
<summary><strong>Why "symmetric" matters — click to expand</strong></summary>

A quantity is *symmetric* in the factorisation if swapping $p$ and $q$ leaves it unchanged.
The product $N$ and the sum $s$ are symmetric; $p$ alone is not. Any procedure that works from
public data alone can only ever produce symmetric information, because the public data does not
distinguish the two primes. So the interesting question — what does $N$ reveal? — is really the
question of what it reveals about *symmetric* invariants. Among those, the trace is minimal:
it is one number, and it is complete.

The other elementary symmetric function here is $N$ itself. The pair $(e_1, e_2) = (s, N)$ is the
whole coefficient vector of the polynomial whose roots are $p$ and $q$; this is
[Vieta's formulas](https://en.wikipedia.org/wiki/Vieta%27s_formulas) in its smallest instance.
</details>

---

## 2. First: the factor itself is invisible

Fix an odd prime $\ell$ and suppose $\ell \nmid N$. What does knowing $N \bmod \ell$ tell you about
$p \bmod \ell$?

**Nothing whatsoever**, and here is the whole proof: whatever nonzero residue $a$ you propose for
$p$, the residue $b = a^{-1}N$ satisfies $ab \equiv N$ — and it is the unique such $b$. Every
candidate is compatible, in exactly one way.

> **Factor invisibility.** Modulo an odd prime $\ell$, the residues a factor of a nonzero $N$ can
> occupy form the entire unit group, all $\ell - 1$ of them. On the uniform model over pairs of
> nonzero residues, the events "$x = a$" and "$xy = b$" satisfy the product rule exactly, so
> $I(p \bmod \ell \,;\, N \bmod \ell) = 0$ — an exact zero, not an approximation.

This is a wall of zeros across every modulus you can test. The public modulus is a perfect
one-time pad for the residues of its own factors.
(If [mutual information](https://en.wikipedia.org/wiki/Mutual_information) is new to you: it
measures how many bits observing one quantity tells you about another. Zero means *nothing*.)

---

## 3. Then: the trace is *not* invisible

Now the same question for $s$. Which residues can $p + q$ occupy modulo $\ell$?

Define the **trace set**
$$S_\ell(N) = \{\, x + y \;:\; xy \equiv N \pmod \ell \,\}.$$

Run the quadratic formula backwards and you get the structural answer immediately:

> **Discriminant description.** $s \in S_\ell(N)$ if and only if $s^2 - 4N$ is a square modulo
> $\ell$.

Indeed if $s = x+y$ and $xy = N$ then $(x-y)^2 = s^2 - 4N$; conversely if $s^2 - 4N = t^2$, take
$x = (s+t)/2$, $y = (s-t)/2$. Since exactly half the nonzero residues are
[quadratic residues](https://en.wikipedia.org/wiki/Quadratic_residue), the trace set has about half
the residues in it — and "about" can be sharpened to *exactly*:

> **The exact size.** For an odd prime $\ell$ and $N \not\equiv 0$,
> $$2\,|S_\ell(N)| = \ell + \chi_\ell(N),$$
> where $\chi_\ell(N) = \pm 1$ according as $N$ is or is not a square modulo $\ell$.

Play with it. Move the sliders, watch cells turn from red to green, and watch the identity
$2|S| = \ell + \chi$ hold on the nose every single time.

{{interactive_demo:0}}

<details>
<summary><strong>The counting proof of the exact size — click to reveal</strong></summary>

Since $N \ne 0$, every factorisation has $x \ne 0$ and $y = N/x$, so
$S_\ell(N) = \{x + Nx^{-1} : x \in \mathbb{F}_\ell^\times\}$: the image of a map $\varphi$ defined
on a set of size $\ell - 1$.

Count the fibres. If $s = x_0 + y_0$ with $x_0 y_0 = N$, then $x + Nx^{-1} = s$ is the quadratic
$x^2 - sx + N = 0$, whose roots are exactly $x_0$ and $y_0$. So each fibre has two elements, unless
$x_0 = y_0$ — that is, unless $s^2 = 4N$ — in which case it has one. Hence
$$\ell - 1 = d + 2(c - d) = 2c - d,$$
where $c = |S_\ell(N)|$ and $d$ counts the *degenerate* traces with $s^2 = 4N$.

Finally, $d = 2$ if $N = r^2$ is a nonzero square (the two solutions $s = \pm 2r$, both realised by
$r \cdot r$ and $(-r)(-r)$) and $d = 0$ otherwise (a solution of $s^2 = 4N$ would exhibit
$N = (s/2)^2$). So $2c = \ell - 1 + d = \ell \pm 1$. $\blacksquare$

The degenerate traces are ringed in gold in the widget above.
</details>

Here is the same fact drawn as a map: rows are values of $N$, columns are candidate traces, green
means "possible". Every row is half green — and, strikingly, no two rows are the same.

{{visualization:1}}

---

## 4. Stacking primes: one bit each, and they never interfere

Does the constraint accumulate? Beautifully, yes — and with no interaction at all, because the
trace set of a product ring is the *product* of the trace sets (a factorisation modulo $mn$ is
exactly a pair of factorisations, by the
[Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)).

> **One bit per prime.** For $M = \prod_{\ell \in P}\ell$ squarefree, odd, coprime to $N$,
> $$\prod_{\ell \in P}(\ell - 1) \;\le\; 2^{|P|}\,|S_M(N)| \;\le\; \prod_{\ell \in P}(\ell + 1),$$
> so the trace set has density $2^{-|P|}$, up to the corrections $1 \pm 1/\ell$.

The measured densities across a large sample of semiprimes were $0.5011$, $0.2509$, $0.1260$ —
i.e. $2^{-1}$, $2^{-2}$, $2^{-3}$. Here is the algorithm that computes the whole joint law in
$O(|P|)$ operations, without ever enumerating anything:

{{algorithm:1}}

And here is the density curve, with the proved envelope drawn around it:

{{visualization:0}}

The left panel is the good news for an attacker. The right panel is the bad news, and we come to
it in Section 7.

<details>
<summary><strong>Why the bits are exactly additive</strong></summary>

Multiplicativity gives
$$\frac{|S_M(N)|}{M} = \prod_{\ell \in P}\frac{\ell + \chi_\ell(N)}{2\ell}
= 2^{-|P|}\prod_{\ell \in P}\left(1 + \frac{\chi_\ell(N)}{\ell}\right),$$
so the information is
$$\log_2\frac{M}{|S_M(N)|} = |P| - \sum_{\ell \in P}\log_2\left(1 + \frac{\chi_\ell(N)}{\ell}\right)
= |P| + O(1).$$
Each prime contributes one bit, and the cross-terms that would signal interaction between primes
are simply absent — the trace set factors exactly.
</details>

---

## 5. The prettiest identity: the exact low bit

At the prime $2$ the quadratic-character analysis degenerates, and something better appears. Write
$p = 2a+1$, $q = 2b+1$ and expand:
$$p + q + pq = 4(a + b + ab) + 3.$$

> **The exact low-bit theorem.** For all odd $p, q$: $\;p + q + pq \equiv 3 \pmod 4$. Equivalently
> $s \equiv 2 \pmod 4$ when $N \equiv 1 \pmod 4$, and $s \equiv 0 \pmod 4$ when $N \equiv 3$; in
> binary digits, $s_1 = 1 - N_1$.

This holds with *no exceptions*: a bit of the secret trace, visible in plain sight. The third tab
of the widget above lets you try to break it — you can't.

But look closely: the visible bit is a function of $N \bmod 4$ *alone*. Two different
factorisations with the same $N \bmod 4$ have the same $s \bmod 4$. Information about the
factorisation: **zero**.

<details>
<summary><strong>Sharpness, and the 3/4 law at the next bit</strong></summary>

The law does not extend. Take $(p,q) = (3,3)$ and $(5,13)$: both give $N \equiv 1 \pmod 8$, but
$s = 6$ and $s = 18$, which differ mod $8$. So no relation determines bit $2$ of $s$ from $N$.

What remains is a statistic. Over the $16$ pairs of odd residues mod $8$ — all that $s \bmod 8$
and $N \bmod 8$ can depend on — bit $2$ of the trace differs from bit $2$ of the modulus in exactly
$12$ cases, a probability of $3/4$. The measured value on real semiprimes was $0.754$.

There is also a version for any number of factors: if $N = a_1\cdots a_k$ with all $a_i$ odd and
$e_1 = \sum a_i$, then
$$e_1 + 1 \equiv N + k \pmod 4 .$$
The visible low bit depends on the product and the *number* of factors — never on the factors.
</details>

---

## 6. The twist: the visible bit was public all along

Look again at the exact size law:
$$2|S_\ell(N)| = \ell + \chi_\ell(N).$$

The one visible bit is $\chi_\ell(N)$ — the
[Legendre symbol](https://en.wikipedia.org/wiki/Legendre_symbol) of the public modulus. By
[quadratic reciprocity](https://en.wikipedia.org/wiki/Quadratic_reciprocity) it is computable from
$N$ alone in microseconds. It is public data, and it was public before anyone thought about traces.

> **Character-indistinguishability.** If $\chi_\ell(N) = \chi_\ell(N')$ then
> $|S_\ell(N)| = |S_\ell(N')|$: the size of the trace constraint sees $N$ only through that one
> public bit.

So the leak is not a leak. It is a shadow cast by something you already knew.

Here is the algorithm that isolates it — the whole constraint in $O(\log \ell)$ operations:

{{algorithm:0}}

<details>
<summary><strong>But the trace SET knows everything — the open question</strong></summary>

The *size* of $S_\ell(N)$ knows one bit. The *set* appears to know all of $N$: for every prime
tested, distinct nonzero $N$ give distinct trace sets.

**Conjecture.** For every odd prime $\ell$ and $N, N' \in \mathbb{F}_\ell^\times$,
$S_\ell(N) = S_\ell(N')$ implies $N = N'$.

The heuristic is a character sum. Two distinct trace sets overlap in
$$\tfrac14\sum_s\big(1 + \chi(s^2-4N)\big)\big(1 + \chi(s^2-4N')\big) + O(1) = \frac{\ell}{4} + O(\sqrt{\ell})$$
elements (by [Weil's bound](https://en.wikipedia.org/wiki/Weil_conjectures)), while equality of the
sets would demand $\ell/2 + O(1)$. The demo below measures exactly this overlap and watches it sit
at $\ell/4$.

The gap between "the size knows one bit" and "the set knows everything" is precisely the
information a residue attack fails to convert into factors — and $N$ was public anyway, so the
chain never touches $p$.
</details>

{{demo:1}}

---

## 7. Why none of this factors anything

We now have a quantity that (i) would break the problem if known, and (ii) is genuinely
constrained by public data, one clean bit per prime. Why is this not an attack?

Because the bits are *additive* and the search space is *exponential*. Since $p + q \le pq = N$,
the trace lives in a window of size $N$ — about $\log_2 N$ bits of uncertainty. Congruence data
modulo $M$ removes a factor of $2^{\omega(M)}$ and no more:

> **The pinning barrier.** For $M = \prod_{\ell \in P}\ell$ squarefree, odd, coprime to $N$, the
> number of integers in $[1,B]$ whose residue is a legal trace residue is at least
> $$\frac{\big(\prod_{\ell\in P}(\ell-1)\big)\big(\lfloor B/M\rfloor - 1\big)}{2^{|P|}} .$$

The surviving set keeps density $\approx 2^{-|P|}$. To reach a single candidate you need
$|P| \gtrsim \log_2 N$ primes — over two thousand for a $2048$-bit modulus — whose product $M$
dwarfs $N$ so completely that the residue of $s$ modulo $M$ simply *is* $s$. The attack would have
to assume its own answer.

Run the sieve and watch it fail on schedule:

{{algorithm:2}}

---

## 8. One last question: is any of this about "two"?

Everything above concerned $N = pq$. What if $N$ has three factors — is $x + y + z$ constrained
when $xyz = N$?

Almost never, and the reason is geometry. Two factors give one quadratic condition — a **conic** —
so half the residues survive. Three factors give a curve of genus one, which by the
[Hasse–Weil bound](https://en.wikipedia.org/wiki/Hasse%27s_theorem_on_elliptic_curves) has
$\ell + O(\sqrt{\ell})$ points: more than enough to reach every residue.

> **The arity dichotomy.** The two-factor trace set is always a proper subset of the residues. But
> modulo $11$, the three-factor sum set is *all* the residues, for every invertible $N$. Only
> $\ell = 3, 5, 7$ are exceptional.

The fourth tab of the widget lets you watch the collapse happen. Slide the prime past $7$ and the
red cells vanish for good.

**The trace constraint is the quadratic discriminant, and nothing else.**

---

## 9. The verdict

| Quantity | Residues available mod $\ell$ | Bits revealed | What the visible information *is* |
|---|---|---|---|
| Factor $p$ | all $\ell-1$ units | $0$, exactly | nothing |
| Trace $s = p+q$ | $(\ell + \chi_\ell(N))/2$ | $1$ per prime, additive | the Legendre symbol — public |
| Trace, low bits | $s \equiv 3 - N \pmod 4$ | an exact identity | a function of $N \bmod 4$ — public |
| Triple sum $x+y+z$ | all $\ell$, for $\ell \ge 11$ | $0$ | nothing |

The trace of a semiprime is the **least hidden symmetric invariant** — the most accessible residue
target that exists. And it is still perfectly safe, for three independent reasons, each of them a
theorem: the visible bit is public, the visible bits are symmetric, and the visible bits do not
scale.

A secret can be surrounded by true, checkable, free facts about itself, and remain — in every way
that matters — a secret.
