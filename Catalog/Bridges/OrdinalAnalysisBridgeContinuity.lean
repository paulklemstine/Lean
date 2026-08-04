/-
# Ordinal analysis bridge, part III: the shape of `psi` (continuity and its failure)

This file continues `Catalog/Bridges/OrdinalAnalysisBridge.lean` and
`Catalog/Bridges/OrdinalAnalysisBridgeExtras.lean`. It settles the last conjecture
(`C5`) left open there, and does so by determining the local behaviour of the
collapsing function `psi` at limit ordinals.

## Part 1: every value of `psi` is an epsilon number

* `log_lt_self_of_ne_fp` : if `b ≠ 0` is not an epsilon number then `log ω b < b`;
* `opow_psi : ω ^ psi a = psi a` — if `psi a` had a nontrivial Cantor normal form, its
  pieces would be below `psi a`, hence in the hull, hence `psi a` itself would be in the
  hull, contradicting `not_gen_psi`.

## Part 2: above `Ω` the hull is an initial segment

* `gen_iff_lt_psi : Om < psi a → (Gen (gens a) x ↔ x < psi a)`, i.e. once the collapse
  has passed `Ω` the stage-`a` hull is exactly `Iio (psi a)`.

## Part 3: continuity at limits above `Ω`, and the resolution of C5

* `psi_of_limit` : for a limit `a > Ω`, `psi a = ⨆ c : Iio a, psi c`;
* `psi_Om_opow_omega_eq_iSup` : **`psi (Ω ^ ω) = ⨆ n : ℕ, psi (Ω ^ n)`** — conjecture C5.

## Part 4: `Ω` is a genuine point of discontinuity

* `psi_lt_Om` : `psi c < Om` for every countable `c` (so `psi` maps the countable
  ordinals into the countable ordinals);
* `iSup_psi_Iio_Om : (⨆ c : Iio Om, psi c) = Om`, while `Om < psi Om`, giving
  `psi_discontinuous_at_Om`: continuity genuinely fails at `Ω`, so the hypothesis
  `Om < a` in `psi_of_limit` cannot be dropped.

## Part 5: explicit values above `Ω`

* `psi_Om_eq : psi Om = ε_{Ω+1}`, `psi_succ_of_Om_le` : `psi (a+1)` is the next epsilon
  number after `psi a` for `a ≥ Ω`; with Part 3 this determines `psi` above `Ω` as the
  enumeration of the epsilon numbers `> Ω`;
* `bachmannHoward_eq_psi_psi_Om : bachmannHoward = psi (psi Ω)`.

## Part 6: closed form

