/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Polynomial growth of every even moment: tightness of the empirical spectral law

`Probability.WignerAllOrderParity` reduces the computation of every trace moment of
the symmetric Rademacher ensemble to a count of *even closed walks* — loop-free
closed walks all of whose edge multiplicities are even — and proves that the odd
moments vanish identically.  This file supplies the missing quantitative half at
even order: an even closed walk of length `2k` can visit at most `k + 1` distinct
vertices, so there are at most `N^(k+1) (k+1)^(2k)` of them and

  `E [ tr (W ^ (2k)) ] ≤ N^(k+1) · (k+1)^(2k)`,
  `E [ (1/N) tr ((W/√N) ^ (2k)) ] ≤ (k+1)^(2k)`   (uniformly in `N`).

The structural core is graph-theoretic and is proved from scratch here:

* `RademacherWigner.card_visited_le` — along any walk, the number of vertices
  visited never exceeds `1 +` the number of distinct edges used (a spanning-tree
  bound, proved by induction on the length of the walk);
* `RademacherWigner.card_edgesUsed_le` — if every edge multiplicity is even, then
  twice the number of distinct edges is at most the length of the walk;
* `RademacherWigner.card_visited_le_of_even` — combining the two, an even closed
  walk of `2k` steps visits at most `k + 1` vertices;
* `RademacherWigner.card_bounded_image_le` — a function `Fin n → Fin N` whose image
  has at most `r` elements is determined by an `r`-element subset together with a
  map into it, giving at most `N^r · r^n` such functions.

Uniform boundedness of all normalised moments is exactly the tightness input of the
moment method: together with `expect_trace_pow_odd` it says that the expected
empirical spectral distribution of `W/√N` has moments that neither blow up nor
oscillate with `N`, at *every* order.
-/
import Probability.WignerAllOrderParity

open Matrix BigOperators Finset

namespace RademacherWigner

variable {N : ℕ}

/-! ### Vertices and edges visited by a walk -/

/-- The set of vertices visited by the first `t` steps of the walk `w`. -/
def visited (w : ℕ → Fin N) (t : ℕ) : Finset (Fin N) := (Finset.range (t + 1)).image w

/-- The set of (distinct) edges traversed by the first `t` steps of the walk `w`. -/
def edgesUsed (w : ℕ → Fin N) (t : ℕ) : Finset (Fin N × Fin N) :=
  (Finset.range t).image fun s => edgeOf (w s) (w (s + 1))

theorem mem_visited (w : ℕ → Fin N) {s t : ℕ} (hst : s ≤ t) : w s ∈ visited w t :=
  Finset.mem_image_of_mem w (Finset.mem_range.2 (by omega))

theorem edgesUsed_mono (w : ℕ → Fin N) {s t : ℕ} (hst : s ≤ t) :
    edgesUsed w s ⊆ edgesUsed w t := by
  intro e he
  rw [edgesUsed, Finset.mem_image] at he ⊢
  obtain ⟨u, hu, rfl⟩ := he
  rw [Finset.mem_range] at hu
  exact ⟨u, Finset.mem_range.2 (by omega), rfl⟩

/-- If two steps traverse the same edge, the endpoint of the first is an endpoint of
the second. -/
theorem edgeOf_eq_imp {a b c d : Fin N} (h : edgeOf a b = edgeOf c d) : b = c ∨ b = d := by
  unfold edgeOf at h
  split_ifs at h <;> simp_all [Prod.ext_iff]

