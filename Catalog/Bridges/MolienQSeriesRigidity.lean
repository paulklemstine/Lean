import Bridges.MoonshineMomentLaurentBridge

/-!
# Conjecture D: q-series rigidity and a Molien-type dichotomy

This file continues the research thread of `Catalog/Bridges/MoonshineMomentLaurentBridge.lean`
(the moment hierarchy of fixed-point / trace series) and settles the following conjecture.

> **Conjecture D (q-series rigidity / Molien-type dichotomy).**
> The fixed-point q-series determines the orbit-counting generating function, and conversely.

Setting: a finite group `G` acting on a finite set `X`.  The two objects in play are

* the **fixed-point q-series** `Φ_{G,X}(q) = ∑_{g ∈ G} q^{|X^g|}` (`fixQSeries`), equivalently
  the multiset `{|X^g| : g ∈ G}` (`fixMultiset`), equivalently the *normalised* distribution
  `ρ_{G,X}(v) = #{g : |X^g| = v} / |G|` (`fixDensity`);
* the **orbit-counting generating function** `N_{G,X}(t) = ∑_{n ≥ 0} #((Fin n → X)/G) · tⁿ`
  (`orbitSeriesPS`), whose coefficients are the orbit counts of the diagonal action on
  `n`-tuples (`orbitCount`).

## Results

* `burnside_moment` : `|G| · #((Fin n → X)/G) = ∑_{g} |X^g|ⁿ` (imported from the catalog).
* `molien_geometric` : `(1 - |X^g|·t)·∑ₙ |X^g|ⁿ tⁿ = 1`, and
  `molien_powerSeries` : `|G| · N_{G,X}(t) = ∑_{g ∈ G} 1/(1 - |X^g| t)`.  This is the
  Molien-type closed form: the orbit generating function is a rational function whose poles
  are exactly the reciprocals of the fixed-point counts (`molien_rational`).
* **Forward rigidity** (`fixMultiset_determines_orbitCount`,
  `fixQSeries_determines_orbitSeries`): equal fixed-point q-series ⟹ equal orbit counts.
* **Converse rigidity** (`orbitCount_determines_fixDensity`): equal orbit counts for
  `n < max(|X|,|Y|)+1` already force the *normalised* fixed-point distributions to agree.
  Normalisation is unavoidable: `density_not_multiset` exhibits `G` and `G × G` acting on the
  same set with identical orbit counts and different q-series.
* **Dichotomy** (`molien_dichotomy`, `molien_rigidity_iff`): for two actions of groups of the
  same order, either the fixed-point q-series coincide, or the orbit-counting sequences already
  differ at some `n ≤ max(|X|,|Y|)`.  There is no intermediate behaviour: agreement on
  `max(|X|,|Y|)+1` coefficients is agreement everywhere.

* **Kernel layer** (`kernel_le_burnside`, `burnside_le_kernel_add`, `molien_detects_trivial`):
  the leading asymptotics of the orbit counts is the kernel proportion, and the single
  coefficient `n = 1` already characterises the trivial action.
* **Graded form** (`graded_molien_rigidity`): the dichotomy holds gradewise for graded families
  of finite `G`-sets, the combinatorial shadow of the moonshine setting.
* **Sharpness** (`powerSum_rigidity_sharp`): the number of coefficients used cannot be reduced
  below the number of admissible fixed-point values.

The algebraic engine is `powerSum_rigidity`: a Lagrange-interpolation argument showing that a
weighted power-sum functional supported on `k` distinct nodes is determined by its first `k`
values.
-/

namespace MolienRigidity

open MulAction Polynomial Finset

/-! ## Part 0: the algebraic core — finite determinacy of weighted power sums -/

section Algebra

/-- **Finite determinacy of weighted power sums.**  If the weighted power sums
`∑ᵢ wᵢ · valᵢⁿ` over `k` distinct nodes vanish for the first `k` exponents `n = 0, …, k-1`,
then all weights vanish.  The proof evaluates the Lagrange basis polynomial at the nodes:
`w u = ∑ᵢ wᵢ · Lᵤ(valᵢ)` and `Lᵤ` has degree `< k`, so the right-hand side is a linear
combination of the vanishing power sums. -/
theorem powerSum_rigidity {ι : Type*} [DecidableEq ι] {S : Finset ι} {val : ι → ℚ}
    (hinj : Set.InjOn val (S : Set ι)) {w : ι → ℚ}
    (h : ∀ n < S.card, ∑ i ∈ S, w i * (val i) ^ n = 0) : ∀ u ∈ S, w u = 0 := by
  classical
  intro u hu
  set Q := Lagrange.basis S val u with hQ
  have hcard : 1 ≤ S.card := Finset.card_pos.mpr ⟨u, hu⟩
  have hdeg : Q.natDegree + 1 = S.card := by
    rw [hQ, Lagrange.natDegree_basis hinj hu]; omega
  have key : ∑ i ∈ S, w i * Q.eval (val i) = w u := by
    rw [Finset.sum_eq_single u]
    · rw [Lagrange.eval_basis_self hinj hu]; ring
    · intro b hb hbu
      rw [Lagrange.eval_basis_of_ne (Ne.symm hbu) hb]; ring
    · intro hc; exact absurd hu hc
  have expand : ∑ i ∈ S, w i * Q.eval (val i)
      = ∑ m ∈ Finset.range S.card, Q.coeff m * (∑ i ∈ S, w i * (val i) ^ m) := by
    simp_rw [Polynomial.eval_eq_sum_range, hdeg, Finset.mul_sum]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun m _ => Finset.sum_congr rfl fun i _ => by ring
  rw [expand] at key
  rw [← key]
  exact Finset.sum_eq_zero fun m hm => by rw [h m (Finset.mem_range.mp hm), mul_zero]

