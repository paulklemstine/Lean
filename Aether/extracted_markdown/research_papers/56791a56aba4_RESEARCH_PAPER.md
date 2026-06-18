# Topological Error-Correcting Codes from Exotic Smooth Structures: The Mod-2 Shadow of Even Unimodular Forms

## Abstract

The smooth/topological gap in four-dimensional manifold theory is governed, on the
algebraic side, by the existence of *even unimodular* intersection forms — most famously
the rank-8 form **E8** — and by Donaldson's diagonalization obstruction. A recurring
arithmetic miracle is the integer **8**: positive-definite even unimodular lattices exist
only in ranks divisible by 8, with E8 the minimal witness. This paper develops the
*coding-theory shadow* of that phenomenon. Via Construction A — the reduction of an even
unimodular lattice modulo 2 — the evenness of a quadratic form becomes the **doubly-even**
condition on a binary code (all weights divisible by 4), and unimodular self-duality
becomes **self-orthogonality**. We prove a single inclusion–exclusion identity for Hamming
weight and derive from it a *bridge theorem* — doubly-even codewords are automatically
orthogonal — that is the exact binary mirror of "an even quadratic form has an even
diagonal." We then exhibit the extended Hamming code [8,4,4] = RM(1,3) as the explicit
mod-2 shadow of E8, establishing its double-evenness, its self-orthogonality (derived from
the bridge theorem without pairwise checking), its closure under addition, its minimum
distance 4, and its complete weight enumerator `1 + 14x⁴ + x⁸`. We also prove the
unconditional general law that every codeword of a self-dual binary code has even weight.
All results are stated over arbitrary length where possible, and every concrete claim about
the Hamming code is established by exhaustive verification over its 16-element codeword set.

**Keywords:** even unimodular lattices, E8, Construction A, self-dual codes, doubly-even
codes, extended Hamming code, Reed–Muller codes, intersection forms, Donaldson's theorem,
weight enumerator, smooth/topological gap.

## 1. Introduction

### 1.1 The lattice side

A closed oriented 4-manifold `M` carries an *intersection form*: the symmetric bilinear
pairing on `H²(M; ℤ)/torsion` given by the cup product. Modeled concretely, it is a
symmetric integer Gram matrix `Q`. Two predicates classify the relevant forms:

- `Q` is **unimodular** if `det Q = ±1` (equivalently, Poincaré duality is perfect);
- `Q` is **even** (or *spin*) if every diagonal entry — every self-pairing `Q(v, v)` — is
  even.

Freedman's classification (1982) shows that, topologically, every unimodular symmetric form
is realized by some simply-connected closed topological 4-manifold. Donaldson's
diagonalization theorem (1983) shows that, *smoothly*, a positive-definite intersection
form must be the standard form `⟨1⟩ⁿ = I_n`. The algebraic obstruction is immediate: an
even positive-rank form can never be congruent over ℤ to `I_n`, because `I_n` has odd
diagonal entries while an even form has even ones. The minimal even unimodular
positive-definite lattice is **E8** (rank 8). Hence E8 is realized topologically but not
smoothly — the cleanest witness of the smooth/topological gap.

The governing arithmetic fact is a theorem of lattice theory: *a positive-definite even
unimodular lattice has rank divisible by 8.* E8 attains the bound.

### 1.2 The code side and the goal of this paper

Construction A relates binary codes and integer lattices. To a binary code
`C ⊆ 𝔽₂ⁿ` one associates the lattice
`Λ_C = { v ∈ ℤⁿ : (v mod 2) ∈ C }`, suitably rescaled. Under this correspondence, the
classical dictionary (Conway–Sloane) reads:

| Lattice property | Code property |
|---|---|
| even | doubly even (all weights `≡ 0 mod 4`) |
| unimodular / self-dual | self-orthogonal / self-dual |
| rank divisible by 8 | length divisible by 8 |
| E8 | extended Hamming code [8,4,4] |

The aim of this paper is to make the *local* part of this dictionary into fully explicit,
exhaustively verified mathematics, and to extract the concrete invariants of E8's shadow
code. We isolate the single combinatorial identity that powers the dictionary, prove the
bridge theorem (double-evenness ⟹ self-orthogonality) from it, and compute the full
distance spectrum of the extended Hamming code.

## 2. Definitions

Throughout, `n : ℕ`, and binary vectors are functions `Fin n → ZMod 2` (i.e. elements of
`𝔽₂ⁿ`). Addition is coordinatewise modulo 2.

**Definition 2.1 (Hamming weight).** The *weight* of `v` is the number of nonzero
coordinates:
`wt(v) = #{ i : v(i) = 1 }`.

