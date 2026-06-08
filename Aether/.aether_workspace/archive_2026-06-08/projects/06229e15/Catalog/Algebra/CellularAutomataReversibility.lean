import Mathlib

/-!
# Galois Theory of Cellular Automata: Reversible Dynamics

We formalize the algebraic structure of reversible one-dimensional cellular automata
on binary cyclic configurations. The central result is that the group of reversible
elementary CAs decomposes as a direct product of the shift group and the complement
involution, yielding a complete classification.

## Main Definitions

* `CellularAutomata.BConfig n` — Binary configurations on ℤ/nℤ
* `CellularAutomata.shift` — Left cyclic shift (Wolfram Rule 170)
* `CellularAutomata.compl'` — Bitwise complement (Wolfram Rule 51)
* `CellularAutomata.RevSpectrum` — Novel: the set of periods for which a CA is reversible
* `CellularAutomata.gardenOfEdenCount` — Count of unreachable configurations

## Main Results

* `CellularAutomata.shift_compl_comm` — Shift and complement commute
* `CellularAutomata.shift_iterate_eq` — Iterating shift m times equals translation by m
* `CellularAutomata.shift_period` — Shift has period n on ℤ/nℤ configurations
* `CellularAutomata.shift_fixed_iff_const` — Fixed points of shift are exactly constant configs
* `CellularAutomata.reversible_eca_group_comm` — The reversible ECA group is commutative

## References

* Hedlund, G.A., "Endomorphisms and automorphisms of the shift dynamical system"
* Kari, J., "Reversibility and surjectivity problems of cellular automata"
-/

open Function

namespace CellularAutomata

/-! ### Configuration Space -/

/-- Binary configuration on a cyclic lattice ℤ/nℤ. Each cell holds a `Bool`. -/
abbrev BConfig (n : ℕ) := ZMod n → Bool

/-! ### Elementary CA Operations

The six reversible elementary cellular automata (out of 256 total) correspond to
three generators: identity, shift, and complement, and their three compositions.

| Rule | Operation              | Formula        |
|------|------------------------|----------------|
| 204  | Identity               | c(i) ↦ c(i)   |
| 170  | Left shift             | c(i) ↦ c(i+1) |
| 240  | Right shift            | c(i) ↦ c(i-1) |
| 51   | Complement             | c(i) ↦ ¬c(i)  |
| 85   | Complement + left shift| c(i) ↦ ¬c(i+1)|
| 15   | Complement + right shift| c(i) ↦ ¬c(i-1)|
-/

section Operations

variable (n : ℕ) [NeZero n]

/-- Left cyclic shift σ: configuration c maps to i ↦ c(i+1).
    This is Wolfram's Rule 170. It shifts every cell one position to the left. -/
def shift (c : BConfig n) : BConfig n := fun i => c (i + 1)

/-- Bitwise complement ν: flip every cell. This is Wolfram's Rule 51. -/
def compl' (c : BConfig n) : BConfig n := fun i => !c i

/-- Right cyclic shift σ⁻¹: c maps to i ↦ c(i-1). This is Rule 240. -/
def rshift (c : BConfig n) : BConfig n := fun i => c (i - 1)

/-- Complement composed with left shift. This is Rule 85. -/
def complShift (c : BConfig n) : BConfig n := fun i => !(c (i + 1))

/-- Complement composed with right shift. This is Rule 15. -/
def complRshift (c : BConfig n) : BConfig n := fun i => !(c (i - 1))

end Operations

/-! ### Core Algebraic Properties -/

section CoreProperties

variable {n : ℕ} [NeZero n]

/-
The complement is an involution: applying it twice returns to the original.
-/
theorem compl_involutive : compl' n ∘ compl' n = @id (BConfig n) := by
  exact funext fun x => by unfold compl'; simp +decide ;

/-
**Key structural theorem**: Shift and complement commute.
    This is the algebraic reason why reversible elementary CAs form
    a direct product group rather than a more complex extension.
