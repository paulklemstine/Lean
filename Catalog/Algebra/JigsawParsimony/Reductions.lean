module

public import Catalog.Algebra.JigsawParsimony.Basic

/-!
# Parsimonious counting reductions: `#SAT → #Jigsaw → #Jigsaw`

We formalise a *counting problem* (instances, an encoding size, and a count) and a
*parsimonious reduction* between counting problems: an instance map preserving the
exact count and blowing up the encoding size at most linearly.  (Linear size
growth is the formal proxy used here for "polynomial-time"; the maps below are
structural recursions over lists, but running time itself is not modelled.)

## Main results

* `ParsimoniousReduction.comp`, `ParsimoniousReduction.count_modEq` : parsimonious
  reductions compose and transport every modular count (`⊕P`, `Mod_kP`).
* `compReduction` / `compPuzzle_isParsimoniousSelfReduction` : global complementation
  is a size-preserving, involutive parsimonious self-reduction of `#Jigsaw`.
* `count_toPuzzle` : the encoding of DIMACS CNF formulas as framed puzzles preserves
  the number of solutions exactly (literals naming undeclared variables are
  genuinely unsatisfiable on both sides), giving `satToJigsaw`.
* `toDimacs`, `satCount_toDimacs` : the converse encoding, so `#SAT` and `#Jigsaw` are
  parsimoniously inter-reducible; `satToJigsawComp` composes with complementation.
* `reduction_to_jigsaw_of_reduction_to_sat` : every counting problem that reduces
  parsimoniously to `#SAT` reduces parsimoniously to `#Jigsaw`, through either `P`
  or its complement.
-/

@[expose] public section

namespace JigsawParsimony

open Finset

/-- A counting problem: instances with an encoding size and a solution count. -/
structure CountingProblem where
  Inst : Type
  size : Inst → ℕ
  count : Inst → ℕ

/-- A parsimonious reduction with linearly bounded size growth. -/
structure ParsimoniousReduction (A B : CountingProblem) where
  map : A.Inst → B.Inst
  count_map : ∀ x, B.count (map x) = A.count x
  sizeMul : ℕ
  sizeAdd : ℕ
  size_map : ∀ x, B.size (map x) ≤ sizeMul * A.size x + sizeAdd

namespace ParsimoniousReduction

variable {A B C : CountingProblem}

/-- The identity reduction. -/
def refl (A : CountingProblem) : ParsimoniousReduction A A :=
  ⟨id, fun _ => rfl, 1, 0, fun x => by simp⟩

/-- Composition of parsimonious reductions. -/
def comp (g : ParsimoniousReduction B C) (f : ParsimoniousReduction A B) :
    ParsimoniousReduction A C where
  map := g.map ∘ f.map
  count_map x := by simp [g.count_map, f.count_map]
  sizeMul := g.sizeMul * f.sizeMul
  sizeAdd := g.sizeMul * f.sizeAdd + g.sizeAdd
  size_map x := by
    have h1 := g.size_map (f.map x)
    have h2 := f.size_map x
    calc C.size (g.map (f.map x)) ≤ g.sizeMul * B.size (f.map x) + g.sizeAdd := h1
      _ ≤ g.sizeMul * (f.sizeMul * A.size x + f.sizeAdd) + g.sizeAdd := by gcongr
      _ = g.sizeMul * f.sizeMul * A.size x + (g.sizeMul * f.sizeAdd + g.sizeAdd) := by ring

/-- Parsimonious reductions transport every modular counting class. -/
theorem count_modEq (f : ParsimoniousReduction A B) (k : ℕ) (x : A.Inst) :
    B.count (f.map x) ≡ A.count x [MOD k] := by
  rw [f.count_map]

/-- In particular they transport the mod-2 count. -/
theorem even_count_iff (f : ParsimoniousReduction A B) (x : A.Inst) :
    Even (B.count (f.map x)) ↔ Even (A.count x) := by
  rw [f.count_map]

end ParsimoniousReduction

/-! ## The counting problem `#Jigsaw` and its complementation self-reduction -/

/-- Encoding size of a framed puzzle: sockets + literal inputs + clause pieces. -/
def puzzleSize {n : ℕ} (P : Puzzle n) : ℕ := n + (P.map List.length).sum + P.length