**Definition 2.2 (Overlap).** The *overlap* of `x` and `y` is the number of coordinates
where both equal 1:
`overlap(x, y) = #{ i : x(i) = 1 ∧ y(i) = 1 }`.

**Definition 2.3 (Binary inner product).** The *inner product* in `ZMod 2` is
`ip(x, y) = Σᵢ x(i)·y(i) ∈ ZMod 2`.

**Definition 2.4 (Doubly even).** A vector `v` is *doubly even* if `4 ∣ wt(v)`.

**Definition 2.5 (Self-orthogonal / self-dual code).** A code `C ⊆ 𝔽₂ⁿ` is
*self-orthogonal* if `ip(x, y) = 0` for all `x, y ∈ C`. It is *self-dual* if membership in
`C` is *equivalent* to orthogonality to all of `C`:
`x ∈ C ⟺ ∀ y ∈ C, ip(x, y) = 0`.

**Definition 2.6 (Generator and the extended Hamming code).** Let the generator matrix be
the 4×8 binary matrix
```
G = [ 1 1 1 1 1 1 1 1
      0 0 0 0 1 1 1 1
      0 0 1 1 0 0 1 1
      0 1 0 1 0 1 0 1 ]
```
(the all-ones row plus the three "address-bit" coordinate functions). The encoder is
`encode(a)(j) = Σᵢ a(i)·G(i, j)` for a message `a ∈ 𝔽₂⁴`. The **extended Hamming code** is
the image
`Hamming = { encode(a) : a ∈ 𝔽₂⁴ } ⊆ 𝔽₂⁸`.
This is the Reed–Muller code RM(1, 3).

## 3. The combinatorial engine

**Theorem 3.1 (Weight inclusion–exclusion).** For all `x, y ∈ 𝔽₂ⁿ`,
> `wt(x + y) + 2·overlap(x, y) = wt(x) + wt(y).`

*Proof sketch.* Both sides are sums over the `n` coordinates of contributions depending
only on the pair `(x(i), y(i)) ∈ {0,1}²`. Writing each cardinality as a sum of indicator
values and comparing the four cases:
- `(0,0)`: LHS `0 + 0`, RHS `0 + 0`;
- `(1,0)`: sum bit `1`, overlap `0`; LHS `1`, RHS `1`;
- `(0,1)`: symmetric; LHS `1`, RHS `1`;
- `(1,1)`: sum bit `0`, overlap `1`; LHS `0 + 2·1 = 2`, RHS `1 + 1 = 2`.
The per-coordinate contributions agree in every case, so the sums agree. Stating the
identity additively (rather than as `wt(x+y) = wt x + wt y − 2·overlap`) avoids truncated
ℕ-subtraction. ∎

**Theorem 3.2 (Inner product is overlap parity).** For all `x, y`,
> `ip(x, y) = (overlap(x, y) mod 2)` in `ZMod 2`.

*Proof sketch.* A product `x(i)·y(i)` in `ZMod 2` equals `1` exactly when both factors are
`1`, i.e. it is the indicator of the overlap condition. Summing indicators over coordinates
and casting to `ZMod 2` gives the overlap count modulo 2. ∎

**Corollary 3.3 (Self-overlap and diagonal).** `overlap(x, x) = wt(x)`, hence
`ip(x, x) = (wt(x) mod 2)`. The second equality uses idempotence `t² = t` in `ZMod 2`.

## 4. The bridge theorem

**Theorem 4.1 (Doubly even ⟹ orthogonal).** Let `x, y ∈ 𝔽₂ⁿ` with `x`, `y`, and `x + y`
all doubly even. Then `ip(x, y) = 0`.

*Proof sketch.* By Theorem 3.1 (read in ℤ),
`2·overlap(x, y) = wt(x) + wt(y) − wt(x + y)`. By hypothesis `4` divides each of the three
weights on the right, so `4 ∣ 2·overlap(x, y)`, whence `2 ∣ overlap(x, y)`. By Theorem 3.2,
`ip(x, y) = (overlap(x, y) mod 2) = 0`. ∎

**Remark 4.2 (Lattice mirror).** Theorem 4.1 is the exact code-side analogue of the lattice
statement *an even quadratic form has an even diagonal* (`even_diag_of_isEven` /
`isEven_of_even_diag` in the companion `IntersectionForms` development). On the lattice side,
form-evenness forces a Donaldson-type obstruction; on the code side, double-evenness forces
self-orthogonality. In both cases the *global* structural conclusion is **derived** from a
single divisibility datum, never checked element by element.

