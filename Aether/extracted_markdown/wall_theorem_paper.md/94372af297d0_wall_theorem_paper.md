# Wall's Lifting-the-Exponent Lemma for Fibonacci Numbers: A Formally Verified Proof

## Abstract

We present a complete, machine-verified proof in Lean 4 (with Mathlib) of Wall's Lifting-the-Exponent (LTE) lemma for Fibonacci numbers. Specifically, for any odd prime *p* dividing the Fibonacci number F(n), and any positive integer k, we prove:

$$v_p(F(nk)) = v_p(F(n)) + v_p(k)$$

where $v_p$ denotes the *p*-adic valuation. This result, due to D.D. Wall (1960), is the key algebraic ingredient in Carmichael's theorem that every Fibonacci number F(n) with n > 12 possesses a primitive prime divisor. Our formalization introduces a novel quadratic approximation technique that reduces the critical mod $p^2$ congruence to a clean inductive argument.

## 1. Introduction

The Fibonacci sequence $F(0) = 0, F(1) = 1, F(n+2) = F(n) + F(n+1)$ possesses a remarkably rich divisibility theory. One of its crown jewels is Carmichael's theorem (1913): for every $n > 12$, the Fibonacci number $F(n)$ has at least one prime factor that does not divide $F(k)$ for any $0 < k < n$. Such a prime is called a *primitive prime divisor*.

The proof of Carmichael's theorem requires precise control over how many times each prime divides Fibonacci numbers at composite indices. This is provided by Wall's theorem, which gives an exact formula for the $p$-adic valuation of $F(n)$ in terms of the Fibonacci entry point $\alpha(p) = \min\{m > 0 : p \mid F(m)\}$ and the $p$-adic valuation of the index.

**Theorem (Wall, 1960).** Let $p$ be an odd prime with $p \mid F(n)$, and let $k \geq 1$. Then:
$$v_p(F(nk)) = v_p(F(n)) + v_p(k).$$

Despite its fundamental importance, a complete formal verification of this result has, to our knowledge, not appeared in the literature. We provide such a verification in Lean 4 using the Mathlib library.

## 2. Proof Architecture

Our proof follows a three-step strategy:

### Step 1: The Base Case — $v_p(F(np)/F(n)) = 1$

This is the most technically demanding component. We prove that $F(np)/F(n)$ (which is always an integer by the well-known divisibility property $F(n) \mid F(nm)$) is divisible by $p$ exactly once.

**Key Congruence.** For odd prime $p \mid F(n)$ with $n \geq 2$:
$$F(np)/F(n) \equiv p \cdot F(n+1)^{p-1} \pmod{p^2}.$$

Since $\gcd(F(n), F(n+1)) = 1$ and $p \mid F(n)$, we have $p \nmid F(n+1)$, so $p \nmid F(n+1)^{p-1}$, and thus $p^2 \nmid p \cdot F(n+1)^{p-1}$. Combined with $p \mid F(np)/F(n)$ (from the mod $p$ version), this gives $v_p(F(np)/F(n)) = 1$.

### Step 2: The Prime-Power Case

