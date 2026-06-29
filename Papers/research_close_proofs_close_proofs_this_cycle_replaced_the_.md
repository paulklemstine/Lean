# The Fibonacci Divisibility Lattice: A First-Principles Theory of Strong Divisibility and the Rank of Apparition

## Abstract

The Fibonacci sequence `F(0)=0, F(1)=1, F(n+2)=F(n+1)+F(n)` is the archetypal
*strong divisibility sequence*: it transports the divisibility lattice of the
natural numbers faithfully into the divisibility lattice of its own values. The
forward direction — that `m ∣ n` implies `F(m) ∣ F(n)` — is classical and widely
available. In this work we give a clean, self-contained development of the
*converse* and its consequences, organized entirely around a single structural
identity, the **gcd homomorphism**

  gcd( F(m), F(n) ) = F( gcd(m, n) ).

Treating this identity as the unique structural input, we prove: (1) injectivity
of `F` on indices `≥ 2`; (2) the exact characterization of when a Fibonacci value
equals 1; (3) the **converse divisibility law** `F(m) ∣ F(n) ⇔ m ∣ n` for `m ≥ 3`,
with sharp boundary; (4) a **coprimality criterion** `gcd(F(m),F(n))=1 ⇔ gcd(m,n)
∈ {1,2}`, free of positivity hypotheses; (5) existence of the **rank of apparition
(entry point)** for every positive modulus, via a pigeonhole-plus-reversibility
argument; and (6) the **apparition law** `m ∣ F(n) ⇔ entry(m) ∣ n`, exhibiting the
entry point as the generator of the complete apparition set. We conclude with the
role of these structures as the algebraic backbone of Lucas-sequence primality
testing, and with conjectures on the multiplicativity of the entry point and the
Wall–Sun–Sun problem.

**Keywords.** Fibonacci numbers, strong divisibility sequence, greatest common
divisor, lattice homomorphism, rank of apparition, entry point, Lucas sequences,
primality testing.

---

## 1. Introduction

Let `F : ℕ → ℕ` denote the Fibonacci sequence, normalized by `F(0) = 0`,
`F(1) = 1`, and the recurrence `F(n+2) = F(n+1) + F(n)`. So the values are

```
F(0)=0, F(1)=1, F(2)=1, F(3)=2, F(4)=3, F(5)=5, F(6)=8, F(7)=13, F(8)=21, ...
```

A sequence `a : ℕ → ℕ` is a **divisibility sequence** if `m ∣ n ⇒ a(m) ∣ a(n)`,
and a **strong divisibility sequence** if moreover `gcd(a(m), a(n)) = a(gcd(m,n))`.
The Fibonacci sequence is the prototype of the latter. The strong property is
strictly more informative than the weak one: it pins down not just that certain
divisibilities hold, but the *exact* greatest common divisor of any two terms.

The aim of this paper is to demonstrate how much of the divisibility architecture
of `F` flows from the single identity

> **(GCD-Hom)**  `gcd( F(m), F(n) ) = F( gcd(m, n) )`,

when combined with one elementary monotonicity fact (strict monotonicity of `F`
above index 1). In particular we recover the *converse* of the divisibility
implication, which is genuinely harder than the forward direction and is the
content most often omitted from textbook treatments. We then build the
rank-of-apparition theory, which is the structural skeleton beneath Lucas-sequence
primality testing — placing the development squarely in the domain of
computational number theory and cryptography.

All results below are fully formalized and machine-checked; the proof sketches
given here mirror the formal arguments faithfully while remaining readable.

### 1.1 Standing notation

Throughout, `m, n, k` denote natural numbers and `∣` denotes divisibility on `ℕ`.
We write `gcd` for the greatest common divisor and `lcm` for the least common
multiple. Two numbers are **coprime** when their gcd equals 1. We take as given
the two classical facts:

