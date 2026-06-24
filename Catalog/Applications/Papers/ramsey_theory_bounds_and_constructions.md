# Computational Evidence — Schur Numbers (Ramsey theory, additive)

All claims below were checked in Lean with `decide` / `Finset.filter` counts
before formalisation, and are now backed by `sorry`-free proofs in
`Algebra/SchurNumberTwo.lean` and `Algebra/SchurNumberThree.lean`.

## 1. Small-case calculations (Schur number S(r))

A *Schur triple* is `x + y = z` with `x, y ≥ 1` (entries may repeat, so `2x = z`
is allowed). `S(r)` is the largest `n` such that `{1,…,n}` admits an `r`-colouring
with no monochromatic Schur triple.

| r | S(r) | extremal colouring of {1,…,S(r)} |
|---|------|----------------------------------|
| 1 | 1    | {1} (since 1+1=2 ∉ {1})          |
| 2 | 4    | {1,4} / {2,3}                    |
| 3 | 13   | {1,4,10,13} / {2,3,11,12} / {5,6,7,8,9} |
| 4 | 44   | (not formalised; future cycle)   |

OEIS: the Schur numbers `1, 4, 13, 44, 160, …` are **A045652**.

## 2. Two-colour case (formalised, `decide`)

* Brute force over all `2^6` colourings of indices `0..5`:
  every two-colouring of `{1,…,5}` contains a monochromatic Schur triple →
  `not_schurColourable_five`.
* Some two-colouring of `{1,…,4}` avoids one (witness `{1,4}` vs `{2,3}`) →
  `schurColourable_four`.
* The deterministic forcing chain making `{1,…,5}` unavoidable (with `a = c 1`):
  `(1,1,2) ⇒ c2≠a`, `(2,2,4) ⇒ c4=a`, `(1,4,5) ⇒ c5≠a`,
  `(2,3,5) ⇒ c3=a`, `(1,3,4) ⇒` contradiction.

Conclusion: `S(2) = 4` (`schur_number_two`).

## 3. Three-colour construction (formalised, `decide`)

`Finset.filter` count of monochromatic Schur triples of the classical partition
of `{1,…,13}`:

```
(Finset.Icc 1 13 ×ˢ Finset.Icc 1 13).filter
  (fun p => p.1 + p.2 ≤ 13 ∧ col p.1 = col p.2 ∧ col p.2 = col (p.1+p.2)) |>.card
  = 0
```

Hence `S(3) ≥ 13` (`schurColourable_three_thirteen`). The colour classes are
symmetric under `k ↦ 14 - k`.

## 4. Counterexample hunt

No counterexamples to `S(2)=4` or to the validity of the `S(3) ≥ 13`
construction were found; the universal `{1,…,5}` claim holds for all `2^6 = 64`
colourings tested, and the `S(3)` construction has exactly 0 bad triples.
