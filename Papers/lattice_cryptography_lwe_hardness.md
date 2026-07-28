# Why a separate computational-evidence stage was skipped

The selected results are universal inequalities for arbitrary finite probability
spaces and arbitrary finite commutative rings. Their content is structural
(triangle inequalities, bounded tests, and permutation invariance), rather than
a numerical conjecture with an informative sequence of small cases. The existing
`LWE.boolPoint` kernel-checked examples already test the relevant normalization:
opposite point masses have ℓ¹ gap 2 and identical point masses have gap 0.

Accordingly, an OEIS search, plots, or a numerical counterexample sweep would not
add meaningful evidence. The deliverable instead gives complete symbolic Lean
proofs covering every finite instance.