- **(FWD)** `m ∣ n ⇒ F(m) ∣ F(n)`  (forward divisibility);
- **(MONO)** `F` is strictly monotone on `{k : k ≥ 2}`, i.e. `2 ≤ i < j ⇒
  F(i) < F(j)`.

Both are standard. Our contribution is everything that (GCD-Hom) and (MONO)
together imply.

---

## 2. Injectivity and the unit indices

The first task is to understand *where* `F` can repeat a value. Because `F(1) =
F(2) = 1`, the sequence is not injective on all of `ℕ`. But this is its only
defect.

### Lemma 2.1 (Injectivity above index 1).
*For `m, n ≥ 2`,* `F(m) = F(n) ⇔ m = n`.

**Proof sketch.** The direction `m = n ⇒ F(m) = F(n)` is trivial. Conversely, a
strictly monotone function is injective on its domain of monotonicity. By (MONO),
`F` is strictly monotone on `{k ≥ 2}`, hence injective there; so `F(m) = F(n)` with
`m, n ≥ 2` forces `m = n`. ∎

This single lemma is the linchpin that converts the *value* equation produced by
(GCD-Hom) into an *index* equation.

### Lemma 2.2 (Characterization of the value 1).
`F(k) = 1 ⇔ k = 1 ∨ k = 2`.

**Proof sketch.** For `k ∈ {1, 2}` we have `F(k) = 1` directly. For `k = 0`,
`F(0) = 0 ≠ 1`. For `k ≥ 3`, strict monotonicity from index 2 gives
`F(k) > F(2) = 1`, equivalently `F(k) ≥ 2` (formally, `F(k) ≥ F(3) = 2` by
monotonicity, using positivity `F(k) > 0` for `k ≥ 1`). Hence the value 1 is
attained at precisely the two unit indices. ∎

Lemma 2.2 isolates the *only* coincidence in the sequence, and every boundary
hypothesis appearing later traces back to it.

---

## 3. The converse divisibility law

We now prove the principal structural theorem.

### Theorem 3.1 (Converse divisibility law).
*For every `m ≥ 3` and every `n`,*

  `F(m) ∣ F(n)  ⇔  m ∣ n`.

**Proof sketch.**

*(⇐)* This is exactly (FWD): if `m ∣ n` then `F(m) ∣ F(n)`.

*(⇒)* Suppose `F(m) ∣ F(n)`. Then `gcd(F(m), F(n)) = F(m)`. By (GCD-Hom),
`gcd(F(m), F(n)) = F(gcd(m, n))`, so

```
F( gcd(m, n) ) = F(m).                                    (∗)
```

We claim `gcd(m, n) ≥ 2`. Indeed, if `gcd(m, n) ≤ 1` then `F(gcd(m,n)) ≤ F(1) = 1`
(checking the values `F(0)=0, F(1)=1`), whereas `F(m) ≥ F(3) = 2` because `m ≥ 3`
and `F` is increasing from index 2. This contradicts (∗). Hence `gcd(m, n) ≥ 2`.

Now both `gcd(m, n)` and `m` are `≥ 2`, so Lemma 2.1 applies to (∗) and yields
`gcd(m, n) = m`. Finally, `gcd(m, n) = m` is equivalent to `m ∣ n`. ∎

### Remark 3.2 (Sharpness of `m ≥ 3`).
The hypothesis is best possible. For `m ∈ {1, 2}` we have `F(m) = 1`, which divides
every `F(n)`, while `m` does not divide every `n`. Thus the law *fails* exactly at
`m ≤ 2`, and the failure is caused precisely by the coincidence isolated in Lemma
2.2. The boundary is therefore not an artifact of the proof but a feature of the
sequence.

### Corollary 3.3 (Faithfulness of the homomorphism).
*The map `F` restricted to `{k ≥ 2}` is an order-embedding of the divisibility
lattice: for `m, n ≥ 3` (and more generally whenever the gcd indices exceed 1),
divisibility, gcd, and lcm questions among the `F`-values are equivalent to the
corresponding questions among the indices.*

