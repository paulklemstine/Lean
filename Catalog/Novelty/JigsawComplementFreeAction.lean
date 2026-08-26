import Mathlib
import Novelty.JigsawNPComplete
import Geometry.JigsawComplementOrbits

/-!
# Complementation as a free involution on *concrete* framed-puzzle assembly spaces

The preceding cycles established two facts about global tab--blank
complementation.

* `Jigsaw.puzzleSolvable_complement` (`Shared.JigsawSolutionSpace`): simultaneous
  Boolean negation and literal-polarity reversal preserves *solvability*.
* `JigsawComplementOrbits.FramedComplementSystem` (`Geometry.JigsawComplementOrbits`):
  *if* one is handed an equivalence of the two assembly spaces, then the
  **tagged** disjoint union carries a free order-two action, hence has even
  cardinality.

Both leave the original conjecture untested where it actually bites.  The
abstract file works with a tagged sum, in which freeness is automatic and the
puzzle's own combinatorics never enter; and no concrete assembly space with a
concrete complementation equivalence was ever produced.

This file builds the concrete object and settles the conjecture in its
**untagged** form.

## What is constructed

A *framed puzzle on `n` variables* is a finite list of clause pieces, each of
which exposes finitely many literal inputs milled for a variable index
`Fin n` and a polarity.  An *assembly* is a choice of one variable piece per
variable (a point of the Boolean cube `Fin n → Bool`) which lets every clause
piece snap into place, using the catalog's edge alphabet, complementation and
truth encoding from `Novelty.JigsawNPComplete`.

Global complementation `compPuzzle` reverses every literal polarity; on
assemblies it is Boolean negation `compAssign`.

## What is proved

* `assembles_compPuzzle_compAssign`: complementation is an *exact* transport of
  assembly spaces, `assemblySet (compPuzzle P) = (assemblySet P).image compAssign`.
* `union_card_even`: for `n ≥ 1` the **untagged** union
  `assemblySet P ∪ assemblySet (compPuzzle P)` has even cardinality — no
  non-self-duality hypothesis is needed.  The same holds for the intersection.
* `selfDual_card_even`: a self-complementary framed puzzle on `n ≥ 1` variables
  has an *even* number of assemblies.  So self-dual puzzles are not fixed
  configurations at all; they are the case where the free involution acts on a
  single space.
* `conjecture_nonSelfDual`: the conjecture as originally posed, derived as a
  corollary.
* `zeroVar_union_card_odd`: the boundary is sharp, and it is `n = 0`, not
  self-duality: the empty framed puzzle on zero variables has a one-element
  union.  Since every zero-variable puzzle is self-complementary
  (`compPuzzle_of_zero`), the original hypothesis is vacuous exactly where it
  would have been needed.
* `concreteFramedSystem`: the concrete model is exhibited as an instance of the
  abstract `FramedComplementSystem`, so the earlier abstract theory is no longer
  hypothetical.
-/

open Function

namespace JigsawFreeComplement

open Jigsaw

/-! ## Part 1 — A general parity principle for free involutions -/

/-- **Free-involution parity.**  A finite set stable under a fixed-point-free
involution has even cardinality.  The proof pairs elements off through a signed
product: the constant `-1` telescopes over the involution's orbits. -/
theorem even_card_of_free_involution {α : Type*} [DecidableEq α] (s : Finset α)
    (g : α → α) (hmem : ∀ a ∈ s, g a ∈ s) (hinv : ∀ a ∈ s, g (g a) = a)
    (hfree : ∀ a ∈ s, g a ≠ a) : Even s.card := by
  have hprod : ∏ _x ∈ s, (-1 : ℤ) = 1 := by
    refine Finset.prod_involution (fun a _ => g a) (fun a _ => by ring)
      (fun a ha _ => hfree a ha) (fun a ha => hmem a ha) (fun a ha => hinv a ha)
  rw [Finset.prod_const] at hprod
  rcases Nat.even_or_odd s.card with h | h
  · exact h
  · rw [h.neg_one_pow] at hprod
    norm_num at hprod

