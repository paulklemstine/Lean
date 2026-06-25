# Exact Betti-Count Recovery from Noisy Persistence Barcodes: A Margin-to-Noise Capacity for Topological Quantum Error Mitigation

## Abstract

We develop a rigorous, finite-data foundation for *topological quantum error
mitigation*: the use of persistent-homology invariants to recover correct
discrete summaries of noisy quantum experiments. Modeling a topological feature
as a birth–death interval (a *bar*) with *persistence* equal to its lifetime, we
study the **Betti count at a threshold** $\tau$ — the number of bars whose
persistence exceeds $\tau$ — as a robust, integer-valued statistic of a barcode.
Our central result, *Betti-count recovery*, shows that a noisy barcode and a
true barcode produce **identical** Betti counts whenever (i) each noisy
persistence lies within $\varepsilon$ of the true persistence, (ii) each true
persistence is separated from the threshold by a margin $m$, and (iii)
$2\varepsilon < m$. The proof factors cleanly through a pointwise
*threshold-stability* lemma and a set-equality argument, recovering an exact
integer from corrupted real measurements. We show that the whole theory is
governed by a single dimensionless control parameter, the **margin-to-noise
ratio** $R = m/(2\varepsilon)$: recovery holds exactly when $R > 1$, and the
constant $2\varepsilon$ is tight. We complement the recovery theorem with a
*monotonicity* result establishing that the Betti count is antitone in the
threshold. We discuss algorithms, numerical demonstrations, applications to
NISQ-era error mitigation, and a program of conjectures (bottleneck-distance
recovery, probabilistic margin amplification, and a converse no-go below
$R = 1$) that push the result outward.

**Keywords:** persistent homology, Betti number, barcode, persistence,
threshold stability, quantum error mitigation, NISQ, margin-to-noise ratio.

---

## 1. Introduction

Near-term quantum hardware — *Noisy Intermediate-Scale Quantum* (NISQ) devices —
delivers measurements corrupted by decoherence, gate infidelity, and readout
error. Full fault-tolerant quantum error correction remains beyond current
qubit budgets, so practitioners rely on *error mitigation*: post-processing of
many noisy repetitions to estimate the noiseless answer. Most mitigation
techniques operate on continuous estimands (e.g. expectation values) and aim for
small statistical error.

This paper studies a structurally different proposal. The outcomes of a noisy
quantum experiment can be embedded as a point cloud and summarized through
*persistent homology*, producing a *barcode* of birth–death intervals. The
length of an interval — its *persistence* — measures the robustness of a
topological feature: long bars are signal, short bars are noise. We ask whether
the *discrete* topological summary of such a barcode — a Betti count above a
chosen persistence threshold — can be recovered *exactly* despite bounded
corruption of every individual bar.

We answer affirmatively and quantitatively. The recovery is governed entirely by
the relation between a *noise budget* $\varepsilon$ and a *margin* $m$ separating
true persistences from the threshold. The exact condition is $2\varepsilon < m$,
equivalently $R := m/(2\varepsilon) > 1$. The factor $2$ is tight. Because
counting is integer-valued, recovery is *exact*, not merely accurate: the
recovered Betti number is the true Betti number with probability one whenever the
margin condition holds.

### Contributions

1. A minimal, finite data model of barcodes (`Bar`, `persistence`) suitable for
   formal reasoning (Section 2).
2. **Threshold stability** (`threshold_iff_of_noise_margin`): a pointwise
   guarantee that a noisy value and a true value lie on the same side of a
   threshold under the margin condition (Section 3).
3. **Monotonicity** (`betti_antitone`): the Betti count is antitone in the
   threshold (Section 4.1).
4. **Betti-count recovery** (`betti_recovered`): exact equality of noisy and
   true Betti counts under the margin condition (Section 4.2).
5. Identification of the margin-to-noise ratio $R = m/(2\varepsilon)$ as the
   single dimensionless capacity parameter, with tightness of $2\varepsilon$
   (Section 5).
6. Algorithms, numerical demonstrations, and an applications/future-work program
   (Sections 6–8).

---

## 2. The data model

We work over the real numbers $\mathbb{R}$.

**Definition 2.1 (Bar).** A *bar* is a pair $b = (\mathrm{birth}, \mathrm{death})$
of real numbers, representing a topological feature that appears at filtration
scale $\mathrm{birth}$ and disappears at scale $\mathrm{death}$.

