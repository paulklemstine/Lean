# Computational evidence justification

Computational evidence was skipped because the deepening proved here is structural rather than
numerical. The new claims—complementarity, monotonicity, unit-interval bounds, subtraction on
relative differences, and strict increase after adjoining a point—follow exactly from the already
formalized finite-additivity law and positivity of the constructed surreal infinitesimal. Small
floating-point calculations cannot represent Conway surreal infinitesimals and would therefore not
provide faithful evidence for these claims. The Lean proofs directly verify the relevant identities
and order relations in Mathlib's `Surreal` type.
