# The Hodge Filtration as a Complete Invariant of a Weight-Two Hodge Structure

## Abstract

A pure Hodge structure can be described in two dual languages: the **decomposition**
language of the Hodge bigrading `V_ℂ = ⊕_{p+q=k} H^{p,q}`, and the **filtration**
language of the decreasing Hodge filtration `Fᵖ = ⊕_{i ≥ p} H^{i,k−i}`. The decomposition
is concrete but unstable in families; the filtration is robust and varies
holomorphically, but apparently discards the individual graded pieces. We develop, in
the weight-two case and over the rational numbers, the precise dictionary that
reconciles the two. The central result is that the Hodge filtration `F²  ⊆  F¹  ⊆  F⁰`,
**together with complex conjugation**, is a complete invariant of the Hodge structure:
the bigrading is recovered by the *opposition relations* `Fᵖ ⊕ conj(F^{k−p+1}) = V_ℂ` and
the *reconstruction identity* `H^{p,q} = Fᵖ ∩ conj(F^q)`, of which the decisive instance
is `H¹¹ = F¹ ∩ conj(F¹)`. We isolate the exact algebraic hypothesis the reconstruction
requires — a genuine internal direct sum of the three pieces, strictly stronger than
pairwise-trivial intersection — and show that, under it, reconstruction reduces to a
single application of the modular law in the lattice of submodules. This is the
linear-algebraic shadow of the degeneration of the Hodge-to-de Rham spectral sequence at
the first page for compact Kähler manifolds. All results have been formally verified.

**Keywords.** Hodge structure, Hodge filtration, Hodge decomposition, opposition,
complex conjugation, modular lattice, spectral sequence degeneration, Lefschetz (1,1).

**Mathematics Subject Classification.** 14C30 (Transcendental methods, Hodge theory),
14D07 (Variation of Hodge structures), 06C05 (Modular lattices), 32G20 (Period
mappings).

---

## 1. Introduction

### 1.1 Two languages for a Hodge structure

Let `X` be a smooth projective complex variety of even cohomological degree `k = 2`. Its
second rational cohomology `V = H²(X, ℚ)` is a finite-dimensional `ℚ`-vector space, and
its complexification `V_ℂ = ℂ ⊗_ℚ V` carries the **Hodge decomposition**

```
V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²,
```

an internal direct sum of complex subspaces indexed by bidegree `(p, q)` with `p+q = 2`.
The middle piece `H¹¹` is where geometry concentrates: by the Lefschetz (1,1) theorem,
every rational class lying in `H¹¹` is the cohomology class of an algebraic divisor.

There is a second, equivalent encoding. The **Hodge filtration** is the decreasing chain
of complex subspaces obtained by accumulating the graded pieces from the top:

```
Fᵖ = ⊕_{i ≥ p} H^{i, k−i},     so     F² = H²⁰,  F¹ = H²⁰ ⊕ H¹¹,  F⁰ = V_ℂ.
```

These two encodings are not merely both available; they are *dual*, and the duality is
foundational. The decomposition is intuitive and computational, but the subspaces
`H^{p,q}` are defined analytically (via harmonic representatives for a chosen Kähler
metric) and do **not** vary holomorphically as `X` deforms in a family. The filtration,
by contrast, varies holomorphically: it is the object that defines a *variation of Hodge
structure* and a *period map*. To do Hodge theory in families one works with `F•`, not
with the `H^{p,q}` directly.

### 1.2 The reconstruction problem

Passing from the decomposition to the filtration is a forgetful operation: `F•` records
only cumulative sums. The natural question is whether it is *reversible*. Given only the
nested chain `F² ⊆ F¹ ⊆ F⁰`, can one recover the graded pieces `H^{p,q}`?

Over `ℂ` and with no further data the answer is **no**: a flag of subspaces does not
determine a splitting. The resolution uses the one piece of structure the filtration
language suppresses: the **real (rational) structure**, manifested as complex
conjugation `conj` on `V_ℂ`. Conjugation interacts with the bigrading by **Hodge
symmetry** `H^{p,q} = conj(H^{q,p})`, and this single extra datum suffices to invert the
forgetful map. The reconstruction is governed by:

- the **opposition relations** `Fᵖ ⊕ conj(F^{k−p+1}) = V_ℂ`, and
- the **reconstruction identity** `H^{p,q} = Fᵖ ∩ conj(F^q)`.

