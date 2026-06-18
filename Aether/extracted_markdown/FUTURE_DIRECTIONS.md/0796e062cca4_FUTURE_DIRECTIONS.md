# Future Directions — Topological Error-Correcting Codes from Exotic Smooth Structures

## Synthesis

The catalog's `SmoothPoincare` files develop the *lattice* side of the smooth /
topological gap in dimension 4: the even unimodular intersection form `E8`
(`E8form`, `E8_even`, `E8_unimodular`), its closure under orthogonal direct sum
(`directSum_isEven`, `directSum_unimodular`, `E8E8_not_stdDiagonalizable`), and the
Donaldson obstruction `even_not_stdDiagonalizable`. The recurring miracle there is the
integer **8**: positive-definite even unimodular lattices exist only in rank divisible
by 8, with `E8` the minimal witness.

This cycle opened the *coding-theory shadow* of that story in
`Catalog/Applications/SmoothPoincare/TopologicalCodes.lean`. Via Construction A (the
reduction of an even unimodular lattice modulo 2), evenness of a form becomes the
**doubly-even** condition on a binary code (all weights divisible by 4), and unimodular
self-duality becomes **self-orthogonality**. We proved, `sorry`-free:

- `wt_add_overlap`: the additive inclusion–exclusion identity
  `wt(x+y) + 2·overlap(x,y) = wt x + wt y`, the combinatorial engine.
- `doublyEven_selfOrthogonal`: **the bridge theorem** — any two doubly-even codewords
  whose sum is doubly even are orthogonal. This is the exact binary mirror of
  "an even form has even diagonal" (`even_diag_of_isEven` / `isEven_of_even_diag`):
  double-evenness *forces* self-orthogonality, just as form-evenness forces the
  Donaldson obstruction.
- The explicit extended Hamming code `[8,4,4] = RM(1,3)` as the mod-2 shadow of `E8`:
  `hamming_card` (16 words), `hamming_add_closed` (linearity), `hamming_doublyEven`
  (analogue of `E8_even`), `hamming_length_div_four` (the all-ones word, weight 8), and
  `hamming_selfOrthogonal` — derived from double-evenness through the bridge theorem
  *without* any pairwise brute force, mirroring how `E8`'s obstruction is derived from
  `E8_even`.

## Results Summary

| Theorem | Role | Lattice-side analogue |
|---|---|---|
| `wt_add_overlap` | weight inclusion–exclusion | symmetric bilinear expansion |
| `ip_eq_overlap` | inner product = overlap parity | Gram pairing mod 2 |
| `doublyEven_selfOrthogonal` | doubly-even ⟹ self-orthogonal | `even_diag_of_isEven` |
| `hamming_doublyEven` | code is doubly even | `E8_even` |
| `hamming_selfOrthogonal` | code is self-orthogonal | `E8` unimodular self-duality |
| `hamming_length_div_four` | all-ones word, weight 8 | signature divisibility (Rokhlin) |

All proofs reduce either to the single arithmetic identity `wt_add_overlap` or to a
`native_decide` on the concrete 16-element generator image.

## Research Directions

### 1. The Gleason "length divisible by 8" theorem for doubly-even self-dual codes
We proved doubly-even self-dual codes force length divisible by **4** (the all-ones word
has weight a multiple of 4). The sharp classical statement is **divisibility by 8** — the
exact code-theoretic twin of "even unimodular definite lattices have rank divisible by 8"
(`E8` minimal). A falsifiable target: formalize that every doubly-even self-dual binary
code has length `≡ 0 (mod 8)`, and that 8 is attained only by the extended Hamming code up
to equivalence. **The key insight is** that the weight enumerator of such a code is fixed
by the order-8 Gleason–MacWilliams transformation group, whose polynomial invariant ring
is generated in degrees 8 and 24 — forcing `8 ∣ n` purely algebraically, with no analysis.
**Why now?** Our `wt_add_overlap` + `doublyEven_selfOrthogonal` already give the mod-4 step
`sorry`-free; the remaining mod-8 jump is a self-contained generating-function identity in
`ℤ[x,y]` that Mathlib's polynomial and `MvPolynomial` invariant-theory API can now carry.

