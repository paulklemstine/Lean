# Hodge Diamonds, Mirror Involution, and the F-Theory Euler Formula for Calabi–Yau Fourfolds

## Abstract

We give a complete, exact, integer-combinatorial account of the Hodge
diamond of a smooth Calabi–Yau fourfold (complex dimension `n = 4`). After
imposing Hodge symmetry, Serre duality, and the Calabi–Yau vanishing
conditions, the diamond is determined by four independent Hodge numbers
`h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}`. We establish five results about this
structure. First, the topological Euler characteristic of the diamond is
the explicit linear form `χ = 4 + 2h^{1,1} + 2h^{3,1} + h^{2,2} − 4h^{2,1}`,
obtained purely combinatorially as the signed sum over the `5 × 5` index
grid. Second, the mirror reflection of the first Hodge index, `p ↦ n − p`,
coincides on the support `p, q ≤ 4` with the diamond obtained by exchanging
`h^{1,1} ↔ h^{3,1}` (with `h^{2,1}, h^{2,2}` fixed): the F-theory mirror
map. Third, that exchange is an involution, realizing a `ℤ/2` action.
Fourth, because `n = 4` is even — so the mirror sign `(−1)^n = +1` — the
Euler characteristic is mirror-invariant, `χ(\text{mirror } X) = χ(X)`, in
sharp contrast to the threefold sign flip `χ ↦ −χ`. Fifth, under the
Klemm–Lian–Roan–Yau Chern-class relation `h^{2,2} = 2(22 + 2h^{1,1} +
2h^{3,1} − h^{2,1})`, the Euler characteristic collapses to the celebrated
F-theory formula `χ = 6(8 + h^{1,1} + h^{3,1} − h^{2,1})`. All statements
hold as identities for arbitrary integer values of the Hodge numbers and
are formally verified. The development extends a combinatorial
mirror-symmetry framework from threefolds to fourfolds, realizing the
"higher-dimensional Hodge-diamond classification" direction of the
arithmetic mirror-symmetry program.

**Keywords.** Calabi–Yau fourfold, Hodge diamond, mirror symmetry, Euler
characteristic, F-theory, Klemm–Lian–Roan–Yau relation, Serre duality.

---

## 1. Introduction

Calabi–Yau manifolds are compact Kähler manifolds with trivial canonical
bundle; they are the geometric backbone of string-theoretic
compactification. The cohomological invariants of such a manifold are
organized in its **Hodge diamond**, the array of Hodge numbers `h^{p,q} =
\dim_{ℂ} H^q(X, Ω^p_X)` for `0 ≤ p, q ≤ n`, where `n = \dim_{ℂ} X`. Three
general symmetries constrain the diamond:

- **Hodge symmetry:** `h^{p,q} = h^{q,p}` (complex conjugation on Dolbeault
  cohomology);
- **Serre duality:** `h^{p,q} = h^{n-p, n-q}`;
- **Calabi–Yau vanishing:** `h^{0,0} = h^{n,0} = 1` and `h^{p,0} = 0` for
  `0 < p < n` (triviality of the canonical bundle plus simple
  connectedness).

For threefolds (`n = 3`) these reduce the diamond to the two free numbers
`h^{1,1}` and `h^{2,1}`, and mirror symmetry famously exchanges them. The
present paper carries the same program to **fourfolds** (`n = 4`), where the
diamond is governed by **four** free numbers, and isolates the exact
combinatorics of the Euler characteristic, the mirror involution, and its
interaction with the Klemm–Lian–Roan–Yau (KLRY) Chern-class relation.

This work extends a catalog framework — referred to here as
`ArithmeticMirror` — which provides a dimension-`n` Euler-characteristic
functional `eulerChar n h` (the alternating double sum over a Hodge array
`h : ℕ → ℕ → ℤ`), a mirror reflection `mirror n h` (reflection of the first
index), and the general invariance theorem `eulerChar_mirror`:
`eulerChar n (mirror n h) = (−1)^n · eulerChar n h`. From this catalog we
inherit, at `n = 3`, the threefold sign flip; our contribution is the full
`n = 4` story.

