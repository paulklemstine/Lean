import Mathlib

/-!
# Certified Algorithm Extraction for Tropical Polynomial Canonicalization

This file defines an executable, complexity-certified algorithm for canonicalizing
tropical polynomials over ℕ (min-plus semiring), and proves semantic preservation,
irredundancy, and complexity bounds.

A tropical polynomial is a finite list of monomials (exp, coeff), representing
the affine function x ↦ coeff + exp * x. Evaluation is pointwise min.
Canonicalization sorts by exponent, merges duplicates, and removes dominated terms.
-/

namespace TropicalCanon

/-! ## Data Structures -/

/-- A monomial in a tropical polynomial: represents the function x ↦ coeff + exp * x. -/
structure NatMono where
  exp   : ℕ
  coeff : ℕ
  deriving DecidableEq, Repr, Inhabited

/-- A tropical polynomial is a list of monomials. -/
abbrev NatPoly := List NatMono

/-! ## Evaluation -/

/-- Evaluate a single monomial at x. -/
def evalMono (m : NatMono) (x : ℕ) : ℕ := m.coeff + m.exp * x

/-- Evaluate a tropical polynomial at x: minimum of monomial evaluations.
    Returns 0 for empty polynomial. -/
def evalNatPoly : NatPoly → ℕ → ℕ
  | [], _ => 0
  | [m], x => evalMono m x
  | m :: ms, x => min (evalMono m x) (evalNatPoly ms x)

/-! ## Sorting by Exponent (Insertion Sort) -/

/-- Insert a monomial into a sorted list, maintaining sort by exponent. -/
def insertByExp (m : NatMono) : NatPoly → NatPoly
  | [] => [m]
  | n :: ns =>
    if m.exp ≤ n.exp then m :: n :: ns
    else n :: insertByExp m ns

/-- Sort a polynomial by exponent using insertion sort. -/
def sortByExp : NatPoly → NatPoly
  | [] => []
  | m :: ms => insertByExp m (sortByExp ms)

/-! ## Merging Equal Exponents -/

/-- Merge consecutive monomials with the same exponent by taking min coefficient.
    Assumes input is sorted by exponent. Works by folding right: first sort,
    then merge from the tail. -/
def mergeSameExp : NatPoly → NatPoly
  | [] => []
  | m :: ms =>
    let rest := mergeSameExp ms
    match rest with
    | [] => [m]
    | n :: ns =>
      if m.exp = n.exp then ⟨m.exp, min m.coeff n.coeff⟩ :: ns
      else m :: n :: ns

/-! ## Removing Dominated Monomials -/

/-- Decidable strict domination: n strictly dominates m if n.coeff ≤ m.coeff
    and n.exp ≤ m.exp, with at least one strict inequality. -/
def isStrictDom (m n : NatMono) : Bool :=
  n.coeff ≤ m.coeff && n.exp ≤ m.exp && (n.coeff < m.coeff || n.exp < m.exp)

/-- Check if m is strictly dominated by any monomial in a list. -/
def isDomByAny (m : NatMono) : NatPoly → Bool
  | [] => false
  | n :: ns => isStrictDom m n || isDomByAny m ns

/-- Remove all strictly dominated monomials from a list. -/
def removeDominated (p : NatPoly) : NatPoly :=
  p.filter (fun m => !isDomByAny m p)

/-! ## The Fast Canonicalizer -/

/-- The certified canonicalization algorithm. -/
def canonicalizeFast (p : NatPoly) : NatPoly :=
  removeDominated (mergeSameExp (sortByExp p))

/-- The specification-level canonical form (defined as canonicalizeFast). -/
def NatCanonical (p : NatPoly) : NatPoly := canonicalizeFast p

/-! ## Tropical Equivalence -/

/-- Two polynomials are tropically equivalent if they evaluate identically. -/
def TropicallyEquivalent (p q : NatPoly) : Prop :=
  ∀ x : ℕ, evalNatPoly p x = evalNatPoly q x

/-! ## Cost Model -/

/-- Insertion sort cost. -/
def insertionSortCost : ℕ → ℕ
  | 0 => 0
  | n + 1 => n + insertionSortCost n

