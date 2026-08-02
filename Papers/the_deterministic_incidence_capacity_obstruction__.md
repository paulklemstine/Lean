# Computational Evidence Stage — Justification for Skipping

The result pursued in this cycle is an exact arithmetic identity valid for all
natural numbers `Δ` and `k`, not an empirical asymptotic assertion. Once a
vertex has target degree `Δ` and each of `⌈Δ/2⌉ + k` layers contributes exactly
two incidences, repeated multiplicity is forced symbolically to be

`2 * k + Δ % 2`.

The Lean development proves this universally and also proves that a genuine
contained cover identifies the layer-incidence union with the target incidence
set. Enumerating small graphs would therefore provide weaker evidence than the
formal proof. No numerical sequence arises beyond alternating parity values, so
an OEIS search is not relevant. The even and odd cases are separately captured
by machine-checked theorems.
