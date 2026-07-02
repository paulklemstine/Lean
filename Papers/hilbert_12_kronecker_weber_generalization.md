# Computational Evidence — Hilbert 12 / Kronecker–Weber generalization

This cycle targets the *explicit class field theory* interface: cyclotomic Galois
degrees (`GL(1)/ℚ`) and the Hilbert-class-field degree law (`[H:K] = h_K`). The
numerical checks below motivated and constrained the three Lean files
(`CyclotomicGaloisDegree`, `KroneckerWeberRealization`, `HilbertClassFieldReciprocity`).

## 1. Cyclotomic degrees `[ℚ(ζₙ):ℚ] = φ(n)`

| n  | φ(n) | (ZMod n)ˣ cyclic? | Gal(ℚ(ζₙ)/ℚ) structure |
|----|------|-------------------|------------------------|
| 1  | 1    | yes               | trivial                |
| 2  | 1    | yes               | trivial                |
| 3  | 2    | yes               | C₂                     |
| 4  | 2    | yes               | C₂                     |
| 5  | 4    | yes               | C₄                     |
| 7  | 6    | yes               | C₆                     |
| 8  | 4    | **no**            | C₂ × C₂                |
| 12 | 4    | **no**            | C₂ × C₂                |
| 15 | 8    | **no**            | C₂ × C₄                |

`φ = ` A000010 (OEIS). The "cyclic?" column confirms that cyclicity of the
cyclotomic Galois group is **prime-restricted** (fails first at `n = 8`), which is
exactly why `isCyclic_galois_prime` is guarded to prime moduli rather than stated
for all `n`.

## 2. Prime case `[ℚ(ζₚ):ℚ] = p − 1`

`p = 2,3,5,7,11,13 → p−1 = 1,2,4,6,10,12`, matching `φ(p) = p−1` and the finite-field
cyclicity `𝔽ₚˣ ≅ C_{p−1}`. This is `card_galois_prime`.

## 3. Kronecker–Weber realization (subfield lattice of ℚ(ζₙ))

Sampling `n = 12`: `Gal = C₂ × C₂` has 5 subgroups, all normal (abelian group), so all
5 intermediate fields `ℚ, ℚ(i), ℚ(√3), ℚ(√-3), ℚ(ζ₁₂)` are abelian over `ℚ`. No
counterexample to "every subfield of a cyclotomic field is abelian over ℚ" was found —
consistent with `intermediate_isGalois` + `intermediate_galois_abelian`.

## 4. Hilbert class field degree law `[H:K] = h_K`

Class numbers of small imaginary quadratic fields `ℚ(√-d)` (A000924-adjacent data):

| d (squarefree) | h_K | predicted [H:K] |
|----------------|-----|-----------------|
| 1, 2, 3, 7, 11 | 1   | 1 (H = K)       |
| 5             | 2   | 2               |
| 23            | 3   | 3               |
| 14            | 4   | 4               |

The `h_K = 1` rows are the content of `finrank_one_of_classNumber_one`; the
non-vacuity witness is `K = ℚ` with `h_ℚ = 1` (`Rat.classNumber_eq`), giving
`[ℚ:ℚ] = 1`. No counterexample to `[H:K] = h_K` exists — it is a theorem of class
field theory, and here it is derived formally from the Artin reciprocity isomorphism
`Gal(H/K) ≃ Cl(𝒪_K)`.

## Counterexample hunt summary
- "All cyclotomic Galois groups cyclic": **FALSE**, first counterexample `n = 8`.
  Result correspondingly guarded to primes.
- "Every subfield of ℚ(ζₙ) abelian over ℚ": no counterexample; proved.
- "[H:K] = h_K": no counterexample; proved from reciprocity datum.
