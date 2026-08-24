import NumberTheory.TagReflectionDepthRigidity

/-!
# The exact reflection spectrum of a two-valued height vector

`NumberTheory.TagReflectionDepthRigidity` shows that inside the common refinement of
`capC` and `valSys` the reflection-depth vector is *not* free: it is a function of the
height vector, subject to

* rigidity — equal truncated heights force equal reflection depths;
* the height-gap inequality `classRealizes_gap_bound` — `r i ≤ min N (d i) − min N (d j)`
  whenever `min N (d j) < min N (d i)`;
* the low-tag collapse `classRealizes_low_tag_le_one` — `r j ≤ 1` as soon as some tag is
  strictly higher than `j`.

This file proves that for a **two-valued** height vector those two inequalities are
*exactly* the answer: the bounds are attained, so the function "height vector ↦
reflection-depth vector" is computed in closed form on this family.  Concretely, fix
`1 ≤ L < N`, split the tags by a Boolean marker `s`, and give the marked tags height `N`
and the unmarked ones height `L` (`twoValD`).  Then the refinement realizes precisely
the reflection depths

  `r i = N − L`  for a high tag,      `r i = 1`  for a low tag

(`classRealizes_twoValue`), the constant valuation `flatVal` being the witness.

The positive half is a bounded bisimulation for two-valued truncation vectors
(`satCV_flat_congr`): with the atoms carrying no information, the worlds `m` and `n` of
the model satisfy the same formulas of box depth `≤ k` as soon as
`min m (L + k) = min n (L + k)`.  The point is that a tag of height `L` can only see the
worlds below `L`, so it cannot help a formula to count further than the low cut point
plus its own box depth; the top world `N` therefore stays indistinguishable from `N − 1`
until depth `N − L`, which is exactly where the gap probe of the negative half strikes.

Together with `classRealizes_constant` (the case `L = N`) this determines
`ClassRealizes` completely for every height vector with at most two values.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the upper bounds of the previous cycle are attained; the empirical
  spectrum measured by exhaustive enumeration (`ComputationalEvidence.md` §5) reads
  `ρ(H) = H − L` and `ρ(L) = 1` for every pair `H > L ≥ 1` tested.
Experiment (Stage 2): formalise the matching lower bounds.  The low-tag bound `ρ(L) ≥ 1`
  needs only that a box-free formula has a world-independent truth value under a
  constant valuation; the high-tag bound `ρ(H) ≥ H − L` needs the bisimulation
  `min m (L + k) = min n (L + k)` fed into `satF_congr_of_approx`.
Analysis (Stage 3): the two cut points of the model are the low height `L` and the top
  `N`; a formula of box depth `k` moves the visible horizon from `L` to `L + k`, so the
  reflection depth of the high tags is the distance `N − L` between the cut points —
  the "distance between two cut points" picture of the original conjecture survives,
  but the second cut point is the *lower tag's height*, not the valuation.
Critique (Stage 4): the theorem is not vacuous — both halves of every biconditional are
  proved for arbitrary formulas, the witnesses `hhigh`, `hlow` are genuinely needed
  (without a low tag the profile is the constant one, whose depth is `N`), and the
  hypothesis `1 ≤ L` is necessary: for `L = 0` the low tags are dead and the high tags
  have reflection depth `N`, not `N − 0 = N` by accident but by
  `classRealizes_constant`-style reasoning.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open ReflectionSpectrum
open Form

/-! ## §1. The information-free valuation -/

/-- The constant valuation: no atom is ever true.  With it, a formula of box depth `0`
has the same truth value at every world, so the *only* way to separate two worlds is to
count accessibility steps. -/
def flatVal : ℕ → ℕ → Bool := fun _ _ => false

/-! ## §2. A bounded bisimulation for two-valued truncation vectors -/

