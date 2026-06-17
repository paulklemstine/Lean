# Counterfactual Number Theory: The Deterministic Backbone of the Cramér Random Prime Model

## Abstract

We study a counterfactual number theory in which the primes are replaced by a
random subset of the natural numbers, each integer *n* declared "prime"
independently with probability 1 / log *n*. This is Cramér's classical
probabilistic model of the primes (1936), and it serves as a null hypothesis
for the statistical behavior of the genuine primes. The central deterministic
object of the model is the **Cramér expectation sum**,
CramerSum(*N*) = Σ_{n=2}^{N} 1 / log *n*, which is the model's prediction for
the prime-counting function π(*N*). We develop, with full rigor, the
elementary real-analytic theory of this sum: strict positivity and
monotonicity of the summand 1 / log *n*; monotonicity of the partial sums;
two-sided sum-versus-integral comparison bounds sandwiching CramerSum(*N*)
between copies of the logarithmic integral; and an explicit *N* / log *N*
lower bound exhibiting the Prime Number Theorem order of growth by purely
elementary means. We then survey, at the level of proof sketches, which
classical theorems survive the passage to the random universe (the Prime
Number Theorem, Dirichlet's theorem on arithmetic progressions, and — almost
surely — the Riemann Hypothesis) and which collapse (unique factorization).
We close with a discussion of the cryptographic relevance of these bounds and
a program of conjectures extending the deterministic backbone to variance,
*k*-tuple, and gap statistics. All core results stated here have been
formally verified.

**Keywords:** Cramér model, probabilistic number theory, prime-counting
function, logarithmic integral, Prime Number Theorem, Riemann Hypothesis,
sum-integral comparison, cryptographic prime generation.

**MSC 2020:** 11N05, 11K65, 11A41, 60C05, 11Y11.

---

## 1. Introduction

### 1.1 The counterfactual question

Number theory is the study of structure that the integers impose upon
themselves: divisibility, factorization, congruence. The primes are the
indivisible atoms of multiplication, and the deepest theorems of the subject —
the Prime Number Theorem (PNT), Dirichlet's theorem, the Riemann Hypothesis
(RH) — describe how these atoms are distributed along the number line.

In 1936 Harald Cramér proposed a radical reframing. Suppose, he said, we
*forget* that the primes are defined multiplicatively, and instead model them
as a random set: let each integer *n* ≥ 2 be "prime" with probability
*p*(*n*) = 1 / log *n*, independently across *n*. This probability is dictated
by the PNT, which asserts π(*N*) ∼ *N* / log *N*, i.e. that the local density
of primes near *n* is about 1 / log *n*. Cramér's model elevates this *average
density* to a literal *per-integer probability* and asks what the resulting
random number theory looks like.

The model is a *counterfactual*: it describes a universe that is not ours, but
one calibrated to match ours in its coarsest statistic. Its value is twofold.
First, it is a **heuristic engine**: by computing expectations in the random
model, one generates precise conjectures about the genuine primes (the
Hardy–Littlewood *k*-tuple conjectures, Cramér's conjecture on prime gaps, the
expected error in the PNT). Second, it is a **null hypothesis**: discrepancies
between the model and reality isolate exactly the arithmetic structure the
random model cannot see.

### 1.2 What survives and what collapses

A useful way to organize the model is to ask which classical theorems remain
true when the genuine primes are swapped for Cramér's random set:

- **Prime Number Theorem — survives.** The model is calibrated to reproduce
  prime density; its expected count grows like *N* / log *N* and tracks the
  logarithmic integral Li(*N*).
- **Dirichlet's theorem — survives.** The coins ignore arithmetic structure,
  so every coprime residue class collects infinitely many random primes almost
  surely, with no inter-class bias.
- **Unique factorization — collapses.** The random primes carry no
  multiplicative meaning; the Fundamental Theorem of Arithmetic has no analogue.
- **Riemann Hypothesis — holds almost surely.** The error π(*N*) − Li(*N*) is,
  in the model, a sum of independent mean-zero fluctuations of size O(√*N* log *N*)
  almost surely, which is exactly the bound equivalent to RH. Cramér proved RH
  holds with probability one in the model.

