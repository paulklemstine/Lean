import Mathlib

/-!
# Proof-Theoretic Ordinal Analysis III: Closure Barriers `ε₀`, `Γ₀`, and a Normal-Function Master Theorem

This file extends the abstract framework of proof-theoretic ordinal analysis developed
in the catalog files `Catalog/Pythagorean/ProofTheoreticOrdinals.lean` (the
`OrdinalTheory` structure, its proof-theoretic ordinal `pto`, `ofOrdinal`) and
`Catalog/Pythagorean/ProofTheoreticOrdinalsLattice.lean` (totality of the inclusion
order, `pto` as a lattice homomorphism, the depth quasi-metric).  Because those files
sit outside the build's default search path, the small core needed here (the
`OrdinalTheory` structure, `pto`, `ofOrdinal`, and the PTO evaluations
`pto_ofOrdinal_limit`, `pto_ofOrdinal_succ`) is reproduced verbatim in Section 0; all
*new* mathematics is in Sections 1–6.

## The new mathematics

We connect the abstract `OrdinalTheory` lattice to the concrete proof-theoretic
landmarks `ε₀` (the Feferman–Schütte predecessor) and `Γ₀` (the Feferman–Schütte
ordinal) through a single organising notion — **closure under a normal function**.

* **Master theorem (Section 2).** `nfp_isLeast_limit_closedUnder`: for *any* normal
  ordinal function `f` whose least fixed point above `0` is a limit, that fixed point
  `nfp f 0` is the **least** ordinal `α` such that the limit theory `ofOrdinal α` is
  closed under `f`.  The proof is purely order-theoretic: it factors through the
  fixed-point characterisation `closedUnder_ofOrdinal_iff_isFixed`, which itself only
  uses normality (strict monotonicity + the `IsSuccLimit` supremum law).

* **The `ε₀` barrier (Section 3).** Instantiating `f = (ω ^ ·)` gives
  `expClosed_ofOrdinal_iff_isFixed` (closure ⇔ the ε-number equation `ω ^ α = α`) and
  `epsilon0_isLeast_expClosed` (`ε₀` is the least PTO of an exponentially-closed limit
  theory).

* **The `Γ₀` barrier (Section 4).** Instantiating `f = (veblen · 0)` gives the exact
  analogue one Veblen level up: `gamma0_isLeast_veblenClosed`.

* **Necessity of the limit hypothesis (Section 5).** A boundary triple at the successor
  `ε₀ + 1` (`expClosed_succ_epsilon0`, `not_isLimitTheory_succ_epsilon0`,
  `not_isFixed_succ_epsilon0`) shows that exponential closure can hold *without* the
  fixed-point equation, so the limit hypothesis in the iff is genuinely necessary.

* **Strict separation (Section 6).** `pto_lt_pto_epsilon0_gamma0`: the `ε₀` barrier sits
  strictly below the predicative barrier `Γ₀`.

-- !-- Lab Notebook -- !--
**Hypothesis.** The bespoke "exponential closure ⇔ ε-number" equivalence behind the `ε₀`
barrier should depend on *nothing* about `ω ^ ·` except normality, hence ought to lift
verbatim to `veblen · 0` (giving `Γ₀`) and to an arbitrary normal `f`.

**Result.** Confirmed and proved: the single master theorem
`nfp_isLeast_limit_closedUnder` subsumes both barriers, which become two-line corollaries
via `epsilon_zero_eq_nfp` and `gamma_zero_eq_nfp`.

**Insight.** The closure question reduces to the least-fixed-point identity
`nfp_le_fp` + the normality supremum law `Order.IsNormal.le_iff_forall_le`; no ordinal
*arithmetic* is needed at all.  The fibre/lattice structure from the catalog then makes
`ε₀` and `Γ₀` *least elements*, not merely lower bounds.

