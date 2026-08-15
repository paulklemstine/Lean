/-
# GENERIC-RECOVERY, cycle III: every hint deficit is a symmetry

Cycles I and II established that a `t`-bit hint reduces the search by exactly
`2^t`, that the bound is attained, and that two special families — value hints
and trace hints — fall short by one and by three bits respectively.  Cycle III
asks *why* a family falls short, and answers: **because the hint is invariant
under a group of candidate symmetries, and the deficit is the order of that
group.**

* `GenericRecovery.cost_ge_of_family` — the abstract mechanism: an injective
  family of candidates carrying the same hint reading forces a class at least
  that large.
* `GenericRecovery.card_image_mul_le`, `GenericRecovery.worstCost_ge_of_uniform`
  — if such a family exists at *every* candidate, the number of usable readings
  drops by the factor `g`: `g · #readings ≤ |S|`, i.e. `log₂ g` bits are lost
  from the hint's nominal budget.
* `GenericRecovery.kleinMul`, `GenericRecovery.card_kleinMul`,
  `GenericRecovery.kleinMul_sq_eq_one` — the invariance group of the trace hint:
  the Klein four-group `{±1, ±(1 + 2^{t-1})}` of square roots of `1` mod `2^t`.
* `GenericRecovery.cost_sqHint_ge_four`, `GenericRecovery.card_image_sqHint_le`
  — the payoff: on *any* candidate set of units closed under that group, the
  square (equivalently trace) hint has classes of size at least `4` and at most
  `|S|/4` readings.  Cycle II computed `4` on the full odd-residue set; here the
  same deficit is derived from structure and holds on every symmetric candidate
  set, e.g. the sparse prime sets of the experiment.
-/
import Mathlib
import Combinatorics.GenericRecoveryHintTaxonomy

namespace GenericRecovery

open Finset

/-! ## 1.  The abstract mechanism -/

variable {α β ι : Type*} [DecidableEq β]

/-- **Indistinguishable families force large classes.**  If `φ` embeds a finite
index set `T` into the candidate set so that all `φ i` produce the same hint
reading `y`, then the class of `y` has at least `|T|` candidates. -/
theorem cost_ge_of_family {S : Finset α} {h : α → β} {T : Finset ι} (φ : ι → α) (y : β)
    (hmaps : ∀ i ∈ T, φ i ∈ S) (hval : ∀ i ∈ T, h (φ i) = y) (hinj : Set.InjOn φ T) :
    #T ≤ cost S h y := by
  classical
  have hsub : T.image φ ⊆ {a ∈ S | h a = y} := by
    intro a ha
    obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp ha
    exact Finset.mem_filter.mpr ⟨hmaps i hi, hval i hi⟩
  calc #T = #(T.image φ) := (Finset.card_image_of_injOn hinj).symm
    _ ≤ cost S h y := Finset.card_le_card hsub

/-- **A uniform deficit costs `log₂ g` bits.**  If every candidate sits in a
class of size at least `g`, the hint realises at most `|S| / g` readings: its
nominal bit budget is cut by `log₂ g`. -/
theorem card_image_mul_le {S : Finset α} {h : α → β} {g : ℕ}
    (hcost : ∀ a ∈ S, g ≤ cost S h (h a)) : g * #(S.image h) ≤ #S := by
  classical
  rw [Finset.card_eq_sum_card_image h S]
  calc g * #(S.image h) = ∑ _y ∈ S.image h, g := by
        rw [Finset.sum_const, smul_eq_mul, Nat.mul_comm]
    _ ≤ ∑ y ∈ S.image h, #({a ∈ S | h a = y}) := by
        refine Finset.sum_le_sum ?_
        intro y hy
        obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hy
        exact hcost a ha

/-- The worst-case recovery cost is at least the size of the invariance group. -/
theorem worstCost_ge_of_uniform {S : Finset α} {h : α → β} {g : ℕ} (hne : S.Nonempty)
    (hcost : ∀ a ∈ S, g ≤ cost S h (h a)) : g ≤ worstCost S h := by
  obtain ⟨a, ha⟩ := hne
  exact (hcost a ha).trans (cost_le_worstCost (Finset.mem_image_of_mem h ha))