All results are stated for arbitrary integer Hodge numbers, i.e. they are
identities in the polynomial ring `ℤ[h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}]`,
and have been formally verified. We use `ℤ` rather than `ℕ` so that the
algebra (signed sums, substitutions) is unobstructed; positivity of genuine
Hodge numbers is an orthogonal constraint that plays no role in the
identities.

---

## 2. Definitions

### 2.1 The four free Hodge numbers

We package the independent data of a Calabi–Yau fourfold's diamond into a
four-integer record.

> **Definition 2.1 (CY4 data).** A `CY4` consists of four integers
> `(h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}) ∈ ℤ^4`:
> - `h^{1,1}` — Kähler / divisor moduli;
> - `h^{2,1}` — mixed deformation number;
> - `h^{3,1}` — complex-structure moduli;
> - `h^{2,2}` — the central Hodge number.

### 2.2 The full diamond

The remaining entries of the diamond are reconstructed from the four free
numbers and the three symmetries. We record this as a function on the index
grid.

> **Definition 2.2 (Diamond).** For `X : CY4`, the **diamond**
> `X.diamond : ℕ → ℕ → ℤ` is defined on `0 ≤ p, q ≤ 4` by
>
> | `(p,q)` | value | reason |
> |---|---|---|
> | `(0,0), (4,4), (0,4), (4,0)` | `1` | CY corners (`h^{0,0}`, Serre dual, holomorphic 4-form) |
> | `(1,1), (3,3)` | `h^{1,1}` | `(3,3)` by Serre duality |
> | `(3,1), (1,3)` | `h^{3,1}` | `(1,3)` by Hodge symmetry |
> | `(2,2)` | `h^{2,2}` | center |
> | `(2,1), (1,2), (2,3), (3,2)` | `h^{2,1}` | Hodge symmetry + Serre duality |
> | all other `(p,q)` | `0` | CY vanishing / padding |
>
> Values with `p > 4` or `q > 4` are padding `0` and carry no geometric
> meaning.

The table is exactly the diamond drawn in the companion article. Note that
the four entries equal to `h^{2,1}` all sit at total degree `p + q = 3`
(odd), while the `h^{1,1}` and `h^{3,1}` entries sit at degree `2` and `4`
respectively (even), and `h^{2,2}` at degree `4` (even). This parity
bookkeeping drives the Euler characteristic.

### 2.3 The Euler-characteristic functional

We use the catalog functional, instantiated at `n = 4`:
`eulerChar 4 h = Σ_{p=0}^{4} Σ_{q=0}^{4} (−1)^{p+q} · h(p,q)`,
the signed sum over the `5 × 5` grid. For a genuine Hodge diamond this is
the topological Euler characteristic `χ(X) = Σ_{p,q} (−1)^{p+q} h^{p,q}`.

### 2.4 The mirror map on free data

> **Definition 2.3 (Swap).** The **mirror exchange** `swap : CY4 → CY4`
> sends `(h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}) ↦ (h^{3,1}, h^{2,1}, h^{1,1},
> h^{2,2})`: it interchanges `h^{1,1}` and `h^{3,1}` and fixes the other
> two.

We also use the catalog **diamond-level mirror** `mirror 4 h`, the
reflection of the first Hodge index `p ↦ 4 − p` (with the usual ℕ-truncated
subtraction), which acts on the whole array `h : ℕ → ℕ → ℤ`.

---

## 3. Main results

Throughout, `X : CY4` is arbitrary; all identities hold for every integer
assignment of the four Hodge numbers.

### 3.1 The Euler characteristic

> **Theorem 3.1 (Euler characteristic of the diamond).**
> `eulerChar 4 X.diamond = 4 + 2·h^{1,1} + 2·h^{3,1} + h^{2,2} − 4·h^{2,1}.`

*Proof sketch.* Expand the alternating double sum over `p, q ∈ {0,…,4}`
into its `25` terms. Each term `(−1)^{p+q} · X.diamond(p,q)` is read off the
table of Definition 2.2. The four corners contribute `+1` each (`p+q ∈
{0,8,4,4}`, all even), giving `+4`. The two `h^{1,1}` entries at `(1,1)` and
`(3,3)` have `p+q ∈ {2,6}` (even), giving `+2h^{1,1}`. The two `h^{3,1}`
entries at `(3,1),(1,3)` have `p+q = 4` (even), giving `+2h^{3,1}`. The
center `(2,2)` has `p+q = 4` (even), giving `+h^{2,2}`. The four `h^{2,1}`
entries at `(2,1),(1,2),(2,3),(3,2)` have `p+q ∈ {3,3,5,5}` (all odd),
giving `−4h^{2,1}`. All remaining entries are `0`. Collecting,
`χ = 4 + 2h^{1,1} + 2h^{3,1} + h^{2,2} − 4h^{2,1}`. ∎

