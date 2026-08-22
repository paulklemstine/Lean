/-
# Cycle 8: **Effective** exponents for modal primitivity

Cycles 6–7 (`Probability.MarkovModalDefinability`, `MarkovPrimitivity`,
`MarkovFrobeniusSpectrum`, `MarkovAperiodicSpectrum`) settled the *qualitative* theory of
the support frame of a Markov chain: `0 < Pⁿ(u,v)` is `n`-step modal accessibility
(`stepPow_pos_iff`), the soundness spectrum of a world is an additive submonoid of `ℕ`,
and for a finite irreducible chain Perron–Frobenius primitivity is equivalent to
aperiodicity of one state.  Every threshold produced there was an *unspecified* `N`
obtained from a `Finset.sup` of ad hoc padding bounds.

This file makes the thresholds **effective**, in terms of the number of worlds alone.
The missing combinatorial input is a shortest-path principle for `iterR`, which is
proved here from scratch by presenting paths as functions `ℕ → F.W` and excising a
repeated world (pigeonhole).

## Main results

* `exists_iterR_lt_card` — **the diameter principle**: if `iterR F k u v` for *some* `k`,
  then already for some `k < card F.W`.  (Pigeonhole plus path splicing.)
* `iterR_of_card_sub_one_le` — an irreducible frame all of whose worlds carry a self-loop
  (a *lazy* chain) has uniform exponent at most `card F.W - 1`.
* `iterR_of_two_mul_card_sub_one_le` — a *single* self-loop already gives the
  Holladay–Varga-type exponent `2 * (card F.W - 1)`.
* `stepPow_pos_of_lazy_card_le`, `stepPow_pos_of_oneLoop_card_le` — the probabilistic
  readings: explicit primitivity exponents for stochastic matrices.
* `iterSound_of_card_sub_one_le` — every world of a finite irreducible lazy frame
  validates `□ᵏφ → φ` for **every** `k ≥ card F.W - 1`; the soundness spectrum is
  cofinite with an explicit conductor.
* `nbrChain` and `nbrChain_exponent_eq` — the nearest-neighbour chain on `Fin n` is
  irreducible and lazy, and its primitivity exponent is *exactly* `n - 1`: the bound of
  `iterR_of_card_sub_one_le` is sharp for every `n`.

## Lab Notes

*Hypothesis (Stage 1).*  The unspecified thresholds of Cycles 6–7 are an artefact of the
proof, not of the mathematics: reachability in a finite frame needs at most `card - 1`
steps, so the padding bounds should collapse to a function of `card` alone.

*Experiment (Stage 2).*  Two routes to the diameter principle were considered.  (i) A
Finset "reachable within `j` steps" stabilisation argument: monotone, but needs a
cardinality-growth induction and decidability of the accessibility relation.  (ii) Paths
as functions with an excision splice: needs no decidability of `F.R` at all, only
`Fintype F.W`, and the splice
`g m = if m ≤ i then f m else f (m + (j - i))` is checked by three index cases, each
closed by `omega`.  Route (ii) was taken; `FramePath` and `iterR` are shown equivalent
in both directions.

*Analysis (Stage 3).*  The lazy bound `card - 1` and the one-loop bound
`2 * (card - 1)` differ by exactly the cost of routing through the distinguished looping
world: an approach of length `< card` and an exit of length `< card`.  The sharpness
witness shows the first bound cannot be improved, so the modal route recovers the
classical exponent bounds for matrices with a positive diagonal.

*Critique (Stage 4).*  Nothing here is vacuous: `nbrChain_not_iterR_of_lt` exhibits a
*failing* instance for every `k < n - 1`, so `nbrChain_exponent_eq` is a genuine
equality, and the two exponent theorems are stated for all `k` above the bound, not just
for one `k`.
-/
import Mathlib
import Probability.MarkovAperiodicSpectrum

namespace MarkovModal

open GLPLogic TangledSoundness FrameDefinability

variable {S : Type} {α : Type}

/-! ## Part A — Paths as functions, and the diameter principle -/

/-- A path of `k` edges from `u` to `v`, presented as a function `ℕ → F.W`. -/
def FramePath (F : KFrame) (f : ℕ → F.W) (k : ℕ) (u v : F.W) : Prop :=
  f 0 = u ∧ f k = v ∧ ∀ i < k, F.R (f i) (f (i + 1))

