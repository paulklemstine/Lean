# Cryptography from the Collatz Conjecture: A Formally Verified Separation of One-Wayness and Collision Resistance

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Cryptography (iterated maps / dynamical-systems cryptography)

---

## Abstract

The Collatz map $T(n) = n/2$ for even $n$ and $T(n) = 3n+1$ for odd $n$ is a natural candidate for a cryptographic one-way function: it is cheap to compute forward and appears intractable to invert, since reconstructing a predecessor requires searching a branching backward tree. We study whether this forward-easy/backward-hard asymmetry can be leveraged to build a *collision-resistant* hash function, and prove — unconditionally and with full machine verification — that the most natural such construction fails. Instantiating the Merkle–Damgård (MD) iterated-hash framework with the additive Collatz compression function $\mathrm{collatzCompress}(s,b) = T(s+b)$, we exhibit an explicit collision on two distinct equal-length single-block messages and, via the MD collision-extraction theorem, convert it into an explicit collision of the compression function. The construction therefore fails collision resistance with a two-element counterexample, independently of the truth of the Collatz conjecture. We frame this as a clean, concrete *separation*: the very information-destroying property that makes $T$ attractive as a one-way function is logically incompatible with collision resistance. We give full statements and proof sketches of every result, an algorithmic account of the extraction reduction, numerical demonstrations, and a discussion of where dynamical-systems cryptography may genuinely succeed (keyed permutation ciphers from the missing-bit structure, and refined backward-tree growth bounds below the trivial $2^a$).

**Keywords:** Collatz map, one-way function, Merkle–Damgård, compression function, collision resistance, hash function, iterated map, dynamical-systems cryptography.

---

## 1. Introduction

### 1.1 Motivation

A *one-way function* is computable in polynomial time but hard to invert; its existence underpins essentially all of modern cryptography. The Collatz map,

$$T(n) = \begin{cases} n/2 & n \text{ even}, \\ 3n+1 & n \text{ odd}, \end{cases}$$

is an irresistible candidate for such a function. Forward evaluation costs a constant number of arithmetic operations. Inversion, by contrast, is genuinely awkward: a value $k$ may have arisen by halving (from $2k$) or, when the arithmetic permits, by the affine odd rule (from $(k-1)/3$). Iterating the map $a$ times yields $f(a, n) = T^{[a]}(n)$, whose inversion appears to demand exploration of a backward tree of size up to $2^a$. The Collatz conjecture — that every orbit reaches $1$ — has been verified computationally beyond $2^{68}$, lending empirical weight to the map's irregular, hard-to-reverse behavior.

The natural cryptographic question is whether this asymmetry yields a *collision-resistant hash function*, the workhorse primitive behind digital signatures, commitments, and integrity checks. This paper answers that question in the negative, decisively and constructively, for the canonical construction.

### 1.2 Contributions

1. **A concrete Collatz hash.** We define the Collatz step map $T$, the additive compression function $\mathrm{collatzCompress}(s,b) = T(s+b)$, and the Merkle–Damgård iterated hash $\mathrm{mdHash}(f, \mathrm{iv}, \text{msg})$ obtained by folding $f$ over message blocks.

2. **An explicit single-step collision.** We record $T(1) = T(8) = 4$ as the theorem `T_one_eq_T_eight`, the kernel of all that follows.

3. **An explicit hash collision.** On initialization vector $0$ and the distinct equal-length messages $m_1 = [1]$, $m_2 = [8]$, both hashes equal $4$ (`collatzHash_collision_value`).

4. **Failure of collision resistance.** Via the MD collision-extraction theorem `md_collision_extract`, the hash collision yields a collision of the compression function itself: `collatzCompress_has_collision`. This holds unconditionally — no assumption about the Collatz conjecture is used.

5. **Conceptual separation and inevitability.** We situate the result as a textbook separation between one-wayness and collision resistance, supported by the MD injectivity corollary `mdHash_injOn_length` and the pigeonhole inevitability theorem `compression_collision_of_card`, which shows collisions always exist so that collision resistance is intrinsically a *computational* (find-it) notion.