* `psi_add_eq_epsilon : psi (Ω + a) = ε_{Ω+1+a}` (Mathlib's `Ordinal.epsilon`), with the
  readings `psi_Om_opow_omega_eq_epsilon : psi (Ω ^ ω) = ε_{Ω ^ ω}` and
  `bachmannHoward_eq_epsilon : bachmannHoward = ε_{ε_{Ω+1}}`;
* `psi_eq_epsilon_of_lt_Om : psi c = ε_c` for countable `c`, and `psi_of_Om_le`, which
  together give the value of `psi` at every argument, and `range_psi`: the range of `psi`
  is exactly the epsilon numbers other than `Ω` itself.
-/
import Bridges.OrdinalAnalysisBridgeExtras

namespace Bridges.OrdinalCollapsing

open Ordinal Set Order

noncomputable section

/-! ## Part 1: every value of `psi` is an epsilon number -/

/-- If `b ≠ 0` is not an epsilon number, its base-`ω` logarithm is strictly smaller. -/
theorem log_lt_self_of_ne_fp {b : Ordinal.{0}} (hb : b ≠ 0) (h : ω ^ b ≠ b) :
    Ordinal.log ω b < b := by
  by_contra hcontra
  push_neg at hcontra
  have hlog_le : ω ^ Ordinal.log ω b ≤ b := Ordinal.opow_log_le_self ω hb
  have hwb : ω ^ b ≤ b := le_trans (isNormal_omega0_opow.monotone hcontra) hlog_le
  have hble : b ≤ ω ^ b := isNormal_omega0_opow.strictMono.id_le _
  exact h (le_antisymm hwb hble)

/-- `ε₀ ≤ psi a` for every `a`. -/
theorem eps0_le_psi (a : Ordinal.{0}) : eps0 ≤ psi a := by
  have h : psi 0 ≤ psi a := psi_mono (by simp)
  rwa [psi_zero] at h

theorem psi_ne_zero (a : Ordinal.{0}) : psi a ≠ 0 :=
  ne_of_gt (lt_of_lt_of_le eps0_pos (eps0_le_psi a))

/-- **Every value of the collapsing function is an epsilon number.** If `psi a` had a
nontrivial Cantor normal form `ω ^ (log ω (psi a)) * n + r`, then both `log ω (psi a)`
and `r` would be below `psi a`, hence inside the stage-`a` hull, and therefore `psi a`
itself would be in the hull — contradicting `not_gen_psi`. -/
theorem opow_psi (a : Ordinal.{0}) : ω ^ psi a = psi a := by
  by_contra h
  have hb : psi a ≠ 0 := psi_ne_zero a
  have hlog : Ordinal.log ω (psi a) < psi a := log_lt_self_of_ne_fp hb h
  obtain ⟨n, r, hr, heq⟩ := cnf_step hb
  have he : Gen (gens a) (Ordinal.log ω (psi a)) := gen_of_lt_psi hlog
  have hrg : Gen (gens a) r := gen_of_lt_psi hr
  exact not_gen_psi a (heq ▸ gen_cnf_step (zero_mem_gens a) he hrg n)

/-- `Ω` is in every stage of the hull, so it is never a value of `psi`. -/
theorem psi_ne_Om (a : Ordinal.{0}) : psi a ≠ Om := by
  intro h
  exact not_gen_psi a (h ▸ Gen.base (Om_mem_gens a))

/-- From `Ω` on, the collapse is strictly above `Ω`. -/
theorem Om_lt_psi_of_le {a : Ordinal.{0}} (h : Om ≤ a) : Om < psi a :=
  lt_of_le_of_ne (h.trans (self_le_psi a)) (Ne.symm (psi_ne_Om a))

/-! ## Part 2: above `Ω` the hull is an initial segment -/

/-- Once `psi a` has passed `Ω`, all stage-`a` generators lie below `psi a`. -/
theorem gens_lt_psi {a : Ordinal.{0}} (hOm : Om < psi a) : ∀ x ∈ gens a, x < psi a := by
  rintro x hx
  rcases hx with hx | ⟨c, rfl⟩
  · rcases hx with rfl | rfl
    · exact lt_of_lt_of_le eps0_pos (eps0_le_psi a)
    · exact hOm
  · exact psi_strictMono c.2

/-- Once `psi a` has passed `Ω`, the stage-`a` hull is contained in `Iio (psi a)`. -/
theorem gen_lt_psi {a x : Ordinal.{0}} (hOm : Om < psi a) (hx : Gen (gens a) x) : x < psi a :=
  Gen.lt_of_forall_lt (opow_psi a) (gens_lt_psi hOm) hx

/-- Above `Ω` the stage-`a` hull is *exactly* the initial segment `Iio (psi a)`. -/
theorem gen_iff_lt_psi {a x : Ordinal.{0}} (hOm : Om < psi a) :
    Gen (gens a) x ↔ x < psi a :=
  ⟨gen_lt_psi hOm, gen_of_lt_psi⟩

/-! ## Part 3: continuity at limits above `Ω` -/

/-- The supremum of the earlier collapses is at most the current one. -/
theorem iSup_psi_Iio_le (a : Ordinal.{0}) : (⨆ c : Set.Iio a, psi c.1) ≤ psi a :=
  Ordinal.iSup_le fun c => psi_mono c.2.le

/-- A supremum of epsilon numbers over a nonempty index set is an epsilon number. -/
theorem opow_iSup_psi_Iio {a : Ordinal.{0}} (ha : 0 < a) :
    ω ^ (⨆ c : Set.Iio a, psi c.1) = ⨆ c : Set.Iio a, psi c.1 := by
  haveI : Nonempty (Set.Iio a) := ⟨⟨0, ha⟩⟩
  have hbdd : BddAbove (Set.range (fun c : Set.Iio a => psi c.1)) :=
    Ordinal.bddAbove_of_small _
  have h := Order.IsNormal.map_iSup isNormal_omega0_opow
    (g := fun c : Set.Iio a => psi c.1) hbdd
  simp only at h
  rw [h]
  exact iSup_congr fun c => opow_psi c.1

/-- At a stage above `Ω`, the supremum of the earlier collapses is above `Ω`. -/
theorem Om_lt_iSup_psi_Iio {a : Ordinal.{0}} (hOm : Om < a) :
    Om < ⨆ c : Set.Iio a, psi c.1 :=
  lt_of_lt_of_le (Om_lt_psi_of_le (le_refl Om))
    (Ordinal.le_iSup (fun c : Set.Iio a => psi c.1) ⟨Om, hOm⟩)

/-- **Continuity of `psi` at limit ordinals above `Ω`.** The limit hypothesis is spelled
out as `∀ c < a, c + 1 < a`.

The supremum `b = ⨆ c < a, psi c` is an epsilon number (each `psi c` is one, by
`opow_psi`) which is strictly above every stage-`a` generator, so by
`Gen.lt_of_forall_lt` nothing at stage `a` generates `b`; hence `psi a ≤ b`. -/
theorem psi_of_limit {a : Ordinal.{0}} (hlim : ∀ c < a, c + 1 < a) (hOm : Om < a) :
    psi a = ⨆ c : Set.Iio a, psi c.1 := by
  have ha : 0 < a := lt_of_le_of_lt (bot_le : (0 : Ordinal.{0}) ≤ Om) hOm
  refine le_antisymm ?_ (iSup_psi_Iio_le a)
  apply psi_le_of_not_gen
  intro hgen
  have hOmb : Om < ⨆ c : Set.Iio a, psi c.1 := Om_lt_iSup_psi_Iio hOm
  have hgens : ∀ x ∈ gens a, x < ⨆ c : Set.Iio a, psi c.1 := by
    rintro x hx
    rcases hx with hx | ⟨c, rfl⟩
    · rcases hx with rfl | rfl
      · exact lt_of_le_of_lt (bot_le : (0 : Ordinal.{0}) ≤ Om) hOmb
      · exact hOmb
    · exact lt_of_lt_of_le (psi_strictMono (lt_add_one c.1))
        (Ordinal.le_iSup (fun d : Set.Iio a => psi d.1) ⟨c.1 + 1, hlim c.1 c.2⟩)
  exact absurd (Gen.lt_of_forall_lt (opow_iSup_psi_Iio ha) hgens hgen) (lt_irrefl _)

/-! ### Conjecture C5: continuity at `Ω ^ ω` -/

theorem one_lt_Om : 1 < Om := lt_of_lt_of_le one_lt_omega0 omega0_lt_omega_one.le

/-- `Ω ^ ω` is the supremum of the finite powers of `Ω`. -/
theorem Om_opow_omega_eq_iSup :
    Om ^ (ω : Ordinal.{0}) = ⨆ n : ℕ, Om ^ (n : Ordinal.{0}) := by
  have h := Order.IsNormal.map_iSup (Ordinal.isNormal_opow one_lt_Om)
    (g := fun n : ℕ => (n : Ordinal.{0})) (Ordinal.bddAbove_of_small _)
  simp only at h
  rw [← h, Ordinal.iSup_natCast]

/-- Every ordinal below `Ω ^ ω` is below some `Ω ^ n`. -/
theorem exists_nat_lt_Om_opow (c : Ordinal.{0}) (h : c < Om ^ (ω : Ordinal.{0})) :
    ∃ n : ℕ, c < Om ^ (n : Ordinal.{0}) := by
  by_contra hc
  push_neg at hc
  rw [Om_opow_omega_eq_iSup] at h
  exact absurd (Ordinal.iSup_le hc) (not_le.2 h)

theorem Om_lt_Om_opow_omega : Om < Om ^ (ω : Ordinal.{0}) := by
  calc Om = Om ^ (1 : Ordinal.{0}) := (opow_one Om).symm
    _ < Om ^ (ω : Ordinal.{0}) := (opow_lt_opow_iff_right one_lt_Om).2 one_lt_omega0

/-- `Ω ^ ω` is a limit ordinal. -/
theorem limit_Om_opow_omega (c : Ordinal.{0}) (h : c < Om ^ (ω : Ordinal.{0})) :
    c + 1 < Om ^ (ω : Ordinal.{0}) := by
  obtain ⟨n, hn⟩ := exists_nat_lt_Om_opow c h
  have h1 : c + 1 ≤ Om ^ (n : Ordinal.{0}) := Order.add_one_le_of_lt hn
  have h2 : Om ^ (n : Ordinal.{0}) < Om ^ (ω : Ordinal.{0}) :=
    (opow_lt_opow_iff_right one_lt_Om).2 (nat_lt_omega0 n)
  exact lt_of_le_of_lt h1 h2

/-- **Conjecture C5, proved: `psi` is continuous at `Ω ^ ω`**, i.e. the collapse of
`Ω ^ ω` is the supremum of the collapses of the finite powers of `Ω`. Together with
`psi_Om_pow_nat_lt` this shows the approximations `psi (Ω ^ n)` climb strictly up to
`psi (Ω ^ ω)`. -/
theorem psi_Om_opow_omega_eq_iSup :
    psi (Om ^ (ω : Ordinal.{0})) = ⨆ n : ℕ, psi (Om ^ (n : Ordinal.{0})) := by
  rw [psi_of_limit limit_Om_opow_omega Om_lt_Om_opow_omega]
  apply le_antisymm
  · refine Ordinal.iSup_le fun c => ?_
    obtain ⟨n, hn⟩ := exists_nat_lt_Om_opow c.1 c.2
    exact le_trans (psi_mono hn.le) (Ordinal.le_iSup _ n)
  · refine Ordinal.iSup_le fun n => ?_
    exact Ordinal.le_iSup (fun c : Set.Iio (Om ^ (ω : Ordinal.{0})) => psi c.1)
      ⟨Om ^ (n : Ordinal.{0}), (opow_lt_opow_iff_right one_lt_Om).2 (nat_lt_omega0 n)⟩

/-! ## Part 4: `Ω` is a point of discontinuity -/

/-- `Ω = ω₁` is closed under `x ↦ ω ^ x`. -/
theorem opow_lt_Om {x : Ordinal.{0}} (h : x < Om) : ω ^ x < Om := by
  rw [Om_eq_ord_aleph_one] at h ⊢
  have hcard : x.card ≤ Cardinal.aleph0 := by
    have hlt : x.card < Cardinal.aleph 1 := Cardinal.lt_ord.mp h
    rw [← Cardinal.succ_aleph0] at hlt
    exact Order.lt_succ_iff.mp hlt
  have h2 : (ω ^ x).card ≤ Cardinal.aleph0 := by
    have := Ordinal.card_opow_le ω x
    rw [Ordinal.card_omega0] at this
    simpa [max_eq_left hcard] using this
  exact Cardinal.lt_ord.mpr (lt_of_le_of_lt h2 Cardinal.aleph0_lt_aleph_one)

/-- A hull whose generators are, apart from `Ω` itself, below an epsilon number `m`
consists of ordinals below `m` together with ordinals `≥ Ω`. This generalises
`gen_base_dichotomy`. -/
theorem gen_dichotomy {S : Set Ordinal.{0}} {m : Ordinal.{0}} (hm : ω ^ m = m)
    (hS : ∀ x ∈ S, x < m ∨ Om ≤ x) {x : Ordinal.{0}} (hx : Gen S x) : x < m ∨ Om ≤ x := by
  induction hx with
  | base h => exact hS _ h
  | add _ _ ih₁ ih₂ =>
    rcases ih₁ with ha | ha <;> rcases ih₂ with hb | hb
    · left
      rw [← hm] at ha hb ⊢
      exact principal_add_omega0_opow m ha hb
    · right; exact le_trans hb le_add_self
    · right; exact le_trans ha le_self_add
    · right; exact le_trans hb le_add_self
  | opow _ ih =>
    rcases ih with ha | ha
    · left
      calc ω ^ _ < ω ^ m := (opow_lt_opow_iff_right one_lt_omega0).2 ha
        _ = m := hm
    · right
      calc Om ≤ _ := ha
        _ ≤ ω ^ _ := isNormal_omega0_opow.strictMono.id_le _

theorem cof_Om : Om.cof = Cardinal.aleph 1 := by
  rw [Om_eq_ord_aleph_one]
  exact Cardinal.isRegular_aleph_one.cof_eq

theorem Om_isSuccLimit : Order.IsSuccLimit Om := by
  rw [Om_eq_ord_aleph_one]
  exact Cardinal.isSuccLimit_ord (Cardinal.aleph0_le_aleph 1)

/-- Regularity of `Ω = ω₁`: a family of countable ordinals indexed by the predecessors
of a countable ordinal has a countable supremum. -/
theorem iSup_lt_Om_of_lt_Om {c : Ordinal.{0}} (hc : c < Om) (f : Set.Iio c → Ordinal.{0})
    (hf : ∀ d, f d < Om) : (⨆ d, f d) < Om := by
  classical
  set T := Shrink.{0} (Set.Iio c) with hT
  have hEq : (⨆ d : Set.Iio c, f d) = ⨆ t : T, f ((equivShrink (Set.Iio c)).symm t) := by
    refine le_antisymm (Ordinal.iSup_le fun d => ?_) (Ordinal.iSup_le fun t => Ordinal.le_iSup _ _)
    have := Ordinal.le_iSup (fun t : T => f ((equivShrink (Set.Iio c)).symm t))
      (equivShrink (Set.Iio c) d)
    simpa using this
  rw [hEq]
  refine Ordinal.iSup_lt_ord_lift ?_ (fun t => hf _)
  rw [cof_Om]
  have hmk : Cardinal.mk T = c.card := by
    apply Cardinal.lift_injective.{1}
    rw [Cardinal.lift_mk_shrink'', Ordinal.mk_Iio_ordinal]
  have hcc : c.card < Cardinal.aleph 1 := Cardinal.lt_ord.mp (Om_eq_ord_aleph_one ▸ hc)
  simpa [hmk] using hcc

/-- **The collapse of a countable ordinal is countable.** The generators available at a
countable stage `c` are `Ω` together with countably many countable ordinals; the least
epsilon number `M` above their supremum is still countable, and by `gen_dichotomy` it is
not generated, so `psi c ≤ M < Ω`. -/
theorem psi_lt_Om : ∀ {c : Ordinal.{0}}, c < Om → psi c < Om := by
  intro c
  induction c using Ordinal.induction with
  | h c ih =>
    intro hc
    set s : Ordinal.{0} := ⨆ d : Set.Iio c, psi d.1 with hs
    have hs_lt : s < Om := iSup_lt_Om_of_lt_Om hc _ (fun d => ih d.1 d.2 (lt_trans d.2 hc))
    have hs1 : s + 1 < Om := Om_isSuccLimit.succ_lt hs_lt
    set M := nfp (fun x : Ordinal.{0} => ω ^ x) (s + 1) with hM
    have hM_fp : ω ^ M = M := nfp_fp isNormal_omega0_opow _
    have hM_lt : M < Om :=
      Ordinal.nfp_lt_ord (by rw [cof_Om]; exact Cardinal.aleph0_lt_aleph_one)
        (fun i hi => opow_lt_Om hi) hs1
    have hs1M : s + 1 ≤ M := le_nfp _ _
    have hgens : ∀ x ∈ gens c, x < M ∨ Om ≤ x := by
      rintro x hx
      rcases hx with hx | ⟨d, rfl⟩
      · rcases hx with rfl | rfl
        · left; exact lt_of_lt_of_le (by simp) hs1M
        · right; exact le_rfl
      · left
        calc psi d.1 ≤ s := Ordinal.le_iSup _ d
          _ < s + 1 := lt_add_one s
          _ ≤ M := hs1M
    have hnot : ¬ Gen (gens c) M := by
      intro hg
      rcases gen_dichotomy hM_fp hgens hg with h' | h'
      · exact lt_irrefl _ h'
      · exact absurd h' (not_le.2 hM_lt)
    exact lt_of_le_of_lt (psi_le_of_not_gen hnot) hM_lt

/-- The collapses of the countable ordinals are cofinal in `Ω`. -/
theorem iSup_psi_Iio_Om : (⨆ c : Set.Iio Om, psi c.1) = Om := by
  refine le_antisymm (Ordinal.iSup_le fun c => (psi_lt_Om c.2).le) ?_
  by_contra hcon
  push_neg at hcon
  set b : Ordinal.{0} := ⨆ c : Set.Iio Om, psi c.1 with hb
  have hb1 : b + 1 < Om := Om_isSuccLimit.succ_lt hcon
  have h1 : psi (b + 1) ≤ b := Ordinal.le_iSup (fun c : Set.Iio Om => psi c.1) ⟨b + 1, hb1⟩
  have h2 : b + 1 ≤ psi (b + 1) := self_le_psi _
  exact absurd (h2.trans h1) (by simp)

/-- **`psi` is discontinuous at `Ω`**: the supremum of the countable collapses is `Ω`
itself, but `psi Ω` is strictly larger. So the hypothesis `Om < a` in `psi_of_limit`
really is needed: `Ω` is a critical point of the collapsing function. -/
theorem psi_discontinuous_at_Om : (⨆ c : Set.Iio Om, psi c.1) < psi Om := by
  rw [iSup_psi_Iio_Om]
  exact Om_lt_psi_of_le le_rfl

/-! ## Part 5: explicit values — above `Ω`, `psi` enumerates the epsilon numbers

Combining Parts 1, 3 and 4 the function is completely determined from `Ω` on: it starts
at `ε_{Ω+1}` and each successor step moves to the next epsilon number, while at limits it
is continuous. -/

/-- **`psi Ω = ε_{Ω+1}`**, the least epsilon number above `Ω`. Every generator at stage
`Ω` is either `Ω` itself or a countable collapse (`psi_lt_Om`), so the hull stays below
`ε_{Ω+1}`; conversely `psi Ω` is an epsilon number above `Ω` (`opow_psi`,
`Om_lt_psi_of_le`), hence at least `ε_{Ω+1}`. -/
theorem psi_Om_eq : psi Om = nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) := by
  apply le_antisymm
  · apply psi_le_of_not_gen
    intro hg
    have hfp : ω ^ (nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1))
        = nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) := nfp_fp isNormal_omega0_opow _
    have hOmlt : Om < nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) :=
      lt_of_lt_of_le (lt_add_one Om) (le_nfp _ _)
    have hgens : ∀ x ∈ gens Om, x < nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) := by
      rintro x hx
      rcases hx with hx | ⟨c, rfl⟩
      · rcases hx with rfl | rfl
        · exact lt_of_le_of_lt (bot_le : (0 : Ordinal.{0}) ≤ Om) hOmlt
        · exact hOmlt
      · exact lt_trans (psi_lt_Om c.2) hOmlt
    exact absurd (Gen.lt_of_forall_lt hfp hgens hg) (lt_irrefl _)
  · exact nfp_le_fp isNormal_omega0_opow.monotone
      (Order.add_one_le_of_lt (Om_lt_psi_of_le le_rfl)) (opow_psi Om).le

