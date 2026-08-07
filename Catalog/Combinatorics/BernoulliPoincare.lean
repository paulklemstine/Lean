/-
# A Poincaré inequality for Bernoulli site measures and the Russo differential
inequality

This is the deepest layer of the thread.  The catalog proves Russo's formula
(`Catalog/Combinatorics/FiniteRussoFormula.lean`), which expresses the
derivative of the Bernoulli probability of an increasing event as the sum of the
pivotal probabilities.  Russo's formula alone gives monotonicity; it gives no
*lower* bound on the derivative in terms of the probability itself, and hence no
control on the width of the threshold.

Here we prove such a lower bound: the **variance–influence (Poincaré /
Efron–Stein) inequality**

`bernProb p A * (1 - bernProb p A) ≤ p * (1-p) * ∑ v, bernProb p (pivotalSet A v)`,

equivalently, via Russo's formula, the **differential inequality**

`P (1 - P) ≤ p (1-p) P'`   (`bernProb_variance_le_deriv`).

The proof is a purely combinatorial *hybrid path* argument, which is the
martingale proof of the Efron–Stein inequality made discrete and union-bound
based:

1. fix an enumeration `rank` of the sites and, for two independent
   configurations `η, ξ`, consider the hybrid family that follows `η` on the
   sites of small rank and `ξ` on the sites of large rank;
2. if `η ∈ A` and `ξ ∉ A`, the hybrid path crosses the boundary of `A` at some
   site `v`, and at the crossing site `v` is pivotal, `η v` is open and `ξ v` is
   closed (`exists_crossing_site`);
3. summing the resulting union bound and factorizing the independent pair
   measure by the coordinatewise pushforward formula
   (`sum_prod_pushforward_dep`) turns each crossing term into
   `p (1-p) * bernProb p (pivotalSet A v)` (`sum_crossTerm`).

As a consequence the logistic derivative of the Bernoulli polynomial is at least
`1 / (p (1-p))`, which is the quantitative sharp-threshold statement
`logit_deriv_lower_bound`.

## Main results

* `sum_prod_pushforward_dep`: pushforward formula with a site-dependent map.
* `exists_crossing_site`: the hybrid path crosses at a pivotal site.
* `crossTerm_bound`: the resulting pointwise union bound.
* `sum_crossTerm`: exact evaluation of one crossing term.
* `bernProb_poincare`: the variance–influence inequality.
* `bernProb_variance_le_deriv`: the Russo differential inequality.
* `logit_deriv_lower_bound`: the logistic form of the differential inequality.
* `crossing_variance_le_deriv`: the grid-crossing instance.
-/

import Combinatorics.InhomogeneousSprinkling

open Finset

namespace BernoulliThresholdCoupling

/-! ## Pushforward with a site-dependent alphabet map -/

/-- **Coordinatewise pushforward, site-dependent version.**  Same as
`sum_prod_pushforward`, but the alphabet map is allowed to depend on the site. -/
theorem sum_prod_pushforward_dep {ι K L : Type*} [Fintype ι] [DecidableEq ι]
    [Fintype K] [DecidableEq K] [Fintype L] [DecidableEq L]
    (W : ι → K → ℝ) (g : ι → K → L) (f : (ι → L) → ℝ) :
    ∑ c : ι → K, (∏ v, W v (c v)) * f (fun v => g v (c v))
      = ∑ η : ι → L, (∏ v, ∑ k ∈ univ.filter (fun k => g v k = η v), W v k) * f η := by
  classical
  rw [← Finset.sum_fiberwise (s := (univ : Finset (ι → K)))
      (g := fun c => fun v => g v (c v))
      (f := fun c => (∏ v, W v (c v)) * f (fun v => g v (c v)))]
  refine Finset.sum_congr rfl fun η _ => ?_
  have hfib : (univ.filter fun c : ι → K => (fun v => g v (c v)) = η)
      = Fintype.piFinset (fun v => univ.filter (fun k => g v k = η v)) := by
    ext c
    simp [Fintype.mem_piFinset, funext_iff]
  rw [hfib, Finset.prod_univ_sum, Finset.sum_mul]
  refine Finset.sum_congr rfl fun c hc => ?_
  rw [Fintype.mem_piFinset] at hc
  have hce : (fun v => g v (c v)) = η := funext fun v => by simpa using hc v
  rw [hce]

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The hybrid path -/