/-- Two weight functions with the same weighted power sums up to exponent `#S - 1` agree. -/
theorem powerSum_rigidity_eq {ι : Type*} [DecidableEq ι] {S : Finset ι} {val : ι → ℚ}
    (hinj : Set.InjOn val (S : Set ι)) {w w' : ι → ℚ}
    (h : ∀ n < S.card, ∑ i ∈ S, w i * (val i) ^ n = ∑ i ∈ S, w' i * (val i) ^ n) :
    ∀ u ∈ S, w u = w' u := by
  have := powerSum_rigidity (w := fun i => w i - w' i) hinj ?_
  · intro u hu; have := this u hu; linarith [this]
  · intro n hn
    have := h n hn
    simp only [sub_mul, Finset.sum_sub_distrib]
    linarith [this]

end Algebra

/-! ## Part 1: the two invariants -/

section Defs

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- The number of points of `X` fixed by `g`. -/
noncomputable def fixCount (g : G) : ℕ := Nat.card (fixedBy X g)

/-- The **fixed-point q-series** `Φ_{G,X}(q) = ∑_{g ∈ G} q^{|X^g|}`, a polynomial because `G`
is finite.  (This is the permutation-character generating polynomial; its Molien-style
normalisation is `fixDensity` below.) -/
noncomputable def fixQSeries : Polynomial ℚ := ∑ g : G, Polynomial.X ^ (fixCount G X g)

/-- The multiset of fixed-point counts, `{|X^g| : g ∈ G}`. -/
noncomputable def fixMultiset : Multiset ℕ :=
  (Finset.univ : Finset G).val.map (fixCount G X)

/-- Number of group elements with exactly `v` fixed points. -/
noncomputable def fixFiberCard (v : ℕ) : ℕ :=
  ((Finset.univ : Finset G).filter fun g => fixCount G X g = v).card

/-- The **normalised fixed-point distribution** `ρ_{G,X}(v) = #{g : |X^g| = v}/|G|`. -/
noncomputable def fixDensity (v : ℕ) : ℚ := (fixFiberCard G X v : ℚ) / (Fintype.card G : ℚ)

/-- The orbit count of the diagonal action of `G` on `n`-tuples, i.e. the `n`-th coefficient of
the orbit-counting generating function. -/
noncomputable def orbitCount (n : ℕ) : ℕ := Nat.card (orbitRel.Quotient G (Fin n → X))

/-- The **orbit-counting generating function** `N_{G,X}(t) = ∑ₙ #((Fin n → X)/G) tⁿ`. -/
noncomputable def orbitSeriesPS : PowerSeries ℚ :=
  PowerSeries.mk fun n => (orbitCount G X n : ℚ)

end Defs

/-! ## Part 2: Burnside's lemma and the Molien closed form -/

section Molien

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- **Burnside for tuples.**  The `n`-th orbit count is the `n`-th moment of the fixed-point
counts.  (Specialisation of the catalog result `sum_fixedPoints_pow_eq_orbits_mul_card`.) -/
theorem burnside_moment (n : ℕ) :
    Nat.card G * orbitCount G X n = ∑ g : G, fixCount G X g ^ n := by
  rw [mul_comm]
  exact (MoonshineMoments.sum_fixedPoints_pow_eq_orbits_mul_card G X n).symm

/-- Rational form of `burnside_moment`. -/
theorem burnside_moment_rat (n : ℕ) :
    (Fintype.card G : ℚ) * (orbitCount G X n : ℚ) = ∑ g : G, (fixCount G X g : ℚ) ^ n := by
  have h : ((Nat.card G * orbitCount G X n : ℕ) : ℚ) = ((∑ g : G, fixCount G X g ^ n : ℕ) : ℚ) :=
    congrArg _ (burnside_moment G X n)
  push_cast at h
  rwa [Nat.card_eq_fintype_card] at h

/-- The geometric series `∑ₙ aⁿ tⁿ` inverts `1 - a t`. -/
theorem molien_geometric (a : ℚ) :
    (1 - PowerSeries.C a * PowerSeries.X) * PowerSeries.mk (fun n => a ^ n) = 1 := by
  ext n
  cases n with
  | zero => simp [sub_mul, PowerSeries.coeff_zero_eq_constantCoeff]
  | succ m =>
      rw [sub_mul, one_mul, map_sub, PowerSeries.coeff_mk, mul_assoc,
        PowerSeries.coeff_C_mul, PowerSeries.coeff_succ_X_mul, PowerSeries.coeff_mk]
      simp [pow_succ, mul_comm]

/-- **Molien-type closed form.**  `|G| · N_{G,X}(t) = ∑_{g ∈ G} 1/(1 - |X^g| t)`, written
without division as an identity of power series. -/
theorem molien_powerSeries :
    (Fintype.card G : ℚ) • orbitSeriesPS G X
      = ∑ g : G, PowerSeries.mk fun n => (fixCount G X g : ℚ) ^ n := by
  ext n
  simp only [orbitSeriesPS, map_smul, PowerSeries.coeff_mk, smul_eq_mul, map_sum]
  exact burnside_moment_rat G X n

/-- **Rationality of the orbit-counting generating function.**  Multiplying by the Molien
denominator `∏_{g}(1 - |X^g| t)` turns `|G| · N_{G,X}(t)` into a polynomial (a finite sum of
products of `|G| - 1` linear factors). -/
theorem molien_rational [DecidableEq G] :
    (∏ g : G, (1 - PowerSeries.C (fixCount G X g : ℚ) * PowerSeries.X)) *
        ((Fintype.card G : ℚ) • orbitSeriesPS G X)
      = ∑ g : G, ∏ h ∈ (Finset.univ : Finset G).erase g,
          (1 - PowerSeries.C (fixCount G X h : ℚ) * PowerSeries.X) := by
  rw [molien_powerSeries, Finset.mul_sum]
  refine Finset.sum_congr rfl fun g _ => ?_
  set f : G → PowerSeries ℚ :=
    fun h => 1 - PowerSeries.C (fixCount G X h : ℚ) * PowerSeries.X with hf
  calc (∏ h : G, f h) * PowerSeries.mk (fun n => (fixCount G X g : ℚ) ^ n)
      = (∏ h ∈ (Finset.univ : Finset G).erase g, f h) *
          (f g * PowerSeries.mk (fun n => (fixCount G X g : ℚ) ^ n)) := by
        rw [← Finset.mul_prod_erase _ f (Finset.mem_univ g)]; ring
    _ = ∏ h ∈ (Finset.univ : Finset G).erase g, f h := by
        rw [hf, molien_geometric, mul_one]

end Molien

/-! ## Part 3: fibrewise decomposition of the moment sequence -/

section Fibers

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

omit [Fintype G] in
/-- Fixed-point counts never exceed `|X|`, so all of them live in `range (|X| + 1)`. -/
theorem fixCount_le (g : G) : fixCount G X g ≤ Nat.card X :=
  Nat.card_le_card_of_injective (fun x : fixedBy X g => (x : X)) Subtype.val_injective

omit [Finite X] in
/-- Splitting the moment sum over the fibres of `g ↦ |X^g|`. -/
theorem sum_pow_eq_sum_fiber (S : Finset ℕ) (hS : ∀ g : G, fixCount G X g ∈ S) (n : ℕ) :
    ∑ g : G, (fixCount G X g : ℚ) ^ n = ∑ v ∈ S, (fixFiberCard G X v : ℚ) * (v : ℚ) ^ n := by
  rw [Finset.sum_comp (fun v : ℕ => ((v : ℚ)) ^ n) (fixCount G X)]
  rw [Finset.sum_subset (fun v hv => ?_) (fun v _ hv => ?_)]
  · exact Finset.sum_congr rfl fun v _ => by
      simp only [fixFiberCard, nsmul_eq_mul]
  · obtain ⟨g, -, rfl⟩ := Finset.mem_image.mp hv
    exact hS g
  · have hemp : ((Finset.univ : Finset G).filter fun g => fixCount G X g = v) = ∅ := by
      refine Finset.filter_eq_empty_iff.mpr fun g _ hg => ?_
      exact hv (Finset.mem_image.mpr ⟨g, Finset.mem_univ g, hg⟩)
    simp [hemp]

/-- The orbit count is the `n`-th moment of the *normalised* fixed-point distribution. -/
theorem sum_fixDensity_pow (S : Finset ℕ) (hS : ∀ g : G, fixCount G X g ∈ S) (n : ℕ) :
    ∑ v ∈ S, fixDensity G X v * (v : ℚ) ^ n = (orbitCount G X n : ℚ) := by
  have hG : (Fintype.card G : ℚ) ≠ 0 := by
    have := Fintype.card_pos_iff.mpr (One.instNonempty (α := G))
    positivity
  have h := sum_pow_eq_sum_fiber G X S hS n
  have h2 := burnside_moment_rat G X n
  rw [h] at h2
  have hsplit : ∑ v ∈ S, fixDensity G X v * (v : ℚ) ^ n
      = (∑ v ∈ S, (fixFiberCard G X v : ℚ) * (v : ℚ) ^ n) / (Fintype.card G : ℚ) := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun v _ => by rw [fixDensity]; ring
  rw [hsplit, ← h2]
  field_simp

end Fibers

/-! ## Part 4: the three descriptions of the fixed-point q-series -/

section Descriptions

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]
variable (H : Type*) [Group H] [Fintype H] (Y : Type*) [MulAction H Y] [Finite Y]

omit [Finite X] in
/-- The `v`-th coefficient of the fixed-point q-series counts the group elements with exactly
`v` fixed points. -/
theorem coeff_fixQSeries (v : ℕ) :
    (fixQSeries G X).coeff v = (fixFiberCard G X v : ℚ) := by
  have hfil : ((Finset.univ : Finset G).filter fun g => v = fixCount G X g)
      = ((Finset.univ : Finset G).filter fun g => fixCount G X g = v) :=
    Finset.filter_congr fun g _ => by simp [eq_comm]
  rw [fixQSeries, Polynomial.finset_sum_coeff]
  simp only [Polynomial.coeff_X_pow, Finset.sum_boole, hfil, fixFiberCard]

omit [Finite X] in
/-- Counting in the fixed-point multiset. -/
theorem count_fixMultiset (v : ℕ) :
    Multiset.count v (fixMultiset G X) = fixFiberCard G X v := by
  rw [fixMultiset, Multiset.count_map, fixFiberCard, Finset.card, Finset.filter_val]
  exact congrArg Multiset.card (Multiset.filter_congr fun g _ => by simp [eq_comm])

omit [Finite X] in
/-- The fixed-point multiset has `|G|` entries. -/
theorem card_fixMultiset : Multiset.card (fixMultiset G X) = Fintype.card G := by
  simp [fixMultiset, Finset.card_univ]

omit [Finite X] [Finite Y] in
/-- q-series and multiset are equivalent packagings of the fixed-point data. -/
theorem fixQSeries_eq_iff_fixMultiset :
    fixQSeries G X = fixQSeries H Y ↔ fixMultiset G X = fixMultiset H Y := by
  constructor
  · intro h
    refine Multiset.ext.mpr fun v => ?_
    have := congrArg (fun p => Polynomial.coeff p v) h
    simp only [coeff_fixQSeries] at this
    rw [count_fixMultiset, count_fixMultiset]
    exact_mod_cast this
  · intro h
    refine Polynomial.ext fun v => ?_
    have := Multiset.ext.mp h v
    rw [count_fixMultiset, count_fixMultiset] at this
    rw [coeff_fixQSeries, coeff_fixQSeries, this]

omit [Finite X] [Finite Y] in
/-- Equal fixed-point multisets force equal group orders. -/
theorem card_eq_of_fixMultiset_eq (h : fixMultiset G X = fixMultiset H Y) :
    Fintype.card G = Fintype.card H := by
  have := congrArg Multiset.card h
  rwa [card_fixMultiset, card_fixMultiset] at this

omit [Finite X] [Finite Y] in
/-- With equal group orders, the normalised distribution carries exactly the same information
as the multiset. -/
theorem fixDensity_eq_iff_fixMultiset (hGH : Fintype.card G = Fintype.card H) :
    (∀ v, fixDensity G X v = fixDensity H Y v) ↔ fixMultiset G X = fixMultiset H Y := by
  have hG : (Fintype.card G : ℚ) ≠ 0 := by
    have := Fintype.card_pos_iff.mpr (One.instNonempty (α := G))
    positivity
  constructor
  · intro h
    refine Multiset.ext.mpr fun v => ?_
    have hv := h v
    rw [fixDensity, fixDensity, ← hGH, div_eq_div_iff hG hG] at hv
    rw [count_fixMultiset, count_fixMultiset]
    exact_mod_cast mul_right_cancel₀ hG hv
  · intro h v
    have := Multiset.ext.mp h v
    rw [count_fixMultiset, count_fixMultiset] at this
    rw [fixDensity, fixDensity, this, hGH]

end Descriptions

/-! ## Part 5: Conjecture D — rigidity in both directions, and the dichotomy -/

section Conjecture

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]
variable (H : Type*) [Group H] [Fintype H] (Y : Type*) [MulAction H Y] [Finite Y]

/-- The finite set of possible fixed-point counts for either action. -/
noncomputable def commonValues : Finset ℕ := Finset.range (max (Nat.card X) (Nat.card Y) + 1)

omit [Finite X] [Finite Y] in
theorem card_commonValues : (commonValues X Y).card = max (Nat.card X) (Nat.card Y) + 1 := by
  simp [commonValues]

omit [Fintype G] [Finite Y] in
theorem fixCount_mem_commonValues_left (g : G) : fixCount G X g ∈ commonValues X Y := by
  have := fixCount_le G X g
  simp only [commonValues, Finset.mem_range]
  omega

omit [Finite X] [Fintype H] in
theorem fixCount_mem_commonValues_right (h : H) : fixCount H Y h ∈ commonValues X Y := by
  have := fixCount_le H Y h
  simp only [commonValues, Finset.mem_range]
  omega

omit [Finite Y] in
/-- Values outside the admissible range carry no mass. -/
theorem fixDensity_eq_zero_of_notMem {v : ℕ} (hv : v ∉ commonValues X Y) :
    fixDensity G X v = 0 := by
  have hemp : ((Finset.univ : Finset G).filter fun g => fixCount G X g = v) = ∅ :=
    Finset.filter_eq_empty_iff.mpr fun g _ hg =>
      hv (hg ▸ fixCount_mem_commonValues_left G X Y g)
  simp [fixDensity, fixFiberCard, hemp]

/-- **Forward direction of Conjecture D.**  Equal normalised fixed-point distributions give
equal orbit counts in every degree. -/
theorem fixDensity_determines_orbitCount (h : ∀ v, fixDensity G X v = fixDensity H Y v) :
    ∀ n, orbitCount G X n = orbitCount H Y n := by
  intro n
  have h1 := sum_fixDensity_pow G X (commonValues X Y)
    (fixCount_mem_commonValues_left G X Y) n
  have h2 := sum_fixDensity_pow H Y (commonValues X Y)
    (fixCount_mem_commonValues_right (X := X) (H := H) (Y := Y)) n
  have : (orbitCount G X n : ℚ) = (orbitCount H Y n : ℚ) := by
    rw [← h1, ← h2]
    exact Finset.sum_congr rfl fun v _ => by rw [h v]
  exact_mod_cast this

/-- **Converse direction of Conjecture D (finite determinacy).**  If the orbit counts agree in
the first `max(|X|,|Y|) + 1` degrees, then the whole normalised fixed-point distributions
agree.  Only finitely many coefficients of the orbit-counting generating function are needed:
this is the Molien-type rigidity statement. -/
theorem orbitCount_determines_fixDensity
    (h : ∀ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n = orbitCount H Y n) :
    ∀ v, fixDensity G X v = fixDensity H Y v := by
  intro v
  by_cases hv : v ∈ commonValues X Y
  · refine powerSum_rigidity_eq (S := commonValues X Y) (val := fun m : ℕ => (m : ℚ))
      (fun a _ b _ hab => Nat.cast_injective hab) ?_ v hv
    intro n hn
    rw [card_commonValues] at hn
    rw [sum_fixDensity_pow G X (commonValues X Y) (fixCount_mem_commonValues_left G X Y) n,
      sum_fixDensity_pow H Y (commonValues X Y) (fixCount_mem_commonValues_right (X := X) (H := H) (Y := Y)) n,
      h n (by omega)]
  · rw [fixDensity_eq_zero_of_notMem G X Y hv,
      fixDensity_eq_zero_of_notMem (G := H) (X := Y) (Y := X)
        (by simpa [commonValues, max_comm] using hv)]

/-- **Conjecture D, q-series form (forward).**  The fixed-point q-series determines the
orbit-counting generating function.  No hypothesis on the group orders is needed: equality of
q-series already forces `|G| = |H|`. -/
theorem fixQSeries_determines_orbitSeries (h : fixQSeries G X = fixQSeries H Y) :
    orbitSeriesPS G X = orbitSeriesPS H Y := by
  have hm : fixMultiset G X = fixMultiset H Y := (fixQSeries_eq_iff_fixMultiset G X H Y).mp h
  have hGH : Fintype.card G = Fintype.card H := card_eq_of_fixMultiset_eq G X H Y hm
  have hd : ∀ v, fixDensity G X v = fixDensity H Y v :=
    (fixDensity_eq_iff_fixMultiset G X H Y hGH).mpr hm
  have := fixDensity_determines_orbitCount G X H Y hd
  ext n
  simp [orbitSeriesPS, this n]

/-- **Conjecture D, q-series form (converse).**  For actions of groups of equal order, the
orbit-counting generating function determines the fixed-point q-series, and already its first
`max(|X|,|Y|) + 1` coefficients suffice. -/
theorem orbitSeries_determines_fixQSeries (hGH : Fintype.card G = Fintype.card H)
    (h : ∀ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n = orbitCount H Y n) :
    fixQSeries G X = fixQSeries H Y :=
  (fixQSeries_eq_iff_fixMultiset G X H Y).mpr
    ((fixDensity_eq_iff_fixMultiset G X H Y hGH).mp
      (orbitCount_determines_fixDensity G X H Y h))

/-- **Molien-type rigidity, iff form.**  For groups of equal order the fixed-point q-series and
the orbit-counting sequence determine one another. -/
theorem molien_rigidity_iff (hGH : Fintype.card G = Fintype.card H) :
    fixQSeries G X = fixQSeries H Y ↔ ∀ n, orbitCount G X n = orbitCount H Y n := by
  constructor
  · intro h n
    have := fixQSeries_determines_orbitSeries G X H Y h
    have := congrArg (fun s => PowerSeries.coeff n s) this
    simpa [orbitSeriesPS] using this
  · intro h
    exact orbitSeries_determines_fixQSeries G X H Y hGH fun n _ => h n

/-- **The dichotomy.**  For two actions of groups of the same order there is no intermediate
behaviour: either the fixed-point q-series coincide, or the orbit-counting sequences already
disagree at some degree `n ≤ max(|X|,|Y|)`. -/
theorem molien_dichotomy (hGH : Fintype.card G = Fintype.card H) :
    fixQSeries G X = fixQSeries H Y ∨
      ∃ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n ≠ orbitCount H Y n := by
  by_cases h : ∀ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n = orbitCount H Y n
  · exact Or.inl (orbitSeries_determines_fixQSeries G X H Y hGH h)
  · push_neg at h
    exact Or.inr h

end Conjecture

/-! ## Part 6: normalisation is unavoidable

The converse direction of Conjecture D recovers the *normalised* distribution `ρ_{G,X}`, not the
raw multiset `{|X^g|}`.  This is not an artefact of the proof: inflating the group by a factor
changes the multiset while leaving every orbit count unchanged. -/

section Sharpness

/-- The trivial action of a group on a set. -/
def trivialAction (G X : Type*) [Group G] : MulAction G X where
  smul _ x := x
  one_smul _ := rfl
  mul_smul _ _ _ := rfl

attribute [local instance] trivialAction

theorem fixedBy_trivialAction (G X : Type*) [Group G] (g : G) :
    fixedBy X g = (Set.univ : Set X) := by
  ext x
  simp [MulAction.mem_fixedBy]
  rfl

theorem fixCount_trivialAction (G X : Type*) [Group G] (g : G) :
    fixCount G X g = Nat.card X := by
  rw [fixCount, fixedBy_trivialAction]
  exact Nat.card_congr (Equiv.Set.univ X)

/-- Under the trivial action every tuple is its own orbit. -/
theorem orbitCount_trivialAction (G X : Type*) [Group G] [Fintype G] [Finite X] (n : ℕ) :
    orbitCount G X n = Nat.card X ^ n := by
  have hG : 0 < Nat.card G := Nat.card_pos
  have h := burnside_moment G X n
  simp only [fixCount_trivialAction, Finset.sum_const, Finset.card_univ, smul_eq_mul,
    ← Nat.card_eq_fintype_card] at h
  exact Nat.eq_of_mul_eq_mul_left hG h

/-- The normalised fixed-point distribution of a trivial action is a point mass at `|X|`,
independently of the group. -/
theorem fixDensity_trivialAction (G X : Type*) [Group G] [Fintype G] (v : ℕ) :
    fixDensity G X v = if v = Nat.card X then 1 else 0 := by
  have hG : (Fintype.card G : ℚ) ≠ 0 := by
    have := Fintype.card_pos_iff.mpr (One.instNonempty (α := G))
    positivity
  by_cases hv : v = Nat.card X
  · have : ((Finset.univ : Finset G).filter fun g => fixCount G X g = v)
        = (Finset.univ : Finset G) :=
      Finset.filter_true_of_mem fun g _ => by rw [fixCount_trivialAction, hv]
    rw [fixDensity, fixFiberCard, this, Finset.card_univ, if_pos hv, div_self hG]
  · have : ((Finset.univ : Finset G).filter fun g => fixCount G X g = v) = ∅ :=
      Finset.filter_eq_empty_iff.mpr fun g _ hg => hv (by rw [← hg, fixCount_trivialAction])
    simp [fixDensity, fixFiberCard, this, hv]

/-- **Normalisation is necessary.**  The trivial actions of the groups of order `1` and `2` on
`Bool` have *identical* orbit-counting generating functions (all coefficients `2ⁿ`) and
identical normalised fixed-point distributions, but different fixed-point q-series (`q²` versus
`2q²`).  Hence the orbit-counting series cannot recover the raw multiset `{|X^g|}`, only its
normalisation — the group order is genuinely extra information. -/
theorem normalisation_necessary :
    (∀ n, orbitCount (Multiplicative (ZMod 1)) Bool n
        = orbitCount (Multiplicative (ZMod 2)) Bool n) ∧
      (∀ v, fixDensity (Multiplicative (ZMod 1)) Bool v
        = fixDensity (Multiplicative (ZMod 2)) Bool v) ∧
      fixQSeries (Multiplicative (ZMod 1)) Bool ≠ fixQSeries (Multiplicative (ZMod 2)) Bool := by
  refine ⟨fun n => by rw [orbitCount_trivialAction, orbitCount_trivialAction],
    fun v => by rw [fixDensity_trivialAction, fixDensity_trivialAction], fun hq => ?_⟩
  have hcard := card_eq_of_fixMultiset_eq _ _ _ _
    ((fixQSeries_eq_iff_fixMultiset (Multiplicative (ZMod 1)) Bool
      (Multiplicative (ZMod 2)) Bool).mp hq)
  simp [Fintype.card_multiplicative, ZMod.card] at hcard

end Sharpness

/-! ## Part 7: a worked example — `Equiv.Perm Bool` acting on `Bool`

Real data for the theory above: the group has order `2`, the fixed-point multiset is `{2, 0}`,
the q-series is `1 + q²`, and the orbit-counting generating function is
`1 + t + 2t² + 4t³ + ⋯ = (1 + (1-2t)⁻¹)/2`. -/

section PermBool

open Equiv

theorem fixCount_permBool_one : fixCount (Perm Bool) Bool 1 = 2 := by
  have h : fixedBy Bool (1 : Perm Bool) = (Set.univ : Set Bool) := by ext x; simp
  rw [fixCount, h, Nat.card_congr (Equiv.Set.univ Bool)]
  simp

theorem fixCount_permBool_swap : fixCount (Perm Bool) Bool (swap true false) = 0 := by
  have h : fixedBy Bool (swap true false) = (∅ : Set Bool) := by
    ext x
    simp only [MulAction.mem_fixedBy, Set.mem_empty_iff_false, iff_false]
    revert x
    decide
  rw [fixCount, h]
  simp

theorem univ_perm_bool :
    (Finset.univ : Finset (Perm Bool)) = {1, swap true false} := by decide

/-- The moment sequence of the full symmetric group on two letters. -/
theorem sum_fixCount_pow_permBool (n : ℕ) :
    ∑ g : Perm Bool, fixCount (Perm Bool) Bool g ^ n = 2 ^ n + 0 ^ n := by
  rw [univ_perm_bool, Finset.sum_pair (by decide : (1 : Perm Bool) ≠ swap true false),
    fixCount_permBool_one, fixCount_permBool_swap]

/-- Orbit counts of `Perm Bool` on `n`-tuples: `1, 1, 2, 4, 8, …` -/
theorem orbitCount_permBool (n : ℕ) : orbitCount (Perm Bool) Bool (n + 1) = 2 ^ n := by
  have hcard : Nat.card (Perm Bool) = 2 := by
    rw [Nat.card_eq_fintype_card]
    decide
  have h := burnside_moment (Perm Bool) Bool (n + 1)
  rw [sum_fixCount_pow_permBool, hcard, zero_pow (Nat.succ_ne_zero n), add_zero,
    pow_succ, mul_comm (2 ^ n) 2] at h
  omega

/-- The fixed-point multiset of `Perm Bool` on `Bool` is `{2, 0}`. -/
theorem fixMultiset_permBool : fixMultiset (Perm Bool) Bool = {2, 0} := by
  have h : (Finset.univ : Finset (Perm Bool)).val = {1, swap true false} := by decide
  rw [fixMultiset, h]
  simp [fixCount_permBool_one, fixCount_permBool_swap]

end PermBool

/-! ## Part 8: what the leading coefficient sees — the kernel

The fixed-point value `v = |X|` is attained exactly on the kernel of the action, so the density
`ρ_{G,X}(|X|)` is the kernel proportion `|K|/|G|`.  Since `|X|` is the largest possible value,
this is the *leading* asymptotics of the orbit-counting sequence, and it is pinned down by a
two-sided bound. -/

section Kernel

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

omit [Fintype G] in
/-- An element fixes every point iff it fixes the maximal number of points. -/
theorem fixCount_eq_card_iff (g : G) : fixCount G X g = Nat.card X ↔ ∀ x : X, g • x = x := by
  constructor
  · intro h x
    exact MoonshineMoments.smul_eq_self_of_card_fixedBy (G := G) (X := X) g h x
  · intro h
    have hu : fixedBy X g = (Set.univ : Set X) := by
      ext x; simpa [MulAction.mem_fixedBy] using h x
    rw [fixCount, hu]
    exact Nat.card_congr (Equiv.Set.univ X)

/-- The number of group elements acting trivially, i.e. the order of the kernel. -/
noncomputable def kernelCard : ℕ := fixFiberCard G X (Nat.card X)

omit [Finite X] in
theorem kernelCard_le : kernelCard G X ≤ Fintype.card G := by
  simpa [kernelCard, fixFiberCard, Finset.card_univ] using
    Finset.card_filter_le (Finset.univ : Finset G) _

omit [Finite X] in
/-- The density at the top value is the kernel proportion. -/
theorem fixDensity_card_eq : fixDensity G X (Nat.card X)
    = (kernelCard G X : ℚ) / (Fintype.card G : ℚ) := rfl

/-- **Lower bound.**  The kernel already contributes `|K| · |X|ⁿ` orbits' worth of mass. -/
theorem kernel_le_burnside (n : ℕ) :
    kernelCard G X * Nat.card X ^ n ≤ Nat.card G * orbitCount G X n := by
  rw [burnside_moment]
  classical
  have hsub : ((Finset.univ : Finset G).filter fun g => fixCount G X g = Nat.card X)
      ⊆ Finset.univ := Finset.filter_subset _ _
  calc kernelCard G X * Nat.card X ^ n
      = ∑ g ∈ (Finset.univ : Finset G).filter (fun g => fixCount G X g = Nat.card X),
          fixCount G X g ^ n := by
        rw [Finset.sum_congr rfl (fun g hg => by
          rw [(Finset.mem_filter.mp hg).2]), Finset.sum_const, smul_eq_mul]
        rfl
    _ ≤ ∑ g : G, fixCount G X g ^ n :=
        Finset.sum_le_sum_of_subset hsub

/-- **Upper bound.**  Everything outside the kernel fixes at most `|X| - 1` points. -/
theorem burnside_le_kernel_add (n : ℕ) :
    Nat.card G * orbitCount G X n
      ≤ kernelCard G X * Nat.card X ^ n
        + (Fintype.card G - kernelCard G X) * (Nat.card X - 1) ^ n := by
  classical
  rw [burnside_moment,
    ← Finset.sum_filter_add_sum_filter_not (Finset.univ : Finset G)
      (fun g => fixCount G X g = Nat.card X) (fun g => fixCount G X g ^ n)]
  have h1 : ∑ g ∈ (Finset.univ : Finset G).filter (fun g => fixCount G X g = Nat.card X),
      fixCount G X g ^ n = kernelCard G X * Nat.card X ^ n := by
    rw [Finset.sum_congr rfl (fun g hg => by rw [(Finset.mem_filter.mp hg).2]),
      Finset.sum_const, smul_eq_mul]
    rfl
  have h2 : ∑ g ∈ (Finset.univ : Finset G).filter (fun g => ¬ fixCount G X g = Nat.card X),
      fixCount G X g ^ n
      ≤ (Fintype.card G - kernelCard G X) * (Nat.card X - 1) ^ n := by
    have hcard : ((Finset.univ : Finset G).filter
        fun g => ¬ fixCount G X g = Nat.card X).card = Fintype.card G - kernelCard G X := by
      have hsum := Finset.card_filter_add_card_filter_not
        (s := (Finset.univ : Finset G)) (p := fun g => fixCount G X g = Nat.card X)
      rw [Finset.card_univ] at hsum
      simp only [kernelCard, fixFiberCard]
      omega
    calc ∑ g ∈ (Finset.univ : Finset G).filter (fun g => ¬ fixCount G X g = Nat.card X),
          fixCount G X g ^ n
        ≤ ∑ _g ∈ (Finset.univ : Finset G).filter (fun g => ¬ fixCount G X g = Nat.card X),
            (Nat.card X - 1) ^ n := by
          refine Finset.sum_le_sum fun g hg => ?_
          have hne := (Finset.mem_filter.mp hg).2
          have hle := fixCount_le G X g
          exact Nat.pow_le_pow_left (by omega) n
      _ = (Fintype.card G - kernelCard G X) * (Nat.card X - 1) ^ n := by
          rw [Finset.sum_const, smul_eq_mul, hcard]
  omega

/-- **Molien detects triviality.**  The orbit-counting generating function is `(1 - |X| t)⁻¹`
exactly for the trivial action.  Already the single coefficient `n = 1` decides this. -/
theorem molien_detects_trivial :
    (∀ n, orbitCount G X n = Nat.card X ^ n) ↔ ∀ (g : G) (x : X), g • x = x := by
  constructor
  · intro h g
    have hb := burnside_le_kernel_add G X 1
    rw [h 1] at hb
    have hK : kernelCard G X ≤ Fintype.card G := kernelCard_le G X
    have hcard : Nat.card G = Fintype.card G := Nat.card_eq_fintype_card
    have hfull : kernelCard G X = Fintype.card G := by
      rcases Nat.eq_zero_or_pos (Nat.card X) with hX | hX
      · have hall : ∀ g : G, fixCount G X g = Nat.card X := fun g => by
          have := fixCount_le G X g; omega
        have hfil : ((Finset.univ : Finset G).filter fun g => fixCount G X g = Nat.card X)
            = Finset.univ := Finset.filter_true_of_mem fun g _ => hall g
        simp [kernelCard, fixFiberCard, hfil, Finset.card_univ]
      · obtain ⟨m, hm⟩ : ∃ m, Nat.card X = m + 1 := ⟨Nat.card X - 1, by omega⟩
        obtain ⟨d, hd⟩ : ∃ d, Fintype.card G = kernelCard G X + d :=
          ⟨Fintype.card G - kernelCard G X, by omega⟩
        simp only [pow_one] at hb
        rw [hcard, hm, hd, Nat.add_sub_cancel_left, Nat.add_sub_cancel] at hb
        have hexp : (kernelCard G X + d) * (m + 1)
            = kernelCard G X * (m + 1) + d * m + d := by ring
        rw [hexp] at hb
        have hle : d ≤ 0 := by linarith
        omega
    have hfil : ((Finset.univ : Finset G).filter fun g => fixCount G X g = Nat.card X)
        = Finset.univ :=
      Finset.eq_univ_of_card _ (by simpa [kernelCard, fixFiberCard] using hfull)
    have hmem : g ∈ ((Finset.univ : Finset G).filter fun g => fixCount G X g = Nat.card X) := by
      rw [hfil]; exact Finset.mem_univ g
    exact (fixCount_eq_card_iff G X g).mp (Finset.mem_filter.mp hmem).2
  · intro h n
    have hG : 0 < Nat.card G := Nat.card_pos
    have hb := burnside_moment G X n
    have : ∀ g : G, fixCount G X g = Nat.card X := fun g => (fixCount_eq_card_iff G X g).mpr (h g)
    simp only [this, Finset.sum_const, Finset.card_univ, smul_eq_mul,
      ← Nat.card_eq_fintype_card] at hb
    exact Nat.eq_of_mul_eq_mul_left hG hb

end Kernel

/-! ## Part 9: the graded (moonshine) form

For a graded family of finite `G`-sets — the combinatorial shadow of a moonshine module — the
dichotomy holds gradewise: the family of fixed-point q-series and the family of
orbit-counting generating functions determine each other. -/

section Graded

variable (G : Type*) [Group G] [Fintype G] (H : Type*) [Group H] [Fintype H]
variable (Xg : ℕ → Type*) [∀ m, MulAction G (Xg m)] [∀ m, Finite (Xg m)]
variable (Yg : ℕ → Type*) [∀ m, MulAction H (Yg m)] [∀ m, Finite (Yg m)]

/-- **Gradewise Molien rigidity.**  Two graded finite actions of groups of equal order have the
same fixed-point q-series in every grade iff they have the same orbit counts on tuples in every
grade. -/
theorem graded_molien_rigidity (hGH : Fintype.card G = Fintype.card H) :
    (∀ m, fixQSeries G (Xg m) = fixQSeries H (Yg m))
      ↔ ∀ m n, orbitCount G (Xg m) n = orbitCount H (Yg m) n := by
  constructor
  · intro h m n
    exact (molien_rigidity_iff G (Xg m) H (Yg m) hGH).mp (h m) n
  · intro h m
    exact (molien_rigidity_iff G (Xg m) H (Yg m) hGH).mpr (h m)

end Graded

/-! ## Part 10: sharpness of the coefficient count, and what the top coefficient determines -/

section Sharp

/-- **The exponent bound in `powerSum_rigidity` is sharp.**  On the four nodes `{0,1,2,3}` the
signed weight vector `(1,-3,3,-1)` kills the moments `n = 0,1,2` but is not zero; so knowing
`#S - 1` moments is genuinely not enough, and the `max(|X|,|Y|)+1` coefficients used in
`orbitCount_determines_fixDensity` cannot be reduced to a smaller multiple of the number of
admissible fixed-point values. -/
theorem powerSum_rigidity_sharp :
    ∃ w : ℕ → ℚ, (∀ n < (Finset.range 4).card - 1, ∑ v ∈ Finset.range 4, w v * (v : ℚ) ^ n = 0)
      ∧ (∃ v ∈ Finset.range 4, w v ≠ 0)
      ∧ ∑ v ∈ Finset.range 4, w v * (v : ℚ) ^ ((Finset.range 4).card - 1) ≠ 0 := by
  refine ⟨fun v => if v = 0 then 1 else if v = 1 then -3 else if v = 2 then 3 else -1, ?_,
    ⟨0, by norm_num⟩, ?_⟩
  · intro n hn
    simp only [Finset.card_range] at hn
    interval_cases n <;> norm_num [Finset.sum_range_succ]
  · norm_num [Finset.card_range, Finset.sum_range_succ]

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]
variable (H : Type*) [Group H] [Fintype H] (Y : Type*) [MulAction H Y] [Finite Y]

/-- **The orbit-counting series determines the kernel proportion.**  This is the leading term
of the Molien expansion: the fraction of group elements acting trivially is read off from
finitely many orbit counts. -/
theorem orbitCount_determines_kernel_density (hXY : Nat.card X = Nat.card Y)
    (h : ∀ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n = orbitCount H Y n) :
    (kernelCard G X : ℚ) / (Fintype.card G : ℚ)
      = (kernelCard H Y : ℚ) / (Fintype.card H : ℚ) := by
  have h1 := orbitCount_determines_fixDensity G X H Y h (Nat.card X)
  rw [fixDensity_card_eq G X, hXY, fixDensity_card_eq H Y] at h1
  exact h1

end Sharp

end MolienRigidity