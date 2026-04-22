import Mathlib

/-! # CatalogBuild.Speculative.Other.KolmogorovComplexity

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 9
-/

noncomputable section

/-- A description method is a partial function from binary strings to binary strings.
We model binary strings as `List Bool`. -/
def DescriptionMethod := List Bool → Option (List Bool)

/-- The set of valid programs for a given output under a description method. -/
def validPrograms (φ : DescriptionMethod) (x : List Bool) : Set (List Bool) :=
  {p | φ p = some x}

/-- The descriptive complexity of `x` with respect to a description method `φ`:
the length of the shortest program `p` such that `φ p = some x`.
Returns `⊤` (infinity) if no such program exists. -/
noncomputable def complexity (φ : DescriptionMethod) (x : List Bool) : ℕ∞ :=
  ⨅ (p : List Bool) (_ : φ p = some x), (p.length : ℕ∞)

/-- A description method `U` is universal if it can simulate any other
description method given a finite prefix (interpreter). -/
def IsUniversal (U : DescriptionMethod) : Prop :=
  ∀ φ : DescriptionMethod, ∃ (prefix_ : List Bool),
    ∀ p x : List Bool, φ p = some x →
      U (prefix_ ++ p) = some x

/-- A description method `ψ` is optimal if for every other description method `φ`,
there exists a constant `c` such that `K_ψ(x) ≤ K_φ(x) + c` for all x. -/
def IsOptimal (ψ : DescriptionMethod) : Prop :=
  ∀ φ : DescriptionMethod, ∃ c : ℕ,
    ∀ x : List Bool, complexity ψ x ≤ complexity φ x + c

/-- [Section: # CatalogBuild.Speculative.Other.KolmogorovComplexity
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 9] -/
theorem universal_is_optimal (U : DescriptionMethod) (hU : IsUniversal U) :
    IsOptimal U := by
      intro φ
      obtain ⟨prefix_, hprefix⟩ := hU φ
      use prefix_.length;
      intro x
      have h_le : ∀ p : List Bool, φ p = some x → complexity U x ≤ p.length + prefix_.length := by
        intro p hp;
        exact le_trans ( ciInf_le ⟨ 0, Set.forall_mem_range.mpr fun _ => by positivity ⟩ ( prefix_ ++ p ) ) ( by simp +decide [ add_comm, hprefix p x hp ] );
      have h_inf_le : ⨅ (p : List Bool) (_ : φ p = some x), (p.length : ℕ∞) ≥ complexity U x - prefix_.length := by
        refine' le_ciInf fun p => _;
        by_cases hp : φ p = some x <;> simp_all +decide [ tsub_le_iff_right ];
      convert tsub_le_iff_right.mp h_inf_le using 1

/-- [Section: # CatalogBuild.Speculative.Other.KolmogorovComplexity
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 9] -/
theorem complexity_le_length (U : DescriptionMethod)
    (hU : IsUniversal U) :
    ∃ c : ℕ, ∀ x : List Bool,
      complexity U x ≤ x.length + c := by
        -- By definition of universality, there exists a prefix_ such that U(prefix_ ++ x) = some x for all x.
        obtain ⟨prefix_, hprefix⟩ : ∃ prefix_ : List Bool, ∀ x : List Bool, U (prefix_ ++ x) = some x := by
          exact hU ( fun x => some x ) |> fun ⟨ prefix_, hprefix_ ⟩ => ⟨ prefix_, fun x => hprefix_ x x rfl ⟩;
        refine' ⟨ prefix_.length, fun x => _ ⟩;
        refine' le_trans ( ciInf_le _ _ ) _ <;> norm_num [ hprefix ];
        exacts [ prefix_ ++ x, by simp [ hprefix, add_comm ] ]

/-- A string is `c`-incompressible if K(x) ≥ |x| - c. -/
def Incompressible (U : DescriptionMethod) (x : List Bool) (c : ℕ) : Prop :=
  complexity U x ≥ x.length - c

theorem incompressible_exist (φ : DescriptionMethod) (n : ℕ) :
    ∃ x : List Bool, x.length = n ∧
      ∀ p : List Bool, p.length < n → φ p ≠ some x := by
        by_contra! h_contra;
        choose! p hp₁ hp₂ using h_contra;
        -- Consider the set of all programs of length less than $n$. There are $2^0 + 2^1 + \cdots + 2^{n-1} = 2^n - 1$ such programs.
        have h_programs : Finset.card (Finset.image p (Finset.filter (fun x => x.length = n) (Finset.image (fun l : Fin n → Bool => List.ofFn l) (Finset.univ : Finset (Fin n → Bool))))) ≤ 2^n - 1 := by
          refine' le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr _ ) _;
          exact Finset.biUnion ( Finset.range n ) fun k => Finset.image ( fun l : Fin k → Bool => List.ofFn l ) ( Finset.univ : Finset ( Fin k → Bool ) );
          · simp +zetaDelta at *;
            exact fun a => ⟨ p ( List.ofFn a ) |> List.length, hp₁ _ ( by simp +decide ), fun i => p ( List.ofFn a ) |> List.get <| i, by simp +decide [ List.ofFn_get ] ⟩;
          · refine' le_trans ( Finset.card_biUnion_le ) _;
            rw [ Finset.sum_congr rfl fun i hi => Finset.card_image_of_injective _ fun x y hxy => by simpa [ funext_iff ] using hxy ] ; norm_num [ Nat.geomSum_eq ];
        rw [ Finset.card_image_of_injOn ] at h_programs;
        · rw [ Finset.filter_true_of_mem ] at h_programs <;> norm_num at *;
          rw [ Finset.card_image_of_injective ] at h_programs <;> norm_num [ Function.Injective ] at *;
          exact Nat.not_le_of_gt ( Nat.sub_lt ( by norm_num ) ( by norm_num ) ) h_programs;
        · intro x hx y hy; have := hp₂ x; have := hp₂ y; aesop;

end
