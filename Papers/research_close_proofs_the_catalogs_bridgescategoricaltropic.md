# The Fibonacci Law of Apparition as an Arithmetic-Height / Tropical Duality

## Abstract

We give a self-contained development of the **law of apparition** for the
Fibonacci sequence, valid for *every* modulus `m ≥ 1` (not only primes), and
bridge it to a tropical/ultrametric theory of arithmetic heights. The central
object is the **rank of apparition** `z(m)`, the least positive index `k` with
`m ∣ F(k)`. We prove its existence by an elementary argument that uses nothing
more than the fact that the Fibonacci transition map `T(a,b) = (b, a+b)` is a
*bijection* of the finite set `(ℤ/mℤ)²`: a finite bijection has purely periodic
orbits, so the orbit of the start state `(0,1)` returns to `(0,1)`, producing a
positive index `d` with `m ∣ F(d)`. The headline result is the **representation
(duality) theorem**

$$ m \mid F(n) \iff z(m) \mid n, $$

which losslessly translates divisibility of Fibonacci *values* into divisibility
of *indices* — the index-side dual of the strong-divisibility identity
`F(\gcd(m,n)) = \gcd(F(m), F(n))`. We then quantify the duality in two ways.
First, the rank map is a **join (lcm) homomorphism**,
`z(\operatorname{lcm}(a,b)) = \operatorname{lcm}(z(a), z(b))`, but only a
one-sided *meet* (gcd) morphism, with a concrete witness (`a=4, b=6`) showing
strictness; this is the lattice/min-plus content of the duality. Second, fixing
a prime `p`, the `p`-adic absolute value of `F(n)` drops below `1` *exactly* on
the rank sublattice,

$$ |F(n)|_p < 1 \iff z(p) \mid n, $$

realising the slogan "arithmetic heights as tropical valuations" concretely on
the Fibonacci sequence via the exponential identity
`|q|_p = \exp(-v_p(q)\,\log p)`. All results are formally verified.

**Keywords.** Fibonacci numbers, rank of apparition, entry point, strong
divisibility sequence, *p*-adic valuation, ultrametric, tropical semiring,
non-archimedean height, primitive divisor.

---

## 1. Introduction

The Fibonacci sequence `F(0)=0, F(1)=1, F(n+2)=F(n)+F(n+1)` is the
prototypical *strong divisibility sequence*: it satisfies

$$ \gcd\big(F(m), F(n)\big) = F\big(\gcd(m,n)\big). \tag{SD} $$

A classical consequence is the **law of apparition** (Lucas): for each modulus
`m` there is a least positive index `z(m)`, the *rank of apparition* (or *entry
point*), such that `m ∣ F(n)` precisely when `z(m) ∣ n`. The purpose of this
paper is threefold:

1. To present the law of apparition as a *duality* — a lossless dictionary
   between divisibility of Fibonacci values and divisibility of indices — and to
   prove it in full generality for arbitrary `m ≥ 1`.
2. To make the existence of `z(m)` rest on a single, transparent structural
   fact: the *reversibility* of the Fibonacci transition map on the finite state
   space `(ℤ/mℤ)²`. No closed form, analytic estimate, or primality assumption
   is required.
3. To bridge the law of apparition to a tropical/ultrametric theory of
   arithmetic heights, exhibiting the rank of apparition as the exact controller
   of the *p*-adic size of Fibonacci numbers.

Throughout, `F : ℕ → ℕ` is the Fibonacci function, `gcd` and `lcm` are the
natural-number operations, `v_p` is the *p*-adic valuation, and `|\cdot|_p` is
the *p*-adic absolute value normalised so that `|p|_p = p^{-1}`.

---

## 2. The state machine and existence of the rank

### 2.1 The Fibonacci state pair

**Definition 2.1 (state pair).** For a modulus `m` and an index `n`, the
*Fibonacci state pair* modulo `m` is

$$ S_m(n) := \big(F(n) \bmod m,\ F(n+1) \bmod m\big) \in (\mathbb{Z}/m\mathbb{Z})^2. $$

The defining recurrence `F(n+2) = F(n) + F(n+1)` is precisely the statement that
`S_m` advances by the affine shift `T(a,b) = (b, a+b)`:

**Lemma 2.2 (transition).** `S_m(n+1) = \big(\,(S_m(n))_2,\ (S_m(n))_1 +
(S_m(n))_2\,\big)`, and `S_m(0) = (0, 1)`.

*Proof.* Unfold `F(n+2) = F(n) + F(n+1)` and reduce modulo `m`; the base case is
`F(0)=0, F(1)=1`. ∎

### 2.2 Reversibility forces pure periodicity

The transition `T` is injective: from `(b, a+b)` one recovers `b` (first
coordinate) and then `a = (a+b) - b` by additive cancellation. The next lemma
packages exactly this cancellation as a *descent*: a coincidence of states at
indices `i` and `i+d` can be "rewound" to a coincidence at `0` and `d`.

**Lemma 2.3 (descent).** For all `d, i`, if `S_m(i) = S_m(i+d)` then
`S_m(0) = S_m(d)`.

*Proof.* Induct on `i`. The base case `i = 0` is immediate. For the inductive
step, suppose `S_m(i+1) = S_m(i+d+1)`. Applying Lemma 2.2 to both sides and
comparing coordinates gives
`(S_m(i))_2 = (S_m(i+d))_2` (second coordinates) and
`(S_m(i))_1 + (S_m(i))_2 = (S_m(i+d))_1 + (S_m(i+d))_2` (first coordinates of
the shifted pairs). Subtracting (additive cancellation, `add_right_cancel`)
yields `(S_m(i))_1 = (S_m(i+d))_1`, hence `S_m(i) = S_m(i+d)`. The inductive
hypothesis closes the step. ∎

### 2.3 Existence of the rank of apparition

**Theorem 2.4 (existence).** For every `m ≥ 1` there exists `k > 0` with
`m ∣ F(k)`.

*Proof.* The map `S_m : ℕ → (ℤ/mℤ)²` has infinite domain and finite codomain, so
by pigeonhole there are `i < j` with `S_m(i) = S_m(j)`. Put `d := j - i > 0`;
then `S_m(i) = S_m(i+d)`, and Lemma 2.3 gives `S_m(0) = S_m(d)`. Since
`S_m(0) = (0,1)`, the first coordinate yields `F(d) \equiv 0 \pmod m`, i.e.
`m ∣ F(d)`. ∎

The proof uses no analytic input: only that an infinite sequence in a finite set
repeats, and that the transition map is reversible. The `m = 0` case genuinely
has no rank (`0 ∣ F(k) \iff k = 0`), so existence is correctly guarded by
`m ≥ 1`.

---

## 3. The representation (duality) theorem

**Definition 3.1 (rank of apparition / entry point).**

$$ z(m) := \min\{ k : k > 0 \ \text{and}\ m \mid F(k)\}, $$

the least positive index at which `m` appears as a divisor. (Equivalently,
`fibEntry m = Nat.find` of the witnessing predicate; we set `z(m) = 0` when no
positive index exists, i.e. only for `m = 0`.) By Theorem 2.4 the set is
nonempty for `m ≥ 1`, so `z(m)` is well defined, `z(m) > 0`, and
`m ∣ F(z(m))`, with `z(m) ≤ k` for any positive `k` with `m ∣ F(k)`
(minimality).

**Lemma 3.2 (simultaneous apparition).** If `m ∣ F(a)` and `m ∣ F(b)` then
`m ∣ F(\gcd(a,b))`.

*Proof.* From (SD), `F(\gcd(a,b)) = \gcd(F(a), F(b))`. As `m` divides both
`F(a)` and `F(b)`, it divides their gcd. ∎

**Theorem 3.3 (law of apparition / duality).** For `m ≥ 1` and all `n`,

$$ m \mid F(n) \iff z(m) \mid n. $$

*Proof.* ($\Leftarrow$) If `z(m) ∣ n` then `F(z(m)) ∣ F(n)` by the divisibility
property `F(a) ∣ F(b)` whenever `a ∣ b` (a consequence of (SD)). Since
`m ∣ F(z(m))`, transitivity gives `m ∣ F(n)`.

