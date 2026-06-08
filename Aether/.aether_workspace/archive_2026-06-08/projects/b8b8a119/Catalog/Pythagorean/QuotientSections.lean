import Mathlib

/-!
# Complexity-Optimal Quotient Sections and Cohomological Defects

This file proves that run-deduplication is the unique length-optimal section
for the free monoid modulo idempotency (`xx ~ x`), and that the sorting section
for the commutative quotient is not a monoid homomorphism.

## Main results

* `runDedup_minimal_length` — Run-deduplication achieves minimum length in each
  idempotent equivalence class.
* `runDedup_unique_min_length` — The minimum-length representative is unique.
* `sortSection_not_hom` — The sorting section is not a monoid homomorphism
  when the alphabet has at least two elements.
-/

variable {X : Type*} [DecidableEq X]

/-! ## Run deduplication -/

/-- Run deduplication: collapse consecutive duplicate elements.
    For example, `[1,1,2,2,3,1,1]` becomes `[1,2,3,1]`. -/
def runDedup : List X → List X
  | [] => []
  | [x] => [x]
  | x :: y :: rest => if x = y then runDedup (y :: rest) else x :: runDedup (y :: rest)

@[simp] lemma runDedup_nil : runDedup ([] : List X) = [] := rfl
@[simp] lemma runDedup_singleton (x : X) : runDedup [x] = [x] := rfl

lemma runDedup_cons_cons (x y : X) (rest : List X) :
    runDedup (x :: y :: rest) =
      if x = y then runDedup (y :: rest) else x :: runDedup (y :: rest) := by
  simp [runDedup]

@[simp] lemma runDedup_cons_cons_eq (x : X) (rest : List X) :
    runDedup (x :: x :: rest) = runDedup (x :: rest) := by
  simp [runDedup]

lemma runDedup_cons_cons_ne {x y : X} (h : x ≠ y) (rest : List X) :
    runDedup (x :: y :: rest) = x :: runDedup (y :: rest) := by
  simp [runDedup, h]

/-! ## Basic properties of runDedup -/

/-
The head of `runDedup (a :: l)` is always `a`.
-/
lemma runDedup_head_cons (a : X) (l : List X) :
    (runDedup (a :: l)).head? = some a := by
      induction' l with b l ih generalizing a;
      · rfl;
      · by_cases h : a = b <;> simp +decide [ *, runDedup_cons_cons ]

/-
runDedup of a nonempty list is nonempty.
-/
lemma runDedup_cons_ne_nil (a : X) (l : List X) :
    runDedup (a :: l) ≠ [] := by
      induction' l with b l ihizing a;
      · grind +locals;
      · cases eq_or_ne a b <;> simp_all +decide [ runDedup_cons_cons ]

/-
runDedup never increases length.
-/
lemma runDedup_length_le (w : List X) : (runDedup w).length ≤ w.length := by
  induction' w with x w ih;
  · rfl;
  · induction' w with y w ih' <;> simp_all +decide [ runDedup_cons_cons ];
    grind

/-
If runDedup preserves the length, the list was already deduplicated.
-/
lemma runDedup_eq_of_length_eq (w : List X) (h : (runDedup w).length = w.length) :
    runDedup w = w := by
      induction' w with x l ih <;> simp_all +decide [ List.length ];
      rcases l with ( _ | ⟨ y, l ⟩ ) <;> simp_all +decide [ List.length ];
      by_cases hxy : x = y <;> simp_all +decide [ runDedup_cons_cons ];
      exact absurd h ( by linarith [ show List.length ( runDedup ( y :: l ) ) ≤ l.length + 1 from by simpa using runDedup_length_le ( y :: l ) ] )

/-
runDedup is idempotent.
-/
lemma runDedup_idem (w : List X) : runDedup (runDedup w) = runDedup w := by
  induction' w with x w ih;
  · rfl;
  · induction' w with y w ih generalizing x <;> (simp_all +decide [ runDedup_cons_cons ] ;);
    cases h : runDedup ( y :: w ) <;> simp_all +decide [ runDedup_cons_cons ];
    · exact absurd h ( runDedup_cons_ne_nil _ _ );
    · split_ifs <;> simp_all +decide [ runDedup_cons_cons ];
      have := runDedup_head_cons y w; aesop;

/-! ## Structural interaction with cons and append -/

/-
Key structural lemma: runDedup commutes with prepending an element
    up to applying runDedup to the tail.
-/
lemma runDedup_cons_runDedup (a : X) (l : List X) :
    runDedup (a :: runDedup l) = runDedup (a :: l) := by
      induction' n : l.length using Nat.strong_induction_on with n ih generalizing l a;
      rcases l with ( _ | ⟨ b, _ | ⟨ c, l ⟩ ⟩ ) <;> simp_all +decide;
      by_cases h : b = c <;> simp_all +decide [ runDedup_cons_cons ];
      · convert ih ( l.length + 1 ) ( by linarith ) a ( c :: l ) rfl using 1;
      · grind +suggestions