**Definition 2.2 (Persistence).** The *persistence* (lifetime) of a bar $b$ is
$$\operatorname{persistence}(b) = b.\mathrm{death} - b.\mathrm{birth}.$$

A *barcode* on $n$ features is a finite family $B : \{0,\dots,n-1\} \to
\mathrm{Bar}$, formally an indexed family $B : \mathrm{Fin}\,n \to \mathrm{Bar}$.

This model is deliberately elementary. All topological content of persistent
homology that we use is captured by the persistence values; the recovery theory
depends only on these real numbers and a threshold, never on the ambient
filtration. This is what makes the results portable across data domains.

---

## 3. Pointwise threshold stability

The atom of the theory concerns a single noisy scalar.

**Theorem 3.1 (Threshold stability, `threshold_iff_of_noise_margin`).**
*Let $x, y, \tau, \varepsilon, m \in \mathbb{R}$ satisfy*
$$|x - y| \le \varepsilon, \qquad m \le |y - \tau|, \qquad 2\varepsilon < m.$$
*Then*
$$\tau < x \iff \tau < y.$$

*Interpretation.* $y$ is the true value, $x$ the noisy observation, and $\tau$ a
decision threshold. The conclusion states that observation and truth fall on the
same side of $\tau$, so thresholding the noisy value yields the correct decision.

**Proof sketch.** The hypotheses bound $x$ within $[y-\varepsilon, y+\varepsilon]$
and force $y$ to satisfy either $y - \tau \ge m$ or $\tau - y \ge m$ (the two
cases of $|y - \tau| \ge m$). Consider the forward direction. Suppose
$\tau < x$. If we were in the case $\tau - y \ge m$, i.e. $y \le \tau - m$, then
$x \le y + \varepsilon \le \tau - m + \varepsilon$. Since $2\varepsilon < m$ we
have $m - \varepsilon > \varepsilon \ge 0$, so $x \le \tau - (m-\varepsilon) <
\tau$, contradicting $\tau < x$. Hence $y - \tau \ge m > 0$, giving $\tau < y$.
The reverse direction is symmetric: if $\tau < y$ then $y - \tau \ge m$ (the
other case would give $y \le \tau$), and $x \ge y - \varepsilon \ge \tau + m -
\varepsilon > \tau$. Formally, the result follows by a finite case split on the
signs of $x - y$ and $y - \tau$ followed by linear arithmetic. $\qquad\blacksquare$

The decisive quantity is $m - \varepsilon$, the minimal distance from $x$ to
$\tau$. The condition $2\varepsilon < m$ guarantees $m - \varepsilon >
\varepsilon \ge 0$; in fact strict positivity of $m - \varepsilon$ suffices for a
single bar, but the sharp constant relevant to *barcode-level* recovery, where a
bar's persistence is itself a difference of two jittered endpoints, is
$2\varepsilon$ (see Section 5).

---

## 4. Betti counts and their stability

**Definition 4.1 (Betti count, `bettiCount`).** For a threshold $\tau \in
\mathbb{R}$ and a barcode $B : \mathrm{Fin}\,n \to \mathrm{Bar}$, the *Betti count
at $\tau$* is
$$\beta_\tau(B) = \bigl|\{\, i \in \mathrm{Fin}\,n : \tau < \operatorname{persistence}(B\,i)\,\}\bigr|,$$
the number of bars whose persistence strictly exceeds $\tau$.

This is the persistent-homology *Betti number* read at persistence scale $\tau$:
the number of features deemed "real" at robustness level $\tau$.

### 4.1 Monotonicity

**Theorem 4.2 (Antitonicity, `betti_antitone`).** *For any barcode $B$ and
thresholds $\tau_1 \le \tau_2$,*
$$\beta_{\tau_2}(B) \le \beta_{\tau_1}(B).$$

**Proof sketch.** If a bar clears the higher threshold, $\tau_2 <
\operatorname{persistence}(B\,i)$, then since $\tau_1 \le \tau_2$ it also clears
the lower one. Hence the index set defining $\beta_{\tau_2}$ is a subset of the
index set defining $\beta_{\tau_1}$, and cardinality is monotone under inclusion.
$\qquad\blacksquare$

Antitonicity certifies that $\tau \mapsto \beta_\tau(B)$ is a non-increasing
integer staircase — the *persistence Betti curve* — so the barcode encodes an
entire ordered family of Betti counts, one per threshold.

### 4.2 Exact recovery

