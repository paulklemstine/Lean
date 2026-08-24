import Mathlib
import Novelty.JigsawComplementFreeAction
import Shared.JigsawSolutionSpace

/-!
# Orbit structure of the complementation involution, and its formula-level bridge

Cycle one proved that global tab--blank complementation acts freely on the
untagged union of the two assembly spaces of a framed puzzle on `n ≥ 1`
variables, so that union has even cardinality
(`JigsawFreeComplement.union_card_even`).  Parity is however only the shadow of a
finer statement.  This file replaces the parity conclusion by an *explicit orbit
decomposition*, computes the sign of complementation as a permutation of the
Boolean cube, and connects the concrete framed model to the formula-level
complementation of `Shared.JigsawSolutionSpace`.

## Contents

* **Gauge fixing.**  `polarityGauge` selects, from each free complementation
  orbit, the unique assembly whose variable `0` piece exposes a tab.  Every
  complement-stable finite set of assemblies is the disjoint union of its gauge
  and the complement of its gauge (`stable_eq_gauge_union_image`), whence
  `card_eq_two_mul_gauge`: the cardinality is exactly twice the number of
  orbits.  Parity is recovered as a corollary, now with a *witnessing section*
  rather than an existence argument.

* **Sign of complementation.**  Complementation is a permutation of the whole
  Boolean cube with no fixed points (for `n ≥ 1`); it is a product of `2^(n-1)`
  disjoint transpositions, so `compAssignPerm_sign`: its sign is `(-1)^(2^(n-1))`.
  In particular it is an *odd* permutation exactly when `n = 1`
  (`compAssignPerm_sign_one`, `compAssignPerm_sign_even`).  The order-two
  symmetry of the edge alphabet therefore leaves a `ℤ/2` trace on the symmetric
  group of the cube which is visible only in the one-variable case.

* **Bridge to the catalog reduction.**  `toFormula` embeds a framed puzzle into
  the `ℕ`-indexed formulas of `Novelty.JigsawNPComplete`.  Complementation is
  compatible with the embedding on the nose
  (`toFormula_compPuzzle`), and assembling the framed puzzle is exactly the
  catalog's `PuzzleAssembled` (`assembles_iff_puzzleAssembled`), hence
  `nonempty_assemblySet_iff_solvable`.  Combining these with
  `Jigsaw.puzzleSolvable_complement` shows the earlier solvability invariance is
  the `π₀` of the present orbit statement.
-/

open Function

namespace JigsawFreeComplement

open Jigsaw

variable {n : ℕ}

/-! ## Part 1 — Gauge fixing: an explicit section of the orbit map -/

/-- The polarity gauge of a set of assemblies: those assemblies whose variable
`0` piece exposes a tab.  Each free complementation orbit meets it exactly
once. -/
def polarityGauge (hn : 0 < n) (s : Finset (Fin n → Bool)) : Finset (Fin n → Bool) :=
  s.filter fun a => a ⟨0, hn⟩ = true

/-- The gauge and its complement are disjoint: complementing flips the polarity
of variable `0`. -/
theorem gauge_disjoint_image (hn : 0 < n) (s : Finset (Fin n → Bool)) :
    Disjoint (polarityGauge hn s) ((polarityGauge hn s).image compAssign) := by
  rw [Finset.disjoint_right]
  rintro a ha hb
  simp only [Finset.mem_image, polarityGauge, Finset.mem_filter] at ha hb
  obtain ⟨b, ⟨_, hb0⟩, rfl⟩ := ha
  simp [compAssign, hb0] at hb

/-- **Orbit decomposition.**  A complement-stable set of assemblies splits as its
gauge together with the complement of its gauge: one representative per free
orbit, plus its partner. -/
theorem stable_eq_gauge_union_image (hn : 0 < n) (s : Finset (Fin n → Bool))
    (hs : ∀ a ∈ s, compAssign a ∈ s) :
    s = polarityGauge hn s ∪ (polarityGauge hn s).image compAssign := by
  ext a
  simp only [Finset.mem_union, Finset.mem_image, polarityGauge, Finset.mem_filter]
  constructor
  · intro ha
    cases h : a ⟨0, hn⟩ with
    | true => exact Or.inl ⟨ha, rfl⟩
    | false =>
        refine Or.inr ⟨compAssign a, ⟨hs a ha, ?_⟩, compAssign_involutive a⟩
        simp [compAssign, h]
  · rintro (⟨ha, _⟩ | ⟨b, ⟨hb, _⟩, rfl⟩)
    · exact ha
    · exact hs b hb

