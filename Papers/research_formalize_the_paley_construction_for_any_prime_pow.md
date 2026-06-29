# Skew Conference Matrices and the Order-Preserving Core of the Paley I Construction

## Abstract

We isolate and rigorously establish the purely matrix-algebraic core of the Paley I
construction of Hadamard matrices. A **skew conference matrix** of order *n* is a
square integer matrix `C` with zero diagonal, ±1 off-diagonal entries, antisymmetry
`Cᵀ = −C`, and the conference identity `C·Cᵀ = (n − 1)·I`. We prove that the single
substitution of antisymmetry into the conference identity yields the master equation
`C·C = (1 − n)·I`, and that this equation alone forces `I + C` to be a Hadamard matrix
of the *same* order *n* — indeed a **skew-Hadamard matrix**, one satisfying
`H + Hᵀ = 2·I`. We prove the exact converse: subtracting the identity from any
skew-Hadamard matrix recovers a skew conference matrix. Together these establish a
bijective correspondence `C ↦ I + C` (with inverse `H ↦ H − I`) between skew
conference matrices and skew-Hadamard matrices of each order. As an existence bridge,
the construction certifies that whenever a skew conference matrix of order *n* exists,
*n* is a Hadamard order — the route, via quadratic-residue (Jacobsthal) matrices over
finite fields `GF(q)` with `q ≡ 3 (mod 4)`, to Hadamard orders `q + 1` that are not
forced to be powers of two. We further characterize the sharp boundary of the method:
the cancellation of cross-terms that powers it holds precisely in the skew (Paley I)
case and fails for symmetric conference matrices (Paley II), which require order
doubling.

**Keywords:** Hadamard matrix, conference matrix, skew-symmetric matrix, Paley
construction, quadratic residues, combinatorial design, formal verification.

---

## 1. Introduction

### 1.1 Hadamard matrices

A **Hadamard matrix** of order *n* is an *n × n* matrix `H` with entries in `{+1, −1}`
whose rows are pairwise orthogonal; equivalently,

> `H · Hᵀ = n · I`,

where `I` is the *n × n* identity. Equivalently, the columns are also pairwise
orthogonal and `Hᵀ · H = n · I`. Hadamard matrices achieve equality in Hadamard's
determinant inequality `|det M| ≤ n^{n/2}` over the class of matrices with entries
bounded by 1, and they underpin error-correcting codes (Reed–Muller / Hadamard codes
used in deep-space telemetry), CDMA spreading sequences, and optimal experimental
designs.

It is classical that a Hadamard matrix of order *n > 2* can exist only if `4 ∣ n`. The
**Hadamard conjecture** — that one exists for *every* multiple of 4 — remains open. The
value of explicit construction families is therefore measured by how large a set of
orders they certify. The **Sylvester family**, obtained by iterating
`H ↦ [[H, H], [H, −H]]` from `H = [1]`, certifies exactly the powers of two
`1, 2, 4, 8, 16, …`. The **Paley constructions** of 1933 broke this barrier by
producing orders `q + 1` and `2(q + 1)` for prime powers *q*, and remain among the
most important infinite families known.

### 1.2 Conference matrices and the two Paley families

A **conference matrix** of order *n* is a matrix `C` with zero diagonal, ±1
off-diagonal entries, and `C·Cᵀ = (n − 1)·I`. Conference matrices split into two
symmetry classes: **symmetric** (`Cᵀ = C`) and **skew** (`Cᵀ = −C`). The two classes
give rise, respectively, to the Paley II construction (order `2(n)`, via 2×2 block
bordering) and the Paley I construction (order `n`, via the identity shift `I + C`).

The canonical examples are the **Jacobsthal / quadratic-residue matrices**
`Q` over the finite field `GF(q)`, with rows and columns indexed by field elements and
`Q_{a,b} = χ(a − b)`, where `χ` is the quadratic-residue character (`χ(0) = 0`,
`χ(x) = +1` if `x` is a nonzero square, `−1` otherwise). The matrix `Q` is symmetric
when `q ≡ 1 (mod 4)` and skew when `q ≡ 3 (mod 4)`. The case `q ≡ 3 (mod 4)` therefore
feeds the order-preserving Paley I construction to produce Hadamard matrices of order
`q + 1`.