/-- The hybrid configuration that follows `η` on the sites of rank smaller than
that of `v` and `ξ` elsewhere. -/
def hybrid (rank : ι → ℕ) (v : ι) (η ξ : ι → Bool) : ι → Bool :=
  fun u => if rank u < rank v then η u else ξ u

/-- The hybrid path indexed by a rank threshold. -/
def hybridAt (rank : ι → ℕ) (k : ℕ) (η ξ : ι → Bool) : ι → Bool :=
  fun u => if rank u < k then η u else ξ u

omit [Fintype ι] [DecidableEq ι] in
theorem hybridAt_zero (rank : ι → ℕ) (η ξ : ι → Bool) :
    hybridAt rank 0 η ξ = ξ := by
  funext u; simp [hybridAt]

omit [Fintype ι] [DecidableEq ι] in
theorem hybridAt_of_lt (rank : ι → ℕ) (η ξ : ι → Bool) {N : ℕ}
    (hN : ∀ u, rank u < N) : hybridAt rank N η ξ = η := by
  funext u; simp [hybridAt, hN u]

/-- **The hybrid path crosses the boundary of an increasing event at a pivotal
site.**  If `η ∈ A` and `ξ ∉ A`, there is a site `v` that is open in `η`, closed
in `ξ`, and pivotal for the hybrid configuration at `v`. -/
theorem exists_crossing_site {A : Set (ι → Bool)} (hA : IsIncreasing A)
    {rank : ι → ℕ} (hrank : Function.Injective rank) {η ξ : ι → Bool}
    (hη : η ∈ A) (hξ : ξ ∉ A) :
    ∃ v : ι, η v = true ∧ ξ v = false ∧ hybrid rank v η ξ ∈ pivotalSet A v := by
  classical
  set N := (univ.sup rank) + 1 with hN
  have hlt : ∀ u, rank u < N := fun u =>
    Nat.lt_succ_of_le (Finset.le_sup (f := rank) (Finset.mem_univ u))
  have hex : ∃ k, hybridAt rank k η ξ ∈ A :=
    ⟨N, by rw [hybridAt_of_lt rank η ξ hlt]; exact hη⟩
  have hk0 : Nat.find hex ≠ 0 := by
    intro h
    have hs := Nat.find_spec hex
    rw [h, hybridAt_zero] at hs
    exact hξ hs
  obtain ⟨m, hkm⟩ : ∃ m, Nat.find hex = m + 1 := ⟨Nat.find hex - 1, by omega⟩
  have hkmem : hybridAt rank (m + 1) η ξ ∈ A := by rw [← hkm]; exact Nat.find_spec hex
  have hmnot : hybridAt rank m η ξ ∉ A := Nat.find_min hex (by omega)
  have hne : hybridAt rank (m + 1) η ξ ≠ hybridAt rank m η ξ := by
    intro hc
    rw [hc] at hkmem
    exact hmnot hkmem
  have hdiff : ∃ v : ι, rank v = m ∧ η v ≠ ξ v := by
    by_contra hcon
    push_neg at hcon
    refine hne (funext fun u => ?_)
    simp only [hybridAt]
    by_cases hu : rank u = m
    · rw [if_pos (by omega), if_neg (by omega)]
      exact hcon u hu
    · by_cases hu2 : rank u < m
      · rw [if_pos (by omega), if_pos hu2]
      · rw [if_neg (by omega), if_neg hu2]
  obtain ⟨v, hvrank, hvne⟩ := hdiff
  have hhyb : hybrid rank v η ξ = hybridAt rank m η ξ := by
    funext u; simp [hybrid, hybridAt, hvrank]
  have hlow : hybridAt rank m η ξ = Function.update (hybrid rank v η ξ) v (ξ v) := by
    funext u
    by_cases hu : u = v
    · subst hu
      simp [hybridAt, hvrank, Function.update_self]
    · rw [Function.update_of_ne hu, hhyb]
  have hhigh : hybridAt rank (m + 1) η ξ
      = Function.update (hybrid rank v η ξ) v (η v) := by
    funext u
    by_cases hu : u = v
    · subst hu
      simp [hybridAt, hvrank, Function.update_self]
    · rw [Function.update_of_ne hu, hhyb]
      simp only [hybridAt]
      have : rank u ≠ m := fun hc => hu (hrank (by rw [hc, hvrank]))
      by_cases h2 : rank u < m
      · rw [if_pos (by omega), if_pos h2]
      · rw [if_neg (by omega), if_neg h2]
  have hvtrue : η v = true := by
    by_contra hcon
    simp only [Bool.not_eq_true] at hcon
    have hxi : ξ v = true := by
      cases hxi : ξ v
      · rw [hcon, hxi] at hvne; exact absurd rfl hvne
      · rfl
    refine hmnot ?_
    refine hA (hybridAt rank (m + 1) η ξ) (hybridAt rank m η ξ) (fun u hu => ?_) hkmem
    rw [hhigh] at hu
    rw [hlow]
    by_cases huv : u = v
    · subst huv; rw [Function.update_self, hxi]
    · rw [Function.update_of_ne huv] at hu ⊢; exact hu
  have hxifalse : ξ v = false := by
    cases hxi : ξ v
    · rfl
    · rw [hvtrue, hxi] at hvne; exact absurd rfl hvne
  refine ⟨v, hvtrue, hxifalse, ?_, ?_⟩
  · rw [← hvtrue, ← hhigh]; exact hkmem
  · rw [← hxifalse, ← hlow]; exact hmnot

