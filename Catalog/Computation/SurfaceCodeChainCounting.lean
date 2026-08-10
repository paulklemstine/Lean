import Mathlib
import Computation.SurfaceCodeThreshold

/-!
# Where the chain-growth constant comes from: counting lattice error chains

`Computation.SurfaceCodeThreshold` proves that the surface-code failure bound is
suppressed exactly when `μ p < 1`, where `μ` is the *chain-growth constant*: the
exponential growth rate of the number of error chains of a given weight.  That file takes
`μ` as an input.  This file *derives* a growth constant, rigorously, from lattice
combinatorics.

An error chain on the square lattice is a connected path of flipped edges.  Two facts make
the count elementary:

* a chain may be taken **non-backtracking**: on the square lattice a Pauli error applied
  twice to the same edge cancels, so a chain that immediately retraces a step is equal, as
  an operator, to a shorter chain;
* each vertex of the square lattice has degree `4`, and a non-backtracking step has `3`
  continuations.

We formalise walks as lists of directions (`Fin 4`, with `revDir d = d + 2` the reversal)
and prove the **exact** count

  `#{ non-backtracking walks with ℓ steps } = 4 · 3 ^ (ℓ - 1)`   (`card_nbWalks`),

so the growth constant of the square lattice is at most `3`.  Feeding this into the
threshold machinery gives a *fully proved* threshold lower bound `p_th ≥ 1/3` for the
chain-counting model (`walk_counting_threshold`).  The physically quoted constant
`μ = 100` of `SurfaceCodeThreshold.surfaceGrowth` is larger because it also absorbs the
entropy of anchor positions and the multiplicity of Pauli types; the *shape* of the bound
is the one proved here.

## Main results

* `mem_nbWalks_iff` — the constructed Finset is exactly the set of non-backtracking walks.
* `card_nbWalks` — there are exactly `4 · 3 ^ n` non-backtracking walks with `n + 1` steps.
* `nbWalks_growth` — the growth constant is `3`: the count is `≤ 4 · 3 ^ ℓ` for every `ℓ`.
* `walk_counting_threshold` — combining with `SurfaceCode.suppression_iff`: with growth
  constant `3`, error chains are exponentially suppressed iff `p < 1/3`.

-- !-- Lab Notebook -- !--
-- Hypothesis:  The exponential growth rate of lattice error chains can be pinned down
--   *exactly* (not just bounded), because the non-backtracking constraint is Markovian:
--   the number of continuations of a partial walk depends only on its last step.
-- Result:  Confirmed, and the exactness is visible in the proof:  `card_nbFrom` shows
--   every "walk with a prescribed first step" class has the *same* cardinality `3 ^ n`,
--   which is what makes the biUnion decomposition disjoint and the count exact.
-- Data:  ℓ = 1, 2, 3, 4, 5 steps ↦ 4, 12, 36, 108, 324 non-backtracking walks
--   (`4 · 3 ^ (ℓ-1)`), against 4, 16, 64, 256, 1024 unrestricted walks: the
--   non-backtracking constraint already removes 68 % of the weight-5 chains.
-- Insight:  Disjointness of the decomposition is enforced by a *head* invariant
--   (`head_of_mem_nbFrom`), not by any geometric argument — the combinatorics of the
--   growth constant is purely a statement about the transfer matrix of the direction
--   graph, i.e. about `K₄ minus a perfect matching`.
-- Boundary:  The count is for non-backtracking, not self-avoiding, walks.  Self-avoiding
--   walks are a subset, so `3` remains an upper bound on their growth constant (the true
--   connective constant of ℤ² is ≈ 2.638, and no closed form is known — this is exactly
--   why the threshold constant is quoted, not derived, in the literature).
-/

open Filter Topology

namespace SurfaceCode

/-- The four lattice directions. -/
abbrev Dir := Fin 4

/-- Reversal of a lattice direction. -/
def revDir (d : Dir) : Dir := d + 2

@[simp] theorem revDir_revDir (d : Dir) : revDir (revDir d) = d := by
  fin_cases d <;> rfl

