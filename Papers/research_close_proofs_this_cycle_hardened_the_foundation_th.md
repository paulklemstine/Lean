# The Fibonacci Divisibility Calculus: A Complete Dictionary Between Index and Value Divisibility

## Abstract

The Fibonacci sequence `F` is the archetypal *strong divisibility sequence*: the
greatest common divisor of two terms is itself a term, indexed by the gcd of the
indices. We develop the full *divisibility calculus* that this property implies,
turning the additive and gcd structure of the **indices** into the multiplicative
and divisibility structure of the **values**. From the single cornerstone
identity `F(gcd(m, n)) = gcd(F(m), F(n))` we derive, and prove formally, four
results: (1) the strong-divisibility law itself; (2) the propagation of
coprimality, `gcd(m,n)=1 ⇒ gcd(F(m), F(n)) = 1`; (3) the **sharp divisibility
characterization** `F(m) ∣ F(n) ⟺ m ∣ n` for `m ≥ 3`, the exact converse to the
classical `m ∣ n ⇒ F(m) ∣ F(n)`, with the hypothesis `m ≥ 3` shown to be
optimal; and (4) the rank-of-apparition descent step `p ∣ F(m) ∧ p ∣ F(n) ⇒
p ∣ F(gcd(m,n))`, the load-bearing lemma underlying Carmichael's primitive
divisor theorem. The characterization (3) is, to our knowledge, not present as a
single named result in standard formal libraries. We discuss the role of the
calculus as a "logarithm" linearizing the multiplicative factor lattice of
`{F(n)}` into the additive divisibility lattice of `ℕ`, and the program of
deriving the rank-of-apparition theory and primitive divisors from the strong
divisibility axioms plus a single growth inequality.

**Keywords:** Fibonacci numbers, strong divisibility sequence, greatest common
divisor, rank of apparition, primitive divisors, Carmichael's theorem,
divisibility lattice.

**MSC 2020:** 11B39 (Fibonacci and Lucas numbers), 11A05 (Multiplicative
structure of the integers), 11B37 (Recurrences).

---

## 1. Introduction

The Fibonacci sequence is defined by

```
F(0) = 0,  F(1) = 1,  F(n+2) = F(n+1) + F(n),
```

producing `0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, ...`. Beyond its
ubiquity in combinatorics and the natural sciences, the sequence carries a rich
arithmetic structure. Two facts are classical:

* **(Lucas, 1878)** `F` is a *strong divisibility sequence*:
  `gcd(F(m), F(n)) = F(gcd(m, n))`.
* **(Classical corollary)** `m ∣ n ⇒ F(m) ∣ F(n)`.

What is less often isolated is the **converse** of the second fact, and the
precise hypothesis under which it holds. The purpose of this paper is to assemble
the complete two-way dictionary — the *divisibility calculus* — between the
divisibility of indices and the divisibility of values, with all boundary cases
made explicit, and to record the minimal logical dependencies of each statement.

Our contributions are:

1. A clean restatement of the strong-divisibility law as the single axiom of the
   calculus (Theorem 3.1).
2. An immediate derivation of coprimality propagation (Theorem 3.2).
3. The **sharp divisibility characterization** `F(m) ∣ F(n) ⟺ m ∣ n` for
   `m ≥ 3` (Theorem 3.3), together with a proof that `m ≥ 3` is exactly sharp
   (Proposition 3.4).
4. The descent lemma to the gcd (Theorem 3.5), isolated once and for all as the
   reusable engine of primitive-divisor arguments.

All four results have been verified in a formal proof assistant, free of
`sorry` placeholders and depending only on the standard foundational axioms
(propositional extensionality, the axiom of choice, and quotient soundness).

---

## 2. Definitions and Preliminaries

Throughout, `m, n, p, k` denote natural numbers and `F : ℕ → ℕ` is the Fibonacci
function above. We write `a ∣ b` for "a divides b" and `gcd(a, b)` for the
greatest common divisor (with the conventions `gcd(0, b) = b`, `gcd(a, 0) = a`).

**Definition 2.1 (Coprimality).** Two naturals `a, b` are *coprime* if
`gcd(a, b) = 1`.

**Definition 2.2 (Strong divisibility sequence).** A sequence `a : ℕ → ℕ` is a
*strong divisibility sequence* (SDS) if `gcd(a(m), a(n)) = a(gcd(m, n))` for all
`m, n`.