/-! ## The union bound -/

/-- The crossing term at the site `v`: the pair `(η, ξ)` crosses at `v` when `v`
is open in `η`, closed in `ξ`, and pivotal for the hybrid configuration. -/
noncomputable def crossTerm (rank : ι → ℕ) (A : Set (ι → Bool)) (v : ι)
    (η ξ : ι → Bool) : ℝ :=
  (if η v then (1 : ℝ) else 0) * (if ξ v then (0 : ℝ) else 1) *
    (pivotalSet A v).indicator (fun _ => (1 : ℝ)) (hybrid rank v η ξ)

omit [Fintype ι] in
theorem crossTerm_nonneg (rank : ι → ℕ) (A : Set (ι → Bool)) (v : ι)
    (η ξ : ι → Bool) : 0 ≤ crossTerm rank A v η ξ := by
  unfold crossTerm
  refine mul_nonneg (mul_nonneg ?_ ?_) ?_
  · split <;> norm_num
  · split <;> norm_num
  · exact Set.indicator_nonneg (fun _ _ => zero_le_one) _

/-- **The union bound.**  The product of the indicators of `A` at `η` and of
`Aᶜ` at `ξ` is dominated by the total number of crossing sites. -/
theorem crossTerm_bound {A : Set (ι → Bool)} (hA : IsIncreasing A)
    {rank : ι → ℕ} (hrank : Function.Injective rank) (η ξ : ι → Bool) :
    A.indicator (fun _ => (1 : ℝ)) η * Aᶜ.indicator (fun _ => (1 : ℝ)) ξ ≤
      ∑ v : ι, crossTerm rank A v η ξ := by
  classical
  by_cases hη : η ∈ A
  · by_cases hξ : ξ ∈ Aᶜ
    · obtain ⟨v, hv1, hv2, hv3⟩ := exists_crossing_site hA hrank hη hξ
      rw [Set.indicator_of_mem hη, Set.indicator_of_mem hξ, mul_one]
      have hterm : crossTerm rank A v η ξ = 1 := by
        unfold crossTerm
        rw [Set.indicator_of_mem hv3, hv1, hv2]
        norm_num
      calc (1 : ℝ) = crossTerm rank A v η ξ := hterm.symm
        _ ≤ ∑ u : ι, crossTerm rank A u η ξ :=
            Finset.single_le_sum
              (fun u _ => crossTerm_nonneg rank A u η ξ) (Finset.mem_univ v)
    · rw [Set.indicator_of_notMem hξ, mul_zero]
      exact Finset.sum_nonneg fun u _ => crossTerm_nonneg rank A u η ξ
  · rw [Set.indicator_of_notMem hη, zero_mul]
    exact Finset.sum_nonneg fun u _ => crossTerm_nonneg rank A u η ξ

/-! ## Evaluating a crossing term -/

