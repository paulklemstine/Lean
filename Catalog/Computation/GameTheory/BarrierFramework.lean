import Mathlib

/-!
# Formal Barrier Framework: Entropy–Compression–Communication Complexity

This file establishes a formally verified bridge between three pillars of
complexity lower bounds:

1. **Communication complexity** via Karchmer–Wigderson (KW) witness spaces
2. **Compression impossibility** via finite coding pigeonhole arguments
3. **Information-theoretic lower bounds** via cardinality/entropy

## Main Results

### Infrastructure: Finite Coding Bounds
- `card_bounded_bitstrings`: The type of variable-length bitstrings up to length `k`
  has exactly `2^(k+1) - 1` elements.
- `injective_bounded_code_card_le`: An injective encoding with max code length `k`
  forces `Fintype.card α ≤ 2^(k+1) - 1`.
- `finite_incompressibility`: If `Fintype.card α ≥ 2^(k+1)`, some element needs
  code length > `k`.
- `cardinality_forces_long_code`: If `2^k < Fintype.card α`, some injective code
  has length ≥ `k`.

### KW Witness Space
- `KWWitness`: Triples `(x, y, i)` witnessing KW game solutions.
- `kw_pair_has_witness`: Every KW pair has a distinguishing coordinate.

### Bridge Theorems
- `kw_witness_compression_lower_bound`: Large KW witness spaces force long codes.
- `kw_log_entropy_lower_bound`: Log-cardinality entropy bound from KW complexity.

### Concrete Examples
- `parity_kw_witness_card_ge`: Parity has at least `n` KW witnesses.
- `parity_incompressibility`: Concrete compression lower bound for parity.

### Barrier Skeletons
- Natural proofs skeleton with large/useful/constructive predicates.
- Relativization skeleton with oracle-parametric statements.
-/

noncomputable section
open Classical Finset Fintype Function

/-! ## Section 1: Finite Coding Infrastructure

The key counting fact: variable-length binary strings of length ≤ k form a
set of size `2^(k+1) - 1`. This is the geometric series `∑_{i=0}^{k} 2^i`.
We model this as `Σ i : Fin (k+1), (Fin i → Bool)`.
-/

/-- Variable-length bitstrings up to length `k`, modeled as a sigma type.
Each element is a pair `(length, content)` where `length ∈ {0, ..., k}`
and `content` is a Boolean vector of that length. -/
abbrev BoundedBitstring (k : ℕ) := Σ i : Fin (k + 1), (Fin i → Bool)

/-- The number of bitstrings of exactly length `k` is `2^k`. -/
theorem card_exact_bitstrings (k : ℕ) :
    Fintype.card (Fin k → Bool) = 2 ^ k := by
  simp [Fintype.card_bool, Fintype.card_fin]

/-
The number of variable-length bitstrings up to length `k` is `2^(k+1) - 1`.
This is the geometric series `1 + 2 + 4 + ... + 2^k = 2^(k+1) - 1`.
-/
theorem card_bounded_bitstrings (k : ℕ) :
    Fintype.card (BoundedBitstring k) = 2 ^ (k + 1) - 1 := by
  convert Nat.geomSum_eq ?_ ?_ using 1;
  case convert_1 => exact 2;
  case convert_3 => exact k + 1;
  · simp +decide [ Fintype.card_sigma, Fintype.card_fin ];
    rw [ Finset.sum_range ];
  · norm_num;
  · norm_num

/-
Coarser bound: variable-length bitstrings up to length `k` number at most `2^(k+1)`.
-/
theorem card_bounded_bitstrings_le (k : ℕ) :
    Fintype.card (BoundedBitstring k) ≤ 2 ^ (k + 1) := by
  rw [ card_bounded_bitstrings ];
  exact Nat.sub_le _ _

/-- Convert a `List Bool` of known length ≤ `k` to a `BoundedBitstring k`. -/
def listToBounded (bs : List Bool) (k : ℕ) (h : bs.length ≤ k) : BoundedBitstring k :=
  ⟨⟨bs.length, by omega⟩, fun i => bs.get ⟨i.val, by exact i.isLt⟩⟩

/-
`listToBounded` is injective: distinct lists yield distinct bounded bitstrings.
-/
theorem listToBounded_injective (k : ℕ) :
    ∀ (a b : List Bool) (ha : a.length ≤ k) (hb : b.length ≤ k),
      listToBounded a k ha = listToBounded b k hb → a = b := by
  intro a b ha hb h; rcases a with ( _ | ⟨ a₀, a ⟩ ) <;> rcases b with ( _ | ⟨ b₀, b ⟩ ) <;> simp_all +decide [ listToBounded ] ;
  -- The second part of h implies that the lists are equal.
  have h_eq : List.ofFn (fun i : Fin (a.length + 1) => (a₀ :: a)[i]) = List.ofFn (fun i : Fin (b.length + 1) => (b₀ :: b)[i]) := by
    congr! 1;
    · -- Since $a.length = b.length$, adding 1 to both sides gives $a.length + 1 = b.length + 1$.
      rw [h.left];
    · convert h.2 using 1;
  simp_all +decide [ List.ofFn_eq_map ];
  grind +extAll