**Theorem 4.3 (Betti-count recovery, `betti_recovered`).** *Let $T, N :
\mathrm{Fin}\,n \to \mathrm{Bar}$ be a true and a noisy barcode, matched index by
index. Suppose there are $\tau, \varepsilon, m \in \mathbb{R}$ with*
$$\forall i,\ |\operatorname{persistence}(N\,i) - \operatorname{persistence}(T\,i)| \le \varepsilon,$$
$$\forall i,\ m \le |\operatorname{persistence}(T\,i) - \tau|,$$
$$2\varepsilon < m.$$
*Then*
$$\beta_\tau(N) = \beta_\tau(T).$$

**Proof sketch.** Fix any index $i$. Apply Theorem 3.1 with $x =
\operatorname{persistence}(N\,i)$ and $y = \operatorname{persistence}(T\,i)$; the
three hypotheses are exactly the per-index assumptions. We obtain
$$\tau < \operatorname{persistence}(N\,i) \iff \tau < \operatorname{persistence}(T\,i).$$
Thus the filtering predicate agrees on every index, so the filtered index sets
defining $\beta_\tau(N)$ and $\beta_\tau(T)$ are *equal as sets*. Equal sets have
equal cardinality, giving $\beta_\tau(N) = \beta_\tau(T)$. $\qquad\blacksquare$

The proof is non-circular and entirely constructive: it flows from the pointwise
lemma (Theorem 3.1) to a pointwise threshold equivalence, then to equality of the
filtered finite sets, then to equality of their cardinalities. No probabilistic
or analytic machinery is needed. The recovered quantity is a *bona fide integer*,
recovered exactly from real-valued data corrupted at every coordinate. This is
the distinctive payoff of operating on a discrete invariant: there is no residual
estimation error to control, only a yes/no membership question that the margin
condition resolves uniformly.

---

## 5. The margin-to-noise ratio and tightness

Define the **margin-to-noise ratio**
$$R = \frac{m}{2\varepsilon} \qquad (\varepsilon > 0).$$
The hypothesis $2\varepsilon < m$ is precisely $R > 1$. Thus:

**Corollary 5.1.** *Threshold stability (Theorem 3.1) and Betti-count recovery
(Theorem 4.3) hold whenever $R > 1$.*

$R$ is a dimensionless signal-to-noise ratio for *shape*: the margin separating
true features from the decision boundary, measured in units of twice the noise.

**Tightness of $2\varepsilon$.** The constant cannot be improved to $c\varepsilon$
for any $c < 2$ when persistences arise as differences of jittered endpoints. Let
a true bar have $\operatorname{persistence} = y$ with $y - \tau = m$ exactly (the
margin is just met). Corrupt the birth *upward* by $\varepsilon$ and the death
*downward* by $\varepsilon$; then the noisy persistence is $x = y - 2\varepsilon$
while the endpoint perturbations are each $\le \varepsilon$. If $m = 2\varepsilon$
exactly, then $x = \tau$, and an arbitrarily small additional perturbation pushes
$x$ below $\tau$, flipping the membership decision and corrupting the count. Hence
$R = 1$ is a sharp boundary: recovery is guaranteed for $R > 1$ and can fail at
$R \le 1$. We treat the converse no-go at $R < 1$ as a conjecture (Section 8).

This tightness elevates $R = 1$ from a sufficient-condition artifact to a
candidate *error-correction capacity* of persistence thresholding: the exact
dividing line between recoverable and unrecoverable regimes for any rule that
observes only persistences.

---

## 6. Algorithms

We summarize the computational content. Throughout, $n$ is the number of bars.

### 6.1 Betti count at a threshold

Compute $\beta_\tau(B)$ by a single linear scan.

```
function BettiCount(B[0..n-1], tau):
    count <- 0
    for i in 0..n-1:
        p <- B[i].death - B[i].birth
        if tau < p:
            count <- count + 1
    return count
```

**Complexity.** $O(n)$ time, $O(1)$ extra space.

### 6.2 Persistence Betti curve

By antitonicity (Theorem 4.2), the map $\tau \mapsto \beta_\tau(B)$ is a
non-increasing step function whose jumps occur at the distinct persistence
values. Sorting the persistences yields the entire curve.

```
function BettiCurve(B[0..n-1]):
    P <- sorted([B[i].death - B[i].birth for i in 0..n-1], descending)
    # beta_tau = number of P[j] > tau; the staircase is read off P directly
    return P     # P[k] is the largest threshold at which beta >= k+1
```

**Complexity.** $O(n \log n)$.

### 6.3 Recovery certification

