/-
# NET-74, third cycle: the knee and the participation ratio

The tail analysis of `Physics/NET74TailMechanism.lean` shows the knee is a
functional of the residual curve and is not constrained by head mass.  What, if
anything, *does* constrain it from a single scalar?  This file answers that in
the `ℓ²` language physicists use for localisation: the **collision mass**
(inverse participation ratio) of the retained keys,

`collisionMass P k = ∑_{j<k} (mass of key j)²`,

whose reciprocal `1/C` is the effective number of participating keys.

* `sq_cum_le_card_mul_collision` — Cauchy–Schwarz on the capture curve:
  `(cum k)² ≤ k · collisionMass P k`.
* `knee_sq_le_mul_collision`, `knee_ge_of_collision_bound` — hence
  `k* ≥ τ² / C` whenever the collision mass never exceeds `C`.  A domain whose
  attention is spread over many keys *must* have a large knee.
* `collision_le_of_step_le` — the collision mass is bounded by the largest
  single-key mass, so this refines, rather than replaces, the `k* ≥ τ/m`
  concentration law of `Applications/NET73KneeDecoupling.lean`.
* `collision_uniform_eq`, `uniform_attains_participation_bound` — the bound is
  attained exactly: the uniform domain has `collisionMass = τ²/k` at its knee
  `k`, turning the Cauchy–Schwarz inequality into an equality.
* `collision_does_not_bound_knee_above` — and it is one-sided: for every
  collision budget `C > 0` and every `N` there is a domain with collision mass
  never above `C` and knee at least `N`.

Together: the participation ratio pins the knee from below and not at all from
above.  Every scalar concentration statistic of the head — top-8 mass, entropy,
collision mass — can only bound `k*` on one side; where in `[τ²/C, ∞)` the knee
actually falls is decided by the tail, which is the NET-74 mechanism claim in
`ℓ²` form.
-/
import Mathlib
import Applications.NET73KneeDecoupling

namespace Catalog.NET74IPR

open Finset Catalog.NET73

variable (P : AttentionProfile)

/-! ## 1. Key masses and the collision mass -/

/-- The attention mass carried by the `j`-th heaviest key. -/
def keyMass (j : ℕ) : ℚ := P.cum (j + 1) - P.cum j

/-- The collision mass (inverse participation ratio) of the `k` heaviest keys.
Its reciprocal is the effective number of keys carrying the attention. -/
def collisionMass (k : ℕ) : ℚ := ∑ j ∈ range k, (keyMass P j) ^ 2

lemma keyMass_nonneg (j : ℕ) : 0 ≤ keyMass P j :=
  sub_nonneg.mpr (P.cum_mono (Nat.le_succ j))

lemma sum_keyMass (k : ℕ) : ∑ j ∈ range k, keyMass P j = P.cum k := by
  simpa [keyMass, P.cum_zero] using Finset.sum_range_sub (f := P.cum) k

/-- **Cauchy–Schwarz on the capture curve.**  The mass captured by `k` keys is
controlled by their collision mass. -/
theorem sq_cum_le_card_mul_collision (k : ℕ) :
    (P.cum k) ^ 2 ≤ (k : ℚ) * collisionMass P k := by
  have h := sq_sum_le_card_mul_sum_sq (s := range k) (f := keyMass P)
  rw [sum_keyMass] at h
  simpa [collisionMass, Finset.card_range] using h

/-- **The participation bound on the knee.** -/
theorem knee_sq_le_mul_collision {τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) :
    τ ^ 2 ≤ (P.kneeAt τ : ℚ) * collisionMass P (P.kneeAt τ) := by
  have h1 : τ ≤ P.cum (P.kneeAt τ) := P.kneeAt_spec hτ1
  have h2 : τ ^ 2 ≤ (P.cum (P.kneeAt τ)) ^ 2 := by nlinarith
  exact h2.trans (sq_cum_le_card_mul_collision P _)

/-- **`k* ≥ τ²/C`.**  A domain whose attention never concentrates more than `C`
of collision mass into the keys it retains needs at least `τ²/C` keys. -/
theorem knee_ge_of_collision_bound {τ C : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1)
    (hC : 0 < C) (hbound : ∀ k, collisionMass P k ≤ C) :
    τ ^ 2 / C ≤ (P.kneeAt τ : ℚ) := by
  have h := knee_sq_le_mul_collision P hτ0 hτ1
  have hk : (0 : ℚ) ≤ (P.kneeAt τ : ℚ) := by positivity
  have h2 : (P.kneeAt τ : ℚ) * collisionMass P (P.kneeAt τ) ≤ (P.kneeAt τ : ℚ) * C :=
    mul_le_mul_of_nonneg_left (hbound _) hk
  rw [div_le_iff₀ hC]
  nlinarith

