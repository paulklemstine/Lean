# Carmichael's Fibonacci Primitive Divisor Theorem: A Verified Proof on a Bounded Range, with an Unconditional Prime-Index Case

## Abstract

A *primitive prime divisor* of the Fibonacci number `F(n)` is a prime `p` with
`p ∣ F(n)` but `p ∤ F(k)` for all `0 < k < n`. Carmichael's classical theorem
(1913) asserts that `F(n)` has a primitive prime divisor for every index `n`
outside the exceptional set `{1, 2, 6, 12}`. We present a fully rigorous,
machine-checked proof of Carmichael's theorem on the range `13 ≤ n ≤ 10000`,
assembled from two logically independent pillars. The first is an *unconditional*
structural result: for every prime index `n ≥ 3`, **every** prime factor of
`F(n)` is primitive. Its proof is a three-line entry-point argument resting on the
strong-divisibility identity `gcd(F(m), F(n)) = F(gcd(m,n))`. The second pillar
handles composite indices through a verified "strip-the-imprimitive-part"
algorithm `primPart`: starting from `F(n)`, it removes every prime shared with a
proper-divisor Fibonacci number, and we prove that a residue exceeding `1`
certifies a primitive prime divisor. An exhaustive computation confirms the
certificate for all composite `n` in the range. We discuss why the prime and
composite regimes demand different techniques, why `13` is the sharp threshold,
and how the unbounded composite tail reduces to a Lifting-the-Exponent law for
Fibonacci `p`-adic valuations, which we state as the principal open formalization
target.

**Keywords.** Fibonacci numbers, primitive prime divisors, Carmichael's theorem,
entry point, strong divisibility, lifting the exponent, formal verification.

**MSC 2020.** 11B39 (Fibonacci and Lucas numbers), 11A41 (primes), 11Y55
(calculation of integer sequences), 68V20 (formalization of mathematics).

---

## 1. Introduction

The Fibonacci sequence is defined by `F(0) = 0`, `F(1) = 1`, and the recurrence
`F(n+2) = F(n+1) + F(n)`. Despite its elementary definition, its multiplicative
structure is subtle and remains a fertile source of research. This paper concerns
the distribution of *new* primes across the sequence.

**Definition 1.1 (Primitive prime divisor).** A prime `p` is a *primitive prime
divisor* of `F(n)` if `p ∣ F(n)` and `p ∤ F(k)` for every `k` with `0 < k < n`.

Equivalently, `p` is primitive for `F(n)` precisely when `n` is the *entry point*
of `p` (Definition 4.1): the first index at which `p` appears in the sequence.

**Theorem 1.2 (Carmichael, 1913).** For every `n ∉ {1, 2, 6, 12}`, the Fibonacci
number `F(n)` has a primitive prime divisor.

The exceptional set is genuine and sharp:

- `F(1) = F(2) = 1` have no prime factors;
- `F(6) = 8 = 2^3`, whose only prime `2` already divides `F(3) = 2`;
- `F(12) = 144 = 2^4 · 3^2`, whose primes `2, 3` already divide `F(3)` and
  `F(4) = 3`.

Thus `13` is the sharp threshold: for every `n ≥ 13`, `F(n)` has a primitive prime
divisor.

### 1.1 Contributions

We give a self-contained, mechanically verified proof of the following.

**Theorem 1.3 (Main, verified).** For every `n` with `13 ≤ n ≤ 10000`, `F(n)` has
a primitive prime divisor.

The proof is built from:

1. **An unconditional prime-index theorem** (Theorem 3.2): for every prime
   `n ≥ 3`, every prime factor of `F(n)` is primitive. This requires no
   computation and no range restriction.
2. **A verified primitive-part algorithm** (Section 4): a GCD-based stripping
   procedure `primPart` whose positivity beyond `1` certifies a primitive prime
   divisor (Theorem 4.6).