**Theorem 4.3 (Self-dual ⟹ even weights; unconditional).** Let `C ⊆ 𝔽₂ⁿ` be self-dual
(Definition 2.5) and let `x ∈ C`. Then `wt(x)` is even, i.e. `2 ∣ wt(x)`.

*Proof sketch.* Self-duality applied to `x ∈ C` gives `ip(x, y) = 0` for all `y ∈ C`, in
particular `ip(x, x) = 0`. By Corollary 3.3, `ip(x, x) = (wt(x) mod 2)`, so `wt(x) ≡ 0
(mod 2)`. ∎

This is the unconditional companion of the doubly-even hypothesis and the code mirror of
"a unimodular *even* form has even diagonal." It requires no double-evenness assumption: a
self-dual code already forces even weights, because the binary diagonal pairing *is* the
weight parity.

## 5. The extended Hamming code as the shadow of E8

The following facts about `Hamming` (Definition 2.6) are established by exhaustive
verification over the finite codeword set; proof sketches indicate the underlying reason.

**Theorem 5.1 (Cardinality).** `#Hamming = 16 = 2⁴`.
*Reason.* The encoder is injective on `𝔽₂⁴` (the generator rows are linearly independent),
so the image has `2⁴` elements.

**Theorem 5.2 (Linearity).** `Hamming` is closed under addition: if `x, y ∈ Hamming`, then
`x + y ∈ Hamming`.
*Proof sketch.* The encoder is `𝔽₂`-linear: `encode(a) + encode(b) = encode(a + b)`
coordinatewise (distribute the sum, regroup). Hence the image is an additive subgroup. ∎

**Theorem 5.3 (Double-evenness).** Every `v ∈ Hamming` satisfies `4 ∣ wt(v)`.
*Reason.* Direct enumeration shows every codeword has weight `0`, `4`, or `8`. This is the
code-side analogue of `E8_even`.

**Theorem 5.4 (All-ones glue).** The all-ones word `𝟙 = (1,1,…,1) ∈ 𝔽₂⁸` lies in `Hamming`
(it is `encode(1,0,0,0)`), and it is doubly even with `wt(𝟙) = 8`.
*Significance.* The presence and weight-8 of the all-ones word is the code-side echo of the
signature divisibility behind Rokhlin's and Donaldson's theorems.

**Theorem 5.5 (Self-orthogonality, derived).** For all `x, y ∈ Hamming`, `ip(x, y) = 0`.
*Proof.* `x`, `y`, and (by Theorem 5.2) `x + y` are all in `Hamming`, hence doubly even by
Theorem 5.3. Apply the bridge theorem (Theorem 4.1). No pairwise brute force is used —
self-orthogonality is *derived* from double-evenness, mirroring how E8's Donaldson
obstruction is derived from `E8_even`. ∎

### 5.1 The distance spectrum

**Theorem 5.6 (Minimum distance lower bound).** Every nonzero `v ∈ Hamming` has
`wt(v) ≥ 4`.

**Theorem 5.7 (Attainment).** There exists nonzero `v ∈ Hamming` with `wt(v) = 4` (e.g. the
second generator row `00001111`).

Together, Theorems 5.6–5.7 pin the **minimum distance at 4**, giving the parameter triple
`[n=8, k=4, d=4]`: length 8, dimension 4 (`2⁴ = 16` codewords), minimum distance 4. Such a
code corrects all single-bit errors and detects all double-bit errors.

**Theorem 5.8 (Complete weight enumerator).** The number of codewords of each weight is:
- weight 0: `1` codeword;
- weight 4: `14` codewords;
- weight 8: `1` codeword;
and these exhaust all codewords: `1 + 14 + 1 = 16`. Equivalently, the weight enumerator is
> `W(x, y) = y⁸ + 14 x⁴ y⁴ + x⁸`, i.e. in one variable `1 + 14·x⁴ + x⁸`.

*Reason.* Exhaustive census over the 16 codewords; no weight lies outside `{0, 4, 8}`,
confirming both double-evenness (Theorem 5.3) and the absence of weight-1,2,3 words implied
by minimum distance 4. The enumerator `1 + 14x⁴ + x⁸` is the order-8 Gleason-invariant
weight polynomial of a doubly-even self-dual code of length 8.

## 6. Algorithms

We summarize the constructive content as algorithms.

**Algorithm A (Encoder).** Input: message `a ∈ 𝔽₂⁴`. Output: codeword `c ∈ 𝔽₂⁸`. For each
output position `j ∈ {0,…,7}`, set `c(j) = Σᵢ a(i)·G(i,j) mod 2`. Complexity: `O(k·n)` bit
operations per codeword.

