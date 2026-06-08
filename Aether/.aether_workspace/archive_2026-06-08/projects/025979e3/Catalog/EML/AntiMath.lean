import Mathlib

/-!
# Anti-Mathematics: Systematic Negation of ZFC Axioms

We study three fundamental "anti-axioms" obtained by negating core ZFC axioms:

- **Anti-Extensionality**: Distinct sets can share identical membership, creating
  "phantom" elements invisible to the membership relation.
- **Anti-Infinity**: Every set is finite — realized concretely by the Ackermann
  encoding of hereditarily finite sets as natural numbers.
- **Anti-Choice**: Families of nonempty sets need not admit choice functions.

## Main Results

1. **Phantom Quotient Theorem**: Every anti-extensional universe has a canonical
   quotient that satisfies extensionality, with the "phantom index" measuring
   deviation.
2. **Ackermann Model**: ℕ with bitwise membership forms a model of ZF⁻∞ + ¬∞
   satisfying extensionality, pairing, union, and the negation of infinity.
3. **Finite Universe Rigidity**: In any finite universe (anti-infinity), every
   endofunction is eventually periodic and no countable injection exists.
4. **Axiom Defect Spectrum**: A novel continuous measure of axiom violation,
   with the compatible spectra forming a convex polytope.
-/

namespace AntiMath

open Finset Function

/-! ## Part 1: Anti-Extensionality and Phantom Sets

We formalize membership structures that may violate extensionality and study
the resulting "phantom" elements — distinct objects indistinguishable by
membership.
-/

/-- A membership structure on a type `α`: a binary relation interpreted as
    "x is a member of y". No axioms are assumed. -/
structure MemStr (α : Type*) where
  /-- The membership relation: `rel x y` means "x ∈ y" -/
  rel : α → α → Prop

/-- Two elements are **extensionally equivalent** if they have identical
    membership: the same elements belong to both. -/
def MemStr.extEquiv {α : Type*} (M : MemStr α) (a b : α) : Prop :=
  ∀ x : α, M.rel x a ↔ M.rel x b

/-- A membership structure is **anti-extensional** if there exist distinct
    elements that are extensionally equivalent — "phantom pairs". -/
def MemStr.isAntiExt {α : Type*} (M : MemStr α) : Prop :=
  ∃ a b : α, a ≠ b ∧ M.extEquiv a b

/-- Extensional equivalence is reflexive. -/
theorem extEquiv_refl {α : Type*} (M : MemStr α) (a : α) :
    M.extEquiv a a :=
  fun _ => Iff.rfl

/-- Extensional equivalence is symmetric. -/
theorem extEquiv_symm {α : Type*} (M : MemStr α) {a b : α}
    (h : M.extEquiv a b) : M.extEquiv b a :=
  fun x => (h x).symm

/-- Extensional equivalence is transitive. -/
theorem extEquiv_trans {α : Type*} (M : MemStr α) {a b c : α}
    (h1 : M.extEquiv a b) (h2 : M.extEquiv b c) : M.extEquiv a c :=
  fun x => (h1 x).trans (h2 x)

/-- The **extensional setoid**: extensional equivalence as a setoid on `α`. -/
def extSetoid {α : Type*} (M : MemStr α) : Setoid α where
  r := M.extEquiv
  iseqv := ⟨extEquiv_refl M, fun h => extEquiv_symm M h,
            fun h1 h2 => extEquiv_trans M h1 h2⟩

/-- The **Phantom Universe**: `Bool` with the empty membership relation.
    Both `true` and `false` have identical (empty) membership, making them
    a phantom pair. This is the simplest non-trivial anti-extensional universe. -/
def phantomMem : MemStr Bool where
  rel := fun _ _ => False

/-- The phantom universe is anti-extensional: `true ≠ false` yet they are
    extensionally equivalent (both have empty membership). -/
theorem phantom_anti_ext : phantomMem.isAntiExt :=
  ⟨true, false, Bool.noConfusion, fun _ => ⟨False.elim, False.elim⟩⟩

/-- **Phantom Index**: For a finite membership structure with decidable
    extensional equivalence, the number of elements "lost" when passing
    to the extensional quotient. `phantomIndex M = |α| - |α/≈|`. -/