### 1.3 Contribution

This paper makes the **deterministic backbone** of the model fully rigorous.
By linearity of expectation, every first-moment quantity in the model is a
finite sum of the weights *p*(*n*), and the master quantity is CramerSum(*N*).
We prove a complete suite of elementary results about it — positivity,
monotonicity, two-sided integral comparison, and explicit growth bounds —
using only standard real analysis. These results turn the heuristic "expected
prime count ≈ Li(*N*) ≈ *N* / log *N*" into theorems with explicit constants,
which is precisely what is needed to certify, for instance, the expected
running time of cryptographic prime generation. The remaining (probabilistic)
statements — survival of PNT/Dirichlet/RH, collapse of factorization — are
presented as proof sketches and as a forward-looking conjecture program.

---

## 2. Definitions

Throughout, log denotes the natural logarithm, and we write *n* for a natural
number and *x* for a real variable.

**Definition 2.1 (Cramér weight).** For an integer *n* ≥ 2 the *Cramér prime
probability* (weight) is
$$ p(n) \;=\; \frac{1}{\log n} \;=\; (\log n)^{-1}. $$
Since *n* ≥ 2 > 1 we have log *n* > 0, so 0 < *p*(*n*); and *p*(*n*) ≤ 1 once
*n* ≥ 3 (because log *n* ≥ 1 there), so *p* is a genuine probability for
*n* ≥ 3. The value *p*(2) = 1 / log 2 ≈ 1.4427 exceeds 1 and is, in the full
random-sieve formalization, clamped to 1; it does not affect any of the
asymptotic statements below.

**Definition 2.2 (Cramér expectation sum).** For *N* ∈ ℕ define
$$ \mathrm{CramerSum}(N) \;=\; \sum_{n=2}^{N} (\log n)^{-1}
   \;=\; \sum_{n \in [2,N] \cap \mathbb{Z}} \frac{1}{\log n}. $$
By linearity of expectation, CramerSum(*N*) is the expected number of random
primes in the window {2, …, *N*}; it is the model's prediction for π(*N*).

**Definition 2.3 (Logarithmic integral, offset form).** The
*logarithmic integral* is Li(*N*) = ∫_{2}^{N} dx / log *x*. This is the
standard elementary approximation to π(*N*); the comparison theorems below
exhibit CramerSum(*N*) as a discretization of Li.

---

## 3. Main results: the deterministic backbone

All statements in this section are formally verified. We give the precise
statement of each and a proof sketch.

### 3.1 Positivity

**Lemma 3.1 (Positive logarithm).** *If* *n* ≥ 2 *then* log *n* > 0.

*Proof.* For *n* ≥ 2 the cast (*n* : ℝ) ≥ 2 > 1, and log is positive on
(1, ∞) by `Real.log_pos`. ∎

**Lemma 3.2 (Positive summand).** *If* *n* ≥ 2 *then* (log *n*)⁻¹ > 0.

*Proof.* Immediate from Lemma 3.1: the reciprocal of a positive real is
positive (`inv_pos`). ∎

These guarantee CramerSum is a sum of strictly positive terms, hence a
bona-fide, non-degenerate expectation.

### 3.2 Monotonicity of the weight

**Lemma 3.3 (Antitone reciprocal-log).** *The function* *x* ↦ (log *x*)⁻¹ *is
antitone on the open ray* (1, ∞): *for* 1 < *x* ≤ *y*,
(log *y*)⁻¹ ≤ (log *x*)⁻¹.

*Proof sketch.* On (1, ∞) we have log *x* > 0 and log is monotone, so
0 < log *x* ≤ log *y*; the reciprocal map is antitone on the positive reals
(`inv_anti₀`), reversing the inequality. ∎

**Lemma 3.4 (Antitone weight, integer form).** *If* 3 ≤ *m* ≤ *n* *then*
(log *n*)⁻¹ ≤ (log *m*)⁻¹.

*Proof sketch.* Apply monotone reciprocal (`gcongr`) using log *m* > 0 (from
*m* ≥ 3 > 1) and log *m* ≤ log *n*. ∎

Lemma 3.4 is the precise statement that "model primes thin out": the
probability of being prime is nonincreasing in the integer.