/-- The assembly counting problem for framed jigsaw puzzles. -/
def jigsawCount : CountingProblem where
  Inst := Σ n : ℕ, Puzzle n
  size x := puzzleSize x.2
  count x := count x.2

theorem puzzleSize_compPuzzle {n : ℕ} (P : Puzzle n) :
    puzzleSize (compPuzzle P) = puzzleSize P := by
  simp [puzzleSize, compPuzzle, Function.comp_def]

/-- Complementation on instances of `#Jigsaw`. -/
def compInst (x : jigsawCount.Inst) : jigsawCount.Inst := ⟨x.1, compPuzzle x.2⟩

/-- **Complementation is a parsimonious self-reduction of `#Jigsaw`**, with no size
growth at all. -/
def compReduction : ParsimoniousReduction jigsawCount jigsawCount where
  map := compInst
  count_map x := count_compPuzzle x.2
  sizeMul := 1
  sizeAdd := 0
  size_map x := by simp [jigsawCount, compInst, puzzleSize_compPuzzle]

theorem compReduction_involutive : Function.Involutive compReduction.map := by
  rintro ⟨n, P⟩
  simp [compReduction, compInst, compPuzzle_involutive P]

/-- A self-map of an instance space is a *parsimonious self-reduction* if it
preserves the count and grows the size at most linearly. -/
def IsParsimoniousSelfReduction (A : CountingProblem) (f : A.Inst → A.Inst) : Prop :=
  (∀ x, A.count (f x) = A.count x) ∧ ∃ c d : ℕ, ∀ x, A.size (f x) ≤ c * A.size x + d

theorem compPuzzle_isParsimoniousSelfReduction :
    IsParsimoniousSelfReduction jigsawCount compInst :=
  ⟨compReduction.count_map, 1, 0, compReduction.size_map⟩

/-- Every signed permutation of the sockets gives a parsimonious self-reduction too. -/
theorem signedPerm_isParsimoniousSelfReduction
    (g : ∀ n, SignedPerm n) :
    IsParsimoniousSelfReduction jigsawCount (fun x => ⟨x.1, (g x.1).actPuzzle x.2⟩) := by
  refine ⟨fun x => (g x.1).count_actPuzzle x.2, 1, 0, fun x => ?_⟩
  simp [jigsawCount, puzzleSize, SignedPerm.actPuzzle, Function.comp_def]

/-! ## `#SAT` in DIMACS format -/

/-- A CNF formula in DIMACS style: `nvars` declared variables, literals are nonzero
integers `±(i+1)`. -/
structure DimacsCNF where
  nvars : ℕ
  clauses : List (List ℤ)

/-- Polarity of a DIMACS literal as an element of `ZMod 2`. -/
def dimacsPol (k : ℤ) : ZMod 2 := if 0 < k then 1 else 0

/-- A DIMACS literal is true under `a` if it names a declared variable carrying the
right polarity.  Literals naming undeclared variables (or `0`) are false. -/
def DimacsLitTrue {nv : ℕ} (a : Cube nv) (k : ℤ) : Prop :=
  ∃ i : Fin nv, k.natAbs = i.1 + 1 ∧ a i = dimacsPol k

instance {nv : ℕ} (a : Cube nv) (k : ℤ) : Decidable (DimacsLitTrue a k) := by
  unfold DimacsLitTrue; infer_instance

/-- Satisfaction of a DIMACS formula. -/
def DimacsCNF.Sat (F : DimacsCNF) (a : Cube F.nvars) : Prop :=
  ∀ c ∈ F.clauses, ∃ k ∈ c, DimacsLitTrue a k

instance (F : DimacsCNF) : DecidablePred F.Sat := by
  intro a; unfold DimacsCNF.Sat; infer_instance

/-- The number of satisfying assignments of the declared variables. -/
def satCount (F : DimacsCNF) : ℕ := (univ.filter F.Sat).card

/-- Encoding size of a DIMACS formula. -/
def dimacsSize (F : DimacsCNF) : ℕ := F.nvars + (F.clauses.map List.length).sum + F.clauses.length

/-- The counting problem `#SAT`. -/
def sharpSAT : CountingProblem := ⟨DimacsCNF, dimacsSize, satCount⟩

