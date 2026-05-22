/-
# Tropical Circuit Duality: Semantic Transport and Simulation Transfer

This file establishes the complete duality bridge between min-plus and max-plus
tropical circuits. The central result is that **negation defines a syntactic
involution** between the two circuit models, and **evaluation commutes with
dualization up to output negation**. As a consequence, any simulation theorem
proved for one convention automatically transfers to the other.

## Main Results

* `MaxTropCircuit.dual` — reverse dualization (max→min)
* `MaxTropCircuit.size`, `MaxTropCircuit.depth` — structural measures
* `eval_dualMaxToMin` — semantic duality for max→min
* `dual_involution_min` — `dualMaxToMin ∘ dualMinToMax = id`
* `dual_involution_max` — `dualMinToMax ∘ dualMaxToMin = id`
* `size_dual_min` — size preservation under min→max dualization
* `size_dual_max` — size preservation under max→min dualization
* `duality_extensional` — extensional equivalence is preserved
* `simulation_transfer_iff` — the simulation transfer theorem

## References

The min/max negation identity `min a b = -(max (-a) (-b))` is the
gate-level algebraic fact underlying the entire development.
-/

import Tropical.Circuits.Defs

open Finset BigOperators

noncomputable section

/-! ## Max-Plus Circuit: Size, Depth, Reverse Dual -/

namespace MaxTropCircuit

/-- Number of nodes in a max-plus circuit. -/
def size {n : ℕ} : MaxTropCircuit n → ℕ
  | var _     => 1
  | const _   => 1
  | add a b   => 1 + size a + size b
  | max a b   => 1 + size a + size b

/-- Depth of a max-plus circuit. -/
def depth {n : ℕ} : MaxTropCircuit n → ℕ
  | var _     => 0
  | const _   => 0
  | add a b   => 1 + Nat.max (depth a) (depth b)
  | max a b   => 1 + Nat.max (depth a) (depth b)

/-- Syntactic duality: negate constants and swap max↔min (reverse of `TropCircuit.dual`). -/
def dual {n : ℕ} : MaxTropCircuit n → TropCircuit n
  | var i     => TropCircuit.var i
  | const c   => TropCircuit.const (-c)
  | add a b   => TropCircuit.add (dual a) (dual b)
  | max a b   => TropCircuit.min (dual a) (dual b)

@[simp] theorem eval_var {n : ℕ} (i : Fin n) (x : Fin n → ℝ) :
    eval (var i) x = x i := rfl

@[simp] theorem eval_const {n : ℕ} (c : ℝ) (x : Fin n → ℝ) :
    eval (const c) x = c := rfl

@[simp] theorem eval_add' {n : ℕ} (C D : MaxTropCircuit n) (x : Fin n → ℝ) :
    eval (add C D) x = eval C x + eval D x := rfl

@[simp] theorem eval_max {n : ℕ} (C D : MaxTropCircuit n) (x : Fin n → ℝ) :
    eval (max C D) x = Max.max (eval C x) (eval D x) := rfl

/-- Size is always positive. -/
theorem size_pos {n : ℕ} (C : MaxTropCircuit n) : 0 < C.size := by
  cases C <;> simp [size]

end MaxTropCircuit

/-! ## Negate assignment -/

/-- Negate all entries of a variable assignment. -/
def dualVarAssign {n : ℕ} (σ : Fin n → ℝ) : Fin n → ℝ := fun i => -(σ i)

@[simp] theorem dualVarAssign_apply {n : ℕ} (σ : Fin n → ℝ) (i : Fin n) :
    dualVarAssign σ i = -(σ i) := rfl

@[simp] theorem dualVarAssign_dualVarAssign {n : ℕ} (σ : Fin n → ℝ) :
    dualVarAssign (dualVarAssign σ) = σ := by
  ext i; simp [dualVarAssign]

/-! ## Semantic Duality Theorems -/

