import Mathlib
import Tropical.OrbitDialInformation

/-!
# The whole exceeds the sum: emergence in the composite type channel

This file is the abstract half of **COMPOSITE-DIAL** (FACT round-35 #4, paper 125,
verdict *THE-WHOLE-EXCEEDS-THE-SUM*).  The measured phenomenon is an *emergence*
effect: several irreducible components each carry (essentially) zero information
about a target, while their composite label carries a positive amount.

We build on the finite-alphabet mutual information `OrbitDialCap.Info.mutualInfo`
of `Tropical.OrbitDialInformation`, lifting it from joint tables to *observables on a
probability space*:

* `CompositeDial.jointLaw μ X Y` is the joint table of two observables `X, Y` on a
  finite sample space `Ω` carrying the weights `μ`;
* `CompositeDial.info μ X Y` is its mutual information.

## Main results

* `mutualInfo_eq_zero_of_const` — a normalised joint table that does not depend on the
  label coordinate has zero mutual information.
* `info_eq_zero_of_swap` — **the fibre-swap criterion**: if for all label values
  `b, b'` there is a `μ`-preserving bijection of `Ω` that fixes `X` and carries the
  label fibre `{Y = b}` onto `{Y = b'}`, then `X` carries exactly zero information
  about `Y`.
* `info_eq_log_card_of_determined` — if the label `Y` is a function of `X` and the label
  has label swaps, then `X` carries exactly `log |β|` nats about `Y`.
* `proper_subfamily_blind` / `whole_carries_log_card` — for `k` independent uniform
  components in a finite abelian group `A` with composite label the sum, **every proper
  subfamily of components is blind** (zero information), while the whole family carries
  `log |A|`.
* `whole_exceeds_sum` — the synergy `I(whole; L) - ∑ᵢ I(Xᵢ; L)` equals `log |A| > 0`
  as soon as `k ≥ 2`, while `single_component_not_emergent` shows that for `k = 1` there
  is no emergence: the single component already carries everything.
-/

namespace CompositeDial

open Finset OrbitDialCap.Info

section General

variable {Ω α β : Type*} [Fintype Ω] [Fintype α] [Fintype β]

/-- The joint table of two observables `X : Ω → α`, `Y : Ω → β` under the weights `μ`. -/
noncomputable def jointLaw (μ : Ω → ℝ) (X : Ω → α) (Y : Ω → β) : α → β → ℝ :=
  open Classical in fun a b => ∑ ω, if X ω = a ∧ Y ω = b then μ ω else 0

/-- Mutual information (in nats) between two observables. -/
noncomputable def info (μ : Ω → ℝ) (X : Ω → α) (Y : Ω → β) : ℝ :=
  mutualInfo (jointLaw μ X Y)

omit [Fintype α] [Fintype β] in
lemma jointLaw_nonneg {μ : Ω → ℝ} (hμ0 : ∀ ω, 0 ≤ μ ω) (X : Ω → α) (Y : Ω → β) (a : α)
    (b : β) : 0 ≤ jointLaw μ X Y a b := by
  classical
  unfold jointLaw
  exact Finset.sum_nonneg fun ω _ => by split_ifs <;> simp [hμ0 ω]

lemma jointLaw_total (μ : Ω → ℝ) (X : Ω → α) (Y : Ω → β) :
    ∑ a, ∑ b, jointLaw μ X Y a b = ∑ ω, μ ω := by
  classical
  unfold jointLaw
  calc ∑ a, ∑ b, ∑ ω, (if X ω = a ∧ Y ω = b then μ ω else 0)
      = ∑ a, ∑ ω, ∑ b, (if X ω = a ∧ Y ω = b then μ ω else 0) := by
        refine Finset.sum_congr rfl fun a _ => Finset.sum_comm
    _ = ∑ ω, ∑ a, ∑ b, (if X ω = a ∧ Y ω = b then μ ω else 0) := Finset.sum_comm
    _ = ∑ ω, μ ω := by
        refine Finset.sum_congr rfl fun ω _ => ?_
        simp [ite_and]

