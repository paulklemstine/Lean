# Angular Curvature Obstruction to Band Re-entry

### Why concavity in the correlation angle cannot describe a non-monotone fade

**Aristotle** (Harmonic)
2026-10-24

---

## Abstract

We study a short ladder of correlation readings $\rho_n$ taken at problem sizes of $96+4n$ bits, $n=0,\dots,6$. The ladder fades below a threshold $0.55$ (the *band*, or spherical cap) by the 108-bit rung, where $\rho_{108}=0.488$. It then shows a single rebound at 116 bits. Monotone fading of $\rho$ is refuted by that rebound. As a replacement, a curvature model was proposed in the angle coordinate $\theta_n=\arccos\rho_n$. The model asks for angular deceleration, $\theta_{n+2}-2\theta_{n+1}+\theta_n\le 0$, from 108 bits on.

We prove the associated conjecture: angular deceleration from 108 bits forces $\theta_n$ to converge to a limit at least $\arccos 0.488$, and forces $\rho_n\le 0.488<0.55$ at every later rung. We then show why the result has no bearing on the data. A concave sequence that is bounded below can never take a downward step. Because angles are bounded, angular concavity therefore *implies* that the correlation is nonincreasing. The curvature model is a sub-class of the falsified monotone model, not a relaxation of it. It follows that no sequence matching the ladder is angularly concave from any rung at or before 112 bits. Dually, none is angularly convex from any rung at or before 116 bits.

The ladder's second differences alternate strictly in sign in both coordinates. The 112-bit window is convex in angle with excess greater than $0.079$. Yet each parity sub-ladder is strictly decreasing and angularly concave. We also show that a concave continuation of the rebound would *force* re-entry into the cap by 132 bits, and could not stay concave for 62 windows.

What survives is a guarded plateau localisation. If the angle is nondecreasing with deceleration ratio at most $1/2$, its limit lies in $[\arccos 0.488,\ \arccos 0.488+0.0595]$, outside the cap. Angle increments are certified by an elementary mean-value sandwich for $\arccos$. We close with a falsifiable prediction for the 124-bit rung, $\rho_{124}\in[0.4814,\,0.4847)$, and a programme of trend-plus-residual models.

---

## 1. Introduction

When a measured signal fades as a control parameter grows, one wants to know whether the fade is *permanent*. Concretely: once the signal has dropped out of a band of interest, can it come back? With a finite number of measurements this cannot be settled empirically. It can be settled *relative to a model class*. If every model in a reasonable class that agrees with the data stays out of the band, then band loss is permanent for that class.

The obvious class is monotone fading. In our setting it is refuted by a single non-monotone reading. The next natural step is to change coordinates and relax the condition. A correlation $\rho\in[-1,1]$ is the cosine of an angle $\theta=\arccos\rho\in[0,\pi]$. The band $\{\rho\ge 0.55\}$ becomes a spherical cap $\{\theta\le\arccos 0.55\}$. Instead of asking that the angle always grows, one may ask only that it *decelerates*, that is, that its increments never increase. This second-order condition looks strictly weaker than a first-order one. One might hope it is flexible enough to accommodate the rebound while still forbidding re-entry.

The contribution of this paper is a complete analysis of that hope.

* **The conjecture holds** (Theorem 3.3). Angular deceleration from 108 bits forces convergence and forbids re-entry.
* **The model class collapses** (Theorem 4.1). For genuine correlations, angular concavity implies antitonicity of $\rho$. The mechanism is Theorem 2.3: a concave sequence that is bounded below cannot take a single downward step.
* **The data refute it** (Theorem 4.3). This happens in both curvature directions. The data instead display strictly alternating curvature (Proposition 5.1) together with monotone, concave parity sub-ladders (Proposition 5.2).
* **Concavity plus the rebound forces re-entry** (Theorem 6.1), and has a short lifetime (Theorem 6.2).
* **A guarded plateau theorem** (Theorem 7.2) localises the limiting angle outside the cap under an explicit geometric-deceleration hypothesis. Its increments are certified by a mean-value sandwich (Lemma 7.4).

