import Cryptography.Factoring.PadicFactoring

/-! # CatalogBuild.Speculative.AutoResearch.non_archimedean_factoring_oracle

See `Cryptography/Factoring/PadicFactoring.lean` for the full formalization.

The original theorem `pAdic_factoring_oracle` is false as stated (fails for primes).
We provide a corrected version `pAdic_factoring_oracle_corrected` and a formal
disproof `pAdic_factoring_oracle_false` of the original statement.
-/

#check pAdic_factoring_oracle_corrected
#check pAdic_factoring_oracle_false
