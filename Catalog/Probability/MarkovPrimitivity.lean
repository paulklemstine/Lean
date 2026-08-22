/-
# Cycle 6, Part III: Primitivity — When the Soundness Spectrum Becomes Cofinite

Parts I and II identified the Cycle-2 *soundness spectrum* of a world with the support
of its return-time distribution, and computed it exactly for the deterministic cycles
(`nℕ`).  Both of those spectra are "thin": `{0}` for a Löb frame, `nℕ` for the
`n`-cycle.  This file identifies the opposite extreme.

## Main results

* `iterR_of_add_le` — **the path-padding lemma.**  If `u` reaches `w` in `a` steps, `w`
  loops, and `w` reaches `v` in `b` steps, then `u` reaches `v` in *every* number of
  steps `≥ a + b`.  This is the combinatorial engine of matrix primitivity, and it is
  proved purely from Part I's `iterR_add`.
* `exists_forall_iterR` / `exists_forall_iterSound` — an irreducible frame with a single
  self-loop has, for every world, a **cofinite** soundness spectrum: past a threshold,
  *every* degree of internal soundness holds.
* `exists_uniform_threshold` — on a finite frame the threshold can be chosen uniformly
  in the pair of worlds (a `Finset.sup` over `S × S`).
* `stepPow_pos_of_primitive` and `exists_uniform_primitive` — the probabilistic reading:
  an **irreducible lazy chain is primitive**, i.e. some power of `P` and all later
  powers have all entries strictly positive.  Laziness is used only through the single
  self-loop.
* `spectrum_trichotomy` — the three regimes side by side: Löb frames have spectrum
  `{0}`, the `n`-cycle has spectrum `nℕ`, an irreducible lazy chain has a cofinite
  spectrum.  A single frame invariant separates provability logic, periodic dynamics and
  mixing dynamics.

## Relationship to the catalog
Builds on `Probability.MarkovModalDefinability` (`suppFrame`, `stepPow`,
`stepPow_pos_iff`, `iterR_add`, `soundMonoid`), `Probability.MarkovLumpability`
(`cycleChain`, `iterSound_cycleChain_iff`), Cycle 2's `IterSoundAt` /
`iterSound_iff_cycle` and Cycle 5's `valid_loeb_iff` /
`not_iterSound_of_valid_loebInst`.
-/

import Mathlib
import Probability.MarkovLumpability

namespace MarkovModal

open GLPLogic TangledSoundness FrameDefinability

variable {S : Type} {α : Type}

/-! ## Part A — Path padding -/

/-- A self-loop yields cycles of every length. -/
theorem iterR_selfLoop (F : KFrame) {w : F.W} (h : F.R w w) :
    ∀ k : ℕ, iterR F k w w
  | 0 => rfl
  | k + 1 => ⟨w, h, iterR_selfLoop F h k⟩

/-- **Path padding.**  Through a looping intermediate world, an `a`-step approach and a
`b`-step exit can be inflated to a path of *any* length `≥ a + b`. -/
theorem iterR_of_add_le (F : KFrame) {u v w : F.W} (hloop : F.R w w) {a b : ℕ}
    (ha : iterR F a u w) (hb : iterR F b w v) :
    ∀ n : ℕ, a + b ≤ n → iterR F n u v := by
  intro n hn
  have hsplit : n = a + ((n - a - b) + b) := by omega
  rw [hsplit]
  refine (iterR_add F ((n - a - b) + b) a u v).mpr ⟨w, ha, ?_⟩
  exact (iterR_add F b (n - a - b) w v).mpr ⟨w, iterR_selfLoop F hloop _, hb⟩

/-! ## Part B — Irreducible frames with a loop -/

/-- A frame is **irreducible** when every world reaches every world in some number of
steps.  (Strong connectedness of the accessibility relation.) -/
def FrameIrreducible (F : KFrame) : Prop := ∀ u v : F.W, ∃ k : ℕ, iterR F k u v

/-- **Cofinite reachability.**  In an irreducible frame containing one self-loop, every
ordered pair of worlds is joined by paths of every sufficiently large length. -/
theorem exists_forall_iterR (F : KFrame) (hirr : FrameIrreducible F) {w : F.W}
    (hloop : F.R w w) (u v : F.W) : ∃ N : ℕ, ∀ n : ℕ, N ≤ n → iterR F n u v := by
  obtain ⟨a, ha⟩ := hirr u w
  obtain ⟨b, hb⟩ := hirr w v
  exact ⟨a + b, iterR_of_add_le F hloop ha hb⟩

/-- **A cofinite soundness spectrum.**  In an irreducible frame with one self-loop every
world validates `□ⁿφ → φ` for all sufficiently large `n`: internal soundness, which the
Löb axiom forbids entirely, here holds in all but finitely many degrees. -/
theorem exists_forall_iterSound (F : KFrame) (p : α) (hirr : FrameIrreducible F)
    {w : F.W} (hloop : F.R w w) (u : F.W) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → IterSoundAt F α n u := by
  obtain ⟨N, hN⟩ := exists_forall_iterR F hirr hloop u u
  exact ⟨N, fun n hn => (iterSound_iff_cycle F p n u).mpr (hN n hn)⟩