The broader message is methodological. A coordinate change combined with a second-order relaxation can be, owing to a hidden boundedness, exactly as restrictive as the first-order condition it was meant to relax. Proving the conjecture is what exposes this.

---

## 2. Discrete concavity and its consequences

Throughout, sequences are real-valued and indexed by $\mathbb N=\{0,1,2,\dots\}$.

**Definition 2.1 (discrete concavity).** A sequence $s$ is *concave from $N$* if
$$\Delta^2 s_n := s_{n+2}-2s_{n+1}+s_n \le 0 \qquad\text{for all } n\ge N.$$
It is *convex from $N$* if $-s$ is concave from $N$. Applied to the angle sequence, concavity is called *angular deceleration*.

Concavity says that the increments $s_{n+1}-s_n$ are nonincreasing. Sometimes concavity is known only on a finite stretch, so we record a windowed form.

**Lemma 2.2 (step and chord bounds).** Let $m,K\in\mathbb N$. Suppose $\Delta^2 s_{m+j}\le 0$ for every $j$ with $j+2\le K$. Then:

1. (*steps*) $s_{m+j+1}-s_{m+j}\le s_{m+1}-s_m$ for every $j$ with $j+1\le K$;
2. (*chord*) $s_{m+k}\le s_m + k\,(s_{m+1}-s_m)$ for every $k\le K$.

In particular, if $s$ is concave from $N$ and $m\ge N$, then $s_{m+k}\le s_m+k(s_{m+1}-s_m)$ for all $k\ge0$.

*Proof sketch.* (1) By induction on $j$. The case $j=0$ is trivial. For the inductive step, $\Delta^2 s_{m+j}\le 0$ rearranges to $s_{m+j+2}-s_{m+j+1}\le s_{m+j+1}-s_{m+j}$, and the right side is at most $s_{m+1}-s_m$ by hypothesis. (2) By induction on $k$, adding the step bound (1) to the chord bound at $k$. The unbounded version applies the windowed one with $K=k$. $\square$

The chord bound says a concave stretch stays below the line through its first two points. Its key consequence is the following.

**Theorem 2.3 (bounded concave sequences never step down).** Let $s$ be concave from $N$ and bounded below, $s_n\ge B$ for all $n$. Then $s_n\le s_{n+1}$ for every $n\ge N$.

*Proof sketch.* Suppose $s_{n+1}<s_n$ for some $n\ge N$, and put $\delta=s_n-s_{n+1}>0$. By the chord bound, $s_{n+k}\le s_n-k\delta$ for every $k$. Choose an integer $k>(s_n-B)/\delta$, which exists by the Archimedean property. Then $s_{n+k}<B$, a contradiction. $\square$

Thus a single downward step, however small, is incompatible with infinite concavity and a floor. Quantitatively, a downward step of size $\delta$ at height $h$ above the floor is fatal within $\lfloor h/\delta\rfloor+1$ further steps. A step of $10^{-3}$ at height $1.2$ is fatal within about $1200$ steps.

**Theorem 2.4 (bounded concave sequences converge).** Let $s$ be concave from $N$ with $B\le s_n\le C$ for all $n$. Then there is $L$ with $s_n\to L$ and $s_n\le L$ for every $n\ge N$.

*Proof sketch.* By Theorem 2.3 the shifted sequence $t_k=s_{k+N}$ is nondecreasing. It is bounded above by $C$, so it converges to $L=\sup_k t_k$ by the monotone convergence theorem. Then $s_n=t_{n-N}\le L$ for $n\ge N$, and convergence of $t$ is convergence of $s$. $\square$

By symmetry, a sequence that is convex from $N$ and bounded above can never step *up* after $N$, and if it is also bounded below it converges.

---

## 3. The angle coordinate and the angular deceleration theorem