### 1.3 Contribution

This paper formalizes the **order-preserving algebraic core** of the Paley I
construction, factored cleanly away from the number theory. We work over the integers
`ℤ` with matrices indexed by `Fin n`. Our contributions are:

1. **The master identity** (Theorem 4.1): for a skew conference matrix,
   `C·C = (1 − n)·I`.
2. **Forward construction** (Theorem 5.1): `I + C` is a skew-Hadamard matrix of order
   *n* whenever `C` is a skew conference matrix; and its forgetful corollary
   (Corollary 5.2) that `I + C` is Hadamard.
3. **Existence bridge** (Theorem 5.3): existence of a skew conference matrix of order
   *n* certifies *n* as a Hadamard order.
4. **Converse / bijection** (Theorem 6.1): `H ↦ H − I` recovers a skew conference
   matrix from any skew-Hadamard matrix, establishing the bijective correspondence
   `C ↦ I + C`.
5. **Boundary analysis** (Section 7): the cross-term cancellation that drives the
   construction holds exactly in the skew case and fails in the symmetric case, which
   explains the structural necessity of two distinct Paley families.

All statements have been formally verified in the Lean 4 proof assistant against
Mathlib; this paper presents the mathematics and proof sketches.

---

## 2. Notation and Conventions

Throughout, *n* is a natural number and all matrices are `n × n` over `ℤ`, indexed by
`Fin n`. We write `I` for the identity matrix `1`, `Mᵀ` for the transpose of `M`, and
`c · I` for the scalar multiple of the identity (the Lean `smul`). For a matrix
predicate, "order *n*" means the matrix is `n × n`. We use `·` for matrix product and
treat the integer scalar `c` interchangeably with `(c : ℤ)` where clear.

We deliberately develop the theory self-containedly over `ℤ`, mirroring the catalog's
`IsHadamard` predicate, so that no external assumptions about fields or characteristic
are needed for the algebraic core.

---

## 3. Definitions

**Definition 3.1 (Hadamard matrix).**
A matrix `H : Matrix (Fin n) (Fin n) ℤ` is *Hadamard*, written `IsHadamardP H`, if

- every entry satisfies `H i j = 1 ∨ H i j = −1`, and
- `H · Hᵀ = (n : ℤ) · I`.

**Definition 3.2 (Hadamard order).**
A natural number *n* is a *Hadamard order*, written `HadamardOrderP n`, if there exists
`H` with `IsHadamardP H`.

**Definition 3.3 (Skew conference matrix).**
A matrix `C : Matrix (Fin n) (Fin n) ℤ` is a *skew conference matrix*, written
`IsSkewConference C`, if

1. `C i i = 0` for all `i` (zero diagonal),
2. `C i j = 1 ∨ C i j = −1` for all `i ≠ j` (±1 off-diagonal),
3. `Cᵀ = −C` (antisymmetry / skewness), and
4. `C · Cᵀ = ((n : ℤ) − 1) · I` (conference identity).

**Definition 3.4 (Skew-Hadamard matrix).**
A matrix `H` is *skew-Hadamard*, written `IsSkewHadamardP H`, if `IsHadamardP H` and

> `H + Hᵀ = (2 : ℤ) · I`.

The second condition says that `H` has all-ones diagonal and an antisymmetric
off-diagonal part: writing `H = I + S`, the condition is equivalent to `Sᵀ = −S`.

**Remark.** Conditions 1 and 3 of Definition 3.3 are mildly redundant in
characteristic ≠ 2: skewness forces `C i i = −C i i`, hence `2 C i i = 0`, hence
`C i i = 0` over `ℤ`. We keep the zero-diagonal condition explicit for clarity and to
match standard combinatorial usage.

---

## 4. The Master Identity

**Theorem 4.1 (`skewConference_mulSelf`).**
If `C` is a skew conference matrix of order *n*, then

> `C · C = (1 − n) · I`.

*Proof sketch.* By the conference identity (Definition 3.3.4),
`C · Cᵀ = (n − 1) · I`. By skewness (Definition 3.3.3), `Cᵀ = −C`. Substituting,

