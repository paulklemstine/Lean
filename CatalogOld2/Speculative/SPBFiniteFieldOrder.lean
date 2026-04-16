/-! # CatalogBuild.Speculative.SPBFiniteFieldOrder

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 3
-/

import Mathlib

def spbMod (x y : ZMod p) : ZMod p := (x + y) / (1 - x * y)


def spbModIter (g : ZMod p) : ℕ → ZMod p
  | 0 => 0
  | n + 1 => spbMod g (spbModIter g n)


theorem spbModIter_one (g : ZMod p) : spbModIter g 1 = g := by
  simp [spbModIter, spbMod]