We use the arccosine extended to all of $\mathbb R$ by clamping: $\arccos x=0$ for $x\ge1$ and $\arccos x=\pi$ for $x\le -1$. On $[-1,1]$ it is the usual strictly decreasing bijection onto $[0,\pi]$. In particular $0\le\arccos x\le\pi$ for all real $x$. For a correlation $\rho$ we write $\theta=\arccos\rho$ for the *correlation angle*. The band $\{\rho\ge 0.55\}$ is the spherical cap $\{\theta\le \arccos 0.55\}$, where $\arccos 0.55\approx 0.98843$.

**Lemma 3.1 (angle comparison).** Let $-1\le a<1$ and $x\in\mathbb R$. If $\arccos a\le\arccos x$, then $x\le a$.

*Proof sketch.* Suppose $x>a$. If $x\le 1$, strict monotonicity on $[-1,1]$ gives $\arccos x<\arccos a$. If $x>1$, then $\arccos x=0<\arccos a$, since $a<1$. Either way this contradicts the hypothesis. $\square$

Note that no range assumption on $x$ is needed. This lets the main theorem apply to arbitrary real sequences, not only to genuine correlations.

**Definition 3.2 (indexing).** The ladder index $n$ corresponds to the bit length $96+4n$. Thus $n=3$ is the 108-bit rung, $n=4$ is 112 bits, $n=5$ is 116 bits, and $n=6$ is 120 bits.

**Theorem 3.3 (angular deceleration forbids re-entry).** Let $\rho:\mathbb N\to\mathbb R$ be any real sequence with $\rho_3=0.488$. Suppose $\theta_n=\arccos\rho_n$ is concave from index $3$:
$$\theta_{n+2}-2\theta_{n+1}+\theta_n\le 0\qquad(n\ge 3).$$
Then there is $L$ with $\theta_n\to L$ and $L\ge\arccos 0.488$. Moreover, for every $n\ge 3$,
$$\rho_n\le 0.488<0.55 .$$
In particular the sequence never re-enters the cap $\{\rho\ge 0.55\}$ after the 108-bit rung.

*Proof sketch.* The angle sequence satisfies $0\le\theta_n\le\pi$. Theorem 2.4 gives a limit $L$ with $\theta_3\le L$, that is, $L\ge\arccos 0.488$. Theorem 2.3 shows $\theta$ is nondecreasing from $3$, so by induction $\theta_n\ge\theta_3=\arccos 0.488$ for all $n\ge3$. Lemma 3.1 with $a=0.488$ yields $\rho_n\le 0.488$, and $0.488<0.55$. $\square$

So the conjecture is a theorem. The next section explains why it is vacuous for the data.

---

## 4. Collapse of the curvature class and refutation by the data

**Theorem 4.1 (angular concavity implies antitonicity).** Let $\rho_n\in[-1,1]$ for all $n$. If $\theta_n=\arccos\rho_n$ is concave from $N$, then $\rho_{n+1}\le\rho_n$ for every $n\ge N$.

*Proof sketch.* The angles are bounded below by $0$, so Theorem 2.3 gives $\theta_n\le\theta_{n+1}$ for $n\ge N$. Since $\cos$ is decreasing on $[0,\pi]$ and $\rho_n=\cos\theta_n$ for $\rho_n\in[-1,1]$, we get $\rho_{n+1}\le\rho_n$. $\square$

**Corollary 4.2.** Within genuine correlation sequences, the class of sequences that are angularly concave from $N$ is contained in the class that is nonincreasing from $N$. Any datum refuting the monotone model from $N$ also refutes the angular curvature model from $N$.

Dually, if $\theta$ is convex from $N$ then, because $\theta\le\pi$, it is nonincreasing from $N$. Hence $\rho$ is nondecreasing from $N$.

### 4.1 The ladder

Two readings anchor every quantitative statement below:
$$\rho_{108}=0.488,\qquad \rho_{116}=0.4847 .$$
The qualitative structure established for the full seven-rung ladder is:

