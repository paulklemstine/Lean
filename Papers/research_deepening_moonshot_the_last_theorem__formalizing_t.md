# The Arithmetic of the Discoverable: Enumeration, Non-Exhaustibility, and the Physical Limits of Mathematical Discovery

## Abstract

We give a rigorous account of a phenomenon we call the *finite/infinite scissor* in the theory of formal discovery. Fix a formal system over a finite alphabet whose set of provable statements (theorems) is infinite. We prove three complementary facts. **(1)** The set of theorems is countably infinite and admits an explicit, computable enumeration — the *shortlex* enumeration — in which each theorem occupies a unique finite index. **(2)** Consequently each individual theorem has a well-defined finite *discovery index*: a systematic search finds it after finitely many steps. **(3)** Nevertheless, for every finite budget $N$ the set of theorems discovered within $N$ steps is finite while the undiscovered set remains infinite; no finite process exhausts the theorems. We then connect this purely mathematical dichotomy to physics. Using standard bounds on physical computation (Landauer's principle, the Margolus–Levitin and Bremermann bounds) together with the finiteness of the free energy available over the future history of the universe, we conclude that any physically realizable discovery process performs only finitely many enumeration steps and therefore discovers only finitely many of the countably infinitely many theorems. The heat death of the universe thus imposes a permanent, quantitative ceiling on mathematical *access* while leaving mathematical *truth* untouched. We close with a discussion of enumeration-order optimality, cooperative multi-system discovery, and a resource-bounded incompleteness gap, and we supply numerical demonstrations of every quantitative claim.

**Keywords:** enumeration, countability, shortlex order, formal systems, computability, physical limits of computation, Bremermann limit, Margolus–Levitin bound, heat death, non-exhaustibility.

---

## 1. Introduction

The question "how much of mathematics can ever be known?" is usually treated as philosophy. We treat it as a theorem-proving exercise with a physical corollary. The engine of the paper is a tension between two senses of the word *finite*:

- **Per-object finiteness.** Every theorem is reached at a finite stage of a systematic search.
- **Collective non-finiteness.** No finite stage reaches every theorem.

These are not in conflict; they are two true facts about a single infinite list, and their interplay — the *scissor* — is exactly what determines how much of an infinite subject a finite process can uncover. When the "finite process" is a physical computer bounded by the free energy budget of a universe headed toward heat death, the scissor becomes a statement about the ultimate reach of science.

The paper is organized as follows. Section 2 fixes definitions. Section 3 proves the three core mathematical results. Section 4 develops the physical model and the heat-death corollary. Section 5 addresses enumeration-order optimality and multi-system cooperation. Section 6 states a resource-bounded incompleteness gap. Section 7 discusses interpretation, and Section 8 lists open problems. Numerical illustrations appear throughout and are collected in the accompanying computational supplement.

---

## 2. Definitions

Throughout, $\Sigma$ is a fixed **finite alphabet** with $|\Sigma| = k \ge 1$, and we assume a total order on $\Sigma$ (its "alphabetical" order).

**Definition 2.1 (Statements).** A *statement* is a finite string over $\Sigma$. The set of all statements is $\Sigma^{*} = \bigcup_{\ell \ge 0} \Sigma^{\ell}$, where $\Sigma^{\ell}$ is the set of strings of length exactly $\ell$. Note $|\Sigma^{\ell}| = k^{\ell}$, which is finite for every $\ell$.

**Definition 2.2 (Formal system).** A *formal system* $S$ is specified by a set of axioms and a finite set of inference rules over $\Sigma$. Its *theorem set* $T_S \subseteq \Sigma^{*}$ is the set of statements admitting a finite derivation from the axioms using the rules. We assume throughout that $T_S$ is **infinite**; this holds for any consistent system expressive enough to prove, e.g., all instances of a nontrivial parameterized identity.

We deliberately keep $S$ abstract: none of our results depends on the internal mechanics of proof, only on the two structural facts that (i) $\Sigma$ is finite and (ii) each proof is a finite object, so that $T_S \subseteq \Sigma^{*}$.

**Definition 2.3 (Shortlex order).** The *shortlex* (short-length-first, then lexicographic) order $\preceq$ on $\Sigma^{*}$ is defined by: $u \prec v$ iff either $|u| < |v|$, or $|u| = |v|$ and $u$ precedes $v$ lexicographically under the fixed order on $\Sigma$.

**Definition 2.4 (Enumeration).** An *enumeration* of $\Sigma^{*}$ is a bijection $e : \mathbb{N} \to \Sigma^{*}$. The *shortlex enumeration* $e_{\mathrm{sl}}$ is the unique enumeration that is order-preserving from $(\mathbb{N}, \le)$ to $(\Sigma^{*}, \preceq)$: it lists the strings of length $0$, then length $1$ in lexicographic order, then length $2$, and so on.

**Definition 2.5 (Discovery index).** Fix an enumeration $e$. For $\theta \in \Sigma^{*}$ the *index* of $\theta$ is the unique $n \in \mathbb{N}$ with $e(n) = \theta$. For a theorem $\theta \in T_S$ we also call this its *discovery index* $\mathrm{idx}_e(\theta)$: the number of steps a search that enumerates via $e$ and checks each candidate for provability takes before first printing $\theta$.

**Definition 2.6 (Discovery frontier).** For a budget $N \in \mathbb{N}$, the *discovered set* is $D_e(N) = \{\, \theta \in T_S : \mathrm{idx}_e(\theta) < N \,\}$ and the *frontier* is the largest length $\ell$ such that every theorem of length $\le \ell$ lies in $D_e(N)$.

**Definition 2.7 (Natural density).** For $A \subseteq \Sigma^{*}$ and enumeration $e$, the *upper density* of $A$ is $\overline{d}_e(A) = \limsup_{N \to \infty} \tfrac{1}{N} \left| \{\, n < N : e(n) \in A \,\} \right|$, with the lower density defined by $\liminf$; when they agree the common value is the *density* $d_e(A)$.

---

## 3. Core Results

### 3.1 The Enumeration Theorem

**Theorem 3.1 (Countability and enumeration).** *Let $S$ be a formal system over a finite alphabet $\Sigma$ with infinite theorem set $T_S$. Then $T_S$ is countably infinite, and the shortlex enumeration $e_{\mathrm{sl}} : \mathbb{N} \to \Sigma^{*}$ is a bijection under which each theorem occupies a unique finite index.*

*Proof sketch.* First, $\Sigma^{*}$ is countable: it is a countable union $\bigcup_{\ell} \Sigma^{\ell}$ of finite sets $\Sigma^{\ell}$ (each of size $k^{\ell}$), and a countable union of finite sets is countable. Concretely, the shortlex order is a well-order in which every element has only finitely many predecessors (the strings of smaller length, plus the lexicographically earlier strings of equal length — a total of $\sum_{j<\ell} k^{j} + (\text{rank within } \Sigma^{\ell})$ many, a finite count). Mapping each string to the number of its predecessors gives an order isomorphism $\Sigma^{*} \cong \mathbb{N}$; its inverse is $e_{\mathrm{sl}}$. Since $T_S \subseteq \Sigma^{*}$ is infinite and any infinite subset of a countable set is countably infinite, $T_S$ is countably infinite. Each $\theta \in T_S$ has the finite index $\mathrm{idx}_{e_{\mathrm{sl}}}(\theta) = |\{\, s : s \prec \theta \,\}| < \infty$. $\qquad\blacksquare$

The content is entirely structural: finiteness of the alphabet forces each length-class to be finite, and finiteness of proofs forces theorems to be strings. No assumption about *decidability* of $T_S$ is needed for countability; decidability matters only for whether the search can *recognize* a theorem when it prints one, which we address next.

### 3.2 The Discovery Index Theorem

**Theorem 3.2 (Existence and uniqueness of discovery indices).** *Under the hypotheses of Theorem 3.1, every theorem $\theta \in T_S$ has a unique finite discovery index $\mathrm{idx}_{e_{\mathrm{sl}}}(\theta)$. Moreover, if $S$ is such that provability is semi-decidable (the standard case: proofs can be checked mechanically), then a systematic search that dovetails candidate statements against candidate proofs prints $\theta$ after finitely many steps.*

*Proof sketch.* Uniqueness and finiteness of the index are immediate from bijectivity of $e_{\mathrm{sl}}$ (Theorem 3.1). For the effective version, dovetail: enumerate pairs $(\text{statement } s,\ \text{proof candidate } p)$ in shortlex order on the finite-string encoding of pairs, and check whether $p$ is a valid derivation of $s$. Since $\theta$ is a theorem it has *some* finite proof $p_0$; the pair $(\theta, p_0)$ has a finite index in the dovetailed enumeration, so the search reaches it in finitely many steps and prints $\theta$. $\qquad\blacksquare$

The two theorems together yield the optimistic blade of the scissor: **reachability**. There is no theorem "beyond the list." Every provable statement is the value $e_{\mathrm{sl}}(n)$ for some finite $n$, and a mechanical search will emit it after finitely many steps.

### 3.3 The Non-Exhaustibility Theorem

**Theorem 3.3 (Non-exhaustibility).** *Under the hypotheses of Theorem 3.1, for every finite budget $N \in \mathbb{N}$:*
1. *the discovered set $D_{e_{\mathrm{sl}}}(N)$ is finite, with $|D_{e_{\mathrm{sl}}}(N)| \le N$;*
2. *the undiscovered set $T_S \setminus D_{e_{\mathrm{sl}}}(N)$ is infinite.*
*In particular no finite budget exhausts $T_S$, while $|D_{e_{\mathrm{sl}}}(N)| \to \infty$ as $N \to \infty$.*

*Proof sketch.* A search of $N$ steps inspects the $N$ statements $e_{\mathrm{sl}}(0), \dots, e_{\mathrm{sl}}(N-1)$ and prints only those that are theorems, so $|D_{e_{\mathrm{sl}}}(N)| \le N < \infty$. Because $T_S$ is infinite (Theorem 3.1) and $D_{e_{\mathrm{sl}}}(N)$ is finite, the complement $T_S \setminus D_{e_{\mathrm{sl}}}(N)$ is infinite. Finally, since $e_{\mathrm{sl}}$ is a bijection and $T_S$ is infinite, arbitrarily large indices are occupied by theorems, so $|D_{e_{\mathrm{sl}}}(N)|$ is nondecreasing and unbounded, i.e. tends to $\infty$. $\qquad\blacksquare$

Theorems 3.2 and 3.3 are the two blades. The first says *"each theorem: finite."* The second says *"all theorems: never finite."* They coexist for exactly the reason the natural numbers coexist with the fact that counting never ends: an infinite well-order in which every element has finite rank.

**Remark 3.4 (Independence of "infinitely often" and "positive frequency").** Non-exhaustibility ($|D(N)| \to \infty$) does *not* require the theorems to have positive density. It is consistent for $T_S$ to have density zero, so that $|D_{e_{\mathrm{sl}}}(N)|/N \to 0$, while still $|D_{e_{\mathrm{sl}}}(N)| \to \infty$. "Discovered infinitely often" and "discovered with positive frequency" are logically independent; the scissor uses only the former. This refinement is the seed of Conjecture 8.1.

---

## 4. The Physical Ceiling

The results of Section 3 are pure mathematics: they hold in any universe. What makes them consequential is that physical discovery processes have a *finite* step budget.

### 4.1 Bounds on physical computation

We use three standard results.

**Landauer's principle.** Erasing one bit of information at temperature $\Theta$ dissipates at least $k_B \Theta \ln 2$ of energy as heat, where $k_B$ is Boltzmann's constant. Logically irreversible steps therefore have a strictly positive energy cost that grows with the ambient temperature the waste heat must be dumped into.

**Margolus–Levitin bound.** A quantum system with average energy $E$ above its ground state can pass through at most $2E/(\pi \hbar)$ orthogonal (distinguishable) states per second. This caps the *rate* of elementary operations by the available energy.

**Bremermann's limit.** Combining mass–energy equivalence with the Margolus–Levitin rate gives a maximum of about $c^2 / (\pi \hbar) \approx 1.36 \times 10^{50}$ operations per second per kilogram of mass-energy devoted to computation.

**Definition 4.1 (Budget function).** A physical discovery process is modeled by a *budget function* $B : \mathbb{R}_{\ge 0} \to \mathbb{N}$, where $B(t)$ is the maximum number of enumeration steps the process can complete by time $t$. Realistic $B$ are nondecreasing.

### 4.2 Finiteness of the total budget

The decisive physical input is that the **total** number of operations available over the entire future is finite. Two independent arguments give this.

1. **Total-operations bound (retrospective).** Treating the observable universe as one computer running since the Big Bang, the Margolus–Levitin/Bremermann rate applied to its total mass-energy over its elapsed age yields a cumulative bound on the order of $10^{120}$ elementary operations to date — a finite number.

2. **Free-energy exhaustion (prospective).** Computation requires *free* energy (energy able to do work), and every irreversible step dumps entropy into the environment (Landauer). As the universe evolves toward thermodynamic equilibrium — uniform temperature, maximal entropy, the heat death — the free energy available to drive further operations decreases toward zero. Hence $\lim_{t \to \infty} B(t) = B_\infty$ exists and is **finite**: there is a last feasible operation.

We abstract both into a single hypothesis.

**Hypothesis 4.2 (Finite lifetime budget).** For a physical discovery process with budget function $B$, the total budget $B_\infty := \lim_{t\to\infty} B(t) = \sup_t B(t)$ is finite.

### 4.3 The heat-death corollary

**Theorem 4.3 (Heat-Death Corollary).** *Let $S$ be a formal system with infinite theorem set $T_S$ (Theorem 3.1), and let a physical discovery process have budget function $B$ satisfying Hypothesis 4.2 with total budget $B_\infty < \infty$. Then, regardless of enumeration order:*
1. *the process discovers at most $B_\infty$ theorems over the entire future of the universe;*
2. *the set of theorems it never discovers is infinite.*

*Proof sketch.* By definition the process completes at most $B_\infty$ enumeration steps in total, and each step can discover at most one new theorem, so the total discovered set $D_\infty$ satisfies $|D_\infty| \le B_\infty < \infty$. By Theorem 3.3 (with $N = B_\infty$), $T_S \setminus D_\infty$ is infinite. $\qquad\blacksquare$

The corollary is independent of the numerical value of $B_\infty$. Whether the true figure is $10^{120}$, $10^{123}$, or any other finite number, it is dwarfed by the countable infinity of theorems. **The universe exhausts its capacity to compute strictly before it exhausts the theorems to be found.** Note also the corollary is *order-independent*: choosing a cleverer enumeration changes *which* $B_\infty$ theorems are found, never *how many*.

---

## 5. Optimal Order and Cooperation

The Heat-Death Corollary shifts the interesting question from *how many* (fixed at $B_\infty$) to *which* — and that is governed by enumeration order.

### 5.1 Optimality of shortlex for frontier discovery

**Proposition 5.1 (Frontier optimality of shortlex).** *Among all enumerations of $\Sigma^{*}$, the shortlex enumeration minimizes the worst-case index at which the last statement of each length is first seen; equivalently, it minimizes the number of steps needed to guarantee discovery of every statement up to a given length $\ell$.*

*Proof sketch.* To have seen every statement of length $\le \ell$, an enumeration must have listed all $\sum_{j \le \ell} k^{j}$ such strings; any enumeration needs at least that many steps, and shortlex achieves the bound exactly because it lists precisely those strings first, in its initial $\sum_{j\le\ell} k^j$ positions, before any longer string. Length is the only monotone complexity measure compatible with the finiteness of each length class, which is why length-first ordering is forced for minimax-optimal frontier discovery. $\qquad\blacksquare$

This gives shortlex a second justification: it is not merely *a* convenient enumeration establishing countability, it is the *optimal* schedule for sweeping out complexity-bounded regions of the statement space as fast as possible.

### 5.2 Cooperation between systems

**Proposition 5.2 (Cooperative discovery).** *Let $S_1, S_2$ be formal systems each with infinite theorem set. Then $T_{S_1} \cup T_{S_2}$, any fair interleaving of shortlex searches of $S_1$ and $S_2$, and (when infinite) $T_{S_1} \cap T_{S_2}$ are all countably infinite and non-exhaustible by any finite budget. Moreover a fair interleaving discovers any complexity-bounded target region of the union in a number of steps within a bounded factor of the faster of the two individual searches.*

*Proof sketch.* Unions and (infinite) intersections of countable sets are countable, and remain infinite under the stated hypotheses, so Theorem 3.3 applies verbatim to the combined set: non-exhaustibility is closed under the Boolean operations preserving infinitude. For the acceleration claim, a fair round-robin interleaving performs step $m$ of each search after $O(m)$ combined steps; hence to reach a target found at step $m_i$ by search $i$, the interleaving needs $O(\min(m_1, m_2))$ steps, i.e. it matches the better search up to the constant interleaving factor. $\qquad\blacksquare$

Cooperation cannot defeat the scissor — the pooled theory is still never finished — but it is a strictly better use of a finite budget, buying a constant-factor speedup toward any given frontier.

---

## 6. A Resource-Bounded Incompleteness Gap

The classical incompleteness phenomenon concerns statements that are *unprovable* in principle. The scissor produces a different, resource-theoretic gap: statements that are perfectly provable yet never *discovered* under a finite budget.

**Theorem 6.1 (Resource-bounded gap).** *Let $S$ have infinite theorem set $T_S$, and let $B : \mathbb{N} \to \mathbb{N}$ be any budget function (allowing $B(t)$ steps by time $t$) that is finite at each $t$. Then for every time $t$ the set of theorems not yet discovered by time $t$ is infinite. If additionally $B$ is bounded (Hypothesis 4.2), the set of theorems never discovered is infinite.*

*Proof sketch.* For fixed $t$, apply Theorem 3.3 with $N = B(t) < \infty$: the discovered set is finite and its complement in the infinite $T_S$ is infinite. The bounded case is Theorem 4.3. $\qquad\blacksquare$

Thus even an *immortal but energy-limited* discoverer (finite total budget) — and, a fortiori, one facing heat death — faces a permanent, infinite backlog of provable-but-undiscovered truths. Unprovability is not required for permanent ignorance; a finite budget suffices.

---

## 7. Discussion

**The loss is collective, not individual.** No specific theorem is placed beyond reach by Theorem 4.3; for any target there is an enumeration order (and a possible history) that finds it within budget. What is lost is the *totality*: the finite budget selects a finite prefix, and the identity of that prefix is a matter of chosen order, not of principle. This sharpens the folk worry that mathematics might "end." The threat was never completion (there is no last theorem in the list) but its opposite: perpetual incipience.

**Truth versus access.** Sections 3 and 4 cleanly separate two things often conflated. The *existence* and *countability* of theorems are timeless mathematical facts (Section 3). Their *discoverability by us* is a physical, budgeted process (Section 4). Heat death touches only the latter. Mathematics is inexhaustible before the first star and after the last; the heat death ends our access, not the subject.

**Why length is special.** The finiteness of each length class $\Sigma^{\ell}$ is the linchpin shared by every result: it makes shortlex a well-order with finite ranks (Theorem 3.1), gives discovery indices (Theorem 3.2), forces $|D(N)| \le N$ (Theorem 3.3), and singles out length as the optimal sort key (Proposition 5.1). Everything follows from "finite alphabet, finite proofs."

---

## 8. Open Problems and Future Directions

We record several conjectures extending the finite/infinite scissor.

**Conjecture 8.1 (No positive density floor).** For a fixed enumeration of $\Sigma^{*}$ and any system whose theorem set has natural density zero, the fraction of the first $N$ statements that are theorems tends to $0$, yet the count of discovered theorems still tends to infinity. The key point is that "discovered infinitely often" and "discovered with positive frequency" are independent (Remark 3.4): a system can be exhaustively enumerable in the limit while being ever more sparsely represented at each finite horizon. Density is the natural quantitative refinement of the qualitative gap.

**Conjecture 8.2 (Optimal enumerations minimize worst-case discovery time).** Among all enumerations of $\Sigma^{*}$, shortlex minimizes the index at which the *last* statement of each length is first seen — it is optimal for the worst-case time to discover everything up to length $n$. Length is the only monotone complexity measure compatible with the finiteness of every length class, so ordering by length first is forced for any minimax-optimal discovery schedule. (Proposition 5.1 is the base case; the conjecture is the full minimax statement over all target profiles.)

**Conjecture 8.3 (Two-system interleaving preserves non-exhaustibility).** If two systems each prove infinitely many statements, then the union, the (infinite) intersection, and any fair interleaving of their theorem sets remain countably infinite and non-exhaustible by any finite budget; moreover the interleaved discovery frontier of the union is, up to a bounded factor, the better of the two individual frontiers. Non-exhaustibility is closed under the Boolean operations that preserve infinitude, so combining theories cannot rescue a finite process — but it can accelerate discovery by a constant factor. (Proposition 5.2 establishes the qualitative half.)

**Conjecture 8.4 (Resource-bounded incompleteness gap).** For every budget function $B : \mathbb{N} \to \mathbb{N}$ modeling an energy budget that allows $B(t)$ enumeration steps by time $t$, and every infinitely-proving system, the set of theorems never discovered by time $t$ is infinite for every $t$; and if $B$ is bounded then the set of forever-undiscovered theorems is infinite. (Theorem 6.1 proves this in the stated form; the open direction is to characterize *which* theorems fall in the gap as a function of the growth rate of $B$.)

---

## 9. Conclusion

We have isolated a clean dichotomy at the heart of mathematical discovery. The theorems of any formal system over a finite alphabet are countably infinite and individually reachable at finite enumeration indices (Theorems 3.1, 3.2), yet collectively non-exhaustible by any finite budget (Theorem 3.3). Layering in the physical limits of computation and the finiteness of the universe's free-energy budget, we obtain the Heat-Death Corollary (Theorem 4.3): any physical discovery process finds only finitely many of infinitely many theorems, leaving an infinite remainder forever undiscovered. The order of enumeration, not the count, is the true degree of freedom (Propositions 5.1, 5.2). The heat death of the universe is not the death of mathematics — only the end of our finite budget for reading an infinite book.
