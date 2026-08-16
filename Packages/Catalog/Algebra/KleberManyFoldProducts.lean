/-
# Many-fold complementary products of monomial symmetric functions

A continuation of `Algebra.KleberComplementaryProducts`.  The quadratic-statistic
triangularity used there for products of *two* monomial symmetric functions is not tied to
two factors: here we prove that products `m_{α_1} ⋯ m_{α_r}` of arbitrarily many monomial
symmetric functions are linearly independent as soon as the multiset unions
`parts α_1 + ⋯ + parts α_r` are pairwise distinct.

## Main results

* `KleberSplit.linearIndependent_msym_prod` — many-fold independence.
* `KleberSplit.linearIndependent_psum_monomials` — corollary: linear independence of
  power-sum monomials `p_{k_1} ⋯ p_{k_r}` indexed by multisets of positive exponents.
-/

import Algebra.KleberComplementaryProducts

namespace KleberSplit

open Finsupp MvPolynomial Finset

variable {N : ℕ} {R : Type*} [CommRing R] {S : Type*} [CommSemiring S]

/-! ### Products of arbitrarily many factors

The mechanism above is not restricted to *two* factors.  We now prove the sharper
statement: products `m_{α_1} ⋯ m_{α_r}` of arbitrarily many monomial symmetric functions
are linearly independent as soon as the multiset unions `parts α_1 + ⋯ + parts α_r` are
pairwise distinct.  For `r = 2` this recovers the theorem above.
-/

lemma card_support_equivMapDomain (e : Equiv.Perm (Fin N)) (b : Exp N) :
    (Finsupp.equivMapDomain e b).support.card = b.support.card := by
  rw [support_equivMapDomain, Finset.card_map]

lemma support_subset_support_sum {κ : Type*} (s : Finset κ) (u : κ → Exp N) {j : κ}
    (hj : j ∈ s) : (u j).support ⊆ (∑ k ∈ s, u k).support := by
  intro i hi
  rw [Finsupp.mem_support_iff, Finsupp.finset_sum_apply]
  have h1 : 0 < u j i := Nat.pos_of_ne_zero (Finsupp.mem_support_iff.1 hi)
  have h2 : (u j) i ≤ ∑ k ∈ s, (u k) i :=
    Finset.single_le_sum (f := fun k => (u k) i) (fun k _ => Nat.zero_le _) hj
  omega

/-- Superadditivity of the quadratic statistic over finite sums. -/
lemma Qstat_sum_le {κ : Type*} [DecidableEq κ] (s : Finset κ) (u : κ → Exp N) :
    ∑ j ∈ s, Qstat (u j) ≤ Qstat (∑ j ∈ s, u j) := by
  induction s using Finset.induction with
  | empty => simp [Qstat]
  | insert j t hj ih =>
      rw [Finset.sum_insert hj, Finset.sum_insert hj, Qstat_add]
      omega

