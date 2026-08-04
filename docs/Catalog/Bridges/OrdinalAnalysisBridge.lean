/-
# Proof-theoretic bridge: ordinal analysis across PA and KP

This file develops, from scratch inside Mathlib's `Ordinal`, a Madore-style ordinal
collapsing function

  `psi a = min { b | b is not generated from {0, Ω} ∪ {psi c | c < a} by `+` and `x ↦ ω ^ x` }`

where `Ω = ω₁` is the first uncountable ordinal, formalises it as a *term rewriting
system*, and builds an explicit order-preserving map from the ordinal notations of `PA`
into that system.

## Part 1: the collapsing function (namespace `Bridges.OrdinalCollapsing`)

* `psi` : the collapsing function, defined by well-founded recursion; it is well defined
  because the Skolem hull of a bounded set of ordinals stays below any epsilon number
  above it (`Gen.lt_of_forall_lt`, `exists_not_gen`);
* `psi_zero` : `psi 0 = ε₀`, the proof-theoretic ordinal of `PA`;
* `psi_mono` : `psi` is monotone;
* `eps0_lt_psi_of_pos` : `ε₀ < psi a` for every `a > 0`;
* `eps0_lt_psi_Om_opow_omega` : **`ε₀ < psi (Ω ^ ω)`**;
* `bachmannHoward` : `psi (ε_{Ω+1})` (an upper bound for the Bachmann–Howard ordinal, the
  proof-theoretic ordinal of Kripke–Platek set theory `KP`; see the caveat at its
  definition), with `psi_Om_opow_omega_le_bachmannHoward` and `eps0_lt_bachmannHoward`.

## Part 2: the term rewriting system and the bridge (namespace `Bridges.OrdinalAnalysis`)

* `OTerm` : notation terms built from `0`, `Ω`, `+`, `x ↦ ω ^ x` and `ψ`, with the
  interpretation `OTerm.val`;
* `Step` : the one-step rewrite relation (unit laws and associativity of `+`, closed
  under all contexts). It is sound (`Step.val_eq`, `RTStep.val_eq`) and terminating
  (`Step.weight_lt`, `step_wf`), so normal forms exist (`exists_normal`) and are
  semantically unique (`normal_val_unique`);
* `eps0Term_val_lt_psi_OmOmegaTerm` : `ε₀ < ψ(Ω ^ ω)` stated inside the term system;
* `ofONote` : the explicit translation of Mathlib's Cantor normal forms (the `PA`
  notation system) into `OTerm`, with `val_ofONote`, `ofONote_val_lt_iff` and
  `strictMono_ofONote` showing it is value preserving and order preserving;
* `ofONote_val_lt_psi_OmOmegaTerm`, `ofONote_val_lt_bachmannHoward` : the image of the
  `PA` notation system lies strictly below `ψ(Ω ^ ω)`, hence below the Bachmann–Howard
  ordinal.

Everything is proved; no axioms beyond Mathlib's are used.
-/
import Mathlib

namespace Bridges.OrdinalCollapsing

open Ordinal Set Order

noncomputable section

/-! ## `ε₀` and `Ω` -/

/-- `Om` is `Ω`, the first uncountable ordinal `ω₁`. It plays the role of an
"uncountable" (regular) ordinal, i.e. a formal symbol above all countable notations. -/
def Om : Ordinal.{0} := ω_ 1

/-- `eps0` is `ε₀`, the least fixed point of `x ↦ ω ^ x`; the proof-theoretic ordinal of `PA`. -/
def eps0 : Ordinal.{0} := nfp (fun x : Ordinal.{0} => ω ^ x) 0

theorem isNormal_omega0_opow : IsNormal (fun x : Ordinal.{0} => ω ^ x) :=
  isNormal_opow one_lt_omega0

@[simp] theorem opow_eps0 : ω ^ eps0 = eps0 :=
  nfp_fp isNormal_omega0_opow 0

theorem eps0_le_of_fp {b : Ordinal.{0}} (h : ω ^ b = b) : eps0 ≤ b :=
  nfp_le_fp isNormal_omega0_opow.monotone bot_le h.le

theorem eps0_pos : 0 < eps0 := by
  have h : (0 : Ordinal) < ω ^ eps0 := opow_pos _ omega0_pos
  rwa [opow_eps0] at h

/-- `ε₀` is closed under `x ↦ ω ^ x`. -/
theorem opow_lt_eps0 {x : Ordinal.{0}} (h : x < eps0) : ω ^ x < eps0 := by
  calc ω ^ x < ω ^ eps0 := (opow_lt_opow_iff_right one_lt_omega0).2 h
    _ = eps0 := opow_eps0

/-- `ε₀` is additively principal. -/
theorem principal_add_eps0 : Principal (· + ·) eps0 := by
  have := principal_add_omega0_opow eps0
  rwa [opow_eps0] at this

/-- The `ω`-towers `(ω ^ ·)^[n] 0` approximating `ε₀` are all countable. -/
theorem tower_lt_Om (n : ℕ) : (fun x : Ordinal.{0} => ω ^ x)^[n] 0 < Om := by
  induction n with
  | zero => unfold Om; exact lt_of_le_of_lt (zero_le omega0) omega0_lt_omega_one
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    unfold Om
    have : ∀ x < ω_ 1, ω ^ x < ω_ 1 := by
      intro x hx
      have hcard : x.card ≤ Cardinal.aleph0 := by
        have hlt : x.card < Cardinal.aleph 1 := by
          exact Cardinal.lt_ord.mp (hx.trans_le (le_of_eq (Cardinal.ord_aleph 1).symm))
        rw [← Cardinal.succ_aleph0] at hlt
        exact (Order.lt_succ_iff.mp hlt)
      have h2 : (ω ^ x).card ≤ Cardinal.aleph0 := by
        have hω : (ω : Ordinal).card = Cardinal.aleph0 := Ordinal.card_omega0
        have := Ordinal.card_opow_le ω x
        rw [hω] at this
        simp only [max_eq_left hcard, max_eq_left rfl.le] at this
        exact this
      have hlt : (ω ^ x).card < Cardinal.aleph 1 := lt_of_le_of_lt h2 Cardinal.aleph0_lt_aleph_one
      have hω1 : (ω_ (1 : Ordinal.{0})) = (Cardinal.aleph 1).ord := Eq.symm (Cardinal.ord_aleph 1)
      rw [hω1]
      exact Cardinal.lt_ord.mpr hlt
    exact this _ ih