/-- **Successor step above `Ω`**: `psi (a + 1)` is the next epsilon number after
`psi a`. -/
theorem psi_succ_of_Om_le {a : Ordinal.{0}} (h : Om ≤ a) :
    psi (a + 1) = nfp (fun x : Ordinal.{0} => ω ^ x) (psi a + 1) := by
  apply le_antisymm
  · apply psi_le_of_not_gen
    intro hg
    have hfp : ω ^ (nfp (fun x : Ordinal.{0} => ω ^ x) (psi a + 1))
        = nfp (fun x : Ordinal.{0} => ω ^ x) (psi a + 1) := nfp_fp isNormal_omega0_opow _
    have hlt : psi a < nfp (fun x : Ordinal.{0} => ω ^ x) (psi a + 1) :=
      lt_of_lt_of_le (lt_add_one _) (le_nfp _ _)
    have hgens : ∀ x ∈ gens (a + 1), x < nfp (fun x : Ordinal.{0} => ω ^ x) (psi a + 1) := by
      rintro x hx
      rcases hx with hx | ⟨c, rfl⟩
      · rcases hx with rfl | rfl
        · exact lt_of_le_of_lt (bot_le : (0 : Ordinal.{0}) ≤ psi a) hlt
        · exact lt_trans (Om_lt_psi_of_le h) hlt
      · exact lt_of_le_of_lt (psi_mono (Order.lt_succ_iff.mp (by simpa using c.2))) hlt
    exact absurd (Gen.lt_of_forall_lt hfp hgens hg) (lt_irrefl _)
  · exact nfp_le_fp isNormal_omega0_opow.monotone
      (Order.add_one_le_of_lt (psi_strictMono (lt_add_one a))) (opow_psi (a + 1)).le