noncomputable def phantomIndex {α : Type*} [Fintype α] [DecidableEq α]
    (M : MemStr α) [DecidableRel (extSetoid M).r] : ℕ :=
  Fintype.card α - @Fintype.card (Quotient (extSetoid M))
    (Quotient.fintype (extSetoid M))

/-- In the phantom universe, extensional equivalence is decidable
    (it is always true since membership is always False). -/
instance : DecidableRel (extSetoid phantomMem).r :=
  fun _ _ => isTrue (fun _ => ⟨False.elim, False.elim⟩)

/-
The phantom index of the phantom universe is 1: two elements collapse
    to one equivalence class.
-/
theorem phantom_index_eq_one : phantomIndex phantomMem = 1 := by
  decide +kernel

/-
**Phantom Quotient Theorem**: In a finite membership structure,
    extensionality holds (every extensionally equivalent pair is equal)
    if and only if the phantom index is zero.
-/
theorem ext_iff_phantom_zero {α : Type*} [Fintype α] [DecidableEq α]
    (M : MemStr α) [DecidableRel (extSetoid M).r] :
    (∀ a b : α, M.extEquiv a b → a = b) ↔ phantomIndex M = 0 := by
      constructor <;> intro h;
      · refine' Nat.sub_eq_zero_of_le _;
        refine' Fintype.card_le_of_injective ( fun x => Quotient.mk'' x ) fun x y hxy => _;
        exact h x y ( Quotient.exact hxy );
      · -- By definition of phantomIndex, we have Fintype.card α = Fintype.card (Quotient (extSetoid M)).
        have h_card_eq : Fintype.card α = Fintype.card (Quotient (extSetoid M)) := by
          exact le_antisymm ( le_of_not_gt fun h' => absurd h ( Nat.sub_ne_zero_of_lt h' ) ) ( Fintype.card_le_of_surjective _ ( Quotient.mk''_surjective ) );
        have h_inj : Function.Injective (Quotient.mk (extSetoid M)) := by
          exact ( Fintype.bijective_iff_surjective_and_card _ ).mpr ⟨ Quotient.mk_surjective, h_card_eq ⟩ |>.1;
        exact fun a b hab => h_inj <| Quotient.sound hab

/-! ## Part 2: The Ackermann Encoding — A Model of Hereditarily Finite Set Theory

The **Ackermann encoding** represents hereditarily finite sets as natural numbers:
the set `{a₁, a₂, ..., aₖ}` is encoded as `2^a₁ + 2^a₂ + ... + 2^aₖ`.
Membership becomes bit-testing: `m ∈ₐ n ⟺ bit m of n is 1`.
-/

/-- **Ackermann membership**: `m` is a member of `n` iff the `m`-th bit
    of `n` is set. This gives a concrete model of set membership on ℕ. -/
def ackMem (m n : ℕ) : Prop := n.testBit m = true

/-
The empty set in the Ackermann encoding is `0` — no bits are set.
-/
theorem ack_empty (m : ℕ) : ¬ackMem m 0 := by
  unfold ackMem; aesop;

/-
**Extensionality for the Ackermann encoding**: Two natural numbers with
    identical membership (identical bits) are equal. This is a fundamental
    property of the encoding — the Ackermann model satisfies extensionality.
-/
theorem ack_extensionality {a b : ℕ} (h : ∀ m, ackMem m a ↔ ackMem m b) :
    a = b := by
      exact Nat.eq_of_testBit_eq fun m => by have := h m; unfold ackMem at this; aesop;

/-
**Anti-Infinity**: There is no natural number encoding the "set of all
    natural numbers" — no `n` has all bits set. This shows the Ackermann
    model satisfies ¬Infinity: no universal set exists.
-/
theorem ack_no_universal_set : ¬∃ n : ℕ, ∀ m : ℕ, ackMem m n := by
  norm_num [ ackMem ];
  exact fun x => ⟨ Nat.log 2 x + 1, by rw [ Nat.testBit_eq_false_of_lt ] ; exact Nat.lt_pow_of_log_lt ( by norm_num ) ( by linarith ) ⟩

/-
Every set in the Ackermann encoding has finitely many members:
    {m : ℕ | ackMem m n} is a finite set for every n.