3. **An exhaustive range certificate** (Theorem 5.1): for all `13 ≤ n ≤ 10000`,
   either `n` is prime or `primPart(n) > 1`, verified by kernel-level
   computation.

We deliberately do not assert the unbounded composite tail `n > 10000`, which is
the deep analytic core of Carmichael's theorem; Section 8 isolates the exact
missing ingredient (a Fibonacci Lifting-the-Exponent law) as the priority open
problem.

### 1.2 Why two regimes

A central design decision is to treat prime and composite indices separately. The
prime case admits a short structural proof because the only proper divisor of a
prime is `1`, and `F(1) = 1` has no prime factors, collapsing the primitivity
check to a single contradiction. Composite indices have many proper divisors
contributing irregular inherited primes; the imprimitive part is not governed by a
clean closed form, so a computational certificate is the most direct route over a
finite range. An attempt to unify both regimes through `primPart` alone is
possible but strictly heavier: for prime `n`, `primPart(n)` strips nothing (the
only proper divisor is `1`), so the certificate is true but the strip-loop
bookkeeping is more involved than the direct entry-point argument. Keeping the
prime case separate yields both a shorter proof and a stronger conclusion (every
prime factor is primitive, not merely one).

---

## 2. The strong-divisibility foundation

All structural arguments rest on a single classical identity.

**Lemma 2.1 (Fibonacci GCD identity).** For all `m, n`,
`gcd(F(m), F(n)) = F(gcd(m,n))`.

*Remark.* In the formal development this is Mathlib's `Nat.fib_gcd`. It expresses
that the Fibonacci map is a *strong divisibility sequence*: divisibility of values
mirrors divisibility of indices.

**Lemma 2.2 (Strong divisibility).** If a number `p` divides both `F(n)` and
`F(k)`, then `p ∣ F(gcd(n,k))`.

*Proof.* From `p ∣ F(n)` and `p ∣ F(k)` we get `p ∣ gcd(F(n), F(k))`. By
Lemma 2.1, `gcd(F(n), F(k)) = F(gcd(n,k))`, hence `p ∣ F(gcd(n,k))`. ∎

We also record an elementary growth fact used to guarantee the existence of a
prime factor.

**Lemma 2.3 (Positivity of value).** For `n ≥ 3`, `F(n) > 1`.

*Proof.* Direct for `n = 3` (`F(3) = 2`). For `n ≥ 4`, write
`F(n) = F(n-1) + F(n-2)` with both summands positive and at least one exceeding
`1`; induction gives `F(n) > 1`. ∎

A convenient packaging of Lemma 2.2, the form actually transported in the proofs:

**Lemma 2.4 (Bridge lemma).** Let `0 < n` and let `p ∣ F(n)`. Suppose for every
proper divisor `d ∣ n` with `0 < d < n` we have `p ∤ F(d)`. Then for every `k`
with `0 < k < n`, `p ∤ F(k)`.

*Proof.* Suppose `p ∣ F(k)` for some `0 < k < n`. By Lemma 2.2,
`p ∣ F(gcd(n,k))`. Now `gcd(n,k)` is positive (since `n > 0`), divides `n`, and
satisfies `gcd(n,k) ≤ k < n`. Thus `gcd(n,k)` is a proper divisor of `n` with
`p ∣ F(gcd(n,k))`, contradicting the hypothesis. ∎

Lemma 2.4 reduces *primitivity* (a statement about all `0 < k < n`) to a finite
condition over the *proper divisors* of `n`. This reduction is the bridge between
the structural arguments and the computational certificate.

---

## 3. The prime-index theorem (unconditional)

For prime indices the proper-divisor condition of Lemma 2.4 trivializes.

**Lemma 3.1.** If `n` is prime and `d ∣ n` with `0 < d < n`, then `d = 1`.

*Proof.* A divisor of a prime is `1` or `n`; since `d < n`, `d = 1`. ∎

