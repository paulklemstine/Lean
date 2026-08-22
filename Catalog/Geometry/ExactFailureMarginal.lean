/-
# Which marginals?  The exact failure law of the random codebook

Research thread *Compression Beyond the Pigeonhole Bound*, cycle v19c.

`Geometry.AlmostLosslessConverse` obtains `P[failure] ≥ k/(2M)` (for `2(k-1) ≤ M`)
by feeding two marginals into the Bonferroni inequality, and
`Geometry.BonferroniMarginals` improves this to the unconditional `k/(M+k-1)` by
feeding the *same* two marginals into the second-moment inequality.  Both are
lower bounds.  This file closes the question completely: the failure probability
of the uniform random codebook is *computed exactly*,

`P[failure] = 1 - (1 - 1/M)^k`,   `k = |S \ {x}|`,

and both the Shannon upper bound and a matching lower bound are then elementary
consequences.  The mechanism is a **conditional marginal principle**: the
collision event `H y = H x` has probability exactly `1/M` *conditionally on any
event that does not constrain the coordinate `y`*.  That is the precise sense in
which the almost-lossless analysis is a statement about marginals.

Main results.

* `ExactFailure.card_inter_collisionEvent_mul` — the **conditional collision
  marginal**: `M · |G ∩ {H : H y = H x}| = |G|` for every `G` unconstrained at
  `y` (`y ≠ x`).  A strict generalisation of
  `AlmostLossless.card_collisionEvent_mul` (take `G = univ`).
* `ExactFailure.card_noCollisionEvent_mul` — by induction along the competitors:
  `M^k · |{H : H y ≠ H x for all y ∈ D}| = (M-1)^k · M^{|α|}`, `k = |D|`.
* `ExactFailure.card_failSet_exact` — the **exact failure count**
  `M^k · |failSet| + (M-1)^k · M^{|α|} = M^k · M^{|α|}`.
* `ExactFailure.failure_prob_exact` — `P[failure] = 1 - (1 - 1/M)^k`.
* `ExactFailure.failure_prob_le_shannon` — recovers the random-coding bound
  `P[failure] ≤ k/M` (`AlmostLossless.failSet_prob_le`) from the exact law.
* `ExactFailure.failure_prob_ge_harmonic` — the matching lower bound
  `P[failure] ≥ k/(M+k)`, proved from the exact law by Bernoulli's inequality.
  Together the two show `P[failure] = Θ(k/M)` for **all** `k` and `M`.
-/
import Geometry.AlmostLosslessConverse

namespace ExactFailure

open Finset AlmostLossless

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {M : ℕ}

/-! ## 1. The conditional collision marginal -/

/-- `G` does not constrain the coordinate `y`: it is stable under arbitrary
overwriting of the `y`-th hash value. -/
def UnconstrainedAt (G : Finset (ι → Fin M)) (y : ι) : Prop :=
  ∀ (H : ι → Fin M) (v : Fin M), H ∈ G → Function.update H y v ∈ G