/-- A normalised joint table that is constant in the label coordinate has zero mutual
information: the label is independent of the observable. -/
theorem mutualInfo_eq_zero_of_const (p : α → β → ℝ) (htot : ∑ a, ∑ b, p a b = 1)
    (hconst : ∀ a b b', p a b = p a b') : mutualInfo p = 0 := by
  classical
  rcases isEmpty_or_nonempty β with hβ | ⟨⟨b₀⟩⟩
  · simp [mutualInfo]
  set M : ℝ := ∑ a, p a b₀ with hM
  have hY : ∀ b, marginalY p b = M := fun b => by
    simp only [marginalY, hM]; exact Finset.sum_congr rfl fun a _ => hconst a b b₀
  have hX : ∀ a b, marginalX p a = (Fintype.card β : ℝ) * p a b := fun a b => by
    simp only [marginalX]
    rw [Finset.sum_congr rfl fun b' _ => hconst a b' b]
    simp
  have hcardM : (Fintype.card β : ℝ) * M = 1 := by
    have h2 : ∑ b, ∑ a, p a b = ∑ _b : β, M := Finset.sum_congr rfl fun b _ => hY b
    rw [← htot, Finset.sum_comm, h2]
    simp
  unfold mutualInfo
  refine Finset.sum_eq_zero fun a _ => Finset.sum_eq_zero fun b _ => ?_
  rw [hX a b, hY b]
  by_cases hp : p a b = 0
  · simp [hp]
  · have : p a b / ((Fintype.card β : ℝ) * p a b * M) = 1 := by
      rw [mul_comm (Fintype.card β : ℝ), mul_assoc, hcardM, mul_one, div_self hp]
    rw [this, Real.log_one, mul_zero]

