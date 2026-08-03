# Computational Evidence Skipped

Computational evidence was not used because the formal target is an algorithmic
soundness and complexity theorem rather than a numerical conjecture. The core
claims are symbolic derivative identities for four constructors and structural
bounds on list traversal. Small numerical samples would not test the universal
analytic identities or the proof of termination. Instead, every constructor is
checked directly by Lean's formal derivative calculus, and the complexity bound
is proved arithmetically for arbitrary input lengths.