/-- The collision mass is at most the largest single-key mass: the `ℓ²`
statistic refines the `ℓ^∞` concentration law rather than replacing it. -/
theorem collision_le_of_step_le {m : ℚ} (hm : 0 ≤ m) (hstep : ∀ j, keyMass P j ≤ m)
    (k : ℕ) : collisionMass P k ≤ m := by
  have h1 : collisionMass P k ≤ ∑ j ∈ range k, m * keyMass P j := by
    refine Finset.sum_le_sum (fun j _ => ?_)
    have h := keyMass_nonneg P j
    nlinarith [hstep j]
  have h2 : ∑ j ∈ range k, m * keyMass P j = m * P.cum k := by
    rw [← Finset.mul_sum, sum_keyMass]
  have h3 : m * P.cum k ≤ m * 1 := mul_le_mul_of_nonneg_left (P.cum_le_one k) hm
  linarith [h1, h2 ▸ h1, h3]

/-! ## 2. Tightness: the uniform domain attains the bound -/

private lemma min_one_add_le {x d : ℚ} (hd : 0 ≤ d) : min 1 (x + d) ≤ min 1 x + d := by
  rcases le_total x 1 with hx | hx
  · rcases le_total (x + d) 1 with hxd | hxd
    · rw [min_eq_right hxd, min_eq_right hx]
    · rw [min_eq_left hxd, min_eq_right hx]; linarith
  · rw [min_eq_left hx, min_eq_left (by linarith : (1:ℚ) ≤ x + d)]; linarith

/-- Every key of the uniform domain carries at most `τ/k`. -/
lemma keyMass_uniform_le {d τ : ℚ} {k : ℕ} (hτ : 0 < τ) (hk : 0 < k) (j : ℕ) :
    keyMass (uniformProfile d τ k hτ hk) j ≤ τ / k := by
  have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  have hcum : ∀ n : ℕ, (uniformProfile d τ k hτ hk).cum n = min 1 ((n : ℚ) * τ / k) :=
    fun _ => rfl
  have hsplit : ((j + 1 : ℕ) : ℚ) * τ / k = (j : ℚ) * τ / k + τ / k := by
    push_cast; ring
  rw [keyMass, hcum, hcum, hsplit]
  have := min_one_add_le (x := (j : ℚ) * τ / k) (d := τ / k) (by positivity)
  linarith

/-- Hence the uniform domain has collision mass at most `τ/k` at every prefix. -/
lemma collision_uniform_le {d τ : ℚ} {k : ℕ} (hτ : 0 < τ) (hk : 0 < k) (n : ℕ) :
    collisionMass (uniformProfile d τ k hτ hk) n ≤ τ / k := by
  have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  exact collision_le_of_step_le _ (by positivity) (keyMass_uniform_le hτ hk) n

