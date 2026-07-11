# Computational Evidence

The central object is **Lawvere's fixed-point theorem** and its diagonal
corollaries. These are *universally quantified* structural statements ("for every
type / every model …"), so the relevant "evidence" is finite-case verification
that the diagonal construction behaves as claimed, and a counterexample hunt for
the boundary hypotheses. All checks below are reproducible with `#eval` /
`decide` inside Lean.

## 1. The Boolean diagonal on small models

Take a finite model `Pgm = Fin n` with acceptance matrix `acc : Fin n → Fin n → Bool`.
The diagonal behaviour is `d q = !(acc q q)` and the claim is `∀ p, acc p ≠ d`.

* `n = 1`, `acc = [[true]]`: diagonal `d 0 = !true = false`. Row `0` is `true ≠ false`. ✓
* `n = 2`, `acc = [[T,T],[T,T]]`: `d = [F,F]`; no row equals `[F,F]`. ✓
* `n = 2`, `acc = [[F,T],[T,F]]` (identity-negation): `d q = !acc q q = [T,T]`; rows are `[F,T],[T,F]`, neither is `[T,T]`. ✓
* Exhaustive check over **all** `2^(n·n)` matrices for `n = 1,2,3`: in every case the
  diagonal row differs from every actual row (it must, since it differs from row `p`
  in column `p`). No counterexample exists — this is exactly the content of
  `ComputationModel.diagonal_not_realized`, provable by `decide` for each fixed `n`.

## 2. Cantor step / hierarchy cardinalities

`Level 0 = A`, `Level (n+1) = Level n → Bool`. With `A = Fin k`:

| level | cardinality (A = Fin 2) |
|------:|:------------------------|
| 0     | 2                       |
| 1     | 2^2 = 4                 |
| 2     | 2^4 = 16                |
| 3     | 2^16 = 65536            |
| 4     | 2^65536                 |

Strictly increasing at every step (`2 < 4 < 16 < 65536 < …`), matching
`Hierarchy.mk_lt` and the tower `#Level (n+1) = 2 ^ #Level n`. This is the
`2 ↑↑ n`-style tower (iterated exponential, related to OEIS A014221:
`0, 1, 2, 4, 16, 65536, …` for `2 ↑↑ n`).

## 3. Counterexample hunt for the hypotheses

* **Lawvere needs a fixed-point-free `f`** for the *negative* corollary. Over `Bool`
  the only fixed-point-free endofunction is `not`; `id`, `const true`, `const false`
  all have fixed points, so they yield *no* Cantor obstruction — correctly, the
  theorem only forbids point-surjectivity when a fixed-point-free `f` exists.
* **Recursion theorem needs completeness.** We searched for non-degenerate `Set`
  models of `PointSurjective (build : Pgm → (Pgm → Pgm))`: for `|Pgm| ≥ 2`,
  `|Pgm → Pgm| = |Pgm|^|Pgm| > |Pgm|`, so no surjection exists. Only `|Pgm| ≤ 1`
  works — a counterexample *to non-triviality*, faithfully reflected in the code by
  using `PUnit` as the witness and documenting that non-degenerate instances live in
  the computable category (Kleene's `s-m-n`).

## Conclusion

Every finite instance of the diagonal construction confirms the universal
theorems, and the counterexample hunt sharply locates the boundary of each
hypothesis. No counterexample to any proved statement was found — as expected,
since each is a theorem with a machine-checked proof in the accompanying `.lean`
files.
