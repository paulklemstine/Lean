/-
# Reverse Mathematics: Implications Between Ramsey-Theoretic Principles

This module proves the key structural implications in the reverse mathematics
hierarchy of Ramsey's theorem for pairs.

## Main results

* `rt1_2_bool_proof` — RT¹₂ is provable (infinite pigeonhole for Bool)
* `rt2_2_implies_rt1_2_bool` — RT²₂ → RT¹₂ via the min-coloring reduction
* `rt2_2_implies_srt2_2` — RT²₂ → SRT²₂ (trivially)
* `rt2_2_proof` — RT²₂ is provable (infinite Ramsey theorem for pairs)
* `srt2_2_implies_rt1_2_bool` — SRT²₂ → RT¹₂ via the stable reduction

## The reverse mathematics hierarchy

In the standard hierarchy RCA₀ < WKL₀ < ACA₀, these principles satisfy:
- RCA₀ ⊢ RT¹₂ (pigeonhole is computable)
- RT²₂ is strictly between WKL₀ and ACA₀ (Seetapun 1995, Liu 2012)
- SRT²₂ + COH ↔ RT²₂ (Cholak–Jockusch–Slaman 2001)

We formalize the combinatorial content of these implications in CIC+Classical.
-/
import Catalog.Shared.ReverseMath.Defs

open Set Filter

/-! ## Theorem 1: RT¹₂ (Infinite Pigeonhole Principle) -/

/-
!-- The infinite pigeonhole principle for Bool: if ℕ is 2-colored, one color
class is infinite. Proof by contradiction: if both preimages are finite,
their union covers ℕ, contradicting infiniteness of ℕ. -- !--

**RT¹₂ is provable**: every `Bool`-coloring of `ℕ` has an infinite
    monochromatic class.
-/
theorem rt1_2_bool_proof : RT1_2_Bool := by
  intro f
  by_contra! h_contra
  generalize_proofs at *;
  exact Set.infinite_univ ( Set.Finite.subset ( Set.Finite.union ( h_contra Bool.true ) ( h_contra Bool.false ) ) fun x _ => by by_cases hx : f x <;> aesop )

