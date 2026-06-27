# Unconditional Cycle Obstructions for the Collatz Step Map

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Applications (Discrete Dynamical Systems / Number Theory)

---

## Abstract

The Collatz Conjecture asserts that the iterated dynamics of the map $T(n) = n/2$ for even $n$ and $T(n) = 3n+1$ for odd $n$ drives every positive integer to $1$. While the global conjecture remains open, a great deal can be established *unconditionally* about the local and cyclic structure of $T$. We give a self-contained, fully formalized development of a small but logically complete chain of obstructions to the existence of nontrivial periodic orbits. Concretely, we establish: (i) the parity evaluation rules $T(n)=n/2$ (even) and $T(n)=3n+1$ (odd); (ii) the one-step monotonicity dichotomy — even steps strictly decrease positive inputs (`T_lt_of_even`) while odd steps strictly increase any input (`T_gt_of_odd`); (iii) the absence of positive fixed points (`T_no_fixed_point`); (iv) an exact "all-even descent" identity stating that a run of $k$ consecutive even iterates divides the input by $2^k$ (`all_even_descent`); and (v) the structural theorem that every positive periodic orbit must contain an odd element (`periodic_has_odd`). The last result rules out the simplest conceivable counterexample to Collatz — a cycle composed entirely of halving steps — and exposes the precise mechanism by which any putative nontrivial cycle is forced to repeatedly invoke the expanding odd rule. We discuss the placement of these results within the broader theory of stopping times, ergodic averages, and $2$-adic (p-adic) dynamics, and we outline a research program extending each obstruction.

---

## 1. Introduction

### 1.1 The problem

Define the **Collatz step map** $T : \mathbb{N} \to \mathbb{N}$ on the natural numbers by

$$
T(n) = \begin{cases} n/2 & \text{if } n \equiv 0 \pmod 2, \\ 3n + 1 & \text{if } n \equiv 1 \pmod 2. \end{cases}
$$