/-- Every `k`-step accessibility witness is realised by a path function. -/
theorem exists_framePath (F : KFrame) :
    ∀ (k : ℕ) (u v : F.W), iterR F k u v → ∃ f : ℕ → F.W, FramePath F f k u v := by
  intro k
  induction k with
  | zero =>
      intro u v h
      cases h
      exact ⟨fun _ => u, rfl, rfl, by omega⟩
  | succ k ih =>
      intro u v h
      obtain ⟨z, hz, hzv⟩ := h
      obtain ⟨g, hg0, hgk, hge⟩ := ih z v hzv
      refine ⟨fun i => if i = 0 then u else g (i - 1), rfl, by simpa using hgk, ?_⟩
      intro i hi
      cases i with
      | zero => simpa [hg0] using hz
      | succ m => simpa using hge m (by omega)

/-- Conversely, a path function witnesses `k`-step accessibility. -/
theorem iterR_of_framePath (F : KFrame) :
    ∀ (k : ℕ) (f : ℕ → F.W) (u v : F.W), FramePath F f k u v → iterR F k u v := by
  intro k
  induction k with
  | zero =>
      rintro f u v ⟨h0, hk, -⟩
      exact h0 ▸ hk ▸ rfl
  | succ k ih =>
      rintro f u v ⟨h0, hk, he⟩
      refine ⟨f 1, ?_, ih (fun i => f (i + 1)) (f 1) v ⟨rfl, hk, ?_⟩⟩
      · have := he 0 (by omega)
        simpa [h0] using this
      · intro i hi
        exact he (i + 1) (by omega)

/-- **Path shortening.**  A path longer than the number of worlds repeats a world, and
excising the loop between the repetitions produces a strictly shorter path. -/
theorem exists_shorter_iterR (F : KFrame) [Fintype F.W] {k : ℕ} {u v : F.W}
    (hk : Fintype.card F.W ≤ k) (h : iterR F k u v) : ∃ j < k, iterR F j u v := by
  obtain ⟨f, hf0, hfk, hfe⟩ := exists_framePath F k u v h
  -- the excision step, for a repetition `f i = f j` with `i < j ≤ k`
  have key : ∀ i j : ℕ, i < j → j ≤ k → f i = f j → ∃ m < k, iterR F m u v := by
    intro i j hij hjk hfij
    rcases eq_or_lt_of_le hjk with rfl | hjlt
    · -- the repetition reaches the endpoint: truncate at `i`
      refine ⟨i, by omega, iterR_of_framePath F i f u v ⟨hf0, ?_, fun t ht => hfe t (by omega)⟩⟩
      rw [hfij]; exact hfk
    · -- genuine excision of the loop of length `d = j - i`
      set d := j - i with hd
      have hd1 : 1 ≤ d := by omega
      have hdk : d ≤ k := by omega
      refine ⟨k - d, by omega,
        iterR_of_framePath F (k - d) (fun m => if m ≤ i then f m else f (m + d)) u v
          ⟨by simpa using hf0, ?_, ?_⟩⟩
      · have hne : ¬ (k - d ≤ i) := by omega
        simp only [hne, if_false]
        have : k - d + d = k := by omega
        rw [this]; exact hfk
      · intro t ht
        rcases lt_trichotomy t i with hti | hti | hti
        · have h1 : (t ≤ i) := by omega
          have h2 : (t + 1 ≤ i) := by omega
          simp only [h1, h2, if_true]
          exact hfe t (by omega)
        · subst hti
          have h1 : (t ≤ t) := le_refl t
          have h2 : ¬ (t + 1 ≤ t) := by omega
          simp only [h1, h2, if_true, if_false]
          have hsum : t + 1 + d = j + 1 := by omega
          rw [hsum, hfij]
          exact hfe j (by omega)
        · have h1 : ¬ (t ≤ i) := by omega
          have h2 : ¬ (t + 1 ≤ i) := by omega
          simp only [h1, h2, if_false]
          have hsum : t + 1 + d = (t + d) + 1 := by omega
          rw [hsum]
          exact hfe (t + d) (by omega)
  -- pigeonhole on the `k + 1` worlds visited
  have hcard : Fintype.card F.W < Fintype.card (Fin (k + 1)) := by
    simpa using Nat.lt_succ_of_le hk
  obtain ⟨a, b, hab, hfab⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin (k + 1) => f i) hcard
  have ha := a.isLt
  have hb := b.isLt
  rcases lt_or_gt_of_ne hab with hlt | hlt
  · exact key a b (Fin.lt_def.mp hlt) (by omega) hfab
  · exact key b a (Fin.lt_def.mp hlt) (by omega) hfab.symm