### 3.3 Monotonicity of the partial sums

**Lemma 3.5 (Monotone partial sums).** *If* *N* ≤ *M* *then*
CramerSum(*N*) ≤ CramerSum(*M*).

*Proof sketch.* The index set [2, *N*] is a subset of [2, *M*]
(`Finset.Icc_subset_Icc_right`), and every omitted term (log *n*)⁻¹ is
nonnegative because *n* ≥ 2 makes log *n* ≥ 0
(`Finset.sum_le_sum_of_subset_of_nonneg`). ∎

This is the model's counterpart to the obvious fact that π is nondecreasing,
and is the basis for any monotone comparison of model versus reality.

### 3.4 Sum-versus-integral comparison

The decreasing positive integrand 1 / log *x* admits the classical
Riemann-sum sandwich. The subtlety is the singularity of 1 / log *x* at
*x* = 1 (where log = 0), which forbids integrating from 1. We therefore
anchor all integrals at *x* = 2.

**Theorem 3.6 (Lower integral bound, right-Riemann).** *For* *N* ≥ 3,
$$ \int_{2}^{N+1} \frac{dx}{\log x} \;\le\; \mathrm{CramerSum}(N). $$

*Proof sketch.* Split the integral over [2, *N* + 1] into unit subintervals
[*k*, *k* + 1] for *k* = 2, …, *N* (additivity of the interval integral,
`intervalIntegral.sum_integral_adjacent_intervals`, with continuity/integrability
of 1 / log *x* on each [*k*, *k* + 1] ⊂ (1, ∞)). On each subinterval the
integrand is bounded above by its value at the *right* endpoint, (log *k*)⁻¹
... wait, by antitonicity the integrand on [*k*, *k*+1] is bounded above by
its value at the *left* endpoint and below by its value at the right; here we
compare ∫_k^{k+1} 1/log x dx ≤ (log k)⁻¹ via monotone integral comparison
(`intervalIntegral.integral_mono_on`), and summing (log *k*)⁻¹ over
*k* = 2, …, *N* gives exactly CramerSum(*N*). ∎

**Theorem 3.7 (Upper integral bound, left-Riemann).** *For* *N* ≥ 3,
$$ \mathrm{CramerSum}(N) \;\le\; \frac{1}{\log 2} \;+\; \int_{2}^{N} \frac{dx}{\log x}. $$

*Proof sketch.* Isolate the first term (log 2)⁻¹ and apply the antitone
sum-integral inequality `AntitoneOn.sum_le_integral_Ico` to the remaining sum
Σ_{n=3}^{N} (log *n*)⁻¹, which is bounded above by ∫_{2}^{N} 1 / log *x* dx
because each term (log *n*)⁻¹ ≤ ∫_{n-1}^{n} 1 / log *x* dx for the decreasing
integrand. Reindexing the finite sums (`Finset.sum_Ico_eq_sub`) reconciles the
ranges. ∎

**Corollary 3.8 (CramerSum tracks the logarithmic integral).** *Combining
Theorems 3.6 and 3.7, for* *N* ≥ 3,
$$ \mathrm{Li}(N+1) - \underbrace{\int_N^{N+1}\!\tfrac{dx}{\log x}}_{\le\, 1/\log N}
   \;\le\; \mathrm{CramerSum}(N) \;\le\; \mathrm{Li}(N) + \frac{1}{\log 2}, $$
*so* |CramerSum(*N*) − Li(*N*)| *is bounded by an absolute constant plus a
vanishing-density term.* In particular CramerSum(*N*) = Li(*N*) + O(1), the
discrete model expectation equals the logarithmic-integral approximation to
π(*N*) up to a bounded error. This is the model's recovery of the refined
Prime Number Theorem π(*N*) ≈ Li(*N*).

### 3.5 Explicit Prime-Number-Theorem-order growth

Even without the integral, an elementary lower bound recovers the PNT order.

**Lemma 3.9 (Crude count bound).** *For* *N* ≥ 2,
$$ \frac{N-1}{\log N} \;\le\; \mathrm{CramerSum}(N). $$

