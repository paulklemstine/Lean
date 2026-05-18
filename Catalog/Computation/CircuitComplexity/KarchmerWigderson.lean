import Mathlib

/-!
# Karchmer-Wigderson Correspondence for Monotone Formulas

## Main Results

- `monotone_formula_gives_KW_protocol` (Theorem A): formula → protocol
- `KW_protocol_gives_monotone_formula` (Theorem B): protocol → formula
- `KW_lower_bound_implies_formula_depth_lower_bound` (Theorem C): lower bound transfer
- `or_function_depth_ge_one`: concrete lower bound for OR
-/

noncomputable section
open Classical

namespace CircuitComplexity

/-! ## Core Definitions -/

def BitwiseLE {n : ℕ} (x y : Fin n → Bool) : Prop :=
  ∀ i, x i = true → y i = true

def MonotoneBool {n : ℕ} (f : (Fin n → Bool) → Bool) : Prop :=
  ∀ ⦃x y⦄, BitwiseLE x y → f x = true → f y = true

inductive MonoFormula (n : ℕ) where
  | var : Fin n → MonoFormula n
  | top : MonoFormula n
  | bot : MonoFormula n
  | and : MonoFormula n → MonoFormula n → MonoFormula n
  | or  : MonoFormula n → MonoFormula n → MonoFormula n

namespace MonoFormula

def eval : MonoFormula n → (Fin n → Bool) → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and φ₁ φ₂, x => φ₁.eval x && φ₂.eval x
  | or φ₁ φ₂, x => φ₁.eval x || φ₂.eval x

def depth : MonoFormula n → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth
  | or φ₁ φ₂ => 1 + max φ₁.depth φ₂.depth

def size : MonoFormula n → ℕ
  | var _ => 1
  | top => 1
  | bot => 1
  | and φ₁ φ₂ => 1 + φ₁.size + φ₂.size
  | or φ₁ φ₂ => 1 + φ₁.size + φ₂.size

theorem eval_monotone (φ : MonoFormula n) : MonotoneBool φ.eval := by
  induction φ with
  | var i => intro x y hxy hx; exact hxy i hx
  | top => intro x y _ _; rfl
  | bot => intro x y _ hx; exact hx
  | and φ₁ φ₂ ih₁ ih₂ =>
    intro x y hxy hx
    simp only [eval, Bool.and_eq_true] at hx ⊢
    exact ⟨ih₁ hxy hx.1, ih₂ hxy hx.2⟩
  | or φ₁ φ₂ ih₁ ih₂ =>
    intro x y hxy hx
    simp only [eval, Bool.or_eq_true] at hx ⊢
    exact hx.elim (fun h => .inl (ih₁ hxy h)) (fun h => .inr (ih₂ hxy h))

end MonoFormula

theorem exists_KW_witness {f : (Fin n → Bool) → Bool}
    (hf : MonotoneBool f) {x y : Fin n → Bool}
    (hx : f x = true) (hy : f y = false) :
    ∃ i : Fin n, x i = true ∧ y i = false := by
  by_contra h; push_neg at h
  have hle : BitwiseLE x y := fun i hi => by
    specialize h i hi; cases hy' : y i <;> simp_all
  exact absurd (hf hle hx) (by rw [hy]; decide)

/-! ## KW Protocol Trees -/

inductive KWProto (n : ℕ) :
    ((Fin n → Bool) → Prop) → ((Fin n → Bool) → Prop) → Type 1 where
  | leaf (i : Fin n)
      (hA : (∃ y, PB y) → ∀ x, PA x → x i = true)
      (hB : (∃ x, PA x) → ∀ y, PB y → y i = false) :
      KWProto n PA PB
  | alice (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n (fun x => PA x ∧ q x = false) PB)
      (t_tt : KWProto n (fun x => PA x ∧ q x = true) PB) :
      KWProto n PA PB
  | bob (q : (Fin n → Bool) → Bool)
      (t_ff : KWProto n PA (fun y => PB y ∧ q y = false))
      (t_tt : KWProto n PA (fun y => PB y ∧ q y = true)) :
      KWProto n PA PB

namespace KWProto

def cost : KWProto n PA PB → ℕ
  | leaf _ _ _ => 0
  | alice _ t₀ t₁ => 1 + max t₀.cost t₁.cost
  | bob _ t₀ t₁ => 1 + max t₀.cost t₁.cost

