# The Rank of Apparition is a Join-Semilattice Morphism

## Abstract

The *rank of apparition* of a modulus `m` in an integer sequence `u` is the least positive
index `k` with `m ∣ u(k)`. For *strong divisibility sequences* — those satisfying
`u(gcd(m,n)) = gcd(u(m), u(n))` — the rank obeys the fundamental biconditional, here called the
*spine*, `m ∣ u(n) ⇔ rank(m) ∣ n`. This single identity is known to imply the classical
divisibility laws for Fibonacci numbers (`F(a) ∣ F(b) ⇔ a ∣ b`) and for the sequences
`a^n − 1` (`(a^m − 1) ∣ (a^n − 1) ⇔ m ∣ n`). Prior developments established that the rank is
**monotone** for divisibility (`b ∣ a ⇒ rank(b) ∣ rank(a)`), i.e. an order morphism on the
divisibility poset. We sharpen this to a full structural statement: the rank of apparition is a
**homomorphism of join-semilattices** `(ℕ_{>0}, lcm) → (ℕ_{>0}, lcm)`. Concretely,
`rank(lcm(a,b)) = lcm(rank(a), rank(b))` whenever `a` and `b` have ranks; moreover the existence
of ranks is *closed* under `lcm`, so the rank of the join is never assumed but always
manufactured from the ranks of the parts. We derive a coprime entry-point corollary
`rank(a·b) = lcm(rank(a), rank(b))` (for coprime `a, b`), and specialize the join law to two
concrete instances — the Fibonacci entry-point-of-an-lcm law and the analogous Mersenne law
`rank(lcm(a^m − 1, a^n − 1)) = lcm(m,n)`. We also explain why the dual *meet* law fails: only
the one-sided divisibility `gcd(rank(a), rank(b)) ∣ rank(gcd(a,b))` holds, reflecting that the
rank behaves as a lower-adjoint-like map preserving joins but not meets. All results are
established constructively from the spine alone, with no sequence-specific input beyond strong
divisibility.

---

## 1. Introduction and motivation

Let `u : ℕ → ℕ` be an integer sequence. Two of the most celebrated divisibility facts in
elementary number theory are:

- **Fibonacci.** `F(a) ∣ F(b) ⇔ a ∣ b` (for `a ≥ 3`), where `F` is the Fibonacci sequence.
- **Mersenne-type.** `(a^m − 1) ∣ (a^n − 1) ⇔ m ∣ n` (for `a ≥ 2`, `m ≥ 1`).

These look like accidents of two unrelated sequences. They are not. Both `F` and `n ↦ a^n − 1`
are *strong divisibility sequences*: their values satisfy `u(gcd(m,n)) = gcd(u(m), u(n))`. From
this single property one extracts the *rank of apparition* `rank(m)` — the least positive index
at which `m` first divides a sequence value — and the master biconditional

> `m ∣ u(n) ⇔ rank(m) ∣ n`  (the *spine*).

The spine converts statements about the (typically exponentially large) values `u(n)` into
statements about the indices `n`, and it instantly yields both classical laws above.

What was previously established about the *modulus* dependence of the rank was only its
**monotonicity**: `b ∣ a ⇒ rank(b) ∣ rank(a)`. Order-theoretically, `rank` is a morphism of
the divisibility poset `(ℕ_{>0}, ∣)`. The poset `(ℕ_{>0}, ∣)` is in fact a lattice: its join is
`lcm` and its meet is `gcd`. A monotone map between lattices need not respect either operation.
The natural sharpening is therefore:

> Does `rank` respect the lattice operations?

The contribution of this work is a complete answer:

1. **Join: preserved exactly.** `rank(lcm(a,b)) = lcm(rank(a), rank(b))` — the rank is a
   join-semilattice homomorphism.
2. **Meet: not preserved.** `rank(gcd(a,b)) = gcd(rank(a), rank(b))` fails; only
   `gcd(rank(a), rank(b)) ∣ rank(gcd(a,b))` holds in general.

