import Shared.AttentionBudgetKnee

/-!
# NET-90: the key budget of a *mixed-domain* context is a sup-convolution

`Shared.AttentionBudgetKnee` develops the knee `k*(n)` of a single sorted attention
profile: the least top-`k` budget whose retained mass clears a gate `τ`.  The NET-90
experiment sweeps the *mixing ratio* of a two-domain corpus (code blocks versus prose
blocks) at fixed context length and measures the knee at each ratio.  The reported
shape is a **bump**: the balanced 50/50 arm needs strictly more keys than either pure
endpoint.

This file supplies the missing structural object.  A context built from `m` keys of
domain `a` and `l` keys of domain `b` has, after sorting, a head mass which is the
**sup-convolution**

  `mixHead a b m l k = max_{j ≤ k} (headMass a (min j m) + headMass b (min (k-j) l))`,

because a top-`k` selection from the union is exactly a split of the budget between the
two domains.  Everything about the mixing-ratio response follows from this one formula:

* `mixKnee_le_add` — **subadditivity**: `k*(m,l) ≤ k*_a(m) + k*_b(l)`.  The bump can
  never exceed the sum of the two pure budgets.
* `add_kstar_le_mixKnee` — **superadditivity with a relaxed gate**, the mechanism
  theorem: `k*_a(m, τ_a) + k*_b(l, τ_b) ≤ k*(m,l,τ)` where
  `τ_a = τ - (1-τ)·S_b/S_a` and `τ_b = τ - (1-τ)·S_a/S_b`.  A mixed context must pay
  for *two* heads, each to a gate only slightly relaxed from `τ`.
* `balanced_selfmix_sandwich` — for a balanced self-mixture the knee is pinned between
  `2·k*(N, 2τ-1)` and `2·k*(N, τ)`: symmetric mixing costs a factor of two, not a
  convex interpolation.
* `mixKnee_le_kstar_add_minority` — an asymmetric mixture with a small minority side is
  within `l` keys of the majority's pure budget: minority blocks cannot inflate the
  budget beyond their own count.

The pure endpoints are recovered exactly (`mixKnee_pure_right`, `mixKnee_pure_left`), so
the mixing-ratio sweep really is a curve through the single-domain theory.

-- !-- Lab Notes -- !--
Hypothesizer (conjectures for the mixing-ratio response, ranked):
 (M1) The mixed head mass is the sup-convolution of the two pure head masses; the whole
      ratio response is a corollary of this single algebraic fact.            [BOLD]
 (M2) The knee is *superadditive* across domains up to a gate relaxation — this is the
      formal content of "cross-domain query-key interactions inflate the budget".
 (M3) The knee is subadditive: `k*(mix) ≤ k*_a + k*_b`; so the bump is bounded by a
      factor two, never worse.
 (M4) For a balanced self-mixture the response is a *doubling*, not an interpolation:
      no linear-in-ratio law can hold.                                        [BOLD]
 (M5) Asymmetry is protective in proportion to the minority count `l`.

Experimenter: M1 is the definition `mixHead`; M2 = `add_kstar_le_mixKnee`;
M3 = `mixKnee_le_add`; M4 = `balanced_selfmix_sandwich`; M5 =
`mixKnee_le_kstar_add_minority`.  All are proved here with zero sorries.  The
quantitative refutation of the three pre-registered shapes is carried out on an explicit
geometric profile in `Probability.NET90SymmetricBump`.

Analyst: the superadditive bound degrades gracefully as the mixture becomes lopsided —
if `S_b ≪ S_a` then `τ_b` is very negative and the second summand collapses to `0`,
which is exactly why the pure endpoints are *not* bumped.  The bump is therefore a
statement about the two domains carrying *comparable mass*, not about their content.

Critic: no theorem here is vacuous.  `mixHead_pure_right` shows the construction
restricts to the single-domain theory, `mixKnee_le_context` shows the knee is a genuine
finite object, and the sandwich has a nonempty gap only when the gate relaxation moves
the pure knee, so the two bounds are not the same statement in disguise.
-/

namespace AttentionBudget

open Finset

variable {a b : ℕ → ℝ} {m l k : ℕ} {τ : ℝ}

/-! ## The sup-convolution head mass of a two-domain context -/

/-- Head mass of a top-`k` truncation of a context made of `m` keys with sorted profile
`a` and `l` keys with sorted profile `b`.  A top-`k` selection splits the budget between
the domains, and the sorted order picks the best split. -/
noncomputable def mixHead (a b : ℕ → ℝ) (m l k : ℕ) : ℝ :=
  (range (k + 1)).sup' nonempty_range_add_one
    fun j => headMass a (min j m) + headMass b (min (k - j) l)