This is the precise sense in which (GCD-Hom) makes `F` a *faithful* lattice
homomorphism `(ℕ, gcd) → (ℕ, gcd)` once the unit indices are excluded: it is not
merely structure-preserving but structure-*reflecting*.

---

## 4. The coprimality criterion

The same identity settles coprimality with no boundary hypotheses at all.

### Theorem 4.1 (Coprimality criterion).
*For all `m, n`,*

  `gcd(F(m), F(n)) = 1  ⇔  gcd(m, n) = 1 ∨ gcd(m, n) = 2`.

**Proof sketch.** By (GCD-Hom), `gcd(F(m), F(n)) = F(gcd(m, n))`. Hence
`gcd(F(m), F(n)) = 1` if and only if `F(gcd(m, n)) = 1`, which by Lemma 2.2 holds
if and only if `gcd(m, n) ∈ {1, 2}`. ∎

The absence of positivity hypotheses is worth emphasizing: the criterion holds
verbatim even when one of the indices is 0, because `gcd(0, n) = n` and the
characterization of the value 1 already accounts for every case.

### Example 4.2.
- `F(5)=5`, `F(9)=34`: `gcd(5,9)=1`, so coprime. Indeed `gcd(5,34)=1`.
- `F(6)=8`, `F(9)=34`: `gcd(6,9)=3 ∉ {1,2}`, so *not* coprime. Indeed
  `gcd(8,34)=2`.
- `F(4)=3`, `F(6)=8`: `gcd(4,6)=2`, so coprime. Indeed `gcd(3,8)=1`.

---

## 5. The rank of apparition (entry point)

We turn to the apparition theory. The central definition:

### Definition 5.1 (Entry point / rank of apparition).
For `m > 0`, the **entry point** `entry(m)` is the least positive index `k` with
`m ∣ F(k)`, provided such a `k` exists.

That such a `k` always exists is the first theorem of this section and the only
place in the development where we go beyond (GCD-Hom) and monotonicity.

### Theorem 5.2 (Existence of the entry point).
*For every `m > 0` there exists `k > 0` with `m ∣ F(k)`.*

**Proof sketch.** Consider the *state sequence* of consecutive residue pairs

```
s(k) = ( F(k) mod m,  F(k+1) mod m )   ∈  {0,…,m-1} × {0,…,m-1}.
```

The state space has only `m²` elements, a finite set. The map `k ↦ s(k)` therefore
cannot be injective on the infinite domain `ℕ`: by the pigeonhole principle there
exist `i < j` with `s(i) = s(j)`, i.e.

```
F(i)   ≡ F(j)   (mod m)   and   F(i+1) ≡ F(j+1) (mod m).
```

Now observe that the Fibonacci recurrence is *reversible*: from `(F(k), F(k+1))`
one recovers `F(k-1) = F(k+1) − F(k)`. Working modulo `m` and rewinding both
trajectories step by step from `(i, i+1)` and `(j, j+1)` simultaneously preserves
the congruence of states. After `i` steps of rewinding, the first trajectory
reaches the base state `(F(0), F(1)) = (0, 1)`, while the second reaches
`(F(j-i), F(j-i+1))`. Equality of first coordinates gives

```
F(j - i) ≡ F(0) = 0   (mod m),
```

with `j − i > 0`. Hence `k := j − i` is a positive index with `m ∣ F(k)`. ∎

The formal proof realizes the "rewind" cleanly by casting into `ℤ/mℤ` and taking a
linear combination of the two state congruences, which is exactly the algebraic
shadow of running the recurrence backwards.

### Definition 5.3 (formal entry point).
Given Theorem 5.2, define `entry(m)` as the minimum witness (e.g. via well-ordered
search over `ℕ`). It satisfies, by construction:

- `entry(m) > 0`  (positivity), and
- `m ∣ F(entry(m))`  (it is an apparition index),
- and it is the *least* index with these properties (minimality).

---

## 6. The apparition law

The entry point is not merely *one* apparition index; it generates *all* of them.

### Theorem 6.1 (Apparition law).
*For `m > 0` and every `n`,*

  `m ∣ F(n)  ⇔  entry(m) ∣ n`.

**Proof sketch.** Write `k = entry(m)`.

*(⇐)* If `k ∣ n` then `F(k) ∣ F(n)` by (FWD), and `m ∣ F(k)` by definition of the
entry point, so `m ∣ F(n)` by transitivity.

*(⇒)* Suppose `m ∣ F(n)`. Since also `m ∣ F(k)`, we have `m ∣ gcd(F(k), F(n))`. By
(GCD-Hom), `gcd(F(k), F(n)) = F(gcd(k, n))`, so

```
m ∣ F( gcd(k, n) ).
```

Thus `gcd(k, n)` is itself a positive apparition index (it is positive because
`gcd(k, n) ≥ 1` and divides `k > 0`). By minimality of `k = entry(m)`, no positive
apparition index is smaller than `k`; but `gcd(k, n) ≤ k`. Therefore
`gcd(k, n) = k`, which is equivalent to `k ∣ n`. ∎

### Corollary 6.2 (The apparition set is an arithmetic progression of indices).
*The set `{ n : m ∣ F(n) }` equals the set of multiples of `entry(m)`.* In
particular `m` divides `F(0) = 0` trivially (since `entry(m) ∣ 0`), and the first
*positive* appearance is at `entry(m)`, with all subsequent appearances at
`2·entry(m), 3·entry(m), …`.

### Example 6.3.
`entry(7) = 8` since `F(8) = 21 = 3·7` is the first positive Fibonacci multiple of
7. By Theorem 6.1, 7 divides `F(n)` exactly at `n ∈ {0, 8, 16, 24, …}`; for
instance `F(16) = 987 = 7·141`, while 7 divides none of `F(9), …, F(15)`.

---

## 7. Algorithms

The theory is constructive and yields simple, certifiably correct algorithms.

### 7.1 Pisano-style entry-point search

To compute `entry(m)`, iterate the residue recurrence and return the first
positive index with residue 0. Existence (Theorem 5.2) guarantees termination, and
the period is at most `m²` (the size of the state space), so the search halts in
`O(m²)` steps with `O(log m)`-bit arithmetic per step.

```
function ENTRY(m):
    if m == 1: return 1
    a, b <- 0, 1                  # (F(0) mod m, F(1) mod m)
    k <- 0
    repeat:
        k <- k + 1
        a, b <- b, (a + b) mod m  # advance to (F(k) mod m, F(k+1) mod m)
        if a == 0 and k > 0: return k
```

### 7.2 Divisibility and coprimality decision procedures

By Theorems 3.1, 4.1, and 6.1, three expensive questions about (potentially
astronomically large) Fibonacci values reduce to cheap questions about indices:

- `F(m) ∣ F(n)` (for `m ≥ 3`)  ⟺  `m ∣ n`         — a single `mod`.
- `gcd(F(m), F(n)) = 1`        ⟺  `gcd(m, n) ∈ {1,2}` — one Euclid run.
- `m ∣ F(n)`                   ⟺  `entry(m) ∣ n`    — one entry-point search.

The point is that one never needs to *materialize* the huge values `F(m), F(n)` to
answer these questions: the lattice structure pushes the computation down to the
index level.

---

## 8. Applications: the backbone of Lucas-sequence primality testing

The Fibonacci sequence is the first member of a broad family of **Lucas
sequences** `U_n(P, Q)`, all of which are strong divisibility sequences obeying a
gcd homomorphism analogous to (GCD-Hom). The rank of apparition generalizes to
these sequences, and its interaction with the underlying prime structure is the
engine of the **Lucas** and **Lucas–Lehmer** primality tests, and of the Lucas
component of the widely deployed **Baillie–PSW** test.