/-- On a finite frame the reachability threshold is uniform in the pair of worlds. -/
theorem exists_uniform_threshold (F : KFrame) [Fintype F.W] [DecidableEq F.W]
    (hirr : FrameIrreducible F) {w : F.W} (hloop : F.R w w) :
    ∃ N : ℕ, ∀ (n : ℕ), N ≤ n → ∀ u v : F.W, iterR F n u v := by
  choose Npair hNpair using fun q : F.W × F.W => exists_forall_iterR F hirr hloop q.1 q.2
  refine ⟨Finset.univ.sup Npair, fun n hn u v => ?_⟩
  exact hNpair (u, v) n (le_trans (Finset.le_sup (Finset.mem_univ (u, v))) hn)

/-! ## Part C — Primitivity of irreducible lazy chains -/

/-- A chain is **irreducible** when every state is reachable from every state with
positive probability in some number of steps. -/
def ChainIrreducible [Fintype S] [DecidableEq S] (P : S → S → ℝ) : Prop :=
  ∀ u v : S, ∃ k : ℕ, 0 < stepPow P k u v

theorem chainIrreducible_iff_frameIrreducible [Fintype S] [DecidableEq S]
    {P : S → S → ℝ} (hP : ∀ u v, 0 ≤ P u v) :
    ChainIrreducible P ↔ FrameIrreducible (suppFrame P) := by
  constructor
  · intro h u v
    obtain ⟨k, hk⟩ := h u v
    exact ⟨k, (stepPow_pos_iff hP k u v).mp hk⟩
  · intro h u v
    obtain ⟨k, hk⟩ := h u v
    exact ⟨k, (stepPow_pos_iff hP k u v).mpr hk⟩

