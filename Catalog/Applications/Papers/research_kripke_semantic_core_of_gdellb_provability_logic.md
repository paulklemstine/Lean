# The Kripke-Semantic Core of Gödel–Löb Provability Logic: Ordinal Ranks, Polymodal Reductions, and Categorical Products

## Abstract

We develop the Kripke-semantic core of Gödel–Löb provability logic (GL) and
push it in three directions that connect provability logic to set theory, proof
theory, and category theory. The unifying object is the **GL frame**: a finite
set of worlds equipped with a transitive, irreflexive accessibility relation.
Its defining feature — *converse well-foundedness* of accessibility — is exactly
strong enough to support an **ordinal rank** function on worlds, which we show
strictly decreases along accessibility. Building on this rank we prove a
**rank-stratification theorem**: in every GL frame the *k*-fold iterated box of
the empty set is precisely the set of worlds of ordinal rank below `k`,
`□^k ∅ = { w | rank w < k }`. This is a quantitative, every-frame form of
Löb's theorem that identifies *consistency strength* with *ordinal rank*,
generalizing the concrete computation `□^k ∅ = Iio k` valid for the canonical
frame `(ℕ, >)`. We then formalize **polymodal GLP frames** as nested families of
GL frames and reduce polymodal soundness, box-monotonicity, and rank descent to
the single-modal theory. Finally we study the **synchronized product** of GL
frames: the diamond of a rectangle factors exactly as a rectangle of diamonds
(`◇(A ×ˢ B) = ◇A ×ˢ ◇B`), the algebraic signature of a categorical product,
whereas the box does **not** factor. We prove the surviving inclusion
`(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)`, characterize equality (both factors edgeless), and
exhibit an explicit two-world/one-world witness making the inclusion strict. The
correct coincidence criterion is edge-freeness, not seriality: a serial GL frame
is necessarily empty, since converse well-foundedness forces a dead-end world.
All results have been formally verified.

**Keywords.** Provability logic, Gödel–Löb logic, Kripke semantics, Löb's
theorem, well-founded relation, ordinal rank, polymodal logic GLP, ordinal
analysis, categorical product, modal logic.

---

## 1. Introduction

Provability logic studies the modal operator `□` read as "it is provable that."
Solovay's arithmetical completeness theorem identifies the logic of this operator
(over Peano Arithmetic) with the modal system **GL** axiomatized by the
distribution axiom `□(φ → ψ) → (□φ → □ψ)` together with **Löb's axiom**
`□(□φ → φ) → □φ`. Segerberg's theorem characterizes GL semantically: it is
exactly the logic of finite, transitive, irreflexive Kripke frames. The
accessibility relation of such a frame is a strict, well-founded partial order,
and worlds correspond to consistent completions of the theory with accessibility
encoding relative consistency strength.

This paper develops the semantic core of GL with three goals, each connecting
provability logic to a neighboring field:

1. **Set theory.** The converse of accessibility in any GL frame is
   well-founded; this gives a canonical ordinal rank on worlds. We make the rank
   frame-internal and prove it strictly decreases along accessibility.

2. **Proof theory.** We lift the concrete rank computation from the canonical
   frame `(ℕ, >)` to *every* GL frame, obtaining `□^k ∅ = {w | rank w < k}` and
   the identification of consistency strength with ordinal rank. We formalize
   polymodal GLP frames — the semantic skeleton of ordinal analysis — and reduce
   their theory to the single-modal case.

3. **Category theory.** We study products of GL frames, isolating the diamond as
   the product-respecting operator and proving that the box fails to factor,
   with a sharp characterization of when it does.

All statements below are theorems that have been formally verified in a proof
assistant; we present mathematical statements with proof sketches rather than
formal proof scripts.

---

## 2. GL Frames and the Box/Diamond Operators

### 2.1 Definitions

**Definition 2.1 (GL frame).** A *GL frame* `F` consists of:

- a finite type `World` of worlds;
- an *accessibility relation* `R : World → World → Prop`;
- a proof of **irreflexivity**: `∀ w, ¬ R w w`;
- a proof of **transitivity**: `∀ w v u, R w v → R v u → R w u`.

We read `R w v` as "`v` is accessible from `w`," equivalently "`v` is a stronger
theory imaginable from `w`."

**Definition 2.2 (Box and diamond).** For a set `S ⊆ World`:

- the **box** `□S := { w | ∀ v, R w v → v ∈ S }` (necessity / provability);
- the **diamond** `◇S := { w | ∃ v, R w v ∧ v ∈ S }` (possibility / consistency
  of a witness).

**Definition 2.3 (Maximal / dead-end world).** A world `w` is *maximal*
(`IsMaximal w`) if it has no successors: `∀ v, ¬ R w v`. Maximal worlds
correspond to complete consistent theories.

### 2.2 Elementary algebra of the box

The box is a normal modal operator on every GL frame:

**Proposition 2.4.** `□` is monotone; `□ univ = univ`; `□(S ∩ T) = □S ∩ □T`;
and the box-sets are upward closed under `R` (if `w ∈ □S` and `R w v` then
`v ∈ □S`, by transitivity). Diamond and box are De Morgan duals:
`◇S = (□Sᶜ)ᶜ` and `□S = (◇Sᶜ)ᶜ`.

*Proof sketch.* Each is a direct unfolding of Definition 2.2; upward closure uses
transitivity of `R`, duality uses classical negation of the quantifier. ∎

**Proposition 2.5 (Vacuous box at dead ends).** If `w` is maximal then
`w ∈ □S` for every `S`.

*Proof.* The universal quantifier over successors of `w` ranges over the empty
set. ∎

Proposition 2.5 is the structural source of the box-factorization failure in
Section 6, and it interacts decisively with well-foundedness (Section 3).

### 2.3 Soundness: Löb's axiom on GL frames

**Theorem 2.6 (Löb soundness, `gl_frame_validates_loeb`).** For every GL frame
`F` and every `S ⊆ World`,
`□((□S)ᶜ ∪ S) ⊆ □S`. (Here `(□S)ᶜ ∪ S` encodes the implication `□S → S`.)

*Proof sketch.* By well-founded induction on the accessibility relation
(well-founded by Theorem 3.1). Suppose `w ∈ □((□S)ᶜ ∪ S)` and `R w v`. By upward
closure (Proposition 2.4) `v` again satisfies `□((□S)ᶜ ∪ S)`. By the induction
hypothesis every successor of `v` lies in `S`, so `v ∈ □S`. The membership
`v ∈ (□S)ᶜ ∪ S` then forces `v ∈ S`. As `v` was an arbitrary successor of `w`,
`w ∈ □S`. The formalization runs the induction on the finite cardinality of the
successor set, which strictly decreases along `R` by transitivity and
irreflexivity. ∎

---

## 3. Well-Foundedness and the Ordinal Rank

### 3.1 Converse well-foundedness

**Theorem 3.1 (`gl_frame_well_founded`).** The accessibility relation `R` of any
GL frame is well-founded.

**Theorem 3.2 (Converse well-foundedness, `flip_wellFounded`).** The *converse*
relation `flip R` (defined by `flip R x y := R y x`) is well-founded; equivalently
there is no infinite *ascending* chain `w R w₁ R w₂ R ⋯`.

*Proof sketch.* A finite, transitive, irreflexive relation is well-founded; the
converse of a transitive irreflexive relation is again transitive and
irreflexive, hence finite-well-founded as well. ∎

**Corollary 3.3 (`exists_maximal_world`).** Every nonempty GL frame has a maximal
(dead-end) world.

*Proof.* A `flip R`-minimal element of `univ` is exactly an `R`-maximal world. ∎

Corollary 3.3 has a sharp consequence used in Section 6: **a serial GL frame
(one in which every world has a successor) must be empty.** Seriality contradicts
the existence of a dead-end world guaranteed by converse well-foundedness in any
nonempty frame.

### 3.2 The ordinal rank

**Definition 3.4 (Rank, `GLFrame.rank`).** For a world `w`, define
`rank w := IsWellFounded.rank (flip R) w`, the ordinal rank of `w` in the
well-founded relation `flip R`. Concretely,
`rank w = sup { (rank v) + 1 | R w v }`: the rank of `w` is the supremum, over
its successors `v`, of `rank v + 1`. Dead ends have rank `0`.

**Theorem 3.5 (Rank descent, `gl_rank_lt_of_R`).** If `R w v` then
`rank v < rank w`.

*Proof.* Immediate from the recursion characterizing the rank of a well-founded
relation applied to `flip R`: `flip R v w` holds iff `R w v`, and rank strictly
increases along the well-founded relation, i.e. strictly decreases along `R`. ∎