> `C · C = C · (−(−C)) = C · (−Cᵀ) = −(C · Cᵀ) = −((n − 1) · I) = (1 − n) · I.`

Concretely: negate both sides of the conference identity, then rewrite the left-hand
side using `Cᵀ = −C` and `C · (−C) = −(C · C)`, and `−(−(C·C)) = C·C`. The choice to
state the right-hand side as `(1 − n)·I` rather than `−((n−1)·I)` avoids friction with
scalar-negation normalization. ∎

This is the *engine* of the paper: every downstream result reduces to it.

---

## 5. Forward Construction: Skew Conference ⟹ Skew-Hadamard

**Theorem 5.1 (`skewConference_add_one_isSkewHadamard`, Paley I core).**
If `C` is a skew conference matrix of order *n*, then `I + C` is a skew-Hadamard
matrix of order *n*.

*Proof sketch.* We verify the three requirements of Definitions 3.1 and 3.4.

*Entries are ±1.* On the diagonal, `(I + C) i i = 1 + C i i = 1 + 0 = 1`. Off the
diagonal (`i ≠ j`), `(I + C) i j = 0 + C i j = C i j ∈ {+1, −1}`. So every entry is
±1, and notably **no hypothesis on *n* is needed** — the diagonal repair `1 + 0 = 1`
is automatic.

*Hadamard relation.* Expand using `(I + C)ᵀ = I + Cᵀ`:

> `(I + C)(I + C)ᵀ = I + Cᵀ + C + C·Cᵀ.`

By skewness the cross-terms cancel: `Cᵀ + C = −C + C = 0`. Hence
`(I + C)(I + C)ᵀ = I + C·Cᵀ`. But it is cleaner to route through Theorem 4.1: since
`Cᵀ = −C`,

> `(I + C)(I + C)ᵀ = (I + C)(I − C) = I − C·C = I − (1 − n)·I = n·I.`

(The cross-terms `−C + C` again cancel inside the product `(I + C)(I − C)`.) This is
precisely the Hadamard relation.

*Skew condition.* `(I + C) + (I + C)ᵀ = I + C + I + Cᵀ = 2I + (C + Cᵀ) = 2I` by
skewness. ∎

**Corollary 5.2 (`skewConference_isHadamard`).**
If `C` is a skew conference matrix of order *n*, then `I + C` is a Hadamard matrix of
order *n*. (Forget the skew refinement in Theorem 5.1.)

**Theorem 5.3 (`skewConference_hadamardOrder`, existence bridge).**
If there exists a skew conference matrix of order *n*, then `HadamardOrderP n`.

*Proof sketch.* Choose such a `C`; then `I + C` witnesses `HadamardOrderP n` by
Corollary 5.2. ∎

Theorem 5.3 is the bridge to non-power-of-two orders. Combined with the (number
theoretic, not formalized here) fact that the Jacobsthal matrix over `GF(q)`,
`q ≡ 3 (mod 4)`, is skew conference of order `q + 1`, it certifies Hadamard orders
`4, 8, 12, 20, 24, 28, …` — including order 12, the first multiple of 4 unreachable by
Sylvester doubling.

---

## 6. Converse and Bijective Correspondence

**Theorem 6.1 (`isSkewHadamard_sub_one_skewConference`).**
If `H` is a skew-Hadamard matrix of order *n*, then `H − I` is a skew conference
matrix of order *n*.

*Proof sketch.* Set `C := H − I` and verify the four conditions of Definition 3.3.

*Zero diagonal.* Reading the skew condition `H + Hᵀ = 2I` at position `(i, i)` gives
`H i i + H i i = 2`, so `H i i = 1`, hence `(H − I) i i = 0`. (Note this step uses the
skew condition, not Hadamard-ness alone.)

*±1 off-diagonal.* For `i ≠ j`, `(H − I) i j = H i j ∈ {+1, −1}` since the identity
contributes 0 off the diagonal and `H` has ±1 entries.

*Antisymmetry.* From `H + Hᵀ = 2I` we get `Hᵀ = 2I − H`, so
`(H − I)ᵀ = Hᵀ − I = (2I − H) − I = I − H = −(H − I)`.

*Conference identity.* Using `Hᵀ = 2I − H` and `H·Hᵀ = n·I`:

