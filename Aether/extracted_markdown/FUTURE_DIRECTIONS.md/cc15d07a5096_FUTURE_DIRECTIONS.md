# Future Directions — Entry Points as a Cross-Family Duality

## Synthesis

This cycle isolated the *entry point* (rank of apparition) `z(p) =` least `k > 0`
with `p ∣ a k` as a **structure-free** organizing object. The new file
`Catalog/Applications/StrongDivisibilityEntryPoint.lean` proves, with `sorry = 0`
and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`), that the
*entire* entry-point calculus rests on a single dual property — **strong
divisibility**

> `a (gcd m n) = gcd (a m) (a n)`   (`EntryPointCalculus.StrongDiv`)

— i.e. `a` is a lattice (anti)morphism from the index gcd-lattice `(ℕ, gcd)` to the
value gcd-lattice. Over this one hypothesis we obtain:

* `StrongDiv.dvd_of_index_dvd` — `m ∣ n → a m ∣ a n`;
* `dvd_iff_entryPoint_dvd`      — the clean bridge `p ∣ a n ↔ z(p) ∣ n`;
* `primitive_iff_entryPoint_eq` — primitivity ⇔ `z(p) = n` (needs *no* hypothesis at all);
* two instances obtained **for free**:
  * Fibonacci `Nat.fib` via `Nat.fib_gcd` (`fib_strongDiv`), and
  * the `b`-Mersenne / Bang–Zsygmondy family `n ↦ b^n − 1` via
    `Nat.pow_sub_one_gcd_pow_sub_one` (`mersenne_strongDiv`).

This realizes the duality advertised in the previous cycle's roadmap (Directions 4
and 5): Fibonacci primitive divisors and `b^n − 1` primitive divisors are now
*literally the same theorem*, `primitive_iff_entryPoint_eq`, applied to two lattice
morphisms. The catalog's scattered Carmichael reasoning
(`Catalog/Applications/FibonacciEntryPoints.lean`,
`Catalog/Shared/CarmichaelProof.lean`) can be retargeted at this reusable theory.

## Results Summary

A self-contained, axiom-clean, *family-agnostic* entry-point calculus now exists
over Mathlib. It recasts "primitive divisor of `a n`" as the order-theoretic
statement `z(p) = n`. The deliberate gap remains *existence* of a primitive divisor
for large `n` (the genuine `sorry` in `fib_carmichael_composite`'s infinite tail):
the divisibility/order *half* is now fully abstract, while the *growth* half — the
only place a specific family's size estimate enters — is what the directions below
attack.

---

## Direction 1 — A `StrongDiv` typeclass with a growth field closes Carmichael abstractly

**Conjecture.** Augment `StrongDiv a` with a single quantitative field
`hgrow : ∀ n, n * (∏ p ∈ n.primeFactors, p) < a n / (a 1)^{...}` (an effective
"the value outgrows its intrinsic divisors" bound). Then a *family-independent*
theorem yields: for every `n` outside an explicit finite exceptional set, `a n` has
a prime `p` with `z(p) = n`. Specializing the growth field to `Nat.fib`
(`Nat.fib` ~ `φ^n/√5`) closes `fib_carmichael_composite`; specializing to `b^n − 1`
reproves Bang–Zsygmondy.

**The key insight is** that `dvd_iff_entryPoint_dvd` already forces every
*non-primitive* prime factor of `a n` to have `z(p)` a *proper* divisor of `n`, so
the non-primitive part divides `∏_{d∣n, d<n} a d`; a strong-divisibility telescoping
bounds that product, and any genuine excess in `a n` must come from a primitive
prime. Only the excess estimate is family-specific — everything else is the abstract
lattice argument already proven.

**Why now?** The abstract half is done and `sorry`-free; the remaining obligation is
a *single inequality per family*, which Mathlib's `Nat.fib` growth lemmas and
`Nat.pow` monotonicity make directly checkable above an explicit threshold (matching
the `native_decide` range below it).

## Direction 2 — Lifting-the-Exponent is the multiplicative refinement of `z(p) ∣ n`

**Conjecture.** For a `StrongDiv` sequence and a prime `p` with `z(p) = m`, the
`p`-adic valuation is additive along multiples: `v_p(a (m·k)) = v_p(a m) + v_p(k)`
(with the standard `p = 5` / `p ∣ b` correction term). For `n ↦ b^n − 1` this is
*exactly* Mathlib's `padicValNat.pow_sub_pow`; for `Nat.fib` it is the open
Fibonacci-LTE.

**The key insight is** that `dvd_iff_entryPoint_dvd` is the order-`0` statement
"`p` appears iff `m ∣ n`", and LTE is its order-`r` upgrade "`p^r` appears iff
`m·p^{r−1} ∣ ...`"; both are governed by the same generator `z(p)`, so the Mersenne
case (already in Mathlib) is a *template* the Fibonacci case can be matched against
term-by-term through the abstract interface.

**Why now?** With `mersenne_strongDiv` instantiated, `padicValNat.pow_sub_pow` and
the abstract `entryPoint` now live in one file, so the analogy can be made a formal
shared lemma rather than two parallel developments.

## Direction 3 — `z(p)` is a multiplicative order, hence a Chebotarev density object

**Conjecture.** For `n ↦ b^n − 1` and a prime `p ∤ b`, `entryPoint (b^· − 1) p =
orderOf (b : (ZMod p)ˣ)`; consequently `#{p ≤ x : z(p) = n}` obeys an
Artin-primitive-root density governed by the splitting of `X^n − 1`. The Fibonacci
analogue replaces `b` by the golden ratio in `ZMod p[√5]`.