/-! ## 2.  The invariance group of the trace hint -/

section Klein

variable (n : ℕ)

/-- The Klein four-group of square roots of `1` modulo `2^{n+3}`. -/
def kleinMul : Finset (ZMod (2 ^ (n + 3))) :=
  {((1 : ℤ) : ZMod (2 ^ (n + 3))), ((-1 : ℤ) : ZMod (2 ^ (n + 3))),
    ((1 + 2 ^ (n + 2) : ℤ) : ZMod (2 ^ (n + 3))),
    ((-(1 + 2 ^ (n + 2)) : ℤ) : ZMod (2 ^ (n + 3)))}

theorem not_dvd_two : ¬ (2:ℤ) ^ (n + 3) ∣ 2 := by
  intro h
  have hle := Int.le_of_dvd (by norm_num) h
  have hlt : (2:ℤ) ^ 3 ≤ 2 ^ (n + 3) :=
    pow_le_pow_right₀ (by norm_num) (by omega)
  norm_num at hlt
  omega

theorem not_dvd_two_pow_pred : ¬ (2:ℤ) ^ (n + 3) ∣ (2:ℤ) ^ (n + 2) := by
  intro h
  have hle := Int.le_of_dvd (by positivity) h
  have hlt : (2:ℤ) ^ (n + 2) < 2 ^ (n + 3) := by
    apply pow_lt_pow_right₀ (by norm_num)
    omega
  omega

theorem not_dvd_two_add : ¬ (2:ℤ) ^ (n + 3) ∣ (2 + 2 ^ (n + 2)) := by
  intro h
  have h' : (2:ℤ) ^ (n + 2) ∣ 1 + 2 ^ (n + 1) := by
    refine two_pow_dvd_two_mul ?_
    rw [show 2 * (1 + (2:ℤ) ^ (n + 1)) = 2 + 2 ^ (n + 2) by ring]
    exact h
  have h2 : (2:ℤ) ∣ 1 + 2 ^ (n + 1) := dvd_trans (dvd_pow_self 2 (by omega)) h'
  have h3 : (2:ℤ) ∣ (2:ℤ) ^ (n + 1) := dvd_pow_self 2 (by omega)
  obtain ⟨i, hi⟩ := h2
  obtain ⟨j, hj⟩ := h3
  omega

theorem card_kleinMul : #(kleinMul n) = 4 := by
  have key : ∀ v w : ℤ, ¬ ((2:ℤ) ^ (n + 3) ∣ v - w) →
      ((v : ℤ) : ZMod (2 ^ (n + 3))) ≠ ((w : ℤ) : ZMod (2 ^ (n + 3))) :=
    fun v w hvw hEq => hvw ((zmod_eq_iff n v w).mp hEq)
  rw [kleinMul, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
    Finset.card_insert_of_notMem, Finset.card_singleton]
  · simp only [Finset.mem_singleton]
    refine key _ _ ?_
    rw [show (1 + (2:ℤ) ^ (n + 2)) - (-(1 + 2 ^ (n + 2))) = 2 + 2 ^ (n + 3) by ring]
    intro h
    refine not_dvd_two n ?_
    have h2 : (2:ℤ) ^ (n + 3) ∣ (2 + 2 ^ (n + 3)) - 2 ^ (n + 3) := dvd_sub h dvd_rfl
    simpa using h2
  · simp only [Finset.mem_insert, Finset.mem_singleton, not_or]
    refine ⟨key _ _ ?_, key _ _ ?_⟩
    · rw [show (-1 : ℤ) - (1 + 2 ^ (n + 2)) = -(2 + 2 ^ (n + 2)) by ring]
      exact fun h => not_dvd_two_add n (dvd_neg.mp h)
    · rw [show (-1 : ℤ) - (-(1 + 2 ^ (n + 2))) = 2 ^ (n + 2) by ring]
      exact not_dvd_two_pow_pred n
  · simp only [Finset.mem_insert, Finset.mem_singleton, not_or]
    refine ⟨key _ _ ?_, key _ _ ?_, key _ _ ?_⟩
    · rw [show (1 : ℤ) - (-1) = 2 by ring]
      exact not_dvd_two n
    · rw [show (1 : ℤ) - (1 + 2 ^ (n + 2)) = -(2 ^ (n + 2)) by ring]
      exact fun h => not_dvd_two_pow_pred n (dvd_neg.mp h)
    · rw [show (1 : ℤ) - (-(1 + 2 ^ (n + 2))) = 2 + 2 ^ (n + 2) by ring]
      exact not_dvd_two_add n