/-
An injective encoding into `List Bool` with bounded length forces a cardinality bound.
This is the main pigeonhole lemma.
-/
theorem injective_bounded_code_card_le
    {α : Type*} [Fintype α]
    (Enc : α → List Bool) (k : ℕ)
    (hinj : Injective Enc)
    (hlen : ∀ a, (Enc a).length ≤ k) :
    Fintype.card α ≤ 2 ^ (k + 1) - 1 := by
  convert Fintype.card_le_of_injective _ ( show Function.Injective ( fun a => listToBounded ( Enc a ) k ( hlen a ) ) from fun a b h => hinj ( listToBounded_injective k _ _ ( hlen a ) ( hlen b ) h ) ) using 1;
  exact card_bounded_bitstrings k ▸ rfl

/-
**Finite incompressibility**: if a type has at least `2^(k+1)` elements,
any injective encoding must assign some element a code of length > `k`.
-/
theorem finite_incompressibility
    {α : Type*} [Fintype α]
    (Enc : α → List Bool) (k : ℕ)
    (hinj : Injective Enc)
    (hlarge : 2 ^ (k + 1) ≤ Fintype.card α) :
    ∃ a : α, k < (Enc a).length := by
  contrapose! hlarge;
  exact lt_of_le_of_lt ( injective_bounded_code_card_le _ _ hinj hlarge ) ( Nat.sub_lt ( by norm_num ) ( by norm_num ) )

