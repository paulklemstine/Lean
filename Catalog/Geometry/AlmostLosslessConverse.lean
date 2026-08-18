/-
# How far beyond the pigeonhole bound can one go?  Converse and tightness

Part of the research thread *Compression Beyond the Pigeonhole Bound*
(Phase B, Question 2: can random number generators help?).

Two adversarial questions about the almost-lossless scheme of
`Geometry.AlmostLosslessDecoder`:

1. *How much can the counting bound really be relaxed?*
   `AlmostLossless.converse_card_good_le` — **the ε-relaxed pigeonhole bound**:
   for **any** encoder/decoder pair whatsoever, the set of strings decoded
   correctly has size at most `M`.  So a `(1-ε)`-reliable code for a typical set
   `S` still needs `M ≥ (1-ε)|S|`: relaxation buys a factor `(1-ε)`, no more.

2. *Is the `1/ε` overhead of random hashing an artefact of the union bound?*
   No.  `AlmostLossless.failure_prob_lower_bound` is a **Bonferroni lower bound**
   on the failure probability of uniform random hashing:
   `P[failure] ≥ (|S|-1) / (2M)` once `2(|S|-2) ≤ M`.
   Hence uniform random hashing genuinely needs `M ≳ |S| / ε`, a factor `Θ(1/ε)`
   above the converse — the gap is a property of the *random codebook*, not of
   the analysis.

Supporting combinatorics proved here from scratch:
* `AlmostLossless.card_sum_le_card_biUnion_add_offDiag` — the second Bonferroni
  inequality for an arbitrary finite family of finite sets.
* `AlmostLossless.card_doubleCollision_mul_le` — a two-coordinate refinement of
  the marginal count of `AlmostLosslessCore`: two prescribed collisions have
  probability `1/M²`.
-/
import Geometry.AlmostLosslessDecoder

namespace AlmostLossless

open Finset

/-! ## 1. The ε-relaxed pigeonhole bound (converse) -/

