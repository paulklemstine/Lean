import Pythagorean.TropicalCryptocurrency.RecessionCone

/-!
# Tropical Cryptocurrency III: a Hall-type criterion for multidirectional collisions

Continuing `Pythagorean/TropicalCryptocurrency/RecessionCone.lean`, we characterise
*exactly* which coordinate sets `S` can be freely increased without changing the
min-plus digest: `S` is a collision support iff every digest component keeps an
active (minimizing) coordinate **outside** `S`.

Consequences.

* `isCollisionSupport_iff` : the exact local criterion.
* `exists_collisionSupport_card_iff` : a coordinate collision cone of dimension
  `≥ d` exists **iff** the family of active sets admits a *hitting set* (a set
  meeting every active set) of cardinality `≤ k - d`.  This is the corrected
  Hall-type criterion.
* `sdr_criterion_counterexample` : the *system of distinct representatives*
  (transversal) formulation of the criterion is **false**: two digest components
  sharing their unique active coordinate admit no SDR at all, yet a
  one-dimensional collision cone exists.  Hitting sets, not SDRs, govern the local
  fiber geometry.
* `card_le_finrank_span_collisionCone` : any collision support of size `c` forces
  the recession cone of the fiber to have dimension at least `c`.
* `isGreatest_collisionSupport_card` : the maximal coordinate collision cone has
  dimension **exactly** `k - τ`, where `τ = hittingNumber A m` is the least size of
  a hitting set of the active family; and `hittingNumber_le_components` gives
  `τ ≤ r`, so `finrank_span_collisionCone_ge_hitting` refines the universal bound
  `k - r` of the previous file.

-- !-- Lab Notes -- !--
Hypothesis: the dimension of a coordinate collision cone is governed by the
combinatorics of the active sets `Act A m i`, via a Hall-type (transversal)
condition.
Experiment: computing with `k = r = 2` and the key `A i j = if j = 0 then 0 else 1`
at the zero message gives `Act A m 0 = Act A m 1 = {0}`, a family with *no* system
of distinct representatives, yet `S = {1}` is a legal collision support.
Analysis: the correct combinatorial invariant is the minimum size `τ` of a set
meeting every active set (a hitting set / vertex cover of the hypergraph of active
sets), and the maximal coordinate-cone dimension is `k - τ`.  Since `τ ≤ r` always
(pick one active coordinate per component), the criterion refines the universal
bound `k - r` of the previous file, and it is strictly better exactly when the
active sets overlap.
Critique: the equivalence is stated with an explicit hitting set rather than with
`τ`, to avoid an unnecessary minimisation; the failure of the SDR formulation is
recorded as a theorem, not as a remark.
-- !-- end Lab Notes -- !--
-/

noncomputable section

namespace TropicalRecession

variable {k r : ℕ} [Nonempty (Fin k)]