def weaken {PA PA' PB PB' : (Fin n → Bool) → Prop}
    (hA : ∀ x, PA' x → PA x) (hB : ∀ y, PB' y → PB y) :
    KWProto n PA PB → KWProto n PA' PB'
  | leaf i hA₀ hB₀ =>
      leaf i
        (fun ⟨y, hy⟩ x hx => hA₀ ⟨y, hB y hy⟩ x (hA x hx))
        (fun ⟨x, hx⟩ y hy => hB₀ ⟨x, hA x hx⟩ y (hB y hy))
  | alice q t₀ t₁ =>
      alice q
        (t₀.weaken (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB)
        (t₁.weaken (fun x ⟨h, hq⟩ => ⟨hA x h, hq⟩) hB)
  | bob q t₀ t₁ =>
      bob q
        (t₀.weaken hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩))
        (t₁.weaken hA (fun y ⟨h, hq⟩ => ⟨hB y h, hq⟩))

theorem weaken_cost {PA PA' PB PB' : (Fin n → Bool) → Prop}
    (hA : ∀ x, PA' x → PA x) (hB : ∀ y, PB' y → PB y)
    (T : KWProto n PA PB) :
    (T.weaken hA hB).cost = T.cost := by
  induction' T with PA PB T ih generalizing PA' PB';
  · rfl;
  · unfold KWProto.cost;
    rename_i hA' hB' ih₁ ih₂;
    rw [ show weaken hA hB ( alice _ hA' hB' ) = alice _ ( weaken ( fun x hx => ⟨ hA x hx.1, hx.2 ⟩ ) hB hA' ) ( weaken ( fun x hx => ⟨ hA x hx.1, hx.2 ⟩ ) hB hB' ) from rfl ];
    grind +splitImp;
  · rename_i hA' hB' ih₁ ih₂;
    exact congr_arg₂ ( fun x y => 1 + max x y ) ( ih₁ hA fun y hy => ⟨ hB y hy.1, hy.2 ⟩ ) ( ih₂ hA fun y hy => ⟨ hB y hy.1, hy.2 ⟩ )

end KWProto

abbrev KWProtocol (n : ℕ) (f : (Fin n → Bool) → Bool) :=
  KWProto n (fun x => f x = true) (fun y => f y = false)

/-! ## Formula → Protocol (Theorem A) -/

def MonoFormula.toKWProto [NeZero n] :
    (φ : MonoFormula n) → KWProto n (fun x => φ.eval x = true) (fun y => φ.eval y = false)
  | .var i =>
      .leaf i (fun _ _ hx => hx) (fun _ y hy => by
        change (MonoFormula.var i).eval y = false at hy; simp [MonoFormula.eval] at hy; exact hy)
  | .top =>
      .leaf ⟨0, NeZero.pos n⟩
        (fun ⟨_, hy⟩ => absurd hy (by simp [MonoFormula.eval]))
        (fun _ _ hy => absurd hy (by simp [MonoFormula.eval]))
  | .bot =>
      .leaf ⟨0, NeZero.pos n⟩
        (fun _ _ hx => absurd hx (by simp [MonoFormula.eval]))
        (fun ⟨_, hx⟩ => absurd hx (by simp [MonoFormula.eval]))
  | .or φ₁ φ₂ =>
      .alice (fun x => φ₁.eval x)
        (φ₂.toKWProto.weaken
          (fun x ⟨h_or, h_q⟩ => by
            change (MonoFormula.or φ₁ φ₂).eval x = true at h_or
            simp only [MonoFormula.eval, Bool.or_eq_true] at h_or
            cases h_or with
            | inl h => simp [h_q] at h
            | inr h => exact h)
          (fun y h_or => by
            change (MonoFormula.or φ₁ φ₂).eval y = false at h_or
            simp only [MonoFormula.eval, Bool.or_eq_false_iff] at h_or
            exact h_or.2))
        (φ₁.toKWProto.weaken
          (fun x ⟨_, h_q⟩ => h_q)
          (fun y h_or => by
            change (MonoFormula.or φ₁ φ₂).eval y = false at h_or
            simp only [MonoFormula.eval, Bool.or_eq_false_iff] at h_or
            exact h_or.1))
  | .and φ₁ φ₂ =>
      .bob (fun y => φ₁.eval y)
        (φ₁.toKWProto.weaken
          (fun x h_and => by
            change (MonoFormula.and φ₁ φ₂).eval x = true at h_and
            simp only [MonoFormula.eval, Bool.and_eq_true] at h_and
            exact h_and.1)
          (fun y ⟨_, h_q⟩ => h_q))
        (φ₂.toKWProto.weaken
          (fun x h_and => by
            change (MonoFormula.and φ₁ φ₂).eval x = true at h_and
            simp only [MonoFormula.eval, Bool.and_eq_true] at h_and
            exact h_and.2)
          (fun y ⟨h_and, h_q⟩ => by
            change (MonoFormula.and φ₁ φ₂).eval y = false at h_and
            simp only [MonoFormula.eval, Bool.and_eq_false_iff] at h_and
            cases h_and with
            | inl h => simp [h_q] at h
            | inr h => exact h))