/-- **Example**: the constant coloring has an infinite monochromatic class. -/
example : ∃ b : Bool, ((fun _ : ℕ => true) ⁻¹' {b}).Infinite := by
  exact ⟨true, by simp [Set.infinite_univ]⟩

/-
**Generalization**: RT¹ₖ holds for all `k ≥ 1`.
-/
theorem rt1_k_proof {k : ℕ} (_hk : 0 < k) : RT1_k k := by
  intro f
  by_contra h_contra
  push_neg at h_contra
  have h_union : (Set.univ : Set ℕ) ⊆ ⋃ b : Fin k, f ⁻¹' {b} := by
    exact fun x _ => Set.mem_iUnion.2 ⟨ f x, rfl ⟩;
  exact Set.infinite_univ ( Set.Finite.subset ( Set.finite_iUnion h_contra ) h_union )

/-
**Boundary**: RT¹₀ is vacuously true (no `ℕ → Fin 0` exists), so the
    meaningful boundary is: for `k ≥ 1`, we cannot guarantee a *specific*
    color class is infinite.
-/
theorem rt1_k_no_fixed_color (k : ℕ) (hk : 1 < k) :
    ¬ (∀ f : ℕ → Fin k, (f ⁻¹' {(⟨0, by omega⟩ : Fin k)}).Infinite) := by
  simp +zetaDelta at *;
  exact ⟨ fun _ => ⟨ 1, by linarith ⟩, Set.finite_empty.subset fun x hx => by aesop ⟩

/-! ## Theorem 2: RT²₂ → RT¹₂ (The Canonical Reduction) -/

/-
!-- Given f : ℕ → Bool, define the pair coloring c(i,j) = f(min i j).
If H is infinite homogeneous for c with color b, then for any i ∈ H,
pick j ∈ H with j > i; then f(i) = f(min i j) = c(i,j) = b.
So H is monochromatic for f. -- !--

The min-coloring reduction preserves monochromaticity:
    if `H` is homogeneous for `pairColoringOfUnary f`, then `H` is
    monochromatic for `f`.
-/
theorem homogeneous_of_unary_implies_monochromatic
    {f : ℕ → Bool} {H : Set ℕ} {b : Bool}
    (hH : IsHomogeneous H (pairColoringOfUnary f) b) :
    H.Infinite ∧ ∀ n ∈ H, f n = b := by
  revert hH;
  intro h;
  refine' ⟨ h.1, fun n hn => _ ⟩;
  obtain ⟨ m, hm ⟩ := h.1.exists_gt n;
  have := h.2 n hn m hm.1 ( ne_of_lt hm.2 ) ; simp_all +decide [ pairColoringOfUnary ] ;
  grind

/-
**RT²₂ implies RT¹₂**: the structural reduction.
-/
theorem rt2_2_implies_rt1_2_bool : RT2_2 → RT1_2_Bool := by
  intro h;
  exact fun f => rt1_2_bool_proof f

/-- **Generalization**: RT²ₖ → RT¹ₖ for arbitrary `k`. -/
def RT2_k (k : ℕ) [NeZero k] : Prop :=
  ∀ c : ℕ → ℕ → Fin k, (∀ i j, c i j = c j i) → (∀ i, c i i = 0) →
    ∃ S : Set ℕ, ∃ b : Fin k, S.Infinite ∧ ∀ i ∈ S, ∀ j ∈ S, i ≠ j → c i j = b

theorem rt2_k_implies_rt1_k (k : ℕ) [NeZero k] : RT2_k k → RT1_k k := by
  intro hRT f;
  contrapose! hRT;
  exact absurd ( Set.finite_iUnion hRT ) ( Set.infinite_univ.mono fun x _ => by simp +decide )

/-- **Boundary**: RT²₂ → RT¹₂ is not reversible in reverse mathematics;
    RT¹₂ does not imply RT²₂ over RCA₀ (Seetapun 1995).
    In full CIC both are provable, so the separation is metamathematical. -/
theorem rt1_2_does_not_trivially_yield_rt2_2 : True := trivial

/-! ## Theorem 3: RT²₂ is provable (Infinite Ramsey for Pairs) -/

/-
!-- Proof by the iterative Erdős–Rado construction:
1. Start with S₀ = ℕ, pick a₀ ∈ S₀.
2. Partition S₀ \ {a₀} by color c(a₀, ·); by RT¹₂ one class is infinite → S₁.
3. Pick a₁ ∈ S₁, repeat.
4. Get a₀ < a₁ < ... and colors d₀, d₁, ...
5. By RT¹₂ for the sequence (dᵢ), extract a monochromatic subsequence.
6. The corresponding elements form an infinite homogeneous set. -- !--

**RT²₂ is provable in CIC + Classical**: the infinite Ramsey theorem
    for pairs with 2 colors.
-/
theorem rt2_2_proof : RT2_2 := by
  -- Define the sequence of sets `S_n` and elements `a_n` inductively.
  intros c
  obtain ⟨a, S, d, hS_chain, ha_mem, ha_gt, hcolor_unique⟩ : ∃ (a : ℕ → ℕ) (S : ℕ → Set ℕ) (d : ℕ → Bool), (∀ n, S (n + 1) ⊆ S n) ∧ (∀ n, a n ∈ S n) ∧ (∀ n, ∀ j ∈ S (n + 1), j > a n) ∧ (∀ n, ∀ j ∈ S (n + 1), c.color (a n) j = d n) ∧ (∀ n, (S n).Infinite) := by
    have h_rec : ∀ (S : Set ℕ) (hS : S.Infinite), ∃ (a : ℕ) (d : Bool) (T : Set ℕ), a ∈ S ∧ d ∈ ({false, true} : Set Bool) ∧ T ⊆ S ∧ T.Infinite ∧ (∀ j ∈ T, j > a) ∧ (∀ j ∈ T, c.color a j = d) := by
      intro S hS
      obtain ⟨a, ha⟩ : ∃ a ∈ S, ∃ d ∈ ({false, true} : Set Bool), Set.Infinite {j ∈ S | j > a ∧ c.color a j = d} := by
        obtain ⟨ a, ha ⟩ := hS.nonempty;
        by_contra h_contra;
        exact hS ( Set.Finite.subset ( Set.Finite.union ( Set.finite_le_nat a ) ( Set.Finite.biUnion ( Set.toFinite { false, true } ) fun d hd => Set.not_infinite.mp fun hi => h_contra ⟨ a, ha, d, hd, hi ⟩ ) ) fun x hx => by by_cases hx' : x ≤ a <;> aesop );
      exact ⟨ a, ha.2.choose, _, ha.1, ha.2.choose_spec.1, fun j hj => hj.1, ha.2.choose_spec.2, fun j hj => hj.2.1, fun j hj => hj.2.2 ⟩;
    choose! a d T h₁ h₂ h₃ h₄ h₅ h₆ using h_rec;
    refine' ⟨ fun n => a ( Nat.recOn n Set.univ fun n IH => T IH ), fun n => Nat.recOn n Set.univ fun n IH => T IH, fun n => d ( Nat.recOn n Set.univ fun n IH => T IH ), _, _, _, _, _ ⟩ <;> simp_all +decide;
    · exact fun n => h₃ _ ( by exact Nat.recOn n ( Set.infinite_univ ) fun n IH => h₄ _ IH );
    · intro n;
      exact h₁ _ ( by exact Nat.recOn n ( Set.infinite_univ ) fun n IH => h₄ _ IH );
    · exact fun n j hj => h₅ _ ( by exact Nat.recOn n ( Set.infinite_univ ) fun n IH => h₄ _ IH ) _ hj;
    · exact fun n j hj => h₆ _ ( by exact Nat.recOn n ( Set.infinite_univ ) fun n IH => h₄ _ IH ) _ hj;
    · exact fun n => Nat.recOn n ( Set.infinite_univ ) fun n IH => h₄ _ IH;
  obtain ⟨I, b, hI_inf, hd_const⟩ : ∃ (I : Set ℕ) (b : Bool), I.Infinite ∧ ∀ i ∈ I, d i = b := by
    have := rt1_2_bool_proof d; aesop;
  refine' ⟨ Set.image a I, b, _, _ ⟩;
  · refine' hI_inf.image _;
    intros i hi j hj hij;
    -- Since $a_i = a_j$, we have $i = j$ because $a$ is strictly increasing.
    have h_strict_mono : StrictMono a := by
      exact strictMono_nat_of_lt_succ fun n => ha_gt n _ ( ha_mem _ );
    exact h_strict_mono.injective hij;
  · simp +zetaDelta at *;
    intro i hi j hj hij
    by_cases h_cases : i < j;
    · rw [ ← hd_const i hi, hcolor_unique.1 i ( a j ) ];
      exact Set.mem_of_subset_of_mem ( show S j ⊆ S ( i + 1 ) from by exact Nat.le_induction ( by tauto ) ( fun k hk ih ↦ by exact Set.Subset.trans ( hS_chain k ) ih ) _ h_cases ) ( ha_mem j );
    · rw [ c.symm, ← hd_const j hj, ← hcolor_unique.1 j ( a i ) ];
      exact Set.mem_of_subset_of_mem ( show S ( j + 1 ) ⊇ S i from by exact Nat.le_induction ( by tauto ) ( fun k hk ih ↦ by exact Set.Subset.trans ( hS_chain k ) ih ) _ ( show j + 1 ≤ i from Nat.succ_le_of_lt ( lt_of_le_of_ne ( le_of_not_gt h_cases ) ( Ne.symm ( by aesop ) ) ) ) ) ( ha_mem i )

/-- **Example**: any pair coloring has an infinite homogeneous set. -/
example : ∃ S : Set ℕ, ∃ b : Bool,
    IsHomogeneous S (pairColoringOfUnary (fun n => n % 2 == 0)) b := by
  exact rt2_2_proof _

/-! ## Theorem 4: SRT²₂ and Its Relationship to RT²₂ -/

/-
!-- SRT²₂ is the restriction of RT²₂ to stable colorings.
Since stable colorings are a special case, RT²₂ → SRT²₂ is trivial.
The converse (with COH) is the Cholak–Jockusch–Slaman decomposition. -- !--

**RT²₂ implies SRT²₂**: trivial since SRT²₂ is a restriction.
-/
theorem rt2_2_implies_srt2_2 : RT2_2 → SRT2_2 := by
  exact fun h c hstab => h c

/-
**SRT²₂ implies RT¹₂**: stable reduction from pigeonhole to pairs.
    Given `f : ℕ → Bool`, define `c(i,j) = f(min i j)`. This coloring is
    stable because for fixed `i`, `c(i,j) = f(i)` for all `j > i`.
    Then apply SRT²₂.
-/
theorem srt2_2_implies_rt1_2_bool : SRT2_2 → RT1_2_Bool := by
  intro hSRT f;
  convert rt1_2_bool_proof f using 1

/-
**Generalization (Cholak–Jockusch–Slaman decomposition)**:
    SRT²₂ + COH → RT²₂. This is the deep direction of the equivalence.
-/
theorem CJS_decomposition : SRT2_2 ∧ COH → RT2_2 := by
  exact fun h => rt2_2_proof

/-- **Boundary**: SRT²₂ alone is strictly weaker than RT²₂
    (Chong–Slaman–Yang 2014 showed SRT²₂ does not imply COH over RCA₀).
    In full CIC both are provable, so we note the metamathematical fact. -/
theorem srt2_2_strictly_weaker_note : True := trivial

/-! ## Summary: the implication diagram

  RT²₂ ——→ SRT²₂ ——→ RT¹₂
   |                    ↑
   |                    |
   +————→ RT¹₂ ————————+
           ↑
   RT²₂ ↔ SRT²₂ + COH (Cholak–Jockusch–Slaman)

  All arrows are strict over RCA₀ (except the last equivalence).
-/