This is unconditional: no Chern-class input is used, only the diamond's
combinatorics.

### 3.2 The mirror map exchanges `h^{1,1}` and `h^{3,1}`

> **Theorem 3.2 (Mirror = swap on the support).** For all `p, q ≤ 4`,
> `mirror 4 X.diamond (p, q) = X.swap.diamond (p, q).`

*Proof sketch.* By definition `mirror 4 X.diamond (p,q) = X.diamond(4−p,
q)`. Both sides vanish off the support, so it suffices to check the finitely
many pairs `p, q ∈ {0,…,4}`. For each, `4 − p` is computed and
`X.diamond(4−p, q)` is read off Definition 2.2; the result matches the
corresponding entry of `X.swap.diamond`, in which `h^{1,1}` and `h^{3,1}`
have been interchanged. For instance, at `(1,1)`: `X.diamond(3,1) = h^{3,1}`
on the left, and `X.swap.diamond(1,1) = (X.swap).h^{1,1} = h^{3,1}` on the
right. A finite case check over the `25` pairs closes the proof (in the
formalization, `interval_cases` on `p` and `q` followed by `rfl`). ∎

The restriction to the support is essential: outside `p, q ≤ 4` the
ℕ-truncated reflection `4 − p` saturates at `0`, so the diamond-level
mirror and the swapped diamond disagree on padding entries. On the
geometrically meaningful support they agree exactly — this is the precise
sense in which the index reflection *is* the F-theory mirror map `h^{1,1}
↔ h^{3,1}`.

### 3.3 The mirror is an involution

> **Theorem 3.3 (Involution).** `X.swap.swap = X`.

*Proof sketch.* `swap` interchanges the first and third fields and fixes the
second and fourth; applying it twice returns each field to its original
value. ∎

Thus the fourfold mirror generates a `ℤ/2` action on `CY4` data, a perfect
reflection.

### 3.4 Mirror invariance of the Euler characteristic

> **Theorem 3.4 (Swap invariance).**
> `eulerChar 4 X.swap.diamond = eulerChar 4 X.diamond`.

*Proof sketch.* By Theorem 3.1 applied to both `X` and `X.swap`,
`eulerChar 4 X.swap.diamond = 4 + 2(X.swap.h^{1,1}) + 2(X.swap.h^{3,1}) +
(X.swap.h^{2,2}) − 4(X.swap.h^{2,1}) = 4 + 2h^{3,1} + 2h^{1,1} + h^{2,2} −
4h^{2,1}`, which equals `eulerChar 4 X.diamond` because `h^{1,1}` and
`h^{3,1}` appear with the *same* coefficient `2`. ∎

> **Theorem 3.5 (Catalog form of mirror invariance).** For any array `h :
> ℕ → ℕ → ℤ`,
> `eulerChar 4 (mirror 4 h) = eulerChar 4 h`.

*Proof sketch.* Specialize the catalog theorem `eulerChar n (mirror n h) =
(−1)^n · eulerChar n h` to `n = 4`; since `(−1)^4 = 1`, the prefactor is
`1`. ∎

**Remark (parity is the whole story).** For threefolds, the same catalog
theorem at `n = 3` gives `(−1)^3 = −1`, hence the celebrated sign flip
`χ(\text{mirror } X) = −χ(X)`. The qualitative difference between the
threefold and fourfold mirror — sign reversal versus exact invariance — is
governed entirely by the parity of the complex dimension through the factor
`(−1)^n`. Theorems 3.4 and 3.5 are two faces of the same fact: 3.4 is the
explicit-formula proof (the swapped numbers share a coefficient), while 3.5
is the structural specialization of the general catalog invariance.

### 3.5 The F-theory Euler formula