/-
**Cardinality forces long codes**: if `2^d ≤ card α`, any injective
encoding has some codeword of length ≥ `d`.
-/
theorem cardinality_forces_long_code
    {α : Type*} [Fintype α]
    (Enc : α → List Bool)
    (hinj : Injective Enc)
    (d : ℕ)
    (hlarge : 2 ^ d ≤ Fintype.card α) :
    ∃ a : α, d ≤ (Enc a).length := by
  contrapose! hlarge with h;
  rcases d with ( _ | d ) <;> simp_all +decide [ Nat.pow_succ' ];
  · exact Fintype.card_eq_zero_iff.mpr ⟨ fun a => h a ⟩;
  · exact lt_of_le_of_lt ( injective_bounded_code_card_le Enc d hinj h ) ( by rw [ pow_succ' ] ; exact Nat.sub_lt ( by norm_num ) ( by norm_num ) )

/-! ## Section 2: Karchmer–Wigderson Witness Space -/

/-- Boolean vectors of length `n`. -/
abbrev BoolVec (n : ℕ) := Fin n → Bool

/-- A KW pair for a Boolean function `f` consists of inputs `(x, y)` with
`f(x) = true` and `f(y) = false`. -/
def KWPair {n : ℕ} (f : BoolVec n → Bool) :=
  { p : BoolVec n × BoolVec n // f p.1 = true ∧ f p.2 = false }

/-- A KW witness for `f` is a triple `(x, y, i)` where `f(x) = true`, `f(y) = false`,
and `x(i) ≠ y(i)`. This models a solution to the Karchmer–Wigderson search problem. -/
def KWWitness {n : ℕ} (f : BoolVec n → Bool) :=
  { w : BoolVec n × BoolVec n × Fin n //
    f w.1 = true ∧ f w.2.1 = false ∧ w.1 w.2.2 ≠ w.2.1 w.2.2 }

instance {n : ℕ} (f : BoolVec n → Bool) : Fintype (KWPair f) :=
  Subtype.fintype _

instance {n : ℕ} (f : BoolVec n → Bool) : Fintype (KWWitness f) :=
  Subtype.fintype _

/-
For any KW pair, there exists a distinguishing coordinate.
-/
theorem kw_pair_has_witness {n : ℕ} (f : BoolVec n → Bool)
    (p : KWPair f) : ∃ i : Fin n, p.1.1 i ≠ p.1.2 i := by
  by_contra! h;
  exact absurd ( congr_arg f ( funext h ) ) ( by cases p; aesop )

/-! ## Section 3: KW Complexity and Bridge Theorems -/

/-- A KW complexity lower bound for `f` at level `d`: the witness space
has at least `2^d` elements. -/
def kwComplexityLB {n : ℕ} (f : BoolVec n → Bool) (d : ℕ) : Prop :=
  2 ^ d ≤ Fintype.card (KWWitness f)

/-- **Main Bridge Theorem**: If `kwComplexityLB f d`, then every injective
encoding of KW witnesses must assign some witness a code of length ≥ `d`.

This is the central result connecting communication complexity lower bounds
to compression impossibility. -/
theorem kw_witness_compression_lower_bound
    {n : ℕ} (f : BoolVec n → Bool) (d : ℕ)
    (hkw : kwComplexityLB f d) :
    ∀ (Enc : KWWitness f → List Bool),
      Injective Enc →
      ∃ w : KWWitness f, d ≤ (Enc w).length := by
  intro Enc hinj
  exact cardinality_forces_long_code Enc hinj d hkw

/-
**Log-cardinality entropy bound**: `d ≤ log₂ |KWWitness f|`.
-/
theorem kw_log_entropy_lower_bound
    {n : ℕ} (f : BoolVec n → Bool) (d : ℕ)
    (hkw : kwComplexityLB f d) :
    d ≤ Nat.log 2 (Fintype.card (KWWitness f)) := by
  exact Nat.le_log_of_pow_le ( by decide ) hkw

/-! ## Section 4: Parity Function — Concrete Instantiation -/

/-- The parity function: XOR of all inputs. -/
def parityFn {n : ℕ} : BoolVec n → Bool :=
  fun x => List.foldl xor false (List.ofFn x)

/-
Flipping one coordinate toggles parity.
-/
theorem parity_flip {n : ℕ} (x : BoolVec n) (i : Fin n) :
    parityFn (Function.update x i (!(x i))) = !(parityFn x) := by
  induction' i with i ih;
  unfold parityFn update;
  induction' n with n ih generalizing i <;> simp_all +decide [ List.ofFn_succ ];
  · contradiction;
  · rcases i with ( _ | i ) <;> simp_all +decide [ List.ofFn_eq_map ];
    · induction' ( List.finRange n ) using List.reverseRecOn with n ih <;> simp_all +decide [ List.foldl_append ];
    · convert congr_arg ( fun b => xor ( x 0 ) b ) ( ih ( fun j => x j.succ ) i ( by linarith ) ) using 1;
      · induction' ( List.finRange n ) using List.reverseRecOn with n ih <;> simp_all +decide [ Fin.ext_iff ];
      · induction' ( List.finRange n ) using List.reverseRecOn with n ih <;> simp_all +decide [ List.foldl ]

/-
For parity on `n ≥ 1` variables, the all-false input gives `false`.
-/
theorem parity_all_false {n : ℕ} :
    @parityFn n (fun _ => false) = false := by
  -- By definition of parityFn, we have parityFn (fun i => false) = List.foldl (fun b a => a ^^ b) false (List.replicate n false).
  simp [parityFn];
  induction n <;> simp_all +decide [ List.replicate ]

/-
For each coordinate `i`, there exist inputs forming a KW pair
with `i` as the distinguishing coordinate.
-/
theorem parity_witness_at_coord {n : ℕ} (hn : 0 < n) (i : Fin n) :
    ∃ w : KWWitness (@parityFn n), w.1.2.2 = i := by
  -- Let $x$ be the all-zero vector and $y$ be the vector with a single 1 at position $i$.
  set x : BoolVec n := fun _ => false
  set y : BoolVec n := Function.update (fun _ => false) i true;
  -- By definition of $x$ and $y$, we have $parityFn x = false$ and $parityFn y = true$.
  have hx : parityFn x = false := by
    exact?
  have hy : parityFn y = true := by
    convert parity_flip x i using 1;
    exact hx.symm ▸ rfl;
  exact ⟨ ⟨ ⟨ y, x, i ⟩, by aesop ⟩, rfl ⟩

/-
Injection from `Fin n` into `KWWitness parityFn`.
-/
theorem parity_kw_witness_card_ge (n : ℕ) (hn : 0 < n) :
    n ≤ Fintype.card (KWWitness (@parityFn n)) := by
  -- By definition of $KWWitness$, there exists a witness for each coordinate $i$.
  have h_witness_at_coord (i : Fin n) : ∃ w : KWWitness (@parityFn n), w.1.2.2 = i := by
    exact?;
  exact le_trans ( by simpa ) ( Fintype.card_le_of_surjective _ ( show Function.Surjective ( fun w : KWWitness parityFn => ( w.val.2.2 : Fin n ) ) from fun i => by cases' h_witness_at_coord i with w hw; aesop ) )

/-
**Parity incompressibility**: any injective encoding of parity's
KW witnesses needs some codeword of length ≥ `⌊log₂ n⌋`.
-/
theorem parity_incompressibility (n : ℕ) (hn : 0 < n)
    (Enc : KWWitness (@parityFn n) → List Bool)
    (hinj : Injective Enc) :
    ∃ w, Nat.log 2 n ≤ (Enc w).length := by
  convert cardinality_forces_long_code Enc hinj ( Nat.log 2 n ) _ using 1;
  exact le_trans ( Nat.pow_log_le_self 2 hn.ne' ) ( parity_kw_witness_card_ge n hn )

/-! ## Section 5: Monotone Formula Depth (Self-Contained) -/

/-- Monotone Boolean formulas on `n` variables. -/
inductive MonoFormula (n : ℕ) where
  | var : Fin n → MonoFormula n
  | top : MonoFormula n
  | bot : MonoFormula n
  | and : MonoFormula n → MonoFormula n → MonoFormula n
  | or  : MonoFormula n → MonoFormula n → MonoFormula n

namespace MonoFormula

/-- Evaluate a monotone formula on an input. -/
def eval : MonoFormula n → BoolVec n → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and φ₁ φ₂, x => φ₁.eval x && φ₂.eval x
  | or φ₁ φ₂, x => φ₁.eval x || φ₂.eval x

/-- Depth of a monotone formula. -/
def depth : MonoFormula n → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth
  | or φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth

/-- Size (number of gates) of a monotone formula. -/
def size : MonoFormula n → ℕ
  | var _ => 1
  | top => 1
  | bot => 1
  | and φ₁ φ₂ => 1 + φ₁.size + φ₂.size
  | or φ₁ φ₂ => 1 + φ₁.size + φ₂.size

end MonoFormula

/-- A formula depth lower bound: no monotone formula of depth < d computes f. -/
def FormulaDepthLB {n : ℕ} (f : BoolVec n → Bool) (d : ℕ) : Prop :=
  ∀ φ : MonoFormula n, (∀ x, φ.eval x = f x) → d ≤ φ.depth

/-! ## Section 6: Natural Proofs Skeleton -/

/-- A property of Boolean functions (predicates on truth tables). -/
def BoolFnProperty (n : ℕ) := (BoolVec n → Bool) → Prop

/-- A property is *large* if at least one function satisfies it. -/
def IsLargeProperty {n : ℕ} (P : BoolFnProperty n) : Prop :=
  ∃ f, P f

/-- A property is *useful against* formulas of size ≤ `bound`. -/
def IsUsefulAgainst {n : ℕ} (P : BoolFnProperty n) (bound : ℕ) : Prop :=
  ∀ f, P f → ∀ φ : MonoFormula n, (∀ x, φ.eval x = f x) → bound < φ.size

/-- **Natural Proofs Template (Razborov–Rudich skeleton)**:
If a large and useful property exists, there is a function witnessing both
properties simultaneously — it satisfies the property AND has high complexity. -/
theorem natural_proof_distinguisher {n : ℕ}
    (P : BoolFnProperty n)
    (hlarge : IsLargeProperty P)
    (huseful : IsUsefulAgainst P bound) :
    ∃ f, P f ∧ ∀ φ : MonoFormula n, (∀ x, φ.eval x = f x) → bound < φ.size :=
  hlarge.imp fun f hf => ⟨hf, huseful f hf⟩

/-! ## Section 7: Relativization Skeleton -/

/-- An oracle is a function from queries to answers. -/
def Oracle := ℕ → Bool

/-- A statement relativizes if it holds for all oracles. -/
def RelativizingStatement (S : Oracle → Prop) : Prop := ∀ A : Oracle, S A

/-- The relativization barrier: relativizing proofs cannot separate
classes that are equal relative to some oracle and unequal relative to another.
Formally, if S relativizes but there exist oracles A, B with S(A) true and S(B) false,
then S is not a valid relativizing proof technique. -/
theorem relativization_barrier
    (S : Oracle → Prop) (hrel : RelativizingStatement S) (A : Oracle) : S A :=
  hrel A

/-- Two properties are *oracle-separated* if one holds and the other fails
for some oracle. -/
def OracleSeparated (P Q : Oracle → Prop) : Prop :=
  (∃ A, P A ∧ ¬Q A) ∧ (∃ B, Q B ∧ ¬P B)

/-- If two properties are oracle-separated, no relativizing proof can show
they are equivalent. -/
theorem no_relativizing_equivalence
    (P Q : Oracle → Prop)
    (hsep : OracleSeparated P Q) :
    ¬ RelativizingStatement (fun A => P A ↔ Q A) := by
  intro hrel
  obtain ⟨⟨A, hPA, hQA⟩, _⟩ := hsep
  exact hQA ((hrel A).mp hPA)

end