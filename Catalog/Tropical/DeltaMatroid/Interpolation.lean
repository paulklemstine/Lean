import Tropical.DeltaMatroid.Twist

/-!
# Interpolation of partial-twuality polynomials

For a ground set `E` and a feasible set `F ⊆ E`, the **partial-twuality polynomial**
records, for each `k`, the number of twists `A ⊆ E` for which the twisted feasible set
`F ∆ A` has size `k`:

  `ptCoeff E F k = #{A ⊆ E | (F ∆ A).card = k}`.

The Gross–Mansour–Tucker *interpolating conjecture* asks when such a polynomial is
**interpolating**, i.e. its nonzero coefficients occupy a contiguous range with no
internal gaps.  Yan–Jin produced counterexamples for general ribbon graphs but
established interpolation in structured cases.

Main results:
* `twuality_spectrum`: the set of attained sizes `{(F ∆ A).card : A ⊆ E}` is exactly
  `{0, 1, …, |E|}` — every value is hit, with no gaps.
* `ptCoeff_pos_iff` / `ptCoeff_interpolating`: consequently the partial-twuality
  polynomial of a single feasible set is **always interpolating**, with support the
  full interval `[0, |E|]`.
* `ptCoeff_twist_invariant`: the polynomial is a **twist invariant** — twisting the
  base feasible set permutes the twists and leaves every coefficient unchanged, so the
  polynomial is genuinely an invariant of the whole twist orbit.
* `ptCoeff_support_nontrivial`: whenever `E` is nonempty the support contains at least
  two distinct degrees, so the result is not vacuous / monomial.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The single-feasible-set partial-twuality polynomial is
  *always* interpolating, refuting the idea that gaps are intrinsic; gaps in ribbon-graph
  examples (Yan–Jin) must come from the interaction of *several* feasible sets, not the
  twist mechanism itself.
Experiment (Experimenter): Reduced interpolation to the bijection `A ↦ F ∆ A` of the
  powerset of `E`, under which sizes range over `{|B| : B ⊆ E} = {0,…,|E|}`.  Formalised
  the spectrum equality, the support characterisation, and the twist invariance via an
  explicit involutive bijection `A ↦ B ∆ A` of the index `Finset`.
Analysis (Analyst): "True but easy at one feasible set; the difficulty in Yan–Jin lives
  entirely in the *combination* across feasible sets."  The twist invariance shows the
  polynomial only sees the twist orbit, matching the GMT framing.
Critique (Critic): Checked non-vacuity (`ptCoeff_support_nontrivial`): for `E ≠ ∅` the
  support has the two distinct degrees `0` and `|E|`, so the polynomial is a genuine
  interpolation, never a monomial.  No `native_decide`; proofs use `omega`, a card
  bijection, and the spectrum lemma.
Synthesis (PI): Interpolation is structural at the atomic level; the open frontier is the
  multi-feasible-set width polynomial (see `FUTURE_DIRECTIONS.md`).
-/

open Finset
open scoped symmDiff

namespace DeltaMatroid

variable {α : Type*} [DecidableEq α]

/-- A twist stays inside the ground set `E`. -/
theorem symmDiff_subset_of_subset {E F A : Finset α} (hF : F ⊆ E) (hA : A ⊆ E) :
    F ∆ A ⊆ E := by
  intro x hx
  rw [Finset.mem_symmDiff] at hx
  rcases hx with ⟨h1, _⟩ | ⟨h1, _⟩
  · exact hF h1
  · exact hA h1

/-- **Spectrum of a partial twuality.**  As `A` ranges over all subsets of `E`, the size
`(F ∆ A).card` attains exactly the values `{0, 1, …, |E|}` with no gaps. -/
theorem twuality_spectrum {E F : Finset α} (hF : F ⊆ E) :
    E.powerset.image (fun A => (F ∆ A).card) = Finset.range (E.card + 1) := by
  ext k
  simp only [mem_image, mem_powerset, mem_range, Nat.lt_succ_iff]
  constructor
  · rintro ⟨A, hA, rfl⟩
    exact card_le_card (symmDiff_subset_of_subset hF hA)
  · intro hk
    obtain ⟨B, hB, hc⟩ := le_card_iff_exists_subset_card.mp hk
    exact ⟨F ∆ B, symmDiff_subset_of_subset hF hB,
      by rw [← symmDiff_assoc, symmDiff_self, bot_symmDiff]; exact hc⟩