/-- `ε₀` is the supremum of the `ω`-towers. -/
theorem eps0_eq_iSup_tower : eps0 = ⨆ n : ℕ, (fun x : Ordinal.{0} => ω ^ x)^[n] 0 :=
  (iSup_iterate_eq_nfp _ _).symm

/-- `Ω` is the ordinal of the first uncountable cardinal. -/
theorem Om_eq_ord_aleph_one : Om = (Cardinal.aleph 1).ord := (Cardinal.ord_aleph 1).symm

/-- The supremum of the `ω`-towers is countable. -/
theorem iSup_tower_lt_Om : (⨆ n : ℕ, (fun x : Ordinal.{0} => ω ^ x)^[n] 0) < Om := by
  rw [Om_eq_ord_aleph_one]
  exact Ordinal.iSup_sequence_lt_omega_one _ fun n => Om_eq_ord_aleph_one ▸ tower_lt_Om n

/-- `ε₀` is countable, hence below `Ω`. -/
theorem eps0_lt_Om : eps0 < Om := by
  rw [eps0_eq_iSup_tower]
  exact iSup_tower_lt_Om

/-! ## The generation predicate -/

/-- `Gen S x` says that the ordinal `x` is generated from the set `S` using ordinal
addition and base-`ω` exponentiation. This is the (inductive presentation of the)
Skolem hull used in the definition of ordinal collapsing functions. -/
inductive Gen (S : Set Ordinal.{0}) : Ordinal.{0} → Prop
  | base {x} : x ∈ S → Gen S x
  | add {x y} : Gen S x → Gen S y → Gen S (x + y)
  | opow {x} : Gen S x → Gen S (ω ^ x)

theorem Gen.mono {S T : Set Ordinal.{0}} (h : S ⊆ T) {x : Ordinal.{0}} (hx : Gen S x) :
    Gen T x := by
  induction hx with
  | base hm => exact Gen.base (h hm)
  | add _ _ ih₁ ih₂ => exact Gen.add ih₁ ih₂
  | opow _ ih => exact Gen.opow ih

/-- Generated sets are closed under multiplication by a natural number, provided `0` is
a generator. -/
theorem Gen.mul_nat {S : Set Ordinal.{0}} (h0 : (0 : Ordinal.{0}) ∈ S) {x : Ordinal.{0}}
    (hx : Gen S x) : ∀ n : ℕ, Gen S (x * (n : Ordinal.{0})) := by
  intro n
  induction n with
  | zero =>
    simp only [Nat.cast_zero, mul_zero]
    exact Gen.base h0
  | succ n ih =>
    simp [Nat.cast_add, Nat.cast_one, mul_succ]
    exact Gen.add ih hx

