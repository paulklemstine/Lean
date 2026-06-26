/-
# Extremal Graph Theory II: Roth's theorem on 3-term arithmetic progressions

Roth's theorem (the `k = 3` case of Szemerédi's theorem) is the additive-combinatorics
culmination of the triangle removal lemma.  Mathlib proves the asymptotic statement
`rothNumberNat_isLittleO_id : rothNumberNat = o(N)` via the corners theorem (which in turn uses
Szemerédi regularity + triangle removal).  Here we extract two genuinely usable consequences:

* `rothNumberNat_density_tendsto_zero` — the maximal density of a 3AP-free subset of `{0,…,N-1}`
  tends to `0`;
* `exists_threeAP_of_freq_dense` — **any** set of naturals whose finite-window density stays
  bounded below by a positive constant infinitely often must contain a genuine 3-term arithmetic
  progression `a, b, c` with `a + c = 2b` and `a ≠ b`.

The second statement is the qualitative form of Roth's theorem usually quoted ("sets of positive
upper density contain 3-APs") and is the real payoff of the `o(N)` bound.
-/
import Mathlib

open Asymptotics Filter Topology Finset
open scoped Classical

namespace ExtremalRoth

/-- **Roth's theorem, density form.** The maximal size of a 3AP-free subset of `{0, …, N-1}`,
divided by `N`, tends to `0`.  Immediate from `rothNumberNat = o(N)`. -/
theorem rothNumberNat_density_tendsto_zero :
    Tendsto (fun N => (rothNumberNat N : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
  rothNumberNat_isLittleO_id.tendsto_div_nhds_zero

/-- **Roth's theorem, qualitative form.** If a set `A ⊆ ℕ` has positive *frequent* density — there
is `c > 0` such that infinitely often `c·N ≤ #(A ∩ {0,…,N-1})` — then `A` is **not** 3AP-free, i.e.
it contains a nontrivial 3-term arithmetic progression.

The proof combines Roth's `o(N)` bound with the extremal characterisation of `rothNumberNat`: a
3AP-free window of `A` has size at most `rothNumberNat N ≤ (c/2)·N` for large `N`, contradicting
the frequent lower bound `c·N`. -/
theorem exists_threeAP_of_freq_dense (A : Set ℕ) (c : ℝ) (hc : 0 < c)
    (hfreq : ∃ᶠ N in atTop, (c : ℝ) * N ≤ #{n ∈ Finset.range N | n ∈ A}) :
    ¬ ThreeAPFree A := by
  intro hA
  -- Roth's o(N): for large N, rothNumberNat N ≤ (c/2)·N.
  have hev : ∀ᶠ N : ℕ in atTop, (rothNumberNat N : ℝ) ≤ (c / 2) * (N : ℝ) := by
    have hlo := rothNumberNat_isLittleO_id
    rw [isLittleO_iff] at hlo
    have h2 := hlo (show (0:ℝ) < c/2 by linarith)
    filter_upwards [h2] with N hN
    simpa using hN
  have hev1 : ∀ᶠ N : ℕ in atTop, (1 : ℝ) ≤ (N : ℝ) := by
    filter_upwards [eventually_ge_atTop 1] with N hN; exact_mod_cast hN
  -- Pick N where the dense lower bound and Roth's upper bound both hold.
  obtain ⟨N, hfN, hrN, hN1⟩ := (hfreq.and_eventually (hev.and hev1)).exists
  set B : Finset ℕ := {n ∈ Finset.range N | n ∈ A} with hB
  have hBsub : (B : Set ℕ) ⊆ A := by
    intro x hx; simp only [hB, coe_filter, mem_range, Set.mem_setOf_eq] at hx; exact hx.2
  have hBfree : ThreeAPFree (B : Set ℕ) := hA.mono hBsub
  have hBlt : ∀ x ∈ B, x < N := by
    intro x hx; simp only [hB, mem_filter, mem_range] at hx; exact hx.1
  have hle : (#B : ℕ) ≤ rothNumberNat N := hBfree.le_rothNumberNat B hBlt rfl
  have hleR : (#B : ℝ) ≤ (rothNumberNat N : ℝ) := by exact_mod_cast hle
  -- c·N ≤ #B ≤ rothNumberNat N ≤ (c/2)·N  forces a contradiction for N ≥ 1.
  have hchain : (c : ℝ) * N ≤ (c / 2) * N := le_trans hfN (le_trans hleR hrN)
  nlinarith [hchain, hc, hN1]

end ExtremalRoth

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  H1: Roth's `o(N)` bound (`rothNumberNat_isLittleO_id`) implies the density of the largest 3AP-free
      window of {0,…,N-1} tends to 0.
  H2 (bold): The same bound implies the *qualitative* Roth theorem — any A ⊆ ℕ whose finite-window
      density is frequently ≥ c > 0 contains a nontrivial 3-AP.  This is the form actually used in
      density-increment arguments and Szemerédi's theorem.

EXPERIMENT (Experimenter).
  * H1: `IsLittleO.tendsto_div_nhds_zero` applied to `rothNumberNat_isLittleO_id` closes it directly.
  * H2: unfold `isLittleO_iff` at ε = c/2 to get an *eventual* upper bound on rothNumberNat; combine
      (`Frequently.and_eventually`) with the *frequent* lower bound to land on a single N where
      `c·N ≤ #(window) ≤ rothNumberNat N ≤ (c/2)·N`.  `nlinarith` extracts the contradiction.
      Key technical move: `ThreeAPFree.mono` shows the window is 3AP-free, then
      `ThreeAPFree.le_rothNumberNat` bounds its size.

ANALYSIS (Analyst).
  * SURVIVED: H1, H2 (0 sorries).
  * KEY INSIGHT: "frequently dense ∧ eventually sparse" is contradictory — the
    `Frequently.and_eventually` combinator is exactly the bridge from an asymptotic `o(N)` bound to a
    concrete finite witness.
  * FAILURE NOTE: a first attempt used ε = c (non-strict) which only gives `c·N ≤ (c/2)·N` boundary
    equality at N=0; switching to ε = c/2 and requiring N ≥ 1 makes the contradiction strict.

CRITIQUE (Critic).
  * `exists_threeAP_of_freq_dense` is not vacuous: the hypothesis is satisfiable (e.g. A = ℕ has
    c = 1), and the conclusion `¬ ThreeAPFree A` genuinely produces a 3-AP via the definition of
    `ThreeAPFree`.
  * `rothNumberNat_density_tendsto_zero` is a short term proof but is a real corollary of a deep
    theorem, included as a stepping stone, not as the main result.
  * The frequent-density hypothesis is weaker than positive upper density, so the theorem is stated at
    its natural level of generality.

SYNTHESIS (Principal Investigator).
  Roth's theorem is now available both as a density limit and in the qualitative "positive density ⇒
  3-AP" form, completing the additive-combinatorics arm of the extremal-graph-theory programme.
-/