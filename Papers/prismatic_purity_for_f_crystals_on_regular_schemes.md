# Theorem Trace (internal anti-hallucination ledger)

Every result below is taken **verbatim** from the Phase A Lean output. No theorem is
invented; no name is paraphrased into a grander claim. Columns: Lean name — informal
statement — where it appears in ARTICLE.md (A) and RESEARCH_PAPER.md (P).

## `Catalog/Novelty/FrobeniusModule.lean` (namespace `PrismaticPurity`)

| Lean name | Statement | A | P |
|---|---|---|---|
| `FMod` | An `F`-crystal model: an `R`-module `M` with a `φ`-semilinear endomorphism `F : M →ₛₗ[φ] M`. | ✓ | ✓ |
| `FHom` | Morphism of `F`-crystals: an `R`-linear map `hom` with `hom (E.F x) = E'.F (hom x)`. | ✓ | ✓ |
| `FHom.idMor`, `FHom.comp`, `FHom.id_comp`, `FHom.comp_id`, `FHom.comp_assoc` | The category axioms for `F`-crystals. | ✓ | ✓ |
| `triv` | The trivial/unit `F`-crystal `(R, φ)`. | ✓ | ✓ |
| `restriction_faithful` | If the target restriction `ρF.hom` is injective, two morphisms with equal restriction are equal. | ✓ | ✓ |
| `purityHomEquiv` | Faithfulness + a Hartogs extension operator ⟹ restriction is a bijection `FHom E F ≃ FHom EU FU`. | ✓ | ✓ |
| `cZ`, `cQ`, `rhoZQ`, `rhoZQ_injective`, `trivZ_faithful` | Concrete `ℤ ⊆ ℚ` instance; restriction to the generic point is injective. | ✓ | ✓ |

## `Catalog/Novelty/DimensionOnePurity.lean` (namespace `PrismaticPurity.DimOne`)

| Lean name | Statement | A | P |
|---|---|---|---|
| `hartogs_dim_one` | Over an integrally closed domain `R` with fraction field `K`, every `x ∈ K` integral over `R` lies in the image of `R → K`. | ✓ | ✓ |
| `extension_unique` | `algebraMap R K` is injective. | ✓ | ✓ |
| `hartogs_dim_one_unique` | `∃!` global section extending an integral element. | ✓ | ✓ |
| `hartogs_Z` | Over `ℤ ⊆ ℚ`: a rational that is integral over `ℤ` is an integer. | ✓ | ✓ |
| `hartogs_polyQ` | Over `ℚ[X] ⊆ RatFunc ℚ`: an integral rational function is a polynomial. | ✓ | ✓ |

## `Catalog/Novelty/PrismaticPurityFoundation.lean` (namespace `PrismaticPurity.Foundation`)

| Lean name | Statement | A | P |
|---|---|---|---|
| `IsXIntegral` | `f ∈ K` is `x`-integral iff `∃ n, (algebraMap R K x)^n * f ∈ range`. | ✓ | ✓ |
| `isXIntegral_of_mem_range` | Every global section is `x`-integral (take `n = 0`). | ✓ | ✓ |
| `hartogs_UFD` | Over a UFD `R` with fraction field `K`, `x ≠ 0`, `IsRelPrime x y`, `f` both `x`- and `y`-integral ⟹ `f ∈ range`. | ✓ | ✓ |
| `regularLocalDimOne_isUFD` | A Noetherian local domain with principal maximal ideal is a UFD. | ✓ | ✓ |
| `xIntegralSubalg` | The localization subalgebra `R[1/x] ⊆ K` of `x`-integral elements. | ✓ | ✓ |
| `equalizer_inf` | `xIntegralSubalg x ⊓ xIntegralSubalg y = ⊥` (i.e. `R[1/x] ∩ R[1/y] = R`). | ✓ | ✓ |
| `fibonacci_inter_eq_bot` | The `ℤ ⊆ ℚ` instance of the equalizer with consecutive Fibonacci numbers as the coprime pair. | ✓ | ✓ |
