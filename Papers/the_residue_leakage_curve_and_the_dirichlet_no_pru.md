# Computational Evidence — QR fingerprints, conductor 9240 (K = 5)

Probe basis `A₅ = [2,3,5,7,11]`, fingerprint `F(N) = [(a|N) : a ∈ A₅]`
(Jacobi symbols), predicted conductor `4·(2·3·5·7·11) = 9240`.
All numbers below were produced with `#eval` inside Lean; the ones that are
stated as theorems are additionally kernel-checked in
`Catalog/Bridges/ResidueLeakageLabNotes.lean` via the `norm_num` extension for
Jacobi symbols (no `native_decide`).

## 1. Small-case calculations

| N | factorisation | F(N) |
|---|---|---|
| 91 | 7·13 | `[-1,-1,1,0,-1]` (a = 7 divides N, symbol 0) |
| 923 | 13·71 | `[-1,1,-1,1,1]` |
| 1591 | 37·43 | `[1,-1,1,-1,1]` |

`1591` is the running target `N₀` of the experiment.

## 2. Periodicity / conductor

`F(m) = F(m + 9240)` was verified for all odd `m ≤ 399` coprime to 9240
(`true`), matching the theorem `qrFingerprint_of_modEq`
(period `4·∏A`, here 9240).  Consequences measured directly:

* units mod 9240: `φ(9240) = 1920`;
* distinct fingerprints among them: **32 = 2^5**;
* every class has exactly **60 = 1920/32** residues — the fingerprint is an
  exactly balanced surjection onto `{±1}^5`.

This already refutes "collision-free hash" as a mathematical statement: each
class is an infinite union of arithmetic progressions.

## 3. No-pruning: explicit compensators for the target `N₀ = 1591`

For each candidate prime `p` the smallest prime `q` (with `q > 11`) such that
`F(p·q) = F(N₀)`:

| p | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| q | 197 | 47 | 181 | 103 | 61 | 71 | 43 | 311 | 37 | 17 | 107 | 101 |

A larger candidate: `p = 3607` → `q = 167`.  Counterexample hunt: **no**
candidate prime `p ≤ 3607` was found for which a compensator fails to exist,
in agreement with `dirichlet_no_pruning` (which proves there are in fact
infinitely many compensators for every `p`).

Kernel-checked instances: `qrLab_compensators`.

## 4. Pattern surjectivity (no individual pinning)

Least prime witness for each of the 32 sign patterns (all patterns occur, so
`(a|p)` is unconstrained for every single `a`):

```
53, 17, 277, 181, 67, 311, 41, 107, 71, 79, 61, 113, 101, 271, 37, 59,
197, 47, 211, 239, 103, 127, 167, 19, 23, 131, 97, 43, 13, 31, 29, 479
```

Among the 429 primes `11 < p < 3000`, exactly **32** distinct fingerprints
occur — i.e. the map `p ↦ F(p)` is onto `{±1}^5` already in this range.
Kernel-checked: `qrLab_pattern_values` and `qrLab_all_32_patterns`
(the 32 fingerprints are pairwise distinct and all entries are `±1`).

## 5. OEIS

The measured sequences (`2^K` patterns, `φ(4∏ p_i)/2^K` class sizes) are the
elementary quantities `2^K` (A000079) and `φ` of primorial-type moduli
(A005867-adjacent); no new sequence appears, which is itself evidence that the
fingerprint carries no structure beyond the character group of `(ℤ/4∏A)ˣ`.

## 6. What the data suggested, and what was then proved

The data suggested (i) exact periodicity with conductor `4∏A`,
(ii) equidistribution of the `2^K` classes, (iii) a compensator for every
candidate. All three became theorems: `qrFingerprint_of_modEq`,
`qrFingerprint_range_eq` / `qrFingerprint_pattern_surjective`, and
`dirichlet_no_pruning`.