In weight two the entire content is captured by the single identity `H¹¹ = F¹ ∩ conj(F¹)`
together with `F² = H²⁰` and `H⁰² = conj(H²⁰)`.

### 1.3 Contributions

We formalize this dictionary in the weight-two rational case and prove that the Hodge
filtration together with conjugation is a **complete invariant**. Specifically:

1. We define a structure `HodgeStructureWeightTwoConj` that augments the bigrading with
   genuine internal-direct-sum hypotheses and a conjugate-linear involution satisfying
   Hodge symmetry.
2. We prove the filtration is decreasing (`F_antitone`).
3. We compute the action of conjugation on the filtration steps (`conj_H02`,
   `conjF1_eq`, `conjF2_eq`).
4. We prove the opposition relations (`opposition`).
5. We prove the reconstruction identity `H¹¹ = F¹ ∩ conj(F¹)` (`recover_H11`).
6. We deduce that the filtration plus conjugation is a complete invariant
   (`filtration_determines_decomposition`).
7. We exhibit a model showing the theory is non-vacuous (`nonempty_of_trivial`).

A central methodological finding is that reconstruction genuinely requires the
**internal-direct-sum** hypothesis rather than the weaker *pairwise*-trivial
intersection that the ambient catalog object records; the gap between them is the
classical "three lines in a plane" phenomenon. Under the correct hypothesis the
reconstruction collapses to a single application of the modular law.

---

## 2. Setup and definitions

Throughout, `V` is a finite-dimensional vector space over `ℚ`, and
`V_ℂ := ℂ ⊗_ℚ V` is its complexification, a finite-dimensional `ℂ`-vector space. We
write `Submodule ℂ V_ℂ` for the lattice of complex subspaces, with `⊓` for intersection,
`⊔` for sum (join), `⊤` for the whole space, and `⊥` for the zero subspace.

### 2.1 Complexification embedding

**Definition 2.1 (complexify embedding).** The natural `ℚ`-linear map
`complexifyEmbed : V →_ℚ V_ℂ` sends `v ↦ 1 ⊗ v`. It realizes `V` as a rational subspace
of its complexification and is the algebraic incarnation of "real classes inside complex
cohomology."

### 2.2 The base object: a weight-two Hodge structure

**Definition 2.2 (weight-two Hodge structure).** A `HodgeStructureWeightTwo` on `V` is a
triple of complex subspaces `H20, H11, H02 ⊆ V_ℂ` together with:

- **(span)** `H20 ⊔ H11 ⊔ H02 = ⊤`;
- **(pairwise independence)** `H20 ⊓ H11 = ⊥`, `H20 ⊓ H02 = ⊥`, and `H11 ⊓ H02 = ⊥`.

This is the catalog's base object. The submodule of **rational Hodge classes** is
`hodgeClasses := (H11.restrictScalars ℚ).comap (complexifyEmbed V)`, i.e. `V ∩ H¹¹`, and
the Lefschetz (1,1) theorem asserts these are exactly the algebraic classes.

**Remark 2.3 (a hypothesis gap).** The pairwise-independence axiom is *strictly weaker*
than requiring `H20, H11, H02` to be an internal direct sum. Three distinct lines through
the origin of `ℂ²` meet pairwise trivially yet are linearly dependent (their dimensions
sum to `3 > 2`). The reconstruction theorems below are false under pairwise independence
alone; they require the stronger axioms of Definition 2.4.

### 2.3 The enriched object: conjugation and direct sum

**Definition 2.4 (weight-two Hodge structure with conjugation).** A
`HodgeStructureWeightTwoConj` on `V` extends Definition 2.2 with:

- **internal direct sum:**
  - `hdir20 : H20 ⊓ (H11 ⊔ H02) = ⊥`,
  - `hdir11 : H11 ⊓ (H20 ⊔ H02) = ⊥`,
  - `hdir02 : H02 ⊓ (H20 ⊔ H11) = ⊥`;
- **conjugation:** a `starRingEnd ℂ`-semilinear isomorphism
  `conj : V_ℂ ≃ₛₗ V_ℂ` (conjugate-linear: `conj(λ · x) = λ̄ · conj(x)`);
