# FUTURE_DIRECTIONS.md — Fibonacci Apparition as a Local-to-Global Sheaf

## Synthesis

This cycle read the Fibonacci **rank of apparition** `z(m)` (the least positive index `k`
with `m ∣ F_k`, formalized unconditionally in `Novelty.FibApparitionExistence`) as a
**presheaf on the divisibility poset of moduli**, valued in the divisibility poset of
indices. The single structural input is strong divisibility, `gcd(F_a, F_b) = F_{gcd(a,b)}`
(`Nat.fib_gcd`), which is exactly the condition that turns the local data `z(a), z(b)` into a
*sheaf with no gluing obstruction*. The new file `Novelty.FibonacciApparitionGlue` proves the
three laws that pin this down, plus a bridge identifying `z` with the catalog's primitivity
labelling.

## Results summary (all `sorry`-free, axioms: `propext`, `Classical.choice`, `Quot.sound`)

* `FibApparition.apparitionRank_dvd_of_dvd` — **restriction map**: `a ∣ b ⟹ z(a) ∣ z(b)`.
  The presheaf is functorial on the divisibility poset.
* `FibApparition.apparitionRank_lcm` — **gluing law**: `z(lcm a b) = lcm(z a, z b)` for
  positive moduli. Local ranks over the cover `{a, b}` glue to the global rank; there is no
  cohomological obstruction (the "rank sheaf" is flasque, `H¹ = 0`).
* `FibApparition.apparitionRank_mul_of_coprime` — **coprime/stalk reduction**:
  `z(a·b) = lcm(z a, z b)` when `gcd(a,b) = 1`, the factor-by-factor computation underlying
  the prime-power stalks of `z`.
* `FibApparition.apparitionRank_eq_iff_isPrimitive` — **cross-domain bridge**: for `m, n ≥ 1`,
  `z(m) = n` iff `m` is a primitive divisor of `F_n` in the sense of
  `Applications.FibonacciPrimitiveDivisors.IsPrimitive`. The global section `z` *is* the
  catalog's primitivity labelling.

These extend, rather than reprove, `FibApparition.fib_dvd_iff_apparitionRank_dvd`,
`FibonacciPrimitiveDivisors.isPrimitive_unique`, and `simultaneous_apparition`.

A second outcome is diagnostic. The catalog's headline composite-case Carmichael theorem
(`Shared.CarmichaelProof.fib_carmichael_composite`) still rests on **one** `sorry`, the
infinite tail `n > 10000`; and the apparent discharge of that tail in
`Speculative.AutoResearch.fib_carmichael_large` is **circular** — it calls back into the very
lemma it claims to prove. The finite range `13 ≤ n ≤ 10000` is genuinely closed by
`native_decide`. This cycle isolates the true frontier and proposes a concrete attack below.

---

## Direction 1 — Close the Carmichael/Zsygmondy tail via a cyclotomic-value lower bound

The composite tail of `fib_carmichael_composite` is the Fibonacci case of Zsygmondy's
theorem: every `n > 12` admits a prime `p` with `z(p) = n`. The obstruction is purely a
*size* statement about the homogeneous cyclotomic value `C_n = ∏_{d ∣ n} F_d^{μ(n/d)}`, the
exact part of `F_n` carrying the primitive divisors.

**Conjecture (falsifiable).** For all `n ≥ 1`, `C_n ≥ φ^{φ(n)} / n`, where `φ` is the golden
ratio and `φ(n)` is Euler's totient; consequently the primitive part of `F_n` exceeds `1` for
every `n ∉ {1, 2, 6, 12}`. Falsifiable by exhibiting a single `n` with `C_n < φ^{φ(n)}/n`.

The key insight is that the primitive part of `F_n` and `C_n` differ by at most one
*intrinsic* prime, which is bounded by the largest prime factor `P(n) ≤ n`; so `C_n > n`
already forces a primitive divisor, and `C_n = ∏ |α − ζ^k β|` over primitive `n`-th roots
`ζ` is bounded below by `(|α| − |β|)^{φ(n)}`-type estimates with `α, β` the golden-ratio
conjugates. Why now? The local-to-global sheaf picture proved this cycle makes the reduction
clean: `z(p) = n` is *exactly* the primitivity bridge `apparitionRank_eq_iff_isPrimitive`, so
the only missing ingredient is the analytic lower bound on `C_n`, which is a self-contained
target that does not need the rest of Zsygmondy.

## Direction 2 — Lifting-the-Exponent as the stalk of the rank sheaf

The gluing law computes `z(m)` from prime-power stalks `z(p^e)`, but says nothing about how
`z(p^e)` grows with `e`. The classical answer is the Fibonacci LTE: for `p ∤ {0}` with
`z(p) = r`, one has `z(p^e) = r · p^{max(0, e − v_p(F_r))}`.

