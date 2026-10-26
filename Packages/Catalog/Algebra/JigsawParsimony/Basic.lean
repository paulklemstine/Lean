module

public import Mathlib

/-!
# Parity-preserving self-reduction for jigsaw assembly counting — the model

A *framed jigsaw puzzle on `n` variables* consists of `n` variable sockets, each of
which receives one of two variable pieces (tab = `1`, blank = `0`), together with a
list of clause pieces.  A clause piece exposes finitely many literal inputs, each
milled for a socket `i : Fin n` and a polarity `p : ZMod 2`; it snaps into place iff
at least one of its inputs mates with the variable piece chosen at its socket.

We work over `ZMod 2` so that global tab–blank complementation becomes the
translation `p ↦ p + 1`, and the whole symmetry group of the instance space is the
*hyperoctahedral group* `(ZMod 2)^n ⋊ Sₙ` of signed permutations of the sockets.

## Main results

* `SignedPerm.assemblyEquiv` : every signed permutation `g` induces an explicit
  bijection between the assembly space of `P` and that of `g • P`.
* `SignedPerm.count_actPuzzle` : the assembly count is an invariant of the whole
  hyperoctahedral action (not only of global complementation).
* `SignedPerm.actPuzzle_mul` : the action on puzzles is compatible with the group
  law of signed permutations, so invariance holds along whole orbits.
* `count_compPuzzle`, `count_compPuzzle_modEq`, `even_count_compPuzzle_iff` :
  global complementation is parsimonious; in particular every modular count, and
  the mod-2 count, is a complementation invariant.
* `compPuzzle_eq_self_iff` : complementation acts *freely* on the instance space
  away from the degenerate puzzles all of whose clause pieces are empty.
-/

@[expose] public section

namespace JigsawParsimony

open Finset

/-- The Boolean cube of variable-piece choices, written additively over `ZMod 2`. -/
abbrev Cube (n : ℕ) := Fin n → ZMod 2

/-- A literal input of a clause piece: a socket together with the polarity it is
milled for. -/
abbrev Lit (n : ℕ) := Fin n × ZMod 2

/-- A clause piece, given by its list of literal inputs. -/
abbrev ClausePiece (n : ℕ) := List (Lit n)

/-- A framed puzzle on `n` variables: its list of clause pieces. -/
abbrev Puzzle (n : ℕ) := List (ClausePiece n)

variable {n : ℕ}

/-- A literal input mates with the variable piece chosen at its socket. -/
def Fits (a : Cube n) (l : Lit n) : Prop := a l.1 = l.2

instance (a : Cube n) (l : Lit n) : Decidable (Fits a l) := by
  unfold Fits; infer_instance

/-- A choice of variable pieces assembles the puzzle when every clause piece has an
input that mates. -/
def Assembles (P : Puzzle n) (a : Cube n) : Prop := ∀ c ∈ P, ∃ l ∈ c, Fits a l

instance (P : Puzzle n) : DecidablePred (Assembles P) := by
  intro a; unfold Assembles; infer_instance

/-- The full (finite) assembly space of a puzzle. -/
def assemblies (P : Puzzle n) : Finset (Cube n) := univ.filter (Assembles P)

/-- The assembly count of a puzzle. -/
def count (P : Puzzle n) : ℕ := (assemblies P).card

@[simp] theorem mem_assemblies {P : Puzzle n} {a : Cube n} :
    a ∈ assemblies P ↔ Assembles P a := by
  simp [assemblies]