**Algorithm B (Code enumeration and invariants).** Enumerate all `2⁴ = 16` messages, encode
each, and collect the codeword set. From it compute: cardinality, the weight histogram (the
weight enumerator), the minimum nonzero weight (minimum distance), and the full Gram table
`ip(x, y)` to certify self-orthogonality. Complexity: `O(2^k · n)` for the histogram and
`O(2^{2k} · n)` for the full pairwise Gram check (though Theorem 5.5 makes the latter
unnecessary in principle).

**Algorithm C (Bridge-theorem certification).** To certify self-orthogonality *without* the
quadratic pairwise check: verify (i) closure under addition and (ii) that every codeword is
doubly even; then orthogonality of every pair follows from Theorem 4.1. Complexity:
`O(2^k · n)` for double-evenness plus closure verification — linear in the code size rather
than quadratic.

## 7. Applications and discussion

**Construction A as a verified functor.** The most direct consequence is a program to make
the lattice ⇄ code dictionary a theorem rather than a metaphor: construct `Λ_C` from a code
`C`, prove `C` doubly-even self-dual ⟺ `Λ_C` even unimodular, and exhibit `E8form`
explicitly as `Λ_Hamming`. The Gram matrix of E8 is, up to integral congruence,
`½·(2I + reduction-of-Hamming-generators)`, so the lattice obstruction and the code
obstruction are literally the same mod-2 computation.

**The error-correcting interpretation of exotic structure.** Donaldson theory detects the
*fine* arithmetic of the intersection lattice — not merely its genus. The conjecture driving
the program is that this arithmetic survives reduction mod 2 precisely as the *distance
spectrum* of the shadow code, so that the smooth-structure-distinguishing power of a lattice
equals the error-correcting power of its code. The first nontrivial test is the rank-16 pair
E8 ⊕ E8 versus D16⁺ — lattices whose genus fails to separate them, but whose shadow codes may
differ in minimum distance.

**A combinatorial decoder for signature obstructions.** Rokhlin's theorem (smooth spin
4-manifolds have signature divisible by 16) has a code shadow: the syndrome map of a
doubly-even self-dual code carries a distinguished quadratic refinement, whose Brown–Arf
invariant should compute the signature modulo 16 of the associated lattice/manifold. Theorem
5.5 supplies the self-orthogonality hypothesis for that quadratic enhancement for free.

## 8. Future work

1. **Gleason's length-divisible-by-8 theorem.** We establish length divisible by 4 (the
   all-ones word has weight a multiple of 4); the sharp statement is divisibility by 8, the
   twin of "rank divisible by 8" for even unimodular definite lattices. The route is the
   invariant theory of the order-8 Gleason–MacWilliams transformation group, whose invariant
   ring is generated in degrees 8 and 24, forcing `8 ∣ n` algebraically.

2. **Construction A as a verified functor** (Section 7), with `E8form = Λ_Hamming` as a
   finite congruence identity.

3. **Minimum distance and the exotic = correcting dictionary.** Promote the heuristic to a
   sharp, falsifiable conjecture testable on E8 ⊕ E8 versus D16⁺.

4. **The signature/syndrome correspondence**: a topological decoder for the smooth signature
   obstruction via the Brown–Arf invariant of the code's quadratic refinement.

5. **Low-energy harmonic sectors as the minimum-weight subcode.** Model the harmonic sector
   of a discrete Laplacian as the minimum-weight stratum and conjecture that exotic pairs
   yield codes with isomorphic ambient space but non-isometric minimum-weight subspaces —
   reframing a hard analytic conjecture as finite linear algebra.

## 9. Conclusion

A single inclusion–exclusion identity for Hamming weight (`wt(x+y) + 2·overlap = wt x + wt
y`) generates the entire local dictionary between even unimodular lattices and doubly-even
self-dual codes. From it we derive the bridge theorem — double-evenness forces
self-orthogonality — the exact mirror of "an even form has even diagonal," and we exhibit the
extended Hamming code [8,4,4] as the explicit mod-2 shadow of E8, complete with its weight
enumerator `1 + 14x⁴ + x⁸`. The recurring integer 8 is thus revealed as a single arithmetic
phenomenon wearing two costumes: the minimal rank of an even unimodular definite lattice, and
the minimal length of a doubly-even self-dual code.

## References

- S. K. Donaldson, *An application of gauge theory to four-dimensional topology*, J. Diff.
  Geom. 18 (1983).
- M. H. Freedman, *The topology of four-dimensional manifolds*, J. Diff. Geom. 17 (1982).
- J. H. Conway, N. J. A. Sloane, *Sphere Packings, Lattices and Groups* (Construction A,
  Ch. 7).
- F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*.
- A. M. Gleason, *Weight polynomials of self-dual codes and the MacWilliams identities*
  (1971).
