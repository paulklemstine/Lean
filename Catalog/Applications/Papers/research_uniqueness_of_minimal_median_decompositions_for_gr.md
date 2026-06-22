# Quotient Orbit Compression: A Unified Bounded-Horizon Collision Principle for Coarse-Grained Deterministic Dynamics

**Author:** Aristotle

**Domain:** Bridges (Algebraic Dynamics ↔ Cryptographic Collision Bounds ↔ Observable-State Compression)

---

## Abstract

We develop and rigorously establish a single combinatorial principle that governs deterministic dynamics observed through a coarse, finite lens, and we show that it simultaneously answers three superficially distinct questions: *when must a coarse-grained trajectory recur?*, *when is a collision in an iterated function guaranteed?*, and *how large can an observable state log become?* Let $\alpha$ be a finite set of microscopic states, let $f : \alpha \to \alpha$ be an arbitrary deterministic transition map, and let $\rho$ be an equivalence relation (a *setoid*) on $\alpha$ whose quotient $\alpha/\rho$ has cardinality $k$. Our central theorem (`exists_iterate_rel_of_card_quotient`) asserts that from **any** start $x$ there exist times $0 \le m < n \le k$ with $f^{[m]}(x) \sim_\rho f^{[n]}(x)$: a coarse collision is forced within $k$ steps, independent of $|\alpha|$ and of the structure of $f$. We prove this via a pigeonhole argument on the quotient trace (`exists_lt_lt_iterate_quotient_eq`) combined with a soundness bridge from label-equality to genuine indistinguishability (`quotient_eq_implies_rel`). We then derive an observable-orbit ceiling (`eml_observable_orbit_bound`), define and bound natural compression statistics — collision entropy, compression ratio (`orbitCompressionRatio_le_one`), and observable diameter — and interpret the result as a cryptographic collision certificate and a certified-robustness guarantee. We show the horizon $k$ is tight via an explicit single-cycle construction. All results are constructive and have been formally verified.

---

## 1. Introduction

### 1.1 Motivation

Deterministic processes on finite state spaces are everywhere: cellular automata, hash-function iterations, finite-precision numerical integrators, register machines, and discrete dynamical models of physical systems. In almost all practical settings we do not — and cannot — observe the full microscopic state. We observe a **coarse-graining**: a temperature band rather than a molecular configuration, a digest rather than a preimage, a logged category rather than a raw sensor reading.

A coarse-graining is precisely an equivalence relation $\rho$ on the state set $\alpha$, and the *observable* state space is the quotient $\alpha/\rho$. The fundamental question of coarse-grained dynamics is: **what can we guarantee about the observable trajectory, knowing nothing about the microscopic map beyond the fact that it is a deterministic self-map of a finite set?**

This paper isolates and proves the strongest possible such guarantee that depends only on the resolution $k = |\alpha/\rho|$, and shows that it unifies three research traditions:

1. **Algebraic dynamics:** finite quotient recurrence.
2. **Cryptography:** worst-case collision certificates for iterated functions (the rigorous skeleton of birthday/Pollard-$\rho$ reasoning).
3. **Observable-state compression (EML):** hard ceilings on the complexity of logged summaries.

### 1.2 Contributions

- A clean **soundness bridge** (Theorem 3.1) from quotient label-equality to the underlying setoid relation.
- The **pigeonhole core** (Theorem 4.1): $k+1$ observations into $k$ classes force a repeated class.
- The **central bounded-horizon collision theorem** (Theorem 4.2): a coarse collision within $k$ steps, for any $f$ and any start.
- A suite of **observable-orbit** definitions and the ceiling theorem (Theorem 5.2).
- **Compression statistics** with proven bounds: collision entropy nonnegativity (Theorem 6.1) and compression ratio $\le 1$ (Theorem 6.2).
- The **cryptographic** and **certified-robustness** readings of the central theorem.
- A **tightness** construction (Theorem 7.1) showing the horizon $k$ cannot be reduced.

All statements are constructive and formally verified.

---

## 2. Preliminaries and Notation