/-- The pivotal probability written as a sum over the configurations with the
site `v` open. -/
theorem bernProb_pivotal_eq_sum (p : ℝ) (A : Set (ι → Bool)) (v : ι) :
    bernProb p (pivotalSet A v)
      = ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true),
          (pivotalSet A v).indicator (fun _ => (1 : ℝ)) η * offWeight p v η := by
  classical
  unfold bernProb
  rw [sum_split v]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have h1 : weight p η = p * offWeight p v η := by
    rw [weight_eq_mul_offWeight, hη]; norm_num
  have h2 : weight p (Function.update η v false) = (1 - p) * offWeight p v η := by
    rw [weight_eq_mul_offWeight, Function.update_self, offWeight_update]
    norm_num
  have hind : (pivotalSet A v).indicator (fun _ => (1 : ℝ))
      (Function.update η v false)
      = (pivotalSet A v).indicator (fun _ => (1 : ℝ)) η := by
    by_cases h : η ∈ pivotalSet A v
    · rw [Set.indicator_of_mem ((pivotalSet_update_mem_iff A v η false).mpr h),
        Set.indicator_of_mem h]
    · rw [Set.indicator_of_notMem
        (fun hc => h ((pivotalSet_update_mem_iff A v η false).mp hc)),
        Set.indicator_of_notMem h]
  rw [indicator_eq_indicator_one_mul (pivotalSet A v) _ η,
    indicator_eq_indicator_one_mul (pivotalSet A v) _ (Function.update η v false),
    h1, h2, hind]
  ring

/-- The same sum taken over the configurations with the site `v` closed. -/
theorem bernProb_pivotal_eq_sum_false (p : ℝ) (A : Set (ι → Bool)) (v : ι) :
    ∑ ζ : ι → Bool, (if ζ v then (0 : ℝ) else 1) *
        ((pivotalSet A v).indicator (fun _ => (1 : ℝ)) ζ * offWeight p v ζ)
      = bernProb p (pivotalSet A v) := by
  classical
  rw [bernProb_pivotal_eq_sum p A v, sum_split v]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hind : (pivotalSet A v).indicator (fun _ => (1 : ℝ))
      (Function.update η v false)
      = (pivotalSet A v).indicator (fun _ => (1 : ℝ)) η := by
    by_cases h : η ∈ pivotalSet A v
    · rw [Set.indicator_of_mem ((pivotalSet_update_mem_iff A v η false).mpr h),
        Set.indicator_of_mem h]
    · rw [Set.indicator_of_notMem
        (fun hc => h ((pivotalSet_update_mem_iff A v η false).mp hc)),
        Set.indicator_of_notMem h]
  rw [hη, Function.update_self, offWeight_update, hind]
  norm_num

/-- The pair weight of the two independent configurations, with the crossing
constraint at the site `v` built in. -/
noncomputable def crossWeight (p : ℝ) (v : ι) : ι → (Bool × Bool) → ℝ :=
  fun u k => pairWeight p p k *
    (if u = v then (if k.1 then (1 : ℝ) else 0) * (if k.2 then (0 : ℝ) else 1) else 1)

/-- The site-dependent selection map producing the hybrid configuration. -/
def crossSelect (rank : ι → ℕ) (v : ι) : ι → (Bool × Bool) → Bool :=
  fun u k => if rank u < rank v then k.1 else k.2

theorem prod_crossWeight (p : ℝ) (v : ι) (η ξ : ι → Bool) :
    (∏ u, crossWeight p v u (η u, ξ u))
      = weight p η * weight p ξ *
        ((if η v then (1 : ℝ) else 0) * (if ξ v then (0 : ℝ) else 1)) := by
  unfold crossWeight
  rw [Finset.prod_mul_distrib, ← weight_mul_weight_eq_prod]
  congr 1
  rw [Finset.prod_eq_single v]
  · simp
  · intro u _ hu; simp [hu]
  · intro h; exact absurd (Finset.mem_univ v) h

omit [Fintype ι] [DecidableEq ι] in
theorem crossSelect_apply (rank : ι → ℕ) (v : ι) (η ξ : ι → Bool) (u : ι) :
    crossSelect rank v u (η u, ξ u) = hybrid rank v η ξ u := rfl