/-- **Exact orbit count.**  A complement-stable set of assemblies has exactly
twice as many elements as it has orbits, and the orbits are indexed by the
polarity gauge. -/
theorem card_eq_two_mul_gauge (hn : 0 < n) (s : Finset (Fin n → Bool))
    (hs : ∀ a ∈ s, compAssign a ∈ s) :
    s.card = 2 * (polarityGauge hn s).card := by
  conv_lhs => rw [stable_eq_gauge_union_image hn s hs]
  rw [Finset.card_union_of_disjoint (gauge_disjoint_image hn s),
    Finset.card_image_of_injective _ compAssign_involutive.injective]
  ring

/-- The combined (untagged) assembly space is twice its gauge: an explicit
witness for the parity theorem of cycle one. -/
theorem combined_card_eq_two_mul_gauge (hn : 0 < n) (P : FPuzzle n) :
    (combinedAssemblySet P).card = 2 * (polarityGauge hn (combinedAssemblySet P)).card :=
  card_eq_two_mul_gauge hn _ (fun _ ha => compAssign_mem_combined P ha)

/-- Parity, re-derived from the orbit decomposition rather than from a signed
product. -/
theorem union_card_even' (hn : 0 < n) (P : FPuzzle n) :
    Even (combinedAssemblySet P).card := by
  rw [combined_card_eq_two_mul_gauge hn P]
  exact even_two_mul _

/-- A self-complementary puzzle has exactly twice as many assemblies as gauge-fixed
assemblies. -/
theorem selfDual_card_eq_two_mul_gauge (hn : 0 < n) (P : FPuzzle n)
    (hself : assemblySet (compPuzzle P) = assemblySet P) :
    (assemblySet P).card = 2 * (polarityGauge hn (assemblySet P)).card := by
  refine card_eq_two_mul_gauge hn _ ?_
  intro a ha
  rw [mem_assemblySet] at ha ⊢
  have : compAssign a ∈ assemblySet (compPuzzle P) :=
    mem_assemblySet.2 ((assembles_compPuzzle_compAssign P a).2 ha)
  rw [hself, mem_assemblySet] at this
  exact this

/-- The gauge of the whole cube has `2^(n-1)` elements: the number of free
complementation orbits of assemblies is at most `2^(n-1)`. -/
theorem gauge_univ_card (hn : 0 < n) :
    (polarityGauge hn (Finset.univ : Finset (Fin n → Bool))).card = 2 ^ n / 2 := by
  have h : (Finset.univ : Finset (Fin n → Bool)).card = 2 * (polarityGauge hn Finset.univ).card :=
    card_eq_two_mul_gauge hn _ (fun _ _ => Finset.mem_univ _)
  have hcard : (Finset.univ : Finset (Fin n → Bool)).card = 2 ^ n := by
    simp [Finset.card_univ]
  omega

/-! ## Part 2 — Complementation as a permutation of the Boolean cube -/

/-- Complementation of assemblies, as a permutation of the Boolean cube. -/
def compAssignPerm (n : ℕ) : Equiv.Perm (Fin n → Bool) where
  toFun := compAssign
  invFun := compAssign
  left_inv := compAssign_involutive
  right_inv := compAssign_involutive

theorem compAssignPerm_sq (n : ℕ) : compAssignPerm n ^ 2 = 1 := by
  ext a i
  simp [compAssignPerm, pow_two, Equiv.Perm.mul_apply, compAssign]

/-- For `n ≥ 1`, complementation has no fixed point on the cube. -/
theorem compAssignPerm_fixedPoints_isEmpty (hn : 0 < n) :
    IsEmpty (Function.fixedPoints (compAssignPerm n)) := by
  constructor
  rintro ⟨a, ha⟩
  exact compAssign_ne hn a ha

/-- **Sign of complementation.**  As a permutation of the `2^n` assemblies,
global tab--blank complementation is a product of `2^(n-1)` disjoint
transpositions, so its sign is `(-1)^(2^(n-1))`. -/
theorem compAssignPerm_sign (hn : 0 < n) :
    Equiv.Perm.sign (compAssignPerm n) = (-1 : ℤˣ) ^ (2 ^ n / 2) := by
  have hfix : Fintype.card (Function.fixedPoints (compAssignPerm n)) = 0 := by
    have := compAssignPerm_fixedPoints_isEmpty hn
    exact Fintype.card_eq_zero_iff.2 this
  have h := Equiv.Perm.sign_of_pow_two_eq_one (compAssignPerm_sq n)
  rw [h, hfix]
  congr 1
  simp [Finset.card_univ]

/-- On a single variable complementation is a transposition: an **odd**
permutation. -/
theorem compAssignPerm_sign_one : Equiv.Perm.sign (compAssignPerm 1) = -1 := by
  rw [compAssignPerm_sign (by norm_num)]
  norm_num