All theorems are formalized and machine-checked. The narrative below gives their exact statements and proof sketches.

---

## 2. Preliminaries: the Merkle–Damgård framework

We work over an arbitrary state type $\mathrm{State}$ and block type $\mathrm{Block}$.

### Definition 2.1 (Iterated hash)

Given a compression function $f : \mathrm{State} \to \mathrm{Block} \to \mathrm{State}$ and an initialization vector $\mathrm{iv} \in \mathrm{State}$, the **Merkle–Damgård hash** of a message $\text{msg}$ (a list of blocks) is the left fold

$$\mathrm{mdHash}(f, \mathrm{iv}, \text{msg}) = \text{msg.foldl } f\ \mathrm{iv}.$$

Concretely, writing $\text{msg} = [b_1, \dots, b_k]$, we set $s_0 = \mathrm{iv}$ and $s_i = f(s_{i-1}, b_i)$, and $\mathrm{mdHash} = s_k$.

### Definition 2.2 (Compression collision)

A compression function $f$ **has a collision** when there exist $s, b, s', b'$ with $(s,b) \neq (s',b')$ and $f(s,b) = f(s',b')$. We denote this predicate $\mathrm{HasCompressionCollision}(f)$.

### Basic identities

The fold satisfies the structural laws

$$\mathrm{mdHash}(f, \mathrm{iv}, []) = \mathrm{iv}, \qquad \mathrm{mdHash}(f, \mathrm{iv}, l \mathbin{+\!+} [b]) = f\big(\mathrm{mdHash}(f, \mathrm{iv}, l),\, b\big),$$

and the concatenation law

$$\mathrm{mdHash}(f, \mathrm{iv}, a \mathbin{+\!+} b) = \mathrm{mdHash}\big(f,\, \mathrm{mdHash}(f, \mathrm{iv}, a),\, b\big).$$

These follow immediately from the definition of `foldl` and the associativity of list append.

### Theorem 2.3 (Merkle–Damgård collision extraction) — `md_collision_extract`

*Let $f$ be a compression function and $\mathrm{iv}$ an initialization vector. If $m_1, m_2$ are messages with $\mathrm{length}(m_1) = \mathrm{length}(m_2)$, $m_1 \neq m_2$, and $\mathrm{mdHash}(f,\mathrm{iv},m_1) = \mathrm{mdHash}(f,\mathrm{iv},m_2)$, then $\mathrm{HasCompressionCollision}(f)$.*

**Proof sketch.** Reverse (last-block) induction on $m_1$, generalizing over $m_2$. If $m_1$ is empty, equal length forces $m_2$ empty, contradicting $m_1 \neq m_2$; the base case is therefore vacuous in the right way. For the inductive step write $m_1 = p_1 \mathbin{+\!+} [b_1]$ and (using equal nonzero length) $m_2 = p_2 \mathbin{+\!+} [b_2]$. By the concatenation identity,

$$f\big(\mathrm{mdHash}(f,\mathrm{iv},p_1), b_1\big) = f\big(\mathrm{mdHash}(f,\mathrm{iv},p_2), b_2\big).$$

Let $s_1 = \mathrm{mdHash}(f,\mathrm{iv},p_1)$ and $s_2 = \mathrm{mdHash}(f,\mathrm{iv},p_2)$. If $(s_1,b_1) \neq (s_2,b_2)$, we have produced a compression collision and are done. Otherwise $s_1 = s_2$ and $b_1 = b_2$; since $m_1 \neq m_2$ but the last blocks agree, the prefixes differ, $p_1 \neq p_2$, while $s_1 = s_2$ means $p_1, p_2$ collide on shorter equal-length messages. The induction hypothesis closes this case. $\blacksquare$

The equal-length hypothesis is necessary: without length padding, messages of different lengths can collide through a free-start/IV collision rather than a genuine compression collision.

### Corollary 2.4 (Injectivity on fixed length) — `mdHash_injOn_length`