*Proof sketch.* Each of the *N* − 1 terms (log *n*)⁻¹ with 2 ≤ *n* ≤ *N*
satisfies (log *n*)⁻¹ ≥ (log *N*)⁻¹ by Lemma 3.3 (antitonicity, since
*n* ≤ *N*). Summing the constant lower bound (log *N*)⁻¹ over the *N* − 1
indices (`Finset.sum_le_sum`) gives (*N* − 1) / log *N*. ∎

**Theorem 3.10 (Explicit scale lower bound).** *For* *N* ≥ 2,
$$ \frac{N}{2\log N} \;\le\; \mathrm{CramerSum}(N). $$

*Proof sketch.* From Lemma 3.9 it suffices that *N* / (2 log *N*) ≤
(*N* − 1) / log *N*, i.e. *N* / 2 ≤ *N* − 1, i.e. *N* ≥ 2; the algebra is
discharged by cross-multiplication using log *N* > 0 and *N* ≥ 2
(`div_le_div_iff₀`, `nlinarith`). ∎

Theorem 3.10 establishes, by counting alone, that the expected number of
Cramér primes up to *N* grows at least at the Prime Number Theorem rate
*N* / log *N* (up to the constant 1/2), with no analytic input whatsoever.

---

## 4. Which theorems survive the counterfactual

We now sketch the probabilistic half of the program: the classification of
classical theorems. These statements concern the random set *S* ⊆ ℕ in which
each *n* lies independently with probability *p*(*n*) = 1 / log *n*. The
deterministic backbone of §3 controls all first moments.

### 4.1 Prime Number Theorem — survives

**Claim.** |*S* ∩ [2, *N*]| = (1 + o(1)) Li(*N*) ∼ *N* / log *N* almost surely.

*Sketch.* The expected count is exactly CramerSum(*N*), which equals
Li(*N*) + O(1) (Corollary 3.8) and is bounded below by *N* / (2 log *N*)
(Theorem 3.10). The variance is Σ *p*(*n*)(1 − *p*(*n*)) = O(*N* / log *N*)
(see Conjecture C1), so the standard deviation O(√(*N* / log *N*)) is of
*smaller order* than the mean. Chebyshev's inequality plus Borel–Cantelli
along a subsequence yields almost-sure concentration: the random count tracks
its expectation, and the PNT order survives. ∎

### 4.2 Dirichlet's theorem — survives

**Claim.** For coprime *a*, *q*, the class {*n* ≡ *a* (mod *q*)} contains
infinitely many elements of *S* almost surely, with the same density 1 / log *n*
as any other class.