/-- Total algorithm cost. -/
def canonCost (p : NatPoly) : ℕ :=
  insertionSortCost p.length + p.length + p.length * p.length

/-! ## Sortedness -/

/-- A polynomial is sorted by exponent. -/
def SortedByExp : NatPoly → Prop
  | [] => True
  | [_] => True
  | m₁ :: m₂ :: rest => m₁.exp ≤ m₂.exp ∧ SortedByExp (m₂ :: rest)

/-! ## Irredundancy -/

/-- A polynomial is irredundant: no monomial is strictly dominated by another in the list. -/
def Irredundant (p : NatPoly) : Prop :=
  ∀ m ∈ p, isDomByAny m p = false

/-! ## Phase 1: Sorting Lemmas -/

theorem insertByExp_length (m : NatMono) (p : NatPoly) :
    (insertByExp m p).length = p.length + 1 := by
  induction p with
  | nil => simp [insertByExp]
  | cons n ns ih =>
    simp only [insertByExp]
    split <;> simp [ih]

theorem sortByExp_length (p : NatPoly) :
    (sortByExp p).length = p.length := by
  induction p with
  | nil => rfl
  | cons m ms ih => simp [sortByExp, insertByExp_length, ih]

theorem insertByExp_mem (m n : NatMono) (p : NatPoly) :
    n ∈ insertByExp m p ↔ n = m ∨ n ∈ p := by
  induction p with
  | nil => simp [insertByExp]
  | cons hd tl ih =>
    simp only [insertByExp]
    split <;> simp [ih] <;> tauto

/-! ## Evaluation Lemmas -/

@[simp] theorem evalNatPoly_nil (x : ℕ) : evalNatPoly [] x = 0 := rfl
@[simp] theorem evalNatPoly_singleton (m : NatMono) (x : ℕ) :
    evalNatPoly [m] x = evalMono m x := rfl

theorem evalNatPoly_cons_cons (m₁ m₂ : NatMono) (ms : NatPoly) (x : ℕ) :
    evalNatPoly (m₁ :: m₂ :: ms) x = min (evalMono m₁ x) (evalNatPoly (m₂ :: ms) x) := rfl

theorem eval_insertByExp (m : NatMono) (p : NatPoly) (x : ℕ) (hp : p ≠ []) :
    evalNatPoly (insertByExp m p) x = min (evalMono m x) (evalNatPoly p x) := by
  induction p <;> simp_all +decide [ evalNatPoly_cons_cons ];
  rename_i k l ih; by_cases hl : l = [] <;> simp_all +decide [ insertByExp ] ;
  · split_ifs <;> simp +decide [ *, evalNatPoly_cons_cons ];
    exact min_comm _ _;
  · split_ifs <;> simp_all +decide [ evalNatPoly_cons_cons ];
    cases h : insertByExp m l <;> cases h' : l <;> simp_all +decide [ evalNatPoly_cons_cons ];
    · unfold insertByExp at h; aesop;
    · ac_rfl

theorem eval_sortByExp (p : NatPoly) (x : ℕ) :
    evalNatPoly (sortByExp p) x = evalNatPoly p x := by
  induction' n : p.length using Nat.strong_induction_on with n ih generalizing p x;
  rcases p with ( _ | ⟨ m, _ | ⟨ n, p ⟩ ⟩ ) <;> simp_all +arith +decide;
  · aesop;
  · rfl;
  · convert eval_insertByExp m ( sortByExp ( ‹_› :: p ) ) x _ using 1;
    · grind +suggestions;
    · exact ne_of_apply_ne List.length ( by simp +arith +decide [sortByExp_length] )

/-! ## Phase 2: Merge Evaluation Preservation -/

