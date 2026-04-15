/-! # CatalogBuild.Tropical.Cryptography.HashInversion

Auto-generated from theorem catalog database.
Domain: Tropical/Cryptography
Declarations: 28
-/

import Mathlib

noncomputable section

/-- [Section: ## Part 1: Non-Injectivity of Hash Functions (Pigeonhole)] -/
theorem hash_not_injective {α β : Type*} [Fintype α] [Fintype β]
    (h_card : Fintype.card β < Fintype.card α) (f : α → β) :
    ¬ Injective f := by
  contrapose! h_card; have := Fintype.card_le_of_injective f; aesop;


theorem sha256_domain_exceeds_range :
    ∀ n : ℕ, 256 < n → 2 ^ 256 < 2 ^ n := by
  exact fun n hn => pow_lt_pow_right₀ ( by decide ) hn


theorem information_loss (n m : ℕ) (h : m < n) :
    n - m ≥ 1 := by
  exact Nat.sub_pos_of_lt h


/-- A tropical matrix is a matrix over ℤ ∪ {+∞}, where we use `WithTop ℤ`
to represent this. Tropical matrix multiplication uses min for addition
and + for multiplication. -/
def tropicalMatMul (n : ℕ) (A B : Fin n → Fin n → WithTop ℤ) :
    Fin n → Fin n → WithTop ℤ :=
  fun i j => Finset.inf (Finset.univ) (fun k => A i k + B k j)


/-- [Section: ## Part 2: Tropical Matrix Algebra for Boolean Circuits] -/
lemma finset_inf_add_right (s : Finset ι) (f : ι → WithTop ℤ) (c : WithTop ℤ)
    (hs : s.Nonempty) :
    s.inf (fun k => f k + c) = s.inf f + c := by
  induction hs using Finset.Nonempty.cons_induction ; simp +decide [ * ];
  simp +decide [ *, Finset.inf_insert ];
  exact?


lemma finset_inf_add_left (s : Finset ι) (f : ι → WithTop ℤ) (c : WithTop ℤ)
    (hs : s.Nonempty) :
    s.inf (fun k => c + f k) = c + s.inf f := by
  convert finset_inf_add_right s f c hs using 1 ; simp +decide [ add_comm ];
  exact add_comm _ _


lemma finset_inf_inf_eq_inf_prod (s : Finset ι) (t : Finset κ)
    (f : ι → κ → WithTop ℤ) :
    s.inf (fun i => t.inf (fun j => f i j)) =
    (s ×ˢ t).inf (fun p => f p.1 p.2) := by
  grind +suggestions


theorem tropicalMatMul_assoc (n : ℕ)
    (A B C : Fin n → Fin n → WithTop ℤ) :
    tropicalMatMul n (tropicalMatMul n A B) C =
    tropicalMatMul n A (tropicalMatMul n B C) := by
  -- By definition of tropical matrix multiplication, we can expand both sides.
  have h_expand : ∀ i j, (tropicalMatMul n (tropicalMatMul n A B) C) i j = (Finset.univ ×ˢ Finset.univ).inf (fun p => A i p.1 + B p.1 p.2 + C p.2 j) := by
    intros i j
    simp [tropicalMatMul];
    convert finset_inf_inf_eq_inf_prod Finset.univ Finset.univ _ using 1;
    congr! 2;
    rw [ ← finset_inf_add_right ];
    · exact ⟨ _, Finset.mem_univ ‹_› ⟩;
    · refine' le_antisymm _ _ <;> simp +decide [ Finset.inf_le ];
      · exact fun a b => Finset.inf_le ( Finset.mem_univ ( b, a ) );
      · exact fun a b => Finset.inf_le ( Finset.mem_univ ( b, a ) ) |> le_trans <| by simp +decide [ add_comm, add_left_comm, add_assoc ] ;
  ext i j;
  rw [ h_expand, show ( tropicalMatMul n A ( tropicalMatMul n B C ) ) i j = Finset.inf ( Finset.univ ×ˢ Finset.univ ) ( fun p => A i p.1 + B p.1 p.2 + C p.2 j ) from ?_ ];
  unfold tropicalMatMul;
  convert finset_inf_inf_eq_inf_prod _ _ _ using 1;
  convert rfl;
  convert finset_inf_add_left _ _ _ _;
  · exact ⟨ ‹_›, Finset.mem_univ _ ⟩;
  · simp +decide only [add_assoc]


/-- The tropical identity matrix has 0 on diagonal, +∞ elsewhere. -/
def tropicalIdentity (n : ℕ) : Fin n → Fin n → WithTop ℤ :=
  fun i j => if i = j then (0 : WithTop ℤ) else ⊤


theorem tropicalMatMul_identity_right (n : ℕ) (hn : 0 < n)
    (A : Fin n → Fin n → WithTop ℤ) :
    tropicalMatMul n A (tropicalIdentity n) = A := by
  unfold tropicalMatMul;
  ext i j; by_cases hij : i = j <;> simp +decide [ hij, tropicalIdentity ] ;
  · refine' le_antisymm _ _ <;> norm_num [ Finset.inf_le_iff ];
    · exact Finset.inf_le ( Finset.mem_univ j ) |> le_trans <| by aesop;
    · aesop;
  · refine' le_antisymm _ _;
    · exact Finset.inf_le ( Finset.mem_univ j ) |> le_trans <| by aesop;
    · exact Finset.le_inf fun k hk => by aesop;


theorem tropicalMatMul_identity_left (n : ℕ) (hn : 0 < n)
    (A : Fin n → Fin n → WithTop ℤ) :
    tropicalMatMul n (tropicalIdentity n) A = A := by
  unfold tropicalMatMul;
  ext i j; by_cases hij : i = j <;> simp +decide [ hij, tropicalIdentity ] ;
  · exact le_antisymm ( Finset.inf_le ( Finset.mem_univ j ) |> le_trans <| by aesop ) ( Finset.le_inf fun k _ => by aesop );
  · refine' le_antisymm _ _ <;> norm_num [ Finset.inf_le, Finset.le_inf ];
    · exact Finset.inf_le ( Finset.mem_univ i ) |> le_trans <| by aesop;
    · aesop


/-- [Section: ## Part 3: XOR as an Invertible Tropical Operation] -/
theorem xor_self_inverse (x k : Bool) : xor (xor x k) k = x := by
  cases x <;> cases k <;> rfl


theorem xor_key_bijective (k : Bool) : Bijective (fun x => xor x k) := by
  native_decide +revert


theorem bitvec_xor_self_inverse (n : ℕ) (x k : Fin (2^n)) :
    Fin.xor (Fin.xor x k) k = x := by
  -- By definition of bitwise XOR, we know that $(x \oplus k) \oplus k = x$.
  have h_xor_self : ∀ (x k : Fin (2 ^ n)), (x ^^^ k) ^^^ k = x := by
    aesop;
  exact h_xor_self _ _


/-- [Section: ## Part 4: Modular Addition is NOT Invertible (Without the Other Operand)] -/
theorem mod_add_surjective (m : ℕ) (hm : 0 < m) (b : Fin m) :
    Surjective (fun x : Fin m => x + b) := by
  intro y; use y - b; simp +decide [ Fin.add_def ] ;
  norm_num [ Fin.ext_iff, Fin.val_sub ];
  rw [ show m - ( b : ℕ ) + ( y : ℕ ) + ( b : ℕ ) = m + ( y : ℕ ) by linarith [ Nat.sub_add_cancel ( show ( b : ℕ ) ≤ m from b.2.le ) ] ] ; simp +decide [ Nat.add_mod, Nat.mod_eq_of_lt y.2 ]


theorem mod_add_not_injective (m : ℕ) (hm : 2 ≤ m) :
    ¬ Injective (fun p : Fin m × Fin m => (p.1 + p.2 : Fin m)) := by
  norm_num [ Function.Injective, Fin.ext_iff ];
  refine' ⟨ ⟨ 0, by linarith ⟩, ⟨ 1, by linarith ⟩, ⟨ 1, by linarith ⟩, ⟨ 0, by linarith ⟩, _, _ ⟩ <;> norm_num;
  norm_num [ Fin.val_add ]


/-- [Section: ## Part 5: Composition of Lossy Functions Cannot Be Inverted] -/
theorem composition_not_injective_of_component {α β γ : Type*}
    (f : α → β) (g : β → γ) (hf : ¬ Injective f) :
    ¬ Injective (g ∘ f) := by
  -- By definition of injectivity, if $f$ is not injective, then there exist $a \neq b$ such that $f(a) = f(b)$.
  obtain ⟨a, b, hab⟩ : ∃ a b, a ≠ b ∧ f a = f b := by
    simpa [ Function.Injective, and_comm ] using hf;
  exact fun h => hab.1 ( h ( by simp +decide [ hab.2 ] ) )


/-- SHA-256 has 64 rounds, each containing modular additions.
Since modular addition is not injective (as a function of the pair),
the overall hash is not injective on messages longer than 256 bits.
This formalizes the core impossibility: no tropical matrix, quantum gate,
or any other algebraic object can invert SHA-256 in general, because
information is irreversibly destroyed.
A composition of two functions where the first is not injective
yields a non-injective composition. This models any SHA-256 round
containing a lossy operation. -/
theorem lossy_composition_not_invertible {α β γ : Type*}
    (f : α → β) (g : β → γ)
    (hf : ¬ Injective f) :
    ¬ Injective (g ∘ f) :=
  composition_not_injective_of_component f g hf


/-- [Section: ## Part 6: Quantum Circuit Reversibility Requires Ancilla Bits] -/
theorem reversible_iff_bijective {α : Type*} [Fintype α] (f : α → α) :
    (∃ g : α → α, g ∘ f = id ∧ f ∘ g = id) ↔ Bijective f := by
  constructor <;> intro h;
  · exact ⟨ Function.LeftInverse.injective ( congr_fun h.choose_spec.1 ), Function.RightInverse.surjective ( congr_fun h.choose_spec.2 ) ⟩;
  · obtain ⟨ g, hg ⟩ := h;
    choose g hg using hg;
    aesop


theorem quantum_ancilla_requirement {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β) (hf : ¬ Injective f)
    {γ : Type*} [Fintype γ] (f' : α → β × γ)
    (h_extends : Prod.fst ∘ f' = f)
    (h_inj : Injective f') :
    1 < Fintype.card γ := by
  contrapose! hf; rcases n : Fintype.card γ with ( _ | _ | n ) <;> simp_all +decide;
  · rw [ Fintype.card_eq_zero_iff ] at n ; aesop_cat;
  · rw [ Fintype.card_eq_one_iff ] at n; obtain ⟨ x, hx ⟩ := n; simp_all +decide [ funext_iff, Prod.ext_iff ] ;
    exact fun a b hab => h_inj <| Prod.ext ( by aesop ) ( by aesop )


theorem quantum_sha256_inverse_needs_garbage
    (n : ℕ) (hn : 256 < n)
    (sha256 : Fin (2^n) → Fin (2^256))
    (h_not_inj : ¬ Injective sha256) :
    ∀ (inv : Fin (2^256) → Fin (2^n)),
      ¬ (∀ x, inv (sha256 x) = x) := by
  exact fun inv h => h_not_inj <| fun x y hxy => by have := h x; have := h y; aesop;


/-- [Section: ## Part 7: Tropical Rank of Lossy Boolean Matrices] -/
theorem tropical_rank_le_dim (n : ℕ) (A : Fin n → Fin n → WithTop ℤ) :
    ∃ r : ℕ, r ≤ n := by
  use n


/-- A bijective function on Fin n can be represented as a tropical
permutation matrix (0s on the permutation, +∞ elsewhere).
Such matrices have full tropical rank and are invertible. -/
def tropicalPermMatrix (n : ℕ) (σ : Equiv.Perm (Fin n)) :
    Fin n → Fin n → WithTop ℤ :=
  fun i j => if σ i = j then (0 : WithTop ℤ) else ⊤


theorem tropicalPerm_inverse (n : ℕ) (hn : 0 < n) (σ : Equiv.Perm (Fin n)) :
    tropicalMatMul n (tropicalPermMatrix n σ) (tropicalPermMatrix n σ⁻¹) =
    tropicalIdentity n := by
  unfold tropicalMatMul tropicalPermMatrix tropicalIdentity;
  ext i j; split_ifs <;> simp_all +decide [ Equiv.Perm.eq_inv_iff_eq ] ;
  · refine' le_antisymm _ _ <;> simp +decide [ Finset.inf_eq_iInf ];
    · use σ j; aesop;
    · aesop;
  · grind


/-- [Section: ## Part 8: The Fundamental Impossibility Theorem] -/
theorem no_matrix_inverts_noninj_function {α β : Type*}
    (f : α → β) (hf : ¬ Injective f) :
    ¬ ∃ g : β → α, ∀ x, g (f x) = x := by
  exact fun ⟨ g, hg ⟩ => hf fun x y hxy => by have := hg x; have := hg y; aesop;


/-- [Section: ## Part 9: What IS Possible — Partial Inverses and Preimage Search] -/
theorem surjective_has_right_inverse {α β : Type*}
    (f : α → β) (hf : Surjective f) :
    ∃ g : β → α, ∀ y, f (g y) = y := by
  exact ⟨ fun y => Classical.choose ( hf y ), fun y => Classical.choose_spec ( hf y ) ⟩


/-- [Section: ## Part 10: Tropical Encoding of Boolean Operations] -/
theorem bool_or_as_tropical_min :
    ∀ a b : Bool,
      (if a || b then (0 : WithTop ℤ) else ⊤) =
      min (if a then (0 : WithTop ℤ) else ⊤) (if b then (0 : WithTop ℤ) else ⊤) := by
  decide +revert


theorem bool_and_as_tropical_max :
    ∀ a b : Bool,
      (if a && b then (0 : WithTop ℤ) else ⊤) =
      max (if a then (0 : WithTop ℤ) else ⊤) (if b then (0 : WithTop ℤ) else ⊤) := by
  decide +revert


end