**Failure analysis.** A first attempt phrased the barrier directly on `OrdinalTheory`
values using the catalog `pto`; this forced delicate `sSup` reasoning.  Re-phrasing the
extremal statement on the *ordinal* parameter `α` (with `IsSuccLimit α`, where
`pto (ofOrdinal α) = α`) removed all `sSup` manipulation and made the `IsLeast` proof
immediate.  A second snag: `nfp f 0` need not be a limit for a general normal `f`
(e.g. `f = id`), so the master theorem carries `IsSuccLimit (nfp f 0)` as a hypothesis,
discharged for `ε₀` and `Γ₀` via `isSuccLimit_opow_left`.
-/

open Ordinal Set

noncomputable section

universe v

/-! ## Section 0: Reproduced core (see catalog `ProofTheoreticOrdinals.lean`) -/

/-- An `OrdinalTheory` models a formal theory by the set of ordinals it proves
well-ordered: a downward-closed, bounded-above set of ordinals. -/
structure OrdinalTheory where
  /-- The set of ordinals provably well-ordered by this theory. -/
  provablyWO : Set Ordinal.{v}
  /-- The set is bounded above. -/
  bddAbove : BddAbove provablyWO
  /-- The set is downward closed: an initial segment of ordinals. -/
  isInitSeg : ∀ ⦃α⦄, α ∈ provablyWO → ∀ ⦃β⦄, β < α → β ∈ provablyWO

/-- The proof-theoretic ordinal (PTO) of an `OrdinalTheory`. -/
def OrdinalTheory.pto (T : OrdinalTheory.{v}) : Ordinal.{v} :=
  sSup T.provablyWO

/-- Construct an `OrdinalTheory` from an ordinal `α`, with `provablyWO = Set.Iio α`. -/
def OrdinalTheory.ofOrdinal (α : Ordinal.{v}) : OrdinalTheory.{v} where
  provablyWO := Set.Iio α
  bddAbove := ⟨α, fun _ h => le_of_lt h⟩
  isInitSeg := fun _ hβ _ hγβ => lt_trans hγβ hβ

-- !-- `Iio α` of a successor-limit ordinal has supremum `α` (catalog `pto_ofOrdinal_limit`). -- !--
/-- For a limit ordinal `α`, the PTO of `ofOrdinal α` is `α`. -/
theorem pto_ofOrdinal_limit {α : Ordinal.{v}} (hα : Order.IsSuccLimit α) :
    (OrdinalTheory.ofOrdinal α).pto = α :=
  hα.sSup_Iio

-- !-- `Iio (α+1) = Iic α`, whose `sSup` is `α` (catalog lattice `pto_ofOrdinal_succ`). -- !--
/-- The PTO of `ofOrdinal (α + 1)` is `α`. -/
theorem pto_ofOrdinal_succ (α : Ordinal.{v}) :
    (OrdinalTheory.ofOrdinal (α + 1)).pto = α := by
  show sSup (Set.Iio (α + 1)) = α
  have h : Set.Iio (α + 1) = Set.Iic α := by ext x; simp
  rw [h]; exact csSup_Iic

/-! ## Section 1: Closure of a theory under a function, and the fixed-point criterion -/

/-- `ClosedUnder f T` says the set of ordinals `T` proves well-ordered is closed under
`f`: applying `f` never escapes the theory.  For `f = (ω ^ ·)` this is *exponential
closure*; for `f = (veblen · 0)` it is *Veblen closure*. -/
def ClosedUnder (f : Ordinal.{v} → Ordinal.{v}) (T : OrdinalTheory.{v}) : Prop :=
  ∀ ⦃β⦄, β ∈ T.provablyWO → f β ∈ T.provablyWO

/-- A theory is a *limit theory* when its proof-theoretic ordinal is a limit ordinal. -/
def IsLimitTheory (T : OrdinalTheory.{v}) : Prop := Order.IsSuccLimit T.pto

