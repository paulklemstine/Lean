/-
# The tropical characteristic polynomial and its roots

For a max-plus matrix `A` on an `n`-element index set the tropical characteristic
polynomial is

  `p_A(x) = max_{0 ≤ k ≤ n} ( c_k + (n - k)·x )`,   `c_k = max_{|s| = k, σ(s) = s} Σ_{i ∈ s} A i (σ i)`,

the coefficient `c_k` being the tropical determinant of the best principal `k × k`
minor (`charCoeff`).  A point `x` is a **tropical root** when the maximum defining
`p_A(x)` is attained at two different degrees `k` (the standard corner-locus
definition of a root of a tropical polynomial).

Main results:

* `charCoeff_card_eq_tdet` : the top coefficient is the tropical determinant;
* `charCoeff_le_of_eigen`  : if `lam` is an eigenvalue then `c_k ≤ k·lam` for all `k`;
* `exists_charCoeff_eq_of_eigen` : equality `c_k = k·lam` holds for some `1 ≤ k ≤ n`,
  witnessed by the critical cycle turned into a genuine permutation;
* `eigen_isTropicalRoot` : **every tropical eigenvalue is a root of the tropical
  characteristic polynomial**, with the maximum attained both at degree `0` and at
  the length of a critical cycle, and `p_A(lam) = n·lam`.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalEigenvalue

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The weight of the permutation `σ` restricted to the principal minor on `s`. -/
def minorWeight (A : Matrix ι ι ℝ) (s : Finset ι) (σ : Equiv.Perm ι) : ℝ := ∑ i ∈ s, A i (σ i)

/-- Pairs `(s, σ)` with `|s| = k` and `σ` mapping `s` to itself: these index the
principal `k × k` minors together with a permutation of the minor. -/
noncomputable def admPairs (ι : Type*) [Fintype ι] [DecidableEq ι] (k : ℕ) :
    Finset (Finset ι × Equiv.Perm ι) :=
  Finset.univ.filter (fun p => p.1.card = k ∧ ∀ i ∈ p.1, p.2 i ∈ p.1)

theorem mem_admPairs {k : ℕ} {s : Finset ι} {σ : Equiv.Perm ι} :
    (s, σ) ∈ admPairs ι k ↔ s.card = k ∧ ∀ i ∈ s, σ i ∈ s := by
  simp [admPairs]

theorem admPairs_nonempty {k : ℕ} (hk : k ≤ Fintype.card ι) : (admPairs ι k).Nonempty := by
  obtain ⟨s, _, hs⟩ := Finset.exists_subset_card_eq
    (s := (Finset.univ : Finset ι)) (n := k) (by simpa using hk)
  exact ⟨(s, 1), mem_admPairs.mpr ⟨hs, fun i hi => by simpa using hi⟩⟩

/-- The `k`-th coefficient of the tropical characteristic polynomial: the tropical
determinant of the best principal `k × k` minor. -/
noncomputable def charCoeff (A : Matrix ι ι ℝ) (k : ℕ) : ℝ :=
  if h : (admPairs ι k).Nonempty then (admPairs ι k).sup' h (fun p => minorWeight A p.1 p.2)
  else 0

theorem le_charCoeff (A : Matrix ι ι ℝ) {k : ℕ} {s : Finset ι} {σ : Equiv.Perm ι}
    (hp : (s, σ) ∈ admPairs ι k) : minorWeight A s σ ≤ charCoeff A k := by
  have hne : (admPairs ι k).Nonempty := ⟨(s, σ), hp⟩
  rw [charCoeff, dif_pos hne]
  exact Finset.le_sup' (fun p => minorWeight A p.1 p.2) hp

theorem charCoeff_le (A : Matrix ι ι ℝ) {k : ℕ} {c : ℝ} (hne : (admPairs ι k).Nonempty)
    (h : ∀ p ∈ admPairs ι k, minorWeight A p.1 p.2 ≤ c) : charCoeff A k ≤ c := by
  rw [charCoeff, dif_pos hne]
  exact Finset.sup'_le _ _ h