> `C·Cᵀ = (H − I)(Hᵀ − I) = H·Hᵀ − H − Hᵀ + I = n·I − (H + Hᵀ) + I = n·I − 2I + I = (n − 1)·I.` ∎

**Corollary 6.2 (Bijection).**
The maps `C ↦ I + C` and `H ↦ H − I` are mutually inverse bijections between the set
of skew conference matrices of order *n* and the set of skew-Hadamard matrices of
order *n*.

*Proof sketch.* Theorem 5.1 sends skew conference matrices to skew-Hadamard matrices;
Theorem 6.1 sends them back. The maps `C ↦ I + C` and `H ↦ H − I` are inverse as
functions on matrices (`(I + C) − I = C` and `I + (H − I) = H`), so they restrict to
mutually inverse bijections between the two classes. ∎

This upgrades the one-way construction into a *classification*: skew-Hadamard matrices
of order *n* are, up to the trivial identity shift, the same data as skew conference
matrices of order *n*.

---

## 7. The Skew/Symmetric Boundary

Why two Paley families? The proof of Theorem 5.1 isolates the answer. The Hadamard
relation for `I + C` reduces to

> `(I + C)(I + C)ᵀ = I + (C + Cᵀ) + C·Cᵀ`,

and the term `C + Cᵀ` is the *only* obstruction.

- **Skew case (`Cᵀ = −C`):** `C + Cᵀ = 0`. The cross-terms vanish and the construction
  succeeds at order *n*.
- **Symmetric case (`Cᵀ = C`):** `C + Cᵀ = 2C ≠ 0`. The cross-terms survive, `I + C`
  fails the Hadamard relation, and one must instead double the order via a 2×2 block
  construction (Paley II), schematically

> `[[ C + I,  C − I ], [ C − I,  −C − I ]]` (up to sign conventions),

producing a Hadamard matrix of order `2n`. The failure mode is recorded as the
conjecture `symmetricConference_hadamardOrder_two_mul`, the natural next formalization
target. The lesson is structural: the single sign distinguishing `Cᵀ = −C` from
`Cᵀ = C` is exactly what forks the theory into order-preserving (Paley I) and
order-doubling (Paley II) constructions.

---

## 8. Algorithms

The constructive content is fully effective. We summarize the two algorithms implicit
in the results (Python realizations appear in the accompanying demo).

**Algorithm A (Jacobsthal skew conference matrix).**
Input: a prime *q* with `q ≡ 3 (mod 4)`.
1. Compute the set `QR` of nonzero quadratic residues mod *q*.
2. Define `χ(0) = 0`; `χ(x) = +1` if `x mod q ∈ QR`, else `−1`.
3. Output `C` with `C_{a,b} = χ((a − b) mod q)`, indices `a, b ∈ {0, …, q−1}`.
Output `C` is a skew conference matrix of order *q*. (For full Paley I one borders to
order `q + 1`; the algebraic core here applies to any skew conference matrix.)

**Algorithm B (Paley I core: identity shift).**
Input: a skew conference matrix `C` of order *n*.
1. Output `H = I + C`.
By Theorem 5.1, `H` is skew-Hadamard of order *n*; verify `H · Hᵀ = n·I` directly.

**Algorithm C (inverse map).**
Input: a skew-Hadamard matrix `H`.
1. Output `C = H − I`.
By Theorem 6.1, `C` is skew conference of order *n*.

---

## 9. Applications

- **Hadamard order expansion.** Algorithm A + Algorithm B certify Hadamard orders
  `q + 1` for `q ≡ 3 (mod 4)`, the first infinite family beyond powers of two — orders
  12, 20, 24, 28, 36, … relevant to optimal designs.
- **Skew-Hadamard matrices specifically** are valued in their own right: they yield
  *doubly regular tournaments*, certain strongly regular graphs, and amicable Hadamard
  matrices used to build still larger Hadamard matrices.
- **Coding and signal processing.** Hadamard matrices of these new orders extend the
  available block lengths for Hadamard codes and orthogonal spreading sequences beyond
  the rigid power-of-two ladder.
- **Experimental design.** Skew-Hadamard matrices give rise to symmetric balanced
  incomplete block designs (the Hadamard–BIBD bridge), enabling new design parameters.

