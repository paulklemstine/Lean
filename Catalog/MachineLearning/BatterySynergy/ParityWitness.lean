/-
# BATTERY-SYNERGY, part III: a battery whose capacity is *entirely* higher order

The round-27 experiment (paper 92) reports an order decomposition

| order | total synergy |
|---|---|
| `k = 2` (6 pairs) | `+0.244` |
| `k = 3` (4 triples) | `+3.822` |
| `k = 4` (the battery) | `+4.315` |

and concludes that pairwise synergies — the whole of the paper-91 table — carry
only `6 %` of the total.  The verdict *SYNERGY-COMPOUNDS* asserts that this is a
structural phenomenon and not an artefact: capacity arithmetic must be done
jointly, never marginally.

This file proves that the phenomenon is real in its sharpest possible form, by
exhibiting a battery in which **100 %** of the capacity is higher order:

* the population is `Bool × Bool × Bool`;
* the battery is the three coordinate dials, each of modulus `2`;
* the label is the parity of the three coordinates.

Then (`BatterySynergy.parity_capacity_is_purely_higher_order`):

* every single dial carries `0` bits about the label,
* every *pair* of dials carries `0` bits, hence every pairwise synergy is `0`
  and the total pairwise synergy vanishes,
* the full three-dial battery carries `1` bit, which is exactly the joint
  label-entropy ceiling `Hb L = 1`.

So the additive prediction is `0`, the measured capacity is at the ceiling, and
the entire `+1` bit is order-`3` synergy.  This is the extreme point of the
`super-additive` scale the verdict proposes, and it shows no bound of the form
"joint ≤ c · Σ marginals" can hold for any constant `c`.

Everything is computed from the counting definitions of part I: `decide` is used
only for finite combinatorial facts about an eight-element population (fibre
cardinalities, images), never for the entropy inequalities themselves.
-/
import Mathlib
import MachineLearning.BatterySynergy.Capacity

namespace BatterySynergy

open TraceBattery Finset

/-! ## 1. The population, the dials and the label -/

/-- The population: three bits. -/
abbrev Pop : Type := Bool × Bool × Bool

/-- A bit as a residue modulo `2`. -/
def bnat (b : Bool) : ℕ := if b then 1 else 0

theorem bnat_lt_two (b : Bool) : bnat b < 2 := by
  cases b <;> simp [bnat]

/-- The reading of the `i`-th coordinate dial. -/
def rd : Fin 3 → Pop → ℕ
  | ⟨0, _⟩ => fun x => bnat x.1
  | ⟨1, _⟩ => fun x => bnat x.2.1
  | _ => fun x => bnat x.2.2

/-- The label: the parity of the three coordinates. -/
def par (x : Pop) : ℕ := bnat (xor (xor x.1 x.2.1) x.2.2)

/-- The three-dial parity battery. -/
def pdial : Fin 3 → Dial Pop := fun i =>
  { modulus := 2
    modulus_pos := by norm_num
    read := rd i
    read_lt := by
      intro x
      match i with
      | ⟨0, _⟩ => exact bnat_lt_two _
      | ⟨1, _⟩ => exact bnat_lt_two _
      | ⟨2, _⟩ => exact bnat_lt_two _ }

theorem pdial_read (i : Fin 3) : (pdial i).read = rd i := rfl

/-- The fibres of a sub-battery's joint reading are cut out by the readings of
its dials. -/
theorem joint_fiber_iff (S : Finset (Fin 3)) (x y : Pop) :
    joint pdial S x = joint pdial S y ↔ ∀ i ∈ S, rd i x = rd i y := by
  constructor
  · intro h i hi
    exact congrFun h ⟨i, hi⟩
  · intro h
    funext i
    exact h i.1 i.2

/-! ## 2. Entropies of explicit statistics on eight individuals -/

theorem img_nat_eq (f : Pop → ℕ) (T : Finset ℕ) (h1 : ∀ x, f x ∈ T)
    (h2 : ∀ a ∈ T, ∃ x, f x = a) : img f = T := by
  ext a
  simp only [mem_img]
  exact ⟨by rintro ⟨x, rfl⟩; exact h1 x, fun ha => h2 a ha⟩

theorem cnt_nat (f : Pop → ℕ) (a k : ℕ)
    (h : (Finset.univ.filter fun x => f x = a).card = k) : cnt f a = k := by
  rw [cnt, fib_eq_filter]
  exact h

/-- Entropy of a statistic on `Pop` whose fibres all have size `k` and which
takes `m` values. -/
theorem H_uniform_nat (f : Pop → ℕ) (T : Finset ℕ) (k m : ℕ) (hk : 0 < k)
    (himg : img f = T) (hcard : T.card = m) (hc : ∀ a ∈ T, cnt f a = k) :
    H f = Real.log m := by
  have h := H_eq_log_card_img_of_uniform f k hk (by rw [himg]; exact hc)
  rw [h, himg, hcard]

theorem log_four : Real.log 4 = 2 * Real.log 2 := by
  rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow]
  push_cast
  ring

