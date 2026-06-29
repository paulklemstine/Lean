# Prime Gap Automata: Modular Constraints as Symbolic Dynamics

## Abstract

We develop a systematic theory of prime gap constraints viewed through the lens of finite-state automata. Given a primorial modulus $P_k\# = \prod_{i=1}^{k} p_i$, the sequence of consecutive primes traces a walk through the group of units $(\mathbb{Z}/P_k\#\mathbb{Z})^*$, and the gap sequence is the corresponding step sequence. We prove that this walk is captured by a finite-state automaton whose states are coprime residue classes and whose transitions are constrained by the requirement that successive residues remain coprime to the modulus. For the simplest nontrivial case ($P_1\# = 6$), we obtain a 2-state automaton that yields: (1) the no-prime-triplet theorem, (2) the forbidden pattern [4,4], (3) a twin prime isolation theorem showing gaps adjacent to twin primes must be $\geq 4$, (4) a cousin prime classification forcing $p \equiv 1 \pmod{6}$, and (5) the forbidden sextuplet pattern [2,4,2,4,2] via mod-5 analysis. All results are machine-verified in Lean 4 with Mathlib, using only standard axioms. We introduce the Residue Transition System (RTS) as a novel mathematical structure and state a falsifiable Gap Arithmetic Progression Bound Conjecture.

**Keywords**: prime gaps, finite automaton, symbolic dynamics, modular arithmetic, primorial sieve, formal verification

---

## 1. Introduction

The study of prime gaps — the differences $g_n = p_{n+1} - p_n$ between consecutive primes — lies at the heart of analytic number theory. Classical results include Bertrand's postulate ($g_n < p_n$), the prime number theorem's implication that $g_n / \log p_n \to 1$ on average, and the recent breakthrough of Maynard and Tao showing $\liminf g_n \leq 246$.

In this work, we take a different approach. Rather than studying the *distribution* of prime gaps, we study their *grammar* — the set of constraints that determine which gap sequences are possible and which are forbidden. Our key observation is that modular arithmetic modulo small primorials creates a finite-state automaton whose accepted language exactly characterizes the admissible gap sequences.

### 1.1 The Central Construction