theorem count_eq_card_subtype (P : Puzzle n) :
    count P = Fintype.card {a : Cube n // Assembles P a} := by
  rw [Fintype.card_subtype]; rfl

/-! ## The hyperoctahedral group acting on puzzles -/

/-- A signed permutation of the sockets: relabel sockets by `perm`, then flip the
tab/blank polarity at socket `i` by `mask i`. -/
@[ext] structure SignedPerm (n : ℕ) where
  perm : Equiv.Perm (Fin n)
  mask : Cube n

namespace SignedPerm

variable (g h : SignedPerm n)

/-- Action on literal inputs. -/
def actLit (l : Lit n) : Lit n := (g.perm l.1, l.2 + g.mask l.1)

/-- Action on puzzles: transform every literal input of every clause piece. -/
def actPuzzle (P : Puzzle n) : Puzzle n := P.map (List.map g.actLit)

/-- Action on choices of variable pieces. -/
def actCube (a : Cube n) : Cube n := fun j => a (g.perm.symm j) + g.mask (g.perm.symm j)

/-- Inverse action on choices of variable pieces. -/
def invCube (b : Cube n) : Cube n := fun i => b (g.perm i) - g.mask i

theorem invCube_actCube (a : Cube n) : g.invCube (g.actCube a) = a := by
  funext i; simp [invCube, actCube]

theorem actCube_invCube (b : Cube n) : g.actCube (g.invCube b) = b := by
  funext j; simp [invCube, actCube]

theorem actCube_injective : Function.Injective g.actCube :=
  Function.LeftInverse.injective g.invCube_actCube

/-- Literal level transport. -/
theorem fits_act (a : Cube n) (l : Lit n) :
    Fits (g.actCube a) (g.actLit l) ↔ Fits a l := by
  simp only [Fits, actCube, actLit, Equiv.symm_apply_apply]
  exact add_left_inj _

/-- Puzzle level transport: `g` maps assemblies of `P` exactly onto assemblies of
`g • P`. -/
theorem assembles_act (P : Puzzle n) (a : Cube n) :
    Assembles (g.actPuzzle P) (g.actCube a) ↔ Assembles P a := by
  constructor
  · intro h c hc
    obtain ⟨l, hl, hf⟩ := h _ (List.mem_map_of_mem hc)
    obtain ⟨l', hl', rfl⟩ := List.mem_map.1 hl
    exact ⟨l', hl', (g.fits_act a l').1 hf⟩
  · intro h c hc
    obtain ⟨c', hc', rfl⟩ := List.mem_map.1 hc
    obtain ⟨l, hl, hf⟩ := h c' hc'
    exact ⟨g.actLit l, List.mem_map_of_mem hl, (g.fits_act a l).2 hf⟩

/-- **Witness-preserving bijection** induced by a signed permutation. -/
def assemblyEquiv (P : Puzzle n) :
    {a : Cube n // Assembles P a} ≃ {b : Cube n // Assembles (g.actPuzzle P) b} where
  toFun a := ⟨g.actCube a.1, (g.assembles_act P a.1).2 a.2⟩
  invFun b := ⟨g.invCube b.1, by
    have hb := b.2
    rw [← g.actCube_invCube b.1] at hb
    exact (g.assembles_act P _).1 hb⟩
  left_inv a := Subtype.ext (g.invCube_actCube a.1)
  right_inv b := Subtype.ext (g.actCube_invCube b.1)

/-- The assembly space of `g • P` is the image of that of `P`. -/
theorem assemblies_actPuzzle (P : Puzzle n) :
    assemblies (g.actPuzzle P) = (assemblies P).image g.actCube := by
  ext b
  simp only [mem_assemblies, Finset.mem_image]
  constructor
  · intro hb
    refine ⟨g.invCube b, ?_, g.actCube_invCube b⟩
    rw [← g.actCube_invCube b] at hb
    exact (g.assembles_act P _).1 hb
  · rintro ⟨a, ha, rfl⟩
    exact (g.assembles_act P a).2 ha

/-- **Hyperoctahedral invariance of the assembly count.** -/
theorem count_actPuzzle (P : Puzzle n) : count (g.actPuzzle P) = count P := by
  rw [count_eq_card_subtype, count_eq_card_subtype]
  exact (Fintype.card_congr (g.assemblyEquiv P)).symm

/-- Group law of signed permutations (`g * h` acts as "first `h`, then `g`"). -/
instance : Mul (SignedPerm n) :=
  ⟨fun g h => ⟨h.perm.trans g.perm, fun i => h.mask i + g.mask (h.perm i)⟩⟩

theorem mul_perm : (g * h).perm = h.perm.trans g.perm := rfl

theorem mul_mask (i : Fin n) : (g * h).mask i = h.mask i + g.mask (h.perm i) := rfl

theorem actLit_mul (l : Lit n) : (g * h).actLit l = g.actLit (h.actLit l) := by
  simp only [actLit, mul_perm, mul_mask, Equiv.trans_apply, Prod.mk.injEq, true_and]
  ring

/-- The action on puzzles is a genuine (left) action of the signed-permutation
monoid. -/
theorem actPuzzle_mul (P : Puzzle n) :
    (g * h).actPuzzle P = g.actPuzzle (h.actPuzzle P) := by
  simp only [actPuzzle, List.map_map]
  refine List.map_congr_left fun c _ => ?_
  simp only [Function.comp_apply, List.map_map]
  exact List.map_congr_left fun l _ => g.actLit_mul h l

/-- Orbit invariance: the count is constant along any finite word of signed
permutations. -/
theorem count_foldr_actPuzzle (gs : List (SignedPerm n)) (P : Puzzle n) :
    count (gs.foldr (fun g Q => g.actPuzzle Q) P) = count P := by
  induction gs with
  | nil => rfl
  | cons g gs ih => simp only [List.foldr_cons]; rw [count_actPuzzle, ih]

end SignedPerm

/-! ## Global tab–blank complementation -/

/-- Global complementation of a puzzle: reverse the polarity of every literal
input. -/
def compPuzzle (P : Puzzle n) : Puzzle n := P.map (List.map fun l => (l.1, l.2 + 1))

/-- Global complementation of a choice of variable pieces. -/
def compCube (a : Cube n) : Cube n := fun i => a i + 1

/-- Complementation is the signed permutation with trivial relabelling and full
mask. -/
def compSigned (n : ℕ) : SignedPerm n := ⟨1, fun _ => 1⟩

theorem compPuzzle_eq_actPuzzle (P : Puzzle n) :
    compPuzzle P = (compSigned n).actPuzzle P := rfl

theorem compCube_eq_actCube (a : Cube n) : compCube a = (compSigned n).actCube a := rfl

theorem add_one_add_one_zmod2 (x : ZMod 2) : x + 1 + 1 = x := by
  rw [add_assoc]; fin_cases x <;> rfl

theorem compPuzzle_involutive : Function.Involutive (compPuzzle (n := n)) := by
  intro P
  simp only [compPuzzle, List.map_map]
  conv_rhs => rw [← List.map_id P]
  refine List.map_congr_left fun c _ => ?_
  simp only [Function.comp_apply, List.map_map, id]
  conv_rhs => rw [← List.map_id c]
  refine List.map_congr_left fun l _ => ?_
  simp [add_one_add_one_zmod2]

theorem compCube_involutive : Function.Involutive (compCube (n := n)) := by
  intro a; funext i; simp [compCube, add_one_add_one_zmod2]

/-- The witness-preserving complementation bijection `assemblyEquiv`. -/
def assemblyEquiv (P : Puzzle n) :
    {a : Cube n // Assembles P a} ≃ {b : Cube n // Assembles (compPuzzle P) b} :=
  (compSigned n).assemblyEquiv P

/-- **Parsimony of complementation.**  `P` and its complement have equal assembly
counts. -/
theorem count_compPuzzle (P : Puzzle n) : count (compPuzzle P) = count P :=
  (compSigned n).count_actPuzzle P

/-- Every modular counting class is a complementation invariant. -/
theorem count_compPuzzle_modEq (k : ℕ) (P : Puzzle n) :
    count (compPuzzle P) ≡ count P [MOD k] := by
  rw [count_compPuzzle]

/-- The mod-2 assembly count is a complementation invariant. -/
theorem even_count_compPuzzle_iff (P : Puzzle n) :
    Even (count (compPuzzle P)) ↔ Even (count P) := by
  rw [count_compPuzzle]

/-- A clause piece is fixed by complementation only if it has no inputs. -/
theorem compClause_eq_self_iff (c : ClausePiece n) :
    c.map (fun l => (l.1, l.2 + 1)) = c ↔ c = [] := by
  constructor
  · intro h
    cases c with
    | nil => rfl
    | cons l c =>
        exfalso
        have h1 := (List.cons.inj h).1
        have h2 : l.2 + 1 = l.2 := congrArg Prod.snd h1
        have : (1 : ZMod 2) = 0 := by
          have := congrArg (fun x => x - l.2) h2
          simp at this
        exact absurd this (by decide)
  · rintro rfl; rfl

/-- **Freeness on the instance space.**  A puzzle is its own complement exactly
when all its clause pieces are empty; on every other instance complementation
moves the instance. -/
theorem compPuzzle_eq_self_iff (P : Puzzle n) :
    compPuzzle P = P ↔ ∀ c ∈ P, c = [] := by
  induction P with
  | nil => simp [compPuzzle]
  | cons c P ih =>
      simp only [compPuzzle, List.map_cons, List.cons.injEq, List.mem_cons,
        forall_eq_or_imp] at ih ⊢
      rw [compClause_eq_self_iff, ih]

/-- The degenerate self-complementary puzzles have count `0` (if some clause piece
is present) or `2^n` (the empty puzzle). -/
theorem count_of_compPuzzle_eq_self (P : Puzzle n) (h : compPuzzle P = P) :
    count P = if P = [] then 2 ^ n else 0 := by
  rw [compPuzzle_eq_self_iff] at h
  split_ifs with hP
  · subst hP
    rw [count, assemblies, Finset.filter_true_of_mem (fun a _ c hc => by simp at hc)]
    simp
  · obtain ⟨c, hc⟩ := List.exists_mem_of_ne_nil P hP
    have hc0 := h c hc
    subst hc0
    rw [count, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
    intro a ha
    obtain ⟨l, hl, _⟩ := (mem_assemblies.1 ha) [] hc
    simp at hl

end JigsawParsimony