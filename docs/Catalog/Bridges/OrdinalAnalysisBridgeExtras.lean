/-
# Ordinal analysis bridge, part II: resolving the open questions

This file continues `Catalog/Bridges/OrdinalAnalysisBridge.lean`. It settles several of
the questions that were left open there.

## Part 1: `psi` is strictly increasing (namespace `Bridges.OrdinalCollapsing`)

* `psi_strictMono` : `psi` is *strictly* monotone (not merely monotone);
* `self_le_psi` : hence `a ≤ psi a` for every `a`;
* `Om_le_psi_Om`, `not_forall_psi_lt_Om` : consequently the collapse does **not** stay
  countable in this (unrestricted-hull) presentation: `Ω ≤ psi Ω`. This *refutes*
  conjecture C1 of `FUTURE_DIRECTIONS.md`, and shows that the constant
  `bachmannHoward = psi (ε_{Ω+1})` of the first file is a strict upper bound for, rather
  than a copy of, the genuine Bachmann–Howard ordinal (`Om_lt_bachmannHoward`). All the
  bridge theorems of the first file are unaffected: they only use `ε₀ < psi (Ω^ω) ≤
  psi (ε_{Ω+1})`.

## Part 2: the `Ω,ψ`-free fragment is exactly `Iio ε₀` (namespace `Bridges.OrdinalAnalysis`)

* `OTerm.Simple` : the terms built from `0`, `+` and `ω ^ ·` only;
* `simple_val_lt_eps0`, `exists_simple_of_lt_eps0`, `simple_val_range` :
  `{t.val | t Simple} = Iio ε₀`. This proves conjecture C4.

## Part 3: the rewriting system is confluent

* `OTerm.norm` : an explicit normalising function (flatten sums to the right, delete
  zeros), built from `OTerm.appendT`;
* `norm_eq_of_step`, `norm_of_normal` : `norm` is invariant under rewriting and fixes
  normal forms;
* `normal_unique`, `step_confluent`, `step_church_rosser` : normal forms are unique and
  the system is confluent. This proves conjecture C3.
-/
import Bridges.OrdinalAnalysisBridge

namespace Bridges.OrdinalCollapsing

open Ordinal Set Order

noncomputable section

/-! ## `psi` is strictly increasing -/

/-- Distinct arguments give distinct collapses: `psi a` is a generator at stage `b`
whenever `a < b`, while `psi b` is by definition not generated at stage `b`. -/
theorem psi_ne_of_lt {a b : Ordinal.{0}} (h : a < b) : psi a ≠ psi b := by
  intro heq
  refine not_gen_psi b ?_
  rw [← heq]
  exact Gen.base (psi_mem_gens h)

/-- **`psi` is strictly monotone.** -/
theorem psi_strictMono : StrictMono psi := by
  intro a b hab
  exact lt_of_le_of_ne (psi_mono hab.le) (psi_ne_of_lt hab)

/-- A strictly monotone function on the ordinals is inflationary. -/
theorem self_le_psi (a : Ordinal.{0}) : a ≤ psi a :=
  psi_strictMono.le_apply

/-- Therefore the collapse of `Ω` is *not* countable. -/
theorem Om_le_psi_Om : Om ≤ psi Om := self_le_psi Om

/-- **Refutation of conjecture C1**: in this unrestricted-hull presentation the
collapsing function does not stay below `Ω`. -/
theorem not_forall_psi_lt_Om : ¬ ∀ a : Ordinal.{0}, psi a < Om :=
  fun h => absurd (h Om) (not_lt.2 Om_le_psi_Om)

/-- Consequently `bachmannHoward = psi (ε_{Ω+1})` is (strictly) above `Ω`, so it is a
strict upper bound for the genuine Bachmann–Howard ordinal rather than equal to it. -/
theorem Om_lt_bachmannHoward : Om < bachmannHoward := by
  have h1 : Om < nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) :=
    lt_of_lt_of_le (lt_add_one Om) (le_nfp _ _)
  exact lt_of_lt_of_le h1 (self_le_psi _)

/-- `psi` is unbounded in the ordinals. -/
theorem psi_unbounded (a : Ordinal.{0}) : ∃ b, a ≤ psi b := ⟨a, self_le_psi a⟩

end