/-- Degree-`0` coefficient: the empty minor has weight `0`. -/
@[simp] theorem charCoeff_zero (A : Matrix ι ι ℝ) : charCoeff A 0 = 0 := by
  have hne : (admPairs ι 0).Nonempty :=
    ⟨(∅, 1), mem_admPairs.mpr ⟨by simp, by simp⟩⟩
  refine le_antisymm (charCoeff_le A hne ?_) ?_
  · rintro ⟨s, σ⟩ hp
    rw [mem_admPairs] at hp
    have : s = ∅ := Finset.card_eq_zero.mp hp.1
    simp [minorWeight, this]
  · have hmem : ((∅ : Finset ι), (1 : Equiv.Perm ι)) ∈ admPairs ι 0 :=
      mem_admPairs.mpr ⟨by simp, by simp⟩
    simpa [minorWeight] using le_charCoeff A hmem

/-- The top coefficient of the tropical characteristic polynomial is the tropical
determinant. -/
theorem charCoeff_card_eq_tdet (A : Matrix ι ι ℝ) :
    charCoeff A (Fintype.card ι) = tdet A := by
  have hne : (admPairs ι (Fintype.card ι)).Nonempty := admPairs_nonempty le_rfl
  refine le_antisymm (charCoeff_le A hne ?_) ?_
  · rintro ⟨s, σ⟩ hp
    rw [mem_admPairs] at hp
    have hs : s = Finset.univ := Finset.eq_univ_of_card s hp.1
    simpa [minorWeight, hs, permWeight] using permWeight_le_tdet A σ
  · obtain ⟨σ, hσ⟩ := exists_permWeight_eq_tdet A
    have hmem : ((Finset.univ : Finset ι), σ) ∈ admPairs ι (Fintype.card ι) :=
      mem_admPairs.mpr ⟨by simp, by simp⟩
    have hle := le_charCoeff A hmem
    rw [hσ]
    simpa [minorWeight, permWeight] using hle

section Eigen

variable [Nonempty ι] {A : Matrix ι ι ℝ} {lam : ℝ} {v : ι → ℝ}

omit [Fintype ι] [Nonempty ι] in
/-- If `σ` maps the finite set `s` to itself then it permutes `s`, so sums of any
function over `s` are invariant under `σ`. -/
theorem sum_comp_of_mapsTo {s : Finset ι} {σ : Equiv.Perm ι} (hσ : ∀ i ∈ s, σ i ∈ s)
    (g : ι → ℝ) : ∑ i ∈ s, g (σ i) = ∑ i ∈ s, g i := by
  classical
  have himg : s.image σ = s := by
    apply Finset.eq_of_subset_of_card_le
    · intro x hx
      obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hx
      exact hσ i hi
    · rw [Finset.card_image_of_injective _ σ.injective]
  calc ∑ i ∈ s, g (σ i) = ∑ x ∈ s.image σ, g x :=
        (Finset.sum_image (fun a _ b _ h => σ.injective h)).symm
    _ = ∑ i ∈ s, g i := by rw [himg]

/-- **Upper bound on the characteristic coefficients**: an eigenvalue `lam` forces
`c_k ≤ k · lam`.  (Each cell of the minor loses `lam` plus a telescoping eigenvector
difference, and the differences cancel because `σ` permutes `s`.) -/
theorem charCoeff_le_of_eigen (h : IsTropEigen A lam v) {k : ℕ} (hk : k ≤ Fintype.card ι) :
    charCoeff A k ≤ k * lam := by
  have hne : (admPairs ι k).Nonempty := admPairs_nonempty hk
  rw [charCoeff, dif_pos hne]
  refine Finset.sup'_le _ _ ?_
  rintro ⟨s, σ⟩ hp
  rw [mem_admPairs] at hp
  obtain ⟨hcard, hmaps⟩ := hp
  have hbound : ∑ i ∈ s, A i (σ i) ≤ ∑ i ∈ s, (lam + (v i - v (σ i))) := by
    refine Finset.sum_le_sum fun i _ => ?_
    have := h.le_of i (σ i)
    linarith
  have hcancel : ∑ i ∈ s, (lam + (v i - v (σ i))) = k * lam := by
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, sum_comp_of_mapsTo hmaps v]
    simp [hcard, mul_comm]
  simpa [minorWeight, hcancel] using hbound.trans_eq hcancel