($\Rightarrow$) Suppose `m ∣ F(n)`. By Lemma 3.2 applied to `n` and `z(m)`,
`m ∣ F(\gcd(n, z(m)))`. Now `\gcd(n, z(m))` is a positive divisor of `z(m)`; by
minimality of `z(m)` it cannot be a *smaller* positive index at which `m`
appears, so `\gcd(n, z(m)) = z(m)`, i.e. `z(m) ∣ n`. ∎

**Remark 3.4 (the duality).** Theorem 3.3 is the index-side dual of (SD). The
strong-divisibility identity moves a gcd *into* the Fibonacci function;
the law of apparition moves divisibility *out* to the indices. Operationally it
trades a question about the value `F(n)` (which may have hundreds of digits) for
a single division `z(m) ∣ n`.

### 3.1 Corollaries: primitive divisors and strong divisibility recovered

**Corollary 3.5 (primitive divisors).** A prime `p` is a *primitive prime
divisor* of `F(n)` (i.e. `p ∣ F(n)` but `p ∤ F(k)` for `0 < k < n`) if and only
if `z(p) = n`. Equivalently, for `n > 0`, `IsFibPrimitiveDivisor p n \iff
\Pr(p) \wedge p \mid F(n) \wedge z(p) = n`.

*Proof.* Primitivity says `n` is the least positive index at which `p` appears,
which is the definition of `z(p) = n`; the equivalence with the displayed form
is Theorem 3.3 plus minimality. ∎

**Corollary 3.6 (strong divisibility, index form).** For `m ≥ 3`,

$$ F(m) \mid F(n) \iff m \mid n. $$

*Proof.* Specialise Theorem 3.3 to the modulus `F(m)` and use `z(F(m)) = m` for
`m ≥ 3` (the rank of `F(m)` is `m`: it divides `F(m)`, and `F` is strictly
increasing past index 2, so no smaller positive index works). ∎

---

## 4. Lattice (min-plus / tropical) structure of the rank map

We now study `z : (\mathbb{N}_{>0}, \mid) \to (\mathbb{N}_{>0}, \mid)` as a map of
divisibility lattices, where `lcm` is join and `gcd` is meet.

**Lemma 4.1 (divisibility determines equality).** If `d, e` satisfy
`d ∣ k \iff e ∣ k` for all `k`, then `d = e`.

*Proof.* Take `k = e` to get `d ∣ e`, and `k = d` to get `e ∣ d`; antisymmetry
of `∣` gives `d = e`. ∎

**Theorem 4.2 (join / lcm law).** For all `a, b > 0`,

$$ z\big(\operatorname{lcm}(a,b)\big) = \operatorname{lcm}\big(z(a), z(b)\big). $$

*Proof.* By Lemma 4.1 it suffices to show both sides have the same divisors `k`.
Using `\operatorname{lcm}(a,b) \mid F(k) \iff a \mid F(k) \wedge b \mid F(k)`
(a property of lcm) and Theorem 3.3 on each conjunct,

$$ \operatorname{lcm}(a,b) \mid F(k)
\iff z(a) \mid k \wedge z(b) \mid k
\iff \operatorname{lcm}(z(a), z(b)) \mid k, $$

the last step again by the defining property of lcm. Applying Theorem 3.3 once
more to the left side, `\operatorname{lcm}(a,b) \mid F(k) \iff
z(\operatorname{lcm}(a,b)) \mid k`. Hence the two ranks have identical divisor
sets, so they are equal. ∎

Theorem 4.2 strictly generalises the coprime multiplicativity
`z(ab) = \operatorname{lcm}(z(a), z(b))` for `\gcd(a,b)=1` (take coprime `a, b`,
so `\operatorname{lcm}(a,b) = ab`).

**Theorem 4.3 (monotonicity).** If `a ∣ b` and `b > 0` then `z(a) ∣ z(b)`.

*Proof.* `b ∣ F(z(b))` and `a ∣ b` give `a ∣ F(z(b))`; Theorem 3.3 (for `a > 0`,
which follows from `a ∣ b`, `b > 0`) yields `z(a) ∣ z(b)`. ∎

**Theorem 4.4 (meet bound).** For `a, b > 0`,

$$ z\big(\gcd(a,b)\big) \ \big|\ \gcd\big(z(a), z(b)\big). $$

*Proof.* `\gcd(a,b)` divides both `a` and `b`; monotonicity (Theorem 4.3) sends
this to `z(\gcd(a,b))` dividing both `z(a)` and `z(b)`, hence their gcd. ∎

