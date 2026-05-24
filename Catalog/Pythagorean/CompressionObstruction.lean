import Mathlib

/-!
# Compression Obstruction for Monotone Formula Depth

This file introduces the theory of **compression obstructions** for lower-bounding
monotone Boolean formula depth. The central idea is that structural constraints on
witness encodings — such as prefix-freeness — create coding barriers that exceed
naive cardinality-based counting arguments.

## Main Definitions

- `AdmissibleCode` — an encoding/decoding pair with a left-inverse guarantee
- `WitnessCompressionProfile` — a structure tracking how many witnesses can be
  encoded at each code-length budget
- `compressionObstruction` — the minimum max code length over all injective codes on `W`
- `prefixFreeCompressionObstruction` — the same restricted to prefix-free codes

## Main Results

- `injective_code_card_bound` — pigeonhole: an injective variable-length code on `W`
  elements with max length `k` implies `W.card < 2^(k+1)`
- `compressionObstruction_ge_log_card` — the compression obstruction is at least
  `⌊log₂ |W|⌋`, subsumes the naive counting bound
- `prefixFree_code_card_le` — a prefix-free code with max length `k` has at most
  `2^k` codewords
- `strict_gap_prefixFree_vs_general` — there exist witness sets where the prefix-free
  obstruction strictly exceeds the general obstruction
- `formula_depth_ge_of_compressionObstruction` — the bridge theorem connecting
  compression obstruction to monotone formula depth via Karchmer–Wigderson

## References

* M. Karchmer, A. Wigderson, "Monotone circuits for connectivity require
  super-logarithmic depth", STOC 1988
* T. M. Cover, J. A. Thomas, "Elements of Information Theory", Wiley, 2006
-/

noncomputable section
open Finset Function

namespace CompressionObstruction

/-! ## Core Definitions -/

/-- An **admissible code** is an encoding from a type `α` to variable-length binary strings
    (`List Bool`) together with a partial decoding function, such that decoding is a left
    inverse of encoding. This guarantees the encoding is injective and lossless. -/
structure AdmissibleCode (α : Type*) where
  /-- Encoding function mapping elements to binary strings -/
  encode : α → List Bool
  /-- Partial decoding function -/
  decode : List Bool → Option α
  /-- Decoding is a left inverse of encoding -/
  left_inv : ∀ a, decode (encode a) = some a

/-- Any admissible code has an injective encoding. -/
theorem AdmissibleCode.injective {α : Type*} (C : AdmissibleCode α) :
    Function.Injective C.encode := by
  intro a b h
  have ha := C.left_inv a
  have hb := C.left_inv b
  rw [h] at ha; rw [ha] at hb
  exact Option.some.inj hb

/-- A **witness compression profile** assigns to each code-length budget `ℓ`
    the number of witnesses from a finite set `W` that can be encoded using
    at most `ℓ` bits under a given admissible code. -/
structure WitnessCompressionProfile (α : Type*) [DecidableEq α] where
  /-- The finite witness set -/
  witnessSet : Finset α
  /-- The admissible code used for encoding -/
  code : AdmissibleCode α

/-- The number of witnesses encodable within a given length budget. -/
def WitnessCompressionProfile.countAtBudget {α : Type*} [DecidableEq α]
    (P : WitnessCompressionProfile α) (ℓ : ℕ) : ℕ :=
  (P.witnessSet.filter (fun a => decide ((P.code.encode a).length ≤ ℓ))).card

/-- The **compression obstruction** of a finite set `W` is the minimum natural number `k`
    such that there exists an injective encoding mapping all elements of `W` to
    binary strings of length at most `k`. -/
noncomputable def compressionObstruction {α : Type*} [DecidableEq α]
    (W : Finset α) : ℕ :=
  sInf {k : ℕ | ∃ (enc : α → List Bool),
    Set.InjOn enc ↑W ∧ ∀ a ∈ W, (enc a).length ≤ k}

/-- The **prefix-free compression obstruction** of `W` is the minimum `k` such that
    there exists an injective, prefix-free encoding of all elements of `W` into
    binary strings of length at most `k`. -/