-- !-- `(≤)`: by `IsNormal.le_iff_forall_le` each `f β < α` forces `f α ≤ α`; `(≥)`: every
-- normal map is inflationary (`StrictMono.le_apply`). Conversely strict monotonicity sends
-- `β < α = f α` to `f β < α`. -- !--
/-- **Fixed-point criterion.** For a normal `f` and a *limit* ordinal `α`, the limit
theory `ofOrdinal α` is closed under `f` if and only if `α` is a fixed point of `f`.
This is the order-theoretic heart of every closure barrier below. -/
theorem closedUnder_ofOrdinal_iff_isFixed {f : Ordinal.{v} → Ordinal.{v}}
    (hf : Order.IsNormal f) {α : Ordinal.{v}} (hα : Order.IsSuccLimit α) :
    ClosedUnder f (OrdinalTheory.ofOrdinal α) ↔ f α = α := by
  simp only [ClosedUnder, OrdinalTheory.ofOrdinal, Set.mem_Iio]
  constructor
  · intro hclosed
    refine le_antisymm ?_ hf.strictMono.le_apply
    rw [hf.le_iff_forall_le hα]
    exact fun a' ha' => (hclosed ha').le
  · intro hfix β hβ
    have := hf.strictMono hβ
    rwa [hfix] at this

/-! ## Section 2: The master theorem — `nfp f 0` is the least limit closure ordinal -/

-- !-- Membership: `f (nfp f 0) = nfp f 0` (`nfp_fp`) gives closure via the criterion.
-- Lower bound: the criterion turns a closed limit theory into a fixed point, and
-- `nfp_le_fp` makes `nfp f 0` the least fixed point above `0`. -- !--
/-- **Master theorem.** For any normal `f` whose least fixed point above `0` is a limit
ordinal, `nfp f 0` is the *least* ordinal `α` for which the limit theory `ofOrdinal α` is
closed under `f`.  Specialising `f` to `ω ^ ·` and `veblen · 0` yields the `ε₀` and `Γ₀`
barriers (Sections 3–4). -/
theorem nfp_isLeast_limit_closedUnder {f : Ordinal.{v} → Ordinal.{v}}
    (hf : Order.IsNormal f) (hlim : Order.IsSuccLimit (nfp f 0)) :
    IsLeast {α : Ordinal.{v} |
      Order.IsSuccLimit α ∧ ClosedUnder f (OrdinalTheory.ofOrdinal α)} (nfp f 0) := by
  constructor
  · refine ⟨hlim, ?_⟩
    exact (closedUnder_ofOrdinal_iff_isFixed hf hlim).2 (nfp_fp hf 0)
  · rintro α ⟨hαlim, hαclosed⟩
    have hfix : f α = α := (closedUnder_ofOrdinal_iff_isFixed hf hαlim).1 hαclosed
    exact nfp_le_fp hf.monotone (zero_le α) hfix.le

/-! ## Section 3: The `ε₀` barrier (instantiate the master theorem at `f = ω ^ ·`) -/

/-- **Exponential closure.** A theory is exponentially closed when its provably
well-ordered ordinals are closed under `α ↦ ω ^ α`. -/
def ExpClosed (T : OrdinalTheory.{v}) : Prop := ClosedUnder (fun a => ω ^ a) T

theorem isSuccLimit_epsilon0 : Order.IsSuccLimit ε₀ := by
  have h : ω ^ ε₀ = ε₀ := omega0_opow_epsilon 0
  rw [← h]
  exact isSuccLimit_opow_left isSuccLimit_omega0 (epsilon_pos 0).ne'

-- !-- A direct corollary of `closedUnder_ofOrdinal_iff_isFixed` with `f = ω ^ ·`. -- !--
/-- **Exponential closure ⇔ ε-number.** For a limit ordinal `α`, the theory `ofOrdinal α`
is exponentially closed iff `α` satisfies the ε-number equation `ω ^ α = α`. -/
theorem expClosed_ofOrdinal_iff_isFixed {α : Ordinal.{v}} (hα : Order.IsSuccLimit α) :
    ExpClosed (OrdinalTheory.ofOrdinal α) ↔ ω ^ α = α :=
  closedUnder_ofOrdinal_iff_isFixed (isNormal_opow one_lt_omega0) hα

-- !-- Master theorem at `f = ω ^ ·`, rewriting `nfp (ω ^ ·) 0 = ε₀` (`epsilon_zero_eq_nfp`). -- !--
/-- **The `ε₀` barrier.** `ε₀` is the least ordinal whose limit theory is exponentially
closed — equivalently, the least proof-theoretic ordinal of an exponentially-closed limit
theory. -/
theorem epsilon0_isLeast_expClosed :
    IsLeast {α : Ordinal.{v} |
      Order.IsSuccLimit α ∧ ExpClosed (OrdinalTheory.ofOrdinal α)} ε₀ := by
  have h := nfp_isLeast_limit_closedUnder (isNormal_opow one_lt_omega0)
    (by rw [← epsilon_zero_eq_nfp]; exact isSuccLimit_epsilon0)
  rwa [← epsilon_zero_eq_nfp] at h

/-- The PTO of the least exponentially-closed limit theory is exactly `ε₀`. -/
theorem pto_epsilon0_expClosed :
    (OrdinalTheory.ofOrdinal ε₀).pto = ε₀ ∧ ExpClosed (OrdinalTheory.ofOrdinal ε₀) :=
  ⟨pto_ofOrdinal_limit isSuccLimit_epsilon0, epsilon0_isLeast_expClosed.1.2⟩

/-! ## Section 4: The `Γ₀` barrier (instantiate the master theorem at `f = veblen · 0`) -/

/-- **Veblen closure.** A theory is Veblen closed when its provably well-ordered ordinals
are closed under `α ↦ veblen α 0` (one Veblen level above exponential closure). -/
def VeblenClosed (T : OrdinalTheory.{v}) : Prop := ClosedUnder (fun a => veblen a 0) T

theorem isSuccLimit_gamma0 : Order.IsSuccLimit Γ₀ := by
  have h : ω ^ Γ₀ = Γ₀ := by
    have h1 : veblen 0 (veblen Γ₀ 0) = veblen Γ₀ 0 := veblen_veblen_of_lt gamma_pos 0
    rw [veblen_gamma_zero, veblen_zero] at h1; exact h1
  rw [← h]
  exact isSuccLimit_opow_left isSuccLimit_omega0 gamma_ne_zero

-- !-- A direct corollary of `closedUnder_ofOrdinal_iff_isFixed` with `f = veblen · 0`. -- !--
/-- **Veblen closure ⇔ Veblen fixed point.** For a limit ordinal `α`, `ofOrdinal α` is
Veblen closed iff `veblen α 0 = α`. -/
theorem veblenClosed_ofOrdinal_iff_isFixed {α : Ordinal.{v}} (hα : Order.IsSuccLimit α) :
    VeblenClosed (OrdinalTheory.ofOrdinal α) ↔ veblen α 0 = α :=
  closedUnder_ofOrdinal_iff_isFixed isNormal_veblen_zero hα

-- !-- Master theorem at `f = veblen · 0`, rewriting `nfp (veblen · 0) 0 = Γ₀`
-- (`gamma_zero_eq_nfp`). -- !--
/-- **The `Γ₀` barrier (predicative barrier).** `Γ₀`, the Feferman–Schütte ordinal, is
the least ordinal whose limit theory is Veblen closed — the exact analogue of the `ε₀`
barrier one ordinal-collapsing level higher. -/
theorem gamma0_isLeast_veblenClosed :
    IsLeast {α : Ordinal.{v} |
      Order.IsSuccLimit α ∧ VeblenClosed (OrdinalTheory.ofOrdinal α)} Γ₀ := by
  have h := nfp_isLeast_limit_closedUnder isNormal_veblen_zero
    (by rw [← gamma_zero_eq_nfp]; exact isSuccLimit_gamma0)
  rwa [← gamma_zero_eq_nfp] at h

/-! ## Section 5: Necessity of the limit hypothesis — boundary triple at `ε₀ + 1` -/

-- !-- For `β ≤ ε₀`: if `β < ε₀` then `ω^β < ω^ε₀ = ε₀`; and `ω^ε₀ = ε₀`. So `ofOrdinal
-- (ε₀+1)` (= `Iic ε₀`) is exponentially closed even though `ε₀+1` is not a fixed point. -- !--
/-- **Boundary (closure without the limit).** The *successor* theory `ofOrdinal (ε₀ + 1)`
is still exponentially closed, even though it is not a limit theory.  This shows
exponential closure alone does not force the ε-number equation. -/
theorem expClosed_succ_epsilon0 : ExpClosed (OrdinalTheory.ofOrdinal (ε₀ + 1)) := by
  simp only [ExpClosed, ClosedUnder, OrdinalTheory.ofOrdinal, Set.mem_Iio, Order.lt_add_one_iff]
  intro β hβ
  rcases hβ.lt_or_eq with hlt | heq
  · have : ω ^ β < ω ^ ε₀ := (isNormal_opow one_lt_omega0).strictMono hlt
    rw [omega0_opow_epsilon] at this
    exact this.le
  · rw [heq, omega0_opow_epsilon]

/-- **Boundary (not a limit theory).** `ofOrdinal (ε₀ + 1)` is not a limit theory: its
underlying ordinal `ε₀ + 1` is a successor, not a limit. -/
theorem not_isLimitTheory_succ_epsilon0 : ¬ Order.IsSuccLimit (ε₀ + 1 : Ordinal) := by
  simp

-- !-- `ω^(ε₀+1) = ω^ε₀ · ω = ε₀ · ω` is a limit ordinal, so it cannot equal the successor
-- `ε₀ + 1`. -- !--
/-- **Boundary (not a fixed point).** `ε₀ + 1` does not satisfy the ε-number equation, so
the fixed-point criterion genuinely needs the limit hypothesis. -/
theorem not_isFixed_succ_epsilon0 : ω ^ (ε₀ + 1) ≠ ε₀ + 1 := by
  intro h
  have hlim : Order.IsSuccLimit (ω ^ (ε₀ + 1)) :=
    isSuccLimit_opow_left isSuccLimit_omega0 (by positivity)
  rw [h] at hlim
  simp at hlim

/-! ## Section 6: Strict separation of the two barriers -/

-- !-- `ε₀ < Γ₀` (`epsilon_zero_lt_gamma`) lifts to the PTOs since both limit theories have
-- PTO equal to their defining ordinal. -- !--
/-- **The `ε₀` barrier sits strictly below the `Γ₀` barrier.** In terms of PTOs of the
two canonical limit theories, `pto (ofOrdinal ε₀) < pto (ofOrdinal Γ₀)`. -/
theorem pto_lt_pto_epsilon0_gamma0 :
    (OrdinalTheory.ofOrdinal ε₀).pto < (OrdinalTheory.ofOrdinal Γ₀).pto := by
  rw [pto_ofOrdinal_limit isSuccLimit_epsilon0, pto_ofOrdinal_limit isSuccLimit_gamma0]
  exact epsilon_zero_lt_gamma 0

/-! ## Section 7: Sanity-check examples -/

-- `ε₀` really is in the exponentially-closed-limit set, witnessing the barrier is attained.
example : ε₀ ∈ {α : Ordinal.{v} | Order.IsSuccLimit α ∧ ExpClosed (OrdinalTheory.ofOrdinal α)} :=
  epsilon0_isLeast_expClosed.1

-- Both barriers are limit theories with PTO equal to the landmark.
example : IsLimitTheory (OrdinalTheory.ofOrdinal ε₀) := by
  unfold IsLimitTheory
  rw [pto_ofOrdinal_limit isSuccLimit_epsilon0]; exact isSuccLimit_epsilon0

example : IsLimitTheory (OrdinalTheory.ofOrdinal Γ₀) := by
  unfold IsLimitTheory
  rw [pto_ofOrdinal_limit isSuccLimit_gamma0]; exact isSuccLimit_gamma0

end