Here $n/2$ denotes the (exact, since $n$ is even) integer quotient. Write $T^{[k]}$ for the $k$-fold iterate $T \circ T \circ \cdots \circ T$ ($k$ times), with the convention $T^{[0]} = \mathrm{id}$. The **Collatz Conjecture** (also the $3n+1$ problem, Ulam's problem, the Syracuse problem, or the Hasse algorithm) states:

> **Conjecture (Collatz, c. 1937).** For every positive integer $n$ there exists $k \ge 0$ with $T^{[k]}(n) = 1$.

The conjecture has been verified computationally for all $n \le 2^{68} \approx 2.95 \times 10^{20}$, yet a proof has eluded mathematics for over eight decades. Erdős famously remarked that "mathematics may not be ready for such problems."

### 1.2 The two failure modes

A counterexample to the conjecture — a positive integer whose orbit never reaches $1$ — must exhibit at least one of two behaviors:

- **Divergence:** the orbit $\{T^{[k]}(n)\}_{k\ge 0}$ is unbounded.
- **Nontrivial cycling:** the orbit enters a periodic loop disjoint from the trivial cycle $\{1, 4, 2\}$.

This paper focuses on **unconditional obstructions to cycling**. We do not assume the conjecture; every result below is a theorem of elementary number theory, holding for all positive integers without exception. Our contribution is a tightly organized, machine-verified chain culminating in the statement that *no Collatz cycle can be built from even steps alone* — every cycle must contain an odd element.

### 1.3 Methodology and scope

All results in this paper have been formalized and mechanically verified in the Lean 4 theorem prover (using the Mathlib library) as the modules `Applications.Collatz.Basic` and `Applications.Collatz.CycleObstruction`. The present document presents the mathematics in standard prose, with proof sketches faithful to the verified arguments. The reader needs no external references: every definition, lemma, and theorem is stated inline with its full mathematical content and a complete proof sketch.

We emphasize the modest and honest scope: these are **partial results**. None of them resolves the Collatz Conjecture. Their value lies in establishing, with total certainty, structural constraints that any counterexample must satisfy — constraints that hold uniformly over the infinitely many integers no computation can survey.

---

## 2. Definitions and elementary lemmas

Throughout, $\mathbb{N} = \{0, 1, 2, \ldots\}$ denotes the natural numbers, and all division is integer (floor) division; for even $n$ the quotient $n/2$ is exact. We say $n$ is **even** if $n \equiv 0 \pmod 2$ and **odd** if $n \equiv 1 \pmod 2$.

### Definition 2.1 (Collatz step map)

$$
T(n) = \begin{cases} n/2 & \text{if } n \bmod 2 = 0, \\ 3n + 1 & \text{otherwise.} \end{cases}
$$

In the formalization this is the definition

```
def T (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1.
```

The following two lemmas simply record the value of $T$ resolved by parity; they are used to rewrite $T$ in every subsequent proof.

### Lemma 2.2 (`T_even`)

*If $n$ is even, then $T(n) = n/2$.*

**Proof.** By definition $T(n)$ branches on the predicate $n \bmod 2 = 0$, which holds exactly when $n$ is even. The "then" branch evaluates to $n/2$. $\square$

### Lemma 2.3 (`T_odd`)

*If $n$ is odd, then $T(n) = 3n + 1$.*

**Proof.** When $n$ is odd, $n \bmod 2 = 1 \ne 0$, so $T(n)$ takes the "else" branch, which evaluates to $3n+1$. $\square$

### Lemma 2.4 (`T_lt_of_even`) — even steps strictly descend

*If $n > 0$ and $n$ is even, then $T(n) < n$.*

**Proof.** By Lemma 2.2, $T(n) = n/2$. For any $n > 1$ we have $n/2 < n$; more precisely, for $n>0$ and divisor $2 > 1$, integer division satisfies $n/2 < n$ (this is `Nat.div_lt_self` with the witnesses $0 < n$ and $1 < 2$). Hence $T(n) = n/2 < n$. $\square$

### Lemma 2.5 (`T_gt_of_odd`) — odd steps strictly ascend

*If $n$ is odd, then $T(n) > n$.*

**Proof.** By Lemma 2.3, $T(n) = 3n + 1$. Since $3n + 1 > n$ for every natural number $n$ (indeed $3n + 1 - n = 2n + 1 \ge 1 > 0$), the claim follows by linear arithmetic. $\square$

Lemmas 2.4 and 2.5 together form the **monotonicity dichotomy**: *every even step strictly shrinks a positive number, and every odd step strictly grows it.* This dichotomy is the engine driving all of the cyclic obstructions in Section 3. Intuitively, $T$ alternates between a contraction (factor $1/2$) and an expansion (factor slightly more than $3$), and the global difficulty of Collatz is precisely the difficulty of controlling the interleaving of these two opposing forces.

---

## 3. Unconditional cycle obstructions

### 3.1 No fixed points

### Theorem 3.1 (`T_no_fixed_point`)

*For every $n > 0$, $T(n) \ne n$.*

**Proof.** Split on the parity of $n$.

- If $n$ is even, Lemma 2.4 gives $T(n) < n$, so $T(n) \ne n$.
- If $n$ is odd, Lemma 2.5 gives $T(n) > n$, so $T(n) \ne n$.

In both cases $T(n) \ne n$. $\square$

Theorem 3.1 rules out cycles of length $1$. It is the base case of the cyclic analysis: a positive integer can never be a fixed point of $T$, because $T$ is never the identity on any positive input — it either strictly contracts or strictly expands.

### 3.2 The all-even descent identity

The next result quantifies what happens during a maximal run of consecutive even iterates. It converts a *dynamical* hypothesis (a streak of even values) into an *exact arithmetic* conclusion (division by a power of two).

### Theorem 3.2 (`all_even_descent`)

*Let $n, k \in \mathbb{N}$. If $T^{[i]}(n)$ is even for every $i$ with $0 \le i < k$, then*

$$
T^{[k]}(n) = \frac{n}{2^k}.
$$

**Proof.** Induction on $k$.

*Base case* ($k = 0$): $T^{[0]}(n) = n = n/2^0$, since $2^0 = 1$. The evenness hypothesis is vacuous.

*Inductive step:* Assume the statement for $k$, under the hypothesis that $T^{[i]}(n)$ is even for all $i < k+1$. In particular it holds for all $i < k$, so the induction hypothesis yields $T^{[k]}(n) = n/2^k$. The hypothesis at index $i = k$ states that $T^{[k]}(n)$ is even. Now compute, using the iterate identity $T^{[k+1]}(n) = T\big(T^{[k]}(n)\big)$ and Lemma 2.2:

$$
T^{[k+1]}(n) = T\big(T^{[k]}(n)\big) = \frac{T^{[k]}(n)}{2} = \frac{n/2^k}{2} = \frac{n}{2^k \cdot 2} = \frac{n}{2^{k+1}}.
$$

The step $\dfrac{n/2^k}{2} = \dfrac{n}{2^{k+1}}$ uses the natural-number identity $(n / a)/b = n/(a b)$ (Mathlib's `Nat.div_div_eq_div_mul`) together with $2^k \cdot 2 = 2^{k+1}$. This completes the induction. $\square$

**Remark.** The identity is exact in integer arithmetic precisely *because* the evenness hypothesis guarantees each halving is exact (no remainder is lost). This is the crucial subtlety that makes the conclusion an equality rather than an inequality.

### 3.3 Every cycle contains an odd element

We now reach the central structural theorem. A **periodic point** of $T$ of period $p \ge 1$ is a positive integer $n$ with $T^{[p]}(n) = n$. Its orbit $\{n, T(n), \ldots, T^{[p-1]}(n)\}$ is a (not necessarily minimal-length) cycle.

### Theorem 3.3 (`periodic_has_odd`)

*Let $n > 0$ and $p > 0$ satisfy $T^{[p]}(n) = n$. Then there exists $i$ with $0 \le i < p$ such that $T^{[i]}(n)$ is odd.*

**Proof.** Suppose, for contradiction, that no iterate in the first lap is odd: $T^{[i]}(n)$ is even for all $i < p$. Then the hypothesis of Theorem 3.2 holds with $k = p$, giving

$$
T^{[p]}(n) = \frac{n}{2^p}.
$$

By the periodicity hypothesis $T^{[p]}(n) = n$, so $n = n/2^p$. But $p \ge 1$ implies $2^p \ge 2 > 1$, and for $n > 0$ with divisor $2^p > 1$ we have the strict inequality $n/2^p < n$ (again `Nat.div_lt_self`, with $1 < 2 \le 2^p$). Hence

$$
n = \frac{n}{2^p} < n,
$$

which is impossible. The assumption fails, so some $T^{[i]}(n)$ with $i < p$ must be odd. $\square$

**Interpretation.** Theorem 3.3 says that the trivial "all-halving" cycle is the *only* thing that pure descent could produce, and descent strictly shrinks, so it cannot close up into a loop. Any genuine cycle is therefore obligated to invoke the expanding odd rule $n \mapsto 3n+1$ at least once. Combined with the monotonicity dichotomy (Lemmas 2.4–2.5), this gives a clean picture of cyclic dynamics: around any cycle, the contractions (halvings) and expansions (triplings) must balance exactly in net effect, and at least one expansion is unavoidable. This is the discrete-dynamics seed of the well-known heuristic that in a cycle the number of odd steps $O$ and even steps $E$ must satisfy $3^{O} \approx 2^{E}$, i.e. $E/O \approx \log 3/\log 2$.

---

## 4. Algorithms

The theorems above are naturally accompanied by simple, exact algorithms over the integers. We summarize the two most relevant.

### 4.1 Orbit iteration and trajectory profiling

**Goal.** Given $n > 0$, produce the trajectory $n, T(n), T^{[2]}(n), \ldots$ until it reaches $1$ (or a step budget is exhausted), recording statistics: the total stopping time (steps to reach $1$), the maximum value attained ("altitude"), and the parity word (the sequence of E/O steps).

**Complexity.** Each step is $O(1)$ machine arithmetic on numbers of bit-length $b$, so $O(b)$ bit operations per step; the total cost is proportional to the (empirically modest) stopping time. The parity word is exactly the data that Theorems 3.2–3.3 analyze: a run of E's of length $k$ multiplies the value by $2^{-k}$, and Theorem 3.3 forbids a parity word over a full period from being all E.

**Pseudocode.**

```
function COLLATZ_TRAJECTORY(n, max_steps):
    assert n > 0
    trajectory <- [n]
    parity_word <- ""
    steps <- 0
    while n != 1 and steps < max_steps:
        if n mod 2 == 0:
            parity_word <- parity_word + "E"   # even step: n -> n/2
            n <- n / 2
        else:
            parity_word <- parity_word + "O"   # odd step:  n -> 3n+1
            n <- 3*n + 1
        append n to trajectory
        steps <- steps + 1
    return (trajectory, parity_word, steps, max(trajectory))
```

### 4.2 Cycle detection via Floyd's algorithm (and the odd-element witness)

**Goal.** Decide whether the orbit of $n$ enters a cycle that does *not* contain $1$, and if so, exhibit the cycle and confirm Theorem 3.3 by locating an odd element in it.

**Method.** Floyd's tortoise-and-hare algorithm advances a slow pointer one $T$-step at a time and a fast pointer two $T$-steps at a time; a collision certifies a cycle without storing the whole orbit. For the Collatz map every detected cycle (up to verified bounds) is $\{1,4,2\}$, which contains the odd element $1$ — an empirical confirmation of `periodic_has_odd`.

**Complexity.** $O(\lambda + \mu)$ map evaluations and $O(1)$ memory, where $\mu$ is the tail length before the cycle and $\lambda$ the cycle length.

**Pseudocode.**

```
function FIND_CYCLE(n):
    slow <- T(n);  fast <- T(T(n))
    while slow != fast:
        slow <- T(slow)
        fast <- T(T(fast))
    # collision: recover cycle start
    mu <- 0;  slow <- n
    while slow != fast:
        slow <- T(slow);  fast <- T(fast);  mu <- mu + 1
    # measure cycle and find odd witness
    cycle <- [slow];  x <- T(slow);  odd_witness <- none
    while x != slow:
        if x is odd and odd_witness is none: odd_witness <- x
        append x to cycle;  x <- T(x)
    if slow is odd and odd_witness is none: odd_witness <- slow
    return (cycle, odd_witness)   # odd_witness is guaranteed to exist (Thm 3.3)
```

---

## 5. Applications and connections

### 5.1 Stopping times

The **stopping time** $\sigma(n)$ is the least $k > 0$ with $T^{[k]}(n) < n$, and the **total stopping time** is the least $k$ with $T^{[k]}(n) = 1$. The monotonicity dichotomy (Lemmas 2.4–2.5) is the atomic ingredient of every stopping-time estimate: each even step is a guaranteed unit of descent, each odd step a guaranteed unit of ascent. Residue-class analysis sharpens this: for instance, numbers $n \equiv 1 \pmod 4$ provably drop below $n$ within a bounded number of steps, certifying a positive-density set of "tame" integers unconditionally. Theorem 3.2 is the exact computation underlying any such residue-class certificate when the prescribed prefix consists of even steps.

### 5.2 Ergodic theory

Viewing $T$ (or its odd-accelerated variant) as a measure-preserving transformation on a suitable space allows the toolkit of ergodic theory — Birkhoff averages, mixing, entropy — to be brought to bear on long-run orbit statistics. The heuristic "$3^O \approx 2^E$ around a cycle," made rigorous in part by Theorem 3.3's forcing of odd steps, mirrors the ergodic prediction that the geometric-mean multiplier per step is $\sqrt{3}/2 < 1$, suggesting typical descent. Tao's theorem that Collatz orbits attain almost bounded values almost everywhere is the deepest expression of this probabilistic intuition.

### 5.3 $p$-adic (2-adic) dynamics

The halving operation is, by its nature, an operation about the prime $2$. The number of consecutive halvings available at a value is its $2$-adic valuation $v_2$, and Theorem 3.2 is precisely the statement $T^{[k]}(n) = n/2^k$ whenever $k \le v_2(n)$. This invites lifting the accelerated odd map to the ring of $2$-adic integers $\mathbb{Z}_2$, where it extends to a measure-preserving homeomorphism conjugate to the shift; under this lens, Collatz convergence becomes a statement about the orbit of $1$ under a $2$-adic shift. This is the most structurally suggestive of the modern viewpoints and the subject of Future Direction 3 below.

---

## 6. Discussion

The results of this paper are deliberately elementary, and that is their point. The Collatz Conjecture resists every heavy instrument; what remains tractable — and what is worth pinning down with absolute certainty — is the local algebra of the map and the structural constraints it places on cycles. We have shown:

1. $T$ has no positive fixed point (Theorem 3.1).
2. Consecutive even steps divide exactly by powers of two (Theorem 3.2).
3. Consequently, every positive cycle contains an odd element (Theorem 3.3).

The logical architecture is economical: two parity-evaluation lemmas (2.2, 2.3) yield the monotonicity dichotomy (2.4, 2.5), which yields both the no-fixed-point result (3.1) and, via the descent identity (3.2), the central cycle theorem (3.3). Every link is mechanically verified, so the chain is sound end to end.

What these results do *not* do is equally important to state plainly. They do not bound cycle lengths, do not rule out divergence, and do not establish convergence for any infinite class beyond what residue certificates provide. They close the *all-even* cycle escape route completely and expose the odd/even tension quantitatively, but the conjecture itself remains open.

---

## 7. Future work

The following directions extend the present results; the first three are concrete formalization targets and the fourth is a density program.

**(1) Uniform stopping-time bounds per residue class mod $2^m$.** Conjecture: for every $m$, all but the single class $n \equiv 1 \pmod{2^m}$ of the $2^m$ residue classes strictly drop below $n$ within $2m$ steps, with explicit affine drop constants. The mechanism generalizes the depth-$m$ unfolding of $T$: each fixed prefix of $m$ steps acts as an affine map $n \mapsto (3^a n + c)/2^m$ whose contraction is decidable from $a$ alone.

**(2) Cycle-length lower bound from the even/odd dichotomy.** Conjecture: any nontrivial cycle of length $k$ has at least $k\,\log 2/\log 3$ odd elements, sharpening Theorem 3.3 from "$\ge 1$ odd" to a linear count. The idea: each step is a signed multiplicative change ($\times \tfrac12$ or $\times \tfrac32$), and a cycle's net log-change is zero, forcing the odd/even counts into the ratio $\log 2 : \log 3$.

**(3) $2$-adic conjugacy of the accelerated odd map.** Conjecture: the accelerated odd map extends to a measure-preserving homeomorphism of $\mathbb{Z}_2$ conjugate to the shift, with Collatz convergence equivalent to topological transitivity of the shift orbit of $1$. The valuation identity $v_2 = \mathrm{padicValNat}\,2$ makes the halving count literally a $2$-adic operation.

**(4) Density of the unconditionally-convergent set.** Conjecture: the set of $n$ provably dropping below $n$ via finitely many residue-class certificates has natural density $1$, even though full convergence stays open. Iterating certificates over deeper moduli should exhaust density $1$ while never closing the last density-$0$ gap.

---

## Appendix A. Summary of formalized results

| Name | Statement |
|---|---|
| `T` | $T(n) = n/2$ if $n$ even, $3n+1$ if $n$ odd |
| `T_even` | $n$ even $\Rightarrow T(n) = n/2$ |
| `T_odd` | $n$ odd $\Rightarrow T(n) = 3n+1$ |
| `T_lt_of_even` | $n > 0$, $n$ even $\Rightarrow T(n) < n$ |
| `T_gt_of_odd` | $n$ odd $\Rightarrow T(n) > n$ |
| `T_no_fixed_point` | $n > 0 \Rightarrow T(n) \ne n$ |
| `all_even_descent` | $(\forall i<k,\ T^{[i]}(n)$ even$) \Rightarrow T^{[k]}(n) = n/2^k$ |
| `periodic_has_odd` | $n>0$, $p>0$, $T^{[p]}(n)=n \Rightarrow \exists i<p,\ T^{[i]}(n)$ odd |

All statements are theorems of elementary number theory, holding unconditionally for all positive integers.