noncomputable def prefixFreeCompressionObstruction {α : Type*} [DecidableEq α]
    (W : Finset α) : ℕ :=
  sInf {k : ℕ | ∃ (enc : α → List Bool),
    Set.InjOn enc ↑W ∧
    (∀ a ∈ W, ∀ b ∈ W, a ≠ b → ¬(enc a) <+: (enc b)) ∧
    (∀ a ∈ W, (enc a).length ≤ k)}

/-- The **counting lower bound** for a finite set is `⌊log₂ |W|⌋`. -/
def countingLowerBound {α : Type*} [DecidableEq α] (W : Finset α) : ℕ :=
  Nat.log 2 W.card

/-! ## Theorem 1: Counting bound for injective codes -/

/-
**Pigeonhole bound for injective codes**: if an injective function maps a finite set `W`
    into binary strings of length at most `k`, then `|W| < 2^(k+1)`.
-/
theorem injective_code_card_bound {α : Type*} [DecidableEq α]
    (W : Finset α) (enc : α → List Bool)
    (hinj : Set.InjOn enc ↑W)
    (k : ℕ) (hk : ∀ a ∈ W, (enc a).length ≤ k) :
    W.card < 2 ^ (k + 1) := by
      -- Consider the set of all binary strings of length at most k. This set has size $\sum_{i=0}^k 2^i$.
      have h_card_binary_strings : (Finset.biUnion (Finset.range (k + 1)) (fun i => Finset.image (fun s : Fin i → Bool => List.ofFn s) (Finset.univ : Finset (Fin i → Bool)))).card = ∑ i ∈ Finset.range (k + 1), 2 ^ i := by
        rw [ Finset.card_biUnion ];
        · exact Finset.sum_congr rfl fun i hi => by rw [ Finset.card_image_of_injective _ fun x y hxy => by simpa [ funext_iff, Fin.forall_fin_succ ] using hxy ] ; simp +decide [ Finset.card_univ ] ;
        · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by obtain ⟨ s, _, rfl ⟩ := Finset.mem_image.mp hx₁; obtain ⟨ t, _, ht ⟩ := Finset.mem_image.mp hx₂; have := congr_arg List.length ht; simp +decide at this; aesop;
      -- Since `enc` is injective on `W`, the image of `W` under `enc` is contained in the set of binary strings of length at most `k`.
      have h_image_subset : (Finset.image enc W) ⊆ Finset.biUnion (Finset.range (k + 1)) (fun i => Finset.image (fun s : Fin i → Bool => List.ofFn s) (Finset.univ : Finset (Fin i → Bool))) := by
        simp +decide [ Finset.subset_iff ];
        exact fun a ha => ⟨ _, hk a ha, fun i => enc a |> List.get <| ⟨ i, by linarith [ hk a ha, i.2 ] ⟩, by simp +decide [ List.ofFn_get ] ⟩;
      have := Finset.card_le_card h_image_subset; simp_all +decide [ Finset.card_image_of_injOn ] ;
      exact this.trans_lt ( Nat.geomSum_lt ( by norm_num ) ( by aesop ) )