end Bridges.OrdinalCollapsing

namespace Bridges.OrdinalAnalysis

open Ordinal Set Bridges.OrdinalCollapsing

/-! ## Part 2: the `Ω, ψ`-free fragment -/

/-- A term is *simple* when it uses neither `Ω` nor `ψ`, i.e. it is built from `0`,
`+` and `ω ^ ·` alone. -/
def OTerm.Simple : OTerm → Prop
  | .zero => True
  | .Om => False
  | .add a b => a.Simple ∧ b.Simple
  | .opow a => a.Simple
  | .psi _ => False

theorem OTerm.simple_repeatAdd {t s : OTerm} (ht : t.Simple) (hs : s.Simple) (n : ℕ) :
    (repeatAdd t n s).Simple := by
  induction n with
  | zero => simpa [repeatAdd] using hs
  | succ n ih => exact ⟨ht, ih⟩

/-- Simple terms denote ordinals below `ε₀`. -/
theorem simple_val_lt_eps0 {t : OTerm} (ht : t.Simple) : t.val < eps0 := by
  induction t with
  | zero => simpa using eps0_pos
  | Om => exact absurd ht not_false
  | add a b iha ihb =>
      obtain ⟨ha, hb⟩ := ht
      exact principal_add_eps0 (iha ha) (ihb hb)
  | opow a iha => exact opow_lt_eps0 (iha ht)
  | psi a _ => exact absurd ht not_false

/-- Conversely, every ordinal below `ε₀` is denoted by a simple term. -/
theorem exists_simple_of_lt_eps0 {b : Ordinal.{0}} (hb : b < eps0) :
    ∃ t : OTerm, t.Simple ∧ t.val = b := by
  induction b using Ordinal.induction with
  | h b ih =>
    by_cases hb0 : b = 0
    · exact ⟨.zero, trivial, by simp [hb0]⟩
    · have hlog : Ordinal.log ω b < b := log_lt_self_of_lt_eps0 hb0 hb
      obtain ⟨n, r, hr, hb_eq⟩ := cnf_step hb0
      obtain ⟨te, hte, hteval⟩ := ih _ hlog (lt_trans hlog hb)
      obtain ⟨tr, htr, htrval⟩ := ih r hr (lt_trans hr hb)
      refine ⟨repeatAdd (.opow te) n tr,
        OTerm.simple_repeatAdd (t := .opow te) hte htr n, ?_⟩
      rw [val_repeatAdd]
      simp only [OTerm.val_opow, hteval, htrval]
      exact hb_eq.symm

/-- **Conjecture C4**: the set of ordinals denoted by `Ω, ψ`-free terms is exactly the
set of ordinals below `ε₀`, the proof-theoretic ordinal of `PA`. -/
theorem simple_val_range : {x : Ordinal.{0} | ∃ t : OTerm, t.Simple ∧ t.val = x} = Iio eps0 := by
  ext x
  constructor
  · rintro ⟨t, ht, rfl⟩
    exact simple_val_lt_eps0 ht
  · intro hx
    exact exists_simple_of_lt_eps0 hx

/-! ## Part 3: confluence of the rewriting system -/

namespace OTerm

/-- `appendT t u` concatenates two right-nested sums, deleting units. -/
def appendT : OTerm → OTerm → OTerm
  | .zero, u => u
  | .add a b, u => .add a (appendT b u)
  | .Om, .zero => .Om
  | .Om, u => .add .Om u
  | .opow a, .zero => .opow a
  | .opow a, u => .add (.opow a) u
  | .psi a, .zero => .psi a
  | .psi a, u => .add (.psi a) u

/-- The canonical normal form of a term: sums are re-associated to the right and units
are deleted, recursively inside all subterms. -/
def norm : OTerm → OTerm
  | .zero => .zero
  | .Om => .Om
  | .add a b => appendT (norm a) (norm b)
  | .opow a => .opow (norm a)
  | .psi a => .psi (norm a)

@[simp] theorem appendT_zero_left (u : OTerm) : appendT .zero u = u := rfl

@[simp] theorem appendT_zero_right (t : OTerm) : appendT t .zero = t := by
  induction t with
  | zero => rfl
  | Om => rfl
  | add a b _ ihb => simp [appendT, ihb]
  | opow a _ => rfl
  | psi a _ => rfl

