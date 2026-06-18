# Future Directions: Proof System Collapse Theory

## Synthesis

This cycle bootstraps an abstract, Cook–Reckhow-style theory of **proof systems**
and the **simulation preorder** in `Catalog/Logic/ProofSystemCollapse.lean`. A
proof system over a formula type `F` is carried as honest data — a type of
`Proof` objects, a `concl`usion map, and a `size` function — rather than reduced
to its provability set. This choice is the spine of the whole development: the
*same* structural constructions that witness the lattice structure of the
qualitative preorder (a `Sum` of proofs for the join, a conclusion-matched
subtype of pairs for the meet) also transport the quantitative *size* bounds,
which is exactly what the polynomial refinement needs.

We proved the qualitative layer in full — `Simulates` is a preorder, `union` is
the categorical join and `inter` the meet (each with provability characterization
and universal property), the `singletonSys` duality collapses point-provability
to a simulation statement, and a complete system simulates every sound one
(`complete_simulates_all_sound`), with the corresponding top-of-the-preorder
collapse `complete_systems_equivalent`. We then lifted the join to the
quantitative world: `PSimulates` (polynomial simulation via an explicit monomial
bound `c·(n+1)^k`) is a preorder (`psim_refl`, `psim_trans`), it refines
qualitative simulation (`psim_implies_simulates`), and polynomial boundedness is
closed under join (`pbounded_union`).

## Results Summary

- `simulates_refl`, `simulates_trans` — the simulation preorder.
- `provable_union`, `union_simulates_left/right`, `union_least` — `union` is the join.
- `provable_inter`, `simulates_inter_left/right`, `inter_greatest` — `inter` is the meet.
- `simulates_singleton_iff` — singleton/point-provability duality.
- `complete_simulates_all_sound`, `complete_systems_equivalent` — maximality and collapse.
- `psim_refl`, `psim_trans`, `psim_implies_simulates` — the polynomial-simulation preorder.
- `pbounded_union` — polynomial boundedness is preserved by the lattice join.

All main results are `sorry`-free.

## Research Directions

### 1. Indexed (finite) joins preserve polynomial boundedness

We proved `pbounded_union` for binary joins. The natural escalation is the
*indexed* union `iUnion` of a finite family `S : Fin m → ProofSys F`, with a
proof type `Σ i, (S i).Proof`, and the theorem that if every `S i` is `PBounded`
then so is `iUnion S`. **The key insight is** that the binary merge — take the
sum of the constants and the max of the exponents — is associative and has a
neutral element (the empty system, whose proof type is `Empty`), so the binary
closure lemma extends by `Finset.induction` to any finite index set with
constants `∑ cᵢ` and exponent `max_i kᵢ`. **Why now?** The monomial-bound
bookkeeping is already isolated in `pbounded_union`; only the inductive plumbing
over `Fin m` remains, which Mathlib's `Finset.sup`/`Finset.induction` API handles
directly. Falsifiable form: the theorem fails for *infinite* index sets, since
the exponent supremum need not exist — a clean boundary the formalization should
pin down.

### 2. A bounded-lattice instance on simulation-equivalence classes

`union` and `inter` satisfy the join/meet universal properties, so the quotient
of `ProofSys F` by mutual simulation should be a genuine `Lattice` (indeed a
bounded lattice, with the empty system as `⊥` and the system proving all of `F`
as `⊤`). **The key insight is** that `Simulates` is a preorder whose induced
equivalence (`Simulates S T ∧ Simulates T S`) has `union`/`inter` as well-defined
representatives — provability is the only invariant that matters, so the quotient
is order-isomorphic to the lattice of *provability sets* `Set F` under inclusion.
**Why now?** Mathlib's `Antisymmetrization` and `OrderHom` machinery turns a
proven preorder plus join/meet universal properties into a `Lattice` instance
almost mechanically. Falsifiable prediction: the resulting lattice is *complete*
(arbitrary joins/meets exist) precisely because `Set F` is complete — so any
claim that some family of proof systems lacks a least upper bound must fail.

### 3. The category of proof systems and proof-translation morphisms

Define `ProofSysMorphism S T` as a conclusion-preserving map `T.Proof → S.Proof`;
identities and composition make `ProofSys F` a category, and the existence of a
morphism implies `Simulates S T`. **The key insight is** that polynomial
simulation `PSimulates` is the sub-`Hom` of morphisms carrying a monomial size
bound, and `psim_trans` is precisely the statement that these bounded morphisms
are closed under composition — i.e. they form a (wide) subcategory. **Why now?**
`psim_refl`/`psim_trans` already provide the identity and composition laws at the
`Prop` level; promoting them to a `CategoryTheory.Category` instance is a matter
of bundling the data. Falsifiable target: `union`/`inter` are the categorical
coproduct/product in this category (not merely the order-theoretic join/meet),
which predicts specific universal arrows that either exist or do not.

### 4. EML-evaluated proof systems and depth-bounded simulation

Instantiate `ProofSys` with proofs whose verification is an `EMLExpr` evaluation
(reusing `Catalog/Applications/EMLTermAlgebra.lean` and the `towerExpr_depth`
depth bounds), with `size` taken to be EML expression depth. **The key insight
is** that `psim_trans`'s monomial composition law becomes a *depth* composition
law: an EML proof system that p-simulates another does so with depth blowup
controlled by `towerExpr_depth`, so an EML-Frege system would have proof depth
exactly trackable through the existing tower-depth theorems. **Why now?** The EML
depth calculus is already formalized with exact bounds, supplying the quantitative
control `PSimulates` consumes. Falsifiable conjecture: there is an EML-based
system that p-simulates the singleton/union systems but whose depth bound is
*strictly* sub-polynomial in formula size — separating EML-depth from
EML-size complexity.

### 5. Finite formula spaces, decidability, and Dedekind numbers

When `F = Fin n`, `Provable` becomes decidable and the simulation preorder is a
finite poset; restricted to sound systems for a fixed `valid`, the
simulation-equivalence classes are in bijection with subsets of the valid
formulas. **The key insight is** that, because mutual simulation depends only on
the provability set, the equivalence classes of *all* (not necessarily sound)
systems on `Fin n` are exactly the elements of the powerset lattice `Set (Fin n)`
— so counting classes under a soundness-and-deductive-closure constraint counts
*antichains*, i.e. yields Dedekind numbers. **Why now?** `Fintype`/`Decidable`
instances make provability `#eval`-computable, so small cases (`n ≤ 4`) can be
enumerated and checked against the known Dedekind sequence as an empirical test.
Falsifiable prediction: the number of closure-respecting equivalence classes for
`F = Fin n` matches `M(n)` (the n-th Dedekind number); any computed mismatch
refutes the bridge.
