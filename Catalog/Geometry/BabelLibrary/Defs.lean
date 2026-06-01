/-
# The Library of Babel: Combinatorial Topology

We formalize Borges' Library of Babel as a mathematical object:
the space of all possible books over a finite alphabet.

We prove fundamental properties:
- Exact cardinality computation
- Hamming distance forms a metric
- Incompressibility of almost all books (counting argument)
- Structural theorems about the combinatorial geometry
-/

import Mathlib

open Finset Function

/-! ## Core Definitions -/

/-- The Babel alphabet size (25 symbols: 22 letters + period + comma + space) -/
abbrev babelAlpha : ℕ := 25

/-- Characters per book in the Library of Babel (410 pages × 40 lines × 80 chars) -/
abbrev babelLength : ℕ := 1312000

/-- A book in a generalized Library of Babel: a sequence of `N` symbols from alphabet `Fin α`.
    We work with general `α` and `N` for mathematical generality. -/
abbrev BabelBook (α N : ℕ) := Fin N → Fin α

/-- The Hamming distance between two books: the number of positions where they differ. -/
noncomputable def babelHammingDist {α N : ℕ} (b₁ b₂ : BabelBook α N) : ℕ :=
  Finset.card (Finset.univ.filter fun i => b₁ i ≠ b₂ i)

/-- A compression scheme: a pair of functions (compress, decompress) mapping books to
    shorter representations. We model compression as mapping to a smaller type. -/
structure CompressionScheme (α N M : ℕ) where
  compress : BabelBook α N → BabelBook α M
  decompress : BabelBook α M → BabelBook α N
  faithful : ∀ b, decompress (compress b) = b

/-- The set of books compressible by a given scheme is exactly the range of decompress. -/
def compressibleBooks {α N M : ℕ} (s : CompressionScheme α N M) : Set (BabelBook α N) :=
  Set.range s.decompress

/-- A Hamming ball of radius r centered at book b. -/
def babelHammingBall {α N : ℕ} (b : BabelBook α N) (r : ℕ) : Set (BabelBook α N) :=
  { b' | babelHammingDist b b' ≤ r }

/-- Two books are `k`-neighbors if they differ in exactly `k` positions. -/
def babelKNeighbors {α N : ℕ} (b₁ b₂ : BabelBook α N) (k : ℕ) : Prop :=
  babelHammingDist b₁ b₂ = k

/-- The spectrum of a book: the multiset of symbol frequencies. -/
noncomputable def symbolSpectrum {α N : ℕ} (b : BabelBook α N) : Fin α → ℕ :=
  fun c => Finset.card (Finset.univ.filter fun i => b i = c)

/-- A book is "uniform" if all symbols appear with equal frequency. -/
def isUniform {α N : ℕ} (b : BabelBook α N) : Prop :=
  ∀ c₁ c₂ : Fin α, symbolSpectrum b c₁ = symbolSpectrum b c₂