/-! ## Part 2 — Framed puzzles on a finite variable set -/

variable {n : ℕ}

/-- A literal input of a clause piece: a variable index together with the
polarity the input edge is milled for. -/
abbrev FLit (n : ℕ) := Fin n × Bool

/-- A clause piece, described by the literal inputs it exposes. -/
abbrev FClause (n : ℕ) := List (FLit n)

/-- A framed puzzle on `n` variables: the list of its clause pieces.  The frame
(border pieces) and the `n` pairs of variable pieces are implicit in the
variable set. -/
abbrev FPuzzle (n : ℕ) := List (FClause n)

/-- One literal input interlocks with the variable piece chosen by `a`: the
variable's output edge `enc (a i)` must mate with the input edge
`(enc p).comp`. -/
def framedLitFits (a : Fin n → Bool) (l : FLit n) : Prop :=
  Edge.fits (enc (a l.1)) ((enc l.2).comp)

instance (a : Fin n → Bool) (l : FLit n) : Decidable (framedLitFits a l) := by
  unfold framedLitFits Edge.fits
  infer_instance

/-- **Local dictionary, framed version.**  A literal input interlocks exactly
when the chosen variable piece carries the required polarity.  This uses
injectivity of both the truth encoding and edge complementation. -/
theorem framedLitFits_iff (a : Fin n → Bool) (l : FLit n) :
    framedLitFits a l ↔ a l.1 = l.2 := by
  unfold framedLitFits Edge.fits
  exact ⟨fun h => (enc_injective (Edge.comp_injective h)).symm, fun h => by rw [h]⟩

/-- A choice of variable pieces assembles the puzzle when every clause piece has
at least one interlocking literal input. -/
def Assembles (P : FPuzzle n) (a : Fin n → Bool) : Prop :=
  ∀ c ∈ P, ∃ l ∈ c, framedLitFits a l

instance (P : FPuzzle n) (a : Fin n → Bool) : Decidable (Assembles P a) := by
  unfold Assembles
  infer_instance

/-- The complete assembly space of a framed puzzle, as a finite set of points of
the Boolean cube. -/
def assemblySet (P : FPuzzle n) : Finset (Fin n → Bool) :=
  Finset.univ.filter (Assembles P)

@[simp] theorem mem_assemblySet {P : FPuzzle n} {a : Fin n → Bool} :
    a ∈ assemblySet P ↔ Assembles P a := by
  simp [assemblySet]

/-! ## Part 3 — Global tab--blank complementation -/

/-- Reverse the polarity every input edge of a clause piece is milled for. -/
def compClause (c : FClause n) : FClause n := c.map fun l => (l.1, !l.2)

/-- Global tab--blank complementation of a framed puzzle. -/
def compPuzzle (P : FPuzzle n) : FPuzzle n := P.map compClause

/-- Boolean negation of an assembly: every variable piece is replaced by its
partner. -/
def compAssign (a : Fin n → Bool) : Fin n → Bool := fun i => !a i

theorem compClause_involutive : Involutive (compClause (n := n)) := by
  intro c
  induction c with
  | nil => rfl
  | cons l c ih =>
      simp only [compClause, List.map_cons, Bool.not_not] at *
      simp [ih]

theorem compPuzzle_involutive : Involutive (compPuzzle (n := n)) := by
  intro P
  have h : ∀ c : FClause n, compClause (compClause c) = c := compClause_involutive
  simp [compPuzzle, List.map_map, Function.comp_def, h]

theorem compAssign_involutive : Involutive (compAssign (n := n)) := by
  intro a; funext i; simp [compAssign]

/-- Complementation of assemblies is **free** as soon as there is at least one
variable: no choice of variable pieces is its own Boolean negation. -/
theorem compAssign_ne (hn : 0 < n) (a : Fin n → Bool) : compAssign a ≠ a := by
  intro h
  have := congrFun h ⟨0, hn⟩
  simp [compAssign] at this

/-! ## Part 4 — Complementation transports assembly spaces exactly -/