The asymmetry is structural, not accidental: a join-preserving monotone map between lattices is
the signature of a *lower adjoint*, which need not preserve meets.

---

## 2. Definitions

Throughout, `u : ℕ → ℕ`, and `gcd`, `lcm` are the natural-number greatest common divisor and
least common multiple, with the conventions `gcd(0,n) = n` and `lcm(a,b) = a·b / gcd(a,b)`
(and `lcm(a,b) = 0` if either is `0`).

**Definition 2.1 (Strong divisibility sequence).** A sequence `u : ℕ → ℕ` is a *strong
divisibility sequence* (SDS) if
> `u(gcd(m, n)) = gcd(u(m), u(n))` for all `m, n ∈ ℕ`.

**Definition 2.2 (Has a rank).** A modulus `m` *has a rank of apparition* in `u`, written
`HasRank(u, m)`, if there exists `k > 0` with `m ∣ u(k)`:
> `HasRank(u, m) :⇔ ∃ k, 0 < k ∧ m ∣ u(k)`.

**Definition 2.3 (Rank of apparition).** The *rank of apparition* of `m` in `u` is
> `rank(u, m) := the least k > 0 with m ∣ u(k)`, and `0` if no such `k` exists.

We write `rank(m)` when `u` is understood. Note `rank(u, m) > 0` exactly when `HasRank(u, m)`.

**Definition 2.4 (Primitive divisor).** `q` is a *primitive divisor* of `u(n)` if `q ∣ u(n)`
but `q ∤ u(k)` for all `0 < k < n`. (Used in §7.)

---

## 3. The engine core (recalled)

We recall the basic facts about the rank that follow from the SDS hypothesis. These constitute
the "engine" on which the new results run; all are proved constructively.

**Lemma 3.1 (Weak divisibility law).** If `u` is an SDS and `m ∣ n`, then `u(m) ∣ u(n)`.

*Proof.* `m ∣ n` gives `gcd(m,n) = m`, so `u(m) = u(gcd(m,n)) = gcd(u(m), u(n)) ∣ u(n)`. ∎

**Lemma 3.2 (Defining properties of the rank).** If `HasRank(u, m)` then:
(i) `rank(u, m) > 0`; (ii) `m ∣ u(rank(u, m))`; and (iii) for all `0 < k < rank(u, m)`,
`m ∤ u(k)`.

*Proof.* Immediate from the well-ordering characterization of the least witness (`Nat.find`):
(i) and (ii) are the witness property; (iii) is its minimality. ∎

**Theorem 3.3 (The spine).** If `u` is an SDS and `HasRank(u, m)`, then for all `n`,
> `m ∣ u(n) ⇔ rank(u, m) ∣ n`.

*Proof sketch.* Write `r = rank(u, m)`, so `r > 0` and `m ∣ u(r)`.

(⇐) If `r ∣ n`, then `u(r) ∣ u(n)` by Lemma 3.1, and `m ∣ u(r) ∣ u(n)`.

(⇒) Suppose `m ∣ u(n)` but `r ∤ n`, for contradiction. Then `gcd(r, n) < r` (a proper divisor
of `r`). Now `m ∣ u(r)` and `m ∣ u(n)`, so `m ∣ gcd(u(r), u(n)) = u(gcd(r, n))` by the SDS law.
But `0 < gcd(r,n) < r` contradicts the minimality of `r` (Lemma 3.2(iii)). Hence `r ∣ n`. ∎

**Theorem 3.4 (Order morphism / monotonicity).** If `u` is an SDS, `b ∣ a`, and both have
ranks, then `rank(u, b) ∣ rank(u, a)`.

*Proof.* `b ∣ a ∣ u(rank(u,a))`, so `b ∣ u(rank(u,a))`; the spine for `b` gives
`rank(u,b) ∣ rank(u,a)`. ∎

**Theorem 3.5 (Rigidity).** If `u(k) > 0` for all `k > 0` and `u` is strictly increasing on
positive indices below `k`, then `rank(u, u(k)) = k`.

