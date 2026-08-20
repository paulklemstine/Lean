# Computational evidence for Conjecture D10

All numbers below were produced by `#eval` inside the Lean project (evaluated against the
definitions in `Catalog/NumberTheory/MolienBurnsideD10.lean` and
`Catalog/NumberTheory/MolienNecklaceCongruence.lean`), and every statement that we rely on
is additionally *proved* in those files — nothing here is an unchecked side computation.

## 1. The two invariants on small groups

For a finite `G`-set `X` we compare

* the permutation character `g ↦ |X^g|` (`D10.fixCount`), from which the Molien invariant
  `molien X H = (1/|H|) ∑_{h ∈ H} |X^h|` is built, and
* the Burnside mark vector `H ↦ |X^H|` (`D10.markOn`).

### Cyclic groups: the two agree (in the sense of D10)

If every subgroup is cyclic then `|X^H| = |X^⟨h⟩| = |X^h|`, so the character *is* the mark
vector re-indexed. This is `D10.markOn_eq_of_fixCount_eq_of_isCyclic`. No numerical search
is required: the identity `|X^g| = |X^{⟨g⟩}|` is `D10.fixCount_eq_markOn_zpowers`.

### Klein four group `V = (ℤ/2)²`: the conjecture breaks

Take

* `Xthree = V/A ⊔ V/B ⊔ V/C` (three transitive 2-element `V`-sets, 6 points);
* `Xreg   = V ⊔ {two fixed points}` (6 points).

`#eval` over the four group elements `(0,0), (1,0), (0,1), (1,1)`:

| `g`     | `|Xthree^g|` | `|Xreg^g|` |
|---------|--------------|------------|
| `(0,0)` | 6            | 6          |
| `(1,0)` | 2            | 2          |
| `(0,1)` | 2            | 2          |
| `(1,1)` | 2            | 2          |

Identical characters, hence identical Molien invariants at every subgroup
(`D10.klein_molien_eq`). The marks:

| `H`     | `mark(Xthree)` | `mark(Xreg)` |
|---------|----------------|--------------|
| `⊥`     | 6              | 6            |
| `⟨a⟩` (each of the three order-2 subgroups) | 2 | 2 |
| `⊤`     | **0**          | **2**        |

The mark vectors agree at all *cyclic* subgroups and differ exactly at `⊤`, the unique
non-cyclic subgroup of `V` (`D10.klein_marks_agree_on_cyclic`, `D10.V4_not_isCyclic`).
`⊥` forces a hypothetical scaling factor to be `1`, `⊤` forces it to be `0`: no scaling
repairs the discrepancy (`D10.D10_false`).

### Rank-two elementary abelian groups: an infinite family

The same pattern persists for `(ℤ/p)²` with `Xlines p = ⊔_{ℓ ∈ ℙ¹(𝔽_p)} E/ℓ` (size
`p(p+1)`) and `XregEA p = E ⊔ (p fixed points)` (size `p² + p`):
characters `(p(p+1), p, p, …, p)` on both sides, marks at `⊤` equal to `0` and `p`.
This is proved uniformly in `p` in `Catalog/NumberTheory/MolienBurnsideElementaryAbelian.lean`
(`D10.D10_false_elementary_abelian`); the key finite-field input is that a nonzero vector of
`𝔽_p²` lies on exactly one of the `p + 1` lines (`D10.card_vanishing_lines`).

## 2. Arithmetic output of the machinery (sanity checks)

The Burnside divisibility applied to the rotation action on `k`-colourings of `ℤ/n` gives
`n ∣ ∑_{a ∈ ℤ/n} k^{gcd(n,a)}` (`D10.necklace_congruence`). The resulting quotients (the
necklace counts) computed by `#eval`:

* `k = 2`, `n = 1..13`: `2, 3, 4, 6, 8, 14, 20, 36, 60, 108, 188, 352, 632`
  — OEIS **A000031** (number of binary necklaces of length `n`).
* `k = 3`, `n = 1..8`: `3, 6, 11, 24, 51, 130, 315, 834`
  — OEIS **A001867** (number of ternary necklaces of length `n`).

Both sequences are integral for every tested `n`, as the theorem requires; the case `n = p`
prime reduces to `k^p ≡ k (mod p)` (`D10.fermat_little_modEq`).

## 3. Counterexample hunt

The universal claim "Molien invariant = mark vector up to scaling" was tested on the
smallest groups:

* all cyclic groups: no counterexample can exist (proved, not searched);
* the smallest non-cyclic group, `V = (ℤ/2)²`: counterexample found (above) and formalised;
* generic rank-two elementary abelian `(ℤ/p)²`: counterexample found for every prime `p`
  and formalised.

The pattern isolated by these experiments — failure occurs precisely at non-cyclic
subgroups — is what motivates the conjectures recorded in `FUTURE_DIRECTIONS.md`.
