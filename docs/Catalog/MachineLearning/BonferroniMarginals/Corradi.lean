import MachineLearning.BonferroniMarginals.Rigidity

/-!
# Which marginals? The Corrádi bound and the Fisher-type consequence

`Core.lean` develops the Bonferroni machinery for an *arbitrary* finite family;
the content of the conjecture is therefore entirely in **which marginals are fed
into it**.  This file feeds in the two standard hypotheses of design theory and
of ensemble learning:

* a uniform lower bound `m ≤ |Aᵢ|` on the **first** marginals, and
* a uniform upper bound `|Aᵢ ∩ Aⱼ| ≤ t` (`i ≠ j`) on the **second** marginals,

and extracts the sharp conclusions.

Main results.

* `card_cover_corradi` — **Corrádi's inequality**, division-free:
  `k·m² ≤ |cover| · (m + (k−1)·t)`, where `k` is the number of sets.
  Equivalently `|⋃ᵢ Aᵢ| ≥ k m² / (m + (k−1) t)`.
* `fisher_type_bound` — turning the same data around: if the ambient union is
  small (`N·t < m²`) then the *number of sets* is bounded,
  `k · (m² − N·t) ≤ N · (m − t)`.  This is the counting principle behind Fisher's
  inequality and behind Plotkin-type bounds in coding theory.
* `corradi_tight_of_pairwiseDisjoint`, `corradi_tight_of_constant` — the bound is
  attained at *both* extremes of the correlation scale (`t = 0` partitions and
  `t = m` totally correlated families), so no better bound is expressible in the
  marginal data `(k, m, t)` alone.
* `ensemble_coverage_bound` — the machine-learning reading: `k` hypotheses each
  failing on at least `m` of `N` samples, with pairwise co-failure at most `t`,
  must jointly fail on many distinct samples.

The proof route is: `sq_sum_card_le_card_cover_mul_sum_prod` (Cauchy–Schwarz on
the multiplicity function) + monotonicity of `S ↦ S²/(S+c)` + the marginal
hypotheses.
-/

namespace BonferroniMarginals

open Finset

variable {Ω ι : Type*} [DecidableEq Ω]
variable {I : Finset ι} {A : ι → Finset Ω}

/-! ## Two arithmetic lemmas -/