/-- **Conditional collision marginal.**  If the event `G` places no constraint on
the coordinate `y`, then conditionally on `G` the collision `H y = H x` still has
probability exactly `1/M`.  Taking `G = univ` recovers
`AlmostLossless.card_collisionEvent_mul`. -/
theorem card_inter_collisionEvent_mul {G : Finset (ι → Fin M)} {y x : ι}
    (hG : UnconstrainedAt G y) (hyx : y ≠ x) :
    M * (G ∩ collisionEvent M y x).card = G.card := by
  classical
  have hbij : ((G ∩ collisionEvent M y x) ×ˢ (univ : Finset (Fin M))).card = G.card := by
    apply Finset.card_bij (fun z _ => Function.update z.1 y z.2)
    · rintro ⟨K, v⟩ hz
      exact hG K v (Finset.mem_inter.1 (Finset.mem_product.1 hz).1).1
    · rintro ⟨K, v⟩ hz ⟨K', v'⟩ hz' heq
      have hKc : K y = K x := by
        have := (Finset.mem_inter.1 (Finset.mem_product.1 hz).1).2
        simpa [collisionEvent] using this
      have hKc' : K' y = K' x := by
        have := (Finset.mem_inter.1 (Finset.mem_product.1 hz').1).2
        simpa [collisionEvent] using this
      have hv : v = v' := by
        have := congrArg (fun f => f y) heq
        simpa using this
      have hoff : ∀ a, a ≠ y → K a = K' a := by
        intro a ha
        have := congrArg (fun f => f a) heq
        simpa [Function.update_apply, ha] using this
      have hKK : K = K' := by
        funext a
        rcases eq_or_ne a y with ha | ha
        · rw [ha, hKc, hKc', hoff x (Ne.symm hyx)]
        · exact hoff a ha
      simp [hKK, hv]
    · intro H hH
      refine ⟨(Function.update H y (H x), H y), ?_, ?_⟩
      · refine Finset.mem_product.2 ⟨Finset.mem_inter.2 ⟨hG H (H x) hH, ?_⟩, mem_univ _⟩
        simp only [collisionEvent, mem_filter, mem_univ, true_and]
        rw [Function.update_apply, Function.update_apply, if_pos rfl, if_neg (Ne.symm hyx)]
      · funext a
        rcases eq_or_ne a y with ha | ha
        · rw [ha]; simp
        · simp [ha]
  rw [Finset.card_product, Finset.card_univ, Fintype.card_fin] at hbij
  rw [← hbij]; ring

/-! ## 2. The no-collision event and its exact count -/

/-- The event that none of the competitors in `D` collides with `x`: the
complement of the failure event. -/
def noCollisionEvent (M : ℕ) (D : Finset ι) (x : ι) : Finset (ι → Fin M) :=
  univ.filter (fun H => ∀ y ∈ D, H y ≠ H x)

/-- The no-collision event of `D` places no constraint on a coordinate outside
`D ∪ {x}`. -/
theorem unconstrainedAt_noCollisionEvent {D : Finset ι} {x y : ι} (hyD : y ∉ D) (hyx : y ≠ x) :
    UnconstrainedAt (noCollisionEvent M D x) y := by
  intro H v hH
  simp only [noCollisionEvent, mem_filter, mem_univ, true_and] at hH ⊢
  intro z hz
  have hzy : z ≠ y := fun h => hyD (h ▸ hz)
  rw [Function.update_apply, Function.update_apply, if_neg hzy, if_neg (Ne.symm hyx)]
  exact hH z hz

/-- **One competitor at a time.**  Adding a fresh competitor `y` multiplies the
no-collision count by exactly `(M-1)/M`. -/
theorem card_noCollisionEvent_insert {D : Finset ι} {x y : ι} (hyD : y ∉ D) (hyx : y ≠ x) :
    M * (noCollisionEvent M (insert y D) x).card
      = (M - 1) * (noCollisionEvent M D x).card := by
  classical
  set G := noCollisionEvent M D x with hG
  have hsplit : noCollisionEvent M (insert y D) x = G \ (G ∩ collisionEvent M y x) := by
    ext H
    simp only [hG, noCollisionEvent, collisionEvent, Finset.mem_sdiff, Finset.mem_inter,
      mem_filter, mem_univ, true_and, Finset.mem_insert, not_and]
    constructor
    · intro h
      refine ⟨fun z hz => h z (Or.inr hz), ?_⟩
      intro _
      exact h y (Or.inl rfl)
    · rintro ⟨h1, h2⟩ z hz
      rcases hz with hz | hz
      · subst hz; exact h2 h1
      · exact h1 z hz
  have hsub : G ∩ collisionEvent M y x ⊆ G := Finset.inter_subset_left
  have hcard : (noCollisionEvent M (insert y D) x).card
      = G.card - (G ∩ collisionEvent M y x).card := by
    rw [hsplit, Finset.card_sdiff_of_subset hsub]
  have hcond : M * (G ∩ collisionEvent M y x).card = G.card :=
    card_inter_collisionEvent_mul (unconstrainedAt_noCollisionEvent hyD hyx) hyx
  rw [hcard, Nat.mul_sub, hcond, Nat.sub_mul, one_mul]

/-- **Exact count of the no-collision event.**  With `k = |D|` competitors and
`x ∉ D`, `M^k · |{H : H y ≠ H x for all y ∈ D}| = (M-1)^k · M^{|ι|}`, i.e. the
success probability of the random codebook is exactly `(1 - 1/M)^k`. -/
theorem card_noCollisionEvent_mul (x : ι) (D : Finset ι) (hx : x ∉ D) :
    M ^ D.card * (noCollisionEvent M D x).card
      = (M - 1) ^ D.card * M ^ Fintype.card ι := by
  classical
  induction D using Finset.induction_on with
  | empty =>
      have huniv : noCollisionEvent M (∅ : Finset ι) x = univ := by
        ext H; simp [noCollisionEvent]
      simp [huniv, Finset.card_univ]
  | insert y D hyD ih =>
      have hxD : x ∉ D := fun h => hx (Finset.mem_insert_of_mem h)
      have hyx : y ≠ x := by
        intro h
        exact hx (h ▸ Finset.mem_insert_self y D)
      have hstep := card_noCollisionEvent_insert (M := M) hyD hyx
      have hih := ih hxD
      rw [Finset.card_insert_of_notMem hyD, pow_succ, pow_succ]
      calc M ^ D.card * M * (noCollisionEvent M (insert y D) x).card
          = M ^ D.card * (M * (noCollisionEvent M (insert y D) x).card) := by ring
        _ = M ^ D.card * ((M - 1) * (noCollisionEvent M D x).card) := by rw [hstep]
        _ = (M - 1) * (M ^ D.card * (noCollisionEvent M D x).card) := by ring
        _ = (M - 1) * ((M - 1) ^ D.card * M ^ Fintype.card ι) := by rw [hih]
        _ = (M - 1) ^ D.card * (M - 1) * M ^ Fintype.card ι := by ring

/-! ## 3. The exact failure law of the almost-lossless scheme -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The failure event is the complement of the no-collision event. -/
theorem failSet_compl (S : Finset α) (x : α) :
    (failSet S x M)ᶜ = noCollisionEvent M (S.erase x) x := by
  ext H
  simp only [failSet, noCollisionEvent, Finset.mem_compl, mem_filter, mem_univ, true_and]
  push_neg
  rfl

/-- **The exact failure count.**  With `k = |S \ {x}|` competitors,
`M^k · |failSet| + (M-1)^k · M^{|α|} = M^k · M^{|α|}`, i.e.
`P[failure] = 1 - (1 - 1/M)^k` exactly.  Every bound in the thread —
`AlmostLossless.failSet_prob_le`, `AlmostLossless.failure_prob_lower_bound_real`,
`BonferroniMarginals.hashing_failure_lower_unconditional` — is a consequence. -/
theorem card_failSet_exact (S : Finset α) (x : α) :
    M ^ (S.erase x).card * (failSet S x M).card
        + (M - 1) ^ (S.erase x).card * M ^ Fintype.card α
      = M ^ (S.erase x).card * M ^ Fintype.card α := by
  classical
  set k := (S.erase x).card with hk
  have hx : x ∉ S.erase x := Finset.notMem_erase x S
  have hgood := card_noCollisionEvent_mul (M := M) x (S.erase x) hx
  have hcompl : (failSet S x M).card + (noCollisionEvent M (S.erase x) x).card
      = M ^ Fintype.card α := by
    rw [← failSet_compl (M := M) S x, Finset.card_add_card_compl]
    simp
  calc M ^ k * (failSet S x M).card + (M - 1) ^ k * M ^ Fintype.card α
      = M ^ k * (failSet S x M).card + M ^ k * (noCollisionEvent M (S.erase x) x).card := by
        rw [← hgood, ← hk]
    _ = M ^ k * ((failSet S x M).card + (noCollisionEvent M (S.erase x) x).card) := by ring
    _ = M ^ k * M ^ Fintype.card α := by rw [hcompl]

/-- **The exact failure law**, in probability form:
`P[failure] = 1 - (1 - 1/M)^k`. -/
theorem failure_prob_exact (S : Finset α) (x : α) (hM : 0 < M) :
    ((failSet S x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α)
      = 1 - (1 - 1 / (M : ℝ)) ^ (S.erase x).card := by
  classical
  set k := (S.erase x).card with hk
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hbase := card_failSet_exact (M := M) S x
  have hsub : ((M - 1 : ℕ) : ℝ) = (M : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ M := hM
    push_cast [Nat.cast_sub h1]; ring
  have hcast : (M : ℝ) ^ k * (failSet S x M).card + ((M : ℝ) - 1) ^ k * (M : ℝ) ^ Fintype.card α
      = (M : ℝ) ^ k * (M : ℝ) ^ Fintype.card α := by
    have h := congrArg (fun n : ℕ => (n : ℝ)) hbase
    push_cast [hsub] at h
    linarith [h]
  have hMk : ((M : ℝ) ^ k) ≠ 0 := by positivity
  have hNk : ((M : ℝ) ^ Fintype.card α) ≠ 0 := by positivity
  have hone : (1 - 1 / (M : ℝ)) = ((M : ℝ) - 1) / (M : ℝ) := by
    field_simp
  rw [hone, div_pow, eq_sub_iff_add_eq]
  field_simp
  linear_combination hcast

/-! ## 4. Matching upper and lower bounds from the exact law -/

/-- **The Shannon random-coding bound, from the exact law.**  Bernoulli's
inequality applied to `(1-1/M)^k` gives `P[failure] ≤ k/M`, recovering
`AlmostLossless.failSet_prob_le`. -/
theorem failure_prob_le_shannon (S : Finset α) (x : α) (hM : 0 < M) :
    ((failSet S x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α)
      ≤ (S.erase x).card / (M : ℝ) := by
  classical
  set k := (S.erase x).card with hk
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hM1 : (1 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
  rw [failure_prob_exact S x hM]
  have hber : 1 + (k : ℝ) * (-(1 / (M : ℝ))) ≤ (1 + -(1 / (M : ℝ))) ^ k := by
    apply one_add_mul_le_pow
    have : 1 / (M : ℝ) ≤ 1 := by
      rw [div_le_one hMpos]; linarith
    linarith
  have hrw : (1 : ℝ) - 1 / (M : ℝ) = 1 + -(1 / (M : ℝ)) := by ring
  rw [hrw]
  have hkM : (k : ℝ) * (1 / (M : ℝ)) = (k : ℝ) / (M : ℝ) := by ring
  linarith [hber]

/-- **A matching lower bound, from the exact law.**  Since
`(1 + k/M)(1 - 1/M)^k ≤ ((1+1/M)(1-1/M))^k ≤ 1`, the exact law gives
`P[failure] ≥ k/(M+k)`.  With `failure_prob_le_shannon` this pins the failure
probability of a uniformly random codebook between `k/(M+k)` and `k/M` for every
`k` and every `M ≥ 1`: random hashing fails with probability `Θ(min(1, k/M))`. -/
theorem failure_prob_ge_harmonic (S : Finset α) (x : α) (hM : 0 < M) :
    ((S.erase x).card : ℝ) / ((M : ℝ) + (S.erase x).card)
      ≤ ((failSet S x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α) := by
  classical
  set k := (S.erase x).card with hk
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hM1 : (1 : ℝ) ≤ (M : ℝ) := by exact_mod_cast hM
  have hknn : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  rw [failure_prob_exact S x hM]
  -- `1 + k/M ≤ (1 + 1/M)^k`
  have hber : 1 + (k : ℝ) * (1 / (M : ℝ)) ≤ (1 + 1 / (M : ℝ)) ^ k := by
    apply one_add_mul_le_pow
    have hinv : (0 : ℝ) < 1 / (M : ℝ) := by positivity
    linarith
  have hpos : (0 : ℝ) ≤ 1 - 1 / (M : ℝ) := by
    have : 1 / (M : ℝ) ≤ 1 := by rw [div_le_one hMpos]; linarith
    linarith
  -- `((1+1/M)(1-1/M))^k ≤ 1`
  have hprod : ((1 + 1 / (M : ℝ)) * (1 - 1 / (M : ℝ))) ^ k ≤ 1 := by
    apply pow_le_one₀
    · have h1 : (0 : ℝ) ≤ 1 + 1 / (M : ℝ) := by positivity
      exact mul_nonneg h1 hpos
    · nlinarith [sq_nonneg (1 / (M : ℝ))]
  have hkey : (1 + (k : ℝ) / (M : ℝ)) * (1 - 1 / (M : ℝ)) ^ k ≤ 1 := by
    have hmul : (1 + (k : ℝ) * (1 / (M : ℝ))) * (1 - 1 / (M : ℝ)) ^ k
        ≤ (1 + 1 / (M : ℝ)) ^ k * (1 - 1 / (M : ℝ)) ^ k := by
      apply mul_le_mul_of_nonneg_right hber (by positivity)
    rw [← mul_pow] at hmul
    have hkM : (k : ℝ) * (1 / (M : ℝ)) = (k : ℝ) / (M : ℝ) := by ring
    rw [hkM] at hmul
    linarith [hprod]
  -- conclude
  have hden : (0 : ℝ) < (M : ℝ) + k := by linarith
  have hfrac : (1 + (k : ℝ) / (M : ℝ)) = ((M : ℝ) + k) / (M : ℝ) := by field_simp
  rw [hfrac] at hkey
  have hbound : (1 - 1 / (M : ℝ)) ^ k ≤ (M : ℝ) / ((M : ℝ) + k) := by
    rw [div_mul_eq_mul_div, div_le_one (by positivity)] at hkey
    rw [le_div_iff₀ hden]
    linarith
  have hsimp : (k : ℝ) / ((M : ℝ) + k) = 1 - (M : ℝ) / ((M : ℝ) + k) := by
    field_simp
    ring
  rw [hsimp]
  linarith

/-! ## 5. Lab notes: brute-force confirmation of the exact law

The exact law predicts `|failSet| = M^{|α|} - (M-1)^k · M^{|α| - k}` with
`k = |α| - 1` when every other string is a competitor.  Two independent
brute-force enumerations of the full codebook space, checked by the kernel:
`|α| = 3, M = 2` gives `8 - 1·2 = 6`, and `|α| = 4, M = 3` gives `81 - 8·3 = 57`. -/

/-- Brute-force check of the exact failure law for `|α| = 3`, `M = 2`. -/
theorem failure_count_check_three_two :
    ((univ : Finset (Fin 3 → Fin 2)).filter
      (fun H => ∃ y ∈ (univ : Finset (Fin 3)).erase (0 : Fin 3), H y = H 0)).card
      = 2 ^ 3 - (2 - 1) ^ 2 * 2 ^ 1 := by decide

/-- Brute-force check of the exact failure law for `|α| = 4`, `M = 3`. -/
theorem failure_count_check_four_three :
    ((univ : Finset (Fin 4 → Fin 3)).filter
      (fun H => ∃ y ∈ (univ : Finset (Fin 4)).erase (0 : Fin 4), H y = H 0)).card
      = 3 ^ 4 - (3 - 1) ^ 3 * 3 ^ 1 := by decide

end ExactFailure