**Theorem 3.2 (Prime-index Carmichael).** For every prime `n ≥ 3` there exists a
prime `p` with `p ∣ F(n)` and `p ∤ F(k)` for all `0 < k < n`. Moreover, *every*
prime factor of `F(n)` has this property.

*Proof.* By Lemma 2.3, `F(n) > 1`, so `F(n)` has a least prime factor
`p = minFac(F(n))`, a prime dividing `F(n)`. Let `0 < k < n` and suppose
`p ∣ F(k)`. By Lemma 2.2, `p ∣ F(gcd(n,k))`. Since `n` is prime and `gcd(n,k)` is
a divisor of `n` with `gcd(n,k) ≤ k < n`, Lemma 3.1 gives `gcd(n,k) = 1`. Then
`p ∣ F(1) = 1`, impossible for a prime. Hence `p ∤ F(k)`. The same argument
applies verbatim to any prime factor of `F(n)`, since it used only `p ∣ F(n)` and
the primality of `p`. ∎

Theorem 3.2 is unconditional: no range restriction, no computation. It already
settles Carmichael's theorem at all prime indices `n ≥ 3` (which includes the
densest part of the index spectrum) and is strictly stronger than the bare
existence claim there.

---

## 4. The composite-index certificate

For composite `n`, the proper divisors of `n` contribute several inherited
Fibonacci factors, and we must measure the residual "primitive part."

**Definition 4.1 (Entry point).** The *entry point* `z(p)` of a prime `p` is the
least `m > 0` with `p ∣ F(m)`. (We do not need its full theory here, but it
clarifies that `p` is primitive for `F(n)` iff `z(p) = n`.)

**Definition 4.2 (Proper divisors).** `propDivs(n)` is the list of `d` with
`0 < d < n` and `d ∣ n`.

**Definition 4.3 (Stripping routine).** For residue `r`, modulus `m`, and fuel
budget `t ∈ ℕ`, define `stripAllAux(r, m, t)` by

```
stripAllAux(r, m, 0)     = r
stripAllAux(r, m, t+1)   = r                              if m ≤ 1
                         = r                              if gcd(r, m) ≤ 1
                         = stripAllAux(r / gcd(r,m), m, t) otherwise.
```

Fuel ensures structural termination; calling with `t = r` always suffices, since
each non-trivial step strictly decreases `r`.

**Definition 4.4 (Primitive part).** 
```
primPart(n) = foldl (fun r d => stripAllAux(r, F(d), r)) F(n) propDivs(n),
```
i.e. starting from `F(n)`, strip every prime shared with `F(d)` for each proper
divisor `d` of `n`.

We establish two correctness lemmas.

**Lemma 4.5a (Divisibility).** `stripAllAux(r, m, t) ∣ r`, and consequently
`primPart(n) ∣ F(n)`.

*Proof.* Induct on `t`. In the recursive branch, `stripAllAux(r/g, m, t-1) ∣ r/g`
by induction, and `r/g ∣ r` since `g = gcd(r,m) ∣ r`; compose. The fold statement
follows by list induction: each fold step replaces the accumulator by a divisor of
itself, and divisibility of the final `F(n)` is transitive through the chain. ∎

**Lemma 4.5b (Coprimality).** If `m > 1`, `r > 0`, and `t ≥ r`, then
`gcd(stripAllAux(r, m, t), m) = 1`. Consequently `primPart(n)` is coprime to
`F(d)` for every `d ∈ propDivs(n)`.

