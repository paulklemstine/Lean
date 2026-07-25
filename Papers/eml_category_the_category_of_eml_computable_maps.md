# Computational Evidence Justification

Computational sampling was skipped because the principal claim is structural and quantified over every finite syntax template. Its witness is constructed uniformly: for a proposed template `t`, the expression `exp t` has exactly one more AST node, whereas every permitted leaf-parameter specialization of `t` preserves AST size. Small numerical evaluation cannot test or strengthen this syntactic invariant, and equality of sampled real outputs would not address the intensional theorem.

The Lean development nevertheless includes denotational semantics and proves that syntactic substitution denotes ordinary function composition, so the obstruction is attached to the intended EML interpretation rather than to an unrelated datatype.
