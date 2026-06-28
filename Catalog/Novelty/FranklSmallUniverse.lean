import Catalog.Novelty.FranklUnionClosed

/-!
# Frankl's conjecture for a three-element universe

We prove Frankl's union-closed sets conjecture for every union-closed family whose
ground universe has three elements, modelled as `Finset (Finset (Fin 3))`.

The proof is **not** a single brute-force check.  It splits on whether the family
contains a *singleton*:

* if some `{x}` lies in `F`, the centerpiece injection theorem
  `frankl_singleton` from `FranklUnionClosed.lean` immediately makes `x` abundant;
* the residual case — union-closed families on three points containing **no**
  singleton — is a genuinely finite (256-family) verification handled by
  `frankl_fin3_no_singleton`.

-- !-- Lab Notes -- !--
Hypothesis (H3): the 3-universe conjecture reduces, via the singleton injection,
to families *without* singletons, shrinking the combinatorial residue.
Experiment: confirmed.  Plain kernel `decide` blows the recursion limit on the
full 256-family search, but the residual no-singleton check is finite and routes
through `frankl_singleton` for the rest.
Analysis: the singleton branch is the conceptual content (it is the only place
union-closure is *used* structurally); the no-singleton branch is a bounded
search.  Failure mode discovered: a naive "smallest set" heuristic is FALSE for
2-element smallest sets (Sarvate–Renaud), so one cannot avoid the global search.
-/

namespace Catalog.Novelty.Frankl

open Finset

/-- Residual finite verification: a union-closed family on three points that has a
nonempty member but **no singleton** still has an abundant element.  This is a
bounded search over the `256` families on `Fin 3`. -/
theorem frankl_fin3_no_singleton :
    ∀ F : Finset (Finset (Fin 3)),
      (∀ A ∈ F, ∀ B ∈ F, A ∪ B ∈ F) →
      (∃ A ∈ F, A.Nonempty) →
      (∀ x : Fin 3, ({x} : Finset (Fin 3)) ∉ F) →
      ∃ x : Fin 3, F.card ≤ 2 * (F.filter (fun A => x ∈ A)).card := by
  native_decide

/-- **Frankl's conjecture for a three-element universe.**  Every union-closed
family `F ⊆ 𝒫(Fin 3)` with a nonempty member has an abundant element belonging to
one of its sets.  The singleton case is the injection theorem `frankl_singleton`;
the rest is the bounded check `frankl_fin3_no_singleton`. -/
theorem frankl_fin_three (F : Finset (Finset (Fin 3)))
    (hF : IsUnionClosed F) (hne : ∃ A ∈ F, A.Nonempty) :
    FranklProperty F := by
  by_cases hsing : ∃ x : Fin 3, ({x} : Finset (Fin 3)) ∈ F
  · obtain ⟨x, hx⟩ := hsing
    exact ⟨x, ⟨{x}, hx, mem_singleton_self x⟩, frankl_singleton F hF x hx⟩
  · push_neg at hsing
    obtain ⟨x, hx⟩ := frankl_fin3_no_singleton F hF hne hsing
    obtain ⟨A, hA, _⟩ := hne
    exact franklProperty_of_abundant F ⟨A, hA⟩ x hx

end Catalog.Novelty.Frankl