/-
Semantic duality for max→min: evaluating the dual of a max-plus circuit
on negated inputs equals the negation of the original evaluation.
-/
theorem eval_dualMaxToMin
    {n : ℕ} (C : MaxTropCircuit n) (σ : Fin n → ℝ) :
    TropCircuit.eval (C.dual) (dualVarAssign σ) = - MaxTropCircuit.eval C σ := by
  -- Let's prove the dual evaluation property by induction on the structure of the circuit.
  induction' C with C₁ C₂ hC₁ hC₂ generalizing σ;
  · rfl;
  · rfl;
  · unfold MaxTropCircuit.dual;
    simp_all +decide [ MaxTropCircuit.eval ];
    ring;
  · rename_i a b ha hb;
    rw [ show ( a.max b ).dual = TropCircuit.min a.dual b.dual by rfl, TropCircuit.eval ];
    rw [ ha, hb, show ( a.max b ).eval σ = Max.max ( a.eval σ ) ( b.eval σ ) from rfl ] ; rw [ min_def, max_def ] ; split_ifs <;> linarith

/-
Alternative form of `eval_duality` using `dualVarAssign`.
-/
theorem eval_dualMinToMax
    {n : ℕ} (C : TropCircuit n) (σ : Fin n → ℝ) :
    MaxTropCircuit.eval (C.dual) (dualVarAssign σ) = - TropCircuit.eval C σ := by
  induction' C with _ _ _ _ _ _ generalizing σ;
  · rfl;
  · rfl;
  · rename_i a b ha hb;
    convert congr_arg₂ ( · + · ) ( ha σ ) ( hb σ ) using 1;
    exact neg_add _ _;
  · rename_i a b ha hb;
    convert congr_arg₂ ( fun x y => Max.max x y ) ( ha σ ) ( hb σ ) using 1;
    -- By definition of `eval`, we know that `eval (min a b) σ = min (eval a σ) (eval b σ)`.
    have h_eval_min : (a.min b).eval σ = min (a.eval σ) (b.eval σ) := by
      rfl;
    rw [ h_eval_min, min_def, max_def ] ; split_ifs <;> linarith

/-! ## Syntactic Involutivity -/

/-
Dualization is an involution on min-plus circuits:
`dual_max_to_min (dual_min_to_max C) = C`.
-/
theorem dual_involution_min
    {n : ℕ} (C : TropCircuit n) :
    (C.dual).dual = C := by
  induction C <;> simp [MaxTropCircuit.dual, TropCircuit.dual] at *;
  · tauto;
  · tauto

/-
Dualization is an involution on max-plus circuits:
`dual_min_to_max (dual_max_to_min C) = C`.
-/
theorem dual_involution_max
    {n : ℕ} (C : MaxTropCircuit n) :
    (C.dual).dual = C := by
  -- By definition of dualization, we know that applying it twice returns the original circuit.
  have h_dual_inv : ∀ (C : MaxTropCircuit n), (C.dual).dual = C := by
    intro C; exact (by
    induction C <;> simp_all +decide [ MaxTropCircuit.dual, TropCircuit.dual ]);
  exact h_dual_inv C

/-! ## Size and Depth Preservation -/

/-
Dualization preserves circuit size (min→max direction).
-/
theorem size_dual_min
    {n : ℕ} (C : TropCircuit n) :
    (C.dual).size = C.size := by
  -- By induction on the structure of C, we can show that the size of the dual of C is equal to the size of C.
  induction' C with n C ih;
  · rfl;
  · rfl;
  · simp [MaxTropCircuit.size, *, TropCircuit.dual];
    exact?;
  · -- By definition of dual, we have that the size of the dual of a min circuit is the same as the size of the min circuit itself.
    simp [TropCircuit.dual, MaxTropCircuit.size];
    rw [ TropCircuit.size ] ; linarith

/-
Dualization preserves circuit size (max→min direction).
-/
theorem size_dual_max
    {n : ℕ} (C : MaxTropCircuit n) :
    (C.dual).size = C.size := by
  -- By induction on the structure of C, we can show that the size of the dual of C is equal to the size of C.
  induction' C with n C ih;
  · rfl;
  · rfl;
  · rename_i k hkircuit.dual TropCircuit.dual;
    exact show ( TropCircuit.add ( ih.dual ) ( k.dual ) ).size = ( MaxTropCircuit.add ih k ).size from by rw [ show ( TropCircuit.add ( ih.dual ) ( k.dual ) ).size = 1 + ( ih.dual ).size + ( k.dual ).size by rfl, show ( MaxTropCircuit.add ih k ).size = 1 + ih.size + k.size by rfl ] ; simp +decide [ * ] ;
  · rename_i a b ha hb;
    exact show 1 + a.dual.size + b.dual.size = 1 + a.size + b.size by rw [ ha, hb ] ;