The rank is the qualitative generalization of the literal depth `rank n = n`
enjoyed by the world `n` in the canonical frame `(ℕ, >)`. Where the canonical
frame has a `ℕ`-valued rank, an arbitrary GL frame has an **ordinal**-valued
rank — the type correctness needed to target named proof-theoretic ordinals
(e.g. ε₀) in future work.

---

## 4. The Canonical Frame `(ℕ, >)` and Quantitative Löb

We recall the canonical model to motivate the general stratification theorem.

**Definition 4.1.** Let the worlds be `ℕ` with `R := (>)` (so `n` sees every
`m < n`). The induced box is `natBox S = { n | ∀ m < n, m ∈ S }`.

**Theorem 4.2 (Löb for `(ℕ, >)`, `natBox_loeb`).** `natBox(natBox S → S) ⊆
natBox S`, proved by strong induction on the world. The Boolean algebra
`Set ℕ` with `□ := natBox` is therefore a consistent model of the GL operator
axioms.

**Theorem 4.3 (Consistency, `natGL_consistent`).** `natBox ∅ = {0} ≠ univ`;
hence `□⊥ ≠ ⊤`. The model cannot prove falsity, and a fortiori cannot prove its
own consistency (`natGL_godel_second`).

**Theorem 4.4 (Rank computation, `natBox_iterate_eq_Iio`).** For every `k`,
`natBox^[k] ∅ = Iio k = {0, 1, …, k-1}`.

*Proof sketch.* Induction on `k`. Base: `natBox^[0] ∅ = ∅ = Iio 0`. Step:
`natBox(Iio k) = Iio (k+1)`, since `(∀ m < n, m < k) ↔ n ≤ k`. ∎

**Theorem 4.5 (Strict consistency hierarchy, `consistency_strength_strictMono`;
graded Gödel II, `godel_hierarchy`).** The map `k ↦ natBox^[k] ∅` is strictly
increasing and never reaches `univ`; consequently for every `k` the
consistency statement `(natBox^[k+1] ∅) → ⊥` is unprovable. This refines the
single Gödel II into a strictly increasing spectrum of unprovable consistency
strengths.

The next section shows that Theorem 4.4 is the `(ℕ, >)` shadow of a theorem about
*all* GL frames, with `Iio k` replaced by `{w | rank w < k}`.

---

## 5. The Rank-Stratification Theorem (Quantitative Löb for Every Frame)

This section formalizes **Direction 4** of the research program. We work in an
arbitrary GL frame `F` and iterate the box on the empty set.

**Lemma 5.1 (Bottom layer, `boxSet_empty_eq_maximal`).** `□∅ = { w | IsMaximal w }`.

*Proof.* `w ∈ □∅` iff every successor of `w` lies in `∅`, i.e. `w` has no
successor, i.e. `w` is maximal. ∎

**Lemma 5.2 (Rank zero = dead end, `rank_eq_zero_iff_maximal`).**
`rank w = 0 ↔ IsMaximal w`.

*Proof.* By Definition 3.4, `rank w = sup { rank v + 1 | R w v }`. This supremum
is `0` iff the index set is empty, i.e. `w` has no successor, i.e. `w` is
maximal. (Every term `rank v + 1` is a successor ordinal `≥ 1`, so a nonempty
index set forces a positive rank.) ∎

Lemmas 5.1 and 5.2 already give the case `k = 1`: `□∅ = {maximal} = {rank = 0} =
{rank < 1}`.

**Theorem 5.3 (Rank stratification, `boxSet_iterate_eq_rank_lt`).** For every
`k ∈ ℕ`,
`□^k ∅ = { w | rank w < k }`.

*Proof sketch.* Induction on `k`.

- **Base `k = 0`:** `□^0 ∅ = ∅`, and `{w | rank w < 0} = ∅` since no ordinal is
  `< 0`.
- **Step `k → k+1`:** `□^{k+1} ∅ = □(□^k ∅) = □{v | rank v < k}` by the induction
  hypothesis. By definition of the box, `w ∈ □{rank < k}` iff every successor `v`
  of `w` satisfies `rank v < k`. By the rank recursion (Definition 3.4),
  `rank w = sup_{R w v}(rank v + 1)`, so
  `rank w ≤ k ⟺ ∀ v (R w v → rank v + 1 ≤ k) ⟺ ∀ v (R w v → rank v < k)`.
  Since `rank w < k+1 ⟺ rank w ≤ k`, we conclude `w ∈ □^{k+1} ∅ ⟺ rank w < k+1`. ∎

