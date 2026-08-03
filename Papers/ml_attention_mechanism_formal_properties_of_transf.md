# Computational Evidence Skipped

The selected result is an exact symbolic invariance theorem: simultaneous reindexing of
queries, keys, and values by an arbitrary finite permutation reindexes the softmax-attention
output by the same permutation. Its proof is driven by a change of variables in finite sums
and therefore does not depend on a numerical pattern, asymptotic conjecture, or finite search.

Small floating-point experiments would add weaker evidence than the exact theorem and would
also introduce irrelevant rounding error. Accordingly, computational evidence was skipped in
favor of a kernel-checked proof valid for every finite token and feature type.
