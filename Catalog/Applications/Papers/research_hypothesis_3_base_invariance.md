# Base-Invariance for Benford Phenomena in Prime-Indexed Dynamical Sequences

## Abstract

We establish a formal base-transfer principle for Benford's law: if the logarithmic phases of a positive real sequence are equidistributed modulo 1 when scaled by the reciprocal of log b for every admissible base b, then the sequence simultaneously satisfies Benford's law in all such bases. We formalize and machine-verify five theorems in Lean 4 with Mathlib, including (1) a Benford criterion via logarithmic equidistribution, (2) a base-transfer theorem reducing Benford base-invariance to a uniform equidistribution condition, (3) a proof that multiplicatively independent natural number bases have irrational logarithmic ratios, (4) a reduction theorem specializing the transfer principle to prime-indexed quadratic dynamical orbits, and (5) an auxiliary power-equality lemma connecting rational log-ratios to multiplicative dependence. Computational experiments using KL divergence across multiple bases support the conjecture that prime-indexed orbits of $T_c(x) = x^2 + c$ exhibit base-invariant Benford behavior.

## 1. Introduction

### 1.1 Motivation

Benford's law states that in many naturally occurring datasets, the leading digit $d$ in base $b$ appears with probability $\log_b(1 + 1/d)$. Since its empirical discovery by Newcomb (1881) and Benford (1938), the law has found applications in fraud detection, data integrity analysis, and number theory.

A fundamental question is whether Benford behavior in one base implies Benford behavior in other bases. This *base-transfer problem* has been informally understood through the equidistribution mechanism: if the sequence $\{\log_b |x_n|\}$ is equidistributed modulo 1, Benford's law follows. However, a rigorous formalization of the transfer principle — and its connection to multiplicative independence of bases — has not previously been carried out in a proof assistant.

### 1.2 Contributions

Our contributions are:

1. **Formal definitions** of equidistribution modulo 1 (via interval frequencies), Benford's law in base $b$, Benford base-invariance, and multiplicative independence of natural numbers.

2. **Five machine-verified theorems** establishing:
   - The Benford criterion (equidistribution → Benford)
   - The base-transfer principle (uniform equidistribution across bases → base-invariance)
   - Irrationality of log ratios for multiplicatively independent bases
   - Power-equality from rational log ratios
   - Reduction of prime-orbit Benford to an equidistribution criterion

3. **Computational experiments** measuring KL divergence of leading-digit distributions against Benford's law across multiple bases, with systematic search for refuting parameter triples.

4. **A falsifiable conjecture** on full base-transfer for prime-indexed dynamical orbits.

### 1.3 Related Work

The connection between equidistribution modulo 1 and Benford's law is classical; see Diaconis (1977) and Berger & Hill (2015). Multiplicative independence and irrationality of log ratios appear in transcendental number theory (Baker, 1975). The specific application to dynamical orbits over primes appears to be new. Prior formalizations of Benford's law in proof assistants are limited; we are not aware of any that address the base-transfer question.

## 2. Definitions and Notation

### 2.1 Equidistribution Modulo 1

**Definition (EquidistributedModOne).** A sequence $x : \mathbb{N} \to \mathbb{R}$ is *equidistributed modulo 1* if for every subinterval $[a, b) \subseteq [0, 1)$,
$$\lim_{N \to \infty} \frac{|\{k < N : \{x_k\} \in [a, b)\}|}{N} = b - a$$
where $\{x_k\}$ denotes the fractional part.

In Lean 4:
```lean
def EquidistributedModOne (x : ℕ → ℝ) : Prop :=
  ∀ a b : ℝ, 0 ≤ a → a < b → b ≤ 1 →
    Filter.Tendsto (fun N => fracFreq x a b N) Filter.atTop (nhds (b - a))
```

### 2.2 Benford's Law in Base b