* (R1) **rebound**: $\rho_{116}>\rho_{112}$, the unique rise along the ladder;
* (R2) **drop**: $\rho_{120}<\rho_{116}$;
* (R3) **alternation**: second differences alternate strictly in sign over all five windows, in both coordinates;
* (R4) **convexity excess**: $\theta_{120}-2\theta_{116}+\theta_{112}>0.079$;
* (R5) **parity**: the even rungs $(96,104,112,120)$ and the odd rungs $(100,108,116)$ each form a strictly decreasing, angularly concave sub-ladder.

For concreteness and for the numerical checks, Table 1 completes the ladder with representative values. They agree with the two anchors and satisfy (R1)–(R5) and every inequality used in Sections 5–7. The theorems depend only on the anchors and on these relations.

**Table 1.** Representative ladder (anchors in bold).

| $n$ | bits | $\rho_n$ | $\theta_n=\arccos\rho_n$ | in cap? |
|---|---|---|---|---|
| 0 | 96 | 0.575 | 0.95819 | yes |
| 1 | 100 | 0.555 | 0.98243 | yes |
| 2 | 104 | 0.510 | 1.03561 | no |
| 3 | 108 | **0.488** | 1.06100 | no |
| 4 | 112 | 0.462 | 1.09055 | no |
| 5 | 116 | **0.4847** | 1.06478 | no |
| 6 | 120 | 0.436 | 1.11965 | no |

**Theorem 4.3 (no curvature model fits).** Let $\rho:\mathbb N\to[-1,1]$ agree with the ladder on $n=0,\dots,6$.

1. $\theta$ is not concave from any index $N\le 4$.
2. $\theta$ is not convex from any index $N\le 5$.

*Proof sketch.* (1) By (R1), $\rho_5>\rho_4$, so $\theta_5<\theta_4$. This is a downward angular step at index $4\ge N$, which Theorem 2.3 forbids for a concave sequence bounded below by $0$. Equivalently, Theorem 4.1 would force $\rho_5\le\rho_4$. (2) By (R2), $\rho_6<\rho_5$, so $\theta_6>\theta_5$. This is an upward angular step at index $5\ge N$, which the convex dual of Theorem 2.3 forbids for a sequence bounded above by $\pi$. $\square$

The monotone model was refuted by the rebound. The curvature model, being a sub-class, is refuted by the same reading, and the opposite curvature is refuted by the following one.

---

## 5. What the ladder actually does

**Proposition 5.1 (alternating curvature in both coordinates).** On the five windows based at $96,100,104,108,112$ bits, the second differences $\Delta^2\rho_n$ alternate strictly in sign, and so do $\Delta^2\theta_n$. In angle, the 108-bit window is concave ($\Delta^2\theta_3<0$). The 112-bit window is convex with
$$\Delta^2\theta_4=\theta_{120}-2\theta_{116}+\theta_{112}>0.079 .$$

For the representative ladder the values are as follows.

| window (bits) | $\Delta^2\rho$ | $\Delta^2\theta$ |
|---|---|---|
| 96 | $-0.02500$ | $+0.02894$ |
| 100 | $+0.02300$ | $-0.02779$ |
| 104 | $-0.00400$ | $+0.00416$ |
| 108 | $+0.04870$ | $-0.05532$ |
| 112 | $-0.07140$ | $+0.08064$ |

The two coordinates carry opposite signs window by window. This is expected because $\arccos$ is decreasing and nearly affine over the range $[0.43,0.58]$. What matters is that *neither* coordinate admits a constant curvature sign.

**Proposition 5.2 (parity sub-ladders).** The even sub-ladder $\rho_{96}>\rho_{104}>\rho_{112}>\rho_{120}$ is strictly decreasing and angularly concave:
$$\theta_{112}-2\theta_{104}+\theta_{96}\le0,\qquad \theta_{120}-2\theta_{112}+\theta_{104}\le 0 .$$
The odd sub-ladder $\rho_{100}>\rho_{108}>\rho_{116}$ is strictly decreasing and angularly concave:
$$\theta_{116}-2\theta_{108}+\theta_{100}\le 0 .$$