theorem eval_mergeSameExp (p : NatPoly) (x : ℕ) :
    evalNatPoly (mergeSameExp p) x = evalNatPoly p x := by
  induction' p with m ms ih generalizing x;
  · rfl;
  · -- By definition of `mergeSameExp`, we consider two cases: when the next element has the same exponent as `m` and when it does not.
    by_cases h_exp : (mergeSameExp ms).head?.map (fun n => m.exp = n.exp) = some true;
    · -- Since the next element has the same exponent as `m`, we can apply the induction hypothesis to the rest of the list.
      have h_ind : evalNatPoly (mergeSameExp (m :: ms)) x = min (evalMono m x) (evalNatPoly (mergeSameExp ms) x) := by
        rcases h : mergeSameExp ms with ( _ | ⟨ n, ns ⟩ ) <;> simp_all +decide;
        rw [ show mergeSameExp ( m :: ms ) = ⟨ m.exp, min m.coeff n.coeff ⟩ :: ns from ?_ ];
        · rw [ ← ih ];
          cases ns <;> simp +decide [ *, evalNatPoly ];
          · unfold evalMono; simp +decide [ h_exp, min_add_add_right ] ;
          · simp +decide [ evalMono, h_exp ];
            grind +revert;
        · rw [ mergeSameExp ];
          aesop;
      grind +locals;
    · cases h : mergeSameExp ms <;> simp_all +decide [ evalNatPoly ];
      · rw [ show mergeSameExp ( m :: ms ) = [ m ] from ?_ ];
        · cases ms <;> simp_all +decide [ evalNatPoly ];
          cases h' : mergeSameExp ‹_› <;> simp_all +decide [ mergeSameExp ];
          split_ifs at h;
        · cases ms <;> simp_all +decide [ mergeSameExp ];
      · rw [ show mergeSameExp ( m :: ms ) = m :: mergeSameExp ms from ?_ ];
        · cases ms <;> simp_all +decide [ evalNatPoly ];
          cases h;
        · cases ms <;> simp_all +decide [ mergeSameExp ]

/-! ## Phase 3: Remove Dominated Evaluation Preservation -/

/-- If isStrictDom m n = true, then n dominates m pointwise. -/
theorem strictDom_eval (m n : NatMono) (h : isStrictDom m n = true) (x : ℕ) :
    evalMono n x ≤ evalMono m x := by
  simp only [isStrictDom, Bool.and_eq_true, decide_eq_true_eq, Bool.or_eq_true] at h
  simp only [evalMono]
  nlinarith [h.1.1, h.1.2]