/-- **The diameter principle.**  In a finite frame, anything reachable at all is
reachable in fewer than `card F.W` steps. -/
theorem exists_iterR_lt_card (F : KFrame) [Fintype F.W] :
    ∀ (k : ℕ) (u v : F.W), iterR F k u v → ∃ j < Fintype.card F.W, iterR F j u v := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
      intro u v h
      by_cases hk : k < Fintype.card F.W
      · exact ⟨k, hk, h⟩
      · obtain ⟨j, hj, hji⟩ := exists_shorter_iterR F (by omega) h
        exact ih j hj u v hji

/-- In a finite irreducible frame every ordered pair is joined by a path of length
`< card F.W`. -/
theorem exists_iterR_lt_card_of_irreducible (F : KFrame) [Fintype F.W]
    (hirr : FrameIrreducible F) (u v : F.W) : ∃ j < Fintype.card F.W, iterR F j u v := by
  obtain ⟨k, hk⟩ := hirr u v
  exact exists_iterR_lt_card F k u v hk

/-! ## Part B — Effective exponents -/

/-- Padding at the target: if every world loops, a path can be extended to any greater
length. -/
theorem iterR_of_le_of_selfLoops (F : KFrame) (hloop : ∀ w : F.W, F.R w w) {a : ℕ}
    {u v : F.W} (h : iterR F a u v) {k : ℕ} (hk : a ≤ k) : iterR F k u v :=
  iterR_of_add_le F (hloop v) h (show iterR F 0 v v from rfl) k (by omega)

/-- **Effective primitivity for lazy frames.**  A finite irreducible frame in which every
world carries a self-loop has uniform exponent at most `card F.W - 1`: for *every*
`k ≥ card F.W - 1` and every ordered pair `u, v` there is a `k`-step path from `u` to
`v`. -/
theorem iterR_of_card_sub_one_le (F : KFrame) [Fintype F.W] (hirr : FrameIrreducible F)
    (hloop : ∀ w : F.W, F.R w w) {k : ℕ} (hk : Fintype.card F.W - 1 ≤ k) (u v : F.W) :
    iterR F k u v := by
  obtain ⟨j, hj, hju⟩ := exists_iterR_lt_card_of_irreducible F hirr u v
  exact iterR_of_le_of_selfLoops F hloop hju (by omega)

/-- **Effective primitivity from a single loop.**  One self-loop suffices, at the cost of
doubling the exponent: routing through the looping world costs an approach and an exit,
each of length `< card F.W`. -/
theorem iterR_of_two_mul_card_sub_one_le (F : KFrame) [Fintype F.W]
    (hirr : FrameIrreducible F) {w : F.W} (hloop : F.R w w) {k : ℕ}
    (hk : 2 * (Fintype.card F.W - 1) ≤ k) (u v : F.W) : iterR F k u v := by
  obtain ⟨a, ha, hau⟩ := exists_iterR_lt_card_of_irreducible F hirr u w
  obtain ⟨b, hb, hbv⟩ := exists_iterR_lt_card_of_irreducible F hirr w v
  exact iterR_of_add_le F hloop hau hbv k (by omega)

/-- **An explicit conductor for the soundness spectrum.**  Every world of a finite
irreducible lazy frame validates the reflection principle `□ᵏφ → φ` for every
`k ≥ card F.W - 1`. -/
theorem iterSound_of_card_sub_one_le (F : KFrame) [Fintype F.W] (p : α)
    (hirr : FrameIrreducible F) (hloop : ∀ w : F.W, F.R w w) {k : ℕ}
    (hk : Fintype.card F.W - 1 ≤ k) (u : F.W) : IterSoundAt F α k u :=
  (iterSound_iff_cycle F p k u).mpr (iterR_of_card_sub_one_le F hirr hloop hk u u)

/-! ## Part C — The probabilistic readings -/

/-- The worlds of a support frame are the states, so a finite state space makes the
support frame finite. -/
instance suppFrameFintype [Fintype S] (P : S → S → ℝ) : Fintype (suppFrame P).W :=
  ‹Fintype S›

@[simp] theorem card_suppFrame [Fintype S] (P : S → S → ℝ) :
    Fintype.card (suppFrame P).W = Fintype.card S := rfl

