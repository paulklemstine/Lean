# Hodge Diamonds of Calabi–Yau Fourfolds: Mirror Exchange, Even-Dimensional Euler Invariance, and the KLRY Formula

## Abstract

We give a complete, exact, and self-contained combinatorial treatment of the
Hodge diamond of a smooth Calabi–Yau fourfold. After imposing Hodge symmetry,
Serre duality, and the Calabi–Yau vanishing conditions, the full `5×5` integer
diamond is parameterized by four independent Hodge numbers
`(h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2})`. Working over a general combinatorial
Euler-characteristic functional defined on arbitrary diamonds, we prove five
results. First, the topological Euler characteristic of the fourfold diamond is
the explicit affine form `χ = 4 + 2h^{1,1} + 2h^{3,1} + h^{2,2} − 4h^{2,1}`,
obtained by pure cancellation in the alternating double sum, with no curvature
input. Second, the mirror reflection of the first Hodge index `p ↦ n − p`, when
specialized to `n = 4`, coincides on the diamond's support with the diamond of
the fourfold whose `h^{1,1}` and `h^{3,1}` have been exchanged — the F-theory
mirror map — and this exchange is an involution. Third, because `n = 4` is even,
the global mirror sign `(−1)^n = +1`, so the Euler characteristic is
mirror-*invariant*, in sharp contrast with the threefold sign flip
`χ ↦ −χ`. Fourth, this invariance is recovered as the `n = 4` shadow of the
general "mirror Euler relation" `χ(mirror) = (−1)^n · χ`. Fifth, under the
Klemm–Lian–Roan–Yau Chern-class relation
`h^{2,2} = 2(22 + 2h^{1,1} + 2h^{3,1} − h^{2,1})`, the Euler characteristic
collapses to the celebrated F-theory formula `χ = 6(8 + h^{1,1} + h^{3,1} −
h^{2,1})`. All results are exact integer (more generally commutative-ring)
identities and are stated entirely in terms of the four free Hodge numbers.

**Keywords.** Calabi–Yau fourfold, Hodge diamond, mirror symmetry, Euler
characteristic, F-theory, Klemm–Lian–Roan–Yau formula, Serre duality.

---

## 1. Introduction

Mirror symmetry, discovered in string theory and now a central theme of complex
and symplectic geometry, predicts that Calabi–Yau manifolds occur in pairs
`(X, Y)` whose Hodge diamonds are reflections of one another, exchanging Kähler
and complex-structure moduli. For threefolds (`n = 3`) the canonical numerical
shadow is the exchange `h^{1,1} ↔ h^{2,1}` and the Euler-characteristic sign flip
`χ(Y) = −χ(X)`. For fourfolds (`n = 4`) — the geometric arena of F-theory — the
situation differs in two essential ways: the relevant exchange is
`h^{1,1} ↔ h^{3,1}`, and the Euler characteristic is *preserved* rather than
negated.

This paper isolates the purely combinatorial core of these statements and proves
them as exact identities. We build on a general combinatorial mirror-symmetry
skeleton — an Euler-characteristic functional `eulerChar` on arbitrary diamonds
`h : ℕ → ℕ → R` (with `R` any commutative ring), a mirror reflection operator,
and the general relation `χ(mirror) = (−1)^n χ` — and specialize and extend it to
the fourfold. The principal payoff is conceptual clarity: we can see precisely
which facts are *shallow* (consequences of the diamond symmetries and the
alternating sign, valid over any ring) and which are *deep* (requiring genuine
geometric input, here the single Chern-class relation of Klemm–Lian–Roan–Yau).

The recurring slogan, borne out by every proof, is that **the parity of the
complex dimension is the entire mechanism** behind the threefold/fourfold
dichotomy: the mirror multiplies `χ` by `(−1)^n`, so odd `n` flips the sign and
even `n` preserves it.

### 1.1 Contributions

1. A four-parameter integer model `CY4` of the Calabi–Yau fourfold Hodge
   diamond, with the diamond reconstructed explicitly from
   `(h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2})` via Hodge symmetry, Serre duality, and
   CY vanishing (Section 3).
2. The exact Euler-characteristic formula
   `χ = 4 + 2h^{1,1} + 2h^{3,1} + h^{2,2} − 4h^{2,1}` (Theorem 4.1).
