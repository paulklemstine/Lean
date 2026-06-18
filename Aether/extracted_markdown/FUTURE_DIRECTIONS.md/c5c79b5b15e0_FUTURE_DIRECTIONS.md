# Future Directions — Closing Carmichael's Bridge for Fibonacci Primitive Divisors

## Synthesis

This cycle repaired and extended the catalog's Carmichael layer — the claim that for
every index `n ≥ 13` the Fibonacci number `F(n)` carries a *primitive prime divisor*
(a prime `p` with `p ∣ F(n)` but `p ∤ F(k)` for all `0 < k < n`). The prior cycle had
left the development in a non-building state: the foundational module
`Shared.CarmichaelHelper` was missing entirely, the companion file was filed under a
module path that did not match its imports, and the headline theorem leaned on a single
`sorry` — the *infinite tail* for composite `n > 10000`.

We rebuilt the foundation from the ground up around one organizing principle: the
**entry-point (rank-of-apparition) calculus**, powered by the strong divisibility law
`F(gcd m k) = gcd(F m, F k)`. From this single law two things fall out cleanly:

1. **The prime case is elementary.** For prime `p`, every prime factor of `F(p)` is
   automatically primitive, because a shared factor of `F(p)` and `F(k)` (with
   `0 < k < p`) would divide `F(gcd(p,k)) = F(1) = 1`. This is now proved with
   `sorry = 0` as `fib_primitive_divisor_prime`.

2. **The computational test is exact.** We proved the *iff*
   `(∃ primitive prime divisor of F(n)) ↔ 1 < fibCoprimePart n`
   (`hasPrimitiveDivisor_iff_fibCoprimePart`), upgrading the catalog's one-directional
   `primitive_of_fibCoprimePart_pos` to a genuine equivalence. The forward direction
   rests on a *p-adic stability* lemma: dividing out the gcd with `F(d)` never removes a
   prime not dividing `F(d)`, so a primitive prime survives the entire fold and forces
   `fibCoprimePart n ≥ 2`. This converts "primitive divisor exists" into a *decidable*
   numerical predicate, which is exactly what justifies the `native_decide` sweep on
   `[14, 10000]`.

The result is an honest, fully verified fragment of Carmichael's theorem —
`fib_carmichael_verified` — covering all prime indices and all `n ≤ 10000`. The one
remaining `sorry` is now isolated, named, and documented as the classical *analytic
kernel*: composite `n > 10000`.

## Results Summary (this cycle, `sorry = 0` on each)

- `fib_dvd_of_dvd_gcd` — the strong-divisibility transfer lemma.
- `fib_gt_one_of_three_le` — `F(n) > 1` for `n ≥ 3`.
- `fib_primitive_divisor_prime` — **Carmichael, prime case** (every prime factor of `F(p)` is primitive).
- `prime_dvd_removePrimesOf`, `removePrimesOf_pos`, `fibCoprimePart_pos`, `prime_dvd_fibCoprimePart` — the p-adic stability toolkit for the computational coprime part.
- `hasPrimitiveDivisor_iff_fibCoprimePart` — **the exact characterization** (existence ⟺ `fibCoprimePart n > 1`).
- `fib_carmichael_verified` — **Carmichael, verified fragment** (`n ≥ 13` prime, or `n ≤ 10000`).

Infrastructure repaired: created `Shared/CarmichaelHelper.lean`, added `srcDir = "Catalog"`
to the lake configuration, and relocated `CarmichaelComposite.lean` to the module path its
importers expect. The entire Carmichael chain now compiles, with a single, clearly
annotated open `sorry`.

---

## Direction 1 — Build the cyclotomic factorization `F(n) = ∏_{d∣n} Φ(d)` over ℕ

**Conjecture.** Define `Φ : ℕ → ℕ` by strong recursion, `Φ(n) = F(n) / ∏_{d∣n, d<n} Φ(d)`.
Then (a) the division is exact (`∏_{d∣n, d<n} Φ(d) ∣ F(n)`), so `Φ` is integer-valued;
(b) `∏_{d∣n} Φ(d) = F(n)`; and (c) `Φ(n) = fibCoprimePart n · (the intrinsic prime power)`,
where the intrinsic prime power is `1` unless the largest prime factor `P` of `n` satisfies
`Φ(n/P) ≡ 0 (mod P)`.

**The key insight is** that `fibCoprimePart n`, which this cycle proved equals the
*primitive part* of `F(n)`, is exactly `Φ(n)` with at most one extra prime stripped out —
so the entire infinite-tail problem reduces to *lower-bounding `Φ(n)`*, a single positive
integer, rather than reasoning about the whole multiset of prime factors of `F(n)`.

**Why now?** This cycle already proved `prime_dvd_fibCoprimePart` and the existence iff,
which pin down precisely *which* primes survive the fold. The Möbius/strong-recursion
definition is the smallest missing piece, and its integrality follows from the strong
divisibility law we already use everywhere. This is the natural, low-risk next module.

**Falsifiable test.** `#eval` the recursive `Φ` against `F(n) / fibCoprimePart n` for
`n ≤ 2000`; the quotient must always be `1` or a single prime dividing `n`. A single
counterexample refutes the intrinsic-divisor structure (c).

## Direction 2 — A lifting-the-exponent (LTE) lemma for Fibonacci `v_p(F(n))`

**Conjecture.** For an odd prime `p` with entry point `z = z(p)` and `z ∣ n`,
`v_p(F(n)) = v_p(F(z)) + v_p(n) - v_p(z)`. Consequently every non-primitive prime of
`F(n)` divides `Φ(n)` to multiplicity at most `1`, and only when it is the largest prime
factor of `n`.