---

## 10. Discussion

The methodological point of this work is *factoring*. The full Paley I theorem couples
three ingredients: finite-field character theory (showing `Q` has the right entry
pattern), antisymmetry (the `q ≡ 3 (mod 4)` condition making `Q` skew), and the
identity-shift algebra. By extracting the third ingredient as a standalone, hypothesis
on an abstract skew conference matrix, we obtain a result that is (a) shorter and
more transparent, (b) reusable for *any* source of skew conference matrices (not only
Jacobsthal), and (c) bidirectional, yielding a classification rather than a mere
construction. The master identity `C·C = (1 − n)·I` compresses the entire argument
into a single line, and the converse shows the construction loses no information.

The boundary analysis of Section 7 clarifies a point often stated but rarely
emphasized: the existence of two Paley families is not an accident of history but a
forced consequence of a sign. Antisymmetry is precisely the hypothesis under which the
diagonal repair `I + C` preserves order.

---

## 11. Future Directions

1. **Symmetric (Paley II) construction.** Formalize that a symmetric conference matrix
   of order *n* yields a Hadamard matrix of order `2n` via 2×2 block bordering
   (`symmetricConference_hadamardOrder_two_mul`). The proof must handle the surviving
   cross-terms that the skew case eliminates.

2. **Jacobsthal matrix over `GF(q)`.** Construct the quadratic-residue matrix `Q` from
   `quadraticChar`/`legendreSym` in Mathlib, prove `Q·Qᵀ = (q−1)I − J` and the
   skew/symmetric dichotomy keyed to `q mod 4`, and border to order `q + 1`. This
   closes the gap between the abstract core proved here and concrete Hadamard orders.

3. **Hadamard maximal determinant bound.** Prove `|det M| ≤ n^{n/2}` for `|M_{ij}| ≤ 1`
   with equality iff `M` is Hadamard, via AM–GM on Gram-matrix eigenvalues.

4. **Equivalence classification for small orders.** Verify uniqueness up to Hadamard
   equivalence for `n ≤ 12` and the five classes at `n = 16` by exhaustive analysis of
   normalized forms.

5. **Hadamard–BIBD bridge.** Construct the incidence matrix of a symmetric
   `2-(4t−1, 2t−1, t−1)` design from a normalized Hadamard matrix of order `4t`.

6. **Williamson construction.** Formalize that four symmetric circulant ±1 matrices
   `A, B, C, D` of order *n* with `AᵀA + BᵀB + CᵀC + DᵀD = 4nI` build a Hadamard matrix
   of order `4n`, covering many orders unreachable by Sylvester or Paley alone.

---

## 12. Conclusion

We have formalized the order-preserving algebraic heart of the Paley I construction:
a skew conference matrix `C` of order *n* yields, via the single identity shift
`I + C`, a skew-Hadamard matrix of the same order, with the entire argument resting on
the one-line master identity `C·C = (1 − n)·I`. The exact converse `H ↦ H − I` makes
this a bijective correspondence and hence a classification. The existence bridge turns
any source of skew conference matrices — paradigmatically the Jacobsthal matrices over
`GF(q)`, `q ≡ 3 (mod 4)` — into certified Hadamard orders `q + 1`, the first infinite
family beyond the powers of two. Finally, the skew/symmetric boundary analysis
explains, in terms of a single surviving sign, why two genuinely different Paley
constructions exist.

---

## Appendix: Summary of Formalized Results

| Name | Statement | Status |
|---|---|---|
| `skewConference_mulSelf` | `C·C = (1 − n)·I` for skew conference `C` | proved |
| `skewConference_add_one_isSkewHadamard` | `I + C` is skew-Hadamard | proved |
| `skewConference_isHadamard` | `I + C` is Hadamard | proved |
| `skewConference_hadamardOrder` | skew conference of order *n* ⟹ `HadamardOrderP n` | proved |
| `isSkewHadamard_sub_one_skewConference` | `H − I` is skew conference for skew-Hadamard `H` | proved |
| `symmetricConference_hadamardOrder_two_mul` | symmetric conference ⟹ Hadamard order `2n` | conjectured |
