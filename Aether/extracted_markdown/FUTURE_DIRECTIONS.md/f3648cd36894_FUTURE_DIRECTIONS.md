# Future Directions — Fibonacci Entry Points and Carmichael's Theorem

## Synthesis

This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 0`
with `p ∣ F(k)` as the single organizing object behind the catalog's scattered
Carmichael/primitive-divisor reasoning. The new file
`FibonacciEntryPoint.lean` proves, with `sorry = 0` and only the standard
axioms, a small but complete theory:

* `fibEntryPt_dvd` — `z(p) ∣ n` whenever `p ∣ F(n)` (no primality needed);
* `fib_dvd_of_fibEntryPt_dvd` — the converse, via `Nat.fib_dvd`;
* `dvd_fib_iff_fibEntryPt_dvd` — the clean equivalence `p ∣ F(n) ↔ z(p) ∣ n`;
* `primitive_iff_fibEntryPt_eq` — `p` is a primitive divisor of `F(n)` iff `z(p) = n`;
* `fib12_no_primitive` — the sharp counterexample explaining the bound `n ≥ 13`.

The deliberate gap is the *existence* of a primitive divisor for every composite
`n > 50000` (the lone genuine `sorry` left in `Shared/CarmichaelProof.lean`'s
`fib_carmichael_composite`). Everything below is a roadmap toward closing it, plus
adjacent conjectures the entry-point lens makes newly tractable.

## Results Summary

A self-contained, axiom-clean entry-point calculus now exists over Mathlib. It
recasts "primitive divisor" as the purely order-theoretic statement `z(p) = n`,
which is exactly the certificate a future LTE/growth argument must produce. The
catalog files that previously asserted these facts ad hoc (and did not build, due
to a missing `Shared.CarmichaelHelper`) can be retargeted at this reusable theory.

---

## Direction 1 — Fibonacci Lifting-the-Exponent (the keystone)

**Conjecture.** For an odd prime `p` with entry point `z(p) = m` and `p ≠ 5`,
the `p`-adic valuation satisfies `v_p(F(m·k)) = v_p(F(m)) + v_p(k)` for all
`k ≥ 1`; for `p = 5`, `v_5(F(k)) = v_5(k)`.

**The key insight is** that `F(mk)/F(m)` expands, via the companion matrix
`V = [[1,1],[1,0]]` diagonalized over `ℤ_p[√5]`, as a binomial sum whose
leading nontrivial term is `k · r^{k-1}` modulo the maximal ideal, so the
valuation is *additive* in `k` exactly like the classical `padicValNat.pow_sub_pow`
LTE for `a^n - b^n`.

**Why now?** `primitive_iff_fibEntryPt_eq` reduces "primitive divisor of `F(n)`"
to producing a prime with `z(p) = n`; LTE is the precise tool that controls how
`z(p)` propagates to multiples, so this conjecture is the missing multiplicative
half of the already-proven divisibility half.

## Direction 2 — Cyclotomic / Möbius primitive part grows past every index

**Conjecture.** Define `Φ_n := ∏_{d ∣ n} F(d)^{μ(n/d)}` (the Möbius "primitive
part"). Then `log Φ_n = φ(n) · log φ_golden + o(n)`, and for all `n > 50000`
the integer `Φ_n` has a prime factor `q` with `z(q) = n`; consequently
`fib_carmichael_composite` holds for all such `n`, closing the open `sorry`.

**The key insight is** that the only obstructions to a prime factor of `Φ_n`
being primitive are the finitely many "intrinsic" primes dividing `n` itself
(the Zsygmondy exceptions), and a counting bound `Φ_n > n · ∏_{p ∣ n} p`
forces a genuinely new prime once `φ(n) log φ_golden` dominates `log n`.

**Why now?** Direction 1 supplies the valuation identity that turns the divisor
product into a telescoping estimate; combined with Mathlib's
`Nat.fib` growth lemmas this becomes an effective inequality verifiable above an
explicit threshold, matching the computational `native_decide` range below it.

## Direction 3 — Entry points realize a uniform-distribution / density law

**Conjecture.** The set `{p prime : z(p) = n}` is nonempty for every `n ∉ {1,2,6,12}`,
and the counting function `#{p ≤ x : z(p) ∣ n}` satisfies an asymptotic of
Chebotarev type governed by the splitting of `x² - x - 1` in `ℚ(√5)`.

**The key insight is** that `z(p)` equals the multiplicative order of the golden
ratio mod `p` (when `5` is a QR) or twice the order of `-φ̄/φ` otherwise, so the
entry-point distribution is an Artin-style primitive-root problem in disguise.

**Why now?** `dvd_fib_iff_fibEntryPt_dvd` already expresses divisibility purely
through `z`, so density statements about primitive divisors translate directly
into statements about orders mod `p`, where Mathlib's `ZMod` and `orderOf` API
gives a concrete formal target.

## Direction 4 — Transfer the entry-point calculus to all Lucas sequences

**Conjecture.** For any nondegenerate Lucas sequence `U_n(P,Q)` with
`gcd(P,Q)=1`, the analogue `z_U(p)` satisfies the same three pillars proven here
(`z ∣ n` ⇔ `p ∣ U_n`, primitivity ⇔ `z = n`), and Carmichael's theorem holds
with a finite, explicitly computable exceptional set depending only on `(P,Q)`.

**The key insight is** that the proofs in `FibonacciEntryPoint.lean` used *only*
strong divisibility `U_{gcd(m,n)} = gcd(U_m,U_n)` and `m ∣ n → U_m ∣ U_n`, both
of which hold for every Lucas sequence — so the entire file generalizes with the
Fibonacci-specific lemmas swapped for their Lucas counterparts.

**Why now?** The current proofs are deliberately written against the two abstract
divisibility facts, making the generalization a refactor (introduce a typeclass
`StrongDivisibilitySequence`) rather than new mathematics.

## Direction 5 — A formal Zsygmondy theorem for `aⁿ − bⁿ`

**Conjecture.** For coprime `a > b ≥ 1`, `aⁿ − bⁿ` has a primitive prime divisor
for all `n` outside an explicit finite set, and the *same* entry-point machinery
(`z(p) =` order of `a/b` mod `p`) yields the proof, unifying Bang–Zsygmondy and
Carmichael under one Lean development.

**The key insight is** that primitive-divisor existence for `aⁿ−b⁛` and for `F(n)`
are the two faces of order theory in `(ℤ/p)^×`; the entry point is the order, and
"primitive" is "the order is exactly `n`" — verbatim our `primitive_iff_fibEntryPt_eq`.

**Why now?** Mathlib already contains `padicValNat.pow_sub_pow` (LTE for `aⁿ−bⁿ`)
and `ZMod.orderOf` theory, so the `aⁿ−bⁿ` case is *closer* to formalization than
Fibonacci — proving it first would give a template (and the missing LTE input) for
finishing Direction 2.