*Proof.* `u(k) ∣ u(k)` so `k` is a witness; for `0 < j < k`, `0 < u(j) < u(k)` forces
`u(k) ∤ u(j)`, so `k` is the least witness. ∎

For Fibonacci this gives `rank(F, F(k)) = k` for `k ≥ 3`; combined with the spine it recovers
`F(a) ∣ F(b) ⇔ a ∣ b`. For the SDS `u(n) = a^n − 1` (`a ≥ 2`) it recovers
`(a^m − 1) ∣ (a^n − 1) ⇔ m ∣ n`.

**Existence (totality) for Fibonacci.** Every `m ≥ 1` has a rank in `F`. The Fibonacci shift
`σ(x, y) = (y, x + y)` is a bijection on `(ℤ/mℤ)²` (inverse `(x,y) ↦ (y − x, x)`), and
`σ^k(0, 1) = (F(k) mod m, F(k+1) mod m)`. By pigeonhole on the finite set `(ℤ/mℤ)²`, two
iterates coincide; reversibility back-steps to `(0,1)`, yielding `k > 0` with `m ∣ F(k)`. This
is the abstract Pisano-period mechanism.

---

## 4. Main results: the join-semilattice morphism

We now state and prove the new structural theorems. Fix an SDS `u`.

### 4.1 Existence of the rank of an lcm is automatic

**Theorem 4.1 (Closure of existence under join).** If `u` is an SDS and both `a` and `b` have
ranks, then `lcm(a, b)` has a rank.

*Proof.* Let `r_a = rank(u, a) > 0`, `r_b = rank(u, b) > 0`, and put `k = lcm(r_a, r_b) > 0`.
Since `r_a ∣ k`, Lemma 3.1 gives `u(r_a) ∣ u(k)`, and `a ∣ u(r_a)` (Lemma 3.2(ii)), so
`a ∣ u(k)`. Symmetrically `b ∣ u(k)`. Hence `lcm(a,b) ∣ u(k)` (as `lcm` is the least common
upper bound for divisibility), with `k > 0`. So `HasRank(u, lcm(a,b))`. ∎

The significance is that the join law below never needs to *postulate* the rank of `lcm(a,b)`:
the witness is built from the witnesses for `a` and `b`.

### 4.2 The join law

**Theorem 4.2 (Join morphism).** If `u` is an SDS and both `a`, `b` have ranks, then
> `rank(u, lcm(a, b)) = lcm(rank(u, a), rank(u, b))`.

*Proof.* Write `r_a = rank(u, a)`, `r_b = rank(u, b)`, `r = rank(u, lcm(a,b))` (exists by
Theorem 4.1), and `L = lcm(r_a, r_b)`. We prove `r ∣ L` and `L ∣ r`, then conclude by
antisymmetry of divisibility on positive integers.

**(`L ∣ r`).** Since `a ∣ lcm(a,b)` and `lcm(a,b) ∣ u(r)` (Lemma 3.2(ii)), we have `a ∣ u(r)`;
the spine for `a` gives `r_a ∣ r`. Symmetrically `r_b ∣ r`. Hence `L = lcm(r_a, r_b) ∣ r`.

**(`r ∣ L`).** Since `r_a ∣ L`, the spine for `a` gives `a ∣ u(L)`; likewise `b ∣ u(L)`. Thus
`lcm(a,b) ∣ u(L)`, and the spine for `lcm(a,b)` gives `r ∣ L`.

Both `r` and `L` are positive, so `r = L`. ∎

Conceptually: `r` and `L` cut out the *same* principal ideal of indices `{n : lcm(a,b) ∣ u(n)}`
(via the spine, this ideal equals `{n : r ∣ n} = {n : L ∣ n}`), and a principal ideal of `ℕ`
determines its generator. Theorem 4.2 upgrades the monotone order morphism (Theorem 3.4) to a
genuine semilattice homomorphism.

### 4.3 The coprime entry-point corollary

