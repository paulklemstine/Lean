# Future Directions — Weight / Inner-Product Identities for Binary Self-Dual Codes

This cycle added two `sorry`-free files to the Smooth-Poincaré coding stack:

* `CodeDirectSum.lean` — the orthogonal **direct sum** `C ⊕ D` of binary codes, with
  additivity of weight (`wt_append`) and inner product (`ip_append`), closure of
  self-duality (`dsum_selfDual`) and double-evenness (`dsum_doublyEven`) under `⊕`, a
  computable minimum-distance lower bound (`dsum_minDist_lower`/`..._attained_left`),
  and the headline `[16,8,4]` shadow of `E8 ⊕ E8` (`hammingSq`), whose `8 ∣ 16` is
  recovered from the *general* Gleason theorem.
* `DoublyEvenDistance.lean` — the **minimum-distance criterion**
  `doublyEven_pos_wt_ge_four` (a nonzero doubly-even word has weight `≥ 4`), the mod-2
  weight additivity `wt_add_mod_two`, the divisibility of every pairwise distance in a
  linear doubly-even code (`hdist_doublyEven_of_mem`), and the *structural* `[8,4,4]`
  bounds for the Hamming code (`hamming_minDist_ge_four`, `hamming_hdist_div_four`),
  derived without `native_decide`.

The following conjectures are direct, falsifiable continuations.

## 1. Minimum distance of a direct sum is exactly `min`

**Statement.** For nonzero linear codes `C, D` with minimum distances `d_C, d_D`, the
direct sum `C ⊕ D` has minimum distance exactly `min d_C d_D` (we proved the `≥ min`
lower bound and the `= d_C` attainment from the left summand; the matching upper bound
and a symmetric right-summand attainment complete the equality).

**The key insight is** that `wt (append x y) = wt x + wt y` splits the weight spectrum
of `C ⊕ D` into the *Minkowski sum* of the two spectra, so the smallest nonzero weight
is achieved by putting all the weight in the lighter summand and zero in the other.

**Why now?** `dsum_minDist_lower` and `dsum_minDist_attained_left` already pin three of
the four inequalities; only a one-line symmetric `attained_right` and the trivial upper
bound remain, making this the cheapest sharp follow-up.

## 2. Doubly-even self-dual codes exist only in lengths divisible by 8 — and `hamming^{⊕k}` realises every such length

**Statement.** For every `k`, the `k`-fold direct sum `hamming^{⊕k}` is a doubly-even
self-dual `[8k, 4k, 4]` code; conversely (Gleason) every doubly-even self-dual code has
length `8 ∣ n`, so the direct-sum tower realises exactly the admissible lengths.

**The key insight is** that `dsum_selfDual` and `dsum_doublyEven` make
"doubly-even self-dual" a *monoid* under `⊕` with `hamming` as generator, so feeding the
tower into `doublyEven_selfDual_length_div_eight` turns the lattice-side fact
"`E8^{⊕k}` exhausts ranks `8k`" into its verified code shadow.

**Why now?** `hammingSq = hamming ⊕ hamming` is already proved doubly-even, self-dual,
and `8 ∣ 16`; the only new ingredient is an induction on `k` reusing the same two
closure lemmas, with no new combinatorial input.

## 3. The MacWilliams identity for direct sums multiplies weight enumerators

**Statement.** With `W_C(x,y) = ∑_{c∈C} x^{n-wt c} y^{wt c}` the homogeneous weight
enumerator, `W_{C⊕D} = W_C · W_D`; in particular
`W_{hamming^{⊕k}} = (1 + 14 x⁴ y⁴ + y⁸)^k` (using the catalog's `1 + 14x⁴ + x⁸`).

**The key insight is** that the additivity `wt_append` makes the enumerator a *ring
homomorphism* from the monoid of codes under `⊕` to polynomials under multiplication,
so the Gleason-invariant factor `1 + 14x⁴+x⁸` is literally exponentiated by the tower.

**Why now?** `MinimumDistance.lean` already computes the full enumerator `1+14x⁴+x⁸` of
the single Hamming code, and `wt_append` is now available, so the product law is the
immediate structural lift.

## 4. A divisibility certificate `4 ∣ hdist` upgrades to a packing/Singleton-type bound

**Statement.** Any linear doubly-even code `C ⊆ (ZMod 2)ⁿ` has all pairwise distances in
`4ℕ`; combined with the sphere-packing bound this forces `|C| ≤ 2^{n}/V(n, 1)` with the
`4`-divisibility tightening the achievable rate, recovering `|hamming| = 16 ≤ 2⁸/9`.

**The key insight is** that `hdist_doublyEven_of_mem` promotes the *local* weight
predicate `4 ∣ wt` to a *global* metric constraint (every codeword sits on a `4ℤ`-graded
sphere), so classical packing counts apply to the coarser `4`-spaced metric.

**Why now?** The pairwise-distance divisibility is now a one-line corollary
(`hamming_hdist_div_four`), so the next step is purely the counting/`Finset.card`
estimate, with the hard algebra already discharged.

## 5. The lattice ↔ code dictionary is a functor on direct sums

**Statement.** Construction A sends the orthogonal direct sum of even unimodular lattices
to the direct sum of their doubly-even self-dual codes; i.e. the square

```
(L, M)  ↦  L ⊕ M           (IntersectionForms / DirectSum.lean)
  ↧                ↧
(C_L, C_M) ↦ C_L ⊕ C_M     (CodeDirectSum.lean)
```

commutes, mapping `E8 ⊕ E8` to `hamming ⊕ hamming`.

**The key insight is** that `directSum_isEven`/`directSum_unimodular` (lattice side) and
`dsum_doublyEven`/`dsum_selfDual` (code side) are the *same* closure statement under the
mod-2 reduction, so Construction A is a monoidal functor rather than a coincidence of
two parallel computations.

**Why now?** Both closure halves are now formalised `sorry`-free in adjacent files, so
stating the reduction map and checking the square commutes is the natural unifying
capstone that turns the two stacks into one verified dictionary.