Throughout, $\alpha$ is a finite type (set) with decidable equality. We write $|\alpha| = \mathrm{card}(\alpha)$.

**Iteration.** For $f : \alpha \to \alpha$ and $n \in \mathbb{N}$, the $n$-fold iterate $f^{[n]}$ is defined by $f^{[0]} = \mathrm{id}$ and $f^{[n+1]} = f \circ f^{[n]}$. The trajectory from $x$ is $\bigl(f^{[n]}(x)\bigr)_{n \ge 0}$.

**Setoid / coarse lens.** A *setoid* $\rho$ on $\alpha$ is an equivalence relation; we write its relation as $a \sim_\rho b$ (or $a \sim b$ when $\rho$ is clear) and assume it is decidable. The *quotient* $\alpha/\rho$ is the set of equivalence classes, and the *class map* $\overline{(\cdot)} : \alpha \to \alpha/\rho$ sends a state to its class, $\overline{a} = [a]_\rho$. We write
$$k := |\alpha/\rho|$$
for the **resolution** of the lens (the number of observable classes). Since the class map is surjective, $k \le |\alpha|$.

The class map is, by construction, **constant on classes** and **separates distinct classes**: $\overline{a} = \overline{b}$ holds *iff* $a \sim_\rho b$. The forward direction of this equivalence is the soundness bridge we make explicit next.

---

## 3. The Soundness Bridge

The first brick connects the *syntactic* fact "two states carry the same label" to the *semantic* fact "two states are genuinely indistinguishable."

> **Theorem 3.1 (`quotient_eq_implies_rel`).** For any setoid $\rho$ on $\alpha$ and any $a, b \in \alpha$,
> $$\overline{a} = \overline{b} \;\Longrightarrow\; a \sim_\rho b.$$

**Proof sketch.** Equality of quotient classes is, by the universal property of the quotient, exactly the statement that the two representatives are identified by $\rho$. Extracting a witness of the relation from an equality of classes is the standard quotient *exactness* principle. $\qquad\blacksquare$

This lemma is what guarantees that every collision we *detect* through the lens (an equality of labels) is a *real* collision (an honest $\rho$-relation), not an artifact of the labeling. It is the linchpin that lets the purely combinatorial pigeonhole step below produce a meaningful dynamical conclusion.

---

## 4. The Bounded-Horizon Collision Theorem

### 4.1 The pigeonhole core

> **Theorem 4.1 (`exists_lt_lt_iterate_quotient_eq`).** Let $\alpha$ be finite, $\rho$ a decidable setoid with $k = |\alpha/\rho|$, $f : \alpha \to \alpha$, and $x \in \alpha$. Then there exist $m, n \in \mathbb{N}$ with
> $$m < n, \qquad n \le k, \qquad \overline{f^{[m]}(x)} = \overline{f^{[n]}(x)}.$$

**Proof sketch.** Consider the map
$$g : \{0, 1, \dots, k\} \to \alpha/\rho, \qquad g(i) = \overline{f^{[i]}(x)},$$
whose domain has $k+1$ elements and whose codomain has $k$ elements. Because $k < k+1$, the finite pigeonhole principle (in the form: a map from a larger finite set to a smaller one is not injective) yields indices $i \ne j$ with $g(i) = g(j)$. Relabel so that $i < j$; set $m = i$, $n = j$. Both lie in $\{0,\dots,k\}$, so $n \le k$, and by construction $\overline{f^{[m]}(x)} = \overline{f^{[n]}(x)}$. $\qquad\blacksquare$

The proof uses only the inequality $k < k+1$ and the non-injectivity of any map from a $(k{+}1)$-element domain to a $k$-element codomain; it is entirely indifferent to the internal structure of $f$.

### 4.2 The central theorem

Composing the pigeonhole core with the soundness bridge yields the main result.

> **Theorem 4.2 (`exists_iterate_rel_of_card_quotient`).** Let $\alpha$ be finite, $\rho$ a decidable setoid with $k = |\alpha/\rho|$, $f : \alpha \to \alpha$, and $x \in \alpha$. Then there exist $m, n \in \mathbb{N}$ with
> $$0 \le m < n \le k \qquad\text{and}\qquad f^{[m]}(x) \sim_\rho f^{[n]}(x).$$

