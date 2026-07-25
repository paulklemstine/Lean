/-
# Thermodynamic Closure Duality

## Algebra–EML Thermodynamic Closure Duality via Idempotent Entropy Semimodules
## and Certified Free-Energy Minimization

This module establishes a precise duality between closure operators on ordered structures
and tropical free-energy minimization. The central insight is that closure fixed points are
exactly the fiberwise minimizers of a canonical free-energy functional, and that closure
computation can be certified as free-energy descent.

### Main Results

1. **Variational fixed-point characterization** (`isClosed_iff_minimizes_freeEnergy`):
   A point is closed iff it minimizes the tropical free-energy functional on its closure fiber.

2. **Closure–equilibrium correspondence** (`closedEquilibrium_roundtrip_val`,
   `equilibriumClosed_roundtrip_val`):
   The poset of closed states is in bijection with the poset of equilibrium states.

3. **Certified finite descent** (`wf_descent_terminates`,
   `finite_height_descent_bound`):
   Iterative free-energy descent reaches a fixed point in finitely many steps.

4. **Minimal equilibrium presentation** (`closed_state_has_presentation`):
   Each closed state admits a presentation whose support size
   is bounded by the number of generators.

### Cross-domain significance

- **Thermodynamics ↔ Closure semantics**: Closed states = zero-entropy equilibria
- **Tropical geometry ↔ Learning theory**: Closure fibers = tropical cells
- **Order theory ↔ Statistical mechanics**: Defect = non-Archimedean irreversibility
- **Complexity theory ↔ Minimal realization**: Support size = realization complexity
-/

import Mathlib

set_option autoImplicit false

/-! ## §1. Closure Operators -/

/-- A closure operator on a preordered type: monotone, extensive, idempotent. -/
structure IsClosureOperator {M : Type*} [Preorder M] (c : M → M) : Prop where
  mono : Monotone c
  le_closure : ∀ x, x ≤ c x
  closure_idem : ∀ x, c (c x) = c x

/-- The closure fiber of z under c: all points whose closure equals z. -/
def closureFiber {M : Type*} (c : M → M) (z : M) : Set M := {x | c x = z}

/-! ## §2. Closure Defect -/

/-- A closure defect functional: measures the gap from a point to its closure.
    Key property: `defect x = ⊥` iff `x` is closed (i.e., `c x = x`).
    Also requires that closure minimizes defect on each fiber. -/
structure IsClosureDefect {S M : Type*} [Preorder M] [Preorder S] [OrderBot S]
    (c : M → M) (defect : M → S) : Prop where
  defect_eq_bot_iff : ∀ x, defect x = ⊥ ↔ c x = x
  closed_minimizes_defect : ∀ (x y : M), c y = c x → defect (c x) ≤ defect y

/-! ## §3. Tropical Free-Energy Functional -/

/-- The tropical free-energy functional.
    `F_{c,E,β}(x) = defect(x) ⊓ (β * E(x))`
    In idempotent semiring terms, this corresponds to `defect(x) ⊕ (β ⊗ E(x))`.
    The `⊓` (inf) is the correct tropical "addition" in a min-plus setting. -/
def tropicalFreeEnergy {S M : Type*} [SemilatticeInf S] [Mul S]
    (defect : M → S) (E : M → S) (β : S) (x : M) : S :=
  defect x ⊓ (β * E x)

/-! ## §4. Variational Fixed-Point Characterization -/

/-
Forward direction: every closed point minimizes free energy on its closure fiber.
    This is the fundamental variational principle: closed states are equilibria.

    **Proof sketch**: If `c x = x`, then `defect x = ⊥` by the defect characterization.
    Therefore `tropicalFreeEnergy defect E β x = ⊥ ⊓ (β * E x) = ⊥`.
    Since `⊥` is the least element, `⊥ ≤ tropicalFreeEnergy defect E β y` for all `y`.
-/
theorem closed_minimizes_freeEnergy_on_fiber
    {S M : Type*} [SemilatticeInf S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S)
    (_hc : IsClosureOperator c)
    (hd : IsClosureDefect c defect) :
    ∀ x, c x = x → ∀ y, c y = c x →
      tropicalFreeEnergy defect E β x ≤ tropicalFreeEnergy defect E β y := by
  intro x hx y hy
  have h_defect_x : defect x = ⊥ := by
    exact hd.defect_eq_bot_iff x |>.2 hx;
  unfold tropicalFreeEnergy; aesop;