> **Theorem 3.6 (Klemm–Lian–Roan–Yau / F-theory formula).** Suppose the
> central Hodge number satisfies the KLRY Chern-class relation
> `h^{2,2} = 2·(22 + 2h^{1,1} + 2h^{3,1} − h^{2,1})`. Then
> `eulerChar 4 X.diamond = 6·(8 + h^{1,1} + h^{3,1} − h^{2,1})`.

*Proof sketch.* Substitute the KLRY value of `h^{2,2}` into Theorem 3.1:
```
χ = 4 + 2h^{1,1} + 2h^{3,1} + [44 + 4h^{1,1} + 4h^{3,1} − 2h^{2,1}] − 4h^{2,1}
  = 48 + 6h^{1,1} + 6h^{3,1} − 6h^{2,1}
  = 6·(8 + h^{1,1} + h^{3,1} − h^{2,1}).
```
∎

The KLRY relation originates from the genus-one part of the Chern character
of a Calabi–Yau fourfold (the integral `χ = Σ (−1)^i b_i` re-expressed via
`∫_X c_4` and the relations among `c_1 = 0`, `c_2`, `c_3`, `c_4`). The
identity above is the bridge between the bare combinatorial Euler form and
the working F-theory expression: it shows that on the KLRY-constrained
locus the Euler characteristic depends on only three of the four Hodge
numbers, is always divisible by `6`, and is symmetric under the mirror swap
`h^{1,1} ↔ h^{3,1}` (consistent with Theorem 3.4).

---

## 4. Algorithms

The results are constructive and computable; we record the two core
algorithms.

### 4.1 Diamond assembly and Euler characteristic

Given the four free numbers, build the `5 × 5` diamond and compute the
signed sum. Both run in constant time for fixed `n = 4` (a `25`-entry grid);
for general `n` the cost is `O(n^2)` entries.

```
function EULER_CHAR_CY4(h11, h21, h31, h22):
    diamond ← assemble 5×5 grid per Definition 2.2
    chi ← 0
    for p in 0..4:
        for q in 0..4:
            chi ← chi + (−1)^(p+q) · diamond[p][q]
    return chi                       # == 4 + 2h11 + 2h31 + h22 − 4h21
```

### 4.2 Mirror exchange and KLRY collapse

```
function MIRROR(h11, h21, h31, h22):
    return (h31, h21, h11, h22)      # swap h11 ↔ h31

function EULER_CHAR_KLRY(h11, h21, h31):
    h22 ← 2 · (22 + 2·h11 + 2·h31 − h21)     # KLRY relation
    return 6 · (8 + h11 + h31 − h21)         # == EULER_CHAR_CY4(h11,h21,h31,h22)
```

---

## 5. Applications

1. **F-theory tadpole counting.** In F-theory on an elliptically fibered
   Calabi–Yau fourfold, the D3-brane tadpole condition is `N_{D3} +
   \tfrac12 \int G \wedge G = χ/24`. Theorem 3.6 gives `χ/24 = (8 + h^{1,1}
   + h^{3,1} − h^{2,1})/4`, a clean expression in the moduli numbers, and
   the divisibility of `χ` by `6` is the first integrality input to these
   counting constraints.

2. **Landscape organization.** Because the mirror swap `h^{1,1} ↔ h^{3,1}`
   preserves `χ` (Theorem 3.4), mirror pairs of fourfolds carry the same
   tadpole budget. This halves certain enumeration tasks over the fourfold
   landscape: one need only catalog representatives modulo the `ℤ/2` mirror
   involution (Theorem 3.3).

3. **Consistency checks for constructions.** Any explicit Calabi–Yau
   fourfold (toric hypersurface, complete intersection, fibration) must
   satisfy Theorem 3.1; comparing a computed `χ` against `4 + 2h^{1,1} +
   2h^{3,1} + h^{2,2} − 4h^{2,1}` is a fast sanity check, and against
   `6(8 + h^{1,1} + h^{3,1} − h^{2,1})` tests consistency with the KLRY
   relation.

---

## 6. Discussion