/-- At its own knee the uniform domain has collision mass exactly `τ²/k`. -/
theorem collision_uniform_eq {d τ : ℚ} {k : ℕ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (hk : 0 < k) :
    collisionMass (uniformProfile d τ k hτ0 hk) k = τ ^ 2 / k := by
  have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  have hcum : ∀ n : ℕ, (uniformProfile d τ k hτ0 hk).cum n = min 1 ((n : ℚ) * τ / k) :=
    fun _ => rfl
  have hkey : ∀ j ∈ range k, keyMass (uniformProfile d τ k hτ0 hk) j = τ / k := by
    intro j hj
    have hjk : (j : ℚ) + 1 ≤ (k : ℚ) := by
      have : j + 1 ≤ k := Finset.mem_range.mp hj
      exact_mod_cast this
    have hj1 : ((j + 1 : ℕ) : ℚ) * τ / k ≤ 1 := by
      have h1 : ((j + 1 : ℕ) : ℚ) * τ ≤ (k : ℚ) * τ := by
        push_cast
        nlinarith
      rw [div_le_one hk']
      nlinarith
    have hj0 : (j : ℚ) * τ / k ≤ 1 := by
      have : (j : ℚ) * τ ≤ ((j + 1 : ℕ) : ℚ) * τ := by push_cast; nlinarith
      calc (j : ℚ) * τ / k ≤ ((j + 1 : ℕ) : ℚ) * τ / k := by gcongr
        _ ≤ 1 := hj1
    rw [keyMass, hcum, hcum, min_eq_right hj1, min_eq_right hj0]
    push_cast
    field_simp
    ring
  rw [collisionMass, Finset.sum_congr rfl (fun j hj => by rw [hkey j hj])]
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  field_simp

/-- **The participation bound is attained.**  For the uniform domain, whose knee
is `k`, Cauchy–Schwarz holds with equality: `τ² = k · (τ²/k)`. -/
theorem uniform_attains_participation_bound {d τ : ℚ} {k : ℕ} (hτ0 : 0 < τ)
    (hτ1 : τ < 1) (hk : 0 < k) :
    let P := uniformProfile d τ k hτ0 hk
    (P.kneeAt τ : ℚ) * collisionMass P (P.kneeAt τ) = τ ^ 2 := by
  intro P
  have hk' : (0 : ℚ) < (k : ℚ) := by exact_mod_cast hk
  have hknee : P.kneeAt τ = k := kneeAt_uniform hτ0 hτ1 hk
  rw [hknee, collision_uniform_eq hτ0 hτ1 hk]
  field_simp

/-! ## 3. One-sidedness: no upper bound from the participation ratio -/

/-- **The collision mass constrains the knee only from below.**  For every
collision budget `C > 0` and every target `N`, some domain keeps its collision
mass under `C` at every prefix and still has knee at least `N`.  A small
participation ratio is compatible with an arbitrarily late knee. -/
theorem collision_does_not_bound_knee_above {τ C : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1)
    (hC : 0 < C) (N : ℕ) :
    ∃ P : AttentionProfile, (∀ n, collisionMass P n ≤ C) ∧ N ≤ P.kneeAt τ := by
  obtain ⟨k, hk1, hkpos, hk2⟩ : ∃ k : ℕ, N ≤ k ∧ 0 < k ∧ τ / (k : ℚ) ≤ C := by
    obtain ⟨m, hm⟩ := exists_nat_gt (τ / C)
    refine ⟨max N (m + 1), le_max_left _ _,
      lt_of_lt_of_le (Nat.succ_pos m) (le_max_right _ _), ?_⟩
    have hmk : (m : ℚ) ≤ ((max N (m + 1) : ℕ) : ℚ) := by
      have : m ≤ max N (m + 1) := le_trans (Nat.le_succ m) (le_max_right _ _)
      exact_mod_cast this
    have hpos : (0 : ℚ) < ((max N (m + 1) : ℕ) : ℚ) := by
      have : 0 < max N (m + 1) := lt_of_lt_of_le (Nat.succ_pos m) (le_max_right _ _)
      exact_mod_cast this
    rw [div_le_iff₀ hpos]
    have h1 : τ / C < ((max N (m + 1) : ℕ) : ℚ) := lt_of_lt_of_le hm hmk
    rw [div_lt_iff₀ hC] at h1
    nlinarith
  refine ⟨uniformProfile 1 τ k hτ0 hkpos, fun n => ?_, ?_⟩
  · exact le_trans (collision_uniform_le hτ0 hkpos n) hk2
  · rw [kneeAt_uniform hτ0 hτ1 hkpos]; exact hk1

/-- **Cycle-3 verdict.**  The participation ratio gives a genuine, attained
lower bound on the knee and no upper bound whatsoever.  Every head statistic
that is a concentration functional behaves this way; only the shape of the tail
locates the knee inside the half-line the bound leaves open. -/
theorem participation_ratio_verdict {τ C : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (hC : 0 < C) :
    (∀ P : AttentionProfile, (∀ k, collisionMass P k ≤ C) → τ ^ 2 / C ≤ (P.kneeAt τ : ℚ)) ∧
    (∀ N : ℕ, ∃ P : AttentionProfile,
      (∀ n, collisionMass P n ≤ C) ∧ N ≤ P.kneeAt τ) :=
  ⟨fun P h => knee_ge_of_collision_bound P hτ0 hτ1 hC h,
    fun N => collision_does_not_bound_knee_above hτ0 hτ1 hC N⟩

end Catalog.NET74IPR