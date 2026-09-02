/-
# How many chart points does a degree-`d` identity really need?

`Bridges.ChartDegreeExactness` shows that the `(d+1)^n` points of the grid `{0,…,d}^n`
suffice to certify any identity between expressions of total degree `≤ d`, and
`Bridges.ChartDegreeCertificates` shows that no set of `≤ d` points suffices.  This file
closes the gap from below with a *dimension count*: a set `T` of points is a uniqueness set
for total degree `≤ d` only if it has at least as many points as there are monomials of
total degree `≤ d`.

The argument is linear algebra bridged to polynomial geometry: the evaluation map from the
coefficient space `(monomialsLE n d) → K` to `T → K` cannot be injective once
`#T < #(monomialsLE n d)`, and any kernel vector is a nonzero polynomial of degree `≤ d`
vanishing on `T`.

Main results:
* `ChartCalculus.exists_nonzero_vanishing_of_card_lt` — kernel vectors give vanishing
  polynomials.
* `ChartCalculus.uniqueness_set_card_ge` — the dimension lower bound for uniqueness sets.
* `ChartCalculus.card_monomialsLE_le` — the count of monomials never exceeds the grid size
  `(d+1)^n`, so the lower bound is consistent with, and generally weaker than, the grid.
* `ChartCalculus.card_monomialsLE_one_var` — in one variable the two bounds coincide
  (`d+1`), so the grid of `Bridges.ChartDegreeExactness` is optimal there.
-/
import Bridges.ChartDegreeCertificates

open MvPolynomial

namespace ChartCalculus

/-! ## Monomials of bounded total degree -/

/-- The finset of monomials in `n` variables of total degree at most `d`. -/
noncomputable def monomialsLE (n d : ℕ) : Finset (Fin n →₀ ℕ) :=
  ((Finset.univ : Finset (Fin n → Fin (d + 1))).image
      (fun v => (Finsupp.equivFunOnFinite.symm (fun i => (v i : ℕ)) : Fin n →₀ ℕ))).filter
    (fun m => (m.sum fun _ e => e) ≤ d)

theorem coord_le_sum {n : ℕ} (m : Fin n →₀ ℕ) (i : Fin n) : m i ≤ m.sum fun _ e => e := by
  classical
  by_cases h : m i = 0
  · simp [h]
  · exact Finset.single_le_sum (f := fun j => m j) (fun j _ => Nat.zero_le _)
      (Finsupp.mem_support_iff.mpr h)

@[simp] theorem mem_monomialsLE {n d : ℕ} {m : Fin n →₀ ℕ} :
    m ∈ monomialsLE n d ↔ (m.sum fun _ e => e) ≤ d := by
  classical
  refine ⟨fun h => (Finset.mem_filter.mp h).2, fun h => Finset.mem_filter.mpr ⟨?_, h⟩⟩
  refine Finset.mem_image.mpr ⟨fun i => ⟨m i, Nat.lt_succ_of_le ((coord_le_sum m i).trans h)⟩,
    Finset.mem_univ _, ?_⟩
  ext i
  simp

/-- There are never more monomials of total degree `≤ d` than points in the grid
`{0,…,d}^n`. -/
theorem card_monomialsLE_le (n d : ℕ) : (monomialsLE n d).card ≤ (d + 1) ^ n := by
  classical
  refine (Finset.card_filter_le _ _).trans ?_
  refine (Finset.card_image_le).trans ?_
  simp

/-- In one variable there are exactly `d + 1` monomials of degree `≤ d`: the grid bound of
`ChartCalculus.NExpr.degree_exact` is optimal for `n = 1`. -/
theorem card_monomialsLE_one_var (d : ℕ) : (monomialsLE 1 d).card = d + 1 := by
  classical
  have hsum : ∀ m : Fin 1 →₀ ℕ, (m.sum fun _ e => e) = m 0 := by
    intro m
    rw [Finsupp.sum_fintype _ _ (fun _ => rfl)]
    simp
  rw [← Finset.card_range (d + 1)]
  refine Finset.card_bij (fun m _ => m 0) (fun m hm => ?_) (fun m hm m' hm' h => ?_)
    (fun k hk => ⟨Finsupp.single 0 k, ?_, ?_⟩)
  · simpa [Nat.lt_succ_iff, hsum m] using mem_monomialsLE.mp hm
  · refine Finsupp.ext (fun i => ?_)
    have hi : i = 0 := Subsingleton.elim _ _
    subst hi
    exact h
  · simpa [hsum, Nat.lt_succ_iff] using Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
  · simp

/-! ## The evaluation map and the dimension lower bound -/

variable {K : Type*} [Field K]

