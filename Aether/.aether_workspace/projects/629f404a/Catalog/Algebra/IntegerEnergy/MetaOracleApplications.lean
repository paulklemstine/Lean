import Mathlib

/-! # CatalogBuild.Computation.Oracles.MetaOracleApplications

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14
-/


noncomputable section

/-- On Fin 2, there are exactly 3 idempotent functions (oracles). -/
theorem oracle_count_fin2 :
    (Finset.univ.filter (fun f : Fin 2 → Fin 2 => ∀ x, f (f x) = f x)).card = 3 := by
  decide




/-- On Fin 1, there is exactly 1 oracle (the identity). -/
theorem oracle_count_fin1 :
    (Finset.univ.filter (fun f : Fin 1 → Fin 1 => ∀ x, f (f x) = f x)).card = 1 := by
  decide




/-- On Fin 3, there are exactly 10 idempotent functions. -/
theorem oracle_count_fin3 :
    (Finset.univ.filter (fun f : Fin 3 → Fin 3 => ∀ x, f (f x) = f x)).card = 10 := by
  native_decide




/-- The identity has full image. -/
theorem identity_image_full (n : ℕ) :
    (Finset.univ.image (id : Fin n → Fin n)).card = n := by
  simp [Finset.image_id, Finset.card_univ, Fintype.card_fin]




/-- A constant function has image size 1 (when n > 0). -/
theorem constant_image_size {n : ℕ} (_hn : 0 < n) (c : Fin n) :
    (Finset.univ.image (fun _ : Fin n => c)).card = 1 := by
  have : Nonempty (Fin n) := ⟨c⟩
  rw [Finset.image_const Finset.univ_nonempty, Finset.card_singleton]




/-- Iterating an oracle and then applying it again is redundant. -/
theorem oracle_absorbs {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (f : X → X) (x : X) :
    O (O (f x)) = O (f x) := hO _




/-- Oracle iteration stabilizes: O^n = O for all n ≥ 1. -/
theorem oracle_iterate_const {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (n : ℕ) (hn : 1 ≤ n) : O^[n] = O := by
  induction n with
  | zero => omega
  | succ k ih =>
    rw [Function.iterate_succ']
    simp only [Function.comp_def]
    cases k with
    | zero => rfl
    | succ m =>
      rw [ih (by omega)]
      ext x; exact hO x




/-- The zero oracle is idempotent. -/
theorem zeroOracle_idem (n : ℕ) : ∀ x, zeroOracle n (zeroOracle n x) = zeroOracle n x :=
  fun _ => rfl




/-- The squaring map on ZMod 2 is idempotent. -/
theorem zmod2_square_idem : ∀ x : ZMod 2, x * x * (x * x) = x * x := by decide




/-- An oracle on Fin n has image size at most n. -/
theorem oracle_image_bound {n : ℕ} (f : Fin n → Fin n) :
    (Finset.univ.image f).card ≤ n := by
  calc (Finset.univ.image f).card ≤ Finset.univ.card := Finset.card_image_le
    _ = n := by simp [Fintype.card_fin]




/-- For an idempotent f on Fin n, Fix(f) ⊆ Im(f). -/
theorem oracle_fixed_subset_image {n : ℕ} (f : Fin n → Fin n) :
    ∀ y, f y = y → y ∈ Finset.univ.image f := by
  intro y hy
  exact Finset.mem_image.mpr ⟨y, Finset.mem_univ y, hy⟩




/-- The set of "interesting questions" — the non-fixed points. -/
def interestingQueries {n : ℕ} (f : Fin n → Fin n) : Finset (Fin n) :=
  Finset.univ.filter (fun x => f x ≠ x)




/-- [Section: # CatalogBuild.Computation.Oracles.MetaOracleApplications
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14] -/
theorem partition_queries {n : ℕ} (f : Fin n → Fin n) :
    (Finset.univ.filter (fun x => f x = x)).card +
    (interestingQueries f).card = n := by
  -- The sum of the cardinalities of the fixed points and the interesting queries equals the cardinality of the universal set.
  have h_sum : (Finset.univ.filter (fun x => f x = x)).card + (Finset.univ.filter (fun x => f x ≠ x)).card = Finset.card (Finset.univ : Finset (Fin n)) := by
    rw [ Finset.card_filter_add_card_filter_not ];
  aesop




/-- For an oracle with k fixed points, there are n - k interesting questions. -/
theorem interesting_count {n : ℕ} (f : Fin n → Fin n) :
    (interestingQueries f).card =
    n - (Finset.univ.filter (fun x => f x = x)).card := by
  have h := partition_queries f
  omega




end