/-- Translate a DIMACS literal into a literal input milled for a declared socket,
discarding literals that name no declared variable. -/
def toLit (nv : ℕ) (k : ℤ) : Option (Lit nv) :=
  if h : k.natAbs - 1 < nv ∧ k ≠ 0 then some (⟨k.natAbs - 1, h.1⟩, dimacsPol k) else none

/-- The puzzle built from a DIMACS formula: one clause piece per clause. -/
def toPuzzle (F : DimacsCNF) : Puzzle F.nvars :=
  F.clauses.map (List.filterMap (toLit F.nvars))

theorem exists_toLit_fits_iff {nv : ℕ} (a : Cube nv) (k : ℤ) :
    (∃ l, toLit nv k = some l ∧ Fits a l) ↔ DimacsLitTrue a k := by
  unfold toLit DimacsLitTrue Fits
  constructor
  · rintro ⟨l, hl, hf⟩
    split_ifs at hl with h
    cases hl
    refine ⟨⟨k.natAbs - 1, h.1⟩, ?_, hf⟩
    have : k.natAbs ≠ 0 := Int.natAbs_ne_zero.2 h.2
    simp only
    omega
  · rintro ⟨i, hi, ha⟩
    have hk : k ≠ 0 := by
      intro hk; subst hk; simp at hi
    have hlt : k.natAbs - 1 < nv := by omega
    refine ⟨(⟨k.natAbs - 1, hlt⟩, dimacsPol k), by rw [dif_pos ⟨hlt, hk⟩], ?_⟩
    have : (⟨k.natAbs - 1, hlt⟩ : Fin nv) = i := Fin.ext (by simp only; omega)
    simpa [this] using ha

/-- The clause piece of `c` fits iff `c` is satisfied. -/
theorem clausePiece_fits_iff {nv : ℕ} (a : Cube nv) (c : List ℤ) :
    (∃ l ∈ c.filterMap (toLit nv), Fits a l) ↔ ∃ k ∈ c, DimacsLitTrue a k := by
  simp only [List.mem_filterMap]
  constructor
  · rintro ⟨l, ⟨k, hk, hkl⟩, hf⟩
    exact ⟨k, hk, (exists_toLit_fits_iff a k).1 ⟨l, hkl, hf⟩⟩
  · rintro ⟨k, hk, ht⟩
    obtain ⟨l, hkl, hf⟩ := (exists_toLit_fits_iff a k).2 ht
    exact ⟨l, ⟨k, hk, hkl⟩, hf⟩

