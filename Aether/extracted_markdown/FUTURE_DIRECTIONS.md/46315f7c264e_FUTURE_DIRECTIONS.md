# Future Directions — Topological Codes from Exotic Smooth Structures (Cycle 2)

## Synthesis

The previous cycle (`TopologicalCodes.lean`) established the *local* bridge of the
lattice ⇄ code dictionary: double-evenness forces pairwise orthogonality
(`doublyEven_selfOrthogonal`), the code-side mirror of "an even form has even diagonal"
(`IntersectionForms.even_diag_of_isEven`). It exhibited the extended Hamming code
`[8,4,4] = RM(1,3)` as the mod-2 shadow of `E8` and proved it doubly even and
self-orthogonal.

This cycle performs the **local-to-global** upgrade — the configured research core. A
*local* (per-pair, per-coordinate) weight datum is glued, through the canonical all-ones
"global section", into *global* numerical invariants of the whole code:

- **Global length divisibility** (`SelfDualLength.lean`). The theorem
  `selfDual_doublyEven_length_div_four` shows that *any* self-dual doubly-even binary
  code of length `n` has `4 ∣ n`, for arbitrary `n`. The proof is exactly a
  sheaf-style argument: the dual code is the presheaf of orthogonality conditions, the
  all-ones vector is the distinguished global section, and self-duality is the gluing
  axiom that forces its membership — whence `4 ∣ wt(𝟙) = n`. We then prove the
  extended Hamming code is *genuinely self-dual* (`hamming_selfDual`, by a finite
  `native_decide` over its `256`-point ambient space) and recover `4 ∣ 8` as a
  *corollary of the general theorem*, mirroring how `E8`'s obstruction is *derived*
  from `E8_even`.

- **Self-dual ⟹ even weights, unconditionally** (`MinimumDistance.lean`). The theorem
  `selfDual_even_weight` shows every codeword of a self-dual code has even weight,
  because `ip x x = wt x (mod 2)` (using `t² = t` in `ZMod 2`) and self-duality kills
  the diagonal. This is the unconditional companion of the doubly-even hypothesis and
  the code mirror of "a unimodular even form has even diagonal".

- **The distance spectrum** (`MinimumDistance.lean`). We pin the parameters `[8,4,4]`
  (`hamming_minDist_lower`, `hamming_minDist_attained`) and compute the **complete
  weight enumerator** `1 + 14·x⁴ + x⁸` (`hamming_weightEnum_0/4/8`,
  `hamming_weightEnum_complete`: `1 + 14 + 1 = 16`). This is the finite fingerprint the
  next cycle should test against rank-16 lattice pairs.

## Results Summary

| Theorem | Role | Lattice-side analogue |
|---|---|---|
| `selfDual_doublyEven_length_div_four` | **global** length `4 ∣ n` for any self-dual doubly-even code | rank divisible by `8` for even unimodular definite lattices |
| `ip_ones` / `overlap_ones` / `wt_ones` | all-ones global section machinery | distinguished lattice vectors |
| `hamming_selfDual` | Hamming code is self-dual | `E8` unimodular (Poincaré self-duality) |
| `hamming_length_div_four_general` | `4 ∣ 8` as a corollary, not by hand | obstruction derived from evenness |
| `selfDual_even_weight` | self-dual ⟹ even weights (unconditional) | unimodular even form has even diagonal |
| `hamming_minDist_lower/attained` | minimum distance `d = 4` | discriminant/distance spectrum |
| `hamming_weightEnum_*` | enumerator `1 + 14x⁴ + x⁸` complete | theta series of `E8` lattice |

Every proof reduces either to the parity identities `ip_self` / `ip_ones` or to a
finite `native_decide` on the explicit 16-codeword generator image.

## Research Directions