/-
If isDomByAny m p = true then some element of p dominates m pointwise.
-/
theorem isDomByAny_witness (m : NatMono) (p : NatPoly) (h : isDomByAny m p = true) (x : ℕ) :
    ∃ n ∈ p, evalMono n x ≤ evalMono m x := by
  induction' p with n ns ih;
  · contradiction;
  · by_cases h' : isStrictDom m n <;> simp_all +decide [ isDomByAny ];
    exact Or.inl ( strictDom_eval m n h' x )

/-
Helper: evalNatPoly of a nonempty list is the minimum of all monomial evaluations
-/
theorem evalNatPoly_eq_foldl_min (m : NatMono) (ms : NatPoly) (x : ℕ) :
    evalNatPoly (m :: ms) x = ms.foldl (fun acc n => min acc (evalMono n x)) (evalMono m x) := by
  -- We can prove each direction by simplifying the if-then-else expressions based on the value of ms.
  cases ms <;> simp [evalNatPoly];
  rename_i n ns; induction' ns using List.reverseRecOn with ns ih <;> simp_all +decide [ List.foldl ] ;
  rw [ ← ‹min ( evalMono m x ) ( evalNatPoly ( n :: ns ) x ) = List.foldl ( fun acc n => min acc ( evalMono n x ) ) ( min ( evalMono m x ) ( evalMono n x ) ) ns› ];
  -- By definition of `evalNatPoly`, we can split the evaluation into the minimum of the evaluations of the individual monomials.
  have h_eval_split : ∀ (m : NatMono) (ns : NatPoly) (ih : NatMono) (x : ℕ), evalNatPoly (m :: (ns ++ [ih])) x = min (evalNatPoly (m :: ns) x) (evalMono ih x) := by
    intros m ns ih x; induction' ns with ns ih generalizing m ih x <;> simp_all +decide [ evalNatPoly ] ;
  rw [ h_eval_split, min_assoc ]

/-
Helper: foldl min over a sublist is ≥ foldl min over the full list
-/
theorem foldl_min_filter_ge (f : α → ℕ) (pred : α → Bool) (l : List α) (init : ℕ) :
    l.foldl (fun acc a => min acc (f a)) init ≤
    (l.filter pred).foldl (fun acc a => min acc (f a)) init := by
  induction' l using List.reverseRecOn with l ih <;> simp +decide [ List.filter_cons ];
  grind

/-
Helper: foldl min distributes over min in initial value
-/
theorem foldl_min_init_min (l : List α) (f : α → ℕ) (init v : ℕ) :
    l.foldl (fun acc a => min acc (f a)) (min init v) =
    min (l.foldl (fun acc a => min acc (f a)) init) v := by
  induction' l using List.reverseRecOn with l ih <;> simp +decide [ min_assoc ];
  grind +extAll

/-
Helper: if b ∈ l and f b ≤ v, then adding min with v to init is redundant
-/
theorem foldl_min_redundant (l : List α) (f : α → ℕ) (init v : ℕ)
    (hb : ∃ b ∈ l, f b ≤ v) :
    l.foldl (fun acc a => min acc (f a)) (min init v) =
    l.foldl (fun acc a => min acc (f a)) init := by
  -- By induction on the list l, we can show that the foldl with min init v is equal to the foldl with init.
  induction' l with a l ih generalizing init v;
  · grind +revert;
  · simp_all +decide [ List.foldl_cons ];
    grind

/-
Helper: if every filtered-out element has a surviving dominator,
the filtered min equals the original min
-/
theorem foldl_min_filter_eq (l : List α) (f : α → ℕ) (pred : α → Bool) (init : ℕ)
    (hdom : ∀ a ∈ l, pred a = false → ∃ b ∈ l, pred b = true ∧ f b ≤ f a) :
    (l.filter pred).foldl (fun acc a => min acc (f a)) init =
    l.foldl (fun acc a => min acc (f a)) init := by
  -- By definition of `foldl`, we can express it as a series of min operations.
  have h_foldl_def : ∀ (l : List α) (init : ℕ), List.foldl (fun acc a => min acc (f a)) init l = List.foldl min init (List.map f l) := by
    intro l init; induction' l using List.reverseRecOn with l ih <;> simp +decide [ * ] ;
  -- Apply the definition of `foldl` from `h_foldl_def`.
  rw [h_foldl_def, h_foldl_def];
  -- Since every element in `l` that does not satisfy `pred` is dominated by some element in `l` that does satisfy `pred`, the minimum value of `f` over `l` is the same as the minimum value of `f` over the filtered list.
  have h_min_eq : ∀ x ∈ List.map f l, ∃ y ∈ List.map f (List.filter pred l), y ≤ x := by
    simp +zetaDelta at *;
    grind;
  -- Since every element in `l` that does not satisfy `pred` is dominated by some element in `l` that does satisfy `pred`, the minimum value of `f` over `l` is the same as the minimum value of `f` over the filtered list. Hence, the foldl operations are equal.
  have h_foldl_eq : ∀ (l₁ l₂ : List ℕ) (init : ℕ), (∀ x ∈ l₁, ∃ y ∈ l₂, y ≤ x) → List.foldl min init l₁ ≥ List.foldl min init l₂ := by
    intros l₁ l₂ init h_dom
    induction' l₁ using List.reverseRecOn with x l₁ ih generalizing init;
    · induction' l₂ using List.reverseRecOn with x l₂ ih <;> simp +decide [ * ];
      exact Or.inl ( by simpa using ih ( by simp +decide ) );
    · simp +zetaDelta at *;
      exact ⟨ ih init fun y hy => h_dom y ( Or.inl hy ), by obtain ⟨ y, hy₁, hy₂ ⟩ := h_dom l₁ ( Or.inr rfl ) ; exact le_trans ( show List.foldl min init l₂ ≤ y from by
                                                                                                                                  have h_foldl_le : ∀ (l : List ℕ) (init : ℕ) (y : ℕ), y ∈ l → List.foldl min init l ≤ y := by
                                                                                                                                    intros l init y hy; induction' l using List.reverseRecOn with x l ih generalizing init; aesop;
                                                                                                                                    grind;
                                                                                                                                  exact h_foldl_le _ _ _ hy₁ ) hy₂ ⟩;
  refine' le_antisymm _ _;
  · exact h_foldl_eq _ _ _ h_min_eq;
  · exact h_foldl_eq _ _ _ fun x hx => by aesop;

/-
Helper: isDomByAny witnesses have surviving non-dominated elements
-/
theorem isDomByAny_has_survivor (m : NatMono) (p : NatPoly)
    (h : isDomByAny m p = true) (x : ℕ) :
    ∃ n ∈ p, isDomByAny n p = false ∧ evalMono n x ≤ evalMono m x := by
  revert h x;
  induction' n : m.coeff + m.exp using Nat.strong_induction_on with n ih generalizing m p;
  intro hm x;
  -- If isDomByAny m p = true, then there exists n ∈ p with isStrictDom m n = true, meaning n.coeff ≤ m.coeff, n.exp ≤ m.exp, with one strict.
  obtain ⟨n, hn⟩ : ∃ n ∈ p, isStrictDom m n = true := by
    have h_dom : ∀ {p : NatPoly}, isDomByAny m p = true → ∃ n ∈ p, isStrictDom m n = true := by
      intros p hp; induction' p with n p ih <;> simp_all +decide [ isDomByAny ] ;
      grind;
    exact h_dom hm;
  by_cases h : isDomByAny n p <;> simp_all +decide [ isStrictDom ];
  · exact Exists.elim ( ih _ ( by cases hn.2.2 <;> linarith ) _ _ rfl h x ) fun k hk => ⟨ k, hk.1, hk.2.1, le_trans hk.2.2 ( strictDom_eval _ _ ( by unfold isStrictDom; aesop ) _ ) ⟩;
  · exact ⟨ n, hn.1, h, by unfold evalMono; cases hn.2.2 <;> nlinarith ⟩

-- isStrictDom is irreflexive
theorem isStrictDom_irrefl (m : NatMono) : isStrictDom m m = false := by
  simp [isStrictDom]

-- isDomByAny m [m] = false (since isStrictDom is irreflexive)
theorem isDomByAny_self_singleton (m : NatMono) : isDomByAny m [m] = false := by
  simp [isDomByAny, isStrictDom_irrefl]

-- removeDominated preserves membership of non-dominated elements
theorem mem_removeDominated (m : NatMono) (p : NatPoly) (hm : m ∈ p)
    (hnd : isDomByAny m p = false) :
    m ∈ removeDominated p := by
  simp [removeDominated, List.mem_filter, hm, hnd]

/-
removeDominated of nonempty list is nonempty
-/
theorem removeDominated_nonempty (p : NatPoly) (hp : p ≠ []) :
    removeDominated p ≠ [] := by
  -- By definition of `removeDominated`, there exists some monomial `m` in `p` such that `m` is not dominated by any other monomial in `p`.
  obtain ⟨m, hm⟩ : ∃ m ∈ p, isDomByAny m p = false := by
    by_contra h_contra;
    -- By repeatedly applying `isDomByAny_has_survivor`, we can find a chain of dominated elements.
    have h_chain : ∀ m ∈ p, ∃ n ∈ p, isDomByAny n p = false ∧ evalMono n 0 ≤ evalMono m 0 := by
      exact fun m hm => isDomByAny_has_survivor m p ( by aesop ) 0;
    exact h_contra <| by obtain ⟨ m, hm ⟩ := List.length_pos_iff_exists_mem.mp ( List.length_pos_iff.mpr hp ) ; obtain ⟨ n, hn₁, hn₂, hn₃ ⟩ := h_chain m hm; exact ⟨ n, hn₁, hn₂ ⟩ ;
  exact List.ne_nil_of_mem ( List.mem_filter.mpr ⟨ hm.1, by simp +decide [ hm.2 ] ⟩ )

/-
Evaluation as infimum over all monomials for nonempty lists
-/
theorem evalNatPoly_le_evalMono (m : NatMono) (p : NatPoly) (hm : m ∈ p) (hp : p ≠ []) (x : ℕ) :
    evalNatPoly p x ≤ evalMono m x := by
  induction' p with m p ih generalizing x;
  · contradiction;
  · cases p <;> simp_all +decide [ List.foldl ];
    cases hm <;> simp_all +decide [ evalNatPoly_cons_cons ]

/-
Evaluation is achieved by some monomial
-/
theorem evalNatPoly_eq_some_mono (p : NatPoly) (hp : p ≠ []) (x : ℕ) :
    ∃ m ∈ p, evalNatPoly p x = evalMono m x := by
  induction' p with m p ih generalizing x;
  · contradiction;
  · rcases p with ( _ | ⟨ n, p ⟩ ) <;> simp_all +decide;
    grind +suggestions

theorem eval_removeDominated (p : NatPoly) (x : ℕ) :
    evalNatPoly (removeDominated p) x = evalNatPoly p x := by
  by_cases h : p ≠ [] <;> simp_all +decide;
  · -- By definition of `removeDominated`, we know that every monomial in `p` that is dominated by another monomial in `p` is removed.
    have h_dom : ∀ m ∈ p, isDomByAny m p = true → ∃ n ∈ removeDominated p, evalMono n x ≤ evalMono m x := by
      intros m hm hdom
      obtain ⟨n, hn₁, hn₂⟩ : ∃ n ∈ p, isDomByAny n p = false ∧ evalMono n x ≤ evalMono m x := isDomByAny_has_survivor m p hdom x;
      exact ⟨ n, mem_removeDominated n p hn₁ hn₂.1, hn₂.2 ⟩;
    refine' le_antisymm _ _;
    · obtain ⟨ m, hm₁, hm₂ ⟩ := evalNatPoly_eq_some_mono p h x;
      by_cases hm₃ : isDomByAny m p <;> simp_all +decide;
      · obtain ⟨ n, hn₁, hn₂ ⟩ := h_dom m hm₁ hm₃;
        exact le_trans ( evalNatPoly_le_evalMono n ( removeDominated p ) hn₁ ( by aesop ) x ) hn₂;
      · exact evalNatPoly_le_evalMono m ( removeDominated p ) ( mem_removeDominated m p hm₁ hm₃ ) ( removeDominated_nonempty p h ) x;
    · obtain ⟨ m, hm₁, hm₂ ⟩ := evalNatPoly_eq_some_mono ( removeDominated p ) ( removeDominated_nonempty p h ) x;
      exact hm₂ ▸ evalNatPoly_le_evalMono m p ( List.mem_filter.mp hm₁ |>.1 ) h x;
  · rfl

/-! ## Main Correctness Theorem -/

/-- The canonicalization algorithm preserves tropical evaluation. -/
theorem eval_canonicalizeFast (p : NatPoly) (x : ℕ) :
    evalNatPoly (canonicalizeFast p) x = evalNatPoly p x := by
  unfold canonicalizeFast
  rw [eval_removeDominated, eval_mergeSameExp, eval_sortByExp]

/-- canonicalizeFast produces a tropically equivalent polynomial. -/
theorem canonicalizeFast_tropEquiv (p : NatPoly) :
    TropicallyEquivalent (canonicalizeFast p) p :=
  fun x => eval_canonicalizeFast p x

/-! ## Irredundancy -/

/-
The output of removeDominated is irredundant by construction.
-/
theorem removeDominated_irredundant (p : NatPoly) :
    Irredundant (removeDominated p) := by
  intros m hm;
  have h_no_dom : ∀ q : NatPoly, q ⊆ p → ∀ m ∈ q, isDomByAny m p = false → isDomByAny m q = false := by
    intros q hq m hm h_no_dom
    have h_dom_in_p : ∀ n ∈ q, isStrictDom m n = true → isDomByAny m p = true := by
      intros n hn h_dom_q
      have h_dom_in_p : isDomByAny m p = true := by
        have h_dom_in_p : ∃ n' ∈ p, isStrictDom m n' = true := by
          exact ⟨ n, hq hn, h_dom_q ⟩
        obtain ⟨ n', hn', h_dom_n' ⟩ := h_dom_in_p;
        have h_dom_in_p : ∀ {p : NatPoly}, n' ∈ p → isStrictDom m n' = true → isDomByAny m p = true := by
          intros p hn' h_dom_n'
          induction' p with p hp_tail ih;
          · contradiction;
          · unfold isDomByAny; aesop;
        exact h_dom_in_p hn' h_dom_n';
      exact h_dom_in_p;
    have h_dom_in_p : ∀ q : NatPoly, (∀ n ∈ q, isStrictDom m n = false) → isDomByAny m q = false := by
      intros q hq; induction q <;> simp_all +decide [ isDomByAny ] ;
    grind +splitImp;
  exact h_no_dom _ ( fun x hx => by simpa using List.mem_filter.mp hx |>.1 ) _ hm ( by simpa using List.mem_filter.mp hm |>.2 )

/-- canonicalizeFast produces an irredundant polynomial. -/
theorem canonicalizeFast_irredundant (p : NatPoly) :
    Irredundant (canonicalizeFast p) :=
  removeDominated_irredundant _

/-! ## Complexity Bounds -/

theorem insertionSortCost_le (n : ℕ) :
    insertionSortCost n ≤ n * n := by
  induction n with
  | zero => simp [insertionSortCost]
  | succ k ih => simp only [insertionSortCost]; nlinarith

/-- The total canonicalization cost is O(n²). -/
theorem canonCost_quadratic (p : NatPoly) :
    canonCost p ≤ 3 * p.length * p.length + p.length + 1 := by
  unfold canonCost
  have h1 := insertionSortCost_le p.length
  nlinarith [p.length.zero_le]

/-! ## Combined Flagship Theorem -/

/-- The flagship theorem: canonicalizeFast is correct, irredundant, and efficient. -/
theorem canonicalizeFast_certified (p : NatPoly) :
    TropicallyEquivalent (canonicalizeFast p) p ∧
    Irredundant (canonicalizeFast p) ∧
    canonCost p ≤ 3 * p.length * p.length + p.length + 1 :=
  ⟨canonicalizeFast_tropEquiv p,
   canonicalizeFast_irredundant p,
   canonCost_quadratic p⟩

/-! ## Length Bound -/

theorem removeDominated_length_le (p : NatPoly) :
    (removeDominated p).length ≤ p.length := by
  unfold removeDominated
  exact List.length_filter_le _ _

theorem canonicalizeFast_length_le (p : NatPoly) :
    (canonicalizeFast p).length ≤ p.length := by
  refine' le_trans _ ( _ : _ ≤ p.length );
  exact ( mergeSameExp ( sortByExp p ) ).length;
  · -- By definition of `canonicalizeFast`, we have that `canonicalizeFast p = removeDominated (mergeSameExp (sortByExp p))`. Since `removeDominated` is a filter, its length is less than or equal to the input length.
    apply removeDominated_length_le;
  · -- By definition of `mergeSameExp`, the length of the merged list is less than or equal to the length of the input list.
    have h_merge_length : ∀ (p : NatPoly), (mergeSameExp p).length ≤ p.length := by
      intro p;
      induction' p with m p ih;
      · rfl;
      · grind +locals;
    exact le_trans ( h_merge_length _ ) ( by simp +decide [ sortByExp_length ] )

/-! ## Computational Tests -/

-- Example: canonicalize [(2,5), (1,3), (2,1), (1,7)]
#eval canonicalizeFast [⟨2, 5⟩, ⟨1, 3⟩, ⟨2, 1⟩, ⟨1, 7⟩]

-- Example: evaluation before and after
#eval (evalNatPoly [⟨2, 5⟩, ⟨1, 3⟩, ⟨2, 1⟩, ⟨1, 7⟩] 10,
       evalNatPoly (canonicalizeFast [⟨2, 5⟩, ⟨1, 3⟩, ⟨2, 1⟩, ⟨1, 7⟩]) 10)

end TropicalCanon