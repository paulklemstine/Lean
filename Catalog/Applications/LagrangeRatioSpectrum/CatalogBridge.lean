import Catalog.Applications.LagrangeRatioSpectrum.DilationBound
import Catalog.NumberTheory.Irrationality

/-!
# Bridge: badly approximable numbers are irrational

This file connects the Lagrange-constant framework of this project to the
catalog file `Catalog/NumberTheory/Irrationality.lean`, whose
`EulerMascheroni.irrational_of_forall_eps_linear_form` says that a real number
admitting arbitrarily small *nonzero* integer linear forms `|q·x − p|` is
irrational.

We prove that every badly approximable real (`x ∈ Bad`, i.e. `Lc x > 0`) is
irrational, by manufacturing those small nonzero forms.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  If `Lc x > 0` then `q·x` is *never* an integer for
`q ≥ 1`: otherwise `approx x` would vanish along the whole multiples-of-`q`
subsequence, forcing `Lc x = 0` via `Lc_le_liminf_subseq`.  Combined with
Dirichlet's theorem (`Real.exists_nat_abs_mul_sub_round_le`, the same engine
used by the catalog file) this yields arbitrarily small *nonzero* linear forms,
so the catalog's sufficient criterion gives irrationality.

EXPERIMENT (Experimenter).  Proven below:
* `ndist_pos_of_bad` — `‖q·x‖ > 0` for `x ∈ Bad`, `q ≥ 1` (contradiction via the
  subsequence bound from `DilationBound`).
* `bad_small_forms` — the small-nonzero-form property, from Dirichlet plus the
  previous lemma.
* `irrational_of_bad` — apply the catalog theorem.

ANALYSIS (Analyst).  This is a genuine cross-file result: it *uses* a catalog
theorem (`EulerMascheroni.irrational_of_forall_eps_linear_form`) rather than
re-proving it.  The non-vanishing lemma `ndist_pos_of_bad` is the crux and is
the place where the `liminf` definition of `Lc` does real work.

CRITIQUE (Critic).  The inclusion `Bad ⊆ Irrational` is proper and the proof is
not vacuous (it really constructs the witnesses).  Boundary case `q = 0` is
excluded by `1 ≤ q`, matching the catalog statement's `1 ≤ q`.
-/

open Filter Topology

namespace LagrangeSpectrum

/-- For a badly approximable `x`, `q·x` is never an integer (`q ≥ 1`):
equivalently `‖q·x‖ > 0`. -/
theorem ndist_pos_of_bad (x : ℝ) (hx : x ∈ Bad) (q : ℕ) (hq : 1 ≤ q) :
    0 < ndist ((q : ℝ) * x) := by
  rcases lt_or_eq_of_le (ndist_nonneg ((q : ℝ) * x)) with h | h
  · exact h
  · exfalso
    obtain ⟨m, hm⟩ := (ndist_eq_zero_iff_int _).1 h.symm
    have hall : ∀ k : ℕ, approx x (q * k) = 0 := by
      intro k
      unfold approx
      have hxe : ((q * k : ℕ) : ℝ) * x = ((k * m : ℤ) : ℝ) := by
        rw [show ((q * k : ℕ) : ℝ) * x = (k : ℝ) * ((q : ℝ) * x) by push_cast; ring, hm]
        push_cast; ring
      rw [hxe, (ndist_eq_zero_iff_int _).2 ⟨k * m, rfl⟩]; simp
    have hle := Lc_le_liminf_subseq x q hq
    have hlim : Filter.liminf (fun k => approx x (q * k)) atTop = 0 := by
      simp only [hall]; simp
    rw [hlim] at hle
    exact absurd (le_antisymm hle (zero_le _)) (ne_of_gt hx)

/-- A badly approximable real admits arbitrarily small *nonzero* integer linear
forms — exactly the hypothesis of the catalog's irrationality criterion. -/
theorem bad_small_forms (x : ℝ) (hx : x ∈ Bad) :
    ∀ ε : ℝ, 0 < ε → ∃ (q : ℕ) (p : ℤ),
      1 ≤ q ∧ 0 < |(q : ℝ) * x - (p : ℝ)| ∧ |(q : ℝ) * x - (p : ℝ)| < ε := by
  intro ε hε
  obtain ⟨n, hn0, hn⟩ : ∃ n : ℕ, 0 < n ∧ 1 / (n + 1 : ℝ) < ε :=
    ⟨⌊ε⁻¹⌋₊ + 1, Nat.succ_pos _, by
      simpa using inv_lt_of_inv_lt₀ hε <| by linarith [Nat.lt_floor_add_one ε⁻¹]⟩
  obtain ⟨k, hk0, _, hk⟩ := Real.exists_nat_abs_mul_sub_round_le x hn0
  refine ⟨k, round ((k : ℝ) * x), hk0, ?_, ?_⟩
  · have hpos := ndist_pos_of_bad x hx k hk0
    unfold ndist at hpos
    exact hpos
  · calc |(k : ℝ) * x - (round ((k : ℝ) * x) : ℤ)| ≤ 1 / (n + 1 : ℝ) := hk
      _ < ε := hn

/-- **Bridge theorem.**  Every badly approximable real number is irrational.
Uses `EulerMascheroni.irrational_of_forall_eps_linear_form` from the catalog
file `Catalog/NumberTheory/Irrationality.lean`. -/
theorem irrational_of_bad (x : ℝ) (hx : x ∈ Bad) : Irrational x :=
  EulerMascheroni.irrational_of_forall_eps_linear_form x (bad_small_forms x hx)

/-- Consequently `Bad ⊆ {irrationals}`. -/
theorem bad_subset_irrational : Bad ⊆ {x : ℝ | Irrational x} :=
  fun _ hx => irrational_of_bad _ hx

end LagrangeSpectrum