/-- Evaluation of a coefficient vector, indexed by the monomials of degree `≤ d`, at the
points of a finite set `T`. -/
noncomputable def gridEvalMap (n d : ℕ) (T : Finset (Fin n → K)) :
    (↥(monomialsLE n d) → K) →ₗ[K] (↥T → K) where
  toFun c := fun t => ∑ m : ↥(monomialsLE n d),
    c m * ∏ i, ((t : Fin n → K) i) ^ ((m : Fin n →₀ ℕ) i)
  map_add' c₁ c₂ := by
    funext t
    simp [add_mul, Finset.sum_add_distrib]
  map_smul' a c := by
    funext t
    simp [Finset.mul_sum, mul_assoc]

/-- **Dimension obstruction.**  If a finite set `T ⊆ Kⁿ` has fewer points than there are
monomials of total degree `≤ d`, then some nonzero polynomial of total degree `≤ d`
vanishes on all of `T`. -/
theorem exists_nonzero_vanishing_of_card_lt {n d : ℕ} (T : Finset (Fin n → K))
    (hT : T.card < (monomialsLE n d).card) :
    ∃ p : MvPolynomial (Fin n) K, p ≠ 0 ∧ p.totalDegree ≤ d ∧ ∀ t ∈ T, eval t p = 0 := by
  classical
  have hnotinj : ¬ Function.Injective (gridEvalMap n d T) := by
    intro hinj
    have hrank := LinearMap.finrank_le_finrank_of_injective (f := gridEvalMap n d T) hinj
    simp only [Module.finrank_pi, Fintype.card_coe] at hrank
    omega
  obtain ⟨c, hcmem, hc0⟩ :=
    Submodule.exists_mem_ne_zero_of_ne_bot
      (fun h => hnotinj (LinearMap.ker_eq_bot.mp h))
  have hker : gridEvalMap n d T c = 0 := hcmem
  refine ⟨∑ m : ↥(monomialsLE n d), monomial (m : Fin n →₀ ℕ) (c m),
    ?_, ?_, ?_⟩
  · obtain ⟨m₀, hm₀⟩ : ∃ m₀, c m₀ ≠ 0 := Function.ne_iff.mp hc0
    intro hzero
    have hco := congrArg (MvPolynomial.coeff (m₀ : Fin n →₀ ℕ)) hzero
    rw [MvPolynomial.coeff_sum] at hco
    rw [Finset.sum_eq_single m₀] at hco
    · simp only [MvPolynomial.coeff_monomial, if_true, MvPolynomial.coeff_zero] at hco
      exact hm₀ hco
    · intro m _ hne
      rw [MvPolynomial.coeff_monomial, if_neg]
      exact fun h => hne (Subtype.ext h)
    · intro h
      exact absurd (Finset.mem_univ m₀) h
  · refine (MvPolynomial.totalDegree_finset_sum _ _).trans (Finset.sup_le (fun m _ => ?_))
    exact (MvPolynomial.totalDegree_monomial_le _ _).trans (mem_monomialsLE.mp m.2)
  · intro t ht
    have := congrFun hker ⟨t, ht⟩
    simp only [gridEvalMap, LinearMap.coe_mk, AddHom.coe_mk, Pi.zero_apply] at this
    rw [map_sum]
    simpa [MvPolynomial.eval_monomial, Finsupp.prod_pow] using this

/-- **Lower bound for uniqueness sets.**  A finite set of points that determines all
polynomials of total degree `≤ d` must contain at least as many points as there are
monomials of total degree `≤ d`. -/
theorem uniqueness_set_card_ge {n d : ℕ} (T : Finset (Fin n → K))
    (hU : ∀ p q : MvPolynomial (Fin n) K, p.totalDegree ≤ d → q.totalDegree ≤ d →
      (∀ t ∈ T, eval t p = eval t q) → p = q) :
    (monomialsLE n d).card ≤ T.card := by
  by_contra hlt
  push_neg at hlt
  obtain ⟨p, hp0, hpdeg, hpvan⟩ := exists_nonzero_vanishing_of_card_lt T hlt
  exact hp0 (hU p 0 hpdeg (by simp) (fun t ht => by simpa using hpvan t ht))

/-- In one variable, the grid `{0,…,d}` is an *optimal* uniqueness set: it works
(`ChartCalculus.NExpr.degree_exact`) and no smaller set does. -/
theorem one_var_uniqueness_set_card_ge {d : ℕ} (T : Finset (Fin 1 → K))
    (hU : ∀ p q : MvPolynomial (Fin 1) K, p.totalDegree ≤ d → q.totalDegree ≤ d →
      (∀ t ∈ T, eval t p = eval t q) → p = q) :
    d + 1 ≤ T.card := by
  simpa [card_monomialsLE_one_var] using uniqueness_set_card_ge T hU

end ChartCalculus