/-- **Spanning-tree bound for walks.**  The number of vertices a walk has visited
never exceeds one plus the number of distinct edges it has used: each newly visited
vertex is reached through a previously unused edge. -/
theorem card_visited_le (w : ℕ → Fin N) :
    ∀ t, (visited w t).card ≤ 1 + (edgesUsed w t).card := by
  intro t
  induction t with
  | zero => simp [visited, edgesUsed]
  | succ t ih =>
      have hvis : visited w (t + 1) = insert (w (t + 1)) (visited w t) := by
        simp [visited, Finset.range_add_one, Finset.image_insert, Finset.insert_comm]
      have hedge : edgesUsed w (t + 1) = insert (edgeOf (w t) (w (t + 1))) (edgesUsed w t) := by
        simp [edgesUsed, Finset.range_add_one, Finset.image_insert]
      by_cases hmem : w (t + 1) ∈ visited w t
      · rw [hvis, Finset.insert_eq_self.2 hmem]
        refine ih.trans (Nat.add_le_add_left (Finset.card_le_card ?_) 1)
        rw [hedge]
        exact Finset.subset_insert _ _
      · have hnew : edgeOf (w t) (w (t + 1)) ∉ edgesUsed w t := by
          intro hc
          rw [edgesUsed, Finset.mem_image] at hc
          obtain ⟨s, hs, hse⟩ := hc
          rw [Finset.mem_range] at hs
          rcases edgeOf_eq_imp hse.symm with h | h
          · exact hmem (h ▸ mem_visited w (le_of_lt hs))
          · exact hmem (h ▸ mem_visited w (by omega : s + 1 ≤ t))
        rw [hvis, hedge, Finset.card_insert_of_notMem hnew,
          Finset.card_insert_of_notMem hmem]
        omega

/-- **No simply-traversed edge forces few edges.**  If no edge of the first `n` steps
is traversed exactly once, then at most `n / 2` distinct edges occur. -/
theorem card_edgesUsed_le (w : ℕ → Fin N) (n : ℕ)
    (hne1 : ∀ p, edgeCount n w p ≠ 1) : 2 * (edgesUsed w n).card ≤ n := by
  have hmaps : ∀ s ∈ Finset.range n, edgeOf (w s) (w (s + 1)) ∈ edgesUsed w n :=
    fun s hs => Finset.mem_image_of_mem _ hs
  have hfib : n = ∑ p ∈ edgesUsed w n, edgeCount n w p := by
    have h := Finset.card_eq_sum_card_fiberwise
      (f := fun s => edgeOf (w s) (w (s + 1))) (s := Finset.range n) (t := edgesUsed w n) hmaps
    simpa [edgeCount, Finset.card_range] using h
  have hge : ∀ p ∈ edgesUsed w n, 2 ≤ edgeCount n w p := by
    intro p hp
    have hpos : 0 < edgeCount n w p := by
      rw [edgesUsed, Finset.mem_image] at hp
      obtain ⟨s, hs, rfl⟩ := hp
      rw [edgeCount, Finset.card_pos]
      exact ⟨s, Finset.mem_filter.2 ⟨hs, rfl⟩⟩
    have := hne1 p
    omega
  calc 2 * (edgesUsed w n).card
      = ∑ _p ∈ edgesUsed w n, 2 := by rw [Finset.sum_const, smul_eq_mul, mul_comm]
    _ ≤ ∑ p ∈ edgesUsed w n, edgeCount n w p := Finset.sum_le_sum hge
    _ = n := hfib.symm

/-- A closed walk of `m + 1` steps no edge of which is traversed exactly once visits
at most `(m + 3) / 2` vertices. -/
theorem card_visited_le_of_ne_one (w : ℕ → Fin N) (m : ℕ)
    (hne1 : ∀ p, edgeCount (m + 1) w p ≠ 1) : 2 * (visited w m).card ≤ m + 3 := by
  have h1 := card_visited_le w m
  have h2 : (edgesUsed w m).card ≤ (edgesUsed w (m + 1)).card :=
    Finset.card_le_card (edgesUsed_mono w (Nat.le_succ m))
  have h3 := card_edgesUsed_le w (m + 1) hne1
  omega

/-- An even closed walk of `m + 1` steps visits at most `(m + 3) / 2` vertices. -/
theorem card_visited_le_of_even (w : ℕ → Fin N) (m : ℕ)
    (heven : ∀ p, Even (edgeCount (m + 1) w p)) : 2 * (visited w m).card ≤ m + 3 := by
  refine card_visited_le_of_ne_one w m fun p hp => ?_
  obtain ⟨c, hc⟩ := heven p
  omega