**Proof sketch.** Apply Theorem 4.1 to obtain $m < n \le k$ with $\overline{f^{[m]}(x)} = \overline{f^{[n]}(x)}$, then apply Theorem 3.1 to upgrade the label equality to the relation $f^{[m]}(x) \sim_\rho f^{[n]}(x)$. $\qquad\blacksquare$

**Interpretation.** A deterministic process observed through a $k$-class lens is *guaranteed* to revisit an observable class within $k$ steps, from any starting point, regardless of how large or intricate the underlying state space is. The only governing quantity is the resolution $k$. This is a worst-case (not average-case) and constructive (it exhibits the indices) statement.

**Complexity remark.** As an algorithm, the theorem says $O(k)$ observations suffice to detect a coarse collision: store the $k+1$ class labels of the first $k+1$ iterates and report the first repeat. With a hash set of labels this is $O(k)$ time and $O(k)$ space; a Floyd/Brent-style two-pointer variant attains $O(1)$ extra space on the eventually-periodic label sequence.

---

## 5. Observable Orbits and the Compression Ceiling

We now turn the existence theorem into quantitative statements about how the *set* of observed labels behaves.

> **Definition 5.1 (observable structures).** Fix $\alpha$ finite, $\rho$ decidable, $f$, $x$, and a horizon $N \in \mathbb{N}$.
> - The **quotient-observable trace** is
>   $$\mathrm{trace}_N : \{0,\dots,N\} \to \alpha/\rho, \qquad \mathrm{trace}_N(i) = \overline{f^{[i]}(x)} \quad (\texttt{quotientObservableTrace}).$$
> - The **observable orbit set** is the image of the trace,
>   $$\mathcal{O}_N = \{\,\overline{f^{[i]}(x)} : 0 \le i \le N\,\} \subseteq \alpha/\rho \quad (\texttt{observableOrbitSet}).$$
> - The **observable orbit count** is $\;|\mathcal{O}_N|\;$ (`observableOrbitCount`).
> - The **observable diameter** is $\;|\mathcal{O}_N| - 1\;$ (`quotientObservableDiameter`).

> **Theorem 5.2 (`eml_observable_orbit_bound`).** For all $N$,
> $$|\mathcal{O}_N| \le k.$$

**Proof sketch.** $\mathcal{O}_N$ is a subset of the finite set $\alpha/\rho$, so its cardinality is at most $|\alpha/\rho| = k$. $\qquad\blacksquare$

> **Corollary 5.3 (`eml_observable_orbit_bound_at_quotient_card`).** Specializing $N = k$ gives $|\mathcal{O}_k| \le k$: even at the natural horizon equal to the resolution, the observable orbit cannot exceed $k$ classes.

> **Corollary 5.4 (`quotientObservableDiameter_bound`).** The observable diameter satisfies $(|\mathcal{O}_N| - 1) + 1 \le k + 1$, i.e. the diameter is at most $k - 1$ (and at most $k$ after the $+1$ normalization used in the formalization).

**Interpretation (EML / compression).** The observable log of *any* run lives in a space of size at most $k$. This is a hard, structure-independent ceiling: buffers, dictionaries, and deduplication tables sized to $k$ never overflow. Combined with Theorem 4.2, it says both that the observable state space is *bounded* (size $\le k$) and that it is *exercised efficiently* (a repeat within $k$ steps).

---

## 6. Compression Statistics

We attach two information-flavored quantities to the lens and bound them.

> **Definition 6.1.**
> - The **collision entropy** is the number of distinctions discarded by the lens,
>   $$H_\rho = |\alpha| - k \quad (\texttt{quotientCollisionEntropy}).$$
> - The **orbit compression ratio** is the retained fraction of resolution,
>   $$R_\rho = \frac{k}{|\alpha|} \quad (\texttt{orbitCompressionRatio}).$$
> - The **compression gap** between collision indices $m < n$ is $n - m$ (`quotientCompressionGap`).