omit [Fintype ι] in
theorem crossFib (p : ℝ) (rank : ι → ℕ) (v u : ι) (b : Bool) :
    (∑ k ∈ univ.filter (fun k : Bool × Bool => crossSelect rank v u k = b),
        crossWeight p v u k)
      = if u = v then (if b then 0 else p * (1 - p)) else (if b then p else 1 - p) := by
  classical
  by_cases huv : u = v
  · subst huv
    cases b <;>
      simp [crossSelect, crossWeight, pairWeight, Finset.sum_filter,
        Fintype.sum_prod_type]
  · by_cases hr : rank u < rank v
    · cases b <;>
        · simp [crossSelect, crossWeight, pairWeight, Finset.sum_filter,
            Fintype.sum_prod_type, hr, huv]
          ring
    · cases b <;>
        · simp [crossSelect, crossWeight, pairWeight, Finset.sum_filter,
            Fintype.sum_prod_type, hr, huv]
          ring

/-- **Exact evaluation of a crossing term.**  Averaging the crossing indicator at
the site `v` over two independent Bernoulli configurations gives
`p (1-p)` times the pivotal probability of `v`. -/
theorem sum_crossTerm (p : ℝ) (A : Set (ι → Bool)) (rank : ι → ℕ) (v : ι) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool,
        weight p η * weight p ξ * crossTerm rank A v η ξ
      = p * (1 - p) * bernProb p (pivotalSet A v) := by
  classical
  have hstep1 : ∑ η : ι → Bool, ∑ ξ : ι → Bool,
      weight p η * weight p ξ * crossTerm rank A v η ξ
      = ∑ c : ι → Bool × Bool, (∏ u, crossWeight p v u (c u)) *
          (pivotalSet A v).indicator (fun _ => (1 : ℝ))
            (fun u => crossSelect rank v u (c u)) := by
    rw [← sum_sum_eq_sum_pair (crossWeight p v)
      (fun c => (pivotalSet A v).indicator (fun _ => (1 : ℝ))
        (fun u => crossSelect rank v u (c u)))]
    refine Finset.sum_congr rfl fun η _ => Finset.sum_congr rfl fun ξ _ => ?_
    rw [prod_crossWeight]
    unfold crossTerm
    have hsel : (fun u => crossSelect rank v u (η u, ξ u)) = hybrid rank v η ξ := rfl
    rw [hsel]
    ring
  rw [hstep1, sum_prod_pushforward_dep (crossWeight p v) (crossSelect rank v)
    ((pivotalSet A v).indicator (fun _ => (1 : ℝ)))]
  have hprod : ∀ ζ : ι → Bool,
      (∏ u, ∑ k ∈ univ.filter (fun k : Bool × Bool => crossSelect rank v u k = ζ u),
          crossWeight p v u k)
        = (if ζ v then (0 : ℝ) else p * (1 - p)) * offWeight p v ζ := by
    intro ζ
    rw [← Finset.mul_prod_erase univ _ (Finset.mem_univ v), crossFib, if_pos rfl,
      offWeight]
    congr 1
    refine Finset.prod_congr rfl fun u hu => ?_
    rw [crossFib, if_neg (Finset.ne_of_mem_erase hu)]
  rw [Finset.sum_congr rfl (fun ζ _ => by rw [hprod ζ])]
  rw [← bernProb_pivotal_eq_sum_false p A v, Finset.mul_sum]
  refine Finset.sum_congr rfl fun ζ _ => ?_
  by_cases hz : ζ v = true
  · simp [hz]
  · simp only [Bool.not_eq_true] at hz
    simp only [hz, Bool.false_eq_true, if_false]
    ring

/-! ## The Poincaré inequality -/