/-! ### Counting functions with a small image -/

/-- A function `Fin n → Fin N` whose image has at most `r ≤ N` elements is encoded by
an `r`-element subset of `Fin N` together with a map into it; hence there are at most
`N ^ r · r ^ n` of them. -/
theorem card_bounded_image_le {n r : ℕ} (hr : r ≤ N) :
    ((univ : Finset (Fin n → Fin N)).filter
        (fun u => (Finset.image u univ).card ≤ r)).card ≤ N ^ r * r ^ n := by
  classical
  have hsub : ((univ : Finset (Fin n → Fin N)).filter
      (fun u => (Finset.image u univ).card ≤ r))
      ⊆ (Finset.powersetCard r (univ : Finset (Fin N))).biUnion
          fun T => Fintype.piFinset fun _ : Fin n => T := by
    intro u hu
    rw [Finset.mem_filter] at hu
    obtain ⟨T, hT1, hT2⟩ := Finset.exists_superset_card_eq hu.2 (by simpa using hr)
    refine Finset.mem_biUnion.2 ⟨T, Finset.mem_powersetCard.2 ⟨Finset.subset_univ T, hT2⟩, ?_⟩
    exact Fintype.mem_piFinset.2 fun t => hT1 (Finset.mem_image_of_mem u (Finset.mem_univ t))
  calc ((univ : Finset (Fin n → Fin N)).filter
        (fun u => (Finset.image u univ).card ≤ r)).card
      ≤ ((Finset.powersetCard r (univ : Finset (Fin N))).biUnion
          fun T => Fintype.piFinset fun _ : Fin n => T).card := Finset.card_le_card hsub
    _ ≤ ∑ T ∈ Finset.powersetCard r (univ : Finset (Fin N)),
          (Fintype.piFinset fun _ : Fin n => T).card := Finset.card_biUnion_le
    _ = N.choose r * r ^ n := by
        rw [Finset.sum_congr rfl (g := fun _ => r ^ n) ?_]
        · rw [Finset.sum_const, Finset.card_powersetCard, Finset.card_univ, Fintype.card_fin,
            smul_eq_mul]
        · intro T hT
          rw [Fintype.card_piFinset, Finset.prod_const, (Finset.mem_powersetCard.1 hT).2]
          simp
    _ ≤ N ^ r * r ^ n := Nat.mul_le_mul_right _ (Nat.choose_le_pow N r)

/-! ### From the `Fin`-indexed encoding of a closed walk to a periodic `ℕ`-walk -/

/-- The `(m+1)`-periodic walk on `ℕ` determined by the base point `i` and the
interior vertices `v`. -/
def cyc (m : ℕ) (i : Fin N) (v : Fin m → Fin N) : ℕ → Fin N := fun t =>
  (Fin.cons i v : Fin (m + 1) → Fin N) ⟨t % (m + 1), Nat.mod_lt _ (Nat.succ_pos m)⟩

theorem cyc_apply {m : ℕ} (i : Fin N) (v : Fin m → Fin N) (t : Fin (m + 1)) :
    cyc m i v t.val = (Fin.cons i v : Fin (m + 1) → Fin N) t := by
  unfold cyc
  congr 1
  exact Fin.ext (Nat.mod_eq_of_lt t.isLt)