**The key insight is** that the entry point is the pullback of `p ∣ −` to a single
generator, and in `(ZMod p)ˣ` that generator is `b`, so "rank of apparition" and
"multiplicative order" are the *same spectral invariant* viewed in the index lattice
versus the unit group — a representation-theoretic dual of `dvd_iff_entryPoint_dvd`.

**Why now?** Mathlib's `ZMod`, `orderOf`, and `ZMod.pow_card_sub_one_eq_one` give a
concrete formal target, and the `mersenne_strongDiv` instance pins down exactly
which sequence to connect `orderOf` to.

## Direction 4 — Full Lucas-sequence transfer via the existing interface

**Conjecture.** Every nondegenerate Lucas sequence `U_n(P,Q)` with `gcd(P,Q)=1`
satisfies `StrongDiv (U · (P,Q))`, so `dvd_iff_entryPoint_dvd` and
`primitive_iff_entryPoint_eq` apply verbatim, and Carmichael's theorem holds with a
finite exceptional set depending only on `(P,Q)`.

**The key insight is** that the file's proofs invoke `a` *only* through `StrongDiv`
and `entryPoint`; a Lucas sequence is just another lattice morphism, so the transfer
is the one-line lemma `U_strongDiv : StrongDiv (U · (P,Q))` plus reuse — no new
order theory.

**Why now?** Fibonacci (`P,Q = 1,−1`) and Mersenne are already the two instances in
this file; proving the general `U_strongDiv` makes them special cases and immediately
populates the catalog's `FibonacciLucasBridge` with theorems instead of definitions.

## Direction 5 — Dual "exceptional sets are intersections of lattice fibers"

**Conjecture.** For any `StrongDiv` family the set of indices `n` with **no**
primitive divisor equals `{n : a n ∣ ∏_{d∣n, d<n} a d}`, and this set is finite iff
the family's growth eventually beats the divisor product (Direction 1). For
`b^n − 1` it is `{1, 2, 6}` (resp. classical Zsygmondy exceptions); for `Nat.fib`
it is `{1, 2, 6, 12}`.

**The key insight is** that `dvd_iff_entryPoint_dvd` makes "no primitive divisor"
purely a statement about the *fiber* `z^{-1}` of the index lattice — `n` is
exceptional exactly when every prime over `a n` already lies over a proper divisor —
so the exceptional set is a finite intersection of lattice fibers, computable by
`decide`/`native_decide` once the growth threshold of Direction 1 caps it.

**Why now?** `fib_twelve_no_primitive` in the catalog already exhibits one fiber
collapse by hand; the abstract `IsPrimitive`/`entryPoint` pair turns that ad-hoc
computation into a uniform, decidable characterization across all families.
