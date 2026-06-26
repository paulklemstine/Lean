import Mathlib

/-!
# Italian squares and orthogonality

An *Italian square* on a finite symbol set `α` is an `α × α` array with entries in
`α` in which every row and every column is a bijection of `α` (equivalently, each
symbol occurs exactly once in each row and once in each column).  This is precisely
the classical notion of a *Latin square* of order `n = #α`.

Two Italian squares `L, M` are *orthogonal* when superimposing them realizes every
ordered pair of symbols exactly once, i.e. `(i, j) ↦ (L i j, M i j)` is a bijection
of `α × α`.

These definitions underlie the catalog references *Brualdi & Dahl 2018* and
*Van Lint & Wilson 1992* (A Course in Combinatorics, Ch. 22), where the central
result is that a family of mutually orthogonal Latin squares of order `n` has at
most `n - 1` members, with equality for prime powers.

-- !-- Lab Notes -- !--
Hypothesis (PI): the classical MOLS theory transfers verbatim to "Italian squares".
We model a square as a pair of bijectivity conditions (rows and columns) which is
the cleanest faithful encoding of "each symbol once per row/column".
-/

namespace ItalianSquares

/-- An Italian (Latin) square on symbol set `α`: an array `α → α → α` whose every
row and every column is a bijection. -/
structure ItalianSquare (α : Type*) where
  /-- The underlying array: `toFun i j` is the symbol in row `i`, column `j`. -/
  toFun : α → α → α
  /-- Every row is a bijection of the symbol set. -/
  row_bij : ∀ i, Function.Bijective (toFun i)
  /-- Every column is a bijection of the symbol set. -/
  col_bij : ∀ j, Function.Bijective (fun i => toFun i j)

/-- Two Italian squares are *orthogonal* when the superposition map
`(i, j) ↦ (L i j, M i j)` is a bijection of `α × α`; equivalently each ordered
pair of symbols arises from exactly one cell. -/
def Orthogonal {α : Type*} (L M : ItalianSquare α) : Prop :=
  Function.Bijective (fun p : α × α => (L.toFun p.1 p.2, M.toFun p.1 p.2))

end ItalianSquares