/-- **Variance–influence (Poincaré) inequality for Bernoulli site measures.**
The variance of an increasing event is at most `p (1-p)` times the sum of its
pivotal probabilities. -/
theorem bernProb_poincare {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    bernProb p A * (1 - bernProb p A) ≤
      p * (1 - p) * ∑ v : ι, bernProb p (pivotalSet A v) := by
  classical
  set rank : ι → ℕ := fun u => ((Fintype.equivFin ι) u : ℕ) with hrankdef
  have hrank : Function.Injective rank := fun a b hab => by
    apply (Fintype.equivFin ι).injective
    exact Fin.ext hab
  have hle : ∑ η : ι → Bool, ∑ ξ : ι → Bool, weight p η * weight p ξ *
        (A.indicator (fun _ => (1 : ℝ)) η * Aᶜ.indicator (fun _ => (1 : ℝ)) ξ)
      ≤ ∑ η : ι → Bool, ∑ ξ : ι → Bool, weight p η * weight p ξ *
        (∑ v : ι, crossTerm rank A v η ξ) := by
    refine Finset.sum_le_sum fun η _ => Finset.sum_le_sum fun ξ _ => ?_
    exact mul_le_mul_of_nonneg_left (crossTerm_bound hA hrank η ξ)
      (mul_nonneg (weight_nonneg hp0 hp1 η) (weight_nonneg hp0 hp1 ξ))
  rw [sum_sum_mul_factor] at hle
  have hright : ∑ η : ι → Bool, ∑ ξ : ι → Bool, weight p η * weight p ξ *
        (∑ v : ι, crossTerm rank A v η ξ)
      = ∑ v : ι, p * (1 - p) * bernProb p (pivotalSet A v) := by
    have h1 : ∀ η ξ : ι → Bool,
        weight p η * weight p ξ * (∑ v : ι, crossTerm rank A v η ξ)
          = ∑ v : ι, weight p η * weight p ξ * crossTerm rank A v η ξ :=
      fun η ξ => Finset.mul_sum _ _ _
    calc ∑ η : ι → Bool, ∑ ξ : ι → Bool,
            weight p η * weight p ξ * (∑ v : ι, crossTerm rank A v η ξ)
        = ∑ η : ι → Bool, ∑ ξ : ι → Bool, ∑ v : ι,
            weight p η * weight p ξ * crossTerm rank A v η ξ :=
          Finset.sum_congr rfl fun η _ => Finset.sum_congr rfl fun ξ _ => h1 η ξ
      _ = ∑ η : ι → Bool, ∑ v : ι, ∑ ξ : ι → Bool,
            weight p η * weight p ξ * crossTerm rank A v η ξ :=
          Finset.sum_congr rfl fun η _ => Finset.sum_comm
      _ = ∑ v : ι, ∑ η : ι → Bool, ∑ ξ : ι → Bool,
            weight p η * weight p ξ * crossTerm rank A v η ξ := Finset.sum_comm
      _ = ∑ v : ι, p * (1 - p) * bernProb p (pivotalSet A v) :=
          Finset.sum_congr rfl fun v _ => sum_crossTerm p A rank v
  rw [hright, ← Finset.mul_sum] at hle
  rw [← bernProb_eq_sum_mul_indicator, ← bernProb_eq_sum_mul_indicator] at hle
  have hcompl : bernProb p Aᶜ = 1 - bernProb p A := by
    have := bernProb_add_bernProb_compl (ι := ι) p A; linarith
  rwa [hcompl] at hle

/-- **The Russo differential inequality.**  For an increasing event the
derivative of the Bernoulli polynomial dominates the variance divided by
`p (1-p)`. -/
theorem bernProb_variance_le_deriv {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    bernProb p A * (1 - bernProb p A) ≤
      p * (1 - p) * deriv (fun t : ℝ => bernProb t A) p := by
  rw [deriv_bernProb hA]
  exact bernProb_poincare hp0 hp1 hA


/-- **Logistic form of the differential inequality.**  On the open interval the
derivative of the Bernoulli polynomial of an increasing event is at least the
variance divided by `p (1-p)`; equivalently, the log-odds of the event grow at
rate at least `1 / (p (1-p))`. -/
theorem logit_deriv_lower_bound {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    bernProb p A * (1 - bernProb p A) / (p * (1 - p)) ≤
      deriv (fun t : ℝ => bernProb t A) p := by
  have hpos : 0 < p * (1 - p) := mul_pos hp0 (by linarith)
  rw [div_le_iff₀ hpos]
  have h := bernProb_variance_le_deriv hp0.le hp1.le hA
  nlinarith

/-- **The grid instance.**  The horizontal crossing probability of the `n × n`
grid satisfies the Russo differential inequality. -/
theorem crossing_variance_le_deriv (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) :
    bernProb p (crossingEvent n hn) * (1 - bernProb p (crossingEvent n hn)) ≤
      p * (1 - p) * deriv (fun t : ℝ => bernProb t (crossingEvent n hn)) p :=
  bernProb_variance_le_deriv hp0 hp1 (crossingEvent_isIncreasing n hn)

end BernoulliThresholdCoupling