# FUTURE DIRECTIONS — Fibonacci Primitive Divisors / Carmichael's Theorem

This cycle delivered `Catalog/Logic/FibonacciPrimitiveDivisorBounded.lean`, a
self-contained, `sorry`-free verification of Carmichael's primitive-divisor
theorem on the range `13 ≤ n ≤ 10000`, together with:

* `fib_primitive_divisor_prime` — an *unconditional* proof for all prime indices
  `n ≥ 3` (every prime factor of `F(n)` is primitive);
* `fib_gcd_identity` — the strong-divisibility identity underpinning the theory;
* `fib_exceptional_no_primitive` — sharpness: `F(n)` has no primitive prime
  divisor for `n ∈ {1, 2, 6, 12}`, so `13` is the sharp threshold.

The genuinely open formalization target is the **unbounded composite tail**.
The conjectures below are stated so they can be transcribed almost verbatim into
Lean statements and attacked in follow-up cycles.

---

## Conjecture 1 (PRIORITY): Fibonacci Lifting-the-Exponent

For an odd prime `p` whose Fibonacci entry point is `z(p) = m` (i.e. `m` is least
with `p ∣ F(m)`), and any `k ≥ 1`:

```
padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m) + padicValNat p k.
```

**Why it matters.** This is the single missing analytic ingredient for the
unbounded tail. It controls exactly how much of `F(n)` is "imprimitive", and
combined with `F(n) ≥ φ^{n-2}` it forces a primitive factor for large `n`.

**Falsifiable test.** Check numerically for `p ∈ {3,7,11,...}`, `k ≤ 20`; a single
counterexample refutes it. (None expected — this is classical, but unformalized.)

---

## Conjecture 2: Primitive part dominates the index

Define the Möbius-cyclotomic primitive part
`Φ(n) = ∏_{d ∣ n} F(d) ^ μ(n/d)` (a positive integer). Then for every
`n ≥ 13`:

```
Φ(n) > n.
```

**Why it matters.** `Φ(n) > 1` already implies a primitive prime divisor; the
strict bound `Φ(n) > n` is the clean inequality that removes the `native_decide`
range cap entirely and yields the full theorem for ALL `n ≥ 13` (prime or
composite) in one stroke.

**Falsifiable test.** `Φ(12) = 144 / (F(6)·F(4)·F(2)... )` collapses to a
non-dominant value — verify the bound first fails exactly inside `{1,2,6,12}`.

---

## Conjecture 3: Entry point divides `p − (5|p)`

For a prime `p ≠ 5`, the Fibonacci entry point `z(p)` satisfies

```
z(p) ∣ (p - legendreSym p 5),   i.e. z(p) ∣ p - 1  or  z(p) ∣ p + 1,
```

according to whether `5` is a quadratic residue mod `p`.

**Why it matters.** This gives an *a priori* upper bound `z(p) ≤ p + 1`, the key
to proving that an imprimitive prime `p ∣ F(n)` must satisfy `p ∣ n` with
multiplicity one — the combinatorial half of the tail argument.

**Falsifiable test.** Tabulate `z(p)` vs `p ± 1` for primes `p < 200`.

---

## Conjecture 4: Lucas-number analogue

The Lucas numbers `L(n)` (`L 0 = 2`, `L 1 = 1`, `L(n+2) = L(n+1)+L(n)`) have a
primitive prime divisor for every `n ∉ {1, 6}`.

**Why it matters.** Lucas and Fibonacci sequences share companion-matrix
eigenvalues; a uniform "Lucas-sequence primitive divisor" lemma would let both
theorems be derived from one abstract result, generalizing the catalog's
`FibonacciLucasBridge`.

**Falsifiable test.** `native_decide` a bounded Lucas range exactly as done here
for Fibonacci; check the exceptional set is `{1,6}`.

---

## Conjecture 5: Multiplicity-one imprimitivity

If a prime `p` divides `F(n)` but is NOT a primitive divisor of `F(n)`, and `p`
is the largest such imprimitive prime, then `p ∣ n` and

```
padicValNat p (Nat.fib n) = padicValNat p (Nat.fib (z(p))) + padicValNat p n.
```

**Why it matters.** This is the precise quantitative form of "the only new prime
factors at level `n` beyond the divisor-levels are primitive", and is the direct
corollary of Conjectures 1 + 3 needed to finish Carmichael's tail.

**Falsifiable test.** Specialize to `n` with a known repeated prime (e.g. study
`p = 2` across `n`, where `z(2) = 3`) and compare `v_2(F n)` against the formula.
