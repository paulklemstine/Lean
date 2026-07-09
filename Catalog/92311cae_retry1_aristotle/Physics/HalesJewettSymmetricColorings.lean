import Mathlib

/-!
# Symmetric colorings of Hales–Jewett cubes are exactly the one-weight colorings

A *word* of length `n` over the alphabet `[t] = {0, 1, …, t-1}` is a function
`x : Fin n → Fin t`; the collection of all such words is the Hales–Jewett cube
`[t]^n`.  A *coloring* with palette `C` is a function `c : (Fin n → Fin t) → C`.

Two natural symmetry conditions on a coloring are:

* **Symmetric** (`IsSymmetric`): the color is invariant under permuting the
  coordinates of a word, i.e. `c (x ∘ σ) = c x` for every permutation `σ` of the
  positions.  Equivalently, the color depends only on the *content* of the word —
  how many times each letter occurs.

* **One-weight** (`IsOneWeight`): there are integer weights `w₀, …, w_{t-1}` and a
  function `f` such that the color of `x` depends only on the weighted letter sum
  `∑ᵢ w_{x ᵢ}`.

The main results establish that these two notions coincide:

* `oneWeight_isSymmetric` — every one-weight coloring is symmetric;
* `symmetric_isOneWeight` — every symmetric coloring is one-weight.

The reverse direction is the substantive one: given a symmetric coloring one must
*manufacture* weights that separate distinct contents.  Choosing the base-`(n+1)`
weights `w_j = (n+1)^j` renders the weighted sum a faithful positional encoding of
the content vector, because every letter-multiplicity lies in `{0, …, n}`.  Thus
equal weighted sums force equal contents, and a symmetric coloring cannot tell
apart two words of equal content.

This equivalence reduces the symmetric lower-bound problem for Hales–Jewett
numbers to the one-dimensional case of Gallai's theorem on homothetic copies of a
`t`-point set in `ℤ`.

## Lab Notes

`-- !-- Lab Notes -- !--`

* **Hypothesis.** Symmetric colorings should be precisely those factoring through a
  single integer linear functional of the content vector.
* **Experiment.** Formalized both directions.  The forward direction is a one-line
  invariance of a sum under reindexing.  The reverse direction required a positional
  (base-`(n+1)`) encoding to guarantee injectivity of content ↦ weighted sum, and a
  sorting argument to convert equal contents into an explicit coordinate permutation.
* **Analysis.** The naive guess "weights independent of `n`" is *false*: contents
  live in a `(t-1)`-dimensional simplex, so no fixed weight vector separates them for
  all `n`.  The dependence of the weights on `n` is essential and is what makes the
  statement an existence theorem rather than a universal one.
* **Critique.** A degenerate corner (`C` empty with a nonempty cube) would make the
  one-weight predicate unsatisfiable while symmetry holds vacuously; we guard the
  reverse direction with `[Nonempty C]`, which every genuine palette satisfies.
* **Synthesis.** Symmetric ⇔ one-weight, with base-`(n+1)` weights realizing the
  equivalence constructively.
-/

open Finset BigOperators

namespace HalesJewettSymmetric

variable {t n : ℕ} {C : Type*}

/-- The *content* of a word at letter `j`: the number of coordinates equal to `j`. -/
def content (x : Fin n → Fin t) (j : Fin t) : ℕ :=
  (Finset.univ.filter (fun i => x i = j)).card

/-- A coloring is *symmetric* if it is invariant under permuting the coordinates. -/
def IsSymmetric (c : (Fin n → Fin t) → C) : Prop :=
  ∀ (σ : Equiv.Perm (Fin n)) (x : Fin n → Fin t), c (x ∘ σ) = c x

/-- A coloring is *one-weight* if the color depends only on a fixed integer-weighted
letter sum. -/
def IsOneWeight (c : (Fin n → Fin t) → C) : Prop :=
  ∃ (w : Fin t → ℤ) (f : ℤ → C), ∀ x, c x = f (∑ i, w (x i))

/-! ### Elementary facts about content -/

/--
Each content is at most the length of the word.
-/
theorem content_le (x : Fin n → Fin t) (j : Fin t) : content x j ≤ n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by simp )

/--
The content is the `Multiset.count` of the letter in the multiset of letters.
-/
theorem content_eq_count (x : Fin n → Fin t) (j : Fin t) :
    content x j = Multiset.count j (Multiset.map x Finset.univ.val) := by
  rw [ Multiset.count_map ];
  exact congrArg Finset.card ( Finset.filter_congr fun _ _ => eq_comm )

/-! ### One-weight ⟹ symmetric -/