- **involution:** `conj_invol : conj (conj x) = x` for all `x`;
- **Hodge symmetry:**
  - `conj_H20 : H20.map conj = H02`,
  - `conj_H11 : H11.map conj = H11`.

The map `conjMap S := S.map conj` is the image of a subspace under conjugation. Note
that, although `conj` is only conjugate-*linear*, `conjMap` sends complex subspaces to
complex subspaces (the conjugate of a `ℂ`-subspace is again a `ℂ`-subspace because
`λ̄` ranges over all of `ℂ` as `λ` does).

**Remark 2.5.** Each direct-sum axiom states that one piece meets the join of the other
two trivially. Together with the spanning axiom these are equivalent to
`DirectSum.IsInternal` for the three-element family, i.e. to a genuine internal direct
sum `V_ℂ = H20 ⊕ H11 ⊕ H02`. This is the precise hypothesis the reconstruction needs.

### 2.4 The Hodge filtration

**Definition 2.6 (Hodge filtration).** Define `F : ℕ → Submodule ℂ V_ℂ` by

```
F 0 = ⊤,    F 1 = H20 ⊔ H11,    F 2 = H20,    F p = ⊥  for p ≥ 3.
```

Thus `F⁰ = V_ℂ ⊇ F¹ = H²⁰ ⊕ H¹¹ ⊇ F² = H²⁰`, the decreasing Hodge filtration with
`Fᵖ = ⊕_{i ≥ p} H^{i, 2−i}`.

---

## 3. Main results

### 3.1 The filtration is decreasing

**Theorem 3.1 (`F_antitone`).** `F` is antitone: if `n ≤ m` then `F m ⊆ F n`.

*Proof sketch.* By induction on `m`. For consecutive indices the inclusions
`F 1 = H20 ⊔ H11 ⊆ ⊤ = F 0`, `F 2 = H20 ⊆ H20 ⊔ H11 = F 1` (by `le_sup_left`), and
`F (p+1) = ⊥ ⊆ F p` for `p ≥ 2` are each immediate; the general case `n ≤ m` chains
these. ∎

### 3.2 Conjugation on the pieces and the filtration

**Theorem 3.2 (`conj_H02`).** `H02.map conj = H20`.

*Proof sketch.* Apply `conjMap` to Hodge symmetry `conj_H20 : H20.map conj = H02`. Since
`conj` is an involution, `conj ∘ conj = id`, so
`H02.map conj = (H20.map conj).map conj = H20.map (conj ∘ conj) = H20.map id = H20`.
Formally one rewrites by `conj_H20`, collapses the composite with `Submodule.map_comp`,
and identifies `conj ∘ conj` with the identity using `conj_invol`. ∎

**Theorem 3.3 (`conjF1_eq`).** `conjMap (F 1) = H02 ⊔ H11`.

*Proof sketch.* `conjMap` distributes over joins (`Submodule.map_sup`):
`conjMap (H20 ⊔ H11) = (H20.map conj) ⊔ (H11.map conj) = H02 ⊔ H11`, using `conj_H20` and
`conj_H11`. ∎

**Theorem 3.4 (`conjF2_eq`).** `conjMap (F 2) = H02`.

*Proof sketch.* `conjMap (F 2) = H20.map conj = H02` directly from `conj_H20`. ∎

### 3.3 The opposition relations

**Theorem 3.5 (`opposition`).** Both of the following hold:

```
F² ⊓ conjMap(F¹) = ⊥   and   F² ⊔ conjMap(F¹) = ⊤      (i.e. F² ⊕ conj F¹ = V_ℂ),
F¹ ⊓ conjMap(F²) = ⊥   and   F¹ ⊔ conjMap(F²) = ⊤      (i.e. F¹ ⊕ conj F² = V_ℂ).
```

*Proof sketch.* Substitute `conjMap(F¹) = H02 ⊔ H11` (Theorem 3.3) and
`conjMap(F²) = H02` (Theorem 3.4), and recall `F² = H20`, `F¹ = H20 ⊔ H11`.

- *First, the intersections vanish.* `F² ⊓ conjMap(F¹) = H20 ⊓ (H02 ⊔ H11) = ⊥` is
  exactly `hdir20` after commuting the join. `F¹ ⊓ conjMap(F²) = (H20 ⊔ H11) ⊓ H02 = ⊥`
  is `hdir02` after commuting. Both are direct-sum axioms; this is where Remark 2.3
  bites — pairwise independence would not suffice.
