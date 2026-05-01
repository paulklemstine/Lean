import Mathlib

/-! # CatalogBuild.Speculative.RudyRucker.TransfiniteOrdinals

Auto-generated from theorem catalog database.
Domain: Speculative/RudyRucker
Declarations: 8
-/

/-- Every ordinal is either zero, a successor, or a limit ordinal.
This trichotomy is fundamental to transfinite induction, which Rucker
describes as "the engine of set-theoretic reasoning." -/
theorem ordinal_trichotomy (o : Ordinal) :
    o = 0 ∨ (∃ p, o = Order.succ p) ∨ Order.IsSuccLimit o := by
  by_contra! h_contra
  simp_all +decide [Order.IsSuccLimit]
  simp_all +decide [Order.IsSuccPrelimit]
  obtain ⟨x, hx⟩ := h_contra.2.2 h_contra.1
  exact h_contra.2.1 x hx.succ_eq.symm

/-- ω + 1 ≠ ω — adding one AFTER ω creates a new ordinal.
Together with the previous theorem, this demonstrates non-commutativity. -/
theorem omega_add_one_ne_omega : Ordinal.omega0 + 1 ≠ Ordinal.omega0 :=
  ne_of_gt (lt_add_one _)

/-- ω + 1 > ω — the successor of ω is strictly larger. -/
theorem omega_lt_omega_add_one : Ordinal.omega0 < Ordinal.omega0 + 1 :=
  lt_add_one _

/-- Transfinite induction principle: if a property holds for 0,
is preserved by successors, and is preserved at limits, then it holds
for all ordinals. -/
theorem transfinite_induction (P : Ordinal → Prop)
    (h0 : P 0)
    (hsucc : ∀ o, P o → P (Order.succ o))
    (hlimit : ∀ o, Order.IsSuccLimit o → (∀ p < o, P p) → P o) :
    ∀ o, P o := by
  intro o
  induction' o using Ordinal.limitRecOn with o ih
  · assumption
  · exact hsucc o ih
  · exact hlimit _ ‹_› ‹_›

/-- ω is a limit ordinal — it has no predecessor. -/
theorem omega_is_limit : Order.IsSuccLimit Ordinal.omega0 :=
  Ordinal.isSuccLimit_omega0

/-- ω is the smallest infinite ordinal. -/
theorem omega_le_of_not_lt (o : Ordinal) (h : ¬ o < Ordinal.omega0) :
    Ordinal.omega0 ≤ o :=
  le_of_not_gt h

/-- The natural number n, viewed as an ordinal, is less than ω.
This connects finite counting to the transfinite. -/
theorem nat_lt_omega (n : ℕ) : (n : Ordinal) < Ordinal.omega0 :=
  Ordinal.nat_lt_omega0 n

/-- ω equals the supremum of all natural numbers viewed as ordinals. -/
theorem omega_eq_iSup_nat : Ordinal.omega0 = ⨆ n : ℕ, (n : Ordinal) := by
  refine le_antisymm ?_ ?_
  · refine le_of_forall_lt fun x hx => ?_
    rw [Ordinal.lt_omega0] at hx
    exact hx.elim fun n hn => hn.symm ▸ lt_of_lt_of_le
      (Nat.cast_lt.mpr (Nat.lt_succ_self _))
      (le_ciSup (Ordinal.bddAbove_range fun n : ℕ => (n : Ordinal)) _)
  · exact ciSup_le fun n => le_of_lt (Ordinal.nat_lt_omega0 n)