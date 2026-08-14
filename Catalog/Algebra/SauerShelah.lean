import Mathlib

open Fin

/-! # CatalogBuild.Algebra.SauerShelah

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 17
-/


/-- A family `F` of sets **shatters** a set `A` if every subset of `A` arises as
`A ∩ S` for some `S ∈ F`. -/
def Shatters {n : ℕ} (F : Finset (Finset (Fin n))) (A : Finset (Fin n)) : Prop :=
  ∀ B ⊆ A, ∃ S ∈ F, A ∩ S = B




/-- Drop the last coordinate: keep `i : Fin n` iff `castSucc i ∈ S`. -/
def proj {n : ℕ} (S : Finset (Fin (n + 1))) : Finset (Fin n) :=
  Finset.univ.filter fun i => i.castSucc ∈ S




/-- Embed via `castSucc`. -/
def embed {n : ℕ} (T : Finset (Fin n)) : Finset (Fin (n + 1)) :=
  T.image Fin.castSucc

-- ================================================================
--  Basic proj / embed API
-- ================================================================

@[simp] lemma mem_proj {n : ℕ} {S : Finset (Fin (n + 1))} {i : Fin n} :
    i ∈ proj S ↔ i.castSucc ∈ S := by simp [proj]




/-- [Section: # CatalogBuild.Algebra.SauerShelah
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 17] -/
lemma last_not_mem_embed {n : ℕ} (T : Finset (Fin n)) :
    Fin.last n ∉ embed T := by
      simp +decide [ embed ]




/-- [Section: # CatalogBuild.Algebra.SauerShelah
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 17] -/
lemma proj_embed {n : ℕ} (T : Finset (Fin n)) : proj (embed T) = T := by
  -- By definition of `proj`, we have `proj (embed T) = Finset.univ.filter (fun i => i.castSucc ∈ T.image Fin.castSucc)`.
  simp [proj, embed]




lemma proj_embed_union_last {n : ℕ} (T : Finset (Fin n)) :
    proj (embed T ∪ {Fin.last n}) = T := by
      unfold proj embed; aesop;




lemma embed_card {n : ℕ} (T : Finset (Fin n)) : (embed T).card = T.card := by
  exact Finset.card_image_of_injective _ ( Fin.castSucc_injective _ )




lemma embed_union_last_card {n : ℕ} (T : Finset (Fin n)) :
    (embed T ∪ {Fin.last n}).card = T.card + 1 := by
      rw [ Finset.card_union, embed_card ] ; simp +decide [ last_not_mem_embed ]




lemma embed_inter_eq {n : ℕ} (A : Finset (Fin n)) (S : Finset (Fin (n + 1))) :
    embed A ∩ S = embed (A ∩ proj S) := by
      ext x; simp [embed, proj] ;
      grind +ring




lemma eq_embed_proj_of_last_not_mem {n : ℕ} {S : Finset (Fin (n + 1))}
    (h : Fin.last n ∉ S) : S = embed (proj S) := by
      -- By definition of $proj$ and $embed$, we know that $x \in S$ if and only if $x \in embed (proj S)$.
      ext x; simp [embed, proj];
      cases x using Fin.lastCases <;> aesop




lemma eq_embed_proj_union_last {n : ℕ} {S : Finset (Fin (n + 1))}
    (h : Fin.last n ∈ S) : S = embed (proj S) ∪ {Fin.last n} := by
      ext x; by_cases hx : x = last n <;> simp_all +decide [ Fin.ext_iff, Fin.val_add, Fin.val_one ] ;
      · rwa [ show x = last n from Fin.ext hx ];
      · simp +decide [ Fin.ext_iff, Fin.val_add, Fin.val_one, hx, embed, proj ];
        exact ⟨ fun hx' => ⟨ ⟨ x, lt_of_le_of_ne ( Fin.le_last _ ) hx ⟩, by simpa [ Fin.ext_iff ] using hx', rfl ⟩, by rintro ⟨ a, ha, ha' ⟩ ; convert ha; aesop ⟩