*Proof.* Induct on `t`. If `gcd(r,m) = 1` we are already done. If `gcd(r,m) > 1`,
then `r/gcd(r,m) > 0` and the fuel bound is preserved (`r/gcd(r,m) ≤ t-1` because
the quotient strictly decreases under a gcd exceeding `1`), so the inductive
hypothesis applies to `stripAllAux(r/gcd(r,m), m, t-1)`. The fold-level statement
follows by reverse list induction: the last stripping step makes the accumulator
coprime to the corresponding `F(d)`, and earlier accumulators retain coprimality
because each subsequent strip only passes to a divisor (using Lemma 4.5a together
with the fact that coprimality is inherited by divisors). The degenerate cases
`F(d) ≤ 1` (occurring at `d ∈ {1, 2}` where `F(d) = 1`) are handled directly,
since nothing is stripped and `gcd(r, 1) = 1`. ∎

These combine into the certificate.

**Theorem 4.6 (Primitive-part certificate).** For `n ≥ 3`, if `primPart(n) > 1`
then `F(n)` has a primitive prime divisor; explicitly, `p = minFac(primPart(n))`
is one.

*Proof.* Let `p = minFac(primPart(n))`, a prime by `primPart(n) > 1`. By
Lemma 4.5a, `p ∣ primPart(n) ∣ F(n)`. For primitivity, by Lemma 2.4 it suffices to
show `p ∤ F(d)` for every proper divisor `d ∣ n`, `0 < d < n`. Such `d` lies in
`propDivs(n)`, and by Lemma 4.5b, `gcd(primPart(n), F(d)) = 1`. Since
`p ∣ primPart(n)`, if `p ∣ F(d)` then `p ∣ gcd(primPart(n), F(d)) = 1`, a
contradiction. Hence `p ∤ F(d)`, and Lemma 2.4 upgrades this to `p ∤ F(k)` for all
`0 < k < n`. ∎

**Exceptionality.** The certificate vanishes exactly on the exceptional indices:
`primPart(6) = 1` (since `F(6) = 8` and `F(3) = 2` strips the entire `2^3`) and
`primPart(12) = 1` (since `F(12) = 144` is consumed by `F(3) = 2`, `F(4) = 3`,
`F(6) = 8`). For `n ∈ {1, 2}`, `F(n) = 1` and there is nothing to strip. This is
the computational manifestation of sharpness.

---

## 5. The range certificate and main theorem

**Theorem 5.1 (Range certificate).** For every `n` with `13 ≤ n ≤ 10000`, either
`n` is prime or `primPart(n) > 1`.

*Proof.* The statement is a decidable proposition over a finite index set
(`Finset.Icc 13 10000`); each instance reduces to integer arithmetic on
`gcd`, division, and `Nat.fib`. It is discharged by kernel-checked evaluation
(`native_decide`). The dominant cost is the GCD strip loop, which is fast at this
scale. ∎

**Theorem 5.2 (Composite case, verified range).** For composite `n` with
`13 ≤ n ≤ 10000`, `F(n)` has a primitive prime divisor.

*Proof.* By Theorem 5.1 and `¬ Prime n`, we have `primPart(n) > 1`; apply
Theorem 4.6 (with `n ≥ 13 ≥ 3`). ∎

**Theorem 5.3 (Main).** For every `n` with `13 ≤ n ≤ 10000`, `F(n)` has a
primitive prime divisor.

*Proof.* If `n` is prime, apply Theorem 3.2 (valid since `n ≥ 13 ≥ 3`). If `n` is
composite, apply Theorem 5.2. ∎

The combined proof is `sorry`-free and depends only on the standard Mathlib axiom
base (including `Lean.ofReduceBool` for the `native_decide` step).

---

## 6. Worked examples

We trace the proof on representative indices to expose how each pillar operates and
why the exceptional indices fail.

**Example 6.0a (Prime index `n = 13`).** `F(13) = 233`, itself prime. By
Theorem 3.2, the least prime factor `233` is primitive. The verification is the
entry-point contradiction: if `233 ∣ F(k)` for some `0 < k < 13`, then
`233 ∣ F(gcd(13,k))`; as `13` is prime and `gcd(13,k) < 13`, the gcd is `1`, giving
`233 ∣ F(1) = 1`, absurd. Note the argument never used that `233` is prime as a
*value* of `F(13)` — only that `13` is a prime *index*.

