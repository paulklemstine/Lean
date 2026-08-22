# Computational evidence

All numerical claims below were produced by `#eval` inside Lean 4 (kernel/compiler
arithmetic on `Nat`/`Int`), and every claim that is used mathematically is *also* certified
by a `decide` proof inside the Lean files, so nothing here is load-bearing folklore.

Notation: a **window-`K` invisible vector** is `e : ℕ → ℤ`, supported on `{0,…,N}`, with
`∑_j e j · j^k = 0` for all `k < K`.  Its **mass** is `∑_j |e j|`.  Writing `e` as the
multiplicity difference of two multisets, a mass-`2n` witness is a Prouhet–Tarry–Escott
(PTE) pair of size `n`.

## 1. Small-case data: minimal mass by window

| window `K` | ideal PTE pair `A` vs `B` (nodes)                                             | mass | binomial vector's mass `2^K` |
|-----------:|-------------------------------------------------------------------------------|-----:|-----------------------------:|
| 1  | `{0}` / `{1}`                                                                          | 2  | 2    |
| 2  | `{0,3}` / `{1,2}`                                                                      | 4  | 4    |
| 3  | `{1,5,6}` / `{2,3,7}`                                                                  | 6  | 8    |
| 4  | `{0,4,7,11}` / `{1,2,9,10}`                                                            | 8  | 16   |
| 5  | `{1,2,10,14,18}` / `{0,4,8,16,17}`                                                     | 10 | 32   |
| 6  | `{0,5,6,16,17,22}` / `{1,2,10,12,20,21}`                                               | 12 | 64   |
| 7  | `{0,18,27,58,64,89,101}` / `{1,13,38,44,75,84,102}`                                    | 14 | 128  |
| 8  | `{0,4,9,23,27,41,46,50}` / `{1,2,11,20,30,39,48,49}`                                   | 16 | 256  |
| 9  | `{0,24,30,83,86,133,157,181,197}` / `{1,17,41,65,112,115,168,174,198}`                 | 18 | 512  |
| 10 | `{12,2865,3519,11869,23738,23762,35631,43981,44635,47488}` / `{0,3083,3301,11893,23314,24186,35607,44199,44417,47500}` | 20 | 1024 |
| 11 | **none known**                                                                          | ?  | 2048 |
| 12 | `{0,11,24,65,90,129,173,212,237,278,291,302}` / `{3,5,30,57,104,116,186,198,245,272,297,299}` | 24 | 4096 |

The `K = 10` and `K = 12` rows are translates of symmetric configurations
(`±{12, 11881, 20231, 20885, 23738}` vs `±{436, 11857, 20449, 20667, 23750}`, and
`±{22, 61, 86, 127, 140, 151}` vs `±{35, 47, 94, 121, 146, 148}`), shifted by a constant to
land in `ℕ`; translation preserves the equality of power sums throughout the window.

Verification performed (all returned `true`):

```lean
def chk (A B : List Nat) (K : Nat) : Bool :=
  (List.range K).all (fun k => (A.map (fun a => a^k)).sum == (B.map (fun a => a^k)).sum)
  && A.all (fun a => !B.contains a) && A.Nodup && B.Nodup
```

Each row is re-proved in Lean by `decide` in
`Catalog/Applications/PTEIdealWitnesses.lean` (`massAchievable_one` … `massAchievable_twelve`),
so the table is a *theorem*, not a computation log.

## 2. Counterexample hunt for the universal claim `mass ≥ 2K`

The catalog previously proved `mass ≥ K + 1`, `≥ K + 2` (`K ≥ 2`) and `≥ K + 3` (odd `K`).
The conjecture tested here was the much stronger `mass ≥ 2K`.

* Attempted counterexamples: all binomial vectors (`mass = 2^K ≥ 2K`), all convolution
  products of the small witnesses, the `K = 3` witness `(-1,2,0,-2,1)` (mass 6 = 2·3, tight),
  and every PTE pair listed above (all tight).  No candidate with mass `< 2K` was found.
* The claim is now a theorem (`PTESize.l1_ge_two_mul_window`), proved through Newton's
  identities, so the hunt is closed.
* The *next* claim, `mass ≥ 2K + 2` for windows with no ideal pair, is proved conditionally
  (`PTEIdeal.minMass_ge_two_mul_add_two`) and is unconditional as soon as one knows
  `¬ IdealPair K`.

## 3. Growth base data

Convolution multiplies masses and adds windows, so a seed of window `K₀` and mass `L` gives
base `L^{1/K₀}`:

| seed              | window `K₀` | mass `L` | base `L^{1/K₀}` |
|-------------------|------------:|---------:|----------------:|
| binomial `(X-1)^K`| `K`         | `2^K`    | 2.0000          |
| catalog's PTE-3   | 3           | 6        | 1.8171          |
| ideal PTE-8       | 8           | 16       | 1.4142          |
| ideal PTE-10      | 10          | 20       | 1.3493          |
| **ideal PTE-12**  | 12          | 24       | **1.3034**      |

The last row is the bound formalised in `Catalog/Applications/PTEExponentialBase.lean`:
`minMass K ≤ 24 ^ ⌈K/12⌉`, equivalently `(minMass K)^12 ≤ 24^{K+11}`.

## 4. Sequence lookup

The sequence of minimal masses `2, 4, 6, 8, 10, 12, 14, 16, 18, 20, ?, 24` is `2K` in the
certified range; the associated sizes of *ideal* PTE solutions (`1,2,…,10,12`, with `11`
unknown) are the classical PTE data.  No OEIS identifier is asserted here, since the only
sequence we prove anything about is `2K` itself.

## 5. What the evidence does **not** show

* Nothing here decides `K = 11`: an exhaustive search over node sets is infeasible, and the
  formal statement `PTEIdeal.minMass_eleven_dichotomy` reflects exactly that state of
  knowledge.
* The upper bound `24^{⌈K/12⌉}` is very likely far from the truth (the data suggest linear
  growth `2K`), but no construction below exponential is known for large `K`.