> **Theorem 6.1 (`quotientCollisionEntropy_nonneg`).** $H_\rho \ge 0$.

**Proof sketch.** Since the class map $\alpha \to \alpha/\rho$ is surjective, $k \le |\alpha|$, so $|\alpha| - k \ge 0$. (As a natural-number subtraction this is immediate.) $\qquad\blacksquare$

> **Theorem 6.2 (`orbitCompressionRatio_le_one`).** $R_\rho \le 1$.

**Proof sketch.** Surjectivity of the class map gives $k \le |\alpha|$; dividing by the nonnegative denominator $|\alpha|$ yields $k/|\alpha| \le 1$. $\qquad\blacksquare$

**Interpretation.** $H_\rho$ measures information deliberately destroyed by coarse-graining; $R_\rho \in (0, 1]$ measures resolution retained. A ratio near $0$ is aggressive compression and, by Theorem 4.2, a fast recurrence guarantee; $R_\rho = 1$ is the microscope-sharp lens with the weakest (but still valid) recurrence horizon $k = |\alpha|$. The compression gap $n - m$ records the observable period exhibited by a particular collision certificate.

---

## 7. Tightness of the Horizon

The horizon $k$ in Theorem 4.2 is best possible.

> **Theorem 7.1 (tightness).** For every $k \ge 1$ there exist a finite set $\alpha$, a setoid $\rho$ with $|\alpha/\rho| = k$, a map $f$, and a start $x$ such that the *first* coarse collision occurs exactly at index $n = k$; no horizon smaller than $k$ suffices.

**Proof sketch.** Take $\alpha = \mathbb{Z}/k\mathbb{Z}$, let $\rho$ be equality (so $\alpha/\rho$ has $k$ classes), let $f(a) = a + 1 \pmod k$, and start at $x = 0$. The trajectory $0, 1, 2, \dots, k-1, 0, \dots$ visits $k$ distinct classes before its first repeat at step $k$, where $f^{[0]}(0) = f^{[k]}(0) = 0$. Thus the earliest collision index is exactly $k$, and the bound $n \le k$ is attained. $\qquad\blacksquare$

Consequently no theorem of this form can promise a collision in fewer than $k$ steps in the worst case: the single $k$-cycle saturates the bound.

---

## 8. The Three Bridges

We make the unifying readings explicit.

### 8.1 Algebraic dynamics: finite quotient recurrence

Theorem 4.2 is a constructive, worst-case recurrence theorem for coarse-grained deterministic systems: every orbit, viewed through a finite lens, folds back onto a previously seen class within $k$ steps. Unlike measure-theoretic recurrence (Poincaré), it requires no invariant measure and no probability — only finiteness and determinism — and it yields explicit witnesses.

### 8.2 Cryptography: collision certificates

Read $f$ as an iterated function and $\rho$ as "produces the same observable digest." Then a $\rho$-related pair $f^{[m]}(x) \sim_\rho f^{[n]}(x)$ is a **collision**, and Theorem 4.2 is a *certificate* that one exists within $k$ iterations — the rigorous, worst-case backbone of birthday-bound and Pollard-$\rho$ collision search. The package records this as a `lattice_crypto_collision_certificate` and, at the digest level, as a `post_quantum_security_collision_upper_bound`: the size $k$ of the observable digest space is a hard speed limit on collision resistance, no matter how large the internal state.

### 8.3 Observable-state compression and certified robustness

Theorem 5.2 gives an EML-style ceiling: observable state complexity is $O(k)$, independent of $|\alpha|$. Bundling the recurrence guarantee with the ceiling yields a universal `certified_robustness_via_quotient_compression` statement: any coarse-grained observable of a finite deterministic system is both bounded and recurrent on a horizon $k$, with checkable certificates — a desirable property for robust monitoring and verification of black-box dynamics.

---

## 9. Algorithms

**Algorithm A — Coarse-collision detection (hash-set).** Compute class labels of successive iterates, storing first-seen times in a dictionary; on the first repeated label, return the pair $(m, n)$. By Theorem 4.1 a repeat appears by index $k$, so the loop runs at most $k+1$ times. Time and space $O(k)$.

