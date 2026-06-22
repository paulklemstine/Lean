# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: the Phase A Lean file
`930ff410_retry3_aristotle/Catalog/Algebra/ProofSpectra/Core.lean`
("Proof-Theoretic Algebraic Geometry: Prime Congruence Spectra and Idempotent
Cut-Elimination"). Only names appearing in that Lean output are used in prose.

NOTE ON CONCEPT MISMATCH: the concept card is titled "Riemann Zeta: Zero-Free
Regions and Density Estimates" (NumberTheory), but the Phase A Lean code that was
actually produced is about semiring congruences and proof spectra. Per the
packaging mandate ("the Lean file is the source of truth"), ARTICLE.md,
RESEARCH_PAPER.md and RESEARCH_PAPER.tex describe the actual proved mathematics
(prime congruence spectra). The zeta future-directions text is included verbatim
in PACKAGE.json's `future_directions` field as required by the prompt.

## Definitions (from Lean)

| Lean name | Mathematical object | In ARTICLE | In PAPER |
|---|---|---|---|
| `SRCong` | semiring congruence: equiv. rel. compatible with `+`, `*` | yes | Def. 1 |
| `SRCong.zeroClass` | `{a \| C.rel a 0}`, the "ideal" of a congruence | yes | Def. 2 |
| `PrimeSRCong` | prime congruence: `rel (a*b) 0 → rel a 0 ∨ rel b 0` | yes | Def. 3 |
| `ProofSpectrum` | the type of prime congruences `PrimeSRCong R` | yes | Def. 4 |
| `vanishes` | `vanishes P a := P.rel a 0` | yes | Def. 5 |
| `zariskiClosed` | `V(S) = {P \| ∀ s∈S, vanishes P s}` | yes | Def. 6 |
| `theoryOfSpec` | `Th(X) = {a \| ∀ P∈X, vanishes P a}` | yes | Def. 7 |

## Theorems / lemmas (statements visible in the Lean output)

| Lean name | Statement | In ARTICLE | In PAPER |
|---|---|---|---|
| `SRCong.mul_left` | `C.rel a b → C.rel (f*a) (f*b)` | — | Lem. A1 |
| `SRCong.mul_right` | `C.rel a b → C.rel (a*f) (b*f)` | — | Lem. A1 |
| `SRCong.zero_mem_zeroClass` | `0 ∈ C.zeroClass` | yes | Prop. 1 |
| `SRCong.zeroClass_add_closed` | `a,b ∈ zeroClass → a+b ∈ zeroClass` | yes | Prop. 1 |
| `SRCong.zeroClass_mul_absorb` | `a ∈ zeroClass → a*b ∈ zeroClass` | yes | Prop. 1 |
| `zariskiClosed_empty_eq_univ` | `V(∅) = univ` | yes | Thm. 2 |
| `zariskiClosed_union_eq_inter` | `V(S∪T) = V(S) ∩ V(T)` | yes | Thm. 2 |
| `zariskiClosed_antiMono` | `S ⊆ T → V(T) ⊆ V(S)` | yes | Thm. 2 |
| `zariskiClosed_iInter` | `V(⋃₀ 𝒮) = ⋂₀ (V '' 𝒮)` | yes | Thm. 2 |

## Theorems named in the module docstring "Main results" (part of Lean output)

These are listed as proved results in the file header; used by name only.

| Lean name | Stated meaning |
|---|---|
| `galois_connection_theory_variety` | Galois connection `S ⊆ Th(X) ↔ X ⊆ V(S)` |
| `idempotent_add_natural_preorder` | idempotent `+` induces a natural preorder |
| `idem_add_is_join` | `+` is the join in the natural order |
| `prime_cong_zero_class_prime_theory` | zero-class of a prime congruence is a prime theory |
| `radical_fixpoint_iff_inter_primes` | `radical T = T ↔ T` is an intersection of primes |
| `radicalTheory_idempotent` | the radical operator is idempotent |
| `towerExp_ge_pow` | tower function grows faster than exponentiation |
| `nontrivial_prime_exists` | integral domains carry non-degenerate prime congruences |
| `idem_nsmul_eq` | `n • x = x` in an idempotent monoid |

No theorem outside this ledger may appear in the prose.