/-- The constant `bachmannHoward = psi (ε_{Ω+1})` of the first file is `psi (psi Ω)`. -/
theorem bachmannHoward_eq_psi_psi_Om : bachmannHoward = psi (psi Om) := by
  rw [bachmannHoward, psi_Om_eq]

/-! ## Part 6: the closed form `psi (Ω + a) = ε_{Ω+1+a}`

Mathlib's `Ordinal.epsilon` (`ε_ · = deriv (ω ^ ·)`) enumerates the epsilon numbers. Parts
1–5 say precisely that from `Ω` on, `psi` is the enumeration of the epsilon numbers above
`Ω`; here this is stated and proved as a closed formula, and read off at the two ordinals
that matter for the bridge. -/

/-- The `eps0` of the first file is Mathlib's `ε₀`. -/
theorem eps0_eq_epsilon_zero : eps0 = Ordinal.epsilon 0 := by
  rw [eps0, Ordinal.epsilon_zero_eq_nfp]

/-- Epsilon numbers with countable index are countable. -/
theorem epsilon_lt_Om {c : Ordinal.{0}} (h : c < Om) : Ordinal.epsilon c < Om := by
  rw [Ordinal.epsilon_eq_deriv, Om_eq_ord_aleph_one]
  refine Cardinal.deriv_lt_ord Cardinal.isRegular_aleph_one
    (ne_of_gt Cardinal.aleph0_lt_aleph_one) (fun i hi => ?_) (Om_eq_ord_aleph_one ▸ h)
  exact Om_eq_ord_aleph_one ▸ opow_lt_Om (Om_eq_ord_aleph_one ▸ hi)

