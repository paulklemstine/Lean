import Mathlib

/-!
# The Library of Babel: finite combinatorics

This file formalizes the finite combinatorial core of Borges' *Library of Babel*.

A **book** of length `n` over an alphabet of `k` symbols is modelled as a function
`Fin n → ℕ` all of whose values are `< k` (i.e. lie in `Finset.range k`).  The set of
all such books is the `n`-fold Cartesian power of `Finset.range k`, encoded with
`Fintype.piFinset`.

Main results:

* `Book` / `mem_Book` : the finite set of all books of length `n` over `k` symbols.
* `card_Library` : the library contains exactly `k ^ n` books.
* `card_Cylinder` : the cylinder set of books sharing a fixed prefix of length `m`
  has cardinality `k ^ (n - m)`.
* `card_Window` : the set of books containing a fixed window of length `w` at a fixed
  position `pos` has cardinality `k ^ (n - w)`.
* `hd_le`, `hd_eq_zero_iff`, `hd_eq_card_iff` : basic Hamming-distance facts —
  the distance is at most `n`, is `0` iff the books are equal, and is `n` iff the books
  differ in every position (no position carries a common symbol).

All proofs use elementary counting arguments.
-/

open Finset

namespace LibraryOfBabel.Combinatorics

/-- `Book n k` is the `n`-fold Cartesian power of `Finset.range k`: the finite set of
all books of length `n` over an alphabet of `k` symbols, each book being a function
`Fin n → ℕ` whose values lie in `Finset.range k`. -/
def Book (n k : ℕ) : Finset (Fin n → ℕ) :=
  Fintype.piFinset (fun _ : Fin n => Finset.range k)

@[simp] lemma mem_Book {n k : ℕ} {b : Fin n → ℕ} : b ∈ Book n k ↔ ∀ i, b i < k := by
  simp [Book, Fintype.mem_piFinset]

/-- The Library of Babel: the collection of all books of length `n` over `k` symbols. -/
def Library (n k : ℕ) : Finset (Fin n → ℕ) := Book n k

/-- The Library of Babel contains exactly `k ^ n` books. -/
theorem card_Library (n k : ℕ) : (Library n k).card = k ^ n := by
  simp [Library, Book, Fintype.card_piFinset]

