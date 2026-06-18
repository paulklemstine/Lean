# Future Directions: Arithmetic Mirror Symmetry

## Synthesis

The new file `Catalog/Geometry/MirrorSymmetry/ArithmeticMirror.lean` builds a
self-contained, fully-proved (`sorry`-free) skeleton of mirror symmetry that
*unifies* the Hodge-theoretic and arithmetic faces of the subject under a single
combinatorial mechanism: **reflection of a finite index range**. Concretely it
proves, over an arbitrary commutative ring `R`:

* `eulerChar_mirror` — reflecting the first Hodge index scales the Euler
  characteristic by `(-1)^n`;
* `eulerChar_mirror2`, `eulerChar_transpose`, `eulerChar_double_reflection` — the
  three reflections (first index, second index, transpose) generate a symmetry
  group acting on `χ` through the sign character, so `χ` is a group invariant up
  to sign;
* `eulerChar_mirror_threefold`, `mirror_swaps_hodge_threefold` — the threefold
  specialization `χ(Y) = -χ(X)` and the `h^{1,1} ↔ h^{2,1}` exchange;
* `projectiveSpace_zeta_functional_equation` — the Weil functional equation for
  `ℙⁿ` as a division-free polynomial identity, valid over any `CommRing`;
* `functional_equation_sign_vs_euler_sign` — the bridge `(-1)^{n+1} = -(-1)^n`
  identifying the functional-equation sign and the Euler sign;
* `projHodge_eulerChar`, `pointCount_congr_eulerChar` — `χ(ℙⁿ) = n+1` and the
  cross-domain congruence `#ℙⁿ(𝔽_q) ≡ χ(ℙⁿ) (mod q-1)`.

The unifying observation is that *every* statement above is an instance of
`Finset.sum_range_reflect` / `Finset.prod_range_reflect` applied to a
sign-weighted alternating object. This is what makes the skeleton ring-valued and
therefore portable to the stringy (ℚ-valued) and motivic settings.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `eulerChar_mirror` | `χ(mirror Y) = (-1)^n χ(X)` over any `CommRing` | proved |
| `eulerChar_mirror2` | second-index reflection scales `χ` by `(-1)^n` | proved |
| `eulerChar_transpose` | `χ` invariant under `h^{p,q} ↦ h^{q,p}` (no hypotheses) | proved |
| `eulerChar_double_reflection` | both reflections compose to identity on `χ` | proved |
| `eulerChar_mirror_threefold` | `χ(Y) = -χ(X)` for `n=3` | proved |
| `projectiveSpace_zeta_functional_equation` | Weil FE for `ℙⁿ`, division-free, any ring | proved |
| `functional_equation_sign_vs_euler_sign` | `(-1)^{n+1} = -(-1)^n` | proved |
| `projHodge_eulerChar` | `χ(ℙⁿ) = n+1` | proved |
| `pointCount_congr_eulerChar` | `#ℙⁿ(𝔽_q) ≡ χ(ℙⁿ) (mod q-1)` | proved |

## Research Directions

### 1. The diamond reflection group is exactly the Klein four-group acting through the sign character

The three reflections proved here (first-index mirror, second-index mirror,
transpose) are involutions; the two index reflections commute and their composite
is `eulerChar_double_reflection`. **Conjecture:** the subgroup of `Sym` they
generate is `ℤ/2 × ℤ/2`, the transpose is the diagonal element, and the induced
action on `χ` factors through a single homomorphism `(ℤ/2)² → {±1}` sending each
index reflection to `(-1)^n` and the transpose to `+1`; consequently `χ` is the
unique-up-to-scale alternating invariant of this action.

The key insight is that the parity datum `(-1)^n` is a *one-dimensional
character* of the reflection group, so all sign bookkeeping in the file is the
evaluation of that one character — making `χ` an equivariant invariant rather
than a coincidence of three separate computations.

Why now? `eulerChar_mirror`, `eulerChar_mirror2`, `eulerChar_transpose`, and
`eulerChar_double_reflection` already pin down the value of the character on every
generator; closing the conjecture is a finite group-presentation check plus one
`MonoidHom` packaging, with no new analytic input.

### 2. Stringy / ℚ-valued Hodge diamonds satisfy the same Euler exchange verbatim

