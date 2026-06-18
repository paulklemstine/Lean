# Future Directions — The Fibonacci apparition adjunction `fibRank ⊣ fib`

## Synthesis

This cycle stopped treating the Fibonacci *rank of apparition* `fibRank m` (the least
positive index `k` with `m ∣ F_k`) as a piece of ad-hoc arithmetic and recognised it as
**one half of a Galois adjunction** on the divisibility order:

> `fibRank ⊣ fib`,   with defining inequality   `fibRank m ∣ n  ↔  m ∣ fib n`.

The catalog already had the *defining inequality* in disguise
(`FibApparition.fib_dvd_iff_rank_dvd`, proved by pure pigeonhole periodicity of the state
pair `(F_n, F_{n+1}) mod m`). The new file
`Catalog/Speculative/AutoResearch/FibonacciApparitionAdjunction.lean` lifts it to `m = 0`
(`fib_dvd_iff_rank_dvd_all`), packages it as an honest `GaloisConnection rankD fibD` on a
divisibility lattice `DvdNat` (`⊓ = gcd`, `⊔ = lcm`), and then lets the *abstract* Galois
API do all the work. Two payoffs stand out.

1. **Representation theorem.** The adjunction's closure operator `c m := fib (fibRank m)`
   is idempotent and its fixed points are **exactly** the Fibonacci values
   (`closure_fixedPoint_iff_isFib : fib (fibRank m) = m ↔ ∃ k, fib k = m`). So the
   apparition adjunction *is* the canonical projection of an arbitrary modulus onto its
   "Fibonacci shadow", and `range fib` is the shadow space.

2. **Unification.** Two facts that the catalog had proved independently —
   the strong-divisibility identity `Nat.fib_gcd` (the priority `Fib_gcd_identity`) and the
   rank lcm law (`FibonacciApparitionLattice.fibEntry_lcm`) — are revealed to be **one
   theorem stated twice**: a right adjoint preserves meets (`u_inf` → `fib_gcd`), a left
   adjoint preserves joins (`l_sup` → `fibRank_lcm`). See `fib_gcd_eq_adjunction` and
   `fibRank_lcm_eq_adjunction`.

Along the way the catalog file `FibonacciApparitionDuality.lean` was repaired (it imported
a missing `Bridges/TropicalUltrametricBridge.lean`; the offending import and the single
theorem using it were commented out, the Mathlib-native `padicNorm` capstone kept), and the
package `lakefile.toml` was given the `srcDir = "Catalog"` it needs to resolve modules.

## Results summary (all `sorry`-free, kernel-checked axioms only)

* `fibRank_zero`, `fib_dvd_iff_rank_dvd_all` — the adjunction's defining inequality for
  every modulus `m`, the `m = 0` boundary included.
* `fibRank_gc : GaloisConnection rankD fibD` — the adjunction itself.
* `monotone_fibRank`, `monotone_fib_dvd` — both adjoints are divisibility morphisms.
* `dvd_fib_fibRank`, `fibRank_fib_dvd_self`, `fib_fibRank_fib`, `fibRank_fib_fibRank` —
  the closure/kernel operators and their idempotence.
* `closure_fixedPoint_iff_isFib` — the representation theorem (fixed points = `range fib`).
* `fib_gcd_eq_adjunction`, `fibRank_lcm_eq_adjunction` — the unification capstones.

---

## Direction 1 — A `ClosureOperator`/`LowerAdjoint` packaging and a *quotient* representation

Promote the ad-hoc closure `c m = fib (fibRank m)` to Mathlib's bundled
`ClosureOperator DvdNat` (via `GaloisConnection.closureOperator`) and prove that the
induced equivalence of `DvdNat` is "same rank of apparition": `c a = c b ↔ fibRank a =
fibRank b`. Then exhibit the **quotient representation**: the poset of closed elements
(= `range fib` ordered by divisibility) is order-isomorphic to the image lattice of
`fibRank`, an explicit Stone-type "points ↔ functions" dictionary for the Fibonacci world.

*The key insight is* that a Galois connection always factors as a surjection onto its
closed elements followed by an order-iso, so the messy map `fibRank` is, up to that
iso, just the identity on Fibonacci-shadows — turning divisibility questions about
arbitrary moduli into questions purely about indices.

*Why now?* The adjunction and the fixed-point theorem are already proved this cycle, so
`GaloisConnection.closureOperator` and `OrderIso.ofRangeEq` apply almost mechanically;
the only new content is identifying the closed elements with `range fib`, which
`closure_fixedPoint_iff_isFib` already gives. *Falsifiable:* if `c a = c b` failed to be
equivalent to `fibRank a = fibRank b` for some explicit `a, b` (search `a,b ≤ 50`), the
packaging is wrong.

## Direction 2 — Lucas numbers as a *second* adjoint and a comparison square