/-- The set of active (minimizing) coordinates of digest component `i` at `m`. -/
def Act (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (i : Fin r) : Set (Fin k) :=
  {j | m j + A i j = digest A m i}

lemma mem_Act_iff {A : Fin r → Fin k → ℝ} {m : Fin k → ℝ} {i : Fin r} {j : Fin k} :
    j ∈ Act A m i ↔ m j + A i j = digest A m i := Iff.rfl

lemma Act_nonempty (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) (i : Fin r) :
    (Act A m i).Nonempty := exists_argmin A m i

/-- **Exact local criterion.**  Raising all coordinates in `S` (by arbitrary
nonnegative amounts) never changes the digest precisely when every component
retains an active coordinate outside `S`. -/
theorem isCollisionSupport_iff (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ)
    (S : Finset (Fin k)) :
    IsCollisionSupport A m S ↔ ∀ i, ∃ j ∉ S, j ∈ Act A m i := by
  constructor
  · intro hS i
    by_contra hcon
    push_neg at hcon
    -- every active coordinate of component `i` lies in `S`; a small uniform bump
    -- on `S` then strictly raises component `i`.
    set c : ℝ := digest A m i with hc
    set e : ℝ := Finset.univ.inf' Finset.univ_nonempty
      (fun j => if j ∈ S then (1:ℝ) else min 1 (m j + A i j - c)) with he
    have hepos : 0 < e := by
      rw [he]
      refine (Finset.lt_inf'_iff _).mpr ?_
      intro j _
      by_cases hj : j ∈ S
      · simp [hj]
      · have h1 : c ≤ m j + A i j := digest_le A m i j
        have h2 : m j + A i j ≠ c := hcon j hj
        simp only [hj, if_false]
        exact lt_min zero_lt_one (by cases lt_or_eq_of_le h1 with
          | inl h => linarith
          | inr h => exact absurd h.symm h2)
    have hele : ∀ j ∉ S, e ≤ m j + A i j - c := by
      intro j hj
      have hb := Finset.inf'_le (f := fun j => if j ∈ S then (1:ℝ)
        else min 1 (m j + A i j - c)) (Finset.mem_univ j)
      simp only [hj, if_false] at hb
      exact le_trans hb (min_le_right _ _)
    set t : Fin k → ℝ := fun j => if j ∈ S then e else 0 with ht
    have htnonneg : ∀ j, 0 ≤ t j := by
      intro j; rw [ht]; by_cases hj : j ∈ S <;> simp [hj, le_of_lt hepos]
    have htsupp : ∀ j ∉ S, t j = 0 := by intro j hj; simp [ht, hj]
    have hbound : ∀ j, c + e ≤ (m + t) j + A i j := by
      intro j
      simp only [Pi.add_apply, ht]
      by_cases hj : j ∈ S
      · have := digest_le A m i j
        simp only [hj, if_true]
        linarith
      · have := hele j hj
        simp only [hj, if_false]
        linarith
    have hfin := le_digest (A := A) (m := m + t) (i := i) hbound
    rw [congrFun (hS t htnonneg htsupp) i] at hfin
    linarith
  · intro h t ht htS
    funext i
    obtain ⟨j, hjS, hj⟩ := h i
    exact digest_add_eq A m t ht i hj (htS j hjS)

/-- Any collision support of size `c` produces a `c`-dimensional cone of collisions
inside the fiber. -/
theorem card_le_finrank_span_collisionCone {A : Fin r → Fin k → ℝ} {m : Fin k → ℝ}
    {S : Finset (Fin k)} (hS : IsCollisionSupport A m S) :
    S.card ≤ Module.finrank ℝ (Submodule.span ℝ (collisionCone A m)) := by
  have hmono : suppSub S ≤ Submodule.span ℝ (collisionCone A m) := by
    rw [← span_coneOn S]
    exact Submodule.span_mono (coneOn_subset_collisionCone hS)
  have hfr := Submodule.finrank_mono hmono
  rwa [finrank_suppSub] at hfr

/-- **Hall-type criterion (corrected form).**  A coordinate collision cone of
dimension at least `d` exists if and only if the family of active sets admits a
hitting set of cardinality at most `k - d`. -/
theorem exists_collisionSupport_card_iff (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ)
    {d : ℕ} (hd : d ≤ k) :
    (∃ S : Finset (Fin k), d ≤ S.card ∧ IsCollisionSupport A m S) ↔
      (∃ H : Finset (Fin k), H.card ≤ k - d ∧ ∀ i, ∃ j ∈ H, j ∈ Act A m i) := by
  constructor
  · rintro ⟨S, hScard, hS⟩
    refine ⟨Sᶜ, ?_, fun i => ?_⟩
    · rw [Finset.card_compl]
      simp only [Fintype.card_fin]
      omega
    · obtain ⟨j, hjS, hj⟩ := (isCollisionSupport_iff A m S).mp hS i
      exact ⟨j, Finset.mem_compl.mpr hjS, hj⟩
  · rintro ⟨H, hHcard, hH⟩
    refine ⟨Hᶜ, ?_, (isCollisionSupport_iff A m Hᶜ).mpr fun i => ?_⟩
    · rw [Finset.card_compl]
      simp only [Fintype.card_fin]
      omega
    · obtain ⟨j, hjH, hj⟩ := hH i
      exact ⟨j, by simpa using hjH, hj⟩

/-- **The SDR formulation of the criterion is false.**  For `k = r = 2` and the key
`A i j = if j = 0 then 0 else 1` at the zero message, both components have the
single active coordinate `0`, so the active family has no system of distinct
representatives; nevertheless `{1}` is a collision support, giving a
one-dimensional collision cone.  Hence transversals (SDRs) do *not* control the
dimension of the collision cone — hitting sets do. -/
theorem sdr_criterion_counterexample :
    ∃ (A : Fin 2 → Fin 2 → ℝ) (m : Fin 2 → ℝ),
      (¬ ∃ f : Fin 2 → Fin 2, Function.Injective f ∧ ∀ i, f i ∈ Act A m i) ∧
      (∃ S : Finset (Fin 2), 1 ≤ S.card ∧ IsCollisionSupport A m S) := by
  set A0 : Fin 2 → Fin 2 → ℝ := fun _ j => if j = 0 then 0 else 1 with hA0
  have hd : ∀ i : Fin 2, digest A0 (0 : Fin 2 → ℝ) i = 0 := by
    intro i
    refine le_antisymm ?_ (le_digest fun j => ?_)
    · have h := digest_le A0 (0 : Fin 2 → ℝ) i 0
      simpa [hA0] using h
    · by_cases hj : j = 0 <;> simp [hA0, hj]
  have hact0 : ∀ i : Fin 2, (0 : Fin 2) ∈ Act A0 (0 : Fin 2 → ℝ) i := by
    intro i
    rw [mem_Act_iff, hd]
    simp [hA0]
  refine ⟨A0, (0 : Fin 2 → ℝ), ?_, ?_⟩
  · rintro ⟨f, hfinj, hf⟩
    have h0 : f 0 = 0 := by
      have h := hf 0
      rw [mem_Act_iff, hd] at h
      by_contra hne
      simp [hA0, hne] at h
    have h1 : f 1 = 0 := by
      have h := hf 1
      rw [mem_Act_iff, hd] at h
      by_contra hne
      simp [hA0, hne] at h
    have hcontra : (0 : Fin 2) = 1 := hfinj (by rw [h0, h1])
    simp at hcontra
  · exact ⟨{1}, by simp, (isCollisionSupport_iff _ _ _).mpr
      fun i => ⟨(0 : Fin 2), by simp, hact0 i⟩⟩

/-! ## The exact coordinate-cone dimension `k - τ` -/

/-- The *hitting number* `τ(A, m)`: the least size of a set of coordinates meeting
every active set.  It is the true security parameter of the digest at `m`. -/
def hittingNumber (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) : ℕ :=
  sInf {n | ∃ H : Finset (Fin k), H.card = n ∧ ∀ i, ∃ j ∈ H, j ∈ Act A m i}

lemma hittingNumber_le {A : Fin r → Fin k → ℝ} {m : Fin k → ℝ} {H : Finset (Fin k)}
    (hH : ∀ i, ∃ j ∈ H, j ∈ Act A m i) : hittingNumber A m ≤ H.card :=
  Nat.sInf_le ⟨H, rfl, hH⟩

lemma exists_hitting_card_eq (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    ∃ H : Finset (Fin k), H.card = hittingNumber A m ∧ ∀ i, ∃ j ∈ H, j ∈ Act A m i := by
  have hne : {n | ∃ H : Finset (Fin k), H.card = n ∧ ∀ i, ∃ j ∈ H, j ∈ Act A m i}.Nonempty := by
    refine ⟨(Finset.univ : Finset (Fin k)).card, Finset.univ, rfl, fun i => ?_⟩
    obtain ⟨j, hj⟩ := Act_nonempty A m i
    exact ⟨j, Finset.mem_univ j, hj⟩
  exact Nat.sInf_mem hne

/-- The hitting number never exceeds the number of digest components. -/
theorem hittingNumber_le_components (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    hittingNumber A m ≤ r := by
  choose p hp using exists_argmin A m
  refine le_trans (hittingNumber_le (H := Finset.image p Finset.univ) fun i =>
    ⟨p i, Finset.mem_image_of_mem p (Finset.mem_univ i), hp i⟩) ?_
  calc (Finset.image p Finset.univ).card ≤ (Finset.univ : Finset (Fin r)).card :=
    Finset.card_image_le
  _ = r := by simp

/-- **The maximal coordinate collision cone has dimension exactly `k - τ`.**
Every collision support has size at most `k - τ`, and this size is attained. -/
theorem isGreatest_collisionSupport_card (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    IsGreatest {n | ∃ S : Finset (Fin k), S.card = n ∧ IsCollisionSupport A m S}
      (k - hittingNumber A m) := by
  constructor
  · obtain ⟨H, hHcard, hH⟩ := exists_hitting_card_eq A m
    refine ⟨Hᶜ, ?_, (isCollisionSupport_iff A m Hᶜ).mpr fun i => ?_⟩
    · rw [Finset.card_compl, hHcard, Fintype.card_fin]
    · obtain ⟨j, hjH, hj⟩ := hH i
      exact ⟨j, by simpa using hjH, hj⟩
  · rintro n ⟨S, rfl, hS⟩
    have hhit : ∀ i, ∃ j ∈ Sᶜ, j ∈ Act A m i := by
      intro i
      obtain ⟨j, hjS, hj⟩ := (isCollisionSupport_iff A m S).mp hS i
      exact ⟨j, Finset.mem_compl.mpr hjS, hj⟩
    have h1 : hittingNumber A m ≤ Sᶜ.card := hittingNumber_le hhit
    have h2 : Sᶜ.card = k - S.card := by
      rw [Finset.card_compl, Fintype.card_fin]
    have h3 : S.card ≤ k := by simpa using Finset.card_le_univ S
    omega

/-- Consequently the recession cone of the fiber has dimension at least `k - τ`,
which refines the universal bound `k - r`. -/
theorem finrank_span_collisionCone_ge_hitting (A : Fin r → Fin k → ℝ) (m : Fin k → ℝ) :
    k - hittingNumber A m ≤ Module.finrank ℝ (Submodule.span ℝ (collisionCone A m)) := by
  obtain ⟨S, hScard, hS⟩ := (isGreatest_collisionSupport_card A m).1
  rw [← hScard]
  exact card_le_finrank_span_collisionCone hS

end TropicalRecession