**Theorem 4.5 (strictness of the meet bound).** The divisibility in Theorem 4.4
is in general *strict*: with `a = 4, b = 6`,

$$ z(\gcd(4,6)) = z(2) = 3 \quad\text{while}\quad \gcd(z(4), z(6)) = \gcd(6, 12) = 6. $$

*Proof.* Direct computation of entry points: `z(2) = 3` (first even Fibonacci is
`F(3)=2`), `z(4) = 6` (`F(6)=8`), `z(6) = 12` (`F(12)=144`). Then `\gcd(4,6)=2`
and `\gcd(6,12)=6`, and `3 ≠ 6`. ∎

**Corollary 4.6 (tropical interpretation).** The rank map `z` is a
*join-homomorphism* of divisibility lattices (Theorem 4.2) but not a
*meet-homomorphism* (Theorem 4.5). In the tropical (min-plus) dictionary where
`gcd ~ \min` and `lcm ~ \max` on the divisibility order, `z` preserves `\max`
exactly and bounds `\min` one-sidedly — the asymmetry characteristic of tropical
morphisms.

**Proposition 4.7 (divisibility as a min-plus / lattice homomorphism).** For
`a, b > 0`,

$$ \operatorname{lcm}(a, b) \mid F(n) \iff \big(a \mid F(n)\big) \wedge \big(b \mid F(n)\big), $$

so via Theorem 3.3 the predicate `n \mapsto (a \mid F(n))` sends the index `gcd`
to logical conjunction: `z(a) \mid n \wedge z(b) \mid n \iff
\operatorname{lcm}(z(a), z(b)) \mid n`. This is the sense in which the law of
apparition turns a tropical `min` of indices into a meet of divisibility
predicates.

---

## 5. The arithmetic-height / ultrametric bridge

We now connect divisibility to *size* via the *p*-adic absolute value, realising
the rank of apparition as the controller of the non-archimedean size of `F(n)`.

### 5.1 Non-archimedean norms and tropical valuations

**Definition 5.1 (non-archimedean norm).** A *non-archimedean (ultrametric)
norm* on an additive abelian group `G` is a map `N : G → ℝ` with `N(x) ≥ 0`,
`N(0) = 0`, `N(-x) = N(x)`, and the **strong triangle inequality**

$$ N(x + y) \le \max\big(N(x), N(y)\big). $$

Its induced distance `d(x,y) = N(x-y)` is then a pseudo-ultrametric.

**Theorem 5.2 (structural ultrametric facts).** For a non-archimedean norm `N`:
(i) `d(x,z) ≤ \max(d(x,y), d(y,z))` (strong triangle inequality for the
distance); (ii) *all triangles are isosceles*: if `d(x,y) ≠ d(y,z)` then
`d(x,z) = \max(d(x,y), d(y,z))`.

*Proof.* (i) Write `x - z = (x-y) + (y-z)` and apply the norm inequality.
(ii) It suffices to prove `N(u+w) = \max(N(u), N(w))` when `N(u) ≠ N(w)`; assume
WLOG `N(u) < N(w)`. Then `N(u+w) ≤ N(w)`, while
`N(w) = N((u+w) + (-u)) ≤ \max(N(u+w), N(u))` forces `N(u+w) ≥ N(w)`, hence
equality. Apply with `u = x-y`, `w = y-z`. ∎

**Definition 5.3 (tropical valuation).** A *tropical (min-plus) valuation* on `G`
is `v : G → ℝ` with `v(-x) = v(x)` and the min-superadditivity
`\min(v(x), v(y)) ≤ v(x+y)` for `x + y ≠ 0` (the zero locus is excluded, where a
genuine valuation would take `+\infty`).

**Theorem 5.4 (the bridge map).** A tropical valuation `v` induces a
non-archimedean norm by `N(x) = \exp(-v(x))` for `x ≠ 0` and `N(0) = 0`.

*Proof.* Nonnegativity and `N(0)=0` are immediate; symmetry follows from
`v(-x) = v(x)`. For the strong triangle inequality, the nonzero case uses
`\min(v(x), v(y)) ≤ v(x+y)` and the fact that `t \mapsto \exp(-t)` is decreasing,
turning `\min` into `\max`; the cases where any of `x, y, x+y` is `0` are direct.
∎