/-- Every element of `kleinMul` squares to `1`: these are exactly the square
roots of unity modulo `2^{n+3}`. -/
theorem kleinMul_sq_eq_one {c : ZMod (2 ^ (n + 3))} (hc : c ∈ kleinMul n) : c ^ 2 = 1 := by
  have hone : ((1 : ℤ) : ZMod (2 ^ (n + 3))) = 1 := by push_cast; ring
  have hsq : ((1 + 2 ^ (n + 2) : ℤ) : ZMod (2 ^ (n + 3))) ^ 2 = 1 := by
    have h := (zmod_eq_iff n ((1 + 2 ^ (n + 2)) ^ 2) 1).mpr
      ⟨1 + 2 ^ (n + 1), by ring⟩
    push_cast at h ⊢
    exact h
  simp only [kleinMul, Finset.mem_insert, Finset.mem_singleton] at hc
  rcases hc with rfl | rfl | rfl | rfl
  · rw [hone]; ring
  · push_cast; ring
  · exact hsq
  · rw [show ((-(1 + 2 ^ (n + 2)) : ℤ) : ZMod (2 ^ (n + 3)))
        = -((1 + 2 ^ (n + 2) : ℤ) : ZMod (2 ^ (n + 3))) by push_cast; ring]
    rw [neg_pow]
    simpa using hsq

/-- **The trace hint is Klein-invariant.**  Multiplying a candidate by a square
root of unity does not change its square, hence does not change the trace
reading. -/
theorem sqHint_klein_invariant {c x : ZMod (2 ^ (n + 3))} (hc : c ∈ kleinMul n) :
    (c * x) ^ 2 = x ^ 2 := by
  rw [mul_pow, kleinMul_sq_eq_one n hc, one_mul]

/-- **Deficit from symmetry.**  On any candidate set of units closed under the
Klein group, every class of the square (trace) hint has at least four
candidates. -/
theorem cost_sqHint_ge_four {S : Finset (ZMod (2 ^ (n + 3)))}
    (hclosed : ∀ x ∈ S, ∀ c ∈ kleinMul n, c * x ∈ S)
    {x : ZMod (2 ^ (n + 3))} (hx : x ∈ S) (hunit : IsUnit x) :
    4 ≤ cost S (fun z => z ^ 2) (x ^ 2) := by
  rw [← card_kleinMul n]
  refine cost_ge_of_family (T := kleinMul n) (fun c => c * x) (x ^ 2)
    (fun c hc => hclosed x hx c hc) (fun c hc => sqHint_klein_invariant n hc) ?_
  intro c _ d _ hcd
  have hcd' : c * x = d * x := hcd
  exact hunit.mul_right_cancel hcd'

/-- **At most `|S|/4` readings.**  A `t`-bit trace hint on a Klein-symmetric set
of unit candidates realises at most a quarter of the readings its bit budget
allows: two bits are structurally lost. -/
theorem card_image_sqHint_le {S : Finset (ZMod (2 ^ (n + 3)))}
    (hclosed : ∀ x ∈ S, ∀ c ∈ kleinMul n, c * x ∈ S)
    (hunits : ∀ x ∈ S, IsUnit x) :
    4 * #(S.image (fun z => z ^ 2)) ≤ #S :=
  card_image_mul_le (fun a ha => cost_sqHint_ge_four n hclosed ha (hunits a ha))

end Klein

end GenericRecovery