*Remark.* With its own parity class as reference, the 116 reading still falls ($0.4847<0.488$). The rebound appears only when 116 is compared with 112, a rung of the other parity. Together with Proposition 5.1, this is the signature of a smooth fade plus a residual of period two rungs, that is, about 8 bits. Pointwise curvature conditions cannot capture such a residual, because the residual reverses the sign of $\Delta^2$ at every rung.

---

## 6. A concave continuation of the rebound must re-enter the cap

So far concavity has been shown incompatible with the data. One might instead impose concavity only *after* the rebound, on a model reproducing the 112 and 116 rungs. The rebound then turns against the model.

**Theorem 6.1 (concavity plus rebound forces re-entry).** Let $\theta$ be any sequence with $\theta_4=\arccos\rho_{112}$ and $\theta_5=\arccos\rho_{116}$. Write $\delta=\theta_4-\theta_5>0$ for the angular size of the rebound. Suppose $\Delta^2\theta_{4+j}\le 0$ for the four windows $j=0,1,2,3$, based at $112,116,120,124$ bits. Then
$$\theta_9\le\theta_4-5\delta .$$
Here $n=9$ is the 132-bit rung. Consequently, whenever $\theta_4-5\delta<\arccos 0.55$, the model reads $\rho_{132}>0.55$, which is re-entry into the cap. This condition holds for the ladder. With the representative value $\rho_{112}=0.462$ one has $\theta_4\approx1.09055$ and $\delta\approx 0.02577$, so $\theta_9\le 0.96169<0.98843$, that is, $\rho_{132}\ge 0.5721$.

*Proof sketch.* Apply the windowed chord bound (Lemma 2.2) with $m=4$, $K=5$ and $k=5$. Then $\theta_9\le\theta_4+5(\theta_5-\theta_4)=\theta_4-5\delta$. Lemma 3.1, in the contrapositive form "$\arccos x<\arccos 0.55\Rightarrow x>0.55$", gives the conclusion. $\square$

The chord bounds along the way are as follows.

| bits | angle bound | correlation bound |
|---|---|---|
| 120 | $\theta\le 1.03900$ | $\rho\ge 0.5071$ |
| 124 | $\theta\le 1.01323$ | $\rho\ge 0.5291$ |
| 128 | $\theta\le 0.98746$ | $\rho\ge 0.5508$ |
| 132 | $\theta\le 0.96169$ | $\rho\ge 0.5721$ |

**Theorem 6.2 (lifetime of a concave continuation).** In the setting of Theorem 6.1, suppose $\rho_{112}\ge 0$, so that $\theta_4\le\pi/2$, and suppose $\delta\ge\delta_0>0$. Then $\theta$ cannot be concave on all windows based at $4,5,\dots,4+K-2$ for any $K$ with $K\delta_0>\pi/2$. For the ladder, the sandwich of Lemma 7.4 certifies
$$\delta\ \ge\ \frac{\rho_{116}-\rho_{112}}{\sqrt{1-\rho_{112}^2}}\ \ge\ 0.0255 .$$
Hence $62\,\delta>\pi/2$, and no such model stays concave for 62 windows.

*Proof sketch.* The chord bound gives $\theta_{4+K}\le\theta_4-K\delta\le\pi/2-K\delta_0<0$. This contradicts $\theta\ge 0$. With $\delta_0=0.025595$ we get $\pi/2-62\,\delta_0\approx-0.0161<0$. $\square$

The model designed to forbid re-entry, once fitted to the rebound, *requires* re-entry within four windows and becomes self-inconsistent within 62.

---

## 7. What survives: plateau localisation in angle

### 7.1 Geometric deceleration

**Definition 7.1.** A sequence $\theta$ is *nondecreasing with deceleration ratio $r$ from $m$* if, for all $n\ge m$,
$$0\le \theta_{n+2}-\theta_{n+1}\le r\,(\theta_{n+1}-\theta_n).$$

Any such sequence with $r\le1$ is concave from $m$, so this is a strengthening of the curvature model, not an alternative to it.

**Theorem 7.2 (plateau localisation).** Let $0\le r<1$ and let $\theta$ be nondecreasing with deceleration ratio $r$ from $m$. Then $\theta$ converges to some $L$ with
$$\theta_m\ \le\ L\ \le\ \theta_m+\frac{\theta_{m+1}-\theta_m}{1-r}.$$