/-- `Ω = ω₁` is the `Ω`-th epsilon number. -/
theorem epsilon_Om : Ordinal.epsilon Om = Om := by
  apply le_antisymm
  · rw [Ordinal.epsilon_eq_deriv, Ordinal.deriv_limit _ Om_isSuccLimit]
    refine Ordinal.iSup_le fun c => ?_
    have := epsilon_lt_Om c.2
    rw [Ordinal.epsilon_eq_deriv] at this
    exact this.le
  · exact (Ordinal.isNormal_deriv _).strictMono.le_apply.trans_eq
      (Ordinal.epsilon_eq_deriv Om).symm

/-- `psi Ω = ε_{Ω+1}`, now in terms of Mathlib's epsilon function. -/
theorem psi_Om_eq_epsilon : psi Om = Ordinal.epsilon (Om + 1) := by
  rw [psi_Om_eq, ← Order.succ_eq_add_one, Ordinal.epsilon_succ_eq_nfp, epsilon_Om,
    Order.succ_eq_add_one]

/-- Cofinality bookkeeping for the limit step of `psi_add_eq_epsilon`: below `Ω + a` the
collapses reached from `Ω` on are cofinal. -/
theorem iSup_psi_Iio_add {a : Ordinal.{0}} (ha : 0 < a) :
    (⨆ c : Set.Iio (Om + a), psi c.1) = ⨆ b : Set.Iio a, psi (Om + b.1) := by
  apply le_antisymm
  · refine Ordinal.iSup_le fun c => ?_
    rcases lt_or_ge c.1 Om with hc | hc
    · refine le_trans (le_of_lt (psi_lt_Om hc)) ?_
      refine le_trans ?_ (Ordinal.le_iSup (fun b : Set.Iio a => psi (Om + b.1)) ⟨0, ha⟩)
      simpa using (self_le_psi Om)
    · obtain ⟨b, hbe⟩ := exists_add_of_le hc
      have hlt : Om + b < Om + a := hbe ▸ c.2
      have hb : b < a := (add_lt_add_iff_left Om).mp hlt
      rw [hbe]
      exact Ordinal.le_iSup (fun b : Set.Iio a => psi (Om + b.1)) ⟨b, hb⟩
  · refine Ordinal.iSup_le fun b => ?_
    exact Ordinal.le_iSup (fun c : Set.Iio (Om + a) => psi c.1)
      ⟨Om + b.1, (add_lt_add_iff_left Om).mpr b.2⟩