/-- **Converse / relaxed counting bound.**  Whatever the encoder and decoder are —
random codebooks, checksums, side information built into the decoder — the set of
source strings on which decoding is exact has cardinality at most `M`.  Almost-
lossless coding therefore relaxes the pigeonhole bound by exactly the fraction of
strings one is willing to lose, and by nothing more. -/
theorem converse_card_good_le {α : Type*} [Fintype α] [DecidableEq α] {M : ℕ}
    (enc : α → Fin M) (dec : Fin M → Option α) :
    ((univ : Finset α).filter (fun x => dec (enc x) = some x)).card ≤ M := by
  classical
  have hinj : Set.InjOn enc ↑((univ : Finset α).filter (fun x => dec (enc x) = some x)) := by
    intro x hx y hy hxy
    simp only [coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hx hy
    have : some x = some y := by rw [← hx, ← hy, hxy]
    exact Option.some_injective _ this
  have := Finset.card_le_card_of_injOn (t := (univ : Finset (Fin M))) enc
    (fun x _ => by simp) hinj
  simpa using this

/-- Quantitative form: to decode a `(1-ε)`-fraction of a typical set `S`
correctly one still needs `M ≥ (1-ε)|S|` codewords. -/
theorem converse_rate {α : Type*} [Fintype α] [DecidableEq α] {M : ℕ}
    (enc : α → Fin M) (dec : Fin M → Option α) (S G : Finset α)
    (hG : ∀ x ∈ G, dec (enc x) = some x) {ε : ℝ} (hε : (1 - ε) * S.card ≤ G.card) :
    (1 - ε) * (S.card : ℝ) ≤ M := by
  have hsub : G ⊆ (univ : Finset α).filter (fun x => dec (enc x) = some x) := by
    intro x hx
    exact mem_filter.2 ⟨mem_univ x, hG x hx⟩
  have h1 : G.card ≤ M :=
    le_trans (Finset.card_le_card hsub) (converse_card_good_le enc dec)
  have : (G.card : ℝ) ≤ M := by exact_mod_cast h1
  linarith

/-! ## 2. Bonferroni: a lower bound for unions of finite sets -/

/-- **Second Bonferroni inequality**, counting form:
`∑ |A i| ≤ |⋃ A i| + ∑_{i ≠ j} |A i ∩ A j|` (ordered pairs).
Proved by induction on the index set. -/
theorem card_sum_le_card_biUnion_add_offDiag {ι Ω : Type*} [DecidableEq ι] [DecidableEq Ω]
    (A : ι → Finset Ω) (I : Finset ι) :
    ∑ i ∈ I, (A i).card ≤ (I.biUnion A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
  classical
  induction I using Finset.induction_on with
  | empty => simp
  | insert a I ha ih =>
      have hunion : (A a).card + (I.biUnion A).card
          = ((insert a I).biUnion A).card + (A a ∩ I.biUnion A).card := by
        rw [Finset.biUnion_insert, ← Finset.card_union_add_card_inter]
      have hinter : (A a ∩ I.biUnion A).card ≤ ∑ i ∈ I, (A a ∩ A i).card := by
        have hEq : A a ∩ I.biUnion A = I.biUnion (fun i => A a ∩ A i) := by
          ext z
          simp only [Finset.mem_inter, Finset.mem_biUnion]
          constructor
          · rintro ⟨hz, i, hi, hzi⟩; exact ⟨i, hi, hz, hzi⟩
          · rintro ⟨i, hi, hz, hzi⟩; exact ⟨hz, i, hi, hzi⟩
        rw [hEq]
        exact Finset.card_biUnion_le
      -- the new cross terms are among the off-diagonal pairs of `insert a I`
      have hcross : ∑ i ∈ I, (A a ∩ A i).card
          = ∑ p ∈ ({a} ×ˢ I), (A p.1 ∩ A p.2).card := by
        rw [Finset.sum_product]
        simp
      have hsubset : (I.offDiag ∪ ({a} ×ˢ I)) ⊆ (insert a I).offDiag := by
        intro p hp
        rcases Finset.mem_union.1 hp with hp | hp
        · rw [Finset.mem_offDiag] at hp ⊢
          exact ⟨mem_insert_of_mem hp.1, mem_insert_of_mem hp.2.1, hp.2.2⟩
        · rw [Finset.mem_product] at hp
          rw [Finset.mem_offDiag]
          have hp1 : p.1 = a := by simpa using hp.1
          refine ⟨by rw [hp1]; exact mem_insert_self a I, mem_insert_of_mem hp.2, ?_⟩
          rw [hp1]
          intro hcon
          exact ha (hcon ▸ hp.2)
      have hdisj : Disjoint I.offDiag ({a} ×ˢ I) := by
        rw [Finset.disjoint_left]
        intro p hp hp'
        rw [Finset.mem_offDiag] at hp
        rw [Finset.mem_product] at hp'
        have : p.1 = a := by simpa using hp'.1
        exact ha (this ▸ hp.1)
      have hsum : ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card
            + ∑ p ∈ ({a} ×ˢ I), (A p.1 ∩ A p.2).card
          ≤ ∑ p ∈ (insert a I).offDiag, (A p.1 ∩ A p.2).card := by
        rw [← Finset.sum_union hdisj]
        exact Finset.sum_le_sum_of_subset hsubset
      calc ∑ i ∈ insert a I, (A i).card = (A a).card + ∑ i ∈ I, (A i).card := by
            rw [Finset.sum_insert ha]
        _ ≤ (A a).card + ((I.biUnion A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card) := by
            omega
        _ = ((insert a I).biUnion A).card + (A a ∩ I.biUnion A).card
              + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by omega
        _ ≤ ((insert a I).biUnion A).card + ∑ i ∈ I, (A a ∩ A i).card
              + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by omega
        _ = ((insert a I).biUnion A).card
              + (∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card
                 + ∑ p ∈ ({a} ×ˢ I), (A p.1 ∩ A p.2).card) := by rw [hcross]; omega
        _ ≤ ((insert a I).biUnion A).card
              + ∑ p ∈ (insert a I).offDiag, (A p.1 ∩ A p.2).card := by omega

/-! ## 3. Two prescribed collisions have probability `1/M²` -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {M : ℕ}

/-- Two distinct collisions with a common vertex `r` cut the codebook space by
`M²`. -/
theorem card_doubleCollision_mul_le {p q r : ι} (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    M ^ 2 * ((collisionEvent M p r) ∩ (collisionEvent M q r)).card
      ≤ M ^ Fintype.card ι := by
  classical
  set E := (collisionEvent M p r) ∩ (collisionEvent M q r) with hE
  have hmaps : ∀ z ∈ (E ×ˢ (univ : Finset (Fin M))) ×ˢ (univ : Finset (Fin M)),
      (fun z : ((ι → Fin M) × Fin M) × Fin M =>
        Function.update (Function.update z.1.1 p z.1.2) q z.2) z ∈
        (univ : Finset (ι → Fin M)) := by
    intro z _; exact mem_univ _
  have hinj : Set.InjOn (fun z : ((ι → Fin M) × Fin M) × Fin M =>
      Function.update (Function.update z.1.1 p z.1.2) q z.2)
      ↑((E ×ˢ (univ : Finset (Fin M))) ×ˢ (univ : Finset (Fin M))) := by
    rintro ⟨⟨H, v⟩, w⟩ hz ⟨⟨H', v'⟩, w'⟩ hz' heq
    simp only [coe_product, Set.mem_prod, mem_coe, hE, Finset.mem_inter, collisionEvent,
      mem_filter, mem_univ, true_and] at hz hz'
    obtain ⟨⟨⟨hHp, hHq⟩, -⟩, -⟩ := hz
    obtain ⟨⟨⟨hHp', hHq'⟩, -⟩, -⟩ := hz'
    have hw : w = w' := by
      have := congrArg (fun f => f q) heq
      simpa using this
    have hv : v = v' := by
      have := congrArg (fun f => f p) heq
      simpa [Function.update_apply, hpq] using this
    have hoff : ∀ a, a ≠ p → a ≠ q → H a = H' a := by
      intro a hap haq
      have := congrArg (fun f => f a) heq
      simpa [Function.update_apply, hap, haq] using this
    have hr : H r = H' r := hoff r (Ne.symm hpr) (Ne.symm hqr)
    have hHH : H = H' := by
      funext a
      rcases eq_or_ne a p with hap | hap
      · rw [hap, hHp, hHp', hr]
      · rcases eq_or_ne a q with haq | haq
        · rw [haq, hHq, hHq', hr]
        · exact hoff a hap haq
    simp [hHH, hv, hw]
  have hcard := Finset.card_le_card_of_injOn _ hmaps hinj
  rw [Finset.card_product, Finset.card_product, Finset.card_univ, Fintype.card_fin,
    Finset.card_univ, card_codebooks] at hcard
  calc M ^ 2 * E.card = E.card * M * M := by ring
    _ ≤ M ^ Fintype.card ι := hcard

/-! ## 4. The failure probability of random hashing is genuinely `≍ |S|/M` -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The failure event is exactly the union of the pairwise collision events. -/
theorem failSet_eq_biUnion (S : Finset α) (x : α) :
    failSet S x M = (S.erase x).biUnion (fun y => collisionEvent M y x) := by
  ext H
  simp only [failSet, mem_filter, mem_univ, true_and, mem_biUnion, collisionEvent]

/-- **Bonferroni lower bound on the failure probability of uniform random
hashing** (counting form).  With `k = |S| - 1` competitors and `N = M^{|α|}`
codebooks:
`k · M · N ≤ M² · |failSet| + k(k-1) · N`.
Together with the trivial upper bound this pins the failure probability of the
random codebook at `Θ(k/M)` in the regime `k ≲ M`. -/
theorem failure_prob_lower_bound (S : Finset α) (x : α) :
    (S.erase x).card * M * M ^ Fintype.card α
      ≤ M ^ 2 * (failSet S x M).card
        + (S.erase x).offDiag.card * M ^ Fintype.card α := by
  classical
  set D := S.erase x with hD
  set N := M ^ Fintype.card α with hN
  have hbon := card_sum_le_card_biUnion_add_offDiag (fun y => collisionEvent M y x) D
  -- multiply the Bonferroni inequality by `M²`
  have hleft : M ^ 2 * ∑ y ∈ D, (collisionEvent M y x).card = D.card * M * N := by
    have : ∀ y ∈ D, M * (collisionEvent M y x).card = N := by
      intro y hy
      exact card_collisionEvent_mul (Finset.mem_erase.1 hy).1
    calc M ^ 2 * ∑ y ∈ D, (collisionEvent M y x).card
        = ∑ y ∈ D, M * (M * (collisionEvent M y x).card) := by
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl (fun y _ => by ring)
      _ = ∑ _y ∈ D, M * N := Finset.sum_congr rfl (fun y hy => by rw [this y hy])
      _ = D.card * M * N := by rw [Finset.sum_const, smul_eq_mul]; ring
  have hright : ∀ p ∈ D.offDiag,
      M ^ 2 * ((collisionEvent M p.1 x) ∩ (collisionEvent M p.2 x)).card ≤ N := by
    intro p hp
    rw [Finset.mem_offDiag] at hp
    exact card_doubleCollision_mul_le hp.2.2 (Finset.mem_erase.1 hp.1).1
      (Finset.mem_erase.1 hp.2.1).1
  calc D.card * M * N = M ^ 2 * ∑ y ∈ D, (collisionEvent M y x).card := hleft.symm
    _ ≤ M ^ 2 * ((D.biUnion (fun y => collisionEvent M y x)).card
          + ∑ p ∈ D.offDiag, ((collisionEvent M p.1 x) ∩ (collisionEvent M p.2 x)).card) :=
        Nat.mul_le_mul_left _ hbon
    _ = M ^ 2 * (failSet S x M).card
          + ∑ p ∈ D.offDiag, M ^ 2 *
              ((collisionEvent M p.1 x) ∩ (collisionEvent M p.2 x)).card := by
        rw [Nat.mul_add, failSet_eq_biUnion, Finset.mul_sum]
    _ ≤ M ^ 2 * (failSet S x M).card + ∑ _p ∈ D.offDiag, N :=
        Nat.add_le_add_left (Finset.sum_le_sum hright) _
    _ = M ^ 2 * (failSet S x M).card + D.offDiag.card * N := by
        rw [Finset.sum_const, smul_eq_mul]

/-- **Random hashing really does pay the `1/ε` factor.**  If the typical set is
not too large compared with the codebook (`2(k-1) ≤ M`, where `k = |S| - 1`), then
the failure probability of a uniformly random codebook is at least `k / (2M)`.
Consequently `P[failure] ≤ ε` forces `M ≥ k/(2ε)`, whereas the converse bound
`converse_rate` only demands `M ≥ (1-ε)|S|`: the `Θ(1/ε)` overhead is intrinsic to
the random codebook, not to the union-bound analysis. -/
theorem failure_prob_lower_bound_real (S : Finset α) (x : α) (hM : 0 < M)
    (hk : 2 * ((S.erase x).card - 1) ≤ M) :
    ((S.erase x).card : ℝ) / (2 * M)
      ≤ ((failSet S x M).card : ℝ) / ((M : ℝ) ^ Fintype.card α) := by
  classical
  set k := (S.erase x).card with hk'
  set N := (M : ℝ) ^ Fintype.card α with hN
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hNpos : (0 : ℝ) < N := by rw [hN]; positivity
  have hbase := failure_prob_lower_bound (M := M) S x
  have hoff : (S.erase x).offDiag.card = k * k - k := by
    rw [Finset.offDiag_card]
  rw [hoff] at hbase
  -- cast to ℝ
  rcases Nat.eq_zero_or_pos k with hk0 | hkpos
  · rw [hk0]
    simp only [Nat.cast_zero, zero_div]
    positivity
  · have hkk : (k : ℝ) * k - k = ((k * k - k : ℕ) : ℝ) := by
      have : k ≤ k * k := Nat.le_mul_of_pos_left k hkpos
      push_cast [Nat.cast_sub this]
      ring
    have hbase' : (k : ℝ) * M * N
        ≤ (M : ℝ) ^ 2 * (failSet S x M).card + ((k : ℝ) * k - k) * N := by
      have h := (Nat.cast_le (α := ℝ)).2 hbase
      push_cast at h
      rw [hkk]
      convert h using 2
    -- `2(k-1) ≤ M` gives `k(k-1) ≤ kM/2`
    have hkM : 2 * ((k : ℝ) - 1) ≤ M := by
      have h1 : ((2 * (k - 1) : ℕ) : ℝ) ≤ (M : ℝ) := by exact_mod_cast hk
      have h2 : ((k - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
        have : (1 : ℕ) ≤ k := hkpos
        push_cast [Nat.cast_sub this]; ring
      push_cast [h2] at h1
      linarith
    have hcross : ((k : ℝ) * k - k) * N ≤ (k : ℝ) * M * N / 2 := by
      have h1 : (k : ℝ) * ((k : ℝ) - 1) ≤ (k : ℝ) * ((M : ℝ) / 2) := by
        have hknn : (0 : ℝ) ≤ k := Nat.cast_nonneg k
        nlinarith
      nlinarith [hNpos.le]
    have hFN : (k : ℝ) * M * N / 2 ≤ (M : ℝ) ^ 2 * (failSet S x M).card := by
      linarith
    rw [div_le_div_iff₀ (by positivity) hNpos]
    nlinarith [hFN, hNpos, hMpos]

end AlmostLossless