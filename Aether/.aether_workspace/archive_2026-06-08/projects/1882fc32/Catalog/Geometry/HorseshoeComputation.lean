import Mathlib

/-!
# Horseshoe Dynamics and Computational Universality

This file formalizes the mathematical chain connecting Smale horseshoe dynamics
to computational universality via symbolic shift spaces.

## Main Definitions

* `SymbolicShift` — The full symbolic shift on `d` symbols
* `Horseshoe` — A map semiconjugate to a full symbolic shift
* `BooleanEncoding` — Encoding of a Boolean function via symbolic itineraries

## Main Results

* `orbit_realization` — Any finite itinerary is realized by an orbit of the full shift
* `boolean_encoding_exists` — Any Boolean function can be encoded by a degree-2 horseshoe
* `entropy_characterization` — Entropy of the full d-shift is log d
* `sub_horseshoe_extraction` — Degree-d contains degree-k sub-horseshoes for k ≤ d
* `horseshoe_iterate_coding` — Semiconjugacy commutes with iteration
-/

noncomputable section

open Function Set Finset

/-! ## Part 1: Symbolic Shift Spaces -/

/-- The full symbolic shift space on `d` symbols: bi-infinite sequences `ℤ → Fin d`. -/
def SymbolicShift (d : ℕ) := ℤ → Fin d

/-- The shift map σ on symbolic sequences: (σx)(n) = x(n+1). -/
def shiftMap (d : ℕ) : SymbolicShift d → SymbolicShift d :=
  fun x n => x (n + 1)

/-
The shift map is injective.
-/
theorem shiftMap_injective (d : ℕ) : Injective (shiftMap d) := by
  intro x y hxy
  have h_eq : ∀ n, x n = y n := by
    intro n;
    convert congr_fun hxy ( n - 1 ) using 1 <;> ring; all_goals unfold shiftMap; ring;
  exact funext h_eq

/-
The shift map is surjective.
-/
theorem shiftMap_surjective (d : ℕ) : Surjective (shiftMap d) := by
  intro y
  use fun n => y (n - 1);
  exact funext fun n => by simp +decide [ shiftMap ] ;

/-- The shift map is a bijection. -/
theorem shiftMap_bijective (d : ℕ) : Bijective (shiftMap d) :=
  ⟨shiftMap_injective d, shiftMap_surjective d⟩

/-
Iterating the shift map n times gives (σⁿx)(k) = x(k+n).
-/
theorem shiftMap_iterate (d : ℕ) (x : SymbolicShift d) (n : ℕ) (k : ℤ) :
    (shiftMap d)^[n] x k = x (k + ↑n) := by
  induction' n with n ih generalizing k <;> simp_all +decide [ Function.iterate_succ_apply', add_assoc ];
  convert ih ( k + 1 ) using 1 ; ring

/-! ## Part 2: Orbit Realization -/

/-- A finite symbolic word of length `n` over `d` symbols. -/
abbrev SymbolicWord (d n : ℕ) := Fin n → Fin d

/-- An orbit of the shift map realizes a word if positions 0..n-1 match the word. -/
def realizesWord (d : ℕ) (x : SymbolicShift d) {n : ℕ} (w : SymbolicWord d n) : Prop :=
  ∀ i : Fin n, x (↑(i : ℕ) : ℤ) = w i

/-
**Orbit Realization Theorem**: Every finite word over `d` symbols is realized by
some orbit of the full shift on `d` symbols.
-/
theorem orbit_realization (d n : ℕ) (hd : 0 < d) (w : SymbolicWord d n) :
    ∃ x : SymbolicShift d, realizesWord d x w := by
  by_contra h_contra;
  simp +zetaDelta at *;
  exact h_contra ( fun i => if h : i < n ∧ 0 ≤ i then w ⟨ i.toNat, by linarith [ Int.toNat_of_nonneg h.2 ] ⟩ else ⟨ 0, hd ⟩ ) fun i => by simp +decide [ Fin.ext_iff ] ;

/-! ## Part 3: Horseshoe Maps -/

/-- A horseshoe structure: a map `f : α → α` with a semiconjugacy to the full d-shift. -/
structure Horseshoe (α : Type*) (d : ℕ) where
  map : α → α
  coding : α → SymbolicShift d
  coding_surjective : Surjective coding
  semiconjugacy : ∀ x, coding (map x) = shiftMap d (coding x)

/-
Iterating a horseshoe map corresponds to iterating the shift via the coding.
-/
theorem horseshoe_iterate_coding {α : Type*} {d : ℕ}
    (H : Horseshoe α d) (x : α) (n : ℕ) :
    H.coding (H.map^[n] x) = (shiftMap d)^[n] (H.coding x) := by
  induction' n with n ih;
  · rfl;
  · rw [ Function.iterate_succ_apply', H.semiconjugacy, ih, Function.iterate_succ_apply' ]

/-
A horseshoe map realizes every finite word via its coding.
-/
theorem horseshoe_realizes_all_words {α : Type*} {d : ℕ} (hd : 0 < d)
    (H : Horseshoe α d) (n : ℕ) (w : SymbolicWord d n) :
    ∃ x : α, realizesWord d (H.coding x) w := by
  obtain ⟨ x, hx ⟩ := orbit_realization d n hd w;
  obtain ⟨ y, hy ⟩ := H.coding_surjective x; use y; aesop;

/-! ## Part 4: Boolean Function Encoding -/

/-- A Boolean function on `n` bits. -/
abbrev BoolFun (n : ℕ) := (Fin n → Bool) → Bool

