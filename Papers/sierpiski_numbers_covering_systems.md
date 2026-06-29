# Theorem Trace (internal anti-hallucination record)

Source of truth: `Catalog/Computation/SierpinskiCovering.lean` (259 lines, no `sorry`).

Every claim in ARTICLE.md and RESEARCH_PAPER.md must trace to one of the entries below.
The Lean file does **not** assemble a complete `SierpinskiCertificate 78557` term, and it
states minimality as a *conjecture* (`SierpinskiMinimalityConjecture`), not a theorem.
Prose must reflect this honestly: the framework + soundness theorem + explicit covering
data are formal; "78557 is a Sierpiński number" follows from the data informally and
"78557 is the smallest" is an open problem stated formally as a `Prop`.

| Lean name | Kind | Statement (math) | Article | Paper |
|---|---|---|---|---|
| `CongruenceClass` | structure | residue `a`, modulus `m>0`, `a<m` | §"Covering" | Def 1 |
| `CoveringSystem` | structure | nonempty list of classes covering every `n` | §"Covering" | Def 2 |
| `SierpinskiCertificate k` | structure | covering + primes with divisibility & order conditions | §"Certificate" | Def 4 |
| `IsComposite n` | def | `1 < n ∧ ¬ Nat.Prime n` | §"Sierpiński" | Def 3 |
| `IsSierpinskiNumber k` | def | `Odd k ∧ 0<k ∧ ∀ n>0, IsComposite (k·2^n+1)` | §"Sierpiński" | Def 3 |
| `pow_mod_congr` | thm | `2≤p, 2^m≡1[p], n%m=a, 0<m ⟹ 2^n≡2^a [MOD p]` | §"Clockwork" | Lem 5 |
| `divisor_transfers` | thm | `p∣k·2^a+1, 2^n≡2^a[p] ⟹ p∣k·2^n+1` | §"Clockwork" | Lem 6 |
| `certificate_gives_divisor` | thm | valid cert ⟹ `∃ p∈primes, p∣k·2^n+1` ∀n | §"Main" | Thm 7 |
| `CoveringSystem.lcm_moduli` | def | foldl lcm of moduli | §"Finite check" | Def 8 |
| `covering_system_lcm_period` | thm | `n%m = (n+lcm)%m` for each class modulus | §"Finite check" | Lem 9 |
| `covering_finite_verification` | thm | infinite coverage ⟺ coverage on `Fin lcm` | §"Finite check" | Thm 10 |
| `CongruenceClass.compatible` | def | `∃ n` in both classes | §"CRT" | Def 11 |
| `crt_compatible` | thm | coprime moduli ⟹ compatible | §"CRT" | Thm 12 |
| `mkCC` | def | constructor helper | (data) | (data) |
| `sierpinski78557_classes` | def | 7 classes, moduli {2,4,3,12,18,36,9} | §"78557" | §"Certificate for 78557" |
| `sierpinski78557_primes` | def | `[3,5,7,13,19,37,73]` | §"78557" | §"Certificate for 78557" |
| `covering_moduli_pos` | thm | each modulus > 0 | — | Lem 13 |
| `singleton_covering_modulus_one` | thm | single residue-0 class covering all ⟹ modulus 1 | — | Lem 14 |
| `uniform_covering_card` | thm | all moduli `=m` ⟹ `m ≤ #classes` | §"Density" | Thm 15 |
| `covering_by_parity` | thm | even-cover ++ odd-cover covers all | §"Density" | Lem 16 |
| `SierpinskiMinimalityConjecture` | def (Prop) | `∀k, IsSierpinskiNumber k → 78557 ≤ k` | §"Open" | §"Open problem" |
| `TestPrediction_21181` | def (Prop) | `∃ n, Nat.Prime (21181·2^n+1)` | §"Open" | §"Open problem" |

Covering data verified numerically (coverage + divisibility + order) for all `n` in `0..399`.