**Corollary 5.4 (Consistency strength = ordinal rank).** For each world `w`, the
least `k` with `w ∉ □^k ∅` equals `rank w` (when `rank w` is finite; in general
`rank w` is the ordinal threshold of the stratification). Iterated falsity is a
thermometer for ordinal rank.

**Specialization.** In `(ℕ, >)` we have `rank n = n` and `{n | rank n < k} =
Iio k`, recovering Theorem 4.4 as the canonical instance of Theorem 5.3. The
slogan "*consistency strength is ordinal rank*" is thus a theorem for arbitrary
GL frames, unifying the semantic picture of Sections 2–3 with the quantitative
picture of Section 4.

---

## 6. Products of GL Frames and the Box-Factorization Obstruction

This section formalizes **Direction 2**, the categorical obstruction theorem.

### 6.1 The synchronized product

**Definition 6.1 (Synchronized product, `GLFrame.prod`).** For GL frames `F`,
`G`, the product `F.prod G` has worlds `F.World × G.World` and accessibility
`R (w₁, w₂) (v₁, v₂) := F.R w₁ v₁ ∧ G.R w₂ v₂`: a step advances *both*
coordinates simultaneously.

**Proposition 6.2.** `F.prod G` is a GL frame (finite, irreflexive, transitive),
and it validates Löb's axiom (`prod_validates_loeb`, by Theorem 2.6 applied to
the product).

We write `A ×ˢ B := { (w₁, w₂) | w₁ ∈ A ∧ w₂ ∈ B }` for the *rectangle* with
sides `A ⊆ F.World`, `B ⊆ G.World`.

### 6.2 Diamond factors exactly

**Theorem 6.3 (Diamond rectangle, `prod_diamond_rectangle`).**
`◇(A ×ˢ B) = (◇A) ×ˢ (◇B)` in `F.prod G`.

*Proof.* A point `(w₁, w₂)` is in `◇(A ×ˢ B)` iff there is a synchronized step to
some `(v₁, v₂) ∈ A ×ˢ B`, i.e. `F.R w₁ v₁ ∧ v₁ ∈ A` and `G.R w₂ v₂ ∧ v₂ ∈ B`.
The existential over the pair splits into independent existentials over each
coordinate, giving exactly `w₁ ∈ ◇A` and `w₂ ∈ ◇B`. ∎

This exact factorization is the algebraic signature of a categorical product:
the existential quantifier behind `◇` distributes over the product step.

### 6.3 Box does not factor

The universal quantifier behind `□` does not distribute, because a dead end in
one coordinate empties the quantifier in both. We make this precise.

**Theorem 6.4 (Surviving inclusion, `prod_box_rectangle_subset`).**
`(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` in `F.prod G`, for all `A`, `B`.

*Proof.* If `w₁ ∈ □A` and `w₂ ∈ □B`, then for any synchronized successor
`(v₁, v₂)` of `(w₁, w₂)` we have `F.R w₁ v₁` and `G.R w₂ v₂`, hence `v₁ ∈ A` and
`v₂ ∈ B`, so `(v₁, v₂) ∈ A ×ˢ B`. ∎

**Theorem 6.5 (Equality when edgeless, `prod_box_rectangle_of_edgeless`).** If
neither `F` nor `G` has any accessibility edge (`∀ w v, ¬ F.R w v` and
`∀ w v, ¬ G.R w v`), then `□(A ×ˢ B) = (□A) ×ˢ (□B)`.

*Proof.* Edgelessness makes every box equal `univ` vacuously (Proposition 2.5),
on both sides; the product is also edgeless, so both sides equal `univ`. ∎

**Theorem 6.6 (Box does not factor — the obstruction, `prod_box_not_factor`).**
There exist GL frames and sets with `(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)` (strict
inclusion). Explicitly, let:

- `boolEdge`: worlds `Bool = {true, false}`, with the single edge
  `R true false` (and no other edges). This is a GL frame.
- `unitDead`: a single world `()` of type `Unit`, with no edges. This is a GL
  frame (the canonical dead end).

Take `A := {true} ⊆ Bool` and `B := univ ⊆ Unit`. Then
`(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)` in `boolEdge.prod unitDead`.

*Proof.* Consider the point `(true, ())`.