/-- Literal level: a complemented input interlocks with the complemented
assembly exactly when the original input interlocked with the original
assembly. -/
theorem framedLitFits_comp (a : Fin n → Bool) (l : FLit n) :
    framedLitFits (compAssign a) (l.1, !l.2) ↔ framedLitFits a l := by
  simp [framedLitFits_iff, compAssign]

/-- Clause level. -/
theorem clause_comp (a : Fin n → Bool) (c : FClause n) :
    (∃ l ∈ compClause c, framedLitFits (compAssign a) l) ↔
      (∃ l ∈ c, framedLitFits a l) := by
  constructor
  · rintro ⟨l, hl, hfit⟩
    simp only [compClause, List.mem_map] at hl
    obtain ⟨l', hl', rfl⟩ := hl
    exact ⟨l', hl', (framedLitFits_comp a l').1 hfit⟩
  · rintro ⟨l, hl, hfit⟩
    refine ⟨(l.1, !l.2), ?_, (framedLitFits_comp a l).2 hfit⟩
    simp only [compClause, List.mem_map]
    exact ⟨l, hl, rfl⟩

/-- **Exact transport of assembly spaces.**  Simultaneous Boolean negation and
literal-polarity reversal carries assemblies of `P` bijectively onto assemblies
of the complemented puzzle. -/
theorem assembles_compPuzzle_compAssign (P : FPuzzle n) (a : Fin n → Bool) :
    Assembles (compPuzzle P) (compAssign a) ↔ Assembles P a := by
  constructor
  · intro h c hc
    have hc' : compClause c ∈ compPuzzle P := List.mem_map_of_mem hc
    exact (clause_comp a c).1 (h _ hc')
  · intro h c hc
    simp only [compPuzzle, List.mem_map] at hc
    obtain ⟨c', hc', rfl⟩ := hc
    exact (clause_comp a c').2 (h c' hc')

/-- The complemented assembly space is the image of the original one under
Boolean negation. -/
theorem assemblySet_compPuzzle (P : FPuzzle n) :
    assemblySet (compPuzzle P) = (assemblySet P).image compAssign := by
  ext b
  simp only [mem_assemblySet, Finset.mem_image]
  constructor
  · intro hb
    refine ⟨compAssign b, ?_, compAssign_involutive b⟩
    rw [← compAssign_involutive b] at hb
    exact (assembles_compPuzzle_compAssign P _).1 hb
  · rintro ⟨a, ha, rfl⟩
    exact (assembles_compPuzzle_compAssign P a).2 ha

/-- The two assembly spaces have the same cardinality: complementation is an
equinumerosity, not merely a preservation of nonemptiness. -/
theorem card_assemblySet_compPuzzle (P : FPuzzle n) :
    (assemblySet (compPuzzle P)).card = (assemblySet P).card := by
  rw [assemblySet_compPuzzle]
  exact Finset.card_image_of_injective _ compAssign_involutive.injective

/-- Complementation of a *complete* assembly space, as an equivalence of
subtypes. -/
def assemblyEquiv (P : FPuzzle n) :
    {a : Fin n → Bool // Assembles P a} ≃ {a : Fin n → Bool // Assembles (compPuzzle P) a} where
  toFun a := ⟨compAssign a.1, (assembles_compPuzzle_compAssign P a.1).2 a.2⟩
  invFun b := ⟨compAssign b.1, by
    have h := b.2
    rw [← compAssign_involutive b.1] at h
    exact (assembles_compPuzzle_compAssign P _).1 h⟩
  left_inv a := by ext i; simp [compAssign]
  right_inv b := by ext i; simp [compAssign]

/-! ## Part 5 — The untagged parity theorem -/

/-- The untagged combined assembly space: assemblies of the puzzle together with
assemblies of its complement, viewed inside the same Boolean cube (no tag). -/
def combinedAssemblySet (P : FPuzzle n) : Finset (Fin n → Bool) :=
  assemblySet P ∪ assemblySet (compPuzzle P)

/-- The untagged combined space is stable under complementation. -/
theorem compAssign_mem_combined (P : FPuzzle n) {a : Fin n → Bool}
    (ha : a ∈ combinedAssemblySet P) : compAssign a ∈ combinedAssemblySet P := by
  simp only [combinedAssemblySet, Finset.mem_union, mem_assemblySet] at ha ⊢
  rcases ha with h | h
  · exact Or.inr ((assembles_compPuzzle_compAssign P a).2 h)
  · refine Or.inl ?_
    rw [← compAssign_involutive a] at h
    exact (assembles_compPuzzle_compAssign P _).1 h

/-- **Main theorem (untagged form of the conjecture).**  On at least one
variable, global tab--blank complementation acts freely on the union of the two
assembly spaces, so that union has even cardinality.  No hypothesis excluding
self-dual puzzles is required. -/
theorem union_card_even (hn : 0 < n) (P : FPuzzle n) :
    Even (combinedAssemblySet P).card := by
  refine even_card_of_free_involution _ compAssign
    (fun a ha => compAssign_mem_combined P ha)
    (fun a _ => compAssign_involutive a) (fun a _ => compAssign_ne hn a)

/-- The intersection of the two assembly spaces is likewise complement-stable,
hence of even cardinality. -/
theorem inter_card_even (hn : 0 < n) (P : FPuzzle n) :
    Even (assemblySet P ∩ assemblySet (compPuzzle P)).card := by
  refine even_card_of_free_involution _ compAssign ?_
    (fun a _ => compAssign_involutive a) (fun a _ => compAssign_ne hn a)
  intro a ha
  simp only [Finset.mem_inter, mem_assemblySet] at ha ⊢
  obtain ⟨h1, h2⟩ := ha
  refine ⟨?_, (assembles_compPuzzle_compAssign P a).2 h1⟩
  rw [← compAssign_involutive a] at h2
  exact (assembles_compPuzzle_compAssign P _).1 h2

/-- **Self-dual puzzles are not fixed configurations.**  If a framed puzzle on at
least one variable has a complement-stable assembly space (in particular if it
is literally self-complementary), then complementation acts freely on that
single space and the puzzle has an even number of assemblies. -/
theorem selfDual_card_even (hn : 0 < n) (P : FPuzzle n)
    (hself : assemblySet (compPuzzle P) = assemblySet P) :
    Even (assemblySet P).card := by
  have h := union_card_even hn P
  rwa [combinedAssemblySet, hself, Finset.union_self] at h

/-- Every framed puzzle on zero variables is self-complementary: a clause piece
over an empty variable set exposes no literal inputs at all. -/
theorem compPuzzle_of_zero (P : FPuzzle 0) : compPuzzle P = P := by
  have hc : ∀ c : FClause 0, compClause c = c := by
    intro c
    cases c with
    | nil => rfl
    | cons l _ => exact absurd l.1.2 (Nat.not_lt_zero _)
  show List.map compClause P = P
  calc List.map compClause P = List.map id P := List.map_congr_left (fun c _ => hc c)
    _ = P := List.map_id P

/-- **Corollary: the conjecture as originally posed.**  A framed puzzle that is
*not* isomorphic to its global complement has an even combined assembly count.
The proof shows the hypothesis is doing only one job: ruling out `n = 0`. -/
theorem conjecture_nonSelfDual (P : FPuzzle n) (hP : compPuzzle P ≠ P) :
    Even (combinedAssemblySet P).card := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · exact absurd (compPuzzle_of_zero P) hP
  · exact union_card_even hn P

/-! ## Part 6 — Sharpness: the boundary is `n = 0`, not self-duality -/

/-- The empty framed puzzle on zero variables: every clause piece (there are
none) trivially snaps into place. -/
theorem zeroVar_assemblySet : assemblySet ([] : FPuzzle 0) = Finset.univ := by
  ext a
  simp only [mem_assemblySet, Finset.mem_univ, iff_true]
  intro c hc
  exact absurd hc (List.not_mem_nil)

/-- Its combined assembly space has exactly one element, so the parity
conclusion genuinely fails for `n = 0`.  Complementation fixes the unique
(empty) assembly: this is the *only* self-dual fixed configuration. -/
theorem zeroVar_union_card_odd :
    (combinedAssemblySet ([] : FPuzzle 0)).card = 1 := by
  have h : compPuzzle ([] : FPuzzle 0) = [] := rfl
  rw [combinedAssemblySet, h, Finset.union_self, zeroVar_assemblySet]
  simp

/-- Explicitly: the parity statement is false at `n = 0`. -/
theorem zeroVar_not_even : ¬ Even (combinedAssemblySet ([] : FPuzzle 0)).card := by
  rw [zeroVar_union_card_odd]; decide

/-- And the fixed point is real: on zero variables complementation of assemblies
is the identity. -/
theorem zeroVar_compAssign_fixed (a : Fin 0 → Bool) : compAssign a = a := by
  funext i; exact absurd i.2 (Nat.not_lt_zero _)

/-! ## Part 7 — Worked framed puzzles

`P₁ = (x₀) ∧ (x₁)` on two variables has a single assembly; its complement
`(¬x₀) ∧ (¬x₁)` also has a single one, and the two are distinct, so the union
has two elements — a single free orbit.

`P₂ = (x₀ ∨ ¬x₀)` is self-complementary up to reordering; its assembly space is
the whole cube of size four, complement-stable and even, illustrating
`selfDual_card_even`. -/

/-- `(x₀) ∧ (x₁)` on two variables. -/
def P₁ : FPuzzle 2 := [[(0, true)], [(1, true)]]

/-- `(x₀ ∨ ¬x₀)` on two variables: a tautological clause piece. -/
def P₂ : FPuzzle 2 := [[(0, true), (0, false)]]

theorem P₁_card : (assemblySet P₁).card = 1 := by decide

theorem P₁_comp_card : (assemblySet (compPuzzle P₁)).card = 1 := by decide

/-- The two assemblies of the combined space of `P₁` form exactly one free
complementation orbit. -/
theorem P₁_union_card : (combinedAssemblySet P₁).card = 2 := by decide

example : Even (combinedAssemblySet P₁).card := union_card_even (by norm_num) P₁

/-- `P₁` really is non-self-dual, so it is an instance of the conjecture as
originally posed. -/
theorem P₁_not_selfDual : compPuzzle P₁ ≠ P₁ := by decide

/-- `P₂` has a complement-stable assembly space, and its assembly count is even,
as `selfDual_card_even` predicts. -/
theorem P₂_selfDual : assemblySet (compPuzzle P₂) = assemblySet P₂ := by decide

theorem P₂_card : (assemblySet P₂).card = 4 := by decide

example : Even (assemblySet P₂).card := selfDual_card_even (by norm_num) P₂ P₂_selfDual

/-! ## Part 8 — The abstract framed system, instantiated

`Geometry.JigsawComplementOrbits.FramedComplementSystem` axiomatised exactly the
data proved above.  Feeding the concrete model into it turns the earlier
abstract tagged theory into a theorem about actual framed puzzles. -/

open JigsawComplementOrbits in
/-- The concrete framed-puzzle model as a `FramedComplementSystem`. -/
def concreteFramedSystem : FramedComplementSystem where
  Puzzle := Σ n : ℕ, FPuzzle n
  Assembly := fun p => {a : Fin p.1 → Bool // Assembles p.2 a}
  complement := fun p => ⟨p.1, compPuzzle p.2⟩
  complement_involutive := by
    intro p
    obtain ⟨n, P⟩ := p
    simp [compPuzzle_involutive P]
  assemblyComplement := fun p => assemblyEquiv p.2
  finiteAssembly := fun _ => inferInstance

open JigsawComplementOrbits in
/-- Consequence of the instantiation: for a concrete framed puzzle the *tagged*
combined space is even, for every `n` — including `n = 0`, where the untagged
statement fails.  The two theorems together locate exactly what the tag buys. -/
theorem concrete_tagged_even (p : concreteFramedSystem.Puzzle) :
    letI := concreteFramedSystem.finiteAssembly p
    letI := concreteFramedSystem.finiteAssembly (concreteFramedSystem.complement p)
    Even (Fintype.card (concreteFramedSystem.CombinedAssemblies p)) :=
  concreteFramedSystem.combinedAssemblies_even p

open JigsawComplementOrbits in
/-- Freeness on the tagged space, for concrete framed puzzles. -/
theorem concrete_tagged_free (p : concreteFramedSystem.Puzzle)
    (x : concreteFramedSystem.CombinedAssemblies p) :
    concreteFramedSystem.complementAssembly p x ≠ x :=
  concreteFramedSystem.complementAssembly_free p x

/-! ## Part 9 — Numerical experiments -/

#eval (assemblySet P₁).card
#eval (assemblySet (compPuzzle P₁)).card
#eval (combinedAssemblySet P₁).card
#eval (assemblySet P₂).card
#eval (combinedAssemblySet ([] : FPuzzle 0)).card

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  Seven conjectures were ranked.  (H1) Complementation transports
*complete* assembly spaces, not just solvability.  (H2) The untagged union of the
two assembly spaces always has even cardinality.  (H3) Self-duality is the
obstruction to freeness, as the mission statement proposes.  (H4) Self-dual
framed puzzles have an even number of assemblies.  (H5) There is a fixed
configuration, and it is unique.  (H6) The abstract `FramedComplementSystem` is
inhabited by a genuinely combinatorial model.  (H7) Parity is stable under the
piece-count grading of the reduction.

**Experiment.**  A finite-variable framed model was built on the catalog edge
alphabet (`Edge`, `Edge.comp`, `enc`) and the assembly space realised as a
`Finset` of the Boolean cube, so cardinalities are computable.  Two worked
puzzles were evaluated: `P₁ = (x₀) ∧ (x₁)` gives `1 + 1` assemblies with a
two-element union (one free orbit); `P₂ = (x₀ ∨ ¬x₀)` gives a complement-stable
space of size `4`.  Both counts are closed by `decide`, i.e. by genuine
enumeration of the cube, and both agree with the general theorems.  The
zero-variable puzzle was evaluated as a counterexample hunt.

**Analysis.**  H1 and H2 survive: `assemblySet_compPuzzle` shows the transport is
an image under Boolean negation, and `union_card_even` gives parity from the
free-involution principle `even_card_of_free_involution`, proved by a signed
telescoping product rather than by induction on pairs.  H3 is **false**, and its
failure is instructive: freeness of `compAssign` needs only `0 < n`, because a
Boolean vector is never its own negation.  Self-duality does not create fixed
points; it merely collapses the two spaces onto one, which is why H4 is true
(`selfDual_card_even`) and is a *strictly stronger* statement than the original
conjecture.  H5 survives in a degenerate form: the unique fixed configuration is
the empty assembly on zero variables (`zeroVar_compAssign_fixed`), which is
exactly where parity fails (`zeroVar_not_even`).  H6 survives
(`concreteFramedSystem`).  H7 was not tested and is left open.

**Critique.**  No theorem here is `True`, `rfl`-only or `native_decide`-only: the
parity principle uses `Finset.prod_involution` and a sign argument, the transport
lemmas use injectivity of `enc` and of `Edge.comp` through
`framedLitFits_iff`, and the `decide` calls are finite enumerations *supporting*
general theorems rather than substituting for them.  The one real hidden
assumption of the mission statement — that non-self-duality is what forces
freeness — is refuted here and replaced by the sharp condition `0 < n`; the
original claim is nevertheless recovered as `conjecture_nonSelfDual`, whose proof
shows the hypothesis is only excluding the zero-variable case
(`compPuzzle_of_zero`).  A remaining boundary: `assemblySet` identifies puzzles
with equal assembly spaces, so "self-dual" is used in the assembly-space sense;
`P₂_selfDual` is of this kind, since `compPuzzle P₂` reorders the literal inputs.

**Synthesis.**  Complementation is an order-two transport of complete assembly
spaces whose freeness is a property of the *Boolean cube*, not of the puzzle.
Tagging buys freeness unconditionally; untagged, one free orbit structure holds
for every puzzle on at least one variable, and the only fixed configuration in
the entire theory is the empty assembly.
-/

end JigsawFreeComplement