/-- **Key counting lemma.** Fixing the values of a book on a finite set `S` of
positions (to admissible symbols `val i < k`) and leaving the remaining positions
free leaves exactly `k ^ (n - S.card)` books. -/
theorem card_constrained (n k : ℕ) (S : Finset (Fin n)) (val : Fin n → ℕ)
    (hval : ∀ i ∈ S, val i < k) :
    ((Book n k).filter (fun b => ∀ i ∈ S, b i = val i)).card = k ^ (n - S.card) := by
  -- By definition of $d$, we have $d i = val i$ if $i \in S$ and $d i = Finset.range k$ if $i \notin S$.
  set d : Fin n → Finset ℕ := fun i => if i ∈ S then {val i} else Finset.range k;
  -- Show that the set of books satisfying the condition is exactly the piFinset of $d$.
  have h_piFinset : (Book n k).filter (fun b => ∀ i ∈ S, b i = val i) = Fintype.piFinset d := by
    ext b; simp [d, mem_Book];
    grind;
  rw [ h_piFinset, Fintype.card_piFinset ];
  rw [ Finset.prod_congr rfl fun i hi => show # ( d i ) = if i ∈ S then 1 else k from ?_, Finset.prod_ite ];
  · simp +decide [ Finset.filter_not, Finset.card_sdiff ];
  · grind

/-- The **cylinder set** of all books whose first `m` symbols agree with a fixed
prefix `p`.  Here `hm : m ≤ n` and `p : Fin m → ℕ`. -/
def Cylinder (n k m : ℕ) (hm : m ≤ n) (p : Fin m → ℕ) : Finset (Fin n → ℕ) :=
  (Book n k).filter (fun b => ∀ j : Fin m, b (Fin.castLE hm j) = p j)

/-
A cylinder set fixing an admissible prefix of length `m` has cardinality
`k ^ (n - m)`.
-/
theorem card_Cylinder (n k m : ℕ) (hm : m ≤ n) (p : Fin m → ℕ) (hp : ∀ j, p j < k) :
    (Cylinder n k m hm p).card = k ^ (n - m) := by
  convert card_constrained n k ( Finset.filter ( fun i : Fin n => ( i : ℕ ) < m ) Finset.univ ) ( fun i => if h : ( i : ℕ ) < m then p ⟨ i, h ⟩ else 0 ) _ using 1;
  · congr with b;
    simp +decide [ Cylinder, Book ];
    exact fun _ => ⟨ fun h i hi => by simpa [ hi ] using h ⟨ i, hi ⟩, fun h j => by simpa [ Fin.castLE ] using h ( Fin.castLE hm j ) ( by simp +decide [ Fin.castLE ] ) ⟩;
  · rw [ Finset.card_eq_of_bijective ];
    use fun i hi => ⟨ i, by linarith ⟩;
    · aesop;
    · aesop;
    · grind;
  · aesop

/-- The set of all books that contain a fixed window `w` of length `wlen` starting at
position `pos`.  Here `hpos : pos + wlen ≤ n`. -/
def Window (n k pos wlen : ℕ) (hpos : pos + wlen ≤ n) (w : Fin wlen → ℕ) :
    Finset (Fin n → ℕ) :=
  (Book n k).filter (fun b => ∀ j : Fin wlen, b ⟨pos + j, by have := j.isLt; omega⟩ = w j)

/-
The set of books containing an admissible window of length `wlen` at a fixed
position has cardinality `k ^ (n - wlen)`.
-/
theorem card_Window (n k pos wlen : ℕ) (hpos : pos + wlen ≤ n) (w : Fin wlen → ℕ)
    (hw : ∀ j, w j < k) :
    (Window n k pos wlen hpos w).card = k ^ (n - wlen) := by
  convert card_constrained n k ( Finset.univ.filter ( fun i ↦ pos ≤ i ∧ i < pos + wlen ) ) ( fun i ↦ if h : pos ≤ i ∧ i < pos + wlen then w ⟨ i - pos, by omega ⟩ else 0 ) _ using 2;
  · grind +locals;
  · rw [ Finset.card_eq_of_bijective ];
    use fun i hi => ⟨ pos + i, by linarith ⟩;
    · exact fun a ha => ⟨ a.val - pos, by rw [ tsub_lt_iff_left ] <;> linarith [ Finset.mem_filter.mp ha, Fin.is_lt a ], by erw [ Fin.ext_iff ] ; simp +decide [ add_tsub_cancel_of_le ( Finset.mem_filter.mp ha |>.2.1 ) ] ⟩;
    · grind +qlia;
    · lia;
  · grind

/-- The **Hamming distance** between two books: the number of positions at which they
differ. -/
def hd {n : ℕ} (b1 b2 : Fin n → ℕ) : ℕ :=
  (Finset.univ.filter (fun i => b1 i ≠ b2 i)).card

/-
The Hamming distance between two books of length `n` is at most `n`.
-/
theorem hd_le {n : ℕ} (b1 b2 : Fin n → ℕ) : hd b1 b2 ≤ n := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )

/-
The Hamming distance is `0` iff the two books are identical.
-/
theorem hd_eq_zero_iff {n : ℕ} (b1 b2 : Fin n → ℕ) : hd b1 b2 = 0 ↔ b1 = b2 := by
  simp +decide [ hd, funext_iff, Finset.ext_iff ]

/-
The Hamming distance equals `n` iff the two books differ in every position,
i.e. they share no common symbol at any position.
-/
theorem hd_eq_card_iff {n : ℕ} (b1 b2 : Fin n → ℕ) :
    hd b1 b2 = n ↔ ∀ i, b1 i ≠ b2 i := by
  constructor <;> intro h;
  · contrapose! h;
    exact ne_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.filter_ssubset.mpr ( by aesop ) ) ) ( by simp ) );
  · unfold hd; aesop;

end LibraryOfBabel.Combinatorics