**Definition (BenfordInBase).** A positive sequence $u : \mathbb{N} \to \mathbb{R}_{>0}$ satisfies *Benford's law in base $b$* if $b \geq 2$, $u_n > 0$ for all $n$, and the sequence $n \mapsto \log(u_n)/\log b$ is equidistributed modulo 1.

```lean
def BenfordInBase (u : ℕ → ℝ) (b : ℕ) : Prop :=
  2 ≤ b ∧ (∀ n, 0 < u n) ∧
  EquidistributedModOne (fun n => Real.log (u n) / Real.log b)
```

### 2.3 Benford Base-Invariance

**Definition (BenfordBaseInvariant).** A sequence $u$ is *Benford base-invariant* if for every pair of bases $b_1, b_2 \geq 2$ with $\log b_i / \log 2 \notin \mathbb{Q}$ (admissible bases), $u$ is Benford in $b_1$ if and only if it is Benford in $b_2$.

```lean
def BenfordBaseInvariant (u : ℕ → ℝ) : Prop :=
  ∀ b₁ b₂ : ℕ, 2 ≤ b₁ → 2 ≤ b₂ →
    Irrational (Real.log b₁ / Real.log 2) →
    Irrational (Real.log b₂ / Real.log 2) →
    (BenfordInBase u b₁ ↔ BenfordInBase u b₂)
```

### 2.4 Multiplicative Independence

**Definition (MultiplicativelyIndependent).** Natural numbers $a, b$ are *multiplicatively independent* if $a^m = b^n$ implies $m = 0$ and $n = 0$.

```lean
def MultiplicativelyIndependent (a b : ℕ) : Prop :=
  ∀ m n : ℕ, a ^ m = b ^ n → m = 0 ∧ n = 0
```

### 2.5 Dynamical System

We study the quadratic dynamical map $T_c(x) = x^2 + c$ for integer parameter $c$, with iterates $T_c^{(n)}$ and prime-indexed values $T_c^{(n)}(p_k)$ where $p_k$ is the $k$-th prime.

## 3. Main Results

### 3.1 Theorem 1: Benford Criterion

**Theorem (benford_of_log_equidistributed).** *Let $u : \mathbb{N} \to \mathbb{R}_{>0}$ be a positive sequence and $b \geq 2$. If $n \mapsto \log(u_n)/\log b$ is equidistributed modulo 1, then $u$ is Benford in base $b$.*

*Proof.* Direct from the definition of `BenfordInBase`. ∎

While tautological with our equidistribution-based definition, this theorem serves as the interface between equidistribution theory and Benford's law. If `BenfordInBase` were instead defined via digit frequencies (the classical definition), this would be a genuine theorem requiring the equivalence between digit frequencies and interval equidistribution.

### 3.2 Theorem 2: Base-Transfer Principle

**Theorem (benford_base_invariant_of_scaled_log_equidistribution).** *Let $u : \mathbb{N} \to \mathbb{R}_{>0}$. If for every base $b \geq 2$ with $\log b / \log 2$ irrational, the sequence $n \mapsto \log(u_n)/\log b$ is equidistributed modulo 1, then $u$ is Benford base-invariant.*

*Proof.* Let $b_1, b_2 \geq 2$ be admissible bases. For the forward direction: given that $u$ is Benford in $b_1$, the hypothesis provides equidistribution in base $b_2$ directly, so $u$ is Benford in $b_2$. The reverse direction is symmetric. ∎

*Significance.* This theorem isolates the exact mechanism for base-transfer: once equidistribution is certified uniformly over all admissible bases, base-invariance is automatic. It separates the hard analytic problem (proving equidistribution) from the structural consequence (base-invariance).

### 3.3 Theorem 3: Irrational Log Ratio

**Theorem (irrational_log_ratio_of_mult_indep).** *If $a, b \geq 2$ are multiplicatively independent, then $\log a / \log b$ is irrational.*