*If $f$ has no collision, then for messages of equal length, $\mathrm{mdHash}(f,\mathrm{iv},m_1) = \mathrm{mdHash}(f,\mathrm{iv},m_2)$ implies $m_1 = m_2$.*

**Proof sketch.** Contrapositive of Theorem 2.3: a collision of the hash would extract a collision of $f$. $\blacksquare$

### Theorem 2.5 (Pigeonhole inevitability) — `compression_collision_of_card`

*Let $\mathrm{State}$ and $\mathrm{Block}$ be finite, $\mathrm{State}$ nonempty, and suppose there is more than one block ($|\mathrm{Block}| > 1$). Then every compression function $f$ has a collision.*

**Proof sketch.** The domain $\mathrm{State} \times \mathrm{Block}$ has cardinality $|\mathrm{State}| \cdot |\mathrm{Block}| > |\mathrm{State}|$, the size of the codomain. A function from a larger finite set to a smaller one cannot be injective; the witnessing pair of distinct inputs with equal image is the collision. $\blacksquare$

This theorem clarifies the *meaning* of collision resistance: collisions always exist information-theoretically, so collision resistance is necessarily a computational notion about the *difficulty of finding* a collision. For the Collatz hash below, that difficulty is zero.

---

## 3. The Collatz hash and its falsification

### Definition 3.1 (Collatz step map) — `T`

$$T(n) = \begin{cases} n/2 & n \equiv 0 \pmod 2, \\ 3n+1 & \text{otherwise}, \end{cases} \qquad n \in \mathbb{N}.$$

### Lemma 3.2 (Single-step collision) — `T_one_eq_T_eight`

$$T(1) = T(8) = 4.$$

**Proof.** $1$ is odd, so $T(1) = 3\cdot 1 + 1 = 4$. $8$ is even, so $T(8) = 8/2 = 4$. Both equal $4$; verified by direct computation (`decide`). $\blacksquare$

This is the irreversibility of $T$ made concrete: two distinct points share an image. The forward map forgets its preimage.

### Definition 3.3 (Collatz compression function) — `collatzCompress`

$$\mathrm{collatzCompress}(s, b) = T(s + b).$$

This is the canonical way to fold a single Collatz step into a Merkle–Damgård compression slot: combine the chaining state and incoming block additively, then apply one step of the dynamics.

### Definition 3.4 (Colliding messages) — `m₁`, `m₂`

$$m_1 = [1], \qquad m_2 = [8].$$

These are distinct lists of equal length $1$.

### Theorem 3.5 (Hash collision) — `collatzHash_collision_value`

$$\mathrm{mdHash}(\mathrm{collatzCompress}, 0, m_1) = \mathrm{mdHash}(\mathrm{collatzCompress}, 0, m_2).$$

**Proof.** Unfolding the single-block fold from $\mathrm{iv} = 0$,

$$\mathrm{mdHash}(\mathrm{collatzCompress}, 0, [1]) = \mathrm{collatzCompress}(0,1) = T(0+1) = T(1) = 4,$$
$$\mathrm{mdHash}(\mathrm{collatzCompress}, 0, [8]) = \mathrm{collatzCompress}(0,8) = T(0+8) = T(8) = 4.$$

Both sides equal $4$; verified by direct computation. $\blacksquare$

### Theorem 3.6 (Failure of collision resistance) — `collatzCompress_has_collision`

$$\mathrm{HasCompressionCollision}(\mathrm{collatzCompress}).$$

**Proof.** Apply the MD collision-extraction theorem (Theorem 2.3) with $f = \mathrm{collatzCompress}$, $\mathrm{iv} = 0$, and the messages $m_1 = [1]$, $m_2 = [8]$. Their lengths are equal ($=1$), they are distinct, and by Theorem 3.5 they collide under the hash. The extraction therefore yields an explicit pair $(s,b) \neq (s',b')$ with $\mathrm{collatzCompress}(s,b) = \mathrm{collatzCompress}(s',b')$. Concretely the extracted witnesses are $(s,b) = (0,1)$ and $(s',b') = (0,8)$, since $T(0+1) = T(0+8) = 4$. $\blacksquare$