/-
runDedup absorbs deduplication of a left factor.
-/
lemma runDedup_append_left (u w : List X) :
    runDedup (runDedup u ++ w) = runDedup (u ++ w) := by
      induction' u with a u ih generalizing w;
      · exact?;
      · cases' u with b u;
        · aesop;
        · by_cases h : a = b <;> simp_all +decide [ runDedup_cons_cons ];
          convert congr_arg ( fun x => a :: x ) ( ih w ) using 1;
          convert runDedup_cons_cons_ne h _ using 1;
          convert runDedup_cons_runDedup a _ using 1;
          convert runDedup_cons_runDedup a _ using 1;
          rotate_right 1;
          exact u ++ w;
          · rw [ ← ih ];
            rw [ runDedup_idem ];
            grind +suggestions;
          · rw [ ih ]

/-
runDedup absorbs deduplication of a right factor.
-/
lemma runDedup_append_right (w u : List X) :
    runDedup (w ++ runDedup u) = runDedup (w ++ u) := by
      induction' w with a w ih generalizing u;
      · simp +decide [ runDedup_idem ];
      · cases w <;> simp_all +decide [ runDedup_cons_cons_ne ];
        · exact?;
        · grind +locals

/-! ## Idempotent equivalence -/

/-- Idempotent equivalence: the smallest congruence on `List X` (as a monoid
    under `++`) containing `xx ~ x` for every letter `x`. -/
inductive IdempotentEquiv : List X → List X → Prop
  | refl (w) : IdempotentEquiv w w
  | idem_contract (x : X) (w) : IdempotentEquiv (x :: x :: w) (x :: w)
  | idem_expand (x : X) (w) : IdempotentEquiv (x :: w) (x :: x :: w)
  | trans {u v w} : IdempotentEquiv u v → IdempotentEquiv v w → IdempotentEquiv u w
  | app_left {u v} (w) : IdempotentEquiv u v → IdempotentEquiv (u ++ w) (v ++ w)
  | app_right {u v} (w) : IdempotentEquiv u v → IdempotentEquiv (w ++ u) (w ++ v)

/-
Every word is idempotent-equivalent to its run-deduplicated form.
-/
lemma idempotentEquiv_runDedup (w : List X) : IdempotentEquiv w (runDedup w) := by
  induction' w with x w ih;
  · constructor;
  · induction' w with y w ih generalizing x;
    · exact IdempotentEquiv.refl _;
    · by_cases h : x = y <;> simp_all +decide [ runDedup_cons_cons ];
      · exact IdempotentEquiv.trans ( IdempotentEquiv.idem_contract _ _ ) ih;
      · -- By the app_right property, we can apply the induction hypothesis to the right-hand side.
        apply IdempotentEquiv.app_right [x] ih

/-
runDedup is invariant under idempotent equivalence.
-/
theorem runDedup_invariant {w w' : List X} (h : IdempotentEquiv w w') :
    runDedup w = runDedup w' := by
      induction' h;
      grobner;
      · exact?;
      · exact?;
      · grind;
      · rename_i u v w huv ih;
        rw [ ← runDedup_append_left, ← runDedup_append_left, ih ];
        rw [ runDedup_idem, runDedup_append_left ];
      · rename_i u v w huv ih;
        rw [ ← runDedup_append_right, ih, runDedup_append_right ]

/-! ## Main optimality theorems -/

/-- **Theorem 1a**: Run-deduplication achieves the minimum possible length
    among all representatives in each idempotent equivalence class. -/
theorem runDedup_minimal_length (w : List X) :
    ∀ w' : List X, IdempotentEquiv w w' → w'.length ≥ (runDedup w).length := by
  intro w' hw'
  have hinv := runDedup_invariant hw'
  calc (runDedup w).length = (runDedup w').length := by rw [hinv]
    _ ≤ w'.length := runDedup_length_le w'

/-- **Theorem 1b**: The minimum-length representative is unique: if `w'` is
    idempotent-equivalent to `w` and has the same length as `runDedup w`,
    then `w' = runDedup w`. -/
theorem runDedup_unique_min_length (w : List X) :
    ∀ w' : List X, IdempotentEquiv w w' → w'.length = (runDedup w).length →
      w' = runDedup w := by
  intro w' hw' hlen
  have hinv := runDedup_invariant hw'
  have hlen' : (runDedup w').length = w'.length := by
    have h1 := runDedup_length_le w'
    rw [hinv] at hlen
    omega
  rw [← runDedup_eq_of_length_eq w' hlen', hinv]

/-! ## Sorting section and its non-homomorphism property -/

/-- The sorting section: returns the sorted representative of a list. -/
noncomputable def sortSection [LinearOrder X] : List X → List X :=
  fun l => l.mergeSort (· ≤ ·)

/-
**Theorem 2**: The sorting section is not a monoid homomorphism when
    the alphabet has at least two distinct elements. The concatenation of
    sorted singletons `[b] ++ [a]` differs from sorting their concatenation
    `sort [b, a]` when `a < b`.
-/
omit [DecidableEq X] in
theorem sortSection_not_hom [LinearOrder X]
    {a b : X} (hlt : a < b) :
    sortSection [b] ++ sortSection [a] ≠ sortSection ([b] ++ [a]) := by
      simp +decide [ sortSection, List.mergeSort ];
      simp +decide [ List.merge ];
      lia