Define `lucasRank m` (least `k>0` with `m ∣ L_k`) and prove the analogous adjunction
`lucasRank ⊣ lucas` on `(ℕ, ∣)`. Then build the **comparison square** relating the two:
since `L_n = F_{2n}/F_n` away from small cases, conjecture
`lucasRank m ∣ fibRank m` and pin down the exact ratio (`1` or `2`) via the 2-adic /
mod-`m` parity of `fibRank m`.

*The key insight is* that the Fibonacci–Lucas bridge `F_{2n} = F_n L_n` is precisely a
*morphism of adjunctions* (a natural transformation between the two closure operators), so
the classical "rank of `L` divides twice the rank of `F`" statements are functoriality, not
computation.

*Why now?* The catalog already contains `FibonacciLucasBridge.lean`; combined with the new
abstract adjunction API, the Lucas side is a copy-paste of the pigeonhole existence proof
plus one identity. *Falsifiable:* compute `fibRank m / lucasRank m` for all `m ≤ 200`; the
conjecture predicts the quotient is always `1` or `2`, with the value determined by
`fibRank m mod` a fixed small modulus.

## Direction 3 — Multiplicativity of `fibRank` and an Euler-product / spectral form

Use the join law `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)` (now an adjunction
corollary) plus the prime-power values to obtain a **closed product formula**
`fibRank m = lcm_{p^e ∥ m} fibRank (p^e)`, and conjecture the prime-power recursion
`fibRank (p^{e+1}) = p · fibRank (p^e)` for all `e ≥ E_p` (the wall–sun–sun threshold),
with `E_p = 1` unless `p` is Wall–Sun–Sun.

*The key insight is* that `fibRank` is a *join-homomorphism* out of the divisibility
lattice, so it is determined by its values on the join-irreducibles (prime powers) — exactly
the spectral/representation philosophy: read a lattice map off its action on atoms.

*Why now?* The lcm law is proved this cycle, reducing the whole conjecture to the local
prime-power statement, which is `decide`-checkable for thousands of `(p, e)` and is the only
place the (open) Wall–Sun–Sun question can enter. *Falsifiable:* a single counterexample to
`fibRank (p^{e+1}) = p · fibRank(p^e)` with `p` non-Wall–Sun–Sun and `e ≥ 1` (none known for
`p < 2^64`) would refute it.

## Direction 4 — Closing Carmichael's tail via a `fibRank`-driven primitive-divisor bound

The catalog's `Shared/CarmichaelProof.lean` still has **one open `sorry`**: the infinite
tail `fib_carmichael_composite` for composite `n > 10000`. Attack it through the adjunction:
a prime `p` is a *primitive* divisor of `F_n` iff `fibRank p = n` (immediate from
`fib_dvd_iff_rank_dvd_all`), so primitivity becomes "the closure fixed-point `c p = F_n` has
minimal rank `n`". Combine the cyclotomic factorisation `F_n = ∏_{d ∣ n} Φ_d(φ,ψ)` with the
crude size bound `F_n > ∏_{d ∣ n, d < n} F_d` (provable by Binet growth) to force a prime of
rank exactly `n`.

*The key insight is* that the entire computational `removePrimesOf`/`primPart` machinery in
the catalog is *computing the kernel operator* `fibRank ∘ fib`; replacing the `native_decide`
window by the analytic growth bound `F_n / lcm_{d<n} F_d → ∞` removes the `10000` cutoff.

*Why now?* The primitive-divisor ⇔ `fibRank = n` reformulation is a one-line corollary of
this cycle's `fib_dvd_iff_rank_dvd_all`, and Mathlib has Binet (`Nat.fib` asymptotics via
`Real.goldenRatio`), so the missing step is a single quantitative inequality rather than new
theory. *Falsifiable:* the bound `F_n > ∏_{d∣n, d<n} F_d` for `n ≥ 7` is directly
`decide`-testable on a range and, if false, the proposed route collapses.

## Direction 5 — `padicNorm`/height spectrum of `fibRank` and a Pontryagin-style duality

This cycle kept the Mathlib-native height capstone `padicNorm_fib_lt_one_iff`
(`|F_n|_p < 1 ↔ fibRank p ∣ n`). Push it to the full **valuation spectrum**: prove
`v_p(F_n) = v_p(n / fibRank p) + v_p(F_{fibRank p})` (lifting-the-exponent for Fibonacci)
and read it as a character `ℕ → ℤ_{≥0}` factoring through the rank sublattice — a discrete
Pontryagin pairing between indices and primes.

*The key insight is* that the `p`-adic height of `F_n` is a *bilinear pairing* `(n, p) ↦
v_p(F_n)` whose left kernel is `fibRank p · ℕ`; LTE makes the pairing explicitly computable,
turning "how divisible is `F_n` by `p`" into linear algebra over the rank lattice.

*Why now?* The catalog already has
`Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean`;
feeding it the adjunction's `fibRank p ∣ n` characterisation supplies exactly the index-side
input LTE needs. *Falsifiable:* the LTE formula is an exact integer identity, checkable by
`decide`/`#eval` for all `(p, n)` with `p < 50, n < 200`; any mismatch refutes it.