/-- From two variables onwards complementation is an **even** permutation of the
cube: the `ℤ/2` trace of the edge involution on the symmetric group of
assemblies is visible only in the one-variable case. -/
theorem compAssignPerm_sign_even (hn : 2 ≤ n) :
    Equiv.Perm.sign (compAssignPerm n) = 1 := by
  have h0 : 0 < n := lt_of_lt_of_le (by norm_num) hn
  rw [compAssignPerm_sign h0]
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 2 := ⟨n - 2, by omega⟩
  have hdiv : 2 ^ (m + 2) / 2 = 2 * 2 ^ m := by
    rw [pow_succ]
    have : 2 ^ (m + 1) = 2 * 2 ^ m := by ring
    omega
  rw [hdiv, pow_mul]
  norm_num

/-! ## Part 3 — Bridge to the catalog's formula-level complementation -/

/-- Embed a framed clause piece into the `ℕ`-indexed clauses of the catalog
reduction. -/
def clauseToClause (c : FClause n) : Clause := c.map fun l => ((l.1 : ℕ), l.2)

/-- Embed a framed puzzle into the `ℕ`-indexed formulas of the catalog
reduction. -/
def toFormula (P : FPuzzle n) : Formula := P.map clauseToClause

/-- **Compatibility of the two complementations.**  The embedding intertwines the
framed tab--blank complement with the formula-level polarity complement of
`Shared.JigsawSolutionSpace`. -/
theorem toFormula_compPuzzle (P : FPuzzle n) :
    toFormula (compPuzzle P) = complementFormula (toFormula P) := by
  simp only [toFormula, compPuzzle, complementFormula, List.map_map]
  refine List.map_congr_left ?_
  intro c _
  simp only [Function.comp_apply, clauseToClause, compClause, complementClause, List.map_map]
  refine List.map_congr_left ?_
  intro l _
  rfl

/-- Extend a framed assembly to an assignment of all natural-number variables,
declaring every undeclared variable `false`. -/
def extendFramed (n : ℕ) (a : Fin n → Bool) : Assignment :=
  fun i => if h : i < n then a ⟨i, h⟩ else false

/-- Restrict a `ℕ`-indexed assignment to the declared variables. -/
def restrictFramed (n : ℕ) (a : Assignment) : Fin n → Bool := fun i => a i.1

@[simp] theorem restrict_extend (a : Fin n → Bool) :
    restrictFramed n (extendFramed n a) = a := by
  funext i
  simp [restrictFramed, extendFramed, i.2]