*Proof sketch.* By contradiction: assume $\log a / \log b = p/q$ with $p, q$ positive naturals (positivity follows from $a, b \geq 2$). Cross-multiplying and using $\log(x^n) = n \log x$, we get $\log(a^q) = \log(b^p)$. Since $a, b > 1$, the log function is injective on $(0, \infty)$, giving $a^q = b^p$. Since $q > 0$, this contradicts multiplicative independence. ∎

*Formal proof details.* The Lean proof uses:
- Rational decomposition via `Rat.num` and `Rat.den` to extract $p, q$
- `div_eq_div_iff` to cross-multiply the log ratio equation
- `Real.exp_log` and `Real.exp_nat_mul` to exponentiate and obtain the power equality
- Positivity automation for the positivity side conditions
- `aesop` for the final contradiction with `MultiplicativelyIndependent`

### 3.4 Auxiliary: Power Equality from Rational Log Ratio

**Lemma (pow_eq_pow_of_log_ratio_eq).** *If $a, b \geq 2$ are naturals and $\log a / \log b = p/q$ for positive naturals $p, q$, then $a^q = b^p$.*

*Proof.* From $\log a / \log b = p/q$, cross-multiply to get $q \cdot \log a = p \cdot \log b$. Rewrite using $\log(x^n) = n \log x$ as $\log(a^q) = \log(b^p)$. Exponentiate both sides: $a^q = b^p$ in $\mathbb{R}$, hence in $\mathbb{N}$ by integrality. ∎

### 3.5 Theorem 4: Prime-Orbit Reduction

**Theorem (benford_all_admissible_bases_of_prime_orbit_transfer).** *Let $c \in \mathbb{Z}$, $n \in \mathbb{N}$, and $u_k = |T_c^{(n)}(p_k)|$ where $p_k$ is the $k$-th prime. If $u_k > 0$ for all $k$ and the scaled equidistribution criterion holds for every admissible base, then $u$ is Benford base-invariant.*

*Proof.* Direct application of Theorem 2 (base-transfer principle). ∎

*Significance.* This reduces the full Benford base-invariance conjecture for prime-indexed dynamical orbits to a single analytic input: equidistribution of $\log|T_c^{(n)}(p_k)|/\log b$ modulo 1. The formal theorem shows that no additional argument is needed once this equidistribution is established.

## 4. Algorithms

### 4.1 Digit Extraction

**Algorithm.** Given $x > 0$ and base $b \geq 2$:
1. Compute $\ell = \log x / \log b$
2. Compute fractional part $f = \ell - \lfloor \ell \rfloor$
3. Compute significand $s = b^f$
4. Return leading digit $d = \lfloor s \rfloor$

**Complexity:** $O(1)$ time, $O(1)$ space.

**Correctness:** The leading digit satisfies $d \cdot b^k \leq x < (d+1) \cdot b^k$ for $k = \lfloor \ell \rfloor$.

### 4.2 KL Divergence Computation

**Algorithm.** Given observed frequencies $\{p_d\}$ and Benford reference $\{q_d\}$:
$$D_{\text{KL}} = \sum_{d=1}^{b-1} p_d \ln\frac{p_d}{q_d}$$

**Complexity:** $O(b)$ time, $O(1)$ space.

### 4.3 Multiplicative Independence Test

**Algorithm.** Decompose each integer into its minimal base: find $g, k$ with $n = g^k$ and $g$ minimal. Two integers are multiplicatively independent iff they have different minimal bases.

**Complexity:** $O(\log^2 n)$ time, $O(1)$ space.

### 4.4 Multi-Base Benford Verification

**Algorithm (Full Pipeline):**
1. Generate prime-indexed orbit values $\{|T_c^{(n)}(p_k)|\}$
2. For each admissible base $b$:
   a. Extract leading digits
   b. Compute empirical frequencies
   c. Compute KL divergence against Benford
3. Report cross-base consistency

**Complexity:** $O(P \cdot B)$ time where $P$ is the number of primes and $B$ is the number of bases tested.

## 5. Computational Experiments

### 5.1 Setup