/-- Encoding of a Boolean function via a symbolic shift. -/
structure BooleanEncoding (d n : ℕ) where
  func : BoolFun n
  boolToSym : Bool → Fin d
  boolToSym_injective : Injective boolToSym
  encoder : (Fin n → Bool) → SymbolicShift d
  encodes_input : ∀ (input : Fin n → Bool) (i : Fin n),
    encoder input (↑(i : ℕ) : ℤ) = boolToSym (input i)
  encodes_output : ∀ (input : Fin n → Bool),
    encoder input (↑n : ℤ) = boolToSym (func input)

/-
**Computational Universality**: For `d ≥ 2`, every Boolean function on `n` bits
can be encoded by the full shift on `d` symbols.
-/
theorem boolean_encoding_exists (n : ℕ) (d : ℕ) (hd : 2 ≤ d) (f : BoolFun n) :
    ∃ enc : BooleanEncoding d n, enc.func = f := by
  refine' ⟨ _, _ ⟩;
  refine' ⟨ f, fun b => if b then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩, _, _, _, _ ⟩;
  exact fun a b h => by rcases a with ( _ | _ | a ) <;> rcases b with ( _ | _ | b ) <;> cases h <;> trivial;
  refine' fun input i ↦ if hi : i.toNat < n then if input ⟨ i.toNat, hi ⟩ = true then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩ else if i.toNat = n then if f input = true then ⟨ 1, by linarith ⟩ else ⟨ 0, by linarith ⟩ else ⟨ 0, by linarith ⟩;
  all_goals norm_num [ Fin.ext_iff, Int.toNat_of_nonneg ]

/-! ## Part 5: Sub-horseshoe Extraction -/

/-
**Sub-horseshoe Extraction**: For `k ≤ d`, the full shift on `d` symbols
contains a subsystem conjugate to the full shift on `k` symbols.
-/
theorem sub_horseshoe_extraction (d k : ℕ) (hk : 0 < k) (hkd : k ≤ d) :
    ∃ (ι : SymbolicShift k → SymbolicShift d),
      Injective ι ∧
      (∀ x, shiftMap d (ι x) = ι (shiftMap k x)) := by
  refine' ⟨ fun x n => ⟨ x n |> Fin.val |> fun z => z % k, _ ⟩, _, _ ⟩;
  exact lt_of_lt_of_le ( Nat.mod_lt _ hk ) hkd;
  · intro x y hxy;
    exact funext fun n => Fin.ext <| Nat.mod_eq_of_lt ( Fin.is_lt ( x n ) ) ▸ Nat.mod_eq_of_lt ( Fin.is_lt ( y n ) ) ▸ congr_arg Fin.val ( congr_fun hxy n );
  · unfold shiftMap; aesop;

/-
The sub-shift space is invariant under the shift map.
-/
theorem subShiftSpace_invariant (d k : ℕ) (e : Fin k ↪ Fin d) :
    ∀ x : SymbolicShift d, (∀ n : ℤ, ∃ j : Fin k, x n = e j) →
      (∀ n : ℤ, ∃ j : Fin k, shiftMap d x n = e j) := by
  exact fun x hx n => hx _

/-! ## Part 6: Entropy Bounds -/

/-- The number of distinct words of length `n` in the full shift on `d` symbols. -/
def wordCount (d n : ℕ) : ℕ := d ^ n

/-
**Entropy Characterization**: log(d^n) / n = log d for n > 0.
-/
theorem entropy_characterization (d n : ℕ) (_hd : 1 < d) (hn : 0 < n) :
    Real.log (wordCount d n : ℝ) / (n : ℝ) = Real.log (d : ℝ) := by
  unfold wordCount; rw [ div_eq_iff ( by positivity ), mul_comm, ← Real.log_pow ] ; norm_cast;

/-
A subsystem using `k ≤ d` symbols has word count at most `d^n`.
-/
theorem entropy_subsystem_bound (d k n : ℕ) (hk : k ≤ d) :
    wordCount k n ≤ wordCount d n := by
  exact Nat.pow_le_pow_left hk _

/-! ## Part 7: Parity and Complexity -/

/-- The parity function on n bits. -/
def parityFun (n : ℕ) : BoolFun n :=
  fun input => (Finset.univ.filter (fun i => input i = true)).card % 2 == 0

/-
Parity is nontrivial for n ≥ 1.
-/
theorem parity_nontrivial (n : ℕ) (hn : 1 ≤ n) :
    ∃ (a b : Fin n → Bool), parityFun n a ≠ parityFun n b := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ parityFun ];
  refine' ⟨ fun i => i = 0, fun i => i = 0 ∨ i = 1, _ ⟩ ; simp +decide [ Finset.filter_eq', Finset.filter_or ]

/-
**Encoding Monotonicity**: If a function can be encoded with `k` symbols,
it can also be encoded with `d ≥ k` symbols.
-/
theorem encoding_monotone (n k d : ℕ) (hkd : k ≤ d) (_hk : 0 < k) (f : BoolFun n) :
    (∃ enc : BooleanEncoding k n, enc.func = f) →
    (∃ enc : BooleanEncoding d n, enc.func = f) := by
  intro h
  obtain ⟨enc, h_enc⟩ := h
  use ⟨enc.func, fun b => Fin.castLE hkd (enc.boolToSym b), by
    exact fun a b h => enc.boolToSym_injective <| Fin.castLE_injective _ h, fun input => fun i => Fin.castLE hkd (enc.encoder input i), by
    exact fun input i => congr_arg ( Fin.castLE hkd ) ( enc.encodes_input input i ), by
    exact fun input => congr_arg _ ( enc.encodes_output input )⟩

end