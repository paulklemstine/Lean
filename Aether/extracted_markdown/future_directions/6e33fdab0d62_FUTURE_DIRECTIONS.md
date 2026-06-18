# Future Directions — Korselt's Criterion & the Multiplicative-Order Bridge

Derived from the v16b research cycle that produced
`Catalog/Shared/KorseltCriterion.lean` and
`Catalog/Cryptography/KorseltGroupActionBridge.lean`.

This cycle proved, unconditionally, the *constructive* direction of Korselt's
criterion (squarefree + `(p-1) ∣ (n-1)` ⇒ absolute Fermat pseudoprime) and lifted
its conclusion to an order-divisibility condition on `(ℤ/nℤ)ˣ`, then bridged it into
the `CryptoGroupAction` framework. The cycle's analysis (the converse is "true but
harder"; `n-1` is not special to the proof; freeness recovers the order condition)
suggests the following falsifiable conjectures.

## C1 — Korselt's criterion is an iff (the hard converse)

**Conjecture.** If `n > 1` is composite and `a^(n-1) ≡ 1 [MOD n]` for every `a`
coprime to `n` (i.e. `IsFermatPsp n`), then `IsKorselt n`: `n` is squarefree and
`(p-1) ∣ (n-1)` for every prime `p ∣ n`.

**The key insight is** that the converse is forced by the *existence of a primitive
root mod each prime power factor*: if `p^2 ∣ n`, a generator of `(ℤ/p^2ℤ)ˣ` has order
`p(p-1) ∤ n-1`, contradicting the pseudoprime property; and a primitive root mod `p`
shows `(p-1) ∣ n-1`. Formalizing this needs only `ZMod.instIsCyclicUnits` (cyclicity
of `(ℤ/p^kℤ)ˣ` for odd `p`) plus a CRT splitting, both available in Mathlib.

**Why now?** The forward direction and the CRT reassembly lemma
(`dvd_of_squarefree_forall_prime_dvd`) are already proved in this cycle; the converse
reuses the same decomposition machinery in reverse, so the marginal cost is a single
cyclic-group lemma rather than a new theory.

## C2 — Generalized Korselt with an arbitrary exponent

**Conjecture.** For squarefree `n` and any `e ≥ 1`, `a^e ≡ 1 [MOD n]` for all `a`
coprime to `n` **iff** `(p-1) ∣ e` for every prime `p ∣ n`. The classical Korselt
criterion is the case `e = n-1`.

**The key insight is** that the value `n-1` plays *no role* in the forward proof:
`pow_modEq_one_of_prime_factor` only consumes `(p-1) ∣ e`. The exponent `n-1` is a
historical artifact of the Fermat test, not a mathematical necessity — so the true
invariant is the universal exponent `λ(n) = lcm{p-1}` (Carmichael's lambda).

**Why now?** `korselt_imp_fermatPsp` is already parametric in the divisibility
hypothesis; abstracting `n-1` to a free `e` is a direct generalization that
immediately connects to `Nat.Carmichael`-style universal-exponent results.

## C3 — Order spectrum collapse is detectable by a single random base

**Conjecture.** For a Korselt number `n` with `k` distinct prime factors, the
fraction of bases `a ∈ (ℤ/nℤ)ˣ` whose order is a *proper* divisor of `n-1` is at
least `1 - 2^{-(k-1)}`; hence a single uniformly random Fermat–Miller–Rabin witness
already exposes the order collapse with probability bounded away from `0`.

**The key insight is** that `korselt_orderOf_dvd` says *every* unit has order dividing
`n-1`, so the Miller–Rabin refinement detects compositeness precisely by finding a
unit whose order is even with a `2`-adic valuation incompatible with the per-prime
factors — a counting statement over the product group `∏ (ℤ/pℤ)ˣ`.

**Why now?** The bridge file already exposes `orderOf g ∣ n-1` as a first-class fact;
turning it into a density statement only needs `Fintype.card` arithmetic on the CRT
product decomposition, with no new number theory.

## C4 — Free torsors encode pseudoprimality (geometric Korselt)

**Conjecture.** A composite `n` is Carmichael **iff** in the regular `FreeTrans` of
`(ℤ/nℤ)ˣ` on itself, the "exponentiate-by-`n-1`" endomorphism of the torsor is the
constant identity map; and the *number* of fixed points of `act (g^d)` for `d ∣ n-1`
recovers the full order spectrum of `(ℤ/nℤ)ˣ`.

**The key insight is** that `korselt_freeTrans_recovers_order` shows freeness turns
the algebraic order condition into a *geometric* triviality of the torsor — so
pseudoprimality is literally a statement about the action having no nontrivial
"rotations of period `n-1`". This is the precise sense in which the CSI-FiSh torsor
model "sees" Carmichael numbers.

**Why now?** Both halves of the equivalence (action-trivial ⇐ Korselt, and order ⇐
action-trivial via freeness) are proved in this cycle; only the fixed-point counting
direction remains, and it is a clean orbit–stabilizer computation.

## C5 — Cross-domain hardness transfer

**Conjecture.** No `CryptoGroupAction` of `(ℤ/nℤ)ˣ` can be *both* free and have its
GAIP (group-action inverse problem) be classically hard when `n` is Korselt, because
the universal relation `g^(n-1) = 1` shrinks the effective key space to exponent
`λ(n) ∣ n-1`, giving a `√λ(n)`-time baby-step/giant-step attack.

**The key insight is** that the multiplicative-order bridge converts a *number-
theoretic* defect (Carmichael-ness) into a *cryptographic* weakness (small group
exponent), so pseudoprimality of the modulus is a direct security reduction, not a
heuristic.

**Why now?** The bridge `korselt_action_pow_trivial` already lives in the
Cryptography namespace and consumes the Shared-domain theorem; quantifying the
resulting key-space collapse is the natural next theorem on this exact interface.