The map `t \mapsto \exp(-t)` is the order-reversing dictionary between the
tropical world `(\mathbb{R}, \min, +)` and the multiplicative world
`(\mathbb{R}_{>0}, \max, \cdot)`.

### 5.2 The *p*-adic valuation as a tropical valuation

**Theorem 5.5 (*p*-adic instance).** For a prime `p`, the map
`q \mapsto v_p(q)` is a tropical valuation on `ℚ` (min-superadditivity is
`\min(v_p(q), v_p(r)) ≤ v_p(q+r)` for `q+r ≠ 0`), and `q \mapsto |q|_p` is a
non-archimedean norm on `ℚ`. Consequently its induced distance is an ultrametric.

**Theorem 5.6 (exponential identity / height as tropical valuation).** For a
prime `p` and `q ≠ 0`,

$$ |q|_p = \exp\big(-v_p(q)\cdot \log p\big). $$

*Proof.* `|q|_p = p^{-v_p(q)}` by definition, and `p^{-v} = \exp(-v\log p)` in
`ℝ`. ∎

This exhibits the *p*-adic arithmetic height as the exponential of the (tropical)
*p*-adic valuation, the concrete realisation of "arithmetic heights as tropical
valuations."

### 5.3 The Fibonacci height capstone

**Theorem 5.7 (height capstone).** For a prime `p` and any `n`,

$$ |F(n)|_p < 1 \iff p \mid F(n) \iff z(p) \mid n. $$

*Proof.* For a nonzero integer `x`, `|x|_p < 1 \iff p \mid x` (the *p*-adic norm
drops below `1` exactly when `p` divides `x`). Apply with `x = F(n)` (handling
`F(0)=0` separately, where `z(p) ∣ 0` holds and `|0|_p = 0 < 1`), and then
invoke Theorem 3.3. ∎

**Corollary 5.8 (combinatorial control of non-archimedean size).** The *p*-adic
size of the Fibonacci numbers dips below `1` exactly along the arithmetic
progression `z(p), 2z(p), 3z(p), \dots`. More precisely, writing
`v_p(F(n))` for the *p*-adic valuation, `v_p(F(n)) > 0` iff `z(p) ∣ n`. The rank
of apparition `z(p)` is the exact combinatorial controller of the
non-archimedean size of Fibonacci numbers. (The precise *value* of `v_p(F(n))`
on the rank sublattice is governed by a lifting-the-exponent law, beyond the
scope of the threshold statement here.)

---

## 6. Algorithms

### 6.1 Computing the rank of apparition

The rank `z(m)` can be computed without ever forming large Fibonacci numbers, by
iterating the state pair modulo `m` until the Fibonacci coordinate vanishes
(equivalently, until the state returns to `(0,1)`):

```
function fibRank(m):
    if m == 1: return 1
    a, b := 0, 1          # (F(0), F(1)) mod m
    k := 0
    repeat:
        a, b := b, (a + b) mod m
        k := k + 1
        if a == 0: return k    # first k with m | F(k)
```

This runs in `O(z(m))` modular additions and `O(z(m) · \log m)` bit operations,
with `O(\log m)` space. By the theory of Pisano periods, `z(m) = O(m)` (in fact
`z(m)` divides the Pisano period `\pi(m) \le 6m`), so the loop terminates in at
most a linear number of steps in `m`.

### 6.2 Divisibility test for `F(n)` via the rank

To test `m ∣ F(n)` for an astronomically large `n`, Theorem 3.3 reduces the
problem to one division:

```
function fibDividesValue(m, n):
    return (n mod fibRank(m) == 0)
```

This is `O(z(m))` to find the rank, then `O(\log n)` for the division — entirely
independent of the size of `F(n)`.

### 6.3 Primitive divisor detection

By Corollary 3.5, a prime `p` is a primitive divisor of `F(n)` iff `z(p) = n`:

```
function isPrimitiveDivisor(p, n):
    return isPrime(p) and (p divides F(n)) and (fibRank(p) == n)
```

---

## 7. Applications