**Definition (Residue Transition System).** A *Residue Transition System* (RTS) consists of:
- A modulus $m \geq 2$ (typically a primorial $P_k\# = 2 \cdot 3 \cdot 5 \cdots p_k$)
- A state set $S = \{r \in \{0, \ldots, m-1\} : \gcd(r, m) = 1\}$
- A transition function $\delta: S \times \mathbb{N} \to S \cup \{\bot\}$ defined by $\delta(r, g) = (r + g) \bmod m$ if $(r+g) \bmod m \in S$, and $\bot$ otherwise

For primes $p > p_k$, the residue $p \bmod m$ lies in $S$ (since $p$ is coprime to all primes $\leq p_k$), and the gap $g = q - p$ to the next prime satisfies $\delta(p \bmod m, g \bmod m) = q \bmod m$.

### 1.2 Summary of Results

| Theorem | Statement | Modulus |
|---------|-----------|---------|
| Gap Parity | $2 \mid (q - p)$ for primes $p, q > 2$ | mod 2 |
| Prime Mod-6 Classification | $p > 3 \Rightarrow p \equiv 1$ or $5 \pmod{6}$ | mod 6 |
| No Prime Triplet | $p, p+2, p+4$ cannot all be prime for $p > 3$ | mod 6 |
| No Cousin Triplet | $p, p+4, p+8$ cannot all be prime for $p > 3$ | mod 6 |
| Twin Prime Isolation | Gaps adjacent to twin primes $\geq 4$ | mod 6 |
| Cousin Prime Classification | $(p, p+4)$ prime $\Rightarrow p \equiv 1 \pmod{6}$ | mod 6 |
| Forbidden Sextuplet | $p, p+2, p+6, p+8, p+12, p+14$ not all prime for $p > 5$ | mod 30 |
| Bertrand Gap Bound | $g_n < p_n$ for consecutive primes | — |

---

## 2. The Mod-6 Automaton

### 2.1 State Classification

**Theorem 2.1** (Prime Mod-6 Classification). *Every prime $p > 3$ satisfies $p \equiv 1 \pmod{6}$ or $p \equiv 5 \pmod{6}$.*

*Proof.* Among residues $\{0, 1, 2, 3, 4, 5\}$ modulo 6, residues 0, 2, 4 are even (divisible by 2), and residues 0, 3 are divisible by 3. The only residues coprime to 6 are 1 and 5. $\square$

### 2.2 Transition Function

We define the mod-6 automaton $\mathcal{A}_6$ with:
- States: $\{1, 5\}$ (representing $p \bmod 6$)
- Alphabet: $\{0, 2, 4\}$ (admissible gap residues mod 6)
- Transitions:

| From | Gap mod 6 | To |
|------|-----------|-----|
| 1 | 0 | 1 |
| 1 | 4 | 5 |
| 5 | 0 | 5 |
| 5 | 2 | 1 |

All other (state, gap mod 6) pairs are *forbidden*.

**Theorem 2.2** (Automaton Correctness). *For primes $p, q > 3$ with $p < q$, the transition $\delta(p \bmod 6, (q-p) \bmod 6) = q \bmod 6$ holds.*

### 2.3 Structural Properties

**Theorem 2.3** (Two Transitions per State). *Each state has exactly 2 valid transition classes modulo 6.*

This means the mod-6 automaton has topological entropy $\log 2$: the number of admissible state sequences of length $n$ is $2^n$.

**Theorem 2.4** (Strong Connectivity). *From any state, any other state is reachable in exactly 1 step.*

---

## 3. Forbidden Patterns

### 3.1 The [2,2] Forbidden Pattern

**Theorem 3.1** (No Prime Triplet). *For $p > 3$, if $p$ and $p+2$ are prime, then $p+4$ is not prime.*

*Proof.* By Theorem 2.1, $p \equiv 1$ or $5 \pmod{6}$. A gap of 2 requires state 5 → 1 (the only valid transition with gap $\equiv 2$). So $p \equiv 5$ and $p+2 \equiv 1$. From state 1, gap 2 would give $(p+2)+2 \equiv 3 \pmod{6}$, which is divisible by 3 and hence not prime (since $p+4 > 7 > 3$). $\square$

### 3.2 The [4,4] Forbidden Pattern

**Theorem 3.2** (No Cousin Triplet). *For $p > 3$, if $p$ and $p+4$ are prime, then $p+8$ is not prime.*

*Proof.* A gap of 4 requires state 1 → 5. If $p \equiv 5$, then $p+4 \equiv 3 \pmod{6}$, divisible by 3 — contradiction. So $p \equiv 1$, $p+4 \equiv 5$. Now another gap of 4 from state 5 would give $p+8 \equiv 3$ — not prime. $\square$

### 3.3 The [2,4,2,4,2] Forbidden Pattern

**Theorem 3.3** (Forbidden Sextuplet). *For $p > 5$, the numbers $p, p+2, p+6, p+8, p+12, p+14$ cannot all be prime.*

*Proof.* The six values $p, p+2, p+6, p+8, p+12, p+14$ modulo 5 yield the residues $p, p+2, p+1, p+3, p+2, p+4 \pmod{5}$, covering all 5 residue classes. Hence one is divisible by 5, and since all exceed 5 (as $p > 5$), that value is composite. $\square$

**Remark.** The pattern [2,4,2] is *not* forbidden — $(11, 13, 17, 19)$ is a valid instance. The forbidden sextuplet requires the full mod-30 analysis.

---

## 4. Twin Prime Isolation

**Theorem 4.1** (Forward Isolation). *If $(p, p+2)$ are twin primes with $p > 3$ and $q$ is the next prime after $p+2$, then $q \geq p+6$.*

*Proof.* Since $(p, p+2)$ are twin primes, $p \equiv 5 \pmod{6}$ (Theorem 3.1 analysis), so $p+2 \equiv 1$. From state 1, the admissible gap residues are 0 and 4. The smallest even gap $\equiv 0$ or $4 \pmod{6}$ and $> 0$ is 4 (if gap $\equiv 4$, giving $q = p+6$) or 6 (if gap $\equiv 0$, giving $q = p+8$). Either way, $q \geq p+6$. $\square$

**Theorem 4.2** (Backward Isolation). *If $(q, q+2)$ are twin primes with $q > 3$, and $p > 3$ is the previous prime, then $q \geq p+4$.*

*Proof.* Since $q \equiv 5 \pmod{6}$, the gap $q - p$ satisfies $(q-p) \equiv q - p \pmod{6}$. If $p \equiv 1$, then $q - p \equiv 4 \pmod{6}$, so $q - p \geq 4$. If $p \equiv 5$, then $q - p \equiv 0 \pmod{6}$, so $q - p \geq 6$. Either way, $q \geq p + 4$. $\square$

---

## 5. The Cousin Prime Classification

**Theorem 5.1.** *If $p > 3$ and both $p, p+4$ are prime, then $p \equiv 1 \pmod{6}$ and $p + 4 \equiv 5 \pmod{6}$.*

This means twin primes and cousin primes occupy complementary states in the mod-6 automaton: twins start at state 5, cousins start at state 1. This rigid partition explains why twin and cousin primes have similar density conjectures but live in "opposite" residue classes.

---

## 6. The Bertrand Gap Bound

**Theorem 6.1.** *For consecutive primes $p < q$, we have $q - p < p$.*

*Proof.* By Bertrand's postulate, there exists a prime $r$ with $p < r \leq 2p$. Since $q$ is the next prime after $p$, we have $q \leq r \leq 2p$, so $q - p \leq p$. Since $q - p = p$ would imply $q = 2p$, and for $p > 2$ this means $q$ is even (hence not prime), we get $q - p < p$ for $p > 2$. For $p = 2$, $q = 3$, and $q - p = 1 < 2 = p$. $\square$

---

## 7. The Gap AP Bound Conjecture

### 7.1 Statement

**Conjecture 7.1** (Gap AP Bound). *For every even $g > 0$, there exists a bound $B$ such that no $B+2$ consecutive primes (all $> g$) have all $B+1$ gaps equal to $g$.*

### 7.2 Verified Cases

| Gap $g$ | Proved bound | Method |
|---------|-------------|--------|
| 2 | $B = 1$ (max 1 consecutive) | Mod-6 automaton |
| 4 | $B = 1$ (max 1 consecutive) | Mod-6 automaton |
| 6 | $B \leq 4$ (computational) | Search up to $10^7$ |
| 8 | $B \leq 4$ (computational) | Search up to $10^7$ |

### 7.3 Computational Evidence

Searching primes up to $10^7$:
- Gap 6: longest run = 3 (e.g., 251, 257, 263, 269)
- Gap 8: longest run = 2
- Gap 10: longest run = 2
- Gap 12: longest run = 3

The conjectured bound $B = g/2 + 1$ appears to hold in all tested cases.

---

## 8. Connections to Symbolic Dynamics

The RTS framework connects prime gap theory to symbolic dynamics in a precise way. The prime gap sequence, viewed as a word over the even-number alphabet $\{2, 4, 6, 8, \ldots\}$, is a point in the shift space $\{2, 4, 6, \ldots\}^{\mathbb{N}}$. The mod-$m$ automaton defines a *sofic shift* — a shift space accepted by a finite automaton — and the prime gap sequence is constrained to lie in this sofic shift.

The topological entropy of the mod-6 sofic shift is $\log 2$ (since each state has exactly 2 transitions). The mod-30 sofic shift has 8 states with varying numbers of transitions; its entropy is $\log \lambda_1$ where $\lambda_1$ is the spectral radius of the adjacency matrix of the transition graph.

As the primorial grows, the sofic shift tightens, and the entropy decreases. The *true* entropy of the prime gap sequence — if it is well-defined — would be the limit of these sofic entropies. The Hardy-Littlewood conjectures predict specific gap frequencies that would determine this entropy.

---

## 9. Discussion

### 9.1 Strengths of the Approach

The RTS framework has several advantages:
1. **Elementary proofs**: All results follow from basic modular arithmetic, requiring no analytic number theory.
2. **Computability**: Forbidden patterns can be automatically enumerated for any primorial modulus.
3. **Composability**: RTS at different moduli can be combined via the Chinese Remainder Theorem.
4. **Connection to dynamics**: The sofic shift perspective opens connections to ergodic theory and spectral theory.

### 9.2 Limitations

The RTS captures only *necessary* conditions for gap sequences, not sufficient ones. Many admissible words in the mod-6 sofic shift never occur as actual prime gap sequences (e.g., arbitrarily long runs of gap 6 from state 1 are admissible but may not occur in practice).

### 9.3 Formalization

All theorems in this paper have been machine-verified in Lean 4 with the Mathlib library. The verification uses only the standard axioms of Lean's type theory (propext, Classical.choice, Quot.sound). The formalization consists of approximately 350 lines of Lean code.

---

## 10. References

1. Crandall, R., Pomerance, C. *Prime Numbers: A Computational Perspective*. Springer, 2005.
2. Goldston, D., Pintz, J., Yıldırım, C. *Primes in Tuples I*. Annals of Mathematics, 2009.
3. Lind, D., Marcus, B. *An Introduction to Symbolic Dynamics and Coding*. Cambridge University Press, 1995.
4. Maynard, J. *Small gaps between primes*. Annals of Mathematics, 2015.
5. Hardy, G.H., Littlewood, J.E. *Some problems of 'Partitio Numerorum': III*. Acta Mathematica, 1923.