By induction on $t$, we show $v_p(F(n \cdot p^t)) = v_p(F(n)) + t$. The base case $t = 0$ is trivial. The inductive step applies Step 1 to $n' = n \cdot p^t$ (which satisfies $p \mid F(n')$ since $F(n) \mid F(n')$), yielding $v_p(F(n'p)/F(n')) = 1$, and then uses the multiplicativity of $v_p$.

### Step 3: The General Case via Coprime Reduction

We decompose $k = p^t \cdot v$ where $\gcd(p, v) = 1$. The "weak Wall" lemma (which follows directly from the mod $p$ congruence) shows $p \nmid F(n'v)/F(n')$ where $n' = n \cdot p^t$, so $v_p(F(nk)) = v_p(F(n \cdot p^t)) = v_p(F(n)) + t = v_p(F(n)) + v_p(k)$.

## 3. The Quadratic Approximation Technique

The heart of our proof is establishing the mod $p^2$ congruence. We introduce the *quadratic approximation*:
$$T(k) = k \cdot \alpha^{k-1} - \binom{k}{2} \cdot F(n) \cdot \alpha^{k-2}$$

where $\alpha = F(n+1)$, and prove by induction that $Q(k) := F(nk)/F(n) \equiv T(k) \pmod{p^2}$ for all $k \geq 1$.

**Setup.** The quotient $Q(k)$ satisfies the exact recurrence:
$$Q(k+1) = F(n-1) \cdot Q(k) + F(nk+1)$$

To compare $Q$ and $T$ modulo $p^2$, we need two auxiliary congruences:

1. **Fibonacci successor mod $F(n)^2$:** $F(nk+1) \equiv F(n+1)^k \pmod{F(n)^2}$. This follows by induction from $F(n(k+1)+1) = F(nk) \cdot F(n) + F(nk+1) \cdot F(n+1)$, where $F(nk) \cdot F(n) = F(n)^2 \cdot Q(k) \equiv 0$.

2. **Algebraic identity:** $(α - F(n)) \cdot T(k) + α^k = T(k+1) + \binom{k}{2} \cdot F(n)^2 \cdot α^{k-2}$.

Since $F(n-1) = α - F(n)$, the error $E(k) = Q(k) - T(k)$ satisfies:
$$E(k+1) = (α - F(n)) \cdot E(k) + \binom{k}{2} \cdot F(n)^2 \cdot α^{k-2} + [F(nk+1) - α^k]$$

Each term on the right is divisible by $p^2$: the first by the inductive hypothesis, the second because $F(n)^2 \equiv 0 \pmod{p^2}$, and the third by auxiliary result (1) since $p^2 \mid F(n)^2$.

**Completing the proof.** For $k = p$:
$$T(p) = p \cdot α^{p-1} - \binom{p}{2} \cdot F(n) \cdot α^{p-2}$$

Since $\binom{p}{2} = p(p-1)/2$ (an integer for odd $p$) and $p \mid F(n)$, we have $\binom{p}{2} \cdot F(n) \equiv 0 \pmod{p^2}$, giving $T(p) \equiv p \cdot α^{p-1} \pmod{p^2}$. Combined with $Q(p) \equiv T(p) \pmod{p^2}$, we obtain $Q(p) \equiv p \cdot α^{p-1} \pmod{p^2}$.

## 4. Formal Verification Details

Our Lean 4 formalization consists of approximately 250 lines of code and comprises:

| Lemma | Statement | Proof Lines |
|-------|-----------|-------------|
| `fib_succ_mul_mod_sq` | $F(n)^2 \mid F(nk+1) - F(n+1)^k$ | ~10 |
| `fib_div_recurrence` | Integer recurrence for $Q(k)$ | ~10 |
| `fib_div_mod_p_sq` | $p^2 \mid Q(p) - p \cdot α^{p-1}$ | ~25 |
| `wall_base` | $v_p(F(np)/F(n)) = 1$ | ~20 |
| `wall_theorem` | $v_p(F(nk)) = v_p(F(n)) + v_p(k)$ | ~35 |

The proof depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`) — no additional axioms or `sorry` placeholders remain.

## 5. Discussion: What This Means

### For the General Reader

Imagine the Fibonacci sequence as a river carrying numerical "DNA" — each number inherits prime factors from its ancestors according to strict mathematical laws. Wall's theorem is the Rosetta Stone that decodes this inheritance pattern.

Here's the intuition: every prime $p$ has a "home base" in the Fibonacci sequence — the first Fibonacci number it divides, called $F(\alpha(p))$. After that, $p$ shows up with clockwork regularity at every multiple of $\alpha(p)$. But the *intensity* of $p$'s appearance (how many times it divides each Fibonacci number) follows a precise rule: each extra factor of $p$ in the index contributes exactly one extra factor of $p$ in the Fibonacci number.

This is like a resonance phenomenon in physics: the prime $p$ resonates with the Fibonacci sequence at frequency $\alpha(p)$, and each additional "octave" ($p$-fold increase in the index) amplifies the signal by exactly one notch.

### Why Formal Verification Matters Here

Number theory proofs involving $p$-adic valuations and modular arithmetic are notoriously error-prone. The key congruence $F(np)/F(n) \equiv p \cdot F(n+1)^{p-1} \pmod{p^2}$ involves delicate bookkeeping with integer divisions, binomial coefficients, and multiple levels of divisibility. A single sign error or off-by-one mistake can invalidate the entire argument. Machine verification eliminates this risk entirely.

### Historical Context

Wall's original 1960 paper studied the Fibonacci sequence modulo $m$ for arbitrary $m$, establishing what is now called the *Wall-Sun-Sun conjecture*. Carmichael's 1913 theorem predated Wall's work by nearly half a century, using different (and more ad hoc) methods. The modern proof via LTE is cleaner and more general, but requires Wall's result as a black box.

## 6. Connections and Future Directions

1. **Lucas sequences.** Wall's theorem generalizes to arbitrary Lucas sequences $U_n(P, Q)$. Our techniques should extend, replacing Fibonacci-specific identities with the general recurrence.

2. **The Wall-Sun-Sun conjecture.** A prime $p$ is called a Wall-Sun-Sun prime if $p^2 \mid F(p - (p/5))$. It is conjectured that no such primes exist. If true, this would imply that $v_p(F(\alpha(p))) = 1$ for all primes $p$, simplifying our base case.

3. **Algebraic number theory.** The proof can be recast in terms of the ring $\mathbb{Z}[\phi]$ where $\phi = (1+\sqrt{5})/2$, using the LTE lemma for $x^n - y^n$ in Dedekind domains. This perspective connects Fibonacci divisibility to the arithmetic of real quadratic fields.

4. **Formal mathematics.** This formalization contributes to the growing body of formally verified number theory in Lean/Mathlib, alongside results like the infinitude of primes, quadratic reciprocity, and the proof of Fermat's Last Theorem for regular primes.

## References

1. R. D. Carmichael, "On the numerical factors of the arithmetic forms $\alpha^n \pm \beta^n$," *Annals of Mathematics*, 1913.
2. D. D. Wall, "Fibonacci series modulo $m$," *The American Mathematical Monthly*, 67(6), 1960.
3. The Mathlib Community, *Mathlib: The Lean Mathematical Library*, https://leanprover-community.github.io/mathlib4_docs/.