theorem MonoFormula.toKWProto_cost [NeZero n] (φ : MonoFormula n) :
    φ.toKWProto.cost ≤ φ.depth := by
  induction' φ using MonoFormula.recOn with i φ₁ φ₂ h₁ h₂;
  · exact Nat.zero_le _;
  · exact Nat.zero_le _;
  · rfl;
  · exact Nat.add_le_add_left ( by exact le_trans ( by simp +decide [ KWProto.weaken_cost ] ) ( max_le_max h₁ h₂ ) ) 1;
  · unfold MonoFormula.toKWProto MonoFormula.depth;
    unfold KWProto.cost; simp +arith +decide [ *, KWProto.weaken_cost ] ;
    grind

theorem monotone_formula_gives_KW_protocol [NeZero n]
    (f : (Fin n → Bool) → Bool)
    (φ : MonoFormula n) (hφ : ∀ x, φ.eval x = f x) :
    ∃ P : KWProtocol n f, P.cost ≤ φ.depth := by
  -- Use φ.toKWProto weakened to f's predicates.
  use φ.toKWProto.weaken (fun x hx => by simpa [hφ] using hx) (fun y hy => by simpa [hφ] using hy);
  rw [KWProto.weaken_cost]
  exact MonoFormula.toKWProto_cost φ

/-! ## Protocol → Formula (Theorem B) -/

def KWProto.toFormula {PA PB : (Fin n → Bool) → Prop} :
    KWProto n PA PB → MonoFormula n
  | .leaf i _ _ => .var i
  | .alice q t₀ t₁ =>
      if (∃ x, PA x ∧ q x = false) then
        if (∃ x, PA x ∧ q x = true) then
          .or t₀.toFormula t₁.toFormula
        else
          t₀.toFormula
      else
        if (∃ x, PA x ∧ q x = true) then
          t₁.toFormula
        else
          .bot
  | .bob q t₀ t₁ =>
      if (∃ y, PB y ∧ q y = false) then
        if (∃ y, PB y ∧ q y = true) then
          .and t₀.toFormula t₁.toFormula
        else
          t₀.toFormula
      else
        if (∃ y, PB y ∧ q y = true) then
          t₁.toFormula
        else
          .top

theorem KWProto.toFormula_true {PA PB : (Fin n → Bool) → Prop}
    (T : KWProto n PA PB) (x : Fin n → Bool) (hx : PA x)
    (hB : ∃ y, PB y) :
    T.toFormula.eval x = true := by
  induction' T with i hA hB q t₀ t₁ hA hB q t₀ t₁ hA hB;
  · unfold KWProto.toFormula; aesop;
  · unfold KWProto.toFormula;
    split_ifs <;> simp_all +decide [ MonoFormula.eval ];
    grobner;
  · rw [ KWProto.toFormula ];
    split_ifs <;> simp_all +decide [ MonoFormula.eval ]

theorem KWProto.toFormula_false {PA PB : (Fin n → Bool) → Prop}
    (T : KWProto n PA PB) (y : Fin n → Bool) (hy : PB y)
    (hA : ∃ x, PA x) :
    T.toFormula.eval y = false := by
  induction' T with PA PB q t₀ t₁ ih₀ ih₁ q t₀ t₁ ih₀ ih₁ generalizing y <;> simp_all +decide [ KWProto.toFormula ];
  · exact t₁ hA y hy;
  · split_ifs <;> simp_all +decide [ MonoFormula.eval ];
    · grind;
    · exact ih₀ y hy _ hA.choose_spec;
    · exact ih₁ y hy _ hA.choose_spec;
  · split_ifs <;> simp_all +decide [ MonoFormula.eval ];
    grind