- **Primitive divisor theory (Carmichael).** Corollary 3.5 reduces the entire
  theory of which Fibonacci numbers introduce a brand-new prime to a single
  equation `z(p) = n`. The rank map is the natural language for the exceptional
  set `{1, 2, 6, 12}` where no primitive divisor exists.
- **Pisano periods and pseudorandomness.** The rank `z(m)` divides the Pisano
  period `\pi(m)` (the period of `F \bmod m`); the lattice laws of §4 give a
  clean handle on how these periods compose across moduli, relevant to
  Fibonacci-based pseudorandom generators.
- **Lucas primality tests.** Entry points underlie Lucas-sequence primality and
  compositeness certificates; the duality (Theorem 3.3) is the correctness
  statement that makes such certificates valid.
- **Non-archimedean / *p*-adic analysis.** Theorem 5.7 makes the rank of
  apparition the exact threshold for *p*-adic smallness of Fibonacci numbers,
  connecting the sequence to ultrametric geometry and the tropical-valuation
  viewpoint on arithmetic heights.

---

## 8. Discussion

The development is notable for its economy. The hard analytic apparatus often
associated with Fibonacci divisibility (Binet's formula, golden-ratio estimates)
plays no role. Existence of the rank (Theorem 2.4) is *purely* the reversibility
of the transition map on a finite set; the duality (Theorem 3.3) is *purely*
strong divisibility (SD) plus minimality of `\min`; the lattice laws (§4) are
elementary divisibility algebra read through the duality; and the height capstone
(§5) is the standard fact `|x|_p < 1 \iff p \mid x` composed with the duality.

Conceptually, three "worlds" are unified: (i) Fibonacci values and their
divisors; (ii) indices under ordinary divisibility, a lattice with `gcd`/`lcm`;
(iii) *p*-adic sizes, an ultrametric/tropical structure. The rank of apparition
is the functor linking (i) and (ii); the exponential `t \mapsto \exp(-t)` links
(ii)/valuations and (iii); and the composite says the combinatorial gadget `z(p)`
governs the non-archimedean geometry of the sequence.

A philosophical point: the rank map is a perfect *join* morphism but only a
*one-sided meet* morphism (Corollary 4.6). This asymmetry — exact for `lcm`,
inequality for `gcd` — is precisely the flavour of tropical mathematics, where
min-plus structures routinely satisfy sharp identities in one operation and only
inequalities in the dual. The Fibonacci sequence thus furnishes a small,
completely explicit model of a tropical morphism arising in pure arithmetic.

---

## 9. Future directions

See the dedicated future-directions discussion bundled with this package. In
brief: (1) re-frame the open infinite tail of the Fibonacci primitive-divisor
theorem via rank equality `z(p) = n`; (2) extend the duality and lattice laws to
general Lucas sequences and other strong divisibility sequences; (3) develop the
*quantitative* height law (lifting-the-exponent) giving `v_p(F(n))` exactly on
the rank sublattice; (4) formalise the Pisano-period/rank relationship and its
behaviour under the lattice operations; (5) explore the tropical-morphism
viewpoint as a template for other arithmetic functions.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| Existence (Thm 2.4) | `∀ m ≥ 1, ∃ k > 0, m ∣ F(k)` |
| Duality (Thm 3.3) | `m ∣ F(n) ⟺ z(m) ∣ n` |
| Primitive divisors (Cor 3.5) | `p` primitive divisor of `F(n)` ⟺ `z(p) = n` |
| Strong divisibility (Cor 3.6) | `F(m) ∣ F(n) ⟺ m ∣ n` for `m ≥ 3` |
| Join law (Thm 4.2) | `z(lcm(a,b)) = lcm(z(a), z(b))` |
| Monotonicity (Thm 4.3) | `a ∣ b ⟹ z(a) ∣ z(b)` |
| Meet bound (Thm 4.4) | `z(gcd(a,b)) ∣ gcd(z(a), z(b))` |
| Meet strictness (Thm 4.5) | witness `a=4, b=6`: `z(2)=3 ≠ 6 = gcd(z(4),z(6))` |
| Height–valuation (Thm 5.6) | `|q|_p = exp(-v_p(q) log p)` |
| Height capstone (Thm 5.7) | `|F(n)|_p < 1 ⟺ z(p) ∣ n` (`p` prime) |

All statements are formally verified.