*Proof sketch.* Put $d_n=\theta_{n+1}-\theta_n\ge 0$. By induction $d_{m+j}\le r^j d_m$. The partial sums $\theta_{m+k}-\theta_m=\sum_{j<k}d_{m+j}$ are nondecreasing and bounded by $d_m\sum_j r^j=d_m/(1-r)$. Monotone convergence gives the limit and both bounds. $\square$

**Corollary 7.3 (the 108-bit plateau window).** If, from the 108-bit rung, the angle is nondecreasing with deceleration ratio at most $1/2$, and the first increment is that of the ladder, then
$$\arccos 0.488\ \le\ L\ \le\ \arccos 0.488+0.0595 .$$
In radians this is $L\in[1.06100,\,1.12050]$. Since $\arccos 0.55\approx 0.98843<1.06100$, the limiting angle lies outside the cap, and every reading after 108 bits lies in $[\cos(\arccos0.488+0.0595),\,0.488]\approx[0.4352,\,0.488]$.

*Derivation.* With $r=1/2$ the width is $2(\theta_{112}-\theta_{108})$. For the representative value $\rho_{112}=0.462$ this equals $0.05910\le0.0595$. $\square$

*Check against the rungs.* Readings at 112, 116 and 120 bits are $0.462$, $0.4847$ and $0.436$, all within the predicted band. The 116 reading, however, violates the *hypothesis* of Corollary 7.3. Its angle decreases, by $0.02577$ rad. The plateau statement is therefore a correct conditional statement whose hypothesis the data do not satisfy. In the ladder's natural coordinates, the plateau reading is unsupported.

### 7.2 Certified angle increments

**Lemma 7.4 (mean-value sandwich for arccos).** For $0\le a<b<1$,
$$\frac{b-a}{\sqrt{1-a^2}}\ \le\ \arccos a-\arccos b\ \le\ \frac{b-a}{\sqrt{1-b^2}} .$$

*Proof sketch.* On $[a,b]$ the derivative of $-\arccos$ is $1/\sqrt{1-x^2}$. This is increasing on $[0,1)$, so its values on $[a,b]$ lie between $1/\sqrt{1-a^2}$ and $1/\sqrt{1-b^2}$. The mean value theorem finishes the proof. $\square$

Representative instances:

| $a$ | $b$ | lower | $\arccos a-\arccos b$ | upper |
|---|---|---|---|---|
| 0.4620 | 0.4880 | 0.029316 | 0.029548 | 0.029788 |
| 0.4620 | 0.4847 | 0.025595 | 0.025771 | 0.025952 |
| 0.4847 | 0.4880 | 0.003773 | 0.003777 | 0.003781 |
| 0.4880 | 0.5500 | 0.071032 | 0.072567 | 0.074237 |

The sandwich lets every quantitative inequality in this paper be checked with rational arithmetic and square roots, without high-precision evaluation of $\arccos$.

---

## 8. Algorithms

All the claims above that concern the ladder reduce to finite computations of the following kinds.

**Algorithm A (curvature profile).** Input: readings $\rho_0,\dots,\rho_{M}$. Compute $\theta_n=\arccos\rho_n$. Compute $\Delta^2\rho_n$ and $\Delta^2\theta_n$ for $n\le M-2$. Report the sign pattern, test strict alternation $\Delta^2_n\Delta^2_{n+1}<0$, and record the extremal windows. Cost: $O(M)$.

**Algorithm B (model-class admissibility).** For each candidate start index $N$:

* concave from $N$ is *inadmissible* if some window $n\ge N$ inside the data has $\Delta^2\theta_n>0$, or some $n\ge N$ has $\theta_{n+1}<\theta_n$ (Theorem 2.3);
* convex from $N$ is *inadmissible* if some window $n\ge N$ has $\Delta^2\theta_n<0$, or some $n\ge N$ has $\theta_{n+1}>\theta_n$.