- *Second, the joins are everything.* `F² ⊔ conjMap(F¹) = H20 ⊔ (H02 ⊔ H11) = ⊤` and
  `F¹ ⊔ conjMap(F²) = (H20 ⊔ H11) ⊔ H02 = ⊤`, both equal to the spanning join
  `H20 ⊔ H11 ⊔ H02 = ⊤` (`hspan`) after reassociating and commuting. ∎

The opposition relations are the abstract form of the statement that the Hodge filtration
and its conjugate are `k`-opposed; geometrically they encode the degeneration of the
Hodge-to-de Rham spectral sequence at `E₁` for compact Kähler manifolds.

### 3.4 Reconstruction of the middle piece

**Theorem 3.6 (`recover_H11`).** `H11 = F¹ ⊓ conjMap(F¹)`, i.e.

```
H11 = (H20 ⊔ H11) ⊓ (H02 ⊔ H11).
```

*Proof sketch.* Substitute `conjMap(F¹) = H02 ⊔ H11` (Theorem 3.3). The inclusion `⊆` is
clear: `H11 ⊆ H20 ⊔ H11` and `H11 ⊆ H02 ⊔ H11`, so `H11 ⊆ (H20 ⊔ H11) ⊓ (H02 ⊔ H11)`.
For `⊇`, apply the **modular law**. Since `H11 ⊆ H02 ⊔ H11`, the modular identity
`A ⊓ (B ⊔ A) = (A ⊓ B) ⊔ ...` specializes to

```
(H20 ⊔ H11) ⊓ (H11 ⊔ H02) = H11 ⊔ ((H20 ⊔ H11) ⊓ H02)   ... (modular law, with H11 ≤ H11 ⊔ H02)
```

Wait — more precisely, write `X = (H20 ⊔ H11) ⊓ (H11 ⊔ H02)`. Because `H11 ⊆ H20 ⊔ H11`,
the modular law `sup_inf_assoc_of_le` gives
`X = H11 ⊔ ((H20 ⊔ H11) ⊓ H02)`. Now `(H20 ⊔ H11) ⊓ H02 = ⊥` is precisely the direct-sum
axiom `hdir02` (after commuting the join), so `X = H11 ⊔ ⊥ = H11`. Combining both
inclusions yields equality. ∎

This is the case `p = q = 1` of the general reconstruction `H^{p,q} = Fᵖ ∩ conj(F^q)`.
The outer pieces are recovered trivially: `H20 = F²` by definition, and
`H02 = conj(H20)` by Theorem 3.2.

### 3.5 The filtration is a complete invariant

**Theorem 3.7 (`filtration_determines_decomposition`).** Let `HC₁` and `HC₂` be two
`HodgeStructureWeightTwoConj` structures on the same `V`. If they have the **same
conjugation** (`HC₁.conj = HC₂.conj`) and the **same filtration** (`HC₁.F = HC₂.F` as
functions `ℕ → Submodule ℂ V_ℂ`), then they have the **same bigrading**:
`HC₁.H20 = HC₂.H20`, `HC₁.H11 = HC₂.H11`, `HC₁.H02 = HC₂.H02`.

*Proof sketch.* Equal filtrations give `HC₁.F 1 = HC₂.F 1` and `HC₁.F 2 = HC₂.F 2`.

- `H20`: `HC_i.H20 = HC_i.F 2`, so equal `F 2` forces equal `H20`.
- `H11`: by `recover_H11`, `HC_i.H11 = HC_i.F 1 ⊓ conjMap_i(HC_i.F 1)`. Since the
  conjugations agree, `conjMap₁ = conjMap₂` as operators; since `F 1` agrees, the two
  expressions coincide, so `HC₁.H11 = HC₂.H11`.
- `H02`: by `conj_H02`, `HC_i.H02 = (HC_i.H20).map (HC_i.conj)`. Both inputs now agree,
  so `HC₁.H02 = HC₂.H02`. ∎

This is the formal statement that the Hodge filtration, **together with complex
conjugation**, is a complete invariant of the weight-two Hodge structure — the
linear-algebraic shadow of `E₁`-degeneration.