/-
Dualization preserves circuit depth (min→max direction).
-/
theorem depth_dual_min
    {n : ℕ} (C : TropCircuit n) :
    (C.dual).depth = C.depth := by
  induction' C with i c a b ih_a ih_b;
  · rfl;
  · exact?;
  · -- By definition of dual, the depth of the dual of an add circuit is the maximum of the depths of the duals of the two subcircuits plus one.
    have h_dual_add : (a.add b).dual.depth = 1 + max (a.dual.depth) (b.dual.depth) := by
      exact?;
    aesop;
  · erw [ show MaxTropCircuit.depth ( MaxTropCircuit.max _ _ ) = 1 + Nat.max _ _ from rfl ] ; aesop

/-
Dualization preserves circuit depth (max→min direction).
-/
theorem depth_dual_max
    {n : ℕ} (C : MaxTropCircuit n) :
    (C.dual).depth = C.depth := by
  -- By induction on the structure of the circuit, we can show that the depth of the dual of a max-plus circuit is equal to the depth of the original circuit.
  induction' C with C ih;
  · rfl;
  · rfl;
  · rename_i a b ha hbide;
    rw [ show ( a.add b ).dual = TropCircuit.add ( a.dual ) ( b.dual ) by rfl, show ( a.add b ).depth = 1 + Nat.max ( a.depth ) ( b.depth ) by rfl, show ( TropCircuit.add ( a.dual ) ( b.dual ) ).depth = 1 + Nat.max ( a.dual.depth ) ( b.dual.depth ) by rfl, ha, hbide ];
  · exact congr_arg ( fun x => 1 + x ) ( by aesop )

/-! ## Extensional Equivalence Preservation -/

/-
If two min-plus circuits are semantically equivalent, then their
max-plus duals are also semantically equivalent.
-/
theorem duality_extensional
    {n : ℕ} (C₁ C₂ : TropCircuit n)
    (h : ∀ σ, TropCircuit.eval C₁ σ = TropCircuit.eval C₂ σ) :
    ∀ σ, MaxTropCircuit.eval C₁.dual σ = MaxTropCircuit.eval C₂.dual σ := by
  intro σ;
  have := eval_dualMinToMax C₁ ( dualVarAssign σ ) ; have := eval_dualMinToMax C₂ ( dualVarAssign σ ) ; simp_all +decide ;

/-
The max→min direction of extensional equivalence preservation.
-/
theorem duality_extensional_max
    {n : ℕ} (C₁ C₂ : MaxTropCircuit n)
    (h : ∀ σ, MaxTropCircuit.eval C₁ σ = MaxTropCircuit.eval C₂ σ) :
    ∀ σ, TropCircuit.eval C₁.dual σ = TropCircuit.eval C₂.dual σ := by
  intros σ
  have h_dual : TropCircuit.eval (C₁.dual) (dualVarAssign σ) = -MaxTropCircuit.eval C₁ σ ∧ TropCircuit.eval (C₂.dual) (dualVarAssign σ) = -MaxTropCircuit.eval C₂ σ := by
    exact ⟨ eval_dualMaxToMin C₁ σ, eval_dualMaxToMin C₂ σ ⟩;
  have h_dual : TropCircuit.eval (C₁.dual) (dualVarAssign (dualVarAssign σ)) = -MaxTropCircuit.eval C₁ (dualVarAssign σ) ∧ TropCircuit.eval (C₂.dual) (dualVarAssign (dualVarAssign σ)) = -MaxTropCircuit.eval C₂ (dualVarAssign σ) := by
    exact ⟨ eval_dualMaxToMin _ _, eval_dualMaxToMin _ _ ⟩;
  aesop

/-! ## Simulation Predicates -/