3. The mirror exchange theorem: `mirror_4` agrees on the support with the
   swap `h^{1,1} ↔ h^{3,1}` (Theorem 5.1), and the swap is an involution
   (Theorem 5.2).
4. Even-dimensional Euler invariance `χ(mirror X) = χ(X)`, both as a symmetry of
   the explicit formula (Theorem 6.1) and as the `n = 4` case of the general
   mirror Euler relation (Theorem 6.2).
5. The KLRY/F-theory collapse `χ = 6(8 + h^{1,1} + h^{3,1} − h^{2,1})` under the
   Chern-class relation (Theorem 7.1).

All results are exact; none uses inequalities, approximations, or unverified
"folklore."

---

## 2. The combinatorial mirror-symmetry skeleton

We recall the ambient framework over a fixed commutative ring `R`. A *Hodge
diamond* of complex dimension `n` is a function `h : ℕ → ℕ → R`; only the values
with `p, q ≤ n` are meaningful, the rest being padding zeros.

**Definition 2.1 (Euler characteristic).** For `n ∈ ℕ` and `h : ℕ → ℕ → R`,
```
eulerChar n h = Σ_{p=0}^{n} Σ_{q=0}^{n} (−1)^{p+q} · h(p,q).
```

**Definition 2.2 (mirror reflection).** `(mirror n h)(p,q) = h(n − p, q)`,
reflecting the first Hodge index through `p ↦ n − p` (with truncated natural
subtraction).

The skeleton supplies one general theorem we will use as a black box.

**Theorem 2.3 (mirror Euler relation).** For all `n` and `h`,
```
eulerChar n (mirror n h) = (−1)^n · eulerChar n h.
```
*Proof sketch.* Reindex the outer sum by the reflection `p ↦ n − p` using
`Finset.sum_range_reflect`. For `p ≤ n` one has the sign identity
`(−1)^{n−p} = (−1)^n (−1)^p` (since `(−1)^p (−1)^p = 1` and
`(−1)^{n−p}(−1)^p = (−1)^n`), so each summand picks up the global factor
`(−1)^n`. No positivity or field structure is needed; the identity holds over any
commutative ring. ∎

The threefold specialization `eulerChar 3 (mirror 3 h) = − eulerChar 3 h` is the
case `n = 3`, where `(−1)^3 = −1`. We will produce the fourfold counterpart as
the case `n = 4`.

---

## 3. The four-parameter fourfold diamond

A smooth Calabi–Yau fourfold `X` has complex dimension `n = 4`. Its Hodge diamond
`h^{p,q}` (`0 ≤ p, q ≤ 4`) is constrained by three symmetries:

- **Hodge symmetry:** `h^{p,q} = h^{q,p}`;
- **Serre duality:** `h^{p,q} = h^{4−p, 4−q}`;
- **Calabi–Yau vanishing:** `h^{0,0} = h^{4,0} = h^{0,4} = h^{4,4} = 1`, and
  `h^{p,0} = 0` for `0 < p < 4`.

These reduce the twenty-five entries to four independent values.

**Definition 3.1 (CY4 data).** A `CY4` is a tuple of four integers
```
(h11, h21, h31, h22) ∈ ℤ^4,
```
representing `h^{1,1}` (Kähler/divisor moduli), `h^{2,1}`, `h^{3,1}`
(complex-structure moduli), and the central `h^{2,2}`.

**Definition 3.2 (reconstructed diamond).** The diamond `X.diamond : ℕ → ℕ → ℤ`
is the explicit function
```
(0,0),(4,4),(0,4),(4,0) ↦ 1
(1,1),(3,3)             ↦ h11
(3,1),(1,3)            ↦ h31
(2,2)                  ↦ h22
(2,1),(1,2),(2,3),(3,2)↦ h21
otherwise              ↦ 0.
```
Every value is the one forced by Hodge symmetry, Serre duality, and CY vanishing
from the four free numbers. The diagonal reads `1, h11, h22, h11, 1`; the
sub/super-diagonals carry `h21`; the secondary diagonal carries `h31`.

This explicit, `match`-style definition is the central modeling choice: it makes
all subsequent identities decidable case checks over the finite support
`{0,…,4}^2`.

---

## 4. The Euler characteristic of a Calabi–Yau fourfold

**Theorem 4.1 (Euler characteristic formula).** For every `X : CY4`,
```
eulerChar 4 (X.diamond) = 4 + 2·h11 + 2·h31 + h22 − 4·h21.
```