/--
Every one-weight coloring is symmetric: permuting coordinates leaves the weighted
letter sum unchanged.
-/
theorem oneWeight_isSymmetric (c : (Fin n → Fin t) → C) (h : IsOneWeight c) :
    IsSymmetric c := by
  obtain ⟨w, f, hf⟩ := h
  intro σ x
  rw [hf, hf]
  congr 1
  exact Equiv.sum_comp σ (fun i => w (x i))

/-! ### Contents determine words up to a coordinate permutation -/

/--
Two words with the same content are related by a permutation of coordinates.
-/
theorem perm_of_content_eq {x y : Fin n → Fin t}
    (h : ∀ j, content x j = content y j) : ∃ σ : Equiv.Perm (Fin n), x ∘ σ = y := by
  obtain ⟨σ₁, hσ₁⟩ : ∃ σ₁ : Equiv.Perm (Fin n), Monotone (x ∘ σ₁) := by
    exact ⟨ Tuple.sort x, Tuple.monotone_sort x ⟩
  obtain ⟨σ₂, hσ₂⟩ : ∃ σ₂ : Equiv.Perm (Fin n), Monotone (y ∘ σ₂) := by
    exact ⟨ Tuple.sort y, fun _ _ hle => Tuple.monotone_sort y hle ⟩;
  -- By `List.ofFn`, we have `List.ofFn (x ∘ σ₁) = (List.ofFn (x ∘ σ₁)).Perm (List.ofFn (y ∘ σ₂))`.
  have h_perm : (List.ofFn (x ∘ σ₁)).Perm (List.ofFn (y ∘ σ₂)) := by
    rw [ List.ofFn_eq_map, List.ofFn_eq_map ];
    rw [ List.perm_iff_count ];
    intro j; have := h j; simp_all +decide [ List.count, content ] ;
    simp_all +decide [ List.countP_eq_length_filter ];
    convert h j using 1 <;> rw [ ← Multiset.coe_card ] <;> rw [ ← Multiset.toFinset_card_of_nodup ] <;> norm_num [ List.nodup_finRange ];
    · rw [ Finset.card_filter, Finset.card_filter ];
      conv_rhs => rw [ ← Equiv.sum_comp σ₁ ] ;
    · exact List.Nodup.filter _ ( List.nodup_finRange _ );
    · rw [ Finset.card_filter, Finset.card_filter ];
      conv_rhs => rw [ ← Equiv.sum_comp σ₂ ] ;
    · exact List.Nodup.filter _ ( List.nodup_finRange _ );
  -- By `List.eq_of_perm_of_sorted`, we have `List.ofFn (x ∘ σ₁) = List.ofFn (y ∘ σ₂)`.
  have h_eq : List.ofFn (x ∘ σ₁) = List.ofFn (y ∘ σ₂) := by
    apply List.Perm.eq_of_pairwise;
    case le => exact fun a b => a ≤ b;
    · exact fun a b ha hb hab hba => le_antisymm hab hba;
    · rw [ List.pairwise_ofFn ];
      exact fun i j hij => hσ₁ hij.le;
    · simp +decide [ List.pairwise_ofFn ];
      exact fun i j hij => hσ₂ hij.le;
    · exact h_perm;
  simp_all +decide [ funext_iff, List.ofFn_inj ];
  exact ⟨ σ₁ * σ₂.symm, fun i => by simpa using h_eq ( σ₂.symm i ) ⟩

/-- A symmetric coloring assigns the same color to words of equal content. -/
theorem symmetric_color_eq_of_content (c : (Fin n → Fin t) → C) (hc : IsSymmetric c)
    {x y : Fin n → Fin t} (h : ∀ j, content x j = content y j) : c x = c y := by
  obtain ⟨σ, hσ⟩ := perm_of_content_eq h
  rw [← hσ]
  exact (hc σ x).symm

/-! ### The base-`(n+1)` weighted sum is a faithful encoding of the content -/

/--
Grouping a letter-indexed sum by content.
-/
theorem weightsum_group (F : Fin t → ℕ) (x : Fin n → Fin t) :
    ∑ i, F (x i) = ∑ j : Fin t, content x j * F j := by
  simp +decide [ content ];
  simp +decide only [card_filter, Finset.sum_mul _ _ _];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop

/--
The base-`b` positional value of a length-`t` digit tuple.
-/
theorem ofDigits_ofFn (b : ℕ) (a : Fin t → ℕ) :
    Nat.ofDigits b (List.ofFn a) = ∑ j : Fin t, a j * b ^ (j : ℕ) := by
  induction' t with t ih <;> simp_all +decide [ Nat.ofDigits, Fin.sum_univ_succ ];
  simp +decide only [Finset.mul_sum _ _ _, pow_succ', mul_left_comm]

/--
**Key injectivity.**  Over the natural numbers, equality of the base-`(n+1)`
weighted letter sums forces equality of contents.
-/
theorem content_eq_of_natweightsum {x y : Fin n → Fin t}
    (h : ∑ i, (n + 1) ^ (x i : ℕ) = ∑ i, (n + 1) ^ (y i : ℕ)) :
    ∀ j, content x j = content y j := by
  by_contra! h_contra;
  -- By `weightsum_group`, we can rewrite the hypothesis `h` in terms of the content vectors.
  have h_content : ∑ j : Fin t, content x j * (n + 1) ^ (j : ℕ) = ∑ j : Fin t, content y j * (n + 1) ^ (j : ℕ) := by
    convert h using 1;
    · convert weightsum_group ( fun j => ( n + 1 ) ^ ( j : ℕ ) ) x |> Eq.symm using 1;
    · convert weightsum_group ( fun j => ( n + 1 ) ^ ( j : ℕ ) ) y |> Eq.symm using 1;
  obtain ⟨j, hj⟩ : ∃ j : Fin t, content x j ≠ content y j := h_contra
  have h_eq : Nat.ofDigits (n + 1) (List.ofFn (fun j => content x j)) = Nat.ofDigits (n + 1) (List.ofFn (fun j => content y j)) := by
    rw [ ofDigits_ofFn, ofDigits_ofFn ] ; aesop;
  rcases n with ( _ | n ) <;> simp_all +decide;
  · exact hj ( by unfold content; aesop );
  · have := Nat.ofDigits_inj_of_len_eq ( show 1 < n + 1 + 1 from by linarith ) ( by simp +decide [ List.length_ofFn ] ) ( by intros l hl; rw [ List.mem_ofFn ] at hl; obtain ⟨ i, rfl ⟩ := hl; exact Nat.lt_succ_of_le ( content_le _ _ ) ) ( by intros l hl; rw [ List.mem_ofFn ] at hl; obtain ⟨ i, rfl ⟩ := hl; exact Nat.lt_succ_of_le ( content_le _ _ ) ) h_eq; simp_all +decide;

/--
The integer version of the injectivity statement.
-/
theorem content_eq_of_weightsum {x y : Fin n → Fin t}
    (h : ∑ i, ((n : ℤ) + 1) ^ (x i : ℕ) = ∑ i, ((n : ℤ) + 1) ^ (y i : ℕ)) :
    ∀ j, content x j = content y j := by
  exact_mod_cast content_eq_of_natweightsum ( by exact_mod_cast h )

/-! ### Symmetric ⟹ one-weight -/

/-- **Main theorem.**  Every symmetric coloring of the Hales–Jewett cube `[t]^n` is a
one-weight coloring: the base-`(n+1)` weights `w_j = (n+1)^j` realize it. -/
theorem symmetric_isOneWeight [Nonempty C] (c : (Fin n → Fin t) → C)
    (hc : IsSymmetric c) : IsOneWeight c := by
  classical
  refine ⟨fun j => ((n : ℤ) + 1) ^ (j : ℕ),
    fun s => if h : ∃ x : Fin n → Fin t, ∑ i, ((n : ℤ) + 1) ^ (x i : ℕ) = s
      then c h.choose else Classical.arbitrary C, ?_⟩
  intro x
  have hex : ∃ z : Fin n → Fin t, ∑ i, ((n : ℤ) + 1) ^ (z i : ℕ) = ∑ i, ((n : ℤ) + 1) ^ (x i : ℕ) :=
    ⟨x, rfl⟩
  show c x = if h : ∃ z : Fin n → Fin t, ∑ i, ((n : ℤ) + 1) ^ (z i : ℕ) = ∑ i, ((n : ℤ) + 1) ^ (x i : ℕ)
      then c h.choose else Classical.arbitrary C
  rw [dif_pos hex]
  apply symmetric_color_eq_of_content c hc
  exact content_eq_of_weightsum hex.choose_spec.symm

/-- **Equivalence.**  A coloring of `[t]^n` with a nonempty palette is symmetric if and
only if it is one-weight. -/
theorem symmetric_iff_oneWeight [Nonempty C] (c : (Fin n → Fin t) → C) :
    IsSymmetric c ↔ IsOneWeight c :=
  ⟨symmetric_isOneWeight c, oneWeight_isSymmetric c⟩

end HalesJewettSymmetric