theorem KWProto.toFormula_depth {PA PB : (Fin n → Bool) → Prop}
    (T : KWProto n PA PB) :
    T.toFormula.depth ≤ T.cost := by
  induction' T with PA PB q t₀ t₁ ih₀ ih₁;
  · exact Nat.zero_le _;
  · rename_i q t_ff t_tt ih_ff ih_tt;
    by_cases h : ∃ x, ih₀ x ∧ q x = false <;> by_cases h' : ∃ x, ih₀ x ∧ q x = true <;> simp_all +decide [ KWProto.toFormula, KWProto.cost ];
    · exact Nat.add_le_add_left ( max_le_max ih_ff ih_tt ) _;
    · grind;
    · grind;
    · exact Nat.zero_le _;
  · unfold KWProto.toFormula KWProto.cost;
    split_ifs <;> simp_all +decide [ MonoFormula.depth ];
    · grind;
    · exact le_trans ‹_› ( by omega );
    · exact le_trans ‹_› ( by omega )

theorem KW_protocol_gives_monotone_formula
    (f : (Fin n → Bool) → Bool)
    (hne_t : ∃ x, f x = true) (hne_f : ∃ y, f y = false)
    (P : KWProtocol n f) :
    ∃ φ : MonoFormula n, (∀ x, φ.eval x = f x) ∧ φ.depth ≤ P.cost := by
  refine' ⟨ _, _, _ ⟩;
  exact P.toFormula;
  · intro x;
    by_cases hx : f x = true <;> simp_all +decide [ KWProto.toFormula_true, KWProto.toFormula_false ];
  · exact KWProto.toFormula_depth P

/-! ## Theorem C: Lower Bound Transfer -/

theorem KW_lower_bound_implies_formula_depth_lower_bound [NeZero n]
    (f : (Fin n → Bool) → Bool)
    (c : ℕ)
    (hc : ∀ P : KWProtocol n f, c ≤ P.cost) :
    ∀ φ : MonoFormula n, (∀ x, φ.eval x = f x) → c ≤ φ.depth := by
  exact fun φ hφ => le_trans ( hc _ ) ( monotone_formula_gives_KW_protocol f φ hφ |> Classical.choose_spec )

/-! ## Concrete Lower Bound -/

def orFn (n : ℕ) : (Fin n → Bool) → Bool :=
  fun x => decide (∃ i : Fin n, x i = true)

theorem orFn_iff (x : Fin n → Bool) :
    orFn n x = true ↔ ∃ i : Fin n, x i = true := by
  unfold orFn; aesop;

theorem orFn_monotone : MonotoneBool (orFn (n := n)) := by
  intro x y hxy hx; contrapose! hx; simp_all +decide ;
  unfold orFn at *; simp_all +decide ;
  exact fun i => by simpa [ hx ] using hxy i;

theorem orFn_KW_cost_ge_one (hn : 2 ≤ n)
    (P : KWProtocol n (orFn n)) : 1 ≤ P.cost := by
  -- Let's unfold the definition of KWProto and KWProtocol.
  rcases P with ⟨⟨i, hA, hB⟩ | ⟨q, t₀, t₁⟩ | ⟨q, t₀, t₁⟩⟩;
  all_goals simp_all +decide [ KWProto.cost ];
  · rename_i hA hB;
    simp_all +decide [ orFn ];
    exact absurd ( hA ( fun _ => Bool.false ) ( fun _ => rfl ) ( fun i => if i = ⟨ 1, by linarith ⟩ then Bool.true else Bool.false ) ⟨ 1, by linarith ⟩ ) ( by simp +decide );
  · rename_i h₁ h₂;
    specialize h₁ ⟨ fun _ => Bool.false, by
      simp +decide [ orFn ] ⟩ ( fun i => if i = ⟨ 0, by linarith ⟩ then Bool.true else Bool.false ) ; simp_all +decide [ orFn ];
  · rename_i hA hB;
    specialize hA ⟨ fun _ => Bool.false, by
      unfold orFn; aesop; ⟩ ( fun i => if i = ⟨ 1, by linarith ⟩ then Bool.true else Bool.false ) ; simp_all +decide [ orFn ];
  · rename_i k hk₁ hk₂;
    contrapose! hk₁;
    refine' ⟨ ⟨ fun _ => Bool.false, _ ⟩, ⟨ fun i => if i = ⟨ 0, by linarith ⟩ then Bool.true else Bool.false, _, _ ⟩ ⟩ <;> simp +decide [ orFn ]

theorem or_function_depth_ge_one (hn : 2 ≤ n)
    (φ : MonoFormula n) (hφ : ∀ x, φ.eval x = orFn n x) :
    1 ≤ φ.depth := by
  convert KW_lower_bound_implies_formula_depth_lower_bound ( orFn n ) 1 _ φ hφ;
  · exact ⟨ by linarith ⟩;
  · -- Apply the theorem `orFn_KW_cost_ge_one` to conclude the proof.
    apply orFn_KW_cost_ge_one hn

end CircuitComplexity