**Corollary 4.3 (Coprime multiplicative law).** If `u` is an SDS, `a` and `b` are coprime, and
both have ranks, then
> `rank(u, a · b) = lcm(rank(u, a), rank(u, b))`.

*Proof.* For coprime `a, b`, `lcm(a, b) = a · b`. Apply Theorem 4.2. ∎

---

## 5. Concrete instances

### 5.1 Fibonacci

The Fibonacci sequence `F` is an SDS (`gcd(F(m), F(n)) = F(gcd(m,n))`) and is total (every
`m ≥ 1` has a rank, §3). Theorem 4.2 specializes to:

**Theorem 5.1 (Fibonacci entry point of an lcm).** For `a, b ≥ 1`,
> `rank(F, lcm(a, b)) = lcm(rank(F, a), rank(F, b))`.

This is the classical statement that the Fibonacci entry point of a least common multiple is the
least common multiple of the entry points. Worked example: `rank(F, 2) = 3` (first Fibonacci
multiple of 2 is `F(3) = 2`), `rank(F, 3) = 4` (`F(4) = 3`), so `rank(F, 6) = lcm(3, 4) = 12`,
matching `F(12) = 144 = 6 · 24` as the first multiple of 6.

### 5.2 Mersenne-type sequences

For `a ≥ 2`, `u(n) = a^n − 1` is an SDS (`gcd(a^m − 1, a^n − 1) = a^{gcd(m,n)} − 1`), with
`rank(u, a^k − 1) = k` for `k ≥ 1` by rigidity (Theorem 3.5; the sequence is positive and
strictly increasing on positive indices). Theorem 4.2 then gives:

**Theorem 5.2 (Mersenne entry point of an lcm).** For `a ≥ 2` and `m, n ≥ 1`,
> `rank(u, lcm(a^m − 1, a^n − 1)) = lcm(m, n)`.

*Proof.* By Theorem 4.2,
`rank(u, lcm(a^m−1, a^n−1)) = lcm(rank(u, a^m−1), rank(u, a^n−1)) = lcm(m, n)`. ∎

The *same* abstract identity governs Fibonacci entry points and the exponents of Mersenne-type
numbers. The two sequences share no surface structure; they are simply two objects in the
category of strong divisibility sequences, and `rank` preserves joins in both.

---

## 6. The meet law fails — a structural asymmetry

It is tempting to expect a dual `rank(gcd(a, b)) = gcd(rank(a), rank(b))`. This is false. What
*does* hold is one-sided:

**Proposition 6.1 (One-sided meet divisibility).** For an SDS `u` with totality, if `a`, `b`
have ranks then
> `rank(u, gcd(a, b)) ∣ gcd(rank(u, a), rank(u, b))`.

*Proof.* `gcd(a,b) ∣ a` and `gcd(a,b) ∣ b`, so by monotonicity (Theorem 3.4),
`rank(gcd(a,b)) ∣ rank(a)` and `rank(gcd(a,b)) ∣ rank(b)`; thus
`rank(gcd(a,b)) ∣ gcd(rank(a), rank(b))`. ∎

The reverse divisibility `gcd(rank a, rank b) ∣ rank(gcd a b)` is *false*: for Fibonacci with
`a = 4`, `b = 6` we have `rank(4) = 6`, `rank(6) = 12`, so `gcd(rank 4, rank 6) = 6`, whereas
`rank(gcd(4,6)) = rank(2) = 3`, and `6 ∤ 3`. Hence the meet identity fails (and not even the
reverse one-sided law holds).

**Why equality fails.** The map `rank` preserves joins (Theorem 4.2) but is only monotone for
meets. A monotone map between lattices that preserves all joins is a *lower adjoint* (in the
sense of Galois connections); lower adjoints preserve joins by general principle but are free to
distort meets. The Fibonacci sequence provides explicit counterexamples: comparing the ranks of
two moduli against the rank of their gcd shows the meet identity can fail (a finite, decidable
check). The failure is therefore intrinsic: `rank` is a join-semilattice homomorphism, not a
lattice isomorphism.

