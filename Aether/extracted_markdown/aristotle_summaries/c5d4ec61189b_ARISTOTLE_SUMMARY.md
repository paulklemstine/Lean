# Summary of changes for run 9ed9e8ee-1305-44ee-bf6c-b8bff599eb18
Created `Catalog/Bridges/SpeciesTropicalProfileCertificate.lean`, a complete, self-contained Lean file proving a sound tropical lower-bound certificate for a minimal language of combinatorial-species expressions. It compiles cleanly (verified with `lake build Bridges.SpeciesTropicalProfileCertificate`) with no `sorry`, placeholders, or stub declarations, and the main theorem's axiom footprint is only `propext`, `Classical.choice`, `Quot.sound`.

What the file contains:
- A minimal `Species` infrastructure mirroring `Catalog/Applications/CombinatorialSpecies.lean` (the `Species` structure, `coeffSeq`, the species of sets `setSpecies`, and the empty species `emptySpecies`). This is reproduced inline because the `Applications/` directory is not a configured Lean library of the package and therefore cannot be imported.
- `intBinConv`, the integer binomial convolution, together with `card_prodSpecies` and `intBinConv_card_prodSpecies`, which prove that `mul`'s semantics equal the cardinality of the structural (Day-convolution) product of species — i.e. `mul` exactly matches the catalog's species-product counting law.
- `SpExpr`: the syntax with two atoms (`sets` = species of sets, `empty` = empty species) and the two recursive constructors `add` and `mul`. The atom set was kept minimal (linear orders were intentionally omitted, per the scope instructions). 
- `SpExpr.coeff : SpExpr → ℕ → ℤ` with definitional simp lemmas `coeff_sets`, `coeff_empty`, `coeff_add`, `coeff_mul`.
- `valProfile p a n = emultiplicity (p : ℤ) (a n) : ℕ∞ (= WithTop ℕ)` as the p-adic valuation profile, and `tropLB p` computing the structural lower bound: `0`/`⊤` on atoms, pointwise `min` on `add`, and min-plus convolution over the antidiagonal on `mul`.
- The three required, fully-proved results:
  - `valProfile_add_node` — the ultrametric step (sound `min` lower bound for coefficientwise addition).
  - `valProfile_mul_node` — the min-plus convolution step (sound lower bound for the binomial convolution), supported by helper lemmas `inf_emultiplicity_le_emultiplicity_sum` and `emultiplicity_term_bound`.
  - `tropLB_le_valProfile : tropLB p e n ≤ valProfile p e.coeff n`, proved by structural induction over `SpExpr`.

This realizes the species-to-tropical certificate pipeline: a structurally computed tropical lower bound is always below the actual p-adic valuation profile of the denoted coefficient sequence.