**Example 6.0b (Composite index `n = 14`).** `F(14) = 377 = 13 · 29`. The proper
divisors of `14` are `1, 2, 7`. Stripping: `F(1) = F(2) = 1` remove nothing;
`F(7) = 13` shares the factor `13` with `377`, so `strip` divides it out, leaving
`377 / 13 = 29`. Thus `primPart(14) = 29 > 1`, and `minFac(29) = 29` is the
primitive divisor — indeed `29` first appears at index `14`, while `13` was
inherited from `F(7)`.

**Example 6.0c (Composite index `n = 18`).** `F(18) = 2584 = 2^3 · 17 · 19`. Proper
divisors `1, 2, 3, 6, 9`. We strip `F(3) = 2` (removing the entire `2^3`),
`F(6) = 8` (already gone), `F(9) = 34 = 2 · 17` (removing the `17`), leaving `19`.
So `primPart(18) = 19`, the primitive prime divisor; `2` and `17` were inherited.

**Example 6.0d (Exceptional `n = 12`).** `F(12) = 144 = 2^4 · 3^2`. Proper divisors
`1, 2, 3, 4, 6`. Stripping `F(3) = 2` removes `2^4`; stripping `F(4) = 3` removes
`3^2`; the residue collapses to `1`. Hence `primPart(12) = 1`: no newcomer exists.
The primes `2` and `3` were already born at `F(3)` and `F(4)`. Likewise
`F(6) = 8 = 2^3` collapses under `F(3) = 2`, giving `primPart(6) = 1`. These two,
together with the degenerate `F(1) = F(2) = 1`, are the complete failure set, and
the certificate detects them automatically.

**Example 6.0e (Entry-point cross-check).** The entry point `z(p)` offers an
independent verification: `p` is primitive for `F(n)` iff `z(p) = n`. For `p = 29`,
streaming the sequence gives the first multiple of `29` at `F(14)`, so `z(29) = 14`,
confirming Example 6.0b. For `p = 19`, `z(19) = 18`, confirming Example 6.0c.

## 7. Algorithms

### 7.1 Primitive-part computation

The certificate of Section 4 is algorithmic. Given `n`, compute `F(n)` and the
proper divisors of `n`; for each `d`, repeatedly divide out `gcd(r, F(d))` until
coprime; return the residue.

```
Algorithm PRIMPART(n):
  r ← F(n)
  for d in proper_divisors(n):            # 0 < d < n, d | n
      m ← F(d)
      if m > 1:
          loop:
              g ← gcd(r, m)
              if g == 1: break
              r ← r / g
  return r
```

Correctness: Lemma 4.5a (`PRIMPART(n) ∣ F(n)`) and Lemma 4.5b (coprime to each
`F(d)`). Complexity: with `D(n)` proper divisors and Fibonacci values of
`O(n)` bits, each gcd costs `O(n^2 / w)` word operations (machine word `w`); the
inner loop runs at most `O(n)` times but in practice a handful, so `PRIMPART(n)` is
comfortably polynomial in `n`.

### 7.2 Carmichael witness extraction

To exhibit an explicit primitive prime divisor of `F(n)` for `n ≥ 13`:

```
Algorithm WITNESS(n):
  if is_prime(n):                          # prime-index theorem
      return min_prime_factor(F(n))
  pp ← PRIMPART(n)                         # composite-index certificate
  assert pp > 1
  return min_prime_factor(pp)
```

The two branches mirror Theorem 3.2 and Theorem 4.6 exactly; `min_prime_factor`
realizes `minFac`.

### 7.3 Entry-point tabulation

The entry point `z(p)` (Definition 4.1) provides an independent cross-check:
`p` is primitive for `F(n)` iff `z(p) = n`.

```
Algorithm ENTRYPOINT(p):
  m ← 1
  while F(m) mod p != 0:
      m ← m + 1
  return m
```