**The key insight is** that the entire "intrinsic divisor" obstruction collapses to a
*single arithmetic identity in `v_p`*: once LTE is available, the non-primitive part of
`F(n)` is forced to be `∏_{d∣n,d<n} Φ(d)` exactly, with no hidden higher-power surprises,
making `Φ(n)` literally the primitive part.

**Why now?** Mathlib has no `padicValNat.fib` lemma at all (verified this cycle), so this
is greenfield but self-contained: it needs only `Nat.fib_add_two`, the gcd law, and
`multiplicity` API. It is the highest-leverage single lemma in the whole program — it is
*the* reason the composite tail is hard, and proving it unblocks Directions 1 and 3.

**Falsifiable test.** Check `padicValNat p (Nat.fib n) = padicValNat p (Nat.fib z) +
padicValNat p n - padicValNat p z` by `#eval` over all `(p, n)` with `p < 50`, `n < 300`.
Any mismatch falsifies the proposed LTE form (e.g. would expose the special role of `p = 5`).

## Direction 3 — The growth bound `Φ(n) > n`, closing the infinite tail

**Conjecture.** For all `n ∉ {1, 2, 6, 12}`, `Φ(n) > n`. Combined with Directions 1–2,
this proves `fibCoprimePart n = Φ*(n) > 1` for every `n ≥ 13`, discharging the remaining
`sorry` in `fib_carmichael_composite` and promoting `fib_carmichael_verified` to the full
theorem `fib_primitive_divisor` for all `n ≥ 13`.

**The key insight is** that `Φ(n) ≥ α^{φ(n)} / α^{(number of proper divisors)}` with
`α = (1+√5)/2`, and `φ(n) ≥ √n` dominates `log n` for all but a handful of small `n`; so a
*single, crude* exponential-vs-polynomial inequality — not a delicate estimate — suffices,
and the finite exceptional set is exactly the one already cleared by the `native_decide`
sweep to `10000`.

**Why now?** The verified range `[14, 10000]` means we only ever need the asymptotic bound
for `n > 10000`, where `φ(n) ≥ √n > 100` and the inequality has enormous slack. The hard
analytic constants disappear; what remains is a clean `Nat`/`Real` interface lemma the
subagent is well suited to close once `Φ` exists.

## Direction 4 — Lift the characterization to general strong divisibility sequences

**Conjecture.** The iff `(∃ primitive prime divisor) ↔ 1 < coprimePart` proved here for
Fibonacci holds verbatim for *any* strong divisibility sequence `a : ℕ → ℕ`
(`gcd(a m, a n) = a (gcd m n)`) with `a 1 = 1` and `a n > 1` for `n ≥ 3` — in particular
for Lucas sequences `U_n(P,Q)`, Mersenne-type sequences `b^n - 1`, and elliptic divisibility
sequences (already present in Mathlib as `EllipticDivisibilitySequence`).

**The key insight is** that *nothing* in this cycle's forward/backward proof used a special
Fibonacci identity beyond the gcd law and positivity — `prime_dvd_removePrimesOf` and the
fold argument are sequence-agnostic — so the entire entry-point calculus is a theorem about
strong divisibility sequences, not about Fibonacci.

**Why now?** This is a pure generalization of code that already compiles; abstracting
`Nat.fib` to a typeclass `StrongDivSeq` is mechanical and immediately connects this number-
theory layer to the catalog's `EllipticDivisibilitySequence` material — a genuine
cross-domain bridge with near-zero proof risk.

**Falsifiable test.** Instantiate the abstract iff at `a n = 2^n - 1` and `#eval`-check
that `1 < coprimePart n ↔ Mersenne F(n)` has a primitive divisor for `n ≤ 40`; a mismatch
would reveal a hidden Fibonacci-specific assumption in the abstraction.

## Direction 5 — Zsygmondy as a bridge to the catalog's ordinal-analysis layer

**Conjecture.** The "primitive divisor exists for all large `n`" phenomenon (Zsygmondy /
Bang / Carmichael) is the order-type-`ω` shadow of a well-quasi-ordering: the function
`n ↦ z⁻¹(n)` (indices with entry point `n`) is eventually surjective, and the finite
exceptional set `{1,2,6,12}` is precisely the set of `n` below the "critical ordinal" of the
divisibility-sequence hierarchy formalized in `Logic.StronglyCriticalOrdinals` and
`Geometry.OrdinalAnalysisBridge`.

**The key insight is** that "every sufficiently large `F(n)` introduces a brand-new prime"
is a *no-infinite-antichain* statement in disguise — the same WQO skeleton that drives the
catalog's proof-theoretic ordinal results — so primitive-divisor existence and ordinal
collapse are two readings of one finiteness principle.

**Why now?** The catalog's ordinal-analysis files are complete and `sorry`-free, and this
cycle just made the Fibonacci side computational and exact; stating the bridge precisely
(even before proving it) is the boldest available cross-domain synthesis and a natural
headline for the next speculative cycle.

**Falsifiable test.** Formalize "the exceptional set of indices without a primitive divisor
is finite" and attempt to derive it from a WQO/`PartiallyWellOrderedOn` hypothesis on the
sequence; if no such derivation exists (i.e. finiteness genuinely needs the analytic
growth bound of Direction 3 and *cannot* be obtained order-theoretically), the bridge
conjecture in its strong form is falsified and must be weakened to an analogy.