lemma shatters_embed_of_union {n : ℕ} (F : Finset (Finset (Fin (n + 1))))
    {A : Finset (Fin n)}
    (h : Shatters ((F.filter (Fin.last n ∉ ·)).image proj ∪
                    (F.filter (Fin.last n ∈ ·)).image proj) A) :
    Shatters F (embed A) := by
      intro B hB
      obtain ⟨T, hT⟩ : ∃ T ∈ Finset.image proj ({x ∈ F | last n ∉ x}) ∪ Finset.image proj ({x ∈ F | last n ∈ x}), A ∩ T = proj B := by
        exact h _ ( Finset.subset_iff.mpr fun i hi => by
          simp_all +decide [ Finset.subset_iff, proj, embed ];
          cases hB hi ; aesop );
      obtain ⟨S, hS⟩ : ∃ S ∈ F, T = proj S := by
        aesop;
      use S, hS.left;
      have h_eq : B = embed (proj B) := by
        apply eq_embed_proj_of_last_not_mem;
        intro h_last_in_B; have := hB h_last_in_B; simp_all +decide [ embed ] ;
      convert embed_inter_eq A S using 1;
      simpa only [ ← hS.2, hT.2 ] using h_eq




lemma shatters_embed_union_last_of_inter {n : ℕ} (F : Finset (Finset (Fin (n + 1))))
    {A : Finset (Fin n)}
    (h : Shatters ((F.filter (Fin.last n ∉ ·)).image proj ∩
                    (F.filter (Fin.last n ∈ ·)).image proj) A) :
    Shatters F (embed A ∪ {Fin.last n}) := by
      -- Let B be a subset of embed A ∪ {last n}. We need to find S ∈ F such that (embed A ∪ {last n}) ∩ S = B.
      intro B hB
      by_cases h_last : Fin.last n ∈ B;
      · obtain ⟨T, hT⟩ : ∃ T ∈ (F.filter (Fin.last n∉ ·)).image proj ∩ (F.filter (Fin.last n ∈ ·)).image proj, A ∩ T = proj B := by
          apply h;
          intro i hi; specialize hB ( show Fin.castSucc i ∈ B from ?_ ) ; aesop;
          unfold embed at hB; aesop;
        obtain ⟨S₁, hS₁⟩ : ∃ S₁ ∈ F, Fin.last n∉ S₁ ∧ proj S₁ = T := by
          aesop
        obtain ⟨S₂, hS₂⟩ : ∃ S₂ ∈ F, Fin.last n ∈ S₂ ∧ proj S₂ = T := by
          aesop;
        use S₂; simp_all +decide [ Finset.ext_iff ] ;
        intro a; specialize hB; have := @hB a; simp_all +decide [ Finset.subset_iff ] ;
        cases a using Fin.lastCases <;> simp_all +decide [ embed ];
      · -- Since $last n \notin B$, we have $B \subseteq embed A$.
        have hB_subset : B ⊆ embed A := by
          intro x hx; specialize hB hx; aesop;
        -- Since $B \subseteq embed A$, there exists $T \in F₀ \cap F₁$ such that $A \cap T = proj B$.
        obtain ⟨T, hT⟩ : ∃ T ∈ (F.filter (Fin.last n∉·)).image proj ∩ (F.filter (Fin.last n ∈ ·)).image proj, A ∩ T = proj B := by
          apply h (proj B) (by
          simp_all +decide [ Finset.subset_iff ];
          intro x hx; specialize hB_subset hx; unfold embed at hB_subset; aesop;);
        obtain ⟨S₀, hS₀⟩ : ∃ S₀ ∈ F, Fin.last n∉S₀ ∧ proj S₀ = T := by
          aesop
        obtain ⟨S₁, hS₁⟩ : ∃ S₁ ∈ F, Fin.last n ∈ S₁ ∧ proj S₁ = T := by
          aesop;
        use S₀;
        simp_all +decide [ Finset.ext_iff ];
        intro a; induction a using Fin.lastCases <;> simp_all +decide [ embed ] ;




