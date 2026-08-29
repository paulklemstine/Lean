/-
# The Drake equation is a first moment, and the Fermi "paradox" is Bernoulli's inequality

Working in the finite product model of `Pythagorean.FermiPigeonhole.Model`, we prove:

* `prb_site_civilized` — each site is civilized with probability exactly `p`
  (the epoch variable integrates out);
* `drake_expected_count` — the expected number of technological civilizations is
  exactly `N * p`.  This *is* the Drake equation: it is a first moment, nothing more;
* `prb_lifeless` — the probability that the cosmos is completely lifeless is
  exactly `(1 - p) ^ N`;
* `prb_lifeless_ge` — Bernoulli's inequality turns this into `≥ 1 - N * p`;
* `drake_alone` — hence, as soon as the Drake expectation `N * p` is `< 1`, a
  lifeless cosmos has probability at least `1 - N * p > 0`: emptiness is *typical*,
  not paradoxical.
-/
import Pythagorean.FermiPigeonhole.Model

namespace Pythagorean.FermiPigeonhole

open Finset

variable {N T : ℕ} {p : ℝ}

/-- The number of civilizations present in an outcome. -/
def civCount (N T : ℕ) (f : Cosmos N T) : ℕ :=
  {i : Fin N | f i ≠ none}.toFinset.card

/-- Local mass of "this site is civilized". -/
lemma siteWeight_sum_erase (hT : 0 < T) :
    ∑ x ∈ (Finset.univ : Finset (Option (Fin T))).erase none, siteWeight T p x = p := by
  rw [Finset.sum_erase_eq_sub (Finset.mem_univ _), siteWeight_sum hT]
  simp [siteWeight]

/-- **Marginal law of a single site.**  Site `i` hosts a civilization with
probability exactly `p`; the epoch degree of freedom integrates out. -/
lemma prb_site_civilized (hT : 0 < T) (i : Fin N) :
    Prb N T p {f | f i ≠ none} = p := by
  classical
  set B : Fin N → Finset (Option (Fin T)) := fun j =>
    if j = i then (Finset.univ.erase none) else Finset.univ with hB
  have hset : {f : Cosmos N T | f i ≠ none} = {f : Cosmos N T | ∀ j, f j ∈ B j} := by
    ext f
    constructor
    · intro hf j
      by_cases hj : j = i
      · subst hj
        simp only [hB, if_pos rfl, Finset.mem_erase, Finset.mem_univ, and_true]
        exact hf
      · simp [hB, hj]
    · intro hf
      have := hf i
      simp only [hB, if_pos rfl, Finset.mem_erase] at this
      exact this.1
  rw [hset, prb_cylinder]
  have hprod : ∀ j : Fin N, (∑ x ∈ B j, siteWeight T p x)
      = if j = i then p else 1 := by
    intro j
    by_cases hj : j = i
    · subst hj; simp only [hB, if_pos rfl]; exact siteWeight_sum_erase hT
    · simp only [hB, if_neg hj]; exact siteWeight_sum hT
  simp [hprod]

/-- The probability that the whole cosmos is lifeless is exactly `(1 - p) ^ N`. -/
lemma prb_lifeless : Prb N T p {f | ∀ i, f i = none} = (1 - p) ^ N := by
  classical
  have hset : {f : Cosmos N T | ∀ i, f i = none}
      = {f : Cosmos N T | ∀ i, f i ∈ ({none} : Finset (Option (Fin T)))} := by
    ext f; simp
  rw [hset, prb_cylinder]
  simp [siteWeight]

/-- **Bernoulli's inequality**, in the Fermi reading: the chance of a lifeless
cosmos is at least `1 - N * p`, i.e. one minus the Drake expectation. -/
lemma prb_lifeless_ge (h1 : p ≤ 1) :
    1 - (N : ℝ) * p ≤ Prb N T p {f | ∀ i, f i = none} := by
  rw [prb_lifeless]
  have hp2 : (-2 : ℝ) ≤ -p := by linarith
  have := one_add_mul_le_pow hp2 N
  calc 1 - (N : ℝ) * p = 1 + (N : ℝ) * (-p) := by ring
    _ ≤ (1 + -p) ^ N := this
    _ = (1 - p) ^ N := by ring_nf