/-- Monotonicity of `S ↦ S²/(S+c)` in the division-free form needed below:
if `S² ≤ N·(S+c)` and `u ≤ S`, then already `u² ≤ N·(u+c)`. -/
lemma sq_le_mul_add_of_le {N S u c : ℕ} (h : S ^ 2 ≤ N * (S + c)) (hu : u ≤ S) :
    u ^ 2 ≤ N * (u + c) := by
  rcases Nat.eq_zero_or_pos (S + c) with hSc | hSc
  · have hS : S = 0 := by omega
    have hu0 : u = 0 := by omega
    have hc : c = 0 := by omega
    simp [hu0, hc]
  · -- work in `ℤ` and multiply the goal by the positive number `S + c`
    by_contra hcon
    push_neg at hcon
    have hZ : (N : ℤ) * (u + c) + 1 ≤ (u : ℤ) ^ 2 := by exact_mod_cast hcon
    have hZ' : (S : ℤ) ^ 2 ≤ (N : ℤ) * ((S : ℤ) + c) := by exact_mod_cast h
    have huS : (u : ℤ) ≤ S := by exact_mod_cast hu
    have hSc' : (0 : ℤ) < (S : ℤ) + c := by exact_mod_cast hSc
    have hu0 : (0 : ℤ) ≤ u := Int.natCast_nonneg u
    have hc0 : (0 : ℤ) ≤ c := Int.natCast_nonneg c
    nlinarith [mul_nonneg (mul_nonneg hu0 (le_trans hu0 huS)) (sub_nonneg.mpr huS),
      mul_nonneg hc0 (mul_nonneg (sub_nonneg.mpr huS) (add_nonneg hu0 (le_trans hu0 huS))),
      mul_le_mul_of_nonneg_left hZ' (add_nonneg hu0 hc0)]

/-- Truncated-subtraction bookkeeping. -/
lemma nat_sub_le_sub_of_add_le {a b c d : ℕ} (h : a + d ≤ c + b) (hd : d ≤ c) :
    a - b ≤ c - d := by omega

/-! ## Corrádi's inequality -/

/-- **Corrádi's inequality (division-free).**  If a family of `k` sets has all
first marginals at least `m` and all second marginals at most `t`, then
`k · m² ≤ |⋃ᵢ Aᵢ| · (m + (k−1)·t)`.

This is the sharp second-order-marginal lower bound on the union: it is what the
Bonferroni machinery yields once the marginals `(m, t)` are fed into the
Cauchy–Schwarz form rather than the linear form. -/
theorem card_cover_corradi [DecidableEq ι] {m t : ℕ}
    (hm : ∀ i ∈ I, m ≤ (A i).card)
    (ht : ∀ p ∈ I.offDiag, (A p.1 ∩ A p.2).card ≤ t) :
    I.card * m ^ 2 ≤ (cover I A).card * (m + (I.card - 1) * t) := by
  classical
  set k := I.card with hk
  set N := (cover I A).card with hN
  set S := ∑ i ∈ I, (A i).card with hS
  -- lower bound on the first marginal mass
  have hSlow : k * m ≤ S := by
    have := Finset.card_nsmul_le_sum I (fun i => (A i).card) m hm
    simpa [hS, hk, mul_comm] using this
  -- upper bound on the pairwise mass
  have hoff : ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card ≤ (k * k - k) * t := by
    have h1 := Finset.sum_le_card_nsmul I.offDiag (fun p => (A p.1 ∩ A p.2).card) t ht
    simpa [Finset.offDiag_card, hk, mul_comm] using h1
  -- Cauchy–Schwarz from the core file
  have hCS := sq_sum_card_le_card_cover_mul_sum_prod I A
  rw [sum_prod_eq_sum_card_add_offDiag] at hCS
  have hCS' : S ^ 2 ≤ N * (S + (k * k - k) * t) := by
    refine le_trans hCS ?_
    exact Nat.mul_le_mul_left N (Nat.add_le_add_left hoff _)
  -- push the bound down from `S` to `k * m`
  have hstep := sq_le_mul_add_of_le hCS' hSlow
  -- unravel: `(k m)² ≤ N (k m + k (k-1) t) = k · N · (m + (k-1) t)`
  rcases Nat.eq_zero_or_pos k with hk0 | hk0
  · simp [hk0]
  · have hfac : k * m + (k * k - k) * t = k * (m + (k - 1) * t) := by
      have : k * k - k = k * (k - 1) := by
        cases k with
        | zero => simp
        | succ n => simp [Nat.mul_succ, Nat.mul_comm]
      rw [this]
      ring
    rw [hfac] at hstep
    have hstep' : k * (k * m ^ 2) ≤ k * (N * (m + (k - 1) * t)) := by
      calc k * (k * m ^ 2) = (k * m) ^ 2 := by ring
        _ ≤ N * (k * (m + (k - 1) * t)) := hstep
        _ = k * (N * (m + (k - 1) * t)) := by ring
    exact Nat.le_of_mul_le_mul_left hstep' hk0

/-- **Fisher-type counting bound.**  Reading Corrádi's inequality as a bound on
the *number of sets*: if the union has `N` points, the first marginals are at
least `m`, the second marginals at most `t`, and the "design regime" `N·t < m²`
holds, then `k · (m² − N·t) ≤ N · (m − t)`.

In particular `k ≤ N(m−t)/(m²−Nt)`: sets that are large and almost disjoint
cannot be numerous. -/
theorem fisher_type_bound [DecidableEq ι] {m t : ℕ}
    (hm : ∀ i ∈ I, m ≤ (A i).card)
    (ht : ∀ p ∈ I.offDiag, (A p.1 ∩ A p.2).card ≤ t)
    (htm : t ≤ m) :
    I.card * (m ^ 2 - (cover I A).card * t)
      ≤ (cover I A).card * (m - t) := by
  classical
  set k := I.card with hk
  set N := (cover I A).card with hN
  rcases Nat.eq_zero_or_pos k with hk0 | hk0
  · simp [hk0]
  have hmain := card_cover_corradi (I := I) (A := A) hm ht
  rw [← hk, ← hN] at hmain
  -- `k m² ≤ N (m + (k-1) t) = N m + k (N t) − N t`
  have hexp : N * (m + (k - 1) * t) + N * t = N * m + k * (N * t) := by
    have hk1 : k - 1 + 1 = k := by omega
    calc N * (m + (k - 1) * t) + N * t = N * m + ((k - 1) + 1) * (N * t) := by ring
      _ = N * m + k * (N * t) := by rw [hk1]
  have hadd : k * m ^ 2 + N * t ≤ N * m + k * (N * t) := by
    calc k * m ^ 2 + N * t ≤ N * (m + (k - 1) * t) + N * t :=
          Nat.add_le_add_right hmain _
      _ = N * m + k * (N * t) := hexp
  have e1 : k * (m ^ 2 - N * t) = k * m ^ 2 - k * (N * t) := by rw [Nat.mul_sub]
  have e2 : N * (m - t) = N * m - N * t := by rw [Nat.mul_sub]
  rw [e1, e2]
  exact nat_sub_le_sub_of_add_le hadd (Nat.mul_le_mul_left N htm)

/-! ## Sharpness at both ends of the correlation scale -/

/-- **Tightness at `t = 0`.**  For a pairwise disjoint family of sets of size
exactly `m`, Corrádi's inequality is an equality. -/
theorem corradi_tight_of_pairwiseDisjoint {m : ℕ}
    (hm : ∀ i ∈ I, (A i).card = m)
    (hdisj : ∀ i ∈ I, ∀ j ∈ I, i ≠ j → Disjoint (A i) (A j)) :
    I.card * m ^ 2 = (cover I A).card * (m + (I.card - 1) * 0) := by
  classical
  have hcard : (cover I A).card = ∑ i ∈ I, (A i).card := by
    rw [cover]
    exact Finset.card_biUnion (fun i hi j hj hij => hdisj i hi j hj hij)
  rw [hcard, Finset.sum_congr rfl hm]
  simp only [Finset.sum_const, smul_eq_mul, mul_zero, add_zero, sq]
  ring

/-- **Tightness at `t = m`.**  For the totally correlated family (all members
equal to one set `B` of size `m`), Corrádi's inequality is again an equality:
`k·m² = |B| · (m + (k−1)·m)`. -/
theorem corradi_tight_of_constant {m : ℕ} {B : Finset Ω} (hB : B.card = m)
    (hA : ∀ i ∈ I, A i = B) (hI : I.Nonempty) :
    I.card * m ^ 2 = (cover I A).card * (m + (I.card - 1) * m) := by
  classical
  have hcover : cover I A = B := by
    apply Finset.Subset.antisymm
    · intro x hx
      obtain ⟨i, hi, hxi⟩ := mem_cover.mp hx
      rwa [hA i hi] at hxi
    · obtain ⟨i, hi⟩ := hI
      intro x hx
      exact mem_cover.mpr ⟨i, hi, by rw [hA i hi]; exact hx⟩
  have hk1 : I.card - 1 + 1 = I.card := by
    have := Finset.card_pos.mpr hI
    omega
  rw [hcover, hB]
  calc I.card * m ^ 2 = ((I.card - 1) + 1) * m ^ 2 := by rw [hk1]
    _ = m * (m + (I.card - 1) * m) := by ring

/-! ## The machine-learning corollary -/

/-- **Ensemble coverage bound.**  Let `k` hypotheses be given, each failing on at
least `m` samples of a finite sample space, with any two hypotheses failing
simultaneously on at most `t` samples.  Then the set of samples on which the
ensemble is not unanimously correct has size at least `k·m² / (m + (k−1)·t)`,
in the division-free form `k·m² ≤ |failures| · (m + (k−1)·t)`.

In the *uncorrelated* regime `t = 0` this says the failures occupy `k·m`
distinct samples; in the *fully correlated* regime `t = m` it degenerates to the
trivial `m ≤ |failures|`.  The bound therefore interpolates exactly between
"union bound" and "no information", governed by the second marginal `t`. -/
theorem ensemble_coverage_bound [DecidableEq ι] {m t : ℕ} (bad : ι → Finset Ω) (H : Finset ι)
    (hm : ∀ h ∈ H, m ≤ (bad h).card)
    (ht : ∀ p ∈ H.offDiag, (bad p.1 ∩ bad p.2).card ≤ t) :
    H.card * m ^ 2 ≤ (cover H bad).card * (m + (H.card - 1) * t) :=
  card_cover_corradi hm ht

/-- Sanity specialisation: with `t = 0` the ensemble bound recovers the exact
disjoint count `k · m ≤ |failures|`. -/
theorem ensemble_coverage_disjoint [DecidableEq ι] {m : ℕ} (bad : ι → Finset Ω) (H : Finset ι)
    (hm : ∀ h ∈ H, m ≤ (bad h).card)
    (ht : ∀ p ∈ H.offDiag, (bad p.1 ∩ bad p.2).card ≤ 0) (hm0 : 0 < m) :
    H.card * m ≤ (cover H bad).card := by
  have h := ensemble_coverage_bound bad H hm ht
  simp only [mul_zero, add_zero] at h
  have h' : H.card * m * m ≤ (cover H bad).card * m := by
    calc H.card * m * m = H.card * m ^ 2 := by ring
      _ ≤ (cover H bad).card * m := h
  exact Nat.le_of_mul_le_mul_right h' hm0

end BonferroniMarginals