/-- The matching cofinality statement for the epsilon function. -/
theorem epsilon_add_limit {a : Ordinal.{0}} (hlim : Order.IsSuccLimit a) (ha : 0 < a) :
    Ordinal.epsilon (Om + 1 + a) = ⨆ b : Set.Iio a, Ordinal.epsilon (Om + 1 + b.1) := by
  rw [Ordinal.epsilon_eq_deriv, Ordinal.deriv_limit _ (Ordinal.isSuccLimit_add _ hlim)]
  apply le_antisymm
  · refine Ordinal.iSup_le fun d => ?_
    rcases lt_or_ge d.1 (Om + 1) with hd | hd
    · refine le_trans ?_
        (Ordinal.le_iSup (fun b : Set.Iio a => Ordinal.epsilon (Om + 1 + b.1)) ⟨0, ha⟩)
      have : Ordinal.deriv (fun x : Ordinal.{0} => ω ^ x) d.1 ≤
          Ordinal.deriv (fun x : Ordinal.{0} => ω ^ x) (Om + 1) :=
        (Ordinal.isNormal_deriv _).monotone hd.le
      simpa [Ordinal.epsilon_eq_deriv] using this
    · obtain ⟨b, hbe⟩ := exists_add_of_le hd
      have hlt : Om + 1 + b < Om + 1 + a := hbe ▸ d.2
      have hb : b < a := (add_lt_add_iff_left (Om + 1)).mp hlt
      rw [hbe]
      refine le_trans ?_
        (Ordinal.le_iSup (fun b : Set.Iio a => Ordinal.epsilon (Om + 1 + b.1)) ⟨b, hb⟩)
      simp [Ordinal.epsilon_eq_deriv]
  · refine Ordinal.iSup_le fun b => ?_
    refine le_trans ?_ (Ordinal.le_iSup
      (fun d : Set.Iio (Om + 1 + a) => Ordinal.deriv (fun x : Ordinal.{0} => ω ^ x) d.1)
      ⟨Om + 1 + b.1, (add_lt_add_iff_left (Om + 1)).mpr b.2⟩)
    simp [Ordinal.epsilon_eq_deriv]

/-- **Closed form: `psi (Ω + a) = ε_{Ω+1+a}`.** Above `Ω` the collapsing function is
exactly the enumeration of the epsilon numbers greater than `Ω`: it starts at `ε_{Ω+1}`
(`psi_Om_eq_epsilon`), steps to the next epsilon number at successors
(`psi_succ_of_Om_le`) and is continuous at limits (`psi_of_limit`). -/
theorem psi_add_eq_epsilon (a : Ordinal.{0}) : psi (Om + a) = Ordinal.epsilon (Om + 1 + a) := by
  induction a using Ordinal.limitRecOn with
  | zero => simpa using psi_Om_eq_epsilon
  | succ a ih =>
    have hle : Om ≤ Om + a := le_self_add
    rw [Order.succ_eq_add_one, ← add_assoc, psi_succ_of_Om_le hle, ih, ← add_assoc,
      show (Om + 1 + a + 1 : Ordinal.{0}) = Order.succ (Om + 1 + a) from
        (Order.succ_eq_add_one _).symm,
      Ordinal.epsilon_succ_eq_nfp, Order.succ_eq_add_one]
  | limit a hlim ih =>
    have ha0 : a ≠ 0 := by simpa [Ordinal.bot_eq_zero] using hlim.ne_bot
    have ha : 0 < a := lt_of_le_of_ne (bot_le : (0 : Ordinal.{0}) ≤ a) (Ne.symm ha0)
    have hlim' : ∀ c < Om + a, c + 1 < Om + a := by
      intro c hc
      have := (Ordinal.isSuccLimit_add Om hlim).succ_lt hc
      rwa [Order.succ_eq_add_one] at this
    have hOm : Om < Om + a := by
      have := (add_lt_add_iff_left Om).mpr ha
      rwa [add_zero] at this
    rw [psi_of_limit hlim' hOm, iSup_psi_Iio_add ha, epsilon_add_limit hlim ha]
    exact iSup_congr fun b => ih b.1 b.2

/-- An epsilon number absorbs on the left everything below it. -/
theorem add_absorp_fp {x m : Ordinal.{0}} (hm : ω ^ m = m) (h : x < m) : x + m = m := by
  have h1 : x < ω ^ m := by rw [hm]; exact h
  exact Ordinal.add_absorp h1 (le_of_eq hm)

theorem add_Om_opow_omega_absorp {x : Ordinal.{0}} (h : x < Om ^ (ω : Ordinal.{0})) :
    x + Om ^ (ω : Ordinal.{0}) = Om ^ (ω : Ordinal.{0}) := by
  have he := Om_opow_omega_eq
  rw [he] at h ⊢
  exact Ordinal.add_absorp h le_rfl

/-- **Explicit value of the headline collapse: `psi (Ω ^ ω) = ε_{Ω ^ ω}`.** -/
theorem psi_Om_opow_omega_eq_epsilon :
    psi (Om ^ (ω : Ordinal.{0})) = Ordinal.epsilon (Om ^ (ω : Ordinal.{0})) := by
  have h1 : Om + Om ^ (ω : Ordinal.{0}) = Om ^ (ω : Ordinal.{0}) :=
    add_Om_opow_omega_absorp Om_lt_Om_opow_omega
  have h2 : Om + 1 + Om ^ (ω : Ordinal.{0}) = Om ^ (ω : Ordinal.{0}) :=
    add_Om_opow_omega_absorp (limit_Om_opow_omega Om Om_lt_Om_opow_omega)
  have key := psi_add_eq_epsilon (Om ^ (ω : Ordinal.{0}))
  rw [h1, h2] at key
  exact key

theorem Om_add_one_lt_nfp : Om + 1 < nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) := by
  have hpow : ω ^ (Om + 1) = Om * ω := by rw [opow_add, opow_one, opow_Om]
  have h2 : Om + 1 < Om + Om := (add_lt_add_iff_left Om).mpr one_lt_Om
  have h3 : Om + Om = Om * 2 := by
    rw [show (2 : Ordinal) = 1 + 1 from by norm_num, mul_add, mul_one]
  have h4 : Om * 2 ≤ Om * ω := mul_le_mul_right (by exact_mod_cast (nat_lt_omega0 2).le) Om
  have h5 : Om + 1 < ω ^ (Om + 1) := by
    rw [hpow]; exact lt_of_lt_of_le (h3 ▸ h2) h4
  have h6 : ω ^ (Om + 1) ≤ nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) := by
    have := Ordinal.iterate_le_nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) 1
    simpa using this
  exact lt_of_lt_of_le h5 h6