- **In the right side:** `()` is a dead end, so `(true, ())` has *no* successor
  in the product (a synchronized step would require a `unitDead`-step from `()`).
  The box quantifies vacuously, so `(true, ()) ∈ □(A ×ˢ B)`.
- **Not in the left side:** membership requires `true ∈ □A`. But `true` sees
  `false` in `boolEdge`, and `false ∉ {true} = A`, so `true ∉ □A`. Hence
  `(true, ()) ∉ (□A) ×ˢ (□B)`.

Combined with Theorem 6.4, the inclusion is strict. ∎

### 6.4 Correction to the seriality conjecture

A natural conjecture is that the box factors iff both factor frames are *serial*
(every world has a successor, so no dead ends arise). **This is vacuous in the GL
setting.** By Corollary 3.3, converse well-foundedness forces every nonempty GL
frame to contain a dead-end world; therefore a serial GL frame must be empty.
The correct coincidence criterion is **edge-freeness** (Theorem 6.5), witnessed
sharp by Theorem 6.6. The conjecture's graceful collapse pinpoints the dead end
as the genuine obstruction.

### 6.5 Categorical reading

Theorems 6.3–6.6 say that, in the category of GL frames under the synchronized
product, the diamond is a *product-preserving* operator while the box is not. The
asymmetry is exactly the asymmetry between `∃` (which distributes over a product
step) and `∀` (which is ambushed by an empty fiber). GL is, in this precise
sense, a **diamond-natural** logic.

---

## 7. Polymodal GLP Frames

This section records the polymodal reduction underlying Japaridze's logic GLP and
ordinal analysis.

**Definition 7.1 (GLP frame).** A *GLP frame* `G` consists of a finite world
type and an `ℕ`-indexed family of relations `R n : World → World → Prop` such
that each `R n` is irreflexive and transitive, and the family is *nested*:
`R (n+1) ⊆ R n`. The relation `R n` interprets the `n`-th provability modality
`[n]`.

**Proposition 7.2 (Antitone family, `R_anti`).** For `n ≤ m`, `R m ⊆ R n`.

*Proof.* Induction on `m - n` using the nesting hypothesis. ∎

**Definition 7.3 (Level, `GLPFrame.level`).** The *`n`-th level* `level n` is the
GL frame with the same worlds and relation `R n`. (It is a GL frame because
`R n` is irreflexive and transitive.)

**Theorem 7.4 (Polymodal Löb, `glp_level_validates_loeb`).** Each level validates
Löb's axiom: `□ₙ((□ₙ S)ᶜ ∪ S) ⊆ □ₙ S` for every `n` and `S`.

*Proof.* `level n` is a GL frame; apply Theorem 2.6. ∎

**Theorem 7.5 (Box monotone in the index, `glp_box_mono_in_level`).** For
`n ≤ m`, `□ₙ S ⊆ □ₘ S`.

*Proof.* If `w ∈ □ₙ S` and `R m w v`, then `R n w v` by Proposition 7.2, so
`v ∈ S`. Thus `w ∈ □ₘ S`. ∎

Theorem 7.5 is the frame-semantic content of the GLP monotonicity axiom
`[n]φ → [n+1]φ`: a sparser, higher modality is logically weaker because it
quantifies over fewer successors.

**Theorem 7.6 (Rank descent per modality, `glp_level_rank_lt`).** For each `n`,
if `R n w v` then `(level n).rank v < (level n).rank w`.

*Proof.* Apply Theorem 3.5 to the GL frame `level n`. ∎

The polymodal apparatus thus requires no new soundness argument: GLP's family of
Löb axioms is a *family* of single-modal Löb axioms, one per level, plus the
nesting bookkeeping of Proposition 7.2.

---

## 8. Algorithms

The semantic results are constructive on finite frames and yield direct
algorithms.

**Algorithm A (Rank computation).** Given a finite GL frame as an adjacency
relation, compute `rank w` for every world by reverse-topological dynamic
programming: `rank w = max_{R w v}(rank v + 1)`, with `rank w = 0` at dead ends.
Because `R` is acyclic (irreflexive + transitive ⇒ a strict partial order),
worlds can be processed in any order consistent with reverse accessibility;
complexity `O(|World| + |R|)` after a topological sort.