/-- Equality in the superadditivity of `Qstat` forces pairwise disjoint supports. -/
lemma pairwise_disjoint_of_Qstat_sum_eq {κ : Type*} [DecidableEq κ] (s : Finset κ)
    (u : κ → Exp N) (h : Qstat (∑ j ∈ s, u j) = ∑ j ∈ s, Qstat (u j)) :
    ∀ j ∈ s, ∀ k ∈ s, j ≠ k → Disjoint (u j).support (u k).support := by
  induction s using Finset.induction with
  | empty => simp
  | insert j₀ t hj₀ ih =>
      rw [Finset.sum_insert hj₀, Finset.sum_insert hj₀, Qstat_add] at h
      have hle := Qstat_sum_le t u
      have hdot : dotp (u j₀) (∑ k ∈ t, u k) = 0 := by omega
      have heq : Qstat (∑ k ∈ t, u k) = ∑ k ∈ t, Qstat (u k) := by omega
      have hdisj0 : Disjoint (u j₀).support (∑ k ∈ t, u k).support :=
        (dotp_eq_zero_iff _ _).1 hdot
      have hstep : ∀ k ∈ t, Disjoint (u j₀).support (u k).support := fun k hk =>
        hdisj0.mono_right (support_subset_support_sum t u hk)
      intro a ha b hb hab
      rcases Finset.mem_insert.1 ha with rfl | ha'
      · rcases Finset.mem_insert.1 hb with rfl | hb'
        · exact absurd rfl hab
        · exact hstep b hb'
      · rcases Finset.mem_insert.1 hb with rfl | hb'
        · exact (hstep a ha').symm
        · exact ih heq a ha' b hb' hab

/-- Under pairwise disjointness both `parts` and `Qstat` are additive along a finite sum. -/
lemma parts_and_Qstat_sum_of_pairwise_disjoint {κ : Type*} [DecidableEq κ] (s : Finset κ)
    (u : κ → Exp N) (h : ∀ j ∈ s, ∀ k ∈ s, j ≠ k → Disjoint (u j).support (u k).support) :
    parts (∑ j ∈ s, u j) = ∑ j ∈ s, parts (u j) ∧
      Qstat (∑ j ∈ s, u j) = ∑ j ∈ s, Qstat (u j) := by
  induction s using Finset.induction with
  | empty => simp [parts, Qstat]
  | insert j₀ t hj₀ ih =>
      have hsub : ∀ k ∈ t, k ∈ insert j₀ t := fun k hk => Finset.mem_insert_of_mem hk
      have hih := ih (fun a ha b hb hab => h a (hsub a ha) b (hsub b hb) hab)
      have hdisj : Disjoint (u j₀).support (∑ k ∈ t, u k).support := by
        refine Finset.disjoint_right.2 ?_
        intro i hi
        obtain ⟨k, hk, hik⟩ := Finset.mem_biUnion.1 (Finsupp.support_finset_sum hi)
        have hne : j₀ ≠ k := fun hEq => hj₀ (hEq ▸ hk)
        exact Finset.disjoint_right.1
          (h j₀ (Finset.mem_insert_self _ _) k (hsub k hk) hne) hik
      rw [Finset.sum_insert hj₀, Finset.sum_insert hj₀, Finset.sum_insert hj₀,
        parts_add_of_disjoint hdisj, Qstat_add, (dotp_eq_zero_iff _ _).2 hdisj, hih.1, hih.2]
      exact ⟨rfl, by omega⟩

/-- A whole family of exponent vectors that jointly fits into `N` variables can be placed
with pairwise disjoint supports, away from a prescribed set of variables. -/
lemma exists_pairwise_disjoint_placement {κ : Type*} [DecidableEq κ] (s : Finset κ)
    (f : κ → Exp N) (F : Finset (Fin N)) (h : F.card + ∑ j ∈ s, (f j).support.card ≤ N) :
    ∃ u : κ → Exp N, (∀ j ∈ s, u j ∈ orbit (f j)) ∧ (∀ j ∈ s, Disjoint F (u j).support) ∧
      (∀ j ∈ s, ∀ k ∈ s, j ≠ k → Disjoint (u j).support (u k).support) := by
  induction s using Finset.induction generalizing F with
  | empty => exact ⟨fun _ => 0, by simp, by simp, by simp⟩
  | insert j₀ t hj₀ ih =>
      rw [Finset.sum_insert hj₀] at h
      obtain ⟨e₀, he₀⟩ := exists_placement_avoiding F (f j₀) (by omega)
      set u₀ : Exp N := Finsupp.equivMapDomain e₀ (f j₀) with hu₀
      have hcard₀ : u₀.support.card = (f j₀).support.card :=
        card_support_equivMapDomain e₀ (f j₀)
      have hunion : (F ∪ u₀.support).card = F.card + (f j₀).support.card := by
        rw [Finset.card_union_of_disjoint he₀, hcard₀]
      obtain ⟨u, hu_orbit, hu_avoid, hu_pair⟩ := ih (F := F ∪ u₀.support) (by omega)
      refine ⟨Function.update u j₀ u₀, ?_, ?_, ?_⟩
      · intro j hj
        rcases Finset.mem_insert.1 hj with rfl | hj'
        · simpa [hu₀] using equivMapDomain_mem_orbit e₀ (f j)
        · have hne : j ≠ j₀ := fun hEq => hj₀ (hEq ▸ hj')
          simpa [Function.update_of_ne hne] using hu_orbit j hj'
      · intro j hj
        rcases Finset.mem_insert.1 hj with rfl | hj'
        · simpa using he₀
        · have hne : j ≠ j₀ := fun hEq => hj₀ (hEq ▸ hj')
          have := hu_avoid j hj'
          rw [Finset.disjoint_union_left] at this
          simpa [Function.update_of_ne hne] using this.1
      · intro j hj k hk hjk
        have key : ∀ m ∈ t, Disjoint u₀.support (u m).support := by
          intro m hm
          have := hu_avoid m hm
          rw [Finset.disjoint_union_left] at this
          exact this.2
        rcases Finset.mem_insert.1 hj with rfl | hj'
        · rcases Finset.mem_insert.1 hk with rfl | hk'
          · exact absurd rfl hjk
          · have hne : k ≠ j := fun hEq => hj₀ (hEq ▸ hk')
            simpa [Function.update_of_ne hne] using key k hk'
        · rcases Finset.mem_insert.1 hk with rfl | hk'
          · have hne : j ≠ k := fun hEq => hj₀ (hEq ▸ hj')
            simpa [Function.update_of_ne hne] using (key j hj').symm
          · have hnej : j ≠ j₀ := fun hEq => hj₀ (hEq ▸ hj')
            have hnek : k ≠ j₀ := fun hEq => hj₀ (hEq ▸ hk')
            simpa [Function.update_of_ne hnej, Function.update_of_ne hnek] using
              hu_pair j hj' k hk' hjk

/-! #### Coefficients of many-fold products -/

lemma msym_map (d : Exp N) :
    MvPolynomial.map (Nat.castRingHom S) (msym ℕ d) = msym S d := by
  unfold msym
  rw [map_sum]
  refine Finset.sum_congr rfl fun w _ => ?_
  simp [MvPolynomial.map_monomial]

lemma coeff_prod_msym_cast {κ : Type*} (s : Finset κ) (f : κ → Exp N) (w : Exp N) :
    MvPolynomial.coeff w (∏ j ∈ s, msym S (f j))
      = ((MvPolynomial.coeff w (∏ j ∈ s, msym ℕ (f j)) : ℕ) : S) := by
  have : (∏ j ∈ s, msym S (f j))
      = MvPolynomial.map (Nat.castRingHom S) (∏ j ∈ s, msym ℕ (f j)) := by
    rw [map_prod]
    exact Finset.prod_congr rfl fun j _ => (msym_map (f j)).symm
  rw [this, MvPolynomial.coeff_map]
  simp

/-- Every decomposition of a monomial into rearrangements really contributes. -/
lemma coeff_prod_msym_pos {κ : Type*} [DecidableEq κ] (s : Finset κ) (f u : κ → Exp N)
    (hu : ∀ j ∈ s, u j ∈ orbit (f j)) :
    0 < MvPolynomial.coeff (∑ j ∈ s, u j) (∏ j ∈ s, msym ℕ (f j)) := by
  induction s using Finset.induction with
  | empty => simp
  | insert j₀ t hj₀ ih =>
      have hsub : ∀ k ∈ t, k ∈ insert j₀ t := fun k hk => Finset.mem_insert_of_mem hk
      have hpos := ih (fun k hk => hu k (hsub k hk))
      rw [Finset.prod_insert hj₀, Finset.sum_insert hj₀, MvPolynomial.coeff_mul]
      have hmem : (u j₀, ∑ k ∈ t, u k) ∈ Finset.antidiagonal (u j₀ + ∑ k ∈ t, u k) := by
        simp
      have hterm : 0 < MvPolynomial.coeff (u j₀) (msym ℕ (f j₀)) *
          MvPolynomial.coeff (∑ k ∈ t, u k) (∏ j ∈ t, msym ℕ (f j)) := by
        rw [coeff_msym, if_pos (hu j₀ (Finset.mem_insert_self _ _))]
        simpa using hpos
      calc 0 < MvPolynomial.coeff (u j₀) (msym ℕ (f j₀)) *
            MvPolynomial.coeff (∑ k ∈ t, u k) (∏ j ∈ t, msym ℕ (f j)) := hterm
        _ ≤ _ := Finset.single_le_sum
            (f := fun x : Exp N × Exp N => MvPolynomial.coeff x.1 (msym ℕ (f j₀)) *
              MvPolynomial.coeff x.2 (∏ j ∈ t, msym ℕ (f j)))
            (fun x _ => Nat.zero_le _) hmem

/-- Conversely, a monomial of a many-fold product does decompose. -/
lemma exists_decomp_of_coeff_prod_ne_zero {κ : Type*} [DecidableEq κ] (s : Finset κ)
    (f : κ → Exp N) (w : Exp N)
    (h : MvPolynomial.coeff w (∏ j ∈ s, msym ℕ (f j)) ≠ 0) :
    ∃ u : κ → Exp N, (∀ j ∈ s, u j ∈ orbit (f j)) ∧ ∑ j ∈ s, u j = w := by
  induction s using Finset.induction generalizing w with
  | empty =>
      refine ⟨fun _ => 0, by simp, ?_⟩
      simp only [Finset.prod_empty, MvPolynomial.coeff_one] at h
      simp only [Finset.sum_empty]
      by_contra hne
      simp [hne] at h
  | insert j₀ t hj₀ ih =>
      rw [Finset.prod_insert hj₀, MvPolynomial.coeff_mul] at h
      obtain ⟨x, hx, hxne⟩ := Finset.exists_ne_zero_of_sum_ne_zero h
      have hx1 : x.1 ∈ orbit (f j₀) := by
        by_contra hc
        rw [coeff_msym, if_neg hc] at hxne
        simp at hxne
      have hx2 : MvPolynomial.coeff x.2 (∏ j ∈ t, msym ℕ (f j)) ≠ 0 := by
        intro hc
        rw [hc] at hxne
        simp at hxne
      obtain ⟨u, hu, hsum⟩ := ih x.2 hx2
      refine ⟨Function.update u j₀ x.1, ?_, ?_⟩
      · intro j hj
        rcases Finset.mem_insert.1 hj with rfl | hj'
        · simpa using hx1
        · have hne : j ≠ j₀ := fun hEq => hj₀ (hEq ▸ hj')
          simpa [Function.update_of_ne hne] using hu j hj'
      · rw [Finset.sum_insert hj₀, Function.update_self]
        have : ∑ j ∈ t, Function.update u j₀ x.1 j = ∑ j ∈ t, u j := by
          refine Finset.sum_congr rfl fun j hj => ?_
          have hne : j ≠ j₀ := fun hEq => hj₀ (hEq ▸ hj)
          simp [Function.update_of_ne hne]
        rw [this, hsum]
        simpa using (Finset.mem_antidiagonal.1 hx)

/-- **Independence of many-fold products with distinct multiset unions.**

Let `f i j` (`j ∈ s`) be finite families of exponent vectors, one family for each index
`i`, each family jointly fitting into `N` variables.  If the multiset unions
`∑ j ∈ s, parts (f i j)` are pairwise distinct, then the products
`∏ j ∈ s, m_{f i j}` are linearly independent over any characteristic-zero domain.

For `s` of size two this is `linearIndependent_msym_mul`. -/
theorem linearIndependent_msym_prod [IsDomain R] [CharZero R]
    {ι κ : Type*} [Fintype ι] [DecidableEq κ] (s : Finset κ) (f : ι → κ → Exp N)
    (hcard : ∀ i, ∑ j ∈ s, (f i j).support.card ≤ N)
    (hinj : Function.Injective fun i => ∑ j ∈ s, parts (f i j)) :
    LinearIndependent R (fun i => ∏ j ∈ s, msym R (f i j)) := by
  classical
  rw [Fintype.linearIndependent_iff]
  by_contra hcon
  push_neg at hcon
  obtain ⟨g, hg, i₁, hi₁⟩ := hcon
  set S : Finset ι := Finset.univ.filter (fun i => g i ≠ 0) with hS
  have hSne : S.Nonempty := ⟨i₁, by simp [hS, hi₁]⟩
  obtain ⟨i₀, hi₀S, hmin⟩ :=
    S.exists_min_image (fun i => ∑ j ∈ s, Qstat (f i j)) hSne
  have hg₀ : g i₀ ≠ 0 := by simpa [hS] using hi₀S
  obtain ⟨u, hu_orbit, -, hu_pair⟩ :=
    exists_pairwise_disjoint_placement s (f i₀) ∅ (by simpa using hcard i₀)
  set w₀ : Exp N := ∑ j ∈ s, u j with hw₀
  have hu_parts : ∀ j ∈ s, parts (u j) = parts (f i₀ j) := fun j hj =>
    parts_of_mem_orbit (hu_orbit j hj)
  have hu_Q : ∀ j ∈ s, Qstat (u j) = Qstat (f i₀ j) := fun j hj =>
    Qstat_of_mem_orbit (hu_orbit j hj)
  obtain ⟨hpartsw₀', hQw₀'⟩ := parts_and_Qstat_sum_of_pairwise_disjoint s u hu_pair
  have hQw₀ : Qstat w₀ = ∑ j ∈ s, Qstat (f i₀ j) := by
    rw [hw₀, hQw₀']
    exact Finset.sum_congr rfl hu_Q
  have hpartsw₀ : parts w₀ = ∑ j ∈ s, parts (f i₀ j) := by
    rw [hw₀, hpartsw₀']
    exact Finset.sum_congr rfl hu_parts
  -- take the coefficient of `w₀` in the vanishing relation
  have hcoeff := congrArg (MvPolynomial.coeff w₀) hg
  rw [MvPolynomial.coeff_sum] at hcoeff
  simp only [smul_eq_mul, MvPolynomial.coeff_smul, MvPolynomial.coeff_zero] at hcoeff
  have hvanish : ∀ i ∈ Finset.univ, i ≠ i₀ →
      g i * MvPolynomial.coeff w₀ (∏ j ∈ s, msym R (f i j)) = 0 := by
    intro i _ hne
    by_cases hgi : g i = 0
    · simp [hgi]
    have hiS : i ∈ S := by simp [hS, hgi]
    by_cases hc : MvPolynomial.coeff w₀ (∏ j ∈ s, msym R (f i j)) = 0
    · simp [hc]
    exfalso
    rw [coeff_prod_msym_cast] at hc
    have hcnat : MvPolynomial.coeff w₀ (∏ j ∈ s, msym ℕ (f i j)) ≠ 0 := by
      intro h0
      rw [h0] at hc
      simp at hc
    obtain ⟨v, hv_orbit, hv_sum⟩ := exists_decomp_of_coeff_prod_ne_zero s (f i) w₀ hcnat
    have hvQ : ∀ j ∈ s, Qstat (v j) = Qstat (f i j) := fun j hj =>
      Qstat_of_mem_orbit (hv_orbit j hj)
    have hle1 : ∑ j ∈ s, Qstat (f i j) ≤ Qstat w₀ := by
      rw [← hv_sum]
      refine le_trans (le_of_eq ?_) (Qstat_sum_le s v)
      exact (Finset.sum_congr rfl hvQ).symm
    have hle2 : ∑ j ∈ s, Qstat (f i₀ j) ≤ ∑ j ∈ s, Qstat (f i j) := hmin i hiS
    have hEq : Qstat (∑ j ∈ s, v j) = ∑ j ∈ s, Qstat (v j) := by
      rw [hv_sum, Finset.sum_congr rfl hvQ]
      omega
    have hvpair := pairwise_disjoint_of_Qstat_sum_eq s v hEq
    obtain ⟨hvparts, -⟩ := parts_and_Qstat_sum_of_pairwise_disjoint s v hvpair
    have : ∑ j ∈ s, parts (f i j) = ∑ j ∈ s, parts (f i₀ j) := by
      rw [← hpartsw₀, ← hv_sum, hvparts]
      exact Finset.sum_congr rfl fun j hj => (parts_of_mem_orbit (hv_orbit j hj)).symm
    exact hne (hinj this)
  rw [Finset.sum_eq_single_of_mem i₀ (Finset.mem_univ i₀) hvanish] at hcoeff
  have hne0 : MvPolynomial.coeff w₀ (∏ j ∈ s, msym R (f i₀ j)) ≠ 0 := by
    rw [coeff_prod_msym_cast]
    have := coeff_prod_msym_pos s (f i₀) u hu_orbit
    rw [← hw₀] at this
    exact Nat.cast_ne_zero.2 (by omega)
  rcases mul_eq_zero.1 hcoeff with h | h
  · exact hg₀ h
  · exact hne0 h

/-! ### Application: linear independence of power-sum monomials

Since `m_{(k)} = p_k` is the power sum, a product `∏_j p_{k_j}` is a monomial in the power
sums, and its multiset union is exactly the multiset `{k_j}` of exponents.  The many-fold
theorem therefore recovers the linear independence of the power-sum monomials
`p_{k_1} ⋯ p_{k_r}` indexed by multisets of positive integers, provided there are at least
as many variables as factors.
-/

/-- The orbit of a one-row exponent vector consists of all one-row exponent vectors. -/
lemma orbit_single (i : Fin N) (x : ℕ) :
    orbit (Finsupp.single i x) = Finset.univ.image (fun j : Fin N => Finsupp.single j x) := by
  ext w
  simp only [orbit, Finset.mem_image, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨e, rfl⟩
    exact ⟨e i, by rw [Finsupp.equivMapDomain_single]⟩
  · rintro ⟨j, rfl⟩
    exact ⟨Equiv.swap i j, by rw [Finsupp.equivMapDomain_single, Equiv.swap_apply_left]⟩

/-- The power sum `p_k = ∑_j x_j ^ k` in `N` variables. -/
noncomputable def psum (R : Type*) [CommRing R] (N k : ℕ) : MvPolynomial (Fin N) R :=
  ∑ j : Fin N, MvPolynomial.X j ^ k

/-- A one-row monomial symmetric polynomial is a power sum. -/
lemma msym_single_eq_psum (i : Fin N) {x : ℕ} (hx : x ≠ 0) :
    msym R (Finsupp.single i x) = psum R N x := by
  unfold msym psum
  rw [orbit_single, Finset.sum_image (fun a _ b _ hab => Finsupp.single_left_injective hx hab)]
  exact Finset.sum_congr rfl fun j _ => (MvPolynomial.X_pow_eq_monomial).symm

lemma multiset_map_eq_sum_singleton {κ : Type*} (s : Finset κ) (k : κ → ℕ) :
    (s.val.map k : Multiset ℕ) = ∑ j ∈ s, ({k j} : Multiset ℕ) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp
  | cons a s _ ih =>
      rw [Finset.cons_val, Multiset.map_cons, Finset.sum_cons, ih, Multiset.singleton_add]

/-- **Linear independence of power-sum monomials.**

A family of products of power sums `∏_{j ∈ s} p_{k_i j}` (all exponents positive, at least
`s.card` variables available) is linearly independent as soon as the multisets of exponents
`{k_i j : j ∈ s}` are pairwise distinct.  This is a corollary of the many-fold independence
theorem, obtained from `m_{(k)} = p_k`. -/
theorem linearIndependent_psum_monomials {M : ℕ} [IsDomain R] [CharZero R]
    {ι κ : Type*} [Fintype ι] [DecidableEq κ] (s : Finset κ) (k : ι → κ → ℕ)
    (hk : ∀ i, ∀ j ∈ s, k i j ≠ 0) (hcard : s.card ≤ M + 1)
    (hinj : Function.Injective fun i => (s.val.map (k i) : Multiset ℕ)) :
    LinearIndependent R (fun i => ∏ j ∈ s, psum R (M + 1) (k i j)) := by
  set f : ι → κ → Exp (M + 1) := fun i j => Finsupp.single (0 : Fin (M + 1)) (k i j) with hf
  have hprod : ∀ i, ∏ j ∈ s, psum R (M + 1) (k i j) = ∏ j ∈ s, msym R (f i j) :=
    fun i => Finset.prod_congr rfl fun j hj => (msym_single_eq_psum 0 (hk i j hj)).symm
  have hparts : ∀ i, ∑ j ∈ s, parts (f i j) = (s.val.map (k i) : Multiset ℕ) := by
    intro i
    rw [multiset_map_eq_sum_singleton]
    exact Finset.sum_congr rfl fun j hj => by
      rw [hf]; simp [parts_single, hk i j hj]
  have hcard' : ∀ i, ∑ j ∈ s, (f i j).support.card ≤ M + 1 := by
    intro i
    refine le_trans (Finset.sum_le_sum fun j _ => card_support_single_le _ _) ?_
    simpa using hcard
  have := linearIndependent_msym_prod (R := R) s f hcard'
    (by
      intro i₁ i₂ h
      simp only [hparts] at h
      exact hinj h)
  simpa only [hprod] using this

end KleberSplit