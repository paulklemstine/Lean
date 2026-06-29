# The Topological Inverse-Limit Core of Projective Fraïssé Theory

*A formal Lean 4 development.*
Source file: `Catalog/Pythagorean/ProjectiveFraisseInverseLimitCore.lean`.

## 1. Mathematical context

Projective Fraïssé theory, introduced by Irwin and Solecki, is the
"dual" of classical Fraïssé theory. Where classical Fraïssé theory builds a
countable ultrahomogeneous structure as a *direct* limit of finite structures
with embeddings, projective Fraïssé theory builds a compact, second-countable
("Polish") topological structure as an **inverse limit** of finite structures
with *epimorphisms*. The prototypical example is Solecki's construction of the
**pseudo-arc** as the canonical projective Fraïssé limit of finite linear graphs.

The theory acquired major importance in topological dynamics. Following the
Kechris–Pestov–Todorčević correspondence on the direct side, Kwiatkowska and
others used projective Fraïssé limits to compute **universal minimal flows** of
homeomorphism groups (for instance of the pseudo-arc and of the Lelek fan),
turning the computation of these flows into combinatorial Ramsey statements
about the approximating finite categories.

Every one of these constructions rests on a single topological object: the
**inverse limit of an inverse sequence of finite discrete spaces**. Before any
Fraïssé-theoretic content (amalgamation, projective universality,
ultrahomogeneity) can be discussed, one needs to know that this inverse limit is

* **nonempty** (so the limit object exists),
* **compact** (so it is a genuine continuum / compact space), and
* **metrizable** (so it is a Polish space and the dynamical machinery applies).

This file formalizes exactly that core, for inverse sequences indexed by `ℕ`,
and deliberately stops there.

## 2. Definitions

Fix a sequence of *levels* and *bonding maps*

```
F    : ℕ → Type*
bond : ∀ n, F (n+1) → F n.
```

The **inverse-limit set** lives inside the product space `∀ n, F n`:

```
InvLimit bond = { x : ∀ n, F n | ∀ n, bond n (x (n+1)) = x n }.
```

A point `x` of `InvLimit bond` is a *compatible thread*: a choice of one element
`x n` at each level that is coherent under the bonding maps. The **inverse-limit
space** is the corresponding subtype, carrying the subspace topology induced from
the product topology when each `F n` is a topological space:

```
InvLimitSpace bond = { x : ∀ n, F n // x ∈ InvLimit bond }.
```

In the file `InvLimitSpace` is an `abbrev`, so that Mathlib's subtype instances
(`TopologicalSpace`, `CompactSpace`, `MetrizableSpace`, …) are inherited
transparently.

## 3. Main results

All statements live in the `ProjectiveFraisse` namespace.

1. **Closedness** — `isClosed_invLimit`.
   If each level is a Hausdorff topological space (`[∀ n, T2Space (F n)]`) and
   each bonding map is continuous, then `InvLimit bond` is closed in `∀ n, F n`.

2. **Nonemptiness** — `nonempty_invLimit`.
   If `Nonempty (F 0)` and every `bond n` is surjective, then `InvLimit bond` is
   nonempty.

3. **Compactness** — `compactSpace_invLimit`.
   For compact Hausdorff levels with continuous bonds, `InvLimitSpace bond` is a
   `CompactSpace`.

4. **Metrizability** — `metrizableSpace_invLimit`.
   For metrizable, second-countable levels, `InvLimitSpace bond` is a
   `MetrizableSpace`.

5. **Assembled core** — `projectiveFraisse_inverseLimit_core`.
   Under the combined hypotheses (compact, Hausdorff, metrizable,
   second-countable levels, `Nonempty (F 0)`, continuous and surjective bonds),
   the inverse limit is nonempty, compact, and metrizable.

6. **Finite-discrete specialization** — `finiteDiscrete_inverseLimit_core`.
   For finite discrete levels with `Nonempty (F 0)` and surjective bonds, the
   inverse limit is nonempty, compact, and metrizable — all topological side
   conditions being discharged automatically.

The development uses only the standard foundational axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## 4. Proof sketches

### Closedness
Rewrite the inverse limit as an intersection of equalizers,
`InvLimit bond = ⋂ n, { x | bond n (x (n+1)) = x n }`
(`invLimit_eq_iInter`). For each `n`, the two sides `x ↦ bond n (x (n+1))` and
`x ↦ x n` are continuous: the second is the coordinate projection
`continuous_apply n`, and the first is that projection (at index `n+1`) composed
with the continuous `bond n`. Equality of two continuous maps into a Hausdorff
space is a closed condition (`isClosed_eq`), and an intersection of closed sets
is closed (`isClosed_iInter`). The discrete case is the special instance where
the discrete topology is Hausdorff and every map is continuous.

### Nonemptiness
Build a compatible thread by recursion on `ℕ`. At level `0` pick any point of
`F 0` (using `Nonempty (F 0)` via `Classical.arbitrary`). Given the value `x n`
at level `n`, surjectivity of `bond n` yields a preimage; choose one with
`Classical.choose`, defining `x (n+1)`. The compatibility equation
`bond n (x (n+1)) = x n` is precisely `Classical.choose_spec`. This is
constructive in the mathematical sense — an explicit recursion plus choice — and
uses neither compactness nor König's lemma. (Formally the construction is the
`thread` definition, with `thread_succ` and `thread_mem_invLimit` recording its
properties.)

### Compactness
The ambient product `∀ n, F n` is compact by Tychonoff (`Pi.compactSpace`). A
closed subset of a compact space is compact (`IsClosed.isCompact` applied to
`isClosed_invLimit`), and `isCompact_iff_compactSpace` upgrades this to a
`CompactSpace` instance on the subtype.

### Metrizability
A countable product of second-countable metrizable spaces is again
second-countable and regular Hausdorff, hence metrizable by the **Urysohn
metrization theorem** (Mathlib synthesizes the instance through
`metrizableSpace_of_t3_secondCountable`). A subspace of a metrizable space is
metrizable. The `SecondCountableTopology` hypothesis is automatic for finite
discrete levels (every finite space is second countable); it is included
explicitly because Mathlib's *finite*-product metrizability instance does not
apply to a `ℕ`-indexed product, and because an arbitrary countable product of
metrizable spaces need not be metrizable without a countability constraint on the
factors.

## 5. Significance for projective Fraïssé limits

The finite-discrete specialization is precisely the setting of projective Fraïssé
theory: the levels `F n` are finite structures (carried by finite discrete
spaces) and the bonds are surjective epimorphisms. The theorem
`finiteDiscrete_inverseLimit_core` guarantees that the underlying space of any
such inverse sequence is a nonempty, compact, metrizable space — a *compact
metrizable structure* in the sense of Irwin–Solecki — onto which the relational
structure and the projective Fraïssé limit are then built. In other words, this
file provides the topological substrate on which the entire theory stands.

## 6. What remains open / out of scope

This development proves *only* the topological core. It does **not** address:

* the **category-theoretic Fraïssé conditions** (joint projective embedding and
  projective amalgamation) and the resulting existence/uniqueness of the
  projective Fraïssé limit as a structure, not merely a space;
* **projective ultrahomogeneity** and projective universality of the limit;
* the **Ramsey-theoretic characterization** of extreme amenability of the
  automorphism group (the projective KPT correspondence);
* the **computation and metrizability of universal minimal flows** of the
  associated homeomorphism groups.

Each of these is a substantial further layer. The full universal-minimal-flow
metrization program is explicitly *not* claimed here; see `FUTURE_DIRECTIONS.md`
for concrete next steps toward it.