### 1. The Gleason mod-8 jump for self-dual doubly-even codes
We now have the **mod-4** statement `selfDual_doublyEven_length_div_four` for arbitrary
`n`, `sorry`-free. The sharp classical theorem is **mod 8** — the precise code twin of
"even unimodular definite lattices have rank divisible by `8`". **The key insight is**
that the weight enumerator `W_C(x,y)` of a self-dual doubly-even code is fixed by the
order-`8` Gleason–MacWilliams matrix group, whose invariant ring `ℂ[W₈, W₂₄]` is
generated in degrees `8` and `24`; since `W_C` is homogeneous of degree `n`, the only
way to lie in that ring is `8 ∣ n`. **Why now?** Our all-ones glue already yields the
mod-4 step with no analysis; the remaining factor of `2` is a self-contained
generating-function identity in `ℤ[x,y]`, and we have already computed the concrete
enumerator `1 + 14x⁴ + x⁸` (`hamming_weightEnum_complete`) to anchor the base case and
test the MacWilliams transform numerically.

### 2. Construction A as a verified functor `Codes → Lattices`
Build `Λ_C = {v ∈ ℤⁿ : (v mod 2) ∈ C}` and prove `C` doubly-even self-dual ⟺ `Λ_C` even
unimodular, then exhibit the catalog's `E8form` explicitly as `Λ_hamming`. **The key
insight is** that the catalog's `E8mat` (already `decide`-verified even and unimodular in
`IntersectionForms.lean`) is integrally congruent to `½(2I + reduction-of-hammingGen)`,
so the lattice obstruction `even_not_stdDiagonalizable` and the code self-duality
`hamming_selfDual` are literally the *same* mod-2 computation. **Why now?** Both
endpoints exist `sorry`-free in this project (`E8form`, `E8_unimodular`, `hamming`,
`hamming_selfDual`); only the finite, `decide`-able congruence matrix is missing.

### 3. A distance-spectrum separator for the genus
Define `weightEnumerator : Polynomial ℕ` for any finite code and conjecture: rank-equal,
discriminant-equal even unimodular lattices whose *genus* fails to separate them are
separated by the **weight enumerators of their mod-2 codes**. **The key insight is** that
exotic smooth structure is detected by the *fine* arithmetic of the intersection lattice
(not merely its genus), and that arithmetic survives reduction mod 2 precisely as the
distance spectrum we computed (`1 + 14x⁴ + x⁸`). **Why now?** With `hamming` and the full
enumerator already proven, the first nontrivial test — the rank-16 pair `E8 ⊕ E8` vs
`D16⁺` — is a finite `native_decide` comparison of two weight polynomials; a *coincidence*
of enumerators there would falsify the conjecture immediately.

### 4. The Arf/Brown invariant as a combinatorial Rokhlin decoder
Rokhlin: a smooth spin 4-manifold has signature `≡ 0 (mod 16)`. Conjecture: the
Brown–Arf invariant of the `ZMod 2` quadratic refinement `q(x) = wt(x)/2 (mod 2)` on a
self-dual doubly-even code computes the signature `mod 16` of the associated
lattice/manifold. **The key insight is** that our `selfDual_even_weight` makes `wt(x)/2`
a well-defined `ZMod 2`-valued *quadratic* form (its polarization is the bilinear `ip`,
forced to vanish by `doublyEven_selfOrthogonal`), so the Arf invariant is a finite,
`decide`-checkable number that should reproduce the analytic `mod 16` content. **Why
now?** The quadratic refinement's two defining hypotheses — even weights and orthogonal
polarization — are exactly the two general theorems now proven; only the Arf-invariant
definition and its `mod 16` matching remain.

### 5. Minimum-weight subcode as the discrete lowest harmonic sector
Return to the seed conjecture: exotic (homeo-but-not-diffeo) 4-manifolds support
Laplace-type operators with distinct low-energy harmonic sectors. Model the harmonic
sector as the *minimum-weight stratum* `C_{d} = {v ∈ C : wt v = d}` and conjecture that
exotic pairs yield codes with isomorphic ambient space but **non-isometric**
minimum-weight subspaces. **The key insight is** that a discrete Laplacian on `Λ_C` is
graded by weight and its lowest nonzero eigenspace is the combinatorial avatar of the
weight-`d` stratum — so "distinct harmonic sectors" becomes "non-isometric weight-`d`
subcodes". **Why now?** `hamming_minDist_attained` already exhibits the `d = 4` stratum
as a concrete `Finset` of 14 words; the first test case (`E8`-Hamming vs a putative fake)
is an immediately decidable comparison of two finite weight-`d` configurations.