/-- A size function `s` witnesses that max-plus circuits simulate min-plus circuits
if every min-plus circuit of size ≤ n has a semantically equivalent max-plus dual
of size ≤ s n. -/
def SimulatesMinByMax {m : ℕ} (s : ℕ → ℕ) : Prop :=
  ∀ (k : ℕ) (C : TropCircuit m),
    C.size ≤ k →
    ∃ D : MaxTropCircuit m,
      D.size ≤ s k ∧
      ∀ σ, MaxTropCircuit.eval D σ = MaxTropCircuit.eval C.dual σ

/-- A size function `s` witnesses that min-plus circuits simulate max-plus circuits. -/
def SimulatesMaxByMin {m : ℕ} (s : ℕ → ℕ) : Prop :=
  ∀ (k : ℕ) (C : MaxTropCircuit m),
    C.size ≤ k →
    ∃ D : TropCircuit m,
      D.size ≤ s k ∧
      ∀ σ, TropCircuit.eval D σ = TropCircuit.eval C.dual σ

/-! ## The Simulation Transfer Theorem -/

/-
**The Simulation Transfer Theorem (forward direction).**
If min-plus circuits of size ≤ n can be simulated by max-plus circuits of size ≤ s n,
then max-plus circuits of size ≤ n can be simulated by min-plus circuits of size ≤ s n.

The proof idea: given a max-plus circuit `C`, dualize it to get a min-plus circuit `C.dual`
of the same size, apply the hypothesis to get a max-plus simulator `D`, then dualize `D`
back to get a min-plus circuit `D.dual` of the same size.
-/
theorem simulation_transfer_min_to_max
    {m : ℕ} (s : ℕ → ℕ) (h : SimulatesMinByMax (m := m) s) :
    SimulatesMaxByMin (m := m) s := by
  intro k C hC;
  -- Apply the hypothesis `h` to the dual of `C`, which is a min-plus circuit.
  obtain ⟨D, hD_size, hD_eval⟩ := h k (C.dual) (by
  -- By definition of dual, we know that the size of the dual of C is equal to the size of C.
  have h_dual_size : C.dual.size = C.size := by
    exact?
  rw [h_dual_size]
  exact hC);
  use D.dual;
  simp_all +decide [ dual_involution_max ];
  exact ⟨ by simpa [ size_dual_max ] using hD_size, fun σ => by simpa [ size_dual_max ] using duality_extensional_max _ _ hD_eval σ ⟩

/-
**The Simulation Transfer Theorem (backward direction).**
-/
theorem simulation_transfer_max_to_min
    {m : ℕ} (s : ℕ → ℕ) (h : SimulatesMaxByMin (m := m) s) :
    SimulatesMinByMax (m := m) s := by
  intro k C hC;
  -- By hypothesis h, there exists a min-plus circuit D such that D.size ≤ s k and D.eval σ = C.eval σ for all σ.
  obtain ⟨D, hD_size, hD_eval⟩ := h k (C.dual) (by
  rw [ size_dual_min ];
  assumption);
  use D.dual;
  simp_all +decide [ size_dual_min, dual_involution_min ];
  convert duality_extensional D C hD_eval using 1

/-- **The Simulation Transfer Theorem (biconditional).**
The simulation problem is invariant under tropical convention:
min-plus circuits simulate max-plus circuits with overhead `s` if and only if
max-plus circuits simulate min-plus circuits with overhead `s`. -/
theorem simulation_transfer_iff
    {m : ℕ} (s : ℕ → ℕ) :
    SimulatesMinByMax (m := m) s ↔ SimulatesMaxByMin (m := m) s :=
  ⟨simulation_transfer_min_to_max s, simulation_transfer_max_to_min s⟩

/-! ## Gate-Level Duality Lemmas -/

/-
Gate-level duality: `min a b = -(max (-a) (-b))`.
-/
theorem eval_min_gate_duality (x y : ℝ) :
    min x y = -(max (-x) (-y)) := by
  grind

/-
Gate-level duality: `max a b = -(min (-x) (-y))`.
-/
theorem eval_max_gate_duality (x y : ℝ) :
    max x y = -(min (-x) (-y)) := by
  grind

end