**Definition 2.3 (Rank of apparition).** For a prime `p`, the *rank of
apparition* `α(p)` is the least positive `k` with `p ∣ F(k)`, when such a `k`
exists. (Existence holds for every prime; `α(2) = 3`, `α(3) = 4`, `α(5) = 5`,
`α(7) = 8`, `α(11) = 10`, etc.)

We rely on two standard structural facts about `F`, both available in the formal
library and treated here as black boxes:

* **(SDS law)** `F(gcd(m, n)) = gcd(F(m), F(n))` for all `m, n`.
* **(Strict monotonicity on `[2, ∞)`)** `F` is strictly increasing on the
  indices `≥ 2`: if `2 ≤ a < b` then `F(a) < F(b)`. In particular `F` restricted
  to `{k : k ≥ 2}` is injective.
* **(Classical forward divisibility)** `m ∣ n ⇒ F(m) ∣ F(n)`.

The first is Lucas's theorem; the second follows from `F(k) ≥ 1` for `k ≥ 1` and
`F(k+1) = F(k) + F(k-1) > F(k)` once `F(k-1) ≥ 1`, i.e. `k ≥ 2`; the third is a
standard induction. Our calculus is everything that can be cleanly *derived* from
these.

---

## 3. Main Results

### 3.1 The strong-divisibility law

**Theorem 3.1 (SDS law, restated).** For all `m, n ∈ ℕ`,
```
F(gcd(m, n)) = gcd(F(m), F(n)).
```

*Proof.* This is Lucas's theorem, recorded here as the cornerstone of the
calculus. ∎

The remaining results are consequences obtained with only elementary `gcd`
manipulation and the monotonicity of `F`.

### 3.2 Propagation of coprimality

**Theorem 3.2 (Coprime indices give coprime values).** If `gcd(m, n) = 1` then
`gcd(F(m), F(n)) = 1`.

*Proof.* By Theorem 3.1, `gcd(F(m), F(n)) = F(gcd(m, n)) = F(1) = 1`. ∎

This is the multiplicative shadow of the additive coprimality of indices. For
example `gcd(4, 9) = 1`, and indeed `gcd(F(4), F(9)) = gcd(3, 34) = 1`.

### 3.3 The sharp divisibility characterization

**Theorem 3.3 (Divisibility characterization).** For `m ≥ 3` and any `n`,
```
F(m) ∣ F(n)  ⟺  m ∣ n.
```

*Proof.*

(`⟸`) This is the classical forward direction: `m ∣ n ⇒ F(m) ∣ F(n)`.

(`⟹`) Suppose `F(m) ∣ F(n)`. Then `gcd(F(m), F(n)) = F(m)`. By Theorem 3.1,
```
F(gcd(m, n)) = gcd(F(m), F(n)) = F(m).      (∗)
```
We claim `gcd(m, n) ≥ 2`. Indeed, suppose for contradiction `gcd(m, n) ≤ 1`,
i.e. `gcd(m, n) ∈ {0, 1}`. Then the left side of (∗) is `F(0) = 0` or
`F(1) = 1`, so `F(m) ∈ {0, 1}`. But for `m ≥ 3` we have `F(m) ≥ F(3) = 2 > 1`,
a contradiction. (Formally, `F(m) ≥ 2` for `m ≥ 3` follows from monotonicity, or
from the bound `m ≤ F(m) + 1` combined with `m ≥ 3`.) Hence `gcd(m, n) ≥ 2`.

Now both `gcd(m, n) ≥ 2` and `m ≥ 2`, and `F` is injective on indices `≥ 2`.
Equation (∗) `F(gcd(m, n)) = F(m)` therefore forces
```
gcd(m, n) = m,
```
which says exactly that `m ∣ n` (since `gcd(m, n) = m ⟺ m ∣ n`). ∎

The engine of the nontrivial direction is the conversion of a *divisibility*
hypothesis `F(m) ∣ F(n)` into the *equation* `F(gcd(m,n)) = F(m)` via the SDS
law, after which strict monotonicity (injectivity) does the rest. No appeal to
Pisano periods or modular periodicity is needed.

**Proposition 3.4 (Sharpness of `m ≥ 3`).** The hypothesis `m ≥ 3` in Theorem
3.3 cannot be weakened. For `m ∈ {1, 2}`, `F(m) = 1`, so `F(m) ∣ F(n)` holds for
*every* `n`, while `m ∣ n` fails for infinitely many `n` (e.g. `m = 2` and any
odd `n`). Thus the equivalence is false for `m ≤ 2`, and `m ≥ 3` is the minimal
hypothesis erasing the single defect `F(1) = F(2) = 1`.