**Algorithm B — Constant-space cycle detection (Floyd).** Run a slow pointer (one step) and fast pointer (two steps) over the *label* sequence $i \mapsto \overline{f^{[i]}(x)}$ until labels coincide; then recover the entry index $m$ and period $n - m$. Time $O(k)$, extra space $O(1)$. Correctness rests on the eventual periodicity of the label sequence guaranteed by Theorem 4.2.

**Algorithm C — Compression auditing.** Given $\alpha$, $\rho$: compute $k = |\alpha/\rho|$, then report $H_\rho = |\alpha| - k$ and $R_\rho = k/|\alpha|$. Theorems 6.1 and 6.2 certify $H_\rho \ge 0$ and $R_\rho \le 1$. Time $O(|\alpha|)$ to scan and bucket states.

---

## 10. Applications

- **Black-box monitoring.** Size a deduplication table to $k$ and a watchdog timer to $k$ steps; both are provably sufficient regardless of the monitored system's internal complexity.
- **Cryptanalysis bookkeeping.** Use $k$ (the observable output-space size) as the governing parameter for worst-case collision budgets, decoupled from the often-unknown internal state size.
- **Numerical reproducibility.** A finite-precision integrator observed through a banded readout must repeat a band within $k$ steps; this bounds the length of any "novel-looking" transient.
- **Model reduction.** The compression ratio $R_\rho$ quantifies the resolution traded for recurrence speed, guiding the choice of coarse-graining.

---

## 11. Discussion and Limitations

The theory is deliberately minimal: it assumes only finiteness, determinism, and a decidable coarse lens. Its strength — total independence from the structure of $f$ — is also the boundary of its claims. It bounds the *first* coarse collision and the *size* of the observable orbit, but says nothing finer about the *distribution* of collision times without further hypotheses; average-case (birthday-style $\Theta(\sqrt{k})$) statements require probabilistic models of $f$ and lie outside this worst-case, deterministic framework. The horizon $k$ is tight in the worst case (Theorem 7.1), so improvements must come from extra structural assumptions, not from sharper counting.

---

## 12. Future Work

- **Average-case refinement.** Introduce a random model of $f$ and recover the $\Theta(\sqrt{k})$ birthday law as an expectation, with the worst-case $k$ bound as a deterministic envelope.
- **Quantitative entropy.** Relate the compression gap $n - m$ to the observable period spectrum and to information-theoretic entropy of the label process.
- **Product and skew systems.** Extend the bound to $f$ acting on products with lenses that factor, seeking multiplicative or additive horizon laws.
- **Constant-space certificates.** Formalize the Floyd/Brent label-cycle detection as a verified $O(1)$-space collision-certificate generator.

---

## 13. Conclusion

A single pigeonhole argument, made honest by a quotient-soundness bridge, yields a sharp and universal law: *a deterministic process observed through a $k$-class lens must repeat an observable class within $k$ steps, and its entire observable log lives in a space of size at most $k$.* The horizon is tight, the statistics are bounded, and the same theorem is a recurrence law, a collision certificate, and a compression ceiling at once. Resolution, not microscopic complexity, is the master variable of coarse-grained deterministic dynamics.

---

## Appendix: Symbol Glossary

| Symbol | Meaning |
|---|---|
| $\alpha$ | finite set of microscopic states |
| $f : \alpha \to \alpha$ | deterministic transition map |
| $f^{[n]}$ | $n$-fold iterate of $f$ |
| $\rho$, $\sim_\rho$ | coarse lens (setoid) and its relation |
| $\alpha/\rho$ | observable quotient (set of classes) |
| $\overline{a}=[a]_\rho$ | class label of state $a$ |
| $k = |\alpha/\rho|$ | resolution (number of observable classes) |
| $\mathcal{O}_N$ | observable orbit set up to horizon $N$ |
| $H_\rho = |\alpha|-k$ | collision entropy (discarded distinctions) |
| $R_\rho = k/|\alpha|$ | orbit compression ratio |