theorem log_eight : Real.log 8 = 3 * Real.log 2 := by
  rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, Real.log_pow]
  push_cast
  ring

/-- Entropy `log 2`: two balanced cells. -/
theorem H_two_cells (f : Pop → ℕ) (h1 : ∀ x, f x ∈ ({0, 1} : Finset ℕ))
    (h2 : ∀ a ∈ ({0, 1} : Finset ℕ), ∃ x, f x = a)
    (h3 : ∀ a ∈ ({0, 1} : Finset ℕ), (Finset.univ.filter fun x => f x = a).card = 4) :
    H f = Real.log 2 := by
  have := H_uniform_nat f {0, 1} 4 2 (by norm_num) (img_nat_eq f _ h1 h2) (by decide)
    (fun a ha => cnt_nat f a 4 (h3 a ha))
  simpa using this

/-- Entropy `log 4`: four balanced cells. -/
theorem H_four_cells (f : Pop → ℕ) (h1 : ∀ x, f x ∈ ({0, 1, 2, 3} : Finset ℕ))
    (h2 : ∀ a ∈ ({0, 1, 2, 3} : Finset ℕ), ∃ x, f x = a)
    (h3 : ∀ a ∈ ({0, 1, 2, 3} : Finset ℕ), (Finset.univ.filter fun x => f x = a).card = 2) :
    H f = Real.log 4 := by
  have := H_uniform_nat f {0, 1, 2, 3} 2 4 (by norm_num) (img_nat_eq f _ h1 h2) (by decide)
    (fun a ha => cnt_nat f a 2 (h3 a ha))
  simpa using this

/-- Entropy `log 8`: the statistic separates all eight individuals. -/
theorem H_eight_cells (f : Pop → ℕ) (h1 : ∀ x, f x ∈ ({0, 1, 2, 3, 4, 5, 6, 7} : Finset ℕ))
    (h2 : ∀ a ∈ ({0, 1, 2, 3, 4, 5, 6, 7} : Finset ℕ), ∃ x, f x = a)
    (h3 : ∀ a ∈ ({0, 1, 2, 3, 4, 5, 6, 7} : Finset ℕ),
      (Finset.univ.filter fun x => f x = a).card = 1) :
    H f = Real.log 8 := by
  have := H_uniform_nat f {0, 1, 2, 3, 4, 5, 6, 7} 1 8 (by norm_num)
    (img_nat_eq f _ h1 h2) (by decide) (fun a ha => cnt_nat f a 1 (h3 a ha))
  simpa using this

/-! ## 3. The label entropy -/

theorem H_par : H par = Real.log 2 :=
  H_two_cells par (by decide) (by decide) (by decide)

theorem Hb_par : Hb par = 1 := by
  rw [Hb, H_par]
  field_simp

/-! ## 4. Every single dial is blind to the label -/

/-- A single coordinate is a balanced bit. -/
theorem H_rd (i : Fin 3) : H (rd i) = Real.log 2 := by
  fin_cases i <;> exact H_two_cells _ (by decide) (by decide) (by decide)

/-- Label and one coordinate are jointly balanced on four cells. -/
theorem H_pr_par_rd (i : Fin 3) : H (pr par (rd i)) = Real.log 4 := by
  have hcode : H (pr par (rd i)) = H (fun x => 2 * par x + rd i x) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    fin_cases i <;> revert x y <;> decide
  rw [hcode]
  fin_cases i <;> exact H_four_cells _ (by decide) (by decide) (by decide)

/-- **Each dial alone carries nothing.** -/
theorem MI_par_rd (i : Fin 3) : MI par (rd i) = 0 := by
  rw [MI_eq, H_par, H_rd i, H_pr_par_rd i, log_four]
  ring

theorem info_singleton (i : Fin 3) : info pdial par {i} = 0 := by
  have hfib : ∀ x y : Pop, joint pdial {i} x = joint pdial {i} y ↔ rd i x = rd i y := by
    intro x y
    rw [joint_fiber_iff]
    simp
  rw [info, MIb, MI_eq_of_same_fibers par (joint pdial {i}) (rd i) hfib, MI_par_rd i, zero_div]

/-! ## 5. Every pair of dials is blind to the label -/

/-- The pair code of two distinct coordinates is balanced on four cells. -/
theorem H_pair_code (i j : Fin 3) (hij : i ≠ j) :
    H (fun x => 2 * rd i x + rd j x) = Real.log 4 := by
  fin_cases i <;> fin_cases j <;>
    first
      | exact absurd rfl hij
      | exact H_four_cells _ (by decide) (by decide) (by decide)

/-- Label plus two coordinates separate all eight individuals. -/
theorem H_pr_par_pair (i j : Fin 3) (hij : i ≠ j) :
    H (pr par (fun x => 2 * rd i x + rd j x)) = Real.log 8 := by
  have hcode : H (pr par (fun x => 2 * rd i x + rd j x))
      = H (fun x => 4 * par x + 2 * rd i x + rd j x) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    fin_cases i <;> fin_cases j <;> revert x y <;> decide
  rw [hcode]
  fin_cases i <;> fin_cases j <;>
    first
      | exact absurd rfl hij
      | exact H_eight_cells _ (by decide) (by decide) (by decide)