lemma card_split {n : ℕ} (F : Finset (Finset (Fin (n + 1)))) :
    F.card = ((F.filter (Fin.last n ∉ ·)).image proj ∪
              (F.filter (Fin.last n ∈ ·)).image proj).card +
             ((F.filter (Fin.last n ∉ ·)).image proj ∩
              (F.filter (Fin.last n ∈ ·)).image proj).card := by
                -- By definition of $F₀$ and $F₁$, we have $F = F₀ ∪ F₁$.
                have h_union : F = Finset.filter (Fin.last n∉·) F ∪ Finset.filter (Fin.last n∈·) F := by
                  grind +ring;
                -- By definition of $F₀$ and $F₁$, we have $|F₀| = |\text{proj}(F₀)|$ and $|F₁| = |\text{proj}(F₁)|$.
                have h_card_F₀ : (Finset.filter (Fin.last n∉·) F).card = (Finset.image proj (Finset.filter (Fin.last n∉·) F)).card := by
                  rw [ Finset.card_image_of_injOn ];
                  intro x hx y hy; simp +decide [ Finset.ext_iff ] at *;
                  intro h a; induction a using Fin.lastCases <;> simp_all +singlePass ;
                have h_card_F₁ : (Finset.filter (Fin.last n∈·) F).card = (Finset.image proj (Finset.filter (Fin.last n∈·) F)).card := by
                  rw [ Finset.card_image_of_injOn ];
                  intro x hx y hy; simp +decide [ Finset.ext_iff ] at *;
                  intro h a; induction a using Fin.lastCases <;> simp +decide [ * ] ;
                conv_lhs => rw [ h_union ];
                rw [ Finset.card_union_add_card_inter ];
                rw [ ← h_card_F₀, ← h_card_F₁, Finset.card_union_of_disjoint ] ; exact Finset.disjoint_filter.mpr fun _ _ _ _ => by tauto;




lemma binomial_pascal_sum (n d : ℕ) :
    (∑ i ∈ Finset.range (d + 1), n.choose i) +
     ∑ i ∈ Finset.range d, n.choose i =
    ∑ i ∈ Finset.range (d + 1), (n + 1).choose i := by
      induction' d with d ih;
      · norm_num;
      · simp_all +arith +decide [ Nat.choose, Finset.sum_range_succ ]




lemma card_le_one_of_vc_zero {n : ℕ} (F : Finset (Finset (Fin n)))
    (hF : ∀ A, Shatters F A → A.card ≤ 0) : F.card ≤ 1 := by
      contrapose! hF;
      -- Since F has more than one element, there exist S₁ ≠ S₂ ∈ F.
      obtain ⟨S₁, S₂, hS₁, hS₂, hne⟩ : ∃ S₁ S₂ : Finset (Fin n), S₁ ∈ F ∧ S₂ ∈ F ∧ S₁ ≠ S₂ := by
        exact Finset.one_lt_card_iff.mp hF
      -- Since S₁ ≠ S₂, there exists x with x ∈ S₁ and x ∉ S₂ (or vice versa), WLOG x ∈ S₁, x ∉ S₂.
      obtain ⟨x, hx₁, hx₂⟩ : ∃ x : Fin n, x ∈ S₁ ∧ x∉ S₂ ∨ x∉ S₁ ∧ x ∈ S₂ := by
        exact Classical.not_forall_not.1 fun h => hne <| Finset.ext fun x => by by_cases hx₁ : x ∈ S₁ <;> by_cases hx₂ : x ∈ S₂ <;> simpa [ hx₁, hx₂ ] using h x;
      · use {x};
        unfold Shatters; aesop;
      · use {x};
        unfold Shatters; aesop;




/-- **Sauer–Shelah lemma.** A family of subsets of `Fin n` that shatters no set
of size greater than `d` contains at most `∑_{i=0}^{d} \binom{n}{i}` members. -/
theorem sauer_shelah : ∀ (n d : ℕ) (F : Finset (Finset (Fin n))),
    (∀ A, Shatters F A → A.card ≤ d) →
    F.card ≤ ∑ i ∈ Finset.range (d + 1), n.choose i := by
  intro n; induction n with
  | zero =>
    intro d F hF
    fin_cases F <;> simp +arith +decide [ Finset.sum_range_succ' ]
  | succ n ih =>
    intro d F hF
    cases d with
    | zero =>
      have h := card_le_one_of_vc_zero F hF
      simp; omega
    | succ d =>
      set F₀ := (F.filter (Fin.last n ∉ ·)).image proj
      set F₁ := (F.filter (Fin.last n ∈ ·)).image proj
      have hsplit := card_split F
      have hvc₀ : ∀ A, Shatters (F₀ ∪ F₁) A → A.card ≤ d + 1 := fun A hA => by
        have := hF _ (shatters_embed_of_union F hA); rwa [embed_card] at this
      have hvc₁ : ∀ A, Shatters (F₀ ∩ F₁) A → A.card ≤ d := fun A hA => by
        have := hF _ (shatters_embed_union_last_of_inter F hA)
        rw [embed_union_last_card] at this; omega
      have h_union := ih (d + 1) (F₀ ∪ F₁) hvc₀
      have h_inter := ih d (F₀ ∩ F₁) hvc₁
      have hpascal := binomial_pascal_sum n (d + 1)
      linarith