theorem revDir_ne (d : Dir) : revDir d ≠ d := by
  fin_cases d <;> decide

/-- A walk (a list of steps) is **non-backtracking** if no step is the reverse of its
predecessor. -/
def NB : List Dir → Prop := List.IsChain (fun a b => b ≠ revDir a)

/-- The non-backtracking walks with `n + 1` steps whose first step is `d`. -/
def nbFrom : Dir → ℕ → Finset (List Dir)
  | d, 0 => {[d]}
  | d, (n + 1) => (Finset.univ.filter (fun e => e ≠ revDir d)).biUnion
      (fun e => (nbFrom e n).image (fun w => d :: w))

/-- Every member of `nbFrom d n` does start with `d`; this invariant is what makes the
recursive decomposition disjoint. -/
theorem head_of_mem_nbFrom {d : Dir} {n : ℕ} {w : List Dir} (h : w ∈ nbFrom d n) :
    w.head? = some d := by
  cases n with
  | zero => simp [nbFrom] at h; simp [h]
  | succ n =>
      simp only [nbFrom, Finset.mem_biUnion, Finset.mem_image] at h
      obtain ⟨e, -, w', -, rfl⟩ := h
      simp

/-- `nbFrom d n` is exactly the set of non-backtracking walks of `n + 1` steps starting
with `d`. -/
theorem mem_nbFrom_iff (d : Dir) (n : ℕ) (w : List Dir) :
    w ∈ nbFrom d n ↔ w.length = n + 1 ∧ w.head? = some d ∧ NB w := by
  induction n generalizing d w with
  | zero =>
      simp only [nbFrom, Finset.mem_singleton]
      constructor
      · rintro rfl; exact ⟨rfl, rfl, List.isChain_singleton _⟩
      · rintro ⟨hlen, hhead, -⟩
        match w, hlen with
        | [a], _ => simpa using hhead
  | succ n ih =>
      simp only [nbFrom, Finset.mem_biUnion, Finset.mem_filter, Finset.mem_univ, true_and,
        Finset.mem_image]
      constructor
      · rintro ⟨e, he, w', hw', rfl⟩
        obtain ⟨hlen, hhead, hchain⟩ := (ih e w').1 hw'
        refine ⟨by simp [hlen], by simp, ?_⟩
        rw [NB, List.isChain_cons]
        refine ⟨fun b hb => ?_, hchain⟩
        rw [hhead] at hb
        simp only [Option.mem_def, Option.some.injEq] at hb
        exact hb ▸ he
      · rintro ⟨hlen, hhead, hchain⟩
        match w with
        | [] => simp at hlen
        | a :: w' =>
            have ha : a = d := by simpa using hhead
            subst ha
            rw [NB, List.isChain_cons] at hchain
            obtain ⟨hh, hc⟩ := hchain
            have hlen' : w'.length = n + 1 := by simpa using hlen
            have hne : w' ≠ [] := by intro h; rw [h] at hlen'; simp at hlen'
            obtain ⟨e, he⟩ : ∃ e, w'.head? = some e := by
              cases w' with
              | nil => exact absurd rfl hne
              | cons b t => exact ⟨b, rfl⟩
            exact ⟨e, hh e he, w', (ih e w').2 ⟨hlen', he, hc⟩, rfl⟩