---

## 8. Discussion and future work

The bounded result reduces Carmichael's theorem, for `13 ≤ n ≤ 10000`, to two
clean and verified pillars. The unbounded composite tail (`n > 10000`) is the
genuinely deep part. We isolate the precise missing analytic input and several
adjacent targets, stated so they may be transcribed almost verbatim into formal
statements.

**Conjecture 8.1 (Fibonacci Lifting-the-Exponent, priority).** Let `p` be an odd
prime with entry point `z(p) = m`. Then for all `k ≥ 1`,
```
v_p(F(mk)) = v_p(F(m)) + v_p(k),
```
where `v_p` is the `p`-adic valuation. Combined with the growth bound
`F(n) ≥ φ^{n-2}` (golden ratio `φ`), this controls the imprimitive part of `F(n)`
and forces a primitive factor for all large `n`, removing the range cap.

**Conjecture 8.2 (Primitive part dominates the index).** Let
`Φ(n) = ∏_{d ∣ n} F(d)^{μ(n/d)}` be the Möbius–cyclotomic primitive part. Then
`Φ(n) > n` for every `n ≥ 13`. Since `Φ(n) > 1` already implies a primitive prime
divisor, the strict bound `Φ(n) > n` yields the full theorem for all `n ≥ 13` in
one stroke. The bound fails exactly inside `{1, 2, 6, 12}`.

**Conjecture 8.3 (Entry point divides `p − (5|p)`).** For a prime `p ≠ 5`,
`z(p) ∣ p − (5|p)`, i.e. `z(p) ∣ p − 1` or `z(p) ∣ p + 1` according to the
Legendre symbol `(5|p)`. This yields the a priori bound `z(p) ≤ p + 1`, central to
showing an imprimitive prime `p ∣ F(n)` must satisfy `p ∣ n` with multiplicity
one — the combinatorial half of the tail argument.

**Conjecture 8.4 (Lucas analogue).** The Lucas numbers (`L(0)=2`, `L(1)=1`,
`L(n+2)=L(n+1)+L(n)`) have a primitive prime divisor for every `n ∉ {1, 6}`. Lucas
and Fibonacci share companion-matrix eigenvalues; a uniform "Lucas-sequence
primitive divisor" lemma would subsume both.

These sit inside the broader Bilu–Hanrot–Voutier program (2001), which classifies
the exceptional indices for *all* Lucas and Lehmer sequences. Carmichael's
Fibonacci theorem is the gateway instance, and the verified scaffolding here — the
GCD identity, the bridge lemma, the entry-point picture, and the primitive-part
certificate — is precisely the apparatus on which a formal proof of the tail (via
Conjecture 8.1 or 8.2) would be built.

---

## 9. Conclusion

We have given a self-contained, machine-verified proof of Carmichael's Fibonacci
primitive-divisor theorem on `13 ≤ n ≤ 10000`, with an unconditional structural
proof at all prime indices. The architecture cleanly separates a computation-free
prime case from a certificate-driven composite case, both founded on the single
strong-divisibility identity `gcd(F(m), F(n)) = F(gcd(m,n))`. The sharp threshold
`13` and the exceptional set `{1, 2, 6, 12}` emerge transparently from the
vanishing of the primitive-part certificate. The path to the unbounded theorem
runs through a Fibonacci Lifting-the-Exponent law, stated here as the priority open
target.

---

## References

- R. D. Carmichael, *On the numerical factors of the arithmetic forms αⁿ ± βⁿ*,
  Annals of Mathematics 15 (1913), 30–70.
- Yu. Bilu, G. Hanrot, P. M. Voutier, *Existence of primitive divisors of Lucas
  and Lehmer numbers*, Journal für die reine und angewandte Mathematik 539 (2001),
  75–122.
- The Fibonacci GCD identity and `Nat.fib` API as formalized in the Mathlib
  library.