**Conjecture (falsifiable).** For every prime `p` and `e ≥ 1`,
`z(p^{e+1}) = p · z(p^e)` once `e ≥ v_p(F_{z(p)})`, and `z(p^{e+1}) = z(p^e)` below that
threshold. Falsifiable by one `(p, e)` violating either branch (checkable by `decide`).

The key insight is that the rank sheaf's stalk at `p` is an eventually-geometric sequence
with ratio `p`, so the entire global `z` is determined by the finite data
`{(z(p), v_p(F_{z(p)})) : p prime}`. Why now? The coprime/stalk reduction
`apparitionRank_mul_of_coprime` already reduces `z` to prime powers; this direction supplies
the *vertical* recursion that the horizontal `lcm` gluing leaves open, completing a full
local description of `z` over `Spec ℤ`.

## Direction 3 — The cohomological obstruction over a non-strong divisibility sequence

The gluing in `apparitionRank_lcm` is obstruction-free *because* Fibonacci is a strong
divisibility sequence. Drop that hypothesis and the "rank presheaf" should fail to be a
sheaf.

**Conjecture (falsifiable).** There is a linear recurrence `G` (e.g. a Lucas sequence
`U_n(P, Q)` with `P^2 − 4Q` not a perfect square but `gcd` structure broken, or the
companion Lucas numbers `L_n`) and moduli `a, b` for which
`z_G(lcm a b) ≠ lcm(z_G a, z_G b)`; equivalently the presheaf-to-sheaf comparison map has
nonzero "first obstruction". Falsifiable — and indeed *confirmable* — by a finite search over
small `a, b` for the Lucas numbers `L_n`, where `gcd(L_a, L_b)` is **not** `L_{gcd(a,b)}` in
general.

The key insight is that `apparitionRank_lcm`'s proof used `Nat.lcm_dvd_iff` together with the
biconditional `m ∣ F_n ↔ z(m) ∣ n`, and the *only* place strong divisibility enters is in
establishing that biconditional; so the obstruction class is literally the failure of
`gcd(G_a, G_b) = G_{gcd(a,b)}`. Why now? With the Fibonacci sheaf proven flasque, the natural
next experiment is to measure the obstruction for the *nearest* sequence that is not strongly
divisible, turning a qualitative "sheaf vs. presheaf" slogan into a computable invariant.

## Direction 4 — Pisano period as the global section of an order sheaf

`z(m)` is the apparition rank; the Pisano period `π(m)` is the order of the Fibonacci shift
map `fibStep` (already defined in `Novelty.FibApparitionExistence`) over `ZMod m`. The two are
linked by `z(m) ∣ π(m) ∣ 6·z(m)`-type laws.

**Conjecture (falsifiable).** `π` satisfies the *same* gluing law as `z`:
`π(lcm a b) = lcm(π a, π b)` for coprime `a, b`, and `z(m) ∣ π(m)` with quotient
`π(m)/z(m) ∈ {1, 2, 4}` for every prime power `m`. Falsifiable by a prime power with quotient
outside `{1,2,4}` (checkable by `decide`).

The key insight is that `fibStep` is an honest permutation of `ZMod m × ZMod m`, so `π(m)` is
the order of a group element and is therefore *automatically* multiplicative over coprime
moduli by the CRT splitting of `ZMod (a·b)` — the same mechanism that gives the `z`-gluing,
now upgraded from a divisibility statement to a group-order statement. Why now? The
`fibStep` permutation is already in the catalog with `fibStep_iterate` proven; turning its
*existence-of-period* (pigeonhole) into an *order sheaf* parallels exactly the `z`-sheaf built
this cycle and would unify apparition rank and Pisano period under one local-to-global roof.

## Direction 5 — A sheaf-theoretic reciprocity between `z(m)` and `m mod 5`

For primes `p ≠ 5`, the rank `z(p)` divides `p − (5/p)` (Legendre symbol), the Fibonacci
analogue of Fermat's little theorem. This is a *local* (mod `p`) law feeding the *global*
section `z`.

**Conjecture (falsifiable).** `z(p) ∣ p − 1` when `p ≡ ±1 (mod 5)` and `z(p) ∣ p + 1` when
`p ≡ ±2 (mod 5)`, for every prime `p ≠ 5`; moreover the density of primes with `z(p) = p −
(5/p)` (maximal rank) is positive. The divisibility half is falsifiable by one prime;
the density half is a quantitative, testable refinement.

The key insight is that `(5/p)` is the obstruction class controlling whether the golden ratio
is *defined over* `𝔽_p` (a split vs. inert prime in `ℤ[φ]`), so `z(p)` is governed by the
splitting type of `p` in the real quadratic field — a genuine local-to-global (Frobenius)
reciprocity. Why now? The primitivity bridge `apparitionRank_eq_iff_isPrimitive` reframes
"`p` has maximal rank" as "`p` is a primitive divisor of `F_{p−(5/p)}`", so this direction
connects the sheaf built this cycle to Chebotarev-style density questions and gives a concrete
arithmetic-statistics target for the next cycle.