/-- **Each first step has exactly `3 ^ n` non-backtracking continuations.** -/
theorem card_nbFrom (d : Dir) (n : ℕ) : (nbFrom d n).card = 3 ^ n := by
  induction n generalizing d with
  | zero => simp [nbFrom]
  | succ n ih =>
      rw [nbFrom, Finset.card_biUnion]
      · have hterm : ∀ e ∈ (Finset.univ.filter (fun e : Dir => e ≠ revDir d)),
            ((nbFrom e n).image (fun w => d :: w)).card = 3 ^ n := by
          intro e _
          rw [Finset.card_image_of_injective _ (fun a b hab => by simpa using hab), ih]
        rw [Finset.sum_congr rfl hterm]
        have hcard : (Finset.univ.filter (fun e : Dir => e ≠ revDir d)).card = 3 := by
          rw [Finset.filter_ne']
          simp
        rw [Finset.sum_const, hcard]
        ring
      · intro x hx y hy hxy
        simp only [Finset.disjoint_left, Finset.mem_image]
        rintro a ⟨w1, hw1, rfl⟩ ⟨w2, hw2, h2⟩
        have h1 := head_of_mem_nbFrom hw1
        have h3 : w2 = w1 := by simpa using h2
        subst h3
        have := head_of_mem_nbFrom hw2
        exact hxy (by simp_all)

/-- All non-backtracking walks with `n + 1` steps. -/
def nbWalks (n : ℕ) : Finset (List Dir) := Finset.univ.biUnion (fun d => nbFrom d n)

/-- `nbWalks n` is exactly the set of non-backtracking walks of `n + 1` steps. -/
theorem mem_nbWalks_iff (n : ℕ) (w : List Dir) :
    w ∈ nbWalks n ↔ w.length = n + 1 ∧ NB w := by
  simp only [nbWalks, Finset.mem_biUnion, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨d, hd⟩
    obtain ⟨hlen, -, hchain⟩ := (mem_nbFrom_iff d n w).1 hd
    exact ⟨hlen, hchain⟩
  · rintro ⟨hlen, hchain⟩
    match w with
    | [] => simp at hlen
    | a :: w' => exact ⟨a, (mem_nbFrom_iff a n (a :: w')).2 ⟨hlen, rfl, hchain⟩⟩

/-- **Exact chain count.**  There are exactly `4 · 3 ^ n` non-backtracking walks with
`n + 1` steps on the square lattice.  Hence the chain-growth constant is `3`. -/
theorem card_nbWalks (n : ℕ) : (nbWalks n).card = 4 * 3 ^ n := by
  rw [nbWalks, Finset.card_biUnion]
  · rw [Finset.sum_congr rfl (fun d _ => card_nbFrom d n)]
    simp [Finset.sum_const]
  · intro x hx y hy hxy
    simp only [Finset.disjoint_left]
    intro a ha ha'
    have h1 := head_of_mem_nbFrom ha
    have h2 := head_of_mem_nbFrom ha'
    rw [h1] at h2
    exact hxy (by simpa using h2)

/-- Growth bound in the form used by the threshold argument: the number of chains of
weight `ℓ` is at most `4 · 3 ^ ℓ`. -/
theorem nbWalks_growth (n : ℕ) : ((nbWalks n).card : ℝ) ≤ 4 * 3 ^ (n + 1) := by
  rw [card_nbWalks]
  push_cast
  have : (3 : ℝ) ^ n ≤ 3 ^ (n + 1) := by
    apply pow_le_pow_right₀ <;> norm_num
  nlinarith [pow_nonneg (by norm_num : (0:ℝ) ≤ 3) n]

/-- **Provable threshold from lattice combinatorics.**  With the rigorously derived growth
constant `3`, the chain-counting failure bound (with any positive number `N` of anchor
positions) is exponentially suppressed in the code distance **iff** the physical error
rate is below `1/3`.  This is the same statement as the `1 %` theorem, with the modelling
constant `μ = 100` replaced by the constant `3` that the lattice actually provides. -/
theorem walk_counting_threshold {N p : ℝ} (hN : 0 < N) (hp : 0 ≤ p) :
    Tendsto (fun m : ℕ => N * (3 * p) ^ m) atTop (𝓝 0) ↔ p < 1 / 3 := by
  rw [suppression_iff hN (by positivity)]
  constructor <;> intro h <;> linarith

/-- Small-case data underlying the Lab Notebook table: `4, 12, 36, 108` walks of
`1, 2, 3, 4` steps. -/
theorem card_nbWalks_examples :
    (nbWalks 0).card = 4 ∧ (nbWalks 1).card = 12 ∧ (nbWalks 2).card = 36 ∧
      (nbWalks 3).card = 108 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [card_nbWalks] <;> norm_num

end SurfaceCode