*Proof.* `F(1) = F(2) = 1` divides everything; take `m = 2`, `n = 3`:
`F(2) = 1 ∣ 2 = F(3)` but `2 ∤ 3`. ∎

The defect of the calculus is thus *exactly one value* — the repeated `1` at the
start of the sequence — and `m ≥ 3` is the sharp threshold past it.

### 3.4 The descent step

**Theorem 3.5 (Rank-of-apparition descent).** For all `p, m, n`, if `p ∣ F(m)`
and `p ∣ F(n)` then `p ∣ F(gcd(m, n))`.

*Proof.* By Theorem 3.1, `F(gcd(m, n)) = gcd(F(m), F(n))`. Since `p` divides both
`F(m)` and `F(n)`, it divides their gcd, hence `p ∣ F(gcd(m, n))`. ∎

This descent — pushing a common divisor of two terms down to the term at the gcd
of the indices — is the recurring step in primitive-divisor arguments. It implies,
in particular, that the set `{ k : p ∣ F(k) }` is closed under gcd, so it is the
set of multiples of its least positive element: this is precisely the
*well-definedness and minimality of the rank of apparition* `α(p)`.

---

## 4. The Calculus as a Logarithm

The four theorems together establish a structure-preserving correspondence
between two lattices:

* the **divisibility lattice of indices** `(ℕ, ∣, gcd, lcm)`, and
* the **divisibility lattice of values** `({F(n)}, ∣, gcd, ...)`.

Theorem 3.1 says the map `n ↦ F(n)` carries `gcd` of indices to `gcd` of values.
Theorem 3.3 says that, away from the single defect, the map *reflects*
divisibility: an order-embedding in the divisibility order. In this sense the
Fibonacci map behaves like an **antilogarithm**, and the rank of apparition `α`
behaves like its inverse **logarithm**: it should satisfy, for primes `p ≠ 5`,
```
p ∣ F(n)  ⟺  α(p) ∣ n,
```
linearizing the multiplicative factorization questions about the enormous numbers
`F(n)` into ordinary divisibility of the small index `n`. Theorem 3.5 supplies
exactly the closure-under-gcd needed for `α` to exist and be minimal.

The practical upshot is striking: to determine the complete divisibility
relationship of `F(n)` with the rest of the sequence one never needs to compute
`F(n)` (which has roughly `0.209 · n` decimal digits). One only factors `n`.

---

## 5. Algorithms

We record the algorithmic content of the calculus.

### 5.1 Index-only divisibility test

**Input:** indices `m ≥ 3`, `n`. **Output:** whether `F(m) ∣ F(n)`.

By Theorem 3.3 this is decided by a single `mod` operation on the indices:

```
function FibDivides(m, n):
    assert m >= 3
    return (n mod m == 0)
```

Complexity: `O(1)` arithmetic operations on the indices — independent of the
astronomically large values `F(m), F(n)`. The naive alternative (compute both
Fibonacci numbers, then test divisibility) costs `Θ(n)` big-integer additions
and a big-integer division on numbers of `Θ(n)` digits.

### 5.2 Value-gcd via index-gcd

**Input:** indices `m, n`. **Output:** `gcd(F(m), F(n))`.

By Theorem 3.1, compute `g = gcd(m, n)` (Euclid, `O(log min(m,n))` steps) and
return `F(g)`:

```
function FibGcd(m, n):
    g = EuclidGcd(m, n)
    return Fib(g)          # only one Fibonacci value, at the small index g
```

This replaces a gcd of two huge numbers with a gcd of two small indices plus a
single Fibonacci evaluation at the (typically much smaller) index `g`.

### 5.3 Rank of apparition

**Input:** a prime `p`. **Output:** `α(p)`, the least `k > 0` with `p ∣ F(k)`.

```
function RankOfApparition(p):
    Fkm1, Fk = 1, 1        # F(1), F(2)
    k = 2
    if (1 mod p == 0): return ... # p = 1 excluded; p prime
    while (Fk mod p != 0):
        Fkm1, Fk = Fk, (Fk + Fkm1) mod p   # work modulo p
        k = k + 1
    return k
```