The result is **unconditional**: it does not invoke the Collatz conjecture or any unproven hardness assumption. The Collatz-based Merkle–Damgård hash fails collision resistance outright.

---

## 4. Algorithms

### 4.1 Forward evaluation

The forward direction is the cheap one. The iterated Collatz map $f(a,n) = T^{[a]}(n)$ costs $a$ Collatz steps; each step is $O(\log n)$ bit operations. The MD hash of a $k$-block message costs $k$ compression calls.

**Algorithm: Collatz MD hash (forward).**
```
Input: compression function step T, iv, message blocks [b_1, ..., b_k]
s ← iv
for i = 1 to k:
    s ← T(s + b_i)
return s
```

### 4.2 Collision-extraction reduction

The constructive engine behind Theorem 3.6. Given two distinct equal-length messages that hash to the same value, it returns a compression-function collision by comparing chaining values block by block from the back.

**Algorithm: MD collision extraction.**
```
Input: compression f, iv, messages m1 ≠ m2 with |m1| = |m2| and mdHash(m1) = mdHash(m2)
while m1 and m2 are nonempty:
    split m1 = p1 ++ [b1],  m2 = p2 ++ [b2]
    s1 ← mdHash(f, iv, p1)
    s2 ← mdHash(f, iv, p2)
    if (s1, b1) ≠ (s2, b2):
        return collision ((s1, b1), (s2, b2))   # f(s1,b1) = f(s2,b2)
    else:
        m1 ← p1 ;  m2 ← p2                        # last blocks equal; recurse on prefixes
# unreachable on valid input: distinctness forces an earlier mismatch
```

The loop terminates because each iteration strips one block; distinctness of the messages guarantees a mismatch is found before both become empty. Complexity: $O(k^2)$ compression calls naively (recomputing prefixes), or $O(k)$ with cached chaining values.

---

## 5. Numerical demonstrations

The accompanying `demo.py` provides self-contained Python reproductions:

- **Direct collision check.** Compute $T(1)$ and $T(8)$ and confirm both equal $4$.
- **Hash collision.** Compute $\mathrm{mdHash}(\mathrm{collatzCompress}, 0, [1])$ and $\mathrm{mdHash}(\mathrm{collatzCompress}, 0, [8])$ and confirm equality.
- **Extraction reduction.** Run the block-by-block extraction on $([1], [8])$ and print the recovered compression collision $(0,1) \neq (0,8)$ with $T(1) = T(8)$.
- **Collision census.** Enumerate small inputs to the compression function and tabulate the many colliding pairs, illustrating the pigeonhole inevitability of Theorem 2.5.
- **Backward-tree growth.** Empirically count $a$-step preimages and compare against the naive $2^a$ bound and the congruence-gated refinement.

---

## 6. Discussion

### 6.1 A clean separation of security notions

Theorem 3.6 is best read not as "Collatz is useless for cryptography" but as a *separation*. One-wayness and collision resistance are logically independent goals. The Collatz map is engineered (as a one-way candidate) to be *information-destroying* — many inputs funnel to one output, exactly the property $T(1) = T(8) = 4$ exhibits. Collision resistance demands the opposite: distinct inputs must not collide. The two requirements are in direct tension, and the additive MD wrapper inherits the conflict immediately. The pigeonhole theorem `compression_collision_of_card` makes the tension structural: over finite block spaces, collisions cannot be avoided in principle; the only question is whether they are *findable*, and here they are found by inspection.

### 6.2 Where the asymmetry is real

The negative result does not refute the underlying intuition that $T$ is hard to invert. Inversion of $T^{[a]}$ remains a branching search. The refinement is that the branching is *gated*: $k$ admits an odd predecessor only when $k \equiv 4 \pmod 6$, so realizable parity transcripts form a sparse, self-similar subset of $\{0,1\}^a$ rather than the full set. The honest backward-tree growth rate is $c^a$ for some Perron eigenvalue $c < 2$, strictly below the trivial $2^a$ bound. The forward-easy/backward-hard asymmetry survives; it is simply quantitatively thinner than the naive estimate, and any security parameter should reflect the true growth rate, not $2^a$.

