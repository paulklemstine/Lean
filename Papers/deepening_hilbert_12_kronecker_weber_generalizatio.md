# Computational evidence skipped

Computational evidence is unnecessary for this extension because the new claims are structural consequences of an assumed Artin reciprocity group isomorphism and the tower law for finite field extensions. They do not posit a numerical pattern inferred from samples. The proofs quantify over arbitrary number fields, finite Galois extensions, and intermediate fields; small-case computations would neither strengthen nor test the decisive hypotheses. The existing rational witness in `Catalog/Novelty/HilbertClassFieldReciprocity.lean` already establishes that the reciprocity interface is non-vacuous.

The same reasoning applies to the descent results added in
`Catalog/NumberTheory/HilbertClassFieldDescent.lean` and
`Catalog/NumberTheory/CyclicClassGroupDescent.lean`: the class-group Galois correspondence, the
identities `[L : K] = index` and `[H : L] = order`, the character descent criterion and the
classification of intermediate fields for a cyclic class group are all consequences of the
Galois correspondence and Lagrange's theorem applied to the assumed reciprocity isomorphism, and
hold for every number field.  The rational witness is instantiated formally in
`CyclicClassGroupDescent.existsUnique_intermediateField_finrank_rat`, so the hypotheses are
certified satisfiable inside Lean rather than by numerical sampling.

The two modules added in this cycle,
`Catalog/NumberTheory/KleinFourClassField.lean` and
`Catalog/NumberTheory/ClassFieldTransfer.lean`, are in the same situation, with one difference:
the only finite datum they involve — the subgroup lattice of the Klein four group — is not
sampled numerically but decided inside Lean.  The classification of the four elements of
`Multiplicative (ZMod 2 × ZMod 2)` and their products is discharged by `decide`, and the
subgroup count `Nat.card (Subgroup V) = 5` is derived from that classification, so the
"computational" part of the argument is itself kernel-checked.  The transfer results are
identities of group homomorphisms valid for every finite commutative group, hence again not
amenable to informative sampling.
