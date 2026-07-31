# Computational Evidence Skip Justification

Computational evidence was skipped because the selected contrarian claims are
settled by exact structural witnesses rather than numerical approximation.

- The real-closedness counterexample is the Hahn monomial at rank `(1, 0, 0)`.
  Any nonzero square has an order of the form `r + r`, whose first integer
  coordinate is even, so it cannot equal that rank. The same argument handles
  the negative monomial. Sampling coefficients or floating-point evaluations
  would add no evidence to this order-theoretic obstruction.
- The failure of point-evaluation injectivity is witnessed directly by two EML
  expressions: the variable and constant zero both evaluate to zero at `0`, but
  are distinct constructors.
- The unique-first-disagreement theorem is a general consequence of linear order
  and Hahn-series coefficient extensionality, not a finite combinatorial pattern.

All three results are instead checked by complete Lean proofs in
`Catalog/Applications/EML/ContrarianTransseries.lean`.