/-- Total mass of a two-domain context. -/
noncomputable def mixTotal (a b : ℕ → ℝ) (m l : ℕ) : ℝ := headMass a m + headMass b l

/-- Retained fraction of a two-domain context under a top-`k` truncation. -/
noncomputable def mixRetained (a b : ℕ → ℝ) (m l k : ℕ) : ℝ :=
  mixHead a b m l k / mixTotal a b m l

/-- The knee of a two-domain context: the least budget clearing the gate `τ`. -/
noncomputable def mixKnee (a b : ℕ → ℝ) (m l : ℕ) (τ : ℝ) : ℕ :=
  sInf {k | τ ≤ mixRetained a b m l k}

lemma le_mixHead (a b : ℕ → ℝ) (m l : ℕ) {j k : ℕ} (hj : j ≤ k) :
    headMass a (min j m) + headMass b (min (k - j) l) ≤ mixHead a b m l k := by
  rw [mixHead]
  exact Finset.le_sup' (fun i => headMass a (min i m) + headMass b (min (k - i) l))
    (mem_range.2 (Nat.lt_succ_of_le hj))

lemma mixHead_le {c : ℝ}
    (h : ∀ j ≤ k, headMass a (min j m) + headMass b (min (k - j) l) ≤ c) :
    mixHead a b m l k ≤ c :=
  Finset.sup'_le _ _ fun j hj => h j (by simpa [Nat.lt_succ_iff] using mem_range.1 hj)

/-- The optimal split is attained. -/
lemma exists_split_eq_mixHead (a b : ℕ → ℝ) (m l k : ℕ) :
    ∃ j ≤ k, mixHead a b m l k = headMass a (min j m) + headMass b (min (k - j) l) := by
  obtain ⟨j, hj, hval⟩ := Finset.exists_mem_eq_sup' (Finset.nonempty_range_add_one (n := k))
    fun j => headMass a (min j m) + headMass b (min (k - j) l)
  exact ⟨j, by simpa [Nat.lt_succ_iff] using mem_range.1 hj, hval⟩

section Positive

variable (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i)

include ha hb

lemma mixHead_le_total (m l k : ℕ) : mixHead a b m l k ≤ mixTotal a b m l :=
  mixHead_le fun _ _ =>
    add_le_add (headMass_mono ha (min_le_right _ _)) (headMass_mono hb (min_le_right _ _))