/-- **The horizon lemma for two-valued heights.**  Suppose every tag has truncation
either exactly `L` or at least `N`.  Then, under the constant valuation, two worlds of
the model that agree on `min · (L + k)` satisfy the same formulas of box depth `≤ k`:
the low tags freeze the horizon at `L`, and each box moves it down by one. -/
theorem satCV_flat_congr {c : ℕ → ℕ} {N L : ℕ} (hc : ∀ j, c j = L ∨ N ≤ c j) :
    ∀ (a : Form) (k m n : ℕ), boxDepth a ≤ k → m ≤ N → n ≤ N →
      min m (L + k) = min n (L + k) →
      satCV c flatVal m a = satCV c flatVal n a := by
  intro a k m n hk hm hn hmn
  refine satF_congr_of_approx
    (E := fun k m n => m ≤ N ∧ n ≤ N ∧ min m (L + k) = min n (L + k))
    ?_ ?_ ?_ a k m n hk ⟨hm, hn, hmn⟩
  · intro _ _ _ _ _; rfl
  · rintro _ _ _ ⟨h1, h2, h3⟩
    exact ⟨h2, h1, h3.symm⟩
  · rintro k' m₀ n₀ ⟨h1, h2, h3⟩ j m' hm' hR
    simp only [capRel, decide_eq_true_eq] at hR
    rcases hc j with hL | hN
    · -- a low tag: the two worlds are literally equal
      have hmn₀ : n₀ = m₀ := by omega
      subst hmn₀
      exact ⟨m', hm', by simp only [capRel, decide_eq_true_eq]; omega,
        ⟨by omega, by omega, rfl⟩⟩
    · -- a high tag: match `m'` with its horizon truncation
      refine ⟨min m' (L + k'), by omega, by simp only [capRel, decide_eq_true_eq]; omega,
        ⟨by omega, by omega, by omega⟩⟩

/-! ## §3. The two reflection depths are attained -/

/-- **The high tags reflect to depth `N − L`.**  A tag reaching the top of the model
satisfies the depth-restricted reflection rule up to the distance between the two cut
points: a formula of box depth `< N − L` cannot separate the top world `N` from the
world `N − 1`, which the tag does see. -/
theorem cvSys_flat_depthReflection_high {c : ℕ → ℕ} {N L i : ℕ} (hL : L < N)
    (hc : ∀ j, c j = L ∨ N ≤ c j) (hi : N ≤ c i) :
    DepthReflection (N - L) i (cvSys c flatVal N) := by
  intro a ha hbox
  rw [provable_cvSys_box_iff] at hbox
  rw [provable_cvSys]
  intro m hm
  rcases Nat.lt_or_ge m N with h | h
  · exact hbox m (by omega)
  · rw [satCV_flat_congr hc a (N - L - 1) m (N - 1) (by omega) hm (by omega) (by omega)]
    exact hbox (N - 1) (by omega)

/-- **Every live tag reflects to depth at least `1`.**  Under the constant valuation a
box-free formula has the same truth value everywhere, so if it holds on a nonempty image
it holds throughout the model. -/
theorem cvSys_flat_depthReflection_one {c : ℕ → ℕ} {N j : ℕ} (hj : 1 ≤ min N (c j)) :
    DepthReflection 1 j (cvSys c flatVal N) := by
  intro a ha hbox
  have h0 : boxDepth a = 0 := by omega
  rw [provable_cvSys_box_iff] at hbox
  have hroot := hbox 0 (by omega)
  rw [provable_cvSys]
  intro m _
  exact (satF_congr_of_boxDepth_zero (R := capRel c) (V := flatVal)
    (m := m) (n := 0) (fun _ => rfl) a h0).trans hroot

/-! ## §4. The closed formula for a two-valued height vector -/

/-- The two-valued height vector: the tags marked by `s` have height `N`, the others
have height `L`. -/
def twoValD (N L : ℕ) (s : ℕ → Bool) : ℕ → ℕ := fun i => if s i then N else L

/-- The reflection-depth vector predicted (and, by `classRealizes_twoValue`, realized):
the high tags reflect to the height gap `N − L`, the low tags to depth `1`. -/
def twoValR (N L : ℕ) (s : ℕ → Bool) : ℕ → ℕ := fun i => if s i then N - L else 1

/-- The predicted profile does obey the constraint of the original conjecture. -/
theorem twoValR_le_twoValD {N L : ℕ} (hL : 1 ≤ L) (hLN : L < N) (s : ℕ → Bool) (i : ℕ) :
    twoValR N L s i ≤ min N (twoValD N L s i) := by
  rcases Bool.eq_false_or_eq_true (s i) with h | h
  · have h1 : twoValR N L s i = N - L := by simp [twoValR, h]
    have h2 : twoValD N L s i = N := by simp [twoValD, h]
    omega
  · have h1 : twoValR N L s i = 1 := by simp [twoValR, h]
    have h2 : twoValD N L s i = L := by simp [twoValD, h]
    omega