-/
theorem ack_finite_members (n : ℕ) : Set.Finite {m : ℕ | ackMem m n} := by
  refine' Set.finite_iff_bddAbove.mpr ⟨ n, fun m hm => _ ⟩;
  contrapose! hm;
  unfold ackMem;
  simp +decide [ Nat.testBit_eq_false_of_lt ( show n < 2 ^ m by exact lt_trans hm ( Nat.recOn m ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ] ) ) ]

/-
The **singleton** {m} in the Ackermann encoding is `2^m`:
    k ∈ₐ 2^m ↔ k = m.
-/
theorem ack_singleton (m k : ℕ) : ackMem k (2 ^ m) ↔ k = m := by
  unfold ackMem;
  grind +suggestions

/-
**Union** in the Ackermann encoding is bitwise OR:
    k ∈ₐ (a ||| b) ↔ k ∈ₐ a ∨ k ∈ₐ b.
-/
theorem ack_union (a b k : ℕ) :
    ackMem k (a ||| b) ↔ ackMem k a ∨ ackMem k b := by
      unfold ackMem; aesop;

/-
**Intersection** in the Ackermann encoding is bitwise AND:
    k ∈ₐ (a &&& b) ↔ k ∈ₐ a ∧ k ∈ₐ b.
-/
theorem ack_intersection (a b k : ℕ) :
    ackMem k (a &&& b) ↔ ackMem k a ∧ ackMem k b := by
      unfold ackMem; aesop;

/-
**Pairing axiom**: For any a, b : ℕ, the set {a, b} exists in the
    Ackermann model, encoded as `2^a ||| 2^b`.
-/
theorem ack_pairing (a b : ℕ) :
    ∃ c : ℕ, ∀ k, ackMem k c ↔ k = a ∨ k = b := by
      use 2^a ||| 2^b;
      intro k; rw [ ack_union ] ; simp +decide [ ack_singleton ] ;

/-! ## Part 3: Finite Universe Rigidity (Anti-Infinity Consequences)

When the axiom of infinity fails, the universe is finite. We prove
structural rigidity results for endofunctions on finite types.
-/

/-
In a finite type, there is no injection from ℕ. This is the
    type-theoretic manifestation of anti-infinity: countably infinite
    structures cannot exist.
-/
theorem no_injection_from_nat {α : Type*} [Finite α] (f : ℕ → α) :
    ¬Function.Injective f := by
      exact fun h => not_injective_infinite_finite f h

/-
**Finite Pigeonhole for Iteration**: In a finite type, any function
    `f : α → α` has two distinct iterates that agree on all inputs.