### 3.6 Non-vacuity

**Theorem 3.8 (`nonempty_of_trivial`).** There exists a `HodgeStructureWeightTwoConj`
structure (e.g. on the zero space, or any structure with `H20 = H02 = ⊥`,
`H11 = V_ℂ`, and `conj` any conjugate-linear involution fixing `H11`). Hence the theory
is inhabited and Theorems 3.1–3.7 are not vacuously true.

*Proof sketch.* Take `H20 = H02 = ⊥` and `H11 = ⊤`. Spanning and pairwise independence
are immediate; the direct-sum axioms reduce to `⊥ ⊓ ⊤ = ⊥` and `⊤ ⊓ ⊥ = ⊥`. The identity
map is a (degenerate) conjugate-linear involution fixing `⊤` and `⊥`, satisfying Hodge
symmetry `conj(⊥) = ⊥` and `conj(⊤) = ⊤`. (For a genuinely conjugate-linear example,
take `V = ℚ`, `V_ℂ = ℂ`, `conj = ` complex conjugation, `H11 = ℂ`.) ∎

---

## 4. Discussion

### 4.1 Why the internal-direct-sum hypothesis is essential

The methodological heart of this work is Remark 2.3. The catalog's base object records
only pairwise-trivial intersection, which is the *correct* and *complete* axiomatization
for many purposes (e.g. defining `hodgeClasses`). But reconstruction is a finer
operation: it must *separate* a piece from the span of the others, and pairwise
disjointness provides no such leverage. The "three lines in a plane" counterexample is
not a curiosity but a precise diagnosis of where a naive proof fails.

In the proof of `recover_H11`, the direct-sum hypothesis enters exactly once, as
`hdir02 : H02 ⊓ (H20 ⊔ H11) = ⊥`, to kill the cross term produced by the modular law.
Trace the dependency and one sees that this single application is *load-bearing*: drop it
and the inclusion `(H20 ⊔ H11) ⊓ (H02 ⊔ H11) ⊆ H11` is genuinely false. The opposition
relations similarly consume `hdir20` and `hdir02` for their vanishing-intersection
halves. Thus the enriched structure is exactly as strong as the theorems require, and no
stronger.

### 4.2 The modular law as the engine

Once the right hypotheses are in place, every reconstruction statement reduces to lattice
theory. The decisive tool is the **modular law**: in any modular lattice (and the lattice
of submodules of a module is modular),

```
a ≤ c   ⟹   a ⊔ (b ⊓ c) = (a ⊔ b) ⊓ c.
```

The reconstruction `H¹¹ = F¹ ∩ conj F¹` is one instance; the general
`H^{p,q} = Fᵖ ∩ conj F^q` is a telescoping iteration of the same identity. This is the
sense in which a "representation-theoretic complete invariant" theorem becomes pure
lattice theory once the conjugation pairing is supplied.

### 4.3 Relation to spectral sequence degeneration