---

## 7. Application: primitive prime divisors

The spine also delivers Carmichael's prime case cleanly. Call `q` a primitive divisor of `F(n)`
if `q ∣ F(n)` but `q ∤ F(k)` for `0 < k < n` (Definition 2.4).

**Theorem 7.1.** For every prime `p ≥ 3`, `F(p)` has a primitive prime divisor.

*Proof sketch.* `F(p) > 1`, so it has a prime divisor `q`. By the spine `rank(q) ∣ p`. Since
`q ∤ F(1) = 1`, `rank(q) ≠ 1`, and as `p` is prime, `rank(q) = p`. Minimality of the rank
(Lemma 3.2(iii)) then says `q ∤ F(k)` for all `0 < k < p`, i.e. `q` is primitive. ∎

This removes the customary `p ≥ 5` restriction (`p = 3` gives the primitive divisor `2` of
`F(3) = 2`). It is a one-paragraph consequence of the join engine's spine, illustrating how the
structural viewpoint subsumes scattered classical results.

---

## 8. Algorithms

**Algorithm A (Rank of apparition).** Given an SDS oracle `u` and a modulus `m ≥ 1` known to
have a rank, scan `k = 1, 2, 3, ...` and return the first `k` with `m ∣ u(k)`. Correctness is
Definition 2.3; termination is totality (e.g. the Pisano bound for Fibonacci guarantees a
witness `k ≤` the Pisano period, hence `k ≤ 6m`). Complexity: `O(rank(m))` sequence evaluations.

**Algorithm B (Join law as a fast rank composition).** To compute `rank(lcm(a, b))` it is
unnecessary to scan for `lcm(a,b)` directly; by Theorem 4.2 compute `rank(a)`, `rank(b)`, and
return `lcm(rank(a), rank(b))`. Because `rank(a), rank(b) ≤ rank(lcm(a,b))` and the lcm modulus
is larger (hence slower to scan), this is a genuine speedup and a verification cross-check.

**Algorithm C (Meet-defect detector).** To witness failure of the meet law, scan pairs `(a,b)`
and compare `rank(gcd(a,b))` with `gcd(rank(a), rank(b))`; report any mismatch. This is a finite
decidable search and produces explicit counterexamples.

---

## 9. Discussion

The results crystallize the modulus-side structure of the rank of apparition. Where prior work
established `rank` as an *order morphism* of the divisibility poset, we show it is a
*join-semilattice homomorphism* — the strongest statement compatible with the genuine failure of
the meet law. The proof is uniform: it uses only the spine (Theorem 3.3) and elementary lattice
facts, so it applies to *every* strong divisibility sequence simultaneously. The two headline
specializations (Fibonacci, Mersenne-type) are then not separate theorems but two evaluations of
one functorial identity.

The conceptual slogan is: **strong divisibility is the abstract Pisano/order mechanism, and the
rank functor preserves joins.** The asymmetry between joins (exact) and meets (one-sided)
records exactly how much arithmetic of moduli survives passage to ranks.

---

## 10. Future work

- **Quantify the meet defect.** Prove the sharp one-sided law
  `rank(gcd a b) ∣ gcd(rank a, rank b)` for all total SDS, and classify when equality holds vs.
  fails (Fibonacci already supplies finite counterexamples, e.g. `a=4, b=6`).
- **Bundle the morphism.** Package `rank` as a Mathlib `LatticeHom`/`MonoidHom`-style bundled
  morphism on `(ℕ_{>0}, lcm)`, exposing the semilattice structure to downstream automation.
- **Beyond strong divisibility.** Investigate which weaker hypotheses (e.g. mere divisibility
  sequences) still yield a join law, and whether a Galois-connection partner to `rank` can be
  identified explicitly.
- **Other SDS.** Apply the join law to Lucas sequences `U_n(P,Q)`, elliptic divisibility
  sequences, and `q`-analogues, harvesting new entry-point-of-lcm identities uniformly.
