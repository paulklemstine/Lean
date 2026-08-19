import Mathlib
import Combinatorics.ErdosGrahamEgyptian

/-!
# Erdős–Graham IV: finitisation by compactness

The Erdős–Graham statement quantifies over colourings of the *infinite* set of integers
`≥ 2`.  Here we prove that it is equivalent to a **finite** statement: there is a bound
`N = N(r)` such that already every `r`-colouring produces a monochromatic Egyptian set
with all denominators `≤ N`.

The proof of the non-trivial direction is a compactness (ultrafilter limit) argument:
from bad colourings `g_N` at every level `N` we build a limit colouring `c` whose value at
`n` is the `hyperfilter`-almost-sure value of `g_N n`; any monochromatic Egyptian set for
`c` is then monochromatic for some `g_N` with `N` larger than all its elements — a
contradiction.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the colouring problem is finitary; an "Erdős–Graham–Rado
number" `EG(r)` exists whenever the conjecture holds for `r` colours.

Experiment (Experimenter): formalised the equivalence `ErdosGrahamProperty r ↔
∃ N, ErdosGrahamFinite r N` via the hyperfilter on `ℕ`.  Only finitely many colours are
needed for the diagonalisation, which is exactly where `Fin r` finiteness enters
(`Ultrafilter.finite_biUnion_mem_iff`).

Analysis (Analyst): the proof shows the equivalence is *effective in structure but not in
size*: it produces no bound on `N(r)`.  Combined with the obstruction file, the finite
statement is the right target for computer search: for `r = 2` the truth of
`ErdosGrahamFinite 2 N` for some concrete `N` would settle the two-colour case.

Critique (Critic): the trivial direction is genuinely trivial, but the interesting one is
not: it needs a limit colouring, and the naive diagonal (choose `c = g_N` for large `N`)
fails because different finite sets need different `N`.  The hyperfilter handles this
uniformly.
-- !-- Lab Notes -- !--
-/

namespace ErdosGraham

open Finset Filter

/-- The finite form of the Erdős–Graham property: every `r`-colouring admits a
monochromatic Egyptian set whose denominators are all `≤ N`. -/
def ErdosGrahamFinite (r N : ℕ) : Prop :=
  ∀ c : ℕ → Fin r, ∃ (S : Finset ℕ) (i : Fin r),
    Egyptian S ∧ (∀ n ∈ S, n ≤ N) ∧ ∀ n ∈ S, c n = i

/-- The finite form is monotone in the bound `N`. -/
theorem erdosGrahamFinite_mono {r N M : ℕ} (hNM : N ≤ M) (h : ErdosGrahamFinite r N) :
    ErdosGrahamFinite r M := by
  intro c
  obtain ⟨S, i, hS, hle, hmono⟩ := h c
  exact ⟨S, i, hS, fun n hn => (hle n hn).trans hNM, hmono⟩

/-- The finite form implies the infinite (Erdős–Graham) form. -/
theorem erdosGrahamProperty_of_finite {r N : ℕ} (h : ErdosGrahamFinite r N) :
    ErdosGrahamProperty r := by
  intro c
  obtain ⟨S, i, hS, -, hmono⟩ := h c
  exact ⟨S, i, hS, hmono⟩

/-- Every point of the limit colouring is the `hyperfilter`-almost-sure value. -/
private lemma exists_hyperfilter_value {r : ℕ} (f : ℕ → Fin r) :
    ∃ i : Fin r, {N | f N = i} ∈ (Filter.hyperfilter ℕ) := by
  have huniv : (Set.univ : Set ℕ) ∈ (Filter.hyperfilter ℕ) := Filter.univ_mem
  have heq : (Set.univ : Set ℕ) = ⋃ i ∈ (Set.univ : Set (Fin r)), {N | f N = i} := by
    ext N; simp
  rw [heq, Ultrafilter.finite_biUnion_mem_iff Set.finite_univ] at huniv
  obtain ⟨i, -, hi⟩ := huniv
  exact ⟨i, hi⟩

/-- **Compactness / finitisation.**  The Erdős–Graham property for `r` colours is
equivalent to its finite version for some explicit bound `N`. -/
theorem erdosGraham_compactness (r : ℕ) :
    ErdosGrahamProperty r ↔ ∃ N : ℕ, ErdosGrahamFinite r N := by
  constructor
  · intro hEG
    by_contra hcon
    push_neg at hcon
    -- a bad colouring at every level
    have key : ∀ N : ℕ, ∃ g : ℕ → Fin r, ∀ S : Finset ℕ, Egyptian S →
        (∀ n ∈ S, n ≤ N) → ∀ i : Fin r, ∃ n ∈ S, g n ≠ i := by
      intro N
      have h := hcon N
      rw [ErdosGrahamFinite] at h
      push_neg at h
      obtain ⟨g, hg⟩ := h
      exact ⟨g, fun S hS hle i => hg S i hS hle⟩
    choose g hg using key
    -- the limit colouring
    choose c hc using fun n => exists_hyperfilter_value (fun N => g N n)
    obtain ⟨S, i, hS, hmono⟩ := hEG c
    -- almost every level agrees with the limit colouring on `S`
    have hagree : {N | ∀ n ∈ S, g N n = c n} ∈ (Filter.hyperfilter ℕ : Filter ℕ) := by
      have hb : (⋂ n ∈ (S : Set ℕ), {N | g N n = c n}) ∈ (Filter.hyperfilter ℕ : Filter ℕ) :=
        (Filter.biInter_mem S.finite_toSet).mpr fun n _ => hc n
      have hset : (⋂ n ∈ (S : Set ℕ), {N | g N n = c n}) = {N | ∀ n ∈ S, g N n = c n} := by
        ext N; simp
      rwa [hset] at hb
    have hbig : {N : ℕ | S.sup id ≤ N} ∈ (Filter.hyperfilter ℕ : Filter ℕ) := by
      refine Filter.hyperfilter_le_cofinite ?_
      rw [Filter.mem_cofinite]
      have : {N : ℕ | S.sup id ≤ N}ᶜ = Set.Iio (S.sup id) := by ext N; simp
      rw [this]
      exact Set.finite_Iio _
    obtain ⟨N, hN1, hN2⟩ :=
      Ultrafilter.nonempty_of_mem (Filter.inter_mem hagree hbig)
    have hmonoN : ∀ n ∈ S, g N n = i := fun n hn => (hN1 n hn).trans (hmono n hn)
    have hle : ∀ n ∈ S, n ≤ N := fun n hn =>
      le_trans (Finset.le_sup (f := id) hn) hN2
    obtain ⟨n, hn, hne⟩ := hg N S hS hle i
    exact hne (hmonoN n hn)
  · rintro ⟨N, hN⟩
    exact erdosGrahamProperty_of_finite hN

/-- The one-colour case admits the explicit finite bound `N = 6`, witnessed by
`1 = 1/2 + 1/3 + 1/6`. -/
theorem erdosGrahamFinite_one : ErdosGrahamFinite 1 6 := by
  intro c
  refine ⟨{2, 3, 6}, c 2, egyptian_two_three_six, ?_, ?_⟩
  · intro n hn; fin_cases hn <;> norm_num
  · intro n _; exact Subsingleton.elim _ _

end ErdosGraham