/-- **The Drake equation as a first moment.**  The expected number of technological
civilizations in the cosmos is exactly `N * p`. -/
theorem drake_expected_count (hT : 0 < T) :
    ∑ f : Cosmos N T, weight N T p f * (civCount N T f : ℝ) = (N : ℝ) * p := by
  classical
  have hcard : ∀ f : Cosmos N T,
      ((civCount N T f : ℝ)) = ∑ i : Fin N, (if f i ≠ none then (1:ℝ) else 0) := by
    intro f
    rw [civCount]
    have : {i : Fin N | f i ≠ none}.toFinset
        = Finset.univ.filter (fun i => f i ≠ none) := by
      ext i; simp
    rw [this, Finset.card_filter]
    push_cast
    rfl
  calc ∑ f : Cosmos N T, weight N T p f * (civCount N T f : ℝ)
      = ∑ f : Cosmos N T, ∑ i : Fin N,
          weight N T p f * (if f i ≠ none then (1:ℝ) else 0) := by
        refine Finset.sum_congr rfl fun f _ => ?_
        rw [hcard f, Finset.mul_sum]
    _ = ∑ i : Fin N, ∑ f : Cosmos N T,
          weight N T p f * (if f i ≠ none then (1:ℝ) else 0) := Finset.sum_comm
    _ = ∑ i : Fin N, Prb N T p {f | f i ≠ none} := by
        refine Finset.sum_congr rfl fun i _ => ?_
        rw [Prb]
        refine Finset.sum_congr rfl fun f _ => ?_
        by_cases h : f i = none
        · have hn : f ∉ {g : Cosmos N T | g i ≠ none} := by simp [h]
          rw [Set.indicator_of_notMem hn, if_neg (by simp [h]), mul_zero]
        · have hm : f ∈ {g : Cosmos N T | g i ≠ none} := h
          rw [Set.indicator_of_mem hm, if_pos h, mul_one]
    _ = (N : ℝ) * p := by
        rw [Finset.sum_congr rfl fun i _ => prb_site_civilized (p := p) hT i]
        simp [mul_comm]

/-- **Union bound on the existence of any civilization.**  The probability that at
least one site is civilized is at most the Drake expectation `N * p`. -/
theorem prb_exists_civ_le (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) :
    Prb N T p {f | ∃ i, f i ≠ none} ≤ (N : ℝ) * p := by
  classical
  have hset : {f : Cosmos N T | ∃ i, f i ≠ none}
      = {f : Cosmos N T | ∃ i ∈ (Finset.univ : Finset (Fin N)), f ∈ {g | g i ≠ none}} := by
    ext f; simp
  rw [hset]
  calc Prb N T p {f : Cosmos N T | ∃ i ∈ (Finset.univ : Finset (Fin N)),
          f ∈ {g : Cosmos N T | g i ≠ none}}
      ≤ ∑ i : Fin N, Prb N T p {g : Cosmos N T | g i ≠ none} :=
        prb_union_bound h0 h1 _ _
    _ = (N : ℝ) * p := by
        rw [Finset.sum_congr rfl fun i _ => prb_site_civilized (p := p) hT i]
        simp [mul_comm]

/-- **Second-order Bonferroni bound**, proved by induction on the number of sites:
`(1 - p) ^ N ≤ 1 - N * p + N ^ 2 * p ^ 2 / 2`.  This is the converse direction to
Bernoulli's inequality and shows the first-moment estimate is tight to second
order. -/
lemma one_sub_pow_le (h0 : 0 ≤ p) (h1 : p ≤ 1) (n : ℕ) :
    (1 - p) ^ n ≤ 1 - (n : ℝ) * p + (n : ℝ) ^ 2 * p ^ 2 / 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hnn : (0 : ℝ) ≤ 1 - p := by linarith
      have hcast : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
      have hstep : (1 - p) ^ (n + 1) ≤ (1 - (n : ℝ) * p + (n : ℝ) ^ 2 * p ^ 2 / 2) * (1 - p) := by
        rw [pow_succ]
        exact mul_le_mul_of_nonneg_right ih hnn
      refine hstep.trans ?_
      rw [hcast]
      have hn : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg _
      nlinarith [sq_nonneg p, mul_nonneg (mul_nonneg hn hn) (mul_nonneg (mul_nonneg h0 h0) h0)]

/-- **Tightness of the union bound.**  The probability that some civilization exists
is at least `N * p - (N * p) ^ 2 / 2`, so together with `prb_exists_civ_le` the
Drake first moment determines it up to a quadratic error. -/
theorem prb_exists_civ_ge (h0 : 0 ≤ p) (h1 : p ≤ 1) (hT : 0 < T) :
    (N : ℝ) * p - ((N : ℝ) * p) ^ 2 / 2 ≤ Prb N T p {f | ∃ i, f i ≠ none} := by
  have hcompl : ({f : Cosmos N T | ∀ i, f i = none})ᶜ = {f : Cosmos N T | ∃ i, f i ≠ none} := by
    ext f
    simp [Set.mem_compl_iff, not_forall]
  have hadd := prb_add_compl (N := N) (T := T) (p := p) hT {f : Cosmos N T | ∀ i, f i = none}
  rw [hcompl, prb_lifeless] at hadd
  have hle := one_sub_pow_le (p := p) h0 h1 N
  have : ((N : ℝ) * p) ^ 2 / 2 = (N : ℝ) ^ 2 * p ^ 2 / 2 := by ring
  linarith [hle, hadd]

/-- **Resolution of the Fermi paradox in the first-moment regime.**  If the Drake
expectation `N * p` is smaller than `1`, then with probability at least
`1 - N * p > 0` the cosmos contains no civilization at all: emptiness is the
typical outcome, and no paradox arises. -/
theorem drake_alone (h1 : p ≤ 1) (hlt : (N : ℝ) * p < 1) :
    0 < Prb N T p {f | ∀ i, f i = none} ∧
      1 - (N : ℝ) * p ≤ Prb N T p {f | ∀ i, f i = none} := by
  have hge := prb_lifeless_ge (N := N) (T := T) h1
  exact ⟨lt_of_lt_of_le (by linarith) hge, hge⟩

end Pythagorean.FermiPigeonhole