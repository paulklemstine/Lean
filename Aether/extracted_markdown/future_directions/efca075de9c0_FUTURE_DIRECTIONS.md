# Future Directions: Solitary Numbers and Divisor-Sum Equations

## Conjecture 1: Complete Resolution of the Even-b Parity Obstruction

**Conjecture:** For all even integers $b \geq 2$, the sum $\sigma(5^b) = 1 + 5 + 5^2 + \cdots + 5^b$ is never a perfect square.

**Test:** Verify computationally for $b \leq 10{,}000$. Attempt a proof via the theory of cyclotomic polynomials: $\sigma(5^b) = \Phi_1(5) \cdot \prod_{d \mid (b+1), d > 1} \Phi_d(5)$. By Zsygmondy's theorem, for $b+1 \geq 3$, there exists a primitive prime divisor of $5^{b+1} - 1$ that divides $\sigma(5^b)$ to exactly the first power, preventing it from being a perfect square.

**Impact:** Completing this would close the one remaining gap in the formal proof that 10 is solitary. More broadly, it would establish a general parity obstruction for divisor-sum equations with odd solutions.

## Conjecture 2: Two-Prime Abundancy Rigidity

**Conjecture:** For distinct primes $p < q$, the abundancy class $\sigma(n)/n = \sigma(pq)/(pq) = (p+1)(q+1)/(pq)$ contains only $n = pq$.

**Test:** For all prime pairs $(p, q)$ with $p < q \leq 1000$, search for solutions to $pq \cdot \sigma(m) = (p+1)(q+1) \cdot m$ up to $m = 10^7$. Extract patterns from any counterexamples.

**Impact:** This would generalize the solitude of 10 (the case $p = 2, q = 5$) to an infinite family of solitary semiprimes, establishing a new class of provably solitary numbers.

## Conjecture 3: Density of Solitary Numbers

**Conjecture:** The set of solitary numbers has natural density 1. That is, $\lim_{N \to \infty} |\{n \leq N : n \text{ is solitary}\}| / N = 1$.

**Test:** Compute the fraction of solitary numbers (verified up to bound $B$) for $B = 10^3, 10^4, 10^5, 10^6$. Plot the trend and fit a model. Compare with the density of numbers satisfying $\gcd(n, \sigma(n)) = 1$ (which are automatically solitary).

**Impact:** This would establish that "most" numbers are solitary, reframing friendly numbers as the rare, interesting objects. It connects to deep questions about the distribution of values of multiplicative functions.

## Conjecture 4: Bounded Descent Depth

**Conjecture:** For any reduced fraction $a/b$ with $1 < a/b < 2$, the descent analysis of the equation $b \cdot \sigma(n) = a \cdot n$ terminates (reaching a ratio below 1) within $O(\log(ab))$ steps.

**Test:** Implement the descent algorithm for all reduced fractions $a/b$ with $a, b \leq 100$ and $1 < a/b < 2$. Record the maximum descent depth. Check whether the depth grows logarithmically in $ab$.

**Impact:** A bounded descent depth would yield an effective algorithm for proving equations $b \cdot \sigma(n) = a \cdot n$ have at most finitely many solutions, opening the door to automated solitary-number certification.

## Conjecture 5: Local Congruence Classification for $5 \mid \sigma(p^a)$

**Conjecture:** For a prime $p$ and positive integer $a$, $5 \mid \sigma(p^a) = 1 + p + \cdots + p^a$ if and only if one of the following holds:
- $p \equiv 1 \pmod{5}$ and $5 \mid (a + 1)$
- $p \equiv 2$ or $3 \pmod{5}$ and $4 \mid (a + 1)$ (i.e., $a \equiv 3 \pmod{4}$)
- $p \equiv 4 \pmod{5}$: never (since the sum is always $\equiv 1 \pmod{5}$)

**Test:** Verify for all primes $p \leq 1000$ and exponents $a \leq 100$. Prove the classification using properties of geometric sums modulo 5.

**Impact:** This reusable lemma is a building block for analyzing divisor-sum equations modulo 5, enabling systematic solitary-number proofs for numbers divisible by 5.
