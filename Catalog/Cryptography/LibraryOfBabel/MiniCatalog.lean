/-
# A de Bruijn Catalog for the Four-Symbol Mini-Library

A cyclic word of length sixteen over four symbols can list every two-symbol
volume exactly once: read the symbol at each position together with its cyclic
successor.  The construction below gives such a word explicitly and proves that
its sixteen cyclic windows form a bijective catalog of the mini-library
`Volume 4 2`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): a four-symbol cyclic volume of length `4^2 = 16` can
catalog all two-symbol volumes without collision, attaining the general counting
bound for windows of length two.

Experiment (Experimenter): the candidate cyclic word
`0010203112132233` produces the windows
`00, 01, 10, 02, 20, 03, 31, 11, 12, 21, 13, 32, 22, 23, 33, 30`.
They are precisely the sixteen ordered pairs over four symbols.

Analysis (Analyst): distinctness of the displayed windows, together with equality
of the finite cardinalities of positions and two-symbol volumes, upgrades the
window map to a bijection.  Thus existence and completeness are separated into
an explicit construction and a structural finite-cardinality argument.

Critique (Critic): this is a cyclic order-two catalog, not a catalog of the
`4^16` books of length sixteen.  Linearizing it requires repeating the initial
symbol, producing length seventeen.  No claim about efficient semantic search
or catalogs of arbitrary order follows from this finite construction.

Synthesis (Principal Investigator): the construction witnesses sharpness of the
capacity bound: all `4^2` reference codes occur once before any cyclic window
repeats.
-/
import Mathlib
import Cryptography.LibraryOfBabel.Basic

open Function

namespace LibraryOfBabel

/-- The explicit order-two de Bruijn word `0010203112132233`. -/
def miniCatalog : Fin 16 → Fin 4 := ![0, 0, 1, 0, 2, 0, 3, 1, 1, 2, 1, 3, 2, 2, 3, 3]

/-- Cyclic successor on the sixteen positions of the mini-catalog. -/
def miniNext (i : Fin 16) : Fin 16 := ⟨(i.val + 1) % 16, Nat.mod_lt _ (by omega)⟩

/-- The two-symbol volume named by the cyclic window beginning at `i`. -/
def miniCatalogPair (i : Fin 16) : Volume 4 2 :=
  fun j => if j = 0 then miniCatalog i else miniCatalog (miniNext i)

set_option maxHeartbeats 800000 in
/-- Distinct positions of the explicit mini-catalog name distinct two-symbol
volumes. -/
lemma miniCatalogPair_injective : Function.Injective miniCatalogPair := by
  intro i j h
  have h0 := congrFun h (0 : Fin 2)
  have h1 := congrFun h (1 : Fin 2)
  fin_cases i <;> fin_cases j <;>
    simp_all [miniCatalogPair, miniCatalog, miniNext, Fin.ext_iff]

/-- **Complete mini-library catalog.** The sixteen cyclic windows of
`0010203112132233` are in bijection with all sixteen books of length two over a
four-symbol alphabet. -/
theorem miniCatalogPair_bijective : Function.Bijective miniCatalogPair := by
  rw [Fintype.bijective_iff_injective_and_card]
  exact ⟨miniCatalogPair_injective, by simp [Volume]⟩

/-- Every two-symbol mini-volume occurs at a unique cyclic position in the
explicit catalog. -/
theorem miniCatalog_unique_location (v : Volume 4 2) :
    ∃! i : Fin 16, miniCatalogPair i = v := by
  rcases miniCatalogPair_bijective.2 v with ⟨i, hi⟩
  refine ⟨i, hi, ?_⟩
  intro j hj
  exact miniCatalogPair_bijective.1 (hj.trans hi.symm)

end LibraryOfBabel