For a compact Kähler manifold the Hodge-to-de Rham (Frölicher) spectral sequence
degenerates at `E₁`, which is equivalent to the assertion that the Hodge filtration is
`k`-opposed to its conjugate, i.e. `Fᵖ ⊕ conj F^{k−p+1} = V_ℂ`. Our `opposition` theorem
is precisely this condition in weight two. Conversely, opposition for a filtration on a
real (rational) vector space is *equivalent* to the existence of a Hodge decomposition
inducing it (Deligne's theory of opposed filtrations). The complete-invariant theorem is
the uniqueness half of this equivalence.

### 4.4 Formalization remarks

All results were formally verified and depend only on the standard foundational axioms
(`propext`, `Classical.choice`, `Quot.sound`). The conjugate-linearity of `conj` is
modeled by a `starRingEnd ℂ`-semilinear equivalence, which is the idiomatic way to
encode an antilinear map; `conjMap` is then a well-defined endomorphism of the lattice of
*complex* subspaces. The chief technical subtlety is bookkeeping the interplay between
the `ℂ`-linear lattice operations and the conjugate-linear `conj`; isolating `conjMap`
and proving `conjF1_eq`/`conjF2_eq` once cleanly insulates the main proofs from this
subtlety.

---

## 5. Algorithms

### 5.1 Reconstructing the bigrading from `(F•, conj)`

The constructive content of the complete-invariant theorem is an algorithm: given the
filtration floors and the conjugation, output the three graded pieces.

```
Algorithm RECONSTRUCT(F1, F2, conj):
  input:  F2 = F², F1 = F¹  (complex subspaces), conj  (conjugate-linear involution)
  output: (H20, H11, H02)
  1. H20 ← F2
  2. CF1 ← conjMap(F1, conj)        # = H02 ⊔ H11
  3. H11 ← F1 ⊓ CF1                  # modular-law reconstruction
  4. H02 ← conjMap(H20, conj)       # = conj(H20)
  5. return (H20, H11, H02)
```

Correctness is Theorems 3.4, 3.6, 3.2 respectively. Over an `n`-dimensional space with
subspaces represented by bases, each lattice operation (`⊓`, `map`) is a Gaussian
elimination costing `O(n³)`, so reconstruction is `O(n³)`.

### 5.2 Verifying the opposition / direct-sum hypothesis

```
Algorithm IS_HODGE(H20, H11, H02):
  input:  three complex subspaces of an n-dimensional space
  output: True iff they form a valid weight-two Hodge bigrading
  1. if H20 ⊔ H11 ⊔ H02 ≠ ⊤: return False        # span
  2. if H20 ⊓ (H11 ⊔ H02) ≠ ⊥: return False       # hdir20
  3. if H11 ⊓ (H20 ⊔ H02) ≠ ⊥: return False       # hdir11
  4. if H02 ⊓ (H20 ⊔ H11) ≠ ⊥: return False       # hdir02
  5. return True
```

Equivalently, by dimension counting, the four conditions hold iff
`dim H20 + dim H11 + dim H02 = n` *and* the three pieces span — a `O(n³)` rank check.

---

## 6. Applications

- **Variations of Hodge structure.** Because `F•` varies holomorphically while the
  `H^{p,q}` do not, family-theoretic constructions (period maps, period domains, the
  Gauss–Manin connection with Griffiths transversality) are phrased in the filtration
  language. The complete-invariant theorem guarantees no information is lost.
- **Lefschetz (1,1) and the Hodge conjecture.** The middle piece `H¹¹`, recovered as
  `F¹ ∩ conj F¹`, is where Hodge classes live. The reconstruction identity is the precise
  bridge between the filtration formalism and the geometry of algebraic divisors.
- **Period domains.** The space of all filtrations opposed to a fixed conjugation is an
  open subset of a flag variety; the opposition relations cut out exactly the locus of
  honest Hodge structures.
- **Mixed Hodge theory.** Deligne's mixed Hodge structures are governed by *opposed*
  filtrations `(F, W)`; the weight-two opposition computation here is the pure base case
  of that splitting machinery.

---

## 7. Future work

The natural next step is the **general-weight** theory: a family
`H : ℤ → Submodule ℂ V_ℂ` supported on `p + q = k`, with `Fᵖ = ⊕_{i ≥ p} H^{i, k−i}`, the
full opposition theorem `Fᵖ ⊕ conj F^{k−p+1} = V_ℂ`, and the general reconstruction
`H^{p,q} = Fᵖ ∩ conj F^q`. The weight-two computation `recover_H11` is the base case of a
telescoping induction on filtration length, each step peeling off one graded piece via
the modular law. Mathlib's `DirectSum.IsInternal` and `iSupIndep` provide the substrate
for the `ℤ`-indexed bookkeeping. Beyond this lie the Künneth formula for Hodge diamonds,
the Lefschetz (1,1) theorem connected to the Chern class map, the Hodge index theorem and
the signature of the intersection form, and Mumford–Tate groups for abelian varieties.

---

## 8. Conclusion

We have formalized, in the weight-two rational case, the dictionary between the two
languages of pure Hodge theory. The decisive statement is that the Hodge filtration
together with complex conjugation is a complete invariant: the bigrading is recovered by
the opposition relations and the reconstruction identity `H¹¹ = F¹ ∩ conj F¹`. The proof
distills a deep geometric phenomenon — the `E₁`-degeneration of the Hodge-to-de Rham
spectral sequence — to a single application of the modular law, once the genuine
internal-direct-sum hypothesis is correctly identified. The result is a clean,
machine-checked foundation on which the general-weight theory and its geometric
applications can be built.