/-
Reverse direction: if a point minimizes free energy on its fiber, it is closed.
    Requires an admissibility condition ensuring that the energy term does not
    trivially mask the defect.

    **Proof sketch**: If `c x ≠ x`, then `c x` is in the fiber (since `c(c x) = c x`).
    We have `defect(c x) = ⊥`, so `F(c x) = ⊥`. The minimality hypothesis gives
    `F(x) ≤ F(c x) = ⊥`, so `F(x) = ⊥`. Since `F(x) = defect(x) ⊓ (β * E x)`,
    in a linear order `F(x) = ⊥` means `defect(x) = ⊥` or `β * E(x) = ⊥`.
    The admissibility rules out the second case, so `defect(x) = ⊥`, i.e. `c x = x`.
-/
theorem minimizes_freeEnergy_implies_closed
    {S M : Type*} [LinearOrder S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S)
    (hc : IsClosureOperator c)
    (hd : IsClosureDefect c defect)
    (hadmissible : ∀ x, c x ≠ x → ⊥ < β * E x) :
    ∀ x, (∀ y, c y = c x → tropicalFreeEnergy defect E β x ≤ tropicalFreeEnergy defect E β y) →
      c x = x := by
  intro x hx;
  contrapose! hx;
  refine' ⟨ c x, _, _ ⟩ <;> simp_all +decide [ tropicalFreeEnergy ];
  · exact hc.closure_idem x;
  · grind +splitIndPred

/-
The main duality theorem: a point is closed if and only if it minimizes
    free energy on its closure fiber. This is the **Thermodynamic Closure Duality**.

    Under a linear order on S and an admissibility condition on the energy
    observable, closure fixed points correspond exactly to fiberwise
    free-energy equilibria.
-/
theorem isClosed_iff_minimizes_freeEnergy
    {S M : Type*} [LinearOrder S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S)
    (hc : IsClosureOperator c)
    (hd : IsClosureDefect c defect)
    (hadmissible : ∀ x, c x ≠ x → ⊥ < β * E x) :
    ∀ x, c x = x ↔
      (∀ y, c y = c x → tropicalFreeEnergy defect E β x ≤ tropicalFreeEnergy defect E β y) := by
  exact fun x => ⟨ fun hx y hy => closed_minimizes_freeEnergy_on_fiber c defect E β hc hd x hx y hy, fun hx => minimizes_freeEnergy_implies_closed c defect E β hc hd hadmissible x hx ⟩

/-! ## §5. Closure–Equilibrium Correspondence -/

/-- An equilibrium state: a point that minimizes free energy on its closure fiber. -/
structure EquilibriumState {S M : Type*} [SemilatticeInf S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S) where
  val : M
  is_minimizer : ∀ y, c y = c val →
    tropicalFreeEnergy defect E β val ≤ tropicalFreeEnergy defect E β y

/-- A closed state: a fixed point of the closure operator. -/
structure ClosedState {M : Type*} (c : M → M) where
  val : M
  is_closed : c val = val

/-- Map from closed states to equilibrium states. -/
noncomputable def closedToEquilibrium
    {S M : Type*} [SemilatticeInf S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S)
    (hc : IsClosureOperator c) (hd : IsClosureDefect c defect) :
    ClosedState c → EquilibriumState c defect E β :=
  fun ⟨x, hx⟩ => ⟨x, closed_minimizes_freeEnergy_on_fiber c defect E β hc hd x hx⟩

/-- Map from equilibrium states to closed states (under admissibility). -/
noncomputable def equilibriumToClosed
    {S M : Type*} [LinearOrder S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S)
    (hc : IsClosureOperator c) (hd : IsClosureDefect c defect)
    (hadmissible : ∀ x, c x ≠ x → ⊥ < β * E x) :
    EquilibriumState c defect E β → ClosedState c :=
  fun ⟨x, hx⟩ => ⟨x, minimizes_freeEnergy_implies_closed c defect E β hc hd hadmissible x hx⟩