*Proof sketch.* Expand the `5×5` alternating double sum
`Σ_{p=0}^{4} Σ_{q=0}^{4} (−1)^{p+q} h^{p,q}` by `Finset.sum_range_succ`, reduce
each of the twenty-five literal entries `diamond(p,q)` through the defining
`match`, and collect terms. The four unit corners contribute
`(−1)^0 + (−1)^8 + (−1)^4 + (−1)^4 = 4`. The two `h11` diagonal entries at
`(1,1)` and `(3,3)` carry signs `(−1)^2 = (−1)^6 = +1`, giving `+2h11`;
similarly the two `h31` entries at `(1,3),(3,1)` (signs `(−1)^4 = +1`) give
`+2h31`. The central `h22` at `(2,2)` has sign `(−1)^4 = +1`, giving `+h22`. The
four `h21` entries at `(1,2),(2,1),(2,3),(3,2)` all have odd `p+q`, hence sign
`−1`, giving `−4h21`. Summing, `ring` closes the identity. ∎

This is unconditional combinatorics: no Chern class, curvature, or even ring
positivity is involved. It is the fourfold analogue of the threefold
`χ = 2(h^{1,1} − h^{2,1})`.

---

## 5. The mirror exchange `h^{1,1} ↔ h^{3,1}`

**Definition 5.1 (mirror swap).** The swap on free data,
`X.swap = (h31, h21, h11, h22)`, exchanges `h^{1,1} ↔ h^{3,1}` and fixes
`h^{2,1}, h^{2,2}`.

**Theorem 5.2 (mirror realizes the swap).** For `p, q ≤ 4`,
```
(mirror 4 (X.diamond))(p,q) = (X.swap).diamond(p,q).
```

*Proof sketch.* Both sides are supported on `{0,…,4}^2`. For each of the
twenty-five index pairs, `(mirror 4 h)(p,q) = h(4 − p, q)` reduces by the
defining `match` to the corresponding entry of the swapped diamond. The decisive
cases are the reflections sending `h^{1,1}` to `h^{3,1}` and back: e.g.
`mirror(1,1) = diamond(3,1) = h31`, which equals `swap.diamond(1,1) = swap.h11
= h31`. A finite case split (`interval_cases p`, `interval_cases q`) followed by
`rfl` discharges every pair. ∎

*Remark (support hypothesis).* Because the diamond is defined by a `match` with
truncating natural subtraction, the equality is asserted only on the support
`p, q ≤ 4`; outside it the two functions can disagree (e.g. `4 − p` truncates to
`0`). This is exactly the pointwise-on-support phrasing used throughout the
combinatorial skeleton, and it is the geometrically meaningful range.

**Theorem 5.3 (involution).** `X.swap.swap = X`.

*Proof sketch.* Swapping `h11` and `h31` twice restores them; `h21, h22` are
never touched. Destructure `X` and apply `rfl`. ∎

Theorems 5.2–5.3 exhibit the F-theory mirror map as a `ℤ/2`-action on
CY4-fourfold Hodge data, with the numerical content "Kähler moduli ↔
complex-structure moduli."

---

## 6. Even-dimensional Euler invariance

**Theorem 6.1 (mirror invariance, formula version).**
```
eulerChar 4 (X.swap.diamond) = eulerChar 4 (X.diamond).
```

*Proof sketch.* Apply Theorem 4.1 to both sides:
```
LHS = 4 + 2·h31 + 2·h11 + h22 − 4·h21,
RHS = 4 + 2·h11 + 2·h31 + h22 − 4·h21,
```
which are equal because the formula is symmetric in `h11` and `h31` and `swap`
exchanges exactly those two; `ring` finishes. ∎

**Theorem 6.2 (mirror invariance, catalog version).** For any diamond
`h : ℕ → ℕ → ℤ`,
```
eulerChar 4 (mirror 4 h) = eulerChar 4 h.
```

*Proof sketch.* Specialize the general mirror Euler relation (Theorem 2.3) to
`n = 4`: `eulerChar 4 (mirror 4 h) = (−1)^4 · eulerChar 4 h`, and `(−1)^4 = 1`.
∎