theorem appendT_eq_zero {t u : OTerm} (h : appendT t u = .zero) : t = .zero ∧ u = .zero := by
  induction t with
  | zero => exact ⟨rfl, h⟩
  | Om => cases u <;> simp [appendT] at h
  | add a b _ _ => simp [appendT] at h
  | opow a _ => cases u <;> simp [appendT] at h
  | psi a _ => cases u <;> simp [appendT] at h

theorem appendT_atomic {a u : OTerm} (ha : ∀ x y, a ≠ .add x y) (ha0 : a ≠ .zero)
    (hu : u ≠ .zero) : appendT a u = .add a u := by
  cases a with
  | zero => exact absurd rfl ha0
  | add x y => exact absurd rfl (ha x y)
  | Om => cases u <;> simp_all [appendT]
  | opow x => cases u <;> simp_all [appendT]
  | psi x => cases u <;> simp_all [appendT]

theorem appendT_assoc (a b c : OTerm) :
    appendT (appendT a b) c = appendT a (appendT b c) := by
  induction a with
  | zero => rfl
  | add x y _ ihy => simp [appendT, ihy]
  | Om =>
      rcases eq_or_ne b .zero with rfl | hb
      · simp
      · have hbc : appendT b c ≠ .zero := fun h => hb (appendT_eq_zero h).1
        rw [appendT_atomic (by simp) (by simp) hb, appendT_atomic (by simp) (by simp) hbc]
        rfl
  | opow x _ =>
      rcases eq_or_ne b .zero with rfl | hb
      · simp
      · have hbc : appendT b c ≠ .zero := fun h => hb (appendT_eq_zero h).1
        rw [appendT_atomic (by simp) (by simp) hb, appendT_atomic (by simp) (by simp) hbc]
        rfl
  | psi x _ =>
      rcases eq_or_ne b .zero with rfl | hb
      · simp
      · have hbc : appendT b c ≠ .zero := fun h => hb (appendT_eq_zero h).1
        rw [appendT_atomic (by simp) (by simp) hb, appendT_atomic (by simp) (by simp) hbc]
        rfl

end OTerm

/-- `norm` is invariant under one rewriting step. -/
theorem norm_eq_of_step {t u : OTerm} (h : Step t u) : t.norm = u.norm := by
  induction h with
  | zero_add t => simp [OTerm.norm]
  | add_zero t => simp [OTerm.norm]
  | assoc a b c => simp [OTerm.norm, OTerm.appendT_assoc]
  | addL b _ ih => simp [OTerm.norm, ih]
  | addR a _ ih => simp [OTerm.norm, ih]
  | opowC _ ih => simp [OTerm.norm, ih]
  | psiC _ ih => simp [OTerm.norm, ih]

/-- `norm` is invariant under arbitrary rewriting sequences. -/
theorem norm_eq_of_rtstep {t u : OTerm} (h : Relation.ReflTransGen Step t u) :
    t.norm = u.norm := by
  induction h with
  | refl => rfl
  | tail _ hstep ih => rw [ih]; exact norm_eq_of_step hstep

/-- Structural description of normal forms. -/
theorem normal_add {a b : OTerm} (h : Normal (.add a b)) :
    Normal a ∧ Normal b ∧ a ≠ .zero ∧ b ≠ .zero ∧ ∀ x y, a ≠ .add x y := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro u hu; exact h _ (Step.addL b hu)
  · intro u hu; exact h _ (Step.addR a hu)
  · rintro rfl; exact h b (Step.zero_add b)
  · rintro rfl; exact h a (Step.add_zero a)
  · rintro x y rfl; exact h _ (Step.assoc x y b)

/-- Normal terms are fixed by `norm`. -/
theorem norm_of_normal {t : OTerm} (h : Normal t) : t.norm = t := by
  induction t with
  | zero => rfl
  | Om => rfl
  | add a b iha ihb =>
      obtain ⟨hna, hnb, ha0, hb0, hnadd⟩ := normal_add h
      rw [OTerm.norm, iha hna, ihb hnb]
      cases a with
      | zero => exact absurd rfl ha0
      | Om => cases b <;> simp_all [OTerm.appendT]
      | add x y => exact absurd rfl (hnadd x y)
      | opow x => cases b <;> simp_all [OTerm.appendT]
      | psi x => cases b <;> simp_all [OTerm.appendT]
  | opow a iha =>
      have : Normal a := fun u hu => h _ (Step.opowC hu)
      rw [OTerm.norm, iha this]
  | psi a iha =>
      have : Normal a := fun u hu => h _ (Step.psiC hu)
      rw [OTerm.norm, iha this]

