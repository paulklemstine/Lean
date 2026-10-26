module

public import Catalog.Algebra.JigsawParsimony.Encoding
public import Catalog.Algebra.JigsawParsimony.MaskSymmetry
public import Catalog.Algebra.JigsawParsimony.Reductions
public import Catalog.Algebra.JigsawParsimony.ParityFormula

/-!
# Enumerated small instances

Exhaustive kernel-checked experiments on the family `puzzlesN n` of all framed
puzzles with exactly two clause pieces whose inputs form a sublist of the `2n`
possible literal inputs (`256` puzzles for `n = 2`, `4096` for `n = 3`).

These finite checks *support* the general theorems of the sibling files; none of
the general theorems depends on them.
-/

@[expose] public section

namespace JigsawParsimony

/-- All `2n` literal inputs on `n` sockets. -/
def litsN (n : ℕ) : List (Lit n) := (List.finRange n).flatMap fun i => [(i, 0), (i, 1)]

/-- All two-clause puzzles whose clause pieces are sublists of `litsN n`. -/
def puzzlesN (n : ℕ) : List (Puzzle n) :=
  let cs := (litsN n).sublists
  cs.flatMap fun c => cs.map fun d => [c, d]

theorem length_puzzlesN_two : (puzzlesN 2).length = 256 := by decide +kernel

/-- Exhaustive check (n = 2): complementation preserves the exact count. -/
theorem puzzlesN_two_comp_count :
    (puzzlesN 2).all (fun P => count (compPuzzle P) == count P) = true := by decide +kernel

/-- Exhaustive check (n = 3, 4096 puzzles): complementation preserves the count. -/
theorem puzzlesN_three_comp_count :
    (puzzlesN 3).all (fun P => count (compPuzzle P) == count P) = true := by decide +kernel

/-- Mod-2 invariance on the enumerated family, derived from the general theorem
(no enumeration needed). -/
theorem puzzlesN_comp_parity (n : ℕ) :
    ∀ P ∈ puzzlesN n, count (compPuzzle P) % 2 = count P % 2 := by
  intro P _
  exact count_compPuzzle_modEq 2 P

/-- Count histogram for `n = 2`: `35, 24, 88, 60, 49` puzzles have count
`0, 1, 2, 3, 4`; in particular `84` have odd count. -/
theorem puzzlesN_two_histogram :
    ((puzzlesN 2).map count).count 0 = 35 ∧ ((puzzlesN 2).map count).count 1 = 24 ∧
      ((puzzlesN 2).map count).count 2 = 88 ∧ ((puzzlesN 2).map count).count 3 = 60 ∧
      ((puzzlesN 2).map count).count 4 = 49 := by
  decide +kernel

/-- Exactly `88` of the `256` puzzles are self-dual in the assembly-space sense,
and all of them have even count — as `even_count_of_selfDual` predicts. -/
theorem puzzlesN_two_selfDual :
    ((puzzlesN 2).filter fun P => assemblies (compPuzzle P) == assemblies P).length = 88 ∧
      ((puzzlesN 2).filter fun P => assemblies (compPuzzle P) == assemblies P).all
        (fun P => count P % 2 == 0) = true := by
  decide +kernel

/-! ## A tight 2-adic example -/

/-- `(x₀ ∨ x₁) ∧ (¬x₀ ∨ ¬x₁)` on three sockets: `x₀ ≠ x₁`, `x₂` free. -/
def xorPuzzle : Puzzle 3 := [[(0, 1), (1, 1)], [(0, 0), (1, 0)]]

theorem count_xorPuzzle : count xorPuzzle = 4 := by decide +kernel

/-- The masks `(1,1,0)` and `(0,0,1)` are mask symmetries of `xorPuzzle`. -/
theorem xorPuzzle_masks :
    (![1, 1, 0] : Cube 3) ∈ maskSymm xorPuzzle ∧ (![0, 0, 1] : Cube 3) ∈ maskSymm xorPuzzle := by
  simp only [mem_maskSymm]
  constructor <;> decide +kernel

/-- `xorPuzzle` is self-dual (the all-ones mask is the sum of the two masks above),
so its count is even by the general theorem. -/
theorem xorPuzzle_selfDual : assemblies (compPuzzle xorPuzzle) = assemblies xorPuzzle := by
  decide +kernel

example : Even (count xorPuzzle) := even_count_of_selfDual (by norm_num) _ xorPuzzle_selfDual

/-- The labelled (physical) count of `xorPuzzle`: `4 · 4! · 3! · 3! = 3456`. -/
theorem card_labeled_xorPuzzle : Fintype.card (LabeledAssembly xorPuzzle) = 3456 := by
  rw [card_labeledAssembly, count_xorPuzzle]
  simp [xorPuzzle, Nat.factorial]

/-- The mod-2 inclusion–exclusion terms of `xorPuzzle`: `8 + 2 + 2 + 0 = 12`, which
is `≡ 4 = count xorPuzzle (mod 2)`. -/
theorem xorPuzzle_falsifierSum :
    ∑ S ∈ (Finset.univ : Finset (Fin xorPuzzle.length)).powerset, falsifierCount xorPuzzle S
      = 12 := by
  decide +kernel

example : count xorPuzzle ≡ 12 [MOD 2] :=
  xorPuzzle_falsifierSum ▸ count_modEq_falsifierSum xorPuzzle

/-! ## The DIMACS bridge on a concrete instance -/

/-- `(x₁ ∨ ¬x₂) ∧ (x₂ ∨ x₉)` on two declared variables (`x₉` is undeclared). -/
def demoCNF : DimacsCNF := ⟨2, [[1, -2], [2, 9]]⟩

theorem satCount_demoCNF : satCount demoCNF = 1 := by
  rw [← count_toPuzzle]; decide +kernel

end JigsawParsimony