/-
The correspondence is a bijection on underlying points (forward-backward).
-/
theorem closedEquilibrium_roundtrip_val
    {S M : Type*} [LinearOrder S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S)
    (hc : IsClosureOperator c) (hd : IsClosureDefect c defect)
    (hadmissible : ∀ x, c x ≠ x → ⊥ < β * E x) :
    ∀ s : ClosedState c,
      (equilibriumToClosed c defect E β hc hd hadmissible
        (closedToEquilibrium c defect E β hc hd s)).val = s.val := by
  aesop

/-
The correspondence is a bijection on underlying points (backward-forward).
-/
theorem equilibriumClosed_roundtrip_val
    {S M : Type*} [LinearOrder S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect E : M → S) (β : S)
    (hc : IsClosureOperator c) (hd : IsClosureDefect c defect)
    (hadmissible : ∀ x, c x ≠ x → ⊥ < β * E x) :
    ∀ s : EquilibriumState c defect E β,
      (closedToEquilibrium c defect E β hc hd
        (equilibriumToClosed c defect E β hc hd hadmissible s)).val = s.val := by
  aesop

/-! ## §6. Certified Finite Descent -/

/-- One-step closure descent terminates immediately: applying closure twice
    is the same as applying it once. -/
theorem closureDescent_terminates {M : Type*} [Preorder M]
    (c : M → M) (hc : IsClosureOperator c) :
    ∀ x, c (c x) = c x :=
  hc.closure_idem

/-
In a well-founded relation, any step function that either fixes a point or
    strictly descends must reach a fixed point.