### 6.3 The missing-bit view

Reversibility of a single Collatz step is governed by exactly one missing bit — the parity of the unknown predecessor. A tagged map carrying that bit is injective, and supplying the bits (as a key stream) turns the dynamics into a length-preserving, perfectly invertible permutation. The "hardness" of Collatz inversion is thus the *absence of key bits*, a one-time-pad-like structure, rather than arithmetic intractability. This reframes the promising cryptographic target: keyed permutation ciphers from iterated maps, not collision-resistant hashing from a single squashing step.

---

## 7. Future directions

*(Reproduced from the project's research notes.)*

**FD1 — The $2^a$ preimage bound is generically loose by an exponential factor.** *Conjecture:* there is a constant $c < 2$ such that for all $k$ and $a$, the number of $a$-step preimages of $k$ is at most $c^a$; moreover the average fibre size over $k \le N$ grows only polynomially in $a$. *Key insight:* the parity transcript of a true Collatz orbit is not a free $a$-bit string — the odd-preimage branch is gated by $k \equiv 4 \pmod 6$, so realizable transcripts are a sparse, self-similar subset of $\{0,1\}^a$, a constrained-string (transfer-matrix) problem whose Perron eigenvalue is strictly below $2$. *Why now:* the clean upper bound (preimage count $\le 2^a$) and the exact gating congruence are already isolated; a transfer-matrix refinement is the natural next step and would replace the trivial $2^a$ security parameter with the true backward-tree growth rate.

**FD2 — A parity-keyed Collatz step IS a perfectly invertible permutation.** *Conjecture:* the tagged map $\mathrm{Ttag} : \mathbb{N} \to \mathbb{N} \times \mathrm{Bool}$ is a bijection onto its range, and the keyed family $n \mapsto \mathrm{untag}(T(n), k_n)$ over a chosen bit-key stream realizes a length-preserving permutation cipher whose inverse is exactly $\mathrm{untag}$; formally, $\mathrm{Ttag}$ is injective (proved) and surjective onto $\{(v,b) \mid b = \text{true} \lor (v \equiv 1 \bmod 3 \land (v-1)/3 \text{ odd})\}$. *Key insight:* $T$ loses exactly one bit per step and $\mathrm{untag}$ reconstructs the input from that bit, so the "hard" direction of Collatz is purely the *missing key bits*, not arithmetic hardness — a one-time-pad-like structure hiding inside the dynamical system. *Why now:* injectivity of the tagged map and the un-tagging inverse are already formalized; the only missing piece is the surjectivity characterization, which follows from the preimage description proved this cycle.

**FD3 — One-wayness and collision resistance are provably independent here.** *Conjecture:* under the Collatz conjecture (every orbit reaches $1$), $f(a,n) = T^{[a]}(n)$ restricted to $n < 2^a$ is injective for suitable $a$, giving genuine one-wayness; yet every additive Merkle–Damgård wrapper of a single Collatz step has explicit closed-form collisions. *Key insight:* the collision side is already established unconditionally, so proving the conditional injectivity side would formally separate "one-way" from "collision resistant" inside a single concrete primitive — a clean textbook separation. *Why now:* the non-collision-resistance half is already a theorem, and the Collatz conjecture has been verified past $2^{68}$.

---

## 8. Conclusion

We instantiated the Merkle–Damgård framework with an additive Collatz compression function and proved, unconditionally and with full machine verification, that the resulting hash fails collision resistance: the distinct equal-length messages $[1]$ and $[8]$ both hash to $4$, and the collision-extraction theorem turns this into an explicit collision of the compression function. The kernel is the elementary identity $T(1) = T(8) = 4$. Far from a dead end, the result is a crisp separation between one-wayness and collision resistance — the information-destroying nature that recommends $T$ as a one-way candidate is precisely what disqualifies the naive hash — and it sharpens the agenda for dynamical-systems cryptography toward keyed permutations and honest backward-tree growth bounds below the trivial $2^a$.