/-- **Effective Perron–Frobenius exponent for a lazy chain.**  If every state of a finite
irreducible chain has positive holding probability, then every entry of `Pᵏ` is positive
for every `k ≥ card S - 1`. -/
theorem stepPow_pos_of_lazy_card_le [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (hirr : ChainIrreducible P) (hlazy : ∀ w, 0 < P w w) {k : ℕ}
    (hk : Fintype.card S - 1 ≤ k) (u v : S) : 0 < stepPow P k u v := by
  have hfr : FrameIrreducible (suppFrame P) := (chainIrreducible_iff_frameIrreducible hP).mp hirr
  refine (stepPow_pos_iff hP k u v).mpr ?_
  exact iterR_of_card_sub_one_le (suppFrame P) hfr (fun w => hlazy w) (by simpa using hk) u v

/-- **Effective exponent from a single holding state.**  One state with positive holding
probability makes a finite irreducible chain primitive with exponent
`2 * (card S - 1)`. -/
theorem stepPow_pos_of_oneLoop_card_le [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (hirr : ChainIrreducible P) {w : S} (hloop : 0 < P w w) {k : ℕ}
    (hk : 2 * (Fintype.card S - 1) ≤ k) (u v : S) : 0 < stepPow P k u v := by
  have hfr : FrameIrreducible (suppFrame P) := (chainIrreducible_iff_frameIrreducible hP).mp hirr
  refine (stepPow_pos_iff hP k u v).mpr ?_
  exact iterR_of_two_mul_card_sub_one_le (suppFrame P) hfr (w := w) hloop (by simpa using hk) u v

/-! ## Part D — Sharpness: the nearest-neighbour chain on `Fin n` -/

/-- The **nearest-neighbour chain** on `Fin n`: a state may stay put or move to an
adjacent state.  (Unnormalised; only the support matters.) -/
def nbrChain (n : ℕ) : Fin n → Fin n → ℝ :=
  fun i j => if (i : ℕ) ≤ (j : ℕ) + 1 ∧ (j : ℕ) ≤ (i : ℕ) + 1 then 1 else 0

theorem nbrChain_nonneg (n : ℕ) (i j : Fin n) : 0 ≤ nbrChain n i j := by
  unfold nbrChain; split <;> norm_num

@[simp] theorem nbrChain_pos_iff (n : ℕ) (i j : Fin n) :
    0 < nbrChain n i j ↔ ((i : ℕ) ≤ (j : ℕ) + 1 ∧ (j : ℕ) ≤ (i : ℕ) + 1) := by
  unfold nbrChain; split <;> simp_all

theorem nbrChain_lazy (n : ℕ) (i : Fin n) : 0 < nbrChain n i i := by simp

/-- Climbing: a `d`-step path from `i` to the state `d` places above it. -/
theorem nbrChain_iterR_up (n : ℕ) :
    ∀ (d : ℕ) (i j : Fin n), (j : ℕ) = (i : ℕ) + d → iterR (suppFrame (nbrChain n)) d i j := by
  intro d
  induction d with
  | zero => intro i j h; exact Fin.ext (by omega)
  | succ d ih =>
      intro i j h
      have hlt : (i : ℕ) + 1 < n := by omega
      have hval : ((⟨(i : ℕ) + 1, hlt⟩ : Fin n) : ℕ) = (i : ℕ) + 1 := rfl
      refine ⟨⟨(i : ℕ) + 1, hlt⟩, ?_, ih ⟨(i : ℕ) + 1, hlt⟩ j (by omega)⟩
      show (0 : ℝ) < nbrChain n i ⟨(i : ℕ) + 1, hlt⟩
      rw [nbrChain_pos_iff]
      omega

/-- Descending: a `d`-step path from `i` to the state `d` places below it. -/
theorem nbrChain_iterR_down (n : ℕ) :
    ∀ (d : ℕ) (i j : Fin n), (i : ℕ) = (j : ℕ) + d → iterR (suppFrame (nbrChain n)) d i j := by
  intro d
  induction d with
  | zero => intro i j h; exact Fin.ext (by omega)
  | succ d ih =>
      intro i j h
      have hlt : (i : ℕ) - 1 < n := by omega
      have hval : ((⟨(i : ℕ) - 1, hlt⟩ : Fin n) : ℕ) = (i : ℕ) - 1 := rfl
      refine ⟨⟨(i : ℕ) - 1, hlt⟩, ?_, ih ⟨(i : ℕ) - 1, hlt⟩ j (by omega)⟩
      show (0 : ℝ) < nbrChain n i ⟨(i : ℕ) - 1, hlt⟩
      rw [nbrChain_pos_iff]
      omega

theorem nbrChain_irreducible (n : ℕ) : ChainIrreducible (nbrChain n) := by
  intro u v
  rcases le_total (u : ℕ) (v : ℕ) with h | h
  · exact ⟨(v : ℕ) - (u : ℕ),
      (stepPow_pos_iff (nbrChain_nonneg n) _ u v).mpr
        (nbrChain_iterR_up n _ u v (by omega))⟩
  · exact ⟨(u : ℕ) - (v : ℕ),
      (stepPow_pos_iff (nbrChain_nonneg n) _ u v).mpr
        (nbrChain_iterR_down n _ u v (by omega))⟩

/-- **Upper bound.**  Every entry of the `k`-th power of the nearest-neighbour chain is
positive once `k ≥ n - 1`. -/
theorem nbrChain_stepPow_pos (n : ℕ) {k : ℕ} (hk : n - 1 ≤ k) (u v : Fin n) :
    0 < stepPow (nbrChain n) k u v :=
  stepPow_pos_of_lazy_card_le (nbrChain_nonneg n) (nbrChain_irreducible n)
    (nbrChain_lazy n) (by simpa using hk) u v

/-- The speed limit: one step moves the index by at most one. -/
theorem nbrChain_iterR_le (n : ℕ) :
    ∀ (k : ℕ) (i j : Fin n), iterR (suppFrame (nbrChain n)) k i j → (j : ℕ) ≤ (i : ℕ) + k := by
  intro k
  induction k with
  | zero => intro i j h; cases h; omega
  | succ k ih =>
      intro i j h
      obtain ⟨z, hz, hzj⟩ := h
      have hz2 : (0 : ℝ) < nbrChain n i z := hz
      obtain ⟨-, hz3⟩ := (nbrChain_pos_iff n i z).mp hz2
      have h4 := ih z j hzj
      omega

/-- **Lower bound (sharpness).**  Fewer than `n - 1` steps cannot join the two ends of
the nearest-neighbour chain, so the exponent `n - 1` of `iterR_of_card_sub_one_le`
cannot be improved. -/
theorem nbrChain_not_iterR_of_lt (n : ℕ) (hn : 1 ≤ n) {k : ℕ} (hk : k < n - 1) :
    ¬ (0 < stepPow (nbrChain n) k ⟨0, by omega⟩ ⟨n - 1, by omega⟩) := by
  intro hpos
  have h := (stepPow_pos_iff (nbrChain_nonneg n) k _ _).mp hpos
  have := nbrChain_iterR_le n k ⟨0, by omega⟩ ⟨n - 1, by omega⟩ h
  simp at this
  omega

/-- **The exponent of the nearest-neighbour chain is exactly `n - 1`.**  Combining the
effective upper bound with the speed limit: `k` works for *all* pairs iff `k ≥ n - 1`. -/
theorem nbrChain_exponent_eq (n : ℕ) (hn : 1 ≤ n) (k : ℕ) :
    (∀ u v : Fin n, 0 < stepPow (nbrChain n) k u v) ↔ n - 1 ≤ k := by
  constructor
  · intro h
    by_contra hlt
    exact nbrChain_not_iterR_of_lt n hn (by omega) (h _ _)
  · intro hk u v
    exact nbrChain_stepPow_pos n hk u v

/-! ## Part E — Capstone -/

/-- **Cycle-8 capstone.**  For a finite irreducible chain with nonnegative entries:
laziness gives the effective primitivity exponent `card S - 1`, a single holding state
gives `2 * (card S - 1)`, and the first bound is attained by the nearest-neighbour chain
on `Fin n`, whose exponent is exactly `n - 1`. -/
theorem markov_exponent_capstone [Fintype S] [DecidableEq S] {P : S → S → ℝ}
    (hP : ∀ u v, 0 ≤ P u v) (hirr : ChainIrreducible P) :
    ((∀ w, 0 < P w w) →
        ∀ k, Fintype.card S - 1 ≤ k → ∀ u v, 0 < stepPow P k u v) ∧
      (∀ w : S, 0 < P w w →
        ∀ k, 2 * (Fintype.card S - 1) ≤ k → ∀ u v, 0 < stepPow P k u v) ∧
      (∀ n : ℕ, 1 ≤ n → ∀ k : ℕ,
        (∀ u v : Fin n, 0 < stepPow (nbrChain n) k u v) ↔ n - 1 ≤ k) :=
  ⟨fun hlazy _k hk u v => stepPow_pos_of_lazy_card_le hP hirr hlazy hk u v,
   fun _w hw _k hk u v => stepPow_pos_of_oneLoop_card_le hP hirr hw hk u v,
   fun n hn k => nbrChain_exponent_eq n hn k⟩

end MarkovModal