/-- Every ordinal generated from a set of ordinals below an epsilon number `m` stays below `m`. -/
theorem Gen.lt_of_forall_lt {S : Set Ordinal.{0}} {m : Ordinal.{0}} (hm : ω ^ m = m)
    (hS : ∀ x ∈ S, x < m) : ∀ {x : Ordinal.{0}}, Gen S x → x < m := by
  intro x hx
  induction hx with
  | base hxS => exact hS _ hxS
  | add ih₁ ih₂ =>
    apply (principal_add_omega0_opow m _ _).trans_eq hm
    all_goals exact hm.symm ▸ by assumption
  | opow ih ih' =>
    rw [← hm]
    exact (opow_lt_opow_iff_right one_lt_omega0).2 (hm.symm ▸ ih')

/-- Above any ordinal there is an epsilon number. -/
theorem exists_fp_above (c : Ordinal.{0}) : ∃ m : Ordinal.{0}, c < m ∧ ω ^ m = m := by
  use nfp (fun x : Ordinal.{0} => ω ^ x) (c + 1)
  exact ⟨lt_of_lt_of_le (lt_add_one _) (le_nfp _ _), nfp_fp isNormal_omega0_opow _⟩

/-- Below `ε₀` the base-`ω` logarithm strictly decreases: this is what makes the
Cantor normal form induction below terminate. -/
theorem log_lt_self_of_lt_eps0 {b : Ordinal.{0}} (hb : b ≠ 0) (h : b < eps0) :
    Ordinal.log ω b < b := by
  by_contra hcontra
  push_neg at hcontra
  have hlog_le : ω ^ Ordinal.log ω b ≤ b := Ordinal.opow_log_le_self ω hb
  have hwb : ω ^ b ≤ b := by
    exact le_trans (isNormal_omega0_opow.monotone hcontra) hlog_le
  have hble : b ≤ ω ^ b := isNormal_omega0_opow.strictMono.id_le _
  have heq : ω ^ b = b := le_antisymm hwb hble
  have h.eps0_le : eps0 ≤ b := eps0_le_of_fp heq
  exact lt_irrefl _ (h.eps0_le.trans_lt h)

/-- One step of the Cantor normal form: a nonzero ordinal `b` is
`ω ^ (log ω b) * n + r` for a natural number `n` and a remainder `r < b`. -/
theorem cnf_step {b : Ordinal.{0}} (hb : b ≠ 0) :
    ∃ (n : ℕ) (r : Ordinal.{0}), r < b ∧ b = ω ^ Ordinal.log ω b * (n : Ordinal.{0}) + r := by
  set e := Ordinal.log ω b with he_def
  set q := b / ω ^ e with hq_def
  set r := b % ω ^ e with hr_def
  have hωpos : (0 : Ordinal) < ω := omega0_pos
  have hc : (0 : Ordinal) < ω ^ e := Ordinal.opow_pos _ hωpos
  -- Key: q < ω, so q is a natural number
  have hlog : ω ^ e ≤ b := Ordinal.opow_log_le_self ω hb
  have hlog_succ : b < ω ^ (e + 1) := Ordinal.lt_opow_succ_log_self one_lt_omega0 b
  have hq_lt_ω : q < ω := by
    rw [hq_def]
    have h1 : ω ^ (e + 1) = ω ^ e * ω := by rw [opow_add ω e 1, opow_one]
    rw [h1] at hlog_succ
    rw [Ordinal.div_lt (ne_of_gt hc)]
    exact hlog_succ
  -- q < ω means q is a natural number
  have hq_nat : ∃ n : ℕ, q = n := by
    exact lt_omega0.mp hq_lt_ω
  obtain ⟨n, hn⟩ := hq_nat
  -- Division algorithm: b = ω^e * q + (b % ω^e)
  have div_mod : b = ω ^ e * q + (b % ω ^ e) := (Ordinal.div_add_mod b (ω ^ e)).symm
  -- Remainder is less than ω^e, which is ≤ b
  have r_lt_oe : b % ω ^ e < ω ^ e := Ordinal.mod_lt b (ne_of_gt hc)
  have r_lt_b : b % ω ^ e < b := lt_of_lt_of_le r_lt_oe hlog
  use n, b % ω ^ e, r_lt_b
  rw [hn] at div_mod
  exact div_mod

/-- The hull is closed under the Cantor normal form step. -/
theorem gen_cnf_step {S : Set Ordinal.{0}} (h0 : (0 : Ordinal.{0}) ∈ S) {e r : Ordinal.{0}}
    (he : Gen S e) (hr : Gen S r) (n : ℕ) : Gen S (ω ^ e * (n : Ordinal.{0}) + r) :=
  Gen.add (Gen.mul_nat h0 (Gen.opow he) n) hr

/-- Every ordinal below `ε₀` is generated from `0` alone. -/
theorem gen_of_lt_eps0 {S : Set Ordinal.{0}} (h0 : (0 : Ordinal.{0}) ∈ S) :
    ∀ {b : Ordinal.{0}}, b < eps0 → Gen S b := by
  intro b hb
  induction b using Ordinal.induction with
  | h b ih =>
    by_cases hb0 : b = 0
    · simp [hb0]
      exact Gen.base h0
    · have hlog : Ordinal.log ω b < b := log_lt_self_of_lt_eps0 hb0 hb
      obtain ⟨n, r, hr, hb_eq⟩ := cnf_step hb0
      have hr_lt_eps0 : r < eps0 := lt_trans hr hb
      have he : Gen S (log ω b) := ih (log ω b) hlog (lt_trans hlog hb)
      have hr_gen : Gen S r := ih r hr hr_lt_eps0
      rw [hb_eq]
      exact gen_cnf_step h0 he hr_gen n

/-- Anything generated from `{0, Ω}` is either below `ε₀` or at least `Ω`. -/
theorem gen_base_dichotomy {x : Ordinal.{0}} (hx : Gen {0, Om} x) : x < eps0 ∨ Om ≤ x := by
  induction hx with
  | base h =>
    rcases h with rfl | rfl
    · left; exact eps0_pos
    · right; exact le_rfl
  | add _ _ ih₁ ih₂ =>
    rcases ih₁ with ha | ha <;> rcases ih₂ with hb | hb
    · left
      rw [← opow_eps0] at ha hb ⊢
      exact principal_add_omega0_opow eps0 ha hb
    · right
      apply le_trans hb
      simp
    · right; exact le_trans ha le_self_add
    · right
      apply le_trans hb
      simp
  | opow _ ih =>
    rcases ih with ha | ha
    · left; exact opow_lt_eps0 ha
    · right
      exact le_trans ha (isNormal_omega0_opow.strictMono.id_le _)

/-! ## The collapsing function -/

/-- The ordinal collapsing function `ψ`: `psi a` is the least ordinal *not* generated
from `{0, Ω} ∪ {psi c | c < a}` by addition and base-`ω` exponentiation. -/
def psi (a : Ordinal.{0}) : Ordinal.{0} :=
  sInf {b | ¬ Gen ({0, Om} ∪ Set.range (fun c : Set.Iio a => psi c.1)) b}
termination_by a
decreasing_by exact c.2

/-- The Skolem hull generators available at stage `a`. -/
def gens (a : Ordinal.{0}) : Set Ordinal.{0} :=
  {0, Om} ∪ Set.range (fun c : Set.Iio a => psi c.1)

theorem psi_eq (a : Ordinal.{0}) : psi a = sInf {b | ¬ Gen (gens a) b} := by
  rw [psi.eq_def]; rfl

theorem zero_mem_gens (a : Ordinal.{0}) : (0 : Ordinal.{0}) ∈ gens a := by
  left; left; rfl

theorem Om_mem_gens (a : Ordinal.{0}) : Om ∈ gens a := by
  left; right; rfl

theorem psi_mem_gens {a c : Ordinal.{0}} (h : c < a) : psi c ∈ gens a :=
  Or.inr ⟨⟨c, h⟩, rfl⟩

theorem gens_zero : gens 0 = {0, Om} := by
  ext x
  simp [gens]

theorem gens_mono {a a' : Ordinal.{0}} (h : a ≤ a') : gens a ⊆ gens a' := by
  intro x hx
  simp only [gens] at hx ⊢
  rcases hx with hx | ⟨c, hc⟩
  · exact Or.inl hx
  · exact Or.inr ⟨⟨c, lt_of_lt_of_le c.2 h⟩, hc⟩

theorem bddAbove_gens (a : Ordinal.{0}) : BddAbove (gens a) := by
  -- We prove by well-founded induction: for all b ≤ a, gens b is bounded
  -- which allows us to bound psi c for all c < a, hence gens a
  induction a using Ordinal.limitRecOn with
  | zero =>
    rw [gens_zero]
    use Om
    intro x hx
    rcases hx with rfl | rfl <;> simp
  | succ a ih =>
    -- Find an epsilon number above the bound of gens a
    obtain ⟨M, hM⟩ := ih
    obtain ⟨M', hM'_gt, hM'_fp⟩ := exists_fp_above M
    -- All elements of gens a are < M'
    have hlt_gens : ∀ x ∈ gens a, x < M' := fun x hx => lt_of_le_of_lt (hM hx) hM'_gt
    -- M' is not generated from gens a
    have hM'_not_gen : ¬ Gen (gens a) M' := fun hgen => not_lt_of_ge (le_refl M') (Gen.lt_of_forall_lt hM'_fp hlt_gens hgen)
    -- psi a ≤ M' since M' is in the set {b | ¬ Gen (gens a) b}
    have hpsi_bound : psi a ≤ M' := by
      rw [psi_eq]
      exact csInf_le' hM'_not_gen
    use M'
    intro x hx
    rw [gens] at hx
    rcases hx with hx | ⟨⟨c, hc⟩, rfl⟩
    · -- x ∈ {0, Om}
      have : x ∈ gens a := by
        rw [gens]
        exact Or.inl hx
      exact le_of_lt (lt_of_le_of_lt (hM this) hM'_gt)
    · -- x = psi c where c < succ a
      simp only [Set.mem_Iio] at hc
      have hc' : c < succ a := hc
      rw [lt_succ_iff] at hc'
      rcases hc'.eq_or_lt with rfl | hc''
      · exact hpsi_bound
      · exact le_of_lt (lt_of_le_of_lt (hM (psi_mem_gens hc'')) hM'_gt)
  | limit a hlim ih =>
    have ⟨hlim_not_min, hlim_prelimit⟩ := hlim
    -- For limit a > 0, pick b with 0 < b < a
    have ha_pos : 0 < a := by
      contrapose! hlim_not_min
      intro b hb
      rw [nonpos_iff_eq_zero] at hlim_not_min
      rw [hlim_not_min]
      exact zero_le b
    -- Define bound function: for each d < a, get a bound for gens d
    let bound : {d : Ordinal // d < a} → Ordinal := fun ⟨d, hd⟩ => Classical.choose (ih d hd)
    -- Take supremum of all bounds
    let M := iSup (fun d : Set.Iio a => bound d)
    -- Use max with Om to also bound {0, Om}
    let M'' := max M Om
    -- Find epsilon number above M''
    obtain ⟨M', hM'_gt, hM'_fp⟩ := exists_fp_above M''
    use M'
    intro x hx
    rw [gens] at hx
    rcases hx with hx | ⟨⟨c, hc⟩, rfl⟩
    · -- x ∈ {0, Om}
      have : x ≤ Om := by rcases hx with rfl | rfl <;> simp
      exact le_trans (le_trans this (le_max_right M Om)) (le_of_lt hM'_gt)
    · -- x = psi c where c < a
      -- Since a is limit (no predecessor), exists d with c < d < a
      have hc_lt : c < a := hc
      have hnot_succ : ¬ c ⋖ a := hlim_prelimit c
      -- c ⋖ a means c < a ∧ ∀ d, c < d → a ≤ d
      -- So ¬(c ⋖ a) and c < a implies ∃ d, c < d < a
      obtain ⟨d, hd_gt, hd_lt⟩ : ∃ d, c < d ∧ d < a := by
        by_contra h_no_between
        push_neg at h_no_between
        exact hnot_succ ⟨hc_lt, fun d hd => (h_no_between d hd).not_gt⟩
      -- psi c ∈ gens d
      have hpsi_in_gens_d : psi c ∈ gens d := psi_mem_gens hd_gt
      -- gens d is bounded
      have h_bound := Classical.choose_spec (ih d hd_lt)
      have hpsi_le_bound : psi c ≤ bound ⟨d, hd_lt⟩ := h_bound hpsi_in_gens_d
      -- bound d ≤ M
      have h_bound_le_M : bound ⟨d, hd_lt⟩ ≤ M := Ordinal.le_iSup (fun d : Set.Iio a => bound d) ⟨d, hd_lt⟩
      -- M < M'' ≤ M' so bound d < M'
      have hM_lt_M' : M < M' := lt_of_le_of_lt (le_max_left M Om) hM'_gt
      exact le_trans hpsi_le_bound (le_of_lt (lt_of_le_of_lt h_bound_le_M hM_lt_M'))

/-- The complement of the Skolem hull is nonempty: `psi` is well defined. -/
theorem exists_not_gen (a : Ordinal.{0}) : {b | ¬ Gen (gens a) b}.Nonempty := by
  -- Find an epsilon number above all generators
  have hbdd : BddAbove (gens a) := bddAbove_gens a
  obtain ⟨m, hm⟩ := hbdd
  -- Get a larger epsilon number
  obtain ⟨M, hM_gt, hM_fp⟩ := exists_fp_above m
  -- All generated ordinals are < M
  have hlt : ∀ x, Gen (gens a) x → x < M := fun x hx =>
    Gen.lt_of_forall_lt hM_fp (fun y hy => lt_of_le_of_lt (hm hy) hM_gt) hx
  -- M is not generated, so M ∈ {b | ¬ Gen (gens a) b}
  exact ⟨M, fun hgen => not_lt_of_ge (le_refl M) (hlt M hgen)⟩

/-- `psi a` itself is not in the hull. -/
theorem not_gen_psi (a : Ordinal.{0}) : ¬ Gen (gens a) (psi a) := by
  intro hgen
  have hmem : psi a ∈ {b | ¬ Gen (gens a) b} := by
    rw [psi_eq]
    exact csInf_mem (exists_not_gen a)
  exact hmem hgen

/-- Everything below `psi a` is in the hull. -/
theorem gen_of_lt_psi {a b : Ordinal.{0}} (h : b < psi a) : Gen (gens a) b := by
  by_contra hb
  have : psi a ≤ b := by rw [psi_eq]; exact csInf_le' hb
  exact not_lt.mpr this h

theorem psi_le_of_not_gen {a b : Ordinal.{0}} (h : ¬ Gen (gens a) b) : psi a ≤ b := by
  rw [psi_eq]; exact csInf_le' h

/-- `ψ` is monotone. -/
theorem psi_mono : Monotone psi := by
  intro a b hab
  apply psi_le_of_not_gen
  intro hg
  have := Gen.mono (gens_mono hab) hg
  exact not_gen_psi b this

/-! ## The main computations -/

/-- **The proof-theoretic ordinal of `PA` is the first value of the collapsing function.** -/
theorem psi_zero : psi 0 = eps0 := by
  rw [psi_eq, gens_zero]
  apply le_antisymm
  · -- psi 0 ≤ eps0: show eps0 is in the set {b | ¬ Gen {0, Om} b}
    apply csInf_le
    · -- {b | ¬Gen {0, Om} b} is bounded below (by 0)
      use 0
      intro b _
      exact zero_le b
    · -- eps0 is in the set: ¬Gen {0, Om} eps0
      show ¬Gen {0, Om} eps0
      by_contra h
      rcases gen_base_dichotomy h with h' | h'
      · exact lt_irrefl _ h'
      · exact not_le.mpr eps0_lt_Om h'
  · -- eps0 ≤ psi 0: show eps0 is a lower bound
    apply le_csInf
    · -- {b | ¬Gen {0, Om} b} is nonempty
      obtain ⟨m, hm₁, hm₂⟩ := exists_fp_above Om
      use m
      simp only [Set.mem_setOf_eq]
      intro hGen
      have hS : ∀ x ∈ ({0, Om} : Set Ordinal), x < m := by
        intro x hx
        rcases hx with rfl | rfl
        · exact lt_of_le_of_lt (zero_le Om) hm₁
        · exact hm₁
      exact lt_irrefl _ (Gen.lt_of_forall_lt hm₂ hS hGen)
    · -- eps0 is a lower bound: ∀ b in set, eps0 ≤ b
      intro b hb
      by_contra h
      push_neg at h
      have := gen_of_lt_eps0 (zero_mem_gens 0) h
      simp only [gens_zero] at this
      exact hb this

/-- **The collapse of any nonzero ordinal is above `ε₀`.** -/
theorem eps0_lt_psi_of_pos {a : Ordinal.{0}} (h : 0 < a) : eps0 < psi a := by
  have h1 : psi 0 ≤ psi a := psi_mono h.le
  rw [psi_zero] at h1
  by_contra hle
  push_neg at hle
  have heq : psi a = eps0 := le_antisymm hle h1
  have hgen : Gen (gens a) (psi 0) := by
    apply Gen.base
    exact psi_mem_gens h
  rw [psi_zero] at hgen
  rw [← heq] at hgen
  exact not_gen_psi a hgen

/-- **`ε₀ < ψ(Ω ^ ω)`**: the proof-theoretic ordinal of `PA` is strictly below the
collapse of `Ω ^ ω`. -/
theorem eps0_lt_psi_Om_opow_omega : eps0 < psi (Om ^ ω) := by
  apply eps0_lt_psi_of_pos
  have hOm1 : 1 < Om := lt_of_lt_of_le one_lt_omega0 (le_of_lt omega0_lt_omega_one)
  have hOm : 0 < Om := lt_trans one_pos hOm1
  calc 0 < 1 := one_pos
    _ ≤ Om := le_of_lt hOm1
    _ = Om ^ 1 := (opow_one Om).symm
    _ ≤ Om ^ ω := opow_le_opow_right hOm (le_of_lt one_lt_omega0)

/-- `Ω = ω₁` is itself an epsilon number. -/
theorem opow_Om : ω ^ Om = Om := by
  rw [Om]
  refine op_eq_self_of_principal ?_ ?_ ?_ ?_
  · exact omega0_lt_omega_one
  · exact isNormal_opow one_lt_omega0
  · exact principal_opow_omega 1
  · exact Cardinal.isSuccLimit_omega 1

/-- `ψ(ε_{Ω+1})`, the value at which the genuine (restricted-hull) Madore collapsing
function takes the Bachmann–Howard ordinal, the proof-theoretic ordinal of `KP`.

Caveat: the hull `Gen (gens a)` used here is *unrestricted* (every `psi c` with `c < a`
is a generator, with no condition `c ∈ Gen (gens a)`). As proved in
`Bridges.OrdinalAnalysisBridgeExtras` (`psi_strictMono`, `Om_lt_bachmannHoward`), this
makes `psi` strictly increasing, so `bachmannHoward` here is a strict upper bound for,
rather than a copy of, the Bachmann–Howard ordinal. All statements below use only the
chain `ε₀ = psi 0 < psi (Ω^ω) ≤ bachmannHoward`, which is unaffected. -/
def bachmannHoward : Ordinal.{0} := psi (nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1))

/-- `Ω ^ ω` is a double `ω`-exponential: `Ω ^ ω = ω ^ (ω ^ (Ω + 1))`. -/
theorem Om_opow_omega_eq : Om ^ ω = ω ^ (ω ^ (Om + 1)) := by
  have h1 : ω ^ (Om + 1) = Om * ω := by rw [Ordinal.add_one_eq_succ, opow_succ, opow_Om]
  rw [h1]
  -- Need: Om ^ ω = ω ^ (Om * ω)
  -- Using the fact that ω ^ Om = Om
  conv_lhs => rw [← opow_Om]
  rw [opow_mul]

theorem Om_opow_omega_le_epsOmSucc : Om ^ ω ≤ nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) := by
  rw [Om_opow_omega_eq]
  -- ω ^ ω ^ (Om + 1) = f(f(Om + 1)) where f = ω^x
  -- We need that iterates of f are bounded by nfp f a
  have h1 : Om + 1 ≤ ω ^ (Om + 1) := by
    have h2 : Om + 1 = succ Om := by rfl
    rw [h2, opow_succ, opow_Om]
    have h3 : Om * (2 : Ordinal) = Om + Om := by
      have : (2 : Ordinal) = 1 + 1 := by norm_num
      rw [this, mul_add_one, mul_one]
    have hOm_pos : 0 < Om := lt_of_lt_of_le Ordinal.omega0_pos (le_of_lt omega0_lt_omega_one)
    have hOm_one : (1 : Ordinal) ≤ Om := by
      have h1 : (1 : Ordinal) ≤ ω := le_of_lt one_lt_omega0
      exact le_trans h1 (le_of_lt omega0_lt_omega_one)
    calc succ Om = Om + 1 := rfl
      _ ≤ Om + Om := add_le_add_right hOm_one Om
      _ = Om * 2 := h3.symm
      _ ≤ Om * ω := mul_le_mul_right (a := Om) (by
        exact_mod_cast add_one_le_of_lt one_lt_omega0)
  -- Need: ω ^ ω ^ (Om + 1) ≤ nfp (fun x => ω^x) (Om + 1)
  -- This is f(f(Om+1)) where f = ω^x
  -- Since nfp is a fixed point, f(nfp) = nfp
  -- So f(f(a)) ≤ f(nfp) = nfp when a ≤ nfp
  have hle : Om + 1 ≤ nfp (fun x : Ordinal => ω ^ x) (Om + 1) := le_nfp _ _
  have hfp : (fun x : Ordinal => ω ^ x) (nfp (fun x : Ordinal => ω ^ x) (Om + 1)) = nfp (fun x : Ordinal => ω ^ x) (Om + 1) := nfp_fp isNormal_omega0_opow _
  -- First show ω ^ (Om + 1) ≤ nfp using monotonicity
  have h2 : ω ^ (Om + 1) ≤ nfp (fun x : Ordinal => ω ^ x) (Om + 1) := by
    have := isNormal_omega0_opow.monotone hle
    simp only [hfp] at this
    exact this
  calc ω ^ ω ^ (Om + 1) = ω ^ (ω ^ (Om + 1)) := rfl
    _ ≤ ω ^ (nfp (fun x : Ordinal => ω ^ x) (Om + 1)) := opow_le_opow_right omega0_pos h2
    _ = nfp (fun x : Ordinal => ω ^ x) (Om + 1) := hfp

/-- `ψ(Ω ^ ω)` lies below the Bachmann–Howard ordinal. -/
theorem psi_Om_opow_omega_le_bachmannHoward : psi (Om ^ ω) ≤ bachmannHoward :=
  psi_mono Om_opow_omega_le_epsOmSucc

/-- **The proof-theoretic gap between `PA` and `KP`.** -/
theorem eps0_lt_bachmannHoward : eps0 < bachmannHoward :=
  lt_of_lt_of_le eps0_lt_psi_Om_opow_omega psi_Om_opow_omega_le_bachmannHoward

end

end Bridges.OrdinalCollapsing




namespace Bridges.OrdinalAnalysis

open Ordinal Set Bridges.OrdinalCollapsing

/-! ## Terms -/

/-- Ordinal notation terms: `0`, `Ω`, addition, base-`ω` exponentiation and the
collapsing function `ψ`. -/
inductive OTerm : Type
  | zero : OTerm
  | Om : OTerm
  | add : OTerm → OTerm → OTerm
  | opow : OTerm → OTerm
  | psi : OTerm → OTerm
  deriving DecidableEq, Repr

namespace OTerm

/-- The interpretation of a term as an ordinal. -/
noncomputable def val : OTerm → Ordinal.{0}
  | zero => 0
  | Om => Bridges.OrdinalCollapsing.Om
  | add a b => a.val + b.val
  | opow a => ω ^ a.val
  | psi a => Bridges.OrdinalCollapsing.psi a.val

@[simp] theorem val_zero : val zero = 0 := rfl
@[simp] theorem val_Om : val Om = Bridges.OrdinalCollapsing.Om := rfl
@[simp] theorem val_add (a b : OTerm) : val (add a b) = a.val + b.val := rfl
@[simp] theorem val_opow (a : OTerm) : val (opow a) = ω ^ a.val := rfl
@[simp] theorem val_psi (a : OTerm) : val (psi a) = Bridges.OrdinalCollapsing.psi a.val := rfl

/-- The weight of a term, used to prove termination of the rewriting system. -/
def weight : OTerm → ℕ
  | zero => 1
  | Om => 1
  | add a b => 2 * a.weight + b.weight + 1
  | opow a => a.weight + 1
  | psi a => a.weight + 1

theorem weight_pos (t : OTerm) : 0 < t.weight := by
  induction t <;> simp [weight]

end OTerm

/-! ## The rewriting system -/

/-- One step of the rewriting system: the unit laws and associativity for `+`,
closed under arbitrary term contexts. -/
inductive Step : OTerm → OTerm → Prop
  | zero_add (t : OTerm) : Step (.add .zero t) t
  | add_zero (t : OTerm) : Step (.add t .zero) t
  | assoc (a b c : OTerm) : Step (.add (.add a b) c) (.add a (.add b c))
  | addL {a a' : OTerm} (b : OTerm) : Step a a' → Step (.add a b) (.add a' b)
  | addR (a : OTerm) {b b' : OTerm} : Step b b' → Step (.add a b) (.add a b')
  | opowC {a a' : OTerm} : Step a a' → Step (.opow a) (.opow a')
  | psiC {a a' : OTerm} : Step a a' → Step (.psi a) (.psi a')

/-- **Soundness of the rewriting system**: rewriting preserves the denoted ordinal. -/
theorem Step.val_eq {t u : OTerm} (h : Step t u) : t.val = u.val := by
  induction h with
  | zero_add t => simp [OTerm.val_add]
  | add_zero t => simp [OTerm.val_add]
  | assoc a b c => simp [OTerm.val_add, add_assoc]
  | addL b _ ih => simp [OTerm.val_add, ih]
  | addR a _ ih => simp [OTerm.val_add, ih]
  | opowC _ ih => simp [OTerm.val_opow, ih]
  | psiC _ ih => simp [OTerm.val_psi, ih]

/-- **Termination**: every rewrite step strictly decreases the weight. -/
theorem Step.weight_lt {t u : OTerm} (h : Step t u) : u.weight < t.weight := by
  cases h with
  | zero_add t => simp [OTerm.weight]
  | add_zero t => simp [OTerm.weight]; omega
  | assoc a b c => simp [OTerm.weight]; omega
  | addL b h' =>
    have ih := Step.weight_lt h'
    simp [OTerm.weight]; omega
  | addR a h' =>
    have ih := Step.weight_lt h'
    simp [OTerm.weight]; omega
  | opowC h' =>
    have ih := Step.weight_lt h'
    simp [OTerm.weight]; omega
  | psiC h' =>
    have ih := Step.weight_lt h'
    simp [OTerm.weight]; omega

/-- **Strong normalisation**: the rewriting system is well founded. -/
theorem step_wf : WellFounded (fun u t : OTerm => Step t u) := by
  let f : OTerm → ℕ := fun t => t.weight
  let g : OTerm × OTerm → ℕ × ℕ := fun ⟨x, y⟩ => (y.weight, x.weight)
  have hAcc : ∀ n, ∀ t : OTerm, t.weight = n → Acc (fun u t => Step t u) t := by
    intro n
    induction n using Nat.strong_induction_on with
    | _ n ih =>
      intro t ht
      exact Acc.intro t (fun u hu => ih u.weight (by rw [← ht]; exact Step.weight_lt hu) u rfl)
  exact ⟨fun t => hAcc t.weight t rfl⟩

/-- Rewriting to normal form preserves the denoted ordinal. -/
theorem RTStep.val_eq {t u : OTerm} (h : Relation.ReflTransGen Step t u) : t.val = u.val := by
  induction h with
  | refl => rfl
  | tail _ _ ih => rw [ih]; exact Step.val_eq ‹_›

/-- A term is in normal form when no rewrite rule applies. -/
def Normal (t : OTerm) : Prop := ∀ u, ¬ Step t u

/-- **Every term reduces to a normal form.** -/
theorem exists_normal (t : OTerm) : ∃ u, Relation.ReflTransGen Step t u ∧ Normal u := by
  induction t using step_wf.induction with
  | _ s ih =>
    by_cases hnormal : Normal s
    · exact ⟨s, Relation.ReflTransGen.refl, hnormal⟩
    · rw [Normal] at hnormal
      rw [not_forall] at hnormal
      obtain ⟨u, hu⟩ := hnormal
      simp only [not_not] at hu
      obtain ⟨v, hvT, hvNormal⟩ := ih u hu
      exact ⟨v, (Relation.ReflTransGen.single hu).trans hvT, hvNormal⟩

/-- Normal forms of a term all denote the same ordinal as the term itself: the
rewriting system computes a semantically unique normal form. -/
theorem normal_val_unique {t u v : OTerm} (hu : Relation.ReflTransGen Step t u)
    (hv : Relation.ReflTransGen Step t v) : u.val = v.val := by
  rw [← RTStep.val_eq hu, RTStep.val_eq hv]

/-! ## Terms for `ε₀` and `Ω ^ ω` -/

/-- The term `ψ(0)`, which denotes `ε₀`. -/
def eps0Term : OTerm := .psi .zero

/-- A term denoting `Ω ^ ω`, namely `ω ^ (ω ^ (Ω + 1))`. -/
def OmOmegaTerm : OTerm := .opow (.opow (.add .Om (.opow .zero)))

@[simp] theorem eps0Term_val : eps0Term.val = eps0 := by
  simp [eps0Term, OTerm.val, psi_zero]

theorem OmOmegaTerm_val : OmOmegaTerm.val = Bridges.OrdinalCollapsing.Om ^ ω := by
  simp [OmOmegaTerm, OTerm.val]
  rw [opow_Om]
  rw [opow_mul]
  rw [opow_Om]

/-- **`ε₀ < ψ(Ω ^ ω)`, stated inside the term system.** -/
theorem eps0Term_val_lt_psi_OmOmegaTerm : eps0Term.val < (OTerm.psi OmOmegaTerm).val := by
  simp [eps0Term_val, OTerm.val_psi, OmOmegaTerm_val, eps0_lt_psi_Om_opow_omega]

/-! ## The bridge: embedding the ordinal notations of `PA` -/

/-- `repeatAdd t n s` is the term `t + (t + ⋯ + (t + s))` with `n` copies of `t`. -/
def repeatAdd (t : OTerm) : ℕ → OTerm → OTerm
  | 0, s => s
  | (n + 1), s => .add t (repeatAdd t n s)

theorem val_repeatAdd (t : OTerm) (n : ℕ) (s : OTerm) :
    (repeatAdd t n s).val = t.val * (n : Ordinal) + s.val := by
  induction n with
  | zero => simp [repeatAdd]
  | succ n ih =>
    simp [repeatAdd, ih]
    rw [← add_assoc]
    have h : t.val + t.val * (n : Ordinal) = t.val * (Order.succ (n : Ordinal)) := by
      have : Order.succ (n : Ordinal) = (n : Ordinal) + 1 := rfl
      rw [this]
      calc t.val + t.val * (n : Ordinal)
          = t.val * 1 + t.val * (n : Ordinal) := by simp [mul_one]
        _ = t.val * (1 + (n : Ordinal)) := by rw [mul_add]
        _ = t.val * ((n : Ordinal) + 1) := by
            congr 1
            simp
    rw [h]

/-- The explicit translation of a Cantor normal form (a `PA` ordinal notation) into a
term of the collapsing-function system. -/
def ofONote : ONote → OTerm
  | ONote.zero => .zero
  | ONote.oadd e n a => repeatAdd (.opow (ofONote e)) (n : ℕ) (ofONote a)

/-- The translation is value preserving. -/
theorem val_ofONote (o : ONote) : (ofONote o).val = o.repr := by
  induction o with
  | zero => simp [ofONote]
  | oadd e n a ih_e ih_a =>
    simp [ofONote, val_repeatAdd, ih_e, ih_a]

/-- **The translation is order preserving** (and reflects the order). -/
theorem ofONote_val_lt_iff (o₁ o₂ : ONote) :
    (ofONote o₁).val < (ofONote o₂).val ↔ o₁ < o₂ := by
  rw [val_ofONote, val_ofONote]
  rfl

/-- The translation, viewed as a map on the linearly ordered type `NONote` of
Cantor normal forms, is strictly monotone. -/
theorem strictMono_ofONote : StrictMono (fun o : NONote => (ofONote o.1).val) := by
  intro a b hab
  exact (ofONote_val_lt_iff a.1 b.1).mpr hab

/-- Every `PA` notation denotes an ordinal below `ε₀`. -/
theorem repr_lt_eps0 (o : ONote) (h : ONote.NF o) : o.repr < eps0 := by
  induction o with
  | zero => simp [eps0_pos]
  | oadd e n a ih_e ih_a =>
    obtain ⟨ha⟩ := h
    cases ha with
    | intro he hf =>
      cases hf with
      | oadd' =>
        have hrepr : (e.oadd n a).repr = ω ^ e.repr * n + a.repr := by
          simp [ONote.repr]
        rw [hrepr]
        rename_i ebEmb eb haeb haer
        have he_nf : e.NF := ⟨ebEmb, eb⟩
        have ha_nf : a.NF := ⟨e.repr, haeb⟩
        have he_bound : e.repr < eps0 := ih_e he_nf
        have ha_bound : a.repr < eps0 := ih_a ha_nf
        have hopow : ω ^ e.repr < eps0 := opow_lt_eps0 he_bound
        -- ω^e.repr * n < eps0 by principal_add_eps0
        have hmul : ω ^ e.repr * (n : Ordinal) < eps0 := by
          have aux : ∀ m : ℕ, ω ^ e.repr * m < eps0 := by
            intro m
            induction m with
            | zero => simp [eps0_pos]
            | succ k ihk =>
              simp only [Nat.cast_add, Nat.cast_one, mul_add, mul_one]
              exact principal_add_eps0 ihk hopow
          exact aux n
        -- sum < eps0
        exact principal_add_eps0 hmul ha_bound

/-- **The bridge theorem**: the image of the `PA` notation system under the explicit
order-preserving translation lies strictly below `ψ(Ω ^ ω)`. -/
theorem ofONote_val_lt_psi_OmOmegaTerm (o : ONote) (h : ONote.NF o) :
    (ofONote o).val < (OTerm.psi OmOmegaTerm).val := by
  rw [val_ofONote]
  exact lt_trans (repr_lt_eps0 o h) (by rw [← eps0Term_val]; exact eps0Term_val_lt_psi_OmOmegaTerm)

/-- The image of the `PA` notation system lies strictly below the Bachmann–Howard
ordinal, the proof-theoretic ordinal of `KP`. -/
theorem ofONote_val_lt_bachmannHoward (o : ONote) (h : ONote.NF o) :
    (ofONote o).val < bachmannHoward := by
  calc (ofONote o).val < (OTerm.psi OmOmegaTerm).val := ofONote_val_lt_psi_OmOmegaTerm o h
    _ = psi OmOmegaTerm.val := OTerm.val_psi OmOmegaTerm
    _ = psi (Om ^ ω) := by rw [OmOmegaTerm_val]
    _ ≤ bachmannHoward := psi_Om_opow_omega_le_bachmannHoward

end Bridges.OrdinalAnalysis