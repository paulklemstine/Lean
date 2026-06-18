# Future Directions: Higher Signatures, Assembly, and Baum–Connes

The file `Bridges/NovikovHigherSignatures.lean` isolates the *purely algebraic skeleton* of the
Novikov conjecture: it proves, with no axioms beyond `propext`/`Quot.sound`, that injectivity (or
mere splitting) of an abstract assembly map `μ : H →+ K`, together with the index formula
`μ ∘ higherSig = symmSig` and homotopy invariance of `symmSig`, forces homotopy invariance of the
higher signatures, and it shows by explicit counterexample (`novikov_needs_injectivity`) that the
injectivity hypothesis cannot be removed. The bundled `HigherSignatureTheory G` records the
conjecture as `NovikovHolds` for an arbitrary group `G`, with the trivial-group case discharged.
The following directions turn this skeleton into mathematics with real content.

## 1. Rationalize the receptacles and prove "rational injectivity suffices"

Right now injectivity is asked of `μ : H →+ K` on the nose. The actual Novikov conjecture only
needs injectivity *after tensoring with `ℚ`*. Build `H_ℚ := H ⊗[ℤ] ℚ`, `K_ℚ := K ⊗[ℤ] ℚ`, the
induced map `μ_ℚ`, and prove `Function.Injective μ_ℚ → NovikovHolds` for higher signatures valued
in the rationalization. **The key insight is** that for the higher *signature* (an `L`-class /
characteristic-number pairing) the relevant classes are already rational, so injectivity of
`μ_ℚ` is both necessary and sufficient, and torsion in `H` is irrelevant. **Why now?** Mathlib's
`TensorProduct` and `Module ℚ` API (flatness of `ℚ`, `LinearMap.rTensor`) is mature enough to make
the rationalized assembly map and its injectivity a finite, mechanical extension of the present
`AddMonoidHom` argument.

## 2. Make the assembly map concrete for `ℤⁿ` via the Fourier/torus model

Replace the abstract `μ` with the genuine assembly map for free abelian groups, where
`B(ℤⁿ) = Tⁿ` and the assembly map is an isomorphism `H_*(Tⁿ; ℚ) ≅ L_*(ℤ[ℤⁿ]) ⊗ ℚ` realized by
Fourier theory / the Shapiro lemma. Prove `StrongNovikov` for `ℤⁿ` by exhibiting an explicit
left inverse and feed it to `novikov_of_split_assembly`. **The key insight is** that for `ℤⁿ` the
"transfer map" is literally an averaging/integration over the dual torus, so the splitting can be
written down rather than invoked abstractly. **Why now?** The split-injectivity lemma is already in
place; only the construction of the explicit retraction `K →+ H` for the group ring `ℤ[ℤⁿ]` is
missing, and this is a finite linear-algebra computation.

## 3. Formalize the descent principle: subgroups and products inherit Novikov

Prove closure properties of the class `{ G : NovikovHolds }`: if `H ≤ G` and `G` satisfies Strong
Novikov then so does `H` (restriction of the assembly map), and `StrongNovikov G₁ → StrongNovikov
G₂ → StrongNovikov (G₁ × G₂)` via the Künneth/external-product structure on assembly. **The key
insight is** that injectivity of assembly is *functorial and monoidal* in the group, so the
permanence properties are statements about commuting squares of `AddMonoidHom`s rather than about
manifolds at all. **Why now?** These are diagram-chase lemmas on `→+` maps that the current
abstraction supports directly; they convert the single-group result into a genuine theorem schema
over a large class of groups (all finitely generated abelian, all their subgroups and products).

## 4. Bridge to Baum–Connes: K-theory assembly and the γ-element

Introduce a parallel `HigherSignatureTheory`-style structure for the *topological K-theory*
assembly map `μ_K : K_*^{top}(BG) → K_*(C*_r G)` and prove that a Baum–Connes section (the
"γ-element equals 1" condition) yields split injectivity, hence Novikov, through exactly the
`novikov_of_split_assembly` mechanism. **The key insight is** that the L-theory and K-theory
assembly maps share one formal pattern — a transfer splitting — so a single abstract lemma
("a left inverse of assembly ⇒ homotopy invariance of the pushed-forward index class") covers both
signatures and Dirac operators. **Why now?** The abstract splitting theorem already proven here is
literally the C*-algebraic mechanism; wiring a second instance to it demonstrates the cross-theory
unification that is the conceptual heart of the Baum–Connes ↔ Novikov relationship.

## 5. A homotopy-theoretic counterexample boundary: non-injective assembly in the wild

Strengthen `novikov_needs_injectivity` from a toy `ℤ/2` example to a structurally meaningful one:
exhibit an abstract theory where `H` has a nontrivial kernel class detected by no homotopy-invariant
in `K`, modeled on the failure of *integral* (as opposed to rational) injectivity. **The key
insight is** that the gap between integral and rational assembly is exactly a kernel/torsion
phenomenon, so a faithful counterexample lives entirely inside finitely generated abelian groups and
their `Ext`/torsion. **Why now?** Pinpointing where injectivity fails sharpens the rationalization
program of Direction 1 and gives a falsifiable test: any proposed strengthening to *integral*
homotopy invariance of higher signatures must be consistent with such a counterexample, and the
present `AddCommGroup` framework can encode it without any manifold topology.