Batyrev–Dais stringy Hodge numbers are `ℚ`-valued corrections of ordinary ones.
**Conjecture:** for any `h : ℕ → ℕ → ℚ` (the stringy diamond), the stringy Euler
characteristic computed by the *same* `eulerChar` satisfies
`eulerChar n (mirror n h) = (-1)^n · eulerChar n h`, and the topological mirror
test `h^{p,q}_{st}(X) = h^{n-p,q}_{st}(Y)` implies pairwise cancellation of the
correction terms under reflection.

The key insight is that `eulerChar` and `eulerChar_mirror` were deliberately
stated over an arbitrary `CommRing`, so the `ℚ`-valued stringy theorem is *already
an instance* of the proved theorem — no re-proof is needed, only a definitional
specialization plus the cancellation lemma.

Why now? The ring-generality is in place today; the only genuinely new content is
defining the correction support set and proving its reflection-invariance, a pure
`Finset` bijection argument analogous to `projHodge_eulerChar`.

### 3. Multiplicativity of the functional equation for products `ℙ^{n₁} × ⋯ × ℙ^{n_k}`

**Conjecture:** the zeta denominator of a product of projective spaces is the
product of the factors' denominators, and its functional equation is the product
of the factor functional equations, with reflection exponent `N = Σ nᵢ` and sign
`∏ (-1)^{nᵢ+1} = (-1)^{Σ(nᵢ+1)}`; equivalently the reciprocal-root multiset of
the product is the Minkowski sum of the factor multisets.

The key insight is that `projectiveSpace_zeta_functional_equation` is a pure
`Finset.prod` identity, and products of zeta denominators multiply factorwise, so
the global functional equation factors through the single-factor identity via
`Finset.prod_mul_distrib`.

Why now? The base identity is proved over an arbitrary ring and the sign is
already isolated as `(-1)^{n+1}`; the product case needs only the distributivity
lemma and a `Finset.prod` over the factor index set, both elementary.

### 4. The mod-`(q-1)` congruence upgrades to a mod-`(q-1)²` "Picard-rank" refinement

`pointCount_congr_eulerChar` shows `#ℙⁿ(𝔽_q) ≡ χ(ℙⁿ) (mod q-1)`. **Conjecture:**
the next-order term is governed by the Picard rank: writing
`#ℙⁿ(𝔽_q) = Σ qⁱ`, one has
`#ℙⁿ(𝔽_q) − (n+1) ≡ \binom{n+1}{2}(q−1) (mod (q−1)²)`, and for a mirror pair the
*difference* of these second-order terms is exactly the `h^{1,1} − h^{2,1}`
exchange detected by `mirror_swaps_hodge_threefold`.

The key insight is that `q^i − 1 = (q−1)(q^{i-1}+⋯+1)` and the inner sum is itself
`≡ i (mod q−1)`, so the second-order coefficient is `Σ i = \binom{n+1}{2}`, tying
the arithmetic refinement directly to a Hodge-number count.

Why now? The first-order statement and the divisibility engine
(`sub_dvd_pow_sub_pow`, `Finset.dvd_sum`) are already in the file; the refinement
is one more application of the same geometric-series factorization plus a
`Finset.sum_range_id` evaluation.

### 5. Modularity-compatible sign for rigid Calabi–Yau threefolds is a theorem, not a hypothesis

The deepest prediction is that a rigid CY threefold (`h^{2,1}=0`) is modular of
weight `4`. **Conjecture:** the functional-equation sign forced by the model,
namely `(-1)^{n+1}` at `n=3`, equals `+1`, which is precisely the sign in the
functional equation of a weight-`4` modular form; and via
`functional_equation_sign_vs_euler_sign` this `+1` is exactly the negation of the
threefold Euler sign `-1` from `eulerChar_mirror_threefold`, so the two signs are
*not independent inputs* but one datum.

The key insight is that the modularity-compatible sign is the value of the parity
character of direction 1 at `n=3`, so "compatibility" is the already-proved
identity `(-1)^{n+1} = -(-1)^n` evaluated at a point — a machine-checked
compatibility statement between the arithmetic and Hodge-theoretic sides.

Why now? Both signs are now formal theorems in the file; equating them is the
finite evaluation `(-1)^4 = 1` and `(-1)^3 = -1`, giving the first end-to-end
formal compatibility check while the genuine modularity statement remains far off.