theorem cyc_succ {m : ℕ} (i : Fin N) (v : Fin m → Fin N) (t : Fin (m + 1)) :
    cyc m i v (t.val + 1) = (Fin.snoc v i : Fin (m + 1) → Fin N) t := by
  rcases Nat.lt_or_ge t.val m with ht | ht
  · have h2 : cyc m i v (t.val + 1)
        = (Fin.cons i v : Fin (m + 1) → Fin N) ⟨t.val + 1, by omega⟩ := by
      unfold cyc; congr 1; exact Fin.ext (Nat.mod_eq_of_lt (by omega))
    rw [h2, show (⟨t.val + 1, by omega⟩ : Fin (m + 1)) = (⟨t.val, ht⟩ : Fin m).succ from rfl,
      Fin.cons_succ]
    calc v ⟨t.val, ht⟩
        = (Fin.snoc v i : Fin (m + 1) → Fin N) (Fin.castSucc ⟨t.val, ht⟩) :=
          (Fin.snoc_castSucc (α := fun _ => Fin N) i v ⟨t.val, ht⟩).symm
      _ = (Fin.snoc v i : Fin (m + 1) → Fin N) t := by congr 1
  · have htm : t = Fin.last m := Fin.ext (by have := t.isLt; simp only [Fin.val_last]; omega)
    have h2 : cyc m i v (t.val + 1) = (Fin.cons i v : Fin (m + 1) → Fin N) 0 := by
      unfold cyc
      congr 1
      refine Fin.ext ?_
      simp [htm]
    rw [h2, htm, Fin.snoc_last, Fin.cons_zero]

theorem edgeMult_eq_edgeCount {m : ℕ} (i : Fin N) (v : Fin m → Fin N) (p : Fin N × Fin N) :
    edgeMult (Fin.cons i v : Fin (m + 1) → Fin N) (Fin.snoc v i : Fin (m + 1) → Fin N) p
      = edgeCount (m + 1) (cyc m i v) p := by
  rw [edgeMult, Finset.card_filter, edgeCount, Finset.card_filter,
    ← Fin.sum_univ_eq_sum_range
      (fun t => if edgeOf (cyc m i v t) (cyc m i v (t + 1)) = p then 1 else 0) (m + 1)]
  exact Finset.sum_congr rfl fun t _ => by rw [cyc_apply, cyc_succ]

theorem image_cons_eq_visited {m : ℕ} (i : Fin N) (v : Fin m → Fin N) :
    Finset.image (Fin.cons i v : Fin (m + 1) → Fin N) univ = visited (cyc m i v) m := by
  ext x
  simp only [visited, Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_range]
  constructor
  · rintro ⟨t, rfl⟩
    exact ⟨t.val, t.isLt, cyc_apply i v t⟩
  · rintro ⟨s, hs, rfl⟩
    exact ⟨⟨s, hs⟩, (cyc_apply i v ⟨s, hs⟩).symm⟩

/-- **Closed walks with no simply-traversed edge are thin.**  Such a walk of at most
`2k + 1` steps visits at most `k + 1` distinct vertices. -/
theorem card_image_cons_le_of_ne_one {m k : ℕ} (hm : m ≤ 2 * k) {i : Fin N}
    {v : Fin m → Fin N}
    (h : ∀ p, edgeMult (Fin.cons i v : Fin (m + 1) → Fin N)
      (Fin.snoc v i : Fin (m + 1) → Fin N) p ≠ 1) :
    (Finset.image (Fin.cons i v : Fin (m + 1) → Fin N) univ).card ≤ k + 1 := by
  have hne1 : ∀ p, edgeCount (m + 1) (cyc m i v) p ≠ 1 := by
    intro p
    rw [← edgeMult_eq_edgeCount]
    exact h p
  have h1 := card_visited_le_of_ne_one (cyc m i v) m hne1
  rw [image_cons_eq_visited]
  omega

/-- **Even closed walks are thin.**  An even closed walk of `2k` steps visits at most
`k + 1` distinct vertices. -/
theorem card_image_cons_le_of_isEvenWalk {m k : ℕ} (hm : m + 1 = 2 * k) {i : Fin N}
    {v : Fin m → Fin N} (h : IsEvenWalk m i v) :
    (Finset.image (Fin.cons i v : Fin (m + 1) → Fin N) univ).card ≤ k + 1 := by
  refine card_image_cons_le_of_ne_one (by omega) fun p hp => ?_
  obtain ⟨c, hc⟩ := h.2 p
  omega

/-! ### The count of even closed walks, and the moment bound -/