The conceptual reason these tests are sound is exactly the *faithfulness*
established here: because the sequence reflects the divisibility lattice of the
integers without loss (Corollary 3.3), a congruence condition on the (hard) values
can be translated into an exact statement about the (easy) indices and the rank of
apparition. For a prime `p`, the entry point `entry(p)` divides `p − (5/p)` (a
Legendre-symbol shift), and deviations from the expected entry-point behavior
certify compositeness. The clean index-level laws proved above are the elementary
substrate on which that machinery is built.

---

## 9. Discussion

The development illustrates a recurring theme in structural number theory: a single
*homomorphism identity*, when combined with a *rigidity* fact (here, injectivity
from monotonicity), can be leveraged to reflect an entire algebraic structure. The
gcd identity (GCD-Hom) says `F` preserves meets in the divisibility lattice;
injectivity (Lemma 2.1) upgrades preservation to *reflection*; and the only
obstruction — the repeated value 1 at indices 1 and 2 — is quarantined exactly by
Lemma 2.2, which is why every theorem carries a boundary hypothesis traceable to
that one coincidence.

It is worth stressing what is *not* needed. We never invoke the closed-form
(Binet) expression, generating functions, matrix exponentiation, or any analytic
input. Everything follows from one combinatorial identity and one monotonicity
statement, which is what makes the theory portable to the entire Lucas-sequence
family.

---

## 10. Future directions

### Direction 1 — Multiplicativity of the rank of apparition on coprime moduli.
**Conjecture.** For coprime `a, b > 0`, `entry(a·b) = lcm( entry(a), entry(b) )`.
The apparition law (Theorem 6.1) turns the apparition predicate into a
*divisibility* predicate on indices, and for coprime `a, b` the Chinese Remainder
Theorem for `∣` gives

```
a·b ∣ F(n) ⇔ a ∣ F(n) ∧ b ∣ F(n) ⇔ entry(a) ∣ n ∧ entry(b) ∣ n ⇔ lcm(entry(a),entry(b)) ∣ n.
```

Matching the generators of two equal divisor-closed sets pins the value. Both
ingredients — the apparition law and CRT-for-`∣` — are now in hand, so the proof
is a short composition rather than new theory.

### Direction 2 — Wall's conjecture at the lattice level.
**Conjecture (Wall–Sun–Sun).** For every prime `p`, `entry(p²) = p · entry(p)`,
equivalently `p² ∤ F(entry(p))`. With `entry` now a fully specified,
computable-in-principle function, the statement becomes a precise, falsifiable
predicate on the entry-point map. A lattice-level reformulation may expose new
angles on this notoriously open problem, and at minimum supports certified
large-scale computational search for counterexamples.

### Direction 3 — Generalization to arbitrary Lucas sequences.
Abstract (GCD-Hom), (FWD), and the monotonicity/injectivity package into the
hypotheses of a generic *strong divisibility sequence*, and re-derive the converse
divisibility law, coprimality criterion, and apparition law once and for all,
specializing to Fibonacci, Pell, and Mersenne-type sequences as corollaries.

---

## 11. Conclusion

Starting from the lone identity `gcd(F(m), F(n)) = F(gcd(m, n))`, we have recovered
the full divisibility architecture of the Fibonacci sequence: injectivity above
the unit indices, the converse divisibility law `F(m) ∣ F(n) ⇔ m ∣ n` for `m ≥ 3`
with its sharp boundary, the boundary-free coprimality criterion, the existence of
the rank of apparition for every modulus, and the apparition law `m ∣ F(n) ⇔
entry(m) ∣ n` that makes a single integer govern an infinite divisibility pattern.
These are precisely the elementary structures on which Lucas-sequence primality
testing rests — the reason an object as familiar as the Fibonacci numbers remains a
working tool at the frontier of computational number theory.