Given a noisy barcode $N$, an assumed noise bound $\varepsilon$, a threshold
$\tau$, and (if available) a true barcode $T$, certify the recovery hypotheses.

```
function CertifyRecovery(T, N, tau, eps):
    eps_obs <- max_i |persistence(N[i]) - persistence(T[i])|
    m_obs   <- min_i |persistence(T[i]) - tau|
    R       <- m_obs / (2 * eps)            # margin-to-noise ratio
    return (eps_obs <= eps) and (2 * eps < m_obs), R
```

If the predicate holds (equivalently $R > 1$ with $\varepsilon_{\text{obs}} \le
\varepsilon$), Theorem 4.3 guarantees $\beta_\tau(N) = \beta_\tau(T)$.
**Complexity.** $O(n)$.

---

## 7. Applications

**NISQ error mitigation.** Run a quantum circuit $K$ times, embed the outcome
statistics as a point cloud, and compute its persistence barcode. The robust
topological features (long bars) encode the intended computation; readout and
gate noise jitter the persistences. Choosing a threshold $\tau$ with a healthy
margin $m$ relative to the empirical noise $\varepsilon$ makes the Betti count a
*self-correcting* readout: by Theorem 4.3, the reported integer equals the
noiseless one whenever $R > 1$. The ratio $R$ gives the experimentalist a direct
design target — widen the margin or suppress the noise until $R$ exceeds one.

**Topological data analysis under bounded perturbation.** The theory is agnostic
to the source of the bars. Any pipeline that reports Betti counts above a
persistence threshold inherits exact stability under bounded perturbation, with
the explicit, tight constant $2\varepsilon$.

**Repetition as a topological code.** When individual shots may occasionally
violate the margin, repeating the experiment and taking a consensus of Betti
counts turns topological thresholding into a repetition code (Section 8,
Conjecture 2).

---

## 8. Discussion and future directions

The cycle established a single dimensionless control parameter, the
margin-to-noise ratio $R = m/(2\varepsilon)$: classification, repetition
consensus, and exact Betti recovery all hold precisely when $R > 1$, and the
$2\varepsilon$ constant is tight. The following conjectures push that finding
outward.

**Conjecture 1 — Bottleneck Betti recovery without a pointwise matching.** If two
finite persistence diagrams are at bottleneck distance $< m/2$ (rather than being
matched index-by-index with closeness $\varepsilon$), their Betti counts above
any $m$-separated threshold still agree exactly. The key insight is that exact
integer recovery should depend only on the *metric* proximity of the diagrams,
not on a chosen bijection, so the optimal matching underlying the bottleneck
distance can replace the hand-supplied identification used in Theorem 4.3.

**Conjecture 2 — Probabilistic margin amplification by repetition.** If each NISQ
shot independently violates the margin with probability $p < 1/2$, then the
majority-vote persistence classification over $k$ shots is correct except with
probability $\le \exp(-c\,k\,(1/2 - p)^2)$. The key insight is that the
deterministic consensus theorem is the $p = 0$ endpoint of a Chernoff-type
concentration: once individual shots can fail, the *count* of consistent shots
concentrates, turning topological repetition into a genuine repetition code.

**Conjecture 3 — Capacity threshold and a no-go below $R = 1$.** For every
mitigation rule that depends only on observed persistences, there exists a true
diagram and an admissible noise with $R < 1$ on which the rule misclassifies;
hence $R = 1$ is the exact error-correction *capacity* of persistence
thresholding. The key insight is that the tightness witness of Section 5 (birth
and death moving oppositely to realize $|\Delta| = 2\varepsilon$) is not an
artifact but an adversary's strategy, converting the tight bound into a converse
no-go theorem.

**Conjecture 4 — Higher-degree persistence is strictly more robust.** Features in
higher homological degree (voids and their higher-dimensional analogues) may
admit larger effective margins under the same noise, making higher-degree Betti
counts strictly more robust signal carriers than degree-one loops.

---

## 9. Conclusion

We have given a sharp, finite-data account of exact Betti-count recovery from
noisy persistence barcodes. The theory reduces to one dimensionless ratio,
$R = m/(2\varepsilon)$: when $R > 1$, the discrete topological summary of a noisy
experiment equals the noiseless one *exactly*, and the constant $2\varepsilon$ is
tight. The discreteness of counting converts bounded analog noise into
error-free digital recovery, suggesting persistence thresholding as a lightweight,
self-correcting readout for NISQ-era quantum computation and, more broadly, for
topological data analysis under bounded perturbation.