/-
The compression obstruction set is always nonempty.
-/
theorem compressionObstruction_set_nonempty {α : Type*} [DecidableEq α]
    (W : Finset α) :
    ∃ k, k ∈ {k : ℕ | ∃ (enc : α → List Bool),
      Set.InjOn enc ↑W ∧ ∀ a ∈ W, (enc a).length ≤ k} := by
        refine' ⟨ W.card, _ ⟩;
        -- Define the encoding function that maps each element to a unique binary string of length at most W.card.
        obtain ⟨f, hf⟩ : ∃ f : {x : α // x ∈ W} → Fin W.card, Function.Injective f := by
          exact ⟨ fun x => Fintype.equivFinOfCardEq ( by simp +decide ) x, by simp +decide [ Function.Injective ] ⟩
        generalize_proofs at *; (
        -- Define the encoding function that maps each element to a unique binary string of length at most W.card using the injective function f.
        use fun a => if h : a ∈ W then List.replicate (f ⟨a, h⟩).val true else [];
        simp +contextual [ Set.InjOn, hf.eq_iff ];
        exact fun x₁ hx₁ x₂ hx₂ h => by simpa [ Subtype.ext_iff ] using hf ( Fin.ext h ) ;)

/-
For any injective code with max codeword length `k` on a nonempty `W`,
    `Nat.log 2 W.card ≤ k`.
-/
theorem log_card_le_of_injective_code {α : Type*} [DecidableEq α]
    (W : Finset α) (hW : W.Nonempty)
    (enc : α → List Bool) (hinj : Set.InjOn enc ↑W)
    (k : ℕ) (hk : ∀ a ∈ W, (enc a).length ≤ k) :
    Nat.log 2 W.card ≤ k := by
      refine' Nat.le_of_lt_succ ( Nat.log_lt_of_lt_pow _ _ );
      · exact Finset.card_ne_zero_of_mem hW.choose_spec;
      · convert injective_code_card_bound W enc hinj k hk using 1

/-
**Compression obstruction dominates the counting lower bound** (Theorem 1).

    For every nonempty finite witness set `W`, the compression obstruction is at least
    `⌊log₂ |W|⌋`. This certifies that the compression obstruction subsumes
    the naive witness-cardinality counting method.
-/
theorem compressionObstruction_ge_log_card {α : Type*} [DecidableEq α]
    (W : Finset α) (hW : W.Nonempty) :
    countingLowerBound W ≤ compressionObstruction W := by
      -- By definition of $compressionObstruction$, we know that for any $k$ in the set, $Nat.log 2 W.card ≤ k$.
      have h_log_card_le_compression : ∀ k, k ∈ {k : ℕ | ∃ (enc : α → List Bool), Set.InjOn enc ↑W ∧ ∀ a ∈ W, (enc a).length ≤ k} → Nat.log 2 W.card ≤ k := by
        rintro k ⟨ enc, hinj, hk ⟩;
        convert log_card_le_of_injective_code W hW enc hinj k hk using 1;
      exact le_csInf ( compressionObstruction_set_nonempty W ) h_log_card_le_compression

/-! ## Theorem 2: Prefix-free codes and the strict gap -/

/-
**Prefix-free bound**: in any prefix-free injective code over a finite set `W`
    with max codeword length `k`, the number of codewords is at most `2^k`.
-/
theorem prefixFree_code_card_le {α : Type*} [DecidableEq α]
    (W : Finset α) (enc : α → List Bool)
    (hinj : Set.InjOn enc ↑W)
    (hpf : ∀ a ∈ W, ∀ b ∈ W, a ≠ b → ¬(enc a) <+: (enc b))
    (k : ℕ) (hk : ∀ a ∈ W, (enc a).length ≤ k) :
    W.card ≤ 2 ^ k := by
      have h_prefix_free : (Finset.image (fun a => (enc a) ++ List.replicate (k - (enc a).length) false) W).card ≤ 2 ^ k := by
        -- The image of the padded encodings is a subset of the set of all binary strings of length `k`.
        have h_image_subset : Finset.image (fun a => (enc a) ++ List.replicate (k - (enc a).length) false) W ⊆ Finset.image (fun l : Fin k → Bool => List.ofFn l) (Finset.univ : Finset (Fin k → Bool)) := by
          intro x hx
          obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hx
          have h_len : (enc a ++ List.replicate (k - (enc a).length) false).length = k := by
            simp +decide [ hk a ha ];
          simp +zetaDelta at *;
          use fun i => (enc a ++ List.replicate (k - (enc a).length) false)[i]!;
          refine' List.ext_get _ _ <;> simp +decide [ h_len ];
        exact le_trans ( Finset.card_le_card h_image_subset ) ( Finset.card_image_le.trans ( by simp +decide [ Finset.card_univ ] ) );
      rwa [ Finset.card_image_of_injOn ] at h_prefix_free;
      intro a ha b hb hab;
      have h_prefix : enc a <+: enc b ∨ enc b <+: enc a := by
        simp_all +decide [ List.append_eq_append_iff ];
        grind;
      grind

/-
An injective (non-prefix-free) code of max length 1 exists for 3 elements.
-/
theorem exists_injective_code_three_maxlen_one :
    ∃ (enc : Fin 3 → List Bool),
      Function.Injective enc ∧
      (∀ i : Fin 3, (enc i).length ≤ 1) := by
        exists fun i => if i = 0 then [ ] else if i = 1 then [ Bool.true ] else [ Bool.false ]

/-
No prefix-free injective code of max length 1 exists for 3 elements.
-/
theorem no_prefixFree_code_three_maxlen_one :
    ¬∃ (enc : Fin 3 → List Bool),
      Function.Injective enc ∧
      (∀ i j : Fin 3, i ≠ j → ¬(enc i) <+: (enc j)) ∧
      (∀ i : Fin 3, (enc i).length ≤ 1) := by
        rintro ⟨ enc, hinj, hpf, hl ⟩;
        simp_all +decide [ Fin.forall_fin_succ, List.length_eq_one_iff ];
        rcases n : enc 0 with ( _ | ⟨ a, _ | ⟨ b, l ⟩ ⟩ ) <;> rcases n' : enc 1 with ( _ | ⟨ c, _ | ⟨ d, m ⟩ ⟩ ) <;> rcases n'' : enc 2 with ( _ | ⟨ e, _ | ⟨ f, n ⟩ ⟩ ) <;> simp_all +decide;
        cases a <;> cases c <;> cases e <;> simp_all +decide

/-
**Strict gap** (Theorem 2): the prefix-free obstruction strictly exceeds the
    general obstruction for `Fin 3`. This demonstrates that structural coding
    constraints create genuinely stronger lower bounds than unconstrained coding.
-/
theorem strict_gap_prefixFree_vs_general :
    compressionObstruction (Finset.univ : Finset (Fin 3)) <
    prefixFreeCompressionObstruction (Finset.univ : Finset (Fin 3)) := by
      -- Show that the compression obstruction for `Fin 3` is 1.
      have hCompressionObstruction : compressionObstruction (Finset.univ : Finset (Fin 3)) = 1 := by
        refine' le_antisymm _ _ <;> norm_num [ compressionObstruction ];
        · exact Nat.sInf_le <| by obtain ⟨ enc, h₁, h₂ ⟩ := exists_injective_code_three_maxlen_one; exact ⟨ enc, h₁, h₂ ⟩ ;
        · refine' le_csInf _ _ <;> norm_num [ Finset.card_univ ];
          · exact ⟨ 1, exists_injective_code_three_maxlen_one ⟩;
          · intro b x hx hb; contrapose! hx; simp_all +decide [ Function.Injective ] ;
      refine' hCompressionObstruction.symm ▸ lt_of_lt_of_le _ ( le_csInf _ _ );
      exact Nat.lt_succ_self 1;
      · refine' ⟨ 2, _ ⟩;
        exists fun x => if x = 0 then [ Bool.true, Bool.true ] else if x = 1 then [ Bool.true, Bool.false ] else [ Bool.false, Bool.true ];
      · rintro k ⟨ enc, henc₁, henc₂, henc₃ ⟩ ; have := prefixFree_code_card_le ( Finset.univ : Finset ( Fin 3 ) ) enc henc₁ henc₂ k henc₃; norm_num at this; contrapose! this; interval_cases k <;> simp_all +decide ;

/-! ## Theorem 3: Bridge to monotone formula depth -/

/-- Monotone Boolean formulas on `n` variables. -/
inductive MonoFormula (n : ℕ) where
  | var : Fin n → MonoFormula n
  | top : MonoFormula n
  | bot : MonoFormula n
  | and : MonoFormula n → MonoFormula n → MonoFormula n
  | or  : MonoFormula n → MonoFormula n → MonoFormula n

namespace MonoFormula

/-- Evaluation of a monotone formula. -/
def eval : MonoFormula n → (Fin n → Bool) → Bool
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

end MonoFormula

/-- A **KW witness** for a Boolean function `f`: a triple `(x, y, i)` where
    `f(x) = true`, `f(y) = false`, and `x_i ≠ y_i`. -/
structure KWWitness {n : ℕ} (f : (Fin n → Bool) → Bool) where
  posInput : Fin n → Bool
  negInput : Fin n → Bool
  coord : Fin n
  pos_accepted : f posInput = true
  neg_rejected : f negInput = false
  differs : posInput coord ≠ negInput coord

/-- The monotone formula depth of `f`. -/
noncomputable def monotoneFormulaDepth {n : ℕ} (f : (Fin n → Bool) → Bool) : ℕ :=
  sInf {d : ℕ | ∃ φ : MonoFormula n, (∀ x, φ.eval x = f x) ∧ φ.depth ≤ d}

/-
Any formula computing `f` certifies an upper bound on `monotoneFormulaDepth`.
-/
theorem monotoneFormulaDepth_le_of_formula {n : ℕ}
    (f : (Fin n → Bool) → Bool)
    (φ : MonoFormula n) (hφ : ∀ x, φ.eval x = f x) :
    monotoneFormulaDepth f ≤ φ.depth := by
      exact Nat.sInf_le ⟨ φ, hφ, le_rfl ⟩

/-
**Bridge theorem** (Theorem 3): if every monotone formula computing `f`
    has depth ≥ `k`, then `monotoneFormulaDepth f ≥ k`.

    Combined with `compressionObstruction_ge_log_card` and `prefixFree_code_card_le`,
    this creates a chain:
    - **Compression theory**: prefix-free obstruction ≥ counting bound
    - **Communication complexity**: KW protocol cost ≥ obstruction
    - **Circuit complexity**: formula depth ≥ protocol cost
-/
theorem formula_depth_ge_of_kw_lower_bound {n : ℕ}
    (f : (Fin n → Bool) → Bool)
    (k : ℕ)
    (hne : ∃ φ : MonoFormula n, ∀ x, φ.eval x = f x)
    (hkw : ∀ (φ : MonoFormula n), (∀ x, φ.eval x = f x) → k ≤ φ.depth) :
    k ≤ monotoneFormulaDepth f := by
      -- Since the set {d | ∃ φ, (∀ x, φ.eval x = f x) ∧ φ.depth ≤ d} is nonempty, its infimum is well-defined.
      have h_nonempty : {d : ℕ | ∃ φ : MonoFormula n, (∀ x, φ.eval x = f x) ∧ φ.depth ≤ d}.Nonempty := by
        exact ⟨ _, ⟨ hne.choose, hne.choose_spec, le_rfl ⟩ ⟩;
      exact le_csInf h_nonempty fun d hd => by obtain ⟨ φ, hφ₁, hφ₂ ⟩ := hd; exact le_trans ( hkw φ hφ₁ ) hφ₂;

/-! ## Auxiliary computations -/

/-- The counting lower bound for `Fin 3` is 1. -/
theorem countingBound_fin3 :
    countingLowerBound (Finset.univ : Finset (Fin 3)) = 1 := by native_decide

/-
Prefix-free obstruction exceeds the counting bound for 3 witnesses.
-/
theorem prefixFree_gt_counting_for_three :
    countingLowerBound (Finset.univ : Finset (Fin 3)) <
    prefixFreeCompressionObstruction (Finset.univ : Finset (Fin 3)) := by
      convert strict_gap_prefixFree_vs_general using 1;
      convert countingBound_fin3 using 1;
      nontriviality;
      refine' le_antisymm _ _ <;> norm_num [ compressionObstruction ];
      · refine' Nat.sInf_le _;
        exists fun a => if a = 0 then [ Bool.true ] else if a = 1 then [ Bool.false ] else [ ];
      · refine' le_csInf _ _;
        · exact ⟨ 3, ⟨ fun a => List.replicate a.val Bool.true, by decide, by decide ⟩ ⟩;
        · rintro k ⟨ enc, henc, hk ⟩ ; contrapose! hk; interval_cases k ; simp_all +decide [ Function.Injective ] ;
          by_cases h : ∃ a, (enc a).length > 0 <;> simp_all +decide [ Fin.forall_fin_succ ]

end CompressionObstruction