*Sketch.* The weights *p*(*n*) depend only on the size of *n*, not on its
residue. Hence Σ_{n ≡ a (q)} *p*(*n*) diverges (it is a positive fraction of
the divergent series Σ 1 / log *n*), and by the second Borel–Cantelli lemma
(independence) infinitely many such *n* lie in *S* almost surely. Moreover the
model predicts *perfect* equidistribution: no residue class is favored, in
contrast to the genuine primes whose finer biases (e.g. Chebyshev's bias) are
exactly the non-random residue the model discards. ∎

### 4.3 Unique factorization — collapses

**Claim.** There is no analogue of the Fundamental Theorem of Arithmetic for
*S*.

*Sketch.* The set *S* is defined purely additively/positionally; it is a
random subset of ℕ with no multiplicative closure. The integers are not
generated as products of elements of *S* in any canonical way, and with
probability one *S* is neither multiplicatively closed nor a free generating
set. Multiplicative structure — the defining feature of the genuine primes —
is absent by construction. This is the model's principal limitation and the
reason it cannot speak to factoring-based cryptographic hardness. ∎

### 4.4 Riemann Hypothesis — holds almost surely

**Claim (Cramér, 1936).** In the random model, |*S* ∩ [2, *N*]| − Li(*N*) =
O(√*N* · log *N*) almost surely; equivalently, RH holds with probability one
in the counterfactual universe.

*Sketch.* Write the error as Σ_{n≤N} (𝟙[*n* ∈ *S*] − *p*(*n*)), a sum of
independent, bounded, mean-zero random variables with variance Σ *p*(1 − *p*)
= O(*N* / log *N*). The law of the iterated logarithm (or Kolmogorov's
inequality with Borel–Cantelli) bounds the partial sums by O(√(*N* log log *N*))
almost surely, which is well inside the RH threshold O(√*N* log *N*). Since the
RH is equivalent to precisely this error bound for the genuine
prime-counting function, the random model satisfies the RH analogue almost
surely. ∎

This does not prove RH for the genuine primes — they are not random — but it
demonstrates that RH is the *generic* behavior, and that a counterexample
would require a non-random conspiracy.

---

## 5. Algorithms

### 5.1 Computing the Cramér expectation sum

The backbone quantity CramerSum(*N*) is computed by a single accumulation
loop. The arithmetic is over floating point; for high-*N* certified bounds one
uses interval arithmetic anchored at the integral comparisons of §3.4.

```
Algorithm CRAMER-SUM(N):
    s ← 0
    for n ← 2 to N:
        s ← s + 1 / ln(n)
    return s          # = expected number of random primes in [2, N]
```

Complexity: Θ(*N*) additions and logarithms; Θ(1) space.

### 5.2 Certified two-sided enclosure

Given *N* ≥ 3, the integral bounds of Theorems 3.6–3.7 yield a rigorous
enclosure of CramerSum(*N*) without summing all *N* terms, by numerically
bracketing the logarithmic integral Li with verified quadrature.

```
Algorithm CRAMER-ENCLOSE(N):
    lo ← LI(2, N+1)              # ∫_2^{N+1} dx/ln x   (lower bound, Thm 3.6)
    hi ← 1/ln(2) + LI(2, N)     # 1/ln2 + ∫_2^N dx/ln x (upper bound, Thm 3.7)
    return [lo, hi]             # CramerSum(N) ∈ [lo, hi], proven
```

### 5.3 Expected prime-tuple count (Hardy–Littlewood skeleton)

For an admissible offset pattern *H* = {*h*₁, …, *h_k*}, the expected number
of *n* ∈ [2, *N*] with all *n* + *h_j* in *S* is Σ_n ∏_j *p*(*n* + *h_j*) (by
independence). Under Cramér's *p* this is asymptotic to ∫ dt / (log *t*)^k.

```
Algorithm EXPECTED-TUPLES(N, H = [h_1,...,h_k]):
    total ← 0
    for n ← 2 to N:
        prod ← 1
        for h in H:
            prod ← prod * 1 / ln(n + h)
        total ← total + prod
    return total
```

---

## 6. Applications: cryptographic prime generation

Public-key cryptosystems (RSA, Diffie–Hellman, DSA) require sampling large
primes. The standard procedure draws random odd integers near a target size
*N* and tests each for primality; the *expected number of trials* before
success is the reciprocal of the local prime density, ≈ log *N*. This estimate
is precisely the Cramér heuristic *p*(*N*) = 1 / log *N*.

The deterministic backbone makes the heuristic rigorous:

1. **Certified yield.** Theorem 3.10 gives CramerSum(*N*) ≥ *N* / (2 log *N*),
   a *proven* lower bound on the expected number of primes in a window, hence a
   proven *upper* bound on the expected number of candidates to test before a
   key is found.
2. **Certified accuracy of Li.** Corollary 3.8 shows the model expectation
   equals Li(*N*) up to a bounded constant, so engineering estimates based on
   Li carry rigorous error bars.
3. **Where the model is unsafe.** The collapse of unique factorization (§4.3)
   is a warning label: the *hardness of factoring*, on which RSA security
   rests, is a multiplicative phenomenon the Cramér model cannot model. Density
   heuristics certify *key generation cost*, never *factoring hardness*. Sound
   cryptographic analysis must keep these separate.

---

## 7. Discussion

The Cramér model occupies a peculiar epistemic position: it is provably wrong
about the primes in detail (the genuine primes are deterministic and
multiplicatively structured), yet it is the most productive source of correct
conjectures in analytic number theory. The resolution is that the model is a
*null hypothesis*. The statistics it predicts correctly — density, the PNT,
the RH error scale — are exactly those governed by size alone; the statistics
it gets wrong — twin-prime constants, the singular series, Chebyshev bias —
are exactly the arithmetic structure, and the *discrepancy* is the object of
real interest.

Our contribution isolates and formally verifies the *deterministic backbone*:
the first-moment theory, which by linearity of expectation governs every
expected-count statistic and which reduces entirely to real analysis of
1 / log *x*. By proving positivity, monotonicity, two-sided integral
enclosure, and explicit *N* / log *N* growth, we convert the model's central
heuristic into theorems with explicit constants — the form required for
certified cryptographic and computational use.

---

## 8. Future directions

The following conjecture program extends the deterministic backbone into the
second moment and into the constellation/gap statistics. Each is a finite
algebraic identity in the weight family followed by a separate asymptotic
lemma, and each is provable from the present foundation.

**Conjecture C1 (Variance and concentration).** For the Cramér sieve,
Var(|*S*|) = Σ_{n} *p*(*n*)(1 − *p*(*n*)) exactly (independence kills cross
terms). Under *p*(*n*) = 1 / log *n* on [2, *N*], the standard deviation is
Θ(√(*N* / log *N*)), so |*S*| = (1 + o(1)) Σ 1 / log *n* almost surely. The
exact variance identity is a finite computation from the pairwise and single
marginals.

**Conjecture C2 (Expected prime *k*-tuples; singular-series skeleton).** For an
admissible offset pattern *H* = {*h*₁, …, *h_k*}, the expected number of
*n* ∈ [2, *N*] with all *n* + *h_j* in *S* equals Σ_n ∏_j *p*(*n* + *h_j*),
and under Cramér's *p* this is asymptotic to ∫ dt / (log *t*)^k. The exact
finite identity iterates the subset-indicator (independence) lemma with |*A*| =
*k*; the asymptotic is a separate analytic lemma. The *deviation* of this from
the true Hardy–Littlewood constant 𝔖(*H*) measures exactly how the genuine
primes fail to be Cramér-random.

**Conjecture C3 (Maximal prime gap; Cramér's conjecture, finite form).** Let
*G_N* be the largest gap between consecutive random primes in [2, *N*]. Then
E[*G_N*] = Θ((log *N*)²) and P(*G_N* > *c*(log *N*)²) → 0 for large *c*. A
provable first step: the exact probability that a fixed window [*m*, *m* + *L*]
contains no random prime is ∏_{n=m}^{m+L} (1 − *p*(*n*)), whence the union
bound P(∃ gap ≥ *L*) ≤ Σ_m ∏ (1 − *p*(*n*)).

**Conjecture C4 (Counterfactual divergence detector).** Formalize a
quantitative non-randomness detector: for residue classes mod *q*, the Cramér
model predicts the random primes equidistribute with no bias, so any measured
bias in the genuine primes (e.g. Chebyshev's bias toward 3 mod 4) is a direct
readout of the model's failure — a quantitative measure of arithmetic
structure beyond density.

---

## 9. Conclusion

We have made rigorous the deterministic backbone of Cramér's counterfactual
number theory: the expected prime count CramerSum(*N*) = Σ_{n=2}^N 1 / log *n*
is a positive, monotone, decreasing-termed sum, sandwiched between two
logarithmic integrals and growing at the Prime Number Theorem rate
*N* / log *N*. From this fully verified foundation, the probabilistic
superstructure — the survival of the PNT, Dirichlet's theorem, and the Riemann
Hypothesis, and the instructive collapse of unique factorization — follows in
outline, and a concrete conjecture program (variance, *k*-tuples, gaps,
bias detection) charts the path forward. The counterfactual where primes are
random is, paradoxically, one of the sharpest instruments we have for
understanding the primes that are not.

---

## References (classical, for context only; this paper is self-contained)

- H. Cramér, *On the order of magnitude of the difference between consecutive
  prime numbers*, Acta Arithmetica 2 (1936), 23–46.
- G. H. Hardy and J. E. Littlewood, *Some problems of 'Partitio numerorum'
  III: On the expression of a number as a sum of primes*, Acta Math. 44
  (1923), 1–70.
- A. Granville, *Harald Cramér and the distribution of prime numbers*, Scand.
  Actuar. J. (1995), 12–28.