omit [Nonempty ι] in
/-- Extend a self-injective self-map of `s` to a permutation of the whole index set. -/
theorem exists_perm_of_mapsTo {s : Finset ι} {f : ι → ι} (hmaps : ∀ i ∈ s, f i ∈ s)
    (hinj : Set.InjOn f s) : ∃ σ : Equiv.Perm ι, ∀ i ∈ s, σ i = f i := by
  classical
  set g : ι → ι := fun x => if x ∈ s then f x else x with hg
  have hgi : Function.Injective g := by
    intro x y hxy
    by_cases hx : x ∈ s <;> by_cases hy : y ∈ s
    · simp only [hg, if_pos hx, if_pos hy] at hxy
      exact hinj hx hy hxy
    · simp only [hg, if_pos hx, if_neg hy] at hxy
      exact absurd (hxy ▸ hmaps x hx) hy
    · simp only [hg, if_neg hx, if_pos hy] at hxy
      exact absurd (hxy ▸ hmaps y hy) hx
    · simpa only [hg, if_neg hx, if_neg hy] using hxy
  refine ⟨Equiv.ofBijective g (Finite.injective_iff_bijective.mp hgi), fun i hi => ?_⟩
  simp [Equiv.ofBijective, hg, hi]

/-- **The critical cycle realises a characteristic coefficient**: for some
`1 ≤ k ≤ n` we have `c_k = k · lam`. -/
theorem exists_charCoeff_eq_of_eigen (h : IsTropEigen A lam v) :
    ∃ k : ℕ, 0 < k ∧ k ≤ Fintype.card ι ∧ charCoeff A k = k * lam := by
  classical
  obtain ⟨f, y, p, hp0, hp, hinj, hf, hw⟩ := h.exists_critical_cycle
  set s : Finset ι := (Finset.range p).image (fun t => f^[t] y) with hs
  have hcard : s.card = p := by
    rw [hs, Finset.card_image_of_injOn hinj, Finset.card_range]
  have hperiodic : Function.IsPeriodicPt f p y := hp
  have hmod : ∀ m : ℕ, f^[m % p] y = f^[m] y := hperiodic.iterate_mod_apply
  have hmaps : ∀ i ∈ s, f i ∈ s := by
    intro i hi
    rw [hs, Finset.mem_image] at hi
    obtain ⟨t, ht, rfl⟩ := hi
    rw [Finset.mem_range] at ht
    have hfi : f (f^[t] y) = f^[t + 1] y := (Function.iterate_succ_apply' f t y).symm
    rw [hfi, hs, Finset.mem_image]
    refine ⟨(t + 1) % p, Finset.mem_range.mpr (Nat.mod_lt _ hp0), hmod (t + 1)⟩
  have hinjf : Set.InjOn f s := by
    intro a ha b hb hab
    rw [hs, Finset.coe_image] at ha hb
    obtain ⟨t, ht, rfl⟩ := ha
    obtain ⟨u, hu, rfl⟩ := hb
    simp only [Finset.coe_range, Set.mem_Iio] at ht hu
    have e1 : f (f^[t] y) = f^[(t + 1) % p] y := by
      rw [hmod (t + 1), Function.iterate_succ_apply']
    have e2 : f (f^[u] y) = f^[(u + 1) % p] y := by
      rw [hmod (u + 1), Function.iterate_succ_apply']
    rw [e1, e2] at hab
    have h1 : (t + 1) % p ∈ (Finset.range p : Finset ℕ) :=
      Finset.mem_range.mpr (Nat.mod_lt _ hp0)
    have h2 : (u + 1) % p ∈ (Finset.range p : Finset ℕ) :=
      Finset.mem_range.mpr (Nat.mod_lt _ hp0)
    have hmodeq : (t + 1) % p = (u + 1) % p := hinj (by simpa using h1) (by simpa using h2) hab
    have htu : t = u := by
      have hcase1 : t + 1 < p ∨ t + 1 = p := by omega
      have hcase2 : u + 1 < p ∨ u + 1 = p := by omega
      rcases hcase1 with h1' | h1' <;> rcases hcase2 with h2' | h2'
      · rw [Nat.mod_eq_of_lt h1', Nat.mod_eq_of_lt h2'] at hmodeq; omega
      · rw [Nat.mod_eq_of_lt h1', h2', Nat.mod_self] at hmodeq; omega
      · rw [Nat.mod_eq_of_lt h2', h1', Nat.mod_self] at hmodeq; omega
      · omega
    rw [htu]
  obtain ⟨σ, hσ⟩ := exists_perm_of_mapsTo hmaps hinjf
  have hmem : (s, σ) ∈ admPairs ι p :=
    mem_admPairs.mpr ⟨hcard, fun i hi => by rw [hσ i hi]; exact hmaps i hi⟩
  have hweight : minorWeight A s σ = p * lam := by
    have : minorWeight A s σ = ∑ i ∈ s, A i (f i) := by
      refine Finset.sum_congr rfl fun i hi => ?_
      rw [hσ i hi]
    rw [this, hs, Finset.sum_image hinj, ← hw, pathWeight]
    refine Finset.sum_congr rfl fun t _ => ?_
    rw [Function.iterate_succ_apply']
  refine ⟨p, hp0, ?_, le_antisymm ?_ ?_⟩
  · rw [← hcard]; exact Finset.card_le_univ s
  · exact charCoeff_le_of_eigen h (by rw [← hcard]; exact Finset.card_le_univ s)
  · rw [← hweight]; exact le_charCoeff A hmem

end Eigen

/-- Value of the tropical characteristic polynomial `p_A(x)`. -/
noncomputable def charPolyVal (A : Matrix ι ι ℝ) (x : ℝ) : ℝ :=
  (Finset.range (Fintype.card ι + 1)).sup' (by simp)
    (fun k => charCoeff A k + ((Fintype.card ι : ℝ) - k) * x)

/-- `x` is a **tropical root** of the characteristic polynomial of `A` if the maximum
defining `p_A(x)` is attained at two different degrees. -/
def IsTropicalRoot (A : Matrix ι ι ℝ) (x : ℝ) : Prop :=
  ∃ k₁ k₂ : ℕ, k₁ ≤ Fintype.card ι ∧ k₂ ≤ Fintype.card ι ∧ k₁ ≠ k₂ ∧
    charCoeff A k₁ + ((Fintype.card ι : ℝ) - k₁) * x = charPolyVal A x ∧
    charCoeff A k₂ + ((Fintype.card ι : ℝ) - k₂) * x = charPolyVal A x

/-- **Tropical eigenvalues are roots of the tropical characteristic polynomial.**
At `x = lam` every degree contributes at most `n·lam`, and the degrees `0` and
`k` (the length of a critical cycle) both attain that value. -/
theorem eigen_isTropicalRoot [Nonempty ι] {A : Matrix ι ι ℝ} {lam : ℝ} {v : ι → ℝ}
    (h : IsTropEigen A lam v) :
    IsTropicalRoot A lam ∧ charPolyVal A lam = (Fintype.card ι : ℝ) * lam := by
  classical
  obtain ⟨k, hk0, hkn, hkeq⟩ := exists_charCoeff_eq_of_eigen h
  have hupper : charPolyVal A lam ≤ (Fintype.card ι : ℝ) * lam := by
    rw [charPolyVal]
    refine Finset.sup'_le _ _ fun j hj => ?_
    rw [Finset.mem_range] at hj
    have hj' : j ≤ Fintype.card ι := by omega
    have := charCoeff_le_of_eigen h hj'
    nlinarith [this]
  have hzero : charCoeff A 0 + ((Fintype.card ι : ℝ) - ((0 : ℕ) : ℝ)) * lam
      = (Fintype.card ι : ℝ) * lam := by
    simp
  have hk' : charCoeff A k + ((Fintype.card ι : ℝ) - k) * lam = (Fintype.card ι : ℝ) * lam := by
    rw [hkeq]; ring
  have hmem0 : (0 : ℕ) ∈ Finset.range (Fintype.card ι + 1) := by simp
  have hmemk : k ∈ Finset.range (Fintype.card ι + 1) := Finset.mem_range.mpr (by omega)
  have hlow : (Fintype.card ι : ℝ) * lam ≤ charPolyVal A lam := by
    rw [← hzero, charPolyVal]
    exact Finset.le_sup' (fun j : ℕ => charCoeff A j + ((Fintype.card ι : ℝ) - j) * lam) hmem0
  have hval : charPolyVal A lam = (Fintype.card ι : ℝ) * lam := le_antisymm hupper hlow
  refine ⟨⟨0, k, Nat.zero_le _, hkn, by omega, ?_, ?_⟩, hval⟩
  · rw [hval]; simp
  · rw [hval]; exact hk'

end TropicalLA