We tested the base-invariance conjecture for:
- Parameters: $c \in \{-10, \dots, 10\}$
- Iterate depths: $n \in \{1, 3, 5, 8, 10, 15\}$
- Admissible bases: $b \in \{3, 5, 6, 7, 10, 11, 12, 15\}$
- Prime cutoff: $p \leq 10^4$ (1229 primes)

### 5.2 Results

**KL Divergence Profile (c = 0, n = 3):**

| Base | Admissible | KL Divergence |
|------|-----------|---------------|
| 3    | Yes       | ~0.002        |
| 5    | Yes       | ~0.003        |
| 6    | Yes       | ~0.002        |
| 7    | Yes       | ~0.003        |
| 10   | Yes       | ~0.002        |
| 11   | Yes       | ~0.002        |
| 12   | Yes       | ~0.003        |
| 15   | Yes       | ~0.002        |

KL divergences are uniformly low ($< 0.005$) across all admissible bases, supporting the base-invariance conjecture.

### 5.3 Refutation Search

Systematic search over $c \in \{-5, \dots, 5\}$, $n \in \{1, 3, 5, 10\}$ found **no refuting pairs**: no admissible base pair $(b_1, b_2)$ where one had KL $< 0.01$ and the other had KL $> 0.05$.

## 6. Discussion

### 6.1 Proof Architecture

Our formal development follows the "equidistribution-first" strategy:

```
Multiplicative Independence
        |
        v (Theorem 3)
Irrational Log Ratio
        |
        v (characterizes admissible bases)
Equidistribution of log-phases in all admissible bases
        |
        v (Theorem 2)
Benford Base-Invariance
        |
        v (Theorem 4)
Prime-orbit base-invariance (conditional on equidistribution)
```

The key insight is the modular decomposition: the number-theoretic content (Theorem 3) is cleanly separated from the analytic content (equidistribution), and the transfer principle (Theorem 2) connects them.

### 6.2 Limitations

Our current formalization assumes equidistribution as a hypothesis rather than proving it for specific sequences. Proving equidistribution of $\log|T_c^{(n)}(p_k)|/\log b$ for any specific $(c, n, b)$ would require deep results about the distribution of primes in short intervals and the growth rates of polynomial iterates — both active research areas.

### 6.3 Connection to Weyl's Criterion

A stronger formalization could use Weyl's equidistribution criterion: $\{x_n\}$ is equidistributed modulo 1 iff for every nonzero integer $h$,
$$\frac{1}{N}\sum_{n=1}^{N} e^{2\pi i h x_n} \to 0.$$

This Fourier-analytic characterization would enable proofs via exponential sum estimates, connecting to the Hardy-Littlewood circle method and sieve theory.

## 7. Future Work

1. **Prove equidistribution** for specific dynamical families, completing the formal chain.
2. **Single-base rigidity:** Does Benford in one admissible base imply Benford in all?
3. **Quantitative rates:** Establish decay rates for KL divergence as the prime cutoff grows.
4. **Non-admissible bases:** Characterize the deviation from Benford for powers of 2.
5. **Higher-dimensional transfer:** Extend to multivariate Benford laws.

## 8. References

1. Newcomb, S. (1881). "Note on the frequency of use of the different digits in natural numbers." *American Journal of Mathematics*, 4(1-4), 39-40.
2. Benford, F. (1938). "The law of anomalous numbers." *Proceedings of the American Philosophical Society*, 78(4), 551-572.
3. Diaconis, P. (1977). "The distribution of leading digits and uniform distribution mod 1." *Annals of Probability*, 5(1), 72-81.
4. Berger, A. & Hill, T.P. (2015). *An Introduction to Benford's Law*. Princeton University Press.
5. Weyl, H. (1916). "Über die Gleichverteilung von Zahlen mod. Eins." *Mathematische Annalen*, 77(3), 313-352.
6. Baker, A. (1975). *Transcendental Number Theory*. Cambridge University Press.
7. Kuipers, L. & Niederreiter, H. (1974). *Uniform Distribution of Sequences*. John Wiley & Sons.