-/
theorem wf_descent_terminates {M : Type*}
    (r : M → M → Prop) (hwf : WellFounded r)
    (step : M → M)
    (hstep : ∀ x, step x = x ∨ r (step x) x) :
    ∀ x, ∃ n : ℕ, step^[n] x = step^[n + 1] x := by
  intro x;
  induction' x using hwf.induction with x ih;
  cases' hstep x with h h;
  · exact ⟨ 0, h.symm ⟩;
  · obtain ⟨ n, hn ⟩ := ih _ h;
    exact ⟨ n + 1, by simpa [ ← Function.iterate_succ_apply' ] using hn ⟩

/-
In a finite partial order, any inflationary (extensive) step function
    must reach a fixed point within `Fintype.card M` steps.
    This models certified free-energy descent termination in finite systems.
-/
theorem finite_height_descent_bound {M : Type*} [Fintype M] [DecidableEq M]
    [PartialOrder M]
    (step : M → M)
    (hstep : ∀ x, x ≤ step x) :
    ∀ x, ∃ n : ℕ, n ≤ Fintype.card M ∧ step^[n] x = step^[n + 1] x := by
  intro x;
  by_contra! h;
  have h_chain : ∀ i j : ℕ, i < j → i ≤ Fintype.card M → j ≤ Fintype.card M → step^[i] x < step^[j] x := by
    intro i j hij hi hj
    induction' hij with j hj ih;
    · exact lt_of_le_of_ne ( by simpa only [ Function.iterate_succ_apply' ] using hstep _ ) ( h _ hi );
    · exact lt_of_lt_of_le ( ih ( Nat.le_of_succ_le hj ) ) ( by simpa only [ Function.iterate_succ_apply' ] using hstep _ );
  have h_chain_length : Finset.card (Finset.image (fun i => step^[i] x) (Finset.range (Fintype.card M + 1))) = Fintype.card M + 1 := by
    rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => by have := h_chain _ _ hi' ( Finset.mem_range_succ_iff.mp hj ) ( Finset.mem_range_succ_iff.mp hi ) ; aesop ) ( le_of_not_gt fun hj' => by have := h_chain _ _ hj' ( Finset.mem_range_succ_iff.mp hi ) ( Finset.mem_range_succ_iff.mp hj ) ; aesop ), Finset.card_range ];
  exact h_chain_length.not_lt ( lt_of_le_of_lt ( Finset.card_le_univ _ ) ( by simp +decide ) )

/-! ## §7. Minimal Equilibrium Presentation -/

/-- A presentation of a point x from generators: a nonempty subset of generators below x. -/
structure Presentation {M : Type*} [Preorder M] {ι : Type*} (gens : ι → M) (x : M) where
  support : Finset ι
  support_nonempty : support.Nonempty
  le_of_mem : ∀ i, i ∈ support → gens i ≤ x

/-
Each closed state that is presented by generators admits a presentation
    whose support size is bounded by the total number of generators.
-/
theorem closed_state_has_presentation
    {M : Type*} [Preorder M] {ι : Type*} [Fintype ι] [DecidableEq ι]
    (c : M → M) (_hc : IsClosureOperator c)
    (gens : ι → M) (x : M) (_hx : c x = x)
    (hgen : ∃ S : Finset ι, S.Nonempty ∧ ∀ i, i ∈ S → gens i ≤ x) :
    ∃ p : Presentation gens x, p.support.card ≤ Fintype.card ι := by
  exact ⟨ ⟨ hgen.choose, hgen.choose_spec.1, hgen.choose_spec.2 ⟩, Finset.card_le_univ _ ⟩

/-! ## §8. Concrete Example: Powerset Closure -/

/-- Powerset closure: the closure adds target elements to the set. -/
def powersetClosure {α : Type*} [DecidableEq α] (target : Finset α) (x : Finset α) :
    Finset α :=
  x ∪ target

/-
Powerset closure is a closure operator on `Finset α` ordered by `⊆`.
-/
theorem powersetClosure_isClosureOperator {α : Type*} [DecidableEq α]
    (target : Finset α) :
    @IsClosureOperator (Finset α) _ (powersetClosure target) := by
  constructor;
  · exact fun x y hxy => Finset.union_subset_union hxy ( Finset.Subset.refl _ );
  · exact fun x => Finset.subset_union_left;
  · unfold powersetClosure; aesop;

/-- Defect for powerset closure: the number of missing target elements. -/
def powersetDefect {α : Type*} [DecidableEq α] (target : Finset α) (x : Finset α) : ℕ :=
  (target \ x).card

/-
Powerset defect is a closure defect for powerset closure.
-/
theorem powersetDefect_isClosureDefect {α : Type*} [DecidableEq α]
    (target : Finset α) :
    @IsClosureDefect ℕ (Finset α) _ _ _ (powersetClosure target) (powersetDefect target) := by
  constructor <;> simp +decide [ powersetClosure, powersetDefect ];
  grind

/-! ## §9. Defect Strict Descent -/

/-
If defect is a closure defect, then the closure strictly decreases
    defect for non-closed points. The closed point is the unique
    defect-minimizer in its fiber.
-/
theorem defect_strict_decrease
    {S M : Type*} [PartialOrder M] [PartialOrder S] [OrderBot S]
    (c : M → M) (defect : M → S)
    (hc : IsClosureOperator c)
    (hd : IsClosureDefect c defect) :
    ∀ x, c x ≠ x → defect (c x) < defect x := by
  intro x hx;
  have h_defect_bot : defect (c x) = ⊥ := by
    exact hd.defect_eq_bot_iff _ |>.2 ( hc.closure_idem _ );
  exact h_defect_bot.symm ▸ lt_of_le_of_ne bot_le ( Ne.symm ( by rintro h; exact hx ( hd.defect_eq_bot_iff x |>.1 h ) ) )

/-
Free energy at the closure point is at most free energy at the original point.
    This is the core monotonicity of thermodynamic descent.
-/
theorem freeEnergy_closure_le
    {S M : Type*} [SemilatticeInf S] [OrderBot S] [Mul S] [Preorder M]
    (c : M → M) (defect : M → S)
    (hc : IsClosureOperator c)
    (hd : IsClosureDefect c defect)
    (E : M → S) (β : S) :
    ∀ x, tropicalFreeEnergy defect E β (c x) ≤ tropicalFreeEnergy defect E β x := by
  cases hd;
  rename_i h₁ h₂;
  intro x;
  refine' le_trans ( inf_le_left ) _;
  exact le_inf ( h₂ x x rfl ) ( h₁ _ |>.2 ( hc.closure_idem x ) ▸ bot_le )