The development is notable for being *exact integer combinatorics*: every
statement is an identity in the four Hodge variables, with no analytic
approximation. This sharpness is possible because the Hodge diamond, after
the three symmetries, is a finite linear-algebraic object. The contrast
with the threefold case is conceptually clean and entirely accounted for by
the dimension parity: the catalog invariance `eulerChar n (mirror n h) =
(−1)^n eulerChar n h` produces the threefold sign flip at the odd dimension
`n = 3` and the fourfold invariance at the even dimension `n = 4`. The two
proofs of fourfold invariance (Theorems 3.4 and 3.5) — one by explicit
formula, one by specializing the general catalog theorem — agree, providing
internal cross-validation.

A subtlety worth emphasizing is the *support restriction* in Theorem 3.2.
Because the diamond is defined by a finite case table padded with zeros, and
because the index reflection uses ℕ-truncated subtraction, the
diamond-level mirror and the swapped diamond agree only where it matters,
on `p, q ≤ 4`. Stating the mirror correspondence pointwise on the support
is therefore the correct and honest formulation, mirroring the analogous
treatment of `mirror_mirror_h` in the threefold catalog.

---

## 7. Future directions

The broader program reads the same operators through complementary lenses;
the following directions were articulated in the companion research cycle
and are reproduced here.

The fifth cycle established *pointwise convergence* of the gradient
message-passing layer `T = 1 − α·L` to the harmonic (cohomology) subspace,
viewing `T` analytically: it decays residual energy geometrically at the
spectral rate while transporting the harmonic part untouched. A subsequent
cycle re-reads that same operator through a **duality / representation**
lens. The unifying observation is that `T` is a degree-one polynomial in the
single operator `L`, so it lives inside the commutative algebra `ℝ[L]`, and
every analytic fact acquires an algebraic dual:

- **Spectral representation.** `T` and all of its depth iterates `T^k` are
  scalars on each eigenspace of `L`: `T x = (1 − αλ)x`, `T^k x = (1 −
  αλ)^k x`. Message passing is the Laplacian in its own eigenbasis, and the
  energy of an eigenmode is exactly `(1 − αλ)^{2k}` of its start —
  convergence becomes an identity, not a bound.
- **Simultaneous diagonalization.** `L∘T = T∘L`: every harmonic / spectral
  projector commutes with each layer.
- **Adjoint duality.** Symmetry of `L` lifts to `T`: the layer is its own
  dual under the Riesz pairing.
- **Fixed-point ↔ kernel duality.** For `α ≠ 0`, `T x = x ⇔ L x = 0`, and
  as submodules `ker(T − 1) = ker L`. Composed with `harmonic_iff`, this
  represents Hodge cohomology as exactly the invariants of the dynamics.

Specific open directions for the Hodge-diamond program of this paper:

1. **Higher-dimensional classification.** Extend the exact Euler/mirror
   combinatorics to Calabi–Yau fivefolds and beyond, tracking how the
   number of free Hodge numbers grows and how the mirror permutation of the
   diagonal `h^{p,p}` behaves with dimension parity.
2. **Full spectral-mapping theorem.** Establish the exact set identity
   `spec(T) = 1 − α·spec(L)` in finite dimension, upgrading the forward
   eigen-correspondence to a bijection of spectra.
3. **Refined Chern relations.** Incorporate the full suite of Chern-class
   constraints (beyond KLRY) to characterize which integer four-tuples
   `(h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2})` are realized by actual smooth
   Calabi–Yau fourfolds, turning the identities here into a Diophantine
   classification.
4. **Mirror-quotient enumeration.** Build explicit catalogs of fourfold
   Hodge data modulo the `ℤ/2` mirror involution, exploiting Theorem 3.4 to
   compress F-theory landscape scans.

---

## 8. Conclusion

The Hodge diamond of a Calabi–Yau fourfold is governed by four integers,
its Euler characteristic by one linear form, its mirror symmetry by a single
swap, and — on the KLRY-constrained locus — its topology by one F-theory
formula. We have made each of these statements an exact identity, valid for
all integer Hodge data, and shown that the entire qualitative gap between
the threefold (sign-flipping) and fourfold (invariant) mirror is the parity
of the complex dimension. The result is a small but complete and rigorously
verified corner of the arithmetic mirror-symmetry program, ready to support
the higher-dimensional and Diophantine extensions outlined above.
