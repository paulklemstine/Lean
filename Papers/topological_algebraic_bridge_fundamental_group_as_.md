# Why a Computational Evidence Stage Was Skipped

The principal claim is structural rather than numerical: it classifies connected groupoids by the automorphism group at one object, and interprets connected groupoids as algebraic models of connected homotopy 1-types. There is no naturally associated integer sequence or informative range of small numerical instances, so an OEIS search, plots, and numerical tables would not test the claim.

The counterexample is also exact and finite: the discrete spaces `Unit` and `Bool` have one and two points respectively. Their based fundamental groups are proved trivial in Lean, while any homotopy equivalence between totally disconnected spaces is proved to induce a bijection of points. Thus the relevant “small-case check” is already subsumed by the machine-checked proof rather than requiring separate computational evidence.