/-- **The exact spectrum of a two-valued height vector.**  For `1 ≤ L < N` and any
splitting of the tags into a nonempty set of high tags (height `N`) and a nonempty set
of low tags (height `L`), the refinement of `capC` and `valSys` realizes the height
vector together with the reflection depths `N − L` (high tags) and `1` (low tags) — and
by `classRealizes_gap_bound` and `classRealizes_low_tag_le_one` those are the largest
possible values.  So on two-valued height vectors the reflection-depth vector is
completely determined, and the two inequalities of the previous cycle are sharp. -/
theorem classRealizes_twoValue {N L : ℕ} {s : ℕ → Bool} (hL : 1 ≤ L) (hLN : L < N)
    (hhigh : ∃ i, s i = true) (hlow : ∃ j, s j = false) :
    ClassRealizes N (twoValD N L s) (twoValR N L s) := by
  obtain ⟨ih, hih⟩ := hhigh
  obtain ⟨jl, hjl⟩ := hlow
  have hc : ∀ j, twoValD N L s j = L ∨ N ≤ twoValD N L s j := by
    intro j
    rcases Bool.eq_false_or_eq_true (s j) with h | h
    · exact Or.inr (by simp [twoValD, h])
    · exact Or.inl (by simp [twoValD, h])
  refine ⟨twoValD N L s, flatVal, fun i k => provable_cvSys_boxPow_bot_iff _ _ _ _ _,
    fun i r' => ?_⟩
  have hdih : twoValD N L s ih = N := by simp [twoValD, hih]
  have hdjl : twoValD N L s jl = L := by simp [twoValD, hjl]
  rcases Bool.eq_false_or_eq_true (s i) with hs | hs
  · -- a high tag: reflection depth exactly the gap `N - L`
    have hdi : twoValD N L s i = N := by simp [twoValD, hs]
    have hri : twoValR N L s i = N - L := by simp [twoValR, hs]
    constructor
    · intro hdr
      by_contra hr
      refine cvSys_not_depthReflection_gap (c := twoValD N L s) (V := flatVal)
        (N := N) (i := i) (j := jl) (by omega) (depthReflection_mono ?_ hdr)
      omega
    · intro hr
      refine depthReflection_mono ?_
        (cvSys_flat_depthReflection_high hLN hc (i := i) (by omega))
      omega
  · -- a low tag: reflection depth exactly `1`
    have hdi : twoValD N L s i = L := by simp [twoValD, hs]
    have hri : twoValR N L s i = 1 := by simp [twoValR, hs]
    constructor
    · intro hdr
      by_contra hr
      refine cvSys_not_depthReflection_two_of_lt (c := twoValD N L s) (V := flatVal)
        (N := N) (i := ih) (j := i) (by omega) (depthReflection_mono ?_ hdr)
      omega
    · intro hr
      refine depthReflection_mono ?_ (cvSys_flat_depthReflection_one (j := i) (by omega))
      omega

/-- **Sharpness of the two obstructions.**  The height-gap inequality and the low-tag
collapse of `NumberTheory.TagReflectionDepthRigidity` are attained simultaneously: there
is a theory of the refinement class in which a high tag reflects to exactly the gap and
a low tag to exactly depth `1`. -/
theorem classRealizes_gap_bound_sharp {N L : ℕ} (hL : 1 ≤ L) (hLN : L < N) :
    ∃ d r : ℕ → ℕ, ClassRealizes N d r ∧
      ∃ i j, min N (d j) < min N (d i) ∧ r i = min N (d i) - min N (d j) ∧ r j = 1 := by
  refine ⟨twoValD N L (fun i => decide (i = 0)), twoValR N L (fun i => decide (i = 0)),
    classRealizes_twoValue hL hLN ⟨0, by simp⟩ ⟨1, by simp⟩, 0, 1, ?_, ?_, ?_⟩
  · have h0 : twoValD N L (fun i => decide (i = 0)) 0 = N := by simp [twoValD]
    have h1 : twoValD N L (fun i => decide (i = 0)) 1 = L := by simp [twoValD]
    omega
  · have h0 : twoValD N L (fun i => decide (i = 0)) 0 = N := by simp [twoValD]
    have h1 : twoValD N L (fun i => decide (i = 0)) 1 = L := by simp [twoValD]
    have hr : twoValR N L (fun i => decide (i = 0)) 0 = N - L := by simp [twoValR]
    omega
  · simp [twoValR]

end PhysicsConsistency