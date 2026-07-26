# Why computational evidence was skipped

The formal theorem proved in this project is a structural implication valid for
an arbitrary well-quasi-order: a downward-closed class has a finite forbidden
set.  It has no numerical instances whose initial terms could usefully be
computed, and no associated OEIS sequence.

The suggested experiment is also circular as stated: “ternary matroid” means
“matroid representable over `F₃`,” so checking that enumerated ternary matroids
are `F₃`-representable cannot find a counterexample.  Excluded minors for
ternary representability must instead be sought among non-ternary matroids by
checking all proper deletion/contraction minors.

Finally, finite checks cannot establish the theorem’s well-quasi-ordering
premise, which quantifies over infinite sequences.  For these reasons,
computational evidence would neither test the formal claim nor provide a
meaningful approximation to it.  A corrected future experiment is described in
`FUTURE_DIRECTIONS.md`.