/-- **Normal forms are unique**: two normal forms of the same term are equal. -/
theorem normal_unique {t u v : OTerm} (hu : Relation.ReflTransGen Step t u)
    (hv : Relation.ReflTransGen Step t v) (hnu : Normal u) (hnv : Normal v) : u = v := by
  have h1 : u.norm = v.norm := by rw [← norm_eq_of_rtstep hu, norm_eq_of_rtstep hv]
  rwa [norm_of_normal hnu, norm_of_normal hnv] at h1

/-- **Conjecture C3: the rewriting system is confluent.** -/
theorem step_confluent {t u v : OTerm} (hu : Relation.ReflTransGen Step t u)
    (hv : Relation.ReflTransGen Step t v) :
    ∃ w, Relation.ReflTransGen Step u w ∧ Relation.ReflTransGen Step v w := by
  obtain ⟨u', hu', hnu'⟩ := exists_normal u
  obtain ⟨v', hv', hnv'⟩ := exists_normal v
  have : u' = v' := normal_unique (hu.trans hu') (hv.trans hv') hnu' hnv'
  exact ⟨u', hu', this ▸ hv'⟩

/-- `norm` is invariant under the equivalence generated by rewriting. -/
theorem norm_eq_of_eqvGen {t u : OTerm} (h : Relation.EqvGen Step t u) : t.norm = u.norm := by
  induction h with
  | rel a b hab => exact norm_eq_of_step hab
  | refl a => rfl
  | symm a b _ ih => exact ih.symm
  | trans a b c _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-- Every term has a unique normal form; `norm` computes it. -/
theorem norm_normal_form (t : OTerm) :
    Relation.ReflTransGen Step t t.norm ∧ Normal t.norm := by
  obtain ⟨u, htu, hnu⟩ := exists_normal t
  have : t.norm = u := by rw [norm_eq_of_rtstep htu, norm_of_normal hnu]
  rw [this]
  exact ⟨htu, hnu⟩

/-- **Church–Rosser property**: two terms related by the equivalence generated by the
rewriting relation have a common reduct. -/
theorem step_church_rosser {t u : OTerm} (h : Relation.EqvGen Step t u) :
    ∃ w, Relation.ReflTransGen Step t w ∧ Relation.ReflTransGen Step u w := by
  refine ⟨t.norm, (norm_normal_form t).1, ?_⟩
  rw [norm_eq_of_eqvGen h]
  exact (norm_normal_form u).1

/-- The `ω`-indexed approximations `psi (Ω ^ n)` are all strictly below `psi (Ω ^ ω)`. -/
theorem psi_Om_pow_nat_lt (n : ℕ) :
    Bridges.OrdinalCollapsing.psi (Om ^ (n : Ordinal)) <
      Bridges.OrdinalCollapsing.psi (Om ^ (ω : Ordinal)) := by
  have hOm : 1 < Om := lt_of_lt_of_le one_lt_omega0 omega0_lt_omega_one.le
  exact psi_strictMono ((opow_lt_opow_iff_right hOm).2 (nat_lt_omega0 n))

/-- Half of conjecture C5: the supremum of the approximations is at most `psi (Ω ^ ω)`. -/
theorem iSup_psi_Om_pow_le :
    (⨆ n : ℕ, Bridges.OrdinalCollapsing.psi (Om ^ (n : Ordinal))) ≤
      Bridges.OrdinalCollapsing.psi (Om ^ (ω : Ordinal)) :=
  Ordinal.iSup_le fun n => (psi_Om_pow_nat_lt n).le

/-- The normal form computed by `norm` denotes the same ordinal as the term itself. -/
theorem val_norm (t : OTerm) : t.norm.val = t.val :=
  (RTStep.val_eq (norm_normal_form t).1).symm

end Bridges.OrdinalAnalysis