This is the decisive contrast with threefolds. There `(−1)^3 = −1` forces
`χ(mirror) = −χ` (so mirror pairs have opposite Euler numbers); here `(−1)^4 = 1`
forces `χ(mirror) = χ`. The phenomenon is entirely controlled by the parity of
the dimension. Theorem 6.1 (the symmetric explicit formula) and Theorem 6.2 (the
abstract sign `(−1)^n`) are two views of the same fact and agree, as they must:
the swap of Theorem 5.2 is the on-support incarnation of `mirror 4`.

---

## 7. The Klemm–Lian–Roan–Yau / F-theory formula

The four Hodge numbers of an *actual* smooth Calabi–Yau fourfold are not
independent: a Chern-class (index-theoretic) constraint pins the central number.

**Chern-class relation (KLRY).** For a smooth Calabi–Yau fourfold,
```
h^{2,2} = 2·(22 + 2·h^{1,1} + 2·h^{3,1} − h^{2,1}).
```

This is the one genuinely geometric input of the paper; it originates in the
relations among Chern numbers and the Hirzebruch–Riemann–Roch computation of
holomorphic Euler characteristics on a fourfold.

**Theorem 7.1 (KLRY/F-theory Euler formula).** If `X : CY4` satisfies the KLRY
relation `h22 = 2(22 + 2·h11 + 2·h31 − h21)`, then
```
eulerChar 4 (X.diamond) = 6·(8 + h11 + h31 − h21).
```

*Proof sketch.* Substitute the KLRY value of `h22` into the combinatorial Euler
formula of Theorem 4.1:
```
χ = 4 + 2h11 + 2h31 + [2(22 + 2h11 + 2h31 − h21)] − 4h21
  = 4 + 2h11 + 2h31 + 44 + 4h11 + 4h31 − 2h21 − 4h21
  = 48 + 6h11 + 6h31 − 6h21
  = 6(8 + h11 + h31 − h21).
```
`ring` verifies the algebra. ∎

Three structural facts follow immediately. (i) `χ` is always divisible by `6`.
(ii) `χ` remains symmetric in `h11` and `h31`, so it is mirror-invariant —
consistent with Theorems 6.1–6.2 and the fact that the KLRY relation itself is
symmetric in `h11, h31`. (iii) The formula is *affine* in the three free numbers
`h11, h31, h21`, the central number `h22` having been eliminated. This is the
expression used pervasively in F-theory flux counting and tadpole calculations.

---

## 8. Worked example

Take the maximally symmetric data `h11 = h31 = h21 = 1`.

- KLRY forces `h22 = 2(22 + 2 + 2 − 1) = 2·25 = 50`.
- Theorem 4.1 gives `χ = 4 + 2 + 2 + 50 − 4 = 54`.
- Theorem 7.1 gives `χ = 6(8 + 1 + 1 − 1) = 6·9 = 54`. ✓
- The mirror swaps the two equal values `h11 ↔ h31`, returning the same data;
  `χ` is unchanged at `54`, confirming Theorems 6.1–6.2.

A second example: `h11 = 3, h31 = 7, h21 = 2`.

- KLRY: `h22 = 2(22 + 6 + 14 − 2) = 2·40 = 80`.
- Theorem 4.1: `χ = 4 + 6 + 14 + 80 − 8 = 96`.
- Theorem 7.1: `χ = 6(8 + 3 + 7 − 2) = 6·16 = 96`. ✓
- Mirror data `h11 = 7, h31 = 3, h21 = 2`: KLRY gives the same `h22 = 80` and
  `χ = 96`, as invariance predicts.

---

## 9. Algorithms

The development yields three elementary but useful algorithms operating on the
four-number model.

**Algorithm A — Diamond assembly and Euler characteristic.** Given
`(h11, h21, h31, h22)`, materialize the `5×5` diamond by the case table of
Definition 3.2 and evaluate the alternating double sum. Verified to equal the
closed form `4 + 2h11 + 2h31 + h22 − 4h21` (Theorem 4.1). Complexity `O(n^2)` in
the dimension (here constant), or `O(1)` via the closed form.

**Algorithm B — Mirror map and invariance check.** Given `CY4` data, produce the
mirror `swap = (h31, h21, h11, h22)` and verify both the on-support diamond
agreement (Theorem 5.2) and `χ(swap) = χ(X)` (Theorem 6.1). The involution
`swap∘swap = id` (Theorem 5.3) is a one-line check.