This needs one pass, $O(M)$. These tests are complete. If the data segment from $N$ is concave and has nondecreasing angles, it extends to an infinite bounded concave sequence, for instance by freezing the angle after the last rung (the increments then drop to $0$). Convex segments with nonincreasing angles extend in the same way.

**Algorithm C (forced re-entry horizon).** Given a downward angular step $\theta_m>\theta_{m+1}$, let $\delta=\theta_m-\theta_{m+1}$. Return the least $k$ with $\theta_m-k\delta<\arccos 0.55$; this is the re-entry horizon. Also return the least $k$ with $\theta_m-k\delta<0$; this is the lifetime. Cost: $O(1)$ by division.

**Algorithm D (plateau window).** Given $\theta_m$, $\theta_{m+1}$ and a ratio $r<1$, return $[\theta_m,\ \theta_m+(\theta_{m+1}-\theta_m)/(1-r)]$, mapped back by $\cos$. Use Lemma 7.4 for certified bounds.

---

## 9. Discussion

**Coordinate changes are not model changes.** The angular reformulation appeared to trade a first-order condition (monotonicity) for a weaker second-order one (deceleration). Boundedness of the angle undoes the trade. A bounded concave sequence is automatically monotone. This is the discrete counterpart of the fact that a concave function on $[0,\infty)$ that is bounded below is nondecreasing. Any curvature condition imposed pointwise on a bounded coordinate inherits the same collapse.

**The role of proof.** It is natural to test a conjecture numerically and stop when it seems plausible. Here, *proving* the conjecture was the decisive step. The proof of Theorem 3.3 passes through Theorem 2.3, and Theorem 2.3 is precisely the statement that the hypothesis already contains monotonicity. The theorem is true and empty for the same reason.

**Alternating curvature is information.** Strict sign alternation of $\Delta^2$ in both coordinates, combined with monotone concave parity classes, is the fingerprint of a period-two residual on a smooth trend. A model $\theta_n=T_n+(-1)^n\varepsilon_n$ produces $\Delta^2\theta_n=\Delta^2T_n+4(-1)^n\varepsilon_n$ when $\varepsilon$ is constant. Once $|\varepsilon|$ exceeds $|\Delta^2T|/4$, the curvature alternates.

**Limitations.** Only seven rungs are available, and the statements in Sections 6–7 that use the 112-bit reading rely on its value. The results are statements about model classes. They do not exclude re-entry for models outside these classes, such as models with oscillating residuals.

---

## 10. Future directions

1. **Trend plus alternating residual.** Decompose $\theta_n=T_n+(-1)^n\varepsilon_n$ with $T$ concave and nondecreasing and $|\varepsilon_n|\le\varepsilon$. Impose curvature on the trend, not on the data. The plateau theorem then applies to $T$ with an additive error of $2\varepsilon$.
2. **Parity persistence and a prediction for 124 bits.** If the odd sub-ladder $(100,108,116,124)$ stays strictly decreasing and angularly concave, then $\rho_{124}<0.4847$ and $\theta_{124}\le 2\theta_{116}-\theta_{108}$. Numerically,
   $$\rho_{124}\in[\approx 0.4814,\ 0.4847).$$
   One further measurement tests the whole parity picture.
3. **Two-step curvature models.** Replace $\Delta^2$ by the two-step difference $\theta_{n+4}-2\theta_{n+2}+\theta_n$, which is blind to a period-two residual, and redevelop Theorems 2.3–7.2 for it.
4. **Robust versions.** Allow $\Delta^2\theta_n\le\eta$ for a small tolerance $\eta>0$, and quantify how the no-step-down theorem degrades: a downward step of size $\delta$ survives roughly $\delta/\eta$ rungs.

---

## Appendix: numerical reproduction

All tables can be regenerated with an elementary script that uses only the standard library. The script computes the angle table, the curvature profile in both coordinates, the parity checks, the chord bounds of Section 6, the sandwich bounds of Lemma 7.4, the plateau window of Corollary 7.3, and the 124-bit prediction window.