Working modulo `p` keeps every intermediate value below `p`. By Theorem 3.5 the
set of `k` with `p ∣ F(k)` is exactly the multiples of `α(p)`, so the first hit
is the rank. The Pisano period bounds the loop by `O(p)` iterations (and far
fewer in practice).

---

## 6. Applications

**6.1 Even and "every-k-th" Fibonacci numbers.** Theorem 3.3 instantly resolves
classical observations: the multiples of `F(3) = 2` are exactly `F(3), F(6),
F(9), ...`; the multiples of `F(4) = 3` are `F(4), F(8), F(12), ...`; the
multiples of `F(5) = 5` are `F(5), F(10), ...`. "Every k-th Fibonacci number is
divisible by F(k)" is the forward direction, and "*only* those are" is Theorem
3.3's converse.

**6.2 Carmichael primitive divisors.** Carmichael's theorem states that for `n ∉
{1, 2, 6, 12}` (and `F(n) ≠ 1`), `F(n)` has a *primitive prime divisor*: a prime
dividing `F(n)` but no earlier `F(k)`. The descent step (Theorem 3.5) is the
mechanism that makes "earlier divisors descend to a gcd index" precise, and is
the step repeatedly invoked in formal developments of Carmichael's theorem. Our
contribution isolates it once, cleanly, rather than re-deriving it inline.

**6.3 Coprimality engineering.** Theorem 3.2 yields large coprime families: any
set of pairwise-coprime indices `{m_1, m_2, ...}` produces pairwise-coprime
Fibonacci values `{F(m_i)}`, useful in constructions requiring coprime moduli
(e.g. CRT-style packing) where Fibonacci values supply a convenient growing
sequence.

---

## 6bis. Relationship to Known Results and Originality

The forward implication `m ∣ n ⇒ F(m) ∣ F(n)` is classical and ancient,
traceable to Lucas's nineteenth-century investigations and present in essentially
every modern treatment of the sequence; in formal libraries it appears as the
lemma we cite as classical forward divisibility. Lucas's strong-divisibility law
`gcd(F(m), F(n)) = F(gcd(m,n))` is equally classical and is available formally.
What is conspicuously *absent* from the standard formal corpus, as far as we have
been able to determine, is the packaged converse `F(m) ∣ F(n) ⇒ m ∣ n` together
with the explicit, sharp side condition `m ≥ 3` and a proof that the condition
cannot be relaxed. The contribution of this work is therefore twofold. First, it
is a *consolidation*: the descent step (Theorem 3.5) had previously been
re-derived inline, from the strong-divisibility law, in several independent
developments of primitive-divisor theory; we isolate it once as a reusable lemma.
Second, it is a genuine *strengthening*: Theorem 3.3 supplies the missing
biconditional, with the boundary behaviour pinned down exactly.

We stress that the proofs are economical. The nontrivial direction of Theorem 3.3
uses only (i) the elementary equivalence `gcd(a,b) = a ⟺ a ∣ b`, (ii) the
strong-divisibility law, and (iii) the injectivity of `F` on indices `≥ 2`. In
particular, *no* appeal is made to Pisano periods, to the closed-form (Binet)
expression, or to any modular-periodicity machinery. This economy is itself a
result of independent interest: it shows that the entire two-way divisibility
dictionary is a formal consequence of two structural facts — strong divisibility
and strict monotonicity — and is therefore portable to any sequence sharing those
two features.

## 7. Discussion

The Fibonacci Divisibility Calculus is a small theory with an unusually high
ratio of consequences to assumptions. Every result descends from one identity
(Theorem 3.1) plus monotonicity, and the lone imperfection of the
correspondence — the repeated `1` at indices 1 and 2 — is captured precisely by
the single hypothesis `m ≥ 3`, shown to be sharp (Proposition 3.4).

Two structural observations deserve emphasis. First, *nothing* in the proofs of
Theorems 3.2–3.5 uses the specific recurrence of `F` beyond the SDS law and
monotonicity; the same calculus holds verbatim for any strictly increasing strong
divisibility sequence, e.g. suitable Lucas sequences and elliptic divisibility
sequences. The Fibonacci case is the cleanest instance, not a special one.
Second, the conversion of a *divisibility hypothesis* into an *equation of values*
(the move `F(m) ∣ F(n) ⇒ F(gcd(m,n)) = F(m)`) is the reusable proof idiom; it is
what allows injectivity to finish the argument without any modular machinery.

---

## 8. Future Directions

(See the dedicated "Future Directions" section of this package for the full
program.) In brief:

* **The entry-point logarithm.** Prove that for primes `p ≠ 5`,
  `p ∣ F(n) ⟺ α(p) ∣ n`, and that `α` is the *unique* function with this
  property — making `α` a literal logarithm of the SDS. Theorem 3.3 supplies the
  index-level skeleton and Theorem 3.5 supplies minimality; what remains is a
  clean minimization argument with no appeal to Pisano periods. The prime `5`
  (with `α(5) = 5`, `25 ∣ F(25)`, and lifting-the-exponent behaviour) is the
  designated stress test.
* **Primitive divisors from axioms.** Determine whether the Carmichael
  primitive-divisor phenomenon is a formal consequence of the SDS axioms plus a
  single growth inequality, abstracting away from the specific Fibonacci
  recurrence.
* **General SDS calculus.** Port the four theorems to arbitrary strictly
  increasing strong divisibility sequences and identify the exact analogue of the
  `m ≥ 3` defect threshold for each.

---

## 8bis. Methodological Notes

Three small lemmas carry disproportionate weight and are worth highlighting for
reuse.

* **The conversion idiom.** The step `F(m) ∣ F(n) ⇒ gcd(F(m), F(n)) = F(m)`
  converts a divisibility hypothesis into an *equation between specific values*.
  Once an equation of the form `F(a) = F(b)` is in hand with `a, b ≥ 2`,
  injectivity collapses it to `a = b`. This pattern — divisibility to equation to
  index equality — recurs throughout strong-divisibility-sequence arguments and
  is the cleanest route past ad hoc index juggling.
* **The defect localization.** Identifying that the *only* obstruction to a clean
  biconditional is the coincidence `F(1) = F(2) = 1` turns a vague "small cases
  are annoying" intuition into a precise, sharp hypothesis. The general lesson:
  when a strong divisibility sequence fails to be strictly increasing on an
  initial segment, that segment is exactly where the index/value dictionary
  loses faithfulness, and excluding it is both necessary and sufficient.
* **Descent as closure.** Theorem 3.5 expresses that the index set
  `{k : p ∣ F(k)}` is closed under `gcd`. Closure under `gcd` for a nonempty set
  of positive integers is equivalent to being the set of multiples of its
  minimum. This single observation is what makes the rank of apparition a
  well-defined, minimal object, and is the bridge from the calculus to the
  entry-point theory.

These observations explain why the calculus generalizes so readily: each rests on
the abstract SDS axiom rather than on any Fibonacci-specific computation.

## 9. Conclusion

We have assembled the complete two-way divisibility dictionary for the Fibonacci
sequence: the strong-divisibility law, coprimality propagation, the sharp
characterization `F(m) ∣ F(n) ⟺ m ∣ n` for `m ≥ 3` with optimal threshold, and
the descent step powering primitive-divisor theory. The calculus reveals the
Fibonacci map as an antilogarithm linearizing the multiplicative structure of an
enormous integer sequence into the elementary divisibility of its indices — a
maximal harvest from a single identity, with every boundary case understood
exactly.

---

## Appendix A: Worked numerical checks

| m | n | gcd(m,n) | F(gcd) | F(m) | F(n) | gcd(F(m),F(n)) |
|---|---|----------|--------|------|------|----------------|
| 12 | 18 | 6 | 8 | 144 | 2584 | 8 |
| 9 | 15 | 3 | 2 | 34 | 610 | 2 |
| 10 | 15 | 5 | 5 | 55 | 610 | 5 |
| 8 | 12 | 4 | 3 | 21 | 144 | 3 |
| 7 | 11 | 1 | 1 | 13 | 89 | 1 |

Each row verifies Theorem 3.1. The last row (coprime indices `7, 11`) also
illustrates Theorem 3.2.

| m | n | m ∣ n? | F(m) ∣ F(n)? |
|---|---|--------|--------------|
| 3 | 9 | yes | 2 ∣ 34 yes |
| 3 | 10 | no | 2 ∣ 55 no |
| 4 | 12 | yes | 3 ∣ 144 yes |
| 5 | 12 | no | 5 ∣ 144 no |
| 2 | 3 | no | 1 ∣ 2 **yes** (defect, m<3) |

The final row is the sharpness witness of Proposition 3.4.