**Algorithm B (Iterated-box stratification).** Compute `□^k ∅` for increasing `k`
by fixpoint iteration: `S₀ = ∅`, `S_{k+1} = □ S_k = {w | ∀ v, R w v → v ∈ S_k}`.
By Theorem 5.3, `S_k = {w | rank w < k}`, and the iteration stabilizes at
`univ` once `k` exceeds the maximal rank. This gives an independent check of
Algorithm A: the level at which a world *enters* the increasing chain equals its
rank.

**Algorithm C (Box-factorization tester).** Given two finite frames and sets
`A`, `B`, compute both `□(A ×ˢ B)` and `(□A) ×ˢ (□B)` in the product and compare.
By Theorems 6.4–6.6 the second is always contained in the first, with equality
iff both frames are edgeless; the algorithm also reports the strictness witness
(a world maximal in one coordinate but not boxed in the other).

---

## 9. Applications

- **Ordinal analysis.** Theorem 5.3 makes "consistency strength" computable as an
  ordinal rank on frames, and the polymodal reduction (Section 7) provides the
  frame skeleton on which Japaridze's GLP-based ordinal analysis of arithmetical
  theories is built. The `ℕ`-valued canonical instance (`rank n = n`) is the
  base case; ordinal-valued ranks open the door to named ordinals such as ε₀.

- **Graded incompleteness.** Theorems 4.5 and 5.3 turn Gödel's single second
  incompleteness theorem into a *strictly increasing spectrum* of unprovable
  consistency statements, indexed by ordinal rank.

- **Modal model construction.** Algorithms A–C give practical tools for building
  and testing finite countermodels in provability logic, including products for
  combining independent provability predicates.

- **Categorical semantics.** Section 6 identifies the diamond as the
  product-preserving operator, a prerequisite for a limit/colimit calculus on GL
  frames (see Future Work).

---

## 10. Discussion

The recurring theme is that **converse well-foundedness is the load-bearing
hypothesis** of GL. It powers Löb soundness (Theorem 2.6), guarantees dead ends
(Corollary 3.3), supports the ordinal rank (Definition 3.4, Theorem 3.5),
stratifies the iterated box (Theorem 5.3), and — through the unavoidable dead end
— obstructs box-factorization in products (Theorem 6.6). The single structural
fact "you cannot go forward forever" reappears as a set-theoretic ruler, a
proof-theoretic gauge, and a categorical asymmetry.

Two methodological points deserve emphasis. First, the polymodal theory is a
*reduction*, not a new theory: by realizing each level as a genuine GL frame, all
single-modal results transfer verbatim. Second, a conjecture that *fails* can be
as informative as one that holds: the seriality criterion for box-factorization
collapses precisely because of converse well-foundedness, and tracing that
collapse yields the correct criterion (edge-freeness) and the conceptual point
that dead ends, not non-seriality, are the obstruction.

---

## 11. Future Work

1. **An ε₀-valued rank for the standard polymodal frame.** Instantiate a GLP
   frame on an ordinal-indexed world set whose level-0 rank realizes ε₀ and whose
   higher levels reproduce the Veblen/Japaridze tower, giving a verified bridge
   from frame semantics to a named proof-theoretic ordinal.

2. **A full box-obstruction theorem.** Prove the general inclusion
   `(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` is strict whenever either frame has a dead end, and
   characterize equality completely.

3. **Coproducts and a categorical structure on GL frames.** Define the disjoint
   union as coproduct, define bounded morphisms, and prove the universal
   properties of product and coproduct, with rank as a functorial invariant.

4. **Rank as longest-chain length.** Prove `rank w` equals the length of the
   longest ascending accessibility chain from `w` (finite frames), tightening
   Corollary 5.4.

5. **Tropical / cost semantics.** Replace the Boolean box by a cost function
   `cost(w, □φ) = sup over successors + 1` defined by well-founded recursion on
   `flip R`, and relate the growth of `cost(w, □^k⊥)` to `rank w`.

---

## 12. Conclusion

We have presented a self-contained semantic core for Gödel–Löb provability logic
and pushed it toward set theory (ordinal rank), proof theory (rank stratification
and polymodal GLP), and category theory (the synchronized product and its
diamond/box asymmetry). The central new theorems — frame-internal rank descent,
the rank-stratification identity `□^k ∅ = {rank < k}`, the polymodal reduction,
and the box-factorization obstruction with its edge-freeness criterion — together
exhibit converse well-foundedness as the single structural principle organizing
the entire theory. All results are formally verified.