omit [Fintype α] [Fintype β] in
/-- Reindexing a joint-law entry along a fibre swap. -/
lemma jointLaw_swap {μ : Ω → ℝ} {X : Ω → α} {Y : Ω → β} {b b' : β} (τ : Ω ≃ Ω)
    (hμ : ∀ ω, μ (τ ω) = μ ω) (hX : ∀ ω, X (τ ω) = X ω) (hY : ∀ ω, Y (τ ω) = b' ↔ Y ω = b)
    (a : α) : jointLaw μ X Y a b' = jointLaw μ X Y a b := by
  classical
  unfold jointLaw
  rw [← Equiv.sum_comp τ]
  refine Finset.sum_congr rfl fun ω _ => ?_
  simp only [hμ, hX, hY]

/-- **Fibre-swap criterion.**  If every pair of label fibres can be exchanged by a
`μ`-preserving bijection fixing the observable `X`, then `X` carries zero information
about the label. -/
theorem info_eq_zero_of_swap {μ : Ω → ℝ} {X : Ω → α} {Y : Ω → β} (hμ : ∑ ω, μ ω = 1)
    (hswap : ∀ b b', ∃ τ : Ω ≃ Ω, (∀ ω, μ (τ ω) = μ ω) ∧ (∀ ω, X (τ ω) = X ω) ∧
      (∀ ω, Y (τ ω) = b' ↔ Y ω = b)) :
    info μ X Y = 0 := by
  refine mutualInfo_eq_zero_of_const _ (by rw [jointLaw_total, hμ]) fun a b b' => ?_
  obtain ⟨τ, h1, h2, h3⟩ := hswap b b'
  exact (jointLaw_swap τ h1 h2 h3 a).symm

/-- Under label swaps, the label is uniformly distributed. -/
lemma label_mass_uniform {μ : Ω → ℝ} {Y : Ω → β} [DecidableEq β] (hμ : ∑ ω, μ ω = 1)
    (hswap : ∀ b b', ∃ τ : Ω ≃ Ω, (∀ ω, μ (τ ω) = μ ω) ∧ (∀ ω, Y (τ ω) = b' ↔ Y ω = b))
    (b : β) : (∑ ω, if Y ω = b then μ ω else 0) = 1 / Fintype.card β := by
  classical
  set ν : β → ℝ := fun b => ∑ ω, if Y ω = b then μ ω else 0 with hν
  have hconst : ∀ b b', ν b' = ν b := fun b b' => by
    obtain ⟨τ, h1, h3⟩ := hswap b b'
    simp only [hν]
    rw [← Equiv.sum_comp τ]
    exact Finset.sum_congr rfl fun ω _ => by simp only [h1, h3]
  have htot : ∑ b', ν b' = 1 := by
    rw [← hμ, hν, Finset.sum_comm]
    refine Finset.sum_congr rfl fun ω _ => ?_
    simp
  have : (Fintype.card β : ℝ) * ν b = 1 := by
    rw [← htot, Finset.sum_congr rfl fun b' _ => hconst b b']
    simp
  have hc : (Fintype.card β : ℝ) ≠ 0 := by
    intro h; rw [h, zero_mul] at this; exact zero_ne_one this
  change ν b = _
  field_simp
  linarith

/-- **Determined labels carry the full label entropy.**  If the label `Y` is a function
`φ ∘ X` of the observable and the label fibres can be swapped measure-preservingly, then
`X` carries exactly `log |β|` nats about `Y`. -/
theorem info_eq_log_card_of_determined {μ : Ω → ℝ} {X : Ω → α} {Y : Ω → β}
    (hμ : ∑ ω, μ ω = 1) (φ : α → β) (hdet : ∀ ω, Y ω = φ (X ω))
    (hswap : ∀ b b', ∃ τ : Ω ≃ Ω, (∀ ω, μ (τ ω) = μ ω) ∧ (∀ ω, Y (τ ω) = b' ↔ Y ω = b)) :
    info μ X Y = Real.log (Fintype.card β) := by
  classical
  set m : α → ℝ := fun a => ∑ ω, if X ω = a then μ ω else 0 with hm
  have hjoint : ∀ a b, jointLaw μ X Y a b = if φ a = b then m a else 0 := fun a b => by
    simp only [jointLaw, hm]
    split_ifs with h
    · refine Finset.sum_congr rfl fun ω _ => ?_
      by_cases hx : X ω = a
      · simp [hx, hdet, h]
      · simp [hx]
    · refine Finset.sum_eq_zero fun ω _ => ?_
      by_cases hx : X ω = a
      · have : Y ω ≠ b := by rw [hdet, hx]; exact h
        simp [this]
      · simp [hx]
  have hmX : ∀ a, marginalX (jointLaw μ X Y) a = m a := fun a => by
    simp [marginalX, hjoint]
  have hmY : ∀ b, marginalY (jointLaw μ X Y) b = 1 / Fintype.card β := fun b => by
    rw [← label_mass_uniform hμ hswap b, marginalY]
    calc ∑ a, jointLaw μ X Y a b = ∑ a, ∑ ω, if X ω = a ∧ Y ω = b then μ ω else 0 := rfl
      _ = ∑ ω, ∑ a, if X ω = a ∧ Y ω = b then μ ω else 0 := Finset.sum_comm
      _ = _ := Finset.sum_congr rfl fun ω _ => by simp [ite_and]
  have hm_tot : ∑ a, m a = 1 := by
    rw [← hμ, hm, Finset.sum_comm]
    exact Finset.sum_congr rfl fun ω _ => by simp
  have hcard : (Fintype.card β : ℝ) ≠ 0 := by
    have hne : Nonempty Ω := by
      by_contra hn
      rw [not_nonempty_iff] at hn
      simp at hμ
    obtain ⟨ω⟩ := hne
    haveI : Nonempty β := ⟨Y ω⟩
    exact_mod_cast Fintype.card_ne_zero
  unfold info mutualInfo
  have hterm : ∀ a, ∑ b, jointLaw μ X Y a b *
      Real.log (jointLaw μ X Y a b /
        (marginalX (jointLaw μ X Y) a * marginalY (jointLaw μ X Y) b)) =
      m a * Real.log (Fintype.card β) := fun a => by
    simp only [hmX, hmY, hjoint]
    rw [Finset.sum_eq_single (φ a)]
    · simp only [if_true]
      by_cases hma : m a = 0
      · simp [hma]
      · congr 1
        congr 1
        field_simp
    · intro b _ hb; simp [Ne.symm hb]
    · simp
  rw [Finset.sum_congr rfl fun a _ => hterm a, ← Finset.sum_mul, hm_tot, one_mul]

end General

section Emergence

variable {A : Type*} [AddCommGroup A] [Fintype A] {k : ℕ}

/-- The uniform law on `k`-tuples of components in `A`. -/
noncomputable def uniformLaw (A : Type*) [Fintype A] (k : ℕ) : (Fin k → A) → ℝ :=
  fun _ => 1 / (Fintype.card A : ℝ) ^ k

/-- The composite label: the sum of the components. -/
def compositeLabel (ω : Fin k → A) : A := ∑ i, ω i

/-- The sub-observable recording only the components in `S`. -/
def restrictTo (S : Finset (Fin k)) (ω : Fin k → A) : S → A := fun i => ω i

lemma uniformLaw_total : ∑ ω : Fin k → A, uniformLaw A k ω = 1 := by
  have h : (Fintype.card A : ℝ) ^ k ≠ 0 := pow_ne_zero _ (by exact_mod_cast Fintype.card_ne_zero)
  simp [uniformLaw, h]

lemma uniformLaw_nonneg (ω : Fin k → A) : 0 ≤ uniformLaw A k ω := by
  unfold uniformLaw; positivity

omit [Fintype A] in
lemma compositeLabel_shift (ω : Fin k → A) (j : Fin k) (c : A) :
    compositeLabel (ω + Pi.single j c) = compositeLabel ω + c := by
  simp [compositeLabel, Finset.sum_add_distrib]

omit [Fintype A] in
/-- The translation in coordinate `j` swaps label fibres `b ↦ b'`. -/
lemma shift_swaps (j : Fin k) (b b' : A) (ω : Fin k → A) :
    compositeLabel ((Equiv.addRight (Pi.single j (b' - b) : Fin k → A)) ω) = b' ↔
      compositeLabel ω = b := by
  simp only [Equiv.coe_addRight, compositeLabel_shift]
  constructor <;> intro h
  · have := congrArg (· - (b' - b)) h; simpa using this
  · rw [h]; abel

/-- **Every proper subfamily is blind.**  For independent uniform components and the
composite (sum) label, the components indexed by any proper subset `S` carry exactly zero
information about the label. -/
theorem proper_subfamily_blind (S : Finset (Fin k)) (hS : S ≠ Finset.univ) :
    info (uniformLaw A k) (restrictTo S) compositeLabel = 0 := by
  obtain ⟨j, hj⟩ : ∃ j, j ∉ S := by
    by_contra h; push_neg at h; exact hS (Finset.eq_univ_iff_forall.mpr h)
  refine info_eq_zero_of_swap uniformLaw_total fun b b' => ?_
  refine ⟨Equiv.addRight (Pi.single j (b' - b)), fun _ => rfl, fun ω => ?_, shift_swaps j b b'⟩
  funext i
  have : (i : Fin k) ≠ j := fun h => hj (h ▸ i.2)
  simp [restrictTo, this]

/-- **The whole carries everything.**  For `k ≥ 1` components, the full tuple carries
`log |A|` nats about the composite label. -/
theorem whole_carries_log_card (hk : k ≠ 0) :
    info (uniformLaw A k) id (compositeLabel (A := A) (k := k)) =
      Real.log (Fintype.card A) := by
  refine info_eq_log_card_of_determined uniformLaw_total
    compositeLabel (fun _ => rfl) fun b b' => ?_
  exact ⟨Equiv.addRight (Pi.single ⟨0, Nat.pos_of_ne_zero hk⟩ (b' - b)), fun _ => rfl,
    shift_swaps _ b b'⟩

/-- A single component, as an observable. -/
def component (i : Fin k) (ω : Fin k → A) : A := ω i

/-- With at least two components, each single component is blind to the label. -/
theorem component_blind (hk : 2 ≤ k) (i : Fin k) :
    info (uniformLaw A k) (component i) compositeLabel = 0 := by
  obtain ⟨j, hj⟩ : ∃ j : Fin k, j ≠ i := by
    by_cases h : (i : ℕ) = 0
    · exact ⟨⟨1, by omega⟩, fun h' => by rw [← h'] at h; simp at h⟩
    · exact ⟨⟨0, by omega⟩, fun h' => by rw [← h'] at h; simp at h⟩
  refine info_eq_zero_of_swap uniformLaw_total fun b b' => ?_
  refine ⟨Equiv.addRight (Pi.single j (b' - b)), fun _ => rfl, fun ω => ?_, shift_swaps j b b'⟩
  simp [component, Ne.symm hj]

/-- **THE-WHOLE-EXCEEDS-THE-SUM.**  For `k ≥ 2` independent uniform components the synergy
`I(whole; L) - ∑ᵢ I(Xᵢ; L)` equals `log |A|`, which is strictly positive for nontrivial
`A`. -/
theorem whole_exceeds_sum (hk : 2 ≤ k) (hA : 1 < Fintype.card A) :
    info (uniformLaw A k) id (compositeLabel (A := A) (k := k)) -
        ∑ i, info (uniformLaw A k) (component i) compositeLabel = Real.log (Fintype.card A) ∧
      ∑ i, info (uniformLaw A k) (component i) compositeLabel <
        info (uniformLaw A k) id (compositeLabel (A := A) (k := k)) := by
  have hsum : ∑ i, info (uniformLaw A k) (component i) (compositeLabel (A := A)) = 0 :=
    Finset.sum_eq_zero fun i _ => component_blind hk i
  have hk0 : k ≠ 0 := by omega
  rw [hsum, whole_carries_log_card hk0]
  refine ⟨by ring, Real.log_pos (by exact_mod_cast hA)⟩

/-- **No emergence with one component.**  For `k = 1` the single component already
carries the full `log |A|` nats: emergence requires at least two irreducible parts. -/
theorem single_component_not_emergent :
    info (uniformLaw A 1) (component 0) (compositeLabel (A := A) (k := 1)) =
      Real.log (Fintype.card A) := by
  refine info_eq_log_card_of_determined uniformLaw_total id
    (fun ω => by simp [compositeLabel, component]) fun b b' => ?_
  exact ⟨Equiv.addRight (Pi.single 0 (b' - b)), fun _ => rfl, shift_swaps _ b b'⟩

/-- **Emergence dichotomy.**  For nontrivial `A` and `k ≥ 1`, a single component is blind
to the composite label if and only if there are at least two components. -/
theorem component_blind_iff (hA : 1 < Fintype.card A) (hk : 1 ≤ k) (i : Fin k) :
    info (uniformLaw A k) (component i) (compositeLabel (A := A)) = 0 ↔ 2 ≤ k := by
  refine ⟨fun h => ?_, fun h => component_blind h i⟩
  by_contra hlt
  have hk1 : k = 1 := by omega
  subst hk1
  have hi : i = 0 := Subsingleton.elim _ _
  subst hi
  rw [single_component_not_emergent] at h
  exact (Real.log_pos (by exact_mod_cast hA)).ne' h

end Emergence

end CompositeDial