/-- Assembling the framed puzzle is exactly the catalog's `PuzzleAssembled` for
the embedded formula. -/
theorem assembles_iff_puzzleAssembled (P : FPuzzle n) (a : Assignment) :
    Assembles P (restrictFramed n a) ↔ PuzzleAssembled (toFormula P) a := by
  constructor
  · intro h c hc
    simp only [toFormula, List.mem_map] at hc
    obtain ⟨c', hc', rfl⟩ := hc
    obtain ⟨l, hl, hfit⟩ := h c' hc'
    refine ⟨((l.1 : ℕ), l.2), ?_, ?_⟩
    · simp only [clauseToClause, List.mem_map]
      exact ⟨l, hl, rfl⟩
    · rw [litFits_iff]
      have := (framedLitFits_iff (restrictFramed n a) l).1 hfit
      simpa [litSat, restrictFramed] using this
  · intro h c hc
    have hc' : clauseToClause c ∈ toFormula P := List.mem_map_of_mem hc
    obtain ⟨l, hl, hfit⟩ := h _ hc'
    simp only [clauseToClause, List.mem_map] at hl
    obtain ⟨l', hl', rfl⟩ := hl
    refine ⟨l', hl', ?_⟩
    rw [framedLitFits_iff]
    have := (litFits_iff a ((l'.1 : ℕ), l'.2)).1 hfit
    simpa [litSat, restrictFramed] using this

/-- **Solvability bridge.**  The framed assembly space is nonempty exactly when
the embedded catalog puzzle is solvable. -/
theorem nonempty_assemblySet_iff_solvable (P : FPuzzle n) :
    (assemblySet P).Nonempty ↔ PuzzleSolvable (toFormula P) := by
  constructor
  · rintro ⟨a, ha⟩
    refine ⟨extendFramed n a, ?_⟩
    rw [← assembles_iff_puzzleAssembled, restrict_extend]
    exact mem_assemblySet.1 ha
  · rintro ⟨a, ha⟩
    exact ⟨restrictFramed n a, mem_assemblySet.2
      ((assembles_iff_puzzleAssembled P a).2 ha)⟩

/-- **Solvability invariance, recovered.**  The framed puzzle is assemblable iff
its global tab--blank complement is.  This is the `π₀` shadow of the orbit
theorem: cycle one's `assemblySet_compPuzzle` upgrades it from a nonemptiness
statement to an equality of cardinalities, and `card_eq_two_mul_gauge` upgrades
that to an orbit decomposition. -/
theorem solvable_compPuzzle_iff (P : FPuzzle n) :
    (assemblySet (compPuzzle P)).Nonempty ↔ (assemblySet P).Nonempty := by
  rw [assemblySet_compPuzzle]
  exact Finset.image_nonempty

/-- The same statement transported to the catalog's formula language, showing the
concrete model refines `Jigsaw.puzzleSolvable_complement`. -/
theorem solvable_complementFormula_iff (P : FPuzzle n) :
    PuzzleSolvable (complementFormula (toFormula P)) ↔ PuzzleSolvable (toFormula P) := by
  rw [← toFormula_compPuzzle, ← nonempty_assemblySet_iff_solvable,
    ← nonempty_assemblySet_iff_solvable]
  exact solvable_compPuzzle_iff P

/-! ## Part 4 — Numerical experiments on the orbit structure -/

#eval (polarityGauge (by norm_num) (combinedAssemblySet P₁)).card
#eval (combinedAssemblySet P₁).card
#eval (polarityGauge (by norm_num) (assemblySet P₂)).card
#eval (assemblySet P₂).card
#eval toFormula P₁
#eval toFormula (compPuzzle P₁)

/-- The combined space of `P₁` is a single free orbit, gauge-fixed by the
variable-`0` polarity. -/
theorem P₁_gauge_card : (polarityGauge (n := 2) (by norm_num) (combinedAssemblySet P₁)).card = 1 := by
  decide

/-- The self-dual example `P₂` has four assemblies forming two free orbits. -/
theorem P₂_gauge_card : (polarityGauge (n := 2) (by norm_num) (assemblySet P₂)).card = 2 := by
  decide

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  Cycle two asked five sharper questions.  (K1) Is the parity
theorem the shadow of a canonical orbit *section*, computable rather than merely
existential?  (K2) Does the number of orbits admit a closed form?  (K3) What is
the sign of complementation in the symmetric group of the cube — is the edge
involution even or odd?  (K4) Does the concrete framed model map onto the
catalog's `ℕ`-indexed reduction compatibly with formula-level complementation?
(K5) Is solvability invariance exactly the `π₀` of the orbit statement?

**Experiment.**  A gauge was defined by fixing the polarity of variable `0`;
this is a section of the orbit map because complementation flips that
coordinate.  The decomposition was tested on the two running puzzles: `P₁` has a
two-element combined space with gauge of size `1` (one orbit) and `P₂` a
four-element self-dual space with gauge of size `2` (two orbits); both are closed
by enumeration of the cube.  The sign computation used the fixed-point formula
for involutions with the fixed-point set proved empty.  The embedding
`toFormula` was checked to intertwine `compPuzzle` with `complementFormula` and
evaluated on `P₁`.

**Analysis.**  K1 survives with a *canonical* answer: `card_eq_two_mul_gauge`
holds for every complement-stable finite set of assemblies, so parity is a
corollary with an explicit witness (`union_card_even'`), and the orbit count is
the gauge cardinality.  K2 survives for the ambient cube:
`gauge_univ_card` gives `2^n / 2`, an upper bound for any puzzle.  K3 gave the
most surprising outcome: the sign is `(-1)^(2^(n-1))`, hence complementation is
odd **only** for `n = 1` and even for all `n ≥ 2`.  The order-two edge symmetry
therefore has a nontrivial image in `ℤ/2 = S(cube)/A(cube)` in exactly one
dimension.  K4 and K5 survive (`toFormula_compPuzzle`,
`solvable_complementFormula_iff`), placing the earlier solvability invariance as
the nonemptiness shadow of the present orbit theorem.

**Critique.**  `card_eq_two_mul_gauge` is stated for arbitrary complement-stable
sets, which is where its strength lies; applying it to `assemblySet` requires the
transport lemma, so no circularity with cycle one arises (`union_card_even'` is
an independent second proof of `union_card_even`, not a restatement).  The gauge
depends on the choice of variable `0`; any variable would do, and the resulting
gauges are in canonical bijection, but that bijection is not formalised here.
`toFormula` sends distinct framed puzzles to distinct formulas only up to the
declared variable range; assignments outside `Fin n` are forced to `false` by
`extendFramed`, exactly as in `Shared.JigsawSolutionSpace`.  The sign theorem
needs `0 < n`; at `n = 0` complementation is the identity, consistent with the
zero-variable fixed configuration found in cycle one.

**Synthesis.**  Free complementation orbits of framed assemblies are indexed by a
computable polarity gauge; cardinality, parity, and solvability invariance are
three successive shadows of that one decomposition, and the involution's sign
isolates `n = 1` as the only dimension where the tab--blank symmetry is an odd
permutation of the assembly cube.
-/

end JigsawFreeComplement