### 2. Construction A as a verified functor: lattices ⇄ codes
Make the analogy a theorem, not a metaphor: build the map `C ↦ Λ_C = {v ∈ ℤⁿ : v mod 2 ∈ C}`
and prove `C` doubly-even self-dual ⟺ `Λ_C` even unimodular, then exhibit `E8form` (the
catalog object) as `Λ_Hamming` explicitly. **The key insight is** that the Gram matrix
`E8mat` (already `decide`-verified even and unimodular in `IntersectionForms.lean`) is, up
to integral congruence, `½·(2·I + reduction-of-Hamming-generators)`, so the lattice and
code obstructions are literally the same `mod 2` computation. **Why now?** Both endpoints
already exist `sorry`-free in this project (`E8form`, `E8_unimodular`, `hamming`); only the
single congruence bridge is missing, and it is a finite `decide`-able matrix identity.

### 3. Minimum distance and the "exotic = correcting" dictionary
Define minimum distance `d(C)` and prove `d(Hamming) = 4`, then state the singular
conjecture driving the whole concept title: the **smooth-structure-distinguishing power** of
a lattice equals the **error-correcting power** of its mod-2 code, i.e. inequivalent even
unimodular lattices of equal rank/discriminant produce codes of strictly different minimum
distance. **The key insight is** that exotic smooth structure on a 4-manifold is detected by
the *fine* arithmetic of the intersection lattice (not just its genus), and that arithmetic
survives reduction mod 2 precisely as the code's distance spectrum. **Why now?** With
`wt` and `hamming` already in place, `d(C)` is a one-line `Finset.min'` definition and the
distance-4 fact is `native_decide`; the conjecture then becomes a sharp, falsifiable
statement testable on the rank-16 pair `E8⊕E8` vs `D16⁺` (the first lattices where the genus
fails to separate but the codes might).

### 4. The signature/syndrome correspondence and a topological decoder
Rokhlin's theorem says a smooth spin 4-manifold has signature divisible by 16; the code
shadow is that the syndrome map of a doubly-even self-dual code is `ℤ/2`-valued with a
distinguished quadratic refinement. Conjecture: the Brown–Arf invariant of the code's
quadratic form computes the signature `mod 16` of the associated lattice/manifold, giving a
*combinatorial decoder* for the smooth signature obstruction. **The key insight is** that the
Arf invariant of the mod-2 quadratic enhancement is exactly the `mod 16` content Rokhlin
extracts analytically, so a purely finite syndrome computation reproduces a gauge-theoretic
divisibility. **Why now?** `doublyEven_selfOrthogonal` supplies the quadratic refinement's
self-orthogonality hypothesis for free, and Mathlib's `ZMod` / quadratic-form API makes the
Arf invariant computable and `decide`-checkable on `hamming`.

### 5. Low-energy harmonic sectors as the weight-zero subspace (the original conjecture)
Return to the seed conjecture: homeomorphic-but-not-diffeomorphic manifolds support
inequivalent Laplace-type operators whose low-energy harmonic sectors differ. Model the
"harmonic sector" as the radical / minimum-weight subcode and conjecture that exotic pairs
yield codes with isomorphic ambient space but non-isometric minimum-weight subspaces.
**The key insight is** that the kernel of a discrete Laplacian on the lattice is graded by
weight, and the smallest nonzero stratum (weight = minimum distance) is the combinatorial
avatar of the lowest nonzero Laplace eigenspace — so "distinct harmonic sectors" becomes
"non-isometric minimum-weight subcodes". **Why now?** This reframes a hard analytic
conjecture as a finite linear-algebra statement already half-built here: `hamming`,
`hamming_doublyEven`, and `ip` give the graded pairing, and the minimum-weight stratum is
a decidable `Finset`, making the first nontrivial case (`E8`-Hamming vs a fake `E8`) an
immediately testable computation.
