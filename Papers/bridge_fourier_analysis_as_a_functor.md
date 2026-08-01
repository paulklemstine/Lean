# Computational Evidence Skip Justification

A separate computational-evidence stage is unnecessary for this mission because every small-case calculation used in the research is encoded and kernel-checked directly in `Catalog/Bridges/FourierAsFunctor.lean`:

- both products of the explicit two-point DFT and inverse matrices are proved equal to the identity;
- the failure of unrestricted naturality is proved at a specific matrix entry using an explicit projection;
- the support-size counterexample is evaluated inside Lean.

No integer sequence arises, so an OEIS search is inapplicable. There are no numerical plots whose evidence would strengthen these exact finite algebraic identities. Keeping these calculations in the theorem file avoids maintaining a weaker, non-verified duplicate table.