/-- **Explicit value: `bachmannHoward = ε_{ε_{Ω+1}}`.** (Recall from
`OrdinalAnalysisBridgeExtras` that this constant, defined with the *unrestricted* hull,
is a strict upper bound for the genuine Bachmann–Howard ordinal rather than a copy of
it.) -/
theorem bachmannHoward_eq_epsilon :
    bachmannHoward = Ordinal.epsilon (Ordinal.epsilon (Om + 1)) := by
  have hE : Ordinal.epsilon (Om + 1) = nfp (fun x : Ordinal.{0} => ω ^ x) (Om + 1) := by
    rw [← Order.succ_eq_add_one, Ordinal.epsilon_succ_eq_nfp, epsilon_Om, Order.succ_eq_add_one]
  have hfp : ω ^ Ordinal.epsilon (Om + 1) = Ordinal.epsilon (Om + 1) :=
    Ordinal.omega0_opow_epsilon _
  have hOmlt : Om < Ordinal.epsilon (Om + 1) := by
    rw [hE]
    exact lt_of_lt_of_le (lt_add_one Om) (le_nfp _ _)
  have hOm1lt : Om + 1 < Ordinal.epsilon (Om + 1) := by
    rw [hE]; exact Om_add_one_lt_nfp
  have h1 : Om + Ordinal.epsilon (Om + 1) = Ordinal.epsilon (Om + 1) := add_absorp_fp hfp hOmlt
  have h2 : Om + 1 + Ordinal.epsilon (Om + 1) = Ordinal.epsilon (Om + 1) :=
    add_absorp_fp hfp hOm1lt
  have key := psi_add_eq_epsilon (Ordinal.epsilon (Om + 1))
  rw [h1, h2] at key
  rw [bachmannHoward, ← hE]
  exact key

/-- The closed form in the form of an explicit value at every `a ≥ Ω`. -/
theorem psi_of_Om_le {a : Ordinal.{0}} (h : Om ≤ a) :
    psi a = Ordinal.epsilon (Om + 1 + (a - Om)) := by
  have hsub : Om + (a - Om) = a := Ordinal.add_sub_cancel_of_le h
  have key := psi_add_eq_epsilon (a - Om)
  rwa [hsub] at key

/-! ## Part 7: below `Ω` the collapse is the epsilon function itself

Below `Ω` the generator `Ω` is useless (a term containing it has value `≥ Ω`), which is
what `gen_dichotomy` expresses; the same successor/limit analysis as in Parts 3 and 5
therefore applies with `M < Ω` in place of the hull bound, and gives `psi c = ε_c`. -/