omit ha in
lemma mixHead_mono (m l : ℕ) : Monotone (mixHead a b m l) := by
  intro k k' hkk
  refine mixHead_le fun j _hj => ?_
  refine le_trans ?_ (le_mixHead a b m l (j := j) (k := k') (by omega))
  have hmin : min (k - j) l ≤ min (k' - j) l := by omega
  exact add_le_add le_rfl (headMass_mono hb hmin)

/-- Budget `m + l` retains everything. -/
lemma mixHead_full (m l : ℕ) : mixHead a b m l (m + l) = mixTotal a b m l := by
  refine le_antisymm (mixHead_le_total ha hb _ _ _) ?_
  have h := le_mixHead a b m l (j := m) (k := m + l) (by omega)
  simpa [mixTotal, Nat.add_sub_cancel_left] using h

lemma mixTotal_pos (hm : 0 < m) (hl : 0 < l) : 0 < mixTotal a b m l :=
  add_pos (headMass_pos ha hm) (headMass_pos hb hl)

lemma mixRetained_full (hm : 0 < m) (hl : 0 < l) : mixRetained a b m l (m + l) = 1 := by
  rw [mixRetained, mixHead_full ha hb, div_self (mixTotal_pos ha hb hm hl).ne']

lemma mixRetained_mono (hm : 0 < m) (hl : 0 < l) : Monotone (mixRetained a b m l) := by
  intro k k' hkk
  exact div_le_div_of_nonneg_right (mixHead_mono hb m l hkk) (mixTotal_pos ha hb hm hl).le

lemma mixGate_nonempty (hm : 0 < m) (hl : 0 < l) (hτ : τ ≤ 1) :
    {k | τ ≤ mixRetained a b m l k}.Nonempty :=
  ⟨m + l, by simpa [Set.mem_setOf_eq, mixRetained_full ha hb hm hl] using hτ⟩

/-- The mixed knee clears the gate. -/
lemma gate_le_mixRetained_mixKnee (hm : 0 < m) (hl : 0 < l) (hτ : τ ≤ 1) :
    τ ≤ mixRetained a b m l (mixKnee a b m l τ) :=
  Nat.sInf_mem (mixGate_nonempty ha hb hm hl hτ)

lemma mixKnee_le_context (hm : 0 < m) (hl : 0 < l) (hτ : τ ≤ 1) :
    mixKnee a b m l τ ≤ m + l :=
  Nat.sInf_le (by simpa [Set.mem_setOf_eq, mixRetained_full ha hb hm hl] using hτ)

end Positive

/-- Any passing budget bounds the mixed knee. -/
lemma mixKnee_le_of_pass (h : τ ≤ mixRetained a b m l k) : mixKnee a b m l τ ≤ k :=
  Nat.sInf_le h

lemma lt_mixKnee_of_fail (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hm : 0 < m) (hl : 0 < l)
    (hτ : τ ≤ 1) (h : mixRetained a b m l k < τ) : k < mixKnee a b m l τ := by
  by_contra hcon
  push_neg at hcon
  have h1 := mixRetained_mono ha hb hm hl hcon
  have h2 := gate_le_mixRetained_mixKnee ha hb hm hl hτ
  linarith

/-! ## The pure endpoints of the sweep -/

lemma mixHead_pure_right (ha : ∀ i, 0 < a i) (m k : ℕ) :
    mixHead a b m 0 k = headMass a (min k m) := by
  refine le_antisymm (mixHead_le fun j hj => ?_) ?_
  · have : min j m ≤ min k m := by omega
    simpa [headMass] using headMass_mono ha this
  · simpa [headMass] using le_mixHead a b m 0 (j := k) (k := k) le_rfl

/-- At mixing ratio `1` the two-domain theory restricts to the single-domain theory. -/
theorem mixKnee_pure_right (ha : ∀ i, 0 < a i) (m : ℕ) (τ : ℝ) :
    mixKnee a b m 0 τ = kstar a m τ := by
  have hset : {k | τ ≤ mixRetained a b m 0 k} = {k | τ ≤ retained a m k} := by
    ext k
    simp [Set.mem_setOf_eq, mixRetained, mixHead_pure_right ha, mixTotal, retained, headMass]
  simp [mixKnee, kstar, hset]

lemma mixHead_pure_left (hb : ∀ i, 0 < b i) (l k : ℕ) :
    mixHead a b 0 l k = headMass b (min k l) := by
  refine le_antisymm (mixHead_le fun j hj => ?_) ?_
  · have : min (k - j) l ≤ min k l := by omega
    simpa [headMass] using headMass_mono hb this
  · simpa [headMass] using le_mixHead a b 0 l (j := 0) (k := k) (Nat.zero_le _)

/-- At mixing ratio `0` the two-domain theory restricts to the single-domain theory. -/
theorem mixKnee_pure_left (hb : ∀ i, 0 < b i) (l : ℕ) (τ : ℝ) :
    mixKnee a b 0 l τ = kstar b l τ := by
  have hset : {k | τ ≤ mixRetained a b 0 l k} = {k | τ ≤ retained b l k} := by
    ext k
    simp [Set.mem_setOf_eq, mixRetained, mixHead_pure_left hb, mixTotal, retained, headMass]
  simp [mixKnee, kstar, hset]

/-! ## Subadditivity: the bump is bounded by the sum of the pure budgets -/

/-- **M3 — subadditivity of the mixed budget.**  Serving each domain to the gate
separately certainly serves the mixture, so the mixing-ratio response never exceeds the
sum of the two pure knees. -/
theorem mixKnee_le_add (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hm : 0 < m) (hl : 0 < l)
    (hτ : τ ≤ 1) : mixKnee a b m l τ ≤ kstar a m τ + kstar b l τ := by
  set kA := kstar a m τ with hkA
  set kB := kstar b l τ with hkB
  have hpa : τ ≤ retained a m kA := gate_le_retained_kstar ha hm hτ
  have hpb : τ ≤ retained b l kB := gate_le_retained_kstar hb hl hτ
  have hSA : 0 < headMass a m := headMass_pos ha hm
  have hSB : 0 < headMass b l := headMass_pos hb hl
  have hA : τ * headMass a m ≤ headMass a (min kA m) := by
    rw [retained, le_div_iff₀ hSA] at hpa; linarith
  have hB : τ * headMass b l ≤ headMass b (min kB l) := by
    rw [retained, le_div_iff₀ hSB] at hpb; linarith
  refine mixKnee_le_of_pass (k := kA + kB) ?_
  have hsplit := le_mixHead a b m l (j := kA) (k := kA + kB) (by omega)
  rw [Nat.add_sub_cancel_left] at hsplit
  rw [mixRetained, le_div_iff₀ (mixTotal_pos ha hb hm hl), mixTotal]
  nlinarith

/-- **M5 — asymmetry is protective.**  A minority domain of `l` keys can inflate the
budget by at most `l` keys above the majority's own pure budget. -/
theorem mixKnee_le_kstar_add_minority (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i)
    (hm : 0 < m) (hl : 0 < l) (hτ : τ ≤ 1) :
    mixKnee a b m l τ ≤ kstar a m τ + l :=
  le_trans (mixKnee_le_add ha hb hm hl hτ)
    (Nat.add_le_add_left (kstar_le_context hb hl hτ) _)

/-! ## Superadditivity: the mechanism behind the bump -/

/-- **M2 — the mechanism theorem.**  A mixed context must buy a head in *each* domain,
each to a gate relaxed only by the other domain's mass share.  Formally the mixed knee
dominates the sum of two pure knees at the relaxed gates
`τ_a = τ - (1-τ)·S_b/S_a` and `τ_b = τ - (1-τ)·S_a/S_b`. -/
theorem add_kstar_le_mixKnee (ha : ∀ i, 0 < a i) (hb : ∀ i, 0 < b i) (hm : 0 < m)
    (hl : 0 < l) (hτ : τ ≤ 1) :
    kstar a m (τ - (1 - τ) * (headMass b l / headMass a m))
      + kstar b l (τ - (1 - τ) * (headMass a m / headMass b l))
      ≤ mixKnee a b m l τ := by
  have hSA : 0 < headMass a m := headMass_pos ha hm
  have hSB : 0 < headMass b l := headMass_pos hb hl
  set k := mixKnee a b m l τ with hk
  have hgate : τ ≤ mixRetained a b m l k := gate_le_mixRetained_mixKnee ha hb hm hl hτ
  obtain ⟨j, hjk, hj⟩ := exists_split_eq_mixHead a b m l k
  have hmass : τ * (headMass a m + headMass b l)
      ≤ headMass a (min j m) + headMass b (min (k - j) l) := by
    rw [mixRetained, le_div_iff₀ (mixTotal_pos ha hb hm hl), mixTotal] at hgate
    rw [← hj]; linarith
  have hbl : headMass b (min (k - j) l) ≤ headMass b l := headMass_mono hb (min_le_right _ _)
  have ham : headMass a (min j m) ≤ headMass a m := headMass_mono ha (min_le_right _ _)
  have hA : τ - (1 - τ) * (headMass b l / headMass a m) ≤ retained a m j := by
    rw [retained, le_div_iff₀ hSA]
    have hexp : (τ - (1 - τ) * (headMass b l / headMass a m)) * headMass a m
        = τ * headMass a m - (1 - τ) * headMass b l := by
      field_simp
    rw [hexp]
    nlinarith
  have hB : τ - (1 - τ) * (headMass a m / headMass b l) ≤ retained b l (k - j) := by
    rw [retained, le_div_iff₀ hSB]
    have hexp : (τ - (1 - τ) * (headMass a m / headMass b l)) * headMass b l
        = τ * headMass b l - (1 - τ) * headMass a m := by
      field_simp
    rw [hexp]
    nlinarith
  have h1 := kstar_le_of_pass hA
  have h2 := kstar_le_of_pass hB
  omega

/-! ## The balanced self-mixture: a doubling law, not an interpolation -/

/-- **M4 — the symmetric doubling sandwich.**  For a balanced mixture of two contexts
with the same profile the knee is trapped between twice the pure knee at the relaxed
gate `2τ - 1` and twice the pure knee at `τ`.  The mixing-ratio response at the balanced
point is therefore governed by a *factor of two*, not by a convex interpolation between
the endpoints. -/
theorem balanced_selfmix_sandwich (ha : ∀ i, 0 < a i) (hN : 0 < m) (hτ : τ ≤ 1) :
    2 * kstar a m (2 * τ - 1) ≤ mixKnee a a m m τ ∧
      mixKnee a a m m τ ≤ 2 * kstar a m τ := by
  constructor
  · have h := add_kstar_le_mixKnee (a := a) (b := a) ha ha hN hN hτ
    have hratio : headMass a m / headMass a m = 1 := div_self (headMass_pos ha hN).ne'
    rw [hratio] at h
    have hgate : τ - (1 - τ) * 1 = 2 * τ - 1 := by ring
    rw [hgate] at h
    omega
  · have h := mixKnee_le_add (a := a) (b := a) ha ha hN hN hτ
    omega

end AttentionBudget