/-- **Witness-level correspondence.**  An assignment assembles the encoded puzzle
iff it satisfies the formula. -/
theorem assembles_toPuzzle_iff (F : DimacsCNF) (a : Cube F.nvars) :
    Assembles (toPuzzle F) a ↔ F.Sat a := by
  unfold Assembles toPuzzle DimacsCNF.Sat
  constructor
  · intro h c hc
    exact (clausePiece_fits_iff a c).1 (h _ (List.mem_map_of_mem hc))
  · intro h c hc
    obtain ⟨c', hc', rfl⟩ := List.mem_map.1 hc
    exact (clausePiece_fits_iff a c').2 (h c' hc')

/-- **Parsimony of the SAT-to-puzzle encoding.** -/
theorem count_toPuzzle (F : DimacsCNF) : count (toPuzzle F) = satCount F := by
  unfold count assemblies satCount
  congr 1
  ext a
  simp [assembles_toPuzzle_iff]

theorem length_filterMap_le {α β : Type*} (f : α → Option β) (l : List α) :
    (l.filterMap f).length ≤ l.length := by
  induction l with
  | nil => simp
  | cons x l ih =>
      rw [List.filterMap_cons]
      split <;> simp <;> omega

theorem puzzleSize_toPuzzle_le (F : DimacsCNF) : puzzleSize (toPuzzle F) ≤ dimacsSize F := by
  unfold puzzleSize dimacsSize toPuzzle
  simp only [List.map_map, List.length_map, add_le_add_iff_right, add_le_add_iff_left]
  apply List.sum_le_sum
  intro c _
  exact length_filterMap_le _ _

/-- The parsimonious reduction `#SAT → #Jigsaw`. -/
def satToJigsaw : ParsimoniousReduction sharpSAT jigsawCount where
  map F := ⟨F.nvars, toPuzzle F⟩
  count_map F := count_toPuzzle F
  sizeMul := 1
  sizeAdd := 0
  size_map F := by simpa [jigsawCount, sharpSAT] using puzzleSize_toPuzzle_le F

/-- `#SAT → #Jigsaw` followed by complementation: still parsimonious. -/
def satToJigsawComp : ParsimoniousReduction sharpSAT jigsawCount :=
  compReduction.comp satToJigsaw

/-! ## The converse encoding `#Jigsaw → #SAT` -/

/-- Encode a literal input as a DIMACS literal. -/
def litToDimacs {n : ℕ} (l : Lit n) : ℤ := if l.2 = 1 then (l.1.1 + 1 : ℤ) else -(l.1.1 + 1 : ℤ)

/-- Encode a framed puzzle as a DIMACS formula. -/
def toDimacs {n : ℕ} (P : Puzzle n) : DimacsCNF := ⟨n, P.map (List.map litToDimacs)⟩

theorem dimacsLitTrue_litToDimacs {n : ℕ} (a : Cube n) (l : Lit n) :
    DimacsLitTrue a (litToDimacs l) ↔ Fits a l := by
  obtain ⟨i, p⟩ := l
  have hp : p = 0 ∨ p = 1 := by fin_cases p <;> simp
  unfold DimacsLitTrue Fits litToDimacs dimacsPol
  rcases hp with rfl | rfl
  · simp only [zero_ne_one, if_false]
    constructor
    · rintro ⟨j, hj, hja⟩
      have : j = i := Fin.ext (by omega)
      subst this
      simpa using hja
    · intro h
      refine ⟨i, by omega, ?_⟩
      simpa using h
  · simp only [if_true]
    constructor
    · rintro ⟨j, hj, hja⟩
      have : j = i := Fin.ext (by omega)
      rw [this] at hja
      have hpos : (0 : ℤ) < (i.1 : ℤ) + 1 := by omega
      simpa [hpos] using hja
    · intro h
      refine ⟨i, by omega, ?_⟩
      have hpos : (0 : ℤ) < (i.1 : ℤ) + 1 := by omega
      simpa [hpos] using h

theorem sat_toDimacs_iff {n : ℕ} (P : Puzzle n) (a : Cube n) :
    (toDimacs P).Sat a ↔ Assembles P a := by
  unfold DimacsCNF.Sat toDimacs Assembles
  simp only [List.mem_map, forall_exists_index, and_imp, forall_apply_eq_imp_iff₂,
    exists_exists_and_eq_and, dimacsLitTrue_litToDimacs]

/-- **Parsimony of the puzzle-to-SAT encoding.** -/
theorem satCount_toDimacs {n : ℕ} (P : Puzzle n) : satCount (toDimacs P) = count P := by
  unfold count assemblies satCount
  congr 1
  ext a
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact sat_toDimacs_iff P a

/-- The parsimonious reduction `#Jigsaw → #SAT`. -/
def jigsawToSat : ParsimoniousReduction jigsawCount sharpSAT where
  map x := toDimacs x.2
  count_map x := satCount_toDimacs x.2
  sizeMul := 1
  sizeAdd := 0
  size_map x := by
    simp [sharpSAT, jigsawCount, dimacsSize, puzzleSize, toDimacs, Function.comp_def]

/-- **Hardness transfer.**  Any counting problem parsimoniously reducible to `#SAT`
reduces parsimoniously to `#Jigsaw`; and the reduction can be post-composed with
complementation, so modular counts transfer through either `P` or its complement. -/
theorem reduction_to_jigsaw_of_reduction_to_sat {A : CountingProblem}
    (f : ParsimoniousReduction A sharpSAT) (k : ℕ) (x : A.Inst) :
    jigsawCount.count ((satToJigsaw.comp f).map x) ≡ A.count x [MOD k] ∧
      jigsawCount.count ((satToJigsawComp.comp f).map x) ≡ A.count x [MOD k] :=
  ⟨(satToJigsaw.comp f).count_modEq k x, (satToJigsawComp.comp f).count_modEq k x⟩

end JigsawParsimony