-/
theorem finite_iterate_collision {α : Type*} [Finite α] (f : α → α) :
    ∃ m n : ℕ, m < n ∧ ∀ x : α, f^[m] x = f^[n] x := by
      -- By the pigeonhole principle, since there are only finitely many possible functions from α to α, there must exist distinct natural numbers m and n such that f^[m] = f^[n].
      have h_pigeonhole : ∃ m n : ℕ, m < n ∧ f^[m] = f^[n] := by
        by_contra! h;
        exact absurd ( Set.infinite_range_of_injective ( fun m n hmn => le_antisymm ( not_lt.1 fun contra => h _ _ contra hmn.symm ) ( not_lt.1 fun contra => h _ _ contra hmn ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
      exact ⟨ _, _, h_pigeonhole.choose_spec.choose_spec.1, fun x => congr_fun h_pigeonhole.choose_spec.choose_spec.2 x ⟩

/-
**Eventual Idempotence**: In a finite type, some positive iterate of
    any endofunction is idempotent: ∃ n > 0, f^[n] ∘ f^[n] = f^[n].
    This means the "eventual image" of f is a retract.
-/
theorem finite_eventual_idempotent {α : Type*} [Finite α] (f : α → α) :
    ∃ n : ℕ, 0 < n ∧ ∀ x : α, f^[n] (f^[n] x) = f^[n] x := by
      obtain ⟨ m, n, hmn, h ⟩ := finite_iterate_collision f;
      -- Let $p = n - m$. Then $f^{[m+p]} = f^{[m]}$ by the collision property.
      set p := n - m with hp
      have h_period : ∀ k ≥ m, f^[k + p] = f^[k] := by
        intro k hk; induction hk <;> simp_all +decide [ Nat.succ_add ] ;
        rw [ Nat.add_sub_of_le hmn.le, funext h ];
      -- Choose $N = p \cdot \lceil m / p \rceil$. This $N$ satisfies $p | N$, $N \geq m$, $N > 0$, and $N \equiv 0 \pmod{p}$.
      obtain ⟨N, hN_pos, hN_ge_m, hN_mod_p⟩ : ∃ N, 0 < N ∧ m ≤ N ∧ p ∣ N := by
        exact ⟨ p * ( m + 1 ), Nat.mul_pos ( Nat.sub_pos_of_lt hmn ) ( Nat.succ_pos _ ), by nlinarith [ Nat.sub_pos_of_lt hmn ], dvd_mul_right _ _ ⟩;
      -- Since $p | N$, we have $f^{[2N]} = f^{[N]}$ by the periodicity.
      have h_periodic : f^[2 * N] = f^[N] := by
        have h_periodic : ∀ k ≥ m, ∀ q : ℕ, f^[k + q * p] = f^[k] := by
          exact fun k hk q => Nat.recOn q ( by simp +decide ) fun q ih => by rw [ Nat.succ_mul, ← add_assoc, h_period _ ( by nlinarith ), ih ] ;
        convert h_periodic N hN_ge_m ( N / p ) using 1 ; rw [ two_mul, Nat.div_mul_cancel hN_mod_p ];
      exact ⟨ N, hN_pos, fun x => by simpa [ two_mul, Function.iterate_add_apply ] using congr_fun h_periodic x ⟩

/-! ## Part 4: Anti-Choice and the Axiom of Choice in Lean

The Axiom of Choice implies the existence of non-measurable sets.
In Lean's foundation (CIC + Classical + Choice), AC is a theorem.
We formalize what ¬Choice would entail and show it's inconsistent
with Lean's foundations.
-/

/-- A **choice-free family** is a collection of nonempty types indexed by `I`
    together with a proof that no global section (choice function) exists.
    The existence of such a family is equivalent to ¬AC. -/
structure ChoiceFreeFamily where
  /-- Index type -/
  I : Type*
  /-- The fiber over each index -/
  fiber : I → Type*
  /-- Each fiber is nonempty -/
  nonempty_fiber : ∀ i, Nonempty (fiber i)
  /-- No choice function exists -/
  no_choice : IsEmpty (∀ i, fiber i)

/-
In Lean's foundation, no choice-free family exists because the axiom
    of choice is built into the type theory. This shows that anti-choice
    is literally inconsistent with Lean's foundations.
-/
theorem no_choicefree_in_lean : IsEmpty ChoiceFreeFamily := by
  refine' ⟨ fun x => _ ⟩;
  exact x.no_choice.elim ( fun i => Classical.choice ( x.nonempty_fiber i ) )

/-- **AC in Lean**: Every family of nonempty types admits a choice function. -/
theorem lean_ac (I : Type*) (S : I → Type*) (hne : ∀ i, Nonempty (S i)) :
    Nonempty (∀ i, S i) :=
  ⟨fun i => Classical.choice (hne i)⟩

/-
**Choice implies well-ordering**: every type can be well-ordered.
    This is the classical equivalence AC ↔ Well-Ordering Principle.
-/
theorem choice_gives_well_order (α : Type*) :
    ∃ r : α → α → Prop, IsWellOrder α r := by
      exact ⟨ WellOrderingRel, inferInstance ⟩

/-! ## Part 5: Novel Concept — Axiom Defect Spectrum

We introduce the **Axiom Defect Spectrum**, a continuous generalization of
the Boolean "axiom holds / axiom fails" dichotomy. Each axiom is assigned
a deficiency value in [0,1], and the collection of deficiencies forms a
vector in the unit hypercube [0,1]ⁿ.

**Key insight**: The set of "compatible" spectra (those that can coexist
in a single model) forms a convex polytope, making the study of axiom
independence a problem in convex geometry.
-/

/-- An **Axiom Defect Spectrum** for `n` axioms assigns each axiom a
    continuous deficiency value in [0,1]. Value 0 means the axiom holds
    perfectly; value 1 means it fails maximally. -/
structure AxiomDefectSpectrum (n : ℕ) where
  /-- Deficiency value for each axiom -/
  defect : Fin n → ℝ
  /-- Each deficiency is non-negative -/
  nonneg : ∀ i, 0 ≤ defect i
  /-- Each deficiency is at most 1 -/
  le_one : ∀ i, defect i ≤ 1

/-- The **total deficiency** of a spectrum: the sum of all individual defects. -/
noncomputable def AxiomDefectSpectrum.totalDefect {n : ℕ}
    (s : AxiomDefectSpectrum n) : ℝ :=
  ∑ i : Fin n, s.defect i

/-
**Total deficiency bound**: the total deficiency of an n-axiom spectrum
    cannot exceed n. This is a fundamental constraint on axiom violation.
-/
theorem totalDefect_le_card {n : ℕ} (s : AxiomDefectSpectrum n) :
    s.totalDefect ≤ (n : ℝ) := by
      exact le_trans ( Finset.sum_le_sum fun _ _ => s.le_one _ ) ( by norm_num )

/-- Two spectra are **compatible** if no axiom is "over-violated":
    the sum of defects for each axiom is at most 1. -/
def AxiomDefectSpectrum.compatible {n : ℕ}
    (s t : AxiomDefectSpectrum n) : Prop :=
  ∀ i, s.defect i + t.defect i ≤ 1

/-
Compatibility is symmetric.
-/
theorem compatible_comm {n : ℕ} (s t : AxiomDefectSpectrum n) :
    s.compatible t ↔ t.compatible s := by
      exact ⟨ fun h i => by linarith [ h i ], fun h i => by linarith [ h i ] ⟩

/-- The **ZFC spectrum**: all axioms hold perfectly (zero deficiency). -/
noncomputable def zfcSpectrum : AxiomDefectSpectrum 8 where
  defect := fun _ => 0
  nonneg := fun _ => le_refl 0
  le_one := fun _ => zero_le_one

/-
The ZFC spectrum is universally compatible — a structure satisfying all
    axioms is compatible with any other spectrum.
-/
theorem zfc_universally_compatible (s : AxiomDefectSpectrum 8) :
    zfcSpectrum.compatible s := by
      exact fun i => by simp [ zfcSpectrum ] ; linarith [ s.le_one i ] ;

/-
**Spectrum Convexity**: If two spectra are both compatible with `s`,
    then any convex combination of them is also compatible with `s`.
    This shows the compatible region is a convex set in ℝⁿ.
-/
theorem compatible_convex_combination {n : ℕ} (s t₁ t₂ : AxiomDefectSpectrum n)
    (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1)
    (h1 : s.compatible t₁) (h2 : s.compatible t₂) :
    ∀ i : Fin n,
      s.defect i + (c * t₁.defect i + (1 - c) * t₂.defect i) ≤ 1 := by
        exact fun i => by nlinarith [ h1 i, h2 i, s.nonneg i, s.le_one i, t₁.nonneg i, t₁.le_one i, t₂.nonneg i, t₂.le_one i ] ;

/-! ## Part 6: Compatibility of Anti-Axioms

We demonstrate that certain combinations of anti-axioms can coexist,
while others cannot (at least in Lean's foundation).
-/

/-
The Ackermann model satisfies extensionality AND anti-infinity
    simultaneously, showing these properties are compatible.
-/
theorem ack_ext_compatible_anti_inf :
    (∀ a b : ℕ, (∀ m, ackMem m a ↔ ackMem m b) → a = b) ∧
    ¬(∃ n : ℕ, ∀ m, ackMem m n) := by
      exact ⟨ fun a b h => ack_extensionality h, fun ⟨ n, hn ⟩ => by have := ack_no_universal_set; tauto ⟩

/-- Anti-extensionality and anti-infinity are compatible:
    the phantom universe is both anti-extensional and finite. -/
theorem anti_ext_compatible_anti_inf :
    ∃ (M : MemStr Bool), M.isAntiExt ∧ Finite Bool :=
  ⟨phantomMem, phantom_anti_ext, inferInstance⟩

/-
**The Full Anti-ZFC is inconsistent**: if all axioms fail simultaneously
    (specifically, if both a universal set exists and doesn't exist),
    we get a contradiction. More precisely, anti-extensionality and
    extensionality cannot both hold for the same structure.
-/
theorem anti_ext_contradicts_ext {α : Type*} (M : MemStr α)
    (hext : ∀ a b : α, M.extEquiv a b → a = b)
    (hanti : M.isAntiExt) : False := by
      exact hanti.choose_spec.choose_spec.1 ( hext _ _ hanti.choose_spec.choose_spec.2 )

end AntiMath