/-- **Any two dials together still carry nothing.** -/
theorem MI_par_pair (i j : Fin 3) (hij : i ≠ j) :
    MI par (fun x => 2 * rd i x + rd j x) = 0 := by
  rw [MI_eq, H_par, H_pair_code i j hij, H_pr_par_pair i j hij, log_four, log_eight]
  ring

theorem info_pair_explicit (i j : Fin 3) (hij : i ≠ j) : info pdial par {i, j} = 0 := by
  have hfib : ∀ x y : Pop, joint pdial {i, j} x = joint pdial {i, j} y ↔
      (fun x => 2 * rd i x + rd j x) x = (fun x => 2 * rd i x + rd j x) y := by
    intro x y
    rw [joint_fiber_iff]
    simp only [Finset.mem_insert, Finset.mem_singleton, forall_eq_or_imp, forall_eq]
    constructor
    · rintro ⟨h1, h2⟩
      simp only [h1, h2]
    · intro h
      have hb : ∀ (k : Fin 3) (z : Pop), rd k z < 2 := by
        intro k z
        fin_cases k <;> exact bnat_lt_two _
      have h1 := hb i x
      have h2 := hb i y
      have h3 := hb j x
      have h4 := hb j y
      simp only at h
      omega
  rw [info, MIb, MI_eq_of_same_fibers par (joint pdial {i, j}) _ hfib, MI_par_pair i j hij,
    zero_div]

/-- **No pair of dials carries anything.** -/
theorem info_pair (S : Finset (Fin 3)) (hS : S.card = 2) : info pdial par S = 0 := by
  have hcases : S = {0, 1} ∨ S = {0, 2} ∨ S = {1, 2} := by
    revert hS
    revert S
    decide
  rcases hcases with rfl | rfl | rfl
  · exact info_pair_explicit 0 1 (by decide)
  · exact info_pair_explicit 0 2 (by decide)
  · exact info_pair_explicit 1 2 (by decide)

/-! ## 6. The full battery saturates the label-entropy ceiling -/

/-- **The whole battery pins the label**, so it carries exactly `Hb L = 1` bit —
the joint label-entropy ceiling. -/
theorem info_univ : info pdial par (Finset.univ : Finset (Fin 3)) = 1 := by
  have hdet : ∀ x y : Pop, joint pdial Finset.univ x = joint pdial Finset.univ y →
      par x = par y := by
    intro x y h
    have h' : ∀ i ∈ (Finset.univ : Finset (Fin 3)), rd i x = rd i y :=
      (joint_fiber_iff _ x y).1 h
    have h0 := h' 0 (Finset.mem_univ _)
    have h1 := h' 1 (Finset.mem_univ _)
    have h2 := h' 2 (Finset.mem_univ _)
    clear h h'
    revert h0 h1 h2
    revert x y
    decide
  rw [info, MIb_eq_label_entropy_of_determines par _ hdet, Hb_par]

/-! ## 7. The verdict, in its extreme form -/

theorem synergy_pairs_zero (S : Finset (Fin 3)) (hS : S.card = 2) :
    synergy pdial par S = 0 := by
  rw [synergy, info_pair S hS, Finset.sum_congr rfl (fun i _ => info_singleton i)]
  simp

theorem pairSynergyTotal_zero :
    pairSynergyTotal pdial par (Finset.univ : Finset (Fin 3)) = 0 := by
  refine Finset.sum_eq_zero fun T hT => ?_
  exact synergy_pairs_zero T (Finset.mem_powersetCard.1 hT).2

theorem synergy_univ_one : synergy pdial par (Finset.univ : Finset (Fin 3)) = 1 := by
  rw [synergy, info_univ, Finset.sum_congr rfl (fun i _ => info_singleton i)]
  simp

/-- **SYNERGY-COMPOUNDS, extreme form.**  For the three-dial parity battery:

* every marginal capacity is `0`, so the additive prediction is `0`;
* every pairwise capacity — and hence the entire pairwise synergy table — is
  `0`;
* the full battery carries `1` bit, exactly its joint label-entropy ceiling;
* consequently all of the capacity is order-`3` synergy.

In particular no inequality `info ≤ c · Σ marginals` can hold for any constant
`c`, and no bound on the pairwise synergies constrains the joint synergy. -/
theorem parity_capacity_is_purely_higher_order :
    (∀ i : Fin 3, info pdial par {i} = 0) ∧
    (∀ S : Finset (Fin 3), S.card = 2 → info pdial par S = 0) ∧
    pairSynergyTotal pdial par Finset.univ = 0 ∧
    info pdial par Finset.univ = Hb par ∧
    synergy pdial par Finset.univ = 1 :=
  ⟨info_singleton, info_pair, pairSynergyTotal_zero, by rw [info_univ, Hb_par], synergy_univ_one⟩

end BatterySynergy