# Theorem Trace — Anti-Gravity Theorems in the OWF Stratum

Internal anti-hallucination ledger. Every name below comes verbatim from the
Phase A Lean output (`Catalog/Cryptography/AntiGravityHierarchy.lean`, namespace
`OWFStratum`). No result is stated in the article or paper that is not listed here.

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `OWFStratum` | structure | A theorem of the one-way-function stratum recorded by a single natural number `depth`, its dependency index. | §"A number for every theorem" | Def. 1 |
| `weight` | def | `weight T = T.depth`; the number of assumptions reachable along the dependency graph. | §"Two numbers" | Def. 2 |
| `proofComplexity` | def | `proofComplexity T = T.depth.primeFactorsList.length`; number of prime factors of `depth` with multiplicity (`Ω(depth)`). | §"Two numbers" | Def. 3 |
| `weight_mk` | simp lemma | `weight ⟨n⟩ = n`. | (implicit) | Def. 2 remark |
| `proofComplexity_mk` | simp lemma | `proofComplexity ⟨n⟩ = n.primeFactorsList.length`. | (implicit) | Def. 3 remark |
| `Preorder OWFStratum` | instance | `a ≤ b ↔ weight a ≤ weight b`. | §"The skyline" | Def. 4 |
| `le_iff_weight` | theorem | `a ≤ b ↔ weight a ≤ weight b`. | §"The skyline" | Def. 4 |
| `TopologicalSpace OWFStratum` | instance | Open sets are exactly the upper sets for the weight order (Alexandrov topology). | §"The skyline" | Def. 5 |
| `isOpen_iff_isUpperSet` | theorem | `IsOpen s ↔ IsUpperSet s`. | §"The skyline" | Def. 5 |
| `isOpen_Ici` | theorem | `IsOpen (Set.Ici a)`; principal upper sets are open (basic opens). | §"The skyline" | Lem. 6 |
| `two_pow_length_le_prod` | private lemma | For a list `l` of naturals each `≥ 2`, `2 ^ l.length ≤ l.prod`. | (proof of trade-off) | Lem. 7 |
| `antigravity_tradeoff` | theorem | For `0 < weight T`, `2 ^ proofComplexity T ≤ weight T`. | §"The trade-off" (main) | Thm. 8 (main) |
| `IsAntiGravity` | def | `2 ^ proofComplexity T = weight T` (equality in the trade-off). | §"Floating theorems" | Def. 9 |
| `antiGravitySet` | def | `{T | IsAntiGravity T}`. | §"Floating theorems" | Def. 9 |
| `primeWitness` | def | `primeWitness p = ⟨2 ^ p⟩`. | §"An infinite ladder" | Def. 10 |
| `weight_primeWitness` | simp lemma | `weight (primeWitness p) = 2 ^ p`. | §"An infinite ladder" | Lem. 11 |
| `proofComplexity_primeWitness` | simp lemma | `proofComplexity (primeWitness p) = p`. | §"An infinite ladder" | Lem. 11 |
| `primeWitness_isAntiGravity` | theorem | `IsAntiGravity (primeWitness p)`. | §"An infinite ladder" | Thm. 12 |
| `primeWitness_mem` | theorem | `primeWitness p ∈ antiGravitySet`. | §"An infinite ladder" | Thm. 12 |
| `primeWitness_cofinal` | theorem | For every `a` there is a prime `p` with `a ≤ primeWitness p` (via `Nat.exists_infinite_primes`). | §"An infinite ladder" | Thm. 13 |
| `basic_open_contains_antiGravity` | theorem | Every nonempty basic open set `Set.Ici a` contains an anti-gravity theorem. | §"Density" | Lem. 14 |
| `antiGravity_dense` | theorem | The anti-gravity theorems are dense in the Alexandrov topology. | §"Density" (climax) | Thm. 15 |

External Mathlib facts used (named in proofs, not re-stated as our results):
`Nat.prod_primeFactorsList`, `Nat.prime_of_mem_primeFactorsList`, `Nat.Prime.two_le`,
`Nat.Prime.primeFactorsList_pow`, `Nat.prime_two`, `Nat.exists_infinite_primes`,
`isUpperSet_univ`, `isUpperSet_sUnion`, `isUpperSet_Ici`.