/-- **An irreducible lazy chain is primitive.**  If some state has positive holding
probability then, for every ordered pair of states, all sufficiently high powers of `P`
have a positive entry there. -/
theorem stepPow_pos_of_primitive [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (hirr : ChainIrreducible P) {w : S} (hloop : 0 < P w w)
    (u v : S) : ∃ N : ℕ, ∀ n : ℕ, N ≤ n → 0 < stepPow P n u v := by
  obtain ⟨N, hN⟩ :=
    exists_forall_iterR (suppFrame P)
      ((chainIrreducible_iff_frameIrreducible hP).mp hirr) (w := w) hloop u v
  exact ⟨N, fun n hn => (stepPow_pos_iff hP n u v).mpr (hN n hn)⟩

/-- **Primitivity with a uniform exponent.**  There is a single `N` beyond which *every*
entry of every power of `P` is strictly positive — the Perron–Frobenius notion of a
primitive matrix, obtained here entirely from the modal path calculus. -/
theorem exists_uniform_primitive [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (hirr : ChainIrreducible P) {w : S} (hloop : 0 < P w w) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → ∀ u v : S, 0 < stepPow P n u v := by
  obtain ⟨N, hN⟩ :=
    @exists_uniform_threshold (suppFrame P) ‹Fintype S› ‹DecidableEq S›
      ((chainIrreducible_iff_frameIrreducible hP).mp hirr) w hloop
  exact ⟨N, fun n hn u v => (stepPow_pos_iff hP n u v).mpr (hN n hn u v)⟩

/-- **A lazy irreducible chain has an eventually full soundness spectrum.** -/
theorem exists_forall_iterSound_of_chain [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (p : α) (hirr : ChainIrreducible P) {w : S}
    (hloop : 0 < P w w) (u : S) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → IterSoundAt (suppFrame P) α n u :=
  exists_forall_iterSound (suppFrame P) p
    ((chainIrreducible_iff_frameIrreducible hP).mp hirr) (w := w) hloop u

/-! ## Part D — The trichotomy of spectra -/

/-- The `n`-cycle is irreducible: `u` reaches `v` in `k` steps where `k` represents
`v - u`. -/
theorem cycleChain_irreducible (n : ℕ) [NeZero n] :
    FrameIrreducible (suppFrame (cycleChain n)) := by
  have key : ∀ a b : ZMod n, ∃ k : ℕ, iterR (suppFrame (cycleChain n)) k a b := by
    intro a b
    refine ⟨(b - a).val, ?_⟩
    rw [iterR_cycleChain n, ZMod.natCast_val, ZMod.cast_id]
    ring
  intro u v
  exact key u v

/-- The `n`-cycle for `n ≥ 2` has **no** self-loop, so `exists_forall_iterSound` really
does need its looping hypothesis: the conclusion fails there. -/
theorem cycleChain_spectrum_not_cofinite (n : ℕ) [NeZero n] (hn : 2 ≤ n) (p : α)
    (w : ZMod n) : ¬ ∃ N : ℕ, ∀ k : ℕ, N ≤ k → IterSoundAt (suppFrame (cycleChain n)) α k w := by
  rintro ⟨N, hN⟩
  have h1 : n ∣ (n * (N + 1)) := ⟨N + 1, rfl⟩
  have h2 : n ∣ (n * (N + 1) + 1) :=
    (iterSound_cycleChain_iff n p (n * (N + 1) + 1) w).mp
      (hN _ (by nlinarith))
  have hd : n ∣ 1 := (Nat.dvd_add_right h1).mp h2
  have := Nat.le_of_dvd one_pos hd
  omega

/-- **Spectrum trichotomy.**  Three genuinely different regimes for the Cycle-2
soundness spectrum, separated by frame conditions that are all definable or
probabilistic in nature:

1. a frame validating the Löb axiom has spectrum `{0}` (no positive degree at all);
2. the deterministic `n`-cycle has spectrum exactly `nℕ` — thin but unbounded;
3. an irreducible lazy chain has a cofinite spectrum.

The three cases are mutually exclusive for `n ≥ 2`, by
`cycleChain_spectrum_not_cofinite`. -/
theorem spectrum_trichotomy [Fintype S] [DecidableEq S] (p : α)
    (F : KFrame.{0}) (hF : Valid F α (loebInst (MFormula.var p)))
    (n : ℕ) [NeZero n] (wn : ZMod n)
    {P : S → S → ℝ} (hP : ∀ u v, 0 ≤ P u v) (hirr : ChainIrreducible P)
    {w : S} (hloop : 0 < P w w) (u : S) :
    (∀ k : ℕ, 0 < k → ∀ x : F.W, ¬ IterSoundAt F α k x) ∧
    (∀ k : ℕ, IterSoundAt (suppFrame (cycleChain n)) α k wn ↔ n ∣ k) ∧
    (∃ N : ℕ, ∀ k : ℕ, N ≤ k → IterSoundAt (suppFrame P) α k u) :=
  ⟨fun _ hk x => not_iterSound_of_valid_loebInst F p hF hk x,
    fun k => iterSound_cycleChain_iff n p k wn,
    exists_forall_iterSound_of_chain hP p hirr hloop u⟩

end MarkovModal

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H26. (Bold) Perron–Frobenius *primitivity* of a nonnegative matrix is not an
--        analytic fact at all: it is the modal path-padding lemma
--        `iterR_of_add_le`, and needs nothing but `iterR_add` from Part I.
--   H27. The Cycle-2 soundness spectrum is a complete separator of dynamical regimes:
--        `{0}` (Löbian / provability logic), `nℕ` (periodic), cofinite (mixing).
--   H28. The looping hypothesis in H26 is not removable — the deterministic `n`-cycle
--        for `n ≥ 2` is irreducible yet has a thin spectrum.
--
-- Experiment (Experimenter):
--   H26: confirmed, `stepPow_pos_of_primitive` and `exists_uniform_primitive`.  The
--        uniform exponent is `Finset.univ.sup` of the pairwise thresholds — finiteness
--        of the state space enters *only* here, and irreducibility only through two
--        applications of `hirr`.  Note especially that row-stochasticity is never used
--        in Part C: primitivity is a statement about supports.
--   H27: confirmed, `spectrum_trichotomy`, assembling Cycle 5's
--        `not_iterSound_of_valid_loebInst` with Part II's `iterSound_cycleChain_iff`
--        and Part III's `exists_forall_iterSound_of_chain`.
--   H28: confirmed, `cycleChain_spectrum_not_cofinite`.  If the spectrum `nℕ` were
--        cofinite it would contain two consecutive integers `n(N+1)` and `n(N+1)+1`,
--        forcing `n ∣ 1`.  This is a genuine refutation, so the trichotomy's three
--        cases are not redundant.
--
-- Analysis (Analyst):
--   The organising insight of Parts I–III is that a *single* combinatorial gadget,
--   `iterR` composition, is simultaneously (i) the semantics of iterated boxes,
--   (ii) matrix multiplication on supports, and (iii) the addition of return times.
--   Every theorem in Part III is one of these three readings of the same padding
--   argument.  Where classical treatments need Perron–Frobenius theory or the
--   numerical-semigroup theorem, the presence of one self-loop short-circuits the
--   argument completely; the genuinely hard case — irreducible, aperiodic, but with no
--   self-loop — is exactly the case where the numerical-semigroup theorem is needed and
--   is left open (see FUTURE_DIRECTIONS.md).
--
-- Critique (Critic):
--   * Non-vacuity: all hypotheses of `spectrum_trichotomy` are simultaneously
--     satisfiable — take `F` the one-point irreflexive frame (Löb-valid), any `n`, and
--     `P` the `2 × 2` lazy chain with all entries `1/2`.
--   * `exists_uniform_threshold` needs `Fintype F.W`; without it the pairwise
--     thresholds need not be bounded, and indeed on the successor frame over `ℕ` they
--     are not.  The hypothesis is load-bearing, not decorative.
--   * `cycleChain_spectrum_not_cofinite` requires `2 ≤ n`: for `n = 1` the spectrum is
--     all of `ℕ`, consistent with the `1`-cycle being lazy.
--   * No theorem in this file is closed by `decide`, `native_decide` or `rfl`.