/-- Successor step below `Ω`. -/
theorem psi_succ_of_lt_Om {a : Ordinal.{0}} (h : a + 1 < Om) :
    psi (a + 1) = nfp (fun x : Ordinal.{0} => ω ^ x) (psi a + 1) := by
  have haOm : a < Om := lt_trans (lt_add_one a) h
  have hpsia : psi a < Om := psi_lt_Om haOm
  have hs1 : psi a + 1 < Om := Om_isSuccLimit.succ_lt hpsia
  set M := nfp (fun x : Ordinal.{0} => ω ^ x) (psi a + 1) with hM
  have hM_fp : ω ^ M = M := nfp_fp isNormal_omega0_opow _
  have hM_lt : M < Om :=
    Ordinal.nfp_lt_ord (by rw [cof_Om]; exact Cardinal.aleph0_lt_aleph_one)
      (fun i hi => opow_lt_Om hi) hs1
  have hs1M : psi a + 1 ≤ M := le_nfp _ _
  apply le_antisymm
  · apply psi_le_of_not_gen
    intro hg
    have hgens : ∀ x ∈ gens (a + 1), x < M ∨ Om ≤ x := by
      rintro x hx
      rcases hx with hx | ⟨c, rfl⟩
      · rcases hx with rfl | rfl
        · left; exact lt_of_lt_of_le (by simp) hs1M
        · right; exact le_rfl
      · left
        exact lt_of_le_of_lt (psi_mono (Order.lt_succ_iff.mp (by simpa using c.2)))
          (lt_of_lt_of_le (lt_add_one _) hs1M)
    rcases gen_dichotomy hM_fp hgens hg with h' | h'
    · exact lt_irrefl _ h'
    · exact absurd h' (not_le.2 hM_lt)
  · exact nfp_le_fp isNormal_omega0_opow.monotone
      (Order.add_one_le_of_lt (psi_strictMono (lt_add_one a))) (opow_psi (a + 1)).le

/-- Continuity at limits below `Ω`. -/
theorem psi_of_limit_lt_Om {a : Ordinal.{0}} (hlim : ∀ c < a, c + 1 < a) (ha : 0 < a)
    (haOm : a < Om) : psi a = ⨆ c : Set.Iio a, psi c.1 := by
  have hb_lt : (⨆ c : Set.Iio a, psi c.1) < Om :=
    iSup_lt_Om_of_lt_Om haOm _ (fun d => psi_lt_Om (lt_trans d.2 haOm))
  refine le_antisymm ?_ (iSup_psi_Iio_le a)
  apply psi_le_of_not_gen
  intro hgen
  have hgens : ∀ x ∈ gens a, x < (⨆ c : Set.Iio a, psi c.1) ∨ Om ≤ x := by
    rintro x hx
    rcases hx with hx | ⟨c, rfl⟩
    · rcases hx with rfl | rfl
      · left
        refine lt_of_lt_of_le eps0_pos ?_
        refine le_trans ?_ (Ordinal.le_iSup (fun d : Set.Iio a => psi d.1) ⟨0, ha⟩)
        simp [psi_zero]
      · right; exact le_rfl
    · left
      exact lt_of_lt_of_le (psi_strictMono (lt_add_one c.1))
        (Ordinal.le_iSup (fun d : Set.Iio a => psi d.1) ⟨c.1 + 1, hlim c.1 c.2⟩)
  rcases gen_dichotomy (opow_iSup_psi_Iio ha) hgens hgen with h' | h'
  · exact lt_irrefl _ h'
  · exact absurd h' (not_le.2 hb_lt)

/-- **Closed form below `Ω`: `psi c = ε_c` for every countable `c`.** Together with
`psi_of_Om_le` this determines `psi` at every argument. -/
theorem psi_eq_epsilon_of_lt_Om : ∀ {c : Ordinal.{0}}, c < Om → psi c = Ordinal.epsilon c := by
  intro c
  induction c using Ordinal.limitRecOn with
  | zero => intro _; rw [psi_zero, eps0_eq_epsilon_zero]
  | succ a ih =>
    intro h
    rw [Order.succ_eq_add_one] at h ⊢
    have haOm : a < Om := lt_trans (lt_add_one a) h
    rw [psi_succ_of_lt_Om h, ih haOm,
      show (a + 1 : Ordinal.{0}) = Order.succ a from (Order.succ_eq_add_one a).symm,
      Ordinal.epsilon_succ_eq_nfp, Order.succ_eq_add_one]
  | limit a hlim ih =>
    intro h
    have ha0 : a ≠ 0 := by simpa [Ordinal.bot_eq_zero] using hlim.ne_bot
    have ha : 0 < a := lt_of_le_of_ne (bot_le : (0 : Ordinal.{0}) ≤ a) (Ne.symm ha0)
    have hlim' : ∀ c < a, c + 1 < a := by
      intro c hc
      have := hlim.succ_lt hc
      rwa [Order.succ_eq_add_one] at this
    rw [psi_of_limit_lt_Om hlim' ha h, Ordinal.epsilon_eq_deriv, Ordinal.deriv_limit _ hlim]
    refine iSup_congr fun b => ?_
    rw [ih b.1 b.2 (lt_trans b.2 h), Ordinal.epsilon_eq_deriv]

/-- **The range of `psi` is exactly the class of epsilon numbers other than `Ω`.** The
single epsilon number that is skipped is `Ω = ε_Ω` itself, which is a generator of every
hull and hence never a value; this is the exact form of the failure of "collapsing" for
the unrestricted hull. -/
theorem range_psi : Set.range psi = Ordinal.epsilon '' {a : Ordinal.{0} | a ≠ Om} := by
  ext x
  constructor
  · rintro ⟨a, rfl⟩
    rcases lt_or_ge a Om with h | h
    · exact ⟨a, ne_of_lt h, (psi_eq_epsilon_of_lt_Om h).symm⟩
    · exact ⟨Om + 1 + (a - Om), ne_of_gt (lt_of_lt_of_le (lt_add_one Om) le_self_add),
        (psi_of_Om_le h).symm⟩
  · rintro ⟨b, hb, rfl⟩
    rcases lt_or_ge b Om with h | h
    · exact ⟨b, psi_eq_epsilon_of_lt_Om h⟩
    · have hlt : Om < b := lt_of_le_of_ne h (Ne.symm hb)
      obtain ⟨d, hd⟩ := exists_add_of_le (Order.add_one_le_of_lt hlt)
      exact ⟨Om + d, by rw [psi_add_eq_epsilon, ← hd]⟩

end

end Bridges.OrdinalCollapsing