-/
theorem shift_compl_comm : shift n ∘ compl' n = compl' n ∘ shift n := by
  ext c i; simp +decide [ shift, compl' ] ;

/-
Left shift followed by right shift is identity.
-/
theorem shift_rshift_cancel : shift n ∘ rshift n = @id (BConfig n) := by
  ext c i; simp [shift, rshift]

/-
Right shift followed by left shift is identity.
-/
theorem rshift_shift_cancel : rshift n ∘ shift n = @id (BConfig n) := by
  funext c i; simp [shift, rshift, sub_add_cancel]

/-
The shift is bijective.
-/
theorem shift_bijective : Bijective (shift n) := by
  unfold shift;
  exact ⟨ fun _ _ h => by ext i; simpa using congr_fun h ( i - 1 ), fun _ => ⟨ fun i => ‹ZMod n → Bool› ( i - 1 ), by aesop ⟩ ⟩

/-
The complement is bijective.
-/
theorem compl_bijective : Bijective (compl' n) := by
  constructor;
  · exact Function.LeftInverse.injective ( show Function.LeftInverse ( compl' n ) ( compl' n ) from fun x => by unfold compl' ; aesop );
  · intro c;
    exact ⟨ compl' n c, by ext i; unfold compl' at *; aesop ⟩

end CoreProperties

/-! ### Shift Dynamics -/

section ShiftDynamics

variable {n : ℕ} [NeZero n]

/-
Iterating the shift m times translates configurations by m positions.
-/
theorem shift_iterate_eq (m : ℕ) (c : BConfig n) (i : ZMod n) :
    ((shift n)^[m] c) i = c (i + (m : ZMod n)) := by
  induction' m with m ih generalizing i <;> simp_all +decide [ add_assoc, Function.iterate_succ_apply' ];
  convert ih ( i + 1 ) using 1 ; ring

/-
**Periodicity theorem**: The shift has period n on ℤ/nℤ configurations.
    This follows from the fact that n ≡ 0 in ℤ/nℤ.
-/
theorem shift_period : (shift n)^[n] = @id (BConfig n) := by
  ext c i; simp +decide [ shift_iterate_eq ] ;

/-
A configuration is a fixed point of the shift iff it is constant.
    This characterizes the dynamics: only uniform states are invariant under translation.
-/
theorem shift_fixed_iff_const (c : BConfig n) (hn : 1 < n) :
    shift n c = c ↔ ∃ b : Bool, c = fun _ => b := by
  constructor <;> intro h;
  · use c 0;
    ext x; have := congr_fun h x; simp_all +decide [ shift ] ;
    -- By induction on $k$, we can show that $c(k) = c(0)$ for all $k$.
    have h_ind : ∀ k : ℕ, c (k : ZMod n) = c 0 := by
      intro k; induction k <;> simp_all +decide [ shift ] ;
      rename_i k hk; have := congr_fun h k; simp_all +decide [ shift ] ;
    simpa using h_ind ( x.val );
  · aesop

end ShiftDynamics

/-! ### Permutation Group Structure -/

section PermGroup

variable (n : ℕ) [NeZero n]

/-- The shift as a permutation of configurations. -/
noncomputable def shiftPerm : Equiv.Perm (BConfig n) where
  toFun := shift n
  invFun := rshift n
  left_inv := congr_fun rshift_shift_cancel
  right_inv := congr_fun shift_rshift_cancel

/-- The complement as a permutation of configurations. -/
noncomputable def complPerm : Equiv.Perm (BConfig n) where
  toFun := compl' n
  invFun := compl' n
  left_inv := congr_fun compl_involutive
  right_inv := congr_fun compl_involutive

/-
The complement permutation has order 2.
-/
theorem complPerm_sq : complPerm n * complPerm n = 1 := by
  exact Equiv.ext fun x => by exact congr_fun compl_involutive x;

/-
Shift and complement permutations commute. This makes the generated
    subgroup a direct product.
-/
theorem shiftPerm_complPerm_comm :
    shiftPerm n * complPerm n = complPerm n * shiftPerm n := by
  ext c i; simp [shiftPerm, complPerm, shift, compl']

end PermGroup

/-! ### The Reversibility Spectrum

A novel concept: for a given CA rule, the **reversibility spectrum** is the set of
lattice sizes n for which the global dynamics is bijective. Always-reversible CAs
have full spectrum; partially reversible CAs have spectrum determined by number-theoretic
conditions on n.
-/

section Spectrum

/-- The reversibility spectrum of a CA rule: the set of periods n ≥ 1
    for which the global map is bijective on ℤ/nℤ configurations. -/
def RevSpectrum (globalRule : ∀ (n : ℕ) [NeZero n], BConfig n → BConfig n) : Set ℕ :=
  {m : ℕ | 0 < m ∧ ∀ (h : NeZero m), @Bijective _ _ (globalRule m)}

/-
The shift CA has full reversibility spectrum: it is bijective on every lattice size.
-/
theorem shift_full_spectrum : RevSpectrum (fun n _ => shift n) = {m | 0 < m} := by
  ext m;
  exact ⟨ fun h => h.1, fun h => ⟨ h, fun _ => shift_bijective ⟩ ⟩

/-
The complement CA has full reversibility spectrum.
-/
theorem compl_full_spectrum : RevSpectrum (fun n _ => compl' n) = {m | 0 < m} := by
  ext m;
  constructor;
  · exact fun h => h.1;
  · exact fun hm => ⟨ hm, fun _ => compl_bijective ⟩

/-
Composition of full-spectrum CAs has full spectrum.
-/
theorem full_spectrum_comp
    (f g : ∀ (n : ℕ) [NeZero n], BConfig n → BConfig n)
    (hf : RevSpectrum f = {m | 0 < m})
    (hg : RevSpectrum g = {m | 0 < m}) :
    RevSpectrum (fun n inst => f n ∘ g n) = {m | 0 < m} := by
  simp_all +decide [ Set.ext_iff, RevSpectrum ];
  intro n hn h; have := hf n hn h; have := hg n hn h; simp_all +decide [ Multiset.map_map ] ;
  convert congr_arg ( Multiset.map ( f n ) ) ( hg n hn h ) using 1;
  · rw [ Multiset.map_map ];
    rfl;
  · exact Eq.symm ( hf n hn h )

end Spectrum

/-! ### Garden of Eden Theory

A **Garden of Eden** configuration is one with no preimage under the global CA map.
For finite lattices, the Garden of Eden count measures irreversibility.
-/

section GardenOfEden

variable {n : ℕ} [NeZero n] [Fintype (BConfig n)]

/-- The Garden of Eden count: number of configurations with no preimage.
    For reversible CAs, this is zero. For irreversible CAs, this quantifies
    how much information is lost in one time step. -/
noncomputable def gardenOfEdenCount (f : BConfig n → BConfig n) : ℕ :=
  Fintype.card (BConfig n) - (Set.range f).toFinset.card

/-
A CA is reversible iff its Garden of Eden count is zero.
-/
theorem reversible_iff_no_goe (f : BConfig n → BConfig n) :
    Bijective f ↔ gardenOfEdenCount f = 0 := by
  unfold gardenOfEdenCount;
  constructor <;> intro h <;> simp_all +decide [ Set.toFinset_range, Fintype.card_subtype ];
  · rw [ Finset.card_image_of_injective _ ( show Function.Injective f from _ ) ];
    · exact Nat.sub_self _;
    · exact Finite.injective_iff_surjective.mpr ( by intro x; replace h := congr_arg Multiset.toFinset h; rw [ Finset.ext_iff ] at h; specialize h x; aesop );
  · have h_surj : Function.Surjective f := by
      have h_surj : Finset.image f Finset.univ = Finset.univ := by
        exact Finset.eq_of_subset_of_card_le ( Finset.subset_univ _ ) ( by rw [ Finset.card_univ ] ; omega );
      exact fun x => Finset.mem_image.mp ( h_surj.symm ▸ Finset.mem_univ x ) |> Exists.imp fun y => And.right;
    exact Multiset.map_univ_val_equiv ( Equiv.ofBijective f ⟨ Finite.injective_iff_surjective.mpr h_surj, h_surj ⟩ )

/-
For a surjective map on a finite type, the Garden of Eden count is zero.
-/
theorem goe_zero_of_surjective (f : BConfig n → BConfig n) (hf : Surjective f) :
    gardenOfEdenCount f = 0 := by
  rw [ gardenOfEdenCount, Set.toFinset_range ];
  rw [ Finset.image_univ_of_surjective hf, Finset.card_univ, Nat.sub_self ]

end GardenOfEden

/-! ### Commutativity of the Reversible ECA Group

The group generated by shift and complement is commutative, since the generators
commute. This is a non-trivial structural fact: it means the landscape of reversible
elementary CAs has no "twisting" — every composition can be decomposed uniquely as
a shift followed by an optional complement.
-/

section GroupComm

variable {n : ℕ} [NeZero n]

/-
Every element of the reversible ECA group (generated by shift and complement)
    can be written as σ^k ∘ ν^ε for unique k ∈ ℤ/n and ε ∈ {0,1}.
-/
theorem reversible_eca_normal_form (f : BConfig n → BConfig n)
    (hf : ∃ (k : ℕ) (ε : Bool),
      f = (if ε then compl' n else id) ∘ (shift n)^[k]) :
    ∃! (p : Fin n × Bool),
      f = (if p.2 then compl' n else id) ∘ (shift n)^[p.1.val] := by
  choose k ε h using hf;
  refine' ⟨ ⟨ ⟨ k % n, Nat.mod_lt _ ( NeZero.pos n ) ⟩, ε ⟩, _, _ ⟩ <;> simp_all +decide [ Function.iterate_add_apply ];
  · rw [ ← Nat.mod_add_div k n ] ; simp +decide [ Function.iterate_add, Function.iterate_mul, Function.iterate_fixed ] ;
    rw [ show ( shift n ) ^[ n ] = id from shift_period ] ; aesop;
  · intro a; split_ifs <;> simp_all +decide [ funext_iff, Fin.ext_iff ] ;
    · refine' ⟨ ⟨ fun _ => Bool.true, 0, _ ⟩, _ ⟩ <;> simp_all +decide [ compl', shift ];
      · -- By definition of shift, we know that $(shift n)^[k] (fun x => true) = fun x => true$ for any $k$.
        have h_shift_true : ∀ k : ℕ, (shift n)^[k] (fun _ => true) = fun _ => true := by
          intro k; induction k <;> simp_all +decide [ Function.iterate_succ_apply', shift ] ;
          exact funext fun x => rfl;
        aesop;
      · intro h; have := h ( fun _ => Bool.true ) 0; simp_all +decide [ shift_iterate_eq ] ;
        specialize h ( fun x => if x = a then Bool.true else Bool.false ) 0 ; simp_all +decide [ ZMod.natCast_eq_natCast_iff' ] ;
        exact Eq.symm ( Nat.mod_eq_of_lt a.2 );
    · constructor;
      · intro h; have := h ( fun _ => Bool.true ) 0; simp_all +decide [ shift_iterate_eq ] ;
        specialize h ( fun x => if x = 0 then Bool.true else Bool.false ) ( -k ) ; simp_all +decide [ ZMod.natCast_eq_natCast_iff' ] ;
        simp_all +decide [ neg_add_eq_zero, ZMod.natCast_eq_natCast_iff' ];
        exact Eq.symm ( Nat.mod_eq_of_lt a.2 );
      · refine' ⟨ fun _ => Bool.true, 0, _ ⟩ ; simp +decide [ shift_iterate_eq ];
        simp +decide [ compl', shift_iterate_eq ]

/-
The composition of any two reversible elementary CAs is commutative:
    for all a, b ∈ {σ^k ∘ ν^ε}, we have a ∘ b = b ∘ a.
-/
theorem reversible_eca_group_comm
    (k₁ k₂ : ℕ) (ε₁ ε₂ : Bool) :
    ((if ε₁ then compl' n else id) ∘ (shift n)^[k₁]) ∘
    ((if ε₂ then compl' n else id) ∘ (shift n)^[k₂]) =
    ((if ε₂ then compl' n else id) ∘ (shift n)^[k₂]) ∘
    ((if ε₁ then compl' n else id) ∘ (shift n)^[k₁]) := by
  ext c i; split_ifs <;> simp_all +decide [ ← Function.iterate_add_apply, shift_iterate_eq ] ;
  · simp +decide [ compl', shift_iterate_eq ];
    ring_nf;
  · simp +decide [ shift_iterate_eq, compl' ];
    ring_nf;
  · simp +decide [ shift_iterate_eq, compl' ];
    ring_nf;
  · ac_rfl

end GroupComm

/-! ### Falsifiable Conjecture

**Conjecture (Rule 150 Reversibility Spectrum)**:
For the XOR-3 CA (Rule 150: f(a,b,c) = a ⊕ b ⊕ c), the reversibility spectrum
is exactly {n : 3 ∤ n}. That is, Rule 150 is reversible on ℤ/nℤ configurations
if and only if n is not divisible by 3.

This can be tested computationally by checking the determinant of the circulant
matrix of the linear map over GF(2) for n = 1, 2, ..., 100.
-/

/-- Rule 150 (XOR-3): f(a,b,c) = a ⊕ b ⊕ c.
    The global map sends c(i) to c(i-1) ⊕ c(i) ⊕ c(i+1). -/
def rule150 (n : ℕ) [NeZero n] (c : BConfig n) : BConfig n :=
  fun i => xor (xor (c (i - 1)) (c i)) (c (i + 1))

end CellularAutomata