/-- **Counting thin closed walks.**  If every walk satisfying `P` visits at most
`k + 1` vertices (and `k ≤ m`), there are at most `N^(k+1) (k+1)^(m+1)` of them. -/
theorem card_filter_le_pow {m k : ℕ} (hkm : k ≤ m) (P : Fin N × (Fin m → Fin N) → Prop)
    [DecidablePred P]
    (hP : ∀ x, P x →
      (Finset.image (Fin.cons x.1 x.2 : Fin (m + 1) → Fin N) univ).card ≤ k + 1) :
    ((univ : Finset (Fin N × (Fin m → Fin N))).filter P).card
      ≤ N ^ (k + 1) * (k + 1) ^ (m + 1) := by
  by_cases hNk : k + 1 ≤ N
  · refine le_trans (Finset.card_le_card_of_injOn
      (fun x => (Fin.cons x.1 x.2 : Fin (m + 1) → Fin N)) ?_ ?_)
      (card_bounded_image_le (n := m + 1) (r := k + 1) hNk)
    · intro x hx
      rw [Finset.mem_coe, Finset.mem_filter] at hx
      rw [Finset.mem_coe, Finset.mem_filter]
      exact ⟨Finset.mem_univ _, hP x hx.2⟩
    · intro x _ y _ hxy
      have h0 : x.1 = y.1 := by
        have := congrFun hxy 0
        simpa using this
      have h1 : x.2 = y.2 := by
        funext t
        have := congrFun hxy t.succ
        simpa using this
      exact Prod.ext h0 h1
  · push_neg at hNk
    have hcard : ((univ : Finset (Fin N × (Fin m → Fin N))).filter P).card ≤ N ^ (m + 1) := by
      refine le_trans (Finset.card_filter_le _ _) (le_of_eq ?_)
      simp [Finset.card_univ, Fintype.card_prod, pow_succ, mul_comm]
    refine hcard.trans ?_
    have hsplit : N ^ (m + 1) = N ^ (k + 1) * N ^ (m - k) := by
      rw [← pow_add]
      congr 1
      omega
    rw [hsplit]
    refine Nat.mul_le_mul_left _ ?_
    calc N ^ (m - k) ≤ (k + 1) ^ (m - k) := Nat.pow_le_pow_left (by omega) _
      _ ≤ (k + 1) ^ (m + 1) := Nat.pow_le_pow_right (by omega) (by omega)

/-- There are at most `N^(k+1) (k+1)^(2k)` even closed walks of length `2k`. -/
theorem card_evenWalks_le {m k : ℕ} (hm : m + 1 = 2 * k) :
    ((univ : Finset (Fin N × (Fin m → Fin N))).filter fun x => IsEvenWalk m x.1 x.2).card
      ≤ N ^ (k + 1) * (k + 1) ^ (m + 1) :=
  card_filter_le_pow (N := N) (by omega) _ fun _ hx => card_image_cons_le_of_isEvenWalk hm hx