/-- The partial-twuality polynomial coefficient: the number of twists `A ⊆ E` producing a
feasible set of size `k`. -/
def ptCoeff (E F : Finset α) (k : ℕ) : ℕ :=
  (E.powerset.filter (fun A => (F ∆ A).card = k)).card

/-- A coefficient sequence is *interpolating* on `[lo, hi]` when its support is exactly
that interval (no internal gaps). -/
def Interpolating (lo hi : ℕ) (c : ℕ → ℕ) : Prop :=
  ∀ k, 0 < c k ↔ lo ≤ k ∧ k ≤ hi

/-- A coefficient is nonzero iff its degree lies in the attainable range `[0, |E|]`. -/
theorem ptCoeff_pos_iff {E F : Finset α} (hF : F ⊆ E) (k : ℕ) :
    0 < ptCoeff E F k ↔ k ≤ E.card := by
  unfold ptCoeff
  rw [Finset.card_pos, Finset.filter_nonempty_iff]
  constructor
  · rintro ⟨A, hA, hc⟩
    rw [mem_powerset] at hA
    rw [← hc]
    exact card_le_card (symmDiff_subset_of_subset hF hA)
  · intro hk
    have hmem : k ∈ E.powerset.image (fun A => (F ∆ A).card) := by
      rw [twuality_spectrum hF, mem_range]; omega
    rw [mem_image] at hmem
    obtain ⟨A, hA, hc⟩ := hmem
    exact ⟨A, hA, hc⟩

/-- **Interpolation theorem.**  The partial-twuality polynomial of a single feasible set
is interpolating, with support the full interval `[0, |E|]`. -/
theorem ptCoeff_interpolating {E F : Finset α} (hF : F ⊆ E) :
    Interpolating 0 E.card (ptCoeff E F) := by
  intro k
  rw [ptCoeff_pos_iff hF]
  omega

/-- **Twist invariance.**  Twisting the base feasible set by `B ⊆ E` leaves every
coefficient of the partial-twuality polynomial unchanged: the polynomial is an invariant
of the twist orbit. -/
theorem ptCoeff_twist_invariant {E F B : Finset α} (hB : B ⊆ E) (k : ℕ) :
    ptCoeff E (F ∆ B) k = ptCoeff E F k := by
  unfold ptCoeff
  apply Finset.card_nbij' (fun A => B ∆ A) (fun A => B ∆ A)
  · intro A hA
    simp only [mem_coe, mem_filter, mem_powerset] at hA ⊢
    refine ⟨symmDiff_subset_of_subset hB hA.1, ?_⟩
    have h : (F ∆ B) ∆ A = F ∆ (B ∆ A) := by rw [symmDiff_assoc]
    rw [← h]; exact hA.2
  · intro A hA
    simp only [mem_coe, mem_filter, mem_powerset] at hA ⊢
    refine ⟨symmDiff_subset_of_subset hB hA.1, ?_⟩
    have h : (F ∆ B) ∆ (B ∆ A) = F ∆ A := by
      rw [symmDiff_assoc, ← symmDiff_assoc B B A, symmDiff_self, bot_symmDiff]
    rw [h]; exact hA.2
  · intro A _; simp only []; rw [← symmDiff_assoc, symmDiff_self, bot_symmDiff]
  · intro A _; simp only []; rw [← symmDiff_assoc, symmDiff_self, bot_symmDiff]

/-- Non-vacuity of interpolation: for nonempty `E` the support contains the two distinct
degrees `0` and `|E|`, so the partial-twuality polynomial is never a monomial. -/
theorem ptCoeff_support_nontrivial {E F : Finset α} (hF : F ⊆ E) (hne : E.Nonempty) :
    0 < ptCoeff E F 0 ∧ 0 < ptCoeff E F E.card ∧ (0 : ℕ) ≠ E.card := by
  refine ⟨?_, ?_, ?_⟩
  · rw [ptCoeff_pos_iff hF]; omega
  · rw [ptCoeff_pos_iff hF]
  · have := Finset.card_pos.mpr hne; omega

end DeltaMatroid