**Algorithm C — KLRY closure.** Given the three free moduli `(h11, h31, h21)`,
compute `h22` from the KLRY relation and return the F-theory Euler number
`6(8 + h11 + h31 − h21)`; cross-check against the combinatorial formula
(Theorem 7.1).

---

## 10. Applications

- **F-theory flux vacua.** The Euler number `χ` of the elliptically fibered
  Calabi–Yau fourfold sets the D3-tadpole `χ/24` and bounds the available flux;
  the formula `χ = 6(8 + h11 + h31 − h21)` is the standard input.
- **Mirror-pair construction.** The exchange `h^{1,1} ↔ h^{3,1}` is the numerical
  test a candidate mirror pair must satisfy, and the involution guarantees the
  relation is symmetric.
- **Hodge-number databases.** The closed Euler formula and divisibility-by-six
  give fast consistency checks for large catalogues of fourfold geometries.
- **Pedagogy.** The reduction of a `25`-entry diamond to four numbers, and of
  mirror symmetry to a corner-swap, is a clean illustration of how index parity
  governs duality signs.

---

## 11. Discussion

The value of an exact, gap-free treatment is the sharp separation of *shallow*
from *deep*. Theorems 4.1, 5.2, 5.3, 6.1, and 6.2 are shallow: they follow from
the diamond's defining symmetries and the alternating sign, and Theorem 6.2 in
particular holds over any commutative ring of coefficients (it never uses that
the entries are the four CY numbers). Only Theorem 7.1 imports geometry, and even
there the geometric content is concentrated in a *single* affine relation; once
that relation is granted, the F-theory formula is one substitution away.

The conceptual takeaway is the parity principle: reflecting one Hodge index
multiplies `χ` by `(−1)^n`. The much-discussed difference between threefold
mirror symmetry (`χ ↦ −χ`) and fourfold mirror symmetry (`χ ↦ χ`) is nothing
more than `(−1)^3 = −1` versus `(−1)^4 = +1`. Framing it this way also predicts
the pattern for all dimensions: odd-dimensional Calabi–Yau mirrors flip the
Euler sign, even-dimensional ones preserve it.

A modeling subtlety worth emphasizing is the support hypothesis in Theorem 5.2.
Because the diamond is encoded by a finite case table and the reflection uses
truncating natural-number subtraction, mirror agreement is asserted only on
`p, q ≤ 4`. This is not a defect but the honest statement: outside the diamond's
support there is no geometry to compare, and the pointwise-on-support phrasing is
exactly what the surrounding combinatorial skeleton uses.

---

## 12. Future work

- **Higher even dimensions.** Extend to fivefolds and sixfolds, confirming the
  parity prediction `χ(mirror) = (−1)^n χ` and cataloguing the free Hodge
  numbers (the count grows, and new "middle" numbers appear).
- **Full Hodge polynomial.** Promote the single Euler invariant to the full
  E-polynomial / Hodge–Deligne polynomial and study how the mirror reflection
  acts on it, not merely on its alternating evaluation.
- **Arithmetic mirror bridge.** Connect to the point-count side: pair the
  fourfold Euler invariant with `𝔽_q`-point-count congruences `mod (q − 1)`, in
  the spirit of Wan-type congruences, generalizing the projective-space toy
  model of the underlying skeleton.
- **Refined KLRY constraints.** Incorporate further Chern-number relations to
  cut the moduli space of admissible `(h11, h31, h21)` and study integrality and
  positivity constraints on realizable diamonds.
- **Mirror beyond the diamond.** Lift the corner-swap to statements about the
  Kähler and complex-structure moduli spaces themselves, toward a combinatorial
  proxy for the genuine mirror map.

---

## 13. Conclusion

We have given a complete and exact account of the Hodge-diamond combinatorics of
Calabi–Yau fourfolds: a four-parameter model, the closed Euler-characteristic
formula `χ = 4 + 2h^{1,1} + 2h^{3,1} + h^{2,2} − 4h^{2,1}`, the mirror exchange
`h^{1,1} ↔ h^{3,1}` as an involution agreeing on support with the index
reflection, the even-dimensional invariance `χ(mirror) = χ` as the `(−1)^4 = +1`
shadow of the general mirror Euler relation, and the KLRY collapse to the
F-theory formula `χ = 6(8 + h^{1,1} + h^{3,1} − h^{2,1})`. Every link is an exact
identity, and the whole story turns on a single arithmetic fact: the parity of
the complex dimension.