/-- The even trace moments are exactly the number of even closed walks, hence
nonnegative and bounded by `N^(k+1) (k+1)^(2k)`. -/
theorem expect_trace_pow_le {m k : ℕ} (hm : m + 1 = 2 * k) :
    expect (fun g : Config N => ((W g) ^ (m + 1)).trace)
      ≤ (N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (m + 1) := by
  have hcount : expect (fun g : Config N => ((W g) ^ (m + 1)).trace)
      = (((univ : Finset (Fin N × (Fin m → Fin N))).filter
          fun x => IsEvenWalk m x.1 x.2).card : ℝ) := by
    rw [expect_trace_pow_eq_sum_indicator, ← Finset.sum_boole, Fintype.sum_prod_type]
  rw [hcount]
  have h := card_evenWalks_le (N := N) hm
  have hcast : (((univ : Finset (Fin N × (Fin m → Fin N))).filter
      fun x => IsEvenWalk m x.1 x.2).card : ℝ) ≤ ((N ^ (k + 1) * (k + 1) ^ (m + 1) : ℕ) : ℝ) := by
    exact_mod_cast h
  refine hcast.trans (le_of_eq ?_)
  push_cast
  ring

/-! ### A matching deterministic lower bound -/

/-- **Deterministic lower bound for every even trace moment.**  Power-mean convexity
applied to the eigenvalues, together with the exactly self-averaging second moment
`tr W² = N² - N`, gives `tr (W^(2k)) ≥ N (N-1)^k` for *every* realisation of the
ensemble.  Combined with `expect_trace_pow_le` this pins the even moments at order
`N^(k+1)`. -/
theorem trace_pow_two_mul_ge (g : Config N) {k : ℕ} (hk : 1 ≤ k) (hN : 0 < N) :
    (N : ℝ) * ((N : ℝ) - 1) ^ k ≤ ((W g) ^ (2 * k)).trace := by
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  obtain ⟨n, rfl⟩ : ∃ n, k = n + 1 := ⟨k - 1, by omega⟩
  have hherm := W_isHermitian g
  have heig : ((W g) ^ (2 * (n + 1))).trace
      = ∑ i, (hherm.eigenvalues i ^ 2) ^ (n + 1) := by
    rw [WignerBridge.trace_pow_eq_sum_eigenvalues_real hherm]
    exact Finset.sum_congr rfl fun i _ => by rw [← pow_mul, mul_comm]
  have hsq : (∑ i, hherm.eigenvalues i ^ 2) = (N : ℝ) ^ 2 - (N : ℝ) := by
    rw [← WignerBridge.trace_pow_eq_sum_eigenvalues_real hherm 2, trace_W_sq]
  have hpm := pow_sum_div_card_le_sum_pow
    (s := (Finset.univ : Finset (Fin N))) (f := fun i => hherm.eigenvalues i ^ 2)
    (fun i _ => sq_nonneg _) n
  rw [hsq, Finset.card_univ, Fintype.card_fin,
    show ((N : ℝ) ^ 2 - (N : ℝ)) = (N : ℝ) * ((N : ℝ) - 1) by ring, mul_pow] at hpm
  rw [heig]
  refine le_trans (le_of_eq ?_) hpm
  have hNk : ((N : ℝ) ^ n) ≠ 0 := by positivity
  field_simp
  ring

/-- The normalised even spectral moments are at least `(1 - 1/N)^k`, deterministically. -/
theorem normalizedMoment_two_mul_ge (g : Config N) {k : ℕ} (hk : 1 ≤ k) (hN : 0 < N) :
    (1 - 1 / (N : ℝ)) ^ k ≤ WignerBridge.normalizedMoment (W g) (2 * k) := by
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hcard : (Fintype.card (Fin N) : ℝ) = (N : ℝ) := by simp
  have hsq : (Real.sqrt (Fintype.card (Fin N)))⁻¹ ^ (2 * k) = ((N : ℝ) ^ k)⁻¹ := by
    rw [hcard, pow_mul, ← Real.sqrt_inv, Real.sq_sqrt (by positivity), inv_pow]
  rw [WignerBridge.normalizedMoment_eq, hsq, hcard]
  have hpos : (0 : ℝ) < 1 / (N : ℝ) * ((N : ℝ) ^ k)⁻¹ := by positivity
  have h := trace_pow_two_mul_ge g hk hN
  calc (1 - 1 / (N : ℝ)) ^ k
      = (1 / (N : ℝ) * ((N : ℝ) ^ k)⁻¹) * ((N : ℝ) * ((N : ℝ) - 1) ^ k) := by
        rw [show (1 : ℝ) - 1 / (N : ℝ) = ((N : ℝ) - 1) / (N : ℝ) by field_simp, div_pow]
        field_simp
    _ ≤ (1 / (N : ℝ) * ((N : ℝ) ^ k)⁻¹) * ((W g) ^ (2 * k)).trace :=
        mul_le_mul_of_nonneg_left h (le_of_lt hpos)
    _ = 1 / (N : ℝ) * ((N : ℝ) ^ k)⁻¹ * ((W g) ^ (2 * k)).trace := rfl

/-- **Uniform boundedness of all even normalised moments.**  For every `k ≥ 1` and
every dimension `N`, the expected `2k`-th moment of the empirical spectral
distribution of `W/√N` is at most `(k+1)^(2k)`, a bound independent of `N`.  This is
the tightness input of the moment method. -/
theorem expect_normalizedMoment_two_mul_le {k : ℕ} (hk : 1 ≤ k) (hN : 0 < N) :
    expect (fun g : Config N => WignerBridge.normalizedMoment (W g) (2 * k))
      ≤ ((k : ℝ) + 1) ^ (2 * k) := by
  obtain ⟨m, hm⟩ : ∃ m, m + 1 = 2 * k := ⟨2 * k - 1, by omega⟩
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hcard : (Fintype.card (Fin N) : ℝ) = (N : ℝ) := by simp
  have hsq : (Real.sqrt (Fintype.card (Fin N)))⁻¹ ^ (2 * k) = ((N : ℝ) ^ k)⁻¹ := by
    rw [hcard, pow_mul, ← Real.sqrt_inv, Real.sq_sqrt (by positivity), inv_pow]
  have hconst : ∀ g : Config N, WignerBridge.normalizedMoment (W g) (2 * k)
      = ((1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹) * ((W g) ^ (2 * k)).trace := by
    intro g
    rw [WignerBridge.normalizedMoment_eq, hsq, hcard]
  simp only [hconst]
  rw [expect_const_mul]
  have hpos : (0 : ℝ) < (1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹ := by positivity
  have hbound : expect (fun g : Config N => ((W g) ^ (2 * k)).trace)
      ≤ (N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k) := by
    have := expect_trace_pow_le (N := N) hm
    rw [hm] at this
    exact this
  calc (1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹ * expect (fun g : Config N => ((W g) ^ (2 * k)).trace)
      ≤ (1 / (N : ℝ)) * ((N : ℝ) ^ k)⁻¹ * ((N : ℝ) ^ (k + 1) * ((k : ℝ) + 1) ^ (2 * k)) :=
        mul_le_mul_of_nonneg_left hbound (le_of_lt hpos)
    _ = ((k : ℝ) + 1) ^ (2 * k) := by
        field_simp
        ring

/-- A pointwise lower bound passes to the ensemble average. -/
theorem le_expect_of_forall {c : ℝ} {f : Config N → ℝ} (h : ∀ g, c ≤ f g) : c ≤ expect f := by
  have h1 : (Fintype.card (Config N) : ℝ) * c ≤ ∑ g : Config N, f g := by
    calc (Fintype.card (Config N) : ℝ) * c = ∑ _g : Config N, c := by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
      _ ≤ ∑ g : Config N, f g := Finset.sum_le_sum fun g _ => h g
  unfold expect
  rw [le_div_iff₀ (card_config_pos N)]
  linarith

/-- **The even spectral moments are of exact order `N^(k+1)`.**  For every `k ≥ 1`
the expected `2k`-th normalised spectral moment of the Rademacher ensemble lies
between `(1 - 1/N)^k` and `(k+1)^(2k)`: it neither vanishes nor blows up, at any
dimension.  The lower bound is deterministic (power-mean convexity applied to the
exactly self-averaging second moment); the upper bound is the spanning-tree walk
count. -/
theorem expect_normalizedMoment_two_mul_sandwich {k : ℕ} (hk : 1 ≤ k) (hN : 0 < N) :
    (1 - 1 / (N : ℝ)) ^ k
        ≤ expect (fun g : Config N => WignerBridge.normalizedMoment (W g) (2 * k)) ∧
      expect (fun g : Config N => WignerBridge.normalizedMoment (W g) (2 * k))
        ≤ ((k : ℝ) + 1) ^ (2 * k) :=
  ⟨le_expect_of_forall fun g => normalizedMoment_two_mul_ge g hk hN,
    expect_normalizedMoment_two_mul_le hk hN⟩

end RademacherWigner